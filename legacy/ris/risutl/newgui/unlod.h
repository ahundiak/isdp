/* Do not alter this SPC information: $Revision: 1.1.31.1 $ */
/********************************************************************
Name:				unlod.h
Authors:       Rick Kramer
Creation Date: 03/28/95
Description:   Header file for Unloader utility

Revision History:

********************************************************************/
typedef struct _unlod_globals
{
   char szAppName[80];
   char szTitle[80];
   HICON hIcon;
   int argc;
   char **argv;
   HWND hIntro;
	int index;
	char szInitialDir[_MAX_PATH];
	char mainfile[_MAX_PATH];
	int nTabDef;
	int nDataFiles;
	int nDataFormat;
	int nFileMode;
	int nPreserve;
	char szSchemas[3][80];
	char szViews[3][80];
	char szPrivs[3][80];
	char szTabs[3][80];
	char szIndexs[3][80];
}  unlod_globals;
unlod_globals unlod;

