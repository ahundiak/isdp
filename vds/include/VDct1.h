/* $Id: VDct1.h,v 1.5 2001/03/12 20:36:00 jdsauby Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDct1.h
 *
 * Description: Collector Tree Object
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1.h,v $
 *      Revision 1.5  2001/03/12 20:36:00  jdsauby
 *      Cleaned out unnecessary functions from vdct1/set
 *
 *      Revision 1.4  2001/02/17 14:06:12  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/01/14 16:11:38  art
 *      sp merge
 *
 *      Revision 1.2  2001/01/09 22:17:07  art
 *      ah
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.19  2000/12/08  16:39:26  pinnacle
 * ah
 *
 * Revision 1.18  2000/12/08  15:32:34  pinnacle
 * ah
 *
 * Revision 1.17  2000/08/15  17:53:36  pinnacle
 * ah
 *
 * Revision 1.16  2000/07/14  19:10:44  pinnacle
 * pn
 *
 * Revision 1.15  2000/07/12  11:21:08  pinnacle
 * p
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/28/99  ah      Creation
 * 10/26/99  ah      Misc Changes
 * 12/16/99  pn      Update the Prototypes from set/*.I files 
 * 03/10/00  pn      Revision to include PPL defined types 
 * 03/28/00  pn      Misc Changes
 * 05/16/00  pn      Added some macros to handle PPL access to VSplate/Beam etc
 * 05/23/00  pn      Added prototypes for PPL wrappers for Freeze/Revise processes
 * 05/31/00  pn      Added prototypes for ppl wrappers for Tree/Lib form views
 * 06/02/00  ah      getPartNum
 * 06/23/00  pn      Added prototype for Posting
 * 06/30/00  pn      added some new prototypes for attribute access
 * 12/07/00  ah      c friendly
 * 01/12/01  ah      sp17 merge, symbology and a few new macros
 ***************************************************************************/

#ifndef VDct1_include
#define VDct1_include
 
/* --------------------------------------------
 * This is the master include file, pull in
 * other files automatically
 */

#ifndef   VDtypedefc_include
#ifndef   VDtypedef_include
#include "VDtypedef.h"
#endif
#endif

#ifndef   VDfld_include
#include "VDfld.h"
#endif

#ifndef   VDcla_include
#include "VDcla.h"
#endif

#ifndef   VDcol_include
#include "VDcol.h"
#endif

#ifndef   VDlnk_include
#include "VDlnk.h"
#endif

#ifndef   VDct_include
#include "VDct.h"
#endif

#ifndef   VDvla_include
#include "VDvla.h"
#endif

#ifndef   VDvla2_include
#include "VDvla2.h"
#endif

#ifndef   VDos_include
#include "VDos.h"
#endif

/* ------------------------------------------
 * This is a real mess, do we really need a display mode?
 */
#ifndef   dp_include
#include "dp.h"
#endif

/* ------------------------------------------
 * Usual bs
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* --------------------------------------------
 * Define class types and names
 */
#define VDCT1_CLASS_TYPE_MGR  1100
#define VDCT1_CLASS_TYPE_SET  1110
#define VDCT1_CLASS_TYPE_NODE 1120

#define VDCT1_CLASS_NAME_MGR  "VDct1Mgr"
#define VDCT1_CLASS_NAME_SET  "VDct1Set"
#define VDCT1_CLASS_NAME_NODE "VDct1Node"

/* ---------------------------------------------
 * 14 August 2000
 *
 * Get real dangerous and define an instance
 * data structure
 *
 * Need to use void for the class data pointer
 * To get around complier restrictions
 */
typedef struct 
{
  void *cl;  // TVDct1XXXXTreeClass
  TGRid id;
} TVDct1JD;

/* --------------------------------------
 * working to have a list of all nodes
 * in a particular tree.  This struct will
 * be of a node.  TVDct1NodeInfo.
 */
typedef struct
{
  TVDct1JD      parentJD;
  TVDct1JD      nodeJD;
  TVDctBaseInfo info;
} TVDct1NodeInfo;

/* -------------------------------------
 * NodeInfo list of all nodes in tree
 */
typedef struct
{
  IGRint          max;
  IGRint          inc;
  IGRint          cnt;
  TVDct1NodeInfo *nodes;
} TVDct1NodeInfos;

// init and free functions
extern IGRstat VDct1InitNodeInfos __((TVDct1NodeInfos *infos));
extern IGRstat VDct1FreeNodeInfos __((TVDct1NodeInfos *infos));

/* ---------------------------------------
 * User Info struct for setting user info
 * at node creation
 */
#if 0
typedef struct 
{
  TGRobj_env   *objOE;
  TGRid        *windowID;
  TGRsymbology *symb;  
} TVDct1UserInfo;
#endif

typedef struct 
{
  TGRobj_env   objOE;
  TGRid        windowID;
  TGRsymbology symb;
} TVDct1UserInfo;

// location names for use in ppls seen by both PPL and /cmd and /set
// used to set the location were rules are applied in ppls
#define VDCT1_ACTION_RENAME_NODE    "rename_node"
#define VDCT1_ACTION_R_NODE_DUP     "r_node_dup"
#define VDCT1_ACTION_DELETE_NODE    "delete_node"
#define VDCT1_ACTION_CREATE_NODE    "create_node"
#define VDCT1_ACTION_CREATE_NAME    "create_name"
#define VDCT1_ACTION_CREATE_TNAME   "create_tree_name"
#define VDCT1_ACTION_C_MODEL_ATTR   "create_model_node"
#define VDCT1_ACTION_C_MODEL_NODE   "create_model_node"
#define VDCT1_ACTION_C_NODE_DUP     "c_node_dup"
#define VDCT1_ACTION_C_MODEL_ATTRS  "c_model_attrs"
#define VDCT1_ACTION_PASTE_NODE     "paste_node"
#define VDCT1_ACTION_PASTE_NPARENT  "parent"
#define VDCT1_ACTION_PARTS          "parts"
#define VDCT1_ACTION_PASTE_DUPS     "paste_dups"
#define VDCT1_ACTION_CHANGE_NT      "change_nt"
#define VDCT1_ACTION_PASTE_CONNECT  "paste_connect"
#define VDCT1_ACTION_CMN_OK         "create_mn_ok"
#define VDCT1_ACTION_CN_OK          "create_node_ok"
#define VDCT1_ACTION_CONVERT        "convert_node"
#define VDCT1_ACTION_MARK_DEL       "mark_del"
/* --------------------------------------------------------
 * set/Vdct1Buf.I
 */
#if 0
// Builds path to paste buffer object 
extern IGRstat VDct1GetPasteBufferPath __((VDosnum osnum, IGRchar *path));
#ifndef c_ONLY
#omdef vdct1$GetPasteBufferPath(osnum,path
)
VDct1GetPasteBufferPath((osnum),(path))
#endomdef
#endif
#endif
#if 0
// Create a new paste buffer
extern IGRstat VDct1CreatePasteBuffer __((VDosnum osnum, TGRid *objID));
#ifndef c_ONLY
#omdef vdct1$CreatePasteBuffer(osnum,objID)
VDct1CreatePasteBuffer((osnum),(objID))
#endomdef
#endif
#endif
#if 0
// Get the manager if it exists
extern IGRstat VDct1GetPasteBuffer __((VDosnum osnum, IGRint createFlag, TGRid *objID));
#ifndef c_ONLY
#omdef vdct1$GetPasteBuffer(osnum,
			    createFlag,
			    objID)
VDct1GetPasteBuffer((osnum),(createFlag),(objID))
#endomdef
#endif
#endif
/* --------------------------------------------------------
 * set/VDct1Mgr.I
 */

// Create the Manager Object
extern IGRstat VDct1CreateManager __((VDosnum osnum, TGRid   *mgrID));

#ifndef c_ONLY
#omdef vdct1$CreateManager(
  osnum =  OM_K_NOT_AN_OS, // I - Otherwise current osnum
  mgrID                    // O - Created Manger Object
)
VDct1CreateManager((osnum),(mgrID))
#endomdef
#endif

// Obtain the Manager
extern IGRstat VDct1GetManager __((VDosnum osnum, TGRid   *mgrID));

#ifndef c_ONLY
#omdef vdct1$GetManager(
  osnum =  OM_K_NOT_AN_OS, // I - Input osnum to search
  mgrID                    // O - Obtained Manager
)
VDct1GetManager((osnum),(mgrID))
#endomdef
#endif

//  Builds path to manager object 
// Needs to be tweaked for transient space
extern IGRstat VDct1GetMgrPath __((VDosnum osnum, IGRchar *mgrPath));

#ifndef c_ONLY
#omdef vdct1$GetMgrPath(osnum,mgrPath)
VDct1GetMgrPath((osnum),(mgrPath))
#endomdef
#endif
#if 0
// manager test routine
extern IGRstat VDctMgrTest __(());

#ifndef c_ONLY
#omdef vdct$MgrTest()
VDctMgrTest(())
#endomdef
#endif
#endif

/* --------------------------------------------------------
 * set/VDct1Defn.I
 */
#if 0
extern IGRstat VDct1GetDefnPath __((VDosnum osnum,IGRchar *defnPath));

#ifndef c_ONLY
#omdef vdct1$GetDefnPath(osnum,    defnPath)
VDct1GetDefnPath((osnum),(defnPath))
#endomdef
#endif
#endif

// Create the Macro Defination Object
extern IGRstat VDct1CreateDefn __((VDosnum osnum, TGRid *defnID));

#ifndef c_ONLY
#omdef vdct1$CreateDefn(osnum =  OM_K_NOT_AN_OS,defnID)
VDct1CreateDefn((osnum),(defnID))
#endomdef
#endif

// Obtain the Defination
extern IGRstat VDct1GetDefn __((VDosnum osnum, TGRid *defnID));

#ifndef c_ONLY
#omdef vdct1$GetDefn(osnum =  OM_K_NOT_AN_OS,defnID)
VDct1GetDefn((osnum),(defnID))
#endomdef
#endif

/* --------------------------------------------------------
 * set/VDct1Base.I
 */
extern IGRstat VDct1CreateBaseObject __((TVDclaType classType,
					 VDosnum    osnum,
					 TGRid     *objID));

#ifndef c_ONLY
#omdef vdct1$CreateBaseObject(classType,osnum = OM_K_NOT_AN_OS,objID)
VDct1CreateBaseObject((classType), (osnum), (objID))
#endomdef
#endif

#if 0
extern IGRstat VDct1DeleteBaseObject __((TGRid *objID));

#ifndef c_ONLY
#omdef vdct1$DeleteBaseObject(objID)
VDct1DeleteBaseObject((objID))
#endomdef
#endif
#endif

extern IGRstat VDct1GetBaseInfo __((TGRobj_env    *objOE,
				    TGRid         *objID,
				    IGRchar       *name,
				    IGRchar       *txt,
				    TVDctBaseInfo *rs));

#ifndef c_ONLY
#omdef vdct1$GetBaseInfo(objOE = NULL,
			 objID = NULL,
			 name  = NULL,
			 txt   = NULL,
			 baseInfo = NULL)
VDct1GetBaseInfo((objOE), (objID), (name), (txt), (baseInfo))
#endomdef
#endif

extern IGRstat VDct1SetBaseInfo __((TGRobj_env    *objOE,
				    TGRid         *objID,
				    TVDctBaseInfo *baseInfo));

#ifndef c_ONLY
#omdef vdct1$SetBaseInfo(objOE = NULL,objID = NULL,baseInfo)
VDct1SetBaseInfo((objOE), (objID), (baseInfo))
#endomdef
#endif

/* -----------------------------------------------------
 * set/VDct1Set.I
 */

/* ---------------------------------------------------------------------------
 * PPL wrapper for test to control check if part must be in ops
 * defaults no (if ppl not found)
 */
#if 0
extern IGRstat VDct1MustPartBeInOPS __((TGRid *nodeID));

#ifndef c_ONLY
#omdef vdct1$MustPartBeInOPS(nodeID = NULL)
VDct1MustPartBeInOPS((nodeID))
#endomdef
#endif
#endif
#if 0
/* ----------------------------------------------------------------------------
 * Validate if a part is in OPS Database
 * ppl wrapper
 */
extern IGRstat VDct1IsPartInOPS __((TGRid         *nodeID,
				    TVDctBaseInfo *baseInfo));

#ifndef c_ONLY
#omdef vdct1$IsPartInOPS(nodeID,baseInfo)
VDct1IsPartInOPS((nodeID),(baseInfo))
#endomdef
#endif
#endif

#if 0
/* ------------------------------------------------
 * PPL wrapper to grab a node and mark it as deleted
 * and wipe out its kids
 */
extern IGRstat VDct1SetNodeMarkDeleted __((TGRid *nodeID));

#ifndef c_ONLY
#omdef vdct1$SetNodeMarkDeleted(nodeID)
VDct1SetNodeMarkDeleted((nodeID))
#endomdef
#endif
#endif
#if 0
/* ------------------------------------------------
 * PPL wrapper for restoring the Deleted status to 
 * Active
 */
extern IGRstat VDct1SetNodeActive __((TGRid *nodeID));

#ifndef c_ONLY
#omdef vdct1$SetNodeActive(nodeID)
VDct1SetNodeActive((nodeID))
#endomdef
#endif
#endif

#if 0
/* -------------------------------------------------
 * Check if this particular node is to be active etc
 */
extern IGRstat VDct1IsNodeActivateOK __((TGRid *nodeID));

#ifndef c_ONLY
#omdef vdct1$IsNodeActivateOK(nodeID = NULL)
VDct1IsNodeActivateOK((nodeID))
#endomdef
#endif
#endif

#if 0
/* ------------------------------------------------
 * Check if the freeze should be done
 * ppl wrapper to determine if a node is proper to freeze
 */
extern IGRstat VDct1IsFreezeOK __((TGRid         *parentNodeID,
				   TVDctBaseInfo *baseInfo));
#ifndef c_ONLY
#omdef vdct1$IsFreezeOK(parentNodeID = NULL,baseInfo = NULL)
VDct1IsFreezeOK((parentNodeID),(baseInfo))
#endomdef 
#endif
#endif

#if 0
/* ------------------------------------------------
 * Check if the revise should be done
 * ppl wrapper to determine if a node is proper to revise
 */
extern IGRstat VDct1IsReviseOK __((TGRid         *parentNodeID,
				   TVDctBaseInfo *baseInfo,
				   IGRint        *revNum));

#ifndef c_ONLY
#omdef vdct1$IsReviseOK(parentNodeID   = NULL,
			baseInfo       = NULL,
			revNum)

VDct1IsReviseOK((parentNodeID),(baseInfo),(revNum))
#endomdef 
#endif
#endif

#if 0
/* ------------------------------------------------
 * A bit of DEBUGGING STUFF
 * used for looking at PPL and Struct data
 * Everything defaults NULL unless input
 * backscreen printing 
 * defaults off with status == 0
 */
extern IGRstat VDct1SR __((IGRint           sts,
			   IGRchar          loc[128],
			   TGRid           *nodeID, 
			   TVDctBaseInfo   *baseInfo,
			   TGRobj_env      *objOE));

#ifndef c_ONLY
#omdef vdct1$SR(sts = 0,
		loc = "",
		nodeID = NULL,
		baseInfo = NULL,
		objOE  = NULL)
VDct1SR((sts),(loc),(nodeID),(baseInfo),(objOE))
#endomdef
#endif
#endif

#if 0
/* ------------------------------------------------
 * isPartConValid?
 * wrapper for PPL 
 * checkes to see if a part is valid for connection
 * works by exception in that it returns a valid connection
 * unless a rule stops the connection  Made this way because
 * pasting of nodes is fairly automatic in the PalAssys.u segment
 * This can be reversed in the PPL if the user wishes to 
 * make the rules detect the conditions which permit returning 0 if the 
 * conditons are not met
 */
extern IGRstat VDct1IsPartConValid __((TGRid         *nodeID, 
				       TVDctBaseInfo *baseInfo,
				       TGRobj_env    *modelOE));

#ifndef c_ONLY
#omdef vdct1$IsPartConValid(nodeID,
			    baseInfo,
			    modelOE)

VDct1IsPartConValid((nodeID),(baseInfo),(modelOE))
#endomdef
#endif
#endif

// tells if first letter is alpha or numeric in a string
  //return 1 = true
#if 0
extern IGRstat VDct1IsFirstLetterOK __((IGRchar *test));

#ifndef c_ONLY
#omdef vdct1$IsFirstLetterOK(test)
VDct1IsFirstLetterOK((test))
#endomdef
#endif
#endif

// Create the Set Object
extern IGRstat VDct1CreateSet __((TGRid          *mgrID,
				  TVDctSetType    setType,
				  TVDctSetTypeRev setTypeRev,
				  TVDctSetName    setName,
				  TGRid          *setID));

#ifndef c_ONLY
#omdef vdct1$CreateSet(mgrID,
		       setType,
		       setTypeRev = NULL,
		       setName,
		       setID)
VDct1CreateSet((mgrID), (setType), (setTypeRev), (setName), (setID))
#endomdef
#endif

#if 0
extern IGRstat VDct1GetSetTypeInfo __((IGRchar *setType, TVDctSetTypeInfo *setTypeInfo));

#ifndef c_ONLY
#omdef vdct1$GetSetTypeInfo(setType,setTypeInfo)
VDct1GetSetTypeInfo((setType), (setTypeInfo))
#endomdef
#endif
#endif

extern IGRstat VDct1GetSetTree __((TGRid *setID, TGRid *treeID));

#ifndef c_ONLY
#omdef vdct1$GetSetTree (setID, treeID)
VDct1GetSetTree((setID), (treeID))
#endomdef
#endif

extern IGRstat VDct1FindSetByName __((TVDctBaseInfo *baseInfo,
				      TGRid         *setID,
				      TGRid         *treeID));

#ifndef c_ONLY
#omdef vdct1$FindSetByName(baseInfo,setID = NULL,treeID = NULL)
VDct1FindSetByName((baseInfo),(setID), (treeID))
#endomdef
#endif

/* ------------------------------------------------------
 * set/VDct1Model.I
 */
#if 0
// Gets type for model object 12/28/99
extern IGRstat VDct1GetTypeForModelObject __((TGRid         *parentID,
					      TGRobj_env    *modelOE,
					      TVDctNodeType  nodeType));
#ifndef c_ONLY
#omdef vdct1$GetTypeForModelObject(parentID,modelOE,nodeType)
VDct1GetTypeForModelObject((parentID),(modelOE),(nodeType))
#endomdef
#endif
#endif

// Connects a node to a model object
// Nothing fancy, just makes the connection
extern IGRstat VDct1ConnectNodeToModelObject __((TGRid      *nodeID, 
						 TGRobj_env *modelOE));
#ifndef c_ONLY
#omdef vdct1$ConnectNodeToModelObject(nodeID,modelOE)
VDct1ConnectNodeToModelObject((nodeID), (modelOE))
#endomdef
#endif

// Get the model attached to the node
extern IGRstat VDct1GetNodeModelObject __((TGRid      *nodeID, 
					   TGRobj_env *modelOE));

#ifndef c_ONLY
#omdef vdct1$GetNodeModelObject(nodeID,modelOE)
VDct1GetNodeModelObject((nodeID),(modelOE))
#endomdef
#endif

//  Copies attributes from model to node
// This needs to call a ppl
extern IGRstat VDct1CopyAttributesFromModelToNode __((TGRid      *nodeID,  
						      TGRobj_env *modelOE));
#ifndef c_ONLY
#omdef vdct1$CopyAttributesFromModelToNode(nodeID,modelOE)
VDct1CopyAttributesFromModelToNode((nodeID),(modelOE))
#endomdef
#endif



// Transfer attribute from model to node
extern IGRstat VDct1CopyAttributeFromModelToNode __((TGRid      *nodeID, 
						     IGRchar    *nodeAttrName,
						     TGRobj_env *modelOE,
						     IGRchar    *modelAttrName));

#ifndef c_ONLY
#omdef vdct1$CopyAttributeFromModelToNode(nodeID,nodeAttrName,modelOE,modelAttrName)
VDct1CopyAttributeFromModelToNode((nodeID),(nodeAttrName),(modelOE),(modelAttrName))
#endomdef
#endif


/* -------------------------------------------------------------------
 * VDct1GetModelObjectNode  Checks for Channel Connections
 * This prototype is to receive either modelOE or modelID but not both
 * It can receive setType,setRev,setName but they are optional
 */
extern IGRstat VDct1GetModelObjectNode __((TGRobj_env      *a_modelOE, /* I - model object */
					   TGRid           *a_modelID, /* I - model object */
					   TVDctSetType     setType,   /* I - filter       */
					   TVDctSetTypeRev  setRev,    /* I - filter       */
					   TVDctSetName     setName,   /* I - filter       */
					   TGRid           *nodeID));  /* O - The node     */

#ifndef c_ONLY
#omdef vdct1$GetModelObjectNode(modelOE = NULL,
				modelID = NULL,
				setType = NULL,
				setRev  = NULL,
				setName = NULL,
				nodeID  = NULL) 
VDct1GetModelObjectNode ((modelOE),(modelID),(setType),(setRev),(setName),(nodeID))
#endomdef
#endif

/* -----------------------------------------------------
 * set/VDct1Node.I
 */
#if 0
/* ---------------------------------------------------------------------------
 *  Turn off if there is not a ppl switch the limit on tree creation
 */
extern IGRstat VDct1IsTreeLimitOK __((TGRid         *nodeID,
				      TVDctBaseInfo *baseInfo));

#ifndef c_ONLY
#omdef vdct1$IsTreeLimitOK(nodeID,baseInfo)
VDct1IsTreeLimitOK((nodeID),(baseInfo))
#endomdef
#endif
#endif

#if 0
/*---------------------------------------------------
 * Searches for a set of matching attributes
 * if found return is 1
 * default return is 0
 * PPL Wrapper
 */
extern IGRstat VDct1CheckNodeAttrForMatch __((TGRid   *parentID,
					      TGRid   *childID,
					      TGRid   *nodeID,
					      IGRint  *dupSwitch));
#ifndef c_ONLY
#omdef vdct1$CheckNodeAttrForMatch(parentID,childID,nodeID,dupSwitch)
VDct1CheckNodeAttrForMatch((parentID),(childID),(nodeID),(dupSwitch))
#endomdef
#endif
#endif

#if 0
/*---------------------------------------------------
 * Searches through a tree provides all the possible children for a tree
 * this is recursive from the parentID.
 * calls the vdct1$CheckNodeAttrsForMatch routine for each one
 */
extern IGRstat VDct1SearchNodesForAttrMatch __((TGRid   *parentID,
						TGRid   *nodeID,
						IGRint  *dupSwitch));
#ifndef c_ONLY
#omdef vdct1$SearchNodesForAttrMatch(parentID,nodeID,dupSwitch)
VDct1SearchNodesForAttrMatch((parentID),(nodeID),(dupSwitch))
#endomdef
#endif
#endif

#if 0
/* ----------------------------------------------------------------------------
 * gets default attributes if any from the PPL 
 * attributes come from parentID and go to nodeID
 * I - NODE_PARENT_ID
 * I - NODE_ID
 */
extern IGRstat VDct1GetParentAttributes __((TGRid *parentID,
					   TGRid *nodeID));
#ifndef c_ONLY
#omdef vdct1$GetParentAttributes(parentID,nodeID)
VDct1GetParentAttributes((parentID),(nodeID))
#endomdef
#endif
#endif

#if 0
/* ------------------------------------------------
 * moves the attributes of NODE_PARENT_ID to NODE_ID
 * while protecting some attributes
 * used when marking as deleted EA[2] when converted 
 * to EA[6]
 */
extern IGRstat VDct1SetNodeDeleted __((TGRid *parentID,
				       TGRid *nodeID));

#ifndef c_ONLY
#omdef vdct1$SetNodeDeleted (parentID,nodeID)

VDct1SetNodeDeleted((parentID),(nodeID))
#endomdef
#endif
#endif

/* ---------------------------------------------------------------
 * Finds if a particular node is a child of a particular Parent
 * filters to make sure that the revNum exists (keeps revisions together)
 * this prevents looking into group and trees also prevents looking into
 * parts
 */
#if 0
extern IGRstat VDct1FindChildUnderParentRev __((TGRid         *nodeID,
						TVDctBaseInfo *baseInfo,
						TGRid         *copiedNodeID));
#ifndef c_ONLY
#omdef vdct1$FindChildUnderParentRev(nodeID,baseInfo,copiedNodeID)
VDct1FindChildUnderParentRev((nodeID),(baseInfo),(copiedNodeID))
#endomdef
#endif
#endif

/* ------------------------------------------------
 * Checks if the nodeID should be posted to the form 
 * (Tree or Lib forms)
 * returns 1 if the node should be updated and 1 if the
 * ppl does not have a corresponding control device
 * fail safe device ...
 * returns 0 if the node should not be displayed
 */
extern IGRstat VDct1IsDisplayOK __((TGRid  *rootID,
				    IGRint *dispOption));
#ifndef c_ONLY
#omdef vdct1$IsDiplayOK(rootID,dispOption)
VDct1IsDisplayOK((rootID),(dispOption))
#endomdef
#endif

#if 0
// updates node attributes
extern IGRstat VDct1UpdateAttributes __((TGRid *nodeID));

#ifndef c_ONLY
#omdef vdct1$UpdateAttributes(nodeID)
VDct1UpdateAttributes((nodeID))
#endomdef
#endif
#endif

/* ------------------------------------------------------
 * Updates the attributes of a node 
 * called by PPL
 * send the parentID It search all the 1st level kids and get attribute values
 * The PPL then can process as per user design the data for sums to apply to this parent
 * parentID is then returned as the ID for the parentID of this node.
 * this is then recursively called to process all the data from that level of kids.
 */ 
#if 0
extern IGRstat VDct1SummaryNode __((TGRid *parentID));

#ifndef c_ONLY
#omdef vdct1$SummaryNode (parentID)
VDct1SummaryNode((parentID))
#endomdef
#endif
#endif

#if 0
/* ------------------------------------------------
 * PPL wrapper to nodeMakeAName()
 * gives the NODE_PARENT_ID and the BASE_INFO 
 * returns the BASE_INFO nodeName
 */
extern IGRstat VDct1MakeNodeName __((TGRid         *parentID,
				     TVDctBaseInfo *baseInfo));

#ifndef c_ONLY
#omdef vdct1$MakeNodeName (parentID,
			   baseInfo)

VDct1MakeNodeName ((parentID),(baseInfo))
#endomdef
#endif
#endif

/* ------------------------------------------------
 *  Name maker for Nodes
 *  Return is 1 or 0
 *  I - actionType is the test conditon (comparison item)
 *  I - actionCall is the calling location (sets rules)
 */
#if 0
extern IGRstat VDct1TreeMakeAName __((TGRid         *a_activeNodeID,
				      TVDctBaseInfo *a_baseInfo,
				      IGRchar        a_location[128]));

#ifndef c_ONLY
#omdef vdct1$TreeMakeAName(activeNodeID,
			   baseInfo = NULL,
			   location)
VDct1TreeMakeAName((activeNodeID),
		   (baseInfo),
		   (location)) 
#endomdef
#endif
#endif

#if 0
/* ----------------------------------------------------------
 * Gets Node Attribute values puts them in the NODE_ID attributes
 * Then totals the various node  values from database
 * no return value changes only input
 * PPL wrapper
 * I - nodeID;  I - parentID;  I - baseInfo; 
 * corresponds in PPL to NODE_ID, BASE_INFO, NODE_PARENT_ID
 */ 
extern IGRstat VDct1ComputeNodeAttr __((TGRid         *nodeID, 
					TVDctBaseInfo *baseInfo,
					TGRid         *parentID));

#ifndef c_ONLY
#omdef vdct1$ComputeNodeAttr(nodeID, 
			     baseInfo,
			     parentID) 

VDct1ComputeNodeAttr((nodeID),(baseInfo),(parentID))
#endomdef
#endif
#endif

#if 0
/* ------------------------------------------------------
 * PPL Wrapper for computeNodeName()
 */
extern IGRstat VDct1computeNodeName __((TGRid *parentID,TVDctBaseInfo *baseInfo));
#ifndef c_ONLY
#omdef vdct1$computeNodeName(parentID,baseInfo)
VDct1computeNodeName((parentID),(baseInfo))
#endomdef
#endif
#endif

#if 0
/* ------------------------------------------------------
 * RET_FLAG is the return value
 * Reports back 1 if valid to make
 * Reports back 0 if not valid to make
 * Just a wrapper to the ppl which validates the creation of this node 
 * used for copies and pastes and automated node creation to prevent duplicates.
 */ 

extern IGRstat VDct1IsChildTypeValid __((TGRid *parentID,TVDctNodeType  childType));
#ifndef c_ONLY
#omdef vdct1$IsChildTypeValid(parentID,childType)
VDct1IsChildTypeValid((parentID),(childType))
#endomdef
#endif
#endif
#if 0
// Create the Node Object
extern IGRstat VDct1CreateNode  __((TGRid         *parentID,
				    TVDctNodeType  nodeType,
				    TVDctNodeName  nodeName,
				    TGRid         *nodeID));
  
#ifndef c_ONLY
#omdef vdct1$CreateNode(parentID,nodeType,nodeName,nodeID)
VDct1CreateNode((parentID),(nodeType),(nodeName),(nodeID))
#endomdef
#endif
#endif

// Return the treeID for the top of the tree

extern IGRstat VDct1GetTreeForNode __((TGRid *nodeID,TGRid *treeID));

#ifndef c_ONLY
#omdef vdct1$GetTreeForNode(nodeID,treeID) 
VDct1GetTreeForNode((nodeID), (treeID)) 
#endomdef
#endif


/* ----------------------------------------------------------
 * From cmd/VDct1Set.I name changed from VDct1GetTreeForNode
 * finds recursively the top node of a tree for ID 
 * probably is not duplicate methodology of previous routine
 * routine occurs in cmd/VDct1Set.I 
 */
extern IGRstat VDct1GetTreeTopForNode __((TGRid *nodeID,TGRid *treeID));

#ifndef c_ONLY
#omdef vdct1$GetTreeTopForNode(nodeID,treeID)
VDct1GetTreeTopForNode((nodeID),(treeID))
#endomdef
#endif

#if 0
// just a wrapper to the ppl
extern IGRstat VDct1ComputeNode __((TGRid *nodeID));

#ifndef c_ONLY
#omdef vdct1$ComputeNode(nodeID)
VDct1ComputeNode((nodeID))
#endomdef
#endif
#endif

#if 0
// Want to post a node to the database
extern IGRstat VDct1PostNode __((TGRid *nodeID));
#ifndef c_ONLY
#omdef vdct1$PostNode(nodeID)
VDct1PostNode((nodeID))
#endomdef
#endif
#endif

#if 0
// Display a node with recursive flag
extern IGRstat VDct1DisplayNode __((TGRid         *nodeID,
				    enum GRdpmode mode,
				    IGRint        flag));
#ifndef c_ONLY
#omdef vdct1$DisplayNode(nodeID,mode,flag)
VDct1DisplayNode((nodeID),(mode),(flag))
#endomdef
#endif
#endif

// Delete a Node Object
extern IGRstat VDct1DeleteNode __((TGRid *nodeID));  
#ifndef c_ONLY
#omdef vdct1$DeleteNode(nodeID)
VDct1DeleteNode((nodeID))
#endomdef
#endif

#if 0
extern IGRstat VDct1GetNodeTypeInfo __((IGRchar           *setType,
					IGRint             nodeInd,
					TVDctNodeTypeInfo *nodeTypeInfo));
#ifndef c_ONLY
#omdef vdct1$GetNodeTypeInfo(setType,nodeInd,nodeTypeInfo)
VDct1GetNodeTypeInfo((setType), (nodeInd), (nodeTypeInfo))
#endomdef
#endif
#endif

// get the model node
extern IGRstat VDct1GetNodeModelObject __((TGRid *nodeID, TGRobj_env *modelOE));
#ifndef c_ONLY
#omdef vdct1$GetNodeModelObject(nodeID,modelOE)
VDct1GetNodeModelObject((nodeID),(modelOE))
#endomdef
#endif

#if 0
extern IGRstat VDct1GetNodeTypeInfoByType __((IGRchar           *setType, 
					      IGRchar           *nodeType,
					      TVDctNodeTypeInfo *nodeTypeInfo));
#ifndef c_ONLY
#omdef vdct1$GetNodeTypeInfoByType(setType,nodeType,nodeTypeInfo)
VDct1GetNodeTypeInfoByType((setType),(nodeType),(nodeTypeInfo))
#endomdef
#endif
#endif

#if 0
// transfer same name .. name attributes
extern IGRstat VDct1CopyNodeAttributes __((TGRid *desID, TGRid *srcID));

#ifndef c_ONLY
#omdef vdct1$CopyNodeAttributes (desID,srcID)
VDct1CopyNodeAttributes((desID),(srcID)) 
#endomdef
#endif
#endif

/* ---------------------------------------------
 * 02 Jun 2000 - getPartNum Interface
 */
#if 0
extern IGRstat VDct1GetPartNumForNode     __((TGRid *nodeID, IGRchar *part_num));
#endif
extern IGRstat VDct1GetPartCageNumForNode __((TGRid *nodeID, IGRchar *part_cage_num));

#if 0
extern IGRstat VDct1GetNodeTypeToCreateForCopy __((TGRid *parentID, 
						   TGRid *copyID, 
						   TVDctNodeTypeInfo *nodeTypeInfo));
#endif

// Recursive search for node in tree
// Make it case insenitive
extern IGRstat VDct1SearchForNodeInTree
                                      __((TGRid          *a_treeID,
					  TGRid          *a_testID,
					  TVDctNodeType   a_nodeType,
					  TVDctNodeType   b_nodeType,
					  TVDfld         *a_fld,
					  TVDfld         *b_fld,
					  IGRint          a_descendFlag,
					  TGRid          *a_nodeID)); 
#ifndef c_ONLY
#omdef vdct1$SearchForNodeInTree(a_treeID,
				 a_testID = NULL,
				 a_nodeType,
				 b_nodeType = NULL,
				 a_fld,
				 b_fld = NULL,
				 a_descendFlag,
				 a_nodeID)

VDct1SearchForNodeInTree((a_treeID),
			 (a_testID),
			 (a_nodeType),
			 (b_nodeType),
			 (a_fld),
			 (b_fld),
			 (a_descendFlag),
			 (a_nodeID))
#endomdef
#endif

#if 0
// Find node in some tree somewhere
extern IGRstat VDct1SearchForNode __((TVDctSetType  treeType,
				      TVDctNodeType nodeType,
				      IGRchar      *attrName,
				      IGRchar      *attrValue,
				      IGRint        descendFlag,
				      TGRid        *nodeID));
#ifndef c_ONLY
#omdef vdct1$SearchForNode(treeType,
			   nodeType,
			   attrName,
			   attrValue,
			   descendFlag,
			   nodeID)
VDct1SearchForNode((treeType),(nodeType),(attrName),(attrValue),(descendFlag),(nodeID))
#endomdef
#endif
#endif

#if 0
// Return a list of all nodes under (and including)
// this node
// Support either type of vla
extern IGRstat VDct1GetNodesVLA __((TGRid    *nodeID, 
				    TVDvlaID *nodeVLA1,
				    TVDvlaid *nodeVLA2));

#ifndef c_ONLY
#omdef vdct1$GetNodesVLA(nodeID,nodeVLA1,nodeVLA2)
VDct1GetNodesVLA((nodeID),(nodeVLA1),(nodeVLA2))
#endomdef
#endif
#endif

#if 0
/* -------------------------------------------------------
 * Returns a value for number of protected attributes to display
 * on the Attribute Form
 * I - BASE_INFO   - baseInfo
 * 0 - ATTR_OFFSET - attrOffset
 * purpose to allow writing of node attributes to the two sections
 * on the attribute form without goofing up access to the attributes
 ************ ppl wrapper ******** VDct1Attr.I
 */
extern IGRstat VDct1GetAttrOffset __((TGRid *nodeID,IGRint *attrOffset));
#ifndef c_ONLY
#omdef vdct1$GetAttrOffset(nodeID,attrOffset)
VDct1GetAttrOffset((nodeID),(attrOffset))
#endomdef
#endif
#endif

/* --------------------------------------------------------------
 * Attribute Interface
 * set/VDct1Attr.I 
 */
extern IGRstat VDct1SetAttrInfo __((IGRchar *name,
				    IGRint   type,
				    IGRint   len,
				    IGRchar *base,
				    IGRchar *desc,
				    IGRchar *defaultValue,
				    IGRchar *pickList,
				    IGRchar *validate,
				    TVDctAttrInfo *attrInfo));


#ifndef c_ONLY
#omdef vdct1$SetAttrInfo(name,
			 type         = VDFLD_TYPE_TXT,
			 len          = VDFLD_MAX_TXT,
			 base         = NULL,
			 desc         = NULL,
			 defaultValue = NULL,
			 pickList     = NULL,
			 validate     = NULL,
			 attrInfo)
VDct1SetAttrInfo((name),(type),(len),(base),(desc),
		 (defaultValue),(pickList),(validate),(attrInfo))
#endomdef
#endif

extern IGRstat VDct1GetAttrInfo __((TGRid         *objID,
				    TVDctAttrName  attrName,
				    TVDctAttrInfo *attrInfo));
#ifndef c_ONLY
#omdef vdct1$GetAttrInfo(objID,attrName,attrInfo)
VDct1GetAttrInfo((objID),(attrName),(attrInfo))
#endomdef
#endif

/* -----------------------------------------------------------
 *   index number for the PPL routines from ../vdct1/post/VDct1Mino.I
 *   This is the FND ID numbers for FNDASSY and others
 */

/* ------------------------------------------
 * Wrapper to get next mino index
 * Updates the table
 */
extern IGRstat VDct1GetNextTreeNumber __((IGRint  *Index));

#ifndef c_ONLY
#omdef vdct1$GetNextTreeNumber (Index)
VDct1GetNextTreeNumber((Index))
#endomdef
#endif

/* ------------------------------------------
 * Wrapper to get next mino index
 * Updates the table
 */
extern IGRstat VDct1PostGetNextMinoIndex __((IGRchar *hullNum,
					     IGRchar *unitNum,
					     IGRchar *groupCode,
					     IGRint  *minoIndex));
#ifndef c_ONLY
#omdef vdct1$PostGetNextMinoIndex (hullNum,unitNum,groupCode,minoIndex)
VDct1PostGetNextMinoIndex((hullNum),(unitNum),(groupCode),(minoIndex))
#endomdef
#endif

/* ------------------------------------------
 * Wrapper to free mino index if it is the
 * Last number used
 */
extern IGRstat VDct1PostFreeMinoIndex __((IGRchar *hullNum,
					  IGRchar *unitNum,
					  IGRchar *groupCode,
					  IGRint   a_minoIndex));
#ifndef c_ONLY
#omdef vdct1$PostFreeMinoIndex(hullNum,unitNum,groupCode,minoIndex)
VDct1PostFreeMinoIndex ((hullNum),(unitNum),(groupCode),(minoIndex))
#endomdef
#endif

/* -----------------------------------------------------
 * set/VDct1CSMatrix.I
 */
/* ---------------------------------------------------
 * Get the matrix for a CS node which has for attributes
 * it is a matrix of 16 doubles which tells the location of 
 * the node in the ship 
 */
extern IGRstat VDct1CSGetNodeMatrix __((TGRid *nodeID,
					TGRobj_env *csOE));
#ifndef c_ONLY
#omdef vdct1$CSGetNodeMatrix(nodeID,csOE)
VDct1CSGetNodeMatrix((nodeID),(csOE))
#endomdef
#endif

#if 0
  /* ----------------------------------------------------
   * Set the CS node to 0.0 attributes to start
   */
extern IGRstat VDct1CSStartNodeMatrix __((TGRid *nodeID));
#ifndef c_ONLY
#omdef vdct1$CSStartNodeMatrix(nodeID)
VDct1CSStartNodeMatrix((nodeID))
#endomdef
#endif
#endif
#if 0
extern IGRstat VDct1SetNotifyBox __((IGRchar msg[256]));
#ifndef c_ONLY
#omdef vdct1$SetNotifyBox(msg)
VDct1SetNotifyBox((msg))
#endomdef
#endif
#endif

/* --------------------------------------------------------------
 * Low level channel manager, just wrappers to VDlnk functions
 */
#ifndef c_ONLY
#omdef vdct1$GetMgrParent(objID,        // I - Input Object
			  nth   = 0,    // I - Which Object on Channel
			  cnt   = NULL, // O - Number of Parents
			  outID = NULL  // O - Returned Parent
)
VDlnkGet ((objID), (VDCT_CHN_MGR_TO_PARENT), (nth), (cnt), (outID))

#endomdef
  
#omdef vdct1$GetMgrChild(objID,        // I - Input Object
			 nth   = 0,    // I - Which Object on Channel
			 cnt   = NULL, // O - Number of Children
			 outID = NULL  // O - Returned Child
)
VDlnkGet ((objID), (VDCT_CHN_MGR_TO_CHILD), (nth), (cnt), (outID))
#endomdef

#omdef vdct1$GetTree1Parent(objID,        // I - Input Object
			    nth   = 0,    // I - Which Object on Channel
			    cnt   = NULL, // O - Number of Children
			    outID = NULL  // O - Returned Child
)
VDlnkGet ((objID), (VDCT_CHN_TREE1_TO_PARENT), (nth), (cnt), (outID))
#endomdef


#omdef vdct1$GetTree1Child(objID,        // I - Input Object
			   nth   = 0,    // I - Which Object on Channel
			   cnt   = NULL, // O - Number of Children
			   outID = NULL  // O - Returned Child
)
VDlnkGet ((objID), (VDCT_CHN_TREE1_TO_CHILD), (nth), (cnt), (outID))
#endomdef

#omdef vdct1$GetTree2Parent(objID,        // I - Input Object
			    nth   = 0,    // I - Which Object on Channel
			    cnt   = NULL, // O - Number of Children
			    outID = NULL  // O - Returned Child
)
VDlnkGet ((objID), (VDCT_CHN_TREE2_TO_PARENT), (nth), (cnt), (outID))
#endomdef

#omdef vdct1$GetTree2Child(objID,        // I - Input Object
			   nth   = 0,    // I - Which Object on Channel
			   cnt   = NULL, // O - Number of Children
			   outID = NULL  // O - Returned Child
)
VDlnkGet ((objID), (VDCT_CHN_TREE2_TO_CHILD), (nth), (cnt), (outID))
#endomdef

#omdef vdct1$ConnectMgrChild(mgrID,    // I - ManagerID
			     childID   // I - ObjectID of Child
)
VDlnkConnect((VDCT_CHN_MGR), (mgrID), (childID))

#endomdef

#omdef vdct1$DisConnectMgrChild(mgrID,    // I - ManagerID
				childID   // I - ObjectID of Child
)
VDlnkDisconnect((VDCT_CHN_MGR), (mgrID), (childID))
#endomdef

#omdef vdct1$ConnectTree1Child(treeID,   // I - TreeID
			       childID   // I - ObjectID of Child
)
VDlnkConnect((VDCT_CHN_TREE1), (treeID), (childID))
#endomdef

#omdef vdct1$DisConnectTree1Child(treeID,   // I - TreeID
				  childID   // I - ObjectID of Child
)

VDlnkDisconnect((VDCT_CHN_TREE1), (treeID), (childID))
#endomdef

#omdef vdct1$ConnectTree2Child(treeID,   // I - TreeID
			       childID   // I - ObjectID of Child
)
VDlnkConnect((VDCT_CHN_TREE2), (treeID), (childID))
#endomdef

#omdef vdct1$DisConnectTree2Child(treeID,   // I - TreeID
				  childID   // I - ObjectID of Child
)
VDlnkDisconnect((VDCT_CHN_TREE2), (treeID), (childID))
#endomdef
#endif

#if 0

#define VDctxGetTree1Parent(objID,outID) VDlnkGet(objID,VDCT_CHN_TREE1_TO_PARENT,0,NULL,outID)

#define VDctxGetTree1Child(objID,nth,outID) VDlnkGet(objID,VDCT_CHN_TREE1_TO_CHILD,nth,NULL,outID)

#define VDctxConnectMgrChild(mgrID,childID) VDlnkConnect(VDCT_CHN_MGR,mgrID,childID)

#endif

#define VDctxSetAttrInfo(name,len,base,desc,info) \
  VDct1SetAttrInfo(name, VDFLD_TYPE_TXT,len,base,desc,NULL,NULL,NULL,info)

//Cleanup
#if defined(__cplusplus)
}
#endif

#endif






