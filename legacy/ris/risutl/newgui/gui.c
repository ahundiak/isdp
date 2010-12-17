/********************************************************************
Name:	       gui.c
Authors:       Melania M Stewart
Creation Date: 03/01/95
Description:   Main program for Interactive Utility

Revision History:
 ********************************************************************/
#include <windows.h>
#include <windowsx.h>
#include <locale.h>
#include <stdio.h>
#include "gco.h"
#include "dlgxext.h"
#include "dlgsec.h"
#include "resource.h"

#define gui_c
#include "gui.prt"
#include "guiutl.prt"
//#include "dlgcat.prt"
//#include "dlgsec.prt"
#include "gcointro.prt"
#include "gcosbar.prt"
#include "gcortns.prt"
#include "gcodbg.prt"
#include "gcordbg.prt"
#include "gcotmess.prt"
#include "gcotips.prt"

HWND PWnd ;

   // Constants
gco_globals gco;

typedef struct _gui_globals
{
   char szAppName[80];
   char szTitle[80];
   HICON hIcon;
   HCURSOR hCursor ;
   int argc;
   char **argv;
   HWND hIntro;
   DWORD ScreenConfig ;
   HMENU hMenu ;
   char ActiveSchema[20] ;
   int NumberOfSchemas ;
   char **ArrayOfSchemas ;
   int FirstFetch ;
   int LastBuffer ;
   char HistoryFile[_MAX_FNAME+1] ;
   HWND hwnd ;
   int  position ;
   int  NumberOfQueries ;
}  gui_globals;

gui_globals gui = {"RISgui", "", NULL, NULL, 0, NULL, NULL, IDM_GUI_FASCR, NULL, "", 0 , NULL, 1, 1, "", 0, 5} ;

/* test only */
int Start=0, EndNumber = 3 ;
static char Queries [5][100] = {\
"1 : select * from table where col1=1",
"2 : select devices from sysdevices",
"3 : select a.name, b.size from sys a, tab b where a.name=\"master\"",
"4 : select label from labels",
"5 : select count(*) from systables"} ;

static char ResultFilter[128] = "RESULT Files (*.rst)|*.rst|All Files (*.*)|*.*|";
static char QueryFilter[128] = "QUERY Files (*.qry)|*.qry|All Files (*.*)|*.*|";
static void PopulateMCF(HANDLE hwnd) ;
static void BlankMCF(HANDLE hwnd) ;
static void ClearBoxes(HANDLE hwnd) ;
static BOOL GetAllSchemas(HANDLE hwnd) ;
static BOOL SubmitRequestToRISServer(HANDLE hwnd) ;

static VOID MyDelay()
{
    STARTWAIT;
    _Delay(3) ;
    ENDWAIT ;
}


int PASCAL WinMain(hinstA, hinstPrev, lpszCmdLine, nCmdShow)
HINSTANCE   hinstA;
HINSTANCE   hinstPrev;
LPSTR	 lpszCmdLine;
int	 nCmdShow;
{
    LRESULT CALLBACK DlgProc ();
    WNDCLASS    wndclass ; // the window class

    setlocale(LC_ALL, "");

    gco.hhInst = hinstA;
    strcpy(gui.szAppName,"RISgui");

    // get handle to risres.dll
    gco.hhLib = _LoadResources(gui.szAppName);
    if (!gco.hhLib)
    {
      return (FALSE);
    }

    gui.argc = _ParseCommandLine(gco.hhInst, lpszCmdLine, &gui.argv);

    strcpy(gui.szTitle,_GetResourceString (gco.hhLib,IDS_GUI_DESC));

    if (!hinstPrev)
    {
	wndclass.style         = CS_HREDRAW | CS_VREDRAW ;
	wndclass.lpfnWndProc   = DefDlgProc ;
	wndclass.cbClsExtra    = 0 ;
	wndclass.cbWndExtra    = DLGWINDOWEXTRA ;
	wndclass.hInstance     = gco.hhInst ;
	wndclass.hIcon	       = LoadIcon(gco.hhInst, MAKEINTRESOURCE(IDI_LOD));
	wndclass.hCursor       = LoadCursor (NULL, IDC_ARROW) ;
	wndclass.hbrBackground = (HBRUSH)(COLOR_WINDOW+1);
	wndclass.lpszMenuName  = NULL ;
	wndclass.lpszClassName = gui.szAppName;

        gui.hIcon = wndclass.hIcon;
        gui.hCursor = wndclass.hCursor ;

	// register the window class 
	if (!RegisterClass (&wndclass))
	{
		MessageBox(NULL,"RegisterClass() failed",gui.szTitle,MB_OK | MB_TASKMODAL | MB_ICONSTOP);
		return FALSE ;
	}
    }

    gui.hIntro= _CreateSplashScreen(NULL, gui.szTitle, gui.szAppName,gui.hIcon);
    UpdateWindow(gui.hIntro);

    DialogBox(gco.hhInst, TEXT("RISgui_tmp"), NULL, (DLGPROC) DlgProc );

    FreeLibrary(gco.hhLib);
    return 0;
}


static BOOL Cls_OnInitDialog(HWND hwnd, HWND hwndFocus, LPARAM lParam)
{
    char Path[_MAX_FNAME+1] ;        
    
    //Initialize
    gui.position = 0 ;
    gui.NumberOfQueries = 5 ;
    gui.hMenu = GetMenu(hwnd) ;
    PWnd= hwnd ;
    _AddUtilityMenu(hwnd, 4);
    _AddHelpMenu(hwnd);
    _InitDebug( gui.argc,gui.argv,hwnd, gui.szAppName );
    _InitProgram(gui.argc,gui.argv);

    _Debug(PROG,2,"Homedir=<%s>",_GetHomeDir(gco.hhInst));

	
    if (!_InitStatusBar (hwnd))
    {
	_MessageBox (NULL,gco.hhLib,MB_OK | MB_TASKMODAL | MB_ICONSTOP,IDS_GUI_DESC,IDS_SBAR_FAIL);
	return FALSE;
    }
    CheckMenuItem (gui.hMenu, gui.ScreenConfig,MF_CHECKED) ;
    GetAllSchemas (hwnd) ;
    /* TOOL BAR */
    Button_Enable(GetDlgItem(hwnd,IDC_GUI_ABORT), FALSE);
    Button_Enable(GetDlgItem(hwnd,IDC_GUI_CONTINUE), FALSE);
    Button_Enable(GetDlgItem(hwnd,IDC_GUI_EXECUTE), FALSE);
    Button_Enable(GetDlgItem(hwnd,IDC_GUI_CLEAR), FALSE);
    Button_Enable(GetDlgItem(hwnd,IDC_GUI_NEXT_QRY), FALSE);
    Button_Enable(GetDlgItem(hwnd,IDC_GUI_PREV_QRY), FALSE);
    Button_Enable(GetDlgItem(hwnd,IDC_GUI_REFRESH), TRUE);
    /* QUERY */
    Edit_Enable(GetDlgItem(hwnd,IDC_GUI_QUERY), FALSE);
    EnableMenuItem(gui.hMenu, IDM_GUI_ABORT, MF_GRAYED);
    EnableMenuItem(gui.hMenu, IDM_GUI_CONTINUE, MF_GRAYED);
    EnableMenuItem(gui.hMenu, IDM_GUI_EXECUTE, MF_GRAYED);
    EnableMenuItem(gui.hMenu, IDM_GUI_CLEAR, MF_GRAYED);
    EnableMenuItem(gui.hMenu, IDM_GUI_REFRESH, MF_ENABLED);
    EnableMenuItem(gui.hMenu, IDM_GUI_HISTORY, MF_GRAYED);
    EnableMenuItem(gui.hMenu ,IDM_GUI_NEXT_QRY, MF_GRAYED);
    EnableMenuItem(gui.hMenu,IDM_GUI_PREV_QRY, MF_GRAYED);
    /* FILE OPTIONS */
    EnableMenuItem(gui.hMenu, IDM_GUI_SAVE_RESULTS, MF_GRAYED);
    EnableMenuItem(gui.hMenu, IDM_GUI_OPEN_QUERY, MF_GRAYED);
    EnableMenuItem(gui.hMenu, IDM_GUI_SAVE_QUERY, MF_GRAYED);
    
    /* When you execute a query, the risgui utility saves the SQL statement in the history file.
        To determine the name of the history file, the ris utility follows the order:
            1. Uses the file specified by the RIS_HISTORY_FILE environment variable
            2. Uses the ris.his in the directory specified by the HOME environment variable.
            3. Uses the ris.his in the directory from which you started the risgui utility.
     */
    strcpy (gui.HistoryFile, "ris.his") ;
    if (GetEnvironmentVariable ("RIS_HISTORY_FILE", gui.HistoryFile, _MAX_FNAME) == 0)
    {
        if (GetEnvironmentVariable ("HOME", Path, _MAX_FNAME) != 0)
        {
            sprintf (gui.HistoryFile, "%s\\ris.his", Path) ;
        }
    }         
    

   _DestroySplashScreen(gui.hIntro);

   if( ! _InitializeTips( gco.hhInst ) )
    {
        MessageBox(NULL,"InitialTips() failed",gui.szTitle,MB_OK | MB_TASKMODAL | MB_ICONSTOP);
        return( FALSE );
    }
    _CreateTip( gco.hhInst, hwnd, IDC_GUI_EXECUTE, "Execute query" );
    _CreateTip( gco.hhInst, hwnd, IDC_GUI_CLEAR, "Clear query and results" );
    _CreateTip( gco.hhInst, hwnd, IDC_GUI_REFRESH, "Refresh schema list" );
    _CreateTip( gco.hhInst, hwnd, IDC_GUI_ABORT, "Abort query" );
    _CreateTip( gco.hhInst, hwnd, IDC_GUI_CONTINUE, "Continue query" );
    _CreateTip( gco.hhInst, hwnd, IDC_GUI_DEFSCH, "Active Schema" );
    _CreateTip( gco.hhInst, hwnd, IDC_GUI_NEXT_QRY, "Next Query" );
    _CreateTip( gco.hhInst, hwnd, IDC_GUI_PREV_QRY, "Previous Query" );
   
    _CenterWindowOnScreen(hwnd);
    return TRUE ;
}

static void Cls_OnCommand(HWND hwnd, int id, HWND hwndCtl, UINT codeNotify)
{
    char String [200] ;
    int index = 0 ;
    char Path[_MAX_FNAME+1] = "" ;
    char CompletePathName[_MAX_FNAME+1] ;
    char filename[_MAX_FNAME+1] ;
    char ResultFilter[128] = "RESULT Files (*.rst)|*.rst|All Files (*.*)|*.*|";
    char QueryFilter[128] = "QUERY Files (*.qry)|*.qry|All Files (*.*)|*.*|";
    
    switch (id)
    {
        _Debug(PROG,2,"id=%d",id);

	case IDOK:
	    _TimedMsgBox(gco.hhLib, hwnd, "Process Record","Temporary",MB_OK | MB_ICONINFORMATION , IDS_GUI_DESC, 2);
	    break;
	
	case IDCANCEL:
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
		_RunHelp(id,hwnd,gui.szTitle,gui.szAppName,gui.hIcon);
		break;

	case IDM_RIS_DEBUG:
		DialogBox(gco.hhLib, MAKEINTRESOURCE(IDD_RISDBG),hwnd, (DLGPROC)RISdebug);
		break;

	case IDM_GUI_DEBUG:
		_UpdateStatusBar("Selected DEBUG");
		_DEBUG(PROG,2,"Selected Debug");
		_DebugControlPanel( gco.hhLib,hwnd,FALSE );
		break;

        case IDM_GUI_PARAMETERS:
		DialogBox(gco.hhInst, MAKEINTRESOURCE(IDD_GUI_PARAMETERS),hwnd, (DLGPROC)ProcParameters);
                break ;
                
        case IDM_GUI_HISTORY:
		DialogBox(gco.hhInst, MAKEINTRESOURCE(IDD_GUI_HISTORY),hwnd, (DLGPROC)ProcHistory);
                break ;
                
        case IDM_GUI_SCHEMA_IN_TRANS:
		DialogBox(gco.hhInst, MAKEINTRESOURCE(IDD_GUI_SCHEMA_IN_TRANS),hwnd, (DLGPROC)ProcSchemaInTrans);
                break ;
                
        case IDM_GUI_SETTINGS:
		DialogBox(gco.hhInst, MAKEINTRESOURCE(IDD_GUI_SETTINGS),hwnd, (DLGPROC)ProcSettings);
                break ;

        case IDM_GUI_FASCR:
        case IDM_GUI_FOSCR:
        case IDM_GUI_FALL:
            CheckMenuItem (gui.hMenu, gui.ScreenConfig,MF_UNCHECKED) ;
            gui.ScreenConfig = id ;
            CheckMenuItem (gui.hMenu, gui.ScreenConfig,MF_CHECKED) ;
            break ;
            
        case IDC_GUI_QUERY:
	    if (Edit_GetTextLength(GetDlgItem(hwnd,IDC_GUI_QUERY)) >0)
	    {
		Button_Enable(GetDlgItem(hwnd,IDC_GUI_EXECUTE), TRUE);
                EnableMenuItem(gui.hMenu, IDM_GUI_SAVE_QUERY, MF_ENABLED);
	    }
	    else
	    {
		Button_Enable(GetDlgItem(hwnd,IDC_GUI_EXECUTE), FALSE);
                EnableMenuItem(gui.hMenu, IDM_GUI_SAVE_QUERY, MF_GRAYED);
	    }
	    break;

	case IDC_GUI_NEXT_QRY:
	case IDM_GUI_NEXT_QRY:
            Button_Enable(GetDlgItem(hwnd,IDC_GUI_EXECUTE), TRUE);
	    SetDlgItemText (hwnd, IDC_GUI_QUERY, Queries[gui.position]) ;
	    if (gui.position != gui.NumberOfQueries -1) ++(gui.position) ;
	    break ;

	case IDC_GUI_PREV_QRY:
	case IDM_GUI_PREV_QRY:
            Button_Enable(GetDlgItem(hwnd,IDC_GUI_EXECUTE), TRUE);
	    SetDlgItemText (hwnd, IDC_GUI_QUERY, Queries [gui.position]) ;
	    if (gui.position != 0) --(gui.position) ;
	    break ;
                    
        case IDC_GUI_DEFSCH:
            if (codeNotify == CBN_SELCHANGE)
            {
                GetDlgItemText (hwnd, IDC_GUI_DEFSCH, String, 200) ;
                if (strcmp (String, gui.ActiveSchema))
                {
                    ClearBoxes(hwnd) ;
                    if (gui.ActiveSchema[0] != 0)
                    {
                        _UpdateStatusBar ("Closing schema %s...", gui.ActiveSchema) ;
                        UpdateWindow (hwnd) ;
                        MyDelay() ;
                        /* Close Previous Schema */
                        gui.ActiveSchema[0] = 0 ;
                    }
                    /* Default to Schema */
                    _UpdateStatusBar ("Default to schema %s...", String) ;
                    UpdateWindow(hwnd) ;
                    strcpy (gui.ActiveSchema, String) ;
                    MyDelay() ;
                    _UpdateStatusBar ("") ;
                    UpdateWindow(hwnd) ;
                        /* TOOL BAR */
                    Button_Enable(GetDlgItem(hwnd,IDC_GUI_ABORT), FALSE);
                    Button_Enable(GetDlgItem(hwnd,IDC_GUI_CONTINUE), FALSE);
                    Button_Enable(GetDlgItem(hwnd,IDC_GUI_EXECUTE), TRUE);
                    Button_Enable(GetDlgItem(hwnd,IDC_GUI_CLEAR), TRUE);
                    Button_Enable(GetDlgItem(hwnd,IDC_GUI_REFRESH), TRUE);
                    Button_Enable(GetDlgItem(hwnd,IDC_GUI_NEXT_QRY), TRUE);
                    Button_Enable(GetDlgItem(hwnd,IDC_GUI_PREV_QRY), TRUE);
                    /* QUERY */
                    Edit_Enable(GetDlgItem(hwnd,IDC_GUI_QUERY), TRUE);
                    EnableMenuItem(gui.hMenu, IDM_GUI_ABORT, MF_GRAYED);
                    EnableMenuItem(gui.hMenu, IDM_GUI_CONTINUE, MF_GRAYED);
                    EnableMenuItem(gui.hMenu, IDM_GUI_EXECUTE, MF_ENABLED);
                    EnableMenuItem(gui.hMenu, IDM_GUI_CLEAR, MF_ENABLED);
                    EnableMenuItem(gui.hMenu, IDM_GUI_REFRESH, MF_ENABLED);
                    EnableMenuItem(gui.hMenu, IDM_GUI_HISTORY, MF_ENABLED);
                    EnableMenuItem(gui.hMenu ,IDM_GUI_NEXT_QRY, MF_ENABLED);
                    EnableMenuItem(gui.hMenu,IDM_GUI_PREV_QRY, MF_ENABLED);
                    /* FILE OPTIONS */
                    EnableMenuItem(gui.hMenu, IDM_GUI_SAVE_RESULTS, MF_ENABLED);
                    EnableMenuItem(gui.hMenu, IDM_GUI_OPEN_QUERY, MF_ENABLED);
                    EnableMenuItem(gui.hMenu, IDM_GUI_SAVE_QUERY, MF_ENABLED);
                    SetFocus (GetDlgItem(hwnd, IDC_GUI_QUERY)) ;
                }
            }
            break ;

        case IDC_GUI_EXECUTE:
        case IDM_GUI_EXECUTE:
            GetDlgItemText (hwnd, IDC_GUI_QUERY, String, 200) ;
            if (strlen (String))
            {
                BlankMCF (hwnd) ;
                _UpdateStatusBar ("Submitting query to RIS. Please wait...") ;
                gui.FirstFetch = 1 ;
                UpdateWindow(hwnd) ;
                if (SubmitRequestToRISServer(hwnd))
                {
                }
                _ReadControl2File(GetDlgItem(hwnd, IDC_GUI_QUERY), gui.HistoryFile);
                _UpdateStatusBar ("Writing to file %s...", gui.HistoryFile) ;
                UpdateWindow (hwnd) ;
                MyDelay() ;
            }
            else
            {
                _UpdateStatusBar ("Need to type a valid RIS statement.") ;
                UpdateWindow (hwnd) ;
                SetFocus (GetDlgItem (hwnd, IDC_GUI_QUERY)) ;
            }
            break ;

        case IDC_GUI_CONTINUE:
        case IDM_GUI_CONTINUE:
                _UpdateStatusBar ("Submitting query to RIS. Please wait...") ;
                UpdateWindow(hwnd) ;
                if (SubmitRequestToRISServer(hwnd))
                {
                }                
                break ;

        case IDC_GUI_REFRESH:
        case IDM_GUI_REFRESH:
            if (gui.ActiveSchema[0] != 0)
            {
                _UpdateStatusBar ("Closing schema %s...", gui.ActiveSchema) ;
                UpdateWindow (hwnd) ;
                MyDelay() ;
                gui.ActiveSchema[0] = 0 ;
                /* Close Previous Schema */
            }
            ClearBoxes (hwnd) ;
            GetAllSchemas (hwnd) ;
            SetFocus (GetDlgItem (hwnd, IDC_GUI_DEFSCH)) ;
            /* TOOL BAR */
            Button_Enable(GetDlgItem(hwnd,IDC_GUI_ABORT), FALSE);
            Button_Enable(GetDlgItem(hwnd,IDC_GUI_CONTINUE), FALSE);
            Button_Enable(GetDlgItem(hwnd,IDC_GUI_EXECUTE), FALSE);
            Button_Enable(GetDlgItem(hwnd,IDC_GUI_CLEAR), FALSE);
            Button_Enable(GetDlgItem(hwnd,IDC_GUI_REFRESH), TRUE);
            Button_Enable(GetDlgItem(hwnd,IDC_GUI_NEXT_QRY), FALSE);
            Button_Enable(GetDlgItem(hwnd,IDC_GUI_PREV_QRY), FALSE);
            /* QUERY  */
            Edit_Enable(GetDlgItem(hwnd,IDC_GUI_QUERY), FALSE);
            EnableMenuItem(gui.hMenu, IDM_GUI_ABORT, MF_GRAYED);
            EnableMenuItem(gui.hMenu, IDM_GUI_CONTINUE, MF_GRAYED);
            EnableMenuItem(gui.hMenu, IDM_GUI_EXECUTE, MF_GRAYED);
            EnableMenuItem(gui.hMenu, IDM_GUI_CLEAR, MF_GRAYED);
            EnableMenuItem(gui.hMenu, IDM_GUI_REFRESH, MF_ENABLED);
            EnableMenuItem(gui.hMenu, IDM_GUI_HISTORY, MF_GRAYED);
            EnableMenuItem(gui.hMenu ,IDM_GUI_NEXT_QRY, MF_GRAYED);
            EnableMenuItem(gui.hMenu,IDM_GUI_PREV_QRY, MF_GRAYED);
            /* FILE OPTIONS */
            EnableMenuItem(gui.hMenu, IDM_GUI_SAVE_RESULTS, MF_GRAYED);
            EnableMenuItem(gui.hMenu, IDM_GUI_OPEN_QUERY, MF_GRAYED);
            EnableMenuItem(gui.hMenu, IDM_GUI_SAVE_QUERY, MF_GRAYED);
            break ;

        case IDC_GUI_ABORT:
        case IDM_GUI_ABORT:
            Button_Enable(GetDlgItem(hwnd,IDC_GUI_ABORT), FALSE);
            Button_Enable(GetDlgItem(hwnd,IDC_GUI_CONTINUE), FALSE);
            Button_Enable(GetDlgItem(hwnd,IDC_GUI_EXECUTE), TRUE);
            Button_Enable(GetDlgItem(hwnd,IDC_GUI_CLEAR), TRUE);
            Button_Enable(GetDlgItem(hwnd,IDC_GUI_REFRESH), TRUE);
            Button_Enable(GetDlgItem(hwnd,IDC_GUI_NEXT_QRY), TRUE);
            Button_Enable(GetDlgItem(hwnd,IDC_GUI_PREV_QRY), TRUE);
            EnableMenuItem(gui.hMenu, IDM_GUI_ABORT, MF_GRAYED);
            EnableMenuItem(gui.hMenu, IDM_GUI_CONTINUE, MF_GRAYED);
            EnableMenuItem(gui.hMenu, IDM_GUI_EXECUTE, MF_ENABLED);
            EnableMenuItem(gui.hMenu, IDM_GUI_CLEAR, MF_ENABLED);
            EnableMenuItem(gui.hMenu, IDM_GUI_REFRESH, MF_ENABLED);
            EnableMenuItem(gui.hMenu ,IDM_GUI_NEXT_QRY, MF_ENABLED);
            EnableMenuItem(gui.hMenu,IDM_GUI_PREV_QRY, MF_ENABLED);
            Edit_Enable (GetDlgItem (hwnd, IDC_GUI_QUERY), TRUE) ;
            Edit_Enable(GetDlgItem(hwnd,IDC_GUI_DEFSCH), TRUE);
            SetFocus (GetDlgItem(hwnd, IDC_GUI_QUERY)) ;
            _UpdateStatusBar("") ;
            UpdateWindow(hwnd) ;
            break ;

        case IDC_GUI_CLEAR:
        case IDM_GUI_CLEAR:
            ClearBoxes (hwnd) ;
            SetFocus (GetDlgItem (hwnd, IDC_GUI_QUERY)) ;
            _UpdateStatusBar("") ;
            UpdateWindow(hwnd) ;            
            break ;
                

        case IDM_GUI_SAVE_RESULTS:
            CompletePathName [0] = 0 ;
            if (_SaveFile(hwnd, CompletePathName, Path,
               filename, "RISgui - Select output filename",
               ResultFilter, &index) != TRUE)
            {
                MessageBox (NULL, "ERROR", "", MB_OK) ;
                break ;                
            }
            _UpdateStatusBar ("Saving Results to %s...", CompletePathName) ;
            UpdateWindow (hwnd) ;
            MyDelay() ;
            _UpdateStatusBar ("") ;
            UpdateWindow (hwnd) ;
            break ;

        case IDM_GUI_OPEN_QUERY:
            if (_SelectFile(hwnd, CompletePathName, Path,
                filename, "RISgui - Select input filename", QueryFilter, &index) != TRUE)
            {
                return ;
            }
            _ReadFile2Control(GetDlgItem(hwnd,IDC_GUI_QUERY), CompletePathName);
            Edit_Enable(GetDlgItem(hwnd,IDC_GUI_QUERY), TRUE) ;
            Button_Enable(GetDlgItem(hwnd,IDC_GUI_EXECUTE), TRUE);
            EnableMenuItem(gui.hMenu, IDM_GUI_SAVE_QUERY, MF_ENABLED);
            BlankMCF(hwnd) ;
            break ;

        case IDM_GUI_SAVE_QUERY:
            GetDlgItemText (hwnd, IDC_GUI_QUERY, String, 200) ;
            if (strlen (String))
            {
                CompletePathName[0] = 0 ;
                if (_SaveFile(hwnd, CompletePathName, Path,
            	filename, "RISgui - Select output filename", QueryFilter, &index) != TRUE)
                {
                    return ;
                }
                _UpdateStatusBar ("Saving Query to %s...", CompletePathName) ;
                UpdateWindow (hwnd) ;
                MyDelay() ;
                _ReadControl2File(GetDlgItem(hwnd, IDC_GUI_QUERY), CompletePathName);
                _UpdateStatusBar ("") ;
                UpdateWindow (hwnd) ;
            }
            else
            {
                _UpdateStatusBar ("No valid RIS statement to be saved.") ;
                UpdateWindow (hwnd) ;
                SetFocus (GetDlgItem (hwnd, IDC_GUI_QUERY)) ;
            }
            break ;
    }

}

static void Cls_OnTimer(HWND hwnd, UINT id)
{
	if (id == 1) _UpdateStatusBarTime();
}

static void Cls_OnSize(HWND hwnd, UINT state, int cx, int cy)
{
	_AdjustStatusBar (hwnd);
}


static void Cls_OnClose(HWND hwnd)
{
    int i ;
    
	WinHelp(hwnd,"risutl.hlp",HELP_QUIT,0L);
	KillTimer(hwnd,1);
	DestroyIcon(gui.hIcon);
	_TimedMsgBox(gco.hhLib, hwnd, "Clean up RIS (RIS_terminate)","Temporary",MB_OK | MB_ICONINFORMATION , IDS_GUI_DESC, 1);
	for (i=0; i<gui.NumberOfSchemas;i++) free (gui.ArrayOfSchemas[i]) ;
	if (gui.NumberOfSchemas > 0) free (gui.ArrayOfSchemas) ;
	EndDialog (hwnd, 0) ;
}

static void Cls_OnMenuSelect(HWND hwnd, HMENU hmenu, int item, HMENU hmenuPopup, UINT flags)
{
	char szMsg[255];

	_DEBUG(PROG,2,"Item = %d",item);
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


/******************************** TEST FUNCTIONS *************************************************/
BOOL GetSchemas (NumberOfSchemas, ArrayOfSchemas)
    int *NumberOfSchemas ;
    char **ArrayOfSchemas ;
{
    char **ptr ;
    int i ;
        
//    _Delay (3) ;

    *NumberOfSchemas = 10 ;
    if ((ptr = (char **) calloc (10, sizeof(char *))) == NULL)
    {
        MessageBox (NULL, "FAILURE : calloc ptr", "", MB_OK) ;
        return FALSE ;
    }
    for (i=0; i<10; i++)
    {
        if ( (ptr[i] = (char *) malloc(20)) == NULL)
        {
            MessageBox (NULL, "FAILURE : calloc ptr[i]", "", MB_OK) ;
            return FALSE ;
        }
    }
    strcpy (ptr[0], "melania") ;
    strcpy (ptr[1], "joe") ;
    strcpy (ptr[2], "jeanette") ;
    strcpy (ptr[3], "david") ;
    strcpy (ptr[4], "radha") ;
    strcpy (ptr[5], "shiva") ;
    strcpy (ptr[6], "devender") ;
    strcpy (ptr[7], "james") ;
    strcpy (ptr[8], "brad") ;
    strcpy (ptr[9], "linda") ;
    *ArrayOfSchemas = (char *) ptr ;
    return TRUE ;
}


static BOOL SubmitRequestToRISServer(HANDLE hwnd)
{
  char String1[300] = "ste\r\nshivak\r\nchang\r\nwang\r\nwarren\r\nbl\r\nrobbins\r\nkramer\r\nsterling\r\nstewart\r\nshivakumar\r\nchang\r\nwang\r\nwarren\r\nbl\r\nrobbins\r\nkrer\r\nsteng\r\nab\r\ncd\r\nef\r\nlk\r\n" ;
  char String2[300] = "stewart\r\nshivakumar\r\nchang\r\nwang\r\nwarren\r\nblohm\r\nrobbins\r\nkramer\r\nsterling\r\nstewart\r\nshivakumar\r\nchang\r\nwang\r\nwa\r\nblohm\r\nrobns\r\nkramer\r\nsteng\r\n" ;
  char String3[300] = "stewart\r\nshivakumar\r\nchang\r\nwang\r\nwarren\r\nblohm\r\nrobbins\r\nkramer\r\nsterling\r\nstewart\r\nshivakumar\r\nchang\r\nwang\r\nwa\r\nblohm\r\nrobns\r\nkramer\r\nsteing\r\n" ;
  char String4[300] = "stewart\r\nshivakumar\r\nchang\r\nwang\r\nwarren\r\nblohm\r\nrobbins\r\nkramer\r\nsterling\r\nstewart\r\nshivakumar\r\nchang\r\nwang\r\nwa\r\nblohm\r\nrobs\r\nkramer\r\nsteng\r\n" ;
  char String5[300] = "stewart\r\nshivakumar\r\nchang\r\nwang\r\nwarren\r\nblohm\r\nrobbins\r\nkramer\r\nsterling\r\nstewart\r\nshivakumar\r\nchang\r\nwang\r\nwa\r\nblohm\r\nrob\r\nkramer\r\nstng\r\n" ;

    /* Submit to RIS */
    _UpdateStatusBar ("Submitting to RIS...") ;
    UpdateWindow (hwnd) ;
    MyDelay() ;
    
    /* RIS sends a structure */
    
    /* NumberOfRows, NumberOfCols, LastBuffer */
    gui.LastBuffer = 0 ;
    /* If first submittion - Put columns */
    if (gui.FirstFetch)
    {
        /* Put columns */
        SetDlgItemText (hwnd, IDC_LABEL1, "Col1") ;
        SetDlgItemText (hwnd, IDC_LABEL2, "Col2") ;
        SetDlgItemText (hwnd, IDC_LABEL3, "Col3") ;
        SetDlgItemText (hwnd, IDC_LABEL4, "Col4") ;
        SetDlgItemText (hwnd, IDC_LABEL5, "Col5") ;
        gui.FirstFetch = 0 ;
        Start = 0 ;
    }
    if (Start == EndNumber)
    {
        gui.LastBuffer = 1 ;
    }
    ++Start ;
    /* Put in edit box */
    /* Enable controls accordingly */
    if ((gui.ScreenConfig == IDM_GUI_FALL) || (gui.LastBuffer))
    {
        Start = 0 ;
        Button_Enable(GetDlgItem(hwnd,IDC_GUI_ABORT), FALSE);
        Button_Enable(GetDlgItem(hwnd,IDC_GUI_CONTINUE), FALSE);
        Button_Enable(GetDlgItem(hwnd,IDC_GUI_EXECUTE), TRUE);
        Button_Enable(GetDlgItem(hwnd,IDC_GUI_CLEAR), TRUE);
        Button_Enable(GetDlgItem(hwnd,IDC_GUI_REFRESH), TRUE);
        Button_Enable(GetDlgItem(hwnd,IDC_GUI_NEXT_QRY), TRUE);
        Button_Enable(GetDlgItem(hwnd,IDC_GUI_PREV_QRY), TRUE);
        EnableMenuItem(gui.hMenu, IDM_GUI_ABORT, MF_GRAYED);
        EnableMenuItem(gui.hMenu, IDM_GUI_CONTINUE, MF_GRAYED);
        EnableMenuItem(gui.hMenu, IDM_GUI_EXECUTE, MF_ENABLED);
        EnableMenuItem(gui.hMenu, IDM_GUI_CLEAR, MF_ENABLED);
        EnableMenuItem(gui.hMenu ,IDM_GUI_NEXT_QRY, MF_ENABLED);
        EnableMenuItem(gui.hMenu,IDM_GUI_PREV_QRY, MF_ENABLED);
        EnableMenuItem(gui.hMenu, IDM_GUI_REFRESH, MF_ENABLED);
        Edit_Enable(GetDlgItem(hwnd,IDC_GUI_QUERY), TRUE);
        Edit_Enable(GetDlgItem(hwnd,IDC_GUI_DEFSCH), TRUE);
        _UpdateStatusBar ("No more rows.") ;
    }
    else
    {
        /* more */
        Button_Enable(GetDlgItem(hwnd,IDC_GUI_ABORT), TRUE);
        Button_Enable(GetDlgItem(hwnd,IDC_GUI_CONTINUE), TRUE);
        Button_Enable(GetDlgItem(hwnd,IDC_GUI_EXECUTE), FALSE);
        Button_Enable(GetDlgItem(hwnd,IDC_GUI_CLEAR), FALSE);
        Button_Enable(GetDlgItem(hwnd,IDC_GUI_REFRESH), FALSE);
        EnableMenuItem(gui.hMenu, IDM_GUI_ABORT, MF_ENABLED);
        EnableMenuItem(gui.hMenu, IDM_GUI_CONTINUE, MF_ENABLED);
        EnableMenuItem(gui.hMenu, IDM_GUI_EXECUTE, MF_GRAYED);
        EnableMenuItem(gui.hMenu, IDM_GUI_CLEAR, MF_GRAYED);
        EnableMenuItem(gui.hMenu, IDM_GUI_REFRESH, MF_GRAYED);
        Edit_Enable(GetDlgItem(hwnd,IDC_GUI_QUERY), FALSE);
        Edit_Enable(GetDlgItem(hwnd,IDC_GUI_DEFSCH), FALSE);
        _UpdateStatusBar ("More rows exist...") ;
    }
    SetDlgItemText (hwnd, IDC_MC1, String1) ;
    SetDlgItemText (hwnd, IDC_MC2, String2) ;
    SetDlgItemText (hwnd, IDC_MC3, String3) ;
    SetDlgItemText (hwnd, IDC_MC4, String4) ;
    SetDlgItemText (hwnd, IDC_MC5, String5) ;
    return TRUE ;
}

static void ClearBoxes(HANDLE hwnd)
{
    SetDlgItemText (hwnd, IDC_GUI_QUERY, "") ;
    SetDlgItemText (hwnd, IDC_LABEL1, "") ;
    SetDlgItemText (hwnd, IDC_LABEL2, "") ;
    SetDlgItemText (hwnd, IDC_LABEL3, "") ;
    SetDlgItemText (hwnd, IDC_LABEL4, "") ;
    SetDlgItemText (hwnd, IDC_LABEL5, "") ;
    SetDlgItemText (hwnd, IDC_MC1, "") ;
    SetDlgItemText (hwnd, IDC_MC2,"") ;
    SetDlgItemText (hwnd, IDC_MC3, "") ;
    SetDlgItemText (hwnd, IDC_MC4, "") ;
    SetDlgItemText (hwnd, IDC_MC5, "") ;
}

static BOOL GetAllSchemas (HANDLE hwnd)
{
    HCURSOR hCursor ;
    int i ;
    HANDLE hDlg ;
    
    if (gui.NumberOfSchemas > 0)
    {
        for (i=0; i<gui.NumberOfSchemas; i++) free (gui.ArrayOfSchemas[i]) ;
        free (gui.ArrayOfSchemas) ;
        SendDlgItemMessage (hwnd, IDC_GUI_DEFSCH, CB_RESETCONTENT, 0, 0) ;
    }
    
    _UpdateStatusBar ("Getting Schemas. Please wait...") ;
    UpdateWindow (hwnd) ;
    MyDelay() ;
    hCursor = SetCursor (hCursor) ;	
    if (GetSchemas (&(gui.NumberOfSchemas), &(gui.ArrayOfSchemas)) != TRUE)
    {
	    return FALSE;
    }
	
    if (gui.NumberOfSchemas == 0)
    {
        _UpdateStatusBar ("No schemas exist.") ;
    }
    else
    {
        /* init combo box */
	for (i=0; i<gui.NumberOfSchemas; i++)
	{
	    SendDlgItemMessage(hwnd, IDC_GUI_DEFSCH, CB_ADDSTRING, 0, (LPARAM) gui.ArrayOfSchemas[i]) ;
	}
	hDlg = GetDlgItem (hwnd, IDC_GUI_DEFSCH) ;
	SetFocus (hDlg) ;
	_UpdateStatusBar ("") ;
	UpdateWindow (hwnd) ;
    }
    SetCursor (hCursor) ;
    return TRUE ;
}

static void PopulateMCF(HANDLE hwnd)
{
  char String1[300] = "melania\r\nradha\r\nlinda\r\nbrad\r\nkathy\r\nkaren\r\nnancy\r\n" ;
  char String2[300] = "stewart\r\nshivakumar\r\nchang\r\nrobbins\r\npayette\r\ntice\r\nwillhite\r\n" ;
  char String3[300] = "Phase I\r\nPhase I\r\nPhase II\r\nPhase III\r\nPhase I\r\nPhase IV\r\nPhase I\r\n" ;

    
    /* Put columns */
    SetDlgItemText (hwnd, IDC_LABEL1, "First Names") ;
    SetDlgItemText (hwnd, IDC_LABEL2, "Last Names") ;
    SetDlgItemText (hwnd, IDC_LABEL3, "Description") ;
    SetDlgItemText (hwnd, IDC_LABEL4, "") ;
    SetDlgItemText (hwnd, IDC_LABEL5, "") ;
    SetDlgItemText (hwnd, IDC_MC1, String1) ;
    SetDlgItemText (hwnd, IDC_MC2, String2) ;
    SetDlgItemText (hwnd, IDC_MC3, String3) ;
    SetDlgItemText (hwnd, IDC_MC4, "") ;
    SetDlgItemText (hwnd, IDC_MC5, "") ;
}

static void BlankMCF (HANDLE hwnd)
{
    /* Put columns */
    SetDlgItemText (hwnd, IDC_LABEL1, "") ;
    SetDlgItemText (hwnd, IDC_LABEL2, "") ;
    SetDlgItemText (hwnd, IDC_LABEL3, "") ;
    SetDlgItemText (hwnd, IDC_LABEL4, "") ;
    SetDlgItemText (hwnd, IDC_LABEL5, "") ;
    SetDlgItemText (hwnd, IDC_MC1, "") ;
    SetDlgItemText (hwnd, IDC_MC2, "") ;
    SetDlgItemText (hwnd, IDC_MC3, "") ;
    SetDlgItemText (hwnd, IDC_MC4, "") ;
    SetDlgItemText (hwnd, IDC_MC5, "") ;
}
