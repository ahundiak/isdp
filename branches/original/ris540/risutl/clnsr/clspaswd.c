/* Do not alter this SPC information: $Revision: 1.2.27.1 $ */
/*
**	NAME:							ucopaswd.c
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
#define clspaswd_c
#include "ucopaswd.prt"
#include "ucoterm.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISuco_get_password(
	char *prompt,
	char *s,
	int len)
{
	char ch;
	char *ptr = s;
	int ok_to_loop = 1;

	if (prompt && *prompt)
	{
		PRINTF("%s",prompt);
	}

#if defined(unix)
	RISuco_set_terminal_noecho_raw();
#endif

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
	PRINTF("\n");
#if defined(unix)
	RISuco_reset_terminal();
#endif
}

/******************************************************************************/