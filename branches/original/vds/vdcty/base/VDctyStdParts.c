 /* $Id: VDctyStdParts.c,v 1.3 2001/02/17 14:24:12 ahundiak Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdcty/base/VDctyStdParts.c
 *
 * Description: Standard Parts Tree Customization
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDctyStdParts.c,v $
 *      Revision 1.3  2001/02/17 14:24:12  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/02/11 17:50:07  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.1  2001/01/14 16:00:48  art
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

#include "VDctx.h"
#include "VDcty.h"

#include "VDct1Part.h"
#include "VDct1Attrs.h"

VDASSERT_FFN("vdcty/base/VDctyStdParts.c");

#define MY_TREE VDCTY_TREE_TYPE_STD_PARTS

/* --------------------------------------------------
 * Called when user tries to expand or contract
 * A tree row
 *
 * op may be changed
 */
static void preExpandContractNode(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID, IGRchar *op)
{
  VDASSERT_FN("stdPartsPreExpandContractNode");
  IGRstat sts;
  
  TVDrisInfo ris;
  
  IGRchar msg[64];
  
  TGRid nounLetID;
  TGRid nounID;

  TGRid  partID;
  
  IGRchar prev[2];
  
  TVDfld  fld;
  TVDctxBaseInfo baseInfo;
  
  // Only process if not done before
  if (*op != ' ') goto wrapup;

  // Say hi
  if (traceFlag) printf(">>> %s\n",fn);

  // Get the info
  VDctxGetBaseInfoCP(cp,nodeID,&baseInfo);

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
#if 0
	VDjt1CreateNode(nodeJD,
			VDCT1_NODE_TYPE_NOUN_NAME,
			prev,
			&nounLetJD);
#endif
      }
#if 0
      VDjt1CreateNode(&nounLetJD,
		      VDCT1_NODE_TYPE_NOUN_NAME,
		      ris.buf[ris.i],
		      &nounJD);
#endif
    }
  
    // Free the buffer
    sprintf(msg,"Processed %d noun names",ris.rows);
    VDrisFreeInfo(&ris);

    // Done for this
    strcpy(op,"-");
    UI_status(msg);
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
#if 0
      VDjt1CreateNode(nodeJD,
		      VDCT1_NODE_TYPE_STD_PART4,
		      ris.buf[ris.j+VDCT1_RIS_COLI_ITEMS_ITEM_CAGE_NUM],
		      &partJD);
#endif      
      // Xfer Attributes
      VDctxSetTxtAtrID(cp,&partID,VDCT1_ATTR_ITEM_CAGE_NUM,
		       ris.buf[ris.j+VDCT1_RIS_COLI_ITEMS_ITEM_CAGE_NUM]);

      VDctxSetTxtAtrID(cp,&partID,VDCT1_ATTR_ITEM_REV,
		       ris.buf[ris.j+VDCT1_RIS_COLI_ITEMS_ITEM_REV]);
      
      VDctxSetTxtAtrID(cp,&partID,VDCT1_ATTR_ITEM_UM,
		       ris.buf[ris.j+VDCT1_RIS_COLI_ITEMS_UNIT_OF_MEASURE]);
      
      VDctxSetTxtAtrID(cp,&partID,VDCT1_ATTR_ITEM_DESC,
		       ris.buf[ris.j+VDCT1_RIS_COLI_ITEMS_COPICS_SHORT_DESC]);
      
      VDctxSetTxtAtrID(cp,&partID,VDCT1_ATTR_ITEM_DATE,
		       ris.buf[ris.j+VDCT1_RIS_COLI_ITEMS_UPDATEDATE]);
    }
  
    // Free the buffer
    sprintf(msg,"Processed %d parts",ris.rows);
    VDrisFreeInfo(&ris);
    
    // Done for this
    strcpy(op,"-");
    UI_status(msg);
    goto wrapup;

  }

wrapup:
  if (traceFlag) printf("<<< %s\n",fn);
  return;
}

/* --------------------------------------------------
 * Validate child type
 */
static IGRstat isChildTypeValid(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
				IGRchar  *parentType,
				IGRchar  *childType)
{
  VDASSERT_FN("stdPartsIsChildTypeValid");
  IGRstat retFlag = 0;
  
  // Dont let anything be created manually
  retFlag = 0;
  
wrapup:

  return retFlag;
}

/* -----------------------------------------------
 * Nth attribute of a given node
 */
static IGRstat getNodeAttrName(TVDctyTP *tp,  
			       TVDctxCP *cp, 
			       TGRid    *nodeID,
			       IGRchar  *nodeType,
			       IGRint    nth,
			       IGRchar  *attrName)
{ 
  VDASSERT_FN("stdPartsGetNodeAttrName");
  IGRstat retFlag = 1;

  // Say hi
  if (traceFlag) printf(">>> %s %2d\n",fn,nth);
  
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

#if 0
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
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  
  return retFlag;
}
#endif

/* -------------------------------------------------
 * Class filter
 */
static void getFilter(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID, OM_S_CLASSLIST *classList)
{
  VDASSERT_FN("stdPartsGetFilter");
  
  VDomGetClassIdForClassName("VDSroot",&classList->p_classes[0]);
  classList->w_count = 1;

wrapup:
  return;
}

/* -------------------------------------------------
 * Individual stage info
 */
static IGRstat getNodeTypeInfo(TVDctyTP *tp,  
			       TVDctxCP *cp, 
			       TGRid    *nodeID,
			       IGRint    nth, 
			       IGRint   *cnt, 
			       TVDctyNodeTypeInfo *info)
{
  VDASSERT_FN("stdPartsGetNodeTypeInfo");

  IGRstat retFlag = 1;
  
  // Arg check
  if (cnt) *cnt = 3;  // Set this to total number of nodes

  // Just a switch
  switch(nth) {

  case 0:
    strcpy(info->type, VDCT1_NODE_TYPE_STD_PART4);
    strcpy(info->desc, "STD PART[4]");
    strcpy(info->level,"U00");
    strcpy(info->table,"");
    goto wrapup;

  case 1:
    strcpy(info->type, VDCT1_NODE_TYPE_NOUN_NAME);
    strcpy(info->desc, "NOUN_NAME");
    strcpy(info->level,"U01");
    strcpy(info->table,"");
    goto wrapup;

  case 2:
    strcpy(info->type, VDCT1_NODE_TYPE_STD_PARTS);
    strcpy(info->desc, "STANDARD PARTS");
    strcpy(info->level,"S02");
    strcpy(info->table,"");
    goto wrapup;
  }

  // No More
  retFlag = 0;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Set type information
 */
static void getSetTypeInfo(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
			    TVDctySetTypeInfo *info)
{
  VDASSERT_FN("getSetTypeInfo");

  info->flag = 1;
  info->nth  = VDCTY_CLASSI_STD_PARTS_TREE;
  strcpy(info->type,VDCTY_CLASSN_STD_PARTS_TREE);
  strcpy(info->rev, "000");
  strcpy(info->desc,"Standard Parts Tree");
  
wrapup:
  return;
}

/* -----------------------------------------------
 * Link the base methods
 */
IGRstat VDctyInitStdPartsTP(TVDctyTP *tpb, TVDctyTP *tp)
{
  VDASSERT_FN("VDctyInitStdPartsTP");
  IGRstat retFlag = 0;

  // Arg check
  VDASSERTW(tp);

  // Copy Base
  memcpy(tp,tpb,sizeof(TVDctyTP));
  tp->parentTP = tpb;

  tp->getSetTypeInfo   = getSetTypeInfo;
  tp->getNodeTypeInfo  = getNodeTypeInfo;
  tp->getNodeAttrName  = getNodeAttrName;
  tp->isChildTypeValid = isChildTypeValid;
  
  tp->getFilter = getFilter;
  tp->preExpandContractNode = preExpandContractNode;
  
#if 0  
  // Xfer functions
  tp-> = ;
#endif    
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}
