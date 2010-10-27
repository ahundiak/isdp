/* $Id: VDatProto.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDatPROTO.h
 *
 * Description: Master assembly tree prototypes
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatProto.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.3  1998/11/07  13:50:30  pinnacle
 * ah
 *
 * Revision 1.2  1998/10/25  11:57:30  pinnacle
 * ah
 *
 * Revision 1.2  1998/10/08  20:34:22  pinnacle
 * ah
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.19  1998/03/22  19:15:56  pinnacle
 * AssyTree
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/25/97  ah      Creation
 * 02/25/98  ah      PPL Friendly
 ***************************************************************************/

#ifndef VDatPROTO_include
#define VDatPROTO_include

// Usual c++ stuff
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

// -----------------------------------------------------------
// post/VDatPdm.I
#if defined(__cplusplus)
extern "C" {
#endif

extern IGRstat VDatGetPdmMgr      __((VDosnum osnum, TGRid   *mgrID));
extern IGRstat VDatCreatePdmMgr   __((VDosnum osnum, TGRid   *mgrID));
extern IGRstat VDatGetPdmMgrPath  __((VDosnum osnum, IGRchar *mgrPath));

extern IGRstat VDatPOSTGetPDMInfo __((VDosnum osnum, TVDatPDMInfo *info));
extern IGRstat VDatPOSTGetFileKey __((TVDatPDMInfo *info, IGRboolean createKey));
//extern IGRstat VDatAddFileToPdmFlds(TVDatFld *fld, VDosnum refOSnum)

extern IGRstat VDatPOSTGetNextSetKey  __((IGRkey  *theKEY));
extern IGRstat VDatPOSTGetNextFileKey __((IGRkey  *theKEY)); 
extern IGRstat VDatPOSTGetNextKey     __((IGRchar *keyName, IGRkey *theKEY));

#omdef vdat$GetPdmMgr(
  osnum =  OM_K_NOT_AN_OS,
  mgrID
)
VDatGetPdmMgr((osnum),(mgrID))
#endomdef

#omdef vdat$CreatePdmMgr(
  osnum =  OM_K_NOT_AN_OS,
  mgrID
)
VDatCreatePdmMgr((osnum),(mgrID))
#endomdef

#if defined(__cplusplus)
}
#endif

// -----------------------------------------------------------
// set/VDatMisc.I
#if defined(__cplusplus)
extern "C" {
#endif

extern IGRstat VDatSetDefaultAttrs __((TGRid *objID));
extern IGRstat VDatGetChildrenVLA  __((TGRid *objID, TVDvlaID *ids));

#if defined(__cplusplus)
}
#endif

// -----------------------------------------------------------
// set/VDatLeaf.I
#if defined(__cplusplus)
extern "C" {
#endif

extern IGRstat VDatCreateLeaf  __((TGRid *setID, TGRobj_env *objOE, TGRid *leafID));
extern IGRstat VDatCreateLeafs __((TGRid *setID, TGRid *leafsID));

extern IGRstat VDatGetLeafs    __((TGRid *setID, TGRid    *leafsID));
extern IGRstat VDatGetLeafsVLA __((TGRid *objID, TVDvlaID *leafVLA));

extern IGRstat VDatGetLeafObject __((TGRid *leafID, TGRobj_env *objOE));
extern IGRstat VDatGetLeafPath   __((TGRid *leafID, IGRchar *pathName));
extern IGRstat VDatGetLeafName   __((TGRid *leafID, IGRchar *leafName));

#if defined(__cplusplus)
}
#endif

// -----------------------------------------------------------
// set/VDatNode.I
#if defined(__cplusplus)
extern "C" {
#endif

extern IGRstat VDatGetParentNode __((TGRid *objID, TGRid   *parentID));
extern IGRstat VDatGetNodesVLA   __((TGRid *objID, TVDvlaID *nodeVLA));
extern IGRstat VDatGetNodePath   __((TGRid *objID, IGRchar *nodePath));
extern IGRstat VDatDeleteNode    __((TGRid *objID));

extern IGRstat VDatCreateNode __((
  TGRid   *parentID, 
  TGRid   *rdbNodeID, 
  IGRchar *nodeName,
  TGRid   *nodeID
));

#if defined(__cplusplus)
}
#endif

// -----------------------------------------------------------
// set/VDatTree.I
#if defined(__cplusplus)
extern "C" {
#endif

extern IGRstat VDatGetTree     __((TGRid *objID, TGRid   *treeID));
extern IGRstat VDatGetTreeName __((TGRid *objID, IGRchar *treeName));

extern IGRstat VDatGetTreeByName __((TGRid *mgrID, IGRchar *treeName, TGRid *treeID));

extern IGRstat VDatGetTreesVLA __((TGRid *objID, TVDvlaID *treeVLA));
extern IGRstat VDatGetTrees    __((TGRid *objID, TGRid    *treesID));

extern IGRstat VDatCreateTrees __((TGRid *setID, TGRid    *treesID));
extern IGRstat VDatCreateTree  __((
  TGRid   *setID, 
  TGRid   *rdbNodeID, 
  IGRchar *treeName, 
  TGRid   *treeID
));

#if defined(__cplusplus)
}
#endif

// -----------------------------------------------------------
// set/VDatSet.I
#if defined(__cplusplus)
extern "C" {
#endif

extern IGRstar VDatGetSet       __((TGRid *objID, TGRid   *setID));
extern IGRstar VDatGetSetName   __((TGRid *objID, IGRchar *setName));
extern IGRstar VDatGetSetByName __((
  TGRid   *mgrID, 
  IGRchar *setType, 
  IGRchar *setName, 
  TGRid   *setID
));
extern IGRstar VDatGetSetsVLA   __((TGRid *mgrID, TVDvlaID *setVLA));
extern IGRstar VDatGetSets      __((TGRid *mgrID, TGRid    *setsID));
extern IGRstar VDatCreateSets   __((TGRid *mgrID, TGRid    *setsID));
extern IGRstar VDatCreateSet    __((
  TGRid   *mgrID, 
  TGRid   *rdbSetID, 
  IGRchar *setName, 
  TGRid   *setID
));

extern IGRstar VDatGetSetTypeInfo __((
  IGRint   i_setTypeInd, 
  TGRid   *i_setID,
  IGRchar *i_setType,
  IGRchar *o_setType,
  IGRchar *o_setTypeDesc,
  IGRchar *o_setTypeLeafTable,
  IGRchar *o_setTypeTreeTable,
  IGRint  *o_setTypeIsTree,
  IGRint  *o_setTypeDoSum,
  IGRint  *o_setTypeRev
));

#omdef vdat$GetSetTypeInfo(
  setTypeInd       = -1,
  setID            = NULL,
  setType          = NULL,
  setTypeO         = NULL,
  setTypeDesc      = NULL,
  setTypeLeafTable = NULL,
  setTypeTreeTable = NULL,
  setTypeIsTree    = NULL,
  setTypeDoSum     = NULL,
  setTypeRev       = NULL
)

VDatGetSetTypeInfo(
  (setTypeInd),
  (setID),
  (setType),
  (setTypeO),
  (setTypeDesc),
  (setTypeLeafTable),
  (setTypeTreeTable),
  (setTypeIsTree),
  (setTypeDoSum),
  (setTypeRev)
)
#endomdef

/* ----------------------------------------------------
 * Interfaces to ppl for set type node information 
 */
extern IGRstar VDatGetSetNodeInfo __((

  IGRchar *i_setType,
  TGRid   *i_setID,

  IGRint   i_setNodeInd, 
  IGRchar *i_setNodeType,
  TGRid   *i_setNodeID,

  IGRchar *o_setNodeType,
  IGRchar *o_setNodeDesc,
  IGRchar *o_setNodeTable,
  IGRint  *o_setNodeLevel

));

#omdef vdat$GetSetNodeInfo(

  setType      = NULL,
  setID        = NULL,

  setNodeInd   = -1,
  setNodeType  = NULL,
  setNodeID    = NULL,

  setNodeTypeO = NULL,
  setNodeDesc  = NULL,
  setNodeTable = NULL,
  setNodeLevel = NULL
)

VDatGetSetNodeInfo(

  (setType),
  (setID),

  (setNodeInd),
  (setNodeType),
  (setNodeID),

  (setNodeTypeO),
  (setNodeDesc),
  (setNodeTable),
  (setNodeLevel)
)
#endomdef


#if defined(__cplusplus)
}
#endif

// -----------------------------------------------------------
// set/VDatSum.I
#if defined(__cplusplus)
extern "C" {
#endif

extern IGRstar VDatGetNodeSummary __((TGRid *nodeID, TVDatSum *sum));
extern IGRstar VDatSetNodeSummary __((TGRid *nodeID, TVDatSum *sum));

extern IGRstar VDatSummarizeLeaf  __((TGRid *leafID));
extern IGRstar VDatSummarizeNode  __((TGRid *nodeID));
extern IGRstar VDatIsSummarizable __((TGRid *nodeID));
extern IGRstar VDatHasSummary     __((TGRid *nodeID));

#if defined(__cplusplus)
}
#endif

// -----------------------------------------------------------
// rdb/VDatNode.I
#if defined(__cplusplus)
extern "C" {
#endif

extern IGRstat VDatRDBGetNode       __((TGRid *objID, TGRid   *nodeID));
extern IGRstat VDatRDBGetNodeType   __((TGRid *objID, IGRchar *nodeType));
extern IGRstat VDatRDBGetNodeByType __((TGRid *objID, IGRchar *nodeType, TGRid *rdbNodeID));

extern IGRstat VDatRDBGetNodes    __((TGRid *objID, TGRid    *nodesID));
extern IGRstat VDatRDBGetNodesVLA __((TGRid *objID, TVDvlaID *nodeVLA));

extern IGRstat VDatRDBCreateNode __((
  TGRid            *rdbNodesID, 
  TVDatRDBNodeInfo *info, 
  TGRid            *rdbNodeID
));
extern IGRstat VDatRDBCreateNodes __((TGRid *rdbSetID, TGRid *rdbNodesID));
extern IGRstat VDatRDBGetNodeInfo __((TGRid *nodeID,   TVDatRDBNodeInfo *info));
extern IGRstat VDatRDBSetNodeInfo __((TGRid *nodeID,   TVDatRDBNodeInfo *info));

#if defined(__cplusplus)
}
#endif

// -----------------------------------------------------------
// rdb/VDatSet.I
#if defined(__cplusplus)
extern "C" {
#endif

extern IGRstat VDatRDBGetSet       __((TGRid *objID, TGRid   *setID));
extern IGRstat VDatRDBGetSetType   __((TGRid *objID, IGRchar *setType));
extern IGRstat VDatRDBGetSetByType __((TGRid *objID, IGRchar *setType, TGRid *setID));

extern IGRstat VDatRDBGetSets      __((TGRid *objID, TGRid    *setsID));
extern IGRstat VDatRDBGetSetsVLA   __((TGRid *objID, TVDvlaID *setVLA));

extern IGRstat VDatRDBCreateSet    __((TGRid *setsID,  TVDatRDBSetInfo *info, TGRid *setID));
extern IGRstat VDatRDBCreateSets   __((TGRid *cacheID, TGRid   *setsID));

extern IGRstat VDatRDBGetSetInfo   __((TGRid *setID, TVDatRDBSetInfo *info));
extern IGRstat VDatRDBSetSetInfo   __((TGRid *setID, TVDatRDBSetInfo *info));

#if defined(__cplusplus)
}
#endif

// -----------------------------------------------------------
// rdb/VDatPost.I
#if defined(__cplusplus)
extern "C" {
#endif

extern IGRstat VDatRDBGetPost       __((TGRid *objID,   TGRid    *postID));
extern IGRstat VDatRDBGetTableName  __((TGRid *objID,   IGRchar  *tableName));
extern IGRstat VDatRDBGetPostByName __((TGRid *objID,   IGRchar  *postName,  TGRid *postID));
extern IGRstat VDatRDBGetPosts      __((TGRid *objID,   TGRid    *postsID));
extern IGRstat VDatRDBGetPostsVLA   __((TGRid *objID,   TVDvlaID *postVLA));
extern IGRstat VDatRDBCreatePost    __((VDosnum osnum,  TGRid *postsID, IGRchar  *tableName, TGRid *postID));
extern IGRstat VDatRDBCreatePosts   __((TGRid *cacheID, TGRid    *postsID));

#omdef vdat$RDBCreatePost(
  osnum      = OM_K_NOT_AN_OS,
  postsID    = NULL,
  tableNAME,
  postID
)

VDatRDBCreatePost((osnum),(postsID),(tableNAME),(postID))
#endomdef

#if defined(__cplusplus)
}
#endif

// -----------------------------------------------------------
// rdb/VDatAttr.I
#if defined(__cplusplus)
extern "C" {
#endif

extern IGRstat VDatRDBGetAttrByName __((TGRid *objID, IGRchar *attrName,  TGRid *attrID));

extern IGRstat VDatRDBGetAttrs      __((TGRid *objID, TGRid    *attrsID));
extern IGRstat VDatRDBGetAttrsVLA   __((TGRid *objID, TVDvlaID *attrVLA));

extern IGRstat VDatRDBCreateAttr    __((TGRid *attrsID, TVDatRDBAttrInfo *attrInfo, TGRid *attrID));
extern IGRstat VDatRDBCreateAttrs   __((TGRid *cacheID, TGRid   *attrsID));

extern IGRstat VDatRDBGetAttrInfo   __((TGRid *attrID, TVDatRDBAttrInfo *info));
extern IGRstat VDatRDBSetAttrInfo   __((TGRid *attrID, TVDatRDBAttrInfo *info));

#if defined(__cplusplus)
}
#endif

// -----------------------------------------------------------
// rdb/VDatMac.I
#if defined(__cplusplus)
extern "C" {
#endif

extern IGRstat VDatRDBGetMacByName __((TGRid *objID, IGRchar *macName,  TGRid *macID));

extern IGRstat VDatRDBGetMacs      __((TGRid *objID, TGRid    *macsID));
extern IGRstat VDatRDBGetMacsVLA   __((TGRid *objID, TVDvlaID *macVLA));

extern IGRstat VDatRDBCreateMac    __((TGRid *macsID,  TVDatRDBMacInfo *macInfo, TGRid *macID));
extern IGRstat VDatRDBCreateMacs   __((TGRid *cacheID, TGRid   *attrsID));

extern IGRstat VDatRDBGetMacInfo   __((TGRid *attrID, TVDatRDBMacInfo *info));
extern IGRstat VDatRDBSetMacInfo   __((TGRid *attrID, TVDatRDBMacInfo *info));

#if defined(__cplusplus)
}
#endif

// -----------------------------------------------------------
// rdb/VDatCache.I
#if defined(__cplusplus)
extern "C" {
#endif

extern IGRstat VDatRDBGetCache    __((TGRid *mgrID, TGRid *cacheID));
extern IGRstat VDatRDBCreateCache __((TGRid *mgrID, TGRid *cacheID));

#if defined(__cplusplus)
}
#endif

// -----------------------------------------------------------
// imp/VDatMgr.I
#if defined(__cplusplus)
extern "C" {
#endif

extern IGRstat VDatGetSetMgr     __((VDosnum osnum, TGRid   *mgrID));
extern IGRstat VDatCreateSetMgr  __((VDosnum osnum, TGRid   *mgrID));
extern IGRstat VDatGetSetMgrPath __((VDosnum osnum, IGRchar *mgrPath));

#if defined(__cplusplus)
}
#endif

#omdef vdat$GetSetMgr(
  osnum =  OM_K_NOT_AN_OS,
  mgrID
)
VDatGetSetMgr((osnum),(mgrID))
#endomdef

#omdef vdat$CreateSetMgr(
  osnum =  OM_K_NOT_AN_OS,
  mgrID
)
VDatCreateSetMgr((osnum),(mgrID))
#endomdef

// -----------------------------------------------------------
// imp/VDatFld.I
#if defined(__cplusplus)
extern "C" {
#endif

extern IGRstat VDatFldGetIntByIndex __((TVDatFld *fld, IGRint cnt, IGRint index, IGRlong   *value));
extern IGRstat VDatFldGetDblByIndex __((TVDatFld *fld, IGRint cnt, IGRint index, IGRdouble *value));
extern IGRstat VDatFldGetTxtByIndex __((TVDatFld *fld, IGRint cnt, IGRint index, IGRchar   *value));

extern IGRstat VDatFldSetIntByIndex __((TVDatFld *fld, IGRint *ind, IGRint index, IGRlong   value));
extern IGRstat VDatFldSetDblByIndex __((TVDatFld *fld, IGRint *ind, IGRint index, IGRdouble value));
extern IGRstat VDatFldSetTxtByIndex __((TVDatFld *fld, IGRint *ind, IGRint index, IGRchar  *value));

extern IGRstat VDatFldSetInt __((TVDatFld *fld, IGRchar *name, IGRlong    value));
extern IGRstat VDatFldSetDbl __((TVDatFld *fld, IGRchar *name, IGRdouble  value));
extern IGRstat VDatFldSetTxt __((TVDatFld *fld, IGRchar *name, IGRchar   *value));

extern IGRstat VDatFldSetTxtByName __((TVDatFld *flds, IGRint cnt, IGRchar *name, IGRchar   *value));
extern IGRstat VDatFldSetIntByName __((TVDatFld *flds, IGRint cnt, IGRchar *name, IGRint     value));
extern IGRstat VDatFldSetDblByName __((TVDatFld *flds, IGRint cnt, IGRchar *name, IGRdouble  value));

extern IGRstat VDatFldGetTxtByName __((TVDatFld *flds, IGRint cnt, IGRchar *name, IGRchar   *value));
extern IGRstat VDatFldGetIntByName __((TVDatFld *flds, IGRint cnt, IGRchar *name, IGRint    *value));
extern IGRstat VDatFldGetDblByName __((TVDatFld *flds, IGRint cnt, IGRchar *name, IGRdouble *value));

extern IGRstat VDatFldGetDefaultNodeAttrs __((TVDatFld *flds, IGRint *cnt));
extern IGRstat VDatFldGetDefaultLeafAttrs __((TVDatFld *flds, IGRint *cnt));

extern IGRstat VDatFldGetAllAttrs __((TGRid *objID, TVDatFld *flds, IGRint *cnt));
extern IGRstat VDatFldSetAllAttrs __((TGRid *objID, TVDatFld *flds, IGRint  cnt));
extern IGRstat VDatFldUpdAllAttrs __((TGRid *objID, TVDatFld *flds, IGRint  cnt));

extern IGRstat VDatFldGetAttrsByPrefix __((
  TGRid    *objID, 
  IGRchar  *prefix, 
  TVDatFld *flds, 
  IGRint   *cnt
));

extern IGRstat VDatFldGetAttrByName __((
  TGRid    *objID, 
  IGRchar  *name,   
  TVDatFld *fld
));

extern IGRstat VDatFldCopy __((
  TVDatFld *flds, 
  IGRint    cnt, 
  TVDatFld *fld
));

#if defined(__cplusplus)
}
#endif

// -----------------------------------------------------------
// imp/VDatBase1.I
#if defined(__cplusplus)
extern "C" {
#endif

extern IGRstat VDatGetBaseType __((TGRid *objID, IGRint  *type));
extern IGRstat VDatSetBaseType __((TGRid *objID, IGRint   type));
extern IGRstat VDatIsBaseType  __((TGRid *objID, IGRint   type));

extern IGRstat VDatGetBaseFlag    __((TGRid *objID, IGRint  *flag));
extern IGRstat VDatSetBaseFlag    __((TGRid *objID, IGRint   flag));
extern IGRstat VDatSetBaseFlagBit __((TGRid *objID, IGRint   flag));
extern IGRstat VDatClrBaseFlagBit __((TGRid *objID, IGRint   flag));
extern IGRstat VDatIsBaseFlag     __((TGRid *objID, IGRint   flag));

extern IGRstat VDatGetBaseName __((TGRid *objID, IGRchar *name));
extern IGRstat VDatSetBaseName __((TGRid *objID, IGRchar *name));
extern IGRstat VDatGetBaseMisc __((TGRid *objID, IGRchar *misc));
extern IGRstat VDatSetBaseMisc __((TGRid *objID, IGRchar *misc));

extern IGRstat VDatGetDbls  __((TGRid *objID, IGRdouble *values, IGRint *cnt));
extern IGRstat VDatSetDbls  __((TGRid *objID, IGRdouble *values, IGRint  cnt));
extern IGRstat VDatGetLongs __((TGRid *objID, IGRlong   *values, IGRint *cnt));
extern IGRstat VDatSetLongs __((TGRid *objID, IGRlong   *values, IGRint  cnt));
extern IGRstat VDatGetChars __((TGRid *objID, IGRchar   *values, IGRint *cnt));
extern IGRstat VDatSetChars __((TGRid *objID, IGRchar   *values, IGRint  cnt));

extern IGRstat VDatGetProcInfo __((TGRid *objID, VDprcAttr *info));
extern IGRstat VDatSetProcInfo __((TGRid *objID, VDprcAttr *info));

extern IGRstat VDatGetChildByType  __((TGRid *objID, IGRint type, TGRid *childID));
extern IGRstat VDatGetParentByType __((TGRid *objID, IGRint type, TGRid *parentID));

extern IGRstat VDatGetChildren __((TGRid *objID, TVDvlaID *objVLA));
extern IGRstat VDatGetParents  __((TGRid *objID, TVDvlaID *objVLA));

extern IGRstat VDatDisplayNode __((TGRid *nodeID, enum GRdpmode mode));

extern IGRstat VDatAddParent __((TGRid *childID, TGRid *parentID));
extern IGRstat VDatDelParent __((TGRid *childID, TGRid *parentID));

extern IGRstat VDatDelParentByType __((TGRid *nodeID, IGRint type));
extern IGRstat VDatDelAllParents   __((TGRid *nodeID));

extern IGRstat VDatAddParentToModel __((TGRobj_env *modelOE, TGRid *parentID));

extern IGRstat VDatGetChildObject  __((TGRid *parentID, IGRuint i, TGRid *childID));
extern IGRstat VDatGetParentObject __((TGRid *childID,  IGRuint i, TGRid *parentID));

extern IGRstar VDatGetObj __((
  TGRid *i_objID, 
  IGRint i_ind, 
  IGRint i_type,
  TGRid *o_childID,
  TGRid *o_parentID
));

extern IGRstat VDatCreateBase __((
  IGRchar *name, 
  IGRlong  type, 
  TGRid   *parentID, 
  VDosnum  osnum,
  TGRid   *objID
));

extern IGRstat VDatDeleteBase __((TGRid *objID));

#if defined(__cplusplus)
}
#endif

#omdef vdat$CreateBase(
  name,
  type,
  parentID = NULL,
  osnum    = OM_K_NOT_AN_OS,
  baseID
)
VDatCreateBase((name),(type),(parentID),(osnum),(baseID))
#endomdef

#omdef vdat$DeleteBase(
  baseID
)
VDatDeleteBase((baseID))
#endomdef

#omdef vdat$GetObj(objID,
		   nth  = -1,
		   type = -1,
		   childID  = NULL,
		   parentID = NULL
)
VDatGetObj((objID),(nth),(type),(childID),(parentID))
#endomdef

// -----------------------------------------------------------
// imp/VDatFrmMgr.I
#if defined(__cplusplus)
extern "C" {
#endif

#if 0
extern IGRstat VDatSetFormPosition __((IGRint flag, Form form)); // Saves position
extern IGRstat VDatGetFormPosition __((IGRint flag, Form form)); // Restores position
extern IGRstat VDatSetFormPositionFile __((Form form));          // Uses file
extern IGRstat VDatGetFormPositionFile __((Form form));          // Uses file
#endif

#if defined(__cplusplus)
}
#endif


#endif







