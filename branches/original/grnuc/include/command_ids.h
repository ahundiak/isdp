




 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                                < 1988 >

              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.


                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.


              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201

 */

/* command_ids.h */

#ifndef COMMAND_IDS_DOT_H
#define COMMAND_IDS_DOT_H

/* ------- metafile command types and subtypes for EMS plotting */

#define SETUP_COMMAND  0
#define   SET_COLOR_TABLE_RGB		0
#define   SET_LINE_STYLE_TABLE		1
#define   CREATE_A_FONT			2
#define   READ_A_FONT			3
#define   START_NEW_PAGE		4
#define   SET_TRANSLUCENCY_GRID		5
#define   SET_DEPTH_CUE_INTENSITIES	6
#define   SET_LIGHT_SOURCE_DIRECTION	7
#define   SET_POINT_LIGHT_SOURCE	8
#define   DEFINE_BINARY_FILL_PATTERN	9
#define   SET_CHARACTER_CODE_MAPPING	10
#define   SET_VIEW_ORIENTATION_RANGE	11
#define   CREATE_A_FONT_FROM_TEMP_FILE	12

#define SEGMENT_DEFINITION_COMMAND  1
#define   BEGIN_DRAW_PRIMITIVE_SEGMENT	0
#define   END_DRAW_PRIMITIVE_SEGMENT	1

#define BASIC_ATTR_COMMAND  2
#define   SET_ACTIVE_FG_COLOR_INDEX	0
#define   SET_ACTIVE_BG_COLOR_INDEX	1
#define   SET_ACTIVE_TSP_COLOR_INDEX	2
#define   SET_ACTIVE_PB_COLOR_INDEX	3
#define   SET_ACTIVE_FG_COLOR		4
#define   SET_ACTIVE_BG_COLOR		5
#define   SET_ACTIVE_TSP_COLOR		6
#define   SET_ACTIVE_PB_COLOR		7
#define   SET_ACTIVE_LINE_STYLE		8
#define   SET_ACTIVE_LINE_WIDTH		9
#define   SET_ACTIVE_TEXT_SPACING	10
#define   SET_ACTIVE_POLY_FILL_MODE	11
#define   SET_ACTIVE_POLY_FILL_PATTERN	12
#define   SET_ACTIVE_RENDERING_MODE	13
#define   SET_ACTIVE_TRANSLUCENCY	14
#define   SET_ACTIVE_BORDER_STYLE	15
#define   SET_ACTIVE_BORDER_WIDTH	16
#define   SET_ACTIVE_RASTER_ORIENTATION	17
#define   SET_ACTIVE_FONT_NUMBER	18
#define   SET_ACTIVE_VIEW_NUMBER	19
#define   SET_ACTIVE_TEXT_JUSTIFICATION	20
#define   SET_ACTIVE_ROTATION_MATRIX	21

#define STACK_ATTR_COMMAND  3
#define   PUSH_ACTIVE_TRANS_MATRIX	0
#define   POP_ACTIVE_TRANS_MATRIX	1
#define   PUSH_ACTIVE_CLIP_ELEMENTS	2
#define   POP_ACTIVE_CLIP_ELEMENTS	3

#define DRAW_PRIMITIVE_COMMAND  4
#define   DRAW_LINE_STRING			0
#define   DRAW_POLYGON				1
#define   DRAW_NURB_CURVE			2
#define   DRAW_DEPENDENT_TEXT_STRING		3
#define   DRAW_ABBR_DEPENDENT_TEXT_STRING	4
#define   DRAW_RASTER_IMAGE			5
#define   DRAW_NURB_SURFACE			6
#define   DRAW_PRIMITIVE_SEGMENT		7
#define   DRAW_SCALE_INDEPENDENT_TEXT_STRING	8

#define DRAW_RECTANGULAR_PRIMITIVE_COMMAND  5
#define   DRAW_RECTANGLE		0
#define   DRAW_ELLIPSE			1
#define   DRAW_ARC			2
#define   DRAW_WEDGE			3

#define APPL_SPECIFIC_COMMAND  6
#define   DRAW_REFERENCE_FILE		0

#define DRAW_PRIMITIVE_COMMAND_WITH_RANGE  7
#define   DRAW_NURB_CURVE_WITH_RANGE		0
#define   DRAW_NURB_SURFACE_WITH_RANGE		1
#define   DRAW_DEPENDENT_TEXT_STRING_WITH_RANGE	2

#endif
