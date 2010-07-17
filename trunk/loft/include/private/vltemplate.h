#ifndef vltemplate_include
#define vltemplate_include

/* General data */
#define	MAX_CHA_TEMP	20


/* ************************************************************************** */
/*			MACRO : TEMPLATE OBJECT				      */
/* ************************************************************************** */

/* Macro <template object> generic data */
#define	MACRO_TO_DEF		"template_obj"
#define	MACRO_TS_DEF		"template_spi"
#define	MACRO_TO_TEMP		 5
#define	MACRO_TO_FEET		17
#define	MACRO_TO_SPINE		12		/* Limited feet for box tpl.  */
#define	MACRO_TO_NAME		"TemplateObj"	/* Occurence naming	      */
#define	NUM_TO_ATTR   		24		/* Length of attributes' box  */

/* Macro <template object> templates names */
#define	NAM_TO_CSYS	"grd_csys"
#define	NAM_TO_PLAT	"tpl_plate"
#define	NAM_TO_PLAN	"tpl_plane"
#define	NAM_TO_CTRL	"ctrl_line"
#define NAM_TO_ATTR	"param_box"

/* Macro <template object> templates index */
#define	IDX_TO_CSYS	 0
#define	IDX_TO_PLAT	 1
#define	IDX_TO_PLAN	 2
#define	IDX_TO_CTRL	 3
#define	IDX_TO_ATTR	 4

/* Macro <template object> parameters names */
#define	NAM_TO_GRD	"grd_dist"
#define	NAM_TO_EXT1	"tpl_ext1"
#define	NAM_TO_EXT2	"tpl_ext2"
#define	NAM_TO_INV	"inv_norm"
#define	NAM_TO_PROJ	"proj_idx"
#define	NAM_TO_SCAL	"scale_factor"
#define	NAM_TO_MID	"middle_ship"
#define	NAM_TO_AXIS	"ship_axis"
#define	NAM_TO_XVAL	"x_place"
#define	NAM_TO_YVAL	"y_place"
#define	NAM_TO_STAT	"tpl_state"
#define	NAM_TO_FULL	"full/hollow"
#define	NAM_TO_HLEN	"hollow_length"
#define	NAM_TO_HRAD	"hollow_radius"
#define	NAM_TO_HWID	"hollow_width"
#define	NAM_TO_UPAR	"u_param"
#define	NAM_TO_VPAR	"v_param"
#define	NAM_TO_TXSZ	"text_size"
#define	NAM_TO_XCNT	"x_center"
#define	NAM_TO_YCNT	"y_center"
#define	NAM_TO_ZCNT	"z_center"
#define	NAM_TO_XNRM	"x_normal"
#define	NAM_TO_YNRM	"y_normal"
#define	NAM_TO_ZNRM	"z_normal"
#define	NAM_TO_VARR	"TemplateRib"

/* Macro <template object> parameters index */
#define	IDX_TO_GRD	 0
#define	IDX_TO_EXT1	 1
#define	IDX_TO_EXT2	 2
#define	IDX_TO_INV	 3
#define	IDX_TO_PROJ	 4
#define	IDX_TO_SCAL	 5
#define	IDX_TO_MID	 6
#define	IDX_TO_AXIS	 7
#define	IDX_TO_XVAL	 8
#define	IDX_TO_YVAL	 9
#define	IDX_TO_STAT	10
#define	IDX_TO_FULL	11
#define	IDX_TO_HLEN	12
#define	IDX_TO_HRAD	13
#define	IDX_TO_HWID	14
#define	IDX_TO_UPAR	15
#define	IDX_TO_VPAR	16
#define	IDX_TO_TXSZ	17
#define	IDX_TO_XCNT	18
#define	IDX_TO_YCNT	19
#define	IDX_TO_ZCNT	20
#define	IDX_TO_XNRM	21
#define	IDX_TO_YNRM	22
#define	IDX_TO_ZNRM	23

/* Macro <template object> state cases */
#define	VAL_TO_MID	1	/*	<Middle	   Template> case	*/
#define	VAL_TO_EXT	2	/*	<Extremity Template> case	*/
#define	VAL_TO_SPI	3	/*	<Spine     Template> case	*/

/* Macro <template object> feet names */
#define	NAM_TO_CONT	"contour"
#define	NAM_TO_REAL	"real_dist"
#define	NAM_TO_REFP	"ref_plane"
#define	NAM_TO_NAME	"tpl_name"
#define	NAM_TO_XRNG	"x_range"
#define	NAM_TO_YRNG	"y_range"
#define	NAM_TO_ATEXT	"ts_text"
#define	NAM_TO_AMARK	"ts_mark"
#define	NAM_TO_WELD1	"weld_pt1"
#define	NAM_TO_WELD2	"weld_pt2"
#define	NAM_TO_LINE1	"weld_ln1"
#define	NAM_TO_LINE2	"weld_ln2"
#define	NAM_TO_LINE	"lp_line"
#define	NAM_TO_ANGL	"lp_angle"
#define	NAM_TO_TEXT	"lp_text"
#define	NAM_TO_LP3D	"3d_lp_line"
#define NAM_TO_LEAN	"lean_dir"
#define	NAM_TO_VARM	"mark"
#define	NAM_TO_VART	"text"

/* Macro <template object> feet index */
#define	IDX_TO_CONT	 0
#define	IDX_TO_REAL	 1
#define	IDX_TO_REFP	 2
#define	IDX_TO_NAME	 3
#define	IDX_TO_XRNG	 4
#define	IDX_TO_YRNG	 5
#define	IDX_TO_ATEXT	 6
#define	IDX_TO_AMARK	 7
#define	IDX_TO_WELD1	 8
#define	IDX_TO_WELD2	 9
#define	IDX_TO_LINE1	10
#define	IDX_TO_LINE2	11
#define	IDX_TO_LINE	12
#define	IDX_TO_ANGL	13
#define	IDX_TO_TEXT	14
#define	IDX_TO_LP3D	15
#define	IDX_TO_LEAN	16


/* ************************************************************************** */
/*			MACRO : TEMPLATE MANAGER			      */
/* ************************************************************************** */

/* Macro <template manager> generic data */
#define	MACRO_TM_DEF	"template_mgr"
#define	MACRO_TM_FTEMP	4			/* Fixe templates number */
#define	MACRO_TM_VTEMP	100			/* Variable templates number */
#define	MACRO_TM_FFEET	13			/* Fixe feet number */
#define	MACRO_TM_VFEET	(MACRO_TM_VTEMP	+ 2)	/* Variable feet number */
#define	MACRO_TM_NAME	"TemplateMgr"		/* Occurence naming	      */
#define	NUM_TM_ATTR   	23			/* Length of attributes' box  */

/* Macro <template manager> templates names */
#define NAM_TM_PLAT	NAM_TO_PLAT
#define NAM_TM_R_CS	"rib_csys"
#define NAM_TM_B_CS	"spine_csys"
#define NAM_TM_ATTR	NAM_TO_ATTR
#define	NAM_TM_VART	"frame|plane"

/* Macro <template manager> templates index */
#define	IDX_TM_PLAT	 0
#define	IDX_TM_R_CS	 1
#define	IDX_TM_B_CS	 2
#define	IDX_TM_ATTR	 3

/* Macro <template manager> parameters names */
#define	NAM_TM_GRD	NAM_TO_GRD
#define	NAM_TM_EXT1	NAM_TO_EXT1
#define	NAM_TM_EXT2	NAM_TO_EXT2
#define	NAM_TM_INV	NAM_TO_INV
#define	NAM_TM_SPIN	"spine_template"
#define	NAM_TM_SCAL	NAM_TO_SCAL
#define	NAM_TM_MID	NAM_TO_MID
#define	NAM_TM_AXIS	NAM_TO_AXIS
#define	NAM_TM_PGH	"page_height"
#define	NAM_TM_PGW	"page_width"
#define	NAM_TM_RPNI	"Rpage_number"
#define	NAM_TM_RWMI	"Rwidth_max"
#define	NAM_TM_RXRI	"Rx_place"
#define	NAM_TM_RYRI	"Ry_place"
#define	NAM_TM_BPNI	"Bpage_number"
#define	NAM_TM_BWMI	"Bwidth_max"
#define	NAM_TM_BXRI	"Bx_place"
#define	NAM_TM_BYRI	"By_place"
#define	NAM_TM_FULL	"full/hollow"
#define	NAM_TM_HLEN	"hollow_length"
#define	NAM_TM_HRAD	"hollow_radius"
#define	NAM_TM_HWID	"hollow_width"
#define	NAM_TM_TXSZ	"text_size"

/* Macro <template manager> parameters index */
#define	IDX_TM_GRD	0
#define	IDX_TM_EXT1	1
#define	IDX_TM_EXT2	2
#define	IDX_TM_INV	3
#define	IDX_TM_SPIN	4
#define	IDX_TM_SCAL	5
#define	IDX_TM_MID	6
#define	IDX_TM_AXIS	7
#define	IDX_TM_PGH	8
#define	IDX_TM_PGW	9
#define	IDX_TM_RPNI	10
#define	IDX_TM_RWMI	11
#define	IDX_TM_RXRI	12
#define	IDX_TM_RYRI	13
#define	IDX_TM_BPNI	14
#define	IDX_TM_BWMI	15
#define	IDX_TM_BXRI	16
#define	IDX_TM_BYRI	17
#define	IDX_TM_FULL	18
#define	IDX_TM_HLEN	19
#define	IDX_TM_HRAD	20
#define	IDX_TM_HWID	21
#define	IDX_TM_TXSZ	22

/* Macro <template manager> feet names */
#define	NAM_TM_CTRL	NAM_TO_CTRL
#define	NAM_TM_REAL	NAM_TO_REAL
#define	NAM_TM_RPNO	NAM_TM_RPNI
#define	NAM_TM_RWMO	NAM_TM_RWMI
#define	NAM_TM_RXRO	"Rx_range"
#define	NAM_TM_RYRO	"Ry_range"
#define	NAM_TM_BPNO	NAM_TM_BPNI
#define	NAM_TM_BWMO	NAM_TM_BWMI
#define	NAM_TM_BXRO	"Bx_range"
#define	NAM_TM_BYRO	"By_range"
#define	NAM_TM_RBOX	"RibBoxManager"
#define	NAM_TM_SBOX	"SpiBoxManager"
#define	NAM_TM_TSPI	"TemplateSpine"
#define	NAM_TM_VARF	NAM_TO_VARR

/* Macro <template manager> feet index */
#define	IDX_TM_CTRL	 0
#define	IDX_TM_REAL	 1
#define	IDX_TM_RPNO	 2
#define	IDX_TM_RWMO	 3
#define	IDX_TM_RXRO	 4
#define	IDX_TM_RYRO	 5
#define	IDX_TM_BPNO	 6
#define	IDX_TM_BWMO	 7
#define	IDX_TM_BXRO	 8
#define	IDX_TM_BYRO	 9
#define	IDX_TM_RBOX	10
#define	IDX_TM_SBOX	11
#define	IDX_TM_TSPI	12


/* ************************************************************************** */
/*			MACRO : TEMPLATE ORTHOGONAL BOX	MANAGER		      */
/* ************************************************************************** */

/* Macro <box manager> generic data */
#define	MACRO_TB_DEF		"template_box"
#define	MACRO_TB_TEMP		  2
#define	MACRO_TB_VFEET		100
#define	MACRO_TB_NAME		"TemplateBox"	/* Occurence naming	      */
#define	NUM_TB_ATTR   		  4		/* Length of attributes' box  */

/* Macro <box manager> templates names */
#define NAM_TB_CSYS	NAM_TO_CSYS
#define NAM_TB_ATTR	NAM_TO_ATTR

/* Macro <box manager> templates index */
#define IDX_TB_CSYS	0
#define IDX_TB_ATTR	1

/* Macro <box manager> parameters names */
#define	NAM_TB_PGH	NAM_TM_PGH
#define	NAM_TB_PGW	NAM_TM_PGW
#define	NAM_TB_PGF	"from_page"
#define	NAM_TB_PGT	"to_page"

/* Macro <box manager> parameters index */
#define	IDX_TB_PGH	0
#define	IDX_TB_PGW	1
#define	IDX_TB_PGF	2
#define	IDX_TB_PGT	3

/* Macro <box manager> feet names */
#define NAM_TB_VARF	"TemplateBox"

/* ************************************************************************** */
/*			COMMAND OBJECT DEFINITIONS			      */
/* ************************************************************************** */

#define	INVNORM_OF	    1		/* Average normal inversion off	*/
#define	INVNORM_ON	   -1		/* Average normal inversion on	*/
#define	PROJECT_OF	    0		/* 3D objects projection off	*/
#define	PROJECT_ON	    1		/* 3D objects projection on	*/

#define	X_MID_SHIP	    0.0
#define	Y_MID_SHIP    1234567.0
#define	Z_MID_SHIP   -1234567.0

#define	X_AXIS		"X axis"
#define	Y_AXIS		"Y axis"
#define	Z_AXIS		"Z axis"

#define	IDX_AX1		1
#define	IDX_AX2		2
#define	IDX_AX3		3

/* [Templates Parameters] form */
#define	TF_MD	101	/* <Minimum Distance> field		*/
#define	TF_AX	102	/* <Ship Axis> field with pop_up list	*/
#define	TF_BX	103	/* <Box Template> toggle		*/
#define TF_EX	104	/* <Extension Value> field		*/
#define	TF_PH	105	/* <Frame Height> field			*/
#define	TF_PW	106	/* <Frame Width> field			*/
#define	TF_PS	107	/* <Frame Scale> field			*/
#define TF_XM	108	/* <X Middle Ship> field		*/
#define	TF_FH	109	/* <Full/Hollow> field			*/
#define	TF_SZ	110	/* <Text Size> field			*/
#define	TF_IN	111	/* <Inverse Normal> toggle		*/
#define TF_TIT  11	/* title of the command 		*/

#endif
