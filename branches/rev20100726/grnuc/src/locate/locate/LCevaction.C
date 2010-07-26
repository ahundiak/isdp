/* #######################    APOGEE COMPILED   ######################## */


/*

Abstract
	This function is the action handler provided by the locate facility
	when a GRlocate message is sent to the graphics object.  This is
	only invoked when event generators are invoked at the locate point.

	Note that this action handler does not call the accept/reject
	handler.

History
	8/21/87	Creation Date
  scw  07/13/92 Ansi conversion

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
LCevaction(info, new_entry, locate_args, action, env_flag)
IGRchar               *info;
struct LC_action_args *locate_args;
struct GRlc_info      *new_entry;
enum   GRlocate_action *action;
IGRint                *env_flag;

{
    int ret_code = 1; 
    int temp_msg;

    switch (*action) {

        case end_transition:
        case start_transition:
            ret_code = OM_S_SUCCESS;
        break;

	/*
	 *	This case is called when an object is to be posted as
	 *	allready located.
	 */

        case post_object:
            lc$post_id (rc=&temp_msg, objid = new_entry->located_obj.objid,
                         osnum = new_entry->located_obj.osnum);
            ret_code = OM_S_SUCCESS;
            break;
        case check_object:
            lc$check_id (rc=&temp_msg, objid = new_entry->located_obj.objid,
                         osnum = new_entry->located_obj.osnum,
                         mode = LC_CHECK);

            if (temp_msg == LC_ID_FOUND) {
                ret_code = OM_S_SUCCESS;
            }
            else {
                lc$post_id (rc=&temp_msg, objid = new_entry->located_obj.objid,
                         osnum = new_entry->located_obj.osnum,
                         mode = LC_CHECK);

                if (temp_msg == LC_ID_FOUND) {
                    ret_code = OM_S_SUCCESS;
                }
                else {
                    ret_code = LC_ID_NOT_FOUND;
                }
            }
            break;
        /*
         *  Otherwise add the object to the stack
         */
        default:
            locate_args->stack->entry[locate_args->stack->num_entries] = *new_entry;
            locate_args->stack->num_entries++;
            ret_code = 1;
        break;
    }
    return (ret_code);
}

