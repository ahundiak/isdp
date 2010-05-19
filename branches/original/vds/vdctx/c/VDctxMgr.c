/* $Id: VDctxMgr.c,v 1.17 2001/11/09 14:44:34 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdctx/c/VDctxMgr.c
 *
 * Description: Context Classes
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDctxMgr.c,v $
 *      Revision 1.17  2001/11/09 14:44:34  ahundiak
 *      ah
 *
 *      Revision 1.16  2001/10/19 18:21:34  ahundiak
 *      ah
 *
 *      Revision 1.15  2001/10/18 15:31:02  ahundiak
 *      ah
 *
 *      Revision 1.14  2001/08/24 20:00:01  ahundiak
 *      ah
 *
 *      Revision 1.13  2001/05/22 15:48:22  ahundiak
 *      ah
 *
 *      Revision 1.12  2001/05/02 15:33:19  ahundiak
 *      ah
 *
 *      Revision 1.11  2001/03/13 00:17:58  ahundiak
 *      ah
 *
 *      Revision 1.10  2001/03/11 18:35:47  ahundiak
 *      VDctxInit.c
 *
 *      Revision 1.9  2001/03/07 16:24:52  ahundiak
 *      ah
 *
 *      Revision 1.8  2001/02/26 15:46:10  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.7  2001/02/22 23:52:32  ahundiak
 *      *** empty log message ***
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/12/00  ah      Creation
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDctxPrivate.h"
#include "VDctx.h"
#include "VDobj2.h"
#include "VDos.h"

#include "glib.h"
#include "xdom.h"

VDASSERT_FFN("vdctx/c/VDctxMgr.c");

/* -----------------------------------------------
 * Returns a class pointer for a node
 */
TVDctxCP *VDctxGetNodeCP(TGRid *nodeID)
{
  VDASSERT_FN("VDctxGetNodeCP");
  IGRstat sts;
  
  TVDctxCP *cp = NULL;
  
  VDclassid classId;

  // Arg check
  VDASSERTW(nodeID && nodeID->objid != NULL_OBJID);
  
  // old Dom object
  if (nodeID->osnum == 9000) {
    printf("*** %s called with old Dom object\n");
    goto wrapup;
  }

  // old Cdom Object
  if (nodeID->osnum == 9090) {
    printf("*** %s called with old cDom object\n");
    goto wrapup;
  }
  
  // Xdom Object
  sts = xdom_nodeid_is_node(nodeID);
  if (sts & 1) {
    cp = VDctxGetNthCP(VDCTX_CP_XDOM);
    goto wrapup;
  }
  
  // Get the class
  sts = VDomGetClassIdForID(nodeID,&classId);
  VDASSERTW(sts & 1);

  // VDct1Base object
  sts = VDomIsAncestryValid(classId,"VDct1Base");
  if (sts == 1) {
    cp = VDctxGetNthCP(VDCTX_CP_CT1);
    goto wrapup;
  }

  // VDatBase object
  sts = VDomIsAncestryValid(classId,"VDatBase");
  if (sts == 1) {
    cp = VDctxGetNthCP(VDCTX_CP_AT);
    goto wrapup;
  }
  
  // Regular om object object
  sts = VDomIsAncestryValid(classId,"ACncpx");
  if (sts == 1) {
    cp = VDctxGetNthCP(VDCTX_CP_OM);
    goto wrapup;
  }

  // VDctBase object (old tree manager object)
  sts = VDomIsAncestryValid(classId,"VDctBase");
  if (sts == 1) {
    cp = VDctxGetNthCP(VDCTX_CP_CT1);
    goto wrapup;
  }

    
  // Done
wrapup:
  return cp;
}

/* -----------------------------------------------
 * Get text attribute
 */
IGRstat VDctxGetTxtAtrCP(TVDctxCP  *cp, 
			 TGRid     *nodeID, 
			 TGRmd_env *env, 
			 IGRchar   *name,
			 IGRint     flag,
			 IGRchar   *value)
{
  VDASSERT_FN("VDctxGetTxtAtrCP");
  IGRstat retFlag = 0;
  
  // Arg checks
  VDASSERTW(value);
  *value = 0;
  VDASSERTW(name && *name);
  
  // Get the class pointer
  if (cp == NULL) cp = VDctxGetNodeCP(nodeID);
  VDASSERTW(cp && cp->getTxtAtr);

  // Doit
  retFlag = cp->getTxtAtr(nodeID,env,name,flag,value);
  
  // Done
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Get text attribute pointer
 * Use this for long attributes
 * Calling routine must free
 */
IGRstat VDctxGetTxtAtrPtrCP(TVDctxCP  *cp, 
			    TGRid     *nodeID, 
			    TGRmd_env *env, 
			    IGRchar   *name,
			    IGRint     flag,
			    IGRchar  **value)
{
  VDASSERT_FN("VDctxGetTxtAtrPtrCP");
  IGRstat retFlag = 0;
  
  // Arg checks
  VDASSERTW(value); *value = NULL;
  VDASSERTW(name && *name);
  
  // Get the class pointer
  if (cp == NULL) cp = VDctxGetNodeCP(nodeID);
  VDASSERTW(cp && cp->getTxtAtrPtr);

  // Doit
  retFlag = cp->getTxtAtrPtr(nodeID,env,name,flag,value);
  
  // Done
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Get binary data pointer
 */
IGRstat VDctxGetBinAtrCP(TVDctxCP  *cp, 
			 TGRid     *nodeID, 
			 TGRmd_env *env, 
			 IGRchar   *name,
			 IGRint     flag,
			 void     **binData)
{
  VDASSERT_FN("VDctxGetBinAtrCP");
  IGRstat retFlag = 0;
  
  // Arg checks
  VDASSERTW(binData); *binData = NULL;
  VDASSERTW(name && *name);
  
  // Get the class pointer
  if (cp == NULL) cp = VDctxGetNodeCP(nodeID);
  VDASSERTW(cp && cp->getBinAtr);

  // Doit
  retFlag = cp->getBinAtr(nodeID,env,name,flag,binData);
  
  // Done
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Set text attribute
 * Need to add a clean routines as control code are still
 * slipping in
 *
 * Take the cance that no static string have control code
 */
IGRstat VDctxSetTxtAtrCP(TVDctxCP  *cp, 
			 TGRid     *nodeID, 
			 TGRmd_env *env, 
			 IGRchar   *name,
			 IGRint     flag,
			 IGRchar   *value)
{
  VDASSERT_FN("VDctxSetTxtAtrCP");
  IGRstat retFlag = 0;
  
  IGRchar *p;
  
  // Arg checks
  VDASSERTW(value);
  VDASSERTW(name && *name);
  
  // Get the class pointer
  if (cp == NULL) cp = VDctxGetNodeCP(nodeID);
  VDASSERTW(cp && cp->setTxtAtr);

  /* ---------------------------------------------
   * Until some upstream code gets fixed
   * Gaurd against control codes
   */
  for(p = value; *p; p++) {
    if (*p < ' ') {
      if (*p != '\n') *p = ' ';
    }
  }
 
  // Doit
  retFlag = cp->setTxtAtr(nodeID,env,name,flag,value);
  
  // Done
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Set binary attribute and optional free routine
 */
IGRstat VDctxSetBinAtrCP(TVDctxCP  *cp, 
			 TGRid     *nodeID, 
			 TGRmd_env *env, 
			 IGRchar   *name,
			 IGRint     flag,
			 void      *binData,
			 void (*binFree)(void *data))
{
  VDASSERT_FN("VDctxSetBinAtrCP");
  IGRstat retFlag = 0;
  
  IGRchar *p;
  
  // Arg checks;
  VDASSERTW(name && *name);
  
  // Get the class pointer
  if (cp == NULL) cp = VDctxGetNodeCP(nodeID);
  VDASSERTW(cp && cp->setBinAtr);
 
  // Doit
  retFlag = cp->setBinAtr(nodeID,env,name,flag,binData,binFree);
  
  // Done
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Set integer attribute
 */
IGRstat VDctxSetIntAtrCP(TVDctxCP  *cp, 
			 TGRid     *nodeID, 
			 TGRmd_env *env, 
			 IGRchar   *name,
			 IGRint     flag,
			 IGRint     value)
{
  VDASSERT_FN("VDctxSetIntAtrCP");
  IGRstat retFlag = 0;
  IGRchab buf;
  
  // Arg checks
  VDASSERTW(name && *name);
  
  // Get the class pointer
  if (cp == NULL) cp = VDctxGetNodeCP(nodeID);
  VDASSERTW(cp && cp->setTxtAtr);

  // Convert to text
  sprintf(buf,"%d",value);
  
  // Doit
  retFlag = cp->setTxtAtr(nodeID,env,name,flag,buf);
  
  // Done
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Set double attribute
 */
IGRstat VDctxSetDblAtrCP(TVDctxCP  *cp, 
			 TGRid     *nodeID, 
			 TGRmd_env *env, 
			 IGRchar   *name,
			 IGRint     flag,
			 IGRdouble  value)
{
  VDASSERT_FN("VDctxSetDblAtrCP");
  IGRstat retFlag = 0;
  IGRchab buf;
  IGRchar *p;
  
  // Arg checks
  VDASSERTW(name && *name);
  
  // Get the class pointer
  if (cp == NULL) cp = VDctxGetNodeCP(nodeID);
  VDASSERTW(cp && cp->setTxtAtr);

  // Convert to text
  VDcnvDblToTxt(value,buf);
  
  // Doit
  retFlag = cp->setTxtAtr(nodeID,env,name,flag,buf);
  
  // Done
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Get double attribute
 */
IGRstat VDctxGetDblAtrCP(TVDctxCP  *cp, 
			 TGRid     *nodeID, 
			 TGRmd_env *env, 
			 IGRchar   *name, 
			 IGRint     flag,
			 IGRdouble *value)
{
  VDASSERT_FN("VDctxGetDblAtrCP");
  IGRstat retFlag = 0;
  
  // Arg checks
  VDASSERTW(value);
  *value = 0.0;
  VDASSERTW(name && *name);
  
  // Get the class pointer
  if (cp == NULL) cp = VDctxGetNodeCP(nodeID);
  VDASSERTW(cp && cp->getDblAtr);

  // Doit
  retFlag = cp->getDblAtr(nodeID,env,name,flag,value);
  
  // Done
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Get fld attribute
 */
IGRstat VDctxGetFldAtrCP(TVDctxCP  *cp, 
			 TGRid     *nodeID, 
			 TGRmd_env *env, 
			 IGRchar   *name, 
			 IGRint     flag,
			 TVDfld    *fld)
{
  VDASSERT_FN("VDctxGetFldAtrCP");
  IGRstat retFlag = 0;
  
  // Arg checks
  VDASSERTW(fld);
  memset(fld,0,sizeof(TVDfld));
  VDASSERTW(name && *name);
  
  // Get the class pointer
  if (cp == NULL) cp = VDctxGetNodeCP(nodeID);
  VDASSERTW(cp && cp->getFldAtr);

  // Doit
  retFlag = cp->getFldAtr(nodeID,env,name,flag,fld);
  
  // Done
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Get fld attributes
 * Null for fld is ok to get count
 */
void VDctxGetFldAtrsCP(TVDctxCP  *cp, 
		       TGRid     *nodeID, 
		       TGRmd_env *env, 
		       IGRint     flag,
		       IGRint    *cnt,
		       TVDfld    *fld)
{
  VDASSERT_FN("VDctxGetFldAtrsCP");
  
  // Arg checks
  VDASSERTW(cnt); *cnt = 0;
  
  // Get the class pointer
  if (cp == NULL) cp = VDctxGetNodeCP(nodeID);
  VDASSERTW(cp && cp->getFldAtrs);

  // Doit
  cp->getFldAtrs(nodeID,env,flag,cnt,fld);
  
  // Done
wrapup:
  return;
}

/* -----------------------------------------------
 * Get base information
 */
IGRstat VDctxGetBaseInfoCP(TVDctxCP  *cp, 
			   TGRid     *nodeID,  
			   TVDctxBaseInfo *baseInfo)
{
  VDASSERT_FN("VDctxGetBaseInfoCP");
  IGRstat retFlag = 0;
  
  // Arg checks
  VDASSERTW(baseInfo);
  memset(baseInfo,0,sizeof(TVDctxBaseInfo));
  
  // Get the class pointer
  if (cp == NULL) cp = VDctxGetNodeCP(nodeID);
  if (cp == NULL) {
    printf("*** No GetBaseInfo CP For %d,%d\n", nodeID->osnum,nodeID->objid);
    goto wrapup;
  }
  VDASSERTW(cp && cp->getBaseInfo);

  // Doit
  retFlag = cp->getBaseInfo(nodeID,baseInfo);

  // Until set stuff goes away
  if (*baseInfo->treeType == 0) strcpy(baseInfo->treeType,baseInfo->setType);
  if (*baseInfo->treeTRev == 0) strcpy(baseInfo->treeTRev,baseInfo->setTypeRev);
  if (*baseInfo->treeName == 0) strcpy(baseInfo->treeName,baseInfo->setName);
  
  // Done
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Get base information
 */
IGRstat VDctxSetBaseInfoCP(TVDctxCP       *cp, 
			   TGRid          *nodeID,  
			   TVDctxBaseInfo *baseInfo)
{
  VDASSERT_FN("VDctxSetBaseInfoCP");
  IGRstat retFlag = 0;
  IGRstat sts;

  // Validate baseInfo
  sts = VDctxValidateBaseInfo(1,baseInfo);
  VDASSERTW(sts == 1);
  
  // Get the class pointer
  if (cp == NULL) cp = VDctxGetNodeCP(nodeID);
  VDASSERTW(cp && cp->setBaseInfo);

  // Doit
  retFlag = cp->setBaseInfo(nodeID,baseInfo);

  // Done
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Get the nth tree child
 */
IGRstat VDctxGetNthTreeChildCP(TVDctxCP *cp, TGRid *nodeID, IGRint nth, TGRid *childID)
{
  VDASSERT_FN("VDctxGetNthTreeChildCP");
  IGRstat retFlag = 0;
  
  // Arg checks
  VDASSERTW(childID);
  childID->objid = NULL_OBJID;
  VDASSERTW(nth >= 0);
  
  // Get the class pointer
  if (cp == NULL) cp = VDctxGetNodeCP(nodeID);
  if (cp == NULL) {
    printf("*** No GetNthTreeChild CP For %d,%d\n", nodeID->osnum,nodeID->objid);
    goto wrapup;
  }
  VDASSERTW(cp && cp->getNthTreeChild);
  
  // Doit
  retFlag = cp->getNthTreeChild(nodeID,nth,childID);
  
  // Done
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Get the nth mgr child
 * Allow no manager to fail silently
 * to reduce the burden a bit on walkers
 */
IGRstat VDctxGetNthMgrChildCP(TVDctxCP *cp, TGRid *mgrID, IGRint nth, TGRid *childID)
{
  VDASSERT_FN("VDctxGetNthMgrChildCP");
  IGRstat retFlag = 0;

  // Arg checks
  VDASSERTW(childID); childID->objid = NULL_OBJID;
  VDASSERTW(nth >= 0);
  VDASSERTW(mgrID);
  if (mgrID->objid == NULL_OBJID) goto wrapup;
  
  // Get the class pointer
  if (cp == NULL) cp = VDctxGetNodeCP(mgrID);
  VDASSERTW(cp && cp->getNthMgrChild);
  
  // Doit
  retFlag = cp->getNthMgrChild(mgrID,nth,childID);
  
  // Done
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Get the tree parent
 */
IGRstat VDctxGetTreeParentCP(TVDctxCP *cp, TGRid *nodeID, TGRid *parentID)
{
  VDASSERT_FN("VDctxGetTreeParentCP");
  IGRstat retFlag = 0;
  
  // Arg checks
  VDASSERTW(parentID);
  parentID->objid = NULL_OBJID;
  
  // Get the class pointer
  if (cp == NULL) cp = VDctxGetNodeCP(nodeID);
  VDASSERTW(cp && cp->getTreeParent);

  // Doit
  retFlag = cp->getTreeParent(nodeID,parentID);
  
  // Done
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Get the mgr parent
 */
IGRstat VDctxGetMgrParentCP(TVDctxCP *cp, TGRid *nodeID, TGRid *parentID)
{
  VDASSERT_FN("VDctxGetMgrParentCP");
  IGRstat retFlag = 0;
  
  // Arg checks
  VDASSERTW(parentID);
  parentID->objid = NULL_OBJID;
  
  // Get the class pointer
  if (cp == NULL) cp = VDctxGetNodeCP(nodeID);
  VDASSERTW(cp && cp->getMgrParent);

  // Doit
  retFlag = cp->getMgrParent(nodeID,parentID);
  
  // Done
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Get the tree (the root) node
 */
void VDctxGetTreeCP(TVDctxCP *cp, TGRid *nodeID, TGRid *treeID)
{
  VDASSERT_FN("VDctxGetTreeCP");
  
  // Arg checks
  VDASSERTW(treeID);
  treeID->objid = NULL_OBJID;
  
  // Get the class pointer
  if (cp == NULL) cp = VDctxGetNodeCP(nodeID);
  VDASSERTW(cp && cp->getTree);

  // Doit
  cp->getTree(nodeID,treeID);
  
  // Done
wrapup:
  return;
}

/* -----------------------------------------------
 * Get the node type
 */
void VDctxGetNodeTypeCP(TVDctxCP *cp, TGRid *nodeID, IGRchar *nodeType)
{
  VDASSERT_FN("VDctxGetNodeTypeCP");
  
  // Arg checks
  VDASSERTW(nodeType);
  *nodeType = 0;
  
  // Get the class pointer
  if (cp == NULL) cp = VDctxGetNodeCP(nodeID);
  if (cp == NULL) {
    printf("*** Problem getting class pointer for osnum %d\n",nodeID->osnum);
  }
  VDASSERTW(cp && cp->getNodeType);

  // Doit
  cp->getNodeType(nodeID,nodeType);
  
  // Done
wrapup:
  return;
}

/* -----------------------------------------------
 * Get the node name
 */
void VDctxGetNodeNameCP(TVDctxCP *cp, TGRid *nodeID, IGRchar *nodeName)
{
  VDASSERT_FN("VDctxGetNodeNameCP");
  
  // Arg checks
  VDASSERTW(nodeName); *nodeName = 0;
  
  // Get the class pointer
  if (cp == NULL) cp = VDctxGetNodeCP(nodeID);
  VDASSERTW(cp && cp->getNodeName);

  // Doit
  cp->getNodeName(nodeID,nodeName);
  
  // Done
wrapup:
  return;
}

/* -----------------------------------------------
 * Get the comp name
 */
void VDctxGetCompNameCP(TVDctxCP *cp, TGRid *nodeID, IGRchar *compName)
{
  VDASSERT_FN("VDctxGetCompNameCP");
  
  // Arg checks
  VDASSERTW(compName); *compName = 0;
  
  // Get the class pointer
  if (cp == NULL) cp = VDctxGetNodeCP(nodeID);
  VDASSERTW(cp && cp->getCompName);

  // Doit
  cp->getCompName(nodeID,compName);
  
  // Done
wrapup:
  return;
}

/* -----------------------------------------------
 * Get the comp path
 */
void VDctxGetCompPathCP(TVDctxCP *cp, TGRid *nodeID, IGRchar *compPath)
{
  VDASSERT_FN("VDctxGetCompPathCP");
  
  // Arg checks
  VDASSERTW(compPath); *compPath = 0;
  // VDlogPrintObject(VDLOG_INFO,1,"Get comp path for ",NULL,nodeID);
    
  // Get the class pointer
  if (cp == NULL) cp = VDctxGetNodeCP(nodeID);
  VDASSERTW(cp && cp->getCompPath);

  // Doit
  cp->getCompPath(nodeID,compPath);
  
  // Done
wrapup:
  return;
}

/* -----------------------------------------------
 * Is the node of a given type
 */
IGRstat VDctxIsNodeTypeCP(TVDctxCP *cp, TGRid *nodeID, IGRchar *nodeType)
{
  VDASSERT_FN("VDctxIsNodeType");
  IGRstat retFlag = 0;

  // Arg checks
  VDASSERTW(nodeType);
  
  // Get the class pointer
  if (cp == NULL) cp = VDctxGetNodeCP(nodeID);
  VDASSERTW(cp && cp->isNodeType);

  // Doit
  retFlag = cp->isNodeType(nodeID,nodeType);
  
  // Done
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Recursive routine for counting nodes
 */
static void getNodeTypeCnt(TVDctxCP *cp,TGRid *nodeID, IGRchar *nodeType, IGRint *cnt)
{
  TGRid  childID;
  IGRint i;
  
  // Check the class
  if (cp->isNodeType(nodeID,nodeType)) *cnt = *cnt + 1;
    
  // Check each kid
  for(i = 0; cp->getNthTreeChild(nodeID,i,&childID); i++) {
    getNodeTypeCnt(cp,&childID,nodeType,cnt);
  }
  
  // Done
  return;
}

/* -----------------------------------------------
 * Count nodes of a given type
 */
void VDctxGetNodeTypeCntCP(TVDctxCP *cp, TGRid *nodeID, IGRchar *nodeType, IGRint *cnt)
{
  VDASSERT_FN("VDctxGetNodeTypeCnt");

  // Arg checks
  VDASSERTW(cnt); *cnt = 0;
  VDASSERTW(nodeType);

  // Want to use the isNodetype
  if (cp == NULL) cp = VDctxGetNodeCP(nodeID);
  VDASSERTW(cp && cp->isNodeType && cp->getNthTreeChild);

  // Go through recursive routine
  getNodeTypeCnt(cp,nodeID,nodeType,cnt);
  
  // Done
 wrapup:
  return;
}

/* -----------------------------------------------
 * Recursive routine for listing nodes
 */
static void getNodeTypeIDs(TVDctxCP *cp, TGRid *nodeID, IGRchar *nodeType, IGRint *cnt, TGRid *listIDs)
{
  TGRid  childID;
  IGRint i;
  
  // Check the class
  if (cp->isNodeType(nodeID,nodeType)) {
    listIDs[*cnt] = *nodeID;
    *cnt = *cnt + 1;
  }
  
  // Check each kid
  for(i = 0; cp->getNthTreeChild(nodeID,i,&childID); i++) {
    getNodeTypeIDs(cp,&childID,nodeType,cnt,listIDs);
  }
  
  // Done
  return;
}

/* -----------------------------------------------
 * Generates list of id's of a given type
 * returns cnt and the list
 * User must free list
 */
void VDctxGetNodeTypeIDsCP(TVDctxCP *cp, TGRid *nodeID, IGRchar *nodeType, IGRint *cnt, TGRid **listIDs)
{
  VDASSERT_FN("VDctxGetNodeTypeCnt");

  // Arg checks
  VDASSERTW(cnt);     *cnt = 0;
  VDASSERTW(listIDs); *listIDs = NULL;
  VDASSERTW(nodeType);

  // Want to use isNodetype
  if (cp == NULL) cp = VDctxGetNodeCP(nodeID);
  VDASSERTW(cp && cp->isNodeType && cp->getNthTreeChild);

  // One pass to count
  getNodeTypeCnt(cp,nodeID,nodeType,cnt);
  if (*cnt == 0) goto wrapup;
  
  // Allocate
  *listIDs = calloc(*cnt,sizeof(TGRid));
  *cnt = 0;
  VDASSERTW(*listIDs);
  
  // Go through recursive routine
  getNodeTypeIDs(cp,nodeID,nodeType,cnt,*listIDs);
  
  // Done
 wrapup:
  return;
}

/* -----------------------------------------------
 * Get the set object
 */
void VDctxGetSetCP(TVDctxCP *cp, TGRid *nodeID, TGRid *setID)
{
  VDASSERT_FN("VDctxGetSet");
  
  // Arg checks
  VDASSERTW(setID);
  setID->objid = NULL_OBJID;
  
  // Get the class pointer
  if (cp == NULL) cp = VDctxGetNodeCP(nodeID);
  VDASSERTW(cp && cp->getSet);

  // Doit
  cp->getSet(nodeID,setID);
  
  // Done
wrapup:
  return;
}
/* -----------------------------------------------
 * Delete a node
 */
void VDctxDeleteNodeCP(TVDctxCP *cp, TGRid *nodeID)
{
  VDASSERT_FN("VDctxDeleteNodeCP");
  
  // Arg checks
  VDASSERTW(nodeID);
  if (nodeID->objid == NULL_OBJID) goto wrapup;
  
  // Get the class pointer
  if (cp == NULL) cp = VDctxGetNodeCP(nodeID);
  VDASSERTW(cp && cp->deleteNode);

  // Doit
  cp->deleteNode(nodeID);
  
  // Done
wrapup:
  return;
}
/* -----------------------------------------------
 * Create a child node
 */
void VDctxCreateNodeCP(TVDctxCP *cp, 
		       TGRid    *parentID, 
		       IGRchar  *nodeType, IGRchar *nodeName, 
		       TGRid    *nodeID)
{
  VDASSERT_FN("VDctxCreateNodeCP");
  
  // Arg checks
  VDASSERTW(nodeID); nodeID->objid = NULL_OBJID;
  VDASSERTW(parentID && parentID->objid != NULL_OBJID);
  VDASSERTW(nodeType && *nodeType);
  
  // Get the class pointer
  if (cp == NULL) cp = VDctxGetNodeCP(parentID);
  VDASSERTW(cp && cp->createNode);

  // Doit
  cp->createNode(parentID,nodeType,nodeName,nodeID);
  
  // Done
wrapup:
  return;
}

/* -----------------------------------------------
 * Log a tree
 */
void VDctxPrintLogCP(TVDctxCP *cp, TGRid *nodeID, IGRint type, IGRint stdOutFlag)
{
  VDASSERT_FN("VDctxPrintLogCP");
  
  // Arg checks
  VDASSERTW(nodeID);
  if (nodeID->objid == NULL_OBJID) goto wrapup;
  
  // Get the class pointer
  if (cp == NULL) cp = VDctxGetNodeCP(nodeID);
  VDASSERTW(cp && cp->printLog);

  // Doit
  cp->printLog(nodeID,type,stdOutFlag);
  
  // Done
wrapup:
  return;
}

/* -----------------------------------------------
 * Write a tree
 */
void VDctxSaveTreeToXmlBufCP(TVDctxCP *cp, TGRid *nodeID, IGRchar **buf)
{
  VDASSERT_FN("VDctxSaveTreeToXmlBufCP");
  
  // Arg checks
  VDASSERTW(buf); *buf = 0;
  VDASSERTW(nodeID);
  if (nodeID->objid == NULL_OBJID) goto wrapup;
  
  // Get the class pointer
  if (cp == NULL) cp = VDctxGetNodeCP(nodeID);
  VDASSERTW(cp && cp->saveTreeToXmlBuf);

  // Doit
  cp->saveTreeToXmlBuf(nodeID,buf);
  
  // Done
wrapup:
  return;
}
/* -----------------------------------------------
 * Write a tree
 */
void VDctxSaveTreeToXmlFileCP(TVDctxCP *cp, TGRid *nodeID, IGRchar *fileName)
{
  VDASSERT_FN("VDctxSaveTreeToXmlFileCP");
  
  // Arg checks
  VDASSERTW(fileName && *fileName);
  VDASSERTW(nodeID);
  if (nodeID->objid == NULL_OBJID) goto wrapup;
  
  // Get the class pointer
  if (cp == NULL) cp = VDctxGetNodeCP(nodeID);
  VDASSERTW(cp && cp->saveTreeToXmlFile);

  // Doit
  cp->saveTreeToXmlFile(nodeID,fileName);
  
  // Done
wrapup:
  return;
}

/* -----------------------------------------------
 * Get the model object
 */
void VDctxGetModelObjectCP(TVDctxCP *cp, TGRid *nodeID, TGRobj_env *modelOE)
{
  VDASSERT_FN("VDctxGetModelObject");
  
  // Arg checks
  VDASSERTW(modelOE);
  modelOE->obj_id.objid = NULL_OBJID;
  
  // Get the class pointer
  if (cp == NULL) cp = VDctxGetNodeCP(nodeID);
  VDASSERTW(cp && cp->getModelObject);

  // Doit
  cp->getModelObject(nodeID,modelOE);
  
  // Done
wrapup:
  return;
}

/* -----------------------------------------------
 * Display a node
 */
void VDctxDisplayNodeCP(TVDctxCP *cp, TGRid *nodeID, enum GRdpmode mode, IGRint flag)
{
  VDASSERT_FN("VDctxDisplayNode");
  
  // Get the class pointer
  if (cp == NULL) cp = VDctxGetNodeCP(nodeID);
  VDASSERTW(cp && cp->displayNode);

  // Doit
  cp->displayNode(cp,nodeID,mode,flag);
  
  // Done
wrapup:
  return;
}

/* -----------------------------------------------
 * Compute a date
 */
void VDctxComputeDateCP(TVDctxCP *cp, TGRid *nodeID, IGRchar *name)
{
  VDASSERT_FN("VDctxComputeDate");

  // Arg check
  VDASSERTW(name);
  
  // Get the class pointer
  if (cp == NULL) cp = VDctxGetNodeCP(nodeID);
  VDASSERTW(cp && cp->computeDate);

  // Doit
  cp->computeDate(cp,nodeID,name);
  
  // Done
wrapup:
  return;
}
