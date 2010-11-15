/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							edtwin32.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					2/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <stdio.h>
#include <io.h>
#include <string.h>
#include "edit.h"

/*
**	DEFINES
*/
#define BACKGROUND_WHITE  (WORD) 0x00f0
#define BACKGROUND_CYAN   (WORD) 0x0030
#define FOREGROUND_YELLOW (WORD) 0x0006
#define FOREGROUND_CYAN   (WORD) 0x0003
#define FOREGROUND_WHITE  (WORD) 0x0007
#define MSG_BUF_SIZE 512

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define edtwin32_c
#include "edtwin32.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern int getinput(
	HANDLE hStdIn)
{
	int				c = 0;
	BOOL			bSuccess;
	DWORD			dwInputEvents; /* number of events actually read */
	INPUT_RECORD	inputBuffer;

	while(c == 0)
	{
		/*
		**	read an input event from the input event queue
		*/
		bSuccess = ReadConsoleInput(hStdIn, &inputBuffer, 1, &dwInputEvents);
		PERR(bSuccess, "ReadConsoleInput");
		if (inputBuffer.EventType == KEY_EVENT)
		{
			if (((inputBuffer.Event.KeyEvent.dwControlKeyState &
					RIGHT_CTRL_PRESSED) ||
				(inputBuffer.Event.KeyEvent.dwControlKeyState &
					LEFT_CTRL_PRESSED)) &&
				inputBuffer.Event.KeyEvent.uChar.AsciiChar == 0x03)
			{
				c = EOF;
			}
			else if (inputBuffer.Event.KeyEvent.bKeyDown)
			{
				c = inputBuffer.Event.KeyEvent.uChar.AsciiChar;
			}
		}
	}

	return c;
}

/******************************************************************************/

extern void perr(
	PCHAR	szFileName,
	int		line,
	PCHAR	szApiName,
	DWORD	dwError)
{
	printf("\nFILE:\"%s\" LINE:%d FUNCTION:\"%s\" ERROR:%d\n\n",
		szFileName, line, szApiName, dwError);
}

/******************************************************************************/

extern void save_restore_cursor(
	int mode)
{
	BOOL bSuccess;
	static CONSOLE_SCREEN_BUFFER_INFO info;

	switch(mode)
	{
		case SAVE_CURSOR_MODE:
  			bSuccess = GetConsoleScreenBufferInfo(hStdOut, &info);
  			PERR(bSuccess, "GetConsoleScreenBufferInfo");
  			break;

		case RESTORE_CURSOR_MODE:
  			bSuccess = SetConsoleCursorPosition(hStdOut, info.dwCursorPosition);
  			PERR(bSuccess, "SetConsoleCursorPosition");
  			break;
	}
}

/******************************************************************************/

extern void hide_show_cursor(
	int mode)
{
	BOOL bSuccess;
	CONSOLE_CURSOR_INFO info;

	bSuccess = GetConsoleCursorInfo(hStdOut, &info);
  	PERR(bSuccess, "GetConsoleCursorInfo");

	if (info.bVisible != mode)
	{
		bSuccess = SetConsoleCursorInfo(hStdOut, &info);
  		PERR(bSuccess, "SetConsoleCursorInfo");
	}
}

/******************************************************************************/

extern void set_cursor(
	int row,
	int col)
{
	BOOL bSuccess;
	COORD pos;

	pos.X = (short)col;
	pos.Y = (short)row;
	bSuccess = SetConsoleCursorPosition(hStdOut, pos);
  	PERR(bSuccess, "SetConsoleCursorPosition");
}

/******************************************************************************/

extern void clr_to_eol()
{
	DWORD count;
	BOOL bSuccess;
	DWORD cCharsWritten;
	CONSOLE_SCREEN_BUFFER_INFO info;

	bSuccess = GetConsoleScreenBufferInfo(hStdOut, &info);
	PERR(bSuccess, "GetConsoleScreenBufferInfo");

	count = info.dwSize.X - info.dwCursorPosition.X;

	bSuccess = FillConsoleOutputCharacter(hStdOut, (TCHAR) ' ',
		count, info.dwCursorPosition, &cCharsWritten);
	PERR(bSuccess, "FillConsoleOutputCharacter");

	bSuccess = SetConsoleCursorPosition(hStdOut, info.dwCursorPosition);
  	PERR(bSuccess, "SetConsoleCursorPosition");
}

/******************************************************************************/

extern void clr_to_eob()
{
	DWORD count;
	BOOL bSuccess;
	DWORD cCharsWritten;
	CONSOLE_SCREEN_BUFFER_INFO info;

	bSuccess = GetConsoleScreenBufferInfo(hStdOut, &info);
	PERR(bSuccess, "GetConsoleScreenBufferInfo");

	count = (info.dwSize.X - info.dwCursorPosition.X) +
		((info.dwSize.Y - info.dwCursorPosition.Y + 1) * info.dwSize.X);

	bSuccess = FillConsoleOutputCharacter(hStdOut, (TCHAR) ' ',
		count, info.dwCursorPosition, &cCharsWritten);
	PERR(bSuccess, "FillConsoleOutputCharacter");

	bSuccess = SetConsoleCursorPosition(hStdOut, info.dwCursorPosition);
  	PERR(bSuccess, "SetConsoleCursorPosition");
}

/******************************************************************************/

extern void move_cursor(
	int direction,
	int count)
{
	BOOL bSuccess;
	CONSOLE_SCREEN_BUFFER_INFO info;

	bSuccess = GetConsoleScreenBufferInfo(hStdOut, &info);
	PERR(bSuccess, "GetConsoleScreenBufferInfo");

	switch(direction)
	{
		case MOVE_CURSOR_UP:
			info.dwCursorPosition.Y -= count;
			break;
		case MOVE_CURSOR_DOWN:
			info.dwCursorPosition.Y += count;
			break;
		case MOVE_CURSOR_RIGHT:
			info.dwCursorPosition.X += count;
			break;
		case MOVE_CURSOR_LEFT:
			info.dwCursorPosition.X -= count;
			break;
	}

	bSuccess = SetConsoleCursorPosition(hStdOut, info.dwCursorPosition);
  	PERR(bSuccess, "SetConsoleCursorPosition");
}

/******************************************************************************/
