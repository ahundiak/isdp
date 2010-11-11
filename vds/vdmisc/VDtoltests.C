/*
	I/VDS	Copy
*/
#include <stdio.h>
#define _INGR_EXTENSIONS
#include <math.h>
#include <values.h>
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "bstypes.h"
#include "bserr.h"
#include "bsparameters.h"
/*
 * Includes of function prototypes.
 */
#include "bscrossp.h"
#include "bsdistptpts.h"
#include "bsdotp.h"
#include "bslenvec.h"
#include "maang2vc.h"
/*----------------------------------------------------------------------------*/
int VD_zeroDist( double d )
{
	long	msg ;
	double	tollenvec ;

	BSEXTRACTPAR( &msg, BSTOLLENVEC, tollenvec ) ;

	return d < tollenvec ;

} /* VD_zeroDist */
/*----------------------------------------------------------------------------*/
int VD_eqPoints( p1, p2 ) IGRpoint p1, p2 ; {

	long	msg ;
	double	distSq,
		tolsqlenvec ;

	BSEXTRACTPAR( &msg, BSTOLSQLENVEC, tolsqlenvec ) ;

	distSq = BSdistptpts( &msg, p1, p2 ) ;

	return distSq < tolsqlenvec ;

} /* VD_eqPoints */
/*----------------------------------------------------------------------------*/
int VD_colinearVectors( v1, v2 ) IGRvector v1, v2 ; {

	long		msg ;
	double		length,
			tolcollinvec ;
	IGRvector	v1Xv2 ;

	BScrossp( &msg, v1, v2, v1Xv2 ) ;
	length = BSlenvec( &msg, v1Xv2 ) ;

	BSEXTRACTPAR( &msg, BSTOLCOLLINVEC, tolcollinvec ) ;

	return length <= tolcollinvec ;

} /* VD_colinearVectors */
/*----------------------------------------------------------------------------*/
int VD_orthoVectors( v1, v2 ) IGRvector v1, v2 ; {

	long		msg ;
	double		tolorthovec ;

	BSEXTRACTPAR( &msg, BSTOLORTHOVEC, tolorthovec ) ;

	return fabs( BSdotp( &msg, v1, v2 ) ) <= tolorthovec ;

} /* VD_orthoVectors */
/*----------------------------------------------------------------------------*/
int VD_areaColinearVectors( v1, v2, angle ) IGRvector v1, v2 ; IGRdouble angle ; {

	/*
	 * This function returns TRUE if vector v2 is inside the set of
	 * colinear vectors of vector v1. This set is defined by the two
	 * cones ( v1, angle ) and ( -v1, angle ).
	 *
	 *	    ^	  ^			^ v2 ( FALSE )
	 *	     \	 /			|
	 *	      \ / \ <- angle		|
	 *   -v1 <-----.-----> v1	  <-----.-----> v2 ( TRUE )
	 *	      / \	    v2 ( TRUE )  \
	 *	     /	 \			  \
	 *	    v	  v			   v v2 ( TRUE )
	 *
	 * Note : angle should be in radian.
	 */
	long		msg ;
	double		angleV1V2[3] ;

	MAang2vc( &msg, v1, v2, angleV1V2 ) ;

	return fabs( angleV1V2[1] ) <= fabs( sin( angle ) ) ;

} /* VD_areaColinearVectors */
/*----------------------------------------------------------------------------*/
int VD_areaOrthoVectors( v1, v2, angle ) IGRvector v1, v2 ; IGRdouble angle ; {

	/*
	 * This function returns TRUE if vector v2 is inside the set of
	 * orthogonal vectors of vector v1. This set is defined by the cone
	 * of revolution ( vector orthogonal to v1, angle ).
	 *
	 *
	 *   ^	^  ^			^ v2 ( TRUE )
	 *    \ |\/  <- angle		|
	 *     \|/			|
	 *	.----> v1		.-----> v2 ( FALSE )
	 *     /|\			|\
	 *    / | \			| \ v2 ( TRUE )
	 *   v	v  v			v  v
	 *			      v2 ( TRUE )
	 *
	 * Note : angle should be in radian.
	 */
	long		msg ;
	double		angleV1V2[3] ;

	MAang2vc( &msg, v1, v2, angleV1V2 ) ;

	return fabs( angleV1V2[2] ) <= fabs( cos( (M_PI/2.0) - angle ) ) ;

} /* VD_areaOrthoVectors */
/*----------------------------------------------------------------------------*/
