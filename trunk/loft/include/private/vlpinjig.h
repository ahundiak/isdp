/*************************************************************************
 * I/LOFT
 *
 * File:        include/private/vlpinjig.h
 *
 * Description: Pin Jig
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: vlpinjig.h,v $
 * Revision 1.1.1.1  2001/01/04 21:11:12  cvs
 * Initial import to CVS
 *
 * Revision 1.2  1998/10/03  18:26:12  pinnacle
 * tr179801585
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 10/03/98  ah      TR179801585 Increase macro feet to 1000
 *************************************************************************/

#ifndef	vlpinjig_include
#define	vlpinjig_include

#define	MAX_CHA_TEMP	20

/* Macro <pinjig> generic data */
#define	MACRO_PINJIG	"pinjig"
#define	MACRO_P_FTEMP	4
#define	MACRO_P_VTEMP	0
#define	MACRO_P_FFEET	2
#define	MACRO_P_VFEET	1000
#define	PINJIG_NAME	"PinJig"

/* Macro <pinjig> templates name */
#define	NAM_PT_MACR	"layout"
#define	NAM_PT_OPTF	"option"
#define	NAM_PT_IPIN	"intermediate"
#define	NAM_PT_INFR	"interference"

/* Macro <pinjig> templates index */
#define	IDX_PT_MACR	0
#define	IDX_PT_OPTF	1
#define	IDX_PT_IPIN	2
#define	IDX_PT_INFR	3

/* Macro <pinjig> feet name */
#define	NAM_PF_NPIN	"pin_number"
#define	NAM_PF_ATTR	"pin_attr"
#define	NAM_PF_VARF	"pin_jig"

/* Macro <pinjig> feet index */
#define IDX_PF_NPIN	0
#define IDX_PF_ATTR	1

/* Options names */
#define NAM_PJO_MIP     " Matrix Internal Points"
#define NAM_PJO_ECP     " External Contour Points"
#define NAM_PJO_CSP     " Columns Seams Points"
#define NAM_PJO_BSP     " Between Seams Points"

/* Options index */
#define IDX_PJO_MIP     1
#define IDX_PJO_ECP     2
#define IDX_PJO_CSP     4
#define IDX_PJO_BSP     8

/* Display option index */
#define IDX_PJO_DOF     0
#define IDX_PJO_DON     1

/* Symbol option names */
#define NAM_PJO_CIR     " CIRCLE"
#define NAM_PJO_PLU     " PLUS"
#define NAM_PJO_CRO     " CROSS"
#define NAM_PJO_POI     " POINT"

/* Symbol option index */
#define IDX_PJO_CIR     0
#define IDX_PJO_PLU     1
#define IDX_PJO_CRO     2
#define IDX_PJO_POI     3

/* ACrg_collect generic names */
#define	NAM_PB_COL	"col"
#define	NAM_PB_LIN	"lin"
#define	NAM_PB_XPT	"xpt"
#define	NAM_PB_YPT	"ypt"
#define	NAM_PB_ZPT	"zpt"
#define	NAM_PB_HEI	"hei"
#define	NAM_PB_ANG	"ang"
#define	NAM_PB_IDX	"idx"
#define	NAM_PB_NAM	"nam"

/* ACrg_collect generic index */
#define	IDX_PB_COL	0
#define	IDX_PB_LIN	1
#define	IDX_PB_XPT	2
#define	IDX_PB_YPT	3
#define	IDX_PB_ZPT	4
#define	IDX_PB_HEI	5
#define	IDX_PB_ANG	6
#define	IDX_PB_IDX	7
#define	IDX_PB_NAM	8
#define	IDX_PB_MAX	9

#endif
