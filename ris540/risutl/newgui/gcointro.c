/* Do not alter this SPC information: $Revision: 1.1.29.1 $ */
/********************************************************************
Name:				gcointro.c
Authors:       Rick Kramer
Creation Date: 03/28/95
Description:   Splash Screen Functions

Revision History:

********************************************************************/
#include <windows.h>
#include <windowsx.h>
#include <string.h>
#include <time.h>
#include <stdio.h>
#include "gcortns.h"
#include "gco.h"
#include "resource.h"

#define gcointro_c
#include "gcointro.prt"
#include "gcortns.prt"

typedef struct _intro_globals
{
	char desc[255];
	char caption[255];
	HICON hIcon;
}	intro_globals;
intro_globals intro;


/****************************************************************************
_Intro
****************************************************************************/
static LRESULT CALLBACK Intro(
	HWND hDlg,
	UINT wMessage,
	WPARAM wParam,
	LPARAM lParam)
{
	char wrk[255];
	char szModuleName[255];

	switch(wMessage)
	{
		case WM_INITDIALOG :
			EnableWindow(GetDlgItem(hDlg,IDOK),FALSE);
			ShowWindow(GetDlgItem(hDlg,IDOK),SW_HIDE);

			GetModuleFileName(gco.hhInst, szModuleName, sizeof(szModuleName));

			//Window Title
			SetWindowText(hDlg, intro.caption);
	
			// File Description
			SetDlgItemText(hDlg, IDC_ABOUT_DESC, (LPSTR)intro.desc);


			// File Version
			_GetVersionInfo(szModuleName,VERSION_FILEVERSION,wrk);
			SetDlgItemText(hDlg, IDC_ABOUT_VER, (LPSTR)wrk);

			// icon
			Static_SetIcon(GetDlgItem(hDlg,IDC_ABOUT_ICON), intro.hIcon);

			// Copyright
			_GetVersionInfo(szModuleName,VERSION_LEGALCOPYRIGHT,wrk);
			SetDlgItemText(hDlg, IDC_ABOUT_CR, (LPSTR)wrk);

			// Trademarks
			_GetVersionInfo(szModuleName,VERSION_LEGALTRADEMARKS,wrk);
			SetDlgItemText(hDlg, IDC_ABOUT_TM, (LPSTR)wrk);

			_CenterWindowOnScreen (hDlg);
			return TRUE;
			break;

		default:
			return FALSE;
	}

}

/****************************************************************************
_CreateSplashScreen
****************************************************************************/
extern HWND _CreateSplashScreen(
	HWND hwnd,
	char *desc,
	char *caption,
	HICON IconName)
{
	HWND hDlgAbout;

	strcpy(intro.desc,desc);
	strcpy(intro.caption,_GetResourceString(gco.hhLib,IDS_ABOUT,caption));
	intro.hIcon = IconName;

	hDlgAbout = CreateDialog(gco.hhLib,MAKEINTRESOURCE(IDD_ABOUT),0,(DLGPROC)Intro);
	ShowWindow(hDlgAbout,SW_SHOW);
	return(hDlgAbout);
}// _CreateSplashScreen

/****************************************************************************
_DestroySplashScreen
****************************************************************************/
extern void _DestroySplashScreen(
	HWND hwnd)
{
	DestroyWindow(hwnd);
}
