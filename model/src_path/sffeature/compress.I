/*
 OVERVIEW

 APIs for compressing the feature tree and to compress the range of the
 faces on the surface entities.

 NOTES

 HISTORY

 Aditya  04/17/96   Creation

*/

class implementation Root;

#include <alloca.h>
#include "OMmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "EMSprop.h"
#include "EMSmsgdef.h"
#include "EMSdef.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWapi/clsid.h"

from EMSdpr import EMmake_primitive1, EMget_dpr_props;
from EMSsubbs import EMreduce_range;

extern OMuword OPP_EMSdpr_class_id;
extern OMuword OPP_EMSsurface_class_id;
extern OMuword OPP_EMSsubbs_class_id;

/*
  DESCRIPTION

  Given the objid of a surface entity (solid, dpr state, composite
  surface or a single surface) this API will return an equivalent
  compressed surface entity. Given the top node of a dpr tree, the
  primitive solid corresponding to the current B-rep is evaluated
  by removing the other nodes in the tree. The surfaces and also
  the surfaces on the composites and soilds are extracted as a
  partial surface of the original surface such that the range of the
  loopset is as close to the (0,0),(1,1) range as possible.

  ARGUMENTS

  PWobjid sf_entity             -I : Surface entity to be compressed.
  PWosnum os                    -I : OS number of the surface entity.
  PWobjid *comp_entity          -O : Compressed surface entity.

  RETURN VALUE

  PWresult

  NOTES

  CAVEATS

  HISTORY

  Aditya   04/18/96     Creation.
*/

PWresult pwCompressSurfaceEntity
(
  PWobjid sf_entity,
  PWosnum os,
  PWobjid *comp_entity
)
{
  PWboolean reset_os=FALSE;
  PWresult PWsts=PW_K_Success;
  PWclassid classid;
  PWosnum save_os;
  PWobjid sfid=PW_K_NullObjid;

  int sts=1;
  long msg=EMS_S_Success;
  unsigned short props=0;

  struct GRmd_env md_env;
  struct GRid new_id;

  /*
   * Switch OS.
   */
  if((save_os = pwGetActiveOs()) != os)
  {
    PWsts = pwActivateOS(os);
    OnErrorState ( !(1&PWsts), PWsts,
                   SetError( PW_K_Pathway, PW_K_InvalidArg), wrapup);

    reset_os = TRUE;
  }

  /*
   * Validate the incoming surface entity.
   */
  sts = om$is_objid_valid ( objid = sf_entity, osnum = os);
  OnErrorState(!(1&sts), PWsts, 
               SetError( PW_K_Pathway, PW_K_InvalidArg), wrapup);

  classid = omClassidFromObjid ( sf_entity , os ) ;
  OnErrorState(!(omIsAncestryValid ( classid , OPP_EMSsurface_class_id )),
               PWsts, SetError( PW_K_Pathway, PW_K_InvalidArg), wrapup);

  /*
   * If the surface entity is a state in the DPR tree, retain only
   * the latest b-rep.
   */
  if ( omIsAncestryValid ( classid , OPP_EMSdpr_class_id ))
  {
    /*
     * Allow compression only if this is an active state of the 
     * feature tree i.e. we don't allow compression of only part of
     * a feature tree.
     */
    sts = om$send(msg = message EMSdpr.EMget_dpr_props( &msg, &props),
                  senderid = PW_K_NullObjid,
                  targetid = sf_entity,
                  targetos = os);
    OnErrorState(!(1 & msg & sts), PWsts,
                 SetError( PW_K_Pathway, PW_K_Error), wrapup);

    OnErrorState(!(props & EMSIS_ACTIVE_STATE), PWsts, 
                 SetError( PW_K_Pathway, PW_K_InvalidArg), wrapup);

    sts = om$send(msg = message EMSdpr.EMmake_primitive1(&msg,
                                                         &md_env,
                                                         &new_id),
                  senderid  = PW_K_NullObjid,
                  targetid = sf_entity,
                  targetos = os);
    OnErrorState(!(1 & msg & sts), PWsts, 
                 SetError( PW_K_Pathway, PW_K_Error), wrapup);

    /*
     * From here on the objid that is returned to the caller (on error)
     * will be the id of the compressed dpr tree, and not the original 
     * tree state which doesn't exist anymore.
     */
    sf_entity = new_id.objid;

    classid = omClassidFromObjid ( sf_entity , os ) ;
  }

  /*
   * If sf_entity is a surface, composite surface or a compressed
   * feature tree, reduce the loopset range on the surfaces.
   */

  if ( omIsAncestryValid ( classid , OPP_EMSsubbs_class_id ))
  {
    /*
     * sf_entity is a single surface.
     */
    sts = om$send(msg = message EMSsubbs.EMreduce_range(&msg,
                             &md_env, &sfid, 0),
                  senderid = PW_K_NullObjid,
                  targetid = sf_entity,
                  targetos = os);
    OnErrorState(!(1 & msg & sts), PWsts, 
                  SetError( PW_K_Pathway, PW_K_Error), wrapup);

    sf_entity = sfid;
  }
  else
  {
    /*
     * the surface entitty is either a  composite surface or a solid
     * from the dpr tree compress.
     */
    OM_S_CHANSELECT to_comps;

    sts = EMmake_chanselect (GRcmpowner_to_components, &to_comps);
    OnErrorState(!(1&sts), PWsts, SetError( PW_K_Pathway, PW_K_Error), wrapup);
    
    sts = om$send(msg = message EMSsubbs.EMreduce_range(&msg,
                             &md_env, &sfid, 0),
                  senderid = sf_entity,
                  targetos = os,
                  p_chanselect = &to_comps);
    OnErrorState(!(1 & msg & sts), PWsts, 
                 SetError( PW_K_Pathway, PW_K_Error), wrapup);
  }

wrapup :
  /*
   * Switch back to original OS.
   */
  if(reset_os)
  {
    PWsts = pwActivateOS(save_os);
    if(!(1&PWsts))
      PWsts = SetError( PW_K_Pathway, PW_K_Error);
  }

  *comp_entity = sf_entity;

  return(PWsts);
}

end implementation Root;
