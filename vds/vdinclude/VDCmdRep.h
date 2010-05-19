/* $Id: VDCmdRep.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / VDCmdRep.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdRep.h,v $
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

#ifndef VDCmdRep_include
#define VDCmdRep_include

/*
 * form gadgets constants
 */

#define EXIT_SAVE	1
#define EXIT_NOSAVE	4
#define MESSAGE         10

#define LAYER_NAME      15
#define COLOR_NAME      16  	
#define LAYER   	17
#define COLOR		18
#define WEIGHT		19
#define STYLE		20
#define LAYER_BUTTON    21
#define COLOR_BUTTON    22
#define WEIGHT_BUTTON   23
#define STYLE_BUTTON    24

#define REPRESENTATION	21

#define POP_UP_BUTTONS  123

#define	MAIN		0
#define	MAX_FIELD	256

#define	COMMAND_NAME	":IGENOD:VDS_rep_comm_id"
#define	FORM_NAME	"VDErrorSymb"
#define	MAX_STRLEN	64


#endif
