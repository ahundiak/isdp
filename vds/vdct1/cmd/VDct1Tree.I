/* $Id: VDct1Tree.I,v 1.2 2001/01/11 22:03:42 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/cmd/VDct1Tree.I
 *
 * Description: Tree Command
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Tree.I,v $
 *      Revision 1.2  2001/01/11 22:03:42  art
 *      sp merge
 *
# Revision 1.4  2000/07/18  19:32:20  pinnacle
# ah
#
# Revision 1.3  2000/05/31  13:38:10  pinnacle
# Replaced: vds/vdct1/cmd/VDct1Tree.I for:  by pnoel for Service Pack
#
# Revision 1.2  2000/05/23  18:30:44  pinnacle
# Replaced: vds/vdct1/cmd/VDct1Tree.I for:  by pnoel for Service Pack
#
# Revision 1.1  2000/04/20  18:37:26  pinnacle
# Created: vds/vdct1/cmd/VDct1Tree.I by pnoel for Service Pack
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
 * 06/17/99  ah      creation
 * 01/10/00  pn      updated controls/safeops
 * 05/23/00  pn      updated tree display controls
 * 05/31/00  pn      installed Tree/Lib form view controls
 ***************************************************************************/
class implementation VDct1Base;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDfrm.h"
#include "VDsa.h"
#include "VDppl1.h"

#include "VDct1.h"
#include "VDct1Tree.h"
#include "VDct1Forms.h"

#include "VDct1Cmd.h"
#include "VDct1CmdTree.h"

static int traceFlag;
static TVDct1CmdInfo *cmdInfo;
static TGRid activeNodeID;
extern IGRstat VDct1FormFindTreeRow(Form    form, 
				    IGRint  gadget, 
				    TGRid  *workID, 
				    IGRint *rowFound);

extern IGRstat VDct1FormRefreshNodeName(Form    form, 
					IGRint  gadget, 
					IGRint  row, 
					TGRid  *nodeID);

extern IGRstat VDct1FormUpdateVRTree(Form form, IGRint gadget);
extern IGRstat VDct1CmdTreeFillTreeList();
extern IGRstat VDct1CmdTreeDispOpt(IGRint *dispOpt);

/* -------------------------------------------
 * Tree notification routine
 */
IGRstat VDct1CmdTreeNotifyTree()
{
  IGRstat retFlag = 0;
  TGRid   nodeID;
  IGRstat traceFlag = 0;
  
  Form   form   = cmdInfo->tree.form;
  IGRint gadget = VDCT_FORM_TREE_G_TREE;
    
  if (traceFlag) printf(">>> VDct1CmdTreeNotifyTree\n");

  // Standard tree handler
  VDct1FormNotifyTree(form,gadget,&nodeID);
  if (nodeID.objid == NULL_OBJID) goto wrapup;
    
  // Activate It
  VDct1CmdMgrActivateNode(&nodeID);

  // update everybody on the form
  if (traceFlag) printf("going to the new update of all rows\n");
  VDct1FormUpdateVRTree(form,gadget);
    
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< VDct1CmdTreeNotifyTree(%d)\n",retFlag);
  
  return retFlag;
}


/* -------------------------------------------
 * The notification routine
 */
IGRstat VDct1CmdTreeNotifyForm()
{
  IGRstat retFlag = 0;
  IGRstat traceFlag = 0;
  
  // Process it
  if (traceFlag) printf(">>> VDct1CmdTreeNotifyForm\n");
  switch(cmdInfo->gadget) {

  case VDCT_FORM_TREE_G_TREE:
    VDct1CmdTreeNotifyTree();
    break;

  case VDCT_FORM_TREE_G_DISPLAY:
    VDct1CmdTreeFillTreeList();
    break;
    
    
  case FI_CANCEL:
    vdfrm$EraseForm(form =  cmdInfo->tree.form, 
                    flag = &cmdInfo->tree.displayed);
    break;
  }
  retFlag = 1;

//wrapup:
  if (traceFlag) printf("<<< VDct1CmdTreeNotifyForm\n");
  return retFlag;
}

/* --------------------------------------
 * Called when user pushes an open button
 */
IGRstat VDct1CmdTreeActivateForm()
{
  IGRstat retFlag = 0;

  // Ignore if already active for now
  if (cmdInfo->tree.displayed) {
    retFlag = 1;
    goto wrapup;
  }
  if (traceFlag) printf(">>> VDct1CmdTreeActivateForm\n");

  // Display
  vdfrm$DisplayForm(form =  cmdInfo->tree.form, 
                    flag = &cmdInfo->tree.displayed);

  // Done
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< VDct1CmdTreeActivateForm\n");
  return retFlag;
}
/* --------------------------------------
 * Fill in the list of trees for the osnum
 */
IGRstat VDct1CmdTreeFillTreeListForOS(TVDosnum osnum)
{
  IGRstat retFlag = 0;
  IGRstat traceFlag = 0;
  
  IGRstat sts;

  TGRid  mgrID;
  TGRid  setID;

  IGRint  i;

  Form   form   = cmdInfo->tree.form;
  IGRint gadget = VDCT_FORM_TREE_G_TREE;
  
  if (traceFlag) printf(">>> VDct1CmdTreeFillTreeListForOS\n");
  
  // Validate os
  sts = vdos$Validate(osnum = osnum);
  if (!(sts & 1)) goto wrapup;
  retFlag = 1;

  // Get the manager
  vdct1$GetManager(osnum = osnum, mgrID = &mgrID);
  if (mgrID.objid == NULL_OBJID) goto wrapup;

  // Cycle Through
  for(i = 0; vdct$GetMgrChild(objID = &mgrID, nth = i, outID = &setID); i++) {

    VDct1FormAppendTree(form,gadget,&setID);
    
  }
  
wrapup:
  if (traceFlag) printf(">>> VDct1CmdTreeFillTreeListForOS(%d)\n",retFlag);

  return retFlag;
}

/* --------------------------------------
 * Fills in the list of available trees
 */
IGRstat VDct1CmdTreeFillTreeList()
{
  IGRstat retFlag = 0;
  IGRstat traceFlag = 0;
  
  Form    form = cmdInfo->tree.form;
  IGRint  gadget = VDCT_FORM_TREE_G_TREE;
  
  if (traceFlag) printf(">>> VDct1CmdTreeFillTreeList\n");
  
  // This resets the tree form
  VDct1FormAppendTree(form,gadget,NULL);

  // Only show active os trees
  VDct1CmdTreeFillTreeListForOS(2);
  
  retFlag = 1;
   if (traceFlag) printf("<<< VDct1CmdTreeFillTreeList(%d)\n",retFlag); 
  return retFlag;
}

/* --------------------------------------------------------
 * Called on startup
 */
IGRstat VDct1CmdTreeInit(TVDct1CmdInfo *a_cmdInfo)
{
  IGRstat retFlag = 0;
  int     display = 1;

  // Say hi
  traceFlag = 0;
  if (traceFlag) printf(">>> VDct1CmdTreeInit\n");

  // Init
  cmdInfo = a_cmdInfo;
  activeNodeID.objid = NULL_OBJID;
  
  // Init the tree list
  VDct1CmdTreeFillTreeList();
    // set the flag
#if 0
  VDct1CmdTreeDispOpt(&display);
#endif
  // Done
  retFlag = 1;

  if (traceFlag) printf("<<< VDct1CmdTreeInit\n");
  return retFlag;
}

/* ----------------------------------------------------------
 * Standard Callbacks
 */
#argsused
IGRstat VDct1CmdTreeCreatedTree(TGRid *treeID)
{  
  VDct1CmdTreeFillTreeList();
  return 1;
}
#argsused
IGRstat VDct1CmdTreeDeletedTree(TGRid *treeID)
{  
  VDct1CmdTreeFillTreeList();

  // update the summary
  VDct1FormUpdateVRTree(cmdInfo->tree.form, VDCT_FORM_TREE_G_TREE);
 
  return 1;
}
#argsused
IGRstat VDct1CmdTreeRenamedTree(TGRid *treeID)
{  
  VDct1CmdTreeFillTreeList();
  return 1;
}

#argsused
IGRstat VDct1CmdTreeCreatedNode(TGRid *nodeID)
{  
  TGRid parentID;
  
  vdct1$GetTree1Parent(objID = nodeID, outID = &parentID);
  
  VDct1FormUpdateTreeRow(cmdInfo->tree.form, VDCT_FORM_TREE_G_TREE, &parentID);

  // update the summary
  VDct1FormUpdateVRTree(cmdInfo->tree.form, VDCT_FORM_TREE_G_TREE);

  return 1;
}
IGRstat VDct1CmdTreeDeletedNode(TGRid *nodeID, TGRid *parentID)
{  
  // Delete the row
  VDct1FormDeleteTreeRowID(cmdInfo->tree.form, VDCT_FORM_TREE_G_TREE, nodeID);

  // Refresh the parent
  VDct1FormUpdateTreeRow(cmdInfo->tree.form, VDCT_FORM_TREE_G_TREE, parentID);

  // update the summary
  VDct1FormUpdateVRTree(cmdInfo->tree.form, VDCT_FORM_TREE_G_TREE);

  return 1;
}

IGRstat VDct1CmdTreeRenamedNode(TGRid *nodeID)
{ 
  IGRstat    retFlag   = 0;
  IGRstat    traceFlag = 0;
  
  IGRint row;

  if (traceFlag) printf(">>> VDct1CmdTreeRenamedNode\n");

    // args check
  if (nodeID == NULL) goto wrapup;
  
  VDct1FormFindTreeRow(cmdInfo->tree.form,
		       VDCT_FORM_TREE_G_TREE,
		       nodeID,
		       &row);
  if (row < 0) goto wrapup;
  
  VDct1FormRefreshNodeName(cmdInfo->tree.form, 
			   VDCT_FORM_TREE_G_TREE, 
			   row, 
			   nodeID);

  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< VDct1CmdTreeRenamedNode %d\n",retFlag);
  return retFlag;
}

/* -----------------------------------------------
 * Called when a node is activated
 */
IGRstat VDct1CmdTreeActivateNode(TGRid *nodeID)
{  
  IGRstat       retFlag = 0;
  TVDctBaseInfo baseInfo;
  IGRchar       buf[128];

  Form form = cmdInfo->tree.form;
  
  IGRint i;
  TVDct1JD nodeJD;
  
  // Save it
  activeNodeID = *nodeID;

  // Update selected tree name
  vdct1$GetBaseInfo(objID = nodeID, baseInfo = &baseInfo);
  
  // Drop the TREE from the string
  sprintf(buf,"%s %s",baseInfo.setType,baseInfo.setName);
  vdfrm$SetText(form   = form,
		gadget = VDCT_FORM_TREE_G_SET_NAME,
		txt    = buf);

  VDct1CmdFormNotifyFree(&activeNodeID);

  // update the summary
  VDct1FormUpdateVRTree(form, VDCT_FORM_TREE_G_TREE);

  // Update the display pick list
  VDct1CmdResetGadgetList(nodeID,form,VDCT_FORM_TREE_G_DISPLAY,1);
  
  // Done
  retFlag = 1;
  
  return retFlag;
}

end implementation VDct1Base;










