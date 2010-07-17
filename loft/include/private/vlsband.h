/* $Id $  */
/* --------------------------------------------------------------------
 * I/LOFT
 *
 * File:        include/private/vlsband.h
 *
 * Description: Steel Band Definitions
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log $
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      06/07/00        Rama Rao        Header Creation.
 * -------------------------------------------------------------------*/

#ifndef vlsband_include
#define vlsband_include

/* Directions */
#define AFT     1
#define FWD     2
#define IB      3
#define OB      4
#define DWN     5
#define UPP     6

/* Steel Band Points Attributes */
#define IDX_SBJ_ATTR    4

#define IDX_SBJ_IDX     0
#define IDX_SBJ_LEN     1
#define IDX_SBJ_NAM     2
#define IDX_SBJ_REF     3

#define NAM_SBJ_IDX     "Index"
#define NAM_SBJ_LEN     "Length"
#define NAM_SBJ_NAM     "MoldLineName"
#define NAM_SBJ_REF     "RefLineName"

/* Form Labels */
#define G_MESSAGE_FIELD         10
#define G_BAND_MCF              12
#define G_UNIT_NUMBER           14
#define G_JOB_NUMBER            16
#define G_JOB_DESC              18
#define G_DATUM_LINES           19
#define G_MARKING_LINES         21
#define G_SURFACE_NAME          23
#define G_ADD                   29
#define G_DELETE                30
#define G_DIRECTION             31
#define G_KEY_IN                32
#define G_SURFACE_LIST		33
#define G_SURFACE_LOCATE	34
#define G_SURFACE_DELETE	35
#define G_SHOW_EDGES		37

/* Steel Band Attributes */

#define NB_SB_ATTR		11

#define NAM_SB_UNITNO           "UnitNumber"
#define NAM_SB_JOBNO            "JobNumber"
#define NAM_SB_JOBDESC          "JobDescription"
#define NAM_SB_BANDNO           "BandNumber"
#define NAM_SB_BANDDESC         "BandDescription"
#define NAM_SB_STOCK            "Stock"
#define NAM_SB_SIDE		"Side"
#define NAM_SB_START_DIR	"StartDirection"
#define NAM_SB_WATERLINES	"WaterLines"
#define NAM_SB_MARKINGLINES	"MarkingLines"
#define NAM_SB_ENDSTOCK		"EndStock"

#define IDX_SB_UNITNO      	0
#define IDX_SB_JOBNO      	1
#define IDX_SB_JOBDESC  	2
#define IDX_SB_BANDNO 		3
#define IDX_SB_BANDDESC 	4
#define IDX_SB_STOCK  		5
#define IDX_SB_SIDE     	6
#define IDX_SB_START_DIR     	7
#define IDX_SB_WATERLINES  	8
#define IDX_SB_MARKINGLINES 	9
#define IDX_SB_ENDSTOCK	       10

#endif
