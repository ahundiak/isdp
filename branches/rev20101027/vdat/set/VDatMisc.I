/* $Id: VDatMisc.I,v 1.1.1.1 2001/01/04 21:07:43 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/set/VDatMisc.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatMisc.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:43  cvs
 *      Initial import to CVS
 *
# Revision 1.4  1999/02/09  20:54:26  pinnacle
# Replaced: vdat/set/VDatMisc.I for:  by vsrivast for vds
#
# Revision 1.3  1999/01/27  18:50:10  pinnacle
# BySetType
#
# Revision 1.2  1998/09/29  21:15:06  pinnacle
# ah
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.8  1998/04/21  21:01:48  pinnacle
# ah
#
# Revision 1.7  1998/03/02  20:25:12  pinnacle
# AssyTree
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/01/97  ah      creation
 * 01/27/99  ah      BySetType
 ***************************************************************************/

class implementation VDatBase;

#include "VDobj.h"
#include "VDchn.h"
#include "v_dbgmacros.h"

extern VDclassid OPP_ACpretendin_class_id;
extern VDclassid OPP_ACpretend_class_id;


IGRstat VDatSetDefaultAttrs(TGRid *objID)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  struct {
    TVDatFld flds[VDAT_FLD_MAX];
    IGRint   cnt;
    IGRint   i;
    TGRid    id;
  } post,node;

  IGRchar nodeName[128];
  
  // Init
  memset(&post,0,sizeof(post));
  memset(&node,0,sizeof(node)); 
  node.id = *objID;

  // Get list of attributes from table
  VDatRDBGetPost(&node.id, &post.id);
  if (post.id.objid == NULL_OBJID) goto wrapup;
  VDatFldGetAllAttrs(&post.id, post.flds, &post.cnt);

  // Filter any predefined ones
  for(post.i = 0; post.i < post.cnt; post.i++) {

    sts = VDatPOSTIsPostAttr(post.flds[post.i].name);

    if (!(sts & 1)) {
      node.flds[node.i] = post.flds[post.i];
      node.i++;
    }

  }

  VDatGetBaseName(objID,nodeName);
  VDatFldSetTxtByName(node.flds,node.i,"node_name",nodeName);

  VDatFldSetAllAttrs(&node.id,node.flds,node.i);

  retFlag = 1;

wrapup:
  return retFlag;
}

#if 0
IGRstat VDatSetDefaultAttrsX(TGRid *objID)
{
  IGRstat retFlag = 0;

  TVDatFld  flds[VDAT_FLD_MAX];
  TVDatFld *fld;
  TVDatFld  fldx;
  IGRint    fldCnt;
  IGRint    i;

  TGRid    rdbPostID;

  TVDatPDMInfo info;

  IGRint     type;
  TGRobj_env objOE;

  GRobjid    objid;

  IGRchar pieceName[DI_PATH_MAX];
  IGRchar piecePath[DI_PATH_MAX];

  IGRchar unitName[128];
  IGRchar treeName[128];
  IGRchar nodeName[128];
  IGRchar nodePath[128];
  IGRchar nodeType[128];

  IGRchar parentPath[128];
  TGRid   parentID;

  // Xfer default attributes
  VDatRDBGetPost(objID, &rdbPostID);
  if (rdbPostID.objid == NULL_OBJID) goto wrapup;

  VDatFldGetAllAttrs(&rdbPostID, flds, &fldCnt);

  // For leafs, want the model object
  VDatGetBaseType(objID,&type);
  if (type == VDAT_CLASSI_LEAF) {

    VDatGetLeafObject(objID,&objOE);
    if (objOE.obj_id.objid == NULL_OBJID) goto wrapup;
    VDatPOSTGetPDMInfo(objOE.obj_id.osnum,&info);
    objid = objOE.obj_id.objid;
  }
  else {
    VDatPOSTGetPDMInfo(objID->osnum,&info);
    objid = objID->objid;
  }
  VDatGetSetName    (objID,unitName);
  VDatGetBaseName   (objID,nodeName);
  VDatGetTreeName   (objID,treeName);
  VDatRDBGetNodeType(objID,nodeType);

  // Need some parent info
  VDatGetParentNode(objID,&parentID);
  if (parentID.objid == NULL_OBJID) *parentPath = 0;
  {
    VDatFldGetAttrByName(&parentID,"node_path",&fldx);
    strcpy(parentPath,fldx.valueTxt);
  }

  for(i = 0; i < fldCnt; i++) {

    fld = &flds[i];

    if (!strcmp(fld->name,"assembly_cat")) {
      strcpy(fld->valueTxt,info.cat);
    }
    if (!strcmp(fld->name,"assembly_nam")) {
      strcpy(fld->valueTxt,info.part);
    }
    if (!strcmp(fld->name,"assembly_ver")) {
      strcpy(fld->valueTxt,info.rev);
    }
    if (!strcmp(fld->name,"comp_seqno")) {
      fld->valueInt = objid;
    }
    if (!strcmp(fld->name,"set_path")) {
      strcpy(fld->valueTxt,unitName);
    }
     if (!strcmp(fld->name,"tree_path")) {
      strcpy(fld->valueTxt,treeName);
    }
   if (!strcmp(fld->name, "node_name")) {
      strcpy(fld->valueTxt,nodeName);
    }
    if (!strcmp(fld->name,"node_type")) {
      strcpy(fld->valueTxt,nodeType);
    }
    if (!strcmp(fld->name,"pare_path")) {
      strcpy(fld->valueTxt,parentPath);
    }
    
  }

  // Done for nodes
  if (type != VDAT_CLASSI_LEAF) {
    VDatFldSetAllAttrs(objID,flds,fldCnt);

    /* Node path requires everthing else to be set */
    *nodePath = 0;
    VDatGetNodePath(objID,nodePath);
    VDatFldSetTxt(&fldx,"node_path",nodePath);
    VDatFldUpdAllAttrs(objID,&fldx,1);
    retFlag = 1;
    goto wrapup;
  }

  // Repeat for leaf info
  VDatPOSTGetPDMInfo(objID->osnum,&info);

  VDatGetLeafName(objID,pieceName);
  VDatGetLeafPath(objID,piecePath);

  for(i = 0; i < fldCnt; i++) {

    fld = &flds[i];

    if (!strcmp(fld->name,"piece_cat")) {
      strcpy(fld->valueTxt,info.cat);
    }
    if (!strcmp(fld->name,"piece_nam")) {
      strcpy(fld->valueTxt,info.part);
    }
    if (!strcmp(fld->name,"piece_ver")) {
      strcpy(fld->valueTxt,info.rev);
    }
    if (!strcmp(fld->name,"piece_seqno")) {
      fld->valueInt = objID->objid;
    }
    if (!strcmp(fld->name,"leaf_cat")) {
      strcpy(fld->valueTxt,info.cat);
    }
    if (!strcmp(fld->name,"leaf_nam")) {
      strcpy(fld->valueTxt,info.part);
    }
    if (!strcmp(fld->name,"leaf_ver")) {
      strcpy(fld->valueTxt,info.rev);
    }
    if (!strcmp(fld->name,"leaf_seqno")) {
      fld->valueInt = objID->objid;
    }
    if (!strcmp(fld->name,"piece_name")) {
      strcpy(fld->valueTxt,pieceName);
    }
    if (!strcmp(fld->name,"piece_path")) {
      strcpy(fld->valueTxt,piecePath);
    }
    
  }

  // And set
  VDatFldSetAllAttrs(objID,flds,fldCnt);
  retFlag = 1;

wrapup:
  return retFlag;
}
#endif

/* -----------------------------------------
 * Want a list of children on a Plate/Beam object
 * Including those conected via acpretendin
 */
IGRstat VDatGetChildrenVLA(TGRid *objID, TVDvlaID *ids)
{
  IGRstat retFlag = 0;
  IGRint  i,j;

  TGRid     childID;
  TGRid     notifyID;
  TVDvlaID  notifyVLA;
  VDclassid notifyCLASS;

  // Init
  VDvlaID_Construct(&notifyVLA);

  // Start by adding any directly connected
  for(i = 0; VDahGetChnObject(objID,"NDchildren.children",i,&childID); i++) {
    VDvlaID_Append(ids,&childID);
  }

  // Cycle through listener looking for ACpretendins
  VDahGetChnObjs(objID,"GRnotify.notification",&notifyVLA);

  for(i = 0; VDvlaID_GetAt(&notifyVLA, &notifyID, i); i++) {

    notifyCLASS = 0;
    om$get_classid(
      osnum = notifyID.osnum,
      objid = notifyID.objid,
      p_classid = &notifyCLASS
    );
    if (notifyCLASS == OPP_ACpretendin_class_id) {

      // Add it's children
      for(j = 0; VDahGetChnObject(&notifyID,"NDchildren.children",i,&childID); i++) {
        VDvlaID_Append(ids,&childID);
      }

    }

  }

//  VDbroPrintObj(objID);
//  for(i = 0; VDvlaID_GetAt(ids,&childID,i); i++) {
//    VDbroPrintObj(&childID);
//  }

  retFlag = 1;

//wrapup:
  VDvlaID_Delete(&notifyVLA);

  return retFlag;
}

extern VDclassid OPP_VDatLeaf_class_id;

/* -----------------------------------------
 * Want a list of leafs on a Plate/Beam object
 * Including those conected via acpretendin
 */
IGRstat VDatGetObjectLeafsVLA(TGRid *objID, TVDvlaID *ids)
{
  IGRstat retFlag = 0;

  IGRint  i,j;

  TGRid     childID;
  VDclassid childCLASS;

  TGRid     notifyID;
  TVDvlaID  notifyVLA;
  VDclassid notifyCLASS;

  TGRid     ownerID;
  TGRid     leafID;
  
  TGRobj_env	objOE;
  
  SetProc(VDatGetObjectLeafsVLA); Begin
  
  // Init
  VDvlaID_Construct(&notifyVLA);
  
  ASget_as_owner(objID, &ownerID);
  
  if(ownerID.objid!= NULL_OBJID)
  {
    for(i = 0; VDahGetChnObject(&ownerID,"NDchildren.children",i,&childID); i++) 
    {
      __DBGpr_obj( " childID", childID);
      // Check the class_id of child and act accordingly
      childCLASS = 0;
      om$get_classid(
	osnum = childID.osnum,
	objid = childID.objid,
	p_classid = &childCLASS
      );
      if(childCLASS == OPP_ACpretend_class_id)
      {
	for(j = 0; VDahGetChnObject(&childID, "NDchildren.children", j, &leafID) ; j++)
	{	
	  childCLASS = 0;
	  om$get_classid(
	    osnum = leafID.osnum,
	    objid = leafID.objid,
	    p_classid = &childCLASS
	  );
	  if( childCLASS == OPP_VDatLeaf_class_id )
	  {
	    VDatGetLeafObject( &leafID, &objOE );	
	    __DBGpr_obj( " objOE.obj_id", objOE.obj_id);
	    if((objOE.obj_id.objid == objID->objid) && (objOE.obj_id.osnum == objID->osnum))
	    {
	      VDvlaID_Append(ids, &leafID);
	      __DBGpr_obj( " leafID", leafID);
	    }
	  }
	}
      }
      if(childCLASS == OPP_ACpretendin_class_id)
      {
	vdchn$Get(il_objID  = objID,
		  ic_IDX    = VDCHN_IDX_NOTIFICATION,
		  or_vlaID  = &notifyVLA);
	
	for(i = 0; VDvlaID_GetAt(&notifyVLA, &notifyID, i); i++) {
	  
	  notifyCLASS = 0;
	  om$get_classid(
	    osnum = notifyID.osnum,
	    objid = notifyID.objid,
	    p_classid = &notifyCLASS
	  );
	  if (notifyCLASS == OPP_ACpretendin_class_id) {
	    
	    // Add it's children
	    for(j = 0; VDahGetChnObject(&notifyID,"NDchildren.children",j,&childID); j++) {
	      childCLASS = 0;
	      om$get_classid(
		osnum = childID.osnum,
		objid = childID.objid,
		p_classid = &childCLASS
	      );
	      if (childCLASS == OPP_VDatLeaf_class_id) {
		VDvlaID_Append(ids,&childID);
	      }
	    }
	  }
	}
      }
    }
  }
  

  // Start by adding any directly connected
  for(i = 0; VDahGetChnObject(objID,"NDchildren.children",i,&childID); i++) {

    childCLASS = 0;
    om$get_classid(
      osnum = childID.osnum,
      objid = childID.objid,
      p_classid = &childCLASS
    );
    if (childCLASS == OPP_VDatLeaf_class_id) {
      VDvlaID_Append(ids,&childID);
    }
  }

  // Cycle through listener looking for ACpretendins
  vdchn$Get(il_objID  = objID,
            ic_IDX    = VDCHN_IDX_NOTIFICATION,
            or_vlaID  = &notifyVLA);
  
  for(i = 0; VDvlaID_GetAt(&notifyVLA, &notifyID, i); i++) {

    notifyCLASS = 0;
    om$get_classid(
      osnum = notifyID.osnum,
      objid = notifyID.objid,
      p_classid = &notifyCLASS
    );
    if (notifyCLASS == OPP_ACpretendin_class_id) {

      // Add it's children
      for(j = 0; VDahGetChnObject(&notifyID,"NDchildren.children",j,&childID); j++) {
        childCLASS = 0;
        om$get_classid(
          osnum = childID.osnum,
          objid = childID.objid,
          p_classid = &childCLASS
        );
        if (childCLASS == OPP_VDatLeaf_class_id) {
          VDvlaID_Append(ids,&childID);
        }
      }
    }
  }
  retFlag = 1;

//wrapup:
  VDvlaID_Delete(&notifyVLA);
	End

  return retFlag;
}

IGRstat VDatGetObjectLeaf(TGRobj_env *objOE, TGRid *a_setID, TGRid *a_leafID)
{
  IGRstat   retFlag = 0;
  TVDvlaID  leafVLA;

  IGRint i;
  TGRid  setID,leafID;

  // Init
  a_leafID->objid = NULL_OBJID;
  VDvlaID_Construct(&leafVLA);

  // Get the leafs
  VDatGetObjectLeafsVLA(&objOE->obj_id,&leafVLA);
 
  // Test if any leafs are in the set
  for(i = 0; VDvlaID_GetAt(&leafVLA,&leafID,i); i++) {

    VDatGetSet(&leafID,&setID);
    if (
        (setID.objid != NULL_OBJID) &&
        (setID.objid == a_setID->objid) &&
        (setID.osnum == a_setID->osnum)) 
    {
      *a_leafID = leafID;
      retFlag = 1;
      goto wrapup;
    }
  }
  retFlag = 0;

wrapup:
  VDvlaID_Delete(&leafVLA);
  return retFlag;
}

IGRstat VDatGetObjectLeafForSetType(TGRobj_env *a_objOE, 
				    IGRchar    *a_setType,
				    TGRid      *a_leafID)
{
  IGRstat   retFlag = 0;
  TVDvlaID  leafVLA;

  IGRint  i;
  TGRid   leafID;

  IGRchar setType[80];
  
  // Init
  a_leafID->objid = NULL_OBJID;
  VDvlaID_Construct(&leafVLA);

  // Get the leafs
  VDatGetObjectLeafsVLA(&a_objOE->obj_id,&leafVLA);
 
  // Test if any leafs are in the set
  for(i = 0; VDvlaID_GetAt(&leafVLA,&leafID,i); i++) {

    VDatGetSetType(&leafID,setType);

    if (!strcmp(a_setType,setType)) {
      *a_leafID = leafID;
      retFlag = 1;
      goto wrapup;
    }
  }
  retFlag = 0;

wrapup:
  VDvlaID_Delete(&leafVLA);
  return retFlag;
}

end implementation VDatBase;






