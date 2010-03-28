/* #######################    APOGEE COMPILED   ######################## */

/*
Name
        LCaccact

Description
        This routine allows the automatic acceptance of one element.  This
        will work even if the locate stack is one, which is the default case.
        The reason for this is the the accept and reject cycle is called
        before the stack is filled in.  That way the accept and reject cycle
        is called only when there are two or more elements.

        This is intended to be called from the graphic object during the
        locate cycle.  The action handler will return OM_S_SUCCESS or
        OM_I_STOP_SENDING.  OM_S_SUCCESS means to continue the locate
        operation, while OM_I_STOP_SENDING means to stop the search through
        the Rtree.

History
        rc      07/20/87    Started documentation
                08/25/87    Added locate stack of one.
        mrm     12/11/89    housecleaning
        scw     07/10/92    ansi conversion
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
IGRint LCaccact (args, new_entry, locate_args, action)
IGRchar *args;
struct GRlc_info *new_entry;
struct LC_action_args *locate_args;
enum GRlocate_action *action;
{
    IGRint  max_entries;
    IGRint  ret_code = 1;
    IGRlong temp_msg;
    struct GRlc_stack *stack;

    /*
     *  Determine action requested
     */
    
    switch (*action)
    {
        case end_transition:
        case start_transition:

            /*
             *  These 2 cases are sent when a reference space is
             *  entered during an rtree scan
             */

            ret_code = OM_S_SUCCESS;
            goto WRAP;
            /* break; */

        case post_object:

            /*
             *  This case is called when an object is to be posted as
             *  already located.
             */
/*
            lc$post_id (rc = &temp_msg,
                        objid = new_entry->located_obj.objid,
                        osnum = new_entry->located_obj.osnum);
*/
            ret_code = OM_S_SUCCESS;
            goto WRAP;
            /* break; */

        case check_object:

            /*
             *  This case allows objects to check to see if it has already
             *  been located -- helpful in solids and owners.
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
     *  Add the object to the stack 
     */

    stack = locate_args->stack;

    /*
     *  If a named locate is not being done, place it on the stack
     *  if it has not already been in the locate list.
     */

    if (locate_args->type != GR_nam_loc)
    {
        /*
         *  Check the locate list.  If it is found then do not process
         *  the id again.  Return from the action handler with OM_S_SUCCESS.
         */

        if (lc$check_id (rc = &temp_msg,
                         objid = new_entry->located_obj.objid,
                         osnum = new_entry->located_obj.osnum))
        {
            if (temp_msg == LC_ID_FOUND)
            {
                ret_code =  OM_S_SUCCESS;
                goto WRAP;
            }
            else
            {
                lc$post_id (rc = &temp_msg,
                            objid = new_entry->located_obj.objid,
                            osnum = new_entry->located_obj.osnum,
                            mode = LC_CHECK);

                if (temp_msg == LC_ID_FOUND)
                {
                    ret_code =  OM_S_SUCCESS;
                    goto WRAP;
                }
            }
        }
        else
        {
            *locate_args->rc = LC_NO_OBJ_LOCATED;
            ret_code = OM_I_STOP_SENDING;
            goto WRAP;
        }

        /*
         *  Check the maximum number of entries in the stack
         */

        if (locate_args->max_entries <= MAX_LCSTACK_LEN)
        {
            max_entries = locate_args->max_entries;
        }
        else
        {
            max_entries = MAX_LCSTACK_LEN;
        }

        /*
         *  Call accept/reject handler if necessary.
         *  Note that this is done before the entry is placed int the stack
         */

        if (stack->num_entries >= locate_args->max_entries)
        {
            /*
             *  Call the accept/reject handler
             */

            ret_code = (*locate_args->select) (locate_args->rc, 
                                               locate_args->loc_select_args,
                                               locate_args->select_args);
            if (ret_code)
            {
                ret_code = OM_S_SUCCESS;

                if (*locate_args->rc == LC_UNKNOWN_TYPE)
                {
                    /*
                     *  This indicates that during the accept/reject cycle an
                     *  input was given that could not be handled.  EX. 
                     *  command_string So stop the locate cycle and return to
                     *  the command saying that no element was located. 
                     */

                    ret_code = OM_I_STOP_SENDING;
                    *locate_args->rc = LC_NO_OBJ_LOCATED;
                }

                if (*locate_args->rc == LC_OBJ_LOCATED ||
                    *locate_args->rc == LC_BACKUP)
                {
                    /*
                     *  This indicates that the accept/reject cycle
                     *  accepted an element so terminate the search in
                     *  the Rtree and tell the command that an element
                     *  was located.  This case is also taken if a backup
                     *  event is given in the accept/reject cycle. 
                     */

                    ret_code = OM_I_STOP_SENDING;
                }
            }
            else
            {
                ret_code = OM_I_STOP_SENDING;
            }
        }
        else
        {
            ret_code = OM_S_SUCCESS;
            *locate_args->rc = LC_OBJS_IN_STACK;

            /*
             *  An object has been located and will be auto-accepted. 
             *  Since the select handler was not called, the criteria
             *  state flag needs to be advanced here.  This is necessary
             *  so that the criteria list will not get confused about
             *  what state and what command is active.  This confusion
             *  could happen if a command with limiting criteria was
             *  stacked at its accept prompt for an event generator with
             *  multiple locates.             
             */

            LCmark_locate (LC_Other_Point);
        }

        if (ret_code != OM_I_STOP_SENDING)
        {
            /*
             *  Insert the element into the stack.  Increment the
             *  number_located field so that in LClocate it can be
             *  checked to determine if only one element went through the
             *  action handler. 
             */

            if (!stack->num_entries)
            {
                ret_code = OM_S_SUCCESS;
                *locate_args->rc = LC_OBJS_IN_STACK;
                locate_args->stack->number_located++;
                stack->entry[0] = *new_entry;
                stack->num_entries++;
            }
            else
            {
                ret_code = OM_S_SUCCESS;
                *locate_args->rc = LC_OBJS_IN_STACK;
                locate_args->stack->number_located++;
                locate_args->located++;
                stack->entry[stack->num_entries++] = *new_entry;
            }
        }
    }
    else /* named locate */
    {
        /*
         *  Since all the criteria for the graphics object has been
         *  checked including levels, properties, and layers insert into
         *  the stack and return
         */

        locate_args->located = 1;
        locate_args->stack->number_located++;
        if (locate_args->is_regex)
        {
            /*
             *  If there is a regular expression create a set of objects
             */

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
