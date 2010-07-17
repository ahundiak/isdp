
/*************************************************************************
 * I/LOFT
 *
 * File:        include/vlunfold.h
 *
 * Description: 'Modify Unwrap Extraction' Command Object.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vlunfold.h,v $
 *      Revision 1.2  2001/01/16 18:16:17  ramarao
 *      *** empty log message ***
 *
 * Revision 1.1  2000/09/13  20:16:50  pinnacle
 * Created: loft/include/vlunfold.h by rchennup for Service Pack
 *
 * Revision 1.4  2000/02/07  15:45:00  pinnacle
 * (No comment)
 *
 * Revision 1.2  1999/06/01  15:56:16  pinnacle
 * (No comment)
 *
 * Revision 1.1  1998/04/30  10:32:50  pinnacle
 * LOFT 2.5.1
 *
 * Revision 1.2  1998/04/23  05:53:00  pinnacle
 * Replaced: include/vlunfold.h for:  by smpathak for loft
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      04/23/98   Sandeep      Header creation
 *      04/23/98   Sandeep      Modification for Form Interface
 *************************************************************************/

#ifndef	vlunwrap_include
#define	vlunwrap_include

#define MAX_CHAR_TF 20
#define plug_generic    0x00100000

/* Macro <unwrap> generic data */
#define	MACRO_UNWRAP	"srf_unwrap"
#define	UNFOLD_NB_TEMP	208
#define	UNFOLD_NB_FTEMP	3
#define	UNFOLD_NB_FEET	203

/* Macro <unwrap> templates name */
#define	UNFOLD_NAM_CS	 	"ref"
#define	UNFOLD_NAM_SURF	 	"BaseSurface"
#define	UNFOLD_NAM_BOX		"Box"
#define	UNFOLD_NAM_ATTR		"attr"

/* Macro <unwrap> templates index */
#define	UNFOLD_IDX_CS	 	0
#define	UNFOLD_IDX_SURF	 	1
#define	UNFOLD_IDX_BOX	        2
#define	UNFOLD_IDX_ATTR		3

/* Macro <unwrap> feet name */
#define	UNFOLD_NAM_UNWSRF	"UnwrapedSrf"
#define	UNFOLD_NAM_MINREC	"MinRec"
#define	UNFOLD_NAM_BOX		"Box"
#define	UNFOLD_NAM_TEXTSIZE	"TextSize"
#define	UNFOLD_NAM_NAME		"Name"
#define	UNFOLD_NAM_ORIENTATION	"Orientation"
#define	UNFOLD_NAM_TYPE		"Type"
#define	UNFOLD_NAM_UVSRF	"uvSrfId"
#define	UNFOLD_NAM_EDGE		"edge"

/* Macro <unwrap> feet index */
#define	UNFOLD_IDX_UNWSRF	0
#define	UNFOLD_IDX_MINREC	1
#define	UNFOLD_IDX_BOX		2
#define	UNFOLD_IDX_TEXTSIZE	3
#define	UNFOLD_IDX_NAME		4
#define	UNFOLD_IDX_ORIENTATION	5
#define	UNFOLD_IDX_TYPE		6
#define	UNFOLD_IDX_UVSRF	7
#define	UNFOLD_IDX_EDGE		8


/* --- attributes stored in attribute box --- */
#define UNFOLD_ATT_SRFWANTED   "UnwSrfWanted"
#define UNFOLD_ATT_EXPTYPE     "Expansion Type"
#define UNFOLD_ATT_TESSELATION "Tesselation"
#define	UNFOLD_ATT_FIB_RATIO   "FiberRatio"
#define	UNFOLD_ATT_X_EXPANSION "ScaleFactorInX"
#define	UNFOLD_ATT_Y_EXPANSION "ScaleFactorInY"
#define UNFOLD_ATT_LINES       "Lines To Unwrap"
#define UNFOLD_ATT_WATONPLATE  "Water line on plate only"
#define UNFOLD_ATT_SIDE        "Side to Unwrap"
#define UNFOLD_ATT_UNWOPT	"UnwrapOption"

#define UNFOLD_ATT_IDX_FIB_RATIO   0
#define UNFOLD_ATT_IDX_X_EXPANSION 1
#define UNFOLD_ATT_IDX_Y_EXPANSION 2
#define UNFOLD_ATT_IDX_SRFWANTED   3
#define UNFOLD_ATT_IDX_EXPTYPE     4
#define UNFOLD_ATT_IDX_TESSELATION 5
#define UNFOLD_ATT_IDX_LINES       6
#define UNFOLD_ATT_IDX_WATONPLATE  7
#define UNFOLD_ATT_IDX_SIDE        8
#define UNFOLD_ATT_IDX_UNWOPT	   9

#define UNFOLD_ATT_IDX_MARK	   0
#define UNFOLD_ATT_IDX_ROL	   1
#define UNFOLD_ATT_IDX_CTRL	   2
#define UNFOLD_ATT_IDX_TRACE	   3
#define UNFOLD_ATT_IDX_WATER	   4
#define UNFOLD_ATT_IDX_BUTT	   5
#define UNFOLD_ATT_IDX_SEAM	   6
#define UNFOLD_ATT_IDX_DISMIN      7
#define UNFOLD_ATT_IDX_FAR         8

#define UNFOLD_NB_OPT              10
#define UNFOLD_NB_OPTLINE          9

/************ defines for the unwrapped surface orientation problem *********/
#define VL_NOTHING      0
#define VL_MIDDEL       1
#define VL_PORT         2
#define VL_STARBOARD    3

#define VL_LEFT         1
#define VL_BOTTOM       2
#define VL_RIGHT        3
#define VL_TOP          4

#define VL_HORZ         0
#define VL_TRANS        1
#define VL_LONG         2
/***************************************************************************/
/* The arrows size in the orientation macros */
#define VL_ARROW_SIZE   100

// Plate expansion type 
#define NO_EXPANSION		0
#define GLOBAL_LW_RATIO		1
#define BY_STIFFNERS		2

// Side to Unwrap
#define BASE_SIDE		0
#define OFFSET_SIDE		1
#define BASE_FLIP		2
#define OFFSET_FLIP		3
#define MAX_MARK		2


// Tesselation Type
#define PARAMETRIC		0
#define ARC_LENGTH		1

#define GREATER_MAX_EDGE_ALLOWED        2  


/* ****************************************************************** */
/* #define  for the gadget form in the place unwrap command */
#define G_UNW_SURF		20
#define G_FIBER_RATIO		28
#define G_EXP_TYPE		14
#define G_EXP_X_SCALE		29
#define G_EXP_Y_SCALE		25
#define G_EXP_X_TEXT		24
#define G_EXP_Y_TEXT		30
#define G_EXP_X_UNIT_mm		32
#define G_EXP_Y_UNIT_mm		33
#define G_EXP_X_UNIT_in		34
#define G_EXP_Y_UNIT_in		35
#define G_EXP_X_PCENT		26
#define G_EXP_Y_PCENT		31
#define G_TESSELATION		19
#define G_LINES	        	12
#define G_WATONPLATE    	17
#define G_SIDE          	18
#define G_DISMIN        	26
#define G_FAR           	22
#define G_UNWOPT		36
#define FI_MSG_FIELD    	16

/* #define  for the gadget form in the modify unwrap command */
#define G_MD_UNW_SURF		20
#define G_MD_FIBER_RATIO	28
#define G_MD_EXP_TYPE		14
#define G_MD_EXP_X_SCALE	29
#define G_MD_EXP_Y_SCALE	25
#define G_MD_EXP_X_TEXT		24
#define G_MD_EXP_Y_TEXT		30
#define G_MD_TESSELATION	19
#define G_MD_LINES	        12
#define G_MD_WATONPLATE	        21
#define G_MD_LOCATE 	        18
#define G_MD_SIDE               17
#define G_MD_DISMIN             26
#define G_MD_FAR		27
#define FI_MD_MSG_FIELD         16

#endif
