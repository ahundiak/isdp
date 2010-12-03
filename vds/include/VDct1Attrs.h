/* $Id: VDct1Attrs.h,v 1.12.2.2 2003/06/06 20:50:08 ahundiak Exp $  */

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
 *      Revision 1.12.2.2  2003/06/06 20:50:08  ahundiak
 *      ah
 *
 *      Revision 1.12.2.1  2003/05/23 20:30:47  ylong
 *      Modified for Placement Group Tree - yl
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/16/00  pn      Set up to define PPL Data Types
 * 03/28/00  pn      Additional Data Types added
 * 06/30/00  pn      some new attributes added
 * 02/14/01  pn      Added CHG_AUTH attribute
 * 11/17/10  ah      SOL10 Additional attributes
 ***************************************************************************/
/* ---------------------------------------------------
 * Consolidate all the attribute name information here
 */
 
// Default Attribute Values set here
#define VDCT1_DEFAULT_CONT_HULL       "C60017"
#define VDCT1_DEFAULT_FROZEN_A        "ACTIVE"
#define VDCT1_DEFAULT_FROZEN          "ACTIVE"
#define VDCT1_DEFAULT_FROZEN_F        "FROZEN"
#define VDCT1_DEFAULT_FROZEN_D        "DELETED"
#define VDCT1_DEFAULT_ASSY_REV        "000"
// Eng and pal have different avhull values as defaults.
#define VDCT1_DEFAULT_ENG_AV_HULL     "LPD"
#define VDCT1_DEFAULT_PAL_AV_HULL     "2484"
#define VDCT1_DEFAULT_ELEC_LABOR_CODE "08"
#define VDCT1_DEFAULT_HVAC_LABOR_CODE "09"
#define VDCT1_DEFAULT_OUTF_ASSY_CODE  "LPOFA"
#define VDCT1_DEFAULT_ELEC_ASSY_CODE  "LPELA"

#define VDCT1_ENG_NODE_TYPE_PART      "PART"
#define VDCT1_ENG_NODE_TYPE_ASSY      "ASSY"
#define VDCT1_ENG_NODE_TYPE_UNIT      "UNIT"
#define VDCT1_ENG_NODE_TYPE_ZONE      "ZONE"
#define VDCT1_ENG_NODE_TYPE_FAMILY    "FAMILY"
#define VDCT1_ENG_NODE_TYPE_GROUP     "GROUP"
#define VDCT1_ENG_NODE_TYPE_OUTFIT    "OUTFIT_TREE"
#define VDCT1_ENG_NODE_TYPE_PTTREE    "PARTS_TREE"
#define VDCT1_ENG_NODE_TYPE_ENGTREE   "ENG_ASSY_TREE"
#define VDCT1_ENG_NODE_TYPE_PALASSYS  "PAL_ASSYS"
#define VDCT1_ENG_NODE_TYPE_DELTA     "DELTA_TREE"
#define VDCT1_ENG_NODE_TYPE_PALGROUP  "PAL_GROUP"
#define VDCT1_ENG_NODE_TYPE_ENGASSY6  "ENG_ASSY6"
#define VDCT1_ENG_NODE_TYPE_ENGASSY2  "ENG_ASSY2"
#define VDCT1_ENG_NODE_TYPE_ASSY2     "STD_ASSY2"
#define VDCT1_ENG_NODE_TYPE_ASSY6     "STD_ASSY6"
#define VDCT1_ENG_NODE_TYPE_EA6_OLD   "ENG_ASSY[6]"
#define VDCT1_ENG_NODE_TYPE_EA2_OLD   "ENG_ASSY[2]"
#define VDCT1_ENG_NODE_TYPE_ASSY2_OLD "ASSY_TYPE[2]"
#define VDCT1_ENG_NODE_TYPE_ASSY6_OLD "ASSY_TYPE[6]"
#define VDCT1_ENG_NODE_TYPE_PARTS     "PARTS_ASSY"
#define VDCT1_ENG_NODE_TYPE_PALLET    "PALLET"
#define VDCT1_ENG_NODE_TYPE_CABLETREE "CABLE_TREE"
#define VDCT1_ENG_NODE_TYPE_WWAYTREE  "WWAY_TREE"
#define VDCT1_ENG_NODE_TYPE_HVACTREE  "HVAC_TREE"
#define VDCT1_ENG_NODE_TYPE_PLGRPTREE "GROUP_TREE"
#define VDCT1_ENG_NODE_TYPE_COMPART   "COMPARTMENT"
#define VDCT1_ENG_NODE_TYPE_PART_TYPE "PART_TYPE"
#define VDCT1_ENG_NODE_TYPE_NOT_IN_GRP "NOT_IN_GROUP"
#define VDCT1_ENG_NODE_TYPE_ITEM       "ITEM"
//#define VDCT1_ENG_NODE_TYPE_CS       "CS"


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
#define VDCT1_ATTR_DWG_TITLE        "drawing_title"
#define VDCT1_ATTR_DWG_REV          "drawing_rev" // added 6/26/00 pn per jds
#define VDCT1_ATTR_DWG_CODE         "drawing_code"       
#define VDCT1_ATTR_SHORT_DRAW       "short_drawing"
#define VDCT1_ATTR_PAL_GROUP        "pallet_group"
#define VDCT1_ATTR_PAL_STAGE        "pallet_stage"     
#define VDCT1_ATTR_PALLET           "pallet_code"
#define VDCT1_ATTR_MINO             "mino"
#define VDCT1_ATTR_CAGE             "cage"       //added by jdsauby
#define VDCT1_ATTR_MINO_ISDP        "mino_isdp"         
#define VDCT1_ATTR_EQPT_MINO        "eqpt_mino"  // CR 5298       
#define VDCT1_ATTR_EQPT_WEIGHT      "eqpt_weight"  // CR 5541       
#define VDCT1_ATTR_RESERVED         "reserved"   // CR 5290
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
#define VDCT1_ATTR_WET_WEIGHT       "wet_weight"       // added for hvac tree
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

#define VDCT1_ATTR_LOC_X            "loc_x"
#define VDCT1_ATTR_LOC_Y            "loc_y"
#define VDCT1_ATTR_LOC_Z            "loc_z"

#define VDCT1_ATTR_NOMENCLATURE     "nomenclature"   //added by jdsauby
#define VDCT1_ATTR_MBOM_ASSY        "tmbom_assy"
#define VDCT1_ATTR_FROZEN           "frozen"
#define VDCT1_ATTR_COG              "cog"
#define VDCT1_ATTR_TREE_NUM         "tree_num"
#define VDCT1_ATTR_NODE_NUM         "node_num"
#define VDCT1_ATTR_NUM_NEXT         "node_num_next"
#define VDCT1_ATTR_TREE_INDEX       "tree_index"
#define VDCT1_ATTR_PARENT_INDEX     "parent_tree_index"
#define VDCT1_ATTR_IN_COPICS        "copics_status"
#define VDCT1_ATTR_COPICS_NUM       "copics_num"     //added by jdsauby
#define VDCT1_ATTR_PAINT_REF        "paint_ref"
#define VDCT1_ATTR_CHG_AUTH         "change_auth"    // added by pnoel 02/11/01  CR MP#4621

//piping attributes  added by jdsauby
#define VDCT1_ATTR_MOD_LENGTH       "mod_length"
#define VDCT1_ATTR_DETAIL_TYPE      "detail_type"
#define VDCT1_ATTR_DETAIL_SEQ       "detail_seq"
#define VDCT1_ATTR_DETAIL_DIR       "detail_dir"
#define VDCT1_ATTR_DETAIL_LOC       "detail_loc"
#define VDCT1_ATTR_DETAIL_USR       "detail_usr"
#define VDCT1_ATTR_DETAIL_NO        "detail_no"

#define VDCT1_ISDP_ATTR_CUT_LENGTH   "memb_cut_leng"
#define VDCT1_ISDP_ATTR_EQP_DESC     "eqp_descr"
#define VDCT1_ISDP_ATTR_EQP_NUMBER   "eqp_number"
#define VDCT1_ISDP_ATTR_EQP_FAMILY   "eqp_family"
#define VDCT1_ISDP_ATTR_EQP_PARTNO   "eqp_partno"
#define VDCT1_ISDP_ATTR_EQP_PARTREV  "eqp_partrev"
#define VDCT1_ISDP_ATTR_ZONE         "zone_number"
#define VDCT1_ISDP_ATTR_UNIT         "unit_number"
#define VDCT1_ISDP_ATTR_COMPARTMENT  "compt_number"
#define VDCT1_ISDP_ATTR_GRADE        "grade"
#define VDCT1_ISDP_ATTR_PART_NUM     "part_num"
#define VDCT1_ISDP_ATTR_PLATE_THK    "plate_thk"
#define VDCT1_ISDP_ATTR_WEIGHT       "unit_weight"
#define VDCT1_ISDP_ATTR_THICKNESS    "plate_thk"
#define VDCT1_ISDP_ATTR_TREATMENT    "treatment"
#define VDCT1_ISDP_ATTR_FAM_NAME     "family_name"
#define VDCT1_ISDP_ATTR_ESTIM_LENGTH "estim_length"
#define VDCT1_ISDP_ATTR_TAIL_LENGTH  "tail_length"
#define VDCT1_ISDP_ATTR_CABLE_WEIGHT "weight"

// Standard Parts and Assemblies
#define VDCT1_NODE_TYPE_STD_PART    "STD_PART"
#define VDCT1_NODE_TYPE_STD_PART4   "STD_PART4"
#define VDCT1_NODE_TYPE_STD_PART4_OLD   "STD_PART[4]"
#define VDCT1_NODE_TYPE_STD_PARTS   "STD_PARTS"

#define VDCT1_NODE_TYPE_STD_ASSY    "STD_ASSY"
#define VDCT1_NODE_TYPE_STD_ASSY2   "STD_ASSY2"
#define VDCT1_NODE_TYPE_STD_ASSY6   "STD_ASSY6"
#define VDCT1_NODE_TYPE_STD_ASSY2_OLD   "STD_ASSY[2]"
#define VDCT1_NODE_TYPE_STD_ASSY6_OLD   "STD_ASSY[6]"
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

// Wireway attributes
#define VDCT1_ATTR_TIER_SPACING     "cpt1_tiersp"
#define VDCT1_ATTR_METHOD_NO        "method_no"
#define VDCT1_ATTR_METHOD_TYPE      "method_type"
#define VDCT1_ATTR_PACKING_METHOD   "packing_method"
#define VDCT1_ATTR_COLLAR_TYPE      "collar_type"
#define VDCT1_ATTR_HOLE_NO          "hole_no"
#define VDCT1_ATTR_WELD_SYMBOL      "weld_symbol"
#define VDCT1_ATTR_ORIENTATION      "orientation"
#define VDCT1_ATTR_MODEL_ID         "model_id"
#define VDCT1_ATTR_SYSTEM_CLASS     "system_class"

// HVAC Tree Attributes
#define VDCT1_ATTR_NEXT_VD          "next_vd"
#define VDCT1_ATTR_COMP_CODE        "comp_code"
#define VDCT1_ATTR_SPEC_NAME        "spec_name"
#define VDCT1_ATTR_DUCT_MATL        "duct_matl"
#define VDCT1_ATTR_SEQ_NUMBER       "seq_number"
#define VDCT1_ATTR_SURF_AREA        "surf_area"
#define VDCT1_ATTR_DUCT_LENGTH      "duct_length"
#define VDCT1_ATTR_BEND_SWEEP       "bend_sweep"
#define VDCT1_ATTR_THROAT_RAD       "throat_rad"
#define VDCT1_ATTR_TRANS_LEN        "trans_len"
#define VDCT1_ATTR_CORNER_RAD       "corner_radius"
#define VDCT1_ATTR_WIDTH_1          "width_1"
#define VDCT1_ATTR_WIDTH_2          "width_2"
#define VDCT1_ATTR_WIDTH_3          "width_3"
#define VDCT1_ATTR_WIDTH_4          "width_4"
#define VDCT1_ATTR_DEPTH_1          "depth_1"
#define VDCT1_ATTR_DEPTH_2          "depth_2"
#define VDCT1_ATTR_DEPTH_3          "depth_3"
#define VDCT1_ATTR_DEPTH_4          "depth_4"
#define VDCT1_ATTR_COATING          "coating"
#define VDCT1_ATTR_MAKE_BUY         "make_buy"

// Placement Group
#define VDCT1_ATTR_SIR_ID           "sirid"
#define VDCT1_ATTR_SIR_TAG          "SrTagNum"
#define VDCT1_ATTR_GROUP_NAME       "group_name"
#define VDCT1_ATTR_ITEM_NAME        "item_name"
#define VDCT1_ATTR_ITEM_COPICS_DESC "copics_decs"
