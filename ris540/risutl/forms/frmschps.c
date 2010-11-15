/* Do not alter this SPC information: $Revision: 1.2.40.1 $ */
/*
**	NAME:							frmschps.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					06/91
**	ABSTRACT:
**		The code to process the schema password form.
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
#define frmschps_c
#include "comdebug.prt"
#include "comumsg.prt"
#include "frmschdf.prt"
#include "frmerror.prt"
#include "frmexec.prt"
#include "frmfile.prt"
#include "frmntfy.prt"
#include "frmschmg.prt"
#include "frmschps.prt"
#include "frmutil.prt"
#include "fi.prt"
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
static	 Form		sp_form = 0;
static	RISfrm_msg	*sp_msg = &RISfrm_msgs[SP_FORM_MSG];
static   char		initial_schname[RIS_MAX_ID_SIZE] = "";

/*
**	FUNCTIONS
*/

/*******************************************************************************
************** SP_MSG_FIELD ****************************************************
*******************************************************************************/

static void update_msg_field(
	const char	*msg)
{
	FRM_DBG(("update_msg_field(msg:<%s>)\n", msg));
	FIfld_set_text(sp_form, SP_MSG_FIELD, 0, 0, (char *)msg, 0);
}

/******************************************************************************/

static void clear_msg_field()
{
	FRM_DBG(("clear_msg_field()\n"));
	FIfld_set_text(sp_form, SP_MSG_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** SCHEMA_NAME_FIELD *****************************************
*******************************************************************************/

static char *get_schname_field()
{
	static	 char	schname[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_schname_field()\n"));

	RISfrm_get_field(sp_form, SP_SCHNAME_FIELD, RIS_MAX_ID_SIZE, schname);
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
			sprintf(sp_msg->str, MSG(RISUTL_I_UNKNOWN_SCHEMA), schname);
		}
		schname = NULL;
	}

	if (RISfrm_sm_form_displayed())
	{
		RISfrm_update_sm_schemas_field(schname);
	}

	update_sp_form(schema);
}

/******************************************************************************/

static void update_schname_field(
	char	*schname)
{
	FRM_DBG(("update_schname_field(schname:<%s>)\n", schname));
	FIfld_set_text(sp_form, SP_SCHNAME_FIELD, 0, 0, schname, 0);
	strcpy(initial_schname, schname);
}

/******************************************************************************/

static void clear_schname_field()
{
	FRM_DBG(("clear_schname_field()\n"));
	FIfld_set_text(sp_form, SP_SCHNAME_FIELD, 0, 0, "", 0);
	strcpy(initial_schname, "");
}

/*******************************************************************************
******************** NEW SCHEMA PASSWORD FIELD *********************************
*******************************************************************************/

static char *get_new_schpass_field()
{
	static	 char	new_schpass[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_new_schpass_field()\n"));

	RISfrm_get_field(sp_form, SP_NEW_SCHPASS_FIELD, RIS_MAX_ID_SIZE,
		new_schpass);
	return new_schpass[0] ? new_schpass : NULL;
}

/******************************************************************************/

static void clear_new_schpass_field()
{
	FRM_DBG(("clear_new_schpass_field()\n"));
	FIfld_set_text(sp_form, SP_NEW_SCHPASS_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** SP_NEW_SCHPASS_TOGGLE *************************************
*******************************************************************************/

static void process_new_schpass_toggle()
{
	FRM_DBG(("process_new_schpass_toggle()\n"));
	RISfrm_set_passwd_echo(sp_form,SP_NEW_SCHPASS_TOGGLE,SP_NEW_SCHPASS_FIELD);
}

/*******************************************************************************
******************** EXECUTE BUTTON ********************************************
*******************************************************************************/

static void process_execute_button()
{
	char	*ptr;
	char	*schname;
	char	*new_schpass;
	char	command[128];
	ris_schema_info	*schema;

	FRM_DBG(("process_execute_button()\n"));

	ptr = command;

	if ((schname = get_schname_field()) == NULL)
	{
		sp_msg->label[sp_msg->count++] = SP_SCHNAME_TEXT;
		sp_msg->label[sp_msg->count++] = SP_SCHNAME_FIELD;
		strcpy(sp_msg->str, MSG(RISUTL_I_SCHNAME_MUST_BE_SPEC));
		FIfld_pos_cursor(sp_form, SP_SCHNAME_FIELD, 0, 0, 0, 0, 0, 0);
		return;
	}
	schema = RISfrm_get_schema(schname, update_msg_field, clear_msg_field);
	if (schema == NULL)
	{
		sp_msg->label[sp_msg->count++] = SP_SCHNAME_TEXT;
		sp_msg->label[sp_msg->count++] = SP_SCHNAME_FIELD;
		sprintf(sp_msg->str, MSG(RISUTL_I_UNKNOWN_SCHEMA), schname);
		FIfld_pos_cursor(sp_form, SP_SCHNAME_FIELD, 0, 0, 0, 0, 0, 0);
		return;
	}

	ptr += sprintf(ptr,"ALTER SCHEMA %s", schname);

	if ((new_schpass = get_new_schpass_field()) == NULL)
	{
		ptr += sprintf(ptr," MODIFY SCHEMA PASSWORD");
	}
	else
	{
		ptr += sprintf(ptr," MODIFY SCHEMA PASSWORD %s", new_schpass);
	}

	if (RISfrm_user_exec_sp_form &&
		RISfrm_user_exec_sp_form(sp_form, command) == 0)
			return;

	sprintf(sp_msg->str,MSG(RISUTL_I_ALTERING_SCHEMA), schname);
	update_msg_field(sp_msg->str);
	RISfrm_execute_schema_command(schema->schname, schema->dbid, command);
	sp_msg->str[0] = 0;
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

	sprintf(sp_msg->str,MSG(RISUTL_I_ALTER_SCHEMA_SUCCESS), schname);
}

/*******************************************************************************
******************** CANCEL_BUTTON *********************************************
*******************************************************************************/

static void process_cancel_button()
{
	FRM_DBG(("process_cancel_button()\n"));
	RISfrm_erase_sp_form();
	if (RISfrm_sd_form_displayed())
	{
		RISfrm_clear_sd_schpass_button();
	}
}

/*******************************************************************************
******************** RESET_BUTTON **********************************************
*******************************************************************************/

static void process_reset_button()
{
	FRM_DBG(("process_reset_button()\n"));
	RISfrm_clear_sp_form();
	if (RISfrm_sm_form_displayed())
	{
		RISfrm_update_sm_schemas_field(NULL);
	}
	DISPLAY_HELP_BUTTON(sp_form);
	RISfrm_call_user_init_sp_form();
}

/*******************************************************************************
******************** SP FORM ***************************************************
*******************************************************************************/

extern void RISfrm_process_sp_form(
	int	g_label)
{
	int	i;
	static	RISfrm_label_function	process_gadget[] = 
	{
		{	FI_CANCEL,				process_cancel_button		},
		{	FI_RESET,				process_reset_button		},
		{	FI_EXECUTE,				process_execute_button		},
		{	SP_SCHNAME_FIELD,		process_schname_field		},
		{	SP_NEW_SCHPASS_TOGGLE,	process_new_schpass_toggle	},
	};
	static	int	process_gadget_count =
		sizeof(process_gadget)/sizeof(RISfrm_label_function);

	FRM_DBG(("RISfrm_process_sp_form(g_label:%d)\n", g_label));

	VALID_FORM_CHECK(sp_form);

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

extern void RISfrm_call_user_init_sp_form()
{
	FRM_DBG(("RISfrm_call_user_init_sp_form()\n"));

	if (RISfrm_user_init_sp_form)
	{
		FRM_DBG(("calling RISfrm_user_init_sp_form()\n"));
		RISfrm_user_init_sp_form(sp_form);
	}
}

/******************************************************************************/

extern int RISfrm_display_sp_form(
	int	called_by_user)
{
	int	sts;

	FRM_DBG(("RISfrm_display_sp_form(called_by_user:%d)\n", called_by_user));

	if (!RISfrm_initialized)
	{
		RISfrm_form_errhandle(RISUTL_E_FORMS_NOT_INITIALIZED, 0);
		return RIS_forms_error.error;
	}

	if (!sp_form)
	{
		sts = FIf_new(SP_FORM, SP_FORM_FILE, RISfrm_notification_routine,
			&sp_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_CREATE_SP_FORM, sts);
			return RIS_forms_error.error;
		}

#if defined(WIN32)
		FIf_SetDefaultButton(sp_form, FI_EXECUTE);
		FIg_set_text(sp_form, FI_CANCEL, RIScom_umsg(RISUTL_I_CLOSE));

#endif

		FIfld_set_max_num_chars(sp_form, SP_SCHNAME_FIELD, 0,
			RIS_MAX_ID_SIZE - 1);
		FIfld_set_max_num_chars(sp_form, SP_NEW_SCHPASS_FIELD, 0,
			RIS_MAX_ID_SIZE - 1);
	}

	if (!RISfrm_sp_form_displayed())
	{
		sp_msg->str[0] = 0;
		sp_msg->count = 0;
		sp_msg->msg_fld_label = SP_MSG_FIELD;
		sp_msg->fp = sp_form;

		DISPLAY_HELP_BUTTON(sp_form);

		if (called_by_user) RISfrm_call_user_init_sp_form();

		sts = FIf_display (sp_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_DISPLAY_SP_FORM, sts);
			return RIS_forms_error.error;
		}
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/******************************************************************************/

static void update_sp_form(
	ris_schema_info	*schemap)
{
	/*
	**	This routine is called internally when ever the schname changes.
	**	It should update every thing on the form that needs updating
	**	except the schname_field()
	*/

	FRM_DBG(("update_sp_form(schemap:0x%x)\n",schemap));
	clear_new_schpass_field();
}

/******************************************************************************/

extern void RISfrm_update_sp_form(
	ris_schema_info	*schemap)
{
	/*
	**	This routine is called by other forms to update this form.  It should
	**	update the schname field, then call the internal update function.
	*/
	FRM_DBG(("RISfrm_update_sp_form(schemap:0x%x)\n",schemap));

	VALID_FORM_CHECK(sp_form);

	if (schemap)
	{
		update_schname_field(schemap->schname);
	}
	else
	{
		clear_schname_field();
	}
	update_sp_form(schemap);
}

/******************************************************************************/

extern void RISfrm_clear_sp_form()
{
	FRM_DBG(("RISfrm_clear_sp_form()\n"));
	VALID_FORM_CHECK(sp_form);
	clear_schname_field();
	clear_new_schpass_field();
}

/******************************************************************************/

extern int RISfrm_sp_form_displayed()
{
	int	form_displayed;

	FRM_DBG(("RISfrm_sp_form_displayed()\n"));
	if (!sp_form)
	{
		return(0);
	}
	FIf_is_displayed(sp_form, &form_displayed);
	return(form_displayed);
}

/******************************************************************************/

extern int RISfrm_erase_sp_form()
{
	int	sts;

	FRM_DBG(("RISfrm_erase_sp_form()\n"));

	if (RISfrm_sp_form_displayed())
	{
		sts = FIf_erase(sp_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_ERASE_SP_FORM, sts);
			return RIS_forms_error.error;
		}
		RISfrm_clear_sp_form();
		if (RISfrm_sd_form_displayed())
			RISfrm_clear_sd_schpass_button();
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/*******************************************************************************
************** USER FUNCTIONS **************************************************
*******************************************************************************/

extern int RISAPI RISXfrm_schpass_form_displayed()
{
	return RISfrm_sp_form_displayed();
}

/******************************************************************************/

extern int RISAPI RISXfrm_display_schpass_form()
{
	return RISfrm_display_sp_form(CALLED_BY_USER);
}

/******************************************************************************/

extern int RISAPI RISXfrm_erase_schpass_form()
{
	return RISfrm_erase_sp_form();
}

/******************************************************************************/
