class implementation GRaxhatch;

#include "bserr.h"
#include "bsparameters.h"
#include "emssfintdef.h" /* For EMSINT_TRIM... */
#include "GRaxhatch.h"
#include "exmacros.h"

extern OMuword OPP_GRpolygon_class_id, OPP_GRcompcurve_class_id,
               OPP_GRorthpoly_class_id, OPP_GRcircle_class_id,
               OPP_GRellipse_class_id, OPP_GRbspline_class_id;


method EMconstruct_associative(IGRlong *EMmsg;
                               IGRushort const_options;
                               OM_S_OBJID old_objid;
                               IGRint nb_root;
                               IGRchar *parent_info;
                               IGRint type;
                               IGRchar *recomp_info;
                               struct GRvg_construct *construct_list)

/* *******************************************************************

Description

 This method creates the crosshatch elements based on the parent object.

Arguments
 Input
  nb_root : Number of roots.
  type : Type to interpret the recomputation information.
  old_objid : Objid of the object which has gotten a recompute message.
  const_options : Currently can be set to NULL.
  parent_info : Information about parents.
  env : Module environment of the master file.
  construct_list : construction information
  info : Recomputation information. This better not be NULL.

 Output
  EMmsg : Completion message.

Notes
 Upon exit the completion code will be one of the following:
  EMS_S_Success : If all goes well.
  EMS_E_Fail : If there is failure

History
 11/01/91 : WBC  : Creation
*********************************************************************** */

{
    extern IGRlong       GRauto_nester();

    IGRlong status,
            temp_msg;
    IGRint  index;
    unsigned int root_count;
    struct    GRid  elem_to_xhatch,
                    gg_grid,
                   *boundaries;
    struct GRlc_info *ret_objects;
    union EMSparent_info *roots;
    IGRuint *root_type;

    status = temp_msg = OM_S_SUCCESS;
    *EMmsg = EMS_S_Success;
    ret_objects = NULL;
    root_count = nb_root;

    root_type = (IGRuint *) alloca(sizeof(IGRint) * root_count);
    EMerr_hndlr(!root_type, *EMmsg, EMS_E_NoStackMemory, wrapup);
/*
    status = om$send (msg = message EMSassoc.EMget_parent_type(EMmsg, type,
                                                               root_count,
                                                               root_type),
                      targetid = my_id);
    EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);
*/
    for (index = 0; index < root_count; index++)
        root_type[index] = EMSlcinfo;

    roots = (union EMSparent_info *)alloca(root_count*
                                              sizeof(union EMSparent_info));
    EMerr_hndlr(!roots, *EMmsg, EMS_E_NoStackMemory, wrapup);

    status = om$send(msg = message EMSassoc.EMget_parent_info(EMmsg, NULL,
                                                              root_count,
                                                              parent_info,
                                                              root_type,
                                                              roots),
                     targetid = my_id);
    EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

    if (type == GR_axhatch_elem)
    {
        /* if the is initial creation of the crosshatch elements, must first
         * set module id in the module environment structure (which was set
         * to NULL_OBJID in EMget_parent_info) so that the crosshatch elements
         * will be put into the R-tree, otherwise the NDupdate method will
         * send an GRaddwrng to me
         */

        if (old_objid == NULL_OBJID)
        {
            ex$get_modid(mod_osnum = roots[0].lc_info.module_info.md_id.osnum,
                         mod_id = &roots[0].lc_info.module_info.md_id.objid);
        }

        gg_grid.objid = NULL_OBJID;
        gg_grid.osnum = roots[0].lc_info.module_info.md_id.osnum;

        /* the root object is the object to be crosshatched */

        elem_to_xhatch = roots[0].lc_info.located_obj;

        if (root_count > 1)
        {
            boundaries = NULL;
            boundaries = (struct GRid *) alloca((root_count - 1) *
                                                sizeof(struct GRid));

            if (! boundaries)
            EMerr_hndlr(! boundaries, *EMmsg, EMS_E_Fail, wrapup);

            for (index = 1; index < root_count; index++)
            {
                boundaries[index - 1] = roots[index].lc_info.located_obj;
            }
        }

        status = om$send(msg = message GRaxhatch.GRxhcompute(&temp_msg,
                                               &elem_to_xhatch,
                                               &roots[0].lc_info.module_info,
                                               root_count - 1,
                                               boundaries,
                                               (struct GRaxhatch_info *) recomp_info,
                                               &gg_grid),
                         targetid = my_id,
                         targetos = OM_Gw_current_OS);
        EMerr_hndlr(! (1 & status & temp_msg), *EMmsg, EMS_E_Fail, wrapup);
    }

wrapup:

    if (ret_objects)
        om$dealloc(ptr = ret_objects);

    return(status);

}
end implementation GRaxhatch;
