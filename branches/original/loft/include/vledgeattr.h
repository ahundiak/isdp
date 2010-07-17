/* $Id: vledgeattr.h,v 1.1.1.1 2001/01/04 21:11:11 cvs Exp $ */

/***************************************************************************
 * I/LOFT
 *
 * File:        include/vledgeattr.h
 *
 * Description: definitions for edge attribute command
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vledgeattr.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:11:11  cvs
 *      Initial import to CVS
 *
 * Revision 1.3  1999/04/30  21:18:20  pinnacle
 * (No comment)
 *
 * Revision 1.2  1999/04/23  18:35:16  pinnacle
 * CR_179900195
 *
 *
 * History:
 * MM/DD/YY   AUTHOR  DESCRIPTION
 * 04/23/99   ejm     Increased ATT_NB_ATT from 17 to 30; added indices
 *		      ATT_DEL_THK, ATT_IDX_DTHK
 * 04/30/99   ejm     Set ATT_NB_ATT back to 17
 ***************************************************************************/

#define  MACRO_NAME    "edge_att"     /* Name of the macro              */

#define  NB_TEMPLATE   3            /* Number of template of the macro  */
#define  NB_FEET       3            /* Number of feet of the macro */
#define  NB_FEET_G     3            /* Number of graphic feet of the macro */
/*  #define  NB_FEET_V     1          Number of virtual feet of the macro */

/* Definition of the names of the objects of the macro                        */

#define SURF            "surf"          /* base surface */
#define EDGE_3D         "edge_3d"       /* current edge */
#define SMALL_EDGE      "small_edge"    /* small edge */
#define ATT_BOX         "box"           /* Type of edge */
#define ALLOW_IND       "allow_ind"

/* template's indexes */
#define ATT_T_IDX_SURF		0
#define ATT_T_IDX_EDGE_3D	1
#define ATT_T_IDX_BOX		2

/* feet's indexes */
#define ATT_F_IDX_EDGE_3D	0
#define ATT_F_IDX_SMALL_EDGE	1
#define ATT_F_IDX_ALLOW_IND     2

/*#define ATT_F_IDX_BOX		2*/

/* #define for the attributes in the rg_collection */
#define ATT_NB_ATT      17

#define ATT_L		"L"
#define ATT_S		"S"
#define ATT_A		"A"
#define ATT_TYPE_ANGLE	"TYPE_ANGLE"
#define ATT_TYPE_CHAMF	"TYPE_CHAMF"
#define ATT_B		"B"
#define ATT_V		"V"
#define ATT_Y		"Y"
#define ATT_X		"X"
#define ATT_H		"H"
#define ATT_C		"C"
#define ATT_N		"N"
#define ATT_T		"T"
#define ATT_ALLOWANCE	"ALLOWANCE"
#define ATT_PROCESS 	"PROCESS"
#define ATT_SPEC_NB 	"SPEC NUMBER"
#define ATT_TYPE 	"TYPE"
#define ATT_DEL_THK	"DTHK"

/* index of attributes */
#define ATT_IDX_L           0
#define ATT_IDX_S           1	
#define ATT_IDX_A           2
#define ATT_IDX_TYPE_ANGLE  3
#define ATT_IDX_TYPE_CHAMF  4
#define ATT_IDX_B	    5
#define ATT_IDX_V           6
#define ATT_IDX_Y	    7
#define ATT_IDX_X	    8
#define ATT_IDX_H           9
#define ATT_IDX_C	    10
#define ATT_IDX_N	    11
#define ATT_IDX_T           12
#define ATT_IDX_ALLOWANCE   13
#define ATT_IDX_PROCESS     14
#define ATT_IDX_SPEC_NB     15
#define ATT_IDX_TYPE   	    16
#define ATT_IDX_DTHK   	    20    /* matches vsedgeattr.h */
 
/* #define for the form's gadgets */

#define G_L 		128
#define G_S 		130
#define G_A 		131
#define G_TYPE_ANGLE 	138
#define G_TYPE_CHAMF 	127
#define G_B 		129
#define G_V 		143
#define G_Y 		133
#define G_X 		136
#define G_H 		132
#define G_C 		134
#define G_N 		135
#define G_T 		104
#define G_ALLOWANCE 	137
#define G_PROCESS 	95
#define G_SPEC_NB 	139
#define G_PL_EDGE	113
#define G_MOD_EDGE	96

#define G_FI_MSG_FIELD	9


#define DEFAULT_ANGLE   "R"

#define ATT_BASE_THIN    1  
#define ATT_OFFSET_THIN  2   
#define ATT_BASE_FAT     3
#define ATT_OFFSET_FAT   4
