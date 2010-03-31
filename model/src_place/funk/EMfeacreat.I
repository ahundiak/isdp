 /*
 * This function does the actual construction of add/remove material feature.
 */


 /*
  * Abstract:
  * ---------
  *    This function does the actual construction of Add/Remove Material 
  *    Feature.
  *
  * Synopsis:
  * ---------
  * IGRlong               *msg            I  Return status 
  * IGRlong               matopts,        I  AddMaterial/RemoveMaterial
  * IGRlong               solopts,        I  Projected/Revolved/Skinned
  * IGRlong               feaopts,        I  ToNext/ThruNext/Finite/FromTo/
  *                                          Symmetric
  * struct GRid           *profid,        I  Profile GRid
  * struct GRmd_env       *modenvcv,      I  ModuleEnv of Profile
  * IGRboolean            reversed,       I  Whether the profile is need to be 
  *                                          reversed while closing and this 
  *                                          indicates the material addition 
  *                                          direction.
  * struct GRid           *from_surf_id,  I  From Surface Grid in FromTo Option
  *                                          otherwise NULL.
  * struct GRid           *to_surf_id,    I  To Surface GRid in FromTo Option 
  *                                          otherwise NULL.
  * struct GRmd_env       *modenvsf,      I  ModuleEnv of From To Surfaces.
  * struct GRid           *base_solid_id, I  Base solid GRid.
  * IGRdouble             *start_dist,    I  In Projected/Finite the start 
  *                                          distance
  * IGRdouble             *proj_dist,     I  In Projected/Finite the projection
  *                                          distance
  * IGRdouble             *projection_vec,I  In Projected the projection vector
  * IGRdouble             *start_angle,   I  In Revolved/Finite the start angle
  * IGRdouble             *sweep_angle,   I  In Revolved/Finite the sweep angle
  * IGRdouble             *axis_ends,     I  In Revolved rotational axis ends
  * struct TraceInfo      *trace_info,    I  In Skinned the trace Curve GRid 
  *                                          and reversal bit.
  * struct GRvg_construct *const_args,    I  Construction List.
  * struct GRid           feature_object  O  Feature Object Created.
  *
  * Algorithm / Flow:
  * -----------------
  *   Step #1 : If the Profile is open, then close the profile.
  *
  *   Step #2 : Using the closed profile create secondary solid depending on
  *             the option. i.e. If Projected  -- Solid of Projection
  *                                 Revolved   -- Solid of Revolution
  *                                 Skinned    -- Skinning Solid
  *
  *   Step #3 : Perform Selective Boolean between the secondary solid created
  *             and the base solid which will keep the required trace groups.
  * 
  * HISTORY:
  * --------
  *
  *   Rustagi      08/02/93       Creation
  *   Sanjay       05/03/94       Added the call to the function "EFperform_
  *                               addrm_boolean" in place of "EFperform_spec
  *                               ial_boolean" as the functionality no more 
  *                               depends on the "Special Boolean". Also rem-
  *                               oved the call to function  "EMgen_rightsort
  *                               pts" as the sort points are no more more re-
  *                               quired because it is not dependent on Special
  *                               Boolean.
  *   Sanjay       06/06/94       Added the call to funciton "BScvtstclsd". See
  *                               the documentation for details.   
  *   Sanjay       06/16/94       Added the header and History Information.
  *
  */

class implementation Root;

#include <math.h>
#include "igrtypedef.h"
#include "igr.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "ex.h"
#include "exmacros.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "EMSmsgdef.h"
#include "ECmsg.h"
#include "emsdef.h"
#include "OMmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "emserr.h"
#include "EMSconstruct.h"
#include "EMSmsgdef.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSlogic.h"
#include "emsdattyp.h"
#include "EMSopt.h"
#include "emsinterdef.h"
#include "EMSprop.h"
#include "emsinter.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsfeaopts.h"
#include "EMSsfintsort.h"
#include "EMSasfeatdef.h"
#include "emsbool.h"
#include "emscvexten.h"

#include "bsnorvec.h"
#include "bscveval.h"
#include "bscvtstclsd.h"
#include "ma.h"
#include "madef.h"
#include "matrlmx.h"
#include "magrotmx.h"
#include "matypemx.h"
#include "malnxform.h"

#include "addprot.h"
#include "addrmopts.h"

#define OUTSIDE 0
#define INSIDE 1

/* imports */
from GRvg         import   GRdetplane;
from EMSsurface   import   EMgetactiveid;
from EMScompsurf  import   EMmovesurfs;
from EMSsfboolean import   EMboolean;

/* externs */
extern IGRboolean  ASbroadcast_in_progress;

extern OMuword OPP_SKgeometry_class_id, OPP_GAcurve_class_id,
               OPP_EMSslboolean_class_id, OPP_EMSgensolid_class_id;


extern IGRlong EMgetvggeom();
extern IGRboolean AddRmGetNormalOfPlaneOfPts();

#argsused
IGRlong EMcreate_add_rem_mat_feature(
IGRlong                             *msg,
IGRlong                             matopts,
IGRlong                             solopts,
IGRlong                             feaopts,
struct GRid                         *profid,
struct GRmd_env                     *modenvcv,
IGRboolean                          reversed,
struct GRid                         *from_surf_id,
struct GRid                         *to_surf_id,
struct GRmd_env                     *modenvsf,
struct GRid                         *base_solid_id,
IGRdouble                           *start_dist,
IGRdouble                           *proj_dist,
IGRdouble                           *projection_vec,
IGRdouble                           *start_angle,
IGRdouble                           *sweep_angle,
IGRdouble                           *axis_ends,
struct TraceInfo                    *trace_info,
struct GRvg_construct               *const_args,
struct GRid                         feature_object )
{
  IGRlong msg_loc=EMS_S_Success, sts=OM_S_SUCCESS;

  IGRint num_coinc_sfs=0, graph_type=0, NDsts=0, i=0, num_modprof=0, knt=0;
  GRobjid save_mdid=NULL_OBJID;
  IGRpoint pt, vec, pt1, vec1;
  IGRdouble lentol;

  IGRboolean save_ASbroadcast_in_progress, transform, ok=TRUE;
  IGRboolean projected, revolved, skinned, profopen=FALSE; 
  IGRboolean open_non_coplanar=FALSE; 

  struct GRid **coinc_sfs_grid=NULL, tra_profid; 
  struct GRprops cvprops;
  struct IGRplane prof_plane;
  enum EMSbooltype bool_type;
  struct ProfileInfo prof_info;

  IGRushort bool_opts=0;
  IGRvector NORMAL;
  struct ModProfileInfo *modprof_info=NULL, *p_modprof_info=NULL;
  struct SecSolidInfo secsolid_info, *loc_secsolid_info=NULL;
  struct IGRbsp_curve *profgeom=NULL;
  
  /* 
   * Initialize the return status 
   */
  sts = OM_S_SUCCESS;
  *msg = EMS_S_Success;
  msg_loc = EMS_S_Success;

  /*
   * Initialize the local variables 
   */ 
  secsolid_info.grid.objid = NULL_OBJID;
  secsolid_info.grid.osnum = profid->osnum;
  tra_profid.objid = NULL_OBJID;
  tra_profid.osnum = profid->osnum;
  num_coinc_sfs = 0;
  coinc_sfs_grid = NULL;
  prof_plane.point = pt; prof_plane.normal = vec;
  prof_info.plane.point = pt1; prof_info.plane.normal = vec1;

  memset (&secsolid_info, 0, sizeof(struct SecSolidInfo));

  projected = (solopts & EMSfeature_projected) ? TRUE : FALSE;
  revolved  = (solopts & EMSfeature_revolved)  ? TRUE : FALSE;
  skinned   = (solopts & EMSfeature_skinned)   ? TRUE : FALSE;

  BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, lentol);

  /*
   * check whether the incoming feature object is already in the graph or
   * not, if it is already there in the graph means, feature is getting 
   * created from recompute and if not from the command object.
   */
  save_ASbroadcast_in_progress = ASbroadcast_in_progress;

  NDsts = nd$get_type( nb_obj = (IGRint) 1, p_object = &feature_object, 
                     p_type = &graph_type );

  /* 
   * If the return status is false, the feature object is not in the graph,
   * set the ASbroadcast_in_progress flag FALSE, otherwise set it to TRUE. 
   * Reset this flag at the end of the process.
   */
  if( !NDsts )
    ASbroadcast_in_progress = FALSE;
  else 
    ASbroadcast_in_progress = TRUE;

  ASbroadcast_in_progress = TRUE;

  /*
   * Get the profile normal.
   */
  ok = GetCvOrSfPlane (profid->objid, profid->osnum, modenvcv, &prof_plane);
  add$status( test = !ok, msg = *msg, code = EMS_E_Fail,
      str = "EMcreate_add_rem_mat_feature : GRvg.GRdetplane error",
      action = GOTO VALUE, value = ret_end );

  /*
   * get the right profile normal
   */
  sts = EMgetvggeom (&msg_loc, &modenvcv->md_env.matrix_type,
                     modenvcv->md_env.matrix, profid, &profgeom, NULL);
  add$status( test = !(1 & sts &msg_loc), msg = *msg, code = EMS_E_Fail,
      str = "EMcreate_add_rem_mat_feature : EMgetvggeom error",
      action = GOTO VALUE, value = ret_end );

  if (!EFisAncestryValid (&msg_loc, profid->objid, profid->osnum, 
                          OPP_SKgeometry_class_id, TRUE) &&
      !EFisAncestryValid (&msg_loc, profid->objid, profid->osnum, 
                          OPP_GAcurve_class_id, TRUE)) 
  {
    if (AddRmGetNormalOfPlaneOfPts (profgeom->num_poles, profgeom->poles,
                  profgeom->rational ? profgeom->weights : NULL, NORMAL))
      OM_BLOCK_MOVE (NORMAL, prof_plane.normal, sizeof(IGRvector));
    else if (OM_Gf_verbose_warning)
      printf("\nAddRm Msg: Unable to calculate the right profile normal\n");
  }

  /*
   * If the feature is finite and projected/revolved and if start dist/angle
   * is provided then translate/rotate the profile to the start dist/angle.
   */
  transform = (feaopts & EMSfeature_finite) ? 
              ( (projected && start_dist && (fabs(*start_dist) > lentol)) ||
                (revolved && start_angle && (fabs(*start_angle) > lentol)) ) 
              : FALSE;

  if( transform ) 
  {
    IGRmatrix   xform_mat;
    IGRshort    xform_mattyp;
    IGRvector   xform_vec, tpt1, tpt2, tpt3, tpt4;
    IGRboolean  bssts;
    struct IGRline line, out_line;

    line.point1 = tpt1; line.point2 = tpt2;
    out_line.point1 = tpt3; out_line.point2 = tpt4;

    /*
     * copy the profile.
     */
    ok = CopyObject( profid->objid, profid->osnum, modenvcv, 
                     &tra_profid.objid );
    add$status( test = !ok, msg = *msg, code = EMS_E_Fail,
        str = "EMcreate_add_rem_mat_feature : CopyObject error",
        action = GOTO VALUE, value = ret_end );

    /*
     * Form the transformation matrix 
     */
    if( projected )
    {
      for(i=0; i<3; i++) 
         xform_vec[i] = prof_plane.normal[i] * (*start_dist);

      bssts = MAtrlmx( &msg_loc, xform_vec, xform_mat);
      add$status( test = !bssts || !(1&msg_loc), msg = *msg, 
          code = EMS_E_BSerror, str = "EMcreate_add_rem_mat_feature : MAtrlmx error",
           action = GOTO VALUE, value = ret_end );

    }
    else if( revolved )
    {
      IGRdouble  start_angle_rad;

      for(i=0; i<3; i++)
         xform_vec[i] = axis_ends[i+3] - axis_ends[i];

      BSnorvec( &msg_loc, xform_vec );

      MAdegrad( &msg_loc, start_angle, &start_angle_rad );

      bssts = MAgrotmx( &msg_loc, xform_vec, &axis_ends[0], &start_angle_rad,
                        xform_mat );
      add$status( test = !bssts || !(1&msg_loc), msg = *msg, 
          code = EMS_E_BSerror, str = "EMcreate_add_rem_mat_feature : MAtrlmx error",
           action = GOTO VALUE, value = ret_end );
    }

    bssts = MAtypemx(&msg_loc, xform_mat, &xform_mattyp );

    /*
     * transform the profile.
     */
    ok = XformObject( tra_profid.objid, tra_profid.osnum, modenvcv, 
                      &xform_mattyp, xform_mat, &tra_profid.objid );
    add$status( test = !ok, msg = *msg, code = EMS_E_Fail, 
        str = "EMcreate_add_rem_mat_feature : MAtrlmx error",
        action = GOTO VALUE, value = ret_end );

    /*
     * get the plane of the profile
     */
    OM_BLOCK_MOVE( prof_plane.point, line.point1, sizeof(IGRpoint) );
    for(i=0; i<3; i++)
       line.point2[i] = line.point1[i] + prof_plane.normal[i]; 

    bssts = MAlnxform( &msg_loc, &line, xform_mat, &out_line );
    add$status( test = !bssts || !(1&msg_loc), msg = *msg, 
        code = EMS_E_BSerror, str = "EMcreate_add_rem_mat_feature : MAlnxform error",
        action = GOTO VALUE, value = ret_end );

    OM_BLOCK_MOVE( out_line.point1, prof_plane.point, sizeof(IGRpoint) );
    for(i=0; i<3; i++)
       prof_plane.normal[i] = out_line.point2[i] - out_line.point1[i];
    BSnorvec( &msg_loc, prof_plane.normal );

  }
  else
  {
    tra_profid = *profid;
  }

  /*
   * Fill the profile info. 
   */
  prof_info.grid = tra_profid;
  OM_BLOCK_MOVE( modenvcv, &prof_info.mdenv, sizeof(struct GRmd_env) );
  OM_BLOCK_MOVE( prof_plane.point, prof_info.plane.point, sizeof(IGRpoint));
  OM_BLOCK_MOVE( prof_plane.normal, prof_info.plane.normal, 
                                                          sizeof(IGRvector));

  /*
   * Check whether the profile is closed or not ...
   *   One question always arises as to why should we check for whether
   *   the profile's closure when we are out finding this in the command
   *   object it self? We should always make it a point to remember that
   *   our functionality is associative, in which the user can edit the
   *   existing profile (by which One created the Add/Remove Mtl. Feature)
   *   and can make it open. So, Checking for the closure bit of the 
   *   profile will take care of the above situations. In such a case 
   *   the material addition direction will be calculated depending on the
   *   way the profile is running i.e. reversed argument in this case is
   *   always FALSE.  ---  Sanjay
   */  
  ok = GetObjectGeomProps(tra_profid.objid, tra_profid.osnum, modenvcv, 
                          &cvprops);
  add$status( test = !ok, msg = *msg, code = EMS_E_Fail,
      str = "EMcreate_add_rem_mat_feature : GetObjectGeomProps error",
      action = GOTO VALUE, value = ret_end );

  profopen = !cvprops.phy_closed;

  /*
   * STEP #1 :  CLOSE THE PROFILE  
   * ----------------------------
   */
  
  if(profopen)
  {
    ok = AddRmProcessProfile(&msg_loc, matopts, solopts, feaopts, reversed, 
              &prof_info, base_solid_id, modenvsf, projection_vec, 
              axis_ends, const_args, &bool_type, &num_modprof, &modprof_info);
    add$status( test = !ok, msg = *msg, code = msg_loc,
        str = "EMcreate_add_rem_mat_feature : AddRmProcessProfile : Profile Closure Error",
        action = GOTO VALUE, value = ret_end );
  }
  else
  {
    num_modprof = 1;
    modprof_info = (struct ModProfileInfo *) 
                           malloc (sizeof (struct ModProfileInfo));
    modprof_info->plane.point = (double *) malloc (sizeof (IGRpoint));
    modprof_info->plane.normal = (double *) malloc (sizeof (IGRvector));
    modprof_info->grid.objid = tra_profid.objid;
    modprof_info->grid.osnum = tra_profid.osnum;
    OM_BLOCK_MOVE (modenvcv, &modprof_info->mdenv, sizeof(struct GRmd_env));
    OM_BLOCK_MOVE (prof_plane.point, modprof_info->plane.point, 
                   sizeof(IGRpoint));
    OM_BLOCK_MOVE (prof_plane.normal, modprof_info->plane.normal, 
                   sizeof(IGRpoint));

    if(matopts & EMSremove_material)
      bool_type = EMSbool_difference;
    else
      bool_type = EMSbool_union;
  }


  if (num_modprof > 1)
  {
    loc_secsolid_info = (struct SecSolidInfo *) 
                        alloca (num_modprof * sizeof (struct SecSolidInfo));
    for (knt=0; knt<num_modprof; knt++)
    {
      memset (&loc_secsolid_info[knt], 0, sizeof (struct SecSolidInfo));
      loc_secsolid_info[knt].grid.objid = NULL_OBJID;
    }
  }
  else
  {
    loc_secsolid_info = &secsolid_info;
  }

  open_non_coplanar = (profopen && !(modprof_info[0].props & 
                                     ModProf_Coplanar)) ? TRUE : FALSE;

  /*
   * STEP #2 :  Creation of Secondary Solid
   * --------------------------------------
   */
  for (knt=0; knt<num_modprof; knt++)
  {
    p_modprof_info = open_non_coplanar ?  &modprof_info[knt] : NULL;
    prof_info.grid = modprof_info[knt].grid;
                        
    sts = EMcreate_secondary_solid(&msg_loc, solopts, feaopts, const_args,
            &prof_info, p_modprof_info, from_surf_id, to_surf_id, modenvsf,
            projection_vec, proj_dist, sweep_angle, axis_ends, trace_info,
            base_solid_id, &num_coinc_sfs, &coinc_sfs_grid, 
            &loc_secsolid_info[knt]); 

    if( msg_loc == EMS_E_AddRmNoIntFromSurf ||
        msg_loc == EMS_I_AddRmNoIntFromSurf )
    {
      fprintf(stderr, 
         "Add/Remove Msg: Feature does not intersect with FROM surface\n");
      ex$message( msgnumb = EMS_I_NoIntFromSurf );
      sleep( 1 );
    }
    else if( msg_loc == EMS_E_AddRmNoIntToSurf ||
             msg_loc == EMS_I_AddRmNoIntToSurf )
    {
      fprintf(stderr, 
        "Add/Remove Msg: Feature does not intersect with TO surface\n");
      ex$message( msgnumb = EMS_I_NoIntToSurf );
      sleep( 1 );
    }

    add$status( test = !(1&msg_loc&sts), msg = *msg, code = msg_loc,
        str = "EMcreate_add_rem_mat_feature : EMcreate_secondary_solid error",
        action = GOTO VALUE, value = ret_end );
  }

  if (num_modprof > 1)
  {
    int num_solids=0;
    GRobjid solid1, *solid2=NULL, boolsolid=NULL_OBJID;

    solid1 = loc_secsolid_info[0].grid.objid;
    num_solids = num_modprof - 1;
    solid2 = (GRobjid *) alloca (num_solids * sizeof (GRobjid));
    for (knt=0; knt<num_solids; knt++)
      solid2[knt] = loc_secsolid_info[knt+1].grid.objid;

    sts = om$construct (classid = OPP_EMSslboolean_class_id, 
             osnum = base_solid_id->osnum, p_objid = &boolsolid,
             msg = message EMSsfboolean.EMboolean (&msg_loc, 
             &modenvsf->md_env.matrix_type, modenvsf->md_env.matrix, 
             solid1, num_solids, solid2, const_args, EMSbool_union,
             EMSsfbool_opt_retryDisjoint, NULL, NULL, NULL, NULL, NULL)); 
    add$status( test = !(1&msg_loc&sts), msg = *msg, code = msg_loc,
        str = "EMcreate_add_rem_mat_feature : EMSsfboolean.EMboolean error",
        action = GOTO VALUE, value = ret_end );

    secsolid_info.grid.osnum = base_solid_id->osnum; 
    sts = om$construct (classid = OPP_EMSgensolid_class_id,
             osnum = base_solid_id->osnum, 
             p_objid = &secsolid_info.grid.objid);
    add$status( test = !(1&sts), msg = *msg, code = EMS_E_Fail,
        str = "EMcreate_add_rem_mat_feature : om$construct error",
        action = GOTO VALUE, value = ret_end );

    sts = om$send (msg = message EMScompsurf.EMmovesurfs (&msg_loc, 
                         &secsolid_info.grid, const_args->env_info),
                   senderid = boolsolid, targetid = boolsolid, 
                   targetos = base_solid_id->osnum);
    add$status( test = !(1&msg_loc&sts), msg = *msg, code = msg_loc,
        str = "EMcreate_add_rem_mat_feature : EMScompsurf.EMmovesurfs error",
        action = GOTO VALUE, value = ret_end );
  }
  
  /*
   * STEP #3 : Selective Boolean between Base solid and Secondary Solid
   * ------------------------------------------------------------------
   *  Instead of Calling EFperform_specail_boolean, we now call EFperform
   *  _addrm_boolean as the fucntionality now no more depends on the spl.
   *  boolean. --- Sanjay  
   */
  bool_opts = AddRm_Bool_DoubleCheck;
  if (profopen && (modprof_info[0].props & ModProf_Coplanar))
    bool_opts |= AddRm_Bool_NoSelective; 
  if (matopts & EMSadd_material)
    bool_opts |= AddRm_Bool_MaxSplitSecSolid;

  EFperform_addrm_boolean(&msg_loc, bool_opts, const_args, modenvsf,
            matopts, solopts, feaopts, bool_type, base_solid_id,
            &secsolid_info, num_coinc_sfs, coinc_sfs_grid, feature_object);
  if( (msg_loc == EMS_E_AddRmNoIntToNextSurf)  ||
      (msg_loc == EMS_I_AddRmNoIntToNextSurf) )
  {
    fprintf(stderr, 
      "Add/Remove Msg: Feature does not intersect with the TO NEXT surface\n");
    ex$message( msgnumb = EMS_I_NoIntToNextSurf );
    sleep( 1 );
  }
  else if( (msg_loc == EMS_E_AddRmInfinite)  ||
           (msg_loc == EMS_I_AddRmInfinite) )
  {
    fprintf(stderr, 
       "Add/Remove Msg: Operation results in infinite length/width solid\n"); 
    ex$message( msgnumb = EMS_I_Infinite );
    sleep( 1 );
  }
  else if ( (msg_loc == EMS_E_AddRmDisjoint) ||
            (msg_loc == EMS_I_AddRmDisjoint) )
  {
    fprintf(stderr, "Add/Remove Msg: Operation results in disjoint solid \n");
    ex$message( msgnumb = EMS_I_Disjoint );
    sleep( 1 );
  }
  
  add$status( test = !(1&msg_loc), msg = *msg, code = msg_loc,
      str = "EMcreate_add_rem_mat_feature : EFperform_addrm_boolean error",
      action = GOTO VALUE, value = ret_end );

  /*
   * In case of " Add Material / To Next ", both the endcaps should not be
   * there in the final solid. If both the endcaps are there in the final
   * solid means, there is To Next surface which is fully intersecting the
   * secondary solid. This results invalid feature. So, determine this 
   * situation and error out accordingly.
   */ 
  if ((matopts & EMSadd_material) && (feaopts & EMSfeature_to_next) &&
      projected)
  {
    IGRint cnt=0;
    IGRboolean error=TRUE;  
    struct GRid act_grid;

    for( cnt=0; cnt<2; cnt++ )
    {
     sts = om$send( msg = message EMSsurface.EMgetactiveid( &msg_loc,
                                  &act_grid, NULL ),
                    senderid = NULL_OBJID,
                    targetid = secsolid_info.capsurfs_id[cnt], 
                    targetos = feature_object.osnum );
       if( (!(1&sts&msg_loc)) || (act_grid.objid != feature_object.objid)
           || (act_grid.osnum != feature_object.osnum)  ) 
       {
           error = FALSE;
           break;
       }
    }

    if( error )
    {
      *msg = EMS_I_AddRmNoIntToNextSurf;
      ex$message( msgnumb = EMS_I_NoIntToNextSurf );
      sleep( 1 );
      goto ret_end;
    } 
 }

ret_end:

  EMWRAPUP( *msg, sts, "EMcreate_add_rem_mat_feature" );

  if (profopen && num_modprof)
  {
    /* 
     * If the profile is open, we must have created a new profile which is
     * closed. So, at the end of the processing we should delete it.
     */
    save_mdid = modenvcv->md_id.objid;
    // modenvcv->md_id.objid = NULL_OBJID;

    for (knt=0; knt<num_modprof; knt++)
    {
      if (modprof_info[knt].grid.objid != NULL_OBJID)
        DeleteObject (&modprof_info[knt].grid.objid, modenvcv);
    }

    modenvcv->md_id.objid = save_mdid;
  }

  if (!(1&sts&msg_loc) && secsolid_info.grid.objid != NULL_OBJID)
  {
    /*
     * If there is any failure and the secondary solid is already created
     * then we should delete it.
     */
     
    DeleteObject( &secsolid_info.grid.objid, modenvsf );
  }

  ASbroadcast_in_progress = save_ASbroadcast_in_progress;
  return(sts); 
}

end implementation Root;

