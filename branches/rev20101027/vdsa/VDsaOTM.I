/* $Id: VDsaOTM.I,v 1.1 2001/01/19 13:08:58 paul_noel Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdsa/VDsaOTM.I
 *
 * Description: Assembly Tree Interface
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDsaOTM.I,v $
 *      Revision 1.1  2001/01/19 13:08:58  paul_noel
 *      New file to handle SA_OTM Expressions
 *
# Revision 1.2  2000/11/29  16:32:20  pinnacle
# pn
#
# Revision 1.1  2000/11/22  17:28:38  pinnacle
# pn
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/22/00  pn      Creation (* Created as solution to TR 4108)
 * 12/08/00  pn      updated to handle Create/Modify table command issues for TR 4108
 *
 ***************************************************************************/

class implementation VDbtBase;

#include "VDmaster.h"
#include "VDchn.h"
#include "VDobj.h"
#include "VDct.h"
#include "VDct1.h"
#include "VDbt.h"
#include "VDsaProto.h"
#include "VDScheckin.h"

#include "PDUerror.h"
#include "v_risproto.h"
#include "VDSris_def.h"
#include "vdbmacros.h"
#include "VDassert.h"


from ACdb_info import ACget_db_info;

VDASSERT_FFN("vdsa/VDsaOTM.I");


/* ------------------------------------------------------
 * Recurse routine to find node of a given type
 * going up the tree
 */
IGRstar VDotmGetNodeByType(IGRchar *nodeType,
                          TGRid   *nodeID,
                          TGRid   *nodeIDx)
{

  VDASSERT_FN("VDotmGetNodeByType");
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRchar nodeTypex[128];
  TGRid   parentID;
  TVDctBaseInfo  baseInfo;
  

  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

   // args check
  VDASSERTW(nodeID);
  VDASSERTW(nodeIDx);
  VDASSERTW(nodeType);
 
  // inits
  if (nodeID->objid == NULL_OBJID) goto wrapup;

  // get the baseInfo
  vdct1$GetBaseInfo(objID = nodeID, baseInfo = &baseInfo); 

  // does it match
  if (!strcmp(baseInfo.nodeType,nodeType)) {
    *nodeIDx = *nodeID;
    retFlag = 1;
    goto wrapup;
  }
  // get the parent
  vdct1$GetTree1Parent(objID = nodeID, outID = &parentID);
  
  // call myself
    sts = VDotmGetNodeByType(nodeType,&parentID,nodeIDx);
  if (sts & 1) retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag); 
  return retFlag;
}
/* ------------------------------------------------------
 * Give Struct OTM Interface
 */
IGRstar VDsaGiveStructureOTM(TGRobj_env  *objOE,
			     IGRchar     *attrName,
			     Tret_struct *attrData)
{
  VDASSERT_FN("VDsaGiveStructureOTM");
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRchar setType  [128];
  IGRchar setTypex [128];
  IGRchar nodeType [128];
  IGRchar attrNamex[128];
  IGRchar *p;

  IGRint  nodeIndex;
  
  IGRint    i;
  TGRid     nodeID,leafID;
  TGRid     parentID;
  TVDctBaseInfo baseInfo;

  // Tracing
  traceFlagx = traceFlag = 0;
  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

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
   
  // get the connected (leafID) node
   sts = vdct1$GetModelObjectNode(modelOE = objOE,
				  nodeID  = &leafID);

   // filter out  if there is no leafID
   if (leafID.objid == NULL_OBJID) leafID = objOE->obj_id;

   // get the baseInfo of the leafID to compare setType...
   vdct1$GetBaseInfo(objID = &leafID, baseInfo = &baseInfo);

   // filter out if the set type is wrong
   if(strcmp(baseInfo.setType,setType)) {
     if(traceFlag) printf("Went wrapup due to setType mismatch\n");
     goto wrapup;
   }

  // By node type or index?
  if (nodeIndex < 0) {
    
    // Recurse up until find nodetype
    VDotmGetNodeByType(nodeType,&leafID,&nodeID);
    if (nodeID.objid == NULL_OBJID) goto wrapup;
  }
  else {
    
    // Move up the tree by n stages
    nodeID = leafID;
    while(nodeIndex) {
      // get the parentID
      vdct1$GetTree1Parent(objID = &nodeID, outID = &parentID);
      
      //VDatGetParentNode(&nodeID,&parentID);
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
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag); 
  return retFlag;
  
}

end implementation VDbtBase;





