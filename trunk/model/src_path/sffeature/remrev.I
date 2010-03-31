/*
  OVERVIEW

  APIs for placement and query on revolved remove material feature.

  NOTES

*/

class implementation Root;

#include <math.h>
#include <alloca.h>
#include "OMmacros.h"
#include "bsvalues.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "ex.h"
#include "gr.h"
#include "dp.h"
#include "igr.h"
#include "igrdef.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "emsdef.h"
#include "nddef.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWmodel.h"
#include "PWapi/clsid.h"

#include "EMSprop.h"
#include "EMSmsgdef.h"
#include "EMSasnucdef.h"
#include "EMSasnuc.h"
#include "EMSasopts.h"
#include "REaddrmfea.h"
#include "EMSfeadef.h"
#include "EMSasfeatdef.h"
#include "addrmopts.h"
#include "valinfo.h"
#include "PWapi/addrm.h"

#include "bsparameters.h"
#include "bserr.h"
#include "bsdotp.h"
#include "bscvtstclsd.h"
#include "bsnorvec.h"

from GRvg import GRgetsymb;
from GRvg import GRdetplane;
from EMSdpr import EMsetprops;
from EMSassoc import EMget_info, EMget_parent_info;
from NDnode import NDget_objects;

extern OMuword OPP_EMSslfeature_class_id;
extern OMuword OPP_EMSsolid_class_id;
extern OMuword OPP_SKgeometry_class_id;
extern OMuword OPP_EMSsurface_class_id;
extern OMuword OPP_EMSdatpln_class_id;
extern OMuword OPP_GAcurve_class_id, OPP_GRcurve_class_id;
extern OMuword OPP_GRcompcurve_class_id;
extern short _Pathway, _pathway_trim, _pathway_orient;

/*
  DESCRIPTION
 
  Places of features that remove material from the base solid (cutout
  features) by revolving a planar profile curve about an axis. The axis of
  revolution is specified by a point and a parallel vector. The direction of
  revolution is decided based on the right hand rule applied to the 
  'axis_vector'. If the user wants to remove material in the opposite 
  direction, the axis_vector will have to be flipped.

  This API supports all the feature extent options in enum PWaddremexttype.

  ARGUMENTS

  PWobjid solid                    -I : Base solid from which material is to 
                                        be removed.
  PWosnum os                       -I : OS number of the base solid
  PWobjid profile_curve            -I : Object id of the curve or composite 
                                        curve using which the material is
                                        removed.
  PWpoint axis_point               -I : Base point of the axis of revolution.
  PWvector axis_vector             -I : Direction vector of the axis of 
                                        revolution.
  PWboolean rem_matl_on_right      -I : Flag indicating that material is to 
                                        be removed to the right of the profile
                                        curve.
  enum PWaddremexttype ext_type    -I : Extent type.
  PWobjid from_sf                  -I : From surface id.
  PWobjid to_sf                    -I : From surface id.
  struct PWvalueinfo *start_angle  -I : Start angle value.
  struct PWvalueinfo *sweep_angle  -I : Start angle value.
  PWobjid *mod_solid               -O : Feature solid id.

  NOTES

  Memory for outputting the mod_solid should be provided by the caller.

  HISTORY

  Aditya   03/19/95    Creation
*/

PWresult pwRemMaterialRevolved
(
  PWobjid solid,
  PWosnum os,
  PWobjid profile_cv,
  PWpoint axis_point,
  PWvector axis_vector,
  PWboolean rem_matl_on_right,
  enum PWaddremexttype ext_type,
  PWobjid from_sf,
  PWobjid to_sf,
  struct PWvalueinfo *start_angle,
  struct PWvalueinfo *sweep_angle,
  PWobjid *mod_solid
)
{
  int prof_geom_size = 0;
  long status=0;
  short save_pw_trim, save_pw_orient;

  PWboolean assoc_status = 0 , stat = 0, reset_os=FALSE;
  PWresult result ;
  PWclassid classid ;
  PWosnum save_os;
  PWvector cvnormal;
  PWpoint point;

  BSrc rc;
  IGRushort option = 0;
  IGRlong msg_loc;
  struct IGRdisplay disp_attrib;
  struct IGRbsp_curve *p_profgeom = NULL;

  struct GRid add_mat_feat;
  struct GRmd_env               md_env;
  struct GRsymbology           symbology;
  struct GRvg_construct        const_args;
  struct EMSAddRm_RecompInfo   recomp_info;
  struct EMSAddRm_ParentInfo   parent_info;

  extern long EFplace_feature ( );
  extern void EMinitvgcnstr ( );
  extern IGRboolean EMgetvgcnstr ( );
  extern IGRboolean AddRmGetNormalOfPlaneOfPts ( int , double * ,
                                                 double * , double * ) ;

  result = PW_K_Success;
  msg_loc = EMS_S_Success;
  rc = BSSUCC;

  if(_Pathway)
  {
    save_pw_trim = _pathway_trim;
    save_pw_orient = _pathway_orient;

    _pathway_trim = 1;
    _pathway_orient = 1;
  }

  if(mod_solid)
    *mod_solid = NULL_OBJID;
  else
    OnErrorState ( TRUE, result, PW_K_InvalidArg, wrapup);
    
  gr$get_associative_flag(buffer = &assoc_status);
  option = ( assoc_status ? 0 : EMSasconst_notassociative);

  /*
   * Switch OS.
   */
  if((save_os = pwGetActiveOs()) != os)
  {
    stat = pwActivateOS(os);
    OnErrorState ( !(1&stat), result,
                   SetError( PW_K_Pathway, PW_K_InvalidArg), wrapup);

    reset_os = TRUE;
  }

  stat = pwGetActiveModuleEnv( &md_env);
  OnErrorState( !(1&stat), result,
                SetError( PW_K_Pathway, PW_K_Error), wrapup);

  /*
   * Validate the solid.
   */
  stat = om$is_objid_valid ( objid = solid , osnum = os ) ;
  OnErrorState( !stat, result, SetError(PW_K_Pathway, PW_K_InvalidArg), wrapup);

  classid = omClassidFromObjid ( solid , os ) ;
  if ( ! omIsAncestryValid ( classid , OPP_EMSsolid_class_id ))
  {
    OnErrorState( TRUE, result,
                  SetError( PW_K_Pathway, PW_K_InvalidArg), wrapup);
  }
  else if ( pwIsFeatureState(solid, os, NULL))
  {
    OnErrorState( !pwIsFeatureActive(solid, os), result,
                  SetError( PW_K_Pathway, PW_K_InvalidArg), wrapup);
  }

  parent_info.base_solid.grid.objid = solid;
  parent_info.base_solid.grid.osnum = os;

  /*
   * Get the symbology and the construct list.
   */
  stat = om$send ( msg = message GRvg.GRgetsymb ( &msg_loc, &symbology ),
                   senderid = NULL_OBJID,
                   targetid = solid,
                   targetos = os );
  OnErrorState( !(1 & stat & msg_loc), result,
                SetError( PW_K_Pathway, PW_K_Error), wrapup);

  EMinitvgcnstr( &msg_loc, &md_env, &disp_attrib, 0, &const_args);
  OnErrorState( !(1&msg_loc), result, 
                SetError( PW_K_Pathway, PW_K_Error), wrapup);

  stat = EMgetvgcnstr ( NULL, NULL, &md_env, symbology.level,
                        &symbology.display_attr, 0, 0, &const_args);
  OnErrorState( !stat, result, SetError( PW_K_Pathway, PW_K_Error), wrapup);

  const_args.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE | GRIS_NEW;

  /*
   * Validate the profile curve.
   */
  stat = om$is_objid_valid ( objid = profile_cv , osnum =  os ) ;
  OnErrorState( !stat, result,
                SetError( PW_K_Pathway, PW_K_InvalidArg), wrapup);

  classid = omClassidFromObjid ( profile_cv , os ) ;
  if ( ! omIsAncestryValid ( classid , OPP_GRcurve_class_id))
  {
    OnErrorState( TRUE, result,
                  SetError( PW_K_Pathway, PW_K_InvalidArg), wrapup);
  }

  parent_info.profile.grid.objid = profile_cv;
  parent_info.profile.grid.osnum = os;
  memcpy ( &parent_info.profile.env, &md_env, sizeof(struct GRmd_env));
  parent_info.profile.env.md_id.objid = profile_cv;

  prof_geom_size = pwGetCvSize( profile_cv, os);
  p_profgeom = (struct IGRbsp_curve *)alloca(prof_geom_size);
  OnErrorState( !p_profgeom, result, 
                SetError( PW_K_Pathway, PW_K_DynamicMemory), wrapup);

  result = pwGetCvAsBspline( profile_cv, os,
                             md_env.md_env.matrix_type,
                             md_env.md_env.matrix, p_profgeom);
  OnErrorState( !(1&result), result, result, wrapup);

  if( !omIsAncestryValid( classid, OPP_SKgeometry_class_id) &&
      !omIsAncestryValid( classid, OPP_GAcurve_class_id))
  {
    if(! AddRmGetNormalOfPlaneOfPts( p_profgeom->num_poles, p_profgeom->poles,
                                    p_profgeom->rational ?
                                    p_profgeom->weights : 0, cvnormal))
    {
      OnErrorState( TRUE, result, SetError( PW_K_Pathway, PW_K_Error), wrapup);
    }
  }

  parent_info.sweep_dir.rotational_axis[0].type = EMSdatainfo_numeric;
  memcpy( &(parent_info.sweep_dir.rotational_axis[0].pt),
          &axis_point[0], sizeof(PWpoint));

  /*
   * Calculate the second axis pt from the axis_point and axis_vector.
   */
  BSnorvec( &rc, axis_vector);
  OnErrorState ( BSERROR(rc), result, 
                 SetError( PW_K_Pathway, PW_K_Error), wrapup);

  point[0] = axis_point[0] + axis_vector[0];
  point[1] = axis_point[1] + axis_vector[1];
  point[2] = axis_point[2] + axis_vector[2];

  parent_info.sweep_dir.rotational_axis[1].type = EMSdatainfo_numeric;
  memcpy( &(parent_info.sweep_dir.rotational_axis[1].pt),
          &point[0], sizeof(PWpoint));

  /*
   * Initialise the properties.
   */
  recomp_info.props = 0;

  BScvtstclsd( p_profgeom, &rc);
  OnErrorState( BSERROR(rc), result, 
                SetError( PW_K_Pathway, PW_K_Error), wrapup);

  if( p_profgeom->phy_closed)
    recomp_info.props &= ~EMSAddRm_ProfOpen;
  else
    recomp_info.props |= EMSAddRm_ProfOpen;

  if(rem_matl_on_right)
    recomp_info.props |= EMSAddRm_MatInside;

  if(ext_type == to_next)
  {
    recomp_info.props |= EMSAddRm_ToNext;
  }
  else if(ext_type == from_to)
  {
    recomp_info.props |= EMSAddRm_FromTo;

    if(from_sf == NULL_OBJID)
      recomp_info.props |= EMSAddRm_NoFromSurf;
    else
    {
      /*
       * Validate "from" surface.
       */
       stat = om$is_objid_valid ( objid = from_sf , osnum =  os ) ;
       OnErrorState( !stat, result, 
                     SetError( PW_K_Pathway, PW_K_InvalidArg), wrapup);

       classid = omClassidFromObjid ( from_sf , os ) ;
       if ( ! omIsAncestryValid ( classid , OPP_EMSsurface_class_id) &&
            ! omIsAncestryValid (classid, OPP_EMSdatpln_class_id))
       {
         OnErrorState( TRUE, result,
                       SetError( PW_K_Pathway,  PW_K_Error), wrapup);
       }
    }

    if (to_sf == NULL_OBJID)
      recomp_info.props |= EMSAddRm_NoToSurf;
    else
    {
      /*
       * Validate "to" surface.
       */
       stat = om$is_objid_valid ( objid = to_sf , osnum =  os ) ;
       OnErrorState( !stat, result, 
                     SetError( PW_K_Pathway, PW_K_InvalidArg), wrapup);

       classid = omClassidFromObjid ( to_sf , os ) ;
       if ( ! omIsAncestryValid ( classid , OPP_EMSsurface_class_id) &&
            ! omIsAncestryValid (classid, OPP_EMSdatpln_class_id))
       {
         OnErrorState( TRUE, result, 
                       SetError( PW_K_Pathway, PW_K_Error), wrapup);
       }
    }

    if(from_sf == NULL_OBJID && to_sf == NULL_OBJID)
      OnErrorState(TRUE, result,
                   SetError( PW_K_Pathway, PW_K_InvalidArg), wrapup);

    parent_info.sweep_extent.from_to_surfaces[0].grid.objid = from_sf;
    parent_info.sweep_extent.from_to_surfaces[0].grid.osnum = os;

    parent_info.sweep_extent.from_to_surfaces[1].grid.objid = to_sf;
    parent_info.sweep_extent.from_to_surfaces[1].grid.osnum = os;

    memcpy(&(parent_info.sweep_extent.from_to_surfaces[0].env.md_env),
           &md_env.md_env, sizeof(struct GRmdenv_info));

    memcpy(&(parent_info.sweep_extent.from_to_surfaces[1].env.md_env),
           &md_env.md_env, sizeof(struct GRmdenv_info));
  }
  else if(ext_type == finite_one_sided)
  {
    recomp_info.props |= EMSAddRm_Finite;

    result = PutValueInfo (start_angle,
                             &parent_info.sweep_extent.start_sweep_angle[0]);

    result = PutValueInfo (sweep_angle,
                             &parent_info.sweep_extent.start_sweep_angle[1]);
  }
  else if(ext_type == finite_symmetric)
  {
    recomp_info.props |= EMSAddRm_Finite;
    recomp_info.props |= EMSAddRm_Symmetric;

    result = PutValueInfo (start_angle,
                             &parent_info.sweep_extent.start_sweep_angle[0]);

    result = PutValueInfo (sweep_angle,
                             &parent_info.sweep_extent.start_sweep_angle[1]);
  }
  else if ( ext_type == thru_all)
  {
    recomp_info.props |= EMSAddRm_ThruAll;
  }
  else
  {
    OnErrorState(TRUE, result, SetError( PW_K_Pathway, PW_K_Error), wrapup);
  }

  if(omIsAncestryValid( classid, OPP_GRcompcurve_class_id))
  {
    recomp_info.props |= EMSAddRm_ProfComposite;
  }

  recomp_info.props |= EMSAddRm_Revolve;

  add_mat_feat.objid = NULL_OBJID;
  add_mat_feat.osnum = os;

  status = EFplace_feature( &msg_loc, option,
                         EMS_ASSOC_FEATURE_REMOVE_MATERIAL,
                         (IGRchar *)&recomp_info,
                         (IGRchar *)&parent_info,
                         &const_args, &add_mat_feat );

  *mod_solid = add_mat_feat.objid;

  if (1 & status & msg_loc)
  {
    IGRboolean action = TRUE;
    IGRushort  bit=EMS_POST310_OBJECT | EMSIS_ACTIVE_STATE;

    status = om$send (msg = message EMSdpr.EMsetprops (&msg_loc,
                                      &action, &bit),
                    senderid = NULL_OBJID,
                    targetid = *mod_solid,
                    targetos = os);
  }
  else
  {
    OnErrorState(!(1 & status & msg_loc), result,
                 SetError( PW_K_Pathway, PW_K_Error), wrapup);
  }

wrapup :

  /*
   * Switch back to original OS.
   */
  if(reset_os)
  {
    stat = pwActivateOS(save_os);
    if(!(1&stat))
      result = SetError( PW_K_Pathway, PW_K_Error);
  }

  if(_Pathway)
  {
    _pathway_trim = save_pw_trim;
    _pathway_orient = save_pw_orient;
  }

  PW_Wrapup (result, "pwRemMaterialRevolved");
  return( result);

}


/*
  DESCRIPTION

  API for query of the parents of a revolved remove material feature.

  ARGUMENTS

  PWobjid feature_id               -I : The dpr state id of the feature.
  PWosnum os                       -I : OS number of the feature solid.
  PWobjid *profile_cv              -O : Id of the profile curve.
  PWpoint *axis_point              -O : Axis start point
  PWvector *axis_vector            -O : Axis direction.
  PWboolean *add_matl_on_right     -O : Flag indicating if material addition 
                                        was to the right of the curve.
  enum PWaddremexttype *ext_type   -O : The feature extent type.
  PWobjid *from_sf                 -O : From surface id.
  PWobjid *to_sf                   -O : To surface id.
  struct PWvalueinfo *start_angle  -O : Start angle.
  struct PWvalueinfo *sweep_angle  -O : Sweep angle.
  PWobjid *base_solid              -O : Base solid on which the feature was
                                        placed.

  NOTES

  Memory for all the output is to be provided by the caller.

  HISTORY

  Aditya  03/19/96   Creation.
*/

PWresult pwQueryRemMatRevolved
(
  PWobjid feature_id,
  PWosnum os,
  PWobjid *profile_cv,
  PWpoint *axis_point,
  PWvector *axis_vector,
  PWboolean *add_matl_on_right,
  enum PWaddremexttype *ext_type,
  PWobjid *from_sf,
  PWobjid *to_sf,
  struct PWvalueinfo *start_angle,
  struct PWvalueinfo *sweep_angle,
  PWobjid *base_solid
)
{
  int inx=0, num_parents=0;
  unsigned int info_size=0, type=0, *p_parenttypes=NULL;
  unsigned long feat_props=0;

  PWboolean stat = 0 ;
  PWresult result ;
  PWclassid classid ;

  BSrc rc;
  IGRlong msg_loc;

  struct GRid *p_parentobjs=NULL;

  struct EMSAddRm_RecompInfo recomp_info, *p_recompinfo=NULL;
  union EMSparent_info *p_parents=NULL;

  result = PW_K_Success;
  msg_loc = EMS_S_Success;
  rc = BSSUCC;
  stat = 1;

  if(base_solid)
    *base_solid = NULL_OBJID;
  else
    OnErrorState ( TRUE, result,
                   SetError( PW_K_Pathway, PW_K_InvalidArg), wrapup);
    
  /*
   * Validate the incoming feature id.
   */
  stat = om$is_objid_valid ( objid = feature_id , osnum = os ) ;
  OnErrorState( !stat, result, 
                SetError( PW_K_Pathway, PW_K_InvalidArg), wrapup);

  classid = omClassidFromObjid ( feature_id , os ) ;
  if ( ! omIsAncestryValid ( classid , OPP_EMSslfeature_class_id ))
  {
    OnErrorState( TRUE, result,
                  SetError( PW_K_Pathway, PW_K_InvalidArg), wrapup);
  }

  /*
   * Get the recompute info for the feature.
   */
  p_recompinfo = &recomp_info;
  stat = om$send (msg = message EMSassoc.EMget_info(&msg_loc,
                                                    NULL,
                                                    &type,
                                                    &info_size,
                                                    (char **)&p_recompinfo),
                  senderid = NULL_OBJID,
                  targetid = feature_id,
                  targetos = os );
  OnErrorState( !(1 & stat & msg_loc), result,
                SetError( PW_K_Pathway, PW_K_Error), wrapup);

  if(type != EMS_ASSOC_FEATURE_REMOVE_MATERIAL)
    OnErrorState( TRUE, result, 
                  SetError( PW_K_Pathway, PW_K_InvalidArg), wrapup);

  stat = om$send (msg = message NDnode.NDget_objects(ND_IN_BUF | ND_ROOT,
                                                       NULL, 0,
                                                       &p_parentobjs, 0,
                                                       MAXINT, &num_parents),
                    senderid = NULL_OBJID,
                    targetid = feature_id,
                    targetos = os );
  OnErrorState( !(1 & stat) || num_parents < 4, result, 
                SetError( PW_K_Pathway, PW_K_Error), wrapup);

  feat_props = p_recompinfo->props; 

  if(! feat_props & EMSAddRm_Revolve)
    OnErrorState( TRUE, result, 
                  SetError( PW_K_Pathway, PW_K_InvalidArg), wrapup);

  num_parents = 4;

  if( feat_props & EMSAddRm_Finite )
    num_parents = 6;

  if( feat_props & EMSAddRm_FromTo )
  {
     if( !(feat_props & EMSAddRm_NoFromSurf) )
       num_parents ++;
     if( !(feat_props & EMSAddRm_NoToSurf) )
       num_parents ++;
  }

  /* 
   * Allocate array for parent information.
   */
  p_parenttypes = (unsigned int *) alloca
                  (sizeof (unsigned int) * num_parents);
  p_parents = (union EMSparent_info *) alloca
              (sizeof(union EMSparent_info)* num_parents);
  OnErrorState ( !p_parenttypes || !p_parents, result, 
                 SetError( PW_K_Pathway, PW_K_Memory), wrapup);

  /*
   * Get the parent types.
   */
  EFfea_get_parent_types(&msg_loc,
                         type,
                         p_recompinfo,
                         num_parents,
                         p_parenttypes); 
  OnErrorState(!(1 & msg_loc), result, 
               SetError( PW_K_Pathway, PW_K_Error), wrapup);

  /* 
   * Get the actual parents.
   */
  stat = om$send (msg = message EMSassoc.EMget_parent_info(&msg_loc,
                                                           NULL,
                                                           num_parents,
                                                           NULL,
                                                           p_parenttypes,
                                                           p_parents ),
                  senderid = NULL_OBJID,
                  targetid = feature_id,
                  targetos = os );
  OnErrorState( !(1 & stat & msg_loc), result, 
                SetError( PW_K_Pathway, PW_K_Error), wrapup);

  inx = 0;

  /*
   * Get the profile id.
   */
  if(p_parenttypes[inx] == EMSgrid)
  {
    *profile_cv = p_parents[inx].grobj.grid.objid;
  }
  else OnErrorState(TRUE, result, SetError( PW_K_Pathway, PW_K_Error), wrapup);

  /*
   * Get the axis of revolution info.
   */
  if( p_parenttypes[++inx] == EMSpoint)
  {
    memcpy(axis_point, &p_parents[inx].point[0], sizeof(PWpoint));
  }
  else OnErrorState(TRUE, result, SetError( PW_K_Pathway, PW_K_Error), wrapup);

  if( p_parenttypes[++inx] == EMSvector)
  {
    memcpy(axis_vector, &p_parents[inx].vector[0], sizeof(PWvector));
  }
  else OnErrorState(TRUE, result, SetError( PW_K_Pathway, PW_K_Error), wrapup);

  /*
   * Get the info related to the feature extent.
   */
  if(feat_props & EMSAddRm_Finite)
  {
    *ext_type =  finite_one_sided;

    if(start_angle->type == value_name)
      GetExpressionFromParamvlObject(p_parentobjs[++inx].objid,
                                       os, start_angle);
    else
    {
      start_angle->value = p_parents[++inx].value;
      start_angle->type = value_numeric;
    }

    if(sweep_angle->type == value_name)
      GetExpressionFromParamvlObject(p_parentobjs[++inx].objid,
                                       os, sweep_angle);
    else
    {
      sweep_angle->value = p_parents[++inx].value;
      sweep_angle->type = value_numeric;
    }
  }
  else if(feat_props & EMSAddRm_Symmetric)
  {
    *ext_type = finite_symmetric;

    if(start_angle->type == value_name)
      GetExpressionFromParamvlObject(p_parentobjs[++inx].objid,
                                       os, start_angle);
    else
    {
      start_angle->value = p_parents[++inx].value;
      start_angle->type = value_numeric;
    }

    if(sweep_angle->type == value_name)
      GetExpressionFromParamvlObject(p_parentobjs[++inx].objid,
                                       os, sweep_angle);
    else
    {
      sweep_angle->value = p_parents[++inx].value;
      sweep_angle->type = value_numeric;
    }
  }
  else if(feat_props & EMSAddRm_FromTo)
  {
    *ext_type = from_to;

    if(!(feat_props & EMSAddRm_NoFromSurf))
      *from_sf = p_parents[++inx].grobj.grid.objid;

    if(!(feat_props & EMSAddRm_NoToSurf))
      *to_sf = p_parents[++inx].grobj.grid.objid;
  }
  else if(feat_props & EMSAddRm_ToNext )
  {
    *ext_type = to_next;
  }
  else if ( feat_props & EMSAddRm_ThruAll)
  {
    *ext_type = thru_all;
  }
  else
    OnErrorState(TRUE, result, SetError( PW_K_Pathway, PW_K_Error), wrapup);

  /*
   * The last parent is the base_solid.
   */
  if(p_parenttypes[++inx] == EMSgrid)
  {
    *base_solid = p_parents[inx].grobj.grid.objid;
  }
  else OnErrorState(TRUE, result, SetError( PW_K_Pathway, PW_K_Error), wrapup);

  /*
   * Get the material addition side.
   */
  if(feat_props & EMSAddRm_MatInside)
    *add_matl_on_right=TRUE;
  else
    *add_matl_on_right = FALSE;

wrapup :

  PW_Wrapup (result, "pwQueryAddMatRevolved");
  return( result);

}

end implementation Root;
