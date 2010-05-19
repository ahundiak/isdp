/* $Id: VDct1Test.c,v 1.1 2001/01/14 16:01:21 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct/cmd/Vct1Mgr.C
 *
 * Description: Main Forms Manager
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Test.c,v $
 *      Revision 1.1  2001/01/14 16:01:21  art
 *      sp merge
 *
 * Revision 1.7  2000/12/08  20:51:12  pinnacle
 * ah
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/25/00  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDfrmc.h"
#include "VDdom.h"
#include "VDctx.h"

#include "VDct1Cmdx.h"
#include "VDct1Forms.h"
#include "VDct1Tree.h"
#include "VDct1Tree2.h"
#include "VDct1Plot.h"

// #include "VDobj.h"

#include "VDassert.h"

VDASSERT_FFN("vdct1/cmd/VDct1Test.C");

/* -----------------------------------------------
 * Stick with the idea of using static local data for now
 */
static TVDct1CmdInfo *cmdInfo;

IGRstat VDct1CmdTestCreateTree(IGRchar *set_type, IGRchar *set_name);

IGRstat VDct1FormFindTreeRow(Form treeForm, IGRint gadget, TGRid *nodeID, IGRint *row)
{
  *row = 0;
  return 0;
}

/* -----------------------------------------------
 * Test the create node
 * The PARENT button on the node form is already displayed
 * The node form itself is assumed to be displayed
 * 
 */
IGRstat VDct1CmdTestCreateNode(IGRchar *nodeType, IGRchar *nodeName)
{
  VDASSERT_FN("VDct1CmdTestCreateNode");
  IGRstat retFlag = 0;
  IGRstat sts;
  
  Form nodeForm;
  
  IGRchar buf[128],*p;
  
  // Create a node
  nodeForm = cmdInfo->node.form;

  VDfrmSetgText(nodeForm,VDCT_FORM_NODE_G_DOIT,"2 CREATE NODE");
  VDfrmSetgText(nodeForm,VDCT_FORM_NODE_G_EDIT_NODE_TYPE,nodeType);
  VDfrmSetgText(nodeForm,VDCT_FORM_NODE_G_EDIT_NODE_NAME,nodeName);

  VDct1CmdNotifyRootLocate(nodeForm,FI_EXECUTE,NULL);

  // Test that it actually worked
  VDfrmGetSts(nodeForm,buf);
  p = strstr(buf,"Created Node");
  VDASSERTW(p);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Test the activation of a tree set by selecting its
 * Top node in the tree form
 *
 * Tree can be in reference file
 */
IGRstat VDct1CmdTestTreeActivation(IGRchar *setType, IGRchar *setName)
{
  VDASSERT_FN("VDct1CmdTestTreeActivation");
  IGRstat retFlag = 0;
  IGRstat sts;

  TVDct1JD workJD;
  TVDct1JD treeJD;

  Form treeForm;
  IGRint gadget = VDCT_FORM_TREE_G_TREE;
  
  IGRint row;
  
  // Make sure such a tree exists
#if 0
  workJD.cl = VDct1GetRootTreeClass();
  workJD.id.objid = NULL_OBJID;

  VDjt1FindTreeByTypeName(&workJD,0,VDCT1_FIND_SET_OPT_ALL_FILES,
			  setType,setName,&treeJD);
  VDASSERTW(treeJD.id.objid != NULL_OBJID);
#endif
  
  // Find the tree row
  treeForm = cmdInfo->tree.form;
  VDct1FormFindTreeRow(treeForm,gadget,&treeJD.id,&row);
  VDASSERTW(row >= 0);
  
  // Poke It
  VDfrmSetActiveRow(treeForm,gadget,row,row);
  VDfrmSetSelect   (treeForm,gadget,row,4,1);

  // Process it
  VDct1CmdNotifyRootLocate(treeForm,gadget,NULL);

  // Tell about it
  // vdobj$Print(objID = &treeJD.id);
  // printf("Row %d\n",row);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Plot Tree Testing
 */
IGRstat VDct1CmdTestPlotTree()
{
  VDASSERT_FN("VDct1CmdTestPlotTree");
  IGRstat retFlag = 0;
  IGRstat sts;
  
  Form nodeForm;
  
  // Arg check
  VDASSERTW(cmdInfo);
  
  // Say Hi
  // traceFlag = 1;
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  // Create the tree
  sts = VDct1CmdTestCreateTree(VDCT1_TREE_TYPE_PLOT_TREE,"Plot1");
  VDASSERTW(sts & 1);

  // Pop up the node form
  VDct1CmdNotifyRootLocate(cmdInfo->mgr.form,VDCT_FORM_MGR_B_NODES,NULL);

  // Push the parent button
  VDct1CmdNotifyRootLocate(cmdInfo->node.form,VDCT_FORM_NODE_B_PARENT_NODE,NULL);

  // Create a few nodes
  sts = VDct1CmdTestCreateNode(VDCT1_PLOT_NODE_TYPE_SHEET,"Sht01");
  VDASSERTW(sts & 1);
  sts = VDct1CmdTestCreateNode(VDCT1_PLOT_NODE_TYPE_SHEET,"Sht02");
  VDASSERTW(sts & 1);
  sts = VDct1CmdTestCreateNode(VDCT1_PLOT_NODE_TYPE_SHEET,"Sht03");
  VDASSERTW(sts & 1);

  // Try a dup
  //sts = VDct1CmdTestCreateNode(VDCT1_PLOT_NODE_TYPE_SHEET,"Sht03");
  // VDASSERTW(!(sts & 1));
  
  // hide the node form
  VDct1CmdNotifyRootLocate(cmdInfo->node.form,FI_CANCEL,NULL);
  
  // Done
  retFlag = 1;
  
 wrapup:

  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
   return retFlag;
}

/* -----------------------------------------------
 * Test the create node
 * The PARENT button on the node form is already displayed
 * The node form itself is assumed to be displayed
 * 
 */
IGRstat VDct1CmdTestGenerateModelNodes()
{
  VDASSERT_FN("VDct1CmdTestGenerateModelNodes");
  IGRstat retFlag = 0;
  IGRstat sts;
  
  Form nodeForm;
  
  IGRchar buf[128],*p;
  
  TGRobj_env  modelOE;
  
  // Create a node
  nodeForm = cmdInfo->node.form;

  VDfrmSetgText(nodeForm,VDCT_FORM_NODE_G_DOIT,"4 GENERATE MODEL NODES");

  // start throwing it some objects
  modelOE.obj_id.objid = 4389;
  modelOE.obj_id.osnum = 2;
  
  VDct1CmdNotifyRootLocate(NULL,NULL,&modelOE);

  // object with pal_group,compt, and wieght
  modelOE.obj_id.objid = 371;
  VDct1CmdNotifyRootLocate(NULL,NULL,&modelOE);

  // object with pal_group, compt, null weight
  modelOE.obj_id.objid = 6431;
  VDct1CmdNotifyRootLocate(NULL,NULL,&modelOE);

  // object with NULL pal_group, compt, null wieght
  modelOE.obj_id.objid = 1009;
  VDct1CmdNotifyRootLocate(NULL,NULL,&modelOE);

  // object with pal_group T, null compt, null wieght
  modelOE.obj_id.objid = 5061;
  VDct1CmdNotifyRootLocate(NULL,NULL,&modelOE);

  // object with null everything
  modelOE.obj_id.objid = 842;
  VDct1CmdNotifyRootLocate(NULL,NULL,&modelOE);

  // Test that it actually worked
  VDfrmGetSts(nodeForm,buf);
  p = strstr(buf,"Created Node");
  VDASSERTW(p);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Ready to test
 */
IGRstat VDct1CmdTestCreateCableTree()
{
  VDASSERT_FN("VDct1CmdTestCreateCableTree");
  IGRstat retFlag = 0;
  IGRstat sts;
  
  Form mgrForm;
  Form setForm;

  IGRchar buf[128],*p;
  
  // Arg check
  VDASSERTW(cmdInfo);
  
  // Say Hi
  traceFlag = 1;
  
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  // Push the New Tree Button
  mgrForm = cmdInfo->mgr.form;
  VDct1CmdNotifyRootLocate(mgrForm,VDCT_FORM_MGR_B_SETS,NULL);

  // Create a tree
  setForm = cmdInfo->sets.form;

  VDfrmSetgText(setForm,VDCT_FORM_SET_G_DOIT,"2 CREATE TREE");
  VDfrmSetgText(setForm,VDCT_FORM_SET_G_TREE_TYPE,VDCT1_TREE_TYPE_CABLE_TREE);
  VDfrmSetgText(setForm,VDCT_FORM_SET_G_TREE_NAME,"62-01-003");

  VDct1CmdNotifyRootLocate(setForm,FI_EXECUTE,NULL);

  // Test that it actually worked
  VDfrmGetSts(setForm,buf);
  p = strstr(buf,"Created Tree");
  VDASSERTW(p);
  
  // See if one was created
  sts = VDct1CmdTestTreeActivation(VDCT1_TREE_TYPE_CABLE_TREE,"62-01-003");
  VDASSERTW(sts & 1);
  
  // Hide the set form
  VDct1CmdNotifyRootLocate(setForm,FI_CANCEL,NULL);

  // Done
  retFlag = 1;
  
 wrapup:

  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
   return retFlag;
}

/* -----------------------------------------------
 * Cable Tree Testing
 */
IGRstat VDct1CmdTestCableTree()
{
  VDASSERT_FN("VDct1CmdTestCableTree");
  IGRstat retFlag = 0;
  IGRstat sts;
  
  Form nodeForm;
  
  // Arg check
  VDASSERTW(cmdInfo);
  
  // Say Hi
  traceFlag = 1;
  
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  // Create the tree
  sts = VDct1CmdTestCreateCableTree();
  VDASSERTW(sts & 1);

  // Pop up the node form
  VDct1CmdNotifyRootLocate(cmdInfo->mgr.form,VDCT_FORM_MGR_B_NODES,NULL);

  // Push the parent button
  VDct1CmdNotifyRootLocate(cmdInfo->node.form,VDCT_FORM_NODE_B_PARENT_NODE,NULL);

  // Generate a few nodes
  sts = VDct1CmdTestGenerateModelNodes();
  VDASSERTW(sts & 1);
  
  // Done
  retFlag = 1;
  
 wrapup:

  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
   return retFlag;
}

/* -----------------------------------------------
 * Create a tree of the given type,name
 */
IGRstat VDct1CmdTestCreateTree(IGRchar *set_type, IGRchar *set_name)
{
  VDASSERT_FN("VDct1CmdTestCreateTree");
  IGRstat retFlag = 0;
  IGRstat sts;
  
  Form mgrForm;
  Form setForm;

  IGRchar buf[128],*p;
  
  // Arg check
  VDASSERTW(cmdInfo);
  
  // Say Hi
  traceFlag = traceFlagx;
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  // Push the New Tree Button
  mgrForm = cmdInfo->mgr.form;
  VDct1CmdNotifyRootLocate(mgrForm,VDCT_FORM_MGR_B_SETS,NULL);

  // Create a tree
  setForm = cmdInfo->sets.form;

  VDfrmSetgText(setForm,VDCT_FORM_SET_G_DOIT,"2 CREATE TREE");
  VDfrmSetgText(setForm,VDCT_FORM_SET_G_TREE_TYPE,set_type);
  VDfrmSetgText(setForm,VDCT_FORM_SET_G_TREE_NAME,set_name);

  VDct1CmdNotifyRootLocate(setForm,FI_EXECUTE,NULL);

  // Test that it actually worked
  VDfrmGetSts(setForm,buf);
  p = strstr(buf,"Created Tree");
  VDASSERTW(p);
  
  // See if one was created
  sts = VDct1CmdTestTreeActivation(set_type,set_name);
  VDASSERTW(sts & 1);
  
  // Hide the set form
  VDct1CmdNotifyRootLocate(setForm,FI_CANCEL,NULL);

  // Done
  retFlag = 1;
  
 wrapup:

  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
   return retFlag;
}

/* -----------------------------------------------
 * Cable Tree Testing
 */
IGRstat VDct1CmdTestStdPartsTree()
{
  VDASSERT_FN("VDct1CmdTestStdPartsTree");
  IGRstat retFlag = 0;
  IGRstat sts;
  
  Form  mgrForm;
  Form nodeForm;
  Form treeForm;
  Form attrForm;
  
  IGRint gadget = VDCT_FORM_TREE_G_TREE;
  IGRint row;
  
  // Arg check
  VDASSERTW(cmdInfo);
  
  // Say Hi
  traceFlag = traceFlagx;
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  // Create the tree
  VDASSERTW(VDct1CmdTestCreateTree(VDCT1_TREE_TYPE_STD_PARTS,"STD_PARTS1") & 1);
  treeForm = cmdInfo->tree.form;

  // Expand noun names
  VDfrmSetActiveRow(treeForm,gadget,0,0);
  VDfrmSetSelect   (treeForm,gadget,0,1,1);
  VDct1CmdNotifyRootLocate(treeForm,gadget,NULL);

  // Expand A's
  VDfrmSetActiveRow(treeForm,gadget,1,1);
  VDfrmSetSelect   (treeForm,gadget,1,1,1);
  VDct1CmdNotifyRootLocate(treeForm,gadget,NULL);

  // Expand First A
  VDfrmSetActiveRow(treeForm,gadget,2,2);
  VDfrmSetSelect   (treeForm,gadget,2,1,1);
  VDct1CmdNotifyRootLocate(treeForm,gadget,NULL);

  // Push the OPS and ATTR Button
  mgrForm = cmdInfo->mgr.form;
  VDct1CmdNotifyRootLocate(mgrForm,VDCT_FORM_MGR_B_PART, NULL);
  VDct1CmdNotifyRootLocate(mgrForm,VDCT_FORM_MGR_B_ATTRS,NULL);

  // Pick first part
  VDfrmSetActiveRow(treeForm,gadget,3,3);
  VDfrmSetSelect   (treeForm,gadget,3,4,1);
  VDct1CmdNotifyRootLocate(treeForm,gadget,NULL);

  // Update an attribute
  attrForm = cmdInfo->attr.form;
  VDfrmSetfText(attrForm,VDCT_FORM_ATTR_L_ATTRS,1,VDCT_FORM_ATTR_L_ATTRS_COL_VALUE,"Changed");
  VDct1CmdNotifyRootLocate(attrForm,FI_EXECUTE,NULL);

  // Cycle
  VDfrmSetActiveRow(treeForm,gadget,4,4);
  VDfrmSetSelect   (treeForm,gadget,4,1,1);
  VDct1CmdNotifyRootLocate(treeForm,gadget,NULL);

  VDfrmSetActiveRow(treeForm,gadget,3,3);
  VDfrmSetSelect   (treeForm,gadget,3,1,1);
  VDct1CmdNotifyRootLocate(treeForm,gadget,NULL);

  // Pop up database form
  VDct1CmdNotifyRootLocate(mgrForm,VDCT_FORM_MGR_B_DBTBL,NULL);
  VDct1CmdNotifyRootLocate(cmdInfo->dbtbl.form,FI_EXECUTE,NULL);
  system("sleep 3");
  VDct1CmdNotifyRootLocate(cmdInfo->dbtbl.form,FI_CANCEL,NULL);

  // Pop up status form
  VDct1CmdNotifyRootLocate(mgrForm,VDCT_FORM_MGR_B_FREE,NULL);
  
  // Done
  retFlag = 1;
  
 wrapup:

  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
   return retFlag;
}

/* -----------------------------------------------
 * Ready to test
 */
IGRstat VDct1CmdTest1(IGRint num)
{
  VDASSERT_FN("VDct1CmdTest1");
  IGRstat retFlag = 0;
  IGRstat sts;
  
  Form mgrForm;
  Form setForm;
  
  // Arg check
  VDASSERTW(cmdInfo);
  
  // Test Mode
  cmdInfo->isTest = 1;
  
  // Say Hi
  // traceFlag = 1;
  
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }

  switch(num) {
    case 1:
      VDASSERTW(VDct1CmdTestPlotTree() & 1);
      break;

    case 2:
      VDASSERTW(VDct1CmdTestCableTree() & 1);
      break;

    case 3:
      VDASSERTW(VDct1CmdTestStdPartsTree() & 1);
      break;
      
  }
  
    
  // Done
  retFlag = 1;
  
 wrapup:

  if (cmdInfo) cmdInfo->isTest = 0;
  
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/* -----------------------------------------------
 * Master init routine
 */
IGRstat VDct1CmdInitTest(TVDct1CmdInfo *a_cmdInfo)
{
  VDASSERT_FN("VDct1CmdInitTest");
  IGRstat retFlag = 0;
  IGRstat sts;
  
  // Arg check
  VDASSERTW(a_cmdInfo);
  
  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  // Set the statics
  cmdInfo = a_cmdInfo;
  
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/* -----------------------------------------------
 * Load in a test xml file
 */
IGRstat VDct1CmdTestLoadXml()
{
  VDASSERT_FN("VDct1CmdLoadXml");
  IGRstat retFlag = 0;
  
  TGRid treeID,setID,mgrID;

  // Say Hi
  if (traceFlag) printf(">>> %s\n",fn);
  
  // Make sure initted
  VDdomInitSystem(0,0,0);

  // Get the manager
  VDdomGetMgr(NULL_OSNUM,1,&mgrID);
  VDASSERTW(mgrID.objid != NULL_OBJID);

  // Have any sets?
  VDctxGetNthMgrChild(NULL,&mgrID,0,&setID);
  if (setID.objid != NULL_OBJID) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Make a test xml tree
  VDdomCreateTreeFromXmlFile("test1.xml",&treeID);
  VDASSERTW(treeID.objid != NULL_OBJID);

  // Change it to a set and hook to the manager
  VDdomConvertToSetObj(&treeID);
  
  VDdomAppendChildObj(&mgrID,&treeID);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}
