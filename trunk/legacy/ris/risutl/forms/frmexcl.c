/* Do not alter this SPC information: $Revision: 1.3.3.1 $ */
/*
**	NAME:							frmexcl.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					06/91
**	ABSTRACT:
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
#include "riscom.h"
#include "ris_err.h"

/*
**	FUNCTION PROTOTYPES
*/
#define frmexcl_c
#include "comdebug.prt"
#include "comumsg.prt"
#include "frmdadef.prt"
#include "frmerror.prt"
#include "frmexec.prt"
#include "frmexcl.prt"
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
#define TABLE		0
#define VIEW		1
#define INDEX		2

/*
**	VARIABLES
*/
char				exclude_command[10000];
static  Form			ex_form = 0;
static RISfrm_msg	*ex_msg = &RISfrm_msgs[EX_FORM_MSG];
static  char			initial_object_name[RIS_MAX_ID_SIZE] = "";

/*
**	FUNCTIONS
*/

/*******************************************************************************
************** EX_MSG_FIELD ****************************************************
*******************************************************************************/

static void update_msg_field(
	const char	*msg)
{
	FRM_DBG(("update_msg_field(msg:<%s>)\n", msg));
	FIfld_set_text(ex_form, EX_MSG_FIELD, 0, 0, (char *)msg, 0);
}

/******************************************************************************/

static void clear_msg_field()
{
	FRM_DBG(("clear_msg_field()\n"));
	FIfld_set_text(ex_form, EX_MSG_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** TEXT ******************************************************
*******************************************************************************/

static void update_text(
	void)
{
	char s[32];
	char typestr[32];

	FRM_DBG(("update_text()\n"));

	switch(get_type_rollthru())
	{
		case INDEX:
			strcpy(typestr, MSG(RISUTL_I_INDEX));
			break;

		case VIEW:
			strcpy(typestr, MSG(RISUTL_I_VIEW));
			break;

		case TABLE:
		default:
			strcpy(typestr, MSG(RISUTL_I_TABLE));
			break;
	}

	FIg_erase(ex_form, EX_OBJECT_TEXT);

	sprintf(s, MSG(RISUTL_I_S_NAME), typestr);
	FIg_set_text(ex_form, EX_OBJECT_TEXT, s);

	FIg_display(ex_form, EX_OBJECT_TEXT);
}

/*******************************************************************************
******************** TYPE ROLLTHRU *********************************************
*******************************************************************************/

static int get_type_rollthru()
{
	int row;
	int pos;

	FRM_DBG(("get_type_rollthru()\n"));
	FIfld_get_active_row(ex_form, EX_TYPE_ROLLTHRU, &row, &pos);
	return row;
}

/******************************************************************************/

static void update_type_rollthru(
	int type)
{
	FRM_DBG(("update_type_rollthru(type:%d)\n", type));

	FIfld_set_active_row(ex_form, IN_TYPE_ROLLTHRU, type, 0);
}

/******************************************************************************/

static void process_type_rollthru()
{
	int m1;
	char object_type;
	char *object_name;
	RISfrm_object *object;
	FRM_DBG(("process_type_rollthru()\n"));

	update_text();

	object_name = get_object_field();
	switch(get_type_rollthru())
	{
		case INDEX:
			object_type = INDEX_CHAR;
			m1 = RISUTL_I_UNKNOWN_INDEX;
			break;

		case VIEW:
			object_type = VIEW_CHAR;
			m1 = RISUTL_I_UNKNOWN_VIEW;
			break;

		case TABLE:
		default:
			object_type = TABLE_CHAR;
			m1 = RISUTL_I_UNKNOWN_TABLE;
			break;
	}

	object = RISfrm_get_object(object_name, RIS_NAME, object_type,
		update_msg_field, clear_msg_field);
	if (object == NULL)
	{
		if (object_name)
		{
			sprintf(ex_msg->str, MSG(m1), object_name);
		}
	}

	if (RISfrm_dd_form_displayed())
	{
		RISfrm_update_dd_objects_mcf(object);
	}

	update_ex_form(object);
}
	
/******************************************************************************/

static void clear_type_rollthru()
{
	FRM_DBG(("clear_type_rollthru()\n"));

	FIfld_set_active_row(ex_form, EX_TYPE_ROLLTHRU, TABLE, 0);
}

/*******************************************************************************
******************** EX_OBJECT_FIELD *******************************************
*******************************************************************************/

static char *get_object_field()
{
	static	 char	object[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_object_field()\n"));

	RISfrm_get_field(ex_form, EX_OBJECT_FIELD, RIS_MAX_ID_SIZE,
		object);
	return object[0] ? object : NULL;
}

/******************************************************************************/

static void process_object_field(
	void)
{
	int m1;
	char object_type;
	char *object_name;
	RISfrm_object *object;
	FRM_DBG(("process_object_field()\n"));

	object_name = get_object_field();
	if (!RISfrm_field_changed(object_name, initial_object_name))
	{
		return;
	}
	switch(get_type_rollthru())
	{
		case INDEX:
			object_type = INDEX_CHAR;
			m1 = RISUTL_I_UNKNOWN_INDEX;
			break;

		case VIEW:
			object_type = VIEW_CHAR;
			m1 = RISUTL_I_UNKNOWN_VIEW;
			break;

		case TABLE:
		default:
			object_type = TABLE_CHAR;
			m1 = RISUTL_I_UNKNOWN_TABLE;
			break;
	}

	object = RISfrm_get_object(object_name, RIS_NAME, object_type,
		update_msg_field, clear_msg_field);
	if (object == NULL)
	{
		if (object_name)
		{
			sprintf(ex_msg->str, MSG(m1), object_name);
		}
	}

	if (RISfrm_dd_form_displayed())
	{
		RISfrm_update_dd_objects_mcf(object);
	}

	update_ex_form(object);
}

/******************************************************************************/

static void update_object_field(
	char	*object)
{
	FRM_DBG(("update_object_field(object:<%s>)\n", object));
	FIfld_set_text(ex_form, EX_OBJECT_FIELD, 0, 0, object, 0);
	strcpy(initial_object_name, object);
}

/******************************************************************************/

static void clear_object_field()
{
	FRM_DBG(("clear_object_field()\n"));
	FIfld_set_text(ex_form, EX_OBJECT_FIELD, 0, 0, "", 0);
	strcpy(initial_object_name, "");
}


/*******************************************************************************
******************** EXECUTE BUTTON ********************************************
*******************************************************************************/

static void process_execute_button()
{
	int		m1;
	int		m2;
	int		m3;
	int		m4;
	char	*type;
	char	type_char;
	char	*obj_name;
	char	*cmd;
	char	schname[RIS_MAX_ID_SIZE];
	RISfrm_object *object;

	FRM_DBG(("process_execute_button()\n"));

	cmd = exclude_command;

	RISget_default_schema_name(schname);

	cmd += sprintf(cmd, "ALTER SCHEMA %s EXCLUDE ", schname);

	switch(get_type_rollthru())
	{
		case INDEX:
			type = "INDEX";
			type_char = INDEX_CHAR;
			m1 = RISUTL_I_INDEX_MUST_BE_SPEC;
			m2 = RISUTL_I_UNKNOWN_INDEX;
			m3 = RISUTL_I_EXCLUDING_INDEX;
			m4 = RISUTL_I_INDEX_EXCLUDED;
			break;

		case VIEW:
			type = "VIEW";
			type_char = VIEW_CHAR;
			m1 = RISUTL_I_VIEW_MUST_BE_SPEC;
			m2 = RISUTL_I_UNKNOWN_VIEW;
			m3 = RISUTL_I_EXCLUDING_VIEW;
			m4 = RISUTL_I_VIEW_EXCLUDED;
			break;

		case TABLE:
		default:
			type = "TABLE";
			type_char = TABLE_CHAR;
			m1 = RISUTL_I_TABLE_MUST_BE_SPEC;
			m2 = RISUTL_I_UNKNOWN_TABLE;
			m3 = RISUTL_I_EXCLUDING_TABLE;
			m4 = RISUTL_I_TABLE_EXCLUDED;
			break;
	}
	cmd += sprintf(cmd, "%s ", type);

	if ((obj_name = get_object_field()) == NULL)
	{
		strcpy(ex_msg->str, MSG(m1));
		ex_msg->label[ex_msg->count++] = EX_OBJECT_TEXT;
		ex_msg->label[ex_msg->count++] = EX_OBJECT_FIELD;
		FIfld_pos_cursor(ex_form, EX_OBJECT_FIELD, 0, 0, 0, 0, 0, 0);
		return;
	}
	object = RISfrm_get_object(obj_name, RIS_NAME, type_char,
		update_msg_field, clear_msg_field);
	if (object == NULL)
	{
		sprintf(ex_msg->str, MSG(m2), obj_name);
		ex_msg->label[ex_msg->count++] = EX_OBJECT_TEXT;
		ex_msg->label[ex_msg->count++] = EX_OBJECT_FIELD;
		FIfld_pos_cursor(ex_form, EX_OBJECT_FIELD, 0, 0, 0, 0, 0, 0);
		return;
	}

	cmd += sprintf(cmd, "%s", obj_name);

	FRM_DBG(("%s\n", exclude_command));

	if (RISfrm_user_exec_ex_form &&
		RISfrm_user_exec_ex_form(ex_form, exclude_command) == 0)
			return;

	sprintf(ex_msg->str, MSG(m3), obj_name);
	update_msg_field(ex_msg->str);
	RISfrm_execute_command(exclude_command);
	clear_msg_field();
	ex_msg->str[0] = '\0';

	if (SQLCODE)
	{
		RISfrm_form_errhandle(RISUTL_E_RIS_ERROR, 0);
		if (RISfrm_report_error() == 0) return;
		switch(SQLCODE)
		{
		}
		return;
	}

	sprintf(ex_msg->str, MSG(m4), obj_name);
	update_msg_field(ex_msg->str);

	RISfrm_object_list_up_to_date = 0;
	RISfrm_dbms_obj_list_up_to_date = 0;

	clear_object_field();
	if (RISfrm_dd_form_displayed())
	{
		RISfrm_load_dd_objects_mcf(schname);
	}
}

/*******************************************************************************
******************** CANCEL_BUTTON *********************************************
*******************************************************************************/

static void process_cancel_button()
{
	FRM_DBG(("process_cancel_button()\n"));
	RISfrm_erase_ex_form();
	if (RISfrm_dd_form_displayed())
	{
		RISfrm_clear_dd_exclude_button();
	}
}

/*******************************************************************************
******************** RESET_BUTTON **********************************************
*******************************************************************************/

static void process_reset_button()
{
	FRM_DBG(("process_reset_button()\n"));
	RISfrm_clear_ex_form();
	DISPLAY_HELP_BUTTON(ex_form);
	RISfrm_call_user_init_ex_form();
	clear_object_field();
}

/*******************************************************************************
******************** EX FORM ***************************************************
*******************************************************************************/

extern void RISfrm_disable_ex_form()
{
	FRM_DBG(("disable_ex_form()\n"));

	VALID_FORM_CHECK(ex_form);

	FIg_disable(ex_form, FI_RESET);
	FIg_disable(ex_form, FI_EXECUTE);
	FIg_disable(ex_form, EX_OBJECT_FIELD);
	FIg_disable(ex_form, EX_TYPE_ROLLTHRU);
}

/******************************************************************************/

extern void RISfrm_enable_ex_form()
{
	FRM_DBG(("enable_ex_form()\n"));

	VALID_FORM_CHECK(ex_form);

	FIg_enable(ex_form, FI_RESET);
	FIg_enable(ex_form, FI_EXECUTE);
	FIg_enable(ex_form, EX_TYPE_ROLLTHRU);
	FIg_enable(ex_form, EX_OBJECT_FIELD);
	/* kmreddy - Fix TR # 439503065 */
	FIf_set_start_seq(ex_form, EX_OBJECT_FIELD);
}

/******************************************************************************/

extern void RISfrm_process_ex_form(
	int	g_label)
{
	int	i;
	static	RISfrm_label_function	process_gadget[] = 
	{
		{	FI_CANCEL,				process_cancel_button		},
		{	FI_RESET,				process_reset_button		},
		{	FI_EXECUTE,				process_execute_button		},
		{	EX_TYPE_ROLLTHRU,		process_type_rollthru		}, 
		{	EX_OBJECT_FIELD,		process_object_field		}, 
	};
	static	int	process_gadget_count =
		sizeof(process_gadget)/sizeof(RISfrm_label_function);

	FRM_DBG(("RISfrm_process_ex_form(g_label:%d)\n", g_label));

	VALID_FORM_CHECK(ex_form);

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

extern void RISfrm_call_user_init_ex_form()
{
	FRM_DBG(("RISfrm_call_user_init_ex_form()\n"));

	if (RISfrm_user_init_ex_form)
	{
		FRM_DBG(("calling RISfrm_user_init_ex_form()\n"));
		RISfrm_user_init_ex_form(ex_form);
	}
}

/******************************************************************************/

extern int RISfrm_display_ex_form(
	int	called_by_user,
	int	disable_flag)
{
	int		sts;
	char	def_schname[RIS_MAX_ID_SIZE];

	FRM_DBG(("RISfrm_display_ex_form(called_by_user:%d disable_flag:%d)\n",
		called_by_user, disable_flag));

	if (!RISfrm_initialized)
	{
		RISfrm_form_errhandle(RISUTL_E_FORMS_NOT_INITIALIZED, 0);
		return RIS_forms_error.error;
	}

	if (!ex_form)
	{
		sts = FIf_new(EX_FORM, EX_FORM_FILE, RISfrm_notification_routine,
			&ex_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_CREATE_IC_FORM, sts);
			return RIS_forms_error.error;
		}
#if defined(WIN32)
		FIf_SetDefaultButton(ex_form, FI_EXECUTE);
		FIg_set_text(ex_form, FI_CANCEL, RIScom_umsg(RISUTL_I_CLOSE));

#endif
	}

	if (!RISfrm_ex_form_displayed())
	{
		ex_msg->str[0] = 0;
		ex_msg->count = 0;
		ex_msg->msg_fld_label = EX_MSG_FIELD;
		ex_msg->fp = ex_form;

		DISPLAY_HELP_BUTTON(ex_form);

		if (disable_flag)
		{
			RISfrm_disable_ex_form();
		}
		else
		{
			RISfrm_enable_ex_form();
		}

		if (called_by_user)
		{
			RISget_default_schema_name(def_schname);
			if (!def_schname[0])
			{
				RISfrm_form_errhandle(RISUTL_E_FORM_NO_SCHEMA, 0);
				return RIS_forms_error.error;
			}

			RISfrm_call_user_init_ex_form();
		}

		update_text();

		sts = FIf_display(ex_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_DISPLAY_IC_FORM, sts);
			return RIS_forms_error.error;
		}
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/******************************************************************************/

static void update_ex_form(
	RISfrm_object *object)
{
	/*
	**	This routine is called internally when ever the table_name changes.
	**	It should update every thing on the form that needs updating
	**	except the table_name_field()
	*/

	FRM_DBG(("update_ex_form(object:0x%x)\n", object));

	/*
	** Nothing to do, just being consistant with other forms
	*/

}

/******************************************************************************/

extern void RISfrm_update_ex_form(
	RISfrm_object *objectp)
{
	/*
	**	This routine is called by other forms to update this form.  It should
	**	update the table_name field, then call the internal update function.
	*/

	int type;

	FRM_DBG(("RISfrm_update_ex_form(objectp:0x%x)\n", objectp));

	VALID_FORM_CHECK(ex_form);

	if (!objectp)
	{
		clear_object_field();
	}
	else
	{
		update_object_field(objectp->name);
		switch(objectp->type)
		{
			case INDEX_CHAR: type = INDEX; break;
			case VIEW_CHAR: type = VIEW; break;
			default:
			case TABLE_CHAR: type = TABLE; break;
		}
		update_type_rollthru(type);
	}
	update_ex_form(objectp);
}

/******************************************************************************/

extern void RISfrm_clear_ex_form()
{
	FRM_DBG(("RISfrm_clear_ex_form()\n"));

	VALID_FORM_CHECK(ex_form);

	clear_type_rollthru();
	update_text();
	clear_object_field();
}

/*******************************************************************************
************** USER FUNCTIONS **************************************************
*******************************************************************************/

extern int RISfrm_ex_form_displayed()
{
	int	form_displayed;

	FRM_DBG(("RISfrm_ex_form_displayed()\n"));
	if (!ex_form)
	{
		return(0);
	}
	FIf_is_displayed(ex_form, &form_displayed);
	return(form_displayed);
}

/******************************************************************************/

extern int RISfrm_erase_ex_form()
{
	int	sts;

	FRM_DBG(("RISfrm_erase_ex_form()\n"));

	if (RISfrm_ex_form_displayed())
	{
		sts = FIf_erase(ex_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_ERASE_IC_FORM, sts);
			return RIS_forms_error.error;
		}
		RISfrm_clear_ex_form();

		if (RISfrm_dd_form_displayed())
		{
			RISfrm_clear_dd_exclude_button();
		}
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/*******************************************************************************
************** USER FUNCTIONS **************************************************
*******************************************************************************/

extern int RISAPI RISXfrm_exclude_form_displayed()
{
	return RISfrm_ex_form_displayed();
}

/******************************************************************************/

extern int RISAPI RISXfrm_display_exclude_form()
{
	return RISfrm_display_ex_form(CALLED_BY_USER, DISPLAY_ENABLED);
}

/******************************************************************************/

extern int RISAPI RISXfrm_erase_exclude_form()
{
	return RISfrm_erase_ex_form();
}

/******************************************************************************/
