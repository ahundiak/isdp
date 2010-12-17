/* Do not alter this SPC information: $Revision: 1.2.40.1 $ */
/*
**	NAME:							guishtr.c
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
#define guishtr_c
#include "fi.prt"
#include "event.prt"
#include "comdebug.prt"
#include "guierror.prt"
#include "guintfy.prt"
#include "guishtr.prt"
#include "guiin.prt"
#include "sys.prt"
#include "ris.prt"
#if defined(WIN32)
#include "fi_winnt.prt"
#endif

/*
**	VARIABLES
*/
static	Form	st_form = 0;

/*
**	FUNCTIONS
*/

/******************************************************************************/

static void update_st_form()
{
	int i;
	int count;
	char (*buffer)[RIS_MAX_ID_SIZE] = NULL;

	GUI_DBG(("update_st_form()\n"));


	count = 0;
	RISget_schema_transactions(buffer, &count);
	if (SQLCODE != RIS_SUCCESS)
	{
		RISgui_errhandle(SQLCODE, 0);
		RISgui_report_error();
		FIfld_set_num_rows(st_form, ST_SCHNAME_FIELD, 0);
		GUI_DBG(("update_st_form: get_transactions error: returning\n"));
		return;
	}

	if (count == 0)
	{
		FIfld_set_num_rows(st_form, ST_SCHNAME_FIELD, 0);
		GUI_DBG(("update_st_form: no transactions: returning\n"));
		return;
	}

	buffer = (char (*)[RIS_MAX_ID_SIZE])malloc(count * RIS_MAX_ID_SIZE);
	RISget_schema_transactions(buffer, &count);
	if (SQLCODE != RIS_SUCCESS)
	{
		RISgui_errhandle(SQLCODE, 0);
		RISgui_report_error();
		FIfld_set_num_rows(st_form, ST_SCHNAME_FIELD, 0);
		if (buffer)
		{
			free(buffer);
		}
		GUI_DBG(("update_st_form: get_transactions error: returning\n"));
		return;
	}

	FIfld_set_num_rows(st_form, ST_SCHNAME_FIELD, count);
	for (i = 0; i < count; i++)
	{
		FIfld_set_text(st_form, ST_SCHNAME_FIELD, i, 0, buffer[i], 0);
	}

	GUI_DBG(("update_st_form:returning\n"));
}

/******************************************************************************/

static int st_form_displayed()
{
	int	form_displayed = 0;

	GUI_DBG(("st_form_displayed()\n"));

	if (st_form)
	{
		FIf_is_displayed(st_form, &form_displayed);
	}

	GUI_DBG(("st_form_displayed: returning form_displayed:%d\n",
		form_displayed));
	return(form_displayed);
}

/******************************************************************************/

static void display_st_form()
{
	int		sts;

	GUI_DBG(("display_st_form()\n"));

	if (!st_form)
	{
		sts = FIf_new(ST_FORM, ST_FORM_FILE, RISgui_notification_routine,
			&st_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_CREATE_ST_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("display_st_form:returning\n"));
			return;
		}
		RISgui_center_form(st_form);
	}

	if (!st_form_displayed())
	{
		update_st_form();

		sts = FIf_display(st_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_DISPLAY_ST_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("display_st_form:returning\n"));
			return;
		}
	}

	CLEAR_ERROR;

	GUI_DBG(("display_st_form:returning\n"));
	return;
}

/******************************************************************************/

extern void erase_st_form()
{
	int	sts;

	GUI_DBG(("erase_st_form()\n"));

	if (st_form_displayed())
	{
		sts = FIf_erase(st_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_ERASE_ST_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("erase_st_form: returning\n"));
			return;
		}
	}

	CLEAR_ERROR;

	GUI_DBG(("erase_st_form: returning\n"));
	return;
}

/******************************************************************************/

extern void RISgui_process_st_form(
	int	g_label)
{
	switch(g_label)
	{
		case FI_CANCEL:
			erase_st_form();
			break;
	}
	GUI_DBG(("RISgui_process_st_form:returning\n"));
}

/******************************************************************************/

extern void RISgui_show_transactions(
	void)
{
	GUI_DBG(("RISgui_show_transactions()\n"));

	display_st_form();

	RISgui_event_loop(st_form_displayed);

	GUI_DBG(("RISgui_show_transactions:returning\n"));
}

/******************************************************************************/
