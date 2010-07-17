/* $Id: VSsldistobob.I,v 1.1.1.1 2001/01/04 21:10:57 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsselector/VSsldistobob.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSsldistobob.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:57  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1997/09/29  15:35:18  pinnacle
# TR179700969
#
 *
 * History:
 *      MM/DD/YY AUTHOR	DESCRIPTIO
 *      09/26/97 ah     added header
 *      09/29/97 ah	TR179700969 Cardinal Point 
 *			Not sure where the change is, Suresh did it
 ***************************************************************************/

class implementation VShelper ;

#include <stdio.h>
#include <float.h>
#include "bserr.h"
#include "EMSmsgdef.h"
#include "vsslc.h"
#include "vsslcmacros.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bsdistptpt.h"
#include "bsmdistcvcv.h"
#include "bsmdistcvsf.h"
#include "bsmdistptcv.h"
#include "bsmdistptsf.h"
#include "bsmdistsfsf.h"

#define	_SF		0
#define	_CV		1
#define	_PT		2
#define _UNKNOWN	(-1)

#define	_PT_PT		0
#define	_PT_CV		1
#define	_PT_SF		2
#define	_CV_CV		3
#define _CV_SF		4
#define _SF_SF		5

extern OMuword		OPP_EMSsubbs_class_id,
			OPP_GRcurve_class_id,
			OPP_GRpoint_class_id ;

from GRlinear	import	GRgetpolyline ;
/*----------------------------------------------------------------------------*/
static int VSgetObjGeomType( obj ) struct GRid *obj ; {

	int	t ;

	/*
	 * Note: tst for GRpoint before GRcurve since GRpoint is a sub-class
	 * of GRcurve.
	 */
	if( vs$is_ancestry_valid(	object	= obj,
					classid	= OPP_EMSsubbs_class_id ) ) {
		t = _SF ;
	} else if( vs$is_ancestry_valid(object	= obj,
					classid	= OPP_GRpoint_class_id ) ) {
		t = _PT ;
	} else if( vs$is_ancestry_valid(object	= obj,
					classid	= OPP_GRcurve_class_id ) ) {
		t = _CV ;
	} else {
		t = _UNKNOWN ;
	}
	return t ;
		
} /* VSgetObjGeomType */
/*----------------------------------------------------------------------------*/
/*
static
  TR179701294 ZDL gives error locating this function
  not sure how regular make dload bypasses ststic
  removing it for now 
*/
int VSdistGeomGeom( msg, action, geom0, geom1, dist )

long		*msg ;
int		action ;
void		*geom0,
		*geom1 ;
double		*dist ; {

	switch( action ) {

	case _PT_PT : {
			*dist = BSdistptpt(	msg,
						(double *) geom0,
						(double *) geom1 ) ;
		      }
		      break ;

	case _PT_CV : {
			short	k,
				n ;
			double	*Tpars	= NULL,
				*intPars= NULL ;

			BSmdistptcv(	(struct IGRbsp_curve *) geom1,
					(double *) geom0,
					&k,
					&n,
					&Tpars,
					dist,
					&intPars,
					msg ) ;
			_FREE( Tpars ) ; _FREE( intPars ) ;
		      }
		      break ;

	case _PT_SF : {
			double		U,
					V ;
			IGRpoint	base ;

			BSmdistptsf(	msg,
					(struct IGRbsp_surface *) geom1,
					(double *) geom0,
					&U,
					&V,
					base,
					dist ) ;
		      }
		      break ;

	case _CV_CV : {
			int		num ;
			double		*par1	= NULL,
					*par2	= NULL ;
			IGRpoint	*pt1	= NULL,
					*pt2	= NULL ;

			BSmdistcvcv(	(struct IGRbsp_curve *) geom0,
					(struct IGRbsp_curve *) geom1,
					&num,
					&par1,
					&par2,
					&pt1,
					&pt2,
					dist,
					msg ) ;
			_FREE( par1 ) ; _FREE( pt1 ) ;
			_FREE( par2 ) ; _FREE( pt2 ) ;
		       }
		       break ;

	case _CV_SF : {
			int		num ;
			double		*Tpar	= NULL,
					*UVpar	= NULL ;
			IGRpoint	*cvPt	= NULL,
					*sfPt	= NULL ;

			BSmdistcvsf(	(struct IGRbsp_curve *) geom0,
					(struct IGRbsp_surface *) geom1,
					&num,
					&Tpar,
					&UVpar,
					&cvPt,
					&sfPt,
					dist,
					msg ) ;
			_FREE( Tpar ) ; _FREE( cvPt ) ;
			_FREE( UVpar) ; _FREE( sfPt ) ;
		     }
		break ;

	case _SF_SF : {
			int		num ;
			IGRdouble	*UVpar1	= NULL,
					*UVpar2	= NULL ;
			IGRpoint	*sfPt1	= NULL,
					*sfPt2	= NULL ;

			BSmdistsfsf(	(struct IGRbsp_surface *) geom0,
					(struct IGRbsp_surface *) geom1,
					&num,
					&UVpar1,
					&UVpar2,
					&sfPt1,
					&sfPt2,
					dist,
					msg ) ;
			_FREE( UVpar1 ) ; _FREE( UVpar2 ) ;
			_FREE( sfPt1  ) ; _FREE( sfPt2  ) ;
		      }
		      break ;
	}

	*msg	= BSOKAY( *msg ) ? MSSUCC : MSFAIL ;

	return *msg & 1 ;
	
} /* VSdistGeomGeom */
/*----------------------------------------------------------------------------*/
long VSdistObjObj( msg, obj0, obj1, distance )

long			*msg ;
struct GRobj_env	*obj0,
			*obj1 ;
VSexecRes		*distance ; {

	long			sts ;
	int			gtype[2],
				t = -1,
				i,
				swap = FALSE ;
	struct GRobj_env	*pO[2] ;
	struct IGRpolyline	poly ;
	IGRpoint		P[2] ;
	int			action = 1 ;
	void			*geom[2] ;
	double			dist ;

	distance->type = VS_double ;
	distance->_dval= DBL_MAX ;

	geom[0] = geom[1] = NULL ;

	gtype[0] = VSgetObjGeomType( &obj0->_grid ) ;
	gtype[1] = VSgetObjGeomType( &obj1->_grid ) ;

	if( gtype[0] == _UNKNOWN || gtype[1] == _UNKNOWN ) {
		*msg = MSINARG ; goto wrapup;
	}

	switch( gtype[0] ) {
		case _PT :
			swap = FALSE ;
			switch( gtype[1] ) {
				case _PT : t = _PT_PT ; break ;
				case _CV : t = _PT_CV ; break ;
				case _SF : t = _PT_SF ; break ;
			}
			break ;

		case _CV :
			switch( gtype[1] ) {
				case _PT : t = _PT_CV ; swap = TRUE ; break ;
				case _CV : t = _CV_CV ; swap = FALSE; break ;
				case _SF : t = _CV_SF ; swap = FALSE; break ;
			}
			break ;

		case _SF :
			switch( gtype[1] ) {
				case _PT : t = _PT_SF ; swap = TRUE ; break ;
				case _CV : t = _CV_SF ; swap = TRUE ; break ;
				case _SF : t = _SF_SF ; swap = FALSE; break ;
			}
			break ;
	}

	if( swap ) {
		int	tmp ;

		tmp = gtype[0] ; gtype[0] = gtype[1] ; gtype[1] = tmp ;
		pO[0] = obj1 ;
		pO[1] = obj0 ;
	} else {
		pO[0] = obj0 ;
		pO[1] = obj1 ;
	}

	for( i = 0 ; i < 2 ; i++ ) {
		switch( gtype[i] ) {

			case _PT :

			poly.num_points	= 1 ;
			poly.points = P[i] ;

			sts = om$send(	msg	= message GRlinear.GRgetpolyline(
							msg,
							&pO[i]->_matrix_type,
							pO[i]->_matrix,
							&action,
							&poly ),
				senderid= pO[i]->_objid,	
				targetid= pO[i]->_objid,
				targetos= pO[i]->_osnum ) ;
			__CheckRC( sts, *msg, "GRlinear.GRgetpolyline", wrapup ) ;

			geom[i] = (void *) &P[i][0] ;
			break ;

			case _CV :
			case _SF :
			sts = vs$get_geometry(	msg	= msg,
						grobjId	= &pO[i]->_grid,
						grobjEnv= &pO[i]->mod_env,
						geometry= &geom[i] ) ;
			break ;
		}
	}

	if( VSdistGeomGeom( msg, t, geom[0], geom[1], &dist ) ) {
		distance->_dval = dist ;
	}
	wrapup :
		for( i = 0 ; i < 2 ; i++ ) {
			if( geom[i] != (void *) &P[i][0] ) {
				_FREE( geom[i] ) ;
			}
		}
		return *msg & 1 ;

} /* VSdistObjObj */
/*----------------------------------------------------------------------------*/

end implementation VShelper ;

