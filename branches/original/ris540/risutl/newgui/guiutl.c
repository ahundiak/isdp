// ABOUT.C
#include <windows.h>
#include <windowsx.h>
#include <stdio.h>

#include "gco.h"
#include "resource.h"

#include "gcortns.h"

#define guiutl_c
#include "gcordbg.prt"
#include "gcortns.prt"
#include "gcodbg.prt"

extern HWND PWnd ;

FARPROC lpfnOldLbProc;
static char ParameterTitles [1024] =
{
"Shared Memory\r\n\
Maximum Local Servers\r\n\
Maximum Rows\r\n\
Maximum Buffer\r\n\
Maximum Static Statements\r\n\
Maximum User Statements\r\n\
Maximum Secondary Schemas\r\n\
Maximum Transactions\r\n\
Maximumm Tables in Memory\r\n\
Timestamp Interval\r\n\
Initial Timeout\r\n\
Timestamp Tolerance\r\n\
Buffer Full Size\r\n\
Buffer Full Timeout\r\n\
Lock File Retry\r\n\
"} ;

static char ParameterFormat [100] =
{"%x\r\n%d\r\n%d\r\n%d\r\n%d\r\n%d\r\n%d\r\n%d\r\n%d\r\n%d\r\n%d\r\n%d\r\n%d\r\n%d\r\n%d\r\n" } ;

static int IdOfDlg =0 ;

static VOID MyDelay()
{
    STARTWAIT;
    _Delay(3) ;
    ENDWAIT ;
}

// ************************************************************************
// FUNCTION : CopyListBoxToClipboard( HWND, LONG )
// PURPOSE  : Copies the entire contents of a listbox into the clipboard.
// COMMENTS : Returns TRUE on success, FALSE otherwise
// ************************************************************************
BOOL
CopyListBoxToClipboard( HWND hWndListBox, LONG MaxStrLen )
{
  LPTSTR  lpDataBuffer;
  HGLOBAL hDataBuffer;

  TCHAR  TempBuffer[256];
  DWORD  dwItemCount;
  DWORD  Count;
  LONG   StrLen;
  DWORD  dwMemSize;

  dwItemCount = (DWORD) SendMessage( hWndListBox, LB_GETCOUNT, 0 , 0 );
  dwMemSize = dwItemCount * (DWORD) MaxStrLen;

  //-- limit the size copied to the clipboard
  if( dwMemSize > 0xFFFFF )
    dwMemSize = 0xFFFFF;

  if( !(hDataBuffer = GlobalAlloc( GMEM_DDESHARE, dwMemSize ) ) ) {
    return( FALSE );
  }
  if( !(lpDataBuffer = (LPTSTR) GlobalLock( hDataBuffer ) ) ) {
    GlobalFree( hDataBuffer );
    return( FALSE );
  }

  *lpDataBuffer = '\0';

  for( Count = 0; Count < dwItemCount; Count++ ) {
    StrLen = SendMessage( hWndListBox, LB_GETTEXTLEN, Count, 0L );
    if( StrLen > (sizeof(TempBuffer)-3) )
      continue;
    StrLen = SendMessage( hWndListBox, LB_GETTEXT, Count, (LPARAM) TempBuffer );
    TempBuffer[StrLen]   = '\r';
    TempBuffer[StrLen+1] = '\n';
    TempBuffer[StrLen+2] = '\0';
    lstrcat( lpDataBuffer, TempBuffer );
  }
   
  GlobalUnlock( hDataBuffer );

  if( !OpenClipboard( hWndListBox ) ) {
    Sleep( 250 );  // wait a quarter second and try again.
    if( !OpenClipboard( hWndListBox ) ) {
      MessageBox( GetFocus(),
        TEXT( "Could not open the Clipboard!" ),
        TEXT( "Cannot Open Clipboard" ),
        MB_ICONSTOP | MB_APPLMODAL );
      GlobalFree( hDataBuffer );
      return( FALSE );
    }
  }
  if( !EmptyClipboard() ) {
    MessageBox( GetFocus(),
      TEXT( "Could not empty the Clipboard!" ),
      TEXT( "Cannot Empty Clipboard" ),
      MB_ICONSTOP | MB_APPLMODAL );
    GlobalFree( hDataBuffer );
    return( FALSE );
  }
  if( !SetClipboardData( CF_TEXT, hDataBuffer ) ) {
    MessageBox( GetFocus(),
      TEXT( "Could not copy data to the Clipboard!" ),
      TEXT( "Cannot Set Clipboard Data" ),
      MB_ICONSTOP | MB_APPLMODAL );
    GlobalFree( hDataBuffer );
    return( FALSE );
  }
  CloseClipboard();

  return( TRUE );
}



static BOOL Cls_OnInitDialog(HWND hwnd, HWND hwndFocus, LPARAM lParam)
{
    char String[200] ;

    switch (IdOfDlg)
    {
        case IDD_GUI_PARAMETERS:
            MyDelay() ;
            sprintf (String, 
"%x\r\n%d\r\n%d\r\n%d\r\n%d\r\n%d\r\n%d\r\n%d\r\n%d\r\n%d\r\n%d\r\n%d\r\n%d\r\n%d\r\n%d\r\n",
                200000, 8, 100, 65552, 10, 40, 0, 1, 50,
                0, 12, 5,64, 12, 25) ;
            SetDlgItemText (hwnd, IDC_GUI_EDIT1, String) ;
            SetDlgItemText (hwnd, IDC_GUI_EDIT2, ParameterTitles) ;
            break ;

        case IDD_GUI_SCHEMA_IN_TRANS:
            MyDelay() ;
            sprintf (String, "melania\r\njoe\r\n") ;
            SetDlgItemText (hwnd, IDC_GUI_EDIT3, String) ;
            break ;

        case IDD_GUI_HISTORY:
            CheckDlgButton (hwnd, IDC_GUI_UP, 1) ;
            CheckDlgButton (hwnd, IDC_GUI_DOWN, 0) ;
            break ;

        case IDD_GUI_SETTINGS:
            /* SETTINGS */
            MyDelay() ;
            CheckDlgButton(hwnd,IDC_GUI_ANSI_CK, TRUE);
            CheckDlgButton(hwnd,IDC_GUI_VERIFY_GUI, TRUE);
            CheckDlgButton(hwnd,IDC_GUI_COMMIT_CK, TRUE);
            CheckDlgButton(hwnd,IDC_GUI_BLANK_CK, TRUE);
            CheckDlgButton(hwnd,IDC_GUI_OS400_CK, TRUE);
            CheckDlgButton(hwnd,IDC_GUI_INX_CK, TRUE);
            CheckDlgButton(hwnd,IDC_GUI_ORACLE_CK, TRUE);
            CheckDlgButton(hwnd,IDC_GUI_INGRES_CK, TRUE);
            CheckDlgButton(hwnd,IDC_GUI_DB2_CK, TRUE);
            CheckDlgButton(hwnd,IDC_GUI_SQL_CK, TRUE);
            CheckDlgButton(hwnd,IDC_GUI_RDB_CK, TRUE);
            CheckDlgButton(hwnd,IDC_GUI_SYBASE_CK, TRUE);
            CheckDlgButton(hwnd,IDC_GUI_SQL_CK, TRUE);
            CheckDlgButton(hwnd,IDC_GUI_RENAME_CK, TRUE);
            CheckDlgButton(hwnd,IDC_GUI_MSSQL_CK, TRUE);
        break ;

    }
    _CenterWindow (hwnd, GetWindow (hwnd, GW_OWNER));
        
    return (TRUE);
}

static void Cls_OnDrawItem(HWND hwnd, const DRAWITEMSTRUCT * lpDrawItem)
{
	LPDRAWITEMSTRUCT lpDs = (LPDRAWITEMSTRUCT)lpDrawItem;
	char szText[ 64 ];
	RECT Rect;
	HBRUSH hBrush;

	if( lpDs->itemID < 0 )                //  Not a legal value? Then quit
		return;

	GetClientRect( lpDs->hwndItem, &Rect );           //  Get listbox size
	Rect.top = lpDs->rcItem.top;              //  Use item vertical height
	Rect.bottom = lpDs->rcItem.bottom;
	Rect.left += 15;        //  Move right so the checkbox isn't clobbered
	hBrush = CreateSolidBrush( GetSysColor( COLOR_WINDOW ) );
	FillRect( lpDs->hDC, &Rect, hBrush );           //  Fill the item area
	DeleteObject( hBrush );                        //  Clean up fill brush
                                        
	ListBox_GetText(lpDs->hwndItem, lpDs->itemID, szText);

	TextOut( lpDs->hDC, 17, lpDs->rcItem.top + 1,    //  And display it in
		szText, lstrlen( szText ) );            //  the item position
	if( lpDs->itemState & ODS_SELECTED )
	{
		lpDs->rcItem.left += 15;             //   Don't invert the checkbox
		InvertRect( lpDs->hDC, &Rect );    //  If selected, invert the area
	}
	return;
}

static void Cls_OnCommand(HWND hwnd, int id, HWND hwndCtl, UINT codeNotify)
{
    char String [200] = "select * from ris05_t07 where column_name = \"ORACLE\"" ;
    HWND hwnd1 ;
    
	switch (id)
	{
_Debug(PROG,2,"OnCommand: id = %d",id);
		case IDOK:
		    EndDialog( hwnd, TRUE );
		    break;
		break;
		
		case IDCANCEL:
		    EndDialog( hwnd, TRUE );
		    break;
		break;

		    
		case IDC_GUI_FIND_NEXT:
                    SendDlgItemMessage (hwnd, IDC_GUI_QRY, LB_ADDSTRING, 0, String) ;
                    SetDlgItemText (hwnd, IDC_GUI_HSTATUS, "No more matches.") ;
                    SetFocus (GetDlgItem (hwnd,IDC_GUI_SCSTRING )) ;
		    break ;

	        case IDC_GUI_COPY:
                    CopyListBoxToClipboard( GetDlgItem(hwnd, IDC_GUI_QRY), 1024) ;
           	    SendMessage(GetDlgItem(PWnd, IDC_GUI_QUERY),WM_PASTE,0,0L);
        	    EndDialog (hwnd, TRUE) ;
		    break;

	}
}

extern LRESULT CALLBACK ProcParameters(
	HWND hwnd,
	UINT uMessage,
	WPARAM wParam,
	LPARAM lParam)
{
        IdOfDlg =IDD_GUI_PARAMETERS ;
	switch (uMessage)
	{
		HANDLE_MSG(hwnd,WM_INITDIALOG,Cls_OnInitDialog);
		HANDLE_MSG(hwnd,WM_COMMAND,Cls_OnCommand);
		HANDLE_MSG(hwnd,WM_DRAWITEM,Cls_OnDrawItem);
	}
	return FALSE ;
}

extern LRESULT CALLBACK ProcHistory(
	HWND hwnd,
	UINT uMessage,
	WPARAM wParam,
	LPARAM lParam)
{
        IdOfDlg = IDD_GUI_HISTORY ;
	switch (uMessage)
	{
		HANDLE_MSG(hwnd,WM_INITDIALOG,Cls_OnInitDialog);
		HANDLE_MSG(hwnd,WM_COMMAND,Cls_OnCommand);
		HANDLE_MSG(hwnd,WM_DRAWITEM,Cls_OnDrawItem);
	}
	return FALSE ;
}

extern LRESULT CALLBACK ProcSettings(
	HWND hwnd,
	UINT uMessage,
	WPARAM wParam,
	LPARAM lParam)
{
        IdOfDlg = IDD_GUI_SETTINGS ;
	switch (uMessage)
	{
		HANDLE_MSG(hwnd,WM_INITDIALOG,Cls_OnInitDialog);
		HANDLE_MSG(hwnd,WM_COMMAND,Cls_OnCommand);
		HANDLE_MSG(hwnd,WM_DRAWITEM,Cls_OnDrawItem);
	}
	return FALSE ;
}

extern LRESULT CALLBACK ProcSchemaInTrans(
	HWND hwnd,
	UINT uMessage,
	WPARAM wParam,
	LPARAM lParam)
{
        IdOfDlg = IDD_GUI_SCHEMA_IN_TRANS;
	switch (uMessage)
	{
		HANDLE_MSG(hwnd,WM_INITDIALOG,Cls_OnInitDialog);
		HANDLE_MSG(hwnd,WM_COMMAND,Cls_OnCommand);
		HANDLE_MSG(hwnd,WM_DRAWITEM,Cls_OnDrawItem);
	}
	return FALSE ;
}


static LRESULT CALLBACK LbSubclassProc( HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam )
{
   /***************************************************************************
   *  Since we specified that the buttons are children of the listbox, we     *
   *  to subclass the listbox and pass any notification messages back to the  *
   *  listbox's parent to it can operate on them as usual. It could be        *
   *  handled here, but best not to interfere too much. 		      *
   ***************************************************************************/
   if( msg == WM_COMMAND)
	{
_Debug(PROG,2,"LbSubClassProc: id = %d",wParam);
		if (wParam >= IDC_RDBG_CMEM && wParam <= IDC_RDBG_SERVERS )
			PostMessage( GetParent( hWnd ), WM_COMMAND, wParam, lParam );
	}	
   //  Finish with a call to the original proc
   return( CallWindowProc( lpfnOldLbProc, hWnd, msg, wParam, lParam ) );
}

