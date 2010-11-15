/* Do not alter this SPC information: $Revision: 1.1.29.1 $ */
/********************************************************************
Name:				gcordbg.c
Authors:       Rick Kramer
Creation Date: 03/28/95
Description:   RIS Debug Functions

Revision History:

********************************************************************/
#include <windows.h>
#include <windowsx.h>
#include "gco.h"
#include "resource.h"
#include "gcortns.h"

#define gcordbg_c
#include "gcordbg.prt"
#include "gcortns.prt"
#include "gcodbg.prt"

char *szFlags[] = {
"APP","ARC","BUF","CCO","CLI","COM","DBS","DDS",
"DIC","FIL","FRM","INT","JMP","NET","PAR","REMOTE",
"SQL","SRV","STMT","TREE","TRN","USR","VCO",NULL
};
char *szScreen[] = {
"Client Memory",
"Client Statements",
"Hash Table",
"Schema File",
"App Memory",
"App Statements",
"Struct Mgrs",
"Servers",NULL
};

char sz[ 200 ];
HWND hCheckBox;
HWND hListBox;

FARPROC lpfnOldLbProc;

static BOOL Cls_OnInitDialog(
	HWND hwnd,
	HWND hwndFocus,
	LPARAM lParam)
{
	int i, iItem;
	RECT Rect;
	HWND hList;
	char str[ 30 ];

	_CenterWindow (hwnd, GetWindow (hwnd, GW_OWNER));
	hListBox = GetDlgItem(hwnd,IDC_RDBG_FLAGS);
	for( i = 0; szFlags[ i ]; ++i )
	{                                          //  Make up a string to add
		iItem = SendDlgItemMessage( hwnd, IDC_RDBG_FLAGS, LB_ADDSTRING, 0,(LPARAM)szFlags[i] );
		if( iItem != LB_ERR )                     //  If it was added ok...
		{                            //  Get the RECT the new item occupies
			SendDlgItemMessage( hwnd, IDC_RDBG_FLAGS, LB_GETITEMRECT, iItem, 
				(LPARAM)&Rect );
			hList = CreateWindow( "button", NULL,      //  Create a checkbox
				WS_CHILD | WS_VISIBLE | BS_AUTOCHECKBOX,
				1, Rect.top,                //  in the position of
				Rect.bottom - Rect.top,   //  the new listbox item
				Rect.bottom - Rect.top,       //  RECT so it works
				hListBox,       //  relative to the
				(HMENU)( IDC_RDBG_FLAGS + i ),                    //  listbox
				gco.hhInst, NULL );
			if( hList )       //  Save the checkbox handle as list item data
				SendDlgItemMessage( hwnd, IDC_RDBG_FLAGS, LB_SETITEMDATA, iItem,
					(LPARAM)hList );
		}
	}

	 lpfnOldLbProc = (FARPROC)SetWindowLong( GetDlgItem( hwnd, IDC_RDBG_LBBUTTON ),
	    GWL_WNDPROC, (DWORD)LbSubclassProc );

	 GetClientRect( GetDlgItem( hwnd, IDC_RDBG_LBBUTTON ), &Rect );     //  the scrollbar
	 Rect.right = Rect.right - GetSystemMetrics( SM_CXVSCROLL );

	 for( i = 0; i < 8; i++ )			   //  Make 20 buttons
	 {
	    strcpy( str, szScreen[i]);	       //  Prepare text line

	    /******************************************************************
	    *  In this next section, we add a string to the listbox. Even     *
	    *  though it's never displayed, it forces the scrollbar to        *
	    *  display and automates listbox scrolling. If the string went    *
	    *  into the listbox ok, then we add the button.		      *
	    *  The button ID's start at 1000 and work up.                     *
	    ******************************************************************/

	    if( SendMessage( GetDlgItem( hwnd, IDC_RDBG_LBBUTTON ), LB_ADDSTRING, 0,
	       (LPARAM)(LPSTR)str ) != LB_ERR )
	       CreateWindow( "button", str,
		  WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,
		  0, i * 24, Rect.right, 24,
		  GetDlgItem( hwnd, IDC_RDBG_LBBUTTON ),
			  (HMENU)( i + IDC_RDBG_CMEM ), gco.hhLib, NULL );

	 /******************************************************************
	 *  Note that the button parent is the listbox, allowing us to	   *
	 *  specify the button position coordinates based on the listbox.  *
	 *  This is important for the listbox scrolling of the buttons	   *
	 ******************************************************************/
	 }


	return (TRUE);
}

static void Cls_OnDrawItem(
	HWND hwnd,
	const DRAWITEMSTRUCT * lpDrawItem)
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

static void Cls_OnCommand(
	HWND hwnd,
	int id,
	HWND hwndCtl,
	UINT codeNotify)
{
	int i;
	int count;
	int index;
	char sz2[ 255 ];

	switch (id)
	{
_Debug(PROG,2,"OnCommand: id = %d",id);
		case IDC_RDBG_ALLOFF:
			count = ListBox_GetCount(hListBox);
			for( index = 0; index < count; ++index )
			{
				hCheckBox = (HWND)SendDlgItemMessage( hwnd, IDC_RDBG_FLAGS, LB_GETITEMDATA,index, 0 );
				if (Button_GetCheck(hCheckBox) == TRUE)
					Button_SetCheck(hCheckBox, FALSE);
			}			
			break;

		case IDOK:
			lstrcpy( sz,"" );
			count = ListBox_GetCount(hListBox);
			for( index = 0; index < count; ++index )
			{
				hCheckBox = (HWND)SendDlgItemMessage( hwnd, IDC_RDBG_FLAGS, LB_GETITEMDATA,index, 0 );
				if (Button_GetCheck(hCheckBox))
				{
					ListBox_GetText(hListBox, index, sz2);
					lstrcat( lstrcat( sz, " " ), sz2 );
				}
			}			
			_Debug(PROG,2,"You have chosen: %s",sz);
				
			EndDialog( hwnd, TRUE );
			break;
		break;

		case IDC_RDBG_FLAGS:
		if( codeNotify == LBN_DBLCLK || codeNotify ==LBN_SELCHANGE)      //  List item double-clicked
		{
			i = SendDlgItemMessage( hwnd, IDC_RDBG_FLAGS, LB_GETCURSEL, 0, 0 );
			if( i == LB_ERR )
				break;                           //  Go away if there's an error
                                             //  Get the checkbox window handle
			hCheckBox = (HWND)SendDlgItemMessage( hwnd, IDC_RDBG_FLAGS, LB_GETITEMDATA,i, 0 );
			if (Button_GetCheck(hCheckBox))
				Button_SetCheck(hCheckBox, FALSE);
			else
				Button_SetCheck(hCheckBox, TRUE);
		}
		break;

		case IDC_RDBG_CMEM:
			if( codeNotify == BN_CLICKED)
			{
				Edit_SetText(GetDlgItem(hwnd,IDC_RDBG_DISPLAY), "Show Client Memory");
			}
			break;

		case IDC_RDBG_CSTATE:
			if( codeNotify == BN_CLICKED)
			{
				Edit_SetText(GetDlgItem(hwnd,IDC_RDBG_DISPLAY), "Show Client Statements");
			}
			break;

		case IDC_RDBG_HASH:
			if( codeNotify == BN_CLICKED)
			{
				Edit_SetText(GetDlgItem(hwnd,IDC_RDBG_DISPLAY), "Show Hash Table");
			}
			break;

		case IDC_RDBG_SCHEMA:
			if( codeNotify == BN_CLICKED)
			{
				Edit_SetText(GetDlgItem(hwnd,IDC_RDBG_DISPLAY), "Show Schema File");
			}
			break;

		case IDC_RDBG_AMEM:
			if( codeNotify == BN_CLICKED)
			{
				Edit_SetText(GetDlgItem(hwnd,IDC_RDBG_DISPLAY), "Show APP Memory");
			}
			break;

		case IDC_RDBG_ASTATE:
			if( codeNotify == BN_CLICKED)
			{
				Edit_SetText(GetDlgItem(hwnd,IDC_RDBG_DISPLAY), "Show APP Statements");
			}
			break;

		case IDC_RDBG_STRUCTS:
			if( codeNotify == BN_CLICKED)
			{
				Edit_SetText(GetDlgItem(hwnd,IDC_RDBG_DISPLAY), "Show Struct Mgrs");
			}
			break;

		case IDC_RDBG_SERVERS:
			if( codeNotify == BN_CLICKED)
			{
				Edit_SetText(GetDlgItem(hwnd,IDC_RDBG_DISPLAY), "Show Servers");
			}
			break;
	}
}

static void Cls_OnMeasureItem(
	HWND hwnd,
	MEASUREITEMSTRUCT * lpMeasureItem)
{
	RECT Rect;
	_Debug(PROG,2,"Id=%d", lpMeasureItem->CtlID);

	if (lpMeasureItem->CtlID == IDC_RDBG_LBBUTTON)
	{
   
		GetClientRect( hwnd, &Rect );
     
		lpMeasureItem->itemWidth = Rect.right - 4;	  //  Give it any old junk here
		lpMeasureItem->itemHeight = 24; 	     //  But we insist on 24 units high
	}
}


extern LRESULT CALLBACK RISdebug(
	HWND hwnd,
	UINT uMessage,
	WPARAM wParam,
	LPARAM lParam)
{
	switch (uMessage)
	{
		HANDLE_MSG(hwnd,WM_INITDIALOG,Cls_OnInitDialog);
		HANDLE_MSG(hwnd,WM_COMMAND,Cls_OnCommand);
		HANDLE_MSG(hwnd,WM_DRAWITEM,Cls_OnDrawItem);
		HANDLE_MSG(hwnd,WM_MEASUREITEM,Cls_OnMeasureItem);
	}
	return FALSE ;
}

static LRESULT CALLBACK LbSubclassProc(
	HWND hWnd,
	UINT msg,
	WPARAM wParam,
	LPARAM lParam )
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

