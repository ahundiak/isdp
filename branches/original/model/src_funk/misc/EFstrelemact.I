/*
Name
        EFstore_elem_act

Description
        This routine adds the input element to the array of located elements
        if the input element is either not a rigid component or is rigidly
        owned by a cell.  It allocates space as needed for the elements using
        om$malloc and om$realloc.  When more memory is needed, several
        entries are allocated  to reduce the number of allocations.

        This is intended to be called from the graphic object during the
        locate cycle.  The action handler will return OM_S_SUCCESS
        to continue the locate  operation.

History
        WBC     09/27/91    Create date.
        WBC     10/14/93    Added checks to only accept the input element
                            if it is either not rigidly owned or is rigidly
                            owned by a cell.
        WBC     12/27/93    If the action is check_object, check for a "match"
                            by comparing the module environment as well as
                            the object id and osnum. (TR#119307149)
*/

class implementation EMSsurface;

#include "grimport.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMindex.h"
#include "OMmacros.h"
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

#define INCR_SIZE  5

extern GRclassid OPP_GRclhdr_class_id;
extern GRclassid OPP_ACconst_class_id;


IGRint EFstore_elem_act(args, new_entry, locate_args, action)

IGRchar *args;
struct GRlc_info *new_entry;
struct LC_action_args *locate_args;
enum GRlocate_action *action;
{
    IGRlong         msg;
    IGRint          ret_code, index1, valid_element, index2;
    OM_S_CHANSELECT owner_chan;
    GRobjid         owner_objid;
    GRclassid       owner_classid;
    GRspacenum      owner_osnum;
    IGRshort        props;
    struct EFloc_elems
    {
        IGRint            num_elems;          /* number of located elements */
        IGRint            num_avail_entries;  /* number of entries currently
                                                 allocated for lc_info */
        struct GRlc_info  *lc_info;           /* memory for this will be
                                                 allocated in the action
                                                 handler */
    }     *action_args;

    ret_code = OM_S_SUCCESS;
    action_args = (struct EFloc_elems *) args;

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

        case post_object:

            /*
             *  This case is called when an object is to be posted as
             *  already located.
             */

            ret_code = OM_S_SUCCESS;
            break;

        case check_object:

            /*
             *  This case allows objects to check to see if it has already
             *  been located -- helpful in solids and owners.
             */

            ret_code = LC_ID_NOT_FOUND;

            for (index1 = 0; (index1 < action_args->num_elems) &&
                             (ret_code == LC_ID_NOT_FOUND); index1++)
            {
                if ((action_args->lc_info[index1].located_obj.objid ==
                     new_entry->located_obj.objid)                       &&
                    (action_args->lc_info[index1].located_obj.osnum ==
                     new_entry->located_obj.osnum)                       &&
                    (action_args->lc_info[index1].module_info.md_id.osnum ==
                     new_entry->module_info.md_id.osnum)                 &&
                    (action_args->lc_info[index1].module_info.md_id.objid ==
                     new_entry->module_info.md_id.objid)                 &&
                    (action_args->lc_info[index1].module_info.md_env.matrix_type ==
                     new_entry->module_info.md_env.matrix_type))
                {
                    if (new_entry->module_info.md_env.matrix_type == MAIDMX)
                        ret_code = OM_S_SUCCESS;
                    else
                    {
                        for (index2 = 0; index2 < 16; index2++)
                        {
                            if (action_args->lc_info[index1].module_info.md_env.matrix[index2] !=
                                new_entry->module_info.md_env.matrix[index2])
                                break;
                        }

                        if (index2 == 16)
                            ret_code = OM_S_SUCCESS;
                    }
                }
            }

            break;

        default:

            valid_element = FALSE;

            /* determine if the input element should be added to the list of
             * of located objects - if it is either not rigidly owned or it
             * is rigidly owned by a cell
             */

            ret_code = om$send(msg = message GRgraphics.GRgetprops(&msg,
                                                                   &props),
                               senderid = NULL_OBJID,
                               targetid = new_entry->located_obj.objid,
                               targetos = new_entry->located_obj.osnum);

            if (1 & ret_code & msg)
            {
                if (props & GR_RIGID_RELATIONSHIP)
                {
                    /* get the object's owner and determine if it's a cell */

                    ret_code = EMmake_chanselect(GRconnector_to_owners,
                                                 &owner_chan);
                    if (! (1 & ret_code))
                    {
                        ret_code = OM_E_ABORT;
                        goto WRAP;
                    }

                    ret_code = om$get_objid_at_index(osnum = new_entry->located_obj.osnum,
                                                     objid = new_entry->located_obj.objid,
                                                     p_chanselect = &owner_chan,
                                                     index = 0,
                                                     objidaddr = &owner_objid,
                                                     osnumaddr = &owner_osnum);
                    if (! (1 & ret_code))
                    {
                        ret_code = OM_E_ABORT;
                        goto WRAP;
                    }

                    ret_code = om$get_classid(osnum = owner_osnum,
                                              objid = owner_objid,
                                              p_classid = &owner_classid);
                    if (! (1 & ret_code))
                    {
                        ret_code = OM_E_ABORT;
                        goto WRAP;
                    }

                    if (owner_classid == OPP_GRclhdr_class_id)
                        valid_element = TRUE;
 		    if (owner_classid == OPP_ACconst_class_id )
                        valid_element = TRUE;
                }
                else
                    valid_element = TRUE;
            }
            else
                goto WRAP;

            if (valid_element)
            {
                /* add the object to the list of located objects; first
                 * determine if additional memory needs to be allocated
                 */

                if (action_args->num_elems >= action_args->num_avail_entries)
                {
                    action_args->num_avail_entries += INCR_SIZE;

                    if (action_args->num_elems)
                    {
                        action_args->lc_info = (struct GRlc_info *) 
			    om$realloc(ptr = (IGRchar *)action_args->lc_info, 
				       size = sizeof(struct GRlc_info) * 
				       action_args->num_avail_entries);
                    }
                    else
                    {
                        action_args->lc_info = (struct GRlc_info *) om$malloc(size = sizeof(struct GRlc_info) *
                                                                              action_args->num_avail_entries);
                    }

                    if (! action_args->lc_info)
                    {
                        ret_code = OM_E_ABORT;
                        goto WRAP;
                    }
                }

                OM_BLOCK_MOVE(new_entry, 
                              &(action_args->lc_info[action_args->num_elems]),
                              sizeof(struct GRlc_info));
                (action_args->num_elems)++;
                break;
            }
    }

WRAP:
    return (ret_code);
}

end implementation EMSsurface;
