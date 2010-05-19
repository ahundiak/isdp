/* $Id: VDctx.h,v 1.24 2002/06/04 14:05:07 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/include/VDctx.h
 *
 * Description: Generic class objects
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDctx.h,v $
 *      Revision 1.24  2002/06/04 14:05:07  ahundiak
 *      ah
 *
 *      Revision 1.23  2002/05/06 20:52:00  ahundiak
 *      ah
 *
 *      Revision 1.22  2002/02/27 16:37:18  ahundiak
 *      ah
 *
 *      Revision 1.21  2001/11/16 14:58:29  ahundiak
 *      ah
 *
 *      Revision 1.20  2001/11/09 14:17:55  ahundiak
 *      ah
 *
 *      Revision 1.19  2001/10/19 18:29:46  ahundiak
 *      ah
 *
 *      Revision 1.18  2001/10/18 16:27:54  ahundiak
 *      ah
 *
 *      Revision 1.17  2001/10/18 15:31:47  ahundiak
 *      ah
 *
 *      Revision 1.16  2001/09/21 21:13:53  ahundiak
 *      ah
 *
 *      Revision 1.15  2001/08/24 19:58:34  ahundiak
 *      ah
 *
 *      Revision 1.14  2001/07/28 17:30:33  ahundiak
 *      ah
 *
 *      Revision 1.13  2001/07/23 16:01:13  ahundiak
 *      ah
 *
 *      ah
 *
 *      Revision 1.2  2001/02/17 14:06:12  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/01/14 16:11:38  art
 *      sp merge
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/12/00  ah      Created
 ***************************************************************************/

#ifndef VDctx_include
#define VDctx_include

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#ifndef   VDtypedefc_include
#include "VDtypedefc.h"
#endif

#ifndef   VDxml_include
#include "VDxml.h"
#endif

#ifndef   VDfld_include
#include "VDfld.h"
#endif

#ifndef   VDtag_include
#include "VDtag.h"
#endif

#ifndef   dp_include
#include "dp.h"
#endif

/* ----------------------------------------------------------
 * C++
 */
#if defined(__cplusplus)
extern "C" {
#endif

/* ---------------------------------------------
 * These node types are used by the object
 * manager stuff i.e. for real modeled pieces
 */
#define VDCTX_NODE_TYPE_OM_BEAM  "om_beam"
#define VDCTX_NODE_TYPE_OM_PLATE "om_plate"
#define VDCTX_TREE_TYPE_OM       "om"

/* ---------------------------------------------
 * Common attributes 
 * Might want to prepend with ig_ ???
 */
#define VDCTX_ATR_BASE_INFO          "base_info"
#define VDCTX_ATR_CREATION_TIMESTAMP "ts_creation"
#define VDCTX_ATR_PURPOSE            "ss_purpose"
#define VDCTX_ATR_COMP_PATH          "comp_path"
#define VDCTX_ATR_COMP_TAG           "comp_tagx"

/* ---------------------------------------------
 * See if the private file has been loaded
 */
#ifndef VDctxPrivate_include

/* ---------------------------------------------
 * Base information about a node
 * Keep thiese in sync with VDctsPrivate!!!
 */
#define VDCTX_MAX_NAME_LEN    32
#define VDCTX_MAX_TYPE_LEN    16
#define VDCTX_MAX_TYPE_REV_LEN 4

typedef struct
{
  IGRchar setType   [VDCTX_MAX_TYPE_LEN];
  IGRchar setTypeRev[VDCTX_MAX_TYPE_REV_LEN];
  IGRchar setName   [VDCTX_MAX_NAME_LEN];

  IGRchar treeType[VDCTX_MAX_TYPE_LEN];
  IGRchar treeTRev[VDCTX_MAX_TYPE_REV_LEN];
  IGRchar treeName[VDCTX_MAX_NAME_LEN];
  IGRchar nodeType[VDCTX_MAX_TYPE_LEN];
  IGRchar nodeName[VDCTX_MAX_NAME_LEN];
  IGRchar baseName[50];
} TVDctxBaseInfo;

 
/* ---------------------------------------------
 * Main class pointer structure
 * It's really defined in the private file
 */
typedef void *TVDctxCP;

/* ---------------------------------------------
 * The end of what is in the provate file
 */
#endif

// A buffer that's not too big but not too small
typedef IGRchar IGRchab[128];

/* -----------------------------------------------
 * This is to support public/provate but it's really
 * a bad implementation
 * really should have a getAtrFlag method which, given a node
 * and atr name will return public/provate information.
 *
 * Something for the next release
 */

#define VDCTX_SET_ATR_FLAG_PUBLIC         0
#define VDCTX_SET_ATR_FLAG_PRIVATE        1
#define VDCTX_SET_ATR_FLAG_PUBLIC_APPEND  2
#define VDCTX_SET_ATR_FLAG_PRIVATE_APPEND 3

#define VDCTX_GET_ATR_FLAG_PUBLIC  0
#define VDCTX_GET_ATR_FLAG_PRIVATE 1

/* ---------------------------------------------
 * Provide a function wrapper for each method
 */ 

// Single text attribute 
extern IGRstat VDctxGetBinAtrCP __((TVDctxCP  *cp, 
				    TGRid     *nodeID, 
				    TGRmd_env *env, 
				    IGRchar   *name, 
				    IGRint     privatE,
				    void     **binData));

extern IGRstat VDctxGetTxtAtrCP __((TVDctxCP  *cp, 
				    TGRid     *nodeID, 
				    TGRmd_env *env, 
				    IGRchar   *name, 
				    IGRint     privatE,
				    IGRchar   *value));

extern IGRstat VDctxGetTxtAtrPtrCP __((TVDctxCP  *cp, 
				       TGRid     *nodeID, 
				       TGRmd_env *env, 
				       IGRchar   *name, 
				       IGRint     privatE,
				       IGRchar   **value));

extern IGRstat VDctxSetTxtAtrCP __((TVDctxCP  *cp, 
				    TGRid     *nodeID, 
				    TGRmd_env *env, 
				    IGRchar   *name, 
				    IGRint     privatE,
				    IGRchar   *value));

extern IGRstat VDctxSetBinAtrCP __((TVDctxCP  *cp, 
				    TGRid     *nodeID, 
				    TGRmd_env *env, 
				    IGRchar   *name, 
				    IGRint     privatE,
				    void      *binData,
				    void (*binFree)(void *binData)));

extern IGRstat VDctxSetIntAtrCP __((TVDctxCP  *cp, 
				    TGRid     *nodeID, 
				    TGRmd_env *env, 
				    IGRchar   *name, 
				    IGRint     privatE,
				    IGRint    value));

extern IGRstat VDctxSetDblAtrCP __((TVDctxCP  *cp, 
				    TGRid     *nodeID, 
				    TGRmd_env *env, 
				    IGRchar   *name, 
				    IGRint     privatE,
				    IGRdouble  value));

#define VDctxGetBinAtr(nodeID,name,value) \
  VDctxGetBinAtrCP(NULL,nodeID,NULL,name,VDCTX_GET_ATR_FLAG_PUBLIC,value)

#define VDctxGetTxtAtr(nodeID,name,value) \
  VDctxGetTxtAtrCP(NULL,nodeID,NULL,name,VDCTX_GET_ATR_FLAG_PUBLIC,value)

#define VDctxGetTxtAtrPtr(nodeID,name,value) \
  VDctxGetTxtAtrPtrCP(NULL,nodeID,NULL,name,VDCTX_GET_ATR_FLAG_PUBLIC,value)

#define VDctxGetTxtAtrOE(nodeOE,name,value) \
  VDctxGetTxtAtrCP(NULL,&(nodeOE)->obj_id,&(nodeOE)->mod_env,name,VDCTX_GET_ATR_FLAG_PUBLIC,value)

#define VDctxGetPrivateTxtAtr(nodeID,name,value) \
  VDctxGetTxtAtrCP(NULL,nodeID,NULL,name,VDCTX_GET_ATR_FLAG_PRIVATE,value)

#define VDctxGetPrivateTxtAtrID(cp,nodeID,name,value) \
  VDctxGetTxtAtrCP(cp,nodeID,NULL,name,VDCTX_GET_ATR_FLAG_PRIVATE,value)

#define VDctxSetBinAtr(nodeID,name,binData,binFree) \
  VDctxSetBinAtrCP(NULL,nodeID,NULL,name,VDCTX_SET_ATR_FLAG_PUBLIC,binData,binFree)

#define VDctxSetTxtAtr(nodeID,name,value) \
  VDctxSetTxtAtrCP(NULL,nodeID,NULL,name,VDCTX_SET_ATR_FLAG_PUBLIC,value)

#define VDctxSetIntAtr(nodeID,name,value) \
  VDctxSetIntAtrCP(NULL,nodeID,NULL,name,VDCTX_SET_ATR_FLAG_PUBLIC,value)

#define VDctxSetDblAtr(nodeID,name,value) \
  VDctxSetDblAtrCP(NULL,nodeID,NULL,name,VDCTX_SET_ATR_FLAG_PUBLIC,value)

#define VDctxSetTxtAtrID(cp,nodeID,name,value) \
  VDctxSetTxtAtrCP(cp,nodeID,NULL,name,VDCTX_SET_ATR_FLAG_PUBLIC,value)

#define VDctxSetPrivateTxtAtr(nodeID,name,value) \
  VDctxSetTxtAtrCP(NULL,nodeID,NULL,name,VDCTX_SET_ATR_FLAG_PRIVATE,value)

#define VDctxSetPrivateTxtAtrID(cp,nodeID,name,value) \
  VDctxSetTxtAtrCP(cp,nodeID,NULL,name,VDCTX_SET_ATR_FLAG_PRIVATE,value)

#define VDctxAppBinAtr(nodeID,name,binData,binFree) \
  VDctxSetBinAtrCP(NULL,nodeID,NULL,name,VDCTX_SET_ATR_FLAG_PUBLIC_APPEND,binData,binFree)

#define VDctxAppTxtAtr(nodeID,name,value) \
  VDctxSetTxtAtrCP(NULL,nodeID,NULL,name,VDCTX_SET_ATR_FLAG_PUBLIC_APPEND,value)

#define VDctxAppIntAtr(nodeID,name,value) \
  VDctxSetIntAtrCP(NULL,nodeID,NULL,name,VDCTX_SET_ATR_FLAG_PUBLIC_APPEND,value)

#define VDctxAppDblAtr(nodeID,name,value) \
  VDctxSetDblAtrCP(NULL,nodeID,NULL,name,VDCTX_SET_ATR_FLAG_PUBLIC_APPEND,value)

#define VDctxAppTxtAtrID(cp,nodeID,name,value) \
  VDctxSetTxtAtrCP(cp,nodeID,NULL,name,VDCTX_SET_ATR_FLAG_PUBLIC_APPEND,value)

#define VDctxAppPrivateTxtAtr(nodeID,name,value) \
  VDctxSetTxtAtrCP(NULL,nodeID,NULL,name,VDCTX_SET_ATR_FLAG_PRIVATE_APPEND,value)

#define VDctxAppPrivateTxtAtrID(cp,nodeID,name,value) \
  VDctxSetTxtAtrCP(cp,nodeID,NULL,name,VDCTX_SET_ATR_FLAG_PRIVATE_APPEND,value)

// Limit buffer length, return 3 is truncated
extern IGRstat VDctxGetTxtAtrBuf __((TGRid *nodeID, IGRchar *name, IGRint len, IGRchar *buf));

// Single double attribute
extern IGRstat VDctxGetDblAtrCP __((TVDctxCP  *cp, 
				    TGRid     *nodeID, 
				    TGRmd_env *env, 
				    IGRchar   *name, 
				    IGRint     privatE,
				    IGRdouble *value));

#define VDctxGetDblAtr(nodeID,name,value) \
  VDctxGetDblAtrCP(NULL,nodeID,NULL,name,0,value)

#define VDctxGetPrivateDblAtr(nodeID,name,value) \
  VDctxGetDblAtrCP(NULL,nodeID,NULL,name,1,value)

#define VDctxGetPrivateDblAtrID(cp,nodeID,name,value) \
  VDctxGetDblAtrCP(cp,nodeID,NULL,name,1,value)

#define VDctxGetDblAtrOE(nodeOE,name,value) \
  VDctxGetDblAtrCP(NULL,&(nodeOE)->obj_id,&(nodeOE)->mod_env,name,0,value)

// Single VDfld attribute
extern IGRstat VDctxGetFldAtrCP __((TVDctxCP  *cp, 
				    TGRid     *nodeID, 
				    TGRmd_env *env, 
				    IGRchar   *name, 
				    IGRint     privatE,
				    TVDfld    *fld));

#define VDctxGetFldAtr(nodeID,name,fld) \
        VDctxGetFldAtrCP(NULL,nodeID,NULL,name,0,fld)

#define VDctxGetFldAtrID(cp,nodeID,name,fld) \
        VDctxGetFldAtrCP(cp,nodeID,NULL,name,0,fld)

#define VDctxGetPrivateFldAtr(nodeID,name,fld) \
        VDctxGetFldAtrCP(NULL,nodeID,NULL,name,1,fld)

#define VDctxGetPrivateFldAtrID(cp,nodeID,name,fld) \
        VDctxGetFldAtrCP(cp,nodeID,NULL,name,1,fld)

#define VDctxGetFldAtrOE(nodeOE,name,fld) \
        VDctxGetFldAtrCP(NULL,&(nodeOE)->obj_id,&(nodeOE)->mod_env,name,0,fld)

// All VDfld attributes
extern void VDctxGetFldAtrsCP __((TVDctxCP  *cp, 
				  TGRid     *nodeID, 
				  TGRmd_env *env,  
				  IGRint     privatE,
				  IGRint    *cnt,
				  TVDfld    *flds));

#define VDctxGetFldAtrs(nodeID,cnt,flds) \
        VDctxGetFldAtrsCP(NULL,nodeID,NULL,0,cnt,flds)

#define VDctxGetFldAtrsID(cp,nodeID,cnt,flds) \
        VDctxGetFldAtrsCP(cp,nodeID,NULL,0,cnt,flds)

#define VDctxGetPrivateFldAtrs(nodeID,cnt,flds) \
        VDctxGetFldAtrsCP(NULL,nodeID,NULL,1,cnt,flds)

#define VDctxGetPrivateFldAtrsID(cp,nodeID,cnt,flds) \
        VDctxGetFldAtrsCP(cp,nodeID,NULL,1,cnt,flds)

#define VDctxGetFldAtrsOE(nodeOE,cnt,flds) \
        VDctxGetFldAtrsCP(NULL,&(nodeOE)->obj_id,&(nodeOE)->mod_env,0,cnt,flds)

/* -----------------------------------------------
 * Base Info
 */

// -------------
extern IGRstat VDctxGetBaseInfoCP __((TVDctxCP       *cp, 
				      TGRid          *nodeID, 
				      TVDctxBaseInfo *baseInfo));

#define VDctxGetBaseInfo(       nodeID,baseInfo) \
        VDctxGetBaseInfoCP(NULL,nodeID,baseInfo)


// -------------
extern IGRstat VDctxSetBaseInfoCP __((TVDctxCP       *cp, 
				      TGRid          *nodeID, 
				      TVDctxBaseInfo *baseInfo));

#define VDctxSetBaseInfo(       nodeID,baseInfo) \
        VDctxSetBaseInfoCP(NULL,nodeID,baseInfo)

extern IGRstat VDctxValidateBaseInfo __((IGRint flag, TVDctxBaseInfo *baseInfo));
extern IGRint  VDctxCompareBaseInfo  __((TVDctxBaseInfo *info1, TVDctxBaseInfo *info2));

extern IGRint  VDctxCompareNodeName __((const void *void1, const void *void2));
extern IGRint  VDctxCompareCompName __((const void *void1, const void *void2));
extern IGRint  VDctxCompareCompPath __((const void *void1, const void *void2));

extern IGRint  VDctxCompareNodeTypeCompName __((const void *void1, const void *void2));
extern IGRint  VDctxCompareNodeTypeCompPath __((const void *void1, const void *void2));
extern IGRint  VDctxCompareNodeTypeName     __((const void *void1, const void *void2));
extern IGRint  VDctxCompareCompTag          __((const void *void1, const void *void2));

extern void VDctxCheckForDupCompNames __((IGRint cnt, TGRid *listIDs, IGRint *dupCnt));

/* -----------------------------------------------
 * Channel connections
 */
// -------------
extern IGRstat VDctxGetNthTreeChildCP __((TVDctxCP *cp, TGRid *nodeID, IGRint nth, TGRid *childID));

#define VDctxGetNthTreeChild(       nodeID,nth,childID) \
        VDctxGetNthTreeChildCP(NULL,nodeID,nth,childID)

// -------------
extern IGRstat VDctxGetTreeParentCP   __((TVDctxCP *cp, TGRid *nodeID, TGRid *parentID));

#define VDctxGetTreeParent(       nodeID,parentID) \
        VDctxGetTreeParentCP(NULL,nodeID,parentID)

// -------------
extern IGRstat VDctxGetNthMgrChildCP  __((TVDctxCP *cp, TGRid *nodeID, IGRint nth, TGRid *childID));

#define VDctxGetNthMgrChild(       nodeID,nth,childID) \
        VDctxGetNthMgrChildCP(NULL,nodeID,nth,childID)

// -------------
extern IGRstat VDctxGetMgrParentCP    __((TVDctxCP *cp, TGRid *nodeID, TGRid *parentID));

#define VDctxGetMgrParent(       nodeID,parentID) \
        VDctxGetMgrParentCP(NULL,nodeID,parentID)

// -------------
extern void VDctxGetTreeCP __((TVDctxCP *cp, TGRid *nodeID, TGRid *treeID));

#define VDctxGetTree(       nodeID,treeID) \
        VDctxGetTreeCP(NULL,nodeID,treeID)

// -------------
extern void VDctxGetSetCP  __((TVDctxCP *cp, TGRid *nodeID, TGRid *setID));

#define VDctxGetSet(       nodeID,setID) \
        VDctxGetSetCP(NULL,nodeID,setID)

// -------------
extern void VDctxGetCompNameCP __((TVDctxCP *cp, TGRid *nodeID, IGRchar *compName));

#define VDctxGetCompName(       nodeID,compName) \
        VDctxGetCompNameCP(NULL,nodeID,compName)

// -------------
extern void VDctxGetCompPathCP __((TVDctxCP *cp, TGRid *nodeID, IGRchar *compPath));

#define VDctxGetCompPath(       nodeID,compPath) \
        VDctxGetCompPathCP(NULL,nodeID,compPath)

// -------------
extern void VDctxGetNodeNameCP __((TVDctxCP *cp, TGRid *nodeID, IGRchar *nodeName));

#define VDctxGetNodeName(       nodeID,nodeName) \
        VDctxGetNodeNameCP(NULL,nodeID,nodeName)

// -------------
extern void VDctxGetNodeTypeCP __((TVDctxCP *cp, TGRid *nodeID, IGRchar *nodeType));

#define VDctxGetNodeType(       nodeID,nodeType) \
        VDctxGetNodeTypeCP(NULL,nodeID,nodeType)

extern void VDctxGetNodeTypeSuffix __((TGRid *nodeID, IGRchar *nodeType));

// -------------
extern IGRstat VDctxIsNodeTypeCP  __((TVDctxCP *cp, TGRid *nodeID, IGRchar *nodeType));

#define VDctxIsNodeType(       nodeID,nodeType) \
        VDctxIsNodeTypeCP(NULL,nodeID,nodeType)


// -------------
extern void VDctxGetNodeTypeCntCP __((TVDctxCP *cp, TGRid *nodeID, IGRchar *nodeType, IGRint *cnt));

#define VDctxGetNodeTypeCnt(       nodeID,nodeType,cnt) \
        VDctxGetNodeTypeCntCP(NULL,nodeID,nodeType,cnt)

// -------------
extern void VDctxGetNodeTypeIDsCP __((TVDctxCP *cp, TGRid *nodeID, IGRchar *nodeType, IGRint *cnt, TGRid **listIDs));

#define VDctxGetNodeTypeIDs(       nodeID,nodeType,cnt,listIDs) \
        VDctxGetNodeTypeIDsCP(NULL,nodeID,nodeType,cnt,listIDs)

// -------------
extern void VDctxDeleteNodeCP __((TVDctxCP *cp, TGRid *nodeID));

#define VDctxDeleteNode(nodeID) \
        VDctxDeleteNodeCP(NULL,nodeID)

// -------------
extern void VDctxCreateNodeCP __((TVDctxCP *cp,
				  TGRid    *parentID, 
				  IGRchar  *nodeType, 
				  IGRchar  *nodeName, 
				  TGRid    *nodeID));

#define VDctxCreateNode(parentID,nodeType,nodeName,nodeID) \
        VDctxCreateNodeCP(NULL,parentID,nodeType,nodeName,nodeID)

/* -----------------------------------------------
 * Model Stuff
 */
extern void VDctxGetModelObjectCP __((TVDctxCP *cp, TGRid *nodeID, TGRobj_env *modelOE));

#define VDctxGetModelObject(       nodeID,modelOE) \
        VDctxGetModelObjectCP(NULL,nodeID,modelOE)


extern void VDctxDisplayNodeCP    __((TVDctxCP *cp, TGRid *nodeID, enum GRdpmode mode, IGRint flag));

#define VDctxDisplayNode(       nodeID,mode,flag) \
        VDctxDisplayNodeCP(NULL,nodeID,mode,flag)


/* -----------------------------------------------
 * Helper Functions
 */
extern void VDctxComputeDateCP __((TVDctxCP *cp, TGRid *nodeID, IGRchar *attrName));

#define VDctxComputeDate(       nodeID,attrName) \
        VDctxComputeDateCP(NULL,nodeID,attrName)

/* ---------------------------------------------
 * Tree Walkers
 */
extern void VDctxWalkNode __((TGRid  *nodeID,
			      IGRint  depthFlag,
			      void (*process)(TGRid *nodeID, void *data, IGRint *stopWalk),
			      void   *data,
			      IGRint *stopWalk));

extern void VDctxWalkTreesInOS __((VDosnum osnum,
				   IGRint  depthFlag,
				   void (*process)(TGRid *treeID, void *data, IGRint *stopWalk),
				   void   *data,
				   IGRint *stopWalk));

extern void VDctxWalkAllTrees __((IGRint depthFlag, 
				  void (*process)(TGRid *nodeID, void *data, IGRint *stopWalk),
				  void *data));
typedef struct 
{
  // What to look for
  TVDctxBaseInfo baseInfo;

  // IFind values
  struct 
  {
    IGRint treeType,treeTRev,treeName;
    IGRint nodeType,nodeName;
  } match;

  // Stop at the first one
  IGRint  stopAtOne;
  
  // Results
  TGRid   firstID;
  IGRint  cnt;

} TVDctxTreeTypeWalk;

extern void VDctxWalkProcessByTypeName __((TGRid *treeID, void *datax, IGRint *stopWalk));

extern void VDctxWalkProcessGetFirstModelObject __((TGRid *nodeID, void *data, IGRint *stopWalk));

extern void VDctxGetStagingTree        __((TGRid *treeID, TVDctxBaseInfo *baseInfo, IGRint *cnt));

/* -----------------------------------------------
 * Many times, need to walk a tree and return
 * an array of id's
 */
typedef struct 
{
  IGRint i,cnt,max,size;
  TGRid *listIDs;
} TVDctxNodeList;

extern void VDctxInitNodeList __((TVDctxNodeList *nodeList));
extern void VDctxFreeNodeList __((TVDctxNodeList *nodeList));

extern void VDctxSortNodeList __((TVDctxNodeList *nodeList, 
				  IGRint (*compare)(const void *p1, const void *p2)));

extern TGRid * VDctxSearchNodeList __((TGRid *findID,
				       TVDctxNodeList *nodeList, 
				       IGRint (*compare)(const void *p1, const void *p2)));

extern void VDctxGetListPieces __((TGRid *treeID, TVDctxNodeList *nodeList));

extern void VDctxGetNodeListByType __((TGRid *treeID, IGRchar *nodeType, TVDctxNodeList *nodeList));

extern void VDctxGetNodeListByFilter __((TGRid *treeID, 
					 IGRint (*filter)(TGRid *nodeID), 
					 TVDctxNodeList *nodeList));

extern void VDctxGetCompTag     __((TGRid *nodeID, TVDtag     *tag));
extern void VDctxGetCompTagInfo __((TGRid *nodeID, TVDtagInfo *tagInfo));

extern IGRstat VDctxGetChildNodeByType __((TGRid *nodeID, IGRchar *type, TGRid *childID));

extern void VDctxGetNodeByType __((TGRid *treeID, IGRchar *nodeType, TGRid *nodeID));

/* ---------------------------------------------
 * Piece routines
 */
extern void VDctxGetPieceMark  __((TGRid *nodeID,  IGRchar *pcmk));
extern void VDctxSetPieceMark  __((TGRid *nodeID,  IGRchar *pcmk));

extern void VDctxGetPieceStage __((TGRid *nodeID, IGRchar *stage));
extern void VDctxSetPieceStage __((TGRid *nodeID, IGRchar *stage));

extern void VDctxGetStagePath  __((TGRid *nodeID,  IGRchar *path));
extern void VDctxSetStagePath  __((TGRid *nodeID,  IGRchar *path));

extern void VDctxGetStagingTreeRootNode __((TGRid *treeID, TGRid *rootID));

extern void VDctxGetStagingTreeNodeType __((TGRid *nodeID, IGRchar *nodeType, IGRint *nodeTypeIndex));

extern IGRint VDctxCompareStagingTreeNodeTypeName __((const void *v1, const void *v2));

/* ---------------------------------------------
 * XML Routines
 */

extern void VDctxSaveTreeToXmlBufCP  __((TVDctxCP *cp,TGRid *treeID,IGRchar **bufXml));
extern void VDctxSaveTreeToXmlFileCP __((TVDctxCP *cp,TGRid *treeID,IGRchar *fileName));
extern void VDctxPrintLogCP          __((TVDctxCP *cp,TGRid *treeID,IGRint type,IGRint stdOutFlag));

#define VDctxSaveTreeToXmlBuf(treeID,buf) \
        VDctxSaveTreeToXmlBufCP(NULL,treeID,buf)

#define VDctxSaveTreeToXmlFile(treeID,fileName) \
        VDctxSaveTreeToXmlFileCP(NULL,treeID,fileName)

#define VDctxPrintLog(treeID,type,stdOutFlag) \
        VDctxPrintLogCP(NULL,treeID,type,stdOutFlag)

/* ---------------------------------------------
 * Class pointer access
 */
extern TVDctxCP *VDctxGetNodeCP __((TGRid *nodeID));
extern TVDctxCP *VDctxGetNthCP  __((IGRint nth));

/* ---------------------------------------------
 * Proecssing instructions and content management
 * Only implemented for xdom
 */
extern void VDctxGetContentCP __((TVDctxCP *cp, TGRid *nodeID, IGRchar **content));

#define     VDctxGetContent(nodeID,content) \
            VDctxGetContentCP(NULL,nodeID,content)

extern void VDctxGetNthDocPICP __((TVDctxCP *cp, TGRid *nodeID, IGRint i, TGRid *piID));
#define     VDctxGetNthDocPI(nodeID,i,piID) \
            VDctxGetNthDocPICP(NULL,nodeID,i,piID)

extern void VDctxGetNthNodePICP __((TVDctxCP *cp, TGRid *nodeID, IGRint i, TGRid *piID));
#define     VDctxGetNthNodePI(nodeID,i,piID) \
            VDctxGetNthNodePICP(NULL,nodeID,i,piID)

/* Generic print routine (probably just for xdom) */
extern void VDctxPrintTree  __((IGRint type, IGRint stdoutFlag, TGRid *treeID));

/* for starting an xdom tree */
extern void VDctxCreateXdomTree __((IGRchar *treeType, IGRchar *treeName, TGRid *treeID));

/* Route all generic double to text stuff through here */
extern void VDcnvDblToTxt __((IGRdouble dbl, IGRchar *txt));

/* Only implemented for xdom nodes */
extern IGRstat VDctxHasAttribute __((TGRid *nodeID, IGRchar *name));

/* ------------------------- */
#if defined(__cplusplus)
}
#endif

#endif
