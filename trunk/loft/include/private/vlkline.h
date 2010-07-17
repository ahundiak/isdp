/* $Id $  */
/* --------------------------------------------------------------------
 * I/LOFT
 *
 * File:        include/private/vlkline.h
 *
 * Description: Key Line Definitions
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log $
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      06/07/00        Rama Rao        File Creation.
 * -------------------------------------------------------------------*/

#ifndef vlkline_include
#define vlkline_include

/* Macro Name */
#define NAM_KL_MACR		"plate_key"

#define MAX_KL_TEMP            	22
#define MAX_KL_FEET           	1000
#define MAX_KL_CHAR_FEET      	10

/* Template Names */
#define NAM_KL_FRAM		"KeyFrame"
#define NAM_KL_ATTR		"Attributes"
#define NAM_KL_PLATE		"Plate"

/* Key Lines Input Attributes */
#define NAM_KL_UNITNO           "UnitNumber"
#define NAM_KL_JOBNO            "JobNumber"
#define NAM_KL_JOBDESC          "JobDescription"

/* Feet  Names */
#define NAM_KL_MOLD		"MoldSurface"
#define NAM_KL_FRLN		"KeyFrameLine"
#define NAM_KL_KLIN		"KeyLine"
#define NAM_KL_DIAG		"Diagonal"
#define NAM_KL_PNT		"Point"

/* Point Junction Attribute Names */
#define NAM_KPJ_ROW     	"Row"
#define NAM_KPJ_COL     	"Column"
#define NAM_KPJ_LNAM    	"LongitudinalMoldedLine"
#define NAM_KPJ_LDIST   	"LongitudinalDistance"
#define NAM_KPJ_TNAM    	"TransversalMoldedLine"
#define NAM_KPJ_TDIST   	"TransversalDistance"

/* Diagonal Junction Attribute Names */
#define NAM_KB_DIAGNAM  	"Name"

/* Form Gadget Numbers */
#define G_MESSAGE_FIELD         10
#define G_TITLE                 11
#define G_UNIT_NUMBER           14
#define G_JOB_NUMBER            16
#define G_JOB_DESC              18
#define G_SURFACE_NAME          23
#define G_PLATE_LIST            33
#define G_PLATE_LOCATE          34
#define G_PLATE_REMOVE          35
#define G_SHOW_EDGES            37
#define G_FRAME_LOCATE          12
#define G_FRAME_NAME            19

#endif
