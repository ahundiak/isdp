/* $Id: VDct1Base.I,v 1.8 2001/10/18 20:49:05 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/set/VDct1Base.I
 *
 * Description: Low Level Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Base.I,v $
 *      Revision 1.8  2001/10/18 20:49:05  ahundiak
 *      ah
 *
 *      Revision 1.7  2001/03/12 20:36:35  jdsauby
 *      Cleaned out unnecessary functions from vdct1/set
 *
 *      Revision 1.6  2001/01/23 14:00:05  ahundiak
 *      mixup
 *
 *      Revision 1.4  2001/01/14 16:27:15  art
 *      sp merge
 *
# Revision 1.2  2000/12/08  15:40:48  pinnacle
# ah
#
# Revision 1.1  2000/07/25  18:39:02  pinnacle
# ah
#
# Revision 1.1  2000/04/20  18:41:40  pinnacle
# Created: vds/vdct1/set/VDct1Base.I by pnoel for Service Pack
#
# Revision 1.3  2000/01/11  22:26:02  pinnacle
# ah
#
# Revision 1.1  1999/06/29  18:28:52  pinnacle
# ct
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/28/99  ah      Creation
 * 12/16/99  pn      Update on Prototypes in VDct1.h (up to date)
 * 01/13/01  ah      sp17 merge, dom hooks
 ***************************************************************************/
class implementation Root;

#include "VDct1.h"

#include "VDobj2.h"
#include "VDppl1.h"

#include "VDassert.h"

VDASSERT_FFN("vdct1/set/VDct1Base.I");

extern VDclassid OPP_VDct1Base_class_id;

from VDct1Base import ACload_macro;

/* ----------------------------------------------------------
 * Generic object creator
 */
IGRstat VDct1CreateBaseObject(
  TVDclaType  classType, 
  VDosnum     osnum,
  TGRid      *objID)
{
  VDASSERT_FN("VDct1CreateBaseObject");
  IGRstat retFlag = 0;

  TGRid defnID;

  // Hi
  if (traceFlag) printf(">>> VDct1CreateBaseObject %d\n",classType);

  // Null if fail
  if (objID == NULL) goto wrapup;
  objID->objid = NULL_OBJID;

  if(osnum == OM_K_NOT_AN_OS) ex$get_cur_mod (osnum = &objID->osnum);
  else                        objID->osnum = osnum;
  
  // Create object
  om$construct(classid =  OPP_VDct1Base_class_id,
	       osnum   =  objID->osnum,
	       p_objid = &objID->objid);
  
  if (objID->objid == NULL_OBJID) {
    printf("*** Problem Creating VDct1Base object, osnum %d, class %d\n",
	   objID->osnum,OPP_VDct1Base_class_id);
    
    goto wrapup;
  }
  
  // Set type class type
  vdcla$Set(objID = objID, type = classType);

  // Link macro defination
  vdct1$GetDefn(osnum = objID->osnum, defnID = &defnID);
  om$send(msg = message VDct1Base.ACload_macro(defnID),
          senderid = NULL_OBJID,
          targetid = objID->objid,
          targetos = objID->osnum);
  // Done
  retFlag = 1;
  
wrapup:

  if (traceFlag) printf("<<< VDct1CreateBaseObject %d\n",retFlag);  
  return retFlag;
}

/* ------------------------------------------------
 * Little wrapper to actually send the delete message
 * so VDct1Node.C does not need to be a .I file
 */
IGRstat VDct1DeleteRootObject(TGRid *objID)
{
  om$send(msg = message Root.delete(0),
	  senderid = NULL_OBJID,
	  targetid = objID->objid,
	  targetos = objID->osnum);
  return 1;
}
  


/* ------------------------------------------------
 * Completely delete a base object and all children
 */
IGRstat VDct1DeleteBaseObject(TGRid *objID)
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
    vdct1$GetManager(osnum = objID->osnum,
	 	     mgrID = &mgrID);

    // Disconnect it from the Set
    vdct1$DisConnectMgrChild(mgrID   = &mgrID,
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
  VDct1DeleteRootObject(objID);

  retFlag = 1;
wrapup:
  return retFlag;
}

/* --------------------------------------------------------------------
 * Standard low level data
 */
IGRstar VDct1GetBaseInfo(
  TGRobj_env    *a_objOE,      // I - Object Environment
  TGRid         *a_objID,      // I - Object ID
  IGRchar       *a_name,       // I - Attribute Name
  IGRchar       *a_txt,        // O - Attribute Value
  TVDctBaseInfo *a_rs          // O - Return TVDctBaseInfo Structure
)
{
  VDASSERT_FN("VDct1GetBaseInfo");
  
  IGRstat  retFlag = 0;
  IGRstat  sts;
  
  TVDfld   fld;
  IGRchar *p;

  TVDctBaseInfo rs;
  TGRid  objID;
  TGRid  setID;
  
  // Say hi
  if(traceFlag) {
    printf(">>>> VDct1GetBaseInfo\n");
  }
  memset(&rs,0,sizeof(TVDctBaseInfo));
  
  // Arg check
  if (a_txt) *a_txt = 0;
  if (a_rs) memset(a_rs,0,sizeof(TVDctBaseInfo));
  
  // Object of interest
  VDobjGetID(a_objOE,a_objID,&objID);
  if(objID.objid == NULL_OBJID) goto wrapup;
  
  // Get the base_info attribute
  vdcol$GetAttr(objID    = &objID,
		vla_type = VDCOL_VLA_INT,
		name     = VDCT_BASE_INFO_NAME,
		fld      = &fld );
 
  if (traceFlag | 0) {
    printf("Get Base Info %d,%d '%s'\n",objID.osnum,objID.objid,fld.val.txt);
  }
  
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
  strcpy(rs.nodeName,fld.val.txt);
  strcpy(fld.val.txt,p+1);
  
  // Return any specific data
return_data:

  // Base Name (basically what get's displayed
  if (*rs.nodeType) {

    sprintf(rs.baseName,"%s %s",
	    rs.nodeType,
	    rs.nodeName);
#if 0
    sprintf(rs.baseName,"%s:%s:%s:%s",
	    rs.setType,
	    rs.setName,
	    rs.nodeType,
	    rs.nodeName);
#endif
  }
  
  else {
    sprintf(rs.baseName,"%s %s",
	    rs.setType, 
	    rs.setName);
  }
  
  if (traceFlag | 0) {
    printf("%d,%d SetType '%s', SetName '%s', NodeType '%s', NodeName '%s', BaseName '%s'\n",
	   objID.osnum,
	   objID.objid,
	   rs.setType,
	   rs.setName,
	   rs.nodeType,
	   rs.nodeName,
	   rs.baseName);
  }
  
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

  if (!strcmp(a_name,VDCT_BASE_NAME_NAME)) strcpy(a_txt,rs.baseName);
  
wrapup:
  if(traceFlag) {
    
    printf("<<<< VDct1GetBaseInfo\n");
  }
  
  return retFlag;
  
}

/* ------------------------------------------------------------
 * Encodes the data from the base info structure
 */
IGRstat VDct1SetBaseInfo(TGRobj_env    *a_objOE,
			 TGRid         *a_objID,
			 TVDctBaseInfo *a_rs)
{
  VDASSERT_FN("VDct1SetBaseInfo");
  IGRstat retFlag = 0;
  
  TVDfld  fld;
  
  TGRid objID;
  
  // Say Hi
  if(traceFlag) {
    printf(">>>> VDct1SetBaseInfo\n");
  }
  
  // Make the string
  if (a_rs == NULL) strcpy(fld.val.txt,"");
  else sprintf(fld.val.txt,"%s:%s:%s:%s:%s:",
	       a_rs->setType,
	       a_rs->setTypeRev,
	       a_rs->setName,
	       a_rs->nodeType,
	       a_rs->nodeName);

  if(traceFlag | 0) {
    printf("Set Base Info: %s\n", fld.val.txt);
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
    printf("<<<< VDct1SetBaseAttr\n");
  }
  
  return 1;
  
}
end implementation Root;
















