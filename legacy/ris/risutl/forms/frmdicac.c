/* Do not alter this SPC information: $Revision: 1.5.3.1 $ */
/*
**	NAME:						frmdicac.c
**	AUTHORS:					Linda Wang
**	CREATION DATE:				11/93
**	ABSTRACT:
**		Process the dictionary access form for grant/revoke schema.
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
#if defined(WIN32)
#include "ris_err.h"
#endif
/*
**	FUNCTION PROTOTYPES
*/
#define frmdicac_c
#include "comdebug.prt"
#include "comumsg.prt"
#include "fi.prt"
#include "frmacusr.prt"
#include "frmdbusr.prt"
#include "frmdicac.prt"
#include "frmerror.prt"
#include "frmexec.prt"
#include "frmfile.prt"
#include "frmntfy.prt"
#include "frmschdf.prt"
#include "frmschmg.prt"
#include "frmutil.prt"
#include "sys.prt"
#if defined (WIN32)
#include "fi_winnt.prt"
#endif

/*
**	DEFINES
*/
#define GRANT		0
#define REVOKE		1

/*
**	VARIABLES
*/
static	 Form		da_form = 0;
static	RISfrm_msg	*da_msg = &RISfrm_msgs[DA_FORM_MSG];

/*
**	FUNCTIONS
*/

/*******************************************************************************
************** DA_MSG_FIELD ****************************************************
*******************************************************************************/

static void update_msg_field(
	const char	*msg)
{
	FRM_DBG(("update_msg_field in frmdicac.c(msg:<%s>)\n", msg));
	FIfld_set_text(da_form, DA_MSG_FIELD, 0, 0, (char *)msg, 0);
}

/******************************************************************************/

static void clear_msg_field()
{
	FRM_DBG(("clear_msg_field()\n"));
	FIfld_set_text(da_form, DA_MSG_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** DA_SCHNAME FIELD ******************************************
*******************************************************************************/

extern  char *RISfrm_get_da_schname_field()
{
	static	 char	schname[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_schname_field()\n"));

	RISfrm_get_field(da_form, DA_SCHNAME_FIELD, RIS_MAX_ID_SIZE, schname);
	if (schname[0]) return(schname);
	return(NULL);
}

/******************************************************************************/

static void process_schname_field()
{
        char            *schname;
        ris_schema_info *schema;

        FRM_DBG(("process_schname_field()\n"));
        schname = RISfrm_get_da_schname_field();
        schema = RISfrm_get_schema(schname, update_msg_field, clear_msg_field);

        RISfrm_update_da_form(schema);
        if (RISfrm_sm_form_displayed())
                RISfrm_update_sm_schemas_field(schname);
}

/******************************************************************************/

static void update_schname_field(
	char	*schname)
{
	FRM_DBG(("update_schname_field(schname:<%s>)\n",schname));
	FIfld_set_text(da_form, DA_SCHNAME_FIELD, 0, 0, schname, 0);
}

/******************************************************************************/

static void clear_schname_field()
{
	FRM_DBG(("clear_schname_field()\n"));
	FIfld_set_text(da_form, DA_SCHNAME_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** ACTION TOGGLE* ********************************************
*******************************************************************************/

static int get_action_toggle()
{
	int state;
	FRM_DBG(("get_action_toggle() of frmdicac.c\n"));
	FIg_get_state(da_form, DA_ACTION_TOGGLE, &state);
	return state;
}
	
/*****************************************************************************/

static void update_action_toggle(
	int state)
{
	FRM_DBG(("update_action_toggle() of frmdicac.c\n"));
	FIg_set_state(da_form, DA_ACTION_TOGGLE, state);
}
	
/******************************************************************************/

static void clear_action_toggle()
{
	FRM_DBG(("clear_action_toggle() of frmdicac.c\n"));
	FIg_set_state(da_form, DA_ACTION_TOGGLE, 0);
}
/*******************************************************************************
******************** DA_SELECTED_USER_FIELD ************************************
*******************************************************************************/

static char *get_selected_user_field()
{
	static	 char	selected_user[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_selected_user_field()\n"));

	RISfrm_get_field(da_form, DA_SELECTED_USER_FIELD, RIS_MAX_ID_SIZE, selected_user);
	if (selected_user[0]) return(selected_user);
	return(NULL);
}

/******************************************************************************/

static void update_selected_user_field(
	char	*user)
{
	FRM_DBG(("update_selected_user_field(user:<%s>\n", user));
	FIfld_set_text(da_form, DA_SELECTED_USER_FIELD, 0,0, user,0);
}

/******************************************************************************/

static void clear_selected_user_field()
{
	FRM_DBG(("clear_selected_user_field()\n"));
	FIfld_set_text(da_form, DA_SELECTED_USER_FIELD, 0, 0, "", 0);

}

/*******************************************************************************
******************** USER_INPUT_GROUP ******************************************
*******************************************************************************/
/* NOTE: The user input group is:
		DA_ACTION_TOGGLE
		DA_SELECTED_USER_FIELD
*/
static void process_user_input_group()
{
	char	*user;
	int	select_mcf_id = 0;
	int	clear_mcf_id = 0;

	user = get_selected_user_field();
	switch(get_action_toggle())
	{
		case GRANT:
			select_mcf_id = DA_ALL_USERS_MCF;
			clear_mcf_id = DA_ACCESS_USERS_MCF;
			break;

		case REVOKE:
			select_mcf_id = DA_ACCESS_USERS_MCF;
			clear_mcf_id = DA_ALL_USERS_MCF;
			break;
	}

	select_user(select_mcf_id, user);
	select_user(clear_mcf_id, NULL);
}

/*******************************************************************************
************** USERS   *********************************************************
*******************************************************************************/

static void select_user(
        int                             mcf_id,
        char                    *user)
{
        int             row;
        int             r_pos;
        int             offset;
        int             sel_flag;
        int             num_rows;
        int             num_vis_rows;
        char    rowname[RIS_MAX_ID_SIZE];

        FRM_DBG(("select_user(mcf_id:%d user:<%s> )\n", mcf_id,
                user ? user : "NULL"));

        FIfld_get_num_rows(da_form, mcf_id, &num_rows);      
        FIfld_get_num_vis_rows(da_form, mcf_id, &num_vis_rows);

        for (row = 0; row < num_rows; row++)
        {
                FIfld_get_text(da_form, mcf_id, row, 0, RIS_MAX_ID_SIZE,
                        (unsigned char *)rowname, &sel_flag, &r_pos);

                if (user && user[0] && !strcmp(rowname,user))
                {
                        FIfld_set_select(da_form, mcf_id, row, 0, 1);
                        FIfld_get_row_offset(da_form, mcf_id, &offset);
                        if (row < offset || row >= offset + num_vis_rows)                       {
                                FIfld_set_active_row(da_form, mcf_id, row, 0);
                        }
                                continue;
                }
                if (sel_flag)
                {
                        FIfld_set_select(da_form, mcf_id, row, 0, 0);
                }
        }
}
/******************************************************************************/

static int valid_all_users(
        char *user)
{
        int             i;
        int             sts;

        FRM_DBG(("valid_all_users(user:<%s>)\n", user));

        sts = 0;
	if (RISfrm_dbms_users_cnt)
	{
        	for (i = 0; i < RISfrm_dbms_users_cnt; i++)
        	{                if ( !strcmp(user, RISfrm_dbms_users[i]->user))
                	{
                        	sts = 1;
                        	break;
                	}
        	}

	}
        return sts;
}

/******************************************************************************/

static int valid_access_users(
        char *user)
{
        int             i;
        int             sts;

        FRM_DBG(("valid_access_users(user:<%s>)\n", user));

        sts = 0;
        for (i = 0; i < RISfrm_access_users_cnt; i++)
        {                if ( !strcmp(user, RISfrm_access_users[i]->user))
                {
                        sts = 1;
                        break;
                }
        }

        return sts;
}


/*******************************************************************************
******************** EXECUTE BUTTON ********************************************
*******************************************************************************/

static void process_execute()
{
	int	action;
	int 	valid = 0;

	char	*cmd;
	char	*schname;
	char	*selected_user;
	char	action_command[128];

	FRM_DBG(("process_execute_button\n"));

	update_msg_field(da_msg->str);

	if ((schname = RISfrm_get_da_schname_field()) == NULL)
	{
		da_msg->label[da_msg->count++] = DA_SCHNAME_TEXT;
		da_msg->label[da_msg->count++] = DA_SCHNAME_FIELD;
		strcpy(da_msg->str, MSG(RISUTL_I_SCHNAME_MUST_BE_SPEC));
		FIfld_pos_cursor(da_form, DA_SCHNAME_FIELD,0,0,0,0,0,0);
		return;	
	}
	da_msg->str[0] = 0;
	clear_msg_field();

	if ((selected_user = get_selected_user_field()) == NULL)
	{
		da_msg->label[da_msg->count++] = DA_SELECTED_USER_TEXT;
		da_msg->label[da_msg->count++] = DA_SELECTED_USER_FIELD;
		strcpy(da_msg->str, MSG(RISUTL_I_NAME_MUST_BE_SPEC));
		FIfld_pos_cursor(da_form, DA_SELECTED_USER_FIELD, 0, 0, 0, 0, 0, 0);

		return;
	}

	action = get_action_toggle();

	switch(action)
	{
		case GRANT:
			valid = valid_all_users(selected_user);
			break;

		case REVOKE:
			valid = valid_access_users(selected_user);
			break;
	}
/*
	if (!valid)
	{
		strcpy(da_msg->str, MSG(RISUTL_I_UNKNOWN_USER));
		return;
	}
*/

	cmd = action_command;

	switch(action)
	{
		case GRANT:
			cmd += sprintf(cmd,"GRANT SCHEMA to %s", selected_user);
			break;
		case REVOKE:
			cmd += sprintf(cmd,"REVOKE SCHEMA from %s",selected_user);
			break;	
	}

	FRM_DBG(("%s\n",action_command));

	if (RISfrm_user_exec_da_form &&
		RISfrm_user_exec_da_form(da_form, action_command) == 0)
			return;

	RISfrm_execute_command(action_command);

	da_msg->str[0] = 0;
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

	sprintf(da_msg->str,MSG(RISUTL_I_RIS_SUCCESS_MSG));
	update_msg_field(da_msg->str);

	if (RIS_forms_error.error == RIS_SUCCESS)
	{
		switch(action)
		{
			case GRANT:
				load_access_users_mcf(schname);
				break;
			case REVOKE:
				update_access_users_mcf(REVOKE, selected_user);
				break;
		}
		clear_selected_user_field();
	}
}

/******************************************************************************/

static void	process_execute_button()
{
	process_execute();
}

/*******************************************************************************
******************** CANCEL_BUTTON *********************************************
*******************************************************************************/

static void process_cancel_button()
{
	FRM_DBG(("process_cancel_button() in frmdicac.c\n"));
	RISfrm_erase_da_form();

	if (RISfrm_sd_form_displayed())
		RISfrm_clear_sd_dict_access_button();
}

/*******************************************************************************
******************** RESET_BUTTON **********************************************
*******************************************************************************/

static void process_reset_button()
{
	FRM_DBG(("process_reset_button()\n"));
	RISfrm_clear_da_form();
	if (RISfrm_sm_form_displayed())
		RISfrm_update_sm_schemas_field(NULL);
	DISPLAY_HELP_BUTTON(da_form);
	RISfrm_call_user_init_da_form();
}

/*******************************************************************************
******************** DA FORM ***************************************************
*******************************************************************************/

extern void RISfrm_process_da_form(
	int	g_label)
{
	int	i;
	static	RISfrm_label_function	process_gadget[] = 
	{
		{	FI_CANCEL,			process_cancel_button	},
		{	FI_RESET,			process_reset_button	},
		{	FI_EXECUTE,			process_execute_button	},
		{	DA_SCHNAME_FIELD,		process_schname_field	},
		{	DA_SELECTED_USER_FIELD,		process_user_input_group	},
		{	DA_ACCESS_USERS_MCF,		process_access_users_mcf	},
		{	DA_ALL_USERS_MCF,	        process_dbms_users_mcf	},
	};
	static	int						process_gadget_count =
		sizeof(process_gadget)/sizeof(RISfrm_label_function);

	FRM_DBG(("RISfrm_process_da_form(g_label:%d)\n", g_label));

	if (!da_form) return;

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

extern void RISfrm_call_user_init_da_form()
{
	FRM_DBG(("RISfrm_call_user_init_da_form()\n"));

	if (RISfrm_user_init_da_form)
	{
		FRM_DBG(("calling RISfrm_user_init_da_form()\n"));
		RISfrm_user_init_da_form(da_form);
	}
}

/******************************************************************************/

extern int RISfrm_display_da_form(
	int	called_by_user)
{
	int	sts;

	FRM_DBG(("RISfrm_display_da_form(called_by_user:%d)\n", called_by_user));

	if (!RISfrm_initialized)
	{
		RISfrm_form_errhandle(RISUTL_E_FORMS_NOT_INITIALIZED, 0);
		return RIS_forms_error.error;
	}


	if (!da_form)
	{
		sts = FIf_new(DA_FORM, DA_FORM_FILE, RISfrm_notification_routine,
			&da_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_CREATE_DA_FORM, sts);
			return RIS_forms_error.error;
		}

		FIfld_set_max_num_chars(da_form, DA_SCHNAME_FIELD, 0,
			RIS_MAX_ID_SIZE - 1);
		FIfld_set_max_num_chars(da_form, DA_SELECTED_USER_FIELD, 0,
			RIS_MAX_ID_SIZE - 1);
#if defined(WIN32)
		FIf_SetDefaultButton(da_form, FI_EXECUTE);
		FIg_set_text(da_form, FI_CANCEL, RIScom_umsg(RISUTL_I_CLOSE)); 
#endif
	}

	if (!RISfrm_da_form_displayed())
	{
		da_msg->str[0] = 0;
		da_msg->count = 0;
		da_msg->msg_fld_label = DA_MSG_FIELD;
		da_msg->fp = da_form;

		DISPLAY_HELP_BUTTON(da_form);

		if (called_by_user) RISfrm_call_user_init_da_form();

		sts = FIf_display (da_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_DISPLAY_DA_FORM, sts);
			return RIS_forms_error.error;
		}
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/******************************************************************************/

extern void RISfrm_update_da_form(
	ris_schema_info	*schemap)
{
	FRM_DBG(("RISfrm_update_da_form(schemap:0x%x)\n",schemap));
	if (!da_form) return;
	if (!schemap)
	{
		RISfrm_clear_da_form();
		return;
	}

	update_schname_field(schemap->schname);
    update_msg_field(MSG(RISUTL_I_OPENING_SCHEMA));
	clear_users_mcf(DA_ACCESS_USERS_MCF);
	clear_users_mcf(DA_ALL_USERS_MCF);
	FRM_DBG(("RISfrm_update_da_form in frmdicac.c  schemap->schname:%s\n",schemap->schname));
	RISfrm_set_default_schema(schemap->schname, schemap->dbid);
	
	/* kmreddy Fix TR # 439502890 */
#if defined(WIN32)

	if ( risca->sqlcode == RIS_E_NO_SCHEMA_NO_ACCESS || 
		 risca->sqlcode == RIS_E_NO_SCHEMA_TABLES )
	   {
		  RISfrm_clear_da_form();
	      RISfrm_form_errhandle ( RISUTL_E_RIS_ERROR, 0 );
	      RISfrm_report_error() ;
	      return;
	   }
#endif
	 	
	clear_selected_user_field();
	load_access_users_mcf(schemap->schname);
	load_dbms_users_mcf(schemap->schname);
}

/******************************************************************************/

extern void RISfrm_clear_da_form()
{
	FRM_DBG(("RISfrm_clear_da_form()\n"));
	if (!da_form) return;
	clear_schname_field();
	clear_selected_user_field();
	clear_action_toggle();
	clear_users_mcf(DA_ACCESS_USERS_MCF);
	clear_users_mcf(DA_ALL_USERS_MCF);

}

/******************************************************************************/

extern int RISfrm_da_form_displayed()
{
	int	form_displayed;

	FRM_DBG(("RISfrm_da_form_displayed()\n"));
	if (!da_form) return(0);
	FIf_is_displayed(da_form, &form_displayed);
	return(form_displayed);
}

/******************************************************************************/

extern int RISfrm_erase_da_form()
{
	int	sts;

	FRM_DBG(("RISfrm_erase_da_form()\n"));

	if (RISfrm_da_form_displayed())
	{
		sts = FIf_erase(da_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_ERASE_DA_FORM, sts);
			return RIS_forms_error.error;
		}
		RISfrm_clear_da_form();
		if (RISfrm_sd_form_displayed())
			RISfrm_clear_sd_dict_access_button();
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/*******************************************************************************
************** USER FUNCTIONS **************************************************
*******************************************************************************/

extern int RISAPI RISXfrm_dict_access_form_displayed()
{
	return RISfrm_da_form_displayed();
}

/******************************************************************************/

extern int RISAPI RISXfrm_display_dict_access_form()
{
	return RISfrm_display_da_form(CALLED_BY_USER);
}

/******************************************************************************/

extern int RISAPI RISXfrm_erase_dict_access_form()
{
	return RISfrm_erase_da_form();
}

/******************************************************************************/
/*******************************************************************************
************** DA_ACCESS_USERS_MCF *********************************************
*******************************************************************************/

static void load_access_users_mcf(
	char	*schname)
{
	int		i;

	FRM_DBG(("load_access_users_mcf(schname:<%s>)\n",
		schname ? schname : "NULL"));

	VALID_FORM_CHECK(da_form);
		
	if (!*schname) return;

	clear_users_mcf(DA_ACCESS_USERS_MCF);

	RISfrm_clear_access_user_list();

	RISfrm_get_access_user_list(schname,update_msg_field,clear_msg_field);
	clear_msg_field();
	if (RIS_forms_error.error && RISfrm_report_error())
	{
			switch(RIS_forms_error.error)
			{
			}
			return;
	}


	FIfld_set_num_rows(da_form, DA_ACCESS_USERS_MCF, RISfrm_access_users_cnt);

	if (RISfrm_access_users_cnt)
	{
		for (i = 0; i < RISfrm_access_users_cnt; i++)
		{
			FIfld_set_text(da_form, DA_ACCESS_USERS_MCF, i, 0,
				RISfrm_access_users[i]->user, 0);
		}
	}
	else
	{
		FIfld_pos_cursor(da_form, DA_SELECTED_USER_FIELD,0,0,0,0,0,0);		
	}
	clear_msg_field();
}

/******************************************************************************/
/*******************************************************************************
************** DA_DBMS_USERS_MCF *********************************************
*******************************************************************************/

static void load_dbms_users_mcf(
	char	*schname)
{
	int		i;

	FRM_DBG(("load_dbms_users_mcf(schname:<%s>)\n",
		schname ? schname : "NULL"));

	if (!da_form) return;
	if (!*schname) return;
		
	clear_users_mcf(DA_ALL_USERS_MCF);

	RISfrm_clear_dbms_user_list();

	RISfrm_get_dbms_user_list(schname,update_msg_field,clear_msg_field);
	clear_msg_field();
	if (RIS_forms_error.error && RISfrm_report_error())
	{
			switch(RIS_forms_error.error)
			{
			}
			return;
	}


	FIfld_set_num_rows(da_form, DA_ALL_USERS_MCF, RISfrm_dbms_users_cnt);

	for (i = 0; i < RISfrm_dbms_users_cnt; i++)
	{
		FIfld_set_text(da_form, DA_ALL_USERS_MCF, i, 0,
		RISfrm_dbms_users[i]->user, 0);
	}
	clear_msg_field();
}

/******************************************************************************/
/******************************************************************************/

static void process_access_users_mcf()
{
	RISfrm_user	*userptr;

	FRM_DBG(("process_access_users_mcf()\n"));
	if (userptr = get_selected_user(DA_ACCESS_USERS_MCF))
	{
		update_action_toggle(REVOKE);
		update_selected_user_field(userptr->user);
	}
	else
	{
		clear_selected_user_field();
	}
}
/******************************************************************************/

static void process_dbms_users_mcf()
{
	RISfrm_user	*userptr;

	FRM_DBG(("process_dbms_users_mcf()\n"));
	if (userptr = get_selected_user(DA_ALL_USERS_MCF))
	{
		update_action_toggle(GRANT);
		update_selected_user_field(userptr->user);
	}
	else
	{
		clear_selected_user_field();
	}
}
/******************************************************************************/

static RISfrm_user *get_selected_user(
	int g_label)
{
	int				row;
	int				num_rows;
	int				sel_flag;
	int				r_pos;

	static	 RISfrm_user	selected_user;

	FRM_DBG(("get_selected_user()\n"));

	FIfld_get_num_rows(da_form, g_label, &num_rows);

	for (row = 0; row < num_rows; row++)
	{
		FIfld_get_text(da_form, g_label, row, 0, 31, 
                (unsigned char *)selected_user.user, &sel_flag, &r_pos);

		if (sel_flag)
		{
			return &selected_user;
		}
	}
	return NULL;
}

/******************************************************************************/

static void update_access_users_mcf(
	int 	action,
	char	*selected_user)
{
	int		row;
	int		r_pos;
	int		sel_flag;
	int		num_rows;
	char	rowuser[RIS_MAX_ID_SIZE];

	FRM_DBG(("update_access_users_mcf(selected_user:%s)\n",selected_user));

	if (!da_form) return;

	FIfld_get_num_rows(da_form, DA_ACCESS_USERS_MCF, &num_rows);

	if (action == REVOKE)
	{
		for (row = 0; row < num_rows; row++)
		{
			FIfld_get_text(da_form, DA_ACCESS_USERS_MCF, row, 0,
                        RIS_MAX_ID_SIZE, (unsigned char *)rowuser, &sel_flag, &r_pos);

			if (selected_user && (strcmp(rowuser, selected_user) == 0))
			{
				FIfld_delete_rows(da_form, DA_ACCESS_USERS_MCF, row, 1);
			}
			continue;
		}
	}

}

/******************************************************************************/

static void clear_users_mcf(
	int  g_label)
{
	FRM_DBG(("clear_users_mcf()\n"));
	RISfrm_clear_multi_row_field(da_form, g_label);
}

/******************************************************************************/
