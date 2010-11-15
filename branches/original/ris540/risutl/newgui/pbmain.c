/* Do not alter this SPC information: $Revision: 1.1.29.1 $ */
/********************************************************************
Name:				plbck.c
Authors:       Rick Kramer
Creation Date: 03/28/95
Description:   Main program for Playback Utility

Revision History:

********************************************************************/
#include <windows.h>
#include <windowsx.h>
#include <locale.h>
#include <commdlg.h>
#include "gco.h"
#include "plbck.h"
#include "dlgxext.h"
#include "dlgsec.h"
#include "resource.h"

#define pbmain_c
#include "pbmain.prt"
#include "gcocat.prt"
#include "gcosec.prt"
#include "gcosbar.prt"
#include "gcortns.prt"
#include "gcodbg.prt"
#include "gcordbg.prt"
#include "gcotmess.prt"

// Constants

#define IDS_TEXTFORMAT	0x1234

enum {
   IDCAT_MAIN,
   IDCAT_ACTIONS,
};

   // Declarations

static DLGSECTION dlgsec;
static BOOL    fDefDlgEx;

struct tagCATEGORYDEF
{
      int   nID;
      LPCTSTR  lpszName;
      LPCTSTR  lpszTitle;
}
static catdef[] =
{
      { IDCAT_MAIN, TEXT("RISplbckMain"),TEXT("Main")},
      { IDCAT_ACTIONS, TEXT("RISplbckActions"),TEXT("Actions")},
};
gco_globals gco;


int PASCAL WinMain(hinstA, hinstPrev, lpszCmdLine, nCmdShow)
HINSTANCE   hinstA;
HINSTANCE   hinstPrev;
LPSTR  lpszCmdLine;
int    nCmdShow;
{
	WNDCLASS    wndclass ; // the window class

   setlocale(LC_ALL, "");

   gco.hhInst = hinstA;
   strcpy(plbck.szAppName,"RISplbck");

   // get handle to risres.dll
   gco.hhLib = _LoadResources(plbck.szAppName);
   if (!gco.hhLib)
   {
      return (FALSE);
   }

   plbck.argc = _ParseCommandLine(gco.hhInst, lpszCmdLine, &plbck.argv);

   strcpy(plbck.szTitle,_GetResourceString (gco.hhLib,IDS_PLBCK_DESC));

	if (!hinstPrev)
	{
		wndclass.style         = CS_HREDRAW | CS_VREDRAW ;
		wndclass.lpfnWndProc   = DefDlgProc ;
		wndclass.cbClsExtra    = 0 ;
		wndclass.cbWndExtra    = DLGWINDOWEXTRA ;
		wndclass.hInstance     = gco.hhInst ;
		wndclass.hIcon			  = LoadIcon(gco.hhInst, MAKEINTRESOURCE(IDI_PLBCK));
		wndclass.hCursor       = LoadCursor (NULL, IDC_ARROW) ;
		wndclass.hbrBackground = (HBRUSH)(COLOR_WINDOW+1);
		wndclass.lpszMenuName  = NULL ;
		wndclass.lpszClassName = plbck.szAppName;

      plbck.hIcon = wndclass.hIcon;
      gco.hCursor = wndclass.hCursor;

		// register the window class 
		if (!RegisterClass (&wndclass))
		{
			MessageBox(NULL,"RegisterClass() failed",plbck.szTitle,MB_OK | MB_TASKMODAL | MB_ICONSTOP);
			return FALSE ;
		}
	}

  DialogBox(gco.hhInst, TEXT("RISplbck_tmp"), NULL, (DLGPROC) DynDlgBox);

  FreeLibrary(gco.hhLib);
  return 0;
}

// -----------------------------------------------------------------------
//  PURPOSE:
// Common default window procedure for all dialog.
// -----------------------------------------------------------------------
static LRESULT CommonDlg_DefProc(
	HWND hwndDlg,
	UINT uMessage,
	WPARAM wParam,
	LPARAM lParam)
{
  return DefDlgProcEx(hwndDlg, uMessage, wParam, lParam, &fDefDlgEx);
}

static BOOL CALLBACK DynDlgBox(
	HWND hwndDlg,
	UINT uMessage,
	WPARAM wParam,
	LPARAM lParam)
{
  CheckDefDlgRecursion(&fDefDlgEx);
  return SetDlgMsgResult(hwndDlg, uMessage,
    DynDlgBox_DlgProc(hwndDlg, uMessage, wParam, lParam));
}


static BOOL DynDlgBox_OnInitDialog(
	HWND hwndDlg,
	HWND hwndFocus,
	LPARAM lparam)
{
  int i;
  HWND	   hwndProp;

   _AddUtilityMenu(hwndDlg, 1);
   _AddHelpMenu(hwndDlg);
   _InitDebug( plbck.argc,plbck.argv,hwndDlg, plbck.szAppName );
   _InitProgram(plbck.argc,plbck.argv);

   if (!_InitStatusBar (hwndDlg))
   {
      _MessageBox (NULL,gco.hhLib,MB_OK | MB_TASKMODAL | MB_ICONSTOP,IDS_PLBCK_DESC,IDS_SBAR_FAIL);
      return FALSE;
   }
//	_MessageBox(hwndDlg,gco.hhInst,MB_OKCANCEL,0,0,plbck.szTitle,_WinError(87));
	plbck.fReadFile = FALSE;
	plbck.fImmPlayback = FALSE;
	plbck.fCommandTimes = FALSE;
	plbck.fDelayTimes = FALSE;
	plbck.fTotalTime = FALSE;
	plbck.fBlob = FALSE;
	plbck.fVerbose = FALSE;
	strcpy(plbck.szInputFile,"c:\\tmp\\risrap.rap");
	strcpy(plbck.szOutputFile,"c:\\tmp\\ris.plb");

	plbck.nSS = IDC_PLBCK_SSC;
	plbck.nSD = IDC_PLBCK_SDC;
	plbck.nSE = IDC_PLBCK_SEC;
	plbck.nDS = IDC_PLBCK_DSC;
	plbck.nDD = IDC_PLBCK_DDC;
	plbck.nDE = IDC_PLBCK_DEC;
	plbck.nES = IDC_PLBCK_ESC;
	plbck.nED = IDC_PLBCK_EDC;
	plbck.nEE = IDC_PLBCK_EEC;

	plbck.index = 1;
	strcpy(plbck.szInitialDir,"c:\\tmp");

   // Initialise the dialog section.
  InitDlgSection(&dlgsec, IDS_TEXTFORMAT, hwndDlg, IDC_PLBCK_FRAME_DIALOGBOX, NULL);

  // Set threshold so that a category is always discarded when the user
  // selects another.

  SetDlgSectionThreshold(&dlgsec, 2, 2);
  
  // Add the categories to the section and their names to the list box.

  hwndProp = GetDlgItem(hwndDlg, IDC_PLBCK_PROPERTY);

  for (i = 0; i < ARRAY_COUNT(catdef); i++)
  {
    ListBox_AddString(hwndProp, catdef[i].lpszTitle);
    AddDlgSectionCategory(&dlgsec, gco.hhInst, catdef[i].lpszName, catdef[i].nID,
      DSCF_DISCARDABLE, NULL);
  }

  // Select the first category and list box selection.

  SelectDlgSectionCategory(&dlgsec, IDCAT_MAIN);
  ListBox_SetCurSel(hwndProp, 0);

   _CenterWindowOnScreen(hwndDlg);
  return TRUE;
}

static void Cls_OnTimer(HWND hwnd, UINT id)
{
   if (id == 1)
      _UpdateStatusBarTime();
}

/********************************************************************
Function:
Description:
Variables:
     
     
     

Return Value:


********************************************************************/
static void Cls_OnSize(
	HWND hwnd,
	UINT state,
	int cx,
	int cy)
{
   _AdjustStatusBar (hwnd);
}


static void DynDlgBox_OnCommand(
	HWND hwndDlg,
	int nID,
	HWND hwndCtl,
	UINT uNotifyCode)
{
  int  nCurSel;
  int  nCatID;

	char   fname_only[_MAX_PATH];
	int    status;
	char filter[128] = "RISRAP Files (risrap.*)|risrap.*|All Files (*.*)|*.*|";

	switch (nID)
  {
    case IDC_PLBCK_PROPERTY :

      if (uNotifyCode == LBN_SELCHANGE)
      {
   nCurSel = ListBox_GetCurSel(hwndCtl);

   if (nCurSel != LB_ERR)
     SelectDlgSectionCategory(&dlgsec, catdef[nCurSel].nID);
      }
      break;

    case IDS_TEXTFORMAT :

      // Sections and categories don't have have window handles,
      // therefore the hwndCtl parameter of the WM_COMMAND is used
      // to signal the ID of the category being discarded or loaded.

      nCatID = (int) hwndCtl;

      switch (uNotifyCode)
      {
   case DSN_DISCARDING :

    // Category is about to be discarded, so save the
    // that state of its controls.

    SaveCategoryState(hwndDlg, nCatID);
    break;

   case DSN_LOADED :

    // Category loaded, so restore the state of its
    // controls.

    RestoreCategoryState(hwndDlg, nCatID);
    break;
      }

      break;

    case IDOK :
	   STARTWAIT;
		_Delay(4);
   	ENDWAIT;
		break;
      case IDM_FILE_EXIT:

      // Delete the dialog section (also deletes the categories
      // implicitly).

//	DeleteDlgSection(&dlgsec);
//	EndDialog(hwndDlg, nID == IDOK);
    SendMessage(hwndDlg,WM_CLOSE,0L,0L);
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
    _RunUtility(nID);
    break;

      case IDM_HELP_PROGRAM:
      case IDM_HELP_CONTENTS:
      case IDM_HELP_SEARCH:
      case IDM_HELP_USE:
      case IDM_HELP_PRODUCT_SUPPORT:
      case IDM_HELP_ABOUT:
    _RunHelp(nID,hwndDlg,plbck.szTitle,plbck.szAppName,plbck.hIcon);
    break;

    case IDM_RIS_DEBUG:
    DialogBox(gco.hhLib, MAKEINTRESOURCE(IDD_RISDBG),hwndDlg, (DLGPROC)RISdebug);
    break;

      case IDM_GUI_DEBUG:
     _UpdateStatusBar("Selected DEBUG");
     _DEBUG(PROG,2,"Selected Debug");
     _DebugControlPanel( gco.hhLib,hwndDlg,FALSE );
    break;
	case IDC_PLBCK_BROWSE:
		strcpy ( plbck.szInputFile, "" );
		status = _SelectFile (hwndDlg, plbck.szInputFile, plbck.szInitialDir,fname_only,"RISplbck - Select input filename",filter,&plbck.index);
_DEBUG(PROG,2,"Status=%d fname_only=<%s> filename=<%s>",status,fname_only,plbck.szInputFile);
_DEBUG(PROG,2,"filter=<%s> index = %d dir=<%s>",filter,plbck.index,plbck.szInitialDir);
		if (status == TRUE)
			Edit_SetText(GetDlgItem(hwndDlg,IDC_PLBCK_INPUT_FILE), plbck.szInputFile);
		break;

  }
}

static void SaveCategoryState(
	HWND hwndDlg,
	int nCatID)
{
	int i;

  switch (nCatID)
  {
    case IDCAT_MAIN :
      plbck.fReadFile = IsDlgButtonChecked(hwndDlg, IDC_PLBCK_READ_FILE);
      plbck.fImmPlayback = IsDlgButtonChecked(hwndDlg, IDC_PLBCK_IMM_PLAYBACK);
      plbck.fCommandTimes = IsDlgButtonChecked(hwndDlg, IDC_PLBCK_COMMAND_TIMES);
      plbck.fDelayTimes = IsDlgButtonChecked(hwndDlg, IDC_PLBCK_DELAY_TIMES);
      plbck.fTotalTime = IsDlgButtonChecked(hwndDlg, IDC_PLBCK_TOTAL_TIME);
      plbck.fBlob = IsDlgButtonChecked(hwndDlg, IDC_PLBCK_BLOB);
      plbck.fVerbose = IsDlgButtonChecked(hwndDlg, IDC_PLBCK_VERBOSE);
		Edit_GetText(GetDlgItem(hwndDlg,IDC_PLBCK_INPUT_FILE), plbck.szInputFile, 255);
		Edit_GetText(GetDlgItem(hwndDlg,IDC_PLBCK_OUTPUT_FILE), plbck.szOutputFile, 255);
      break;

    case IDCAT_ACTIONS :
		for (i=IDC_PLBCK_SSC; i<=IDC_PLBCK_SSR; i++)
		{
	      if (IsDlgButtonChecked(hwndDlg, i) ==TRUE)
				plbck.nSS = i;
		}

		for (i=IDC_PLBCK_SDC; i<=IDC_PLBCK_SDR; i++)
		{
	      if (IsDlgButtonChecked(hwndDlg, i) ==TRUE)
				plbck.nSD = i;
		}

		for (i=IDC_PLBCK_SEC; i<=IDC_PLBCK_SER; i++)
		{
	      if (IsDlgButtonChecked(hwndDlg, i) ==TRUE)
				plbck.nSE = i;
		}

				for (i=IDC_PLBCK_DSC; i<=IDC_PLBCK_DSR; i++)
		{
	      if (IsDlgButtonChecked(hwndDlg, i) ==TRUE)
				plbck.nDS = i;
		}

				for (i=IDC_PLBCK_DDC; i<=IDC_PLBCK_DDR; i++)
		{
	      if (IsDlgButtonChecked(hwndDlg, i) ==TRUE)
				plbck.nDD = i;
		}

				for (i=IDC_PLBCK_DEC; i<=IDC_PLBCK_DER; i++)
		{
	      if (IsDlgButtonChecked(hwndDlg, i) ==TRUE)
				plbck.nDE = i;
		}

				for (i=IDC_PLBCK_ESC; i<=IDC_PLBCK_ESR; i++)
		{
	      if (IsDlgButtonChecked(hwndDlg, i) ==TRUE)
				plbck.nES = i;
		}

				for (i=IDC_PLBCK_EDC; i<=IDC_PLBCK_EDR; i++)
		{
	      if (IsDlgButtonChecked(hwndDlg, i) ==TRUE)
				plbck.nED = i;
		}

				for (i=IDC_PLBCK_EEC; i<=IDC_PLBCK_EER; i++)
		{
	      if (IsDlgButtonChecked(hwndDlg, i) ==TRUE)
				plbck.nEE = i;
		}

      break;

  }
}

static void RestoreCategoryState(
	HWND hwndDlg,
	int nCatID)
{
  switch (nCatID)
  {
    case IDCAT_MAIN :
      CheckDlgButton(hwndDlg, IDC_PLBCK_READ_FILE, plbck.fReadFile);
      CheckDlgButton(hwndDlg, IDC_PLBCK_IMM_PLAYBACK, plbck.fImmPlayback);
      CheckDlgButton(hwndDlg, IDC_PLBCK_COMMAND_TIMES, plbck.fCommandTimes);
      CheckDlgButton(hwndDlg, IDC_PLBCK_DELAY_TIMES, plbck.fDelayTimes);
      CheckDlgButton(hwndDlg, IDC_PLBCK_TOTAL_TIME, plbck.fTotalTime);
      CheckDlgButton(hwndDlg, IDC_PLBCK_BLOB, plbck.fBlob);
      CheckDlgButton(hwndDlg, IDC_PLBCK_VERBOSE, plbck.fVerbose);
		Edit_SetText(GetDlgItem(hwndDlg,IDC_PLBCK_INPUT_FILE), plbck.szInputFile);
		Edit_SetText(GetDlgItem(hwndDlg,IDC_PLBCK_OUTPUT_FILE), plbck.szOutputFile);
      break;

    case IDCAT_ACTIONS :
      CheckRadioButton(hwndDlg, IDC_PLBCK_SSC, IDC_PLBCK_SSR, plbck.nSS);
      CheckRadioButton(hwndDlg, IDC_PLBCK_SDC, IDC_PLBCK_SDR, plbck.nSD);
      CheckRadioButton(hwndDlg, IDC_PLBCK_SEC, IDC_PLBCK_SER, plbck.nSE);
      CheckRadioButton(hwndDlg, IDC_PLBCK_DSC, IDC_PLBCK_DSR, plbck.nDS);
      CheckRadioButton(hwndDlg, IDC_PLBCK_DDC, IDC_PLBCK_DDR, plbck.nDD);
      CheckRadioButton(hwndDlg, IDC_PLBCK_DEC, IDC_PLBCK_DER, plbck.nDE);
      CheckRadioButton(hwndDlg, IDC_PLBCK_ESC, IDC_PLBCK_ESR, plbck.nES);
      CheckRadioButton(hwndDlg, IDC_PLBCK_EDC, IDC_PLBCK_EDR, plbck.nED);
      CheckRadioButton(hwndDlg, IDC_PLBCK_EEC, IDC_PLBCK_EER, plbck.nEE);
      break;

  }
}
static void Cls_OnMenuSelect(
	HWND hwnd,
	HMENU hmenu,
	int item,
	HMENU hmenuPopup,
	UINT flags)
{
   char szMsg[255];

   _DEBUG(PROG,2,"Item = %d",item);
   strcpy(szMsg, _GetResourceString(gco.hhLib,item));
   _UpdateStatusBar(szMsg);


}

static void Cls_OnClose(
	HWND hwnd)
{
 	_TimedMsgBox(gco.hhLib, hwnd, "Clean up RIS (RIS_terminate)","Temporary",MB_OKCANCEL | MB_ICONINFORMATION , IDS_PLBCK_DESC, 1);
   WinHelp(hwnd,"risutl.hlp",HELP_QUIT,0L);
   KillTimer(hwnd,1);
   DestroyIcon(plbck.hIcon);
//	DeleteDlgSection(&dlgsec);

   EndDialog (hwnd, 0) ;
}

void Cls_OnDestroy(
	HWND hwnd)
{
   PostQuitMessage(0);
}

static void Cls_OnParentNotify(
	HWND hwnd,
	UINT msg,
	HWND hwndChild,
	int idChild)
{
   POINT pt;
   int id;

   if (msg == WM_RBUTTONDOWN)
   {
      pt.x = LOWORD(hwndChild);
      pt.y = HIWORD(hwndChild);
      _DEBUG(PROG,2,"x=%d y=%d",pt.x,pt.y);

      id = (int)GetWindowLong(ChildWindowFromPoint(hwnd,pt),GWL_ID);
      _Debug(PROG,2,"gadget = %d",id);
// if (id >= IDC_CLNSR_SCHEMAS && id <= IDC_CLNSR_EXIT)
//     _UpdateStatusBar(_GetResourceString(gco.hhLib,id+100));
   }
}


static LRESULT DynDlgBox_DlgProc(
	HWND hwndDlg,
	UINT uMessage,
	WPARAM wParam,
	LPARAM lParam)
{
  switch (uMessage)
  {
    HANDLE_MSG(hwndDlg, WM_INITDIALOG, DynDlgBox_OnInitDialog);
    HANDLE_MSG(hwndDlg, WM_COMMAND, DynDlgBox_OnCommand);
      HANDLE_MSG(hwndDlg,WM_TIMER,Cls_OnTimer);
      HANDLE_MSG(hwndDlg,WM_SIZE,Cls_OnSize);
      HANDLE_MSG(hwndDlg,WM_MENUSELECT,Cls_OnMenuSelect);
      HANDLE_MSG(hwndDlg,WM_CLOSE,Cls_OnClose);
      HANDLE_MSG(hwndDlg,WM_DESTROY,Cls_OnDestroy);
	   HANDLE_MSG(hwndDlg,WM_PARENTNOTIFY,Cls_OnParentNotify);

    default :
   return CommonDlg_DefProc(hwndDlg, uMessage, wParam, lParam);
  }
}
