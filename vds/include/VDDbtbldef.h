/* $Id: VDDbtbldef.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include / VDDbtbldef.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDDbtbldef.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.3  1997/12/17  22:16:10  pinnacle
 * AssyTree
 *
 * Revision 1.2  1997/12/03  15:25:06  pinnacle
 * Replaced: include/VDDbtbldef.h for:  by v250_int for vds
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY  AUTHOR  DESCRIPTION
 *	12/14/97  ah      Some more Assembly Tree attributes
 * -------------------------------------------------------------------*/


#ifndef VDDbtbldef_include
#define VDDbtbldef_include

/* ------	Definitions of tables used	--------------*/

/* --- Definitions of COLUMN NAMES or ATTRIBUTE NAMES used  ---- */

#define		VD_N_ORIGINAL_AN		"original"
#define		VD_N_FAMILY_NAME_AN		"family_name"
#define		VD_N_COMP_CODE_AN		"comp_code"
#define		VD_N_PART_NUM_AN		"part_num"
#define		VD_N_FAMILY_CODE_IN		"family_code"
#define		VD_N_PART_CODE_IN		"part_code"
#define		VD_N_SHORT_CODE_AN		"short_code"
#define		VD_N_MACRO_NAME_AN		"macro_name"
#define		VD_N_DESCRIPT_AN		"descript"
#define		VD_N_DENSITY_AN			"density"
#define		VD_N_MATERIAL_AN		"material"
#define		VD_N_GRADE_AN			"grade"
#define		VD_N_UNITS_SET_IN		"units_set"
#define		VD_N_VOLUME_DB			"volume"
#define		VD_N_WEIGHT_DB			"weight"
#define		VD_N_SURFAREA_AN		"surface_area"
#define		VD_N_DGN_TEMP_DB		"dgn_temp"
#define		VD_N_DGN_PRESS_DB		"dgn_press"
#define		VD_N_OPER_TEMP_DB		"op_temp"
#define		VD_N_OPER_PRESS_DB		"op_press"
#define		VD_N_GROUP_AN			"grp" /*hardcoded in Compart*/

/*
 * Nozzle/Terminal attributes 
 * For Nozzles & Terminals one of the attributes is the eqp_number ie TAG_NUMBER
 * of Equipment it is connected to.
 */ 

#define		VD_N_EQP_NUMBER_AN		"eqp_number"
#define		VD_N_EQP_ID_IN			"eqp_id_no"

/* Names of the attributes used for DYNAMIC tables */

#define		VD_N_COMPSEQNO_IN		"comp_seqno"
#define		VD_N_ASMB_CATALOG_AN		"assembly_cat"
#define		VD_N_ASMB_NAME_AN		"assembly_nam"
#define		VD_N_ASMB_VERSION_AN		"assembly_ver"
#define		VD_N_TAG_NUMBER_AN		"tag_number"
#define		VD_N_SYSTEM_NAME_AN		"system_name"
#define		VD_N_ID_CATEGORY_IN		"id_category"
#define		VD_N_AUTO_ID_AN			"auto_id"
#define		VD_N_BEHAVIOUR_IN		"id_behaviour"
#define		VD_N_COMMODITY_AN		"commodity"
#define		VD_N_ZONE_NUMBER_AN		"zone_number"
#define		VD_N_COMP_NOTE_AN		"comp_note"
#define		VD_N_INSUL_TYPE_AN		"insul_type"
#define		VD_N_INSUL_THK_D		"insul_thk"
#define		VD_N_APPRV_STAT_AN		"apprv_stat"
#define		VD_N_CONST_STAT_AN		"constr_stat"
#define		VD_N_NO_MTO_FLAG_AN		"no_mto_flag"
#define		VD_N_CHANGE_NO_IN		"chg_no"
#define		VD_N_ERR_CMP_FLAG_AN		"err_cmp_flg"
	
#define		VD_N_LOCATION_X_DB		"loc_x"
#define		VD_N_LOCATION_Y_DB		"loc_y"
#define		VD_N_LOCATION_Z_DB		"loc_z"
#define		VD_N_COG_X_DB			"cog_x"
#define		VD_N_COG_Y_DB			"cog_y"
#define		VD_N_COG_Z_DB			"cog_z"
#define		VD_N_PRIMARY_AXIS_X_DB		"pri_x"
#define		VD_N_PRIMARY_AXIS_Y_DB		"pri_y"
#define		VD_N_PRIMARY_AXIS_Z_DB		"pri_z"
#define		VD_N_SECONDARY_AXIS_X_DB	"sec_x"
#define		VD_N_SECONDARY_AXIS_Y_DB	"sec_y"
#define		VD_N_SECONDARY_AXIS_Z_DB	"sec_z"
#define		VD_N_MOI_X_DB			"mx"
#define		VD_N_MOI_Y_DB			"my"
#define		VD_N_MOI_Z_DB			"mz"

/* Added for assembly tree posting */
#define		VD_N_SIZE_X_DB		        "size_x"
#define		VD_N_SIZE_Y_DB		        "size_y"
#define		VD_N_SIZE_Z_DB		        "size_z"

/* Seems like need three axis for orientation */
#define		VD_N_THIRD_AXIS_X_DB	        "third_x"
#define		VD_N_THIRD_AXIS_Y_DB	        "third_y"
#define		VD_N_THIRD_AXIS_Z_DB	        "third_z"

/* The moment function returnd 6 doubles, not sure about the 
 * other 3 so just put them in for now
 */
#define		VD_N_MOI_X2_DB			"mx2"
#define		VD_N_MOI_Y2_DB			"my2"
#define		VD_N_MOI_Z2_DB			"mz2"

/* Encompassing range box */
#define		VD_N_RANGE_X1_DB		"range_x1"
#define		VD_N_RANGE_Y1_DB		"range_y1"
#define		VD_N_RANGE_Z1_DB		"range_z1"
#define		VD_N_RANGE_X2_DB		"range_x2"
#define		VD_N_RANGE_Y2_DB		"range_y2"
#define		VD_N_RANGE_Z2_DB		"range_z2"

/*
 * schematics sttributes.
 */
#define		VD_N_SCH_SCALE_DB		"pid_scale"

#define		VD_N_FLOW_RATE_DB		"flow_rate"
#define		VD_N_DUCT_LENGTH_DB		"duct_length"
#define		VD_N_VELOCITY_CALC_DB		"veloc_calc"
#define		VD_N_PRESSURE_DROP_DB		"press_drop"

/* Names of the attributes used for DYNAMIC PRODUCTION tables */

#define		VD_N_LEAF_SEQNO_IN		"leaf_seqno"
#define		VD_N_LEAF_CATALOG_AN		"leaf_cat"
#define		VD_N_LEAF_NAME_AN		"leaf_nam"
#define		VD_N_LEAF_VERSION_AN		"leaf_ver"

#define		VD_N_NODE_SEQNO_IN		"node_seqno"
#define		VD_N_NODE_CATALOG_AN		"node_cat"
#define		VD_N_NODE_NAME_AN		"node_nam"
#define		VD_N_NODE_VERSION_AN		"node_ver"

#endif
