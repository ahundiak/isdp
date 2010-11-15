/* Do not alter this SPC information: $Revision: 1.3.3.1 $ */
/*
**	NAME:						frmschac.c
**	AUTHORS:					Linda Wang
**	CREATION DATE:				11/93
**	ABSTRACT:
**		Process the secure schema access form for grant/revoke 
**		resource/Connect to users.
**
**	REVISION HISTORY:
**
**	11/94:	Added support for INTERNATIONALIZATION.  Linda Wang
**	02/03/95 Removed NTJ specific changes. rlk
**	7/18/96: Ashley - fix for TR 439503632
*/
 
/*
**	INCLUDES
*/
#include "forms.h"
#include "riscom.h"

/*
**	FUNCTION PROTOTYPES
*/
#define frmschac_c
#include "comdebug.prt"
#include "comumsg.prt"
#include "fi.prt"
#include "frmdbusr.prt"
#include "frmerror.prt"
#include "frmexec.prt"
#include "frmfile.prt"
#include "frmntfy.prt"
#include "frmschac.prt"
#include "frmschdf.prt"
#include "frmschmg.prt"
#include "frmusers.prt"
#include "frmutil.prt"
#include "sys.prt"
#if defined (WIN32)
#include "fi_winnt.prt"
#endif

/*
**	DEFINES
*/
#define	GRANT		0
#define	REVOKE		1

#define	RESOURCE	0
#define	CONNECT		1
	
/*
**	VARIABLES
*/
static	 Form		sa_form = 0;
static	RISfrm_msg	*sa_msg = &RISfrm_msgs[SA_FORM_MSG];
/*
**	FUNCTIONS
*/

/*******************************************************************************
************** SA_MSG_FIELD ****************************************************
*******************************************************************************/

static void update_msg_field(
	const char	*msg)
{
	FRM_DBG(("update_msg_field in frmschac.c(msg:<%s>)\n", msg));
	FIfld_set_text(sa_form, SA_MSG_FIELD, 0, 0, (char *)msg, 0);
}

/******************************************************************************/

static void clear_msg_field()
{
	FRM_DBG(("clear_msg_field()\n"));
	FIfld_set_text(sa_form, SA_MSG_FIELD, 0, 0, "", 0);
}

/******************************************************************************/

static void disable_sa_gadgets()
{
	FRM_DBG(("disable_sa_gadgets()\n"));
	FIg_disable(sa_form, SA_EXECUTE_BUTTON);
	FIg_disable(sa_form, SA_ACTION_TOGGLE);
	FIg_disable(sa_form, SA_PRIVILEGE_TOGGLE);
	FIg_disable(sa_form, SA_ACCESS_USERS_MCF);
	FIg_disable(sa_form, SA_ALL_USERS_MCF);
	FIg_disable(sa_form, SA_SELECTED_USER_FIELD);
	
}

/******************************************************************************/

static void enable_sa_gadgets()
{
	FRM_DBG(("enable_sa_gadgets()\n"));
	FIg_enable(sa_form, SA_EXECUTE_BUTTON);
	FIg_enable(sa_form, SA_ACTION_TOGGLE);
	FIg_enable(sa_form, SA_PRIVILEGE_TOGGLE);
	FIg_enable(sa_form, SA_ACCESS_USERS_MCF);
	FIg_enable(sa_form, SA_ALL_USERS_MCF);
	FIg_enable(sa_form, SA_SELECTED_USER_FIELD);
	
}
/*******************************************************************************
******************** SA_SCHNAME FIELD ******************************************
*******************************************************************************/

extern char *RISfrm_get_sa_schname_field()
{
	static	 char	schname[RIS_MAX_ID_SIZE];

	FRM_DBG(("RISfrm_get_sa_schname_field()\n"));

	RISfrm_get_field(sa_form, SA_SCHNAME_FIELD, RIS_MAX_ID_SIZE, schname);
	if (schname[0]) return(schname);
	return(NULL);
}

/******************************************************************************/

static void process_schname_field()
{
	char		*schname;
	ris_schema_info	*schema;
	char 		*slct_schname;

	FRM_DBG(("process_schname_field()\n"));
	schname = RISfrm_get_sa_schname_field();
	schema = RISfrm_get_schema(schname, update_msg_field, clear_msg_field);

/*	7/18/96: Ashley - fix for TR 439503632
*       If the schema has already been selected then a default schema has
*	already been done when the secure access form is first displayed.
*       If RISfrm_update_sa_form() is called again another default schema
*       and associated tasks will be done which results in sort of a 
*       recursive condition  
*/
        slct_schname = RISfrm_get_selected_schname();	
	if (slct_schname == NULL)
		RISfrm_update_sa_form(schema);
	else
          if (strcmp(slct_schname, schname)) 
		RISfrm_update_sa_form(schema);


	if (RISfrm_sm_form_displayed())
		RISfrm_update_sm_schemas_field(schname);
}

/******************************************************************************/

static void update_schname_field(
	char	*schname)
{
	FRM_DBG(("update_schname_field(schname:<%s>)\n",schname));
	FIfld_set_text(sa_form, SA_SCHNAME_FIELD, 0, 0, schname, 0);
}

/******************************************************************************/

static void clear_schname_field()
{
	FRM_DBG(("clear_schname_field()\n"));
	FIfld_set_text(sa_form, SA_SCHNAME_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** SA_SELECTED_USER_FIELD ************************************
*******************************************************************************/

static char *get_selected_user_field()
{
	static	 char	selected_user[RIS_MAX_ID_SIZE];

	FRM_DBG(("get_selected_user_field()\n"));

	RISfrm_get_field(sa_form, SA_SELECTED_USER_FIELD, RIS_MAX_ID_SIZE, selected_user );
	if (selected_user[0]) return(selected_user);
	return(NULL);
}

/******************************************************************************/

static void update_selected_user_field(
	char	*selected_user)
{
	FRM_DBG(("update_selected_user_field(%s)\n", selected_user));
	FIfld_set_text(sa_form, SA_SELECTED_USER_FIELD, 0, 0, selected_user, 0);
}

/******************************************************************************/

static void clear_selected_user_field()
{
	FRM_DBG(("clear_selected_user_field()\n"));
	FIfld_set_text(sa_form, SA_SELECTED_USER_FIELD, 0, 0, "", 0);
}

/*******************************************************************************
******************** ACTION TOGGLE ********************************************
*******************************************************************************/

static int get_action_toggle()
{
	int state;

	FRM_DBG(("get_action_toggle()\n"));
	
	FIg_get_state(sa_form, SA_ACTION_TOGGLE, &state);
	return state;
	
}

/*********************************************************************/

static void update_action_toggle(
	int state)
{
	FRM_DBG(("update_action_toggle()\n"));
	
	FIg_set_state(sa_form, SA_ACTION_TOGGLE, state);
	
}

/*********************************************************************/

static void clear_action_toggle()
{
	FRM_DBG(("clear_action_toggle()\n"));
	
	FIg_set_state(sa_form, SA_ACTION_TOGGLE,0 );
	
}

/*******************************************************************************
******************** PRIVILEGE TOGGLE ********************************************
*******************************************************************************/

static int get_privilege_toggle()
{
	int state;

	FRM_DBG(("get_privilege_toggle()\n"));
	
	FIg_get_state(sa_form, SA_PRIVILEGE_TOGGLE, &state);
	return state;
	
}

/*********************************************************************/

static void update_privilege_toggle(
	int state)
{
	FRM_DBG(("update_privilege_toggle()\n"));
	
	FIg_set_state(sa_form, SA_PRIVILEGE_TOGGLE, state);
}

/*********************************************************************/

static void clear_privilege_toggle()
{
	FRM_DBG(("clear_privilege_toggle()\n"));
	
	FIg_set_state(sa_form, SA_PRIVILEGE_TOGGLE,0 );
	
}
/******************************************************************************/

static void process_access_users_mcf()
{
        RISfrm_user     *userptr;

        FRM_DBG(("process_access_user_mcf()\n"));
        if (userptr = get_selected_user(SA_ACCESS_USERS_MCF))
        {
                update_action_toggle(REVOKE);

		switch(userptr->privilege)
		{
			case 'C':
                		update_privilege_toggle(CONNECT);
				break;

			case 'R':
                		update_privilege_toggle(RESOURCE);
				break;
		}

                update_selected_user_field(userptr->user);
        }
        else
        {
                clear_selected_user_field();
        }
}
/******************************************************************************/

static void clear_users_mcf(
        int  g_label)
{
        FRM_DBG(("clear_users_mcf()\n"));
        RISfrm_clear_multi_row_field(sa_form, g_label);
}

/******************************************************************************/

static void process_dbms_users_mcf()
{
        RISfrm_user     *userptr;

        FRM_DBG(("process_dbms_users_mcf()\n"));
        if (userptr = get_dbms_selected_user(SA_ALL_USERS_MCF))
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
        int                             row;
        int                             num_rows;
        int                             sel_flag;
        int                             r_pos;

	unsigned char		privilege[3];
        static   RISfrm_user     selected_user;

        FRM_DBG(("get_selected_user()\n"));

        FIfld_get_num_rows(sa_form, g_label, &num_rows);

        for (row = 0; row < num_rows; row++)
        {
                FIfld_get_text(sa_form, g_label, row, 0, 2,
				 privilege, &sel_flag, &r_pos);

                if (sel_flag)
                {
			selected_user.privilege = privilege[0];
                	FIfld_get_text(sa_form, g_label, row, 1, 31,
               		(unsigned char *)selected_user.user, &sel_flag, &r_pos);
                        return &selected_user;
                }
        }
        return NULL;
}
/******************************************************************************/

static RISfrm_user *get_dbms_selected_user(
        int g_label)
{
        int                             row;
        int                             num_rows;
        int                             sel_flag;
        int                             r_pos;

        static   RISfrm_user     selected_user;

        FRM_DBG(("get_dbms_selected_user()\n"));

        FIfld_get_num_rows(sa_form, g_label, &num_rows);

        for (row = 0; row < num_rows; row++)
        {
                FIfld_get_text(sa_form, g_label, row, 0, 31,
                        (unsigned char *)selected_user.user, &sel_flag, &r_pos);
                if (sel_flag)
                {
                        return &selected_user;
                }
        }
        return NULL;
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

        FIfld_get_num_rows(sa_form, mcf_id, &num_rows);
        FIfld_get_num_vis_rows(sa_form, mcf_id, &num_vis_rows);

        for (row = 0; row < num_rows; row++)
        {
                FIfld_get_text(sa_form, mcf_id, row, 1, RIS_MAX_ID_SIZE,
                        (unsigned char *)rowname, &sel_flag, &r_pos);

                if (user && user[0] && !strcmp(rowname,user))
                {
                        FIfld_set_select(sa_form, mcf_id, row, 0, 1);
                        FIfld_set_select(sa_form, mcf_id, row, 1, 1);
                        FIfld_get_row_offset(sa_form, mcf_id, &offset);
                        if (row < offset || row >= offset + num_vis_rows)
	                {
                                FIfld_set_active_row(sa_form, mcf_id, row, 0);
                                FIfld_set_active_row(sa_form, mcf_id, row, 1);
                        }
                                continue;
                }
                if (sel_flag)
                {
                        FIfld_set_select(sa_form, mcf_id, row, 0, 0);
                        FIfld_set_select(sa_form, mcf_id, row, 1, 0);
                }
        }
}
/*******************************************************************************
**************  DBMS USERS ****************************************************
*******************************************************************************/

static void select_dbms_user(
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

        FRM_DBG(("select_dbms_user(mcf_id:%d user:<%s> )\n", mcf_id,
                user ? user : "NULL"));

        FIfld_get_num_rows(sa_form, mcf_id, &num_rows);
        FIfld_get_num_vis_rows(sa_form, mcf_id, &num_vis_rows);

        for (row = 0; row < num_rows; row++)
        {
                FIfld_get_text(sa_form, mcf_id, row, 0, RIS_MAX_ID_SIZE,
                        (unsigned char *)rowname, &sel_flag, &r_pos);

                if (user && user[0] && !strcmp(rowname,user))
                {
                        FIfld_set_select(sa_form, mcf_id, row, 0, 1);
                        FIfld_get_row_offset(sa_form, mcf_id, &offset);
                        if (row < offset || row >= offset + num_vis_rows)
	                {
                                FIfld_set_active_row(sa_form, mcf_id, row, 0);
                        }
                                continue;
                }
                if (sel_flag)
                {
                        FIfld_set_select(sa_form, mcf_id, row, 0, 0);
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
        for (i = 0; i < RISfrm_dbms_users_cnt; i++)
        {                if ( !strcmp(user, RISfrm_dbms_users[i]->user))
                {
                        sts = 1;
                        break;
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
        for (i = 0; i < RISfrm_users_cnt; i++)
        {                if ( !strcmp(user, RISfrm_users[i]->user))
                {
                        sts = 1;
                        break;
                }
        }

        return sts;
}

/*******************************************************************************
************** USER INPUT GROUP ************************************************
*******************************************************************************/

/*
**      NOTE: the user input group is:
**                      SA_ACTION_TOGGLE
**                      SA_PRIVILEGE_TOGGLE
**                      SA_SELECTED_USER_FIELD
**
*/
static void process_user_input_group()
{
        char    *user;

        FRM_DBG(("process_user_input_group()\n"));

        user = get_selected_user_field();

        switch(get_action_toggle())
        {
                case GRANT:
        		select_dbms_user(SA_ALL_USERS_MCF, user);
       		        select_user(SA_ACCESS_USERS_MCF, NULL);
                        break;

                case REVOKE:
        		select_user(SA_ACCESS_USERS_MCF, user);
       		        select_dbms_user(SA_ALL_USERS_MCF, NULL);
                        break;
        }

}

/*******************************************************************************
************** ACCESS_USER_LIST *****************************************************
*******************************************************************************/

static void load_access_user_list(
        char *schname)
{
	int i;
	char privilege[3];

        FRM_DBG(("load_access_user_list(schname:<%s>)\n", schname));
	clear_users_mcf(SA_ACCESS_USERS_MCF);
/*
        if (!RISfrm_user_list_up_to_date)
*/
         RISfrm_get_user_list(schname,update_msg_field, clear_msg_field);
         clear_msg_field();
         if (RIS_forms_error.error && RISfrm_report_error())
         {
                  switch(RIS_forms_error.error)
                  {
                  }
                      return;
         }
       FIfld_set_num_rows(sa_form, SA_ACCESS_USERS_MCF, RISfrm_users_cnt);

        if (RISfrm_users_cnt)
        {
                for (i = 0; i < RISfrm_users_cnt; i++)
                {
			privilege[0] = RISfrm_users[i]->privilege;
			privilege[1] = '\0';
                        FIfld_set_text(sa_form, SA_ACCESS_USERS_MCF,
                             		i, 0, privilege, 0);
                        FIfld_set_text(sa_form, SA_ACCESS_USERS_MCF, i, 1,
                                RISfrm_users[i]->user, 0);
                }
        }
	else
	{
		FIfld_pos_cursor(sa_form, SA_SELECTED_USER_FIELD, 0,0,0,0,0,0);
	}	
}
/******************************************************************************/
/*******************************************************************************
************** DA_DBMS_USERS_LIST *********************************************
*******************************************************************************/

static void load_dbms_users_list(
        char    *schname)
{
        int             i;

        FRM_DBG(("load_dbms_users_list(schname:<%s>)\n",
                schname ? schname : "NULL"));

        if (!sa_form) return;
        if (!*schname) return;

        clear_users_mcf(SA_ALL_USERS_MCF);
	RISfrm_clear_dbms_user_list();
/*
        if (!RISfrm_dbms_user_list_up_to_date)
*/
        RISfrm_get_dbms_user_list(schname,update_msg_field,clear_msg_field);
        clear_msg_field();
        if (RIS_forms_error.error && RISfrm_report_error())
        {
               switch(RIS_forms_error.error)
               {
               }
                     return;
        }

        FIfld_set_num_rows(sa_form, SA_ALL_USERS_MCF, RISfrm_dbms_users_cnt);

        if (RISfrm_dbms_users_cnt)
        {
                for (i = 0; i < RISfrm_dbms_users_cnt; i++)
                {
                        FIfld_set_text(sa_form, SA_ALL_USERS_MCF, i, 0,
                                RISfrm_dbms_users[i]->user, 0);
                }
        }
        else
        {
		/*
                strcpy(sa_msg->str, MSG(RISUTL_I_NO_TABLES_VIEWS_INDEXES));
		*/
		
		FIfld_pos_cursor(sa_form, SA_SELECTED_USER_FIELD, 0,0,0,0,0,0);
        }
}

/*******************************************************************************
******************** EXECUTE BUTTON ********************************************
*******************************************************************************/

static void process_execute()
{
	int	action;
	int	user_privilege;
	int	valid = 0;
	char	*cmd;
	char	*schname;
	char	*selected_user;
	char	action_command[128], default_schema_command[128];

	FRM_DBG(("process_execute_button\n"));
	clear_msg_field();
	update_msg_field(sa_msg->str);

	cmd = default_schema_command;

	if ((schname = RISfrm_get_sa_schname_field()) == NULL)
	{
		sa_msg->label[sa_msg->count++] = SA_SCHNAME_TEXT;
		sa_msg->label[sa_msg->count++] = SA_SCHNAME_FIELD;
		strcpy(sa_msg->str, MSG(RISUTL_I_SCHNAME_MUST_BE_SPEC));
		FIfld_pos_cursor(sa_form, SA_SCHNAME_FIELD,0,0,0,0,0,0);
		return;	
	}
	cmd += sprintf(cmd, "DEFAULT SCHEMA %s", schname);

	FRM_DBG(("%s\n", default_schema_command));
	if (RISfrm_user_exec_sa_form &&
            RISfrm_user_exec_sa_form(sa_form, default_schema_command) == 0)
		return;	
	RISfrm_execute_command(default_schema_command);

	sa_msg->str[0] = 0;
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
	cmd = action_command;
	if ((selected_user = get_selected_user_field()) == NULL)
	{
		sa_msg->label[sa_msg->count++] = SA_SELECTED_USER_TEXT;
		sa_msg->label[sa_msg->count++] = SA_SELECTED_USER_FIELD;
		strcpy(sa_msg->str, MSG(RISUTL_I_NAME_MUST_BE_SPEC));
		FIfld_pos_cursor(sa_form, SA_SELECTED_USER_FIELD, 0, 0, 0, 0, 0, 0);
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
		strcpy(sa_msg->str, MSG(RISUTL_I_UNKNOWN_USER));
		return;
	}

*/
	user_privilege = get_privilege_toggle();
        cmd = action_command;

        switch(action)
        {
                case GRANT:
			switch(user_privilege)
			{
				case RESOURCE:
                         		cmd += sprintf(cmd,
					"GRANT RESOURCE to %s", selected_user);
                       			break;

				case CONNECT:
                       			cmd += sprintf(cmd,
					"GRANT CONNECT to %s", selected_user);
		 			break;
		
			}
			break;

                case REVOKE:
			switch(user_privilege)
			{
				case RESOURCE:
                         		cmd += sprintf(cmd,
					"REVOKE RESOURCE from %s",
					 selected_user);
                       			break;

				case CONNECT:
                       			cmd += sprintf(cmd,
					"REVOKE CONNECT from %s",
					 selected_user);
		 			break;
		
			}
			break;
	}

	FRM_DBG(("%s\n",action_command));

	if (RISfrm_user_exec_sa_form &&
		RISfrm_user_exec_sa_form(sa_form, action_command) == 0)
			return;

	RISfrm_execute_command(action_command);

	sa_msg->str[0] = 0;
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

	sprintf(sa_msg->str,MSG(RISUTL_I_RIS_SUCCESS_MSG));
	update_msg_field(sa_msg->str);

        if (RIS_forms_error.error == RIS_SUCCESS)
        {
		load_access_user_list(schname);
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
	FRM_DBG(("process_cancel_button() in frmschac.c\n"));
	RISfrm_erase_sa_form();
	if (RISfrm_sd_form_displayed())
		RISfrm_clear_sd_secure_sch_access_button();
}

/*******************************************************************************
******************** RESET_BUTTON **********************************************
*******************************************************************************/

static void process_reset_button()
{
	FRM_DBG(("process_reset_button()\n"));
	RISfrm_clear_sa_form();
	if (RISfrm_sm_form_displayed())
		RISfrm_update_sm_schemas_field(NULL);
	DISPLAY_HELP_BUTTON(sa_form);
	RISfrm_call_user_init_sa_form();
}

/*******************************************************************************
******************** DA FORM ***************************************************
*******************************************************************************/

extern void RISfrm_process_sa_form(
	int	g_label)
{
	int	i;
	static	RISfrm_label_function	process_gadget[] = 
	{
		{	FI_CANCEL,			process_cancel_button	},
		{	FI_RESET,			process_reset_button	},
		{	FI_EXECUTE,			process_execute_button	},
		{	SA_SCHNAME_FIELD,       	process_schname_field	},
               {        SA_SELECTED_USER_FIELD,         process_user_input_group
        },
                {       SA_ACCESS_USERS_MCF,            process_access_users_mcf
        },
                {       SA_ALL_USERS_MCF,               process_dbms_users_mcf
},
	};
	static	int						process_gadget_count =
		sizeof(process_gadget)/sizeof(RISfrm_label_function);

	FRM_DBG(("RISfrm_process_sa_form(g_label:%d)\n", g_label));

	if (!sa_form) return;

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

extern void RISfrm_call_user_init_sa_form()
{
	FRM_DBG(("RISfrm_call_user_init_sa_form()\n"));

	if (RISfrm_user_init_sa_form)
	{
		FRM_DBG(("calling RISfrm_user_init_sa_form()\n"));
		RISfrm_user_init_sa_form(sa_form);
	}
}

/******************************************************************************/

extern int RISfrm_display_sa_form(
	int	called_by_user)
{
	int	sts;

	FRM_DBG(("RISfrm_display_sa_form(called_by_user:%d)\n", called_by_user));

	if (!RISfrm_initialized)
	{
		RISfrm_form_errhandle(RISUTL_E_FORMS_NOT_INITIALIZED, 0);
		return RIS_forms_error.error;
	}


	if (!sa_form)
	{
		sts = FIf_new(SA_FORM, SA_FORM_FILE, RISfrm_notification_routine,
			&sa_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_CREATE_SA_FORM, sts);
			return RIS_forms_error.error;
		}

		FIfld_set_max_num_chars(sa_form, SA_SCHNAME_FIELD, 0,
			RIS_MAX_ID_SIZE - 1);
		FIfld_set_max_num_chars(sa_form, SA_SELECTED_USER_FIELD, 0,
			RIS_MAX_ID_SIZE - 1);
#if defined(WIN32)
                FIf_SetDefaultButton(sa_form, FI_EXECUTE);
                FIg_set_text(sa_form, FI_CANCEL, RIScom_umsg(RISUTL_I_CLOSE));

#endif
	}

	if (!RISfrm_sa_form_displayed())
	{
		sa_msg->str[0] = 0;
		sa_msg->count = 0;
		sa_msg->msg_fld_label = SA_MSG_FIELD;
		sa_msg->fp = sa_form;

		DISPLAY_HELP_BUTTON(sa_form);

		if (called_by_user) RISfrm_call_user_init_sa_form();

		sts = FIf_display (sa_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_DISPLAY_SA_FORM, sts);
			return RIS_forms_error.error;
		}
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/******************************************************************************/

extern void RISfrm_update_sa_form(
	ris_schema_info	*schemap)
{
	FRM_DBG(("RISfrm_update_sa_form(schemap:0x%x)\n",schemap));

	if (!sa_form) return;
	if (!schemap)
	{
		RISfrm_clear_sa_form();
		return;
	}

	update_schname_field(schemap->schname);

	if (!schemap->secure)
	{
		disable_sa_gadgets();
		clear_selected_user_field();
		clear_action_toggle();
		clear_privilege_toggle();
		clear_users_mcf(SA_ACCESS_USERS_MCF);
		clear_users_mcf(SA_ALL_USERS_MCF);

		sprintf(sa_msg->str, MSG(RISUTL_I_NOT_SECURE_SCHEMA), 
                schemap->schname);
		return;
	}
	
	enable_sa_gadgets();
        update_msg_field(MSG(RISUTL_I_OPENING_SCHEMA));
	RISfrm_set_default_schema(schemap->schname, schemap->dbid);
	clear_selected_user_field();
	load_access_user_list(schemap->schname);
	load_dbms_users_list(schemap->schname);
}

/******************************************************************************/

extern void RISfrm_clear_sa_form()
{
	FRM_DBG(("RISfrm_clear_sa_form()\n"));
	if (!sa_form) return;
	clear_schname_field();
	clear_selected_user_field();
        clear_action_toggle();
        clear_privilege_toggle();
        clear_users_mcf(SA_ACCESS_USERS_MCF);
        clear_users_mcf(SA_ALL_USERS_MCF);
}

/******************************************************************************/

extern int RISfrm_sa_form_displayed()
{
	int	form_displayed;

	FRM_DBG(("RISfrm_sa_form_displayed()\n"));
	if (!sa_form) return(0);
	FIf_is_displayed(sa_form, &form_displayed);
	return(form_displayed);
}

/******************************************************************************/

extern int RISfrm_erase_sa_form()
{
	int	sts;

	FRM_DBG(("RISfrm_erase_sa_form()\n"));

	if (RISfrm_sa_form_displayed())
	{
		sts = FIf_erase(sa_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_ERASE_SA_FORM, sts);
			return RIS_forms_error.error;
		}
		RISfrm_clear_sa_form();
		if (RISfrm_sd_form_displayed())
			RISfrm_clear_sd_secure_sch_access_button();
	}

	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/*******************************************************************************
************** USER FUNCTIONS **************************************************
*******************************************************************************/

extern int RISAPI RISXfrm_schema_access_form_displayed()
{
	return RISfrm_sa_form_displayed();
}

/******************************************************************************/

extern int RISAPI RISXfrm_display_schema_access_form()
{
	return RISfrm_display_sa_form(CALLED_BY_USER);
}

/******************************************************************************/

extern int RISAPI RISXfrm_erase_schema_access_form()
{
	return RISfrm_erase_sa_form();
}

/******************************************************************************/
