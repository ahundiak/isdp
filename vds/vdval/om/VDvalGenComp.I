/***************************************************************************
 * I/VDS
 *
 * File:        vdval/om/VDvalGenComponent.I
 *
 * Description: Generate route component xml
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDvalGenComp.I,v $
 *      Revision 1.1  2001/08/24 20:01:52  ahundiak
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

VDASSERT_FFN("VDvalGenComp.I");

/* -----------------------------------------------
 * Convert a piece into a xdom node
 */
IGRstat VDvalConvertComponentToDom(TGRobj_env *compOE, TGRid *parentID, TGRid *compID)
{
  VDASSERT_FN("VDvalConvertComponentToDom");
  
  IGRstat retFlag = 0;

  IGRstat (*cnvComponent)(TGRobj_env *compOE, TGRid *parentID, TGRid *compID);

  // Arg check
  VDASSERTW(compID);  compID->objid = NULL_OBJID;
  VDASSERTW(compOE && compOE->obj_id.objid != NULL_OBJID);

  // Just pass it on for now
  cnvComponent =  (IGRstat (*)(TGRobj_env *compOE, TGRid *parentID, TGRid *compID))
    dload_address_lookup("VRvalConvertComponentToDom");
  if (cnvComponent == NULL) goto wrapup;
  
  retFlag = (*cnvComponent)(compOE,parentID,compID);
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Create a tree of all equipment
 */
void VDvalCreateComponentTreeForOS(VDosnum osnum,TGRid *treeID)
{
  VDASSERT_FN("VDvalCreateComponentTreeForOS");
  
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
  VDobjGetRouteComponents(osnum,&cnt,&listIDs);
  if (cnt) VDASSERTW(listIDs);
  
  // Build the tree
  VDctxCreateXdomTree(VDCTX_NODE_TYPE_SS_OM_COMPONENTS,NULL,treeID);
  VDASSERTW(treeID->objid != NULL_OBJID);
  
  // Cycle through
  for(i = 0; i < cnt; i++) {
    eqpID = listIDs[i];
    eqpOE.obj_id = eqpID;
    VDobjResetOE(&eqpOE);

    // Create the node
    VDvalConvertComponentToDom(&eqpOE,treeID,&nodeID);
    VDASSERTW(nodeID.objid != NULL_OBJID);

  }
  
  // Done

 wrapup:
  if (listIDs) free(listIDs);
  
}

/* -----------------------------------------------
 * Batch creation of tree
 */
void VDvalCreateComponentTreeTest(TVDtestTestInfo *info)
{
  TGRid treeID;
  
  // Init
  treeID.objid = NULL_OBJID;

  // Make the tree
  VDvalCreateComponentTreeForOS(2,&treeID);
  if (treeID.objid == NULL_OBJID) goto wrapup;

  // Save it
  VDctxSaveTreeToXmlFile(&treeID,"comps.xml");
  
  // Done
  if (info) info->worked = 1;
  
 wrapup:
  VDctxDeleteNode(&treeID);
  
  return;
}

/* -----------------------------------------------
 * Place single xml route component
 */
static void placeXmlComponent(TGRid *compID, void *data, IGRint *stopWalk)
{
  VDASSERT_FN("placeXmlComponent");
    
  TGRobj_env macOE;

  TGRsymbology symb1,symb2;
  IGRint symbFlag = 0;
  
  IGRchab symb;
  IGRchar *p;
  
  // Only want equipment
  if (!VDctxIsNodeType(compID,VDCTX_NODE_TYPE_SS_OM_COMPONENT)) goto wrapup;

  // Symbology
  VDahGetActiveSymbology(&symb1);
  VDahGetActiveSymbology(&symb2);
  VDctxGetTxtAtr(compID,"symbology",symb);
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
  VDbufPlaceMacro("VDxml","xml_comp",NULL,NULL,compID,&macOE);
  if (macOE.obj_id.objid == NULL_OBJID) {
    VDlogPrintFmt(VDLOG_ERROR,1,"*** Could not place xml_comp macro");
    goto wrapup;
  }
  
 wrapup:
  if (symbFlag) VDahSetActiveSymbology(&symb1);
  return;
}

/* -----------------------------------------------
 * Load xml file then place macros
 */
void VDvalLoadXmlComponentFile(IGRchar *fileName)
{
  VDASSERT_FN("VDvalLoadXmlComponentFile");
  
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
  VDctxWalkNode(&treeID,1,placeXmlComponent,NULL,&stopWalk);

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
void VDvalLoadXmlComponentFileTest(TVDtestTestInfo *info)
{
  VDvalLoadXmlComponentFile("comps.xml");
  
  // Done
  if (info) info->worked = 1;
  
 wrapup:
  
  return;
}

end implementation Root;

