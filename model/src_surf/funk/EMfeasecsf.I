/*________________________________________________________________________
 |                                                                        |
 | OVERVIEW                                                               |
 |                                                                        |
 |                                                                        |
 | NOTES                                                                  |
 |                                                                        |
 |                                                                        |
 | KEYWORDS                                                               |
 |                                                                        |
 |                                                                        |
 | HISTORY                                                                |
 |                                                                        |
 |    Sanjay           04/12/94   Creation                                |
 |    Sp.Balamurugan   12/21/96   from-to algorithm modified              |      |                                                                        |
 |________________________________________________________________________|
*/

class implementation Root;

#include "math.h"
#include "values.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "OMlimits.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "ex.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "emsdef.h"
#include "emsdattyp.h"                  /* enum EMSdata_ etc. */
#include "EMSmsgdef.h"                  /* EMS return codes */
#include "EMSlogic.h"
#include "OMprimitives.h"
#include "OMmacros.h"                   /* OM_BLOCK_MOVE */
#include "emserr.h"                    
#include "emsinterdef.h"
#include "EMSprop.h"
#include "dpmacros.h"
#include "emscvexten.h"
#include "emsfeaopts.h"
#include "EMSasopts.h"
#include "EMSasnuc.h"
#include "emsmacros.h"

#include "addrmopts.h"
#include "addprot.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "bsparameters.h"
#include "bserr.h"
#include "bsptlngen.h"
#include "bsnorvec.h"
#include "bsmvecsclr.h"
#include "bsmkvec.h"
#include "bsdistptpt.h"
#include "bsdistptpts.h"
#include "bscvarrevt.h"
#include "bsnorvec.h"
#include "bsproj0.h"
#include "bsproj1.h"
#include "bsdotp.h"
#include "bsxlnpl.h"
#include "bssrtptslnv.h"
#include "bsbxint.h"
#include "bstagsort.h"
#include "bsconic.h"
#include "magrotmx.h"
#include "matypemx.h"
#include "madetplan.h"
#include "bslenvecsq.h"
#include "bscrossp.h"
#include "maptscent.h"
#include "bsx2pln.h"
#include "bsorthovec.h"
#include "bsgeom_cvsf.h"
#include "bsdistptli.h"
#include "bsalloccv.h"
#include "bsallocsf.h"
#include "bsfreecv.h"
#include "bsfreesf.h"
#include "bssf_rev.h"
#include "maraddeg.h"
#include "bscveval.h"
#include "bssftgeomsf.h"
#include "bsxlngmcyl.h"
#include "bsxlngmsph.h"
#include "bsxlngmtor.h"
#include "bsxlngmcon.h"

#include "PWapi/mdstptgm.h"
#include "PWapi/rngbx.h"
#include "PWapi/mkvec.h"
#include "PWapi/normvec.h"
#include "PWapi/dotp.h"
#include "PWapi/sfptloc.h"

/* Imports */
from GRvg         import GRdetplane, GRgeomprops, EMptatpr;
from EMSdpr       import EMmake_primitive1;
from GRcurve      import GRendpts;
from EMSsolid     import EMorient_yourself;
from EMSplane     import EMplane_of_curve;
from EMSdatpln    import EMget_pln_info;
from GRgraphics   import GRconstruct, GRptproject;
from EMSsurface   import EMgetactiveid, EMget_point_on_surface;
from EMSsfstitch  import EMmake_comp;
from EMScompsurf  import EMmovesurfs;

/* externs */
extern IGRlong EMplace_surf_of_projection();
extern IGRlong EMplace_surf_of_revolution();
extern GRclassid OPP_EMSplane_class_id;
extern GRclassid OPP_EMSdatpln_class_id;
extern GRclassid OPP_EMSsfstitch_class_id, OPP_EMSgensolid_class_id;
extern GRclassid OPP_EMScylindr_class_id,OPP_EMStorus_class_id,
                 OPP_EMSptorus_class_id;
extern GRclassid OPP_EMSpcylindr_class_id,OPP_EMSsphere_class_id,
                 OPP_EMSpsphere_class_id,OPP_EMScone_class_id,
                 OPP_EMSpcone_class_id;
static void GetStartAndSweepAngles
(
  IGRdouble from_int_angs[2],
  IGRdouble to_int_angs[2],
  IGRdouble *start_ang,
  IGRdouble *sweep_ang,
  IGRdouble *svsd_ang,
  double    tol
);

#define SecSolid_NoCaps  0x01
#define SecSolid_OneCap  0x02

/*
 * NAME
 *      IGRlong   EMcreate_secondary_solid()
 *
 * ABSTRACT
 *
 * This function is being written for creating the solids provided diff.
 * options. The aim  is to provide a single functionality for creating
 * secondary solid for features like add material/remove material. The
 * various cases which may arise are :
 *       0) type, whether projected/revolved/skinned.
 *       1) options related to to_next/from_to/finite.
 *       2) from surf GRid.
 *       3) to_surf GRid.
 *       4) directional vector incase the option happens to be to_next.
 *       5) angular value.
 *       6) boolean related to symmetric/asymmetric.
 *       7) information about axis of revolution.
 *       8) information about the trace curve.
 * Output:
 *       0) GRid of the solid created.
 *
 * SYNOPSIS
 *
 * RETURN VALUES
 *
 * ALGORITHM
 *
 * NOTES
 *
 *
 * HISTORY
 *    Rustagi 07/26/93    Creation.
 *    Sanjay  04/??/94    Header Creation.
 *    Sanjay  04/??/94    Modified to incorporate the intesect surface save
 *                        side in from to case of Add/Remove material.
 *    Sanjay  05/??/94    Rewritten the main function.
 *    Sanjay  05/??/94    Added checks every where.
 *    Sanjay  05/??/94    Fixed problems in getting the start and stop points
 *                        in case of "from to" option. If any of the from/to
 *                        surface is a plane parallel to the plane of the
 *                        profile, then the profile is transformed to that
 *                        surface and from there the secondary solid is
 *                        created. So, as it is transformed to one of the
 *                        surface there is no need to intersect the secondary
 *                        solid with this surface.
 *    Sp.B    12/21/96    From - to projected algorithm is modified to
 *                        handle intersecting from - to surfaces and also
 *                        to add material beyond the range box limits of
 *                        the base solid
 */

IGRlong EMcreate_secondary_solid (
IGRlong                *msg,
IGRlong                solopts,
IGRlong                feaopts,
struct GRvg_construct  *const_args,
struct ProfileInfo     *prof_info,
struct ModProfileInfo  *modprof_info,
struct GRid            *from_surf_GRid,
struct GRid            *to_surf_GRid,
struct GRmd_env        *modenvsf,
IGRdouble              *proj_vec,
IGRdouble              *proj_dist,
IGRdouble              *sweep_angle,
IGRdouble              *axis_ends,
struct TraceInfo       *trace_info,
struct GRid            *base_solid,
IGRint                 *num_coinc_sfs,
struct GRid            ***coinc_sfs_grid,
struct SecSolidInfo    *sec_slinfo )
{
 /*
  * LOCAL VARIABLES DECLARATION                   
  */
 IGRint                   cnt, ii;
 IGRlong                  msg_loc, sts, opts=0;
 GRspacenum               os;
 IGRboolean               projected, revolved, skinned, ok;
 struct GRid              new_prof_id, *profid, slgrid, solid_GRid;
 struct GRmd_env          *modenvcv;
 struct FromToSurfInfo    surf_info;
 struct EMSobject_info    cv_info;

 /* Skin Surface Info */
 struct SkinSurfInfo      skin_info;
 OMuword                  solidclass;

 IGRboolean               from_surf_created=FALSE;

 
 //   Initialize the return status 
 sts                              = OM_S_SUCCESS;
 *msg                             = EMS_S_Success;
 msg_loc                          = EMS_S_Success;


 // INITIALIZATIONS 
 profid = &prof_info->grid;
 modenvcv = &prof_info->mdenv;
 os = profid->osnum; slgrid.osnum = os;
 memset( &surf_info, 0, sizeof(struct FromToSurfInfo) );
 new_prof_id.objid = NULL_OBJID;

 projected = (solopts & EMSfeature_projected) ? TRUE : FALSE;
 revolved  = (solopts & EMSfeature_revolved)  ? TRUE : FALSE;
 skinned   = (solopts & EMSfeature_skinned)   ? TRUE : FALSE;

 /*
  * In case of from-to option, if there is no from surface which is a
  * planar surface (which also means that it is from the ref. plane of
  * of the profile), create a dummy surface.
  */
 if ((feaopts & EMSfeature_from_to) && from_surf_GRid->objid == NULL_OBJID)
 {
   BSrc       rc=BSSUCC;
   GRrange    slrange;
   IGRdouble  poles[12], uknots[2], vknots[2];
   IGRboolean in_range=FALSE;
   struct IGRbsp_surface pln_sfgeom;

   memset (&pln_sfgeom, 0, sizeof(struct IGRbsp_surface));
   pln_sfgeom.poles = &poles[0];
   pln_sfgeom.u_knots = &uknots[0];
   pln_sfgeom.v_knots = &vknots[0];

   GetObjectRange (base_solid->objid, base_solid->osnum, modenvsf, slrange);
   BSplptnorrg (slrange, &slrange[3], prof_info->plane.point, 
                prof_info->plane.normal, 1.0, &in_range, &pln_sfgeom, &rc); 

   const_args->geometry = (char *) &pln_sfgeom;
   sts = om$construct (classid = OPP_EMSplane_class_id,
                       p_objid = &from_surf_GRid->objid, 
                       msg = message GRgraphics.GRconstruct (const_args));
   add$status( test = !(1&sts), msg = *msg, code = EMS_E_Fail, 
       str = "EMcreate_secondary_solid : om$construct error",
       action = GOTO_VALUE,  value = ret_end );
   const_args->geometry = NULL; 

   from_surf_GRid->osnum = const_args->env_info->md_id.osnum;
   from_surf_created = TRUE;
 }

 if(projected)  // if projected, generate solid of projection 
 {
    struct EMSpoint_info     base_point, height_point;

    /*
     * get the start and stop point of the projection given the options.
     */
    sts = EMget_projection_start_stop_pt( &msg_loc, feaopts, prof_info,  
                                   proj_vec, proj_dist, from_surf_GRid, 
                                   to_surf_GRid, modenvsf, base_solid, 
                                   &new_prof_id, &surf_info );
    add$status( test = !(1&sts&msg_loc), msg = *msg, code = msg_loc, 
        str = "EMcreate_secondary_solid : EMget_projection_start_stop_pt error",
        action = GOTO_VALUE,  value = ret_end );

    /*
     * Create the solid of projection.
     */
    OM_BLOCK_MOVE(&new_prof_id, &cv_info.grid, sizeof(struct GRid));
    OM_BLOCK_MOVE(modenvcv, &cv_info.env, sizeof(struct GRmd_env));

    /*
     * Based on the type of feature i.e. add_mat/rem_mat & feaopts,
     * some additional thing needs to be done to avoid coplanarity.
     */
    base_point.type = EMSdatainfo_numeric;
    OM_BLOCK_MOVE(&surf_info.d.proj_pts[0], base_point.pt, sizeof(IGRpoint));
    height_point.type = EMSdatainfo_numeric;
    OM_BLOCK_MOVE(&surf_info.d.proj_pts[3], height_point.pt, sizeof(IGRpoint));

    sts = EMplace_surf_of_projection(&msg_loc,
                            EMSasconst_notassociative,
                            const_args->env_info,
                            const_args->level,
                            const_args->display,
                            const_args->class_attr,
                            const_args->name,
                            &cv_info,
                            &base_point,
                            &height_point,
                            TRUE,
                            &slgrid.objid);
    if (new_prof_id.objid != NULL_OBJID && new_prof_id.objid != profid->objid)
      DeleteObject (&new_prof_id.objid, modenvcv);
    add$status( test = !(1&sts&msg_loc), msg = *msg, code = msg_loc,
        str = "EMcreate_secondary_solid : EMplace_surf_of_projection error",
        action = GOTO_VALUE,  value = ret_end );
 }
 else if( revolved ) // if revolved, generate solid of revolution
 {
    IGRboolean               is_solid = TRUE;
    struct EMSpoint_info     axis[2];
    struct EMSvalue_info     start, sweep;
   
    OM_BLOCK_MOVE(profid, &cv_info.grid, sizeof(struct GRid));
    OM_BLOCK_MOVE(modenvcv, &cv_info.env, sizeof(struct GRmd_env));

    start.type    = EMSdatainfo_numeric;
    sweep.type    = EMSdatainfo_numeric;
    axis[0].type  = EMSdatainfo_numeric;
    axis[1].type  = EMSdatainfo_numeric;

    start.val = 0.0;
    if( feaopts & EMSfeature_finite )
    {
      if( (feaopts & EMSfeature_symmetric) && (*sweep_angle != 360.0) ) 
        start.val = - (*sweep_angle / 2.0);
      sweep.val = *sweep_angle;
      if (sweep.val == 360.0)
        opts = SecSolid_NoCaps;
    }
    else if( feaopts & EMSfeature_thru_all )
    {
      sweep.val = 360.0;
    }
    else if( feaopts & EMSfeature_from_to )
    {
      sts = EMget_revolution_svsdpt( &msg_loc, const_args, prof_info, 
                                     axis_ends, from_surf_GRid, to_surf_GRid, 
                                     &surf_info );
      add$status( test = !(1&sts&msg_loc), msg = *msg, code = msg_loc,
          str = "EMcreate_secondary_solid : EMget_revolution_svsdpt error",
          action = GOTO_VALUE,  value = ret_end );

      start.val = surf_info.d.rev_angs[0];
      sweep.val = surf_info.d.rev_angs[1];
    }
    else if (feaopts & EMSfeature_to_next)
    {
      sweep.val = 359.0;
    }
    else if (feaopts & EMSfeature_thru_next)
    {
      sweep.val = 360.0;
    }

    if( (sweep.val != 360.0) )
    {
       struct GRprops  props;

       ok = GetObjectGeomProps( profid->objid, profid->osnum, modenvcv, &props );
       add$status( test = !ok, msg = *msg, code = msg_loc,
           str = "EMcreate_secondary_solid : GetObjectGeomProps error",
           action = GOTO_VALUE,  value = ret_end );

       if( !props.phy_closed )
         is_solid = FALSE;
    }

    OM_BLOCK_MOVE( &axis_ends[0], axis[0].pt, sizeof(IGRpoint) ); 
    OM_BLOCK_MOVE( &axis_ends[3], axis[1].pt, sizeof(IGRpoint) ); 

    sts = EMplace_surf_of_revolution( &msg_loc, 
                            EMSasconst_notassociative,
                            const_args->env_info,
                            const_args->level,
                            const_args->display,
                            const_args->class_attr,
                            const_args->name,
                            &cv_info,
                            axis,
                            &start, 
                            &sweep,
                            is_solid,
                            &slgrid.objid);
    add$status( test = !(1&sts&msg_loc), msg = *msg, code = msg_loc,
        str = "EMcreate_secondary_solid : EMplace_surf_of_revolution error",
        action = GOTO_VALUE,  value = ret_end );

    if( !is_solid )
    {
       struct GRid  sfgrid;

       sfgrid.objid = slgrid.objid;
       sfgrid.osnum = os;
       sts = EMcap_surface_of_revolution( &msg_loc, const_args, &sfgrid, 
                                          profid, axis_ends, start.val, 
                                          sweep.val, &slgrid );
       add$status( test = !(1&sts&msg_loc), msg = *msg, code = msg_loc,
           str = "EMcreate_secondary_solid : EMcap_surface_of_revolution error",
           action = GOTO_VALUE,  value = ret_end );

    }
 }
 else if( skinned )  // if skinned, generate skinning solid
 { 
    IGRlong          skin_opts = 0;
    struct GRlc_info sec_cv, trc_cv;
    struct GRprops   trc_cv_props;

    /*
     * Fill in the info of cross-section and trace curves. 
     */
    opts = 0;
    sec_cv.located_obj = *profid;
    sec_cv.geom_parms.polygon_inx = 0;
    trc_cv.located_obj = trace_info->grid;
    trc_cv.geom_parms.polygon_inx = trace_info->reverse;
    OM_BLOCK_MOVE(modenvcv, &sec_cv.module_info, sizeof(struct GRmd_env));
    OM_BLOCK_MOVE(modenvcv, &trc_cv.module_info, sizeof(struct GRmd_env));

    ok = GetObjectGeomProps(trace_info->grid.objid, trace_info->grid.osnum, 
                            modenvcv, &trc_cv_props);
    add$status( test = !ok, msg = *msg, code = msg_loc,
        str = "EMcreate_secondary_solid : GetObjectGeomProps error",
        action = GOTO_VALUE,  value = ret_end );

    skin_opts = SKIN_OPT_MADECOMP; 
    if(trc_cv_props.phy_closed)
    {
      opts |= SecSolid_NoCaps;
      skin_opts |= SKIN_OPT_CLOSED;
    }

    /*
     * Create Skin Solid
     */
    sts = EFPlaceSkinSolid( &msg_loc, skin_opts, const_args, (IGRint) 1,
                            &sec_cv, (IGRint) 1, &trc_cv, &slgrid, 
                            &skin_info );
    add$status( test = !(1&sts&msg_loc), msg = *msg, code = msg_loc,
        str = "EMcreate_secondary_solid : EFPlaceSkinSolid error",
        action = GOTO_VALUE,  value = ret_end );
 }

 /*
  * In case of the feature "EMSfeature_from_to" some special processing
  * is required in some of the cases on the capped solid. It needs to
  * get to be trimmed against the reference planes.
  */
 if((feaopts & EMSfeature_from_to) && surf_info.num_sfs )
 {
  IGRint      num_sfs = surf_info.num_sfs, num_sfs_failed = 0;
  IGRushort   intsl_opts=0,*sfs_opts = NULL;
  IGRboolean  *ext_sfs = NULL, made_compsurf, from_and_to_are_same=FALSE;
  struct GRid *sfs_grid = NULL;
  IGRdouble   *svsd_pts = NULL;
  IGRboolean  to_surf_from_base_solid, from_surf_from_base_solid;
  IGRboolean  from_is_ref_pln, to_is_ref_pln, from_is_pln, to_is_pln;
  struct GRid *int_sfs_grid=NULL, *failed_sfs_grid = NULL;
  struct GRid act_from_surf_GRid, act_to_surf_GRid;

  from_surf_from_base_solid = to_surf_from_base_solid = FALSE;

  from_is_ref_pln = (surf_info.props & FROM_SURF_REFPLANE) ? TRUE : FALSE; 
  from_is_pln = (surf_info.props & FROM_SURF_PLANE) ? TRUE : FALSE; 
  to_is_ref_pln = (surf_info.props & TO_SURF_REFPLANE) ? TRUE : FALSE; 
  to_is_pln = (surf_info.props & TO_SURF_PLANE) ? TRUE : FALSE; 
  made_compsurf = (surf_info.props & FROMTO_MADE_COMPSURF) ? TRUE : FALSE;
  from_and_to_are_same = (surf_info.props & FROM_AND_TO_ARE_SAME) ? TRUE : FALSE;

  sfs_opts = (IGRushort *) alloca( num_sfs * sizeof(IGRushort));
  ext_sfs  = (IGRboolean *) alloca( num_sfs * sizeof(IGRboolean));
  sfs_grid = (struct GRid *) alloca( num_sfs * sizeof(struct GRid));
  svsd_pts = (IGRdouble *) alloca( num_sfs * 3 * sizeof(IGRdouble) );  
  intsl_opts = 0x1;

  if( !from_is_ref_pln && !from_is_pln )
  {
     sts = om$send( msg = message EMSsurface.EMgetactiveid( &msg_loc,
                                  &act_from_surf_GRid, NULL ),
                    senderid = NULL_OBJID,
                    targetid = from_surf_GRid->objid,
                    targetos = from_surf_GRid->osnum );
     if( (1 & sts & msg_loc) &&
         (IF_EQ_OBJID( act_from_surf_GRid.objid, base_solid->objid)) )
        from_surf_from_base_solid = TRUE;
  }

  if (!to_is_ref_pln && !to_is_pln && !from_and_to_are_same && !made_compsurf)
  {
     sts = om$send( msg = message EMSsurface.EMgetactiveid( &msg_loc,
                                  &act_to_surf_GRid, NULL ),
                    senderid = NULL_OBJID,
                    targetid = to_surf_GRid->objid,
                    targetos = to_surf_GRid->osnum );
     if( (1 & sts & msg_loc) &&
         (IF_EQ_OBJID( act_to_surf_GRid.objid, base_solid->objid)) )
         to_surf_from_base_solid = TRUE;
  }

  if( coinc_sfs_grid && num_coinc_sfs )
  {
     cnt = 0;
     *num_coinc_sfs = 0;
     if (from_surf_from_base_solid)
         cnt ++;
     if (to_surf_from_base_solid)
         cnt++;

     *num_coinc_sfs = cnt;
     if( cnt )
     {
       *coinc_sfs_grid = (struct GRid **) om$malloc(
                                     size = cnt * sizeof( struct GRid *) );
       for( ii=0; ii<cnt; ii++)
            coinc_sfs_grid[0][ii] = (struct GRid *) om$malloc(
                                          size = 2 * sizeof(struct GRid));
     }
  }

  /*
   * From and To surface is same. So the final solid will contain only one
   * capped surface.
   */
  if (from_and_to_are_same) 
    opts |= SecSolid_OneCap;

  for( cnt=0; cnt<num_sfs; cnt++ )
  {
    sfs_opts[cnt] = from_and_to_are_same ? KEEP_ALL_GROUPS : 
                                           KEEP_ONLY_ONE_GROUP;
    sfs_grid[cnt] = surf_info.sfs_grid[cnt]; 
    ext_sfs[cnt]  = TRUE;
    OM_BLOCK_MOVE( surf_info.svsdpt, &svsd_pts[cnt*3], sizeof(IGRpoint) );
  }
  sts = EFplsolid_by_trimming_with_surfaces( &msg_loc, intsl_opts, const_args, 
               num_sfs, sfs_opts, sfs_grid, ext_sfs, svsd_pts, &slgrid,
               const_args->env_info, &int_sfs_grid, &num_sfs_failed,
               &failed_sfs_grid, &solid_GRid);
  add$status( test = !(1&sts&msg_loc), msg = *msg, code = msg_loc,
      str = "EMcreate_secondary_solid : EFplsolid_by_trimming_with_surfaces error",
      action = GOTO_VALUE,  value = loc_ret_end );

#ifdef DEBUG
    printf("number of surfaces failed to intersect: %d\n", num_sfs_failed);
    for(cnt=0; cnt<num_sfs_failed; cnt++)
        printf("failed_sf_grid[%d] = ( %d, %d )\n",cnt,
                failed_sfs_grid[cnt].objid, failed_sfs_grid[cnt].osnum );
#endif

  add$status( test = num_sfs_failed, msg = *msg, code = msg_loc, 
      str = "EMcreate_secondary_solid : EFplsolid_by_trimming_with_surfaces error",
      action = GOTO_VALUE,  value = loc_ret_end );


  if( coinc_sfs_grid && num_coinc_sfs && *num_coinc_sfs )
  {
    cnt = 0;
    if (from_surf_from_base_solid) 
    {
      coinc_sfs_grid[0][cnt][0] = *from_surf_GRid;

      if( made_compsurf )
        coinc_sfs_grid[0][cnt][1] = surf_info.sfs_grid[cnt];
      else
        coinc_sfs_grid[0][cnt][1] = int_sfs_grid[cnt];
      cnt++;
    }

    if (to_surf_from_base_solid)
    {
      coinc_sfs_grid[0][cnt][0] = *to_surf_GRid;
      if( made_compsurf )
        coinc_sfs_grid[0][cnt][1] = surf_info.sfs_grid[cnt];
      else
        coinc_sfs_grid[0][cnt][1] = int_sfs_grid[cnt];
    }
  }

 loc_ret_end :
   /*
    * If there is any failure in intersecting the secondary solid with from/
    * to surface, then error out accordingly.
    */
   if( num_sfs_failed )
   {
      IGRboolean ok;

      if( failed_sfs_grid[0].objid == surf_info.sfs_grid[0].objid )
         *msg = EMS_E_AddRmNoIntFromSurf;
      else
         *msg = EMS_E_AddRmNoIntToSurf;
      /*
       * For failed surfaces, delete all the respective copies made.
       */
      for( ii=0; ii<num_sfs_failed; ii++ )
      {
        ok = DeleteObject(&failed_sfs_grid[ii].objid, const_args->env_info);
      }
    }

    if( int_sfs_grid )     om$dealloc( ptr = int_sfs_grid );
    if( failed_sfs_grid )  om$dealloc( ptr = failed_sfs_grid );
 }
 else
 {
   solid_GRid.objid = slgrid.objid;
   solid_GRid.osnum = os;
 }

 solidclass = GetObjectClass (solid_GRid.objid, solid_GRid.osnum);

 if (is_a_subclass(solidclass, OPP_EMSdpr_class_id) == OM_S_SUCCESS)
 {
   /*
    * compress the state tree
    */
   sts = om$send( msg = message EMSdpr.EMmake_primitive1( &msg_loc,
                                       const_args->env_info,
                                       &solid_GRid ),
                  senderid = NULL_OBJID,
                  targetid = solid_GRid.objid,
                  targetos = solid_GRid.osnum );
   add$status( test = !(1&sts&msg_loc), msg = *msg, code = EMS_E_Fail,
       str = "EMcreate_secondary_solid : EMSdpr.EMmake_primitive1 error",
       action = GOTO_VALUE,  value = ret_end );
 }
 else
 {
   struct GRid prim_grid;

   prim_grid.osnum = solid_GRid.osnum;
   sts = om$construct (classid = OPP_EMSgensolid_class_id,
                       p_objid = &prim_grid.objid,
                       osnum = solid_GRid.osnum);
   add$status( test = !(1&sts), msg = *msg, code = EMS_E_Fail,
       str = "EMcreate_secondary_solid : om$construct error",
       action = GOTO_VALUE,  value = ret_end );

   sts = om$send (msg = message EMScompsurf.EMmovesurfs (&msg_loc,
                                &prim_grid, const_args->env_info), 
                  senderid = NULL_OBJID,
                  targetid = solid_GRid.objid,
                  targetos = solid_GRid.osnum );
   add$status( test = !(1&sts&msg_loc), msg = *msg, code = EMS_E_Fail,
       str = "EMcreate_secondary_solid : EMSsurface.EMmovesurfs error",
       action = GOTO_VALUE,  value = ret_end );

   solid_GRid.objid = prim_grid.objid;
 }

 ok = GetSecondarySolidInfo (&msg_loc, opts, solopts, modprof_info, 
              &solid_GRid, const_args->env_info,(skinned ? &skin_info : NULL), 
              sec_slinfo);
 add$status( test = !ok, msg = *msg, code = EMS_E_Fail,
     str = "EMcreate_secondary_solid : GetSecondarySolidInfo error",
     action = GOTO_VALUE,  value = ret_end );

ret_end:

  if (from_surf_created)
    DeleteObject (&from_surf_GRid->objid, const_args->env_info);

  EMWRAPUP( *msg, sts, "EMcreate_secondary_solid"); 
  return(sts);
}

#define  X   0
#define  Y   1
#define  Z   2

/*
 * NAME
 *         EMget_projection_start_stop_pt
 *
 * ABSTRACT
 *         This function computes the "right" projection distance needed
 *         for creating the right sized solid for the feature creation.
 *         Incase of features "finite(symetric)" and "from_to" where the 
 *         projection vector end points are not available directly, these 
 *         inputs are assumed to be passed as NULL.
 *
 * SYNOPSIS
 *
 * RETURN VALUES
 *
 * ALGORITHM
 *
 * NOTES
 *
 * HISTORY
 */

IGRlong EMget_projection_start_stop_pt (
IGRlong                *msg,
IGRlong                feaopts,
struct ProfileInfo     *prof_info,
IGRdouble              *proj_vec,
IGRdouble              *proj_dist,
struct GRid            *from_surf_id,
struct GRid            *to_surf_id,
struct GRmd_env        *modenvsf,
struct GRid            *base_solid,
struct GRid            *new_prof_id,
struct FromToSurfInfo  *surf_info )
{
 /*
  * VARIABLES DECLARATION
  */
 // GENERAL
 BSrc         rc=BSSUCC;
 IGRint       i, index, num_values, sort_ind[4];
 IGRlong      msg_loc, sts;
 GRobjid      save_md_id;
 OMuword      classid;
 IGRshort     xform_mattyp, cvmat_type, sfmat_type;

 // POINTS FOR PROJECTION 
 IGRpoint     projpt1, projpt2, startpt_prjvec, from_ref_pt, to_ref_pt, minpt, 
              maxpt, ref_pt, from_min, from_max, to_min, to_max, begin_prjvec, 
              the_start_point, the_stop_point, the_mid_point,from_ref_pt1,
              to_ref_pt1,midpt;
 IGRvector    vec0, vec1, vec2, vec3, xforms_vec;
 IGRdouble    value1, value2, cht_tol, *cvmat=NULL, *sfmat=NULL, result1, 
              result2, lentol, dist1, dist2, dist3, dist4, chord_ht, 
              dotp, dist, dist_comp, values[4], prjvec_pts[2][3];

 // BOOLEANS
 IGRmatrix    xform_mat;

 IGRboolean   from_is_ref_pln, to_is_ref_pln, transform_profile, success,
              from_is_same_as_profile_plane,  to_is_same_as_profile_plane,
              to_is_pln, from_is_pln,  from_is_plane, to_is_plane, ok,
              from_is_sphere,from_is_cone,from_is_cyl,from_is_tau,
              from_is_psphere,from_is_pcone,from_is_pcyl,from_is_ptau,
              to_is_sphere,to_is_cone,to_is_cyl,to_is_tau,
              to_is_pcone,to_is_pcyl,to_is_psphere,to_is_ptau,no_int_from,
              no_int_to;
 

 // GENERAL
 struct GRid            outcrv, *profile;
 struct GRmd_env        *modenvcv;
 struct IGRbsp_curve    *prof_geom=NULL; 
 struct IGRbsp_surface  *sf_geom=NULL;

 // FUNCTIONS
 IGRlong      EFplane_from_ref_pt();

 //  INITIALIZATIONS
 sts             = OM_S_SUCCESS;
 *msg            = EMS_S_Success;
 to_is_ref_pln   = FALSE;
 from_is_ref_pln = FALSE;
 to_is_pln       = FALSE;
 from_is_pln     = FALSE;
 to_is_plane     = FALSE;
 from_is_plane   = FALSE;
 from_is_sphere  = FALSE;
 from_is_cone    = FALSE;
 from_is_cyl     = FALSE;
 from_is_tau     = FALSE;
 from_is_psphere = FALSE;
 from_is_pcone   = FALSE;
 from_is_pcyl    = FALSE;
 from_is_ptau    = FALSE; 
 to_is_sphere    = FALSE;
 to_is_cone      = FALSE;
 to_is_cyl       = FALSE;
 to_is_tau       = FALSE;
 to_is_pcone     = FALSE;
 to_is_psphere   = FALSE;
 to_is_pcyl      = FALSE;
 to_is_ptau      = FALSE;
 no_int_to       = FALSE;
 no_int_from     = FALSE;
 
 transform_profile = FALSE;
 to_is_same_as_profile_plane   = FALSE;
 from_is_same_as_profile_plane = FALSE;
 BSEXTRACTPAR(&rc, BSTOLCHRDHT, chord_ht);

 profile = &prof_info->grid; 
 modenvcv = &prof_info->mdenv; 
 memset( surf_info, 0, sizeof(struct FromToSurfInfo) );

 cvmat             = modenvcv->md_env.matrix;
 cvmat_type        = modenvcv->md_env.matrix_type;
 sfmat             = modenvsf->md_env.matrix;
 sfmat_type        = modenvsf->md_env.matrix_type;

 sts = BSEXTRACTPAR (&rc, BSTOLLENVEC, lentol);
 sts = BSEXTRACTPAR(&msg_loc, BSTOLCHRDHT, cht_tol);
 cht_tol *= 10.0; 

 /*
  * get a point on the profile.
  */
 sts = EMgetvggeom( &msg_loc, &modenvcv->md_env.matrix_type, 
                    modenvcv->md_env.matrix, profile, &prof_geom, NULL );
 add$status( test = !(1&sts&msg_loc), msg = *msg, code = EMS_E_Fail,
     str = "EMget_projection_start_stop_pt : EMgetvggeom error",       
     action = GOTO_VALUE, value = ret_end );

 BScveval( prof_geom, (IGRdouble) 0.5, (IGRint) 0, &begin_prjvec, &msg_loc );
 add$status( test = BSERROR(msg_loc), msg = *msg, code = EMS_E_BSerror,
     str = "EMget_projection_start_stop_pt : BScveval error",       
     action = GOTO_VALUE, value = ret_end );

 om$dealloc( ptr = prof_geom ); prof_geom = NULL;

  
 for(i=0; i<3; i++)
 {
    prjvec_pts[0][i] = begin_prjvec[i];
    prjvec_pts[1][i] = prjvec_pts[0][i] + proj_vec[i];
 }

 OM_BLOCK_MOVE(begin_prjvec, startpt_prjvec, sizeof(IGRpoint));

 if( (feaopts & EMSfeature_to_next) || (feaopts & EMSfeature_thru_next) ||
     (feaopts & EMSfeature_thru_all) )
 {
    GRrange         prof_range, solid_range;
    IGRpoint        rngpts[8], projpts[8], inf_line[2];
    IGRpoint        maxpt, minpt;
    IGRdouble       diag=0, mindist=0, maxdist=0; 

    /*
     * get the range box limits of the base solid.
     */
    ok = GetSurfaceRtreeRange( base_solid->objid, base_solid->osnum, modenvsf, 
                               solid_range );
    add$status( test = !ok, msg = *msg, code = EMS_E_Fail,
        str = "EMget_projection_start_stop_pt : GetObjectRange error",       
        action = GOTO_VALUE, value = ret_end );

    diag = pwDistPtPt(&solid_range[0], &solid_range[3]);
    EM3dbxinc (solid_range, 0.05 * diag);

    /*
     * get the range box limits of the profile
     */
    ok = GetObjectRange( profile->objid, profile->osnum, modenvcv, prof_range );
    add$status( test = !ok, msg = *msg, code = EMS_E_Fail,
        str = "EMget_projection_start_stop_pt : GetObjectRange error",       
        action = GOTO_VALUE, value = ret_end );

    /*
     * get all the eight range box points of the solid.
     */
    pwGetRngPts ((PWpoint *) &solid_range[0], rngpts);

    /*
     * Take the minimum range box point and form a infinite line and project
     * all the eight range box points on to this line. Take the extreme points
     * on this line and compute the minimum and maximum projection distances.
     */
 
    memcpy (&inf_line[0][0], &prof_range[0], sizeof (IGRpoint));
    for (i=0; i<3; i++)
      inf_line[1][i] = inf_line[0][i] + proj_vec[i];

    for (i=0; i<8; i++)
    {
      BSproj0 (&rc, rngpts[i], inf_line, projpts[i]);
      add$status( test = BSERROR (rc), msg = *msg, code = EMS_E_BSerror,
        str = "EMget_projection_start_stop_pt : BSproj0 error",
        action = GOTO_VALUE,  value = ret_end );
    }

    sts = pwMinMaxPtsAlongVec (8, projpts, proj_vec, maxpt, minpt);
    add$status( test = BSERROR (rc), msg = *msg, code = EMS_E_BSerror,
        str = "EMget_projection_start_stop_pt : pwMinMaxPtsAlongVec error",
        action = GOTO_VALUE,  value = ret_end );

    pwMakeVec (&prof_range[0], maxpt, vec0);
    pwNormVec (vec0, vec0);
    pwMakeVec (&prof_range[0], minpt, vec1);
    pwNormVec (vec1, vec1);

    dist = pwDistPtPt (&prof_range[0], maxpt);
    if (pwDot (vec0, proj_vec) > 0)
      maxdist = dist;
    else
      mindist = dist;

    dist = pwDistPtPt (&prof_range[0], minpt);
    if (pwDot (vec1, proj_vec) > 0)
    {
      if (dist > maxdist) 
        maxdist = dist;
    }
    else
    {
      if (dist > mindist) 
        mindist = dist;
    }

    /*
     * Take the maximum range box point and form a infinite line and project
     * all the eight range box points on to this line. Take the extreme points
     * on this line and compute the minimum and maximum projection distances.
     */
 
    memcpy (&inf_line[0][0], &prof_range[0], sizeof (IGRpoint));
    
    memcpy (&inf_line[0][0], &prof_range[3], sizeof (IGRpoint));
    for (i=0; i<3; i++)
      inf_line[1][i] = inf_line[0][i] + proj_vec[i];

    for (i=0; i<8; i++)
    {
      BSproj0 (&rc, rngpts[i], inf_line, projpts[i]);
      add$status( test = BSERROR (rc), msg = *msg, code = EMS_E_BSerror,
        str = "EMget_projection_start_stop_pt : BSproj0 error",
        action = GOTO_VALUE,  value = ret_end );
    }

    sts = pwMinMaxPtsAlongVec (8, projpts, proj_vec, maxpt, minpt);
    add$status( test = BSERROR (rc), msg = *msg, code = EMS_E_BSerror,
        str = "EMget_projection_start_stop_pt : pwMinMaxPtsAlongVec error",
        action = GOTO_VALUE,  value = ret_end );

    pwMakeVec (&prof_range[3], maxpt, vec0);
    pwNormVec (vec0, vec0);
    pwMakeVec (&prof_range[3], minpt, vec1);
    pwNormVec (vec1, vec1);

    dist = pwDistPtPt (&prof_range[3], maxpt);
    if (pwDot (vec0, proj_vec) > 0)
    {
      if (dist > maxdist) 
        maxdist = dist;
    } 
    else
    {
      if (dist > mindist)
        mindist = dist;
    }

    dist = pwDistPtPt (&prof_range[3], minpt);
    if (pwDot (vec1, proj_vec) > 0)
    {
      if (dist > maxdist) 
        maxdist = dist;
    }
    else
    {
      if (dist > mindist)
        mindist = dist;
    }

    for(i=0; i<3; i++)
    {
       projpt1[i] = startpt_prjvec[i] - proj_vec[i] * mindist;
       projpt2[i] = startpt_prjvec[i] + proj_vec[i] * maxdist;
    }
 }

 /*
  * Feature : TO NEXT / THRU NEXT 
  */
 if( (feaopts & EMSfeature_to_next) || (feaopts & EMSfeature_thru_next) )
 {
    sts = BSmkvec(&rc, vec0, startpt_prjvec, projpt1);
    add$status( test = BSERROR(rc), msg = *msg, code = EMS_E_BSerror,
        str = "EMget_projection_start_stop_pt : BSmkvec error",
        action = GOTO_VALUE,  value = ret_end );

    BSnorvec(&rc, vec0);

    sts = BSmkvec(&rc, vec1, startpt_prjvec, projpt2);
    add$status( test = BSERROR(rc), msg = *msg, code = EMS_E_BSerror,
        str = "EMget_projection_start_stop_pt : BSmkvec error",
        action = GOTO_VALUE,  value = ret_end );

    BSnorvec(&rc, vec1);

    value1 = BSdotp(&rc, proj_vec, vec0);
    add$status( test = BSERROR(rc), msg = *msg, code = EMS_E_BSerror,
        str = "EMget_projection_start_stop_pt : BSdotp error",
        action = GOTO_VALUE,  value = ret_end );

    value2 = BSdotp(&rc, proj_vec, vec1);
    add$status( test = BSERROR(rc), msg = *msg, code = EMS_E_BSerror,
        str = "EMget_projection_start_stop_pt : BSdotp error",
        action = GOTO_VALUE,  value = ret_end );

    OM_BLOCK_MOVE(startpt_prjvec, the_start_point, sizeof(IGRpoint));

    if(value1 > 0.0 && value1 > value2)
       OM_BLOCK_MOVE(projpt1, the_stop_point, sizeof(IGRpoint));
    else if(value2 > 0.0)
       OM_BLOCK_MOVE(projpt2, the_stop_point, sizeof(IGRpoint));
    else
       add$status( test = TRUE, msg = *msg,
           code = EMS_E_AddRmDisjoint,
           str = "EMget_projection_start_stop_pt : Operation results in Disjoint Solid.",
           action = GOTO_VALUE,  value = ret_end );

 }
 /*
  * Feature : FROM-TO
  * 
  * information specific to "from_to" case feature_type.
  */
 else if(feaopts & EMSfeature_from_to)
 {
   int             k, j;
   OMuword         os=from_surf_id->osnum;
   GRrange         from_range, to_range;
   IGRboolean      from_and_to_are_same = FALSE;
   struct          IGRplane               plane_of_profile, plane_of_ref;
   GRrange         prof_range ;
   struct          BSgeom_bsp_surf        geom_surf;
   IGRpoint        intpts[4],intpts1, inter_pt[150];
   IGRint          tnpts=0,tnpts1=0,npts;
   IGRpoint        rngpts[8], inf_line[2],projpts1[150];

   IGRdouble         param ,parameter,uvpars[150];
   enum PWptloctype  fr_p_ptloc,to_p_ptloc,p_ptloc;
   struct PWgeomid   sfgeomid;
   PWobjid           p_bdryid;
   struct PWcvpt     p_edpt;
   IGRdouble         chttol;
   IGRlong           BSmsg;
   PWpoint           xyzpt;

   fr_p_ptloc = to_p_ptloc = p_ptloc = PWptloc_unknown;

   plane_of_ref.point      = (double *) alloca (sizeof (IGRpoint));
   plane_of_ref.normal     = (double *) alloca (sizeof (IGRvector));
   plane_of_profile.point  = (double *) alloca (sizeof (IGRpoint));
   plane_of_profile.normal = (double *) alloca (sizeof (IGRvector));

   /*
    * get the plane of the profile
    */
   if( !prof_info->plane.point || !prof_info->plane.normal )
   {
     sts = om$send( msg = message GRvg.GRdetplane( &msg_loc, &cvmat_type,
                                  cvmat, &plane_of_profile ),
                    senderid = NULL_OBJID,
                    targetid = profile->objid,
                    targetos = profile->osnum );
     add$status( test = !(1&sts&msg_loc), msg = *msg, code = EMS_E_Fail,
         str = "EMget_projection_start_stop_pt : GRdetplane error",
         action = GOTO_VALUE,  value = ret_end );
   }
   else
   {
     OM_BLOCK_MOVE( prof_info->plane.point, plane_of_profile.point, 
                    sizeof(IGRpoint) );
     OM_BLOCK_MOVE( prof_info->plane.normal, plane_of_profile.normal, 
                    sizeof(IGRvector) );
   }

   /*
    * find the class of the from and to surfaces 
    */ 
   sts = om$get_classid(objid = from_surf_id->objid,
                        osnum = from_surf_id->osnum,
                        p_classid = &classid);
   add$status( test = !(1&sts), msg = *msg, code = EMS_E_Fail,
       str = "EMget_projection_start_stop_pt : om$get_classid error",
       action = GOTO_VALUE,  value = ret_end );

   if(om$is_ancestry_valid(subclassid = classid,
                  superclassid = OPP_EMSdatpln_class_id) == OM_S_SUCCESS)
      from_is_ref_pln = TRUE;
   else if(om$is_ancestry_valid(subclassid = classid,
                  superclassid = OPP_EMSplane_class_id) == OM_S_SUCCESS)
      from_is_pln = TRUE;

   else if(om$is_ancestry_valid(subclassid = classid,
                  superclassid = OPP_EMSpcylindr_class_id) == OM_S_SUCCESS)
      from_is_pcyl =TRUE;

   else if(om$is_ancestry_valid(subclassid = classid,
                  superclassid = OPP_EMScylindr_class_id) == OM_S_SUCCESS)
       from_is_cyl = TRUE; 

   else if(om$is_ancestry_valid(subclassid = classid,
                  superclassid = OPP_EMSpsphere_class_id) == OM_S_SUCCESS)
      from_is_psphere = TRUE;

   else if(om$is_ancestry_valid(subclassid = classid,
                  superclassid = OPP_EMSsphere_class_id) == OM_S_SUCCESS)
      from_is_sphere = TRUE;

   else if(om$is_ancestry_valid(subclassid = classid,
                  superclassid = OPP_EMSpcone_class_id) == OM_S_SUCCESS)
      from_is_pcone = TRUE;

   else if(om$is_ancestry_valid(subclassid = classid,
                  superclassid = OPP_EMScone_class_id) == OM_S_SUCCESS)
      from_is_cone =TRUE;

   else if(om$is_ancestry_valid(subclassid = classid,
                  superclassid = OPP_EMSptorus_class_id) == OM_S_SUCCESS)
      from_is_ptau =TRUE;

   else if(om$is_ancestry_valid(subclassid = classid,
                  superclassid = OPP_EMStorus_class_id) == OM_S_SUCCESS)
      from_is_tau =TRUE;

   if( from_surf_id->objid == to_surf_id->objid &&
       from_surf_id->osnum == to_surf_id->osnum )
       from_and_to_are_same = TRUE;

   if( !from_and_to_are_same )
   {
       sts = om$get_classid(objid = to_surf_id->objid,
                            osnum = to_surf_id->osnum,
                            p_classid = &classid);
       add$status( test = !(1&sts), msg = *msg, code = EMS_E_Fail,
           str = "EMget_projection_start_stop_pt : om$get_classid error",
           action = GOTO_VALUE,  value = ret_end );
    
       if(om$is_ancestry_valid(subclassid = classid,
                        superclassid = OPP_EMSdatpln_class_id) == OM_S_SUCCESS)
          to_is_ref_pln = TRUE;
       else if(om$is_ancestry_valid(subclassid = classid,
                        superclassid = OPP_EMSplane_class_id) == OM_S_SUCCESS)
          to_is_pln = TRUE;

       else if(om$is_ancestry_valid(subclassid = classid,
                     superclassid = OPP_EMSpcylindr_class_id) == OM_S_SUCCESS)
          to_is_pcyl =TRUE;

       else if(om$is_ancestry_valid(subclassid = classid,
                        superclassid = OPP_EMScylindr_class_id) == OM_S_SUCCESS)
          to_is_cyl = TRUE;
 
       else if(om$is_ancestry_valid(subclassid = classid,
                  superclassid = OPP_EMSpsphere_class_id) == OM_S_SUCCESS)
          to_is_psphere = TRUE;
 
       else if(om$is_ancestry_valid(subclassid = classid,
                  superclassid = OPP_EMSsphere_class_id) == OM_S_SUCCESS)
          to_is_sphere = TRUE;

       else if(om$is_ancestry_valid(subclassid = classid,
                  superclassid = OPP_EMSpcone_class_id) == OM_S_SUCCESS)
          to_is_pcone = TRUE;
  
       else if(om$is_ancestry_valid(subclassid = classid,
                  superclassid = OPP_EMScone_class_id) == OM_S_SUCCESS)
          to_is_cone =TRUE;

       else if(om$is_ancestry_valid(subclassid = classid,
                  superclassid = OPP_EMSptorus_class_id) == OM_S_SUCCESS)
          to_is_ptau =TRUE;
 
       else if(om$is_ancestry_valid(subclassid = classid,
                  superclassid = OPP_EMStorus_class_id) == OM_S_SUCCESS)
          to_is_tau =TRUE;

   }
   else
   {
       to_is_pln = from_is_pln;
       to_is_ref_pln = from_is_ref_pln;
       to_is_cyl = from_is_cyl;
       to_is_pcyl = from_is_pcyl;
       to_is_sphere = from_is_sphere;
       to_is_psphere = from_is_sphere;
       to_is_cone = from_is_cone;
       to_is_pcone = from_is_pcone;
 
   }

   /*
    * if the from surface is ref. plane or planar surface set from_is_plane
    * TRUE. similarly for to_is_plane 
    */

   to_is_plane   = to_is_ref_pln || to_is_pln;
   from_is_plane = from_is_ref_pln || from_is_pln;

   if( from_and_to_are_same && from_is_plane && to_is_plane )
   {
      add$status( test = TRUE, msg = *msg, code = EMS_E_InvalidArg, 
          str = "EMget_projection_start_stop_pt : From and to Surfaces are sameplanes and will result in ZERO length secondary solid", 
          action = GOTO_VALUE, value = ret_end );
   }  

   /*
    get the range box  of the profile
   */

    
 
 
   ok = GetObjectRange( profile->objid, profile->osnum, modenvcv, prof_range );

   add$status( test = !ok, msg = *msg, code = EMS_E_Fail,
        str = "EMget_projection_start_stop_pt : GetObjectRange error",
        action = GOTO_VALUE, value = ret_end );
 
   /* get all the eight range box points of the profile.*/

   pwGetRngPts ((PWpoint *) &prof_range[0], rngpts);

   /* create eight infinite lines */ 

   for(i=0;i<150;i++)
   {
     inter_pt[i][0]=inter_pt[i][1]=inter_pt[i][2]=0.0;
   }

   /* cylinders,cones,spheres and taurus are handled seperate from planes
    * for the determination of the start and stop points.The eight infinite
    * lines are intersected with the infinite unbounded from and to surfaces
    * The intersection points are then projected on to a line and then 
    * sorted out to get the start and stop points.This algorithm can
    * be implemented for other type of surfaces also (provided math calls
    * are existing for them) for eg. surface of projection ,gen, surfaces.
    * As of now the old code of using range box limits of the from and to
    * surfaces to determine the start and stop points is used for such cases
    */
    
   if(from_is_cyl || from_is_pcyl || from_is_sphere || from_is_psphere ||
        from_is_cone || from_is_pcone || from_is_tau ||from_is_ptau)
   {
     for(i = 0;i < 8;i ++ )
     {
      memcpy (&inf_line[0], &rngpts[i],sizeof (IGRpoint));
      for(j=0;j<3;j++)
      {
        inf_line[1][j] = inf_line[0][j] + proj_vec[j];
      }
 
      sts = EMgetvggeom( &msg_loc, &modenvsf->md_env.matrix_type,
                    modenvsf->md_env.matrix,from_surf_id , &sf_geom , NULL );
     
      add$status( test = !(1&sts&msg_loc), msg = *msg, code = EMS_E_Fail,
      str = "EMget_projection_start_stop_pt : EMgetvggeom error",
      action = GOTO_VALUE, value = ret_end );
 
      memset(&geom_surf, NULL, sizeof(struct BSgeom_bsp_surf));
      geom_surf.bspsf = sf_geom;
      if(from_is_cyl)geom_surf.type =  BSFULL_CYL;
      else if(from_is_pcyl)geom_surf.type = BSPART_CYL;
      else if(from_is_sphere)geom_surf.type = BSSPHERE;
      else if(from_is_psphere)geom_surf.type = BSPART_SPHERE;
      else if(from_is_cone)geom_surf.type = BSFULL_CONE;
      else if(from_is_pcone)geom_surf.type = BSPART_CONE;
      else if(from_is_tau)geom_surf.type = BSTORUS;
      else if(from_is_ptau)geom_surf.type = BSPART_TORUS;
 
      geom_surf.bounded = FALSE;

      BSsftgeomsf (&geom_surf,TRUE,FALSE,&msg_loc);
 
      add$status( test = BSERROR(msg_loc), msg = *msg, code = EMS_E_BSerror,
      str = "EMget_projection_start_stop_pt : BSMATH error",
      action = GOTO_VALUE, value = ret_end );

      for(k=0;k<3;k++)
      {
       intpts[k][0]=intpts[k][1]=intpts[k][2] = 0;      
      } 
      for(k=0;k<150;k++)
      {
       uvpars[k]=0.0;
      }
     
      geom_surf.bounded = FALSE;

      if(from_is_cyl || from_is_pcyl)geom_surf.type =  BSFULL_CYL;
      else if(from_is_sphere || from_is_psphere)geom_surf.type = BSSPHERE;
      else if(from_is_cone || from_is_pcone)geom_surf.type = BSFULL_CONE;
      else if(from_is_tau || from_is_ptau)geom_surf.type = BSTORUS; 

      if(from_is_cyl || from_is_pcyl)
      BSxlngmcyl (inf_line[0],proj_vec,1,&geom_surf,intpts,NULL,&npts,
                 &rc);
    
      else if(from_is_sphere || from_is_psphere)
      BSxlngmsph (inf_line[0],proj_vec,1,&geom_surf,intpts,uvpars,&npts,
                 &rc);
    
      else if(from_is_cone || from_is_pcone)
      BSxlngmcon (inf_line[0],proj_vec,1,&geom_surf,intpts,uvpars,&npts,
                 &rc);
     
      else if(from_is_tau || from_is_ptau)
      BSxlngmtor (inf_line[0],proj_vec,1,&geom_surf,intpts,NULL,&npts,
                 &rc);

      for(j=0;j<npts;j++)
      {
       memcpy(&inter_pt[tnpts+j],intpts[j],sizeof (IGRpoint));
      }
      tnpts = tnpts + npts;
      if(i == 7 && tnpts == 0) no_int_from = TRUE; 
     }
   }
   tnpts1= tnpts;
 
   if(no_int_from || !(from_is_cyl || from_is_pcyl || from_is_sphere || 
       from_is_psphere  || from_is_cone || from_is_pcone || from_is_tau
       || from_is_ptau ))
   {
    if(!from_is_plane)
    { 
     no_int_from = TRUE; 
     ok = GetObjectRange( from_surf_id->objid, from_surf_id->osnum, modenvsf,
                           from_range );
     add$status( test = !ok, msg = *msg, code = EMS_E_Fail,
          str = "EMget_projection_start_stop_pt : GetObjectRange error",
          action = GOTO_VALUE,  value = ret_end );

     sts = BSproj0( &rc, from_range, prjvec_pts, from_min );
     add$status( test = BSERROR(rc), msg = *msg, code = EMS_E_BSerror,
          str = "EMget_projection_start_stop_pt : BSproj0 error",
          action = GOTO_VALUE,  value = ret_end );

     sts = BSproj0( &rc, &from_range[3], prjvec_pts, from_max );
     add$status( test = BSERROR(rc), msg = *msg, code = EMS_E_BSerror,
          str = "EMget_projection_start_stop_pt : BSproj0 error",
          action = GOTO_VALUE,  value = ret_end );
    }
   
    else 
 
    { 
     /*
      * determine whether "from" surface is same as the profile plane or
      * not. If so, we will transform the profile to the "from" reference
      * plane and take point on the ref. plane as the starting point.
      */
     sts = om$send( msg = message GRvg.GRdetplane( &msg_loc, &sfmat_type,
                                   sfmat, &plane_of_ref ),
                     senderid = NULL_OBJID,
                     targetid = from_surf_id->objid,
                     targetos = from_surf_id->osnum );
     add$status( test = !(1&sts&msg_loc), msg = *msg, code = EMS_E_Fail,
          str = "EMget_projection_start_stop_pt : GRdetplane error",
          action = GOTO_VALUE,  value = ret_end );

     /*
      * Intersect the projection vector with the from plane to get the start
      * point of the projection vector.
      */
     for(i = 0;i < 8;i ++ )
     {
       memcpy (&inf_line[0], &rngpts[i],sizeof (IGRpoint));
       for(j=0;j<3;j++)
       {
        inf_line[1][j] = inf_line[0][j] + proj_vec[j];
       }
       BSxlnpl( &rc, plane_of_ref.normal, plane_of_ref.point, inf_line[0],
               inf_line[1], intpts1);
       npts = 1; 
       for(j=0;j<npts;j++)
       {
        memcpy(&inter_pt[tnpts+j],intpts1,sizeof (IGRpoint));
       }
       tnpts = tnpts + npts;

     }
     tnpts1=tnpts;
     /* 
      * check whether the normals of the ref. plane of the profile and from
      * are same or not, i.e. dot product is equal to one, if they are same 
      * then we will transform the profile to the from surface and from th-
      * ere the secondary solid will be generated. 
      */ 

     dotp = BSdotp( &rc, plane_of_ref.normal, plane_of_profile.normal);
     add$status( test = BSERROR(rc), msg = *msg, code = EMS_E_BSerror,
          str = "EMget_projection_start_stop_pt : BSdotp error",
          action = GOTO_VALUE,  value = ret_end );
     dotp = (IGRdouble) fabs(dotp);

     if( (fabs(dotp - 1.0)) < lentol )
     {
       from_is_same_as_profile_plane = TRUE;
     }
    }
   }
   if(no_int_from && !from_is_plane)
   {
    if( from_and_to_are_same )
    {
      OM_BLOCK_MOVE( from_min, to_min, sizeof(IGRpoint) );
      OM_BLOCK_MOVE( from_max, to_max, sizeof(IGRpoint) );
    }
   }
    
   if(!from_and_to_are_same)
   { 
    if(!no_int_from)
    { 
     if(to_is_cyl || to_is_pcyl || to_is_sphere || to_is_psphere ||
       to_is_cone || to_is_pcone || to_is_tau || to_is_ptau)
     {

      for(i = 0;i < 8;i ++ )
      {
       memcpy (&inf_line[0], &rngpts[i],sizeof (IGRpoint));
       for(j=0;j<3;j++)
       {
        inf_line[1][j] = inf_line[0][j] + proj_vec[j];
       }
 
       sts = EMgetvggeom( &msg_loc, &modenvsf->md_env.matrix_type,
                    modenvsf->md_env.matrix,to_surf_id , &sf_geom
                    , NULL );
     
       add$status( test = !(1&sts&msg_loc), msg = *msg, code = EMS_E_Fail,
       str = "EMget_projection_start_stop_pt : EMgetvggeom error",
       action = GOTO_VALUE, value = ret_end );
  
       memset(&geom_surf, NULL, sizeof(struct BSgeom_bsp_surf));
       geom_surf.bspsf = sf_geom;
       
       if(to_is_cyl)geom_surf.type = BSFULL_CYL;
       else if(to_is_pcyl)geom_surf.type = BSPART_CYL;
       else if(to_is_sphere)geom_surf.type = BSSPHERE;
       else if(to_is_psphere)geom_surf.type = BSPART_SPHERE;
       else if(to_is_cone)geom_surf.type = BSFULL_CONE;
       else if(to_is_pcone)geom_surf.type = BSPART_CONE;
       else if(to_is_tau)geom_surf.type =BSTORUS;
       else if(to_is_ptau)geom_surf.type =BSPART_TORUS;

       geom_surf.bounded = FALSE; 
 
       BSsftgeomsf (&geom_surf,TRUE,FALSE,&msg_loc);

       for(k=0;k<3;k++)
       {
        intpts[k][0]=intpts[k][1]=intpts[k][2] = 0;
       } 
       for(k=0;k<150;k++)
       {
        uvpars[k]=0.0;
       }
       
       if(to_is_cyl|| to_is_pcyl)geom_surf.type = BSFULL_CYL;
       else if(to_is_sphere || to_is_psphere)geom_surf.type = BSSPHERE;
       else if(to_is_cone || to_is_pcone)geom_surf.type = BSFULL_CONE;
       else if(to_is_tau || to_is_ptau)geom_surf.type =BSTORUS;
 
       geom_surf.bounded = FALSE;
      
       if(to_is_cyl || to_is_pcyl)
       BSxlngmcyl (inf_line[0],proj_vec,1,&geom_surf,intpts,NULL,&npts,
                 &rc);
     
       else if(to_is_sphere || to_is_psphere)
       BSxlngmsph (inf_line[0],proj_vec,1,&geom_surf,intpts,uvpars,&npts,
                 &rc);
     
       else if(to_is_cone || to_is_pcone)
       BSxlngmcon (inf_line[0],proj_vec,1,&geom_surf,intpts,uvpars,&npts,
                 &rc);
       
       else if(to_is_tau || to_is_ptau)
       BSxlngmtor (inf_line[0],proj_vec,1,&geom_surf,intpts,NULL,&npts,
                 &rc);

       for(j=0;j<npts;j++)
       {
         memcpy(&inter_pt[tnpts+j],intpts[j],sizeof (IGRpoint));
       }
       tnpts = tnpts + npts;
       if(i==7 && tnpts == tnpts1)no_int_to = TRUE;
      }
     }
    }
    if(no_int_from || no_int_to || (no_int_from && no_int_to) ||
       !(to_is_cyl || to_is_pcyl || to_is_cone || to_is_pcone ||
         to_is_sphere || to_is_psphere || to_is_tau || to_is_ptau) ) 
    {
     if(!to_is_plane)
     {
      no_int_to= TRUE;
      
      ok = GetObjectRange( to_surf_id->objid, to_surf_id->osnum, modenvsf, 
                      to_range );
      add$status( test = !ok, msg = *msg, code = EMS_E_Fail,
          str = "EMget_projection_start_stop_pt : GetObjectRange error",
          action = GOTO_VALUE,  value = ret_end );

      sts = BSproj0( &rc, to_range, prjvec_pts, to_min );
      add$status( test = BSERROR(rc), msg = *msg, code = EMS_E_BSerror,
          str = "EMget_projection_start_stop_pt : BSproj0 error",
          action = GOTO_VALUE,  value = ret_end );

      sts = BSproj0( &rc, &to_range[3], prjvec_pts, to_max );
      add$status( test = BSERROR(rc), msg = *msg, code = EMS_E_BSerror,
          str = "EMget_projection_start_stop_pt : BSproj0 error",
          action = GOTO_VALUE,  value = ret_end );
      }
      if(no_int_from && to_is_plane)
      { 
       no_int_to = TRUE;
       /*
       * determine whether the to surface is same as the profile plane or
       * not. If so, we will transform the profile to the "to" reference
       * plane and take point on the ref. plane as the starting point.
       */
       sts = om$send( msg = message GRvg.GRdetplane( &msg_loc, &sfmat_type,
                                   sfmat, &plane_of_ref ),
                     senderid = NULL_OBJID,
                     targetid = to_surf_id->objid,
                     targetos = to_surf_id->osnum );
       add$status( test = !(1&sts&msg_loc), msg = *msg, code = EMS_E_Fail,
          str = "EMget_projection_start_stop_pt : GRdetplane error",
          action = GOTO_VALUE,  value = ret_end );
 
       /*
       * Intersect the projection vector with the to plane to get the stop
       * point of the projection vector.
       */
 
       BSxlnpl( &rc, plane_of_ref.normal, plane_of_ref.point, prjvec_pts[0],
               prjvec_pts[1], to_ref_pt );
       add$status( test = BSERROR(rc), msg = *msg,
          code = EMS_E_AddRmNoIntToSurf,
          str = "EMget_projection_start_stop_pt : BSxlnpl error",
          action = GOTO_VALUE,  value = ret_end );
 
       /*
        * check whether the normals of the ref. plane of the profile and "to"
        * are same or not, i.e. dot product is equal to one, if they are same
        * then we will transform the profile to the "to" surface and from th-
        * ere the secondary solid will be generated.
        */
 
       dotp = fabs(BSdotp( &rc, plane_of_ref.normal,
                               plane_of_profile.normal));
       add$status( test = BSERROR(rc), msg = *msg, code = EMS_E_BSerror,
          str = "EMget_projection_start_stop_pt : BSdotp error",
          action = GOTO_VALUE,  value = ret_end );
 
       if( (fabs(dotp - 1.0)) < lentol )
       {
         to_is_same_as_profile_plane = TRUE;
       }

      } 
      if(!no_int_from && no_int_to)
      {
       if(!from_is_plane)
       {
        no_int_from = TRUE;
        ok = GetObjectRange( from_surf_id->objid, from_surf_id->osnum, modenvsf,
                           from_range );
        add$status( test = !ok, msg = *msg, code = EMS_E_Fail,
          str = "EMget_projection_start_stop_pt : GetObjectRange error",
          action = GOTO_VALUE,  value = ret_end );
 
        sts = BSproj0( &rc, from_range, prjvec_pts, from_min );
        add$status( test = BSERROR(rc), msg = *msg, code = EMS_E_BSerror,
          str = "EMget_projection_start_stop_pt : BSproj0 error",
          action = GOTO_VALUE,  value = ret_end );
 
        sts = BSproj0( &rc, &from_range[3], prjvec_pts, from_max );
        add$status( test = BSERROR(rc), msg = *msg, code = EMS_E_BSerror,
          str = "EMget_projection_start_stop_pt : BSproj0 error",
          action = GOTO_VALUE,  value = ret_end );
       }
       else
       {
        sts = om$send( msg = message GRvg.GRdetplane( &msg_loc, &sfmat_type,
                                   sfmat, &plane_of_ref ),
                     senderid = NULL_OBJID,
                     targetid = from_surf_id->objid,
                     targetos = from_surf_id->osnum );
        add$status( test = !(1&sts&msg_loc), msg = *msg, code = EMS_E_Fail,
          str = "EMget_projection_start_stop_pt : GRdetplane error",
          action = GOTO_VALUE,  value = ret_end );
 
        /*
         * Intersect the projection vector with the from plane to get the start
         * point of the projection vector.
         */
 
        BSxlnpl( &rc, plane_of_ref.normal, plane_of_ref.point, prjvec_pts[0],
               prjvec_pts[1], from_ref_pt );
        add$status( test = BSERROR(rc), msg = *msg,
          code = EMS_E_AddRmNoIntFromSurf,
          str = "EMget_projection_start_stop_pt : BSxlnpl error",
          action = GOTO_VALUE,  value = ret_end );
 
        /*
         * check whether the normals of the ref. plane of the profile and from
         * are same or not, i.e. dot product is equal to one, if they are same
         * then we will transform the profile to the from surface and from th-
         * ere the secondary solid will be generated.
         */
 
        dotp = BSdotp( &rc, plane_of_ref.normal, plane_of_profile.normal);
        add$status( test = BSERROR(rc), msg = *msg, code = EMS_E_BSerror,
          str = "EMget_projection_start_stop_pt : BSdotp error",
          action = GOTO_VALUE,  value = ret_end );
        dotp = (IGRdouble) fabs(dotp);
 
        if( (fabs(dotp - 1.0)) < lentol )
        {
         from_is_same_as_profile_plane = TRUE;
        }
   

       } 
      } 
     } 
     if(to_is_plane && !no_int_from) 
     {
      /* 
       * determine whether the to surface is same as the profile plane or
       * not. If so, we will transform the profile to the "to" reference 
       * plane and take point on the ref. plane as the starting point.
       */
      sts = om$send( msg = message GRvg.GRdetplane( &msg_loc, &sfmat_type,
                                   sfmat, &plane_of_ref ),
                     senderid = NULL_OBJID,
                     targetid = to_surf_id->objid,
                     targetos = to_surf_id->osnum );
      add$status( test = !(1&sts&msg_loc), msg = *msg, code = EMS_E_Fail,
          str = "EMget_projection_start_stop_pt : GRdetplane error",
          action = GOTO_VALUE,  value = ret_end );

      /*
       * Intersect the projection vector with the to plane to get the stop
       * point of the projection vector.
       */
       for(i = 0;i < 8;i ++ )
       {
        memcpy (&inf_line[0], &rngpts[i],sizeof (IGRpoint));
        for(j=0;j<3;j++)
        {
         inf_line[1][j] = inf_line[0][j] + proj_vec[j];
        }
        BSxlnpl( &rc, plane_of_ref.normal, plane_of_ref.point, inf_line[0],
               inf_line[1], intpts1 );

        npts = 1;
      
        for(j=0;j<npts;j++)
        {
         memcpy(&inter_pt[tnpts+j],intpts1,sizeof (IGRpoint));
        }
        tnpts = tnpts + npts;
 
       }
      
       /*
        * check whether the normals of the ref. plane of the profile and "to" 
        * are same or not, i.e. dot product is equal to one, if they are same
        * then we will transform the profile to the "to" surface and from th-
        * ere the secondary solid will be generated.
        */

       dotp = fabs(BSdotp( &rc, plane_of_ref.normal, 
                               plane_of_profile.normal));
       add$status( test = BSERROR(rc), msg = *msg, code = EMS_E_BSerror,
          str = "EMget_projection_start_stop_pt : BSdotp error",
          action = GOTO_VALUE,  value = ret_end );

       if( (fabs(dotp - 1.0)) < lentol )
       {
         to_is_same_as_profile_plane = TRUE;
       }
     }
   }
   if(!no_int_from && !no_int_to  ) 
   {
    for (i=0; i<tnpts; i++)
    {
      BSproj0 (&rc, inter_pt[i], prjvec_pts, projpts1[i]);
      add$status( test = BSERROR (rc), msg = *msg, code = EMS_E_BSerror,
        str = "EMget_projection_start_stop_pt : BSproj0 error",
        action = GOTO_VALUE,  value = ret_end );
    } 
    ok = GetObjectRange( from_surf_id->objid, from_surf_id->osnum, modenvsf,
                           from_range );
    add$status( test = !ok, msg = *msg, code = EMS_E_Fail,
          str = "EMget_projection_start_stop_pt : GetObjectRange error",
          action = GOTO_VALUE,  value = ret_end );
    sts = BSproj0( &rc,from_range, prjvec_pts,projpts1[tnpts]  );
    add$status( test = BSERROR(rc), msg = *msg, code = EMS_E_BSerror,
          str = "EMget_projection_start_stop_pt : BSproj0 error",
          action = GOTO_VALUE,  value = ret_end );
       
    sts = BSproj0( &rc, &from_range[3], prjvec_pts, projpts1[tnpts+1] );
    add$status( test = BSERROR(rc), msg = *msg, code = EMS_E_BSerror,
          str = "EMget_projection_start_stop_pt : BSproj0 error",
          action = GOTO_VALUE,  value = ret_end ); 
      
    ok = GetObjectRange( to_surf_id->objid, to_surf_id->osnum, modenvsf,
                      to_range );
    add$status( test = !ok, msg = *msg, code = EMS_E_Fail,
          str = "EMget_projection_start_stop_pt : GetObjectRange error",
          action = GOTO_VALUE,  value = ret_end );
 
    sts = BSproj0( &rc,to_range, prjvec_pts, projpts1[tnpts+2] );
    add$status( test = BSERROR(rc), msg = *msg, code = EMS_E_BSerror,
          str = "EMget_projection_start_stop_pt : BSproj0 error",
          action = GOTO_VALUE,  value = ret_end );
    sts = BSproj0( &rc, &to_range[3], prjvec_pts, projpts1[tnpts+3] );
    add$status( test = BSERROR(rc), msg = *msg, code = EMS_E_BSerror,
          str = "EMget_projection_start_stop_pt : BSproj0 error",
          action = GOTO_VALUE,  value = ret_end );
    sts = pwMinMaxPtsAlongVec (tnpts+4, projpts1, proj_vec, maxpt, minpt);
    OM_BLOCK_MOVE(minpt, the_start_point, sizeof(IGRpoint));
    OM_BLOCK_MOVE(maxpt, the_stop_point, sizeof(IGRpoint));

    /*** to take of profiles which have thier parameter 0.5 not in the ****
    **** region of the from and to surfaces                            ****/
     
    sts = EMgetvggeom( &msg_loc, &modenvcv->md_env.matrix_type,
                    modenvcv->md_env.matrix, profile, &prof_geom, NULL );

    add$status( test = !(1&sts&msg_loc), msg = *msg, code = EMS_E_Fail,
     str = "EMget_projection_start_stop_pt : EMgetvggeom error",
     action = GOTO_VALUE, value = ret_end );
 
 
 
    for(param = 0.5 ; param <=1.50; param = param +0.25 )
    {
     parameter = param;
     if(param == 1.25)parameter = 0.0;
     else if(param == 1.50)parameter = 0.25;
 
     BScveval( prof_geom, parameter, (IGRint) 0, &begin_prjvec, &msg_loc );
   
     add$status( test = BSERROR(msg_loc), msg = *msg, code = EMS_E_BSerror,
              str = "EMget_projection_start_stop_pt : BScveval error",
              action = GOTO_VALUE, value = ret_end );
 
 
     for(i=0; i<3; i++)
     {
      prjvec_pts[0][i] = begin_prjvec[i];
      prjvec_pts[1][i] = prjvec_pts[0][i] + proj_vec[i];
     }
    
     if(from_is_plane && to_is_plane)
     {
      sts = om$send( msg = message GRvg.GRdetplane( &msg_loc, &sfmat_type,
                                   sfmat, &plane_of_ref ),
                     senderid = NULL_OBJID,
                     targetid = from_surf_id->objid,
                     targetos = from_surf_id->osnum );
 
      add$status( test = !(1&sts&msg_loc), msg = *msg, code = EMS_E_Fail,
          str = "EMget_projection_start_stop_pt : GRdetplane error",
          action = GOTO_VALUE,  value = ret_end );
 
      BSxlnpl( &rc, plane_of_ref.normal, plane_of_ref.point, prjvec_pts[0],
               prjvec_pts[1], from_ref_pt );
      if(param == 0.5)memcpy(from_ref_pt1,from_ref_pt,sizeof(IGRpoint));

      add$status( test = BSERROR(rc), msg = *msg,
          code = EMS_E_AddRmNoIntFromSurf,
          str = "EMget_projection_start_stop_pt : BSxlnpl error",
          action = GOTO_VALUE,  value = ret_end );
    
      if(!from_is_ref_pln)
      { 
       sfgeomid.id.objid =from_surf_id->objid;
       sfgeomid.id.osnum = os;
       sfgeomid.mattyp = cvmat_type;
       memcpy(sfgeomid.mat,modenvcv->md_env.matrix,sizeof(PWmatrix));
 
       for(i=0; i<3; i++)
       {
        xyzpt[i]=from_ref_pt[i];
       }
       BSEXTRACTPAR(&BSmsg, BSTOLCHRDHT, chttol);
       sts = pwSfPtLocate(&sfgeomid,xyzpt,NULL,chttol,&fr_p_ptloc,&p_bdryid,&p_edpt);
      }
      sts = om$send( msg = message GRvg.GRdetplane( &msg_loc, &sfmat_type,
                                   sfmat, &plane_of_ref ),
                     senderid = NULL_OBJID,
                     targetid = to_surf_id->objid,
                     targetos = to_surf_id->osnum );
 
      add$status( test = !(1&sts&msg_loc), msg = *msg, code = EMS_E_Fail,
          str = "EMget_projection_start_stop_pt : GRdetplane error",
          action = GOTO_VALUE,  value = ret_end );
 
      BSxlnpl( &rc, plane_of_ref.normal, plane_of_ref.point, prjvec_pts[0],
               prjvec_pts[1], to_ref_pt );
      if(param == 0.5)memcpy(to_ref_pt1,to_ref_pt,sizeof(IGRpoint));
      add$status( test = BSERROR(rc), msg = *msg,
          code = EMS_E_AddRmNoIntFromSurf,
          str = "EMget_projection_start_stop_pt : BSxlnpl error",
          action = GOTO_VALUE,  value = ret_end );

      if(!to_is_ref_pln)
      { 
       sfgeomid.id.objid =to_surf_id->objid;
       sfgeomid.id.osnum = os;
       sfgeomid.mattyp = cvmat_type;
       memcpy(sfgeomid.mat,modenvcv->md_env.matrix,sizeof(PWmatrix));
 
       for(i=0; i<3; i++)
       {
        xyzpt[i]=to_ref_pt[i];
       }
       BSEXTRACTPAR(&BSmsg, BSTOLCHRDHT, chttol);
       sts = pwSfPtLocate(&sfgeomid,xyzpt,NULL,chttol,&to_p_ptloc,&p_bdryid,&p_edpt);
      } 
      if(to_p_ptloc || fr_p_ptloc || ( to_p_ptloc && fr_p_ptloc))
      {
       for(k=0;k<3;k++)
       {
        midpt[k] = (from_ref_pt[k] + to_ref_pt[k])/2;
       }
       OM_BLOCK_MOVE(midpt,the_mid_point,sizeof(IGRpoint));
       break; 
      }
      if(param == 1.5 && (!to_p_ptloc && !fr_p_ptloc))
      {
       for(k=0;k<3;k++)
       {
        midpt[k] = (from_ref_pt1[k] + to_ref_pt1[k])/2;
       }
       OM_BLOCK_MOVE(midpt,the_mid_point,sizeof(IGRpoint));
      }
     }
     else
     {
      if(from_is_plane)
      {
       sts = om$send( msg = message GRvg.GRdetplane( &msg_loc, &sfmat_type,
                                   sfmat, &plane_of_ref ),
                     senderid = NULL_OBJID,
                     targetid = from_surf_id->objid,
                     targetos = from_surf_id->osnum );
 
       add$status( test = !(1&sts&msg_loc), msg = *msg, code = EMS_E_Fail,
          str = "EMget_projection_start_stop_pt : GRdetplane error",
          action = GOTO_VALUE,  value = ret_end );
 
       BSxlnpl( &rc, plane_of_ref.normal, plane_of_ref.point, prjvec_pts[0],
               prjvec_pts[1], from_ref_pt );
 
       add$status( test = BSERROR(rc), msg = *msg,
          code = EMS_E_AddRmNoIntFromSurf,
          str = "EMget_projection_start_stop_pt : BSxlnpl error",
          action = GOTO_VALUE,  value = ret_end );

       if(!from_is_ref_pln) 
       {
        sfgeomid.id.objid =from_surf_id->objid;
        sfgeomid.id.osnum = os;
        sfgeomid.mattyp = cvmat_type;
        memcpy(sfgeomid.mat,modenvcv->md_env.matrix,sizeof(PWmatrix));
 
        for(i=0; i<3; i++)
        {
         xyzpt[i]=from_ref_pt[i];
        }
        BSEXTRACTPAR(&BSmsg, BSTOLCHRDHT, chttol);
        sts = pwSfPtLocate(&sfgeomid,xyzpt,NULL,chttol,&fr_p_ptloc,&p_bdryid,&p_edpt);
       } 
 
      }
      else
      { 
       sts = EMgetvggeom( &msg_loc, &modenvsf->md_env.matrix_type,
                    modenvsf->md_env.matrix,from_surf_id , &sf_geom , NULL );
       add$status( test = !(1&sts&msg_loc), msg = *msg, code = EMS_E_Fail,
            str = "EMget_projection_start_stop_pt : EMgetvggeom error",
            action = GOTO_VALUE, value = ret_end );
 

 
       memset(&geom_surf, NULL, sizeof(struct BSgeom_bsp_surf));
       geom_surf.bspsf = sf_geom;

       if(from_is_cyl)geom_surf.type = BSFULL_CYL;
       else if(from_is_pcyl)geom_surf.type = BSPART_CYL;
       else if(from_is_sphere)geom_surf.type = BSSPHERE;
       else if(from_is_psphere)geom_surf.type = BSPART_SPHERE;
       else if(from_is_cone)geom_surf.type = BSFULL_CONE;
       else if(from_is_pcone)geom_surf.type = BSPART_CONE;
       else if(from_is_tau)geom_surf.type = BSTORUS;
       else if(from_is_ptau)geom_surf.type = BSPART_TORUS;
 
       geom_surf.bounded = FALSE;
       BSsftgeomsf (&geom_surf,TRUE,FALSE,&msg_loc);
 
       add$status( test = BSERROR(msg_loc), msg = *msg, code = EMS_E_BSerror,
             str = "EMget_projection_start_stop_pt : BSMATH error",
             action = GOTO_VALUE, value = ret_end );
       for(k=0;k<3;k++)
       {
        intpts[k][0]=intpts[k][1]=intpts[k][2] = 0;
       } 
       for(k=0;k<150;k++)
       {
        uvpars[k]=0.0;
       }

 
       if(from_is_cyl || from_is_pcyl)geom_surf.type = BSFULL_CYL;
       else if(from_is_sphere || from_is_psphere )geom_surf.type = BSSPHERE;
       else if(from_is_cone || from_is_pcone )geom_surf.type = BSFULL_CONE;
       else if(from_is_tau || from_is_ptau )geom_surf.type = BSTORUS;
 
       geom_surf.bounded = FALSE;

       if(from_is_cyl || from_is_pcyl)
       BSxlngmcyl (prjvec_pts[0],proj_vec,1,&geom_surf,intpts,NULL,&npts,
                 &rc);

       else if(from_is_sphere || from_is_psphere)
       BSxlngmsph (prjvec_pts[0],proj_vec,1,&geom_surf,intpts,uvpars,&npts,
                 &rc);

       else if(from_is_cone || from_is_pcone)
       BSxlngmcon (prjvec_pts[0],proj_vec,1,&geom_surf,intpts,uvpars,&npts,
                 &rc);
 
       else if(from_is_tau || from_is_ptau)
       BSxlngmtor (prjvec_pts[0],proj_vec,1,&geom_surf,intpts,NULL,&npts,
                 &rc);
 
 
 
       sfgeomid.id.objid =from_surf_id->objid;
       sfgeomid.id.osnum = os;
       sfgeomid.mattyp = cvmat_type;
       memcpy(sfgeomid.mat,modenvcv->md_env.matrix,sizeof(PWmatrix));
       BSEXTRACTPAR(&BSmsg, BSTOLCHRDHT, chttol); 
       for(k=0;k<npts;k++)
       {
        memcpy(xyzpt,intpts[k],sizeof(IGRpoint));
        sts = pwSfPtLocate(&sfgeomid,xyzpt,NULL,chttol,&fr_p_ptloc,&p_bdryid,&p_edpt);
        if(fr_p_ptloc)break;
       }
      }
      if(to_is_plane)
      {
       sts = om$send( msg = message GRvg.GRdetplane( &msg_loc, &sfmat_type,
                                   sfmat, &plane_of_ref ),
                     senderid = NULL_OBJID,
                     targetid = to_surf_id->objid,
                     targetos = to_surf_id->osnum );
 
       add$status( test = !(1&sts&msg_loc), msg = *msg, code = EMS_E_Fail,
          str = "EMget_projection_start_stop_pt : GRdetplane error",
          action = GOTO_VALUE,  value = ret_end );
 
       BSxlnpl( &rc, plane_of_ref.normal, plane_of_ref.point, prjvec_pts[0],
               prjvec_pts[1], to_ref_pt );
       if(param == 0.5)memcpy(to_ref_pt1,to_ref_pt,sizeof(IGRpoint));
       add$status( test = BSERROR(rc), msg = *msg,
          code = EMS_E_AddRmNoIntFromSurf,
          str = "EMget_projection_start_stop_pt : BSxlnpl error",
          action = GOTO_VALUE,  value = ret_end );
       if(!to_is_ref_pln)
       { 
        sfgeomid.id.objid =to_surf_id->objid;
        sfgeomid.id.osnum = os;
        sfgeomid.mattyp = cvmat_type;
        memcpy(sfgeomid.mat,modenvcv->md_env.matrix,sizeof(PWmatrix));
 
        for(i=0; i<3; i++)
        {
         xyzpt[i]=to_ref_pt[i];
        }
        BSEXTRACTPAR(&BSmsg, BSTOLCHRDHT, chttol);
        sts = pwSfPtLocate(&sfgeomid,xyzpt,NULL,chttol,&to_p_ptloc,&p_bdryid,&p_edpt);
       } 
      }
      else
      {
       sts = EMgetvggeom( &msg_loc, &modenvsf->md_env.matrix_type,
                    modenvsf->md_env.matrix,to_surf_id , &sf_geom
                    , NULL );
       add$status( test = !(1&sts&msg_loc), msg = *msg, code = EMS_E_Fail,
                str = "EMget_projection_start_stop_pt : EMgetvggeom error",
                action = GOTO_VALUE, value = ret_end );
 
       memset(&geom_surf, NULL, sizeof(struct BSgeom_bsp_surf));
       geom_surf.bspsf = sf_geom;
       if(to_is_cyl)geom_surf.type = BSFULL_CYL;
       else if(to_is_pcyl)geom_surf.type = BSPART_CYL;
       else if(to_is_sphere)geom_surf.type = BSSPHERE;
       else if(to_is_psphere)geom_surf.type = BSPART_SPHERE;
       else if(to_is_cone)geom_surf.type = BSFULL_CONE;
       else if(to_is_pcone)geom_surf.type = BSPART_CONE;
       else if(to_is_tau)geom_surf.type = BSTORUS;
       else if(to_is_ptau)geom_surf.type = BSPART_TORUS;
 

       for(k=0;k<3;k++)
       {
        intpts[k][0]=intpts[k][1]=intpts[k][2] = 0;
       }
       for(k=0;k<150;k++)
       {
        uvpars[k]=0.0;
       }

       geom_surf.bounded = FALSE; 
       BSsftgeomsf (&geom_surf,TRUE,FALSE,&msg_loc);

       if(to_is_cyl|| to_is_pcyl)geom_surf.type = BSFULL_CYL;
       else if(to_is_sphere || from_is_psphere )geom_surf.type = BSSPHERE;
       else if(to_is_cone || from_is_pcone )geom_surf.type = BSFULL_CONE;
       else if(from_is_tau || from_is_ptau)geom_surf.type = BSTORUS;
 
       geom_surf.bounded = FALSE;
     
       if(to_is_cyl || to_is_pcyl)
       BSxlngmcyl (prjvec_pts[0],proj_vec,1,&geom_surf,intpts,NULL,&npts,
                 &rc);
     
       else if(to_is_sphere || to_is_psphere)
       BSxlngmsph (prjvec_pts[0],proj_vec,1,&geom_surf,intpts,uvpars,&npts,
                 &rc);

       else if(to_is_cone || to_is_pcone)
       BSxlngmcon (prjvec_pts[0],proj_vec,1,&geom_surf,intpts,uvpars,&npts,
                 &rc);
       else if(to_is_tau || to_is_ptau)
       BSxlngmtor (prjvec_pts[0],proj_vec,1,&geom_surf,intpts,NULL,&npts,
                 &rc);
     
 
   
       sfgeomid.id.objid =to_surf_id->objid;
       sfgeomid.id.osnum = os;
       sfgeomid.mattyp = cvmat_type;
       memcpy(sfgeomid.mat,modenvcv->md_env.matrix,sizeof(PWmatrix));
       BSEXTRACTPAR(&BSmsg, BSTOLCHRDHT, chttol);
       for(k=0;k<npts;k++)
       {
        memcpy(xyzpt,intpts[k],sizeof(IGRpoint));
        sts = pwSfPtLocate(&sfgeomid,xyzpt,NULL,chttol,&to_p_ptloc,&p_bdryid,&p_edpt);
        if(to_p_ptloc)break;
       }
      } 
      if(fr_p_ptloc || to_p_ptloc || (fr_p_ptloc && to_p_ptloc))
      {
       OM_BLOCK_MOVE(begin_prjvec,the_mid_point,sizeof(IGRpoint));
       break;
      }
      if(param == 1.5)
      {
       BScveval( prof_geom,0.5,(IGRint) 0, &begin_prjvec, &msg_loc );
 
       add$status( test = BSERROR(msg_loc), msg = *msg, code = EMS_E_BSerror,
                     str = "EMget_projection_start_stop_pt : BScveval error",
                     action = GOTO_VALUE, value = ret_end );
 
      
       OM_BLOCK_MOVE(begin_prjvec,the_mid_point,sizeof(IGRpoint));
      }
     }
    }
    om$dealloc( ptr = prof_geom ); prof_geom = NULL;
   } 
   else
   { 
    /*
     * Both from to surfaces are not reference planes
     */
    if(!from_is_plane && !to_is_plane) 
    {
      if( from_and_to_are_same )
      {
          dist = BSdistptpt( &rc, from_min, from_max );
      }
      else
      {
          dist1 = BSdistptpt( &rc, from_min, to_min );
          dist2 = BSdistptpt( &rc, from_min, to_max );
          dist3 = BSdistptpt( &rc, from_max, to_min );
          dist4 = BSdistptpt( &rc, from_max, to_max );
    
          num_values = 4;
          values[0] = dist1; values[1] = dist2; 
          values[2] = dist3; values[3] = dist4;
    
          sts = BStagsort(&rc, &num_values, values, sort_ind );
          add$status( test = BSERROR(rc), msg = *msg, code = EMS_E_BSerror,
              str = "EMget_projection_start_stop_pt : BSmkvec error",
              action = GOTO_VALUE, value = ret_end );
    
          dist = values[sort_ind[3]];
      }

      if( from_and_to_are_same )
      {
         OM_BLOCK_MOVE( from_min, from_ref_pt, sizeof(IGRpoint) );
         OM_BLOCK_MOVE( from_max, to_ref_pt, sizeof(IGRpoint) );
      }
      else if( BSbxint( &rc, from_min, from_max, to_min, to_max) )
      {
         sts = BSmkvec( &rc, vec0, from_min, to_min );
         add$status( test = BSERROR(rc), msg = *msg, code = EMS_E_BSerror,
             str = "EMget_projection_start_stop_pt : BSmkvec error",
             action = GOTO_VALUE, value = ret_end);

         BSnorvec( &rc, vec0 );
  
         sts = BSmkvec( &rc, vec1, from_min, to_max );
         add$status( test = BSERROR(rc), msg = *msg, code = EMS_E_BSerror,
             str = "EMget_projection_start_stop_pt : BSmkvec error",
             action = GOTO_VALUE, value = ret_end);

         BSnorvec( &rc, vec1 );
  
         sts = BSmkvec( &rc, vec2, from_max, to_min );
         add$status( test = BSERROR(rc), msg = *msg, code = EMS_E_BSerror,
             str = "EMget_projection_start_stop_pt : BSmkvec error",
             action = GOTO_VALUE, value = ret_end);
  
         BSnorvec( &rc, vec2 );

         sts = BSmkvec( &rc, vec3, from_max, to_max );
         add$status( test = BSERROR(rc), msg = *msg, code = EMS_E_BSerror,
             str = "EMget_projection_start_stop_pt : BSmkvec error",
             action = GOTO_VALUE, value = ret_end);
  
         BSnorvec( &rc, vec3 );

         values[0] = BSdotp( &rc, proj_vec, vec0 );
         values[1] = BSdotp( &rc, proj_vec, vec1 );
         values[2] = BSdotp( &rc, proj_vec, vec2 );
         values[3] = BSdotp( &rc, proj_vec, vec3 );

         num_values = 4;
         sts = BStagsort(&rc, &num_values, values, sort_ind );
         add$status( test = BSERROR(rc), msg = *msg, code = EMS_E_BSerror,
             str = "EMget_projection_start_stop_pt : BSmkvec error",
             action = GOTO_VALUE, value = ret_end);

         if( values[sort_ind[1]] > 0.0 )
            index = sort_ind[1];
         else
            index = sort_ind[0];

         if( index == 1 )
         {
            OM_BLOCK_MOVE( from_min, from_ref_pt, sizeof(IGRpoint) );
            OM_BLOCK_MOVE( to_min, to_ref_pt, sizeof(IGRpoint) );
         }
         else if( index == 2 )
         {
            OM_BLOCK_MOVE( from_min, from_ref_pt, sizeof(IGRpoint) );
            OM_BLOCK_MOVE( to_max, to_ref_pt, sizeof(IGRpoint) );
         }
         else if( index == 2 )
         {
            OM_BLOCK_MOVE( from_max, from_ref_pt, sizeof(IGRpoint) );
            OM_BLOCK_MOVE( to_min, to_ref_pt, sizeof(IGRpoint) );
         }
         else
         {
            OM_BLOCK_MOVE( from_max, from_ref_pt, sizeof(IGRpoint) );
            OM_BLOCK_MOVE( to_max, to_ref_pt, sizeof(IGRpoint) );
         }
      }
      else if( dist1 <= dist2 && dist1 <= dist3 && dist1 <= dist4 )
      {
         OM_BLOCK_MOVE( from_min, from_ref_pt, sizeof(IGRpoint) );
         OM_BLOCK_MOVE( to_min, to_ref_pt, sizeof(IGRpoint) );
      }
      else if( dist2 <= dist1 && dist2 <= dist3 && dist2 <= dist4 )
      {
         OM_BLOCK_MOVE( from_min, from_ref_pt, sizeof(IGRpoint) );
         OM_BLOCK_MOVE( to_max, to_ref_pt, sizeof(IGRpoint) );
      }
      else if( dist3 <= dist1 && dist3 <= dist2 && dist3 <= dist4 )
      {
         OM_BLOCK_MOVE( from_max, from_ref_pt, sizeof(IGRpoint) );
         OM_BLOCK_MOVE( to_min, to_ref_pt, sizeof(IGRpoint) );
      }
      else 
      {
         OM_BLOCK_MOVE( from_max, from_ref_pt, sizeof(IGRpoint) );
         OM_BLOCK_MOVE( to_max, to_ref_pt, sizeof(IGRpoint) );
      }
      
      /* 
      for(i=0; i<3; i++)
         the_mid_point[i] = (from_ref_pt[i] + to_ref_pt[i]) / 2.0;
      */

      OM_BLOCK_MOVE (begin_prjvec, the_mid_point, sizeof (IGRpoint));

      dist_comp = 0.9 * (BSdistptpt( &rc, from_ref_pt, to_ref_pt )+ dist);

      for(i=0; i<3; i++)
      {
          the_start_point[i] = from_ref_pt[i] - dist/2.0 * proj_vec[i];
          the_stop_point[i] = to_ref_pt[i] + dist/2.0 * proj_vec[i];
      }

      if( (BSdistptpt( &rc, the_start_point, the_stop_point)) < dist_comp )
      {
          for(i=0; i<3; i++)
          {
              the_start_point[i] = from_ref_pt[i] + dist/2.0 * proj_vec[i];
              the_stop_point[i] = to_ref_pt[i] - dist/2.0 * proj_vec[i];
          }
      }
   }
   
   else if(from_is_plane && !to_is_plane) /* from ref. pln to surface */
   {
      /*
       * Two possible cases occur here :
       *     a) 'From plane' is out side the range box limits of the 
       *        'TO Surface' 
       *     b) 'From plane is with in the range box limits of the 
       *        'TO Surface'
       * Save side point generation :
       *     In case of a)
       *        The minimum distance point from the 'From plane' is taken as
       *        taken as the 'to reference point' and the middle point of the
       *        'from_ref_pt and to_ref_pt' is taken as the save side point.
       *     In case of b)
       *        The point which is in the direction of projection direction is
       *        taken as the 'to reference point' and the middle point of the 
       *        'from_ref_pt and to_ref_pt' is taken as the save side point.
       */ 
      dist1 = BSdistptpt( &rc, from_ref_pt, to_min ); 
      dist2 = BSdistptpt( &rc, from_ref_pt, to_max ); 

      sts = BSmkvec( &rc, vec0, from_ref_pt, to_min );
      add$status( test = BSERROR(rc), msg = *msg, code = EMS_E_BSerror,
          str = "EMget_projection_start_stop_pt : BSmkvec error",
          action = GOTO_VALUE, value = ret_end );
      BSnorvec( &rc, vec0 );
 
      sts = BSmkvec( &rc, vec1, from_ref_pt, to_max );
      add$status( test = BSERROR(rc), msg = *msg, code = EMS_E_BSerror,
          str = "EMget_projection_start_stop_pt : BSmkvec error",
          action = GOTO_VALUE, value = ret_end );

      BSnorvec( &rc, vec1 );
     
      value1 = BSdotp( &rc, proj_vec, vec0 ); 
      add$status( test = BSERROR(rc), msg = *msg, code = EMS_E_BSerror,
          str = "EMget_projection_start_stop_pt : BSdotp error",
          action = GOTO_VALUE, value = ret_end );

      value2 = BSdotp( &rc, proj_vec, vec1 ); 
      add$status( test = BSERROR(rc), msg = *msg, code = EMS_E_BSerror,
          str = "EMget_projection_start_stop_pt : BSdotp error",
          action = GOTO_VALUE, value = ret_end );

      /*
       * "FROM Plane" is with in the range box limits of the "TO Surface"
       */
      if( (value1 < 0.0 && value2 > 0.0) || (value1 > 0.0 && value2 < 0.0) )
      {
         if( value1 > 0.0 )
         {
            OM_BLOCK_MOVE( to_min, to_ref_pt, sizeof(IGRpoint) );  
         }
         else
         {
            OM_BLOCK_MOVE( to_max, to_ref_pt, sizeof(IGRpoint) );  
         }

         dist = dist1 + dist2;
      }
      /*
       * "FROM Plane is out side the range box limits of the "TO Surface"
       */
      else
      {
         if( dist1 < dist2 )
         {
            OM_BLOCK_MOVE( to_min, to_ref_pt, sizeof(IGRpoint) );
            dist = dist2;
         }
         else
         {
            OM_BLOCK_MOVE( to_max, to_ref_pt, sizeof(IGRpoint) );
            dist = dist1;
         }
      }

      /*
       * calculate the save side point
       */
      /*
      for(i=0; i<3; i++)
          the_mid_point[i] = (from_ref_pt[i] + to_ref_pt[i]) / 2.0;
      */

      OM_BLOCK_MOVE (begin_prjvec, the_mid_point, sizeof (IGRpoint));

      dist_comp = 0.9 * ( BSdistptpt(&rc, from_ref_pt, to_ref_pt) + dist );

      /*
       * calculate the start and stop points : 
       *    If the 'FROM Plane' is same as the profile plane then take the
       *    'from_ref_pt' as the starting point otherwise starting point is
       *    taken as the point away from the 'from_ref_pt by half of the 
       *    'dist'. 
       *    Stop point is is taken as the point away from the 'to_ref_pt' by 
       *    half of the 'dist'.  
       */
      if( from_is_same_as_profile_plane )
      {
         OM_BLOCK_MOVE( from_ref_pt, the_start_point, sizeof(IGRpoint) );
         for(i=0; i<3; i++)
             the_stop_point[i] = to_ref_pt[i] + dist * proj_vec[i];
         if( (BSdistptpt( &rc, the_start_point, the_stop_point)) < dist_comp )
         {
             for(i=0; i<3; i++)
                 the_stop_point[i] = to_ref_pt[i] - dist * proj_vec[i];
         }
      }
      else
      {
         for(i=0; i<3; i++)  
         {
             the_start_point[i] = from_ref_pt[i] - dist / 2.0 * proj_vec[i];
             the_stop_point[i]  = to_ref_pt[i] + dist / 2.0 * proj_vec[i];
         }
         if( (BSdistptpt( &rc, the_start_point, the_stop_point)) < dist_comp )
         { 
             for(i=0; i<3; i++)  
             {
                 the_start_point[i] = from_ref_pt[i] - dist / 2.0 * proj_vec[i];
                 the_stop_point[i]  = to_ref_pt[i] + dist / 2.0 * proj_vec[i];
             }
         }
      }
   } 
   else if(!from_is_plane && to_is_plane) /* from surface to ref. pln */
   {
      /*
       * Two possible cases occur here :
       *     a) 'To plane' is out side the range box limits of the
       *        'From Surface'
       *     b) 'To plane is with in the range box limits of the
       *        'From Surface'
       * Save side point generation :
       *     In case of a)
       *        The minimum distance point from the 'To plane' is taken as
       *        taken as the 'from reference point' and the middle point of 
       *        the 'from_ref_pt and to_ref_pt' is taken as the save side point.
       *     In case of b)
       *        The point which is in the direction of projection direction is
       *        taken as the 'from reference point' and the middle point of the
       *        'from_ref_pt and to_ref_pt' is taken as the save side point.
       */

      dist1 = BSdistptpt( &rc, to_ref_pt, from_min );
      dist2 = BSdistptpt( &rc, to_ref_pt, from_max );

      sts = BSmkvec( &rc, vec0, to_ref_pt, from_min );
      add$status( test = BSERROR(rc), msg = *msg, code = EMS_E_BSerror,
          str = "EMget_projection_start_stop_pt : BSmkvec error",
          action = GOTO_VALUE, value = ret_end );

      BSnorvec( &rc, vec0 );

      sts = BSmkvec( &rc, vec1, to_ref_pt, from_max );
      add$status( test = BSERROR(rc), msg = *msg, code = EMS_E_BSerror,
          str = "EMget_projection_start_stop_pt : BSmkvec error",
          action = GOTO_VALUE, value = ret_end );

      BSnorvec( &rc, vec1 );

      value1 = BSdotp( &rc, proj_vec, vec0 );
      add$status( test = BSERROR(rc), msg = *msg, code = EMS_E_BSerror,
          str = "EMget_projection_start_stop_pt : BSdotp error",
          action = GOTO_VALUE, value = ret_end );

      value2 = BSdotp( &rc, proj_vec, vec1 );
      add$status( test = BSERROR(rc), msg = *msg, code = EMS_E_BSerror,
          str = "EMget_projection_start_stop_pt : BSdotp error",
          action = GOTO_VALUE, value = ret_end );

      /*
       * "TO Plane" is with in the range box limits of the "FROM Surface"
       */
      if( (value1 < 0.0 && value2 > 0.0) || (value1 > 0.0 && value2 < 0.0) )
      {
         if( value1 > 0.0 )
         {
            OM_BLOCK_MOVE( from_min, from_ref_pt, sizeof(IGRpoint) );
         }
         else
         {
            OM_BLOCK_MOVE( from_max, from_ref_pt, sizeof(IGRpoint) );
         }

         dist = dist1 + dist2;
      }
      /*
       * "TO Plane" is out side the range box limits of the "FROM Surface"
       */
      else
      {
         if( dist1 < dist2 )
         {
            OM_BLOCK_MOVE( from_min, from_ref_pt, sizeof(IGRpoint) );
            dist = dist2;
         }
         else
         {
            OM_BLOCK_MOVE( from_max, from_ref_pt, sizeof(IGRpoint) );
            dist = dist1;
         }
      }

      /*
       * calculate the save side point
       */
      /*
      for(i=0; i<3; i++)
          the_mid_point[i] = (from_ref_pt[i] + to_ref_pt[i]) / 2.0;
      */

      OM_BLOCK_MOVE (begin_prjvec, the_mid_point, sizeof (IGRpoint));

      dist_comp = 0.9 * ( BSdistptpt(&rc, from_ref_pt, to_ref_pt) + dist );

      /*
       * calculate the start and stop points :
       *    If the 'TO Plane' is same as the profile plane then take the
       *    'to_ref_pt' as the starting point otherwise starting point is
       *    taken as the point away from the 'to_ref_pt by half of the 'dist'.
       *    Stop point is is taken as the point away from the 'from_ref_pt' by
       *    half of the 'dist'.
       */
      if( to_is_same_as_profile_plane )
      {
          OM_BLOCK_MOVE(to_ref_pt, the_start_point, sizeof(IGRpoint));
          for(i=0; i<3; i++)
              the_stop_point[i] = from_ref_pt[i] - dist * proj_vec[i];
          if( (BSdistptpt(&rc, the_start_point, the_stop_point)) > dist )
          {  
             for(i=0; i<3; i++)
                 the_stop_point[i] = from_ref_pt[i] +  dist * proj_vec[i];
          }
      }
      else
      {
          for(i=0; i<3; i++)
          {   
              the_start_point[i] = to_ref_pt[i] - dist / 2.0 * proj_vec[i];
              the_stop_point[i]  = from_ref_pt[i] + dist / 2.0 * proj_vec[i];
          }
          if( (BSdistptpt(&rc, the_start_point, the_stop_point)) < dist_comp )
          {
              for(i=0; i<3; i++)
              {   
                  the_start_point[i] = to_ref_pt[i] + dist / 2.0 * proj_vec[i];
                  the_stop_point[i]  = from_ref_pt[i] - dist / 2.0 * proj_vec[i];
              }
          }
      } 
   }
   else if(from_is_plane && to_is_plane) /* from ref pln to ref pln */
   {
      if( from_is_same_as_profile_plane && to_is_same_as_profile_plane )
      {
          OM_BLOCK_MOVE( from_ref_pt, the_start_point, sizeof(IGRpoint));
          OM_BLOCK_MOVE( to_ref_pt, the_stop_point, sizeof(IGRpoint));
          for(i=0; i<3; i++)
              the_mid_point[i] = (from_ref_pt[i] + to_ref_pt[i]) / 2.0;
      }
      else if( from_is_same_as_profile_plane || to_is_same_as_profile_plane )
      {
          if( from_is_same_as_profile_plane )
              OM_BLOCK_MOVE( from_ref_pt, the_start_point, sizeof(IGRpoint));
          else
              OM_BLOCK_MOVE( to_ref_pt, the_start_point, sizeof(IGRpoint));

          if( from_is_same_as_profile_plane )
              OM_BLOCK_MOVE( to_ref_pt, ref_pt, sizeof(IGRpoint) );
          else
              OM_BLOCK_MOVE( from_ref_pt, ref_pt, sizeof(IGRpoint) );

          for(i=0; i<3; i++)
              the_mid_point[i] = (ref_pt[i] + the_start_point[i]) / 2.0;

          BSmkvec( &rc, vec2, the_start_point, ref_pt );
          BSnorvec( &rc, vec2 ); 

          dist1 = BSdistptpt( &rc, ref_pt, the_start_point);

          for(i=0; i<3; i++)
              maxpt[i] = ref_pt[i] + dist1 * vec2[i];

          OM_BLOCK_MOVE(maxpt, the_stop_point, sizeof(IGRpoint));
      }
      else
      {
          for(i=0; i<3; i++)
              the_mid_point[i] = (from_ref_pt[i] + to_ref_pt[i]) / 2.0;
            
          BSmkvec( &rc, vec2, from_ref_pt, to_ref_pt );
          BSnorvec( &rc, vec2 ); 

          dist1 = BSdistptpt( &rc, from_ref_pt, to_ref_pt );

          for(i=0; i<3; i++)
          {
              minpt[i] = from_ref_pt[i] - dist1/2.0 * vec2[i];  
              maxpt[i] = to_ref_pt[i] + dist1/2.0 * vec2[i];  
          }
          OM_BLOCK_MOVE(minpt, the_start_point, sizeof(IGRpoint));
          OM_BLOCK_MOVE(maxpt, the_stop_point, sizeof(IGRpoint));
      } 
   }
   }
   if(from_and_to_are_same)
   {
     surf_info->num_sfs = 1;
     surf_info->sfs_grid = (struct GRid *) malloc( sizeof(struct GRid) );

     if( !from_is_ref_pln )
     {
       ok = CopyObject( from_surf_id->objid, from_surf_id->osnum, modenvsf,
                        &surf_info->sfs_grid[0].objid ); 
       add$status( test = !ok, msg = *msg, code = EMS_E_Fail,
           str = "EMget_projection_start_stop_pt : CopyObject error",
           action = GOTO_VALUE, value = ret_end );
     }
     else
      surf_info->sfs_grid[0].objid = from_surf_id->objid; 
 
     surf_info->sfs_grid[0].osnum = os;
   }
   else 
   {  
     surf_info->num_sfs = 0;

     if(!from_is_same_as_profile_plane)
       surf_info->num_sfs ++;
      
     if(!to_is_same_as_profile_plane)
       surf_info->num_sfs ++;
     
     if( surf_info->num_sfs ) 
       surf_info->sfs_grid = (struct GRid *) om$malloc( size = 
                                   surf_info->num_sfs * sizeof(struct GRid));

     if(!from_is_same_as_profile_plane)
     {
       if( !from_is_ref_pln )
       {
         ok = CopyObject( from_surf_id->objid, from_surf_id->osnum, modenvsf,
                          &surf_info->sfs_grid[0].objid );
         add$status( test = !ok, msg = *msg, code = EMS_E_Fail,
             str = "EMget_projection_start_stop_pt : CopyObject error",
             action = GOTO_VALUE, value = ret_end );
       }
       else
         surf_info->sfs_grid[0].objid = from_surf_id->objid;

       surf_info->sfs_grid[0].osnum = os;
     }
   
     
     if(!to_is_same_as_profile_plane)
     { 
       i = surf_info->num_sfs - 1;

       if( !to_is_ref_pln )
       {
         ok = CopyObject( to_surf_id->objid, to_surf_id->osnum, modenvsf,
                          &surf_info->sfs_grid[i].objid );
         add$status( test = !ok, msg = *msg, code = EMS_E_Fail,
             str = "EMget_projection_start_stop_pt : CopyObject error",
             action = GOTO_VALUE, value = ret_end );
       }
       else
         surf_info->sfs_grid[i].objid = to_surf_id->objid;

       surf_info->sfs_grid[i].osnum = os;
     }
   }

   if( from_is_ref_pln )
     surf_info->props |= FROM_SURF_REFPLANE;
   else if( from_is_pln )
     surf_info->props |= FROM_SURF_PLANE;

   if( to_is_ref_pln )
     surf_info->props |= TO_SURF_REFPLANE;
   else if( to_is_pln )
     surf_info->props |= TO_SURF_PLANE;

   if( from_and_to_are_same)
     surf_info->props |= FROM_AND_TO_ARE_SAME;
 }
 /*
  * Feature : THRU ALL
  */
 else if(feaopts & EMSfeature_thru_all)
 {
    result1 = BSdistptpt(&rc, startpt_prjvec, projpt1);
    result2 = BSdistptpt(&rc, startpt_prjvec, projpt2);

    if(result1 < result2)
    {
       OM_BLOCK_MOVE(projpt1, the_start_point, sizeof(IGRpoint));
       OM_BLOCK_MOVE(projpt2, the_stop_point, sizeof(IGRpoint));
    }
    else
    {
       OM_BLOCK_MOVE(projpt2, the_start_point, sizeof(IGRpoint));
       OM_BLOCK_MOVE(projpt1, the_stop_point, sizeof(IGRpoint));
    }
 }
 /*
  * Feature : FINITE / SYMMETRIC
  */
 else if(feaopts & EMSfeature_finite) /* Finite Feature */
 {
    BSnorvec(&rc, proj_vec);

    /*
     * In this case we have to create the right sized secondary solid
     * finite.
     */
    if(feaopts & EMSfeature_symmetric)
    {
       /*
        * In this case also we need to compute the start and stop points.
        */
       for(i=0; i<3; i++)
       {
           the_stop_point[i]  = startpt_prjvec[i] + 
                                (*proj_dist/2.0) * proj_vec[i];
           the_start_point[i] = startpt_prjvec[i] - 
                                (*proj_dist/2.0) * proj_vec[i];
       } 
    }
    else
    {
       for(i=0; i<3; i++)
       {
           the_start_point[i] = startpt_prjvec[i];
           the_stop_point[i]  = startpt_prjvec[i] + 
                                (*proj_dist) * proj_vec[i]; 
       }
    }
 }

  /*
   * By this time, potentially the correct start and stop points have
   * been evaluated. We need to transform the profile at the evaluated
   * start point.
   */
  
  for(i=0; i<3; i++)
      xforms_vec[i] = the_start_point[i] - startpt_prjvec[i];
  success = MAtrlmx(&msg_loc, xforms_vec, (IGRdouble *)xform_mat);
  add$status( test = !success || !(1&msg_loc), msg = *msg, code = EMS_E_BSerror,
      str = "EMget_projection_start_stop_pt : MAtrlmx error",
      action = GOTO_VALUE,  value = ret_end );

  /*
   * find out the type of the matrix
   */
  success = MAtypemx(&msg_loc, (IGRdouble *)xform_mat, &xform_mattyp);
  add$status( test = !success || !(1&msg_loc), msg = *msg, code = EMS_E_BSerror,
      str = "EMget_projection_start_stop_pt : MAtrlmx error",
      action = GOTO_VALUE,  value = ret_end );
    
  outcrv.osnum = profile->osnum;
  save_md_id = modenvcv->md_id.objid;
  // modenvcv->md_id.objid = NULL_OBJID;
  outcrv.osnum = profile->osnum;

  ok = CopyObject( profile->objid, profile->osnum, modenvcv, &(outcrv.objid) ); 
  modenvcv->md_id.objid = save_md_id;

  add$status( test = !ok, msg = *msg, code = EMS_E_Fail,
      str = "EMget_projection_start_stop_pt : CopyObject error",
      action = GOTO_VALUE,  value = ret_end );

  if((xform_mattyp != NULL)  && (xform_mat != NULL))
  {
    save_md_id = modenvcv->md_id.objid;
    // modenvcv->md_id.objid = NULL_OBJID;
    new_prof_id->osnum = outcrv.osnum;

    ok = XformObject( outcrv.objid, outcrv.osnum, modenvcv, &xform_mattyp, 
                      xform_mat, &new_prof_id->objid);
    modenvcv->md_id.objid = save_md_id;

    add$status( test = !ok, msg = *msg, code = EMS_E_Fail,
         str = "EMget_projection_start_stop_pt : XformObject error",
         action = GOTO_VALUE,  value = ret_end );
  }
 
  /*
   * Post the start, stop and save side point in surf_info structure.
   */
  OM_BLOCK_MOVE( the_mid_point, surf_info->svsdpt, sizeof(IGRpoint));
  OM_BLOCK_MOVE( the_start_point, &surf_info->d.proj_pts[0], sizeof(IGRpoint));
  OM_BLOCK_MOVE( the_stop_point, &surf_info->d.proj_pts[3], sizeof(IGRpoint));

ret_end:
   
  if( prof_geom ) om$dealloc( ptr = prof_geom );
  EMWRAPUP( *msg, sts, "EMget_projection_start_stop_pt");
 
  return(sts);
}


IGRlong  EFplane_from_ref_pt( plane_pt, ref_pt, direction, plane )
IGRdouble         *plane_pt, *ref_pt;
IGRushort        direction;
struct IGRplane   *plane;
{
  IGRlong     BSmsg, num_pts=3;
  IGRpoint    plane_pts[3];
  IGRdouble   chttol;
  IGRboolean  BSsts;

  BSEXTRACTPAR(&BSmsg, BSTOLCHRDHT, chttol);
  OM_BLOCK_MOVE( &plane_pt[0], plane_pts[0], sizeof(IGRpoint) );
  OM_BLOCK_MOVE( &plane_pt[0], plane_pts[1], sizeof(IGRpoint) );
  OM_BLOCK_MOVE( &plane_pt[0], plane_pts[2], sizeof(IGRpoint) );

  if( direction == X )
  {
     plane_pts[1][Y] = ref_pt[Y];
     plane_pts[2][Z] = ref_pt[Z];
  }
  else if( direction == Y )
  {
     plane_pts[1][X] = ref_pt[X];
     plane_pts[2][Z] = ref_pt[Z];
  }
  else
  {
     plane_pts[1][X] = ref_pt[X];
     plane_pts[2][Y] = ref_pt[Y];
  }

  BSsts = MAdetplane( &BSmsg, (IGRdouble *)plane_pts, &num_pts, &chttol, plane);
  if( !BSsts || !(1&BSmsg) )
     return (IGRlong) OM_E_ABORT;
  else
     return (IGRlong) OM_S_SUCCESS; 
}

/*
 * NAME
 *         EMget_corner_points_of_rngbox
 *
 * ABSTRACT
 *         
 *         Given the range box limits this routine returns the '8 corners' of
 *         of the range box.
 *
 * SYNOPSIS
 *
 * RETURN VALUES
 *
 * ALGORITHM
 *
 * NOTES
 *
 * HISTORY
 *         Rustagi         ??/??/??       Creation
 *         Sanjay          09/14/94       Header Creation 
 */

void EMget_corner_points_of_rngbox(range, corners)
IGRdouble *range;
IGRpoint *corners;
{
 IGRdouble delx, dely, delz;
 IGRlong pt_size;

 pt_size = sizeof(IGRpoint);

 delx = range[3] - range[0];
 dely = range[4] - range[1];
 delz = range[5] - range[2];

 OM_BLOCK_MOVE(&range[0], &corners[0], pt_size);
 OM_BLOCK_MOVE(&range[3], &corners[7], pt_size);

 OM_BLOCK_MOVE(&range[0], &corners[1], pt_size);
  corners[1][0] = range[0] + delx;
 OM_BLOCK_MOVE(&range[0], &corners[2], pt_size);
  corners[2][1] = range[1] + dely;
 OM_BLOCK_MOVE(&range[0], &corners[3], pt_size);
  corners[3][2] = range[2] + delz;
 OM_BLOCK_MOVE(&range[3], &corners[4], pt_size);
  corners[4][0] = range[3] - delx;
 OM_BLOCK_MOVE(&range[3], &corners[5], pt_size);
  corners[5][1] = range[4] - dely;
 OM_BLOCK_MOVE(&range[3], &corners[6], pt_size);
  corners[6][2] = range[5] - delz;
}  

/*
 * NAME
 *
 * ABSTRACT
 *
 * SYNOPSIS
 *
 * RETURN VALUES
 *
 * ALGORITHM
 *
 * NOTES
 *
 * HISTORY
 */

IGRlong  EMcap_surface_of_revolution(
IGRlong                *EFmsg,
struct GRvg_construct  *conslist, 
struct GRid            *sfgrid,
struct GRid            *profgrid,
IGRdouble              *axis, 
IGRdouble              startangle,
IGRdouble              sweepangle,
struct GRid            *slgrid )
{
  IGRlong               OMsts, OMmsg;
  GRobjid               comps[3];
  IGRshort              mattype;
  IGRdouble             axisvec[3];
  IGRmatrix             matrix;
  IGRboolean            ok;
  struct GRid           closeprof, cap1, cap2;
  struct GRmd_env       *mdenv;
  struct GRlc_info      prof_lcinfo;
  

  // Validate input arguments
  if( !sfgrid || !conslist || !profgrid || !slgrid )
     add$status( test = TRUE, msg = *EFmsg, code = EMS_E_InvalidArg, 
         str = "EMcap_surface_of_revolution : Invalid Arguments", 
         action = GOTO_VALUE, value = wrapup );
  
  OMsts   = OM_S_SUCCESS;
  OMmsg   = EMS_S_Success;
  *EFmsg  = EMS_S_Success;

  mdenv   = conslist->env_info;
  /*
   * As the Profile is not closed, create a closed profile from the given
   * profile.
   */
  ok = CloseProfile( &OMmsg, profgrid, mdenv, conslist, &closeprof, NULL, 
                     NULL, NULL );
  add$status( test = !ok || !(1&OMmsg), msg = *EFmsg, code = EMS_E_Fail, 
         str = "EMcap_surface_of_revolution : CloseProfile error", 
         action = GOTO_VALUE, value = wrapup );

  BSmkvec(  &OMmsg, axisvec, &axis[0], &axis[3]);
  BSnorvec( &OMmsg, axisvec );

  if( startangle != 0.0 )
  {
    MAdegrad( &OMmsg, &startangle, &startangle );

    ok = MAgrotmx( &OMmsg, axisvec, &axis[0], &startangle, matrix );
    add$status( test = !ok || !(1&OMmsg), msg = *EFmsg, code = EMS_E_BSerror,
        str = "EMcap_surface_of_revolution : MArotmx error",
        action = GOTO_VALUE, value = wrapup );
  
    ok = MAtypemx( &OMmsg, (IGRdouble *)matrix, &mattype );
    add$status( test = !ok || !(1&OMmsg), msg = *EFmsg, code = EMS_E_BSerror,
        str = "EMcap_surface_of_revolution : MAtypemx error",
        action = GOTO_VALUE, value = wrapup );
 
    ok = XformObject( closeprof.objid, closeprof.osnum, mdenv, &mattype, 
                      matrix, &closeprof.objid ); 
    add$status( test = !ok, msg = *EFmsg, code = EMS_E_Fail,
        str = "EMcap_surface_of_revolution : XformObject error",
        action = GOTO_VALUE, value = wrapup );
  }

  cap1.osnum = profgrid->osnum;
  cap2.osnum = profgrid->osnum;

  /*
   * Create a plane encompassing this closed profile.
   */
  prof_lcinfo.located_obj = closeprof;
  OM_BLOCK_MOVE( mdenv, &prof_lcinfo.module_info, sizeof(struct GRmd_env));  

  OMsts = om$construct( msg = message EMSplane.EMplane_of_curve( &OMmsg, 
                              conslist, &prof_lcinfo, NULL, NULL, FALSE, 
                              TRUE, NULL, NULL), 
                classid = OPP_EMSplane_class_id,
                p_objid = &cap1.objid,
                osnum   = cap1.osnum );
  add$status( test = !ok || !(1&OMmsg), msg = *EFmsg, code = EMS_E_Fail, 
      str = "EMcap_surface_of_revolution : EMSplane.EMplane_of_curve error", 
      action = GOTO_VALUE, value = wrapup );

  /*
   * Generate the second cap by rotating the first cap by sweep angle.
   */ 

  //form the rotation matrix 

  MAdegrad( &OMmsg, &sweepangle, &sweepangle );

  ok = MAgrotmx( &OMmsg, axisvec, &axis[0], &sweepangle, matrix );
  add$status( test = !ok || !(1&OMmsg), msg = *EFmsg, code = EMS_E_BSerror,
      str = "EMcap_surface_of_revolution : MArotmx error",
      action = GOTO_VALUE, value = wrapup );

  ok = MAtypemx( &OMmsg, (IGRdouble *)matrix, &mattype );
  add$status( test = !ok || !(1&OMmsg), msg = *EFmsg, code = EMS_E_BSerror,
      str = "EMcap_surface_of_revolution : MAtypemx error",
      action = GOTO_VALUE, value = wrapup );

  ok = CopyObject( cap1.objid, cap1.osnum, mdenv, &cap2.objid );
  add$status( test = !ok , msg = *EFmsg, code = EMS_E_Fail,
      str = "EMcap_surface_of_revolution : CopyObject error",
      action = GOTO_VALUE, value = wrapup );

  ok = XformObject( cap2.objid, cap2.osnum, mdenv, &mattype, matrix, 
                    &cap2.objid );
  add$status( test = !ok, msg = *EFmsg, code = EMS_E_Fail,
      str = "EMcap_surface_of_revolution : XformObject error",
      action = GOTO_VALUE, value = wrapup );


  /*
   * Construct solid
   */
  slgrid->osnum = sfgrid->osnum;

  comps[0] = sfgrid->objid;
  comps[1] = cap1.objid;
  comps[2] = cap2.objid;

  OMsts = om$construct( classid = OPP_EMSsfstitch_class_id,
                        p_objid = &slgrid->objid,
                        osnum   = slgrid->osnum,
                        msg = message EMSsfstitch.EMmake_comp( &OMmsg, 
                                      (IGRint) 3, comps, mdenv, NULL, NULL, 
                                      0, NULL, NULL ) );
  add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
      str = "EMcap_surface_of_revolution : EMSsfstitch.EMmake_comp error",
      action = GOTO_VALUE, value = wrapup );

  OMsts = om$change_class( objid = slgrid->objid, osnum = slgrid->osnum,
                           classname = "EMSslstitch" );
  add$status( test = !(1&OMsts), msg = *EFmsg, code = EMS_E_Fail,
      str = "EMcap_surface_of_revolution : om$change_class error",
      action = GOTO_VALUE, value = wrapup );

  OMsts = om$send( msg = message EMSsolid.EMorient_yourself( &OMmsg, NULL,
                                 conslist->env_info ),
                   senderid = NULL_OBJID,
                   targetid = slgrid->objid,
                   targetos = slgrid->osnum );
  add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
      str = "EMcap_surface_of_revolution : EMSsolid.EMorient_yourself error",
      action = GOTO_VALUE, value = wrapup );

wrapup :

  DeleteObject( &closeprof.objid, mdenv );
  return OMsts;
}

/*
 * NAME
 *
 * ABSTRACT
 *
 * SYNOPSIS
 *
 * RETURN VALUES
 *
 * ALGORITHM
 *
 * NOTES
 *
 * HISTORY
 */
IGRlong EMget_revolution_svsdpt( 
IGRlong               *EFmsg,
struct GRvg_construct *cons_list,
struct ProfileInfo    *prof_info,
IGRdouble             *axis_ends,
struct GRid           *from_surf_grid,
struct GRid           *to_surf_grid,
struct FromToSurfInfo *surf_info )
{
   /* general variables */
   BSrc        BSmsg=BSSUCC;
   IGRint      i=0, num_from_int=0, num_to_int=0;
   GRrange     cvrange, slrange;
   IGRlong     OMsts=OM_S_SUCCESS, OMmsg=EMS_S_Success;
   OMuword     classid, osnum;
   IGRshort    *mat_type=NULL; 
   IGRdouble   *mat=NULL, from_center[3], to_center[3], from_angle, to_angle;
   IGRboolean  ok=TRUE;
   struct GRid *prof_grid=NULL;

   /* circular arc generation */
   IGRpoint   stpoint, center;
   IGRvector  normal;

   /* intersection between the circle and the from and to planes */ 
   IGRdouble  line[2][3], radius, from_int_pts[6], from_int_angs[2];
   IGRdouble  to_int_pts[6], to_int_angs[2], lentol, diag, angtol=0; 
   IGRboolean from_is_plane, to_is_plane, from_and_to_are_same;
   IGRboolean inrange, from_is_pln, to_is_pln, from_is_refpln, to_is_refpln;

   /* planar definitions of from and to surfaces */
   struct IGRplane  from_plane, to_plane, *prof_plane=NULL;
   struct IGRbsp_surface *from_surf=NULL, *to_surf=NULL, *surf=NULL;

   /*
    * INITIALIZATION 
    */
   // Status 
   OMsts = OM_S_SUCCESS;
   OMmsg = EMS_S_Success;
   *EFmsg = EMS_S_Success;

   // Local Variables
   mat = cons_list->env_info->md_env.matrix;
   mat_type = &cons_list->env_info->md_env.matrix_type;
   memset( &to_plane, 0, sizeof(struct IGRplane) );
   memset( &from_plane, 0, sizeof(struct IGRplane) );
   osnum = from_surf_grid->osnum;
   prof_grid  = &prof_info->grid;
   prof_plane = &prof_info->plane; 
   from_and_to_are_same = FALSE;
 
   from_is_plane = to_is_plane = FALSE;
   from_is_pln = to_is_pln = TRUE;
   from_is_refpln = to_is_refpln = FALSE;

   // allocate memory
   from_plane.point  = (IGRdouble *) alloca( sizeof(IGRpoint) );
   from_plane.normal = (IGRdouble *) alloca( sizeof(IGRvector) ); 
   to_plane.point  = (IGRdouble *) alloca( sizeof(IGRpoint) );
   to_plane.normal = (IGRdouble *) alloca( sizeof(IGRvector) ); 

   surf_info->d.rev_angs[0]  = 0.0;
   surf_info->d.rev_angs[1]  = 360.0;

   OMsts = BSEXTRACTPAR (&BSmsg, BSTOLLENVEC, lentol);
   angtol = EMS_ZEROANGLE_DEG;

   /*
    * Check whether the given surfaces are same or not
    */
   if( (from_surf_grid->objid == to_surf_grid->objid) &&
       (from_surf_grid->osnum == to_surf_grid->osnum) )
      from_and_to_are_same = TRUE;

   /*
    * get the range box limits of the profile
    */
   ok = GetObjectRange( prof_grid->objid, prof_grid->osnum,cons_list->env_info,
                        cvrange );
   add$status( test = !ok, msg = *EFmsg, code = EMS_E_Fail,
       str = "EMget_revolution_svsdpt : GetObjectRange error",
       action = GOTO_VALUE, value = wrapup );

   /*
    * get the circular arc parameters, such as starting point, center, radius 
    * and the normal to the plane of the circle.
    */
   for(i=0; i<3; i++)
     stpoint[i] = (cvrange[i] + cvrange[i+3]) / 2.0;

   OM_BLOCK_MOVE( &axis_ends[0], line[0], sizeof(IGRpoint) );
   OM_BLOCK_MOVE( &axis_ends[3], line[1], sizeof(IGRpoint) );

   BSproj0( &BSmsg, stpoint, line, center );
   add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
       str = "EMget_revolution_svsdpt : BSproj0 error",
       action = GOTO_VALUE, value = wrapup );

   BSmkvec( &BSmsg, normal, &axis_ends[0], &axis_ends[3] );
   add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
       str = "EMget_revolution_svsdpt : BSmkvec error",
       action = GOTO_VALUE, value = wrapup );

   BSnorvec( &BSmsg, normal );

   radius = BSdistptpt( &BSmsg, center, stpoint );

   /*
    * check whether the from surface is planar or not
    */
   OMsts = om$get_classid( objid = from_surf_grid->objid, 
                           osnum = from_surf_grid->osnum,
                           p_classid = &classid );
   add$status( test = !(1&OMsts), msg = *EFmsg, code = EMS_E_Fail, 
       str = "EMget_revolution_svsdpt : om$get_classid error",
       action = GOTO_VALUE, value = wrapup );

   if( is_a_subclass( classid, OPP_EMSdatpln_class_id ) == OM_S_SUCCESS )
     from_is_refpln = TRUE;
   else if( is_a_subclass( classid, OPP_EMSplane_class_id ) == OM_S_SUCCESS )
     from_is_pln = TRUE;

   from_is_plane = from_is_pln || from_is_refpln;

   /*
    * if the surface is planar:
    */
   if( from_is_plane )
   {
      IGRboolean from_tangent;

      /*
       * get the plane definition of the from surface 
       */
      OMsts = om$send( msg = message GRvg.GRdetplane( &OMmsg, mat_type, mat,
                                     &from_plane ),
                       senderid = NULL_OBJID,
                       targetid = from_surf_grid->objid,
                       targetos = from_surf_grid->osnum );
      add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
          str = "EMget_revolution_svsdpt : GRdetplane error",
          action = GOTO_VALUE, value = wrapup );

      /*
       * intersect the from plane with the circular arc
       */
      BSxplcirc(from_plane.point, from_plane.normal, center, normal, stpoint,
                stpoint, (360.0), radius, &num_from_int, from_int_pts,
                from_int_angs, &from_tangent, &BSmsg );
      add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
          str = "EMget_revolution_svsdpt : BSxplcirc error",
          action = GOTO_VALUE, value = wrapup );
      add$status( test = !num_from_int, msg = *EFmsg, 
          code = EMS_E_AddRmNoIntFromSurf, str = "EMget_revolution_svsdpt : Msg : From Surface does not intersect with the secondary solid.",
          action = GOTO_VALUE, value = wrapup );

      MAraddeg( &BSmsg, &from_int_angs[0], &from_int_angs[0] );
      MAraddeg( &BSmsg, &from_int_angs[1], &from_int_angs[1] );

   } // end of (from_is_plane) 
   else
   {
      add$status (test = TRUE, msg = *EFmsg, code = EMS_E_Fail,
          str = "EMget_revolution_svsdpt : NOT YET IMPLEMENTED FOR GEN. SURFACES",
          action = GOTO_VALUE, value = wrapup );
   }


   /*
    * get the center of the range box of the from surface.
    */
   if( !from_is_refpln )
   {
     IGRint npts=3;
     IGRdouble points[9];
     /* get three points on the surface in area */

     OMsts = om$send( msg = message EMSsurface.EMget_point_on_surface( &OMmsg,
                                    cons_list->env_info, (IGRuint) 0, npts,
                                    points, NULL),
                      senderid = NULL_OBJID,
                      targetid = from_surf_grid->objid,
                      targetos = from_surf_grid->osnum );
     add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
         str = "EMget_revolution_svsdpt : EMget_point_on_surface error",
         action = GOTO_VALUE, value = wrapup );

     for(i=0; i<3; i++)
        from_center[i] = (points[i] + points[i+3] + points[i+6]) / 3.0;
   }
   else
   {
     OMsts = om$send( msg = message EMSdatpln.EMget_pln_info( &OMmsg, NULL,
                                    cons_list->env_info, NULL, NULL, NULL, 
                                    from_center, NULL ),
                      senderid = from_surf_grid->objid,
                      targetid = from_surf_grid->objid,
                      targetos = from_surf_grid->osnum );
     add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
         str = "EMget_revolution_svsdpt : EMSdatpln.EMget_pln_info error",
         action = GOTO_VALUE, value = wrapup );
   }
   
   /*
    * from and to suraces are different
    */
   if( !from_and_to_are_same )
   {
      /* 
       * check whether the the to surface is planar or not 
       */
      OMsts = om$get_classid( objid = to_surf_grid->objid,
                              osnum = to_surf_grid->osnum,
                              p_classid = &classid );
      add$status( test = !(1&OMsts), msg = *EFmsg, code = EMS_E_Fail,
          str = "EMget_revolution_svsdpt : om$get_classid error",
          action = GOTO_VALUE, value = wrapup );
   
      if( is_a_subclass( classid, OPP_EMSdatpln_class_id ) == OM_S_SUCCESS )
        to_is_refpln = TRUE;
      else if( is_a_subclass( classid, OPP_EMSplane_class_id ) == OM_S_SUCCESS )
        to_is_pln = TRUE;

      to_is_plane = to_is_refpln || to_is_pln;
    
      /*
       * if to surface is planar, then get the palne definition.
       */ 
      if( to_is_plane )
      {
         OMsts = om$send( msg = message GRvg.GRdetplane( &OMmsg, mat_type, mat,
                                        &to_plane ),
                          senderid = NULL_OBJID,
                          targetid = to_surf_grid->objid,
                          targetos = to_surf_grid->osnum );
         add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
             str = "EMget_revolution_svsdpt : GRdetplane error",
             action = GOTO_VALUE, value = wrapup );
      }
      else
      {
         add$status (test = TRUE, msg = *EFmsg, code = EMS_E_Fail,
             str = "EMget_revolution_svsdpt : NOT YET IMPLEMENTED FOR GEN. SURFACES",
             action = GOTO_VALUE, value = wrapup );
      }


      /*
       * If both from and to surfaces are planar and representing the same sur-
       * face then, the secondary solid need to be intersected with only one 
       * surface and that is either from or to surface.
       */
      if( from_is_plane && to_is_plane )
      {
        from_and_to_are_same = EFare_planes_same( from_plane.point, 
                           from_plane.normal, to_plane.point, to_plane.normal );
      }
   } // end of (!from_and_to_are_same)

   /*
    * if from and to surfaces are same, then take the input surface as the
    * new surface and svsdpt as the point on the profile and goto wrapup.
    */
   if( from_and_to_are_same )
   {
      surf_info->num_sfs = 1;
      surf_info->sfs_grid = (struct GRid *) om$malloc( size = 
                                               sizeof(struct GRid) );
      if( !from_is_refpln )
      {
        ok = CopyObject( from_surf_grid->objid, from_surf_grid->osnum,
                         cons_list->env_info, &surf_info->sfs_grid[0].objid );
        add$status( test = !ok, msg = *EFmsg, code = EMS_E_Fail,
            str = "EMget_revolution_svsdpt : CopyObject error",
            action = GOTO_VALUE, value = wrapup );
      }
      else
        surf_info->sfs_grid[0].objid = from_surf_grid->objid;

      surf_info->sfs_grid[0].osnum = osnum;

      if( num_from_int == 2 ) 
      {
        if( BSdistptpts(&BSmsg, &from_int_pts[0], from_center) < 
            BSdistptpts(&BSmsg, &from_int_pts[3], from_center) )
          from_angle = from_int_angs[0];
        else
          from_angle = from_int_angs[1];
   
        if( fabs(from_angle - 360.0) < (2.0 * angtol) )
          from_angle =  0.0;
      }
      else
      {
        from_angle = from_int_angs[0];
      }
    
      from_angle += 2.0 * angtol;
      EFpoint_on_circle_at_angle( center, normal, stpoint, from_angle,
                                  surf_info->svsdpt);
      goto wrapup;
   }

   if( to_is_plane )
   {
      IGRboolean  to_tangent=FALSE;

      /*
       * intersect the to plane with the circular arc
       */
      BSxplcirc(to_plane.point, to_plane.normal, center, normal, stpoint,
                stpoint, (360.0), radius, &num_to_int, to_int_pts,
                to_int_angs, &to_tangent, &BSmsg );
      add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
          str = "EMget_revolution_svsdpt : BSxplcirc error",
          action = GOTO_VALUE, value = wrapup );
      add$status( test = !num_to_int, msg = *EFmsg, 
          code = EMS_E_AddRmNoIntToSurf, str = "EMget_revolution_svsdpt : Msg : To Surface does not intersect with the secondary solid.",
          action = GOTO_VALUE, value = wrapup );

      MAraddeg( &BSmsg, &to_int_angs[0], &to_int_angs[0] );
      MAraddeg( &BSmsg, &to_int_angs[1], &to_int_angs[1] );

      /*
       * get the center of the range box of the from surface.
       */
      if( !to_is_refpln )
      {
        IGRint npts=3;
        IGRdouble points[9];

        /* get three points on the surface in area */

        OMsts = om$send( msg = message EMSsurface.EMget_point_on_surface(&OMmsg,
                                       cons_list->env_info, (IGRuint) 0, npts,
                                       points, NULL),
                         senderid = NULL_OBJID,
                         targetid = to_surf_grid->objid,
                         targetos = to_surf_grid->osnum );
        add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
            str = "EMget_revolution_svsdpt : EMget_point_on_surface error",
            action = GOTO_VALUE, value = wrapup );

        for(i=0; i<3; i++)
           to_center[i] = (points[i] + points[i+3] + points[i+6]) / 3.0;
      }
      else
      {
        OMsts = om$send( msg = message EMSdatpln.EMget_pln_info( &OMmsg, NULL,
                                       cons_list->env_info, NULL, NULL, NULL,
                                       to_center, NULL ),
                         senderid = to_surf_grid->objid,
                         targetid = to_surf_grid->objid,
                         targetos = to_surf_grid->osnum );
        add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
            str = "EMget_revolution_svsdpt : EMSdatpln.EMget_pln_info error",
            action = GOTO_VALUE, value = wrapup );
      }
   }
   else
   {
   } // end of (to_is_plane)

   /*
    * get the range box limits of the surface of revolution which will be 
    * generated from the profile.
    */
   OMsts = EFget_revsurf_range_box_from_profile( prof_plane, cvrange, 
                                                 axis_ends, slrange );
   add$status( test = !(1&OMsts), msg = *EFmsg, code = EMS_E_Fail,
       str = "EMget_revolution_svsdpt : EFget_revsurf_range_box_from_profile error",
       action = GOTO_VALUE, value = wrapup );

   diag = BSdistptpt( &BSmsg, &slrange[0], &slrange[3] );
   EM3dbxinc( slrange, 0.2 * diag );

   /*
    * if both from and to surfaces are planar :
    */
   if( from_is_plane && to_is_plane )
   {
     /* general variables */
     IGRint      span=0, from_inx=0, to_inx=0, inx1=0, inx2=0, m=0, 
                 poles_inx[4];
     IGRlong     num_poles=0;
     IGRdouble   new_point[3], new_normal[3], *poles=NULL, tpt[3]; 
     IGRdouble   pt1[3], pt2[3], new_poles[12], angle=0; 
     IGRdouble   comp_dist[2], *intpt=NULL, mindist=0, dist=0;

     /* intersection of two planes */
     IGRdouble   intcv_pts[6];
     IGRint      num_grps=0, *num_int_cvs=NULL;
     struct BSgeom_bsp_curve *int_cvs = NULL;

     /* B-Spline definition of from and to surfaces */
     struct BSgeom_bsp_surf from_geom_surf, to_geom_surf;
     GRobjid planar_surfid[2], comp_surfid;

     if( num_from_int == 2 )
     {
       if( BSdistptpts(&BSmsg, &from_int_pts[0], from_center) <
           BSdistptpts(&BSmsg, &from_int_pts[3], from_center) )
         from_inx = 0;
       else
         from_inx = 1;
     }
     else
       from_inx = 0;

     from_angle = from_int_angs[from_inx];
     if( fabs(from_angle - 360.0) < (2.0 * angtol) )
        from_angle =  0.0;

     if( num_to_int == 2 )
     {
       if( BSdistptpts(&BSmsg, &to_int_pts[0], to_center) < 
           BSdistptpts(&BSmsg, &to_int_pts[3], to_center) )
         to_inx = 0;
       else
         to_inx = 1;
     }
     else
       to_inx = 0;

     to_angle = to_int_angs[to_inx];
     if( to_angle < 2.0 * angtol )
       to_angle = 360.0;

     /*
      * Algorithm :
      *   a) Form the transformation matrix based on the rotational axis, 
      *      center of the circle and the intersection angle.
      *   b) Apply the transformation matrix on profile point and normal 
      *      and see whether the transformed point and normal matches with 
      *      the planes. 
      *   c) Repeat the steps a anb b for both from and to surfaces and if
      *      the normal matches in both the cases take the intersection angles
      *      as start and stop angles and goto wrapup.
      *   d)
      */
     
     /* 
      * rotate the profile plane by one of the intersection angle with the 
      * from plane
      */
     OMsts = EFrotate_plane( prof_plane->point, prof_plane->normal, normal,   
                             center, from_angle, new_point, new_normal );
     add$status( test = !(1&OMsts), msg = *EFmsg, code = EMS_E_Fail,
         str = "EMget_revolution_svsdpt : EFrotate_plane error",
         action = GOTO_VALUE, value = wrapup );

     /* check whether the roated plane is same as the from_plane */
     
     if( EFare_planes_same( new_point, new_normal, from_plane.point, 
                            from_plane.normal ) )
     {
       /* 
        * rotate the profile plane by one of the intersection angle with the 
        * from plane
        */
       OMsts = EFrotate_plane( prof_plane->point, prof_plane->normal, normal,
                             center, to_angle, new_point, new_normal );
       add$status( test = !(1&OMsts), msg = *EFmsg, code = EMS_E_Fail,
           str = "EMget_revolution_svsdpt : EFrotate_plane error",
           action = GOTO_VALUE, value = wrapup );

       /* check whether the roated plane is same as the to_plane */

       if( EFare_planes_same( new_point, new_normal, to_plane.point, 
                              to_plane.normal ) )
       {
          surf_info->num_sfs = 0;
          surf_info->d.rev_angs[0] = from_int_angs[0];
          surf_info->d.rev_angs[1] = to_int_angs[0];
          goto wrapup;
       }
     }

     /*
      * get the save side point 
      */
     if( to_angle > from_angle )
     {
       angle = (from_angle + to_angle) / 2.0;
       EFpoint_on_circle_at_angle( center, normal, stpoint, angle,
                                 surf_info->svsdpt);
     }
     else
     {
       angle = 0.0;
       OM_BLOCK_MOVE( stpoint, surf_info->svsdpt, sizeof(IGRpoint) );
     }


     /*
      * get the B-spline plane definition which encompasses the solid range
      */
     BSallocsf( 2, 2, 2, 2, 0, 0, &from_surf, &BSmsg );
     add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
         str = "EMget_revolution_svsdpt : BSallocsf error",
         action = GOTO_VALUE, value = wrapup );
 
     BSplptnorrg( &slrange[0], &slrange[3], from_plane.point,
                  from_plane.normal, (IGRdouble) 1.1, &inrange,
                  from_surf, &BSmsg );
     add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
         str = "EMget_revolution_svsdpt : BSplptnorrg error",
         action = GOTO_VALUE, value = wrapup );
 
     /*
      * get the B-spline plane definition which encompasses the solid range
      */
     BSallocsf( 2, 2, 2, 2, 0, 0, &to_surf, &BSmsg );
     add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
         str = "EMget_revolution_svsdpt : BSallocsf error",
         action = GOTO_VALUE, value = wrapup );
 
     BSplptnorrg( &slrange[0], &slrange[3], to_plane.point,
                  to_plane.normal, (IGRdouble) 1.1, &inrange,
                  to_surf, &BSmsg );
     add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
         str = "EMget_revolution_svsdpt : BSplptnorrg error",
         action = GOTO_VALUE, value = wrapup );

     memset( &from_geom_surf, 0, sizeof(struct BSgeom_bsp_surf));
     memset( &to_geom_surf, 0, sizeof(struct BSgeom_bsp_surf));

     from_geom_surf.geom_prop = FALSE;
     from_geom_surf.type = BSRECT_PLANE;
     from_geom_surf.bounded = TRUE;
     from_geom_surf.bspsf = from_surf;
 
     to_geom_surf.geom_prop = FALSE;
     to_geom_surf.type = BSRECT_PLANE;
     to_geom_surf.bounded = TRUE;
     to_geom_surf.bspsf = to_surf;

     /*
      * intersect the from and to planes and get the intersection line
      */
     BSx2pln(&from_geom_surf, &to_geom_surf, &num_grps, &num_int_cvs, &int_cvs, &BSmsg);
     add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_S_Success,
         str = "EMget_revolution_svsdpt : BSx2pln error",
         action = GOTO_VALUE, value = loc_wrapup );
     add$status( test = !num_grps, msg = *EFmsg, code = EMS_S_Success,
         str = "EMget_revolution_svsdpt : Msg : From and To Planes does NOT INTERSECT",
         action = GOTO_VALUE, value = loc_wrapup );
     add$status( test = (num_grps > 1 || num_int_cvs[0] > 1 ||
                         int_cvs[0].type != BSLINE), msg = *EFmsg,
         code = EMS_S_Success, str = "EMget_revolution_svsdpt : Error : number of groups or number of intersection curves is greater than ONE",
         action = GOTO_VALUE, value = loc_wrapup );

     OM_BLOCK_MOVE( int_cvs[0].pt1, &intcv_pts[0], sizeof(IGRpoint) );
     OM_BLOCK_MOVE( int_cvs[0].pt2, &intcv_pts[3], sizeof(IGRpoint) );

     /*
      * find the spans in which these intersection points are lying
      */
     for( m=0; m<2; m++ )
     {
       if(m)
       { 
         surf  = to_surf; 
         intpt = &to_int_pts[to_inx*3];
       }
       else  
       {
         surf  = from_surf;
         intpt = &from_int_pts[from_inx*3];
       }

       poles = surf->poles;
       mindist = -1.0;

       /*
        * Inter-change the 2 and 3rd poles so that the geometry represents
        * a rectangle
        */
       OM_BLOCK_MOVE( &poles[6], tpt, sizeof(IGRpoint) );
       OM_BLOCK_MOVE( &poles[9], &poles[6], sizeof(IGRpoint) );
       OM_BLOCK_MOVE( tpt, &poles[9], sizeof(IGRpoint) );

       for( i=0; i<4; i++ )
       {
         OM_BLOCK_MOVE( &poles[i*3], pt1, sizeof(IGRpoint) );
         if( i==3 )
           OM_BLOCK_MOVE( &poles[0], pt2, sizeof(IGRpoint) );
         else
           OM_BLOCK_MOVE( &poles[(i+1)*3], pt2, sizeof(IGRpoint) );

         if( BSdistptli( &BSmsg, &intcv_pts[0], pt1, pt2, &dist ) )
         {
           if( mindist < 0.0 )
           { 
             mindist = dist;
             span = i;
           }
           else if( dist < mindist ) 
           { 
             mindist = dist;
             span = i;
           }
           if( mindist < lentol ) break;
         }
       }

       /*
        * see which point is lying in the range box limits of the from/to 
        * surface
        */
       if(span == 2  || span == 3)
       {
         inx1 = 1; inx2 = 0;
       }
       else
       {
         inx1 = 0; inx2 = 1;
       }

       for( i=0; i<2; i++ )
       {
         IGRpoint  new_center;

         if(i) 
         {
           if(span == 0 || span == 2)
           {
             poles_inx[2] = 1; poles_inx[3] = 2;
           }
           else
           {
             poles_inx[2] = 2; poles_inx[3] = 3;
           }
         }
         else
         {
           if(span == 0 || span == 2)
           {
             poles_inx[0] = 0; poles_inx[1] = 3;
           }
           else
           {
             poles_inx[0] = 1; poles_inx[1] = 0;
           }
         }

         num_poles = 4;
         OM_BLOCK_MOVE( poles, &new_poles[0], 4 * sizeof(IGRpoint) );
         OM_BLOCK_MOVE( &intcv_pts[inx1*3], &new_poles[poles_inx[i*2]*3], sizeof(IGRpoint) );
         OM_BLOCK_MOVE( &intcv_pts[inx2*3], &new_poles[poles_inx[i*2+1]*3], sizeof(IGRpoint) );
  
         MAptscentroid( &BSmsg, new_poles, &num_poles, new_center );

         comp_dist[i] = BSdistptpts( &BSmsg, new_center, intpt);
       }

       if( comp_dist[0] < comp_dist[1] )
         i = 0;
       else
         i = 1;
       OM_BLOCK_MOVE( poles, &new_poles[0], 4 * sizeof(IGRpoint) );
       OM_BLOCK_MOVE( &intcv_pts[inx1*3], &new_poles[poles_inx[i*2]*3], sizeof(IGRpoint) );
       OM_BLOCK_MOVE( &intcv_pts[inx2*3], &new_poles[poles_inx[i*2+1]*3], sizeof(IGRpoint) );

       /*
        * Reinter-change the 2 and 3rd poles so that the poles are ordered as
        * in B-spline manner.
        */
       OM_BLOCK_MOVE( &new_poles[6], tpt, sizeof(IGRpoint) );
       OM_BLOCK_MOVE( &new_poles[9], &new_poles[6], sizeof(IGRpoint) );
       OM_BLOCK_MOVE( tpt, &new_poles[9], sizeof(IGRpoint) );

       /*
        * Create a surface with the new set of poles 
        */
       OM_BLOCK_MOVE( new_poles, surf->poles, 4 * sizeof(IGRpoint) );
       cons_list->geometry = (IGRchar *) surf;
       
       OMsts = om$construct( classid = OPP_EMSplane_class_id, 
                             p_objid = &planar_surfid[m], 
                             osnum = osnum,
                             msg = message GRvg.GRconstruct( cons_list )  
                           );
       add$status( test = !(1&OMsts&(*(cons_list->msg))), msg = *EFmsg, 
           code = EMS_E_Fail, str = "EMget_revolution_svsdpt : om$construct error", action = GOTO_VALUE, value = wrapup );

     }

     OMsts = om$construct( classid = OPP_EMSsfstitch_class_id,
                           p_objid = &comp_surfid,
                           osnum = osnum,
                           msg = message EMSsfstitch.EMmake_comp( &OMmsg,
                                         2, planar_surfid, cons_list->env_info,
                                         NULL, NULL, NULL, NULL, NULL ) );
     add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_S_Success,
         str = "EMget_revolution_svsdpt : om$construct error", 
         action = GOTO_VALUE, value = loc_wrapup );

     surf_info->props |= FROMTO_MADE_COMPSURF;
     surf_info->num_sfs = 1;
     surf_info->sfs_grid = (struct GRid *) om$malloc(size =
                                              3 * sizeof(struct GRid));
     surf_info->sfs_grid[0].objid = comp_surfid;
     surf_info->sfs_grid[0].osnum = osnum;
     surf_info->sfs_grid[1].objid = planar_surfid[0];
     surf_info->sfs_grid[1].osnum = osnum;
     surf_info->sfs_grid[2].objid = planar_surfid[1];
     surf_info->sfs_grid[2].osnum = osnum;
     goto wrapup;

   loc_wrapup :

     if (num_from_int == 2 && num_to_int == 2)
     {
       double svsd_ang = 0.0;

       GetStartAndSweepAngles (from_int_angs, to_int_angs, 
                               &surf_info->d.rev_angs[0], 
                               &surf_info->d.rev_angs[1], 
                               &svsd_ang, angtol);

       EFpoint_on_circle_at_angle (center, normal, stpoint, svsd_ang,
                                   surf_info->svsdpt);
     }

     surf_info->num_sfs = 2;
     surf_info->sfs_grid = (struct GRid *) om$malloc(size =
                                              2 * sizeof(struct GRid));
     if( !from_is_refpln )
     {
       ok = CopyObject( from_surf_grid->objid, from_surf_grid->osnum, 
                        cons_list->env_info, &surf_info->sfs_grid[0].objid );
       add$status( test = !ok, msg = *EFmsg, code = EMS_E_Fail,
           str = "EMget_revolution_svsdpt : CopyObject error",
           action = GOTO_VALUE, value = wrapup );
     }
     else
       surf_info->sfs_grid[0].objid = from_surf_grid->objid;

     surf_info->sfs_grid[0].osnum = osnum;

     if( !to_is_refpln )
     {
       ok = CopyObject( to_surf_grid->objid, to_surf_grid->osnum, 
                        cons_list->env_info, &surf_info->sfs_grid[1].objid );
       add$status( test = !ok, msg = *EFmsg, code = EMS_E_Fail,
           str = "EMget_revolution_svsdpt : CopyObject error",
           action = GOTO_VALUE, value = wrapup );
     }
     else
       surf_info->sfs_grid[1].objid = to_surf_grid->objid;

     surf_info->sfs_grid[1].osnum = osnum;

   } // end of (from_is_plane && to_is_plane)

 
wrapup :
  if(from_surf) BSfreesf( &BSmsg, from_surf );
  if(to_surf) BSfreesf( &BSmsg, to_surf );

  if( from_is_refpln )
    surf_info->props |= FROM_SURF_REFPLANE;
  else if( from_is_pln )
    surf_info->props |= FROM_SURF_PLANE;

  if( to_is_refpln )
    surf_info->props |= TO_SURF_REFPLANE;
  else if( to_is_pln )
    surf_info->props |= TO_SURF_PLANE;

  return OMsts;
}


IGRlong EFrotate_plane
(
  IGRdouble  *point,
  IGRdouble  *normal,
  IGRdouble  *axis_vec,
  IGRdouble  *origin,
  IGRdouble  angle,    // angle in degrees
  IGRdouble  *new_point,
  IGRdouble  *new_normal
) 
{
  IGRboolean BSsts;
  IGRshort   xform_mattyp;
  IGRlong    BSmsg, npts=1, EFsts; 
  IGRdouble  radians;
  IGRmatrix  xform_mat;

  EFsts = OM_S_SUCCESS;

  MAdegrad( &BSmsg, &angle, &radians );

  BSsts = MAgrotmx( &BSmsg, axis_vec, origin, &radians, xform_mat );
  add$status( test = !BSsts || !(BSmsg&1), msg = EFsts, code = EMS_E_BSerror,
      str = "EFrotate_plane : MAgrotmx error",  action = GOTO_VALUE,
      value = wrapup );

  BSsts = MAtypemx( &BSmsg, xform_mat, &xform_mattyp );

  BSsts = MAoptsxform( &BSmsg, &npts, &xform_mattyp, xform_mat, point, 
                       new_point);
  BSsts = MAoptsxform( &BSmsg, &npts, &xform_mattyp, xform_mat, normal, 
                       new_normal);
  add$status( test = !BSsts || !(BSmsg&1), msg = EFsts, code = EMS_E_BSerror,
      str = "EFrotate_plane : MAoptsxform error",  action = GOTO_VALUE,
      value = wrapup );

  BSnorvec( &BSmsg, new_normal);
 
wrapup :
  return EFsts;
}

IGRboolean  EFare_planes_same(
IGRdouble   *point1,
IGRdouble   *normal1,
IGRdouble   *point2, 
IGRdouble   *normal2 )
{
  BSrc       BSmsg;
  IGRdouble  cross_vec[3], cross_sqtol;
  IGRboolean same = FALSE;

  BSEXTRACTPAR( &BSmsg, BSTOLLENVEC, cross_sqtol );

  BScrossp( &BSmsg, normal1, normal2, cross_vec );

  if( BSlenvecsq( &BSmsg, cross_vec ) < cross_sqtol )
  {
     IGRdouble  vec[3], lentol;

     BSmkvec( &BSmsg, vec, point1, point2 );
     BSEXTRACTPAR( &BSmsg, BSTOLLENVEC, lentol );

     if( fabs(BSdotp( &BSmsg, vec, normal1)) < lentol )
       same = TRUE;
  }

  return same;
}

IGRint EFmindist_point_index( 
IGRint num_pts,   
IGRdouble *pts,
IGRdouble *range)
{
  BSrc    BSmsg=BSSUCC;
  IGRint  i=0, j=0, k=0, index=0;
  IGRdouble dist=0, mindist=MAXDOUBLE;

  for( i=0; i<num_pts; i++ )
  {
    k = i*3;
    for( j=0; j<2; j++ )
    {
      if( (dist = BSdistptpts( &BSmsg, &pts[k], &range[j*3] )) < mindist )
      {
        mindist = dist;
        index = i;
      }
    }
  }

  return index;
}

IGRlong EFpoint_on_circle_at_angle( 
IGRdouble *center, 
IGRdouble *normal, 
IGRdouble *stpoint, 
IGRdouble angle,
IGRdouble *point )
{
  IGRboolean BSsts;
  IGRshort   xform_mattyp;
  IGRlong    BSmsg, npts=1, EFsts;
  IGRdouble  radians;
  IGRmatrix  xform_mat;

  EFsts = OM_S_SUCCESS;

  MAdegrad( &BSmsg, &angle, &radians );

  BSsts = MAgrotmx( &BSmsg, normal, center, &radians, xform_mat );
  add$status( test = !BSsts || !(BSmsg&1), msg = EFsts, code = EMS_E_BSerror,
      str = "EFrotate_plane : MAgrotmx error",  action = GOTO_VALUE,
      value = wrapup );

  BSsts = MAtypemx( &BSmsg, xform_mat, &xform_mattyp );

  BSsts = MAoptsxform( &BSmsg, &npts, &xform_mattyp, xform_mat, stpoint,
                       point);
  add$status( test = !BSsts || !(BSmsg&1), msg = EFsts, code = EMS_E_BSerror,
      str = "EFrotate_plane : MAoptsxform error",  action = GOTO_VALUE,
      value = wrapup );

wrapup :
  return EFsts;
}

IGRlong EFget_revsurf_range_box_from_profile
(
  struct IGRplane *prof_plane,
  IGRdouble       *prof_range,
  IGRdouble       *axis_ends,
  IGRdouble       *slrange 
)
{
  BSrc        BSmsg;
  IGRint      i, type=0;
  IGRlong     sts=OM_S_SUCCESS, num_poles=0;
  IGRpoint    pt, xpt, ypt, pt1, pt2, x_vec, y_vec, line[2], xprojpt, yprojpt;
  IGRboolean  BSsts, full=TRUE;
  IGRdouble   new_axis_ends[6], new_prof_range[6], d1, d2;
  struct IGRbsp_curve *curve = NULL;
  struct IGRbsp_surface *surf = NULL;

  /* Project the axis_ends on to the plane of the profile */
  BSsts = BSproj1( &BSmsg, &axis_ends[0], prof_plane->normal, 
                   prof_plane->point, &new_axis_ends[0] );
  BSsts = BSproj1( &BSmsg, &axis_ends[3], prof_plane->normal, 
                   prof_plane->point, &new_axis_ends[3] );
  add$status( test = !BSsts || BSERROR(BSmsg), msg = sts, code = EMS_E_BSerror,
      str = "EFget_revsurf_range_box_from_profile : BSproj1 error",
      action = GOTO_VALUE, value = wrapup );

  /* Project the range box limits on to the profile plane */
  BSsts = BSproj1( &BSmsg, &prof_range[0], prof_plane->normal, 
                   prof_plane->point, &new_prof_range[0] );
  BSsts = BSproj1( &BSmsg, &prof_range[3], prof_plane->normal, 
                   prof_plane->point, &new_prof_range[3] );
  add$status( test = !BSsts || BSERROR(BSmsg), msg = sts, code = EMS_E_BSerror,
      str = "EFget_revsurf_range_box_from_profile : BSproj1 error",
      action = GOTO_VALUE, value = wrapup );

  /* Get the orthogonal vector of the profile normal */
  BSsts = BSorthovec( &BSmsg, prof_plane->normal, x_vec );
  add$status( test = !BSsts || BSERROR(BSmsg), msg = sts, code = EMS_E_BSerror,
      str = "EFget_revsurf_range_box_from_profile : BSorthovec error",
      action = GOTO_VALUE, value = wrapup );
 
  /* Get the cross product of the profile normal and its orthogonal vector */
  BSsts = BScrossp( &BSmsg, prof_plane->normal, x_vec, y_vec );
  BSnorvec( &BSmsg, y_vec );

  /* Select the points */
  BSsts = BSdistptli( &BSmsg, &new_prof_range[0], &new_axis_ends[0], 
                      &new_axis_ends[3], &d1 );  
  BSsts = BSdistptli( &BSmsg, &new_prof_range[3], &new_axis_ends[0], 
                      &new_axis_ends[3], &d2 );
  add$status( test = !BSsts || BSERROR(BSmsg), msg = sts, code = EMS_E_BSerror,
      str = "EFget_revsurf_range_box_from_profile : BSdistptli error",
      action = GOTO_VALUE, value = wrapup );

  if( d1 > d2 ) 
  {
    OM_BLOCK_MOVE( &new_prof_range[0], pt1, sizeof(IGRpoint) );
    OM_BLOCK_MOVE( &new_prof_range[3], pt, sizeof(IGRpoint) );
  }
  else
  {
    OM_BLOCK_MOVE( &new_prof_range[3], pt1, sizeof(IGRpoint) );
    OM_BLOCK_MOVE( &new_prof_range[0], pt, sizeof(IGRpoint) );
  }

  for(i=0; i<3; i++ )
  {
     xpt[i] = pt1[i] + x_vec[i];
     ypt[i] = pt1[i] + y_vec[i];
  }
 
  OM_BLOCK_MOVE( pt1, line[0], sizeof(IGRpoint) ); 
  OM_BLOCK_MOVE( xpt, line[1], sizeof(IGRpoint) ); 
  BSproj0( &BSmsg, pt, line, xprojpt );
  OM_BLOCK_MOVE( ypt, line[1], sizeof(IGRpoint) ); 
  BSproj0( &BSmsg, pt, line, yprojpt );

  BSsts = BSdistptli( &BSmsg, xprojpt, &new_axis_ends[0],
                      &new_axis_ends[3], &d1 );
  BSsts = BSdistptli( &BSmsg, yprojpt, &new_axis_ends[0],
                      &new_axis_ends[3], &d2 );
  add$status( test = !BSsts || BSERROR(BSmsg), msg = sts, code = EMS_E_BSerror,
      str = "EFget_revsurf_range_box_from_profile : BSdistptli error",
      action = GOTO_VALUE, value = wrapup );

  if( d1 > d2 )
    OM_BLOCK_MOVE( xprojpt, pt2, sizeof(IGRpoint) );
  else
    OM_BLOCK_MOVE( yprojpt, pt2, sizeof(IGRpoint) );

  BSalloccv((IGRshort) 2, (IGRlong)2, FALSE, 0, &curve, &BSmsg ); 
  BSsts = BSptlngen( &BSmsg, pt1, pt2, curve, &type );

  BSallocsf( (IGRshort)2, BSCIRCLE_ORDER, (IGRlong) 2, BSCIRCLE_NUM_POLES_MAX,
             TRUE, 0, &surf, &BSmsg );
  BSsts = BSsf_rev(&BSmsg, &new_axis_ends[0], &new_axis_ends[3], curve, &full,
                   NULL, NULL, surf );
  add$status( test = !BSsts || BSERROR(BSmsg), msg = sts, code = EMS_E_BSerror,
      str = "EFget_revsurf_range_box_from_profile : BSsf_rev error",
      action = GOTO_VALUE, value = wrapup );

  num_poles = surf->u_num_poles * surf->v_num_poles;

  BSbx2( &BSmsg, &num_poles, surf->poles, surf->weights, &slrange[0], 
         &slrange[3] );
  add$status( test = !BSsts || BSERROR(BSmsg), msg = sts, code = EMS_E_BSerror,
      str = "EFget_revsurf_range_box_from_profile : BSbx2 error",
      action = GOTO_VALUE, value = wrapup );

wrapup :   
  if(curve) BSfreecv( &BSmsg, curve );
  if(surf)  BSfreesf( &BSmsg, surf );
  return sts;
}

IGRboolean  GetSecondarySolidInfo 
(
IGRlong               *EFmsg, 
IGRlong               options,
IGRlong               solopts,
struct ModProfileInfo *prof_info,
struct GRid           *sec_slgrid,
struct GRmd_env       *slenv,
struct SkinSurfInfo   *skin_info, 
struct SecSolidInfo   *sec_slinfo
)
{
  IGRint          num_comps=0, i=0, num_v_surfs=0, *surfs_index=NULL;
  IGRlong         sts = OM_S_SUCCESS, loc_msg = EMS_S_Success;
  GRobjid         *comps=NULL, surfid, *surfs_id=NULL;
  OMuword         os;
  IGRpoint        pt, projpt;
  IGRdouble       *parms=NULL, ENDS[6];
  IGRboolean      ok = TRUE;
  struct GRparms  projparms;
  struct GRmd_env *envcv;
  OM_S_CHANSELECT to_components;

  *EFmsg = EMS_S_Success;
  os = sec_slgrid->osnum;

  EMmake_chanselect (GRcmpowner_to_components, &to_components);

  memset (sec_slinfo, 0, sizeof(struct SecSolidInfo));

  sec_slinfo->grid = *sec_slgrid;
  
  num_comps = GetObjectNumCompsOnChannel (sec_slgrid->objid, sec_slgrid->osnum,
                                          &to_components);
  if (!prof_info)
  {
    sec_slinfo->capsurfs_id[0] = GetObjectAtIndexOnChannel (sec_slgrid->objid, 
                                            sec_slgrid->osnum, (num_comps-1),
                                            &to_components);
    sec_slinfo->capsurfs_id[1] = GetObjectAtIndexOnChannel (sec_slgrid->objid, 
                                            sec_slgrid->osnum, (num_comps-2),
                                            &to_components);
    goto wrapup;
  }

  envcv = &prof_info->mdenv;

  comps = (GRobjid *) alloca (num_comps * sizeof(GRobjid));
  add$status (test = !comps, msg = *EFmsg, code = EMS_E_NoDynamicMemory,
      str = "GetSecondarySolidInfo : Insufficient Memory", 
      action = GOTO_VALUE, value = wrapup);
 
  ok = GetObjectCompsOnChannel (sec_slgrid->objid, sec_slgrid->osnum, 
                                num_comps, &to_components, comps);
  add$status (test = !ok, msg = *EFmsg, code = EMS_E_Fail,
      str = "GetSecondarySolidInfo : Insufficient Memory", 
      action = GOTO_VALUE, value = wrapup);

  if (options & SecSolid_NoCaps)
  {
    sec_slinfo->capsurfs_id[0] = NULL_OBJID;
    sec_slinfo->capsurfs_id[1] = NULL_OBJID;
  }
  else if (options & SecSolid_OneCap)
  {
    sec_slinfo->capsurfs_id[0] = comps[num_comps-1];
    sec_slinfo->capsurfs_id[1] = NULL_OBJID;
  }
  else
  {
    sec_slinfo->capsurfs_id[0] = comps[num_comps-1];
    sec_slinfo->capsurfs_id[1] = comps[num_comps-2];
  }

  if (solopts & EMSfeature_skinned)
  {
    IGRint      j, index; 
    IGRdouble   chttol, dist, mindist=MAXDOUBLE;

    BSEXTRACTPAR(&loc_msg, BSTOLCHRDHT, chttol);

    num_v_surfs = skin_info->nsplit_v - 1;
    surfs_index = (int *) om$malloc (size = num_v_surfs * 2 *sizeof(int));
    surfs_id = (GRobjid *) om$malloc (size = num_v_surfs * 2 *sizeof(GRobjid));
    parms = (IGRdouble *) om$malloc (size = num_v_surfs * 4 * sizeof(double));

    for (i=0; i<2; i++)
    {
      mindist = MAXDOUBLE;
      index = prof_info->parms[i].index;
      OM_BLOCK_MOVE (prof_info->parms[i].pt, pt, sizeof(IGRpoint)); 
      surfid = skin_info->split_surfs[index];

      do
      {
        surfid = skin_info->split_surfs[index];

        sts = om$send (msg = message GRgraphics.GRptproject (&loc_msg,
                                     &slenv->md_env.matrix_type,
                                     slenv->md_env.matrix, pt, projpt,
                                     &projparms),
                       senderid = surfid,
                       targetid = surfid,
                       targetos = os);
        add$status (test = !(1&sts&loc_msg), msg = *EFmsg, code = EMS_E_Fail,
            str = "GetSecondarySolidInfo : GRgraphics.GRptproject error",
            action = GOTO_VALUE, value = wrapup);
  
        dist = BSdistptpt(&loc_msg, pt, projpt);

        if (dist < mindist)
        {
          surfs_id[i] = surfid; 
          surfs_index[i] = index;

          if (i)
          {
            parms[2] = 0.0;
            parms[3] = projparms.u;
          }
          else
          {
            parms[0] = projparms.u;
            parms[1] = 1.0;
          }

          mindist = dist;
        }

        index ++; 

      }while ((dist > 10*chttol) && index < skin_info->nsplit_u );

#ifdef DEBUG
  if (index > skin_info->nsplit_u)
   printf ("AddRm Msg: Problem in getting the secondary solid info.\n");
#endif
 
    }

    for (i=1; i<num_v_surfs; i++)
    {
      for (j=0; j<2; j++)
      {
        index = surfs_index [(i-1)*2+j] + skin_info->nsplit_u;

        surfs_index [i*2+j] = index;
        surfs_id [i*2+j] = skin_info->split_surfs[index];
        OM_BLOCK_MOVE (&parms[(i-1)*4 + j*2], &parms[i*4 + j*2], 
                       2*sizeof(double));
      }
    }
  }

  else

  {
    num_v_surfs = 1;
    surfs_index = (IGRint *) om$malloc (size = 2 * sizeof(IGRint));
    surfs_id = (GRobjid *) om$malloc (size = 2 * sizeof(GRobjid));
    parms = (IGRdouble *) om$malloc (size = num_v_surfs * 4 * sizeof(double));

    for (i=0; i<2; i++)
    {
      surfid = comps [prof_info->parms[i].index];
      OM_BLOCK_MOVE (prof_info->parms[i].pt, pt, sizeof(IGRpoint)); 

      sts = om$send (msg = message GRgraphics.GRptproject (&loc_msg, 
                                   &slenv->md_env.matrix_type, 
                                   slenv->md_env.matrix, pt, projpt,
                                   &projparms), 
                     senderid = surfid,
                     targetid = surfid,
                     targetos = os);
      add$status (test = !(1&sts&loc_msg), msg = *EFmsg, code = EMS_E_Fail,
          str = "GetSecondarySolidInfo : GRgraphics.GRptproject error",
          action = GOTO_VALUE, value = wrapup);

      surfs_id[i] = surfid;
      surfs_index[i] = prof_info->parms[i].index;
  
      if (i)
      {
        parms[i*2+1] = projparms.u;
      }
      else
      {
        parms[i*2]   = projparms.u;
      }

      /* 
       * get the other end point of the same segment and project it on to the
       * surface 
       */
      if (prof_info->parms[0].index == prof_info->parms[1].index)
      {
        surfid = comps [prof_info->parms[1].index];
        OM_BLOCK_MOVE (prof_info->parms[1].pt, pt, sizeof(IGRpoint)); 
        surfs_id[1] = surfid;
        surfs_index[1] = prof_info->parms[1].index;
      }
      else
      {
        sts = om$send (msg = message GRcurve.GRendpts (&loc_msg, 
                                     &envcv->md_env.matrix_type, 
                                     envcv->md_env.matrix, &ENDS[0], 
                                     &ENDS[3]),
                       senderid = prof_info->parms[i].id, 
                       targetid = prof_info->parms[i].id, 
                       targetos = os );
        add$status (test = !(1&sts&loc_msg), msg = *EFmsg, code = EMS_E_Fail,
            str = "GetSecondarySolidInfo : GRcurve.GRendpts error",
            action = GOTO_VALUE, value = wrapup);

        if (i)
          OM_BLOCK_MOVE(&ENDS[0], pt, sizeof(IGRpoint));
        else
          OM_BLOCK_MOVE(&ENDS[3], pt, sizeof(IGRpoint));
      }

      sts = om$send (msg = message GRgraphics.GRptproject (&loc_msg,
                                   &slenv->md_env.matrix_type,
                                   slenv->md_env.matrix, pt, projpt,
                                   &projparms),
                     senderid = surfid,
                     targetid = surfid,
                     targetos = os);
      add$status (test = !(1&sts&loc_msg), msg = *EFmsg, code = EMS_E_Fail,
          str = "GetSecondarySolidInfo : GRgraphics.GRptproject error",
          action = GOTO_VALUE, value = wrapup);

      if (i)
      {
        parms[i*2] = projparms.u;
      }
      else
      {
        parms[i*2+1]   = projparms.u;
      }

      if (prof_info->parms[0].index == prof_info->parms[1].index) 
        break;
    }
  }

  sec_slinfo->num_v_surfs = num_v_surfs;
  sec_slinfo->surfs_index = surfs_index;
  sec_slinfo->surfs_id = surfs_id;
  sec_slinfo->parms = parms;
   
wrapup : 

  if (!(1&*EFmsg))
    return FALSE;
  else
    return TRUE;
}

static void GetStartAndSweepAngles
(
  IGRdouble from_int_angs[2],
  IGRdouble to_int_angs[2],
  IGRdouble *start_ang,
  IGRdouble *sweep_ang,
  IGRdouble *svsd_ang,
  double    tol
)
{
  BSrc rc=BSSUCC;
  IGRint sort_ind[4], num_values=0;
  IGRdouble from_angs[2], to_angs[2], values[4];
  IGRboolean overlap=FALSE;

  *start_ang = 0.0;
  *sweep_ang = 360.0;
  *svsd_ang = 0.0;

  OM_BLOCK_MOVE (from_int_angs, from_angs, 2 * sizeof (IGRdouble));
  OM_BLOCK_MOVE (to_int_angs, to_angs, 2 * sizeof (IGRdouble));

  if (from_angs[0] < tol || fabs (360.0 - from_angs[0]) < tol)
  {
    if (from_angs[1] < 180.0)
    {
      if (fabs (360.0 - from_angs[0]) < tol)
        from_angs[0] = fabs (360.0 - from_angs[0]);
    }
    else
    {
      if (from_angs[0] < tol)
        from_angs[0] = (360.0 - from_angs[0]);
    }
  }
  else if (from_angs[1] < tol || fabs (360.0 - from_angs[1]) < tol)
  {
    if (from_angs[0] < 180.0)
    {
      if (fabs (360.0 - from_angs[1]) < tol)
        from_angs[1] = fabs (360.0 - from_angs[1]);
    }
    else
    {
      if (from_angs[1] < tol)
        from_angs[1] = (360.0 - from_int_angs[1]);
    }
  }

  if (to_angs[0] < tol || fabs (360.0 - to_angs[0]) < tol)
  {
    if (to_angs[1] < 180.0)
    {
      if (fabs (360.0 - to_angs[0]) < tol)
        to_angs[0] = fabs (360.0 - to_angs[0]);
    }
    else
    {
      if (to_angs[0] < tol)
        from_int_angs[0] = (360.0 - to_angs[0]);
    }
  }
  else if (to_angs[1] < tol || fabs (360.0 - to_angs[1]) < tol)
  {
    if (to_angs[0] < 180.0)
    {
      if (fabs (360.0 - to_angs[1]) < tol)
        to_angs[1] = fabs (360.0 - to_angs[1]);
    }
    else
    {
      if (to_angs[1] < tol)
        to_angs[1] = (360.0 - to_angs[1]);
    }
  }

  num_values = 4;
  OM_BLOCK_MOVE (from_angs, values, 2 * sizeof (IGRdouble));
  OM_BLOCK_MOVE (to_angs, &values[2], 2 * sizeof (IGRdouble));
 
  BStagsort (&rc, &num_values, values, sort_ind);

  if ((sort_ind[0] == 0 && sort_ind[1] == 1) || 
      (sort_ind[0] == 1 && sort_ind[1] == 0) ||
      (sort_ind[0] == 0 && sort_ind[3] == 1) ||
      (sort_ind[0] == 1 && sort_ind[3] == 0)) 
    overlap = FALSE;
  else
    overlap = TRUE;

  if (!overlap)
  {
    *start_ang = (from_angs[0] + from_angs[1]) / 2.0 - 360.0;
    *sweep_ang = (to_angs[0] + to_angs[1]) / 2.0 - (*start_ang);
  }
  else
  {
    *start_ang = (values[sort_ind[3]] + values[sort_ind[2]]) / 2.0 - 360.0;
    *sweep_ang = (values[sort_ind[0]] + values[sort_ind[1]]) / 2.0 - (*start_ang);
  }

  return;
}
 
end implementation Root;
