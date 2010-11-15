/* Do not alter this SPC information: $Revision: 1.1.29.1 $ */
/********************************************************************
Name:				recrd.c
Authors:       Rick Kramer
Creation Date: 03/28/95
Description:   Main program for Record Utility

Revision History:

********************************************************************/
#include <windows.h>
#include <windowsx.h>
#include <locale.h>
#include "gco.h"
#include "recrd.h"
#include "resource.h"

#define rcmain_c
#include "rcmain.prt"
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
	HWND hwnd;

	setlocale(LC_ALL, "");

	gco.hhInst = hInstance;
	strcpy(recrd.szAppName,"RISrecrd");

		// get handle to risres.dll
	gco.hhLib = _LoadResources(recrd.szAppName);
	if (!gco.hhLib)
	{
		return (FALSE);
	}
	recrd.argc = _ParseCommandLine(hInstance, lpszCmdLine, &recrd.argv);

	strcpy(recrd.szTitle,_GetResourceString (gco.hhLib,IDS_RECRD_DESC));

	hwnd = FindWindow (recrd.szAppName, NULL);
	if (hwnd)
	{
		MessageBox(NULL,"Application is already running; Switching to that instance",recrd.szAppName,MB_OK);
		// We found another version of ourself. Lets defer to it:
		if (IsIconic(hwnd))
		{
			ShowWindow(hwnd, SW_RESTORE);
		}
		SetForegroundWindow (hwnd);
		// If this app actually had any functionality, we would
		// also want to communicate any action that our 'twin'
		// should now perform based on how the user tried to
		// execute us.
		return FALSE;
	}


	if (!hPrevInstance)    // load data into window class struct. 
	{
		wndclass.style         = CS_HREDRAW | CS_VREDRAW ;
		wndclass.lpfnWndProc   = DefDlgProc ;
		wndclass.cbClsExtra    = 0 ;
		wndclass.cbWndExtra    = DLGWINDOWEXTRA ;
		wndclass.hInstance     = hInstance ;
		wndclass.hIcon			  = LoadIcon(gco.hhInst, MAKEINTRESOURCE(IDI_RECRD));
		wndclass.hCursor       = LoadCursor (NULL, IDC_ARROW) ;
		wndclass.hbrBackground = (HBRUSH)(COLOR_WINDOW+1);
		wndclass.lpszMenuName  = NULL ;
		wndclass.lpszClassName = recrd.szAppName;

      recrd.hIcon = wndclass.hIcon;
      gco.hCursor = wndclass.hCursor;

		// register the window class 
		if (!RegisterClass (&wndclass))
		{
			MessageBox(NULL,"RegisterClass() failed",recrd.szTitle,MB_OK | MB_TASKMODAL | MB_ICONSTOP);
			return FALSE ;
		}
	}

	DialogBox (gco.hhInst, MAKEINTRESOURCE(IDD_RECRD), NULL,(DLGPROC)DlgProc) ;

	FreeLibrary(gco.hhLib);
	return FALSE ;
}

static BOOL Cls_OnInitDialog(HWND hwnd, HWND hwndFocus, LPARAM lParam)
{
	HMENU hMenu;

	//Initialize
	_AddUtilityMenu(hwnd, 1);
	_AddHelpMenu(hwnd);
	_InitDebug( recrd.argc,recrd.argv,hwnd, recrd.szAppName );
	_InitProgram(recrd.argc,recrd.argv);

	// disable RISrecrd
	hMenu = GetMenu(hwnd);
	EnableMenuItem(hMenu,IDM_UTIL_RECRD,MF_DISABLED | MF_GRAYED | MF_BYCOMMAND);

_Debug(PROG,2,"Homedir=<%s>",_GetHomeDir(gco.hhInst));

	
	if (!_InitStatusBar (hwnd))
	{
		_MessageBox (NULL,gco.hhLib,MB_OK | MB_TASKMODAL | MB_ICONSTOP,IDS_RECRD_DESC,IDS_SBAR_FAIL);
		return FALSE;
	}
	Edit_SetText(GetDlgItem(hwnd,205), "c:\\tmp\\risrap.rap");
	Button_SetCheck(GetDlgItem(hwnd,200), FALSE);
	Button_SetCheck(GetDlgItem(hwnd,201), FALSE);
	Button_SetCheck(GetDlgItem(hwnd,202), FALSE);
	Button_SetCheck(GetDlgItem(hwnd,203), TRUE);
	Button_SetCheck(GetDlgItem(hwnd,208), TRUE);

	Button_Enable(GetDlgItem(hwnd,200), FALSE);
	Button_Enable(GetDlgItem(hwnd,201), FALSE);
	Button_Enable(GetDlgItem(hwnd,202), FALSE);
	Button_Enable(GetDlgItem(hwnd,203), FALSE);
	Edit_Enable(GetDlgItem(hwnd,205), FALSE);

	_CenterWindowOnScreen(hwnd);
	return TRUE ;
}

static void Cls_OnCommand(HWND hwnd, int id, HWND hwndCtl, UINT codeNotify)
{
	switch (id)
	{
		_Debug(PROG,2,"OnCommand: id=%d",id);

		case IDOK:
		   STARTWAIT;
			_Delay(4);
	   	ENDWAIT;
			break;

		case IDM_FILE_EXIT:
			SendMessage(hwnd,WM_CLOSE,0L,0L);
			break;

		case 208://off
			Button_Enable(GetDlgItem(hwnd,200), FALSE);
			Button_Enable(GetDlgItem(hwnd,201), FALSE);
			Button_Enable(GetDlgItem(hwnd,202), FALSE);
			Button_Enable(GetDlgItem(hwnd,203), FALSE);
			Edit_Enable(GetDlgItem(hwnd,205), FALSE);
			break;

		case 209://on
			Button_Enable(GetDlgItem(hwnd,200), TRUE);
			Button_Enable(GetDlgItem(hwnd,201), TRUE);
			Button_Enable(GetDlgItem(hwnd,202), TRUE);
			Button_Enable(GetDlgItem(hwnd,203), TRUE);
			Edit_Enable(GetDlgItem(hwnd,205), TRUE);
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
			_RunHelp(id,hwnd,recrd.szTitle,recrd.szAppName,recrd.hIcon);
			break;

		case IDM_RIS_DEBUG:
			DialogBox(gco.hhLib, MAKEINTRESOURCE(IDD_RISDBG),hwnd, (DLGPROC)RISdebug);
			break;

		case IDM_GUI_DEBUG:
					_UpdateStatusBar("Selected DEBUG");
					_DEBUG(PROG,2,"Selected Debug");
					_DebugControlPanel( gco.hhLib,hwnd,FALSE );
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
	DestroyIcon(recrd.hIcon);
	_TimedMsgBox(gco.hhLib, hwnd, "Clean up RIS (RIS_terminate)","Temporary",MB_OK | MB_ICONINFORMATION , IDS_RECRD_DESC, 1);

	EndDialog (hwnd, 0) ;
}

static void Cls_OnMenuSelect(HWND hwnd, HMENU hmenu, int item, HMENU hmenuPopup, UINT flags)
{
	char szMsg[255];

	_DEBUG(PROG,2,"OnMenuSelect: Item = %d",item);
	strcpy(szMsg, _GetResourceString(gco.hhLib,item));
	_UpdateStatusBar(szMsg);

}

static LRESULT CALLBACK DlgProc (HWND hwnd, UINT iMessage, WPARAM wParam, LPARAM lParam)
{
	switch (iMessage)
	{
		_Debug(PROG,2,"imessage=%d",iMessage);

		HANDLE_MSG(hwnd,WM_INITDIALOG,Cls_OnInitDialog);
		HANDLE_MSG(hwnd,WM_TIMER,Cls_OnTimer);
		HANDLE_MSG(hwnd,WM_SIZE,Cls_OnSize);
		HANDLE_MSG(hwnd,WM_MENUSELECT,Cls_OnMenuSelect);
		HANDLE_MSG(hwnd,WM_COMMAND,Cls_OnCommand);
		HANDLE_MSG(hwnd,WM_CLOSE,Cls_OnClose);
	}
	return FALSE ;
}







