/* $Id: form_env.h,v 1.2 2001/10/17 20:40:06 hans Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:    vdannot/dim/form_env.h
 *
 * Description:
 *	This file was copied from $GRNUC/include. Modified to add two #define
 *	CHAR_SPACING and LINE_SPACING. We can't add these modification in GRNUC
 *	that trigger lot of compilation. So moving this file locally would solve
 *	the problem. CR179901516
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: form_env.h,v $
 *  Revision 1.2  2001/10/17 20:40:06  hans
 *  Modifications for CR# MP5368
 *
 *  Revision 1.1  2001/01/19 23:19:30  jayadev
 *  *** empty log message ***
 *
 * Revision 1.1  2000/05/08  15:41:32  pinnacle
 * Created: vds/vdannot/dim/form_env.h by apazhani for Service Pack
 *
 *
 * History:
 *	MM/DD/YYYY	AUTHOR	DESCRIPTION
 *	05/05/00	Alwin	Created this file for VDS locally in this directory.
 *				Later might be moved to appropriate location.
 *	10/16/2001	HF	Modifications for CR# MP5368
 *
 *************************************************************************/

#define GAD_CHECK		  1
#define GAD_RESTORE		  5
#define GAD_TITLE		 11
#define GAD_EDIT_TITLE		 12
#define GAD_DIM_STAN		 22
#define GAD_DUAL_MODE		 23
#define GAD_TXT_HEIG		 36
#define GAD_TXT_FONT		 38
#define GAD_SEC_UNIT		 42
#define GAD_DIM_LAYR		 68

#define GAD_CHAR_SPACING	 72  /* added by Alwin for CR179901516 */
#define GAD_LINE_SPACING	 74  /* added by Alwin for CR179901516 */

#define GAD_TERM_UNI_BI		 76  /* HF: 10/12/2001 CR# MP5368 */
#define SYM_TERM_BI_ON		112  /* HF: 10/12/2001 CR# MP5368 */
#define SYM_TERM_BI_OFF		113  /* HF: 10/12/2001 CR# MP5368 */
#define SYM_TERM_UNI_ON		130  /* HF: 10/12/2001 CR# MP5368 */
#define SYM_TERM_UNI_OFF	131  /* HF: 10/12/2001 CR# MP5368 */

#define GAD_DELIMITER		 79
#define GAD_LIN_OFFS		 83
#define GAD_TER_TYPE		 57
#define GAD_SYM_POSN		 95
#define GAD_PROJ_OFFS		 96
#define GAD_TXT_YOFF		105
#define GAD_TXT_WEIG		107
#define GAD_DIM_GAP2		112
#define GAD_PROJ_EXTN		114
#define GAD_TOL_WEIG		116
#define GAD_DIM_WEIG		120
#define GAD_TOL_SIZE		123
#define GAD_ASP_RATI		138
#define GAD_LEADING		139
#define GAD_TRAILING	 	 85
#define GAD_TER_LIMIT		153
#define GAD_COMM_ORIG		182
#define GAD_COMM_ORIG_DOT	59
#define GAD_COMM_ORIG_CIRCLE	61
#define GAD_COMM_ORIG_NONE	66
#define GAD_TER_SELECT		184
#define GAD_LIN_DISP		187

#define GAD_HOLLOW_ARROW	20
#define GAD_FILLED_ARROW	18
#define GAD_OPEN_ARROW		16
#define GAD_SLASH		15
#define GAD_BACK_SLASH		12
#define GAD_BLANK		21
#define GAD_DOT			13
#define GAD_CIRCLE		17

#define GAP_TXT_CLEARANCE	-1
#define GAP_PRE_SUFF		-2
#define GAP_SYMBOL		-3
#define GAP_DUAL_DIM		-4
#define GAP_TOL_HOR		-5
#define GAP_TOL_VER		-6
#define GAP_VER_LIMI		-7
#define GAP_BOX_HOR		-8
#define GAP_BOX_VER		-9

#define SUPER_USER		-100

#define KEY_POSS_VALUES		1
#define KEY_ACT_VALUES		2
#define KEY_TXT_WIDT		3
#define KEY_FRAC_FONT		4
#define KEY_TER_TYPE0		5
#define KEY_PRI_TOLE_SYM	6
#define KEY_SEC_TOLE_SYM	7
#define KEY_TER_DISP		8
#define KEY_PRI_TOLE_UP		9
#define KEY_PRI_TOLE_LOW	10
#define KEY_SEC_TOLE_UP		11
#define KEY_SEC_TOLE_LOW	12
#define KEY_PRI_LEADING 	13
#define KEY_PRI_TRAILING 	14
#define KEY_SEC_LEADING 	15
#define KEY_SEC_TRAILING 	16
#define KEY_PRI_UNITS		17
#define KEY_SEC_UNITS		18
#define KEY_PRI_LABEL		19
#define KEY_PRI_SUB_LABEL	20
#define KEY_SEC_LABEL		21
#define KEY_SEC_SUB_LABEL	22
#define KEY_BLN_TYPE		23
#define KEY_BLN_SIZE		24
#define KEY_NUM_SIDES		25
#define KEY_ANNOT_POSN		26
#define KEY_ANNOT_ORIE		27
#define KEY_CTXT_POSN		28
#define KEY_DATUM_TERM		29
#define KEY_CAR_SPAC		30
#define KEY_LIN_SPAC		31
#define KEY_DIM_DISP		32
#define KEY_VIEW_ANG		33
#define KEY_REF_TYPE		35
#define KEY_TERM_SIZE		36
#define KEY_AUT_SUPPRESS	37
#define KEY_PROJ_METHOD		221
#define KEY_ANSI_WELD		222
#define KEY_DASH_LINE		223

#define LAB_STANDARD		30
#define LAB_LABEL		28
#define LAB_SUB_LABEL		42
#define GAD_LABEL		40
#define GAD_SUB_LABEL		45
#define LAB_MAX_SUB		27
#define GAD_MAX_SUB		46

#define LAB_MODL_LINE		41
#define LAB_DRVG_COLR		47
#define GAD_DRVG_COLR		55
#define LAB_DRVN_COLR		48
#define LAB_DIM_COLR		18
#define GAD_DIM_COLR		56
#define LAB_DET_COLR		51
#define GAD_DET_COLR		34
#define GAD_DIM_MODE		37

#define GAD_ANG_UNITS		25
#define LAB_ANG_UNITS		13

#define GAD_UNIT_SEL		151
#define GAD_UNITS		24
#define LAB_PRIMARY		17

#define UNIT_SEL_PRIMARY	1
#define TOLE_DSP_PRIMARY	0
