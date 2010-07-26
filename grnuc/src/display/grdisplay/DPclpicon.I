/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
	CLASS NAME:	IGEgragad
	METHOD NAME:	clpicon
 
     	Abstract: This method toggles the active bit setting in window
		  instance data and send update message to window if
                  uncollapsed. If the window collapsed, toggle the
                  active bit.
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
      *flag        IGRint           flag = 0 uncollapsed
					 = 1 collapsed
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg           IGRlong	 MSSUCC -- successful completion

-----
%RL%

	RELATIONS REFERENCED:

-----
%NB%

     NOTES:
-----
%CH%
     CHANGE HISTORY:

	HT 04/29/86  : Creation date.
        scw 06/23/92 : Added static ANSI C prototypes
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

     	 This method toggles the active bit setting in window
         instance data and send update message to window if
         uncollapsed. If the window collapsed, toggle the
         active bit.
----*/
/*EH*/


class implementation IGEgragad;

#include "grimport.h"
#include "wl.h"
#include "exproto.h"

#if defined( X11 )

static Bool  my_check_fun(
   Display *display,
   XEvent *event,
   int *win )

{
    XExposeEvent *xevent;
    xevent = (XExposeEvent *)event;
     
    if( (xevent->type == Expose) && (xevent->window == *win) )
    {
       return(1);
    }
    else
    {
       return(0);
    }
}

#endif

method clpicon (IGRlong *msg; IGRint *flag)

{

#if defined( X11 )
XEvent  myevent;
unsigned int win;
struct WLnative_info native_info;
WLuint32 context_no;
#endif

IGRlong status ;
IGRboolean upd_flag = FALSE;
status = OM_S_SUCCESS;
*msg = MSSUCC;

#if defined( X11 )
if (*flag == 2 )  /* uncollapse just set IS_ACTIVE bit, expose event will follow*/
{
   ME.IGEgragad->gragad.flags |= IS_ACTIVE;
}
else 
#endif
  if (*flag == 0 )  /* uncollapse need update */
  {
    if (!(ME.IGEgragad->gragad.flags & IS_ACTIVE ))
    {
       ME.IGEgragad->gragad.flags |= IS_ACTIVE;
   }
   
#if defined( X11 )
   WLget_window_base_context( ME.IGEgadget->win_no, &context_no );
   WLget_native_info( ME.IGEgadget->win_no, context_no, &native_info );

   win = native_info.base_win;
   while( JNL_XCheckIfEvent( native_info.display, &myevent, my_check_fun, (char *)(&win) ) );
#endif
   
   status = om$send(mode = OM_e_wrt_object,
                    msg = message IGEgragad.DPupdate(msg,NULL,&upd_flag),
                    senderid = my_id,
                    targetid = my_id);

   if ( !(1 & status) )
   {
#ifdef DEBUG
       om$report_error(sts = status);
       printf("Error: collapse icon send to wn update\n");
#endif
   }
}
else  /* collapse */
{
   if (ME.IGEgragad->gragad.flags & IS_ACTIVE)
   {
	  /*  set is active bit to 0  */
	
       ME.IGEgragad->gragad.flags &= ~IS_ACTIVE;
   }

}
return (status);

}
end implementation IGEgragad;
