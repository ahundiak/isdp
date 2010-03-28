/* #######################    APOGEE COMPILED   ######################## */


/*
Abstract
	This function supports an interface that is replaced by the 
	lc$locate macro.  Since too there is too much code that calls
	this function directly it may not be removed easily.  This function
	call LClocate (the function called from the macro lc$locate) with
	the proper parameters to perform a locate depending on the bore
	flag in the dpb.

History
	7/20/87	Started documentation
  scw  07/10/92 Ansi conversion
*/

#include "grimport.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "exdef.h"
#include "ex.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "grdpbmacros.h"
#include "griomacros.h"
#include "msdef.h"


#argsused
GRlclocate (rc, event1, event2, eventmask1, eventmask2, eventsize, 
        display_flag, response, response_data, locate_prompt, 
        acc_prompt, relocate_prompt, attributes, stack,
        dyn, act_handler, act_args, event3, temp_arg5)

       IGRlong     *rc;           /* return code                         */ 
struct GRevent     *event1;       /* return from GRgetevent              */
struct GRevent     *event2;       /* return from GRgetevent              */
struct GRevent     *event3;       /* return from GRgetevent              */
       IGRlong     *eventmask1;   /* mask to GRgetevent                  */
       IGRlong     *eventmask2;   /* mask to GRgetevent                  */
       IGRint      *eventsize;    /* size                                */
       IGRlong     *display_flag; /* 1-display all windows 0-display     */
                                  /* in one window                       */
       IGRint      *response;     /* response from GRgetevent            */
       IGRchar     *response_data;/*response data from GRgetevent        */
       IGRchar     *locate_prompt;/* locate prompt                       */
       IGRchar     *acc_prompt;   /* accept/reject prompt                */
       IGRchar     *relocate_prompt; /* when an object is not located    */
struct GRlc_locate *attributes;   /* contains class & level info         */
struct GRlc_stack  *stack;        /* pointer to "stack"                  */
struct GRlc_dynamics  
                   *dyn;          /* pointer to structure containing    */
                                  /* dynamics info                      */
       IGRint      (*act_handler)();
       IGRchar     *act_args;
       IGRchar     *temp_arg5;

{
    IGRint type = LC_DPB_LOCATE;

    if (!(LClocate (rc, event1, event2, event3, *eventmask1, 
                    *eventmask2, eventsize, *display_flag, response, 
                    response_data, locate_prompt, acc_prompt, 
                    relocate_prompt, attributes, stack, dyn, type, 
                    act_handler, act_args, NULL, NULL)))
    {
        return (0);
    }
    return(1);
}
