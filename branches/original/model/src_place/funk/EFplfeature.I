/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsffeature;

#include "EMSas.h"
#include "OMmacros.h"
#include "EMSasnucdef.h"
#include "EMSasfeatdef.h"
#include "EMSfeadef.h"
#include "emsfeaopts.h"
#include "REaddrmfea.h"

/*   
 *  This function creates the rib, add matl. and remove matl. feature.
 *  Placement can be associative or non-associative.
 *
 *  NP              06/29/93           Creation.
 *  Sanjay          03/03/94           Added a function ( FOR EMS 4.0 ) 
 *                                     ' EFfea_get_add_rem_matl_parent_info '
 *                                     which constructs the parents for Add /
 *                                     Remove Material feature, implemented 
 *                                     for EMS 4.0
 *                                     Also Modified the function arguments of
 *                                     'EFplace_feature' : 
 *                                     Changed the recomp_info  argument from 
 *                                     (struct  EMSfeature_data *) to (char *)  
 *                                     a generic Pointer.
 *  Sanjay          03/09/94           Modified EFplace_feature :
 *                                     init_options will be set depending on
 *                                     recomp_info and the assoc_type
 */


extern OMuword OPP_EMSslfeature_class_id, OPP_EMSsffeature_class_id;
extern OMuword OPP_EMSsolid_class_id, OPP_EMSpervcnstr_class_id;
extern OM_S_OBJID current_creator; /* WHERE is this defined? */

from EMScnstr import EMinit;

IGRlong EFfea_get_rib_parent_info();
IGRlong EFfea_get_add_rem_matl_parent_info();


IGRlong EFplace_feature(EFmsg,options,assoc_type,recomp_info, 
                        feature_info,construct_list,feature_id)
IGRlong *EFmsg;
IGRchar *recomp_info; 
IGRushort options;
IGRint   assoc_type;
IGRchar *feature_info;
struct GRvg_construct *construct_list;
struct GRid  *feature_id;
{
   IGRint                               num_parents=0;
   IGRlong                              sts, msg_loc, another_msg_loc;
   IGRushort                            init_options=0;
   IGRboolean                           solid_feature=FALSE;
   GRspacenum                           const_os;
   struct GRmd_env                      const_env;
   struct EMSobject_info                *parents=NULL;
   struct EMSAddRm_RecompInfo  *addrm_recomp_info=NULL;

   sts = OM_S_SUCCESS;
   *EFmsg = EMS_S_Success;
   msg_loc = EMS_S_Success;
   another_msg_loc = EMS_S_Success;

   /* get construct env info */
   OM_BLOCK_MOVE(construct_list->env_info,&const_env,sizeof(struct GRmd_env));
   const_os = const_env.md_id.osnum;

   /* initialize */
   parents = NULL;
   feature_id->objid = NULL_OBJID;
   feature_id->osnum = const_os;
   
   switch (assoc_type)
   {
     case EMS_ASSOC_FEATURE_RIB:
       sts = EFfea_get_rib_parent_info(&msg_loc, construct_list, 
              (struct EMSrib_feature_parent_info *) feature_info, 
              (struct EMSfeature_data *) recomp_info, &num_parents, 
              &parents, &solid_feature);
       EMerr_hndlr(!(1&sts&msg_loc), *EFmsg, msg_loc, wrapup);
       break;

     case EMS_ASSOC_FEATURE_ADD_MATERIAL:
     case EMS_ASSOC_FEATURE_REMOVE_MATERIAL:
       sts = EFfea_get_add_rem_matl_parent_info(&msg_loc, 
              construct_list, 
              (struct EMSAddRm_ParentInfo *) feature_info, 
              (struct EMSAddRm_RecompInfo *) recomp_info, 
              &num_parents, &parents, &solid_feature);
       EMerr_hndlr (!(1&sts&msg_loc), *EFmsg, msg_loc, wrapup);
       break;

     default:
       EMerr_hndlr (TRUE, *EFmsg, EMS_E_InvalidArg, wrapup);
       break;
   }

   sts = om$construct(
     classid = (solid_feature ? OPP_EMSslfeature_class_id :
                                OPP_EMSsffeature_class_id),
     osnum   = feature_id->osnum,
     p_objid = &(feature_id->objid));
   EMerr_hndlr(!(1&sts), *EFmsg, EMS_E_OMerror, wrapup);

   current_creator = feature_id->objid; /* SET */

   /* If the construction is non-associative, don't auto dimension */

   init_options = NULL; /* important */
   if( assoc_type != EMS_ASSOC_FEATURE_RIB )
       addrm_recomp_info = (struct EMSAddRm_RecompInfo *) recomp_info;

   /*
    * set init options as no auto dimension, if
    *     if feature is not associative ( OR )
    *     if the feature is add/remove material and not finite
    * in case if the feature is add/remove material
    *     set the options as no recompute. i.e. feature is being created using
    *     a caller function but not thru recompute.
    */       
   if( options & EMSasconst_notassociative)  
   {
       init_options |= EMSasconst_noautodimension;
   }
   else if( (assoc_type != EMS_ASSOC_FEATURE_RIB) ) 
   {
       init_options &= ~EMSasconst_recompute;
       if( !( addrm_recomp_info->props & EMSAddRm_Finite) )
         init_options |= EMSasconst_no_autodimension;    
   }

   sts = om$send (msg = message EMSassoc.EMinit_associative(&msg_loc,
	    			init_options, 
				num_parents, 
				parents, 
				assoc_type, 
				sizeof(struct EMSfeature_data),
				(IGRchar *) recomp_info,
				construct_list),
	    		senderid = NULL_OBJID,
	    		targetid = feature_id->objid,
	    		targetos = feature_id->osnum);
   EMerr_hndlr(!(1&sts&msg_loc), *EFmsg, msg_loc, wrapup);

   current_creator = NULL_OBJID; /* UNSET */

   /* If non-associative placement disconnect the parents */
   if(options & EMSasconst_notassociative) 
   {
     sts = om$send(msg = message NDnode.NDmove_to_root(&msg_loc, 
                               feature_id, &const_env),
              senderid = NULL_OBJID,
              targetid = feature_id->objid,
              targetos = feature_id->osnum);

     EMerr_hndlr(!(1&sts&msg_loc), *EFmsg, msg_loc, wrapup);
   }

wrapup:

   /* On error, delete the feature object, if one has been created */
   if(!(1&sts&msg_loc)) 
   {
      if(feature_id->objid != NULL_OBJID) 
      {
	 om$send(msg = message GRgraphics.GRdelete(&another_msg_loc,
			    construct_list->env_info),
			senderid = NULL_OBJID,
			targetid = feature_id->objid,
			targetos = feature_id->osnum);
      }
      feature_id->objid = NULL_OBJID;
   }
   
   /* free array of parent info if it exists */
   if (parents) 
   {  om$dealloc (ptr=parents);
      parents=NULL;
   }

   EMWRAPUP(*EFmsg, sts, "EFplace_feature"); 
   return (sts);
}

/*---------------------------------------------------------------------------*/

/*
     Order of parents for the rib is:
         - Profile  (EMSgrid)
         - Thickness (EMSscalar)
         - Flip side   (EMSscalar, boolean)
         - Flip proj. dir (EMSscalar, boolean)
         - Projection distance(if finite rib) (EMSscalar).
         - Base solid/surface (EMSgrid)

  "parents" will be freed in the calling function.
*/

IGRlong EFfea_get_rib_parent_info(EFmsg, construct_list, feature_info, 
                                  recomp_info, num_parents, parents, 
                                  solid_feature)
IGRlong *EFmsg;
struct GRvg_construct *construct_list;
IGRint  *num_parents;
struct EMSobject_info **parents;
struct EMSrib_feature_parent_info *feature_info;
struct EMSfeature_data *recomp_info;
IGRboolean *solid_feature;
{
  /* ALTHOUGH SIX TYPES OF PARENTS ARE POSSIBLE, THE NUMBER OF ACTUAL PARENTS
   * OF A RIB FEATURE MAY BE 4,5 or 6, DEPENDING ON WHETHER IT IS SYMMETRIC
   * AND/OR FINITE.
   */

  IGRlong sts, msg_loc;
  IGRint actual_num_parents;
  struct EMSvalue_info thickness, flip_thickness_side, flip_projection_side;
  struct EMSvalue_info proj_dist;
  GRspacenum const_os;
  OMuword class_id;

  sts = OM_S_SUCCESS;
  *EFmsg = EMS_S_Success;

  const_os = construct_list->env_info->md_id.osnum;

  *num_parents = 0;

  actual_num_parents = 6;
  if (recomp_info->attributes & EMSfeature_symmetric)
     actual_num_parents--;
  if (!(recomp_info->attributes & EMSfeature_finite))
     actual_num_parents--;


  *parents = (struct EMSobject_info *) om$malloc (
                size = (sizeof(struct EMSobject_info) * actual_num_parents));


  /* FIRST PARENT is the profile*/
  OM_BLOCK_MOVE (&(feature_info->profile), &((*parents)[*num_parents]), 
                   sizeof (struct EMSobject_info));
  (*num_parents)++;


  /* NEXT PARENT is the thickness*/
  OM_BLOCK_MOVE (&(feature_info->thickness), &thickness,
                   sizeof (struct EMSvalue_info));
  sts = EMgetparval_object(&msg_loc, const_os, NULL,
                        &thickness, &((*parents)[*num_parents]));
  EMerr_hndlr(!(1&sts&msg_loc), *EFmsg,EMS_E_Fail,wrapup);
  (*num_parents)++;

  /* NEXT PARENT is a boolean value. TRUE (1) implies that the material side
   * for the profile is to the "right" side of the profile curve. FALSE implies
   * the opposite.
   *   OBVIOUSLY, THIS IS VALID ONLY FOR NON_SYMMETRIC PROFILES.
   */

  if (!(recomp_info->attributes & EMSfeature_symmetric))
  {
    OM_BLOCK_MOVE (&(feature_info->flip_thickness_side), &flip_thickness_side,
                   sizeof (struct EMSvalue_info));
    sts = EMgetparval_object(&msg_loc, const_os, NULL,
                        &flip_thickness_side, &((*parents)[*num_parents]));
    EMerr_hndlr(!(1&sts&msg_loc), *EFmsg,EMS_E_Fail,wrapup);
    (*num_parents)++;
  }

  /* NEXT PARENT is a boolean value for flipping projection direction.*/
  OM_BLOCK_MOVE (&(feature_info->flip_projection_side), &flip_projection_side,
                   sizeof (struct EMSvalue_info));
  sts = EMgetparval_object(&msg_loc, const_os, NULL,
                        &flip_projection_side, &((*parents)[*num_parents]));
  EMerr_hndlr(!(1&sts&msg_loc), *EFmsg,EMS_E_Fail,wrapup);
  (*num_parents)++;

  /* NEXT PARENT is the finite pojection depth of a rib. This is needed ONLY
   * for those ribs with a finite projection distance.
   */
  if (recomp_info->attributes & EMSfeature_finite)
  {
     OM_BLOCK_MOVE (&(feature_info->proj_dist), &proj_dist,
                   sizeof (struct EMSvalue_info));
     sts = EMgetparval_object(&msg_loc, const_os, NULL,
                           &proj_dist, &((*parents)[*num_parents]));
     EMerr_hndlr(!(1&sts&msg_loc), *EFmsg,EMS_E_Fail,wrapup);
     (*num_parents)++;
  }


  /* NEXT PARENT is the base solid/feature*/
  OM_BLOCK_MOVE (&(feature_info->solid), &((*parents)[*num_parents]), 
                   sizeof (struct EMSobject_info));
  (*num_parents)++;


  /* check if a solid (EMSslfeature) or surface (EMSsffeature) object needs
   * to be created. The "surface/solid" on which the feature is to be created
   * is the LAST parent.
   */
 
  sts = om$get_classid (objid     = ((*parents)[(*num_parents)-1]).grid.objid, 
                        osnum     = ((*parents)[(*num_parents)-1]).grid.osnum,
                        p_classid = &class_id);
  EMerr_hndlr(!(1&sts), *EFmsg,EMS_E_OMerror,wrapup);

  sts = om$is_ancestry_valid(subclassid   = class_id,
                             superclassid = OPP_EMSsolid_class_id);
  EMerr_hndlr (!(1&sts), *EFmsg, EMS_E_OMerror, wrapup);

  *solid_feature = (sts == OM_S_SUCCESS)? TRUE : FALSE;
    
  wrapup:

  EMWRAPUP(*EFmsg, sts, "EFfea_get_rib_parent_info"); 
  return (sts); 

}

/*---------------------------------------------------------------------------*
 * This function constructs the parents for Add/Remove Material feature impl.*
 * for EMS 4.0                                                               *
 *                                                                           *
 * History                                                                   *
 * -------                                                                   *
 * 03/03/94           Sanjay            Creation                             *
 *---------------------------------------------------------------------------*/

IGRlong EFfea_get_add_rem_matl_parent_info(EFmsg, construct_list, 
                                           parent_info, recomp_info,
                                           num_parents, parents, solid_feature)
IGRint  *num_parents;
IGRlong *EFmsg;
IGRboolean *solid_feature;
struct EMSobject_info **parents;
struct GRvg_construct *construct_list; 
struct EMSAddRm_ParentInfo *parent_info;
struct EMSAddRm_RecompInfo *recomp_info;
{
   IGRint                            nparents, indx, i;
   IGRlong                           sts, loc_msg;
   OMuword                           osnum, class_id;
   IGRshort                          matrix_type;
   IGRdouble                         *matrix;

   /*
    *   Validate the incoming arguments
    */
   if( !construct_list || !num_parents || !parent_info || !recomp_info || 
       !solid_feature )
   {
       sts = EMS_E_Fail;
       *EFmsg = EMS_E_InvalidArg;
       goto wrapup;
   }

   /*
    *   Initialize the local variables and the incoming variables 
    */
   sts = OM_S_SUCCESS;
   *EFmsg = EMS_S_Success;
   nparents = 0; *num_parents = 0; indx = 0;
   osnum = construct_list->env_info->md_id.osnum; 

   /* ______________________________________________________________________

      Parent list for Add / Remove Material Feature
      ---------------------------------------------

      Projected Case
      ~~~~~~~~~~~~~~

      Description                  When                       Remarks
      -----------                  ----                       -------

      1. Profile                   always                     EMSGRid

      2. Projection Vector         always                     EMSvector

      3. Projection Start distance finite                     EMSScalar 

      4. Projection Distance       finite                     EMSscalar

      5. From Surface_id           from_to &                  EMSGRid
                                   Profile is non-composite

      6. To Surface_id             from_to                    EMSGRid

      7. Base Solid_id             always                     EMSGRid


      Revolved Case
      ~~~~~~~~~~~~~

      1. Profile                   always                     EMSGRid

      2. Axis Start point          always                     EMSpoint 

      3. Axis of Revolution        always                     EMSvector

      4. Start Angle               finite                     EMSscalar

      5. Sweep Angle               finite                     EMSscalar

      6. From Surface_id           from_to &                  EMSGRid
                                   Profile is non-composite

      7. To Surface_id             from_to                    EMSGRid

      8. Base Solid_id             always                     Solid EMSGRid

      Skinned Case
      ~~~~~~~~~~~~

      1. Profile                   always                     Profile EMSGRid

      2. Trace Curve               always                     Profile EMSGRid

      3. From Surface_id           if from_to                 Surface EMSGRid

      4. To Surface_id             if from_to                 Surface EMSGRid

      5. Base Solid_id             always                     Solid EMSGRid

      _______________________________________________________________________ 
   */
  
   /*
    * Get the number of parents from the options selected
    */
   if( recomp_info->props & EMSAddRm_Project )
   {
      nparents = 3; /* Minimum Number of parents
                     * 1. Profile 2. Base Solid
                     * 3. Projection Vector
                     */
      if( recomp_info->props & EMSAddRm_Finite )
        nparents +=2;
   }
   else if( recomp_info->props & EMSAddRm_Revolve )
   {
      nparents = 4; /* Minimum Number of parents
                     * 1. Profile 2. Base Solid
                     * 3. Axis of Revolution Start Point
                     * 4. Axis of Revolution Direction
                     */
      if( recomp_info->props & EMSAddRm_Finite )
        nparents +=2;
   }
   else if( recomp_info->props & EMSAddRm_Skinned )
   {
      nparents = 3; /* Minimum Number of parents
                     * 1. Profile 2. Base Solid
                     * 3. Trace Curve 
                     */
   }
   else
   {
      sts = OM_E_ABORT;
      *EFmsg = EMS_E_InvalidArg;
      goto wrapup; 
   }

   if( recomp_info->props & EMSAddRm_FromTo )
   {
     if( !(recomp_info->props & EMSAddRm_NoFromSurf) )
       nparents ++;
     if( !(recomp_info->props & EMSAddRm_NoToSurf) )
       nparents ++;
   }

   /*
    * Allocate the memory for nparents to hold parent information
    */
   *num_parents = nparents;
   *parents = ( struct EMSobject_info * ) om$malloc( 
                       size = ( sizeof(struct EMSobject_info) * nparents) );
   EMerr_hndlr( !(*parents), *EFmsg, EMS_E_NoDynamicMemory, wrapup );   

   matrix_type = construct_list->env_info->md_env.matrix_type;
   matrix = construct_list->env_info->md_env.matrix;

   /* ---------------------------------------------------------------------- * 
    *                   Construction of Parents                              *
    * ---------------------------------------------------------------------- */ 

   /*
    * First Parent : Always the Profile for All solid types
    * As the object is already there, there is no need to construct this object
    * just populate the parents list
    */ 
   OM_BLOCK_MOVE( &(parent_info->profile),  &((*parents)[indx++]),
                  sizeof( struct EMSobject_info ) );
   
   /*
    * Second Parent : Projection Vecotr, in case of Projected 
    *                 Axis start point & Rotational axis, in case of Revolved
    *                 trace curve, in case of Skinned                  
    * In this case construct a EMSparval object
    */
   if( (recomp_info->props & EMSAddRm_Project) )
   {

       /*
        * Create a Parameter Vector Object
        */
       sts = EMgetparvec_object( &loc_msg, matrix_type, matrix, osnum,
                                 &(parent_info->sweep_dir.projection_vec), 
                                 &((*parents)[indx++]) );
       EMerr_hndlr( !(sts & loc_msg & 1), *EFmsg, EMS_E_Fail, wrapup );

       /*
        * if the projection is normal to the profile plane then place a 
        * perpendicularity constraint.
        */
       if( recomp_info->props & EMSAddRm_ProjNormal )
       {
         GRobjid     cnstr_id;
         struct GRid prof_grid, vector_grid;
     
         prof_grid = (*parents)[0].grid;
         vector_grid = (*parents)[1].grid;

         sts = om$construct( classid = OPP_EMSpervcnstr_class_id, 
                  msg = message EMScnstr.EMinit( &loc_msg, NULL, 
                  construct_list->env_info, (IGRint)1, &prof_grid, 
                  EMScnstr_self_constraint, NULL, (IGRint) 1, &vector_grid),
                  osnum   = prof_grid.osnum,
                  p_objid = &cnstr_id );
         EMerr_hndlr( !(sts & loc_msg & 1), *EFmsg, EMS_E_Fail, wrapup );
       }
   }
   else if( (recomp_info->props & EMSAddRm_Revolve) )
   {
       struct EMSvector_info   direction;

       /*
        * Create a Parameter Point Object
        */
       sts = EMgetparpt_object( &loc_msg, matrix_type, matrix, osnum,
                                 &(parent_info->sweep_dir.rotational_axis[0]),
                                 &((*parents)[indx++]) );
       EMerr_hndlr( !(sts & loc_msg & 1), *EFmsg, EMS_E_Fail, wrapup );

       direction.type = EMSdatainfo_numeric;
       for(i=0; i<3; i++)
          direction.vec[i] = parent_info->sweep_dir.rotational_axis[1].pt[i] - 
                             parent_info->sweep_dir.rotational_axis[0].pt[i]; 
       BSnorvec( &loc_msg, direction.vec );

       /*
        * Create a Parameter Vector Object
        */
       sts = EMgetparvec_object( &loc_msg, matrix_type, matrix, osnum,
                                 &direction, &((*parents)[indx++]) );
       EMerr_hndlr( !(sts & loc_msg & 1), *EFmsg, EMS_E_Fail, wrapup );
   }
   else if( (recomp_info->props & EMSAddRm_Skinned) )
   {
       OM_BLOCK_MOVE( &(parent_info->sweep_dir.trace_curve), 
                      &((*parents)[indx++]), sizeof(struct EMSobject_info) );
   }
   
   /*
    * Third Parent and Fourth Parents: 
    *               1. If finite only Fourth parent will be there.
    *                  In case of Projected, projection start and total distance
    *                  In case of Revolved , Sweep angle
    *               2. If from_to Option is specified then both parents will 
    *                  be there. In all cases
    *                  a. from surface
    *                  b. to surface
    */
   if( recomp_info->props & EMSAddRm_Finite )
   {
     if( recomp_info->props & EMSAddRm_Project )
     {
       /*
        * Create a Parval Object
        */
       sts = EMgetparval_object( &loc_msg, osnum, NULL,
                          &(parent_info->sweep_extent.start_sweep_dist[0]),
                          &((*parents)[indx++]) );
       EMerr_hndlr( !(sts & loc_msg & 1), *EFmsg, EMS_E_Fail, wrapup );

       /*
        * Create a Parval Object
        */
       sts = EMgetparval_object( &loc_msg, osnum, NULL,
                          &(parent_info->sweep_extent.start_sweep_dist[1]), 
                          &((*parents)[indx++]) );
       EMerr_hndlr( !(sts & loc_msg & 1), *EFmsg, EMS_E_Fail, wrapup );
     }
     else if( recomp_info->props & EMSAddRm_Revolve )
     {
       /*
        * Create a Parval Object
        */
       sts = EMgetparval_object( &loc_msg, osnum, NULL,
                          &(parent_info->sweep_extent.start_sweep_angle[0]),
                          &((*parents)[indx++]) );
       EMerr_hndlr( !(sts & loc_msg & 1), *EFmsg, EMS_E_Fail, wrapup );

       /*
        * Create a Parval Object
        */
       sts = EMgetparval_object( &loc_msg, osnum, NULL,
                         &(parent_info->sweep_extent.start_sweep_angle[1]), 
                         &((*parents)[indx++]) );
       EMerr_hndlr( !(sts & loc_msg & 1), *EFmsg, EMS_E_Fail, wrapup );
     }
   }
   else if( recomp_info->props & EMSAddRm_FromTo )
   {
     /*
      * Just populate the parents
      */
     if( !(recomp_info->props & EMSAddRm_NoFromSurf) )
       OM_BLOCK_MOVE( &(parent_info->sweep_extent.from_to_surfaces[0]), 
                      &((*parents)[indx++]), sizeof( struct EMSobject_info));

     if( !(recomp_info->props & EMSAddRm_NoToSurf) )
       OM_BLOCK_MOVE( &(parent_info->sweep_extent.from_to_surfaces[1]), 
                      &((*parents)[indx++]), sizeof( struct EMSobject_info));
   }

   /*
    * Fifth Parent : Base solid it self
    * Just populate the parents list
    */
   OM_BLOCK_MOVE( &(parent_info->base_solid), &((*parents)[indx++]),
                     sizeof( struct EMSobject_info) );

   if( indx != nparents )
   {
       sts = OM_E_ABORT;
       *EFmsg = EMS_E_Fail;
       goto wrapup;
   }

   /*
    * Whether an object of class of "EMSslfeature" or "EMSsffeature" to be 
    * constructed depends on whether last parent is a surface/solid, so check
    * for the same.
    */

   sts = om$get_classid ( objid = ((*parents)[indx-1]).grid.objid, 
                          osnum = ((*parents)[indx-1]).grid.osnum,
                          p_classid = &class_id);
   EMerr_hndlr(!(1&sts), *EFmsg, EMS_E_OMerror, wrapup);

   sts = om$is_ancestry_valid( subclassid   = class_id,
                               superclassid = OPP_EMSsolid_class_id);
   EMerr_hndlr (!(1&sts), *EFmsg, EMS_E_OMerror, wrapup);

   *solid_feature = (sts == OM_S_SUCCESS)? TRUE : FALSE;

wrapup:
   EMWRAPUP( *EFmsg, sts, "IN EFfea_get_add_rem_matl_parent_info");
   return (sts);
}

end implementation EMSsffeature;
