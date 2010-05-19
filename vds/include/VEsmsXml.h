/* $Id: VEsmsXml.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VEsmsXml.h
 *
 * Description:	Struct Manufacturing Solutions
 *              Contains the XML definations
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VEsmsXml.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  2000/03/24  15:44:46  pinnacle
 * ah
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/13/00  ah      Creation
 ***************************************************************************/
#ifndef VEsmsXml_include
#define VEsmsXml_include
 
/* ----------------------------------------------------
 * XML Interface
 */
 
/* SMS Stuff */
#define XML_SMS          "sms"
#define XML_SMS_DOC_TYPE "sms:sms"
#define XML_SMS_DTD      "sms.dtd"

/* Individual plates */
#define XML_SMS_PLATES                   "sms:plates"
#define XML_SMS_PLATE                    "sms:plate"

#define XML_SMS_PLATE_THICKNESS          "thickness"

#define XML_SMS_PLATE_NEAR_SIDE          "near_side"
#define XML_SMS_PLATE_NEAR_SIDE_MOLDED   "molded"
#define XML_SMS_PLATE_NEAR_SIDE_OFFSET   "offset"

#define XML_SMS_PLATE_MAX_MARKING        "max_marking"
#define XML_SMS_PLATE_MAX_MARKING_MOLDED "molded"
#define XML_SMS_PLATE_MAX_MARKING_OFFSET "offset"

/* Generic part (plate or profile) Information */
#define XML_SMS_PART_INFO                "sms:part_info"

#define XML_SMS_PART_INFO_PART_NUM       "part_num"
#define XML_SMS_PART_INFO_PART_NAME      "part_name"

#define XML_SMS_PART_INFO_MARKING_SIDE   "marking_side"
#define XML_SMS_PART_INFO_GRAIN          "grain"

#define XML_SMS_PART_INFO_MATERIAL_TYPE  "material_type"
#define XML_SMS_PART_INFO_MATERIAL_GRADE "material_grade"

#define XML_SMS_PART_INFO_PROD_TYPE        "prod_type"
#define XML_SMS_PART_INFO_PROD_TYPE_COLLAR "collar"

/* Assembly information */ 
#define XML_SMS_PROD_INFO          "sms:prod_info"
#define XML_SMS_PROD_INFO_HULL     "hull"
#define XML_SMS_PROD_INFO_BLOCK    "block"
#define XML_SMS_PROD_INFO_ASSEMBLY "assembly"
#define XML_SMS_PROD_INFO_PCMK     "piece_mark"
#define XML_SMS_PROD_INFO_QTY      "quantity"
#define XML_SMS_PROD_INFO_QTY_PORT "quantity_port"
#define XML_SMS_PROD_INFO_QTY_STBD "quantity_stbd"
#define XML_SMS_PROD_INFO_QTY_CL   "quantity_cl"
#define XML_SMS_PROD_INFO_SYMMETRY "symmetry"

/* Inner and outer contours */
#define XML_SMS_PLATE_CONTOUR  "sms:plate_contour"
#define XML_SMS_INNER_CONTOURS "sms:inner_contours"
#define XML_SMS_INNER_CONTOUR  "sms:inner_contour"

/* Edge Information */
#define XML_SMS_EDGE          "sms:edge"
#define XML_SMS_EDGE_TYPE     "type"
#define XML_SMS_EDGE_JOINT    "joint"

/* Bevel Information */
#define XML_SMS_BEVEL         "sms:bevel"
#define XML_SMS_BEVEL_TYPE    "type"
#define XML_SMS_BEVEL_PROCESS "process"
#define XML_SMS_BEVEL_THICK1  "thick1"
#define XML_SMS_BEVEL_THICK2  "thick2"
#define XML_SMS_BEVEL_STOCK   "stock"
#define XML_SMS_BEVEL_GAP     "gap"
#define XML_SMS_BEVEL_ANGLE_A "angle_a"
#define XML_SMS_BEVEL_ANGLE_B "angle_b"
#define XML_SMS_BEVEL_ANGLE_C "angle_c"
#define XML_SMS_BEVEL_ANGLE_D "angle_d"
#define XML_SMS_BEVEL_ANGLE_E "angle_e"
#define XML_SMS_BEVEL_SIZE_A  "size_a"
#define XML_SMS_BEVEL_SIZE_B  "size_b"
#define XML_SMS_BEVEL_SIZE_C  "size_c"
#define XML_SMS_BEVEL_SIZE_D  "size_d"
#define XML_SMS_BEVEL_SIZE_E  "size_e"

/* Mark Information */
#define XML_SMS_MARKING_PART_INFO           "sms:marking_part_info"
#define XML_SMS_MARKING_PART_INFO_MARKED_BY "marked_by"
#define XML_SMS_MARKING_PART_INFO_DECLIVITY "declivity"

/* Marking Line */
#define XML_SMS_MARKINGS             "sms:markings"
#define XML_SMS_MARKING              "sms:marking"

#define XML_SMS_MARKING_TYPE         "type"
#define XML_SMS_MARKING_TYPE_PART    "part"
#define XML_SMS_MARKING_TYPE_STOCK   "stock"
#define XML_SMS_MARKING_TYPE_DATUM   "datum"
#define XML_SMS_MARKING_TYPE_LABEL   "label"
#define XML_SMS_MARKING_TYPE_WATER   "water"
#define XML_SMS_MARKING_TYPE_ROLL    "roll"
#define XML_SMS_MARKING_TYPE_KNUCKLE "knuckle"
#define XML_SMS_MARKING_TYPE_TANGENT "tangent"

#define XML_SMS_MARKING_MARKED_SIDE      "marked_side"
#define XML_SMS_MARKING_MARKED_SIDE_FAR  "far"
#define XML_SMS_MARKING_MARKED_SIDE_NEAR "near"

/* ----------------------------------------------------
 * Special setup object for SPADES translator
 */
#define XML_PDF_SETUP                       "pdf:setup"
#define XML_PDF_SETUP_INTERNAL_UNITS        "internal_units"
#define XML_PDF_SETUP_INTERNAL_UNITS_METRIC "metric"

#define XML_PDF_SETUP_DATE                  "date"
#define XML_PDF_SETUP_PDF_NAME              "pdf_name"
#define XML_PDF_SETUP_FILE_NAME             "file_name"
#define XML_PDF_SETUP_PDM_CAT               "pdm_cat"
#define XML_PDF_SETUP_PDM_PART              "pdm_part"
#define XML_PDF_SETUP_PDM_REV               "pdm_rev"
#define XML_PDF_SETUP_PDM_STATUS            "pdm_status"

/* ----------------------------------------------------
 * Special ship object for SPADES translator
 */
#define XML_PDF_SHIP                       "pdf:ship"
#define XML_PDF_SHIP_NAME                  "name"
#define XML_PDF_SHIP_OWNER                 "owner"
#define XML_PDF_SHIP_HULL                  "hull"
#define XML_PDF_SHIP_HULL_APP              "hull_app"
#define XML_PDF_SHIP_DIMENSIONS            "dimensions"
#define XML_PDF_SHIP_GLOBAL_COORD_SYSTEM   "global_coord_system"
#define XML_PDF_SHIP_FWD_PERPENDICULAR     "fwd_perpendicular"

/* -----------------------------------------------------
 * Production tree for SPADES translator
 */
#define XML_PDF_TREE                       "pdf:tree"
#define XML_PDF_TREE_NAME                  "name"

#define XML_PDF_TREE_NODE                  "pdf:tree_node"
#define XML_PDF_TREE_NODE_TYPE             "type"
#define XML_PDF_TREE_NODE_NAME             "name"
#define XML_PDF_TREE_NODE_PCMK             "pcmk"
#define XML_PDF_TREE_NODE_STAGE            "stage"
#define XML_PDF_TREE_NODE_PARENT           "parent"
#define XML_PDF_TREE_NODE_PATH             "path"
#define XML_PDF_TREE_NODE_QTY              "qty"
#define XML_PDF_TREE_NODE_DESC             "desc"
#define XML_PDF_TREE_NODE_NOTES            "notes"
#define XML_PDF_TREE_NODE_PLATEN           "platen"
#define XML_PDF_TREE_NODE_SEQUENCE         "sequence"
#define XML_PDF_TREE_NODE_DESTINATION      "destination"

/* These are for additional part specific information */
#define XML_PDF_TREE_NODE_PART_TYPE       "part_type"
#define XML_PDF_TREE_NODE_PART_TYPE_PLATE "plate"
#define XML_PDF_TREE_NODE_PART_TYPE_BEAM  "beam"

#define XML_PDF_TREE_NODE_PART_FAMILY     "part_family"
#define XML_PDF_TREE_NODE_PART_NUM        "part_num"
#define XML_PDF_TREE_NODE_PART_MATERIAL   "part_material"
#define XML_PDF_TREE_NODE_PART_GRADE      "part_grade"
#define XML_PDF_TREE_NODE_PART_THICKNESS  "part_thickness"
#define XML_PDF_TREE_NODE_PART_OBJID      "part_objid"

/* -----------------------------------------------
 * 3d Plate info for spades translator
 * The object will contain 3 3d reference points as well
 */
#define XML_PDF_PLATE_3D                    "pdf:plate_3d"
#define XML_PDF_PLATE_3D_MATERIAL_DIRECTION "material_direction"
#define XML_PDF_PLATE_3D_EXPAND_MAJOR       "expand_major"
#define XML_PDF_PLATE_3D_EXPAND_MINOR       "expand_minor"

#endif




