/* Do not alter this SPC information: $Revision: 1.4.27.1 $ */
/********************************************************************
Name:		dtype.h
Authors:	Alan Barksdale
Creation Date:	03/28/95
Description:	Header file for Schema Manager utility

Revision History:

********************************************************************/

// constants

#define BAD_DIALOG_BOX (-1)

#define DEBUG_MESSAGE_BOX( \
	message_dmb) \
\
	MessageBoxEx(NULL,(message_dmb),"debug", \
		MB_OK | MB_TASKMODAL | MB_ICONINFORMATION, \
		MAKELANGID(LANG_NEUTRAL,SUBLANG_DEFAULT));
// DEBUG_MESSAGE_BOX


// Declarations

gco_globals gco;

typedef struct _mgr_globals
{
	char szAppName[80];
	char szTitle[80];
	HICON hIcon;
	int argc;
	char **argv;
	HWND hIntro;

/*
	LONG dlgBaseUnits;
*/
}	mgr_globals;
mgr_globals mgr;
