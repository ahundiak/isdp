/* Do not alter this SPC information: $Revision: 1.1.29.1 $ */
/********************************************************************
Name:				gco.h
Authors:       Rick Kramer
Creation Date: 03/28/95
Description:   Header file for Utility Global Variables

Revision History:

********************************************************************/
#define PROG __FILE__,__LINE__
#define _DEBUG _Debug
#define IS_WIN32     -1
#define IS_DAYTONA   -2
#define IS_WIN32S    3
#define IS_CHICAGO   4

#define STARTWAIT gco.hCursor=SetCursor(LoadCursor(NULL,IDC_WAIT))
#define ENDWAIT SetCursor(gco.hCursor);

// Global variable declarations.
typedef struct _gco_globals
{
	HINSTANCE hhInst;     // The current instance handle
	HANDLE hhLib;
	HANDLE hhAccel;
   HCURSOR hCursor;
   FARPROC lpfnOldHook;           // Previous filter function
}	gco_globals;
extern gco_globals gco;


