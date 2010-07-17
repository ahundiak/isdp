/* $Id: */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrrt/cmp.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: cmp.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:06  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1998/01/16  05:24:52  pinnacle
 * Created: vrrt/cmp.C by r250_int for route
 *
 *
 *
 * History:
 *	01/15/98	Onay	Integration date.
 *
 *************************************************************************/


/* Various functions for comparing two objects of the same type,
e.g. for insertion into a linked list. */

#include <common.h>

/* Functions for converting a number into an integer comparison
without magnitude. */

#define DEFINE_CMPINTFUNC(type) \
int self(type)_to_cmpint(x) type x; { \
	if (x > 0) return CMP_GREATER; \
	if (x < 0) return CMP_LESS; \
	return 0; }

DEFINE_CMPINTFUNC(int)
DEFINE_CMPINTFUNC(long)
DEFINE_CMPINTFUNC(float)
DEFINE_CMPINTFUNC(double)

/* str_cmp() acts like the standard library function strcmp(),
but is robust against NULL pointers. */

int str_cmp(s1,s2) charp s1, s2; {
	ifnull (s1) s1 = ""; ifnull (s2) s2 = ""; return strcmp(s1,s2); }

/* Dummy comparison function for pointers.  Useful for sorting an input list
of previously allocated objects in order of appearance. */

int pointercmp(p1,p2) pointer p1, p2; { return p1==p2 ? 0 : CMP_GREATER; }

/* Functions for comparing integer data stored in pointers. */

int pointercmp_int(p1,p2) pointer p1, p2; { return (int)p1 - (int)p2; }
long pointercmp_long(p1,p2) pointer p1, p2; { return (long)p1 - (long)p2; }
