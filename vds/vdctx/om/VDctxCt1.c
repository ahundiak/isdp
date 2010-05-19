/* $Id: VDctxCt1.c,v 1.5 2001/09/18 14:01:28 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdctx/c/VDctxCt1.c
 *
 * Description: Context Classes
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDctxCt1.c,v $
 *      Revision 1.5  2001/09/18 14:01:28  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/03/13 00:18:32  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/02/22 23:53:09  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/02/17 14:21:31  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.1  2001/01/14 16:09:04  art
 *      sp merge
 *
 * Revision 1.1  2000/12/06  15:01:08  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/12/00  ah      Creation
 * 09/18/01  ah      Internal calls not initializing results
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDctxPrivate.h"
#include "VDctx.h"
#include "VDct1.h"

VDASSERT_FFN("vdctx/c/VDctxCt1.c");

/* -----------------------------------------------
 * Field attribute
 */
static IGRstat getFldAtr(TGRid     *nodeID, 
			 TGRmd_env *env, 
			 IGRchar   *name, 
			 IGRint     privatE,
			 TVDfld    *fld)
{
  VDASSERT_FN("getFldAtr");
  IGRstat retFlag = 0;
  
  IGRint flag = VDCOL_VLA_EXT;

  // init
  memset(fld,0,sizeof(TVDfld));
  
  // Get it
  if (privatE) flag = VDCOL_VLA_INT;
  VDcolGetAttr(NULL,nodeID,0,0,flag,-1,name,NULL,fld,NULL);
  if (*fld->name == 0) goto wrapup;
  
  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Text Attribute
 */
static IGRstat getTxtAtr(TGRid     *nodeID, 
			 TGRmd_env *env, 
			 IGRchar   *name, 
			 IGRint     privatE,
			 IGRchar   *value)
{
  VDASSERT_FN("getTxtAtr");
  IGRstat retFlag = 0;

  TVDfld  fld;
  
  // Init
  *value = 0;
  
  // Get it
  retFlag = getFldAtr(nodeID,env,name,privatE,&fld);

  if (traceFlag) printf(">>> %s %s %s %d\n",ffn(),fn,name,retFlag);

  if (retFlag) {
    strcpy(value,fld.val.txt);
  }
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Double Attribute
 */
static IGRstat getDblAtr(TGRid     *nodeID, 
			 TGRmd_env *env, 
			 IGRchar   *name, 
			 IGRint     privatE,
			 IGRdouble *value)
{
  VDASSERT_FN("getDblAtr");
  IGRstat retFlag = 0;
  
  TVDfld fld;
  
  // Init
  *value = 0.0;
  
  // Get it
  retFlag = getFldAtr(nodeID,env,name,privatE,&fld);
  if (retFlag) {
    *value = atof(fld.val.txt);
  }

wrapup:
  return retFlag;
}


/* -----------------------------------------------
 * Field attributes
 */
static void getFldAtrs(TGRid     *nodeID, 
		       TGRmd_env *env,  
		       IGRint     privatE,
		       IGRint    *cnt,
		       TVDfld    *flds)
{
  VDASSERT_FN("getFldAtr");
  
  IGRint flag = VDCOL_VLA_EXT;
  
  // Init
  *cnt = 0;
  
  // Get Them
  if (privatE) flag = VDCOL_VLA_INT;
  VDcolGetAttrs(NULL,nodeID,0,0,flag,0,cnt,flds,NULL);
  
wrapup:
  return;
}

/* --------------------------------------------------
 * Component name and path
 */
static void getCompPath(TGRid *nodeID, IGRchar *path)
{ 
  *path = 0;
  getTxtAtr(nodeID,NULL,VDCTX_ATR_COMP_PATH,0,path);
  
  // Done
  return;
}

static void getCompName(TGRid *nodeID, IGRchar *name)
{ 
  IGRchab buf;
  IGRchar *p;

  *name = 0;
  getCompPath(nodeID,buf);  
  p = strrchr(buf,':');
  if (p) p++;
  else   p = buf;
  strcpy(name,p);
  
  // Done
  return;
}

/* -----------------------------------------------
 * Base Information
 * Should a set return nodeType and nodeName?
 */
static IGRstat getBaseInfo(TGRid *nodeID, TVDctxBaseInfo *baseInfo)
{
  VDASSERT_FN("getBaseInfo");
  IGRstat retFlag = 0;

  TVDfld fld;
  IGRchar *p;
  
  // Init
  memset(baseInfo,0,sizeof(TVDctxBaseInfo));
  
  // Get the base info attribute
  getFldAtr(nodeID,NULL,VDCT_BASE_INFO_NAME,1,&fld);
  VDASSERTW(*fld.name);
  
  // Set Type
  p = strchr(fld.val.txt,':');
  if (p) {  
    *p = 0;
    strcpy(baseInfo->setType,fld.val.txt);
    strcpy(fld.val.txt,p+1);
  }
  
  // Set Type Rev
  p = strchr(fld.val.txt,':');
  if (p) {  
    *p = 0;
    strcpy(baseInfo->setTypeRev,fld.val.txt);
    strcpy(fld.val.txt,p+1);
  }
  
  // Set Name
  p = strchr(fld.val.txt,':');
  if (p) {  
    *p = 0;
    strcpy(baseInfo->setName,fld.val.txt);
    strcpy(fld.val.txt,p+1);
  }
  
  // Node Type
  p = strchr(fld.val.txt,':');
  if (p) {  
    *p = 0;
    strcpy(baseInfo->nodeType,fld.val.txt);
    strcpy(fld.val.txt,p+1);
  }
  
  // Node Name
  p = strchr(fld.val.txt,':');
  if (p) {  
    *p = 0;
    strcpy(baseInfo->nodeName,fld.val.txt);
    strcpy(fld.val.txt,p+1);
  }
  
  // Base Name (basically what get's displayed
  if (*baseInfo->nodeType) {
    sprintf(baseInfo->baseName,"%s %s",
	    baseInfo->nodeType,
	    baseInfo->nodeName);
  }
  else {
    sprintf(baseInfo->baseName,"%s %s",
	    baseInfo->setType, 
	    baseInfo->setName);
  }

  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}
static void getNodeName(TGRid *nodeID, IGRchar *nodeName)
{
  TVDctxBaseInfo baseInfo;
  *nodeName = 0;
  getBaseInfo(nodeID,&baseInfo);
  strcpy(nodeName,baseInfo.nodeName);
  return;
}
static void getNodeType(TGRid *nodeID, IGRchar *nodeType)
{
  TVDctxBaseInfo baseInfo;
  *nodeType = 0;
  getBaseInfo(nodeID,&baseInfo);
  strcpy(nodeType,baseInfo.nodeType);
  return;
}
static IGRstat isNodeType(TGRid *nodeID, IGRchar *nodeType)
{
  IGRstat retFlag = 0;
  
  TVDctxBaseInfo baseInfo;

  getBaseInfo(nodeID,&baseInfo);

  if (!strcmp(nodeType,baseInfo.nodeType)) retFlag = 1;
  
  return retFlag;
}

/* -----------------------------------------------
 * Get the nth child
 */
static  IGRstat getNthTreeChild(TGRid *nodeID, IGRint nth, TGRid *childID)
{
  childID->objid = NULL_OBJID;
  return VDlnkGet(nodeID,VDCT_CHN_TREE1_TO_CHILD,nth,NULL,childID);
}
static  IGRstat getNthMgrChild(TGRid *nodeID, IGRint nth, TGRid *childID)
{
  TGRid  setID;
  TGRid treeID;

  childID->objid = NULL_OBJID;

  VDlnkGet(nodeID,VDCT_CHN_MGR_TO_CHILD,nth,NULL,&setID);  
  if (setID.objid == NULL_OBJID) return 0;

  VDlnkGet(&setID,VDCT_CHN_MGR_TO_CHILD,0,NULL,&treeID);  
  if (treeID.objid == NULL_OBJID) return 0;

  *childID = treeID;
  return 1;

}

/* -----------------------------------------------
 * Get the parent
 */
static  IGRstat getTreeParent(TGRid *nodeID, TGRid *parentID)
{
  parentID->objid = NULL_OBJID;
  return VDlnkGet(nodeID,VDCT_CHN_TREE1_TO_PARENT,0,NULL,parentID);
}
static  IGRstat getMgrParent(TGRid *nodeID, TGRid *parentID)
{
  parentID->objid = NULL_OBJID;
  return VDlnkGet(nodeID,VDCT_CHN_MGR_TO_PARENT,0,NULL,parentID);
}

/* -----------------------------------------------
 * Get the tree object by recursing up
 */
static void getTree(TGRid *nodeID, TGRid *treeID)
{
  TGRid parentID;
  IGRlong type;

  // Init
  treeID->objid = NULL_OBJID;

  // Might be asking a set for a tree
  VDclaGetTypeFlag(NULL,nodeID,NULL_OBJID,NULL_OSNUM,&type,NULL);
  if (type ==VDCT1_CLASS_TYPE_SET) {
    
    // Need to get the manager child
    getNthMgrChild(nodeID,0,treeID);
    goto wrapup;
  }
  
  // Asking the node for a tree
  getTreeParent(nodeID,&parentID);
  if (parentID.objid == NULL_OBJID) {
    *treeID = *nodeID;
    goto wrapup;
  }
  
  // Go Up
  getTree(&parentID,treeID);

  // Done
 wrapup:
  return;
}

/* -----------------------------------------------
 * Get the set object by recursing up
 */
static void getSet(TGRid *nodeID, TGRid *setID)
{
  VDASSERT_FN("getSet");
  
  TGRid   treeID;
  IGRlong type;

  // Init
  setID->objid = NULL_OBJID;
  
  // Might be asking a set for a set
  VDclaGetTypeFlag(NULL,nodeID,NULL_OBJID,NULL_OSNUM,&type,NULL);
  if (type ==VDCT1_CLASS_TYPE_SET) {
    
    // Need to get the manager child
    *setID = *nodeID;
    goto wrapup;
    
  }

  // Get the tree
  getTree(nodeID,&treeID);
  VDASSERTW(treeID.objid != NULL_OBJID);
  
  // Get the manager parent
  getMgrParent(nodeID,setID);
  
  // Done
 wrapup:
  return;
}

/* -----------------------------------------------
 * Initializer
 */
IGRstat VDctxInitCt1CP(TVDctxCP *baseCP, TVDctxCP *cp)
{
  VDASSERT_FN("VDctxInitCt1CP");
  IGRstat retFlag = 0;

  // Arg check
  VDASSERTW(cp);

  // Copy Base
  memcpy(cp,baseCP,sizeof(TVDctxCP));
  cp->parentCP = baseCP;
  
  // Xfer overrode functions
  cp->getTxtAtr  = getTxtAtr;
  cp->getDblAtr  = getDblAtr;
  cp->getFldAtr  = getFldAtr;
  cp->getFldAtrs = getFldAtrs;

  cp->getBaseInfo = getBaseInfo;
  cp->getNodeName = getNodeName;
  cp->getNodeType = getNodeType;
  cp->isNodeType  =  isNodeType;

  cp->getNthTreeChild = getNthTreeChild;
  cp->getTreeParent   = getTreeParent;

  cp->getNthMgrChild  = getNthMgrChild;
  cp->getMgrParent    = getMgrParent;
  
  cp->getTree         = getTree;
  cp->getSet          = getSet;

  cp->getCompName = getCompName;
  cp->getCompPath = getCompPath;

  // Model stuff
  VDctxInitCt1CPi(baseCP,cp);
  
#if 0
  cp->get = get;
#endif

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

