/* Do not alter this SPC information: $Revision: 1.1.53.1 $ */
/*
**	NAME:							ucowinsz.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					5/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "windows.h"
#include "ucommon.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define ucowinsz_c
#include "ucowinsz.prt"
#include "comdebug.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISuco_set_window_size(
	int lines,
	int columns)
{
	HANDLE	hStdOut;
	CONSOLE_SCREEN_BUFFER_INFO info;

	UCO_DBG(("RISuco_set_window_size(lines:%d columns:%d)\n",
		lines, columns));

	if (lines > 0 || columns > 0)
	{
		if ((hStdOut = GetStdHandle(STD_OUTPUT_HANDLE)) != INVALID_HANDLE_VALUE)
		{
			if (GetConsoleScreenBufferInfo(hStdOut, &info) == TRUE)
			{
				if (lines > info.dwSize.Y)
				{
					info.dwSize.Y = lines;
				}
				if (columns > info.dwSize.X)
				{
					info.dwSize.X = columns;
				}
				SetConsoleScreenBufferSize(hStdOut, info.dwSize);
			}
		}
	}
	UCO_DBG(("RISuco_set_window_size: returning\n"));
}

/******************************************************************************/
