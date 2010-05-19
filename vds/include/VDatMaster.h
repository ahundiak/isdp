/* $Id: VDatMaster.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDatMaster.h
 *
 * Description: Master assembly tree include
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatMaster.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.2  1998/11/07  13:50:30  pinnacle
 * ah
 *
 * Revision 1.1  1998/10/11  13:51:42  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 10/10/98  ah      Creation, used to be VDat.h, also combined other includes
 *
 ***************************************************************************/

#ifndef VDatMaster_include
#define VDatMaster_include

#include "VDtypedef.h"
#include "VDvla.h"

/* --------------------------------------------------
 * Ties into a stage or node setup table
 */
typedef struct {

  IGRchar setType   [24];
  IGRchar nodeType  [24];  // Ex: UNIT, PSU, PSA, etc.

  IGRlong nodeLevel;
  IGRchar nodeDesc     [84];
  IGRchar nodeTableName[24];

  IGRchar nodeSyntax  [84];   // Syntax definition: [0-999]
  IGRchar nodeNameCons[84];   // Name Constraint (ex: Unique in UNIT or STAGE).
  IGRchar nodePathDesc[24]; 
  IGRchar nodePathSep [ 4];   // Seperator between nodes.
  IGRlong nodePathSwap;       // Swap with child path.(Ex: "273-1-A-1" -> "273-1-1A")
  IGRchar nodePathPrefix[24]; // Print out control/prefix. Ex: "CPSU 273-1-1A"

} TVDatRDBNodeInfo;

/* --------------------------------------------
 * List of available set types
 */
typedef struct {
  IGRchar setType[24];
  IGRchar setDesc[84];
} TVDatRDBSetInfo;

/* --------------------------------------------
 * List of available attributes
 */
typedef struct {
  IGRchar attrName  [24];
  IGRchar attrPrompt[24];
  IGRchar attrDesc  [84];
  IGRlong attrType;
  IGRchar attrPPL   [24];

} TVDatRDBAttrInfo;

/* --------------------------------------------
 * List of detail macros
 */
typedef struct {
  IGRchar macName[24];
  IGRchar macUse [24];
  IGRchar macPPL [24];
} TVDatRDBMacInfo;

/* ---------------------------------------------
 * Some predefined table names
 */
#define VDAT_RDB_TBL_MACROS        "vdat_macros"
#define VDAT_RDB_TBL_ATTRS         "vdat_attrs"
#define VDAT_RDB_TBL_ATTR_VALUES   "vdat_attr_values"
#define VDAT_RDB_TBL_SET_TYPES     "vdat_set_types"
#define VDAT_RDB_TBL_SET_NODES     "vdat_set_nodes"

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

/* ----------------------------------------------------------
 * Predefined attribute names
 */
#define VDAT_ATTR_NODE_PATH  "node_path"
#define VDAT_ATTR_NODE_NAME  "node_name"
#define VDAT_ATTR_NODE_TYPE  "node_type"
#define VDAT_ATTR_NODE_ORDER "node_order"

#define VDAT_ATTR_PARENT_SEQNO "parent_seqno"
#define VDAT_ATTR_PARENT_PATH  "parent_path"
#define VDAT_ATTR_PARENT_NAME  "parent_name"
#define VDAT_ATTR_PARENT_TYPE  "parent_type"

#define VDAT_ATTR_SET_NAME  "set_name"
#define VDAT_ATTR_SET_TYPE  "set_type"
#define VDAT_ATTR_DYN_TABLE "dyn_table"

#define VDAT_ATTR_PCMK      "pcmk"

#define VDAT_ATTR_COMP_PATH "comp_path"
#define VDAT_ATTR_COMP_NAME "comp_name"

#define VDAT_ATTR_BASE_INFO "base_info"
#define VDAT_ATTR_LEAF_NAME "leaf_name"

#define VDAT_FLAG_SUM 0x01

/* ---------------------------------------------
 * Field processing
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

/* ------------------------------------------------
 * Summary information
 */
#ifndef   vd_procinfo_include
#include "vdprocinfo.h"
#endif
typedef VDprcAttr TVDatSum;

#include "VDatClass.h"
#include "VDatProto.h"

#endif
