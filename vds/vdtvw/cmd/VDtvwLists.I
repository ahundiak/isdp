/* $Id: VDtvwLists.I,v 1.8 2001/09/20 18:56:52 paul_noel Exp $  */


/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdtvw/cmd/VDtvwLists.I
 *
 * Description: List management routines for the searching of 
 *              the tree to hilite specific nodes in the tree
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/05/01  pn      Creation
 ***************************************************************************/

// Generic node operations routines

class implementation VDct1Base;
/*
#define vdsDEBUG 
#define vdserrDEBUG
*/

#include "vdtvw.h"
#include "vdtr_macros.h"
#include "VDmem.h"
#include "VDassert.h"
#include "VDfrm.h"
#include <sys/stat.h>
#include "ci.h"
#include <dirent.h>
#include "VDppl1.h"
#include "VDchn.h"
#include "VDfile.h"
#include "vdtvwtools.h"

VDASSERT_FFN("vds/vdtvw/VDtvwLists.I");


/********************************************
 *
 * Select a list of nodes to match the 
 * definition and the User Definition
 * This is not filtered  by Model Obj
 * This is not filtered  by Attribute
 * This is just the list for the filtering
 * to apply to separates any old data from
 * the new list. MEMORY ALLOCATED
 *
 ********************************************/
IGRint VDtvwListGetUnfiltered(TGRid   *defIDs,
			      IGRint  *defIDsCnt,
			      IGRchar *selection,
			      TGRid   **outIDs,
			      IGRint  *outIDsCnt)
{
  VDASSERT_FN("VDtvwListGetUnfiltered");
  IGRint retFlag = 0;
  IGRint     child = -1;
  IGRint     i = 0;
  IGRint     j = 0;
  TGRid      *stageIDs = NULL,nodeID;
  IGRint     stageIDsCnt = 0;
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  /* some cleanup */
  if(*outIDsCnt > 0) _FREE( *outIDs);
  *outIDsCnt = 0;
  if(!defIDs) goto wrapup;
  if(!selection) goto wrapup;
  if(*defIDsCnt < 1) goto wrapup;

 
  if(traceFlag) { 
    printf("\n\nPrinting defIDs [%d]\n",*defIDsCnt);
    for(i = 0;i < *defIDsCnt;i++) {
      printf("defIDs #[%d] [%d][%d]\n",i,defIDs[i].osnum,defIDs[i].objid);
    }
    printf("Done \n\n");
  }
  
  

  /* do the lists */
  if(!strcmp(selection,"Parent")) {
    /* this is a case of the definition is the list */
    for(i = 0;i < *defIDsCnt;i++) {
      if(defIDs[i].objid != NULL_OBJID) {
	VDtvwAddNodeToListUnique(&defIDs[i],outIDs,outIDsCnt);
      }
    }
    retFlag = 1;
    goto wrapup;
  } else if (!strcmp(selection,"One Level")) {
    /* this is one level down from the definition */
    child = 0;
  } else if (!strcmp(selection,"All")) {
    /* all levels down from the definition */
    child = 1;
  }

  /* this only happens if there is some the selection */
  if(child >= 0) {  
    for(i = 0;i < *defIDsCnt;i++) {
    _FREE(stageIDs);
    stageIDsCnt = 0;
    
    vdfile$GetNodeList(nodeID      = &defIDs[i],
		       child       = &child, 
		       nodeList    = &stageIDs,
		       nodeListCnt = &stageIDsCnt);
 
      if(stageIDsCnt > 0) {
	for(j = 0;j < stageIDsCnt;j++) {
	  nodeID = stageIDs[j];
	  if(nodeID.objid != NULL) {
	    VDtvwAddNodeToListUnique(&nodeID,outIDs,outIDsCnt);
	  }
	}
      }
    }
    
  if(traceFlag) { 
    printf("\n\nPrinting outIDs [%d]\n",*outIDsCnt);
    for(i = 0;i < *outIDsCnt;i++) {
      printf("outIDs #[%d] [%d][%d]\n",i,(*outIDs)[i].osnum,(*outIDs)[i].objid);
    }
    printf("Done \n\n");
  }   
    
    retFlag = 1;
    goto wrapup;    
  }

wrapup:
  if(stageIDsCnt > 0) _FREE( stageIDs);
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}


/********************************************
 *
 * Remove from a list any items not objOE
 *
 ********************************************/
IGRint VDtvwListFilterModelObjs(TGRid **nodeList,IGRint *nodeListCnt)
{
  VDASSERT_FN("VDtvwListFilterModelObjs");
  IGRint     retFlag = 0;
  TGRobj_env objOE;
  TGRid      nodeID;
  IGRint     row;
  
  
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s nodeListCnt [%d]\n",ffn(),fn,*nodeListCnt);

  /* args */
  VDASSERTW(nodeList);
  if(*nodeListCnt < 1) goto wrapup;
  
  /* loop through and exclude non model object items */
  for(row = 0;row < *nodeListCnt;row++) {
    if((*nodeList)[row].objid != NULL_OBJID) {
      
      vd$trget_modelObject(nodeID = &((*nodeList)[row]),
			   objOE   = &objOE);
      if(objOE.obj_id.objid == NULL_OBJID) {
	nodeID = (*nodeList)[row];
	VDtvwRemoveNodeFromList(&nodeID,
				nodeList,
				nodeListCnt);
	if(*nodeListCnt == 0) break;
      }
    }
  }
  
  retFlag = 1;
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d) nodeListCnt [%d]\n",ffn(),fn,retFlag,*nodeListCnt);
  return retFlag;
}


/********************************************
 *
 * Filter nodeIDs by Stage from selection
 *
 ********************************************/
IGRint VDtvwListFilterNodeIDsByStage(IGRchar *stage,TGRid **nodeList,IGRint *nodeListCnt)
{
  VDASSERT_FN("VDtvwListFilterNodeIDsByStage");
  IGRint retFlag = 0;
  IGRint i,j;
  TGRid  nodeID;
  IGRchar buf[128];
  IGRchar nodeType[128];
   
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  /* args check */
  if(stage[0] == '\0') goto wrapup;
  if(!strcmp(stage," ")) goto wrapup;
  VDASSERTW(nodeList);
  if(*nodeListCnt < 1) {
    *nodeListCnt = 0;
    goto wrapup;
  }
  
  /* inits */ 
  nodeType[0] = '\0';
  nodeID.objid = NULL_OBJID;
  sprintf(buf,"Filtering [%d] Nodes by Stage",*nodeListCnt);
  UI_status(buf); 
  /* start looping though the list and adding the nodes that match */
  for(i = 0;i < *nodeListCnt;i++) {
    
    nodeID = (*nodeList)[i];
    if(nodeID.objid == NULL_OBJID) continue;
    VDctxGetNodeType(&nodeID,nodeType);
    if(traceFlag) printf("nodeID[%d][%d] {%s}\n",nodeID.osnum,nodeID.objid,nodeType);
    if(strcmp(nodeType,stage)) {
      VDtvwRemoveNodeFromList(&nodeID,nodeList,nodeListCnt);
      if(*nodeListCnt < 1) goto wrapup;
      i--;
    }
  }
  
  retFlag = 1;
wrapup:
  UI_status("Filtering Nodes by Stage Done");
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}
/********************************************
 *
 * Filter nodeIDs by Name from selection
 *
 ********************************************/
IGRint VDtvwListFilterNodeIDsByName(IGRchar *name,TGRid **nodeList,IGRint *nodeListCnt)
{
  VDASSERT_FN("VDtvwListFilterNodeIDsByStage");
  IGRint retFlag = 0;
  IGRint i;
  TGRid  nodeID;
  IGRchar buf[128];
  IGRchar nodeName[128],*p;
   
  
   
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  /* args check */
  VDASSERTW(nodeList);
  if(*nodeListCnt < 1) {
    *nodeListCnt = 0;
    goto wrapup;
  }
  
  /* inits */ 
  nodeName[0] = '\0';
  nodeID.objid = NULL_OBJID;
  sprintf(buf,"Filtering [%d] Nodes by Name",*nodeListCnt);
   UI_status(buf); 
  /* check for wildcards */
  p = NULL;
  p = strrchr(name,'*');

  if(p != NULL) {
    /* start looping though the list and remove the nodes that don't match */
    for(i = 0;i < *nodeListCnt;i++) {
      nodeID = (*nodeList)[i];
      if(nodeID.objid == NULL_OBJID) continue;
      VDctxGetNodeName(&nodeID,nodeName);
      if(traceFlag) printf("name [%s] nodeName [%s]\n",name,nodeName);
      
      if(!(VDtvwIsWildCardMatchItem(name,nodeName))) {
	// if(!vdfile$IsFilterMatch(filter = name,
	//	       name   = nodeName)) {
	if(traceFlag) printf(" removing nodeID[%d][%d]\n",nodeID.osnum,nodeID.objid);
	VDtvwRemoveNodeFromList(&nodeID,nodeList,nodeListCnt);
	if(*nodeListCnt < 1) goto wrapup;
	i--;
      }
    }
  }
  else {
    /* start looping though the list and remove the nodes that don't match */
    for(i = 0;i < *nodeListCnt;i++) {
      nodeID = (*nodeList)[i];
      if(nodeID.objid == NULL_OBJID) continue;
      VDctxGetNodeName(&nodeID,nodeName);
      if(strcmp(nodeName,name)) {
	VDtvwRemoveNodeFromList(&nodeID,nodeList,nodeListCnt);
	if(*nodeListCnt < 1) goto wrapup;
	i--;
      }
    }
  }
  
  
  retFlag = 1;
wrapup:
  UI_status("Filtering Nodes by Name Done");
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}


/********************************************
 *
 * Filter a node list by the selections of 
 * attributes from the form
 *
 ********************************************/
IGRint VDtvwListFilterNodeIDsByAttr(IGRchar *attrName,
				    IGRchar *attrValue,
				    IGRchar *blnTxt,
				    TGRid   **nodeList,
				    IGRint  *nodeListCnt)
{
  VDASSERT_FN("VDtvwListFilterNodeIDsByAttr");
  IGRint retFlag = 0;
  TVDfld  flds[VDFLD_MAX_CNT];
  IGRint  i,sts,cnt,fldsCnt = 0;
  TGRid   nodeID;
  IGRchar buf[128];
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
      
  /* args */
  VDASSERTW(attrName);
  VDASSERTW(attrValue);
  VDASSERTW(blnTxt);
  VDASSERTW(nodeList);
  
  /* inits */
  sprintf(buf,"Filtering [%d] Nodes by Attrs",*nodeListCnt);
  UI_status(buf); 
  buf[0] = '\0';

  /* data check */
  if(!strcmp(blnTxt,"")) goto wrapup;
  if(!strcmp(attrName,"")) goto wrapup;

  /* loop though the list of nodes */
  for(i = 0;i < *nodeListCnt;i++) {
    nodeID = (*nodeList)[i];
    
    if(!(VDtvwDoesNodeHaveThisAttribute( &nodeID,
					 attrName,
					 attrValue,
					 blnTxt))) {
      
      VDtvwRemoveNodeFromList(&nodeID,nodeList,nodeListCnt);
      if(*nodeListCnt < 1) goto wrapup;
      i--;
    }
  }
  
  retFlag = 1;
wrapup:
  /* say bye */
  UI_status("Filtering Nodes by Attrs Done");
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

/********************************************
 *
 * Filter out nodes which do not have this
 * attribute value from a list 
 * This is a check to see if the node even
 * has the attribute of that name to use
 * it does not check the attribute content
 * it validates existence of the attribute
 * which may have no content value
 *
 ********************************************/
IGRint VDtvwFilterNodeIDsByAttrName(IGRchar *attrName,TGRid **nodeList,IGRint *nodeListCnt)
{
  VDASSERT_FN("VDtvwFilterNodeIDsByAttrName");
  IGRint retFlag = 0;
  IGRchar attrValue[128],blnTxt[128];
  
  traceFlag = 0;
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  /* init */
  strcpy(attrValue,"*");
  strcpy(blnTxt,"=");

  /* args check */
  if(*nodeListCnt < 1) goto wrapup;
  VDASSERTW(attrName);
  VDASSERTW(nodeList);
  
  /* 
   * check the list
   * relies on the wildcard abilities of this
   * uses the '*' to allow any value to pass 
   */
  VDtvwListFilterNodeIDsByAttr(attrName,
			       attrValue,
			       blnTxt,
			       nodeList,
			       nodeListCnt);
  retFlag = 1;
wrapup:  

  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

#if 0
/********************************************
 *
 * 
 *
 ********************************************/
IGRint VDtvw(TGRid **nodeList,IGRint *nodeListCnt)
{
  VDASSERT_FN("VDtvw");
  IGRint retFlag = 0;
  traceFlag = 1;
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  

  retFlag = 1;
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

#endif
end implementation VDct1Base;


