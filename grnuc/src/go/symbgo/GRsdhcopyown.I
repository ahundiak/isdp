/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        GRcopy_owner

Description
        This method is responsible for coping the symbol definition 
        header to the specified space.  This method will add the sdh 
        to the symbol index object.

Synopsis
        IGRlong *msg                    return code 
        struct GRmd_env *mod_env        the module environment
        struct GRmd_env *target_env     the target environment
        GRobjid *owner_id               the new owner

Return Value
        MSSUCC  -- successful completion
        MSFAIL  -- failure

History
        HGW     06/23/86    Design Date and Creation Date
        HGW     08/14/86    Changed terminology
        HGW     09/29/86    Convert to 4.0
        HGW     11/02/87    Changes for version 1.1
        mrm     01/16/89    make copy here rather than calling GRowner so
                            that the symbol definition is not added to
                            the active owner
*/

class implementation GRsmdfhdr;

#include "grimport.h"
#include "msdef.h"
#include "grsymdef.h"
#include "grsymmacros.h"
#include "gocmacros.h"

method GRcopy_owner (IGRlong *msg;
                     struct GRmd_env *mod_env;
                     struct GRmd_env *target_env;
                     GRobjid *owner_id)
{
    IGRshort props, act = -1;
    IGRlong  sts;

    *msg = MSSUCC;
    *owner_id = NULL_OBJID;

    /*
     *  make a copy of the object in the target object space
     */

    sts = om$construct_and_copy (object = me,
                                 obj_osnum = OM_Gw_current_OS,
                                 osnum = target_env->md_id.osnum,
                                 p_objid = owner_id);
    if (sts & 1)
    {
        /*
         *  change the properties of the element -
         *  set the new bit and clear the modified and component bits
         */

        props = me->properties & (~GR_RIGID_RELATIONSHIP)
                & (~GRIS_MODIFIED) & (~GRNOT_IN_RTREE) | GRIS_NEW;

        sts = om$send (msg = message GRgraphics.GRchgprops (msg, &act, &props),
                       targetid = *owner_id,
                       targetos = target_env->md_id.osnum);

        if (sts & *msg * 1)
        {
            /*
             *  add the symbol definition header to symbol index object
             */     

            sts = gr$symsd_add (msg = msg,
                                sl_osnum = target_env->md_id.osnum,
                                sd_name = me->symbol_name,
                                sd_objid = *owner_id);
        }
    }
    if (!(sts & *msg & 1))
    {
        *msg = MSFAIL;
    }
#ifdef DEBUG
    printf ("GRsmdfhdr.GRcopy_owner: (%d, %d) -> (%d, %d)\n", OM_Gw_current_OS, my_id, target_env->md_id.osnum, *owner_id);
    printf ("GRsmdfhdr.GRcopy_owner: %#x, %#x\n", sts, *msg);
#endif
    GR_NOTIFY_LISTENERS(msg, &sts, GR_COPIED);
    return (sts);
}
end implementation GRsmdfhdr;
