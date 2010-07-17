/* $Id:*/

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrrt_STEP/cmp.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: cmp.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:07  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/11/06  19:27:54  pinnacle
 * initial revision
 *
 *
 * History:
 *       Date            Name     Description
 *      11/06/98        Alwin     Creation
 *
 *************************************************************************/


/* Various functions for comparing two objects of the same type,
e.g. for insertion into a linked list. */

#include "common.h"

/* Functions for converting a number into an integer comparison
without magnitude. */

/** commented this for the time being. Alwin
#define DEFINE_CMPINTFUNC(type) \
int self(type)_to_cmpint(x) type x; { \
	if (x > 0) return CMP_GREATER; \
	if (x < 0) return CMP_LESS; \
	return 0; }
**/

/***
int long_to_cmpint( int x )
{
   if( x > 0 ) return CMP_GREATER;
   if( x < 0 ) return CMP_LESS;
   return 0;
}
***/

int double_to_cmp_int( int x )
{
   if( x > 0 ) return CMP_GREATER;
   if( x < 0 ) return CMP_LESS;
   return 0;
}

int float_to_cmpint( int x )
{
   if( x > 0 ) return CMP_GREATER;
   if( x < 0 ) return CMP_LESS;
   return 0;
}

int int_tocmpint( int x )
{
   if( x > 0 ) return CMP_GREATER;
   if( x < 0 ) return CMP_LESS;
   return 0;
}

/********* Even the declaration of the above functions are commented. Alwin
DEFINE_CMPINTFUNC(int)
DEFINE_CMPINTFUNC(long)
DEFINE_CMPINTFUNC(float)
DEFINE_CMPINTFUNC(double)
*********/

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
