/* Do not alter this SPC information: $Revision: 1.1.29.1 $ */
/********************************************************************
Name:				gcophelp.c
Authors:       Rick Kramer
Creation Date: 03/28/95
Description:   Popup Windows Functions

Revision History:

********************************************************************/
#include <windows.h>
#include <windowsx.h>
#include "gcophelp.h"

#define gcophelp_c
#include "gcophelp.prt"


#define    SPOPUP_MAXWIDTH          400

static int aPattern[] = { 0xAA, 0x55, 0xAA, 0x55,
                                   0xAA, 0x55, 0xAA, 0x55 };

extern BOOL FAR PASCAL RegisterSPopupClass(
	HANDLE hInst )
{
    WNDCLASS wc;

    wc.hCursor          = LoadCursor( NULL, IDC_ARROW );
    wc.hIcon            = NULL;
    wc.lpszMenuName     = NULL;
    wc.lpszClassName    = "spopup";
    wc.hbrBackground    = (HBRUSH)( COLOR_WINDOW + 1 );
    wc.hInstance        = hInst;
    wc.style            = CS_HREDRAW | CS_VREDRAW;
    wc.lpfnWndProc      = SPopupWndFn;
    wc.cbClsExtra       = 0;
    wc.cbWndExtra       = 0;
    if( !RegisterClass( &wc ) )
        return( FALSE );
    return( TRUE );
}

extern HWND FAR PASCAL _CreateSPopup(
	int x,
	int y,
	int cx,
	int cy,
   HWND hwnd,
	HANDLE hInst,
	void FAR * lParam )
{
   HWND hwndPopup;
   DWORD dwStyle = 0L;

   if( hwnd )
      dwStyle = WS_CHILD;
   else
      dwStyle = WS_POPUP;
   hwndPopup = CreateWindow( "spopup", NULL,
            dwStyle, x, y, cx, cy, hwnd, NULL,
            hInst, lParam );
   ShowWindow( hwndPopup, SW_SHOWNOACTIVATE );
   UpdateWindow( hwndPopup );
   return( hwndPopup );
}

extern void FAR PASCAL _PopupText(
	HWND hwnd,
	int x,
	int y,
	LPSTR lpszText )
{
    HWND hwndPopup;
    HANDLE hInst;
    RECT rc;
    BOOL fDone;
    MSG msg;
    HDC hdc;
    hdc = CreateDC( "DISPLAY", NULL, NULL, NULL );
    SelectObject( hdc, GetStockObject( SYSTEM_FONT ) );
    SetRect( &rc, 0, 0, SPOPUP_MAXWIDTH, 0 );
SetBkMode(hdc,TRANSPARENT);
    DrawText( hdc, lpszText, -1, &rc,
        DT_NOPREFIX|DT_WORDBREAK|DT_CALCRECT );
    rc.right += 10;
    DeleteDC( hdc );

    hInst = (HINSTANCE)GetWindowWord( hwnd, GWL_HINSTANCE );
    hwndPopup = _CreateSPopup( x, y,
        rc.right + SPOPUP_SHADOWWIDTH * 3,
        rc.bottom + SPOPUP_SHADOWHEIGHT * 3,
        hwnd, hInst, NULL );

    hdc = GetDC( hwndPopup );
    OffsetRect( &rc, SPOPUP_SHADOWWIDTH,
                    SPOPUP_SHADOWHEIGHT );
SetBkMode(hdc,TRANSPARENT);

    DrawText( hdc, lpszText, -1, &rc,
        DT_WORDBREAK|DT_NOPREFIX );
    ReleaseDC( hwndPopup, hdc );
//MessageBox(NULL,"In _PopupText()","gcophelp.c",MB_OK);

    SetCapture( hwndPopup );
    for( fDone = FALSE; !fDone; )
        if( PeekMessage( &msg, NULL, 0, 0, PM_REMOVE ) )
            if( msg.message == WM_KEYDOWN ||
                 msg.message == WM_SYSKEYDOWN ||
                 msg.message == WM_LBUTTONDOWN ||
                 msg.message == WM_MBUTTONDOWN ||
                 msg.message == WM_RBUTTONDOWN )
                fDone = TRUE;
            else {
                TranslateMessage( &msg );
                DispatchMessage( &msg );
                }
    ReleaseCapture();
    DestroyWindow( hwndPopup );
}

static LRESULT CALLBACK SPopupWndFn(
	HWND hwnd,
	UINT message,
	WPARAM wParam,
	LPARAM lParam )
{
    static HBITMAP hbm = NULL;
    static HBRUSH hbr = NULL;
    static int nUsage = 0;

    switch( message )
        {
        case WM_NCCREATE:
            if( nUsage++ == 0 ) {
                hbm = CreateBitmap( 8, 8, 1, 1, aPattern );
                hbr = CreatePatternBrush( hbm );
                }
            break;

        case WM_NCDESTROY:
            if( --nUsage == 0 ) {
                DeleteObject( hbm );
                DeleteObject( hbr );
                }
            break;

        case WM_NCCALCSIZE: {
            LPRECT lpClRc = (LPRECT)lParam;

            lpClRc->left += 1;
            lpClRc->top += 1;
            lpClRc->right -= SPOPUP_SHADOWWIDTH + 1;
            lpClRc->bottom -= SPOPUP_SHADOWHEIGHT + 1;
            break;
            }

        case WM_NCPAINT: {
            RECT rc;
            HDC hdc;
            HBRUSH hbrFrame;
            HBRUSH hbrOld;

            hdc = GetWindowDC( hwnd );
            GetWindowRect( hwnd, &rc );
            rc.right -= rc.left;
            rc.bottom -= rc.top;
            rc.top = 0;
            rc.left = 0;

            UnrealizeObject( hbr );
            hbrOld = SelectObject( hdc, hbr );
            PatBlt( hdc, rc.left + SPOPUP_SHADOWWIDTH,
                      rc.bottom - SPOPUP_SHADOWHEIGHT,
                      rc.right - SPOPUP_SHADOWWIDTH,
                      SPOPUP_SHADOWHEIGHT, 0xA000C9 );
            PatBlt( hdc, rc.right - SPOPUP_SHADOWWIDTH,
                      rc.top + SPOPUP_SHADOWHEIGHT,
                      SPOPUP_SHADOWWIDTH,
                      rc.bottom, 0xA000C9);
            SelectObject( hdc, hbrOld );

            hbrFrame = CreateSolidBrush(
                    GetSysColor( COLOR_WINDOWFRAME ) );
            rc.right -= SPOPUP_SHADOWWIDTH;
            rc.bottom -= SPOPUP_SHADOWHEIGHT;
            FrameRect( hdc, &rc, hbrFrame );
            DeleteObject( hbrFrame );

            ReleaseDC( hwnd, hdc );
         break;
            }
        }
    return( DefWindowProc( hwnd,message, wParam, lParam ) );
}
