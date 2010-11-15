/* Do not alter this SPC information: $Revision: 1.7.27.1 $ */
/********************************************************************
Name:		mgr.c
Authors:	Alan Barksdale based on code from Rick Kramer
Creation Date:	03/27/95
Description:	Main program for Schema Manager Utility

Revision History:
	03/27/95 AFB	Created the file.
	03/28/95 AFB	Started over; it wasn't the "Windows way".
	03/30/95 AFB	Started over again because dynamic dialogs were
			inconsistent with the API interface to Screen Manager
			dialogs.
	04/12/95 AFB	Made main window be a dialog.
********************************************************************/
#include <windows.h>
#include <windowsx.h>
#include <locale.h>
#include "gco.h"
// #include "gcosbar.h"
#include "resource.h"
#include "mgr.h"

#define mgr_c
#include "mgr.prt"
#include "mgrdlg.prt"
#include "gcosbar.prt"
#include "gcortns.prt"
#include "gcodbg.prt"
#include "gcordbg.prt"
#include "gcotmess.prt"
#include "gcointro.prt"


// Constants

#define DELAY_TIME 1 //to be deleted

/*
#define WIDTH_DLG_BASE_UNITS_TO_PIXELS( \
	width_wdbutp) \
\
	( \
		(LOWORD(mgr.dlgBaseUnits) * (width_wdbutp)) / 4 \
	)
// WIDTH_DLG_BASE_UNITS_TO_PIXELS

#define HEIGHT_DLG_BASE_UNITS_TO_PIXELS( \
	height_hdbutp) \
\
	( \
		(LOWORD(mgr.dlgBaseUnits) * (height_hdbutp)) / 4 \
	)
// HEIGHT_DLG_BASE_UNITS_TO_PIXELS
*/


/********************************************************************
Function:	WinMain
Description:	Main function for utility
Variables:	hInstance	Input, instance of the program
		hPrevInstance	Input, previous instance
		lpszCmdLine	Input, command line
		nCmdShow	Input, show flags

Return Value:	If the function succeeds, terminating when it receives a
		WM_QUIT message, it returns the exit value contained in that
		message's wParam parameter.  If the function terminates before
		entering the message loop, it returns FALSE. 
********************************************************************/
int PASCAL WinMain(
	HINSTANCE	hInstance,
	HINSTANCE	hPrevInstance,
	LPSTR		lpszCmdLine,
	int		nCmdShow)
{
	WNDCLASS	wndclass; // the window class
/*
	HWND		hWnd;
	MSG		msg;
*/

	DWORD dwLastError;
	char szLastError[80];

	// Used from a article in WindowsTech Magazine 7/92 by Charles Petzold
	setlocale(LC_ALL,"");

	gco.hhInst = hInstance;

	strcpy(mgr.szAppName,"RISmgr");

	// get handle to risres.dll
	gco.hhLib = _LoadResources(mgr.szAppName);
	if(!gco.hhLib)
	{
		return(0);
	}

	mgr.argc = _ParseCommandLine(gco.hhInst,lpszCmdLine,&mgr.argv);

	strcpy(mgr.szTitle,_GetResourceString(gco.hhLib,IDS_MGR_DESC));

	if(!hPrevInstance)
	{
		wndclass.style		= CS_HREDRAW | CS_VREDRAW;
		wndclass.lpfnWndProc	= DefDlgProc; 
		wndclass.cbClsExtra	= 0;
		wndclass.cbWndExtra	= DLGWINDOWEXTRA;
		wndclass.hInstance	= gco.hhInst;
		wndclass.hIcon		= LoadIcon(gco.hhInst,
						MAKEINTRESOURCE(IDI_MGR));
		wndclass.hCursor	= LoadCursor(NULL,IDC_ARROW);
		wndclass.hbrBackground	= (HBRUSH)(COLOR_WINDOW+1);
		wndclass.lpszMenuName	= NULL;
		wndclass.lpszClassName	= mgr.szAppName;

		mgr.hIcon = wndclass.hIcon;
		gco.hCursor = wndclass.hCursor;

		// register the window class 
		if(!RegisterClass(&wndclass))
		{
			MessageBox(NULL,"RegisterClass() failed",
				mgr.szTitle,MB_OK | MB_TASKMODAL | MB_ICONSTOP);
			return(0);
		}
/*
		wndclass.style		= CS_HREDRAW | CS_VREDRAW;
		wndclass.lpfnWndProc	= MgrWndProc; 
		wndclass.cbClsExtra	= 0;
		wndclass.cbWndExtra	= 0;
		wndclass.hInstance	= gco.hhInst;
		wndclass.hIcon		= LoadIcon(gco.hhInst,
						MAKEINTRESOURCE(IDI_MGR));
		wndclass.hCursor	= LoadCursor(NULL,IDC_ARROW);
		wndclass.hbrBackground	= (HBRUSH)(COLOR_WINDOW+1);
		wndclass.lpszMenuName	= mgr.szAppName;
		wndclass.lpszClassName	= mgr.szAppName;

		mgr.hIcon = wndclass.hIcon;
		gco.hCursor = wndclass.hCursor;

		// register the window class 
		if(!RegisterClass(&wndclass))
		{
			MessageBox(NULL,"RegisterClass() failed",
				mgr.szTitle,MB_OK | MB_TASKMODAL | MB_ICONSTOP);
			return(0);
		}
*/
	} /* if(!hPrevInstance) */

/*
	mgr.dlgBaseUnits = GetDialogBaseUnits(); // since window size is in pixels
*/

/*
	hWnd = CreateWindow(mgr.szAppName,mgr.szTitle,WS_OVERLAPPEDWINDOW,
		CW_USEDEFAULT,CW_USEDEFAULT,WIDTH_DLG_BASE_UNITS_TO_PIXELS(295),
		HEIGHT_DLG_BASE_UNITS_TO_PIXELS(285),NULL,NULL,gco.hhInst,NULL);
*/

	mgr.hIntro = _CreateSplashScreen(NULL,mgr.szTitle,mgr.szAppName,
		mgr.hIcon);
	UpdateWindow(mgr.hIntro);

	if(BAD_DIALOG_BOX == DialogBox(gco.hhInst,MAKEINTRESOURCE(IDD_MGR),
		NULL,(DLGPROC)DlgProcMgr))
	{
		dwLastError = GetLastError();
		wsprintf(szLastError,"DialogBox() failed; GetLastError returned %d", dwLastError);
		DEBUG_MESSAGE_BOX(szLastError);
	}

	FreeLibrary(gco.hhLib);

	return(0);

/*
	if(!InitWndMgr(hWnd))
	{
		return(0);
	}

	ShowWindow(hWnd,nCmdShow);
	UpdateWindow(hWnd);

	while(GetMessage(&msg,NULL,0,0))
	{
		TranslateMessage(&msg);
		DispatchMessage(&msg);
	}

	return(msg.wParam);
*/
} // WinMain

/********************************************************************
Function:      GetSchemaInformation
Description:
Variables:     hWnd Input, dialog window handle
Return Value:  None
********************************************************************/
static void GetSchemaInformation(
	HWND hWnd)
{
	_Debug(PROG,0,"enter GetSchemaInformation");
	
	_UpdateStatusBar("Getting schema information, please wait...");
	STARTWAIT;
	_Delay(DELAY_TIME);
	ENDWAIT;
	_UpdateStatusBar("");

	_Debug(PROG,0,"return GetSchemaInformation");
} // GetSchemaInformation

/*_______________________*/
/* Schema Manager Dialog */
/*vvvvvvvvvvvvvvvvvvvvvVv*/

/*
static BOOL InitWndMgr(
	HWND hWnd)
{
	HMENU hMenu;

	_Debug(PROG,0,"enter InitWndMgr");

	STARTWAIT;

	//Initialize
	_AddUtilityMenu(hWnd,4);
	_AddHelpMenu(hWnd);
	_InitDebug(mgr.argc,mgr.argv,hWnd,mgr.szAppName);
	_InitProgram(mgr.argc,mgr.argv);

	// disable RISmgr
	hMenu = GetMenu(hWnd);
	EnableMenuItem(hMenu,IDM_UTIL_MGR,
		MF_DISABLED | MF_GRAYED | MF_BYCOMMAND);

	if(!_InitStatusBar(hWnd))
	{
		_MessageBox(NULL,gco.hhLib,MB_OK | MB_TASKMODAL | MB_ICONSTOP,
			IDS_CLNSR_DESC,IDS_SBAR_FAIL);
		_Debug(PROG,0,"return InitWndMgr");
		return(FALSE);
	}

	CreateWindow("scrollbar",NULL,
		WS_CHILD | WS_VISIBLE | WS_TABSTOP | SBS_VERT,
		WIDTH_DLG_BASE_UNITS_TO_PIXELS(275),
		HEIGHT_DLG_BASE_UNITS_TO_PIXELS(20),
		WIDTH_DLG_BASE_UNITS_TO_PIXELS(10),

//		HEIGHT_DLG_BASE_UNITS_TO_PIXELS(230),

		HEIGHT_DLG_BASE_UNITS_TO_PIXELS(200),hWnd,
		(HMENU)IDC_MGR_SCROLLBAR,gco.hhInst,NULL);

	CreateWindow("static",
		_GetResourceString(gco.hhInst,IDS_MGR_SCHEMA_NAME),
		WS_CHILD | WS_VISIBLE | SS_CENTER,
		WIDTH_DLG_BASE_UNITS_TO_PIXELS(10),
		HEIGHT_DLG_BASE_UNITS_TO_PIXELS(10),
		WIDTH_DLG_BASE_UNITS_TO_PIXELS(50),
		HEIGHT_DLG_BASE_UNITS_TO_PIXELS(8),hWnd,
		(HMENU)IDC_MGR_SCHEMA_NAME_STATIC,gco.hhInst,NULL);
	CreateWindow("static",
		_GetResourceString(gco.hhInst,IDS_MGR_SCHEMA_TYPE),
		WS_CHILD | WS_VISIBLE | SS_CENTER,
		WIDTH_DLG_BASE_UNITS_TO_PIXELS(145),
		HEIGHT_DLG_BASE_UNITS_TO_PIXELS(10),
		WIDTH_DLG_BASE_UNITS_TO_PIXELS(45),
		HEIGHT_DLG_BASE_UNITS_TO_PIXELS(8),hWnd,
		(HMENU)IDC_MGR_SCHEMA_TYPE_STATIC,gco.hhInst,NULL);
	CreateWindow("static",
		_GetResourceString(gco.hhInst,IDS_MGR_DICTIONARY),
		WS_CHILD | WS_VISIBLE | SS_CENTER,
		WIDTH_DLG_BASE_UNITS_TO_PIXELS(210),
		HEIGHT_DLG_BASE_UNITS_TO_PIXELS(10),
		WIDTH_DLG_BASE_UNITS_TO_PIXELS(35),
		HEIGHT_DLG_BASE_UNITS_TO_PIXELS(8),hWnd,
		(HMENU)IDC_MGR_DICTIONARY_STATIC,gco.hhInst,NULL);

	CreateWindow("edit",NULL,
		WS_CHILD | WS_VISIBLE | WS_BORDER,
		WIDTH_DLG_BASE_UNITS_TO_PIXELS(10),
		HEIGHT_DLG_BASE_UNITS_TO_PIXELS(20),
		WIDTH_DLG_BASE_UNITS_TO_PIXELS(130),
		HEIGHT_DLG_BASE_UNITS_TO_PIXELS(200),hWnd,
		(HMENU)IDC_MGR_SCH_NAME_EDIT,gco.hhInst,NULL);
	CreateWindow("edit",NULL,
		WS_CHILD | WS_VISIBLE | WS_BORDER,
		WIDTH_DLG_BASE_UNITS_TO_PIXELS(145),
		HEIGHT_DLG_BASE_UNITS_TO_PIXELS(20),
		WIDTH_DLG_BASE_UNITS_TO_PIXELS(60),
		HEIGHT_DLG_BASE_UNITS_TO_PIXELS(200),hWnd,
		(HMENU)IDC_MGR_SCH_TYPE_EDIT,gco.hhInst,NULL);
	CreateWindow("edit",NULL,
		WS_CHILD | WS_VISIBLE | WS_BORDER,
		WIDTH_DLG_BASE_UNITS_TO_PIXELS(210),
		HEIGHT_DLG_BASE_UNITS_TO_PIXELS(20),
		WIDTH_DLG_BASE_UNITS_TO_PIXELS(60),
		HEIGHT_DLG_BASE_UNITS_TO_PIXELS(200),hWnd,
		(HMENU)IDC_MGR_DICT_EDIT,gco.hhInst,NULL);

	CreateWindow("Button",_GetResourceString(gco.hhInst,IDS_MGR_REFRESH),
		WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,
		WIDTH_DLG_BASE_UNITS_TO_PIXELS(114),
		HEIGHT_DLG_BASE_UNITS_TO_PIXELS(230),
		WIDTH_DLG_BASE_UNITS_TO_PIXELS(65),
		HEIGHT_DLG_BASE_UNITS_TO_PIXELS(15),hWnd,
		(HMENU)IDC_MGR_REFRESH_BUTTON,gco.hhInst,NULL);

	GetSchemaInformation(hWnd);

	_DestroySplashScreen(mgr.hIntro);
	_CenterWindowOnScreen(hWnd);

	_Debug(PROG,0,"return InitWndMgr");
	return(TRUE);
} // InitWndMgr
*/

static void Cls_OnCloseMgr(
	HWND hWnd)
{
	_Debug(PROG,0,"enter Cls_OnCloseMgr");

	_TimedMsgBox(gco.hhLib,hWnd,"Clean up RIS (RIS_terminate)",
		"Temporary",MB_OK | MB_ICONINFORMATION,IDS_MGR_DESC,1);
	WinHelp(hWnd,"risutl.hlp",HELP_QUIT,0L);
	KillTimer(hWnd,1);
	DestroyIcon(mgr.hIcon);
/*
	DestroyWindow(hWnd);
*/
	EndDialog(hWnd,0);

	_Debug(PROG,0,"return Cls_OnCloseMgr");
} // Cls_OnCloseMgr

#define HANDLE_MGR_GENERIC_MENU_COMMANDS( \
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
		_RunHelp((iId_hmgmc),(hWnd_hmgmc),mgr.szTitle,mgr.szAppName, \
			mgr.hIcon); \
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
// HANDLE_MGR_GENERIC_MENU_COMMANDS

static void Cls_OnCommandMgr(
	HWND hWnd,
	int iId,
	HWND hWndCtl,
	UINT codeNotify)
{
	DWORD dwLastError;
	char szLastError[80];

	_Debug(PROG,0,"enter Cls_OnCommandMgr");
//	wsprintf(szLastError,"iId Cls_OnCommandMgr = %d",iId);
//	DEBUG_MESSAGE_BOX(szLastError);

	switch(iId)
	{
		_Debug(PROG,2,"iId=%d",iId);

		HANDLE_MGR_GENERIC_MENU_COMMANDS(hWnd,iId);

		case IDM_MGR_SCH_INFO:
			if(BAD_DIALOG_BOX == DialogBox(gco.hhInst,
				MAKEINTRESOURCE(IDD_MGR_SCH_INFO),hWnd,
				(DLGPROC)DlgProcSchInfo))
			{
				dwLastError = GetLastError();
				wsprintf(szLastError,"DialogBox() failed; GetLastError returned %d",dwLastError);
				DEBUG_MESSAGE_BOX(szLastError);
			}
		break;
		case IDM_MGR_CREATE_SCH:
			if(BAD_DIALOG_BOX == DialogBox(gco.hhInst,
				MAKEINTRESOURCE(IDD_MGR_CREATE_SCH),hWnd,
				(DLGPROC)DlgProcCreateSch))
			{
				dwLastError = GetLastError();
				wsprintf(szLastError,"DialogBox() failed; GetLastError returned %d",dwLastError);
				DEBUG_MESSAGE_BOX(szLastError);
			}
		break;
		case IDM_MGR_DROP_SCH:
			if(BAD_DIALOG_BOX == DialogBox(gco.hhInst,
				MAKEINTRESOURCE(IDD_MGR_DROP_SCH),hWnd,
				(DLGPROC)DlgProcDropSch))
			{
				dwLastError = GetLastError();
				wsprintf(szLastError,"DialogBox() failed; GetLastError returned %d",dwLastError);
				DEBUG_MESSAGE_BOX(szLastError);
			}
		break;
		case IDM_MGR_SECURE_SCH_ACCESS:
			if(BAD_DIALOG_BOX == DialogBox(gco.hhInst,
				MAKEINTRESOURCE(IDD_MGR_SECURE_SCH_ACCESS),hWnd,
				(DLGPROC)DlgProcSecureSchAccess))
			{
				dwLastError = GetLastError();
				wsprintf(szLastError,"DialogBox() failed; GetLastError returned %d",dwLastError);
				DEBUG_MESSAGE_BOX(szLastError);
			}
		break;
		case IDM_MGR_DICT_ACCESS:
			if(BAD_DIALOG_BOX == DialogBox(gco.hhInst,
				MAKEINTRESOURCE(IDD_MGR_DICT_ACCESS),hWnd,
				(DLGPROC)DlgProcDictAccess))
			{
				dwLastError = GetLastError();
				wsprintf(szLastError,"DialogBox() failed; GetLastError returned %d",dwLastError);
				DEBUG_MESSAGE_BOX(szLastError);
			}
		break;
		case IDM_MGR_MOD_SCH_PASSWD:
			if(BAD_DIALOG_BOX == DialogBox(gco.hhInst,
				MAKEINTRESOURCE(IDD_MGR_MOD_SCH_PASSWD),hWnd,
				(DLGPROC)DlgProcModSchPasswd))
			{
				dwLastError = GetLastError();
				wsprintf(szLastError,"DialogBox() failed; GetLastError returned %d",dwLastError);
				DEBUG_MESSAGE_BOX(szLastError);
			}
		break;
		case IDM_MGR_MOD_NODE_INFO:
			if(BAD_DIALOG_BOX == DialogBox(gco.hhInst,
				MAKEINTRESOURCE(IDD_MGR_MOD_NODE_INFO),hWnd,
				(DLGPROC)DlgProcModNodeInfo))
			{
				dwLastError = GetLastError();
				wsprintf(szLastError,"DialogBox() failed; GetLastError returned %d",dwLastError);
				DEBUG_MESSAGE_BOX(szLastError);
			}
		break;
		case IDM_MGR_MOD_DB2_PASSWD:
			if(BAD_DIALOG_BOX == DialogBox(gco.hhInst,
				MAKEINTRESOURCE(IDD_MGR_MOD_DB2_PASSWD),hWnd,
				(DLGPROC)DlgProcModDb2Passwd))
			{
				dwLastError = GetLastError();
				wsprintf(szLastError,"DialogBox() failed; GetLastError returned %d",dwLastError);
				DEBUG_MESSAGE_BOX(szLastError);
			}
		break;

		case IDM_MGR_TBL_INFO:
			if(BAD_DIALOG_BOX == DialogBox(gco.hhInst,
				MAKEINTRESOURCE(IDD_MGR_TBL_INFO),hWnd,
				(DLGPROC)DlgProcTblInfo))
			{
				dwLastError = GetLastError();
				wsprintf(szLastError,"DialogBox() failed; GetLastError returned %d",dwLastError);
				DEBUG_MESSAGE_BOX(szLastError);
			}
		break;
		case IDM_MGR_CREATE_TBL:
			if(BAD_DIALOG_BOX == DialogBox(gco.hhInst,
				MAKEINTRESOURCE(IDD_MGR_CREATE_TBL),hWnd,
				(DLGPROC)DlgProcCreateTbl))
			{
				dwLastError = GetLastError();
				wsprintf(szLastError,"DialogBox() failed; GetLastError returned %d",dwLastError);
				DEBUG_MESSAGE_BOX(szLastError);
			}
		break;
		case IDM_MGR_DROP:
			if(BAD_DIALOG_BOX == DialogBox(gco.hhInst,
				MAKEINTRESOURCE(IDD_MGR_DROP),hWnd,
				(DLGPROC)DlgProcDrop))
			{
				dwLastError = GetLastError();
				wsprintf(szLastError,"DialogBox() failed; GetLastError returned %d",dwLastError);
				DEBUG_MESSAGE_BOX(szLastError);
			}
		break;
		case IDM_MGR_ALTER_TBL:
			if(BAD_DIALOG_BOX == DialogBox(gco.hhInst,
				MAKEINTRESOURCE(IDD_MGR_ALTER_TBL),hWnd,
				(DLGPROC)DlgProcAlterTbl))
			{
				dwLastError = GetLastError();
				wsprintf(szLastError,"DialogBox() failed; GetLastError returned %d",dwLastError);
				DEBUG_MESSAGE_BOX(szLastError);
			}
		break;
		case IDM_MGR_INCLUDE:
			if(BAD_DIALOG_BOX == DialogBox(gco.hhInst,
				MAKEINTRESOURCE(IDD_MGR_INCLUDE),hWnd,
				(DLGPROC)DlgProcInclude))
			{
				dwLastError = GetLastError();
				wsprintf(szLastError,"DialogBox() failed; GetLastError returned %d",dwLastError);
				DEBUG_MESSAGE_BOX(szLastError);
			}
		break;
		case IDM_MGR_EXCLUDE:
			if(BAD_DIALOG_BOX == DialogBox(gco.hhInst,
				MAKEINTRESOURCE(IDD_MGR_EXCLUDE),hWnd,
				(DLGPROC)DlgProcExclude))
			{
				dwLastError = GetLastError();
				wsprintf(szLastError,"DialogBox() failed; GetLastError returned %d",dwLastError);
				DEBUG_MESSAGE_BOX(szLastError);
			}
		break;

		case IDM_MGR_SCH_FILE:
			if(BAD_DIALOG_BOX == DialogBox(gco.hhInst,
				MAKEINTRESOURCE(IDD_MGR_SCH_FILE),hWnd,
				(DLGPROC)DlgProcSchFile))
			{
				dwLastError = GetLastError();
				wsprintf(szLastError,"DialogBox() failed; GetLastError returned %d",dwLastError);
				DEBUG_MESSAGE_BOX(szLastError);
			}
		break;
		case IDM_MGR_LOCATE_CLIENT:
			if(BAD_DIALOG_BOX == DialogBox(gco.hhInst,
				MAKEINTRESOURCE(IDD_MGR_LOCATE_CLIENT),hWnd,
				(DLGPROC)DlgProcLocateClient))
			{
				dwLastError = GetLastError();
				wsprintf(szLastError,"DialogBox() failed; GetLastError returned %d",dwLastError);
				DEBUG_MESSAGE_BOX(szLastError);
			}
		break;
		case IDM_MGR_SET:
			if(BAD_DIALOG_BOX == DialogBox(gco.hhInst,
				MAKEINTRESOURCE(IDD_MGR_SET),hWnd,
				(DLGPROC)DlgProcSet))
			{
				dwLastError = GetLastError();
				wsprintf(szLastError,"DialogBox() failed; GetLastError returned %d",dwLastError);
				DEBUG_MESSAGE_BOX(szLastError);
			}
		break;

		case IDC_MGR_REFRESH_BUTTON:
			GetSchemaInformation(hWnd);
		break;

		default:
			_Debug(PROG,2,"iId not expected");
		break;
	} // switch(iId)

	_Debug(PROG,0,"return Cls_OnCommandMgr");
} // Cls_OnCommandMgr

static void Cls_OnDestroyMgr(
	HWND hWnd)
{
	_Debug(PROG,0,"enter Cls_OnDestroyMgr");

	PostQuitMessage(0);

	_Debug(PROG,0,"return Cls_OnDestroyMgr");
} // Cls_OnDestroyMgr

static BOOL Cls_OnInitDialogMgr(
	HWND hWnd,
	HWND hWndFocus,
	LPARAM lParam)
{
	HMENU hMenu;

	_Debug(PROG,0,"enter Cls_OnInitDialogMgr");

	STARTWAIT;

	//Initialize
	_AddUtilityMenu(hWnd,4); // 4 so just before HELP
	_AddHelpMenu(hWnd);
	_InitDebug(mgr.argc,mgr.argv,hWnd,mgr.szAppName);
	_InitProgram(mgr.argc,mgr.argv);

	// disable RISmgr
	hMenu = GetMenu(hWnd);
	EnableMenuItem(hMenu,IDM_UTIL_MGR,
		MF_DISABLED | MF_GRAYED | MF_BYCOMMAND);

	if(!_InitStatusBar(hWnd))
	{
		_MessageBox(NULL,gco.hhLib,MB_OK | MB_TASKMODAL | MB_ICONSTOP,
			IDS_CLNSR_DESC,IDS_SBAR_FAIL);
		_Debug(PROG,0,"return Cls_OnInitDialogMgr");
		return(FALSE);
	}

	GetSchemaInformation(hWnd);

	_DestroySplashScreen(mgr.hIntro);
	_CenterWindowOnScreen(hWnd);

	ENDWAIT;

	_Debug(PROG,0,"return Cls_OnInitDialogMgr");
	return(TRUE);
} // Cls_OnInitDialogMgr

static void Cls_OnMenuSelectMgr(
	HWND hWnd,
	HMENU hMenu,
	int item,
	HMENU hMenuPopup,
	UINT flags)
{
	char szMsg[255];

	_Debug(PROG,0,"enter Cls_OnMenuSelectMgr");

	_Debug(PROG,2,"item = %d",item);
	strcpy(szMsg,_GetResourceString(gco.hhLib,item));
	_UpdateStatusBar(szMsg);

	_Debug(PROG,0,"return Cls_OnMenuSelectMgr");
} // Cls_OnMenuSelectMgr

static void Cls_OnParentNotifyMgr(
	HWND hWnd,
	UINT msg,
	HWND hWndChild,
	int idChild)
{
	POINT pt;
	int iId;

	_Debug(PROG,0,"enter Cls_OnParentNotifyMgr");

	if(msg == WM_RBUTTONDOWN)
	{
		pt.x = LOWORD(hWndChild);
		pt.y = HIWORD(hWndChild);
		_Debug(PROG,2,"x=%d y=%d",pt.x,pt.y);

		iId = (int)GetWindowLong(ChildWindowFromPoint(hWnd,pt),GWL_ID);
		_Debug(PROG,2,"gadget = %d",iId);
	}

	_Debug(PROG,0,"return Cls_OnParentNotifyMgr");
} // Cls_OnParentNotifyMgr

static void Cls_OnSizeMgr(
	HWND hWnd,
	UINT state,
	int cx,
	int cy)
{
	_Debug(PROG,0,"enter Cls_OnSizeMgr");

	_AdjustStatusBar(hWnd);

	_Debug(PROG,0,"return Cls_OnSizeMgr");
} // Cls_OnSizeMgr

static void Cls_OnTimerMgr(HWND hWnd,UINT iId)
{
//	_Debug(PROG,0,"enter Cls_OnTimerMgr");

	if(iId == 1)
	{
		_UpdateStatusBarTime();
	}

//	_Debug(PROG,0,"return Cls_OnTimerMgr");
} // Cls_OnTimerMgr

static LRESULT CALLBACK DlgProcMgr(
	HWND	hWnd,
	UINT	wMessage,
	WPARAM	wParam,
	LPARAM	lParam)
{
//	_Debug(PROG,0,"enter DlgProcMgr (may return within message cracker)");

	switch(wMessage)
	{
		_Debug(PROG,2,"wMessage=%d",wMessage);
		HANDLE_MSG(hWnd,WM_CLOSE,Cls_OnCloseMgr);
		HANDLE_MSG(hWnd,WM_COMMAND,Cls_OnCommandMgr);
		HANDLE_MSG(hWnd,WM_DESTROY,Cls_OnDestroyMgr);
		HANDLE_MSG(hWnd,WM_INITDIALOG,Cls_OnInitDialogMgr);
		HANDLE_MSG(hWnd,WM_MENUSELECT,Cls_OnMenuSelectMgr);
		HANDLE_MSG(hWnd,WM_PARENTNOTIFY,Cls_OnParentNotifyMgr);
		HANDLE_MSG(hWnd,WM_SIZE,Cls_OnSizeMgr);
		HANDLE_MSG(hWnd,WM_TIMER,Cls_OnTimerMgr);
/*
		default:
//			_Debug(PROG,0,
//				"return DlgProcMgr (not within message cracker)");
			return(DefWindowProc(hWnd,wMessage,wParam,lParam));
		break;
*/
	}

//	_Debug(PROG,0,"return DlgProcMgr (return(FALSE))");
	return(FALSE);
} // DlgProcMgr

/*^^^^^^^^^^^^^^^^^^^^^^^*/
/* Schema Manager Dialog */
/*_______________________*/
