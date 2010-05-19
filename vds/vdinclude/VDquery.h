/* $Id: VDquery.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / VDquery.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDquery.h,v $
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
 * Constants for the query command 
 */

#ifndef VDquery_include
#define	VDquery_include

/* possible operators (from y.tab.h) 	*/

# define NUMBER 	257
# define IDENT 		258
# define SELECT 	259
# define WHERE 		260
# define OR 		261
# define AND 		262
# define GT 		263
# define GE 		264
# define LT 		265
# define LE 		266
# define EQ 		267
# define NE 		268
# define NOT 		269
# define XOR 		270
# define EXIST 		271


/* possible return code			*/
#define QY_E_SYNTAX 	-1
#define QY_TRUE		1
#define QYfalse		0

#endif
