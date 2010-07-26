/*
 *  This file contains the #defines needed by the set of
 *  "Show Element" forms.  There are different categories
 *  of #defines.  Each category is separated by a comment
 *  describing its purpose.
 */

/*
 *  label names for each gadget
 *  on the main form
 */

#define		MAIN_FILE_NAME			26
#define		MAIN_ELEMENT_NAME		27
#define 	MAIN_ELEMENT_TYPE		28
#define		MAIN_LAYER_NUM			23
#define		MAIN_LAYER_NAME			18
#define		MAIN_COLOR_NUM			12
#define		MAIN_COLOR_NAME			13
#define		MAIN_WEIGHT			14
#define		MAIN_STYLE			16
#define		MAIN_MORE_INFO			30
#define		MAIN_DISMISS_BUTTON		1
#define		MAIN_HELP_BUTTON		3

/*
 * Gadget id for geometry symbols placed on forms
 */
#define     GEOM_SYMBOL         11

/*
 * label names for each gadget
 * on the linear geometry subform
 */

#define		LINEAR_GEOM_SF_NUM_VERTICES	15
#define		LINEAR_GEOM_SF_CS_NAME		16
#define		LINEAR_GEOM_SF_UNIT1		18
#define		LINEAR_GEOM_SF_UNIT2		19
#define		LINEAR_GEOM_SF_UNIT3		20
#define		LINEAR_GEOM_SF_NUM_LABEL	21
#define		LINEAR_GEOM_SF_COOR1_LABEL	22
#define		LINEAR_GEOM_SF_COOR2_LABEL	23
#define		LINEAR_GEOM_SF_COOR3_LABEL	24
#define		LINEAR_GEOM_SF_COORDINATES	25

/*
 * Symbol indices for linear geometry icons.
 */
#define		LINEAR_GEOM_SF_POINT		2
#define		LINEAR_GEOM_SF_LINESEG		3
#define		LINEAR_GEOM_SF_LINESTR		4
#define		LINEAR_GEOM_SF_PLLNSTR		5
#define		LINEAR_GEOM_SF_ORLNSTR		6
#define		LINEAR_GEOM_SF_POLYGON		7
#define		LINEAR_GEOM_SF_ORTHPG		8
#define		LINEAR_GEOM_SF_BOTH_INFLINE	9
#define		LINEAR_GEOM_SF_END_INFLINE	10
#define		LINEAR_GEOM_SF_BEG_INFLINE	11
#define		LINEAR_GEOM_SF_FENCE		23

/*
 *  label names for each gadget on the GREllArcGeom subform.
 *  This form is used for ellipse and elliptical arc.
 *  ELL_ARC_KEYPTS_ORIGIN field is used as ORIGIN field
 *  for ellipse and keypoints field for elliptical arc. If used 
 *  for ellipse gadget # 25 (END PT 1)
 *  and gadget # 26 (END PT 2) are turned off.
 *  If ellipse SYM_PERIMETER and SYM_AREA are on and
 *  SYM_SWEEP_ANGLE and SYM_ARC_LENGTH are off. If
 *  elliptical arc opposite.
 */
  
#define		ELL_ARC_GEOM_SF_MAJ_AXIS	29
#define		ELL_ARC_GEOM_SF_MIN_AXIS	31
#define		ELL_ARC_GEOM_SF_ASPECT_RATIO    33
#define		ELL_ARC_GEOM_SF_APP_ROT_ANGLE	35
#define		ELL_ARC_SWEEP_ANGLE_PERIMETER	12
#define     ELL_ARC_SYM_SWEEP_ANGLE         36
#define		ELL_ARC_SYM_PERIMETER	        37
#define		ELL_ARC_ARC_LENGTH_AREA  	14
#define     ELL_ARC_SYM_ARC_LENGTH      13
#define		ELL_ARC_SYM_AREA		    38
#define		ELL_ARC_GEOM_SF_CS_NAME		16
#define		ELL_ARC_GEOM_SF_UNIT1		18
#define		ELL_ARC_GEOM_SF_UNIT2		19
#define		ELL_ARC_GEOM_SF_UNIT3		20
#define		ELL_ARC_GEOM_SF_COOR1_LABEL	21
#define		ELL_ARC_GEOM_SF_COOR2_LABEL	22
#define		ELL_ARC_GEOM_SF_COOR3_LABEL	23
#define		ELL_ARC_KEYPTS_ORIGIN		27
#define     ELL_ARC_SYM_END_PT_1        25
#define     ELL_ARC_SYM_END_PT_2        26

/*
 *  label names for each gadget on the GRCirArcGeom subform.
 *  This form is used for circle and circular arc.
 *  CIR_ARC_KEYPTS_ORIGIN field is used as ORIGIN field
 *  for circle and keypoints field for circular arc. If used
 *  for circle gadget # 21 (END PT 1)
 *  and gadget # 22 (END PT 2) are turned off.
 *  If circle SYM_CIRCUMFERENCE and SYM_AREA are on and
 *  SYM_SWEEP_ANGLE and SYM_ARC_LENGTH are off. If
 *  circular arc opposite.
 */

#define		CIR_ARC_GEOM_SF_DIAMETER	    25
#define		CIR_ARC_GEOM_SF_RADIUS		    27
#define		CIR_ARC_SWEEP_ANGLE_CIRCUMFERENCE   29
#define     CIR_ARC_SYM_SWEEP_ANGLE     28
#define     CIR_ARC_SYM_CIRCUMFERENCE   33
#define		CIR_ARC_ARC_LENGTH_AREA		31
#define     CIR_ARC_SYM_ARC_LENGTH      30
#define     CIR_ARC_SYM_AREA            34
#define		CIR_ARC_GEOM_SF_CS_NAME		12
#define		CIR_ARC_GEOM_SF_UNIT1		14
#define		CIR_ARC_GEOM_SF_UNIT2		15
#define		CIR_ARC_GEOM_SF_UNIT3		16
#define		CIR_ARC_GEOM_SF_COOR1_LABEL	17
#define		CIR_ARC_GEOM_SF_COOR2_LABEL	18
#define		CIR_ARC_GEOM_SF_COOR3_LABEL	19
#define		CIR_ARC_KEYPTS_ORIGIN		23
#define     CIR_ARC_SYM_END_PT_1        21
#define     CIR_ARC_SYM_END_PT_2        22

/*
 *  special fonts for the coordinate labels
 */

#define		THETA		128
#define		RHO		129
#define		PHI		130
#define		Rindex		131
#define		X		88
#define		Y		89
#define		Z		90

/*
 *  Indication that symbol to place on form is already
 *  there and displayed
 */
#define SYM_ON_FORM     -1

/* 
 *  fixed sizes for the form arrays for objects
 */

#define     GRLINEAR_FORM_FIXED_SIZE        8
#define     GRCIRCLE_FORM_FIXED_SIZE        12
#define     GRCIRARC_FORM_FIXED_SIZE        14
#define     GRELLIPSE_FORM_FIXED_SIZE       14
#define     GRELLARC_FORM_FIXED_SIZE        16

