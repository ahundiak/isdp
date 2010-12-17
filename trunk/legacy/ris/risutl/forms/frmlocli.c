/* Do not alter this SPC information: $Revision: 1.2.40.1 $ */
/*
**	NAME:							frmlocli.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					2/91
**	ABSTRACT:
**		The code to process the locate client form.
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
#define frmlocli_c
#include "comdebug.prt"
#include "comumsg.prt"
#include "fi.prt"
#include "frmerror.prt"
#include "frmmsg.prt"
#include "frmntfy.prt"
#include "frmlocli.prt"
#include "frmschmg.prt"
#include "frmutil.prt"
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
#define ACTION_COUNT			2
#define VALID_ACTION(action)	((action) >= 0 && (action) < ACTION_COUNT)

#define TYPE_COUNT				4

/*
**	VARIABLES
*/
static	 Form		lc_form = 0;
static	RISfrm_msg	*lc_msg = &RISfrm_msgs[LC_FORM_MSG];

static struct
{
	int		type;
	int		label;
	char	letter;
} type_check_info[TYPE_COUNT] = 
{
	{	SHMEM,	LC_LOCAL_CHECK, 'M'	},
	{	TCP,	LC_TCP_CHECK,	'T'	},
	{	XNS,	LC_XNS_CHECK,	'X'	},
	{	DNP,	LC_DNP_CHECK,	'D'	},
};

static int action_button[ACTION_COUNT] =
{
	LC_SHOW_LOCATION_BUTTON,
	LC_LOCATE_BUTTON,
};

static	 char	save_nodename[RIS_MAX_NODE_SIZE] = "";
static	 char	save_username[RIS_MAX_ID_SIZE] = "";
static	 char	save_password[RIS_MAX_ID_SIZE] = "";

/*
**	FUNCTIONS
*/

/*******************************************************************************
************** LC_MSG_FIELD ****************************************************
*******************************************************************************/

static void update_msg_field(
	const char	*msg)
{
	FRM_DBG(("update_msg_field(msg:<%s>)\n", msg));
	FIfld_set_text(lc_form, LC_MSG_FIELD, 0, 0, (char *)msg, 0);
}

/******************************************************************************/

static void clear_msg_field()
{
	FRM_DBG(("clear_msg_field()\n"));
	FIfld_set_text(lc_form, LC_MSG_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** LC_NODENAME FIELD *****************************************
*******************************************************************************/

static char *get_nodename_field()
{
	static	 char	nodename[RIS_MAX_NODE_SIZE];

	FRM_DBG(("get_nodename_field()\n"));

	RISfrm_get_field(lc_form, LC_NODENAME_FIELD, RIS_MAX_NODE_SIZE, nodename);
	if (nodename[0]) return(nodename);
	return(NULL);
}

/******************************************************************************/

static void update_nodename_field(
	char	*nodename)
{
	FRM_DBG(("update_nodename_field(nodename:<%s>)\n",nodename));
	FIfld_set_text(lc_form, LC_NODENAME_FIELD, 0, 0, nodename, 0);
}

/******************************************************************************/

static void clear_nodename_field()
{
	FRM_DBG(("clear_nodename_field()\n"));
	FIfld_set_text(lc_form, LC_NODENAME_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** LC_USERNAME FIELD *****************************************
*******************************************************************************/

static char *get_username_field()
{
	static	 char	username[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_username_field()\n"));

	RISfrm_get_field(lc_form, LC_USERNAME_FIELD, RIS_MAX_ID_SIZE, username);
	if (username[0]) return(username);
	return(NULL);
}

/******************************************************************************/

static void update_username_field(
	char	*username)
{
	FRM_DBG(("update_username_field(username:<%s>)\n",username));
	FIfld_set_text(lc_form, LC_USERNAME_FIELD, 0, 0, username, 0);
}

/******************************************************************************/

static void clear_username_field()
{
	FRM_DBG(("clear_username_field()\n"));
	FIfld_set_text(lc_form, LC_USERNAME_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** LC_PASSWORD FIELD *****************************************
*******************************************************************************/

static char *get_password_field()
{
	static	 char	password[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_password_field()\n"));

	RISfrm_get_field(lc_form, LC_PASSWORD_FIELD, RIS_MAX_ID_SIZE, password);
	if (password[0]) return(password);
	return(NULL);
}

/******************************************************************************/

static void clear_password_field()
{
	FRM_DBG(("clear_password_field()\n"));
	FIfld_set_text(lc_form, LC_PASSWORD_FIELD, 0, 0, "", 0);
}

/******************************************************************************/

static void update_password_field(
	char	*password)
{
	FRM_DBG(("update_password_field()\n"));
	FIfld_set_text(lc_form, LC_PASSWORD_FIELD, 0, 0, password, 0);
}

/******************************************************************************/

static void process_password_toggle()
{
	FRM_DBG(("process_password_toggle()\n"));
	RISfrm_set_passwd_echo(lc_form,LC_PASSWORD_TOGGLE,LC_PASSWORD_FIELD);
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
		FIg_get_state(lc_form, type_check_info[i].label, &state);
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
FRM_DBG(("process_type_check() type = %d\n",type));
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
			FIg_disable(lc_form, LC_NODENAME_FIELD);

			FIfld_pos_cursor(lc_form, LC_NODENAME_TEXT,0,0,0,0,0,0);
			FIg_disable(lc_form, LC_USERNAME_FIELD);
			FIg_disable(lc_form, LC_PASSWORD_FIELD);
			FIg_disable(lc_form, LC_PASSWORD_TOGGLE);
/*
			disable_locate_group();
*/
		break;

		case TCP:
		case XNS:
		case DNP:
			FIg_enable(lc_form, LC_LOCATE_GROUP);
			FIfld_pos_cursor(lc_form,LC_NODENAME_FIELD,0,0,0,0,0,0);

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
/*
			FIg_disable(lc_form, LC_LOCATE_GROUP);
*/
			disable_locate_group();
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
			FIg_set_state(lc_form, type_check_info[i].label, 1);
		else
			FIg_set_state(lc_form, type_check_info[i].label, 0);
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
	FIg_enable(lc_form, LC_CHECK_GROUP);
}

/******************************************************************************/

static void disable_check_group()
{
	FRM_DBG(("disable_check_group()\n"));
	FIg_disable(lc_form, LC_CHECK_GROUP);
}

/*******************************************************************************
************** VERSION_GROUP ***************************************************
*******************************************************************************/

static void enable_version_group()
{
	FRM_DBG(("enable_version_group()\n"));
	FIg_enable(lc_form, LC_VERSION_TOGGLE);
	FIg_enable(lc_form, LC_VERSION_GROUP);
}

/******************************************************************************/

static void disable_version_group()
{
	FRM_DBG(("disable_version_group()\n"));
	FIg_disable(lc_form, LC_VERSION_TOGGLE);
	FIg_disable(lc_form, LC_VERSION_GROUP);
}

/******************************************************************************/

static void clear_version_group()
{
	update_version_toggle(0);	
	FIg_erase(lc_form, LC_VERSION_GROUP);
}

/*******************************************************************************
************** LC_VERSION_TOGGLE ***********************************************
*******************************************************************************/

static int get_version_toggle()
{
	int state;

	FRM_DBG(("get_version_toggle()\n"));
	FIg_get_state(lc_form, LC_VERSION_TOGGLE, &state);
	return state;
}

/******************************************************************************/

static void process_version_toggle()
{
	if (get_version_toggle())
	{
		FIg_display(lc_form, LC_VERSION_GROUP);
	}
	else
	{
		FIg_erase(lc_form, LC_VERSION_GROUP);
	}
}

/******************************************************************************/

static void update_version_toggle(
	int state)
{
	FRM_DBG(("update_version_toggle(state:%d)\n", state));
	FIg_set_state(lc_form, LC_VERSION_TOGGLE, state);
}

/*******************************************************************************
************** LC_MAJOR_VERSION_FIELD ******************************************
*******************************************************************************/

static int get_major_version_field(
	short *version)
{
	int		return_sts = 0;
	char	s[8];

	RISfrm_get_field(lc_form, LC_MAJOR_VERSION_FIELD, 8, s);
	if (s[0])
	{
		*version = (short)atoi(s);
		return_sts = 1;
	}
	return return_sts;
}

/******************************************************************************/

static void update_major_version_field(
	short version)
{
	char s[8];

	FRM_DBG(("update_major_version_field(version:%d)\n", version));
	sprintf(s, "%h02d", version);
	FIfld_set_text(lc_form, LC_MAJOR_VERSION_FIELD, 0, 0, s, 0);
}

/*******************************************************************************
************** LC_FEATURE_VERSION_FIELD ****************************************
*******************************************************************************/

static int get_feature_version_field(
	short *version)
{
	int		return_sts = 0;
	char	s[8];

	RISfrm_get_field(lc_form, LC_FEATURE_VERSION_FIELD, 8, s);
	if (s[0])
	{
		*version = (short)atoi(s);
		return_sts = 1;
	}
	return return_sts;
}

/******************************************************************************/

static void update_feature_version_field(
	int	version)
{
	char s[8];

	FRM_DBG(("update_feature_version_field(version:%d)\n", version));
	sprintf(s, "%h02d", version);
	FIfld_set_text(lc_form, LC_FEATURE_VERSION_FIELD, 0, 0, s, 0);
}

/*******************************************************************************
************** LC_SHOW_LOCATION_BUTTON *****************************************
*******************************************************************************/

static void process_show_location_button()
{
	FRM_DBG(("process_show_location_button()\n"));
	disable_check_group();
	disable_locate_group();
	disable_version_group();
	update_location();
}

/******************************************************************************/

static void clear_show_location_button()
{
	FRM_DBG(("clear_show_location_button()\n"));
	FIg_set_state(lc_form, LC_SHOW_LOCATION_BUTTON, 0);
}

/*******************************************************************************
************** LC_LOCATE_BUTTON ***********************************************
*******************************************************************************/

static void process_locate_button()
{
	FRM_DBG(("process_locate_button()\n"));
	enable_check_group();
	enable_locate_group();
	enable_version_group();

#if defined(WIN32)
	if (RISget_platform() == IS_WIN32S)
	{
/*
		FIg_disable(lc_form, LC_LOCAL_CHECK);
		FIg_disable(lc_form, LC_XNS_CHECK);
		FIg_disable(lc_form, LC_DNP_CHECK);
*/
		update_type_check('T');
	}
#endif
	FIg_enable(lc_form, LC_LOCATE_GROUP);
	FIfld_pos_cursor(lc_form,LC_NODENAME_FIELD,0,0,0,0,0,0);
}

/******************************************************************************/

static void clear_locate_button()
{
	FRM_DBG(("clear_locate_button()\n"));
	FIg_set_state(lc_form, LC_LOCATE_BUTTON, 0);
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
			FIg_disable(lc_form, LC_NODENAME_FIELD);
			FIg_disable(lc_form, LC_USERNAME_FIELD);
			FIg_disable(lc_form, LC_PASSWORD_FIELD);
			FIg_disable(lc_form, LC_PASSWORD_TOGGLE);
			FIg_disable(lc_form, LC_VERSION_TOGGLE);
			FIg_disable(lc_form, LC_VERSION_GROUP);
			break;

		case XNS:
		case TCP:
		case DNP:
			FIg_enable(lc_form, LC_LOCATE_GROUP);
			break;

		default:
			FIg_disable(lc_form, LC_LOCATE_GROUP);
	}
}

/******************************************************************************/

static void disable_locate_group()
{
	FRM_DBG(("disable_locate_group()\n"));

	FIg_disable(lc_form, LC_LOCATE_GROUP);
}

/******************************************************************************/

static void update_location()
{
	client_parms	parms;

	FRM_DBG(("update_location()\n"));

	RISget_client_location(&parms);	
	if (SQLCODE)
	{
		RISfrm_form_errhandle(RISUTL_E_RIS_ERROR, 0);
		if (RISfrm_report_error() == 0) return;
	
		switch(SQLCODE)
		{
		}

		FIg_set_state(lc_form, LC_SHOW_LOCATION_BUTTON, 0);

		return;
	}

	clear_locate_group();
	clear_version_group();

	update_type_check(parms.protocol);
	update_nodename_field(parms.address);
	update_username_field(parms.username);
	if (parms.major != 0 || parms.feature != 0)
	{
		update_version_toggle(1);
		FIg_display(lc_form, LC_VERSION_GROUP);
		update_major_version_field(parms.major);
		update_feature_version_field(parms.feature);
	}
}

/******************************************************************************/

static void clear_locate_group()
{
	FRM_DBG(("clear_locate_group()\n"));

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
		FIg_get_state(lc_form, action_button[i], &state);
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
	client_parms	parms;

	FRM_DBG(("process_execute_button()\n"));

	action = get_action();
	if (!VALID_ACTION(action))
	{
		strcpy(lc_msg->str, MSG(RISUTL_I_NO_ACTION_SELECT_ACTION));
		return;
	}

	switch (action)
	{
		case LOCATE:
			if ((type = get_type_check()) == RIS_UNKNOWN_TYPE)
			{
				lc_msg->label[lc_msg->count++] = LC_CHECK_GROUP;
				strcpy(lc_msg->str, MSG(RISUTL_I_PROT_MUST_BE_SPEC));
				return;
			}
			parms.protocol = get_type_letter(type);

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
					lc_msg->label[lc_msg->count++] = LC_NODENAME_TEXT;
					lc_msg->label[lc_msg->count++] = LC_NODENAME_FIELD;
					strcpy(lc_msg->str,MSG(RISUTL_I_NODE_OR_ADDR_MUST_BE_SPEC));
					FIfld_pos_cursor(lc_form, LC_NODENAME_FIELD,0,0,0,0,0,0);
					return;
				}
				strcpy(parms.address, ptr);

				if ((ptr = get_username_field()) == NULL)
				{
					lc_msg->label[lc_msg->count++] = LC_USERNAME_TEXT;
					lc_msg->label[lc_msg->count++] = LC_USERNAME_FIELD;
					strcpy(lc_msg->str, MSG(RISUTL_I_USERNAME_MUST_BE_SPEC));
					FIfld_pos_cursor(lc_form, LC_USERNAME_FIELD,0,0,0,0,0,0);
					return;
				}
				strcpy(parms.username, ptr);

				if ((ptr = get_password_field()) == NULL)
				{
					parms.password[0] = '\0';
				}
				else
				{
					strcpy(parms.password, ptr);
				}
			}

			if (get_version_toggle())
			{
				if (!get_major_version_field(&parms.major) ||
					!get_feature_version_field(&parms.feature))
				{
					lc_msg->label[lc_msg->count++] = LC_VERSION_GROUP;
					lc_msg->label[lc_msg->count++] = LC_VERSION_TOGGLE;
					strcpy(lc_msg->str, MSG(RISUTL_I_NO_CLIENT_VERSION));
					return;
				}
			}
			else
			{
				parms.major = 0;
				parms.feature = 0;
			}

			strcpy(lc_msg->str, MSG(RISUTL_I_STOPPING_CLIENT));
			update_msg_field(lc_msg->str);
			RISstop_client();
			lc_msg->str[0] = 0;
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

			strcpy(lc_msg->str, MSG(RISUTL_I_LOCATING_CLIENT));
			update_msg_field(lc_msg->str);
			RISlocate_client(&parms);
			lc_msg->str[0] = 0;
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
			strcpy(lc_msg->str, MSG(RISUTL_I_LOCATE_CLIENT_SUCCESS));

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
	RISfrm_erase_lc_form();
	if (RISfrm_sm_form_displayed())
		RISfrm_clear_sm_locate_client_button();
}

/*******************************************************************************
******************** RESET_BUTTON **********************************************
*******************************************************************************/

static void process_reset_button()
{
	FRM_DBG(("process_reset_button()\n"));
	RISfrm_clear_lc_form();
	if (RISfrm_sm_form_displayed())
		RISfrm_update_sm_schemas_field(NULL);
	DISPLAY_HELP_BUTTON(lc_form);
	RISfrm_call_user_init_lc_form();
}

/*******************************************************************************
******************** DS FORM ***************************************************
*******************************************************************************/

extern void RISfrm_process_lc_form(
	int	g_label)
{
	int	i;

	static	RISfrm_label_function	process_gadget[] = 
	{
		{	FI_CANCEL,					process_cancel_button			},
		{	FI_RESET,					process_reset_button			},
		{	FI_EXECUTE,					process_execute_button			},
		{	LC_SHOW_LOCATION_BUTTON,	process_show_location_button	},
		{	LC_LOCATE_BUTTON,			process_locate_button			},
		{	LC_LOCAL_CHECK,				process_type_check				},
		{	LC_XNS_CHECK,				process_type_check				},
		{	LC_TCP_CHECK,				process_type_check				},
		{	LC_DNP_CHECK,				process_type_check				},
		{	LC_PASSWORD_TOGGLE,			process_password_toggle 		},
		{	LC_VERSION_TOGGLE,			process_version_toggle 		},
	};
	static	int	process_gadget_count =
		sizeof(process_gadget)/sizeof(RISfrm_label_function);

	FRM_DBG(("RISfrm_process_lc_form(g_label:%d)\n", g_label));

	if (!lc_form) return;

	for (i = 0; i < process_gadget_count; i++)
	{
		if (process_gadget[i].label == g_label)
		{
			(process_gadget[i].function_ptr)();
			break;
		}
	}
	if (get_action() == NO_ACTION && !lc_msg->str[0])
	{
		strcpy(lc_msg->str, MSG(RISUTL_I_SELECT_ACTION));
	}
}

/******************************************************************************/

extern void RISfrm_call_user_init_lc_form()
{
	FRM_DBG(("RISfrm_call_user_init_lc_form()\n"));

	if (RISfrm_user_init_lc_form)
	{
		FRM_DBG(("calling RISfrm_user_init_lc_form()\n"));
		RISfrm_user_init_lc_form(lc_form);
	}
}

/******************************************************************************/

extern int RISfrm_display_lc_form(
	int	called_by_user)
{
	int	sts;

	FRM_DBG(("RISfrm_display_lc_form(called_by_user:%d)\n", called_by_user));

	if (!RISfrm_initialized)
	{
		RISfrm_form_errhandle(RISUTL_E_FORMS_NOT_INITIALIZED, 0);
		return RIS_forms_error.error;
	}

	if (!lc_form)
	{
		sts = FIf_new(LC_FORM, LC_FORM_FILE, RISfrm_notification_routine,
			&lc_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_CREATE_LC_FORM, sts);
			return RIS_forms_error.error;
		}

#if defined(WIN32)
		FIf_SetDefaultButton(lc_form, FI_EXECUTE);
		FIg_set_text(lc_form, FI_CANCEL, RIScom_umsg(RISUTL_I_CLOSE));
#endif

		FIfld_set_max_num_chars(lc_form, LC_USERNAME_FIELD, 0,
			RIS_MAX_ID_SIZE - 1);
		FIfld_set_max_num_chars(lc_form, LC_PASSWORD_FIELD, 0,
			RIS_MAX_ID_SIZE - 1);
	}

	if (!RISfrm_lc_form_displayed())
	{
		lc_msg->str[0] = 0;
		lc_msg->count = 0;
		lc_msg->msg_fld_label = LC_MSG_FIELD;
		lc_msg->fp = lc_form;

		DISPLAY_HELP_BUTTON(lc_form);
		/*
		**	If called directly by a user, display the message,
		**	otherwise, RISfrm_notification will display the message
		*/
		strcpy(lc_msg->str, MSG(RISUTL_I_SELECT_ACTION));
		if (called_by_user)
		{
			RISfrm_display_msgs(); 
		}

		/*
		**	If called directly by a user, call their init routine,
		**	otherwise, the schema_mgr form will call it
		*/
		if (called_by_user) RISfrm_call_user_init_lc_form();

		sts = FIf_display (lc_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_DISPLAY_LC_FORM, sts);
			return RIS_forms_error.error;
		}
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/******************************************************************************/

extern void RISfrm_update_lc_form(
	ris_schema_info	*schemap)
{
	FRM_DBG(("RISfrm_update_lc_form(schemap:0x%x)\n",schemap));
	if (!lc_form) return;
	if (!schemap)
	{
		RISfrm_clear_lc_form();
		return;
	}
}

/******************************************************************************/

extern void RISfrm_clear_lc_form()
{
	FRM_DBG(("RISfrm_clear_lc_form()\n"));
	if (!lc_form) return;

	clear_show_location_button();
	clear_locate_button();
	clear_locate_group();
	clear_version_group();
	clear_type_check();

	disable_locate_group();
	disable_check_group();
}

/*******************************************************************************
************** USER FUNCTIONS **************************************************
*******************************************************************************/

extern int RISfrm_lc_form_displayed()
{
	int	form_displayed;

	FRM_DBG(("RISfrm_lc_form_displayed()\n"));
	if (!lc_form) return(0);
	FIf_is_displayed(lc_form, &form_displayed);
	return(form_displayed);
}

/******************************************************************************/

extern int RISfrm_erase_lc_form()
{
	int	sts;

	FRM_DBG(("RISfrm_erase_lc_form()\n"));

	if (RISfrm_lc_form_displayed())
	{
		sts = FIf_erase(lc_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_ERASE_LC_FORM, sts);
			return RIS_forms_error.error;
		}
		RISfrm_clear_lc_form();
		if (RISfrm_sm_form_displayed())
			RISfrm_clear_sm_locate_client_button();
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/*******************************************************************************
************** USER FUNCTIONS **************************************************
*******************************************************************************/

extern int RISAPI RISXfrm_locate_client_form_displayed()
{
	return RISfrm_lc_form_displayed();
}

/******************************************************************************/

extern int RISAPI RISXfrm_display_locate_client_form()
{
	return(RISfrm_display_lc_form(CALLED_BY_USER));
}

/******************************************************************************/

extern int RISAPI RISXfrm_erase_locate_client_form()
{
	return RISfrm_erase_lc_form();
}

/******************************************************************************/
