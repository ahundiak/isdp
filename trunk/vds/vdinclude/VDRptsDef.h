/* $Id: VDRptsDef.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / VDRptsDef.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDRptsDef.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:51  cvs
 *	Initial import to CVS
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
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

#ifndef VDrpt_define
#define VDrpt_define

/* form labels */

#define  VDS_RPTS_FORM	0
#define  DISP_RPTS_FORM 1

/* gadget labels of VDrpts form */

#define VD_RPT_PROCESS	    18
#define VD_RPT_DISPLAY      31
#define VD_RPT_SAVE         32
#define VD_RPT_SINGLE_PART  46
#define VD_RPT_DIFF_2PARTS  47
#define VD_RPT_DIFF_2PRJS   57
#define VD_RPT_USR_DEF	    59
#define VD_RPT_NO1          26
#define VD_RPT_NO2          33
#define VD_RPT_CAT_TXT      20
#define VD_RPT_CAT_LIST1    19
#define VD_RPT_CAT_LIST2    21
#define VD_RPT_PRJ_TXT      34
#define VD_RPT_PRJ_FLD      38
#define VD_RPT_REV_TXT1     35
#define VD_RPT_REV_FLD1     37
#define VD_RPT_REV_TXT2     36
#define VD_RPT_REV_FLD2     39
#define VD_RPT_LIB_TXT      22
#define VD_RPT_LIB_FLD      23
#define VD_RPT_TEMP_TXT     24
#define VD_RPT_TEMP_FLD     25
#define VD_RPT_FILE_TXT     27
#define VD_RPT_FILE_FLD     28
#define VD_RPT_PARAM_TXT    29
#define VD_RPT_PARAM_TGL    30
#define VD_RPT_PARAM_TXT1   41
#define VD_RPT_PARAM_FLD1   43
#define VD_RPT_PARAM_TXT2   42
#define VD_RPT_PARAM_FLD2   48
#define VD_RPT_PARAM_TXT3   49
#define VD_RPT_PARAM_FLD3   50
#define VD_RPT_PARAM_TXT4   52
#define VD_RPT_PARAM_FLD4   51
#define VD_RPT_PARAM_TXT5   53
#define VD_RPT_PARAM_FLD5   55
#define VD_RPT_PARAM_TXT6   54
#define VD_RPT_PARAM_FLD6   56
#define VD_RPT_WHERE_TXT    61
#define VD_RPT_WHERE_FLD    62
/* symbolic constants */

#define VD_MAX_LIBNAME_LEN  132
#define VD_MAX_FLNAME_LEN  132
#define VD_MAX_TEMPLATE_LEN 132
#define VD_MAX_PART_LEN	    132

#define VD_RPT_OUTFILE	"/usr/tmp/report.out"  /* temporary file for creating
						   reports */
#define VD_RPT_TEMPLIB  "dba/dba.lib"	       /* this is library containing
						  templates under $VDS dir */


/* gadget label of VDDispRpts form */

#define VD_DISP_RPTS_FLD    12


#endif

