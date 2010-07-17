/* $Id: VSbmvertices.I,v 1.5 2001/06/04 18:45:59 ahundiak Exp $  */

/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:	struct/vsgeom / VSbmvertices.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSbmvertices.I,v $
 *	Revision 1.5  2001/06/04 18:45:59  ahundiak
 *	ah
 *	
 *	Revision 1.4  2001/05/03 22:26:52  ramarao
 *	Fixed a crash. - TR# 5170
 *	
 *	Revision 1.3  2001/01/29 19:52:12  ramarao
 *	*** empty log message ***
 *	
 *	Revision 1.2  2001/01/16 23:41:52  ramarao
 *	*** empty log message ***
 *	
# Revision 1.2  2000/11/29  23:22:24  pinnacle
# Replaced: struct/vsgeom/VSbmvertices.I for:  by ahundiak for Service Pack
#
# Revision 1.1  2000/06/27  15:24:34  pinnacle
# Created: struct/vsgeom/VSbmvertices.I by jwfrosch for Service Pack
#
 *
 * History:
 *	MM/DD/YY	AUTHOR	DESCRIPTION
 *	06/27/00	HF	Modify realloc() ==>> _REALLOC()
 *	11/29/00	RR	Replace VSzeroDist with VSzeroDistCHT.
 *      06/04/01        ah      TR5272 Comment out the "check for duplicates" code
 * -------------------------------------------------------------------*/

class implementation EMSedge ;

#include <math.h>
#include <stdlib.h>
#include "msdef.h"
#include "bstypes.h"
#include "bserr.h"
#include "bsparameters.h"
#include "vsbeamdef.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdatamacros.h"
#include "vsjntmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bscveval.h"
#include "vsocgrleaves.h"
#include "vsvecmxproto.h"

extern void	VSzeroOutEdgeGeom() ;
extern long	VSgetEdgesByProps() ;

from NDmacro	import	ACreturn_foot ;

int VSzeroDistCHT( d ) double d ; {

        long    msg ;
        double  tollenvec ;

        BSEXTRACTPAR( &msg, BSTOLCHRDHT, tollenvec ) ;

        return d < tollenvec ;

} /* VSzeroDistCHT */

/*----------------------------------------------------------------------------*/
int VSvertexCmp( V1, V2 )

#if defined(__STDC__) || defined(__cplusplus)
	const
#endif

void	*V1,		/* In fact pointing to a double[3]	*/
	*V2 ; {		/* In fact pointing to a double[3]	*/

	int	rc ;
	double	*v1 = (double *) V1,
		*v2 = (double *) V2 ;

	double tol = 2.0;
	
	if( fabs( v1[0] - v2[0] ) < tol ) {
		if( fabs( v1[1] - v2[1] ) < tol ) {
			if( fabs( v1[2] - v2[2] ) < tol )	rc =  0 ;
			else if( v1[2] < v2[2] )		rc = -1 ;
	     		else					rc =  1 ;
	     	} else if( v1[1] < v2[1] )	rc = -1 ;
	     	  else				rc =  1 ;
	} else if( v1[0] < v2[0] )	rc = -1 ;
	  else 				rc =  1 ;

	return rc ;

} /* VSvertexCmp */
/*----------------------------------------------------------------------------*/
long VSgetVerticesOfBeam( msg, bmId, bmEnv, count, vertices )

long		*msg ;
struct GRid	*bmId ;
struct GRmd_env	*bmEnv ;
int		*count ;
double		**vertices ; {

	/*
	 * Get all surfaces constituent of beam.
	 * For all surfaces
	 *	- get their edges
	 *	- for each edge
	 *		get their end points
	 *	(we will get here all poits at least twice)
	 *	All edge endpoints make the vertices of the beam.
	 */
	long		sts ;		/* OM return code		*/
	struct	GRid	solid,		/* Solid of beam		*/
			*sfList = NULL,	/* Surfaces of solid		*/
			loopSet,	/* Loopset of one surface	*/
			*edList = NULL ;/* Edges of one loopset		*/
	struct GRobj_env
			oneSf ;
	int		sfCount = 0,	/* Count of surfaces		*/
			edCount = 0,	/* Count of edges in one loopset*/
			vxCount	= 0,	/* Count of vertices		*/
			i,		/* Loop-on-surfaces index	*/
			j,		/* Loop-on-edges index		*/
			k,		/* Index of current vertex	*/
			l ;		/* Counts distinct vertices	*/
	struct IGRbsp_surface
			*sfGeom	= NULL ;/* Geometry of one surface	*/
	struct IGRbsp_curve
			edGeom ;	/* Geometry of one edge		*/
	double		*vxList = NULL,	/* List of vertices		*/
			*previous ;

	*count = NULL ; *vertices = NULL ;

	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
						msg, VS_K_bmGrCmpName,
						&solid, NULL, NULL ),
			senderid= bmId->objid,
			targetid= bmId->objid,
			targetos= bmId->osnum ) ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	/*
	 * Get all surfaces constituent of solid.
	 */
	sts = VSgetLeavesOfOwnerCmpGraph( msg, &solid, &sfCount, &sfList ) ;
	__CheckRC( sts, *msg, "VSgetLeavesOfOwnerCmpGraph", wrapup ) ;

	for( k = i = 0 ; i < sfCount ; i++ ) {
		oneSf._grid	= sfList[i] ;
		oneSf.mod_env	= *bmEnv ;
		sts = vs$getLoopset(	msg	= msg,
					surface = &oneSf,
					loopset = &loopSet ) ;
		__CheckRC( sts, *msg, "vs$getLoopset", wrapup ) ;

		sts = VSgetEdgesByProps( msg, &loopSet, EMED_NATURAL,
						&edCount, &edList ) ;
		__CheckRC( sts, *msg, "VSgetEdgesByProps", wrapup ) ;

		/*
		 * Get geometry of surface : it will speed up
		 */
	 	sts = vs$get_geometry(	msg     = msg,
					grobjId = sfList + i,
					grobjEnv= bmEnv,
					geometry= &sfGeom ) ;
		__CheckRC( sts, *msg, "vs$get_geometry 1", wrapup ) ;

		/*
		 * Two end points per edge.
		 */
		if( !vxList ) {
			vxCount = 2 * edCount ;
			vxList	= _MALLOC( vxCount * 3, double ) ;
			if( !vxList ) vs$mem_fail() ;
		} else {
			double	*newptr ;
			vxCount += 2 * edCount ;
			newptr  = _REALLOC( vxList,  vxCount * 3, double ) ;
			if( newptr ) {
				vxList = newptr ;
			} else {
				_FREE( vxList ) ; vxList = NULL ; vxCount = 0 ;
				vs$mem_fail() ;
			}
		}
		for( j = 0 ; j < edCount ; j++ ) {
			VSzeroOutEdgeGeom( &edGeom ) ;
			sts = om$send(
				msg	= message EMSedge.EMget_bcxyz_geom(
						msg,
						&bmEnv->md_env,
						sfList + i,
						sfGeom,
						0, /* from spaninx */
						OM_K_MAXINT, /* num span */
						FALSE,
						NULL,
						&edGeom ),
				senderid= edList[j].objid,
				targetid= edList[j].objid,
				targetos= edList[j].osnum ) ;
			__CheckRC( sts, *msg, "EMSedge.EMget_bcxyz_geom", wrapup ) ;

			BScveval( &edGeom, 0., 0, (IGRpoint *) (vxList + k), msg ) ;
			k += 3 ;
			BScveval( &edGeom, 1., 0, (IGRpoint *) (vxList + k), msg ) ;
			k += 3 ;

			VSfreeEdgeGeom( &edGeom ) ;
		}
		_FREE( edList ) ; edList = NULL ; edCount = 0 ;
		_FREE( sfGeom ) ; sfGeom = NULL ;

	}
#if 0
	/* TR5272 No need for this and can cause obscure crashes
	 * on some units due to a > b, b > c but a > c
	 * messing up qsort
	 *
	 * Remove duplicate entries.
	 */
	qsort( (char *) vxList, vxCount, sizeof( IGRpoint ), VSvertexCmp ) ;
	previous = vxList ; l = 1 ; k = 3 ;

	for( i = 1 ; i < vxCount ; i++ ) {
		j = i * 3 ;
		if( !VSeqPoints( previous, vxList + j ) ) {
			VSvccpy( vxList + k, vxList + j ) ;
			previous = vxList + k ;
			k += 3 ; l++ ;
		}
	}
	vxCount = l ;
#endif

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		_FREE( sfList ) ;
		/*
		 * The following may not have been freed in case of error.
		 */
		_FREE( edList ) ; _FREE( sfGeom ) ;

		if( sts & 1 & *msg ) {
			*count		= vxCount ;
			*vertices	= vxList ;
		} else {
			_FREE( vxList ) ;
		}
		return sts ;

} /* VSgetVerticesOfBeam */
/*----------------------------------------------------------------------------*/

end implementation EMSedge ;

