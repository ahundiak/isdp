/* $Id: VDtrTools.I,v 1.19.2.2 2003/06/04 15:49:07 ylong Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/tools/VDtrTools.I
 *
 * Description: basic node tools
 *
 * Dependencies: $Log: VDtrTools.I,v $
 * Dependencies: Revision 1.19.2.2  2003/06/04 15:49:07  ylong
 * Dependencies: Only filter out DELETED nodes, keep subtrees alive
 * Dependencies:
 * Dependencies: Revision 1.19.2.1  2003/05/12 19:35:32  ylong
 * Dependencies: TR7673 Filter out DELETED nodes/parts
 * Dependencies:
 * Dependencies: Revision 1.19  2002/05/20 22:27:51  ylong
 * Dependencies: *** empty log message ***
 * Dependencies:
 * Dependencies: Revision 1.18  2001/03/21 18:34:44  paul_noel
 * Dependencies: *** empty log message ***
 * Dependencies:
 * Dependencies: Revision 1.17  2001/03/19 20:30:19  paul_noel
 * Dependencies: Fix _FREE problem
 * Dependencies:
 * Dependencies: Revision 1.16  2001/03/09 16:47:51  paul_noel
 * Dependencies: Added functions vdtr$GetAllSets vdtr$IsSet vdtr$IsTree vdtr$IsNode
 * Dependencies:
 * Dependencies: Revision 1.15  2001/03/08 12:29:18  paul_noel
 * Dependencies: TR 4835 checked. Fixed Node Path Issue
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/21/00  pn      Creation
 * 01/05/01  pn      added a bunch of new helper routines
 * 05/20/02  ylong   TR6376, rewite VDtrget_stages
 * 11/17/10  ah      SOL10 frozen stuff
 ***************************************************************************/

// Generic node operations routines
class implementation VDct1Base;

#include "vdtr_macros.h"
#include "VDassert.h"
#include "VDmem.h"
#include "VDctx.h"

VDASSERT_FFN("vdct1/tools/VDtrTools.I");
/*****************************************************
 *
 * Is the object of one of the trees?
 *
 *****************************************************/
IGRstat VDtrIsTreeAncestry(TGRid *nodeID)
{
  VDASSERT_FN("VDtrTreeAncestry");
  IGRstat  retFlag = 0;
  IGRint   nodeClass;
  IGRchar  nodeType[128];

  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  // must have a nodeID
  VDASSERTW(nodeID);
  if(nodeID->objid == NULL_OBJID) goto wrapup;

  retFlag = 1;
  
  // Based on type VDATBASE
  if(vdobj$IsAncestryValid(objID          = nodeID,
                           superClassName = "VDatBase")) goto wrapup;

  // Based on type VDCT1BASE
  if(vdobj$IsAncestryValid(objID          = nodeID,
                           superClassName = "VDct1Base")) goto wrapup;
#if 0
  /* these are not valid yet */
  // Based on type XMLBASE
  if(vdobj$IsAncestryValid(objID          = nodeID,
                           superClassName = "")) goto wrapup;

  // Based on type DOMBASE
  if(vdobj$IsAncestryValid(objID          = nodeID,
                           superClassName = "")) goto wrapup;
#endif
  retFlag = 0;
  
wrapup:
   // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
/*****************************************************
 *
 * Is the object a Set ?
 *
 *****************************************************/
IGRstat VDtrIsSet(TGRid *nodeID)
{
  VDASSERT_FN("VDtrIsSet");
  IGRstat  retFlag = 0;
  TGRid    setID;
  TGRid   *setList;
  IGRint   setCnt;
  IGRint   i;

  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  // must have a nodeID
  VDASSERTW(nodeID);
  if(nodeID->objid == NULL_OBJID) goto wrapup;

  /* inits */
  setCnt = 0;
  setList = NULL;
  
  /* get all of the sets */
  vdtr$GetAllSets(setList = &setList,
                  setCnt  = &setCnt);

  if(traceFlag) printf("setCnt [%d]\n",setCnt);
  
  /* loop through the sets */
  for(i = 0;i < setCnt;i++) {
    /* if it is the one declare success and goto wrapup */
    if((setList[i].osnum == nodeID->osnum) && (setList[i].objid == nodeID->objid)) {
      retFlag = 1;
      goto wrapup;
    }
  }

wrapup:
  _FREE( setList );
   // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
/*****************************************************
 *
 * Is the object a tree ?
 * this is filtered to only allow valid classes
 *
 *****************************************************/
IGRstat VDtrIsTree(TGRid *nodeID)
{
  VDASSERT_FN("VDtrIsTree");
  IGRstat  retFlag = 0;
  TGRid    treeID;

  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  // must have a nodeID
  VDASSERTW(nodeID);
  if(nodeID->objid == NULL_OBJID) goto wrapup;

  /* ask for the treeID related to this nodeID */
  VDctxGetTree(nodeID,&treeID);
  /* if it matches it is a treeID */
  if((nodeID->osnum == treeID.osnum) && (nodeID->objid == treeID.objid)) {
    retFlag = 1;
  }
  
  

wrapup:
   // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
/*****************************************************
 *
 * Is the object a node under a tree (not the tree itself)?
 *
 *****************************************************/
IGRstat VDtrIsNode(TGRid *nodeID)
{
  VDASSERT_FN("VDtrIsNode");
  IGRstat  retFlag = 0;
  IGRstat  sts = 0;
  TGRid    treeID;
  
  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  /* init treeID */
  treeID.objid = NULL_OBJID;
  
  // must have a nodeID
  VDASSERTW(nodeID);
  if(nodeID->objid == NULL_OBJID) goto wrapup;

  /* it might just be a setID */
  if(vdtr$IsSet(nodeID = nodeID))  goto wrapup;

  /* it might just be a treeID */
  if(vdtr$IsTree(nodeID = nodeID))  goto wrapup;

  /* it might not have a tree */
  VDctxGetTree(nodeID,&treeID);
  if(treeID.objid == NULL_OBJID) goto wrapup;

  retFlag = 1;

wrapup:
   // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
/*****************************************************
 *
 * Is the object a leaf?
 *
 *****************************************************/
IGRstat VDtrIsLeaf(TGRid *nodeID)
{
  VDASSERT_FN("VDtrIsLeaf");
  IGRstat  retFlag = 0;
  IGRint   nodeClass;
  IGRchar  nodeType[128];

  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  // must have a nodeID
  VDASSERTW(nodeID);
  if(nodeID->objid == NULL_OBJID) goto wrapup;

  // init

  // get the class
  vd$trget_class( nodeID = nodeID,
                  class  = &nodeClass );

  // get the VDatBase data
  if (nodeClass == VDTR_CLASS_VDAT) {
    retFlag = VDatIsLeaf(nodeID);
  }


  // get the VDct1Base data
  if (nodeClass == VDTR_CLASS_VDCT1) {
    vdtr$GetNodeType(nodeID   = nodeID,
                     nodeType = nodeType);
    if(!strcmp(nodeType,"PART")) retFlag = 1;
  }

wrapup:
  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/*
 * Report status of an event to the UI_status() box
 * location is the number of the process in a loop or otherwise
 * count is the count of items to process
 * txt is any additonal message that the process
 * message needs
 * count is optional and so is txt
 */

IGRstat VDtrUI(IGRint *location, IGRint *count, IGRchar *txt)
{
  VDASSERT_FN("VDtrUI");
  IGRstat        retFlag = 0;
  IGRchar        msg[128], buf[128],text[128];
  IGRint         interval,ok;

  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  // args check
  if(!location) goto wrapup;

  // if the count exists calculate the report printing interval at somewhat 5% units
  interval = 1;
  ok = 1;

  if(count) {
    if(*count > 20) {
      interval = *count/(*count/20);
      ok = *location % interval;
    }
      if(*location == *count) ok = 1;
  }

  if(!ok) {
    retFlag = 1;
    goto wrapup;
  }


  // start the string
  strcpy(buf,"");
  strcpy(text,"");
  if(txt) {
    sprintf(text,"[%s]",txt);
  }
  if(count) {
    sprintf(buf,"%d of %d",*location,*count);
  }
  else {
    sprintf(buf,"%d",*location);
  }
  // crank up the basic message
  sprintf(msg,"Processing %s : %s",text,buf);
  // print the message
  UI_status(msg);

  retFlag = 1;

wrapup:
   // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
/******************************************************
 *
 * Get the nodeKeys from the nodePath
 * '|' delimiter
 ******************************************************/
IGRstat VDtrGetNodeKeysFromNodePath(IGRchar *nodePath,
                                    IGRchar *tree_key,
                                    IGRchar *node_key)
{
  VDASSERT_FN("VDtrGetNodeKeysFromNodePath");
  IGRstat         retFlag = 0;
  IGRchar         nodeKeys[128];

  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
    printf("nodePath [%s]\n",nodePath);
  }
  // args check
  VDASSERTW(nodePath);
  VDASSERTW(tree_key);
  VDASSERTW(node_key);



  if(!strcmp(nodePath,"")) goto wrapup;

  // inits
  strcpy(nodeKeys,"");
  strcpy(tree_key,"");
  strcpy(node_key,"");


  // clip out the first nodeName and prime the loop
  vdtr$GetDelimitedStr(impStr = nodePath,
                       outStr = nodeKeys,
                       delChr = '|',
                       posStr = 2);

  if(!strcmp(nodeKeys,"")) goto wrapup;

  // get the tree_key
  vdtr$GetDelimitedStr(impStr = nodeKeys,
                       outStr = tree_key,
                       delChr = ':',
                       posStr = 1);
  // get the node_key
    vdtr$GetDelimitedStr(impStr = nodeKeys,
                       outStr = node_key,
                       delChr = ':',
                       posStr = 2);
  retFlag = 1;

wrapup:

  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d \n",ffn(),fn,retFlag);
  }
  return retFlag;
}
/******************************************************
 *
 * Get the truePath and not all the other stuff after the
 * '|' delimiter
 ******************************************************/
IGRstat VDtrGetTruePathFromNodePath(IGRchar *nodePath,
                                    IGRchar *truePath)
{
  VDASSERT_FN("VDtrGetTruePathFromNodePath");
  IGRstat         retFlag = 0;
  IGRchar         delStrClip[128],clippedStr[128];

  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
    printf("nodePath [%s]\n",nodePath);
  }
  // args check
  VDASSERTW(nodePath);
  VDASSERTW(truePath);
  if(!strcmp(nodePath,"")) goto wrapup;

  // inits
  strcpy(truePath,"");

  // clip out the first nodeName and prime the loop
  vdtr$GetDelimitedStr(impStr = nodePath,
                       outStr = truePath,
                       delChr = '|',
                       posStr = 1);

  retFlag = 1;

wrapup:

  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d \n",ffn(),fn,retFlag);
  }
  return retFlag;
}
/******************************************************
 *
 * Get the nodeName from a standard path
 * File:      vds/incude/vdtr_macros.h
 * used internally to clip out the last nodeName listed
 * I = nodePath
 * O = nodeName
 * NOTE intended in a pure path not including |xxxx:xxxx at end
 *
 ******************************************************/
IGRstat VDtrGetNodeNameFromPath(IGRchar *nodePath,
                                IGRchar *nodeName)
{
  VDASSERT_FN("VDtrGetNodeNameFromPath");
  IGRstat         retFlag = 0;
  IGRchar         delStrClip[128],truePath[128],clippedStr[128];
  IGRint          clipPos = 3;

  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
    printf("nodePath [%s]\n",nodePath);
  }
  // args check
  VDASSERTW(nodePath);
  VDASSERTW(nodeName);
  if(!strcmp(nodePath,"")) goto wrapup;

  // inits
  strcpy(nodeName,"");
  strcpy(delStrClip,"");
  strcpy(clippedStr,"");

  // be sure it is a truePath
  VDtrGetTruePathFromNodePath(nodePath,
                              truePath);
    if(!strcmp(truePath,"")) {
    goto wrapup;
  }


    // clip out the first nodeName and prime the loop
  vdtr$GetDelimitedStr(impStr = truePath,
                       outStr = delStrClip,
                       delChr = ':',
                       posStr = clipPos);
  if(!strcmp(delStrClip,"")) {
    goto wrapup;
  }
  strcpy(clippedStr,delStrClip);
  // keep clipping strings
  while(strcmp(delStrClip,"")) {
    // copy it over because it is good
    strcpy(clippedStr,delStrClip);
    // get the next clip
    clipPos++;
    vdtr$GetDelimitedStr(impStr = truePath,
                         outStr = delStrClip,
                         delChr = ':',
                         posStr = clipPos);
  }
  // copy over the last good string
  strcpy(nodeName,clippedStr);
  retFlag = 1;

wrapup:

  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d nodeName->[%s]\n",ffn(),fn,retFlag,nodeName);
  }
  return retFlag;
}

/******************************************************
 *
 * Get the node from the path AST
 * File:      vds/incude/vdtr_macros.h
 * I = nodePath
 * O = nodeID  <optional at least 1 of these>
 *
 ******************************************************/
IGRstat VDtrGetASTClassPathNode(IGRchar *nodePath,
                                TGRid   *nodeID,
                                TGRid   *treeID)
{
  VDASSERT_FN("VDtrGetASTClassPathNode");
  IGRchar         tree_key[128],node_key[128],truePath[128],oldPath[128];
  IGRchar         unit_name[128],stage_name[128],node_name[128],node_names[128];
  IGRchar         node_type[128],xnode_path[128],xnodeName[128];
  IGRlong         tree_objid,node_objid;
  TGRid          *treeList,*nodeList,localTreeID;
  IGRint          i,j,treeListCnt,nodeListCnt,clipCnt;
  TVDctxBaseInfo  baseInfo;
  IGRstat         retFlag = 0;

  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
    printf("nodePath [%s]\n",nodePath);
  }

  // args check
  VDASSERTW(nodePath);
  if((!nodeID) && (!treeID)) goto wrapup;

  // inits
  if(nodeID) nodeID->objid = NULL_OBJID;
  if(treeID) treeID->objid = NULL_OBJID;
  node_objid = NULL_OBJID;
  tree_objid = NULL_OBJID;
  treeList = NULL;
  nodeList = NULL;
  tree_key[0] = '\0';
  node_key[0] = '\0';
  truePath[0] = '\0';
  oldPath[0]  = '\0';
  unit_name[0] = '\0';
  stage_name[0] = '\0';
  node_name[0] = '\0';
  node_names[0] = '\0';
  xnode_path[0] = '\0';
  xnodeName[0] = '\0';
  /********************
   * Important Notice *
   ********************
   * This option can have old paths and new paths entered into it
   * the old path is handled by the old drivers
   * The new path is hunted down the new way
   */

  if(!strcmp(nodePath,"")) goto wrapup;
  /*
   * get the list of available trees
   */
  vdtr$GetAllTrees(treeList = &treeList,
                   treeCnt = &treeListCnt);
  /* not trees get out of here */
  if((treeList == NULL) || (treeListCnt == 0)) goto wrapup;


  /*
   * get the tree_key and node_key if it exists
   */

  vdtr$GetNodeKeysFromNodePath(nodePath = nodePath,
                               tree_key = tree_key,
                               node_key = node_key);
  //if(traceFlag) printf("tree_key [%s] node_key [%s]\n",tree_key,node_key);

  /*
   * Begin cutting up the string to get the data
   */

  // get the truePath string AST:xxx-1-2-3-4 or xxx-1-2-3-4
  VDtrGetTruePathFromNodePath(nodePath,
                              truePath);

  //if(traceFlag) printf("truePath [%s]\n",truePath);
  /* check if the string is AST: to start */
  vdtr$GetDelimitedStr(impStr = truePath,
                       outStr = oldPath,
                       delChr = ':',
                       posStr = 1);
  // if(traceFlag) printf("oldPath1 [%s]\n",oldPath);
  /* if it is AST: */
  if(!strcmp(oldPath,VDTR_AST_CLASS)) {
    oldPath[0] = '\0';
    vdtr$GetDelimitedStr(impStr = truePath,
                         outStr = oldPath,
                         delChr = ':',
                         posStr = 2);
  }
  // if(traceFlag) printf("oldPath2 [%s]\n",oldPath);
  /* we now have an oldPath string so lets clip out the names */
  vdtr$GetDelimitedStr(impStr = oldPath,
                       outStr = node_names,
                       delChr = ' ',
                       posStr = 2);
  //if(traceFlag) printf("node_names [%s]\n",node_names);
  /* clip out the node_name */
  vdtr$GetDelimitedStr(impStr = oldPath,
                       outStr = node_type,
                       delChr = ' ',
                       posStr = 1);
  //if(traceFlag) printf("node_type [%s]\n",node_type);
  /* clip out the unit_name out of the 1st location in the node_names */
  vdtr$GetDelimitedStr(impStr = node_names,
                       outStr = unit_name,
                       delChr = '-',
                       posStr = 1);

  /* get the node_name */
  clipCnt = 1;
  while(clipCnt) {
    vdtr$GetDelimitedStr(impStr = node_names,
                         outStr = node_name,
                         delChr = '-',
                         posStr = clipCnt);
    //if(traceFlag) printf("node_namex [%s]\n",node_name);
    if(!strcmp(node_name,"")) {
      clipCnt--;
      vdtr$GetDelimitedStr(impStr = node_names,
                           outStr = node_name,
                           delChr = '-',
                           posStr = clipCnt);
      break;
    }
    clipCnt++;
  }
  /*  if(traceFlag) printf("node_name [%s] node_type [%s] unit_name [%s]\n",node_name,node_type,unit_name); */
  if(!strcmp(node_name,"")) goto wrapup;
  /* if we have a node_key and tree_key */
  if((strcmp(tree_key,"")) && (strcmp(node_key,""))) {
    /* use the new way to get the nodeID */
    tree_objid = atoi(tree_key);
    node_objid = atoi(node_key);
    /* if(traceFlag) printf("tree_objid = [%d] node_objid = [%d]\n",tree_objid,node_objid); */

    if(!((tree_objid == NULL_OBJID) || (node_objid == NULL_OBJID))) {
      /* loop through the trees and get the tree if we can */
      for(i = 0;i < treeListCnt;i++) {
        /*  get the tree baseInfo */
        if(treeList[i].objid != NULL_OBJID) {
          VDctxGetBaseInfo(&treeList[i],&baseInfo);
          if(!strcmp(baseInfo.nodeName,unit_name)) {
            /* double check  if we have a tree_objid*/
            if(tree_objid != NULL_OBJID) {
              if(treeList[i].objid == tree_objid) {
                if(treeID) *treeID = treeList[i];
                localTreeID = treeList[i];
              }
            }
          }
        }
      }
    }
  }
  else {
    /* loop through the trees and get the  match  */
    for(i = 0;i < treeListCnt;i++) {
      if(treeList[i].objid != NULL_OBJID) {
        VDctxGetBaseInfo(&treeList[i],&baseInfo);
        if (!strcmp(baseInfo.nodeName,unit_name)) {
          if(treeID) *treeID = treeList[i];
          localTreeID = treeList[i];
        }
      }
    }
  }
  /* wrapup if we don't have a treeID here */
  if(treeID) {
    if(treeID->objid == NULL_OBJID) goto wrapup;
    if(traceFlag) printf("treeID [%d] [%d] \n",treeID->osnum,treeID->objid);
  }

  /* if we are only looking for a treeID go home now */
  if(!nodeID) {
    retFlag = 1;
    goto wrapup;
  }

  /* make sure the path is not for the tree (its ok but we have to check it first) */
  if((node_objid != NULL_OBJID) &&(tree_objid != NULL_OBJID)) {
    if (node_objid == tree_objid) {
      *nodeID = localTreeID;
      retFlag = 1;
      goto wrapup;
    }
  }
  if(!strcmp(node_name,unit_name)) {
    *nodeID = localTreeID;
    retFlag = 1;
    goto wrapup;
  }

  /*  start looking at the kids */
  vd$trget_nodes( nodeID     = &localTreeID,
                  lookupType = VDTR_FIND_ALL_NODE,
                  outID      = &nodeList,
                  cnt        = &nodeListCnt ) ;

  /* verify if we have any nodes to look at */
  if((nodeListCnt == 0) || (nodeList == NULL)) goto wrapup;
  /* loop through the nodes and get the node */

  if(node_objid != NULL_OBJID) {
    /* this is the new way */
    for(j = 0;j < nodeListCnt;j++) {
      if(node_objid == nodeList[j].objid) {
        /* double check */
        VDctxGetBaseInfo(&nodeList[j],&baseInfo);
        if(!strcmp(baseInfo.nodeName,"")) VDatGetLeafName(&nodeList[j],baseInfo.nodeName);
        VDctxGetBaseInfo(&nodeList[j],&baseInfo);
        if(!strcmp(baseInfo.nodeType,"PM")) {
          vdsa$GetStruct(objID = &nodeList[j], name = "pcmk", txt = baseInfo.nodeName);
        }
        if(!strcmp(baseInfo.nodeName,node_name)) {
          /* we have a match */
          *nodeID = nodeList[j];
          retFlag = 1;
          goto wrapup;
        }
        else {
          if(!strcmp(baseInfo.nodeType,"PSU")) {
            VDatGetNodePath(&nodeList[j],xnode_path);
            if(!strcmp(oldPath,xnode_path)) {
              /* we have a match!!!! */
              *nodeID = nodeList[j];
              retFlag = 1;
              goto wrapup;
            }
          }
        }
      }
    }  }
  else {
    /* this is the old way */
    for(j = 0;j < nodeListCnt;j++) {
      if(nodeList[j].objid != NULL_OBJID) {
        VDctxGetBaseInfo(&nodeList[j],&baseInfo);
        if(!strcmp(baseInfo.nodeType,"PM")) {
          vdsa$GetStruct(objID = &nodeList[j], name = "pcmk", txt = baseInfo.nodeName);
        }
        if(!strcmp(baseInfo.nodeName,node_name)) {
          /* we have a match */
          *nodeID = nodeList[j];
          retFlag = 1;
          goto wrapup;
        }
        else {
          if(!strcmp(baseInfo.nodeType,"PSU")) {
            VDatGetNodePath(&nodeList[j],xnode_path);
            if(!strcmp(oldPath,xnode_path)) {
              /* we have a match!!!! */
              *nodeID = nodeList[j];
              retFlag = 1;
              goto wrapup;
            }
          }
        }
      } 
    }
  }

wrapup:
  _FREE(treeList);
  _FREE(nodeList);
  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/******************************************************
 *
 * Get the node from the path OTM
 * File:      vds/incude/vdtr_macros.h
 * I = nodePath
 * O = nodeID  <optional at least 1 of these>
 *
 ******************************************************/
IGRstat VDtrGetOTMClassPathNode(IGRchar *nodePath,
                                TGRid   *nodeID,
                                TGRid   *treeID)
{
  VDASSERT_FN("VDtrGetOTMClassPath");
  IGRstat         retFlag = 0;
  IGRchar         delStrClip[128],truePath[128],nodeKeys[128],treeName[128];
  IGRchar         tree_key[128],node_key[128],node_name[128];
  TVDfld          treeFld,nodeFld;
  TGRid           mgrID, setID,setTreeID,*nodeList;
  IGRint          i,j,status = 0;
  IGRint          nodeListCnt = 0;
  IGRint          treeIDsCnt = 0;
  IGRint          nodeClass;
  TVDctxBaseInfo  baseInfo;

  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
    printf("nodePath [%s]\n",nodePath);
  }


  // args check
  VDASSERTW(nodePath);



  // inits
  strcpy(delStrClip,"");
  strcpy(nodeKeys,"");
  strcpy(truePath,"");
  strcpy(tree_key,"");
  strcpy(node_key,"");
  nodeList = NULL;

  if(nodeID) nodeID->objid = NULL_OBJID;
  if(treeID) treeID->objid = NULL_OBJID;
  setTreeID.objid = NULL_OBJID;

  // clip out the truePath string
  vdtr$GetDelimitedStr(impStr = nodePath,
                       outStr = truePath,
                       delChr = '|',
                       posStr = 1);

  if(!strcmp(truePath,"")) {
    goto wrapup;
  }

  // clip out the nodeKeys string
  vdtr$GetDelimitedStr(impStr = nodePath,
                       outStr = nodeKeys,
                       delChr = '|',
                       posStr = 2);
  if(!strcmp(nodeKeys,"")) {
    goto wrapup;
  }

  // clip out the treeName string
  vdtr$GetDelimitedStr(impStr = truePath,
                       outStr = treeName,
                       delChr = ':',
                       posStr = 2);
  if(!strcmp(treeName,"")) {
    goto wrapup;
  }

  // clip out the tree_key string
  vdtr$GetDelimitedStr(impStr = nodeKeys,
                       outStr = tree_key,
                       delChr = ':',
                       posStr = 1);
  if(!strcmp(tree_key,"")) {
    goto wrapup;
  }

  // clip out the node_key  string
  vdtr$GetDelimitedStr(impStr = nodeKeys,
                       outStr = node_key,
                       delChr = ':',
                       posStr = 2);
  if(!strcmp(node_key,"")) {
    goto wrapup;
  }
  // get this node's nodeName
  VDtrGetNodeNameFromPath(truePath,
                          node_name);
  // fetch the mgrID
  nodeClass = VDTR_CLASS_VDCT1;
  vd$trget_manager(mgrID  = &mgrID,
                   class  = &nodeClass);
  for(i = 0;VDctxGetNthMgrChild(&mgrID,i,&setID); i++) {
    // get the tree that corresponds to a set
    VDctxGetTree(&setID,&setTreeID);
    if(setTreeID.objid == NULL_OBJID) continue;
    VDctxGetBaseInfo(&setTreeID,&baseInfo);
    // check the tree to see if it is correct
    vdcol$GetAttr(objID = &setTreeID, name = VDCT1_ATTR_TREE_NUM, fld = &treeFld);
    if(strcmp(treeFld.val.txt,tree_key)) continue;
    if(strcmp(baseInfo.nodeName,treeName)) {
      continue;
    }
    // get its node_key we have the correct tree now
    vdcol$GetAttr(objID = &setTreeID, name = VDCT1_ATTR_NODE_NUM, fld = &nodeFld);
    if(treeID) *treeID = setTreeID;
    // if the user picked treeID only option
    if(!nodeID) {
      retFlag = 1;
      goto wrapup;
    }
    // check to see if it is the tree
    if((!strcmp(nodeFld.val.txt,node_key)) && (!strcmp(node_name,baseInfo.nodeName))){
      *nodeID = setTreeID;
      break;
    }
    // fetch all the nodes in the tree
    status = vd$trget_nodes( nodeID     = &setTreeID,
                             lookupType = VDTR_FIND_ALL_NODE,
                             outID      = &nodeList,
                             cnt        = &nodeListCnt ) ;

    if((nodeListCnt < 1) || (status = 0)) {
      // fix the tree for not found node
      treeID->objid = NULL_OBJID;
      goto wrapup;
    }
    // this is the correct tree  so lets check the nodes
    for(j = 0;j < nodeListCnt;j++) {
      vdcol$GetAttr(objID = &nodeList[j], name = VDCT1_ATTR_NODE_NUM, fld = &nodeFld);
      vdcol$GetAttr(objID = &nodeList[j], name = VDCT1_ATTR_TREE_NUM, fld = &treeFld);
      // this is the node definition
      if(nodeList[j].objid == NULL_OBJID) continue;
      VDctxGetBaseInfo(&nodeList[j],&baseInfo);
      if((!strcmp(nodeFld.val.txt,node_key)) && (!strcmp(treeFld.val.txt,tree_key)) && (!strcmp(baseInfo.nodeName,node_name))) {
        *nodeID = nodeList[j];
        break;
      }
    }
  } // looping through the sets to get the trees
  if(nodeID) {
    if(nodeID->objid != NULL_OBJID) retFlag = 1;
  }

wrapup:

  // no memory leaks ever
  _FREE(nodeList);

  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}



/******************************************************
 *
 * Get the node from the path
 * Prototype: vdtr$GetNodeFromPath
 * File:      vds/incude/vdtr_macros.h
 * I = nodePath
 * O = nodeID  <optional at least 1 of these>
 * O = treeID
 *
 ******************************************************/
IGRstat VDtrget_nodeFromPath(IGRchar *nodePath,
                             TGRid   *nodeID,
                             TGRid   *treeID)
{
  VDASSERT_FN("VDtrget_nodeFromPath");
  IGRstat         retFlag = 0;
  IGRchar         nodeClass[128];

  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
    printf("nodePath [%s]\n",nodePath);
  }

  // args check
  VDASSERTW(nodePath);
  if((!treeID) && (!nodeID)) goto wrapup;
  if(!strcmp(nodePath,"")) goto wrapup;

  // inits
  if(nodeID) nodeID->objid = NULL_OBJID;
  if(treeID) treeID->objid = NULL_OBJID;
  nodeClass[0]  = '\0';


  // see if it is an "OTM|" or "AST|"  add others later
      // get the nodeName
    vdtr$GetDelimitedStr(impStr = nodePath,
                         outStr = nodeClass,
                         delChr = ':',
                         posStr = 1);
    if(!strcmp(nodeClass,"")) goto wrapup;
    //checking the type of node it is to determine where to look for paths
    if(!strcmp(nodeClass,VDTR_OTM_CLASS)) {
      retFlag = VDtrGetOTMClassPathNode(nodePath,
                                        nodeID,
                                        treeID);

      goto wrapup;
    }
    if(!strcmp(nodeClass,VDTR_XML_CLASS)) {
      printf("%s %s: The XML Class is not yet supported.\n",ffn(),fn);
      retFlag = 1;
      goto wrapup;
    }

    if(!strcmp(nodeClass,VDTR_DOM_CLASS)) {
      printf("%s %s: The DOM Class is not yet supported.\n",ffn(),fn);
      retFlag = 1;
      goto wrapup;
    }
    if(!strcmp(nodeClass,VDTR_AST_CLASS)) {
      retFlag = VDtrGetASTClassPathNode(nodePath,
                                        nodeID,
                                        treeID);
      goto wrapup;
    }
    retFlag = VDtrGetASTClassPathNode(nodePath,
                                      nodeID,
                                      treeID);
wrapup:

  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/********************************************************
 *
 *  get the vdct1 path ** BEST NOT ADDRESSED DIRECTLY ***
 *  use the addressing of VDtr_getNodePath
 *
 ********************************************************/
IGRstat VDtrget_vdct1NodePath(TGRid   *nodeID,
			      IGRchar *path)
{
  VDASSERT_FN("VDtrget_vdct1NodePath");
  IGRstat         retFlag = 0;
  TVDctxBaseInfo  baseInfo,treeBaseInfo;
  IGRchar         nodeName[128],attrName[128],strFront[128],strBack[128],strAdd[128],strPath[128];
  IGRchar         buf[128];
  TVDfld          nodeFld,treeFld;
  TGRid           treeID,parentID,localNodeID;
  IGRint          strLenFront = 0, strLenBack = 0, strLenAdd = 0,strLenTotal = 0;

    // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  // args check
  if(!path)               goto wrapup;
  if(!nodeID)             goto wrapup;
  if(nodeID->objid == NULL_OBJID) goto wrapup;

  // set path to nothing
  strcpy(path,"");
  strcpy(strFront,"");
  strcpy(strBack,"");
  strcpy(strAdd,"");
  localNodeID.osnum = nodeID->osnum;
  localNodeID.objid = nodeID->objid;

  // get the baseInfo
  if(localNodeID.objid == NULL_OBJID) goto wrapup;
  VDctxGetBaseInfo(&localNodeID, &baseInfo);
  // check data
  if(*baseInfo.nodeType == 0) goto wrapup;
  // get the attributes
  strcpy(attrName,VDCT1_ATTR_NODE_NUM);
  VDctxGetAttr(&localNodeID,attrName,&nodeFld);
  strcpy(attrName,VDCT1_ATTR_TREE_NUM);
  VDctxGetAttr(&localNodeID,attrName,&treeFld);

  // get the treeID
  VDctxGetTree(&localNodeID,&treeID);
  if(treeID.objid == NULL_OBJID) goto wrapup;
  // get the tree baseInfo
  VDctxGetBaseInfo(&treeID,&treeBaseInfo);
  if(*treeBaseInfo.nodeName == 0) goto wrapup;
  // check the fields data
  if(*treeFld.val.txt == 0) goto wrapup;
  if(*nodeFld.val.txt == 0) goto wrapup;
  sprintf(strFront,"OTM:%s:",treeBaseInfo.nodeName);
  strLenFront = strlen(strFront);
  sprintf(strBack,"%s|%s:%s",baseInfo.nodeName,treeFld.val.txt,nodeFld.val.txt);
  strLenBack = strlen(strBack);
  sprintf(strPath,"%s%s",strFront,strBack);
  if(treeID.objid != localNodeID.objid) {
    VDctxGetTreeParent(&localNodeID,&parentID);
    while(parentID.objid != treeID.objid) {
      VDctxGetBaseInfo(&parentID,&baseInfo);
      sprintf(strAdd,"%s:",baseInfo.nodeName);
      strLenBack = strlen(strBack);
      strLenAdd = strlen(strAdd);
      strLenTotal = strLenFront + strLenAdd + strLenBack;
      // the limit is 78
      if(strLenTotal > 76) {
        strcpy(strAdd,"*:");
        // add the clip to strBack
        sprintf(buf,"%s%s",strAdd,strBack);
        strcpy(strBack,buf);
        break;
      }
      sprintf(buf,"%s%s",strAdd,strBack);
      strcpy(strBack,buf);
      localNodeID = parentID;
      VDctxGetTreeParent(&localNodeID,&parentID);
    }
  }
  
  // make up the strPath
  sprintf(strPath,"%s%s",strFront,strBack);
  strcpy(path,strPath);

  retFlag = 1;

wrapup:
  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  
  return retFlag;
}

/***********************************************
 * Get the nodePath for any node
 * input *nodeID  (required)
 * output *path
 ***********************************************/
IGRstat VDtrget_nodePath(TGRid *nodeID, IGRchar *path)
{
  VDASSERT_FN("VDtrget_nodePath");
  IGRstat  retFlag = 0;
  IGRint   nodeClass;
  TGRid    treeID;
  IGRchar  newVDatPath[80];

  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  // must have a nodeID
  VDASSERTW(nodeID);
  VDASSERTW(path);
  if(nodeID->objid == NULL_OBJID) goto wrapup;

  // init
  path[0] = '\0';
  newVDatPath[0] = '\0';


  // get the class
  vd$trget_class( nodeID = nodeID,
                  class  = &nodeClass );

  // get the VDatBase data
  if (nodeClass == VDTR_CLASS_VDAT) {
    retFlag = VDatGetNodePath( nodeID, path );
    // clip in the new path stuff
    if(retFlag) {
      VDctxGetTree(nodeID,&treeID);

      sprintf(newVDatPath,"AST:%s|%d:%d",path,treeID.objid,nodeID->objid);
      strcpy(path,newVDatPath);
    }


    // selection if we want to clip in the AST option commented out for now
    //if(retFlag > 0) sprintf(path"AST|%s",path);
  }


  // get the VDct1Base data
  if (nodeClass == VDTR_CLASS_VDCT1) {
    retFlag = VDtrget_vdct1NodePath(nodeID,path );
  }



wrapup:
  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d Path: [%s]\n",ffn(),fn,retFlag,path);
  }
  return retFlag;
}

/***********************************************
 * get the ancestry right
 * This is primarily of local use inside the tools
 * Could be used outside if user uses the
 * defined types for the classes
 ***********************************************/
IGRstat VDtrget_class(TGRid *nodeID, IGRint *class)
{
  VDASSERT_FN("VDtrget_class");
  IGRstat retFlag = 0;

  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  // args check
  if(nodeID) {
    if(nodeID->objid == NULL_OBJID) goto wrapup;
  }

  if((!nodeID) ||
     (!class))           goto wrapup;

  // init
  *class = VDTR_CLASS_NONE;
  // if a nodeID is sent in
  if(nodeID != NULL) {

    // Based on type VDATBASE
    if(vdobj$IsAncestryValid(objID          = nodeID,
			     superClassName = "VDatBase")) {
      *class = VDTR_CLASS_VDAT;
      retFlag = 1;
    }
    // Based on type VDCT1BASE
    if(vdobj$IsAncestryValid(objID          = nodeID,
			     superClassName = "VDct1Base")) {
      *class = VDTR_CLASS_VDCT1;
      retFlag = 1;
    }
  }

wrapup:
  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/***********************************************************
 * Get the treeID
 * Input  *setID
 * output *treeID
 ***********************************************************/
IGRstat VDtrget_setTree(TGRid *setID, TGRid *treeID)
{
  VDASSERT_FN("VDtrget_setTree");
  IGRstat       retFlag = 0;
  IGRint        class;
  TGRid         nodeID;

    // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  // Arg check
  VDASSERTW(setID);
  if(setID->objid == NULL_OBJID) goto wrapup;

  // init
  treeID->objid = NULL_OBJID;


  // get the ancestry info
  vd$trget_class(nodeID = setID,
		 class  = &class);

  // get the VDatBase data
  if (class == VDTR_CLASS_VDAT) {
    if(traceFlag) printf("class == VDTR_CLASS_VDAT\n");
    VDatGetTree( setID, treeID );
  }
  // get the VDct1Base data
  if (class == VDTR_CLASS_VDCT1) {
    if(traceFlag) printf("class == VDTR_CLASS_VDCT1\n");
    VDctxGetTree(setID,&nodeID);
    //vdct1$GetMgrChild(objID = setID,
    // outID = &nodeID);
    treeID->objid = nodeID.objid;
    treeID->osnum = nodeID.osnum;
  }

  if(treeID->objid != NULL_OBJID) retFlag = 1;

wrapup:
  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }

  return retFlag;
}

/***********************************************************
 * Get the nodeType
 * Input  *nodeID
 * output *nodeType
 ***********************************************************/
IGRstat VDtrget_nodeType(TGRid *nodeID, IGRchar *nodeType)
{
  VDASSERT_FN("VDtrget_nodeType");
  IGRstat       retFlag = 0;
  IGRint        nodeClass;
  IGRchar       lookUp[128];
  TVDctxBaseInfo baseInfo;

    // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  // Arg check
  VDASSERTW(nodeID);
  if(nodeID->objid == NULL_OBJID) goto wrapup;

  // init
  strcpy(lookUp,"");
  strcpy(nodeType,lookUp);

  // get the ancestry info
  vd$trget_class(nodeID = nodeID,
		 class  = &nodeClass);

  // get the VDatBase data
  if (nodeClass == VDTR_CLASS_VDAT) {
    VDatGetNodeType( nodeID, lookUp );
  }
  // get the VDct1Base data
  if (nodeClass == VDTR_CLASS_VDCT1) {
    VDctxGetBaseInfo(nodeID,&baseInfo);
      strcpy(lookUp,baseInfo.nodeType);
  }

  if(strcmp(lookUp,"")) {
    strcpy(nodeType,lookUp);
    retFlag = 1;
  }

wrapup:
  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }

  return retFlag;
}

/***********************************************************
 * Get the nodeName
 * Input  *nodeID
 * output *nodeName
 ***********************************************************/
IGRstat VDtrget_nodeName(TGRid *nodeID, IGRchar *nodeName)
{
  VDASSERT_FN("VDtrget_nodeName");
  IGRstat        retFlag = 0;
  IGRint         nodeClass;
  IGRchar        lookUp[128];
  TVDctxBaseInfo baseInfo;

    // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  // Arg check
  VDASSERTW(nodeID);
  if(nodeID->objid == NULL_OBJID) goto wrapup;

  // init
  strcpy(lookUp,"");
  strcpy(nodeName,lookUp);

  // get the ancestry info
  vd$trget_class(nodeID = nodeID,
		 class  = &nodeClass);

  // get the VDatBase data
  if (nodeClass == VDTR_CLASS_VDAT) {
    VDatGetNodeName( nodeID, lookUp );
  }
  // get the VDct1Base data
  if (nodeClass == VDTR_CLASS_VDCT1) {
    VDctxGetBaseInfo(nodeID,&baseInfo);
    strcpy(lookUp,baseInfo.nodeName);
  }

   if(strcmp(lookUp,"")) {
    strcpy(nodeName,lookUp);
    retFlag = 1;
  }

wrapup:
  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }

  return retFlag;
}
/***********************************************************
 * Get the setType
 * Input  *nodeID
 * output *setType
 ***********************************************************/
IGRstat VDtrget_setType(TGRid *nodeID, IGRchar *setType)
{
  VDASSERT_FN("VDtrget_setType");
  IGRstat       retFlag = 0;
  IGRint        nodeClass;
  IGRchar       lookUp[128];
  TVDctxBaseInfo baseInfo;

    // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  // Arg check
  VDASSERTW(nodeID);
  if(nodeID->objid == NULL_OBJID) goto wrapup;
  // init
  strcpy(lookUp,"");
  strcpy(setType,lookUp);

  // get the ancestry info
  vd$trget_class(nodeID = nodeID,
		 class  = &nodeClass);

  // get the VDatBase data
  if (nodeClass == VDTR_CLASS_VDAT) {
        VDatGetSetType( nodeID, lookUp );
  }
  // get the VDct1Base data
  if (nodeClass == VDTR_CLASS_VDCT1) {
    VDctxGetBaseInfo(nodeID,&baseInfo);
    strcpy(lookUp,baseInfo.setType);
  }

   if(strcmp(lookUp,"")) {
    strcpy(setType,lookUp);
    retFlag = 1;
  }

wrapup:
  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }

  return retFlag;
}

/***********************************************************
 * Get the setName
 * Input  *nodeID
 * output *setName
 ***********************************************************/
IGRstat VDtrget_setName(TGRid *nodeID, IGRchar *setName)
{
  VDASSERT_FN("VDtrget_setName");
  IGRstat       retFlag = 0;
  IGRint        nodeClass;
  IGRchar       lookUp[128];
  TVDctxBaseInfo baseInfo;

    // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  // Arg check
  VDASSERTW(nodeID);
  if(nodeID->objid == NULL_OBJID) goto wrapup;
  // init
  strcpy(lookUp,"");
  strcpy(setName,lookUp);

  // get the ancestry info
  vd$trget_class(nodeID = nodeID,
		 class  = &nodeClass);

  // get the VDatBase data
  if (nodeClass == VDTR_CLASS_VDAT) {
        VDatGetSetName( nodeID, lookUp );
  }
  // get the VDct1Base data
  if (nodeClass == VDTR_CLASS_VDCT1) {
    VDctxGetBaseInfo(nodeID,&baseInfo);
    strcpy(lookUp,baseInfo.setName);
  }

    if(strcmp(lookUp,"")) {
    strcpy(setName,lookUp);
    retFlag = 1;
  }

wrapup:
  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }

  return retFlag;
}

/****************** Currently Not Used ***************
 * Needs fixed to handle both mgrID's if used
 *****************************************************/

// get the manager
IGRstat VDtrget_manager(TGRid *nodeID,TGRid *mgrID,IGRint *nodeClass)
{
  VDASSERT_FN("VDtrget_manager");
  IGRstat retFlag = 0;

  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  // arg check
  if((!nodeClass) && (!nodeID)) goto wrapup;
  // nodeID and class are optional to determine class but if type is not
  // selected it will default to find the a VDat manager
  // if the VDat manager is not found it will then find a VDct1 manager
  vd$trget_class(nodeID = nodeID,
		 class  = nodeClass);
  // always default to the selected class if one is stated
  if(nodeClass) {
    if(nodeClass && VDTR_CLASS_VDAT) {
      vdat$GetSetMgr(mgrID = mgrID);
    }
    if(nodeClass && VDTR_CLASS_VDCT1) {
      vdct1$GetManager(mgrID = mgrID);
    }
  }
  if (mgrID->objid == NULL_OBJID) goto wrapup;

  // success
  retFlag = 1;

wrapup:
  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/* -------------------------------------------------*/
/************************************************
 * Generic routine to get all trees by type  or *
 * an individual tree based upon a treeName  or *
 * based upon treeType and treeName             *
 * don't specify either and all sets included   *
 * wrapper for VDtrget_treeList                 *
 * MEMORY ALLOCATED     **treeID                *
 ************************************************/

IGRstat VDtrget_trees(IGRchar *treeType,
		      IGRchar *treeName,
		      IGRint  *nodeClass,
		      IGRint  active_file,
		      TGRid   **treeID,
		      IGRint  *cnt)
{
  VDASSERT_FN("VDtrget_trees");
  IGRstat         retFlag = 0;
  IGRstat         i,j;
  TGRid           nodeID;
  IGRchar         tType[128],tName[128];


  // say hi
  if(traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
    if(treeType) printf("treeType [%s]\n",treeType);
    if(treeName) printf("treeName [%s]\n\n",treeName);
  }
  *treeID = NULL;

  if (!cnt)                  goto wrapup;
  *cnt = 0;
   if (!treeID)              goto wrapup;

  if ((active_file > 1) ||
      (active_file < 0))     goto wrapup;


  if(((!treeType) &&
      (!treeName)) &&
     (!nodeClass))           goto wrapup;


  if((!treeType) && (!nodeClass)) {
    *cnt = 0;
    goto wrapup;
  }

  if(traceFlag) printf("passed null checks\n");

  *cnt = 0;
  tType[0] = '\0';
  tName[0] = '\0';
  if(treeType) strcpy(tType,treeType);
  if(treeName) strcpy(tName,treeName);
  VDstrupr(tType);
  VDstrupr(tName);

  // get the count of trees
  vd$trget_treeList(treeType  = tType,
		    treeName  = tName,
		    class     = nodeClass,
		    cnt       = cnt);

  if(*cnt == 0) {
    retFlag = 1;
    goto wrapup;
  }

  // allocate the  memory
  if(*cnt >0) {

    if( !( *treeID = _MALLOC( ((*cnt) + 1), TGRid )))
    {
      goto wrapup;
    }
  }
  // get the tree list
  vd$trget_treeList(treeType = tType,
		    treeName = tName,
		    class    = nodeClass,
		    treeID   = treeID,
		    cnt      = cnt);
  if(traceFlag) printf("** count of trees is [%d]\n",*cnt);
  if(*cnt >0) {
    for(i = 0;i < *cnt;i++){
      nodeID = (*treeID)[i];
          if(traceFlag) vd$trget_getNodePrint(nodeID = &nodeID,
					title = "Report Loop");

    }

  }


  // filter the list for active trees or reference file trees
  for (i = 0; i < *cnt; i++){
    if(traceFlag) printf("inside the tree filter loop1\n");

    nodeID = (*treeID)[i];
// apply the appropriate filter
    if(traceFlag) printf("inside the tree filter loop1.1\n");
    if(traceFlag) vd$trget_getNodePrint(nodeID = &nodeID,
					title = "NODE TO TEST");

    if(((nodeID.osnum == 2) && (active_file == 0)) ||
       ((nodeID.osnum != 2) && (active_file == 1))) {

    if(traceFlag) vd$trget_getNodePrint(nodeID = &nodeID,
					title = "NODE TO PULL OUT");
      if(traceFlag) printf("pulling out a node\n");

      // move the pointers over in the list
      for(j = i;j < (*cnt - 1);j++) {
    if(traceFlag) printf("inside the tree filter loop1.2\n");
    nodeID = (*treeID)[j];
    if(traceFlag) vd$trget_getNodePrint(nodeID = &nodeID,
					title = "NODE TO BE DELETED");
    nodeID = (*treeID)[j+1];
    if(traceFlag) vd$trget_getNodePrint(nodeID = &nodeID,
					title = "NODE TO REPLACE");
	*treeID[j] = *treeID[j+1];
    if(traceFlag) printf("inside the tree filter loop1.3\n");
      }
      // change the increments
      i--;
      *cnt = *cnt -1;
      if(traceFlag) printf("the ** count of trees is [%d]\n",*cnt);

    }
  }

  if(cnt) {
    if(traceFlag) printf("inside the tree filter loop2\n");
    if(*cnt == 0) {
      _FREE( *treeID);
    }
    
    if(traceFlag) printf("inside the tree filter loop2.1\n");
  }
  retFlag = 1;
  // oh well
wrapup:

  if(traceFlag)    printf("<<< %s %s %d [%d]\n",ffn(),fn,retFlag,*cnt);
  return retFlag;

}

/************************************************
 * Generic routine to get a specific node       *
 * selects based upon nodeName and nodeType     *
 * optional start at a node and search for  the *
 * node below a nodeID                          *
 ************************************************/
IGRstat VDtrget_node(IGRchar *nodeType,
		     IGRchar *nodeName,
		     TGRid   *nodeID,
		     TGRid   **outID,
		     IGRint  active_file,
		     IGRint  *cnt)
{
  VDASSERT_FN("VDtrget_node");
  IGRstat retFlag  = 0;
  IGRint  selectionClass;
  TGRid   *vdatIDs, *vdct1IDs, *nodeIDs, treeID;
  IGRint  vdatCount, vdct1Count, nodeCount;
  IGRint  i,j,k;
  IGRchar nType[128], nName[128], buf[128];


  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  // args checks
  if(!nodeName)            goto wrapup;
  if((!nodeType) &&
     (!nodeID))            goto wrapup;
  if(!outID)               goto wrapup;
  if(!cnt)                 goto wrapup;
  if(nodeID->objid == NULL_OBJID) goto wrapup;
  // must have a nodeID go get a set of treeIDs if there is not one
  if(!nodeID) {
    selectionClass = VDTR_CLASS_VDAT;
    // vdat class getting trees
    if(traceFlag) printf("Getting the VDatBase Trees\n");

    vd$trget_trees(class         = &selectionClass,
		   treeID        = &vdatIDs,
		   active_file   = active_file,
		   cnt           = &vdatCount);
      // loop through the list and get any
    for(i = 0;i < vdatCount;i++) {
	treeID = vdatIDs[i];
	if(traceFlag) {
	  strcpy(buf,"Trees List VDAT");
	  printf("Printing out the list of trees\n\n");
	  vd$trget_getNodePrint(nodeID = &treeID,
				title = buf);
	}

	// get the tree data
	vd$trget_nodeInfo(nodeType = nType,
			  nodeName = nName,
			  nodeID   = &treeID);
	  if(traceFlag) printf("TreeID VDAT [%s] [%s]\n",nType,nName);

	  // if the tree matches
	if(vdatCount) {
	  if((!strcmp(nType,nodeType)) && (!strcmp(nName,nodeName))){
	    outID[0] = &treeID;
	    *cnt = 1;
	    retFlag = 1;
	    goto wrapup;
	  }
	}
	vd$trget_nodes(nodeType    = nodeType,
		       nodeName    = nodeName,
		       nodeID      = &treeID,
		       lookupType  = VDTR_FIND_ALL_NODE,
		       active_file = active_file,
		       outID       = outID,
		       cnt         = cnt);
	if(*cnt < 0) {
	  retFlag = 1;
	  _FREE ( outID );
	  goto wrapup;
	}
	if(vdatCount) _FREE (vdatIDs);
      }

VDCT1:

      selectionClass = VDTR_CLASS_VDCT1;
      // vdat class getting trees
      vd$trget_trees(class         = &selectionClass,
		     treeID        = &vdct1IDs,
		     active_file   = active_file,
		     cnt           = &vdct1Count);


      if(vdct1Count){
	// loop through the list and get any
	for(i = 0;i < vdct1Count;i++){
	  treeID = vdct1IDs[i];
	  if(traceFlag) {
	    strcpy(buf,"Trees List VDCT1");
	    printf("Printing out the list of trees\n\n");
	    vd$trget_getNodePrint(nodeID = &treeID,
				  title = buf);
	  }
	  if(traceFlag) vd$trget_getNodePrint(nodeID = &treeID,
					      title = "treeID check");
	  // get the tree data
	  vd$trget_nodeInfo(nodeType = nType,
			    nodeName = nName,
			    nodeID   = &treeID);
	  if(traceFlag) printf("TreeID VDCT1 [%s] [%s]\n",nType,nName);

	  if(vdct1Count) {
	    if((!strcmp(nType,nodeType)) && (!strcmp(nName,nodeName))){
	      (outID)[0] = &treeID;
	      *cnt = 1;
	      goto wrapup;
	    }
	  }
	  treeID = vdct1IDs[i];
	  vd$trget_nodes(nodeType    = nodeType,
			 nodeName    = nodeName,
			 nodeID      = &treeID,
			 lookupType  = VDTR_FIND_ALL_NODE,
			 active_file = active_file,
			 outID       = outID,
			 cnt         = cnt);
	  if(*cnt < 1) {
	    _FREE (outID);
	    retFlag = 1;
	    goto wrapup;
	  }
	}
      }
  }
  else // we had a node to start with
  {
    vd$trget_nodes(nodeType    = nodeType,
		   nodeName    = nodeName,
		   nodeID      = nodeID,
		   lookupType  = VDTR_FIND_ALL_NODE,
		   active_file = active_file,
		   outID       = outID,
		   cnt         = cnt);
    if(*cnt < 1) {
      _FREE (outID);
    }
  }

  retFlag = 1;

wrapup:
  if(vdct1Count) _FREE (vdct1IDs);
  if(vdatCount) _FREE (vdatIDs);
  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/************************************************
 * Generic routine to get all trees by type  or *
 * an individual tree based upon a treeName  or *
 * based upon treeType and treeName             *
 * don't specify either and all sets included   *
 * MEMORY NOT ALLOCATED **treeID                *
 ************************************************/

IGRstat VDtrget_treeList(IGRchar *treeType,
			 IGRchar *treeName,
			 IGRint  *nodeClass,
			 TGRid   **treeID,
			 IGRint  *cnt)
{
  VDASSERT_FN("VDtrget_treeList");
  IGRstat         retFlag = 0;
  TGRid           mgrID, setID,setsID, setTreeID;
  IGRint          sts, i;
  TVDctxBaseInfo  baseInfo;
  TVDvlaID        setVLA;
  TVDtrSetInfo    set;
  IGRchar         tType[128],tName[128];
  IGRint          selection;

  // say hi
  if(traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
    if(treeType) printf("treeType [%s]\n",treeType);
    if(treeName) printf("treeName [%s]\n\n",treeName);
  }


   *cnt = 0;
  // args and control check
  if(!cnt)                  goto wrapup;

  if(((!treeType) &&
      (!treeName)) &&
     (!nodeClass) &&
     (!treeID))             goto wrapup;

  selection = VDTR_CLASS_NONE;
  if(nodeClass) selection = *nodeClass;
  tType[0] = '\0';
  tName[0] = '\0';
  if(treeType) strcpy(tType,treeType);
  if(treeName) strcpy(tName,treeName);
  VDstrupr(tType);
  *cnt = 0;

  if((selection == VDTR_CLASS_NONE) || (selection == VDTR_CLASS_VDAT)) {
    // get the AT manager
    vdat$GetSetMgr(mgrID = &mgrID);
    if (mgrID.objid != NULL_OBJID) {
      // Get a list of sets
      VDatGetSets(&mgrID,&setsID);
      if (setsID.objid != NULL_OBJID) {
	// Cycle Through
	for(i = 0; VDatGetChildObject(&setsID,i,&setID); i = i + 1) {
	  // Need set name, type and description
	  VDatGetSetName(&setID,set.name);
	  VDatGetSetType(&setID,set.type);
	  VDstrupr(set.type);
	  VDstrupr(set.name);

	    // select by type
	    if((strcmp(tType,""))  && (!strcmp(tName,""))) {
	      if(!strcmp(set.type,treeType)) {
		// ok set it up
		if(treeID) (*treeID)[*cnt] = setID;
		*cnt = *cnt + 1;
	      }
	    }
	    // select by name
	    if((!strcmp(tType,""))  && (strcmp(tName,""))) {
	      if(!strcmp(set.name,treeName)) {
		// ok set it up
		if(treeID) (*treeID)[*cnt] = setID;
		*cnt = *cnt + 1;
	      }
	    }
	    // individual type and name
	    if((strcmp(tType,""))  && (strcmp(tName,""))) {
	      if((!strcmp(set.name,treeName)) &&
	       (!strcmp(set.type,treeType))) {
		// ok set it up
		if(treeID) (*treeID)[*cnt] = setID;
		*cnt = *cnt + 1;
	      }
	    }



	  // give all trees
	  if((!strcmp(tType,""))  && (!strcmp(tName,"")) && (nodeClass)) {
	    // ok set it up
	    if(treeID) (*treeID)[*cnt] = setID;
	    *cnt = *cnt + 1;
	  }
	}
      }
    }
  }

  //selection = VDTR_CLASS_NONE;
  if((selection ==  VDTR_CLASS_NONE) || (selection == VDTR_CLASS_VDCT1)) {
    // get the VDCT1 manager
    vdct1$GetManager(mgrID = &mgrID);
    if (mgrID.objid != NULL_OBJID) {
      // Cycle through each set
      for(i = 0;VDctxGetNthMgrChild(&mgrID,i,&setID); i++) {
	// for(i = 0; vdct1$GetMgrChild(objID = &mgrID, nth = i, outID = &setID); i++) {

	// get the tree that corresponds to a set
	VDctxGetTree(&setID,&setTreeID);
	//vdct1$GetMgrChild(objID = &setID,
	// outID = &setTreeID);
	// get the baseInfo
        if(setTreeID.objid == NULL_OBJID) continue;
	VDctxGetBaseInfo(&setTreeID,&baseInfo);
	VDstrupr(baseInfo.setType);
	VDstrupr(baseInfo.setName);

	  // select by type
	  if((strcmp(tType,""))  && (!strcmp(tName,""))) {
	    if(!strcmp(baseInfo.setType,treeType)) {
	      // ok set it up
	      if(treeID) (*treeID)[*cnt] = setTreeID;
    	      *cnt = *cnt + 1;
	    }
	  }
	  // select by name
	  if((!strcmp(tType,""))  && (strcmp(tName,""))) {
	    if(!strcmp(baseInfo.setName,treeName)) {
	      // ok set it up
	      if(treeID) (*treeID)[*cnt] = setTreeID;
	      *cnt = *cnt + 1;
	    }
	  }
	  // individual type and name
	  if((strcmp(tType,""))  && (strcmp(tName,""))) {
	    if((!strcmp(baseInfo.setName,treeName)) &&
	       (!strcmp(baseInfo.setType,treeType))) {
	      // ok set it up
	      if(treeID) (*treeID)[*cnt] = setTreeID;
	      *cnt = *cnt + 1;
	    }
	  }
	// give all trees
	if((!strcmp(tType,""))  && (!strcmp(tName,"")) && (nodeClass)) {
	  // ok set it up
	  if(treeID) (*treeID)[*cnt] = setTreeID;
	  *cnt = *cnt + 1;
	}
      }
    }
  }
  retFlag = 1;
  // oh well
wrapup:
#if 0
  if(traceFlag) printf("At Wrapup\n");
  if((treeID) && (traceFlag) ) {
    for(i = 0; i < *cnt;i++){
      if(traceFlag) printf("Printing final treelist\n");
      if(*cnt > 0) {
	if(traceFlag) printf("Printing final ** treelist\n");
	setTreeID = (*treeID)[i];
	if(traceFlag) printf("Printing final * treelist\n");
	if(traceFlag) vd$trget_getNodePrint(nodeID = &setTreeID,
					    title = "Final Treelist");
      }
    }
  }
#endif
  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d [%d]\n",ffn(),fn,retFlag,*cnt);
  }
  return retFlag;
}


/************************************************
 * Generic routine to get all the stages in  a  *
 * tree list and count or by type               *
 * an individual tree by treeName               *
 * MEMORY ALLOCATED  **stages                   *
 ************************************************/

IGRstat VDtrget_stages(IGRchar  *treeType,
		       IGRchar  *treeName,
		       TGRid    *treeID,
		       IGRint   *stageCnt,
		       IGRchar  **stages)

{
    VDASSERT_FN("VDtrget_stages");
    IGRstat		retFlag = 0;
    IGRint		sts, i, j, 
			treeCount	= 0,
			nodeCount	= 0,
			listCnt		= 0,
			found		= 0;
    IGRchar		stageName[VDTR_NODE_NAME_LEN];
    IGRchar		tName[128],tType[128];

    IGRchar		*stageList	= NULL;
    TGRid		*nodeList	= NULL,
			*treeIDs	= NULL,
			tID;

    // say hi
    if (traceFlag) {
	printf(">>> %s %s\n",ffn(),fn);
    }

    // args and control check
    if( !stageCnt && !stages ) 		   goto wrapup ;

    if( stageCnt ) *stageCnt = 0;
    if( stages )   *stages   = NULL;

    if((!treeID) && ((!treeType) || (!treeName))) goto wrapup;

    // init
    tID.objid = NULL_OBJID ;
    tName[0] = '\0';
    tType[0] = '\0';
    if(treeName) strcpy(tName,treeName);
    if(treeType) strcpy(tType,treeType);

    // use the treeName or treeType
    if( treeID && vdtr$IsTreeAncestry( nodeID = treeID ) )
    {
	tID = *treeID ;
    }

    if( tID.objid == NULL_OBJID )
    {
	/*
	 * find the tree by name ...
	 */
	if(treeType && treeName)
	{
	   // get the appropriate tree (may be more than one!) --> that is an error
	   treeCount = 0 ;
	   sts = vd$trget_trees(treeType = tType,
				treeName = tName,
				treeID   = &treeIDs,
				cnt      = &treeCount);
	   // tree not found get out of here
	   if((! sts ) || (treeCount != 1))
	   {
		printf("**** Error VDtrTools.I->VDtrget_stages tree not found ****\n");
		goto wrapup;
	   }

	   // update tID with the treeIDs[0]
	   tID = treeIDs[0];
	   _FREE (treeIDs);
	}
    }  // tID is now set!

    if( tID.objid == NULL_OBJID ) goto wrapup;

    VDctxGetNodeType(&tID, stageName);
    if( !( stageList  = _MALLOC( (VDTR_NODE_NAME_LEN), IGRchar  ))) goto wrapup;
    strcpy( stageList, stageName);
    listCnt++;

    vd$trget_nodes (	nodeID       = &tID,
			lookupType   = VDTR_FIND_ALL,
			outID        = &nodeList,
			cnt          = &nodeCount);
    if( !nodeList ) nodeCount = 0;

    // cycle through the nodes!
    for(i = 0; i < nodeCount; i++)
    {
	if(nodeList[i].objid == NULL_OBJID) continue;

	VDctxGetNodeType(&nodeList[i],stageName);

	// check if there are stages in the list
	found = 0;
	for(j = 0; j < listCnt; j++)
	{
	    if(!strcmp(stageList + j*VDTR_NODE_NAME_LEN, stageName))
	    {
		found = 1;
		break;
	    }
	}

	// allocate the memory
	if(!found)
	{
	    stageList = 
	    _REALLOC(stageList, (listCnt+1)*VDTR_NODE_NAME_LEN, IGRchar);
	    if( !(stageList) ) goto wrapup;

	    strcpy(stageList + listCnt*VDTR_NODE_NAME_LEN, stageName);
	    listCnt++;
	}
    }

    if( stageCnt )	*stageCnt = listCnt;
    if( stages )	*stages = stageList;

    // success
    retFlag = 1;

wrapup:

    // say bye
    if (traceFlag)
    {
	printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    }
    _FREE (treeIDs);
    _FREE (nodeList);
    if( !stages ) _FREE( stageList );
    return retFlag;
}

/****************************************************************************
 * Filter out node if its frozen matches status
 * 
 ****************************************************************************/
IGRstat	VDtrFilterFrozenNode( TGRid **nodeIDs, IGRint *cnt )
{
  IGRstat       retFlag = 0;
  IGRstat       sts;
  IGRint	nodeCnt = 0, i, j;
  Tret_struct   rs;

  if( !nodeIDs || !(*cnt) ) goto wrapup;

  nodeCnt = *cnt;
  for( i = 0; i < nodeCnt;  )
  {
    sts = vdsa$GetStruct( objID = &(*nodeIDs)[i], name = "frozen", rs = &rs);
    if( (sts & 1) && !strcmp( rs.var.text_st.text_string, "DELETED" ) )
    {
       for( j = i; j < nodeCnt-1; j++ ) (*nodeIDs)[j] = (*nodeIDs)[j+1];
       nodeCnt--;
    }
    else i++;
  }

  if( nodeCnt < 1 )
  {
     *cnt = 0;
     _FREE( *nodeIDs );
  }
  else *cnt = nodeCnt;

  retFlag = 1;

wrapup:
  return retFlag;
}

/************************************************
 * Generic routine to get ParentID or children  *
 * for a node, or a specific child node         *
 * given a specific starting node               *
 * MEMORY ALLOCATED by called routine  applies  *
 * to **outID                                   *
 ************************************************/

IGRstat VDtrget_nodes(IGRchar *nodeType,
		      IGRchar *nodeName,
		      TGRid   *nodeID,
		      IGRint  lookupType,
		      IGRint  frozen,
		      IGRint  active_file,
		      TGRid   **outID,
		      IGRint  *cnt)
{
  VDASSERT_FN("VDtrget_nodes");
  IGRstat        retFlag = 0;
  IGRint         i,j,k,zz;
  TGRid          testID;
  TVDctxBaseInfo baseInfo;
  IGRchar        buf[128],tName[128];

  // say hi
  if(traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
    if(nodeType) printf("nodeType: [%s]\n", nodeType);
  }

  // args and control check
  if((!nodeID) &&
     (!nodeType) &&
     (!nodeName))               goto wrapup;
  if(outID == NULL)             goto wrapup;
  if(!cnt)                      goto wrapup;
  if(!nodeID)                   goto wrapup;
  if(nodeID->objid == NULL_OBJID) goto wrapup;


#if 0
  if(traceFlag) {
    if(!nodeType) printf("no nodeType entered\n");
    if(nodeType)  printf("Entered [%s] nodeType\n",nodeType);

    if(!nodeName) printf("no nodeName entered\n");
    if(nodeName)  printf("Entered [%s] nodeName\n",nodeName);

    if(nodeID)  printf("nodeID is [%d] [%d]\n",nodeID->osnum,nodeID->objid);
    if(lookupType == VDTR_FIND_ALL)         printf("Lookup is VDTR_FIND_ALL\n");
    // finds all child nodes based on set  type or name
    if(lookupType == VDTR_FIND_CHILD)       printf("Lookup is VDTR_FIND_CHILD\n");
    // finds direct child nodes based on set  type or name
    if(lookupType == VDTR_FIND_ALL_NODE)    printf("Lookup is VDTR_FIND_ALL_NODE\n");
    // finds all child nodes based on node type or name
    if(lookupType == VDTR_FIND_CHILD_NODE)  printf("Lookup is VDTR_FIND_CHILD_NODE\n");
    // finds direct child nodes based on node type or name
    if(lookupType == VDTR_FIND_PARENT)      printf("Lookup is VDTR_FIND_PARENT\n");
    // finds the parent of a node
    if(lookupType == VDTR_FIND_TREE)        printf("Lookup is VDTR_FIND_TREE\n");
    // finds the tree of a node
  }
#endif
  *cnt = 0;
  // get the count
  if(nodeType){

    if(traceFlag) printf("nodeID[%d][%d] [%s]\n",nodeID->osnum,nodeID->objid,nodeType);
  }


  vd$trget_treeNodeList(nodeID   = nodeID,
			type     = nodeType,
			lookup   = lookupType,
			cnt      = cnt);
     if(traceFlag) printf("the Initial count is [%d]******\n",*cnt);
  // no nodes no allocation of memory
  if(*cnt == 0) goto wrapup;
  /******************** Important! ***************
   * if this location _MALLOC fails
   * the reason is not the syntax of the command
   * the reason is that the calling item is
   * incorrect **Poiner
   * outID should be called with *Pointer
   * outID should be referenced by &Pointer
   ***********************************************/
  // allocate the memory here
  //  if(traceFlag) printf("Tools: loc #1a1\n");
  *outID = NULL;
  *outID = _MALLOC( ((*cnt) +1) , TGRid );
  //  if(traceFlag) printf("Tools: loc #1a2\n");
  if((*outID) == NULL)
  {
    goto wrapup;
  }
 // get the list
  *cnt = 0;
  vd$trget_treeNodeList( nodeID   = nodeID,
			 type     = nodeType,
			 nodeList = outID,
			 lookup   = lookupType,
			 cnt      = cnt);

  if( frozen )
  {
    VDtrFilterFrozenNode( outID, cnt );
  }

#if 0
   if(traceFlag) printf("the FINAL count is [%d]******\n",*cnt);
	if(*cnt > 0) {
	  if(traceFlag) {
	    for(zz = 0; zz < *cnt; zz++){
	      testID = (*outID)[zz];
	      sprintf(buf,"INitial Trial List Results (%d)",zz);

	      vd$trget_getNodePrint(nodeID = &testID,
				    title = buf);
	    }
	  }
	}
#endif
  // test the count
  if(*cnt < 1) {
    retFlag = 1;
    goto wrapup;
  }

  // go home if there is no nodeName to check
  if((!nodeName) ||(!strcmp(nodeName,"")))  {
    retFlag = 1;
    goto wrapup;
  }
  // check the nodeName
  for(i = 0;i < *cnt;i++) {
    testID = (*outID)[i];
    // Based on type VDatBase
    if(vdobj$IsAncestryValid(objID          = &testID,
			     superClassName = "VDatBase")) {
      // Need set name, type and description
      strcpy(tName,"");
      if((lookupType == VDTR_FIND_ALL) ||
	 (lookupType == VDTR_FIND_CHILD)) VDatGetSetName(&testID,tName);
      if((lookupType  == VDTR_FIND_ALL_NODE) ||
	 (lookupType == VDTR_FIND_CHILD_NODE)) VDatGetNodeName(&testID,tName);
    }
    if(vdobj$IsAncestryValid(objID          = &testID,
			     superClassName = "VDct1Base")) {
      // get the baseInfo
      VDctxGetBaseInfo(&testID,&baseInfo);
      // Need set name, type and description
      strcpy(tName,"");
      if((lookupType == VDTR_FIND_ALL) ||
	 (lookupType == VDTR_FIND_CHILD)) strcpy(tName,baseInfo.setName);
      if((lookupType  == VDTR_FIND_ALL_NODE) ||
	 (lookupType == VDTR_FIND_CHILD_NODE)) strcpy(tName,baseInfo.nodeName);
    }
    if(strcmp(tName,nodeName)) {
      // yank it from the list
      for(j = i;j < (*cnt - 1);j++) {
	k = j + 1;
	(*outID)[j] = (*outID)[k];
      }
      // increment the count down by 1:
      *cnt = *cnt - 1;
      i = i - 1;
      // if count is 0  goto wrapup
      if(*cnt == 0) {
	retFlag = 0;
	_FREE (outID);
	goto wrapup;
      }
    }
  } // end of count looping
  // success
  retFlag = 1;

  // oh well
wrapup:
  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}


/************************************************
 * Generic routine to get the NodeName &  Type  *
 * for a specific node and some stats           *
 ************************************************/

IGRstat VDtrget_nodeInfo(IGRchar *nodeType,  // 0 -
			 IGRchar *nodeName,  // 0 -
                         IGRchar *setType,   // O -
                         IGRchar *setName,   // O -
			 TGRid   *nodeID,    // I -
			 IGRchar *path,      // 0 -
                         IGRchar *fullPath)  // 0 -
{
  VDASSERT_FN("VDtrget_nodeInfo");
  IGRstat        retFlag = 0;
  IGRint         sts;
  IGRint         selection;
  TVDctxBaseInfo baseInfo;
  IGRchar        localPath[80],clipPath[80],*p;

  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  /* inits */
  localPath[0] = '\0';
  clipPath[0]  = '\0';
  if(setType)  setType[0]   = '\0';
  if(setName)  setName[0]   = '\0';
  if(nodeType) nodeType[0]  = '\0';
  if(nodeName) nodeName[0]  = '\0';
  if(path)     path[0]      = '\0';
  if(fullPath) fullPath[0]  = '\0';

  // args and control check
  if(nodeID) {
    if(nodeID->objid == NULL_OBJID) goto wrapup;
  }

  VDASSERTW(nodeID);
  if((!nodeType) &&
     (!nodeName) &&
     (!setType) &&
     (!setName) &&
     (!fullPath) &&
     (!path))            goto wrapup;

  /* get the basic info */
  if((nodeType) || (nodeName) || (setType) || (setName)) {
    VDctxGetBaseInfo(nodeID,&baseInfo);
    if(!strcmp(baseInfo.nodeType,"")) goto wrapup;

    if(nodeType) strcpy(nodeType,baseInfo.nodeType);
    if(nodeName) strcpy(nodeName,baseInfo.nodeName);
    if(setType) strcpy(setType,baseInfo.setType);
    if(setName) strcpy(setName,baseInfo.setName);
    retFlag = 1;
  }

  /* get the path  */
  if((!path) && (!fullPath)) goto wrapup;
  vdtr$GetNodePath(nodeID = nodeID,
                   path   = localPath);

  if(traceFlag) printf("localPath is [%s]\n",localPath);

  if(!strcmp(localPath,"")) {
    if(traceFlag)printf("Went wrapup; no localPath\n");
    goto wrapup;
  }

  retFlag = 1;
  if(fullPath) strcpy(fullPath,localPath);
  if(path) {
    /* clip out the path */
    vdtr$GetDelimitedStr(impStr = localPath,
                         outStr = clipPath,
                         delChr = '|',
                         posStr = 1);
    if(traceFlag) printf("clipPath = [%s]\n",clipPath);

    /* if it is old path design send it along */
    if(!strcmp(localPath,clipPath)) {
      if(path) strcpy(path,localPath);
      retFlag = 1;
      goto wrapup;
    }
    /* if it is new path design clip off 4 spaces and send it out */
    p = clipPath;
    p = p + 4;
    strcpy(path,p);
  }
  // oh well
  retFlag = 1;
wrapup:
  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}


/************************************************
 * Generic routine find all child nodes         *
 * a specific node                              *
 * has available a filter for only nodes of a   *
 * specific setType  (specific tree type)       *
 * Also can find the Parent of a specific node  *
 * also can find treeID for a specific node     *
 * MEMORY IS NOT ALLOCATED **nodeList           *
 ************************************************/
IGRstat	VDtrget_treeNodeList (TGRid		*nodeID,
			      IGRchar		*type,
			      TGRid		**nodeList,
			      IGRint            lookup,
			      IGRint		*cnt)
{
  VDASSERT_FN("VDtrget_treeNodeList");
  TGRid             childID, parentID, treeID, mgrID, setID;
  IGRint            i, selection;
  IGRstat           retFlag = 0;
  IGRstat           typeFilter = 0;
  IGRstat           nameFilter = 0;
  TVDctxBaseInfo    baseInfo;
  IGRchar           selType[128];
  IGRchar           selName[128];
  TVDatRDBNodeInfo  vdatNodeInfo;


  // say hi
  if(traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
    printf(">>> VDtrget_treeNodeList[lookup = %d][cnt = %d]\n",lookup,*cnt);
    printf("type = [%s]\n",type);
  }

    // args check
  if(!nodeID)            goto wrapup;
  if(nodeID->objid == NULL_OBJID) goto wrapup;
  if(!cnt)               goto wrapup;

  // Based on type
  if(vdobj$IsAncestryValid(objID          = nodeID,
			   superClassName = "VDatBase")) {
    // get the node's setType and nodeType (VDatBase class) names too
    VDatRDBGetNodeInfo(nodeID, &vdatNodeInfo);
    strcpy(selType,vdatNodeInfo.setType);
    // Get the selection started
    selection = lookup;
      // change the type selector item
    if((lookup == VDTR_FIND_CHILD_NODE) || (lookup == VDTR_FIND_ALL_NODE)) {
      // Bring in  the (selType) from the node
      strcpy(selType,vdatNodeInfo.nodeType);
    }
    if(type) {
      if(traceFlag) printf("setting selType to type\n\n");

      strcpy(selType,type);
    }


   if(traceFlag) printf("the selType in VDtrget_treeNodelist is [%s]\n",selType);
    // Selection below is based upon nodeType or setType if present
    // selects only the directly dependent kids
    // ****************** get one layer of kids  *************************
    if((selection == VDTR_FIND_CHILD) || (selection == VDTR_FIND_CHILD_NODE)) {
      // get the kids directly below
      for(i = 0;VDatGetChildObject(nodeID,i,&childID);i++) {
        // filter out the ACpretends and ACpretendins
        if(vdobj$IsAncestryValid(objID          = &childID,
                                 superClassName = "ACpretend")) continue;
        if(vdobj$IsAncestryValid(objID          = &childID,
                                 superClassName = "ACpretendin")) continue;

        // if there is a filter
	if(type) {
	  VDatRDBGetNodeInfo(&childID, &vdatNodeInfo);
	  strcpy(selType,vdatNodeInfo.setType);
	  if(lookup == VDTR_FIND_CHILD_NODE) strcpy(selType,vdatNodeInfo.nodeType);
	  // the filter is ok
	  if(!strcmp(selType,type)) {
	    // load up the node
	    if(nodeList) (*nodeList)[*cnt] = childID;
	    // increment the count
	    *cnt = *cnt + 1;
	  }
	}
	// there is no filter
	else
	{
	  // load up the node
	  if(nodeList) (*nodeList)[*cnt] = childID;
	  // increment the count
	  *cnt = *cnt + 1;
	}
      }
    }

    // Selection below is based upon nodeType or setType if present
    // get all subordinate nodes
    // ****************** get all of the kids  *************************
    if((selection == VDTR_FIND_ALL) || (selection == VDTR_FIND_ALL_NODE)) {
      // get the kids directly below
      for(i = 0;VDatGetChildObject(nodeID,i,&childID);i++) {
        // filter out the ACpretends and ACpretendins
        if(vdobj$IsAncestryValid(objID          = &childID,
                                 superClassName = "ACpretend")) continue;
        if(vdobj$IsAncestryValid(objID          = &childID,
                                 superClassName = "ACpretendin")) continue;

	// if there is a filter
	if(type) {
	  VDatRDBGetNodeInfo(&childID, &vdatNodeInfo);
	  strcpy(selType,vdatNodeInfo.setType);
	  if(lookup == VDTR_FIND_ALL_NODE) strcpy(selType,vdatNodeInfo.nodeType);
	  // the filter is ok
	  if(!strcmp(selType,type)) {
	    // load up the node
	    if(nodeList) (*nodeList)[*cnt] = childID;
	    // increment the count
	    *cnt = *cnt + 1;
	  }
	}
	// there is no filter
	else
	{
	  // load up the node
	  if(nodeList) (*nodeList)[*cnt] = childID;
	  // increment the count
	  *cnt = *cnt + 1;
	}
	//call myself
	vd$trget_treeNodeList(nodeID   = &childID,
			      type     = type,
			      nodeList = nodeList,
			      lookup   = lookup,
			      cnt      = cnt);
      }
      retFlag = 1;
      goto wrapup;
    }
    // ***************** get the parentID ************************
    if(selection == VDTR_FIND_PARENT) {
      i = 0;
      VDatGetParentObject(nodeID,i,&parentID);
      *cnt = 0;
      // load up the node
      if(nodeList) (*nodeList)[*cnt] = parentID;
      // increment the count
      *cnt = *cnt + 1;
      retFlag = 1;
      goto wrapup;
    }
    // ****************** get the treeID *************************
    if(selection == VDTR_FIND_TREE) {
      VDatGetSet(nodeID, &setID);
      *cnt = 0;
      // load up the node
      if(nodeList) (*nodeList)[*cnt] = setID;
      // increment the count
      *cnt = *cnt + 1;
      retFlag = 1;
      goto wrapup;
    }
    goto wrapup;
  }

  // Based on type
  if(vdobj$IsAncestryValid(objID          = nodeID,
			   superClassName = "VDct1Base")) {
    // get the baseInfo
    VDctxGetBaseInfo(nodeID,&baseInfo);

    // copy it up
    strcpy(selType,baseInfo.setType);
    selection = lookup;

    // change the type selector item
    if((lookup == VDTR_FIND_CHILD_NODE) || (lookup == VDTR_FIND_ALL_NODE)) {
      strcpy(selType,baseInfo.nodeType);
    }
    if(type) strcpy(selType,type);



    // the selection is just the kids below a node
    // ****************** get one layer of kids  *************************
    if((selection == VDTR_FIND_CHILD) || (selection == VDTR_FIND_CHILD_NODE)) {

      // get the kids
      for(i = 0;vdct1$GetTree1Child(objID = nodeID,
				    nth   = i,
				    outID = &childID); i++) {

	// get the baseInfo
	VDctxGetBaseInfo(&childID,&baseInfo);
	if(type) {
	  // set the filter
	  strcpy(selType,baseInfo.setType);
	  if(lookup & VDTR_FIND_CHILD_NODE) {
	    strcpy(selType,baseInfo.nodeType);
	  }
	  // the filter is ok
	  if(!strcmp(selType,type)) {
	    // load up the node
	    if(nodeList) (*nodeList)[*cnt] = childID;
	    // increment the count
	    *cnt = *cnt + 1;
	  }
	}
	// there is no filter
	else {
	  // load up the node
	  if(nodeList) (*nodeList)[*cnt] = childID;
	  // increment the count
	  *cnt = *cnt + 1;
	}
      }
      retFlag = 1;
      goto wrapup;
    }

    // the selection is all the kids below a node
    // by setType if present
    // ****************** get all of the kids  *************************
    if((selection == VDTR_FIND_ALL) || (selection == VDTR_FIND_ALL_NODE)) {
      // get the kids
      for(i = 0;vdct1$GetTree1Child(objID = nodeID,
				    nth   = i,
				    outID = &childID); i++) {

	// get the baseInfo
	VDctxGetBaseInfo(&childID,&baseInfo);
	if(type) {
	  // set the filter
	  strcpy(selType,baseInfo.setType);
	  // change the selector
	  if(lookup & VDTR_FIND_ALL_NODE) {
	    strcpy(selType,baseInfo.nodeType);
	  }
	  // the filter is ok
	  if(!strcmp(selType,type)) {
	    // load up the node
	    if(nodeList) (*nodeList)[*cnt] = childID;
	    // increment the count
	    *cnt = *cnt + 1;
	  }
	}
	// there is no filter
	else {
	  // load up the node
	  if(nodeList) (*nodeList)[*cnt] = childID;
	  // increment the count
	  *cnt = *cnt + 1;
	}
	// call myself
	vd$trget_treeNodeList(nodeID   = &childID,
			      type     = type,
			      nodeList = nodeList,
			      lookup   = lookup,
			      cnt      = cnt);
      }
      retFlag = 1;
      goto wrapup;
    }

    //  if the lookup is the immediate parent of the node
    // no filter [type ignored]
    // ***************** get the parentID ************************
    if(selection == VDTR_FIND_PARENT) {
      if(vdct1$GetTree1Parent(objID = nodeID, outID = &parentID))
      {
	if(nodeList) (*nodeList)[0] = parentID;
	*cnt = 1;
	retFlag = 1;
      }
      goto wrapup;
    }
    //  if the lookup is the treeID for the node
    // no filter [type ignored]
    // ****************** get the treeID *************************
    if(selection == VDTR_FIND_TREE) {
      if(vdct1$GetTreeTopForNode(nodeID = nodeID,
				 treeID = &treeID))
      {
	if(nodeList) (*nodeList)[0] = treeID;
	*cnt = 1;
	retFlag = 1;
      }
      goto wrapup;
    }
  }

wrapup:
  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/********************************************************
 * Generic Routine to secure access to the Model Object *
 * Input is nodeID and output is the objID for the      *
 * model object   checks the connections                *
 ********************************************************/
IGRstat VDtrget_modelObject(TGRid      *nodeID,
			    TGRobj_env *objOE)
{
  VDASSERT_FN("VDtrget_modelObject");
  IGRstat retFlag = 0;

    // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  if(nodeID->objid == NULL_OBJID) goto wrapup;
  // Based on type VDATBASE
  if(vdobj$IsAncestryValid(objID          = nodeID,
			   superClassName = "VDatBase")) {
    retFlag = VDatGetLeafObject(nodeID,objOE);

  }
  // Based on type VDATBASE
  if(vdobj$IsAncestryValid(objID          = nodeID,
			   superClassName = "VDct1Base")) {
  // Make sure don't already have a model
  retFlag =  vdct1$GetNodeModelObject(nodeID  = nodeID,
				      modelOE = objOE);
  }

wrapup:
  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/**********************************************************************************
 * test routine to print out the nodeJD, setType, setName nodeName, nodeType      *
 **********************************************************************************/
IGRstat VDtr_getNodeJDPrint(TVDct1JD *nodeJD,
			    IGRchar  *title)
{
  VDASSERT_FN("VDtr_getNodeJDPrint");
  IGRstat retFlag = 0;
  TGRid   nodeID;

    // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  nodeID.osnum = nodeJD->id.osnum;
  nodeID.objid = nodeJD->id.objid;

  vd$trget_getNodePrint(nodeID = &nodeID,
			title  = title);

  retFlag = 1;
wrapup:
  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}


/**********************************************************************************
 * test routine to print out the nodeID, setType, setName nodeName, nodeType      *
 **********************************************************************************/
IGRstat VDtr_getNodePrint(TGRid    *nodeID,
			  IGRchar  *title)
{
  VDASSERT_FN("VDtr_getNodePrint");
  IGRstat        retFlag = 0;
  IGRchar        nodeName[128],nodeType[128],setName[128],setType[128],classType[128];
  TVDctxBaseInfo baseInfo;
  IGRint         osnum,objid;

    // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  // args check

    strcpy(setType,"");
    strcpy(setName,"");
    strcpy(nodeType,"");
    strcpy(nodeName,"");
    osnum = -1;
    objid = -1;

    if(nodeID) {
      osnum = nodeID->osnum;
      objid = nodeID->objid;


      // Based on type
      if(vdobj$IsAncestryValid(objID          = nodeID,
			       superClassName = "VDatBase")) {
	strcpy(classType,"VDatBase  - Class");
	// Need set name, type and description
	VDatGetSetName(nodeID,setName);
	VDatGetSetType(nodeID,setType);
	VDatGetNodeName(nodeID,nodeType);
	VDatGetNodeType(nodeID,nodeName);
      }
      // Based on type
      if(vdobj$IsAncestryValid(objID          = nodeID,
			       superClassName = "VDct1Base")) {
	strcpy(classType,"VDct1Base - Class");
	VDctxGetBaseInfo(nodeID,&baseInfo);
	strcpy(setType,baseInfo.setType);
	strcpy(setName,baseInfo.setName);
	strcpy(nodeType,baseInfo.nodeType);
	strcpy(nodeName,baseInfo.nodeName);
      }
    }
     if(title) printf("\n*************** Node [%s] Report ***************\n",title);
  if(!title) printf("\n*************** Node Report ***************\n");
  printf("     Node [%s]  [%d, %d]\n",classType,
	 osnum,
	 objid);
  printf("     Set: [%s %s] Node: [%s %s]\n",
	 setType,
	 setName,
	 nodeType,
	 nodeName);
     if(title) printf("*************** Node [%s] Report ***************\n",title);
  if(!title) printf("*************** Node Report ***************\n");
  retFlag = 1;

wrapup:
   // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}


/* ****************************************************************
 * testing routines below here
 */
IGRstat actual_Test()
{
  IGRstat retFlag = 0;
  IGRstat traceFlag = 0;
  IGRchar  treeType[128], treeName[128], nodeType[128], nodeName[128], *stages;
  IGRint   selectionClass;
  IGRchar        input[128], buf[128], path[1024];
  IGRint         i,j, sts, cnt, *cntp;
  TVDctBaseInfo  baseInfo;
  TGRid          testID, *treeIDs, *treeIDx;

  strcpy(treeType,"outfittree");
  strcpy(treeName,"1");
  strcpy(nodeType,"");
  strcpy(nodeName,"");

  printf("The test begins here 1\n");
  printf("Called Type and name defined no class\n");
#if 0

  vd$trget_trees(treeType = treeType,
		 treeName = treeName,
		 treeID   = &treeIDs,
		 cnt      = &cnt);

  printf("************1 Tree Count is [%d]\n",cnt);
  if(cnt){

    for(i = 0;i < cnt; i++){
      vd$trget_getNodePrint(nodeID = &treeIDs[i],
			    title = "Test 1 Results");


  }

    _FREE(treeIDs);
  }



  printf("\nThe test begins here 2\n");
  printf("Called Type and name defined no class\n");
  strcpy(treeType,"pipetree");
  strcpy(treeName,"1");
  vd$trget_trees(treeType = treeType,
		 treeName = treeName,
		 treeID   = &treeIDs,
		 cnt      = &cnt);

  printf("************2 Tree Count is [%d]\n",cnt);
  if(cnt){
  for(i = 0;i < cnt; i++){
    vd$trget_getNodePrint(nodeID = &treeIDs[i],
			  title = "Test 2 Results");

  }
  _FREE (treeIDs);
  }


  printf("\nThe test begins here 3\n");
  printf("Called Type no name defined no class\n");
  strcpy(treeType,"pipetree");
  strcpy(treeName,"");
  vd$trget_trees(treeType = treeType,
		 //treeName = treeName,
		 treeID   = &treeIDs,
		 cnt      = &cnt);

  printf("************3 Tree Count is [%d]\n",cnt);
  if(cnt){
  for(i = 0;i < cnt; i++){
    vd$trget_getNodePrint(nodeID = &treeIDs[i],
			  title = "Test 3 Results");

  }
  _FREE (treeIDs);
  }


  printf("\nThe test begins here 4\n");
  printf("Called no Type  name defined no class\n");
  strcpy(treeType,"pipetree");
  strcpy(treeName,"");
  vd$trget_trees(//treeType = treeType,
		 treeName = treeName,
		 treeID   = &treeIDs,
		 cnt      = &cnt);

  printf("************4 Tree Count is [%d]\n",cnt);
  if(cnt){
  for(i = 0;i < cnt; i++){
    vd$trget_getNodePrint(nodeID = &treeIDs[i],
			  title = "Test 4 Results");

  }
  _FREE (treeIDs);
  }


  //#endif
  printf("\nThe test begins here 5\n");
  printf("Called only class\n");
  strcpy(treeType,"pipetree");
  strcpy(treeName,"");
  selectionClass = VDTR_CLASS_VDAT;

  vd$trget_trees(//treeType = treeType,
		 //treeName = treeName,
		 class    = &selectionClass,
		 treeID   = &treeIDs,
		 cnt      = &cnt);

  printf("************5 Tree Count is [%d]\n",cnt);
  if(cnt){
  for(i = 0;i < cnt; i++){
    vd$trget_getNodePrint(nodeID = &treeIDs[i],
			  title = "Test 5 Results");

  }

  _FREE (treeIDs);
  }


  printf("\nThe test begins here 6\n");
  printf("Called only class\n");
  strcpy(treeType,"pipetree");
  strcpy(treeName,"");
  selectionClass = VDTR_CLASS_VDCT1;
  vd$trget_trees(//treeType = treeType,
		 //treeName = treeName,
		 class    = &selectionClass,
		 treeID   = &treeIDs,
		 cnt      = &cnt);

  printf("************6 Tree Count is [%d]\n",cnt);
  if(cnt){
  for(i = 0;i < cnt; i++){
    vd$trget_getNodePrint(nodeID = &treeIDs[i],
			  title = "Test 6 Results");

  }
  _FREE (treeIDs);
  }

  //#endif

  *nodeType = '\0';
  *nodeName = '\0';
  *path     = '\0';

  testID.objid = NULL_OBJID;

  sts = vd$trget_nodeInfo(nodeID   = &testID);
  printf("test of nodeInfo 1 sts[%d]\n",sts);

  testID.objid = 779;
  testID.osnum = 2;

  sts = vd$trget_nodeInfo(nodeType = nodeType,
			  nodeID   = &testID,
			  path     = path);
  printf("test of nodeInfo 2 sts[%d]\n",sts);
  printf("nodeType is [%s]\n",nodeType);
  printf("nodePath is [%s]\n",path);
  testID.objid = 357;
  testID.osnum = 2;


  sts = vd$trget_nodeInfo(nodeType = nodeType,
			  nodeName = nodeName,
			  nodeID   = &testID,
			  path     = path);
  printf("test of nodeInfo 3 sts[%d]\n",sts);
  printf("nodeType is [%s]\n",nodeType);
  printf("nodeName is [%s}\n",nodeName);
  printf("nodePath is [%s]\n",path);
  //#endif


   selectionClass = VDTR_FIND_ALL_NODE;
 strcpy(nodeType,"GROUP");
 strcpy(nodeName,"1.2");

 testID.objid = 357;
 testID.osnum = 2;
 vd$trget_nodes(nodeType   = nodeType,
		nodeName   = nodeName,
		nodeID     = &testID,
		lookupType = selectionClass,
		outID      = &treeIDs,
		cnt        = &cnt);
  printf("************1a Node Count is [%d]\n",cnt);
  if(cnt > 0) {
    for(i = 0;i < cnt; i++){
      vd$trget_getNodePrint(nodeID = &treeIDs[i],
			    title = "Test 1a Results");

    }
    free(treeIDs);
  }
  //***************************************************
  strcpy(nodeType,"OUTFITTREE");
  strcpy(nodeName,"1");
  printf("the 1stageCount\n");
  vd$trget_stages(treeType = nodeType,
		  treeName = nodeName,
		  treeID   = NULL, //&testID,
		  //class    = NULL,
		  stageCnt = &cnt,
		  stages   = &stages);
  printf("the 2stageCount is [%d]\n",cnt);
  if(cnt > 0) {
    printf("the 3stageCount is [%d]\n",cnt);
    for(i = 0;i < cnt; i++){
      printf("The stage is [%s]\n", stages + i*VDTR_NODE_NAME_LEN);

      }
    free(stages);
  }
#endif


  printf("end test of get_node\n");

  retFlag = 1;
wrapup:
  return retFlag;

}


/// starts the testing
IGRstat get_Started()
{
  IGRstat retFlag = 0;
  IGRstat traceFlag = 0;
  IGRstat i, sts;
  IGRchar buf[128], input[128];


  sts = 1;

  actual_Test();

wrapup:
  return retFlag;

}


end implementation VDct1Base;
