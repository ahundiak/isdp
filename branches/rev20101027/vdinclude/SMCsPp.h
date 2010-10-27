/* $Id: SMCsPp.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / SMCsPp.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCsPp.h,v $
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

/*
 * I/VDS
 * 
 * definition of gadget labels of the form SMCsPp 
 */

#ifndef SMCsPp_include
#define	SMCsPp_include

#define SM_PERP_MAX_ATTR	80

#define MAX_CHAR	256

#define	OCC_NAME	17
#define	COORDINATE	19
#define	CS_NAME		60

#define	AFTDIST		30
#define	FOREDIST	31

#define	AFTEXP		43
#define	FOREXP		44

#define	ANALYSIS	12
#define DRAWING		13
#define MIDDLE		14

#define AFTNAME		22
#define FORENAME	23
#define MIDNAME		24
#define DRWNAME		29

#define DRWMAC		28
#define MIDPP		21


#define	F_TITLE		57

#define SAVE            1
#define STORE           2
#define ABORT           3
#define EXIT            4
#define LOAD		25
#define MESSAGE_FIELD   10

#endif

