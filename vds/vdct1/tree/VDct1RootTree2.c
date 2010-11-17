/* $Id: VDct1RootTree2.c,v 1.9.2.2 2003/06/17 14:02:10 ahundiak Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/tree/VDct1RootTree2.I
 *
 * Description: Low level implementations
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1RootTree2.c,v $
 *      Revision 1.9.2.2  2003/06/17 14:02:10  ahundiak
 *      ah
 *
 *      Revision 1.9.2.1  2003/06/06 20:58:15  ahundiak
 *      ah
 *
 *      Revision 1.9  2002/05/16 21:22:28  jdsauby
 *      JTSMP CR6359
 *
 *      Revision 1.8  2001/10/29 17:06:26  jdsauby
 *      JTS TR 5677 -jds
 *
 *      Revision 1.7  2001/10/19 15:00:03  jdsauby
 *      JTS MP TR 5660, moved getAttr and getTreeIndex from Eng to Root JDS 10/19/01
 *
 *      Revision 1.6  2001/06/05 15:15:19  jdsauby
 *      ETL 8749, no CR logged.  Needed to protect against attributes > 80.
 *
 *      Revision 1.5  2001/05/14 20:49:45  jdsauby
 *      CR5180 Update Nodes
 *
 *      Revision 1.4  2001/03/07 16:32:15  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.3  2001/03/06 20:23:26  paul_noel
 *      Fix TR4795 Missing tm_outfit_dynamic attributes supplied
 *      parent_tree_index and tree_index
 *
 *      Revision 1.2  2001/02/08 16:57:41  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/01/12 15:14:10  art
 *      sp merge
 *
 * Revision 1.1  2000/12/08  15:49:42  pinnacle
 * ah
 *
 * Revision 1.12  2000/09/07  18:02:38  pinnacle
 * js
 *
 * Revision 1.11  2000/09/04  14:43:54  pinnacle
 * js
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/10/00  ah      Creation
 * 06/17/03  ah      TR7811 - System was allowing node.name to overfill
 *                            Cleanup existing overfills by truncating
 ***************************************************************************/
#include "VDtypedefc.h" 

#include "VDos.h"
#include "VDassert.h"

#include "VDct1.h"
#include "VDctx.h"
#include "VDct1Tree.h"
#include "VDct1Tree2.h"

#include "VDct1Attrs.h"
#include "VDct1Forms.h"
#include "VDct1Trace.h"

#include "time.h"

VDASSERT_FFN("vdct1/tree/VDct1RootTree2.C");

#define MY_TREE VDCT1_TREE_TYPE_ROOT_TREE

/* --------------------------------------------------
 * determine display on treeF based on attribute frozen
 * **/
static IGRstat isDisplayOnTreeFOK(TVDct1JD *nodeJD,
	                          IGRint    dispFlag)
{
    VDASSERT_FN("isDisplayOnTreeFOK");
    IGRstat retFlag = 0; // default to not display
    IGRchar attr[80];

    VDASSERTW(nodeJD && nodeJD->id.objid != NULL_OBJID);
    
    *attr = 0;

    // get the frozen attribute
    VDjt1GetAttr(nodeJD,VDCT1_ATTR_FROZEN,attr);
    if (*attr == 0) {retFlag = 1; goto wrapup;}

    // check the display option
    // 1 = All
    // 2 = Active only
    // 3 = Frozen
    // 4 = Deleted
    switch (dispFlag)
    {
      case 1:
	  // all are valid
	  retFlag = 1;
	  goto wrapup;

      case 2:  // Active
	  if (*attr == 'A') retFlag = 1;
	  goto wrapup;

      case 3:  // Frozen
	  if (*attr == 'F') retFlag = 1;
	  goto wrapup;

      case 4:  // Deleted
	  if (*attr == 'D') retFlag = 1;
	  goto wrapup;

      default:
	  retFlag = 1;
	  goto wrapup;

    }

    // done

wrapup:
    return retFlag;
}
/* --------------------------------------------------
 * Default post node
 * do nothing for now
 */
static IGRstat postNode(TVDct1JD *nodeJD, FILE *file)
{
  VDASSERT_FN("postNode");
  IGRstat retFlag = 0;
  IGRstat sts;
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* --------------------------------------------------
 * set the NodeNum attribute
 * using a counter in the root node
 */
static IGRstat setAttrNodeNum(TVDct1JD *nodeJD)
{
  VDASSERT_FN("setAttrNodeNum");
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRint    nodeNum;
  IGRchar   buf[128];
  TVDct1JD  rootJD;

  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  // Arg check
  VDASSERTW(nodeJD && nodeJD->cl);

  // Needs to have a node num attribute
  sts = VDjt1GetAttr(nodeJD,VDCT1_ATTR_NODE_NUM,buf);
  if (!(sts & 1)) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Get the root node
  VDjt1GetRootForNode(nodeJD,&rootJD);
  VDASSERTW(rootJD.id.objid != NULL_OBJID);
  
  // If setting the root node the init the values
  if ((nodeJD->id.objid == rootJD.id.objid) &&
      (nodeJD->id.osnum == rootJD.id.osnum)) {
    
    // This is safe otherwise would not have node_num
    VDjt1SetAttr(nodeJD,VDCT1_ATTR_NUM_NEXT,"000001");
    VDjt1SetAttr(nodeJD,VDCT1_ATTR_NODE_NUM,"000000");
    
    retFlag = 1;
    goto wrapup;
  }
  
  // Set the next number
  sts = VDjt1GetAttr(&rootJD,VDCT1_ATTR_NUM_NEXT,buf);
  VDASSERTW(sts & 1);
  
  nodeNum = atoi(buf);
  VDASSERTW(nodeNum > 0);

  VDjt1SetAttr(nodeJD,VDCT1_ATTR_NODE_NUM,buf);
  
  // Update counter
  sprintf(buf,"%06d",nodeNum+1);
  VDjt1SetAttr(&rootJD,VDCT1_ATTR_NUM_NEXT,buf);
  
  // Done
  retFlag = 1;

wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/* --------------------------------------------------
 * If the top node in the tree has an attribute with the
 * name of VDCT1_ATTR_TREE_NUM, then generate a unique number
 * and assign it
 */
IGRstat setAttrTreeNum(TVDct1JD *nodeJD)
{
  VDASSERT_FN("setAttrTreeNum");
  IGRstat retFlag = 0;
  IGRint  sts;
  IGRint  index;
  IGRchar buf[128];

  TVDct1JD treeJD;
  
  //args check
  VDASSERTW(nodeJD && nodeJD->cl);

  // Should only be the top node, ignore if not
  VDjt1GetRootForNode(nodeJD,&treeJD);
  if ((nodeJD->id.objid != treeJD.id.objid) || 
      (nodeJD->id.osnum != treeJD.id.osnum)){
    retFlag = 1;
    goto wrapup;
  }
  
  // Needs an attribute
  sts = VDjt1GetAttr(nodeJD,VDCT1_ATTR_TREE_NUM,buf);
  if (!(sts & 1)) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Use the existing function, add to tree later
  VDct1GetNextTreeNumber(&index);
  
  // get the index number
  sprintf(buf,"%06d",index);

  // set the attribute 
  VDjt1SetAttr(nodeJD,VDCT1_ATTR_TREE_NUM,buf);

  retFlag = 1;

wrapup:
  if (traceFlag) {
    printf(">>> %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/* ------------------------------------------------
 * custom generic recomputer
 */
static IGRstat computeNode(TVDct1JD *nodeJD)
{
  return 1;
}


/* --------------------------------------------------
 * Unit of measure
 * Base it on node name for now???
 * Later query the database???
 * Need the beam/plate stuff implemented first
 */
static IGRstat computeUM(TVDct1JD *nodeJD, IGRchar *attrName)
{
  
  IGRstat retFlag;
  IGRstat sts;
  
  IGRchar buf[128];
  TVDctBaseInfo baseInfo;
  
  // Make sure have the attribute
  sts = _RTCJDB(nodeJD)->getAttr(nodeJD, attrName, buf);
  if (!(sts & 1)) goto wrapup;

  // Get the node name
  _RTCJDB(nodeJD)->getBaseInfo(nodeJD,&baseInfo);
  
  // Default to EA
  strcpy(buf,"EA");
  
  // Plates are square feet (or metric???)
  if (strstr(baseInfo.nodeName,"-PL_")) {
    strcpy(buf,"SF");
  }

  // Beams are length
  if (strstr(baseInfo.nodeName,"-BM_")) {
    strcpy(buf,"LF");
  }

  // And update
  _RTCJDB(nodeJD)->setAttr(nodeJD, attrName, buf);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* --------------------------------------------------
 * Sets the date in question
 */
static IGRstat computeDate(TVDct1JD *nodeJD, IGRchar *attrName)
{
  IGRstat retFlag;
  IGRstat sts;
  
  IGRchar buf[128];
  
  time_t current_time;
  struct tm *tm;
  
  // Make sure have the attribute
  sts = VDjt1GetAttr(nodeJD, attrName, buf);
  if (!(sts & 1)) goto wrapup;
  
  // Date time stamp
  time(&current_time);
  tm = localtime(&current_time);
  sprintf(buf,
	  "%4d-%02d-%02d %02d:%02d:%02d",
	  tm->tm_year+1900,tm->tm_mon+1,tm->tm_mday,
	  tm->tm_hour,tm->tm_min,tm->tm_sec);

  // Update
  VDjt1SetAttr(nodeJD, attrName, buf);

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* --------------------------------------------------------------------
 * Standard low level data
 */
static IGRstat setBaseInfo(TVDct1JD *nodeJD, TVDctBaseInfo *baseInfo)
{
  VDASSERT_FN("setBaseInfo");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar buf[128];
  IGRchar *p,*q;
  
  // Arg Check
  VDASSERTW(nodeJD && nodeJD->cl);
  VDASSERTW(baseInfo);

  // Make the string
  sprintf(buf,"%s:%s:%s:%s:%s:",
	  baseInfo->setType,
	  baseInfo->setTypeRev,
	  baseInfo->setName,
	  baseInfo->nodeType,
	  baseInfo->nodeName);

  // Update It
  sts = _RTCJDB(nodeJD)->setPrivateAttr(nodeJD,VDCT_BASE_INFO_NAME,buf);
  if (!(sts & 1)) {
    sts = _RTCJDB(nodeJD)->createPrivateAttr(nodeJD,
					     VDCT_BASE_INFO_NAME,
					     VDFLD_TYPE_TXT,
					     buf);
  }
  VDASSERTW(sts & 1);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* --------------------------------------------------------------------
 * Standard low level data
 */
static IGRstat getBaseInfo(TVDct1JD *nodeJD, TVDctBaseInfo *baseInfo)
{
  IGRstat  retFlag = 0;
  IGRstat  traceFlag = traceFlagx;
  
  IGRchar buf[128];
  IGRchar *p,*q;
  
  // Arg Check
  if (baseInfo == NULL) goto wrapup;
  memset(baseInfo,0,sizeof(TVDctBaseInfo));
  
  // Get the base_info attribute
  _RTCJDB(nodeJD)->getPrivateAttr(nodeJD,VDCT_BASE_INFO_NAME,buf);
  if (*buf == 0) goto wrapup;
  q = buf;
  
  // Set Type
  p = strchr(q,':');
  if (p == NULL) goto base_name; *p = 0;
  if (strlen(q) >= VDCT_SET_TYPE_LEN) *(q+VDCT_SET_TYPE_LEN-1) = 0;
  strcpy(baseInfo->setType,q);
  q = p + 1 ;
  
  // Set Type Rev
  p = strchr(q,':');
  if (p == NULL) goto base_name; *p = 0;
  if (strlen(q) >= VDCT_SET_TYPE_REV_LEN) *(q+VDCT_SET_TYPE_REV_LEN-1) = 0;
  strcpy(baseInfo->setTypeRev,q);
  q = p + 1 ;

  // Set Name
  p = strchr(q,':');
  if (p == NULL) goto base_name; *p = 0;
  if (strlen(q) >= VDCT_SET_NAME_LEN) *(q+VDCT_SET_NAME_LEN-1) = 0;
  strcpy(baseInfo->setName,q);
  q = p + 1 ;
    
  // Node Type
  p = strchr(q,':');
  if (p == NULL) goto base_name; *p = 0;
  if (strlen(q) >= VDCT_NODE_TYPE_LEN) *(q+VDCT_NODE_TYPE_LEN-1) = 0;
  strcpy(baseInfo->nodeType,q);
  q = p + 1 ;

  // Node Name
  p = strchr(q,':');
  if (p == NULL) goto base_name; *p = 0;
  if (strlen(q) >= VDCT_NODE_NAME_LEN) *(q+VDCT_NODE_NAME_LEN-1) = 0;
  strcpy(baseInfo->nodeName,q);
  q = p + 1 ;

base_name:
  // Make a display name
  if (*baseInfo->nodeType) {
    sprintf(baseInfo->baseName,"%s %s",baseInfo->nodeType,baseInfo->nodeName);
  }
  else {
    if (*baseInfo->setType) {
      sprintf(baseInfo->baseName,"%s %s",baseInfo->setType,baseInfo->setName);
    }
  }
  
  // Worked
  retFlag = 1;
  
wrapup:

  return retFlag;
  
}

/* -----------------------------------------------
 * Utility routine to get value of one attribute
 * Returns false if not found 
 */
static IGRstat getAttr(TVDct1JD *nodeJD, IGRchar *name, IGRchar *value)
{
  IGRstat retFlag = 0;
  TVDfld  fld;
    
  // Get it
  VDctxGetAttr(&nodeJD->id,name,&fld);
  if (*fld.name == 0) goto wrapup;
  
  // Update
  if (value) strcpy(value,fld.val.txt);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Utility routine to set value of one attribute
 * No difference between this and update 
 */
static IGRstat setAttr(TVDct1JD *nodeJD, IGRchar *name, IGRchar *value)
{
  IGRstat retFlag = 0;
  TVDfld  fld;

  IGRchar *p;
  
  // Get it
  VDctxGetAttr(&nodeJD->id,name,&fld);
  if (*fld.name == 0) goto wrapup;
 
  /* ---------------------------------------------
   * Until some upstream code gets fixed
   * Gaurd against control codes
   */
  for(p = value; *p; p++) {
    if (*p < ' ') {
      if (*p != '\n') *p = ' ';
    }
  }

  // Update
  if (value) {
      // fld.val.txt cannot be > 80
      strncpy(fld.val.txt,value,79);
      *(fld.val.txt + 79) = 0;
  }
  VDctxUpdAttrs(&nodeJD->id,1,&fld);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}
/* -----------------------------------------------
 * Utility routine to get value of one attribute
 * Returns false if not found 
 */
static IGRstat getPrivateAttr(TVDct1JD *nodeJD, IGRchar *name, IGRchar *value)
{
  IGRstat retFlag = 0;
  TVDfld  fld;
    
  // Get it
  VDctxGetPrivateAttr(&nodeJD->id,name,&fld);  
  if (*fld.name == 0) goto wrapup;
  
  // Update
  if (value) strcpy(value,fld.val.txt);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Utility routine to set value of one attribute
 * No difference between this and update 
 */
static IGRstat setPrivateAttr(TVDct1JD *nodeJD, IGRchar *name, IGRchar *value)
{
  IGRstat retFlag = 0;
  TVDfld  fld;
  
  // Get it
  VDctxGetPrivateAttr(&nodeJD->id,name,&fld);  
  if (*fld.name == 0) goto wrapup;
  
  // Update
  if (value) strcpy(fld.val.txt,value);
  VDctxUpdPrivateAttrs(&nodeJD->id,1,&fld);  

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Utility routine to update value of one attribute
 * No difference between this and set
 */
static IGRstat updateAttr(TVDct1JD *nodeJD, IGRchar *name, IGRchar *value)
{
  IGRstat retFlag = 0;
  TVDfld  fld;

  IGRchar *p;
  
  TGRid *nodeID = &nodeJD->id;
  
  // Get it
  VDctxGetAttr(&nodeJD->id,name,&fld);
  if (*fld.name == 0) goto wrapup;
 
  /* ---------------------------------------------
   * Until some upstream code gets fixed
   * Gaurd against control codes
   */
  for(p = value; *p; p++) {
    if (*p < ' ') {
      if (*p != '\n') *p = ' ';
    }
  }

  // Update
  if (value) {
      // fld.val.txt cannot be > 80
      strncpy(fld.val.txt,value,79);
      *(fld.val.txt + 79) = 0;
  }
  VDctxUpdAttrs(&nodeJD->id,1,&fld);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* --------------------------------------------------
 * Create an attribute of the given type
 */
static IGRstat createAttr(TVDct1JD *nodeJD, IGRchar *name, IGRint type, IGRchar *value)
{
  VDASSERT_FN("createAttr");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDfld  fld;
  
  // Arg check
  VDASSERTW(nodeJD && nodeJD->cl);
  VDASSERTW(name);
  VDASSERTW(value);
  
  // See if it already exists
  sts = _RTCJDB(nodeJD)->getAttr(nodeJD,name,NULL);
  if (sts & 1) goto wrapup;  // attribute already exists
  
  // Create it
  VDfldSetValue(&fld,name,type,value);
  VDctxUpdAttrs(&nodeJD->id,1,&fld);

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* --------------------------------------------------
 * Create an attribute of the given type
 */
static IGRstat createPrivateAttr(TVDct1JD *nodeJD, 
				 IGRchar  *name, 
				 IGRint    type, 
				 IGRchar  *value)
{
  VDASSERT_FN("createPrivateAttr");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDfld  fld;
  
  // Arg check
  VDASSERTW(nodeJD && nodeJD->cl);
  VDASSERTW(name);
  VDASSERTW(value);
  
  // See if it already exists
  sts = _RTCJDB(nodeJD)->getPrivateAttr(nodeJD,name,NULL);
  VDASSERTW(!(sts & 1));
  
  // Create it
  VDfldSetValue(&fld,name,type,value);
  VDctxUpdPrivateAttrs(&nodeJD->id,1,&fld);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* --------------------------------------------------
 * Pull down means to go up the tree and find a parent
 * node with the attribute in question and grab it's value
 *
 * Uses a loop instead of recursion
 */
static IGRstat pullDownAttr(TVDct1JD *nodeJD, IGRchar *name)
{
  IGRstat retFlag = 0;
  TVDfld  fld,fldx;

  TGRid   childID,parentID;
  TGRid   *nodeID = &nodeJD->id;
  
  TVDct1JD  childJD,parentJD;
  
  // Arg Check
  if (name == 0) goto wrapup;

  // Make sure this node had the attribute
  VDctxGetAttr(nodeID, name,&fld);
  if (*fld.name == 0) goto wrapup;
  
  // Go up the tree looking for a value
  childJD.cl = nodeJD->cl;
  childJD.id = nodeJD->id;
  
  
parent_loop:
  // get the parent
  _RTCJDB(&childJD)->getTreeParent(&childJD,&parentJD);
  if (parentJD.id.objid == NULL_OBJID) goto wrapup;
    
  // Get it's attribute
  parentID = parentJD.id;
  VDctxGetAttr(&parentID,name,&fldx);
  if (*fldx.name == 0) {
    childJD.id = parentJD.id;
    goto parent_loop;
  }
  
  // Update
  strcpy(fld.val.txt,fldx.val.txt);
  VDctxUpdAttrs(nodeID,1,&fld);
 
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Get child or parent
 */
static IGRstat getTreeChild(TVDct1JD *nodeJD, IGRint nth, TVDct1JD  *childJD)
{
  childJD->cl = nodeJD->cl;
  return VDlnkGet(&nodeJD->id,VDCT_CHN_TREE1_TO_CHILD,nth,NULL,&childJD->id);
}
static IGRstat getTreeParent(TVDct1JD *nodeJD, TVDct1JD  *parentJD)
{
  parentJD->cl = nodeJD->cl;
  return VDlnkGet(&nodeJD->id,VDCT_CHN_TREE1_TO_PARENT,0,NULL,&parentJD->id);
}

/* ---------------------------------------------
 * Connect or Disconnect tree child
 */
static IGRstat connectTreeChild(TVDct1JD *treeJD, TVDct1JD *childJD)
{
  childJD->cl = treeJD->cl;
  return VDlnkConnect(VDCT_CHN_TREE1,&treeJD->id,&childJD->id);
}

static IGRstat disconnectTreeChild(TVDct1JD *treeJD, TVDct1JD *childJD)
{
  childJD->cl = treeJD->cl;
  return VDlnkDisconnect(VDCT_CHN_TREE1,&treeJD->id,&childJD->id);
}

/* -----------------------------------------------
 * Get child or parent
 */
static IGRstat getMgrChild(TVDct1JD *nodeJD, IGRint nth, TVDct1JD  *childJD)
{
  childJD->cl = nodeJD->cl;
  return VDlnkGet(&nodeJD->id,VDCT_CHN_MGR_TO_CHILD,nth,NULL,&childJD->id);
}
static IGRstat getMgrParent(TVDct1JD *nodeJD, TVDct1JD  *parentJD)
{
  parentJD->cl = nodeJD->cl;
  return VDlnkGet(&nodeJD->id,VDCT_CHN_MGR_TO_PARENT,0,NULL,&parentJD->id);
}

/* ----------------------------------------------
 * connect or disconnect mgrchild
 */
static IGRstat connectMgrChild(TVDct1JD *mgrJD, TVDct1JD *childJD)
{
  childJD->cl = mgrJD->cl;
  return VDlnkConnect(VDCT_CHN_MGR,&mgrJD->id,&childJD->id);
}

static IGRstat disconnectMgrChild(TVDct1JD *mgrJD, TVDct1JD *childJD)
{
  childJD->cl = mgrJD->cl;
  return VDlnkDisconnect(VDCT_CHN_MGR,&mgrJD->id,&childJD->id);
}


/* -----------------------------------------------
 * From a set object, get the top node in the tree
 * Assume only one tree per set for now
 */
static IGRstat getNodeForSet(TVDct1JD  *setJD, TVDct1JD *nodeJD)
{
  nodeJD->cl = setJD->cl;
  return VDlnkGet(&setJD->id,VDCT_CHN_MGR_TO_CHILD,0,NULL,&nodeJD->id);  
}

/* -----------------------------------------------
 * Recurse up until the root node in the tree is found
 */
static IGRstat getRootForNode(TVDct1JD *nodeJD, TVDct1JD  *rootJD)
{
  TVDct1JD parentJD;

  // Make sure got one
  if (nodeJD->id.objid == NULL_OBJID) return 0;

  // Does node have a parent?
  _RTCJDB(nodeJD)->getTreeParent(nodeJD,&parentJD);
  if (parentJD.id.objid == NULL_OBJID) {
    *rootJD = *nodeJD;
    return 1;
  }
  
  // Recurse up
  return _RTCJDB(nodeJD)->getRootForNode(&parentJD,rootJD);
}

/* -----------------------------------------------
 * Find the actual set object
 */
static IGRstat getSetForNode(TVDct1JD *nodeJD, TVDct1JD  *setJD)
{
  TVDct1JD rootJD;
  
  // Get the root
  _RTCJDB(nodeJD)->getRootForNode(nodeJD,&rootJD);

  // Get the set
  setJD->cl = nodeJD->cl;
  return VDlnkGet(&rootJD.id,VDCT_CHN_MGR_TO_PARENT,0,NULL,&setJD->id);  
}

/* ------------------------------------------------------
 * Builds path to manager object 
 */

static IGRstat getManagerPath(VDosnum osnum, IGRchar *mgrPath)
{
  VDASSERT_FN("getManagerPath");
  
  IGRstat retFlag = 0;

  // Arg check
  VDASSERTW(mgrPath);
  
  // Get the path
  DIgive_pathname(osnum,mgrPath);
  if (*mgrPath == 0) return 0;
  
  // Add the explicit path
  DIstrcat(mgrPath,"IGENOD");    
  DIstrcat(mgrPath,"VDct1Mgr");

  // printf("mgrPath %s\n",mgrPath);
  
  // Done
  retFlag = 1;
  
wrapup:
  return 1;
}

/* -------------------------------------------
 * Creates a new manager object
 *
 * For now, create VDctBase object and not VDct1Base
 */
static IGRstat createManager(TVDct1JD *mgrJD)
{
  VDASSERT_FN("createManager");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar  mgrPath[DI_PATH_MAX];
  TGRid    mgrID;
  TVDct1JD mgrJDx;
  TVDct1JD mgrJDy;
  
  // Arg check
  VDASSERTW(mgrJD);
  VDASSERTW(mgrJD->cl);
  mgrJD->id.objid = NULL_OBJID;

  // Validate the os
  sts = VDosValidate(mgrJD->id.osnum);
  VDASSERTW(sts & 1); 

  // Prevent creating more than one
  mgrJDx = *mgrJD;
  _RTCJDB( &mgrJDx)->getManager(&mgrJDx);
  VDASSERTW(mgrJDx.id.objid == NULL_OBJID);
  
  // Say Hi
  // traceFlag = 1;
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  // Create object
  _RTCJDB(&mgrJDx)->createBaseObject(&mgrJDx,VDCT1_CLASS_TYPE_MGR);
  mgrID = mgrJDx.id;	
  VDASSERTW(mgrID.objid != NULL_OBJID);

  // Standard path name
  getManagerPath(mgrID.osnum, mgrPath);
  VDASSERTW(*mgrPath);

  /* ---------------------------------------------
   * Problem with VDct1Base is that it's really directory
   * as far as the system is concerned since it it derived
   * from IGRdir as a result of coming from ACncpx
   *
   * Need to use the GRputname here which in turn goes through a bunch of
   * low level nonsense to create a directory
   * 
   * of course, that means implementing a bunch of methods in the VDct1Basei.I file
   */
  VDct1GRputname(&mgrID,mgrPath);
  
  // Now, just to be sure, find it and check
  mgrJDy = mgrJDx;
  mgrJDy.id.objid = NULL_OBJID;
  _RTCJDB( &mgrJDy)->getManager(&mgrJDy);
  VDASSERTW(mgrJDx.id.objid == mgrJDy.id.objid);
  
  // Done
  mgrJD->id = mgrID;
  retFlag = 1;

wrapup:

  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/* -------------------------------------------------
 * Quick test of the create manager
 */
IGRstat VDct1TestCreateManager()
{
  VDASSERT_FN("VDct1TestCreateManager");
  IGRstat retFlag = 0;
  
  TVDct1JD mgrJD;

  // Say Hi
  //traceFlag = 1;
  if (traceFlag) {  
    printf(">>> %s %s\n",ffn(),fn);
  }
  
  mgrJD.cl = VDct1GetRootTreeClass();
  mgrJD.id.osnum = 2;
  
  createManager(&mgrJD);
  VDASSERTW(mgrJD.id.objid != NULL_OBJID);
  
  retFlag = 1;
  
 wrapup:
  if (traceFlag) {  
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

extern VDosnum OM_Gw_TransOSnum_0;

/* -------------------------------------------------
 * Create a transient manager
 */
IGRstat VDct1TestCreateTransientManager()
{
  VDASSERT_FN("VDct1TestCreateManager");
  IGRstat retFlag = 0;
  
  TVDct1JD mgrJD;

  // Say Hi
  // traceFlag = 1;
  if (traceFlag) {  
    printf(">>> %s %s\n",ffn(),fn);
  }
  
  mgrJD.cl = VDct1GetRootTreeClass();
  mgrJD.id.osnum = OM_Gw_TransOSnum_0;
  
  createManager(&mgrJD);
  VDASSERTW(mgrJD.id.objid != NULL_OBJID);
  
  retFlag = 1;
  
 wrapup:
  if (traceFlag) {  
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/* -------------------------------------------------
 * Get the manager if it exists
 */
static IGRstat getManager(TVDct1JD *mgrJD)
{
  VDASSERT_FN("getManager");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar mgrPath[DI_PATH_MAX];
    
  TGRid mgrID;
  
  // Init
  VDASSERTW(mgrJD);
  mgrJD->id.objid = NULL_OBJID;
  mgrID.osnum = mgrJD->id.osnum;
  
  sts = VDosValidate(mgrID.osnum);
  VDASSERTW(sts & 1);
  
  // Set desired os to search
  *mgrPath = 0;
  getManagerPath(mgrID.osnum, mgrPath);
  if (*mgrPath == 0) goto wrapup;

  VDtranslate(mgrPath,&mgrID);
  if (mgrID.objid == NULL_OBJID) goto wrapup;
  
  // Got it
  mgrJD->id = mgrID;
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Wrapper for creating base object
 */
static IGRstat createBaseObject(TVDct1JD  *baseJD, 
				TVDclaType classType)
{
  VDASSERT_FN("createBaseObject");
  IGRstat retFlag = 0;
  IGRstat sts;
  TGRid baseID;
  
  // Arg check
  VDASSERTW(baseJD);
  baseJD->id.objid = NULL_OBJID;
  VDASSERTW(classType);
  VDASSERTW(VDosValidate(baseJD->id.osnum) & 1);  
  
  // Do It
  VDct1CreateBaseObject(classType,baseJD->id.osnum,&baseID);
  VDASSERTW(baseID.objid != NULL_OBJID);
  
  // Done
  baseJD->id = baseID;
  retFlag = 1;
  
wrapup:
  return retFlag;
}

static IGRstat getModelPartData(TVDct1JD *nodeJD,VDprcAttr *mp)
{
  VDASSERT_FN("getModelPartData");
  
  VDASSERTW(0);

 wrapup:  
  return 0;
}

/* -----------------------------------------------
 * Inits these pointers
 */
IGRstat VDct1InitRootTreeClass2(TVDct1RootTreeClass *cl)
{
  VDASSERT_FN("VDct1InitRootTreeClass2");

  IGRstat retFlag = 0;
  
  // Tracing
  traceFlagx = traceFlag = VDct1TraceFlag(VDCT1_TRACE_TREE_BASE);
  
  // Fill up pointers
  cl->base.updateAttr     = updateAttr;
  cl->base.pullDownAttr   = pullDownAttr;

  cl->base.getAttr        = getAttr;
  cl->base.setAttr        = setAttr;

  cl->base.getPrivateAttr = getPrivateAttr;
  cl->base.setPrivateAttr = setPrivateAttr;

  cl->base.createAttr        = createAttr;
  cl->base.createPrivateAttr = createPrivateAttr;
  
  cl->base.setBaseInfo    = setBaseInfo;
  cl->base.getBaseInfo    = getBaseInfo;

  cl->base.getTreeChild   = getTreeChild;
  cl->base.getTreeParent  = getTreeParent;

  cl->base.connectTreeChild    = connectTreeChild;
  cl->base.disconnectTreeChild = disconnectTreeChild;

  cl->base.getMgrChild    = getMgrChild;
  cl->base.getMgrParent   = getMgrParent;

  cl->base.connectMgrChild    = connectMgrChild;
  cl->base.disconnectMgrChild = disconnectMgrChild;

  cl->base.getManager     = getManager;
  cl->base.createManager  = createManager;

  cl->base.getNodeForSet  = getNodeForSet;
  cl->base.getSetForNode  = getSetForNode;
  cl->base.getRootForNode = getRootForNode;

  cl->base.computeDate    = computeDate;
  cl->base.computeUM      = computeUM;
  cl->base.computeNode    = computeNode;

  cl->base.setAttrTreeNum = setAttrTreeNum;
  cl->base.setAttrNodeNum = setAttrNodeNum;
  
  cl->base.createBaseObject = createBaseObject;

  cl->base.postNode = postNode;
  cl->base.getModelPartData = getModelPartData;
  cl->base.isDisplayOnTreeFOK = isDisplayOnTreeFOK;
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}
