/* $Id: dbl.c,v 1.1 2001/01/18 16:31:32 art Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdcppl / dbl.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: dbl.c,v $
 *	Revision 1.1  2001/01/18 16:31:32  art
 *	ah
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:58  cvs
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

/*============================================================================*/
/*	Some basic functions are written for double arrays. 		      */
/*============================================================================*/

#include	"stdio.h"
#include	"igrtypedef.h"

extern	IGRdouble	fabs();

/*============================================================================*/
IGRboolean dblcmp ( one, two, tol, len)

	IGRdouble	*one;
	IGRdouble 	*two;
	IGRdouble	tol;
	IGRint		len;

{
	IGRint		i;
	IGRboolean	flag=TRUE;

#ifdef DEBUG
	printf ( "dblcmp() on :");
	for ( i=0; i<len; i++) 
		printf ( "\t<%f>\t<%f>\n\t", one[i], two[i]);
	printf ( "\n");
#endif


	for ( i=0; i<len; i++) {
	   	if ( fabs(one[i] - two[i]) > tol) {
	      		flag = FALSE;
	      		break;
		}
	}

	return flag;
}
/*============================================================================*/

/*============================================================================*/
void dblcpy ( to, from, len)

	IGRdouble	*to;
	IGRdouble 	*from;
	IGRint		len;

{
extern void *memcpy();

/*
	IGRint		i;

	for ( i=0; i<len; i++) to[i] = from[i];
	 isn' t it boutiful, shoud not we use memcpy 
*/
	memcpy( (char *)to, (char *)from, (int)len*sizeof(double) );
}
/*============================================================================*/
