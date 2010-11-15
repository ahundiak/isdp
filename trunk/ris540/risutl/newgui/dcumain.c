/* Do not alter this SPC information: $Revision: 1.1.29.1 $ */
/********************************************************************
Name:				dcumain.c
Authors:       Rick Kramer
Creation Date: 03/28/95
Description:   Main program for Dcode Utility

Revision History:

********************************************************************/
#include <windows.h>
#include <windowsx.h>
#include <stdio.h>
#include <locale.h>
#include "gco.h"
#include "dcode.h"
#include "resource.h"

#define dcumain_c
#include "dcumain.prt"
#include "gcosbar.prt"
#include "gcortns.prt"
#include "gcodbg.prt"
#include "gcordbg.prt"
#include "gcotmess.prt"

gco_globals gco;


int PASCAL WinMain (HANDLE hInstance, HANDLE hPrevInstance,
	LPSTR lpszCmdLine, int nCmdShow)
{
	WNDCLASS    wndclass ; // the window class

	setlocale(LC_ALL, "");

	strcpy(dcode.szAppName,"RISdcode");
	gco.hhInst = hInstance;

	// get handle to risres.dll
	gco.hhLib = _LoadResources(dcode.szAppName);
	if (!gco.hhLib)
	{
		return (FALSE);
	}

	dcode.argc = _ParseCommandLine(hInstance, lpszCmdLine, &dcode.argv);

	strcpy(dcode.szTitle,_GetResourceString (gco.hhLib,IDS_DCODE_DESC));

	if (!hPrevInstance)    // load data into window class struct. 
	{
		wndclass.style         = CS_HREDRAW | CS_VREDRAW ;
		wndclass.lpfnWndProc   = DefDlgProc ;
		wndclass.cbClsExtra    = 0 ;
		wndclass.cbWndExtra    = DLGWINDOWEXTRA ;
		wndclass.hInstance     = hInstance ;
		wndclass.hIcon			  = LoadIcon(gco.hhInst, MAKEINTRESOURCE(IDI_DCODE));
		wndclass.hCursor       = LoadCursor (NULL, IDC_ARROW) ;
		wndclass.hbrBackground = (HBRUSH)(COLOR_WINDOW+1);
		wndclass.lpszMenuName  = NULL ;
		wndclass.lpszClassName = dcode.szAppName;

      dcode.hIcon = wndclass.hIcon;
      gco.hCursor = wndclass.hCursor;

		// register the window class 
		if (!RegisterClass (&wndclass))
		{
			MessageBox(NULL,"RegisterClass() failed",dcode.szTitle,MB_OK | MB_TASKMODAL | MB_ICONSTOP);
			return FALSE ;
		}
	}
	DialogBox (gco.hhInst, MAKEINTRESOURCE(IDD_DCODE), NULL,(DLGPROC)DlgProc) ;

	FreeLibrary(gco.hhLib);
	return FALSE ;
}

static BOOL Cls_OnInitDialog(HWND hwnd, HWND hwndFocus, LPARAM lParam)
{
	char wrk[255];

	//Initialize
	_AddUtilityMenu(hwnd, 2);
	_AddHelpMenu(hwnd);
	_InitDebug(dcode.argc,dcode.argv,hwnd, dcode.szAppName);
	_InitProgram(dcode.argc,dcode.argv);
	gco.hhAccel = LoadAccelerators(gco.hhInst,dcode.szAppName);
	if (!gco.hhAccel)
	{
		_MessageBox (NULL,gco.hhLib,MB_OK | MB_TASKMODAL | MB_ICONSTOP,IDS_DCODE_DESC,IDS_ACCEL_FAIL);
		return FALSE;
	}
	dcode.hMenu = GetMenu(hwnd);

	GetClassName(hwnd,wrk,sizeof(wrk));
	_Debug(PROG,2,"OnInitDialog: Dcode hwnd=%08X class=<%s>",hwnd,wrk); 
	_Debug(PROG,2,"OnInitDialog: IDC_DCODE_VALUE=%08X id=%d",GetDlgItem(hwnd,IDC_DCODE_VALUE),IDC_DCODE_VALUE);
	_Debug(PROG,2,"OnInitDialog: IDC_DCODE_DESC=%08X id=%d",GetDlgItem(hwnd,IDC_DCODE_DESC),IDC_DCODE_DESC);

//	Edit_SetText(GetDlgItem(hwnd,IDC_DCODE_VALUE), "200");
//	Edit_SetText(GetDlgItem(hwnd,IDC_DCODE_DESC), "RIS Information: STATEMENT NOT COMPLETE (200)\r\n\r\nAsynchronous statement not complete.");
Button_Enable(GetDlgItem(hwnd,IDOK), FALSE);

	SetFocus(GetDlgItem(hwnd,IDC_DCODE_VALUE));

	if (!_InitStatusBar (hwnd))
	{
		_MessageBox (NULL,gco.hhLib,MB_OK | MB_TASKMODAL | MB_ICONSTOP,IDS_DCODE_DESC,IDS_SBAR_FAIL);
		return FALSE;
	}

	_CenterWindowOnScreen(hwnd);
	return FALSE ;
}

static void Cls_OnCommand(HWND hwnd, int id, HWND hwndCtl, UINT codeNotify)
{
	char wrk[255];
	char wrk1[255];
HWND hwnd1;
int nDlgID;

	switch (id)
	{
		case IDC_DCODE_VALUE:
			if (Edit_GetTextLength(GetDlgItem(hwnd,IDC_DCODE_VALUE)) >0)
				Button_Enable(GetDlgItem(hwnd,IDOK), TRUE);
			else
				Button_Enable(GetDlgItem(hwnd,IDOK), FALSE);
			break;

		case IDOK:
			Edit_GetText(GetDlgItem(hwnd,IDC_DCODE_VALUE), wrk, 255);
			_Debug(PROG,2,"Dcode value = <%s>",wrk);

			sprintf(wrk1,"RIS Information: DCODE DESCRIPTION (%s)\r\n\r\nDCODE Wording",wrk);
			Edit_SetText(GetDlgItem(hwnd,IDC_DCODE_DESC), wrk1);

			break;

		case IDM_FILE_EXIT:
			SendMessage(hwnd,WM_CLOSE,0L,0L);
			break;

		case IDM_UTIL_DCODE:
		case IDM_UTIL_CLNSR:
		case IDM_UTIL_DTYPE:
		case IDM_UTIL_RECRD:
		case IDM_UTIL_PLBCK:
		case IDM_UTIL_UNLOD:
		case IDM_UTIL_LOD:
		case IDM_UTIL_BATCH:
		case IDM_UTIL_GUI:
		case IDM_UTIL_MGR:
			_RunUtility(id);
			break;

		case IDM_HELP_PROGRAM:
		case IDM_HELP_CONTENTS:
		case IDM_HELP_SEARCH:
		case IDM_HELP_USE:
		case IDM_HELP_PRODUCT_SUPPORT:
		case IDM_HELP_ABOUT:
			_RunHelp(id,hwnd,dcode.szTitle,dcode.szAppName,dcode.hIcon);
			break;

		case IDM_RIS_DEBUG:
			DialogBox(gco.hhLib, MAKEINTRESOURCE(IDD_RISDBG),hwnd, (DLGPROC)RISdebug);
			break;

		case IDM_GUI_DEBUG:
					_UpdateStatusBar("Selected DEBUG");
					_DEBUG(PROG,2,"Selected Debug");
					_DebugControlPanel( gco.hhLib,hwnd,FALSE );
			break;

		case IDM_EDIT_CUT:
hwnd1 = GetFocus();
nDlgID=GetDlgCtrlID(hwnd1);
_Debug(PROG,2,"OnCommand-CUT: hwnd1=%08X is id %d",hwnd1,nDlgID);
			if (nDlgID == IDC_DCODE_VALUE)
				SendMessage(hwnd1,WM_CUT,0,0L);
			break;

		case IDM_EDIT_COPY:
hwnd1 = GetFocus();
nDlgID=GetDlgCtrlID(hwnd1);
_Debug(PROG,2,"OnCommand-COPY: hwnd1=%08X is id %d",hwnd1,nDlgID);
			if (nDlgID == IDC_DCODE_VALUE)
				SendMessage(hwnd1,WM_COPY,0,0L);
			else if (nDlgID == IDC_DCODE_DESC)
				SendMessage(hwnd1,WM_COPY,0,0L);
			break;

					case IDM_EDIT_PASTE:
hwnd1 = GetFocus();
nDlgID=GetDlgCtrlID(hwnd1);
_Debug(PROG,2,"OnCommand-PASTE: hwnd1=%08X is id %d",hwnd1,nDlgID);
			if (nDlgID == IDC_DCODE_VALUE)
				SendMessage(hwnd1,WM_PASTE,0,0L);
			break;

	}

}

static void Cls_OnTimer(HWND hwnd, UINT id)
{
	if (id == 1)
		_UpdateStatusBarTime();
}

static void Cls_OnSize(HWND hwnd, UINT state, int cx, int cy)
{
	_AdjustStatusBar (hwnd);
}


static void Cls_OnClose(HWND hwnd)
{
	WinHelp(hwnd,"risutl.hlp",HELP_QUIT,0L);
	KillTimer(hwnd,1);
	DestroyIcon(dcode.hIcon);
	 _TimedMsgBox(gco.hhLib, hwnd, "Clean up RIS (RIS_terminate)","Temporary",MB_OK | MB_ICONINFORMATION , IDS_DCODE_DESC, 1);
	EndDialog (hwnd, 0) ;
}

static void Cls_OnMenuSelect(HWND hwnd, HMENU hmenu, int item, HMENU hmenuPopup, UINT flags)
{
	char szMsg[255];

	_DEBUG(PROG,2,"Item = %d",item);
	strcpy(szMsg, _GetResourceString(gco.hhLib,item));
	_UpdateStatusBar(szMsg);
	UpdateDcodeMenu(hwnd);
}

static LRESULT CALLBACK DlgProc (HWND hwnd, UINT iMessage, WPARAM wParam, LPARAM lParam)
{
	switch (iMessage)
	{
		HANDLE_MSG(hwnd,WM_INITDIALOG,Cls_OnInitDialog);
		HANDLE_MSG(hwnd,WM_TIMER,Cls_OnTimer);
		HANDLE_MSG(hwnd,WM_SIZE,Cls_OnSize);
		HANDLE_MSG(hwnd,WM_MENUSELECT,Cls_OnMenuSelect);
		HANDLE_MSG(hwnd,WM_COMMAND,Cls_OnCommand);
		HANDLE_MSG(hwnd,WM_CLOSE,Cls_OnClose);
	}
	return FALSE ;
}

static void UpdateDcodeMenu(HWND hwnd)
{
	LONG l;
	WORD status = TRUE;
	WORD status1 = TRUE;

	//If edit control is non-empty, allow cut/copy/clear
	l = Edit_GetSel(GetDlgItem(hwnd,IDC_DCODE_VALUE));
	if ( HIWORD(l) == LOWORD(l) )
		status = FALSE;

	l = Edit_GetSel(GetDlgItem(hwnd,IDC_DCODE_DESC));
	if ( HIWORD(l) == LOWORD(l) )
		status1 = FALSE;

	if ( (status ==FALSE) && (status1 == FALSE) )
	{
		EnableMenuItem (dcode.hMenu, IDM_EDIT_CUT, MF_BYCOMMAND | MF_GRAYED);
		EnableMenuItem (dcode.hMenu, IDM_EDIT_COPY, MF_BYCOMMAND | MF_GRAYED);
	}
	else
	{
		EnableMenuItem (dcode.hMenu, IDM_EDIT_CUT, MF_BYCOMMAND | MF_ENABLED);
		EnableMenuItem (dcode.hMenu, IDM_EDIT_COPY, MF_BYCOMMAND | MF_ENABLED);
	}

	// If the clipboard contains some CF_TEXT data, allow paste
	status = FALSE;
	if (OpenClipboard (hwnd))
	{
		UINT wFmt = 0;

		while (wFmt = EnumClipboardFormats (wFmt))
			if (wFmt == CF_TEXT)
			{
				status = TRUE;
				break;
			}

		CloseClipboard ();
	}
	if (status == TRUE)
		EnableMenuItem (dcode.hMenu, IDM_EDIT_PASTE, MF_BYCOMMAND | MF_ENABLED);
	else
		EnableMenuItem (dcode.hMenu, IDM_EDIT_PASTE, MF_BYCOMMAND | MF_GRAYED);
}
