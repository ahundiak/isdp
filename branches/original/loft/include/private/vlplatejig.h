#ifndef vlplate_jig_include
#define vlplate_jig_include

#include	"vltemplate.h"

/* ************************************************************************** */
/*			MACRO : PLATE-JIG MANAGER			      */
/* ************************************************************************** */

/* Macro <plate-jig manager> generic data */
#define	MACRO_PM_DEF	"platejig_mgr"		/* Macro definition name      */
#define	MACRO_PM_FTEMP	1			/* Number of fix templates    */
#define	MACRO_PM_VTEMP	300			/* Number of var templates    */
#define	MACRO_PM_FFEET	4			/* Number of fix feet	      */
#define	MACRO_PM_VFEET	100			/* Number of var feet         */
#define	MACRO_PM_NAME	"PlateJigMgr"		/* Macro occurence prefix     */
#define	NUM_PM_ATTR	17			/* Number of attributes	      */

/* Macro <plate-jig manager> templates names */
#define	NAM_PM_ATTR	NAM_TM_ATTR
#define	NAM_PM_VART	"plt|frm|lin"

/* Macro <plate-jig manager> templates indices */
#define	IDX_PM_ATTR	0

/* Macro <plate-jig manager> parameters names */
#define NAM_PM_GRD	NAM_TM_GRD
#define	NAM_PM_EXT1	"jig_ext1"
#define	NAM_PM_EXT2	"jig_ext2"
#define	NAM_PM_HOLE	"hole_radius"
#define	NAM_PM_INV	NAM_TM_INV
#define	NAM_PM_MID	NAM_TM_MID
#define	NAM_PM_TYPE	"jig_type"
#define	NAM_PM_OSET	"jig_offset"
#define	NAM_PM_SPAC	"jig_spacing"
#define	NAM_PM_NPLT	"plate_number"
#define	NAM_PM_NFRM	"frame_number"
#define	NAM_PM_CODE	"plane_code"
#define	NAM_PM_NLIN	"cline_number"
#define	NAM_PM_GROP	"grid_option"
#define	NAM_PM_STOP	"strip_option"
#define	NAM_PM_STWI	"strip_width"
#define NAM_PM_DIR	"jig_direction"

/* Macro <plate-jig manager> parameters indices */
#define IDX_PM_GRD	0
#define	IDX_PM_EXT1	1
#define	IDX_PM_EXT2	2
#define	IDX_PM_HOLE	3
#define	IDX_PM_INV	4
#define	IDX_PM_MID	5
#define	IDX_PM_TYPE	6
#define	IDX_PM_OSET	7
#define	IDX_PM_SPAC	8
#define	IDX_PM_NPLT	9
#define	IDX_PM_NFRM	10
#define	IDX_PM_CODE	11
#define	IDX_PM_NLIN	12
#define	IDX_PM_GROP	13
#define	IDX_PM_STOP	14
#define	IDX_PM_STWI	15
#define IDX_PM_DIR	16

/* Macro <plate-jig manager> feet names */
#define	NAM_PM_CTR1	"control_line1"
#define	NAM_PM_CTR2	"control_line2"
#define	NAM_PM_PPNT	"Ppoint"
#define	NAM_PM_REAL	NAM_TM_REAL
#define	NAM_PM_VARF	"PlateJig"

/* Macro <plate-jig manager> feet index */
#define	IDX_PM_CTR1	0
#define	IDX_PM_CTR2	1
#define	IDX_PM_PPNT	2
#define	IDX_PM_REAL	3


/* ************************************************************************** */
/*			MACRO : PLATE-JIG OBJECT			      */
/* ************************************************************************** */

/* Macro <plate-jig object> generic data */
#define	MACRO_PO_DEF	"platejig_obj"		/* Macro definition name      */
#define	MACRO_PO_FTEMP	4			/* Number of fix templates    */
#define	MACRO_PO_VTEMP	100			/* Number of var templates    */
#define	MACRO_PO_FFEET	5			/* Number of fix feet	      */
#define	MACRO_PO_VFEET	100			/* Number of var feet         */
#define	MACRO_PO_NAME	"PlateJigObj"		/* Macro occurence prefix     */
#define	NUM_PO_ATTR	19			/* Number of attributes	      */

/* Macro <plate-jig object> templates names */
#define	NAM_PO_ATTR	NAM_PM_ATTR
#define	NAM_PO_PLAN	"frame_plane"
#define	NAM_PO_CTRL	NAM_TO_CTRL
#define	NAM_PO_INDX	"platejig_name"
#define	NAM_PO_VART	"srf|lin"

/* Macro <plate-jig object> templates indices */
#define	IDX_PO_ATTR	0
#define	IDX_PO_PLAN	1
#define	IDX_PO_CTRL	2
#define	IDX_PO_INDX	3

/* Macro <plate-jig object> parameters names */
#define	NAM_PO_REAL	NAM_PM_REAL
#define	NAM_PO_EXT1	NAM_PM_EXT1
#define	NAM_PO_EXT2	NAM_PM_EXT2
#define	NAM_PO_HOLE	NAM_PM_HOLE
#define	NAM_PO_INV	NAM_PM_INV
#define	NAM_PO_MID	NAM_PM_MID
#define	NAM_PO_TYPE	NAM_PM_TYPE
#define	NAM_PO_OSET	NAM_PM_OSET
#define	NAM_PO_NSRF	"support_number"
#define	NAM_PO_NLIN	NAM_PM_NLIN
#define	NAM_PO_STOP	NAM_PM_STOP
#define	NAM_PO_STWI	NAM_PM_STWI
#define	NAM_PO_ORDR	"platejig_order"
#define	NAM_PO_XCOG	"x_cog"
#define	NAM_PO_YCOG	"y_cog"
#define	NAM_PO_ZCOG	"z_cog"
#define	NAM_PO_XNRM	"x_normal"
#define	NAM_PO_YNRM	"y_normal"
#define	NAM_PO_ZNRM	"z_normal"

/* Macro <plate-jig object> parameters indices */
#define	IDX_PO_REAL	0
#define	IDX_PO_EXT1	1
#define	IDX_PO_EXT2	2
#define	IDX_PO_HOLE	3
#define	IDX_PO_INV	4
#define	IDX_PO_MID	5
#define	IDX_PO_TYPE	6
#define	IDX_PO_OSET	7
#define	IDX_PO_NSRF	8
#define	IDX_PO_NLIN	9
#define	IDX_PO_STOP	10
#define	IDX_PO_STWI	11
#define	IDX_PO_ORDR	12
#define	IDX_PO_XCOG	13
#define	IDX_PO_YCOG	14
#define	IDX_PO_ZCOG	15
#define	IDX_PO_XNRM	16
#define	IDX_PO_YNRM	17
#define	IDX_PO_ZNRM	18

/* Macro <plate-jig object> feet names */
#define	NAM_PO_CONT	NAM_TO_CONT
#define	NAM_PO_NAME	NAM_PO_INDX
#define	NAM_PO_RESU	NAM_PO_ATTR
#define	NAM_PO_KLIN	"lk_line"
#define	NAM_PO_KTXT	"lk_text"
#define	NAM_PO_VARF	"weld|line"

/* Macro <plate-jig object> feet indices */
#define	IDX_PO_CONT	0
#define	IDX_PO_NAME	1
#define	IDX_PO_RESU	2
#define	IDX_PO_KLIN	3
#define	IDX_PO_KTXT	4

/* Macro <plate_jig object> attributes name */
#define	NAM_RG_P_INDEX	"index"
#define	NAM_RG_P_E_NUM	"e_num"
#define	NAM_RG_P_R_NUM	"r_num"
#define	NAM_RG_P_L_NUM	"l_num"
#define	NAM_RG_P_W_NUM	"w_num"
#define	NAM_RG_P_C_NUM	"c_num"

/* Macro <plate_jig object> attributes index */
#define	IDX_RG_P_INDEX	0
#define	IDX_RG_P_E_NUM	1
#define	IDX_RG_P_R_NUM	2
#define	IDX_RG_P_L_NUM	3
#define	IDX_RG_P_W_NUM	4
#define	IDX_RG_P_C_NUM	5
#define	IDX_RG_P_VALUE	6

/* Macro <plate_jig object> attributes suffix */
#define	NAM_RG_P_E_XPT	"xe"
#define	NAM_RG_P_E_ZPT	"ze"
#define	NAM_RG_P_R_XPT	"xr"
#define	NAM_RG_P_R_ZPT	"zr"
#define	NAM_RG_P_L_XPT	"xl"
#define	NAM_RG_P_L_ZPT	"zl"
#define	NAM_RG_P_W_XPT	"xw"
#define	NAM_RG_P_W_ZPT	"zw"
#define	NAM_RG_P_C_XPT	"xc"
#define	NAM_RG_P_C_ZPT	"zc"

#define IDX_J3		1
#define IDX_J4		2
#define IDX_J5		3

#define NAM_J3		"Wall/Shell Type"
#define NAM_J4		"Flat Double Bottom"
#define NAM_J5		"Cylinder Double Bottom"

/* [Plate_Jigs Parameters] form */
#define JF_MS	201	/* <Middle Ship> field 			*/
#define JF_EX	202	/* <Extension Value> field		*/
#define JF_HR	203	/* <Scallop Radius> field		*/
#define JF_GG	204	/* <Ground Gap> field			*/
#define JF_OS	205	/* <Jigs Offset> field			*/
#define JF_SP	206	/* <Jigs Spacing> field			*/
#define	JF_SW	207	/* <Strip Width> field			*/
#define JF_TY	208	/* <Jigs Type> field with pop_up list	*/
#define	JF_GO	209	/* <Grid Option> toggle			*/
#define	JF_SO	210	/* <Strip Option> toggle		*/
#define JF_DR   211     /* <Jigs Direction> toggle		*/

/* [Check_List] form */
#define JF_LENGTH	100
#define	JF_MCF		100


/* ************************************************************************** */
/*			OLD FASHIONED MACRO				      */
/* ************************************************************************** */

/* Macro <plate_jig> generic data */
#define	MACRO_P_JIGS	"plate_jig"
#define	MACRO_J_FTEMP	16			/* Fixe templates number      */
#define	MACRO_J_VTEMP	100			/* Variable templates number  */
#define	MACRO_J_FFEET	6			/* Fixe feet number	      */
#define	MACRO_J_VFEET	(MACRO_J_VTEMP + 1)	/* Variable feet number       */
#define	P_JIGS_NAME	"PlateJig"

/* Macro <plate_jig> templates name */
#define NAM_P_GRD	NAM_TO_GRD
#define	NAM_P_EXT1	"jig_ext1"
#define	NAM_P_EXT2	"jig_ext2"
#define	NAM_P_HOLE	"hole_radius"
#define	NAM_P_INV	NAM_TO_INV
#define	NAM_P_PPNT	"PP_point"
#define	NAM_P_LK1	"cntl_lin1"
#define	NAM_P_LK2	"cntl_lin2"
#define NAM_P_IDX	"jig_index"
#define	NAM_P_SCAL	NAM_TO_SCAL
#define	NAM_P_MID	NAM_TO_MID
#define	NAM_P_TYPE	"jig_type"
#define	NAM_P_OSET	"jig_offset"
#define	NAM_P_SPAC	"jig_spacing"
#define	NAM_P_ORDR	"jig_order"
#define	NAM_P_NPLT	"plate_number"
#define	NAM_P_VART	"plate|line"

/* Macro <plate_jig> templates index */
#define	IDX_P_GRD	 0
#define	IDX_P_EXT1	 1
#define	IDX_P_EXT2	 2
#define	IDX_P_HOLE	 3
#define	IDX_P_INV	 4
#define IDX_P_PPNT	 5
#define IDX_P_LK1	 6
#define IDX_P_LK2	 7
#define IDX_P_IDX	 8
#define	IDX_P_SCAL	 9
#define	IDX_P_MID	10
#define	IDX_P_TYPE	11
#define	IDX_P_OSET	12
#define	IDX_P_SPAC	13
#define	IDX_P_ORDR	14
#define	IDX_P_NPLT	15

/* Macro <plate_jig> feet name */
#define	NAM_P_CONT	NAM_TO_CONT
#define	NAM_P_REAL	NAM_TO_REAL
#define	NAM_P_JNAM	"jig_name"
#define	NAM_P_ATTR	"jig_attr"
#define	NAM_P_LINE	"lk_line1"
#define	NAM_P_TEXT	"lk_text"
#define	NAM_P_VARF	"line|weld"

/* Macro <plate_jig> feet index */
#define	IDX_P_CONT	0
#define	IDX_P_REAL	1
#define	IDX_P_JNAM	2
#define	IDX_P_ATTR	3
#define	IDX_P_LINE	4
#define	IDX_P_TEXT	5

#endif
