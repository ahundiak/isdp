/* Do not alter this SPC information: $Revision: 1.1.29.1 $ */
/********************************************************************
Name:	 	      clnsr.c
Authors:       Rick Kramer
Creation Date: 03/01/95
Description:   Main program for Clean Server Utility

Revision History:
03/17/95 RLK   Added this header

********************************************************************/
#include <windows.h>
#include <windowsx.h>
#include <locale.h>
#include "gco.h"
#include "resource.h"
#include "clnsr.h"

#define csmain_c
#include "csmain.prt"
#include "gcosbar.prt"
#include "gcortns.prt"
#include "gcodbg.prt"
#include "gcordbg.prt"
#include "gcointro.prt"
#include "gcotmess.prt"

#define RICK 1
//#define _DB2(s) if (RICK) {_Debug(__FILE__,__LINE__,2,s);}


gco_globals gco;

#define DELAY_TIME 4 //to be deleted

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
int PASCAL WinMain (HANDLE hInstance, HANDLE hPrevInstance,
   LPSTR lpszCmdLine, int nCmdShow)
{
	WNDCLASS    wndclass ; // the window class
	HWND hwnd;

	setlocale(LC_ALL, "");

   gco.hhInst = hInstance;
   strcpy(clnsr.szAppName,"RISclnsr");

   // get handle to risres.dll
   gco.hhLib = _LoadResources(clnsr.szAppName);
   if (!gco.hhLib)
   {
      return (FALSE);
   }

   clnsr.argc = _ParseCommandLine(hInstance, lpszCmdLine, &clnsr.argv);


   strcpy(clnsr.szTitle,_GetResourceString (gco.hhLib,IDS_CLNSR_DESC));

	hwnd = FindWindow (clnsr.szAppName, NULL);
	if (hwnd)
	{
		MessageBox(NULL,"Application is already running; Switching to that instance",clnsr.szAppName,MB_OK);
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
		wndclass.hIcon			  = LoadIcon(gco.hhInst, MAKEINTRESOURCE(IDI_CLNSR));
		wndclass.hCursor       = LoadCursor(NULL,IDC_ARROW);
		wndclass.hbrBackground = (HBRUSH)(COLOR_WINDOW+1);
		wndclass.lpszMenuName  = NULL ;
		wndclass.lpszClassName = clnsr.szAppName;

      clnsr.hIcon = wndclass.hIcon;
      gco.hCursor = wndclass.hCursor;

		// register the window class 
		if (!RegisterClass (&wndclass))
		{
			MessageBox(NULL,"RegisterClass() failed",clnsr.szTitle,MB_OK | MB_TASKMODAL | MB_ICONSTOP);
			return FALSE ;
		}
	}

   clnsr.hIntro= _CreateSplashScreen(NULL, clnsr.szTitle, clnsr.szAppName,clnsr.hIcon);
   UpdateWindow(clnsr.hIntro);

	DialogBox (gco.hhInst, MAKEINTRESOURCE(IDD_CLNSR), NULL,(DLGPROC)DlgProc) ;

   FreeLibrary(gco.hhLib);

   return FALSE ;
}

/********************************************************************
Function:
Description:
Variables:
	  
	  
	  

Return Value:


********************************************************************/
static BOOL Cls_OnInitDialog(HWND hwnd, HWND hwndFocus, LPARAM lParam)
{
	HMENU hMenu;

	//Initialize
   _AddUtilityMenu(hwnd, 1);
   _AddHelpMenu(hwnd);
   _InitDebug( clnsr.argc,clnsr.argv,hwnd, clnsr.szAppName );
   _InitProgram(clnsr.argc,clnsr.argv);

	// disable RISclnsr
	hMenu = GetMenu(hwnd);
	EnableMenuItem(hMenu,IDM_UTIL_CLNSR,MF_DISABLED | MF_GRAYED | MF_BYCOMMAND);

   if (!_InitStatusBar (hwnd))
   {
      _MessageBox (NULL,gco.hhLib,MB_OK | MB_TASKMODAL | MB_ICONSTOP,IDS_CLNSR_DESC,IDS_SBAR_FAIL);
      return FALSE;
   }
GetSchemaNames(hwnd);

//_Delay(DELAY_TIME);
   _DestroySplashScreen(clnsr.hIntro);
   _CenterWindowOnScreen(hwnd);
   return TRUE ;
}

/********************************************************************
Function:
Description:
Variables:
	  
	  
	  

Return Value:


********************************************************************/
static void Cls_OnCommand(HWND hwnd, int id, HWND hwndCtl, UINT codeNotify)
{
   char lpszBuffer[1024];
   HWND hDlg;
	int nSel;

	_Debug(PROG,2,"id=%d",id);
	switch (id)
	{
		case IDC_CLNSR_CLEAN:
			_UpdateStatusBar("Cleaning Schemas, please wait...");
			STARTWAIT;
			_Delay(DELAY_TIME);

			hDlg = GetDlgItem(hwnd,IDC_CLNSR_SCHEMAS);

			nSel = ListBox_GetCurSel(hDlg);
			ListBox_GetText(hDlg, nSel, lpszBuffer);
		   _DEBUG(PROG,2,"Selected <%s> %d",lpszBuffer,nSel);

	      Button_Enable(GetDlgItem(hwnd,IDC_CLNSR_CLEAN), FALSE);
			ListBox_DeleteString(hDlg, nSel);
		   ListBox_SetCurSel(hDlg,-1);
			ENDWAIT;
			_UpdateStatusBar("Cleaning Schemas has completed");
			break;

      case IDC_CLNSR_SCHEMAS:
	 if (codeNotify == LBN_SELCHANGE)
	 {
	    _Debug(PROG,2,"got notify");
      Button_Enable(GetDlgItem(hwnd,IDC_CLNSR_CLEAN), TRUE);
	 }
	 break;

      case IDC_CLNSR_RESTART:
	 ListBox_ResetContent(GetDlgItem(hwnd,IDC_CLNSR_SCHEMAS));
	 GetSchemaNames(hwnd);
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
	 _RunHelp(id,hwnd,clnsr.szTitle,clnsr.szAppName,clnsr.hIcon);
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

/********************************************************************
Function:
Description:
Variables:
	  
	  
	  

Return Value:


********************************************************************/
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
static void Cls_OnSize(HWND hwnd, UINT state, int cx, int cy)
{
   _AdjustStatusBar (hwnd);
}


/********************************************************************
Function:
Description:
Variables:
	  
	  
	  

Return Value:


********************************************************************/
static void Cls_OnClose(HWND hwnd)
{
   WinHelp(hwnd,"risutl.hlp",HELP_QUIT,0L);
   KillTimer(hwnd,1);
	_TimedMsgBox(gco.hhLib, hwnd, "Clean up RIS (RIS_terminate)","Temporary",MB_OK | MB_ICONINFORMATION , IDS_CLNSR_DESC, 1);

   EndDialog (hwnd, 0) ;
}

/********************************************************************
Function:
Description:
Variables:
	  
	  
	  

Return Value:


********************************************************************/
static void Cls_OnMenuSelect(HWND hwnd, HMENU hmenu, int item, HMENU hmenuPopup, UINT flags)
{
   char szMsg[255];

   _DEBUG(PROG,2,"Item = %d",item);
   strcpy(szMsg, _GetResourceString(gco.hhLib,item));
   _UpdateStatusBar(szMsg);


}

/********************************************************************
Function:
Description:
Variables:
	  
	  
	  

Return Value:


********************************************************************/
void Cls_OnDestroy(HWND hwnd)
{
   PostQuitMessage(0);
}


/********************************************************************
Function:
Description:
Variables:
	  
	  
	  

Return Value:


********************************************************************/
static void Cls_OnParentNotify(HWND hwnd, UINT msg, HWND hwndChild, int idChild)
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
      if (id >= IDC_CLNSR_SCHEMAS && id <= IDC_CLNSR_RESTART)
	 _UpdateStatusBar(_GetResourceString(gco.hhLib,id+100));
   }
}

/********************************************************************
Function:
Description:
Variables:
	  
	  
	  

Return Value:


********************************************************************/
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
      HANDLE_MSG(hwnd,WM_DESTROY,Cls_OnDestroy);
      HANDLE_MSG(hwnd,WM_PARENTNOTIFY,Cls_OnParentNotify);
   }
   return FALSE ;
}


/********************************************************************
Function:      GetSchemaNames
Description:
Variables:     hwnd Input, dialog window handle
Return Value:  None
********************************************************************/
static void GetSchemaNames(HWND hwnd)
{
   HWND hDlg;
   int i;

   _UpdateStatusBar("Getting Schemas, please wait...");
   STARTWAIT;
	_Delay(DELAY_TIME);


   hDlg = GetDlgItem(hwnd,IDC_CLNSR_SCHEMAS);

   for (i = IDS_CLNSR_S1; i <= IDS_CLNSR_S9; i++)
      ListBox_AddString(hDlg,_GetResourceString(gco.hhLib,i));
   ListBox_SetCurSel(hDlg,-1);
   SetFocus(hDlg);

	Button_Enable(GetDlgItem(hwnd,IDC_CLNSR_CLEAN), FALSE);

   ENDWAIT;
   _UpdateStatusBar("");
}


