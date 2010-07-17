/*
	I/STRUCT
*/

#include <stdio.h>
#include <stdlib.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "msdef.h"
#include "igrdef.h"
#include "igr.h"
#include "bstypes.h"
#include "bserr.h"
#include "EMSmsgdef.h"
#include "VDobj.h"
#include "vsdbgmacros.h"
#include "vsmiscmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bscveval.h"
#include "bscv_sf_int.h"
#include "bsdotp.h"
#include "bsmdstptarr.h"
#include "bssfevaln.h"
#include "vsvecmxproto.h"
/*----------------------------------------------------------------------------*/
long VSmustRevOrient( msg, sfGeom, cvGeom, isNatNorm, revNorm )

/*
 * See if the normal of the surface must be reversed: it will have to be if
 * the normal of the surface where it intersects the curve does not point in the
 * same direction as the tangent of the curve at the intersection point.
 */

long			*msg ;
struct	IGRbsp_surface	*sfGeom ;
struct	IGRbsp_curve	*cvGeom ;
int			isNatNorm ;
int			*revNorm ; {

	IGRpoint		*intPoints	= NULL ;
	double			*tParms		= NULL,
				*uParms		= NULL,
				*vParms		= NULL ;
	int			nbInt		= 0 ;
	IGRvector		sfNormal ;

	BScv_sf_int(	msg,
			cvGeom,
			sfGeom,
			&nbInt,
			(double **) &intPoints,
			&tParms,
			&uParms,
			&vParms ) ;

	switch( nbInt ) {

		int		i1,
				i2 ;
		IGRpoint	endPnt[1],
				pntAtUV;
		double		dist,
				eval[9] ;
		IGRboolean	nat_side ;
		IGRpoint	cvEval[3];
		
		case 0 : 
			 BScveval( cvGeom, 0, 1, cvEval, msg ) ;
			 if( BSERROR( *msg ) ) {
				*msg = EMS_E_BSerror ;
				goto wrapup ;
			 }
			 BSptonnsdsf( sfGeom, cvEval[0], &nat_side, msg);

			 *revNorm = ( !(nat_side) && sfGeom->pos_orient) ; 
			 break ;
		case 1 : i2 = 0 ;
			 goto SFEVAL ;

		default:
			/*
			 * Find point closest to end point #0 of curve.
			 */
			BScveval( cvGeom, 0., 0, (IGRpoint *) endPnt[0], msg ) ;
			if( BSERROR( *msg ) ) {
				*msg = EMS_E_BSerror ;
				goto wrapup ;
			}
			BSmdstptarr(	1,
					endPnt,
					nbInt,
					intPoints,
					&i1,
					&i2,
					&dist,
					msg ) ;
		SFEVAL:
			BSsfevaln(	
				sfGeom,			/* IN  : surface geom.*/
				uParms[i2],		/* IN  : u of eval.   */
				vParms[i2],		/* IN  : v of eval.   */
				1,			/* IN  : u-left/v-left*/
				&i1,			/* OUT : # of norms   */
				pntAtUV,		/* OUT : point at u, v*/
				(IGRvector *) sfNormal,	/* OUT : nrml at u, v */
				msg ) ;			
			if( BSERROR( *msg ) ) {
				*msg = EMS_E_BSerror ;
				goto wrapup ;
			}
			if( !isNatNorm ) VSnegvc( sfNormal, sfNormal ) ;
			/*
			 * Get tangent of curve at intersection.
			 */
			BScveval(
				cvGeom,		   /* IN  : curve geometry  */
				tParms[i2],	   /* IN  : t of evaluation */
				1,		   /* IN  : point+tangent   */
				(IGRpoint *) eval, /* OUT : buffer	    */
				msg ) ;
			if( BSERROR( *msg ) ) {
				*msg = EMS_E_BSerror ;
				goto wrapup ;
			}
			*revNorm = BSdotp( msg, eval + 3, sfNormal ) < 0 ;
			break ;
			
	}

	*msg = MSSUCC ;

	wrapup :
		_FREE( intPoints	) ;
		_FREE( tParms		) ;
		_FREE( uParms		) ;
		_FREE( vParms		) ;
		return *msg & 1 ? OM_S_SUCCESS : OM_W_ABORT ;

} /* VSmustRevOrient */
/*----------------------------------------------------------------------------*/

