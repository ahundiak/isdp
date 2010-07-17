/*
	I/STRUCT
*/
#include <stdio.h>
#include "OMprimitives.h"
#include "bserr.h"
#include "OMerrordef.h"
#include "EMSmsgdef.h"
#include "msdef.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bsalloccv.h"
#include "bsbx2.h"
#include "bscvarreval.h"
#include "bscveval.h"
#include "bsfreecv.h"
#include "bslngen.h"
#include "bsmerge_cv.h"
#include "vsvecmxproto.h"

extern long	VSallocForBSmerge_cv() ;

#define NB_PTS_ALONG_X		50	/* Number of points of curve along X. */
#define NB_PTS_ALONG_Y		50	/* Number of points of curve along Y. */

#define NB_PTS_ONTO_CV		(NB_PTS_ALONG_X*NB_PTS_ALONG_Y)
					/* Number of points onto closed curve.*/
/*----------------------------------------------------------------------------*/
#ifdef vsDEBUG
static void VSprintMesh( comment, m )

char	*comment ;
short	m[NB_PTS_ALONG_Y][NB_PTS_ALONG_X] ; {

	int	i,
		j ;

	printf( "\n%s :\n\n", comment ) ;

	for( i=0; i<NB_PTS_ALONG_Y; i++ ) {
		for( j=0; j<NB_PTS_ALONG_X; j++ ) printf( "%d", m[i][j] ) ;
		printf( "\n" ) ;
	}

} /* VSprintMesh */
#endif
/*----------------------------------------------------------------------------*/
static void VScountNeighbor( m_in, m_nei )

short	m_in[NB_PTS_ALONG_Y][NB_PTS_ALONG_X],
	m_nei[NB_PTS_ALONG_Y][NB_PTS_ALONG_X] ; {

	int	i,
		j ;

	for( i=0; i<NB_PTS_ALONG_Y; i++ )
	for( j=0; j<NB_PTS_ALONG_X; j++ ) {

	if( 0 == m_in[i][j] ) {
		m_nei[i][j] = 0 ;
		continue ;
	}

	m_nei[i][j] =
	( i && j					? m_in[i-1][j-1] : 0 ) +
	( j						? m_in[i]  [j-1] : 0 ) +
	( i+1 < NB_PTS_ALONG_Y && j			? m_in[i+1][j-1] : 0 ) +
	( i+1 < NB_PTS_ALONG_Y				? m_in[i+1][j]	 : 0 ) +
	( i+1 < NB_PTS_ALONG_Y && j+1 < NB_PTS_ALONG_X	? m_in[i+1][j+1] : 0 ) +
	( j+1 < NB_PTS_ALONG_X				? m_in[i]  [j+1] : 0 ) +
	( i && j+1 < NB_PTS_ALONG_X			? m_in[i-1][j+1] : 0 ) +
	( i						? m_in[i-1][j]	 : 0 ) ;

	}

} /* VScountNeighbor */
/*----------------------------------------------------------------------------*/
static void VSfindInteriorPointUsingMesh( mesh, i_interior, j_interior )

short	mesh[NB_PTS_ALONG_Y][NB_PTS_ALONG_X] ;
int	*i_interior,
	*j_interior ; {

	int	i,
		j ;
	short	neighbor[NB_PTS_ALONG_Y][NB_PTS_ALONG_X] ;
	short	max = 0 ;

	VScountNeighbor( mesh, neighbor ) ;

#ifdef vsDEBUG
	VSprintMesh( "Mesh of neighbor", neighbor ) ;
#endif

	/*
	 * See if we can find the most interior point.
	 */
	for( i=0; i<NB_PTS_ALONG_Y; i++ ) {
		for( j=0; j<NB_PTS_ALONG_X; j++ )
			if( 8 == neighbor[i][j] ) break ;
		if( j < NB_PTS_ALONG_X ) break ;
	}

	if( NB_PTS_ALONG_Y == i ) {
		/*
		 * We can find the most interior point.
		 */
		for( i=0; i<NB_PTS_ALONG_Y; i++ )
			for( j=0; j<NB_PTS_ALONG_X; j++ )
				if( neighbor[i][j] > max ) {
					max = neighbor[i][j] ;
					*i_interior = i ;
					*j_interior = j ;
				}

		/*
		 * If the mesh of neighbor is null, we find the most interior
		 * point with the previous mesh of neighbor.
		 */
		if( *i_interior == NB_PTS_ALONG_Y &&
		    *j_interior == NB_PTS_ALONG_X ) {
			__DBGpr_com( "Mesh of neighbor is NULL" ) ;

			max = 0 ;

			for( i=0; i<NB_PTS_ALONG_Y; i++ )
				for( j=0; j<NB_PTS_ALONG_X; j++ )
					if( mesh[i][j] > max ) {
						max = mesh[i][j] ;
						*i_interior = i ;
						*j_interior = j ;
					}
		}
	} else {
		/*
		 * We cannot find the most interior point. So, for each
		 * point which is not surrounded of neighbor, consider it as
		 * an outside point.
		 */
		for( i=0; i<NB_PTS_ALONG_Y; i++ )
			for( j=0; j<NB_PTS_ALONG_X; j++ )
				if( neighbor[i][j] == 8 ) neighbor[i][j] = 1 ;
				else			  neighbor[i][j] = 0 ;

		VSfindInteriorPointUsingMesh( neighbor,
					      i_interior,
					      j_interior ) ;
	}

} /* VSfindInteriorPointUsingMesh */
/*----------------------------------------------------------------------------*/
long VSfindTheMostInteriorPointToACurve( msg, cvGeom, point )

long			*msg ;
struct IGRbsp_curve	*cvGeom ;
IGRpoint		point ; {

	/*
	 * Given a XY planar curve ( cvGeom ), this function returns the most
	 * interior point to the input curve ( point ).
	 *
	 *	       ----------------------	 <- curve.
	 *	       |		    |
	 *	       |     --------	    |
	 *	       |     |	    |	*   |	 (*) Returned point.
	 *	       |......	    |	    |
	 *			    |	    |
	 *			    ---------
	 *
	 * Note :
	 * =====
	 *	- If the input curve is not closed, this function closes it
	 *	  (...) and processes the closed curve.
	 */

	long		sts,		/* OM return code.		      */
			bsRC,		/* BS return code.		      */
			num ;		/* Number of points for BSbx2().      */
	int		i,		/* Loop index.			      */
			j ;		/* Loop index.			      */
	struct IGRbsp_curve
			*wkGeom,	/* Geometry of closed curve.	      */
			*lnGeom ;	/* Geometry of line segment from      */
					/*  first to last points of input     */
					/*  curve if it's not closed.	      */
	IGRpoint	ptAt0,		/* Start point of input curve.	      */
			ptAt1,		/* End point of input curve.	      */

			ptOnCv[NB_PTS_ONTO_CV] ;
					/* List of points on closed curve.    */

	double		pm[NB_PTS_ONTO_CV] ;
					/* Parameters of above points.	      */

	IGRpoint	min,		/* Min-max box that contains the      */
			max ;		/* closed curve.		      */

	short		mesh[NB_PTS_ALONG_Y][NB_PTS_ALONG_X] ;
					/* Mesh of points where member is     */
					/* equal to 1 means the equivalent    */
					/* point is inside the closed curve.  */

	double		dx,		/* Scale along X and Y of the above   */
			dy ;		/* mesh of points.		      */
	int		i_mesh, 	/* Index i and j onto mesh of points  */
			j_mesh ;	/* onto closed curve.		      */

	SetProc( VSfindTheMostInteriorPointToACurve ); Begin

	wkGeom = lnGeom = NULL ;

	/*
	 * See if the input curve is linear.
	 */
	if( vs$is_curve_linear( msg = msg, curveGeom = cvGeom ) ) {

		__DBGpr_com( "Curve is linear" ) ;

		BScveval( cvGeom, 0., 0, (IGRpoint *) ptAt0, &bsRC ) ;
		if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

		BScveval( cvGeom, 1., 0, (IGRpoint *) ptAt1, &bsRC ) ;
		if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

		VSmidpoint( ptAt0, ptAt1, point ) ;

		sts  = OM_S_SUCCESS ;
		*msg = MSSUCC ;
		goto wrapup ;
	}

	/*
	 * Close the input curve if it's not closed.
	 */
	if( !cvGeom->phy_closed ) {
		int	type ;

		__DBGpr_com( "Curve not closed -> close it" ) ;

		/*
		 * Find end points of input curve.
		 */
		BScveval( cvGeom, 0., 0, (IGRpoint *) ptAt0, &bsRC ) ;
		if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

		BScveval( cvGeom, 1., 0, (IGRpoint *) ptAt1, &bsRC ) ;
		if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

		/*
		 * Construct a line segment from first to last points of
		 * input curve.
		 */
		BSalloccv( 2,
			   2,
			   FALSE,
			   0,
			   &lnGeom,
			   &bsRC ) ;

		if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

		BSlngen( &bsRC, ptAt0, ptAt1, lnGeom, &type ) ;
		if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

		/*
		 * Merge the input curve and the above line segment.
		 */
		sts = VSallocForBSmerge_cv( msg, cvGeom, lnGeom, &wkGeom ) ;
		__CheckRC( sts, *msg, "VSallocForBSmerge_cv", wrapup ) ;

		BSmerge_cv( &bsRC, cvGeom, lnGeom, wkGeom ) ;
		if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

	} else {
		__DBGpr_com( "Curve is closed" ) ;
		wkGeom = cvGeom ;
	}

	/*
	 * Find points on closed curve.
	 */
	pm[0]		       = 0.0 ;
	pm[NB_PTS_ONTO_CV - 1] = 1.0 ;

	for( i=1; i<NB_PTS_ONTO_CV-1; i++ )
		pm[i] = pm[i-1] + 1.0/NB_PTS_ONTO_CV ;

		BScvarreval(	&bsRC,
				wkGeom,
				pm,
				NB_PTS_ONTO_CV,
				0,
				(double *) ptOnCv ) ;

	if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

	/*
	 * Find min-max box that contains the closed curve.
	 */
	num = NB_PTS_ONTO_CV ;

	BSbx2( &bsRC,
	       &num,
	       ptOnCv,
	       NULL,
	       min,
	       max ) ;

	if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

	__DBGpr_vec( "Min of box", min ) ;
	__DBGpr_vec( "Max of box", max ) ;

	/*
	 * Transform the closed curve to a mesh of points. Each member of
	 * this matrix can take 3 values which are :
	 *	0 : the point is on the closed curve.
	 *	1 : the point is inside the closed curve.
	 *	2 : the point is outside the closed curve.
	 */
	dx = ( max[0] - min[0] ) / ( NB_PTS_ALONG_X - 1 ) ;
	dy = ( max[1] - min[1] ) / ( NB_PTS_ALONG_Y - 1 ) ;

	__DBGpr_dbl( "1/dx", 1/dx ) ;
	__DBGpr_dbl( "1/dy", 1/dy ) ;

	for( i=0; i<NB_PTS_ALONG_Y; i++ )
		for( j=0; j<NB_PTS_ALONG_X; j++ ) mesh[i][j] = 1 ;

	/*
	 * Points on curve.
	 */
	for( i=0; i<NB_PTS_ONTO_CV; i++ ) {
		j_mesh = ( ptOnCv[i][0] - min[0] ) / dx ;
		i_mesh = ( ptOnCv[i][1] - min[1] ) / dy ;

		mesh[i_mesh][j_mesh] = 0 ;
	}

	/*
	 * Outside points. ( Per line, first point --> point on curve
	 * and last point --> point on curve ).
	 */
	for( i=0; i<NB_PTS_ALONG_Y; i++ ) {

		for( j=0; j<NB_PTS_ALONG_X; j++ ) {
			if( mesh[i][j] == 0 ) break ;
			mesh[i][j] = 2 ;
		}

		for( j=NB_PTS_ALONG_X-1; j>0; j-- ) {
			if( mesh[i][j] == 0 ||
			    mesh[i][j] == 2 ) break ;
			mesh[i][j] = 2 ;
		}
	}

	/*
	 * Outside points. ( Per column, first point --> point on curve
	 * and last point --> point on curve ).
	 */
	for( j=0; j<NB_PTS_ALONG_X; j++ ) {

		for( i=0; i<NB_PTS_ALONG_Y; i++ ) {
			if( mesh[i][j] == 0 ) break ;
			mesh[i][j] = 2 ;
		}

		for( i=NB_PTS_ALONG_Y-1; i>0; i-- ) {
			if( mesh[i][j] == 0 ) break ;
			mesh[i][j] = 2 ;
		}
	}

#ifdef vsDEBUG
	VSprintMesh( "Mesh of closed curve", mesh ) ;
#endif

	/*
	 * Find the most interior point using the mesh of points.
	 */
	for( i=0; i<NB_PTS_ALONG_Y; i++ )
		for( j=0; j<NB_PTS_ALONG_X; j++ )
			if( mesh[i][j] != 1 ) mesh[i][j] = 0 ;

	VSfindInteriorPointUsingMesh( mesh, &i, &j ) ;

	__DBGpr_int( "X index", j ) ;
	__DBGpr_int( "Y index", i ) ;

	point[0] = min[0] + j*dx ;
	point[1] = min[1] + i*dy ;
	point[2] = 0 ;

	__DBGpr_vec( "Most interior point", point ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( wkGeom && wkGeom != cvGeom ) BSfreecv( &bsRC, wkGeom ) ;
		if( lnGeom		       ) BSfreecv( &bsRC, lnGeom ) ;

		End
		return sts ;

} /* VSfindTheMostInteriorPointToACurve */
/*----------------------------------------------------------------------------*/
