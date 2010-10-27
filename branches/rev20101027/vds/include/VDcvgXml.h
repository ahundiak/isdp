/* $Id: VDcvgXml.h,v 1.4 2001/06/27 14:44:10 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDsvgXml.h
 *
 * Description:	CAD Vector Graphics XML Interface
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDcvgXml.h,v $
 *      Revision 1.4  2001/06/27 14:44:10  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/06/07 19:03:42  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/01/10 15:31:54  art
 *      ah
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  2000/04/25  16:02:42  pinnacle
 * ah
 *
 * Revision 1.1  2000/02/18  16:01:30  pinnacle
 * sms
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 01/29/00  ah      Creation
 * 01/09/01  ah      sp merge
 ***************************************************************************/
#ifndef VDcvgXml_include
#define VDcvgXml_include

/* ----------------------------------- */
/* XML defines for CVG                 */

/* A curve contains a list of vertexes */
#define XML_CVG_CURVE       "cvg:curve"

#define XML_CVG_CURVE_TYPE         "type"
#define XML_CVG_CURVE_TYPE_CIRCLE  "circle"
#define XML_CVG_CURVE_TYPE_ELLIPSE "ellipse"
#define XML_CVG_CURVE_TYPE_OVAL    "oval"

#define XML_CVG_CURVE_RADIUS   "rad"
#define XML_CVG_CURVE_CENTER_X "cenx"
#define XML_CVG_CURVE_CENTER_Y "ceny"
#define XML_CVG_CURVE_CENTER_Z "cenz"
#define XML_CVG_CURVE_MAJOR_X  "majx"
#define XML_CVG_CURVE_MAJOR_Y  "majy"
#define XML_CVG_CURVE_MAJOR_Z  "majz"
#define XML_CVG_CURVE_MINOR_X  "minx"
#define XML_CVG_CURVE_MINOR_Y  "miny"
#define XML_CVG_CURVE_MINOR_Z  "minz"

/* Vertexes are either lines or arcs   */
#define XML_CVG_VERTEX      "cvg:vertex"
#define XML_CVG_VERTEX_TYPE "type"

#define XML_CVG_VERTEX_TYPE_MOVE_TO "m"
#define XML_CVG_VERTEX_TYPE_LINE_TO "l"
#define XML_CVG_VERTEX_TYPE_CARC_TO "a"

/* End Point */
#define XML_CVG_VERTEX_EX "endx"
#define XML_CVG_VERTEX_EY "endy"

/* Mid Point */
#define XML_CVG_VERTEX_MX "midx"
#define XML_CVG_VERTEX_MY "midy"

/* Center Point */
#define XML_CVG_VERTEX_CX "cenx"
#define XML_CVG_VERTEX_CY "ceny"

#define XML_CVG_VERTEX_RADIUS    "rad"
#define XML_CVG_VERTEX_BULGE     "bulge"
#define XML_CVG_VERTEX_INC_ANGLE "inc_angle"

/* Range Points */
#define XML_CVG_RANGE    "cvg:range"
#define XML_CVG_RANGE_X1 "x1"
#define XML_CVG_RANGE_X2 "x2"
#define XML_CVG_RANGE_Y1 "y1"
#define XML_CVG_RANGE_Y2 "y2"
#define XML_CVG_RANGE_Z1 "z1"
#define XML_CVG_RANGE_Z2 "z2"

/* Point */
#define XML_CVG_POINT   "cvg:point"
#define XML_CVG_POINT_X "x"
#define XML_CVG_POINT_Y "y"
#define XML_CVG_POINT_Z "z"

/* Matrrix */
#define XML_CVG_MATRIX_4X4   "cvg:matrix_4x4"
#define XML_CVG_MATRIX_4X3   "cvg:matrix_4x3"
#define XML_CVG_MATRIX_3X3   "cvg:matrix_3x3"
#define XML_CVG_MATRIX_I00   "i00"
#define XML_CVG_MATRIX_I01   "i01"
#define XML_CVG_MATRIX_I02   "i02"
#define XML_CVG_MATRIX_I03   "i03"
#define XML_CVG_MATRIX_I10   "i10"
#define XML_CVG_MATRIX_I11   "i11"
#define XML_CVG_MATRIX_I12   "i12"
#define XML_CVG_MATRIX_I13   "i13"
#define XML_CVG_MATRIX_I20   "i20"
#define XML_CVG_MATRIX_I21   "i21"
#define XML_CVG_MATRIX_I22   "i22"
#define XML_CVG_MATRIX_I23   "i23"
#define XML_CVG_MATRIX_I30   "i30"
#define XML_CVG_MATRIX_I31   "i31"
#define XML_CVG_MATRIX_I32   "i32"
#define XML_CVG_MATRIX_I33   "i33"

/* Text Object */
#define XML_CVG_TEXT         "cvg:text"
#define XML_CVG_TEXT_X1      "x1"
#define XML_CVG_TEXT_Y1      "y1"
#define XML_CVG_TEXT_X2      "x2"
#define XML_CVG_TEXT_Y2      "y2"
#define XML_CVG_TEXT_VALUE   "string"
#define XML_CVG_TEXT_ANGLE   "rot_angle"
#define XML_CVG_TEXT_HEIGHT  "height"
#define XML_CVG_TEXT_WIDTH   "width"
#define XML_CVG_TEXT_FONT    "font"
#define XML_CVG_TEXT_JUST    "just"

#define XML_CVG_TEXT_JUST_UL "ul"
#define XML_CVG_TEXT_JUST_ML "ml"
#define XML_CVG_TEXT_JUST_LL "ll"

#define XML_CVG_TEXT_JUST_UM "um"
#define XML_CVG_TEXT_JUST_MM "mm"
#define XML_CVG_TEXT_JUST_LM "lm"

#define XML_CVG_TEXT_JUST_UR "ur"
#define XML_CVG_TEXT_JUST_MR "mr"
#define XML_CVG_TEXT_JUST_LR "lr"

#endif








