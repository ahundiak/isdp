/*
	I/STRUCT
*/
#include <stdio.h>
#include <math.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "igetypedef.h"		/* IGE typedefs GR*		*/
#include "igrtypedef.h"		/* Typedef IGR*			*/
#include "bstypes.h"
#include "msdef.h"
#include "igrdef.h"		/* Constants IGR??		*/
#include "igr.h"		/* Structs IGR* for geometries	*/
#include "igrdp.h"		/* Structs IGR* for display	*/
#include "gr.h"
#include "dpdef.h"
#include "dp.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "godef.h"
#include "go.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bscrossp.h"
#include "bsdotp.h"

#define LENGTH	35.	
/*----------------------------------------------------------------------------*/
long VSdrawViewIndepLineSeg( msg, dpMode, dspAttr, dpInfo, pnts, tangent, normal )

long			*msg ;
enum GRdpmode		dpMode ;
struct IGRaltdisplay	*dspAttr ;
struct DP_information	*dpInfo ;
IGRpoint		pnts ;
IGRvector		tangent,
			normal ; {

	struct IGRpolyline	polyline ;	/* Line segment		*/
	struct DPele_header	dpBuf ;		/* To display segment	*/
	IGRvector		vw_vect[3],	/* View vectors		*/
				prod ;		/* Tangent x normal	*/
	int			i,
				iMax ;
	double			*vw_rot,	/* World-to-view matrix	*/
				maxAbsCos,
				pntBuf[6],	/* Point buffer		*/
				val ;
	struct IGRdisplay	dsp ;

	__DBGpr_vec( "Point", pnts ) ;
	__DBGpr_vec( "Normal", normal ) ;
	__DBGpr_vec( "Tangent", tangent ) ;

	vw_rot = &dpInfo->gragad->wld_to_view[0][0] ;

	__DBGpr_mat( "View rotation", vw_rot ) ;
	/*
	 * CAUTION: axis vectors are in rows not columns.
	 */ 
	for( i = 0 ; i < 3 ; i++ ) {
		vw_vect[0][i]	= vw_rot[0+i] ; 
		vw_vect[1][i]	= vw_rot[4+i] ;
		vw_vect[2][i]	= vw_rot[8+i] ;
	}

	/*
	 * Find view vector closest to prod.
	 */
	BScrossp( msg, tangent, normal, prod ) ;
	maxAbsCos = 0. ; iMax = 0 ;
	for( i = 0 ; i < 3 ; i++ ) {
		val = fabs( BSdotp( msg, prod, vw_vect[i] ) ) ;

		if( val > maxAbsCos ) {
				maxAbsCos = val ;
				iMax = i ;
		}
	}
	__DBGpr_int( "iMax-1", iMax ) ;
	if( iMax == 2 ) {
		/*
		 * We found the z-axis of view, since it will make segment
		 * seen as a point, which we do not want, let's try again with
		 * the x- and y-axis against the normal vector.
		 */
		int	iMax2 ;

		maxAbsCos = 0. ; iMax2 = 0 ;
		for( i = 0 ; i < 2 ; i++ ) {
			val = fabs( BSdotp( msg, normal, vw_vect[i] ) ) ;

			if( val > maxAbsCos ) {
				maxAbsCos = val ;
				iMax2 = i ;
			}
		}
		iMax = iMax2 ;
	}

	__DBGpr_int( "iMax-2", iMax ) ;
	val = LENGTH / dpInfo->gragad->vvol_viewport_scale ;

	for( i = 0 ; i < 3 ; i++ ) {
		pntBuf[i+0] 	= pnts[i] ;
		pntBuf[i+3]	= pnts[i] + val * vw_vect[iMax][i] ;
	}
	polyline.num_points	= 2 ;
	polyline.points		= pntBuf ;

	__DBGpr_vec( "Pnt buf 0", pntBuf ) ;
	__DBGpr_vec( "Pnt buf 1", pntBuf + 3 ) ;

	dsp.color	= *dspAttr->color ;
	dsp.weight	= *dspAttr->weight ;
	dsp.style	= *dspAttr->style ;

        dp$build_dis_buffer(	buffer		= &dpBuf,
				type		= IGRPY,
				display_att	= &dsp,
				geometry	= &polyline ) ;
        dp$dispelem(	msg	= msg,
			buffer	= &dpBuf,
			mode	= dpMode,
			dp_info = dpInfo ) ;

	return OM_S_SUCCESS ;

} /* VSdrawViewIndepLineSeg */
/*----------------------------------------------------------------------------*/

