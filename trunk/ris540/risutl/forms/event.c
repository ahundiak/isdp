/* Do not alter this SPC information: $Revision: 1.2.51.1 $ */
/*
**	NAME:							event.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					8/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#if defined(__clipper__)
#include <tools.h>
#elif defined(WIN32)
#elif defined(__hpux__)
#else
ERROR -- NO CODE
#endif
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
#define event_c
#include "comdebug.prt"
#include "event.prt"
#include "env5.prt"
#include "fi.prt"
#if defined(__clipper__)
#include "fi_env5.prt"
#elif defined(WIN32)
#include "fi_winnt.prt"
#else
ERROR -- NO CODE
#endif

/*
**	VARIABLES
*/
#if defined(WIN32)
static HCURSOR hCursor = 0;
#elif defined(__clipper__)
#else
ERROR -- NO CODE
#endif


/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISfrm_event_loop(
	int (* form_displayed)())
{
#if defined(__clipper__)
	int event;
#elif defined(WIN32)
	MSG event;
#else
ERROR -- NO CODE
#endif
	FRM_DBG(("RISfrm_event_loop()\n"));

	if (!form_displayed)
	{
		FRM_DBG(("RISfrm_event_loop:no function pointer: returning\n"));
		return;
	}

	while(form_displayed())
	{
#if defined(__clipper__)
		Wait_for_next(FI_EVENT_MASK, &event);	
		if (!FI_process_event(event))
		{
			FI_clear_event(event);
		}
#elif defined(WIN32)
		GetMessage(&event, NULL, 0, 0);
		FI_process_event(&event);
#else
ERROR -- NO CODE
#endif
	}

	FRM_DBG(("RISfrm_event_loop:returning\n"));
}

/******************************************************************************/

extern void RISfrm_hourglass_cursor(
	Form fp)
{
#if defined(__clipper__)
	int wno;

	static int hotspotx = 7;
	static int hotspoty = 13;
	static long enable_pattern[] =
	{
		0x00007fff, 0x00007fff, 0x00007fff, 0x00003ffe,
		0x00003ffe, 0x00003ffe, 0x00003ffe, 0x00003ffe,
		0x00003ffe, 0x00001ffc, 0x00000ff8, 0x000007f0,
		0x000003e0, 0x000003e0, 0x000003e0, 0x000007f0,
		0x00000ff8, 0x00001ffc, 0x00003ffe, 0x00003ffe,
		0x00003ffe, 0x00003ffe, 0x00003ffe, 0x00003ffe,
		0x00007fff, 0x00007fff, 0x00007fff, 0x00000000,
		0x00000000, 0x00000000, 0x00000000, 0x00000000
	};
	static long data_pattern[] =
	{
		0x00000000, 0x00000000, 0x00001ffc, 0x00000000,
		0x00000ff8, 0x00000ff8, 0x00000df8, 0x00000aa8,
		0x00000d58, 0x000006b0, 0x00000360, 0x000001c0,
		0x00000080, 0x00000080, 0x00000080, 0x000001c0,
		0x000003e0, 0x00000770, 0x00000ff8, 0x00000f78,
		0x00000eb8, 0x00000d58, 0x00000aa8, 0x00000000,
		0x00001ffc, 0x00000000, 0x00000000, 0x00000000,
		0x00000000, 0x00000000, 0x00000000, 0x00000000
	};
#elif defined(WIN32)
	static HCURSOR hHourglass = 0;
#else
ERROR -- NO CODE
#endif

	FRM_DBG(("RISfrm_hourglass_cursor(fp:0x%x)\n", fp));

#if defined(__clipper__)
	FIf_get_window(fp, &wno);
	if (wno >= 0)
	{
		defcursor(wno, enable_pattern, data_pattern, hotspotx, hotspoty);
	}
#elif defined(WIN32)
	if (hHourglass == 0)
	{
		hHourglass = LoadCursor(NULL, IDC_WAIT);
	}
	hCursor = SetCursor(hHourglass);
#else
ERROR -- NO CODE
#endif

	FRM_DBG(("RISfrm_hourglass_cursor:returning\n"));
}

/******************************************************************************/

extern void RISfrm_default_cursor(
	Form fp)
{
#if defined(__clipper__)
	int wno;

	static int hotspotx = 1;
	static int hotspoty = 1;

	static long enable_pattern[] =
	{
		0x00000003, 0x0000000f, 0x0000003e, 0x000000fe,
		0x000003fc, 0x00000ffc, 0x00003ff8, 0x0000fff8,
		0x0003fff0, 0x000ffff0, 0x003fffe0, 0x00ffffe0,
		0x03ffffc0, 0x0fffffc0, 0x3fffff80, 0x7fffff80,
		0x3fffff00, 0x0001ff00, 0x0001fe00, 0x0001fe00,
		0x0001fc00, 0x0001fc00, 0x0001f800, 0x0001f800,
		0x0001f000, 0x0001f000, 0x0001e000, 0x0001e000,
		0x0001c000, 0x0001c000, 0x00008000, 0x00000000
	};

	static long data_pattern[] =
	{
		0x00000000, 0x00000002, 0x00000004, 0x00000018,
		0x00000078, 0x000001f0, 0x000007f0, 0x00001fe0,
		0x00007fe0, 0x0001ffc0, 0x0007ffc0, 0x001fff80,
		0x007fff80, 0x01ffff00, 0x07ffff00, 0x1ffffe00,
		0x0000fe00, 0x0000fc00, 0x0000fc00, 0x0000f800,
		0x0000f800, 0x0000f000, 0x0000f000, 0x0000e000,
		0x0000e000, 0x0000c000, 0x0000c000, 0x00008000,
		0x00008000, 0x00000000, 0x00000000, 0x00000000
	};
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

	FRM_DBG(("RISfrm_default_cursor(fp:0x%x)\n",fp));

#if defined(__clipper__)
	FIf_get_window(fp, &wno);
	if (wno >= 0)
	{
		defcursor(wno, enable_pattern, data_pattern, hotspotx, hotspoty);
	}
#elif defined(WIN32)
	if (hCursor)
	{
		SetCursor(hCursor);
	}
#else
ERROR -- NO CODE
#endif

	FRM_DBG(("RISfrm_default_cursor:returning\n"));
}

/******************************************************************************/
