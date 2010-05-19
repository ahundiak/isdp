/***************************************************************************
 * I/VDS
 *
 * File:        vdval/om/VDvalGenEqp.I
 *
 * Description: Generate equipment xml
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDvalGenEqp.I,v $
 *      Revision 1.4  2001/08/31 14:15:15  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/08/24 20:01:52  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/08/14 19:15:45  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/08/02 15:33:39  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/13/01  ah      Creation
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

#include "VDxdom.h"
#include "VDctx.h"
#include "VDss.h"

#include "macro.h"
#include "acmacros.h"

VDASSERT_FFN("VDvalGenEqp.c");

extern VDclassid OPP_ACpretend_class_id;

from ACncpx  import ACget_rep;
from VDSroot import VDGetGraphMac;

/* -----------------------------------------------
 * Convert a piece into a dom node
 * Parent id can be NULL in which case a new xdom
 * tree is created
 */
IGRstat VDvalConvertEqpToDom(TGRobj_env *eqpOE, TGRid *parentID, TGRid *eqpID)
{
  VDASSERT_FN("VDvalConvertEqpToDom");
  
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  IGRchar *txt = NULL;
  
  TGRid nodeIDs;
  TGRid nodeID;

  TGRobj_env parentOE;
  IGRint i;

  TGRid   macDefID;
  IGRchab buf;

  TGRobj_env nozOE;
  TGRid      nozID;
  TGRid      nozDomID;
  TGRid      nozzlesID;
  TGRid      pretendID;

  IGRstat (*cnvNoz)(TGRobj_env *nozOE, TGRid *parentID, TGRid *nozID);

  // Init
  nozzlesID.objid = NULL_OBJID;
  
  // Arg check
  VDASSERTW(eqpID); eqpID->objid = NULL_OBJID;
  VDASSERTW(eqpOE && eqpOE->obj_id.objid != NULL_OBJID);
  
  // Verify
  sts = VDobjIsAncestryValid(eqpOE,NULL,OM_K_NOTUSING_CLASSID,"VDequipment");
  VDASSERTW(sts);
  
  // Make the basic node
  if (parentID == NULL) VDctxCreateXdomTree(VDCTX_NODE_TYPE_SS_OM_EQP,NULL,eqpID);
  else                  VDctxCreateNode(parentID,VDCTX_NODE_TYPE_SS_OM_EQP,NULL,eqpID);
  VDASSERTW(eqpID->objid != NULL_OBJID);

  // Standard attributes
  VDvalAddModelCompPathAttribute (eqpOE,eqpID);
  VDvalAddModelTagAttribute      (eqpOE,eqpID);
  VDvalAddModelSymbologyAttribute(eqpOE,eqpID);
  VDvalAddModelClassNameAttribute(eqpOE,eqpID);
  VDvalAddModelRepAttribute      (eqpOE,eqpID);
    
  // Explicitly save the macro name and library
  // Also need to jigger the method to get the ACconst flag
  *buf = 0;
  om$send(msg = message VDSroot.VDGetGraphMac(&msg,buf),
	  senderid = NULL_OBJID,
	  targetid = eqpOE->obj_id.objid,
	  targetos = eqpOE->obj_id.osnum);
  VDctxAppTxtAtr(eqpID,"macro_name",buf);

  // Need the defination
  macDefID.objid = NULL_OBJID;
  ac$find_macro_defn(action          = ACfind_load,
		     macro_name      =  buf,
		     p_macro_defn_id = &macDefID);
  if (macDefID.objid == NULL_OBJID) {
    VDlogPrintFmt(VDLOG_ERROR,1,"*** Could find macro def for %s",buf);
  }
  else {
    VDosGetFileName(macDefID.osnum,buf);
    VDctxAppTxtAtr(eqpID,"macro_lib",buf);
  }
 
  // Cycle through parents
  for(i = 0; VDobjGetTemplate(eqpOE,NULL,i,&parentOE); i++) {
    VDvalGenProcessParent(eqpOE,&parentOE,NULL,eqpID);
  }

  // Nozzle conversion routine
  cnvNoz =  (IGRstat (*)(TGRobj_env *nozOE, TGRid *parentID, TGRid *nozID))
    dload_address_lookup("VRvalConvertNozToDom");
  if (cnvNoz == NULL) printf("VRvalConvertNozToDom not found\n");
  
  /* ---------------------------------------------
   * Process any connected objects
   * Assume for now they are all in the same file
   */
  for(i = 0; 
      vdchn$Get2(objOE = eqpOE, chnIDx = VDCHN_IDX_CHILD, nth = i, outID = &pretendID);
      i++) {
    
    sts = vdobj$IsAncestryValid(objID = &pretendID, superClassID = OPP_ACpretend_class_id);
    if (sts) {
      vdchn$Get2(objID = &pretendID, chnIDx = VDCHN_IDX_CHILD, nth = 0, outID = &nozID);
      sts = vdobj$IsAncestryValid(objID = &nozID, superClassName = "VRNozzle");
      if (sts) {
	if (cnvNoz) {

	  // Create the nozzles object
	  if (nozzlesID.objid == NULL_OBJID) {  
	    VDctxCreateNode(eqpID,VDCTX_NODE_TYPE_SS_OM_NOZZLES,NULL,&nozzlesID);
	    VDASSERTW(nozzlesID.objid != NULL_OBJID);
	  }
	  // Pass off to route code
	  nozOE.obj_id  = nozID;
	  nozOE.mod_env = eqpOE->mod_env;
	  (*cnvNoz)(&nozOE,&nozzlesID,&nozDomID); 
	}  
      }
    }
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Create a tree of all equipment
 */
void VDvalCreateEqpTreeForOS(VDosnum osnum,TGRid *treeID)
{
  VDASSERT_FN("VDvalCreateEqpTree");
  
  IGRint  cnt;
  IGRchab key;
  
  TGRid    *listIDs = NULL;
  TGRid      eqpID;
  TGRobj_env eqpOE;
  IGRint i;
  
  TGRid nodeID;
  
  // Arg check
  VDASSERTW(treeID); treeID->objid = NULL_OBJID;
  VDASSERTW(osnum != OM_K_NOT_AN_OS);
  
  // Get list of pieces
  VDobjGetEqps(osnum,&cnt,&listIDs);
  if (cnt) VDASSERTW(listIDs);
  
  // Build the tree
  VDctxCreateXdomTree(VDCTX_NODE_TYPE_SS_OM_EQPS,NULL,treeID);
  VDASSERTW(treeID->objid != NULL_OBJID);
  
  // Cycle through
  for(i = 0; i < cnt; i++) {
    eqpID = listIDs[i];
    eqpOE.obj_id = eqpID;
    VDobjResetOE(&eqpOE);

    // Create the node
    VDvalConvertEqpToDom(&eqpOE,treeID,&nodeID);
    VDASSERTW(nodeID.objid != NULL_OBJID);

  }
  
  // Done

 wrapup:
  if (listIDs) free(listIDs);
  
}

/* -----------------------------------------------
 * Batch creation of tree
 */
void VDvalCreateEqpTreeTest(TVDtestTestInfo *info)
{
  TGRid treeID;
  
  // Init
  treeID.objid = NULL_OBJID;

  // Make the tree
  VDvalCreateEqpTreeForOS(2,&treeID);
  if (treeID.objid == NULL_OBJID) goto wrapup;

  // Save it
  VDctxSaveTreeToXmlFile(&treeID,"eqps.xml");
  
  // Done
  if (info) info->worked = 1;
  
 wrapup:
  VDctxDeleteNode(&treeID);
  
  return;
}

/* -----------------------------------------------
 * Place singel xml equipment
 */
static void placeXmlEqp(TGRid *eqpID, void *data, IGRint *stopWalk)
{
  VDASSERT_FN("placeXmlEqp");
    
  TGRobj_env macOE;

  TGRsymbology symb1,symb2;
  IGRint symbFlag = 0;
  
  IGRchab symb;
  IGRchar *p;
  
  // Only want equipment
  if (!VDctxIsNodeType(eqpID,VDCTX_NODE_TYPE_SS_OM_EQP)) goto wrapup;

  // Symbology
  VDahGetActiveSymbology(&symb1);
  VDahGetActiveSymbology(&symb2);
  VDctxGetTxtAtr(eqpID,"symbology",symb);
  if (*symb) {
  
    p = strchr(symb,':');
    if (p) {
      symb2.level = atoi(symb);
      strcpy(symb,p+1);
    }
    p = strchr(symb,':');
    if (p) {
      symb2.display_attr.color = atoi(symb);
      strcpy(symb,p+1);
    }
    p = strchr(symb,':');
    if (p) {
      symb2.display_attr.weight = atoi(symb);
      strcpy(symb,p+1);
    }
    p = strchr(symb,':');
    if (p) {
      symb2.display_attr.style = atoi(symb);
      strcpy(symb,p+1);
    }
    
    // Set it
    VDahSetActiveSymbology(&symb2);
    symbFlag = 1;
  }
  
  // Place the macro
  VDbufPlaceMacro("VDxml","xml_eqp",NULL,NULL,eqpID,&macOE);
  if (macOE.obj_id.objid == NULL_OBJID) {
    VDlogPrintFmt(VDLOG_ERROR,1,"*** Could not place xml_eqp macro");
    goto wrapup;
  }
  VDvalPostPlaceNozzles(&macOE);
  
 wrapup:
  if (symbFlag) VDahSetActiveSymbology(&symb1);
  return;
}

/* -----------------------------------------------
 * Load xml file then place macros
 */
void VDvalLoadXmlEqpFile(IGRchar *fileName)
{
  VDASSERT_FN("VDvalLoadXmlEqpFile");
  
  TGRid treeID;
  IGRint stopWalk = 0;

  IGRchab buf;
  
  // Arg check
  VDASSERTW(fileName);

  sprintf(buf,"Loading %s ...",fileName);  
  UI_status(buf);
  
  // Load up
  VDxdomCreateTreeFromXmlFile(fileName,&treeID);
  VDASSERTW(treeID.objid != NULL_OBJID);
  
  // Walk through
  VDctxWalkNode(&treeID,1,placeXmlEqp,NULL,&stopWalk);

 wrapup:
  VDctxDeleteNode(&treeID);
  if (fileName) {
    sprintf(buf,"Loaded %s",fileName);  
    UI_status(buf);
  }
  return;
}

/* -----------------------------------------------
 * Batch loading of tree
 */
void VDvalLoadXmlEqpFileTest(TVDtestTestInfo *info)
{
  VDvalLoadXmlEqpFile("eqps.xml");
  
  // Done
  if (info) info->worked = 1;
  
 wrapup:
  
  return;
}

end implementation Root;
