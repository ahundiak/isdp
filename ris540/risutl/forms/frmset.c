/* Do not alter this SPC information: $Revision: 1.2.40.1 $ */
/*
**	NAME:							frmset.c
**	AUTHORS:						Linda Wang
**	CREATION DATE:					7/94
**	ABSTRACT:
**	
**	REVISION HISTORY:
**		10.24.94 -Radha
**			Added changes for MSSQL data server.
**
**		11/94:	Added support for INTERNATIONALIZATION. Linda Wang
**	02/03/95 Removed NTJ specific changes. rlk
*/
 
/*
**	INCLUDES
*/
#include "forms.h"

/*
**	DEFINES
*/
#define OFF           0
#define ON            1

#define LIST  0
#define ALL           1


/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define frmset_c
#include "comdebug.prt"
#include "comumsg.prt"
#include "frmerror.prt"
#include "frmexec.prt"
#include "frmntfy.prt"
#include "frmschmg.prt"
#include "frmset.prt"
#include "fi.prt"
#include "ris.prt"
#include "sys.prt"

#if defined(WIN32)
#include "fi_winnt.prt"
#endif

/*
**	VARIABLES
*/
static struct dbms_info_s
{
	char		*name;
	int		label;
	int		bitmask;
} dbms_info[] =
{
	{"INFORMIX",	SE_INFORMIX_CHECK,	RIS_ENABLE_INFORMIX	},
	{"ORACLE",	SE_ORACLE_CHECK,	RIS_ENABLE_ORACLE	},
	{"INGRES",	SE_INGRES_CHECK,	RIS_ENABLE_INGRES	},
	{"DB2", 	SE_DB2_CHECK,		RIS_ENABLE_DB2		},
	{"RDB", 	SE_RDB_CHECK,		RIS_ENABLE_RDB		},
	{"SYBASE",	SE_SYBASE_CHECK,	RIS_ENABLE_SYBASE	},
	{"SQLDS",	SE_SQLDS_CHECK,		RIS_ENABLE_SQLDS	},
	{"OS400",	SE_OS400_CHECK,		RIS_ENABLE_OS400	},
	{"MSSQL",	SE_MSSQL_CHECK,	    RIS_ENABLE_MSSQL	},
/*
	{	SE_ADABAS_CHECK,	RIS_ENABLE_ADABAS	},
*/
};
static int dbms_info_cnt = sizeof(dbms_info)/sizeof(struct dbms_info_s);

static  Form			se_form = 0;
static  int			exit_status = 0;
static  modes_s			modes;
static RISfrm_msg	*se_msg = &RISfrm_msgs[SE_FORM_MSG];

/*
**	FUNCTIONS
*/

/******************************************************************************/

static int get_ansi_mode()
{
	int ansi_mode;
	FRM_DBG(("get_ansi_mode()\n"));

	FIg_get_state(se_form, SE_ANSI_CHECK, &ansi_mode);

	FRM_DBG(("get_ansi_mode:returning %d\n", ansi_mode));
	return ansi_mode;
}

/******************************************************************************/

static void	update_ansi_mode(
	int ansi_mode)
{
	FRM_DBG(("update_l_mode(ansi_mode:%s)\n", ansi_mode ? "ON" : "OFF"));

	FIg_set_state(se_form, SE_ANSI_CHECK, ansi_mode);

	FRM_DBG(("update_ansi_mode:returning\n"));
}

/******************************************************************************/

static int get_autorename_mode()
{
	int autorename_mode;
	FRM_DBG(("get_autorename_mode()\n"));

	FIg_get_state(se_form, SE_AUTORENAME_CHECK, &autorename_mode);

	FRM_DBG(("get_autorename_mode:returning %d\n", autorename_mode));
	return autorename_mode;
}

/******************************************************************************/

static void	update_autorename_mode(
	int autorename_mode)
{
	FRM_DBG(("update_l_mode(autorename_mode:%s)\n",
		autorename_mode ? "ON" : "OFF"));

	FIg_set_state(se_form, SE_AUTORENAME_CHECK, autorename_mode);

	FRM_DBG(("update_autorename_mode:returning\n"));
}

/******************************************************************************/

static int get_enable_dbms()
{
	int i;
	int state;
	int	enable_dbms = 0;

	FRM_DBG(("get_enable_dbms()\n"));

	for (i = 0; i < dbms_info_cnt; i++)
	{
		FIg_get_state(se_form, dbms_info[i].label, &state);
		if (state)
		{
			enable_dbms |= dbms_info[i].bitmask;
		}
	}
	FRM_DBG(("get_enable_dbms:returning enable_dbms:%d\n", enable_dbms));
	return enable_dbms;
}

/******************************************************************************/

static void update_enable_dbms(
	int enable_dbms)
{
	int i;

	FRM_DBG(("update_enable_dbms(enable_dbms:0x%x)\n", enable_dbms));

	for (i = 0; i < dbms_info_cnt; i++)
	{
		FIg_set_state(se_form, dbms_info[i].label,
			enable_dbms & dbms_info[i].bitmask);
	}
	FRM_DBG(("update_enable_dbms:returning\n"));
}

/******************************************************************************/

extern int RISfrm_se_form_displayed()
{
	int	form_displayed = 0;

	FRM_DBG(("RISfrm_se_form_displayed()\n"));

	if (se_form)
	{
		FIf_is_displayed(se_form, &form_displayed);
	}

	FRM_DBG(("RISfrm_se_form_displayed: returning form_displayed:%d\n",
		form_displayed));
	return(form_displayed);
}

/******************************************************************************/

extern int RISfrm_erase_se_form()
{
        int     sts;

        FRM_DBG(("RISfrm_erase_se_form()\n"));

        if (RISfrm_se_form_displayed())
        {
                sts = FIf_erase(se_form);
                if (sts)
                {
                        RISfrm_form_errhandle(RISUTL_E_ERASE_SE_FORM, sts);
                        return RIS_forms_error.error;
                }
                if (RISfrm_sm_form_displayed())
                        RISfrm_clear_sm_set_button();
        }

        CLEAR_ERROR;
        return RIS_SUCCESS;
}
/******************************************************************************/

extern void RISfrm_process_se_form(
	int	g_label)
{
	FRM_DBG(("RISfrm_process_se_form(g_label:%d)\n", g_label));

	switch(g_label)
	{
		case FI_ACCEPT:
			if (!get_enable_dbms())
			{
				strcpy(se_msg->str,MSG(RISUTL_I_ONE_DBTYPE_MUST_BE_SPEC));
			}
			exit_status = 1;
			RISfrm_get_set_modes();
			RISfrm_erase_se_form();	
			break;

		case FI_CANCEL:
			RISfrm_erase_se_form();	
			break;
	}


	FRM_DBG(("RISfrm_process_se_form:returning\n"));
}

/******************************************************************************/

extern void RISfrm_get_set_modes()
{
	FRM_DBG(("I have clicked OK and in RISfrm_get_set_modes()\n"));
	modes.ansi = get_ansi_mode();
	modes.verify = get_verify_mode();
	modes.blankstrip = get_blankstrip_mode();
	modes.autocommit = get_autocommit_mode();
	modes.autorename = get_autorename_mode();
	modes.enable_dbms = get_enable_dbms();
}
/******************************************************************************/

extern int RISfrm_display_se_form(
        int     called_by_user)
{
        int     sts;
	modes_s *modes_ptr = NULL;
	modes_s temp;

        FRM_DBG(("RISfrm_display_se_form(called_by_user:%d)\n",called_by_user));

        if (!RISfrm_initialized)
        {
                RISfrm_form_errhandle(RISUTL_E_FORMS_NOT_INITIALIZED, 0);
                return RIS_forms_error.error;
        }

        if (!se_form)
        {
                sts = FIf_new(SE_FORM, SE_FORM_FILE, RISfrm_notification_routine,
                        &se_form);
                if (sts)
                {
                        RISfrm_form_errhandle(RISUTL_E_CREATE_SE_FORM, sts);
                        return RIS_forms_error.error;
                }
        }

        if (!RISfrm_se_form_displayed())
        {
                se_msg->str[0] = 0;
                se_msg->count = 0;
                se_msg->msg_fld_label = SE_MSG_FIELD;
                se_msg->fp = se_form;

                DISPLAY_HELP_BUTTON(se_form);

		/*
                **      If called directly by a user, call their init routine,
                **      otherwise, the schema_mgr form will call it
                */
                if (called_by_user) RISfrm_call_user_init_se_form();

                sts = FIf_display (se_form);
                if (sts)
                {
                        RISfrm_form_errhandle(RISUTL_E_DISPLAY_SE_FORM, sts);
                        return RIS_forms_error.error;
                }
        }


	if (exit_status == 0)
        {
                FRM_DBG(("exit_status == 0\n"));

	      	RISint_get_flags(&modes.ansi, &modes.enable_dbms, 
                         &modes.verify, &modes.blankstrip, 
                         &modes.autocommit, &modes.autorename);
       		if (SQLCODE != RIS_SUCCESS)
       		 {
       		      	RISfrm_form_errhandle(RISUTL_E_RIS_ERROR, 0);
       	        	RISfrm_report_error();
       	        	return RIS_forms_error.error;
       		 }
        
		modes_ptr = &modes;

                set_ansi_mode(1);
                set_verify_mode(1);
                set_blankstrip_mode(1);
                set_autocommit_mode(1);
                set_autorename_mode(1);
	        set_enable_dbms_all();

                update_ansi_mode(1);
                update_verify_mode(1);
                update_blankstrip_mode(1);
                update_autocommit_mode(1);
                update_autorename_mode(1);
		update_enable_dbms(modes_ptr->enable_dbms);
        }
	else
	{
                FRM_DBG(("exit_status == 1\n"));

       		memcpy(&temp, &modes, sizeof(modes_s));

               	set_ansi_mode(temp.ansi);
               	set_verify_mode(temp.verify);
               	set_blankstrip_mode(temp.blankstrip);
               	set_autocommit_mode(temp.autocommit);
               	set_autorename_mode(temp.autorename);
	        set_enable_dbms(temp.enable_dbms);

		modes_ptr = &modes;

		update_ansi_mode(modes_ptr->ansi);
		update_verify_mode(modes_ptr->verify);
		update_blankstrip_mode(modes_ptr->blankstrip);
		update_autocommit_mode(modes_ptr->autocommit);
		update_autorename_mode(modes_ptr->autorename);
		update_enable_dbms(modes_ptr->enable_dbms);
	}

        CLEAR_ERROR;
        return RIS_SUCCESS;
}
/******************************************************************************/

static int set_enable_dbms(
        int enable_dbms)
{
        int             i;
        int             dbms_cnt;
        char    *ptr;
        char    cmd[128];

	FRM_DBG(("set_enable_dbms()\n"));

        ptr = cmd;
        ptr += sprintf(ptr,"set database enable only ");
        for (i = 0, dbms_cnt = 0; i < dbms_info_cnt; i++)
        {
                if (enable_dbms & dbms_info[i].bitmask)
                {
                        if (dbms_cnt)
                        {
                                *ptr++ = ',';
				FRM_DBG(("dbms_cnt\n"));
                        }
                        ptr += sprintf(ptr, " %s", dbms_info[i].name);
                        dbms_cnt++;
		}
        }
        RISfrm_execute_command(cmd);
        if (SQLCODE != RIS_SUCCESS)
        {
                RISfrm_form_errhandle(RISUTL_E_RIS_ERROR, 0);
                RISfrm_report_error();
                return 1;
        }
        return 0;
}
/******************************************************************************/
static int set_enable_dbms_all()
{
        char    cmd[128];

	FRM_DBG(("set_enable_dbms()\n"));

        sprintf(cmd,"set database enable all ");
        RISfrm_execute_command(cmd);
        if (SQLCODE != RIS_SUCCESS)
        {
                RISfrm_form_errhandle(RISUTL_E_RIS_ERROR, 0);
                RISfrm_report_error();
                return 1;
        }
        return 0;
}
/******************************************************************************/

static int set_autorename_mode(
        int autorename_mode)
{
        char cmd[24];

        sprintf(cmd, "set mode autorename %s", autorename_mode ? "on" : "off");
        RISfrm_execute_command(cmd);
        if (SQLCODE != RIS_SUCCESS)
        {
                RISfrm_form_errhandle(RISUTL_E_RIS_ERROR, 0);
                RISfrm_report_error();
                return 1;
        }
        return 0;
}
/******************************************************************************/

static int set_ansi_mode(
        int ansi_mode)
{
        char cmd[24];

        sprintf(cmd, "set mode ansi %s", ansi_mode ? "on" : "off");
        RISfrm_execute_command(cmd);
        if (SQLCODE != RIS_SUCCESS)
        {
                RISfrm_form_errhandle(RISUTL_E_RIS_ERROR, 0);
                RISfrm_report_error();
                return 1;
        }
        return 0;
}
/******************************************************************************/

static int set_autocommit_mode(
        int autocommit_mode)
{
        char cmd[32];

        sprintf(cmd,"set transaction autocommit %s",
                autocommit_mode ? "on" : "off");
        RISfrm_execute_command(cmd);
        if (SQLCODE != RIS_SUCCESS)
        {
                RISfrm_form_errhandle(RISUTL_E_RIS_ERROR, 0);
                RISfrm_report_error();
                return 1;
        }
        return 0;
}
/******************************************************************************/

static int set_blankstrip_mode(
        int blankstrip_mode)
{
        char cmd[25];

        sprintf(cmd, "set mode blank strip %s", blankstrip_mode ? "on" : "off");
        RISfrm_execute_command(cmd);
        if (SQLCODE != RIS_SUCCESS)
        {
                RISfrm_form_errhandle(RISUTL_E_RIS_ERROR, 0);
                RISfrm_report_error();
                return 1;
        }
        return 0;
}
/******************************************************************************/

static int set_verify_mode(
        int verify_mode)
{
        char cmd[24];

        sprintf(cmd, "set mode verify %s", verify_mode ? "on" : "off");
        RISfrm_execute_command(cmd);
        if (SQLCODE != RIS_SUCCESS)
        {
                RISfrm_form_errhandle(RISUTL_E_RIS_ERROR, 0);
                RISfrm_report_error();
                return 1;
        }
        return 0;
}
/******************************************************************************/

extern void RISfrm_call_user_init_se_form()
{
        FRM_DBG(("RISfrm_call_user_init_se_form()\n"));

        if (!se_form) return;

        if (RISfrm_user_init_se_form)
        {
                FRM_DBG(("calling RISfrm_user_init_se_form()\n"));
                RISfrm_user_init_se_form(se_form);
        }
}
/******************************************************************************/

static int get_autocommit_mode()
{
        int autocommit_mode;
        FRM_DBG(("get_autocommit_mode()\n"));

        FIg_get_state(se_form, SE_AUTOCOMMIT_CHECK, &autocommit_mode);

        FRM_DBG(("get_autocommit_mode:returning %d\n", autocommit_mode));
        return autocommit_mode;
}

/******************************************************************************/

static int get_blankstrip_mode()
{
        int blankstrip_mode;
        FRM_DBG(("get_blankstrip_mode()\n"));

        FIg_get_state(se_form, SE_BLANKSTRIP_CHECK, &blankstrip_mode);

        FRM_DBG(("get_blankstrip_mode:returning %d\n", blankstrip_mode));
        return blankstrip_mode;
}
/******************************************************************************/

static int get_verify_mode()
{
        int verify_mode;
        FRM_DBG(("get_verify_mode()\n"));

        FIg_get_state(se_form, SE_VERIFY_CHECK, &verify_mode);

        FRM_DBG(("get_verify_mode:returning %d\n", verify_mode));
        return verify_mode;
}
/******************************************************************************/

static void     update_autocommit_mode(
        int autocommit_mode)
{
        FRM_DBG(("update_l_mode(autocommit_mode:%s)\n",
                autocommit_mode ? "ON" : "OFF"));

        FIg_set_state(se_form, SE_AUTOCOMMIT_CHECK, autocommit_mode);

        FRM_DBG(("update_autocommit_mode:returning\n"));
}
/******************************************************************************/

static void     update_blankstrip_mode(
        int blankstrip_mode)
{
        FRM_DBG(("update_l_mode(blankstrip_mode:%s)\n", blankstrip_mode ? "ON" :
 "OFF"));

        FIg_set_state(se_form, SE_BLANKSTRIP_CHECK, blankstrip_mode);

        FRM_DBG(("update_blankstrip_mode:returning\n"));
}
/******************************************************************************/

static void     update_verify_mode(
        int verify_mode)
{
        FRM_DBG(("update_l_mode(verify_mode:%s)\n", verify_mode ? "ON" : "OFF"))
;

        FIg_set_state(se_form, SE_VERIFY_CHECK, verify_mode);

        FRM_DBG(("update_verify_mode:returning\n"));
}
/*******************************************************************************
******************** USER FUNCTIONS ********************************************
*******************************************************************************/

extern int RISAPI RISXfrm_set_form_displayed()
{
        return RISfrm_se_form_displayed();
}

/******************************************************************************/
extern int RISAPI RISXfrm_display_set_form()
{
        return(RISfrm_display_se_form(CALLED_BY_USER));
}
/******************************************************************************/

extern int RISAPI RISXfrm_erase_set_form()
{
        return RISfrm_erase_se_form();
}

/******************************************************************************/

