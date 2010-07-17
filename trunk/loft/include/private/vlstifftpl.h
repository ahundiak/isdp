#ifndef	vlstf_tpl_include
#define	vlstf_tpl_include

#define	MAX_CHA_TEMP	20

/* Macro <stf_tpl> generic data */
#define	MACRO_STFTPL	"stfnr_tpl"
#define	MACRO_S_FTEMP	7
#define	MACRO_S_VTEMP	0
#define	MACRO_S_FFEET	9
#define	MACRO_S_VFEET	100	/*	100 marks + 100 texts	*/
#define	STFTPL_NAME	"StfTpl"

/* Macro <stf_tpl> templates name */
#define	NAM_ST_STIF	"stiffener"
#define	NAM_ST_WLEF	"web_left"
#define	NAM_ST_THEI	"tpl_height"
#define	NAM_ST_TTHI	"tpl_thickness"
#define	NAM_ST_EXT1	"extension1"
#define	NAM_ST_EXT2	"extension2"
#define	NAM_ST_CODE	"tpl_code"

/* Macro <stf_tpl> templates index */
#define	IDX_ST_STIF	0
#define	IDX_ST_WLEF	1
#define	IDX_ST_THEI	2
#define	IDX_ST_TTHI	3
#define	IDX_ST_EXT1	4
#define	IDX_ST_EXT2	5
#define	IDX_ST_CODE	6

/* Macro <stf_tpl> feet name */
#define	NAM_SF_CONT	"contour"
#define	NAM_SF_TTHI	NAM_ST_TTHI
#define NAM_SF_SMRK     "start_mark"
#define NAM_SF_SLIN     "start_line"
#define NAM_SF_EMRK     "end_mark"
#define NAM_SF_ELIN     "end_line"
#define	NAM_SF_AMRK	"dir_mark"
#define	NAM_SF_ALIN	"dir_line"
#define	NAM_SF_ATTR	"markAttr"
#define	NAM_SF_NMRK	"dir_mark:symbol"	/* the nested graphic foot */
#define	NAM_SF_NLIN	"dir_line:symbol"	/* the nested graphic foot */
#define NAM_SF_VARF_M	"mark"
#define NAM_SF_VARF_T	"text"

/* Macro <stf_tpl> feet index */
#define IDX_SF_CONT	0
#define IDX_SF_TTHI	1
#define IDX_SF_SMRK	2
#define IDX_SF_SLIN	3
#define IDX_SF_EMRK	4
#define IDX_SF_ELIN	5
#define IDX_SF_AMRK	6
#define IDX_SF_ALIN	7
#define IDX_SF_ATTR	8

/* Macro <stf_tpl> feet parameters names */
#define	NAM_SB_TNUM	"totLine_num"
#define	NAM_SB_BNUM	"butLine_num"
#define	NAM_SB_CNUM	"ctrLine_num"
#define	NAM_SB_MNUM	"mrkLine_num"
#define	NAM_SB_SNUM	"seaLine_num"
#define	NAM_SB_WNUM	"watLine_num"
#define	NAM_SB_YNUM	"traLine_num"
#define	NAM_SB_GNAM	"genLine_nam"
#define	NAM_SB_XNUM	"stfMacr_num"

/* Indices of class of queriable lines */
#define IDX_SC_BUTT	0
#define	IDX_SC_CTRL	1
#define	IDX_SC_MRKL	2
#define	IDX_SC_SEAM	3
#define	IDX_SC_WATL	4
#define	IDX_SC_TRAC	5
#define	IDX_SC_LINE	6
#define	IDX_SC_MACR	6
#define	IDX_SC_SIZE	7

/* Class name of queriable lines for interface form */
#define NAM_SC_BUTT	" Butt    Lines"
#define	NAM_SC_CTRL	" Control Lines"
#define	NAM_SC_MRKL	" Marking Lines"
#define	NAM_SC_SEAM	" Seam    Lines"
#define	NAM_SC_WATL	" Water   Lines"
#define	NAM_SC_TRAC	" Trace   Lines"
#define	NAM_SC_MACR	" Stfnr  Macros"

/* Macro <stf_tpl> feet parameters indices */
#define	IDX_SB_TNUM	0
#define	IDX_SB_BNUM	IDX_SC_BUTT + 1
#define	IDX_SB_CNUM	IDX_SC_CTRL + 1
#define	IDX_SB_MNUM	IDX_SC_MRKL + 1
#define	IDX_SB_SNUM	IDX_SC_SEAM + 1
#define	IDX_SB_WNUM	IDX_SC_WATL + 1
#define	IDX_SB_YNUM	IDX_SC_TRAC + 1
#define	IDX_SB_XNUM	IDX_SC_MACR + 1
#define	IDX_SB_PVAR	IDX_SC_SIZE + 1
#define	IDX_SB_PMAX	IDX_SB_PVAR + MACRO_S_VFEET

/* Options of planarity for queriable lines */
#define IDX_SO_BUTT	0
#define	IDX_SO_CTRL	1
#define	IDX_SO_MRKL	0
#define	IDX_SO_SEAM	0
#define	IDX_SO_WATL	1
#define	IDX_SO_TRAC	1
#define	IDX_SO_MACR	0

/* Macro <stf_tpl> VSplate side options */
#define	VAL_TO_WEBR	0	/*	<VSplate Web Right> case	*/
#define	VAL_TO_WEBL	1	/*	<VSplate Web  Left> case	*/

/* [Stiffeners Templates] form */
#define	SF_TH	101	/*	<Template Height> field		*/
#define	SF_TT	102	/*	<Template Thickness> field	*/
#define	SF_TE	103	/*	<Template Extension> field	*/
#define	SF_WS	104	/*	<Web Side> toggle		*/
#define	SF_SL	105	/*	<Selected Lines> multi-field	*/

#endif
