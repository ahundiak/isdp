/* $Id: VDct1Free.I,v 1.2 2001/01/11 22:03:42 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/cmd/VDct1Free.I
 *
 * Description: Freeze Form
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Free.I,v $
 *      Revision 1.2  2001/01/11 22:03:42  art
 *      sp merge
 *
# Revision 1.6  2000/07/20  20:15:18  pinnacle
# js
#
# Revision 1.5  2000/06/30  18:55:30  pinnacle
# pn
#
# Revision 1.4  2000/05/26  11:34:16  pinnacle
# Replaced: vds/vdct1/cmd/VDct1Free.I for:  by pnoel for Service Pack
#
# Revision 1.3  2000/05/23  18:29:18  pinnacle
# Replaced: vds/vdct1/cmd/VDct1Free.I for:  by pnoel for Service Pack
#
# Revision 1.2  2000/05/09  19:15:10  pinnacle
# Replaced: vds/vdct1/cmd/VDct1Free.I for:  by pnoel for Service Pack
#
# Revision 1.1  2000/04/20  18:35:26  pinnacle
# Created: vds/vdct1/cmd/VDct1Free.I by pnoel for Service Pack
#
# Revision 1.2  2000/01/11  22:28:50  pinnacle
# ah
#
# Revision 1.1  1999/06/29  18:29:28  pinnacle
# ct
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 06/17/99  ah      Creation
 * 05/23/00  pn      Very substantial functionality improvement for 
 *                   the Freeze/Revise process and new form alterations
 ***************************************************************************/

class implementation VDct1Base;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDfrm.h"
#include "VDsa.h"
#include "VDppl1.h"

#include "VDct1.h"
#include "VDct1Cmd.h"
#include "time.h"
#include "VDct1Forms.h"

static int traceFlag;
static TVDct1CmdInfo *cmdInfo;

static TGRid activeNodeID;
static TGRid deletedNodeID;
static TGRid frozenNodeID;
static TGRid mrFrozenNodeID;


IGRstat VDct1CmdFormNotifyFree(TGRid *a_nodeID);

/* ---------------------------------------------------
 * Clear up the Freeze form nothing fancy
 * Clear up activeNodeID and frozenNodeID to NULL_OBJID
 */
IGRstat VDct1CmdFormNotifyFreeClear()
{
  IGRstat retFlag = 1;
  IGRstat traceFlag = 0;
  IGRchar buf[128];
  
  // say hi
  if (traceFlag) printf(">>> VDct1CmdFormNotifyFreeClear()\n");
 
  // set it blank
  strcpy(buf,"");
 
  // copy it everywhere to clear up the form
    // clear up the activeNode
    vdfrm$SetText(form   = cmdInfo->free.form,
		  gadget = VDCT_FORM_FREE_G_ACTIVE_NODE,
		  txt    = buf);

    // clear up the active Revision 
    vdfrm$SetText(form   = cmdInfo->free.form,
		  gadget = VDCT_FORM_FREE_G_ACT_REV,
		  txt    = buf);

    // clear up the frozenNode
    vdfrm$SetText(form   = cmdInfo->free.form,
		  gadget = VDCT_FORM_FREE_G_FROZEN_NODE,
		  txt    = buf);   

    // clear up the frozen Revision
    vdfrm$SetText(form   = cmdInfo->free.form,
		  gadget = VDCT_FORM_FREE_G_FRZ_REV,
		  txt    = buf); 

    // clear up the most recent Revision box
    vdfrm$SetText(form   = cmdInfo->free.form,
		  gadget = VDCT_FORM_FREE_G_MR_REV,
		  txt    = buf);  

    // clear up the deletedNode
    vdfrm$SetText(form   = cmdInfo->free.form,
		  gadget = VDCT_FORM_FREE_G_DELETE_NODE,
		  txt    = buf);   

    // clear up the message box
    vdfrm$SetText(form   = cmdInfo->free.form,
		  txt    = buf); 
    if (traceFlag) {
      printf("reset the message box to blank(1)\n");
      
    }
    
  // reset activeNodeID frozenNodeID and mrFrozenNodeID to nulls
    //activeNodeID.objid == NULL_OBJID;
  frozenNodeID.objid == NULL_OBJID;
  deletedNodeID.objid ==  NULL_OBJID;
  mrFrozenNodeID.objid == NULL_OBJID;
  
  
  // say bye
  if (traceFlag) printf("<<< VDct1CmdFormNotifyFreeClear(1)\n");
}

/* -------------------------------------------
 * Make a revised copy of the node and
 * attach it to the parent then repeat 
 * for each child of the copied node
 * also checks and fixes the attributes
 * same as VDct1NodeCopyNode in cmd/VDct1Node.I except:
 * NO PROTECTION against duplicate connections or nodes
 * and it ALTERS the Attributes:
 * FROZEN and ASSY_REV
 */
IGRstat VDct1NodeReviseNode(TGRid *parentID, TGRid *copyID, TGRid *rootID)
{
  IGRstat            retFlag = 0;
  IGRstat            traceFlag = 0;
  TVDctBaseInfo      parentBaseInfo;
  TVDctBaseInfo      baseInfo1;
  TVDctBaseInfo      copyBaseInfo;
  TVDctBaseInfo      rootBaseInfo;
  TVDctNodeTypeInfo  nodeTypeInfo;
  TGRid              nodeID,childID;
  IGRint             i, nextRevNum;
  IGRstat            sts, sts1, sts2;
  IGRchar            location[128], buf[128];
  TVDfld             fld;
  TGRobj_env         modelOE;
  Form               form = cmdInfo->free.form;
  // say hi
  if (traceFlag) {
    printf(">>> VDct1NodeReviseNode \n");
  }

  // Grab the info
  vdct1$GetBaseInfo(objID = parentID, baseInfo = &parentBaseInfo);
  vdct1$GetBaseInfo(objID = copyID, baseInfo = &copyBaseInfo);
  vdct1$GetBaseInfo(objID = rootID, baseInfo = &rootBaseInfo);

  if (*parentBaseInfo.setType  == 0) goto wrapup;
  if (*copyBaseInfo.nodeType   == 0) goto wrapup;

  // Verify type is valid
   vdct1$GetNodeTypeInfoByType(setType      = parentBaseInfo.setType,
			       nodeType     = copyBaseInfo.nodeType,
			       nodeTypeInfo = &nodeTypeInfo);

  if (*nodeTypeInfo.type == 0) goto wrapup;
  //xxx
  if (traceFlag) printf("Got the nodeTypeInfo.type and it was ok!\n");


  // start the creation of this node 
    // Create the object
    vdct1$CreateNode(parentID = parentID,
		     nodeType = copyBaseInfo.nodeType,
		     nodeName = copyBaseInfo.nodeName,
		     nodeID   = &nodeID);

    if (nodeID.objid == NULL_OBJID) goto wrapup;
  
    // Transfer attributes
    vdct1$CopyNodeAttributes(desID = &nodeID, 
			     srcID = copyID);

    // check to see if the node is ok to alter the FROZEN attribute and ASSY_REV
    sts = vdct1$IsNodeActivateOK(nodeID = &nodeID);
    if(traceFlag) printf("the status for revision came back [%d]\n",sts);
    
    // it is ok to activate the node Attributes
    if (sts & 1) {

   // get the attribute frozen 
    vdcol$GetAttr(objID = &nodeID, name = "frozen", fld = &fld);
    strcpy(fld.val.txt,"ACTIVE");

    // set up the attribute
    vdcol$UpdAttrs(objID = &nodeID,
		   cnt = 1,
		   fld = &fld);  

    // get the attribute assy_rev
    vdcol$GetAttr(objID = &nodeID, name = "assy_rev", fld = &fld);
    

  // get the most recent frozen mrRevNum
    vdfrm$GetText(form   = form,
		  gadget = VDCT_FORM_FREE_G_MR_REV,
		  txt    = buf);
 
    // convert it
    nextRevNum = atoi(buf);
    nextRevNum++;

    // copy it up
    sprintf(buf,"%03d",nextRevNum);
    strcpy(fld.val.txt,buf);
   if (traceFlag) {
      printf("\nWe are updating the Attributes because we should\n");
      printf("the Revision is [%d]\n\n",nextRevNum);
      
    }
    // set up the attribute
    vdcol$UpdAttrs(objID = &nodeID,
		   cnt = 1,
		   fld = &fld);

    }
    
    
    // Link model object
    vdct1$GetNodeModelObject(nodeID  = copyID,
			     modelOE = &modelOE);
  
      // connect it up
      if (modelOE.obj_id.objid != NULL_OBJID) {    
	if (traceFlag )printf("It got connected up \n");
      
	vdct1$ConnectNodeToModelObject(nodeID  = &nodeID,
				       modelOE = &modelOE);
      }
    
  
    // Save first one in rootID
    if ((rootID) && (rootID->objid == NULL_OBJID)) *rootID = nodeID;

  // Now do the kids

    for(i = 0; vdct1$GetTree1Child(objID = copyID, 
				   nth   = i, 
				   outID = &childID); i++) {

      VDct1NodeReviseNode(&nodeID,&childID,NULL);
      VDct1CmdMgrCreatedNode(&nodeID);
   
    }

  // Done
  retFlag = 1;
  
wrapup:

 // say bye
  if (traceFlag) {
    printf("<<< VDct1NodeReviseNode %d\n",retFlag);
  }


  return retFlag;
}


/******************************************
 * Unconditional copy routine that makes  *
 * new nodes exactly the same as the old  *
 * nodes but revised upwards if revisable *
 * not revised upward if not revisable    *    
 * Similar for Active vs Frozen status    *
 ******************************************/
IGRstat VDct1CmdCopyAndReviseIT(TGRid *f_nodeID)
{
  IGRstat        retFlag = 0;
  IGRstat        traceFlag = 0;
  TGRid          frzID, parentNodeID, childID;
  IGRint         i;
  TVDfld         frzFld, assyFld;
  IGRchar        buf[128], buf1[128], buf2[128];
  IGRint         mrRev;
   
  // say hi
  if (traceFlag) printf(">>> VDct1CmdReviseIT()\n");
  
  // args check
  if (f_nodeID->objid == NULL_OBJID) goto wrapup;

  // copy in the ID
  frzID = *f_nodeID;
  
 // move up and get the parent
  vdct1$GetTree1Parent(objID = &frzID, nth = 0, outID = &parentNodeID);

  // revise the node
  VDct1NodeReviseNode(&parentNodeID,&frzID,NULL);

   // update the summary
  //VDct1FormUpdateVRTree(cmdInfo->tree.form, VDCT_FORM_TREE_G_TREE);
  // VDct1FormUpdateVRTree(cmdInfo->lib.form, VDCT_FORM_LIB_G_TREE); 
  // success
  retFlag = 1;

  // oh well
wrapup:
  // say bye
  if (traceFlag) printf("<<< VDct1CmdReviseIT(%d)\n",retFlag);
  return retFlag;
  
}
/* -------------------------------------------------
 * Mark Node as deleted and remove its kids
 * uses the activeNodeID
 */
IGRstat VDct1CmdFreeMarkDeleted()
{
  IGRstat       retFlag = 0;
  IGRstat       traceFlag = 0;
  IGRint        i, sts;
  TGRid         nodeID, childID;
  IGRchar       buf[128], buf1[128], buf2[128],location[128];
  Form          form  = cmdInfo->free.form;
  TVDctBaseInfo baseInfo;
  
 
  // say hi
  if(traceFlag) printf(">>> VDct1CmdFreeMarkDeleted\n");

  // args check
  if(activeNodeID.objid == NULL_OBJID) {
    sprintf(buf,"Please select a node\n\nTo Mark as Deleted\n");
    sts = VDnotify_box(buf); 
    goto wrapup;
  }
  
  nodeID = activeNodeID;

  // get active node description
  vdfrm$GetText(form   = form,
		gadget = VDCT_FORM_FREE_G_ACTIVE_NODE,
		txt    = buf1);

  // if it is blank get out of here
  if(!strcmp(buf1,"")) {
    sprintf(buf,"Please select a node\n\nTo Mark as Deleted\n");
    sts = VDnotify_box(buf);  
    goto wrapup;
  }
  
  // get the baseInfo
  vdct1$GetBaseInfo(objID = &nodeID, baseInfo = &baseInfo); 

  // rules to control deletion mark
  sprintf(location,"%s",VDCT1_ACTION_MARK_DEL);

  sts = vdct1$CmdNodeRulesOK(parentNodeID  = &nodeID,
			     baseInfo      = &baseInfo,
			     location      = location);

  // get out of here if the rules don't allow this
  if(!(sts & 1)) 
     {
       goto wrapup;
     }


  // start the message for Deletion Box
  strcpy(buf,"Delete? : ");
  sprintf(buf2,"%s %s",buf,buf1);

  // Confirm if Deletion is to be done if not goto wrapup
  if( GRconfirm_box(buf2) != TRUE )goto wrapup;

  // do the work
  retFlag = vdct1$SetNodeMarkDeleted(nodeID = &nodeID);

  // delete the kids
  while(vdct1$GetTree1Child(objID = &nodeID, nth = 0, outID = &childID)) {
    vdct1$DeleteNode(nodeID = &childID);
  }
  
  // Tell the world
  VDct1CmdMgrDeletedNode(&childID,&nodeID);
  VDct1CmdMgrActivateNode(&nodeID);

  // tell the text box
  sprintf(buf,"Marked Deleted: %s %s",baseInfo.nodeType,baseInfo.nodeName);
  vdfrm$SetText(form   = cmdInfo->free.form,
		txt    = buf);
  
wrapup:
  // say bye
  if(traceFlag) printf("<<< VDct1CmdFreeMarkDeleted(%d)\n",retFlag);
  return retFlag;
}

/* -------------------------------------------------
 * Restore to Deleted node to Active 
 * uses the activeNodeID
 */
IGRstat VDct1CmdFreeRestoreDeleted()
{
  IGRstat       retFlag = 0;
  IGRstat       traceFlag = 0;
  IGRchar       buf[128];
  IGRint        sts;
  Form          form  = cmdInfo->free.form;
  // say hi
  if(traceFlag) printf(">>> VDct1CmdFreeRestoreDeleted\n");

  // args check
  if(deletedNodeID.objid == NULL_OBJID) {
    sprintf(buf,"Please select a Deleted Node\n\nTo Restore to Active\n");
    sts = VDnotify_box(buf);  
    goto wrapup;
  }
  // get active node description
  vdfrm$GetText(form   = form,
		gadget = VDCT_FORM_FREE_G_DELETE_NODE,
		txt    = buf);

  // if it is blank get out of here
  if(!strcmp(buf,"")) {
    sprintf(buf,"Please select a Deleted Node\n\nTo Restore to Active\n");
    sts = VDnotify_box(buf);  
    goto wrapup;
  }  
  // do the work
  retFlag = vdct1$SetNodeActive(nodeID = &deletedNodeID);

  // update the form 
  VDct1CmdMgrActivateNode(&deletedNodeID);
  
wrapup:
  // say bye
  if(traceFlag) printf("<<< VDct1CmdFreeRestoreDeleted(%d)\n",retFlag);
  return retFlag;
}


/* -----------------------------------------------
 * The Revise Nodes button was pressed
 * Revisions apply only to assmblies directly below a GROUP
 * this is a ppl call for the validation because this might change
 * Revisions stop when there is not frozen attribute to be set
 * Revisions must search the tree to find the highest assy_rev number (not for part)
 * At the highest ASSY that is FROZEN!!!!!
 * Copy all below it unconditionally with the new assy_rev number except types 
 * determined by PPL such as ASSY[2]
 * Set the frozen to ACTIVE if the assy_rev is set
 */
IGRstat VDct1CmdReviseNodes()
{

  IGRstat         traceFlag = 0;
  IGRstat         retFlag   = 0;
  IGRint          state;
  IGRstat         sts;
  IGRint          revNum, mrRevNum, nextRevNum, i;
  IGRchar         buf[128], txtBox1[128], txtBox2[128];
  TGRid           workID, tmpID;
  TVDctBaseInfo   frzBaseInfo, wrkBaseInfo;
  TVDfld          fld;
  Form            form = cmdInfo->free.form; 

  // say hi
  if (traceFlag) printf(">>> VDct1CmdReviseNode\n");

  // if frozenNodeID is NULL somebody needs to pick a frozenNodeID
  if (frozenNodeID.objid == NULL_OBJID) {

    // tell the user to pick a frozenNode
    strcpy(buf,"Please Pick a Frozen Node\n\nTo be Revised\n");
    sts = vdct1$CmdNodeMsgBox(msg = buf);  
 
    // go home   
    goto wrapup;
  }

  // set the workID initially
  workID = frozenNodeID;

  // get the most recent frozen mrRevNum
  vdfrm$GetText(form   = form,
		gadget = VDCT_FORM_FREE_G_MR_REV,
		txt    = buf);
  if(traceFlag) printf("The most RecentRev is [%s]\n",buf);
  
  if (!strcmp(buf,"")) strcpy(buf,"000");
  mrRevNum = atoi(buf);
  
  // get the form checkbox status
  vdfrm$GetState(form   = form,
		 gadget = VDCT_FORM_FREE_C_MR,
		 state  = &state);

  // lets pick who gets updated swap in mrFrozenNode if the box is checked
  if (state & 1) {
    workID = mrFrozenNodeID;
  }

  // get the work baseInfo
  vdct1$GetBaseInfo(objID = &workID, baseInfo = &wrkBaseInfo);
 
    if (traceFlag) printf("The mrRevNum is before call [%d]\n",mrRevNum);  
  
  // is the parentNode the proper type to use workID?  
  // this is the ppl check for node type (could be more)
  sts = vdct1$IsReviseOK(parentNodeID = &workID,
			baseInfo      = &wrkBaseInfo,
			revNum        = &mrRevNum);
   if (traceFlag) printf("The mrRevNum is after call[%d]\n",mrRevNum);  

  if (!(sts & 1)) {
    // tell the user
    sprintf(buf,"This Node\n\n%s %s\n\nCannot Be Revised Here\n",
	    wrkBaseInfo.nodeType,
	    wrkBaseInfo.nodeName);

    sts = vdct1$CmdNodeMsgBox(msg = buf);  
    goto wrapup;
  }
  
  // ask the user if he really wants to revise this node
  sprintf(buf,   
	  "Revise: %s %s?",
	  wrkBaseInfo.nodeType,
	  wrkBaseInfo.nodeName);
  
  sts = vdct1$CmdNodeConfirmBox(msg = buf);
  
  // if not goto wrapup
  if (!(sts & 1)) goto wrapup;

  VDct1CmdCopyAndReviseIT(&workID);

  retFlag = 1;
  
wrapup:
  // say bye
  if (traceFlag) printf("<<< VDct1CmdReviseNode(%d)\n",retFlag);
  
  return retFlag;
  
}


/* ------------------------------------------------
 * Absolute unconditional freezer for a node and its kids
 * if they exist they get frozen 
 * pretty simple stuff here just go down and do it
 */
IGRstat VDct1CmdFreezeNodes(TGRid *f_nodeID)
{
  IGRstat retFlag = 0;
  IGRstat traceFlag = 0;
  IGRint  i, sts;
  TGRid   childID, workID;
  TVDfld  fld;
  IGRchar buf[128];
  TVDctBaseInfo baseInfo;
  

  //say hi
  if (traceFlag) printf(">>>  VDct1CmdFreezeNodes\n");

  // args check
  if (f_nodeID->objid == NULL_OBJID) goto wrapup;

 // copy it out
  workID = *f_nodeID;
  
  // get the status of workID
  vdct1$SR(sts = traceFlag,loc = "workID",nodeID = &workID);
 
  // get the parentBaseInfo 
  vdct1$GetBaseInfo(objID = &workID, baseInfo = &baseInfo); 

  // get the attribute
  vdcol$GetAttr(objID = &workID, name = "frozen", fld = &fld);

  // if attempt to freeze a node without this attribute quit
  if (*fld.name == 0) goto wrapup;
    
  strcpy(fld.val.txt,"FROZEN");

  // set up the attribute
  vdcol$UpdAttrs(objID = &workID,
		 cnt = 1,
		 fld = &fld);

  // Now do the kids
  for(i = 0; vdct1$GetTree1Child(objID = &workID, 
				 nth   = i, 
				 outID = &childID); i++) {

    VDct1CmdFreezeNodes(&childID);
  }
  
  retFlag = 1;
wrapup:
  //say bye
  if (traceFlag) printf("<<<  VDct1CmdFreezeNodes(%d)\n",retFlag);
  return retFlag;
}

/* ------------------------------------------------
 * The Freeze Node Button was pushed
 * All freezing is up to the parent of a PART 
 * All freezing is from that parent downward indefinitely
 * Freezing consists of renaming the freeze attribute for 
 * all items below that parent.  If it was an assembly selected 
 * The assembly is frozen and all assys below are frozen
 * autoselects the activeNode up to the next Parent when this option is 
 * selected for a PART and downward if not a PART
 */
IGRstat VDct1CmdFreezeSelection(TGRid *s_nodeID)
{
  IGRstat       retFlag = 0;
  IGRstat       traceFlag = 0;
  TGRid         workID,       parentNodeID,   baseNodeID;
  TVDctBaseInfo workBaseInfo, parentBaseInfo, baseInfox;
  TVDfld        fld;
  IGRstat       sts;
  IGRchar       buf[128];

   // if activeNodeID is NULL somebody needs to pick an activeNodeID
  if (s_nodeID->objid == NULL_OBJID) {

    // tell the user to pick a activeNodeID
    strcpy(buf,"Please Pick an Active Node\n\nTo be Frozen\n");
    sts = vdct1$CmdNodeMsgBox(msg = buf);  
 
    // go home   
    goto wrapup;
  } 

  // set it up first
  workID       = *s_nodeID;
  parentNodeID = *s_nodeID;

  // get the workBaseInfo to check if the item is a part
  // normally this would be ppl stuff but this check is always  for the PART
  vdct1$GetBaseInfo(objID = &workID, baseInfo = &workBaseInfo);

  if (!strcmp(workBaseInfo.nodeType,"PART")) {
  
    strcpy(buf,"You Cannot Freeze\n\nThis PART Node\n");
    sts = vdct1$CmdNodeMsgBox(msg = buf);
    goto wrapup;
  }
  // get the parentBaseInfo 
   vdct1$GetBaseInfo(objID = &parentNodeID, baseInfo = &parentBaseInfo); 
    if (traceFlag) {
    sprintf(buf,"This was a \n\n%s %s\n",
	    parentBaseInfo.nodeType,
	    parentBaseInfo.nodeName);
    sts = vdct1$CmdNodeMsgBox(msg = buf);
    }  
   // tell the Freeze Form the proper parentNodeID;
   sts = VDct1CmdFormNotifyFree(&parentNodeID);

  // get the attribute
  vdcol$GetAttr(objID = &parentNodeID, name = "frozen", fld = &fld);

  // if there is not attribute you can't freeze it. 
  if (*fld.name == 0) {
    strcpy(buf,"You Cannot Freeze\n\nThis Node\n");
    sts = vdct1$CmdNodeMsgBox(msg = buf);
    goto wrapup;
  }
 
  if (!strcmp(fld.val.txt,"FROZEN")) {

    // tell the user that the node is already frozen and tell it's name
    sprintf(buf,
	    "Already Frozen\n\n%s %s\n",
	    parentBaseInfo.nodeType, parentBaseInfo.nodeName);
    
    sts = vdct1$CmdNodeMsgBox(msg = buf);
    goto wrapup;
  }

  /**********************************************
   * now that we have the assembly above a part *
   * with a frozen attribute ACTIVE             *
   * go up and check to see if it has a GROUP   *
   * for a parent using PPL                     *
   **********************************************/
  sts = vdct1$IsFreezeOK(parentNodeID   = &parentNodeID,
			 baseInfo       = &parentBaseInfo);

  if (!(sts & 1)) {
    // tell the user that the node cannot be frozen
    sprintf(buf,
	    "Cannot Freeze this Node\n\n%s %s\n",
	    parentBaseInfo.nodeType, parentBaseInfo.nodeName);
    sts = vdct1$CmdNodeMsgBox(msg = buf);
    goto wrapup;
  }
  
   // ask the user if he really wants to freeze this node
  sprintf(buf,   
	  "Freeze: %s %s?",
	  parentBaseInfo.nodeType,
	  parentBaseInfo.nodeName);
  
  sts = vdct1$CmdNodeConfirmBox(msg = buf);
  
    // if so do it!
    if (sts & 1) {
      VDct1CmdFreezeNodes(&parentNodeID); 

      // clear up the freeze form
      VDct1CmdFormNotifyFreeClear();
      
      // tell the Freeze Form the proper parentNodeID;
      sts = VDct1CmdFormNotifyFree(&parentNodeID);     

      // tell the attr.form of the change
      activeNodeID = parentNodeID;

      // tell the freeze form that we did it
      sprintf(buf,"Froze: %s %s\n",
	      parentBaseInfo.nodeType,
	      parentBaseInfo.nodeName);
     
      vdfrm$SetText(form   = cmdInfo->free.form,
		    gadget = 10,
		    txt    = buf);   
    if (traceFlag) {
      printf("reset the message box to blank(2)\n");
      
    }   
    }

  // update the summary
  VDct1FormUpdateVRTree(cmdInfo->tree.form, VDCT_FORM_TREE_G_TREE);
  VDct1FormUpdateVRTree(cmdInfo->lib.form, VDCT_FORM_LIB_G_TREE);    
  VDct1CmdMgrActivateNode(&parentNodeID);
  
  
  retFlag = 1;
wrapup:
  return retFlag;
}


/* ------------------------------------------------
 * notify the Freeze form of activeNodeID
 * This routine activates the placement of
 * the data on the free.form and if the node is frozen
 * it sets the frozenNodeID or the activeNodeID
 * it sets the mrFrozenNodeID as well. 
 * It also sets the revision number up on the frozenNodeID amd activeNodeID
 * It will clear the form data for any items not present
 */
IGRstat VDct1CmdFormNotifyFree(TGRid *a_nodeID)
{
  IGRstat         retFlag   = 0;
  IGRstat         traceFlag = 0;
  TGRid           nodeID, outID, childID;
  TVDctBaseInfo   baseInfo, baseInfox;
  IGRchar         buf[128], buf1[128], buf2[128];
  IGRstat         sts, i;
  IGRint          revNum = 0;
  IGRint          revNumHighest = -1;
  IGRint          state;
  TVDfld          frzFld, revFld, assyFld;
  

  if (traceFlag) printf(">>> VDct1CmdFormNotifyFree\n");
  // args check
  if (a_nodeID->objid == NULL_OBJID) {
    // clear up the form because there is not any data
    activeNodeID.objid == NULL_OBJID;
    deletedNodeID.objid == NULL_OBJID;
    strcpy(buf,"");

    // clear up the activeNode
    vdfrm$SetText(form   = cmdInfo->free.form,
		  gadget = VDCT_FORM_FREE_G_ACTIVE_NODE,
		  txt    = buf);

    // clear up the active Revision 
    vdfrm$SetText(form   = cmdInfo->free.form,
		  gadget = VDCT_FORM_FREE_G_ACT_REV,
		  txt    = buf);

    // clear up the deletedNode
    vdfrm$SetText(form   = cmdInfo->free.form,
		  gadget = VDCT_FORM_FREE_G_DELETE_NODE,
		  txt    = buf);

    // clear up the message box
    // vdfrm$SetText(form   = cmdInfo->free.form,
    //txt    = buf);

    // clear up the frozenNode
    if (frozenNodeID.objid == NULL_OBJID) {
      vdfrm$SetText(form   = cmdInfo->free.form,
		    gadget = VDCT_FORM_FREE_G_FROZEN_NODE,
		    txt    = buf);   

      // clear up the frozen Revision
      vdfrm$SetText(form   = cmdInfo->free.form,
		    gadget = VDCT_FORM_FREE_G_FRZ_REV,
		    txt    = buf); 
    }
    goto wrapup;
  }
   
  nodeID = *a_nodeID;
  vdct1$GetBaseInfo(objID    = &nodeID, 
		    baseInfo = &baseInfo);

  if (*baseInfo.nodeType == 0) goto wrapup;
  sprintf(buf,"%s %s",baseInfo.nodeType,baseInfo.nodeName);

  // get the frozen status The attribute must be present to post the data
  sts = vdcol$GetAttr(objID = &nodeID, name = "frozen", fld = &frzFld);

  // get the assy_rev  status The attribute must be present to post the data
  sts = vdcol$GetAttr(objID = &nodeID, name = "assy_rev", fld = &assyFld);

  // if either is missing clear out
  if (*frzFld.name == 0) {

    // if the attribute is not present clear up the activeNode on the form and in this
    activeNodeID.objid == NULL_OBJID;
    strcpy(buf,"");

    // clear up the activeNode
    vdfrm$SetText(form   = cmdInfo->free.form,
		  gadget = VDCT_FORM_FREE_G_ACTIVE_NODE,
		  txt    = buf);

    // clear up the active Revision 
    vdfrm$SetText(form   = cmdInfo->free.form,
		  gadget = VDCT_FORM_FREE_G_ACT_REV,
		  txt    = buf);
    // go home
    goto wrapup;
  }
  // get the assy_rev status The attribute must be present to post the data
  sts = vdcol$GetAttr(objID = &nodeID, name = "assy_rev", fld = &revFld);

    // copy it up blank
  strcpy(buf2,"");

  strcpy(buf1,frzFld.val.txt);
  if (*revFld.name != 0) {
    strcpy(buf2,revFld.val.txt);
    revNum = atoi(buf2);
  }
  

  switch(*buf1) {

    case 'A':
      // set the activeNode on the form
      if (traceFlag) printf("We hit an Active Node\n");
      vdfrm$SetText(form   = cmdInfo->free.form,
		    gadget = VDCT_FORM_FREE_G_ACTIVE_NODE,
		    txt    = buf);

      // set up the active Revision 
      vdfrm$SetText(form   = cmdInfo->free.form,
		    gadget = VDCT_FORM_FREE_G_ACT_REV,
		    txt    = buf2);

    // set the deleted node blank on the form
    strcpy(buf2,"");

    vdfrm$SetText(form   = cmdInfo->free.form,
		  gadget = VDCT_FORM_FREE_G_DELETE_NODE,
		  txt    = buf2); 

      // tell the form
      sprintf(buf2,"Active Node Sel: %s %s\n",baseInfo.nodeType,baseInfo.nodeName);
      vdfrm$SetText(form   = cmdInfo->free.form,
		    txt    = buf2);
    if (traceFlag) {
      printf("reset the message box (4)\n");
      
    }
      // set the activeNodeID to match input from tree,form
      activeNodeID = *a_nodeID;
      break;

  case 'D':
    // set the activeNode blank on the form
    strcpy(buf2,"");
    vdfrm$SetText(form   = cmdInfo->free.form,
		  gadget = VDCT_FORM_FREE_G_ACTIVE_NODE,
		  txt    = buf2); 
  
// set the deleted node value on the form
    vdfrm$SetText(form   = cmdInfo->free.form,
		  gadget = VDCT_FORM_FREE_G_DELETE_NODE,
		  txt    = buf); 

    // notify the text box
      sprintf(buf2,"Deleted Node Sel: %s %s\n",baseInfo.nodeType,baseInfo.nodeName);
      vdfrm$SetText(form   = cmdInfo->free.form,
		    txt    = buf2);  

      // set the deletedNodeID to match input from tree,form
      deletedNodeID = *a_nodeID;
      break;
      
  case 'F':
    // set the frozenNode on the form
    if (traceFlag) printf("We hit a Frozen Node\n");
    vdfrm$SetText(form   = cmdInfo->free.form,
		  gadget = VDCT_FORM_FREE_G_FROZEN_NODE,
		  txt    = buf); 
  
    // set up the frozen Revision 
    vdfrm$SetText(form   = cmdInfo->free.form,
		  gadget = VDCT_FORM_FREE_G_FRZ_REV,
		  txt    = buf2);

    if (!strcmp(buf2,"")) {
      vdfrm$SetText(form   = cmdInfo->free.form,
		    gadget = VDCT_FORM_FREE_G_MR_REV,
		    txt    = buf2);
    }
      

    // tell the form
    sprintf(buf2,"Frozen Node Sel: %s %s\n",baseInfo.nodeType,baseInfo.nodeName);
    vdfrm$SetText(form   = cmdInfo->free.form,
		  txt    = buf2);
    if (traceFlag) {
      printf("reset the message box(3)\n");
      
    }

     vdfrm$GetState(form   = cmdInfo->free.form,
		    gadget = VDCT_FORM_FREE_C_MR,
		    state  = &state);

     if (traceFlag) {
       sprintf(buf,"State is [%d]\n",state);
       sts = vdct1$CmdNodeMsgBox(msg = buf);  
     }

     // see if its valid to freeze
     sts = vdct1$IsFreezeOK(parentNodeID   = &nodeID,
			    baseInfo       = &baseInfo);

     if (traceFlag) {
       printf("the freezeOK(%d)\n",sts);
     }
     
     if (!(sts & 1)) {
       strcpy(buf2,"");
       // clear up the Freeze Form NODEID slot
      vdfrm$SetText(form   = cmdInfo->free.form,
		    gadget = VDCT_FORM_FREE_G_FROZEN_NODE,
		    txt    = buf2); 

       // clear up the mrFrozenNodeID and frozenNodeID;
       frozenNodeID.objid = NULL_OBJID;
       mrFrozenNodeID.objid = NULL_OBJID;
       goto wrapup;
     }
     

     if (sts & 1) {
       // move up and get the parent
       vdct1$GetTree1Parent(objID = &nodeID, nth = 0, outID = &outID);

       // now check its kids
       for (i = 0; (vdct1$GetTree1Child(objID = &outID,       
					nth   = i,    
					outID = &childID)); i++) {

	 // get the baseInfox of the childID
	 vdct1$GetBaseInfo(objID    = &childID, 
			   baseInfo = &baseInfox);

	 // make sure we are looking at the same assembly by name and type
	 if ((!strcmp(baseInfo.nodeType,baseInfox.nodeType)) && 
	     (!strcmp(baseInfo.nodeName,baseInfox.nodeName))) {
	   
	   // with each child get the attribute data to be processed
	   vdcol$GetAttr(objID = &childID, name = "frozen",   fld = &frzFld); 
	   vdcol$GetAttr(objID = &childID, name = "assy_rev", fld = &revFld);  

	   if (!strcmp(frzFld.val.txt,"FROZEN")){
	     if(*revFld.name != 0) {
	       revNum = atoi(revFld.val.txt);
	       if (revNum > revNumHighest) {
		 revNumHighest = revNum;
		 mrFrozenNodeID = childID;
		 sprintf(buf,"%03d",revNumHighest);
		 
		 // set up the frozen MOST RECENT  Revision 
		 vdfrm$SetText(form   = cmdInfo->free.form,
			       gadget = VDCT_FORM_FREE_G_MR_REV,
			       txt    = buf);
	       } // set revNum test
	     } // revFld test
	   } // attribute frozen test
	 } // node baseInfo check
       } // childID  loop
     } // isFreezeOK test
     
      // set the frozenNodeID to match input from tree.form
      frozenNodeID = *a_nodeID;
      break;
    }


    retFlag = 1;
    
wrapup:
    if (traceFlag) printf("<<<  VDct1CmdFormNotifyFree(%d)\n",retFlag);
  return retFlag;
  
}

/* -----------------------------------------------
 * Sets the version of the node
 */
IGRstat VDct1GetNodeVersion(TGRid *nodeID, IGRint *verNum, IGRchar *verStr)
{
  IGRstat retFlag = 0;
  TVDfld  fld;

  // Arg check
  if (verNum) *verNum = -1;
  if (verStr) *verStr = 0;
  if (nodeID == NULL) goto wrapup;
  
  // Get the string
  vdcol$GetAttr(objID = nodeID, name = "assy_rev", fld = &fld);
  if (*fld.name == 0) goto wrapup;

  // Parse it
  if (verStr) strcpy(verStr,fld.val.txt);
  if (verNum) {
    if (*fld.val.txt == 'A') *verNum = atoi(fld.val.txt+1) * -1;
    else                     *verNum = atoi(fld.val.txt);
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Generates the version string
 */
IGRstat VDct1GenNodeVersion(IGRint verNum, IGRchar *verStr)
{
  IGRstat retFlag = 0;
  TVDfld  fld;

  time_t current_time;
  struct tm *tm;
  
  IGRchar prefix[16];
    
  // Arg check
  if (verStr == NULL) goto wrapup;
  *verStr = 0;
  
  // Prefix
  if (verNum < 0) sprintf(prefix,"A%d ",-verNum);
  else            sprintf(prefix,"%03u", verNum);

  // Date time stamp
  time(&current_time);
  tm = localtime(&current_time);
    
  sprintf(verStr,
	  "%s %4d%02d%02d",
	  prefix,
	  tm->tm_year+1900,tm->tm_mon+1,tm->tm_mday);

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Sets the version of the node
 */
IGRstat VDct1SetNodeVersion(TGRid *nodeID, IGRint verNum)
{
  IGRstat retFlag = 0;
  TVDfld  fld;

  TGRid  childID;
  IGRint i;
  
  // Arg check
  if (nodeID == NULL) goto wrapup;
  vdcol$GetAttr(objID = nodeID, name = "frozen", fld = &fld);
  if (*fld.name == 0) goto wrapup;

  // Update
  VDct1GenNodeVersion(verNum,fld.val.txt);
  vdcol$UpdAttrs(objID = nodeID, cnt = 1, fld = &fld);

  // Set all children as well
  for(i = 0; vdct1$GetTree1Child(objID = nodeID, nth = i, outID = &childID); i++) {
    VDct1SetNodeVersion(&childID, verNum);
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Finds the latest version of a frozen node
 */
IGRstat VDct1GetLatestFrozenCopy(TGRid *nodeID, TGRid *frozenID)
{
  IGRstat retFlag = 0;
  
  TGRid parentID;
  TGRid childID;
  
  TVDctBaseInfo nodeInfo,childInfo;
  IGRint i;
  IGRint nodeVer,childVer;

  TVDfld fld;
  
  // Arg check
  if (frozenID == NULL) goto wrapup;
  frozenID->objid = NULL_OBJID;
  if (nodeID == NULL) goto wrapup;
  
  // Assume they share the same parent
  vdct1$GetTree1Parent(objID = nodeID, outID = &parentID);
  if (parentID.objid == NULL_OBJID) goto wrapup;

  vdct1$GetBaseInfo(objID = nodeID, baseInfo = &nodeInfo);
  if (*nodeInfo.baseName == 0) goto wrapup;
  
  nodeVer = -1;
  
  // Check each child
  for(i = 0; vdct1$GetTree1Child(objID = &parentID, nth = i, outID = &childID); i++) {

    vdct1$GetBaseInfo(objID = &childID, baseInfo = &childInfo);
    if (!strcmp(nodeInfo.baseName,childInfo.baseName)) {
      
      VDct1GetNodeVersion(&childID,&childVer,NULL);
      
      if (childVer > nodeVer) {
	*frozenID = childID;
	 nodeVer  = childVer;
      }

    }
  }
  
  // Check results
  if (nodeVer < 0) goto wrapup;
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Compares node with children of other node
 */
IGRstat VDct1CmdFreeCompareChildren(TGRid *baseID, TGRid *compareID, IGRint flag)
{
  IGRstat retFlag = 0;
  TGRid   childID;
  IGRint  i;

  TGRobj_env compareOE;
  TGRobj_env childOE;
  
  // Only worried about those with a model connection for now
  vdct1$GetNodeModelObject(nodeID  = compareID,
			   modelOE = &compareOE);
  

  if (compareOE.obj_id.objid == NULL_OBJID) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Check each child
  for(i = 0; vdct1$GetTree1Child(objID = baseID, nth = i, outID = &childID); i++) {

    vdct1$GetNodeModelObject(nodeID  = &childID,
			     modelOE = &childOE);
    

    if ((compareOE.obj_id.objid == childOE.obj_id.objid) && 
	(compareOE.obj_id.osnum == childOE.obj_id.osnum)) {
      retFlag = 1;
      goto wrapup;
    }
  }
  
  // Not found, how sad
  printf("----- NODE VERSION COMPARE, CHILD NOT FOUND -----\n");
  vdobj$Print(objID =  baseID);
  vdobj$Print(objID =  compareID);
  vdobj$Print(objOE = &compareOE);
  printf("-----\n");
  
wrapup:
  return retFlag;
}

/* -------------------------------------------
 * Compare active and frozen nodes
 */
IGRstat VDct1CmdFreeNotifyCompareNodes()
{
  IGRstat retFlag = 0;
  IGRstat sts,changed;
  
  Form form = cmdInfo->free.form;

  TVDctBaseInfo activeInfo;
  TVDctBaseInfo frozenInfo;
  IGRchar       buf[128];
  
  IGRint i;
  TGRid  childID;
  
  // Must have an active node
  if (activeNodeID.objid == NULL_OBJID) {
    vdfrm$SetStatus(form = form, txt = "Pick active node first");
    goto wrapup;
  }

  // get the form info on the activeNodeID
  vdfrm$GetText(form   = form, 
		gadget = VDCT_FORM_FREE_G_ACTIVE_NODE,
		txt    = buf);

  // test if it is blank
  if(!strcmp(buf,"")) {
    vdfrm$SetStatus(form = form, txt = "Pick active node first");
    goto wrapup;
  }
  
  // Must have an frozen node
  if (frozenNodeID.objid == NULL_OBJID) {
    vdfrm$SetStatus(form = form, txt = "Pick frozen node first");
    goto wrapup;
  }
 
  // Should be same node
  vdct1$GetBaseInfo(objID = &activeNodeID, baseInfo = &activeInfo);
  vdct1$GetBaseInfo(objID = &frozenNodeID, baseInfo = &frozenInfo);

  if (strcmp(activeInfo.nodeType,frozenInfo.nodeType) ||
      strcmp(activeInfo.nodeName,frozenInfo.nodeName)) 
  {
    vdfrm$SetStatus(form = form, txt = "Nodes are from different assemblies");
    goto wrapup;
  }
  changed = 0;
  // set the activeNode name in the form
  vdfrm$SetStatus(form   = form, 
		  gadget = VDCT_FORM_FREE_G_ACTIVE_NODE,
		  txt    = activeInfo.baseName);

  // set the frozenNode name in the form
  vdfrm$SetStatus(form   = form, 
		  gadget = VDCT_FORM_FREE_G_FROZEN_NODE,
		  txt    = frozenInfo.baseName);  

  // Gross check for matching children
  for(i = 0; vdct1$GetTree1Child(objID = &activeNodeID, nth = i, outID = &childID); i++) {
    sts = VDct1CmdFreeCompareChildren(&frozenNodeID,&childID,1);
    if (!(sts & 1)) changed = 1;
  }
  
  // Repeat for deleted items
  for(i = 0; vdct1$GetTree1Child(objID = &frozenNodeID, nth = i, outID = &childID); i++) {
    sts = VDct1CmdFreeCompareChildren(&activeNodeID,&childID,0);
    if (!(sts & 1)) changed = 1;
  }

  // Show results
  if (changed) vdfrm$SetStatus(form = form, txt = "Differences were found");
  else         vdfrm$SetStatus(form = form, txt = "No Differences found");
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -------------------------------------------
 * Determines if a node is different than it's
 * latest frozen version
 */

/* -------------------------------------------
 * Freeze a node
 */
IGRstat VDct1CmdFreeNotifyFreezeNode()
{
  IGRstat retFlag = 0;
  Form form = cmdInfo->free.form;
  
  TGRid curID;
  TGRid parentID;
  TGRid frozenID;
  
  IGRint  verNum;
  
  // Must have a node in the active os
  if (activeNodeID.objid == NULL_OBJID) {
    vdfrm$SetStatus(form = form, txt = "Pick node to freeze first");
    goto wrapup;
  }
  ex$get_cur_mod(id = &curID.objid, osnum = &curID.osnum);
  if (curID.osnum != activeNodeID.osnum) {
    vdfrm$SetStatus(form = form, txt = "Can't freeze node in reference file");
    goto wrapup;
  }
  
  // See if already froze it
  VDct1GetLatestFrozenCopy(&activeNodeID,&frozenID);
  VDct1GetNodeVersion(&frozenID,&verNum,NULL);
  if (verNum < 0) verNum = 0;
  else            verNum++;
  
  // Get the parent
  vdct1$GetTree1Parent(objID = &activeNodeID, outID = &parentID);
  if (parentID.objid == NULL_OBJID) {
    vdfrm$SetStatus(form = form, txt = "Problem getting parent");
    goto wrapup;
  }

  // Make a new copy
  frozenID.objid = NULL_OBJID;
  VDct1NodeCopyNode(&parentID,&activeNodeID,&frozenID);
  VDct1SetNodeVersion(&frozenID,verNum);
  
  // Active is in sync with the latest version
  VDct1SetNodeVersion(&activeNodeID,-2);

  // Show the results
  VDct1FormUpdateTreeRow(cmdInfo->tree.form, VDCT_FORM_TREE_G_TREE, &parentID);
  VDct1FormUpdateTreeRow(cmdInfo->lib.form,  VDCT_FORM_LIB_G_TREE,  &parentID);
  VDct1CmdMgrActivateNode(&activeNodeID);

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -------------------------------------------
 * Traffic directory for handling located objects
 */
IGRstat VDct1CmdFreeLocatedObject(TGRobj_env *modelOE)
{
  IGRstat retFlag = 0;

  Form form = cmdInfo->free.form;
  
  IGRchar buf[256];
  
  // Switch on doit
  vdfrm$GetText(form   = form,
		gadget = VDCT_FORM_FREE_G_DOIT,
		txt    = buf);

  switch(*buf) {
#if 0
  case '3': 
    VDct1CmdNodeCreateModelNode(modelOE);
    retFlag = 1;
    break;

  case '4':
    VDct1CmdNodeCreateModelAssembly(modelOE);
    retFlag = 1;
    break;
    
  case '5': 
    VDct1CmdNodeConnectModelNode(modelOE);
    retFlag = 1;
    break;
#endif
  }
  
//wrapup:
  return retFlag;
}

/* ------------------------------------------
 * unconditional verification of the revNum in the box on the form
 * checks if the number is valid
 * if it is valid sets the frozenNodeID appropriately
 */
IGRstat  VDct1CmdFreeCheckRevID()
{
  IGRstat    retFlag = 0;
  IGRstat    traceFlag = 0; 
  Form       form = cmdInfo->free.form;
  IGRchar    buf1[128], buf2[128], buf[128];
  IGRint     revNum, mrRevNum, state, i, sts;
  TGRid      ptID,childID;
  TVDfld     assyFld;
 
  // say hi
  if (traceFlag) printf(">>> VDct1CmdFreeCheckRevID()\n");

  // args check
  if (frozenNodeID.objid == NULL_OBJID) goto wrapup;
  
  // get the form data
  vdfrm$GetText(form   = form,
		gadget = VDCT_FORM_FREE_G_FRZ_REV,
		txt    = buf1);

  // if there is no data get out of here
  if (!strcmp(buf1,"")) goto wrapup;
  
  // set it up
  revNum = atoi(buf1);
  
  vdfrm$GetText(form   = form,
		gadget = VDCT_FORM_FREE_G_MR_REV,
		txt    = buf2);
  // set it up
  mrRevNum = atoi(buf2);

  // get the form checkbox status
  vdfrm$GetState(form   = form,
		 gadget = VDCT_FORM_FREE_C_MR,
		 state  = &state);

  // if the revNum is too high or the mrFrozenNodeID is selected  
  if ((revNum >= mrRevNum) || (state & 1))  {

    // set the frozenNodeID etc to mrFrozenNodeID
    frozenNodeID =  mrFrozenNodeID;
   
    // set the form to reflect the selection
    vdfrm$SetText(form   = form,
		  gadget = VDCT_FORM_FREE_G_FRZ_REV,
		  txt    = buf2); 
    retFlag = 1;
    goto wrapup;
  }
  // if the user entered a negative number reset it to zero
  if (revNum < 0) {
    revNum = 0;
  }

  // hunt down the node which matches the revNum
 // get the ptID
  vdct1$GetTree1Parent(objID = &frozenNodeID, nth = 0, outID = &ptID);

  // Now do the kids
  sts = 0;
  for(i = 0; vdct1$GetTree1Child(objID = &ptID, 
				 nth   = i, 
				 outID = &childID); i++) {
    // get the attribute
    vdcol$GetAttr(objID = &childID, name = "assy_rev", fld = &assyFld);

    // if the attribute matches
    if (!strcmp(assyFld.val.txt,buf1)) {
      
      // set the form to reflect the selection
      sprintf(buf1,"%03d",revNum);
      vdfrm$SetText(form   = form,
		    gadget = VDCT_FORM_FREE_G_FRZ_REV,
		    txt    = buf1); 

      frozenNodeID = childID;
      retFlag = 1;
      goto wrapup;
    }
  }

  // get the attribute
  vdcol$GetAttr(objID = &frozenNodeID, name = "assy_rev", fld = &assyFld);

  // set the form to reflect the selection
  vdfrm$SetText(form   = form,
		gadget = VDCT_FORM_FREE_G_FRZ_REV,
		txt    = assyFld.val.txt); 

  // success  
  retFlag = 1;

  // oh well
wrapup:

  // say bye 
  if (traceFlag) printf("<<< VDct1CmdFreeCheckRevID(%d)\n",retFlag);
  return retFlag;
  
}

/* -------------------------------------------------
 * Doit processor
 */
IGRstat VDct1CmdFreeNotifyDoit()
{
  
  IGRstat retFlag;
  
  IGRchar buf[128];
  IGRchar cmd;

  VDct1CmdFreeCheckRevID();
  
  // Get the command string
  vdfrm$GetText(form   = cmdInfo->free.form,
		gadget = VDCT_FORM_FREE_G_DOIT,
		txt    = buf);
  cmd = *buf;
  
  // Switch it
  switch(cmd) {

  case '1':
    // freezes the nodes
    VDct1CmdFreezeSelection(&activeNodeID);
    
    break;

  case '2':
    // compares the nodes
    VDct1CmdFreeNotifyCompareNodes();
    break;
 
  case '3':
    // revises the nodes
    VDct1CmdReviseNodes();
    break;
    
  case '4':
    // clears up the form
    VDct1CmdFormNotifyFreeClear();
    break;
  case '5':
    VDct1CmdFreeMarkDeleted();
    break;

  case '6':
    VDct1CmdFreeRestoreDeleted();
    break;
    
  }
  
  retFlag = 1;
  
//wrapup:
  return retFlag;
}

/* -------------------------------------------
 * Node was deleted
 */
#argsused
IGRstat VDct1CmdFreeDeletedNode(TGRid *nodeID, TGRid *parentID)
{
  IGRstat retFlag = 0;
  Form form = cmdInfo->free.form;
  
#if 0
  // Its possible the parent was deleted
  if ((parentNodeID.objid == nodeID->objid) && 
      (parentNodeID.osnum == nodeID->osnum)) {

    parentNodeID.objid = NULL_OBJID;
    vdfrm$SetText(form   = form,
		  gadget = VDCT_FORM_NODE_G_PARENT_NODE,
		  txt    = "");
    
  }
#endif

  // Done
  retFlag = 1;
  
//wrapup:
  return retFlag;
}

/* -------------------------------------------
 * Node was created
 */
IGRstat VDct1CmdFreeCreatedNode(TGRid *nodeID)
{
  IGRstat retFlag = 0;
  Form form = cmdInfo->node.form;
  
  IGRchar  buf[128];
  
  TVDctBaseInfo baseInfo;
  
  vdct1$GetBaseInfo(objID = nodeID, baseInfo = &baseInfo);
  
  // Update status
  // sprintf(buf,"Created Node '%s'",baseInfo.baseName);
  // vdfrm$SetStatus(form = form, txt = buf);
  
  // Done
  retFlag = 1;
  
//wrapup:
  return retFlag;
}

/* -------------------------------------------
 * Node was activated
 */
IGRstat VDct1CmdFreeActivateNode(TGRid *nodeID)
{
  IGRstat retFlag = 1;
  Form    form = cmdInfo->free.form;
  
  TVDctBaseInfo baseInfo;
  IGRchar      *p;
  TVDfld        fld;

  IGRchar buf[128];

  // Trace
  if (traceFlag) {
    printf(">>> VDct1CmdFreeActivateNode\n");
  }
  if (form == NULL) {
    printf("*** Free form is NULL\n");
  }
  
  // Init
  //vdfrm$SetStatus(form = form, txt = "");
  
  // Arg Check
  if (nodeID == NULL) goto wrapup;
  
  // Need the info
  vdct1$GetBaseInfo(objID = nodeID, baseInfo = &baseInfo);

  // Only applicable to assemblies
  if (strcmp(baseInfo.nodeType,"ASSY")) goto wrapup;
  
  // Determine if it's active or already frozen
  vdcol$GetAttr(objID = nodeID, name = "frozen", fld = &fld);
  if (*fld.name == 0) goto wrapup;
  sprintf(buf,"%s %s",baseInfo.baseName,fld.val.txt);

  if (*fld.val.txt == 'A') {
    activeNodeID = *nodeID;
    vdfrm$SetText(form   = form,
		  gadget = VDCT_FORM_FREE_G_ACTIVE_NODE,
		  txt    = buf);
  }
  else {
    frozenNodeID = *nodeID;
    vdfrm$SetText(form   = form,
		  gadget = VDCT_FORM_FREE_G_FROZEN_NODE,
		  txt    = buf);
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf("<<< VDct1CmdFreeActivateNode\n");
  }
  return retFlag;
}

/* -------------------------------------------
 * The notification routine
 */
IGRstat VDct1CmdFreeNotifyForm()
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  // Process it
  if (traceFlag) printf(">>> VDct1CmdNodeNotifyForm\n");
  switch(cmdInfo->gadget) {

  case FI_EXECUTE:
    sts = VDct1CmdFreeNotifyDoit();
    break;
    
  case FI_ACCEPT:
    sts = VDct1CmdFreeNotifyDoit();
    if (sts & 1) {
      vdfrm$EraseForm(form =  cmdInfo->free.form, 
		      flag = &cmdInfo->free.displayed);
    }
    
    break;

  case FI_CANCEL:
    vdfrm$EraseForm(form =  cmdInfo->free.form, 
                    flag = &cmdInfo->free.displayed);
    break;
  }
  retFlag = 1;

//wrapup:
  if (traceFlag) printf("<<< VDct1CmdNodeNotifyForm\n");
  return retFlag;
}

/* --------------------------------------
 * Called when user pushes an open button
 */
IGRstat VDct1CmdFreeActivateForm()
{
  IGRstat retFlag = 0;

  // Ignore if already active for now
  if (cmdInfo->free.displayed) {
    retFlag = 1;
    goto wrapup;
  }
  
  if (traceFlag) printf(">>> VDct1CmdFreeActivateForm\n");
  if (cmdInfo->free.form == NULL) {
    printf("*** Free Form pointer is null\n");
  }
  
  // Display
  // sleep(5);
  vdfrm$DisplayForm(form =  cmdInfo->free.form, 
                    flag = &cmdInfo->free.displayed);

  // Done
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< VDct1CmdFreeActivateForm\n");
  return retFlag;
}

/* --------------------------------------------------------
 * Called on startup
 */
IGRstat VDct1CmdFreeInit(TVDct1CmdInfo *a_cmdInfo)
{
  IGRstat retFlag = 0;

  if (traceFlag) printf(">>> VDct1CmdFreeInit\n");

  cmdInfo = a_cmdInfo;

  activeNodeID.objid = NULL_OBJID;
  frozenNodeID.objid = NULL_OBJID;
  
  retFlag = 1;

  if (traceFlag) printf("<<< VDct1CmdFreeInit\n");
  return retFlag;
}

/* ---------------------------------------------------------
 * Standard event handlers
 */
#argsused
IGRstat VDct1CmdFreeCreatedTree(TGRid *treeID)
{  
  return 1;
}
#argsused
IGRstat VDct1CmdFreeDeletedTree(TGRid *treeID)
{  
  return 1;
}
#argsused
IGRstat VDct1CmdFreeRenamedTree(TGRid *treeID)
{  
  return 1;
}
#argsused
IGRstat VDct1CmdFreeRenamedNode(TGRid *nodeID)
{  
  IGRstat        retFlag     = 0;
  IGRstat        traceFlag   = 0;
  IGRchar        buf[128];
 
  Form           form        = cmdInfo->free.form;
  TVDctBaseInfo  baseInfo;
  TVDfld         fld;

  // args check
  if (nodeID == NULL) goto wrapup;

  // Need the info
  vdct1$GetBaseInfo(objID = nodeID, baseInfo = &baseInfo);

  // Get the attributes 
  vdcol$GetAttr(objID = nodeID, name = "frozen", fld = &fld);
  if (*fld.name == 0) goto wrapup;
  sprintf(buf,"%s %s",baseInfo.baseName,fld.val.txt);

  // print the active node to the form
    vdfrm$SetText(form   = form,
		  gadget = VDCT_FORM_FREE_G_ACTIVE_NODE,
		  txt    = buf);

  // needs to find an frozen node if there is one that matches

  // everything OK!
  retFlag = 1;
  // oh well
wrapup:
  if (traceFlag) printf("<<< VDct1CmdFreeRenamedNode %d\n",retFlag);  
  return retFlag;
}


end implementation VDct1Base;










