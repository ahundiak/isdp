// ABOUT.C
#include <windows.h>
#include <windowsx.h>
#include <stdio.h>

#include "gco.h"
#include "resource.h"
#include "gcortns.h"

#define sqlutl_c
#include "gcordbg.prt"
#include "gcortns.prt"
#include "gcodbg.prt"

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

static int id =0 ;

static BOOL Cls_OnInitDialog(HWND hwnd, HWND hwndFocus, LPARAM lParam)
{
    char String[200] ;

    switch (id)
    {
        case IDD_GUI_PARAMETERS:
            sprintf (String, 
"%x\r\n%d\r\n%d\r\n%d\r\n%d\r\n%d\r\n%d\r\n%d\r\n%d\r\n%d\r\n%d\r\n%d\r\n%d\r\n%d\r\n%d\r\n",
                200000, 8, 100, 65552, 10, 40, 0, 1, 50,
                0, 12, 5,64, 12, 25) ;
            SetDlgItemText (hwnd, IDC_GUI_EDIT1, String) ;
            SetDlgItemText (hwnd, IDC_GUI_EDIT2, ParameterTitles) ;
            break ;

        case IDD_GUI_SCHEMA_IN_TRANS:
            _Delay(3) ;
            sprintf (String, "melania\r\njoe\r\n") ;
            SetDlgItemText (hwnd, IDC_GUI_EDIT3, String) ;
            break ;

        case IDD_GUI_HISTORY:
            CheckDlgButton (hwnd, IDC_GUI_UP, 1) ;
            CheckDlgButton (hwnd, IDC_GUI_DOWN, 0) ;
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
                    SetDlgItemText (hwnd, IDC_GUI_QRY, String) ;
                    SetDlgItemText (hwnd, IDC_GUI_HSTATUS, "No more matches.") ;
                    SetFocus (GetDlgItem (hwnd,IDC_GUI_SCSTRING )) ;
		    break ;
	}
}

extern LRESULT CALLBACK ProcParameters(
	HWND hwnd,
	UINT uMessage,
	WPARAM wParam,
	LPARAM lParam)
{
    id =IDD_GUI_PARAMETERS ;
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
        id = IDD_GUI_HISTORY ;
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
        id = IDD_GUI_SETTINGS ;
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
        id = IDD_GUI_SCHEMA_IN_TRANS;
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

