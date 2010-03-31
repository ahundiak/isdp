class implementation EMSsffeature;

/*
 * History
 * -------
 * NP       : ????????  Creation
 *
 * Rustagi  : 12/02/93  The dimension of the rib was not displayed correctly
 *                      and some time it was not displayed et. all due to
 *                      wromg dimensioning plane returned. Made this 
 *                      correction and re-shuffled some code. The changes
 *                      were made in "EMdimparam" method.
 *
 * NP       : 12/10/93  In the EMdeactivate method we are deleting ONLY the 
 *                      surfaces that have been added by the feature. We are NOT
 *                      deleting the feature node itself. Therefore removed 
 *                      check for option "EMS_UNDO_DONTDELME" in deciding 
 *                      whether to delete added geometry. In fact, if 
 *                      "EMS_UNDO_SAVE" is NOT set, it automatically implies 
 *                      delete.
 *
 * Sanjay   : 03/15/94  Modified the methods EMdim and EMdimparam to call 
 *                      different functions depending up on the feature type.
 *                      In this process created the following functions : 
 *                      EMdim_rib() : 
 *                                    Copied the code from EMdim method and 
 *                                    made a function.
 *                      EMdimparam_rib() : 
 *                                    Copied code from EMdim_param method and
 *                                    made a function
 *                      EMdim_addrmmtl :
 *                                    For Add/Remove Material auto dimensioning 
 *                                    This function is called from EMdim method
 *                                    and this will place appropriate dimension
 *                                    depending up on the solid type 
 *                      EMdimparam_addrmmtl : 
 *                                    This function call provides the all the 
 *                                    dimensioning parameters required for 
 *                                    auto dimensioning i.e. dimension plane,
 *                                    dimension x_axis, dimension geometry etc.
 *
 *                      Also in the process Modified the EMdim and EMdimparam
 *                      methods :
 *                            Now these methods call the appropriate functions
 *                            which will do the auto dimensioning depending on 
 *                            on the feature type
 */

#include "math.h"
#include "EMSopt.h"
#include "OMmacros.h"
#include "emsdef.h"
#include "EMSmsgdef.h"

#include "EMS.h"
#include "emserr.h"
#include "OMmacros.h"
#include "msdef.h"
#include "msmacros.h"

#include "dimdef.h"
#include "EMSasfeatdef.h"
#include "dimplcmacros.h"
#include "ECmsg.h"
#include "bserr.h"
#include "bscvnormal.h"

#define ABS(X) ((X) >= 0 ? (X) : -(X))


from expression import NDgive_value;
from EMSparamgm import EMgetgeom;

extern OMuword OPP_DMroot_class_id;

#include "EMSasfeatdef.h"
#include "msdef.h"
#include "msmacros.h"

/* my includes */
#include "emsfeaopts.h"
#include "bsparameters.h"
/*****#include "bscvmidpt.h"******/
#include "bscveval.h"
#include "bscvarrevt.h"
#include "bsnorvec.h"
#include "bsdotp.h"
#include "bsoffsetpt.h"
#include "bsdistptpt.h"

#include "REaddrmfea.h"
#include "EMSfeadef.h"
#include "parametric.h"
#include "bsconic.h"
#include "maptlnpro.h"
#include "madegrad.h"
#include "magrotmx.h"
#include "maptsxfor.h"
#include "bsarc_rot.h"
#include "bsprepcirc.h"
#include "maptplpro.h"

#define SMALL_VALUE      5

#define TEST_PARAMETER  0.3789  /* some arbitrary value. Usage of values like
                                 * 0.5, 0.75 etc. could lead to evaluation of
                                 * curve at sharp corners etc.
                                 */
#define PROFILE               0
#define PRJ_VECTOR            1
#define PRJ_START_DISTANCE    2
#define PRJ_DISTANCE          3

#define REV_AXIS_POINT        1
#define REV_AXIS_VECTOR       2
#define REV_START_ANGLE       3 
#define REV_SWEEP_ANGLE       4



IGRlong EMdim_rib(          IGRlong *, IGRchar *, struct GRid *, GRobjid );
  
IGRlong EMdim_addrmmtl(     IGRlong *, IGRchar *, struct GRid *, GRobjid );

IGRlong EMdimparam_rib(     IGRlong *, struct GRmd_env *, IGRushort , IGRint,
                            IGRchar *, IGRint, struct GRid *, IGRint ,
                            struct IGRplane *, IGRdouble *, 
                            struct EMSgeomdata *, IGRint *, GRobjid );

IGRlong EMdimparam_addrmmtl(IGRlong *, struct GRmd_env *, IGRushort , IGRint,
                            IGRchar *, IGRint, struct GRid *, IGRint ,
                            struct IGRplane *, IGRdouble *, 
                            struct EMSgeomdata *, IGRint *, GRobjid );

/******************************************************************************/

method EMgetsolidclass(IGRlong *EMmsg; IGRchar *desc)
{
  *EMmsg = EMS_S_Success;
  strcpy(desc, "EMSsffeature");
  return(OM_S_SUCCESS);
}

/******************************************************************************/

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
  IGRlong sts;

  sts  = OM_S_SUCCESS;
  *msg = EMS_S_Success;

   if (ME.EMSassoc->type == EMS_ASSOC_FEATURE_RIB)
   {
     ex$message(msgname = "EMSsffeature1", buff = info->type);
   }
   else if (ME.EMSassoc->type == EMS_ASSOC_FEATURE_ADD_MATERIAL)
   {
     ex$message(msgname = "EMSsffeature2", buff = info->type);
   }
   else if (ME.EMSassoc->type == EMS_ASSOC_FEATURE_REMOVE_MATERIAL)
   {
     ex$message(msgname = "EMSsffeature3", buff = info->type);
   }

  return(OM_S_SUCCESS);
}

/******************************************************************************/
/**
 PLAIN AND SIMPLE COPY OF DEACTIVATE OF EMSslboolfea class. We want our 
 overrides to be at the surface feature class, hence we have to do this. This
 will now be inherited by the EMSslfeatue class.
**/



method EMdeactivate(IGRlong *EMmsg;
                IGRshort *option;
                struct GRmd_env *env;
                GRobjid **display_ids;
                IGRint *display_count)
{
  IGRboolean  delete;
  IGRlong  sts;
  OM_S_CHANSELECT  to_comps;

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

  delete = ((*option & EMS_UNDO_SAVE)) ? FALSE : TRUE;

  sts = om$send(mode = OM_e_wrt_message,
                msg = message EMSsfboolean.EMdeactivate(EMmsg,
                option, env, display_ids, display_count),
                targetid = my_id);
  EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

  sts = om$make_chanselect(chanaddr = &ME.GRcmpowner->to_components,
                           p_chanselect = &to_comps);
  EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

  if ((*option & EMS_DO_DISPLAY) || delete)
  {
    enum GRdpmode  display_mode;
    /* erase all surfaces added by the feature */


    display_mode = GRbe;
    sts = om$send(msg = message GRgraphics.GRdisplay(EMmsg,
                &env->md_env.matrix_type,
                env->md_env.matrix, &display_mode,
                &env->md_id),
                p_chanselect = &to_comps,
                from = OM_K_MAXINT, to = 1);
    EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_OMerror, wrapup);
  }

  if(delete)
  {

    /* delete those surface that have been added by the feature */

    sts = om$send(msg = message GRgraphics.GRdelete(EMmsg, env),
                p_chanselect = &to_comps,
                from = OM_K_MAXINT, to = 1);
    EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

  } /* if */

wrapup:
  EMWRAPUP(*EMmsg, sts, "In EMSsffeature.EMdeactivate");
  return(sts);

} /* EMdeactivate */

/****************************************************************************/

/* 
   Notes : 
            This method calls the appropriate auto dimensioning 

   History : 
  
   ??????       NP          Creation
   03/15/94     Sanjay      Modified to call different functions depending on
                            assoc_type, because in future many features may 
                            subclass from EMSsffeature, there it will be very
                            useful. Moved the earlier code to a new function 
                            EMdim_rib() 
*/ 

method EMdim(IGRlong        *msg;
        struct GRmd_env     *mod_env;
        IGRushort           options;
        IGRint              type;
        IGRchar             *info;
        IGRint              num_parents;
        struct GRid         *parents )
{
   IGRlong sts;

   /*
    * Depending on the assoc type call the appropriate function to call the
    * appropriate auto dimensioning.
    */
   if( ME.EMSassoc->type == EMS_ASSOC_FEATURE_RIB )
   {
       sts = EMdim_rib( msg, info, parents, my_id );
   }
   else if( (ME.EMSassoc->type == EMS_ASSOC_FEATURE_ADD_MATERIAL) ||    
            (ME.EMSassoc->type == EMS_ASSOC_FEATURE_REMOVE_MATERIAL) )
   {
       sts = EMdim_addrmmtl( msg, info, parents, my_id );
   }

   EMWRAPUP(*msg, sts, "In EMSsffeature.EMdim");
   return(sts);
}

/*
   Notes :
          This function does the  auto-dimensiong for Rib feature.  

   History :
      
   03/15/94        Sanjay        Creation ( Moved the earlier code of 
                                            EMdim method to make it a 
                                            function )
*/

IGRlong EMdim_rib( IGRlong  *msg,
        IGRchar             *info,
        struct GRid         *parents ,
        GRobjid             your_id )
{ 
   IGRlong         sts;
   IGRint          depth_index, thk_index;
   struct GRid     dim_id, source_id, assoc_id;
   IGRpoint        dumpt;
   IGRint          trak_dir;
   IGRboolean      finite_rib, symmetric_rib;
   struct EMSfeature_data *feature_recomp_data; 

   /*
    * The parents that come in here are all the acutal parents of the rib, 
    * MINUS the state parent (the solid), which is connected at index 1. 
    * The array of parents being passed in therefore has the parents beyond 
    * index 1, shifted upward by one position (compared to their actual position
    * on the parent channel.
    *              
    * Order of parents coming in here is:
    *                
    * 0  - Profile
    * 1  - Thickness 
    * 2  - Flip thk side (ONLY IF NON_SYMMETRIC)
    * 3  - Flip proj side 
    * 4  - Depth (ONLY IF FINITE)
    *
    *    [- Base solid/surface (THIS PARENT NOT SENT IN)]
    */

   *msg = EMS_S_Success;
    sts = OM_S_SUCCESS;

   feature_recomp_data = (struct EMSfeature_data *) info;
   finite_rib     = feature_recomp_data->attributes & EMSfeature_finite;
   symmetric_rib  = feature_recomp_data->attributes & EMSfeature_symmetric;

   dumpt[0] = dumpt[1] = dumpt[2] = 0.0;
   assoc_id.objid = your_id;
   assoc_id.osnum = OM_Gw_current_OS;


   EFget_parent_source(&assoc_id, &source_id);

   /* Perform auto-dimensioning */
   thk_index = 1; 
   if(!(EFselect_first_component(&parents[thk_index], OPP_DMroot_class_id,
                   &dim_id) & 1)) 
   {
           dim_id.objid = NULL_OBJID;
           trak_dir = 0;
           dm$place_sglpara(orig_grid  = &source_id,
                           orig_pt     = dumpt,
                            plane_grid = &source_id,
                            trak_dir   = trak_dir,
                            owner      = &parents[thk_index],
                            dim_grid   = &dim_id);

           EMerr_hndlr(dim_id.objid == NULL_OBJID, *msg, EMS_E_Fail,
                   wrapup);
   }

   if (finite_rib)
   { 
     depth_index = (symmetric_rib? 3 : 4);

     if(!(EFselect_first_component(&parents[depth_index], OPP_DMroot_class_id,
                     &dim_id) & 1)) 
     {
             dim_id.objid = NULL_OBJID;
             trak_dir = 1;
             dm$place_sglpara(orig_grid  = &source_id,
                             orig_pt     = dumpt,
                              plane_grid = &source_id,
                              trak_dir   = trak_dir,
                              owner      = &parents[depth_index],
                              dim_grid   = &dim_id);
  
             EMerr_hndlr(dim_id.objid == NULL_OBJID, *msg, EMS_E_Fail,
                     wrapup);
     }
   }

   wrapup:

   EMWRAPUP(*msg, sts, "In EMdim_rib");
   return(sts);
}

/*
   Notes :
          This function calls the appropriate auto-dimensiong macro for 
          Add/Remove material feature depending on the solid type. 

   History :
      
   03/15/94        Sanjay        Creation  
*/

IGRlong EMdim_addrmmtl( IGRlong             *msg,
                        IGRchar             *info,
                        struct GRid         *parents,
                        GRobjid             your_id )
{
   IGRint                              parent_num, trak_dir;
   IGRlong                             sts; 
   IGRpoint                            dummy_pt;
   struct GRid                         dim_grid, source_grid, assoc_grid;
   struct EMSAddRm_RecompInfo          *recomp_info=NULL;

   /*
    * Initilize the local variable arguments and any incoming variables and
    * validate the arguments
    */
   sts = OM_S_SUCCESS;
   *msg = EMS_S_Success;
   dummy_pt[0] = dummy_pt[1] = dummy_pt[2] = 0;  
   if( !info || !parents )
   {
       *msg = EMS_E_InvalidArg;
       sts = EMS_E_Fail;
       goto wrapup;
   }

   /*
    * Check whether the feature is finite or not, if not goto wrapup 
    */
   recomp_info = (struct EMSAddRm_RecompInfo *) info;
   if( !(recomp_info->props & EMSAddRm_Finite) )
       goto wrapup;

   assoc_grid.objid = your_id; 
   assoc_grid.osnum = OM_Gw_current_OS;
   /* get the source id */
   EFget_parent_source( &assoc_grid, &source_grid );

   /*
    * The parents that come in here are all the acutal parents of the add /
    * remove material feature MINUS the state parent (the solid), which is 
    * connected at the last index.. 
    */
   if( recomp_info->props & EMSAddRm_Project )
   {
      if( !(EFselect_first_component( &parents[PRJ_DISTANCE], 
                                      OPP_DMroot_class_id, &dim_grid)) )
      {    
          dim_grid.objid = NULL_OBJID; 
          trak_dir = 1;
          dm$place_sglpara( orig_grid  = &source_grid,
                            orig_pt    = dummy_pt,
                            plane_grid = &source_grid,
                            trak_dir   = trak_dir,
                            owner      = &parents[PRJ_DISTANCE],
                            dim_grid   = &dim_grid );
         EMerr_hndlr( (dim_grid.objid == NULL_OBJID), *msg, EMS_E_Fail, wrapup);
      }
   }
   else if( recomp_info->props & EMSAddRm_Revolve )
   {
      IGRdouble  start_angle, sweep_angle;

      sts = om$send( msg = message expression.NDgive_value( &start_angle ),
                                   senderid = NULL_OBJID,
                                   targetid = parents[REV_START_ANGLE].objid,
                                   targetos = parents[REV_START_ANGLE].osnum );
      EMerr_hndlr( EMSerror(sts), *msg, EMS_E_Fail, wrapup );

      /*
       * if the start angle is not equal to zero and only if the dimension is
       * not yet placed, then place the dimension otherwise not.
       */
      if( (fabs(start_angle) > EMS_ZEROANGLE_DEG)  &&
          !(EFselect_first_component( &parents[REV_START_ANGLE], OPP_DMroot_class_id,
                                   &dim_grid)) )
      {    
         dim_grid.objid = NULL_OBJID; 
         trak_dir = 1;
         dm$place_sglarc_angle( orig_grid  = &source_grid,
                                orig_pt    = dummy_pt,
                                plane_grid = &source_grid,
                                trak_dir   = trak_dir,
                                owner      = &parents[REV_START_ANGLE],
                                dim_grid   = &dim_grid );
         EMerr_hndlr( (dim_grid.objid == NULL_OBJID), *msg, EMS_E_Fail, wrapup);
      }

      sts = om$send( msg = message expression.NDgive_value( &sweep_angle ),
                                   senderid = NULL_OBJID,
                                   targetid = parents[REV_SWEEP_ANGLE].objid,
                                   targetos = parents[REV_SWEEP_ANGLE].osnum );
      EMerr_hndlr( EMSerror(sts), *msg, EMS_E_Fail, wrapup );

      /*
       * if the sweep angle is not equal to 360 and only if the dimension is
       * not yet placed, then place the dimension otherwise not.
       */
      if( (fabs(sweep_angle - 360.0) > EMS_ZEROANGLE_DEG) &&
          !(EFselect_first_component( &parents[REV_SWEEP_ANGLE], OPP_DMroot_class_id,
                                   &dim_grid)) )
      {    
         dim_grid.objid = NULL_OBJID; 
         trak_dir = 1;
         dm$place_sglarc_angle( orig_grid  = &source_grid,
                                orig_pt    = dummy_pt,
                                plane_grid = &source_grid,
                                trak_dir   = trak_dir,
                                owner      = &parents[REV_SWEEP_ANGLE],
                                dim_grid   = &dim_grid );
         EMerr_hndlr( (dim_grid.objid == NULL_OBJID), *msg, EMS_E_Fail, wrapup);
      }
   }
   
wrapup : 
   return(sts); 
}


/****************************************************************************/
/* 
   Notes : 

   This method returns the geometry, plane & axis to the dimensioning macro.
   The macro calls this method about 8 times for each dimension placed. Two
   calls get only the plane and the plane x-axis, while the other six calls get
   the dim-type and the dim-geom. Therefore, the method calculates only
   what stuff is needed, to reduce overhead on calls that dont need certain 
   information.

   History : 
  
   ????????     NP          Creation
   03/15/94     Sanjay      Modified to call different functions depending on
                            assoc_type, because in future many features may 
                            subclass from EMSsffeature, there it will be very
                            useful. Moved the earlier code to a new function 
                            EMdimparam_rib() 
*/ 

method EMdimparam(IGRlong  *msg;
        struct GRmd_env    *mod_env;
        IGRushort  options;
        IGRint             type;
        IGRchar            *info;
        IGRint             num_parents;
        struct GRid        *parents;
        IGRint             index;
        struct IGRplane    *dim_plane;
        IGRdouble          *dim_plane_xaxis;
        struct EMSgeomdata *dim_geom;
        IGRint             *dim_type)
{
    IGRlong   sts;
   
    if( ME.EMSassoc->type == EMS_ASSOC_FEATURE_RIB )
    {
        sts = EMdimparam_rib( msg, mod_env, options, type, info, num_parents,
                              parents, index, dim_plane, dim_plane_xaxis, 
                              dim_geom, dim_type, my_id);
    }
    else if( ME.EMSassoc->type == EMS_ASSOC_FEATURE_ADD_MATERIAL ||
             ME.EMSassoc->type == EMS_ASSOC_FEATURE_REMOVE_MATERIAL )
    {
        sts = EMdimparam_addrmmtl( msg, mod_env, options, type, info, 
                                num_parents, parents, index, dim_plane,
                                dim_plane_xaxis, dim_geom, dim_type, my_id );
    } 

    EMWRAPUP(*msg, sts, "In EMSsffeature.EMdimparam");
    return(sts);
}

/*
   Notes :
          This function provides the dimensioning parameters required for 
          rib feature

   History :
      
   03/15/94        Sanjay        Creation ( Moved the earlier code of 
                                            EMdimparam method to make 
                                            it a function )
*/

IGRlong EMdimparam_rib(IGRlong  *msg,
        struct GRmd_env    *mod_env,
        IGRushort          options,
        IGRint             type,
        IGRchar            *info,
        IGRint             num_parents,
        struct GRid        *parents,
        IGRint             index,
        struct IGRplane    *dim_plane,
        IGRdouble          *dim_plane_xaxis,
        struct EMSgeomdata *dim_geom,
        IGRint             *dim_type,
        GRobjid            my_id )
{
IGRlong sts, msg_loc;
IGRint  i;
struct GRid  profile;
IGRdouble cht, *mat, cv_par, thickness, depth, dist;
IGRdouble flip_thk_side_value, flip_proj_side_value;
IGRshort mat_type;
struct IGRbsp_curve *curve_geom;
IGRlong size;
IGRpoint start_pt, end_pt, pt_on_profile, tangent_pts[1][2], dir_pt;
IGRpoint plane_point;
IGRvector unit_profile_tangent, unit_thk_vector, unit_proj_vector;
IGRvector  plane_normal, profile_plane_unit_normal, t_cross_n;
BSrc rc;
IGRboolean type1_rib, flip_thk_side, flip_proj_side;
IGRboolean success, finite_rib, symmetric_rib;
IGRboolean place_thk_dimension, place_depth_dimension;
struct EMSfeature_data *feature_recomp_data; 
struct IGRplane profile_plane;
IGRvector top, front, right, temp_vect;
IGRdouble result[3], temp=0.0;
IGRint store_ind;

 *msg = EMS_S_Success;
 sts = OM_S_SUCCESS;

 mat_type = mod_env->md_env.matrix_type;
 mat      = mod_env->md_env.matrix;
 
 BSEXTRACTPAR(&rc, BSTOLCHRDHT, cht);

 top[0]=0.0; top[1]=0.0; top[2]=1.0;
 front[0]=0.0; front[1]= -1.0; front[2]=0.0;
 right[0]=1.0; right[1]=0.0; right[2]=0.0;
 /*
  * The parents that come in here are all the acutal parents of the rib, 
  * MINUS the state parent (the solid), which is connected at index 1. 
  * The array of parents being passed in therefore has the parents beyond 
  * index 1, shifted upward by one position (compared to their actual position
  * on the parent channel.
  *              
  * Order of parents coming in here is:
  *                
  * 0   - Profile
  *
  *    [- Base solid/surface (THIS PARENT NOT SENT IN)]
  *
  * 1  - Thickness 
  * 2  - Flip thk side (ONLY IF NON_SYMMETRIC)
  * 3  - Flip proj side 
  * 4  - Depth (ONLY IF FINITE)
  */
 feature_recomp_data = (struct EMSfeature_data *) info;
 finite_rib     = feature_recomp_data->attributes & EMSfeature_finite;
 symmetric_rib  = feature_recomp_data->attributes & EMSfeature_symmetric;
 type1_rib      = !(feature_recomp_data->attributes &
                          EMSfeature_thickness_in_profile_plane);


 place_thk_dimension   = (index==1);
 place_depth_dimension = (symmetric_rib? (index==3) : (index==4));

 EMerr_hndlr(!place_thk_dimension && !place_depth_dimension,
                                    *msg, EMS_E_InvalidArg, wrapup);
 if(dim_type)
   *dim_type = SINGLE_PARALLEL;

 if(dim_plane || dim_plane_xaxis || dim_geom)
 {
 sts = om$send (msg = message expression.NDgive_value (&thickness),
             targetid = parents[1].objid,
             targetos = parents[1].osnum);
 EMerr_hndlr(!(1&sts), *msg, EMS_E_Fail, wrapup);
  
 if(!symmetric_rib)
  {
  sts = om$send (msg = message expression.NDgive_value (&flip_thk_side_value),
                  targetid = parents[2].objid,
                  targetos = parents[2].osnum);
  EMerr_hndlr(!(1&sts), *msg, EMS_E_Fail, wrapup);
  
  flip_thk_side = (flip_thk_side_value==0.0? FALSE : TRUE);
  }
 else
  flip_thk_side = FALSE;
  
 sts = om$send (msg = message expression.NDgive_value (&flip_proj_side_value),
                  targetid = parents[symmetric_rib?2:3].objid,
                  targetos = parents[symmetric_rib?2:3].osnum);
 EMerr_hndlr(!(1&sts), *msg, EMS_E_Fail, wrapup);
   
 flip_proj_side = (flip_proj_side_value==0.0?FALSE:TRUE);
  
 if(finite_rib)
  {
  sts = om$send (msg = message expression.NDgive_value (&depth),
                 targetid = parents[symmetric_rib?3:4].objid,
                 targetos = parents[symmetric_rib?3:4].osnum);
  EMerr_hndlr(!(1&sts), *msg, EMS_E_Fail, wrapup);
  }
  
   /* The first parent is always the profile. Get its id */
 sts = om$send(msg = message NDnode.ASreturn_go(&profile, &mat_type, mat),
                 targetid = parents[0].objid,
                 targetos = parents[0].osnum );
 EMerr_hndlr(!(1&sts), *msg, EMS_E_Fail, wrapup);
  
   /* get the geometry of the profile (possibly composite) curve */
 sts = om$send(msg = message GRvg.GRgetsize(&msg_loc,
                                    &mat_type, mat, (IGRlong *)&size),
                 targetid =profile.objid,
                 targetos =profile.osnum);
 EMerr_hndlr (!(1&msg_loc&sts), *msg, msg_loc, wrapup);
  
 curve_geom = (struct IGRbsp_curve *)alloca(size);
 EMerr_hndlr(!curve_geom, *msg, EMS_E_NoDynamicMemory, wrapup);
  
 sts = om$send(msg = message GRvg.GRgetgeom(&msg_loc,
                   &mat_type, mat, (IGRchar *)curve_geom),
                 targetid =profile.objid,
                 targetos =profile.osnum);
 EMerr_hndlr(!(1&msg_loc&sts), *msg, msg_loc, wrapup);
  
   /* evaluate the curve at given parameter */
 cv_par = TEST_PARAMETER;
  
 /* NOTE: Find a more sophisticated way to get a valid non-knot point */
 (void) BScveval(curve_geom, cv_par, 0, &pt_on_profile, &rc);
 EMerr_hndlr(rc!=BSSUCC, *msg, EMS_E_BSerror, wrapup);
  
 /* get the tangent to the curve at the evaluated point*/
  
 (void) BScvarrevt(curve_geom,&cv_par,1,1.0,tangent_pts,&rc);
 EMerr_hndlr (rc != BSSUCC, *msg, EMS_E_BSerror, wrapup);
  
 /* since "display" factor above is 1.0, tangent vector is unit vector */
 
 for(i=0; i<3; i++)
   unit_profile_tangent[i] = tangent_pts[0][1][i] - tangent_pts[0][0][i];
  
 if(dim_plane_xaxis || dim_geom)
 {
 /* Get the profile/curve plane normal using GRdetplane. The whole feature code
  * is based upon the fact that there is a CONSISTENT (non-flipping) normal
  * to the profile plane. This can be guaranteed ONLY if features are created
  * from profiles. If features are created using non-profile curves, then the
  * normal of the curve plane has an equal chance of going on either side
  * of the plane during recompute.
  */
  profile_plane.point  = (IGRdouble *)plane_point;
  profile_plane.normal = (IGRdouble *)plane_normal;
  sts = om$send (msg = message GRvg.GRdetplane (
                              &msg_loc, &mat_type, mat, &profile_plane),
                 targetid = profile.objid,
                 targetos = profile.osnum);
  EMerr_hndlr (!(1&sts) || (msg_loc != MSSUCC), *msg, EMS_E_Fail, wrapup);
  
  OM_BLOCK_MOVE(profile_plane.normal, profile_plane_unit_normal, 
                 sizeof (IGRvector));
 /*normalize the plane normal*/
  success = BSnorvec(&rc,(IGRdouble *)profile_plane_unit_normal);
  EMerr_hndlr (!success || (rc != BSSUCC), *msg, EMS_E_BSerror, wrapup);
  
  /* both operands are unit vectors, hence result is also unit vector*/
  success =  BScrossp(&rc,unit_profile_tangent, profile_plane_unit_normal,
                    t_cross_n);
  
  if(type1_rib)
   {
   for(i=0; i<3; i++)
     unit_thk_vector[i] = (flip_thk_side? -1.0:1.0) *
                                               profile_plane_unit_normal[i];
   for(i=0; i<3; i++)
     unit_proj_vector[i] = (flip_proj_side? -1.0:1.0) * t_cross_n[i];
   }
   else
   {
   for(i=0; i<3; i++)
     unit_proj_vector[i] = (flip_proj_side? -1.0:1.0) *
                                               profile_plane_unit_normal[i];
   for(i=0; i<3; i++)
     unit_thk_vector[i] = (flip_thk_side? -1.0:1.0) * t_cross_n[i];
   }

   if(dim_plane_xaxis)
   {
    if(place_thk_dimension)
    {
    if(type1_rib)
     OM_BLOCK_MOVE(profile_plane_unit_normal,dim_plane_xaxis,sizeof(IGRvector));
    else
     OM_BLOCK_MOVE(t_cross_n, dim_plane_xaxis, sizeof(IGRvector));
    }
    else
    {
    if(type1_rib)
     OM_BLOCK_MOVE(t_cross_n, dim_plane_xaxis, sizeof(IGRvector));
    else
     OM_BLOCK_MOVE(profile_plane_unit_normal,dim_plane_xaxis,sizeof(IGRvector));
    }
   }
  }/*if (dim_plane_xaxis || dim_geom) */

 /*
  * calc. the start and end pt for placing the dimension
  */
 if(dim_geom || dim_plane)
  {
   if(place_thk_dimension)
    {
    if(type1_rib)
     {
      for(i=0; i<3; i++)
       start_pt[i] = pt_on_profile[i] - (!symmetric_rib ? 0.0 :
                                     ((thickness/2.0)*unit_thk_vector[i]));
      for (i=0; i<3; i++)
       end_pt[i] = start_pt[i] + thickness * unit_thk_vector[i];
     }
    else
     {
     /*START PT*/
      if(symmetric_rib)
       {
        /* evaluate a point on the side of the curve (which is the side in 
         * the -ve dir of thk vector)that we want to offset "pt_on_profile".
         */
        for(i=0; i<3; i++)
          dir_pt[i]=pt_on_profile[i] - SMALL_VALUE*cht*unit_thk_vector[i];
        dist = thickness/2.0;
        success = BSoffsetpt(&rc,curve_geom,&cv_par,dir_pt,&dist,start_pt);
        EMerr_hndlr (!success ||(rc != BSSUCC), *msg, EMS_E_BSerror, wrapup);
       }
      else
       OM_BLOCK_MOVE (pt_on_profile, start_pt, sizeof (IGRpoint));
       
      /*END PT*/
      for(i=0; i<3; i++)
       dir_pt[i]=pt_on_profile[i] + SMALL_VALUE * cht * unit_thk_vector[i];
       dist = symmetric_rib? thickness/2.0 : thickness;
       success = BSoffsetpt(&rc,curve_geom,&cv_par,dir_pt, &dist,end_pt);
       EMerr_hndlr (!success || (rc != BSSUCC), *msg, EMS_E_BSerror, wrapup);
     }
    }
   else if (place_depth_dimension)
   {
   if(type1_rib)
    {
    /*START PT*/
     for(i=0; i<3; i++)
      start_pt[i] = pt_on_profile[i] - (!symmetric_rib ? 0.0 :
                                     ((thickness/2.0)*unit_thk_vector[i]));
    /*END PT*/
    /* evaluate an offset point on the side of the curve which is the side 
     * in the direction of material addition.
     */
    for(i=0; i<3; i++)
      dir_pt[i]=pt_on_profile[i]+SMALL_VALUE * cht * unit_proj_vector[i];
 
      success = BSoffsetpt(&rc,curve_geom,&cv_par,dir_pt,&depth,end_pt);
      EMerr_hndlr (!success || (rc != BSSUCC), *msg, EMS_E_BSerror, wrapup);
 
     /* now translate it to the correct position just as in start pt */
      for(i=0; i<3; i++)
       end_pt[i] -=  (!symmetric_rib ? 0.0 :
                                     ((thickness/2.0)*unit_thk_vector[i]));
    }
   else
    {
    /*START PT*/
    if(symmetric_rib)
     { /* evaluate a point on the side of the curve (which is the side in 
        * the -ve dir of thk vector)that we want to offset "pt_on_profile".
        */
     for(i=0; i<3; i++)
      dir_pt[i]=pt_on_profile[i]-SMALL_VALUE * cht * unit_thk_vector[i];
      dist = thickness/2.0;
      success = BSoffsetpt(&rc,curve_geom,&cv_par,dir_pt,&dist,start_pt);
      EMerr_hndlr(!success || (rc != BSSUCC), *msg, EMS_E_BSerror, wrapup);
     }
    else
     OM_BLOCK_MOVE (pt_on_profile, start_pt, sizeof (IGRpoint));
 
   /*END PT*/
    for(i=0; i<3; i++)
          end_pt[i] = start_pt[i] + depth * unit_proj_vector[i];
    }
   }
  else
    EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, wrapup);

  if(dim_geom)
    {
    dim_geom->geomtype = GEOMDATA_LINE;
    dim_geom->line.igr_line.point1 = dim_geom->line.line_pt1;
    dim_geom->line.igr_line.point2 = dim_geom->line.line_pt2;

    OM_BLOCK_MOVE(start_pt, dim_geom->line.line_pt1, sizeof (IGRpoint)); 
    OM_BLOCK_MOVE(end_pt, dim_geom->line.line_pt2, sizeof (IGRpoint)); 
    }
  /*
   * Find the projection of this unit profile tangent onto the normal
   * to view planes of windows. Find the dot products. The dimension plane
   * normal is one which gives the maximum value(get absolute)
   */
    sts = BSmkvec(&rc, temp_vect, start_pt, end_pt);
    result[0] = BSdotp(&rc, temp_vect, top);
    result[1] = BSdotp(&rc, temp_vect, front);
    result[2] = BSdotp(&rc, temp_vect, right);
    for(i=0; i<3; i++)
     result[i] = ABS(result[i]);
    temp = result[0];
    store_ind = 0;
    for(i=0; i<2; i++)
    {
    if((temp >= result[i+1]))
     {
     temp = result[i+1];
     store_ind = i+1;
     }
    }
  /*
   * If the minimum "temp" is with in some tolerance value to zero ie
   * perpandicularity of the accounted vectors then return that view
   * normal as the normal of the dimension plane else the tangent plane
   * is the dimensioning plane.
   */
   if(dim_plane)
   {
   if(temp < cht && temp > -cht)
    {
    OM_BLOCK_MOVE(pt_on_profile, dim_plane->point, sizeof (IGRpoint));
    if(store_ind == 0)
     OM_BLOCK_MOVE(top, dim_plane->normal, sizeof(IGRvector));
    else
    if(store_ind == 1)
     OM_BLOCK_MOVE(front, dim_plane->normal, sizeof(IGRvector));
    else
    if(store_ind == 2)
     OM_BLOCK_MOVE(right, dim_plane->normal, sizeof(IGRvector));
    }
  else
    {
    OM_BLOCK_MOVE(pt_on_profile, dim_plane->point, sizeof (IGRpoint));
    OM_BLOCK_MOVE(t_cross_n, dim_plane->normal, sizeof(IGRvector));
    }
   }
  }/*if dim_geom || dim_plane*/
 } /* if (dim_plane || dim_plane_xaxis || dim_geom) */ 

wrapup:
 EMWRAPUP(*msg, sts, "In EMdimparam_rib");
 return(sts);
}

/*
   Notes :
          This function provides the dimensioning parameters required for 
          Add/Remove material feature. 

   History :
      
   03/15/94        Sanjay        Creation  
*/

IGRlong EMdimparam_addrmmtl(IGRlong  *msg,
        struct GRmd_env    *mod_env,
        IGRushort          options,
        IGRint             type,
        IGRchar            *info,
        IGRint             num_parents,
        struct GRid        *parents,
        IGRint             index,
        struct IGRplane    *dim_plane,
        IGRdouble          *dim_plane_xaxis,
        struct EMSgeomdata *dim_geom,
        IGRint             *dim_type,
        GRobjid            my_id )
{
    BSrc                       rc;
    IGRint                     cnt, store_indx;
    IGRlong                    sts, loc_msg;
    IGRshort                   mat_type;
    IGRpoint                   pt_on_profile, startpt, endpt; 
    IGRpoint                   plane_point, plane_normal;
    IGRdouble                  *mat, temp, dot_prdt[3];
    IGRdouble                  cv_par, range[6];
    IGRvector                  topvw_nor, frontvw_nor, rightvw_nor;
    IGRvector                  proj_vec, temp_vec ;
    IGRboolean                 projected, finite, symmetric, success;
    IGRboolean                 world = TRUE;
    struct GRid                prof_grid;    
    struct IGRplane            prof_plane;
    struct IGRbsp_curve        *prof_geom = NULL;
    struct EMSAddRm_RecompInfo *recomp_info = NULL;

    /*
     * initilize the local variables and validate the function arguments
     */
    sts = OM_S_SUCCESS; 
    *msg = EMS_S_Success;
    loc_msg = EMS_S_Success;

    projected = symmetric = success = FALSE;
    memset( pt_on_profile, 0, sizeof(IGRpoint) ); 
    memset( startpt, 0, sizeof(IGRpoint) ); 
    memset( endpt, 0, sizeof(IGRpoint) ); 
    memset( topvw_nor, 0, sizeof(IGRvector) );
    memset( frontvw_nor, 0, sizeof(IGRvector) );
    memset( rightvw_nor, 0, sizeof(IGRvector) );
    memset( proj_vec, 0, sizeof(IGRvector) );
    memset( temp_vec, 0, sizeof(IGRvector) );
 
    if( !info || !mod_env || !parents || (num_parents == 0) )
    {
        sts = EMS_E_Fail;
        *msg = EMS_E_InvalidArg;
        goto wrapup;
    }

    prof_plane.point = plane_point; prof_plane.normal = plane_normal;
    mat = mod_env->md_env.matrix;
    mat_type = mod_env->md_env.matrix_type;
    recomp_info = (struct EMSAddRm_RecompInfo *) info;
    projected = ( recomp_info->props & EMSAddRm_Project ) ? TRUE :
                  FALSE; 
    if( dim_type )
    {
        if( projected  ) *dim_type = SINGLE_PARALLEL;
        else *dim_type = SINGLE_ARC_ANGLE;
    }

    finite    = ( recomp_info->props & EMSAddRm_Finite )    ? TRUE : 
                  FALSE;
    symmetric = ( recomp_info->props & EMSAddRm_Symmetric ) ? TRUE : 
                  FALSE;

    topvw_nor[0] = topvw_nor[1] = 0.0; topvw_nor[2] = 1.0;
    frontvw_nor[0] = 0.0; frontvw_nor[1] = -1.0; frontvw_nor[2] = 0.0;
    rightvw_nor[0] = 1.0; rightvw_nor[1] = rightvw_nor[2] = 0.0;

    if( dim_plane || dim_plane_xaxis || dim_geom )
    {
        /*
         * get the profile grid and the geometry
         */
        sts = om$send( msg = message NDnode.ASreturn_go(&prof_grid, &mat_type, 
                                     mat),
                       senderid = NULL_OBJID,
                       targetid = parents[PROFILE].objid,
                       targetos = parents[PROFILE].osnum );
        EMerr_hndlr( !(1 & sts), *msg, EMS_E_Fail, wrapup);
 
        /*
         * get the geometry of the profile
         */
        EMgetvggeom( &loc_msg, &mat_type, mat, &prof_grid, &prof_geom, NULL );
        EMerr_hndlr( !(1 & loc_msg), *msg, EMS_E_Fail, wrapup );

        /*
         * evaluate the profile at an arbitrary parameter ( non-knot point )
         */
        for( cnt = prof_geom->order-1; cnt < prof_geom->num_poles; cnt++ )
        {
            cv_par = (prof_geom->knots[cnt] + prof_geom->knots[cnt+1]) / 2.0;
            if( cv_par != prof_geom->knots[cnt] )
            {
                success = TRUE;
                break;
            }
        } 
        if( !success ) cv_par = TEST_PARAMETER;

        BScveval( prof_geom, cv_par, 0, &pt_on_profile, &rc);

        if( recomp_info->props & EMSAddRm_Project )
        { 
            IGRdouble           proj_dist;
            struct EMSgeomdata  proj_data; 

            /*
             * get the projection direction
             */
            sts = om$send( msg = message EMSparamgm.EMgetgeom( &loc_msg,
                                         NULL, &mat_type, mat, &proj_data),
                           targetid = parents[PRJ_VECTOR].objid,
                           targetos = parents[PRJ_VECTOR].osnum,
                           senderid = NULL_OBJID );
            EMerr_hndlr( !(1 & sts & loc_msg), *msg, EMS_E_Fail, wrapup );
    
            proj_vec[0] = proj_data.vector[0];
            proj_vec[1] = proj_data.vector[1];
            proj_vec[2] = proj_data.vector[2];
    
            if( dim_plane_xaxis ) 
                OM_BLOCK_MOVE( proj_vec, dim_plane_xaxis, sizeof( IGRvector ));

            if( finite || symmetric )
            {
                 IGRdouble  start_dist, lentol;

                 BSEXTRACTPAR(&rc, BSTOLLENVEC, lentol);

                 /*
                  * get the projection distance
                  */
                 sts = om$send( msg = message expression.NDgive_value( 
                                              &proj_dist ),
                                senderid = NULL_OBJID,
                                targetid = parents[PRJ_DISTANCE].objid,
                                targetos = parents[PRJ_DISTANCE].osnum );
                 EMerr_hndlr( !(1 & sts), *msg, EMS_E_Fail, wrapup);

                 /*
                  * get the projection start distance
                  */
                 sts = om$send( msg = message expression.NDgive_value( 
                                              &start_dist ),
                                senderid = NULL_OBJID,
                                targetid = parents[PRJ_START_DISTANCE].objid,
                                targetos = parents[PRJ_START_DISTANCE].osnum );
                 EMerr_hndlr( !(1 & sts), *msg, EMS_E_Fail, wrapup);

                 if( fabs(start_dist) > lentol )
                 {
                   /*
                    * get the plane of the profile 
                    */
                   sts = om$send( msg = message GRvg.GRdetplane( &loc_msg,
                                                &mat_type, mat, &prof_plane ),
                                  senderid = NULL_OBJID,
                                  targetid = prof_grid.objid,
                                  targetos = prof_grid.osnum );
                   EMerr_hndlr( !(1 & sts & loc_msg), *msg, EMS_E_Fail, wrapup);
                  
                   /*
                    * move the pt_on_profile by the start_dist along the 
                    * profile normal.
                    */
                   for(cnt=0; cnt<3; cnt++)
                     pt_on_profile[cnt] += start_dist * prof_plane.normal[cnt];
                 }
            }
            else
            {
                 /*
                  * get the range of the profile
                  */
                 sts = om$send( msg = message GRgraphics.GRgetrang( &loc_msg,
                                              &mat_type, mat, &world, range ),
                                targetid = prof_grid.objid,
                                targetos = prof_grid.osnum,
                                senderid = NULL_OBJID );
                 EMerr_hndlr( !(1 & sts & loc_msg), *msg, EMS_E_Fail, wrapup);

                 proj_dist = BSdistptpt( &rc, &range[0], &range[3] );
            }


            if( symmetric )
            {
               for(cnt=0; cnt<3; cnt++)
               {
                  startpt[cnt] = pt_on_profile[cnt] - 
                                 (proj_dist/2.0) * proj_vec[cnt] ;
                  endpt[cnt]   = pt_on_profile[cnt] +  
                                 (proj_dist/2.0) * proj_vec[cnt] ;
               }
            }
            else
            {
               OM_BLOCK_MOVE( pt_on_profile, startpt, sizeof(IGRpoint) );
               for( cnt=0; cnt<3; cnt++)
                  endpt[cnt] = startpt[cnt] + proj_dist * proj_vec[cnt];
            }
 
            if( dim_geom )
            {
                if( index == PRJ_DISTANCE || index == PRJ_VECTOR )
                {
                   dim_geom->geomtype = GEOMDATA_LINE;
                   dim_geom->line.igr_line.point1 = dim_geom->line.line_pt1;
                   dim_geom->line.igr_line.point2 = dim_geom->line.line_pt2;
   
                   OM_BLOCK_MOVE( startpt, dim_geom->line.line_pt1, 
                                           sizeof(IGRpoint));
                   OM_BLOCK_MOVE( endpt, dim_geom->line.line_pt2, 
                                         sizeof(IGRpoint));
                }
            }

            if( dim_plane )
            {
                sts = BSmkvec( &rc, temp_vec, startpt, endpt );
                dot_prdt[0] = BSdotp( &rc, temp_vec, topvw_nor );
                dot_prdt[1] = BSdotp( &rc, temp_vec, frontvw_nor );   
                dot_prdt[2] = BSdotp( &rc, temp_vec, rightvw_nor );   

                for( cnt=0; cnt<3; cnt++ )
                    dot_prdt[cnt] = ABS( dot_prdt[cnt] );
                temp = dot_prdt[0];
                store_indx = 0;
                for( cnt=1; cnt<3; cnt++ )
                {
                    if( temp >= dot_prdt[cnt] )
                    {
                        temp = dot_prdt[cnt];
                        store_indx = cnt;
                    }
                }

                OM_BLOCK_MOVE( pt_on_profile, dim_plane->point, 
                                                         sizeof(IGRpoint) );
                if( store_indx == 0 )
                    OM_BLOCK_MOVE( topvw_nor, dim_plane->normal, 
                                                          sizeof( IGRvector) );
                else if( store_indx == 1 )
                    OM_BLOCK_MOVE( frontvw_nor, dim_plane->normal, 
                                                          sizeof( IGRvector) );
                else if( store_indx == 2 )
                    OM_BLOCK_MOVE( rightvw_nor, dim_plane->normal, 
                                                          sizeof( IGRvector) );
            }
        }
        else if( recomp_info->props & EMSAddRm_Revolve )
        {
            IGRpoint            box_center, axis_center, axis[2], point, 
                                pt1, pt2 ;
            IGRvector           axis_vec;
            IGRdouble           box_diagonal[3];
            struct IGRline      line;
            struct EMSgeomdata  axispt_data, axisvec_data; 
     
            line.point1 = pt1;
            line.point2 = pt2;
 
            /*
             * get the rotational axis starting point
             */
            sts = om$send( msg = message EMSparamgm.EMgetgeom( &loc_msg,
                                         NULL, &mat_type, mat, &axispt_data),
                           targetid = parents[1].objid,
                           targetos = parents[1].osnum,
                           senderid = NULL_OBJID );
            EMerr_hndlr( !(1 & sts & loc_msg), *msg, EMS_E_Fail, wrapup );

            OM_BLOCK_MOVE( axispt_data.point, axis[0], sizeof(IGRpoint) );

            /*
             * get the rotational axis vector
             */
            sts = om$send( msg = message EMSparamgm.EMgetgeom( &loc_msg,
                                         NULL, &mat_type, mat, &axisvec_data),
                           targetid = parents[2].objid,
                           targetos = parents[2].osnum,
                           senderid = NULL_OBJID );
            EMerr_hndlr( !(1 & sts & loc_msg), *msg, EMS_E_Fail, wrapup );

            OM_BLOCK_MOVE( axisvec_data.vector, axis_vec, sizeof(IGRvector) );

            for(cnt=0; cnt<3; cnt++)
               axis[1][cnt] = axis[0][cnt] + axis_vec[cnt];

            /*
             * get the profile plane 
             */
            sts = om$send( msg = message GRvg.GRdetplane( &loc_msg,
                                         &mat_type, mat, &prof_plane ),
                           senderid = NULL_OBJID,
                           targetid = prof_grid.objid,
                           targetos = prof_grid.osnum );
            EMerr_hndlr( !(1 & sts & loc_msg), *msg, EMS_E_Fail, wrapup);
       
            /*
             * get the range of the profile 
             */
            sts = om$send( msg = message GRgraphics.GRgetrang( &loc_msg,
                                         &mat_type, mat, &world, range ),
                           targetid = prof_grid.objid,
                           targetos = prof_grid.osnum,
                           senderid = NULL_OBJID );
            EMerr_hndlr( !(1 & sts & loc_msg), *msg, EMS_E_Fail, wrapup);

            /*
             * calculate the box diagonal, box center and axis_center
             */ 
            for( cnt=0; cnt<3; cnt++)
                box_diagonal[cnt] = range[cnt+3] - range[cnt];

            for( cnt=0; cnt<3; cnt++ )
                box_center[cnt] = range[cnt] + (box_diagonal[cnt] * 0.5);
            
            /*
             * project the axis points on to the plane of the profile.
             */
            MAptplproj( &loc_msg, (IGRpoint *) axis[0], &prof_plane, 
                        line.point1 );
            EMerr_hndlr( !(1 & loc_msg), *msg, EMS_E_BSerror, wrapup);

            MAptplproj( &loc_msg, (IGRpoint *) axis[1], &prof_plane, 
                        line.point2 );
            EMerr_hndlr( !(1 & loc_msg), *msg, EMS_E_BSerror, wrapup);

            /*
             * project the box_center on to the axis to get the axis
             * center
             */
            MAptlnproj( &loc_msg, box_center, &line, axis_center, &temp); 
   
            if( dim_plane )
            {
                OM_BLOCK_MOVE( axis_center, dim_plane->point, 
                                                      sizeof( IGRpoint ) );
                OM_BLOCK_MOVE( axis_vec, dim_plane->normal,
                                                     sizeof( IGRvector ) );
            }
 
            if( dim_plane_xaxis )
            {
                for( cnt=0; cnt<3; cnt++ )
                    dim_plane_xaxis[cnt] = box_center[cnt] - 
                                                          axis_center[cnt];
                BSnorvec( &loc_msg, dim_plane_xaxis );
            }
 
            if( dim_geom ) 
            {
                IGRlong   num_pts=1;
                IGRdouble start_angle, sweep_angle;
                IGRmatrix matrix;
               
                if( index == REV_START_ANGLE )
                {
                   dim_geom->geomtype = GEOMDATA_CURVE;

                   /*
                    * get the start angle 
                    */
                   sts = om$send( msg = message expression.NDgive_value(
                                                &start_angle ),
                                  senderid = NULL_OBJID,
                                  targetid = parents[REV_START_ANGLE].objid,
                                  targetos = parents[REV_START_ANGLE].osnum );
                   EMerr_hndlr( !(1 & sts), *msg, EMS_E_Fail, wrapup);

                   if( start_angle < 0.0 )
                   {
                      IGRpoint  temppt;

                      OM_BLOCK_MOVE( axis[0], temppt, sizeof(IGRpoint));
                      OM_BLOCK_MOVE( axis[1], axis[0], sizeof(IGRpoint));
                      OM_BLOCK_MOVE( temppt, axis[1], sizeof(IGRpoint));
                   }

                   EFget_curve_buffer( BSCIRCLE_ORDER,BSCIRCLE_NUM_POLES_MAX,
                                       TRUE, 0, &dim_geom->curve);
                   BSarc_rot( &loc_msg, axis[0], axis[1], box_center, 
                              &start_angle, dim_geom->curve);
                }
                else if( index == REV_SWEEP_ANGLE )
                {
                   IGRdouble xform_angle;

                   dim_geom->geomtype = GEOMDATA_CURVE;

                   /*
                    * get the start and sweep angles  
                    */
                   sts = om$send( msg = message expression.NDgive_value(
                                                &start_angle ),
                                  senderid = NULL_OBJID,
                                  targetid = parents[REV_START_ANGLE].objid,
                                  targetos = parents[REV_START_ANGLE].osnum );
                   EMerr_hndlr( !(1 & sts), *msg, EMS_E_Fail, wrapup);

                   sts = om$send( msg = message expression.NDgive_value(
                                                &sweep_angle ),
                                  senderid = NULL_OBJID,
                                  targetid = parents[REV_SWEEP_ANGLE].objid,
                                  targetos = parents[REV_SWEEP_ANGLE].osnum );
                   EMerr_hndlr( !(1 & sts), *msg, EMS_E_Fail, wrapup);

                   /*
                    * get the starting point of the circular arc
                    */
                   xform_angle = start_angle - 
                                     (symmetric ? (sweep_angle/2.0) : 0.0);

                   if( fabs(xform_angle) > EMS_ZEROANGLE_DEG )
                   {
                      IGRdouble  xform_radians;

                      if( start_angle < 0.0 )
                         xform_angle = start_angle + 360.0; 
                      else 
                         xform_angle = start_angle;
                    
                      if( symmetric )
                         xform_angle -= (sweep_angle/2.0);

                      MAdegrad( &loc_msg, &xform_angle, &xform_radians );

                      MAgrotmx( &loc_msg, axis_vec, axis_center, 
                                &xform_radians, matrix ); 
                      num_pts = 1;
                      MAptsxform( &loc_msg, &num_pts, matrix, box_center, 
                                  point );
                   }
                   else 
                   {
                     OM_BLOCK_MOVE( box_center, point, sizeof( IGRpoint ) );
                   }

                   /*
                    * generate the circular arc with the given sweep angle
                    */
                   EFget_curve_buffer(BSCIRCLE_ORDER, BSCIRCLE_NUM_POLES_MAX,
                                      TRUE, 0, &dim_geom->curve );

                   BSarc_rot( &loc_msg, axis[0], axis[1], point, 
                              &sweep_angle, dim_geom->curve );
                   EMerr_hndlr( BSERROR(loc_msg), *msg, EMS_E_BSerror, 
                                wrapup);
                }
                else if( index == REV_AXIS_POINT )
                {
                   dim_geom->geomtype = GEOMDATA_POINT;
                   OM_BLOCK_MOVE( &axis[0], dim_geom->point, sizeof(IGRpoint));
                }
                else if( index == REV_AXIS_VECTOR )
                {
                   dim_geom->geomtype = GEOMDATA_LINE;
                   dim_geom->line.igr_line.point1 = dim_geom->line.line_pt1;
                   dim_geom->line.igr_line.point2 = dim_geom->line.line_pt2;

                   MAptlnproj( &loc_msg, &range[0], &line, point, &temp);
                   BSmkvec( &rc, temp_vec, &axis[0], point );
                   BSnorvec( &rc, temp_vec );
                   if( (rc != BSSUCC) || 
                       BSdotp(&rc, temp_vec, axis_vec) < 0.0 )
                       MAptlnproj( &loc_msg, &range[3], &line, point, &temp);

                   OM_BLOCK_MOVE( &axis[0], dim_geom->line.line_pt1, 
                                  sizeof(IGRpoint) );
                   OM_BLOCK_MOVE( point, dim_geom->line.line_pt2, 
                                  sizeof(IGRpoint) );
                }
            }
        }                    
    }

wrapup :
   EMWRAPUP( *msg, sts, "In EMdimparam_addrmmtl");
   if( prof_geom ) om$dealloc( ptr = prof_geom );
   return sts;
}


/*****************************************************************************/


method EMgetInGeomIds(IGRlong *EMmsg; 
                      GRobjid nodes_side_id; 
                      IGRboolean is_kd_on; 
                      IGRint *num_in_geom_ids; 
                      GRobjid **in_geom_ids; 
                      IGRushort options)
/*
Description
    This message will get the geometry added by this operation.  The main user
    of this message will be the EMcheckRngOverlap message.

Return Values    
    EMS_S_Success if all is well.

Notes
    About parameters:
        nodes_side_id - the component of this state that contains the
                        replacing node.  This is needed by some states 
                        such as booleans where in the added geometry can only
                        be determined relative to what has changed.  For local
                        operations this parameter MAY not be referenced.
        is_kd_on - indicates a known dependency and is an indicator of what is
                   added in a boolean op (which operand).
        num_in_geom_ids - returned num ids found.
        in_geom_ids - returned ids found.
        options - None so far.

History
    08/17/93  NP  Copied verbatim from the override of EMSslboolfea class.

*/
{
  IGRlong           OM_stat;
  GRobjid           GRids;
  OM_S_CHANSELECT   to_comps;
  OMuword           dum_os;
  OMuint            i,num_of_comps;
  
  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  *num_in_geom_ids = 0;

  OM_stat = EMmake_chanselect(GRcmpowner_to_components, &to_comps);
  if(!(1& OM_stat)) goto wrapup;

  /* count the number of components */
  OM_stat = om$get_channel_count(objid = my_id, 
				p_chanselect = &to_comps,
				count = &num_of_comps); 

  if(!(1& OM_stat)) goto wrapup;

  if(num_of_comps > 1) {
  	*in_geom_ids = (GRobjid *) om$malloc(size = sizeof(GRobjid) *
				(num_of_comps - 1));
  	if(! *in_geom_ids) {
		*EMmsg = EMS_E_NoDynamicMemory;
		goto wrapup;
  	}
  }
  else 
   return (OM_S_SUCCESS);

  /* get the component ids */
  for(i = 1; i < num_of_comps; i++) {
 	OM_stat = om$get_objid_at_index(objid = my_id,
				p_chanselect = &to_comps,
				index = i,
				objidaddr = &GRids,
				osnumaddr = &dum_os);
  	if(!(1& OM_stat)) goto wrapup;

        (*in_geom_ids)[*num_in_geom_ids] = GRids;
        (*num_in_geom_ids)++;
  }


wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EMSsffeature.getInGmIds")
  return(OM_stat);
}
/*****************************************************************************/
end implementation EMSsffeature;

