/* $Id: SMSurf.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / SMSurf.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMSurf.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:51  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.2  1997/02/06  20:38:40  pinnacle
 * Replaced: vdinclude/SMSurf.h for:  by jwfrosch for vds.241
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

/*
 * I/VDS
 *
 *  definition of gadget labels of the forms SMSurf
 */
#ifndef SMSurf_include
#define SMSurf_include

struct def_slope{
	IGRdouble		slope;
	struct GRobj_env	frame;
	IGRdouble		dx;
};
struct def_pts{
	IGRdouble		z_pos;
	struct GRobj_env	frame;
	IGRdouble		dx;
};


#define	F_TITLE		57

#define PLACE    	0
#define MODIFY		1
#define LOAD_OCC 	511
#define LOAD_CS		513
#define RESTART 	515
#define MODIF_FORM 	517

#define LOAD		25

#define	OCC_NAME	17
#define	CS_NAME		14
#define	COORDINATE	15

#define	ORIENT		12
#define	SYMETRY		13


#define EXTENSION	31

#define EXT_X1		32   /* for transv bulk and transv corrugated bulk */
#define EXT_X2		33   /* ext_y is replaced by ext_x */
#define EXT_Y1		34
#define EXT_Y2		35
#define EXT_Z1		34
#define EXT_Z2		35

#define EXT_NMX1	42
#define EXT_NMX2	43
#define EXT_NMY1	44
#define EXT_NMY2	45
#define EXT_NMZ1	44
#define EXT_NMZ2	45


#define	CENTER		60
#define RADIUS		61

#define LEN1		60
#define LEN2		61
#define PERIOD		62
#define HIGHT		63
#define POINT		64

#define Y_POS1		70
#define Y_POS2		71
#define FR_FRAME	72
#define FR_NAME		73
#define FR_DX		74
#define TO_FRAME	75
#define TO_NAME		76
#define TO_DX		77

#define PTDEF_B		80

/*
 * new form SMBulkHead
 */
#define RAD_1_GAD	82
#define RAD_2_GAD	83

#define	SYMBOL_200	100
#define	SYMBOL_201	101

/* subform */


#define	DEF_FIELD	20
#define	DEL_ROW		21
#define	INSERT_ROW	22
#define	LOC_FRAME	23

#endif
