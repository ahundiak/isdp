class implementation EMSsffeature;


/*****************************************************************
Description
 This method does the actual construction of a feature.

ARGUMENTS

INPUT
  options:         Ubiquitous argument.
  num_parents:     Number of parents.
  list:            GRid of parents.
  type:            Type to interpret the recomputation information.
  recomp_info:     Recomputation information. 
  construct_list:  Construction information.

OUTPUT
 EMmsg: Completion code.

Notes
  Upon exit the completion code will be one of the following:
  EMS_S_Success : If all goes well.
  EMS_E_Fail : For fatal errors whose exact cause cannot be determined.

History

   NP    06/24/93   Creation.
*******************************************/

#include "EMSasfeatdef.h"
#include "emsfeaopts.h"
#include "EMSutlmacros.h"
#include "REaddrmfea.h"

void EFfea_get_add_rem_matl_parent_types();
void EFfea_get_rib_parent_types();
IGRlong EMmake_feature();
void EFfea_get_parent_types();

method EMconstruct_associative(IGRlong *EMmsg; 
                               IGRushort options;
                               GRobjid  old_objid; 
                               IGRint num_parents; 
                               IGRchar *parent_info;
                               IGRint type; 
                               IGRchar *recomp_info; 
                               struct GRvg_construct *construct_list)
{
IGRlong  sts, msg_loc;
IGRuint    *parent_types;
struct EMSfeature_data *feature_recomp_data;
IGRboolean recompute;
struct GRid feature_id;
union EMSparent_info *parents;
OM_S_CHANSELECT to_comps;

IGRboolean aflag;



*EMmsg = EMS_S_Success;
sts    = OM_S_SUCCESS;
parent_types = NULL;
parents = NULL;

/* make necessary channel connections */
ems$make_chanselect (chan_label    = GRcmpowner_to_components,
                     chan_selector = &to_comps);

recompute = options & EMSasconst_recompute;
feature_recomp_data = (struct EMSfeature_data *) (recomp_info);

/* allocate array for parent types */
parent_types = (IGRuint *) alloca (sizeof (IGRuint) * num_parents);

/* allocate array for parents */
parents = (union EMSparent_info *)alloca(sizeof(union EMSparent_info)*
                  num_parents);

/* fill the "parent_types" array with the type of each parent in "parent_info"*/
EFfea_get_parent_types(&msg_loc, type, feature_recomp_data, num_parents, 
          parent_types); 
EMerr_hndlr(!(1&sts&msg_loc), *EMmsg, msg_loc, wrapup);

/* get the actual parents in array "parents" */
sts = om$send (msg = message EMSassoc.EMget_parent_info(&msg_loc,NULL,
                        num_parents, parent_info, parent_types, parents),
          targetid = my_id);
EMerr_hndlr(!(1&sts&msg_loc), *EMmsg, msg_loc, wrapup);

/** Check for recompute and activation flag
 ** If !recompute and aflag then change the env matrix
 **/

  aflag = pwIsActivationOn();
  if (aflag)
  {
     if (!recompute)
     {
        struct GRmd_env rfenv;

        pwGetActiveModuleEnv(&rfenv);

        /** Zeroth - always profile 
         ** last  - always base solid
         **/
        memcpy(&(parents[0].grobj.env), &rfenv, sizeof(struct GRmd_env)); 
        memcpy(&(parents[num_parents - 1].grobj.env), &rfenv, sizeof(struct GRmd_env)); 
     }
  }

/* call the main function that creates the feature. This function should also 
 * do validation of parents etc. to make sure feature is creatable.
 */

feature_id.osnum = OM_Gw_current_OS;
feature_id.objid = my_id;

sts = EMmake_feature(
                &msg_loc, 
                construct_list,
                type,
                num_parents,
                parent_types,
                parents,
                feature_recomp_data,
                &feature_id);
EMerr_hndlr(!(1&sts&msg_loc), *EMmsg, msg_loc, wrapup);

wrapup:

        /* Disconnect the components when an error occurs
         * BUT ONLY IF NOT IN RECOMPUTE!!!!
         */
        if(!(1&sts&*EMmsg) && !recompute)
        {
           IGRlong om_stat;
           OMuint comp_count = 0;
                
           om_stat = om$get_channel_count(
                         osnum        = feature_id.osnum,
                         objid        = feature_id.objid,
                         p_chanselect = &to_comps,
                         count        = &comp_count);

           if(comp_count) 
           {
              om$send( msg = message GRconnector.GRdisconn(&msg_loc,
                                                   &feature_id),  
                  p_chanselect = &to_comps);
           }
        }

        EMWRAPUP (*EMmsg,sts, "In EMSsffeature: construct associative");
        return (sts);
}

/****************************************************************************/
IGRlong EMmake_feature(
            EMmsg, 
            construct_list,
            assoc_type,
            num_parents,
            parent_types,
            parents,
            feature_recomp_data,
            feature_id)
IGRlong                *EMmsg; 
struct GRvg_construct  *construct_list;
IGRint                  assoc_type;
IGRint                  num_parents;
IGRuint                *parent_types;
union  EMSparent_info  *parents;
struct EMSfeature_data *feature_recomp_data;
struct GRid            *feature_id;
{
 
  IGRlong  sts, msg_loc;

  sts    = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success; 

  /* depending on the assoc type, we call different functions to create the 
   * specific type of feature.
   */

  switch (assoc_type)
  {
    case EMS_ASSOC_FEATURE_RIB:
      sts = EMmake_associative_rib_feature (&msg_loc,
                                            construct_list,
                                            num_parents,
                                            parent_types,
                                            parents,
                                            feature_recomp_data,
                                            feature_id);
      EMerr_hndlr (!(1&sts&msg_loc), *EMmsg, msg_loc, wrapup);
      break;
    case EMS_ASSOC_FEATURE_ADD_MATERIAL:
    case EMS_ASSOC_FEATURE_REMOVE_MATERIAL:
      sts = EMmake_associative_add_rem_matl_feature( &msg_loc,
                                            assoc_type,
                                            construct_list,
                                            num_parents,
                                            parent_types,
                                            parents,
                                            feature_recomp_data,
                                            feature_id);
      EMerr_hndlr (!(1&sts&msg_loc), *EMmsg, msg_loc, wrapup);
      break;

    default:
      break;
  } 

  wrapup:

  EMWRAPUP (*EMmsg,sts, "In EMmake_feature");
  return(sts);  
}

/******************************************************************************/
void EFfea_get_parent_types(EFmsg, 
                            assoc_type,
                            feature_recomp_data, 
                            num_parents, 
                            parent_types)  

IGRlong   *EFmsg, num_parents;
IGRchar   *feature_recomp_data;
IGRuint   *parent_types;
IGRint    assoc_type;
{

 IGRlong sts;

 sts    = OM_S_SUCCESS;
 *EFmsg = EMS_S_Success;
 
 switch (assoc_type)
 {
   case EMS_ASSOC_FEATURE_RIB:
      EFfea_get_rib_parent_types(EFmsg,
                                 (struct EMSfeature_data *)feature_recomp_data,
                                 num_parents,
                                 parent_types);
      EMerr_hndlr (!(1&*EFmsg), *EFmsg, *EFmsg, wrapup);
      break;

   case EMS_ASSOC_FEATURE_ADD_MATERIAL:
   case EMS_ASSOC_FEATURE_REMOVE_MATERIAL:
      EFfea_get_add_rem_matl_parent_types(EFmsg,
                   (struct EMSAddRm_RecompInfo *) feature_recomp_data,
                   num_parents,
                   parent_types);
      EMerr_hndlr (!(1&*EFmsg), *EFmsg, *EFmsg, wrapup);
      break;

   default:
      EMerr_hndlr (TRUE, *EFmsg, EMS_E_Fail /* INVALID FEATURE*/, wrapup);
} 


wrapup:
  EMWRAPUP (*EFmsg, sts, "EFfea_get_parent_types");
}
/******************************************************************************/

void EFfea_get_rib_parent_types(EFmsg, 
                                feature_recomp_data, 
                                num_parents, 
                                parent_types)

IGRlong                       *EFmsg, num_parents;
struct EMSfeature_data  *feature_recomp_data;
IGRuint                       *parent_types;
{

      IGRlong sts;
      IGRlong parent_num=0;

       sts = OM_S_SUCCESS;
      *EFmsg = EMS_S_Success;

      parent_num=0; 

      parent_types[parent_num++] = EMSgrid;   /* profile id */
      parent_types[parent_num++] = EMSscalar; /* thickness.(OR EMSdistance??)*/

      /* whether thk vector should be flipped (valid only for one-sided rib) */
      if (!(feature_recomp_data->attributes & EMSfeature_symmetric))
          parent_types[parent_num++] = EMSscalar; 

      /* whether proj vector should be flipped */     
      parent_types[parent_num++] = EMSscalar;

      /*whether feature is finite */
      if (feature_recomp_data->attributes & EMSfeature_finite) 
          parent_types[parent_num++] = EMSscalar;

      parent_types[parent_num++] = EMSgrid;   /* base surface/solid  id */

      /* UPDATE THIS CHECK BASED ON MAX. and MIN. PARENTS POSSIBLE */
      if ( (parent_num <4) || (parent_num >6) || (parent_num!=num_parents) )
      { *EFmsg = EMS_E_InvalidArg;
        goto wrapup;
      }

wrapup:
  EMWRAPUP (*EFmsg, sts, "EFfea_get_rib_parent_types");
}

/******************************************************************************/
void EFfea_get_add_rem_matl_parent_types(EFmsg, 
                                recomp_info, 
                                num_parents, 
                                parent_types)  

IGRlong                     *EFmsg, num_parents;
struct EMSAddRm_RecompInfo  *recomp_info;
IGRuint                     *parent_types;
{
    IGRint  parent;
    IGRlong sts;
 
    /*
     * Initilization of local variables and Validation of incoming arguments
     */
    sts = OM_S_SUCCESS;
    *EFmsg = EMS_S_Success;
    parent = 0;
    if( !parent_types || !recomp_info )
    {
        *EFmsg = EMS_E_InvalidArg;
        goto wrapup;
    }

    /* 
     * 1st Parent : Always a profile
     */
    parent_types[parent++] = EMSgrid; /* Profile location info */

    /*
     * 2nd Parent : Sweep direction 
     */
    if( (recomp_info->props & EMSAddRm_Project) ) 
    {
        parent_types[parent++] = EMSvector; /* Projection vector */
    }
    else if( recomp_info->props & EMSAddRm_Revolve )
    {
        parent_types[parent++] = EMSpoint;  /* Rotational axis starting point */
        parent_types[parent++] = EMSvector; /* Rotational axis vector */
    }
    else if( recomp_info->props & EMSAddRm_Skinned )
    {
        parent_types[parent++] = EMSgrid; /* Trace curve id */
    }

    /*
     * 3rd Parent : if from_to : from and to surface ids
     * 4th Parent : if finite  : Projection distance and distance from the 
     *                           plane of the profile to the start point of 
     *                           the projection along the profile normal 
     *                           vector/ Start and Sweep Angle
     */
    if( !(recomp_info->props & EMSAddRm_Skinned) && 
        recomp_info->props & EMSAddRm_Finite )
    {
       parent_types[parent++] = EMSscalar;
       parent_types[parent++] = EMSscalar;
    }
    else if( recomp_info->props & EMSAddRm_FromTo )
    {
       if( !(recomp_info->props & EMSAddRm_NoFromSurf) )
         parent_types[parent++] = EMSgrid;
       if( !(recomp_info->props & EMSAddRm_NoToSurf) )
         parent_types[parent++] = EMSgrid;
    } 
  
    /*
     * 6th Parent : Always Base solid id 
     */
    parent_types[parent++] = EMSgrid;
   
    EMerr_hndlr( (num_parents != parent ), *EFmsg, EMS_E_InvalidArg, wrapup);       
wrapup:
  EMWRAPUP (*EFmsg, sts, "IN EFfea_get_add_rem_matl_parent_types");
}
/******************************************************************************/
end implementation EMSsffeature;
