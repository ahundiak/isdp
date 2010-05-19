/* $Id: VDct1Attrs.h,v 1.2 2001/01/12 14:47:06 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDct1Attrs.h
 *
 * Description: Collector Tree Object
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Attrs.h,v $
 *      Revision 1.2  2001/01/12 14:47:06  art
 *      sp merge
 *
 * Revision 1.12  2000/06/30  18:52:26  pinnacle
 * pn
 *
 * Revision 1.11  2000/06/06  20:29:18  pinnacle
 * ah
 *
 * Revision 1.10  2000/06/05  15:15:16  pinnacle
 * ah
 *
 * Revision 1.9  2000/05/17  15:57:46  pinnacle
 * Replaced: vds/vdct1/ppl/*.h for:  by jdsauby for Service Pack
 *
 * Revision 1.8  2000/05/17  12:19:34  pinnacle
 * Replaced: vds/vdct1/ppl/*.h for:  by jdsauby for Service Pack
 *
 * Revision 1.7  2000/05/16  14:35:28  pinnacle
 * Replaced: vds/vdct1/ppl/VDct1Attrs.h for:  by pnoel for Service Pack
 *
 * Revision 1.5  2000/05/10  19:22:20  pinnacle
 * Replaced: vds/vdct1/ppl/VDct1Attrs.h for:  by jdsauby for Service Pack
 *
 * Revision 1.4  2000/05/09  19:10:06  pinnacle
 * Replaced: vds/vdct1/ppl/VDct1Attrs.h for:  by pnoel for Service Pack
 *
 * Revision 1.1  2000/04/20  18:48:20  pinnacle
 * Created: vds/vdct1/ppl/VDct1Attrs.h by pnoel for Service Pack
 *
 * Revision 1.5  2000/03/30  18:41:10  pinnacle
 * pn.
 *
 * Revision 1.3  2000/03/24  20:35:06  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/16/00  pn      Set up to define PPL Data Types
 * 03/28/00  pn      Additional Data Types added
 * 06/30/00  pn      some new attributes added
 ***************************************************************************/
/* ---------------------------------------------------
 * Consolidate all the attribute name information here
 */
 
#define VDCT1_ENG_NODE_TYPE_PART     "PART"
#define VDCT1_ENG_NODE_TYPE_ASSY     "ASSY"
#define VDCT1_ENG_NODE_TYPE_UNIT     "UNIT"
#define VDCT1_ENG_NODE_TYPE_ZONE     "ZONE"
#define VDCT1_ENG_NODE_TYPE_FAMILY   "FAMILY"
#define VDCT1_ENG_NODE_TYPE_GROUP    "GROUP"
#define VDCT1_ENG_NODE_TYPE_OUTFIT   "OUTFIT_TREE"
#define VDCT1_ENG_NODE_TYPE_PTTREE   "PARTS_TREE"
#define VDCT1_ENG_NODE_TYPE_ENGTREE  "ENG_ASSY_TREE"
#define VDCT1_ENG_NODE_TYPE_PALASSYS "PAL_ASSYS"
#define VDCT1_ENG_NODE_TYPE_PALGROUP "PAL_GROUP"
#define VDCT1_ENG_NODE_TYPE_ENGASSY6 "ENG_ASSY[6]"
#define VDCT1_ENG_NODE_TYPE_ENGASSY2 "ENG_ASSY[2]"
#define VDCT1_ENG_NODE_TYPE_ASSY2    "ASSY_TYPE[2]"
#define VDCT1_ENG_NODE_TYPE_PARTS    "PARTS_ASSY"
#define VDCT1_ENG_NODE_TYPE_PALLET   "PALLET"
//#define VDCT1_ENG_NODE_TYPE_CS      "CS"


#define VDCT1_ATTR_CONT_HULL        "contracthull"
#define VDCT1_ATTR_AV_HULL          "avhull"
#define VDCT1_ATTR_CONTRACT_JOB     "job_num"
#define VDCT1_ATTR_HULL_JOB         "job_hull_num"
#define VDCT1_ATTR_GROUP_CODE       "group_code"
#define VDCT1_ATTR_COM_CODE         "comm_code"
#define VDCT1_ATTR_COMM_CODE        "comm_code"
#define VDCT1_ATTR_COMMODITY        "commodity"  //added by jdsauby
#define VDCT1_ATTR_COST_CODE        "cost_code"
#define VDCT1_ATTR_PROJ_CODE        "proj_code"  // LPOFA
#define VDCT1_ATTR_LABOR_CODE       "labor_code"
#define VDCT1_ATTR_ZONE             "zone_num"
#define VDCT1_ATTR_UNIT             "unit_num"
#define VDCT1_ATTR_COMPARTMENT      "compt_num"
#define VDCT1_ATTR_DWG_NUM          "drawing_no"  
#define VDCT1_ATTR_DWG_REV          "drawing_rev" // added 6/26/00 pn per jds
#define VDCT1_ATTR_DWG_CODE         "drawing_code"       
#define VDCT1_ATTR_SHORT_DRAW       "short_drawing"
#define VDCT1_ATTR_PAL_GROUP        "pallet_group"
#define VDCT1_ATTR_PAL_STAGE        "pallet_stage"     
#define VDCT1_ATTR_PALLET           "pallet_code"
#define VDCT1_ATTR_MINO             "mino"
#define VDCT1_ATTR_CAGE             "cage"       //added by jdsauby
#define VDCT1_ATTR_MINO_ISDP        "mino_isdp"         
#define VDCT1_ATTR_QTY              "qty"
#define VDCT1_ATTR_LINE_IDENT       "line_ident"
#define VDCT1_ATTR_FIAN             "fian"              
#define VDCT1_ATTR_ISDP_NAME        "isdp_name"
#define VDCT1_ATTR_ISDP_PATH        "isdp_path"
#define VDCT1_ATTR_UNIT_MEASURE     "unit_measure"      
#define VDCT1_ATTR_MATERIAL         "material"
#define VDCT1_ATTR_SIZE             "part_size"        //added by jdsauby
#define VDCT1_ATTR_SPEC_CODE        "spec_code"
#define VDCT1_ATTR_SPECIAL_CODE     "special_code"
#define VDCT1_ATTR_WEIGHT           "weight"
#define VDCT1_ATTR_WEIGHT_ASSY      "weight_assy"
#define VDCT1_ATTR_UNIT_WT          "unit_measure"
#define VDCT1_ATTR_LOCATION         "location"
#define VDCT1_ATTR_ASSY_REV         "assy_rev"    //modified by jdsauby
#define VDCT1_ATTR_PART_REV         "part_rev"    //added by jdsauby
#define VDCT1_ATTR_PART_NO          "part_no"     //added by jdsauby
#define VDCT1_ATTR_COUNT            "node_count"
#define VDCT1_ATTR_ASSY_DATE        "assy_date"
#define VDCT1_ATTR_PART_DATE        "part_date"    //modified by jdsauby
#define VDCT1_ATTR_ASSY_DESCR       "assy_descr"   //modified by jdsauby
#define VDCT1_ATTR_ASSY_REMARKS     "assy_remarks" //modified by jdsauby
#define VDCT1_ATTR_PART_DESCR       "part_descr"   //added by jdsauby
#define VDCT1_ATTR_PART_REMARKS     "part_remarks" //added by jdsauby
#define VDCT1_ATTR_WEIGHT_UNITS     "unit_weight_units"
#define VDCT1_ATTR_UM               "um"
#define VDCT1_ATTR_PART_TYPE        "part_type"
#define VDCT1_ATTR_MIC_CODE         "mic_code"
#define VDCT1_ATTR_ENG_DATE         "date"
#define VDCT1_ATTR_PAL_DATE         "date"
#define VDCT1_ATTR_MAT1             "mat1"
#define VDCT1_ATTR_MAT2             "mat2"
#define VDCT1_ATTR_MAT3             "mat3"
#define VDCT1_ATTR_MAT4             "mat4"
#define VDCT1_ATTR_STOCK            "stock"
#define VDCT1_ATTR_PCT_MINO         "pct_mino"
#define VDCT1_ATTR_LOC_Z            "loc_z"
#define VDCT1_ATTR_NOMENCLATURE     "nomenclature"   //added by jdsauby
#define VDCT1_ATTR_MBOM_ASSY        "tmbom_assy"
#define VDCT1_ATTR_FROZEN           "frozen"
#define VDCT1_ATTR_COG              "cog"
#define VDCT1_ATTR_TREE_NUM         "tree_num"
#define VDCT1_ATTR_NODE_NUM         "node_num"
#define VDCT1_ATTR_NUM_NEXT         "node_num_next"
#define VDCT1_ATTR_TREE_INDEX       "tree_index"
#define VDCT1_ATTR_IN_COPICS        "copics_status"
#define VDCT1_ATTR_COPICS_NUM       "copics_num"     //added by jdsauby
#define VDCT1_ATTR_PAINT_REF        "paint_ref"

//piping attributes  added by jdsauby
#define VDCT1_ATTR_MOD_LENGTH       "mod_length"
#define VDCT1_ATTR_DETAIL_TYPE      "detail_type"
#define VDCT1_ATTR_DETAIL_SEQ       "detail_seq"
#define VDCT1_ATTR_DETAIL_DIR       "detail_dir"
#define VDCT1_ATTR_DETAIL_LOC       "detail_loc"
#define VDCT1_ATTR_DETAIL_USR       "detail_usr"
#define VDCT1_ATTR_DETAIL_NO        "detail_no"

#define VDCT1_ISDP_ATTR_CUT_LENGTH  "memb_cut_leng"
#define VDCT1_ISDP_ATTR_EQP_FAMILY  "eqp_family"
#define VDCT1_ISDP_ATTR_EQP_PARTNO  "eqp_partno"
#define VDCT1_ISDP_ATTR_EQP_PARTREV "eqp_partrev"
#define VDCT1_ISDP_ATTR_UNIT        "unit_number"
#define VDCT1_ISDP_ATTR_COMPARTMENT "compt_number"
#define VDCT1_ISDP_ATTR_GRADE       "grade"
#define VDCT1_ISDP_ATTR_PART_NUM    "part_num"
#define VDCT1_ISDP_ATTR_PLATE_THK   "plate_thk"
#define VDCT1_ISDP_ATTR_WEIGHT      "unit_weight"
#define VDCT1_ISDP_ATTR_THICKNESS   "plate_thk"
#define VDCT1_ISDP_ATTR_TREATMENT   "treatment"

// Standard Parts and Assemblies
#define VDCT1_NODE_TYPE_STD_PART    "STD_PART"
#define VDCT1_NODE_TYPE_STD_PART4   "STD_PART[4]"
#define VDCT1_NODE_TYPE_STD_PARTS   "STD_PARTS"

#define VDCT1_NODE_TYPE_STD_ASSY    "STD_ASSY"
#define VDCT1_NODE_TYPE_STD_ASSY2   "STD_ASSY[2]"
#define VDCT1_NODE_TYPE_STD_ASSYS   "STD_ASSYS"

#define VDCT1_NODE_TYPE_NOUN_NAME   "NOUN_NAME"
#define VDCT1_NODE_TYPE_COMM_CODE   "COMM_CODE"

#define VDCT1_ATTR_ITEM_CAGE_NUM    "item_cage_num"
#define VDCT1_ATTR_ITEM_CAGE_CODE   "item_cage_code"
#define VDCT1_ATTR_ITEM_NUM         "item_num"
#define VDCT1_ATTR_ITEM_DESC        "item_desc"
#define VDCT1_ATTR_ITEM_UM          "item_um"
#define VDCT1_ATTR_ITEM_REV         "item_rev"
#define VDCT1_ATTR_ITEM_DATE        "item_date"
#define VDCT1_ATTR_ITEM_QTY         "item_qty"





