 /* $Id: VDct1StdParts.c,v 1.2 2001/02/11 17:15:54 ahundiak Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/tree/VDct1StdParts.I
 *
 * Description: Standard Parts Tree Customization
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1StdParts.c,v $
 *      Revision 1.2  2001/02/11 17:15:54  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.1  2001/01/14 16:29:17  art
 *      sp merge
 *
 * Revision 1.7  2000/08/24  13:48:16  pinnacle
 * ah
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
#include "VDct1Part.h"
#include "VDct1Attrs.h"
#include "VDct1Trace.h"

VDASSERT_FFN("vdct1/tree/VDct1StdParts.C");

#define MY_TREE VDCT1_TREE_TYPE_STD_PARTS

/* --------------------------------------------------
 * Called when user tries to expand or contract
 * A tree row
 */
static IGRstat preExpandContractNode(TVDct1JD *nodeJD, IGRchar *op)
{
  VDASSERT_FN("preExpandContractNode");
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDrisInfo ris;
  
  IGRchar msg[64];
  
  TVDct1JD nounLetJD;
  TVDct1JD nounJD;

  TVDct1JD partJD;
  TGRid   *partID = &partJD.id;
  
  IGRchar prev[2];
  
  TVDfld  fld;
  TVDctBaseInfo baseInfo;
  
  // Arg check
  VDASSERTW(&nodeJD);
  VDASSERTW(op);
  
  // Only process if not done before
  if (*op != ' ') goto wrapup;

  // Say hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  // Get the info
  VDjt1GetBaseInfo(nodeJD,&baseInfo);

  // For the top level
  if (!strcmp(baseInfo.nodeType,VDCT1_NODE_TYPE_STD_PARTS)) {

    // Get the nouns
    UI_status("NOUN NAME Query...");
    VDrisInitInfo(&ris);

    //VDct1QryDistinctNounNamesFromItems(&ris,VDCT1_ITEM_TYPE_4);

    VDct1QryDistinctItems(&ris,
			  VDCT1_ITEM_TYPE_4,
			  VDCT1_RIS_COLN_ITEMS_NOUN_NAME);
    if (ris.rows < 1) {
      UI_status("Query for noun_names failed");
      goto wrapup;
    }
    sprintf(msg,"Processing %d noun names",ris.rows);
    UI_status(msg);
    
    // Setup for nested nouns
    strcpy(prev," ");
    
    // Cycle through
    for(ris.i = 0; ris.i < ris.rows; ris.i = ris.i + 1) {

      // One group per first letter
      if (*ris.buf[ris.i] != *prev) {

	*prev = *ris.buf[ris.i];

	VDjt1CreateNode(nodeJD,
			VDCT1_NODE_TYPE_NOUN_NAME,
			prev,
			&nounLetJD);

      }
      VDjt1CreateNode(&nounLetJD,
		      VDCT1_NODE_TYPE_NOUN_NAME,
		      ris.buf[ris.i],
		      &nounJD);
    }
  
    // Free the buffer
    sprintf(msg,"Processed %d noun names",ris.rows);
    VDrisFreeInfo(&ris);

    // Done for this
    strcpy(op,"-");
    UI_status(msg);
    retFlag = 1;
    goto wrapup;

  }

  // For a noun_name
  if (!strcmp(baseInfo.nodeType,VDCT1_NODE_TYPE_NOUN_NAME)) {

    // Get the parts
    UI_status("STANDARD PART Query...");
    VDrisInitInfo(&ris);
    VDct1QryItems(&ris,
		  VDCT1_ITEM_TYPE_4,
		  VDCT1_RIS_COLN_ITEMS_NOUN_NAME,
		  baseInfo.nodeName);
       
    // Verify got something
    if (ris.rows < 1) {
      UI_status("Query for standard parts failed");
      goto wrapup;
    }
    sprintf(msg,"Processing %d parts",ris.rows);
    UI_status(msg);
    
    // Cycle through
    for(ris.i = 0; ris.i < ris.rows; ris.i = ris.i + 1) {

      ris.j = ris.i * ris.cols;
	
      // Create It
      VDjt1CreateNode(nodeJD,
		      VDCT1_NODE_TYPE_STD_PART4,
		      ris.buf[ris.j+VDCT1_RIS_COLI_ITEMS_ITEM_CAGE_NUM],
		      &partJD);
      
      // Xfer Attributes
      VDjt1SetAttr(&partJD,
		   VDCT1_ATTR_ITEM_CAGE_NUM,
		   ris.buf[ris.j+VDCT1_RIS_COLI_ITEMS_ITEM_CAGE_NUM]);

      VDjt1SetAttr(&partJD,
		   VDCT1_ATTR_ITEM_REV,
		   ris.buf[ris.j+VDCT1_RIS_COLI_ITEMS_ITEM_REV]);
      
      VDjt1SetAttr(&partJD,
		   VDCT1_ATTR_ITEM_UM,
		   ris.buf[ris.j+VDCT1_RIS_COLI_ITEMS_UNIT_OF_MEASURE]);
      
      VDjt1SetAttr(&partJD,
		   VDCT1_ATTR_ITEM_DESC,
		   ris.buf[ris.j+VDCT1_RIS_COLI_ITEMS_COPICS_SHORT_DESC]);
      
      VDjt1SetAttr(&partJD,
		   VDCT1_ATTR_ITEM_DATE,
		   ris.buf[ris.j+VDCT1_RIS_COLI_ITEMS_UPDATEDATE]);
    }
  
    // Free the buffer
    sprintf(msg,"Processed %d parts",ris.rows);
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
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  
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

  // Dont let anything be created manually
  retFlag = 0;
  
wrapup:
  if (traceFlag) {
    printf("<<< %s %s %s %s %d\n",
	   _RTCJDB(parentJD)->info.type,
	   fn,parentType,childType,retFlag);
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
  
  // Drawing
  if (!strcmp(nodeType,VDCT1_NODE_TYPE_STD_PART4)) {
    
    switch(nth) {
      case  0: strcpy(attrName,VDCT1_ATTR_ITEM_CAGE_NUM); goto wrapup;
      case  1: strcpy(attrName,VDCT1_ATTR_ITEM_DESC);     goto wrapup;
      case  2: strcpy(attrName,VDCT1_ATTR_ITEM_UM);       goto wrapup;
      case  3: strcpy(attrName,VDCT1_ATTR_ITEM_REV);      goto wrapup;
      case  4: strcpy(attrName,VDCT1_ATTR_ITEM_DATE);     goto wrapup;
    }
  }

  // Not found
  retFlag = 0;
    
wrapup:
  return retFlag;
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

  // Special initializing

  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf("<<< %s %d\n",fn,retFlag);
  }
  
  return retFlag;
}

/* -------------------------------------------------
 * Class filter
 */
static IGRstat getFilter(TVDct1JD *nodeJD, OM_S_CLASSLIST *classList)
{

  IGRstat retFlag = 0;
  
  if (classList == NULL) goto wrapup;
  
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
  if (cnt) *cnt = 3;  // Set this to total number of nodes
  VDASSERTW(info);

  // Just a switch
  switch(nth) {

  case 0:
    strcpy(info->type, VDCT1_NODE_TYPE_STD_PART4);
    strcpy(info->desc, VDCT1_NODE_TYPE_STD_PART4);
    strcpy(info->level,"U00");
    strcpy(info->table,"");
    return 1;

  case 1:
    strcpy(info->type, VDCT1_NODE_TYPE_NOUN_NAME);
    strcpy(info->desc, "NOUN_NAME");
    strcpy(info->level,"U01");
    strcpy(info->table,"");
    return 1;

  case 2:
    strcpy(info->type, VDCT1_NODE_TYPE_STD_PARTS);
    strcpy(info->desc, "STANDARD PARTS");
    strcpy(info->level,"S02");
    strcpy(info->table,"");
    return 1;
  }
  
  // No More
  memset(info,0,sizeof(TVDctNodeTypeInfo));

 wrapup:
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
IGRstat VDct1InitStdPartsTreeClass(TVDct1ProdTreeClass     *prodCL, 
				   TVDct1StdPartsTreeClass *cl)
{
  VDASSERT_FN("VDct1InitStdPartsTreeClass");
  
  IGRstat retFlag = 0;
  
  // Tracing
  traceFlagx = traceFlag = VDct1TraceFlag(VDCT1_TRACE_TREE_PART);
  
  // Transfer
  VDct1CopyRootImps(prodCL,cl);
  cl->prod = prodCL->prod;
    
  // Data
  strcpy(cl->base.info.type,VDCT1_TREE_TYPE_STD_PARTS);
  strcpy(cl->base.info.rev, "000");
  strcpy(cl->base.info.desc,"Standard Parts");
  
  // Fill up pointers
  cl->base.hello            = hello;

  cl->base.getNodeTypeInfo  = getNodeTypeInfo;
  cl->base.getNodeAttrName  = getNodeAttrName;
  cl->base.getFilter        = getFilter;

  cl->base.createNode       = createNode;  
  cl->base.isChildTypeValid = isChildTypeValid;

  cl->base.preExpandContractNode = preExpandContractNode;
  
  // Done
  retFlag = 1;

 wrapup:
  return retFlag;
}
