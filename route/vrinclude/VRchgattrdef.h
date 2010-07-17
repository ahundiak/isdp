/* $Id: VRchgattrdef.h,v 1.2 2001/01/12 20:48:52 anand Exp $ */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vrinclude/VRchgattrdef.h
 *
 * Description:
 *
 * This file contains the definition of change attributes command
 *
 * Author	:	momo
 *
 * Creation:	september 30th, 1991
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VRchgattrdef.h,v $
 *      Revision 1.2  2001/01/12 20:48:52  anand
 *      SP merge
 *
 * Revision 1.2  2000/07/13  23:03:00  pinnacle
 * Replaced: route/vrinclude/VRchgattrdef.h for:  by apazhani for Service Pack
 *
 * Revision 1.1  2000/05/11  21:57:02  pinnacle
 * Created: route/vrinclude/VRchgattrdef.h by apazhani for Service Pack
 *
 *
 * Change History :

	  date	|  name	|	modification's description
	--------+-------+-----------------------------------
	19/08/94   MM	  Added TRAY_SHAPE gadget for modify Rway comp form.
	10/24/94  Lori    CR#179422038 Added spec to HVAC 
	12/22/97  Law     CR179309874 Added new RWAY shapes
	01/08/98  Law     CR179700399 Added Friction for HVAC
	06/24/98  Law     TR179801141 Added Vendor for RWAY
	07/25/98  LAW     CR179801144 Added tiers for raceway
	Apr 26 99 Anand   CR 179900491 Modified gadget ids for new form
    03/20/00  law     TR179901167 delete fields for transitions
    05/10/00  Alwin   CR179901312 Added field's for Acoustic Insulation 
    07/13/00  Alwin   CR179901661 Added field's for ACST

 *********************************************************************/

#ifndef	vr_VRchgattrdef_include

#define vr_VRchgattrdef_include


/* variable needed to allocate values and names attributes buffers */
#define VR_MAX_CHAR		80

/* variables needed to manipulate collections */
#define VR_ADD_PARAM            2
#define VR_MOD_PARAM            3
#define VR_ADD_OR_MOD_PARAM     4

#define VR_SYSTEM_ATTR		0x0001
#define VR_USER_ATTR		0x0010
#define VR_MISSING_ATTR  	0x0003
#define VR_DB_ATTR     		0x0004
#define VR_ATTRIBUTE_NE		0x0005

/* CR179700399 */
/* shape codes from VRdef.h needed for VRsizcomp.c */
#define         VR_RECT_S       0x0000  /* */
#define         VR_OVAL_S       0x0001  /* */
#define         VR_CIRC_S       0x0002  /* */
#define         VR_CORNER_S     0x0003  /* */

/* variable needed for user forms manipulations */
#define	USER_ATTR_FLD			12

/* variable needed for PIPING forms manipulations */
#define	USER_ATTR_BUTTON		17

#define	PIPING_MAT_CLASS		12
#define NOM_PIPE_DIAM			13
#define	LINE_SEQ_NO			14 
#define	FLUID_CODE			15
#define	OP_NORMAL_TEMP			16
#define	OP_NORMAL_PRES			18
#define	MOD_USER_ATTR_BUTTON0		19
#define	BLOCK_NO			21
#define	INSULATION_THICKNESS		25
#define	DES_NORMAL_TEMP			26
#define	DES_NORMAL_PRES			22
#define LINE_ID				24
#define	APPROVAL_STATUS			29
#define	CONSTRUC_STATUS			28
#define	LOAD_COMPONENT			43
#define HEAT_TRACING			47
#define	INSULATION_TYPE			55
#define	MOD_LOAD_COMPONENT		63
#define	PID_SCALE			930
#define	PID_SCALE_LABEL			130

#define SYMB_PIPING_MAT_CLASS		44
#define SYMB_NOM_PIPE_DIAM		45
#define SYMB_LINE_SEQ_NO		20
#define SYMB_FLUID_CODE			39
#define SYMB_HEAT_TRACING		37
#define SYMB_INSULATION_THICKNESS	40
#define SYMB_INSULATION_TYPE		31
#define SYMB_BLOCK_NO			62
#define SYMB_OP_NORMAL_TEMP		27
#define SYMB_OP_NORMAL_PRES		30
#define SYMB_DES_NORMAL_TEMP		48
#define SYMB_DES_NORMAL_PRES		50
#define SYMB_APPROVAL_STATUS		36
#define SYMB_CONSTRUC_STATUS		23
#define SYMB_PID_SCALE			830
#define SYMB_ACST			146

/* variable needed for HVAC and RACEWAY forms manipulations */
#define		ACST			148
#define		MESSAGE			10
#define		GAP			13
#define		ELLP_SHAPE		85  /*  Elliptical Shape  */
#define		CIRCULAR_SHAPE		17
#define		RECTANGULAR_SHAPE	18
#define		OVAL_SHAPE		19
#define		RADIUS_SHAPE		123
#define		LOAD_BUTTON		20
#define		W_SIZE			22
#define		D_SIZE			23
#define		RW_D_SIZE_DGTEXT	88 /*CR179801144*/
#define		RW_D_SIZE_DGTX_IN	35 /*CR179801144*/
#define		RW_D_SIZE_DGTX_MM	26 /*CR179801144*/
#define         RW_W_SIZE_DGTEXT        90 /*TR179801167*/
#define         RW_W_SIZE_DGTX_IN       34 /*TR179801167*/
#define         RW_W_SIZE_DGTX_MM       27 /*TR179801167*/
#define         HV_W_SIZE_DGTEXT        60 /*TR179801167*/
#define         HV_W_SIZE_DGTX_IN       113 /*TR179801167*/
#define         HV_W_SIZE_DGTX_MM       101 /*TR179801167*/
#define         HV_D_SIZE_DGTEXT        61 /*TR179801167*/
#define         HV_D_SIZE_DGTX_IN       112 /*TR179801167*/
#define         HV_D_SIZE_DGTX_MM       102 /*TR179801167*/
#define		MAX_FIELD		25
#define		LINE_NUMBER		41
#define		PRESS_CLASS		42
#define		HVAC_MAT_CLASS		122
#define		RWAY_VNDR_CODE		122 /* TR179801141-add to rway form */
#define		SERVICE			43
#define		SIZE_METHOD		44
#define		AIR_FLOW    		45
#define		MAX_VELOCITY		46
#define		EQUIV_DIAM  		47
#define		MAX_WIDTH		48
#define		DUCT_MATER		49
#define		DUCT_THICK		50
#define		INSULA_MATER		51
#define		INSULA_THICK		36

/* added for Acoustical Insulation. CR179901312 */
#define		ACOUSTIC_MATERIAL	120
#define		ACOUSTIC_THICK		121

#define		THROAT_RADIUS		39
#define		TRANS_LENGTH		40
#define		SYSTEM			56
#define		ZONE			57
#define		CONST_STATUS		58
#define		APPROVAL_STAT		59
#define		MOD_LOAD_BUTTON		67
#define 	MOD_USER_ATTR_BUTTON1   83
#define		CORNER_RADIUS		117
#define		CORNER_RADIUS_LBL       118
#define		SIZE_COMP_METHOD        132  /* CR179700399 */
#define		FRICTION                133  /* CR179700399 */
/* Tier added for CR179801144 */
#define		N_TIER_DG		716
#define		RW_SP_TIER_TEXT		87
#define		RW_SP_TIER_TX_IN	95
#define		RW_SP_TIER_TX_MM	94
#define		RW_N_TIER_TEXT		91
#define		SP_TIER_DG		714

#define SYMB_SHAPE			12
#define SYMB_LINE_NUMBER		16
#define SYMB_PRESS_CLASS	       131
#define SYMB_SERVICE			63
#define SYMB_SIZE_METHOD		64
#define SYMB_AIR_FLOW			65
#define SYMB_MAX_VELOCITY		66
#define SYMB_MAX_WIDTH			68
#define SYMB_DUCT_MATER			69
#define SYMB_DUCT_THICK			70
#define SYMB_INSULA_MATER		71
#define SYMB_INSULA_THICK		72

/* added for Acoustical Insulation. CR179901312 */
#define	SYMB_ACOUSTIC_MATERIAL	141
#define SYMB_ACOUSTIC_THICK		143

#define SYMB_CONST_STATUS		73
#define SYMB_APPROVAL_STAT		74
#define SYMB_W_SIZE			75
#define SYMB_D_SIZE			76
#define SYMB_THROAT_RADIUS		77
#define SYMB_TRANS_LENGTH		78
#define SYMB_GAP			79
#define SYMB_SYSTEM			80
#define SYMB_ZONE			81
#define SYMB_CORNER_RADIUS		124
#define SYMB_HVAC_MAT_CLASS             129
#define SYMB_RWAY_VNDR_CODE             129 /* TR179801141 */
#define SYMB_FRICTION                   135 /* CR179700399 */
#define	SYMB_N_TIER_DG			82  /* CR179801144 */
#define	SYMB_SP_TIER_DG			86  /* CR179801144 */

/*C new defines	*/
#define SYMB_SYSTEM_NAME		814
#define SYSTEM_NAME			914
#define SYMB_UNIT_NUMBER		825
#define UNIT_NUMBER			925

#endif
