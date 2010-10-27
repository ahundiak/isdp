/* $Id: VDctxList.c,v 1.6 2002/05/09 17:46:36 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdctx/c/VDctxPiece.c
 *
 * Description: Node List Routines
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDctxList.c,v $
 *      Revision 1.6  2002/05/09 17:46:36  ahundiak
 *      ah
 *
 *      Revision 1.5  2002/05/06 20:52:24  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/07/28 17:37:27  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/07/23 16:25:12  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/05/17 14:48:14  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/03/18 22:40:17  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/03/16 16:50:51  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/03/13 00:17:58  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/12/01  ah      Creation
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDctx.h"
#include "VDtest.h"

VDASSERT_FFN("VDctxList.c");

/* -----------------------------------------------
 * Some utility routines
 */
void VDctxInitNodeList(TVDctxNodeList *nodeList)
{
  if (nodeList == NULL) goto wrapup;
  memset(nodeList,0,sizeof(TVDctxNodeList));

  // Leave for now but should probably not use
  nodeList->size = sizeof(TGRid);

 wrapup:
  return;
}
void VDctxFreeNodeList(TVDctxNodeList *nodeList)
{
  if (nodeList == NULL) goto wrapup;
  if (nodeList->listIDs) free(nodeList->listIDs);
  VDctxInitNodeList(nodeList);
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * qsort wrapper
 */
void VDctxSortNodeList(TVDctxNodeList *nodeList, 
		       IGRint (*compare)(const void *p1, const void *p2))
{
  VDASSERT_FN("VDctxSortNodeList");
  
  // Arg check
  VDASSERTW(compare);
  VDASSERTW(nodeList);

  // Zero elements is ok
  if (nodeList->listIDs == NULL) goto wrapup;
  if (nodeList->cnt == 0)        goto wrapup;

  // Doit
  qsort(nodeList->listIDs,nodeList->cnt,sizeof(TGRid),compare);

  // Done
 wrapup:
  return;
}

/* -----------------------------------------------
 * bsearch wrapper
 */
TGRid * VDctxSearchNodeList(TGRid *findID,
			    TVDctxNodeList *nodeList, 
			    IGRint (*compare)(const void *p1, const void *p2))
{
  VDASSERT_FN("VDctxSearchNodeList");
  
  // Arg check
  VDASSERTW(compare);
  VDASSERTW(nodeList);
  VDASSERTW(findID && findID->objid != NULL_OBJID);
  
  // Zero elements is ok
  if (nodeList->listIDs == NULL) goto wrapup;
  if (nodeList->cnt == 0)        goto wrapup;

  // Doit
  return bsearch(findID,nodeList->listIDs,nodeList->cnt,sizeof(TGRid),compare);

 wrapup:
  return NULL;
}

typedef struct 
{
  IGRchar        *nodeType;
  TVDctxNodeList *nodeList;
  IGRint        (*filter)(TGRid *nodeID);
} Tdata;

/* ----------------------------------------------
 * 06 May 2002 - Accept * for all node types
 * Should add full regular expressions later
 */
static void walkProcessGetByType(TGRid *nodeID, void *datax, IGRint *stopWalk)
{
  Tdata *data = datax;
  IGRchab nodeType;

  VDctxGetNodeType(nodeID,nodeType);
  if (strcmp(data->nodeType,"*")) {
    if (strcmp(data->nodeType,nodeType)) goto wrapup;
  }
  // Save it
  if (data->nodeList->cnt < data->nodeList->max) {
    data->nodeList->listIDs[data->nodeList->cnt] = *nodeID;
  }
  data->nodeList->cnt++;

 wrapup:  
  return;
}
static void walkProcessGetByFilter(TGRid *nodeID, void *datax, IGRint *stopWalk)
{
  Tdata *data = datax;

  if (data->filter(nodeID) == 0) goto wrapup;

  // Save it
  if (data->nodeList->cnt < data->nodeList->max) {
    data->nodeList->listIDs[data->nodeList->cnt] = *nodeID;
  }
  data->nodeList->cnt++;

 wrapup:  
  return;
}

/* -----------------------------------------------
 * Get a list of nodes by type
 */
void VDctxGetNodeListByType(TGRid *treeID, IGRchar *nodeType, TVDctxNodeList *nodeList)
{
  VDASSERT_FN("VDctxGetNodeListByType");
  
  IGRint cnt;
  IGRint stopWalk = 0;
  Tdata  data;
  
  // Arg check
  VDASSERTW(nodeList);
  VDctxInitNodeList(nodeList);
  VDASSERTW(nodeType && *nodeType);
  VDASSERTW(treeID && treeID->objid != NULL_OBJID);
  
  // Once for count
  data.nodeList = nodeList;
  data.nodeType = nodeType;
  VDctxWalkNode(treeID,1,walkProcessGetByType,&data,&stopWalk);

  cnt = nodeList->cnt;
  nodeList->cnt = 0;
  if (cnt == 0) goto wrapup;
  
  // Allocate
  nodeList->listIDs = calloc(cnt,nodeList->size);
  VDASSERTW(nodeList->listIDs);
  nodeList->max = cnt;
  
  // Walk for the nodes
  VDctxWalkNode(treeID,1,walkProcessGetByType,&data,&stopWalk);
  VDASSERTW(nodeList->cnt == nodeList->max);

 wrapup:
  return;
}

/* -----------------------------------------------
 * Get a list of nodes using a passed filter
 */
void VDctxGetNodeListByFilter(TGRid *treeID, IGRint (*filter)(TGRid *nodeID), TVDctxNodeList *nodeList)
{
  VDASSERT_FN("VDctxGetNodeListByFilter");
  
  IGRint cnt;
  IGRint stopWalk = 0;
  Tdata  data;
  
  // Arg check
  VDASSERTW(nodeList);
  VDctxInitNodeList(nodeList);
  VDASSERTW(filter);
  VDASSERTW(treeID && treeID->objid != NULL_OBJID);
  
  // Once for count
  data.nodeList = nodeList;
  data.filter   = filter;
  VDctxWalkNode(treeID,1,walkProcessGetByFilter,&data,&stopWalk);

  cnt = nodeList->cnt;
  nodeList->cnt = 0;
  if (cnt == 0) goto wrapup;
  
  // Allocate
  nodeList->listIDs = calloc(cnt,nodeList->size);
  VDASSERTW(nodeList->listIDs);
  nodeList->max = cnt;
  
  // Walk for the nodes
  VDctxWalkNode(treeID,1,walkProcessGetByFilter,&data,&stopWalk);
  VDASSERTW(nodeList->cnt == nodeList->max);

 wrapup:
  return;
}

/* -----------------------------------------------
 * Gets the child directly attached under the node
 */
IGRstat VDctxGetChildNodeByType(TGRid *nodeID, IGRchar *type, TGRid *childID)
{
  VDASSERT_FN("VDctxGetChildNodeByType");
  IGRstat retFlag = 0;
  
  IGRint i;
  TGRid  childIDx;
  
  // Arg check
  VDASSERTW(childID); childID->objid = NULL_OBJID;
  VDASSERTW(type && *type);
  VDASSERTW(nodeID && nodeID->objid != NULL_OBJID);
  
  // Cycle through
  for(i = 0; VDctxGetNthTreeChild(nodeID,i,&childIDx); i++) {
    if (VDctxIsNodeType(&childIDx,type)) {
      *childID = childIDx;
      retFlag = 1;
      goto wrapup;
    }
  }
 wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Find the first node of given type in a tree
 */
void VDctxGetNodeByType(TGRid *treeID, IGRchar *nodeType, TGRid *nodeID)
{
  VDASSERT_FN("VDctxGetNodeByType");
  
  TVDctxTreeTypeWalk data;
  IGRint stopFlag = 0;
  
  // Arg check
  VDASSERTW(nodeID);  nodeID->objid  = NULL_OBJID;
  VDASSERTW(treeID && treeID->objid != NULL_OBJID);
  VDASSERTW(nodeType && *nodeType);
  
  // Init walking data
  memset(&data,0,sizeof(TVDctxTreeTypeWalk));
  
  strcpy(data.baseInfo.nodeType,nodeType);
  data.match.nodeType = 1;
  data.stopAtOne = 1;
  data.firstID.objid = NULL_OBJID;
  
  // Do it
  VDctxWalkNode(treeID,1,VDctxWalkProcessByTypeName,&data,&stopFlag);
  if (data.firstID.objid != NULL_OBJID) {
    *nodeID = data.firstID;
  }
  
 wrapup:
  return;
}

/* ----------------------------------------------
 * Returns a copy of the text attribute
 * truncating it if necessary to prevent overfilling the buffer
 * Returns 3 if truncation was done
 */
IGRstat VDctxGetTxtAtrBuf(TGRid *nodeID, IGRchar *name, IGRint len, IGRchar *buf)
{
  VDASSERT_FN("VDctxGetTxtAtrBuf");

  IGRstat sts;
  IGRstat retFlag = 0;
  IGRstat truncFlag = 0;

  IGRchar *p;

  // Arg check
  VDASSERTW(buf); *buf = 0;
  VDASSERTW(len);

  sts = VDctxGetTxtAtrPtr(nodeID,name,&p);
  if (sts == 0) goto wrapup;

  retFlag = 1;

  if (strlcpy(buf,p,len) > len) retFlag = 3;

wrapup:
  return retFlag;
}

