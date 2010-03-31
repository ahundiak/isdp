class implementation EMSsf_lift;

#include "EMS.h"
#include <stdio.h>
%safe
#include "math.h"
%endsafe
#include "OMmacros.h"
#include "bstypes.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emserr.h"
#include "emsdef.h"
#include "EMSprop.h"
#include "emsedgedef.h"
#include "EMSbnd.h"
#include "EMSbnddef.h"
#include "emsinter.h"
#include "emssfint.h"
#include "emsimpdef.h"
#include "emsmapdef.h"
#include "emsmacros.h"
#include "EMSopt.h"
#include "OMmacros.h"
#include "bsgeom_cvsf.h"
#include "ma.h"
#include "matypemx.h"
#include "matrlmx.h"
#include "maoptsxfo.h"
#include "bssfeval.h"
#include "bssfarrevn.h"
#include "bsrev_cv.h"
#include "bsprptarrsf.h"
#include "bsmdstptcv.h"
#include "bsfreecv.h"
#include "bsdotp.h"
#include "bsdistptpts.h"
#include "bsdistptpt.h"
#include "bscveval.h"
#include "bscvarrevt.h"
#include "bscrossp.h"
#include "bsgeom_cvsf.h"


#define EDGEU0  0
#define EDGEV1  1
#define EDGEU1  2
#define EDGEV0  3

#define U       0
#define V       1

#define EMS_MD_EXTRACT_LP    1
#define EMS_MD_DELETE_LP     2
#define EMS_MD_EXTRACT_SF    3

#define WBC_USE_NEW_MATH 1

extern OMuword  OPP_EMSproject_class_id;
extern OMuword  OPP_EMSgenbs_class_id;
extern OMuword  OPP_EMSplane_class_id;
extern OMuword  OPP_EMSbsedge_class_id;
extern OMuword  OPP_EMSedge_class_id;

extern IGRboolean _sm_convert_into_plane;
extern IGRboolean WANT_POST220_BEHAVIOR;
extern void     EFget_analytic_info();

from EMSsubbs    import EMruled_surface, EMdrafted_surface;
from EMSproject  import EMplace_surface_of_projection;
from EMSsubbs    import EMexeinst, EMpartolbasis;
from EMSboundary import EMget_objid, EMgetsurface_info, EMtpcopy,
                        EMcompress_top, EMmk_act_cm_eds_connectable,
                        EMget_edges, EMtree_traverse;
from EMSloopset  import EMsplityourself, EMset_props, EMptproject,
                        EMget_loops, EMnesting, EMtreemod;
from EMSloop     import EMpt_location, EMget_props, EMset_props,
                        EMtreemod, EMtrimyourself, EMextractyourself,
                        EMactivate_loop, EMgivenestinfo;
from EMSedge     import EMget_bcxyz_geom, EMconnect_edges, 
                        EMget_props_type, EMget_sf_geom,
                        EMsplityourself, EMstitch,
                        EMget_props, EMset_props, EMendpts,
                        EMget_top_part_edges, EMgetbcgeom, EMputbcgeom,
                        EMgetpygeom, EMstroke_iso_edge;
from EMSlinedge  import EMleinit;

%safe
static void EFfix_the_intloc();
%endsafe

/*
   History 
        WBC     10-Nov-93    Fix for TR#119311557.  An additional class check
                             was necessary in the fix described below
                             (SM  16-Sept-93).  Its intent was to process
                             partial cones but partial cylinders are subclassed
                             from partial cones so partial cylinders were
                             mistakenly being processed.
        SM      16-Sept-93   Problem - When a circular arc is part of a comp
                             curve we can't always assume that it would give
                             rise to a partial cone as the drafted surface.
                             In cases where the components of the comp.
                             curve get trimmed after offsetting,  the sweep 
                             angles of the 2 circular arcs (original and the 
                             offset) may not be the same. In such cases the 
                             resulting surface should not be a partial cone.
                             Solution - For lack of information about curve
                             trimming during comp. curve offset,  went for the
                             brute force method of validating the surface 
                             geometry for partial cones. If invalid change 
                             class. See EFcreate_lft_sf1.
	Sudha	06/23/93     Modified for BSprototype ansification
        Jack    06/14/93     Added call to EFget_analytic_info in 
                             EFcreate_lft_sf1 to allow analytic surface 
                             creation during lift face(boss)
                             operations.
         AMD    03/12/93     Maintain the dominant properites of the edges
                             being connected which might get reversed at the
                             time of connection

         WBC    01/08/93     Replaced the calls to BSmdistptsf and BSprptonsf
                             with calls to BSprptarrsf.
         AMD    09/14/92     Fix for TR 92n6261
	 DLB    09/08/92     Fixed problem where "tweeking" of end pt of edge
	 			resulted in an ISO edge no longer being iso.
	ashok	01/27/92     Added criterion for storing edges in SSI in
			     function EFcollect_ed_split_info(). Also added
			     a new argument to the function.
         DLB    04/01/91     Add display params. Change the affected functions 
                             names.
	 SM	28-Mar-89    Argument change in EMget_loops_for_imposition.
			     Function renamed as EMget_mapped_data().
         DLB    07/26/88     Added code to set surfaces to inactive.
         RC     03/20/88     Creation Date

   Notes
       This file contains various routines used by different
       lift operations. 
*/


/*
 * The follwing function is used to detect whether
 * the surface created by the movement of an edge 
 * along a vector will overlap the common edge's
 * surface's area region or not. As a result of
 * the following assumptions, this is achieved 
 * without surface_surface intersection:
 *
 * i) If the coincidence occurs, the newly created surface
 *    will be fully coincident with the other surface. There
 *    will not be a partial coincidence.
 *
 * ii) The newly constructed surface will totally lie
 *     on the area region of other surface i.e., the process of 
 *     moving the edge will not cross over the hole regions 
 *     of the surface under consideration.
 *
 * 
 * Algorithm:
 *   
 *   o Perform minimum distance between movement vector
 *     and the common edge's surface. If the distance is within
 *     tolernace, it is assumed that it lies on the surface.
 *
 *   o Extract a model space counterpart for the edge under 
 *     consideration. The extraction should be done in the 
 *     edge direction.
 *
 *   o Calculate the a vector tangent to the curve extracted
 *     in step 1. The tangent vector can evaluated at any point 
 *     on the edge. Let it be Vt.
 *
 *   o Calculate the natural normal to the surface corresponding
 *     to the common edge of the edge used in step 1. The normal
 *     should be evaluated using the same point as in step 2. 
 *     Let it be Vn.
 *
 *   o (Vt * Vn) will result in a vector tangent to the
 *     the surface used in step 3 and will be pointing towards the area
 *     region of the surface. Let it be Vt_Cp_Vn.
 *
 *   o Let Vlift is lift vector input by the user.
 *     If (Vt_Cp_Vn . Vlift) > 0., it is a case of coincidence.
 *
 */

 void   EFdoes_new_sf_overlaps_cm_ed_sf (
               EFmsg,
               ed_GRid,
               lift_vec,
               md_env,
               overlap_exists,
               cm_ed_GRid,
               cm_ed_sf_GRid,
               cm_ed_sfgm,
               cm_ed_oldgm)

  IGRlong                    *EFmsg;
  struct  GRid               ed_GRid;
  IGRvector                  lift_vec;
  struct      GRmd_env       *md_env;
  IGRboolean                 *overlap_exists;
  struct      GRid           *cm_ed_sf_GRid, *cm_ed_GRid;
  struct      IGRbsp_surface **cm_ed_sfgm;
  struct      IGRbsp_curve   *cm_ed_oldgm;
  
  {
    OM_S_OBJECT_LINKAGE      cm_ed_list;
    OM_S_CHANSELECT          cm_ed_chan;
    struct BSgeom_bsp_surf   geom_surface;
    IGRdouble                sf_uv[2], dist, dist_tol, tan_pts[6], 
                             tan_vec[3], nor_vec[3], t_c_n_vec[3], 
                             sf_pt[3], mpt[3], prj_mpt[3], mv_mpt[3], 
                             mpar;
    IGRlong                  OM_stat, rc, mthd_stat;
    IGRint                   i, num_pts;
    OMuint                   count;
    IGRboolean               status, onsrf;
extern void EFinit_geom_surface() ;
    typedef IGRpoint         dummy[2];

    *EFmsg = EMS_S_Success;
    OM_stat = OM_S_SUCCESS;
    *overlap_exists = FALSE; 
    geom_surface.sfgen_cv = NULL;

    OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &cm_ed_chan);
    EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

    OM_stat = om$get_channel_objects (osnum = ed_GRid.osnum,
                 objid = ed_GRid.objid, p_chanselect = &cm_ed_chan,
                 list = &cm_ed_list, size = 1, count = &count);
    EMerr_hndlr (!(1&OM_stat),*EFmsg, EMS_E_OMerror, wrapup);
    EMerr_hndlr (count != 1, *EFmsg, EMS_E_InvalidArg, wrapup);
    cm_ed_GRid->objid = cm_ed_list.S_objid;
    cm_ed_GRid->osnum = cm_ed_list.osnum;

    OM_stat = om$send (msg = message EMSboundary.EMgetsurface_info (
                        &mthd_stat, &cm_ed_sf_GRid->objid, NULL),
                       senderid = NULL_OBJID,
                       targetid = cm_ed_list.S_objid, 
                       targetos = cm_ed_list.osnum);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg, EMS_E_EdgeError,wrapup);
    cm_ed_sf_GRid->osnum = cm_ed_list.osnum;    

    OM_stat = om$send (msg = message EMSedge.EMget_sf_geom (&mthd_stat,
                        cm_ed_sf_GRid, cm_ed_sfgm, &md_env->md_env),
                      senderid = NULL_OBJID,
                      targetid = cm_ed_list.S_objid,
                      targetos = cm_ed_list.osnum);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg, EMS_E_EdgeError,wrapup);
 
    OM_stat = om$send (msg = message EMSedge.EMget_bcxyz_geom (
                        &mthd_stat, &md_env->md_env, cm_ed_sf_GRid,
                         *cm_ed_sfgm, NULL, MAXINT, FALSE, NULL,
                         cm_ed_oldgm),
                       senderid = NULL_OBJID, 
                       targetid = cm_ed_list.S_objid, 
                       targetos = cm_ed_list.osnum);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg, EMS_E_EdgeError,wrapup);
    
    /*
     * get the mid point of the curve. In case of linear edge or a 
     * part of linear edge, the point obtained may not be node point
     * of the linear edge. In such a case, the point can be away from
     * the surface by chord_height tolerance (at most). If such is the
     * case, the mv_mpt will also be away from the surface and thus the
     * minimum distance test will fail. In order to avoid such instances
     * the mpt is projected on to the surface.
     */

    mpar = 0.5;
    BScveval (cm_ed_oldgm, mpar, 0, (IGRpoint *)&mpt[0], &rc);
    EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup );

    status = BSEXTRACTPAR (&rc, BSTOLLENVEC, dist_tol);

#if WBC_USE_NEW_MATH
    EFinit_geom_surface(&rc, *cm_ed_sfgm, cm_ed_sf_GRid->objid,
                        cm_ed_sf_GRid->osnum, &geom_surface);
    EMerr_hndlr (!(1&rc),*EFmsg, EMS_E_Fail,wrapup);

    num_pts = 1;

    BSprptarrsf(&geom_surface, dist_tol, 2, 2, &num_pts, mpt, sf_uv,
                prj_mpt, &onsrf, NULL, &rc);
    EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror,wrapup);

    for (i = 0; i < 3; i++)
      mv_mpt[i] = prj_mpt[i] + lift_vec[i];

    BSprptarrsf(&geom_surface, dist_tol, 2, 2, &num_pts, mv_mpt, sf_uv,
                sf_pt, &onsrf, NULL, &rc);
    EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror,wrapup);

    dist = BSdistptpt(&rc, mv_mpt, sf_pt);
    EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror,wrapup);
#else
    status = BSmdistptsf (&rc, *cm_ed_sfgm, mpt, &sf_uv[0], &sf_uv[1], prj_mpt,
                          &dist);
    EMerr_hndlr (!status || rc != BSSUCC, *EFmsg, EMS_E_BSerror,wrapup);

    for (i = 0; i < 3; i++)
      mv_mpt[i] = prj_mpt[i] + lift_vec[i];

    status = BSmdistptsf (&rc, *cm_ed_sfgm, mv_mpt, &sf_uv[0], &sf_uv[1],
               sf_pt, &dist);
    EMerr_hndlr (!status || rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);
#endif

    if (dist <= dist_tol )
    {
      /*
       * calculate the vector tangent to the curve at its mid
       * point.
       */

      BScvarrevt (cm_ed_oldgm, &mpar, 1, 1.0, (dummy *)&tan_pts[0], &rc);
      EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup );

      for (i = 0; i < 3; i++)
        tan_vec[i] = tan_pts[i+3] - tan_pts[i];
      
      /*
       * calculate the surface normal at the curve's mid
       * point
       */

#if WBC_USE_NEW_MATH
      BSprptarrsf(&geom_surface, dist_tol, 0, 0, &num_pts, prj_mpt, sf_uv,
                  NULL, &onsrf, NULL, &rc);
      EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror,wrapup);
#else
      status = BSprptonsf (&rc, *cm_ed_sfgm, prj_mpt, &sf_uv[0], &sf_uv[1],
                           &onsrf);
      EMerr_hndlr (!status || rc != BSSUCC,*EFmsg,EMS_E_BSerror,wrapup);
#endif

      BSsfarrevn (&rc, *cm_ed_sfgm, 1, &sf_uv[0], 1, &sf_uv[1], tan_pts, 
                  nor_vec);
      EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

      status = BScrossp (&rc, tan_vec, nor_vec, t_c_n_vec);
      EMerr_hndlr (!status || rc != BSSUCC, *EFmsg,EMS_E_BSerror, wrapup);

      if ( BSdotp (&rc, t_c_n_vec, lift_vec) > 0. )
         *overlap_exists = TRUE;

    } /* if (dist <= dist_tol ) */

    wrapup:

      if (geom_surface.sfgen_cv)
        BSfreecv(&rc, geom_surface.sfgen_cv);

      EMWRAPUP (*EFmsg, OM_stat, "EFdoes_new_sf_overlaps_cm_ed_sf");
      return;

  } /* end EFdoes_new_sf_overlaps_cm_ed_sf */


/*
 * Given an edge_info, its surface's geometry before and
 * and after modification, this function performs the following
 * operations:
 *
 * o Create a surface. The type of surface created depends
 *   on the type of edge movement during its surface modification.
 *   If the edge moves linearly as in case of EMS_LIFT_FACE or the
 *   edge being lifted in case EMS_LIFT_EDGE, a surface of projection
 *   is constructed. Otherwise, a ruled surface is constructed as
 *   in case of EMS_LIFT_VERTEX or for edges sharing the end
 *   points of the edge being lifted in EMS_LIFT_EDGE.
 *
 * o Connect the surface to its owner sent by the caller.
 * 
 * o Set the new surface's normal correctly.
 * 
 * o Establish the topology edges v0 and v1.
 *
 * o Display the newly created surface.
 */
extern OMuword OPP_EMSpcone_class_id;
extern OMuword OPP_EMSpcylindr_class_id;

void EFcreate_lft_sf1 (
            EFmsg,
            ed_info,
            ded_info,
            new_ed_GRid,
            owner_GRid,
            ed_old_geom,
            ed_new_geom, 
            sf_old_geom,
            sf_new_geom,
            lift_vec,
            md_env,
            construct_list,
            edv0v1_info, 
            ed_u0s,
            ed_u1s,
            dis_options,
            display_ids,
            display_count,
            owner_index)

   IGRlong                         *EFmsg;
   struct    EMSlft_ed_info        *ed_info;
   struct    EMSdlft_ed_info       *ded_info;
   struct    GRid                  new_ed_GRid, owner_GRid;
   struct    IGRbsp_curve          *ed_old_geom, *ed_new_geom;
   struct    IGRbsp_surface        *sf_old_geom;
   struct    IGRbsp_surface        *sf_new_geom;
   IGRvector                       lift_vec;
   struct    GRmd_env              *md_env;
   struct    EMSlft_edv0v1_info    *edv0v1_info;
   struct    GRvg_construct        *construct_list;
   struct    EMSlft_edmtch_info    *ed_u0s, *ed_u1s;
   IGRushort               dis_options;
   GRobjid                         **display_ids;
   IGRint                          *display_count;
   OMuint                          owner_index;
 {
    struct      IGRbsp_curve     old_geom, new_geom;
    struct      EMSlft_edmtch_info    *ed_mtch_tbl;
    struct      GRid             ed_GRid;
    OM_S_OBJECT_LINKAGE          old_ed_cm_ed;
    OM_S_CHANSELECT              cm_ed_chan;
    IGRdouble                    from_pt[3];
    IGRlong                      OM_stat, mthd_stat, rc;
    IGRboolean                   lsf_pos_orient;
    IGRushort                    edge_props, cm_ed_props, ed_sf_type;
    enum        GRdpmode         DisplayMode;
    IGRint                       i, cur_idx, INITIAL_SIZE, j, 
                                 BUF_INC, array_size, numpleds = 0, 
                                 *numpledsptr = NULL;
    OMuint                       count;
    GRobjid                      lsf_edids[4], lsf_id, ed_id, 
                                 *origed = NULL, **origedptr = NULL, 
                                 *repled = NULL, 
                                 **repledptr = NULL, oldls = NULL_OBJID, 
                                 *oldlsptr = NULL;
    GRspacenum                   cur_os;
    IGRuchar                     ed_cv_type;
    OM_S_OBJID                   new_objid=NULL_OBJID;
    IGRint                       info_bits=0;
    OMuword                      new_classid=0;
    extern     void              EFmemory_allocation();
    struct IGRbsp_surface        *dsf_gm = NULL;


    OM_stat = OM_S_SUCCESS;
    *EFmsg = EMS_S_Success;

    old_geom.poles = new_geom.poles = NULL;
    old_geom.knots = new_geom.knots = NULL;
    old_geom.weights = new_geom.weights = NULL;
    old_geom.bdrys = new_geom.bdrys = NULL;

    if (ed_info)
    {
      ed_GRid = ed_info->ed_GRid;
      ed_sf_type = ed_info->ed_sf_type;
      ed_cv_type = ed_info->ed_cv_type;

    } /* if (ed_info) */
    else
    {
      ed_GRid = ded_info->ed_GRid;
      ed_sf_type = ded_info->ed_sf_type;
      ed_cv_type = ded_info->ed_cv_type;

    } /* if (ed_info) */

    cur_os = ed_GRid.osnum;

    /*
     * The normal of a surface of a solid can be
     * aligned correctly by examining the reverse_connect
     * bit of one of its edges and and the position orient 
     * bit of the common edge's surface.
     *
     * 1. The edge is reverse_connect -- In this case
     *    set the position orient bit the same as 
     *    that of the common edge's surface.
     *
     * 2. The edge is not reverse_connect -- In this case
     *    set the orientation bit opposite to that of 
     *    common edge's surface.
     *
     *    As the old edge will never be reverse_connected 
     *    to its new common edge of the newly constructed
     *    surface (EDGEV1), therefore, the orientation
     *    bit of the new surface will be opposite
     *    to that of the old edge's surface (surface
     *    being geometrically modified.)
     */

    if (sf_old_geom->pos_orient) lsf_pos_orient = 0;
    else lsf_pos_orient = 1;

    if (!ed_old_geom)
    {
      ed_old_geom = &old_geom;

      OM_stat = om$send (msg = message EMSedge.EMget_bcxyz_geom(
                        &mthd_stat, &md_env->md_env, NULL, sf_old_geom,
                        0, OM_K_MAXINT, FALSE, NULL, ed_old_geom ),
                senderid = NULL_OBJID,
                targetid = ed_GRid.objid, targetos = ed_GRid.osnum);
      EMerr_hndlr(!(1&OM_stat&mthd_stat), *EFmsg,EMS_E_EdgeError, wrapup);

    } /* if (!ed_old_geom) */

    /*
     * construct the appropriate type of surface.
     */

    switch (ed_sf_type)
    {
      /*
       * construct the ruled surface using edge's old 
       * and new B-spline definitions.
       */

      case EMS_C_RULED_SF:
          
          if (!ed_new_geom)
          {
            ed_new_geom = &new_geom;
            OM_stat = om$send (msg = message EMSedge.EMget_bcxyz_geom(
                              &mthd_stat, &md_env->md_env, NULL, 
                               sf_new_geom, 0, OM_K_MAXINT, FALSE, NULL, 
                               ed_new_geom ),
                             senderid = NULL_OBJID,
                             targetid = ed_GRid.objid, 
                             targetos = ed_GRid.osnum);
            EMerr_hndlr(!(1&OM_stat&mthd_stat), *EFmsg,EMS_E_EdgeError, wrapup);

          } /* if (!ed_new_geom) */

          OM_stat = om$construct (classid = OPP_EMSgenbs_class_id,
                     p_objid = &lsf_id, osnum = cur_os,
                     msg = message EMSsubbs.EMruled_surface (
                         ed_old_geom, NULL, ed_new_geom, NULL, 0,
                         NULL, NULL, NULL, lsf_pos_orient, 
                         NULL, NULL, FALSE, FALSE,
                         construct_list, &mthd_stat) );
          EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_SurfaceError,wrapup);

          break;


      /*
       * construct the surface of projection using edge's old 
       * B-spline definition and the lift vector.
       */

      case EMS_C_PROJECTED_SF:

        for (i = 0; i < 3; i++) from_pt[i] = 0.;

        OM_stat = om$construct (classid = OPP_EMSproject_class_id,
                p_objid = &lsf_id, osnum = cur_os,
                msg = message EMSproject.EMplace_surface_of_projection (
                 construct_list, NULL, md_env, ed_old_geom,
                 ed_cv_type, from_pt, 
                 lift_vec, lsf_pos_orient, &lsf_id));
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_SurfaceError,wrapup);

        break;

      /*
       * Create a drafted surface using the edge's old and
       * new geometries.
       */

      case EMS_C_DRAFTED_SF:

           /*
            * We only want to come in here if we are creating or 
            * recomputing a post-220 object.  
            */
           if ( WANT_POST220_BEHAVIOR )
            {
            /*
             * Let's try and found out if any analytic surface will be 
             * created by creating a ruled surface from the input curve.
             */
            info_bits = 0;  /* no input bits set */
            new_objid = NULL_OBJID;
            
            EFget_analytic_info(&mthd_stat,              /* EMmsg */
                                 ded_info->draft_angle,  /* draft_angle */
                                 NULL,                   /* curve_id */
                                 NULL,                   /* curve_env */ 
                                 ed_new_geom,            /* curve_geom */
                                 ded_info->ed_cv_type,   /* curve_type */
                                 lift_vec,               /* axis */
                                 0.0,                    /* rev_angle */
                                 cur_os,                 /* const_os */
                                &new_classid,            /* new_classid */
                                &new_objid,              /* new_obj */
                                &info_bits);             /* info_bits */
            }
           else new_objid = NULL_OBJID;

make_surf:
            if(new_objid == NULL_OBJID)
              /*
               * Construct and define the general surface if there was
               * no analytic surface possible.
               */
              OM_stat = om$construct(classid =  OPP_EMSgenbs_class_id,
                                     osnum   =  cur_os,
                                     p_objid = &lsf_id);
            else
              lsf_id = new_objid;


        OM_stat = om$send ( msg = message EMSsubbs.EMdrafted_surface( &mthd_stat,
                        ed_old_geom, NULL, ed_new_geom, lift_vec,
                        ded_info->draft_angle, NULL, NULL, 
                        ded_info->ed_cv_type, lsf_pos_orient, &lsf_id,
                        construct_list),
                        senderid = NULL_OBJID,
                        targetid = lsf_id,
                        targetos = cur_os );
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_SurfaceError,wrapup);

        /* Partial cone validation.
           SM 16-Sept-93.

           Additional class check to make sure the surface is not a partial
           cylinder since EMSpcylndr is subclassed from EMSpcone (TR#119311557).
           WBC 11-Nov-93.
        */
       if(WANT_POST220_BEHAVIOR && EFisAncestryValid(&mthd_stat, lsf_id, 
          cur_os, OPP_EMSpcone_class_id, TRUE) &&
          ! EFisAncestryValid(&mthd_stat, lsf_id, cur_os,
                              OPP_EMSpcylindr_class_id, TRUE))
        {
         struct BSgeom_bsp_surf junk;
         extern void EFinit_geom_surface();
         struct GRid more_junk;
         BSrc   some_more_junk;

         /* Get surface geom.
         */
         if(dsf_gm) om$dealloc(ptr = dsf_gm);
         dsf_gm = NULL;
     
         more_junk.objid = lsf_id;
         more_junk.osnum = cur_os;
         OM_stat = EMgetvggeom(&mthd_stat, 
                            &md_env->md_env.matrix_type, 
                            md_env->md_env.matrix, &more_junk, 
                            &dsf_gm, NULL);
         EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg, EMS_E_SurfaceError,wrapup);

         /* Initialize BS geometric structure.
         */
         junk.sfgen_cv = NULL;
         EFinit_geom_surface(&mthd_stat, dsf_gm, lsf_id, cur_os, &junk);
         EMerr_hndlr(!(1&mthd_stat),*EFmsg, EMS_E_SurfaceError,wrapup);

         (void) BSsftgeomsf(&junk, FALSE, BSPART_CONE, &some_more_junk);
         EMerr_hndlr(some_more_junk!=BSSUCC,*EFmsg, EMS_E_SurfaceError,wrapup);

         if(junk.type != BSPART_CONE)
          {
           OM_stat = om$send(msg = message GRgraphics.GRdelete(&mthd_stat, 
                  md_env), targetid = lsf_id, senderid = lsf_id);
           EMerr_hndlr(!(1&OM_stat&mthd_stat), *EFmsg, EMS_E_SurfaceError,
                       wrapup);
           lsf_id = NULL_OBJID;
           new_objid = NULL_OBJID;
           goto make_surf;
          }
        }
        
      break;

      default:

         *EFmsg = EMS_E_InvalidArg;
         goto wrapup;

    } /* switch (ed_sf_type) */

    /*
     * make a natural boundary for new surface
     */

   OM_stat = om$send (msg = message EMSsurface.EMmk_nat_bdry (&mthd_stat,
                        &md_env->md_env, lsf_edids),
                       senderid = NULL_OBJID,
                       targetid = lsf_id, targetos = cur_os);
   EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_SurfaceError, wrapup);

   /* See if the new surface can be converted into a plane. If it gets
      converted then replace the original natural edges in lsf_edids array
      with their new counterpart. THIS IS IMPORTANT SO AS NOT TO AFFECT
      THE SUBSEQUENT TOPOLOGY CODE.

      SM 29-May-92.
   */



   /* Convert into plane only if not already a plane. 09/14/92  AMD */

   if(!EFisAncestryValid(&mthd_stat, lsf_id, cur_os,
              OPP_EMSplane_class_id, FALSE) && _sm_convert_into_plane)
    {
     origedptr = &origed;
     repledptr = &repled;
     numpledsptr = &numpleds;
     oldlsptr = &oldls;
     OM_stat = EMconvert_into_plane(&mthd_stat, NULL, NULL, NULL, &origedptr, 
               &repledptr, &numpledsptr, &oldlsptr, md_env, lsf_id, cur_os);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_SurfaceError,wrapup);

     if(mthd_stat == EMS_S_Success)
      {
       IGRboolean found = FALSE;

       for(i=0; i<4; i++)
        {
	 found = FALSE;
         for(j=0; j<numpleds; j++)
          {
           if(IF_EQ_OBJID(lsf_edids[i], origed[j]))
            {
             lsf_edids[i] = repled[j];
             found = TRUE;
             break;
            }
          }
         if(!found) lsf_edids[i] = NULL_OBJID;
        }
      }
     if(!IF_NULL_OBJID(oldls))
      {
       om$send(msg = message Root.delete(TRUE), targetid = oldls, 
              senderid = oldls);
       oldls = NULL_OBJID;
      }
    }

    if (dis_options & EMS_DO_DISPLAY)
    {
      if (dis_options & EMS_DONT_REDRAW)
      {
        /*Add the surface to the list.*/
        OM_stat = EFwork_the_display(&mthd_stat, dis_options, lsf_id,
                                     display_ids, display_count, NULL);
        if (!(1 & OM_stat & mthd_stat)) goto wrapup;                  
      }
      else
      {
        /*
         * display the newly created surface
         */
    
        DisplayMode = GRbd;
        OM_stat = om$send (msg = message GRgraphics.GRdisplay (&mthd_stat,
                            &md_env->md_env.matrix_type,
                             md_env->md_env.matrix, &DisplayMode,
                            &md_env->md_id),
                           senderid = NULL_OBJID,
                           targetid = lsf_id, targetos = cur_os);
        EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_SurfaceError,wrapup);
      }
    }

   /*
    * connect the new surface to the owner(local mod object)
    */

   OM_stat = om$send (msg = message GRconnector.GRrigidconn (&mthd_stat,
                       &owner_GRid, (IGRlong *) &owner_index),
                      senderid = NULL_OBJID,
                      targetid = lsf_id, targetos = cur_os);
   EMerr_hndlr(!(1&OM_stat),*EFmsg,EMS_E_SurfaceError,wrapup);

   /*
    * the old_edge (or its new version, new_ed_GRid. if the caller 
    * sends one) wiil be common to (v = 1) edge of the new
    * surface. and the common edge of the the old_edge will
    * be common to the (v = 0) of the new surface.
    * The reverse_connect edge property can be obtained
    * without making any evaluations.
    * The logic as follows:
    *
    *   1. If the old edge was not reverse_connected to its 
    *      common edge, the old edge will not be reverse_connect 
    *      to its new common edge i.e., (v = 1) edge of the 
    *      new surface. And the its old common edge will be 
    *      reverse_connect to its new common edge i.e., (v = 0) 
    *      edge of the new surface.
    * 
    *   2. If the old edge was reverse_connected to its common edge, the
    *      old edge as well its old common edge will not be 
    *      reverse_connect to their respective common edges of the
    *      new surface.
    */

    OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &cm_ed_chan);
    EMerr_hndlr(!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup); 

    old_ed_cm_ed.S_objid = NULL_OBJID;

    if (!IF_NULL_OBJID(ed_GRid.objid))
    {
      OM_stat = om$get_channel_objects(objid = ed_GRid.objid,
                 osnum = cur_os, p_chanselect = &cm_ed_chan,
                 list = &old_ed_cm_ed, size = 1, count = &count);
      EMerr_hndlr(!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup); 
      EMerr_hndlr(count != 1,*EFmsg,EMS_E_InvalidArg,wrapup);

      OM_stat = om$send(msg = message Root.wild_disconnect(cm_ed_chan),
                 senderid = NULL_OBJID,
                 targetid = ed_GRid.objid, targetos = cur_os);
      EMerr_hndlr(!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup); 

    } /* if (!IF_NULL_OBJID(ed_GRid.objid)) */

    /*
     * connect the edge(ed_id or new_ed_id) to its new common edge
     * (lsf_edids[EDGEV1])
     */
    
    if ( !IF_NULL_OBJID(new_ed_GRid.objid) ) 
    {
      OM_stat = om$send (msg = message EMSedge.EMget_props(
                          &mthd_stat, &edge_props),
                         senderid = NULL_OBJID,
                         targetid = new_ed_GRid.objid,
                        targetos = cur_os);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

      if (edge_props & EMED_XYZ_CLOSED)
      {
        cm_ed_props = EMED_XYZ_CLOSED;
        OM_stat = om$send (msg = message EMSedge.EMset_props(
                            &mthd_stat, cm_ed_props, EMS_O_ON),
                      senderid = NULL_OBJID,
                      targetid = lsf_edids[EDGEV1],
                      targetos = cur_os);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);
      }

      OM_stat = om$send (msg = message EMSedge.EMconnect_edges (
                          &mthd_stat, FALSE, FALSE, lsf_edids[EDGEV1],
                           NULL_OBJID, NULL_OBJID, &md_env->md_env),
                         senderid = NULL_OBJID,
                         targetid = new_ed_GRid.objid,
                         targetos = cur_os);
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

    } /* if ( !IF_NULL_OBJID(new_ed_GRid.objid) ) */

    /*
     * connect the old edge's common edge (if any) to the (v=0) edge
     * of the new surface
     */

    if (!IF_NULL_OBJID(old_ed_cm_ed.S_objid))
    {
      OM_stat = om$send (msg = message EMSedge.EMget_props(
                          &mthd_stat, &edge_props),
                        senderid = NULL_OBJID,
                        targetid = old_ed_cm_ed.S_objid,
                        targetos = old_ed_cm_ed.osnum);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

      if (edge_props & EMED_XYZ_CLOSED)
      {
        cm_ed_props = EMED_XYZ_CLOSED;
        OM_stat = om$send (msg = message EMSedge.EMset_props(
                            &mthd_stat, cm_ed_props, EMS_O_ON),
                      senderid = NULL_OBJID,
                      targetid = lsf_edids[EDGEV0],
                      targetos = cur_os);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);
      }

      cm_ed_props = 0;
      if (!( edge_props & EMED_REVERSE_CONNECT)) 
        cm_ed_props |= EMED_REVERSE_CONNECT;

      OM_stat = om$send (msg = message EMSedge.EMconnect_edges (
                          &mthd_stat, cm_ed_props, FALSE, 
                           lsf_edids[EDGEV0], NULL_OBJID, NULL_OBJID, 
                          &md_env->md_env),
                    senderid = NULL_OBJID,
                    targetid = old_ed_cm_ed.S_objid,
                    targetos = old_ed_cm_ed.osnum);
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

      {

      /* Maintain the dominant properties as before  AMD : 03/10/93 */

      if (!( edge_props & EMED_SUBORDINATE))
       {
        OM_stat = om$send (msg = message EMSedge.EMset_props(
                           &mthd_stat, EMED_SUBORDINATE, EMS_O_ON),
                      senderid = NULL_OBJID,
                      targetid = lsf_edids[EDGEV0],
                      targetos = cur_os);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

        OM_stat = om$send (msg = message EMSedge.EMset_props(
                           &mthd_stat, EMED_SUBORDINATE, EMS_O_OFF),
                      senderid = NULL_OBJID,
                      targetid = old_ed_cm_ed.S_objid,
                      targetos = cur_os);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

       }
      else
       {
        OM_stat = om$send (msg = message EMSedge.EMset_props(
                           &mthd_stat, EMED_SUBORDINATE, EMS_O_OFF),
                      senderid = NULL_OBJID,
                      targetid = lsf_edids[EDGEV0],
                      targetos = cur_os);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

        OM_stat = om$send (msg = message EMSedge.EMset_props(
                           &mthd_stat, EMED_SUBORDINATE, EMS_O_ON),
                      senderid = NULL_OBJID,
                      targetid = old_ed_cm_ed.S_objid,
                      targetos = cur_os);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);
       }
      
      }
    } /* if (!NULL_OBJID(old_ed_cm_ed.S_objid)) */

     /*
      * save the above performed reestablishing of the topology.
      * This is done by storing the edge objids in ids[] vla.
      * These edge ids are saved in a predetermined way, so as
      * to facilitate the undo process. The edge ids are saved
      * in the following manner:
      *
      *        ids[1]  ---- old_ed1
      *        ids[2]  ---- old_ed1_old_cm_ed
      *        ids[3]  ---- old_ed1_new_cm_ed
      *        ids[4]  ---- old_edg1_old_cm_ed's_cm_ed
      *        ids[5]  ---- old_ed2
      *        ids[6]  ---- old_ed2_cm_ed
      *        ids[7]  ---- old_ed2_new_cm_ed
      *        ids[8]  ---- old_ed2_cm_ed's_new_cm_ed
      *                                         .
      *                                         .
      *                                         .
      *                                         .
      */

    if (!IF_NULL_OBJID(ed_GRid.objid))
    {
      cur_idx = (edv0v1_info->num_eds) * 4;
      edv0v1_info->ed_ids[cur_idx] = ed_GRid.objid;
      edv0v1_info->ed_ids[cur_idx+1] = old_ed_cm_ed.S_objid;
      edv0v1_info->ed_ids[cur_idx+2] = 
          (new_ed_GRid.objid == ed_GRid.objid) ? lsf_edids[EDGEV1] :
                                                 NULL_OBJID;
      edv0v1_info->ed_ids[cur_idx+3] = lsf_edids[EDGEV0];
      (edv0v1_info->num_eds)++;

    } /* if (!IF_NULL_OBJID(ed_GRid.objid)) */
   
   /*
    * save ed_u0s and ed_u1s for edge matching if they
    * are not degenerate.
    */

   INITIAL_SIZE = 10;
   BUF_INC = 10;
  
   for (i = 0; i < 2; i++)
   {
     ed_id = i ? lsf_edids[EDGEU1] : lsf_edids[EDGEU0];

     if(ed_id == NULL_OBJID) continue;

     OM_stat = om$send (msg = message EMSedge.EMget_props(
                       &mthd_stat, &edge_props),
                     senderid = NULL_OBJID,
                     targetid = ed_id,
                     targetos = cur_os);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

     if (!( (edge_props & EMED_DEGENERATE) || (edge_props & EMED_SEAM) ))
     {  
        ed_mtch_tbl = i ? ed_u1s : ed_u0s;

        array_size = ed_mtch_tbl->array_size;
        EFmemory_allocation (&rc, (IGRchar **) &ed_mtch_tbl->ed_ids, 
                              1, &array_size, 
                              sizeof(GRobjid), INITIAL_SIZE, BUF_INC);
        EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_NoDynamicMemory,wrapup);

        EFmemory_allocation (&rc, (IGRchar **) &ed_mtch_tbl->sf_ids, 
                              1, &ed_mtch_tbl->array_size, 
                             sizeof(GRobjid), INITIAL_SIZE, BUF_INC);
        EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_NoDynamicMemory,wrapup);

        ed_mtch_tbl->ed_ids[0] = ed_id;
        ed_mtch_tbl->sf_ids[0] = lsf_id;
        (ed_mtch_tbl->num_eds)++;

     } /* if (!( (edge_props & EMED_DEGENERATE) || 
                 (edge_props & EMED_SEAM) )) */

   } /* for (i = 0; i < 2; i++) */
   
   wrapup:
 
    EMWRAPUP (*EFmsg, OM_stat, "In EFcreate_lft_sf");

    if (old_geom.poles) om$dealloc (ptr = old_geom.poles);
    if (old_geom.knots) om$dealloc (ptr = old_geom.knots);
    if (old_geom.weights) om$dealloc (ptr = old_geom.weights);
    if (old_geom.bdrys) om$dealloc (ptr = old_geom.bdrys);
    if (new_geom.poles) om$dealloc (ptr = new_geom.poles);
    if (new_geom.knots) om$dealloc (ptr = new_geom.knots);
    if (new_geom.weights) om$dealloc (ptr = new_geom.weights);
    if (new_geom.bdrys) om$dealloc (ptr = new_geom.bdrys);
    if(origed) om$dealloc(ptr = origed);
    if(repled) om$dealloc(ptr = repled);
    if(dsf_gm) om$dealloc(ptr = dsf_gm);

    if(!IF_NULL_OBJID(oldls))
     OM_stat = om$send(msg = message Root.delete(TRUE), targetid = oldls, 
               senderid = oldls);

    return;
 
} /* end  EFcreate_lft_sf */

/*
 * The following function trims the common edges' surface with
 * boundary of the surface to be created in lifting an edge.
 * Actually, a new surface is not created but its boundary
 * is extracted by using the geometries of the edge corresponding
 * to its orginal and modified surface.
 */

#argsused
void EFtrim_cm_ed_sf1 (
            EFmsg,
            ed_info,
            ded_info,
            new_ed_GRid,
            ed_sf_GRid,
            ed_new_sf_GRid,
            sf_new_geom,
            ed_new_geom,
            lift_vec,
            cm_ed_GRid,            
            cm_ed_sf_GRid,
            cm_ed_sfgm,
            cm_ed_oldgm,
            md_env,
            ed_u0s,
            ed_u1s,
            last_ed_u1s, 
            next_ed_u0s, 
            ed_v0v1_info,
            ed_sp_info,
            lps_mod_info,
            ed_cn_info,
            sfrmvd_info,
            dis_options,
            display_ids,
            display_count)

  IGRlong                       *EFmsg;
  struct     EMSlft_ed_info     *ed_info;
  struct     EMSlft_ed_info     *ded_info;
  struct     GRid               new_ed_GRid, ed_new_sf_GRid, 
                                cm_ed_GRid, 
                                cm_ed_sf_GRid, ed_sf_GRid;
  struct     IGRbsp_surface     *sf_new_geom, *cm_ed_sfgm;
  IGRvector                     lift_vec;
  struct     IGRbsp_curve       *ed_new_geom, *cm_ed_oldgm;
  struct     GRmd_env           *md_env;
  struct     EMSlft_edmtch_info *ed_u0s, *ed_u1s, *last_ed_u1s,
                                *next_ed_u0s;
  struct     EMSlft_edv0v1_info *ed_v0v1_info;
  struct     EMSlft_edsp_info   *ed_sp_info;
  struct     EMSlft_lpmod_info  *lps_mod_info;
  struct     EMSlft_edcn_info   *ed_cn_info;
  struct     EMSlft_sfrmvd_info *sfrmvd_info;
  IGRushort             dis_options;
  GRobjid                       **display_ids;
  IGRint                        *display_count;

{
  OM_S_CHANSELECT               lp_ed_chan, sf_ls_chan, cm_ed_chan,
                                to_owners_chan, to_comps_chan, ed_lp_chan;
  OM_S_OBJECT_LINKAGE           ls_list;
  struct EMSptloc_info          pt_loc;
  struct EMSpartolbasis         partolbasis;
  struct IGRbsp_curve           new_geom, beg_pt_lineseg, 
                                end_pt_lineseg, *cm_ed_newgm, 
                                *lp_cvs[3];
  struct EMSsfintedpar          **trim_info, **against_bdrys, **lp_bdrys,
                                **out_bdrys, split_info, 
                                *split_info_ptr[2];
  
  struct EMSownercomp           *lps_rmvd;
  struct EMSlft_edmtch_info     reject_list, new_cm_eds, old_ed_tbl;
  struct GRid                   ed_GRid, clip_ls, sf_owner_GRid;
  struct EMSnest_info           nesting;
  enum   GRdpmode               DisplayMode;

  IGRdouble                     beg_pts[6], end_pts[6], beg_knots[4], 
                                end_knots[4], distsq_tol, 
                                cm_ed_ngm_pts[4], cm_ed_end_pts[4],
                                ed_end_pts[4],
                                *cm_ed_tst_pt, lp_end_pt[2];

  IGRmatrix                     mat;

  IGRlong                       OM_stat, mthd_stat, rc;

  IGRint                        i, j, num_ed_sp_eds, 
                                num_imp_lps, num_lp_cvs, ed_idx, 
                                *num_bdrys, uv_type,
                                array_size, num_new_lps, depth, 
                                num_sfs = 0, stat,  
                                num_part_eds, cur_ed, num_ls_sp_eds = 0,
                                cur_ls_sp_ed, cur_ed_sp_ed, 
                                cur_idx, blksize, 
                                INITIAL_SIZE, BUF_INC, num_elems,
                                ed_u0s_inx[2], ed_u1s_inx[2], num_lps, 
                                buf_size, from_inx, cur_csf,
                                sf_inx, lp_inx, num_lps_in, num_lps_out,
                                cur_lp_rmvd, to_inx;

  OMuint                        cm_ed_inx, num_rev_lp_eds, 
                                cm_ed_ngm_end_inx[2],
                                new_num_rev_lp_eds, num_cm_ed,
                                composite_idx, new_ed_inx, count;
   
  extern IGRint                 EMsend_loops();

  IGRboolean                    status, valid_end_pts_lineseg[2], good_ed,
                                ed_exists, world_flag, compsf_exists,
                                sf_is_plane = FALSE, sf_exists, lp_exists,
                                extract_lp = TRUE, comm_sf_erased = FALSE;


  OMuword                       cm_ed_sf_classid;
  GRspacenum                    cur_os, dum_os;
  GRobjid                       *imp_lp_id, cm_ed_ngm_id, rev_lp_id, 
                                ed_sp_eds[2], *new_lps_added, *work_ids,
                                *ls_sp_eds, ed_id, *lp_ids, *trim_lps,
                                *lps_in_ptr, *lps_out_ptr, dum_eds[4],
                                cp_ed, lp_id;


  IGRushort             cm_ed_props, options, ed_sf_type,
                                rev_lp_props, lp_props;
  IGRshort                      mat_type, rev_lp_md;

  IGRuchar              ed_cv_types[3], cm_ed_cv_type,
                                ed_cv_type;

  extern void                   EFed_match(), EFcollect_eds(), 
                                EFcollect_ed_split_info(),
                                EFmemory_allocation(), EMget_sp_edges(),
                                EFmake_curve_with_2pts(),
                                EFfix_the_trim_info(),
                                EFfix_ed_geometry(), EFfix_mapped_data();

/* ********************************************************* */

  OM_stat = OM_S_SUCCESS;
  *EFmsg = EMS_S_Success;
  cur_os = cm_ed_GRid.osnum;
  split_info_ptr[0] = &split_info;
  split_info_ptr[1] = NULL;
  split_info.info = NULL;
  split_info.next = NULL;


  if (ed_info)
  {
    ed_GRid = ed_info->ed_GRid;
    ed_sf_type = ed_info->ed_sf_type;
    ed_cv_type = ed_info->ed_cv_type;

  } /* if (ed_info) */
  else
  {
    ed_GRid = ded_info->ed_GRid;
    ed_sf_type = ded_info->ed_sf_type;
    ed_cv_type = ded_info->ed_cv_type;

  } /* else for if (ed_info) */


  new_geom.poles = new_geom.knots = NULL;
  new_geom.weights = new_geom.bdrys = NULL;

  imp_lp_id = NULL;
  trim_info = lp_bdrys = against_bdrys = out_bdrys = NULL;
  lps_rmvd = NULL;
  new_cm_eds.num_eds = 0;
  new_cm_eds.array_size = 0;
  new_cm_eds.ed_ids = NULL;
  new_cm_eds.sf_ids = NULL;
  new_lps_added = NULL;
  work_ids = NULL;
  ls_sp_eds = NULL;
  lp_ids = NULL;
  trim_lps = NULL;
  num_bdrys = NULL;

  { /*INTENTIONAL BLOCK*/
    IGRboolean dont_have_it;
 
    OM_stat = EFwork_the_display(&mthd_stat, dis_options,
                                 cm_ed_sf_GRid.objid,
                                 display_ids, display_count,
                                 &dont_have_it);
    if (!(1 & OM_stat & mthd_stat)) goto wrapup;

    if (dont_have_it)
    {
      /*
       * Erase the common edge's surface.
       */
      DisplayMode = GRbe;
      OM_stat = om$send (msg = message GRgraphics.GRdisplay (&mthd_stat,
                           &md_env->md_env.matrix_type,
                           md_env->md_env.matrix, &DisplayMode,
                           &md_env->md_id),
                         senderid = NULL_OBJID,
                         targetid = cm_ed_sf_GRid.objid, 
                         targetos = cm_ed_sf_GRid.osnum);
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_SurfaceError,wrapup);
      comm_sf_erased = TRUE;
    }
  }

  world_flag = TRUE;
  OM_stat = om$send (msg = message EMSsubbs.EMpartolbasis (&mthd_stat,
                      &md_env->md_env.matrix_type, md_env->md_env.matrix,
                      &world_flag, FALSE, &partolbasis.tol),
                     senderid = NULL_OBJID,
                     targetid = cm_ed_sf_GRid.objid, 
                     targetos = cm_ed_sf_GRid.osnum);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_SurfaceError,wrapup);

  partolbasis.in_world = partolbasis.is_valid = TRUE;
  partolbasis.mattyp = &md_env->md_env.matrix_type;
  partolbasis.mat = md_env->md_env.matrix;

  OM_stat=EMmake_chanselect (EMSedge_to_common_edge, &cm_ed_chan);
  EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

  OM_stat = EMmake_chanselect (EMSbd_owner_to_comps, &lp_ed_chan);
  EMerr_hndlr (!(1&OM_stat),*EFmsg, EMS_E_OMerror, wrapup);

  OM_stat = EMmake_chanselect (EMSsubbs_to_loopset, &sf_ls_chan);
  EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

  /*
   * save begin and end points of the cm_ed_old_geometry.
   * They will be used in constructing line segments. Since
   * the geometry is used to create a loop to close the
   * cm_ed_sf loopset in the reverse direction, the geometry
   * of the edge will be reversed to construct the loop.
   * This will necessitate flipping of the begin and end points
   * as the cm_ed_oldgm is in its logical direction.
   */

  OM_stat = om$send (msg = message EMSedge.EMget_props_type (&mthd_stat,
                          &cm_ed_props, &cm_ed_cv_type),
                         senderid = NULL_OBJID,
                         targetid = cm_ed_GRid.objid,
                         targetos = cm_ed_GRid.osnum);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg, EMS_E_EdgeError,wrapup);

  if (!(cm_ed_props & EMED_XYZ_CLOSED))
  {
    BScveval (cm_ed_oldgm, 0., 0, (IGRpoint *)&end_pts[3], &rc);
    EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup );
  
    BScveval (cm_ed_oldgm, 1., 0, (IGRpoint *)&beg_pts[0], &rc);
    EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup );
  
  } /* if (!(cm_ed_props & EMED_XYZ_CLOSED)) */

  /*
   * Get the geomtery of the modified edge.
   * If the new surface to be constructed is a surface of 
   * projectoion, it can be obtained by translating the old_geom by
   * by lift vector. Otherwise, the geomtery of the edge corresponding
   * to its modified surface will have to be obtained. And then
   * it has to be reversed if the the edge is not reverse_connect to
   * its common edge in order to get the geometry in the direction
   * opposite to its logical direction.
   */

  switch (ed_sf_type)
  {

    case EMS_C_PROJECTED_SF:

     status = MAtrlmx (&rc, lift_vec, mat);
     EMerr_hndlr (!status || !(1&rc),*EFmsg,EMS_E_Fail,wrapup);

     if (cm_ed_oldgm->rational)
     {
       for (i = 0; i < cm_ed_oldgm->num_poles; i++)
        for (j = 0; j < 3; j++)
          cm_ed_oldgm->poles[3*i+j] /= cm_ed_oldgm->weights[i];
     }

     status = MAtypemx (&rc, mat, &mat_type);
     EMerr_hndlr (!status || !(1&rc), *EFmsg, EMS_E_Fail, wrapup);

     status = MAoptsxform (&rc, &cm_ed_oldgm->num_poles, &mat_type,
                            mat, cm_ed_oldgm->poles, cm_ed_oldgm->poles);
     EMerr_hndlr (!status || !(1&rc),*EFmsg,EMS_E_Fail,wrapup);

     if (cm_ed_oldgm->rational)
     {
       for (i = 0; i < cm_ed_oldgm->num_poles; i++)
        for (j = 0; j < 3; j++)
          cm_ed_oldgm->poles[3*i+j] *= cm_ed_oldgm->weights[i];
     }
     cm_ed_newgm = cm_ed_oldgm;
     
     status = BSrev_cv (&rc, cm_ed_newgm);
     EMerr_hndlr(!status || rc != BSSUCC,*EFmsg,EMS_E_BSerror,wrapup);
  
     break;

    /*
     * If the surface to be created is a ruled surface, its
     * boundaries are created in the following way.
     *
     *  o get the geometry of the edge w.r.t the modified 
     *    surface. 
     *  o Since the loop is used for reverse close, it is
     *    therfore needed to get the new_geom in a direction
     *    opposite to that of logical direction of common
     *    edge. Thus, reverse the geometry if it is not 
     *    reverse_connect to its common edge.
     */

    case EMS_C_RULED_SF:

      if (!ed_new_geom)
      {
        ed_new_geom = &new_geom;
        OM_stat = om$send (msg = message EMSedge.EMget_bcxyz_geom (
                        &mthd_stat, &md_env->md_env, NULL,
                         sf_new_geom, NULL, MAXINT, FALSE, NULL,
                         ed_new_geom),
                       senderid = NULL_OBJID, 
                       targetid = ed_GRid.objid, 
                       targetos = ed_GRid.osnum);
        EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg, EMS_E_EdgeError,wrapup);
      
      } /* if (!ed_new_geom) */

      if (!(cm_ed_props & EMED_REVERSE_CONNECT ))
      {
         status = BSrev_cv (&rc, ed_new_geom);
         EMerr_hndlr(!status || rc != BSSUCC,*EFmsg,EMS_E_BSerror,wrapup);
      }
      cm_ed_newgm = ed_new_geom;

      break;

    /*
     * If the surface to be created is drafted surface, its
     * boundaries are created in the following way.
     *
     *  o use the new geometry of the edge sent by the caller.  
     *  o Since the loop is used for reverse close, it is
     *    therfore needed to get the new_geom of the common edge
     *    in a direction
     *    opposite to that of logical direction of common
     *    edge. Thus, reverse the geometry if it is not 
     *    reverse_connect to its common edge.
     */

    case EMS_C_DRAFTED_SF:

      if (!(cm_ed_props & EMED_REVERSE_CONNECT ))
      {
         status = BSrev_cv (&rc, ed_new_geom);
         EMerr_hndlr(!status || rc != BSSUCC,*EFmsg,EMS_E_BSerror,wrapup);
      }
      cm_ed_newgm = ed_new_geom;

      break;

    default:
       *EFmsg = EMS_E_InvalidArg;
       goto wrapup;

  } /* switch (ed_sf_type) */

  /*
   * Now the geometry of the edge corresponding to the
   * modified surface and in the direction opposite to that of  
   * common edge's logical direction is available. Next step is to
   * create the valid loop using this geometry,
   * the line segments (if any ) using the 
   * begin and end points of the original and
   * modified geometries of the common edge.
   */

   if (!(cm_ed_props & EMED_XYZ_CLOSED))
   {   
     BScveval (cm_ed_newgm, 0., 0, (IGRpoint *)&beg_pts[3], &rc);
     EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup );
  
     BScveval (cm_ed_newgm, 1., 0, (IGRpoint *)&end_pts[0], &rc);
     EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup );
  
   } /* if (!(cm_ed_props & EMED_XYZ_CLOSED)) */

    valid_end_pts_lineseg[0] = valid_end_pts_lineseg[1] = TRUE;

    /*
     * If a loop's boundary is for a ruled surface,
     * one of line_segments will be degenerate.
     * find out which one is it.
     */

    if (ed_sf_type == EMS_C_RULED_SF)
    {
       status = BSEXTRACTPAR (&rc, BSTOLSQLENVEC, distsq_tol);

       if ( BSdistptpts (&rc, beg_pts, &beg_pts[3]) <= distsq_tol )
            valid_end_pts_lineseg[0] = FALSE;

       if ( BSdistptpts (&rc, end_pts, &end_pts[3]) <= distsq_tol )
            valid_end_pts_lineseg[1] = FALSE;

    } /* if (ed_sf_type == EMS_C_RULED_SF) */

    /*
     * If the loop bounadry is for a surface of projection or drafted
     * surface and the edge is closed in model space, the beg_pt_lineseg
     * and end_pt_lineseg will be overlaping the seam edges of
     * the surface and will be trimmed completely.
     */

    if ( (ed_sf_type == EMS_C_PROJECTED_SF ||
          ed_sf_type == EMS_C_DRAFTED_SF )   && 
        (cm_ed_props & EMED_XYZ_CLOSED) )
      valid_end_pts_lineseg[0] = valid_end_pts_lineseg[1] = FALSE;

    /*
     * In order to get the loop in correct direction w.r.t
     * common edge's surface, the edge and linesegments 
     * should be placed in the following order:
     *
     * 1. line segment between the old_beg_pt and new_beg_pt.
     * 2. the cm_ed_newgm
     * 3. linesegment between new_end_pt and old_end_pt.
     *
     * Note that one or both line segments may be omitted
     * due to degeneracy or the due the edge being closed in
     * model space.
     */

    OM_stat = om$get_classid (objid = cm_ed_sf_GRid.objid,
             osnum = cm_ed_sf_GRid.osnum, p_classid = &cm_ed_sf_classid);
    EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

    OM_stat = om$is_ancestry_valid (subclassid = cm_ed_sf_classid,
                                    superclassid = OPP_EMSplane_class_id);
    if (OM_stat == OM_S_SUCCESS) sf_is_plane = TRUE;

    num_lp_cvs = 0;

    if (valid_end_pts_lineseg[0])
    {
      EFmake_curve_with_2pts (&rc, &beg_pt_lineseg, beg_pts,
                               beg_knots);
      EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_Fail,wrapup);
  
      if (sf_is_plane) 
         ed_cv_types[num_lp_cvs] = EMlinesegment;
      else
         ed_cv_types[num_lp_cvs] = EMlinestring;

      lp_cvs[num_lp_cvs++] = &beg_pt_lineseg;

    } /* if (beg_pt_lineseg) */
    
    if (sf_is_plane) 
      ed_cv_types[num_lp_cvs] = cm_ed_cv_type;
    else
      ed_cv_types[num_lp_cvs] = EMlinestring;

    lp_cvs[num_lp_cvs++] = cm_ed_newgm;
    
    if (valid_end_pts_lineseg[1])
    {
      EFmake_curve_with_2pts (&rc, &end_pt_lineseg, end_pts,
                              end_knots);
      EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_Fail,wrapup);
  
      if (sf_is_plane) 
         ed_cv_types[num_lp_cvs] = EMlinesegment;
      else
         ed_cv_types[num_lp_cvs] = EMlinestring;

      lp_cvs[num_lp_cvs++] = &end_pt_lineseg;
 
    } /* if (beg_pt_lineseg) */

    /*
     * Map the above constructed model space loop on
     * to the common edge's surface. The model
     * space loop is linked in the correct logical direction,
     * is within the bounds of the surface and will
     * close with respect to boundaries (natural/imposed).
     * Therefore, No tracing, cliping, fixing or validation 
     * is needed.
     */

    OM_stat = om$get_channel_objects (osnum = cm_ed_sf_GRid.osnum,
                  objid = cm_ed_sf_GRid.objid, 
                  p_chanselect = &sf_ls_chan, list = &ls_list,
                  size = 1, count = &count);
    EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);
    EMerr_hndlr (count != 1, *EFmsg,EMS_E_InvalidArg,wrapup);

    clip_ls.objid = ls_list.S_objid;
    clip_ls.osnum = ls_list.osnum;

    options = NULL | EMMapBnd_WantBadCurves | EMMapBnd_StrokeIfNeeded |
              /*EMMapBnd_NoClip |*/ EMMapBnd_NoRmvColEds |
              EMMapBnd_NoValidate | EMMapBnd_NoCurveType | 
              EMMapBnd_ClipBdryArea |
              (sf_is_plane ? EMMapBnd_SurfIsPlane : NULL);

    /*clip_ls.objid = NULL_OBJID;*/
    {
     struct EMSgetlp_output		junk;
     struct EMSgetlp_planar_info	planar_info;

     junk.num_objs = 0;
     junk.objs = NULL;
     planar_info.edge_types = ed_cv_types;
     planar_info.curve_info = NULL;
     planar_info.out_edges = NULL;
     planar_info.num_out_edges = NULL;

     stat = EMget_mapped_data( num_lp_cvs, lp_cvs, NULL,
             NULL, cm_ed_sfgm, &partolbasis.tol, md_env,
             NULL, NULL, &junk, NULL, clip_ls,
             options, &planar_info, &rc);
     imp_lp_id = junk.objs;
     num_imp_lps = junk.num_objs;
     EMerr_hndlr (!stat || !(1&rc), *EFmsg, EMS_E_Fail, wrapup);

     /* Since we clipped against the loopset of the common surface during
        mapping, we should get back ONLY 1 loop. Any more loops indicates
        that there was interference with hole regions on the common
        surface. This is a condition we don't handle. Set the return code
        to EMS_E_IntersectTrim and exit.

        It also follows that if there is only 1 mapped loop produced, it
        should contain the same number of edges as the number of input
        curves. Lack of this also indicated interference.

        Redraw the erased common surface if interference is detected and
        then exit.

        SM 8/3/93
     */
     if(num_imp_lps != 1)
      {
       *EFmsg = EMS_E_IntersectTrim;
       goto Interference;
      }

     OM_stat = om$get_channel_count(osnum = cur_os,
               objid = imp_lp_id[0], p_chanselect = &lp_ed_chan,
                 count = &count);
     EMerr_hndlr (!(1&OM_stat),*EFmsg, EMS_E_OMerror, wrapup);

     if(count != num_lp_cvs)
      {
       *EFmsg = EMS_E_IntersectTrim;
       goto Interference;
      }


Interference:
    if(!(1&OM_stat&*EFmsg) && comm_sf_erased)
     {
      IGRlong locmsg;

      /*
       * Redraw the common edge's surface. It was erased earlier.
      */
      DisplayMode = GRbd;
      (void) om$send (msg = message GRgraphics.GRdisplay (&locmsg,
                       &md_env->md_env.matrix_type,
                       md_env->md_env.matrix, &DisplayMode,
                       &md_env->md_id),
                       senderid = NULL_OBJID,
                       targetid = cm_ed_sf_GRid.objid, 
                       targetos = cm_ed_sf_GRid.osnum);
      comm_sf_erased = FALSE;
      goto wrapup;
     }

    }

    /*
     * Whenever the imposed loops end points match with
     * that of end points of the common edge, make sure
     * the respective end points of the loop and the common
     * edge are the same. The end points of the loop should
     * always match with that of the common edge except in
     * case the common edge is physically closed. 
     */

    OM_stat = om$send (msg = message EMSedge.EMendpts (&mthd_stat,
                         cm_ed_end_pts, &cm_ed_end_pts[2], NULL, 
                         NULL, NULL),
                        senderid = NULL_OBJID, 
                        targetid = cm_ed_GRid.objid, 
                        targetos = cur_os);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

    if (!(cm_ed_props & EMED_XYZ_CLOSED))
    {
      /*
       * o num_edges = num_lp_cvs.
       * o get the end pts of the common edge.
       * o get begin point of the first edge of the loop.
       *   Make sure that its begin point is the same as 
       *   common edge's end point.
       * o Get the end point of the last edge of the loop.
       *   make it same as the begin point of the common edge.
       */

      for (i = 0; i < 2; i++)
      {
        ed_idx = i ? (num_lp_cvs - 1) : 0;
        cm_ed_tst_pt = i ? cm_ed_end_pts : &cm_ed_end_pts[2];

        OM_stat = om$get_objid_at_index (osnum = cur_os,
                     objid = imp_lp_id[0], p_chanselect = &lp_ed_chan,
                     index = ed_idx, objidaddr = &ed_id, 
                     osnumaddr = &dum_os);
        EMerr_hndlr (!(1&OM_stat),*EFmsg, EMS_E_OMerror, wrapup);

        OM_stat = om$send (msg = message EMSedge.EMendpts (&mthd_stat,
                            i ? NULL : lp_end_pt, i ? lp_end_pt : NULL,
                            NULL, NULL, NULL),
                           senderid = NULL_OBJID,
                           targetid = ed_id, targetos = cur_os);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);
        
        if (lp_end_pt[0] != cm_ed_tst_pt[0]    ||
            lp_end_pt[1] != cm_ed_tst_pt[1] )
        {
          EFfix_ed_geometry ( &rc, ed_id, cur_os, 
                               (i ? EMS_EDGE_END_PT : EMS_EDGE_BEG_PT),
                               cm_ed_tst_pt, &partolbasis, NULL_OBJID);
          EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_Fail,wrapup);
               
        } /* if (lp_end_pt[0] != cm_ed_tst_pt[0]    ||
                 lp_end_pt[1] != cm_ed_tst_pt[1] ) */

      } /* for (i = 0; i < 2; i++) */

      /* 
       * If the common edge's surface is physically closed
       * in u, v or both directions, common points between the 
       * first curve, second curve and second curve, third curve
       * need to have correct/same values. Map the curve may result
       * in wrong uvdata for the points lying on the seam edges.
       */

      if (cm_ed_sfgm->u_phy_closed || cm_ed_sfgm->v_phy_closed)
      {
        EFfix_mapped_data (&rc, *imp_lp_id, cur_os, num_lp_cvs, lp_cvs, 
                           cm_ed_sfgm, &partolbasis);
        EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

      } /* if (cm_ed_sfgm->u_phy_closed || cm_ed_sfgm->v_phy_closed) */

    } /* if (!(cm_ed_props & EMED_XYZ_CLOSED)) */
    else
    {
      /*
       * If the common edge is physically closed, one
       * curve will be sent to get_loops_for_imposition. Since,
       * NoTrace option is sent, get loop for imposition is not
       * going to set mapped edge's EMED_XYZ_CLOSED property.
       * It is therefore, needed to turn this property on.
       *
       * Also, make sure that the end points of mapped edge
       * at the seam points are correct. The following logic
       * is used:
       *
       * o surface is u_phy_closed:
       *    o The u_value of the begin point of the edge should be that
       *      end point of the common edge.
       *    o The u_value of the end point of the edge should be that
       *      begin point of the common edge.
       *    o The v_values of the begin and end points should be same.
       *
       * o surface is v_phy_closed:
       *    o The v_value of the begin point of the edge should be that
       *      end point of the common edge.
       *    o The v_value of the end point of the edge should be that
       *      begin point of the common edge.
       *    o The u_values of the begin and end points should be same.
       */

      IGRboolean fix_ed = FALSE;

      OM_stat = om$send (msg = message EMSboundary.EMtree_traverse (
                          &mthd_stat, message EMSedge.EMset_props(
                            &mthd_stat, EMED_XYZ_CLOSED, EMS_O_ON),
                          MAXINT, 1, &OPP_EMSedge_class_id, TRUE, NULL,
                          NULL, NULL),
                        senderid = NULL_OBJID,
                        targetid = imp_lp_id[0], targetos = cur_os);
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopError,wrapup);

      OM_stat = om$get_objid_at_index (osnum = cur_os,
                     objid = imp_lp_id[0], p_chanselect = &lp_ed_chan,
                     index = 0, objidaddr = &ed_id, 
                     osnumaddr = &dum_os);
      EMerr_hndlr (!(1&OM_stat),*EFmsg, EMS_E_OMerror, wrapup);

      OM_stat = om$send (msg = message EMSedge.EMendpts (&mthd_stat,
                          ed_end_pts, &ed_end_pts[2],
                          NULL, NULL, NULL),
                         senderid = NULL_OBJID,
                         targetid = ed_id, targetos = cur_os);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

      uv_type = cm_ed_sfgm->u_phy_closed ? U : V;
   
      if ( ed_end_pts[2+ (uv_type ? 0 : 1)] != 
           ed_end_pts[uv_type ? 0 : 1] )
      {
        ed_end_pts[2+ (uv_type ? 0 : 1)] = ed_end_pts[uv_type ? 0 : 1];
        fix_ed = TRUE;
      }
      
      for (i = 0; i < 2; i++)
      {
        if ( ( cm_ed_end_pts[2*i+uv_type] != 
               ed_end_pts[(i ? 0 : 2) + uv_type] ) || fix_ed )
        {
          ed_end_pts[(i ? 0 : 2) + uv_type] = cm_ed_end_pts[2*i+uv_type];
          EFfix_ed_geometry ( &rc, ed_id, cur_os, 
                               (i ? EMS_EDGE_BEG_PT : EMS_EDGE_END_PT),
                       &ed_end_pts[i ? 0 : 2], &partolbasis, NULL_OBJID);
          EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_Fail,wrapup);
               
        } /* if ( ( cm_ed_end_pts[2*i+uv_type] != 
                    ed_end_pts[(i ? 0 : 2) + uv_type] ) || fix_ed ) */
        
      } /* for (i = 0; i < 2; i++) */

    } /* else for if (!(cm_ed_props & EMED_XYZ_CLOSED)) */

    /*
     * Because of tolerance problems, it may be possible that
     * trim info resulted from the EMtrimyourself has NULL_OBJIDs
     * as edge ids and edges which should not split may have
     * have split points. In order to avoid failures because of
     * these reasons, it is needed to trim and extract the loop
     * here and fix the trim info before splitting the cm_ed_sf.
     */

    OM_stat = om$get_channel_objects (osnum = cm_ed_sf_GRid.osnum,
                  objid = cm_ed_sf_GRid.objid, 
                  p_chanselect = &sf_ls_chan, list = &ls_list,
                  size = 1, count = &count);
    EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);
    EMerr_hndlr (count != 1, *EFmsg,EMS_E_InvalidArg,wrapup);

    num_lps = buf_size = 0;
    OM_stat = om$send (msg = message EMSloop.EMtrimyourself (
                        &mthd_stat, &ls_list.S_objid, NULL, 
                        &against_bdrys, &lp_bdrys, &lp_ids, 
                        &num_lps, &num_bdrys, &buf_size, 
                        &partolbasis),
                       senderid = NULL_OBJID,
                       targetid = imp_lp_id[0], targetos = cur_os);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopError,wrapup);
    if (mthd_stat == EMS_I_InAreaTrim) extract_lp = FALSE;

    if (*num_bdrys)
    {
      EFfix_the_trim_info (&rc, lp_bdrys, against_bdrys, 1,
                           ls_list.S_objid, cur_os, last_ed_u1s->ed_ids,
                           last_ed_u1s->num_eds, &partolbasis);
      EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

      if (next_ed_u0s)
      {
        if (next_ed_u0s->num_eds)
        {
          EFfix_the_trim_info (&rc, lp_bdrys, against_bdrys, 1,
                            ls_list.S_objid, cur_os, next_ed_u0s->ed_ids,
                            next_ed_u0s->num_eds, &partolbasis);
          EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_Fail,wrapup);

        } /* if (next_ed_u0s->num_eds) */
 
      } /* if (next_ed_u0s) */

    } /* if (*num_bdrys) */

    /*
     * The loop in the parametric space of the common edge's surface
     * has been obtained. Get the objid of the edge corresponding to
     * the new geometry of the cm_ed.
     */
 
    OM_stat = om$get_objid_at_index (osnum = cur_os, objid = *imp_lp_id,
                   p_chanselect = &lp_ed_chan, 
                   index = valid_end_pts_lineseg[0] ? 1 : 0, 
                   objidaddr = &cm_ed_ngm_id, osnumaddr = &cur_os);
    EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);
                   
    /*
     * get begin and end points of the edge created
     * by the cm_ed_newgm. It will be used in collecting
     * the edges for common edge connections.
     */

    OM_stat = om$send (msg = message EMSedge.EMendpts (&mthd_stat,
                        cm_ed_ngm_pts, &cm_ed_ngm_pts[2], NULL, 
                        NULL, NULL),
                       senderid = NULL_OBJID, 
                       targetid = cm_ed_ngm_id, targetos = cur_os);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

    /*
     * If the number of boundaries representing the area
     * portions on the imp_lp_id returned by EMtrimyourself is 0,
     * it is assumed that the imp_lp is totally overlapping
     * the common edge's loop. In such a case, there are two
     * possibilities :
     *
     * 1. The common edge's surface has only one loop and it
     *    is the common edge's loop. In such a case
     *    take the surface out and establish the topology with
     *    rev_lp_id as the common edge's loop.
     *
     * 2. The common edge's surface has more than one loop.
     *    In such a case, take out the common edge's loop
     *    and treat it as rev_lp_id for reestablishing topology.
     */

    if (!(*num_bdrys))
    {
      depth = MAXINT;
      buf_size = NULL;
      OM_stat = om$send (msg = message EMSloopset.EMget_loops (&mthd_stat,
                          EMS_OPT_ALL, &depth, NULL, NULL, &buf_size,
                          &num_lps),
                         senderid = NULL_OBJID,
                         targetid = ls_list.S_objid, 
                         targetos = ls_list.osnum);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopsetError,wrapup);
      rev_lp_md = (num_lps == 1 ? EMS_MD_EXTRACT_SF : EMS_MD_EXTRACT_LP);
      
    } /* if (!(*num_bdrys)) */

    else
    { 
      rev_lp_md = EMS_MD_DELETE_LP;
      /*
       * If the imposed loop wholly lies in the area region,
       * there is no need to extract it.
       */

      if (extract_lp)
      {
       OM_stat = om$send (msg = message EMSloop.EMextractyourself (
                          &mthd_stat, *lp_bdrys, *against_bdrys,
                          *num_bdrys, &trim_lps, &out_bdrys, &trim_info,
                          TRUE, TRUE, &partolbasis),
                         senderid = NULL_OBJID,
                         targetid = imp_lp_id[0], targetos = cur_os);
       EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_OMerror,wrapup);

      } /* if (extract_lp) */
      else
      {
        trim_info = against_bdrys;
        against_bdrys = NULL;
      }
      /*
       * Split the loopset of the cm_ed_sf w.r.t. loop
       * created above
       */
     
      options = EMImpBnd_CloseRegular | EMImpBnd_CloseReverse |
                EMImpBnd_SplitTopology | EMImpBnd_NoDummyEdges;

      OM_stat = om$send (msg = message EMSloopset.EMsplityourself (
                         &mthd_stat, (extract_lp ? trim_lps : imp_lp_id),
                         *num_bdrys, trim_info,
                          NULL, NULL, &new_lps_added, &num_new_lps,
                          options, &num_sfs, &lps_rmvd, &partolbasis,
                          md_env),
                        senderid = NULL_OBJID,
                        targetid = ls_list.S_objid, 
                        targetos = ls_list.osnum);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopsetError,wrapup);

     } /* else for if (!(*num_bdrys)) */

     /*
      * Since the loop used for splitting spans over
      * the area region of the cm_ed_sf only, there
      * will be only one loop crated by reverse_close.
      * And this particular loop will have the cm_ed
      * as one of its edges. 
      * On the other hand, if the imp_lp completely overlaps
      * the common edge's lp, it will be used for extracting the 
      * edges. Find out this loop. This will be used to get 
      * the edges to be used for common edge connections 
      * of the last_ed's_lifted_sf and the next_ed's_lifted_sf.
      */

     stat = EMsend_loops (&rc, message EMSboundary.EMget_objid(&mthd_stat,
                           &rev_lp_id), cm_ed_GRid.objid, NULL, MAXINT, 
                           EMLP_ACTIVE, NULL, NULL);
     EMerr_hndlr (!(1&stat&rc&mthd_stat),*EFmsg,EMS_E_Fail,wrapup);

     OM_stat = om$get_index (osnum_c = cur_os, objid_c = rev_lp_id,
                     p_chanselect = &lp_ed_chan, objid = cm_ed_GRid.objid,
                     osnum2 = cm_ed_GRid.osnum, indexaddr = &cm_ed_inx);
     EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

     OM_stat = om$send (msg = message EMSloop.EMget_props (&mthd_stat,
                         &rev_lp_props),
                        senderid = NULL_OBJID,
                        targetid = rev_lp_id,
                        targetos = cur_os);
     EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopError,wrapup);

     /*
      * Collect the ed_u0s (edges to be coonected to the EDGEU1
      * of the surface created/trimmed by last edge), ed_u1s (edges to
      * be connected to EDGEU0 of the surface created/trimmed 
      * by the next edge) and edges to be connected to the edge 
      * under consideration.
      *
      * If the end points of the cm_ed_ngm do not correspond to 
      * the end points of one or two edges of the rev_lp, one 
      * or two edges of the rev_lp will have to be split. Further, 
      * if there is a common edge of the edge being split, it will 
      * also be split. Need to save this information for save 
      * state purposes. There can be at most two edges being split. 
      * One corresponding to begin point and the other for the end 
      * point of the cm_ed_ngm. If the end point edge being split 
      * is a result of the begin point edge split, ignore it for 
      * save state info. 
      */

     OM_stat = om$get_channel_count (objid = rev_lp_id,
                   osnum = cur_os, p_chanselect = &lp_ed_chan,
                   count = &num_rev_lp_eds);
     EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

     num_ed_sp_eds = 0;

     for (i = 0; i < 2; i++)
     {
       if (!valid_end_pts_lineseg[i] && !(cm_ed_props & EMED_XYZ_CLOSED))
       {
        if (rev_lp_props & EMLP_REVERSED)
          cm_ed_ngm_end_inx[i] = i ? 
             ( cm_ed_inx == num_rev_lp_eds-1 ? 0 : cm_ed_inx+1 ) :
             ( cm_ed_inx == 0 ? num_rev_lp_eds-1 : cm_ed_inx-1 );

        else
          cm_ed_ngm_end_inx[i] = i ?  
               ( cm_ed_inx == 0 ? num_rev_lp_eds-1 : cm_ed_inx-1 ) :
               ( cm_ed_inx == num_rev_lp_eds-1 ? 0 : cm_ed_inx+1 );

       } /* if (!valid_end_pts_lineseg[i] && 
                !(cm_ed_props & EMED_XYZ_CLOSED)) */

       else
       {
         IGRboolean cntinue = FALSE;
         pt_loc.options = NULL;
         OM_stat = om$send (msg = message EMSloop.EMpt_location ( 
                          &mthd_stat, &cm_ed_ngm_pts[2*i], &pt_loc, 
                          &partolbasis),
                        senderid = NULL_OBJID, targetid = rev_lp_id,
                        targetos = cur_os);
         EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopError,wrapup);

         OM_stat = om$get_index (objid_c = rev_lp_id,
                       osnum_c = cur_os, p_chanselect = &lp_ed_chan,
                       objid = pt_loc.edge[0].edge_id, osnum2 = cur_os,
                       indexaddr = &cm_ed_ngm_end_inx[i]);
         EMerr_hndlr(!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

         do
         {
          switch (pt_loc.location)
          {
            case EMS_L_ONVRTX:
            break;

           /*
            * If the location is on an edge, split it.
            */

           case EMS_L_ONEDGE:

             split_info.edgeid = pt_loc.edge[0].edge_id;
             split_info.edgepar = pt_loc.edge[0].nst_pt.param;
             split_info.intloc = pt_loc.edge[0].nst_pt.location;
             OM_BLOCK_MOVE(pt_loc.edge[0].nst_pt.proj_pt,split_info.point,
					       2 * sizeof(IGRdouble));

             OM_stat = om$send (msg = message EMSedge.EMsplityourself (
                                 &mthd_stat, split_info_ptr, 
                                 EMSplitEd_SplitTopology, NULL, dum_eds, NULL,
				 NULL, NULL, &partolbasis, md_env, 
				 NULL, NULL, NULL),
                                senderid = NULL_OBJID,
                                targetid = pt_loc.edge[0].edge_id,
                                targetos = cur_os);
             EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);
             /*
              * It may be possible that the split point was within
              * tolerance w.r.t edge's end points in model space and 
              * thus the edge was not split. In such a case,
              * o for begin pt (i = 0), nothing needs to be done.
              * o for end point (i = 1), decrement cm_ed_ngm_end_inx by 1.
              */

             OM_stat = om$get_channel_count (objid = rev_lp_id,
                        osnum = cur_os, p_chanselect = &lp_ed_chan,
                       count = &new_num_rev_lp_eds);
             EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);
             if (num_rev_lp_eds == new_num_rev_lp_eds)
             {
               if (i) cm_ed_ngm_end_inx[i]--;
             } /* if (num_rev_lp_eds == new_num_rev_lp_eds) */
             else
             {
              OM_stat = om$get_channel_count (osnum = cur_os, 
                          objid = pt_loc.edge[0].edge_id, 
                          p_chanselect = &cm_ed_chan, count = &num_cm_ed);
              EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

              good_ed = TRUE;
              if (num_cm_ed)
              {
                /*
                 * find out if the edge being currently split
                 * is a result of last edge being split. If so
                 * ignore this edge.
                 */
 
                if (num_ed_sp_eds)
                {
                  num_part_eds = 0;
                  OM_stat = om$send (
                             msg = message EMSedge.EMget_top_part_edges 
                              (&mthd_stat, &work_ids, &num_part_eds,
                               &array_size),
                             senderid = NULL_OBJID,
                             targetid = ed_sp_eds[0], targetos = cur_os);
                  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

                  cur_ed = 0;
                  do
                  {
                    if (work_ids[cur_ed] == pt_loc.edge[0].edge_id)
                     good_ed = FALSE;
                  } while (cur_ed < num_part_eds && good_ed); 

                } /* if (num_sp_eds) */

                if (good_ed)
                    ed_sp_eds[num_ed_sp_eds++] = pt_loc.edge[0].edge_id;
                
              } /* if (num_cm_ed) */

              num_rev_lp_eds++;
             } /* else for if (num_rev_lp_eds == new_num_rev_lp_eds) */
             break;

           default:
             switch (pt_loc.edge[0].nst_pt.location) 
             { 
               case EMScvint_lfend: 
               case EMScvint_lfendcoll: 
                if (i)
                {
                 if (rev_lp_props & EMLP_REVERSED)
                  cm_ed_ngm_end_inx[i] = 
                    (cm_ed_ngm_end_inx[i] == num_rev_lp_eds - 1) ? 0 :
                     cm_ed_ngm_end_inx[i]+1;

                 else
                  cm_ed_ngm_end_inx[i] = 
                    (cm_ed_ngm_end_inx[i] == 0 ? num_rev_lp_eds - 1 :
                      cm_ed_ngm_end_inx[i] - 1);

                } /* if (i) */

                 break;

               case EMScvint_middle: 
                 cntinue = TRUE;
                 pt_loc.location = EMS_L_ONEDGE;
                 break;

               case EMScvint_rtend: 
               case EMScvint_rtendcoll: 
                if (!i)
                {
                 if (rev_lp_props & EMLP_REVERSED)
                  cm_ed_ngm_end_inx[i] = 
                    (cm_ed_ngm_end_inx[i] == 0 ? num_rev_lp_eds - 1 :
                      cm_ed_ngm_end_inx[i] - 1);

                 else
                  cm_ed_ngm_end_inx[i] = 
                    (cm_ed_ngm_end_inx[i] == num_rev_lp_eds - 1) ? 0 :
                     cm_ed_ngm_end_inx[i]+1;
                } /* if (!i) */

                 break;

               default: 
                 fprintf (stderr, "pt_location got screwed up \n");
                 *EFmsg = EMS_E_Fail;
                 goto wrapup;

             } /* switch (pt_loc.edge[0].nst_pt.location) */

          } /* switch (pt_loc.location) */

         } while (cntinue);
          

         /* 
          * the edge at the end point of the cm_ed_ngm 
          * will be pt_loc.edge[0].edge_id while 
          * at the beg pt will be next to pt_loc_edge[0].edge_id  
          */

         if ( (pt_loc.location == EMS_L_ONVRTX || 
               pt_loc.location == EMS_L_ONEDGE)   && !i) 
         {
           if (rev_lp_props & EMLP_REVERSED)
            cm_ed_ngm_end_inx[i] = 
                   (cm_ed_ngm_end_inx[i] == 0 ? num_rev_lp_eds-1 :
                    cm_ed_ngm_end_inx[i]-1);

           else
             cm_ed_ngm_end_inx[i] = 
                 (cm_ed_ngm_end_inx[i] == num_rev_lp_eds - 1) ? 0 :
                  cm_ed_ngm_end_inx[i] + 1;

         } /* if ( (pt_loc.location == EMS_L_ONVRTX || 
                     pt_loc.location == EMS_L_ONEDGE)   && !i)  */

       } /* else for if (!valid_end_pts_lineseg[i] && 
                             !(cm_ed_props & EMED_SEAM)) */

     } /* for (i = 0; i < 2; i++) */

     /* 
      * Save the following information for save state purposes. 
      * 
      * 1. Some of the edges of the cm_ed_sf_ls were split 
      *    during splitting it with the imp_lp. If these 
      *    edges had any common edges, they were split too. 
      *    save the original and split common edges. 
      *    This information can be extracted from trim_info. 
      *    Some edges might have been split while splitting
      *    the edges of the rev_lp to get begin and end points
      *    of the cm_ed_ngm. If these edges were the
      *    result of the ls_spliting process, they should be
      *    ignored.
      * 
      * 2. If the edge is split, its splitedges will be 
      *    extracted by the caller and not here. 
      */

      if (*num_bdrys)
      {
        EMget_sp_edges (&rc, trim_info, *num_bdrys, 
                        lps_rmvd ? lps_rmvd->num_comps : NULL,
                        lps_rmvd ? lps_rmvd->comps : NULL,
                        &ls_sp_eds, &num_ls_sp_eds);
        EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_Fail,wrapup);

      } /* if (*num_bdrys) */

      if (num_ls_sp_eds || num_ed_sp_eds)
      {
        if (num_ed_sp_eds)
        {
          cur_ls_sp_ed = 0;  
          do
          {
            num_part_eds = 0;
            if(ls_sp_eds)
             {
              OM_stat = om$send (msg = message EMSedge.EMget_top_part_edges(
                                &mthd_stat, &work_ids, &num_part_eds,
                                &array_size),
                               senderid = NULL_OBJID,
                               targetid = ls_sp_eds[cur_ls_sp_ed],
                               targetos = cur_os);
              EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,
                           wrapup);
             }
            cur_ed_sp_ed = 0;
            do
            {
              ed_exists = FALSE;
              for (i = 0; i < num_part_eds; i++)
              {
                if ( work_ids[i] == ed_sp_eds[cur_ed_sp_ed] )
                {
                  ed_exists = TRUE;
                  break;
                }
              } /* for (i = 0; i < num_part_eds; i++) */

              if (ed_exists)
              {
                blksize = sizeof(GRobjid) *(num_ed_sp_eds-1-cur_ed_sp_ed);
                if (blksize)
                   OM_BLOCK_MOVE (&ed_sp_eds[cur_ed_sp_ed+1],
                                &ed_sp_eds[cur_ed_sp_ed],blksize);
                num_ed_sp_eds--;

              } /* if (ed_exists) */
              else cur_ed_sp_ed++;
 
            } while (cur_ed_sp_ed < num_ed_sp_eds);

          } while (cur_ls_sp_ed < num_ls_sp_eds && num_ed_sp_eds);

        } /* if (num_ed_sp_eds) */
           
      } /* if (num_ls_sp_eds || num_ed_sp_eds) */

      /*
       * Now all of the edges of the common edge surface
       * that were split and have common edges on another
       * surface(s) have been collected. Next step is
       * to 1) get the common edges and 2) the top
       * part edges of these common edges. Save this
       * information for save state purposes.
       */

      if (num_ls_sp_eds)
      {
        EFcollect_ed_split_info (&rc, num_ls_sp_eds, ls_sp_eds, cur_os,
                                ed_sp_info, lps_mod_info);
        EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_Fail,wrapup);

      } /* if (num_ed_sp_eds) */
   
      if (num_ed_sp_eds)
      {
        EFcollect_ed_split_info (&rc, num_ed_sp_eds, ls_sp_eds, cur_os,
                                ed_sp_info, lps_mod_info);
        EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_Fail,wrapup);

      } /* if (num_ed_sp_eds) */
   
     /*
      * Now the index of the edge whose begin point
      * matches with that of the cm_ed_newgm's 
      * begin point as well as the index of the edge
      * whose end point matches with end point of the
      * cm_ed_newgm are available.
      * Using this information and the reverse connect property
      * of the common edge, start and end indices of ed_u0s and 
      * ed_u1s can be extracted from the rev_lp. In a special
      * case where there were no trim boundaries and the
      * common edge's loop is used as rev_lp_id, EMLP_REVERSED
      * property will have to be used in computing the
      * ed_u0s and ed_u1s indices.
      *
      */

     /*
      * Get the ed_u0s. Some of the edges whose common
      * edges are ed_u0s may be present in last_ed_u1s. This
      * will be the case when a edge as well as its common
      * edge is trimmed while trimming two consequtive surfaces.
      * In such a case, take out the corresponding entry in
      * last_ed_u1s and donot put an entry in ed_u0s.
      */

     ed_u0s->num_eds = 0;

     if ( ( (cm_ed_props & EMED_REVERSE_CONNECT) &&
             valid_end_pts_lineseg[0])                   ||

          ( !(cm_ed_props & EMED_REVERSE_CONNECT) &&
              valid_end_pts_lineseg[1]) )
     {

       if (cm_ed_props & EMED_REVERSE_CONNECT)
       {
         if ( !(rev_lp_props & EMLP_REVERSED) )
         {
           ed_u0s_inx[0] = (cm_ed_inx == num_rev_lp_eds-1) ? 0 :
                             cm_ed_inx+1;
           ed_u0s_inx[1] = (cm_ed_ngm_end_inx[0] == 0) ?
                           (num_rev_lp_eds-1) : (cm_ed_ngm_end_inx[0]-1);

         } /* if ( !(rev_lp_props & EMLP_REVERSED) ) */
         else
         {
           ed_u0s_inx[0] = (cm_ed_inx == 0) ? 
                            (num_rev_lp_eds-1) : (cm_ed_inx-1);

           ed_u0s_inx[1] = (cm_ed_ngm_end_inx[0] == num_rev_lp_eds-1) ?
                            0 : (cm_ed_ngm_end_inx[0] + 1);

         } /* else for if ( !(rev_lp_props & EMLP_REVERSED) ) */

       } /* if (cm_ed_props & EMED_REVERSE_CONNECT) */
       else
       {
         if ( !(rev_lp_props & EMLP_REVERSED) )
         {
           ed_u0s_inx[0] = (cm_ed_ngm_end_inx[1] == num_rev_lp_eds-1) ? 
                            0 : cm_ed_ngm_end_inx[1]+1;
           ed_u0s_inx[1] = (cm_ed_inx == 0) ?
                           (num_rev_lp_eds-1) : (cm_ed_inx-1);
 
         } /* if ( !(rev_lp_props & EMLP_REVERSED) ) */
         else
         {
           ed_u0s_inx[0] = (cm_ed_ngm_end_inx[1] == 0) ? 
                            (num_rev_lp_eds-1) : (cm_ed_ngm_end_inx[1]-1);
           ed_u0s_inx[1] = (cm_ed_inx == num_rev_lp_eds-1) ?
                            0 : (cm_ed_inx + 1);
 
         } /* else for if ( !(rev_lp_props & EMLP_REVERSED) ) */

       } /* else for if (cm_ed_props & EMED_REVERSE_CONNECT) */
  
       EFcollect_eds (&rc, rev_lp_id, num_rev_lp_eds, rev_lp_props,
                      ed_u0s_inx[0], ed_u0s_inx[1],
                      cur_os, ed_u0s, last_ed_u1s);
       EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_Fail,wrapup);

     } /* if ( ( (cm_ed_props & EMED_REVERSE_CONNECT) &&
                   valid_end_pts_lineseg[0])                  ||

                ( !(cm_ed_props & EMED_REVERSE_CONNECT) &&
                    valid_end_pts_lineseg[1]) ) */

     /*
      * collect ed_u1s. The edges whose common edges will
      * be connected (ed_u1s) to next edge's surface's
      * ed_u0s. If the caller has sent next_ed_u0s,
      * check if any of the ed_u1s are in next_ed_u0s. If
      * take it out of next_ed_u0s and do not put it in 
      * ed_u1s.
      */

     ed_u1s->num_eds = 0;
     reject_list.num_eds = 0;

     if ( ( (cm_ed_props & EMED_REVERSE_CONNECT) &&
             valid_end_pts_lineseg[1])                  ||

          ( !(cm_ed_props & EMED_REVERSE_CONNECT) &&
              valid_end_pts_lineseg[0]) )
     {

       if (cm_ed_props & EMED_REVERSE_CONNECT)
       {
         if (!(rev_lp_props & EMLP_REVERSED))
         {
           ed_u1s_inx[0] = (cm_ed_ngm_end_inx[1] == num_rev_lp_eds-1) ?
                         0 : cm_ed_ngm_end_inx[1]+1;
           ed_u1s_inx[1] = (cm_ed_inx == 0) ? (num_rev_lp_eds-1) :
                          (cm_ed_inx-1);

         } /* if (!(rev_lp_props & EMLP_REVERSED)) */
         else
         {
            ed_u1s_inx[0] = (cm_ed_ngm_end_inx[1] == 0) ?
                            (num_rev_lp_eds-1) : (cm_ed_ngm_end_inx[1]-1);
            ed_u1s_inx[1] = (cm_ed_inx == num_rev_lp_eds-1) ?
                              0 : (cm_ed_inx+1);

          } /* else for if (!(rev_lp_props & EMLP_REVERSED)) */

       } /* if (cm_ed_props & EMED_REVERSE_CONNECT) */
       else
       {
         if (!(rev_lp_props & EMLP_REVERSED))
         {
           ed_u1s_inx[0] = (cm_ed_inx == num_rev_lp_eds-1) ?
                          0 : cm_ed_inx+1;
           ed_u1s_inx[1] =(cm_ed_ngm_end_inx[0] == 0) ? 
                           (num_rev_lp_eds-1) : (cm_ed_ngm_end_inx[0]-1);

         } /* if (!(rev_lp_props & EMLP_REVERSED)) */
         else
         {
           ed_u1s_inx[0] = (cm_ed_inx == 0) ?
                          (num_rev_lp_eds-1) : (cm_ed_inx-1);
           ed_u1s_inx[1] =(cm_ed_ngm_end_inx[0] == num_rev_lp_eds-1) ? 
                           0 : (cm_ed_ngm_end_inx[0]+1);
         
         } /* else for if (!(rev_lp_props & EMLP_REVERSED)) */

       } /* else for if (cm_ed_props & EMED_REVERSE_CONNECT) */

       EFcollect_eds (&rc, rev_lp_id, num_rev_lp_eds, rev_lp_props, 
                       ed_u1s_inx[0], ed_u1s_inx[1],
                       cur_os, ed_u1s, 
                       next_ed_u0s ? next_ed_u0s : &reject_list);
       EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_Fail,wrapup);

     } /* if ( ( (cm_ed_props & EMED_REVERSE_CONNECT) &&
                   valid_end_pts_lineseg[1])                  ||

                ( !(cm_ed_props & EMED_REVERSE_CONNECT) &&
                    valid_end_pts_lineseg[0]) ) */

     /*
      * Now ed_u0s and ed_u1s have been collected.
      * Next step is to collect all of the edges
      * corresponding to cm_ed_newgm. These will
      * be used to establish topology with ed_GRid.
      *
      * 1. Get the edge id.
      * 2. Get the cm_ed_id and cm_ed_sf_id if any.
      */

     EFcollect_eds (&rc, rev_lp_id, num_rev_lp_eds, rev_lp_props,
                     cm_ed_ngm_end_inx[0], cm_ed_ngm_end_inx[1],
                     cur_os, &new_cm_eds, &reject_list);
     EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_Fail,wrapup);

     /*
      * The following three situations are possible for
      * rev_lp_id:
      *
      * 1. It is returned by loopset split process. In this
      *    case delete it. There may be some lps taken out.
      *    If any of these lps were added in an earlier edge
      *    trimming process, do not add these lps in lp_rmvd_ids
      *    and also take the lp out of lps-added_array.
      *
      * 2. It is the common edge's loop and the common edge's
      *    surface has only one loop. It may be possible that
      *    the only loop left in the surface is a new lp added
      *    during trimming the surface for an earlier edge.
      *    In such a case, there will be an entry for this surface
      *    in lps_mod_info. In such a case put the lps_out back
      *    and take the lps out and finally extract the surface out.
      *    This will result in removal of the surface when the processing
      *    is over. If there is no entry in lps_mod_info simply take
      *    the surface out.
      *    
      * 3. It is the common edge's loop and the common edge's
      *    surface has more than one loop. If this lp is the one
      *    added during an earlier edge trimming, delete the lp
      *    and take the lp out from lps_addedd in the lps_mod_info 
      *    for the surface.
      */

     if (rev_lp_md == EMS_MD_EXTRACT_LP ||
         rev_lp_md == EMS_MD_DELETE_LP)
     {
       sf_exists = FALSE;
       sf_inx = 0;

       while ( sf_inx < lps_mod_info->num_sfs && !sf_exists)
       {
         if ( IF_EQ_OBJID (cm_ed_sf_GRid.objid, 
               lps_mod_info->sf_ids[sf_inx]) ) sf_exists = TRUE;
         else  sf_inx++;

       } /* while ( sf_inx < lps_mod_info->num_sfs && !sf_exists) */

       if (rev_lp_md == EMS_MD_EXTRACT_LP )
       {
        lp_exists = FALSE;
        if (sf_exists)
        {
         from_inx = 0;

         for (lp_inx = 0; lp_inx < sf_inx; lp_inx++)
            from_inx += lps_mod_info->lps_added_prsf[lp_inx];

         to_inx = from_inx + lps_mod_info->lps_added_prsf[sf_inx];

         for (lp_inx = from_inx; lp_inx < to_inx; lp_inx++)

          if (IF_EQ_OBJID (rev_lp_id, lps_mod_info->lp_added_ids[lp_inx]))
          {
            lp_exists = TRUE;
            break;
          }

          if (lp_exists)
          {                
            rev_lp_md = EMS_MD_DELETE_LP;
            blksize = (lps_mod_info->num_lps_added - lp_inx - 1) *
                         sizeof(GRobjid);
            if (blksize)
              OM_BLOCK_MOVE ( &lps_mod_info->lp_added_ids[lp_inx+1],
                     &lps_mod_info->lp_added_ids[lp_inx], blksize);

            (lps_mod_info->lps_added_prsf[sf_inx])--;
            (lps_mod_info->num_lps_added)--;
          } /* if (lp_exists) */

        } /* if (sf_exists) */

        num_lps_in = 0;
        num_lps_out = lp_exists ? 0 : 1;
        lps_in_ptr = NULL;
        lps_out_ptr = lp_exists ? NULL : &rev_lp_id;

       } /* if (rev_lp_md == EMS_MD_EXTRACT_LP ) */
       else
       {
         for (lp_inx = 0; lp_inx < num_new_lps; lp_inx++)
           if ( IF_EQ_OBJID (new_lps_added[lp_inx],rev_lp_id)) break;
     
         blksize = (num_new_lps - 1 - lp_inx) * sizeof(GRobjid);
         if (blksize)
           OM_BLOCK_MOVE(&new_lps_added[lp_inx+1], 
                         &new_lps_added[lp_inx], blksize);
         num_new_lps--;
         
         if (sf_exists)
         {
           from_inx = 0;
           for (lp_inx = 0; lp_inx < sf_inx; lp_inx++)
              from_inx += lps_mod_info->lps_added_prsf[lp_inx];
             
           cur_lp_rmvd = 0;
           while (cur_lp_rmvd < lps_rmvd->num_comps && 
                  lps_mod_info->lps_added_prsf[sf_inx] )
           {
             lp_exists = FALSE;             
             for (lp_inx = from_inx; 
               lp_inx < (from_inx + lps_mod_info->lps_added_prsf[sf_inx]);
               lp_inx++)
             {
               if (IF_EQ_OBJID (lps_rmvd->comps[cur_lp_rmvd],
                                lps_mod_info->lp_added_ids[lp_inx]))
               {
                 lp_exists = TRUE;
                 break;
               }
             }

             if (lp_exists)
             { 
               blksize = (lps_mod_info->num_lps_added - lp_inx - 1) *
                         sizeof(GRobjid);
               if (blksize)
                 OM_BLOCK_MOVE ( &lps_mod_info->lp_added_ids[lp_inx+1],
                     &lps_mod_info->lp_added_ids[lp_inx], blksize);

               (lps_mod_info->lps_added_prsf[sf_inx])--;
               (lps_mod_info->num_lps_added)--;

               OM_stat = om$send (msg = message Root.delete (1),
                          senderid = NULL_OBJID,
                          targetid = lps_rmvd->comps[cur_lp_rmvd]);
               EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_LoopError,wrapup);
                            
               blksize = (lps_rmvd->num_comps - cur_lp_rmvd - 1) *
                         sizeof(GRobjid);
               if (blksize)
                 OM_BLOCK_MOVE ( &lps_rmvd->comps[cur_lp_rmvd + 1],
                     &lps_rmvd->comps[cur_lp_rmvd], blksize);

               (lps_rmvd->num_comps)--;

              } /* if (lp_exists) */
              else
               cur_lp_rmvd++;

           }/* while (cur_lp_rmvd < lps_rmvd->num_comps && 
                  lps_mod_info->lps_added_prsf[sf_inx] ) */

         } /* if (sf_exists) */

         num_lps_in = num_new_lps;
         num_lps_out = lps_rmvd->num_comps;
         lps_in_ptr = new_lps_added;
         lps_out_ptr = lps_rmvd->comps;

       } /* if (rev_lp_md == EMS_MD_EXTRACT_LP ) */


       OM_stat = om$send(msg = message EMSloop.EMtreemod( &mthd_stat, 
                          &nesting, (rev_lp_md == EMS_MD_DELETE_LP ? 
                          DELETE : EXTRACT), NULL),
                         senderid = NULL_OBJID, targetid = rev_lp_id,
                         targetos = cur_os);
       EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopError,wrapup);

       /*
        * If there are any lps added or removed , save it.
        */

       if (num_lps_in || num_lps_out)
       {
         if (!sf_exists)
         {
           num_elems = lps_mod_info->num_sfs;

           INITIAL_SIZE = BUF_INC = 10;
           array_size = lps_mod_info->sf_arrsz;
           EFmemory_allocation (&rc, (IGRchar **) &lps_mod_info->sf_ids, 
                            num_elems + 1, &array_size,
                            sizeof(GRobjid), INITIAL_SIZE, BUF_INC);
           EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_NoDynamicMemory,wrapup);

           array_size = lps_mod_info->sf_arrsz;
           EFmemory_allocation (&rc, 
                          (IGRchar **) &lps_mod_info->lps_rmvd_prsf, 
                          num_elems + 1, &array_size,
                          sizeof(IGRint), INITIAL_SIZE, BUF_INC);
           EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_NoDynamicMemory,wrapup);

           EFmemory_allocation (&rc, (IGRchar **) 
                            &lps_mod_info->lps_added_prsf,
                            num_elems + 1, &lps_mod_info->sf_arrsz, 
                            sizeof(IGRint), INITIAL_SIZE, BUF_INC);
           EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_NoDynamicMemory,wrapup);

           lps_mod_info->sf_ids[num_elems] = cm_ed_sf_GRid.objid;
           lps_mod_info->lps_added_prsf[num_elems] = 0;
           lps_mod_info->lps_rmvd_prsf[num_elems] = 0;
           (lps_mod_info->num_sfs)++;
           sf_inx = num_elems;

         } /* if (!sf_exists) */

         if (num_lps_in)
         {
           num_elems = lps_mod_info->num_lps_added;
           INITIAL_SIZE = BUF_INC = 10;
           EFmemory_allocation (&rc, 
                              (IGRchar **) &lps_mod_info->lp_added_ids, 
                              num_elems + num_lps_in, 
                              &lps_mod_info->lps_added_arrsz,
                              sizeof(GRobjid), INITIAL_SIZE, BUF_INC);
           EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_NoDynamicMemory,wrapup);

           if (sf_exists)
           {
             num_lps = 0;
             for (i = 0; i <= sf_inx; i++)
               num_lps += lps_mod_info->lps_added_prsf[i];

             blksize = (lps_mod_info->num_lps_added - num_lps ) *
                       sizeof(GRobjid);
             if (blksize)
               OM_BLOCK_MOVE (&lps_mod_info->lp_added_ids[num_lps],
                 &lps_mod_info->lp_added_ids[num_lps + num_lps_in],
                 blksize);

             lp_inx = num_lps;

           } /* if (sf_exists) */
           else
             lp_inx = lps_mod_info->num_lps_added;

           OM_BLOCK_MOVE (lps_in_ptr, 
                 &lps_mod_info->lp_added_ids[lp_inx], 
                 sizeof(GRobjid) * num_lps_in);

           lps_mod_info->lps_added_prsf[sf_inx] += num_lps_in;
           lps_mod_info->num_lps_added += num_lps_in;

         } /* if (num_lps_in) */

         if (num_lps_out)
         {
           num_elems = lps_mod_info->num_lps_rmvd;
           INITIAL_SIZE = BUF_INC = 10;
           EFmemory_allocation (&rc, 
                              (IGRchar **) &lps_mod_info->lp_rmvd_ids, 
                              num_elems + num_lps_out, 
                              &lps_mod_info->lps_rmvd_arrsz,
                              sizeof(GRobjid), INITIAL_SIZE, BUF_INC);
           EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_NoDynamicMemory,wrapup);

           if (sf_exists)
           {
             num_lps = 0;
             for (i = 0; i <= sf_inx; i++)
               num_lps += lps_mod_info->lps_rmvd_prsf[i];

             blksize = (lps_mod_info->num_lps_rmvd - num_lps ) *
                       sizeof(GRobjid);
             if (blksize)
               OM_BLOCK_MOVE (&lps_mod_info->lp_rmvd_ids[num_lps],
                 &lps_mod_info->lp_rmvd_ids[num_lps + num_lps_out],
                 blksize);

             lp_inx = num_lps;

           } /* if (sf_exists) */
           else
             lp_inx = lps_mod_info->num_lps_rmvd;
            
           OM_BLOCK_MOVE (lps_out_ptr, 
                 &lps_mod_info->lp_rmvd_ids[lp_inx], 
                 sizeof(GRobjid) * num_lps_out);

           lps_mod_info->lps_rmvd_prsf[sf_inx] += num_lps_out;
           lps_mod_info->num_lps_rmvd += num_lps_out;

         } /* if (num_lps_out) */

       } /* if (num_lps_in || num_lps_out) */

     } /* if (rev_lp_md == EMS_MD_EXTRACT_LP ||
              rev_lp_md == EMS_MD_DELETE_LP) */

     else
     {
       /*
        * The case of EMS_MD_EXTRACT_SF.
        * o Check if the sf_id is in the lps_mod_info.
        *  o If so, take the sf_entry from the lps_mod_info.
        *  o Also, put back the lps taken out and delete the
        *    lps added.
        * o Get the surface owner's id.
        * o Get the surface's index w.r.t. its owner.
        * o Disconnect the surface from its owner.
        * o Make the surface Non_locatable and Non_displayable.
        */

       if (lps_mod_info->num_sfs)
       {
         sf_exists = FALSE;
         sf_inx = 0;
         do
         {
           if (IF_EQ_OBJID ( cm_ed_sf_GRid.objid, 
               lps_mod_info->sf_ids[sf_inx]) )sf_exists = TRUE;
           else sf_inx++;
           
         } while (!sf_exists && sf_inx < lps_mod_info->num_sfs);
       
         if (sf_exists)
         {
           from_inx = 0;
           for (i = 0; i < sf_inx; i++)
             from_inx += lps_mod_info->lps_added_prsf[i];
            
           to_inx = from_inx + lps_mod_info->lps_added_prsf[sf_inx];

           for (i = from_inx; i < to_inx; i++)
           {
             OM_stat = om$send(msg = message EMSloop.EMtreemod(&mthd_stat,
                                &nesting, DELETE, NULL),
                               senderid = NULL_OBJID,
                               targetid = lps_mod_info->lp_added_ids[i]);
             EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopError,wrapup);
           } /* for (i = from_inx; i < to_inx; i++) */

           blksize = (lps_mod_info->num_lps_added - to_inx)
                      * sizeof(GRobjid);
           if (blksize)
              OM_BLOCK_MOVE (&lps_mod_info->lp_added_ids[to_inx],
                 &lps_mod_info->lp_added_ids[from_inx], blksize);

           lps_mod_info->num_lps_added -= lps_mod_info->lps_added_prsf[sf_inx];
           
           /* 
            * o put the out_loops back into the loopset
            */

           from_inx = 0;
           for (i = 0; i < sf_inx; i++)
             from_inx += lps_mod_info->lps_rmvd_prsf[i];

           to_inx = from_inx + lps_mod_info->lps_rmvd_prsf[sf_inx];

           lp_props = EMLP_ACTIVE;
           for (i = from_inx; i < to_inx; i++)
           {
             OM_stat = om$send (msg = message EMSloop.EMactivate_loop( 
                                  &mthd_stat),
                                senderid = NULL_OBJID,
                                targetid = lps_mod_info->lp_rmvd_ids[i],
                                targetos = cur_os);
             EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopError,wrapup);

             OM_stat = om$send(msg = message EMSloop.EMgivenestinfo( 
                                &mthd_stat, &nesting),
                               senderid = NULL_OBJID,
                               targetid = lps_mod_info->lp_rmvd_ids[i],
                               targetos = cur_os);
             EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_NestError,wrapup);

             OM_stat = om$send(msg = message EMSloopset.EMnesting(
                                &mthd_stat, &nesting, &partolbasis),
                               senderid = NULL_OBJID,
                               targetid = ls_list.S_objid,
                               targetos = cur_os);
             EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_NestError,wrapup);

             if( IF_EQ_OBJID(ls_list.S_objid, nesting.parent) )

               OM_stat = om$send(msg = message EMSloopset.EMtreemod(
                           &mthd_stat, &nesting, ADD_CHILD, &partolbasis),
                          senderid = NULL_OBJID,
                          targetid = ls_list.S_objid, targetos = cur_os);
             else

               OM_stat = om$send(msg = message EMSloop.EMtreemod(
                           &mthd_stat, &nesting, ADD_CHILD, &partolbasis),
                          senderid = NULL_OBJID,
                          targetid = nesting.parent,
                          targetos = cur_os);

             EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_NestError,wrapup);

           } /* for (i = from_inx; i < to_inx; i++) */
           
           blksize = (lps_mod_info->num_lps_rmvd - to_inx)
                      * sizeof(GRobjid);
           if (blksize)
              OM_BLOCK_MOVE (&lps_mod_info->lp_rmvd_ids[to_inx],
                 &lps_mod_info->lp_rmvd_ids[from_inx], blksize);

           lps_mod_info->num_lps_rmvd -= lps_mod_info->lps_rmvd_prsf[sf_inx];
           blksize = (lps_mod_info->num_sfs - sf_inx -1 ) * 
                       sizeof(GRobjid);
           if (blksize)
           {
            OM_BLOCK_MOVE (lps_mod_info->sf_ids[sf_inx+1], 
               lps_mod_info->sf_ids[sf_inx], blksize);

            blksize = (lps_mod_info->num_sfs - sf_inx -1 ) * 
                       sizeof(IGRint);
            OM_BLOCK_MOVE (lps_mod_info->lps_added_prsf[sf_inx+1], 
               lps_mod_info->lps_added_prsf[sf_inx], blksize);

            OM_BLOCK_MOVE (lps_mod_info->lps_rmvd_prsf[sf_inx+1], 
               lps_mod_info->lps_rmvd_prsf[sf_inx], blksize);

           } /* if (blksize) */

           (lps_mod_info->num_sfs)--;
           
         } /* if (sf_exists) */

       } /* if (lps_mod_info->num_sfs) */

       OM_stat = EMmake_chanselect (GRconnector_to_owners, &to_owners_chan);
       EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror, wrapup);

       OM_stat = EMmake_chanselect (GRcmpowner_to_components, &to_comps_chan);
       EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

       OM_stat = om$get_objid_at_index (objid = cm_ed_sf_GRid.objid,
                  osnum = cm_ed_sf_GRid.osnum,
                  p_chanselect = &to_owners_chan,
                  index = 0, objidaddr = &sf_owner_GRid.objid,
                  osnumaddr = &sf_owner_GRid.osnum);
       EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

       OM_stat = om$get_index (osnum_c = sf_owner_GRid.osnum,
                        objid_c = sf_owner_GRid.objid,
                        p_chanselect = &to_comps_chan,
                        objid = cm_ed_sf_GRid.objid,
                        osnum2 = cm_ed_sf_GRid.osnum,
                        indexaddr = &composite_idx);
       EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror, wrapup);

       OM_stat = om$send (msg = message GRconnector.GRdisconn (&mthd_stat,
                           &sf_owner_GRid),
                          senderid = NULL_OBJID,
                          targetid = cm_ed_sf_GRid.objid,
                          targetos = cm_ed_sf_GRid.osnum);
       EMerr_hndlr (!(1&OM_stat&mthd_stat), *EFmsg, EMS_E_SurfaceError, wrapup);

       EFsetsfstate(&mthd_stat, cm_ed_sf_GRid.objid, cm_ed_sf_GRid.osnum,
                    EMS_O_OFF);
       EMerr_hndlr (!(1&mthd_stat),*EFmsg,EMS_E_SurfaceError,wrapup);

      num_elems = sfrmvd_info->num_sf_rmvd;
      INITIAL_SIZE = BUF_INC = 10;
      array_size = sfrmvd_info->sf_arrsz;
      EFmemory_allocation (&rc, 
            (IGRchar **) &sfrmvd_info->sf_ids, 
            num_elems + 1, &array_size, sizeof(GRobjid), 
            INITIAL_SIZE, BUF_INC);
      EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_NoDynamicMemory,wrapup);
      
      EFmemory_allocation (&rc, 
            (IGRchar **) &sfrmvd_info->sf_idx, 
            num_elems + 1, &sfrmvd_info->sf_arrsz, sizeof(IGRint), 
            INITIAL_SIZE, BUF_INC);
      EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_NoDynamicMemory,wrapup);
      
      compsf_exists = FALSE;
      from_inx = 0;

      for (cur_csf = 0 ; cur_csf < sfrmvd_info->num_compsf; cur_csf++)
      {
        from_inx += sfrmvd_info->num_sf_prcompsf[cur_csf];
        if (IF_EQ_OBJID(sf_owner_GRid.objid, 
                        sfrmvd_info->compsf_ids[cur_csf]))
        {
          compsf_exists = TRUE;
          break;
        }

      } /* for (cur_csf = 0 ; cur_csf < sfrmvd_info->num_compsf; 
                cur_csf++) */

      if (compsf_exists)
      {
        blksize = (sfrmvd_info->num_sf_rmvd - from_inx) * sizeof(GRobjid);
        if (blksize)
          OM_BLOCK_MOVE (&sfrmvd_info->sf_ids[from_inx],
                         &sfrmvd_info->sf_ids[from_inx+1], blksize);

        blksize = (sfrmvd_info->num_sf_rmvd - from_inx) * sizeof(IGRint);
        if (blksize)
          OM_BLOCK_MOVE (&sfrmvd_info->sf_ids[from_inx],
                         &sfrmvd_info->sf_ids[from_inx+1], blksize);

        sfrmvd_info->sf_ids[from_inx] = cm_ed_sf_GRid.objid;
        sfrmvd_info->sf_idx[from_inx] = composite_idx;
        (sfrmvd_info->num_sf_rmvd)++;
        (sfrmvd_info->num_sf_prcompsf[cur_csf])++;

      } /* if (compsf_exists) */
      else
      {
        num_elems = sfrmvd_info->num_compsf;
        INITIAL_SIZE = BUF_INC = 10;
        array_size = sfrmvd_info->compsf_arrsz;
        EFmemory_allocation (&rc, 
            (IGRchar **) &sfrmvd_info->compsf_ids, 
            num_elems + 1, &array_size, sizeof(GRobjid), 
            INITIAL_SIZE, BUF_INC);
        EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_NoDynamicMemory,wrapup);
      
        EFmemory_allocation (&rc, 
            (IGRchar **) &sfrmvd_info->num_sf_prcompsf, 
            num_elems + 1, &sfrmvd_info->compsf_arrsz, sizeof(IGRint), 
            INITIAL_SIZE, BUF_INC);
        EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_NoDynamicMemory,wrapup);
      
        sfrmvd_info->compsf_ids[num_elems] = sf_owner_GRid.objid;
        sfrmvd_info->num_sf_prcompsf[num_elems] = 1;
        (sfrmvd_info->num_compsf)++;
        num_elems = sfrmvd_info->num_sf_rmvd;
        sfrmvd_info->sf_ids[num_elems] = cm_ed_sf_GRid.objid;
        sfrmvd_info->sf_idx[num_elems] = composite_idx;
        (sfrmvd_info->num_sf_rmvd)++;

      } /* else for if (compsf_exists) */

      /*
       * Turn off 'ACTIVE' property bit of all of the loops
       * of the removed surface.
       */

      OM_stat = om$send (msg = message EMSboundary.EMtree_traverse (
                          &mthd_stat, message EMSloop.EMset_props (
                            &mthd_stat, EMLP_ACTIVE, EMS_O_OFF),
                          MAXINT, 1, &OPP_EMSloop_class_id, TRUE, NULL,
                          NULL, NULL),
                         senderid = NULL_OBJID,
                         targetid = ls_list.S_objid, 
                         targetos = ls_list.osnum);
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopsetError,wrapup);

     } /* else for if (rev_lp_md == EMS_MD_EXTRACT_LP ||
                       rev_lp_md == EMS_MD_DELETE_LP) */
     /*
      * connect the edge with its new common edge(s).
      * There are three possibilities based upon the
      * number of new_cmeds:
      *
      *  1) One new_cm_ed -- If the caller did not send
      *     new_ed (as in case of non-drafted surface), disconnect
      *     the edge from its current common ed. Connect
      *     the edge to its new common edge. Save ed_id,
      *     edge's old cm_ed_id, edge's new cm_ed id.
      *     If the caller sent a new edge, just connect it to 
      *     new common edge.
      *     
      *  2) Many new_cm_eds - If the caller did not send
      *     a new_edge, disconnect
      *     the edge from its common edge. Perform edge
      *     Matching. Connect the edge to its old_cm_ed if 
      *     new edge is not being sent in.
      *     The edge is disconnected originally as the
      *     stitching process only connectable edges.
      *
      *  3) No new-cm-eds - If the caller did not send a
      *     new_edge, copy the edge and replace it old_edge.
      *     This is because the old_cm_ed is inactive and
      *     thus should not be connected to the edge after
      *     the operation is over.
      */

     if (new_cm_eds.num_eds)
     {

       if (IF_EQ_OBJID(ed_GRid.objid, new_ed_GRid.objid) )
       {
         OM_stat = om$send (msg = message Root.wild_disconnect (
                             cm_ed_chan),
                          senderid = NULL_OBJID,
                          targetid = ed_GRid.objid, 
                          targetos = ed_GRid.osnum);
        EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);
       }

       old_ed_tbl.num_eds = 1;
       old_ed_tbl.ed_ids = &new_ed_GRid.objid;
       old_ed_tbl.sf_ids = &ed_new_sf_GRid.objid;

       EFed_match (&rc, &old_ed_tbl, &new_cm_eds, cur_os, md_env, 
                   ed_cn_info);
       EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_Fail,wrapup);

       if ( IF_EQ_OBJID(new_ed_GRid.objid, ed_GRid.objid) )
       {     
         if (new_cm_eds.num_eds == 1)
         {
           cur_idx = (ed_v0v1_info->num_eds) * 4;
           ed_v0v1_info->ed_ids[cur_idx++] = ed_GRid.objid;
           ed_v0v1_info->ed_ids[cur_idx++] = cm_ed_GRid.objid;
           ed_v0v1_info->ed_ids[cur_idx++] = new_cm_eds.ed_ids[0];
           ed_v0v1_info->ed_ids[cur_idx] = NULL_OBJID;
           (ed_v0v1_info->num_eds)++;

         } /* if (new_cm_eds.num_eds == 1) */
         else
         {
           OM_stat = om$send (msg = message Root.connect (cm_ed_chan,
                               NULL, cm_ed_GRid.objid, cm_ed_GRid.osnum,
                               cm_ed_chan, NULL),
                              senderid = NULL_OBJID,
                              targetid = ed_GRid.objid, 
                              targetos = ed_GRid.osnum);
           EMerr_hndlr (!(1&OM_stat),*EFmsg, EMS_E_OMerror, wrapup);

           EFcollect_ed_split_info (&rc, 1, &cm_ed_GRid.objid, cur_os,
                                ed_sp_info, lps_mod_info);
           EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_Fail,wrapup);

          } /* else for if (new_cm_eds.num_eds == 1) */
       
       } /* if ( IF_EQ_OBJID(new_ed_GRid.objid, ed_GRid.objid) ) */

     } /* if (new_cm_eds.num_eds) */
     else
     {
       /*
        * If there are no new common edges of the modified edge,
        * it will not go through edge matching. In such a case,
        * the new edge may still be connected to the old common
        * edge which is anactive after this operation and thus
        * will prevent the modified edge from connnecting to another edge.
        * The strategy to resolve this problem is:
        *  o If the ed_id is the same as new_ed_id.
        *    o Copy the modified edge and collapse it if needed.
        *    o Replace the modified edge by its copy and save this
        *      information.
        */

       if ( IF_EQ_OBJID(new_ed_GRid.objid, ed_GRid.objid) ) 
       {     
         OM_stat = om$send (msg = message EMSboundary.EMtpcopy (
                             &mthd_stat, md_env, cur_os,
                             cur_os, NULL, &cp_ed),
                            senderid = NULL_OBJID,
                            targetid = new_ed_GRid.objid,
                            targetos = new_ed_GRid.osnum);
         EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);
         stat = EMsend_loops (&mthd_stat,
                      message EMSboundary.EMget_objid ( &mthd_stat,
                       &lp_id),
                      new_ed_GRid.objid, NULL, OM_K_MAXINT, EMLP_ACTIVE,
                      NULL, NULL);
          EMerr_hndlr (!(1&stat&mthd_stat),*EFmsg,EMS_E_Fail,wrapup);

          OM_stat = om$get_index (osnum_c = cur_os, objid_c = lp_id,
                                  p_chanselect = &lp_ed_chan, 
                                  objid = new_ed_GRid.objid, 
                                  osnum2 = new_ed_GRid.osnum,
                                  indexaddr = &new_ed_inx);
          EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

          OM_stat = EMmake_chanselect (EMSedge_to_owner, &ed_lp_chan);
          EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

          OM_stat = om$send (msg = message Root.connect (ed_lp_chan,
                             new_ed_inx, lp_id, cur_os, lp_ed_chan, NULL),
                            senderid = NULL_OBJID,
                            targetid = cp_ed, targetos = cur_os);
          EMerr_hndlr (!(1&OM_stat),*EFmsg, EMS_E_OMerror, wrapup);
         
          OM_stat = om$send (msg = message EMSboundary.EMcompress_top (
                              &mthd_stat, &partolbasis, &cp_ed),
                             senderid = NULL_OBJID, targetid = cp_ed,
                             targetos = cur_os);
          EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

          OM_stat = om$send (msg = message Root.disconnect (lp_ed_chan,
                              new_ed_GRid.objid, cur_os, ed_lp_chan),
                             senderid = NULL_OBJID, targetid = lp_id,
                             targetos = cur_os);
          EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_OMerror,wrapup);

          array_size = ed_sp_info->eds_arrsz;
          INITIAL_SIZE = BUF_INC = 5;

          EFmemory_allocation (&rc, (IGRchar **) &ed_sp_info->ed_ids, 
                                ed_sp_info->num_eds + 1,
                               &array_size, sizeof(GRobjid), 
                               INITIAL_SIZE, BUF_INC);
          EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_NoDynamicMemory,wrapup);

          EFmemory_allocation (&rc, (IGRchar **) &ed_sp_info->sp_eds_pred,
                                ed_sp_info->num_eds + 1,
                               &ed_sp_info->eds_arrsz, sizeof(IGRint), 
                               INITIAL_SIZE, BUF_INC);
          EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_NoDynamicMemory,wrapup);

          EFmemory_allocation (&rc, (IGRchar **) &ed_sp_info->sp_eds, 
                                ed_sp_info->num_sp_eds + 1,
                               &ed_sp_info->sp_eds_arrsz, 
                               sizeof(GRobjid), INITIAL_SIZE, BUF_INC);
          EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_NoDynamicMemory,wrapup);

          ed_sp_info->ed_ids[ed_sp_info->num_eds] = new_ed_GRid.objid;
          ed_sp_info->sp_eds_pred[(ed_sp_info->num_eds)++] = 1;
          ed_sp_info->sp_eds[(ed_sp_info->num_sp_eds)++] = cp_ed;

       } /* if ( IF_EQ_OBJID(new_ed_GRid.objid, ed_GRid.objid) ) */

     } /* else for if (new_cm_eds.num_eds) */

  /*
   * Display the modified common edge's surface if it has not been
   * extracted.
   */

  if (rev_lp_md != EMS_MD_EXTRACT_SF)
  {
    if ((dis_options & EMS_DO_DISPLAY) &&
        !(dis_options & EMS_DONT_REDRAW))
    {
      DisplayMode = GRbd;
      OM_stat = om$send(msg = message GRgraphics.GRdisplay (&mthd_stat,
                              &md_env->md_env.matrix_type,
                              md_env->md_env.matrix, &DisplayMode,
                              &md_env->md_id),
                     senderid = NULL_OBJID,
                     targetid = cm_ed_sf_GRid.objid, 
                     targetos = cm_ed_sf_GRid.osnum);
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_SurfaceError,wrapup);
    }
  } /* if (rev_lp_md != EMS_MD_EXTRACT_SF) */

 wrapup:

  if (imp_lp_id) om$dealloc (ptr = imp_lp_id);
  if (new_geom.poles) om$dealloc (ptr = new_geom.poles);
  if (new_geom.knots) om$dealloc (ptr = new_geom.knots);
  if (new_geom.weights) om$dealloc (ptr = new_geom.weights);
  if (new_geom.bdrys) om$dealloc (ptr = new_geom.bdrys);

  if (lps_rmvd) EMownercomp_free(lps_rmvd,NULL);

  if (trim_info)
  {
    for (i = 0; i < *num_bdrys; i++)
      EMsfintedpar_free(trim_info[i],2);
        
    om$dealloc(ptr = trim_info);
  }

  if (out_bdrys)
  {
    for (i = 0; i < *num_bdrys; i++)
      EMsfintedpar_free(out_bdrys[i],2);
        
    om$dealloc(ptr = out_bdrys);
  }
  if (against_bdrys) om$dealloc (ptr = against_bdrys);
  if (lp_bdrys) om$dealloc (ptr = lp_bdrys);
  if (lp_ids) om$dealloc (ptr = lp_ids);
  if (num_bdrys) om$dealloc (ptr = num_bdrys);
  if (trim_lps) om$dealloc (ptr = trim_lps);
  
  if (new_cm_eds.ed_ids) om$dealloc (ptr = new_cm_eds.ed_ids);
  if (new_cm_eds.sf_ids) om$dealloc (ptr = new_cm_eds.sf_ids);

  if (new_lps_added) om$dealloc (ptr = new_lps_added);
  if (work_ids) om$dealloc (ptr = work_ids);
  if (ls_sp_eds) om$dealloc (ptr = ls_sp_eds);

  EMWRAPUP (*EFmsg, OM_stat, "In EFtrim_cm_ed_sf");
  return;

} /* end  EFtrim_cm_ed_sf */

void  EFmake_curve_with_2pts (
              EFmsg,
              cv_geom,
              poles,
              knots)

  IGRlong                   *EFmsg;
  struct      IGRbsp_curve  *cv_geom;
  IGRdouble                 *poles, *knots;
  {
    *EFmsg = EMS_S_Success;
    cv_geom->order = 2;
    cv_geom->periodic = FALSE;
    cv_geom->non_uniform = FALSE;
    cv_geom->num_poles = 2;
    cv_geom->num_knots = 4;
    cv_geom->rational = FALSE;
    cv_geom->planar = TRUE;
    cv_geom->phy_closed = FALSE;
    cv_geom->num_boundaries = 0;
    cv_geom->poles = poles;
    knots[0] = knots[1] = 0.;
    knots[2] = knots[3] = 1.;
    cv_geom->knots = knots;
    cv_geom->weights = NULL;
    cv_geom->bdrys = NULL;
    return;  

} /* void  EFmake_curve_with_2pts */

/*
 * Given two EMSlft_edmtch_info structures containing
 * two sets of edges, this function performs the
 * edge matching and connects apprpriate edges.
 * Also, if an edge has a common edge, it saves its
 * old and new common edge and returns the information
 * in EMSlft_edcn_info structure.
 */

void  EFed_match (
             EFmsg, 
             ed_tbl1, 
             ed_tbl2,
             cur_os,
             md_env,
             ed_cn_info)

  IGRlong                     *EFmsg;
  struct EMSlft_edmtch_info   *ed_tbl1, *ed_tbl2;
  GRspacenum                  cur_os;
  struct GRmd_env             *md_env;
  struct EMSlft_edcn_info    *ed_cn_info;

{
  struct IGRbsp_surface       **sfs_geom;
  struct EMSlft_edmtch_info   *one_ed_tbl, *many_ed_tbl;
  struct EMSstitch_info       stitch_pair;
  OM_S_CHANSELECT             cm_ed_chan;

  IGRlong                     OM_stat, mthd_stat, rc;
  IGRint                      num_sfs = 0, i;
  GRobjid                     *sfs_ids, from_ed, cm_node_ed;
  IGRboolean                  one_ed_tbl_moved = FALSE, many_ed_tbl_moved;
  extern void                 EFwill_cm_ed_mv_during_ed_matching(),
                              EFfill_cm_ed_movement_info(),
                              EFget_ed_sf_geom();


  OM_stat = OM_S_SUCCESS;
  *EFmsg = EMS_S_Success;
  sfs_geom = NULL;
  sfs_ids = NULL;
  
  OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &cm_ed_chan);
  EMerr_hndlr (!(1&OM_stat),*EFmsg, EMS_E_OMerror,wrapup);

  /*
   * The following assumptions are made while performing
   * edge matching.
   *
   * 1) The following combinations are possible between ed_tbl1
   *    and ed_tbl2:
   *
   *    a) One ed in ed_tbl1   --- One ed in ed_tbl2   (1:1)
   *    b) One ed in ed_tbl1   --- Many eds in ed_tbl2 (1:m)
   *    c) Many eds in ed_tbl1 --- One ed in ed_tbl2   (m:1)
   *
   *    If it 1:m or m:1, it is assumed that many edges are 
   *    saved in a particular direction w.r.t the one edge
   *    i.e., either going in the edge's logical direction
   *    or reverse direction.
   *
   *  2) The max num of surfaces shared by these edges is (m+1).
   */

   sfs_geom = (struct IGRbsp_surface **) om$malloc (size =
                sizeof(struct IGRbsp_surface *) * 
                (ed_tbl1->num_eds + ed_tbl2->num_eds) );
   EMerr_hndlr (!sfs_geom, *EFmsg, EMS_E_NoDynamicMemory,wrapup);

   sfs_ids = (GRobjid *) om$malloc (size = sizeof(GRobjid) *
                (ed_tbl1->num_eds + ed_tbl2->num_eds) );
   EMerr_hndlr (!sfs_ids, *EFmsg, EMS_E_NoDynamicMemory,wrapup);

   for ( i = 0; i < (ed_tbl1->num_eds + ed_tbl2->num_eds); i++)
     sfs_geom[i] = NULL;

   if (ed_tbl1->num_eds > 1 && ed_tbl2->num_eds > 1)
   {
     fprintf (stderr, "m:m case for edge matching\n");
     *EFmsg = EMS_E_Fail;
     goto wrapup;
   }
   else              /* 1:1, 1:m or m:1 case */
   {
     /*
      * The following step are involved in 1:1 edge matching
      * process:
      *
      * o If (ed_cn_info)
      *   o Check if ed_tbl1's edge(s) has a common edge. Disconnect
      *     it from its cm_ed and save its id.
      *   o Else check if ed_tbl2's edge(s) has a common edge. If so,
      *     disconnect it from its common edge and save its id.
      *   o Check for ed_tbl2 also.
      * o Perform edge matching.
      * o If (ed_cn_info)
      *   o Save the cm_ed id extracted above and the new cm_ed.
      */

     if (ed_tbl1->num_eds == 1)
     {
       one_ed_tbl = ed_tbl1;
       many_ed_tbl = ed_tbl2;
     }
     else
     {
       one_ed_tbl = ed_tbl2;
       many_ed_tbl = ed_tbl1;
     }

     /*
      * check if the ed_cn_info is requested by the user.
      * If so, the common edge of the one_ed_tbl edge 
      * will be moved only if the many_ed_tbl has only
      * one edge. It is due to the fact that in case many_ed_tbl
      * has more than one edge, one_ed_tbl's edge will be split and
      * its split edges will be connected to many_ed_tbl's edges. 
      */
        
     if (ed_cn_info && ( many_ed_tbl->num_eds == 1) )
     {
       EFwill_cm_ed_mv_during_ed_matching ( &rc, 
               one_ed_tbl->ed_ids[0], cur_os, &cm_ed_chan, 
              &one_ed_tbl_moved, &from_ed, &cm_node_ed);
       EMerr_hndlr (!(1&rc),*EFmsg, EMS_E_Fail, wrapup);

     } /* if (ed_cn_info && (many_ed_tbl->num_eds == 1) ) */
          
     EFget_ed_sf_geom ( &rc, one_ed_tbl->ed_ids[0], one_ed_tbl->sf_ids[0],
                         cur_os, md_env, &num_sfs, sfs_ids, sfs_geom,
                        &stitch_pair.surf_geom0);
     EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_Fail, wrapup);

     stitch_pair.edge0 = one_ed_tbl->ed_ids[0];
     stitch_pair.surf0 = one_ed_tbl->sf_ids[0];
     stitch_pair.edge_geom0 = NULL;
     stitch_pair.edge_geom1 = NULL;
     stitch_pair.option =  EMSstitch_NoMoveSurfs |
			   EMSstitch_NoOrientSurfs;

     for (i = 0; i < many_ed_tbl->num_eds; i++)
     {
        many_ed_tbl_moved = FALSE;

        /*
         * check if the ed_cn_info is requested by the user.
         * If so and one_ed_tbl edge is not going to move,
         * (which is the case if many_ed_tbl has more than
         *  one edge or one_ed_tbl's edge does not have a common
         *  edge), check if many_ed_tbl will have its edge(s)
         *  with common edge(s) moved..
         */
        
        if (ed_cn_info && !one_ed_tbl_moved)
        {
          EFwill_cm_ed_mv_during_ed_matching ( &rc, 
                 many_ed_tbl->ed_ids[i], cur_os, &cm_ed_chan, 
                 &many_ed_tbl_moved, &from_ed, &cm_node_ed);
          EMerr_hndlr (!(1&rc),*EFmsg, EMS_E_Fail, wrapup);

        } /* if (ed_cn_info) */
          
        stitch_pair.edge1 = many_ed_tbl->ed_ids[i];
        stitch_pair.surf1 = many_ed_tbl->sf_ids[i];
        EFget_ed_sf_geom ( &rc, stitch_pair.edge1, 
                            many_ed_tbl->sf_ids[i], cur_os, md_env, 
                           &num_sfs, sfs_ids, sfs_geom, 
                           &stitch_pair.surf_geom1);
        EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_Fail, wrapup);

        OM_stat = om$send (msg = message EMSedge.EMstitch (&mthd_stat,
                            &stitch_pair, md_env, NULL,
                            NULL, NULL, NULL, NULL),
                           senderid = NULL_OBJID,
                           targetid = stitch_pair.edge0,
                           targetos = cur_os);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

        if ( many_ed_tbl_moved )
        {
          EFfill_cm_ed_movement_info (&rc, from_ed, cm_node_ed, cur_os,
                                      &cm_ed_chan, ed_cn_info);
          EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_Fail,wrapup);

        } /* if ( many_ed_tbl_moved ) */

     } /* for (i = 0; i < many_ed_tbl->num_eds; i++) */
 
  } /* end 1:1, 1:m or m:1 case */
 
  if ( one_ed_tbl_moved )
  {
     EFfill_cm_ed_movement_info (&rc, from_ed, cm_node_ed, cur_os,
                                 &cm_ed_chan, ed_cn_info);
     EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_Fail,wrapup);

   } /* if ( one_ed_tbl_moved ) */

 wrapup:
   EMWRAPUP (*EFmsg, OM_stat, "In EFed_match ");

   if (num_sfs)
   {
    for (i = 0; i < num_sfs; i++)
      if (sfs_geom[i]) om$dealloc (ptr = sfs_geom[i]);
    if (sfs_geom) om$dealloc (ptr = sfs_geom);
   }
   if (sfs_ids) om$dealloc (ptr = sfs_ids);

   return;
} /* end EFed_match () */


void EFget_ed_sf_geom (
            EFmsg,
            ed_id,
            sf_id,
            cur_os,
            md_env,
            num_sfs,
            sfs_ids,
            sfs_geom,
            ed_sf_geom)

      IGRlong                *EFmsg;
      GRobjid                ed_id, sf_id, *sfs_ids;
      GRspacenum             cur_os;
      struct GRmd_env        *md_env;
      IGRint                 *num_sfs;
      struct IGRbsp_surface  **sfs_geom, **ed_sf_geom;
     
    {
       IGRlong     OM_stat, mthd_stat;
       IGRboolean  sf_geom_exists = FALSE;
       IGRint      cur_sf = 0;
       struct GRid sf_GRid;

       *EFmsg = EMS_S_Success;
       OM_stat = OM_S_SUCCESS;

       while (cur_sf < *num_sfs && !sf_geom_exists)
       {
           if (sfs_ids[cur_sf] == sf_id ) sf_geom_exists = TRUE;
           else cur_sf++;
       } 

       if (!sf_geom_exists)
       {
         sf_GRid.objid = sf_id;
         sf_GRid.osnum = cur_os;

         OM_stat = om$send (msg = message EMSedge.EMget_sf_geom (
                             &mthd_stat,
                             &sf_GRid, &sfs_geom[cur_sf], 
                             &md_env->md_env),
                            senderid = NULL_OBJID, 
                            targetid = ed_id, targetos = cur_os);
         EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);
        
         (*num_sfs)++;
         sfs_ids[cur_sf] = sf_id;

       } /* if (!sf_geom_exists) */

       *ed_sf_geom = sfs_geom[cur_sf];
 
   wrapup:
     EMWRAPUP (*EFmsg, OM_stat, "In EFget_ed_sf_geom");

     return;
      
 } /* end  EFget_ed_sf_geom */
     

/*
 * Given a) a loop, b) start_idx and end_idx of its edges from
 * the loop's point of view:
 * 
 * 1) If the edge is in the reject list, take it out of
 *    the reject list and donot process it furhter. This will
 *    be the case when an edge as well as its common edge is trimmed
 *    while trimming two consequtive edges.
 *
 * 2) If it is not case 1, check if the edge has a common edge.
 *    If so, put its common edge id and common_edge's surface id
 *    in the output list.
 */

void EFcollect_eds (
            EFmsg,
            lp_id,
            num_lp_eds,
            lp_props,
            start_inx,
            end_inx,
            cur_os,
            out_list,
            reject_list)

     IGRlong                       *EFmsg;
     GRobjid                       lp_id;
     IGRushort             lp_props;
     IGRint                        start_inx, end_inx, num_lp_eds;
     GRspacenum                    cur_os;
     struct   EMSlft_edmtch_info   *out_list, *reject_list;

{
   OM_S_OBJECT_LINKAGE    dum_list;
   OM_S_CHANSELECT        lp_ed_chan, cm_ed_chan;
   IGRlong                OM_stat, mthd_stat, rc;
   IGRint                 i, j, num_eds = 0, num_elems,
                          INITIAL_SIZE = 10, BUF_INC = 10, array_size,
                          from_inx[2], to_inx[2], num_cycles = 0,
                          incr, cur_cycle, cur_inx;
   OMuint                 count;
   GRobjid                dum_id;
   GRspacenum             dum_os;
   OMuint                 num_cm_ed, blksize;
   IGRboolean             ed_exists;
   extern void            EFmemory_allocation();

   *EFmsg = EMS_S_Success;
   OM_stat = OM_S_SUCCESS;

   if (lp_props & EMLP_REVERSED)
   {
    incr = -1; 
    if (start_inx < end_inx)
    {
      num_cycles = 2;
      from_inx[0] = start_inx;
      to_inx[0] = 0;
      from_inx[1] = num_lp_eds - 1;
      to_inx[1] = end_inx;

    } /* if (start_inx < end_inx) */
    else
    {
      num_cycles = 1;
      from_inx[0] = start_inx;
      to_inx[0] = end_inx;

    } /* else for if (start_inx < end_inx) */

   } /* if (lp_props & EMLP_REVERSED) */
   else
   {
     incr = 1;
     if (start_inx > end_inx)
     {
       num_cycles = 2;
       from_inx[0] = start_inx;
       to_inx[0] = num_lp_eds - 1;
       from_inx[1] = 0;
       to_inx[1] = end_inx;
     } /* if (start_inx > end_inx) */
     else
     {
       num_cycles = 1;
       from_inx[0] = start_inx;
       to_inx[0] = end_inx;
     } /* else for if (start_inx > end_inx) */

   } /* else for if (lp_props & EMLP_REVERSED) */

   OM_stat = EMmake_chanselect (EMSbd_owner_to_comps, &lp_ed_chan);
   EMerr_hndlr (!(1&OM_stat),*EFmsg, EMS_E_OMerror, wrapup);

   OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &cm_ed_chan);
   EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

   num_elems = 0;
   for (cur_cycle = 0; cur_cycle < num_cycles; cur_cycle++)
     num_elems += (to_inx[cur_cycle] > from_inx[cur_cycle] ?
                   (to_inx[cur_cycle] - from_inx[cur_cycle] + 1) :
                   (from_inx[cur_cycle] - to_inx[cur_cycle] + 1) );

   num_elems += out_list->num_eds;
   array_size = out_list->array_size;

   EFmemory_allocation (&rc, (IGRchar **) &out_list->ed_ids, num_elems, 
                        &array_size, sizeof(GRobjid), 
                        INITIAL_SIZE, BUF_INC);
   EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_NoDynamicMemory,wrapup);

   EFmemory_allocation (&rc, (IGRchar **) &out_list->sf_ids, num_elems,
                        &out_list->array_size, sizeof(GRobjid), 
                        INITIAL_SIZE, BUF_INC);
   EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_NoDynamicMemory,wrapup);

   for (cur_cycle = 0; cur_cycle < num_cycles; cur_cycle++)
   {
     num_eds = out_list->num_eds;
     num_elems = (to_inx[cur_cycle] > from_inx[cur_cycle] ?
                  (to_inx[cur_cycle] - from_inx[cur_cycle] + 1) :
                  (from_inx[cur_cycle] - to_inx[cur_cycle] + 1) );
     cur_inx = from_inx[cur_cycle];

     /*
      * 1. get the edge id.
      * 2. check if it is in the reject list. If so take its entry
      *     out of reject list.
      * 3. If not in the reject list, check if it has a common edge.
      *    If so, put its common_ed_id as well as common_ed'sf_id in
      *    the output list.
      */

     for (i = 0; i < num_elems; i++, cur_inx += incr)
     {

       OM_stat = om$get_objid_at_index (osnum = cur_os, objid = lp_id,
                      p_chanselect = &lp_ed_chan, index = cur_inx, 
                      objidaddr = &dum_id, osnumaddr= &dum_os);
       EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

       ed_exists = FALSE;

       if (reject_list->num_eds)
       {
         for (j = 0; j < reject_list->num_eds; j++)
          if (reject_list->ed_ids[j] == dum_id)
          { 
            ed_exists = TRUE;
            break;
          }
 
         if (ed_exists)
         {
          blksize = sizeof(GRobjid) * (reject_list->num_eds- 1 - j);
          if (blksize)
               OM_BLOCK_MOVE (&reject_list->ed_ids[j+1], 
                              &reject_list->ed_ids[j], blksize);
          (reject_list->num_eds)--;

         } /* if (ed_exists) */
 
       } /* if (reject_list->num_eds) */
 
       if (!ed_exists)
       {
        OM_stat = om$get_channel_count ( osnum = dum_os, objid =dum_id,
                        p_chanselect = &cm_ed_chan, count = &num_cm_ed);
        EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

        if (num_cm_ed)
        {
           OM_stat = om$get_channel_objects (osnum = dum_os, 
                       objid = dum_id,
                       p_chanselect = &cm_ed_chan, list = &dum_list,
                       size = 1, count = &count);
           EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror, wrapup);
            
           out_list->ed_ids[num_eds] = dum_list.S_objid;

           OM_stat = om$send (msg = message EMSboundary.EMgetsurface_info
                                (&mthd_stat, &out_list->sf_ids[num_eds++],
                                  NULL ),
                               senderid = NULL_OBJID,
                               targetid = dum_list.S_objid, 
                               targetos = dum_list.osnum);
           EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);
        } /* if (num_cm_ed) */

       } /* if (!ed_exists) */

     } /* for (i = 0; i < num_elems; i++, cur_inx += incr) */

     out_list->num_eds = num_eds;

   } /* for (cur_cycle = 0; cur_cycle < num_cycles; cur_cycle++) */

 wrapup:
   EMWRAPUP (*EFmsg, OM_stat, "In EFcollect_eds");
   return;

}/* void EFcollect_eds ( ) */

void EFcollect_ed_split_info(
             EFmsg,
             num_input_eds,
             ed_ids,
             cur_os,
             ed_sp_info,
	     lps_mod_info)

  IGRlong                      *EFmsg;
  IGRint                       num_input_eds;
  GRobjid                      *ed_ids;
  GRspacenum                   cur_os;
  struct EMSlft_edsp_info      *ed_sp_info;
  struct EMSlft_lpmod_info     *lps_mod_info;    /* Added this argument to fix
						    ITR 369 - Ashok 27-Jan-92
						 */
  
{
  OM_S_CHANSELECT       cm_ed_chan, lp_ls_chan;
  OM_S_OBJECT_LINKAGE   cm_ed_list, ls_list;
  IGRlong               OM_stat, mthd_stat, rc;
  IGRint                i, j, num_sp_eds, num_eds, sp_factor,
                        array_size, INITIAL_SIZE = 10, BUF_INC = 10, sts,
                        cur_ed, sp_ed_fr_inx, sp_ed_to_inx, from_inx,
                        to_inx;
  OMuint                blksize, count;
  IGRboolean            ed_exists;
  GRobjid               lp_id;
  IGRushort     props;
  IGRboolean            lp_exists;    /* Added to fix ITR 369 - Ashok */
  extern void           EFmemory_allocation();



  OM_stat = OM_S_SUCCESS;
  *EFmsg = EMS_S_Success;

  /*
   * For each edge,
   *  o Get its cm_ed_id.
   *  o Get the top part edges of the cm_ed.
   *  o Store the cm_ed_id and its top part edges.
   *  o Get the active loop and the loopset id of one
   *    of the top part edges. 
   *  o Turn off EMLP_NATURAL of the loop and
   *    EMLS_NATURAL of the loopset.
   */

  OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &cm_ed_chan);
  EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

  OM_stat = EMmake_chanselect (EMSloop_to_outter, &lp_ls_chan);
  EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

  array_size = ed_sp_info->eds_arrsz;

  EFmemory_allocation (&rc, (IGRchar **) &ed_sp_info->ed_ids, 
                 ed_sp_info->num_eds+num_input_eds,
                &array_size, sizeof(GRobjid), 
                 INITIAL_SIZE, BUF_INC);
   EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_NoDynamicMemory,wrapup);

   EFmemory_allocation (&rc, (IGRchar **) &ed_sp_info->sp_eds_pred,
                         ed_sp_info->num_eds+num_input_eds,
                        &ed_sp_info->eds_arrsz, sizeof(IGRint), 
                         INITIAL_SIZE, BUF_INC);
   EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_NoDynamicMemory,wrapup);

   sp_factor = 3;         
   EFmemory_allocation (&rc, (IGRchar **) &ed_sp_info->sp_eds, 
                         ed_sp_info->num_sp_eds+sp_factor*(num_input_eds),
                        &ed_sp_info->sp_eds_arrsz, sizeof(GRobjid), 
                         INITIAL_SIZE, BUF_INC);
   EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_NoDynamicMemory,wrapup);

   for (i = 0; i < num_input_eds; i++)
   {
     OM_stat = om$get_channel_objects (osnum = cur_os,
                  objid = ed_ids[i], p_chanselect = &cm_ed_chan,
                  list = &cm_ed_list, size = 1, count = &count);
     EMerr_hndlr (!(1&OM_stat),*EFmsg, EMS_E_OMerror, wrapup);

     ed_exists = FALSE;
     cur_ed = 0;
     sp_ed_fr_inx = 0;
     while (!ed_exists && cur_ed < ed_sp_info->num_eds)
     {
       sp_ed_to_inx = sp_ed_fr_inx + ed_sp_info->sp_eds_pred[cur_ed];
       while (!ed_exists && sp_ed_fr_inx < sp_ed_to_inx)
       {
         if (IF_EQ_OBJID (cm_ed_list.S_objid,
                          ed_sp_info->sp_eds[sp_ed_fr_inx]) )
           ed_exists = TRUE;
         else
          sp_ed_fr_inx++;

       }/* while (!ed_exists && cur_sp_ed <
                  ed_sp_info->sp_eds_pred[cur_ed])*/

       if (!ed_exists) cur_ed++;

     } /* while (!ed_exists && cur_ed < ed_sp_info->num_eds) */

     if (ed_exists)
     {
       cm_ed_list.S_objid = ed_sp_info->ed_ids[cur_ed];
       to_inx = 0;
/* FIXED potential bug.... "i" is already indexed by the outer "for" loop- Ashok
       for (i = 0; i < cur_ed; i++)
         to_inx += ed_sp_info->sp_eds_pred[i];
*/
       for (j = 0; j < cur_ed; j++)
         to_inx += ed_sp_info->sp_eds_pred[j];
       from_inx = to_inx + ed_sp_info->sp_eds_pred[cur_ed];
       ed_sp_info->num_sp_eds -= ed_sp_info->sp_eds_pred[cur_ed];
       blksize = (ed_sp_info->num_sp_eds - to_inx) * sizeof(GRobjid);

       if (blksize)
       {
         OM_BLOCK_MOVE (&ed_sp_info->sp_eds[to_inx],
                        &ed_sp_info->sp_eds[from_inx], blksize);
         blksize = (ed_sp_info->num_eds - cur_ed - 1) * sizeof(GRobjid);
         OM_BLOCK_MOVE (&ed_sp_info->ed_ids[cur_ed+1],
                        &ed_sp_info->ed_ids[cur_ed], blksize );
         OM_BLOCK_MOVE (&ed_sp_info->sp_eds_pred[cur_ed+1],
                      &ed_sp_info->sp_eds_pred[cur_ed], blksize );

       } /* if (blksize) */
       (ed_sp_info->num_eds)--;

     } /* if (ed_exists) */

     num_sp_eds = ed_sp_info->num_sp_eds;
     OM_stat = om$send (msg = message EMSedge.EMget_top_part_edges(
                         &mthd_stat, &ed_sp_info->sp_eds,
                         &num_sp_eds, &ed_sp_info->sp_eds_arrsz),
                        senderid = NULL_OBJID,
                        targetid = cm_ed_list.S_objid,
                        targetos = cm_ed_list.osnum);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

     /*
      * The common edge that is split and its split edges
      * will have EMED_SPLIT, EMED_BEGINSPLIT and EMED_ENDSPLIT
      * property bits on. Turn them off before it screws up the
      * model during next closure.
      */

/*************
     props = EMED_SPLIT | EMED_BEGINSPLIT | EMED_ENDSPLIT;

     OM_stat = om$send (msg = message EMSedge.EMset_props (&mthd_stat,
                         props, EMS_O_OFF),
                        senderid = NULL_OBJID,     
                        targetid = cm_ed_list.S_objid,
                        targetos = cm_ed_list.osnum);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

     for ( j = ed_sp_info->num_sp_eds; j < num_sp_eds; j++)
     {
       OM_stat = om$send (msg = message EMSedge.EMset_props (&mthd_stat,
                           props, EMS_O_OFF),
                          senderid = NULL_OBJID,
                          targetid = ed_sp_info->sp_eds[j],
                          targetos = cur_os);
       EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

      } 
************/
/* for ( j = ed_sp_info->num_sp_eds; j < num_sp_eds; j++) */

      sts = EMsend_loops (&mthd_stat,
                    message EMSboundary.EMget_objid( &mthd_stat, &lp_id),
                      ed_sp_info->sp_eds[num_sp_eds-1], NULL, 
                      OM_K_MAXINT, EMLP_ACTIVE, NULL, NULL);
      EMerr_hndlr(!(1&sts&mthd_stat),*EFmsg,EMS_E_Fail,wrapup);

/* Added Check to see whether the edges should be saved or not. The are saved
   only if the loop is not already saved as an "added-loop" (ITR 369) - Ashok 
*/
      lp_exists = FALSE;
      for ( j = 0; !lp_exists && j < lps_mod_info->num_lps_added; j++ )
         if (IF_EQ_OBJID (lp_id, lps_mod_info->lp_added_ids[j]) )
		lp_exists = TRUE;

      if( !lp_exists )
      {

         num_eds = ed_sp_info->num_eds;
         ed_sp_info->ed_ids[num_eds] = cm_ed_list.S_objid;
         ed_sp_info->sp_eds_pred[num_eds]=num_sp_eds- ed_sp_info->num_sp_eds;
                      
         ed_sp_info->num_sp_eds = num_sp_eds;
         (ed_sp_info->num_eds)++;
      }
      
/* Moved this block up (ITR 369) - Ashok
      sts = EMsend_loops (&mthd_stat,
                    message EMSboundary.EMget_objid( &mthd_stat, &lp_id),
                      ed_sp_info->sp_eds[num_sp_eds-1], NULL, 
                      OM_K_MAXINT, EMLP_ACTIVE, NULL, NULL);
      EMerr_hndlr(!(1&sts&mthd_stat),*EFmsg,EMS_E_Fail,wrapup);
*/        
      /*
       * It may be possible that the loop of the common edge
       * was a natural one before splitting and after splitting
       * has become non natural. It is therefore needed to
       * turn EMLP_NATURAL off. Also turn off the EMLS_NATURAL
       * bit of the loopset owning this loop. This will be
       * possible for natural loop.
       */

      OM_stat = om$send (msg = message EMSloop.EMget_props(&mthd_stat,
                              &props),
                             senderid = NULL_OBJID,
                             targetid = lp_id, targetos = cur_os);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopError,wrapup);
         
      if (props & EMLP_NATURAL)
      {
        props = EMLP_NATURAL;
        OM_stat = om$send (msg = message EMSloop.EMset_props(
                            &mthd_stat, props, EMS_O_OFF),
                           senderid = NULL_OBJID,
                           targetid = lp_id, targetos = cur_os);

        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopError,wrapup);
        
        OM_stat = om$get_channel_objects (osnum = cur_os,
                     objid = lp_id, p_chanselect = &lp_ls_chan,
                     list = &ls_list, size = 1, count = &count);
        EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

        props = EMLS_NATURAL;
        OM_stat = om$send (msg = message EMSloopset.EMset_props (
                        &mthd_stat, props, EMS_O_OFF),
                        senderid = NULL_OBJID,
                        targetid = ls_list.S_objid, targetos = cur_os);
        EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopsetError,wrapup);

      }/* if (props & EMLP_NATURAL) */

   } /* for (i = 0; i < num_eds; i++) */

wrapup:
 EMWRAPUP (*EFmsg, OM_stat, "In EFcollect_ed_split_info ");
 return;

} /* void EFcollect_ed_split_info () */


void EFsave_edges_for_edge_matching (
             EFmsg,
             from_info,
             to_info)
  IGRlong                      *EFmsg;
  struct EMSlft_edmtch_info    *from_info, *to_info;

{
  IGRlong  rc;
  OMuint   blksize;
  IGRint   INITIAL_SIZE = 10, BUF_INC = 10, array_size;
  extern void     EFmemory_allocation();

  *EFmsg = EMS_S_Success;
  array_size = to_info->array_size;
  EFmemory_allocation (&rc, (IGRchar **) &to_info->ed_ids, 
                        from_info->num_eds, &array_size, 
                        sizeof(GRobjid), INITIAL_SIZE, BUF_INC);
  EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_NoDynamicMemory,wrapup);

  EFmemory_allocation (&rc, (IGRchar **) &to_info->sf_ids, 
                        from_info->num_eds, &to_info->array_size, 
                        sizeof(GRobjid), INITIAL_SIZE, BUF_INC);
  EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_NoDynamicMemory,wrapup);

  to_info->num_eds = from_info->num_eds;
  blksize = sizeof(GRobjid) * (from_info->num_eds);
  OM_BLOCK_MOVE (from_info->ed_ids, to_info->ed_ids, blksize);
  OM_BLOCK_MOVE (from_info->sf_ids, to_info->sf_ids, blksize);

wrapup:
  return;

} /* void EFsave_edges_for_edge_matching () */

/*
 * The following function is used to fill the common edge
 * movement info.
 */

void EFfill_cm_ed_movement_info (
              EFmsg,
              from_ed,
              cm_node_ed,
              cur_os,
              cm_ed_chan,
              ed_cn_info)

   IGRlong                  *EFmsg;
   GRobjid                  from_ed, cm_node_ed;
   GRspacenum               cur_os;
   OM_S_CHANSELECT          *cm_ed_chan;
   struct EMSlft_edcn_info  *ed_cn_info;

{

  OM_S_OBJECT_LINKAGE cm_ed_list;
  IGRlong             OM_stat, rc;
  IGRint              num_eds, INITIAL_SIZE = 10, BUF_INC = 10;
  OMuint              count;
  extern void         EFmemory_allocation();


  *EFmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  num_eds = (ed_cn_info->num_eds)*2;
  EFmemory_allocation (&rc, (IGRchar **) &ed_cn_info->ed_ids, num_eds + 2,
                       &ed_cn_info->array_size, sizeof(GRobjid), 
                        INITIAL_SIZE, BUF_INC);
  EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_NoDynamicMemory,wrapup);

  OM_stat = om$get_channel_objects (objid = cm_node_ed,
                    osnum = cur_os, p_chanselect = cm_ed_chan,
                    list = &cm_ed_list, size = 1, count = &count);
  EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

  ed_cn_info->ed_ids[num_eds] = from_ed;
  ed_cn_info->ed_ids[num_eds+1] = cm_ed_list.S_objid;
  (ed_cn_info->num_eds)++;

wrapup:

   EMWRAPUP (*EFmsg, OM_stat, "In EFfill_cm_ed_movement_info");
   return;

} /* void EFfill_cm_ed_movement_info () */

/*
 * The following function determines whether the edge
 * has a common edge or not. If so, it will disconnect
 * the edge from its common edge and save both of the
 * edges' objids. This function is used before edge matching
 * of two given edges. This is done to make sure that
 * edge to be used in edge matching does not have
 * a common edge and if so, to dissolve this connection
 * and to save this information.
 */

void EFwill_cm_ed_mv_during_ed_matching (
             EFmsg,
             ed_id,
             cur_os,
             cm_ed_chan,
             cm_ed_moved,
             from_ed,
             cm_node_ed)

  IGRlong           *EFmsg;
  GRobjid           ed_id, *from_ed, *cm_node_ed;
  OM_S_CHANSELECT   *cm_ed_chan;
  GRspacenum        cur_os;
  IGRboolean        *cm_ed_moved;

{
  OM_S_OBJECT_LINKAGE     cm_ed_list;
  IGRlong                 OM_stat;
  OMuint                  num_cm_ed;

  OM_stat = OM_S_SUCCESS;
  *EFmsg = EMS_S_Success;    

  *cm_ed_moved = FALSE;

  OM_stat = om$get_channel_count (objid = ed_id,
                    osnum = cur_os, p_chanselect = cm_ed_chan,
                    count = &num_cm_ed);
  EMerr_hndlr (!(1&OM_stat),*EFmsg, EMS_E_OMerror,wrapup);

  if (num_cm_ed)
  {
     OM_stat = om$get_channel_objects (objid = ed_id,
                     osnum = cur_os, p_chanselect = cm_ed_chan,
                     list = &cm_ed_list, size = 1,
                     count = &num_cm_ed);
     EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror, wrapup);
       
     OM_stat = om$send (msg = message Root.wild_disconnect (*cm_ed_chan),
                        senderid = NULL_OBJID, targetid = ed_id,
                        targetos = cur_os);
     EMerr_hndlr (!(1&OM_stat),*EFmsg, EMS_E_OMerror,wrapup);

     *from_ed = cm_ed_list.S_objid;
     *cm_node_ed = ed_id;
     *cm_ed_moved = TRUE;

   } /* if (num_cm_ed) */

wrapup:
 EMWRAPUP (*EFmsg, OM_stat, "In  EFwill_cm_ed_mv_during_ed_matching");
 return;

} /*  EFwill_cm_ed_mv_during_ed_matching () */

void  EFmemory_allocation (
                 rc,
                 array,
                 num_elem,
                 array_size,
                 struct_size, 
                 initial_size, 
                 buf_inc)

 IGRlong     *rc;
 IGRchar     **array;
 IGRint      num_elem, *array_size;
 OMuint      struct_size, initial_size, buf_inc;
  
 {
    *rc = EMS_S_Success;
     
    if ( !(*array_size) )
    {
      *array_size = (num_elem > initial_size) ?
                     num_elem : initial_size;

      *array = om$malloc (size =  (*array_size) * struct_size);
      EMerr_hndlr (!(*array),*rc,EMS_E_NoDynamicMemory,wrapup);
    }
    else if (num_elem > *array_size )
    {
       (*array_size) = ((*array_size + buf_inc) > num_elem) ?
                        (*array_size + buf_inc) : num_elem;

       *array = om$realloc (ptr = *array, 
                            size = (*array_size) * struct_size );
        EMerr_hndlr (!(*array),*rc,EMS_E_NoDynamicMemory,wrapup);
    }

   wrapup:       
    return;
           
 } /* void  EFmemory_allocation () */

void EFfix_the_trim_info (
             EFmsg,
             lp_bdrys,
             against_bdrys,
             num_bdrys,
             ls_id,
             cur_os,
             reject_ed_ids,
             num_eds,
             partolbasis)

  IGRlong                    *EFmsg;
  struct EMSsfintedpar       **lp_bdrys, **against_bdrys;
  IGRint                     num_bdrys;
  GRobjid                    ls_id, *reject_ed_ids;
  GRspacenum                 cur_os;   
  IGRint                     num_eds;
  struct EMSpartolbasis      *partolbasis;
{

  struct   EMSsfintedpar   *cur_lp_bdry = NULL, *cur_against_bdry = NULL;
  struct   EMSproj_info    proj_info;
  IGRdouble                *ed_fixed_pt;
  IGRlong                  OM_stat, mthd_stat, rc;
  IGRint                   i;
  GRobjid                  ed_id, ls_ed_id;
  IGRboolean               cntinue, fix_lp_bdry_ed, start_pt;
  IGRshort                 which_end_pt;
  extern void              EFfix_ed_geometry();

  *EFmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  for (i = 0; i < num_bdrys; i++)
  {
    start_pt = TRUE;
    cntinue = TRUE;

    while (cntinue)
    {
      cur_lp_bdry = start_pt ? lp_bdrys[i] : cur_lp_bdry->next;
      cur_against_bdry = start_pt ? against_bdrys[i] : 
                                              cur_against_bdry->next;
      start_pt = FALSE;

      if (cur_against_bdry)
      {
        ed_id = cur_against_bdry->edgeid;
        fix_lp_bdry_ed = FALSE;

        if ( IF_NULL_OBJID(ed_id) )
        {
          /*
           * o Get the point from the corresponding cur_lp_bdry.
           * o Perform a minimum distance test on the against loopset
           *   using the above point.
           * o Check if the distance between the projected point
           *   and the above end point is within 5 * par_tol.
           *   If so, modify the cur_against_bdry,
           *   the cur_lp_bdry and the geometry of the edge for
           *   cur_lp_bdry appropriately.
           */

          OM_stat = om$send (msg = message EMSloopset.EMptproject (
                              &mthd_stat, cur_lp_bdry->point, 1,
                              &proj_info, &ls_ed_id, partolbasis),
                             senderid = NULL_OBJID,
                             targetid = ls_id, targetos = cur_os);
          EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopsetError,wrapup);

          if ( 5 * partolbasis->tol >= proj_info.dist)
          {
            cur_against_bdry->intloc = proj_info.location;
            cur_against_bdry->edgeid = ls_ed_id;
            OM_BLOCK_MOVE (&proj_info.param, &cur_against_bdry->edgepar,
                           sizeof(struct EMSedgebound));
            OM_BLOCK_MOVE (proj_info.proj_pt, cur_against_bdry->point,
                           2 * sizeof(IGRdouble));
            cur_against_bdry->info = NULL;

            EFfix_the_intloc (&rc, 1, &ls_ed_id, cur_os, 
                    cur_against_bdry, &fix_lp_bdry_ed, &ed_fixed_pt,
                    partolbasis);
            EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_Fail,wrapup);
          
            fix_lp_bdry_ed = TRUE;
            ed_fixed_pt = cur_against_bdry->point;

          } /* if ( 5 * partolbasis->tol >= proj_info.dist) */
          else
          {
            fprintf (stderr, "could not resolve NULL_OBJID");
            *EFmsg = EMS_E_Fail;
            goto wrapup;
          }            

        } /* if ( IF_NULL_OBJID(ed_id) ) */

        else if (num_eds) 
        {
           EFfix_the_intloc ( &rc, num_eds, reject_ed_ids, cur_os,
                  cur_against_bdry, &fix_lp_bdry_ed, &ed_fixed_pt,
                  partolbasis);
           EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_Fail,wrapup);

        } /* else if (num_eds)  */

        /*
         * If the lp_bdry_edge need to be fixed,
         * o Get the pygeom or bcgeom depending upon the class
         *   of the edge.
         * o Replace the appropriate end_point with the fix_pt and
         *   post the geometry.
         * o Also, fix the cur_lp_bdry appropriately.
         */

        if (fix_lp_bdry_ed)
        {
          ed_id = cur_lp_bdry->edgeid;
          which_end_pt = (cur_lp_bdry->edgepar.param == 0.) ? 
                         EMS_EDGE_BEG_PT : EMS_EDGE_END_PT;
                      
          EFfix_ed_geometry ( &rc, ed_id, cur_os, 
                               which_end_pt, ed_fixed_pt, partolbasis, ls_id);
          EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_Fail,wrapup);
               
          OM_BLOCK_MOVE (ed_fixed_pt, cur_lp_bdry->point, 
                         sizeof(IGRdouble) * 2 );
   
        } /* if (fix_lp_bdry_ed) */

      } /* if (cur_against_bdry) */

      else cntinue = FALSE;

    } /* while (cntinue) */
    
  } /* for (i = 0; i < num_bdrys; i++) */

 wrapup:
  EMWRAPUP (*EFmsg, OM_stat, "In EFfix_the_trim_info" );

  return;

} /* void EFfix_the_trim_info () */

static void EFfix_the_intloc (
       EFmsg,
       num_eds,
       ed_ids,
       cur_os,
       trim_info,
       ed_fixed,
       ed_fixed_pt,
       partolbasis)
  IGRlong                *EFmsg;
  IGRint                 num_eds;
  GRobjid                *ed_ids;
  GRspacenum             cur_os;
  struct EMSsfintedpar   *trim_info;
  IGRboolean             *ed_fixed;
  IGRdouble              **ed_fixed_pt;
  struct EMSpartolbasis  *partolbasis;
{
  struct   EMSedgebound    ed_bounds[2];
  IGRdouble                ed_end_pts[4], b_t_pts_dist, e_t_pts_dist;
  IGRlong                  OM_stat, mthd_stat;
  IGRint                   i;
  GRobjid                  ed_id;
  IGRboolean               beg_pt_close;

  *EFmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;
  *ed_fixed = FALSE;
  /*
   * If the intersection location is not one of the 
   * end points and the intersection point is within
   * 3 * par_tol from one of the end points of the edges
   * sent by the caller, move it to the endpoint.
   */

  if (trim_info->intloc == EMScvint_middle    ||
      trim_info->intloc == EMScvint_collapsed ||
      trim_info->intloc == EMScvint_overlap   ||
      trim_info->intloc == EMScvint_unknown ) 
  {
    ed_id = trim_info->edgeid;

    for ( i = 0; i < num_eds; i++)
    {
      if (ed_id == ed_ids[i])
      {
        OM_stat = om$send (msg = message EMSedge.EMendpts (
                            &mthd_stat, ed_end_pts,
                            &ed_end_pts[2], ed_bounds, 
                            &ed_bounds[1], NULL),
                           senderid = NULL_OBJID, 
                           targetid = ed_ids[i], 
                           targetos = cur_os);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

         b_t_pts_dist = sqrt(EM2ddistptpts(trim_info->point, 
                                           ed_end_pts) );

         e_t_pts_dist = sqrt(EM2ddistptpts(trim_info->point,
                                           &ed_end_pts[2]));

         beg_pt_close =(b_t_pts_dist < e_t_pts_dist)? TRUE : FALSE;

         if ( 3. * partolbasis->tol >= (beg_pt_close ?
                              b_t_pts_dist : e_t_pts_dist))
         {
           trim_info->intloc = beg_pt_close ?
                               EMScvint_lfend : EMScvint_rtend;

           OM_BLOCK_MOVE ((beg_pt_close ? ed_bounds : 
                          &ed_bounds[1]), &trim_info->edgepar, 
                          sizeof (struct EMSedgebound) );

           OM_BLOCK_MOVE ((beg_pt_close ? ed_end_pts : 
                          &ed_end_pts[2]), trim_info->point, 
                          2 * sizeof(IGRdouble));

           *ed_fixed = TRUE;
           *ed_fixed_pt = trim_info->point;

         } /* if ( 3. * partolbasis->tol >= (beg_pt_close ?
                        b_t_pts_dist : e_t_pts_dist)) */
/*
         else 
         {
           fprintf (stderr, "somthing is messed up \n");
           goto wrapup;
          }
*/
          break;

      } /* if (ed_id == ed_ids[i]) */

    } /* for ( i = 0; i < num_eds; i++) */

  } /* if (trim_info->intloc == EMScvint_middle    ||
           trim_info->intloc == EMScvint_collapsed ||
           trim_info->intloc == EMScvint_overlap   ||
           trim_info->intloc == EMScvint_unknown ) */

wrapup:
  EMWRAPUP (*EFmsg, OM_stat, "In EFfix_the_intloc" );
  return;

}/* end EFfix_the_intloc () */


void EFfix_ed_geometry (
            EFmsg,
            ed_id,
            cur_os,
            which_end_pt,
            ed_fixed_pt,
            partolbasis,
            ls_id)

   IGRlong                   *EFmsg;
   GRobjid                   ed_id;
   GRspacenum                cur_os;
   IGRshort                  which_end_pt;
   IGRdouble                 *ed_fixed_pt;
   struct EMSpartolbasis     *partolbasis;
   GRobjid                   ls_id;
               
{
   struct IGRbsp_curve      ed_bcgeom;
   struct IGRpolyline       ed_pygeom;
   IGRlong                  OM_stat, mthd_stat;
   IGRint                   j, ed_pt_idx, ed_wt_idx;
   OMuword                  ed_classid;
   IGRushort                ed_props;
   IGRuchar                 ed_type;
 
   *EFmsg = EMS_S_Success;
   OM_stat = OM_S_SUCCESS;

   ed_bcgeom.poles = ed_bcgeom.knots = ed_bcgeom.weights = NULL;
   ed_bcgeom.bdrys = NULL;
   ed_pygeom.points = NULL;

   OM_stat = om$get_classid (osnum = cur_os, objid = ed_id,
                             p_classid = &ed_classid);
   EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);
         
   OM_stat = om$is_ancestry_valid (subclassid = ed_classid,
                     superclassid = OPP_EMSbsedge_class_id);
   EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

   if (OM_stat == OM_S_SUCCESS)
   {
     OM_stat = om$send (msg = message EMSedge.EMgetbcgeom (
                         &mthd_stat, NULL, MAXINT, FALSE, NULL,
                         &ed_bcgeom, partolbasis, NULL),
                        senderid = NULL_OBJID, targetid = ed_id,
                        targetos = cur_os);
     EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

     ed_pt_idx = (which_end_pt == EMS_EDGE_BEG_PT ? 
                   0 : ((ed_bcgeom.num_poles-1) * 3) );
     ed_wt_idx = (which_end_pt == EMS_EDGE_BEG_PT ? 
                   0 : (ed_bcgeom.num_poles - 1) );
            
     if (ed_bcgeom.rational)
     {
       for (j = 0; j < 2; j++)
         ed_bcgeom.poles[ed_pt_idx + j] = 
               ed_fixed_pt[j] * ed_bcgeom.weights[ed_wt_idx];

     } /* if (ed_bcgeom.rational) */
     else 
       OM_BLOCK_MOVE (ed_fixed_pt, &ed_bcgeom.poles[ed_pt_idx],
                      2 * sizeof(IGRdouble));

     OM_stat = om$send (msg = message EMSedge.EMputbcgeom (
                         &mthd_stat, NULL, FALSE, &ed_bcgeom),
                        senderid = NULL_OBJID,
                        targetid = ed_id, targetos = cur_os);
     EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

   } /* if (OM_stat == OM_S_SUCCESS) */
   else
   {
     OM_stat = om$send (msg = message EMSedge.EMgetpygeom (
                         &mthd_stat, NULL, MAXINT, FALSE, NULL,
                         &ed_pygeom, partolbasis, NULL),
                        senderid = NULL_OBJID,
                        targetid = ed_id, targetos = cur_os);
     EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

     ed_pt_idx = (which_end_pt == EMS_EDGE_BEG_PT ? 
                   0 : ((ed_pygeom.num_points - 1)*2) );

     OM_BLOCK_MOVE (ed_fixed_pt, &ed_pygeom.points[ed_pt_idx],
                    2 * sizeof(IGRdouble) );

     /*
      * Since EMputpygeom inserts instead of replacing
      * the geometry, have to resort to EMleinit. This
      * in turn resulted in an overhead of extracting
      * props and type.
      */

     OM_stat = om$send (msg = message EMSedge.EMget_props_type (
                         &mthd_stat, &ed_props, &ed_type),
                        senderid = NULL_OBJID,
                        targetid = ed_id, targetos = cur_os);
     EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg, EMS_E_EdgeError,wrapup);

     /*Check to if change of end pt or just plain old tolerancing
      * problems has resulted in a edge marked as ISO now no longer ISO.  If so
      * then must stroke the edge, fix the end pt and init with stroked
      * version. DLB 9/8/92 TR 92n6077
      */
     if (ed_props & EMED_ISO)
     {
       IGRdouble         partollen, iso_buf[4]; 
       extern IGRboolean EMis_iso_edge();

       OM_stat = EFextract_par(BSTOLLENVEC, partolbasis->tol,
                               &partollen, &mthd_stat);
 
       if (! EMis_iso_edge(ed_pygeom.num_points, ed_pygeom.points, 
                           partollen, iso_buf))
       {
         OMuint              link_cnt;
         OM_S_OBJECT_LINKAGE sf_link;
         OM_S_CHANSELECT     to_surface;
         struct GRid         sf_GRid;


         /*Stroke the edge in place, get the pygeom and blast in the "fixed"
          * end point again.
          */

         /*Get the surface id*/
         if (ls_id == NULL_OBJID) {*EFmsg = EMS_E_InvalidArg; goto wrapup;}
           
         EMmake_chanselect(EMSloopset_to_surface, &to_surface);
         OM_stat = om$get_channel_objects(objid = ls_id,
                                          osnum = cur_os,
                                          p_chanselect = &to_surface,
                                          list = &sf_link,
                                          size = 1,
                                          count = &link_cnt);
         if (!(1 & OM_stat) || !link_cnt)
         {*EFmsg = EMS_E_InvalidCase; goto wrapup;}

         sf_GRid.objid = sf_link.S_objid;
         sf_GRid.osnum = cur_os;

         /*Stroke the iso edge in place*/
         OM_stat = om$send(msg = message EMSlinedge.EMstroke_iso_edge(
                                 EFmsg, 
                                 partolbasis->mat, 
                                 partolbasis->mattyp, 
                                 &sf_GRid, NULL, FALSE,
                                 partolbasis, NULL_OBJID, NULL, TRUE),
                           senderid = NULL_OBJID,
                           targetid = ed_id,
                           targetos = cur_os);
         if (!(1 & OM_stat & *EFmsg)) goto wrapup;

         /*Now get the stroked edges geom and apply the end fix again*/
         if (ed_pygeom.points) om$dealloc (ptr = ed_pygeom.points);
         ed_pygeom.points = NULL;

         OM_stat = om$send(msg = message EMSedge.EMgetpygeom(EFmsg,
                                 NULL, MAXINT, FALSE, NULL,
                                 &ed_pygeom, partolbasis, NULL),
                           senderid = NULL_OBJID,
                           targetid = ed_id, targetos = cur_os);
         if (!(1 & OM_stat & *EFmsg)) goto wrapup;

         ed_pt_idx = (which_end_pt == EMS_EDGE_BEG_PT ? 
                      0 : ((ed_pygeom.num_points - 1)*2) );

         OM_BLOCK_MOVE(ed_fixed_pt, &ed_pygeom.points[ed_pt_idx],
                       2 * sizeof(IGRdouble) );

         /* Get the props again since the stroke changed'em.*/
         OM_stat = om$send(msg = message EMSedge.EMget_props_type(EFmsg,
                                 &ed_props, &ed_type),
                           senderid = NULL_OBJID,
                           targetid = ed_id, targetos = cur_os);
         if (!(1 & OM_stat & *EFmsg)) goto wrapup;
       }
       /*no else... all is well*/
     }

     OM_stat = om$send (msg = message EMSlinedge.EMleinit (
                         &mthd_stat, ed_props, ed_type,
                         &ed_pygeom, partolbasis,NULL, NULL_OBJID),
                        senderid = NULL_OBJID,
                        targetid = ed_id, targetos = cur_os);
     EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

   } /* else for if (OM_stat == OM_S_SUCCESS) */

 wrapup:
  EMWRAPUP (*EFmsg, OM_stat, "In EFfix_ed_geometry" );

  if (ed_pygeom.points) om$dealloc (ptr = ed_pygeom.points);
  if (ed_bcgeom.poles) om$dealloc (ptr = ed_bcgeom.poles);
  if (ed_bcgeom.knots) om$dealloc (ptr = ed_bcgeom.knots);
  if (ed_bcgeom.weights) om$dealloc (ptr = ed_bcgeom.weights);
  if (ed_bcgeom.bdrys) om$dealloc (ptr = ed_bcgeom.bdrys);

  return;
   
} /* void EFfix_ed_geometry () */

void EFrmv_inacteds_actcm_eds (
     EFmsg, md_env, cur_os, sfrmvd_info, lps_mod_info, ed_sp_info)

 IGRlong                        *EFmsg;
 struct  GRmd_env               *md_env;
 GRspacenum                     cur_os;
 struct  EMSlft_sfrmvd_info     *sfrmvd_info;
 struct  EMSlft_lpmod_info      *lps_mod_info;
 struct  EMSlft_edsp_info       *ed_sp_info;

 {
   OM_S_CHANSELECT       sf_ls_chan, cm_ed_chan;
   OM_S_OBJECT_LINKAGE   ls_list;
   IGRint                num_act_cm_eds, num_new_cm_eds, *num_eds, 
                         *num_sp_eds, k, kk,
                         act_cm_eds_buf_size, new_cm_eds_buf_size, 
                         i, j, array_size, INITIAL_SIZE, BUF_INC,
                         num_lp_eds, lp_eds_arrsz;
   OMuint                count;
   IGRlong               OM_stat, mthd_stat, rc;
   IGRboolean            is_ed_split;
   GRobjid               *act_cm_eds, *new_cm_eds, *sf_out, *region_out,
                         *cm_ed_ids;
   struct GRid           *lp_eds;


   *EFmsg = EMS_S_Success;
   OM_stat = OM_S_SUCCESS;
   num_act_cm_eds = num_new_cm_eds = NULL;
   act_cm_eds_buf_size = new_cm_eds_buf_size = NULL;
   act_cm_eds = new_cm_eds = NULL;
   lp_eds = NULL;
   cm_ed_ids = NULL;
   lp_eds_arrsz = num_lp_eds = 0;
       
   OM_stat = EMmake_chanselect (EMSsubbs_to_loopset, &sf_ls_chan);
   EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

   OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &cm_ed_chan);
   EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

   /*
    * For each region taken out,
    * o Check if any of its edges was not split, is not a part
    *   of an active loop and still have an active common edge.
    *   o If so, replace the active common edge with its compress copy
    *     and save this information in the ed_sp_info.
    */

   if (lps_mod_info->num_sfs)
   {
     
     /*
      * Collect all of the edges which were replaced by another
      * set of edges. It is assumed these edges were the
      * result of ed_splitting process started by their common
      * edges. Collect the common edges. If any of the edges
      * of the loops taken out is is one of these common edges,
      * do not process.
      */

     if (ed_sp_info->num_eds)
     {
       cm_ed_ids = (GRobjid *) om$malloc (size = ed_sp_info->num_eds *
                                           sizeof(GRobjid) );
       EMerr_hndlr (!cm_ed_ids, *EFmsg, EMS_E_NoDynamicMemory, wrapup);

       for (i = 0; i < ed_sp_info->num_eds; i++)
       {
         OM_stat = om$send (msg = message EMSboundary.EMget_objid (
                             &mthd_stat, &cm_ed_ids[i]),
                            senderid = NULL_OBJID,
                            targetid = ed_sp_info->ed_ids[i],
                            targetos = cur_os);
         EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);
       } /* for (i = 0; i < ed_sp_info->num_eds; i++) */

     } /* if (ed_sp_info->num_eds) */
     
     region_out = lps_mod_info->lp_rmvd_ids;
   
     for (i = 0; i < lps_mod_info->num_sfs; i++)
     {
       for (j = 0; j < lps_mod_info->lps_rmvd_prsf[i]; j++, region_out++)
       {
         num_lp_eds = 0;
         OM_stat = om$send (msg = message EMSboundary.EMget_edges (
                             &mthd_stat, 1, EMS_OPT_NONDEG_NONSEAM,
                             &lp_eds, &lp_eds_arrsz, &num_lp_eds),
                            senderid = NULL_OBJID,
                            targetid = *region_out, targetos = cur_os);
         EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopError,wrapup);

         for (k = 0; k < num_lp_eds; k++)
         {
           is_ed_split = FALSE;
           kk = 0;
           while (!is_ed_split && kk < ed_sp_info->num_eds)
           {
             if (lp_eds[k].objid == cm_ed_ids[kk]) is_ed_split = TRUE;
             else kk++;
           } /* while (!is_ed_split && kk < ed_sp_info->num_eds) */

           if (!is_ed_split)
           {
             OM_stat = om$send (
                    msg = message EMSboundary.EMmk_act_cm_eds_connectable(
                     &mthd_stat, MAXINT, md_env, &num_act_cm_eds,
                     &act_cm_eds_buf_size, &act_cm_eds, &num_new_cm_eds,
                     &new_cm_eds_buf_size, &new_cm_eds),
                    senderid = NULL_OBJID,
                    targetid = lp_eds[k].objid, targetos = cur_os);
             EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopsetError,wrapup);
           } /* if (!is_ed_split) */
            
         } /* for (k = 0; k < num_lp_eds; k++) */
      
       }/* for (j = 0; j < lps_mod_info->lp_rmvd_prsf[i]; 
              j++, region_out++) */

     } /* for (i = 0; i < lps_mod_info->num_sfs; i++) */

   } /* if (lps_mod_info) */

   /*
    * For each surface taken out,
    * o Check if any of its edges still have an active common edge.
    *   o If so, replace the active common edge with its compress copy
    *     and save this information in the ed_sp_info.
    */

   sf_out = sfrmvd_info->sf_ids;
   for ( i = 0; i < sfrmvd_info->num_compsf; i++)
   {
     for (j = 0; j < sfrmvd_info->num_sf_prcompsf[i]; j++, sf_out++)
     {
       OM_stat = om$get_channel_objects (osnum = cur_os, 
                    objid = *sf_out, p_chanselect = &sf_ls_chan,
                    list = &ls_list, size = 1, count = &count);
       EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

       OM_stat = om$send (
                    msg = message EMSboundary.EMmk_act_cm_eds_connectable(
                     &mthd_stat, MAXINT, md_env, &num_act_cm_eds,
                     &act_cm_eds_buf_size, &act_cm_eds, &num_new_cm_eds,
                     &new_cm_eds_buf_size, &new_cm_eds),
                    senderid = NULL_OBJID,
                    targetid = ls_list.S_objid, targetos = ls_list.osnum);
       EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_LoopsetError,wrapup);

     } /* for (j = 0; j < sfrmvd_info->num_sf_prcompsf; j++, sf_out++) */

   } /* for ( i = 0; i < sfrmvd_info->num_compsf; i++) */

   /*
    * If there are any common edges that are replaced by their
    * copies, save them in ed_sp_info.
    */

   if (num_act_cm_eds)
   {
     array_size = ed_sp_info->eds_arrsz;
     INITIAL_SIZE = BUF_INC = 10;

     EFmemory_allocation (&rc, (IGRchar **) &ed_sp_info->ed_ids, 
             ed_sp_info->num_eds + num_act_cm_eds,
             &array_size, sizeof(GRobjid), INITIAL_SIZE, BUF_INC);
     EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_NoDynamicMemory,wrapup);

     EFmemory_allocation (&rc, (IGRchar **) &ed_sp_info->sp_eds_pred,
          ed_sp_info->num_eds + num_act_cm_eds,
          &ed_sp_info->eds_arrsz, sizeof(IGRint), INITIAL_SIZE, BUF_INC);
     EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_NoDynamicMemory,wrapup);

     EFmemory_allocation (&rc, (IGRchar **) &ed_sp_info->sp_eds, 
              ed_sp_info->num_sp_eds + num_act_cm_eds,
              &ed_sp_info->sp_eds_arrsz, 
              sizeof(GRobjid), INITIAL_SIZE, BUF_INC);
     EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_NoDynamicMemory,wrapup);

     num_eds = &ed_sp_info->num_eds;
     num_sp_eds = &ed_sp_info->num_sp_eds;

     for (i = 0; i < num_act_cm_eds; i++, (*num_eds)++, (*num_sp_eds)++)
     {
       ed_sp_info->ed_ids[*num_eds] = act_cm_eds[i];
       ed_sp_info->sp_eds_pred[*num_eds] = 1;
       ed_sp_info->sp_eds[*num_sp_eds] = new_cm_eds[i];

     } /* for (i = 0; i < num_act_cm_eds; i++, (*num_eds)++, 
               (*num_sp_eds)++) */

   } /* if (num_act_eds) */

  wrapup:

    EMWRAPUP (*EFmsg, OM_stat, "In EFrmv_inacteds_actcm_eds");
    if (cm_ed_ids) om$dealloc (ptr = cm_ed_ids);
    if (lp_eds) om$dealloc (ptr = lp_eds);
    if (act_cm_eds) om$dealloc (ptr = act_cm_eds);
    if (new_cm_eds) om$dealloc (ptr = new_cm_eds);
    return;

 } /* void EFrmv_inacteds_actcm_eds () */

/*
 * The following function is used to fix the mapped data in case
 * the surface is physically closed. The mapped data may need
 * be fixed if the creation of boundary used for mapping results in
 * moving a point along the seam edges/the moved happens to lie on the
 * seam edge. In such instances, the mapped uvdata may lie on the
 * incorrect seam edge.
 */
 
void EFfix_mapped_data (
  EFmsg,
  lp_id,
  cur_os,
  num_cvs,
  xyz_cvs,
  sf_geom,
  partolbasis)

  IGRlong                   *EFmsg;
  GRobjid                   lp_id;
  GRspacenum                cur_os;
  IGRint                    num_cvs;
  struct     IGRbsp_curve   **xyz_cvs;
  struct     IGRbsp_surface *sf_geom;
  struct     EMSpartolbasis *partolbasis;

{
    struct  IGRbsp_curve  ed_bcgeom;
    struct  IGRpolyline   ed_pygeom[3];
    IGRdouble             cht_tol, eds_beg_pt[3][2], eds_end_pt[3][2],
                          uvpt[2], xyzpt[2], par, base_pt[3], dist, 
                          *end_uv_seg, TEST_PARAM;
    OM_S_CHANSELECT       lp_ed_chan;
    IGRlong               OM_stat, mthd_stat, rc;
    IGRint                i, pole_idx;
    GRobjid               ed_ids[3];
    GRspacenum            dum_os;
    IGRboolean            first_node_u_test, first_node_v_test, 
                          second_node_u_test, second_node_v_test, 
                          is_bs_edge, eds_fixed[3];
    OMuword               ed_classid;
    IGRushort     ed_props;
    IGRuchar      ed_type;

    OM_stat = OM_S_SUCCESS;
    *EFmsg = EMS_S_Success;
    TEST_PARAM = 0.645;
    first_node_u_test = first_node_v_test = FALSE;
    second_node_u_test = second_node_v_test = FALSE;
    is_bs_edge = FALSE;
    for (i = 0; i < 3; i++)
      eds_fixed[i] = FALSE;
    
    ed_bcgeom.poles = ed_bcgeom.knots = ed_bcgeom.weights = NULL;
    ed_bcgeom.bdrys = NULL;
    for (i = 0; i < 3; i++)
      ed_pygeom[i].points = NULL;

    BSEXTRACTPAR (&rc, BSTOLCHRDHT, cht_tol);

    OM_stat = EMmake_chanselect (EMSbd_owner_to_comps, &lp_ed_chan);
    EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

    for (i = 0; i < num_cvs; i++)
    {
      OM_stat = om$get_objid_at_index (objid = lp_id, osnum = cur_os,
                   p_chanselect = &lp_ed_chan, index = i, 
                   objidaddr = &ed_ids[i], osnumaddr = &dum_os);
      EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

      OM_stat = om$send (msg = message EMSedge.EMendpts (&mthd_stat,
                          &eds_beg_pt[i][0], &eds_end_pt[i][0], NULL,
                          NULL, NULL),
                         senderid = NULL_OBJID, targetid = ed_ids[i],
                         targetos = cur_os);
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

    } /* for (i = 0; i < num_cvs; i++) */

    if (sf_geom->u_phy_closed)
    {
      if ( ( fabs(eds_end_pt[0][0] - 0) < 3. * partolbasis->tol) ||
           ( fabs(eds_end_pt[0][0] - 1) < 3. * partolbasis->tol) )
        first_node_u_test = TRUE;
      
      if ( ( fabs(eds_beg_pt[2][0] - 0) < 3. * partolbasis->tol) ||
           ( fabs(eds_beg_pt[2][0] - 1) < 3. * partolbasis->tol) )
        second_node_u_test = TRUE;

    } /* if (sf_geom->u_phy_closed) */

    if (sf_geom->v_phy_closed)
    {
      if ( ( fabs(eds_end_pt[0][1] - 0) < 3. * partolbasis->tol) ||
           ( fabs(eds_end_pt[0][1] - 1) < 3. * partolbasis->tol) )
        first_node_v_test = TRUE;
      
      if ( ( fabs(eds_beg_pt[2][1] - 0) < 3. * partolbasis->tol) ||
           ( fabs(eds_beg_pt[2][1] - 1) < 3. * partolbasis->tol) )
        second_node_v_test = TRUE;

    } /* if (sf_geom->v_phy_closed) */

    /*
     * If u_test or v_test need to be performed, get the geometry.
     * The second curve may be a bs_edge. If so, get bs-geometry.
     */

    OM_stat = om$get_classid (osnum = cur_os, objid = ed_ids[1],
                              p_classid = &ed_classid);
    EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);
         
    OM_stat = om$is_ancestry_valid (subclassid = ed_classid,
                           superclassid = OPP_EMSbsedge_class_id);
    EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

    is_bs_edge = (OM_stat == OM_S_SUCCESS ? TRUE : FALSE);
         
    for ( i = 0; i < 3; i++)
    {
       if (i == 1 && is_bs_edge)
       {
        OM_stat = om$send (msg = message EMSedge.EMgetbcgeom (
                            &mthd_stat, NULL, MAXINT, FALSE, NULL,
                            &ed_bcgeom, partolbasis, NULL),
                        senderid = NULL_OBJID, targetid = ed_ids[i],
                        targetos = cur_os);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

       } /* if (i == 1 && is_bs_edge) */
       else
       {
        OM_stat = om$send (msg = message EMSedge.EMgetpygeom (
                         &mthd_stat, NULL, MAXINT, FALSE, NULL,
                         &ed_pygeom[i], partolbasis, NULL),
                        senderid = NULL_OBJID,
                        targetid = ed_ids[i], targetos = cur_os);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

       } /* else for if (is_bs_edge) */

     } /* for ( i = 0; i < 3; i++) */

     if (first_node_u_test || first_node_v_test)
     {
       end_uv_seg = &ed_pygeom[0].points[(ed_pygeom[0].num_points - 2)*2];
       uvpt[0] = end_uv_seg[0] + TEST_PARAM*(end_uv_seg[2]-end_uv_seg[0]);
       uvpt[1] = end_uv_seg[1] + TEST_PARAM*(end_uv_seg[3]-end_uv_seg[1]);
       
       BSsfeval (sf_geom, uvpt[0], uvpt[1], 0, (IGRpoint *)&xyzpt[0], &rc);
       EMerr_hndlr(rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

       BSmdstptcv (xyz_cvs[0], xyzpt, &par, base_pt, &dist, &rc);
       EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror,wrapup);

       if (dist > cht_tol)
       {
         if (first_node_u_test)
          end_uv_seg[2] = fabs(end_uv_seg[2]-0.) < fabs(end_uv_seg[2] -1.)
                          ? 1. : 0.;

         if (first_node_v_test)
          end_uv_seg[3] = fabs(end_uv_seg[3]-0.) < fabs(end_uv_seg[3] -1.)
                          ? 1. : 0.;

         uvpt[0] = end_uv_seg[0]+TEST_PARAM*(end_uv_seg[2]-end_uv_seg[0]);
         uvpt[1] = end_uv_seg[1]+TEST_PARAM*(end_uv_seg[3]-end_uv_seg[1]);
       
         BSsfeval (sf_geom, uvpt[0], uvpt[1], 0, (IGRpoint *)&xyzpt[0], &rc);
         EMerr_hndlr(rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

         BSmdstptcv (xyz_cvs[0], xyzpt, &par, base_pt, &dist, &rc);
         EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror,wrapup);
         if (dist > cht_tol)
         {
           *EFmsg = EMS_E_Fail;
           fprintf (stderr, "Could not resolve mapped data ambiguity");
           goto wrapup;
         } /* if (dist > cht_tol) */

         eds_fixed[0] = TRUE;

       } /* if (dist > cht_tol) */

       else
       {
         /*
          * snap the first node point to the natural boundary if
          * it is within parametric tolerance.
          */

         end_uv_seg[2] = (fabs(end_uv_seg[2] - 0.) < partolbasis->tol) ?
                 0. : (fabs(end_uv_seg[2] - 1.) < partolbasis->tol ? 1. :
                       end_uv_seg[2] );

         end_uv_seg[3] = (fabs(end_uv_seg[3] - 0.) < partolbasis->tol) ?
                 0. : (fabs(end_uv_seg[3] - 1.) < partolbasis->tol ? 1. :
                       end_uv_seg[3] );

       } /* else for if (dist > cht_tol) */
     } /* if (first_node_u_test || first_node_v_test) */

     /*
      * make sure that the end point of first edge is the same
      * as that of begin point of the second edge.
      */

     pole_idx = (ed_pygeom[0].num_points - 1 ) * 2;
     if (ed_pygeom[0].points[pole_idx] != eds_beg_pt[1][0] ||
         ed_pygeom[0].points[pole_idx+1] != eds_beg_pt[1][1] )
     {
       if (is_bs_edge)
       {
        if (ed_bcgeom.rational)
        {
          for (i = 0; i < i; i++)
            ed_bcgeom.poles[i] = ed_pygeom[0].points[pole_idx+i] * 
                                 ed_bcgeom.weights[0];
        } /* if (ed_bcgeom.rational) */
        else 
         OM_BLOCK_MOVE (&ed_pygeom[0].points[pole_idx], 
                        &ed_bcgeom.poles[0], 2 * sizeof(IGRdouble));

       } /* if (is_bs_edge) */
       else
       {
         OM_BLOCK_MOVE (&ed_pygeom[0].points[pole_idx], 
                        ed_pygeom[1].points, 2 * sizeof(IGRdouble) );
       } /* else for if (is_bs_edge) */

       eds_fixed[1] = TRUE;
     } /* if (ed_pygeom[0].points[pole_idx] != eds_beg_pt[1][0] ||
              ed_pygeom[0].points[pole_idx+1] != eds_beg_pt[1][1] ) */

     if (second_node_u_test || second_node_v_test)
     {
       end_uv_seg = ed_pygeom[2].points;
       uvpt[0] = end_uv_seg[0] + TEST_PARAM*(end_uv_seg[2]-end_uv_seg[0]);
       uvpt[1] = end_uv_seg[1] + TEST_PARAM*(end_uv_seg[3]-end_uv_seg[1]);
       
       BSsfeval (sf_geom, uvpt[0], uvpt[1], 0, (IGRpoint *)&xyzpt[0], &rc);
       EMerr_hndlr(rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

       BSmdstptcv (xyz_cvs[2], xyzpt, &par, base_pt, &dist, &rc);
       EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror,wrapup);

       if (dist > cht_tol)
       {
         if (second_node_u_test)
          end_uv_seg[0] = fabs(end_uv_seg[0]-0.) < fabs(end_uv_seg[0]-1.)
                          ? 1. : 0.;

         if (second_node_v_test)
          end_uv_seg[1] = fabs(end_uv_seg[1]-0.) < fabs(end_uv_seg[1]-1.)
                          ? 1. : 0.;

         uvpt[0] = end_uv_seg[0]+TEST_PARAM*(end_uv_seg[2]-end_uv_seg[0]);
         uvpt[1] = end_uv_seg[1]+TEST_PARAM*(end_uv_seg[3]-end_uv_seg[1]);
       
         BSsfeval (sf_geom, uvpt[0], uvpt[1], 0, (IGRpoint *)&xyzpt[0], &rc);
         EMerr_hndlr(rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

         BSmdstptcv (xyz_cvs[2], xyzpt, &par, base_pt, &dist, &rc);
         EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror,wrapup);
         if (dist > cht_tol)
         {
           *EFmsg = EMS_E_Fail;
           fprintf (stderr, "Could not resolve mapped data ambiguity");
           goto wrapup;
         } /* if (dist > cht_tol) */

         eds_fixed[2] = TRUE;

       } /* if (dist > cht_tol) */
       else
       {
         /*
          * snap the first node point to the natural boundary if
          * it is within parametric tolerance.
          */

         end_uv_seg[0] = (fabs(end_uv_seg[0] - 0.) < partolbasis->tol) ?
                 0. : (fabs(end_uv_seg[0] - 1.) < partolbasis->tol ? 1. :
                       end_uv_seg[0] );

         end_uv_seg[1] = (fabs(end_uv_seg[1] - 0.) < partolbasis->tol) ?
                 0. : (fabs(end_uv_seg[1] - 1.) < partolbasis->tol ? 1. :
                       end_uv_seg[1] );

       } /* else for if (dist > cht_tol) */

     } /* if (second_node_u_test || second_node_v_test) */

     /*
      * make sure that the end point of second edge is the same
      * as that of begin point of the third edge.
      */

     if (ed_pygeom[2].points[0] != eds_end_pt[1][0] ||
         ed_pygeom[2].points[1] != eds_end_pt[1][1] )
     {
       if (is_bs_edge)
       {
        pole_idx = (ed_bcgeom.num_poles - 1) * 3;
        if (ed_bcgeom.rational)
        {
          for (i = 0; i < 2; i++)
            ed_bcgeom.poles[pole_idx+i] = ed_pygeom[2].points[i] * 
                         ed_bcgeom.weights[ed_bcgeom.num_poles-1];
        } /* if (ed_bcgeom.rational) */
        else 
         OM_BLOCK_MOVE (ed_pygeom[2].points, &ed_bcgeom.poles[pole_idx], 
                         2 * sizeof(IGRdouble));

       } /* if (is_bs_edge) */
       else
       {
         OM_BLOCK_MOVE (ed_pygeom[2].points, 
                    &ed_pygeom[1].points[(ed_pygeom[1].num_points-1)*2],
                    2 * sizeof(IGRdouble) );
       } /* else for if (is_bs_edge) */

       eds_fixed[1] = TRUE;
     } /* if (ed_pygeom[0].points[pole_idx] != eds_beg_pt[1][0] ||
              ed_pygeom[0].points[pole_idx+1] != eds_beg_pt[1][1] ) */

     /*
      * Update the geometry of any of the above modified edges.
      */

     for ( i = 0; i < 3; i++)
     {
       if (eds_fixed[i])
       {
        if (i == 1 && is_bs_edge)
        { 
         OM_stat = om$send (msg = message EMSedge.EMputbcgeom (
                               &mthd_stat, NULL, FALSE, &ed_bcgeom),
                              senderid = NULL_OBJID,
                              targetid = ed_ids[i], targetos = cur_os);
          EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);
        } /* if (i == 1 && is_bs_edge) */

        else
        {
         /*
          * Since EMputpygeom inserts instead of replacing
          * the geometry, have to resort to EMleinit. This
          * in turn resulted in an overhead of extracting
          * props and type.
          */

         OM_stat = om$send (msg = message EMSedge.EMget_props_type (
                             &mthd_stat, &ed_props, &ed_type),
                            senderid = NULL_OBJID,
                            targetid = ed_ids[i], targetos = cur_os);
         EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

         OM_stat = om$send (msg = message EMSlinedge.EMleinit (
                             &mthd_stat, ed_props, ed_type,
                             &ed_pygeom[i], partolbasis,NULL, NULL_OBJID),
                            senderid = NULL_OBJID,
                            targetid = ed_ids[i], targetos = cur_os);
         EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

        } /* else for if (i == 1 && is_bs_edge) */

       } /* if (eds_fixed[i]) */

     } /* for ( i = 0; i < 3; i++) */

 wrapup:

  EMWRAPUP (*EFmsg, OM_stat, "In EFfix_mapped_data");
  if (ed_bcgeom.poles) om$dealloc (ptr = ed_bcgeom.poles);
  if (ed_bcgeom.knots) om$dealloc (ptr = ed_bcgeom.knots);
  if (ed_bcgeom.weights) om$dealloc (ptr = ed_bcgeom.weights);
  if (ed_bcgeom.bdrys) om$dealloc (ptr = ed_bcgeom.bdrys);
  for (i = 0; i < 3; i++)
      if (ed_pygeom[i].points) om$dealloc (ptr = ed_pygeom[i].points);

  return;

} /* void EFfix_mapped_data () */
  
end implementation EMSsf_lift;
