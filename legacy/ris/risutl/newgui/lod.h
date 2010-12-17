/* Do not alter this SPC information: $Revision: 1.2.30.1 $ */
/********************************************************************
Name:				lod.h
Authors:       Rick Kramer
Creation Date: 03/28/95
Description:   Header file for Loader utility

Revision History:

********************************************************************/
typedef struct _lod_globals
{
   char szAppName[80];
   char szTitle[80];
   HICON hIcon;
   HWND hIntro;
   int argc;
   char **argv;
	int nAnsi;
	int nPreserve;
	char szDelim[2];
	char szInterval[5];
	int nFileMode;
	char szDB[9][80];
	int nDB[9];
	char szInputFile[_MAX_PATH];
	char szLogFile[_MAX_PATH];
	char szBadFile[_MAX_PATH];
	char szSchemas[3][80];
	char szViews[3][80];
	char szPrivs[3][80];
	char szTabs[3][80];
	char szIndexs[3][80];
	int nTabDef;
	int nTabExist;
	int nClear;
	int input_index;
	char szInputInitialDir[_MAX_PATH];
	int log_index;
	char szLogInitialDir[_MAX_PATH];
	int bad_index;
	char szBadInitialDir[_MAX_PATH];
}  lod_globals;
lod_globals lod;

