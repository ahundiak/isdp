 /* $Id: VDct1StdAssys.c,v 1.2 2001/02/11 17:15:54 ahundiak Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/tree/VDct1StdAssys.C
 *
 * Description: Standard Assy Tree Customization
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1StdAssys.c,v $
 *      Revision 1.2  2001/02/11 17:15:54  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.1  2001/01/14 16:29:17  art
 *      sp merge
 *
 * Revision 1.12  2000/08/25  19:59:20  pinnacle
 * ah
 *
 * Revision 1.10  2000/08/24  13:48:16  pinnacle
 * ah
 *
 * Revision 1.9  2000/08/23  14:51:58  pinnacle
 * ah
 *
 * Revision 1.8  2000/08/17  12:56:48  pinnacle
 * js
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/10/00  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDobj2.h"
#include "VDrisc.h"
#include "VDos.h"
#include "VDassert.h"

#include "VDct1.h"
#include "VDct1Tree.h"
#include "VDct1Tree2.h"

#include "VDct1Ris.h"
#include "VDct1Part.h"
#include "VDct1Attrs.h"
#include "VDct1Forms.h"
#include "VDct1Trace.h"

VDASSERT_FFN("vdct1/tree/VDct1StdAssys.C");

#define MY_TREE VDCT1_TREE_TYPE_STD_ASSYS

/* --------------------------------------------------
 * Validate convert node type
 * do not allow anything
 */
static IGRstat isConvertNodeValid(TVDct1JD *nodeJD,
				  IGRchar  *activeNodeType,
				  IGRchar  *newNodeType)
{
  VDASSERT_FN("isConvertNodeValid");
  IGRstat retFlag = 0;

  // Say hi
  if (traceFlag) printf (">>> %s %s\n",ffn(),fn);
 
  // Arg check
  VDASSERTW(activeNodeType);
  VDASSERTW(newNodeType);

  if (!strcmp(activeNodeType,VDCT1_NODE_TYPE_STD_ASSY2)) {    
    if (!strcmp(newNodeType,VDCT1_NODE_TYPE_STD_ASSY6)) {
      retFlag = 1;
      goto wrapup;
    }
  }
  
wrapup:
  if (traceFlag) printf ("<<< %s %s %d\n",ffn(),fn,retFlag);
  return retFlag;
}

/* -----------------------------------------------
 * Returns list of product structure children
 */
IGRstat VDct1QryPS(TVDrisInfo *ris, IGRchar *parent_cage_num)
{
  VDASSERT_FN("VDct1QryPS");
  IGRstat retFlag = 0;
  
  // Arg check
  VDASSERTW(ris);
  ris->rows = 0;
  VDASSERTW(parent_cage_num && *parent_cage_num);
  
  // Build it
  sprintf(ris->sql,
	  "Select %s,%s,%s,%s,%s from %s where %s = '%s' order by %s;",

	  VDCT1_RIS_COLN_PS_PARENT_CAGE_NUM,
	  VDCT1_RIS_COLN_PS_CHILD_CAGE_NUM,
	  VDCT1_RIS_COLN_PS_SORT,
	  VDCT1_RIS_COLN_PS_QTY,
	  VDCT1_RIS_COLN_PS_DATE,
	  VDCT1_RIS_TBLN_PS,
	  VDCT1_RIS_COLN_PS_PARENT_CAGE_NUM,
	  parent_cage_num,
	  VDCT1_RIS_COLN_PS_SORT);

  VDrisQuery(ris,NULL);
  
  retFlag = 1;
  
 wrapup:
  return retFlag;
}


/* -----------------------------------------------
 * Check to see if the product structure has already
 * been posted and if so, see if any changes have been mase
 */
static IGRstat doesNodeNeedPosting(TVDct1JD *nodeJD,  
				   IGRint    deleteFlag)
{
  VDASSERT_FN("doesNodeNeedPosting");
  IGRstat retFlag = 0;

  TVDctBaseInfo baseInfo;
  IGRchar sql[256];
  
  // Grab it's name
  VDjt1GetBaseInfo(nodeJD,&baseInfo);
  VDASSERTW(*baseInfo.nodeName);
  
  /* ---------------------------------------------
   * A delete flag of 1 means don't mess around
   * Looking for changes, just delete it
   */
  if (deleteFlag == 1) {
    sprintf(sql,"Delete from %s where %s = '%s';",
	    VDCT1_RIS_TBLN_PS,
	    VDCT1_RIS_COLN_PS_PARENT_CAGE_NUM,
	    baseInfo.nodeName);
    VDrisExecute(sql);
    retFlag = 1;
    goto wrapup;
  }
  
  // Implement the rest later

 wrapup:
  return retFlag;
}
/* --------------------------------------------------
 * Pull down means to go up the tree and find a parent
 * node with the attribute in question and return it's value
 * Value must actually have some value
 */
static IGRstat pullDownAttrValue(TVDct1JD *nodeJD, IGRchar *name, IGRchar *value)
{
  VDASSERT_FN("pullDownAttrValue");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDct1JD parentJD;
  
  // Arg Check
  VDASSERTW(value);
  *value = 0;
  VDASSERTW(name);
  VDASSERTW(nodeJD && nodeJD->cl);

  // Done
  if (nodeJD->id.objid == NULL_OBJID) goto wrapup;
  
  // See if this node has it
  sts = VDjt1GetAttr(nodeJD,name,value);
  if ((sts & 1) && (*value)) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Try it's parent
  VDjt1GetTreeParent(nodeJD,&parentJD);
  
  retFlag = pullDownAttrValue(&parentJD,name,value);
    
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Post a node which for this tree means
 * posting the actual product structure
 */
static IGRstat postNode(TVDct1JD *nodeJD, FILE *file)
{
  VDASSERT_FN("postNode");

  IGRstat retFlag = 1;
  IGRstat sts;
  
  TVDctBaseInfo baseInfo;
  TVDctBaseInfo childBaseInfo;
  IGRchar       child_cage_num[64];
  IGRchar       comm_code[64];
  IGRchar       qty[64];
  IGRint        item_type;
  
  IGRint i;
  TVDct1JD childJD;

  IGRchar sql[512];
  
  // Init
  if (file == NULL) file = stdout;
  
  // Only for certain types
  VDjt1GetBaseInfo(nodeJD,&baseInfo);
  VDASSERTW(*baseInfo.nodeType);
  
  // Only the master can be posted
  if (strcmp(baseInfo.setName,"MASTER")) goto wrapup;

  // For top nodes, recurse down
  if (!strcmp(baseInfo.nodeType,VDCT1_NODE_TYPE_STD_ASSYS) ||
      !strcmp(baseInfo.nodeType,VDCT1_NODE_TYPE_COMM_CODE)) {
    
    for(i = 0; VDjt1GetTreeChild(nodeJD,i,&childJD); i++) {
      VDjt1PostNode(&childJD,file);
      
    }
    goto wrapup;
    
  }
  
  // Bottom type nodes get ignored
  item_type = 0;
  if (!strcmp(baseInfo.nodeType,VDCT1_NODE_TYPE_STD_ASSY2)) item_type = 2;
  if (!strcmp(baseInfo.nodeType,VDCT1_NODE_TYPE_STD_ASSY6)) item_type = 6;
  if (item_type == 0) goto wrapup;
    
  // Make sure it needs posting, might already be posted
  sts = doesNodeNeedPosting(nodeJD,1);
  if (!(sts & 1)) goto wrapup;
  
  // Basically post each parent/child pair
  for(i = 0; VDjt1GetTreeChild(nodeJD,i,&childJD); i++) {

    VDjt1GetBaseInfo(&childJD,&childBaseInfo);
    VDct1ReadCageNumForIsdpCageNum(childBaseInfo.nodeName,child_cage_num);

    VDjt1GetAttr(&childJD,VDCT1_ATTR_ITEM_QTY,qty);
    
    sprintf(sql,
	    "Insert into %s values ('%s','%s',%d,'%s','%s');",
	    VDCT1_RIS_TBLN_PS,
	    baseInfo.nodeName,
	    child_cage_num,
	    i,
	    qty,
	    "DATE");
    VDrisExecute(sql);  
  }
  // See if anyting actually posted
  if (i == 0) {
    retFlag = 1;
    goto wrapup;
  }
  fprintf(file,"Posted %s with %d children\n",baseInfo.nodeName,i);

  // Type and Comm Code need setting in items
  pullDownAttrValue(nodeJD,VDCT1_ATTR_COMM_CODE,comm_code);
  sprintf(sql,"Update %s set %s = %d, %s = '%s' where %s = '%s';",
	  VDCT1_RIS_TBLN_ITEMS,
	  VDCT1_RIS_COLN_ITEMS_ITEM_TYPE,
	  item_type,
	  VDCT1_RIS_COLN_ITEMS_COMM_CODE,
	  comm_code,
	  VDCT1_RIS_COLN_ITEMS_ITEM_CAGE_NUM,
	  baseInfo.nodeName);
  VDrisExecute(sql);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/******************************************************
 * Command Interface overrides
 */

/* -----------------------------------------------
 * Returns value for form gadget
 * Every time we get a new active node, or a new parent,
 * this will get called.
 */
static IGRstat getGadgetText(TVDct1JD *nodeJD,
			     IGRchar  *formName,
			     IGRint    gadget,
			     IGRint    nth,
			     IGRchar  *txt)
{
  VDASSERT_FN("getGadgetText");

  IGRstat       retFlag = 0;
  
  TVDctBaseInfo baseInfo;
  TVDct1JD parentClassJD;

  // Arg Check
  VDASSERTW(txt != NULL);
  *txt = 0;
  VDASSERTW(formName != NULL);
    
  // Say hi
  if (traceFlag) printf (">>> %s %s\n",ffn(),fn);
  

  // Need baseInfo
  _RTCJDB(nodeJD)->getBaseInfo(nodeJD,&baseInfo);
  VDASSERTW(*baseInfo.nodeType);

  // Tree Form
  if (!strcmp(formName,VDCT_FORM_TREE_F_NAME)) {
    
    switch(gadget) {
      case VDCT_FORM_TREE_G_DISPLAY:

	retFlag = 1;
	
	switch(nth) {
	  case 0: strcpy(txt,"1 ALL     Nodes");  break;
	  case 1: strcpy(txt,"2 Active  Nodes");  break;
	  case 2: strcpy(txt,"3 Latest  Frozen"); break;
	  case 3: strcpy(txt,"4 Deleted NODES");  break;
	  default: retFlag = 0;
	}
	break;	
    }
    goto wrapup;
  }
  
  // Node Form
  if (!strcmp(formName,VDCT_FORM_NODE_F_NAME)) {
    
    switch(gadget) {
    case VDCT_FORM_NODE_G_DOIT:
      retFlag = 1;
      if(!strcmp(baseInfo.nodeType,VDCT1_NODE_TYPE_STD_ASSYS)) {
	switch(nth) {
	  case 0: strcpy(txt,"1 Review  Node");      break;
	  case 1: strcpy(txt,"2 Create  Node");      break;
	  case 2: strcpy(txt,"C Convert Node Type"); break;
	  case 3: strcpy(txt,"D Delete  Node");      break;
	  case 4: strcpy(txt,"M Move    Node");      break;
	  case 5: strcpy(txt,"X Paste   MBOM");      break;
	  case 6: strcpy(txt,"9 Post    Node(s)");   break;
	default: retFlag = 0;
	}
      }
      else {	
	switch(nth) {
	  case 0: strcpy(txt,"1 Review  Node");       break;
	  case 1: strcpy(txt,"2 Create  Node");       break;
	  case 2: strcpy(txt,"3 Create  Model Node"); break;
	  case 3: strcpy(txt,"C Convert Node Type");  break;
	  case 4: strcpy(txt,"D Delete  Node");       break;
	  case 5: strcpy(txt,"M Move    Node");       break;
	  case 6: strcpy(txt,"P Paste   Node(s)");    break;
	  case 7: strcpy(txt,"X Paste   MBOM");       break;
	  case 8: strcpy(txt,"9 Post    Node(s)");    break;
	  default: retFlag = 0;
	}
      }
      
      break;	
           
    }
    goto wrapup;
  }

  // Try ancestor
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  retFlag = _RTCJDC(&parentClassJD)->getGadgetText(nodeJD,formName,gadget,nth,txt);
  
 wrapup:
  if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
  
  return retFlag;
}


/* -----------------------------------------------------
 * Determine type of node to create duing copy operation
 *
 * I - copyJD copyBaseInfo              Node being copied
 * I - parentJD parentBaseInfo          Parent where node is to be copied
 *
 * O - info - Node Type to create
 *
 * This is really only for transformations, calling routine will
 * ensure that if this fails then a valid node type does exists
 */
static IGRstat getPasteNodeType(TVDct1JD          *parentJD, 
				TVDct1JD          *copyJD,
				TVDctNodeTypeInfo *info)
{
  VDASSERT_FN("getPasteNodeType");
  
  IGRstat          retFlag;
  TVDctBaseInfo    parentBaseInfo;
  TVDctBaseInfo    copyBaseInfo;
  IGRstat          sts;
    
  // Arg check
  VDASSERTW(info); *info->type = 0;
  VDASSERTW(parentJD);
  VDASSERTW(copyJD);
  
  //Init
  retFlag = 0;

  //Say hi
  // traceFlag = 1;
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

  // Get base info of objects
  _RTCJDB(parentJD)->getBaseInfo(parentJD,&parentBaseInfo);
  VDASSERTW(*parentBaseInfo.nodeType);
  
  _RTCJDB(copyJD)->getBaseInfo(copyJD,&copyBaseInfo);
  VDASSERTW(*copyBaseInfo.nodeType);

  if (traceFlag) {
    printf ("parentBaseInfo.nodeType = %s\n",parentBaseInfo.nodeType);
    printf ("copyBaseInfo.nodeType   = %s\n",copyBaseInfo.nodeType);
  }
  
  //Do it
  if (!strcmp(parentBaseInfo.nodeType,VDCT1_NODE_TYPE_COMM_CODE)) {
    sts = 1;
    if (sts) sts = strcmp(copyBaseInfo.nodeType,VDCT1_NODE_TYPE_STD_PART);
    if (sts) sts = strcmp(copyBaseInfo.nodeType,VDCT1_NODE_TYPE_STD_PART4);
    if (sts) sts = strcmp(copyBaseInfo.nodeType,VDCT1_NODE_TYPE_STD_ASSY);
    if (sts) sts = strcmp(copyBaseInfo.nodeType,VDCT1_NODE_TYPE_STD_ASSY2);
    if (sts) sts = strcmp(copyBaseInfo.nodeType,VDCT1_ENG_NODE_TYPE_PART);
    if (sts) sts = strcmp(copyBaseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY);
    if (sts) sts = strcmp(copyBaseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY2);
    if (sts) sts = strcmp(copyBaseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY2);
    if (sts == 0) {
      strcpy(info->type,VDCT1_NODE_TYPE_STD_ASSY2);
      goto wrapup;
      
    }
    if (sts) sts = strcmp(copyBaseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY6);
    if (sts == 0) {
      strcpy(info->type,VDCT1_NODE_TYPE_STD_ASSY6);
    }
    goto wrapup;
  }


  // Adding to existing STD_ASSY2
  if (!strcmp(parentBaseInfo.nodeType,VDCT1_NODE_TYPE_STD_ASSY2)) {
    sts = 1;
    if (sts) sts = strcmp(copyBaseInfo.nodeType,VDCT1_NODE_TYPE_STD_PART);
    if (sts) sts = strcmp(copyBaseInfo.nodeType,VDCT1_NODE_TYPE_STD_PART4);
    if (sts) sts = strcmp(copyBaseInfo.nodeType,VDCT1_ENG_NODE_TYPE_PART);
    if (sts == 0) {
      strcpy(info->type,VDCT1_NODE_TYPE_STD_PART);
      goto wrapup;
    } 
    sts = 1;
    if (sts) sts = strcmp(copyBaseInfo.nodeType,VDCT1_NODE_TYPE_STD_ASSY);
    if (sts) sts = strcmp(copyBaseInfo.nodeType,VDCT1_NODE_TYPE_STD_ASSY2);
    if (sts) sts = strcmp(copyBaseInfo.nodeType,VDCT1_NODE_TYPE_STD_ASSY6);
    if (sts) sts = strcmp(copyBaseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY);
    if (sts) sts = strcmp(copyBaseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY2);
    if (sts) sts = strcmp(copyBaseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY2);
    if (sts) sts = strcmp(copyBaseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY6);
    if (sts == 0) {
      strcpy(info->type,VDCT1_NODE_TYPE_STD_ASSY);
    }
    goto wrapup;
  }
  
  //Adding to existing STD_ASSY[6]
  if (!strcmp(parentBaseInfo.nodeType,VDCT1_NODE_TYPE_STD_ASSY6)) {
    sts = 1;
    if (sts) sts = strcmp(copyBaseInfo.nodeType,VDCT1_NODE_TYPE_STD_PART);
    if (sts) sts = strcmp(copyBaseInfo.nodeType,VDCT1_NODE_TYPE_STD_PART4);
    if (sts) sts = strcmp(copyBaseInfo.nodeType,VDCT1_ENG_NODE_TYPE_PART);
    if (sts == 0) {
      strcpy(info->type,VDCT1_NODE_TYPE_STD_PART);
      goto wrapup;
    } 
    sts = 1;
    if (sts) sts = strcmp(copyBaseInfo.nodeType,VDCT1_NODE_TYPE_STD_ASSY);
    if (sts) sts = strcmp(copyBaseInfo.nodeType,VDCT1_NODE_TYPE_STD_ASSY2);
    if (sts) sts = strcmp(copyBaseInfo.nodeType,VDCT1_NODE_TYPE_STD_ASSY6);
    if (sts) sts = strcmp(copyBaseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY);
    if (sts) sts = strcmp(copyBaseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ASSY2);
    if (sts) sts = strcmp(copyBaseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY2);
    if (sts) sts = strcmp(copyBaseInfo.nodeType,VDCT1_ENG_NODE_TYPE_ENGASSY6);
    if (sts == 0) {
      strcpy(info->type,VDCT1_NODE_TYPE_STD_ASSY);
    }
    goto wrapup;
  }
  
  //Done
 
  
wrapup:
  if (traceFlag) printf("<<< %s %s [%s]\n",ffn(),fn,info->type);
  return 1;
}

/* --------------------------------------------------
 * Called when user tries to expand or contract
 * A tree row
 */
static IGRstat preExpandContractNode(TVDct1JD *nodeJD, IGRchar *op)
{
  VDASSERT_FN("preExpandContractNode");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDrisInfo ris,ris2;
  
  IGRchar  msg[64];
  IGRchar  node_type[64];
  IGRchar  child_cage_num[64];
  IGRchar  item_type;

  TVDct1RisIOC ioc;
  
  TVDct1JD itemJD;
  TVDct1JD assyJD;
  TVDct1JD commJD;
  
  TVDctBaseInfo baseInfo;
  
  TVDct1PartInfo part;
  
  // Arg check
  VDASSERTW(nodeJD && nodeJD->cl);
  VDASSERTW(op);
  
  // Only process if not done before
  if (*op != ' ') goto wrapup;
  
  // Say hi
  // traceFlag = 1;
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  
  // Get the info
  VDjt1GetBaseInfo(nodeJD,&baseInfo);
  
  // For the top level
  if (!strcmp(baseInfo.nodeType,VDCT1_NODE_TYPE_STD_ASSYS)) {

    // Get the nouns
    UI_status("COMM CODE Query...");
    VDrisInitInfo(&ris);
    VDct1QryDistinctItems(&ris,
			  VDCT1_ITEM_TYPE_2OR6,
			  VDCT1_RIS_COLN_ITEMS_COMM_CODE);
    if (ris.rows < 1) {
      UI_status("Query for comm_codes failed");
      goto wrapup;
    }
    sprintf(msg,"Processing %d comm codes",ris.rows);
    UI_status(msg);
    
    // Cycle through
    for(ris.i = 0; ris.i < ris.rows; ris.i = ris.i + 1) {

      if (traceFlag) printf("COMM CODE '%s'\n",ris.buf[ris.i]);
      
      // Create it
      VDjt1CreateNode(nodeJD,
		      VDCT1_NODE_TYPE_COMM_CODE,
		      ris.buf[ris.i],
		      &commJD);
    }
      
    // Free the buffer
    sprintf(msg,"Processed %d comm codes",ris.rows);
    VDrisFreeInfo(&ris);

    // Done for this
    strcpy(op,"-");
    UI_status(msg);
    retFlag = 1;
    goto wrapup;

  }

  // For the comm_code
  if (!strcmp(baseInfo.nodeType,VDCT1_NODE_TYPE_COMM_CODE)) {

    // Get the parts
    UI_status("STANDARD ASSY Query...");
    VDrisInitInfo(&ris);
    VDct1QryItems(&ris,
		  VDCT1_ITEM_TYPE_2OR6,
		  VDCT1_RIS_COLN_ITEMS_COMM_CODE,
		  baseInfo.nodeName);
       
    // Verify got something
    if (ris.rows < 1) {
      UI_status("Query for standard assys failed");
      goto wrapup;
    }
    sprintf(msg,"Processing %d assys",ris.rows);
    UI_status(msg);
    
    // Cycle through
    for(ris.i = 0; ris.i < ris.rows; ris.i = ris.i + 1) {

      ris.j = ris.i * ris.cols;

      // Need to know type to create
      *node_type = 0;
      item_type = *ris.buf[ris.j+VDCT1_RIS_COLI_ITEMS_ITEM_TYPE];
      switch(item_type) {
	case '2':
	  strcpy(node_type,VDCT1_NODE_TYPE_STD_ASSY2);
	  break;
	case '6':
	  strcpy(node_type,VDCT1_NODE_TYPE_STD_ASSY6);
	  break;
      }
      VDASSERTW(*node_type);

      if (traceFlag) printf("%s '%s'\n",node_type,
			    ris.buf[ris.j+VDCT1_RIS_COLI_ITEMS_ITEM_CAGE_NUM]);
      
      // Create It
      VDjt1CreateNode(nodeJD,
		      node_type,
		      ris.buf[ris.j+VDCT1_RIS_COLI_ITEMS_ITEM_CAGE_NUM],
		      &assyJD);
      VDASSERTW(assyJD.id.objid != NULL_OBJID);

      // Xfer Attributes
      VDjt1SetAttr(&assyJD,
		   VDCT1_ATTR_ITEM_CAGE_NUM,
		   ris.buf[ris.j+VDCT1_RIS_COLI_ITEMS_ITEM_CAGE_NUM]);

      VDjt1SetAttr(&assyJD,
		   VDCT1_ATTR_ITEM_REV,
		   ris.buf[ris.j+VDCT1_RIS_COLI_ITEMS_ITEM_REV]);

      VDjt1SetAttr(&assyJD,
		   VDCT1_ATTR_ITEM_UM,
		   ris.buf[ris.j+VDCT1_RIS_COLI_ITEMS_UNIT_OF_MEASURE]);

      VDjt1SetAttr(&assyJD,
		   VDCT1_ATTR_ITEM_DESC,
		   ris.buf[ris.j+VDCT1_RIS_COLI_ITEMS_COPICS_SHORT_DESC]);

      VDjt1SetAttr(&assyJD,
		   VDCT1_ATTR_ITEM_DATE,
		   ris.buf[ris.j+VDCT1_RIS_COLI_ITEMS_UPDATEDATE]);

    }
  
    // Free the buffer
    sprintf(msg,"Processed %d assys",ris.rows);
    VDrisFreeInfo(&ris);
    
    // Done for this
    strcpy(op,"-");
    UI_status(msg);
    retFlag = 1;
    goto wrapup;

  }

  // For the assemblies (type 2 or type 6)
  if (!strcmp(baseInfo.nodeType,VDCT1_NODE_TYPE_STD_ASSY2) ||
      !strcmp(baseInfo.nodeType,VDCT1_NODE_TYPE_STD_ASSY6) ||
      !strcmp(baseInfo.nodeType,VDCT1_NODE_TYPE_STD_ASSY))  {

    // Query for the kids
    UI_status("STANDARD ASSY PS Query...");
    VDrisInitInfo(&ris);
    VDct1QryPS(&ris,baseInfo.nodeName);
       
    // Verify got something
    if (ris.rows < 1) {
      UI_status("Query for standard assys product structure failed");
      goto wrapup;
    }
    sprintf(msg,"Processing %d children",ris.rows);
    UI_status(msg);

    // Cycle through
    for(ris.i = 0; ris.i < ris.rows; ris.i = ris.i + 1) {

      ris.j = ris.i * ris.cols;

      // Pull child cage num
      strcpy(child_cage_num,ris.buf[ris.j+VDCT1_RIS_COLI_PS_CHILD_CAGE_NUM]);
      VDASSERTW(*child_cage_num);
      
      // Need to query items table for child to get it's info
      VDrisInitInfo(&ris2);
      VDct1QryItems(&ris2,
		    VDCT1_ITEM_TYPE_ALL,
		    VDCT1_RIS_COLN_ITEMS_ITEM_CAGE_NUM,
		    child_cage_num);
      VDASSERTW(ris2.rows == 1);
      
      // Need to know type to create, look in items table
      *node_type = 0;
      item_type = *ris2.buf[VDCT1_RIS_COLI_ITEMS_ITEM_TYPE];
      switch(item_type) {
	case '2': 
	  strcpy(node_type,VDCT1_NODE_TYPE_STD_ASSY);
	  break;
	case '4': 
	  strcpy(node_type,VDCT1_NODE_TYPE_STD_PART);
	  break;
      }      
#if 0
      if (*node_type == 0) {
	printf("*** Cannot determine node type for %s %s %c\n",
	       ris2.buf[VDCT1_RIS_COLI_ITEMS_NOUN_NAME],
	       child_cage_num,item_type);
      }
#endif
      VDASSERTW(*node_type);

      // Translate to isdp number if one is available
      VDct1ReadIOCForPartCageNum(&ioc,VDCT1_RIS_COLI_SIOC_OPS_CAGE_NUM,child_cage_num);
      if (*ioc.isdp_cage_num) strcpy(child_cage_num,ioc.isdp_cage_num);
      
      // Ready to rock
      if (traceFlag) printf("%s '%s'\n",node_type,child_cage_num);
      
      // Create It
      VDjt1CreateNode(nodeJD,
		      node_type,
		      child_cage_num,
		      &itemJD);
      VDASSERTW(itemJD.id.objid != NULL_OBJID);

      // Xfer Attributes
      VDjt1SetAttr(&itemJD,
		   VDCT1_ATTR_ITEM_QTY,
		   ris.buf[ris.j+VDCT1_RIS_COLI_PS_QTY]);

#if 0
      VDjt1SetAttr(&itemJD,
		   VDCT1_ATTR_ITEM_CAGE_NUM,
		   ris2.buf[VDCT1_RIS_COLI_ITEMS_ITEM_CAGE_NUM]);

      VDjt1SetAttr(&itemJD,
		   VDCT1_ATTR_ITEM_REV,
		   ris2.buf[VDCT1_RIS_COLI_ITEMS_ITEM_REV]);

      VDjt1SetAttr(&itemJD,
		   VDCT1_ATTR_ITEM_UM,
		   ris2.buf[VDCT1_RIS_COLI_ITEMS_UNIT_OF_MEASURE]);

      VDjt1SetAttr(&itemJD,
		   VDCT1_ATTR_ITEM_DESC,
		   ris2.buf[VDCT1_RIS_COLI_ITEMS_COPICS_SHORT_DESC]);

      VDjt1SetAttr(&itemJD,
		   VDCT1_ATTR_ITEM_DATE,
		   ris2.buf[VDCT1_RIS_COLI_ITEMS_UPDATEDATE]);
#endif

      // Free ris2 buffer
      VDrisFreeInfo(&ris2);
      
    }

    // Free the buffer
    sprintf(msg,"Processed %d children",ris.rows);
    VDrisFreeInfo(&ris);
    
    // Done for this
    strcpy(op,"-");
    UI_status(msg);
    retFlag = 1;
    goto wrapup;
    
  }
  
  // Done
  retFlag = 1;

wrapup:
  if (traceFlag) {
    printf("<<< %s %s\n",ffn(),fn);
  }
  
  return retFlag;
}

/* -----------------------------------------------
 * Usually called before creating a node
 * to verify valid names
 */
static IGRstat isNodeNameValid(TVDct1JD *parentJD,
			       IGRchar  *nodeType,
			       IGRchar  *nodeName,
			       IGRchar  *results)
{
  VDASSERT_FN("isNodeNameValid");
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDct1JD parentClassJD;

  TVDct1CommInfo comm;
  
  
  // Arg check
  VDASSERTW(results); strcpy(results,"Invalid Node Name ");
  VDASSERTW(parentJD && parentJD->cl);
  VDASSERTW(nodeType && *nodeType);
  VDASSERTW(nodeName && *nodeName);
  sprintf(results,"Invalid Node Name %s %s",nodeType,nodeName);
  
  // Say Hi
  if (traceFlag) {  
    printf(">>> %s %s %s %s\n",ffn(),fn,nodeType,nodeName);
  }

  // Init

  // Upper Case
  VDstrupr(nodeName);
  

  // call the default first
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  sts = _RTCJDB(&parentClassJD)->
    isNodeNameValid(parentJD,nodeType,nodeName,results);
  if (!(sts & 1)) goto wrapup;

  // make sure comm_code is valid  
  if(!strcmp(nodeType,VDCT1_NODE_TYPE_COMM_CODE)){
    
    sts = VDct1GetCommInfo(nodeName,&comm);
    if (!(sts & 1)) {
      sprintf(results,"COMM CODE %s is invalid",nodeName);
      goto wrapup;  
    }
  }
  
  // If creating other than comm_code, then it must be in OPS
  // if(strcmp(nodeType,VDCT1_NODE_TYPE_COMM_CODE)) {
  // sts = 
  // Done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) {  
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  if (retFlag == 1) *results = 0;
  
  return retFlag;
}



/* --------------------------------------------------
 * Validate child type
 */
static IGRstat isChildTypeValid(TVDct1JD *parentJD,
				IGRchar  *childType)
{
  VDASSERT_FN("isChildTypeValid");

  IGRstat retFlag = 0;
  
  TVDctBaseInfo baseInfo;
  TVDctNodeType parentType;
  
  // Arg check
  VDASSERTW((parentJD->cl != NULL) && (parentJD->id.objid != NULL_OBJID));
  VDASSERTW(childType != NULL);
  
  // Need the parent info
   _RTCJDB(parentJD)->getBaseInfo(parentJD,&baseInfo);
  VDASSERTW(*baseInfo.nodeType);
  strcpy(parentType,baseInfo.nodeType);
    
  // Say hi
  if (traceFlag) {
    printf(">>> %s %s %s %s %s\n",ffn(),_RTCJDBC(parentJD),fn,parentType,childType);
  }
  
  // OK By default
  retFlag = 1;

  // STD_ASSYS can have COMM_CODE
  if(!strcmp( parentType,VDCT1_NODE_TYPE_STD_ASSYS)) {
    if(!strcmp(childType,VDCT1_NODE_TYPE_COMM_CODE)) goto wrapup;
  }
  // COMM_CODE can have STD_ASSY2, or STD_ASSY6
  // Might want to disable this, only allow pasting
  if(!strcmp( parentType,VDCT1_NODE_TYPE_COMM_CODE)) {
    if(!strcmp(childType,VDCT1_NODE_TYPE_STD_ASSY2)) goto wrapup;
    if(!strcmp(childType,VDCT1_NODE_TYPE_STD_ASSY6)) goto wrapup;
  }
  // STD_ASSY6 can have STD_ASSY2, STD_ASSY, or STD_PART
  if(!strcmp( parentType,VDCT1_NODE_TYPE_STD_ASSY6)) {
    if(!strcmp(childType,VDCT1_NODE_TYPE_STD_ASSY2)) goto wrapup;
    if(!strcmp(childType,VDCT1_NODE_TYPE_STD_ASSY))  goto wrapup;
    if(!strcmp(childType,VDCT1_NODE_TYPE_STD_PART))  goto wrapup;
  }
  // STD_ASSY2 can have STD_ASSY or STD_PART
  if(!strcmp( parentType,VDCT1_NODE_TYPE_STD_ASSY2)) {
    if(!strcmp(childType,VDCT1_NODE_TYPE_STD_ASSY)) goto wrapup;
    if(!strcmp(childType,VDCT1_NODE_TYPE_STD_PART)) goto wrapup;
  }
  // STD_ASSY can have STD_PART
  if(!strcmp( parentType,VDCT1_NODE_TYPE_STD_ASSY)) {
    if(!strcmp(childType,VDCT1_NODE_TYPE_STD_PART)) goto wrapup; 
  }
  // STD_PART Nothing
  if(!strcmp(parentType,VDCT1_NODE_TYPE_STD_PART)) {
  }

  // Dont let anything be created manually
  retFlag = 0;
  
wrapup:
  if (traceFlag) {
    printf(">>> %s %s %s %d\n",ffn(),_RTCJDBC(parentJD),fn,retFlag);
  }

  return retFlag;
}

/* -----------------------------------------------
 * Nth attribute of a given node
 */
static IGRstat getNodeAttrName(TVDct1JD *nodeJD,
			       IGRchar  *nodeType,
			       IGRint    nth,
			       IGRchar  *attrName)
{ 
  VDASSERT_FN("getNodeAttrName");
  
  IGRstat retFlag = 0;
  
  // Init 
  VDASSERTW(attrName != NULL);
  *attrName = 0;
  VDASSERTW(nodeType != NULL);
  retFlag = 1;
  

  // Say hi
  if (traceFlag) {
    printf(">>> %s %s %s %s %2d\n",ffn(),_RTCJDBC(nodeJD),fn,nodeType,nth);
  }
  
  
  if (!strcmp(nodeType,VDCT1_NODE_TYPE_STD_PART)) {
    
    switch(nth) {

      case  0: strcpy(attrName,VDCT1_ATTR_ITEM_CAGE_NUM); goto wrapup;
      case  1: strcpy(attrName,VDCT1_ATTR_ITEM_DESC);     goto wrapup;
      case  2: strcpy(attrName,VDCT1_ATTR_ITEM_QTY);      goto wrapup;
      case  3: strcpy(attrName,VDCT1_ATTR_ITEM_UM);       goto wrapup;
      case  4: strcpy(attrName,VDCT1_ATTR_ITEM_REV);      goto wrapup;
      case  5: strcpy(attrName,VDCT1_ATTR_ITEM_DATE);     goto wrapup;
	
    }
  }

  if (!strcmp(nodeType,VDCT1_NODE_TYPE_STD_ASSY)) {
    
    switch(nth) {

      case  0: strcpy(attrName,VDCT1_ATTR_ITEM_CAGE_NUM); goto wrapup;
      case  1: strcpy(attrName,VDCT1_ATTR_ITEM_DESC);     goto wrapup;
      case  2: strcpy(attrName,VDCT1_ATTR_ITEM_QTY);      goto wrapup;
      case  3: strcpy(attrName,VDCT1_ATTR_ITEM_UM);       goto wrapup;
      case  4: strcpy(attrName,VDCT1_ATTR_ITEM_REV);      goto wrapup;
      case  5: strcpy(attrName,VDCT1_ATTR_ITEM_DATE);     goto wrapup;
 
    }
  }

  if (!strcmp(nodeType,VDCT1_NODE_TYPE_STD_ASSY2)) {
    
    switch(nth) {

      case  0: strcpy(attrName,VDCT1_ATTR_ITEM_CAGE_NUM); goto wrapup;
      case  1: strcpy(attrName,VDCT1_ATTR_ITEM_DESC);     goto wrapup;
      case  2: strcpy(attrName,VDCT1_ATTR_COMM_CODE);     goto wrapup;
      case  3: strcpy(attrName,VDCT1_ATTR_COST_CODE);     goto wrapup;
      case  4: strcpy(attrName,VDCT1_ATTR_ITEM_UM);       goto wrapup;
      case  5: strcpy(attrName,VDCT1_ATTR_ITEM_REV);      goto wrapup;
      case  6: strcpy(attrName,VDCT1_ATTR_ITEM_DATE);     goto wrapup;
      
    }
  }

  if (!strcmp(nodeType,VDCT1_NODE_TYPE_STD_ASSY6)) {
    
    switch(nth) {

    case  0: strcpy(attrName,VDCT1_ATTR_ITEM_CAGE_NUM); goto wrapup;
    case  1: strcpy(attrName,VDCT1_ATTR_ITEM_DESC);     goto wrapup;
    case  2: strcpy(attrName,VDCT1_ATTR_COMM_CODE);     goto wrapup;
    case  3: strcpy(attrName,VDCT1_ATTR_COST_CODE);     goto wrapup;
    case  4: strcpy(attrName,VDCT1_ATTR_ITEM_UM);       goto wrapup;
    case  5: strcpy(attrName,VDCT1_ATTR_ITEM_REV);      goto wrapup;
    case  6: strcpy(attrName,VDCT1_ATTR_ITEM_DATE);     goto wrapup;
      
    }
  }

  if (!strcmp(nodeType,VDCT1_NODE_TYPE_COMM_CODE)) {
    
    switch(nth) {

      case  0: strcpy(attrName,VDCT1_ATTR_COMM_CODE);      goto wrapup;
      case  1: strcpy(attrName,VDCT1_ATTR_COMMODITY);      goto wrapup;
      case  2: strcpy(attrName,VDCT1_ATTR_COST_CODE);      goto wrapup;
      case  3: strcpy(attrName,VDCT1_ATTR_ITEM_CAGE_CODE); goto wrapup;
      case  4: strcpy(attrName,VDCT1_ATTR_PROJ_CODE);      goto wrapup;
      
    }
  }

  if (!strcmp(nodeType,VDCT1_NODE_TYPE_STD_ASSYS)) {
    
    switch(nth) {

      case  0: strcpy(attrName,VDCT1_ATTR_ITEM_CAGE_CODE); goto wrapup;
      case  1: strcpy(attrName,VDCT1_ATTR_PROJ_CODE);      goto wrapup;
      
    }
  }


  // Not found
  retFlag = 0;
    
wrapup:
  return retFlag;
}
/* --------------------------------------------------
 * Load up static attributes from ops
 * This is just a local routine for now, 
 * Not sure if it needs to be shared outside this tree or not
 *
 * This also focuses on parts, probably needs to do other types as well?
 */
static IGRstat setPartAttrs(TVDct1JD *nodeJD)
{
  VDASSERT_FN("setPartAttrs");
  
  TVDct1_part_fld_part_id part_id;
  TVDct1PartInfo          part;

  IGRchar buf[256];

  TVDctBaseInfo baseInfo;
  
  //Arg check
  VDASSERTW((nodeJD->cl != NULL) && (nodeJD->id.objid != NULL_OBJID));
  
  // Need the name
  _RTCJDB(nodeJD)->getBaseInfo(nodeJD,&baseInfo);
  VDASSERTW(baseInfo.nodeName);
  
  // See if have a valid part (or assy???)
  VDct1ReadPartIdForPartCageNum(baseInfo.nodeName,part_id);
  if (*part_id == NULL) goto wrapup;
  
  // Get the part information
  VDct1ReadPartFromAttrsTable(part_id,&part);
  
  // Just a bunch of copies
  _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_ITEM_CAGE_NUM, part.part_cage_num);  
  _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_ITEM_CAGE_CODE,part.part_cage_code);
  
  _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_ITEM_NUM, part.part_num);
  _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_ITEM_DESC,part.copics_short_description);
  _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_ITEM_UM,  part.unit_of_measure);
  _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_ITEM_REV, part.part_rev);
  _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_ITEM_DATE,part.updatedate);

  // Use copics description if available
  if (*part.copics_short_description) {
    _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_ITEM_DESC,part.copics_short_description);
  }
  else {
    // Build nomenclature
    strcpy(buf,part.noun_name);
    if (*part.noun_name) strcat(buf,", ");
    strcat(buf,part.type);
    if (*part.type) strcat(buf,", ");
    strcat(buf,part.modifier);
    *(buf+72) = 0;
    _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_ITEM_DESC,buf);
    // printf("### %s\n",buf);
  }
  
  // Done
 wrapup:
  return 1;
}

/* -------------------------------------------------
 * Create a node
 */
static IGRstat createNode(TVDct1JD *parentJD,
			  IGRchar  *nodeType, 
			  IGRchar  *nodeName,
			  TVDct1JD *nodeJD)
{ 
  VDASSERT_FN("createNode");

  
  IGRstat retFlag = 0;

  TVDctBaseInfo baseInfo;
  
  TVDct1JD parentClassJD;
  
  TVDct1CommInfo commInfo;
  
  TVDrisInfo ris;
  
  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s %s %s %s\n",
	   ffn(),_RTCJDBC(parentJD),fn,nodeType,nodeName);
  }
  //Arg check
  VDASSERTW((parentJD->id.objid != NULL_OBJID) && (parentJD->cl != NULL));
  VDASSERTW(nodeType != NULL);
  VDASSERTW(nodeName != NULL);
  VDASSERTW(nodeJD);

  // Init
  nodeJD->id.objid = NULL_OBJID;
  nodeJD->cl = parentJD->cl;

  // Use standard node create routine
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  _RTCJDB(&parentClassJD)->createNode(parentJD,nodeType,nodeName,nodeJD);
  VDASSERTW(nodeJD->id.objid != NULL_OBJID);

  // For StdAssys, default cage_code
  if (!strcmp(nodeType,VDCT1_NODE_TYPE_STD_ASSYS)) {

    _RTCJDB(nodeJD)->
      setAttr(nodeJD,
	      VDCT1_ATTR_ITEM_CAGE_CODE,
	      VDCT1_DEFAULT_CAGE_CODE);

    _RTCJDB(nodeJD)->
      setAttr(nodeJD,
	      VDCT1_ATTR_PROJ_CODE,     
	      VDCT1_DEFAULT_PROJ_CODE);
  }

  // For comm_codes, already have validated comm_code data
  if (!strcmp(nodeType,VDCT1_NODE_TYPE_COMM_CODE)) {

    // Get CommInfo
    
    VDct1GetCommInfo(nodeName,&commInfo);
    if (commInfo.comm_code == NULL) goto wrapup;
    
    _RTCJDB(nodeJD)->
      setAttr(nodeJD,
	      VDCT1_ATTR_COMM_CODE,
	      commInfo.comm_code);
    
    _RTCJDB(nodeJD)->
      setAttr(nodeJD,
	      VDCT1_ATTR_COMMODITY,
	      commInfo.commodity);
    
    _RTCJDB(nodeJD)->
      setAttr(nodeJD,
	      VDCT1_ATTR_COST_CODE,
	      commInfo.cost_code);
  }

  // Init the date
  _RTCJDB(nodeJD)->computeDate(nodeJD,VDCT1_ATTR_ITEM_DATE);

  // Init the UM
  _RTCJDB(nodeJD)->computeUM(nodeJD,VDCT1_ATTR_ITEM_UM);
  
  // Pull some down
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_ITEM_CAGE_CODE);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_COMM_CODE);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_COMMODITY);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_COST_CODE);
  _RTCJDB(nodeJD)->pullDownAttr(nodeJD,VDCT1_ATTR_PROJ_CODE);

  // Init a few more
  _RTCJDB(nodeJD)->setAttr(nodeJD,VDCT1_ATTR_ITEM_CAGE_NUM,nodeName);

  // Pulls data from ops
  setPartAttrs(nodeJD);

  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  
  return retFlag;
}

/* --------------------------------------------------
 * get the node type for the model object,
 * default will be to check if it is a std_assy
 * and set it to the correct assy type.
 * if it is not a std_assy, then it will be a part
 */ 
static IGRstat getTypeForModelObject(TVDct1JD      *parentNodeJD,
				     TGRobj_env    *modelOE,
				     TVDctNodeType nodeType)
{
  VDASSERT_FN("getTypeForModelObject");
  
  IGRstat retFlag = 0;

  TVDctBaseInfo baseInfo;
 
  // Arg check
  VDASSERTW(parentNodeJD && parentNodeJD->id.objid != NULL_OBJID);
  VDASSERTW(nodeType);

  // init
  *nodeType = 0;

  // just set it equal to a part
  strcpy(nodeType,VDCT1_NODE_TYPE_STD_PART);

  // Done 
  retFlag = 1;

wrapup:  
  if (traceFlag) printf("<<< %s %s %s\n",ffn(),fn,nodeType);
  
  return retFlag;
}

/* -------------------------------------------------
 * Class filter
 */
static IGRstat getFilter(TVDct1JD       *nodeJD,
			 OM_S_CLASSLIST *classList)
{
  VDASSERT_FN("getFilter");
  
  IGRstat retFlag = 0;
  
  VDASSERTW(classList);
  
  VDomGetClassIdForClassName("VDSroot",&classList->p_classes[0]);
  classList->w_count = 1;

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Individual stage info
 */
static IGRstat getNodeTypeInfo(TVDct1JD *nodeJD,
			       IGRint    nth, 
			       IGRint   *cnt, 
			       TVDctNodeTypeInfo *info)
{
  VDASSERT_FN("getNodeTypeInfo");
  
  IGRstat retFlag = 0;
  
  // Arg check
  if (cnt) *cnt = 6;  // Set this to total number of nodes
  VDASSERTW(info);

  // say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // Just a switch
  switch(nth) {

  case 0:
    strcpy(info->type, VDCT1_NODE_TYPE_STD_PART);
    strcpy(info->desc, "STD PART");
    strcpy(info->level,"U00");
    strcpy(info->table,"");
    return 1;
    
  case 1:
    strcpy(info->type, VDCT1_NODE_TYPE_STD_ASSY);
    strcpy(info->desc, "STD ASSY");
    strcpy(info->level,"U01");
    strcpy(info->table,"");
    return 1;
    
  case 2:
    strcpy(info->type, VDCT1_NODE_TYPE_STD_ASSY2);
    strcpy(info->desc, VDCT1_NODE_TYPE_STD_ASSY2);
    strcpy(info->level,"U02");
    strcpy(info->table,"");
    return 1;
    
  case 3:
    strcpy(info->type, VDCT1_NODE_TYPE_STD_ASSY6);
    strcpy(info->desc, VDCT1_NODE_TYPE_STD_ASSY6);
    strcpy(info->level,"U03");
    strcpy(info->table,"");
    return 1;
    
  case 4:
    strcpy(info->type, VDCT1_NODE_TYPE_COMM_CODE);
    strcpy(info->desc, "COMMODITY CODE");
    strcpy(info->level,"U04");
    strcpy(info->table,"");
    return 1;
      
  case 5:
    strcpy(info->type,  VDCT1_NODE_TYPE_STD_ASSYS);
    strcpy(info->desc, "STD ASSYS");
    strcpy(info->level,"S05");
    strcpy(info->table,"");
    return 1;
  }
  
  // No More
  memset(info,0,sizeof(TVDctNodeTypeInfo));
  
 wrapup:
  if (traceFlag) printf("<<< %s %s %s\n",ffn(),fn,info->type);
  
  return retFlag;
}

/* -----------------------------------------------
 * Hello routine for testing
 */
static IGRstat hello(TVDct1JD *nodeJD)
{ 
  printf("@@@ Hello from %s\n",_RTCJDBC(nodeJD));
  return 1;
}

/* -----------------------------------------------
 * The only public routine
 * Used to init the various function pointers
 */
IGRstat VDct1InitStdAssysTreeClass(TVDct1ProdTreeClass     *prodCL, 
				   TVDct1StdAssysTreeClass *cl)
{
  VDASSERT_FN("VDct1InitStdAssysTreeClass");
  
  IGRstat retFlag = 0;

  traceFlagx = traceFlag = VDct1TraceFlag(VDCT1_TRACE_TREE_ASSY);
  
  // Transfer
  VDct1CopyRootImps(prodCL,cl);
  cl->prod = prodCL->prod;
  
  // Data
  strcpy(cl->base.info.type,VDCT1_TREE_TYPE_STD_ASSYS);
  strcpy(cl->base.info.rev, "000");
  strcpy(cl->base.info.desc,"Standard Assys");
  
  // Fill up pointers
  cl->base.hello            = hello;

  cl->base.getNodeTypeInfo  = getNodeTypeInfo;
  cl->base.getNodeAttrName  = getNodeAttrName;
  cl->base.getFilter        = getFilter;

  cl->base.createNode       = createNode;  
  cl->base.isChildTypeValid = isChildTypeValid;
  cl->base.isNodeNameValid  = isNodeNameValid;
  
  cl->base.getTypeForModelObject = getTypeForModelObject;

  cl->base.postNode = postNode;
  
  cl->base.preExpandContractNode = preExpandContractNode;
  
  // Command Pointers
  cl->cmd.getPasteNodeType   = getPasteNodeType;
  cl->cmd.getGadgetText      = getGadgetText;
  cl->cmd.isConvertNodeValid = isConvertNodeValid;
  
  
  // Done
  retFlag = 1;

 wrapup:
  return retFlag;
}

