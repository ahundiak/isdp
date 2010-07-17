/***************************************************************************
 * I/VDS
 *
 * File:        vrval/om/VRvalGenComp.I
 *
 * Description: Generate component xml
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VRvalGenComp.I,v $
 *      Revision 1.3  2002/06/07 15:54:58  ahundiak
 *      ah
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

VDASSERT_FFN("VRvalGenComp.I");

from ACncpx    import ACget_rep;
from ACpretend import ACgive_downscan;
from VRGeneric import VRGetMacro;
from VRGeneric import VRGetMatrix;

extern VDclassid OPP_VRCnrlSeg_class_id;
extern VDclassid OPP_VRplane_class_id;

from VRCnrlSeg import VRget_terminators;

/* -----------------------------------------------
 * Process a single parent VRplane
 * Does not do anything for now
 */
IGRstat VRvalGenProcessParentVRplane(TGRobj_env *childOE, 
				     TGRobj_env *parentOE,
				     IGRchar    *parentType,
		                     TGRid      *domID)
{
  VDASSERT_FN("VRvalGenProcessParentVRplane");
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  IGRint i;
  
  VDclassid classId;
  TGRid     parentID;
  TGRid     nodeID;

  IGRchab  txt;
  
  IGRdouble pts[6];
  
  // Init
  parentID = parentOE->obj_id;

  // Arg check
  VDASSERTW(domID && domID->objid != NULL_OBJID);
  VDASSERTW(parentOE && parentOE->obj_id.objid != NULL_OBJID);
  
  // Get the class
  sts = som_get_classid(parentID.osnum,NULL,parentID.objid,NULL,&classId);
  VDASSERTW(sts == 1);

  // Collector
  if (classId != OPP_VRplane_class_id) goto wrapup;
  retFlag = 1;
#if 0
  // Get end points
  sts = om$send(msg = message VRCnrlSeg.
		VRget_terminators(&msg,NULL,&parentOE->mod_env,pts,NULL),
		senderid = NULL_OBJID,
		targetid = parentID.objid,
		targetos = parentID.osnum);
  VDASSERTW(sts & msg & 1);
  
  // Create the node
  VDctxCreateNode(domID,VDCTX_NODE_TYPE_SS_OM_VRCNRLSEG,NULL,&nodeID);
  
  // Special type
  if (parentType) VDctxAppTxtAtr(&nodeID,"parent_type",parentType);
    
  // Two points
  VDvalConvertPointToText(&pts[0],txt);
  VDctxAppTxtAtr(&nodeID,"pt1",txt);
  VDvalConvertPointToText(&pts[3],txt);
  VDctxAppTxtAtr(&nodeID,"pt2",txt);
#endif

 wrapup:

  return retFlag;
}

/* -----------------------------------------------
 * Process a single parent control line segment
 */
IGRstat VRvalGenProcessParentVRCnrlSeg(TGRobj_env *childOE, 
				       TGRobj_env *parentOE,
				       IGRchar    *parentType,
				       TGRid      *domID)
{
  VDASSERT_FN("VRvalGenProcessParentVRCnrlSeg");
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  IGRint i;
  
  VDclassid classId;
  TGRid     parentID;
  TGRid     nodeID;

  IGRchab  txt;
  
  IGRdouble pts[6];
  
  // Init
  parentID = parentOE->obj_id;

  // Arg check
  VDASSERTW(domID && domID->objid != NULL_OBJID);
  VDASSERTW(parentOE && parentOE->obj_id.objid != NULL_OBJID);
  
  // Get the class
  sts = som_get_classid(parentID.osnum,NULL,parentID.objid,NULL,&classId);
  VDASSERTW(sts == 1);

  // Collector
  if (classId != OPP_VRCnrlSeg_class_id) goto wrapup;
  retFlag = 1;
  
  // Get end points
  sts = om$send(msg = message VRCnrlSeg.
		VRget_terminators(&msg,NULL,&parentOE->mod_env,pts,NULL),
		senderid = NULL_OBJID,
		targetid = parentID.objid,
		targetos = parentID.osnum);
  VDASSERTW(sts & msg & 1);
  
  // Create the node
  VDctxCreateNode(domID,VDCTX_NODE_TYPE_SS_OM_VRCNRLSEG,NULL,&nodeID);
  
  // Special type
  if (parentType) VDctxAppTxtAtr(&nodeID,"parent_type",parentType);
    
  // Two points
  VDvalConvertPointToText(&pts[0],txt);
  VDctxAppTxtAtr(&nodeID,"pt1",txt);
  VDvalConvertPointToText(&pts[3],txt);
  VDctxAppTxtAtr(&nodeID,"pt2",txt);
  
 wrapup:

  return retFlag;
}

/* -----------------------------------------------
 * Convert a component into a dom node
 */
IGRstat VRvalConvertComponentToDom(TGRobj_env *compOE, TGRid *parentID, TGRid *compID)
{
  VDASSERT_FN("VRvalConvertComponentToDom");
  
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  IGRchar *txt = NULL;
  
  TGRid nodeIDs;
  TGRid nodeID;

  TGRobj_env parentOE;
  IGRint i;

  TGRid   macDefID;
  IGRchab buf;
  IGRchab macName;
  IGRchab macLibName;
  
  IGRchar  macRep;
  IGRshort macType;
  
  TGRid staticID;
  TGRid cptsID;
  
  IGRdouble matrix[16];
  IGRchar *txtx;
  
  // Arg check
  VDASSERTW(compID);  compID->objid = NULL_OBJID;
  VDASSERTW(compOE && compOE->obj_id.objid != NULL_OBJID);
  
  // Verify
  sts = VDobjIsFinalRouteComponent(compOE,NULL,1);
  VDASSERTW(sts);
  
  // Make the basic node
  if (parentID) VDctxCreateNode(parentID,VDCTX_NODE_TYPE_SS_OM_COMPONENT,NULL,compID);
  else          VDctxCreateXdomTree(VDCTX_NODE_TYPE_SS_OM_COMPONENT,NULL,compID);
  VDASSERTW(compID->objid != NULL_OBJID);
  
  // Standard attributes
  VDvalAddModelClassNameAttribute(compOE,compID);
  VDvalAddModelTagAttribute      (compOE,compID);
  VDvalAddModelSymbologyAttribute(compOE,compID);
  VDvalAddModelRepAttribute      (compOE,compID);

  // Macro info
  sts = om$send(msg = message VRGeneric.
		VRGetMacro(&msg,macName,&macRep,&macType,&staticID,
			   NULL,NULL,NULL,&compOE->mod_env),
		senderid = NULL_OBJID,
		targetid = compOE->obj_id.objid,
		targetos = compOE->obj_id.osnum);
  VDASSERTW(sts & msg & 1);
  
  // Need the defination
  *macLibName = 0;
  macDefID.objid = NULL_OBJID;
  ac$find_macro_defn(action          = ACfind_load,
		     macro_name      =  macName,
		     p_macro_defn_id = &macDefID);
  if (macDefID.objid == NULL_OBJID) {
    VDlogPrintFmt(VDLOG_ERROR,1,"*** Could find macro def for %s",macName);
  }
  else {
    VDosGetFileName(macDefID.osnum,macLibName);
  }
  VDctxAppTxtAtr(compID,"macro_name",macName);
  VDctxAppTxtAtr(compID,"macro_lib", macLibName);
  VDctxAppIntAtr(compID,"macro_type",macType);
  VDctxAppIntAtr(compID,"macro_rep", macRep);

  // Could be another collectorwith more info
  if (staticID.objid != NULL_OBJID) {
    parentOE.obj_id  = staticID;
    parentOE.mod_env = compOE->mod_env;
    VDvalGenProcessParent(compOE,&parentOE,"static",compID);
  }
  
  // Cycle through parents
  for(i = 0; VDobjGetTemplate(compOE,NULL,i,&parentOE); i++) {
    sts = VDvalGenProcessParentCollector(compOE,&parentOE,NULL,compID);
    if (sts == 0) {
      sts = VRvalGenProcessParentVRCnrlSeg(compOE,&parentOE,NULL,compID);
    }
    if (sts == 0) {
      sts = VRvalGenProcessParentVRplane(compOE,&parentOE,NULL,compID);
    }
     if (sts == 0) {
      VDlogPrintObject(VDLOG_ERROR,1,"Unknown component parent type ",&parentOE,NULL);
      VDlogPrintObject(VDLOG_ERROR,1,"For  ",compOE,NULL);
    }
  }

  // Process connect points
  VRvalConvertCptsToDom(compOE,compID,&cptsID);

  // Try sending for a matrix
  // Not going to do the template thing right now
  sts = om$send(msg = message VRGeneric.
		VRGetMatrix(&msg,0,NULL,matrix,&compOE->mod_env),
		senderid = NULL_OBJID,
		targetid = compOE->obj_id.objid,
		targetos = compOE->obj_id.osnum);
  VDASSERTW(sts & msg & 1);

  // Write it out
  VDvalConvertDoublesToText(16,matrix,9,&txtx);
  VDASSERTW(txtx);
  VDctxAppTxtAtr(compID,"matrix",txtx);
  free(txtx); txtx = NULL;

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

end implementation Root;
