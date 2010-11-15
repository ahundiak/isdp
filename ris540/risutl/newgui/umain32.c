/* Do not alter this SPC information: $Revision: 1.1.29.1 $ */
/********************************************************************
Name:				unlod.c
Authors:       Rick Kramer
Creation Date: 03/28/95
Description:   Main program for Unloader Utility

Revision History:

********************************************************************/
#include <windows.h>
#include <windowsx.h>
#include <locale.h>
#include "gco.h"
#include "unlod.h"
#include "dlgxext.h"
#include "dlgsec.h"
#include "resource.h"

#define umain32_c
#include "umain32.prt"
#include "gcocat.prt"
#include "gcosec.prt"
#include "gcosbar.prt"
#include "gcortns.prt"
#include "gcodbg.prt"
#include "gcordbg.prt"
#include "gcotmess.prt"
#include "gcointro.prt"

// Constants

#define IDS_TEXTFORMAT	0x1234

enum {
   IDCAT_MAIN,
   IDCAT_SCHEMAS,
	IDCAT_TABLES
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
      { IDCAT_MAIN, TEXT("RISunlod_Main"),TEXT("Main")},
      { IDCAT_SCHEMAS, TEXT("RISunlod_Schemas"),TEXT("Schemas")},
      { IDCAT_TABLES,	TEXT("RISunlod_Tables"),TEXT("Tables")}
};
gco_globals gco;


int PASCAL WinMain(hinstA, hinstPrev, lpszCmdLine, nCmdShow)
HINSTANCE   hinstA;
HINSTANCE   hinstPrev;
LPSTR	 lpszCmdLine;
int	 nCmdShow;
{
	WNDCLASS    wndclass ; // the window class

   setlocale(LC_ALL, "");

   gco.hhInst = hinstA;
   strcpy(unlod.szAppName,"RISunlod");

   // get handle to risres.dll
   gco.hhLib = _LoadResources(unlod.szAppName);
   if (!gco.hhLib)
   {
      return (FALSE);
   }

   unlod.argc = _ParseCommandLine(gco.hhInst, lpszCmdLine, &unlod.argv);


   strcpy(unlod.szTitle,_GetResourceString (gco.hhLib,IDS_UNLOD_DESC));

	if (!hinstPrev)
	{
		wndclass.style         = CS_HREDRAW | CS_VREDRAW ;
		wndclass.lpfnWndProc   = DefDlgProc ;
		wndclass.cbClsExtra    = 0 ;
		wndclass.cbWndExtra    = DLGWINDOWEXTRA ;
		wndclass.hInstance     = gco.hhInst ;
		wndclass.hIcon			  = LoadIcon(gco.hhInst, MAKEINTRESOURCE(IDI_UNLOD));
		wndclass.hCursor       = LoadCursor (NULL, IDC_ARROW) ;
		wndclass.hbrBackground = (HBRUSH)(COLOR_WINDOW+1);
		wndclass.lpszMenuName  = NULL ;
		wndclass.lpszClassName = unlod.szAppName;

      unlod.hIcon = wndclass.hIcon;
      gco.hCursor = wndclass.hCursor;

		// register the window class 
		if (!RegisterClass (&wndclass))
		{
			MessageBox(NULL,"RegisterClass() failed",unlod.szTitle,MB_OK | MB_TASKMODAL | MB_ICONSTOP);
			return FALSE ;
		}
	}
   unlod.hIntro= _CreateSplashScreen(NULL, unlod.szTitle, unlod.szAppName,unlod.hIcon);
   UpdateWindow(unlod.hIntro);


  DialogBox(gco.hhInst, TEXT("RISunlod_tmp"), NULL, (DLGPROC) DynDlgBox);

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
  HWND	  hwndProp;

   _AddUtilityMenu(hwndDlg, 1);
   _AddHelpMenu(hwndDlg);
   _InitDebug( unlod.argc,unlod.argv,hwndDlg, unlod.szAppName );
   _InitProgram(unlod.argc,unlod.argv);

   if (!_InitStatusBar (hwndDlg))
   {
      _MessageBox (NULL,gco.hhLib,MB_OK | MB_TASKMODAL | MB_ICONSTOP,IDS_UNLOD_DESC,IDS_SBAR_FAIL);
      return FALSE;
   }

	// Init values here
	unlod.nPreserve = IDC_UNLOD_PRESERVE_N;
	unlod.nFileMode = IDC_UNLOD_MODE_E;
	unlod.nTabDef = IDC_UNLOD_TABDEF_BOTH;
	unlod.nDataFiles = IDC_UNLOD_DATA_SAME;
	unlod.nDataFormat = IDC_UNLOD_DATA_FIXED;
	strcpy(unlod.mainfile,"c:\\tmp\\ris.dmp");

	unlod.index = 1;
	strcpy(unlod.szInitialDir,"c:\\tmp");


	strcpy(unlod.szSchemas[0],"schema1");
	strcpy(unlod.szSchemas[1],"schema3");
	strcpy(unlod.szSchemas[2],"schema2");

	strcpy(unlod.szViews[0],"view3");
	strcpy(unlod.szViews[1],"view2");
	strcpy(unlod.szViews[2],"view1");

	strcpy(unlod.szPrivs[0],"priv2");
	strcpy(unlod.szPrivs[1],"priv3");
	strcpy(unlod.szPrivs[2],"priv1");

	strcpy(unlod.szTabs[0],"tab2");
	strcpy(unlod.szTabs[1],"tab3");
	strcpy(unlod.szTabs[2],"tab1");

	strcpy(unlod.szIndexs[0],"index3");
	strcpy(unlod.szIndexs[1],"index2");
	strcpy(unlod.szIndexs[2],"index1");



   // Initialise the dialog section.
  InitDlgSection(&dlgsec, IDS_TEXTFORMAT, hwndDlg, IDC_UNLOD_FRAME_DIALOGBOX, NULL);

  // Set threshold so that a category is always discarded when the user
  // selects another.

  SetDlgSectionThreshold(&dlgsec, 3, 5);
  
  // Add the categories to the section and their names to the list box.

  hwndProp = GetDlgItem(hwndDlg, IDC_UNLOD_PROPERTY);

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
	_Delay(1);
   _DestroySplashScreen(unlod.hIntro);
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
  char   fname_only[256];
  int    status;
	char filter[128] = "DMP Files (*.dmp)|*.dmp|All Files (*.*)|*.*|";

  switch (nID)
  {
    case IDC_UNLOD_PROPERTY :

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

//      DeleteDlgSection(&dlgsec);
//      EndDialog(hwndDlg, nID == IDOK);
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
    _RunHelp(nID,hwndDlg,unlod.szTitle,unlod.szAppName,unlod.hIcon);
    break;

    case IDM_RIS_DEBUG:
    DialogBox(gco.hhLib, MAKEINTRESOURCE(IDD_RISDBG),hwndDlg, (DLGPROC)RISdebug);
    break;

      case IDM_GUI_DEBUG:
	  _UpdateStatusBar("Selected DEBUG");
	  _DEBUG(PROG,2,"Selected Debug");
	  _DebugControlPanel( gco.hhLib,hwndDlg,FALSE );
    break;

	case IDC_UNLOD_BROWSE:
		strcpy ( unlod.mainfile, "" );
		status = _SelectFile (hwndDlg, unlod.mainfile, unlod.szInitialDir,fname_only,"RISunlod - Select output filename",filter,&unlod.index);
_DEBUG(PROG,2,"Status=%d fname_only=<%s> filename=<%s>",status,fname_only,unlod.mainfile);
		if (status == TRUE)
			Edit_SetText(GetDlgItem(hwndDlg,IDC_UNLOD_OUTPUT_FILE), unlod.mainfile);
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
		for (i=IDC_UNLOD_PRESERVE_Y; i<=IDC_UNLOD_PRESERVE_N; i++)
		{
	      if (IsDlgButtonChecked(hwndDlg, i) ==TRUE)
				unlod.nPreserve = i;
		}

		for (i=IDC_UNLOD_MODE_O; i<=IDC_UNLOD_MODE_E; i++)
		{
	      if (IsDlgButtonChecked(hwndDlg, i) ==TRUE)
				unlod.nFileMode = i;
		}
		Edit_GetText(GetDlgItem(hwndDlg,IDC_UNLOD_OUTPUT_FILE), unlod.mainfile, 255);
		break;
	case IDCAT_SCHEMAS:
		break;
	case IDCAT_TABLES:
		for (i=IDC_UNLOD_TABDEF_BOTH; i<=IDC_UNLOD_TABDEF_DEF; i++)
		{
	      if (IsDlgButtonChecked(hwndDlg, i) ==TRUE)
				unlod.nTabDef = i;
		}

		for (i=IDC_UNLOD_DATA_SAME; i<=IDC_UNLOD_DATA_DIFF; i++)
		{
	      if (IsDlgButtonChecked(hwndDlg, i) ==TRUE)
				unlod.nDataFiles = i;
		}

		for (i=IDC_UNLOD_DATA_FIXED; i<=IDC_UNLOD_DATA_VAR; i++)
		{
	      if (IsDlgButtonChecked(hwndDlg, i) ==TRUE)
				unlod.nDataFormat = i;
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
      CheckRadioButton(hwndDlg, IDC_UNLOD_PRESERVE_Y, IDC_UNLOD_PRESERVE_N, unlod.nPreserve);
      CheckRadioButton(hwndDlg, IDC_UNLOD_MODE_O, IDC_UNLOD_MODE_E, unlod.nFileMode);
		Edit_SetText(GetDlgItem(hwndDlg,IDC_UNLOD_OUTPUT_FILE), unlod.mainfile);
		break;

	case IDCAT_SCHEMAS:
		ListBox_AddString(GetDlgItem(hwndDlg,IDC_UNLOD_SCHEMAS),unlod.szSchemas[0]);
		ListBox_AddString(GetDlgItem(hwndDlg,IDC_UNLOD_SCHEMAS),unlod.szSchemas[1]);
		ListBox_AddString(GetDlgItem(hwndDlg,IDC_UNLOD_SCHEMAS),unlod.szSchemas[2]);

		ListBox_AddString(GetDlgItem(hwndDlg,IDC_UNLOD_VIEW),unlod.szViews[0]);
		ListBox_AddString(GetDlgItem(hwndDlg,IDC_UNLOD_VIEW),unlod.szViews[1]);
		ListBox_AddString(GetDlgItem(hwndDlg,IDC_UNLOD_VIEW),unlod.szViews[2]);

		ListBox_AddString(GetDlgItem(hwndDlg,IDC_UNLOD_PRIV),unlod.szPrivs[0]);
		ListBox_AddString(GetDlgItem(hwndDlg,IDC_UNLOD_PRIV),unlod.szPrivs[1]);
		ListBox_AddString(GetDlgItem(hwndDlg,IDC_UNLOD_PRIV),unlod.szPrivs[2]);

		break;

	case IDCAT_TABLES:
      CheckRadioButton(hwndDlg, IDC_UNLOD_TABDEF_BOTH, IDC_UNLOD_TABDEF_DEF, unlod.nTabDef);
      CheckRadioButton(hwndDlg, IDC_UNLOD_DATA_SAME, IDC_UNLOD_DATA_DIFF, unlod.nDataFiles);
      CheckRadioButton(hwndDlg, IDC_UNLOD_DATA_FIXED, IDC_UNLOD_DATA_VAR, unlod.nDataFormat);
		ComboBox_AddString(GetDlgItem(hwndDlg,IDC_UNLOD_SCHEMAS1),unlod.szSchemas[0]);
		ComboBox_AddString(GetDlgItem(hwndDlg,IDC_UNLOD_SCHEMAS1),unlod.szSchemas[1]);
		ComboBox_AddString(GetDlgItem(hwndDlg,IDC_UNLOD_SCHEMAS1),unlod.szSchemas[2]);
		Edit_SetText(GetDlgItem(hwndDlg,IDC_UNLOD_TAB1), unlod.szTabs[0]);
		Edit_SetText(GetDlgItem(hwndDlg,IDC_UNLOD_TAB2), unlod.szTabs[1]);
		Edit_SetText(GetDlgItem(hwndDlg,IDC_UNLOD_TAB3), unlod.szTabs[2]);
		ListBox_AddString(GetDlgItem(hwndDlg,IDC_UNLOD_INDEX),unlod.szIndexs[0]);
		ListBox_AddString(GetDlgItem(hwndDlg,IDC_UNLOD_INDEX),unlod.szIndexs[1]);
		ListBox_AddString(GetDlgItem(hwndDlg,IDC_UNLOD_INDEX),unlod.szIndexs[2]);

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
 	_TimedMsgBox(gco.hhLib, hwnd, "Clean up RIS (RIS_terminate)","Temporary",MB_OK | MB_ICONINFORMATION , IDS_UNLOD_DESC, 1);
   WinHelp(hwnd,"risutl.hlp",HELP_QUIT,0L);
   KillTimer(hwnd,1);
   DestroyIcon(unlod.hIcon);
//      DeleteDlgSection(&dlgsec);

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
//	if (id >= IDC_CLNSR_SCHEMAS && id <= IDC_CLNSR_EXIT)
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
