/* Do not alter this SPC information: $Revision: 1.2.27.1 $ */
/*
**	NAME:							btcpaswd.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					1/93
**	ABSTRACT:
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
#include <stdio.h>
#if defined(WIN32) || defined(DOS)
#include <conio.h>
#endif
#include "risutl.h"
#if defined(WIN32S)
#include "prog32s.h"
#endif 

/*
**	DEFINES
*/
#define CTRL_H		8
#define CTRL_Z		26
#define DEL			127
#if defined(WIN32) || defined(DOS)
#define NEWLINE		13
#else
#define NEWLINE		'\n'
#endif

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define btcpaswd_c
#include "btcpaswd.prt"
#include "ucoterm.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISbtc_get_password(
	char *prompt,
	char *s,
	int len)
{
#if defined(WIN32S)
#else
	char ch;
#endif
	char *ptr = s;
	int ok_to_loop = 1;

	if (prompt && *prompt)
	{
		PRINTF("%s",prompt);
	}

#if defined(unix)
	RISuco_set_terminal_noecho_raw();
#endif

#if defined(WIN32S)
		GETS(s);
#else
	while (ok_to_loop)
	{
#if defined(WIN32) || defined(DOS)
		ch = _getch();
#elif defined(unix)
		ch = getchar();
#endif
		switch (ch)
		{
			case EOF:
			case CTRL_Z:
				*s = '\0';
				ok_to_loop = 0;
				break;

			case NEWLINE:
				*ptr = '\0';
				ok_to_loop = 0;
				break;

			case DEL:
			case CTRL_H:
				if (ptr > s)
					ptr--;
				break;

			default:
				*ptr++ = ch;
				if (ptr - s >= len)
				{
					*(ptr-1) = '\0';
					PRINTF("\nMaximum password length (%d) exceeded, "
						"truncating to %d characters", len - 1, len - 1);
					ok_to_loop = 0;
					break;
				}
				break;
		}
	}
#endif
	PRINTF("\n");
#if defined(unix)
	RISuco_reset_terminal();
#endif
}

/******************************************************************************/
