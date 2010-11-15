/* Do not alter this SPC information: $Revision: 1.4.27.1 $ */
/*
**	NAME:							frmschfl.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					2/91
**	ABSTRACT:
**		The code to process the schema file form.
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
#include "net.h"

/*
**	FUNCTION PROTOTYPES
*/
#define frmschfl_c
#include "comdebug.prt"
#include "comumsg.prt"
#include "frmerror.prt"
#include "frmexec.prt"
#include "frmmsg.prt"
#include "frmntfy.prt"
#include "frmschfl.prt"
#include "frmschmg.prt"
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
#define ALL_GROUPS				-1
#define NO_ACTION				ALL_GROUPS

#define SHOW_LOCATION			0
#define LOCATE					1
#define CHECKSUM				2
#define ACTION_COUNT			3
#define VALID_ACTION(action)	((action) >= 0 && (action) < ACTION_COUNT)

#define TYPE_COUNT				4

/*
**	VARIABLES
*/
static	 Form		sf_form = 0;
static	RISfrm_msg	*sf_msg = &RISfrm_msgs[SF_FORM_MSG];

static struct
{
	int		type;
	int		label;
	char	letter;
} type_check_info[TYPE_COUNT] = 
{
	{	SHMEM,	SF_LOCAL_CHECK, 'M'	},
	{	TCP,	SF_TCP_CHECK,	'T'	},
	{	XNS,	SF_XNS_CHECK,	'X'	},
	{	DNP,	SF_DNP_CHECK,	'D'	},
};

static int action_button[ACTION_COUNT] =
{
	SF_SHOW_LOCATION_BUTTON,
	SF_LOCATE_BUTTON,
	SF_CHECKSUM_BUTTON,
};

static	 char	save_nodename[RIS_MAX_NODE_SIZE] = "";
static	 char	save_username[RIS_MAX_ID_SIZE] = "";
static	 char	save_password[RIS_MAX_ID_SIZE] = "";

/*
**	FUNCTIONS
*/

/*******************************************************************************
************** SF_MSG_FIELD ****************************************************
*******************************************************************************/

static void update_msg_field(
	const char	*msg)
{
	FRM_DBG(("update_msg_field(msg:<%s>)\n", msg));
	FIfld_set_text(sf_form, SF_MSG_FIELD, 0, 0, (char *)msg, 0);
}

/******************************************************************************/

static void clear_msg_field()
{
	FRM_DBG(("clear_msg_field()\n"));
	FIfld_set_text(sf_form, SF_MSG_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** SF_FILENAME FIELD *****************************************
*******************************************************************************/

static char *get_filename_field()
{
	static	 char	filename[RIS_MAX_PATH_SIZE];

	FRM_DBG(("get_filename_field()\n"));

	RISfrm_get_field(sf_form, SF_FILENAME_FIELD, RIS_MAX_PATH_SIZE, filename);
	if (filename[0]) return(filename);
	return(NULL);
}

/******************************************************************************/

static void update_filename_field(
	char	*filename)
{
	FRM_DBG(("update_filename_field(filename:<%s>)\n",filename));
	FIfld_set_text(sf_form, SF_FILENAME_FIELD, 0, 0, filename, 0);
}

/******************************************************************************/

static void clear_filename_field()
{
	FRM_DBG(("clear_filename_field()\n"));
	FIfld_set_text(sf_form, SF_FILENAME_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** SF_NODENAME FIELD *****************************************
*******************************************************************************/

static char *get_nodename_field()
{
	static	 char	nodename[RIS_MAX_NODE_SIZE];

	FRM_DBG(("get_nodename_field()\n"));

	RISfrm_get_field(sf_form, SF_NODENAME_FIELD, RIS_MAX_NODE_SIZE, nodename);
	if (nodename[0]) return(nodename);
	return(NULL);
}

/******************************************************************************/

static void update_nodename_field(
	char	*nodename)
{
	FRM_DBG(("update_nodename_field(nodename:<%s>)\n",nodename));
	FIfld_set_text(sf_form, SF_NODENAME_FIELD, 0, 0, nodename, 0);
}

/******************************************************************************/

static void clear_nodename_field()
{
	FRM_DBG(("clear_nodename_field()\n"));
	FIfld_set_text(sf_form, SF_NODENAME_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** SF_USERNAME FIELD *****************************************
*******************************************************************************/

static char *get_username_field()
{
	static	 char	username[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_username_field()\n"));

	RISfrm_get_field(sf_form, SF_USERNAME_FIELD, RIS_MAX_ID_SIZE, username);
	if (username[0]) return(username);
	return(NULL);
}

/******************************************************************************/

static void update_username_field(
	char	*username)
{
	FRM_DBG(("update_username_field(username:<%s>)\n",username));
	FIfld_set_text(sf_form, SF_USERNAME_FIELD, 0, 0, username, 0);
}

/******************************************************************************/

static void clear_username_field()
{
	FRM_DBG(("clear_username_field()\n"));
	FIfld_set_text(sf_form, SF_USERNAME_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** SF_PASSWORD FIELD *****************************************
*******************************************************************************/

static char *get_password_field()
{
	static	 char	password[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_password_field()\n"));

	RISfrm_get_field(sf_form, SF_PASSWORD_FIELD, RIS_MAX_ID_SIZE, password);
	if (password[0]) return(password);
	return(NULL);
}

/******************************************************************************/

static void clear_password_field()
{
	FRM_DBG(("clear_password_field()\n"));
	FIfld_set_text(sf_form, SF_PASSWORD_FIELD, 0, 0, "", 0);
}

/******************************************************************************/

static void update_password_field(
	char	*password)
{
	FRM_DBG(("update_password_field()\n"));
	FIfld_set_text(sf_form, SF_PASSWORD_FIELD, 0, 0, password, 0);
}

/******************************************************************************/

static void process_password_toggle()
{
	FRM_DBG(("process_password_toggle()\n"));
	RISfrm_set_passwd_echo(sf_form,SF_PASSWORD_TOGGLE,SF_PASSWORD_FIELD);
}

/*******************************************************************************
******************** CT_TYPE_CHECKS ********************************************
*******************************************************************************/

static int get_type_check()
{
	int	i;
	int	state;

	FRM_DBG(("get_type_check()\n"));

	for (i = 0; i < TYPE_COUNT; i++)
	{
		FIg_get_state(sf_form, type_check_info[i].label, &state);
		if (state) return type_check_info[i].type;
	}

	return RIS_UNKNOWN_TYPE;
}

/******************************************************************************/

static char get_type_letter(
	int type)
{
	int	i;

	FRM_DBG(("char get_type_letter(type:%d)\n",type));

	for (i = 0; i < TYPE_COUNT; i++)
	{
		if (type == type_check_info[i].type)
		{
			return type_check_info[i].letter;
		}
	}
	return (char)0;
}

/******************************************************************************/

static void process_type_check()
{
	int	type;
	char *ptr;

	FRM_DBG(("process_type_check()\n"));

	type = get_type_check();
	switch (type)
	{
		case SHMEM:
			if ((ptr = get_nodename_field()) != NULL)
			{
				strcpy(save_nodename, ptr);
				clear_nodename_field();
			}

			if ((ptr = get_username_field()) != NULL)
			{
				strcpy(save_username, ptr);
				clear_username_field();
			}

			if ((ptr = get_password_field()) != NULL)
			{
				strcpy(save_password, ptr);
				clear_password_field();
			}

			FIg_enable(sf_form, SF_FILENAME_FIELD);
			FIg_disable(sf_form, SF_NODENAME_FIELD);
			FIg_disable(sf_form, SF_USERNAME_FIELD);
			FIg_disable(sf_form, SF_PASSWORD_FIELD);
			FIg_disable(sf_form, SF_PASSWORD_TOGGLE);
		break;

		case TCP:
		case XNS:
		case DNP:
			FIg_enable(sf_form, SF_LOCATE_GROUP);
			if (save_nodename[0])
			{
				update_nodename_field(save_nodename);
				save_nodename[0] = '\0';
			}
			if (save_username[0])
			{
				update_username_field(save_username);
				save_username[0] = '\0';
			}
			if (save_password[0])
			{
				update_password_field(save_password);
				save_password[0] = '\0';
			}
		break;

		default:
			FIg_disable(sf_form, SF_LOCATE_GROUP);
		break;
	}
}

/******************************************************************************/

static void update_type_check(
	char	letter)
{
	int	i;

	FRM_DBG(("update_type_field(letter:%c)\n",letter));

	for (i = 0; i < TYPE_COUNT; i++)
	{
		if (letter == type_check_info[i].letter)
			FIg_set_state(sf_form, type_check_info[i].label, 1);
		else
			FIg_set_state(sf_form, type_check_info[i].label, 0);
	}
}

/******************************************************************************/

static void clear_type_check()
{
	FRM_DBG(("clear_type_check()\n"));
	update_type_check(RIS_UNKNOWN_TYPE);
}

/*******************************************************************************
************** CHECK_GROUP *****************************************************
*******************************************************************************/

static void enable_check_group()
{
	FRM_DBG(("enable_check_group()\n"));
	FIg_enable(sf_form, SF_CHECK_GROUP);
}

static void disable_check_group()
{
	FRM_DBG(("disable_check_group()\n"));
	FIg_disable(sf_form, SF_CHECK_GROUP);
}

/*******************************************************************************
************** SF_SHOW_LOCATION_BUTTON *****************************************
*******************************************************************************/

static void process_show_location_button()
{
	FRM_DBG(("process_show_location_button()\n"));
	disable_check_group();
	disable_locate_group();
	update_locate_group();
}

/******************************************************************************/

static void clear_show_location_button()
{
	FRM_DBG(("clear_show_location_button()\n"));
	FIg_set_state(sf_form, SF_SHOW_LOCATION_BUTTON, 0);
}

/*******************************************************************************
************** SF_LOCATE_BUTTON ***********************************************
*******************************************************************************/

static void process_locate_button()
{
	FRM_DBG(("process_locate_button()\n"));
	enable_check_group();
	enable_locate_group();

#if defined(WIN32)
	if (RISget_platform() == IS_WIN32S)
	{
		FIg_disable(sf_form, SF_XNS_CHECK);
		FIg_disable(sf_form, SF_DNP_CHECK);
		update_type_check('T');
		FIg_enable(sf_form, SF_LOCATE_GROUP);
	}
#endif
}

/******************************************************************************/

static void clear_locate_button()
{
	FRM_DBG(("clear_locate_button()\n"));
	FIg_set_state(sf_form, SF_LOCATE_BUTTON, 0);
}

/*******************************************************************************
************** SF_CHECKSUM_BUTTON **********************************************
*******************************************************************************/

static void process_checksum_button()
{
	FRM_DBG(("process_checksum_button()\n"));
	disable_check_group();
	disable_locate_group();
	clear_type_check();
	clear_locate_group();

#if defined(unix)
	strcpy(sf_msg->str, MSG(RISUTL_I_SELECT_CHECKSUM_BUTTON));
#elif defined(WIN32)
	strcpy(sf_msg->str, MSG(RISUTL_I_SELECT_APPLY_CHECKSUM));
#else
	ERROR -- NO CODE
#endif
}

/******************************************************************************/

static void clear_checksum_button()
{
	FRM_DBG(("clear_checksum_button()\n"));
	FIg_set_state(sf_form, SF_CHECKSUM_BUTTON, 0);
}

/*******************************************************************************
******************** LOCATE_GROUP **********************************************
*******************************************************************************/

static void enable_locate_group()
{
	int type;
	FRM_DBG(("enable_locate_group()\n"));

	type = get_type_check();

	switch (type)
	{
		case SHMEM:
			FIg_enable(sf_form, SF_FILENAME_FIELD);
			FIg_disable(sf_form, SF_NODENAME_FIELD);
			FIg_disable(sf_form, SF_USERNAME_FIELD);
			FIg_disable(sf_form, SF_PASSWORD_FIELD);
			FIg_disable(sf_form, SF_PASSWORD_TOGGLE);
			break;

		case XNS:
		case TCP:
		case DNP:
			FIg_enable(sf_form, SF_LOCATE_GROUP);
			break;

		default:
			FIg_disable(sf_form, SF_LOCATE_GROUP);
	}
}

static void disable_locate_group()
{
	FRM_DBG(("disable_locate_group()\n"));

	FIg_disable(sf_form, SF_LOCATE_GROUP);
}

static void update_locate_group()
{
	schema_file_parms	parms;

	FRM_DBG(("update_locate_group()\n"));

	RISget_schema_file_location(&parms);	
	update_type_check(parms.protocol);
	clear_locate_group();
	update_filename_field(parms.filename);
	update_nodename_field(parms.address);
	update_username_field(parms.username);
}

/******************************************************************************/

static void clear_locate_group()
{
	FRM_DBG(("clear_locate_group()\n"));

	clear_filename_field();
	clear_nodename_field();
	clear_username_field();
	clear_password_field();

	save_nodename[0] = '\0';
	save_username[0] = '\0';
	save_password[0] = '\0';
}

/*******************************************************************************
******************** GROUP *****************************************************
*******************************************************************************/

static int get_action()
{
	int	i;
	int	state;

	FRM_DBG(("get_action()\n"));

	for (i = 0; i < ACTION_COUNT; i++)
	{
		FIg_get_state(sf_form, action_button[i], &state);
		if (state) return i;
	}
	return NO_ACTION;
}

/*******************************************************************************
******************** EXECUTE BUTTON ********************************************
*******************************************************************************/

static void process_execute_button()
{
	int					action;
	int					type;
	char				*ptr;
	schema_file_parms	parms;

	FRM_DBG(("process_execute_button()\n"));

	action = get_action();
	if (!VALID_ACTION(action))
	{
		strcpy(sf_msg->str, MSG(RISUTL_I_NO_ACTION_SELECT_ACTION));
		return;
	}

	switch (action)
	{
		case LOCATE:
			if ((type = get_type_check()) == RIS_UNKNOWN_TYPE)
			{
				sf_msg->label[sf_msg->count++] = SF_CHECK_GROUP;
				strcpy(sf_msg->str, MSG(RISUTL_I_PROT_MUST_BE_SPEC));
				return;
			}
			parms.protocol = get_type_letter(type);

			if ((ptr = get_filename_field()) == NULL)
			{
				sf_msg->label[sf_msg->count++] = SF_FILENAME_TEXT;
				sf_msg->label[sf_msg->count++] = SF_FILENAME_FIELD;
				strcpy(sf_msg->str, MSG(RISUTL_I_FILENAME_MUST_BE_SPEC));
				FIfld_pos_cursor(sf_form, SF_FILENAME_FIELD, 0, 0, 0, 0, 0, 0);
				return;
			}
			strcpy(parms.filename, ptr);

			if (type == SHMEM)
			{
				parms.address[0] = '\0';
				parms.username[0] = '\0';
				parms.password[0] = '\0';
			}
			else
			{
				if ((ptr = get_nodename_field()) == NULL)
				{
					sf_msg->label[sf_msg->count++] = SF_NODENAME_TEXT;
					sf_msg->label[sf_msg->count++] = SF_NODENAME_FIELD;
					strcpy(sf_msg->str,MSG(RISUTL_I_NODE_OR_ADDR_MUST_BE_SPEC));
					FIfld_pos_cursor(sf_form, SF_NODENAME_FIELD,0,0,0,0,0,0);
					return;
				}
				strcpy(parms.address, ptr);

				if ((ptr = get_username_field()) == NULL)
				{
					sf_msg->label[sf_msg->count++] = SF_USERNAME_TEXT;
					sf_msg->label[sf_msg->count++] = SF_USERNAME_FIELD;
					strcpy(sf_msg->str, MSG(RISUTL_I_USERNAME_MUST_BE_SPEC));
					FIfld_pos_cursor(sf_form, SF_USERNAME_FIELD,0,0,0,0,0,0);
					return;
				}
				strcpy(parms.username, ptr);

				if ((ptr = get_password_field()) == NULL &&
					type == TCP)
				{
					sf_msg->label[sf_msg->count++] = SF_TCP_CHECK;
					sf_msg->label[sf_msg->count++] = SF_PASSWORD_TEXT;
					sf_msg->label[sf_msg->count++] = SF_PASSWORD_FIELD;
					strcpy(sf_msg->str, MSG(RISUTL_I_TCP_PASSWD_MUST_BE_SPEC));
					FIfld_pos_cursor(sf_form, SF_PASSWORD_FIELD,0,0,0,0,0,0);
					return;
				}
				if (ptr)
				{
					strcpy(parms.password, ptr);
				}
				else
				{
					parms.password[0] = '\0';
				}
			}

			strcpy(sf_msg->str, MSG(RISUTL_I_CLOSING_SCHEMAS));
			update_msg_field(sf_msg->str);
			RISfrm_execute_command("close schema all");
			sf_msg->str[0] = 0;
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

			strcpy(sf_msg->str, MSG(RISUTL_I_LOCATING_SCHFILE));
			update_msg_field(sf_msg->str);
			RISlocate_schema_file(&parms);
			sf_msg->str[0] = 0;
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
			strcpy(sf_msg->str, MSG(RISUTL_I_LOCATE_SCHFILE_SUCCESS));

			RISfrm_file_info_up_to_date = 0;
			if (RISfrm_sm_form_displayed())
			{
				RISfrm_update_schema_mgr();
			}

			break;

		case CHECKSUM:
			strcpy(sf_msg->str, MSG(RISUTL_I_CALC_CHECKSUM));
			update_msg_field(sf_msg->str);
			RISrestore_schema_file_checksum();
			sf_msg->str[0] = 0;
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
			strcpy(sf_msg->str, MSG(RISUTL_I_CHECKSUM_SUCCESS));

			RISfrm_file_info_up_to_date = 0;
			if (RISfrm_sm_form_displayed())
			{
				RISfrm_update_schema_mgr();
			}
			break;
	}
}

/*******************************************************************************
******************** CANCEL_BUTTON *********************************************
*******************************************************************************/

static void process_cancel_button()
{
	FRM_DBG(("process_cancel_button()\n"));
	RISfrm_erase_sf_form();
	if (RISfrm_sm_form_displayed())
		RISfrm_clear_sm_schema_file_button();
}

/*******************************************************************************
******************** RESET_BUTTON **********************************************
*******************************************************************************/

static void process_reset_button()
{
	FRM_DBG(("process_reset_button()\n"));
	RISfrm_clear_sf_form();
	if (RISfrm_sm_form_displayed())
		RISfrm_update_sm_schemas_field(NULL);
	DISPLAY_HELP_BUTTON(sf_form);
	RISfrm_call_user_init_sf_form();
}

/*******************************************************************************
******************** DS FORM ***************************************************
*******************************************************************************/

extern void RISfrm_process_sf_form(
	int	g_label)
{
	int	i;

	static	RISfrm_label_function	process_gadget[] = 
	{
		{	FI_CANCEL,					process_cancel_button			},
		{	FI_RESET,					process_reset_button			},
		{	FI_EXECUTE,					process_execute_button			},
		{	SF_SHOW_LOCATION_BUTTON,	process_show_location_button	},
		{	SF_LOCATE_BUTTON,			process_locate_button			},
		{	SF_CHECKSUM_BUTTON,			process_checksum_button			},
		{	SF_LOCAL_CHECK,				process_type_check				},
		{	SF_XNS_CHECK,				process_type_check				},
		{	SF_TCP_CHECK,				process_type_check				},
		{	SF_DNP_CHECK,				process_type_check				},
		{	SF_PASSWORD_TOGGLE,			process_password_toggle 		},
	};
	static	int	process_gadget_count =
		sizeof(process_gadget)/sizeof(RISfrm_label_function);

	FRM_DBG(("RISfrm_process_sf_form(g_label:%d)\n", g_label));

	if (!sf_form) return;

	for (i = 0; i < process_gadget_count; i++)
	{
		if (process_gadget[i].label == g_label)
		{
			(process_gadget[i].function_ptr)();
			break;
		}
	}
	if (get_action() == NO_ACTION && !sf_msg->str[0])
		strcpy(sf_msg->str, MSG(RISUTL_I_SELECT_ACTION));
}

/******************************************************************************/

extern void RISfrm_call_user_init_sf_form()
{
	FRM_DBG(("RISfrm_call_user_init_sf_form()\n"));

	if (RISfrm_user_init_sf_form)
	{
		FRM_DBG(("calling RISfrm_user_init_sf_form()\n"));
		RISfrm_user_init_sf_form(sf_form);
	}
}

/******************************************************************************/

extern int RISfrm_display_sf_form(
	int	called_by_user)
{
	int	sts;

	FRM_DBG(("RISfrm_display_sf_form(called_by_user:%d)\n", called_by_user));

	if (!RISfrm_initialized)
	{
		RISfrm_form_errhandle(RISUTL_E_FORMS_NOT_INITIALIZED, 0);
		return RIS_forms_error.error;
	}

	if (!sf_form)
	{
		sts = FIf_new(SF_FORM, SF_FORM_FILE, RISfrm_notification_routine,
			&sf_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_CREATE_SF_FORM, sts);
			return RIS_forms_error.error;
		}
		FIfld_set_max_num_chars(sf_form, SF_FILENAME_FIELD, 0,
			RIS_MAX_PATH_SIZE - 1);
		FIfld_set_max_num_chars(sf_form, SF_USERNAME_FIELD, 0,
			RIS_MAX_ID_SIZE - 1);
		FIfld_set_max_num_chars(sf_form, SF_PASSWORD_FIELD, 0,
			RIS_MAX_ID_SIZE - 1);

#if defined(WIN32)
		FIf_SetDefaultButton(sf_form, FI_EXECUTE);
#endif
	}

	if (!RISfrm_sf_form_displayed())
	{
		sf_msg->str[0] = 0;
		sf_msg->count = 0;
		sf_msg->msg_fld_label = SF_MSG_FIELD;
		sf_msg->fp = sf_form;

		DISPLAY_HELP_BUTTON(sf_form);
		/*
		**	If called directly by a user, display the message,
		**	otherwise, RISfrm_notification will display the message
		*/
		strcpy(sf_msg->str, MSG(RISUTL_I_SELECT_ACTION));
		if (called_by_user) RISfrm_display_msgs(); 

		/*
		**	If called directly by a user, call their init routine,
		**	otherwise, the schema_mgr form will call it
		*/
		if (called_by_user) RISfrm_call_user_init_sf_form();

		sts = FIf_display (sf_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_DISPLAY_SF_FORM, sts);
			return RIS_forms_error.error;
		}
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/******************************************************************************/

extern void RISfrm_update_sf_form(
	ris_schema_info	*schemap)
{
	FRM_DBG(("RISfrm_update_sf_form(schemap:0x%x)\n",schemap));
	if (!sf_form) return;
	if (!schemap)
	{
		RISfrm_clear_sf_form();
		return;
	}
}

/******************************************************************************/

extern void RISfrm_clear_sf_form()
{
	FRM_DBG(("RISfrm_clear_sf_form()\n"));
	if (!sf_form) return;

	clear_show_location_button();
	clear_locate_button();
	clear_checksum_button();
	clear_locate_group();
	clear_type_check();

	disable_locate_group();
	disable_check_group();
}

/******************************************************************************/

extern int RISfrm_sf_form_displayed()
{
	int	form_displayed;

	FRM_DBG(("RISfrm_sf_form_displayed()\n"));
	if (!sf_form) return(0);
	FIf_is_displayed(sf_form, &form_displayed);
	return(form_displayed);
}

/******************************************************************************/

extern int RISfrm_erase_sf_form()
{
	int	sts;

	FRM_DBG(("RISfrm_erase_sf_form()\n"));

	if (RISfrm_sf_form_displayed())
	{
		sts = FIf_erase(sf_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_ERASE_SF_FORM, sts);
			return RIS_forms_error.error;
		}
		RISfrm_clear_sf_form();
		if (RISfrm_sm_form_displayed())
			RISfrm_clear_sm_schema_file_button();
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/*******************************************************************************
************** USER FUNCTIONS **************************************************
*******************************************************************************/

extern int RISAPI RISXfrm_schema_file_form_displayed()
{
	return RISfrm_sf_form_displayed();
}

/******************************************************************************/

extern int RISAPI RISXfrm_display_schema_file_form()
{
	return RISfrm_display_sf_form(CALLED_BY_USER);
}

/******************************************************************************/

extern int RISAPI RISXfrm_erase_schema_file_form()
{
	return RISfrm_erase_sf_form();
}

/******************************************************************************/
