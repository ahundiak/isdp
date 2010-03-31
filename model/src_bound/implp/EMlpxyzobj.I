/* #################   APOGEE  COMPILED   ######################### */
/*
  DESCRITPION

    This method is intended as the sole place from which a model-space
    counterpart for this loop is generated. Various options are available
    to drive this method (EMSopt.h).

  ARGUMENTS

    xyzinfo, xyzcv,	- Input: Information about the model-space curve
    xyzcvtype, xyzsymb,    if one needs to be generated. If any of these
    xyzattr		   are NULL, this method tries to obtain the info
			   from the connected surface.  Xyzinfo can only
                           be NULL if EMSlcopt_existingmsc is specified
                           in the options.

    options		- Input: This options mask specifies certain
			   characterisitics of operations. These masks
			   are defined in the include file - EMSlcdef.h
                           Recognized options are: EMSlcopt_existingmsc,
			   EMSlcopt_noassoc and EMSlcopt_debug.

    xyzos		- Input: The object space in which this loop's
			   model-space counterpart needs to be searched for
			   or generated in.

    xyzobj		- Output: The model-space conterpart, if one was
			   found. Else, a NULL_OBJID is returned.

  RETURN VALUE

    If the MSC object is being returned
     - EMS_S_Success
    If an existing MSC in the same object space as the loop is being returned
     - EMS_I_FoundOther
    If the no MSC object was found
     - EMS_I_NotFound
    If some error occurred
     - EMS_E_Fail, EMS_E_EdgeError, EMS_E_CurveError, etc.

  HISTORY

    SS  :  Long ago  :  Creation
    SS  :  05/23/89  :  Modified such that xyzcv, cvtype, xyzsymb and xyzattr
                        arguments can be set to NULL.
    SS  :  08/08/89  :  If the MSCEXISTS bit is set but no counterpart
                        can be obtained, the bit is set off and depending
                        on the option a new model-space counterpart may or
                        may not be generated.
    WBC :  03/28/91  :  Reworked to create associative model-space counterparts.
    WBC :  01/05/94  :  Since the loop's creator can now be non-associative,
                        had to change the code to find a loop's MSC via the
                        loop's creator (can't count on the creator having an
                        NDchildren.children channel).
*/

class implementation EMSloop;

#include <stdio.h>
#include "OMmacros.h"
#include "EMSlcdef.h"
#include "EMSobjmgrdef.h"
#include "exmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "REcurve.h"
#include "asbox.h"
#include "asmacros.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_GAcompcurve_class_id,
                 OPP_NDnodein_class_id,
                 OPP_GRcompcurve_class_id;

from EMSassoc import EMinit_associative;
from GAcurve import GAget_msc_component;


method EMgetxyzobj (IGRlong *msg; IGRushort options;
                    struct GRmdenv_info *xyzinfo;
                    struct IGRbsp_curve *xyzcv; IGRuchar *cvtype;
                    struct GRsymbology *xyzsymb; struct IGResbc *xyzattr;
                    GRspacenum xyzos; GRobjid *xyzobj)
{
    extern IGRlong        EFcreate_composite_curve_from_loop();
    extern IGRlong        EFget_creator_id();
    IGRboolean            aflag=0;
    IGRlong               stat_OM,
                          sizebuffer,
                          nbytes_ret,
                          constmsg;
    IGRint                i;
    OMuint                count;
    struct GRvg_construct const_list;
    struct GRmd_env       locmdenv;
    struct EMSobject_info object_info;
    struct GRid           src_parent;
    OM_S_CHANSELECT       child_chansel;
    GRobjid               loop_id;
    GRspacenum            mscos,
                          loop_os;

    *msg = EMS_S_Success;
    stat_OM = OM_S_SUCCESS;
    *xyzobj = NULL_OBJID;

    /*
     * If the model-space counterpart exists for this loop, fetch it.
     * If for some reason, the MSC cannot be located, take a corrective action
     * of turning this bit off, and proceed as if this loop did not have the
     * bit on in the first place.
     */

    if ((ME.EMSloop->lp_props & EMLP_MSCEXISTS) &&
        (! (options & EMSlcopt_noassoc)))
    {
        /* find my creator and send a message to its children to see if
         * it has an associative model-space counterpart for me
         */

        stat_OM = EFget_creator_id(msg, my_id, OM_Gw_current_OS,
                                   &object_info.grid.objid, NULL);
        EMerr_hndlr(!(1 & stat_OM & *msg), *msg, EMS_E_Fail, ret_end);

        /* The creator may be NULL_OBJID if the boundary element is part
         * of an application object. (i.e VDS and struct related stuff).
         * Theoretically EMED_MSCEXISTS bit should not be set if this is
         * true.
         */

        if (object_info.grid.objid == NULL_OBJID)
            goto ret_end;

        if (!(EFisAncestryValid(msg, object_info.grid.objid,
                                OM_Gw_current_OS, OPP_NDnodein_class_id,
                                FALSE))) 
        {
            object_info.grid.osnum = OM_Gw_current_OS;

            stat_OM = as$make_source(go_grid = object_info.grid,
                                     as_grid = &src_parent);
            if (!(1&stat_OM)) goto ret_end;
            object_info.grid = src_parent;
        }

        stat_OM = om$make_chanselect(channame = "NDchildren.children",
                                     p_chanselect = &child_chansel);
        EMomerr_exit(stat_OM, ret_end);

        /* find the number of the creator's children objects */

        stat_OM = om$get_channel_count(osnum = OM_Gw_current_OS,
                                       objid = object_info.grid.objid,
                                       p_chanselect = &child_chansel,
                                       count = &count);
        EMerr_hndlr(!(1 & stat_OM), *msg, EMS_E_Fail, ret_end);

        if (count)
        {
            for (i = 0; i < count; i++)
            {
                stat_OM = om$send(msg = message GAcurve.GAget_msc_component(
                                                   msg, &loop_id, &loop_os),
                                  senderid = object_info.grid.objid,
                                  p_chanselect = &child_chansel,
                                  from = i,
                                  to = i);

                if ((stat_OM == OM_S_SUCCESS) && (1 & *msg) &&
                    (loop_id == my_id))
                {
                    stat_OM = om$get_objid_at_index(objid = object_info.grid.objid,
                                                    p_chanselect = &child_chansel,
                                                    index = i,
                                                    objidaddr = xyzobj,
                                                    osnumaddr = &mscos);
                    EMerr_hndlr(!(1 & stat_OM), *msg, EMS_E_Fail, ret_end);
                    break;
                }
            }
            stat_OM = OM_S_SUCCESS;
        }
    }

    if (*xyzobj == NULL_OBJID)
    {
        if (! (options & EMSlcopt_noassoc))
        {
            ME.EMSloop->lp_props &= ~EMLP_MSCEXISTS;

            if (options & EMSlcopt_debug)
                fprintf(stderr, "MSCEXISTS prop turned off for loop - %d\n",
                        my_id);
        }

        /*
         * This loop's MSC has not yet been found. If options allows for
         * generation of a new model-space counterpart, generate the
         * model-space curve id and return it.
         */

        if (options & EMSlcopt_existingmsc)
        {
            /*
             * Options indicated that only an existing model-space counterpart
             * needed to be processed. Since none exists, return an appropriate
             * code.
             */

            *msg = EMS_I_NotFound;
        }
        else
        {
            object_info.env.md_id.osnum = OM_Gw_current_OS;
            stat_OM = ex$get_modid(mod_osnum = OM_Gw_current_OS,
                                   mod_id = &object_info.env.md_id.objid);
            EMomerr_exit (stat_OM, ret_end);
            object_info.env.md_env = *xyzinfo;

            if(aflag = pwIsActivationOn())
            {
              pwGetActiveModuleEnv(&locmdenv);
            }
            else
            {
              /* getting the module environment info for the construction
               * environment; by calling gr$get_module_env it is being assumed
               * that we are constructing in the "active" object space;
               * this would have to be changed if we have user writeable
               * reference files
               */

              sizebuffer = sizeof(locmdenv);
              gr$get_module_env(msg = &constmsg,
                                sizbuf = &sizebuffer,
                                buffer = &locmdenv,
                                nret = &nbytes_ret);
            }

            locmdenv.md_id.objid = NULL_OBJID;  /* don't put in R-tree */
            locmdenv.md_id.osnum = xyzos;

            /* Initialize the construction list */

            const_list.msg = &constmsg;
            const_list.env_info = &locmdenv;
            const_list.newflag = FALSE;
            const_list.level = NULL;
            const_list.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
            const_list.geometry = NULL;
            const_list.display = NULL;
            const_list.class_attr = NULL;
            const_list.name = NULL;

            /* construct either an associative or non-associative model-space
             * counterpart depending on the options
             */

            if (options & EMSlcopt_noassoc)
            {
                stat_OM = om$construct(classid = OPP_GRcompcurve_class_id,
                                       p_objid = xyzobj,
                                       osnum = xyzos,
                                       msg = message GRgraphics.GRconstruct
                                                               (&const_list));
                EMerr_hndlr(!(1 & stat_OM & constmsg), *msg, EMS_E_Fail, ret_end);

                stat_OM = EFcreate_composite_curve_from_loop(&constmsg, options,
                                             xyzos, *xyzobj, OM_Gw_current_OS,
                                             my_id, &ME.EMSloop->lp_props,
                                             &object_info.env, NULL);
                EMomerr_exit(stat_OM, ret_end);
                EMerr_hndlr(EMSerror (constmsg), *msg, EMS_E_Fail, ret_end);
            }
            else  /* create an associative model-space counterpart */
            {
                /* find the "creator" object of this model-space counterpart */

                object_info.grid.objid = NULL_OBJID;

                stat_OM = EFget_creator_id(msg, my_id, OM_Gw_current_OS,
                                           &object_info.grid.objid, NULL);
                EMerr_hndlr(!(1 & stat_OM & *msg), *msg, EMS_E_Fail, ret_end);

                /* The creator may be NULL_OBJID if the boundary element is
                 * part of an application object. (i.e VDS and struct related
                 * stuff). In such a case it is proper to not create mscs.
                 */

                if (object_info.grid.objid == NULL_OBJID)
                   goto ret_end;

                /* determine if the creator is an associative object; if it is
                 * not, send it a message to make it associative
                 */

                /*
                 * Currently it is assumed that the creator is either an
                 * associative object or a non-associative surface. By 
                 * associative we mean it needs to be a subclass of
                 * NDnodein.
                 * pp 11/14/91
                 * Commented out the call below to EMtransform_to_associative
                 * because an om$change_class is done in that method, which
                 * can cause crashes in some instances (TR#119310858).
                 * WBC 01/05/94
                 */
/*
                if (!(EFisAncestryValid(msg, object_info.grid.objid,
                                       OM_Gw_current_OS, OPP_NDnodein_class_id,
                                       FALSE))) 
                {
                    stat_OM = om$send(msg = message EMSsurface.EMtransform_to_associative
                                         (msg, &object_info.grid.objid),
                                      targetid = object_info.grid.objid);
                    EMerr_hndlr(!(1 & stat_OM & *msg), *msg, EMS_E_Fail, ret_end);
                }
*/
                object_info.grid.osnum = OM_Gw_current_OS;

                stat_OM = om$construct(classid = OPP_GAcompcurve_class_id,
                                       p_objid = xyzobj,
                                       osnum = xyzos,
                                       msg = message EMSassoc.EMinit_associative
                                                   (msg, NULL, 1, &object_info,
                                                    EMSmsc_id, sizeof(GRobjid),
                                                    (IGRchar *) &my_id,
                                                    &const_list));
                EMerr_hndlr(!(1 & stat_OM & constmsg), *msg, EMS_E_Fail, ret_end);

                /* update the edge's properties to indicate it has a
                 * model-space counterpart
                 */

                ME.EMSloop->lp_props |= EMLP_MSCEXISTS;
            }
        }
    }
 
ret_end:

    EMWRAPUP (*msg, stat_OM, "EMSloop.EMgetxyzobj");
    return (stat_OM);
}

end implementation EMSloop;
