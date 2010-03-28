/* #######################    APOGEE COMPILED   ######################## */

/*
Name
        LCptlocact

Decription
	This routine is called as a default action handler from the
	graphics object to place it on the locate stack.

History
	rc  07/20/87    Started documentation
	    08/25/87    Added locate stack of one.
       scw  07/13/92    ANSI conversion
*/

#include "grimport.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMindex.h"
#include "OMDB.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "dp.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "dpstruct.h"
#include "lcpriv.h"
#include "lcmacros.h"


#argsused
int LCptlocact (args, new_entry, locate_args, action)
struct GRlc_info      *new_entry;
struct LC_action_args *locate_args;
enum GRlocate_action  *action;
IGRchar               *args;
{
    IGRint ret_code = 1;
    IGRlong temp_msg;
    struct GRlc_stack *stack;

    
    switch (*action)
    {
        case end_transition:
        case start_transition:

            /*
             *	These 2 cases are sent when a reference space is
	     *	entered during an rtree scan
             */

            ret_code = OM_S_SUCCESS;
            goto WRAP;
            /* break; */

        case post_object:

    	    /*
	     *	This case is called when an object is to be posted as
	     *	already located.
	     */

            lc$post_id (rc = &temp_msg,
                        objid = new_entry->located_obj.objid,
                        osnum = new_entry->located_obj.osnum);
            ret_code = OM_S_SUCCESS;
            goto WRAP;
            /* break; */

        case check_object:

	    /*
	     *	This case allows objects to check to see if it has already
	     *	been located -- helpful in solids and owners.
	     */

            lc$check_id (rc = &temp_msg,
                         objid = new_entry->located_obj.objid,
                         osnum = new_entry->located_obj.osnum,
                         mode = LC_CHECK);

            if (temp_msg == LC_ID_FOUND)
            {
                ret_code = OM_S_SUCCESS;
            }
            else
            {
                lc$post_id (rc = &temp_msg,
                            objid = new_entry->located_obj.objid,
                            osnum = new_entry->located_obj.osnum,
                            mode = LC_CHECK);

                if (temp_msg == LC_ID_FOUND)
                {
                    ret_code = OM_S_SUCCESS;
                }
                else
                {
                    ret_code = LC_ID_NOT_FOUND;
                }
            }
            goto WRAP;
            /* break; */
    }


    /*
     *	Add the object to the stack 
     */

    stack = locate_args->stack;

    /*
     *	If it is not a named locate operation, check the object ids because
     *	there may be multiple occurrences.
     */

    if (locate_args->type != GR_nam_loc)
    {
        if (*action != add_nopost)
        {
            /*
             *	Check the list of objects that have been through this locate
             *	cycle.
             */

            if (lc$check_id (rc = &temp_msg, 
                             objid = new_entry->located_obj.objid,
                             osnum = new_entry->located_obj.osnum))
            {
                if (temp_msg == LC_ID_FOUND)
                {
                     return (OM_S_SUCCESS);
                }
            }
            else
            {
                *locate_args->rc = LC_NO_OBJ_LOCATED;
                return (OM_I_STOP_SENDING);
            }
        }

        /*
         *  if the stack is empty
         */

        if (!stack->num_entries)
        {
            stack->entry[0] = *new_entry;
            stack->num_entries++;
        }
        else
        {
            stack->entry[stack->num_entries++] = *new_entry;
        }    

        /*
         *  call accept/reject handler if necessary 
         */
 
        if (stack->num_entries >= locate_args->max_entries)
        {
            if (locate_args->loc_select_args->display_flag & NO_ACC_REJ_CYCLE)
            {
                /* stop the rtree pass; the stack is full */

                ret_code = OM_I_STOP_SENDING;
                *locate_args->rc = LC_OBJS_IN_STACK;
            }
            else
            {
                ret_code = (*locate_args->select)(locate_args->rc, 
                                                  locate_args->loc_select_args,
                                                  locate_args->select_args);
                if (ret_code)
                {
                    ret_code = OM_S_SUCCESS;

                    /*
                     *  Set the return code so that the Rtree will terminate
                     *  its search.  This case occurs when an unknown event
                     *  is returned from the accept/reject cycle. 
                     */

                    if (*locate_args->rc == LC_UNKNOWN_TYPE)
                    {
                        ret_code = OM_I_STOP_SENDING;
                        *locate_args->rc = LC_NO_OBJ_LOCATED;
                    }

                    /*
                     *  If an object is accepted there is no need
                     *  to search further.
                     */

                    if (*locate_args->rc == LC_OBJ_LOCATED ||
                        *locate_args->rc == LC_BACKUP)
                    {
                        ret_code = OM_I_STOP_SENDING;
                    }
                }
                else
                {
                    ret_code = OM_I_STOP_SENDING;
                }
            }
        }
        else
        {
            /*
             *  If the stack is not full continue the Rtree search.  In this
             *  case the accept/reject handler was not called.
             */

            ret_code = OM_S_SUCCESS;
            *locate_args->rc = LC_OBJS_IN_STACK;
        }
    }
    else /* named locate */
    {
        /*
         *  Since all the criteria for the graphics object has been checked
         *  including levels, properties, and layers and owner action....
         *  insert into the stack and return
         */

        locate_args->located = 1;
        locate_args->stack->number_located++;

        /*
         *  Handle the regular expression by adding the element to a 
         *  graphics set.  Otherwise add it to the stack.
         */

        if (locate_args->is_regex)
        {
            LCadd_sav (locate_args->gs_id, locate_args->sv_id, new_entry);
        }
        else if (!locate_args->stack->num_entries)
        {
            new_entry->geom_parms.u = 0;
            locate_args->stack->entry[0] = *new_entry;
            locate_args->stack->number_located = 
            locate_args->stack->num_entries = 1;
        }
    }

WRAP:
    return (ret_code);
}
