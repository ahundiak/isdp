/* $Id: VDatBase1.I,v 1.2 2001/01/11 20:37:26 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdat/imp/VDatBase1.I
 *
 * Description: Function interface to method's
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatBase1.I,v $
 *      Revision 1.2  2001/01/11 20:37:26  art
 *      sp merge
 *
# Revision 1.2  2000/06/27  16:27:28  pinnacle
# Display Problems
#
# Revision 1.1  2000/06/08  16:56:10  pinnacle
# Created: vds/vdat/imp/VDatBase1.I by azuurhou for Service Pack
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/25/97  ah      creation
 * 01/21/99  vinit   Modified VDatGetDisplayName 
 * 02/23/00  ah      Added piece mark to VDatGetDisplayName
 * 06/06/00  adz     Control display.
 * 06/25/00  ah      Took out the control display code for now
 *                   Added model objid's to VDatGetDisplayName but commented out
 *                   For now
 ***************************************************************************/

class implementation VDatBase;

#include "v_dbgmacros.h"
#include "v_miscmacros.h"
#include "VDppl1.h"
#include "VDsa.h"

/* -----------------------------------------------
 * Displays node and all children
 */
IGRstar VDatDisplayNode(TGRid *nodeID, enum GRdpmode mode) 
{
  TGRobj_env leafOE;

  TGRid      childID;
  IGRuint    i;

  IGRint type;

  if ((nodeID->objid == NULL_OBJID) || (nodeID->objid == 0)) return 0;

  VDatGetBaseType(nodeID,&type);

  if (type == VDAT_CLASSI_LEAF) {

    VDatGetLeafObject(nodeID,&leafOE);

    if (leafOE.obj_id.objid != NULL_OBJID) {
      vd_$bulk_display(dpmode = mode, objenvs = &leafOE);
    }
    return 1;
  }

  // Send to each child
  for(i = 0; VDatGetChildObject(nodeID,i,&childID); i++) {

    VDatDisplayNode(&childID,mode);

  }

  return 1;
}

/* -------------------------------------------------
 * Wrapper to extract type
 */
IGRstar VDatGetBaseType(TGRid *objID, IGRint *a_type)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRlong l_type = 0;

  // Init
  *a_type = 0;
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;

  sts = om$send(
    msg = message VDatBase.getType(&l_type),
    senderid = NULL_OBJID,
    targetid = objID->objid,
    targetos = objID->osnum
  );
  if (!(sts & 1)) goto wrapup;

  *a_type  = l_type;
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Wrapper to set type
 */
IGRstar VDatSetBaseType(TGRid *objID, IGRint a_type)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRlong type = a_type;

  // Arg Check
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;

  sts = om$send(
    msg = message VDatBase.setType(type),
    senderid = NULL_OBJID,
    targetid = objID->objid,
    targetos = objID->osnum
  );
  if (!(sts & 1)) goto wrapup;

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Wrapper to check for given type
 */
IGRstar VDatIsBaseType(TGRid *objID, IGRint a_type)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRlong l_type = 0;

  // Arg Check
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;

  sts = om$send(
    msg = message VDatBase.getType(&l_type),
    senderid = NULL_OBJID,
    targetid = objID->objid,
    targetos = objID->osnum
  );
  if (!(sts & 1)) goto wrapup;

  if (a_type == l_type) retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Wrapper to extract flag
 */
IGRstat VDatGetBaseFlag(TGRid *objID, IGRint *a_flag)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRlong l_flag = 0;

  // Init
  *a_flag = 0;
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;

  sts = om$send(
    msg = message VDatBase.getFlag(&l_flag),
    senderid = NULL_OBJID,
    targetid = objID->objid,
    targetos = objID->osnum
  );
  if (!(sts & 1)) goto wrapup;

  *a_flag  = l_flag;
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Wrapper to set flag
 */
IGRstat VDatSetBaseFlag(TGRid *objID, IGRint a_flag)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRlong flag = a_flag;

  // Arg Check
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;

  sts = om$send(
    msg = message VDatBase.setFlag(flag),
    senderid = NULL_OBJID,
    targetid = objID->objid,
    targetos = objID->osnum
  );
  if (!(sts & 1)) goto wrapup;

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Wrapper to set flag bit
 */
IGRstat VDatSetBaseFlagBit(TGRid *objID, IGRint a_flag)
{
  IGRstat retFlag = 0;
  IGRint  flag = a_flag;

  // Arg Check
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;

  VDatGetBaseFlag(objID,&flag);
  flag |= a_flag;
  VDatSetBaseFlag(objID, flag);

  retFlag = 1;

wrapup:
  return retFlag;
}
/* -------------------------------------------------
 * Wrapper to clear flag bit
 */
IGRstat VDatClrBaseFlagBit(TGRid *objID, IGRint a_flag)
{
  IGRstat retFlag = 0;
  IGRint  flag = a_flag;

  // Arg Check
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;

  VDatGetBaseFlag(objID,&flag);
  flag &= !a_flag;
  VDatSetBaseFlag(objID, flag);

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Wrapper to check for given flag bit
 * Only checks bit's not the whole thing
 */
IGRstat VDatIsBaseFlag(TGRid *objID, IGRint a_flag)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRlong l_flag = 0;

  // Arg Check
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;

  sts = om$send(
    msg = message VDatBase.getFlag(&l_flag),
    senderid = NULL_OBJID,
    targetid = objID->objid,
    targetos = objID->osnum
  );
  if (!(sts & 1)) goto wrapup;

  // Check the bits
  l_flag &= a_flag;  
  if (a_flag == l_flag) retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Wrapper to extract name
 */
IGRstat VDatGetBaseName(TGRid *objID, IGRchar *name)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRint  type;


  // Arg Check
  *name = 0;
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;

  // Overide a few virtual classes here
  type = 0;
  VDatGetBaseType(objID,&type);
  switch(type) {

  case VDAT_CLASSI_LEAF: {
    VDatGetLeafName(objID,name);
    retFlag = 1;
    goto wrapup;
  }
  }

  sts = om$send(
    msg = message VDatBase.getName(name),
    senderid = NULL_OBJID,
    targetid = objID->objid,
    targetos = objID->osnum
  );
  if (!(sts & 1)) goto wrapup;

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Wrapper to extract misc
 */
IGRstat VDatGetBaseMisc(TGRid *objID, IGRchar *misc)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  // Arg Check
  if (misc == NULL) goto wrapup;
  *misc = 0;
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;


  // Get it
  sts = om$send(
    msg = message VDatBase.getMisc(misc),
    senderid = NULL_OBJID,
    targetid = objID->objid,
    targetos = objID->osnum
  );
  if (!(sts & 1)) goto wrapup;

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Wrapper to extract name for displaying on a form
 * Don't want to mess with getbase name since that is
 * also used for searching
 */
IGRstat VDatGetDisplayName(TGRid *objID, IGRchar *name)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRint  type;

  IGRchar baseName[128];
  IGRchar baseType[128];

  IGRint  list_ind;
  IGRint  pplRET;
  TGRid   pplID;
  TGRid   setID;
  IGRchar setType[128];
  IGRchar setName[128];

  IGRchar namex[128];
  IGRchar pcmk [128];
  TGRobj_env pieceOE;
  
  // TVDatFld fld;
  
  // Arg Check
  if (name == NULL) goto wrapup;
  *name = 0;
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;

  // Overide a few virtual classes here
  type = 0;
  VDatGetBaseType(objID,&type);

  VDatGetSet(objID, &setID);
  VDatRDBGetSetType(&setID, setType);
  switch(type) {

  case VDAT_CLASSI_LEAF: {
    VDatGetLeafName(objID,namex);

    /* -------------------------------------------
     * 23 Feb 2000, add in piece mark and see what happens
     */
    *pcmk = 0;
    pieceOE.obj_id.objid = NULL_OBJID;
    vdsa$GetStruct(objID = objID,
		   name  = "pcmk",
		   txt   = pcmk);

    if (atoi(pcmk) < 1) {

      // Try getting from piece object
      VDatGetLeafObject(objID, &pieceOE);
      vdsa$GetStruct(objOE = &pieceOE,
		     name = "SA_AST:StagingTree:0:pcmk",
		     txt   = pcmk);
 
    }
    if (atoi(pcmk) > 0) sprintf(name,"%s,%s",pcmk,namex);
    else                strcpy (name,namex);
    
#if 0
    // Tag on piece objid for debugging
    if (pieceOE.obj_id.objid == NULL_OBJID) {
      VDatGetLeafObject(objID, &pieceOE);
    }
    if (pieceOE.obj_id.objid != NULL_OBJID) {
      sprintf(namex," MODEL %d,%d",
	      pieceOE.obj_id.osnum,
	      pieceOE.obj_id.objid);
      strcat(name,namex);
    }
    else strcat(name," MODEL NOT CONNECTED");
#endif

    retFlag = 1;
    goto wrapup;
 			}
 /* The four cases below are added to  to handle production sets' display on the pocket menu form */

  case VDAT_CLASSI_LEAFS: 
			{
			VDatGetSetName(&setID, setName);
			strcat(setType, " ");
			strcat(setType, setName);
			strcpy(name, setType);
			retFlag=1;
			goto wrapup;
			}
  case VDAT_CLASSI_PLATES:
			{
			list_ind = 0;
			VDatGetNameForList(setType, list_ind, name);
			retFlag =1;
			goto wrapup;
			}
  case VDAT_CLASSI_BEAMS:
			{
			list_ind = 1;
			VDatGetNameForList(setType, list_ind, name);
			retFlag =1;
			goto wrapup;
			}
  case VDAT_CLASSI_OTHERS:
			{
			list_ind = 2;
			VDatGetNameForList(setType, list_ind, name);
			retFlag =1;
			goto wrapup;
			}
  }

  sts = om$send(
    msg = message VDatBase.getName(name),
    senderid = NULL_OBJID,
    targetid = objID->objid,
    targetos = objID->osnum
  );
  if (!(sts & 1)) goto wrapup;

  switch(type) {

  case VDAT_CLASSI_TREE:
  case VDAT_CLASSI_NODE: {
    
    VDatRDBGetNodeType(objID,baseType);
    if (*baseType) {
      strcpy(baseName,name);
      sprintf(name,"%s %s",baseType,baseName);
    }
    retFlag = 1;
    goto wrapup;
  }

  } // switch

  retFlag = 1;

wrapup:
  return retFlag;
}


// Gets the name of a particular list from the ppl given the list index

IGRint VDatGetNameForList(IGRchar *setType, IGRint list_ind, IGRchar *name)
{
		TGRid 	pplID;
		IGRint  pplRET;
		IGRint  retFlag;
		
		//Init 
		retFlag = 0;

		vdppl$Load(name = setType, pplID = &pplID);
		if(pplID.objid == NULL_OBJID){
		printf("Could not load %s.e", setType);
		goto wrapup;
		}
		vdppl$SetData(  pplID = &pplID,
				name  = "LIST_IND",
				size  = sizeof(IGRint),
				data  = (IGRchar*)&list_ind);
		vdppl$Run(pplID = &pplID, name = "getListText", ret = &pplRET);
		vdppl$GetData(	pplID = &pplID,
				name  = "LIST_TEXT",
				size  = 128,
				data  = name);
		vdppl$Delete(pplID = &pplID);
			retFlag = 1;
			goto wrapup;
wrapup:
	return retFlag;

}


/* -------------------------------------------------
 * Wrapper to set name
 */
IGRstat VDatSetBaseName(TGRid *objID, IGRchar *name)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  // Arg Check
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;

  sts = om$send(
    msg = message VDatBase.setName(name),
    senderid = NULL_OBJID,
    targetid = objID->objid,
    targetos = objID->osnum
  );
  if (!(sts & 1)) goto wrapup;

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Wrapper to set misc
 */
IGRstat VDatSetBaseMisc(TGRid *objID, IGRchar *misc)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  // Arg Check
  if (misc == NULL) goto wrapup;
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;

  sts = om$send(
    msg = message VDatBase.setMisc(misc),
    senderid = NULL_OBJID,
    targetid = objID->objid,
    targetos = objID->osnum
  );
  if (!(sts & 1)) goto wrapup;

  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------------------
 * Searches children for the type
 */
IGRstat VDatGetChildByType(TGRid *objID, IGRint a_type, TGRid *a_childID)
{
  IGRstat retFlag = 0;
  IGRuint i;
  IGRint  type;
  TGRid   childID;

  // Arg Check
  a_childID->objid = NULL_OBJID;
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;

  for(i = 0; VDatGetChildObject(objID,i,&childID); i++) {

    VDatGetBaseType(&childID,&type);

    if (a_type == type) {
      *a_childID = childID;
      retFlag = 1;
      goto wrapup;
    }
  }

wrapup:
  return retFlag;
}

/* ---------------------------------------------------
 * Searches parent for the type
 */
IGRstat VDatGetParentByType(TGRid *objID, IGRint a_type, TGRid *a_parentID)
{
  IGRstat retFlag = 0;
  IGRuint i;
  IGRint  type;
  TGRid   parentID;

  // Arg Check
  a_parentID->objid = NULL_OBJID;
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;

  for(i = 0; VDatGetParentObject(objID,i,&parentID); i++) {

    VDatGetBaseType(&parentID,&type);
    if (a_type == type) {
      *a_parentID = parentID;
      retFlag = 1;
      goto wrapup;
    }
  }

wrapup:
  return retFlag;
}

/* ------------------------------------------------------
 * Get all the children, Should not be needed
 */
IGRstat VDatGetChildren(TGRid *objID, TVDvlaID *objVLA)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;

  sts = VDahGetChnObjs(objID,VDAT_CHN_TO_CHILDREN,objVLA);
  if (!(sts & 1)) {
    printf("Problem getting children of\n");
    VDbroPrintObj(objID);
    goto wrapup;
  }

  retFlag = 1;

wrapup:
  return retFlag;
}

/* ------------------------------------------------------
 * Get all the parents
 */
IGRstat VDatGetParents(TGRid *objID, TVDvlaID *objVLA)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;

  sts = VDahGetChnObjs(objID,VDAT_CHN_TO_PARENT,objVLA);
  if (!(sts & 1)) {
    printf("Problem getting parents of\n");
    VDbroPrintObj(objID);
    goto wrapup;
  }

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------
 * Sets the parent of an object
 */
IGRstat VDatAddParent(TGRid *childID, TGRid *parentID)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  OM_S_CHANSELECT   parentCHN;
  OM_S_CHANSELECT childrenCHN;

  // Arg Check
  if (( childID == NULL) || ( childID->objid == NULL_OBJID)) goto wrapup;
  if ((parentID == NULL) || (parentID->objid == NULL_OBJID)) goto wrapup;

  // Make channels
  sts = om$make_chanselect(
    channame     = VDAT_CHN_TO_PARENT,
    p_chanselect = &parentCHN
  );
  if (!(sts & 1)) goto wrapup;

  sts = om$make_chanselect(
    channame     = VDAT_CHN_TO_CHILDREN,
    p_chanselect = &childrenCHN
  );
  if (!(sts & 1)) goto wrapup;

  // Connect up
  sts = om$send(
    msg = message Root.connect(
      parentCHN,  OM_K_MAXINT,
      parentID->objid, 
      parentID->osnum,
      childrenCHN,OM_K_MAXINT
    ),
    senderid = NULL_OBJID,
    targetid = childID->objid,
    targetos = childID->osnum
  );
  if (!(sts & 1)) {
    printf("Parent Connection Failed\n");
    goto wrapup;
  }

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------
 * Deletes the parent of an object
 */
IGRstat VDatDelParent(TGRid *childID, TGRid *parentID)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  OM_S_CHANSELECT   parentCHN;
  OM_S_CHANSELECT childrenCHN;

  // Arg Check
  if (( childID == NULL) || ( childID->objid == NULL_OBJID)) goto wrapup;
  if ((parentID == NULL) || (parentID->objid == NULL_OBJID)) goto wrapup;

  // Make channels
  sts = om$make_chanselect(
    channame     = VDAT_CHN_TO_PARENT,
    p_chanselect = &parentCHN
  );
  if (!(sts & 1)) goto wrapup;

  sts = om$make_chanselect(
    channame     = VDAT_CHN_TO_CHILDREN,
    p_chanselect = &childrenCHN
  );
  if (!(sts & 1)) goto wrapup;

  // Connect up
  sts = om$send(
    msg = message Root.disconnect(
      parentCHN,
      parentID->objid, 
      parentID->osnum,
      childrenCHN
    ),
    senderid = NULL_OBJID,
    targetid = childID->objid,
    targetos = childID->osnum
  );
  if (!(sts & 1)) {
    printf("Parent Dis-Connection Failed\n");
    goto wrapup;
  }

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------
 * Deletes all parents of a given type
 */
IGRstat VDatDelParentByType(TGRid *nodeID, IGRint type)
{
  TGRid parentID;

  // Arg Check
  if ((nodeID == NULL) || (nodeID->objid == NULL_OBJID)) goto wrapup;

  while(1) {
    parentID.objid = NULL_OBJID;
    VDatGetParentByType(nodeID,type,&parentID);
    if (parentID.objid == NULL_OBJID) goto wrapup;
    VDatDelParent(nodeID,&parentID);
  }

wrapup:
  return 1;
}

/* -----------------------------------------
 * Deletes all parents
 */
IGRstat VDatDelAllParents(TGRid *nodeID)
{
  IGRstat retFlag = 0;

  TGRid parentID;

  // Arg Check
  if ((nodeID == NULL) || (nodeID->objid == NULL_OBJID)) goto wrapup;

  while(VDatGetParentObject(nodeID,0,&parentID)) {
    VDatDelParent(nodeID,&parentID);
  }
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------
 * Used to connect piece to tree
 * Obsolete
 */
#if 0
IGRstat VDatAddParentToModel(TGRobj_env *pieceOE, TGRid *parentID)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  TGRid     sourceID;

  // Source It
  sts = as$make_source(
    go_grid =  pieceOE->obj_id,
    mod_env = &pieceOE->mod_env,
    as_os   =  parentID->osnum,
    as_grid = &sourceID
  );

  if (!(sts & 1)) {
    printf("Problem makeing source\n");
    goto wrapup;
  }
  // VDbroPrintObj(&pieceOE->obj_id);
  // VDbroPrintObj(&sourceID);

  // Now just connect the source
  sts = VDatAddParent(&sourceID,parentID);
  if(!(sts & 1)) goto wrapup;
  
  retFlag = 1;

wrapup:
  return retFlag;
}
#endif

/* ------------------------------------------------------
 * Gets parent/child of object by index
 */
IGRstat VDatGetChildObject(TGRid *parentID, IGRuint i, TGRid *childID)
{
  return VDahGetChnObject(parentID,VDAT_CHN_TO_CHILDREN,i,childID);
}
IGRstat VDatGetParentObject(TGRid *childID, IGRuint i, TGRid *parentID)
{
  return VDahGetChnObject(childID,VDAT_CHN_TO_PARENT,i,parentID);
}

extern VDclassid OPP_VDatBase_class_id;

/* ------------------------------------------------------
 * Create base object
 */
IGRstat VDatCreateBase(
  IGRchar *name, 
  IGRlong  type, 
  TGRid   *parentID, 
  VDosnum  osnum,
  TGRid   *objID
)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  VDclassid classId = 0;

  // Hi
  __DBGpr_str("VDatCreateBase",name);

  // Null if fail
  objID->objid = NULL_OBJID;

  // If name is an existing class then use it
  sts = om$get_classid(
    classname = name,
    p_classid = &classId
  );
  if (!(sts & 1)) classId = OPP_VDatBase_class_id;
 
  // Decide on osnum
  if (osnum != OM_K_NOT_AN_OS) objID->osnum = osnum;
  else {
    if (parentID != NULL) objID->osnum = parentID->osnum;
    else {
      ex$get_cur_mod(osnum = &objID->osnum);
    }
  }

  // Create object
  om$construct(
    classid =  classId,
    osnum   =  objID->osnum,
    p_objid = &objID->objid
  );
  if (objID->objid == NULL_OBJID) {
    printf("Problem Creating VDatBase object\n");
    goto wrapup;
  }

  // Set name and type
  VDatSetBaseName(objID,name);
  VDatSetBaseType(objID,type);

  // Line to parent
  if (parentID != NULL) {
    sts = VDatAddParent(objID,parentID);
    if (!(sts & 1)) {
      printf("Problem attaching parent\n");
      goto wrapup;
    }
  }

  // Done
  retFlag = 1;

wrapup:

  if (!(retFlag & 1)) {
    __DBGpr_str("VDatCreateBase","FAILED!");
  }

  return retFlag;
}

/* ------------------------------------------------
 * Completely delete a base object and all children
 */
IGRstat VDatDeleteBase(TGRid *objID)
{
  IGRstat retFlag = 0;
  TGRid   childID;
  IGRint  type;

  // Arg Check
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;
  
  // Ignore non VDatBase objects
  VDatGetBaseType(objID,&type);
  if (type == 0) {
    retFlag = 1;
    goto wrapup;
  }

  VDatDelAllParents(objID);

  // Leaf is special as the piece is not a node
  if (type == VDAT_CLASSI_LEAF) {
    VDatGetChildObject(objID,0,&childID);
    VDatDelParent(&childID,objID);
    goto delete_me;
  }

  // Delete all kids
  while(VDatGetChildObject(objID,0,&childID)) {

    VDatDeleteBase(&childID);

  }

delete_me:

  om$send(
    msg = message Root.delete(0),
    senderid = NULL_OBJID,
    targetid = objID->objid,
    targetos = objID->osnum
  );

  retFlag = 1;
wrapup:
  return 1;
}

end implementation VDatBase;
