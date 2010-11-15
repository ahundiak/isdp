/* Do not alter this SPC information: $Revision: 1.2.9.1 $ */
/*
**	NAME:							btcterm.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					6/87
**	ABSTRACT:
**		Contains termination and signal handling initialization routine
**		USED ONLY BY THE RIS PROGRAM.  The general signal handling routine
**		for RIS is elsewhere.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "batch.h"
#if defined(WIN32S)
#include <windows.h>
#include <windowsx.h>
#include "winport.h"
#include "winio.h"
#include "winhan.h"
#include "prog32s.h"
#endif

/*
**	FUNCTION PROTOTYPES
*/
#define btcterm_c
#include "btcmain.prt"
#include "btcterm.prt"
#include "comdebug.prt"
#include "utlprint.prt"
#include "ris.prt"
#include "sys.prt"


/*
**	DEFINES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISutl_terminate(
	void)
{
	RISutl_printf("\n");

#if defined(WIN32S)
#else
	RISutl_close_files();
#endif
#ifdef WIN32
	/*
	**	Added to fix data server hanging problem (TR#439502817)
	**				-Goverdhan    11/7
	*/
	BTC_DBG(("Sleep for a second\n"));
	_sleep(1000);
	BTC_DBG(("Finished sleeping\n"));
#endif
	RISterminate();
#if defined(WIN32S)
	if (RISbtc_mode != BATCH_MODE)
	{
	 PRINTF("Program Terminated\n");
	winio_end();
	}
#else
	exit(0);
#endif
}

/******************************************************************************/
