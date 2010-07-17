/*
	I/STRUCT
*/
class implementation EMSsubbs ;

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "OMmacros.h"
#include "bserr.h"
#include "bstypes.h"
#include "bsparameters.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsglobalmsg.h"
#include "vsdatamacros.h"
#include "vsgeommacros.h"
#include "vsiomacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bsarclength.h"
#include "bschangepar.h"
#include "bschtptstcv.h"
#include "bscveval.h"
#include "bsdistptpt.h"
#include "bsdistptpts.h"
#include "bsdividecv.h"
#include "bsdotp.h"
#include "bsmkvec.h"
#include "bsnorvec.h"
#include "bspj_pt_sf.h"
#include "bssfevaln.h"
#include "vsvecmxproto.h"

#define FACTOR 1000.
/*----------------------------------------------------------------------------*/
%safe
static int VSstrokeLineString(	long			*msg,
				struct IGRbsp_curve	*lineStr,
				int			*numPts,
				IGRpoint		**points,
				double			**params ) {

	double	arcTol ;
	int	i ;

	BSEXTRACTPAR( msg, BSTOLARCLEN, arcTol ) ;
	arcTol *= FACTOR ;

	*numPts = 0 ; *params = NULL ; *points = NULL ;

	{
	  double	t0 = 0. ;
	  double	t1 = 1. ;
	  double	length ;

	  BSarclength( msg, lineStr, &t0, &t1, &length ) ;
          if( BSOKAY( *msg ) ) {
	    *numPts = (int) ( length / arcTol ) ;

	    if( *params = _MALLOC( *numPts, double ) ) {
	      BSdividecv( msg, lineStr, &t0, &t1, numPts, *params ) ;

              if( BSOKAY( *msg ) ) {
	        if( *points = _MALLOC( *numPts, IGRpoint ) ) {

	          for( i = 0 ; i < *numPts ; i++ ) {
 	             BScveval( lineStr, (*params)[i], 0,
	                       (IGRpoint *) (*points)[i], msg ) ;
	          }
	        } else *msg = BSFAIL ;
	      } else *msg = BSFAIL ;
	    }
	  }
	}

	if( !BSOKAY( *msg ) ) {
		_FREE( *params ) ; _FREE( *points ) ;
		*numPts = 0 ; *params = NULL ; *points = NULL ;
	}
	return BSOKAY( *msg ) ;

} /* VSstrokeLineString */
%endsafe
/*----------------------------------------------------------------------------*/
long VSdetectGapBeyondTolBtwSfs(	long			*msg,
					const struct GRid	*sf1Id,
					const struct GRmd_env	*sf1Env,
					const struct GRid	*sf2Id,
					const struct GRmd_env	*sf2Env,
					double			gap,
					struct GRvg_construct	*cst,
					int			maxMarkers,
					struct GRid		markers[],
					int			*count,
					double			*maxGap ) {
	
	/*
	 * Compares the distances of isoparametric curves of one surface sf1 to
	 * another surface sf2 along a the normals to sf1 along the iso curve:
	 *
	 *  ^      sf1  ----------    .        
	 *  |                     .            
	 *  | distances         .              
	 *  |               . .                
	 *  V      sf2  . .
	 *
	 * and flags the portions of these curves where the gap is bigger
	 * that a given value with markers. A marker is just a line string
	 * delimitting a portion of isoparametric curve:
	 *            ---------             ---
	 *      -----/       | \-----------/   \---- sf1
	 *           |       | --  |     ||     |
	 *      -----|-------|/  \-|     ||-----|--- sf2
	 *           |       |     |\---/||     |
	 *           |       |     |     ||     |
	 *           +-------+     +-----++-----+
	 *             marker
	 *
	 * The isoparametric curves at U=0 and U=1 are treated.
	 */

	long			sts ;
	struct IGRbsp_surface	*sf1Geom	= NULL ;
	struct IGRbsp_surface	*sf2Geom	= NULL ;
	int			nbPoints	= 0 ;
	double			*params 	= NULL ;
	IGRpoint		*points 	= NULL ;
	int			i ;
	int			imarker		= 0 ;
	int			inZone	;
	int			createMark	= FALSE ;
	double			sqrGap		= gap * gap ;
	double			maxSqrGap	= 0. ;
	double			Upar		= 0. ;
	IGRpoint		begPoint ;
	IGRpoint		endPoint ;
	IGRvector		begNorml ;
	IGRvector		endNorml ;
	IGRvector		verticalUp ;
	struct IGRpolyline	lineString ;
	IGRpoint		lsPnts[4] ;
	struct GRvg_construct	lsCst ;
	extern OMuword		OPP_GR3dlinestr_class_id ;

	vs$dotsInStsFld( dots = 1, msgnum = VS_gI_AnalyzingStfPltGaps ) ;

	*count = 0 ; *maxGap = 0. ;

	verticalUp[0] = 0 ; verticalUp[1] = 0 ; verticalUp[2] = 1 ;

	vs$fill_cnst_list(	Msg		= cst->msg,
				Env_info	= cst->env_info,
				Display		= cst->display,
				Level		= cst->level,
				Properties	= cst->properties,
				Geometry	= &lineString,
				Cnst_list	= lsCst ) ;

	lineString.num_points	= 4 ;
	lineString.points	= (double*) lsPnts ;

	sts = vs$get_geometry( msg	= msg,
			       grobjId	= sf1Id,
			       grobjEnv = sf1Env,
			       geometry = &sf1Geom ) ;
	__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

	vs$dotsInStsFld( msgnum = VS_gI_AnalyzingStfPltGaps ) ;
	sts = vs$get_geometry( msg	= msg,
			       grobjId	= sf2Id,
			       grobjEnv = sf2Env,
			       geometry = &sf2Geom ) ;
	__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

	vs$dotsInStsFld( msgnum = VS_gI_AnalyzingStfPltGaps ) ;

	for( Upar = 0. ; Upar <= 1. ; Upar += 1. ) {
	  {
	    OM_S_OBJID	*isosAtU ;	/* Isos at U		*/
	    long	nbCrvs ;	/* # of isos at U	*/

	    isosAtU	= NULL ;
	    nbCrvs	= 0 ;

	    sts = om$send( msg	= message EMSsubbs.EMisoparcvs(
						msg,
						(short*) &sf1Env->_MATRIX_TYPE,
						sf1Env->_MATRIX,
						cst,
						FALSE, /* Trim to boundaries ?*/
						1,
						&Upar,
						TRUE, /* in u-direction */
						&nbCrvs,
						&isosAtU ),
                         senderid= NULL_OBJID,
                         targetid= sf1Id->objid,
                         targetos= sf1Id->osnum ) ;
            __CheckRC( sts, *msg, "EMSsubbs.EMisoparcvs", wrapup ) ;

	    vs$dotsInStsFld( msgnum = VS_gI_AnalyzingStfPltGaps ) ;

	    {
	      struct GRid		iso ;
	      struct IGRbsp_curve	*cvGeom = NULL ;

	      iso.objid = isosAtU[0] ;
	      iso.osnum = cst->env_info->_MD_OS ;

	      sts = vs$get_geometry(	msg		= msg,
			       		grobjId		= &iso,
			      		grobjEnv	= cst->env_info,
			       		geometry	= &cvGeom ) ;

	      vs$bulk_delete( objids = isosAtU, count = nbCrvs,
	                      theEnv = cst->env_info ) ;
	      free( isosAtU ) ;

	      __CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

	      if( cvGeom->order > 2 ) {
	      	BSrc	rc ;
	      	double	cht ;
	      	BSEXTRACTPAR( &rc, BSTOLCHRDHT, cht ) ;
	      	BSchangepar( &rc, BSTOLCHRDHT, cht * FACTOR ) ;
                BSchtptstcv( cvGeom, &nbPoints, &points, &params, msg ) ;
	      	BSchangepar( &rc, BSTOLCHRDHT, cht ) ;
	      } else {
	        VSstrokeLineString( msg, cvGeom, &nbPoints, &points, &params ) ;
	      }
              _FREE( cvGeom ) ;
	      if( BSERROR( *msg ) ) vs$error( msgval = EMS_E_BSerror ) ;
	      vs$dotsInStsFld( msgnum = VS_gI_AnalyzingStfPltGaps ) ;
	    }
	  }

	  inZone	 = FALSE ;

	  for( i = 0 ; i < nbPoints ; i++ ) {
	
	    IGRvector	normal ;
	    IGRpoint	projected ;

	    vs$dotsInStsFld( msgnum = VS_gI_AnalyzingStfPltGaps ) ;
	    {
	      IGRpoint	ptOnSf ;
	      int	num ;

	      BSsfevaln( sf1Geom, Upar, params[i], 1, &num, ptOnSf,
	                 (IGRvector *) normal, msg ) ;
	      if( BSERROR( *msg ) ) vs$error( msgval = EMS_E_BSerror ) ;
	    }

	    { 
	      double	sqrDst ;

	      {
	        long 	 	numPjPts= NULL ;
	        IGRpoint	*pjPts	= NULL ;
	        double		*uPjPts	= NULL ;
	        double		*vPjPts	= NULL ;
	        int		j ;

	        /* Project point on sf1's isoparametric curve onto sf2 along
	         * normal of sf1 at point.
	         */
	        BSpj_pt_sf( sf2Geom, points[i], normal,
	                    &numPjPts, &pjPts, &uPjPts, &vPjPts, msg ) ;
	        if( BSERROR( *msg ) ) vs$error( msgval = EMS_E_BSerror ) ;

                if( numPjPts ) {
              	   int jmin = 0 ;
	           sqrDst = MAXDOUBLE ;
	           for( j = 0 ; j < numPjPts ; j++ ) {
	             double d = BSdistptpts( msg, points[i], pjPts[j] ) ;
	    	     if( d < sqrDst ) { sqrDst = d ; jmin = j ; }
	           }
	           VSvccpy( projected, pjPts[jmin] ) ;

	           _FREE( pjPts ) ; _FREE( uPjPts ) ; _FREE( vPjPts ) ;
	        } else {
	      	  continue ;
	        }
	      }

	      if( sqrDst > sqrGap ) {
	        if( inZone ) {
	          int k ;
	      	  for( k = 0 ; k < 3 ; k++ ) {
	      	     endPoint[k] = points[i][k] ;
	             endNorml[k] = normal[k] ;
	      	  }
	          if( sqrDst > maxSqrGap ) {
	            maxSqrGap = sqrDst ;
	          }
	          if( i == nbPoints - 1 ) createMark = TRUE ;
	        } else {
	      	  int		k ;
	      	  IGRvector	sf1ToSf2 ;
	      	  int		dir ;
	      	
	          inZone = TRUE ;

	          /* Set normal from sf1 to sf2
	           */
	          BSmkvec( msg, sf1ToSf2, points[i], projected ) ;
	          dir = BSdotp( msg, sf1ToSf2, normal ) >= 0 ? 1 : -1 ;

	          for( k = 0 ; k < 3 ; k++ ) {
	             endPoint[k] = begPoint[k] = points[i][k] ;
	             endNorml[k] = begNorml[k] = dir * normal[k] ;
	          }

	          maxSqrGap = sqrDst ;
	        }
	      } else {
	        if( inZone ) {
	      	  inZone = FALSE ; createMark = TRUE ;
	        }
	      }
	      if( createMark ) {
	 	double		length = sqrt( maxSqrGap ) ;
		int		k ;
		int		dir ;
		struct GRid	marker ;

		createMark = FALSE ;

		if( maxSqrGap > *maxGap ) *maxGap = maxSqrGap ;

		BSnorvec( msg, begNorml ) ; BSnorvec( msg, endNorml ) ;

		/* Set endNorml in the same direction as begNorml
		 */
		dir = BSdotp( msg, begNorml, endNorml ) >= 0 ? 1 : -1 ;

		for( k = 0 ; k < 3 ; k++ ) {
		  lsPnts[0][k] = begPoint[k] ;
		  lsPnts[1][k] = begPoint[k] + length * begNorml[k] ;
		  lsPnts[2][k] = endPoint[k] + length * endNorml[k] * dir ;
		  lsPnts[3][k] = endPoint[k] ;
		}

		marker.osnum = cst->env_info->_MD_OS ;
		marker.objid = NULL_OBJID ;
		sts = om$construct(
			classid	= OPP_GR3dlinestr_class_id,
			osnum	= marker.osnum,
			p_objid	= &marker.objid,
			msg	= message GRgraphics.GRaltconstruct( &lsCst ) );
		if( !( sts & 1 & *msg ) && !IF_NULL_OBJID( marker.objid ) ) {
			om$send(msg	= message Root.delete( 0 ),
				senderid= marker.objid,
				targetid= marker.objid,
				targetos= marker.osnum ) ;
		}
		markers[imarker++] = marker ;
		if( imarker >= maxMarkers ) goto endOfLoops ;
	      }
	    }
	  } /* for */
	} /* for */

	endOfLoops :
		*maxGap	= sqrt( *maxGap ) ;
		*count	= imarker ;
		sts	= OM_S_SUCCESS ;
		*msg	= MSSUCC ;

	wrapup :
	        vs$dotsInStsFld( dots = clear ) ;
		_FREE( sf1Geom ) ; _FREE( sf2Geom ) ;
		_FREE( params  ) ; _FREE( points ) ;
		return sts ;

} /* VSdetectGapBeyongTolBtwSfAndCv */
/*----------------------------------------------------------------------------*/

end implementation EMSsubbs ;

