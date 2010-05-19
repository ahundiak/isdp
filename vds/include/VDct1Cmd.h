/* $Id: VDct1Cmd.h,v 1.3 2001/03/12 20:36:02 jdsauby Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDctCmd.h
 *
 * Description: Command Object
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Cmd.h,v $
 *      Revision 1.3  2001/03/12 20:36:02  jdsauby
 *      Cleaned out unnecessary functions from vdct1/set
 *
 *      Revision 1.2  2001/01/09 22:17:07  art
 *      ah
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.10  2000/09/07  18:05:06  pinnacle
 * js
 *
 * Revision 1.9  2000/07/18  19:43:28  pinnacle
 * ah
 *
 * Revision 1.8  2000/07/14  19:10:44  pinnacle
 * pn
 *
 * Revision 1.7  2000/07/12  11:21:08  pinnacle
 * pn
 *
 * Revision 1.2  1999/10/26  17:49:06  pinnacle
 * ah
 *
 * Revision 1.1  1999/06/29  18:16:56  pinnacle
 * ct
 *
 * Revision 1.2  1999/05/30  14:16:46  pinnacle
 * ah
 *
 * Revision 1.1  1999/05/28  12:43:54  pinnacle
 * ct
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/28/99  ah      Creation
 * 10/26/99  ah      Misc  Changes
 * 01/11/00  ah      Pauls Changes
 * 03/10/00  pn      2.6.1.5 Build
 * 03/28/00  pn      Misc Changes
 * 06/30/00  pn      Some new ppl wrappers 
 * 01/09/01  ah      sp merge
 ***************************************************************************/

#ifndef VDct1Cmd_include
#define VDct1Cmd_include

#ifndef   VDahFrm_include
#include "VDahFrm.h"
#endif

// For hilites
#ifndef   dpdef_include
#include "dpdef.h"
#endif

#ifndef   dpmacros_include
#include "dpmacros.h"
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#define VDCT1_MAX_NODE_TYPES 20

typedef struct {
  struct 
  {
    Form   form;
    IGRint displayed;
  } mgr,set,leaf,tree,node,rep,attr,pcmk,rpt,lib,free,part,dbtbl;
  
  // Selected by user
  Form    form;
  IGRint  gadget;
  
  // Misc
  IGRint         inittedOK;
  IGRint         shutdown;
 
  VDclassid      classIDs[16];
  OM_S_CLASSLIST classList;

  // Active set
  TGRid             activeSetID;
  TVDctBaseInfo     activeSetBaseInfo;
  TVDctSetTypeInfo  activeSetTypeInfo;
  
  // Active Node
  TGRid             activeNodeID;
  TVDctBaseInfo     activeNodeBaseInfo;
  
  // Used by the node form to store parent node
  TGRid             parentNodeID;
  TVDctBaseInfo     parentNodeBaseInfo;

  // Used to store deleted node and it's parent
  TGRid             deletedNodeID;
  TGRid             deletedNodeParentID;
  
  // Used to store last node selected by user
  // Might not want to use it
  TGRid lastNodeID;

  // Holds list of node types
  TVDctNodeTypeInfo nodeTypeInfos[VDCT1_MAX_NODE_TYPES];
  IGRint            nodeTypeCnt;
  IGRint            nodeTypeInd;

  // Holds list of attributes being displayed
  TVDfldS displayedFlds;
  
  // Active Library Node ID
  TGRid activeLibNodeID;
  
  // Paste node and attributes
  TGRid   pasteID;
  TVDfldS pasteFlds;
  
} TVDct1CmdInfo;


/* ------------------------------------------------
 * vdct1/cmd/VDct1Mgr.I
 */

extern IGRstat VDct1CmdMgrNotifyObject __((TGRobj_env *setOE));
extern IGRstat VDct1CmdMgrNotifyForm   __(());
extern IGRstat VDct1CmdMgrInit         __((TVDct1CmdInfo *a_cmdInfo));
extern IGRstat VDct1CmdMgrDelete       __(());
extern IGRstat VDct1CmdMgrWakeup       __(());
extern IGRstat VDct1CmdMgrSleep        __(());

extern IGRstat VDct1CmdMgrGetFilter        __(());
extern IGRstat VDct1CmdMgrGetDefaultFilter __(());

extern IGRstat VDct1CmdMgrCreatedTree   __((TGRid *treeID));
extern IGRstat VDct1CmdMgrDeletedTree   __((TGRid *treeID));
extern IGRstat VDct1CmdMgrRenamedTree   __((TGRid *treeID));

extern IGRstat VDct1CmdMgrCreatedNode   __((TGRid *nodeID));
extern IGRstat VDct1CmdMgrDeletedNode   __((TGRid *nodeID, TGRid *parentID));
extern IGRstat VDct1CmdMgrRenamedNode   __((TGRid *nodeID));
extern IGRstat VDct1CmdMgrActivateNode  __((TGRid *nodeID));

extern IGRstat VDct1CmdResetGadgetList  __((TGRid *nodeID, 
					    Form   form, 
					    IGRint gadget,
					    IGRint keepDefault));

/* ------------------------------------------------
 * vdct1/cmd/VDct1Set.I
 */
extern IGRstat VDct1CmdSetNotifyForm   __(());
extern IGRstat VDct1CmdSetActivateForm __(());
extern IGRstat VDct1SetPostTrees       __(());

extern IGRstat VDct1CmdSetInit __((TVDct1CmdInfo *a_cmdInfo));

extern IGRstat VDct1CmdSetCreatedTree   __((TGRid *treeID));
extern IGRstat VDct1CmdSetDeletedTree   __((TGRid *treeID));
extern IGRstat VDct1CmdSetRenamedTree   __((TGRid *treeID));

extern IGRstat VDct1CmdSetCreatedNode   __((TGRid *nodeID));
extern IGRstat VDct1CmdSetDeletedNode   __((TGRid *nodeID, TGRid *parentID));
extern IGRstat VDct1CmdSetRenamedNode   __((TGRid *nodeID));
extern IGRstat VDct1CmdSetActivateNode  __((TGRid *nodeID));

#omdef vdct1$CmdSetActivateNode(nodeID)
VDct1CmdSetActivateNode((nodeID))
#endomdef
/* ----------------------------------------------------------
 * Prints the report for 1 node
 */
extern IGRstat VDct1PrintNodeReport __((TGRid *nodeID, 
					IGRstat seqNum));

#omdef vdct1$PrintNodeReport(nodeID, 
			     seqNum)

VDct1PrintNodeReport((nodeID),
		     (seqNum))
#endomdef
/* ------------------------------------------------
 * vdct1/cmd/VDct1Node.I
 */
extern IGRstat VDct1CmdNodeNotifyForm   __(());
extern IGRstat VDct1CmdNodeActivateForm __(());

extern IGRstat VDct1CmdNodeInit __((TVDct1CmdInfo *a_cmdInfo));

extern IGRstat VDct1CmdNodeCreatedTree   __((TGRid *treeID));
extern IGRstat VDct1CmdNodeDeletedTree   __((TGRid *treeID));
extern IGRstat VDct1CmdNodeRenamedTree   __((TGRid *treeID));

extern IGRstat VDct1CmdNodeCreatedNode   __((TGRid *nodeID));
extern IGRstat VDct1CmdNodeDeletedNode   __((TGRid *nodeID, TGRid *parentID));
extern IGRstat VDct1CmdNodeRenamedNode   __((TGRid *nodeID));
extern IGRstat VDct1CmdNodeActivateNode  __((TGRid *nodeID));
extern IGRstat VDct1CmdChildAttrPresent  __((TGRid   *nodeID,
					     IGRchar *a_attrName,
					     IGRchar *a_attrVal));


/* ----------------------------------------------------------------
 * Supplies the count of nodes and their ID's
 */
extern IGRstat VDct1GetNodeListIDAndCount __((TGRid *nodeID, 
					      TGRid *nodeList, 
					      IGRint *cnt));

#omdef vdct1$GetNodeListIDAndCount(nodeID, 
				   nodeList = NULL, 
				   cnt)

VDct1GetNodeListIDAndCount((nodeID), 
			   (nodeList), 
			   (cnt))
#endomdef
/* ----------------------------------------------------------------
 * Get the range of the objects..
 */
#if 0
extern IGRstat VDct1GetNodeRange __((TGRid *nodeID, GRrange objRange));

#omdef vdct1$GetNodeRange(nodeID,
			  objRange)

VDct1GetNodeRange((nodeID),
		  (objRange))
#endomdef
#endif
/* -------------------------------------------------
 * Checks to see if a Parent type exists above a node
 * checks all the parents
 */
extern IGRstat VDct1CmdParentTypePresent __((TGRid *nodeID,IGRchar *a_nodeType));
#omdef vdct1$CmdParentTypePresent(nodeID,  
				  a_nodeType)
VDct1CmdParentTypePresent((nodeID),
			  (a_nodeType))			    
#endomdef
/* -------------------------------------------
 * wrapper for VDct1CmdAttrPresent
 * sets up the static value to 0 and then kicks off the 
 * test routine to scan for attributes and the set value
 * all the args testing is done in the test routine
 * call this routine for getting attribute status of the kids
 */
extern IGRstat VDct1CmdChildAttrPresent __((TGRid *nodeID,
					    IGRchar *a_attrName,
					    IGRchar *a_attrVal));

#omdef VDct1$CmdChildAttrPresent(nodeID,
				 a_attrName,
				 a_attrVal)
VDct1CmdChildAttrPresent((nodeID),
			 (a_attrName),
			 (a_attrVal))
#endomdef
/* ---------------------------------------------------------------------------
 * Looks up the children of a node and recursively their children and determines
 * if this node has any children of a specific type or name
 * defaults to null name or type,  If null it looks for the other one
 * both null exits. Both present looks for both present at same time
 */
extern IGRstat VDct1CmdNodeNameTypePresent __((TGRid   *nodeID,
					       IGRchar *a_nodeType,
					       IGRchar *a_nodeName));
#omdef vdct1$CmdNodeNameTypePresent(nodeID,
				    a_nodeType = NULL,
				    a_nodeName = NULL)

VDct1CmdNodeNameTypePresent((nodeID),
			    (a_nodeType),
			    (a_nodeName))
#endomdef
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
extern IGRstat VDct1CmdAttrPresent __((TGRid   *nodeID,
				       IGRchar *a_attrName,
				       IGRchar *a_attrVal));
#omdef vdct1$CmdAttrPresent(nodeID,
			    a_attrName,
			    a_attrVal)

VDct1CmdAttrPresent((nodeID),
		    (a_attrName),
		    (a_attrVal))
#endomdef

// Generic Confirm Box only message with choice
extern IGRstat VDct1CmdNodeConfirmBox __((IGRchar *msg));
#omdef vdct1$CmdNodeConfirmBox(msg)
VDct1CmdNodeConfirmBox((msg))
#endomdef

// Generic Notice Box or Construction if NULL
extern IGRstat VDct1CmdNodeMsgBox __((IGRchar *msg));
#omdef vdct1$CmdNodeMsgBox(msg = NULL)
VDct1CmdNodeMsgBox((msg))
#endomdef

// Checks for Duplicates printing msg1 to the node.form and msg2 with
// baseInfo.nodeType and baseInfo.nodeName to a Notice Box.
extern IGRstat VDct1CmdCheckForDuplicate __((TGRid          *nodeID,
					     TGRid          *testID,
					     TVDctBaseInfo  *baseInfo,
					     IGRchar        *msg1,
					     IGRchar        *msg2));

#omdef vdct1$CmdCheckForDuplicate(nodeID,
				  testID = NULL,
				  baseInfo,
				  msg1 = NULL,
				  msg2 = NULL)

VDct1CmdCheckForDuplicate((nodeID),
			  (testID),
			  (baseInfo),
			  (msg1),
			  (msg2))
#endomdef


  /* ------------------------------------------------
   *  Rules control from ppl 
   *  Return is 1 or 0
   *  I - actionType is the test conditon (comparison item)
   *  I - actionCall is the calling location (sets rules)
   */
  extern IGRstat VDct1CmdNodeRulesOK __((TGRid         *parentNodeID,
					 TGRid         *childNodeID,
					 TVDctBaseInfo *baseInfo,
					 IGRchar        location[128]));

#omdef vdct1$CmdNodeRulesOK (parentNodeID, 
			     childNodeID   = NULL,
			     baseInfo      = NULL,
			     location)

VDct1CmdNodeRulesOK((parentNodeID),
		    (childNodeID),
		    (baseInfo),
		    (location)) 
#endomdef

/* -------------------------------------------------
 *  Sums the CG of two points uses a structure
 *  with xcoord, ycoord, zcoord and mass
 *  all are doubles.
 */
extern IGRstat VDct1CmdNodeCG __((TVDctCGinfo *partCG, 
				  TVDctCGinfo *assyCG));
#omdef vdct1CmdNodeCG(partCG,
		      assyCG)

VDct1CmdNodeCG((partCG),(assyCG))
#endomdef
/* ------------------------------------------------
 * vdct1/cmd/VDct1Free.I
 */
extern IGRstat VDct1CmdFreeNotifyForm   __(());
extern IGRstat VDct1CmdFreeActivateForm __(());

extern IGRstat VDct1CmdFreeInit __((TVDct1CmdInfo *a_cmdInfo));

extern IGRstat VDct1CmdFreeCreatedTree   __((TGRid *treeID));
extern IGRstat VDct1CmdFreeDeletedTree   __((TGRid *treeID));
extern IGRstat VDct1CmdFreeRenamedTree   __((TGRid *treeID));

extern IGRstat VDct1CmdFreeCreatedNode   __((TGRid *nodeID));
extern IGRstat VDct1CmdFreeDeletedNode   __((TGRid *nodeID, TGRid *parentID));
extern IGRstat VDct1CmdFreeRenamedNode   __((TGRid *nodeID));
extern IGRstat VDct1CmdFreeActivateNode  __((TGRid *nodeID));

/* ------------------------------------------------
 * vdct1/cmd/VDct1Attr.I
 */
extern IGRstat VDct1CmdAttrNotifyForm   __(());
extern IGRstat VDct1CmdAttrActivateForm __(());

extern IGRstat VDct1CmdAttrInit __((TVDct1CmdInfo *a_cmdInfo));

extern IGRstat VDct1CmdAttrCreatedTree   __((TGRid *treeID));
extern IGRstat VDct1CmdAttrDeletedTree   __((TGRid *treeID));
extern IGRstat VDct1CmdAttrRenamedTree   __((TGRid *treeID));

extern IGRstat VDct1CmdAttrCreatedNode   __((TGRid *nodeID));
extern IGRstat VDct1CmdAttrDeletedNode   __((TGRid *nodeID, TGRid *parentID));
extern IGRstat VDct1CmdAttrRenamedNode   __((TGRid *nodeID));
extern IGRstat VDct1CmdAttrActivateNode  __((TGRid *nodeID));

/* ------------------------------------------------
 * vdct1/cmd/VDct1Part.I
 */
extern IGRstat VDct1CmdPartNotifyForm   __(());
extern IGRstat VDct1CmdPartActivateForm __(());

extern IGRstat VDct1CmdPartInit __((TVDct1CmdInfo *a_cmdInfo));

extern IGRstat VDct1CmdPartCreatedTree   __((TGRid *treeID));
extern IGRstat VDct1CmdPartDeletedTree   __((TGRid *treeID));
extern IGRstat VDct1CmdPartRenamedTree   __((TGRid *treeID));

extern IGRstat VDct1CmdPartCreatedNode   __((TGRid *nodeID));
extern IGRstat VDct1CmdPartDeletedNode   __((TGRid *nodeID, TGRid *parentID));
extern IGRstat VDct1CmdPartRenamedNode   __((TGRid *nodeID));
extern IGRstat VDct1CmdPartActivateNode  __((TGRid *nodeID));

/* ------------------------------------------------
 * vdct1/cmd/VDct1Tree.I
 */

extern IGRstat VDct1CmdTreeNotifyForm   __(());
extern IGRstat VDct1CmdTreeActivateForm __(());

extern IGRstat VDct1CmdTreeInit __((TVDct1CmdInfo *a_cmdInfo));

extern IGRstat VDct1CmdTreeCreatedTree   __((TGRid *treeID));
extern IGRstat VDct1CmdTreeDeletedTree   __((TGRid *treeID));
extern IGRstat VDct1CmdTreeRenamedTree   __((TGRid *treeID));

extern IGRstat VDct1CmdTreeCreatedNode   __((TGRid *nodeID));
extern IGRstat VDct1CmdTreeDeletedNode   __((TGRid *nodeID, TGRid *parentID));
extern IGRstat VDct1CmdTreeRenamedNode   __((TGRid *nodeID));
extern IGRstat VDct1CmdTreeActivateNode  __((TGRid *nodeID));

/* ------------------------------------------------
 * vdct1/cmd/VDct1Lib.I
 */

extern IGRstat VDct1CmdLibNotifyForm   __(());
extern IGRstat VDct1CmdLibActivateForm __(());

extern IGRstat VDct1CmdLibInit __((TVDct1CmdInfo *a_cmdInfo));

extern IGRstat VDct1CmdLibCreatedTree   __((TGRid *treeID));
extern IGRstat VDct1CmdLibDeletedTree   __((TGRid *treeID));
extern IGRstat VDct1CmdLibRenamedTree   __((TGRid *treeID));

extern IGRstat VDct1CmdLibCreatedNode   __((TGRid *nodeID));
extern IGRstat VDct1CmdLibDeletedNode   __((TGRid *nodeID, TGRid *parentID));
extern IGRstat VDct1CmdLibRenamedNode   __((TGRid *nodeID));
extern IGRstat VDct1CmdLibActivateNode  __((TGRid *nodeID));

//Cleanup
#if defined(__cplusplus)
}
#endif

#endif






