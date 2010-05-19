/*
	I/VDS	Copy.
*/
#include "bs.h"
#include "bsconic.h"
/*
 * Includes of function prototypes.
 */
#include "bscncprop.h"
#include "bscvnormal.h"
/*----------------------------------------------------------------------------*/
void VD_conicprp( curve,
		 type, center, r1_r, r2, f1_f, f2, v1, v2, v3_t1, v4_t2, rc )

struct IGRbsp_curve	*curve ;
int			*type ;
double			*r1_r,
			*r2 ;
IGRpoint		center,
			f1_f,
			f2,
			v1,
			v2,
			v3_t1,
			v4_t2 ;
BSrc			*rc ; {

	/*
	 * Same arguments and return codes as `BSconicprp'.
	 */

	IGRvector	unormal ;
	IGRpoint	p1,
			p2,
			p3 ;
	double		w1,
			w2,
			w3 ;
	IGRboolean	status ;
	int		i ;

	*rc = BSSUCC;

	status = BScvnormal( rc, curve, unormal ) ;
	if( !status ) goto wrapup ;

	for( i = 0 ; i < 3 ; ++i ) {
		if( curve->rational ) {
			p1[i] = curve->poles[i        ] / curve->weights[0] ;
			p2[i] = curve->poles[3 + i    ] / curve->weights[1] ;
			p3[i] = curve->poles[2 * 3 + i] / curve->weights[2] ;
		} else {
			p1[i] = curve->poles[i];
			p2[i] = curve->poles[3 + i];
			p3[i] = curve->poles[2 * 3 + i];
		}
	}

	if( curve->rational ) {
		w1 = curve->weights[0] ;
		w2 = curve->weights[1] ;
		w3 = curve->weights[2] ;
	} else {
		w1 = 1;
		w2 = 1;
		w3 = 1;
	}

	status = BScncprop(	rc,
				unormal,
				p1,
				p2,
				p3,
				&w1,
				&w2,
				&w3,
				type,
				center,
				r1_r,
				r2,
				f1_f,
				f2,
				v1,
				v2,
				v3_t1,
				v4_t2 ) ;

	wrapup : return ;

} /* VD_conicprp */
/*----------------------------------------------------------------------------*/
