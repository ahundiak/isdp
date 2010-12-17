
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"

/*  Global NFI structure  */

extern struct NFFglobal_st NFFglobal;

#ifndef XWINDOWS
long _NFF_process_environv_forms ()
  {
    auto    int  event = NULL;
    auto    int  w;
    auto    int  x;
    auto    int  y;
    auto    int  button;
    auto    int  trans = 0;
    auto    int  timetag;

    static  char *fname = "_NFF_process_environv_forms";

    while( FI_forms_active () )
    {
        JNL_wait_for_next ( FI_EVENT_MASK, &event);
/*        Wait_for_next( FI_EVENT_MASK, &event ); */
        if( event & BUTTON_EVENT )
        {
   	    _NFFinq_button_data (&w, &x, &y, &button, &trans, &timetag);
        }

        if( !FI_process_event (event) )
	    FI_clear_event( event ); 
    }

    return (NFI_S_SUCCESS);
  }

#else
long _NFF_process_x_forms ()
  {
    auto    int  trans = 0;
    XEvent  event;

    static  char *fname = "_NFF_process_x_forms";

    while( FI_forms_active () )
    {
        XNextEvent( NFFglobal.display, &event );
	_NFIdebug ((fname, "event_type = %d\n", event.type));
        if(( event.type == ButtonRelease) || ( event.type == ButtonPress ))
	{
	    FI_get_transition( &event, &trans );
	    NFFglobal.button_transition = trans;
	}

	/*	ConfigureNotify event if allowed to be processed by 
		FI_process_event is resulting in odd behaviour..
		To be looked in detail -- MVR 1 Mar 94 			*/

	if (event.type != ConfigureNotify)
        	FI_process_event (&event, trans);
    }
    return (NFI_S_SUCCESS);
  }

#endif
