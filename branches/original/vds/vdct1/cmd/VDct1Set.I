/* $Id: VDct1Set.I,v 1.2 2001/01/11 22:03:42 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct/cmd/Vct1Set.I
 *
 * Description: Tree creation/modification form
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Set.I,v $
 *      Revision 1.2  2001/01/11 22:03:42  art
 *      sp merge
 *
# Revision 1.13  2000/07/25  13:04:40  pinnacle
# ah
#
# Revision 1.12  2000/07/20  20:15:58  pinnacle
# js
#
# Revision 1.11  2000/07/18  19:32:20  pinnacle
# ah
#
# Revision 1.10  2000/07/17  19:50:06  pinnacle
# ah
#
# Revision 1.9  2000/07/14  19:09:28  pinnacle
# pn
#
# Revision 1.8  2000/07/12  14:39:56  pinnacle
# pn
#
# Revision 1.7  2000/07/12  11:18:58  pinnacle
# pn
#
# Revision 1.1  1999/06/29  18:29:28  pinnacle
# ct
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/29/99  ah      creation
 * 01/10/00  pn      updated controls/safeops
 * 03/28/00  pn      new operations controls for tree added related to PPL's 
 *                   and naming of trees/attributes
 * 06/23/00  pn      altered the posting per CR 179901682
 * 07/06/00  pn      altered to control access and etc
 * 07/17/00  ah      Disable access control stuff
 ***************************************************************************/
class implementation VDct1Base;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDfrm.h"
#include "VDppl1.h"

#include "VDct1.h"
#include "VDct1Tree.h"
#include "VDct1Forms.h"

#include "VDct1Cmd.h"
#include "VDct1Post.h"

#include "VDassert.h"

VDASSERT_FFN("vdct1/cmd/VDct1Set.I");

static int traceFlag;
static TVDct1CmdInfo *cmdInfo;

static TGRid activeNodeID;
static TGRid activeTreeID;


/* ----------------------------------------
 * Internal routines
 */
IGRstat VDct1CmdSetNotifyCreateTree();
IGRstat VDct1CmdSetNotifyDeleteTree();
IGRstat VDct1CmdSetNotifyRenameTree();
IGRstat VDct1CmdSetNotifyDoit();
IGRstat VDct1CmdSetNotifyType();
FILE   *VDct1CmdSetOpenListOfSets();
IGRstat VDct1CmdSetFillTypes();
IGRstat VDct1ChangeNodeSetName(TGRid *nodeID,IGRchar *setName);

/* ----------------------------------------
 * External Routines
 */
extern IGRint     GRconfirm_box();
extern IGRint     VDnotify_box();
/* ----------------------------------------------------------
 * Prints the report for 1 node
 */
IGRstat VDct1PrintNodeReport(TGRid *nodeID, IGRstat seqNum)
{
  IGRstat        retFlag,k;
  TVDctBaseInfo  baseInfo;
  TVDfldS        flds;  
  GRrange        range;
  // init
  retFlag = 0;

  // args check
  if(nodeID->objid == NULL_OBJID) goto wrapup;
  
  // get the baseInfo
  vdct1$GetBaseInfo(objID = nodeID, baseInfo = &baseInfo);  

  printf("\n********** Node [%d] ************\n",seqNum);
  printf("SetType [%s] Node: [%s]\n\n",baseInfo.setType,baseInfo.baseName);

  // get the  node attributes
  vdcol$GetAttrs(objID = nodeID, 
		 cnt   = &flds.cnt, 
		 fld   = flds.fld);
  
  //print the attributes
  for(k = 0; k < flds.cnt; k = k + 1) {
    printf("     Attr [%s] [%s]\n",
	   flds.fld[k].name,
	   flds.fld[k].val.txt);  
  }   

  // if it is a PlotTree
  if(!strcmp("PlotTree",baseInfo.setType)) {
    /*
     * SHow the range of the Node...
     */
    vdct1$GetNodeRange(nodeID   = nodeID,
		       objRange = range );
    printf(" Range %g, %g, %g\n", range[0], range[1], range[2] );
    printf(" Range %g, %g, %g\n", range[3], range[4], range[5] );       
  }  
  
  // success
  retFlag = 1;
  
wrapup:
  return retFlag;
 
}
/* --------------------------------------------------------------
 *  supplies the count of and a list of nodes
 * don't directly call this routine 
 * call 
 */
IGRstat VDct1GetNodeListItems(TGRid *nodeID, TGRid *nodeList, IGRint *cnt)
{
  IGRstat retFlag, i;
  TGRid   testID, childID;
  
  
  // init
  retFlag = 1;
  testID = *nodeID;

  // args test
  if (nodeID->objid == NULL_OBJID) goto wrapup;
  
  // update the list
  nodeList[*cnt] = testID;

   // update the count
  *cnt = *cnt + 1;
  

  // time to do the kids
  for(i = 0;vdct1$GetTree1Child(objID = &testID, 
				 nth   = i, 
				outID = &childID); i++) {

    // call myself 
    VDct1GetNodeListItems(&childID,nodeList,cnt);

  }
  
wrapup:
  return retFlag;
}

/* ----------------------------------------------------------------
 * Supplies the count of nodes and their ID's
 */
IGRstat VDct1GetNodeListIDAndCount(TGRid *nodeID, TGRid *nodeList, IGRint *cnt)
{
  IGRstat retFlag;
  TGRid   testID, childID;
  
  
  // init
  retFlag = 1;
  *cnt = 0;

  // args test
  if (nodeID->objid == NULL_OBJID) goto wrapup;
  if (nodeList == NULL) goto wrapup;
  if (cnt == 0) goto wrapup;
  
  VDct1GetNodeListItems(nodeID,nodeList,cnt);
    
wrapup:
  return retFlag;
}
/* ----------------------------------------------------------------
 * Get the range of the objects..
 */
IGRstat VDct1GetNodeRange( TGRid *nodeID, GRrange objRange )
{
  TGRobj_env modelOE;
  IGRint  sts,msg;
  
  /*
   * Check if object is fine ...
   */


  if( ! nodeID ) goto wrapup ;
  if( nodeID->objid == NULL_OBJID ) goto wrapup;
  objRange[0] = objRange[1] = objRange[2] = 0.0;
  objRange[3] = objRange[4] = objRange[5] = 0.0;
  

  /*
   * get model objects from the node.
   */
    // Make sure don't already have a model
  vdct1$GetNodeModelObject(nodeID  = nodeID,
			   modelOE = &modelOE);
  
  if (modelOE.obj_id.objid == NULL_OBJID) {

    goto wrapup;
  }

  sts = VD_getRangeOfComposite( &msg, &modelOE, objRange );
  if( !(sts & msg & 1)) goto wrapup ;

  return MSSUCC ;
  
wrapup:
  return MSFAIL;
}

/* -----------------------------------------
 * Permissions control for Trees
 */
IGRstat VDct1CmdSetFileAccessOK()
{
  TGRid         mgrID, pdmID, setID;
  IGRstat       retFlag = 0;
  IGRstat       traceFlag = 0;
  IGRchar       catName[128],treeName[128],*p,*q;
  IGRchar       buf[DI_PATH_MAX];
  TVDatPDMInfo  info;
  IGRint        sts;
  TVDctBaseInfo baseInfo;
  FILE         *file;
  IGRchar       setType[128];
  IGRint        i,j, stringLength;
  
 
  // just for now wrapup anything
  //if(traceFlag) goto wrapup;
   if(traceFlag) printf(">>> VDct1CmdSetFileAccessOK\n"); 

  //Do nothing if not logged in
  sts = VDatVerifyLogin();
  if (!(sts & 1)) goto wrapup;

  // Do Nothing if no active manager
  vdct1$GetManager(mgrID = &mgrID);
  if (mgrID.objid == NULL_OBJID) {
    retFlag = 1;
    goto wrapup;
  }
    vdct1$GetMgrChild(objID = &mgrID, nth = 0, outID = &setID);

    // get the baseInfo
    vdct1$GetBaseInfo(objID = &setID, baseInfo = &baseInfo); 
    if(traceFlag) printf("baseInfo [%s] setType\n",baseInfo.setType);
    sts = vdct1$IsTreeLimitOK(nodeID   = &mgrID,
			      baseInfo = &baseInfo);
    if(traceFlag) printf("STS came back [%d]\n",sts);

    if(!sts){
      retFlag = 1;
      goto wrapup;
    }  
  // Make a list of files and cache their pdm info
  vdat$CreatePdmMgr(mgrID = &pdmID);
  if (pdmID.objid == NULL_OBJID) {  
    printf("*** Unable to create pdm manager\n");
    retFlag = 1;
    goto wrapup;
  }
  // Get the file key to work with
  VDatPOSTGetPDMInfo(mgrID.osnum,&info);
  if (info.key == 0) {
    printf("*** Unable to get pdm info\n");
    retFlag = 1;
    goto wrapup;
  }  

  // get the setType
  vdfrm$GetText(form   = cmdInfo->set.form,
		gadget = VDCT_FORM_SET_G_TREE_TYPE,
		txt    = setType); 

  // Look in local directory
  file = fopen("tm_access.tbl","rt");
  if (!file) {
    
    // Look in config directory
    for(i = 0; 1; i++) {
    
      // Product specific loading
      *buf = 0;
      ex$get_path( index = i,
		   path  = buf,
		   len   = sizeof(buf),
		   type  = EX_CONFIG_PATH );
      if(*buf == 0) {
	if(traceFlag) printf("exited due to *buf == 0\n");
	goto wrapup;
      }
      
     
      strcat(buf,"config/sets/tm_access.tbl");

      if(traceFlag) printf("Directory for Sets.txt file is\n[%s]\n\n",buf);
    
      file = fopen(buf,"rt");
      if (file != NULL) break;
    } 
  }
  
 // Cycle through
  while(fgets(buf,sizeof(buf),file)) {
    stringLength = strlen(buf);
    p = buf;
 
    // set it up
    strcpy(catName,"");
    strcpy(treeName,"");
    p = buf;
    j = 0;
    
    // copy it out
    for(i = 0; i < stringLength; i++) {
      if(*p == ' ') {
	j = 1;
      }
      if(*p > ' ' ) {
	if(!j) sprintf(treeName,"%s%c",treeName,*p);
	if(j) sprintf(catName,"%s%c",catName,*p);
      }
      p++;
    }

    if(traceFlag) {
      printf("treeName [%s] catName[%s]\n",treeName, catName);
      printf("setType  [%s] info.cat[%s]\n\n",setType,info.cat);
      
    }
    
      if((!strcmp(treeName,setType)) && 
	 (!strcmp(catName,info.cat))) {
	retFlag = 1;
	break;
      }
  
  }
  fclose(file);

wrapup:
  if(traceFlag) printf("<<< VDct1CmdSetFileAccessOK(%d)\n",retFlag);
  return retFlag;
  
}

/* ----------------------------------------
 * Main doit processor
 */
IGRstat VDct1CmdSetNotifyDoit()
{
  IGRstat retFlag;
  
  IGRchar buf[128];
  IGRchar cmd;
  
  // Get the command string
  vdfrm$GetText(form   = cmdInfo->set.form,
		gadget = VDCT_FORM_SET_G_DOIT,
		txt    = buf);
  cmd = *buf;
  
  // Switch it
  switch(cmd) {

  case '2':
    VDct1CmdSetNotifyCreateTree();
    break;

  case '3':
    VDct1CmdSetNotifyDeleteTree();
    break;

  case '4':
    VDct1CmdSetNotifyRenameTree();
    break;

  }
  
  retFlag = 1;
  
//wrapup:
  return retFlag;
}
/* ------------------------------------------
 * calls the posting routine from here
 */
IGRstat VDct1SetPostTrees()
{
  vdct1$POSTAll(postID = &activeTreeID);
  return 1;
}

/* ----------------------------------------
 * Recursive routine to return the root treenode 
 * to which a node belongs
 */
IGRstat VDct1GetTreeTopForNode(TGRid *nodeID, TGRid *treeID)
{
  IGRstat retFlag = 0;
  TGRid   parentID;
  
  // Arg check
  if (treeID == NULL) goto wrapup;
  treeID->objid = NULL_OBJID;
  
  if (nodeID == NULL) goto wrapup;
  if (nodeID->objid == NULL_OBJID) goto wrapup;
  if (nodeID->objid == 0)          goto wrapup;
  
  // Get its parent
  vdct1$GetTree1Parent(objID = nodeID, outID = &parentID);
  if (parentID.objid = NULL_OBJID) {
    *treeID = *nodeID;
    retFlag = 1;
    goto wrapup;
  }
  
  // Recurse up
  retFlag = vdct1$GetTreeTopForNode(nodeID = &parentID,
				    treeID = treeID);
  
  
wrapup:
  return retFlag;
}

/* ----------------------------------------
 * Initialize form based on a new active node 
 */
IGRstat VDct1CmdSetActivateNode(TGRid *nodeID)
{
  IGRstat retFlag = 0;
  
  Form    form  = cmdInfo->set.form;
  
  TVDctBaseInfo    baseInfo;
  TVDctSetTypeInfo setTypeInfo;
  
  IGRchar buf[128];
  
  // Store it
  if (nodeID == NULL) goto wrapup;
  activeNodeID = *nodeID;
  
  // Get the tree to which it belongs
  vdct1$GetTreeForNode(nodeID = nodeID,
		       treeID = &activeTreeID);
  
  // Get the info
  vdct1$GetBaseInfo(objID = nodeID, baseInfo = &baseInfo);
  
  vdfrm$SetText(form   = form,
		gadget = VDCT_FORM_SET_G_TREE_TYPE,
		txt    = baseInfo.setType);
  
  vdfrm$SetText(form   = form,
		gadget = VDCT_FORM_SET_G_TREE_NAME,
		txt    = baseInfo.setName);

  sprintf(buf,"%s %s",baseInfo.setType,baseInfo.setName);

  vdfrm$SetText(form   = form,
		gadget = VDCT_FORM_SET_G_TREE_ACTIVE,
		txt    = buf);
  
  // For the description
  vdct1$GetSetTypeInfo(setType     = baseInfo.setType, 
		       setTypeInfo = &setTypeInfo);

  vdfrm$SetText(form   = form,
		gadget = VDCT_FORM_SET_G_TREE_DESC,
		txt    = setTypeInfo.desc);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ---------------------------------------------
 * Rename a Tree
 */
IGRstat VDct1CmdSetNotifyRenameTree()
{
  IGRstat      retFlag   = 0;
  IGRstat      traceFlag = 0;
  IGRstat      sts       = 0;
  
  Form    form = cmdInfo->set.form;
  
  TVDctBaseInfo    baseInfo;

  TGRid            mgrID;
  TGRid            setID;
  TGRid            setID1;
  

  TVDctSetName     setName;
  TVDctSetType     setType;

  IGRchar          buf[128],msg[128],buf1[128];

  //say hi
  if (traceFlag) printf(">>> VDct1CmdSetNotifyRenameTree \n");

  // get the setID of the Mgr
  vdct1$GetMgrParent(objID = &activeTreeID,
		     outID = &setID);
  // args check
  if (activeTreeID.objid == NULL_OBJID){
    sprintf(msg,"No Active Tree \n\nRename Not Done\n\n");
    sts = VDnotify_box(msg);
    goto wrapup;
  }
  
  // Get The Type
  vdfrm$GetText(form = form, gadget = VDCT_FORM_SET_G_TREE_TYPE, txt = buf);
  strcpy(setType,buf);

  vdfrm$GetText(form = form, gadget = VDCT_FORM_SET_G_TREE_NAME, txt = buf);
  strcpy(setName,buf);    
 

  // Get the manager
  vdct1$GetManager(mgrID = &mgrID);
  if (mgrID.objid == NULL_OBJID) {
    vdfrm$SetStatus(form = form,txt = "No Manager!!!");
    goto wrapup;
  }

  // Get the baseInfo 
  vdct1$GetBaseInfo(objID = &mgrID, baseInfo = &baseInfo);

  // Make sure set does not already exist
  strcpy(baseInfo.setType,setType);
  strcpy(baseInfo.setName,setName);

  vdct1$FindSetByName(baseInfo = &baseInfo,
		      setID    = &setID1);
  
   // if duplicate go to wrapup
  if (setID1.objid != NULL_OBJID) {
    vdfrm$SetStatus(form = form,txt = "Tree Already Exists, Change Name");

    // notify of rejected duplicate
    sprintf(buf,"%s %s \n\nTree Already Exists\n\nSelect a New Name\n\nNot Renamed\n\n",setType,setName);
    sts = VDnotify_box(buf );    
    goto wrapup;
  }  
  
  // Get the baseInfo 
  vdct1$GetBaseInfo(objID = &activeTreeID, baseInfo = &baseInfo);

  // verify if top of tree
  if (strcmp(baseInfo.setName,baseInfo.nodeName)) {
    sprintf(msg,"Select a Tree \n\nRename Not Done");
    sts = VDnotify_box(msg);    
    goto wrapup;
  }

  // Get the info from the form
  vdfrm$GetText(form   = form,
		gadget = VDCT_FORM_SET_G_TREE_NAME,
		txt    = buf);
 
  // if name is blank
  if (!strcmp(buf,"")) {
    sprintf(msg,"New Name is Blank\n\nRename Not Done\n\n");
    sts = VDnotify_box(msg);   
    goto wrapup;
  }
  // if name is not changed
  if (!strcmp(buf,baseInfo.nodeName)) {
    sprintf(msg,"Duplicate New Name\n\nRename Not Done\n\n");
    sts = VDnotify_box(msg);   
    goto wrapup;
  }
  // if name is not a valid name to make
  sts = vdct1$IsFirstLetterOK(test = buf);
  
  if (!sts) {
    sprintf(msg,"New Name Invalid\n\nRename Not Done\n\n");
    sts = VDnotify_box(msg);   
    goto wrapup;
  }
  

  // Verify if active Tree is to be renamed by popup
  sprintf(msg,"Rename to: %s %s",baseInfo.nodeType,buf);
  if (GRconfirm_box(msg) != 1) goto wrapup;

  //rename the Tree Top Node
  strcpy(baseInfo.setName,buf);
  strcpy(baseInfo.nodeName,buf);
  vdct1$SetBaseInfo(objID = &activeTreeID, baseInfo = &baseInfo); 
     
  // Clear up the Tree form Msg box
  sprintf(buf1,"Renamed Tree: %s.%s",setType,setName);
  vdfrm$SetStatus(form   = form,
		  txt    = buf1);

  // Get the Mgr baseInfo 
  vdct1$GetBaseInfo(objID = &setID, baseInfo = &baseInfo);  

  // rename the Mgr object  
  strcpy(baseInfo.setName,buf);
  strcpy(baseInfo.nodeName,buf);
  vdct1$SetBaseInfo(objID = &setID, baseInfo = &baseInfo);  

  // Go out and change the name of the children
  VDct1ChangeNodeSetName(&activeTreeID,buf);

  // Tell the world
  VDct1CmdMgrDeletedTree(&activeTreeID);  
  
  // Success
  retFlag = 1;

  // oh well
wrapup:

  // say bye
  if (traceFlag) printf("<<< VDct1CmdSetNotifyRenameTree %d\n",retFlag);
  return retFlag;
}

/* ----------------------------------------
 * Delete a tree 
 */
IGRstat VDct1CmdSetNotifyDeleteTree()
{
  IGRlong	sts = MSSUCC ;
  IGRstat retFlag = 0;
  IGRchar buf[80];
  IGRchar msg[80];
  
  Form    form = cmdInfo->set.form;

  TGRid   setID;

  // Need the actual set parent
  vdct1$GetMgrParent(objID = &activeTreeID,
		     outID = &setID);
  if (setID.objid == NULL_OBJID){
    // notify of problem
    vdfrm$SetStatus(form = form, txt = "Need to select a tree first.");
    sprintf(buf,"No Active Tree\n\nSelect an Active Tree\n\n");
    VDnotify_box(buf);
    goto wrapup;
  }

  // start the message for Deletion Box
  strcpy(buf,"Delete? : ");

  // get the active tree data
  vdfrm$GetText(form = form, gadget = VDCT_FORM_SET_G_TREE_ACTIVE, txt = msg);
  strcat(buf,msg);

  // Confirm if Deletion is to be done if no goto wrapup
  if( GRconfirm_box(buf) != TRUE )goto wrapup;

  // Clear up the Tree form Msg box
  sprintf(buf,"Deleted Tree: %s",msg);
  vdfrm$SetStatus(form   = form,
		  txt    = buf);

  // Delete it
  vdct1$DeleteNode(nodeID = &setID);

  // Tell the world
  VDct1CmdMgrDeletedTree(&activeTreeID);
  
  // Just to make sure
  activeTreeID.objid = NULL_OBJID;
  
  // Done
  return retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ----------------------------------------
 * Create a tree 
 */
IGRstat VDct1CmdSetNotifyCreateTree()
{
  VDASSERT_FN("VDct1CmdSetNotifyCreateTree");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  Form    form = cmdInfo->set.form;

  TGRid   mgrID, mgrID1;
  TGRid   setIDx, setID1;
  TGRid   nodeID;
  
  TVDct1JD setJD;
  TVDct1JD mgrJD;
  
  TVDctBaseInfo baseInfo;
  TVDctBaseInfo baseInfox;

  IGRchar setName[64];
  IGRchar setType[64];
  
  IGRchar buf[128], location[128];
  IGRchar msg[128];
  
  // Get The Type
  vdfrm$GetText(form = form, gadget = VDCT_FORM_SET_G_TREE_TYPE, txt = setType);  
  if (*setType == 0) {
    sprintf(msg,"Enter Tree Type");
    vdfrm$SetStatus(form = form,txt = msg);
    VDnotify_box(msg);   
    goto wrapup;
  }
  // Get the class pointer
  setJD.cl = VDct1GetTreeClassForSetType(setType);
  VDASSERTW(setJD.cl);
  setJD.id.objid = NULL_OBJID;
  ex$get_cur_mod(osnum = &setJD.id.osnum);
 
  // Get the name
  vdfrm$GetText(form = form, gadget = VDCT_FORM_SET_G_TREE_NAME, txt = setName);
  if (*setName == 0) {
    sprintf(msg,"Enter Tree Name");
    vdfrm$SetStatus(form = form,txt = msg);
    VDnotify_box(msg);   
    goto wrapup;
  }
#if 0
  // if name is not a valid name to make
  sts = vdct1$IsFirstLetterOK(test = buf);
  
  if (!sts) {
    sprintf(msg,"Tree Name Invalid\n\nNew Tree Not Made\n\n");
    sts = VDnotify_box(msg);   
    goto wrapup;
  }  
#endif

  // check if it is ok to make this file
#if 0
  sts = VDct1CmdSetFileAccessOK(&setType);
  if(!(sts &1)) {
    strcpy(buf,"This Tree is not used\n\nIn this File\n");
    sts = vdct1$CmdNodeMsgBox(msg = buf);
    goto wrapup;
  }
#endif

#if 0
  // Make sure set does not already exist  
  strcpy(baseInfo.setType,setType);
  strcpy(baseInfo.setName,setName);

  vdct1$FindSetByName(baseInfo = &baseInfo,
		      setID    = &setID1);
  
   // if duplicate go to wrapup
  if (setID1.objid != NULL_OBJID) {
    vdfrm$SetStatus(form = form,txt = "Tree Already Exists, Change Name");

    // notify of rejected duplicate
    sprintf(buf,"%s %s \n\nDuplicate Not Made",setType,setName);
    sts = VDnotify_box(buf );    
    goto wrapup;
  }
#endif

  // Validate the name
  sts = _RTCJDB(&setJD)->
    isSetNameValid(&setJD,setType,setName,msg);

  if (!(sts & 1)) {
    vdfrm$SetStatus(form = form,txt = msg);
    sts = VDnotify_box(msg);    
    goto wrapup;
  }
  
  // Get the manager
  mgrJD = setJD;
  _RTCJDB(&mgrJD)->getManager(&mgrJD);
  VDASSERTW(mgrJD.id.objid != NULL_OBJID);
  
  // Create it
  _RTCJDB(&mgrJD)->createSet(&mgrJD,setType,NULL,setName,&setJD);
  if (setJD.id.objid == NULL_OBJID) {
    vdfrm$SetStatus(form = form,txt = "Tree Creation Failed");
    goto wrapup;
  }

  // Status
  sprintf(buf,"Created Tree %s.%s",setType,setName);
  vdfrm$SetStatus(form = form,txt = buf);
  vdfrm$SetText  (form = form, gadget = VDCT_FORM_SET_G_TREE_TYPE, txt = setType);  
  vdfrm$SetText  (form = form, gadget = VDCT_FORM_SET_G_TREE_NAME, txt = setName);  

  // Tell the manager
  VDct1CmdMgrCreatedTree(&setJD.id);
    
  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* --------------------------------------
 * User changed set type
 */
IGRstat VDct1CmdSetNotifyType()
{
  IGRstat retFlag = 0;
  IGRchar buf[128],*p;

  Form form = cmdInfo->set.form;
 
  // Get type and desc
  vdfrm$GetText(form   = form,
                gadget = VDCT_FORM_SET_G_TREE_TYPE,
                txt    = buf);

  // Clean up type
  p = strchr(buf,' ');
  if (p) *p = NULL;
  vdfrm$SetText(form   = form,
                gadget = VDCT_FORM_SET_G_TREE_TYPE,
                txt    = buf);

  // Clean desc
  if (p == NULL) *buf = 0;
  else {
    for(p++; *p == ' '; p++);
    strcpy(buf,p);
  }
  vdfrm$SetText(form   = form,
                gadget = VDCT_FORM_SET_G_TREE_DESC,
                txt    = buf);

  retFlag = 1;

  return retFlag;
}

/* --------------------------------------------------------
 * Look through config directories for list of sets
 */
FILE *VDct1CmdSetOpenListOfSets()
{
  IGRint i;
  IGRchar buf[DI_PATH_MAX];
  FILE *file;

  // Look in local directory
  file = fopen("sets.txt","rt");
  if (file) return file;
  
  // Look in config directory
  for(i = 0; 1; i++) {
    
    // Product specific loading
    *buf = 0;
    ex$get_path( index = i,
		 path  = buf,
		 len   = sizeof(buf),
		 type  = EX_CONFIG_PATH );
    if (*buf == 0) {
      file = NULL;
      return file;
    }
   
    strcat(buf,"config/sets/sets.txt");
    //printf("Directory for Sets.txt file is [%s]\n",buf);
    
    file = fopen(buf,"rt");
    if (file != NULL) return file;
  }
}

/* --------------------------------------------------
 * Fills in list of available set types
 * 18 July 2000 - Tree Interface
 */
IGRstat VDct1CmdSetFillTypes()
{
  IGRstat retFlag = 0;
  IGRint  row;
  IGRchar buf[128],*p;
  FILE   *file;

  Form   form   = cmdInfo->set.form;
  IGRint gadget = VDCT_FORM_SET_G_TREE_TYPE;

  TVDctSetTypeInfo setTypeInfo;

  TVDct1JD setJD;
  IGRint   i;
  
  // Init
  traceFlag = 0;
  
  if (traceFlag) printf(">>> VDct1CmdSetFillTypes\n");

  vdfrm$SetListNumRows(form = form, gadget = gadget, rows = 0);
  vdfrm$SetText       (form = form, gadget = gadget, txt  = "");

  // Tree interface
  row = 0;
  setJD.id.objid = NULL_OBJID;
  for(i = 0; setJD.cl = VDct1GetTreeClassForNth(i); i++) {

    _RTCJDB(&setJD)->getSetTypeInfo(&setJD,&setTypeInfo);

    sprintf(buf,"%-10s %s",setTypeInfo.type,setTypeInfo.desc);
    vdfrm$SetListText(form   = form, 
		      gadget = gadget, 
		      row    = row, 
		      txt    = buf);
    row++;
    
  }
  if (1) return 1;
  
  // Open the list of sets
  file = VDct1CmdSetOpenListOfSets();
  if (file == NULL) {
    printf("*** sets.txt not found\n");
    goto wrapup;
  }
  
  row = 0;

  // Cycle through
  while(fgets(buf,sizeof(buf),file)) {

    if (!strncmp(buf,"S ",2)) {

      strcpy(buf,buf+2);
      for(p = buf; *p > ' '; p++); *p = 0;
      if (*buf) {
	//printf("Get Set Type %s\n",buf);
	
        vdct1$GetSetTypeInfo(setType = buf, setTypeInfo = &setTypeInfo);
        if (*setTypeInfo.type) {

          sprintf(buf,"%-10s %s",setTypeInfo.type,setTypeInfo.desc);
          vdfrm$SetListText(form   = form, 
                            gadget = gadget, 
                            row    = row, 
                            txt    = buf);
          row++;
        }
      }
    }
  }
  fclose(file);

  // Done
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< VDct1CmdSetFillTypes\n");
  return retFlag;
}

/* -------------------------------------------
 * The notification routine
 */
IGRstat VDct1CmdSetNotifyForm()
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRstat traceFlag = 0;
  
  
  // Process it
  if (traceFlag) printf(">>> VDct1CmdSetNotifyForm\n");
  switch(cmdInfo->gadget) {

  case VDCT_FORM_SET_G_TREE_TYPE:
    VDct1CmdSetNotifyType();
    break;

  case FI_EXECUTE:
    sts = VDct1CmdSetNotifyDoit();
    break;

  case FI_ACCEPT:
    sts = VDct1CmdSetNotifyDoit();
    if (sts & 1) {
      vdfrm$EraseForm(form =  cmdInfo->set.form, 
		      flag = &cmdInfo->set.displayed);
    }
    break;
        
  case FI_CANCEL:
    vdfrm$EraseForm(form =  cmdInfo->set.form, 
                    flag = &cmdInfo->set.displayed);
    break;
  }
  retFlag = 1;

//wrapup:
  if (traceFlag) printf("<<< VDct1CmdSetNotifyForm\n");
  return retFlag;
}

/* --------------------------------------
 * Called when user pushes an open button
 */
IGRstat VDct1CmdSetActivateForm()
{
  IGRstat retFlag = 0;

  // Ignore if already active for now
  if (cmdInfo->set.displayed) {
    retFlag = 1;
    goto wrapup;
  }
  if (traceFlag) printf(">>> VDct1CmdSetActivateForm\n");

  // Display
  vdfrm$DisplayForm(form =  cmdInfo->set.form, 
                    flag = &cmdInfo->set.displayed);

  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< VDct1CmdSetActivateForm\n");
  return retFlag;
}

/* --------------------------------------------------------
 * Called on startup
 */
IGRstat VDct1CmdSetInit(TVDct1CmdInfo *a_cmdInfo)
{
  IGRstat retFlag = 0;

  traceFlag = VDdbgGetTraceFlag(42);

  cmdInfo = a_cmdInfo;
  activeNodeID.objid = NULL_OBJID;
  activeTreeID.objid = NULL_OBJID;

  VDct1CmdSetFillTypes();
  retFlag = 1;

  return retFlag;
}

/* --------------------------------------------------------
 * Rename the setName attr of all the children
 */
IGRstat  VDct1ChangeNodeSetName(TGRid *nodeID,IGRchar *setName)
{
  IGRstat          retFlag     = 0;
  IGRstat          traceFlag   = 0;
  IGRint           i;
  
  TVDctBaseInfo    baseInfo;
  TGRid            childID;

  // arg check
  if (setName == NULL) goto wrapup;
  if (nodeID  == NULL) goto wrapup;
  
  // say hi
  if (traceFlag) printf(">>> VDct1ChangeNodeSetName \n");

  // Get the baseInfo 
  vdct1$GetBaseInfo(objID = nodeID, baseInfo = &baseInfo);

  //rename the Node
  strcpy(baseInfo.setName,setName);
  vdct1$SetBaseInfo(objID = nodeID, baseInfo = &baseInfo); 

  // Now do the kids
  for(i = 0; vdct1$GetTree1Child(objID = nodeID, nth = i, outID = &childID); i++) {
    VDct1ChangeNodeSetName(&childID,setName);
    if (traceFlag) printf("child ID  setName = %s\n",setName);
  }

  // success
  retFlag = 1;

  // oh well
wrapup:

  // say bye
  if (traceFlag) printf("<<< VDct1ChangeNodeSetName %d\n",retFlag);  
  return retFlag;
}


/* --------------------------------------------------------
 * Standard event handlers
 */
#argsused
IGRstat VDct1CmdSetCreatedTree(TGRid *treeID)
{
  return 1;
}
#argsused
IGRstat VDct1CmdSetDeletedTree(TGRid *treeID)
{
  return 1;
}
#argsused
IGRstat VDct1CmdSetRenamedTree(TGRid *treeID)
{  
  return 1;
}
#argsused
IGRstat VDct1CmdSetCreatedNode(TGRid *nodeID)
{  
  return 1;
}
#argsused
IGRstat VDct1CmdSetDeletedNode(TGRid *nodeID,TGRid *parentID)
{  
  return 1;
}

#argsused
IGRstat VDct1CmdSetRenamedNode(TGRid *nodeID)
{  
  return 1;
}

end implementation VDct1Base;








