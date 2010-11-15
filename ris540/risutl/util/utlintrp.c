/* Do not alter this SPC information: $Revision: 1.2.26.1 $ */
/*
**	NAME:							utlintrp.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					2/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#if defined(unix) || defined(DOS)
#include <signal.h>
#endif
#if defined(WIN32)
#include <windows.h>
#endif
#include "util.h"

/*
**	FUNCTION PROTOTYPES
*/
#define utlintrp_c
#include "utlintrp.prt"
#include "comjmp.prt"
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

#if defined(unix)
static void handle_int()
{
	SET_INTERRUPT();
}
#endif

#if defined(WIN32)
static BOOL	WINAPI handle_int(
	DWORD	dwCtrlType)
{
	if (dwCtrlType == CTRL_C_EVENT)
	{
		SET_INTERRUPT();
		return TRUE;
	}
	return FALSE;
}
#endif

#if defined(DOS)
static void handle_int()
{
	signal(SIGINT,SIG_IGN);/* ignore further SIGINT */
	SET_INTERRUPT();
}
#endif

/******************************************************************************/

extern void RISutl_init_interrupt()
{
#if defined(unix)
	if (sigset(SIGINT,(void (*)())handle_int) == SIG_ERR)
	{
		LONGJMP(RISUTL_E_SIGSET);
	}
#endif
#if defined(WIN32)
	if (SetConsoleCtrlHandler(handle_int, TRUE) == FALSE)
	{
		LONGJMP(RISUTL_E_SIGSET);
	}
#endif
#if defined(DOS)
	if (signal(SIGINT,handle_int) == SIG_ERR)
	{
		LONGJMP(RISUTL_E_SIGSET);
	}
#endif
}


/******************************************************************************/

extern void RISutl_reset_interrupt()
{
#if defined(unix)
	sigset(SIGINT,SIG_DFL);
#endif
#if defined(WIN32)
	SetConsoleCtrlHandler(handle_int, TRUE);
#endif
#if defined(DOS)
	signal(SIGINT,handle_int);
#endif
}

/******************************************************************************/
