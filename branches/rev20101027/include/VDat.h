/* $Id: VDat.h,v 1.3 2001/02/17 14:06:12 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDat.h
 *
 * Description:	Assembly Tree Stuff, Original include files have dependency
 *              problems.  This file has public interface prototypes
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDat.h,v $
 *      Revision 1.3  2001/02/17 14:06:12  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/01/09 22:03:39  art
 *      ah
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.3  2000/11/27  16:30:22  pinnacle
 * ah
 *
 * Revision 1.2  2000/10/15  12:54:32  pinnacle
 * ah
 *
 * Revision 1.1  2000/05/15  14:38:10  pinnacle
 * ah
 *
 * Revision 1.1  2000/03/31  17:10:10  pinnacle
 * ah
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/28/00  ah      Creation
 * 10/15/00  ah      Blob Functionality
 * 01/09/00  ah      sp merge
 ***************************************************************************/
#ifndef VDat_include
#define VDat_include

#ifndef   VDtypedefc_include
#include "VDtypedefc.h"
#endif

#ifndef   VDatClass_include
#include "VDatClass.h"
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ------------------------------------------------
 * Leaf routines
 */
extern IGRstat VDatGetConsumingChild  __((TGRobj_env *parentOE, TGRobj_env *childOE));

extern IGRstat VDatLeafAttachPiece    __((TGRid *leafID, TGRobj_env *pieceOE));
extern IGRstat VDatLeafAttachNewPiece __((TGRid *leafID));
extern IGRstat VDatLeafVerifyPiece    __((TGRid *leafID));

extern IGRstat VDatSetLeafPath        __((TGRid *leafID));
extern IGRstat VDatComputeLeaf        __((TGRid *leafID, IGRint flag));
extern IGRstat VDatSetLeafPieceMark   __((TGRid *leafID));

extern IGRstat VDatGetNumLeafs        __((TGRid *objID, IGRint *cnt));
extern IGRstat VDatIsLeaf             __((TGRid *nodeID));

extern IGRstat VDatGetLeafObject      __((TGRid *leafID, TGRobj_env *objOE));

extern IGRstat VDatGetLeafs           __((TGRid *nodeID, TGRid *leafsID));

/* -------------------------------------------------------
 * vdat/set/VDatMisc.I
 */
extern IGRstat VDatGetObjectLeaf __((TGRobj_env *objOE, 
				     TGRid      *setID, 
				     TGRid      *leafID));


extern IGRstat VDatGetObjectLeafForSetType __((TGRobj_env *objOE, 
					       IGRchar    *setType,
					       TGRid      *leafID));

/* -------------------------------------------------------
 * vdat/imp/VDatMgr.I
 */
extern IGRstat VDatGetSetMgr    __((VDosnum osnum, TGRid *mgrID));

/* -------------------------------------------------------
 * vdat/imp/VDatBase1.I
 */
extern IGRstat VDatGetChildObject __((TGRid  *nodeID, 
				      IGRuint i,
				      TGRid  *childID));

extern IGRstat VDatGetParentObject __((TGRid  *nodeID, 
				       IGRuint i,
				       TGRid  *childID));

extern IGRstat VDatGetBaseType    __((TGRid   *nodeID, 
				      IGRint  *type));

/* -------------------------------------------------------
 * vdat/set/VDatTree.I
 */
extern IGRstat VDatGetTree __((TGRid *nodeID, TGRid *treeID));
  
/* -------------------------------------------------------
 * vdat/set/VDatSet.I
 */
extern IGRstat VDatGetSetByName     __((TGRid   *mgrID,
					IGRchar *setType,
					IGRchar *setName,
					TGRid   *setID));

extern IGRstat VDatGetSetByTypeName __((IGRchar *setType, 
					IGRchar *setName, 
					TGRid   *setID));

extern IGRstat VDatGetSetName __((TGRid *objID, IGRchar *setName));
extern IGRstat VDatGetSetType __((TGRid *objID, IGRchar *setType));
  
/* -------------------------------------------------------
 * vdat/set/VDatNode.I
 */
extern IGRstat VDatGetNodeName __((TGRid *objID, IGRchar *nodeName));
extern IGRstat VDatGetNodeType __((TGRid *objID, IGRchar *nodeType));

extern IGRstat VDatGetParentNode __((TGRid *objID, TGRid *parentID));
  

/* -------------------------------------------------------
 * vdat/post/VDatImp.c
 */
extern IGRstat VDatGetSetNameForType __((IGRchar *setType, 
					 IGRchar *setName));

extern IGRstat VDatCompareFiles __((IGRchar *file_name1, 
				    IGRchar *file_name2, 
				    IGRint  *results));
  
/* -------------------------------------------------------
 * vdat/rdb/VDatNode.I
 */
extern IGRstat VDatRDBGetNodeType   __((TGRid *objID, IGRchar *nodeType));

/* -------------------------------------------------------
 * vdat/post/VDatXml.I
 */
extern IGRstat VDatWriteXmlFile __((IGRchar *setType, 
				    IGRchar *setName, 
				    IGRchar *fileName));

extern IGRstat VDatTestWriteXmlFile __(());
  

/* ---------------------------------------------
 * Field processing
 * imp/VDatFld.I
 */
typedef struct {

  IGRlong type;
  IGRlong flag;
  IGRlong index;
  IGRchar name[32];
  
  IGRlong   valueInt;
  IGRdouble valueDbl;
  IGRchar   valueTxt[100];

} TVDatFld;

#define VDAT_FLD_MAX 256

// These numbers correspond to the ris defs in VDSris_def.h
#define VDAT_FLD_TYPE_NONE     0
#define VDAT_FLD_TYPE_CHAR     1
#define VDAT_FLD_TYPE_NUMERIC  2
#define VDAT_FLD_TYPE_DECIMAL  3
#define VDAT_FLD_TYPE_INT      4
#define VDAT_FLD_TYPE_SMALLINT 5
#define VDAT_FLD_TYPE_REAL     7
#define VDAT_FLD_TYPE_DOUBLE   8
#define VDAT_FLD_TYPE_DATE    99

extern IGRstat VDatFldGetAllAttrs   __((TGRid *objID, TVDatFld *flds, IGRint *cnt));
extern IGRstat VDatFldGetAttrByName __((TGRid *objID, IGRchar *name, TVDatFld *fld));
  

/* ------------------------------------------------
 * vds/vdat/post/VDatRis.c
 */
#define VDAT_RIS_TBLN_BLOBS           "vdat_blobs"

#define VDAT_RIS_FLDN_BLOBS_FILE_KEY  "file_key"
#define VDAT_RIS_FLDN_BLOBS_PURPOSE   "purpose"
#define VDAT_RIS_FLDN_BLOBS_HULL      "hull"
#define VDAT_RIS_FLDN_BLOBS_SET_TYPE  "set_type"
#define VDAT_RIS_FLDN_BLOBS_SET_NAME  "set_name"
#define VDAT_RIS_FLDN_BLOBS_SET_VER   "set_ver"
#define VDAT_RIS_FLDN_BLOBS_SET_CUR   "set_cur"
#define VDAT_RIS_FLDN_BLOBS_POST_DATE "post_date"
#define VDAT_RIS_FLDN_BLOBS_BLOB_KEY  "blob_key"

typedef struct 
{
  IGRint  file_key;
  IGRchar purpose [20];
  IGRchar hull    [20];
  IGRchar set_type[20];
  IGRchar set_name[20];
  IGRint  set_ver;
  IGRint  set_cur;
  IGRchar post_date[20];  
  IGRint  blob_key;
} TVDatBlob;

extern IGRstat VDatRisInsertCurrentBlob __((TVDatBlob *blob));
extern IGRstat VDatRisSelectCurrentBlob __((TVDatBlob *blob));
extern IGRstat VDatHasBlobChanged       __((TVDatBlob *blob, IGRint *results));
extern IGRstat VDatTestHasBlobChanged   __(());

/* ----------------------------------------------------
 * Clean up
 */
#if defined(__cplusplus)
}
#endif

#endif
