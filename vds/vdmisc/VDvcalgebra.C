/*
	I/VDS	Copy
*/
#include <math.h>
#include "OMminimum.h"
#include "igetypedef.h"		/* IGE typedefs GR*		*/
#include "igrtypedef.h"		/* Typedef IGR*			*/
#include "bserr.h"
#include "bsparameters.h"
/*
 * Includes of function prototypes.
 */
#include "bsdotp.h"
#include "bsmkvec.h"
/*----------------------------------------------------------------------------*/
double *VD_scalvc( scale, in, out )

IGRdouble		scale ;
const IGRdouble 	*in ;
IGRdouble		*out ; {

	double *scaled = out ; int i ;

	for( i = 0 ; i < 3 ; i++ ) {
		*out++ = scale * *in++ ;
	}
	return scaled ;
	
} /* VD_scalvc */
/*----------------------------------------------------------------------------*/
double *VD_negvc( in, out ) const IGRdouble *in ; IGRdouble *out ; {

	double *neg = out ; int i ;

	for( i = 0 ; i < 3 ; i++ ) {
		*out++ = - *in++ ;
	}
	return neg ;

} /* VD_negvc */
/*----------------------------------------------------------------------------*/
double *VD_vccpy( out, in ) const IGRdouble *in ; IGRdouble *out ; {

	double *cpy = out ; int i ;

	for( i = 0 ; i < 3 ; i++ ) {
		*out++ = *in++ ;
	}
	return cpy ;

} /* VD_vccpy */
/*----------------------------------------------------------------------------*/
double *VD_zerovc( out ) IGRdouble *out ; {

	double *zero = out ; int i ;

	for( i = 0 ; i < 3 ; i++ ) {
		*out++ = 0. ;
	}
	return zero ;

} /* VD_zerovc */
/*----------------------------------------------------------------------------*/
double *VD_mxcpy( out, in ) const IGRdouble *in ; IGRdouble *out ; {

	double *cpy = out ; int i ;

	for( i = 0 ; i < 16 ; i++ ) {
		*out++ = *in++ ;
	}
	return cpy ;

} /* VD_mxcpy */
/*----------------------------------------------------------------------------*/
double *VD_mxprodpt( mx, pt, prod )

const IGRmatrix mx ;
const IGRpoint  pt ;
IGRpoint 	prod ; {

	short	_4  	= 4,
		_1	= 1 ;
	long	msg ;
	double	PT[4],
		PROD[4] ;

	PT[3] = PROD[3] = 1. ;

	MAmulmx(	&msg,
			&_4,
			&_4,
			&_1,
			(double*) mx,
			VD_vccpy( PT, pt ),
			PROD ) ;

	return VD_vccpy( prod, PROD ) ;

} /* VD_mxprodpt */
/*----------------------------------------------------------------------------*/
double *VD_mxprodvc( mx, vc, prod )

const IGRmatrix mx ;
const IGRvector vc ;
IGRvector	prod ; {

	IGRmatrix xform ;
	memcpy( xform, mx, sizeof( IGRmatrix ) ) ;
	xform[3] = xform[7] = xform[11] = 0 ;
	return VD_mxprodpt( xform, vc, prod ) ;

} /* VD_mxprodvc */
/*----------------------------------------------------------------------------*/
double *VD_midpoint( pt1, pt2, mid )

const IGRdouble	*pt1 ;
const IGRdouble	*pt2 ;
IGRdouble		*mid ; {

	int i ;

	for( i = 0 ; i < 3 ; i++ ) {
		mid[i] = 0.5 * ( pt1[i] + pt2[i] ) ;
	}
	return mid ;

} /* VD_midpoint */
/*----------------------------------------------------------------------------*/
double *VD_mxorigin( mx, origin ) const IGRdouble *mx ; IGRdouble *origin ; {

	origin[0] = mx[3] ;
	origin[1] = mx[7] ;
	origin[2] = mx[11] ;

	return origin ;

} /* VD_mxorigin */
/*----------------------------------------------------------------------------*/
double *VD_pjPtOnPlAlongVc( M, n, Q, p, P )

const IGRpoint	M ;
const IGRvector	n ;
const IGRpoint	Q ;
const IGRvector	p ;
IGRpoint	P ; {


	/*
	 * Projects a point `M' onto a plane defined by its normal vector `n'
	 * and a point `Q' along vector `p'.
	 *					->     ->
	 *            -> + M			MP = k p
	 *            p /|			-> ->	-> ->  ->  -> ->
	 *      -------/-|---------------	MP.n = (Mm+mP).n = Mm.n
	 *     /      /  |   ^ ->      /		-> ->  ->  -> ->
	 *    /      /   |m  | n      /		     = (MQ+Qm).n = MQ.n
	 *   /      /        +Q      /		-> ->    ->->  -> ->
	 *  /     P+                /		MP.n = k p.n = MQ.n
	 * -------------------------		    -> ->  ->->
	 *	   -> ->  ->->				k = MQ.n / p.n
	 * R = M + MP.n / p.n
	 * This function returns NULL if `p' and `n' are orthogonal and `P' is
	 * not set, else it returns `P'.
	 */
	long	msg ;
	double	n_dot_p	= BSdotp( &msg, (double*) n, (double*) p ),
		tolorthovec ;

	BSEXTRACTPAR( &msg, BSTOLORTHOVEC, tolorthovec ) ;

	if( fabs( n_dot_p ) <= tolorthovec ) {
		P = NULL ;
	} else {
		int		i ;
		IGRvector	MQ ;
		double		s ;

		BSmkvec( &msg, MQ, (double*) M, (double*) Q ) ;
		s = BSdotp( &msg, (double*) n, MQ ) / n_dot_p ;

		for( i = 0 ; i < 3 ; i++ ) {
			P[i] = M[i] - s * p[i] ;
		}
	}

	return P ;

} /* VD_pjPtOnPlAlongVc */
/*----------------------------------------------------------------------------*/
double *VD_pjVcOnPlAlongVc( v, n, p, w )

const IGRvector	v ;
const IGRvector	n ;
const IGRvector	p ;
IGRvector	w ; {

	/*
	 * Projects a vector `v' onto a vectorial plane defined by its normal
	 * vector `n' along vector `p'.
	 * The formula giving the projection `w' of `v' is (supposing that
	 * `p' and `n' are not orthogonal ) :
	 *
	 *          n . v
	 * w = v - _______ p	( where "." denotes the scalar product. )
	 *	    n . p
	 *
	 * Note that neither `p' nor `n' need be unit vectors.
	 * This function returns NULL if `p' and `n' are orthogonal and `w' is
	 * not set, else it returns `w'.
	 */
	long	msg ;
	double	n_dot_p	= BSdotp( &msg, (double*) n, (double*) p ),
		tolorthovec ;

	BSEXTRACTPAR( &msg, BSTOLORTHOVEC, tolorthovec ) ;

	if( fabs( n_dot_p ) <= tolorthovec ) {
		w = NULL ;
	} else {
		int	i ;
		double	s = BSdotp( &msg, (double*) n, (double*) v ) / n_dot_p ;

		for( i = 0 ; i < 3 ; i++ ) {
			w[i] = v[i] - s * p[i] ;
		}
	}

	return w ;

} /* VD_pjVcOnPlAlongVc */
/*----------------------------------------------------------------------------*/

