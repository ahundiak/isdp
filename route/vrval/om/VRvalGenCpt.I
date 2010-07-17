/***************************************************************************
 * I/VDS
 *
 * File:        vrval/om/VRvalGenCpt.I
 *
 * Description: Generate VRcpt xml
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VRvalGenCpt.I,v $
 *      Revision 1.3  2002/06/14 13:32:28  jdsauby
 *      JDS, dangles crashed due to bad return connect point data.
 *
 *      Revision 1.2  2002/06/07 14:50:52  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/08/24 20:10:11  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 08/03/01  ah      Creation
 ***************************************************************************/

class implementation Root;

#include "VDtypedef.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDbuf.h"
#include "VDtest.h"
#include "VDobj2.h"
#include "VDgeomc.h"

#include "VDval.h"
#include "VDvalLike.h"

#include "VDctx.h"
#include "VDss.h"

#include "macro.h"
#include "acmacros.h"

VDASSERT_FFN("VRvalGenCpt.I");

from VRGeneric import VRGetNumberOfCpts;
from VRGeneric import VRGetCptProp;
from VRGeneric import VRGetCptGeom;

/* -----------------------------------------------
 * Convert a connect point to dom
 * The actual input will be a VRgeneric object 
 *
 * For now, always require a parent since multiple cpts are common
 */
IGRstat VRvalConvertCptsToDom(TGRobj_env *genericOE, TGRid *parentID, TGRid *cptsID)
{
  VDASSERT_FN("VRvalConvertCptsToDom");
  
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  IGRchab buf;

  IGRint i;
  
  TGRid parentIDx;

  TGRid  cptID;
  IGRint cptCnt = 0;
  struct VRcp_attr cptProps;

  IGRpoint org,axis,orn;
  
  // Arg check
  VDASSERTW(cptsID); cptsID->objid = NULL_OBJID;
  VDASSERTW(genericOE && genericOE->obj_id.objid != NULL_OBJID);
  VDASSERTW(parentID && parentID->objid != NULL_OBJID);
  
  // Verify
  sts = VDobjIsAncestryValid(genericOE,NULL,OM_K_NOTUSING_CLASSID,"VRGeneric");
  VDASSERTW(sts);

  // Process connect points
  sts = om$send(msg = message VRGeneric.
		VRGetNumberOfCpts(&msg,&cptCnt,&genericOE->mod_env),
		senderid = NULL_OBJID,
		targetid = genericOE->obj_id.objid,
		targetos = genericOE->obj_id.osnum);
  VDASSERTW(sts & msg & 1);
  if (cptCnt <= 0) goto wrapup;
  if (cptCnt == 1) parentIDx = *parentID;
  else {
    VDctxCreateNode(parentID,VDCTX_NODE_TYPE_SS_OM_CPTS,NULL,&parentIDx);
    VDASSERTW(parentIDx.objid != NULL_OBJID);
  }
  
  // Cycle through
  for(i = 0; i < cptCnt; i++) {

    // Create the cpt object
    VDctxCreateNode(&parentIDx,VDCTX_NODE_TYPE_SS_OM_CPT,NULL,&cptID);
    VDASSERTW(cptID.objid != NULL_OBJID);

    // Get the properties
    memset(&cptProps,0,sizeof(struct VRcp_attr));
    msg = MSSUCC;
    sts = om$send(msg = message VRGeneric.
	    VRGetCptProp(&msg,i,&cptProps,&genericOE->mod_env),
	    senderid = NULL_OBJID,
	    targetid = genericOE->obj_id.objid,
	    targetos = genericOE->obj_id.osnum);

    /* -------------------------------------------
     * It appears that dangles will indicate a failure?
     * The data looks ok then the geom method seems to work
     * So I guess we ignore it for now
     * JDS, starting point dangles cause a failure as the data is
     * not returned correctly.  Once a dangle has been recomputed or modified
     * then it will not have a problem.  The current work around is to reset
     * the data to 0 on failure, and allow it to continue.
     */
    //VDASSERTW(sts & msg & 1);
    if (!(sts & msg & 1)) memset(&cptProps,0,sizeof(struct VRcp_attr));
    
    VDctxAppDblAtr(&cptID,"width",       cptProps.width);
    VDctxAppDblAtr(&cptID,"depth",       cptProps.depth);
    VDctxAppIntAtr(&cptID,"section_mask",cptProps.section_mask);
    VDctxAppIntAtr(&cptID,"end_prep",    cptProps.end_prep);
    VDctxAppDblAtr(&cptID,"pressure",    cptProps.pressure);
    VDctxAppDblAtr(&cptID,"cp_offset",   cptProps.cp_offset);

    // Get the geometry
    sts = om$send(msg = message VRGeneric.
	    VRGetCptGeom(&msg,i,org,axis,orn,&genericOE->mod_env),
	    senderid = NULL_OBJID,
	    targetid = genericOE->obj_id.objid,
	    targetos = genericOE->obj_id.osnum);
    VDASSERTW(sts & msg & 1);

    VDvalConvertPointToText(org,buf);
    VDctxAppTxtAtr(&cptID,"origin",buf);
    VDvalConvertPointToText(axis,buf);
    VDctxAppTxtAtr(&cptID,"axis",buf);
    VDvalConvertPointToText(orn,buf);
    VDctxAppTxtAtr(&cptID,"orientation",buf);

  }
  
  // Results
  if (cptCnt == 1) *cptsID = cptID;
  else             *cptsID = parentIDx;
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}


end implementation Root;
