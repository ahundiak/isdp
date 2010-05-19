/* $Id: VDbtBase2.I,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/imp/VDbtBase2.I
 *
 * Description: Function interface to method's
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDbtBase2.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:57  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1998/04/07  14:33:40  pinnacle
# ah
#
# Revision 1.2  1998/04/02  21:22:22  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/28/98  ah      Creation
 *
 ***************************************************************************/

class implementation VDbtBase;

#include "VDmaster.h"

#include "VDchn.h"
#include "VDbt.h"

/* ------------------------------------------------
 * Get an attribute
 *
 */
IGRstar VDbtGetAttrs(TGRid   *objID,
                     TVDfld  *a_fld,
                     IGRint  *a_cnt,
		     TVDflds *a_flds
		     )
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRint  cnt = 0;
  
  TVDfld *fld = NULL;

  // Arg Check
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;

  if (a_cnt) *a_cnt = 0;
  if (a_fld) fld = a_fld;

  if (a_flds) {
    fld = a_flds->fld;
    a_flds->cnt = 0;
  }

  // Get Them
  sts = om$send(msg = message
		VDbtBase.getAttrs(1,fld,&cnt),
		senderid = NULL_OBJID,
		targetid = objID->objid,
		targetos = objID->osnum);
  if (!(sts & 1)) goto wrapup;

  if (a_cnt) *a_cnt = cnt;
  if (a_flds) a_flds->cnt = cnt;
  
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ------------------------------------------------
 * Get an attribute
 *
 */
IGRstar VDbtGetAttr(TGRid   *objID,
                    IGRint   ind,
		    IGRchar *name,
		    TVDfld  *fld
		    )
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  // Arg Check
  if (fld == NULL) goto wrapup;
  memset(fld,0,sizeof(TVDfld));
  
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;
  
  // Get it
  sts = om$send(msg = message
		VDbtBase.getAttrBy(1,ind,name,fld),
		senderid = NULL_OBJID,
		targetid = objID->objid,
		targetos = objID->osnum);
  if (!(sts & 1)) goto wrapup;
  
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ------------------------------------------------
 * Set a list of attributes for object
 *
 */
IGRstar VDbtSetAttrs(TGRid   *objID,
		     TVDfld  *a_fld,
		     IGRint   a_cnt,
                     TVDflds *a_flds
		     )
{
  IGRstat retFlag = 0;
  IGRstat sts;

  TVDfld *fld = NULL;
  IGRint  cnt = -1;
  
  // Arg check */
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;

  if (a_flds) {
    cnt = a_flds->cnt;
    fld = a_flds->fld;
  }
  if (a_fld) {
    cnt = a_cnt;
    fld = a_fld;
  }

  // Passing through fld == NULL will reset list of attributes
  sts = om$send(msg = message
		VDbtBase.setAttrs(1,fld,cnt),
		senderid = NULL_OBJID,
		targetid = objID->objid,
		targetos = objID->osnum);
  
  if (!(sts & 1)) goto wrapup;
  
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ------------------------------------------------
 * Update a list of attributes for object
 *
 */
IGRstar VDbtUpdAttrs(TGRid   *objID,
		     TVDfld  *a_fld,
		     IGRint   a_cnt,
                     TVDflds *a_flds
		     )
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDfld *fld = NULL;
  IGRint  cnt = -1;

  // Arg check */
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;

  if (a_flds) {
    cnt = a_flds->cnt;
    fld = a_flds->fld;
  }
  if (a_fld) {
    cnt = a_cnt;
    fld = a_fld;
  }

  if (fld == NULL) goto wrapup;
  if (cnt <= 0)    goto wrapup;
  
  // Update it
  sts = om$send(msg = message
		VDbtBase.updAttrs(1,fld,cnt),
		senderid = NULL_OBJID,
		targetid = objID->objid,
		targetos = objID->osnum);
  
  if (!(sts & 1)) goto wrapup;
  
  retFlag = 1;
  
wrapup:
  return retFlag;
}

  
/* ------------------------------------------------
 * Completely delete a base object and all children
 */
IGRstar VDbtDeleteBase(TGRid *objID)
{
  IGRstat retFlag = 0;

  TGRid   parentID;
  TGRid   childID;

  IGRint  type;
  IGRint  flag;
  
  // Arg Check
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;
  
  // Ignore non VDatBase objects
  vdbt$GetBase(objID = objID, type = &type);
  if (type == VDBT_TYPE_NONE) {
    retFlag = 1;
    goto wrapup;
  }

  // Disconnect any parents
  flag = 1;
  while(flag) {    
    vdbt$GetObj(objID = objID, ind = 0, parentID = &parentID);
    if (parentID.objid == NULL_OBJID) flag = 0;
    else {
      vdbt$DisConnect(objID = objID, parentID = &parentID);
    }
  }
  
  // Tell each VDatBase child to delete itself
  flag = 1;
  while(flag) {

    vdbt$GetObj(objID = objID, ind = 0, childID = &childID);
    if (childID.objid == NULL_OBJID) flag = 0;

    else {

      vdbt$GetBase(objID = &childID, type = &type);

      if (type == VDBT_TYPE_NONE) {

	// Disconnect from a model object
	vdbt$DisConnect(objID = &childID, parentID = objID);
	
      }
      else {

	VDbtDeleteBase(&childID);

      }
    }
    
  }
  
  // The final delete
  om$send(
    msg = message NDnode.NDdelete(NULL),
    senderid = NULL_OBJID,
    targetid = objID->objid,
    targetos = objID->osnum
  );
  /*
  om$send(
    msg = message Root.delete(0),
    senderid = NULL_OBJID,
    targetid = objID->objid,
    targetos = objID->osnum
  );
  */
  retFlag = 1;

wrapup:
  return 1;
}

/* --------------------------------------------
 * Gets object on parent or child channel
 */
IGRstar VDbtGetObj(TGRid *objID,
		   IGRint type,
		   IGRint ind,
		   TGRid *parentID,
		   TGRid *childID
		   )
{
  IGRstat retFlag = 0;

  IGRint  chnIDX  = VDCHN_IDX_NONE;
  TGRid   chnID;
  IGRint  chnType;
  
  IGRint  i;
  
  // Arg Check
  if (parentID != NULL) {
    parentID->objid = NULL_OBJID;
    chnIDX = VDCHN_IDX_CHILD;
  }
  if ( childID != NULL) {
    childID->objid  = NULL_OBJID;
    chnIDX = VDCHN_IDX_PARENT;
  }
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;
  if (chnIDX == VDCHN_IDX_NONE) goto wrapup;
  
  // Looking for a particular object?
  if (type != VDBT_TYPE_NONE) {
    for(i = 0; 
	vdchn$Get(il_objID=objID, ic_IDX=chnIDX, ir_objIDX=i, or_objID=&chnID);
	i++) {

      vdbt$GetBase(objID = &chnID, type = &chnType);
      
      if (type == chnType) {
	if (childID)  *childID  = chnID;
	if (parentID) *parentID = chnID;
	retFlag = 1;
	goto wrapup;
      }
    }
  }
  
  // Looking for nth object
  if (ind >= 0) {
    vdchn$Get(il_objID=objID, ic_IDX=chnIDX, ir_objIDX=ind, or_objID=&chnID);
    if (chnID.objid == NULL_OBJID) goto wrapup;
    if (childID)  *childID  = chnID;
    if (parentID) *parentID = chnID;
    retFlag = 1;
    goto wrapup;
  }
  
wrapup:
  return retFlag;
}

/* -----------------------------------------
 * Disconnect a parent
 */
#argsused
IGRstar VDbtDisConnect(TGRid *objID, 
		       TGRid *parentID,
		       TGRid *listenerID)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  // Arg Check
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;
  
  // DisConnect parent
  if ((parentID != NULL) && (parentID->objid != NULL_OBJID)) {
        
    sts = om$send(msg = message
		  NDnode.NDdisconnect(1,objID),
		  senderid = NULL_OBJID,
		  targetid = parentID->objid,
		  targetos = parentID->osnum);
    
    if (!(sts & 1)) goto wrapup;
    retFlag = 1;
    goto wrapup;
  }
  
  // Disconnect listener

wrapup:
  if (retFlag != 1) {
    printf("Problem DisConnecting\n");
  }
  return retFlag;
}


/* -----------------------------------------
 * Sets the parent of an object
 * The term "parent" is in the context of an assembly tree
 * Actually gets conntected using the "child" channel
 * Depends on your point of view
 */
IGRstar VDbtConnect(TGRid *objID, 
		    TGRid *parentID,
		    TGRid *listenerID)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  // Arg Check
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;
  
  // Connect to parent
  if ((parentID != NULL) && (parentID->objid != NULL_OBJID)) {
    
    // This arg gets ignored
    TGRid originalID;
    originalID.objid = NULL_OBJID;
    
    sts = om$send(msg = message
		  NDnode.NDconnect(1,objID,originalID,ND_ADD),
		  senderid = NULL_OBJID,
		  targetid = parentID->objid,
		  targetos = parentID->osnum);
    
    if (!(sts & 1)) goto wrapup;
    retFlag = 1;
    goto wrapup;
  }

  // Connect to parent
  if ((listenerID != NULL) && (listenerID->objid != NULL_OBJID)) {
    
    OM_S_CHANSELECT *to_notifyCHN = NULL;
    IGRboolean       tagged = FALSE;
    IGRlong          msg;
    IGRint           index = OM_K_MAXINT;
    
    // Need the channel
    vdchn$Get(ic_IDX = VDCHN_IDX_BT_TO_NOTIFY, oc_SEL = &to_notifyCHN);
    if (to_notifyCHN == NULL) goto wrapup;
    
    // Connect it
    sts = om$send(msg = message
		  GRnotify.GRntfyconn(&msg,
				      listenerID,
				      to_notifyCHN,
				      &index,
				      &tagged,NULL),
		  senderid = NULL_OBJID,
		  targetid = objID->objid,
		  targetos = objID->osnum);

    if (!(sts & 1)) goto wrapup;
    retFlag = 1;
    goto wrapup;
  }

#if 0    
method GRntfyconn(IGRlong *msg; 
                  struct GRid *listeners_id; 
                  OM_S_CHANSELECT *listeners_chan; 
                  IGRint *listeners_index;
                  IGRboolean *make_tagged_connect; 
                  OMuword *tagged_os)
  
  // Arg Check
  if ((childID) && (childID->objid != NULL_OBJID)) {
    oneID = *childID;
    vdchn$Get(ic_IDX = VDCHN_IDX_PARENT, oc_SEL = &oneCHN);
  }
  if ((parentID) && (parentID->objid != NULL_OBJID)) {
    twoID = *parentID;
    vdchn$Get(ic_IDX = VDCHN_IDX_CHILD, oc_SEL = &twoCHN);
  }
  if ((notifyID) && (notifyID->objid != NULL_OBJID)) {
    oneID = *notifyID;
    vdchn$Get(ic_IDX = VDCHN_IDX_BT_TO_NOTIFY, oc_SEL = &oneCHN);
  }
  if ((listenerID) && (listenerID->objid != NULL_OBJID)) {
    twoID = *listenerID;
    vdchn$Get(ic_IDX = VDCHN_IDX_NOTIFICATION, oc_SEL = &twoCHN);
  }
  if ((oneCHN == NULL) || (twoCHN == NULL)) {
    goto wrapup;
  }
  
  // Connect up
  sts = om$send(msg = message 
		Root.connect(
			     *twoCHN,OM_K_MAXINT,
			     twoID.objid, 
			     twoID.osnum,
			     *oneCHN,OM_K_MAXINT
			     ),
		senderid = NULL_OBJID,
		targetid = oneID.objid,
		targetos = oneID.osnum
  );
  if (!(sts & 1)) {
    goto wrapup;
  }

  retFlag = 1;
#endif

wrapup:
  if (retFlag != 1) {
    printf("Problem Connecting\n");
  }
  return retFlag;
}

/* ------------------------------------------------------
 * Create base object
 */
IGRstar VDbtCreateBase
(
 VDosnum  a_osnum,
 IGRchar *a_className, 
 IGRlong  a_type, 
 IGRlong  a_flag,
 IGRchar *a_name,
 IGRchar *a_desc,
 TVDfld  *a_fld,
 TGRid   *a_parentID, 
 TGRid   *a_objID
)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRchar   className[128];

  TVDfld    fld;
  
  // Null if fail
  if (a_objID == NULL) goto wrapup;
  a_objID->objid = NULL_OBJID;

  // Use VDbtBase by default
  if (a_className == NULL) strcpy(className,"VDbtBase");
  else                     strcpy(className,a_className);
  
  // Decide on osnum
  //ex$get_cur_mod(osnum = &objID->osnum);
  if (a_parentID != NULL) a_objID->osnum = a_parentID->osnum;
  else                    a_objID->osnum = a_osnum;
  
  // Create object
  om$construct(
    classname = className,
    osnum     =  a_objID->osnum,
    p_objid   = &a_objID->objid
  );
  if (a_objID->objid == NULL_OBJID) {
    printf("Problem Creating %s object\n",className);
    goto wrapup;
  }

  if (a_fld) fld = *a_fld;
  else {
    memset(&fld,0,sizeof(fld));
    fld.type = a_type;
    fld.flag = a_flag;
    if (a_name) strcpy(fld.name,a_name);
    if (a_desc) strcpy(fld.val.txt,a_desc);
  }
  vdbt$SetBase(objID = a_objID, fld = &fld);
  
  // Line to parent
  if (a_parentID != NULL) {
    sts = vdbt$Connect(objID = a_objID, parentID = a_parentID);
    if (!(sts & 1)) goto wrapup;
  }

  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------------
 * Gets Base Information
 */
IGRstar VDbtGetBase(TGRobj_env *a_baseOE, 
                    TGRid      *a_baseID,
                    IGRint     *a_type,
                    IGRint     *a_flag,
                    IGRchar    *a_name,
                    TVDfld     *a_fld)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  TGRid   baseID;
  IGRlong type = 0;
  IGRlong flag = 0;

  // Arg Check
  if (a_type) *a_type = 0;
  if (a_flag) *a_flag = 0;
  if (a_name) *a_name = 0;
  if (a_fld)   memset(a_fld,0,sizeof(TVDfld));

  // Get the id
  baseID.objid = NULL_OBJID;
  if (a_baseOE) baseID =  a_baseOE->obj_id;
  if (a_baseID) baseID = *a_baseID;
  if (baseID.objid == NULL_OBJID) goto wrapup;

  // Check for type
  if (a_type) {

    sts = om$send(
      msg = message VDbtBase.getType(&type),
      senderid = NULL_OBJID,
      targetid = baseID.objid,
      targetos = baseID.osnum
    );
    if (!(sts & 1)) goto wrapup;
    *a_type = type;
  }

  // Check for flag
  if (a_flag) {

    sts = om$send(
      msg = message VDbtBase.getFlag(&flag),
      senderid = NULL_OBJID,
      targetid = baseID.objid,
      targetos = baseID.osnum
    );
    if (!(sts & 1)) goto wrapup;
    *a_flag = flag;
  }

  // Check for name
  if (a_name) {

    sts = om$send(
      msg = message VDbtBase.getName(a_name),
      senderid = NULL_OBJID,
      targetid = baseID.objid,
      targetos = baseID.osnum
    );
    if (!(sts & 1)) goto wrapup;
  }

  // Check for internal field
  if (a_fld) {

    sts = om$send(
      msg = message VDbtBase.getAttr(a_fld),
      senderid = NULL_OBJID,
      targetid = baseID.objid,
      targetos = baseID.osnum
    );
    if (!(sts & 1)) goto wrapup;
  }

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Set Base Information
 */
IGRstar VDbtSetBase(TGRobj_env *a_baseOE, 
                    TGRid      *a_baseID,
                    IGRint     *a_type,
                    IGRint     *a_flag,
                    IGRchar    *a_name,
                    TVDfld     *a_fld)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  TGRid   baseID;
  IGRlong type = 0;
  IGRlong flag = 0;

  // Get the id
  baseID.objid = NULL_OBJID;
  if (a_baseOE) baseID =  a_baseOE->obj_id;
  if (a_baseID) baseID = *a_baseID;
  if (baseID.objid == NULL_OBJID) goto wrapup;

  // Check for type
  if (a_type) {

    type = *a_type;
    sts = om$send(
      msg = message VDbtBase.setType(type),
      senderid = NULL_OBJID,
      targetid = baseID.objid,
      targetos = baseID.osnum
    );
    if (!(sts & 1)) goto wrapup;
  }

  // Check for flag
  if (a_flag) {

    flag = *a_flag;
    sts = om$send(
      msg = message VDbtBase.setFlag(flag),
      senderid = NULL_OBJID,
      targetid = baseID.objid,
      targetos = baseID.osnum
    );
    if (!(sts & 1)) goto wrapup;
  }

  // Check for name
  if (a_name) {

    sts = om$send(
      msg = message VDbtBase.setName(a_name),
      senderid = NULL_OBJID,
      targetid = baseID.objid,
      targetos = baseID.osnum
    );
    if (!(sts & 1)) goto wrapup;
  }

  // Check for internal field
  if (a_fld) {
    sts = om$send(
      msg = message VDbtBase.setAttr(a_fld),
      senderid = NULL_OBJID,
      targetid = baseID.objid,
      targetos = baseID.osnum
    );
    if (!(sts & 1)) goto wrapup;
  }

  retFlag = 1;

wrapup:
  return retFlag;
}

#if 0

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
#endif

end implementation VDbtBase;
