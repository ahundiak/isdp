/* Do not alter this SPC information: $Revision: 1.1.31.1 $ */
/********************************************************************
Name:				plbck.h
Authors:       Rick Kramer
Creation Date: 03/28/95
Description:   Header file for Playback utility

Revision History:

********************************************************************/
typedef struct _plbck_globals
{
   char szAppName[80];
   char szTitle[80];
   HICON hIcon;
   int argc;
   char **argv;
   HWND hIntro;
	BOOL fReadFile;
	BOOL fImmPlayback;
	BOOL fCommandTimes;
	BOOL fDelayTimes;
	BOOL fTotalTime;
	BOOL fBlob;
	BOOL fVerbose;
	char szInputFile[_MAX_PATH];
	char szOutputFile[_MAX_PATH];
	int index;
	char szInitialDir[_MAX_PATH];
	int nSS;
	int nSD;
	int nSE;
	int nDS;
	int nDD;
	int nDE;
	int nES;
	int nED;
	int nEE;
}  plbck_globals;
plbck_globals plbck;

