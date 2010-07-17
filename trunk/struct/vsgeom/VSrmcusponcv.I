/*
	I/STRUCT
*/
class implementation GRcurve ;

#include <stdio.h>
#include "bserr.h"
#include "bsparameters.h"
#include "EMSmsgdef.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"

/*
 * Includes of function prototypes.
 */
#include "bsfndcvcsp.h"
#include "bscveval.h"
#include "bsmkvec.h"
#include "bsnorvec.h"
#include "bsalloccv.h"
#include "bscv_copy.h"
#include "bsfreecv.h"
#include "bsinspolcv2.h"
#include "bsmdelpolcv.h"
#include "vsvecmxproto.h"

#define SCALE_FACTOR		1000.	/* Scale of translation used with the */
					/* minimum length of vector.	      */

/*----------------------------------------------------------------------------*/
long VSremoveAllCuspsOnCurve( msg, cvEnv, cvId )

long		*msg ;
struct GRmd_env *cvEnv ;
struct GRid	*cvId ; {

	/*
	 * This function removes all cusp points ( if any ) on a curve of order
	 * 3 or 4 by :
	 * 1) Inserting new poles closed to the cusp points.
	 * 2) Removing all cusps on the curve.
	 *
	 *	\
	 *	 \
	 *	  \ c				c : cusp point.
	 *	   .-----------------
	 *
	 *		|
	 *		v
	 *
	 *	\
	 *	 .p1
	 *	  \   p2			p1, p2 : new poles closed
	 *	   ---.--------------			 to cusp point c
	 *						 which is removed.
	 */

	long			sts,	     /* OM return code. 	      */
				bsRC ;	     /* BS return code. 	      */
	struct IGRbsp_curve	*cvGeom,     /* Geometry of input curve.      */
				*nvGeom ;    /* New geometry of curve.	      */
	int			i,	     /* Loop index.		      */
				j,	     /* Loop index.		      */
				nb_cusp,     /* Number of cusp points.	      */
				nb_poles ;   /* Number of poles to insert.    */
	double			*pm_cusp,    /* Parameters where cusp points  */
					     /* are.			      */
				pt_cusp[3],  /* Cusp point.		      */
				*new_poles,  /* New poles to insert.	      */
				tollenvec,   /* Minimum length of vector.     */
				trlDir[3] ;  /* Direction of translation.     */
	struct GRpost_info	post_info ;  /* Processing information.       */

	SetProc( VSremoveAllCuspsOnCurve ) ; Begin

	BSEXTRACTPAR( msg, BSTOLLENVEC, tollenvec ) ;

	cvGeom	= NULL ;
	nvGeom	= NULL ;

	pm_cusp = NULL ;
	nb_cusp = 0 ;

	new_poles = NULL ;
	nb_poles  = 0 ;

	__DBGpr_obj( "Curve", *cvId ) ;

	/*
	 * Get geometry of curve.
	 */
	sts = vs$get_geometry( msg	= msg,
			       grobjId	= cvId,
			       grobjEnv = cvEnv,
			       geometry = &cvGeom ) ;

	__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

	/*
	 * See if order is 3 or 4.
	 */
	if( cvGeom->order < 3 ) {
		__DBGpr_com( "Curve NOT order 3 or 4" ) ;

		sts  = OM_S_SUCCESS ;
		*msg = MSSUCC ;

		goto wrapup ;
	}

	__DBGpr_int( "Number of poles", cvGeom->num_poles ) ;

	/*
	 * Find cusps on curve.
	 */
	if( !( pm_cusp = _MALLOC( cvGeom->num_poles - cvGeom->order +1,
				  double ) ) )
		vs$mem_fail() ;

	BSfndcvcsp( cvGeom,
		    &nb_cusp,
		    pm_cusp,
		    &bsRC ) ;

	if( BSERROR( bsRC ) ) {
		__DBGpr_com( "ERROR in finding cusp points" ) ;
		vs$error( msgval = EMS_E_BSerror ) ;
	}

	__DBGpr_int( "Number of cusp points", nb_cusp ) ;

	if( !nb_cusp ) {
		__DBGpr_com( "No cusps to remove" ) ;

		sts  = OM_S_SUCCESS ;
		*msg = MSSUCC ;

		goto wrapup ;
	}

	/*
	 * Find new poles to insert.
	 */
	if( !( new_poles = _MALLOC( 2*3*nb_cusp, double ) ) )
		vs$mem_fail() ;

	for( i=0; i<nb_cusp; i++ ) {
		__DBGpr_dbl( "Parameter of cusp point", pm_cusp[i] ) ;

		BScveval( cvGeom,
			  pm_cusp[i],
			  0,
			  (IGRpoint *) pt_cusp,
			  &bsRC ) ;

		if( BSERROR( bsRC ) ) {
			__DBGpr_com( "ERROR in evaluation of cusp point" ) ;
			vs$error( msgval = EMS_E_BSerror ) ;
		}

		__DBGpr_vec( "Point cusp", pt_cusp ) ;

		for( j=0; j<cvGeom->num_poles; j++ )
			if( VSeqPoints( pt_cusp, cvGeom->poles + 3*j ) )
				break ;

		if( j == cvGeom->num_poles ) {
			__DBGpr_com( "Cusp point is NOT a pole !!!" ) ;
			continue ;
		}

		if( j > 0 ) {
			__DBGpr_vec( "\tPole before cusp point",
				     cvGeom->poles +3*(j-1) ) ;

			BSmkvec( &bsRC,
				 trlDir,
				 pt_cusp,
				 cvGeom->poles +3*(j-1) ) ;

			BSnorvec( &bsRC, trlDir ) ;

			VSscalvc( SCALE_FACTOR * tollenvec, trlDir, trlDir ) ;

			new_poles[3*nb_poles +0] = pt_cusp[0] + trlDir[0] ;
			new_poles[3*nb_poles +1] = pt_cusp[1] + trlDir[1] ;
			new_poles[3*nb_poles +2] = pt_cusp[2] + trlDir[2] ;

			__DBGpr_vec( "\t\tNew pole", new_poles + 3*nb_poles ) ;

			nb_poles++ ;
		}

		if( j < cvGeom->num_poles ) {
			__DBGpr_vec( "\tPole after cusp point",
				     cvGeom->poles +3*(j+1) ) ;

			BSmkvec( &bsRC,
				 trlDir,
				 pt_cusp,
				 cvGeom->poles +3*(j+1) ) ;

			BSnorvec( &bsRC, trlDir ) ;

			VSscalvc( SCALE_FACTOR * tollenvec, trlDir, trlDir ) ;

			new_poles[3*nb_poles +0] = pt_cusp[0] + trlDir[0] ;
			new_poles[3*nb_poles +1] = pt_cusp[1] + trlDir[1] ;
			new_poles[3*nb_poles +2] = pt_cusp[2] + trlDir[2] ;

			__DBGpr_vec( "\t\tNew pole", new_poles + 3*nb_poles ) ;

			nb_poles++ ;
		}
	}

	/*
	 * Insert new poles without changing the shape of the curve.
	 */
	BSalloccv( cvGeom->order,
		   cvGeom->num_poles,
		   cvGeom->rational,
		   cvGeom->num_boundaries,
		   &nvGeom,
		   &bsRC ) ;

	if( BSERROR( bsRC ) ) {
		__DBGpr_com( "ERROR in allocating memory ( BSalloccv )" ) ;
		vs$error( msgval = EMS_E_BSerror ) ;
	}

	BScv_copy( &bsRC,
		   cvGeom,
		   nvGeom ) ;

	if( BSERROR( bsRC ) ) {
		__DBGpr_com( "ERROR in copying curve" ) ;
		vs$error( msgval = EMS_E_BSerror ) ;
	}

	for( i=0; i<nb_poles; i++ ) {

		BSinspolcv2( new_poles + 3*i,
			     nvGeom,
			     &bsRC ) ;

		if( BSERROR( bsRC ) ) {
			__DBGpr_vec( "ERROR in inserting new pole", new_poles + 3*i ) ;
			vs$error( msgval = EMS_E_BSerror ) ;
		}
	}

	/*
	 * Remove cusp points, if still here.
	 */
	BSmdelpolcv( 1, nvGeom, &bsRC ) ;

	if( BSERROR( bsRC ) ) {
		__DBGpr_com( "ERROR in removing cusp points" ) ;
		vs$error( msgval = EMS_E_BSerror ) ;
	}

	/*
	 * Change geometry of curve.
	 */
	post_info.construct_flag = FALSE ;

	sts = om$send( msg	= message GRcurve.GRpostabsg( msg,
							      cvEnv,
							      &post_info,
							      (char *) nvGeom,
							      &cvId->objid ),
		       senderid = NULL_OBJID,
		       targetid = cvId->objid,
		       targetos = cvId->osnum ) ;

	__CheckRC( sts, *msg, "GRcurve.GRpostabsg", wrapup ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		_FREE( cvGeom	 ) ;
		_FREE( pm_cusp	 ) ;
		_FREE( new_poles ) ;

		if( nvGeom ) BSfreecv( &bsRC, nvGeom ) ;

		End
		return sts ;

} /* VSremoveAllCuspsOnCurve */
/*----------------------------------------------------------------------------*/

end implementation GRcurve ;
