/*
  OVERVIEW

  APIs for placement and query on skinned add material features.

  NOTES

*/

class implementation Root;

#include <math.h>
#include <alloca.h>
#include "OMmacros.h"
#include "bsvalues.h"
#include "values.h"
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
#include "nddef.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWapi/clsid.h"

#include "EMSprop.h"
#include "EMSmsgdef.h"
#include "EMSasnuc.h"
#include "EMSasnucdef.h"
#include "EMSasopts.h"
#include "REaddrmfea.h"
#include "EMSfeadef.h"
#include "EMSasfeatdef.h"
#include "addrmopts.h"
#include "PWmodel.h"
#include "valinfo.h"
#include "PWapi/addrm.h"

#include "bsparameters.h"
#include "bserr.h"
#include "bscvtstclsd.h"

from GRvg import GRgetsymb;
from GRvg import GRdetplane;
from EMSdpr import EMsetprops;
from EMSassoc import EMget_info, EMget_parent_info;
from NDnode import NDget_objects;

extern OMuword OPP_EMSslfeature_class_id;
extern OMuword OPP_EMSsolid_class_id;
extern OMuword OPP_SKgeometry_class_id;
extern OMuword OPP_GAcurve_class_id;
extern OMuword OPP_GRcurve_class_id;
extern OMuword OPP_GRcompcurve_class_id;
extern short _Pathway, _pathway_trim, _pathway_orient;


/*
  DESCRIPTION

  Allows placement of features that add material to the base solid 
  (protrusion features) by skinning a planar profile curve along a trace
  curve. This feature allows only closed profile curves at the moment and
  material is added on the inside of the closed curve. The trace_curve may
  be a single or a composite curve object.

  This API supports only the 'finite_one_sided' and 'to_next' extent
  options in enum PWaddremexttype.

  NOTES

  Memory for outputting the mod_solid should be provided by the caller.

  ARGUMENTS

  PWobjid solid                  -I : Solid on which feature is to be placed.
  PWosnum os                     -I : OS number of the base solid
  PWobjid profile_curve          -I : Object id of the curve or composite curve                                       using which the material is added.
  PWobjid trace_curve            -I : Id of the trace curve object.
  enum PWaddremexttype ext_type  -I : Extent of material addition.
  PWboolean along_trace_curve    -I : TRUE if skinning is in the direction of
                                      parametric flow of the curve.
  PWobjid *mod_solid             -O : Feature id of the modified solid.

  RETURN VALUE

  PWresult

  HISTORY

  Aditya   03/19/96   Creation.
*/

PWresult pwAddMaterialBySkinning
(
  PWobjid solid ,
  PWosnum os ,
  PWobjid profile_cv ,
  PWobjid trace_curve,
  enum PWaddremexttype ext_type ,
  PWboolean along_trc_cv,
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
    OnErrorState ( TRUE, result, 
                   SetError( PW_K_Pathway, PW_K_InvalidArg), wrapup);
    
  /*
   * Replace by a Pathway function when it becomes available.
   */
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
  OnErrorState( !stat, result, 
                SetError( PW_K_Pathway, PW_K_InvalidArg), wrapup);

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
  OnErrorState( !stat, result, 
                SetError( PW_K_Pathway, PW_K_Error), wrapup);

  const_args.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE | GRIS_NEW;

  /*
   * Validate the trace curve.
   */
  stat = om$is_objid_valid ( objid = trace_curve , osnum =  os ) ;
  OnErrorState( !stat, result, 
                SetError( PW_K_Pathway, PW_K_InvalidArg), wrapup);

  classid = omClassidFromObjid ( trace_curve , os ) ;
  if ( ! omIsAncestryValid ( classid , OPP_GRcurve_class_id ))
  {
    OnErrorState( TRUE, result, 
                  SetError( PW_K_Pathway, PW_K_InvalidArg), wrapup);
  }

  parent_info.sweep_dir.trace_curve.grid.objid = trace_curve;
  parent_info.sweep_dir.trace_curve.grid.osnum = os;
  memcpy(&(parent_info.sweep_dir.trace_curve.env),
         &md_env, sizeof(struct GRmd_env));

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
                  SetError( PW_K_Pathway, PW_K_Error), wrapup);
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
    if(!AddRmGetNormalOfPlaneOfPts( p_profgeom->num_poles, p_profgeom->poles,
                                    p_profgeom->rational ?
                                    p_profgeom->weights : 0, cvnormal))
    {
      OnErrorState( TRUE, result, 
                    SetError( PW_K_Pathway, PW_K_Error), wrapup);
    }
  }

  /*
   * Initialise the properties.
   */
  recomp_info.props = 0;

  BScvtstclsd( p_profgeom, &rc);
  OnErrorState( BSERROR(rc), result, 
                SetError( PW_K_Pathway, PW_K_Error), wrapup);

  if( p_profgeom->phy_closed)
  {
    recomp_info.props |= EMSAddRm_MatInside;
    recomp_info.props &= ~EMSAddRm_ProfOpen;
  }
  else
  {
    /*
     * Open profiles are not handled at the moment in skinning.
     */
    OnErrorState ( TRUE, result, 
                   SetError( PW_K_Pathway, PW_K_InvalidArg), wrapup);
  }

  if(ext_type == to_next)
  {
    recomp_info.props |= EMSAddRm_ToNext;
  }
  else if(ext_type == finite_one_sided)
  {
    recomp_info.props |= EMSAddRm_Finite;
  }
  else
  {
    OnErrorState(TRUE, result, 
                 SetError( PW_K_Pathway, PW_K_InvalidArg), wrapup);
  }

  if (!along_trc_cv)
    recomp_info.props |= EMSAddRm_ReverseTrace;

  if(omIsAncestryValid( classid, OPP_GRcompcurve_class_id))
  {
    recomp_info.props |= EMSAddRm_ProfComposite;
  }

  recomp_info.props |= EMSAddRm_Skinned;

  add_mat_feat.objid = NULL_OBJID;
  add_mat_feat.osnum = os;

  status = EFplace_feature( &msg_loc, option,
                         EMS_ASSOC_FEATURE_ADD_MATERIAL,
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

  PW_Wrapup (result, "pwAddMaterialBySkinning");
  return( result);
}

/*
  DESCRIPTION

  API for query on the parents of a skinned add material feature.

  ARGUMENTS


  PWobjid feature_id             -I : The dpr state id of the feature.
  PWosnum os                     -I : OS number of the feature solid.
                                      material feature.
  PWobjid *profile_cv            -O : Id of the profile curve.
  PWobjid *trace_cv              -O : Id of the trace curve.
  enum PWaddremexttype *ext_type -O : Feature extent type.
  PWboolean along_trace_curve    -O : TRUE if the skinning direction was
                                      along the parametric flow direction of
                                      the trace_curve.
  PWobjid *base_solid            -O : Base solid on which the feature was
                                      placed.
  NOTES

  Memory for all the output is to be provided by the caller.

  HISTORY

  Aditya  03/19/96   Creation.
*/
 

PWresult pwQueryAddMatBySkinning
(
  PWobjid feature_id,
  PWosnum os,
  PWobjid *profile_cv,
  PWobjid *trace_cv,
  enum PWaddremexttype *ext_type,
  PWboolean *along_trace_curve,
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

  if(type != EMS_ASSOC_FEATURE_ADD_MATERIAL)
    OnErrorState( TRUE, result, 
                  SetError( PW_K_Pathway, PW_K_InvalidArg), wrapup);

  stat = om$send (msg = message NDnode.NDget_objects(ND_IN_BUF | ND_ROOT,
                                                       NULL, 0,
                                                       &p_parentobjs, 0,
                                                       MAXINT, &num_parents),
                    senderid = NULL_OBJID,
                    targetid = feature_id,
                    targetos = os );
  OnErrorState( !(1 & stat) || num_parents < 3, result, 
                SetError( PW_K_Pathway, PW_K_Error), wrapup);

  feat_props = p_recompinfo->props; 

  if(! feat_props & EMSAddRm_Skinned)
    OnErrorState( TRUE, result, 
                  SetError( PW_K_Pathway, PW_K_InvalidArg), wrapup);

  num_parents = 3;

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
    *profile_cv = p_parents[inx++].grobj.grid.objid;
  }
  else OnErrorState(TRUE, result, 
                    SetError( PW_K_Pathway, PW_K_Error), wrapup);

  /*
   * Get the trace_cv id.
   */
  if(p_parenttypes[inx] == EMSgrid)
  {
    *trace_cv = p_parents[inx++].grobj.grid.objid;
  }
  else OnErrorState(TRUE, result, 
                    SetError( PW_K_Pathway, PW_K_Error), wrapup);

  /*
   * Get the info related to the feature extent.
   */
  if(feat_props & EMSAddRm_Finite)
  {
    *ext_type =  finite_one_sided;
  }
  else if(feat_props & EMSAddRm_ToNext )
  {
    *ext_type = to_next;
  }
  else
    OnErrorState(TRUE, result, 
                 SetError( PW_K_Pathway, PW_K_Error), wrapup);

  /*
   * The last parent is the base_solid.
   */
  if(p_parenttypes[inx] == EMSgrid)
  {
    *base_solid = p_parents[inx].grobj.grid.objid;
  }
  else OnErrorState(TRUE, result, 
                    SetError( PW_K_Pathway, PW_K_Error), wrapup);

  if(feat_props & EMSAddRm_ReverseTrace)
    *along_trace_curve = FALSE;
  else
    *along_trace_curve = TRUE;

wrapup :

  PW_Wrapup (result, "pwQueryAddMatRevolved");
  return( result);

}

end implementation Root;
