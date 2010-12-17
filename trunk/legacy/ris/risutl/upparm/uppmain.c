/* Do not alter this SPC information: $Revision: 1.4.3.1 $ */
/*
**	NAME:							uppmain.c
**	AUTHORS:						Sanju Kapoor
**	CREATION DATE:					3/94
**	ABSTRACT:
**		This program upgrades the parameters file.
**
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#if defined(WIN32S)
#include <windows.h>
#include <windowsx.h>
#include "winport.h"
#include "winio.h"
#include "winhan.h"
#endif
#if !defined(WIN32S)
#include <stdio.h>
#endif
#include "risstjmp.h"
#include "ucommon.h"
#include "riscom.h"
#include "risver.h"
#include "risutl.h"
#include "util.h"
#if defined(WIN32S)
#include "prog32s.h"
#endif 


/*
**	DEFINES
*/
#define UMS_MASK	(INIT_UTL_UMS_FILE|INIT_RIS_UMS_FILE|INIT_NET_UMS_FILE)

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define uppmain_c
#include "uppmain.prt"
#include "ris.prt"
#include "sys.prt"
#include "comumsg.prt"
#include "comjmp.prt"
#include "ucoerrbx.prt"
#include "ucoumsg.prt"
#include "ucodebug.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/
static void DoVersion();

/*****************************************************************************/

/*
**  print out the syntax
*/
extern void syntax()
{
	PRINTF(MSG(RISUTL_I_UPGRADE_PARMS_USAGE));
}

/*****************************************************************************/

/*
** Main.
*/

extern int main(
	int argc,
	char *argv[])
{
	int		status;
#if defined(WIN32S)
	char about[128];
#endif


#if !defined(WIN32S)
	if (RISload_dll()) return(1);
#endif
	if ((status = SETJMP()) != 0)
	{
		RESETJMP();
#if defined(WIN32S)
		RISuco_file_error_box(NULL,RISUTL_I_UPGRADE_PARMS_ERROR,0,status,NULL,0,1);
#else
		RISuco_file_error_box(stdout,RISUTL_I_UPGRADE_PARMS_ERROR,0,status,NULL,0,1);
#endif
		PRINTF(CHECK_UNINIT_MSG(RISUTL_I_UPGRADE_PARMS_COULD_NOT_INIT,
			"RIS Upgrade Parameters File Utility could not initialize... Bye\n"));
		return 1;
	}

	RISuco_initialize_debug(NULL, 0);
	RISuco_initialize_ums(UMS_MASK);
#if defined(WIN32S)
	winio_setfont(winio_current(),ANSI_FIXED_FONT);
	sprintf(about,MSG(RISUTL_I_UPGRADE_PARMS_UTILITY), RIS_version);
	winio_about(about);
#endif

	--argc;	/* program name */

	if (argc == 0)
	{
		RISint_upgrade_parms_file();
	}
	else if (argc == 1)
	{
		if (strcmp(argv[1],"-?")==0)
		{
			syntax();
			return 0;
		}
			
		if (strcmp(argv[1],"-V")==0)
		{
			DoVersion();
			return 0;
		}
		else
		{
			syntax();
			PRINTF(MSG(RISUTL_I_UPGRADE_PARMS_ERROR));
			return 0;
		}
	}
	else 
	{
		PRINTF(MSG(RISUTL_I_UPGRADE_PARMS_ERROR));
		return 0;
	}


	RESETJMP();

	PRINTF(MSG(RISUTL_I_UPGRADE_PARMS_TAIL));
#if defined(WIN32S)
	winio_end();
#endif

	return 0;
}

/*****************************************************************************
DoVersion
*****************************************************************************/
static void DoVersion()
{
	/*PRINTF(MSG(RISUTL_I_COPYRIGHT));*/
	/* 1996.03.12:Alan Barksdale:TR439600483 */
	PRINTF(MSG(RISUTL_I_BEGIN_COPYRIGHT));
	PRINTF(" ");
	PRINTF(COPYRIGHTYEAR);
	PRINTF(", ");
	PRINTF(MSG(RISUTL_I_END_COPYRIGHT));
	PRINTF(MSG(RISUTL_I_UPGRADE_PARMS_UTILITY), RIS_version);
}
