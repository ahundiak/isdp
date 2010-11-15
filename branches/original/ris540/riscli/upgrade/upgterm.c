/*
**	NAME:							upgterm.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					1/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/

/*
**	INCLUDES
*/
#if defined(unix)
# include <termio.h>
#endif
#if defined(WIN32)
# include <windows.h>
#endif
#if defined(unix) || defined(WIN32)
# include <stdio.h>
# include <sys/types.h>
#endif
#include "risupg.h"

/*
**	DEFINES
*/
#define PERR(bSuccess, api) {if (!(bSuccess)) perr(__FILE__, __LINE__, \
    api, GetLastError());}

/*
** The system header file <sys/ioccom.h>" which has the defn. for
** _IOR and _IOW macro is messed up. As the result TCGETA and TCSETA
** in <termio.h> which uses these macros, gets messed up and ioctl()
** call fails. So, we need to use these alternate macros until the
** system header files are straightened up.    Surjit,Sanju  2/14/95
*/
#if defined(sun)
# if defined(_IOR)
#  undef _IOR
#  define _IOR(x,y,t) (_IOC_OUT|((sizeof(t)&_IOCPARM_MASK)<<16)|('T'<<8)|y)
# endif
# if defined(_IOW)
#  undef _IOW
#  define _IOW(x,y,t) (_IOC_IN|((sizeof(t)&_IOCPARM_MASK)<<16)|('T'<<8)|y)
# endif
#endif /* sun */

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define upgterm_c
#include "wrap.prt"
#if defined(DOS) || defined(WIN32) || defined(WIN32S) || defined(vms)
#include "sysalloc.prt"
#endif

#include "upgterm.prt"

/*
**	VARIABLES
*/
#if defined(WIN32)
static DWORD dwMode;
#endif

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISupg_set_terminal_noecho_raw()
{
#if defined(unix)
	struct termio termdata;
#endif
#if defined(WIN32)
	BOOL bSuccess;
	HANDLE hStdIn;
#endif

#if defined(unix)
	/* set io to no echo, no buffer */
	ioctl(0, TCGETA, &termdata);
	termdata.c_lflag &= ~ICANON & ~ECHO;
	termdata.c_cc[4] = 1;
	ioctl(0, TCSETA, &termdata);
#endif

#if defined(WIN32)
	/* get the standard handles */
	hStdIn = GetStdHandle(STD_INPUT_HANDLE);
	PERR(hStdIn != INVALID_HANDLE_VALUE, "GetStdHandle");

	/* set up mouse and window input */
	bSuccess = GetConsoleMode(hStdIn, &dwMode);
	PERR(bSuccess, "GetConsoleMode");
	/* when turning off ENABLE_LINE_INPUT, you MUST also turn off */
	/* ENABLE_ECHO_INPUT. */
	bSuccess = SetConsoleMode(hStdIn, (dwMode & ~(ENABLE_LINE_INPUT |
		ENABLE_ECHO_INPUT)) | ENABLE_WINDOW_INPUT | ENABLE_MOUSE_INPUT);
	PERR(bSuccess, "SetConsoleMode");
#endif
}

/******************************************************************************/

extern void RISupg_reset_terminal()
{
#if defined(unix)
	struct termio termdata;
#endif
#if defined(WIN32)
	BOOL bSuccess;
	HANDLE hStdIn;
#endif

#if defined(unix)
	/* set io to echo, buffer */
	ioctl(0, TCGETA, &termdata);
	termdata.c_lflag |= ICANON | ECHO;
	termdata.c_cc[4] = 4;
	ioctl(0, TCSETA, &termdata);
#endif
#if defined(WIN32)
	/* get the standard handles */
	hStdIn = GetStdHandle(STD_INPUT_HANDLE);
	PERR(hStdIn != INVALID_HANDLE_VALUE, "GetStdHandle");

	bSuccess = SetConsoleMode(hStdIn, dwMode);
	PERR(bSuccess, "SetConsoleMode");
#endif
}

/******************************************************************************/

#if defined(WIN32)
static void perr(
	PCHAR	szFileName,
	int		line,
	PCHAR	szApiName,
	DWORD	dwError)
{
	printf("\nFILE:\"%s\" LINE:%d FUNCTION:\"%s\" ERROR:%d\n\n",
		szFileName, line, szApiName, dwError);
}
#endif

/******************************************************************************/
