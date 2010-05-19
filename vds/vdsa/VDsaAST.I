/* $Id: VDsaAST.I,v 1.2 2001/01/22 15:27:06 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdsa/VDsaAST.I
 *
 * Description: Assembly Tree Interface
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDsaAST.I,v $
 *      Revision 1.2  2001/01/22 15:27:06  ahundiak
 *      ah
 *
 *      Revision 1.1.1.1  2001/01/04 21:09:12  cvs
 *      Initial import to CVS
 *
# Revision 1.2  2000/08/04  20:04:14  pinnacle
# Replaced: vds/vdsa/VDsaAST.I for:  by mdong for Service Pack
#
# Revision 1.1  2000/08/03  16:31:18  pinnacle
# Created: vds/vdsa/VDsaAST.I by mdong for Service Pack
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1998/04/21  21:00:42  pinnacle
# ah
#
# Revision 1.3  1998/04/10  21:37:36  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/07/98  ah      Creation
 * 08/03/00  Ming    for new cmd Create Table by Stage
 * 01/22/01  ah      sp merge
 ***************************************************************************/

class implementation VDbtBase;

#include "VDmaster.h"
#include "VDchn.h"
#include "VDobj.h"

#include "VDbt.h"
#include "VDsaProto.h"
#include "VDScheckin.h"

#include "PDUerror.h"
#include "v_risproto.h"
#include "VDSris_def.h"
#include "vdbmacros.h"


from ACdb_info import ACget_db_info;

extern GRclassid        OPP_VDatNode_class_id;

/* ------------------------------------------------------
 * Recurse routine to find node of a given type
 */
IGRstar VDsaGetNodeByType(IGRchar *nodeType,
                          TGRid   *nodeID,
                          TGRid   *nodeIDx)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRchar nodeTypex[128];
  TGRid   parentID;

  // Arg check
  if  (nodeIDx == NULL) goto wrapup;
  nodeIDx->objid = NULL_OBJID;

  if ((nodeID == NULL) || (nodeID->objid == NULL_OBJID)) goto wrapup;

  // See if this is it
  VDatRDBGetNodeType(nodeID,nodeTypex);
  if (!strcmp(nodeType,nodeTypex)) {
    *nodeIDx = *nodeID;
    retFlag = 1;
    goto wrapup;
  }

  // Try parent
  VDatGetParentNode(nodeID,&parentID);
  sts = VDsaGetNodeByType(nodeType,&parentID,nodeIDx);
  if (sts & 1) retFlag = 1;

wrapup:
  return retFlag;
}
  
/* ------------------------------------------------------
 * Give Struct AST Interface
 */
IGRstar VDsaGiveStructureAST(TGRobj_env  *objOE,
			     IGRchar     *attrName,
			     Tret_struct *attrData)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRchar setType  [128];
  IGRchar setTypex [128];
  IGRchar nodeType [128];
  IGRchar attrNamex[128];
  IGRchar *p;

  IGRint  nodeIndex;
  
  IGRint    i;
  TGRid     leafID;
  TVDvlaID  leafVLA;

  TGRid nodeID;

  // Init
  VDvlaID_Construct(&leafVLA);
  
  // Drop the prefix
  strcpy(attrNamex,attrName);
  p = strchr(attrNamex,':');
  if (p) strcpy(attrNamex,p+1);
  
  // Get the set type
  *setType = 0;
  p = strchr(attrNamex,':');
  if (p) {
    *p = 0;
    strcpy(setType,attrNamex);
    strcpy(attrNamex,p+1);
  }
  if (*setType == 0) goto wrapup;

  // Get the Node Type
  *nodeType = 0;
  p = strchr(attrNamex,':');
  if (p) {
    *p = 0;
    strcpy(nodeType,attrNamex);
    strcpy(attrNamex,p+1);
  }
  if (*nodeType == 0) goto wrapup;

  // see if it is a number
  nodeIndex = -1;
  if ((*nodeType >= '0') && (*nodeType <= '9')) {
    nodeIndex = atoi(nodeType);
  }
  
  // printf("AST %s %s %s\n",setType,nodeType,attrNamex);
    
  /*
  ** Modified by Ming for cmd Create Table by Stage
  */
  if( vd_$is_ancestry_valid(object  = &(objOE->obj_id),
                            classid = OPP_VDatNode_class_id) )
  {
    leafID = objOE->obj_id;
    goto got_leaf;
  }

  // Get the leafs
  VDatGetObjectLeafsVLA(&objOE->obj_id,&leafVLA);
 
  // Test if any leafs are in the set
  for(i = 0; VDvlaID_GetAt(&leafVLA,&leafID,i); i++) {

    // vdobj$Print(objID = &leafID);
    
    VDatGetSetType(&leafID,setTypex);
    if (!strcmp(setType,setTypex)) goto got_leaf;
  }
  goto wrapup;
  
got_leaf:

  // By node type or index?
  if (nodeIndex < 0) {
    
    // Recurse up until find nodetype
    VDsaGetNodeByType(nodeType,&leafID,&nodeID);
    if (nodeID.objid == NULL_OBJID) goto wrapup;

  }
  else {
    
    TGRid parentID;
    
    // Move up the tree by n stages
    nodeID = leafID;
    while(nodeIndex) {

      VDatGetParentNode(&nodeID,&parentID);
      if (parentID.objid == NULL_OBJID) goto wrapup;
      
      nodeID = parentID;
      nodeIndex--;
    }
  }

  // Get the attr
  sts = vdsa$GetStruct(objID = &nodeID, 
		       name  = attrNamex, 
		       rs    = attrData);
  
  if (!(sts & 1)) goto wrapup;
  
  retFlag = 1;
    
wrapup:

  VDvlaID_Delete(&leafVLA);

  if (retFlag != OM_S_SUCCESS) {
    //printf("Problem getting '%s' for\n",attrName);
    //vdbro$PrintObject(objOE = objOE);
  }
  
  return retFlag;
  
}

end implementation VDbtBase;





