/* ###################   APOGEE COMPILED   ################## */
/*
Name
        EMSsfimpbnd.EMconstruct_associative

Description
        This method [re]imposes boundaries on a surface.

History
        NP      12/08/93    Removed EMImpBnd_NoPrintError option which no longer
                            exists and replaced its functionality by using the
                            external variable OM_Gf_verbose_warning.
        WBC     01/07/93    Replaced call to BSmdistptsf with a call to
                            BSprptarrsf.
        SM      09/07/92    Fixed a bug in checking area side after imposing
                            the boundary. See inline comments dated 9/7/92.
        DLB     06/29/92    Support optional track pt parent as area pt.
        SM      03/16/92    When getting internal point for linear edges, 
                            get bcgeom, reparametrize based on cht between
                            poles and then get internal point.
                            This is to work around a problem in EMinternalpt()
                            due to which it may return an end point as an 
                            internal point. Fixing EMinternalpt() is too risky
                            at this point.
        SM      03/11/92    When imposing only the first curve out of
                            multiple curves, supress error printing via an 
                            option.
        DLB     01/21/92    Fixed bug where 1st curve will not close off area.
                            Must pass both curves in this case.
        DLB     01/04/92    Make several changes to attempt to rid this
                            code of side-flipping problem.
        DLB     12/20/91    Patched up problems in the area side computation.
        mrm     03/22/91    creation
	Sudha   06/01/93    modified to handle BSprototype headers
*/

class implementation EMSsfimpbnd;

#include "OMmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsmapdef.h"
#include "emsimpdef.h"
#include "EMSdpr.h"
#include <alloca.h>
#include "bsgeom_cvsf.h"
#include "maunitvc.h"
#include "mascalvc.h"
#include "macrossvc.h"
#include "bsptnorsf.h"
#include "bsprptarrsf.h"
#include "bsparameters.h"
#include "bsnorvec.h"
#include "bsfreecv.h"
#include "bschrdlkts.h"
#include "bschangepar.h"
#include "bsmdistptsf.h"

#define DO_AREA_CHECK_AFTER_IMPOSITION 0

#if DEBUG
#define ERROR(sts,msg,error_message,label)      \
    if (EMSmsgReport(sts,error_message,FALSE) || \
        EMSmsgReport(msg,error_message,FALSE))   \
                goto label;
#else
#define ERROR(sts,msg,error_message,label)   if (!(sts & msg & 1)) goto label;
#endif

#define KLUDGE_NECESSARY 0 /*THIS SHOULD NEVER BE SET TO 1 - WILL BREAK STUFF*/

#define WBC_USE_NEW_MATH 1

from GRcurve    import EMcvtanorm;
from EMSsubbs   import EMsftanorm;
from EMSedge    import EMtangent, EMget_props, EMinternalpt, EMptproject, 
                       EMgetbcgeom, EMgetsurface_info;
from EMSloopset import EMpt_location;
from GRlinear   import GRgetpolyline;

extern OMuword OPP_GRcompcurve_class_id, 
               OPP_EMSlinedge_class_id, 
               OPP_GRpoint_class_id;

extern IGRboolean WANT_POST220_BEHAVIOR;
extern unsigned int OM_Gf_verbose_warning;

method EMconstruct_associative(IGRlong               *msg;
                               IGRushort     options;
                               OM_S_OBJID            old_objid;
                               IGRint                nparents;
                               IGRchar               *parent_info;
                               IGRint                type;
                               IGRchar               *recomp_info;
                               struct GRvg_construct *construct)
{
extern void EFinit_geom_surface() ;
    IGRushort map_options, cur_map_options, imp_options;
    IGRuint   *parent_types, save_verbose_warning;
    OM_S_OBJID result;
    IGRint    i, recompute, ncurves, num_pts;
    IGRlong   sts, lmsg;
    IGRlong   *i_npoints, *i_nbadcurves, *i_badcurves;
    IGRpoint  **i_points, *i_pts, proj_cv_xyz;
    IGRdouble active_cht;
    IGRdouble origin[3], normal[3], tangent[3], vector[3], poly[6];
    IGRdouble dist, uv_parms[2], dist_tol;
    IGRpoint  projpt;
    union EMSparent_info *parents = NULL;
    OM_S_CHANSELECT to_comps;
    struct GRid *firstcurve = NULL, *tanorm_GRid, leaf_GRid;
    struct GRlc_info *obj;
    struct GRmd_env env, track_env;
    struct GRparms projparms;
    struct GRid surface, track;
    struct EMSimpbndinfo *r_info;
    struct EMSimpbndcmd *cmdata;
    struct GRlc_info *curves;
    struct IGRbsp_surface *surf_geom;
    struct BSgeom_bsp_surf geom_surface;
    struct EMSinlist  inlist;
    IGRint            num_tries=0;
    IGRboolean        final_pass, failed_pass, second_good_try, imp_w_track,
                      all_on_surf;

#if DEBUG
    IGRboolean        world=TRUE;
    IGRdouble         range[6];
    struct IGRdisplay display;

    display.color = 1;
    display.weight = 0;
    display.style = 0;
#endif

    /* Since we have removed the EMImpBnd_NoPrintError option, we are using the
     * OM variable "OM_Gf_verbose_warning" to achieve the same result, by 
     * saving its value in the beginning, setting it to TRUE whereever the
     * "EMImpBnd_NoPrintError" was being activated and setting it to FALSE 
     * whereever "EMImpBnd_NoPrintError" was being deactivated.
     * However, before we exit the function, we restore the value of 
     * "OM_Gf_verbose_warning" to what it was when it came into this function. 
     */
    save_verbose_warning = OM_Gf_verbose_warning;

    geom_surface.sfgen_cv = NULL; 

    /*Start out with empty buffers.*/
    memset((char *) &inlist, '\0', sizeof(struct EMSinlist));
    inlist.modlist.mod_id = NULL_OBJID;

    EMmake_chanselect (GRcmpowner_to_components, &to_comps);

    /* check options for recompute */

    recompute = options & EMSasconst_recompute;

    imp_w_track = (type == EMS_ASsfimpbnd_w_track_pt);

    /* unwind the parent information */

    parents = (union EMSparent_info *)alloca
              (sizeof(union EMSparent_info) * nparents);
    parent_types = (IGRuint *) alloca(sizeof(IGRint) * nparents);
    for (i = 0; i < nparents; i++) parent_types[i] = EMSgrid;

    sts = om$send(msg = message EMSassoc.EMget_parent_info
                       (msg, NULL, nparents, parent_info,
                        parent_types, parents),
                  targetid = my_id);

    ERROR(sts, *msg, "EMSsfimpbnd$EMconstruct_associative", wrapup);

    /* determine curve count and surface id */
/*
 * Removed the following kludge since we are able to handle connecting
 * the same parent multiple times on the parent channel using 
 * "identity" objects.
 * pp 06/19/91
 */

#if KLUDGE_NECESSARY
    if (recompute)
    {
        OMuword classid;

        /*  
            In this case, the parent array breaks down as:
                curve1, ..., curveN, surface[, state object]
            The state object may not be present, depending on whether
            there are intervening nodes in a dpr tree.  If the last
            parent is a not a dpr, then it is the surface; otherwise,
            the next-to-last parent is the surface.  All previous
            parents are curves which are to be imposed on the surface.
        */

        om$get_classid(objid = parents[nparents - 1].grobj.grid.objid,
                       p_classid = &classid);
        sts = om$is_ancestry_valid(subclassid = classid,
                                   superclassid = OPP_EMSdpr_class_id);
        ncurves = nparents - ((sts == OM_I_INVANCESTRY) ? 1 : 2);
    }
    else
    {
        /*  
            In this case, the parent array always breaks down as:
                curve1, ..., curveN, surface, state object
            The surface and state object are always present in the
            list during the initial computation, even if they are
            the same object.
        */

        ncurves = nparents - 2; 
    }
#else
    if (imp_w_track)
      ncurves = nparents - 3;
    else
      ncurves = nparents - 2; 
#endif

    surface = parents[ncurves].grobj.grid;
    env = parents[ncurves].grobj.env;

    if (imp_w_track)
    {
      track = parents[ncurves+1].grobj.grid;
      track_env = parents[ncurves+1].grobj.env;
    }

    /* reformat the curve info into the format EMimpose_boundaries needs */

    curves = (struct GRlc_info *) alloca(sizeof(struct GRlc_info) * ncurves);
    for (i = 0; i < ncurves; i++)
    {
        curves[i].located_obj = parents[i].grobj.grid;
        curves[i].module_info = parents[i].grobj.env;
    }

    /* grab a pointer to the recomputation info */

    r_info = (struct EMSimpbndinfo *)recomp_info;

    /* if recomputing, set the correct parameters */

    if (recompute)
    {
      /* save the current tolerance */
      BSEXTRACTPAR(&lmsg, BSTOLCHRDHT, active_cht);

      /* set the proper tolerance for this operation */
      BSchangepar(&lmsg, BSTOLCHRDHT, r_info->cht);
    }

    /*
        Grab a pointer to some data to pass back to the command object.
        This is currently kludged up to look in construct->class_attr,
        but should eventually be changed to use a additional argument to
        init_assoc and construct_assoc
     */

    if (recompute)
    {
      i_npoints = (IGRlong *) alloca(sizeof(IGRlong));
      *i_npoints = 0;
      i_pts = NULL;
      i_points = &i_pts;
      i_nbadcurves = (IGRlong *) alloca(sizeof(IGRlong));
      *i_nbadcurves = 0;
      i_badcurves = (IGRlong *) alloca(sizeof(IGRlong) * 50);
    }
    else
    {
      cmdata = (struct EMSimpbndcmd *)construct->class_attr;
      i_npoints = cmdata->npoints;
      i_points = cmdata->points;
      i_nbadcurves = cmdata->nbadcurves;
      i_badcurves = cmdata->badcurves;
    }

    { /*DLB ADDITION - get the surface geom for later use.*/
      IGRlong               surf_size;

      sts = om$send(msg = message GRvg.GRgetsize(msg,         
                          &env.md_env.matrix_type,
                          env.md_env.matrix,
                          &surf_size),
                    targetid = surface.objid,
                    targetos = surface.osnum);
      ERROR(sts, *msg, "GRvg.GRgetsize", wrapup);
                   
      surf_geom = (struct IGRbsp_surface *) alloca(surf_size);
      
      sts = om$send(msg = message GRvg.GRgetgeom(msg,
                          &env.md_env.matrix_type,
                          env.md_env.matrix,
                          (IGRchar *) surf_geom),
                    targetid = surface.objid,
                    targetos = surface.osnum);
      ERROR(sts, *msg, "GRvg.GRgetgeom", wrapup);
    }

    obj = &curves[0];

#if DEBUG
    /* get the range of the boundary */
    om$send(msg = message GRgraphics.GRgetrang
                 (msg, &obj->module_info.md_env.matrix_type,
                  obj->module_info.md_env.matrix, &world, range),
            targetid = obj->located_obj.objid,
            targetos = obj->located_obj.osnum);
#endif

    if (recompute && r_info->point_in_area && !imp_w_track)
    {
        /*
            calculate a new uv point on the surface --
            get a vector tangent to the first boundary at the locate point
        */

        firstcurve = &obj->located_obj;

        if (EFisAncestryValid(msg, firstcurve->objid, firstcurve->osnum, 
                          OPP_GRcompcurve_class_id, FALSE))
        {
         IGRint leaf_index;

         /*The index of the component curve is stored in leaf_id.objid
          * instead of the actual object id.  Added 10/01/92 by DLB.
          * leaf_index was uninitialized before this fix.
          * 
          * Note that use of the "correct" component curve here is really
          * not necessary since all the component curves in a composite
          * are oriented in the same direction which is how the area
          * side is determined.
          */
         leaf_index = r_info->parms.leaf_id.objid; 
         sts = om$get_objid_at_index(objid = firstcurve->objid,
                                     osnum = firstcurve->osnum,
                                     p_chanselect = &to_comps,
                                     index = leaf_index,
                                     objidaddr = &leaf_GRid.objid,
                                     osnumaddr = &leaf_GRid.osnum);
         if (sts == OM_E_INVINDEX) 
         {
          sts = om$get_objid_at_index(objid = firstcurve->objid,
                                      osnum = firstcurve->osnum,
                                      p_chanselect = &to_comps,
                                      index = 0,
                                      objidaddr = &leaf_GRid.objid,
                                      osnumaddr = &leaf_GRid.osnum);
         }
         EMerr_hndlr(!(1&sts), *msg, EMS_E_InvalidArg, wrapup);
         tanorm_GRid = &leaf_GRid;
        }
        else
         tanorm_GRid = &obj->located_obj;

        sts = om$send(msg = message GRcurve.EMcvtanorm
                      (msg, &obj->module_info.md_env.matrix_type,
                       obj->module_info.md_env.matrix,
                       (struct GRvg_construct *)NULL,
                       (IGRlong)1, &r_info->parms,
                       &r_info->parms, &r_info->parms,
                       (IGRdouble)1.0, (IGRdouble *)NULL,
                       (IGRboolean)TRUE, (IGRboolean)FALSE, poly,
                       (OM_S_OBJID *)NULL),
                      targetid = tanorm_GRid->objid,
                      targetos = tanorm_GRid->osnum);
        ERROR(sts,*msg,"GRcurve.EMcvtanorm",wrapup);

        tangent[0] = poly[3] - poly[0];
        tangent[1] = poly[4] - poly[1];
        tangent[2] = poly[5] - poly[2];

        /* store the first point of this vector as the "origin" */

        OM_BLOCK_MOVE(poly, origin, sizeof(IGRdouble) * 3);

#if     DEBUG
        EFdraw_vector_on_screen(my_id, &display, &obj->module_info, GRbd,
                                FALSE, poly, tangent, range, msg);
#endif

        /*
           get the normal for the surface - first, project the curve tangent 
           point onto the surface... Project along the surface normal - DLB
        */

        { /*INTENTIONAL*/
          IGRint    num_pt;
  
          (void) BSptnorsf(surf_geom, origin, &num_pt,
                           &projparms.u, &projparms.v, proj_cv_xyz,
                           &dist, msg);
          if (BSERROR(*msg))
          {
            *msg = EMS_E_BSerror;
            ERROR(1, *msg, "BSptnorsf", wrapup);
          }
        }

        /* ...next, get the surface normal at the projected point */

        sts = om$send(msg = message EMSsubbs.EMsftanorm
                      (msg, &env.md_env.matrix_type,
                       env.md_env.matrix,
                       (struct GRvg_construct *)NULL,
                       (IGRlong)1, &projparms.u,
                       (IGRlong)1, &projparms.v,
                       (IGRdouble)1.0, (IGRdouble *)NULL,
                       (IGRboolean)FALSE, (IGRboolean)TRUE, poly,
                       (OM_S_OBJID *)NULL),
                      targetid = surface.objid,
                      targetos = surface.osnum);

        ERROR(sts,*msg,"EMSsubbs.EMsftanorm",wrapup);

        normal[0] = poly[3] - poly[0];
        normal[1] = poly[4] - poly[1];
        normal[2] = poly[5] - poly[2];

#if     DEBUG
        display.color = 2;
        EFdraw_vector_on_screen(my_id, &display, &obj->module_info, GRbd,
                                FALSE, poly, normal, range, msg);
#endif
        /* cross the boundary tangent and curve normal to get a vector */

        MAcrossvc(msg, tangent, normal, vector);

#if     DEBUG
        display.color = 3;
        EFdraw_vector_on_screen(my_id, &display, &obj->module_info, GRbd,
                                r_info->reverse, poly, vector, range, msg);
#endif
        /*
            move along the vector a small amount to obtain a uv point
            on the surface to define as the area
        */

        MAunitvc(msg, vector, vector);
        MAscalvc(msg, &r_info->veclen, vector, vector);
        if (r_info->reverse)
        {
            proj_cv_xyz[0] -= vector[0];
            proj_cv_xyz[1] -= vector[1];
            proj_cv_xyz[2] -= vector[2];
        }
        else
        {
            proj_cv_xyz[0] += vector[0];
            proj_cv_xyz[1] += vector[1];
            proj_cv_xyz[2] += vector[2];
        }

        /* project this point onto the surface to obtain the area point */

        sts = om$send(msg = message GRgraphics.GRptproject
                           (msg, &env.md_env.matrix_type,
                            env.md_env.matrix, proj_cv_xyz,
                            projpt, &projparms),
                      targetid = surface.objid,
                      targetos = surface.osnum);

        ERROR(sts,*msg,"GRgraphics.GRptproject",wrapup);

#if     DEBUG
        display.color = 4;
        display.weight = 5;
        ECdisplayPointSetByBuffer(msg, display, env,
                                  NULL_OBJID, 1, projpt, TRUE);
        display.weight = 0;
#endif

        r_info->uv_point[0] = projparms.u;
        r_info->uv_point[1] = projparms.v;
    }
    else if (imp_w_track)
    {
      IGRint             num_pt, return_poly=1;
      struct IGRpolyline polyline;
  
      if (!EFisAncestryValid(msg, track.objid, track.osnum,
                             OPP_GRpoint_class_id, FALSE))
      {*msg = EMS_E_InvalidCase; goto wrapup;}

      polyline.points = origin;

      sts = om$send(msg = message GRlinear.GRgetpolyline(msg,
                          &track_env.md_env.matrix_type,
                          track_env.md_env.matrix,
                          &return_poly, &polyline),
                    targetid = track.objid,
                    targetos = track.osnum);
      ERROR(sts,*msg,"GRgraphics.GRptproject",wrapup);

      (void) BSptnorsf(surf_geom, origin, &num_pt,
                       &projparms.u, &projparms.v, proj_cv_xyz,
                       &dist, msg);
      if (BSERROR(*msg))
      {
        *msg = EMS_E_BSerror;
        ERROR(1, *msg, "BSptnorsf", wrapup);
      }

      r_info->uv_point[0] = projparms.u;
      r_info->uv_point[1] = projparms.v;
    }

    /* impose the boundaries */

    result = my_id;
    imp_options = EMImpBnd_WantStatMsg;
    if (!r_info->point_in_area) imp_options |= EMImpBnd_AutoNest;
    map_options = EMMapBnd_WantStatMsg | EMMapBnd_WantBadCurves |
                  EMMapBnd_StrokeIfNeeded;

    /*Make more than 1 pass: 
     *
     * First pass will ensure a good area point pick and second will be the
     *  real thing. 
     * If imposing only 1 curve and the area point picked initially was good
     *  then dont make the second pass. 
     * If autonesting then only make one pass.
     * If have track pt parent then only make one pass.
     * If get NoMoreLoops error on first pass then go again with all curves.
     *  If get NoMoreLoops again then error out.
     */

    final_pass = FALSE;
    second_good_try = FALSE;

    while (!final_pass)
    {
      IGRint pass_in_ncurves;

      if (num_tries == 0 && 
          r_info->point_in_area /*no auto-nest*/ && 
          !imp_w_track /*no track pt*/ ) 
      {
        /*Always pass only the first curve in to check validity of area 
         * side.  Then pass in all curves.
         */
        pass_in_ncurves = 1;

        if (ncurves > 1) 
           OM_Gf_verbose_warning=FALSE;
      }
      else 
      {
        /* I pass all curves in if:
         * Have a good area point or previous pass failed due to open boundary
         * or auto nest case or track pt parent case.  
         */
        pass_in_ncurves = ncurves;

        if(ncurves > 1) 
          OM_Gf_verbose_warning = TRUE; 
      }

      failed_pass = FALSE;

      cur_map_options = map_options;
      if (pass_in_ncurves != ncurves) 
        cur_map_options &= ~EMMapBnd_WantBadCurves;

#if   DEBUG
      fprintf(stderr,"%d TRY OF IMPOSING BOUNDARY\n", num_tries);
#endif

      sts = om$send(msg = message EMSsurface.EMimpose_boundaries
                         (msg, pass_in_ncurves, NULL, curves, r_info->uv_point,
                          r_info->point_in_area, construct->env_info,
                          i_npoints, i_points, i_nbadcurves, i_badcurves,
                          NULL, NULL, NULL, NULL,
                          cur_map_options, imp_options, &result),
                    targetid = surface.objid,
                    targetos = surface.osnum);

      if (!(1 & *msg & sts) || *msg == EMS_I_NoMoreLoops)  /*failure*/
      {
        failed_pass = TRUE;
        if (num_tries == 0 && ncurves > 1)
        {
          *msg = EMS_S_Success;
          final_pass = FALSE;
        }
        else
        {
          final_pass = TRUE;

          if (! recompute)  /*disconnect and delete me*/
          {
            struct GRid     my_grid;

            my_grid.objid = my_id;
            my_grid.osnum = OM_Gw_current_OS;
    
            om$send(msg = message GRconnector.GRdisconn(msg, &my_grid),
                    p_chanselect = &to_comps);
              
            om$send(msg = message Root.delete(NULL),
                    targetid = my_id);
            *msg = EMS_I_NoMoreLoops;
          }
          else *msg = EMS_I_CantRecompute;
        }
      }

      num_tries++;

      /*safety net - 3 tries maximum*/
      if (second_good_try || num_tries > 3) final_pass = TRUE;

      if (!r_info->point_in_area || imp_w_track) /*auto-nest or track pt */
      {
        final_pass = TRUE;
      }
      else if (!failed_pass && !final_pass && !second_good_try)
      {
        IGRdouble             min_proj_uv[2], min_dist;
        struct EMSpartolbasis partolbasis;
        OM_S_CHANSELECT       to_loopset;
        struct EMSptloc_info  location_info;
        struct EMSproj_info   proj_info;
        OMuint                ii;
        GRobjid               edgeid=NULL_OBJID;
        /*IGRushort     ed_props;*/
        extern OMuword        OPP_EMSpartedge_class_id;
        IGRboolean            done = FALSE;
        
        EMmake_chanselect(EMSsubbs_to_loopset, &to_loopset);

        /*get closest point on bndry to the area point*/
        sts = om$send(msg = message EMSdpr.EMgetInInfo(msg, &inlist,
                            NULL_OBJID, FALSE, 
                            EMget_in_inf_NO_SURFS | EMget_in_inf_NO_LOOPS),
                      targetid = my_id);
        ERROR(sts, *msg, "getininf", wrapup);

        min_dist = GRDGNLIMITS_MAX_D;

        partolbasis.mattyp = &env.md_env.matrix_type;
        partolbasis.mat = env.md_env.matrix;
	partolbasis.is_valid = FALSE;
	
        /*Get closed edge to best guess pt*/
        for(ii=0; ii<inlist.edlist.num_edges; ii++)
        {
          if (!EFisAncestryValid(msg, 
                                 inlist.edlist.edge_ids[ii],
                                 surface.osnum, 
                                 OPP_EMSpartedge_class_id, FALSE))
          {
	    GRobjid thisedsf = NULL_OBJID;

            partolbasis.in_world = TRUE;

            /* EMgetInInfo message returns all edges added by the imp. bdry
               node. This includes the copies of the edges from common surfaces
               which became connectable after imposition. We want to consider
               only the edges on the imposition surface.
               SM 4/22/93.
            */
            sts = om$send(msg = message EMSedge.EMgetsurface_info(msg,
                          &thisedsf, NULL), 
                          targetid = inlist.edlist.edge_ids[ii],
                          targetos = surface.osnum);            
            ERROR(sts, *msg, "edge.ptproj", wrapup);

            if( (!IF_NULL_OBJID(thisedsf)) && 
                (!IF_EQ_OBJID(surface.objid, thisedsf)))
             continue;

            sts = om$send(msg = message EMSedge.EMptproject(msg,
                                r_info->uv_point, 1, 
                                &proj_info, NULL, &partolbasis),
                          targetid = inlist.edlist.edge_ids[ii],
                          targetos = surface.osnum);            
            ERROR(sts, *msg, "edge.ptproj", wrapup);

            if (proj_info.dist < min_dist)
            {
              min_dist = proj_info.dist;
              edgeid = inlist.edlist.edge_ids[ii];
            }
          }
        }
                      
        if (inlist.edlist.edge_ids) om$dealloc(ptr = inlist.edlist.edge_ids);
        inlist.edlist.edge_ids = NULL;
        inlist.edlist.num_edges = 0;
        inlist.edlist.array_size = 0;

        /*Now get an internal point on this edge to check area side*/

        /* SM 03/16/92 fix for linear edges only. In case of any problem
           in the fix, old code is executed, without aborting.
        */
        if(EFisAncestryValid(msg, edgeid, surface.osnum, 
           OPP_EMSlinedge_class_id, FALSE))
         {
          struct IGRbsp_curve lined;
          IGRboolean bssts;
          BSrc rc;
          struct EMSdataselect ingeom;

          lined.poles = NULL;
          lined.knots = NULL;
          lined.weights = NULL;
        
          sts = om$send(msg = message EMSedge.EMgetbcgeom(msg, 0, MAXINT, 
                FALSE, NULL, &lined, &partolbasis, NULL),
                      targetid = edgeid,
                      targetos = surface.osnum);                        
          ERROR(sts, *msg, "edge.getbcgeom", loc_wrapup);
          
          bssts = BSchrdlkts(&rc, &lined.num_poles, lined.poles, 
                  &lined.order, &lined.periodic, lined.knots);
          if(!bssts || (rc!=BSSUCC))
           {
            *msg = EMS_E_BSerror;
            goto loc_wrapup;
           }

          ingeom.datatype = EMSdata_curve3d;
          ingeom.data.curve = &lined;

          sts = EMinternalpt(msg, partolbasis.mattyp, partolbasis.mat, &ingeom,
                EMScvint_middle, 1, min_proj_uv);
          ERROR(sts, *msg, "edge.internalpt", loc_wrapup);

loc_wrapup:
          if(lined.poles) om$dealloc(ptr = lined.poles);
          if(lined.knots) om$dealloc(ptr = lined.knots);
          if(lined.weights) om$dealloc(ptr = lined.weights);
          if(!(1&sts&*msg)) done = FALSE;
          else done = TRUE;
         }

        if(!done)
         {
          sts = om$send(msg = message EMSedge.EMinternalpt(msg, 1, NULL,
                            min_proj_uv, NULL, NULL),
                      targetid = edgeid,
                      targetos = surface.osnum);                        
          ERROR(sts, *msg, "edge.internalpt", wrapup);
         }

        /* Get the surface normal at this new uv point */

        sts = om$send(msg = message EMSsubbs.EMsftanorm
                      (msg, &env.md_env.matrix_type,
                       env.md_env.matrix,
                       (struct GRvg_construct *)NULL,
                       (IGRlong)1, &min_proj_uv[0],
                       (IGRlong)1, &min_proj_uv[1],
                       (IGRdouble)1.0, (IGRdouble *)NULL,
                       (IGRboolean)FALSE, (IGRboolean)TRUE, poly,
                       (OM_S_OBJID *)NULL),
                      targetid = surface.objid,
                      targetos = surface.osnum);

        ERROR(sts,*msg,"EMSsubbs.EMsftanorm",wrapup);

        normal[0] = poly[3] - poly[0];
        normal[1] = poly[4] - poly[1];
        normal[2] = poly[5] - poly[2];

        /*now have uv pnt on closest bndry. get xyz*/
        sts = om$send(msg = message GRvg.EMptatpr(msg,
                            &env.md_env.matrix_type,
                            env.md_env.matrix,
                            min_proj_uv, 2,
                            proj_cv_xyz),
                      targetid = surface.objid,
                      targetos = surface.osnum);
        ERROR(sts, *msg, "ptatpr", wrapup);

        /*Get EDGE vector at this u,v pnt*/
        sts = om$send(msg = message EMSedge.EMtangent(msg,
                            &env,
                            &surface.objid,
                            proj_cv_xyz,
                            (IGRdouble) 1.0,
                            NULL,
                            tangent),
                      targetid = edgeid,
                      targetos = surface.osnum);
        ERROR(sts, *msg, "ed.tangent", wrapup);

/***** SM 09/07/92
 It was assumed that the edge direction and the curve direction will be the
 same after imposition. This may not be true, since the surface parametrization
 affects the edge direction, for the same curve direction. The above message
 obtains the edge tangent in the logical direction. This needs to be compared
 with the curve tangent and reversed if necessary. The following edge reversal
 check is replaced by the edge and curve tangent comparison.
*********/

/************* Start SM 09/07/92
        sts = om$send(msg = message EMSedge.EMget_props(msg, &ed_props),
                      targetid = edgeid,
                      targetos = surface.osnum);
        ERROR(sts, *msg, "ed.getprop", wrapup);                      
                        
        if (ed_props & EMED_REVERSED)
        {
          tangent[0] *= -1;
          tangent[1] *= -1;          
          tangent[2] *= -1;
        }
*************** End SM 09/07/92 *******************/

/************ Start SM 09/07/92 ******************/
     {
      struct GRid *firstcurve, cvGRid;
      struct GRparms cvparms;
      IGRpoint xyz_on_cv;
      IGRdouble cvpoly[6], cvtangent[3], dotp, edtangent[3];
      BSrc rc;

      firstcurve = &obj->located_obj;

      /* Project the xyz point on to the parent xyz curve. Then compute
         the curve tangent at the projected point.
      */

      /* DLB 10/01/92 - Fix to handle first curve being a composite.
                        In this case project the xyz point on the composite
                        to find the closest component curve.  Then use that
                        component curve to get the tangent vector.  This 
                        should be the curve that produced the edge "edgeid".
                        Fix for TR#119220504.
      */                  
                        

      sts = om$send(msg = message GRgraphics.GRptproject
            (msg, &obj->module_info.md_env.matrix_type,
             obj->module_info.md_env.matrix,
             proj_cv_xyz, xyz_on_cv, &cvparms), 
             targetid = firstcurve->objid, targetos = firstcurve->osnum);
      ERROR(sts,*msg,"GRcurve.GRptproject",wrapup);

      if (EFisAncestryValid(msg, firstcurve->objid, firstcurve->osnum, 
                          OPP_GRcompcurve_class_id, FALSE))
      {
        cvGRid = cvparms.leaf_id;
      }
      else
       cvGRid = obj->located_obj;

      sts = om$send(msg = message GRcurve.EMcvtanorm
            (msg, &obj->module_info.md_env.matrix_type,
             obj->module_info.md_env.matrix, (struct GRvg_construct *)NULL,
             (IGRlong)1, &cvparms, &cvparms, &cvparms,
             (IGRdouble)1.0, (IGRdouble *)NULL,
             (IGRboolean)TRUE, (IGRboolean)FALSE, cvpoly,
             (OM_S_OBJID *)NULL),
             targetid = cvGRid.objid, targetos = cvGRid.osnum);
      ERROR(sts,*msg,"GRcurve.EMcvtanorm",wrapup);

      cvtangent[0] = cvpoly[3] - cvpoly[0];
      cvtangent[1] = cvpoly[4] - cvpoly[1];
      cvtangent[2] = cvpoly[5] - cvpoly[2];

      BSnorvec(&rc, cvtangent);
      OM_BLOCK_MOVE(tangent, edtangent, 3*sizeof(IGRdouble));
      BSnorvec(&rc, edtangent);
      dotp = edtangent[0]*cvtangent[0] +
             edtangent[1]*cvtangent[1] +
             edtangent[2]*cvtangent[2];

      if(dotp<0)
       {
        tangent[0] *= -1;
        tangent[1] *= -1;          
        tangent[2] *= -1;
       }

     }
/************ End SM 09/07/92 ******************/

#if     DEBUG
        obj = &curves[0];

        display.color = 3;
        EFdraw_vector_on_screen(my_id, &display, &obj->module_info, GRbd,
                                FALSE, poly, tangent, range, msg);

        display.color = 4;
        EFdraw_vector_on_screen(my_id, &display, &obj->module_info, GRbd,
                                FALSE, poly, normal, range, msg);
#       endif

        /* cross the EDGE tangent and SURFACE normal to get a vector
           pointing INTO the area of the surface.
        */
        MAcrossvc(msg, tangent, normal, vector);

#if     DEBUG
        display.color = 5;
        EFdraw_vector_on_screen(my_id, &display, &obj->module_info, GRbd,
                           r_info->reverse, poly, vector, range, msg);
#       endif
        /*
            move along the vector a small amount to obtain a uv point
            on the surface to define as the area
        */

        MAunitvc(msg, vector, vector);
        MAscalvc(msg, &r_info->veclen, vector, vector);

        if (r_info->reverse)
        {
          proj_cv_xyz[0] -= vector[0];
          proj_cv_xyz[1] -= vector[1];
          proj_cv_xyz[2] -= vector[2];
        }
        else
        {
          proj_cv_xyz[0] += vector[0];
          proj_cv_xyz[1] += vector[1];
          proj_cv_xyz[2] += vector[2];
        }
        
        /*Project the xyz point onto the surface to get the uv - cant use
         * GRptproject cause it honors boundaries
         */

#if WBC_USE_NEW_MATH
        EFinit_geom_surface(msg, surf_geom, surface.objid, surface.osnum,
                            &geom_surface);
        if (! (*msg & 1))
          ERROR(1, *msg, "EFinit_geom_surface", wrapup);

        BSEXTRACTPAR(&lmsg,BSTOLLENVEC,dist_tol);
        num_pts = 1;

        BSprptarrsf(&geom_surface, dist_tol, 2, 2, &num_pts, proj_cv_xyz,
                    uv_parms, projpt, &all_on_surf, NULL, msg);
        if (BSERROR(*msg))
        {
          *msg = EMS_E_BSerror;
          ERROR(1, *msg, "BSprptarrsf", wrapup);
        }

        projparms.u = uv_parms[0];
        projparms.v = uv_parms[1];
#else 
        (void) BSmdistptsf(msg, surf_geom,  proj_cv_xyz,
                           &projparms.u, &projparms.v,
                           projpt, &dist);
        if (BSERROR(*msg))
        {
          *msg = EMS_E_BSerror;
          ERROR(1, *msg, "BSptnorsf", wrapup);
        }
#endif

#if     DEBUG
        display.color = 1;
        display.weight = 5;
        ECdisplayPointSetByBuffer(msg, display, env,
                                  NULL_OBJID, 1, projpt, TRUE);
        display.weight = 0;
#endif

        /*now do pt location, if in hole then we got a flip case.*/

        min_proj_uv[0] = projparms.u;
        min_proj_uv[1] = projparms.v;

        partolbasis.is_valid = FALSE;
        partolbasis.in_world = TRUE;

        sts = om$send(msg = message EMSloopset.EMpt_location(msg,
                            min_proj_uv, &location_info, &partolbasis),
                      senderid = surface.objid,
                      targetos = surface.osnum,
                      p_chanselect = &to_loopset);
        ERROR(sts,*msg,"pt_location",wrapup);                          

        /*Make the second pass if there is more than 1 curve to impose OR
         * the area pt picked was bad.
         */
        if (location_info.location == EMS_L_INHOLE ||
            location_info.location == EMS_L_UNKNWN ||
            pass_in_ncurves != ncurves)
        {
          OMuword deact_opt = EMS_UNDO_DELETE | EMS_UNDO_DONTDELME |
                              EMS_UNDO_DONTCLEANOWN |
                              EMS_UNDO_DONTDISCONCOMPS;

          /* If the point in area proved to be good during first pass, 
             leave it alone.
             SM 7/29/93
          */
          if(WANT_POST220_BEHAVIOR && 
             (location_info.location == EMS_L_INHOLE ||
             location_info.location == EMS_L_UNKNWN))
           {
            r_info->uv_point[0] = projparms.u;
            r_info->uv_point[1] = projparms.v;
           }

          second_good_try = TRUE;

          sts = om$send(msg = message EMSdpr.EMundo(msg,
                              &deact_opt,
                              &env,
                              NULL, NULL, NULL,
                              NULL, NULL, NULL),
                        targetid = my_id);
          ERROR(sts, *msg, "undo", wrapup);
          ME.EMSdpr->dpr_props = NULL;
        }
        else final_pass = TRUE;

      } /* else if (!failed_pass && !final_pass && !second_good_try) */

    } /* while (!final_pass) */

    if (recompute)
    {
      /* restore active tolerance */
      BSchangepar(&lmsg, BSTOLCHRDHT, active_cht);
    }

wrapup:
    /* restore the value of "OM_Gf_verbose_warning" back to what it was */
    OM_Gf_verbose_warning = save_verbose_warning;

    if (geom_surface.sfgen_cv)
        BSfreecv(&lmsg, geom_surface.sfgen_cv);

    if (inlist.edlist.edge_ids) om$dealloc(ptr = inlist.edlist.edge_ids);
    return(sts);
}

end implementation EMSsfimpbnd;
