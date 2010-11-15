/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							frmdb2ps.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					06/91
**	ABSTRACT:
**		The code to process the DB2 password form.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "forms.h"

/*
**	FUNCTION PROTOTYPES
*/
#define frmdb2ps_c
#include "comdebug.prt"
#include "comumsg.prt"
#include "frmschdf.prt"
#include "frmdb2ps.prt"
#include "frmerror.prt"
#include "frmexec.prt"
#include "frmfile.prt"
#include "frmntfy.prt"
#include "frmschmg.prt"
#include "frmutil.prt"
#include "fi.prt"
#include "sys.prt"

/*
**	DEFINES
*/

/*
**	VARIABLES
*/
static  Form			dp_form = 0;
static RISfrm_msg	*dp_msg = &RISfrm_msgs[DP_FORM_MSG];
static  char			initial_schname[RIS_MAX_ID_SIZE] = "";

/*
**	FUNCTIONS
*/

/*******************************************************************************
************** DP_MSG_FIELD ****************************************************
*******************************************************************************/

static void update_msg_field(
	const char	*msg)
{
	FRM_DBG(("update_msg_field(msg:<%s>)\n", msg));
	FIfld_set_text(dp_form, DP_MSG_FIELD, 0, 0, (char *)msg, 0);
}

/******************************************************************************/

static void clear_msg_field()
{
	FRM_DBG(("clear_msg_field()\n"));
	FIfld_set_text(dp_form, DP_MSG_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** SCHEMA_NAME_FIELD *****************************************
*******************************************************************************/

static char *get_schname_field()
{
	static	 char	schname[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_schname_field()\n"));

	RISfrm_get_field(dp_form, DP_SCHNAME_FIELD, RIS_MAX_ID_SIZE, schname);
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
			sprintf(dp_msg->str, MSG(RISUTL_I_UNKNOWN_SCHEMA), schname);
		}
	}

	if (RISfrm_sm_form_displayed())
	{
		RISfrm_update_sm_schemas_field(schname);
	}

	update_dp_form(schema);
}

/******************************************************************************/

static void update_schname_field(
	char	*schname)
{

	FRM_DBG(("update_schname_field(schname:<%s>)\n", schname));
	FIfld_set_text(dp_form, DP_SCHNAME_FIELD, 0, 0, schname, 0);
	strcpy(initial_schname, schname);
}

/******************************************************************************/

static void clear_schname_field()
{
	FRM_DBG(("clear_schname_field()\n"));
	FIfld_set_text(dp_form, DP_SCHNAME_FIELD, 0, 0, "", 0);
	strcpy(initial_schname, "");
}

/*******************************************************************************
******************** SCHEMA PASSWORD FIELD *************************************
*******************************************************************************/

static char *get_db2pass_field()
{
	static	 char	db2pass[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_db2pass_field()\n"));

	RISfrm_get_field(dp_form, DP_DB2PASS_FIELD, RIS_MAX_ID_SIZE, db2pass);
	return db2pass[0] ? db2pass : NULL;
}

/******************************************************************************/

static void clear_db2pass_field()
{
	FRM_DBG(("clear_db2pass_field()\n"));
	FIfld_set_text(dp_form, DP_DB2PASS_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** DP_DB2PASS_TOGGLE *****************************************
*******************************************************************************/

static void process_db2pass_toggle()
{
	FRM_DBG(("process_db2pass_toggle()\n"));
	RISfrm_set_passwd_echo(dp_form,DP_DB2PASS_TOGGLE,DP_DB2PASS_FIELD);
}

/*******************************************************************************
******************** NEW SCHEMA PASSWORD FIELD *********************************
*******************************************************************************/

static char *get_new_db2pass_field()
{
	static	 char	new_db2pass[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_new_db2pass_field()\n"));

	RISfrm_get_field(dp_form, DP_NEW_DB2PASS_FIELD, RIS_MAX_ID_SIZE,
		new_db2pass);
	return new_db2pass[0] ? new_db2pass : NULL;
}

/******************************************************************************/

static void clear_new_db2pass_field()
{
	FRM_DBG(("clear_new_db2pass_field()\n"));
	FIfld_set_text(dp_form, DP_NEW_DB2PASS_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** DP_NEW_DB2PASS_TOGGLE ************************************
*******************************************************************************/

static void process_new_db2pass_toggle()
{
	FRM_DBG(("process_new_db2pass_toggle()\n"));
	RISfrm_set_passwd_echo(dp_form,DP_NEW_DB2PASS_TOGGLE,DP_NEW_DB2PASS_FIELD);
}

/*******************************************************************************
******************** MODE_FIELD ************************************************
*******************************************************************************/

static char *get_lu62_mode_field()
{
	static	 char	mode[RIS_MAX_MODE_NAME_SIZE];

	FRM_DBG(("get_lu62_mode_field()\n"));

	RISfrm_get_field(dp_form, DP_MODE_FIELD, RIS_MAX_MODE_NAME_SIZE, mode);
	return  mode[0] ? mode : NULL;
}

/******************************************************************************/

static void display_lu62_mode_field()
{
	FRM_DBG(("display_lu62_mode_field()\n"));
	FIg_display(dp_form, DP_MODE_TEXT);
	FIg_display(dp_form, DP_MODE_FIELD);
}

/******************************************************************************/

static void erase_lu62_mode_field()
{
	FRM_DBG(("erase_lu62_mode_field()\n"));
	FIg_erase(dp_form, DP_MODE_TEXT);
	FIg_erase(dp_form, DP_MODE_FIELD);
}

/******************************************************************************/

static void clear_lu62_mode_field()
{
	FRM_DBG(("clear_lu62_mode_field()\n"));
	FIfld_set_text(dp_form, DP_MODE_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** EXECUTE BUTTON ********************************************
*******************************************************************************/

static void process_execute_button()
{
	char			*cmd;
	char			*schname;
	char			*db2pass;
	char			*new_db2pass;
	char			*mode;
	char			command[128];
	ris_schema_info	*schema;

	FRM_DBG(("process_execute_button()\n"));

	cmd = command;

	if ((schname = get_schname_field()) == NULL)
	{
		dp_msg->label[dp_msg->count++] = DP_SCHNAME_TEXT;
		dp_msg->label[dp_msg->count++] = DP_SCHNAME_FIELD;
		strcpy(dp_msg->str, MSG(RISUTL_I_SCHNAME_MUST_BE_SPEC));
		FIfld_pos_cursor(dp_form, DP_SCHNAME_FIELD, 0, 0, 0, 0, 0, 0);
		return;
	}
	schema = RISfrm_get_schema(schname, update_msg_field, clear_msg_field);
	if (schema == NULL)
	{
		dp_msg->label[dp_msg->count++] = DP_SCHNAME_TEXT;
		dp_msg->label[dp_msg->count++] = DP_SCHNAME_FIELD;
		sprintf(dp_msg->str, MSG(RISUTL_I_UNKNOWN_SCHEMA), schname);
		FIfld_pos_cursor(dp_form, DP_SCHNAME_FIELD, 0, 0, 0, 0, 0, 0);
		return;
	}

	if ((db2pass = get_db2pass_field()) == NULL)
	{
		dp_msg->label[dp_msg->count++] = DP_DB2PASS_TEXT;
		dp_msg->label[dp_msg->count++] = DP_DB2PASS_FIELD;
		dp_msg->label[dp_msg->count++] = DP_DB2PASS_TOGGLE;
		strcpy(dp_msg->str, MSG(RISUTL_I_OLD_PASSWD_MUST_BE_SPEC));
		FIfld_pos_cursor(dp_form, DP_DB2PASS_FIELD, 0, 0, 0, 0, 0, 0);
		return;
	}

	if ((new_db2pass = get_new_db2pass_field()) == NULL)
	{
		dp_msg->label[dp_msg->count++] = DP_NEW_DB2PASS_TEXT;
		dp_msg->label[dp_msg->count++] = DP_NEW_DB2PASS_FIELD;
		dp_msg->label[dp_msg->count++] = DP_NEW_DB2PASS_TOGGLE;
		strcpy(dp_msg->str, MSG(RISUTL_I_NEW_PASSWD_MUST_BE_SPEC));
		FIfld_pos_cursor(dp_form, DP_NEW_DB2PASS_FIELD, 0, 0, 0, 0, 0, 0);
		return;
	}

	cmd += sprintf(cmd,
		"ALTER SCHEMA %s MODIFY DB2 PASSWORD FROM %s TO %s",
		schname, db2pass, new_db2pass);

	if ((mode = get_lu62_mode_field()) != NULL)
	{
		cmd += sprintf(cmd, " USING MODE %s", mode);
	}

	if (RISfrm_user_exec_dp_form &&
		RISfrm_user_exec_dp_form(dp_form, command) == 0)
			return;

	sprintf(dp_msg->str,MSG(RISUTL_I_ALTERING_SCHEMA), schname);
	update_msg_field(dp_msg->str);
	RISfrm_execute_schema_command(schema->schname, schema->dbid, command);
	dp_msg->str[0] = 0;
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

	sprintf(dp_msg->str, MSG(RISUTL_I_ALTER_DB2_PASSWD_SUCCESS), schname);
}

/*******************************************************************************
******************** CANCEL_BUTTON *********************************************
*******************************************************************************/

static void process_cancel_button()
{
	FRM_DBG(("process_cancel_button()\n"));
	RISfrm_erase_dp_form();
	if (RISfrm_sd_form_displayed())
		RISfrm_clear_sd_db2pass_button();
}

/*******************************************************************************
******************** RESET_BUTTON **********************************************
*******************************************************************************/

static void process_reset_button()
{
	FRM_DBG(("process_reset_button()\n"));
	RISfrm_clear_dp_form();
	if (RISfrm_sm_form_displayed())
		RISfrm_update_sm_schemas_field(NULL);
	DISPLAY_HELP_BUTTON(dp_form);
	RISfrm_call_user_init_dp_form();
}

/*******************************************************************************
******************** SP FORM ***************************************************
*******************************************************************************/

extern void RISfrm_process_dp_form(
	int	g_label)
{
	int	i;
	static	RISfrm_label_function	process_gadget[] = 
	{
		{	FI_CANCEL,				process_cancel_button		},
		{	FI_RESET,				process_reset_button		},
		{	FI_EXECUTE,				process_execute_button		},
		{	DP_SCHNAME_FIELD,		process_schname_field		},
		{	DP_DB2PASS_TOGGLE,		process_db2pass_toggle		},
		{	DP_NEW_DB2PASS_TOGGLE,	process_new_db2pass_toggle	},
	};
	static	int	process_gadget_count =
		sizeof(process_gadget)/sizeof(RISfrm_label_function);

	FRM_DBG(("RISfrm_process_dp_form(g_label:%d)\n", g_label));

	VALID_FORM_CHECK(dp_form);

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

extern void RISfrm_call_user_init_dp_form()
{
	FRM_DBG(("RISfrm_call_user_init_dp_form()\n"));

	if (RISfrm_user_init_dp_form)
	{
		FRM_DBG(("calling RISfrm_user_init_dp_form()\n"));
		RISfrm_user_init_dp_form(dp_form);
	}
}

/******************************************************************************/

static void enable_form()
{
	FRM_DBG(("void enable_form()\n"));
	FIg_enable(dp_form, FI_EXECUTE);
#if defined(WIN32)
	FIf_SetDefaultButton(dp_form, FI_EXECUTE);
#endif
	FIg_enable(dp_form, DP_DISABLE_GROUP);
}

/******************************************************************************/

static void disable_form()
{
	FRM_DBG(("void disable_form()\n"));
	FIg_disable(dp_form, FI_EXECUTE);
#if defined(WIN32)
	FIf_SetDefaultButton(dp_form, FI_CANCEL);
#endif
	FIg_disable(dp_form, DP_DISABLE_GROUP);
}

/******************************************************************************/

extern int RISfrm_display_dp_form(
	int	called_by_user)
{
	int	sts;

	FRM_DBG(("RISfrm_display_dp_form(called_by_user:%d)\n", called_by_user));

	if (!RISfrm_initialized)
	{
		RISfrm_form_errhandle(RISUTL_E_FORMS_NOT_INITIALIZED, 0);
		return RIS_forms_error.error;
	}

	if (!dp_form)
	{
		sts = FIf_new(DP_FORM, DP_FORM_FILE, RISfrm_notification_routine,
			&dp_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_CREATE_DP_FORM, sts);
			return RIS_forms_error.error;
		}
#if defined(WIN32)
		FIf_SetDefaultButton(dp_form, FI_CANCEL);
		FIg_set_text(dp_form, FI_CANCEL, RIScom_umsg(RISUTL_I_CLOSE));
#endif
	}

	if (!RISfrm_dp_form_displayed())
	{
		dp_msg->str[0] = 0;
		dp_msg->count = 0;
		dp_msg->msg_fld_label = DP_MSG_FIELD;
		dp_msg->fp = dp_form;

		DISPLAY_HELP_BUTTON(dp_form);

		if (called_by_user) RISfrm_call_user_init_dp_form();

		sts = FIf_display (dp_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_DISPLAY_DP_FORM, sts);
			return RIS_forms_error.error;
		}
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/******************************************************************************/

static void update_dp_form(
	ris_schema_info	*schemap)
{
	/*
	**	This routine is called internally when ever the schname changes.
	**	It should update every thing on the form that needs updating
	**	except the schname_field()
	*/

	ris_db_info *dbp;

	FRM_DBG(("update_dp_form(schemap:0x%x)\n",schemap));

	if (schemap)
	{
		update_schname_field(schemap->schname);
		clear_db2pass_field();
		clear_new_db2pass_field();

		dbp = RISfrm_db_from_schema(schemap);
		if (dbp && dbp->dtype == 'D')
		{
			int ibmprot;

			ibmprot = RISfrm_get_frmibmprot_from_ibmprotname(
				dbp->info.db2.net_protocol);
			if (VALID_IBMPROT(ibmprot) && ibmprot == IBM_LU62_PROT)
			{
				display_lu62_mode_field();
			}
			else
			{
				erase_lu62_mode_field();
				clear_lu62_mode_field();
			}
			enable_form();
		}
		else
		{
			erase_lu62_mode_field();
			clear_lu62_mode_field();
			disable_form();
			sprintf(dp_msg->str, MSG(RISUTL_I_MODIFY_DB2_PASSWD_ONLY));
		}
	}
	else
	{
		clear_db2pass_field();
		clear_new_db2pass_field();
		clear_lu62_mode_field();
		erase_lu62_mode_field();
		disable_form();
	}
}

/******************************************************************************/

extern void RISfrm_update_dp_form(
	ris_schema_info	*schemap)
{
	/*
	**	This routine is called by other forms to update this form.  It should
	**	update the schname field, then call the internal update function.
	*/

	FRM_DBG(("RISfrm_update_dp_form(schemap:0x%x)\n",schemap));

	VALID_FORM_CHECK(dp_form);

	if (schemap)
	{
		update_schname_field(schemap->schname);
	}
	else
	{
		clear_schname_field();
	}

	update_dp_form(schemap);
}

/******************************************************************************/

extern void RISfrm_clear_dp_form()
{
	FRM_DBG(("RISfrm_clear_dp_form()\n"));

	VALID_FORM_CHECK(dp_form);

	clear_schname_field();
	clear_db2pass_field();
	clear_new_db2pass_field();
	clear_lu62_mode_field();
	erase_lu62_mode_field();
	disable_form();
}

/******************************************************************************/

extern int RISfrm_dp_form_displayed()
{
	int	form_displayed;

	FRM_DBG(("RISfrm_dp_form_displayed()\n"));
	if (!dp_form)
	{
		return(0);
	}
	FIf_is_displayed(dp_form, &form_displayed);
	return(form_displayed);
}

/******************************************************************************/

extern int RISfrm_erase_dp_form()
{
	int	sts;

	FRM_DBG(("RISfrm_erase_dp_form()\n"));

	if (RISfrm_dp_form_displayed())
	{
		sts = FIf_erase(dp_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_ERASE_DP_FORM, sts);
			return RIS_forms_error.error;
		}
		RISfrm_clear_dp_form();
		if (RISfrm_sd_form_displayed())
			RISfrm_clear_sd_db2pass_button();
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/*******************************************************************************
************** USER FUNCTIONS **************************************************
*******************************************************************************/

extern int RISAPI RISXfrm_db2pass_form_displayed()
{
	return RISfrm_dp_form_displayed();
}

/******************************************************************************/

extern int RISAPI RISXfrm_display_db2pass_form()
{
	return RISfrm_display_dp_form(CALLED_BY_USER);
}

/******************************************************************************/

extern int RISAPI RISXfrm_erase_db2pass_form()
{
	return RISfrm_erase_dp_form();
}

/******************************************************************************/
