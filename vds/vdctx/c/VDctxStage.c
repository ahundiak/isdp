/***************************************************************************
 * I/VDS
 *
 * File:        vdctx/c/VDctxStage.c
 *
 * Description: Getting the caluclated stage from the staging tree
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDctxStage.c,v $
 *      Revision 1.4  2002/05/06 20:52:24  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/10/19 18:21:34  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/04/13 19:49:42  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/04/06 12:43:21  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/05/01  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"

#include "VDctx.h"
#include "VDat.h"
#include "VDss.h"

VDASSERT_FFN("vdctx/c/VDctxStage.c");

/* -------------------------------------------------
 * The "stage" of a piece is derived from it's position
 * in the staging tree using Avondale specific rules
 *
 * The original implementation was done in a ppl for
 * customization purposes but we have since moved onto
 * function based customization.  Using the ppl was too slow
 * for batch snapshot processing
 *
 * There are time when the stage is calculated then stored as an
 * attribute.  Need to be careful  to update this should the actual
 * staging tree structure be changed.
 *
 * VDctxGetPieceStage really implements the "parent_path" attribute of
 * of the original StagingTree.  Don't confuse this with "node_path"
 * which gets the stage including the piece itself.  
 *
 * Probably do need an atribute for this
 * piece_stage - stage to which it belongs
 * stage_path  - The full staging tree path, so this is a StagingTree attribute
 *
 * Its confusing
 */

/* -------------------------------------------------
 * Need a custom routine for getting node types to
 * deal with different using different node types
 * for the same type of node
 */
static void getNodeType(TGRid *nodeID, IGRchar *nodeType)
{
  IGRchar *p;
  
  VDctxGetNodeType(nodeID,nodeType);  
  p = strrchr(nodeType,'_');
  if (p) strcpy(nodeType,p+1);
  strupr(nodeType);
  return;
}

/* -------------------------------------------------
 * Validates name format for given stage type
 * Changing the actual name in some cases
 *
 * Returns some info about what it finds in msg
 *
 * This was just copied form the ppl, not yet used
 */
static IGRstat isNameValid(IGRchar *nodeType, IGRchar *nodeName, IGRchar *msg)
{
  IGRstat retFlag = 0;
  
  IGRchar *p;

  // Init
  *msg = 0;
  
  // Handle SAx
  if ((strncmp(nodeType,"SA",2) == 0) && (strlen(nodeType) > 2)) {

    // Never give a name for this
    *nodeName = 0;
    retFlag = 1;
    goto wrapup;
  }
  
  // rest must all have some name
  if (*nodeName == 0) {
    strcpy(msg,"Must specify stage name");
    goto wrapup;
  }
  
  // Upper case the name
  for(p = nodeName; *p; p = p + 1) {
    if ((*p >= 'a') && (*p <= 'z')) {
      *p = *p - 32;
    }
  }
    
  // SA are numbers
  if ((!strcmp(nodeType,"SA")) || (!strcmp(nodeType,"PSU"))) {

    for(p = nodeName; *p; p = p + 1) {
      if ((*p < '0') || (*p > '9')) {
	sprintf(msg,"%s's can only have numbers",nodeType);
	goto wrapup;
      }
    }
    retFlag = 1;
    goto wrapup;
  }

  // CPSU and PSA are letters
  if ((!strcmp(nodeType,"PSA")) || (!strcmp(nodeType,"CPSU"))) {

    for(p = nodeName; *p; p = p + 1) {
      if ((*p < 'A') || (*p > 'Z')) {
	sprintf(msg,"%s's can only have letters",nodeType);
	goto wrapup;
      }
    }
    retFlag = 1;
    goto wrapup;
  }

  // Oops
  strcpy(msg,"StagingTree.Unknown stage type");

wrapup:
  return retFlag;
}

/* --------------------------------------------------------------------
 * Returns the name of the unit item belongs to
 */
static void getNameForUnit(TGRid *nodeID, IGRchar *nodeName)
{
  TGRid   node1ID;
  TGRid   node2ID;
  IGRchar node1Type[128];

  // Init
  *nodeName = 0;
  node1ID = *nodeID;

  // Cycle up until unit is found
  while(1) {

    getNodeType(&node1ID,node1Type);
    
    if (!strcmp(node1Type,"UNIT")) {
      VDctxGetNodeName(&node1ID,nodeName);
      goto wrapup;
    }

    VDctxGetTreeParent(&node1ID,&node2ID);
    if (node2ID.objid == NULL_OBJID) goto wrapup;
    
    node1ID = node2ID;
  }

 wrapup:
  return;
  
}

/* -----------------------------------------------------------
 * Returns name of the SA/PSA item belongs to (if any)
 */
static void getNameForSA(TGRid *nodeID, IGRchar *nodeName)
{
  TGRid   node1ID;
  TGRid   node2ID;
  IGRchar node1Type[128];

  IGRchar psaName[128];
  
  // Init
  *nodeName = 0;
  *psaName  = 0;
  node1ID = *nodeID;
  
  // Cycle up until sa or psa is found
  while(1) {

    getNodeType(&node1ID,node1Type);

    if (!strcmp(node1Type,"PSA")) {
      VDctxGetNodeName(&node1ID,psaName);
    }

    if (!strcmp(node1Type,"SA")) {
      VDctxGetNodeName(&node1ID,nodeName);
      strcat(nodeName,psaName);
      goto wrapup;
    }

    if (!strncmp(node1Type,"SA",2)) {
      strcpy(nodeName,node1Type + 2);
      strcat(nodeName,psaName);
      goto wrapup;
    }

    VDctxGetTreeParent(&node1ID,&node2ID);
    if (node2ID.objid == NULL_OBJID) goto wrapup;
    
    node1ID = node2ID;
  }

 wrapup:
  return;
}

/* -----------------------------------------------------------
 * Returns name of the PSU/CPSU item belongs to (if any)
 * For pieces, return 0 if item is not connected to psu
 */
static IGRstat getNameForPSU(TGRid *nodeID, IGRchar *nodeName)
{
  IGRstat retFlag = 0;
  
  TGRid   node1ID;
  TGRid   node2ID;
  IGRchar node1Type[128];

  IGRchar cpsuName[128];
  
  // Init
  *nodeName = 0;
  *cpsuName = 0;
  node1ID = *nodeID;
  
  // Cycle up until psu or cpsu is found
  while(1) {
    
    getNodeType(&node1ID,node1Type);

    if (!strcmp(node1Type,"CPSU")) {
      VDctxGetNodeName(&node1ID,cpsuName);

      // Most of the time have a PSU
      if (*nodeName == 0) {

	/* -----------------------------------------------------
	 * Don't know where theis PIECE stuff is coming from
	 * Plates and beams don't override node_type
	 * and leafs are of type PM
	 */
	// If no psu and extracting for a PIECE then use PSU = 0
	//vdsa$GetStruct(objID = nodeID, name = "node_type", txt = node1Type);
	getNodeType(nodeID,node1Type);
	if (!strcmp(node1Type,"PIECE")) strcpy(nodeName,"0");
      }      
      strcat(nodeName,cpsuName);
      retFlag = 1;
      goto wrapup;
    }

    // Check for psu
    if (!strcmp(node1Type,"PSU")) {
	VDctxGetNodeName(&node1ID,nodeName);
     // Cannot return yet since might be part of cpsu
    }

    VDctxGetTreeParent(&node1ID,&node2ID);

    if (node2ID.objid == NULL_OBJID) {

      // A PIECE is always assumed to be part of some psu
      // use PSU of 0 for direct connections
      getNodeType(nodeID,node1Type);
      if (!strcmp(node1Type,"PIECE")) {
	strcpy(nodeName,"0");
	retFlag = 1;
      }
      goto wrapup;
    }
    node1ID = node2ID;
  }
  
 wrapup:
  return retFlag;
  
}

/* -----------------------------------------------------------
 * Returns piece mark if any
 */
static void getNameForPCMK(TGRid *nodeID, IGRchar *pcmk)
{ 
  // Just a wrapper for now
  VDctxGetTxtAtr(nodeID,"pcmk",pcmk);
  return;  
}


/* --------------------------------------------------------------------
 * Returns the name of the node of nodeType
 */
static IGRstat getNameForNode(TGRid *nodeID, IGRchar *nodeType, IGRchar *nodeName)
{
  IGRstat retFlag = 0;
  
  TGRid   node1ID;
  TGRid   node2ID;
  IGRchar node1Type[128];

  // Init
  *nodeName = 0;
  node1ID = *nodeID;
  node2ID = *nodeID;

  // Cycle up until the nodeType is found
  while(node1ID.objid != NULL_OBJID) {

    // Test It
    getNodeType(&node1ID,node1Type);    
    if (!strcmp(node1Type,nodeType)) {
      VDctxGetNodeName(&node1ID,nodeName);
      retFlag = 1;
      goto wrapup;    
    }

    // Go Up
    VDctxGetTreeParent(&node1ID,&node2ID);
    node1ID = node2ID;
  }

 wrapup:
  return retFlag;
  
}

/* ------------------------------------------------------------
 * Gets full path for a node handling all swapping and special cases
 *
 * Note that the function has a VDat prefix, it overrides the
 * older VDat function which needs to be removed for the pload
 */
IGRstat VDatGetNodePath(TGRid *nodeID, IGRchar *node_path)
{
  IGRstat retFlag = 0;

  IGRchar unit_name[128];
  IGRchar   sa_name[128];
  IGRchar  psu_name[128];
  IGRchar pcmk_name[128];
  
  // Init
  *node_path = 0;
  
  // Get various elements
  getNameForUnit(nodeID,unit_name);
  getNameForSA  (nodeID,  sa_name);
  getNameForPSU (nodeID, psu_name);
  getNameForPCMK(nodeID,pcmk_name);

  strcpy(node_path,unit_name);

  // printf("Path %s %s %s %s\n",unit_name,sa_name,psu_name,pcmk_name);
  
  // If there is no unit then fail
  if (*unit_name == 0) goto wrapup;
  
  // Always start with type for now
  getNodeType(nodeID,node_path);

  // Except for 3 letter SA types
  if (!strncmp(node_path,"SA",2)) {
    *(node_path+2) = 0;
  }
  
  // Add Unit
  if (*unit_name) {
    strcat(node_path," ");
    strcat(node_path,unit_name);
  }
  // Add sa
  if (*sa_name) {
    strcat(node_path,"-");
    strcat(node_path,sa_name);
  }
  // Add psu
  if (*psu_name) {
    strcat(node_path,"-");
    strcat(node_path,psu_name);
  }
  // Add pcmk
  if (*pcmk_name) {
    strcat(node_path,"-");
    strcat(node_path,pcmk_name);
  }
  retFlag = 1;
  
wrapup:
  return retFlag;
}


/* -----------------------------------------------------------
 * Provide a common interface for getting a pieces stage
 * First look for an attribute
 * then calculate it
 */
void VDctxGetPieceStage(TGRid *nodeID, IGRchar *stage)
{
  VDASSERT_FN("VDctxGetPieceStage");
  
  TGRid   parentID;
  
  // Arg check
  VDASSERTW(stage); *stage = 0;
  VDASSERTW(nodeID && nodeID->objid != NULL_OBJID);
  
  // Check for attribute
  VDctxGetTxtAtr(nodeID,"piece_stage",stage);
  if (*stage) goto wrapup;

  // Grab the parent
  VDctxGetTreeParent(nodeID,&parentID);
  if (parentID.objid == NULL_OBJID) goto wrapup;
  
  // Calc it
  VDatGetNodePath(&parentID,stage);

  // Done
 wrapup:
  return;
}

void VDctxGetStagePath(TGRid *nodeID, IGRchar *path)
{
  VDASSERT_FN("VDctxGetStagePath");
  
  // Arg check
  VDASSERTW(path); *path = 0;
  VDASSERTW(nodeID && nodeID->objid != NULL_OBJID);
  
  // Check for attribute
  VDctxGetTxtAtr(nodeID,"stage_path",path);
  if (*path) goto wrapup;

  // Calc it
  VDatGetNodePath(nodeID,path);
  
  // Done
 wrapup:
  return;
}

/* -----------------------------------------------
 * Just to hide the actual attribute name
 * when creating snapshots
 */
void VDctxSetPieceStage(TGRid *nodeID, IGRchar *stage)
{
  VDASSERT_FN("VDctxSetPieceStage");
  
  // Arg check
  VDASSERTW(stage);
  VDASSERTW(nodeID && nodeID->objid != NULL_OBJID);
  
  // Doit 
  VDctxAppTxtAtr(nodeID,"piece_stage",stage);
 
 wrapup:
  return;
}
void VDctxSetStagePath(TGRid *nodeID, IGRchar *path)
{
  VDASSERT_FN("VDctxSetStagePath");
  
  // Arg check
  VDASSERTW(path);
  VDASSERTW(nodeID && nodeID->objid != NULL_OBJID);
  
  // Doit 
  VDctxAppTxtAtr(nodeID,"stage_path",path);
 
 wrapup:
  return;
}

/* -----------------------------------------------
 * Add stages to the list
 * Anything that is not a piece must be a stage
 * If data->max is 0 then effectivily get only the count 
 */
void VDctxWalkProcessGetStages(TGRid *nodeID, void *datax, IGRint *stopWalk)
{
  TVDctxNodeList *data = datax;
  IGRchab nodeType;

  IGRchar *p;
  
  VDctxGetNodeTypeSuffix(nodeID,nodeType);
  
  if (strcmp(nodeType,"beam")  &&
      strcmp(nodeType,"plate") &&
      strcmp(nodeType,"piece") &&
      strcmp(nodeType,"PM")    &&
      strcmp(nodeType,"pm"))   {
  }
  else goto wrapup;

  // Save it
  if (data->cnt < data->max) {
    data->listIDs[data->cnt] = *nodeID;
  }
  data->cnt++;

 wrapup:  
  return;
}

/* ---------------------------------------------------
 * Grab a list of stages from the node
 */
void VDctxGetListStages(TGRid *treeID, TVDctxNodeList *nodeList)
{
  VDASSERT_FN("VDctxGetListStages");

  IGRint stopWalk = 0;
  IGRint cnt;
  
  // Arg check
  VDASSERTW(nodeList);
  VDctxInitNodeList(nodeList);  
  VDASSERTW(treeID && treeID->objid != NULL_OBJID);
  
  // Walk for the count
  VDctxWalkNode(treeID,1,VDctxWalkProcessGetStages,nodeList,&stopWalk);
  cnt = nodeList->cnt;
  nodeList->cnt = 0;
  if (cnt == 0) goto wrapup;
  
  // Allocate
  nodeList->listIDs = calloc(cnt,nodeList->size);
  VDASSERTW(nodeList->listIDs);
  nodeList->max = cnt;
  
  // Walk for the nodes
  VDctxWalkNode(treeID,1,VDctxWalkProcessGetStages,nodeList,&stopWalk);
  VDASSERTW(nodeList->cnt == nodeList->max);
  
  // Done
 wrapup:
  return;
}

/* -------------------------------------------------
 * Pulls the staging tree node from the xml tree
 * Needs to be enhanced to deal with an actual at
 * tree as well
 */
void VDctxGetStagingTreeRootNode(TGRid *treeID, TGRid *rootID)
{
  VDASSERT_FN("VDctxGetStagingTreeRootNode");
  
  // Arg check
  VDASSERTW(rootID);  rootID->objid  = NULL_OBJID;
  VDASSERTW(treeID && treeID->objid != NULL_OBJID);
  
  // Just look for the node for now
  VDctxGetNodeByType(treeID,VDCTX_NODE_TYPE_SS_ST_ROOT,rootID);
  if (rootID->objid != NULL_OBJID) goto wrapup;
  
  // Look through at tree

 wrapup:
  return;
}

/* -------------------------------------------------
 * Changes node type into a standard node type
 * and optionally maps it to an number
 */
void VDctxGetStagingTreeNodeType(TGRid *nodeID, IGRchar *nodeType, IGRint *nodeTypeIndex)
{
  VDASSERT_FN("VDctxGetStagingTreeNodeType");
  
  IGRchar *p;
  
  // Arg check
  if (nodeTypeIndex) *nodeTypeIndex = 0;
  VDASSERTW(nodeType); *nodeType = 0;
  VDASSERTW(nodeID && nodeID->objid != NULL_OBJID);

  // Get it
  VDctxGetNodeType(nodeID,nodeType);
  VDASSERTW(*nodeType);
  
  // Clean the node type
  p = strrchr(nodeType,'_');
  if (p) strcpy(nodeType,p+1);
  strlwr(nodeType);
  if (nodeTypeIndex == NULL) goto wrapup;
  
  // Map it
  if (!strcmp(nodeType,"unit")) {
    *nodeTypeIndex = 1;
    goto wrapup;
  }
  if (!strcmp(nodeType,"sae")) {
    *nodeTypeIndex = 2;
    goto wrapup;
  }
  if (!strcmp(nodeType,"sab")) {
    *nodeTypeIndex = 3;
    goto wrapup;
  }
  if (!strcmp(nodeType,"saf")) {
    *nodeTypeIndex = 4;
    goto wrapup;
  }
  if (!strcmp(nodeType,"sam")) {
    *nodeTypeIndex = 5;
    goto wrapup;
  }
  if (!strcmp(nodeType,"sa")) {
    *nodeTypeIndex = 6;
    goto wrapup;
  }
  if (!strcmp(nodeType,"psa")) {
    *nodeTypeIndex = 7;
    goto wrapup;
  }
  if (!strcmp(nodeType,"cpsu")) {
    *nodeTypeIndex = 8;
    goto wrapup;
  }
  if (!strcmp(nodeType,"psu")) {
    *nodeTypeIndex = 9;
    goto wrapup;
  }

  /* ---------------------------------------------
   * Everything else is a piece
   */
  *nodeTypeIndex = 10;
  
 wrapup:
  return;
}
/* -------------------------------------------------
 * Little routine for sorting staging tree nodes
 */
IGRint VDctxCompareStagingTreeNodeTypeName(const void *v1, const void *v2)
{
  TGRid *node1ID = (TGRid*)(v1);
  TGRid *node2ID = (TGRid*)(v2);
  
  TVDctxBaseInfo baseInfo1;
  TVDctxBaseInfo baseInfo2;
  
  IGRint nodeType1;
  IGRint nodeType2;
  IGRint nodeName1;
  IGRint nodeName2;
  
  // Get the types
  VDctxGetStagingTreeNodeType(node1ID,baseInfo1.nodeType,&nodeType1);
  VDctxGetStagingTreeNodeType(node2ID,baseInfo1.nodeType,&nodeType2);
  if (nodeType1 < nodeType2) return -1;
  if (nodeType1 > nodeType2) return  1;
  
  // Check the names
  VDctxGetNodeName(node1ID,baseInfo1.nodeName);
  VDctxGetNodeName(node2ID,baseInfo2.nodeName);

  nodeName1 = atoi(baseInfo1.nodeName);
  nodeName2 = atoi(baseInfo2.nodeName);

  if (nodeName1 < nodeName2) return -1;
  if (nodeName1 > nodeName2) return  1;
  
  return strcmp(baseInfo1.nodeName,baseInfo2.nodeName);
}

