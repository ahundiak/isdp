#include "machine.h"
#include "WFF.h"

/*  Global NFI structure  */

extern struct WFFglobal_st WFFglobal;

#ifndef XWINDOWS
long _WFF_process_environv_forms ()
  {
    auto    int  event = NULL;
    auto    int  w;
    auto    int  x;
    auto    int  y;
    auto    int  button;
    auto    int  trans = 0;
    auto    int  timetag;

    static  char *fname = "_WFF_process_environv_forms";

    _NFIdebug(( fname, "Entering ...\n" ));

    while( FI_forms_active () )
    {
        Wait_for_next( FI_EVENT_MASK, &event );
        if( event & BUTTON_EVENT )
	{
   	    Inq_button_data (&w, &x, &y, &button, &trans, &timetag);
            WFFglobal.button_transition = trans;
	}
        _NFIdebug(( fname, "Call FI_process_event(%d)\n", event )); 
        if( !FI_process_event (event))
	    FI_clear_event(event);
    }

    return (NFI_S_SUCCESS);
  }

#else
long _WFF_process_x_forms ()
  {
    auto    int  trans = 0;
    XEvent  event;

    static  char *fname = "_WFF_process_x_forms";

    _NFIdebug(( fname, "Entering ...\n" ));

    while( FI_forms_active () )
    {
        XNextEvent( WFFglobal.display, &event );
        if(( event.type == ButtonRelease) || ( event.type == ButtonPress ))
	{
	    FI_get_transition( &event, &trans );
	    WFFglobal.button_transition = trans;
	}
        FI_process_event (&event, trans);
    }

    return (NFI_S_SUCCESS);
  }

#endif
