/* Do not alter this SPC information: $Revision: 1.1.31.1 $ */
/********************************************************************
Name:				dcode.h
Authors:       Rick Kramer
Creation Date: 03/28/95
Description:   Header file for Dcode utility

Revision History:

********************************************************************/
typedef struct _dcode_globals
{
	char szAppName[80];
	char szTitle[80];
	HICON hIcon;
	HMENU hMenu;
	int argc;
	char **argv;
}	dcode_globals;
dcode_globals dcode;

