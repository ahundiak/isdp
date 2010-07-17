/*
	I/STRUCT
*/
class implementation GRgraphics ;

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "bserr.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsvedef.h"
#include "vsgeommacros.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bsalloccv.h"
#include "bscvcvint.h"
#include "bscveval.h"
#include "bsfreecv.h"
#include "bspj_pt_cv.h"
#include "bsprj_cv_pl.h"
#include "vsdrwproto.h"
#include "vspratpt.h"
#include "vsvecmxproto.h"
#include "vsvisedproto.h"

extern long	VSdrwSfToWireFrame() ;
extern long	VSdrwIsPtHiddenBySf() ;

from EMSsurface import EMcrvsrfint ;


/*----------------------------------------------------------------------------*/
static long VSprjcvnpl0( msg, cv, normal, pj_cv )

long			*msg ;
struct IGRbsp_curve	*cv ;
double			*normal ;
struct IGRbsp_curve	**pj_cv ; {

	/*
	 * This function projects a curve ( cv ) onto a plane
	 * ( point = 0,0,0 normal = 'normal' ) and returns the projected
	 * curve ( pj_cv ).
	 *
	 * Note :
	 * ------
	 *	'*pj_cv' is allocated and must be freed by the caller with
	 *	the function BSfreecv().
	 */

	long		sts,	/* Completion code.		      */
			bsRC ;	/* BS return code.		      */
	IGRpoint	ptPl ;	/* Point on plane.		      */

	*pj_cv = NULL ;

	BSalloccv( cv->order,
		   cv->num_poles,
		   cv->rational,
		   cv->num_boundaries,
		   pj_cv,
		   &bsRC ) ;

	if( BSERROR( bsRC ) ) vs$mem_fail() ;

	ptPl[0] = ptPl[1] = ptPl[2] = 0. ;

	BSprj_cv_pl( &bsRC,
		     cv,
		     ptPl,
		     normal,
		     normal,
		     *pj_cv ) ;

	if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			BSfreecv( &bsRC, *pj_cv ) ;
			*pj_cv = NULL ;
		}
		return sts ;

} /* VSprjcvnpl0 */
/*----------------------------------------------------------------------------*/
static long VScvcvint( msg, cv0, cv1, nint, xint_pts )

long			*msg ;
struct IGRbsp_curve	*cv0,
			*cv1 ;
int			*nint ;
double			**xint_pts ; {

	/*
	 * This function intersects two curves ( cv0, cv1 ) and returns the
	 * number ( nint ) and intersection points ( int_pts ).
	 *
	 * Note :
	 * ------
	 *	'*xint_pnt' is allocated and must be freed by the caller with
	 *	free( *xint_pts ).
	 */

	long		sts,	    /* Completion code. 		      */
			bsRC ;	    /* BS return code.			      */
	int		nover ;     /* Number of overlap points.	      */
	short		alloc ;     /* Flag to indicate to BScvcvint to       */
				    /* allocate memory. 		      */
	double		*xpar0,     /* Parameter of intersection points on    */
				    /* curve #0.			      */
			*xpar1,     /* Parameter of intersection points on    */
				    /* curve #1.			      */
			*xend_pts,  /* Overlap points.			      */
			*xover0,    /* Parameter of overlap points on cv #0.  */
			*xover1 ;   /* Parameter of overlap points on cv #1.  */

	*nint	  = 0 ;
	*xint_pts = NULL ;

	xpar0 = xpar1 = xend_pts = xover0 = xover1 = NULL ;

	alloc = TRUE ;

	BScvcvint( cv0,
		   cv1,
		   TRUE,
		   0,
		   0,
		   NULL,
		   NULL,
		   NULL,
		   NULL,
		   NULL,
		   NULL,
		   nint,
		   &nover,
		   &alloc,
		   &alloc,
		   (IGRpoint **) xint_pts,
		   &xpar0,
		   &xpar1,
		   (IGRpoint **) &xend_pts,
		   &xover0,
		   &xover1,
		   &bsRC ) ;

	if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			_FREE( *xint_pts ) ;
			*nint	  = 0 ;
			*xint_pts = NULL ;
		}

		_FREE( xpar0	) ;
		_FREE( xpar1	) ;
		_FREE( xend_pts ) ;
		_FREE( xover0	) ;
		_FREE( xover1	) ;

		return sts ;

} /* VScvcvint */
/*----------------------------------------------------------------------------*/
long VSveFindHiddenPartsOfCurveWithSurface( msg, cvId, cvEnv, sfId, sfEnv,
					    viewVector, nb_part, part_pt_s,
					    part_pt_e, part_pm_s, part_pm_e )

long		*msg ;
struct GRid	*cvId ;
struct GRmd_env *cvEnv ;
struct GRid	*sfId ;
struct GRmd_env *sfEnv ;
IGRvector	viewVector ;
int		*nb_part ;
double		**part_pt_s,
		**part_pt_e,
		**part_pm_s,
		**part_pm_e ; {

	/*
	 * Given a curve ( cvId, cvEnv ) and a surface ( sfId, sfEnv ), this
	 * function returns the number of parts which are hidden by the surface
	 * with respect to view vector ( nb_part ), the start point
	 * ( part_pt_s ) and corresponding parameter ( part_pm_s ), the end
	 * point ( part_pt_e ) and corresponding parameter ( part_pm_e ) of
	 * each part.
	 *
	 *
	 *			    View vector.
	 *				|
	 *				v
	 *
	 *			 -------------------------
	 *			/			/ <- Surface.
	 *		       /     --------	       /
	 *		      /     /	   /	      /
	 *		     *	   *	  *	     *
	 *		    /.	  /.	 /.	    /.
	 *		   / .	 -------- .	   / .
	 *		  /  .	   .	  .	  /  .
	 *		 -------------------------   .
	 *		     .	   .	  .	     .
	 *		     .	   .	  .	     .
	 *		     .	   .	  .	     .
	 *		     .	   .	  .	     .
	 *	   --->------*-----*------*----------*------ <- Curve.
	 *	      ^      A	   B	  C	     D
	 *	      |
	 *	   Orientation
	 *	   of curve.
	 *
	 * Here, we have 2 parts ( nb_part = 2 ).
	 *
	 * Part #1 :
	 * =========
	 * part_pt_s[0] = A	( with part_pm_s[0] ).
	 * part_pt_e[0] = B	( with part_pm_e[0] ).
	 *
	 * Part #2 :
	 * =========
	 * part_pt_s[1] = C	( with part_pm_s[1] ).
	 * part_pt_e[1] = D	( with part_pm_e[1] ).
	 *
	 */

	long			sts,		/* Completion code.	      */
				bsRC ;		/* BS return code.	      */
	GRrange 		cvRange,	/* Range of curve.	      */
				sfRange,	/* Range of surface.	      */
				wfRange ;	/* Range of a wireframe.      */
	int			i,		/* Loop index.		      */
				j,		/* Loop index.		      */
				k,		/* Loop index.		      */
				relationship,	/* Relation ship between two  */
						/* ... ranges.		      */
				npartPt,	/* Number of part points.     */
				nintCvWf,	/* Number of intersection     */
						/* points between input curve */
						/* and a wireframe all two    */
						/* projected onto a plane.    */
				npartEval,	/* Number of parts evaluated. */
				istart, 	/* Indexes of start and end   */
				iend,		/* points of a part.	      */
				partHidden ;	/* Part hidden ? TRUE / FALSE.*/
	long			nptpjCv ;	/* Number of points projected */
						/* onto input curve.	      */
	double			*partPt,	/* Part points. 	      */
				*partPm,	/* Parameters of part points. */
				*intptCvWf,	/* Intersection points	      */
						/* between input curve and a  */
						/* wireframe all two projected*/
						/* onto a plane.	      */
				*ptpjCv,	/* Points projected onto      */
						/* input curve. 	      */
				*pmpjCv ;	/* Parameters of the above    */
						/* points onto curve.	      */
	IGRpoint		partMiddle ;	/* Middle point of a part.    */
	short			world ; 	/* Compute range in world     */
						/* coordinate.		      */
	struct IGRbsp_curve	*cvGeom,	/* Geometry of curve.	      */
				*pjCvGeom,	/* Geometry of input curve    */
						/* projected onto a plane.    */
				*wfGeom,	/* Geometry of a wireframe.   */
				*pjWfGeom ;	/* Geometry of a wireframe    */
						/* projected onto a plane.    */
	struct GRvg_construct	wfCst ; 	/* Construction list for      */
						/* surface's wireframes.      */
	int			wfCount ;	/* Count of surface's	      */
						/* wireframes.		      */
	struct GRid		*wfList ;	/* List of surface's	      */
						/* wireframes.		      */

	struct IGRdisplay	dis;		/* dummy variable	      */


	SetProc( VSveFindHiddenPartsOfCurveWithSurface ); Begin

	*nb_part   = 0 ;
	*part_pt_s = *part_pt_e = *part_pm_s = *part_pm_e = NULL ;

	npartPt    = 0 ;
	partPt	   = partPm = NULL ;

	nintCvWf   = 0 ;
	intptCvWf  = NULL ;

	nptpjCv    = 0 ;
	ptpjCv	   = pmpjCv = NULL ;

	cvGeom	   = pjCvGeom = wfGeom = pjWfGeom = NULL ;

	wfCount    = 0 ;
	wfList	   = NULL ;

	__DBGpr_obj( "Curve", *cvId   ) ;
	__DBGpr_obj( "Surface", *sfId ) ;

	/*
	 * Get range of curve.
	 */
	world = TRUE ;

	sts = om$send( msg	= message GRgraphics.GRgetrang(
							   msg,
							   &cvEnv->_MATRIX_TYPE,
							   cvEnv->_MATRIX,
							   &world,
							   cvRange ),
		       senderid = cvId->objid,
		       targetid = cvId->objid,
		       targetos = cvId->osnum ) ;

	__CheckRC( sts, *msg, "GRgraphics.GRgetrang", wrapup ) ;

	__DBGpr_vec( "Min range of curve  ", cvRange	 ) ;
	__DBGpr_vec( "Max range of curve  ", cvRange + 3 ) ;

	/*
	 * Get range of surface.
	 */
	sts = om$send( msg	= message GRgraphics.GRgetrang(
							   msg,
							   &sfEnv->_MATRIX_TYPE,
							   sfEnv->_MATRIX,
							   &world,
							   sfRange ),
		       senderid = sfId->objid,
		       targetid = sfId->objid,
		       targetos = sfId->osnum ) ;

	__CheckRC( sts, *msg, "GRgraphics.GRgetrang", wrapup ) ;

	__DBGpr_vec( "Min range of surface", sfRange	 ) ;
	__DBGpr_vec( "Max range of surface", sfRange + 3 ) ;

	/*
	 * See if the curve's range is not hidden by the surface's range
	 * ( That means the curve is not hidden by the surface ).
	 */
	sts = VSveRangeRangeRelationShip( msg,
					  sfRange,	      /* Range #0 */
					  cvRange,	      /* Range #1 */
					  viewVector,
					  &relationship ) ;

	__CheckRC( sts, *msg, "VSveRangeRangeRelationShip", wrapup ) ;

	if( relationship == VS_K_0_IN_FRONT_OF_1 ||
	    relationship == VS_K_0_AT_THE_BACK_OF_1 ) {
		__DBGpr_com( "Curve is NOT HIDDEN by surface" ) ;
		goto wrapup ;
	}

	/*
	 * Get geometry of curve.
	 */
	sts = vs$get_geometry( msg	= msg,
			       grobjId	= cvId,
			       grobjEnv = cvEnv,
			       geometry = &cvGeom ) ;

	__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

	/*
	 * If the curve's range intersects the surface's range, find
	 * intersection points between the curve and surface, if any.
	 */
	if( relationship == VS_K_INTERSECT ) {
		long	num_alloc = 0,
			num_int   = 0 ; /* WARNING : Should bet set to 0      */
					/* before call of EMcrvsrfint.	      */

		__DBGpr_com( "Curve's range intersects the surface's range" ) ;

		/*
		 * Intersect curve and surface.
		 */
		sts = om$send( msg	= message EMSsurface.EMcrvsrfint(
								 msg,
								 NULL,
								 &sfEnv->md_env,
								 cvGeom,
								 NULL,
								 NULL,
								 FALSE,
								 &num_alloc,
								 &num_int,
								 NULL,
								 NULL,
								 NULL,
								 &partPt,
								 NULL ),
			       senderid = sfId->objid,
			       targetid = sfId->objid,
			       targetos = sfId->osnum ) ;

		__CheckRC( sts, *msg, "EMSsurface.EMcrvsrfint", wrapup ) ;

		npartPt = num_int ;
		__DBGpr_int( "Number of intersection points", npartPt ) ;

		/*
		 * Find parameter of intersection points onto curve.
		 */
		if( npartPt ) {
			if( !( partPm = _MALLOC( npartPt, double ) ) )
				vs$mem_fail() ;

			for( i=0; i<npartPt; i++ ) {
				sts = VSpratpt( msg,
						cvEnv,
						cvId->objid,
						partPt +3*i,
						partPm +i ) ;

				__CheckRC( sts, *msg, "VSpratpt", wrapup ) ;
			}
		}
	}

	/*
	 * Get wireframes of surface.
	 */
	vs$fill_cnst_list( Env_info  = sfEnv,
			   Level     = NULL,
			   Display   = NULL,
			   Cnst_list = wfCst ) ;
	wfCst.display = &dis;

	sts = VSdrwSfToWireFrame( msg,
				  sfId,
				  sfEnv,
				  &wfCst,
				  &wfCount,
				  &wfList ) ;

	__CheckRC( sts, *msg, "VSdrwSfToWireFrame", wrapup ) ;

	__DBGpr_int( "Count of surface's wireframes", wfCount ) ;
	__DBGpr_objlist( "Wireframe", wfCount, wfList ) ;

	/*
	 * Project input curve normal to plane ( Point = 0,0,0	Normal = view
	 * vector ).
	 */
	sts = VSprjcvnpl0( msg, cvGeom, viewVector, &pjCvGeom ) ;

	__CheckRC( sts, *msg, "VSprjcvnpl0", wrapup ) ;

	/*
	 * For each wireframes which hides the curve ( test only on range ),
	 * project wireframe onto plane and intersect the result with the
	 * input curve projected. Then, project intersection points onto
	 * input curve.
	 */
	for( i=0; i<wfCount; i++ ) {
		__DBGpr_obj( "Wireframe", wfList[i] ) ;

		/*
		 * Get range of wireframe.
		 */
		sts = om$send( msg	= message GRgraphics.GRgetrang(
							   msg,
							   &sfEnv->_MATRIX_TYPE,
							   sfEnv->_MATRIX,
							   &world,
							   wfRange ),
			       senderid = wfList[i].objid,
			       targetid = wfList[i].objid,
			       targetos = wfList[i].osnum ) ;

		__CheckRC( sts, *msg, "GRgraphics.GRgetrang", wrapup ) ;

		__DBGpr_vec( "\tmin of range", wfRange	  ) ;
		__DBGpr_vec( "\tmax of range", wfRange +3 ) ;

		/*
		 * See if the wireframe's range hides the curve's range.
		 */
		sts = VSveRangeRangeRelationShip( msg,
						  wfRange,	/* Range #0 */
						  cvRange,	/* Range #1 */
						  viewVector,
						  &relationship ) ;

		__CheckRC( sts, *msg, "VSveRangeRangeRelationShip", wrapup ) ;

		if( relationship == VS_K_0_IN_FRONT_OF_1 ||
		    relationship == VS_K_0_AT_THE_BACK_OF_1 ) {
			__DBGpr_com( "\tdo NOT hide curve" ) ;
			continue ;
		}

		/*
		 * Get geometry of wireframe.
		 */
		sts = vs$get_geometry( msg	= msg,
				       grobjId	= wfList +i,
				       grobjEnv = sfEnv,
				       geometry = &wfGeom ) ;

		__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

		/*
		 * Project wireframe normal to plane ( Point = 0,0,0 Normal
		 * = view vector ).
		 */
		sts = VSprjcvnpl0( msg, wfGeom, viewVector, &pjWfGeom ) ;

		__CheckRC( sts, *msg, "VSprjcvnpl0", wrapup ) ;

		/*
		 * Intersect the wireframe projected with the input curve
		 * projected.
		 */
		sts = VScvcvint( msg,
				 pjCvGeom,
				 pjWfGeom,
				 &nintCvWf,
				 &intptCvWf ) ;

		__CheckRC( sts, *msg, "VScvcvint", wrapup ) ;

		__DBGpr_int( "\tnumber of intersection points", nintCvWf ) ;

		/*
		 * Project intersection points onto input curve and add points
		 * to list of part points.
		 */
		if( nintCvWf ) {
			for( j=0; j<nintCvWf; j++ ) {
				__DBGpr_vec( "\tintersection point",
					     intptCvWf +3*j ) ;

				BSpj_pt_cv( cvGeom,
					    intptCvWf +3*j,
					    viewVector,
					    &nptpjCv,
					    (IGRpoint **) &ptpjCv,
					    &pmpjCv,
					    &bsRC ) ;

				if( BSERROR( bsRC ) )
					vs$error( msgval = EMS_E_BSerror ) ;

				__DBGpr_int( "\tnumber of projection points",
					     nptpjCv ) ;

				if( !nptpjCv ) continue ;
#ifdef vsDEBUG
				for( k=0; k<nptpjCv; k++ ) {
					__DBGpr_vec( "\tprojection point",
						     ptpjCv +3*k ) ;
					__DBGpr_dbl( "\tparameter",
						     pmpjCv[k] ) ;
				}
#endif
				/*
				 * Add projection points to list of part points.
				 */
				if( npartPt ) {
					partPt = _REALLOC( partPt,
							   3*(nptpjCv+npartPt),
							   double ) ;
					if( !partPt ) vs$mem_fail() ;

					partPm = _REALLOC( partPm,
							   nptpjCv+npartPt,
							   double ) ;
					if( !partPm ) vs$mem_fail() ;
				} else {
					partPt = _MALLOC( 3*nptpjCv,
							  double ) ;
					if( !partPt ) vs$mem_fail() ;

					partPm = _MALLOC( nptpjCv,
							  double ) ;
					if( !partPm ) vs$mem_fail() ;
				}

				for( k=0; k<nptpjCv; k++ ) {
					VSvccpy( partPt +3*(npartPt+k),
						 ptpjCv +3*k ) ;
					partPm[npartPt+k] = pmpjCv[k] ;
				}

				npartPt += nptpjCv ;

				_FREE( ptpjCv ) ; ptpjCv = NULL ;
				_FREE( pmpjCv ) ; pmpjCv = NULL ;
				nptpjCv = 0 ;
			}

		_FREE( intptCvWf ) ; intptCvWf = NULL ;
		nintCvWf = 0 ;
		}

		_FREE( wfGeom ) ; wfGeom = NULL ;
		if( pjWfGeom ) {
			BSfreecv( &bsRC, pjWfGeom ) ;
			pjWfGeom = NULL ;
		}
	}

	/*
	 * Add end points of curve to list of part points.
	 */
	if( !npartPt ) {
		npartPt = 2 ;

		if( !( partPt = _MALLOC( 3*npartPt, double ) ) ||
		    !( partPm = _MALLOC( npartPt,   double ) ) )
			vs$mem_fail() ;
	} else {
		npartPt += 2 ;

		if( !( partPt = _REALLOC( partPt, 3*npartPt, double ) ) ||
		    !( partPm = _REALLOC( partPm, npartPt,   double ) ) )
			vs$mem_fail() ;
	}

	partPm[npartPt-2] = 0. ;
	BScveval( cvGeom, 0., 0, (IGRpoint *) (partPt + 3*(npartPt-2)), &bsRC );
	if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

	partPm[npartPt-1] = 1. ;
	BScveval( cvGeom, 1., 0, (IGRpoint *)( partPt + 3*(npartPt-1)), &bsRC );
	if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

#ifdef vsDEBUG
	__DBGpr_int( "Number of part points", npartPt ) ;
	__DBGpr_com( "List of part points" ) ;
	__DBGpr_com( "-------------------" ) ;
	for( i=0; i<npartPt; i++ ) {
		__DBGpr_int( "number", i	    ) ;
		__DBGpr_vec( "\tpoint", partPt +3*i ) ;
		__DBGpr_dbl( "\tpm   ", partPm[i]   ) ;
	}
	__DBGpr_com( "-------------------" ) ;
#endif

	/*
	 * Allocate memory for output lists.
	 */
	npartEval = (int) ceil( (double) npartPt * 0.5 ) ;

	__DBGpr_int( "Number of parts evaluated", npartEval ) ;

	if( !( *part_pt_s = _MALLOC( 3*npartEval, double ) ) ||
	    !( *part_pt_e = _MALLOC( 3*npartEval, double ) ) ||
	    !( *part_pm_s = _MALLOC( npartEval,   double ) ) ||
	    !( *part_pm_e = _MALLOC( npartEval,   double ) ) ) vs$mem_fail() ;

	/*
	 * Find hidden parts.
	 */
	istart = npartPt-2 ;
	iend   = npartPt-1 ;

	while( istart != iend ) {
		/*
		 * Find end point of a part ( first point bigger than start
		 * point ).
		 */
		for( i=0; i<npartPt; i++ ) {
			if( partPm[i] <= partPm[istart] ||
			    partPm[i] >  partPm[iend]	) continue ;
			iend = i ;
		}

		__DBGpr_int( "Start", istart	) ;
		__DBGpr_int( "End  ", iend	) ;
		__DBGpr_com( "Is part hidden ?" ) ;

		/*
		 * See if middle point of part is hidden.
		 */
		BScveval( cvGeom,
			  (partPm[istart] + partPm[iend]) * 0.5,
			  0,
			  (IGRpoint *) partMiddle,
			  &bsRC ) ;

		if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

		sts = VSdrwIsPtHiddenBySf( msg,
					   sfId,
					   sfEnv,
					   partMiddle,
					   viewVector,
					   &partHidden ) ;

		__CheckRC( sts, *msg, "VSdrwIsPtHiddenBySf", wrapup ) ;

		if( partHidden ) {
			__DBGpr_com( "\t-> Yes" ) ;

			if( *nb_part					&&
			    (*part_pm_e)[*nb_part -1] == partPm[istart] ) {
				VSvccpy( *part_pt_e +3*(*nb_part -1),
					 partPt +3*iend ) ;
				(*part_pm_e)[*nb_part -1] = partPm[iend] ;
			} else {
				VSvccpy( *part_pt_s +3*(*nb_part),
					 partPt +3*istart ) ;
				(*part_pm_s)[*nb_part] = partPm[istart] ;

				VSvccpy( *part_pt_e +3*(*nb_part),
					 partPt +3*iend   ) ;
				(*part_pm_e)[*nb_part] = partPm[iend]	;

				(*nb_part)++ ;
			}

		} else __DBGpr_com( "\t-> No" ) ;

		istart = iend ;
		iend   = npartPt-1 ;
	}

#ifdef vsDEBUG
	__DBGpr_int( "Number of hidden parts", *nb_part ) ;
	__DBGpr_com( "List of hidden parts" ) ;
	__DBGpr_com( "--------------------" ) ;
	for( i=0; i<*nb_part; i++ ) {
		__DBGpr_int( "number", i		) ;
		__DBGpr_vec( "\tstart", *part_pt_s +3*i ) ;
		__DBGpr_dbl( "\tpm   ", (*part_pm_s)[i] ) ;
		__DBGpr_vec( "\t\tend", *part_pt_e +3*i ) ;
		__DBGpr_dbl( "\t\tpm ", (*part_pm_e)[i] ) ;
	}
	__DBGpr_com( "--------------------" ) ;
#endif

	/*
	 * If no hidden parts were found, the curve is not hidden by the
	 * surface.
	 */
	if( !(*nb_part) ) {
		__DBGpr_com( "Curve is NOT HIDDEN by surface" ) ;

		_FREE( *part_pt_s ) ; *part_pt_s = NULL ;
		_FREE( *part_pt_e ) ; *part_pt_e = NULL ;
		_FREE( *part_pm_s ) ; *part_pm_s = NULL ;
		_FREE( *part_pm_e ) ; *part_pm_e = NULL ;
	}

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			_FREE( *part_pt_s ) ; *part_pt_s = NULL ;
			_FREE( *part_pt_e ) ; *part_pt_e = NULL ;
			_FREE( *part_pm_s ) ; *part_pm_s = NULL ;
			_FREE( *part_pm_e ) ; *part_pm_e = NULL ;
			*nb_part = 0 ;
		}

		vs$bulk_delete( count  = wfCount,
				grids  = wfList,
				theEnv = sfEnv ) ;

		_FREE( partPt	 ) ;
		_FREE( partPm	 ) ;
		_FREE( intptCvWf ) ;
		_FREE( ptpjCv	 ) ;
		_FREE( pmpjCv	 ) ;
		_FREE( cvGeom	 ) ;
		_FREE( wfGeom	 ) ;
		_FREE( wfList	 ) ;
		if( pjCvGeom ) BSfreecv( &bsRC, pjCvGeom ) ;
		if( pjWfGeom ) BSfreecv( &bsRC, pjWfGeom ) ;

		End
		return sts ;

} /* VSveFindHiddenPartsOfCurveWithSurface */
/*----------------------------------------------------------------------------*/

end implementation GRgraphics ;
