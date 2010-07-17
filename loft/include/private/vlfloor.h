#ifndef vlfloor_include
#define vlfloor_include

#define	MAX_CHA_TEMP	20

/* Macro <balance> generic data */
#define	MACRO_FLOOR	"balance"
#define	MACRO_B_FTEMP	6
#define	MACRO_B_VTEMP	100
#define	MACRO_B_FFEET	6
#define	MACRO_B_VFEET	(2 * MACRO_B_VTEMP)
#define	FLOOR_NAME	"PlateFloor"

/* Macro <balance> templates name */
#define	NAM_BT_GRD	"grd_dist"
#define	NAM_BT_REV	"rev_flag"
#define	NAM_BT_GCS	"grd_csys"
#define	NAM_BT_BCS	"bal_csys"
#define	NAM_BT_TYP	"jig_type"
#define	NAM_BT_QYO	"query_on"
#define	NAM_BT_VART	"src_obj"

/* Macro <balance> templates index */
#define	IDX_BT_GRD	0
#define	IDX_BT_REV	1
#define	IDX_BT_GCS	2
#define	IDX_BT_BCS	3
#define	IDX_BT_TYP	4
#define	IDX_BT_QYO	5

/* Macro <balance> feet name */
#define	NAM_BF_XANG	"x_angle"
#define	NAM_BF_YANG	"y_angle"
#define	NAM_BF_ZANG	"z_angle"
#define	NAM_BF_CONT	"contour"
#define	NAM_BF_NPLT	"num_plate"
#define	NAM_BF_ATTR	"plt_attr"
#define	NAM_BF_VARF	"proj|cont"

/* Macro <balance> feet index */
#define	IDX_BF_XANG	0
#define	IDX_BF_YANG	1
#define	IDX_BF_ZANG	2
#define	IDX_BF_CONT	3
#define	IDX_BF_NPLT	4
#define	IDX_BF_ATTR	5

#define IDX_J1          1
#define IDX_J2          2
#define IDX_J3          3

#define NAM_J1          "Wall/Shell Plates"
#define NAM_J2          "Double Bottom Plates"
#define NAM_J3          "User Define"

#define	PJ_TY		100
#define	PJ_QY		101
#define	PJ_MK		102
#define	PJ_PO		103
#define	PJ_HI		104
#define	PJ_AN		107

#define	PJ_EA_X		17
#define	PJ_EA_Y		18
#define	PJ_EA_Z		19

#define PJ_TG		13
#define PJ_GS		24
#define PJ_GRP		23

#define NO_SEL          "No Reference"
#define TWO_PT_SEL      "By Two Points"
#define THREE_PT_SEL	"By Three Points"
#define PLANE_SEL	"By Plane"

/* ACrg_collect attributes names */
#define	NAM_BB_IDX	"plt_index"
#define	NAM_BB_NAM	"plt_name"
#define	NAM_BB_BSM	"bot_seam"
#define	NAM_BB_TSM	"top_seam"

/* ACrg_collect attributes index */
#define	IDX_BB_IDX	0
#define	IDX_BB_NAM	1
#define	IDX_BB_BSM	2
#define	IDX_BB_TSM	3
#define	IDX_BB_MAX	4

#endif
