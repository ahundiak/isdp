/* $Id: VDatLeaf.I,v 1.5 2001/03/16 17:05:40 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/set/VDatLeaf.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatLeaf.I,v $
 *      Revision 1.5  2001/03/16 17:05:40  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/01/23 13:58:24  ahundiak
 *      mixup
 *
 *      Revision 1.2  2001/01/11 21:12:34  art
 *      sp merge
 *
# Revision 1.2  2000/11/27  19:14:30  pinnacle
# ah
#
# Revision 1.8  2000/03/31  17:09:12  pinnacle
# ah
#
# Revision 1.7  2000/02/14  19:47:16  pinnacle
# tr179901064
#
# Revision 1.6  2000/01/10  19:20:04  pinnacle
# ah
#
# Revision 1.5  1998/11/07  14:04:16  pinnacle
# ah
#
# Revision 1.3  1998/10/11  13:53:52  pinnacle
# ah
#
# Revision 1.2  1998/09/29  21:15:06  pinnacle
# ah
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/25/97  ah      creation
 * 01/10/00  ah      Added more messages when leaf object cannot be found
 * 02/14/00  ah      TR179901064 Crashing when getting ref file names.
 * 03/28/00  ah      Added some misc routines, VDat.h
 * 11/09/00  ah      When reattaching a piece, make sure the child piece has
 *                   not somehow already been put in the tree
 * 03/16/01  ah      Plates and beams whose names had changedwere not being detected
 *                   Also had a problem where a leaf was attached to something
 *                   which was no longer a plate or beam 
 *                   The change was actually nade for 2.6.1.11 SP16 right before pload for
 *                   2.6.2,  The service pack file was used then copied into 2.6.2
 *                   code base and cvs info added.
 ***************************************************************************/

class implementation VDatBase;

#include "VDsa.h"
#include "VDobj.h"
#include "VDdir.h"
#include "VDppl1.h"
#include "VDat.h"

#include "asmacros.h"

#include "v_dbgmacros.h"

from VDSroot import VDprocAttr;

#define VDAT_ATTR_LEAF_NAME "leaf_name"

/* -----------------------------------------------
 * Return true if it is a leaf object
 */
IGRstat VDatIsLeaf(TGRid *nodeID)
{
  IGRstat retFlag = 0;
  IGRint  type;

  // Easy
  VDatGetBaseType(nodeID,&type);
  if (type == VDAT_CLASSI_LEAF) retFlag = 1;
  
  return retFlag;
}

/* -----------------------------------
 * Recursive routine to count leafs
 * Calling routine must init cnt to 0
 * before calling
 */
IGRstat VDatGetNumLeafs(TGRid *objID, IGRint *cnt)
{
  IGRstat retFlag = 0;
  TGRid   leafsID,listID,leafID;
  IGRint  i,j;

  IGRint type;

  VDatGetBaseType(objID,&type);
  switch(type) {

  case VDAT_CLASSI_LEAF: {
    *cnt = *cnt + 1;
    retFlag = 1;
    goto wrapup;
  }

  case VDAT_CLASSI_SET: {

    // Get list of sets
    VDatGetLeafs(objID,&leafsID);
    if (leafsID.objid == NULL_OBJID) goto wrapup;

    // Cycle through
    for(i = 0; VDatGetChildObject(&leafsID,i,&listID); i++) {
      for(j = 0; VDatGetChildObject(&listID,j,&leafID); j++) {
        *cnt = *cnt + 1;
      }
    }
    retFlag = 1;
    goto wrapup;
  }

  case VDAT_CLASSI_TREE: 
  case VDAT_CLASSI_NODE: {

    // Recursive Loop
    for(i = 0; VDatGetChildObject(objID,i,&listID); i++) {
      VDatGetNumLeafs(&listID,cnt);
    }
    retFlag = 1;
    goto wrapup;
  }

  }

  // Unusual object, just return

wrapup:
  return retFlag;
}

/* -----------------------------------
 * Fills in vla with all leaf id's
 * Recursive routine in which the objID can be different
 * objects (set,node or tree)
 */
IGRstat VDatGetLeafsVLA(TGRid *objID, TVDvlaID *leafVLA)
{
  IGRstat retFlag = 0;
  TGRid   leafsID,listID,leafID;
  IGRint  i,j;

  IGRint type;

  VDatGetBaseType(objID,&type);
  switch(type) {

  case VDAT_CLASSI_LEAF: {
    VDvlaID_Append(leafVLA,objID);
    retFlag = 1;
    goto wrapup;
  }

  case VDAT_CLASSI_SET: {

    // Get list of sets
    VDatGetLeafs(objID,&leafsID);
    if (leafsID.objid == NULL_OBJID) goto wrapup;

    // Cycle through
    for(i = 0; VDatGetChildObject(&leafsID,i,&listID); i++) {
      for(j = 0; VDatGetChildObject(&listID,j,&leafID); j++) {
        VDvlaID_Append(leafVLA,&leafID);
      }
    }
    retFlag = 1;
    goto wrapup;
  }

  case VDAT_CLASSI_TREE: 
  case VDAT_CLASSI_NODE: {

    // Recursive Loop
    for(i = 0; VDatGetChildObject(objID,i,&listID); i++) {
      VDatGetLeafsVLA(&listID,leafVLA);
    }
    retFlag = 1;
    goto wrapup;
  }

  }

  // Unusual object, just return

wrapup:
  return retFlag;
}

/* -----------------------------------------
 * Create a leaf for a model object
 */
IGRstat VDatCreateLeaf(TGRid *setID, TGRobj_env *objOE, TGRid *leafID)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  TGRid   sourceID;

  TGRid   leafsID;

  TGRid   rdbNodeID;

  IGRchar setType[64];
  IGRint  ind;
  TGRid   listID;

  TGRid   pplID;
  IGRint  pplRET;

  IGRint  doSum;

#if 0
  TGRid   pieceID;
  VDclassid objCLASS;

  IGRchar ppl[128];
  IGRchar isDetail[128];
#endif

  // Init
  UI_status("Creating leaf...");
  leafID->objid = NULL_OBJID;

  /* --------------------------------------------
   * This has a second function of allowing the
   * ppl to reject the piece completely
   */
  VDatRDBGetSetType(setID,setType);

  vdppl$Load(name = setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) {
    printf("Could not load %s.e",setType);
    goto wrapup;
  }

  vdppl$SetData(pplID = &pplID,
                name  = "PIECE_OE",
                size  = sizeof(TGRobj_env),
                data  = (IGRchar*)objOE);
  
  vdppl$Run(pplID = &pplID, name = "getListInd", ret = &pplRET);

  vdppl$GetData(pplID = &pplID,
                name  = "LIST_IND",
                size  = sizeof(IGRint),
                data  = (IGRchar*)&ind);

  vdppl$Delete(pplID = &pplID);

  // Check for rejection
  if (ind < 0) goto wrapup;

  // Source It
  sourceID.objid = NULL_OBJID;
  sts = as$make_source(
    go_grid =  objOE->obj_id,
    mod_env = &objOE->mod_env,
    as_os   =  objID->osnum,
    as_grid = &sourceID
  );
  if (sourceID.objid == NULL_OBJID) goto wrapup;

  // Make the leaf
  vdat$CreateBase(
    name    = VDAT_CLASSN_LEAF,
    type    = VDAT_CLASSI_LEAF,
    osnum   = setID->osnum,
    baseID  = leafID
  );
  if (leafID->objid == NULL_OBJID) goto wrapup;

  // Link To Model
  VDatAddParent(&sourceID,leafID);

  // Get the leafs
  VDatGetLeafs(setID,&leafsID);
  if (leafsID.objid == NULL_OBJID) goto wrapup;

  // Hook to first rdb node in set
  VDatRDBGetNode(setID,&rdbNodeID);
  if (rdbNodeID.objid == NULL_OBJID) goto wrapup;
  VDatAddParent(leafID,&rdbNodeID);

  // ind was obtained before from a ppl
  listID.objid = NULL_OBJID;
  switch(ind) {
    case 0: VDatGetChildByType(&leafsID,VDAT_CLASSI_PLATES,&listID); break;
    case 1: VDatGetChildByType(&leafsID,VDAT_CLASSI_BEAMS, &listID); break;
    case 2: VDatGetChildByType(&leafsID,VDAT_CLASSI_OTHERS,&listID); break;
  }
  if (listID.objid == NULL_OBJID) {
    listID = leafsID;
  }
  VDatAddParent(leafID,&listID);

  // Xfer default attributes
  VDatSetDefaultAttrs(leafID);

  // Compute it
  vdat$GetSetTypeInfo(setID = setID, setTypeDoSum = &doSum);
  if (doSum > 1) VDatComputeLeaf(leafID,VDAT_FLAG_SUM);
  else           VDatComputeLeaf(leafID,0);
  
  // Done
  retFlag = 1;

wrapup:
  UI_status("");
  return retFlag;
}

/* -------------------------------------------
 * Gets list of leafs for a set
 */
IGRstat VDatGetLeafs(TGRid *setID, TGRid *leafsID)
{
  IGRstat retFlag = 0;

  VDatGetChildByType(setID,VDAT_CLASSI_LEAFS,leafsID);
  if (leafsID->objid == NULL_OBJID) goto wrapup;

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------
 * Creates LEAFS system if required
 */
IGRstat VDatCreateLeafs(TGRid *setID, TGRid *leafsID)
{
  IGRstat retFlag = 0;
  TGRid   listID;

  // See if already have it
  VDatGetLeafs(setID,leafsID);
  if (leafsID->objid != NULL_OBJID) {
    retFlag = 1;
    goto wrapup;
  }

  vdat$CreateBase(
    name     = VDAT_CLASSN_LEAFS, 
    type     = VDAT_CLASSI_LEAFS,
    parentID = setID,
    baseID   = leafsID
  );
  vdat$CreateBase(
    name     = VDAT_CLASSN_PLATES,
    type     = VDAT_CLASSI_PLATES,
    parentID = leafsID,
    baseID   = &listID
  );
  vdat$CreateBase(
    name     = VDAT_CLASSN_BEAMS, 
    type     = VDAT_CLASSI_BEAMS, 
    parentID = leafsID,
    baseID   = &listID
  );
  vdat$CreateBase(
    name     = VDAT_CLASSN_OTHERS,
    type     = VDAT_CLASSI_OTHERS,
    parentID = leafsID,
    baseID   = &listID
  );

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------
 * Gets the model object from a leaf
 */
IGRstat VDatGetLeafObject(TGRid *leafID, TGRobj_env *objOE)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  TGRid childID;

  // Init
  objOE->obj_id.objid = NULL_OBJID;

  // Should only have one child
  VDatGetChildObject(leafID,0,&childID);
  if (childID.objid == NULL_OBJID) goto wrapup;

  // Need to test with plates in local file
  sts = om$send(
    msg = message NDmacro.ACreturn_foot(
      &msg,"",
      &objOE->obj_id,
      &objOE->mod_env.md_env.matrix_type,
       objOE->mod_env.md_env.matrix
    ),
    senderid = NULL_OBJID,
    targetid = childID.objid,
    targetos = childID.osnum
  );
  if (!(sts & msg & 1)) {

#if 0
    printf("*** Failed to get the connected model object for leaf %d,%d\n",
	   leafID->osnum,
	   leafID->objid);
#endif

    goto wrapup;
  }
  objOE->mod_env.md_id.osnum = objOE->obj_id.osnum;
  ex$get_modid(
    mod_osnum =  objOE->mod_env.md_id.osnum, 
    mod_id    = &objOE->mod_env.md_id.objid
  );

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------
 * Gets the name of a leaf
 * which is actually the name of the model object
 *
 * 09/29/1998 This should no longer be called
 * Instead, ask for attribute VDAT_ATTR_COMP_NAME
 * which is dynamically derived from the internal copy
 * of the component's path
 *
 * On second thought, keeping this around might be useful
 * map the ACgive_struct routine to here
 * One thing it will do is to store the path in the leaf if
 * one is not already there.  This will allow updating older trees
 * more or less automatically.
 */
IGRstat VDatGetLeafName(TGRid *leafID, IGRchar *leafName)
{
  IGRstat retFlag = 0;
  /*
  IGRchar    objPATH[DI_PATH_MAX];
  IGRchar   *pnt;
  */
  TVDatFld fld;
  TGRobj_env pieceOE;
  
  TGRid  pplID;
  IGRint pplRET;
  
  IGRchar setType[64];
  
  // Init
  *leafName = 0;

  // Some pieces need a user supplied name
  VDatFldGetAttrByName(leafID,VDAT_ATTR_LEAF_NAME,&fld);
  if (*fld.valueTxt != 0) {
    strcpy(leafName,fld.valueTxt);
    return 1;
  }

  // Get it from the object
  VDatGetLeafObject(leafID,&pieceOE);
  if (pieceOE.obj_id.objid == NULL_OBJID) goto wrapup;

  // Hook to ppl
  VDatRDBGetSetType(leafID,setType);
  vdppl$Load(name = setType, pplID = &pplID);

  if (pplID.objid == NULL_OBJID) {
    printf("Could not load %s.e",setType);
    goto wrapup;
  }

  vdppl$SetData(pplID = &pplID,
                name  = "NODE_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)leafID);

  vdppl$SetData(pplID = &pplID,
                name  = "PIECE_OE",
                size  = sizeof(TGRobj_env),
                data  = (IGRchar*)&pieceOE);
  
  vdppl$Run(pplID = &pplID, name = "getLeafName", ret = &pplRET);

  vdppl$GetData(pplID = &pplID,
                name  = "NODE_NAME",
                size  =  64,
                data  =  leafName);

  vdppl$Delete(pplID = &pplID);

  // get the path
  //VDatGetLeafPath(leafID,objPATH);
  
  // Name is just last part
  //pnt = strrchr(objPATH,':');
  //if (pnt == NULL) goto wrapup;

  //strcpy(leafName,pnt+1);
  if (*leafName) {  
    retFlag = 1;
    goto wrapup;
  }
  
  // At least know what calss was gotten
  vdobj$Get(objOE = &pieceOE, className = leafName);
  
wrapup:
  return retFlag;
}

/* -----------------------------------------
 * Sets the internal copy of the pieces path
 */
IGRstar VDatSetLeafPath(TGRid *leafID)
{
  IGRstat retFlag = 0;
  IGRstat msg;

  TGRobj_env pieceOE;
  IGRchar    piecePath[DI_PATH_MAX];
  IGRchar   *p;

  TVDatFld   fld;
  
  // Verify have a leaf class just in case
  if (!VDatIsBaseType(leafID,VDAT_CLASSI_LEAF)) goto wrapup;
  
  // get the model object
  VDatGetLeafObject(leafID,&pieceOE);
  if (pieceOE.obj_id.objid == NULL_OBJID) goto wrapup;

  // Get the path
  *piecePath = 0;
  om$send(
    msg = message GRgraphics.GRgetname(&msg,piecePath),
    senderid = NULL_OBJID,
    targetid = pieceOE.obj_id.objid,
    targetos = pieceOE.obj_id.osnum
  );

  // Drop any ref file info
  p = strstr(piecePath,":ref:");
  if (p) strcpy(piecePath,p+4);

  // Protect against long paths, hope it won't be a problem later
  *(piecePath+78) = 0;
  
  // Save it internally if this is a leaf
  VDatFldSetTxt(&fld,VDAT_ATTR_COMP_PATH,piecePath);
  VDatFldUpdAllAttrs(leafID,&fld,1);
  
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------
 * Gets the path of a leaf
 * which is actually the path of the model object
 * with any :ref: dropped
 *
 * VDAT_ATTR_COMP_PATH calls this routine
 *
 * Normally returns the internal copy of the path but if none
 * exists, will ask the piece itself and then store it
 *
 * Not really sure if the set path is needed anymore but
 * do it anyways for now
 */
IGRstar VDatGetLeafPath(TGRid *leafID, IGRchar *leafPath)
{
  IGRstat retFlag = 0;

  TVDatFld fld;
  
  // Init
  *leafPath = 0;

  // Verify have a leaf class just in case
  if (!VDatIsBaseType(leafID,VDAT_CLASSI_LEAF)) goto wrapup;
  
  // Newer trees will have this stored as an attribute
  VDatFldGetAttrByName(leafID,VDAT_ATTR_COMP_PATH,&fld);
  if (*fld.valueTxt != 0) {
    strcpy(leafPath,fld.valueTxt);
    return 1;
  }
  
  // Ask the piece again
  VDatSetLeafPath(leafID);
  
  // Try again
  VDatFldGetAttrByName(leafID,VDAT_ATTR_COMP_PATH,&fld);
  if (*fld.valueTxt != 0) {
    strcpy(leafPath,fld.valueTxt);
    return 1;
  }

wrapup:
  return retFlag;
}

/* ------------------------------------------------------
 * Gets called by the NDcompute_node method when
 * a piece is updated
 */
IGRstat VDatLeafNDcompute_node(TGRid *leafID)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  TGRobj_env pieceOE;
  
  TGRobj_env childOE;

  // Say hi
  // printf("Entering VDatLeafNDcompute_node for\n");
  // vdobj$Print(objID = leafID);
  
  // Get the piece
  VDatGetLeafObject(leafID,&pieceOE);
  if (pieceOE.obj_id.objid == NULL_OBJID) goto wrapup;

  /* --------------------------------------------------
   * If the object is consumed then this implies it was
   * processed since it's original connection
   */
  msg = 0;
  sts = om$send(msg = message NDmacro.ACtest_consumed(&msg),
		senderid = NULL_OBJID,
		targetid = pieceOE.obj_id.objid,
		targetos = pieceOE.obj_id.osnum);

  if (sts & msg & 1) {

    // Get the child that consumed it
    VDatGetConsumingChild(&pieceOE,&childOE);

    if (childOE.obj_id.objid == NULL_OBJID) {
      printf("Problem getting consuming child for\n");
      vdobj$Print(objOE = &pieceOE);
      goto wrapup;
    }
    
    // Attach the new one
    VDatLeafAttachPiece(leafID,&childOE);
    
    // Use the new plate from here
    pieceOE = childOE;
    
  }

  // Compute it
  VDatComputeLeaf(leafID,VDAT_FLAG_SUM);
  
  retFlag = 1;
  
wrapup:
  return retFlag;
  
}

/* -------------------------------------------------------------
 * Attaches a piece to a leaf
 * Drops any previous attachments
 */
IGRstat VDatLeafAttachPiece(TGRid *leafID, TGRobj_env *pieceOE)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRid   sourceID;
  
  // Get rid of any previous attachements
  while(VDatGetChildObject(leafID,0,&sourceID)) {
    VDatDelParent(&sourceID,leafID);
  }

  // Source the new one
  sourceID.objid = NULL_OBJID;
  sts = as$make_source(
    go_grid =  pieceOE->obj_id,
    mod_env = &pieceOE->mod_env,
    as_os   =  leafID->osnum,
    as_grid = &sourceID
  );
  if (sourceID.objid == NULL_OBJID) goto wrapup;

  // Link To Model
  VDatAddParent(&sourceID,leafID);

  // Done
  retFlag = 1;

wrapup:  
  return retFlag;
}

/* -------------------------------------------------------------
 * Finds the child who consumed the parent.
 *
 * Will only work if the child is in the same file as the parent.
 *
 * The basic idea is that the GRgetname of the child will match that
 * of it's consumed parent
 */
IGRstar VDatGetConsumingChild(TGRobj_env *parentOE, TGRobj_env *childOE)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  IGRchar parentPath[DI_PATH_MAX];
  IGRchar childPath [DI_PATH_MAX];
  
  TGRid   childID;
  IGRint  i;

  TGRobj_env parentOEx;
  
  // Arg check
  if ((parentOE == NULL) || (childOE == NULL)) goto wrapup;
  *childOE = *parentOE;
  
  // Verify parent is consumed
  msg = 0;
  sts = om$send(msg = message NDmacro.ACtest_consumed(&msg),
		senderid = NULL_OBJID,
		targetid = parentOE->obj_id.objid,
		targetos = parentOE->obj_id.osnum);

  // If not consumed then just return itself
  if (!(sts & msg & 1)) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Get the parent's path
  *parentPath = 0;
  om$send(msg = message GRgraphics.GRgetname(&msg,parentPath),
	  senderid = NULL_OBJID,
	  targetid = parentOE->obj_id.objid,
	  targetos = parentOE->obj_id.osnum);

  // Without a path, this won't work
  if (*parentPath == 0) {
    goto wrapup;
  }
  
  // Cycle through kids
  for(i = 0; VDahGetChnObject(&parentOE->obj_id,"NDchildren.children",i,&childID); i++) {
    *childPath = 0;

    om$send(msg = message GRgraphics.GRgetname(&msg,childPath),
	    senderid = NULL_OBJID,
	    targetid = childID.objid,
	    targetos = childID.osnum);
    
    if (!strcmp(parentPath,childPath)) {
      
      // Got it
      childOE->obj_id = childID;
      
      // Recurse incase child itself is consumed
      parentOEx = *childOE;
      return VDatGetConsumingChild(&parentOEx,childOE);
      
    }
    
  }
  
  // Child not found, just return itself

wrapup:
  return retFlag;
}

/* --------------------------------------------------------------
 * Gets called when a piece wants to disconnect itself
 * from the leaf.  Assume this happens because the plate
 * is deleted
 *
 * If another plate with the same name as the one before is available
 * then switch to it
 */
IGRstar VDatLeafNDdisconnect(TGRid *leafID)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  // Say hi
  //printf("Entering VDatLeafNDdisconnect for\n");
  //vdobj$Print(objID = leafID);
  
  // See if another piece with the same name is around
  sts = VDatLeafAttachNewPiece(leafID);
  if (!(sts & 1)) {
    VDatDeleteBase(leafID);
    retFlag = 1;
    goto wrapup;
  }
  
  // Compute it
  VDatComputeLeaf(leafID,VDAT_FLAG_SUM);
  
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* --------------------------------------------------------------
 * Finds another piece based on the internal comp_path
 * and attaches it
 *
 * returns 0 if no new piece is found
 */
IGRstar VDatLeafAttachNewPiece(TGRid *leafID)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar piecePath[DI_PATH_MAX];
  IGRchar osFile   [DI_PATH_MAX];
  IGRchar newPath  [DI_PATH_MAX];

  TGRobj_env   pieceOE;
  TGRobj_env   childOE;
  
  IGRchar *p;

  TGRid leafIDx;
  TGRid setID;
  
  // Arg check
  if ((leafID == NULL) || (leafID->objid == NULL_OBJID)) goto wrapup;
  pieceOE.obj_id.objid = NULL_OBJID;
    
  // Need a path for possible reconnecting
  VDatGetLeafPath(leafID,piecePath);
  if (*piecePath == 0) goto wrapup;
  
  // First check in local file
  pieceOE.obj_id.objid = NULL_OBJID;
  di$translate(objname =  piecePath,
	       p_objid = &pieceOE.obj_id.objid,
	       p_osnum = &pieceOE.obj_id.osnum);

  if (pieceOE.obj_id.objid != NULL_OBJID) goto got_it;
  
  // Check in reference file
  di$give_pathname(osnum = leafID->osnum, pathname = osFile);

  // Get just the file
  p = strrchr(osFile,':');
  if (p) p++;
  else   p = osFile;
  
  sprintf(newPath,":%s:ref%s",p,piecePath);
  
  di$translate(objname =  newPath,
	       p_objid = &pieceOE.obj_id.objid,
	       p_osnum = &pieceOE.obj_id.osnum);

  if (pieceOE.obj_id.objid != NULL_OBJID) goto got_it;
  
  // Give up
  // printf("*** Unable to reattach %s\n",piecePath);
  goto wrapup;
  
  // -----------------------------------------------
  // Got a new piece so attach it
got_it:

  // Matrix should not be really important (I hope)
  gr$get_module_env(buffer = &pieceOE.mod_env);

  pieceOE.mod_env.md_id.osnum = pieceOE.obj_id.osnum;
  
  sts = ex$get_modid(
    mod_osnum =  pieceOE.mod_env.md_id.osnum, 
    mod_id    = &pieceOE.mod_env.md_id.objid
  );

  // This guy could be consumed
  VDatGetConsumingChild(&pieceOE,&childOE);

  /* ---------------------------------------------
   * 15 Mar 2001
   */
  sts = VDobjIsAncestryValid(&pieceOE,NULL,OM_K_NOTUSING_CLASSID,"VSplate");
  if (sts == 0) {
    sts = VDobjIsAncestryValid(&pieceOE,NULL,OM_K_NOTUSING_CLASSID,"VSbeam");
  }
  if (sts == 0) goto wrapup;
  
  /* ---------------------------------------------
   * It's possible that this guy could already be in the tree
   * Happens when the user ignores the Assoc Update Box and manages
   * to somehow get here?
   * Actually, I don't really know how it happens, just that is does happen
   *
   * By failing here, the calling routine knows to delete the leaf
   */
  VDatGetSet(leafID,&setID);
  VDatGetObjectLeaf(&childOE, &setID, &leafIDx);
  if (leafIDx.objid != NULL_OBJID) goto wrapup;
  
  //printf("Attaching piece\n");  
  VDatLeafAttachPiece(leafID,&childOE);

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------
 * It's possible for the leafs to get out of sync
 * with their pieces because of associativity and reference files
 *
 * This routine verifies the leafs are ok and attempts to repair
 * if they are not
 */
IGRstar VDatLeafVerifyPiece(TGRid *leafID)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  TGRobj_env pieceOE;

  IGRchar piecePath[128];
  IGRchar *p;
  
  TVDatFld fld;
  
  // Say hi
  // printf("VDatVerifyLeafObject ");
  // vdobj$Print(objID = leafID);
  
  // Get the object
  VDatGetLeafObject(leafID,&pieceOE);
  
  // Get the object
  VDatGetLeafObject(leafID,&pieceOE);
  if (pieceOE.obj_id.objid == NULL_OBJID) goto reattach;
  
  // If a compute is lost, then might be consumed
  msg = 0;
  sts = om$send(msg = message NDmacro.ACtest_consumed(&msg),
		senderid = NULL_OBJID,
		targetid = pieceOE.obj_id.objid,
		targetos = pieceOE.obj_id.osnum);
  
  // If not consumed
  if (sts & msg & 1) goto reattach;

  // See if plate name has changed
  *piecePath = 0;
  om$send(msg = message GRgraphics.GRgetname(&msg,piecePath),
	  senderid = NULL_OBJID,
	  targetid = pieceOE.obj_id.objid,
	  targetos = pieceOE.obj_id.osnum);
  p = strstr(piecePath,":ref:");
  if (p) strcpy(piecePath,p+4);
  
  VDatFldGetAttrByName(leafID,VDAT_ATTR_COMP_PATH,&fld);
  if (strcmp(piecePath,fld.valueTxt)) {
    printf("*** Leaf piece name has changed\n");
    printf("    PIECE %s\n",piecePath);
    printf("    LEAF  %s\n",fld.valueTxt);
    VDatComputeLeaf(leafID,VDAT_FLAG_SUM);
  }

  // Should be ok
  retFlag = 1;
  goto wrapup;
  
  // Try hooking up based on piecePath
 reattach:
  sts = VDatLeafAttachNewPiece(leafID);
  
  if (!(sts & 1)) {
    //printf("Warning VERIFY Failed for ");
    //vdobj$Print(objID = leafID);
    //printf("*** Part could not be reattached\n");
    goto wrapup;
  }
  //printf("### Part was successfully reattached\n");
  
  // Compute it
  VDatComputeLeaf(leafID,VDAT_FLAG_SUM);
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------------
 * Wrap some standard compute routines
 */
IGRstar VDatComputeLeaf(TGRid *leafID, IGRint flag)
{
  IGRstat retFlag = 0;
  IGRint  traceFlag = 0;

  IGRchar *p;
  
  // For isolating assoc update problems
  p = getenv("ISDP_SKIP_LEAF_UPDATES");
  if ((p) && (*p == 1)) return 1;
  
  // Say Hi
  if (traceFlag) {
    printf(">>> VDatComputeLeaf %d,%d Flag %d\n",
	   leafID->osnum,leafID->objid,flag);
  }
  
  //printf("Compute Leaf 1\n");
  
  retFlag = VDatSetLeafPath  (leafID);
  //if (!(retFlag & 1)) return retFlag;
  //printf("Compute Leaf 2\n");
  
  retFlag = VDatSetLeafPieceMark (leafID);
  //if (!(retFlag & 1)) return retFlag;
  //printf("Compute Leaf 3\n");
  
  if (flag & VDAT_FLAG_SUM) { 
    //printf("Summarizing leaf\n");
    retFlag = VDatSummarizeLeaf(leafID);
    //if (!(retFlag & 1)) return retFlag;
  }

  retFlag = 1;

  if (traceFlag) {
    printf("<<< VDatComputeLeaf %d,%d Flag %d\n",
	   leafID->osnum,leafID->objid,flag);
  }
  
  return retFlag;
}

/* --------------------------------------------
 * If a leaf has a piece mark attribute,
 * then determine if the piece has a standard
 * piece mark, if so, store it in the leaf.
 */
IGRstar VDatSetLeafPieceMark(TGRid *leafID)
{
  IGRstat    retFlag = 1;
  TVDatFld   fld;
  TGRobj_env pieceOE;
  IGRchar    ppl[128];

  // Only worry about leafs with pcmk attribute
  VDatFldGetAttrByName(leafID,VDAT_ATTR_PCMK,&fld);
  if (*fld.name == 0) goto wrapup;

  // Get the piece
  VDatGetLeafObject(leafID,&pieceOE);
  if (pieceOE.obj_id.objid == NULL_OBJID) goto wrapup;

  // Ask for it's piece mark
  sprintf(ppl,"%s%s:%s:%s",
    VDSA_KEY_SA_PPL,
    "VDatPiece",
    "GetPieceMark",
    "AssyTree");
  vdsa$GetStruct(objOE = &pieceOE, name = ppl, txt = fld.valueTxt);

  // Cheat here a bit and hard code test for standard
  switch(*fld.valueTxt) {
    case 'S':
    case 's':
    case 'C':
    case 'c':

      // Update leaf with the attribute
      VDatFldUpdAllAttrs(leafID,&fld,1);
      retFlag = 1;

  }
  retFlag = 1;
  
wrapup:
  return retFlag;
}

end implementation VDatBase;

