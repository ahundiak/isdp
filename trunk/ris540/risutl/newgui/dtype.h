/* Do not alter this SPC information: $Revision: 1.1.31.1 $ */
/********************************************************************
Name:		dtype.h
Authors:	Alan Barksdale
Creation Date:	03/28/95
Description:	Header file for Data Types utility

Revision History:

********************************************************************/

typedef struct _dtype_globals
{
	char szAppName[80];
	char szTitle[80];
	HICON hIcon;
	int argc;
	char **argv;
	HWND hIntro;
}	dtype_globals;
dtype_globals dtype;
