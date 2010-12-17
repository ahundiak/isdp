/* Do not alter this SPC information: $Revision: 1.2.51.1 $ */
/*
**	NAME:							xevent.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					8/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <X11/Xlib.h>
#include "forms.h"
#include "riscom.h"
#include "risver.h"
#include "risprods.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define xevent_c
#include "comdebug.prt"
#include "fi_xwin.prt"
#include "xevent.prt"
#include "xwin.prt"

/*
**	VARIABLES
*/
Display *RISdisplay;

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISfrm_event_loop(
	int (* form_displayed)())
{
    unsigned int trans = 0;
    XEvent event;

	FRM_DBG(("RISfrm_event_loop()\n"));

	if (!form_displayed)
	{
		FRM_DBG(("RISfrm_event_loop:no function pointer: returning\n"));
		return;
	}

	while(form_displayed())
	{
    	XNextEvent(RISdisplay, &event);
    	FI_process_event(&event, trans);
	}

	FRM_DBG(("RISfrm_event_loop:returning\n"));
}

/******************************************************************************/

extern void RISfrm_hourglass_cursor(
	Form fp)
{
	FRM_DBG(("RISfrm_hourglass_cursor(fp:0x%x)\n", fp));
	FRM_DBG(("RISfrm_hourglass_cursor:returning\n"));
}

/******************************************************************************/

extern void RISfrm_default_cursor(
	Form fp)
{
	FRM_DBG(("RISfrm_default_cursor(fp:0x%x)\n",fp));
	FRM_DBG(("RISfrm_default_cursor:returning\n"));
}

/******************************************************************************/
