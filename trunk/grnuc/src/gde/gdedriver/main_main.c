/*  main()
 *
 *  This is the main function.  It performs the neccessary initialization
 *  and creates the menus and then enters a loop which just passes events
 *  to the forms and menus sub-systems.
 */

/*
$Log: main_main.c,v $
Revision 1.1.1.1  2001/12/17 22:39:36  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:17:16  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:31:37  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  18:00:24  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.2  1993/01/06  18:16:16  pike
 * COMMENT : port to NT
 *
 * Revision 240.1  1993/01/05  18:17:23  pike
 * COMMENT : port to NT
 *
 * Revision 240.0  1992/12/07  00:05:18  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:41:28  root
 * COMMENT : Corresponds to Rel201.3 in 2.0.1 RCS
 *
 * Revision 201.3  1992/07/13  20:43:28  tim
 * COMMENT : added Log variable
 *
*/

#include <stdio.h>

#include <tools.h>
#if defined( ENV5 )
#elif defined( NT )
#  include <windows.h>
#endif

#include "FI.h"
#include "FIdyn.h"
#include "ex1.h"
#include "ex1gvar.h"
#include "ex1gvare.h"
#include "UMS.h"

char GRMsgFile[80];

#if defined( NT )

int WINAPI WinMain( HINSTANCE hInst,
                    HINSTANCE hPrevInst,
                    LPSTR lpCmdLn,
                    int nShowCmd )

#else

main ()

#endif
{
  int sts;

#if defined( ENV5 )
  long event;
#elif defined( NT )
  MSG event;
#elif defined( X11 )
#endif

#if defined( ENV5 )
  int window, uncollapsed, area;
  int button, tran, time, xpos, ypos;
  int xlo, ylo, xhi, yhi;
  int count, dummy, option, vs;
  int event_mask = { (DELETE_EVENT  |
                      COLLAPSE_EVENT |
                      REFRESH_EVENT |
                      BUTTON_EVENT |
                      KEYBOARD_EVENT  |
                      TIMER_EVENT |
		      USER_EVENT |
                      WINDOW_USER_ICON_EVENT ) };
#endif

  strcpy(GRMsgFile,product_path("GRNUC"));
#if defined( NT )
  strcat(GRMsgFile,"\\config\\english\\messages\\grmsg.msg");
#else
  strcat(GRMsgFile,"/config/english/messages/grmsg.msg");
#endif
  sts=UMSInitMsg(GRMsgFile,UMS_INDEX|UMS_MESSAGE);
  if (sts !=  UMS_S_SUCCESS)
   {
    puts("Message sub-system not initialized");
   }

#if defined( ENV5 )
/*
 *  Eviron V function which initializes the environ v
 *  libarary and activates the process.
 */
  Enter_tools ();

/*
 *  Environ V function which sets the logo field.
 */
  Set_logo ( "gde" );

/*
 *  Environ V function  returning the number of virtual
 *  screens displayed.
 */   
  Inq_displayed_vs (&vs);

/*
 *  Environ V function which loads the vlt.  This vlt has been initialized
 *  in the global variable section (file ex2gvar.h.)
 */
  Loadvlt (vs, vlt, sizeof (vlt) / sizeof (struct vlt_slot));

/*
 *  Environ V function which sets the keyboard buffer.  All keyboard
 *  input will be placed in this buffer.
 */
  Set_keyboard_buffer ( key_buf, sizeof (key_buf) );

/*
 *  Environ V function which enables the reporting of selected events
 *  dependant on the event mask.  This event mask was initialized as
 *  a local variable above.  The following events will be enabled:
 *  delete_event, collapse_event, refresh_event, button_event,
 *  keyboard_event, window_user_icon_event.  If we were creating our
 *  own windows, these events would concern us here, otherwise, we just
 *  pass them on the the forms and menus system and let it take care
 *  of things.
 */
  Enable_events (event_mask);
#endif

#if defined( ENV5 )
  FI_enter ( );
#elif defined( NT )
  FI_enter ( hInst );
#elif defined( X11 )
#endif

/*
 *  Create our form, modify some gadgets, create the group gadgets and
 *  place the desired gadgets in the groups.
 */
  main_form();

/*
 *  Get in a loop that gets and passes events.  We will
 *  exit when notification_routine sets exit_flag to TRUE
 *  in response to the accept or cancel button.
 */
  while (! exit_flag)
  {

#if defined( ENV5 )
/*
 *  Wait for and get the next event.
 */    	
    Wait_for_next ( event_mask, &event );
#elif defined( NT )
    if ( ! GetMessage( &event, NULL, 0, 0 ) ) {
      exit_flag = 1;
      continue;
    }
    TranslateMessage( &event );
#elif defined( X11 )
#endif

/*
 *  Give the forms system a chance to claim the event.
 *  Since we do not care about events unless they are claimed by
 *  forms or menus, there is really no processing going on here
 *  in response to events.
 */
#if defined( ENV5 )
    if ( ! FI_process_event ( event ) )
#elif defined( NT )
    if ( ! FI_process_event ( &event ) )
#elif defined( X11 )
#endif
    {
		
#if defined( ENV5 )
      if ( event & DELETE_EVENT)
      {
        Get_delete_data ( &window );
/*
 *  If I cared about a delete event, the code would go here.
 */
      }
      else if ( event & REFRESH_EVENT)
      {
        Get_refresh_area_data( &window,&vs,&xlo,&ylo,&xhi,&yhi,
                               &dummy,&dummy,&dummy,&dummy, &option );			
/*
 *  If I cared about a refresh event, the code would go here.
 */
      }	
      else if ( event & KEYBOARD_EVENT )
      {
        Get_keyboard_data (&count);
        key_buf[count] = NULL;
/*
 *  If I cared about a keyboard event, the code would go here.
 */
      }		
      else if ( event & COLLAPSE_EVENT)
      {
        Get_collapse_data( &window, &uncollapsed);			
/*
 *  If I cared about a collapse event, the code would go here.
 */
      }		
      else if (event & BUTTON_EVENT)
      {
        Get_button_data ( &area, &xpos, &ypos, &button, &tran, &time );
        Inq_win_region ( area, &xlo, &ylo, &xhi, &yhi );
/*
 *  If I cared about a button event, the code would go here.
 */
      }		    
#endif
    }
  }

#if defined( ENV5 )
/*
 *  Environ V function which cleans up the structure used by the Environ
 *  V library.
 */
  Exit_tools();
#endif

}

#if defined( NT )

/*
 *  Stub until UMS is online
 */

int UMSInitMsg( char *msg_path, int index )
{ return 1; }

int UMSGetByNum( char *msgbuf, int msgnum, char *fmt )
{
  sprintf( msgbuf, "%d", msgnum );
  return 1;
}
#endif
