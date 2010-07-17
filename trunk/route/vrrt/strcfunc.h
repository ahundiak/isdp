/* $Id: */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrrt/strcfunc.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: strcfunc.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:07  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1998/01/16  05:25:38  pinnacle
 * Created: vrrt/strcfunc.h by r250_int for route
 *
 *
 *
 * History:
 *	01/15/98	Onay	Integration date.
 *
 *************************************************************************/

#ifndef _STRCFUNC_
#define _STRCFUNC_

/* See the Common module cfunc.c. */

#define strisalpha(str) okay(strcheck(str,Cfunc[CF_ISALPHA],T))
#define strisupper(str) okay(strcheck(str,Cfunc[CF_ISUPPER],T))
#define strislower(str) okay(strcheck(str,Cfunc[CF_ISLOWER],T))
#define strisdigit(str) okay(strcheck(str,Cfunc[CF_ISDIGIT],T))
#define strisxdigit(str) okay(strcheck(str,Cfunc[CF_ISXDIGIT],T))
#define strisalnum(str) okay(strcheck(str,Cfunc[CF_ISALNUM],T))
#define strisspace(str) okay(strcheck(str,Cfunc[CF_ISSPACE],T))
#define strispunct(str) okay(strcheck(str,Cfunc[CF_ISPUNCT],T))
#define strisprint(str) okay(strcheck(str,Cfunc[CF_ISPRINT],T))
#define strisgraph(str) okay(strcheck(str,Cfunc[CF_ISGRAPH],T))
#define striscntrl(str) okay(strcheck(str,Cfunc[CF_ISCNTRL],T))
#define strisascii(str) okay(strcheck(str,Cfunc[CF_ISASCII],T))

#endif
