/* $Id: VDChElPt.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* I/VDS
 *
 * File:	VDS/VDSrep/VDChElPt.h 
 *
 * Description:
 *   	Used for file VDChElPt.sl
 *      Define the gadgets states and struct FIform used for
 *              "Change Elment Path" command object
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDChElPt.h,v $
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
 *	04/15/94	Yuhang Zhu		DESCRIPTION
 *
 */


#ifndef VDChElPt_def_include
#define VDChElPt_def_include

/*
 * constants for form VDChgElePath
 */
#define VDcep_TITLE		11

#define VDcep_LAYER_BUTTON	25
#define VDcep_LAYER		16
#define	VDcep_LAYER_NAME	17

#define VDcep_COLOR_BUTTON	13
#define VDcep_COLOR		18
#define	VDcep_COLOR_NAME	21

#define VDcep_WEIGHT_BUTTON	14
#define VDcep_WEIGHT		20


#define VDcep_STYLE_BUTTON	15
#define VDcep_STYLE		22


#define VDcep_DIR_BUTTON	34
#define VDcep_DIRECTORY		35

#define VDcep_NAME_BUTTON	39
#define VDcep_NAME_ADD_MOVE_TOG	19

#define VDcep_NAME_PREFIX_TXT	37
#define VDcep_NAME_PREFIX	38

#define VDcep_COPY_ATTRIBUTES	29
#define VDcep_HILIGHT_SELECTION	30

#define VDcep_SAMPLE_LINE       24
#define VDcep_SAMPLE_RECT       23
#define VDcep_SAMPLE_TEXT       12

#define VDcep_MAX_LAYER         1023
#define VDcep_MIN_LAYER         0

#define VDcep_MAX_COLOR         255
#define VDcep_MIN_COLOR         0

#define VDcep_MAX_WEIGHT        31
#define VDcep_MIN_WEIGHT        0

#define VDcep_MAX_STYLE         255
#define VDcep_MIN_STYLE         0

/* max length of text */
#define	VDcep_MAX_TEXT          132		

/*
 * Form interface control constants
 */
#define	VD_REP_FORM_INFO	255
#define	VD_FORM_ACCEPT		1
#define	VD_FORM_EXECUTE		2
#define	VD_FORM_RESET		3
#define	VD_FORM_CANCEL		4
#define VD_FORM_COPY            5
#define VD_FORM_OBJECT          6
#define VD_FORM_FENCE           7
#define VD_FORM_DISPLAY         8
#define VD_FORM_COPY_END        9
/*
 * form identifier numbers
 */
#define	VDcep_MAIN_FORM		0



#endif /* VDChElPt_def_include */
