/* $Id: VDctBase.I,v 1.1.1.1 2001/01/04 21:08:01 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct/set/VDctBase.I
 *
 * Description: Low Level Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDctBase.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:01  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1999/05/30  14:27:54  pinnacle
# ct
#
# Revision 1.1  1999/05/28  19:08:46  pinnacle
# ct
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/28/99  ah      Creation
 ***************************************************************************/

class implementation VDctBase;

#include "VDct.h"
#include "VDppl1.h"

extern VDclassid OPP_VDctBase_class_id;

static int traceFlag;

/* ----------------------------------------------------------
 * Generic object creator
 */
IGRstat VDctCreateBaseObject(
  TVDclaType  classType, 
  VDosnum     osnum,
  TGRid      *objID)
{
  IGRstat retFlag = 0;

  // Hi
  traceFlag = VDdbgGetTraceFlag(41);
  if (traceFlag) printf(">>> VDctCreateBaseObject %d\n",classType);

  // Null if fail
  if (objID == NULL) goto wrapup;
  objID->objid = NULL_OBJID;

  if(osnum == OM_K_NOT_AN_OS) ex$get_cur_mod (osnum = &objID->osnum);
  else                        objID->osnum = osnum;
  
  // Create object
  om$construct(classid =  OPP_VDctBase_class_id,
	       osnum   =  objID->osnum,
	       p_objid = &objID->objid);
  
  if (objID->objid == NULL_OBJID) {
    printf("Problem Creating VDctBase object\n");
    goto wrapup;
  }
  
  // Set type class type
  vdcla$Set(objID = objID, type = classType);
  
  // Done
  retFlag = 1;
  
wrapup:

  if (traceFlag) printf("<<< VDctCreateBaseObject %d\n",retFlag);  
  return retFlag;
}

/* ------------------------------------------------
 * Completely delete a base object and all children
 */
IGRstat VDctDeleteBaseObject(TGRid *objID)
{
  IGRstat     retFlag = 0;
  TGRid       mgrID;
  TVDclaType  type;

  // Arg Check
  if ((objID == NULL) || (objID->objid == NULL_OBJID)) goto wrapup;
 
  // Ignore non VDatBase objects
  vdcla$Get(objID = objID,
	    type  = &type);
  
  if (type == VDCLA_TYPE_NONE) {
    retFlag = 1;
    goto wrapup;
  }

  // VDctDelAllParents(objID);
  // If it is a Set, then disconnect it from the manager and delete it's children
  if(type == VDCT_CLASS_TYPE_SET){
    // Get the manager
    vdct$GetManager(osnum = objID->osnum,
		    mgrID = &mgrID);
    // Disconnect it from the Set
    vdct$DisConnectMgrChild(mgrID   = &mgrID,
			    childID = objID);
    goto delete_me;
  }
  
  /*
  // Leaf is special as the piece is not a node
  if (type == VDCT_CLASS_TYPE_LEAF) {
    VDctGetChildObject(objID,0,&childID);
    VDctDelParent(&childID,objID);
    goto delete_me;
  }

  // Delete all kids
  while(VDctGetChildObject(objID,0,&childID)) {

    VDctDeleteBase(&childID);

  }
  */
delete_me:

  om$send(
    msg = message Root.delete(0),
    senderid = NULL_OBJID,
    targetid = objID->objid,
    targetos = objID->osnum
  );

  retFlag = 1;
wrapup:
  return retFlag;
}

/* --------------------------------------------------------------------
 * Standard low level data
 */
IGRstar VDctGetBaseInfo(
  TGRobj_env    *a_objOE,      // I - Object Environment
  TGRid         *a_objID,      // I - Object ID
  IGRchar       *a_name,       // I - Attribute Name
  IGRchar       *a_txt,        // O - Attribute Value
  TVDctBaseInfo *a_rs          // O - Return TVDctBaseInfo Structure
)
{

  IGRstat  retFlag = 0;
  TVDfld   fld;
  IGRchar *p;

  TVDctBaseInfo rs;
  TGRid  objID;
  
  // Say hi
  traceFlag = VDdbgGetTraceFlag(41);
  if(traceFlag) {
    printf(">>>> VDctGetBaseInfo\n");
  }

  // Arg check
  if (a_txt) *a_txt = 0;
  if (a_rs) memset(a_rs,0,sizeof(TVDctBaseInfo));
  
  // Object of interest
  objID.objid = NULL_OBJID;
  if(a_objOE){
    objID.objid = a_objOE->obj_id.objid;
    objID.osnum = a_objOE->obj_id.osnum;
  }
  if(a_objID){
    objID.objid = a_objID->objid;
    objID.osnum = a_objID->osnum;
  }
  if(objID.objid == NULL_OBJID) goto wrapup;

  // Get the base_info attribute
  vdcol$GetAttr(objID    = &objID,
		vla_type = VDCOL_VLA_INT,
		name     = VDCT_BASE_INFO_NAME,
		fld      = &fld );
 
  // Set Type
  p = strchr(fld.val.txt,':');
  if (p == NULL) goto return_data;
  *p = 0;
  strcpy(rs.setType,fld.val.txt);
  strcpy(fld.val.txt,p+1);
  
  // Set Type Rev
  p = strchr(fld.val.txt,':');
  if (p == NULL) goto return_data;
  *p = 0;
  strcpy(rs.setTypeRev,fld.val.txt);
  strcpy(fld.val.txt,p+1);

  // Set Name
  p = strchr(fld.val.txt,':');
  if (p == NULL) goto return_data;
  *p = 0;
  strcpy(rs.setName,fld.val.txt);
  strcpy(fld.val.txt,p+1);
    
  // Node Type
  p = strchr(fld.val.txt,':');
  if (p == NULL) goto return_data;
  *p = 0;
  strcpy(rs.nodeType,fld.val.txt);
  strcpy(fld.val.txt,p+1);

  // Node Name
  p = strchr(fld.val.txt,':');
  if (p == NULL) goto return_data;
  *p = 0;
  strcpy(rs.nodeType,fld.val.txt);
  strcpy(fld.val.txt,p+1);

  // Return any specific data
return_data:

  // Worked
  retFlag = 1;
  
  // Everything
  if (a_rs) memcpy(a_rs,&rs,sizeof(TVDctBaseInfo));
  
  // Specific
  if (a_name == NULL) goto wrapup;
  if (a_txt  == NULL) goto wrapup;
  
  if (!strcmp(a_name,VDCT_SET_TYPE_NAME))     strcpy(a_txt,rs.setType);
  if (!strcmp(a_name,VDCT_SET_TYPE_REV_NAME)) strcpy(a_txt,rs.setTypeRev);
  if (!strcmp(a_name,VDCT_SET_NAME_NAME))     strcpy(a_txt,rs.setName);

  if (!strcmp(a_name,VDCT_NODE_TYPE_NAME)) strcpy(a_txt,rs.nodeType);
  if (!strcmp(a_name,VDCT_NODE_TYPE_NAME)) strcpy(a_txt,rs.nodeName);
  
wrapup:
  if(traceFlag) {
    
    printf("<<<< VDctGetBaseInfo\n");
  }
  
  return retFlag;
  
}

/* ------------------------------------------------------------
 * Encodes the data from the base info structure
 */
IGRstat VDctSetBaseInfo(TGRobj_env    *a_objOE,
			TGRid         *a_objID,
			TVDctBaseInfo *a_rs)
{
  IGRstat retFlag = 0;
  
  TVDfld  fld;
  
  TGRid objID;
  
  // Say Hi
  traceFlag = VDdbgGetTraceFlag(41);
  if(traceFlag) {
    printf(">>>> VDctSetBaseInfo\n");
  }
  
  // Make the string
  if (a_rs == NULL) strcpy(fld.val.txt,"");
  else sprintf(fld.val.txt,"%s:%s:%s:%s;%s:",
	       a_rs->setType,
	       a_rs->setTypeRev,
	       a_rs->setName,
	       a_rs->nodeName,
	       a_rs->nodeType);

  if(traceFlag) {
    printf("Base Info: %s\n", fld.val.txt);
  }
  
  strcpy(fld.name,VDCT_BASE_INFO_NAME);
  fld.type = VDFLD_TYPE_TXT;
  
  // Get the object
  objID.objid = NULL_OBJID;
  if (a_objOE) objID = a_objOE->obj_id;
  if (a_objID) objID = *a_objID;
  if (objID.objid == NULL_OBJID) goto wrapup;
  
  vdcol$SetAttrs(objID    = &objID,
		 vla_type = VDCOL_VLA_INT,
		 fld      = &fld,
		 cnt      = 1);
  
  retFlag = 1;
  
wrapup:
  if(traceFlag) {  
    printf("<<<< VDctSetBaseAttr\n");
  }
  
  return 1;
  
}

end implementation VDctBase;

















