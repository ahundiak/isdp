/* Do not alter this SPC information: $Revision: 1.1.53.1 $ */

/* Copyright (c) 1989, 1990, 1991, 1992, 1993, 1994
 * Intergraph Corporation; All Rights Reserved
 * Including Application Programs, File Formats, and Visual Displays
 *
 * from "Undocumented Windows" (Addison-Wesley, 1992)
 * by Andrew Schulman, Dave Maxey and Matt Pietrek.
 * Copyright (c) Dave Maxey and Andrew Schulman 1991-1992. All rights reserved.
*/

/******************************************************************************
	File Name:		winarg.c
	Author:			Rick Kramer
	Description:	This program is for winmain startup.
	Change History:
******************************************************************************/
#include "windows.h"
#include <stdlib.h>
#include <string.h>
#include "winio.h"
#include "winparse.h"

#define MAIN_BUFFER 64512

int argc;
char **argv;

extern _CRTIMP int __argc;
extern _CRTIMP char **__argv;

extern int main(int argc, char **argv);

void getexefilename(HANDLE hInst, char *strName);

HANDLE __hInst;
HANDLE __hPrevInst;
LPSTR __lpCmdLine;
int __nCmdShow;
HWND __hMainWnd;
WORD __hAppTimer;
char __szModule[9] = {0};

int PASCAL WinMain(HANDLE hInstance, HANDLE hPrevInstance, 
	LPSTR lpCmdLine, int nCmdShow)
{
	int ret;
    
	__hInst = hInstance;
	__hPrevInst = hPrevInstance;
	__lpCmdLine = lpCmdLine;
	__nCmdShow = nCmdShow;
    
	getexefilename(__hInst, __szModule);
	winio_about(__szModule);    // default; can override
    
	if (! winio_init())
	{
		winio_warn(FALSE, __szModule, "Could not initialize");
		return 1;
	}
    
	if (__hMainWnd = winio_window((LPSTR) NULL, MAIN_BUFFER,
		WW_HASMENU | WW_EXITALLOWED))
	{
		// App timer to allow multitasking
		__hAppTimer = SetTimer(NULL, 0xABCD, 100, NULL);
    
		winio_setcurrent(__hMainWnd);
        
		argc = ParseCommandLine(hInstance, lpCmdLine, &argv);
		ret = main(argc, argv);

		winio_end();
    
		if (__hAppTimer)
			KillTimer(NULL, __hAppTimer);
	}
	else
	{
		winio_warn(FALSE, __szModule, "Could not create main window");
		ret = -1;
	}
    
	return ret;
}


void getexefilename(HANDLE hInst, char *strName)
{
	char str[128];
	char *p;

	// can use hInst as well as hMod (GetExePtr does the trick)
	GetModuleFileName(hInst, str, 128);
	p = &str[strlen(str) - 1];
    
	for ( ; (p != str) && (*p != '\\'); p--)
		if (*p == '.') *p = 0;
        
	strcpy(strName, *p == '\\' ? ++p : p);
}
    
