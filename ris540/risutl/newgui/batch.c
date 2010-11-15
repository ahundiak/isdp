/* Do not alter this SPC information: $Revision: 1.7.28.1 $ */
/********************************************************************
Name:				batch.c
Authors:       Rick Kramer
Creation Date: 03/01/95
Description:   Main program for Batch Utility

Revision History:
03/17/95 RLK   Added this header

********************************************************************/
#include <windows.h>
#include <windowsx.h>
#include <locale.h>
#include <stdio.h>
#include "gco.h"
#include "batch.h"
#include "resource.h"

#define batch_c
#include "batch.prt"
#include "gcosbar.prt"
#include "gcortns.prt"
#include "gcodbg.prt"
#include "gcordbg.prt"
#include "gcotmess.prt"

#define RICK 1
//#define _DB2(s) if (RICK) {_Debug(__FILE__,__LINE__,2,s);}


gco_globals gco;


char *szCommands[] = {
"show client location",
"start client",
"stop client",
"show default schema",
"show schema file location",
"show schema names",
"show schema transactions",
"checksum schema file",
"show superschema definition",
"show superschema names",
"show flags",
"show parameters",
"ignore errors",
"process errors",
"quit",
NULL
};

#define DELAY_TIME 3 //to be deleted

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
	int i;
	int nInput=FALSE;
	int nOutput=FALSE;

	// Used from a article in WindowsTech Magazine 7/92 by Char;es Petzold
   setlocale(LC_ALL, "");

   gco.hhInst = hInstance;
   strcpy(batch.szAppName,"RISbatch");

   // get handle to risres.dll
   gco.hhLib = _LoadResources(batch.szAppName);
   if (!gco.hhLib)
   {
      return (FALSE);
   }

   batch.argc = _ParseCommandLine(hInstance, lpszCmdLine, &batch.argv);

	// find mode
	batch.nMode = ALL_INTERACTIVE;
	strcpy(batch.szInputFile,"");
	strcpy(batch.szOutputFile,"");
	for (i=0; i<batch.argc; i++)
	{
		if (strcmp(batch.argv[i],"-i") == 0)
		{
			nInput = TRUE;
			strcpy(batch.szInputFile,batch.argv[i+1]);
		}
		if (strcmp(batch.argv[i],"-o") == 0)
		{
			nOutput = TRUE;
			strcpy(batch.szOutputFile,batch.argv[i+1]);
		}
	}
	if (nInput == TRUE && nOutput == TRUE)
		batch.nMode = ALL_FILE;
	else if (nInput == TRUE)
		batch.nMode = IN_FILE_ONLY;
	else if (nOutput == TRUE)
		batch.nMode = OUT_FILE_ONLY;

   strcpy(batch.szTitle,_GetResourceString (gco.hhLib,IDS_BATCH_DESC));

	if (!hPrevInstance)    // load data into window class struct. 
	{
		wndclass.style         = CS_HREDRAW | CS_VREDRAW ;
		wndclass.lpfnWndProc   = DefDlgProc ;
		wndclass.cbClsExtra    = 0 ;
		wndclass.cbWndExtra    = DLGWINDOWEXTRA ;
		wndclass.hInstance     = hInstance ;
		wndclass.hIcon			  = LoadIcon(gco.hhInst, MAKEINTRESOURCE(IDI_BATCH));
		wndclass.hCursor       = LoadCursor (NULL, IDC_ARROW) ;
		wndclass.hbrBackground = (HBRUSH)(COLOR_WINDOW+1);
		wndclass.lpszMenuName  = NULL ;
		wndclass.lpszClassName = batch.szAppName;

      batch.hIcon = wndclass.hIcon;
      gco.hCursor = wndclass.hCursor;

		// register the window class 
		if (!RegisterClass (&wndclass))
		{
			MessageBox(NULL,"RegisterClass() failed",batch.szTitle,MB_OK | MB_TASKMODAL | MB_ICONSTOP);
			return FALSE ;
		}
	}
	if (batch.nMode != ALL_FILE)
	   DialogBox (gco.hhInst, MAKEINTRESOURCE(IDD_BATCH), NULL,(DLGPROC)DlgProc) ;

	if (batch.nMode == ALL_FILE)
	{
		_TimedMsgBox(gco.hhLib, NULL, "All File Mode","Temporary",MB_OK | MB_ICONINFORMATION , IDS_BATCH_DESC, 2);
	}
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
	char wrk[255];

	//Initialize
   _AddUtilityMenu(hwnd, 5);
   _AddHelpMenu(hwnd);
   _InitDebug( batch.argc,batch.argv,hwnd, batch.szAppName );
   _InitProgram(batch.argc,batch.argv);

	_Debug(PROG,0,"OnInitDialog: hwnd=%08X focus=%d",hwnd,GetDlgCtrlID(hwndFocus)); 
	GetClassName(hwnd,wrk,sizeof(wrk));
	_Debug(PROG,2,"OnInitDialog: class=<%s>",wrk); 
	_Debug(PROG,2,"OnInitDialog: Batch mode = %d", batch.nMode); 
	_Debug(PROG,2,"OnInitDialog: IDC_BATCH_COMMANDS=%08X id=%d",GetDlgItem(hwnd,IDC_BATCH_COMMANDS),IDC_BATCH_COMMANDS);


   if (!_InitStatusBar (hwnd))
   {
      _MessageBox (NULL,gco.hhLib,MB_OK | MB_TASKMODAL | MB_ICONSTOP,IDS_BATCH_DESC,IDS_SBAR_FAIL);
      return FALSE;
   }

	batch.hMenu = GetMenu(hwnd);

	// set output
	CheckRadioButton(hwnd, IDC_BATCH_TOSCREEN, IDC_BATCH_TOFILE, IDC_BATCH_TOSCREEN);
	Edit_SetText(GetDlgItem(hwnd,IDC_BATCH_FILENAME), "c:\\tmp\\batch.brf");
	Edit_Enable(GetDlgItem(hwnd,IDC_BATCH_FILENAME), FALSE);
	Button_Enable(GetDlgItem(hwnd,IDC_BATCH_START), FALSE);


	ListBox_ResetContent(GetDlgItem(hwnd,IDC_BATCH_RESULTS));
	// set list box horizontal extension
	ListBox_SetHorizontalExtent(GetDlgItem(hwnd,IDC_BATCH_RESULTS), 320);

	strcpy(batch.szComFile,"");
	EnableMenuItem (batch.hMenu, IDM_BATCH_FILE_SAVE, MF_BYCOMMAND | MF_GRAYED);
	EnableMenuItem (batch.hMenu, IDM_BATCH_FILE_SAVERESULTS, MF_BYCOMMAND | MF_GRAYED);

	_CenterWindowOnScreen(hwnd);

	// set values based on command line
	if (batch.nMode != ALL_FILE)
	{
		if (strcmp(batch.szInputFile,"") !=0)
		{
				_ReadFile2Control(GetDlgItem(hwnd,IDC_BATCH_COMMANDS),batch.szInputFile);
				Button_Enable(GetDlgItem(hwnd,IDC_BATCH_START), TRUE);

		}

		if (strcmp(batch.szOutputFile,"") !=0)
			Edit_SetText(GetDlgItem(hwnd,IDC_BATCH_FILENAME), batch.szOutputFile);
	}
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
HWND hwnd1;
int nDlgID;
	char   fname_only[_MAX_PATH];
	int    status;
	char OpenFilter[128] = "Batch Files (*.btc)|*.btc|All Files (*.*)|*.*|";
	char SaveFilter[128];
	char szFileName[_MAX_PATH];
	char wrk[80];

	_Debug(PROG,0,"OnCommand: hwnd=%08X id=%d hwndCtl=%d codeNotify=%d",hwnd,id,GetDlgCtrlID(hwndCtl),codeNotify); 
   switch (id)
   {
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
	 _RunHelp(id,hwnd,batch.szTitle,batch.szAppName,batch.hIcon);
	 break;

      case IDM_RIS_DEBUG:
	 DialogBox(gco.hhLib, MAKEINTRESOURCE(IDD_RISDBG),hwnd, (DLGPROC)RISdebug);
	 break;

      case IDM_GUI_DEBUG:
	       _UpdateStatusBar("Selected DEBUG");
	       _DEBUG(PROG,2,"Selected Debug");
	       _DebugControlPanel( gco.hhLib,hwnd,FALSE );
	 break;

		case IDC_BATCH_TOSCREEN:
		case IDC_BATCH_TOFILE:
			CheckRadioButton(hwnd, IDC_BATCH_TOSCREEN, IDC_BATCH_TOFILE, id);
	      if (IsDlgButtonChecked(hwnd, IDC_BATCH_TOSCREEN))
				Edit_Enable(GetDlgItem(hwnd,IDC_BATCH_FILENAME), FALSE);
			else
				Edit_Enable(GetDlgItem(hwnd,IDC_BATCH_FILENAME), TRUE);
			break;

		case IDC_BATCH_COMMANDS:
			if (Edit_GetTextLength(GetDlgItem(hwnd,id)) >0)
			{
				Button_Enable(GetDlgItem(hwnd,IDC_BATCH_START), TRUE);
				EnableMenuItem (batch.hMenu, IDM_BATCH_FILE_SAVE, MF_BYCOMMAND | MF_ENABLED);
			}
			else
			{
				Button_Enable(GetDlgItem(hwnd,IDC_BATCH_START), FALSE);
				EnableMenuItem (batch.hMenu, IDM_BATCH_FILE_SAVE, MF_BYCOMMAND | MF_GRAYED);
			}
			break;

		case IDC_BATCH_START:
			STARTWAIT;

ListBox_AddString(GetDlgItem(hwnd,IDC_BATCH_RESULTS),"[default schema rick;]");
ListBox_AddString(GetDlgItem(hwnd,IDC_BATCH_RESULTS),"");
ListBox_AddString(GetDlgItem(hwnd,IDC_BATCH_RESULTS),"[select * from ris5tables where table_name = 'records';]");
ListBox_AddString(GetDlgItem(hwnd,IDC_BATCH_RESULTS),"");
ListBox_AddString(GetDlgItem(hwnd,IDC_BATCH_RESULTS),"schema_name      : 'rick'");
ListBox_AddString(GetDlgItem(hwnd,IDC_BATCH_RESULTS),"table_name       : 'records'");
ListBox_AddString(GetDlgItem(hwnd,IDC_BATCH_RESULTS),"dbms_owner       : 'rlkramer'");
ListBox_AddString(GetDlgItem(hwnd,IDC_BATCH_RESULTS),"ext_table_name   : 'records'");
ListBox_AddString(GetDlgItem(hwnd,IDC_BATCH_RESULTS),"upper_table_name : 'RECORDS'");
ListBox_AddString(GetDlgItem(hwnd,IDC_BATCH_RESULTS),"table_type       : 'T'");
ListBox_AddString(GetDlgItem(hwnd,IDC_BATCH_RESULTS),"date_entered     : 1994-04-06:11:54:17");
ListBox_AddString(GetDlgItem(hwnd,IDC_BATCH_RESULTS),"date_modified    : 1994-04-06:11:54:17");
ListBox_AddString(GetDlgItem(hwnd,IDC_BATCH_RESULTS),"ris_object       : 'N'");
ListBox_AddString(GetDlgItem(hwnd,IDC_BATCH_RESULTS),"");
ListBox_AddString(GetDlgItem(hwnd,IDC_BATCH_RESULTS),"End of Data Found ... ");
	      if (IsDlgButtonChecked(hwnd, IDC_BATCH_TOFILE) == TRUE)
			{
				Edit_GetText(GetDlgItem(hwnd,IDC_BATCH_FILENAME), szFileName,sizeof(szFileName));
_Debug(PROG,2,"output to <%s>",szFileName);
				_ReadLB2File(GetDlgItem(hwnd,IDC_BATCH_RESULTS),szFileName);
			}

			_Delay(2);
			EnableMenuItem (batch.hMenu, IDM_BATCH_FILE_SAVERESULTS, MF_BYCOMMAND | MF_ENABLED);
			ENDWAIT;
			break;

		case IDM_BATCH_SHOWCLILOC:
		case IDM_BATCH_STARTCLI:
		case IDM_BATCH_STOPCLI:
		case IDM_BATCH_SHOWDEFSCH:
		case IDM_BATCH_SHOWSCHLOC:
		case IDM_BATCH_SHOWSCHNAMES:
		case IDM_BATCH_SHOWSCHTRANS:
		case IDM_BATCH_CHECKSUM:
		case IDM_BATCH_SHOWSUPERDEF:
		case IDM_BATCH_SHOWSUPERNAMES:
		case IDM_BATCH_SHOWFLAGS:
		case IDM_BATCH_SHOWPARMS:
		case IDM_BATCH_IGNOREERRORS:
		case IDM_BATCH_PROCESSERRORS:
		case IDM_BATCH_QUIT:
			sprintf(wrk,"%s;\r\n",szCommands[id - IDM_BATCH_SHOWCLILOC]);
			AddCommand(hwnd, wrk);
			break;

		case IDM_EDIT_CUT:
hwnd1 = GetFocus();
nDlgID=GetDlgCtrlID(hwnd1);
_Debug(PROG,2,"OnCommand-CUT: hwnd1=%08X is id %d",hwnd1,nDlgID);
			if (nDlgID == IDC_BATCH_COMMANDS)
				SendMessage(hwnd1,WM_CUT,0,0L);
			break;


		case IDM_EDIT_COPY:
hwnd1 = GetFocus();
nDlgID=GetDlgCtrlID(hwnd1);
_Debug(PROG,2,"OnCommand-COPY: hwnd1=%08X is id %d",hwnd1,nDlgID);
			if (nDlgID == IDC_BATCH_COMMANDS)
				SendMessage(hwnd1,WM_COPY,0,0L);
			else if (nDlgID == IDC_BATCH_RESULTS)
				SendMessage(hwnd1,WM_COPY,0,0L);
			break;

		case IDM_EDIT_PASTE:
hwnd1 = GetFocus();
nDlgID=GetDlgCtrlID(hwnd1);
_Debug(PROG,2,"OnCommand-PASTE: hwnd1=%08X is id %d",hwnd1,nDlgID);
			if (nDlgID == IDC_BATCH_COMMANDS)
				SendMessage(hwnd1,WM_PASTE,0,0L);
			break;

		case IDC_BATCH_RCLEAR:
			ListBox_ResetContent(GetDlgItem(hwnd,IDC_BATCH_RESULTS));
			EnableMenuItem (batch.hMenu, IDM_BATCH_FILE_SAVERESULTS, MF_BYCOMMAND | MF_GRAYED);
			break;

		case IDC_BATCH_CCLEAR:
			Edit_SetText(GetDlgItem(hwnd,IDC_BATCH_COMMANDS), "");
			Button_Enable(GetDlgItem(hwnd,IDC_BATCH_START), FALSE);
			EnableMenuItem (batch.hMenu, IDM_BATCH_FILE_SAVE, MF_BYCOMMAND | MF_GRAYED);
			break;

		case IDM_BATCH_FILE_OPEN:
			status = _SelectFile (hwnd, szFileName, batch.szInitialDir,fname_only,"RISbatch - Select input filename",OpenFilter,&batch.index);
			if (status == TRUE)
			{
				_Debug(PROG,2,"Selected <%s>",szFileName);
				_ReadFile2Control(GetDlgItem(hwnd,IDC_BATCH_COMMANDS),szFileName);
				Button_Enable(GetDlgItem(hwnd,IDC_BATCH_START), TRUE);
				strcpy(batch.szComFile,fname_only);
				EnableMenuItem (batch.hMenu, IDM_BATCH_FILE_SAVE, MF_BYCOMMAND | MF_ENABLED);
			}
			break;
		case IDM_BATCH_FILE_SAVE:
			strcpy(SaveFilter,"Batch Files (*.btc)|*.btc|All Files (*.*)|*.*|");
			status = _SaveFile (hwnd, batch.szComFile, batch.szInitialDir,fname_only,"RISbatch - Select output filename",SaveFilter,&batch.index);
			if (status == TRUE)
			{
				_Debug(PROG,2,"Selected <%s>",batch.szComFile);
				_ReadControl2File(GetDlgItem(hwnd,IDC_BATCH_COMMANDS),batch.szComFile);
				strcpy(batch.szComFile,fname_only);
			}
			break;

		case IDM_BATCH_FILE_SAVERESULTS:
			strcpy(SaveFilter,"Result Files (*.brf)|*.brf|All Files (*.*)|*.*|");
			status = _SaveFile (hwnd, szFileName, batch.szInitialDir,fname_only,"RISbatch - Select output filename",SaveFilter,&batch.index);
			if (status == TRUE)
			{
				_Debug(PROG,2,"Selected <%s>",szFileName);
				_ReadLB2File(GetDlgItem(hwnd,IDC_BATCH_RESULTS),szFileName);
			}

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
   DestroyIcon(batch.hIcon);
	_TimedMsgBox(gco.hhLib, hwnd, "Clean up RIS (RIS_terminate)","Temporary",MB_OK | MB_ICONINFORMATION , IDS_BATCH_DESC, 1);

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
	UpdateBatchMenu(hwnd);
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
//      if (id >= IDC_BATCH_SCHEMAS && id <= IDC_BATCH_EXIT)
//		 _UpdateStatusBar(_GetResourceString(gco.hhLib,id+100));
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


static void AddCommandText(HWND hwnd,int id, char *text)
{
	char str[4096];
	char str1[4096];
	int len;
/*
NOTE: dynamically allocate memory
*/
	len = GetWindowTextLength(GetDlgItem(hwnd,id));
_DEBUG(PROG,2,"id = %d text = <%s> len=%d",id,text,len);

	Edit_GetText(GetDlgItem(hwnd,id), str1,sizeof(str1));
	sprintf(str,"%s%s",str1,text);

	Edit_SetText(GetDlgItem(hwnd,id), str);
_DEBUG(PROG,2,"str= <%s>",str);
}

static void UpdateBatchMenu(HWND hwnd)
{
	LONG l;
	WORD status = TRUE;

	//If edit control is non-empty, allow cut/copy/clear
	l = Edit_GetSel(GetDlgItem(hwnd,IDC_BATCH_COMMANDS));

	if ( HIWORD(l) == LOWORD(l) )
	{
		EnableMenuItem (batch.hMenu, IDM_EDIT_CUT, MF_BYCOMMAND | MF_GRAYED);
		EnableMenuItem (batch.hMenu, IDM_EDIT_COPY, MF_BYCOMMAND | MF_GRAYED);
	}
	else
	{
		EnableMenuItem (batch.hMenu, IDM_EDIT_CUT, MF_BYCOMMAND | MF_ENABLED);
		EnableMenuItem (batch.hMenu, IDM_EDIT_COPY, MF_BYCOMMAND | MF_ENABLED);
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
		EnableMenuItem (batch.hMenu, IDM_EDIT_PASTE, MF_BYCOMMAND | MF_ENABLED);
	else
		EnableMenuItem (batch.hMenu, IDM_EDIT_PASTE, MF_BYCOMMAND | MF_GRAYED);
}


static void AddCommand( HWND hwnd,char *str)
{
	HGLOBAL hData;
	LPTSTR lpData;
	DWORD dwSize;

	dwSize = strlen(str);
_DEBUG(PROG,2,"AddCommand: str=<%s>",str);

	// Allocate memory and copy the string to it.
	hData = GlobalAlloc(GMEM_MOVEABLE, dwSize+1);
	if (hData == NULL)
	{
		_DEBUG(PROG,2,"AddCommand: GlobalAlloc failed");
		return;
	}

	lpData = GlobalLock(hData);
	if	(lpData == NULL)
	{
		_DEBUG(PROG,2,"AddCommand: GlobalLock failed");
		GlobalFree(hData);
		return;
	}

	lstrcpy(lpData, str);
	GlobalUnlock(hData);

	/*
	* Clear the current contents of the clipboard,
	* and set the data handle to the new string.
	*/
	if (OpenClipboard(hwnd))
	{
		EmptyClipboard();
		SetClipboardData(CF_TEXT, hData);
		CloseClipboard();
	}
	SendMessage(GetDlgItem(hwnd,IDC_BATCH_COMMANDS),WM_PASTE,0,0L);
}
