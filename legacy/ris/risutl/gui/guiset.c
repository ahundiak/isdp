/* Do not alter this SPC information: $Revision: 1.2.40.1 $ */
/*
**	NAME:							guiset.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					5/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
**		10/24/94 -Radha
**			Added chaanges for MSSQL data server.
**
**		11/94:	Added support for INTERNATIONALIZATION.   Rick Kramer
*/
 
/*
**	INCLUDES
*/
#include "rislimit.h"
#include "gui.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define guiset_c
#include "fi.prt"
#include "event.prt"
#include "comdebug.prt"
#include "comumsg.prt"
#include "guierror.prt"
#include "guintfy.prt"
#include "guiin.prt"
#include "guiset.prt"
#include "sys.prt"
#if defined(WIN32)
#include "fi_winnt.prt"
#endif

/*
**	VARIABLES
*/
static struct dbms_info_s
{
	int		label;
	int		bitmask;
} dbms_info[] =
{
	{	SE_INFORMIX_CHECK,	RIS_ENABLE_INFORMIX	},
	{	SE_ORACLE_CHECK,	RIS_ENABLE_ORACLE	},
	{	SE_INGRES_CHECK,	RIS_ENABLE_INGRES	},
	{	SE_DB2_CHECK,		RIS_ENABLE_DB2		},
	{	SE_RDB_CHECK,		RIS_ENABLE_RDB		},
	{	SE_SYBASE_CHECK,	RIS_ENABLE_SYBASE	},
	{	SE_SQLDS_CHECK,		RIS_ENABLE_SQLDS	},
	{	SE_OS400_CHECK,		RIS_ENABLE_OS400	},
	{	SE_MSSQL_CHECK,	    RIS_ENABLE_MSSQL	},
/*
	{	SE_ADABAS_CHECK,	RIS_ENABLE_ADABAS	},
*/
};
static int dbms_info_cnt = sizeof(dbms_info)/sizeof(struct dbms_info_s);

static Form			se_form = 0;
static int			exit_status;
static ris_gui_msg	*se_msg = &RIS_gui_msgs[SE_FORM_MSG];

/*
**	FUNCTIONS
*/

/******************************************************************************/

static int get_ansi_mode()
{
	int ansi_mode;
	GUI_DBG(("get_ansi_mode()\n"));

	FIg_get_state(se_form, SE_ANSI_CHECK, &ansi_mode);

	GUI_DBG(("get_ansi_mode:returning %d\n", ansi_mode));
	return ansi_mode;
}

/******************************************************************************/

static void	update_ansi_mode(
	int ansi_mode)
{
	GUI_DBG(("update_l_mode(ansi_mode:%s)\n", ansi_mode ? "ON" : "OFF"));

	FIg_set_state(se_form, SE_ANSI_CHECK, ansi_mode);

	GUI_DBG(("update_ansi_mode:returning\n"));
}

/******************************************************************************/

static int get_verify_mode()
{
	int verify_mode;
	GUI_DBG(("get_verify_mode()\n"));

	FIg_get_state(se_form, SE_VERIFY_CHECK, &verify_mode);

	GUI_DBG(("get_verify_mode:returning %d\n", verify_mode));
	return verify_mode;
}

/******************************************************************************/

static void	update_verify_mode(
	int verify_mode)
{
	GUI_DBG(("update_l_mode(verify_mode:%s)\n", verify_mode ? "ON" : "OFF"));

	FIg_set_state(se_form, SE_VERIFY_CHECK, verify_mode);

	GUI_DBG(("update_verify_mode:returning\n"));
}

/******************************************************************************/

static int get_blankstrip_mode()
{
	int blankstrip_mode;
	GUI_DBG(("get_blankstrip_mode()\n"));

	FIg_get_state(se_form, SE_BLANKSTRIP_CHECK, &blankstrip_mode);

	GUI_DBG(("get_blankstrip_mode:returning %d\n", blankstrip_mode));
	return blankstrip_mode;
}

/******************************************************************************/

static void	update_blankstrip_mode(
	int blankstrip_mode)
{
	GUI_DBG(("update_l_mode(blankstrip_mode:%s)\n", blankstrip_mode ? "ON" : "OFF"));

	FIg_set_state(se_form, SE_BLANKSTRIP_CHECK, blankstrip_mode);

	GUI_DBG(("update_blankstrip_mode:returning\n"));
}

/******************************************************************************/

static int get_autocommit_mode()
{
	int autocommit_mode;
	GUI_DBG(("get_autocommit_mode()\n"));

	FIg_get_state(se_form, SE_AUTOCOMMIT_CHECK, &autocommit_mode);

	GUI_DBG(("get_autocommit_mode:returning %d\n", autocommit_mode));
	return autocommit_mode;
}

/******************************************************************************/

static void	update_autocommit_mode(
	int autocommit_mode)
{
	GUI_DBG(("update_l_mode(autocommit_mode:%s)\n",
		autocommit_mode ? "ON" : "OFF"));

	FIg_set_state(se_form, SE_AUTOCOMMIT_CHECK, autocommit_mode);

	GUI_DBG(("update_autocommit_mode:returning\n"));
}

/******************************************************************************/

static int get_autorename_mode()
{
	int autorename_mode;
	GUI_DBG(("get_autorename_mode()\n"));

	FIg_get_state(se_form, SE_AUTORENAME_CHECK, &autorename_mode);

	GUI_DBG(("get_autorename_mode:returning %d\n", autorename_mode));
	return autorename_mode;
}

/******************************************************************************/

static void	update_autorename_mode(
	int autorename_mode)
{
	GUI_DBG(("update_l_mode(autorename_mode:%s)\n",
		autorename_mode ? "ON" : "OFF"));

	FIg_set_state(se_form, SE_AUTORENAME_CHECK, autorename_mode);

	GUI_DBG(("update_autorename_mode:returning\n"));
}

/******************************************************************************/

static int get_enable_dbms()
{
	int i;
	int state;
	int	enable_dbms = 0;

	GUI_DBG(("get_enable_dbms()\n"));

	for (i = 0; i < dbms_info_cnt; i++)
	{
		FIg_get_state(se_form, dbms_info[i].label, &state);
		if (state)
		{
			enable_dbms |= dbms_info[i].bitmask;
		}
	}
	GUI_DBG(("get_enable_dbms:returning enable_dbms:%d\n", enable_dbms));
	return enable_dbms;
}

/******************************************************************************/

static void update_enable_dbms(
	int enable_dbms)
{
	int i;

	GUI_DBG(("update_enable_dbms(enable_dbms:0x%x)\n", enable_dbms));

	for (i = 0; i < dbms_info_cnt; i++)
	{
		FIg_set_state(se_form, dbms_info[i].label,
			enable_dbms & dbms_info[i].bitmask);
	}
	GUI_DBG(("update_enable_dbms:returning\n"));
}

/******************************************************************************/

extern int RISgui_se_form_displayed()
{
	int	form_displayed = 0;

	GUI_DBG(("RISgui_se_form_displayed()\n"));

	if (se_form)
	{
		FIf_is_displayed(se_form, &form_displayed);
	}

	GUI_DBG(("RISgui_se_form_displayed: returning form_displayed:%d\n",
		form_displayed));
	return(form_displayed);
}

/******************************************************************************/

static void display_se_form(
	modes_s *modes)
{
	int		sts;

	GUI_DBG(("display_se_form(modes:0x%x)\n", modes));

	if (!se_form)
	{
		sts = FIf_new(SE_FORM, SE_FORM_FILE, RISgui_notification_routine,
			&se_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_CREATE_SE_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("display_se_form:returning\n"));
			return;
		}
		RISgui_center_form(se_form);
	}
	se_msg->str[0] = 0;
	se_msg->count = 0;
	se_msg->msg_fld_label = SE_MESSAGE_FIELD;
	se_msg->fp = se_form;

	if (!RISgui_se_form_displayed())
	{
		sts = FIf_display(se_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_DISPLAY_SE_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("display_se_form:returning\n"));
			return;
		}
	}

	update_ansi_mode(modes->ansi);
	update_verify_mode(modes->verify);
	update_blankstrip_mode(modes->blankstrip);
	update_autocommit_mode(modes->autocommit);
	update_autorename_mode(modes->autorename);
	update_enable_dbms(modes->enable_dbms);

	CLEAR_ERROR;

	GUI_DBG(("display_se_form:returning\n"));
	return;
}

/******************************************************************************/

extern void RISgui_erase_se_form()
{
	int	sts;

	GUI_DBG(("RISgui_erase_se_form()\n"));

	if (RISgui_se_form_displayed())
	{
		sts = FIf_erase(se_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_ERASE_SE_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("RISgui_erase_se_form: returning\n"));
			return;
		}
	}

	CLEAR_ERROR;

	GUI_DBG(("RISgui_erase_se_form: returning\n"));
	return;
}

/******************************************************************************/

extern void RISgui_process_se_form(
	int	g_label)
{
	GUI_DBG(("RISgui_process_se_form(g_label:%d)\n", g_label));

	switch(g_label)
	{
		case FI_ACCEPT:
			if (!get_enable_dbms())
			{
				strcpy(se_msg->str,MSG(RISUTL_I_ONE_DBTYPE_MUST_BE_SPEC));
				break;
			}
			RISgui_erase_se_form();	
			exit_status = 1;
			break;

		case FI_CANCEL:
			RISgui_erase_se_form();	
			exit_status = 0;
			break;
	}

	GUI_DBG(("RISgui_process_se_form:returning\n"));
}

/******************************************************************************/

extern int RISgui_get_set_modes(
	modes_s *modes)
{
	exit_status = 0;
	GUI_DBG(("RISgui_get_set_modes()\n"));

	display_se_form(modes);

	RISgui_event_loop(RISgui_se_form_displayed);

	if (exit_status)
	{
		modes->ansi = get_ansi_mode();
		modes->verify = get_verify_mode();
		modes->blankstrip = get_blankstrip_mode();
		modes->autocommit = get_autocommit_mode();
		modes->autorename = get_autorename_mode();
		modes->enable_dbms = get_enable_dbms();
	}

	GUI_DBG(("RISgui_get_set_modes:returning exit_status:%d\n",
		exit_status));
	return exit_status;
}

/******************************************************************************/
