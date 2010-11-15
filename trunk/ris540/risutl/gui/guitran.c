/* Do not alter this SPC information: $Revision: 1.2.40.1 $ */
/*
**	NAME:							guitran.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					5/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
**
**	11/94:	Added support for INTERNATIONALIZATION.  Rick Kramer
*/
 
/*
**	INCLUDES
*/
#include "rislimit.h"
#include "gui.h"

/*
**	DEFINES
*/
#define COMMIT_WORK		0
#define ROLLBACK_WORK	1

#define TR_ERROR		-1
#define TR_CANCEL		0
#define TR_ACCEPT		1

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define guitran_c
#include "fi.prt"
#include "event.prt"
#include "comdebug.prt"
#include "guierror.prt"
#include "guiexec.prt"
#include "guintfy.prt"
#include "guitran.prt"
#include "guiin.prt"
#include "sys.prt"
#include "ris.prt"
#if defined(WIN32)
#include "fi_winnt.prt"
#endif

/*
**	VARIABLES
*/
static	Form	tr_form = 0;
static	int		exit_status;
static	int		mode;

/*
**	FUNCTIONS
*/

/******************************************************************************/

static int tr_form_displayed()
{
	int	form_displayed = 0;

	GUI_DBG(("tr_form_displayed()\n"));

	if (tr_form)
	{
		FIf_is_displayed(tr_form, &form_displayed);
	}

	GUI_DBG(("tr_form_displayed: returning form_displayed:%d\n",
		form_displayed));
	return(form_displayed);
}

/******************************************************************************/

static void display_tr_form(
	char *schname)
{
	int		sts;

	GUI_DBG(("display_tr_form(schname:<%s>)\n", STRING(schname)));

	if (!tr_form)
	{
		sts = FIf_new(TR_FORM, TR_FORM_FILE, RISgui_notification_routine,
			&tr_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_CREATE_TR_FORM, sts);
			RISgui_report_error();
			exit_status = TR_ERROR;
			GUI_DBG(("display_tr_form:returning\n"));
			return;
		}
		RISgui_center_form(tr_form);
	}

	if (!tr_form_displayed())
	{
		FIg_set_text(tr_form, TR_SCHNAME_FIELD, schname);
		FIg_set_state(tr_form,
			mode == COMMIT_WORK ? TR_COMMIT_CHECK : TR_ROLLBACK_CHECK, 1);

		sts = FIf_display(tr_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_DISPLAY_TR_FORM, sts);
			RISgui_report_error();
			exit_status = TR_ERROR;
			GUI_DBG(("display_tr_form:returning\n"));
			return;
		}
	}

	CLEAR_ERROR;

	GUI_DBG(("display_tr_form:returning\n"));
	return;
}

/******************************************************************************/

extern void erase_tr_form()
{
	int	sts;

	GUI_DBG(("erase_tr_form()\n"));

	if (tr_form_displayed())
	{
		sts = FIf_erase(tr_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_ERASE_TR_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("erase_tr_form: returning\n"));
			return;
		}
	}

	CLEAR_ERROR;

	GUI_DBG(("erase_tr_form: returning\n"));
	return;
}

/******************************************************************************/

extern void RISgui_process_tr_form(
	int	g_label)
{
	GUI_DBG(("RISgui_process_tr_form(g_label:%d)\n", g_label));


	switch (g_label)
	{
		case TR_COMMIT_CHECK:
			mode = COMMIT_WORK;
			break;

		case TR_ROLLBACK_CHECK:
			mode = ROLLBACK_WORK;
			break;

		case FI_ACCEPT:
			erase_tr_form();
			exit_status = TR_ACCEPT;
			break;

		case FI_CANCEL:
			erase_tr_form();
			exit_status = TR_CANCEL;
			break;
	}

	GUI_DBG(("RISgui_process_tr_form:returning\n"));
}

/******************************************************************************/

extern int RISgui_close_transactions()
{
	int i;
	int count;
	char command[80];
	char (*buffer)[RIS_MAX_ID_SIZE] = NULL;

	GUI_DBG(("RISgui_close_transactions()\n"));

	count = 0;
	RISget_schema_transactions(buffer, &count);
	if (SQLCODE != RIS_SUCCESS)
	{
/*		RISgui_errhandle(SQLCODE, 0); */
/*		RISgui_report_error(); */
		GUI_DBG(("RISgui_close_transactions: get_transactions error: returning 1\n"));
		return 1;
	}

	if (count == 0)
	{
		GUI_DBG(("RISgui_close_transactions: no transactions: returning 1\n"));
		return 1;
	}

	buffer = (char (*)[RIS_MAX_ID_SIZE])malloc(count * RIS_MAX_ID_SIZE);
	RISget_schema_transactions(buffer, &count);
	if (SQLCODE != RIS_SUCCESS)
	{
		RISgui_errhandle(SQLCODE, 0);
		RISgui_report_error();
		if (buffer)
		{
			free(buffer);
		}
		GUI_DBG(("RISgui_close_transactions: get_transactions error: returning 1\n"));
		return 1;
	}

	for (i = 0; i < count; i++)
	{
		mode = COMMIT_WORK;
		exit_status = TR_ACCEPT;
		display_tr_form(buffer[i]);
		RISgui_event_loop(tr_form_displayed);
		switch(exit_status)
		{
			case TR_ACCEPT:
				sprintf(command, "%s for %s",
					mode == COMMIT_WORK ? "commit" : "rollback", buffer[i]);
				RISgui_execute_command(command);
				if (SQLCODE != RIS_SUCCESS)
				{
					RISgui_errhandle(SQLCODE, 0);
					RISgui_report_error();
					if (buffer)
					{
						free(buffer);
					}
					GUI_DBG(("RISgui_close_transactions: %s failed: returning 1\n",
						command));
					return 1;
				}
				break;

			case TR_ERROR:
				if (buffer)
				{
					free(buffer);
				}
				GUI_DBG(("RISgui_close_transactions: error: returning 1\n"));
				return 1;

			case TR_CANCEL:
				if (buffer)
				{
					free(buffer);
				}
				GUI_DBG(("RISgui_close_transactions: cancel: returning 0\n"));
				return 0;
		}
	}

	if (buffer)
	{
		free(buffer);
	}

	GUI_DBG(("RISgui_close_transactions:returning 1\n"));
	return 1;
}

/******************************************************************************/
