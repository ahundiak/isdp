#include "stdio.h"
#include "wl.h"
#include "preview.h"

#if defined( WIN32x )

/*---MainWinProc----------------------------------------------------*/

LRESULT CALLBACK MainWndProc( HWND hwnd, 
                              UINT message, 
                              WPARAM wParam, 
                              LPARAM lParam)
   {
   WLuint32 lwin_no;

   switch (message)
      {
      case WM_DESTROY: PostQuitMessage (0); break;
      case WM_MOUSEMOVE: break;
      case WM_LBUTTONDOWN: break;
      case WM_LBUTTONUP: break;
      case WM_RBUTTONUP: break;
      case WM_RBUTTONDOWN: break;
      case WM_CREATE: break;

      case WM_PAINT:
         WLget_logical_window (hwnd, &lwin_no);
         display_geometry (lwin_no);
         ValidateRect (hwnd, NULL);
         break;

      default:
         return (DefWindowProc (hwnd, message, wParam, lParam));
         }
   return (NULL);
   }

int APIENTRY WinMain (HINSTANCE hInstance, 
                      HINSTANCE hPrevInstance,
                      LPSTR lpCmdLine, 
                      int nCmdShow)
   {
   hmain_instance = hInstance;
   main ();
   }

int DLTwin32_event_loop ( void)

   {
   MSG msg;
   struct window_node *win_node;

   /* update all the windows one time because we don't get an initial event */
   win_node = preview.win_head;
   while (win_node)
      {
      display_geometry (win_node->lwin_no);
      win_node = win_node->next;
      }

   /* Loop getting messages and dispatching them. */
   while (GetMessage (&msg, NULL, 0, 0))
      {
      TranslateMessage (&msg);
      DispatchMessage (&msg);
      }

   }    /* DLTwin32_event_loop */


#elif defined( ENV5 )

#define	TRUE	1

void env5_event_loop ( void (*expose_function)(void) )

   {
   int mask = BUTTON_EVENT | DELETE_EVENT | COLLAPSE_EVENT | 
              REFRESH_EVENT | COVER_EVENT | TIMER_EVENT;
   int cur_event;
   int win_no;
   int x, y;
   int button, transition, timetag;
   int status;

   if( expose_function != NULL )
      (*expose_function)();

   /* loop over events */
   while (TRUE)
      {
      Enable_events (mask);
      Wait_for_next (mask, &cur_event);
      switch (cur_event)
         {

         case TIMER_EVENT:
            Clear_timer_data ();
            break;

         case COVER_EVENT:
            printf( "cover event\n" );
            break;

         case BUTTON_EVENT:
            printf( "button event\n" );
            Get_button_data (&win_no, &x, &y, &button, &transition, &timetag);
            break;

         case DELETE_EVENT:
            printf( "delete event\n" );
            return;

         case COLLAPSE_EVENT:
            printf( "collapse event\n" );
            Get_collapse_data( &win_no, &status );
            break;

         case REFRESH_EVENT:
            if( expose_function != NULL )
               (*expose_function)();
            break;

            }   /* end: switch */

      } /* end: while */

   }    /* env5_event_loop */

#elif defined ( X11 )

void x11_event_loop ( void (*expose_function)(void) )

   {
   WLuint32 lwin_no, context_no;
   XEvent event;

   while (TRUE)
      {
      if (XPending (preview.init_ret.display) > 0)
         {
         XNextEvent (preview.init_ret.display, &event);
         switch (event.type)
            {
            case 5:
               WLget_logical_window (event.xany.window, &lwin_no);
               return;
               break;

            case Expose:
               WLget_logical_window (event.xany.window, &lwin_no);

               if( expose_function != NULL )
                  (*expose_function)();
               else
                  return;
               break;

            /*
             *  Do this to kill the session
             *  Doesn't seem to make since, but this is what you
             *  get when you select "close" on the pull down
             */

            case ClientMessage:
               WLexit();
               exit( 0 );
               break;
            }
         }
      }

   return;
   }    /* DLTx11_event_loop */

#endif
