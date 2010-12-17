/* Do not alter this SPC information: $Revision: 1.1.29.1 $ */
/********************************************************************
Name:				gcotips.c
Authors:       Rick Kramer
Creation Date: 03/28/95
Description:   Tool Tips Functions

Revision History:

********************************************************************/
/******************************************************************************

                         Tooltip example by Mark Gamber.
                              Rev 0.2. - 10/22/94
                         
   Tooltips are those little yellowish windows that appear over buttons in
   some programs like Excel, Word and so on. This program demonstrates one
   way to get the same effect. Everything from "Actual Tooltip Code Starts
   Here" on down can be cut-n-pasted into an application to include this
   functionality.
   
   This revision corrects a bug in the mouse capture and allows the tip window
   to display without being activated. Previously, when a tip window
   displayed, it also became the active window which is distracting and moves
   the focus.
   
   This program is public domain. In using the program or any part thereof,
   the user agrees to hold harmless the program and it's author from any
   loss of damage caused by the program, any part of it or anything else for
   that matter. The program and all parts are unsupported. If unable to
   comply with this restriction, the program or any part may not be used and
   must be destroyed immediately.

******************************************************************************/

#include <windows.h>
#include <windowsx.h>

#define gcotips_c
#include "gcotips.prt"

#define TIPCLASS "tipclass"             //  CHANGE THIS BEFORE CUT-N-PASTING!!!
//#define TIPTIMEOUT  250                    //  Milliseconds before tip kicks in
#define TIPTIMEOUT  50                    //  Milliseconds before tip kicks in

/******************************************************************************
   
   InitializeTips(): Registers tip window class. Registration is assumed ok.
   
******************************************************************************/
extern BOOL _InitializeTips(
	HINSTANCE hInstance )
{
   WNDCLASS wc;
   
   wc.style = CS_BYTEALIGNCLIENT | CS_SAVEBITS;         //  Use these for speed
   wc.hInstance = hInstance;
   wc.lpfnWndProc = TipWndProc;
   wc.hbrBackground = GetStockObject( NULL_BRUSH );
   wc.lpszClassName = TIPCLASS;
   wc.lpszMenuName = (LPSTR)NULL;
   wc.hIcon = (HICON)NULL;
   wc.hCursor = LoadCursor( NULL, IDC_ARROW );
   wc.cbClsExtra = wc.cbWndExtra = 0;
   RegisterClass( &wc );

   return( TRUE );           //  Just return true. Base failure on tip creation
}
   
/******************************************************************************

                    TipWndProc(): Tooltip window procedure

******************************************************************************/
static LRESULT WINAPI TipWndProc(
	HWND hWnd,
	UINT msg,
	WPARAM wParam,
	LPARAM lParam )
{
   switch( msg )
   {
      case WM_CREATE:
      {
         HWND hNew;
         HDC hDC;
         HFONT hFont;
         SIZE size;
         FARPROC lpfnProc;
         char str[ 128 ];
         LPCREATESTRUCT lpCs;
         
         lpCs = (LPCREATESTRUCT)lParam;    //  Get create structure from lParam
                                             //  Get window to apply the tip to
         hNew = *(HWND far *)lpCs->lpCreateParams;                  

         if( ! hNew )
            return( -1 );                   //  Fail if no window handle passed
         
         if( ! GetClassName( hNew, str, 32 ) )    //  Fail if bad window handle
            return( -1 );
         
         if( ! lstrcmpi( str, TIPCLASS ) )    //  Fail if target is a tooltip
            return( -1 );
         
         if( ! GetWindowText( hWnd, str, 128 ) )     //  Fail if no text passed
            return( -1 );
                      
         hFont = CreateFont( -8,           //  Apply a small font to the window
                             0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                             "Helv" );
         hDC = GetDC( hWnd );
         SelectObject( hDC, hFont );    //  Determine size based on text length
         GetTextExtentPoint( hDC, str, lstrlen( str ), &size );
         ReleaseDC( hWnd, hDC );
         DeleteObject( hFont );
         
         size.cx += 7;                      //  Add a few pixels here and there
         size.cy += 3;                                //  And resize the window
         SetWindowPos( hWnd, NULL, 0, 0, size.cx, size.cy, 
                       SWP_NOZORDER | SWP_NOMOVE );            
                                //  Get original proc address of target control
         lpfnProc = (FARPROC)GetWindowLong( hNew, GWL_WNDPROC );

                               //  Save address as properties of target control
         SetProp( hNew, MAKEINTATOM( 10000 ), (HANDLE)LOWORD( lpfnProc ) );
         SetProp( hNew, MAKEINTATOM( 10001 ), (HANDLE)HIWORD( lpfnProc ) );
                                   //  Initialize tip status for control access
         SetProp( hNew, MAKEINTATOM( 10002 ), (HANDLE)0 );
                                       //  Save this tip handle as control prop
         SetProp( hNew, MAKEINTATOM( 10003 ), hWnd );
                                       //  finally, subclass the target control
         SetWindowLong( hNew, GWL_WNDPROC, (DWORD)CtrlSubProc );
         break;
      }
        
      
      case WM_USER + 1024:           //  Custom message from subclassed control
         if( wParam )
         {  
            RECT Rect;
            int xpos, ypos, xMax, yMax;
            POINT pt;


            pt.x = LOWORD( lParam );          //  X and Y position of mouse are
            pt.y = HIWORD( lParam );    //  passed in lParam (if to be visible)

            GetClientRect( hWnd, &Rect );              //  Get current tip size
            
            xpos = pt.x + 12;                   //  Position tip next to cursor
            ypos = pt.y;

            xMax = GetSystemMetrics( SM_CXSCREEN );         //  Get screen size
            yMax = GetSystemMetrics( SM_CYSCREEN );

            while( xpos + Rect.right > xMax )           //  If offscreen, start
               xpos -= 8;                  //  taking off pixels until onscreen

            while( xpos < 0 )          //  If offscreen to the left, add pixels
               xpos += 8;                               //  until on the screen

            while( ypos + Rect.bottom > yMax )        //  Do same with vertical
               ypos -= 8;                                      //  tip location

            while( ypos < 0 )
               ypos += 8;
            
            SetWindowPos( hWnd, HWND_TOPMOST, xpos, ypos, 0, 0,
                          SWP_NOSIZE | SWP_NOACTIVATE | SWP_SHOWWINDOW );
         }
         else                            //  if wParam is zero, hide the window
            if( IsWindowVisible( hWnd ) )
               ShowWindow( hWnd, SW_HIDE );
         break;                                       //  End of WM_USER + 1024

      
      case WM_PAINT:                                   //  Window needs painted
      {
         PAINTSTRUCT ps;
         HDC hDC;
         HFONT hFont;
         HBRUSH hBrush;
         char str[ 128 ];
         RECT Rect;
         
         hDC = BeginPaint( hWnd, &ps );
         GetClientRect( hWnd, &Rect );                      //  Get window size
         
         Rect.right -= 1;                 //  Knock one off to allow a "shadow"
         Rect.bottom -= 1;
                                               //  Use that sickly yellow color
         hBrush = CreateSolidBrush( RGB( 255, 255, 128 ) );
         SelectObject( hDC, hBrush );        //  and a black pen for the border
         SelectObject( hDC, GetStockObject( BLACK_PEN ) );
                                                         //  Fill in the window
         Rectangle( hDC, 0, 0, Rect.right, Rect.bottom );
         
         SetBkMode( hDC, TRANSPARENT );      //  Don't use background with text
         GetWindowText( hWnd, str, 128 );     //  Get text and use a small font
         hFont = CreateFont( -8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "Helv" );
         SelectObject( hDC, hFont );
                                              //  Display text. This isn't used
         ExtTextOut( hDC, 2, 1, ETO_CLIPPED, &Rect,  //  to fill in the rect as
                     str, lstrlen( str ), NULL );     //  it doesn't do dithers
                     
         Rect.right += 1;                           //  Move into "shadow" area
         Rect.bottom += 1;
         
         MoveToEx( hDC, 1, Rect.bottom - 1, NULL );       //  Draw shadow lines
         LineTo( hDC, Rect.right - 1, Rect.bottom - 1 );
         LineTo( hDC, Rect.right - 1, 1 );
         
         EndPaint( hWnd, &ps );
         DeleteObject( hBrush );
         DeleteObject( hFont );               //  All done...clean up and leave
         break;
      }                                                     //  End of WM_PAINT


      case WM_NCHITTEST:         //  Let clicks and stuff go through the window
         return( HTTRANSPARENT );      //  to any underlying windows (controls)
            
      
      default:                   //  Oh yeah...default junk. Can't forget that!
         return( DefWindowProc( hWnd, msg, wParam, lParam ) );
   }
   return( FALSE );
}                                                //  End of the tip window proc

/******************************************************************************

    CtrlSubProc(): Subclass proc for controls the tip window is applied to

******************************************************************************/
static LRESULT WINAPI CtrlSubProc(
	HWND hWnd,
	UINT msg,
	WPARAM wParam, 
                            LPARAM lParam )
{
   LRESULT ( WINAPI *lpfnProc )( HWND, UINT, WPARAM, LPARAM );
                   //  We need the original address for anything, so get it now
   (FARPROC)lpfnProc = (FARPROC)MAKELONG( 
                                 GetProp( hWnd, MAKEINTATOM( 10000 ) ),
                                 GetProp( hWnd, MAKEINTATOM( 10001 ) ) );

   if( msg == WM_DESTROY )          //  If window is about to go away, clean up
   {                                               //  Restore original address
      SetWindowLong( hWnd, GWL_WNDPROC, (DWORD)lpfnProc );
      
      RemoveProp( hWnd, MAKEINTATOM( 10000 ) );     //  Kill off attached props
      RemoveProp( hWnd, MAKEINTATOM( 10001 ) );
      RemoveProp( hWnd, MAKEINTATOM( 10002 ) );
      RemoveProp( hWnd, MAKEINTATOM( 10003 ) );
   }                                       //  Fall through to CallWindowProc()


   if( msg == WM_MOUSEMOVE ||                 //  Trap any input to the control
       msg == WM_LBUTTONDOWN ||
       msg == WM_RBUTTONDOWN ||
       msg == WM_MBUTTONDOWN ||
       msg == WM_LBUTTONUP ||
       msg == WM_RBUTTONUP ||
       msg == WM_MBUTTONUP ||
       msg == WM_SETFOCUS ||                   //   That includes focus changes
       msg == WM_KILLFOCUS ||
       ( msg >= WM_KEYFIRST && msg <= WM_KEYLAST ) ||        //  Keyboard input
       ( msg == WM_ACTIVATEAPP && ! wParam ) )       //  and activation changes
   {
      POINT pt;
      RECT Rect;
      BOOL bOnControl;

      GetCursorPos( &pt );               //  Get current cursor screen position
      GetWindowRect( hWnd, &Rect );      //  and this control's screen position
      
      if( pt.x < Rect.left || pt.x > Rect.right ||       //  Is the cursor over
          pt.y < Rect.top || pt.y > Rect.bottom ||           //  the control or
          msg != WM_MOUSEMOVE ||           //  is the message not a movement or
          GetAsyncKeyState( VK_LBUTTON ) < 0 )    //  is the mouse button down?
         bOnControl = FALSE;               //  If so, don't show the tip window
      else
         bOnControl = TRUE;                     //  Else, tag it, it's a keeper
                              //  If something's in motion, don't allow display
      if( msg == WM_LBUTTONDOWN || msg == WM_RBUTTONDOWN ||
          msg == WM_LBUTTONUP || msg == WM_RBUTTONUP )
         bOnControl = FALSE;

      if( ! bOnControl )               //  Now then...if display is not allowed
      {
         KillTimer( hWnd, 1 );                       //  Stop the current timer
         SetProp( hWnd, MAKEINTATOM( 10002 ), (HANDLE)0 );
                                               //  and if the window is visible
         if( IsWindowVisible( GetProp( hWnd, MAKEINTATOM( 10003 ) ) ) )
         {
            SendMessage( GetProp( hWnd, MAKEINTATOM( 10003 ) ), 
                         WM_USER + 1024, 0, 0 );
         
            ReleaseCapture();            //  Finally, release the mouse capture
         }
      }
      else                                         //  If display is allowed...
      {                          //  If the tip window is not currently visible
         if( ! IsWindowVisible( GetProp( hWnd, MAKEINTATOM( 10003 ) ) ) )
         {
            SetTimer( hWnd, 1, TIPTIMEOUT, NULL ); 
            SetProp( hWnd, MAKEINTATOM( 10002 ), (HANDLE)1 ); //  Timer started
         }
      } 
   }                                       //  End of WM_... message processing


   if( msg == WM_TIMER ) //  Timeout passed since tip window display considered
   {
      POINT pt;
      RECT Rect;
      
      KillTimer( hWnd, 1 );                                  //  Kill the timer
      SetProp( hWnd, MAKEINTATOM( 10002 ), (HANDLE)0 );        //  Timer killed
                                                 //  (Violent profession, huh?)
      GetCursorPos( &pt );                  //  Get the current cursor position
      GetWindowRect( hWnd, &Rect );         //  and the control screen position

      if( pt.x > Rect.left && pt.x < Rect.right &&    //  If cursor is in range
          pt.y > Rect.top && pt.y < Rect.bottom )
      {                        //  Send message to tip window to display itself
         SendMessage( GetProp( hWnd, MAKEINTATOM( 10003 ) ),
                      WM_USER + 1024,
                      1, MAKELPARAM( pt.x, pt.y ) );
         
         SetCapture( hWnd );         //  Capture the mouse so it can be tracked
      }
   }
                                  //  End subclass with original procedure call
   return( CallWindowProc( lpfnProc, hWnd, msg, wParam, lParam ) );
}

/******************************************************************************

                      CreateTip(): Creates the tip window
   
   This function is called by the program with the program's instance handle,
   parent (dialog box) window handle, control ID number and text to display.
   
******************************************************************************/
extern BOOL _CreateTip(
	HINSTANCE hinst,
	HWND hParent,
	int iID,
	LPSTR lpText )
{
   HWND hChild;

   hChild = GetDlgItem( hParent, iID );
   CreateWindow( TIPCLASS, lpText, WS_POPUP, 0, 0, 1, 1, NULL,
                 NULL, hinst, (LPVOID)&hChild );
   return( TRUE );
}

   
