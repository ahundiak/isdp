/***************************************************************************
 * I/VDS
 *
 * File:        vrval/om/VRvalGenNoz.I
 *
 * Description: Generate nozzle xml
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VRvalGenNoz.I,v $
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

VDASSERT_FFN("VRvalGenNoz.c");

extern VDclassid OPP_ACpretend_class_id;
extern VDclassid OPP_VRNozHold_class_id;

from ACncpx    import ACget_rep;
from ACpretend import ACgive_downscan;
from VRGeneric import VRGetMacro;

from VRNozHold import NDgive_structure;

/* -----------------------------------------------
 * Convert a nozzle into a dom node
 */
IGRstat VRvalConvertNozToDom(TGRobj_env *nozOE, TGRid *parentID, TGRid *nozID)
{
  VDASSERT_FN("VRvalConvertNozToDom");
  
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  TGRobj_env parentOE;
  IGRint i;

  TGRid   macDefID;
  IGRchab buf;
  IGRchab parent_foot;
  IGRchab macName;
  IGRchab macLibName;
  
  IGRchar  macRep;
  IGRshort macType;
  
  TGRid pretendID;
  TGRid staticID;

  TGRid cptsID;
  
  // Init
  *parent_foot = 0;
  
  // Arg check
  VDASSERTW(nozID); nozID->objid = NULL_OBJID;
  VDASSERTW(nozOE && nozOE->obj_id.objid != NULL_OBJID);
  
  // Verify
  sts = VDobjIsAncestryValid(nozOE,NULL,OM_K_NOTUSING_CLASSID,"VRNozzle");
  VDASSERTW(sts);
  
  // Make the basic node
  if (parentID) VDctxCreateNode(parentID,VDCTX_NODE_TYPE_SS_OM_NOZZLE,NULL,nozID);
  else          VDctxCreateXdomTree(VDCTX_NODE_TYPE_SS_OM_NOZZLE,NULL,nozID);

  // Standard attributes
  VDvalAddModelClassNameAttribute(nozOE,nozID);
  VDvalAddModelTagAttribute      (nozOE,nozID);
  VDvalAddModelSymbologyAttribute(nozOE,nozID);
  VDvalAddModelRepAttribute      (nozOE,nozID);

  // Macro info
  om$send(msg = message VRGeneric.
	  VRGetMacro(&msg,macName,&macRep,&macType,&staticID,
		     NULL,NULL,NULL,&nozOE->mod_env),
	  senderid = NULL_OBJID,
	  targetid = nozOE->obj_id.objid,
	  targetos = nozOE->obj_id.osnum);

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
  VDctxAppTxtAtr(nozID,"macro_name",macName);
  VDctxAppTxtAtr(nozID,"macro_lib", macLibName);
  VDctxAppIntAtr(nozID,"macro_type",macType);
  VDctxAppIntAtr(nozID,"macro_rep", macRep);

  // Could be another collectorwith more info
  if (staticID.objid != NULL_OBJID) {
    parentOE.obj_id  = staticID;
    parentOE.mod_env = nozOE->mod_env;
    VDvalGenProcessParent(nozOE,&parentOE,"static",nozID);
  }
   
  // Cycle through parents
  for(i = 0; VDobjGetTemplate(nozOE,NULL,i,&parentOE); i++) {

    // Check for pretends, this will be the equipment connection
    vdchn$Get2(objOE = nozOE, chnIDx = VDCHN_IDX_PARENT, nth = i, outID = &pretendID);
    sts = vdobj$IsAncestryValid(objID = &pretendID, superClassID = OPP_ACpretend_class_id);

    // Regular collector parent
    if (sts == 0) VDvalGenProcessParent(nozOE,&parentOE,NULL,nozID);
    else {
      // Want to save the connection info
      om$send(msg = message ACpretend.ACgive_downscan(parent_foot),
	      senderid = NULL_OBJID,
	      targetid = pretendID.objid,
	      targetos = pretendID.osnum);
      VDctxAppTxtAtr(nozID,"parent_foot",parent_foot);

      // This should actually be a nozzle holder
      sts = vdobj$IsAncestryValid(objOE = &parentOE, superClassID = OPP_VRNozHold_class_id);
      if (sts) {
	
	/* -----------------------------------------------
	 * Only thing we really need is the matrix I think
	 * Everything should be in the collectors already
	 */
	Tret_struct rs;
	TGRid csID;
	IGRchar *txtx;
	
	// Get the matric
	sts = om$send(msg = message VRNozHold.NDgive_structure(&msg,&rs,&parentOE.mod_env),
		      senderid = NULL_OBJID,
		      targetid = parentOE.obj_id.objid,
		      targetos = parentOE.obj_id.osnum);
	VDASSERTW(sts & msg & 1);
	
	// Write it out
	VDctxCreateNode(nozID,VDCTX_NODE_TYPE_SS_OM_CS,NULL,&csID);
	VDvalConvertDoublesToText(16,rs.var.ref_st.t,9,&txtx);
	VDASSERTW(txtx);
	VDctxAppTxtAtr(&csID,"matrix",txtx);
	free(txtx); txtx = NULL;
	
      }
    }
  }

  // Process connect points
  VRvalConvertCptsToDom(nozOE,nozID,&cptsID);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

end implementation Root;
