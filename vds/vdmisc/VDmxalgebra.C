/*
	I/VDS	Copy
*/
#include <math.h>		/* For cos(), sin()		*/
#include <string.h>		/* For memcpy()			*/
#include "OMminimum.h"
#include "igetypedef.h"		/* IGE typedefs GR*		*/
#include "igrtypedef.h"		/* Typedef IGR*			*/
#include "bstypes.h"
#include "v_.h"
/*
 * Includes of function prototypes.
 */
#include "bscrossp.h"
#include "maidmx.h"
#include "matypemx.h"
#include "v_vecmxproto.h"

/*----------------------------------------------------------------------------*/
double *VD_rotatemx( angle, inMx, outMx )

IGRdouble		angle ;
const IGRmatrix	inMx ;
IGRmatrix	outMx ; {

	/*
	 * This function multiplies `inMx' with a rotation matrix whose
	 * rotation (in radians) angle is `angle', and whose rotation axis is
	 * the z-axis.
	 */

	IGRmatrix	rotMx ;
	short		_4 = 4 ;
	long		msg ;

	MAidmx( &msg, rotMx ) ;
	rotMx[0] = cos( angle ) ;
	rotMx[4] = sin( angle ) ;
	rotMx[1] = - rotMx[4] ;
	rotMx[5] =   rotMx[0] ;
	MAmulmx( &msg, &_4, &_4, &_4, rotMx, (double*) inMx, outMx ) ;

	return outMx ;

} /* VD_rotatemx */
/*----------------------------------------------------------------------------*/
double *VD_scalemx( scale, inMx, outMx )

/*
Abstract
 
	This function multiplies inMx with scaling matrix,
	where scaling factor is the same for each axis.
	(I) scaling factor and inMx.
	(O) outMx.
*/

IGRdouble		scale ;
const IGRmatrix	inMx ;
IGRmatrix	outMx ; {

	IGRmatrix	scalMx ;
	short		_4 = 4 ;
	long		msg ;

	MAidmx( &msg, scalMx ) ;
	scalMx[0] = scalMx[5] = scalMx[10] = scale ;
	MAmulmx( &msg, &_4, &_4, &_4, scalMx, (double*) inMx, outMx ) ;

	return outMx ;

} /* VD_scalemx */
/*----------------------------------------------------------------------------*/
double *VD_translatemx( vector, inMx, outMx )

const IGRvector vector ;
const IGRmatrix	inMx ;
IGRmatrix	outMx ; {

	/* 
	 * This function multiplies `inMx' with a translation matrix, whose
	 * translation vector is `vector'.
	 */
           
	IGRmatrix 	trnslMx ;
	short		_4 = 4 ;
	long		msg ;

	MAidmx( &msg, trnslMx ) ;
	trnslMx[ 3] = vector[0]; 
	trnslMx[ 7] = vector[1]; 
	trnslMx[11] = vector[2]; 
	MAmulmx( &msg, &_4, &_4, &_4, trnslMx, (double*) inMx, outMx ) ;

	return outMx ;

} /* VD_translatemx */
/*----------------------------------------------------------------------------*/
double *VD_mirrormx( axis, inMx, outMx )

enum VD_symmetry	axis ;
const IGRmatrix	inMx ;
IGRmatrix	outMx ; {

	/*
	 * This function multiplies `inMx' with a mirroring matrix, whose
	 * symmetry axis is given by the following codes : 
	 * VD_e_X_Symm  : x-axis
	 * VD_e_Y_Symm  : y-axis
	 * VD_e_XY_Symm : both x-axis & y-axis
	 */

	IGRmatrix	symMx ;
	short		_4 = 4 ;
	long		msg ;

	MAidmx( &msg, symMx ) ;

	switch( axis ) {
		case VD_e_X_Symm  : symMx[5] = -1 ; break ;
		case VD_e_Y_Symm  : symMx[0] = -1 ; break ;
		case VD_e_XY_Symm : symMx[0] =
				    symMx[5] = -1 ; break ;
	}
	MAmulmx( &msg, &_4, &_4, &_4, symMx, (double*) inMx, outMx ) ;

	return outMx ;

} /* VD_mirrormx */
/*----------------------------------------------------------------------------*/
double *VD_mkmatrix( O, i, j, k, M )

const IGRpoint	O ;
const IGRvector	i ;
const IGRvector	j ;
const IGRvector	k ;
IGRmatrix	M ; {

	int			u, u_times_4 ;
	IGRvector		K ;

	if( !k ) {
		long rc ;
		k = K ;
		BScrossp( &rc, (double*) i, (double*) j, (double*) k ) ;
	}
	for( u = 0 ; u < 3 ; u++ ) {
		u_times_4 = u * 4 ;
		M[u_times_4+0] = i[u] ;
		M[u_times_4+1] = j[u] ;
		M[u_times_4+2] = k[u] ;
		M[u_times_4+3] = O[u] ;
	}
	M[12] = M[13] = M[14] = 0 ; M[15] = 1 ;

	return M ;

} /* VD_mkmatrix */
/*----------------------------------------------------------------------------*/
double *VD_mulmx( inMx1, inMx2, outMx, outMxType )

const IGRmatrix	inMx1 ;
const IGRmatrix	inMx2 ;
IGRmatrix	outMx ;
short		*outMxType ; {

	long		msg ;
	short		_4 = 4 ;
	IGRmatrix	prodMx ;

	MAmulmx( &msg, &_4, &_4, &_4, (double*) inMx1, (double*) inMx2,
		 prodMx ) ;
	MAtypemx( &msg, prodMx, outMxType ) ;

	return (double *) memcpy(	(char *) outMx,
					(char *) prodMx,
					sizeof( IGRmatrix ) ) ;

} /* VD_mulmx */
/*----------------------------------------------------------------------------*/

