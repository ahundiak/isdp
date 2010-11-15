/* Do not alter this SPC information: $Revision: 1.4.27.1 $ */
/********************************************************************
Name:		dtumain.c
Authors:	Alan Barksdale based on code from Rick Kramer
Creation Date:	03/01/95
Description:	Main program for Data Types Utility

Revision History:
	03/24/95 AFB   Added this header.
	04/06/95 AFB   Changed name from dtype.c at Rick Kramer's request.
	04/09/95 AFB   Added names and passwords dialog prototype.
********************************************************************/

#include <windows.h>
#include <windowsx.h>
#include <locale.h>
#include "gco.h"
#include "resource.h"
#include "dtype.h"

#define dtumain_c
#include "dtumain.prt"
#include "gcosbar.prt"
#include "gcortns.prt"
#include "gcodbg.prt"
#include "gcordbg.prt"
#include "gcointro.prt"
#include "gcotmess.prt"

gco_globals gco;

#define DELAY_TIME 1 //to be deleted

/********************************************************************
Function:      WinMain
Description:   Main function for utility
Variables:  hInstance Input, instance of the program
	    hPrevInstance Input, Previous instance
	    lpszCmdLine Input, Command line
	    nCmdShow Input, show flags

Return Value:  If the function succeeds, terminating when it receives a WM_QUIT message,
      it returns the exit value contained in that message's wParam parameter.
      If the function terminates before entering the message loop, it returns FALSE. 
********************************************************************/
int PASCAL WinMain(
	HINSTANCE hInstance,
	HINSTANCE hPrevInstance,
	LPSTR lpszCmdLine,
	int nCmdShow)
{
	WNDCLASS wndclass; // the window class

	DWORD dwLastError;
	char szLastError[80];

	// Used from a article in WindowsTech Magazine 7/92 by Charles Petzold
	setlocale(LC_ALL, "");

	gco.hhInst = hInstance;

	strcpy(dtype.szAppName,"RISdtype");

	// get handle to risres.dll
	gco.hhLib = _LoadResources(dtype.szAppName);
	if(!gco.hhLib)
	{
		return(0);
	}

	dtype.argc = _ParseCommandLine(hInstance,lpszCmdLine,&dtype.argv);
/*
MessageBoxEx(NULL,*dtype.argv,"debug",MB_OK | MB_TASKMODAL | MB_ICONINFORMATION,MAKELANGID(LANG_NEUTRAL,SUBLANG_DEFAULT));
*/


	strcpy(dtype.szTitle, _GetResourceString (gco.hhLib,IDS_DTYPE_DESC));

	if(!hPrevInstance) // load data into window class struct. 
	{
		wndclass.style		= CS_HREDRAW | CS_VREDRAW;
		wndclass.lpfnWndProc	= DefDlgProc;
		wndclass.cbClsExtra	= 0;
		wndclass.cbWndExtra	= DLGWINDOWEXTRA;
		wndclass.hInstance	= gco.hhInst;
		wndclass.hIcon		= LoadIcon(gco.hhInst,
						MAKEINTRESOURCE(IDI_DTYPE));
		wndclass.hCursor	= LoadCursor(NULL,IDC_ARROW);
		wndclass.hbrBackground	= (HBRUSH)(COLOR_WINDOW+1);
		wndclass.lpszMenuName	= NULL;
		wndclass.lpszClassName	= dtype.szAppName;

		dtype.hIcon = wndclass.hIcon;
		gco.hCursor = wndclass.hCursor;

		// register the window class 
		if(!RegisterClass(&wndclass))
		{
			MessageBox(NULL,"RegisterClass() failed",dtype.szTitle,
				MB_OK | MB_TASKMODAL | MB_ICONSTOP);
			return(0);
		}
	}

	dtype.hIntro= _CreateSplashScreen(NULL,dtype.szTitle,dtype.szAppName,
		dtype.hIcon);
	UpdateWindow(dtype.hIntro);

	if(-1 == DialogBox(gco.hhInst,MAKEINTRESOURCE(IDD_DTYPE),NULL,
		(DLGPROC)DlgProcDtype))
	{
		dwLastError = GetLastError();
                wsprintf(szLastError,"DialogBox() failed; GetLastError returned %#lx",
			dwLastError);
		MessageBox(NULL,szLastError,dtype.szTitle,
			MB_OK | MB_TASKMODAL | MB_ICONSTOP);
		return(0);
	}

	FreeLibrary(gco.hhLib);

	return(0);
} // WinMain

/*____________________________*/
/* Names and Passwords Dialog */
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvv*/

static void Cls_OnCommandNamesAndPasswds(
	HWND hDlg,
	int iId,
	HWND hDlgCtl,
	UINT codeNotify)
{
	_Debug(PROG,0,"enter Cls_OnCommandNamesAndPasswds");

	switch(iId)
	{
		_Debug(PROG,2,"iId=%d",iId);

		case IDCANCEL:
		case IDOK:
			EndDialog(hDlg,0);
		break;
		default:
			_Debug(PROG,2,"iId not expected");
		break;
	} // switch(iId)

	_Debug(PROG,0,"return Cls_OnCommandNamesAndPasswds");
} // Cls_OnCommandNamesAndPasswds

static BOOL Cls_OnInitDialogNamesAndPasswds(
	HWND hDlg,
	HWND hFocus,
	LPARAM lParam)
{
	_Debug(PROG,0,"enter Cls_OnInitDialogNamesAndPasswds");

	_CenterWindowOnScreen(hDlg);

	_Debug(PROG,0,"return Cls_OnInitDialogNamesAndPasswds");
	return(TRUE);
} // Cls_OnInitDialogNamesAndPasswds

extern LRESULT CALLBACK DlgProcNamesAndPasswds(
	HWND hDlg,
	UINT wMessage,
	WPARAM wParam,
	LPARAM lParam)
{
	_Debug(PROG,0,"enter DlgProcNamesAndPasswds");

	switch(wMessage)
	{
		case WM_COMMAND:
			HANDLE_WM_COMMAND(hDlg,wParam,lParam,Cls_OnCommandNamesAndPasswds);

			_Debug(PROG,0,"return DlgProcNamesAndPasswds");
			return(TRUE);
		break;
		case WM_INITDIALOG:
			_Debug(PROG,0,"return DlgProcNamesAndPasswds");
			return(HANDLE_WM_INITDIALOG(hDlg,wParam,lParam, \
				Cls_OnInitDialogNamesAndPasswds));
		break;
		default:
			_Debug(PROG,0,"return DlgProcNamesAndPasswds");
			return(FALSE);
		break;
	}
} // DlgProcNamesAndPasswds

/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* Names and Passwords Dialog */
/*____________________________*/

/*___________________*/
/* Data Types Dialog */
/*vvvvvvvvvvvvvvvvvvv*/

static void Cls_OnCloseDtype(
	HWND hWnd)
{
	_Debug(PROG,0,"enter Cls_OnCloseDtype");

	_TimedMsgBox(gco.hhLib,hWnd,"Clean up RIS (RIS_terminate)",
		"Temporary",MB_OK | MB_ICONINFORMATION,IDS_DTYPE_DESC,1);
	WinHelp(hWnd,"risutl.hlp",HELP_QUIT,0L);
	KillTimer(hWnd,1);
	DestroyIcon(dtype.hIcon);
	EndDialog(hWnd,0);

	_Debug(PROG,0,"leave Cls_OnCloseDtype");
} // Cls_OnCloseDtype

#define HANDLE_DTYPE_GENERIC_MENU_COMMANDS( \
	hWnd_hmgmc, \
	iId_hmgmc) \
\
	case IDM_FILE_EXIT: \
		SendMessage((hWnd_hmgmc),WM_CLOSE,0L,0L); \
	break; \
	case IDM_UTIL_DCODE: \
	case IDM_UTIL_CLNSR: \
	case IDM_UTIL_DTYPE: \
	case IDM_UTIL_RECRD: \
	case IDM_UTIL_PLBCK: \
	case IDM_UTIL_UNLOD: \
	case IDM_UTIL_LOD: \
	case IDM_UTIL_BATCH: \
	case IDM_UTIL_GUI: \
	case IDM_UTIL_MGR: \
		_RunUtility((iId_hmgmc)); \
	break; \
	case IDM_HELP_PROGRAM: \
	case IDM_HELP_CONTENTS: \
	case IDM_HELP_SEARCH: \
	case IDM_HELP_USE: \
	case IDM_HELP_PRODUCT_SUPPORT: \
	case IDM_HELP_ABOUT: \
		_RunHelp((iId_hmgmc),(hWnd_hmgmc),dtype.szTitle,dtype.szAppName, \
			dtype.hIcon); \
	break; \
	case IDM_RIS_DEBUG: \
		DialogBox(gco.hhLib,MAKEINTRESOURCE(IDD_RISDBG),(hWnd_hmgmc), \
			(DLGPROC)RISdebug); \
	break; \
	case IDM_GUI_DEBUG: \
		_UpdateStatusBar("Selected DEBUG"); \
		_DEBUG(PROG,2,"Selected Debug"); \
		_DebugControlPanel(gco.hhLib,(hWnd_hmgmc),FALSE); \
	break;
// HANDLE_DTYPE_GENERIC_MENU_COMMANDS

static void Cls_OnCommandDtype(
	HWND hWnd,
	int iId,
	HWND hWndCtl,
	UINT codeNotify)
{
	_Debug(PROG,0,"enter Cls_OnCommandDtype");

	switch(iId)
	{
		_Debug(PROG,2,"iId=%d",iId);

		HANDLE_DTYPE_GENERIC_MENU_COMMANDS(hWnd,iId);

		case IDC_DTYPE_SCH_NAME_LIST:
			if(LBN_DBLCLK == codeNotify)
			{
				DialogBox(gco.hhInst,
					MAKEINTRESOURCE(IDD_NAMES_AND_PASSWDS),
					hWnd,(DLGPROC)DlgProcNamesAndPasswds);
			}
		break;

                case IDC_DTYPE_RESET_BUTTON:
			STARTWAIT;
			_Delay(DELAY_TIME);

			ListBox_ResetContent(GetDlgItem(hWnd,
				IDC_DTYPE_SCH_NAME_LIST));
			GetSchemaNames(hWnd);

			ENDWAIT;
		break;

		default:
			_Debug(PROG,2,"iId not expected");
		break;
	}

	_Debug(PROG,0,"return Cls_OnCommandDtype");
} // Cls_OnCommandDtype

static void Cls_OnDestroyDtype(
	HWND hWnd)
{
	_Debug(PROG,0,"enter Cls_OnDestroyDtype");

	PostQuitMessage(0);

	_Debug(PROG,0,"return Cls_OnDestroyDtype");
} // Cls_OnDestroyDtype

/*
static BOOL Cls_OnEraseBkgndDtype(
	HWND hWnd,
	HDC hdc)
{
	_Debug(PROG,0,"enter Cls_OnEraseBkgndDtype");

	if(IsIconic(hWnd))
	{
		_Debug(PROG,0,"return Cls_OnEraseBkgndDtype");
		return(TRUE);
	}

	_Debug(PROG,0,"return Cls_OnEraseBkgndDtype");
} // Cls_OnEraseBkgndDtype
*/

static BOOL Cls_OnInitDialogDtype(
	HWND hWnd,
	HWND hWndFocus,
	LPARAM lParam)
{
	HMENU hMenu;

	_Debug(PROG,0,"enter Cls_OnInitDialogDtype");

	STARTWAIT;

	//Initialize
	_AddUtilityMenu(hWnd,1);
	_AddHelpMenu(hWnd);
	_InitDebug(dtype.argc,dtype.argv,hWnd,dtype.szAppName);
	_InitProgram(dtype.argc,dtype.argv);

	// disable RISdtype
	hMenu = GetMenu(hWnd);
	EnableMenuItem(hMenu,IDM_UTIL_DTYPE,
		MF_DISABLED | MF_GRAYED | MF_BYCOMMAND);

	if(!_InitStatusBar(hWnd))
	{
                _MessageBox(NULL,gco.hhLib,MB_OK | MB_TASKMODAL | MB_ICONSTOP,
			IDS_DTYPE_DESC,IDS_SBAR_FAIL);
		_Debug(PROG,0,"return Cls_OnInitDialogDtype");
		return(FALSE);
	}

	GetSchemaNames(hWnd);

	_DestroySplashScreen(dtype.hIntro);
	_CenterWindowOnScreen(hWnd);

	ENDWAIT;

	_Debug(PROG,0,"return Cls_OnInitDialogDtype");
	return(TRUE);
} // Cls_OnInitDialogDtype

static void Cls_OnMenuSelectDtype(
	HWND hWnd,
	HMENU hmenu,
	int item,
	HMENU hmenuPopup,
	UINT flags)
{
	char szMsg[255];

	_Debug(PROG,0,"enter Cls_OnMenuDtype");

	_Debug(PROG,2,"item = %d",item);
	strcpy(szMsg,_GetResourceString(gco.hhLib,item));
	_UpdateStatusBar(szMsg);

	_Debug(PROG,0,"return Cls_OnMenuDtype");
} // Cls_OnMenuSelectDtype

/*
static void Cls_OnPaintDtype(
	HWND hWnd)
{
	PAINTSTRUCT ps;

	_Debug(PROG,0,"enter Cls_OnPaintDtype");

	if(IsIconic(hWnd))
	{
		BeginPaint(hWnd,&ps);
		DrawIcon(ps.hdc,0,0,dtype.hIcon);
		EndPaint(hWnd,&ps);
	}

	_Debug(PROG,0,"return Cls_OnPaintDtype");
} // Cls_OnPaintDtype
*/

static void Cls_OnParentNotifyDtype(
	HWND hWnd,
	UINT msg,
	HWND hWndChild,
	int iIdChild)
{
	POINT pt;
	int iId;

	_Debug(PROG,0,"enter Cls_OnParentNotifyDtype");

	if(msg == WM_RBUTTONDOWN)
	{
		pt.x = LOWORD(hWndChild);
		pt.y = HIWORD(hWndChild);
		_Debug(PROG,2,"x=%d y=%d",pt.x,pt.y);

		iId = (int)GetWindowLong(ChildWindowFromPoint(hWnd,pt),GWL_ID);
		_Debug(PROG,2,"gadget = %d",iId);

//		if(iId >= IDC_CLNSR_SCHEMAS && iId <= IDC_CLNSR_EXIT)
//		{
//			 _UpdateStatusBar(_GetResourceString(gco.hhLib,iId+100));
//		}
   	}

	_Debug(PROG,0,"return Cls_OnParentNotifyDtype");
} // Cls_OnParentNotifyDtype

static void Cls_OnSizeDtype(
	HWND hWnd,
	UINT state,
	int cx,
	int cy)
{
	_Debug(PROG,0,"enter Cls_OnSizeDtype");

	_AdjustStatusBar(hWnd);

	_Debug(PROG,0,"return Cls_OnSizeDtype");
} // Cls_OnSizeDtype

static void Cls_OnTimerDtype(HWND hWnd,UINT iId)
{
//	_Debug(PROG,0,"enter Cls_OnTimerDtype");

	if(iId == 1)
	{
		_UpdateStatusBarTime();
	}

//	_Debug(PROG,0,"return Cls_OnTimerDtype");
} // Cls_OnTimerDtype

static LRESULT CALLBACK DlgProcDtype(
	HWND hWnd,
	UINT iMessage,
	WPARAM wParam,
	LPARAM lParam)
{
//	_Debug(PROG,0,"enter DlgProcDtype (may return within message cracker)");

	switch(iMessage)
	{
		_Debug(PROG,2,"iMessage=%d",iMessage);
		HANDLE_MSG(hWnd,WM_CLOSE,Cls_OnCloseDtype);
		HANDLE_MSG(hWnd,WM_COMMAND,Cls_OnCommandDtype);
		HANDLE_MSG(hWnd,WM_DESTROY,Cls_OnDestroyDtype);
/*
		HANDLE_MSG(hWnd,WM_ERASEBKGND,Cls_OnEraseBkgndDtype);
*/
		HANDLE_MSG(hWnd,WM_INITDIALOG,Cls_OnInitDialogDtype);
		HANDLE_MSG(hWnd,WM_MENUSELECT,Cls_OnMenuSelectDtype);
/*
		HANDLE_MSG(hWnd,WM_PAINT,Cls_OnPaintDtype);
*/
		HANDLE_MSG(hWnd,WM_PARENTNOTIFY,Cls_OnParentNotifyDtype);
		HANDLE_MSG(hWnd,WM_SIZE,Cls_OnSizeDtype);
		HANDLE_MSG(hWnd,WM_TIMER,Cls_OnTimerDtype);
	}

//	_Debug(PROG,0,"return DlgProcDtype (return(FALSE)");
	return(FALSE);
} // DlgProcDtype

/*^^^^^^^^^^^^^^^^^^^*/
/* Data Types Dialog */
/*___________________*/

/********************************************************************
Function:      GetSchemaNames
Description:
Variables:     hWnd Input, dialog window handle
Return Value:  None
********************************************************************/
#define TEMP_FIRST_SCHEMA "first_schema"
#define TEMP_SECOND_SCHEMA "second_schema"
#define TEMP_THIRD_SCHEMA "third_schema"
#define TEMP_FOURTH_SCHEMA "fourth_schema"
static void GetSchemaNames(
	HWND hWnd)
{
	HWND hDlg;

	_Debug(PROG,0,"enter GetSchemaNames");

	_UpdateStatusBar("Getting Schemas, please wait...");
	STARTWAIT;
	_Delay(DELAY_TIME);

	hDlg = GetDlgItem(hWnd,IDC_DTYPE_SCH_NAME_LIST);

	ListBox_AddString(hDlg,TEMP_FIRST_SCHEMA);
	ListBox_AddString(hDlg,TEMP_SECOND_SCHEMA);
	ListBox_AddString(hDlg,TEMP_THIRD_SCHEMA);
	ListBox_AddString(hDlg,TEMP_FOURTH_SCHEMA);
	ListBox_SetCurSel(hDlg,0L);

	SetFocus(hDlg);

	ENDWAIT;
	_UpdateStatusBar("");

	_Debug(PROG,0,"return GetSchemaNames");
} // GetSchemaNames
