/* Do not alter this SPC information: $Revision: 1.1.29.1 $ */
/********************************************************************
Name:				gcoabout.c
Authors:       Rick Kramer
Creation Date: 03/28/95
Description:   About Box Functions

Revision History:

********************************************************************/
#include <windows.h>
#include <windowsx.h>
#include <string.h>
#include <stdio.h>
#include "gco.h"
#include "resource.h"
#include "gcortns.h"

#define gcoabout_c
#include "gcoabout.prt"
#include "gcortns.prt"
#include "gcocred.prt"
#include "gcosbar.prt"

typedef struct _about_globals
{
	char desc[255];
	char caption[255];
	HICON hIcon;
}	about_globals;
about_globals about;


static BOOL Cls_OnInitDialog(
	HWND hDlg,
	HWND hwndFocus,
	LPARAM lParam)
{
	char wrk[255];
	char szModuleName[255];

	GetModuleFileName(gco.hhInst, szModuleName, sizeof(szModuleName));

	//Window Title
	SetWindowText(hDlg, about.caption);
	
	// File Description
	SetDlgItemText(hDlg, IDC_ABOUT_DESC, (LPSTR)about.desc);


	// File Version
	_GetVersionInfo(szModuleName,VERSION_FILEVERSION,wrk);
	SetDlgItemText(hDlg, IDC_ABOUT_VER, (LPSTR)wrk);

	// icon
	Static_SetIcon(GetDlgItem(hDlg,IDC_ABOUT_ICON), about.hIcon);

	// Copyright
	_GetVersionInfo(szModuleName,VERSION_LEGALCOPYRIGHT,wrk);
	SetDlgItemText(hDlg, IDC_ABOUT_CR, (LPSTR)wrk);

	// Trademarks
	_GetVersionInfo(szModuleName,VERSION_LEGALTRADEMARKS,wrk);
	SetDlgItemText(hDlg, IDC_ABOUT_TM, (LPSTR)wrk);


	_CenterWindow (hDlg, GetWindow (hDlg, GW_OWNER));

	return (TRUE);
}


static void Cls_OnCommand(
	HWND hwnd,
	int id,
	HWND hwndCtl,
	UINT codeNotify)
{
	switch (id)
	{
		case IDOK:
		{
			EndDialog(hwnd, TRUE);
		}
		break;
	}
}

static void Cls_OnRButtonDown(
	HWND hwnd,
	BOOL fDoubleClick,
	int x,
	int y,
	UINT keyFlags)
{
	char wrk[2048];

	strcpy(wrk,"");
	strcat(wrk, "Development Team:\r\n\r\n");
	strcat(wrk, "Rick Kramer, Lead Developer, and Acquirier of Software\r\n");
	strcat(wrk, "Alan Barksdale, Developer\r\n");
	strcat(wrk, "Adell Warren, Developer\r\n");
	strcat(wrk, "Brad Robbins, Product Manager\r\n");
	strcat(wrk, "and Paula wanted to but Brad wouldn't let her\r\n");
	strcat(wrk, "cause she needs to work on multi-threaded servers\r\n");
	strcat(wrk, "but would rather do these utilities...\0");

	_RollCredits(hwnd, wrk);
}


static LRESULT CALLBACK About(
	HWND hDlg,
	UINT uMessage,
	WPARAM wParam,
	LPARAM lParam)
{
	BOOL fProcessed = TRUE;

	switch (uMessage)
	{

		HANDLE_MSG(hDlg,WM_INITDIALOG,Cls_OnInitDialog);
		HANDLE_MSG(hDlg,WM_COMMAND,Cls_OnCommand);
		HANDLE_MSG(hDlg,WM_RBUTTONDOWN,Cls_OnRButtonDown);

		default:
			fProcessed = FALSE;
			break;
	}
	return fProcessed;
}


extern void _DisplayAboutBox(
	HWND hwnd,
	char *desc,
	char *caption,
	HICON IconName)
{
	strcpy(about.desc,desc);
	strcpy(about.caption,_GetResourceString(gco.hhLib,IDS_ABOUT,caption));
	about.hIcon = IconName;
	DialogBox(gco.hhLib, MAKEINTRESOURCE(IDD_ABOUT), hwnd, (DLGPROC)About);

}// _DisplayAboutBox
