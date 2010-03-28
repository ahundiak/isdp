class implementation Root;

#include "coimport.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "lcdef.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "lc.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grgs.h"
#include "grgsdef.h"
#include "godef.h"
#include "lcmacros.h"
#include "grerr.h"
#include "dpmacros.h"
#include "grownerdef.h"

from  GRvg     import   GRgetsymb;
from  GRgraphics import GRgetprops;
from  GRowner import GRget_owner_properties;

/*\
Name
   GRgs_delete_orphan_cells_action

Description
   This is an action handler which performs the steps neccessary to
   add an orphan cell object to a graphics set.  This action handler will also
   do a symbology criteria check.  It assumes the new_entry object is a cell.

   *action_args   struct GRsymb_action_args  The structure defining the
                                             symbology
   *new_entry     struct GRlc_info           Entry to be added to the
                                             graphics set.
   *locate_args   IGRchar                    Locate arguments.
   *action        enum GRlocate_action       Locate action

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
     WBC     10/02/91    Creation date.
\*/

extern OMuword OPP_GRclhdr_class_id;

#argsused
IGRint GRgs_delete_orphan_cells_action(action_args, new_entry,
                                       locate_args, action)

struct GRdelete_action     *action_args;
struct GRlc_info           *new_entry;
IGRchar                    *locate_args;
enum GRlocate_action       *action;
{
    IGRlong              om_msg;
    IGRlong              ret_msg;
    OMuword              go_classid;
    IGRshort             properties;
    struct GRsymbology   symb;

    om_msg = OM_S_SUCCESS;

    /*
     *  If the element fails to meet the properties then it should be
     *  added to the located elements.   This is so that the proper 
     *  elements may be deleted by the file fence command.
     *  Need to first check to see if this is an orphan cell.
     */

    om_msg = om$get_classid (objid = new_entry->located_obj.objid,
                             osnum = new_entry->located_obj.osnum,
                             p_classid = &go_classid);

    if (! (1 & om_msg))
        goto wrapup;

    om_msg = om$is_ancestry_valid(subclassid = go_classid,
                                  superclassid = OPP_GRclhdr_class_id);

    if (! (om_msg & 1) || (om_msg == OM_I_INVANCESTRY))
        goto wrapup;

    om_msg = om$send (msg = message GRowner.GRget_owner_properties(&ret_msg,
                                                             &properties),
                      senderid = NULL_OBJID,
                      targetid = new_entry->located_obj.objid,
                      targetos = new_entry->located_obj.osnum);

    if ((om_msg & 1) &&
        (properties & GR_ORPHAN))
    {
        /*
         *  The criteria that will be checked is window layers, global layers,
         *  locateable, displayable, and classchecks. 
         */

        om_msg = om$send (msg = message GRvg.GRgetsymb (&ret_msg, &symb),
                          senderid = NULL_OBJID,
                          targetid = new_entry->located_obj.objid,
                          targetos = new_entry->located_obj.osnum);

        if (om_msg & 1)
        {
            /*
             *  If the element has a layer and is does not pass the layers
             *  passed in call the action handler to have it deleted.
             */

            if (ret_msg != GR_I_NO_LAYER)
            {
                if (!DPlevel_check (symb.level, action_args->layers))
                {
                    om_msg = GRgsaction ( new_entry, action, &action_args->gs_id, 
                                          &action_args->sv_id, NULL, TRUE);
                    goto wrapup;
                }
            }
        }
        om_msg = om$send (msg = message GRgraphics.GRgetprops 
                                (&ret_msg, &properties),
                          senderid = NULL_OBJID,
                          targetid = new_entry->located_obj.objid,
                          targetos = new_entry->located_obj.osnum);

        if (om_msg & 1 && ret_msg == MSSUCC)
        {
            /*
             *  If the element is not displayable or locateable call the action
             *  handler to have the element deleted.
             */

            if (!(properties & GRIS_LOCATABLE) ||
                !(properties & GRIS_DISPLAYABLE))
            {
                om_msg = GRgsaction ( new_entry, action, &action_args->gs_id, 
                                      &action_args->sv_id, NULL, TRUE);
                goto wrapup;
            }
        }
    }

wrapup:

    return (om_msg);
}  


end implementation Root;
