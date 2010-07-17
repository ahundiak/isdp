/* $Id: */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrrt/cfunc.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: cfunc.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:07  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/11/06  19:49:20  pinnacle
 * Alwin
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1998/01/16  05:24:44  pinnacle
 * Created: vrrt/cfunc.h by r250_int for route
 *
 *
 *
 * History:
 *	01/15/98	Onay	Integration date.
 *
 *************************************************************************/

#ifndef _CFUNC_
#define _CFUNC_

/* See the Common module cfunc.c. */

#define CF_ISALPHA      0                       
#define CF_ISUPPER      1                       
#define CF_ISLOWER      2                       
#define CF_ISDIGIT      3                       
#define CF_ISXDIGIT     4                       
#define CF_ISALNUM      5                       
#define CF_ISSPACE      6                       
#define CF_ISPUNCT      7                       
#define CF_ISPRINT      8                       
#define CF_ISGRAPH      9                       
#define CF_ISCNTRL      10                      
#define CF_ISASCII      11                      

extern funcp Cfunc[];
extern int NCfunc;
extern charp Cfunc_name[];

extern int what_ctype();
extern int diag_what_ctype();
extern funcp what_cfunc();
extern funcp diag_what_cfunc();

#include "strcfunc.h"

#endif
