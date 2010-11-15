/* Do not alter this SPC information: $Revision: 1.2.40.1 $ */
/*
**	NAME:									frmdrtab.c
**	AUTHORS:								Terry McIntyre
**	CREATION DATE:							11/90
**	ABSTRACT:
**		The code to process the drop table form.
**	
**	REVISION HISTORY:
**
**	11/94:	Added support for INTERNATIONALIZATION.  Linda Wang
**	02/03/95 Removed NTJ specific changes. rlk
*/
 
/*
**	INCLUDES
*/
#include "forms.h"

/*
**	FUNCTION PROTOTYPES
*/
#define frmdrtab_c
#include "comdebug.prt"
#include "comumsg.prt"
#include "frmdadef.prt"
#include "frmdrtab.prt"
#include "frmerror.prt"
#include "frmexec.prt"
#include "frmntfy.prt"
#include "frmobj.prt"
#include "frmutil.prt"
#include "fi.prt"
#include "ris.prt"
#include "sys.prt"
#if defined (WIN32)
#include "fi_winnt.prt"
#endif


/*
**	DEFINES
*/

/*
**	VARIABLES
*/
static  Form			dt_form = 0;
static RISfrm_msg	*dt_msg = &RISfrm_msgs[DT_FORM_MSG];
static  char			initial_table_name[RIS_MAX_ID_SIZE] = "";

/*
**	FUNCTIONS
*/

/*******************************************************************************
************** DT_MSG_FIELD ****************************************************
*******************************************************************************/

static void update_msg_field(
	const char	*msg)
{
	FRM_DBG(("update_msg_field(msg:<%s>)\n", msg));
	FIfld_set_text(dt_form, DT_MSG_FIELD, 0, 0, (char *)msg, 0);
}

/******************************************************************************/

static void clear_msg_field()
{
	FRM_DBG(("clear_msg_field()\n"));
	FIfld_set_text(dt_form, DT_MSG_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** DT_TABLE_NAME_FIELD ***************************************
*******************************************************************************/

static char *get_table_name_field()
{
	static	 char	table_name[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_table_name_field()\n"));

	RISfrm_get_field(dt_form, DT_TABLE_NAME_FIELD, RIS_MAX_ID_SIZE, table_name);
	return table_name[0] ? table_name : NULL;
}

/******************************************************************************/

static void process_table_name_field()
{
	char			*table_name;
	RISfrm_object	*object;

	FRM_DBG(("process_table_name_field()\n"));

	table_name = get_table_name_field();
	if (!RISfrm_field_changed(table_name, initial_table_name))
	{
		return;
	}
	object = RISfrm_get_table_object(table_name, RIS_NAME, update_msg_field,
		clear_msg_field);
	if (object == NULL)
	{
		if (table_name)
		{
			sprintf(dt_msg->str, MSG(RISUTL_I_UNKNOWN_TABLE), table_name);
		}
	}

	if (RISfrm_dd_form_displayed())
	{
		RISfrm_update_dd_objects_mcf(object);
	}

	update_dt_form(object);
}

/******************************************************************************/

static void update_table_name_field(
	char	*table_name)
{
	FRM_DBG(("update_table_name_field(table_name:<%s>)\n",table_name));
	FIfld_set_text(dt_form, DT_TABLE_NAME_FIELD, 0, 0, table_name, 0);
	strcpy(initial_table_name, table_name);
}

/******************************************************************************/

static void clear_table_name_field()
{
	FRM_DBG(("clear_table_name_field()\n"));
	FIfld_set_text(dt_form, DT_TABLE_NAME_FIELD, 0, 0, "", 0);
	strcpy(initial_table_name, "");
}

/*******************************************************************************
******************** EXECUTE BUTTON ********************************************
*******************************************************************************/

static void process_execute_button()
{
	char			*cmd;
	char			*table_name;
	char			drop_table_command[128];
	RISfrm_object	*object;

	FRM_DBG(("process_execute_button()\n"));

	cmd = drop_table_command;

	if ((table_name = get_table_name_field()) == NULL)
	{
		dt_msg->label[dt_msg->count++] = DT_TABLE_NAME_TEXT;
		dt_msg->label[dt_msg->count++] = DT_TABLE_NAME_FIELD;
		strcpy(dt_msg->str, MSG(RISUTL_I_TABNAME_MUST_BE_SPEC));
		FIfld_pos_cursor(dt_form, DT_TABLE_NAME_FIELD, 0, 0, 0, 0, 0, 0);
		return;
	}
	object = RISfrm_get_table_object(table_name, RIS_NAME, update_msg_field,
		clear_msg_field);
	if (object == NULL)
	{
		dt_msg->label[dt_msg->count++] = DT_TABLE_NAME_TEXT;
		dt_msg->label[dt_msg->count++] = DT_TABLE_NAME_FIELD;
		sprintf(dt_msg->str, MSG(RISUTL_I_UNKNOWN_TABLE), table_name);
		FIfld_pos_cursor(dt_form, DT_TABLE_NAME_FIELD, 0, 0, 0, 0, 0, 0);
		return;
	}

	cmd += sprintf(cmd,"DROP TABLE %s", table_name);

	FRM_DBG(("%s\n",drop_table_command));

	if (RISfrm_user_exec_dt_form &&
		RISfrm_user_exec_dt_form(dt_form, drop_table_command) == 0)
			return;

	strcpy(dt_msg->str, MSG(RISUTL_I_DROPPING_TABLE));
	update_msg_field(dt_msg->str);
	RISfrm_execute_command(drop_table_command);
	dt_msg->str[0] = 0;
	clear_msg_field();

	if (SQLCODE)
	{
		RISfrm_form_errhandle(RISUTL_E_RIS_ERROR, 0);
		if (RISfrm_report_error() == 0) return;
	
		switch(SQLCODE)
		{
		}
		return;
	}
	RISfrm_object_list_up_to_date = 0;

	strcpy(dt_msg->str, MSG(RISUTL_I_DROP_TABLE_SUCCESS));
	update_msg_field(dt_msg->str);
	clear_table_name_field();

	if (RISfrm_dd_form_displayed())
	{
		char def_schname[RIS_MAX_ID_SIZE] = "";

		RISget_default_schema_name(def_schname);
		RISfrm_load_dd_objects_mcf(def_schname);
	}
}

/*******************************************************************************
******************** CANCEL_BUTTON *********************************************
*******************************************************************************/

static void process_cancel_button()
{
	FRM_DBG(("process_cancel_button()\n"));
	RISfrm_erase_dt_form();
	if (RISfrm_dd_form_displayed())
		RISfrm_clear_dd_drop_table_button();
}

/*******************************************************************************
******************** RESET_BUTTON **********************************************
*******************************************************************************/

static void process_reset_button()
{
	FRM_DBG(("process_reset_button()\n"));
	RISfrm_clear_dt_form();
	if (RISfrm_dd_form_displayed())
		RISfrm_update_dd_objects_mcf((RISfrm_object *)0);
	DISPLAY_HELP_BUTTON(dt_form);
	RISfrm_call_user_init_dt_form();
}

/*******************************************************************************
******************** DS FORM ***************************************************
*******************************************************************************/

extern void RISfrm_process_dt_form(
	int	g_label)
{
	int	i;
	static	RISfrm_label_function	process_gadget[] = 
	{
		{	FI_CANCEL,				process_cancel_button		},
		{	FI_RESET,				process_reset_button		},
		{	FI_EXECUTE,				process_execute_button		},
		{	DT_TABLE_NAME_FIELD,	process_table_name_field	},
	};
	static	int	process_gadget_count =
		sizeof(process_gadget)/sizeof(RISfrm_label_function);

	FRM_DBG(("RISfrm_process_dt_form(g_label:%d)\n", g_label));

	VALID_FORM_CHECK(dt_form);

	for (i = 0; i < process_gadget_count; i++)
	{
		if (process_gadget[i].label == g_label)
		{
			(process_gadget[i].function_ptr)();
			break;
		}
	}
}

/******************************************************************************/

extern void RISfrm_call_user_init_dt_form()
{
	FRM_DBG(("RISfrm_call_user_init_dt_form()\n"));

	VALID_FORM_CHECK(dt_form);

	if (RISfrm_user_init_dt_form)
	{
		FRM_DBG(("calling RISfrm_user_init_dt_form()\n"));
		RISfrm_user_init_dt_form(dt_form);
	}
}

/******************************************************************************/

extern int RISfrm_display_dt_form(
	int	called_by_user,
	int	disable_flag)
{
	int		sts;
	char	def_schname[RIS_MAX_ID_SIZE];

	FRM_DBG(("RISfrm_display_dt_form(called_by_user:%d disable_flag:%d)\n",
		called_by_user, disable_flag));

	if (!RISfrm_initialized)
	{
		RISfrm_form_errhandle(RISUTL_E_FORMS_NOT_INITIALIZED, 0);
		return RIS_forms_error.error;
	}

	if (!dt_form)
	{
		sts = FIf_new(DT_FORM, DT_FORM_FILE, RISfrm_notification_routine,
			&dt_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_CREATE_DT_FORM, sts);
			return RIS_forms_error.error;
		}
#if defined(WIN32)
		FIf_SetDefaultButton(dt_form, FI_EXECUTE);
		FIg_set_text(dt_form, FI_CANCEL, RIScom_umsg(RISUTL_I_CLOSE));
#endif
	}

	if (!RISfrm_dt_form_displayed())
	{
		dt_msg->str[0] = 0;
		dt_msg->count = 0;
		dt_msg->msg_fld_label = DT_MSG_FIELD;
		dt_msg->fp = dt_form;

		DISPLAY_HELP_BUTTON(dt_form);

		if (disable_flag)
			RISfrm_disable_dt_form();
		else
			RISfrm_enable_dt_form();

		if (called_by_user)
		{
			RISget_default_schema_name(def_schname);
			if (!def_schname[0])
			{
				RISfrm_form_errhandle(RISUTL_E_FORM_NO_SCHEMA, 0);
				return RIS_forms_error.error;
			}
			RISfrm_object_list_up_to_date = 0;
			RISfrm_call_user_init_dt_form();
		}

		sts = FIf_display (dt_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_DISPLAY_DT_FORM, sts);
			return RIS_forms_error.error;
		}
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/******************************************************************************/

static void update_dt_form(
	RISfrm_object	*objectp)
{
	/*
	**	This routine is called internally when ever the table_name changes.
	**	It should update every thing on the form that needs updating
	**	except the table_name_field()
	*/

	FRM_DBG(("update_dt_form(objectp:0x%x)\n",objectp));

	/*
	** Nothing to do, just being consistant with other forms
	*/
}

/******************************************************************************/

extern void RISfrm_update_dt_form(
	RISfrm_object	*objectp)
{
	/*
	**	This routine is called by other forms to update this form.  It should
	**	update the table_name field, then call the internal update function.
	*/

	FRM_DBG(("RISfrm_update_dt_form(objectp:0x%x)\n",objectp));

	VALID_FORM_CHECK(dt_form);

	if (!objectp)
	{
		clear_table_name_field();
	}
	else
	{
		update_table_name_field(objectp->name);
	}
	update_dt_form(objectp);
}

/******************************************************************************/

extern void RISfrm_clear_dt_form()
{
	FRM_DBG(("RISfrm_clear_dt_form()\n"));

	VALID_FORM_CHECK(dt_form);

	clear_table_name_field();
}

/******************************************************************************/

extern void RISfrm_enable_dt_form()
{
	FRM_DBG(("RISfrm_enable_dt_form()\n"));

	VALID_FORM_CHECK(dt_form);

	FIg_enable(dt_form, DT_TABLE_NAME_FIELD);
	FIg_enable(dt_form, FI_RESET);
	FIg_enable(dt_form, FI_EXECUTE);

}

/******************************************************************************/

extern void RISfrm_disable_dt_form()
{
	FRM_DBG(("RISfrm_disable_dt_form()\n"));

	VALID_FORM_CHECK(dt_form);

	FIg_disable(dt_form, DT_TABLE_NAME_FIELD);
	FIg_disable(dt_form, FI_RESET);
	FIg_disable(dt_form, FI_EXECUTE);
}

/******************************************************************************/

extern int RISfrm_dt_form_displayed()
{
	int	form_displayed;

	FRM_DBG(("RISfrm_dt_form_displayed()\n"));

	if (!dt_form)
	{
		return(0);
	}

	FIf_is_displayed(dt_form, &form_displayed);
	return(form_displayed);
}

/******************************************************************************/

extern int RISfrm_erase_dt_form()
{
	int	sts;

	FRM_DBG(("RISfrm_erase_dt_form()\n"));

	if (RISfrm_dt_form_displayed())
	{
		sts = FIf_erase(dt_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_ERASE_DT_FORM, sts);
			return RIS_forms_error.error;
		}
		RISfrm_clear_dt_form();
		if (RISfrm_dd_form_displayed())
			RISfrm_clear_dd_drop_table_button();
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/*******************************************************************************
************** USER FUNCTIONS **************************************************
*******************************************************************************/

extern int RISAPI RISXfrm_drop_table_form_displayed()
{
	return RISfrm_dt_form_displayed();
}

/******************************************************************************/

extern int RISAPI RISXfrm_display_drop_table_form()
{
	return RISfrm_display_dt_form(CALLED_BY_USER, DISPLAY_ENABLED);
}

/******************************************************************************/

extern int RISAPI RISXfrm_erase_drop_table_form()
{
	return RISfrm_erase_dt_form();
}

/******************************************************************************/
