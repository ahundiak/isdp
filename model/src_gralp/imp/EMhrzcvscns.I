class implementation EMShrzcvs;


/*
Name

    EMconstruct_associative

Abstract

        This is the construct method for horizon curves.  It determines the
    parting lines of the parent surface with respect to the orientation of
    the parent reference plane and constructs an associative group of vector
    graphics that represent these parting lines.

Synopsis

        Type                   Name           I/O       Description
 --------------------- ---------------------- --- --------------------------
 IGRlong               *EMmsg                  O  Return code.
 IGRushort              opts                   I  Options; not currently used
                                                  so a 0 should be passed in.
 GRobjid                old_objid              I  Objid of the object which
                                                  is being recomputed.  If
                                                  this is a construct instead
                                                  of a recompute, this should
                                                  be set to NULL_OBJID.
 IGRint                 num_parents            I  Number of parents.
 IGRchar               *p_info                 I  Information about the
                                                  parents.  This info can be
                                                  deciphered by using the
                                                  message EMget_parent_info.
 IGRint                 type                   I  Indicates the recomputation
                                                  information type.
 IGRchar               *recomp_info            I  Recomputation information.
 struct GRvg_construct *construct_list         I  Construction information to
                                                  be used when constructing
                                                  this object itself and any
                                                  objects created by this
                                                  method.

Description

        This method gets the object ids and environment info of its two
    parents, a reference plane and a surface.  The z-vector from the parent
    reference plane and the parting tolerance are obtained, which are used
    in the call to the method EMpartingLines which returns a group of
    points that represent the parting lines of the parent surface relative
    to the z-vector.  These points are then used to construct line segment
    and line string graphic elements that represent the parting lines.  These
    elements are then rigidly connected to the associative horizon curve
    object (myself) to form an associative group.

Notes

Keywords

    associative
    construct
    method
    surface
    wireframe

History

   05/26/93  :  WBC  :  Creation date.
   08/30/93  :  WBC  :  Returning EMS_I_NoSolution if no parting lines are
                        found.
   11/23/93  :  WBC  :  During a recompute, get the symbology of the parent
                        surface to be used in constructing the horizon curve
                        lines since the symbology of the parent surface may
                        have changed and the surface is in a reference file
                        so the horizon curves would not be notified.
Justification

        Class specific actions to be done during construction and recompute
    of this class.
*/

#include "OMmacros.h"
#include "emsmacros.h"
#include "EMSfrtdef.h"     /* EMGL_NO_DISPLAY              */
#include "msdef.h"
#include "gocmacros.h"
#include "EMSprop.h"       /* EMLP_ACTIVE                  */
#include "EMSopt.h"        /* nesting and profile options  */
#include "EMSbnddef.h"     /* EMSbnd.h                     */
#include "EMSbnd.h"        /* EMSpartolbasis               */
#include "bstypes.h"
#include "emsdef.h"
#include "EMdtmacros.h"
#include "EMSasnuc.h"
#include "DEsomacros.h"
#include "alloca.h"
#include "EMShrzcvs.h"

extern OMuword  OPP_GR3dlinestr_class_id;
extern OMuword  OPP_GR3dlineseg_class_id;

from EMSdatpln      import  EMget_pln_info;
from EMSsubbs       import  EMpartolbasis,
                            EMpartingLines;


method EMconstruct_associative(IGRlong               *EMmsg; 
                               IGRushort              opts;
                               GRobjid                old_objid;
                               IGRint                 num_parents;
                               IGRchar               *p_info;
                               IGRint                 type;
                               IGRchar               *recomp_info;
                               struct GRvg_construct *construct_list)
{
    IGRlong                  OM_stat,
                             rc,
                             connect_index;
    struct GRid              my_GRid,
                             old_comp,    /* old component */
                             new_comp;    /* new component */
    struct GRvg_construct    const_list;
    struct IGRpolyline       polyline;
    struct BSpartgrp        *grp;
    struct EMSpartolbasis    partolbasis;
    struct GRsymbology       surf_symb;
    union EMSparent_info    *roots = NULL;
    IGRdouble                z_vector[3];
    IGRint                   local_numgrps = 0,
                             j;
    IGRuint                 *root_type = NULL;
    OMuint                   count;
    struct BSpartgrp        *local_partgrps = NULL;
    OM_S_CHANSELECT          to_components,
                             notify_chansel;
    OMuword                  partline_classid;
    IGRshort                 properties;
    unsigned short           trim = NULL;
    IGRboolean               move_soos,          /* move symbology overrides */
                             world = TRUE;

    *EMmsg = EMS_S_Success;

    root_type = (unsigned int *) alloca(sizeof(IGRint) * num_parents);

    if (! root_type)
    {
        *EMmsg = EMS_E_NoStackMemory;
        goto wrapup;
    }

    OM_stat = om$send(msg = message EMSassoc.EMget_parent_type(EMmsg,
                                                               type,
                                                               num_parents,
                                                               root_type),
                      targetid = my_id);

    if (! (1 & OM_stat & *EMmsg))
    {
        *EMmsg = EMS_E_Fail;
        goto wrapup;
    }

    roots = (union EMSparent_info *) alloca(num_parents *
                                              sizeof(union EMSparent_info));

    if (! roots)
    {
        *EMmsg = EMS_E_NoStackMemory;
        goto wrapup;
    }

    OM_stat = om$send(msg = message EMSassoc.EMget_parent_info(EMmsg, NULL,
                                                               num_parents,
                                                               p_info,
                                                               root_type,
                                                               roots),
                      targetid = my_id);

    if (! (1 & OM_stat & *EMmsg))
    {
        *EMmsg = EMS_E_Fail;
        goto wrapup;
    }

    /* get the z_vector from the reference plane parent */

    OM_stat = om$send(msg = message EMSdatpln.EMget_pln_info(EMmsg, NULL,
                         &roots[EMS_HRZCVS_REF_PLN_INDEX].lc_info.module_info,
                         NULL, NULL, z_vector, NULL, NULL),
                      senderid = my_id,
                      targetos = roots[EMS_HRZCVS_REF_PLN_INDEX].lc_info.located_obj.osnum,
                      targetid = roots[EMS_HRZCVS_REF_PLN_INDEX].lc_info.located_obj.objid );

    if(! (1 & OM_stat & *EMmsg))
        goto wrapup;

    /* find the parting lines for the surface parent relative to the
     * orientation of the reference plane parent
     */

    local_numgrps = 0;
    trim = EMStrimWorldData;

    /* Get the surface parametric tolerance. */

    OM_stat = om$send(msg = message EMSsubbs.EMpartolbasis(
                         EMmsg,
                         &roots[EMS_HRZCVS_SURF_INDEX].lc_info.module_info.md_env.matrix_type,
                         roots[EMS_HRZCVS_SURF_INDEX].lc_info.module_info.md_env.matrix,
                         &world, FALSE, &partolbasis.tol),
                      targetid = roots[EMS_HRZCVS_SURF_INDEX].lc_info.located_obj.objid,
                      targetos = roots[EMS_HRZCVS_SURF_INDEX].lc_info.located_obj.osnum);

    if(! (1 & OM_stat & *EMmsg)) goto wrapup;

    partolbasis.is_valid = TRUE;
    partolbasis.mattyp = &roots[EMS_HRZCVS_SURF_INDEX].lc_info.module_info.md_env.matrix_type;
    partolbasis.mat = roots[EMS_HRZCVS_SURF_INDEX].lc_info.module_info.md_env.matrix;

    /* Calculate the parting lines */

    local_numgrps = 0;
    local_partgrps = NULL;

    OM_stat = om$send(msg = message EMSsubbs.EMpartingLines(
                                 EMmsg,
                                 &roots[EMS_HRZCVS_SURF_INDEX].lc_info.module_info,
                                 z_vector,
                                 trim,
                                 &partolbasis, 
                                 &local_numgrps, 
                                 &local_partgrps),
                      targetid = roots[EMS_HRZCVS_SURF_INDEX].lc_info.located_obj.objid,
                      targetos = roots[EMS_HRZCVS_SURF_INDEX].lc_info.located_obj.osnum);
    if(! (1 & OM_stat & *EMmsg)) goto wrapup;

    if (local_numgrps > 0) /* there are results */
    {
        /* notify display list of horizon curve creation */
        DPdlist_horizon_curve_notify( roots[EMS_HRZCVS_SURF_INDEX].lc_info.located_obj.objid,
                                      roots[EMS_HRZCVS_SURF_INDEX].lc_info.located_obj.osnum );

        /* Construct either a line segment or line string for each parting
         * line group.
         */

        const_list.msg = &rc;
        const_list.env_info = construct_list->env_info;
        const_list.level = construct_list->level;
        const_list.newflag = FALSE;
        const_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE | GRNOT_IN_RTREE;
        const_list.geometry = (IGRchar *) &polyline;
        const_list.display = construct_list->display;
        const_list.class_attr = NULL;
        const_list.name = NULL;
        my_GRid.objid = my_id;
        my_GRid.osnum = OM_Gw_current_OS;
        connect_index = OM_K_MAXINT;
        move_soos = FALSE;

        if (old_objid != NULL_OBJID)
        {
            /* This is a recompute; find how many components the old object
             * has and if it's the same number as this new object will have,
             * move any symbology overrides from the old components to the
             * corresponding new components.  If the number of components is
             * not the same, don't bother moving the symbology overrides since
             * we don't know how to match the old symbology overrides to the
             * new components.  These "unmatched" symbology overrides will be
             * automatically deleted when the old components are deleted.
             */

            EMmake_chanselect(GRcmpowner_to_components, &to_components);

            OM_stat = om$get_channel_count(objid = old_objid,
                                           p_chanselect = &to_components,
                                           count = &count);

            if (! (1 & OM_stat)) goto wrapup;

            if (count == local_numgrps)
            {
                move_soos = TRUE;
                new_comp.osnum = construct_list->env_info->md_id.osnum;
            }

            /* get the symbology of the parent surface; the horizon curve
             * lines should be created with this symbology
             */

            OM_stat = om$send(msg = message GRvg.GRgetsymb(EMmsg, &surf_symb),
                              targetid = roots[EMS_HRZCVS_SURF_INDEX].lc_info.located_obj.objid,
                              targetos = roots[EMS_HRZCVS_SURF_INDEX].lc_info.located_obj.osnum);
            if(! (1 & OM_stat & *EMmsg)) goto wrapup;

            const_list.level = surf_symb.level;
            const_list.display = &surf_symb.display_attr;
        }
        else
        {
            /* This is not a recompute; connect myself to my surface parent
             * to enable messages to be sent more quickly from the surface
             * to myself - this is strictly an efficiency enhancement.
             */

            IGRint      connect_index;
            GRspacenum  tagged_osnum;
            IGRboolean  tagged_connect;

            EMmake_chanselect(GRnotify_notification, &notify_chansel);
            connect_index = 0;
            tagged_connect = TRUE;
            tagged_osnum = roots[EMS_HRZCVS_SURF_INDEX].lc_info.located_obj.osnum;

            OM_stat = om$send(msg = message GRnotify.GRntfyconn(&rc,
                                                          &my_GRid,
                                                          &notify_chansel,
                                                          &connect_index,
                                                          &tagged_connect,
                                                          &tagged_osnum),
                              targetid = roots[EMS_HRZCVS_SURF_INDEX].lc_info.located_obj.objid,
                              targetos = roots[EMS_HRZCVS_SURF_INDEX].lc_info.located_obj.osnum);
            if(! (1 & OM_stat & rc)) goto wrapup;
        }

        for (j=0, grp=local_partgrps; j<local_numgrps; grp=grp->next, j++)
        {
            GRobjid               partline_id;

            if(grp->num > 0) /* this will weed out point curves */
            {
               /* create a line segment if there are two points,
                * else create a line string; if we ever decide we want to
                * create other types of objects (e.g. circles, arcs), we
                * would need to first check with whoever is responsible for
                * the command Process Detail Display since they assume we
                * are only returning line segments and line strings
                */

               polyline.num_points = grp->num;
               polyline.points = (IGRdouble *)grp->pts;

               partline_classid = (polyline.num_points == 2) ?
                                   OPP_GR3dlineseg_class_id :
                                   OPP_GR3dlinestr_class_id;

               OM_stat = om$construct(classid = partline_classid,
                                      osnum = construct_list->env_info->md_id.osnum,
                                      p_objid = &partline_id,
                                      msg = message GRgraphics.GRaltconstruct
                                                         (&const_list));
               if(! (1 & OM_stat)) goto wrapup;

               /* connect the parting line (horizon curve) to myself as a
                * rigid component
                */

               OM_stat = om$send(msg = message GRconnector.GRrigidconn(
                                                       EMmsg, &my_GRid,
                                                       &connect_index),
                                 targetid = partline_id,
                                 targetos = construct_list->env_info->md_id.osnum);
                if(! (1 & OM_stat)) goto wrapup;
            } /* end if grp->num > 0 */

            /* if this is a recompute and the number of components is
             * the same for the new and old elements and if this new
             * component's corresponding old component has a symbology
             * override, move the symbology override from the old
             * component to the new one
             */

            if (move_soos)
            {
                OM_stat = om$get_objid_at_index(objid = old_objid,
                                           p_chanselect = &to_components,
                                           index = j,
                                           objidaddr = &old_comp.objid,
                                           osnumaddr = &old_comp.osnum);
                if(! (1 & OM_stat)) goto wrapup;

                OM_stat = om$send(msg = message GRgraphics.GRgetprops(
                                                            &rc,
                                                            &properties),
                                 targetid = old_comp.objid,
                                 targetos = old_comp.osnum);
                if(! (1 & OM_stat & rc)) goto wrapup;

                if (properties & DEHAS_OVERRIDE)
                {
                    new_comp.objid = partline_id;

                    de$objid_changed(msg = &rc,
                                     old = &old_comp,
                                     new = &new_comp);
                }
            }
        } /* for */
    } /* if there are results */
    else 
    {
        /* if the surface is an ancestor of EMSplane, then it will
         * never get horizon edges so delete myself.  I set local_numgrps
         * to -1 in EMpartingLines if this was the case.
         */

        *EMmsg = EMS_I_NoSolution;

        OM_stat = om$send(msg = message Root.delete(1),
                          targetid = my_id,
                          targetos = OM_Gw_current_OS);
        if(! (1 & OM_stat)) goto wrapup;
    }

wrapup:

    /* Free the memory for the parting line data. */

    if (local_partgrps)
    {
        int                i;
        struct BSpartgrp  *grp;

        for (i = 0, grp = local_partgrps; i < local_numgrps; i++)
        {
            if (grp->pts)
            {
                om$dealloc(ptr = grp->pts);
                grp->pts = NULL; 
            }

            if (grp->par)
            {
                om$dealloc(ptr = grp->par);
                grp->par = NULL;
            }
            grp = grp->next;
        }

        /* deallocate this memory outside of the loop since it was
         * allocated as one chunk.
         */  

        om$dealloc(ptr = local_partgrps);
    }

    EMWRAPUP (*EMmsg, OM_stat, "EMShrzcvs.EMconstruct_associative");
    return (OM_stat);
}

end implementation EMShrzcvs;
