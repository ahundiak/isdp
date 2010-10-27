/***************************************************************************
 * I/VDS
 *
 * File:        vdat/pcmk2/VDatNodePath.c
 *
 * Description: Moved some routines from StagingTree.u to improve speed
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatNodePath.c,v $
 *      Revision 1.3  2001/10/19 18:22:34  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/04/05 14:16:25  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/04/04 14:16:31  ahundiak
 *      *** empty log message ***
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/03/01  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"

#include "VDdoom.h"
#include "VDlog.h"
#include "VDctx.h"
#include "VDss.h"
#include "VDat.h"

VDASSERT_FFN("vdat/pcmk2/VDatNodePath.c");

/* -------------------------------------------------
 * Validates name format for given stage type
 * Changing the actual name in some cases
 *
 * Returns some info about what it finds in msg
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

    VDctxGetNodeType(&node1ID,node1Type);
    
    if (strcmp(node1Type,"UNIT") == 0) {
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

    VDctxGetNodeType(&node1ID,node1Type);

    if (strcmp(node1Type,"PSA") == 0) {
      VDctxGetNodeName(&node1ID,psaName);
    }

    if (strcmp(node1Type,"SA") == 0) {
      VDctxGetNodeName(&node1ID,nodeName);
      strcat(nodeName,psaName);
      goto wrapup;
    }

    if (strncmp(node1Type,"SA",2) == 0) {
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

    VDctxGetNodeType(&node1ID,node1Type);

    if (strcmp(node1Type,"CPSU") == 0) {
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
	VDctxGetNodeType(nodeID,node1Type);
	if (strcmp(node1Type,"PIECE") == 0) {
	  strcpy(nodeName,"0");
	}
      }
      
      strcat(nodeName,cpsuName);
      retFlag = 1;
      goto wrapup;
    }

    // Check for psu
    if (strcmp(node1Type,"PSU") == 0) {
	VDctxGetNodeName(&node1ID,nodeName);
     // Cannot return yet since might be part of cpsu
    }

    VDctxGetTreeParent(&node1ID,&node2ID);
    if (node2ID.objid == NULL_OBJID) {

      // A PIECE is always assumed to be part of some psu
      // use PSU of 0 for direct connections
      VDctxGetNodeType(nodeID,node1Type);
      if (strcmp(node1Type,"PIECE") == 0) {
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
    VDctxGetNodeType(&node1ID,node1Type);    
    if (strcmp(node1Type,nodeType) == 0) {
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
 */
IGRstat VDatGetNodePath(TGRid *nodeID, IGRchar *node_path)
{
  IGRstat retFlag = 0;

  IGRchar unit_name[128];
  IGRchar   sa_name[128];
  IGRchar  psu_name[128];
  IGRchar pcmk_name[128];
  
  // Init
  retFlag = 0;
  *node_path = 0;
  
  // Get various elements
  getNameForUnit(nodeID,unit_name);
  getNameForSA  (nodeID,  sa_name);
  getNameForPSU (nodeID, psu_name);
  getNameForPCMK(nodeID,pcmk_name);

  // Always start with type for now
  VDctxGetNodeType(nodeID,node_path);

  // Except for 3 letter SA types
  if (strncmp(node_path,"SA",2) == 0) {
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
 * Provide a common interface for the staging tree node path
 * First look for an attribute
 * then calculate it
 */
void VDctxGetStagingTreeNodePath(TGRid *nodeID, IGRchar *nodePath)
{
  VDASSERT_FN("VDctxGetStagingTreeNodePath");
  
  // Arg check
  VDASSERTW(nodePath); *nodePath = 0;
  VDASSERTW(nodeID && nodeID->objid != NULL_OBJID);
  
  // Check for attribute
  VDctxGetTxtAtr(nodeID,"node_path",nodePath);
  if (*nodePath) goto wrapup;
  
  // Calc it
  VDatGetNodePath(nodeID,nodePath);

  // Done
 wrapup:
  return;
}

/* -----------------------------------------------------------
 * Provide a common interface for the staging tree parent path
 * First look for an attribute
 * then calculate it
 */
void VDctxGetStagingTreeParentPath(TGRid *nodeID, IGRchar *nodePath)
{
  VDASSERT_FN("VDctxGetStagingTreeParentPath");
  
  TGRid   parentID;
  
  // Arg check
  VDASSERTW(nodePath); *nodePath = 0;
  VDASSERTW(nodeID && nodeID->objid != NULL_OBJID);
  
  // Check for attribute
  VDctxGetTxtAtr(nodeID,"parent_path",nodePath);
  if (*nodePath) goto wrapup;

  // Grab the parent
  VDctxGetTreeParent(nodeID,&parentID);
  if (parentID.objid == NULL_OBJID) goto wrapup;
  
  // Calc it
  VDctxGetStagingTreeNodePath(&parentID,nodePath);

  // Done
 wrapup:
  return;
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
  VDctxGetStagingTreeNodePath(&parentID,stage);

  // Done
 wrapup:
  return;
}

/* -----------------------------------------------
 * Just to hide the actual attribute name
 * when creating snapshots
 */
void VDctxSetStagingTreeNodePath(TGRid *nodeID, IGRchar *nodePath)
{
  VDASSERT_FN("VDctxSetStagingTreeNodePath");
  
  // Arg check
  VDASSERTW(nodePath);
  VDASSERTW(nodeID && nodeID->objid != NULL_OBJID);
  
  // Doit 
  VDctxAppTxtAtr(nodeID,"node_path",nodePath);
 
 wrapup:
  return;
}

void VDctxSetStagingTreeParentPath(TGRid *nodeID, IGRchar *nodePath)
{
  VDASSERT_FN("VDctxSetStagingTreeParentPath");
  
  // Arg check
  VDASSERTW(nodePath);
  VDASSERTW(nodeID && nodeID->objid != NULL_OBJID);
  
  // Doit 
  VDctxAppTxtAtr(nodeID,"parent_path",nodePath);
 
 wrapup:
  return;
}
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

