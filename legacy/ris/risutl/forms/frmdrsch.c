/* Do not alter this SPC information: $Revision: 1.3.27.1 $ */
/*
**	NAME:						frmdrsch.c
**	AUTHORS:					Terry McIntyre
**	CREATION DATE:				11/90
**	ABSTRACT:
**		The code to process the drop schema form.
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
#define frmdrsch_c
#include "comdebug.prt"
#include "comumsg.prt"
#include "frmschdf.prt"
#include "frmdrsch.prt"
#include "frmerror.prt"
#include "frmexec.prt"
#include "frmfile.prt"
#include "frmntfy.prt"
#include "frmschmg.prt"
#include "frmutil.prt"
#include "fi.prt"
#include "sys.prt"
#if defined (WIN32)
#include "fi_winnt.prt"
#endif

/*
**	DEFINES
*/
#if defined(unix)
#define FORCE_BUTTON DS_FORCE_BUTTON
#endif
#if defined(WIN32)
#define FORCE_BUTTON FI_FORM_OK
#endif

/*
**	VARIABLES
*/
static  Form			ds_form = 0;
static RISfrm_msg	*ds_msg = &RISfrm_msgs[DS_FORM_MSG];
static  char			initial_schname[RIS_MAX_ID_SIZE] = "";


/*
**	FUNCTIONS
*/

/*******************************************************************************
************** DS_MSG_FIELD ****************************************************
*******************************************************************************/

static void update_msg_field(
	const char	*msg)
{
	FRM_DBG(("update_msg_field(msg:<%s>)\n", msg));
	FIfld_set_text(ds_form, DS_MSG_FIELD, 0, 0, (char *)msg, 0);
}

/******************************************************************************/

static void clear_msg_field()
{
	FRM_DBG(("clear_msg_field()\n"));
	FIfld_set_text(ds_form, DS_MSG_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** DS_SCHNAME FIELD ******************************************
*******************************************************************************/

static char *get_schname_field()
{
	static	 char	schname[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_schname_field()\n"));
	RISfrm_get_field(ds_form, DS_SCHNAME_FIELD, RIS_MAX_ID_SIZE, schname);
	return schname[0] ? schname : NULL;
}

/******************************************************************************/

static void process_schname_field()
{
	char		*schname;
	ris_schema_info	*schema;

	FRM_DBG(("process_schname_field()\n"));

	schname = get_schname_field();
	if (!RISfrm_field_changed(schname, initial_schname))
	{
		return;
	}
	schema = RISfrm_get_schema(schname, update_msg_field, clear_msg_field);
	if (schema == NULL)
	{
		if (schname)
		{
			sprintf(ds_msg->str, MSG(RISUTL_I_UNKNOWN_SCHEMA), schname);
		}
		schname = NULL;
	}

	if (RISfrm_sm_form_displayed())
	{
		RISfrm_update_sm_schemas_field(schname);
	}

	update_ds_form(schema);
}

/******************************************************************************/

static void update_schname_field(
	char	*schname)
{
	FRM_DBG(("update_schname_field(schname:<%s>)\n",schname));
	FIfld_set_text(ds_form, DS_SCHNAME_FIELD, 0, 0, schname, 0);
	strcpy(initial_schname, schname);
}

/******************************************************************************/

static void clear_schname_field()
{
	FRM_DBG(("clear_schname_field()\n"));
	FIfld_set_text(ds_form, DS_SCHNAME_FIELD, 0, 0, "", 0);
	strcpy(initial_schname, "");
}

/*******************************************************************************
******************** EXECUTE BUTTON ********************************************
*******************************************************************************/

static void process_execute(
	int		force)
{
	char			*cmd;
	char			*schname;
	char			drop_schema_command[128];
	ris_schema_info	*schema;

	FRM_DBG(("process_execute_button(force:%d)\n", force));

	cmd = drop_schema_command;

	if ((schname = get_schname_field()) == NULL)
	{
		ds_msg->label[ds_msg->count++] = DS_SCHNAME_TEXT;
		ds_msg->label[ds_msg->count++] = DS_SCHNAME_FIELD;
		strcpy(ds_msg->str, MSG(RISUTL_I_SCHNAME_MUST_BE_SPEC));
		FIfld_pos_cursor(ds_form, DS_SCHNAME_FIELD, 0, 0, 0, 0, 0, 0);
		return;
	}
	schema = RISfrm_get_schema(schname, update_msg_field, clear_msg_field);
	if (schema == NULL)
	{
		ds_msg->label[ds_msg->count++] = DS_SCHNAME_TEXT;
		ds_msg->label[ds_msg->count++] = DS_SCHNAME_FIELD;

		sprintf(ds_msg->str, MSG(RISUTL_I_UNKNOWN_SCHEMA), schname);
		FIfld_pos_cursor(ds_form, DS_SCHNAME_FIELD, 0, 0, 0, 0, 0, 0);
		return;
	}

	cmd += sprintf(cmd,"DROP SCHEMA %s", schname);

	if (force)
	{
		cmd += sprintf(cmd," FORCE");
	}

	FRM_DBG(("%s\n",drop_schema_command));

	if (RISfrm_user_exec_ds_form &&
		RISfrm_user_exec_ds_form(ds_form, drop_schema_command) == 0)
	{
			return;
	}

	sprintf(ds_msg->str, MSG(RISUTL_I_DROPPING_SCHEMA), schname);
	update_msg_field(ds_msg->str);

	RISfrm_execute_schema_command(schema->schname, schema->dbid, drop_schema_command);

	ds_msg->str[0] = 0;
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
	RISfrm_file_info_up_to_date = 0;

	clear_schname_field();

	sprintf(ds_msg->str,MSG(RISUTL_I_DROP_SCHEMA_SUCCESS), schname);

	if (RISfrm_sm_form_displayed())
	{
		RISfrm_update_schema_mgr();
	}
}

/******************************************************************************/

static void	process_execute_button()
{
	process_execute(0);
}

/******************************************************************************/

static void	process_force_button()
{
	process_execute(1);
}

/*******************************************************************************
******************** CANCEL_BUTTON *********************************************
*******************************************************************************/

static void process_cancel_button()
{
	FRM_DBG(("process_cancel_button()\n"));
	RISfrm_erase_ds_form();
	if (RISfrm_sd_form_displayed())
	{
		RISfrm_clear_sd_drop_schema_button();
	}
}

/*******************************************************************************
******************** RESET_BUTTON **********************************************
*******************************************************************************/

static void process_reset_button()
{
	FRM_DBG(("process_reset_button()\n"));
	RISfrm_clear_ds_form();
	if (RISfrm_sm_form_displayed())
	{
		RISfrm_update_sm_schemas_field(NULL);
	}
	DISPLAY_HELP_BUTTON(ds_form);
	RISfrm_call_user_init_ds_form();
}

/*******************************************************************************
******************** DS FORM ***************************************************
*******************************************************************************/

extern void RISfrm_process_ds_form(
	int	g_label)
{
	int	i;
	static	RISfrm_label_function	process_gadget[] = 
	{
		{	FI_CANCEL,			process_cancel_button	},
		{	FI_RESET,			process_reset_button	},
		{	FI_EXECUTE,			process_execute_button	},
		{	FORCE_BUTTON,		process_force_button	},
		{	DS_SCHNAME_FIELD,	process_schname_field	},
	};
	static	int						process_gadget_count =
		sizeof(process_gadget)/sizeof(RISfrm_label_function);

	FRM_DBG(("RISfrm_process_ds_form(g_label:%d)\n", g_label));

	VALID_FORM_CHECK(ds_form);

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

extern void RISfrm_call_user_init_ds_form()
{
	FRM_DBG(("RISfrm_call_user_init_ds_form()\n"));

	if (RISfrm_user_init_ds_form)
	{
		FRM_DBG(("calling RISfrm_user_init_ds_form()\n"));
		RISfrm_user_init_ds_form(ds_form);
	}
}

/******************************************************************************/

extern int RISfrm_display_ds_form(
	int	called_by_user)
{
	int	sts;

	FRM_DBG(("RISfrm_display_ds_form(called_by_user:%d)\n", called_by_user));

	if (!RISfrm_initialized)
	{
		RISfrm_form_errhandle(RISUTL_E_FORMS_NOT_INITIALIZED, 0);
		return RIS_forms_error.error;
	}

	if (!ds_form)
	{
		sts = FIf_new(DS_FORM, DS_FORM_FILE, RISfrm_notification_routine,
			&ds_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_CREATE_DS_FORM, sts);
			return RIS_forms_error.error;
		}
#if defined(WIN32)
		FIf_SetDefaultButton(ds_form, FI_EXECUTE);
		FIg_set_text(ds_form, FI_CANCEL, RIScom_umsg(RISUTL_I_CLOSE));
		FIg_set_text(ds_form, FORCE_BUTTON, RIScom_umsg(RISUTL_I_FORCE));
#endif
	}

	if (!RISfrm_ds_form_displayed())
	{
		ds_msg->str[0] = 0;
		ds_msg->count = 0;
		ds_msg->msg_fld_label = DS_MSG_FIELD;
		ds_msg->fp = ds_form;

		DISPLAY_HELP_BUTTON(ds_form);

		if (called_by_user) RISfrm_call_user_init_ds_form();

		sts = FIf_display (ds_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_DISPLAY_DS_FORM, sts);
			return RIS_forms_error.error;
		}
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/******************************************************************************/

static void update_ds_form(
	ris_schema_info	*schemap)
{
	FRM_DBG(("update_ds_form(schemap:0x%x)\n", schemap));

	/*
	**	This routine is called internally when ever the schname changes.
	**	It should update every thing on the form that needs updating
	**	except the schname_field()
	*/

	/*
	** Nothing to do, just being consistant with other forms
	*/
}

/******************************************************************************/

extern void RISfrm_update_ds_form(
	ris_schema_info	*schemap)
{
	FRM_DBG(("RISfrm_update_ds_form(schemap:0x%x)\n",schemap));

	/*
	**	This routine is called by other forms to update this form.  It should
	**	update the schname field, then call the internal update function.
	*/

	VALID_FORM_CHECK(ds_form);

	if (schemap)
	{
		update_schname_field(schemap->schname);
	}
	else
	{
		clear_schname_field();
	}

	update_ds_form(schemap);
}

/******************************************************************************/

extern void RISfrm_clear_ds_form()
{
	FRM_DBG(("RISfrm_clear_ds_form()\n"));

	VALID_FORM_CHECK(ds_form);

	clear_schname_field();
}

/******************************************************************************/

extern int RISfrm_ds_form_displayed()
{
	int	form_displayed;

	FRM_DBG(("RISfrm_ds_form_displayed()\n"));
	if (!ds_form)
	{
		return(0);
	}
	FIf_is_displayed(ds_form, &form_displayed);
	return(form_displayed);
}

/******************************************************************************/

extern int RISfrm_erase_ds_form()
{
	int	sts;

	FRM_DBG(("RISfrm_erase_ds_form()\n"));

	if (RISfrm_ds_form_displayed())
	{
		sts = FIf_erase(ds_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_ERASE_DS_FORM, sts);
			return RIS_forms_error.error;
		}
		RISfrm_clear_ds_form();
		if (RISfrm_sd_form_displayed())
		{
			RISfrm_clear_sd_drop_schema_button();
		}
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/*******************************************************************************
************** USER FUNCTIONS **************************************************
*******************************************************************************/

extern int RISAPI RISXfrm_drop_schema_form_displayed()
{
	return RISfrm_ds_form_displayed();
}

/******************************************************************************/

extern int RISAPI RISXfrm_display_drop_schema_form()
{
	return RISfrm_display_ds_form(CALLED_BY_USER);
}

/******************************************************************************/

extern int RISAPI RISXfrm_erase_drop_schema_form()
{
	return RISfrm_erase_ds_form();
}

/******************************************************************************/
