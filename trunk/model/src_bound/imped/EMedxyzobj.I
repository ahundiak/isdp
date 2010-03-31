/* #################   APOGEE  COMPILED   ######################### */
/*
  DESCRITPION

    This method is intended as the sole place from which a model-space
    counterpart for this edge is generated. Various options are available
    to drive this method (EMSopt.h).

  ARGUMENTS

    xyzinfo, xyzcv,	- Input: Information about the model-space curve
    xyzcvtype, xyzsymb,    if one needs to be generated. If any of these
    xyzattr		   are NULL, this method tries to obtain the info
			   from the connected surface.  Xyzinfo can only
                           be NULL if option EMSlcopt_existingmsc is set.

    options		- Input: This options mask specifies certain
			   characterisitics of operations. These masks
			   are defined in the include file - EMSlcdef.h
                           Recognized options are: EMSlcopt_nodgnedge,
			   EMSlcopt_existingmsc, EMSlcopt_touchmsc,
			   EMSlcopt_noassoc, EMSlcopt_nocommon.
                           NOTE: (03/29/91) EMSlcopt_touchmsc and
                                 EMSlcopt_nocommon ignored.
    xyzos		- Input: The object space in which this edge's
			   model-space counterpart needs to be searched for
			   or generated in.

    xyzobj		- Output: The model-space conterpart, if one was
			   found. Else, a NULL_OBJID is returned.

  RETURN VALUE

    If the MSC object is being returned
     - EMS_S_Success
    If an existing MSC in the same object space as the edge is being returned
     - EMS_I_FoundOther
    If sufficient stack memory was not available
     - EMS_E_NoStackMemory
    If some error occurred
     - EMS_E_Fail

  HISTORY

    SS  :  Long ago  :  Creation
    SS  :  05/23/89  :  Modified such that xyzcv, cvtype, xyzsymb and xyzattr
                        arguments can be set to NULL.
    SS  :  08/08/89  :  If the MSCEXISTS bit is set but no counterpart
                        can be obtained, the bit is set off and depending
                        on the option a new model-space counterpart may or
                        may not be generated.
    SA  :  05/11/90  :  Set stat_OM to OM_S_SUCCESS after EMSobjmgr.EMtouchobj
			message send.
    WBC :  03/25/91  :  Changed to create associative model-space counterparts.
    WBC :  03/25/93  :  If the edge is a freeform curve and its curve order
                        is 2 and it has 2 poles, create its model space
                        counterpart as a line segment.
    WBC :  12/03/93  :  If EMtransform_to_associative fails, let the method
                        proceed instead of erroring out since EMint_associative
                        will create a source object to serve as the parent
                        object (TR#119313978).
*/

class implementation EMSedge;

#include "OMmacros.h"
#include "EMSlcdef.h"
#include "EMSobjmgrdef.h"
#include "EMcp.h"
#include "exmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "emsdef.h"
#include "nddef.h"
#include "REcurve.h"
#include "emsedgedef.h"
#include "asbox.h"
#include "asmacros.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_EMSsubbs_class_id, OPP_NDnodein_class_id;

from GRvg import GRgetsymb;
from EMSassoc import EMinit_associative;
from NDnode import NDget_objects;
from GAcurve import GAget_msc_component;
from EMSsurface import EMis_associative;
from EMSsurface import EMtransform_to_associative;
from GAcurve import GAreturn_yourself;


method EMgetxyzobj (IGRlong *msg; IGRushort options;
                    struct GRmdenv_info *xyzinfo;
                    struct IGRbsp_curve *xyzcv; IGRuchar *xyzcvtype;
                    struct GRsymbology *xyzsymb; struct IGResbc *xyzattr;
                    GRspacenum xyzos; GRobjid *xyzobj)
{
    extern IGRlong EFget_assoc_classid_for_an_edge_type();
    extern IGRlong EFget_creator_id();
    IGRboolean aflag=0;
    IGRlong stat_OM,
            status,
            temp_msg,
            sizebuffer,
            nbytes_ret;
    IGRlong l_msg;
    IGRint i;
    OMuint count;
    OM_S_CHANSELECT child_chansel;
    OM_S_CHANSELECT notify;
    GRobjid edge_id,
            creator_id;
    GRspacenum mscos,
               edge_os;
    OMuword msc_classid;
    struct GRid my_GRid, msc_GRid;
    struct EMSobject_info  object_info;
    struct GRsymbology bcsymb,
                       *edge_symb_ptr;
    struct IGResbc loc_xyzattr;
    struct GRvg_construct construct_list;
    struct GRmd_env construct_env;
    struct IGRbsp_curve loc_xyzcv;
    struct GRid src_parent;

    *msg = EMS_S_Success;
    stat_OM = OM_S_SUCCESS;
    *xyzobj = NULL_OBJID;
    loc_xyzcv.poles = NULL;
    loc_xyzcv.knots = NULL;
    loc_xyzcv.weights = NULL;
    my_GRid.objid = my_id;
    my_GRid.osnum = OM_Gw_current_OS;
    creator_id = NULL_OBJID;

    /*
     * If degenerate edge, then return the corresponding message code.
     * Also, if no degenerate edge processing needs to be done, wrapup.
     */

    if (ME.EMSedge->ed_props & EMED_DEGENERATE)
    {
      *msg = EMS_I_DegenerateEdge;
      if (options & EMSlcopt_nodgnedge)
      {
        goto wrapup;
      }
    }

      EMmake_chanselect (GRnotify_notification, &notify);

    /* determine if the edge already has an associative model-space counterpart
     */

    if ((ME.EMSedge->ed_props & EMED_MSCEXISTS) &&
        (! (options & EMSlcopt_noassoc)))
    {
        /* find my creator and send a message to its children to see if it has
         * an associative model-space counterpart for me
         */

      msc_GRid.objid = NULL_OBJID;

      om$send (msg = message GAcurve.GAreturn_yourself(&l_msg,
                             &my_GRid, &msc_GRid),
               p_chanselect = &notify);
       
      if (msc_GRid.objid == NULL_OBJID)
      {
        stat_OM = EFget_creator_id(msg, my_id, OM_Gw_current_OS,
                                   &object_info.grid.objid, NULL);
        EMerr_hndlr(!(1 & stat_OM & *msg), *msg, EMS_E_Fail, wrapup);

/*
 * The creator may be NULL_OBJID if the boundary element is part of
 * an application object. (i.e VDS and struct related stuff).
 * Theoretically EMED_MSCEXISTS bit should not be set if this is true.
 */

        if (object_info.grid.objid == NULL_OBJID)
         goto wrapup;

/* end pp */
        if (!(EFisAncestryValid(&temp_msg, object_info.grid.objid,
                         OM_Gw_current_OS, OPP_NDnodein_class_id,
                         FALSE))) 
        {
          object_info.grid.osnum = OM_Gw_current_OS;
          stat_OM = as$make_source(go_grid = object_info.grid,
                              as_grid = &src_parent);
          if (!(1&stat_OM)) goto wrapup;
          object_info.grid = src_parent;
        }

        stat_OM = om$make_chanselect(channame = "NDchildren.children",
                                     p_chanselect = &child_chansel);
        EMomerr_exit(stat_OM, wrapup);

        /* find the number of the creator's children objects */

        stat_OM = om$get_channel_count(osnum = OM_Gw_current_OS,
                                       objid = object_info.grid.objid,
                                       p_chanselect = &child_chansel,
                                       count = &count);
        EMerr_hndlr(!(1 & stat_OM), *msg, EMS_E_Fail, wrapup);

        if (count)
        {
            for (i = 0; i < count; i++)
            {
                stat_OM = om$send(msg = message GAcurve.GAget_msc_component(
                                                   msg, &edge_id,
                                                   &edge_os),
                                  senderid = object_info.grid.objid,
                                  p_chanselect = &child_chansel,
                                  from = i,
                                  to = i);

                if ((stat_OM == OM_S_SUCCESS) && (1 & *msg) &&
                    (edge_id == my_id))
                {
                    stat_OM = om$get_objid_at_index(objid = object_info.grid.objid,
                                                    p_chanselect = &child_chansel,
                                                    index = i,
                                                    objidaddr = xyzobj,
                                                    osnumaddr = &mscos);
                    EMerr_hndlr(!(1 & stat_OM), *msg, EMS_E_Fail, wrapup);
                    break;
                }
            }
            stat_OM = OM_S_SUCCESS;
        }

        if (*xyzobj != NULL_OBJID)
        {
         IGRboolean make_tagged_connect = FALSE;
         OMuword tagged_os;
         IGRlong l_msg;
         IGRint list_index;

         tagged_os = OM_Gw_current_OS;
         list_index = 0;

         om$send (msg = message GRnotify.GRntfyconn(&l_msg,
                        &my_GRid, &notify, &list_index,
                        &make_tagged_connect, &tagged_os),
                  targetid = *xyzobj,
                  targetos = mscos);
        }
       }
       else
        *xyzobj = msc_GRid.objid;
    }

    if (*xyzobj == NULL_OBJID)  /* amsc not found */
    {
        if (! (options & EMSlcopt_noassoc))
            ME.EMSedge->ed_props &= ~EMED_MSCEXISTS;

        if (options & EMSlcopt_existingmsc)
        {
            *msg = EMS_I_NotFound;  /* don't create an msc */
        }
        else
        {
            if (xyzsymb)
            {
                edge_symb_ptr = xyzsymb;
            }
            else
            {
                stat_OM = om$send(msg = message EMSboundary.EMtree_traverse
                                        (msg, message GRvg.GRgetsymb
                                                        (&temp_msg, &bcsymb),
                                         OM_K_MAXINT, 1, &OPP_EMSsubbs_class_id,
                                         EMStreetrav_up, NULL, NULL, NULL),
                                  targetid = my_id);
                EMerr_hndlr(!(1 & stat_OM & *msg & temp_msg), *msg, EMS_E_Fail,
                            wrapup);
                edge_symb_ptr = &bcsymb;
            }

            if (xyzattr)
                loc_xyzattr = *xyzattr;
            else
            {
                loc_xyzattr.is_polydis = FALSE;
                loc_xyzattr.is_curvedis = TRUE;
            }

            if(aflag = pwIsActivationOn())
            {
              pwGetActiveModuleEnv(&construct_env);
            }
            else
            {
            /* getting the module environment info for the construction
             * environment; by calling gr$get_module_env it is being assumed
             * that we are constructing in the "active" object space;
             * this would have to be changed if we have user writeable
             * reference files
             */

            sizebuffer = sizeof(construct_env);
            gr$get_module_env(msg = &temp_msg,
                              sizbuf = &sizebuffer,
                              buffer = &construct_env,
                              nret = &nbytes_ret);
            }

            construct_env.md_id.osnum = xyzos;
            construct_env.md_id.objid = NULL_OBJID;  /* don't put in R-tree */

            construct_list.msg = &temp_msg;
            construct_list.env_info = &construct_env;
            construct_list.newflag = FALSE;
            construct_list.level = edge_symb_ptr->level;
            construct_list.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE |
                                        GRNOT_IN_RTREE | GRIS_NEW;
            construct_list.display = &edge_symb_ptr->display_attr;
            construct_list.class_attr = (IGRchar *) &loc_xyzattr;
            construct_list.name = NULL;
            construct_list.geometry = NULL;

            /* construct either an associative or non-associative model-space
             * counterpart depending on the options
             */

            if (options & EMSlcopt_noassoc)
            {
                if (! xyzcv)
                {
                    stat_OM = om$send(msg = message EMSedge.EMget_bcxyz_geom
                                                     (&temp_msg, xyzinfo, NULL,
                                                      NULL, 0, MAXINT, FALSE,
                                                      NULL, &loc_xyzcv),
                                      targetid = my_id);
                    EMomerr_exit (stat_OM, wrapup);
                    EMerr_hndlr(EMSerror (temp_msg), *msg, EMS_E_EdgeError,
                                wrapup);
                }
                construct_list.geometry = (IGRchar *) &loc_xyzcv;
                status = EFget_classid_for_an_edge_type(&msc_classid,
                     (xyzcvtype == NULL) ? ME.EMSedge->curve_type : *xyzcvtype);
                EMerr_hndlr(!(1 & status), *msg, EMS_E_Fail, wrapup);

                stat_OM = om$construct(classid = msc_classid,
                                       p_objid = xyzobj,
                                       osnum = xyzos,
                                       msg =  message GRgraphics.GRconstruct
                                                           (&construct_list));
                EMerr_hndlr(!(1 & stat_OM & temp_msg), *msg, EMS_E_Fail, wrapup);
            }
            else  /* construct an associative model-space counterpart */
            {
                IGRint edge_type;
                IGRshort cvorder;
                IGRboolean cvrational;

                /* find the "creator" object of this model-space counterpart */

                stat_OM = EFget_creator_id(msg, my_id, OM_Gw_current_OS,
                                           &object_info.grid.objid, NULL);
                EMerr_hndlr(!(1 & stat_OM & *msg), *msg, EMS_E_Fail, wrapup);
/*
 * The creator may be NULL_OBJID if the boundary element is part of
 * an application object. (i.e VDS and struct related stuff).
 * In such a case it is proper to not create mscs.
 */

                if (object_info.grid.objid == NULL_OBJID)
                   goto wrapup;

/* end pp */

                creator_id = object_info.grid.objid;

                /* determine if the creator is an associative object; if it is
                 * not, send it a message to make it associative
                 */

                /*
                 * Currently it is assumed that the creator is either an
                 * associative object or a non-associative surface. By 
                 * associative we mean it needs to be a subclass of
                 * NDnodein.
                 * pp 11/14/91
                 */

                if (!(EFisAncestryValid(&temp_msg, object_info.grid.objid,
                                       OM_Gw_current_OS, OPP_NDnodein_class_id,
                                       FALSE))) 
                {
/*
                     stat_OM = as$make_source(go_grid = &object_info.grid,
                                 as_grid = &src_parent);
                     if (!(1&stat_OM)) goto wrapup;

                     object_info.grid = src_parent;
*/
                }

                if (! xyzcv)
                {
                    stat_OM = om$send(msg = message EMSedge.EMget_bcxyz_geom
                                                     (&temp_msg, xyzinfo, NULL,
                                                      NULL, 0, MAXINT, FALSE,
                                                      NULL, &loc_xyzcv),
                                      targetid = my_id);
                    EMomerr_exit (stat_OM, wrapup);
                    EMerr_hndlr(EMSerror (temp_msg), *msg, EMS_E_EdgeError,
                                wrapup);
                    cvorder = loc_xyzcv.order;
                    cvrational = loc_xyzcv.rational;
                }
                else
                {
                    cvorder = xyzcv->order;
                    cvrational = xyzcv->rational;
                }

                edge_type = ((xyzcvtype == NULL) ? ME.EMSedge->curve_type :
                             *xyzcvtype);

                if ((cvorder == 2) && (! cvrational))
                {
                 if (!EFisEdgeTypeLinear(edge_type))
                 {
                  if (((xyzcv) ? xyzcv->num_poles : loc_xyzcv.num_poles) == 2)
                   edge_type = EMlinesegment;
                  else
                   edge_type = EMlinestring;
                 }
                 else
                 {
/*
 * The following is to fix improper setting of edge types in some case.
 * Eg: cusps 
 */
                  if ((((xyzcv) ? xyzcv->num_poles : loc_xyzcv.num_poles) > 2)
                      && (edge_type == EMlinesegment))
                   edge_type = EMlinestring;

/* end pp 02/02/94 */
                 }
                }
                else if (cvorder > 2)
                {
     /*
      * If the curve is claiming to be a linesegment/point/linestring and its
      * order is greater than 2 then construct the same as a bspline curve. 
      * pp (03/31/89)
      */
                 if (EFisEdgeTypeLinear(edge_type))
                  edge_type = EMfreeform_curve;
                }

                status = EFget_assoc_classid_for_an_edge_type(&msc_classid,
                         edge_type);
                EMerr_hndlr(!(1 & status), *msg, EMS_E_Fail, wrapup);

                object_info.grid.osnum = OM_Gw_current_OS;
                object_info.env.md_id.osnum = OM_Gw_current_OS;
                stat_OM = ex$get_modid(mod_osnum = OM_Gw_current_OS,
                                       mod_id = &object_info.env.md_id.objid);
                EMomerr_exit (stat_OM, wrapup);

                /* use the construct environment module info since the model-
                 * space counterpart will always be constructed in the same
                 * object space as its creator
                 */

                object_info.env.md_env = construct_env.md_env;

                /* construct the associative model-space counterpart */

                stat_OM = om$construct(classid = msc_classid,
                                       p_objid = xyzobj,
                                       osnum = xyzos,
                                       msg = message EMSassoc.EMinit_associative
                                                   (msg, NULL, 1, &object_info,
                                                    EMSmsc_id, sizeof(GRobjid),
                                                    (IGRchar *) &my_id,
                                                    &construct_list));
                EMerr_hndlr(!(1 & stat_OM & *msg), *msg, EMS_E_Fail, wrapup);

                /* update the edge's properties to indicate it has a
                 * model-space counterpart
                 */

                ME.EMSedge->ed_props |= EMED_MSCEXISTS;
                HSdlist_msc_created( *xyzobj, OM_Gw_current_OS );


                {
                 IGRboolean make_tagged_connect = FALSE;
                 OMuword tagged_os;
                 IGRlong l_msg;
                 IGRint list_index;

                 tagged_os = OM_Gw_current_OS;
                 list_index = 0;

                 om$send (msg = message GRnotify.GRntfyconn(&l_msg,
                               &my_GRid, &notify, &list_index,
                               &make_tagged_connect, &tagged_os),
                          targetid = *xyzobj,
                          targetos = xyzos);
               }
            }
        }
    }

wrapup:

    if (loc_xyzcv.poles)
        om$dealloc (ptr = loc_xyzcv.poles);
    if (loc_xyzcv.knots)
        om$dealloc (ptr = loc_xyzcv.knots);
    if (loc_xyzcv.weights)
        om$dealloc (ptr = loc_xyzcv.weights);

  return (stat_OM);
}

end implementation EMSedge;
