/* $Id: VDbom.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdinclude / VDbom.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDbom.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:51  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.3  1994/12/13  15:43:06  pinnacle
 * Replaced:  vdinclude/VDbom.h r#
 *
 * Revision 1.2  1994/12/07  15:50:32  pinnacle
 * Replaced:  vdinclude/VDbom.h r#
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	12/07/94	R. Manem	New gadgets on BOM form
 *					Default values, other constants
 *
 * -------------------------------------------------------------------*/


#ifndef vd_bom_include
#     define vd_bom_include


#include "ACrg_collect.h"


/*
 * ----Gadget labels on the form.
 */

/* multicolumn fields */

#define VD_LST_ATTR_FLD       12
#define VD_COL_DESC_FLD       16
#define VD_GLB_ATTR_FLD       35

/* Roll through gadgets */

#define VD_ROL_PLUS_BTN       29
#define VD_ROL_MNUS_BTN       28
#define VD_DEL_LIST_BTN       11
#define VD_ROL_THRU_FLD       33
#define VD_ROL_THRU_GRP       34

/* Mcf title texts */

#define VD_ATT_NAME_TXT       14
#define VD_ATT_TYPE_TXT       15
#define VD_ATT_VALU_TXT       17
#define VD_COL_NAME_TXT       18
#define VD_SRT_ORDR_TXT       40
#define VD_COL_TITL_TXT       23
#define VD_COL_SIZE_TXT       25
#define VD_COL_JUST_TXT       31
#define VD_COL_FRMT_TXT       32
#define VD_OBJ_INFO_TXT       43

/* Attribute selection buttons */

#define VD_SELCT_ATT_BTN      19
#define VD_UNSEL_ATT_BTN      20
#define VD_SEL_GLOB_BTN       36
#define VD_UNS_GLOB_BTN       37

/* Null value representation */

#define VD_NUL_VALU_FLD       21
#define VD_NUL_VALU_TXT       22

/* Arrow buttons for moving columns */

#define VD_MOVE_UP_BTN        41
#define VD_MOVE_DOWN_BTN      42

/* Text parameter gadgets */

#define VD_TXT_SIZE_TXT       67
#define VD_TXT_WDTH_TXT       68
#define VD_TXT_HGHT_TXT       69

#define VD_TXT_WDTH_FLD       70
#define VD_TXT_HGHT_FLD       71

/* Default units */

#define VD_DEF_UNITS_TXT      74

/* Leader line gadgets */

#define VD_LDR_LINE_GAD       44

#define VD_LDR_LEN1_FLD       50
#define VD_LDR_LEN2_FLD       51
#define VD_LDR_ANGL_FLD       52

#define VD_LDR_LINE_TXT       45
#define VD_LDR_LEN1_TXT       59
#define VD_LDR_LEN2_TXT       60
#define VD_LDR_ANGL_TXT       58

/* Leader line graphics on form */

#define VD_LDR_LINE1_GRA      46
#define VD_LDR_LINE2_GRA      47
#define VD_LDR_LINE1_TXT      54
#define VD_LDR_LINE2_TXT      53
#define VD_LDR_ARR_HOR_GRA          48
#define VD_LDR_ARR_VER_GRA          49
#define VD_LDR_DIM_LINE_GRA         56
#define VD_LDR_DIM_ARC_GRA          55
#define VD_LDR_ANGLE_TXT            57
#define VD_LDR_ANG_ARR_HOR_GRA      65
#define VD_LDR_ANG_ARR_VER_GRA      64

#define VD_LDR_LINE_GRP             61

/* BOM output control buttons */

#define VD_BOM_ORNT_GAD       38
#define VD_BOM_ASSOC_GAD      62
#define VD_BOM_ASCII_GAD      63
#define VD_ASCII_FLNM_TXT     73
#define VD_ASCII_FLNM_FLD     66
#define VD_ASCII_FLNM_GRP     75

/* 
 * ----End of form gadget labels
 */

/* Other constants not related to the form */

#define MAXROWSIZE         64
#define DEF_COL_LENGTH     15
#define MAX_COL_WIDTH      50
#define MAX_COLUMNS        100
#define MAX_FILEBUF        256
#define MAX_BUF_CHARS      (MAX_COL_WIDTH + 1)
#define SORT_LEVEL         3

/* default leader line parameters */

#define DEF_LENGTH           5.0
#define DEF_ANGLE            45.0

/* max number of templates for the ci_macro */

#define MAX_TEMP            152

/* maximum number of objects for associative BOM */

#define MAX_OBJECTS        150

/* orientation of bom table */

#define BOTTOM_UP           '+'
#define TOP_DOWN            '-'

/* NULL representation for sort order */

#define NULL_SORT           "---"

/* NULL value of attribute for purpose of sorting */

#define NULL_VAL_STR        "!@!"

/* Sorting orders */

#define ASCENDING           '<'
#define DESCENDING          '>'

/* command types */

#define CREATE              0
#define MODIFY              1

/* structure used for qsort */

struct VDsortElement
{
     struct GRobj_env     obj;
     IGRchar              *refStr;
     IGRchar              compStr[MAX_BUF_CHARS];
     IGRchar              (*attrVal)[MAX_BUF_CHARS];
};


#endif
