/* $Id: VDctxXdom.c,v 1.11 2002/06/07 14:49:17 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdctx/c/VDctxXdom.c
 *
 * Description: X Dom Interface
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDctxXdom.c,v $
 *      Revision 1.11  2002/06/07 14:49:17  ahundiak
 *      ah
 *
 *      Revision 1.10  2002/02/28 15:31:10  ahundiak
 *      ah
 *
 *      Revision 1.9  2002/01/04 16:35:05  ahundiak
 *      ah
 *
 *      Revision 1.8  2001/11/16 14:58:19  ahundiak
 *      ah
 *
 *      Revision 1.7  2001/11/16 14:27:27  ahundiak
 *      ah
 *
 *      Revision 1.6  2001/10/19 18:21:34  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/09/21 21:13:36  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/09/18 14:01:39  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/09/17 17:44:40  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/09/06 14:39:58  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/08/24 20:00:01  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/23/01  ah      Creation
 * 09/18/01  ah      Internal calls not initializing results
 * 11/12/01  ah      Try adding bin/txt cache
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDctxPrivate.h"
#include "VDctx.h"
#include "VDss.h"
#include "VDxdom.h"

#include "glib.h"
#include "xdom.h"

VDASSERT_FFN("vdctx/c/VDctxCdom.c");

/* -----------------------------------------------
 * The low level routines always return a newly 
 * created string.  This happens because entities might
 * need to be expanded or other variable processing might take place.
 *
 * The basic idea here is that the first time a value is desired,
 * let the low level routines do their thing then cache the results
 * for subsequent accesses.
 *
 * It's also nice to be able to convert the text attribute into
 * an internal representation (such as a bsp curve) then store the
 * the binary data
 */
typedef struct Tcache
{
  IGRchar *txtDatax;  // Pointer to internal tree data
  IGRchar *txtData;   // Same as txtDatax or an expanded copy
  void    *binData;
  void   (*binFree)(void *binData);
} Tcache;

static void freeCacheData(Tcache *cache)
{
  if (cache == NULL) goto wrapup;

  if (cache->txtData != cache->txtDatax) {  
    g_free(cache->txtData);
  }
  cache->txtData  = NULL;
  cache->txtDatax = NULL;
  
  if (cache->binData) {  
    if (cache->binFree) (*cache->binFree)(cache->binData);
    else g_free(cache->binData);
  }
  cache->binData = NULL;
  cache->binFree = NULL;

 wrapup:
  return;
}
static Tcache *getCache(xmlAttrPtr attr)
{
  return attr->_private;
}

static Tcache *newCache(xmlAttrPtr attr)
{ 
  Tcache *cache = NULL;
  
  // Make the cache
  cache = g_new0(Tcache,1);
  attr->_private = cache;

 wrapup:
  return cache;
}
static void delCache(xmlAttrPtr attr)
{ 
  Tcache *cache = attr->_private;
  
  if (cache == NULL) goto wrapup;
  freeCacheData(cache);
  attr->_private = NULL;
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * xdom can have attributes of arbitary lengths
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
 * Binary Attribute
 */
static IGRstat getBinAtr(TGRid     *nodeID, 
			 TGRmd_env *env, 
			 IGRchar   *name, 
			 IGRint     flag,
			 void     **binData)
{
  VDASSERT_FN("getBinAtr");

  IGRstat retFlag = 0;

  xmlNodePtr node;
  xmlAttrPtr attr;

  Tcache *cache;
  
  // Init
  *binData = NULL;
  
  // Get it
  node = xdom_nodeid_get_node(nodeID);
  if (node == NULL) goto wrapup;
  attr = xmlHasProp(node,(xmlChar*)name);
  if (attr == NULL) goto wrapup;

  // Pull from cache
  cache = getCache(attr);
  if (!cache || !cache->binData) goto wrapup;
  *binData = cache->binData;
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Text Attribute cache processing
 */
static IGRstat getTxtAtrCache(TGRid    *nodeID, 
			      IGRchar  *name,
			      IGRchar **val)
{
  VDASSERT_FN("getTxtAtrCache");

  IGRstat retFlag = 0;

  xmlNodePtr node;
  xmlAttrPtr attr;

  Tcache *cache;

  // Init
  *val = NULL;
  
  // Get The Node and attribute
  node = xdom_nodeid_get_node(nodeID);
  if (node == NULL) goto wrapup;

  attr = xmlHasProp(node,(xmlChar*)name);
  if (attr == NULL) goto wrapup;
  
  // Know the prop exists
  retFlag = 1;
  
  // Check the cached value
  cache = getCache(attr);
  if (!cache) cache = newCache(attr);  
  if ( cache->txtData) {
    *val = cache->txtData;
    goto wrapup;
  }
  
  // Get the internal data pointer
  cache->txtDatax = (IGRchar*)attr->children->content;
  
  // Check for entities
  if (cache->txtDatax && !strchr(cache->txtDatax,'&')) cache->txtData = cache->txtDatax;
  else {  
    // Need to make a copy
    cache->txtData = (gchar*)xmlGetProp(node,(xmlChar*)name);
    if (cache->txtData == NULL) goto wrapup;
  }
  *val = cache->txtData;
  
wrapup:
  return retFlag;
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
  IGRstat sts;
  
  xmlNodePtr node;
  xmlAttrPtr attr;

  Tcache *cache;

  IGRchar *val;
  
  // Init
  *value = 0;
 
  // Get the cached value
  sts = getTxtAtrCache(nodeID,name,&val);
  if (!(sts & 1)) goto wrapup;
  
  // Should not happen
  VDASSERTW(val);
  
#if 0
  // Get The Node and attribute
  node = xdom_nodeid_get_node(nodeID);
  if (node == NULL) goto wrapup;

  attr = xmlHasProp(node,(xmlChar*)name);
  if (attr == NULL) goto wrapup;
  
  // Check the cached value
  cache = getCache(attr);
  if (!cache) cache = newCache(attr);  
  if (cache->txtData) {    
    cpyTxtAtr(value,cache->txtData);
    retFlag = 1;
    goto wrapup;
  }

  // Get the internal data pointer
  cache->txtDatax = (IGRchar*)attr->children->content;
  if (cache->txtDatax == NULL) goto wrapup;
  
  // Check for entities
  if (!strchr(cache->txtDatax,'&')) cache->txtData = cache->txtDatax;
  else {  
    // Need to make a copy
    cache->txtData = (gchar*)xmlGetProp(node,(xmlChar*)name);
    if (cache->txtData == NULL) goto wrapup;
  }
#endif

  // Copy the value
  cpyTxtAtr(value,val);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Text Attribute Pointer
 *
 * What to do when the attribute does not exist?
 * Returning a NULL forces all code to check the pointer
 * before using it.  Returning an empty string avoids the need
 * for this check but code would need to check status code
 * to see if attribute exists
 */
static IGRchar *emptyStr = "" ;

static IGRstat getTxtAtrPtr(TGRid     *nodeID, 
			    TGRmd_env *env, 
			    IGRchar   *name, 
			    IGRint     flag,
			    IGRchar  **value)
{
  VDASSERT_FN("getTxtAtr");

  IGRstat retFlag = 0;
  IGRstat sts;
  
  xmlNodePtr node;
  xmlAttrPtr attr;
  IGRchar *val;

  Tcache *cache;
    
  // Init
  *value = emptyStr;

  // Get the cached value
  sts = getTxtAtrCache(nodeID,name,&val);
  if (!(sts & 1)) goto wrapup;
  
  // Should not happen
  VDASSERTW(val);
  
#if 0
  // Get it
  node = xdom_nodeid_get_node(nodeID);
  if (node == NULL) goto wrapup;

  attr = xmlHasProp(node,(xmlChar*)name);
  if (attr == NULL) goto wrapup;

  // Check the cached value
  cache = getCache(attr);
  if (!cache) cache = newCache(attr);
  if (cache->txtData) {    
    *value = cache->txtData;
    retFlag = 1;
    goto wrapup;
  }
  // Have data?
  val = (gchar*)xmlGetProp(node,(xmlChar*)name);
  if (val == NULL) goto wrapup;
  cache->txtData = val;
#endif

  *value = val;
  
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
  IGRstat retFlag = 0;

  xmlNodePtr node;
  xmlAttrPtr attr;
  
  // get the node
  node = xdom_nodeid_get_node(nodeID);
  if (node == NULL) goto wrapup;
  
  // Get the attr
  attr = xmlHasProp(node,(xmlChar*)name);
  if (attr) {

    // Clear any cache
    freeCacheData(getCache(attr));
    
    // Set the value
    xmlSetProp(node,(xmlChar*)name,(xmlChar*)value);

    // Done
    retFlag = 1;
    goto wrapup;
  }
  
  // Append ?
  switch(flag) {
    case VDCTX_SET_ATR_FLAG_PUBLIC:
    case VDCTX_SET_ATR_FLAG_PRIVATE:
      goto wrapup;
  }
  xmlNewProp(node,(xmlChar*)name,(xmlChar*)value);
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Binary Attribute
 */
static IGRstat setBinAtr(TGRid     *nodeID, 
			 TGRmd_env *env, 
			 IGRchar   *name, 
			 IGRint     flag,
			 void      *binData,
			 void     (*binFree)(void *data))
{
  VDASSERT_FN("setBinAtr");
  IGRstat retFlag = 0;

  xmlNodePtr node;
  xmlAttrPtr attr;
  
  Tcache *cache;
  
  // get the node
  node = xdom_nodeid_get_node(nodeID);
  if (node == NULL) goto wrapup;
  
  // Get the attr
  attr = xmlHasProp(node,(xmlChar*)name);
  if (attr) {

    // Grab the cache
    cache = getCache(attr);
    if (cache) {
      if (cache->binFree) (*cache->binFree)(cache->binData);
      else g_free(cache->binData);
    }
    else cache = newCache(attr);

    cache->binData = binData;
    cache->binFree = binFree;
    retFlag = 1;
    goto wrapup;
  }
  
  // Append ?
  switch(flag) {
    case VDCTX_SET_ATR_FLAG_PUBLIC:
    case VDCTX_SET_ATR_FLAG_PRIVATE:
      goto wrapup;
  }

  // Create it
  attr = xmlNewProp(node,(xmlChar*)name,(xmlChar*)"BINARY");
  VDASSERTW(attr);
  cache = newCache(attr);
  cache->binData = binData;
  cache->binFree = binFree;
  retFlag = 1;
  
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
  IGRstat sts;
  
  xmlNodePtr node;
  IGRchar *val;
  
  // Init
  *value = 0.0;
  
  // Get it
  sts = getTxtAtrPtr(nodeID,env,name,flag,&val);
  if (!(sts & 1)) goto wrapup;
  *value = atof(val);
  
#if 0
  node = xdom_nodeid_get_node(nodeID);
  if (node == NULL) goto wrapup;
  val = (gchar*)xmlGetProp(node,(xmlChar*)name);
  if (val == NULL) goto wrapup;
  
  *value = atof(val);
  free(val);
#endif

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
  IGRstat sts;
  
  xmlNodePtr node;
  IGRchar *val;
  
  // Init
  memset(fld,0,sizeof(TVDfld));
  
  // Get it
  sts = getTxtAtrPtr(nodeID,env,name,flag,&val);
  if (!(sts & 1)) goto wrapup;
#if 0
  node = xdom_nodeid_get_node(nodeID);
  if (node == NULL) goto wrapup;
  val = (gchar*)xmlGetProp(node,(xmlChar*)name);
  if (val == NULL) goto wrapup;
#endif

  // Xfer (assume text for now)
  strcpy(fld->name,name);
  cpyTxtAtr(fld->val.txt,val);
  fld->type = VDFLD_TYPE_TXT;

  //  free(val);
  
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
  IGRstat sts;
  
  xmlNodePtr node;
  xmlAttrPtr attr;

  TVDfld   *fld;
  
  IGRint i = 0;
  IGRchar *val;
  
  // Init
  *cnt = 0;
  
  // Get the node
  node = xdom_nodeid_get_node(nodeID);
  if (node == NULL) goto wrapup;
  
  // Cycle through
  for(attr = node->properties; attr; attr = attr->next) {
    
    // Allow for NULL
    if (flds) {
      
      // Xfer (assume text for now)
      fld = &flds[i];
      strcpy(fld->name,(IGRchar*)attr->name);
      sts = getTxtAtrPtr(nodeID,env,(IGRchar*)attr->name,flag,&val);
      if (sts & 1) cpyTxtAtr(fld->val.txt,val);
      else *fld->val.txt = 0;      
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

static void getNodeType(TGRid *nodeID, IGRchar *nodeType);

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
   * Try returning some info at least
   */
  getNodeType(nodeID,baseInfo->nodeType);
  getCompName(nodeID,baseInfo->nodeName);
  
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
static IGRstat getNthTreeChild(TGRid *nodeID, IGRint nth, TGRid *childID)
{
  IGRstat retFlag = 0;
  
  xmlNodePtr node;
  xmlNodePtr child;
  
  // Init
  childID->objid = NULL_OBJID;
  
  node = xdom_nodeid_get_node(nodeID);
  if (node == NULL) goto wrapup;

  for(child = node->xmlChildrenNode; child && nth; child = child->next) {
    if (child->type == XML_ELEMENT_NODE) nth--;
  }
  if (child && (child->type == XML_ELEMENT_NODE) && (nth == 0)) {
    xdom_nodeid_set_node(childID,child);
    retFlag = 1;
  }
  
 wrapup:
  return retFlag;
  
}

/* -----------------------------------------------
 * Get the nth document processing instruction
 */
static IGRstat getNthDocPI(TGRid *nodeID, IGRint nth, TGRid *childID)
{
  IGRstat retFlag = 0;
  
  xmlNodePtr node;
  xmlNodePtr child;
  xmlDocPtr  doc;
  
  // Init
  childID->objid = NULL_OBJID;
  
  node = xdom_nodeid_get_node(nodeID);
  if (node == NULL) goto wrapup;

  doc = node->doc;
  
  for(child = doc->xmlChildrenNode; child && nth; child = child->next) {
    if (child->type == XML_PI_NODE) nth--;
  }
  if (child && (child->type == XML_PI_NODE) && (nth == 0)) {
    xdom_nodeid_set_node(childID,child);
    retFlag = 1;
  }
  
 wrapup:
  return retFlag;
  
}

/* -----------------------------------------------
 * Get the nth node processing instruction
 */
static IGRstat getNthNodePI(TGRid *nodeID, IGRint nth, TGRid *childID)
{
  IGRstat retFlag = 0;
  
  xmlNodePtr node;
  xmlNodePtr child;
  
  // Init
  childID->objid = NULL_OBJID;
  
  node = xdom_nodeid_get_node(nodeID);
  if (node == NULL) goto wrapup;
  
  for(child = node->xmlChildrenNode; child && nth; child = child->next) {
    if (child->type == XML_PI_NODE) nth--;
  }
  if (child && (child->type == XML_PI_NODE) && (nth == 0)) {
    xdom_nodeid_set_node(childID,child);
    retFlag = 1;
  }
  
 wrapup:
  return retFlag;
  
}

/* -----------------------------------------------
 * Get the content of a node
 * Calling routine must free
 */
static IGRstat getContent(TGRid *nodeID, IGRchar **content)
{
  IGRstat retFlag = 0;
  
  xmlNodePtr node;
  
  // Init
  *content = NULL;
  
  node = xdom_nodeid_get_node(nodeID);
  if (node == NULL) goto wrapup;

  *content = (IGRchar*)xmlNodeGetContent(node);

  retFlag = 1;
  
 wrapup:
  return retFlag;
  
}

void VDctxGetContentCP(TVDctxCP *cp, TGRid *nodeID, IGRchar **content)
{
  VDASSERT_FN("VDctxGetContentCP");
  
  VDASSERTW(content); *content = NULL;
  VDASSERTW(nodeID);
  
  getContent(nodeID,content);
  
 wrapup:
  return;
}
void VDctxGetNthDocPICP(TVDctxCP *cp, TGRid *nodeID, IGRint i, TGRid *piID)
{
  VDASSERT_FN("VDctxGetNthDocPICP");
  
  VDASSERTW(piID); piID->objid = NULL_OBJID;
  VDASSERTW(nodeID);
  
  getNthDocPI(nodeID,i,piID);
  
 wrapup:
  return;
}
void VDctxGetNthNodePICP(TVDctxCP *cp, TGRid *nodeID, IGRint i, TGRid *piID)
{
  VDASSERT_FN("VDctxGetNthNodePICP");
  
  VDASSERTW(piID); piID->objid = NULL_OBJID;
  VDASSERTW(nodeID);
  
  getNthNodePI(nodeID,i,piID);
  
 wrapup:
  return;
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

  xmlNodePtr node;
  xmlNodePtr root;
  xmlNodePtr parent;

  parentID->objid = NULL_OBJID;
  
  node = xdom_nodeid_get_node(nodeID);
  if (node == NULL) goto wrapup;

  /* ---------------------------------------------
   * Don't go any higher than the root node
   * Have not looked what in the parent pointer for the root
   * node but it does point somewhere
   */
  root = xmlDocGetRootElement(node->doc);
  if (root == node) goto wrapup;
  
  parent = node->parent;
  if (parent == NULL) goto wrapup;
  
  xdom_nodeid_set_node(parentID,parent);
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
 * Get the tree (or the root node)
 */
static void getTree(TGRid *nodeID, TGRid *treeID)
{
  IGRstat retFlag = 0;

  xmlNodePtr node;
  xmlNodePtr tree;

  treeID->objid = NULL_OBJID;
  
  node = xdom_nodeid_get_node(nodeID);
  if (node      == NULL) goto wrapup;
  if (node->doc == NULL) goto wrapup;
  
  tree = xmlDocGetRootElement(node->doc);
  
  xdom_nodeid_set_node(treeID,tree);
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Get the parent
 *
 * Probably should never be called for xdom
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
  TVDtagInfo info;

  // Init
  modelOE->obj_id.objid = NULL_OBJID;
  
  // Work from path
  getCompPath(nodeID,path); 
  if (*path) {
  
    // Get the object
    VDobjGetObjFromPath(path,modelOE);
    goto wrapup;
  }

  // Try the tag
  VDctxGetCompTagInfo(nodeID,&info);
  if (info.id.objid == NULL_OBJID) goto wrapup;

  modelOE->obj_id = info.id;
  VDobjResetOE(modelOE);

 wrapup:  
  return;
}

/* ---------------------------------------------
 * Returns the objects class (type)
 * For xdom, this is the node name
 */
static void getNodeType(TGRid *nodeID, IGRchar *nodeType)
{
  xmlNodePtr node;

  // Init
  *nodeType = 0;
  
  node = xdom_nodeid_get_node(nodeID);
  if (node == NULL) goto wrapup;

  /* ---------------------------------------------
   * Apply name space if we have one
   */
  if (node->ns && node->ns->prefix) {
    sprintf(nodeType,"%s:%s",(IGRchar*)node->ns->prefix,(IGRchar*)node->name);
  }
  else strcpy(nodeType,(IGRchar*)node->name);
  
 wrapup:
  return;
}

/* ---------------------------------------------
 * Returns the objects name
 *
 * Probably should never be called for xdom
 */
static void getNodeName(TGRid *nodeID, IGRchar *nodeName)
{    
  TVDctxBaseInfo baseInfo;
  
  // Init
  *nodeName = 0;
  
  // Try
  getBaseInfo(nodeID,&baseInfo);
  if (*baseInfo.nodeName) {
    strcpy(nodeName,baseInfo.nodeName);
    return;
  }
}

/* ---------------------------------------------
 * returns true if the object is of a given type
 */
static IGRstat isNodeType(TGRid *nodeID, IGRchar *nodeType)
{ 
  IGRstat retFlag = 0;
  
  IGRchab nodeTypex;
  
  getNodeType(nodeID,nodeTypex);
  
  if (!strcmp(nodeType,nodeTypex)) retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* ---------------------------------------------
 * Recursive routine to delete any caches 
 * for the node and for any child nodes
 */
static void deleteNodeCache(xmlNodePtr node, IGRint deepFlag)
{
  xmlAttrPtr attr;
  xmlNodePtr child;
  
  // Arg check
  if (node == NULL) goto wrapup;

  // Cycle though attributes
  for(attr = node->properties; attr; attr = attr->next) {
    delCache(attr);
  }
  
  // Want to do kids?
  if (deepFlag == 0) goto wrapup;

  // Cycle through
  for(child = node->xmlChildrenNode; child; child = child->next) {
    if (child->type == XML_ELEMENT_NODE) deleteNodeCache(child,deepFlag);
  }
  
 wrapup:
  return;
  
}

/* ---------------------------------------------
 * Delete a node
 */
static void deleteNode(TGRid *nodeID)
{
  xmlNodePtr node;
  xmlNodePtr root;
  
  // Ok not to have one
  node = xdom_nodeid_get_node(nodeID);
  if (node == NULL) goto wrapup;
  
  // This should do it
  if (node->doc) {
    root = xmlDocGetRootElement(node->doc);
    deleteNodeCache(root,1);    
    xmlFreeDoc(node->doc);
  }
  else {
    deleteNodeCache(node,1);    
    xmlFreeNode(node);
  }
  
 wrapup:
  return;
  
}

/* -----------------------------------------------
 * Adds new node for a tree
 *
 * Note: This is called directly by VDctxCreateXdomTree
 * with parentID = NULL
 */
static void createNode(TGRid *parentID, IGRchar *nodeType, IGRchar *nodeName, TGRid *nodeID)
{
  VDASSERT_FN("createNode");
  
  TVDctxBaseInfo baseInfo;
  
  // Init
  nodeID->objid = NULL_OBJID;
  
  // Create the node
  if (parentID) VDxdomCreateNode(parentID,nodeType,nodeID);
  else          VDxdomCreateTree(         nodeType,nodeID);

  // Add the baseInfo
  if (nodeName == NULL) goto wrapup;

  // Possible that this is int fact the root node
  if (parentID) VDctxGetBaseInfo(parentID,&baseInfo);
  else memset(&baseInfo,0,sizeof(TVDctxBaseInfo));
  
  strcpy(baseInfo.nodeType,nodeType);
  strcpy(baseInfo.nodeName,nodeName);
  
  if (*baseInfo.setType == 0) {
    strcpy(baseInfo.setType, nodeType);
    strcpy(baseInfo.treeType,nodeType);
  }
  if (*baseInfo.setName == 0) {
    strcpy(baseInfo.setName, nodeName);
    strcpy(baseInfo.treeName,nodeName);
  }  
  VDctxSetBaseInfo(nodeID,&baseInfo);

  // Done
 wrapup:
  return;
}

/* -----------------------------------------------
 * Creates a root node for a tree
 */
void VDctxCreateXdomTree(IGRchar *treeType, IGRchar *treeName, TGRid *treeID)
{
  VDASSERT_FN("VDctxCreateXdomTree");
  
  // Arg check
  VDASSERTW(treeID); treeID->objid = NULL_OBJID;
  VDASSERTW(treeType && *treeType);
  
  // Create the tree
  createNode(NULL,treeType,treeName,treeID);
    
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
  VDxdomSaveTreeToXmlBuf(treeID,buf);
}
static void saveTreeToXmlFile(TGRid *treeID, IGRchar *fileName)
{
  VDxdomSaveTreeToXmlFile(treeID,fileName);
}

/* -----------------------------------------------
 * Initializer
 */
IGRstat VDctxInitXdomCP(TVDctxCP *baseCP, TVDctxCP *cp)
{
  VDASSERT_FN("VDctxInitXdomCP");
  IGRstat retFlag = 0;

  // Arg check
  VDASSERTW(cp);

  // Copy Base
  memcpy(cp,baseCP,sizeof(TVDctxCP));
  cp->parentCP = baseCP;

  // Xfer overrode functions
  cp->setBinAtr     = setBinAtr;
  cp->getBinAtr     = getBinAtr;
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
 * Need an easy way to test for the presence
 * of a given attribute without impacting the
 * cache system
 */
IGRstat VDctxHasAttribute(TGRid *nodeID, IGRchar *name)
{
  VDASSERT_FN("VDctxHasAttribute");
  
  IGRstat retFlag = 0;

  xmlNodePtr node;
  xmlAttrPtr attr;
  
  VDASSERTW(nodeID);
  VDASSERTW(name);
  
  // get the node
  node = xdom_nodeid_get_node(nodeID);
  if (node == NULL) goto wrapup;
  
  // Get the attr
  attr = xmlHasProp(node,(xmlChar*)name);
  if (attr == NULL) goto wrapup;
  
  retFlag = 1;
  
 wrapup:
  return retFlag;
}
