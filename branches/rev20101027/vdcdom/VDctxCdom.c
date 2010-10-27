/* $Id: VDctxCdom.c,v 1.1 2001/10/18 16:41:55 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdctx/c/VDctxCdom.c
 *
 * Description: Context Classes
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDctxCdom.c,v $
 *      Revision 1.1  2001/10/18 16:41:55  ahundiak
 *      ah
 *
 *      Revision 1.6  2001/09/18 14:01:38  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/09/17 17:44:40  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/08/24 20:00:01  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/06/22 15:12:54  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/05/17 14:48:13  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/05/02 15:33:19  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/23/01  ah      Creation
 * 09/18/01  ah      Internal calls not initializing results
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDctxPrivate.h"
#include "VDctx.h"
#include "VDss.h"
#include "VDcdom.h"

#include "glib.h"
#include "cdom.h"

VDASSERT_FFN("vdctx/c/VDctxCdom.c");

/* -----------------------------------------------
 * cdom can have attributes of arbitary lengths
 * prevent overflows when using standard interface
 */
static void cpyTxtAtr(IGRchar *des, IGRchar *src)
{
  if (strlen(src) < 80) strcpy(des,src);
  else {
    memcpy(des,src,79);
    *(des+79) = 0;
  }
  return;
}

/* -----------------------------------------------
 * Text Attribute
 */
static IGRstat getTxtAtr(TGRid     *nodeID, 
			 TGRmd_env *env, 
			 IGRchar   *name, 
			 IGRint     flag,
			 IGRchar   *value)
{
  VDASSERT_FN("getTxtAtr");

  IGRstat retFlag = 0;

  CDOMattr *attr;

  // Init
  *value = 0;
  
  // Get it
  attr = cdom_nodeid_get_attr_by_name(nodeID,name);
  if (attr == NULL) goto wrapup;
  
  cpyTxtAtr(value,attr->txt->str);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Text Attribute Pointer
 */
static IGRstat getTxtAtrPtr(TGRid     *nodeID, 
			    TGRmd_env *env, 
			    IGRchar   *name, 
			    IGRint     flag,
			    IGRchar  **value)
{
  VDASSERT_FN("getTxtAtrPtr");

  IGRstat retFlag = 0;

  CDOMattr *attr;
  
  // Init
  *value = NULL;
  
  // Get it
  attr = cdom_nodeid_get_attr_by_name(nodeID,name);
  if (attr == NULL) goto wrapup;
  
  *value = strdup(attr->txt->str);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Text Attribute
 */
static IGRstat setTxtAtr(TGRid     *nodeID, 
			 TGRmd_env *env, 
			 IGRchar   *name, 
			 IGRint     flag,
			 IGRchar   *value)
{
  VDASSERT_FN("setTxtAtr");
  IGRstat retFlag = 1;

  CDOMnode *node;
  CDOMattr *attr;
  
  // get the node
  node = cdom_nodeid_get_node(nodeID);
  if (node == NULL) goto wrapup;
  
  // Get the attr
  attr = cdom_attr_get_by_name(node->attrs,name);
  if (attr) {
    if (strcmp(attr->txt->str,value)) {  
      g_string_assign(attr->txt,value);
    }
    goto wrapup;
  }
  
  // Append ?
  switch(flag) {
    case VDCTX_SET_ATR_FLAG_PUBLIC:
    case VDCTX_SET_ATR_FLAG_PRIVATE:
      retFlag = 0;
      goto wrapup;
  }
  node->attrs = cdom_attr_new(node->attrs,name,value);
  
  // Done
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Double Attribute
 */
static IGRstat getDblAtr(TGRid     *nodeID, 
			 TGRmd_env *env, 
			 IGRchar   *name, 
			 IGRint     flag,
			 IGRdouble *value)
{
  VDASSERT_FN("getDblAtr");
  IGRstat retFlag = 0;

  CDOMattr *attr;
  
  // Init
  *value = 0.0;
  
  // Get it
  attr = cdom_nodeid_get_attr_by_name(nodeID,name);
  if (attr == NULL) goto wrapup;
  
  *value = atof(attr->txt->str);
  
  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Field attribute
 */
static IGRstat getFldAtr(TGRid     *nodeID, 
			 TGRmd_env *env, 
			 IGRchar   *name, 
			 IGRint     flag,
			 TVDfld    *fld)
{
  VDASSERT_FN("getFldAtr");
  IGRstat retFlag = 0;

  CDOMattr *attr;
  
  // Init
  memset(fld,0,sizeof(TVDfld));
  
  // Get it
  attr = cdom_nodeid_get_attr_by_name(nodeID,name);
  if (attr == NULL) goto wrapup;

  // Xfer (assume text for now)
  strcpy(fld->name,name);
  cpyTxtAtr(fld->val.txt,attr->txt->str);
  fld->type = VDFLD_TYPE_TXT;
  
  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Field attribute
 */
static void getFldAtrs(TGRid     *nodeID, 
		       TGRmd_env *env,  
		       IGRint     flag,
		       IGRint    *cnt,
		       TVDfld    *flds)
{
  VDASSERT_FN("getFldAtrs");

  CDOMnode *node;
  CDOMattr *attr;
  TVDfld   *fld;
  
  IGRint i = 0;
  
  // Init
  *cnt = 0;
  
  // Get the node
  node = cdom_nodeid_get_node(nodeID);
  if (node == NULL) goto wrapup;
  
  // Cycle through
  for(attr = node->attrs; attr; attr = attr->next) {
    
    // Allow for NULL
    if (flds) {
      
      // Xfer (assume text for now)
      fld = &flds[i];
      strcpy(fld->name,   attr->name->str);
      cpyTxtAtr(fld->val.txt,attr->txt->str);
      fld->type = VDFLD_TYPE_TXT;
    }
    i++; 
  }
      
wrapup:
  if (cnt) *cnt = i;
  return;
}

/* --------------------------------------------------
 * Component name, path and piece mark
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

static void getPieceMark(TGRid *nodeID, IGRchar *pcmk)
{ 
  *pcmk = 0;
  
  getTxtAtr(nodeID,NULL,VDCTX_ATR_SS_PIECE_PCMK,0,pcmk);
  if (*pcmk == 0) {
    getTxtAtr(nodeID,NULL,VDCTX_ATR_AT_ST_PCMK,0,pcmk);
  }
  
  // Done
  return;
}
static void setPieceMark(TGRid *nodeID, IGRchar *pcmk)
{ 
  
  setTxtAtr(nodeID,NULL,VDCTX_ATR_SS_PIECE_PCMK,0,pcmk);
  
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

  TGRid setID;

  IGRchab buf;
  IGRchar *p,*b;
  IGRint  i;
  
  // Init
  memset(baseInfo,0,sizeof(TVDctxBaseInfo));
  
  // See if have an attribute
  getTxtAtr(nodeID,NULL,VDCTX_ATR_BASE_INFO,VDCTX_GET_ATR_FLAG_PRIVATE,buf);
  if (*buf) {

    // Extract
    p = b = buf;
    for(i = 0; i < 5; i++) {
      p = strchr(b,':');
      if (p) {
	*p = 0;
	switch(i) {
	  case 0: strcpy(baseInfo->setType,   b); break;
	  case 1: strcpy(baseInfo->setTypeRev,b); break;
	  case 2: strcpy(baseInfo->setName,   b); break;
	  case 3: strcpy(baseInfo->nodeType,  b); break;
	  case 4: strcpy(baseInfo->nodeName,  b); break;
	}    
	b = p + 1;
      }
    }
    // Display name
    sprintf(baseInfo->baseName,"%s %s",baseInfo->nodeType,baseInfo->nodeName);
    retFlag = 1;
    goto wrapup;
  }
  
  /* ---------------------------------------------
   * Not going to worry about baseInfo when the
   * standard attribute is not present
   * not using this as much as before anyways
   */
#if 0
  // Get The node stuff
  VDdomGetObjType(nodeID,baseInfo->nodeType);
  VDdomGetObjName(nodeID,baseInfo->nodeName);

  // Need the set
  VDdomGetSetObj (nodeID,&setID);
  VDdomGetObjType(&setID,baseInfo->setType);
  VDdomGetObjName(&setID,baseInfo->setName);

  // What about revs

  // Build a description
  sprintf(baseInfo->baseName,"%s %s",baseInfo->nodeType,baseInfo->nodeName);
#endif

  // Should a set return nodeType and nodeName?
  
  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Base Information
 * Set the base info
 */
static IGRstat setBaseInfo(TGRid *nodeID, TVDctxBaseInfo *baseInfo)
{
  VDASSERT_FN("setBaseInfo");
  IGRstat retFlag = 0;

  IGRchab buf;

  // Just a cat
  sprintf(buf,"%s:%s:%s:%s:%s:",
	  baseInfo->setType,
	  baseInfo->setTypeRev,
	  baseInfo->setName,
	  baseInfo->nodeType,
	  baseInfo->nodeName);
  
  setTxtAtr(nodeID,NULL,VDCTX_ATR_BASE_INFO,VDCTX_SET_ATR_FLAG_PRIVATE_APPEND,buf);
  
  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Get the nth child
 */
static  IGRstat getNthTreeChild(TGRid *nodeID, IGRint nth, TGRid *childID)
{
  IGRstat retFlag = 0;
  
  CDOMnode *node;
  CDOMnode *child;
  
  childID->objid = NULL_OBJID;
  
  node = cdom_nodeid_get_node(nodeID);
  if (node == NULL) goto wrapup;

  child = cdom_node_nth_child(node,nth);
  if (child == NULL) goto wrapup;
  
  cdom_nodeid_set_node(childID,child);
  retFlag = 1;
  
 wrapup:
  return retFlag;
  
}

/* -----------------------------------------------
 * Get the nth mgr child (no difference)
 */
static  IGRstat getNthMgrChild(TGRid *nodeID, IGRint nth, TGRid *childID)
{
  childID->objid = NULL_OBJID;
  return getNthTreeChild(nodeID,nth,childID);
}

/* -----------------------------------------------
 * Get the parent
 */
static  IGRstat getTreeParent(TGRid *nodeID, TGRid *parentID)
{
  IGRstat retFlag = 0;

  CDOMnode *node;
  CDOMnode *parent;

  parentID->objid = NULL_OBJID;

  node = cdom_nodeid_get_node(nodeID);
  if (node == NULL) goto wrapup;

  parent = cdom_node_get_parent(node);
  if (parent == NULL) goto wrapup;
  
  cdom_nodeid_set_node(parentID,parent);
  retFlag = 1;
  
 wrapup:
  return retFlag;
  
}

/* -----------------------------------------------
 * Get the manager parent (no difference)
 */
static  IGRstat getMgrParent(TGRid *nodeID, TGRid *parentID)
{
  parentID->objid = NULL_OBJID;
  return getTreeParent(nodeID,parentID);
}

/* -----------------------------------------------
 * Get the tree
 */
static void getTree(TGRid *nodeID, TGRid *treeID)
{
  IGRstat retFlag = 0;

  CDOMnode *node;
  CDOMnode *tree;

  treeID->objid = NULL_OBJID;

  node = cdom_nodeid_get_node(nodeID);
  if (node == NULL) goto wrapup;

  tree = cdom_node_get_root(tree);
  if (tree == NULL) goto wrapup;
  
  cdom_nodeid_set_node(treeID,tree);
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Get the parent
 */
static void getSet (TGRid *nodeID, TGRid *setID)
{
  setID->objid = NULL_OBJID;
  getTree(nodeID,setID);
}

/* -----------------------------------------------
 * Get a model object
 */
static void getModelObject(TGRid *nodeID, TGRobj_env *modelOE)
{
  IGRchab path;
  
  // Init
  modelOE->obj_id.objid = NULL_OBJID;
  
  // Work from path
  getCompPath(nodeID,path);  
  if (*path == 0) goto wrapup;
  
  // Get the object
  VDobjGetObjFromPath(path,modelOE);

 wrapup:  
  return;
}

/* ---------------------------------------------
 * Returns the objects class (type)
 * Form cdom, this is the node name
 */
static void getNodeType(TGRid *nodeID, IGRchar *nodeType)
{
  CDOMnode *node;

  *nodeType = 0;
  
  node = cdom_nodeid_get_node(nodeID);
  if (node == NULL) goto wrapup;

  strcpy(nodeType,node->name->str);
  
 wrapup:
  return;
}

/* ---------------------------------------------
 * Returns the objects name
 */
static void getNodeName(TGRid *nodeID, IGRchar *nodeName)
{    
  TVDctxBaseInfo baseInfo;
  
  *nodeName = 0;
  
  // Try
  getBaseInfo(nodeID,&baseInfo);
  if (*baseInfo.nodeName) {
    strcpy(nodeName,baseInfo.nodeName);
    return;
  }

  // VDdomGetObjName(nodeID,nodeName);
}

/* ---------------------------------------------
 * returns true if the object is of a given type
 */
static IGRstat isNodeType(TGRid *nodeID, IGRchar *nodeType)
{ 
  IGRstat retFlag = 0;
  
  
  CDOMnode *node;

  node = cdom_nodeid_get_node(nodeID);
  if (node == NULL) goto wrapup;

  if (!strcmp(nodeType,node->name->str)) retFlag = 1;
  
 wrapup:
  return retFlag;
}
/* ---------------------------------------------
 * Delete a node
 */
static void deleteNode(TGRid *nodeID)
{
  VDcdomDeleteNode(nodeID);
}

/* -----------------------------------------------
 * Adds new node for a tree
 */
static void createNode(TGRid *parentID, IGRchar *nodeType, IGRchar *nodeName, TGRid *nodeID)
{
  VDASSERT_FN("createNode");
  
  TVDctxBaseInfo baseInfo;
  
  // Init
  nodeID->objid = NULL_OBJID;
  
  // Create the node
  VDcdomCreateNode(parentID,nodeType,nodeID);
  
  // Add the baseInfo
  if (nodeName) {  
    VDctxGetBaseInfo(parentID,&baseInfo);
    strcpy(baseInfo.nodeType,nodeType);
    strcpy(baseInfo.nodeName,nodeName);
    VDctxSetBaseInfo(nodeID,&baseInfo);
  }
  
  // Done
 wrapup:
  return;
}

/* ---------------------------------------------
 * save tree
 */
static void saveTreeToXmlBuf(TGRid *treeID, IGRchar **buf)
{
  *buf = NULL;
  VDcdomSaveTreeToXmlBuf(treeID,buf);
}
static void saveTreeToXmlFile(TGRid *treeID, IGRchar *fileName)
{
  VDcdomSaveTreeToXmlFile(treeID,fileName);
}

/* -----------------------------------------------
 * Initializer
 */
IGRstat VDctxInitCdomCP(TVDctxCP *baseCP, TVDctxCP *cp)
{
  VDASSERT_FN("VDctxInitCdomCP");
  IGRstat retFlag = 0;

  // Arg check
  VDASSERTW(cp);

  // Copy Base
  memcpy(cp,baseCP,sizeof(TVDctxCP));
  cp->parentCP = baseCP;
  
  // Xfer overrode functions
  cp->setTxtAtr     = setTxtAtr;
  cp->getTxtAtr     = getTxtAtr;
  cp->getTxtAtrPtr  = getTxtAtrPtr;

  cp->getDblAtr  = getDblAtr;
  cp->getFldAtr  = getFldAtr;
  cp->getFldAtrs = getFldAtrs;

  cp->getBaseInfo = getBaseInfo;
  cp->setBaseInfo = setBaseInfo;

  cp->getNthTreeChild = getNthTreeChild;
  cp->getTreeParent   = getTreeParent;

  cp->getNthMgrChild  = getNthMgrChild;
  cp->getMgrParent    = getMgrParent;

  cp->getTree         = getTree;
  cp->getSet          = getSet;

  cp->getModelObject = getModelObject;

  cp->getNodeName = getNodeName;
  cp->getNodeType = getNodeType;
  cp->isNodeType  = isNodeType;

  cp->deleteNode  = deleteNode;
  cp->createNode  = createNode;

  cp->saveTreeToXmlBuf  = saveTreeToXmlBuf;
  cp->saveTreeToXmlFile = saveTreeToXmlFile;
  
  cp->getCompName = getCompName;
  cp->getCompPath = getCompPath;

  cp->getPieceMark = getPieceMark;
  cp->setPieceMark = setPieceMark;
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Generic node low level node creation traffic
 * director, need to change this into static functions eventually
 * Requires a valid parent node, if you don't have this then no
 * real way of determine what class of node to create,
 */

void VDctxPrintTree(IGRint type, IGRint stdoutFlag, TGRid *treeID)
{
  VDcdomPrintTree(type,stdoutFlag,treeID);
}

  
/* -----------------------------------------------
 * Creates a root node for a tree
 */
// void VDctyCreateCdomRoot
// void VDctxCreateCdomRoot
// void VDcdomCreateRoot
// cdom_root_create
void VDctxCreateCdomRoot(IGRchar *treeType, IGRchar *treeName, TGRid *rootID)
{
  VDASSERT_FN("VDctxCreateCdomRoot");
  
  TVDctxBaseInfo baseInfo;
  
  // Arg check
  VDASSERTW(rootID); rootID->objid = NULL_OBJID;
  VDASSERTW(treeName && *treeName);
  VDASSERTW(treeType && *treeType);
  
  // Create the node
  VDcdomCreateNode(NULL,treeType,rootID);
  VDASSERTW(rootID->objid != NULL_OBJID);
  
  // Add the baseInfo
  memset(&baseInfo,0,sizeof(TVDctxBaseInfo));
  strcpy(baseInfo.setType, treeType);
  strcpy(baseInfo.setName, treeName);
  strcpy(baseInfo.nodeType,treeType);
  strcpy(baseInfo.nodeName,treeName);
  VDctxSetBaseInfo(rootID,&baseInfo);
  
  // Done
 wrapup:
  return;
}

/* -----------------------------------------------
 * Adds new node for a tree
 * If no parent is given then actualy create a new tree
 */
void VDctxCreateCdomNode(TGRid *parentID, IGRchar *nodeType, IGRchar *nodeName, TGRid *nodeID)
{
  VDASSERT_FN("VDctxCreateCdomNode");
  
  TVDctxBaseInfo baseInfo;
  
  // Arg check
  VDASSERTW(nodeID); nodeID->objid = NULL_OBJID;
  VDASSERTW(nodeType && *nodeType);
  VDASSERTW(nodeName);

  if ((parentID == NULL) || (parentID->objid == NULL_OBJID)) {
    VDctxCreateCdomRoot(nodeType,nodeName,nodeID);
    goto wrapup;
  }
  
  // Create the node
  VDcdomCreateNode(parentID,nodeType,nodeID);
  VDASSERTW(nodeID->objid != NULL_OBJID);
  
  // Add the baseInfo
  VDctxGetBaseInfo(parentID,&baseInfo);
  strcpy(baseInfo.nodeType,nodeType);
  strcpy(baseInfo.nodeName,nodeName);
  VDctxSetBaseInfo(nodeID,&baseInfo);
  
  // Done
 wrapup:
  return;
}
