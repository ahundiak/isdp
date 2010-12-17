/* Do not alter this SPC information: $Revision: 1.1.31.1 $ */
/********************************************************************
Name:				recrd.h
Authors:       Rick Kramer
Creation Date: 03/28/95
Description:   Header file for Record utility

Revision History:

********************************************************************/
typedef struct _recrd_globals
{
	char szAppName[80];
	char szTitle[80];
	HICON hIcon;
	int argc;
	char **argv;
}	recrd_globals;
recrd_globals recrd;

