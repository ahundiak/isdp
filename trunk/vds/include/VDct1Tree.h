/* $Id: VDct1Tree.h,v 1.11 2003/05/23 20:28:53 ylong Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/include/VDct1Tree.h
 *
 * Description: Custom tree Interface
 *
 *
 * Revision History:
 *      $Log: VDct1Tree.h,v $
 *      Revision 1.11  2003/05/23 20:28:53  ylong
 *      Modified for Placement Group Tree - yl
 *
 *      Revision 1.10  2002/05/24 17:48:24  jdsauby
 *      Added isConnectModelObjectValid per CR6383, JDS
 *
 *      Revision 1.9  2002/05/16 21:23:22  jdsauby
 *      JTSMP CR6359
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/12/00  ah      Created
 * 11/17/10  ah      SOL10 Group Tree
 ***************************************************************************/

#ifndef VDct1Tree_include
#define VDct1Tree_include

#ifndef   VDct1_include
#include "VDct1.h"
#endif

#ifndef   VDxml_include
#include "VDxml.h"
#endif

#ifndef   vdprocinfo_include
#include "vdprocinfo.h"
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* ----------------------------------------------------------
 * C++
 */
#if defined(__cplusplus)
extern "C" {
#endif

/* ------------------------------------------------ 
 * Master list of tree types
 */
#define VDCT1_TREE_TYPE_PLOT_TREE   "PlotTree"
#define VDCT1_TREE_TYPE_STD_PARTS   "StdParts"
#define VDCT1_TREE_TYPE_STD_ASSYS   "StdAssys"
#define VDCT1_TREE_TYPE_PAL_ASSYS   "PalAssys"
#define VDCT1_TREE_TYPE_DELTA_TREE  "DeltaTree"

#define VDCT1_TREE_TYPE_OUTFIT_TREE "OutfitTree"
#define VDCT1_TREE_TYPE_CABLE_TREE  "CableTree"
#define VDCT1_TREE_TYPE_WWAY_TREE   "WWayTree"
#define VDCT1_TREE_TYPE_HVAC_TREE   "HvacTree"
#define VDCT1_TREE_TYPE_PIPE_TREE   "PipeTree"

#define VDCT1_TREE_TYPE_GRP_PLACE   "SirGrpPlace"

/* -------------------------------------------------
 * Abstract tree types
 */
#define VDCT1_TREE_TYPE_ROOT_TREE   "RootTree"
#define VDCT1_TREE_TYPE_PROD_TREE   "ProdTree"
#define VDCT1_TREE_TYPE_ENG_TREE    "EngTree"

/* -----------------------------------------------
 * Main implementation data structure
 */
typedef struct TVDct1BaseInterface
{
  // Parent Class
  void *parentCL;
  
  // System Class Type
  IGRchar className[32];
  IGRint  classID;
  
  // Local Data
  TVDctSetTypeInfo info;
  
  // Methods
  IGRstat  (*hello)(TVDct1JD *nodeJD);
  
  IGRstat  (*getSetTypeInfo)(TVDct1JD *setJD,
			     TVDctSetTypeInfo *info);

  IGRstat  (*getNodeTypeInfo)(TVDct1JD *nodeJD,
			      IGRint    nth, 
			      IGRint   *cnt, 
			      TVDctNodeTypeInfo *info);

  IGRstat  (*getNodeAttrInfo)(TVDct1JD *nodeJD,
			      IGRchar  *name, 
			      TVDctAttrInfo *info);

  IGRstat  (*getNodeAttrName)(TVDct1JD *nodeID,
			      IGRchar  *nodeType,
			      IGRint    nth,
			      IGRchar  *attrName);
  
  IGRstat  (*getFilter)(TVDct1JD *setJD,
			OM_S_CLASSLIST *classList);
  
  IGRstat  (*createNode)(TVDct1JD *parentJD,
			 IGRchar  *nodeType, 
			 IGRchar  *nodeName,
			 TVDct1JD *nodeJD);

  IGRstat  (*createSet) (TVDct1JD *mgrJD,
			 IGRchar  *setType,
			 IGRchar  *setTypeRev,
			 IGRchar  *setName,
			 TVDct1JD *setJD);

  IGRstat  (*getRootNodeTypeForSet)(TVDct1JD *mgrJD,
				    IGRchar  *setType,
				    IGRchar  *setName,
				    IGRchar  *nodeType);
  
  IGRstat  (*isChildTypeValid)(TVDct1JD *parentJD,
			       IGRchar  *childType);
  
  IGRstat  (*preExpandContractNode)(TVDct1JD *nodeJD, 
				    IGRchar  *op);
  

  /* ---------------------------------------------
   * Searches tree for a node
   */
#define VDCT1_FIND_NODE_OPT_NONE        0
#define VDCT1_FIND_NODE_OPT_ENTIRE_TREE 1
#define VDCT1_FIND_NODE_OPT_NODE_DOWN   2
#define VDCT1_FIND_NODE_OPT_NODE_KIDS   3
#define VDCT1_FIND_NODE_OPT_NODE_CUR    4

#define VDCT1_FIND_NODE_OPT_ALL_CUR_FILE  10
#define VDCT1_FIND_NODE_OPT_ALL_FILES     11
#define VDCT1_FIND_NODE_OPT_POSTED_FILES  12

  IGRstat (*findNodeByTypeName)(TVDct1JD *nodeJD,
				IGRint    isCaseSensitive,
				IGRint    opt,
				IGRchar  *nodeType,
				IGRchar  *nodeName,
				TVDct1JD *foundJD);

  /* ---------------------------------------------
   * Same idea as for node except the osnum in nodeJD
   * is used in conjunction with the opt arg
   * To control search range
   */
#define VDCT1_FIND_SET_OPT_NONE           0
#define VDCT1_FIND_SET_OPT_CUR_SET       20
#define VDCT1_FIND_SET_OPT_CUR_FILE      21
#define VDCT1_FIND_SET_OPT_ALL_FILES     22
#define VDCT1_FIND_SET_OPT_POSTED_FILES  23

  IGRstat (*findTreeByTypeName)(TVDct1JD *nodeJD,
				IGRint    isCaseSensitive,
				IGRint    opt,
				IGRchar  *setType,
				IGRchar  *setName,
				TVDct1JD *foundJD);

  IGRstat (*findSetByTypeName)(TVDct1JD *nodeJD,
			       IGRint    isCaseSensitive,
			       IGRint    opt,
			       IGRchar  *setType,
			       IGRchar  *setName,
			       TVDct1JD *foundJD);
 
  /* Used by the find routines */
  IGRint (*sortTypeName)(TVDct1JD *nodeJD,
			 IGRint    isCaseSensitive,
			 IGRchar  *type1,
			 IGRchar  *type2,
			 IGRchar  *name1,
			 IGRchar  *name2);

  // find node by attribute value from current node down
  IGRstat (*findNodeByAttrValue)(TVDct1JD *nodeJD,
				 IGRchar  *attrName,
				 IGRchar  *attrValue,
				 TVDct1JD *foundJD);
  
  /* ---------------------------------------------
   * Checks to see if a node name is valid i.e. no
   * illegael characters and maybe checking against
   * databases or what not
   *
   * This routine may convert an invalid name to a valid name
   * In particular, it may uppercase it
   * 
   * May need separate convert routine is this changing
   * causes a problem
   *
   * The results will have a message suitable for displaying
   * in a status box
   */

  IGRstat (*isFirstCharOK)(TVDct1JD *parentJD,
			   IGRchar  *name);
  
  IGRstat (*cleanName)(TVDct1JD *parentJD,
		       IGRchar  *ame);

  IGRstat (*isNodeNameValid)(TVDct1JD *parentJD,
			     IGRchar  *nodeType,
			     IGRchar  *nodeName,
			     IGRchar  *results);

  /* ---------------------------------------------
   * Same but for the set, this will actually get the
   * default node type that will end up being created when
   * the set is created and then calling isNodeNameValid
   */
  IGRstat (*isSetNameValid)(TVDct1JD *parentJD,
			    IGRchar  *setType,
			    IGRchar  *setName,
			    IGRchar  *results);

  /* ---------------------------------------------
   * Attribute processing
   */
  IGRstat (*computeDate)(TVDct1JD *nodeJD, 
			 IGRchar  *attrName);

  IGRstat (*computeUM)(TVDct1JD *nodeJD, 
		       IGRchar  *attrName);

  // generic recomputer
  IGRstat (*computeNode)(TVDct1JD *nodeJD);
  
  IGRstat (*reComputeNode)(TVDct1JD *nodeJD);
  
  IGRstat (*reComputeStdAssy)(TVDct1JD *nodeJD);
  
  IGRstat (*verifyModelAttrs)(TVDct1JD *nodeJD);

  // Assign unique number to a tree
  IGRstat (*setAttrTreeNum)(TVDct1JD *nodeJD);

  // Assign unique number withing a tree
  IGRstat (*setAttrNodeNum)(TVDct1JD *nodeJD);
  
  /* ---------------------------------------------
   * Try moving low level routines here and see if they
   * get out of control
   * VDct1RootTree2.I
   */
  IGRstat (*pullDownAttr)  (TVDct1JD *nodeJD, IGRchar *name);

  IGRstat (*setAttr)(TVDct1JD *nodeJD, IGRchar *name, IGRchar *value);
  IGRstat (*getAttr)(TVDct1JD *nodeJD, IGRchar *name, IGRchar *value);

  IGRstat (*updateAttr)(TVDct1JD *nodeJD, IGRchar *name, IGRchar *value);

  IGRstat (*setPrivateAttr)(TVDct1JD *nodeJD, IGRchar *name, IGRchar *value);
  IGRstat (*getPrivateAttr)(TVDct1JD *nodeJD, IGRchar *name, IGRchar *value);

  IGRstat (*createAttr)       (TVDct1JD *nodeJD, IGRchar *name, IGRint type, IGRchar *value);
  IGRstat (*createPrivateAttr)(TVDct1JD *nodeJD, IGRchar *name, IGRint type, IGRchar *value);

  IGRstat (*getBaseInfo)(TVDct1JD *nodeJD, TVDctBaseInfo *baseInfo);
  IGRstat (*setBaseInfo)(TVDct1JD *nodeJD, TVDctBaseInfo *baseInfo);
  
  IGRstat (*setNodeInfo)(TVDct1JD *nodeJD, TVDct1NodeInfo *nodeInfo);
  IGRstat (*getNodeInfo)(TVDct1JD *nodeJD, TVDct1NodeInfo *nodeInfo);

#define VDCT1_SET_NODE_INFOS_ENTIRE_TREE  0
#define VDCT1_SET_NODE_INFOS_NODE_DOWN    1
  IGRstat (*setNodeInfos)(TVDct1JD *nodeJD, IGRint opt, TVDct1NodeInfos *nodeInfos);

  IGRstat (*getNthInfoFromNodeInfos)(TVDct1JD        *nodeJD,
				     TVDct1NodeInfos *nodeInfos,
				     IGRint           nth,
				     TVDct1NodeInfo  *nodeInfo);

  IGRstat (*getTreeChild )(TVDct1JD *nodeJD, IGRint nth, TVDct1JD  *childJD);
  IGRstat (*getTreeParent)(TVDct1JD *nodeJD,             TVDct1JD *parentJD);

  IGRstat (*connectTreeChild   )(TVDct1JD *treeJD, TVDct1JD *childJD);
  IGRstat (*disconnectTreeChild)(TVDct1JD *treeJD, TVDct1JD *childJD);

  IGRstat (*getMgrChild  )(TVDct1JD *nodeJD, IGRint nth, TVDct1JD  *childJD);
  IGRstat (*getMgrParent )(TVDct1JD *nodeJD,             TVDct1JD *parentJD);

  IGRstat (*connectMgrChild   )(TVDct1JD *mgrJD, TVDct1JD *childJD);
  IGRstat (*disconnectMgrChild)(TVDct1JD *mgrJD, TVDct1JD *childJD);
  

  IGRstat (*   getManager)(TVDct1JD *mgrJD);  
  IGRstat (*createManager)(TVDct1JD *mgrJD);
  
  IGRstat (*getNodeForSet)  (TVDct1JD  *setJD, TVDct1JD *nodeJD);
  IGRstat (*getSetForNode)  (TVDct1JD *nodeJD, TVDct1JD  *setJD);
  IGRstat (*getRootForNode) (TVDct1JD *nodeJD, TVDct1JD  *rootJD);

  IGRstat (*       getModelObject) (TVDct1JD *nodeJD, TGRobj_env *modelOE);
  IGRstat (*   connectModelObject) (TVDct1JD *nodeJD, TGRobj_env *modelOE);
  IGRstat (*disconnectModelObject) (TVDct1JD *nodeJD, TGRobj_env *modelOE);
  IGRstat (*isModelObjectValid)    (TVDct1JD *nodeJD, TGRobj_env *modelOE);

  IGRstat (*isConnectModelObjectValid) (TVDct1JD *nodeJD, TGRobj_env *modelOE);

  IGRstat (*getModelPartData)(TVDct1JD *nodeJD,VDprcAttr *mp);
  
  IGRstat (*isDisplayOnTreeFOK)(TVDct1JD *nodeJD,IGRint dispFlag);

  IGRstat (*getTypeForModelObject)(TVDct1JD      *parentNodeJD,
				   TGRobj_env    *modelOE,
				   TVDctNodeType  nodeType);

  IGRstat (*copyAttributesFromModelToNode)(TVDct1JD   *nodeJD,
					   TGRobj_env *modelOE);
  
  IGRstat (*copyAttributeFromModelToNode)(TVDct1JD   *nodeJD, 
					  IGRchar    *nodeAttrName,
					  TGRobj_env *modelOE,
					  IGRchar    *modelAttrName);
  
  IGRstat (*displayNode)(TVDct1JD      *nodeJD,
			 enum GRdpmode mode,
			 IGRint        flag);
  
  IGRstat (*getModelObjectNodeFilter)(TVDct1JD        *nodeJD,    // I - node object
				      TVDctSetType     setType,   // I - filter
				      TVDctSetTypeRev  setRev,    // I - filter
				      TVDctSetName     setName);  // I - filter

  IGRstat (*getModelObjectNode)(TVDct1JD        *fakeJD,    // I - just because we need class
				TGRobj_env      *a_modelOE, // I - model object
				TGRid           *a_modelID, // I - model object
				TVDctSetType     setType,   // I - filter
				TVDctSetTypeRev  setRev,    // I - filter
				TVDctSetName     setName,   // I - filter
				TVDct1JD        *nodeJD);   // O - The node

  IGRstat (*getNodeNameForModelObject)(TVDct1JD      *nodeJD,
				       TGRobj_env    *modelOE,
				       TVDctNodeName  nodeName);

  IGRstat (*getParentForModelObject)(TVDct1JD   *parentJD,
				     TGRobj_env *modelOE);
  
  IGRstat (*isPartInOPS)(TVDct1JD   *nodeJD,
			 TGRobj_env *modelOE);
  
  IGRstat (*getComptNumberAttrForCableObject)(TVDct1JD   *nodeJD,
					      TGRobj_env *modelOE,
					      IGRchar    *attrCompt);

  IGRstat (*getUnitNumberAttrForCableObject)(TVDct1JD   *nodeJD,
					     TGRobj_env *modelOE,
					     IGRchar    *attrUnit);
  
  IGRstat (*createBaseObject)(TVDct1JD *baseJD, TVDclaType classType);

  IGRstat (*deleteNode)(TVDct1JD *nodeJD);

  /* -----------------------------------------------
   * Mark current node, and the children as deleted
   * **/
  IGRstat (*markNodeAsDeleted)(TVDct1JD *nodeJD);

  IGRstat (*markNodeAsActive)(TVDct1JD *nodeJD);

  /* -----------------------------------------------
   * Delete Nodes which are marked as deleted
   * **/
  IGRstat (*deleteMarkedNodes)(TVDct1JD *nodeJD);

  /* ---------------------------------------------
   * Posting stuff
   */
  IGRstat (*postNode)(TVDct1JD *nodeJD, FILE *file);

  IGRstat (*postTree)    (TVDct1JD *treeJD, FILE *file);
  IGRstat (*postTreeBeg) (TVDct1JD *treeJD, FILE *file);
  IGRstat (*postTreeEnd) (TVDct1JD *treeJD, FILE *file);
  IGRstat (*postTreeNode)(TVDct1JD *nodeJD, FILE *file);

  IGRstat (*isTreePostable)  (TVDct1JD *treeJD);
  IGRstat (*getTreePostTable)(TVDct1JD *treeJD, IGRchar *tableName);
  
  /* --------------------------------------------
   * Update utility
   * **/
  IGRstat (*updateNodesOnTree) (TVDct1JD *treeJD);

} TVDct1BaseInterface;
  
/* ---------------------------------------------
 * Interface for command specific methods
 */
typedef struct
{
  IGRstat (*getGadgetText)(TVDct1JD *nodeJD,
			   IGRchar  *formName,
			   IGRint    gadget,
			   IGRint    nth,
			   IGRchar  *text);

  IGRstat (*getPasteNodeType)(TVDct1JD          *parentJD, 
			      TVDct1JD          *copyJD,
			      TVDctNodeTypeInfo *info);

  IGRstat (*createNodeByQuery)(TVDct1JD         *parentJD);

  IGRstat (*makeNodeName)(TVDct1JD      *parentJD,   
			  TVDctBaseInfo *baseInfo); 

  IGRstat (*isConvertNodeValid)(TVDct1JD *nodeJD,
                                IGRchar  *activeNodeType,
				IGRchar  *newNodeType);
  
  IGRstat (*convertNode)(TVDct1JD  *activeNodeJD,
			 IGRchar   *newNodeType,
			 IGRchar   *newNodeName);

  IGRstat (*isRenameNodeValid)(TVDct1JD *nodeJD,
			       IGRchar  *nodeType);
  
  IGRstat (*isPasteNodeValid)(TVDct1JD *parentJD,
			      TVDct1JD *copiedJD);
  
  IGRstat (*isMoveNodeValid)(TVDct1JD  *parentJD,
			     TVDct1JD  *movedJD);

  IGRstat (*isDeleteNodeValid)(TVDct1JD  *activeJD,
			       TVDct1JD  *parentJD);

  IGRstat (*isDeleteTreeValid)(TVDct1JD  *treeJD);

  IGRstat (*isCreateTreeValid)(TVDct1JD  *setJD,
			       IGRchar   *setType);
  
  IGRstat (*isRenameTreeValid)(TVDct1JD  *treeJD);
      
  IGRstat (*isAttrUpdateValid)(TVDct1JD  *nodeJD,
			       IGRchar   *attrName);
  
  IGRstat (*computeMoveCopyNode)(TVDct1JD  *parentJD,
				 TVDct1JD  *nodeJD);
  
  IGRstat (*copyNodeAttributes)(TVDct1JD *desJD,
				TVDct1JD *srcJD);

  IGRstat (*updateNodeAttributes)(TVDct1JD *nodeJD);

  IGRstat (*updateChildAttrValue)(TVDct1JD *nodeJD,
				  IGRchar  *attrName,
				  IGRchar  *attrValue);
  
  IGRstat (*isAttrPropagateValid)(TVDct1JD *nodeJD,
				  IGRchar  *attrName);
  
  IGRstat (*validateAttrValue)(TVDct1JD *nodeJD,
			       IGRchar  *attrName,
			       IGRchar  *attrValue,
			       IGRchar  *attrValuex,
			       IGRchar  *msg);

  IGRstat (*setNodeUserInfo)(TVDct1JD       *nodeJD,
			     TVDct1UserInfo *info);
  
  IGRstat (*getNewParentForPastedNode)(TVDct1JD *parentJD,     // I - needed for class
				       TVDct1JD *copiedJD,     // I - the node beind pasted
				       TVDct1JD *newParentJD); // 0 - the new Parent

  IGRstat (*isNodeInfoForPasteValid)(TVDct1JD       *parentJD,
				     TVDct1NodeInfo *nodeInfo);

  IGRstat  (*isUnmarkDeletedValid)(TVDct1JD *nodeJD);



  IGRstat (*isMarkDeletedOK)(TVDct1JD *nodeJD);
} TVDct1CmdInterface;

/* ---------------------------------------------
 * XML Interface
 */
typedef struct
{
  IGRstat (*writeNode)(TVDct1JD *setJD,
		       TVDxmlFileInfo *xml);

  IGRstat (*writeBuf)(TVDct1JD *setJD,
		      IGRchar  **buf);

  IGRstat (*writeFile)(TVDct1JD *setJD,
		       IGRchar  *fileName,
		       IGRchar  *results);

  IGRstat (*writeSchemaFile)(TVDct1JD *setJD,
			     IGRchar  *fileName,
			     IGRchar  *results);

  IGRstat (*writeSchemaSet)(TVDct1JD       *setJD,
			    TVDxmlFileInfo *xml);

  IGRstat (*writeSchemaNode)(TVDct1JD          *setJD,
			     TVDxmlFileInfo    *xml,
			     TVDctNodeTypeInfo *nodeTypeInfo);

  IGRstat (*readSchema)(TVDct1JD *nodeJD, 
			IGRchar  *fileName, 
			IGRchar  *buf);
  

} TVDct1XmlInterface;

/* ---------------------------------------------
 * Interface for production specific methods
 */
typedef struct
{
  IGRstat (*getCageNum)(TVDct1JD *nodeJD,
			IGRchar  *cage_num);

  IGRstat (*isCommCodeValid)(TVDct1JD *nodeJD,
			     IGRchar  *comm_code);

  IGRstat (*getValidCommCode)(TVDct1JD      *parentJD,
			      TVDctBaseInfo *baseInfo,
			      IGRchar       *comm_code);

  IGRstat (*setAttrRev)(TVDct1JD *nodeJD,
			IGRchar  *value);

  IGRstat (*setAttrNodeCount)(TVDct1JD *nodeJD,
			      IGRchar  *value);

  IGRstat (*setStatus)(TVDct1JD *nodeJD,
		       IGRchar  *status);

  IGRstat (*isFreezeOK)(TVDct1JD *nodeJD);

  IGRstat (*isReviseOK)(TVDct1JD *nodeJD);

  IGRstat (*getHighestRev)(TVDct1JD *nodeJD,
			  IGRint *highestRev);


} TVDct1ProdInterface;

/* ---------------------------------------------
 * Interface for engineering specific methods
 */
typedef struct
{
  IGRstat (*setElecPalletCode)(TVDct1JD *parentJD,
			       TVDct1JD *nodeJD);
  
  IGRstat (*computeEngAssy2Name)(TVDct1JD      *parentJD,
				 TVDctBaseInfo *baseInfo);

  IGRstat (*computeEngAssy6Name)(TVDct1JD      *parentJD,
				 TVDctBaseInfo *baseInfo); 

  IGRstat (*deleteAllChildNodes)(TVDct1JD  *activeNodeJD);

  /* -------------------------------------------------
 * set percent of MINO and COPICS Number attributes
 */
  IGRstat (*computeCopicsInfo)(TVDct1JD      *nodeJD,
			       TVDctBaseInfo *baseInfo);

} TVDct1EngInterface;

/* ---------------------------------------------
 * Defined names and ids for the various classes
 */
#define VDCT1_CLASSN_ROOT_TREE      "TVDct1RootTree"
#define VDCT1_CLASSI_ROOT_TREE      10
#define VDCT1_CLASSN_PLOT_TREE      "TVDct1PlotTree"
#define VDCT1_CLASSI_PLOT_TREE      11
#define VDCT1_CLASSN_PROD_TREE      "TVDct1ProdTree"
#define VDCT1_CLASSI_PROD_TREE      12
#define VDCT1_CLASSN_STD_PARTS_TREE "TVDct1StdPartsTree"
#define VDCT1_CLASSI_STD_PARTS_TREE 13
#define VDCT1_CLASSN_STD_ASSYS_TREE "TVDct1StdAssysTree"
#define VDCT1_CLASSI_STD_ASSYS_TREE 14
#define VDCT1_CLASSN_PAL_ASSYS_TREE "TVDct1PalAssysTree"
#define VDCT1_CLASSI_PAL_ASSYS_TREE 15
#define VDCT1_CLASSN_ENG_TREE       "TVDct1EngTree"
#define VDCT1_CLASSI_ENG_TREE       16
#define VDCT1_CLASSN_OUTFIT_TREE    "TVDct1OutfitTree"
#define VDCT1_CLASSI_OUTFIT_TREE    17
#define VDCT1_CLASSN_ELEC2D_TREE    "TVDct1Elec2dTree"
#define VDCT1_CLASSI_ELEC2D_TREE    18
#define VDCT1_CLASSN_ELEC3D_TREE    "TVDct1Elec3dTree"
#define VDCT1_CLASSI_ELEC3D_TREE    19

#define VDCT1_CLASSN_GRP_PLACE_TREE "TVDct1GrpPlaceTree"
#define VDCT1_CLASSI_GRP_PLACE_TREE 20

/* ---------------------------------------------
 * Actual tree classes
 */
typedef struct 
{
  TVDct1BaseInterface base;
  TVDct1XmlInterface  xml;
  TVDct1CmdInterface  cmd;
} TVDct1RootTreeClass;

typedef struct 
{
  TVDct1BaseInterface base;
  TVDct1XmlInterface  xml;
  TVDct1CmdInterface  cmd;
} TVDct1PlotTreeClass;

typedef struct 
{
  TVDct1BaseInterface base;
  TVDct1XmlInterface  xml;
  TVDct1CmdInterface  cmd;
  TVDct1ProdInterface prod;
} TVDct1ProdTreeClass;

typedef struct 
{
  TVDct1BaseInterface base;
  TVDct1XmlInterface  xml;
  TVDct1CmdInterface  cmd;
  TVDct1ProdInterface prod;
} TVDct1StdPartsTreeClass;

typedef struct 
{
  TVDct1BaseInterface base;
  TVDct1XmlInterface  xml;
  TVDct1CmdInterface  cmd;
  TVDct1ProdInterface prod;
} TVDct1StdAssysTreeClass;

typedef struct 
{
  TVDct1BaseInterface base;
  TVDct1XmlInterface  xml;
  TVDct1CmdInterface  cmd;
  TVDct1ProdInterface prod;
} TVDct1PalAssysTreeClass;

typedef struct 
{
  TVDct1BaseInterface base;
  TVDct1XmlInterface  xml;
  TVDct1CmdInterface  cmd;
  TVDct1ProdInterface prod;
} TVDct1DeltaTreeClass;

typedef struct
{
  TVDct1BaseInterface base;
  TVDct1XmlInterface  xml;
  TVDct1CmdInterface  cmd;
  TVDct1ProdInterface prod;
  TVDct1EngInterface  eng;
} TVDct1EngTreeClass;

typedef struct
{
  TVDct1BaseInterface base;
  TVDct1XmlInterface  xml;
  TVDct1CmdInterface  cmd;
  TVDct1ProdInterface prod;
  TVDct1EngInterface  eng;
} TVDct1OutfitTreeClass;

typedef struct
{
  TVDct1BaseInterface base;
  TVDct1XmlInterface  xml;
  TVDct1CmdInterface  cmd;
  TVDct1ProdInterface prod;
  TVDct1EngInterface  eng;
} TVDct1CableTreeClass;

typedef struct
{
  TVDct1BaseInterface base;
  TVDct1XmlInterface  xml;
  TVDct1CmdInterface  cmd;
  TVDct1ProdInterface prod;
  TVDct1EngInterface  eng;
} TVDct1WWayTreeClass;

typedef struct
{
  TVDct1BaseInterface base;
  TVDct1XmlInterface  xml;
  TVDct1CmdInterface  cmd;
  TVDct1ProdInterface prod;
  TVDct1EngInterface  eng;
} TVDct1HvacTreeClass;

typedef struct
{
  TVDct1BaseInterface base;
  TVDct1XmlInterface  xml;
  TVDct1CmdInterface  cmd;
  TVDct1ProdInterface prod;
  TVDct1EngInterface  eng;
} TVDct1GrpPlaceTreeClass;


// Save some typing
typedef TVDct1RootTreeClass TVDct1RTC;

/* Make it easier to typecast the void class pointer
 * To the generic root tree class
 *
 * Should be possible to do this inline but don't
 * Know how yet
 */
extern TVDct1RootTreeClass *_RTCJD  __((TVDct1JD *objJD));
extern TVDct1BaseInterface *_RTCJDB __((TVDct1JD *objJD));
extern TVDct1CmdInterface  *_RTCJDC __((TVDct1JD *objJD));
extern TVDct1XmlInterface  *_RTCJDX __((TVDct1JD *objJD));

extern TVDct1ProdInterface *_PTCJDP __((TVDct1JD *objJD));
extern TVDct1EngInterface  *_ETCJDE __((TVDct1JD *objJD));

// Returns setType for trace statements
extern IGRchar *_RTCJDBC __((TVDct1JD *objJD));

/* ---------------------------------------------
 * Main interface to getting the function trees
 * Keep these as void for now
 */
extern void *VDct1GetTreeClassForSetType __((IGRchar *setType));
extern void *VDct1GetTreeClassForNode    __((TGRid   *nodeID));
extern void *VDct1GetTreeClassForNth     __((IGRint   nth));

/* -------------------------------------------------------------------
 * Use this to get the parent class for accessing
 * ancestor methods
 */
extern void *VDct1GetParentTreeClassForSetType __((IGRchar *setType));

/* ---------------------------------------------
 * Maybe times (during startup) when want to 
 * get a default tree class jus to get going
 */
extern TVDct1RootTreeClass *VDct1GetRootTreeClass __(());

/* --------------------------------------------------------
 * Probably to use ForSetType if actually needed
 */
extern TVDct1ProdTreeClass *VDct1GetProdTreeClass __(());
extern TVDct1EngTreeClass  *VDct1GetEngTreeClass  __(());
  
extern IGRstat VDct1TestTreeClassMgr __(());
extern IGRstat VDct1InitTreeClassMgr __(());

/* ---------------------------------------------
 * Each tree has an init routine to fill up the pointers
 */
extern IGRstat VDct1InitRootTreeClass  __((TVDct1RootTreeClass *root));
extern IGRstat VDct1InitRootTreeClass2 __((TVDct1RootTreeClass *root));
extern IGRstat VDct1InitRootTreeClassC __((TVDct1RootTreeClass *root));
extern IGRstat VDct1InitRootTreeClassX __((TVDct1RootTreeClass *root));
extern IGRstat VDct1InitModel          __((TVDct1RootTreeClass *root));
extern IGRstat VDct1InitRootTreeClassP __((TVDct1RootTreeClass *root));
extern IGRstat VDct1InitRootTreeClassM __((TVDct1RootTreeClass *root));

extern IGRstat VDct1InitPlotTreeClass  __((TVDct1RootTreeClass *root, 
					   TVDct1PlotTreeClass *tree));

extern IGRstat VDct1InitProdTreeClass  __((TVDct1RootTreeClass *root, 
					   TVDct1ProdTreeClass *tree));

extern IGRstat VDct1InitStdPartsTreeClass __((TVDct1ProdTreeClass     *prod, 
					      TVDct1StdPartsTreeClass *tree));

extern IGRstat VDct1InitStdAssysTreeClass __((TVDct1ProdTreeClass     *prod, 
					      TVDct1StdAssysTreeClass *tree));

extern IGRstat VDct1InitEngTreeClass __((TVDct1ProdTreeClass     *prod, 
					 TVDct1EngTreeClass *tree));

extern IGRstat VDct1InitOutfitTreeClass __((TVDct1EngTreeClass    *eng, 
					    TVDct1OutfitTreeClass *tree));

extern IGRstat VDct1InitCableTreeClass __((TVDct1EngTreeClass    *eng, 
					   TVDct1CableTreeClass *tree));

extern IGRstat VDct1InitWWayTreeClass __((TVDct1EngTreeClass    *eng, 
					  TVDct1WWayTreeClass *tree));

extern IGRstat VDct1InitHvacTreeClass __((TVDct1EngTreeClass    *eng, 
					  TVDct1HvacTreeClass *tree));

extern IGRstat VDct1InitGrpPlaceTreeClass __((TVDct1EngTreeClass      *eng, 
					      TVDct1GrpPlaceTreeClass *tree));

extern IGRstat VDct1CopyRootImps __((void *parent, void *child));

/* ---------------------------------------------
 * Engineering Attributes Utility
 */
extern IGRstat VDct1EngTreeGetAttrInfo __((IGRchar       *name, 
					   TVDctAttrInfo *info));

extern IGRstat VDct1UpdNodeAttr  __((TGRid   *nodeID, 
				     IGRchar *name, 
				     IGRchar *value));

extern IGRstat VDct1PullDownAttr __((TGRid   *nodeID, 
				     IGRchar *attrName));

extern IGRstat VDct1GetMiscStaticAttrValue __((TVDct1JD   *nodeJD,
					       TGRobj_env *modelOE,
					       IGRchar    *attrName,
					       IGRchar    *attrValue));

extern IGRstat VDct1IsCreateTreeAccessAllowed __((IGRchar *setType,
						  IGRchar *pdm_catalog));


/* ---------------------------------------------
 * Clipboard Utilities
 */
extern IGRstat VDct1GetNthIDFromVLAID  __((IGRint nth, TGRid   *nodeID));

extern IGRstat VDct1GetLastIDFromVLAID __((TGRid   *nodeID));

/* -----------------------------------------
 * Function defined in cmd2/VDct1TreeF.C.  
 * It is a wrapper around updateNodesOnTree.  
 */
extern IGRstat VDct1ScanTree __((TGRid *setID));


/* ------------------------- */
#if defined(__cplusplus)
}
#endif

#endif

