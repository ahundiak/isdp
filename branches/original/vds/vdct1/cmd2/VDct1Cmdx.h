/* $Id: VDct1Cmdx.h,v 1.2 2002/01/10 19:10:26 jdsauby Exp $  */

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
 *      $Log: VDct1Cmdx.h,v $
 *      Revision 1.2  2002/01/10 19:10:26  jdsauby
 *      JTSMP CR 5679, added event gadgets to LIB and TREE forms.
 *
 *      Revision 1.1  2001/01/11 21:48:40  art
 *      sp merge
 *
 * Revision 1.10  2000/12/07  13:41:14  pinnacle
 * ah
 *
 * Revision 1.9  2000/09/20  21:08:34  pinnacle
 * js
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/25/00  ah      Creation
 * 12/06/00  ah      c Friendly
 ***************************************************************************/

#ifndef VDct1Cmdx_include
#define VDct1Cmdx_include

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* -----------------------------------------------
 * Turn all command tracing on or off
 */
#define VDCT1_TRACE 1

/* -----------------------------------------------
 * Master Command Data Structure
 */
typedef struct 
{
  Form   form;
  IGRint displayed,isTest;
  TGRid  activeNodeID;

  IGRstat (*init)   __(());
  IGRstat (*delet)  __((void *formInfo)); // Delete is reserved
  IGRstat (*wakeup) __(());
  IGRstat (*sleep)  __(());

  IGRstat (*createdTree)  __((TGRid *treeID));
  IGRstat (*deletedTree)  __((TGRid *treeID));
  IGRstat (*renamedTree)  __((TGRid *treeID));
  IGRstat (*createdNode)  __((TGRid *nodeID));
  IGRstat (*deletedNode)  __((TGRid *nodeID, TGRid *parentID));
  IGRstat (*renamedNode)  __((TGRid *nodeID));
  IGRstat (*activateNode) __((TGRid *nodeID));

  IGRstat (*activateForm)  __(());
  IGRstat (*  notifyForm)  __(());
  IGRstat (*locatedObject) __(());
  
} TVDct1CmdFormInfo;

/* Data structure to hold everything */
typedef struct 
{
  // The various sub forms
  TVDct1CmdFormInfo root;   // Access to default items
  TVDct1CmdFormInfo mgr;
  TVDct1CmdFormInfo sets;   // Because is reserved
  TVDct1CmdFormInfo node;
  TVDct1CmdFormInfo tree;
  TVDct1CmdFormInfo attr;
  TVDct1CmdFormInfo lib;
  TVDct1CmdFormInfo free;
  TVDct1CmdFormInfo part;
  TVDct1CmdFormInfo misc;
  TVDct1CmdFormInfo stru;
  TVDct1CmdFormInfo dbtbl;
  

  // Current form and gadget
  Form       form;
  IGRint     gadget;
  TGRobj_env locatedOE;
  TGRid      windowID;
  
  // Command controls
  IGRint isTest;
  IGRint isNotify;
  
  IGRint shutDown;
  TGRid  cmdID;  // The PPL ID which kicked this off

  TGRid  eventID; // object ID passed when EVENT button pressed
  IGRint event;

  // mode of ppl, sleep or wake
  IGRint sleep;

  // Locate functions
  VDclassid      classIDs[16];
  OM_S_CLASSLIST classList;
  
} TVDct1CmdInfo;


/* -----------------------------------------------
 * Setup default function pointers
 */
extern IGRstat VDct1CmdInitRootFormInfo __((TVDct1CmdFormInfo *formInfo,
					    IGRchar           *formName));

/* -----------------------------------------------
 * Allows cycling through list form infos
 */
extern TVDct1CmdFormInfo *VDct1CmdGetNthFormInfo __((TVDct1CmdInfo *cmdInfo, 
						     IGRint nth));
/* -----------------------------------------------
 * Called from ppl
 */
extern IGRstat VDct1CmdInitRootCmdInfo   __((TVDct1CmdInfo *cmdInfo,
	    				     VDobjid        pplObjid,
					     VDosnum        pplOsnum));
extern IGRstat VDct1CmdDeleteRootCmdInfo __(());
extern IGRstat VDct1CmdSleepRootCmdInfo  __(());
extern IGRstat VDct1CmdWakeupRootCmdInfo __(());
extern IGRstat VDct1CmdMainRootCmdInfo   __(());

extern IGRstat VDct1CmdNotifyRootLocate  __((Form        form, 
					     IGRint      gadget, 
					     TGRobj_env *locatedOE));

extern IGRint  VDct1CmdNotifyRootForm    __((IGRint    formLabel,
					     IGRint    gadget,
					     IGRdouble value,
					     Form      form));

/* -----------------------------------------------
 * Individual public init functions
 */
extern IGRstat VDct1CmdInitMgrCmdInfo  __((TVDct1CmdInfo *cmdInfo));
extern IGRstat VDct1CmdInitSetCmdInfo  __((TVDct1CmdInfo *cmdInfo));
extern IGRstat VDct1CmdInitLibCmdInfo  __((TVDct1CmdInfo *cmdInfo));
extern IGRstat VDct1CmdInitBoxCmdInfo  __((TVDct1CmdInfo *cmdInfo));
extern IGRstat VDct1CmdInitTreeCmdInfo __((TVDct1CmdInfo *cmdInfo));
extern IGRstat VDct1CmdInitStruCmdInfo __((TVDct1CmdInfo *cmdInfo));

extern IGRstat VDct1CmdInitDbTblCmdInfo __((TVDct1CmdInfo *cmdInfo));

/* -----------------------------------------------
 * Test routines
 */
extern IGRstat VDct1CmdInitTest __((TVDct1CmdInfo *cmdInfo));
extern IGRstat VDct1CmdTest1    __(());

/* ------------------------------------------------
 * Message box routines
 */
extern IGRstat VDct1CmdBoxMsg     __((IGRchar *msg));
extern IGRstat VDct1CmdBoxYesOrNo __((IGRchar *msg, IGRint *yesFlag));

/* ------------------------------------------------
 * Utility routine for the doit gadget
 */
extern IGRstat VDct1CmdResetGadgetList __((TGRid *nodeID, 
					   Form   form, 
					   IGRint gadget,
					   IGRint keepDefault));

extern void VDct1CmdGetNavEventID __((TGRid *objID));

//Cleanup
#if defined(__cplusplus)
}
#endif

#endif
