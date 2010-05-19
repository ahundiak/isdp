/* $Id: VDct1Ris.h,v 1.2 2001/02/11 17:30:40 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDct1Ris.h
 *
 * Description: Ris Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Ris.h,v $
 *      Revision 1.2  2001/02/11 17:30:40  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/01/09 22:17:57  art
 *      ah
 *
 * Revision 1.13  2000/12/07  17:33:08  pinnacle
 * ah
 *
 * Revision 1.12  2000/09/04  14:37:30  pinnacle
 * js
 *
 * Revision 1.11  2000/08/24  14:50:00  pinnacle
 * js
 *
 * Revision 1.10  2000/08/23  14:47:54  pinnacle
 * ah
 *
 * Revision 1.9  2000/08/17  11:18:44  pinnacle
 * js
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/16/00  ah      Creation
 * 12/06/00  ah      c Friendly
 ***************************************************************************/

#ifndef VDct1Ris_include
#define VDct1Ris_include

#ifndef   VDrisc_include
#include "VDrisc.h"
#endif

/* ------------------------------------------
 * Usual bs
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* -----------------------------------------------
 * Part Attributes Interface
 */
#define VDCT1_RIS_TBLN_ATTRS         "tm_item_attrs"
#define VDCT1_RIS_COLN_ATTRS_PART_ID "item_id"
#define VDCT1_RIS_COLN_ATTRS_NAME    "attr_name"
#define VDCT1_RIS_COLN_ATTRS_VALUE   "attr_value"
#define VDCT1_RIS_COLN_ATTRS_SORT    "attr_sort"
#define VDCT1_RIS_COLN_ATTRS_INFO    "attr_info"

#define VDCT1_RIS_COLI_ATTRS_PART_ID 0
#define VDCT1_RIS_COLI_ATTRS_NAME    1
#define VDCT1_RIS_COLI_ATTRS_VALUE   2
#define VDCT1_RIS_COLI_ATTRS_SORT    3
#define VDCT1_RIS_COLI_ATTRS_INFO    4
#define VDCT1_RIS_COLI_ATTRS_LAST    5

/* -----------------------------------------------
 * tm_items layout
 */
#define VDCT1_RIS_TBLN_ITEMS                   "tm_items"
#define VDCT1_RIS_COLN_ITEMS_ITEM_ID           "item_id"
#define VDCT1_RIS_COLN_ITEMS_ITEM_TYPE         "item_type"
#define VDCT1_RIS_COLN_ITEMS_ITEM_SRC          "item_src"
#define VDCT1_RIS_COLN_ITEMS_ITEM_CAGE_NUM     "item_cage_num"
#define VDCT1_RIS_COLN_ITEMS_ITEM_CAGE_CODE    "item_cage_code"
#define VDCT1_RIS_COLN_ITEMS_ITEM_NUM          "item_num"
#define VDCT1_RIS_COLN_ITEMS_ITEM_REV          "item_rev"
#define VDCT1_RIS_COLN_ITEMS_ITEM_CUR_REV      "item_cur_rev"
#define VDCT1_RIS_COLN_ITEMS_NOUN_NAME         "noun_name"
#define VDCT1_RIS_COLN_ITEMS_TYPE              "type"
#define VDCT1_RIS_COLN_ITEMS_MODIFIER          "modifier"
#define VDCT1_RIS_COLN_ITEMS_COMM_CODE         "comm_code"
#define VDCT1_RIS_COLN_ITEMS_DISCIPLINE        "discipline"
#define VDCT1_RIS_COLN_ITEMS_CLASSIFICATION    "classification"
#define VDCT1_RIS_COLN_ITEMS_UNIT_OF_MEASURE   "unit_of_measure"
#define VDCT1_RIS_COLN_ITEMS_COPICS_SHORT_DESC "copics_short_desc"
#define VDCT1_RIS_COLN_ITEMS_UPDATEDATE        "updatedate"

#define VDCT1_RIS_COLI_ITEMS_ITEM_ID            0
#define VDCT1_RIS_COLI_ITEMS_ITEM_TYPE          1
#define VDCT1_RIS_COLI_ITEMS_ITEM_SRC           2
#define VDCT1_RIS_COLI_ITEMS_ITEM_CAGE_NUM      3
#define VDCT1_RIS_COLI_ITEMS_ITEM_CAGE_CODE     4
#define VDCT1_RIS_COLI_ITEMS_ITEM_NUM           5 
#define VDCT1_RIS_COLI_ITEMS_ITEM_REV           6 
#define VDCT1_RIS_COLI_ITEMS_ITEM_CUR_REV       7
#define VDCT1_RIS_COLI_ITEMS_NOUN_NAME          8
#define VDCT1_RIS_COLI_ITEMS_TYPE               9
#define VDCT1_RIS_COLI_ITEMS_MODIFIER          10
#define VDCT1_RIS_COLI_ITEMS_COMM_CODE         11
#define VDCT1_RIS_COLI_ITEMS_DISCIPLINE        12
#define VDCT1_RIS_COLI_ITEMS_CLASSIFICATION    13
#define VDCT1_RIS_COLI_ITEMS_UNIT_OF_MEASURE   14
#define VDCT1_RIS_COLI_ITEMS_COPICS_SHORT_DESC 15
#define VDCT1_RIS_COLI_ITEMS_UPDATEDATE        16
#define VDCT1_RIS_COLI_ITEMS_LAST              17

/* -----------------------------------------------
 * ISDP To ITEMS Table layout, Obsolete, don't use anymore
 */
#define  VDCT1_RIS_TBLN_ISDPITEMS                "tm_isdp_item"
#define  VDCT1_RIS_COLN_ISDPITEMS_ISDP_CAGE_NUM  "isdp_cage_num"
#define  VDCT1_RIS_COLN_ISDPITEMS_ITEM_CAGE_NUM  "item_cage_num"
#define  VDCT1_RIS_COLI_ISDPITEMS_ISDP_CAGE_NUM  0
#define  VDCT1_RIS_COLI_ISDPITEMS_ITEM_CAGE_NUM  1

/* ------------------------------------------------
 * Standard assembly product structure
 * create table tm_ps
 * (
 *  parent_cage_num  char(25),    -- OPS item in tm_items
 *  child_cage_num   char(25),    -- OPS Child

 *  ps_sort          integer,     -- Order to extract
 *  ps_qty           char(39),    -- qty per part
 *  ps_date          char(19)     -- Date posted
 * );
 */

#define  VDCT1_RIS_TBLN_PS                  "tm_ps"
#define  VDCT1_RIS_COLN_PS_PARENT_CAGE_NUM  "parent_cage_num"
#define  VDCT1_RIS_COLN_PS_CHILD_CAGE_NUM   "child_cage_num"
#define  VDCT1_RIS_COLN_PS_SORT             "ps_sort"
#define  VDCT1_RIS_COLN_PS_QTY              "ps_qty"
#define  VDCT1_RIS_COLN_PS_DATE             "ps_date"

#define  VDCT1_RIS_COLI_PS_PARENT_CAGE_NUM  0
#define  VDCT1_RIS_COLI_PS_CHILD_CAGE_NUM   1
#define  VDCT1_RIS_COLI_PS_SORT             2
#define  VDCT1_RIS_COLI_PS_QTY              3
#define  VDCT1_RIS_COLI_PS_DATE             4

/* -----------------------------------------------
 * Misc Static Attributes table layout
 */
#define VDCT1_RIS_TBLN_MISC_SATTR                "misc_sattr"
#define VDCT1_RIS_COLN_MISC_SATTR_ITEM_CAGE_NUM  "cage_mino"
#define VDCT1_RIS_COLN_MISC_SATTR_ATTR_NAMES     "attr_name"
#define VDCT1_RIS_COLN_MISC_SATTR_ATTR_DESC      "attr_desc"   //AVD may take this out
#define VDCT1_RIS_COLN_MISC_SATTR_ATTR_VALUE     "attr_value"

#define VDCT1_RIS_COLI_MISC_SATTR_ITEM_CAGE_NUM  0
#define VDCT1_RIS_COLI_MISC_SATTR_ATTR_NAMES     1
//#define VDCT1_RIS_COLI_MISC_SATTR_ATTR_DESC      // we don't need this, and it may disappear
#define VDCT1_RIS_COLI_MISC_SATTR_ATTR_VALUE     2

// Add known attr names here for our use
#define VDCT1_MISC_SATTR_NAME_DRY_WEIGHT          "dry_wt"
#define VDCT1_MISC_SATTR_NAME_PAL_GROUP           "pallet_group"

/* -----------------------------------------------
 * Commidity Code table
 */

/* -----------------------------------------------
 * Commodity Info structure
 */
// field lengths
#define VDCT1_COMM_FLD_LEN_COMM_CODE     12
#define VDCT1_COMM_FLD_LEN_COMMODITY     25
#define VDCT1_COMM_FLD_LEN_COST_CODE     12
#define VDCT1_COMM_FLD_LEN_SEQUENCE_NO   12

#define VDCT1_RIS_TBLN_COMMS             "tm_code_list"
#define VDCT1_RIS_COLN_COMMS_COMM_CODE   "comm_code"
#define VDCT1_RIS_COLN_COMMS_COST_CODE   "cost_code"
#define VDCT1_RIS_COLN_COMMS_COMMODITY   "commodity"
#define VDCT1_RIS_COLN_COMMS_SEQUENCE_NO "sequence_no"

#define VDCT1_RIS_COLI_COMMS_COMM_CODE   0
#define VDCT1_RIS_COLI_COMMS_COST_CODE   1
#define VDCT1_RIS_COLI_COMMS_COMMODITY   2
#define VDCT1_RIS_COLI_COMMS_SEQUENCE_NO 3



// The fields
typedef IGRchar TVDct1_comm_fld_comm_code    [1+VDCT1_COMM_FLD_LEN_COMM_CODE];
typedef IGRchar TVDct1_comm_fld_commodity    [1+VDCT1_COMM_FLD_LEN_COMMODITY];
typedef IGRchar TVDct1_comm_fld_cost_code    [1+VDCT1_COMM_FLD_LEN_COST_CODE];
typedef IGRchar TVDct1_comm_fld_sequence_no  [1+VDCT1_COMM_FLD_LEN_SEQUENCE_NO];

// The record
typedef struct 
{
  TVDct1_comm_fld_comm_code     comm_code;
  TVDct1_comm_fld_commodity     commodity;
  TVDct1_comm_fld_cost_code     cost_code;
  TVDct1_comm_fld_sequence_no   sequence_no;

} TVDct1CommInfo;

/* ----------------------------------------------------------
 * Electrical Drawing code table and info
 */
// field lengths
#define VDCT1_ELECDWG_FLD_LEN_DWG_NUM     13
#define VDCT1_ELECDWG_FLD_LEN_DWG_CODE     2
#define VDCT1_ELECDWG_FLD_LEN_DWG_TITLE  255
#define VDCT1_ELECDWG_FLD_LEN_SECT_NUM     2

#define VDCT1_RIS_TBLN_ELECDWG             "tm_elec_dwg"
#define VDCT1_RIS_COLN_ELECDWG_DWG_NUM     "dwg_num"
#define VDCT1_RIS_COLN_ELECDWG_DWG_CODE    "dwg_code"
#define VDCT1_RIS_COLN_ELECDWG_DWG_TITLE   "dwg_title"
#define VDCT1_RIS_COLN_ELECDWG_SECT_NUM    "sect_num"

#define VDCT1_RIS_COLI_ELECDWG_DWG_NUM     0
#define VDCT1_RIS_COLI_ELECDWG_DWG_CODE    1
#define VDCT1_RIS_COLI_ELECDWG_DWG_TITLE   2
#define VDCT1_RIS_COLI_ELECDWG_SECT_NUM    3



// The fields
typedef IGRchar TVDct1_elecdwg_fld_dwg_num   [1+VDCT1_ELECDWG_FLD_LEN_DWG_NUM];
typedef IGRchar TVDct1_elecdwg_fld_dwg_code  [1+VDCT1_ELECDWG_FLD_LEN_DWG_CODE];
typedef IGRchar TVDct1_elecdwg_fld_dwg_title [1+VDCT1_ELECDWG_FLD_LEN_DWG_TITLE];
typedef IGRchar TVDct1_elecdwg_fld_sect_num  [1+VDCT1_ELECDWG_FLD_LEN_SECT_NUM];

// The record
typedef struct 
{
  TVDct1_elecdwg_fld_dwg_num    dwg_num;
  TVDct1_elecdwg_fld_dwg_code   dwg_code;
  TVDct1_elecdwg_fld_dwg_title  dwg_title;
  TVDct1_elecdwg_fld_sect_num   sect_num;
  
} TVDct1ElecDwgInfo;


/* -----------------------------------------------
 * tree/VDct1Misc.C
 */
extern IGRstat VDct1GetCommInfo   __((IGRchar *commCode, TVDct1CommInfo *comm));

extern IGRstat VDct1GetElecDwgInfo __((IGRchar *dwg_num, TVDct1ElecDwgInfo *info));

/* -----------------------------------------------
 * ISDP to OPS to COPICS Table (IOC)
 */

#define VDCT1_RIS_TBLN_SIOC               "tm_struct_ioc"
#define VDCT1_RIS_COLN_SIOC_ISDP_FAMILY   "isdp_family"
#define VDCT1_RIS_COLN_SIOC_ISDP_CAGE_NUM "isdp_cage_num"
#define VDCT1_RIS_COLN_SIOC_OPS_CAGE_NUM  "ops_cage_num"
#define VDCT1_RIS_COLN_SIOC_COP_CAGE_NUM  "cop_cage_num"
#define VDCT1_RIS_COLN_SIOC_COP_SIZE      "cop_size"
#define VDCT1_RIS_COLN_SIOC_COP_MAX_X     "cop_max_x"
#define VDCT1_RIS_COLN_SIOC_COP_MAX_Y     "cop_max_y"

#define VDCT1_RIS_COLI_SIOC_ISDP_FAMILY   0
#define VDCT1_RIS_COLI_SIOC_ISDP_CAGE_NUM 1
#define VDCT1_RIS_COLI_SIOC_OPS_CAGE_NUM  2
#define VDCT1_RIS_COLI_SIOC_COP_CAGE_NUM  3
#define VDCT1_RIS_COLI_SIOC_COP_SIZE      4
#define VDCT1_RIS_COLI_SIOC_COP_MAX_X     5
#define VDCT1_RIS_COLI_SIOC_COP_MAX_Y     6

typedef struct 
{

  IGRchar  isdp_family  [20];
  IGRchar  isdp_cage_num[32];  // Note: Bigger than standard part_cage_num!
  IGRchar   ops_cage_num[26];  // Don't increase more, just fits into NODE_NAME
  IGRchar   cop_cage_num[26];
  
  IGRchar  cop_size [20];
  IGRchar  cop_max_x[20];
  IGRchar  cop_max_y[20];

} TVDct1RisIOC;

extern IGRstat VDct1QryIOCForPartCageNum  __((TVDrisInfo *ris, 
					      IGRint      type_cage_num, 
					      IGRchar    *part_cage_num));

extern IGRstat VDct1ReadIOCForPartCageNum __((TVDct1RisIOC *ioc,
					      IGRint        type_cage_num,
					      IGRchar      *part_cage_num));

extern IGRstat VDct1MapIOCBuffer          __((IGRchar **buf, TVDct1RisIOC *ioc));

extern IGRstat VDct1InsertIOC             __((TVDct1RisIOC *ioc));

extern IGRstat VDct1DumpIOCTable          __(());

extern IGRstat VDct1GenerateIsdpCageNum   __((IGRchar *cage_code,
					      IGRchar *type,
					      IGRchar *grade,
					      IGRchar *part_num,
					      IGRchar *isdp_cage_num));

extern IGRstat VDct1LoadIOCFromCSVFile    __((IGRchar *fileName));

// Special string inside of isdp cage nums
#define VDCT1_ISDP_TYPE_PLATE "-PL_"
#define VDCT1_ISDP_TYPE_BEAM  "-BM_"

/* -----------------------------------------------
 * Entries in the items table can be either 2,4, or 6
 * Need to be able to query by various combinations
 */
#define VDCT1_ITEM_TYPE_ALL   0
#define VDCT1_ITEM_TYPE_2     2
#define VDCT1_ITEM_TYPE_4     4
#define VDCT1_ITEM_TYPE_6     6
#define VDCT1_ITEM_TYPE_2OR6 26

/* -----------------------------------------------
 * Gather the queries together
 */
extern IGRstat VDct1QryItems __((TVDrisInfo *ris, 
				 IGRint item_type, 
				 IGRchar *name, 
				 IGRchar *value));

extern IGRstat VDct1QryDistinctItems __((TVDrisInfo *ris, 
					 IGRint item_type, 
					 IGRchar *name));

extern IGRstat VDct1QryPartCageNumFromItems        __((TVDrisInfo *ris, IGRchar *part_cage_num));
extern IGRstat VDct1QryPartCageNumFromIsdpItems    __((TVDrisInfo *ris, IGRchar *isdp_cage_num));

// Item Type = 4
extern IGRstat VDct1QryPartIdForPartCageNum        __((TVDrisInfo *ris, IGRchar *part_cage_num));
extern IGRstat VDct1QryPartIdForPartNum            __((TVDrisInfo *ris, IGRchar *part_num));

// All Item Types
extern IGRstat VDct1QryPartIdForItemCageNum        __((TVDrisInfo *ris, IGRchar *part_cage_num));

// Item type = 2
extern IGRstat VDct1QryPartIdForAssyCageNum        __((TVDrisInfo *ris, IGRchar *part_cage_num));


extern IGRstat VDct1QryAttrsForPartId              __((TVDrisInfo *ris, IGRchar *part_id));

extern IGRstat VDct1QryNounNameFromItems           __((TVDrisInfo *ris, IGRchar *noun_name));

extern IGRstat VDct1QryDistinctNounNamesFromItems  __((TVDrisInfo *ris));

extern IGRstat VDct1QryCodesForCommCode            __((TVDrisInfo *ris, IGRchar *comm_code));

extern IGRstat VDct1QryMiscStatAttrsForCageNum     __((TVDrisInfo *ris,
						       IGRchar    *part_cage_num,
						       IGRchar    *attrName));   // optional

extern IGRstat VDct1QryItemTypeForPartCageNum __((TVDrisInfo  *ris,
						  IGRchar     *part_cage_num,
						  IGRchar     *itemType));


//Cleanup
#if defined(__cplusplus)
}
#endif

#endif






