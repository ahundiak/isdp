/* $Id: VDtvwTree.I,v 1.10 2001/10/26 20:20:22 ylong Exp $  */


/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdtvw/cmd/VDtvwTree.I
 *
 * Description: generic Tree browsing display routines for 
 *              the tree in the TNS form
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/25/01  pn      Creation
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
#include "vdtvwtools.h"
#include "VDobj.h"

//#define MULTI_COL VDTVW_MCOL_TREE
IGRstat VDtvwFormPlaceTreeItem(Form    form,
			       IGRint  gadget,
			       IGRint  row,
			       TGRid   *nodeID,
			       IGRint  offset,
			       IGRint  attrFlag,
			       IGRint  exprFlag,
			       IGRint  selFlag);

IGRstat VDtvwFormPlaceNodeTop(Form    form,
			      IGRint  gadget,
			      TGRid  *topID);

IGRstat VDtvwFormExpandNode(Form   form,
			    IGRint gadget,
			    TGRid *nodeID);

IGRstat VDtvwFormContractNode(Form   form,
			      IGRint gadget,
			      TGRid  baseID);

IGRstat VDtvwFormGetTreeRowData(Form     form,
				IGRint   gadget,
				IGRint   row,
				IGRchar *attr,
				IGRchar *exp,
				IGRchar *data,
				TGRid   *nodeID,
				IGRint  *selFlag,
				IGRint  *pos);

IGRstat VDtvwFormFindNode(Form    form,
			  IGRint  gadget,
			  TGRid   baseID,
			  IGRint *rowFound);

IGRint VDtvwFormExpandAttrs(Form    form,
			    IGRint  gadget,
			    TGRid  *nodeID);

IGRint VDtvwFormContractAttrs(Form    form,
			      IGRint  gadget,
			      TGRid  *nodeID);

IGRint VDtvwFormGetTreeID(Form   form,
			  IGRint gadget,
			  TGRid *nodeID);

IGRint VDtvwNotifyIfNodeSel(Form   form,
			    IGRint gadget);

IGRint VDtvwFormExpandToNodeInTree(Form   form,
				   IGRint gadget,
				   TGRid  nodeID, 
				   TGRid  rootID);

IGRint VDtvwFormIsNodeInView(Form   form,
			     IGRint gadget,
			     TGRid  nodeID);

IGRint VDtvwFormSetHiliteNodeExp(Form   form,
				 IGRint gadget,
				 TGRid  nodeID,
				 TGRid  rootID);

IGRint VDtvwFormSetUnHiliteNode(Form   form,
				IGRint gadget,
				TGRid *nodeID);

IGRint VDtvwFormIsNodeInViewHilited(Form    form,
				    IGRint  gadget,
				    TGRid   nodeID,
				    IGRint *rowFound);

static IGRint  intcmp( int* e1, int* e2 );


extern IGRstat VDctbsFilterTreeID(TGRid *treeID);

extern IGRstat VDctbsFilterStages(TGRid *nodeID,IGRchar *stage);


VDASSERT_FFN("vds/vdtvw/VDtvwTree.I");
/* routines differ from other tree displays in that
 * these trees do not display from the top
 * These trees do display from a defined rootID
 */
/********************************************
 *
 * Checks to see if a nodeID is in the view
 * on the form and gets Hilite status ~pn
 *
 ********************************************/
IGRint VDtvwFormIsNodeInViewHilited(Form form,IGRint gadget,TGRid nodeID,IGRint *rowFound)
{
  VDASSERT_FN("VDtvwFormIsNodeInViewHilited");
  IGRint retFlag = 0;
  IGRint row,rows,selFlag,pos;
  IGRchar data[128],attr[128],exp[128];
  TGRid   rowID;
 
  if (traceFlag) printf(">>> %s %s nodeID[%d][%d]\n",ffn(),fn,nodeID.osnum,nodeID.objid);

   /* args checks */
  VDASSERTW(form);
  if(gadget < 11) goto wrapup;
  if(nodeID.objid == NULL_OBJID) goto wrapup;
  *rowFound = -1;

  /* get the number of rows posted already */
  VIfld_get_num_rows(form, gadget, &rows);

 /* loop through to find if already hilited */
  for(row = 0;row < rows;row++) {
    VDtvwFormGetTreeRowData(form,gadget,row,attr,exp,data,&rowID,&selFlag,&pos);
    if(rowID.objid != NULL_OBJID) {
      if((rowID.osnum == nodeID.osnum) && (rowID.objid == nodeID.objid)) {
	retFlag = selFlag;
	*rowFound = row;
	goto wrapup;
      }
    }
  }

wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

/********************************************
 *
 * Checks to see if a nodeID is in the view
 * on the form ~pn
 *
 ********************************************/
IGRint VDtvwFormIsNodeInView(Form form,IGRint gadget,TGRid nodeID)
{
  VDASSERT_FN("VDtvwFormIsNodeInView");
  IGRint retFlag = 0;
  IGRint row,rows,selFlag,pos;
  IGRchar data[128],attr[128],exp[128];
  TGRid   rowID;
 
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

   /* args checks */
  VDASSERTW(form);
  if(gadget < 11) goto wrapup;
  if(nodeID.objid == NULL_OBJID) goto wrapup;

  /* get the number of rows posted already */
  VIfld_get_num_rows(form, gadget, &rows);

 /* loop through to find if the parent is already expanded */
  for(row = 0;row < rows;row++) {
    VDtvwFormGetTreeRowData(form,gadget,row,attr,exp,data,&rowID,&selFlag,&pos);
    if(rowID.objid != NULL_OBJID) {
      if((rowID.osnum == nodeID.osnum) && (rowID.objid == nodeID.objid)) {
	retFlag = 1;
	goto wrapup;
      }
    }
  }

wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

/********************************************
 *
 * Expand a node recursively 
 * nodeID is not expanded but all nodes in between
 * it and the rootID are expanded ~pn
 *
 ********************************************/

IGRint VDtvwFormExpandToNodeInTree(Form form,IGRint gadget,TGRid nodeID, TGRid rootID)
{
  VDASSERT_FN("VDtvwExpandToNodeInTree");
  IGRint retFlag = 0;
  IGRint row,rows,i,j,selFlag,pos,sts;
  IGRchar data[128],attr[128],exp[128];
  TGRid   rowID,parentID,nextID,testID;
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  /* init */
  sts = 0;

  /* args checks */
  VDASSERTW(form);
  if(gadget < 11) goto wrapup;
  if(nodeID.objid == NULL_OBJID) goto wrapup;
  /* if nodeID is at the rootID */
  if(nodeID.objid == rootID.objid) goto wrapup;

  /* get my parentID  */
  VDctxGetTreeParent(&nodeID,&parentID);
  if(parentID.objid == NULL_OBJID) goto wrapup;
  nextID = parentID;
  
  while(sts == 0) {
    nextID = parentID;
    
    /* check to see if the node is in view */
    sts = VDtvwFormIsNodeInView(form,gadget,nodeID);
      if (traceFlag) printf("nodeID[%d][%d] sts [%d]\n",nodeID.osnum,nodeID.objid,sts);
    if(sts & 1) break;
    
    /* check to see if the parent of the node is in view */
    if(VDtvwFormIsNodeInView(form,gadget,nextID)) { 
      /* expand it */
        if (traceFlag) printf("expanding node [%d][%d]\n",nextID.osnum,nextID.objid);
      VDtvwFormExpandNode(form,
			  gadget,
			  &nextID);
      VDctxGetTreeParent(&nodeID,&parentID);
      if(parentID.objid == NULL_OBJID) goto wrapup;
    } else {
      /* move the parent up a notch */
      VDctxGetTreeParent(&nextID,&parentID);
      if(parentID.objid == NULL_OBJID) goto wrapup;
    }
    
  }
  
  retFlag = 1;
wrapup:

  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

/********************************************
 *
 * UnHilite any node given to this routine
 * does not shrink expansions
 * checks to see if the node is in view 
 * and removes hilites if the node is in view ~pn
 *
 ********************************************/
IGRint VDtvwFormSetUnHiliteNode(Form form,IGRint gadget,TGRid *nodeID)
{
  VDASSERT_FN("VDtvwFormSetUnHiliteNode");
  IGRint  retFlag = 0;
  IGRint  rowFound = 0;
  TGRid   rowID;
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  /* args */
  VDASSERTW(form);
  if(gadget < 11) goto wrapup;
  VDASSERTW(nodeID);

  VDtvwFormFindNode(form,
		    gadget,
		    *nodeID,
		    &rowFound);
  if(rowFound >= 0) {
    FIfld_set_select(form,gadget,rowFound,2,0);
  }

  retFlag = 1;

wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

/********************************************
 *
 * controls hilites on any node passed 
 * finds it in the multicol gadget and 
 * hiltes this node.
 * also expands the node into view ~pn
 *
 ********************************************/
IGRint VDtvwFormSetHiliteNodeExp(Form form,IGRint gadget,TGRid nodeID,TGRid rootID)
{
  VDASSERT_FN("VDtvwFormSetHiliteNodeExp");
  IGRint  retFlag = 0;
  IGRint  rowFound = -1;
  TGRid   rowID;
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s nodeID [%d][%d]\n",ffn(),fn,nodeID.osnum,nodeID.objid);
  
  /* args checks */
  VDASSERTW(form);
  if(gadget < 11) goto wrapup;
  if(nodeID.objid == NULL_OBJID) goto wrapup;

  /* IS THE NODE VISIBLE IN THE GADGET */
  if(!(VDtvwFormIsNodeInView(form,gadget,nodeID))) {
    VDtvwFormExpandToNodeInTree(form,gadget,nodeID,rootID);
  }
  /* double check to make sure it worked */
  if(!(VDtvwFormIsNodeInView(form,gadget,nodeID))) {
    if(traceFlag) printf("It failed to expand!\n");
    goto wrapup;
  }
  
  
  /* hilite it */
  VDtvwFormFindNode(form,
		    gadget,
		    nodeID,
		    &rowFound);
  if(rowFound == -1) {
    if(traceFlag) printf("rowFound failed to find the nodeID!\n");
    goto wrapup;
  }
  
  
  FIfld_set_select(form,gadget,rowFound,2,1); 
  
  retFlag = 1;
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}



/********************************************
 *
 * notify if a node is selected
 * blank if the node is not selected ~pn
 *
 ********************************************/
IGRint VDtvwNotifyIfNodeSel(Form form,IGRint gadget)
{
  VDASSERT_FN("VDtvw");
  IGRint retFlag = 0;
  IGRint row,rows,selFlag,pos,i;
  IGRchar attr[128],exp[128],data[128],buf[128],*p;
  TGRid   nodeID;
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  VDASSERTW(form);

  /* get the active row */ 
  FIfld_get_active_row( form, gadget, &row, &pos );

  /* get the row data */
  VDtvwFormGetTreeRowData(form,gadget,row,attr,exp,data,&nodeID,&selFlag,&pos);

  p = data;
  for(i = 0;i < strlen(data);i++) {
    if(!(*p == ' ')) {
      strcpy(data,p);
      break;
    }
    p++;
  }

  /* selected */
  if(nodeID.objid == NULL_OBJID) {
    sprintf(buf,"Attr: [%s]\n",data);
    FIg_set_text(form,10,buf);
  } else {
    sprintf(buf,"Node: [%d,%d] [%s]\n",nodeID.osnum,nodeID.objid,data);
      FIg_set_text(form,10,buf);
  } 
  
  retFlag = 1;
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

/********************************************
 *
 * Get the nodeID from the top of the form
 * multicolumn gadget ~pn
 *
 ********************************************/
IGRint VDtvwFormGetTreeID(Form form,IGRint gadget,TGRid *nodeID)
{
  VDASSERT_FN("VDtvwFormGetTreeID");
  IGRint retFlag = 0;
  IGRint row,rows,selFlag,pos;
  IGRchar attr[128],exp[128],data[128];
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  /* init */ 
  nodeID->objid = NULL_OBJID;
  strcpy(attr,EXP_EMP);
  strcpy(attr,EXP_EMP);
  strcpy(data,"");
  row = rows = selFlag = pos = 0;

  /* args checks */
  VDASSERTW(form);
  if(gadget < 11) goto wrapup;
  
  /* get the number of rows posted already */
  VIfld_get_num_rows(form, gadget, &rows);
  if(rows < 1) goto wrapup;
    
  VDtvwFormGetTreeRowData(form,gadget,row,attr,exp,data,nodeID,&selFlag,&pos);

  retFlag = 1;
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

/********************************************
 *
 * Fill in the stages list on the form
 * gadget is the stages gadget 
 * source is the source gadget ~pn*
 *
 ********************************************/
/*
 * allocation *nodeIDs, actually ** 
 * freed as nodeIDs
 */
IGRint VDtvwFormFillStageList(Form form, IGRint gadget,IGRint source)
{
  VDASSERT_FN("VDtvwFormFillStageList");
  IGRint retFlag = 0;
  TGRid  treeID;
  TGRid   *nodeIDs;
  IGRint  i,j,cnt,listCnt,nodeTypeCnt,selectionType,Selflag,nodeClass;
  IGRchar **nodeTypeList,nodeType[128],parent[128];
  IGRint    nodeTypeListCnt = 0;
  IGRint    rows = 0;
  IGRint    child = 1;
  TGRobj_env modelOE;
  
  // say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn); 
  }
  // args check
  VDASSERTW(form != '\0');
  
  /* init */
  nodeIDs = NULL;
  parent[0] = '\0';
  nodeType[0]  = '\0';
  
  // first things first reset the form
  FIg_reset( form, gadget );    
  Selflag = FALSE;

  // get the treeID
  VDtvwFormGetTreeID(form,source,&treeID);
  if(treeID.objid == NULL_OBJID) {
    if(traceFlag) printf("No Tree\n");
    goto wrapup;
  }

  /* give a status notice for users */
  FIg_set_text(form,10,"Processing Stage List.");
  UI_status("Processing Stage List");


  if(traceFlag) printf("Tree ID data [%d] [%d]\n",treeID.osnum,treeID.objid);
 
  // get the nodes below the treeID
  cnt = 0;

  vdfile$GetNodeList(nodeID      = &treeID,
		     child       = &child,
		     nodeList    = &nodeIDs,
		     nodeListCnt = &cnt);
 if(traceFlag) printf("%s %s: vdfile$GetNodeList[%d] call #1\n",ffn(),fn,cnt);
  if(traceFlag) printf("cnt = [%d]\n",cnt);

  if(cnt < 1) {
    VIg_set_text(form,10,"Selection has no children");
  }
  else {
   VIg_set_text(form,10,"");
  }

  // loop through the IDs and fetch the names matching the text
  for(i = 0;i < cnt;i++) {
    nodeType[0] = '\0';
    if((nodeIDs[i].osnum == treeID.osnum) && (nodeIDs[i].objid != NULL_OBJID)){
      VDctxGetNodeType(&nodeIDs[i],nodeType);
      if(traceFlag) printf("nodeIDs[%d] [%d][%d] {%s}\n",i,nodeIDs[i].osnum,nodeIDs[i].objid,
			   nodeType);
      VDtvwAddStrListUnique(nodeType,&nodeTypeList,&nodeTypeListCnt);

    }
  }

  if(nodeTypeListCnt < 1) goto wrapup;
  // set the text field to the first one
  FIg_set_text( form, gadget, nodeTypeList[0] );

  for(i = 0;i < nodeTypeListCnt;i++) {
  // load up the rows
  FIfld_set_list_text( form,
                       gadget,  
                       i,
                       0,
                       (unsigned char *)(nodeTypeList[i]),
                       Selflag );
  }

  /* do we need this ? */
  vdtr$FixScrollBar(form = form,gadget = gadget);

wrapup:

  /* give a status notice for users */
  FIg_set_text(form,10,"Done Stage List.");
  UI_status("Done Stage List");

  if(nodeIDs) _FREE(nodeIDs);
  if(nodeTypeListCnt > 0) _LOOPFREE( nodeTypeList,nodeTypeListCnt );
  
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}
/****************************************************************
 *
 * Fill Names List ~pn*
 *
 ****************************************************************/
/*
 * allocation is supposed to be free at the end of this
 */
IGRstat VDtvwFormFillNamesList(Form form,IGRint gadget,IGRint source)
{
  VDASSERT_FN("VDtvwFormFillNamesList");
  IGRint  retFlag = 0;
  TGRid    treeID;
  TGRid   *nodeIDs = NULL;
  IGRint   nodeIDsCnt = 0;
  TGRid   *nameIDs = NULL;
  IGRint   nameIDsCnt = 0;
  IGRchar sets[128],stage[128],name[128],afrom[128],ato[128],attrName[128],attrValue[128];
  IGRint  modTog,stageTog,nameTog,attrTog,itemTog,rows,row,child = 1;
  IGRchar nodeName[128];
  IGRchar **nodeNameList = NULL;
  IGRint    nodeNameListCnt = 0;
  IGRint    selFlag = 0;
  TVDctxBaseInfo baseInfo;

  // say hi
  if (traceFlag) {
    printf("##########################\n");
    printf(">>> %s %s\n",ffn(),fn); 
  }
  
  // first things first reset the form
  FIg_reset( form, gadget ); 
  
  // get the treeID
  VDtvwFormGetTreeID(form,source,&treeID);
  if(treeID.objid == NULL_OBJID) {
    if(traceFlag) printf("No Tree\n");
    goto wrapup;
  }

  if(traceFlag) printf("Tree ID data [%d] [%d]\n",treeID.osnum,treeID.objid);

  /* get the toggle settings off the form */
  VDtvwGetToggleState(form,&modTog,&stageTog,&nameTog,&attrTog,&itemTog);

  /* get the text box data from the form */
  VDtvwGetSelectionText(form,sets,stage,name,afrom,ato,attrName,attrValue);

  /* give a status notice for users */
  FIg_set_text(form,10,"Processing Names List.");
  UI_status("Processing Names List");


    // get the nodes below the treeID
  nodeIDsCnt = 0;
  /*
  vdfile$GetNodeList(nodeID      = &treeID,
		     child       = &child,
		     nodeList    = &nodeIDs,
		     nodeListCnt = &cnt);
  */
  if(!strcmp(stage,"")) goto wrapup;
  nodeIDs = NULL;
  if(traceFlag) printf("going to the list stage[%s]\n",stage);
  vdfile$GetNodeList(nodeID      = &treeID,
		     type        = stage,
		     child       = &child,
		     nodeList    = &nodeIDs,
		     nodeListCnt = &nodeIDsCnt);
if(traceFlag) printf("%s %s: vdfile$GetNodeList[%d] call #1\n",ffn(),fn,nodeIDsCnt);
  if(traceFlag) printf("nodeIDsCnt = [%d]\n",nodeIDsCnt);

  if(nodeIDsCnt < 1) {
    VIg_set_text(form,10,"Selection has no children");
  }
  else {
   VIg_set_text(form,10,"");
  }
  /* no data lets go home */
  if(nodeIDsCnt < 1) goto wrapup;

  for(row = 0;row < nodeIDsCnt;row++) {
    if((nodeIDs[row].osnum == treeID.osnum) && (nodeIDs[row].objid != NULL_OBJID)) {
      VDctxGetNodeName(&nodeIDs[row],nodeName);
      VDtvwAddStrListUnique(nodeName,&nodeNameList,&nodeNameListCnt);
    }
  }
  
  rows = nodeNameListCnt;
  selFlag = 0;
  for(row = 0;row < rows;row++) {
    FIfld_set_list_text( form,
			 gadget,  
			 row,
			 0,
			 (unsigned char *)(nodeNameList[row]),
			 selFlag );
  }
  

  VDtvwFormMakeTextItemsUniqueADn(form,gadget,1,0);

  /* mop up the textbox stuff */
 if(rows > 0) {
    vdfrm$GetListText( form   = form,
		       gadget = gadget,
		       row    = 0,
		       txt    = nodeName);
      FIg_set_text( form, gadget, nodeName); 
      FIfld_set_list_select(form, gadget, 0, 0, 1);
  }
  
  retFlag = 1;
wrapup:

  /* give a status notice for users */
  FIg_set_text(form,10,"Done Names List.");
  UI_status("Done Names List");
  /* clean up */
  if(nameIDs) _FREE( nameIDs );
  if(nodeIDs) _FREE( nodeIDs );
  if(nodeNameListCnt > 0) _LOOPFREE( nodeNameList,nodeNameListCnt );

  // say bye
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    printf("##############################\n");
  }
  return retFlag;
}

/******************************************
 *
 * Expand the attribute list ~pn
 *
 ******************************************/


IGRint VDtvwFormExpandAttrs(Form form,IGRint gadget,TGRid *nodeID)
{
  VDASSERT_FN("VDtvwExpandAttrs");
  IGRint  retFlag = 0;
  TVDfld  flds[VDFLD_MAX_CNT];
  IGRint  fldsCnt,row,rows,i,baseOffset,offset,pos,selFlag;
  IGRchar attr[128],exp[128];
  IGRchar data[128];
  IGRchar node[128];
  IGRchar buf[128];
  IGRchar nodeData[128];
  IGRchar baseString[128];
  IGRchar *p,*q;
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  /* inits */
  strcpy(attr,EXP_EMP);
  strcpy(exp,EXP_EMP);
  strcpy(data,"");
  strcpy(node,"");
  strcpy(baseString,"");
  fldsCnt = row = rows = i = baseOffset = offset = pos = selFlag = 0;

  /* args check */
  VDASSERTW(nodeID);
  VDASSERTW(form);

  if(traceFlag) printf("looking for nodeID[%d][%d]\n",nodeID->osnum,nodeID->objid);
  
  if(gadget < 11) goto wrapup;
  if(nodeID->objid == NULL_OBJID) goto wrapup;

  /* get the number of rows posted already */
  VIfld_get_num_rows(form, gadget, &rows);
  if(rows < 1) goto wrapup;

  /* find this nodeID's row */
  VDtvwFormFindNode(form,
		    gadget,
		    *nodeID,
		    &row);

  if(traceFlag) printf("found at row [%d]\n",row);
  
  /* get the row's data */
  VDtvwFormGetTreeRowData(form,gadget,row,attr,exp,nodeData,nodeID,&selFlag,&pos);

  if(traceFlag) printf("nodeID coming off the form is [%d][%d]\n",
		       nodeID->osnum,nodeID->objid);
  if(!strcmp(attr,EXP_EXP)) VIfld_set_text(form, gadget, row, 0, EXP_CON, 0);

  /* reset the expansion flag on attributes */
  VIfld_set_text(form, gadget, row, 0, EXP_EXP, 0);
  
  /* get the baseOffset */
  q = nodeData;
  strcpy(baseString,EXP_EMP);
  for(i = 0;i < strlen(nodeData);i++) {
    if(*q == ' ') {
      strcat(baseString,EXP_EMP);
      baseOffset++;
    }
    if(!(*q == ' ')) break;
    q++;
  }

  /* Reset the stuff */
  strcpy(attr,EXP_EMP);
  strcpy(exp,EXP_EMP);
  strcpy(data,"");
  strcpy(node,"");

  /* get the attributes for the nodeID */
  p = data;
  VDctxGetFldAtrsID(NULL,nodeID,&fldsCnt,flds);
  for(i = 0; i < fldsCnt; i++) {
    row++;
    /* get the field description */
    VDfldGetFldDesc(&flds[i],p);
    VDfrmInsertBlankRow(form,gadget,row);
      /* place the data in the form */
    sprintf(buf,"%s%s",baseString,data);
    strcpy(data,buf);
    VIfld_set_text(form, gadget, row, 0, attr, 0);
    VIfld_set_text(form, gadget, row, 1, exp, 0);
    VIfld_set_text(form, gadget, row, 2, data, 0);
    VIfld_set_text(form, gadget, row, 3, node, 0);
  }
  retFlag = 1;
wrapup:
  /* update the number of rows */
  VIfld_get_num_rows(form, gadget, &rows);
  FIfld_set_num_rows(form, gadget, rows);
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}
/********************************************
 *
 * Contract the attribute list ~pn
 *
 ********************************************/
IGRint VDtvwFormContractAttrs(Form form,IGRint gadget,TGRid *nodeID)
{
  VDASSERT_FN("VDtvwContractAttrs");
  IGRint  retFlag = 0;
  IGRint  fldsCnt,row,rows,i,baseOffset,offset,pos,selFlag;
  IGRchar attr[128],exp[128];
  IGRchar data[128];
  IGRchar node[128];
  IGRchar buf[128];
  IGRchar nodeData[128];
  IGRchar *p,*q;
  TGRid   localID;

  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  /* inits */
  strcpy(attr,EXP_EMP);
  strcpy(exp,EXP_EMP);
  strcpy(data,"");
  strcpy(node,"");
  fldsCnt = row = rows = i = baseOffset = offset = pos = selFlag = 0;


  /* args check */
  VDASSERTW(nodeID);
  VDASSERTW(form);
  if(gadget < 11) goto wrapup;
  if(nodeID->objid == NULL_OBJID) goto wrapup;
  
  /* get the number of rows posted already */
  VIfld_get_num_rows(form, gadget, &rows);
  if(rows < 1) goto wrapup;
  /* find this nodeID's row */
  VDtvwFormFindNode(form,gadget,*nodeID,&row);

  /* get the nodes data */
  VDtvwFormGetTreeRowData(form,gadget,row,attr,exp,nodeData,nodeID,&selFlag,&pos);
  if(!strcmp(attr,EXP_EXP)) VIfld_set_text(form, gadget, row, 0, EXP_CON, 0);

  /* get the baseOffset */
  q = nodeData;
  for(i = 0;i < strlen(nodeData);i++) {
    if(*q == ' ') {
      baseOffset++;
    }
    if(!(*q == ' ')) break;
    q++;
  }
  /* now go down a row */
  row++;
  while(1) {
    /* get the number of rows posted */
    VIfld_get_num_rows(form, gadget, &rows);

    /* if out of rows to look at */
    if(row == rows) break;

    /* get the row data */
    VDtvwFormGetTreeRowData(form,gadget,row,attr,exp,data,&localID,&selFlag,&pos);

    /* if it has not got a nodeID it is an attribute */
    if(localID.objid == NULL_OBJID) {

      /* delete this row */
      VDfrmDeleteRows(form,gadget,row,1);
      
    } else {
      /* we hit a node so quit */
      break;
    }
  }
  retFlag = 1;
wrapup:
  /* update the number of rows */
  VIfld_get_num_rows(form, gadget, &rows);
  FIfld_set_num_rows(form, gadget, rows);
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}


/******************************************
 *
 * Get the data back from a row ~pn
 *
 ******************************************/
IGRstat VDtvwFormGetTreeRowData(Form form,
				IGRint gadget,
				IGRint row,
				IGRchar *attr,
				IGRchar *exp,
				IGRchar *data,
				TGRid   *nodeID,
				IGRint  *selFlag,
				IGRint  *pos)
{
  VDASSERT_FN("VDtvwFormGetTreeRowData");
  IGRint retFlag = 0;
  IGRint rows,sFlag,rPos,osnum,objid;
  IGRchar nodeData[128],clip[128],*p;
  
    /* say hi */
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  /* args check */
  VDASSERTW(form);
  VDASSERTW(attr);
  VDASSERTW(exp);
  VDASSERTW(nodeID);

  /* inits */
  strcpy(attr,EXP_EMP);
  strcpy(exp,EXP_EMP);
  nodeID->objid = NULL_OBJID;

  /* get the number of rows */
  VIfld_get_num_rows(form, gadget, &rows);
  if(rows < row) goto wrapup;

  /* fetch this row */
  VIfld_get_text(form, gadget,row,0, 1, attr,&sFlag,&rPos);
  VIfld_get_text(form, gadget,row,1, 1, exp,&sFlag,&rPos);
  VIfld_get_text(form, gadget,row,2, 80, data,selFlag,pos);
  vdfrm$GetText (	form	= form,
			gadget	= gadget,
			col	= 3,
			row	= row,
			objID	= nodeID );

  retFlag = 1;
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}
/******************************************
 *
 * This will find a node row on the form ~pn
 *
 ******************************************/	
IGRstat VDtvwFormFindNode(Form    form,
			  IGRint  gadget,
			  TGRid   baseID,
			  IGRint *rowFound)
{
  VDASSERT_FN("VDtvwFormFindNode");
  IGRint retFlag = 0;
  IGRint nodeCnt;
  IGRint i = 0;
  IGRint level;
  IGRchar attr[128],exp[128],data[128],*p;
  IGRint row,rows,offset;
  IGRint col,selFlag,pos;
  TGRid  rowID;

    /* say hi */
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }  
  /* init */
  *rowFound = -1;

  /* checks */
  VDASSERTW(form);
  if(gadget < 11) goto wrapup;
  if(baseID.objid == NULL_OBJID) goto wrapup;

  /* get the number of rows */
  VIfld_get_num_rows(form, gadget, &rows);

    /* scan down the tree and get the row */
  for(row = 0;row < rows;row++) {
    VDtvwFormGetTreeRowData(form,gadget,row,attr,exp,data,&rowID,&selFlag,&pos);
    /* if we found it */
    if((rowID.objid == baseID.objid) && (baseID.osnum == rowID.osnum)) {
      break;
    } 
  }
  /* make sure we found it */
  if(!((rowID.objid == baseID.objid) && (baseID.osnum == rowID.osnum))) goto wrapup;
  *rowFound = row;
  retFlag = 1;
wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
} 
			 
/******************************************
 *
 * Contract a node in the tree
 * (delete any child rows below until expansion
 * level is the same as current) ~pn
 *
 ******************************************/	
IGRstat VDtvwFormContractNode(Form   form,
			      IGRint gadget,
			      TGRid  baseID)
{
  VDASSERT_FN("VDtvwFormContractNode");
  IGRint retFlag = 0;
  IGRint nodeCnt;
  IGRint i = 0;
  IGRint level;
  IGRchar attr[128],exp[128],data[128],*p;
  IGRint row,rows,offset,baseRow,baseOffset,rowCnt;
  IGRint col,selFlag,pos;
  TGRid  nodeID;

    /* say hi */
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }  
  row = rows = offset = baseRow = baseOffset = rowCnt = 0;

  /* contract the attributes */
  VDtvwFormContractAttrs(form,gadget,&baseID);

  /* get the number of rows */
  VIfld_get_num_rows(form, gadget, &rows);
  if(rows < 1) goto wrapup;
  
  /* find the row for the node */
  VDtvwFormFindNode(form,
		    gadget,
		    baseID,
		    &baseRow);
  /* if it was not found */
  if(baseRow < 0) goto wrapup;

  data[0] = '\0';
  
  VDtvwFormGetTreeRowData(form,gadget,baseRow,attr,exp,data,&baseID,&selFlag,&pos);

  if(baseID.objid == NULL_OBJID) goto wrapup;
  VIfld_set_text(form, gadget, baseRow, 1, EXP_CON, 0);
  VIfld_set_text(form, gadget, baseRow, 0, EXP_CON, 0);
  /* get the offset set up */
  p = data;
  for(i = 0;i < strlen(data);i++) {
    if(*p == ' ') baseOffset++;
    p++;
  }

  /* start going down the rows */
  row = baseRow +1;
  while (1) {
    /* get the number of rows */
    VIfld_get_num_rows(form, gadget, &rowCnt);
    if(rowCnt == row) break;
    VDtvwFormGetTreeRowData(form,gadget,row,attr,exp,data,&baseID,&selFlag,&pos); 
    /* get the offset */
    p = data;
    offset = 0;
    for(i = 0;i < strlen(data);i++) {
      if(*p == ' ') offset++;
      p++;
    }
    if(offset <= baseOffset) break;
    //    rows--;
    VDfrmDeleteRows(form,gadget,row,1);
  }
  
  
  retFlag = 1;
wrapup:
  /* update the number of rows */
  VIfld_get_num_rows(form, gadget, &rows);
  FIfld_set_num_rows(form, gadget, rows);
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
} 
				
/******************************************
 *
 * Expand any node in the tree 
 * (insert blank rows for expansion)
 * place all the child nodes in the blank rows
 * ~pn
 *
 *****************************************/
IGRstat VDtvwFormExpandNode(Form   form,
			    IGRint gadget,
			    TGRid *nodeID)
{
  VDASSERT_FN("VDtvwFormExpandNode");
  IGRint retFlag = 0;
  IGRint nodeCnt;
  IGRint i = 0;
  IGRint row,rows,offset;
  IGRint col,selFlag,pos;
  IGRchar attr[128],exp[128],data[128],*p;
  TGRid  rowID,childID;
  
    /* say hi */
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  /* inits */
  row = rows = col = selFlag = pos  = offset = 0;
  

  /* args check */
  VDASSERTW(form);
  VDASSERTW(nodeID);
  if(nodeID->objid == NULL_OBJID) goto wrapup;
  /* contract the attributes */
  VDtvwFormContractAttrs(form,gadget,nodeID);

  /* get the number of rows */
  VIfld_get_num_rows(form, gadget, &rows);

  /* scan down the tree and get the row */
  for(row = 0;row < rows;row++) {
    VDtvwFormGetTreeRowData(form,gadget,row,attr,exp,data,&rowID,&selFlag,&pos);
    /* if we found it */
    if((rowID.objid == nodeID->objid) && (nodeID->osnum == rowID.osnum)) {
      if(!strcmp(exp,EXP_CON)) VIfld_set_text(form, gadget, row, 1, EXP_EXP, 0);
      VIfld_set_text(form, gadget, row, 0, EXP_CON, 0);
      break;
    }  
  }
  /* make sure we found it */
  if(!((rowID.objid == nodeID->objid) && (nodeID->osnum == rowID.osnum))) goto wrapup;

  /* get the offset set up */
  p = data;
  for(i = 0;i < strlen(data);i++) {
    if(*p == ' ') offset++;
    p++;
  }

  /* count up its kids */
  for(i = 0; VDctxGetNthTreeChild(nodeID,i,&childID); i++) {
    /* first time you get a kid set the expansion flag on the parent */
    if(i == 0) {
      VIfld_set_text(form, gadget, row, 1, EXP_EXP, 0);
    }
    row++;
    VDfrmInsertBlankRow (form,gadget, row);
    VDtvwFormPlaceTreeItem( form,gadget,row,&childID,
			    offset,0,0,0);
  }
  
  retFlag = 1;
  
 wrapup:
  /* update the number of rows */
  VIfld_get_num_rows(form, gadget, &rows);
  FIfld_set_num_rows(form, gadget, rows);
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}			     
/*******************************************
 *
 * place a setID or TreeID or nodeID at the 
 * top for a list of nodes (clears any nodes in list)
 * always starts a new display no selections etc
 * cleans up the funky data sent in and 
 * makes sure that nobody messes up ~pn
 *
 *******************************************/
IGRstat VDtvwFormPlaceNodeTop(Form    form,
			      IGRint  gadget,
			      TGRid  *topID)
{
  VDASSERT_FN("VDtvwFormPlaceNodeTop");
  IGRint retFlag = 0;
  IGRint offset,attrFlag,exprFlag,selFlag,row;
  
    /* say hi */
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  
  /* CHECKS */
  VDASSERTW(topID);
  if(topID->objid == NULL_OBJID) goto wrapup;
  
  /* inits */
  offset = attrFlag = exprFlag = selFlag = row = 0;

  /* refresh the gadget */ 
  FIg_reset(form,gadget);
  
  /* place the topID */
  VDtvwFormPlaceTreeItem( form,gadget,row,topID,
			  offset,attrFlag,exprFlag,selFlag);
  
  retFlag = 1;
  
 wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}
/********************************************
 *
 * Copy items to the multicolumn gadget 
 * just places the data where you say to put 
 * the data. ~pn
 *
 *******************************************/
IGRstat VDtvwFormPlaceTreeItem(Form    form,
			       IGRint  gadget,
			       IGRint  row,
			       TGRid   *nodeID,
			       IGRint  offset,
			       IGRint  attrFlag,
			       IGRint  exprFlag,
			       IGRint  selFlag) 
{
  VDASSERT_FN("VDtvwFormPlaceTreeItem");
  IGRint retFlag = 0;
  IGRint rows = 0;
  IGRchar attr[128],exp[128];
  IGRchar data[128];
  IGRchar node[128];
  IGRchar buf[128];
  IGRint  i = 0;
  TGRid   childID;
  IGRint  cnt;
  TVDfld  flds[VDFLD_MAX_CNT];
  IGRchar nodeName[128],nodeType[128];
  TVDctxBaseInfo baseInfo;

  /* say hi */
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
    /*
    printf("row      = [%d]\n",row);
    printf("offset   = [%d]\n",offset);
    printf("gadget   = [%d]\n",gadget);
    printf("attrFlag = [%d]\n",attrFlag);
    printf("exprFlag = [%d]\n",exprFlag);
    printf("selFlag  = [%d]\n",selFlag);
    printf("nodeID [%d] [%d] \n",nodeID->osnum,nodeID->objid);
    */
  }
  

  /* check the form */
  VDASSERTW(form);
  VDASSERTW(nodeID);
  if(nodeID->objid == NULL_OBJID) goto wrapup;
  
  /* inits */
  node[0] = '\0';
  attr[0] = '\0';
  exp[0] = '\0';
  data[0] = '\0';
  buf[0] = '\0';
  strcpy(exp,EXP_EMP);
  strcpy(attr,EXP_EMP);
  nodeType[0] = '\0';
  nodeName[0] = '\0';

  /* check the data */
  if(row < 0) row = 0;
  if(offset   < 0) offset   = 0;
  
  if(!nodeID) goto wrapup;
  if(nodeID->objid == NULL_OBJID) goto wrapup;

  /* get the number of rows posted already */
  VIfld_get_num_rows(form, gadget, &rows);

  /* go to the next row if you told it to go too far */
  if(row > rows) row = rows + 1;

  /* if it has attributes set the attr to the specified setting */
  VDctxGetFldAtrsID(NULL,nodeID,&cnt,flds);
  if(cnt > 0) {
    if(attrFlag > 0) {
      strcpy(attr,EXP_EXP);
    } else {
      strcpy(attr,EXP_CON);
    }
  }

  strcpy(exp,EXP_EMP);
  /* if it has children set the exp state to the specified setting */
  VDctxGetNthTreeChild(nodeID,i,&childID);
  if(childID.objid != NULL_OBJID) { 
    if(exprFlag > 0) {
      strcpy(exp,EXP_EXP);
    } else {
      strcpy(exp,EXP_CON);
    }
  }
  

  /* set up the data for view */
  if(traceFlag) printf("\t\t***** nodeID [%d][%d]\n",nodeID->osnum,nodeID->objid);
  //  vdobj$Print(objID = nodeID);
  
  nodeType[0] = '\0';
  VDctxGetNodeType(nodeID,nodeType);
  //sprintf(nodeName,"%d",nodeID->objid);
  nodeName[0] = '\0';
  VDctxGetNodeName(nodeID,nodeName);
  //VDctxGetBaseInfo(nodeID,&baseInfo);
  //strcpy(nodeType,baseInfo.nodeType);
  //strcpy(nodeName,baseInfo.nodeName);
  
  sprintf(buf,"%s %s",nodeType,nodeName);
  if(traceFlag) printf("node is [%s %s]\n",nodeType,nodeName);
  
  strcpy(data,buf);
  for(i = 0;i < offset;i++) {
    sprintf(data,"%s%s",EXP_EMP,buf);
    strcpy(buf,data);
  }
 
  /* place the data in the form */
  VIfld_set_text(form, gadget, row, 0, attr, 0);
  VIfld_set_text(form, gadget, row, 1, exp, 0);
  VIfld_set_text(form, gadget, row, 2, data, selFlag);
  vdfrm$SetText (	form	= form,
			gadget	= gadget,
			row	= row,
			col	= 3,
			objID	= nodeID );
  

  retFlag = 1;
  
 wrapup:
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

/********************************************
 *
 * Fills the Attribute Names in the list from 
 * the settings on the form ~pn*
 *
 ********************************************/
/* 
 * All allocations are to be freed at the end of the 
 * operations 
 */
IGRint VDtvwFormFillAttrNameList(Form form)
{
  VDASSERT_FN("VDtvwFormFillAttrNameList");
  IGRint    retFlag = 0;
  TGRid     *defIDs = NULL;
  TGRid     *outIDs,nodeID;
  IGRint    defIDsCnt = 0;
  IGRint    outIDsCnt = 0;
  IGRchar   hilite[128],parent[128],bln[128];
  IGRint    modTog,stageTog,nameTog,attrTog,itemTog;
  IGRchar   **attrNames;
  IGRint    attrNamesCnt = 0;
  TVDfld    flds[VDFLD_MAX_CNT];
  IGRint    fldsCnt = 0;
  IGRint    i,j;
  IGRchar   data[1028],nameStr[1028],*p;
  IGRint    gadget;
  
  traceFlag = 0;
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  /* init */
  gadget = VDTVW_T_ANAME;

  /* args checks */
  VDASSERTW(form);
  if(gadget < 11) goto wrapup;

  /* first things first clear the gadget */
  FIg_reset( form, gadget );
  
   /* get the toggle settings off the form */
  VDtvwGetToggleState(form,&modTog,&stageTog,&nameTog,&attrTog,&itemTog);

  /* apply some rules here for speedup (save some steps) */
  if(attrTog == 0) goto wrapup;

  /* give a status notice for users */
  FIg_set_text(form,10,"Updating Attribute Names.");
  UI_status("Processing Attribute Names");

  /* get the defIDs */
  VDtvwGetDefIDsList(&defIDs,&defIDsCnt);
  if((defIDs == NULL) || (defIDsCnt < 1)) goto wrapup;
  /* get the roll text settings */
  VDtvwGetRollText(form,hilite,parent,bln);
  UI_status("Getting Selection List");
  /* get the unfiltered IDs per the selection (Ready for Selection)*/
  VDtvwListGetUnfiltered(defIDs,&defIDsCnt,parent,&outIDs,&outIDsCnt);
  if(outIDsCnt < 1) goto wrapup;
  UI_status("Filtering Selection List");
  /* filter out the model objects that don't apply per the filter */
  if(modTog == 1) VDtvwListFilterModelObjs(&outIDs,&outIDsCnt);
  if(outIDsCnt < 1) goto wrapup;

  UI_status("Filling Name List");
  /* get the names into a list */
  for(i = 0;i < outIDsCnt;i++) {
    nodeID = outIDs[i];
    if(nodeID.objid != NULL_OBJID) {
      VDctxGetFldAtrsID(NULL,&nodeID,&fldsCnt,flds);
      for(j = 0; j < fldsCnt; j++) {
	/* get the field description */
	data[0] = '\0';
	p = data;
	VDfldGetFldDesc(&flds[j],p);
	/* clip this data */
	vdtr$GetDelimitedStr(impStr = data,
			     outStr = nameStr,
			     delChr = ' ',
			     posStr = 2); 
	VDtvwAddStrListUnique(nameStr,&attrNames,&attrNamesCnt);
      }
    }
  }

  if(attrNamesCnt < 1) goto wrapup;
  UI_status("Putting data on form");
  /* copy the list to the form */
  for(i = 0;i < attrNamesCnt;i++) {
    vdfrm$SetListText( form   = form,
		       gadget = gadget,
		       row    = i,
		       txt    = attrNames[i]);
  }
  /* fix the list on the form */
  VDtvwFormMakeTextItemsUniqueAUp(form,gadget,1,0);
  
  retFlag = 1;
wrapup:
  /* give a status notice for users */
  if(attrTog == 1) {
    FIg_set_text(form,10,"Done Processing Attribute Names.");
    UI_status("Done Processing Attribute Names");
  }
  
  VDtvwAttrViewCtrl(form);
  if(outIDsCnt > 0)    _FREE( outIDs );
  if(defIDsCnt > 0)    _FREE( defIDs );
  if(attrNamesCnt > 0) _LOOPFREE( attrNames,attrNamesCnt );
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

/********************************************
 *
 * Fill the Attribute Values list 
 *
 ********************************************/
IGRint VDtvwFormFillAttrValuesList(Form form)
{
  VDASSERT_FN("VDtvwFormFillAttrValuesList");
  IGRint    retFlag = 0;
  TGRid     *defIDs = NULL;
  TGRid     *outIDs;
  TGRid     nodeID;
  IGRint    defIDsCnt = 0;
  IGRint    outIDsCnt = 0;
  IGRchar   hilite[128],parent[128],bln[128];
  IGRint    modTog,stageTog,nameTog,attrTog,itemTog;
  IGRchar   sets[128],stage[128],name[128],afrom[128],ato[128],attrName[128],attrValue[128];
  IGRchar   **attrValues;
  IGRint    attrValuesCnt = 0;
  TVDfld    flds[VDFLD_MAX_CNT];
  IGRint    fldsCnt = 0;
  IGRint    i,j;
  IGRchar   data[128],nameStr[128],valueStr[128],*p;
  IGRint    gadget,source;
   
  /* say hi */
  if(traceFlag) printf(">>> %s %s\n",ffn(),fn);

  /* init */
  gadget = VDTVW_T_AVAL;
  source = VDTVW_T_ANAME;
  
  /* args checks */
  VDASSERTW(form);

  /* first things first clear the gadget */
  FIg_reset( form, gadget );
  
   /* get the toggle settings off the form */
  VDtvwGetToggleState(form,&modTog,&stageTog,&nameTog,&attrTog,&itemTog);

  /* apply some rules here for speedup (save some steps) */
  if(attrTog == 0) goto wrapup;

  /* give a status notice for users */
  FIg_set_text(form,10,"Updating Attribute Values.");
  UI_status("Processing Attribute Values");
  
  /* get the defIDs */
  VDtvwGetDefIDsList(&defIDs,&defIDsCnt);
  if((defIDsCnt < 1) || (defIDs == NULL)) goto wrapup;

 /* get the roll text settings */
  VDtvwGetRollText(form,hilite,parent,bln);

  UI_status("Getting Selection List");
  /* get the unfiltered IDs per the selection (Ready for Selection)*/
  /* this list is already fixed by its source (range)/(item) (parent) */
  VDtvwListGetUnfiltered(defIDs,&defIDsCnt,parent,&outIDs,&outIDsCnt);
  if(outIDsCnt < 1) goto wrapup;
  UI_status("Filtering Selection List");
  /* filter out the model objects that don't apply per the filter */
  if(modTog == 1) VDtvwListFilterModelObjs(&outIDs,&outIDsCnt);
  if(outIDsCnt < 1) goto wrapup;

  /* get the data from the other text boxes */
  VDtvwGetSelectionText(form,sets,stage,name,afrom,ato,attrName,attrValue);

  /* filter the attribute values by name */
  VDtvwFilterNodeIDsByAttrName(attrName,&outIDs,&outIDsCnt);
  /*
  printf(" done AttrName outIDsCnt[%d]\n",outIDsCnt);
  for(i = 0;i < outIDsCnt;i++) {
    printf("outIDs[%d] [%d][%d]\n",i,outIDs[i].osnum,outIDs[i].objid);
  }
  */
  if(outIDsCnt < 1) goto wrapup;
  UI_status("Making List of Values");
  /* go get the attribute Values for this list */
  for(i = 0;i < outIDsCnt;i++) {
    if(outIDs[i].objid != NULL_OBJID) {
      nodeID = outIDs[i];
      VDctxGetFldAtrsID(NULL,&nodeID,&fldsCnt,flds);
      for(j = 0; j < fldsCnt; j++) {

	/* get the field description */
	data[0] = '\0';
	p = data;
	VDfldGetFldDesc(&flds[j],p);

	/* clip this data */
	vdtr$GetDelimitedStr(impStr = data,
			     outStr = nameStr,
			     delChr = ' ',
			     posStr = 2); 
	VD_stripString( nameStr );

	/* nameStr is the attrName (for this node) */
	if(!strcmp(nameStr,attrName)) {

	  /* get the actual attribute value from the field */
	  vdtr$GetDelimitedStr(impStr = data,
			       outStr = valueStr,
			       delChr = '=',
			       posStr = 2); 
	  VD_stripString( valueStr );
	  VDtvwAddStrListUnique(valueStr,&attrValues,&attrValuesCnt);
	}
      }
    }
  }

 if(attrValuesCnt < 1) goto wrapup;
  UI_status("Placing Values on Form");
  /* copy the list to the form */
  for(i = 0;i < attrValuesCnt;i++) {
    vdfrm$SetListText( form   = form,
		       gadget = gadget,
		       row    = i,
		       txt    = attrValues[i]);
  }

  /* clean up the display */
  VDtvwFormMakeTextItemsUniqueAUp(form,gadget,1,0);

  retFlag = 1;
wrapup:

  /* give a status notice for users */
  if(attrTog == 1) {    
    FIg_set_text(form,10,"Done Processing Attribute Values.");
    UI_status("Done Processing Attribute Values");
  }
  

  VDtvwAttrViewCtrl(form);
  if((outIDsCnt < 1)  && (attrTog == 1)) {
    FIg_set_text( form,10,"Selection: no nodes match"); 
  }
  
  if(outIDsCnt > 0)     _FREE( outIDs );
  if(defIDsCnt > 0)     _FREE( defIDs );
  if(attrValuesCnt > 0) _LOOPFREE( attrValues,attrValuesCnt );
  
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}
/********************************************
 *
 * Traffic Director for the controls to pick 
 * a list of nodes and get it hilited
 *
 ********************************************/
IGRint VDtvwListsSelection(Form form,IGRint gadget)
{
  VDASSERT_FN("VDtvwListsSelection");
  IGRint    retFlag = 0;
  TGRid     *defIDs = NULL;
  TGRid     *outIDs;
  TGRid     nodeID,rootID;
  IGRint    defIDsCnt = 0;
  IGRint    outIDsCnt = 0;
  IGRchar   hilite[128],parent[128],bln[128];
  IGRint    modTog,stageTog,nameTog,attrTog,itemTog;
  IGRchar   sets[128],stage[128],name[128],afrom[128],ato[128],attrName[128],attrValue[128];
  IGRchar   **attrValues;
  IGRint    attrValuesCnt = 0;
  TVDfld    flds[VDFLD_MAX_CNT];
  IGRint    fldsCnt = 0;
  IGRint    i,j;
  IGRchar   data[128],nameStr[128],valueStr[128],*p;
  
  /* say hi */
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  /* get the toggle settings off the form */
  VDtvwGetToggleState(form,&modTog,&stageTog,&nameTog,&attrTog,&itemTog);

  /* 
   * get the defIDs 
   * This is the set of IDs defined by itemTog(range/index)
   */
  if(traceFlag) printf("Getting defIDs\n");
  VDtvwGetDefIDsList(&defIDs,&defIDsCnt);
  if(traceFlag) printf("defIDsCnt = %d\n",defIDsCnt);
  if((defIDsCnt < 1) || (defIDs == NULL)) goto wrapup;

 /* get the roll text settings */
  VDtvwGetRollText(form,hilite,parent,bln);

  FIg_set_text(form,10,"Getting List");
  UI_status("Getting List");

  /* get the unfiltered IDs per the selection (Ready for Selection)*/
  /* this list is already fixed by its source (range)/(item) (parent) */
  VDtvwListGetUnfiltered(defIDs,&defIDsCnt,parent,&outIDs,&outIDsCnt);
  if(outIDsCnt < 1) goto wrapup;

  FIg_set_text(form,10,"Filtering List By Object");
  UI_status("Filtering List By Object");

  /* filter out the model objects that don't apply per the filter */
  if(modTog == 1) VDtvwListFilterModelObjs(&outIDs,&outIDsCnt);
  if(outIDsCnt < 1) goto wrapup;

  /* get the data from the other text boxes */
  VDtvwGetSelectionText(form,sets,stage,name,afrom,ato,attrName,attrValue);

  FIg_set_text(form,10,"Filtering By Attribute");
  UI_status("Filtering By Attribute");

  VDtvwListFilterNodeIDsByAttr(attrName,
			       attrValue,
			       bln,
			       &outIDs,
			       &outIDsCnt);

  if(traceFlag) {
    printf(" done AttrName outIDsCnt[%d]\n",outIDsCnt);
    for(i = 0;i < outIDsCnt;i++) {
      printf("outIDs[%d] [%d][%d]\n",i,outIDs[i].osnum,outIDs[i].objid);
    }
  }

  if(outIDsCnt < 1) goto wrapup;
  
  FIg_set_text(form,10,"Processing View");
  UI_status("Processing View");

  VDtvwFormGetTreeID(form,VDTVW_MCOL_TREE,&rootID);
  for(i = 0;i < outIDsCnt;i++) {
    nodeID = outIDs[i];
    /* hilite the list */
    if((gadget == VDTVW_B_SEL_1) || 
       (gadget == VDTVW_B_SEL_2) || 
       (gadget == VDTVW_B_SEL_3)) {
      VDtvwFormSetHiliteNodeExp(form,VDTVW_MCOL_TREE,nodeID,rootID);
    } 
    /* unhilite the list */
    if((gadget == VDTVW_B_CLR_1) || 
       (gadget == VDTVW_B_CLR_2) || 
       (gadget == VDTVW_B_CLR_3)) {
      VDtvwFormSetUnHiliteNode(form,VDTVW_MCOL_TREE,&nodeID);
    }  
  }
  

  retFlag = 1;
wrapup:

  if(outIDsCnt < 1) {
    FIg_set_text( form,10,"Selection: no nodes match"); 
  }
  
  if(defIDsCnt > 0) _FREE( defIDs );
  if(outIDsCnt > 0) _FREE( outIDs );
 
  /* say bye */
  if (traceFlag) printf("<<< %s %s(%d)\n",ffn(),fn,retFlag);
  return retFlag;
}

static IGRint  intcmp( int* e1, int* e2 )
{
	return (*e1 - *e2);
}
#if 0
/********************************************
 *
 *
 *
 ********************************************/
IGRint VDtvw(TGRid *nodeID)
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



