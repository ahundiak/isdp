/*
**	NAME:			upgpaswd.c
**	AUTHORS:		Terrence McIntyre
**	CREATION DATE:		1/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/

/*
**	INCLUDES
*/
#include <stdio.h>
#if defined(WIN32) || defined(DOS)
# include <conio.h>
#endif
#if defined(unix)
# include <sys/stat.h>
#endif
#include "risupg.h"

/*
**	DEFINES
*/
#define CTRL_H		8
#define CTRL_Z		26
#define DEL		127
#if defined(WIN32) || defined(DOS)
# define NEWLINE	13
#else
# define NEWLINE	'\n'
#endif

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define upgpaswd_c
#include "upgterm.prt"
#include "sys.prt"
#if defined(sco) || defined(DOS) || defined(WIN32) || defined(WIN32S) || defined(vms)
# include "sysalloc.prt"
#endif
#include "upgpaswd.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISupg_get_password(
	char *prompt,
	char *s,
	int len)
{
	char ch;
	char *ptr = s;
	int ok_to_loop = 1;

	if (prompt && *prompt)
	{
		printf("%s",prompt);
	}

#if defined(unix)
	RISupg_set_terminal_noecho_raw();
#endif

	while (ok_to_loop)
	{
#if defined(WIN32) || defined(DOS)
		ch = _getch();
#endif
#if defined(unix)
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
					printf("\nMaximum password length (%d) exceeded, "
						"truncating to %d characters", len - 1, len - 1);
					ok_to_loop = 0;
					break;
				}
				break;
		}
	}
	printf("\n");
#if defined(unix)
	RISupg_reset_terminal();
#endif
}

/******************************************************************************/
