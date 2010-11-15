/* Do not alter this SPC information: $Revision: 1.1.29.1 $ */
/********************************************************************
Name:				lod.c
Authors:       Rick Kramer
Creation Date: 03/28/95
Description:   Main program for Loader Utility

Revision History:

********************************************************************/
#include <windows.h>
#include <windowsx.h>
#include <locale.h>
#include "gco.h"
#include "lod.h"
#include "dlgxext.h"
#include "dlgsec.h"
#include "resource.h"

#define lmain32_c
#include "lmain32.prt"
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
   IDCAT_FILES,
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
      { IDCAT_MAIN, TEXT("RISlod_Main"),TEXT("Main")},
      { IDCAT_FILES, TEXT("RISlod_Files"),TEXT("Files")},
      { IDCAT_SCHEMAS, TEXT("RISlod_Schemas"),TEXT("Schemas")},
      { IDCAT_TABLES,	TEXT("RISlod_Tables"),TEXT("Tables")}
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
   strcpy(lod.szAppName,"RISlod");

   // get handle to risres.dll
   gco.hhLib = _LoadResources(lod.szAppName);
   if (!gco.hhLib)
   {
      return (FALSE);
   }

   lod.argc = _ParseCommandLine(gco.hhInst, lpszCmdLine, &lod.argv);

   strcpy(lod.szTitle,_GetResourceString (gco.hhLib,IDS_LOD_DESC));

	if (!hinstPrev)
	{
		wndclass.style         = CS_HREDRAW | CS_VREDRAW ;
		wndclass.lpfnWndProc   = DefDlgProc ;
		wndclass.cbClsExtra    = 0 ;
		wndclass.cbWndExtra    = DLGWINDOWEXTRA ;
		wndclass.hInstance     = gco.hhInst ;
		wndclass.hIcon			  = LoadIcon(gco.hhInst, MAKEINTRESOURCE(IDI_LOD));
		wndclass.hCursor       = LoadCursor (NULL, IDC_ARROW) ;
		wndclass.hbrBackground = (HBRUSH)(COLOR_WINDOW+1);
		wndclass.lpszMenuName  = NULL ;
		wndclass.lpszClassName = lod.szAppName;

      lod.hIcon = wndclass.hIcon;
      gco.hCursor = wndclass.hCursor;

		// register the window class 
		if (!RegisterClass (&wndclass))
		{
			MessageBox(NULL,"RegisterClass() failed",lod.szTitle,MB_OK | MB_TASKMODAL | MB_ICONSTOP);
			return FALSE ;
		}
	}

   lod.hIntro= _CreateSplashScreen(NULL, lod.szTitle, lod.szAppName,lod.hIcon);
   UpdateWindow(lod.hIntro);


  DialogBox(gco.hhInst, TEXT("RISlod_tmp"), NULL, (DLGPROC) DynDlgBox);

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
   _InitDebug( lod.argc,lod.argv,hwndDlg, lod.szAppName );
   _InitProgram(lod.argc,lod.argv);

   if (!_InitStatusBar (hwndDlg))
   {
      _MessageBox (NULL,gco.hhLib,MB_OK | MB_TASKMODAL | MB_ICONSTOP,IDS_LOD_DESC,IDS_SBAR_FAIL);
      return FALSE;
   }

	// Init values here
	lod.nAnsi = TRUE;
	lod.nPreserve = FALSE;
	strcpy(lod.szDelim,"'");
	strcpy(lod.szInterval,"25");
	lod.nFileMode = IDC_LOD_FILEMODE_E;

	strcpy(lod.szDB[0],"Informix");
	strcpy(lod.szDB[1],"ORACLE");
	strcpy(lod.szDB[2],"SQL/DS");
	strcpy(lod.szDB[3],"Ingres");
	strcpy(lod.szDB[4],"DB2");
	strcpy(lod.szDB[5],"MS/SQL");
	strcpy(lod.szDB[6],"Rdb");
	strcpy(lod.szDB[7],"SYBASE");
	strcpy(lod.szDB[8],"OS400");
	for (i=0; i<9; i++)
		lod.nDB[i] = TRUE;

	strcpy(lod.szInputFile,"c:\\tmp\\ris.dmp");
	strcpy(lod.szLogFile,"c:\\tmp\\ris.log");
	strcpy(lod.szBadFile,"c:\\tmp\\ris.bad");

	strcpy(lod.szSchemas[0],"schema1");
	strcpy(lod.szSchemas[1],"schema3");
	strcpy(lod.szSchemas[2],"schema2");

	strcpy(lod.szViews[0],"view3");
	strcpy(lod.szViews[1],"view2");
	strcpy(lod.szViews[2],"view1");

	strcpy(lod.szPrivs[0],"priv2");
	strcpy(lod.szPrivs[1],"priv3");
	strcpy(lod.szPrivs[2],"priv1");

	strcpy(lod.szTabs[0],"tab2");
	strcpy(lod.szTabs[1],"tab3");
	strcpy(lod.szTabs[2],"tab1");

	strcpy(lod.szIndexs[0],"index3");
	strcpy(lod.szIndexs[1],"index2");
	strcpy(lod.szIndexs[2],"index1");

	lod.nTabDef = IDC_LOD_TABDEF_BOTH;
	lod.nTabExist = FALSE;
	lod.nClear = FALSE;
	
	strcpy(lod.szInputInitialDir,"c:\\tmp");
	strcpy(lod.szLogInitialDir,"c:\\tmp");
	strcpy(lod.szLogInitialDir,"c:\\tmp");

	// Initialise the dialog section.
  InitDlgSection(&dlgsec, IDS_TEXTFORMAT, hwndDlg, IDC_LOD_FRAME_DIALOGBOX, NULL);

  // Set threshold so that a category is always discarded when the user
  // selects another.

  SetDlgSectionThreshold(&dlgsec, 3, 5);
  
  // Add the categories to the section and their names to the list box.

  hwndProp = GetDlgItem(hwndDlg, IDC_LOD_PROPERTY);

  for (i = 0; i < ARRAY_COUNT(catdef); i++)
  {
    ListBox_AddString(hwndProp, catdef[i].lpszTitle);
    AddDlgSectionCategory(&dlgsec, gco.hhInst, catdef[i].lpszName, catdef[i].nID,
      DSCF_DISCARDABLE, NULL);
  }

  // Select the first category and list box selection.

  SelectDlgSectionCategory(&dlgsec, IDCAT_MAIN);
  ListBox_SetCurSel(hwndProp, 0);

_Delay(4);
   _DestroySplashScreen(lod.hIntro);
   _CenterWindowOnScreen(hwndDlg);
  return TRUE;
}

static void Cls_OnTimer(
	HWND hwnd,
	UINT id)
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
	int    status;
	char   fname_only[_MAX_PATH];
	char szFilter[128];
	char szFileName[_MAX_PATH];

  switch (nID)
  {
    case IDC_LOD_PROPERTY :

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
    _RunHelp(nID,hwndDlg,lod.szTitle,lod.szAppName,lod.hIcon);
    break;

    case IDM_RIS_DEBUG:
    DialogBox(gco.hhLib, MAKEINTRESOURCE(IDD_RISDBG),hwndDlg, (DLGPROC)RISdebug);
    break;

      case IDM_GUI_DEBUG:
	  _UpdateStatusBar("Selected DEBUG");
	  _DEBUG(PROG,2,"Selected Debug");
	  _DebugControlPanel( gco.hhLib,hwndDlg,FALSE );
    break;

	case IDC_LOD_BROWSE_INPUT:
		strcpy(szFilter,"Input Files (*.dmp)|*.dmp|All Files (*.*)|*.*|");

		status = _SelectFile (hwndDlg, szFileName, lod.szInputInitialDir,fname_only,"RISlod - Select input filename",szFilter,&lod.input_index);
		if (status == TRUE)
		{
			_Debug(PROG,2,"Selected input file <%s>",szFileName);
			Edit_SetText(GetDlgItem(hwndDlg,IDC_LOD_INPUTFILE), szFileName);
			strcpy(lod.szInputFile,fname_only);
		}
		break;

	case IDC_LOD_BROWSE_LOG:
		strcpy(szFilter,"Log Files (*.log)|*.log|All Files (*.*)|*.*|");

		status = _SelectFile (hwndDlg, szFileName, lod.szLogInitialDir,fname_only,"RISlod - Select Log filename",szFilter,&lod.log_index);
		if (status == TRUE)
		{
			_Debug(PROG,2,"Selected Log file <%s>",szFileName);
			Edit_SetText(GetDlgItem(hwndDlg,IDC_LOD_LOGFILE), szFileName);
			strcpy(lod.szLogFile,fname_only);
		}
		break;

	case IDC_LOD_BROWSE_BAD:
		strcpy(szFilter,"Bad Files (*.bad)|*.bad|All Files (*.*)|*.*|");

		status = _SelectFile (hwndDlg, szFileName, lod.szBadInitialDir,fname_only,"RISlod - Select Bad filename",szFilter,&lod.bad_index);
		if (status == TRUE)
		{
			_Debug(PROG,2,"Selected Bad File <%s>",szFileName);
			Edit_SetText(GetDlgItem(hwndDlg,IDC_LOD_BADFILE), szFileName);
			strcpy(lod.szBadFile,fname_only);
		}
		break;

  }
}

static void SaveCategoryState(
	HWND hwndDlg,
	int nCatID)
{
  switch (nCatID)
  {
	case IDCAT_MAIN :
	case IDCAT_FILES:
	case IDCAT_SCHEMAS:
	case IDCAT_TABLES:
      break;
  }
}

static void RestoreCategoryState(
	HWND hwndDlg,
	int nCatID)
{
	int i;

  switch (nCatID)
  {
	case IDCAT_MAIN :
      CheckDlgButton(hwndDlg, IDC_LOD_ANSI, lod.nAnsi);
      CheckDlgButton(hwndDlg, IDC_LOD_PRESERVE, lod.nPreserve);
		Edit_SetText(GetDlgItem(hwndDlg,IDC_LOD_DELIM), lod.szDelim);
		Edit_SetText(GetDlgItem(hwndDlg,IDC_LOD_COMMIT), lod.szInterval);
      CheckRadioButton(hwndDlg, IDC_LOD_FILEMODE_O, IDC_LOD_FILEMODE_E, lod.nFileMode);
		for (i=0; i<9;i++)
		{
			ListBox_AddString(GetDlgItem(hwndDlg,IDC_LOD_DB),lod.szDB[i]);
			ListBox_SetSel(GetDlgItem(hwndDlg,IDC_LOD_DB), lod.nDB[i], i);
		}
		break;

	case IDCAT_FILES:
		Edit_SetText(GetDlgItem(hwndDlg,IDC_LOD_INPUTFILE), lod.szInputFile);
		Edit_SetText(GetDlgItem(hwndDlg,IDC_LOD_LOGFILE), lod.szLogFile);
		Edit_SetText(GetDlgItem(hwndDlg,IDC_LOD_BADFILE), lod.szBadFile);
		break;

	case IDCAT_SCHEMAS:
		ListBox_AddString(GetDlgItem(hwndDlg,IDC_LOD_SCHEMAS),lod.szSchemas[0]);
		ListBox_AddString(GetDlgItem(hwndDlg,IDC_LOD_SCHEMAS),lod.szSchemas[1]);
		ListBox_AddString(GetDlgItem(hwndDlg,IDC_LOD_SCHEMAS),lod.szSchemas[2]);

		ListBox_AddString(GetDlgItem(hwndDlg,IDC_LOD_VIEWS),lod.szViews[0]);
		ListBox_AddString(GetDlgItem(hwndDlg,IDC_LOD_VIEWS),lod.szViews[1]);
		ListBox_AddString(GetDlgItem(hwndDlg,IDC_LOD_VIEWS),lod.szViews[2]);

		ListBox_AddString(GetDlgItem(hwndDlg,IDC_LOD_PRIVS),lod.szPrivs[0]);
		ListBox_AddString(GetDlgItem(hwndDlg,IDC_LOD_PRIVS),lod.szPrivs[1]);
		ListBox_AddString(GetDlgItem(hwndDlg,IDC_LOD_PRIVS),lod.szPrivs[2]);
		break;

	case IDCAT_TABLES:
		ComboBox_AddString(GetDlgItem(hwndDlg,IDC_LOD_TABSCHEMAS),lod.szSchemas[0]);
		ComboBox_AddString(GetDlgItem(hwndDlg,IDC_LOD_TABSCHEMAS),lod.szSchemas[1]);
		ComboBox_AddString(GetDlgItem(hwndDlg,IDC_LOD_TABSCHEMAS),lod.szSchemas[2]);
		ListBox_AddString(GetDlgItem(hwndDlg,IDC_LOD_TABLES),lod.szTabs[0]);
		ListBox_AddString(GetDlgItem(hwndDlg,IDC_LOD_TABLES),lod.szTabs[1]);
		ListBox_AddString(GetDlgItem(hwndDlg,IDC_LOD_TABLES),lod.szTabs[2]);
		ListBox_AddString(GetDlgItem(hwndDlg,IDC_LOD_INDEXES),lod.szIndexs[0]);
		ListBox_AddString(GetDlgItem(hwndDlg,IDC_LOD_INDEXES),lod.szIndexs[1]);
		ListBox_AddString(GetDlgItem(hwndDlg,IDC_LOD_INDEXES),lod.szIndexs[2]);
      CheckRadioButton(hwndDlg, IDC_LOD_TABDEF_BOTH, IDC_LOD_TABDEF_DEF, lod.nTabDef);
      CheckDlgButton(hwndDlg, IDC_LOD_TABEXIST, lod.nTabExist);
      CheckDlgButton(hwndDlg, IDC_LOD_CLEAR, lod.nClear);
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
	 _TimedMsgBox(gco.hhLib, hwnd, "Clean up RIS (RIS_terminate)","Temporary",MB_OK | MB_ICONINFORMATION , IDS_LOD_DESC, 1);
   WinHelp(hwnd,"risutl.hlp",HELP_QUIT,0L);
   KillTimer(hwnd,1);
   DestroyIcon(lod.hIcon);
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

