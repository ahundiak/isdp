/* $Id: VDct1Post2.h,v 1.2 2001/01/14 16:11:38 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDct1Post2.h
 *
 * Description: Posting Functions
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Post2.h,v $
 *      Revision 1.2  2001/01/14 16:11:38  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/09 22:17:57  art
 *      ah
 *
 * Revision 1.2  2000/09/04  14:37:22  pinnacle
 * js
 *
 * Revision 1.1  2000/08/25  21:02:44  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/11/00  ah      Creation
 * 01/12/01  ah      sp17, c friendly
 ***************************************************************************/
#ifndef VDct1Post2_include
#define VDct1Post2_include

/* -------------------------------------------------------------------
 * Usual BS
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ----------------------------------------------------
 * Transfer some stuff from VDatMaster.h cause it's too big
 */
#define VDAT_RDB_TBL_SET_REF_KEYS  "vdat_set_ref_keys"
#define VDAT_RDB_TBL_SET_KEYS      "vdat_set_keys"
#define VDAT_RDB_TBL_FILE_KEYS     "vdat_file_keys"
#define VDAT_RDB_TBL_KEYS          "vdat_keys"
#define VDAT_RDB_TBL_POSTABLE      "vdat_postable"

typedef IGRlong IGRkey;

/* ---------------------------------------------------------
 * Make some PDM Stuff easier
 */
typedef struct {
  GRobjid objid;
  IGRchar cat [20];
  IGRchar part[20];
  IGRchar rev [20];
  IGRchar file[20];
  IGRkey  key;
} TVDatPDMInfo;

extern IGRstat VDatGetPdmMgr      __((VDosnum osnum, TGRid   *mgrID));
extern IGRstat VDatCreatePdmMgr   __((VDosnum osnum, TGRid   *mgrID));
extern IGRstat VDatGetPdmMgrPath  __((VDosnum osnum, IGRchar *mgrPath));

extern IGRstat VDatPOSTGetPDMInfo __((VDosnum osnum, TVDatPDMInfo *info));
extern IGRstat VDatPOSTGetFileKey __((TVDatPDMInfo *info, IGRboolean createKey));

extern IGRstat VDatPOSTGetNextSetKey  __((IGRkey  *theKEY));
extern IGRstat VDatPOSTGetNextFileKey __((IGRkey  *theKEY)); 
extern IGRstat VDatPOSTGetNextKey     __((IGRchar *keyName, IGRkey *theKEY));


/* ---------------------------------------------
 * Predefined standard column names that every
 * tree manager post table should have
 *
 * Note that types are important, 
 * hence the I for int and C for character
 */
#define VDCT1_RIS_POST_COLNI_COMP_SEQNO   "comp_seqno"
#define VDCT1_RIS_POST_COLNC_ASSEMBLY_CAT "assembly_cat"
#define VDCT1_RIS_POST_COLNC_ASSEMBLY_NAM "assembly_nam"
#define VDCT1_RIS_POST_COLNC_ASSEMBLY_VER "assembly_ver"
#define VDCT1_RIS_POST_COLNI_FILE_KEY     "file_key"
#define VDCT1_RIS_POST_COLNI_TREE_KEY     "tree_key"
#define VDCT1_RIS_POST_COLNI_SORT_KEY     "sort_key"
#define VDCT1_RIS_POST_COLNC_TREE_TYPE    "tree_type"
#define VDCT1_RIS_POST_COLNC_TREE_NAME    "tree_name"
#define VDCT1_RIS_POST_COLNC_TREE_REV     "tree_rev"
#define VDCT1_RIS_POST_COLNC_NODE_TYPE    "node_type"
#define VDCT1_RIS_POST_COLNC_NODE_NAME    "node_name"
#define VDCT1_RIS_POST_COLNI_PARENT_SEQNO "parent_seqno"

// Non standard attributes follow this one
#define VDCT1_RIS_POST_COLNI_LAST "parent_seqno"

// Some model specific attributes are handled as special cases
#define VDCT1_RIS_POST_COLNC_MODEL_PREFIX  "model_"
#define VDCT1_RIS_POST_COLNI_MODEL_KEY     "model_key"
#define VDCT1_RIS_POST_COLNI_MODEL_OBJID   "model_objid"

// For now, track RIS Types here
#define VDCT1_RIS_COL_TYPE_INT  1
#define VDCT1_RIS_COL_TYPE_CHAR 4

/* ----------------------------------------------------
 * Clean up
 */
#if defined(__cplusplus)
}
#endif
#endif





