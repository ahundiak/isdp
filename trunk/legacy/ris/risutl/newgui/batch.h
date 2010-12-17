/* Do not alter this SPC information: $Revision: 1.3.32.1 $ */
/********************************************************************
Name:				batch.h
Authors:       Rick Kramer
Creation Date: 03/28/95
Description:   Header file for Batch utility

Revision History:

********************************************************************/
#define ALL_INTERACTIVE 0
#define ALL_FILE			1
#define OUT_FILE_ONLY	2
#define IN_FILE_ONLY		3

typedef struct _batch_globals
{
   char szAppName[80];
   char szTitle[80];
   HICON hIcon;
	HMENU hMenu;
   int argc;
   char **argv;
   HWND hIntro;
	int index;
	char szInitialDir[_MAX_PATH];
	char szInputFile[_MAX_PATH];
	char szOutputFile[_MAX_PATH];
	char szComFile[_MAX_PATH];
	int nMode;
}  batch_globals;
batch_globals batch;

