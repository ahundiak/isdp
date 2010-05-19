/* $Id: VDct1Node.I,v 1.2 2001/01/11 22:03:42 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/cmd/VDct1Node.I
 *
 * Description: Node Manupilation Form
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Node.I,v $
 *      Revision 1.2  2001/01/11 22:03:42  art
 *      sp merge
 *
# Revision 1.22  2000/07/27  16:33:36  pinnacle
# js
#
# Revision 1.21  2000/07/24  19:53:52  pinnacle
# js
#
# Revision 1.20  2000/07/20  20:14:48  pinnacle
# js
#
# Revision 1.19  2000/07/18  19:32:20  pinnacle
# ah
#
# Revision 1.18  2000/07/14  19:09:28  pinnacle
# pn
#
# Revision 1.17  2000/07/12  11:18:58  pinnacle
# pn
#
# Revision 1.16  2000/07/06  15:50:08  pinnacle
# pn
#
# Revision 1.15  2000/06/30  18:55:30  pinnacle
# pn
#
# Revision 1.13  2000/06/08  17:08:00  pinnacle
# pn
#
# Revision 1.12  2000/06/05  21:00:28  pinnacle
# ah
#
# Revision 1.11  2000/06/03  18:00:30  pinnacle
# ah
#
# Revision 1.10  2000/06/02  14:03:10  pinnacle
# Replaced: vds/vdct1/cmd/VDct1Node.I for:  by pnoel for Service Pack
#
# Revision 1.9  2000/05/31  13:37:54  pinnacle
# Replaced: vds/vdct1/cmd/VDct1Node.I for:  by pnoel for Service Pack
#
# Revision 1.7  2000/05/26  11:34:58  pinnacle
# Replaced: vds/vdct1/cmd/VDct1Node.I for:  by pnoel for Service Pack
#
# Revision 1.6  2000/05/23  18:30:20  pinnacle
# Replaced: vds/vdct1/cmd/VDct1Node.I for:  by pnoel for Service Pack
#
# Revision 1.5  2000/05/15  15:19:54  pinnacle
# Replaced: vds/vdct1/cmd/VDct1Node.I for:  by pnoel for Service Pack
#
# Revision 1.4  2000/05/09  19:16:06  pinnacle
# Replaced: vds/vdct1/cmd/VDct1Node.I for:  by pnoel for Service Pack
#
# Revision 1.3  2000/05/05  15:18:46  pinnacle
# pn
#
# Revision 1.1  2000/04/20  18:36:50  pinnacle
# Created: vds/vdct1/cmd/VDct1Node.I by pnoel for Service Pack
#
# Revision 1.6  2000/03/28  16:08:16  pinnacle
# pn.
#
# Revision 1.5  2000/03/24  20:33:18  pinnacle
# ah
#
# Revision 1.4  2000/03/10  21:59:34  pinnacle
# (No comment)
#
# Revision 1.3  2000/01/11  22:28:50  pinnacle
# ah
#
# Revision 1.1  1999/06/29  18:29:28  pinnacle
# ct
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 06/17/99  ah      Creation
 * 12/16/99  pn      Update Prototypes in VDct1.h
 * 01/10/00  pn      updated controls/safeops
 * 03/28/00  pn      refined operations / access new PPL's
 * 05/16/00  pn      added feature disconnect model node and activated
 *                   connect model node also change type node.
 * 06/23/00  pn      altered posting per CR 179901682
 ***************************************************************************/

class implementation VDct1Base;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDfrm.h"
#include "VDsa.h"
#include "VDppl1.h"
#include "VDct1.h"
#include "VDct1Cmd.h"
#include "VDct1Part.h"
#include "VDct1Forms.h"
#include "VDct1Tree.h"

#include "VDassert.h"

VDASSERT_FFN("vdct1/cmd/VDct1Node.I");

static int traceFlagx;
static int dupFlag;
static int multFlag;
static int boxCount;
static int dupPasteFlag;
static int attrPresent;
			   
static TVDct1CmdInfo *cmdInfo;

static TGRid activeNodeID;
static TGRid parentNodeID;
static TGRid pastedNodeID;



/* -------------------------------------------------
 * Checks to see if a Parent type exists above a node
 * checks all the parents
 */
IGRstat VDct1CmdParentTypePresent(TGRid *nodeID,IGRchar *a_nodeType)
{
  IGRstat        retFlag   = 0;
  IGRstat        traceFlag = 0;
  TGRid          testID, outID;
  IGRchar        nodeType[128];
  TVDctBaseInfo  baseInfo;

  // say hi
  if (traceFlag) printf(">>> VDct1CmdParentPresent\n");

  // args check
  if (nodeID->objid == NULL_OBJID) goto wrapup;

  // copy it over
  testID = *nodeID;
  strcpy(nodeType,a_nodeType);
  
  // loop up the parents
  while (vdct1$GetTree1Parent(objID = &testID, outID = &outID)) {

    // get the baseInfo
    vdct1$GetBaseInfo(objID = &outID, baseInfo = &baseInfo); 
 
    // check to see if the type match is there
    if (!strcmp(baseInfo.nodeType,nodeType)) {
      retFlag = 1;
      break;
    }
    
    // give the loop the next ID to test
    testID = outID;
  }
  
wrapup:
  if (traceFlag) printf("<<< VDct1CmdParentPresent(%d)\n",retFlag);
  return retFlag;
}

/* ---------------------------------------------------------------
 * checks to see if an attribute is present anywhere and
 * if its value matches a desired value
 * this is a generic check of the node and all of its children
 * if they match it returns 1 to the retFlag and to the 
 * global static int attrPresent if it is found.
 * used to look up one level of kids and then call itself for each kid
 * do not call this routine directly
 * use its wrapper VDct1CmdChildAttrPresent (below)
 * attrPresent is  set in the wrapper to 0 to start the routine
 */
IGRstat VDct1CmdAttrPresent(TGRid *nodeID,IGRchar *a_attrName,IGRchar *a_attrVal)
{
  IGRstat        traceFlag = 0;
  TGRid          testID, childID;
  IGRchar        attrName[128];
  IGRchar        attrVal[128];
  IGRchar        buf[128];
  TVDctBaseInfo  baseInfo;
  TVDfld         attrFld;
  IGRstat        i;
 
  // say hi
  if (traceFlag) printf(">>> VDct1CmdAttrPresent(%d)\n",attrPresent);

  // args check
  if (nodeID->objid == NULL_OBJID) {
    if(traceFlag) printf("nodeID was null\n");
    
    goto wrapup;
  }
  
  // has it been found?
  if (attrPresent == 1) {
    // quit looking if we have found it!
    goto wrapup;
  }
  
  // copy it up
  strcpy(attrName,a_attrName);
  strcpy(attrVal,a_attrVal);
  testID = *nodeID;

  // more protection must have test data!
  if (!strcmp(attrName,"")) {
    goto wrapup;
  }
  
  if (!strcmp(attrVal,"")) {
    goto wrapup;
  }
  
  // time to do the kids
  for(i = 0;vdct1$GetTree1Child(objID = &testID, 
				 nth   = i, 
				 outID = &childID); i++) {

    // get the attribute of the kid
    vdcol$GetAttr(objID = &childID, name = attrName, fld = &attrFld);

    // if the attribute exists
    if (*attrFld.name != 0) {

      // copy it up
      strcpy(buf,attrFld.val.txt);
      
      // ah! we found it!
      if (!strcmp(buf,attrVal)) {
	if(traceFlag) printf("We found it!\n");
        attrPresent = 1;
	goto wrapup;  // quit looking
      }
    }

    // call myself to test the next layer of kids
  VDct1CmdAttrPresent(&childID,attrName,attrVal);
  }
  
wrapup:
  if (traceFlag) printf("<<< VDct1CmdAttrPresent(%d)\n",attrPresent);
  return attrPresent;
}

/* ---------------------------------------------------------------------------
 * Looks up the children of a node and recursively their children and determines
 * if this node has any children of a specific type or name
 * defaults to null name or type,  If null it looks for the other one
 * both null exits. Both present looks for both present at same time
 * does not test the incomming nodeID
 */
IGRstat VDct1CmdNodeNameTypePresent(TGRid *nodeID,IGRchar *a_nodeType,IGRchar *a_nodeName)
{
  IGRstat       traceFlag = 0;
  IGRstat       retFlag   = 0;
  IGRint        i;
  TGRid         testID, childID;
  IGRchar       nodeType[128],nodeName[128],buf[128];
  TVDctBaseInfo baseInfo;
  
  // say hi
  if(traceFlag) printf(">>> VDct1CmdNodeNameTypePresent\n");

  // args check
  if((a_nodeType == NULL) && (a_nodeName == NULL)) goto wrapup;
  if(nodeID->objid == NULL_OBJID) goto wrapup;

  // init
  if(a_nodeType != NULL) strcpy(nodeType,a_nodeType);
  if(a_nodeName != NULL) strcpy(nodeName,a_nodeName);
  testID = *nodeID;

  // time to do the kids
  for(i = 0;vdct1$GetTree1Child(objID = &testID, 
				nth   = i, 
				outID = &childID); i++) {

    // get the baseInfo of the kids
    vdct1$GetBaseInfo(objID = &childID, baseInfo = &baseInfo); 

    // nodeType only match nodeName = NULL
    if((!strcmp(nodeType,baseInfo.nodeType)) && (a_nodeName == NULL)) {
      retFlag = 1;
      goto wrapup;
    }
    
    // nodeName only match nodeType = NULL
    if((!strcmp(nodeName,baseInfo.nodeName)) && (a_nodeType == NULL)) {
      retFlag = 1;
      goto wrapup;
    } 

    // nodeType and Name match
    if((!strcmp(nodeName,baseInfo.nodeName)) && (!strcmp(nodeType,baseInfo.nodeType))) {
      retFlag = 1;
      goto wrapup;
    } 

    // call myself to test my kids
    retFlag = vdct1$CmdNodeNameTypePresent(nodeID     = &childID,
					   a_nodeType = nodeType,
					   a_nodeName = nodeName);
    if(retFlag) goto wrapup;

  } // getting the kids loop
  
  // go home
wrapup:
  if(traceFlag) printf(">>> VDct1CmdNodeNameTypePresent(%d)\n",retFlag);
  return retFlag;
}


/* -------------------------------------------
 * wrapper for VDct1CmdAttrPresent
 * sets up the static value to 0 and then kicks off the 
 * test routine to scan for attributes and the set value
 * all the args testing is done in the test routine
 * call this routine for getting attribute status of the kids
 */
IGRstat VDct1CmdChildAttrPresent(TGRid *nodeID,IGRchar *a_attrName,IGRchar *a_attrVal)
{
  IGRstat        traceFlag = 0;
  TGRid          testID;
  IGRchar        attrName[128];
  IGRchar        attrVal[128];
  IGRchar        buf[128];
  
  // set the flag to 0;
  attrPresent = 0;
  if (traceFlag) printf(">>> VDct1CmdChildAttrPresent()\n");

  // copy it up
  strcpy(attrName,a_attrName);
  strcpy(attrVal,a_attrVal);
  testID = *nodeID;

  // go to the action ~attrPresent is global and set inside the call below
  attrPresent = VDct1CmdAttrPresent(&testID,attrName,attrVal);
  
  // done
  if(traceFlag) printf("<<< VDct1CmdChildAttrPresent(%d)\n",attrPresent);
  
  return attrPresent;
  
}

/* Sauby added, for query node capabilites
 * this originall setup for quering pallet codes, but can
 * be used for other queries in other PPLs if needed.
 */

IGRstat VDct1CmdNodeQuery()
{
  IGRstat  retFlag = 0;
  IGRstat  traceFlag = 0;
  
  IGRstat  sts = 1;
  
  TGRid    pplID;
  IGRint   pplRet;
  TVDctBaseInfo parentBaseInfo;

  TVDct1JD parentJD;
  
  //say hi
  if (traceFlag) printf("Calling VDct1CmdNodeQuery\n");
  vdct1$GetBaseInfo(objID = &parentNodeID, baseInfo = &parentBaseInfo);
 
  // Tree interface
  parentJD.cl = VDct1GetTreeClassForNode(&parentNodeID);
  if (parentJD.cl) {
    parentJD.id = parentNodeID;
    sts = _RTCJDC(&parentJD)->createNodeByQuery(&parentJD);
    if (sts & 1) 
      VDct1FormUpdateTreeRow(cmdInfo->tree.form,VDCT_FORM_TREE_G_TREE,&parentNodeID);
        
    return sts;
  }
  
 

  //load the ppl
  vdppl$Load(name = parentBaseInfo.setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;
  
  //set the data
  vdppl$SetData(pplID = &pplID,
		name = "BASE_INFO_PARENT",
		size = sizeof(TVDctBaseInfo),
		data = (IGRchar*)&parentBaseInfo);

  vdppl$SetData(pplID = &pplID,
	        name  = "NODE_PARENT_ID",
		size  = sizeof(TGRid),
		data  = (IGRchar*)&parentNodeID);
  
  //run the ppl
  vdppl$Run(pplID = &pplID, name = "pplNodeQuery", ret = &pplRet);
  if (pplRet == 0) goto wrapup;

  //update the tree form

  VDct1FormUpdateTreeRow(cmdInfo->tree.form,VDCT_FORM_TREE_G_TREE,&parentNodeID);
   retFlag = 1;
   
wrapup:
  if (traceFlag) printf("Leaving VDct1CmdNodeQuery(%d)\n",retFlag);
  
  return retFlag;
  
}  //end of VDct1CmdNodeQuery
/* end of Sauby  */

// wrapper for ppl rules
IGRstat VDct1CmdNodeRulesOK(TGRid         *parentNodeID,
			    TGRid         *childNodeID,
			    TVDctBaseInfo *baseInfo, 
			    IGRchar       *a_location)
{

  TGRid   pplID;
  IGRint  pplRet;
  IGRchar location[128];
  TVDctBaseInfo parentBaseInfo;
  IGRstat sts = 1;
  IGRint  traceFlag = 0;
  

  if (traceFlag) printf("Calling VDct1CmdNodeRulesOK\n");
  // Just call ppl
  vdct1$GetBaseInfo(objID = parentNodeID, baseInfo = &parentBaseInfo);
  if (*parentBaseInfo.nodeType == 0) goto wrapup;

  // load the ppl
  vdppl$Load(name = parentBaseInfo.setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup; 

  // set the data
  vdppl$SetData(pplID = &pplID,
                name  = "ACTION_OK",
                size  = sizeof(IGRstat),
                data  = (IGRchar*)&sts);

  vdppl$SetData(pplID = &pplID,
                name  = "NODE_PARENT_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)parentNodeID);

  vdppl$SetData(pplID = &pplID,
                name  = "BASE_INFO",
                size  = sizeof(TVDctBaseInfo),
                data  = (IGRchar*)baseInfo);

  vdppl$SetData(pplID = &pplID,
                name  = "BASE_INFO_PARENT",
                size  = sizeof(TVDctBaseInfo),
                data  = (IGRchar*)&parentBaseInfo);

  strcpy(location,a_location);
  vdppl$SetData(pplID = &pplID,
                name  = "LOCATION",
                size  = 128,
                data  = location);
  // run the ppl
  vdppl$Run(pplID = &pplID, name = "pplNodeRulesOK", ret = &pplRet);

  // get the data from the ppl
  vdppl$GetData(pplID = &pplID,
                name  = "ACTION_OK",
                size  = sizeof(IGRstat),
                data  = (IGRchar*)&sts);

  vdppl$GetData(pplID = &pplID,
                name  = "BASE_INFO",
                size  = sizeof(TVDctBaseInfo),
                data  = (IGRchar*)baseInfo);

  vdppl$GetData(pplID = &pplID,
                name  = "BASE_INFO_PARENT",
                size  = sizeof(TVDctBaseInfo),
                data  = (IGRchar*)&parentBaseInfo);

wrapup:

  if (traceFlag) printf("Leaving VDct1CmdNodeRulesOK %d\n",sts);  
  return sts;

}


IGRstat VDct1CmdNodeNotifyNodeType();
/* ----------------------------------------
 * External Routines
 */
extern IGRint     GRconfirm_box();
extern IGRint     VDnotify_box();



/* --------------------------------------
 * Confirm Box
 */  
IGRstat VDct1CmdNodeConfirmBox(IGRchar msg[256])
{
  IGRstat sts;
  sts = GRconfirm_box(msg);
  return sts;
}

/* ---------------------------------------
 * Construction on Nodes Warning
 */
IGRstat VDct1CmdNodeConstruction()
{
  IGRstat     sts   = 0;
  IGRchar     buf[128];
  
  /////////////////////// Construction //////////////////////////////////////////
  // This is because the software is under construction to prevent user accidents
  // prevent all but this type of Tree
    // message of construction
   sts = vdct1$CmdNodeMsgBox();
    strcpy(buf,"Select Another Node Operation\\n\nOn Node Form\n\n");
    // message to choose another tree type
    sts = vdct1$CmdNodeMsgBox(msg = buf);
  
  // REMOVE this and alter as more trees come into operation
    ///////////////////////////////////////////////////////////////////////////////
}

/* ------------------------------------------
 * Generic Notice Box of Construction or other Message
 */

IGRstat VDct1CmdNodeMsgBox(IGRchar *msg)
{
  IGRint       retFlag = 0;
  IGRint       sts     = 0;
  IGRchar      buf[128];
  IGRchar      bars[128];
  
  strcpy(bars,"///////////////////////////");

  if (msg) sts = VDnotify_box(msg);

  if (!(msg)) {
    sprintf(buf,"%s\nThis Area\n%s\nUnder Construction\n%s\n\n",bars,bars,bars);
    sts = VDnotify_box(buf); 
    retFlag = 1;
  }
  
wrapup:
  return retFlag;
  
}

/* -------------------------------------------
 * Writes out the duplicate control box
 */
IGRstat VDct1CmdNodeSeeDupMsg()
{
  IGRint retFlag = 0;
  IGRint sts     = 0;
  IGRchar msg[128];

  if (dupFlag){
    
    if (multFlag) {
      if (!(boxCount % 5)) {
      
	// every 5 duplicates give the choice of turning off the notices
	sprintf(msg,"Show Notices of all Duplicates?");
	sts = GRconfirm_box(msg);
      
	if (!(sts & 1)) {
	  // turn off the boxes
	  dupFlag = 0;
	  multFlag = 0;
	}
      
      }
     boxCount++;
    }
  }
  
  retFlag = 1;
  
  // oh well
wrapup:
  return retFlag;

}
/* --------------------------------------------
 * Reports out Message of Node already existing
 */

IGRstat VDct1CmdNodeDupMsg(TVDctBaseInfo *baseInfo)
{
  IGRint retFlag = 0;
  IGRchar   msg[128];

  // write the message to the buffer
  sprintf(msg,"%s %s\n\nNode already in Tree\n\nNode not made\n\n",
	  baseInfo->nodeType,baseInfo->nodeName);
  // Do we see the duplicates
  VDct1CmdNodeSeeDupMsg();
  // give notice
  if (dupFlag) retFlag = VDnotify_box(msg);
 
    
  // oh well
wrapup:
  return retFlag;

}

/*--------------------------------------------
 * Set the Display Flags off from Duplicate operations
 */
IGRstat VDct1CmdNodeDupFlagOff()
{
  multFlag = 0;
  boxCount = 0;
  dupFlag = 1;

  return 1;
  
}

/* -------------------------------------------
 * Add a part to the existing CG
 */
IGRstat VDct1CmdNodeCG(TVDctCGinfo *partCG, TVDctCGinfo *assyCG)
{
  IGRstat retFlag   = 0;
  IGRint  traceFlag = traceFlagx;
  TVDctCGinfo workCG;

  // say hi
  if (traceFlag) printf(">>> VDct1CmdNodeCGAddPart\n");

  // args check
  if (partCG == NULL) goto wrapup;
  if (assyCG == NULL) goto wrapup;

  // sum the mass
  workCG.mass = partCG->mass + assyCG->mass;

  // locate the coordinates
  workCG.xcoord  = ((partCG->xcoord * partCG->mass) + (assyCG->xcoord *assyCG->mass))/workCG.mass;
  workCG.ycoord  = ((partCG->ycoord * partCG->mass) + (assyCG->ycoord *assyCG->mass))/workCG.mass; 
  workCG.zcoord  = ((partCG->zcoord * partCG->mass) + (assyCG->zcoord *assyCG->mass))/workCG.mass;

  // copy it out
  assyCG->xcoord = workCG.xcoord;
  assyCG->ycoord = workCG.ycoord;
  assyCG->zcoord = workCG.zcoord;
  assyCG->mass   = workCG.mass;
  
  // success
  retFlag = 1;

  // oh well!
wrapup:
  // say bye
  if (traceFlag) printf("<<< VDct1CmdNodeCGAddPart(%d)\n",retFlag);
  return retFlag;
  
}

/* -------------------------------------------
 * Set the Display Flags for Duplicates on the copy from view
 */
IGRstat VDct1CmdNodeDupFlag(IGRint copy)
{
  boxCount = 0;
  multFlag = 0;
  dupFlag = 1;
  if (copy) multFlag = 1;
  if (!(copy)) boxCount = 1;
  return 1;
}

/* -------------------------------------------
 * Post the selected node
 */
IGRstat VDct1CmdNodeNotifyPostNode()
{
  IGRstat retFlag = 0;
  IGRint  traceFlag = traceFlagx;

  // say hi
  if (traceFlag) {
    printf(">>> VDct1CmdNodeNotifyPostNode \n");
 }

  // Just a wrapper
  vdct1$PostNode(nodeID = &activeNodeID);
  
  // Done
  retFlag = 1;
  
//wrapup:

 // say bye
  if (traceFlag) {
    printf("<<< VDct1CmdNodeNotifyPostNode %d \n",retFlag);
 }
  return retFlag;
}

/* -------------------------------------------
 * Tells the ppl to create default nodes
 */
IGRstat VDct1CmdNodeNotifyCreateDefaultNodes()
{
  IGRstat retFlag = 0;
  IGRint  traceFlag = traceFlagx;
  
  TVDctBaseInfo baseInfo;
  TGRid  pplID;  
  IGRint pplRet;

  // say hi
  if (traceFlag) {
    printf(">>> VDct1CmdNodeNotifyCreateDefault \n");
  }

  // Just call ppl
  vdct1$GetBaseInfo(objID = &parentNodeID, baseInfo = &baseInfo);
  if (*baseInfo.nodeType == 0) goto wrapup;
  
  vdppl$Load(name = baseInfo.setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;

  vdppl$SetData(pplID = &pplID,
                name  = "NODE_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)&parentNodeID);

  vdppl$Run(pplID = &pplID, name = "createDefaultNodes", ret = &pplRet);

  // Tell the tree to update itself
  VDct1FormUpdateTreeRow(cmdInfo->tree.form,VDCT_FORM_TREE_G_TREE,&parentNodeID);

  // Done
  retFlag = 1;
  
wrapup:
  // say bye
 if (traceFlag) {
     printf("<<< VDct1CmdNodeNotifyCreateDefault %d\n",retFlag);
 }
  return retFlag;
}

/* -------------------------------------------
 * Basically tries to convert an eng node to a bom node
 */
IGRstat VDct1AddBOMNode(TGRid *bomID,TGRid *engID, IGRchar *unitFilter)
{
  IGRstat retFlag = 0;
  IGRint  traceFlag = traceFlagx;
  TVDfld  fld;
  IGRint  i;
  TGRid   childID;

  TVDctBaseInfo baseInfo;

   // say hi
  if (traceFlag) {
    printf(">>> VDct1AddBOMNode\n");
  }

  // Arg Check
  if ((bomID == NULL) || (bomID->objid == NULL_OBJID)) goto wrapup;
  if ((engID == NULL) || (engID->objid == NULL_OBJID)) goto wrapup;
  
  // Needs to have a unit attribute
  vdcol$GetAttr(objID = engID, name = "teng_unit_num", fld = &fld);
  if (*fld.name == 0) {
    
    // Cycle downwards
    for(i = 0; vdct1$GetTree1Child(objID = engID, nth = i, outID = &childID); i++) {
      VDct1AddBOMNode(bomID,&childID, unitFilter);
    }
    retFlag = 1;
    goto wrapup;
  }
  
  // If the attribute does not match, then just stop
  if (strcmp(fld.val.txt,unitFilter)) {
    retFlag = 1;
    goto wrapup;
  }

  // Should be part of the bom
  vdct1$GetBaseInfo(objID = engID, baseInfo = &baseInfo);
  printf("BOM Node %s\n",baseInfo.baseName);
  
  /* ----------------------------------------------
   * Check under the bom tree to see if this type
   * Has already been processed, if so, just adjust qty
   */

  /* ---------------------------------------------
   * Cycle through first level of kids, add any
   * parts found, breakout any assemblies
   */

  // Done
  retFlag = 1;
   
wrapup:

  // say bye
 if (traceFlag) {
     printf("<<< VDct1AddBOMNode %d\n",retFlag);
 }

  return retFlag;
}

/* -------------------------------------------
 * This function converts an engineering tree
 * to a mbom tree
 */
IGRstat VDct1CmdNodeNotifyBOMNode()
{
  IGRstat retFlag = 0;
  IGRint  traceFlag = traceFlagx;
  
  TGRid srcID;
  TGRid desID;
  
  TVDctBaseInfo desBaseInfo;
  TVDctSetName  unitFilter;
  IGRchar *p;
  
  TGRid childID;
  
  // say hi
  if (traceFlag){
    printf(">>> VDct1CmdNodeNotifyBOMNode\n");
  }
  
  // Need a source
  VDct1CmdLibGetCopiedNode(&srcID);
  if (srcID.objid == NULL_OBJID) goto wrapup;

  // Pull the parent node
  desID = parentNodeID;
  vdct1$GetBaseInfo(objID = &desID, baseInfo = &desBaseInfo);
  if (*desBaseInfo.nodeType == 0) goto wrapup;
  
  // The first part of the name should be the unit number
  strcpy(unitFilter,desBaseInfo.setName);
  p = strchr(unitFilter,' ');
  if (p) *p = 0;
  // printf("Unit filter is '%s'\n",unitFilter);
  
  // For now, delete anything under the tree
  VDct1FormContractTreeRowID(cmdInfo->tree.form, VDCT_FORM_TREE_G_TREE,&desID);
  VDct1FormContractTreeRowID(cmdInfo->lib.form,  VDCT_FORM_LIB_G_TREE, &desID);

  while(vdct1$GetTree1Child(objID = &desID, nth = 0, outID = &childID)) {
    vdct1$DeleteNode(nodeID = &childID);
  }

  // Process each node
  VDct1AddBOMNode(&desID,&srcID,unitFilter);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ------------------------------------------------------
 * 6 Disconnect Model Node
 * disconnect a model object from its attachment to the model
 * used to allow the user to go back and disconnect a part 
 * that was misconnected
 * nothing too fancy just get the modelOE disconnected
 */
IGRstat VDct1CmdNodeDisconnectModelNode(TGRobj_env *modelOE)
{
  IGRstat        retFlag = 0;
  IGRstat        traceFlag = 0;
  TGRid          nodeID;
  IGRstat        sts, msg;
  IGRchar        buf[128];
  TVDctBaseInfo  baseInfo;
  Form           form = cmdInfo->node.form;
// Keep copies of the channel selection
struct {
  IGRint          init;
  OM_S_CHANSELECT select;
} notifyChn,listenerChn;

  listenerChn.init = 0;

  // say hi
  if (traceFlag) printf(">>> VDct1CmdNodeDisconnectModelNode\n");
    // Make selection
    sts = om$make_chanselect(channame     = "VDct1Base.to_notify", 
			     p_chanselect = &listenerChn.select);
    if (!(sts & 1)) goto wrapup;
    listenerChn.init = 1;
  
  // Pull the active node
  nodeID = activeNodeID;
  vdct1$GetBaseInfo(objID = &nodeID, baseInfo = &baseInfo);  
  if (*baseInfo.nodeType == 0) goto wrapup;
  
  // check the model for channel connection
  sts = vdct1$GetModelObjectNode(modelOE = modelOE,
				 setType = baseInfo.setType,
				 nodeID  = &nodeID);

  // if it is not here go home
  if (nodeID.objid == NULL_OBJID) {
    // notify already not connected
    sts = vdct1$CmdNodeMsgBox(msg = "Node Connection\n\nNot Found\n");
    strcpy(buf,"Node connection not found");
    vdfrm$SetText(form   = form,
		  txt    = buf);
    goto wrapup;
  }
  
  // Connect it
  if (traceFlag) printf("Sending the disconnect\n");

  sts = om$send(msg = message
		GRnotify.GRntfydisconn(&msg,
				       &nodeID,
				       &listenerChn.select),
		senderid = NULL_OBJID,
		targetid = modelOE->obj_id.objid,
		targetos = modelOE->obj_id.osnum);

  if (traceFlag) {
    printf(">>> om$send .... \n");
    vdobj$Print(objID = &nodeID);
    vdobj$Print(objOE = modelOE);
  }
 
    // notify the form  that the item was disconnected
  strcpy(buf,"Node disconnected successfully");
    vdfrm$SetText(form   = form,
		  txt    = buf);

    // notify the popup that the item was disconnected
    sts = vdct1$CmdNodeMsgBox(msg = "Node Disconnection\n\nSuccessful\n");

  // success
  retFlag = 1;

  // oh well
wrapup:
  // say bye
  if (traceFlag) printf("<<< VDct1CmdNodeDisconnectModelNode(%D)\n",retFlag); 
  return retFlag;
  
}

/* -------------------------------------------
 * Hook to a model object to the active node
 */
IGRstat VDct1CmdNodeConnectModelNode(TGRobj_env *modelOE)
{
  IGRstat        retFlag = 0;
  Form           form = cmdInfo->node.form;
  TVDctBaseInfo  baseInfo;
  TGRid          nodeID,nodeIDx;
  TGRobj_env     modelOEx;
  IGRstat        sts;
  IGRstat        traceFlag = 0;
  IGRchar        buf[128];
  
  // Say hi
  if (traceFlag) {
    printf("VDct1CmdNodeConnectModelNode \n");
  }

  // Pull the active node
  nodeID = activeNodeID;
  vdct1$GetBaseInfo(objID = &nodeID, baseInfo = &baseInfo);  
  if (*baseInfo.nodeType == 0) goto wrapup;

  // Make sure don't already have a model
  vdct1$GetNodeModelObject(nodeID  = &nodeID,
			   modelOE = &modelOEx);
  
  if (modelOEx.obj_id.objid != NULL_OBJID) {
    strcpy(buf,"The nodes is\n\nalready connected\n");
    if (traceFlag) {
      sts = vdct1$CmdNodeMsgBox(msg = buf);
    }    
    vdfrm$SetStatus(form = form, txt = "Node is already connected");
    goto wrapup;
  }

  // check the model for channel connection
   sts = vdct1$GetModelObjectNode(modelOE = modelOE,
				  setType = baseInfo.setType,
				  nodeID  = &nodeIDx);
   
   if (nodeIDx.objid != NULL_OBJID) {

     // prevent any duplicates
     strcpy(buf,"Duplicate model\n\nconnection prevented\n");
     if (traceFlag) {
       sts = vdct1$CmdNodeMsgBox(msg = buf);
     }
    
     vdfrm$SetStatus(form = form, txt = "Duplicate model connection prevented");
     goto wrapup;
   }

   // check if it is a valid match
   sts = vdct1$IsPartConValid(nodeID   = &nodeID,
			      baseInfo = &baseInfo,
			      modelOE  = modelOE);
   
   // if not a match go home
   if (!(sts & 1)) {
     strcpy(buf,"The nodes are\n\nnot the same\n");
     if (traceFlag) {
       sts = vdct1$CmdNodeMsgBox(msg = buf);
     }
    
     vdfrm$SetStatus(form = form, txt = "The nodes are not the same.");
     goto wrapup; 
   }
#if 0
   // No longer changing the name since it needs to match already

   // Get the objects name
   vdobj$Get(objOE = modelOE, objName = baseInfo.nodeName);
   VDstrupr(baseInfo.nodeName);
  
   // Reset Objects name
   vdct1$SetBaseInfo(objID = &nodeID, baseInfo = &baseInfo);

   if (traceFlag) {
     printf(">>> Call check\n");
     vdobj$Print(objID = &nodeID);
     vdobj$Print(objOE = modelOE);
   }
   strcpy(buf,"The nodes is\n\nbeing connected\n");
   if (traceFlag) {
     sts = vdct1$CmdNodeMsgBox(msg = buf);
   }
#endif

   // Connect it up
   VDct1ConnectNodeToModelObject(&nodeID, modelOE);

   // Really need to recompute the tree as well

   // Transfer some attributes ~pn this is commented off because the function call was commented off so 
   // the macro was installed and commented off...
   // VDct1CopyAttributesFromModelToNode(&nodeID,modelOE);
   //vdct1$CopyAttributesFromModelToNode(nodeID  = &nodeID,   //  I - nodeID to lookup
   //			      modelOE = modelOE)   //  I - modelOE to copy from

    
   // Need to tell the world (which activates the node and updates the forms)
   VDct1CmdMgrRenamedNode(&nodeID);
 
   // Done
   retFlag = 1;
  
 wrapup:

   // say bye
   if (traceFlag){
     printf("<<< VDct1CmdNodeNotifyModelNode %d\n",retFlag);
   }
  
  return retFlag;
}

/* -------------------------------------------
 * The user locates an object such as a ladder
 * If the located object is a standard assembly
 * then copy in the assembly and attach accordingly
 *
 * If the object is not a standard assembly then ???
 */
IGRstat VDct1CmdNodeCreateModelAssembly(TGRobj_env *modelOE)
{
  IGRstat retFlag = 0;
  IGRint  traceFlag = traceFlagx;

  TGRid   saID;
  IGRchar unit[128];
  IGRchar eqp_number[128];
  IGRchar sa_number[128];
  IGRchar *p;
  
  //  say hi
  if (traceFlag){
    printf(">>> VDct1CmdNodeCreateModelAssembly \n");
  }

  // See if already attached to the current tree

  // Pull the unit number
  vdsa$GetStruct(objOE = modelOE, name = "unit_number", txt = unit);
  if (*unit == 0) strcpy(unit,"XXXX");

  // Pull the equipment number
  vdsa$GetStruct(objOE = modelOE, name = "eqp_number", txt = eqp_number);
  if (*eqp_number == 0) goto wrapup;

  // Extract the standard assembly number
  strcpy(sa_number,eqp_number);
 
  p = strchr(sa_number,'_');
  if (*p) *p = 0;
  VDstrupr(sa_number);
  
  // Find the standard assembly
  VDct1SearchForStandardAssembly(sa_number,&saID);
  if (saID.objid == NULL_OBJID) goto wrapup;

  // Summarize
  printf("------------------------------------------\n");
  vdobj$Print(objOE = modelOE);
  printf("ASSY %s %s %s\n",unit,eqp_number,sa_number);
  vdobj$Print(objID = &saID);

#if 0  
  // Pull the node type
  vdfrm$GetText(form   = form,
		gadget = VDCT_FORM_NODE_G_EDIT_NODE_TYPE,
		txt    = baseInfo.nodeType);

  // Get the objects name  vdobj$Get(objOE = modelOE, objName = baseInfo.nodeName);
 
  VDstrupr(baseInfo.nodeType);
  VDstrupr(baseInfo.nodeName);
  
  /* ------------------------------------------------
   * Actual creation is done by the ppl so let it do 
   * the validation
   */
  vdct1$CreateNode(parentID = &parentNodeID,
		   nodeType = baseInfo.nodeType,
		   nodeName = baseInfo.nodeName,
		   nodeID   = &nodeID);
  
  if (nodeID.objid == NULL_OBJID) {
    sprintf(buf,"Node Creation Failed For '%s', '%s'",
	    baseInfo.nodeType,
	    baseInfo.nodeName);
    vdfrm$SetStatus(form = form, txt = buf);
    goto wrapup;
  }

  // Connect it up
  VDct1ConnectNodeToModelObject(&nodeID, modelOE);

  // Transfer some attributes
  vdct1$CopyAttributesFromModelToNode(nodeID  = &nodeID,   //  I - nodeID to lookup
				      modelOE = modelOE);   //  I - modelOE to copy from

#if 0
  VDct1CopyAttributeFromModelToNode(&nodeID,
				    "tpart_isdp_mino",
				    modelOE,
				    "eqp_partno");
#endif

  // Need to tell the world (which activates the node and updates the forms)
  VDct1CmdMgrCreatedNode(&nodeID);
#endif

  // Done
  retFlag = 1;
  
wrapup:

  //  say bye
  if (traceFlag){
    printf("<<< VDct1CmdNodeCreateModelAssembly %d\n",retFlag);
  }

  return retFlag;
}

/* ---------------------------------------------
 * Actually create a part few data Checks here! JUST DO IT!
 */
IGRstat VDct1CmdNodeMakePart(TVDctBaseInfo *baseInfo)
{
  IGRstat       retFlag = 0;
  IGRstat       sts;
  IGRstat       traceFlag = 0;
  TVDctBaseInfo parentBaseInfo;
  Form form   = cmdInfo->node.form;
  TGRid         nodeID;  
  IGRchar       location[128], buf[128];

  // say hi
  if (traceFlag) printf(">>> VDct1CmdNodeMakePart()\n");

  // validate the node for creation
  sts = vdct1$IsChildTypeValid(parentID  = &parentNodeID,
			       childType = baseInfo->nodeType);  
  // rules to control the duplicate check
  sprintf(location,"%s",VDCT1_ACTION_PARTS);

  sts = vdct1$CmdNodeRulesOK(parentNodeID  = &parentNodeID,
			     baseInfo      = baseInfo,
			     location      = location);
  if (sts & 1) {
    
    // Test for Duplicates and reject them 
    sts = vdct1$CmdCheckForDuplicate(nodeID   = &parentNodeID,
				     baseInfo = baseInfo);
  
    if (!(sts & 1)){    
      // write the messages
      VDct1CmdNodeDupMsg(baseInfo);
      goto wrapup;
    } 
  }
  
 /* ------------------------------------------------
   * Actual creation is done by the ppl so let it do 
   * the validation
   */
  vdct1$CreateNode(parentID = &parentNodeID,
		   nodeType = baseInfo->nodeType,
		   nodeName = baseInfo->nodeName,
		   nodeID   = &nodeID);

  if (nodeID.objid == NULL_OBJID) {
    sprintf(buf,"Node Creation Failed For '%s', '%s'",
	    baseInfo->nodeType,
	    baseInfo->nodeName);
    vdfrm$SetStatus(form = form, txt = buf);  
    goto wrapup;
  }
  // Connect it up
  //VDct1ConnectNodeToModelObject(&nodeID, modelOE);

  // Generic recomputer
  vdct1$ComputeNode(nodeID = &nodeID);

  // summary of node totals up tree
  vdct1$SummaryNode (parentID = &parentNodeID);

  // Need to tell the world (which activates the node and updates the forms)
  VDct1CmdMgrCreatedNode(&nodeID);

 // update the summary
  VDct1FormUpdateVRTree(cmdInfo->tree.form, VDCT_FORM_TREE_G_TREE);
  VDct1FormUpdateVRTree(cmdInfo->lib.form, VDCT_FORM_LIB_G_TREE);
  // success
  retFlag = 1;
wrapup:
  if (traceFlag) printf("<<< VDct1CmdNodeMakePart(%d)\n",retFlag); 
  return retFlag;
}

/* ---------------------------------------------
 * Create a Part by Database Lookup!
 * wraps around action
 */
IGRstat VDct1CmdNodeCreatePart()
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRstat traceFlag = 0;
  TVDctBaseInfo baseInfo, parentBaseInfo;
  TGRid nodeID;  
  // say hi
  if (traceFlag) printf(">>> VDct1CmdNodeCreatePart()\n");
  

  // success
  retFlag = 1;
wrapup:
  if (traceFlag) printf("<<< VDct1CmdNodeCreatePart(%d)\n",retFlag); 
  return retFlag;
}

/* -------------------------------------------
 * Create a node and hook to a model object
 */
IGRstat VDct1CmdNodeCreateModelNode(TGRobj_env *modelOE)
{
  IGRstat  retFlag = 0;
  IGRstat  traceFlag = traceFlagx;
  IGRstat  sts;

  Form form = cmdInfo->node.form;
  
  IGRchar buf[128], buff1[128], buff2[128];
  IGRchar blank[128] = "";
  TVDctBaseInfo baseInfo, parentBaseInfo, baseInfo1;
  TGRid nodeID;

  IGRint desFlag = 1;
  TVDctNodeType a_NodeType;
  TGRid         a_treeID;
  TVDfld        a_fld;
  IGRchar       msg[128]; 
  IGRchar       msg2[128];
  IGRchar       location[128];
  
  TVDct1_part_fld_part_cage_num part_cage_num;
  TVDct1_part_fld_part_id       part_id;
  
  // say hi
  traceFlag = traceFlagx;
  traceFlag = 0;
  if (traceFlag) {
    printf(">>> VDct1CmdNodeCreateModelNode \n"); 
  }
  vdfrm$SetStatus(form = form, txt = "Create Model Node");
  
  strcpy(buff2,"The node is\n\nbeing connected\n");
  if (traceFlag) {
    //sts = vdct1$CmdNodeMsgBox(msg = buff2);
  }

  // get the modelOE className
  vdobj$Get(objOE     = modelOE,
	    className = buf);
 
  // prevent a CS node from being made!
  if(!strcmp(buf,"GRgencs")) goto wrapup;
  
  // get baseInfo for parentNodeID;
  vdct1$GetBaseInfo(objID = &parentNodeID, baseInfo = &baseInfo);
  strcpy(location,VDCT1_ACTION_CMN_OK);
  
  sts = vdct1$CmdNodeRulesOK(parentNodeID  = &parentNodeID,
			     baseInfo      = &baseInfo,
			     location      = location);

  if (!(sts & 1)) {

    // tell the user we don't allow attaching under this node
    strcpy(msg,"This node cannot be attached\n\nunder this parent node\n");
    sts = vdct1$CmdNodeMsgBox(msg = msg);
    goto wrapup;
  }
  
  // check the model for channel connection
  sts = vdct1$GetModelObjectNode(modelOE = modelOE,
				 setType = baseInfo.setType,
				 nodeID  = &nodeID);
  if (nodeID.objid == NULL_OBJID) {
    if (traceFlag) printf("Channel connection not found\n");
  }
  else {
    if (traceFlag) {
      printf("nodeID [%d] [%d]\n",nodeID.osnum,nodeID.objid);
      printf("Channel connection found\n");
    }

    // get baseInfo for nodeID;
    vdct1$GetBaseInfo(objID = &nodeID, baseInfo = &baseInfo1);
    VDct1CmdNodeDupMsg(&baseInfo1);
    goto wrapup;
  }
  
  // Pull the node type
  vdct1$GetTypeForModelObject(parentID = &parentNodeID,
			      modelOE  = modelOE,
			      nodeType = baseInfo.nodeType);
  if (*baseInfo.nodeType == 0) {
    vdfrm$SetStatus(form = form, txt = "Invalid Parent Type");
    goto wrapup;
  }
  // does this part need to be in OPS?
  sts = vdct1$MustPartBeInOPS(nodeID = &parentNodeID);
  if(sts) {
    
  // Need a cage_num
  VDct1GetPartCageNumForModelObject(modelOE,NULL,part_cage_num,part_id);
  if (*part_cage_num == 0) {
    vdfrm$SetStatus(form = form,txt = "MODEL OBJECT NOT IN OPS");
    goto wrapup;
  }
  strcpy(baseInfo.nodeName,part_cage_num);
  }
  

#if 0
  // Not sure I understand why activeNodeID is used here

  // Check for special model rules
  sprintf(location,"%s",VDCT1_ACTION_C_MODEL_ATTRS);

  sts = vdct1$CmdNodeRulesOK(parentNodeID  = &activeNodeID,
			     baseInfo      = &baseInfo,
			     location      = location);

  // exit if rules apply
  if (!(sts & 1)) {
    vdct1$CSGetNodeMatrix(nodeID = &activeNodeID,
			  csOE   = modelOE);    
    goto wrapup;
  }
  // ??? And nodeID is not set yet
  // get baseInfo for nodeID;
  vdct1$GetBaseInfo(objID = &nodeID, baseInfo = &baseInfo1);
#endif

  // validate the node for creation
  sts = vdct1$IsChildTypeValid(parentID  = &parentNodeID,
			       childType = baseInfo.nodeType);  
  if (!(sts & 1)){  

    // get the parentNodeID baseinfo
    vdct1$GetBaseInfo(objID = &parentNodeID, baseInfo = &parentBaseInfo);
    strcpy(buff1,parentBaseInfo.nodeType);
    strcpy(buff2,baseInfo.nodeType);
    sprintf(buf,"Invalid node type selection");

    if(!(strcmp(buff2,blank))) {
      strcpy(buff2,"is Blank");
      sprintf(buf,"Child Node is Blank - Select Child Type");
    }

    if(!(strcmp(buff1,blank))) {
      strcpy(buff1,"is Blank");
      sprintf(buf,"Parent Node is Blank - Select Parent Node");
    }   
        // tell the form
    vdfrm$SetStatus(form = form, txt = buf);  
    sprintf(buf,"Parent: %s\n\nNode Type : %s\n\nInvalid Node Type Selection\n\n",buff1,buff2);
    // tell the world
    
    if (dupFlag) {
    sts = VDnotify_box(buf);
    dupFlag = 0;
    }
    
    goto wrapup;
  }

#if 0  
  // In general, parts do not need to worry about dups???
  // Maybe this should say dup???

  // rules to control the duplicate check
  sprintf(location,"%s",VDCT1_ACTION_C_MODEL_NODE);

  sts = vdct1$CmdNodeRulesOK(parentNodeID  = &parentNodeID,
			     baseInfo      = &baseInfo,
			     location      = location);
  if (sts & 1) {

    if (traceFlag) printf("Testing for duplicates\n");
    
    // Test for Duplicates and reject them 
    sts = vdct1$CmdCheckForDuplicate(nodeID   = &parentNodeID,
				     baseInfo = &baseInfo);
  
    if (!(sts & 1)){    
      // write the messages
      VDct1CmdNodeDupMsg(&baseInfo);
      goto wrapup;
    } 
  }
#endif
  
  /* ------------------------------------------------
   * Actual creation is done by the ppl so let it do 
   * the validation
   */
  if (traceFlag) printf("Creating %s %s\n",baseInfo.nodeType,baseInfo.nodeName);
  
  vdct1$CreateNode(parentID = &parentNodeID,
		   nodeType = baseInfo.nodeType,
		   nodeName = baseInfo.nodeName,
		   nodeID   = &nodeID);
 
  if (nodeID.objid == NULL_OBJID) {
    sprintf(buf,"Node Creation Failed For '%s', '%s'",
	    baseInfo.nodeType,
	    baseInfo.nodeName);
    vdfrm$SetStatus(form = form, txt = buf);  
    goto wrapup;
  }
  // Connect it up
  VDct1ConnectNodeToModelObject(&nodeID, modelOE);

  // Generic recomputer
  vdct1$ComputeNode(nodeID = &nodeID);

  // Transfer some attributes
  vdct1$CopyAttributesFromModelToNode(nodeID  = &nodeID,    //  I - nodeID to lookup
				      modelOE = modelOE);   //  I - modelOE to copy from

  // rules to control the node attribute computations
  sprintf(location,"%s",VDCT1_ACTION_C_MODEL_ATTR);

  // get baseInfo for nodeID;
  vdct1$GetBaseInfo(objID = &nodeID, baseInfo = &baseInfo);

  sts = vdct1$CmdNodeRulesOK(parentNodeID  = &parentNodeID,
			     baseInfo      = &baseInfo,
			     location      = location);
  // if the rules return 1
  if (sts & 1) {
 
    // compute some node attributes
    vdct1$ComputeNodeAttr(nodeID   = &nodeID, 
			  baseInfo = &baseInfo,
			  parentID = &parentNodeID);
  }
  
  // summary of node totals up tree
  vdct1$SummaryNode (parentID = &parentNodeID);

  // Need to tell the world (which activates the node and updates the forms)
  VDct1CmdMgrCreatedNode(&nodeID);

  // update the summary (why, CreatedNode should handle this)
  VDct1FormUpdateVRTree(cmdInfo->tree.form, VDCT_FORM_TREE_G_TREE);
  VDct1FormUpdateVRTree(cmdInfo->lib.form,  VDCT_FORM_LIB_G_TREE);
 
  // Done
  retFlag = 1;
  
wrapup:

  // say bye
  if (traceFlag) {
    printf("<<< VDct1CmdNodeCreateModelNode %d\n",retFlag);
  }

  return retFlag;
}

/* -------------------------------------------
 * Traffic directory for handling located objects
 */
IGRstat VDct1CmdNodeLocatedObject(TGRobj_env *modelOE)
{
  IGRstat retFlag = 0;
  IGRint  traceFlag = traceFlagx;
  
  Form form = cmdInfo->node.form;
  
  IGRchar buf[256];
  
  // say hi
  if (traceFlag){
    printf(">>> VDct1CmdNodeLocatedObject \n"); 
  }

  // Switch on doit
  vdfrm$GetText(form   = form,
		gadget = VDCT_FORM_NODE_G_DOIT,
		txt    = buf);

  if(traceFlag) printf("buf is [%s]\n",buf);

  switch(*buf) {
 

  case '3': 
    VDct1CmdNodeCreateModelNode(modelOE);
    retFlag = 1;
    break;

  case '4':

    // Create model parts here.
    VDct1CmdNodeCreatePart();
    
    //VDct1CmdNodeCreateModelAssembly(modelOE);

    retFlag = 1;
    break;
    
  case '5': 
   if(traceFlag) printf("gone to connect the node\n");
    
    VDct1CmdNodeConnectModelNode(modelOE);
    retFlag = 1;
    break;

  case '6':
    // disconnects a modelpart from its modelOE
    if(traceFlag) printf("gone to disconect the node\n");
    
    VDct1CmdNodeDisconnectModelNode(modelOE);
    retFlag = 1;
    break;
  }
  
  //wrapup: 
  
  // say bye
  if (traceFlag){
    printf("<<< VDct1CmdNodeLocatedObject %d\n",retFlag); 
  }
  
  return retFlag;
}

/* -------------------------------------------
 * Move active node to parent node
 * Make sure they are in the same tree
 */
IGRstat VDct1CmdNodeNotifyMoveNode()
{
  IGRstat retFlag = 0;
  IGRint  traceFlag = traceFlagx;
  Form    form = cmdInfo->node.form;
  
  TVDctBaseInfo parentBaseInfo;
  TVDctBaseInfo activeBaseInfo;
  
  TGRid parentID;
  TGRid nodeID;
  
  // say hi
  if (traceFlag) {
    printf(">>> VDct1CmdNodeNotifyMoveNode \n"); 
  }

  // Need a destination
  vdct1$GetBaseInfo(objID = &parentNodeID, baseInfo = &parentBaseInfo);
  if (*parentBaseInfo.nodeType == 0) {
    vdfrm$SetStatus(form = form,
		    txt  = "Need An Active Parent");
    goto wrapup;
  }
  
  // Need a source
  VDct1CmdLibGetCopiedNode(&nodeID);
  
  vdct1$GetBaseInfo(objID = &nodeID, baseInfo = &activeBaseInfo);
  if (*activeBaseInfo.nodeType == 0) {
    vdfrm$SetStatus(form = form,
		    txt  = "Need A Copied Node In Library Form");
    goto wrapup;
  }
  
  // Need to be in the same set
  if (strcmp(parentBaseInfo.setType,activeBaseInfo.setType) ||
      strcmp(activeBaseInfo.setName,activeBaseInfo.setName)) {

    vdfrm$SetStatus(form = form,
		    txt  = "Can only move within the same tree");
    goto wrapup;
  }
  
  // Need current parent
  vdct1$GetTree1Parent(objID = &nodeID, outID = &parentID);
  if (parentID.objid == NULL_OBJID) {
    vdfrm$SetStatus(form = form,
		    txt  = "Active node has no parent???");
    goto wrapup;
  }
    
  // Disconnect then reconnect
  vdct1$DisConnectTree1Child(treeID = &parentID,  childID = &nodeID);
  vdct1$ConnectTree1Child(treeID = &parentNodeID, childID = &nodeID);
  
  // Update the forms directly for now
  VDct1FormUpdateTreeRow(cmdInfo->tree.form, VDCT_FORM_TREE_G_TREE, &parentID);
  VDct1FormUpdateTreeRow(cmdInfo->tree.form, VDCT_FORM_TREE_G_TREE, &parentNodeID);

  VDct1FormUpdateTreeRow(cmdInfo->lib.form,  VDCT_FORM_LIB_G_TREE, &parentID);
  VDct1FormUpdateTreeRow(cmdInfo->lib.form,  VDCT_FORM_LIB_G_TREE, &parentNodeID);

  // Make the new node active
  VDct1CmdMgrActivateNode(&nodeID);
  
  // Done
  retFlag = 1;
  
wrapup:

  // say bye
  if (traceFlag) {
    printf("<<< VDct1CmdNodeNotifyMoveNode %d\n",retFlag); 
  }

  return retFlag;
}


/* -------------------------------------------
 * Make a copy of the copied node
 * attach it to the parent then
 * repeat for each child of the copied node
 */
IGRstat VDct1NodeCopyNode(TGRid *parentID, TGRid *copyID, TGRid *rootID)
{
  IGRstat            retFlag = 0;
  IGRint             traceFlag = 0;

  TVDctBaseInfo      parentBaseInfo;
  TVDctBaseInfo      baseInfo1;
  TVDctBaseInfo      copyBaseInfo;
  TVDctBaseInfo      rootBaseInfo;
  TVDctNodeTypeInfo  nodeTypeInfo;
  TGRid              nodeID,childID;
  IGRint             i;
  IGRstat            sts, sts1, sts2;
  IGRchar            location[128];
  TVDfld             fld;

  TGRobj_env modelOE;
  Form form = cmdInfo->node.form;
  // say hi
  if (traceFlag) {
    printf(">>> VDct1NodeCopyNode \n");
  }

  // Grab the info
  vdct1$GetBaseInfo(objID = parentID, baseInfo = &parentBaseInfo);
  vdct1$GetBaseInfo(objID = copyID,   baseInfo = &copyBaseInfo);
  vdct1$GetBaseInfo(objID = rootID,   baseInfo = &rootBaseInfo);

  if (*parentBaseInfo.setType  == 0) goto wrapup;
  if (*copyBaseInfo.nodeType   == 0) goto wrapup;

  if (traceFlag) printf("Set types are OK!\n");

  if(traceFlag) {
    printf(" *************** Location 1 **************\n");
    printf("parentBaseInfo.nodeType = [%s], parentBaseInfo.nodeName = [%s]\n",
	   parentBaseInfo.nodeType,parentBaseInfo.nodeName);
    printf("copyBaseInfo.nodeType = [%s], copyBaseInfo.nodeName = [%s]\n",
	   copyBaseInfo.nodeType,copyBaseInfo.nodeName);
    printf("rootBaseInfo.nodeType = [%s], rootBaseInfo.nodeName = [%s]\n",
	   rootBaseInfo.nodeType,rootBaseInfo.nodeName);
  }
  
  /* ---------------------------------------------
   * Determines what type of node to create when
   * Pasting a node from one tree to another
   */
  VDct1GetNodeTypeToCreateForCopy(parentID,copyID,&nodeTypeInfo);
  if(traceFlag) printf("nodeTypeInfo.type [%s]\n",nodeTypeInfo.type);
  
  // When pasting a node of a given 
  // Verify type is valid
#if 0
  vdct1$GetNodeTypeInfoByType(setType      = parentBaseInfo.setType,
			      nodeType     = copyBaseInfo.nodeType,
			      nodeTypeInfo = &nodeTypeInfo);
#endif

  if (*nodeTypeInfo.type == 0) goto wrapup;

  strcpy(copyBaseInfo.nodeType,nodeTypeInfo.type);

  //xxx
  if (traceFlag) printf("Got the nodeTypeInfo.type and it was ok!\n");
  
  strcpy(location,VDCT1_ACTION_PASTE_DUPS);
  sts1 = vdct1$CmdNodeRulesOK (parentNodeID = parentID,
			       baseInfo     = &copyBaseInfo,
			       location     = location);

  sts = 1;  // ok go ahead and make if the rules don't apply

  if (sts1 & 1) {
    // check the tree for duplicates NOTE: No messages!
    sts = vdct1$CmdCheckForDuplicate(nodeID   = parentID,
				     testID   = copyID,
				     baseInfo = &copyBaseInfo);
  }
  
  

  // start the creation of this node if he is not a duplicate
  if (sts & 1) {

    // Create the object
    vdct1$CreateNode(parentID = parentID,
		     nodeType = copyBaseInfo.nodeType,
		     nodeName = copyBaseInfo.nodeName,
		     nodeID   = &nodeID);

    if (nodeID.objid == NULL_OBJID) goto wrapup;
  
    // Transfer attributes
    vdct1$CopyNodeAttributes(desID = &nodeID, 
			     srcID = copyID);

    // get some attributes from the parentID
    vdct1$GetParentAttributes(parentID = parentID,
			      nodeID   = &nodeID);

    // Link model object
    vdct1$GetNodeModelObject(nodeID  = copyID,
			     modelOE = &modelOE);
  
    // rules to control the duplicate check
    sprintf(location,"%s",VDCT1_ACTION_PASTE_CONNECT);

    sts = vdct1$CmdNodeRulesOK(parentNodeID  = parentID,
			       baseInfo      = &copyBaseInfo,
			       location      = location);

    // do it if rules are absent etc.
    if (sts & 1) {
      // connect it up
      if (modelOE.obj_id.objid != NULL_OBJID) {    
	if(traceFlag)printf("It got connected up \n");
      
	vdct1$ConnectNodeToModelObject(nodeID  = &nodeID,
				       modelOE = &modelOE);
      }
    }
  
    // Save first one in rootID
    if ((rootID) && (rootID->objid == NULL_OBJID)) *rootID = nodeID;

  
  // Now do the kids

    for(i = 0; vdct1$GetTree1Child(objID = copyID, 
				   nth   = i, 
				   outID = &childID); i++) {

      VDct1NodeCopyNode(&nodeID,&childID,NULL);
   
    }
    }
  else { 
    // if a duplicate is found reset the notice control flag
    dupPasteFlag = 1;
  }
  
  
  
  // Done
  retFlag = 1;
  
wrapup:

 // say bye
  if (traceFlag) {
    printf("<<< VDct1NodeCopyNode %d\n",retFlag);
  }


  return retFlag;
}

/* -------------------------------------------
 * The Paste Node Button was pressed
 */
IGRstat VDct1CmdNodeNotifyPasteNode()
{
  IGRstat retFlag   = 0;
  IGRint  traceFlag = traceFlagx;
  IGRstat sts, sts1, sts2;
  
  IGRchar        location[128], buf[128];
  IGRint         i = 0;
  TGRid          parentID = parentNodeID;
  TGRid          clipBoardID[500];
  TGRid          copiedID;
  TGRid          copyparentID;
  TVDctBaseInfo  copiedBaseInfo;
  TVDctBaseInfo  copyparentBaseInfo;
  IGRint         clipBoardCount = 0;
  
  // say hi
  if (traceFlag) {
    printf(">>> VDct1CmdNodeNotifyPasteNode \n");
  }
  // init
  strcpy(location,"NULL");
  // set the dupPasteFlag off to prevent Notice of duplicates rejection
  // the value is reset in the VDct1NodeCopyNode operation if a duplicate is found
  dupPasteFlag = 0;
 
  // Can't do nothing without a parent
  if (parentID.objid == NULL_OBJID) goto wrapup;
  // need to get the array of nodes not the single node
  // Same for the copied
  sts1 = VDct1CmdLibGetCopiedNodes(clipBoardID);
  if (!sts1) goto wrapup;

  clipBoardCount = 0;
  // count the clipboard
  for(i = 0;i <= 500;i++) {
     copiedID = clipBoardID[i];
     if (copiedID.objid == NULL_OBJID) break;
     clipBoardCount++;
  }
  
  // ask if the user wants to paste these items
  sprintf(buf,"Paste ClipBoard? (%d items)",clipBoardCount);
  sts = GRconfirm_box(buf);
  if (!(sts & 1)) goto wrapup;

  for(i = 0;i <= clipBoardCount;i++)
  {
    copiedID = clipBoardID[i];
    // quit at the end of the clipBoard content
    if (copiedID.objid == NULL_OBJID) break;
    // initialize the check for paste on self or in self tree
    sts2 = 0;

    // do not allow pasting on self
    if (parentID.objid == copiedID.objid) goto wrapup;

    // For PalAssy, some rules need to apply for pasting.  
    // vdct1$CmdNodeRulesOK will cover this.  rules are in PPL.
    // Node Rules need baseinfo of copiedID
    vdct1$GetBaseInfo   ( objID = &copiedID, baseInfo = &copiedBaseInfo );
    vdct1$GetTree1Parent( objID = &copiedID, outID    = &copyparentID );
    vdct1$GetBaseInfo( objID = &copyparentID, baseInfo = &copyparentBaseInfo );

    // test if it is going under itself 
    sts2 = vdct1$FindChildUnderParentRev(nodeID   = &parentID,
					 baseInfo = &copiedBaseInfo,
					 copiedNodeID = &copiedID);  
    // apply 2 rules here!
    strcpy(location,VDCT1_ACTION_PASTE_NODE);
    sts1 = vdct1$CmdNodeRulesOK (parentNodeID = &parentID,
				 baseInfo = &copiedBaseInfo,
				 location = location);
    //printf("sts1 = [%d]  ",sts1);
    
    strcpy(location,VDCT1_ACTION_PASTE_NPARENT);
    sts = vdct1$CmdNodeRulesOK (parentNodeID = &parentID,
				baseInfo = &copyparentBaseInfo,
				location = location);
    //printf("sts = [%d] \n",sts);
    
 
    if (sts && sts1 && !sts2) {
    
      // Do a recursive copy
      pastedNodeID.objid = NULL_OBJID;

      printf("Calling the nodecopy routine ***** \n");
      
      VDct1NodeCopyNode(&parentID,&copiedID,&pastedNodeID);

      // Tell everyone created 
      if (pastedNodeID.objid != NULL_OBJID) {
	
	VDct1CmdMgrCreatedNode(&pastedNodeID);

	// update the pasted node tree attribute sums
	vdct1$GetTree1Parent( objID = &pastedNodeID, outID = &copyparentID ); 
	vdct1$SummaryNode (parentID = &copyparentID);

	// update the summary
	VDct1FormUpdateVRTree(cmdInfo->tree.form, VDCT_FORM_TREE_G_TREE);
	VDct1FormUpdateVRTree(cmdInfo->lib.form, VDCT_FORM_LIB_G_TREE);
      }
    }
  }
   // Done
  retFlag = 1;
wrapup:

 // say bye
  if (traceFlag) {
    printf("<<< VDct1CmdNodeNotifyPasteNode %d\n",retFlag);
  }
  sprintf(buf,"Duplicate Nodes Not Pasted");
  
  if (dupPasteFlag) sts = VDnotify_box(buf);
  
  
  return retFlag;
}

/* -------------------------------------------
 * The Delete Node Button Was Pushed
 */
IGRstat VDct1CmdNodeNotifyDeleteNode()
{
  IGRstat retFlag   = 0;
  IGRint  traceFlag = traceFlagx;
  
  TGRid  parentID; 

  IGRchar buf[80];
  IGRchar msg[80];
  IGRstat sts = 0;
  IGRchar blank[128] = "";
  IGRchar location[128];
  

  Form    form  = cmdInfo->node.form;
  //Form    form1 = cmdInfo->part.form;
  
  traceFlag = 0;
  
  // say hi
  if (traceFlag) {
    printf(">>> VDct1CmdNodeNotifyDeleteNode \n");
  }

  // Delete active node, don't delete top node
  vdct1$GetTree1Parent(objID = &activeNodeID,
		       outID = &parentID);

  // if activeNode on form is blank 
  vdfrm$GetText(form   = form,
		gadget = VDCT_FORM_NODE_G_ACTIVE_NODE,
		txt    = msg);
 
  if(!strcmp(msg,blank)){
    sprintf(buf,"Active Node is Blank\n\nSelect an Active Node\n\nFrom the Tree form\n\n");
    sts = VDnotify_box(buf);
    goto wrapup;
  }

  // check the rules
  sprintf(location,"%s",VDCT1_ACTION_DELETE_NODE);
  sts = vdct1$CmdNodeRulesOK(parentNodeID  = &activeNodeID,
			     location      = location);
  if (!sts){
    sprintf(buf,"Deletion of this Item\n\nIs Not Permitted Here\n\n");
    sts = VDnotify_box(buf);
    goto wrapup; 
  }
  

   // prevent the top node from changing and send notice 
  if (parentID.objid == NULL_OBJID) {
    sprintf(buf,"Cannot Delete \n\nTop Node Here");
    sts = VDnotify_box(buf);
    goto wrapup;
  }

 // start the message for Deletion Box
  strcpy(buf,"Delete? : ");

  // get the active tree data
  vdfrm$GetText(form = form, gadget = VDCT_FORM_NODE_G_ACTIVE_NODE, txt = msg);
  strcat(buf,msg);

  // Confirm if Deletion is to be done if no goto wrapup
  if( GRconfirm_box(buf) != TRUE )goto wrapup;

  // Delete the copied nodes from the original tree
  vdct1$DeleteNode(nodeID = &activeNodeID);


  // Clear up the Node form Msg box
  sprintf(buf,"Deleted Node: %s",msg);
  vdfrm$SetStatus(form   = form,
		  txt    = buf);
  // Clear up the Active Node  on the form
  sprintf(buf,"");
  vdfrm$SetStatus(form   = form,
		  gadget = VDCT_FORM_NODE_G_ACTIVE_NODE,
		  txt    = buf);

  // Clear up the Parent Node on the form 
  sprintf(buf,"");
  vdfrm$SetStatus(form   = form,
		  gadget = VDCT_FORM_NODE_G_PARENT_NODE,
		  txt    = buf);

  // vdfrm$SetStatus(form   = form1,
  // gadget = VDCT_FORM_PART_T_PARENT,
  // txt    = buf);

  // Tell the world
  VDct1CmdMgrDeletedNode(&activeNodeID,&parentID);
  
  // recalculate the parentID (node) etc.
  // summary of node totals up tree
  vdct1$SummaryNode (parentID = &parentID);

  // update the summary
  VDct1FormUpdateVRTree(cmdInfo->tree.form, VDCT_FORM_TREE_G_TREE);
  VDct1FormUpdateVRTree(cmdInfo->lib.form, VDCT_FORM_LIB_G_TREE);
  // Done
  retFlag = 1;
  
wrapup:

  // say bye
  if (traceFlag) {
    printf("<<< VDct1CmdNodeNotifyDeleteNode %d\n",retFlag);
  }

  return retFlag;
}

/* -------------------------------------------
 * The Rename Node Button Was Pushed
 */
IGRstat VDct1CmdNodeNotifyRenameNode()
{
  IGRstat retFlag = 0;
  IGRint  traceFlag = traceFlagx;
  IGRchar newName[256];
  
  Form form     = cmdInfo->node.form;
  IGRint gadget = VDCT_FORM_NODE_G_EDIT_NODE_NAME;  // gadget #18 tells the new name
  
  TVDctBaseInfo activeBaseInfo;
  
  TGRid    nodeID;
  TGRid    treeID;
  TVDfld   fld;
  IGRchar  buf[128];
  IGRchar  location[128];
  IGRchar  msg[128];
  IGRchar  blank[128];
  IGRstat  sts     = 0;
  IGRint   desFlag = 1;
  traceFlag = 0;

  *blank = 0;
  
  // say hi
  if (traceFlag){
    printf(">>> VDct1CmdNodeNotifyRenameNode \n");
  }

  // if activeNode on form is blank 
  vdfrm$GetText(form   = form,
		gadget = VDCT_FORM_NODE_G_ACTIVE_NODE,
		txt    = msg);
 
  if(!strcmp(msg,blank)){
    sprintf(buf,"Active Node is Blank\n\nSelect an Active Node\n\nFrom the Tree form\n\n");
    sts = VDnotify_box(buf);
    goto wrapup;
  }

  // pull the new node name from the "Node" form 
  vdfrm$GetText  (form = form, gadget = gadget, txt = newName);
  VDstrupr(newName);

  // if name is not a valid name to make
  sts = vdct1$IsFirstLetterOK(test = newName);
  
  if (!sts) {
    sprintf(buf,"New Node Name Invalid\n\nRename Not Done\n\n");
    sts = VDnotify_box(buf);   
    goto wrapup;
  }  
  // Pull the active node
  vdct1$GetBaseInfo(objID = &activeNodeID, baseInfo = &activeBaseInfo);
  if (*activeBaseInfo.nodeType == 0) goto wrapup;  

  // test to see if node is top node
  vdct1$GetTreeForNode(nodeID = &activeNodeID, 
		       treeID = &treeID);         

  // prevent the top node from changing and send notice 
  if (activeNodeID.objid == treeID.objid) {
    sprintf(buf,"Cannot Rename Top Node");
    vdfrm$SetStatus(form   = form,
		    txt    = buf);
    sts = VDnotify_box(buf);
    goto wrapup;
  }

  // check the rules
  sprintf(location,"%s",VDCT1_ACTION_R_NODE_DUP);
  sts = vdct1$CmdNodeRulesOK(parentNodeID  = &parentNodeID,
			     baseInfo      = &activeBaseInfo,
			     location      = location);

  if (!sts) {
    
  // compare the names if same do nothing  
  if(!strcmp(activeBaseInfo.nodeName,newName)) {
    sprintf(buf,"%s %s ,Name in use\n\nNot Renamed",activeBaseInfo.nodeType,activeBaseInfo.nodeName);
    sts = VDnotify_box(buf );  
    sprintf(buf,"Node Not Renamed");                                                
    vdfrm$SetStatus(form   = form,
		    txt    = buf);  
    goto wrapup;
  }
  
  }
  
  //  load up the data for the check
  strcpy(activeBaseInfo.nodeName,newName);
  
  // check the rules
  sprintf(location,"%s",VDCT1_ACTION_RENAME_NODE);
  sts = vdct1$CmdNodeRulesOK(parentNodeID  = &activeNodeID,
			     baseInfo      = &activeBaseInfo,
			     location      = location);

  if (!sts) {
    sprintf(buf,"Rules do not Permit\n\nRenaming this Node\n\n");
    sts = VDnotify_box(buf);
    sprintf(buf,"Node Not Renamed");                                                
    vdfrm$SetStatus(form   = form,
		    txt    = buf);
    goto wrapup;
  }
  
  
   /* check for duplicates like if you were making a new node and prohibit them 
    * Load up to do the check for duplicates
    */
  strcpy(fld.name, VDCT_NODE_NAME);
  strcpy(fld.val.txt,activeBaseInfo.nodeName);
  
  fld.type = VDFLD_TYPE_TXT;   
  //Send the data off to be tested to for duplicates
    vdct1$SearchForNodeInTree(a_treeID      = &treeID,
			      a_nodeType    = activeBaseInfo.nodeType,
			      a_fld         = &fld,
			      a_descendFlag = desFlag,
			      a_nodeID      = &nodeID);
    // if duplicate go to wrapup
    if (nodeID.objid != NULL_OBJID){
      vdfrm$SetStatus(form = form, txt = "Node name exists, choose another name");
 
      // notify of duplicate rejection
      sprintf(buf,"%s %s \n\nName in use\n\nNot Renamed",activeBaseInfo.nodeType,activeBaseInfo.nodeName);
      sts = VDnotify_box(buf);    
      goto wrapup;
    }
  
 
  // Confirm if Rename is to be done if no goto wrapup
  sprintf(buf,"%s %s Rename to this?",activeBaseInfo.nodeType,activeBaseInfo.nodeName);
  if( GRconfirm_box(buf) != TRUE )goto wrapup;
 
  // Reset Objects name
  vdct1$SetBaseInfo(objID = &activeNodeID, baseInfo = &activeBaseInfo);

  // Clear up the Node form Msg box
  sprintf(buf,"Renamed Node: %s %s",activeBaseInfo.nodeType,activeBaseInfo.nodeName);
  vdfrm$SetStatus(form   = form,
		  txt    = buf);
  // Clear up the Active Node  on the form
  sprintf(buf,"%s %s",activeBaseInfo.nodeType,activeBaseInfo.nodeName);
  vdfrm$SetStatus(form   = form,
		  gadget = VDCT_FORM_NODE_G_ACTIVE_NODE,
		  txt    = buf);

  // Need to tell the world (which activates the node and updates the forms)
   VDct1CmdMgrRenamedNode(&activeNodeID);
  
  // Done
  retFlag = 1;

wrapup:
  // say bye
  if (traceFlag){
    printf("<<< VDct1CmdNodeNotifyRenameNode %d\n",retFlag);
  }
  return retFlag;
  
}


/* -------------------------------------------
 * The Create Node Button Was Pushed
 */

IGRstat VDct1CmdNodeNotifyCreateNode()
{
  VDASSERT_FN("VDct1CmdNodeNotifyCreateNode");
  
  
  IGRstat retFlag = 0;
  IGRstat sts = 0;
  //  IGRint  traceFlag = 0;
  
  Form form = cmdInfo->node.form;
  
  TVDctBaseInfo baseInfo, parentBaseInfo, baseInfox;

  IGRchar msg1[128];
  IGRchar msg2[128];  

  TVDctNodeType a_NodeType;
  TGRid   a_treeID;
  TVDfld  a_fld;
  TGRid   nodeID, parentNodeIDx;
  IGRchar buf[128];
  IGRchar buff1[128], buff2[128];
  IGRint  desFlag = 1;
  IGRchar blank[128] = "";
  IGRchar msg[128];
  IGRchar location[128], nodeName[128], nodeType[128];
  
  TVDct1JD parentNodeJD;
  
  // say hi
  if (traceFlag){
    printf(">>> VDct1CmdNodeNotifyCreateNode \n");
  }
  // Pull the node type 
  vdfrm$GetText(form   = form,
		gadget = VDCT_FORM_NODE_G_PARENT_NODE,
		txt    = buff1);
  if (!strcmp(buff1,"")) {
    sprintf(msg,
	    "No Parent Node Selected\n\nSelect Parent Node in Tree form\n\n"
	    "Then Select [Parent] Button\n\n On Node Form\n\n");
    sts = VDnotify_box(msg);   
    goto wrapup;    
  }
  
  // Pull the node type 
  vdfrm$GetText(form   = form,
		gadget = VDCT_FORM_NODE_G_EDIT_NODE_TYPE,
		txt    = baseInfo.nodeType);

  // Pull the node name
  vdfrm$GetText(form   = form,
		gadget = VDCT_FORM_NODE_G_EDIT_NODE_NAME,
		txt    = baseInfo.nodeName);

  VDstrupr(baseInfo.nodeType);
  VDstrupr(baseInfo.nodeName);

  // generate any new names here 
  //keep it clean!
  parentNodeIDx = parentNodeID;
  vdct1$GetBaseInfo(objID    = &parentNodeIDx, 
		    baseInfo = &baseInfox);
  strcpy(baseInfox.nodeType,baseInfo.nodeType);
  strcpy(baseInfox.nodeName,baseInfo.nodeName);

  // look it up
  sts = vdct1$MakeNodeName(parentID = &parentNodeIDx,
			   baseInfo = &baseInfox);

  // copy it back
  if (sts & 1) strcpy(baseInfo.nodeName, baseInfox.nodeName);
  
  strcpy(buf,baseInfo.nodeName);
  
  // reset the form
  vdfrm$SetStatus(form   = form, 
		  gadget = VDCT_FORM_NODE_G_EDIT_NODE_NAME,
		  txt    = buf);
# if 0
    // if name is not a valid name to make
    sts = vdct1$IsFirstLetterOK(test = baseInfo.nodeName);
  
    if (!sts) {
      sprintf(msg,"Node Name Invalid\n\nNew Node Not Made\n\n");
      sts = VDnotify_box(msg);   
      goto wrapup;
    }  
# endif
  
    // Validate node name, tree interface
    parentNodeJD.id = parentNodeID;
    parentNodeJD.cl = VDct1GetTreeClassForNode(&parentNodeID);
    VDASSERTW(parentNodeJD.cl);
    printf("have parentNodeJD.cl, calling isNodeNameValid...\n");
    
    sts = _RTCJDB(&parentNodeJD)->
      isNodeNameValid(&parentNodeJD,baseInfo.nodeType,baseInfo.nodeName,msg);
    if (!(sts & 1)) {
      sts = VDnotify_box(msg);   
      goto wrapup;
    }

    // validate the node for creation
    sts = vdct1$IsChildTypeValid(parentID  = &parentNodeID,
				 childType = baseInfo.nodeType);
    if (!(sts & 1)) {
   
      // get the parentNodeID baseinfo
      vdct1$GetBaseInfo(objID = &parentNodeID, baseInfo = &parentBaseInfo);
      strcpy(buff1,parentBaseInfo.nodeType);
      strcpy(buff2,baseInfo.nodeType);
      sprintf(buf,"Invalid node type selection");

      if(!(strcmp(buff2,blank))) {
	strcpy(buff2,"is Blank");
	sprintf(buf,"Child Node is Blank - Select Child Type");
      }

      if(!(strcmp(buff1,blank))) {
	strcpy(buff1,"is Blank");
	sprintf(buf,"Parent Node is Blank - Select Parent Node");
      }
    
      // tell the form
      vdfrm$SetStatus(form = form, txt = buf);  
      sprintf(buf,"Parent: %s\n\nNode Type : %s\n\nInvalid Node Type Selection\n\n",buff1,buff2);
      sts = VDnotify_box(buf);
   
      goto wrapup;
    }
    sprintf(msg1,"Node exists: choose another name");
    sprintf(msg2,"\n\nNode Already Exists\n\nNode Not Added\n\n");   
    // Test for Duplicates and reject them 
 
  // rules to control the duplicate check
  sprintf(location,"%s",VDCT1_ACTION_C_NODE_DUP);
  if(traceFlag) printf("Location test a\n");
  
  sts = vdct1$CmdNodeRulesOK(parentNodeID  = &parentNodeID,
			     baseInfo      = &baseInfo,
			     location      = location);
 
  if (sts) { 
   if(traceFlag) printf("Location test b\n");
  
    sts = vdct1$CmdCheckForDuplicate(nodeID   = &parentNodeID,
				     baseInfo = &baseInfo,
				     msg1     = msg1,
				     msg2     = msg2);
    if (!(sts & 1)) goto wrapup;   
  }

  sts = vdct1$IsPartInOPS(nodeID   = &parentNodeID,
			  baseInfo = &baseInfo);
  if(!(sts & 1)) {
    strcpy(buf,"Part Name Invalid\n\nPart Not in OPS\n");
    sts = VDnotify_box(buf); 
    goto wrapup;
  }
  


    if(traceFlag) printf("Location test c\n");
  
  /* ------------------------------------------------
   * Actual creation is done by the ppl so let it do 
   * the validation
   */
  if(traceFlag) printf("Location test 1\n");
  
  vdct1$CreateNode(parentID = &parentNodeID,
		   nodeType = baseInfo.nodeType,
		   nodeName = baseInfo.nodeName,
		   nodeID   = &nodeID);
  if(traceFlag) printf("Location test 2\n");
  if (nodeID.objid == NULL_OBJID) {
     sprintf(buf,"Node Creation Failed For '%s', '%s'",
	     baseInfo.nodeType,
	     baseInfo.nodeName);
 
    vdfrm$SetStatus(form = form, txt = buf);
    goto wrapup;
  }
    if(traceFlag) printf("Location test 3\n");
  // Need to tell the world (which activates the node and updates the forms)
  VDct1CmdMgrCreatedNode(&nodeID);
    if(traceFlag) printf("Location test 4\n");
    // update the summary
  VDct1FormUpdateVRTree(cmdInfo->tree.form, VDCT_FORM_TREE_G_TREE);
  VDct1FormUpdateVRTree(cmdInfo->lib.form, VDCT_FORM_LIB_G_TREE);
    if(traceFlag) printf("Location test 5\n");
  // Done
  retFlag = 1;
  
wrapup:

  // say bye
  if (traceFlag){
    printf("<<< VDct1CmdNodeNotifyCreateNode %d\n",retFlag);
  }
  
  return retFlag;
}

/* -------------------------------------------------
 * Converter for TYPE and NAME of a node
 * made generic so that many options for use exist
 * the node must exist before this operation happens
 * It relies on the Active Node content and renames the 
 * Node and gives it a new type
 * It then updates the tree display
 */
IGRstat VDct1CmdNodeConvertTypeAndName()
{
  IGRint          retFlag   = 0;
  IGRint          traceFlag = 0;
  IGRint          sts;
  TGRid           nodeID, newNodeID, parentID;
  TVDctBaseInfo   baseInfo, baseInfox;
  IGRchar         location[128], buf[128], nodeName[128], nodeType[128];
  Form            form      = cmdInfo->node.form;

  // say hi
  if (traceFlag) printf(">>>VDct1CmdNodeConvertTypeAndName()\n");

  // args check
  if(activeNodeID.objid == NULL_OBJID) {
    if (traceFlag) printf("failed activeNode\n");
    goto wrapup;
  }
  
  // set the nodeID
  nodeID = activeNodeID;

  // get the baseInfo
  vdct1$GetBaseInfo(objID = &activeNodeID, baseInfo = &baseInfo);  
  if (*baseInfo.nodeType == 0) {
    if (traceFlag) printf("failed nodeID baseInfo\n");
    goto wrapup;
  }

  // Put the node type and name to uppercase
  VDstrupr(baseInfo.nodeType);
  VDstrupr(baseInfo.nodeName);

  // save the old baseInfo stuff
  strcpy(nodeType,baseInfo.nodeType);
  strcpy(nodeName,baseInfo.nodeName);

  sprintf(location,"%s",VDCT1_ACTION_CONVERT);

  sts = vdct1$CmdNodeRulesOK(parentNodeID  = &activeNodeID,
			     baseInfo      = &baseInfo,
			     location      = location);
  if(!(sts & 1)) {
    if(traceFlag) printf("Rules prevented action\n");
    goto wrapup;
  }
  
  if(traceFlag) printf("baseInfo1 [%s] [%s]\n",nodeType,nodeName);
  
  
  // set the location for the PPL
  strcpy(location,VDCT1_ACTION_CHANGE_NT);

  // send the data off to create a type and name
  vdct1$TreeMakeAName(activeNodeID   = &activeNodeID,
		      baseInfo       = &baseInfo,
		      location       = location);

  // Put the node type and name to uppercase
  VDstrupr(baseInfo.nodeType);
  VDstrupr(baseInfo.nodeName);

  //compare the old and new baseInfo stuff
  if ((!strcmp(baseInfo.nodeType,nodeType)) &&
      (!strcmp(baseInfo.nodeName,nodeName))) goto wrapup;
  // get the parentID
  vdct1$GetTree1Parent(objID = &activeNodeID, outID = &parentID);
 if(traceFlag) printf("baseInfo2 [%s] [%s]\n",nodeType,nodeName);
  
  // go make a new node Identical to the old one  
  vdct1$CreateNode(parentID = &parentID,
		   nodeType = nodeType,
		   nodeName = nodeName,
		   nodeID   = &newNodeID);

  // get the baseInfo
  vdct1$GetBaseInfo(objID = &newNodeID, baseInfo = &baseInfox); 
  if(traceFlag) printf("baseInfox [%s]\n",baseInfox.baseName);
  

  // Call the wrapper to set up the attributes
  vdct1$SetNodeDeleted (parentID = &nodeID,
			nodeID   = &newNodeID);

  vdct1$SetBaseInfo(objID = &activeNodeID, baseInfo = &baseInfo);
  
  // Need to tell the world (which activates the node and updates the forms)
  //VDct1CmdMgrRenamedNode(&parentID);

    // update the summary
  VDct1FormUpdateVRTree(cmdInfo->tree.form, VDCT_FORM_TREE_G_TREE);
  VDct1FormUpdateVRTree(cmdInfo->lib.form, VDCT_FORM_LIB_G_TREE);
  VDct1CmdMgrCreatedNode(&newNodeID);
  VDct1CmdMgrActivateNode(&nodeID);

  // put the notice of what happened on the form
  sprintf(buf,"Converted: %s %s",nodeType,nodeName);
  vdfrm$SetText(form = form,
		gadget = 10,
		txt = buf);

  // success
  retFlag = 1;

  // oh well
wrapup:
  // say bye
  if (traceFlag) printf("<<< VDct1CmdNodeConvertTypeAndName(%d)\n",retFlag);
  return retFlag;
  
}

/* -------------------------------------------------
 * Doit processor
 */
IGRstat VDct1CmdNodeNotifyDoit()
{  
  IGRstat retFlag;
  IGRint  traceFlag = traceFlagx;
  
  IGRchar cmd;
  IGRchar buf[128];
 
  
    // say hi
  if (traceFlag){
    printf(">>> VDct1CmdNodeNotifyDoit \n");
  }

  
  // Get the command string
  vdfrm$GetText(form   = cmdInfo->node.form,
		gadget = VDCT_FORM_NODE_G_DOIT,
		txt    = buf);

  if(traceFlag) printf("buf was [%s]\n",buf);
  
  cmd = *buf;
     if(traceFlag) printf("selection was [%c]\n",cmd);
  // Switch it
  switch(cmd) {
  case '2':
    VDct1CmdNodeNotifyCreateNode();
    break;

  case '3':
    // VDct1CmdNodeNotifyCreateModelNode(); Actually a switch
    break;

  case '4':
    // Under Construction Notice
    VDct1CmdNodeConstruction();
    break;
    
  case '5':
    // Under Construction Notice
    //VDct1CmdNodeConstruction();
    break;
    
  case '6':
    break;

    //case '7': 
    // Under Construction Notice
    //VDct1CmdNodeConstruction();
    //break;

    //case '8': 
    // break;

  case 'C':
    VDct1CmdNodeConvertTypeAndName();
    break;

  case 'D':
    VDct1CmdNodeNotifyDeleteNode();
    break;

  case 'R':
    VDct1CmdNodeNotifyRenameNode();
    break;
    
  case 'P':
    // Under Construction Notice
    //VDct1CmdNodeConstruction();
    VDct1CmdNodeNotifyPasteNode();
    break;

  case 'Q':
    VDct1CmdNodeQuery();
    //VDct1CmdNodeQuery();
    break;
  

  case 'M':
    // Under Construction Notice
    VDct1CmdNodeConstruction();
    //VDct1CmdNodeNotifyMoveNode();
    break;

  case 'X':
    // Under Construction Notice
    VDct1CmdNodeConstruction();
    //VDct1CmdNodeNotifyBOMNode();
    break;

  }
  
  retFlag = 1;
  
//wrapup:      

  // say bye
  if (traceFlag){
    printf("<<< VDct1CmdNodeNotifyDoit %d\n",retFlag);
  }

  return retFlag;
}

/* -------------------------------------------
 * The Parent Node Button was pushed
 */
IGRstat VDct1CmdNodeNotifyParentNode()
{
  IGRstat retFlag = 0;
  IGRstat traceFlag = traceFlagx;
  IGRstat sts;
  
  Form   form    = cmdInfo->node.form;
  IGRint gadget  = VDCT_FORM_NODE_G_PARENT_NODE;
  TVDctBaseInfo parentNodeBaseInfo;

  IGRchar buf[80];
  IGRint  i;
  IGRint  row;
  
  TVDctNodeTypeInfo nodeTypeInfo;
  
  // say hi
  if (traceFlag) {
    printf(">>> VDct1CmdNodeNotifyParentNode \n");
  }
  
  // Make it the parent
  parentNodeID = activeNodeID;

  vdct1$GetBaseInfo(objID    = &parentNodeID, 
		    baseInfo = &parentNodeBaseInfo);
  
  vdfrm$SetText(form   = form, 
		gadget = gadget,
		txt    = parentNodeBaseInfo.baseName);

  // Make sure have an object
  if (*parentNodeBaseInfo.nodeType == 0) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Update the node type list
  gadget = VDCT_FORM_NODE_G_EDIT_NODE_TYPE;
  vdfrm$SetListNumRows(form = form, gadget = gadget, rows = 0);
  vdfrm$SetText       (form = form, gadget = gadget, txt = "");
  row = 0;
  for(i = 0; 
      vdct1$GetNodeTypeInfo(setType = parentNodeBaseInfo.setType,
			    nodeInd = i,
			    nodeTypeInfo = &nodeTypeInfo);
      i++){
    
    // Is it a valid child type?
    sts = vdct1$IsChildTypeValid(parentID = &parentNodeID,
				 childType = nodeTypeInfo.type);
    if (sts & 1) {

      // Make first one the default
      if (row == 0)  {
	vdfrm$SetText(form   = form, 
		      gadget = gadget,
		      txt    = nodeTypeInfo.type);

      }
      // Add it to pull down list
      sprintf(buf,"%-8s %s",nodeTypeInfo.type,nodeTypeInfo.desc);
      vdfrm$SetListText(form   = form, 
			gadget = gadget,
			txt    = buf,
			row    = row);
      row++;
    }
  }
  
  //Reset pick list
  VDct1CmdResetGadgetList(&parentNodeID,form,VDCT_FORM_NODE_G_DOIT,1);

  // Done
  retFlag = 1;
  
wrapup:  

  // say bye
  if (traceFlag) {
    printf(">>> VDct1CmdNodeNotifyParentNode %d\n",retFlag);
  }

  return retFlag;
}

/* -------------------------------------------
 * A node type was selected
 */
IGRstat VDct1CmdNodeNotifyNodeType()
{
  IGRstat retFlag = 0;
  IGRint  traceFlag = traceFlagx;

  Form    form   = cmdInfo->node.form;
  IGRint  gadget = VDCT_FORM_NODE_G_EDIT_NODE_TYPE;
  
  IGRchar buf[128],*p;

  // say hi
  if (traceFlag) {
    printf(">>> VDct1CmdNodeNotifyNodeType \n");
  }
  // Read it
  vdfrm$GetText  (form = form, gadget = gadget, txt = buf);
  vdfrm$SetStatus(form = form, txt = "");
  
  // Break type and desc
  p = strchr(buf,' ');
  if (p == NULL) goto wrapup;
  *p = 0;
  vdfrm$SetText(form = form, gadget = gadget, txt = buf);
  
  // Parse and move
  for(p++; (*p == ' '); p++);
  if (*p) {
    vdfrm$SetStatus(form = form, txt = p);
  }
  
wrapup:
  // say bye
  if (traceFlag) {
    printf("<<<  VDct1CmdNodeNotifyNodeType %d\n",retFlag);
  }
  return retFlag;
}

/* -------------------------------------------
 * Node was deleted  
 */
#argsused
IGRstat VDct1CmdNodeDeletedNode(TGRid *nodeID, TGRid *parentID)
{
  IGRstat retFlag = 0;
  IGRint  traceFlag = traceFlagx;

  Form form = cmdInfo->node.form;
  // Form form1 = cmdInfo->part.form;
  
  // say hi
  if (traceFlag) {
    printf(">>> VDct1CmdNodeDeletedNode \n");  
  }
  
  // Its possible the parent was deleted
  if ((parentNodeID.objid == nodeID->objid) && 
      (parentNodeID.osnum == nodeID->osnum)) {

    parentNodeID.objid = NULL_OBJID;  
    vdfrm$SetText(form   = form,
		  gadget = VDCT_FORM_NODE_G_PARENT_NODE,
		  txt    = "");

    // vdfrm$SetText(form   = form1,
    //  gadget = VDCT_FORM_PART_T_PARENT,
    //  txt    = ""); 
  }
  
  // Done
  retFlag = 1;
  
wrapup:

  // say bye
  if (traceFlag) {
    printf("<<< VDct1CmdNodeDeletedNode %d\n",retFlag);  
  }  

  return retFlag;
}
/* -------------------------------------------
 * Node was created
 */
IGRstat VDct1CmdNodeCreatedNode(TGRid *nodeID)
{
  IGRstat retFlag = 0;
  IGRint  traceFlag = traceFlagx;
  Form form = cmdInfo->node.form;
   
  IGRchar  buf[128];
  
  TVDctBaseInfo baseInfo;

  vdct1$GetBaseInfo(objID = nodeID, baseInfo = &baseInfo);
 
  // say hi
  if (traceFlag) {
    printf(">>> VDct1CmdNodeCreatedNode \n");
  }
 
  // Update status
  sprintf(buf,"Created Node '%s'",baseInfo.baseName);
  vdfrm$SetStatus(form = form, txt = buf);
  
  // Done
  retFlag = 1;
  
wrapup:

  // say bye
  if (traceFlag) {
    printf("<<< VDct1CmdNodeCreatedNode %d\n",retFlag);
  }

  return retFlag;
}

/* -------------------------------------------
 * Node was activated
 */
IGRstat VDct1CmdNodeActivateNode(TGRid *nodeID)
{
  IGRstat retFlag = 0;
  IGRint  traceFlag = traceFlagx;

  Form    form = cmdInfo->node.form;
  IGRint  state;
  
  TVDctBaseInfo     baseInfo;
  TVDctNodeTypeInfo nodeTypeInfo;
  
  IGRint  i,row;  
  IGRchar buf[128];
  
  // say hi
  if (traceFlag) {
    printf(">>> VDct1CmdNodeActivateNode \n");
  }
   
  
  // Arg Check
  if (nodeID == NULL) goto wrapup;
  
  // Make it active
  activeNodeID = *nodeID;

  // Fill In work information
  vdct1$GetBaseInfo(objID = nodeID, baseInfo = &baseInfo);
  
  vdfrm$SetText(form   = form,
		gadget = VDCT_FORM_NODE_G_EDIT_NODE_TYPE,
		txt    = baseInfo.nodeType);

  vdfrm$SetText(form   = form,
		gadget = VDCT_FORM_NODE_G_EDIT_NODE_NAME,
		txt    = baseInfo.nodeName);

  // Fiil in pick list for node type
  row = 0;
  vdfrm$SetListNumRows(form = form, gadget = VDCT_FORM_NODE_G_EDIT_NODE_TYPE, rows = 0);
  for(i = 0;
      vdct1$GetNodeTypeInfo(setType      = baseInfo.setType,
			    nodeInd      = i,
			    nodeTypeInfo = &nodeTypeInfo);
      i++) {
    
    if (*nodeTypeInfo.level == 'U') {
      sprintf(buf,"%-8s %s",nodeTypeInfo.type,nodeTypeInfo.desc);
      
      vdfrm$SetListText(form   = form,
			gadget = VDCT_FORM_NODE_G_EDIT_NODE_TYPE,
			row    = row,
			txt    = buf);
      row++;
    }
  }

  // Make it active based on toggle
  vdfrm$GetState(form   = form,
		 gadget = VDCT_FORM_NODE_T_ACTIVE_NODE,
		 state  = &state);

  if (state == 0) {
    activeNodeID = *nodeID;
    vdfrm$SetText(form   = form,
		  gadget = VDCT_FORM_NODE_G_ACTIVE_NODE,
		  txt    = baseInfo.baseName);
  }
  
  //Reset pick list
  
  //  VDct1CmdResetGadgetList(nodeID,form,VDCT_FORM_NODE_G_DOIT,1);

  // Done
  retFlag = 1;
  
wrapup:

  // say bye
  if (traceFlag) {
    printf("<<< VDct1CmdNodeActivateNode %d\n",retFlag);
  }
   
  return retFlag;
}
/* -------------------------------------------
 * The notification routine
 */
IGRstat VDct1CmdNodeNotifyForm()
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRint  traceFlag = traceFlagx;
  
  // say hi
  if (traceFlag){
    printf(">>> VDct1CmdNodeNotifyForm \n");
  }

  // Process it
  switch(cmdInfo->gadget) {

  case VDCT_FORM_NODE_G_EDIT_NODE_TYPE:
    VDct1CmdNodeNotifyNodeType();
    break;

  case VDCT_FORM_NODE_B_PARENT_NODE:
    VDct1CmdNodeNotifyParentNode();
    break;

  case FI_EXECUTE:
    sts = VDct1CmdNodeNotifyDoit();
    break;
    
  case FI_ACCEPT:
    sts = VDct1CmdNodeNotifyDoit();
    if (sts & 1) {
      vdfrm$EraseForm(form =  cmdInfo->node.form, 
		      flag = &cmdInfo->node.displayed);
    }
    
    break;
    
  case FI_CANCEL:
    vdfrm$EraseForm(form =  cmdInfo->node.form, 
                    flag = &cmdInfo->node.displayed);
    break;
  }
  retFlag = 1;

//wrapup:
  
  if (traceFlag) printf("<<< VDct1CmdNodeNotifyForm %d\n",retFlag);
  return retFlag;
}

/* --------------------------------------
 * Called when user pushes an open button
 */
IGRstat VDct1CmdNodeActivateForm()
{
  IGRstat retFlag = 0;
  IGRint  traceFlag = traceFlagx;

  // Ignore if already active for now
  if (cmdInfo->node.displayed) {
    retFlag = 1;
    goto wrapup;
  }

  // say hi
  if (traceFlag){
    printf(">>> VDct1CmdNodeActivateForm\n");
  }
  

  // Display
  // sleep(5);
  vdfrm$DisplayForm(form =  cmdInfo->node.form, 
                    flag = &cmdInfo->node.displayed);

  
  // Done
  retFlag = 1;

wrapup:

  // say bye
  if (traceFlag) {
    printf("<<< VDct1CmdNodeActivateForm %d\n",retFlag);
  }
  
  return retFlag;
}

/* --------------------------------------------------------
 * Called on startup
 */
IGRstat VDct1CmdNodeInit(TVDct1CmdInfo *a_cmdInfo)
{
  IGRstat retFlag = 0;
  IGRint  traceFlag = traceFlagx;

  // say hi
  traceFlag = 0;
  if (traceFlag) printf(">>> VDct1CmdNodeInit\n");

  cmdInfo = a_cmdInfo;

  parentNodeID.objid = NULL_OBJID;
  activeNodeID.objid = NULL_OBJID;
  
  retFlag = 1;

  // say bye
  if (traceFlag){
    printf("<<< VDct1CmdNodeInit %d\n",retFlag);
  }
  
  return retFlag;
}

/* -----------------------------------------------------------------
 * Duplicate Detector
 */
IGRstat VDct1CmdCheckForDuplicate(TGRid          *parentNodeID,
				  TGRid          *testID,
				  TVDctBaseInfo  *baseInfo,
				  IGRchar        *msg1,
				  IGRchar        *msg2)
{
  IGRstat retFlag = 0;
  IGRint  traceFlag = 0;

  Form          form = cmdInfo->node.form;
  TGRid         nodeID;
  TGRid         treeID,a_testID;
  TVDfld        fld;  


  IGRchar       buf[256];
  IGRint        sts       = 0;
  IGRint        desFlag   = 1;
  IGRint        dupSwitch = 1;
  

  // say hi
  if (traceFlag) printf(">>> VDct1CheckForDuplicate \n");
  
  // arg check
  if (parentNodeID == NULL) goto wrapup;
  if (baseInfo     == NULL) goto wrapup;

  nodeID.objid = NULL_OBJID;
  
// Load up to do the check for duplicates
  vdct1$GetTreeForNode(nodeID = parentNodeID,
		       treeID = &treeID);         

  strcpy(fld.name, VDCT_NODE_NAME);
  strcpy(fld.val.txt,baseInfo->nodeName);

  fld.type = VDFLD_TYPE_TXT; 
  // put switch here for ppl check to see if duplicate 
  // attributes are found.  The routine returns 2 values

  sts = vdct1$SearchNodesForAttrMatch(parentID  = &treeID,
				      nodeID    = testID,
				      dupSwitch = &dupSwitch);
  if(traceFlag) printf("vdct1$SearchNodesForAttrMatch returned [%d] & [%d]\n",sts,dupSwitch);
  retFlag = 1;
   //if a match is found set nodeID == testID
  if(sts) {
    retFlag = 0;
    goto wrapup;
  }
  
  if(dupSwitch & 1) {
    //Send the data off to be tested to for duplicates
    vdct1$SearchForNodeInTree(a_treeID      = &treeID,
			      a_nodeType    = baseInfo->nodeType,
			      a_fld         = &fld,
			      a_descendFlag = desFlag,
			      a_nodeID      = &nodeID);
  }
  
    // if duplicate go to wrapup
    if (nodeID.objid != NULL_OBJID){
      if (msg1) vdfrm$SetStatus(form = form, txt = msg1);
 
      // notify of duplicate rejection on Prompt
      if(msg2){
	sprintf(buf,"%s %s %s",baseInfo->nodeType,baseInfo->nodeName,msg2);
	sts = VDnotify_box(buf);  
	if(traceFlag) printf("notice of Duplicate given\n");
	
      }
      retFlag = 0;
      if(traceFlag) printf("going to wrapup retFlag [%d]\n",retFlag);
      goto wrapup;
    }
    retFlag = 1;
   
  // Oh well!
wrapup:
  // say bye
  if (traceFlag) printf("<<< VDct1CheckForDuplicate (%d)\n",retFlag);
  return retFlag;
}
// end of IGRstat VDct1CheckForDuplicate
// ----------------------------------------------------------------------------

/* ---------------------------------------------------------
 * Standard event handlers
 */
#argsused
IGRstat VDct1CmdNodeCreatedTree(TGRid *treeID)
{  

  // update the summary
  VDct1FormUpdateVRTree(cmdInfo->tree.form, VDCT_FORM_TREE_G_TREE);
  VDct1FormUpdateVRTree(cmdInfo->lib.form, VDCT_FORM_LIB_G_TREE);
  return 1;
}
#argsused
IGRstat VDct1CmdNodeDeletedTree(TGRid *treeID)
{  
  // update the summary
  VDct1FormUpdateVRTree(cmdInfo->tree.form, VDCT_FORM_TREE_G_TREE);
  VDct1FormUpdateVRTree(cmdInfo->lib.form, VDCT_FORM_LIB_G_TREE);
  return 1;
}

/* -----------------------------------------------------
 * A Node was renamed
 */
IGRstat VDct1CmdNodeRenamedNode(TGRid *nodeID)
{ 
  IGRstat retFlag = 0;

  Form form = cmdInfo->node.form;
  // Form form1 = cmdInfo->part.form;
   
  IGRchar  buf[128];
  
  TVDctBaseInfo baseInfo;
  IGRstat       traceFlag = 0;
 
  vdct1$GetBaseInfo(objID    = nodeID, 
		    baseInfo = &baseInfo);
  
  // Arg Check
  if (nodeID->objid == NULL_OBJID) goto wrapup;
  if (traceFlag) printf("ArgCheck ok\n");
   
  // Update status
  sprintf(buf,"Renamed Node %s %s",baseInfo.nodeType,baseInfo.nodeName);
  vdfrm$SetStatus(form = form, txt = buf);

  // update the activeNodeID to the form
  if ((nodeID->objid == activeNodeID.objid) && (nodeID->osnum == activeNodeID.osnum)){
    sprintf(buf,"%s %s",baseInfo.nodeType,baseInfo.nodeName);
    vdfrm$SetStatus(form = form,gadget = VDCT_FORM_NODE_G_ACTIVE_NODE, txt = buf);
  }

  // update the parentNodeID to the form
  if ((nodeID->objid == parentNodeID.objid) && (nodeID->osnum == parentNodeID.osnum)){
 
    // get the parentNodeID data!
    vdct1$GetBaseInfo(objID    = &parentNodeID, 
		      baseInfo = &baseInfo);
  
    // Copy the parentNodeID data to the form
    sprintf(buf,"%s %s",baseInfo.nodeType,baseInfo.nodeName);
    vdfrm$SetStatus(form = form,gadget = VDCT_FORM_NODE_G_PARENT_NODE, txt = buf);
  }

  // success! 
  retFlag = 1;

  // Oh well
wrapup:

  // say bye
  if (traceFlag) printf("<<< VDct1CmdNodeRenamedNode %d\n",retFlag);
  return retFlag;
}

#argsused
IGRstat VDct1CmdNodeRenamedTree(TGRid *treeID)
{  

  return 1;
}


end implementation VDct1Base;















