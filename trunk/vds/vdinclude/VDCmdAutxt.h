/* $Id: VDCmdAutxt.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / VDCmdAutxt.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdAutxt.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:51  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.2  1997/09/18  03:09:42  pinnacle
 * Replaced: vdinclude/VDCmdAutxt.h for:  by mdong for vds
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.2  1994/12/12  17:21:00  pinnacle
 * Replaced:  vdinclude/VDCmdAutxt.h r#
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

/* I/VDS
 *
 * File:        ~VDS/include/VDCmdAutxt.h
 *
 * Description: This file is the include file for Command object that
 *              places annotation automatically
 *
 * History:
 *      08/17/94        Chaya V. Rao
 *
 */
/*============================================================================*/

#ifndef VDCmdAutxt_include

#define VDCmdAutxt_include

#define VDMACRO_NAME          14
#define VDREAD_FORMAT         30
#define VDDIM_ENV             49
#define VDEXIST_FORMAT        13
#define VDTEXT_LAYOUT         18

/*
 * position gadgets
 */
#define VDBOTTOM_LEFT         60
#define VDCENTER_LEFT         61
#define VDTOP_LEFT            62
#define VDBOTTOM_CENTER       63
#define VDCENTER_CENTER       64
#define VDTOP_CENTER          65
#define VDBOTTOM_RIGHT        66
#define VDCENTER_RIGHT        67
#define VDTOP_RIGHT           68

#define VDOFFSET_OPTION       50
#define VDOFFSETX             51
#define VDOFFSETY             52
#define VDOFFSETZ             53
#define VDOFFSETX_TEXT        54
#define VDOFFSETY_TEXT        55
#define VDOFFSETZ_TEXT        56
#define VDSELECTED_OBJ        47
#define VDBOXOPT_NO           42
#define VDBOXOPT_YES          44
#define VDBOXOPT_ELLIPSE      70
#define VDMSG_GAD             10 

#define VDLDRL_OPTION         31
#define VDLDRL1_TEXT          29
#define VDLDRL2_TEXT          28
#define VDLDRA_TEXT           27
#define VDLDRL1               24
#define VDLDRL2               23
#define VDLDRA                57

#endif
