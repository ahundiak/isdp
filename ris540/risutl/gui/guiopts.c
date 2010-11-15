/* Do not alter this SPC information: $Revision: 1.2.40.1 $ */
/*
**	NAME:							guiopts.c
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

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define guiopts_c
#include "fi.prt"
#include "event.prt"
#include "comdebug.prt"
#include "guierror.prt"
#include "guiin.prt"
#include "guintfy.prt"
#include "guiopts.prt"
#include "sys.prt"
#if defined(WIN32)
#include "fi_winnt.prt"
#endif

/*
**	VARIABLES
*/
static	Form	op_form = 0;
static	int		exit_status;

/*
**	FUNCTIONS
*/

/******************************************************************************/

static void	update_h_scroll_mode(
	int h_scroll_mode)
{
	GUI_DBG(("update_h_scroll_mode(h_scroll_mode:%s)\n",
		h_scroll_mode ? "H_SCROLL_CHAR" : "H_SCROLL_COL"));

	if (h_scroll_mode == H_SCROLL_COL)
	{
		FIg_set_state(op_form, OP_BY_COLUMN_CHECK, 1);
	}
	else
	{
		FIg_set_state(op_form, OP_BY_CHAR_CHECK, 1);
	}

	GUI_DBG(("update_h_scroll_mode:returning\n"));
}

/******************************************************************************/

static int get_h_scroll_mode()
{
	int state;
	int h_scroll_mode;

	GUI_DBG(("get_h_scroll_mode()\n"));
	FIg_get_state(op_form, OP_BY_COLUMN_CHECK, &state);
	if (state)
	{
		h_scroll_mode = H_SCROLL_COL;
	}
	else
	{
		h_scroll_mode = H_SCROLL_CHAR;
	}

	GUI_DBG(("get_h_scroll_mode:returning h_scroll_mode:%d\n", h_scroll_mode));
	return h_scroll_mode;
}

/******************************************************************************/

static void	update_fetch_mode(
	int fetch_mode)
{
	GUI_DBG(("update_fetch_mode(fetch_mode:%d)\n", fetch_mode));

	switch (fetch_mode)
	{
		case FETCH_SCREEN_APPEND:
			FIg_set_state(op_form, OP_SCREEN_APPEND_CHECK, 1);
			break;
		case FETCH_SCREEN_OVERWRITE:
			FIg_set_state(op_form, OP_SCREEN_OVERWRITE_CHECK, 1);
			break;
		case FETCH_ALL_ROWS:
			FIg_set_state(op_form, OP_ALL_ROWS_CHECK, 1);
			break;
	}

	GUI_DBG(("update_fetch_mode:returning\n"));
}

/******************************************************************************/

static int get_fetch_mode()
{
	int state;
	int fetch_mode;

	GUI_DBG(("get_fetch_mode()\n"));
	FIg_get_state(op_form, OP_SCREEN_APPEND_CHECK, &state);
	if (state)
	{
		fetch_mode = FETCH_SCREEN_APPEND;
	}
	else
	{
		FIg_get_state(op_form, OP_SCREEN_OVERWRITE_CHECK, &state);
		if (state)
		{
			fetch_mode = FETCH_SCREEN_OVERWRITE;
		}
		else
		{
			fetch_mode = FETCH_ALL_ROWS;
		}
	}

	GUI_DBG(("get_fetch_mode:returning fetch_mode:%d\n", fetch_mode));
	return fetch_mode;
}

/******************************************************************************/

extern int RISgui_op_form_displayed()
{
	int	form_displayed = 0;

	GUI_DBG(("RISgui_op_form_displayed()\n"));

	if (op_form)
	{
		FIf_is_displayed(op_form, &form_displayed);
	}

	GUI_DBG(("RISgui_op_form_displayed: returning form_displayed:%d\n",
		form_displayed));
	return(form_displayed);
}

/******************************************************************************/

static void display_op_form(
	options_s *options)
{
	int		sts;

	GUI_DBG(("display_op_form(options:0x%x)\n", options));

	if (!op_form)
	{
		sts = FIf_new(OP_FORM, OP_FORM_FILE, RISgui_notification_routine,
			&op_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_CREATE_OP_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("display_op_form:returning\n"));
			return;
		}
		FIg_disable(op_form,OP_BY_CHAR_CHECK);
		FIg_disable(op_form,OP_BY_COLUMN_CHECK);
		RISgui_center_form(op_form);
	}

	if (!RISgui_op_form_displayed())
	{
		sts = FIf_display(op_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_DISPLAY_OP_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("display_op_form:returning\n"));
			return;
		}
	}

	update_h_scroll_mode(options->h_scroll_mode);
	update_fetch_mode(options->fetch_mode);

	CLEAR_ERROR;

	GUI_DBG(("display_op_form:returning\n"));
	return;
}

/******************************************************************************/

extern void RISgui_erase_op_form()
{
	int	sts;

	GUI_DBG(("RISgui_erase_op_form()\n"));

	if (RISgui_op_form_displayed())
	{
		sts = FIf_erase(op_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_ERASE_OP_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("RISgui_erase_op_form: returning\n"));
			return;
		}
	}

	CLEAR_ERROR;

	GUI_DBG(("RISgui_erase_op_form: returning\n"));
	return;
}

/******************************************************************************/

extern void RISgui_process_op_form(
	int	g_label)
{
	GUI_DBG(("RISgui_process_op_form(g_label:%d)\n", g_label));

	switch(g_label)
	{
		case FI_CANCEL:
			RISgui_erase_op_form();	
			exit_status = 0;
			break;

		case FI_ACCEPT:
			RISgui_erase_op_form();	
			exit_status = 1;
			break;
	}

	GUI_DBG(("RISgui_process_op_form:returning\n"));
}

/******************************************************************************/

extern int RISgui_get_options(
	options_s *options)
{
	exit_status = 0;
	GUI_DBG(("RISgui_get_options()\n"));

	display_op_form(options);

	RISgui_event_loop(RISgui_op_form_displayed);

	if (exit_status)
	{
		options->h_scroll_mode = get_h_scroll_mode();
		options->fetch_mode = get_fetch_mode();
	}

	GUI_DBG(("RISgui_get_options:returning exit_status:%d\n",
		exit_status));
	return exit_status;
}

/******************************************************************************/
