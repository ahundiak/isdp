/* #######################    APOGEE COMPILED   ######################## */
class implementation Root;
/*
Name
        LCevent

Decription
        This function provides functionality to eliminate one user input
        in the following case.  A command invokes a locate.  At the locate
        input the user invokes an event generator that performs a locate 
        operation.  The element accepted in the event generator is to
        be accepted in the command locate.

        This function will check an event structure to see if it was 
        produced by an event generator.  It does this by checking 
        the subtype and the number of ids in the event.

        It will return 1 if event is an event generated from an event
        generator.  Otherwise a 0 is returned.  Presently it is called
        only from LClocate_processing.  If the locate message succeeds
        the return code, rc, will be LC_OBJS_IN_STACK, otherwise it will
        be LC_NO_OBJ_LOCATED. 

Algorithm
	If the event is from an event generator a GRlocate message will be
	sent to the object in the event.  Then if the action handler was
	called and the object is placed in the stack the event is put back
	onto the queue.  The reason for this is to accept the element with
	the datapoint produced by the event generator.  If the command has
        asked for auto accept, there is no need to place the event back on
        the queue, so that step is omitted when appropriate.

History
	rc      08/03/87    Creation Date.
	rc      08/25/87    Modified for locate stack of one
        mrm     06/24/89    restore pointers before returning if error occurs
                12/12/89    maintain proj_point and geom_parms, check for
                            auto accept (added display_flag argument)
                07/12/91    set ret_code = 1 when returning objects
                            in the stack
        scw     07/13/92    ansi conversion
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
#include "dpdef.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "dpmacros.h"
#include "exmacros.h"
#include "OMerrordef.h"
#include "OMindex.h"
#include "dpstruct.h"
#include "lcpriv.h"
#include "msdef.h"
#include "referr.h"

extern IGRint LCaccact(), LCevselect();

from GRgraphics import GRlocate;


#argsused
IGRint LCevent (rc, event, attributes, act_handler, act_args, mod,
                eligible_classes, stack, size, display_flag)
IGRlong *rc;
struct GRevent *event;
struct GRlc_locate *attributes;
IGRchar *act_handler;
struct LC_action_args *act_args;
struct GRmd_env *mod;
OM_p_CLASSLIST eligible_classes;
struct GRlc_stack *stack;
IGRint *size;
IGRlong display_flag;
{
    IGRchar *save_args;
    IGRint (*save_function)(), level[35], ret_code;
    IGRlong lc_status, msg, retb1, w_error;
    IGRpoint eventprojpts;
    struct var_list list_var[2];
    struct GRparms eventparms;
    struct GRlc_info *obj;
    struct GRlc_cvl cvl;
    struct LC_sd_evselect ev_args;

    ret_code = 0;
    /*
     *	Check to see if this datapoint is from an event
     *	generator and has a located object in the event.
     */

    if (event->subtype != GRst_REGULAR && event->num_id > 0)
    {
        obj = &event->located_object[0];

        /*
         *  Check to see if the object located from the event generator
         *  is from a reference file.  This function will also return the
         *  correct levels that are on in a reference file.
         *
         *  NOTE: This check may be replaced by passing the criteria of
         *  commands to event generators.  This is done for the
         *  time being as a short term patch for a problem.
         */

        GRrfloccheck (&msg, &obj->module_info, &attributes->properties, level);

        if (msg == MSFAIL)
        {
            /*
             *  This means that the reference file that has the object is
             *  read only and the operation that was requested was a write
             *  operation.  So reject the element.
             */

            *rc = LC_NO_OBJ_LOCATED;
            ret_code = 1;
            return (ret_code);
        }
        else if (msg == GRNOTREFFILE)
        {
            /*
             *  Inquire the active levels from the window so only elements
             *  that are on active layers are locateable.
             */

            list_var[0].var = LEVELS;
            list_var[0].var_ptr = (IGRchar*) level;
            list_var[0].num_bytes = sizeof(IGRint) * 35;
            list_var[0].bytes_returned = &retb1;

            list_var[1].var = END_PARAM;

       	    lc_status = dp$inq_set_gragad (msg = &msg,
  	                       osnum = stack->window.osnum,
                               gragad_objid = stack->window.objid,
    			       which_error = &w_error,
    			       var_list = list_var);
            if(!(1&lc_status))
            {
                return(0);
            }
        }

        /*
         *  Set up cvl structure for the locate method.
         */

        cvl.attributes.acc_point[0] = event->event.button.x;
    	cvl.attributes.acc_point[1] = event->event.button.y;
    	cvl.attributes.acc_point[2] = event->event.button.z;
    	cvl.button = event->event.button;
    	cvl.attributes.obj_attr = *attributes;
        cvl.attributes.obj_attr.owner_action |= 512;
    	cvl.action_handler = LCaccact;
    	cvl.attributes.acc_tolerance = 100000000;
        cvl.module = obj->module_info;
    	cvl.classes = eligible_classes;
    	cvl.act_parms = NULL;
        cvl.locate_args = act_args;

        ev_args.select_handler = act_args->select;
        ev_args.user_args = act_args->select_args;
        ev_args.button = &(event->event.button);

        /*
         *  save the projected point and geometric parameters to reinsert
         *  if the named locate succeeds
         */

        eventprojpts[0] = obj->proj_pnt[0];
        eventprojpts[1] = obj->proj_pnt[1];
        eventprojpts[2] = obj->proj_pnt[2];
        eventparms = obj->geom_parms;

        /*
         *  Save what should be in the action handler arguments.
         */

        save_function = act_args->select;
        save_args = act_args->select_args;

        act_args->select = LCevselect;
        act_args->select_args = (IGRchar*)&ev_args;

        cvl.attributes.type = GR_crit_loc;
   	cvl.levels =  level;

        /*
         *  This locate message will be a criteria locate.  It passes a special
         *  action handler that does not invoke the accept reject cycle but
         *  simply puts the element on the stack and returns.  In this manner
         *  it can be found out whether the element passed the criteria
         *  specified by the command.
         */

        lc_status = om$send (msg = message GRgraphics.GRlocate(&cvl,NULL), 
                             senderid = NULL_OBJID,
                             targetid = obj->located_obj.objid,
                             targetos = obj->located_obj.osnum);
 
        if(!(1&lc_status))
        {
            act_args->select = save_function;
            act_args->select_args = save_args;
	    return(0);
        }

        if (stack->number_located == 1)
        {
            /*
             *  Push the event on the queue to be picked up by the
             *  select handler as the accept point.  This needs to
             *  be changed because there are 2 additional display
             *  requests because of this.  Control should go back to
             *  LClocate and the filter should terminate with the 
             *  return codes that are correct for an element that
             *  has been located.
             */

            event->num_id = 0;
            stack->entry[0].proj_pnt[0] = eventprojpts[0];
            stack->entry[0].proj_pnt[1] = eventprojpts[1];
            stack->entry[0].proj_pnt[2] = eventprojpts[2];
            stack->entry[0].geom_parms = eventparms;
            *obj = stack->entry[0];

            if (!(display_flag & LC_ACC_ONE_ELEMENT))
            {
                lc_status = ex$putque(msg = &msg,
                                      response = &(event->response),
                                      byte = (IGRlong *)size,
                                      buffer = (char *)&event->event.button);
                if(!(1 & lc_status))
                {
                    act_args->select = save_function;
                    act_args->select_args = save_args;
                    return(0);
                }
            }

            ret_code = 1;
            *rc = LC_OBJS_IN_STACK;
        }
        else if (stack->number_located > 1)
        {
            if (LCevselect(act_args->rc, act_args->loc_select_args, &ev_args))
            {
                if (*(act_args->rc) == LC_UNKNOWN_TYPE)
                {
                    *act_args->rc = LC_NO_OBJ_LOCATED;
                }
                ret_code = 1;
            }
        }
        else
        {
            ret_code = 1;
        }

        /*
         *  Restore proper context
         */

        act_args->select = save_function;
        act_args->select_args = save_args;
    }
    else
    {
        ret_code = 0;
    }
    return (ret_code);
}

end implementation Root;
