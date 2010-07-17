#ifndef	vllayout_include
#define	vllayout_include

#define	MAX_CHA_TEMP	20

/* Macro <layout> generic data */
#define	MACRO_LAYOUT	"layout"
#define	MACRO_L_FTEMP	2
#define	MACRO_L_VTEMP	0
#define	MACRO_L_FFEET	3
#define	MACRO_L_VFEET	400
#define	LAYOUT_NAME	"PlateMap"

/* Macro <layout> templates name */
#define	NAM_LT_MACR	"balance"
#define	NAM_LT_GRID	"grid_attr"

/* Macro <layout> templates index */
#define	IDX_LT_MACR	0
#define	IDX_LT_GRID	1

/* Macro <layout> feet name */
#define	NAM_LF_EXT	"external"
#define	NAM_LF_GRID	NAM_LT_GRID
#define	NAM_LF_PRIV	"private"
#define	NAM_LF_VARF	"internal"

/* Macro <layout> feet index */
#define	IDX_LF_EXT	0
#define	IDX_LF_GRID	1
#define	IDX_LF_PRIV	2

/* Form gadgets */
#define	PL_XPI	102
#define	PL_YPI	103
#define	PL_MRG	104

/* ACrg_collect attributes names */
#define	NAM_LB_XPI	"Xpitch"
#define	NAM_LB_YPI	"Ypitch"
#define	NAM_LB_MRG	"Margin"
#define	NAM_LB_COL	"col_num"
#define	NAM_LB_LIN	"lin_num"
#define	NAM_LB_UNI	"uniform"
#define	NAM_LB_XIX	"x_col"
#define	NAM_LB_YIX	"y_lin"

/* ACrg_collect attributes index */
#define	IDX_LB_XPI	0
#define	IDX_LB_YPI	1
#define	IDX_LB_MRG	2
#define	IDX_LB_COL	3
#define	IDX_LB_LIN	4
#define	IDX_LB_UNI	5
#define	IDX_LB_FIXE1	6

/* ACrg_collect private names */
#define	NAM_LB_VMX	"Xmin"
#define	NAM_LB_VMY	"Ymin"
#define	NAM_LB_VMZ	"Zmin"
#define NAM_LB_DLX	"Xpas"
#define NAM_LB_DLY	"Ypas"
#define NAM_LB_VXX	"XvecX"
#define NAM_LB_VXY	"XvecY"
#define NAM_LB_VXZ	"XvecZ"
#define NAM_LB_VYX	"YvecX"
#define NAM_LB_VYY	"YvecY"
#define NAM_LB_VYZ	"YvecZ"

/* ACrg_collect private index */
#define	IDX_LB_VMX	 0
#define	IDX_LB_VMY	 1
#define	IDX_LB_VMZ	 2
#define IDX_LB_DLX	 3
#define IDX_LB_DLY	 4
#define IDX_LB_VXX	 5
#define IDX_LB_VXY	 6
#define IDX_LB_VXZ	 7
#define IDX_LB_VYX	 8
#define IDX_LB_VYY	 9
#define IDX_LB_VYZ	10
#define	IDX_LB_FIXE2	11

#endif
