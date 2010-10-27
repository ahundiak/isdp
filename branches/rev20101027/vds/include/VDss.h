/* $Id: VDss.h,v 1.14 2002/05/17 15:20:25 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDss.h
 *
 * Description: Snapshot routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDss.h,v $
 *      Revision 1.14  2002/05/17 15:20:25  ahundiak
 *      ah
 *
 *      Revision 1.13  2002/05/03 13:42:13  ahundiak
 *      ah
 *
 *      Revision 1.12  2002/05/01 19:54:00  ahundiak
 *      ah
 *
 *      Revision 1.11  2002/04/15 13:41:04  ahundiak
 *      ah
 *
 *      Revision 1.10  2002/03/04 20:56:06  ylong
 *      CR5068 and CR5286
 *
 *      Revision 1.9  2002/02/27 16:37:18  ahundiak
 *      ah
 *
 *      Revision 1.8  2001/08/24 19:58:34  ahundiak
 *      ah
 *
 *      Revision 1.7  2001/08/14 19:06:56  ahundiak
 *      ah
 *
 *      Revision 1.6  2001/08/02 15:34:09  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/07/28 17:30:34  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/03/19 22:03:41  jdsauby
 *      Added pdm_info and purp_info attributes
 *
 *      Revision 1.3  2001/03/16 16:49:33  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/03/13 00:15:21  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/03/11 18:38:58  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/10/01  ah      Creation
 ***************************************************************************/

#ifndef VDss_include
#define VDss_include

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* ---------------------------------------------
 * These node types are used by the object
 * manager stuff i.e. for real modeled pieces
 *
 * These are copied from VDctx.h for documentation
 * keep them in sync
 */
#define VDCTX_NODE_TYPE_BEAM     "beam"
#define VDCTX_NODE_TYPE_PLATE    "plate"
#define VDCTX_NODE_TYPE_OM_BEAM  "om_beam"
#define VDCTX_NODE_TYPE_OM_PLATE "om_plate"
#define VDCTX_TREE_TYPE_OM       "om"

/* ---------------------------------------------
 * Common attributes 
 * Might want to prepend with ig_ ???
 */

/* -----------------------------------------------
 * Snapshot stuff
 */
#define VDCTX_NODE_TYPE_SS_OM_BEAM    "ss_om_beam"
#define VDCTX_NODE_TYPE_SS_OM_BEAMS   "ss_om_beams"

#define VDCTX_NODE_TYPE_SS_OM_PLATE   "ss_om_plate"
#define VDCTX_NODE_TYPE_SS_OM_PLATES  "ss_om_plates"

#define VDCTX_NODE_TYPE_SS_OM_PIECE   "ss_om_piece"
#define VDCTX_NODE_TYPE_SS_OM_PIECES  "ss_om_pieces"

#define VDCTX_NODE_TYPE_SS_OM_BEVEL_PLATE "ss_om_bevel_plate"
#define VDCTX_NODE_TYPE_SS_OM_BEVEL    "ss_om_bevel"
#define VDCTX_NODE_TYPE_SS_OM_BEVELS   "ss_om_bevels"

#define VDCTX_NODE_TYPE_SS_OM_PEN      "ss_om_pen"
#define VDCTX_NODE_TYPE_SS_OM_PENS     "ss_om_pens"

#define VDCTX_NODE_TYPE_SS_OM_PCG_PEN   "ss_om_pcg_pen"
#define VDCTX_NODE_TYPE_SS_OM_PCG_RFPLN "ss_om_pcg_ref_plane"
#define VDCTX_NODE_TYPE_SS_OM_PCG       "ss_om_pcg"
#define VDCTX_NODE_TYPE_SS_OM_PCGS      "ss_om_pcgs"

#define VDCTX_NODE_TYPE_SS_ST_PIECE   "ss_st_piece"
#define VDCTX_NODE_TYPE_SS_ST_PLATE   "ss_st_plate"
#define VDCTX_NODE_TYPE_SS_ST_BEAM    "ss_st_beam"
#define VDCTX_NODE_TYPE_SS_ST_ROOT    "ss_st_unit"
#define VDCTX_NODE_TYPE_SS_ST_UNIT    "ss_st_unit"

#define VDCTX_NODE_TYPE_AT_ST_PIECE   "pm"

#define VDCTX_NODE_TYPE_SS_OM_EQP       "ss_om_eqp"
#define VDCTX_NODE_TYPE_SS_OM_EQPS      "ss_om_eqps"
#define VDCTX_NODE_TYPE_SS_OM_COLLECTOR "ss_om_collector"
#define VDCTX_NODE_TYPE_SS_OM_CS        "ss_om_cs"

#define VDCTX_NODE_TYPE_SS_OM_NOZZLE    "ss_om_nozzle"
#define VDCTX_NODE_TYPE_SS_OM_NOZZLES   "ss_om_nozzles"

#define VDCTX_NODE_TYPE_SS_OM_CPT       "ss_om_cpt"
#define VDCTX_NODE_TYPE_SS_OM_CPTS      "ss_om_cpts"

#define VDCTX_NODE_TYPE_SS_OM_COMPONENTS "ss_om_components"
#define VDCTX_NODE_TYPE_SS_OM_COMPONENT  "ss_om_component"
#define VDCTX_NODE_TYPE_SS_OM_VRCNRLSEG  "ss_om_vrcnrlseg"

/* ---------------------------------------------
 * Tree Types
 */
#define VDCTX_TREE_TYPE_SS_UNIT_HULL    "ss_unit_hull"
#define VDCTX_TREE_TYPE_SS_UNIT_PROD    "ss_unit_prod"
#define VDCTX_TREE_TYPE_SS_UNIT_FABDATA "ss_unit_fabdata"
#define VDCTX_TREE_TYPE_SS_UNIT_UCM     "ss_unit_ucm"
#define VDCTX_TREE_TYPE_SS_UNIT_PROFILE "ss_unit_profile"

/* ---------------------------------------------
 * Various attributes
 * Some need to match the VDctx defaults
 * But it's easier to have ss defined for everything
 */
#define VDCTX_ATR_SS_CREATION_TIMESTAMP "ts_creation"

#define VDCTX_ATR_SS_BASE_INFO    "base_info"
#define VDCTX_ATR_SS_PDM_INFO     "pdm_info"
#define VDCTX_ATR_SS_PURPOSE_INFO "purpose_info"
#define VDCTX_ATR_SS_PURPOSE      "ss_purpose"

#define VDCTX_ATR_SS_COMP_PATH "comp_path"
#define VDCTX_ATR_SS_COMP_TAG  "comp_tagx"
#define VDCTX_ATR_SS_SYMBOLOGY "symbology"

#define VDCTX_ATR_SS_PIECE_FAMILY    "piece_family"
#define VDCTX_ATR_SS_PIECE_PART_NUM  "piece_part_num"
#define VDCTX_ATR_SS_PIECE_MATERIAL  "piece_material"
#define VDCTX_ATR_SS_PIECE_GRADE     "piece_grade"
#define VDCTX_ATR_SS_PIECE_RESERVED  "piece_reserved"

#define VDCTX_ATR_SS_PIECE_PCMK      "piece_pcmk"
#define VDCTX_ATR_SS_PIECE_PCMK_KEY  "piece_pcmk_key"
#define VDCTX_ATR_SS_PIECE_NOT_LIKE  "piece_not_like"

/* -------------------------------------------
 * Really should have piece_geom_key but already
 * have some snapshots with the original name
 * and it seems a bit painful to change?
 */
#define VDCTX_ATR_SS_PIECE_GEOM_KEY  "geom_key"

#define VDCTX_ATR_SS_PIECE_TYPE       "piece_type"
#define VDCTX_ATR_SS_PIECE_TYPE_PLATE "plate"
#define VDCTX_ATR_SS_PIECE_TYPE_BEAM  "beam"
#define VDCTX_ATR_SS_PIECE_TYPE_BEVEL "bevel"
#define VDCTX_ATR_SS_PIECE_TYPE_PEN   "pen"
#define VDCTX_ATR_SS_PIECE_TYPE_PCG   "pcg"

#define VDCTX_ATR_SS_PLATE_AREA      "plate_area"
#define VDCTX_ATR_SS_PLATE_BEVELS    "plate_bevel"
#define VDCTX_ATR_SS_PLATE_CENTER    "plate_center"
#define VDCTX_ATR_SS_PLATE_THICKNESS "plate_thickness"
#define VDCTX_ATR_SS_PLATE_IS_PLANAR "plate_is_planar"

#define VDCTX_ATR_SS_BEAM_STOCKS     "beam_stocks"
#define VDCTX_ATR_SS_BEAM_TREATMENTS "beam_treatments"
#define VDCTX_ATR_SS_BEAM_CUT_LENGTH "beam_cut_length"
#define VDCTX_ATR_SS_BEAM_HEIGHT     "beam_height"
#define VDCTX_ATR_SS_BEAM_WEB_THK    "beam_web_thk"
#define VDCTX_ATR_SS_BEAM_ET0        "beam_et0"
#define VDCTX_ATR_SS_BEAM_EI0        "beam_ei0"
#define VDCTX_ATR_SS_BEAM_ET1        "beam_et1"
#define VDCTX_ATR_SS_BEAM_EI1        "beam_ei1"

#define VDCTX_ATR_SS_BEAM_AREA       "beam_area"
#define VDCTX_ATR_SS_BEAM_CENTER     "beam_center"
#define VDCTX_ATR_SS_BEAM_IS_PLANAR  "beam_is_planar"

/* bevel attributes */
#define VDCTX_ATR_SS_BEVEL_MACRO_TYPE   "bevel_macro_type"
#define VDCTX_ATR_SS_BEVEL_BEVEL_TYPE   "bevel_type"
#define VDCTX_ATR_SS_BEVEL_PROCESS_TYPE "bevel_process_type"
#define VDCTX_ATR_SS_BEVEL_STOCK_VALUE  "bevel_stock_value"
#define VDCTX_ATR_SS_BEVEL_BEVEL_LENGTH	"bevel_length"
/* pen atributes */
#define VDCTX_ATR_SS_PEN_CS		"pen_coord_system"
#define VDCTX_ATR_SS_PEN_COMPARTMENT	"pen_compartment"
#define VDCTX_ATR_SS_PEN_REVISION	"pen_revision"
#define VDCTX_ATR_SS_PEN_MACRO_LIB	"pen_macro_lib"
#define VDCTX_ATR_SS_PEN_SHAPE		"pen_shape"
#define VDCTX_ATR_SS_PEN_TYPE		"pen_type"
#define VDCTX_ATR_SS_PEN_STRUCT_CUT	"pen_structure_to_cut"
#define VDCTX_ATR_SS_PEN_LONG_AXIS	"pen_long_axis"
#define VDCTX_ATR_SS_PEN_DESCRIPTION	"pen_description"
#define VDCTX_ATR_SS_PEN_SHAPE_MACRO	"pen_macro_name"
#define VDCTX_ATR_SS_PEN_SHAPE_DIAMETER	"pen_diameter"
#define VDCTX_ATR_SS_PEN_SHAPE_RADIUS	"pen_radius"
#define VDCTX_ATR_SS_PEN_SHAPE_RAD_CORN	"pen_radius_corner"
#define VDCTX_ATR_SS_PEN_SHAPE_WIDTH	"pen_width"
#define VDCTX_ATR_SS_PEN_SHAPE_DEPTH	"pen_depth"

/* pcg atributes */
#define VDCTX_ATR_SS_PCG_APPROVAL	"pcg_approval"
#define VDCTX_ATR_SS_PCG_PEN_NAME	"pcg_penetration_name"
#define VDCTX_ATR_SS_PCG_FA_PLANE	"pcg_fwd_aft_plane"
#define VDCTX_ATR_SS_PCG_FA_VALUE	"pcg_fwd_aft_value"
#define VDCTX_ATR_SS_PCG_REF_DECK	"pcg_reference_deck"
#define VDCTX_ATR_SS_PCG_CUT_TYPE	"pcg_cut_type"
#define VDCTX_ATR_SS_PCG_PORT_STARBOARD	"pcg_port_starboard"
#define VDCTX_ATR_SS_PCG_VERTICAL_ABL	"pcg_vertical_abl"
#define VDCTX_ATR_SS_PCG_VERTICAL_XY	"pcg_vertical_x_or_y"
#define VDCTX_ATR_SS_PCG_CS		"pcg_coord_system"
#define VDCTX_ATR_SS_PCG_COMPARTMENT	"pcg_compartment"
#define VDCTX_ATR_SS_PCG_REVISION	"pcg_revision"
#define VDCTX_ATR_SS_PCG_MACRO_LIB	"pcg_macro_lib"
#define VDCTX_ATR_SS_PCG_SHAPE		"pcg_shape"
#define VDCTX_ATR_SS_PCG_TYPE		"pcg_type"
#define VDCTX_ATR_SS_PCG_STRUCT_CUT	"pcg_structure_to_cut"
#define VDCTX_ATR_SS_PCG_LONG_AXIS	"pcg_long_axis"
#define VDCTX_ATR_SS_PCG_DESCRIPTION	"pcg_description"
#define VDCTX_ATR_SS_PCG_SHAPE_MACRO	"pcg_macro_name"
#define VDCTX_ATR_SS_PCG_SHAPE_DIAMETER	"pcg_diameter"
#define VDCTX_ATR_SS_PCG_SHAPE_RADIUS	"pcg_radius"
#define VDCTX_ATR_SS_PCG_SHAPE_RAD_CORN	"pcg_radius_corner"
#define VDCTX_ATR_SS_PCG_SHAPE_WIDTH	"pcg_width"
#define VDCTX_ATR_SS_PCG_SHAPE_DEPTH	"pcg_depth"

#define VDCTX_ATR_AT_ST_STAGE        "node_stage"
#define VDCTX_ATR_AT_ST_NAME         "node_name"
#define VDCTX_ATR_AT_ST_PCMK         "pcmk"


/* -----------------------------------------------
 * The diff tree
 */
#define VDCTX_TREE_TYPE_SS_DIFFS "ss_diffs"
#define VDCTX_NODE_TYPE_SS_DIFF  "ss_diff"

#define VDCTX_ATR_SS_DIFF_NODE1  "ss_diff_node1"
#define VDCTX_ATR_SS_DIFF_NODE2  "ss_diff_node2"

#define VDCTX_ATR_SS_DIFF_TYPE    "ss_diff_type"
#define VDCTX_ATR_SS_DIFF_COMMENT "ss_diff_comment"

//Cleanup
#if defined(__cplusplus)
}
#endif

#endif
