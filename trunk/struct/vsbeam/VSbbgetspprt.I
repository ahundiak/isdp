/*
	I/STRUCT
*/
class implementation VSbooBeam ;

#include <math.h>
#include <stdlib.h>
#include "madef.h"
#include "bstypes.h"
#include "nddef.h"
#include "asmacros.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bsdistptpts.h"
#include "ASextbspi.h"
#include "vsobjgarbage.h"
#include "vsvecmxproto.h"

extern long		VSgetVerticesOfBeam() ;
extern struct GRid	NULL_GRID ;

#define EQPARMS( t1, t2 ) VSzeroDist( fabs( (t1) - (t2) ) )
/*----------------------------------------------------------------------------*/
method VSgetSupportAxis(	long			*msg ;
				struct GRmd_env		*myEnv ;
				struct GRobj_env 	*axis ) {

	long		sts ;		/* OM return code		*/
	int		vxCount	= 0,	/* Count of vertices of beam	*/
			i,
			j,
			ip[2],		/* Ind. of farthest apart projs.*/
			haveFarthestPnt;/* TRUE/FALSE.			*/
	double		*vxList	= NULL,	/* Vertices of beam		*/
			*vxParms= NULL,	/* Parms of projs of vertices	*/
			distSq,		/* A squared distances		*/
			maxDistSq,	/* Max. sq. dist. between projs	*/
			*t0,		/* Parm. of new 1st end point	*/
			*t1,		/* Parm. of new 2nd end point	*/
			*p0,		/* Coords of new 1st end point	*/
			*p1 ;		/* Coords of new 2nd end point	*/
	IGRpoint	prjPnt ;	/* Coords of a projected point	*/
	struct GRparms	prjParm ;	/* Parm. of a projected point	*/
	struct GRid	myGRid,		/* Moi !			*/
			copy,		/* Copy of original axis	*/
			pdelCv ;	/* Copy after resizing		*/
	VSdspRep	myRep ;
	struct GRmd_env axisEnv ;	/* Env of axis.                 */

	pdelCv.objid = copy.objid = NULL_OBJID ;

	/*
	 * Get original axis (the one to be resized).
	 */
	sts = om$send(	msg	= message VSmodBeam.VSgetSupportAxis(
							msg, myEnv, axis ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSmodBeam.VSgetSupportAxis", wrapup ) ;

	sts = om$send(	msg	= message ACncpx.ACget_NV_rep( &myRep ),
			targetid= my_id ) ;

	if( myRep & AC_2D_REP ) {
		/*
		 * No solid available.
		 * For now we return the original axis.
		 */
		*msg = MSSUCC ; sts = OM_S_SUCCESS ; goto wrapup ;
	}

	myGRid.objid = my_id ; myGRid.osnum = OM_Gw_current_OS ;

	sts = VSgetVerticesOfBeam( msg, &myGRid, myEnv, &vxCount, &vxList ) ;
	__CheckRC( sts, *msg, "VSgetVerticesOfBeam", wrapup ) ;

	if( !( vxParms = _MALLOC( vxCount, double ) ) ) vs$mem_fail() ;

	/*
	 * Project vertices onto original axis, overwriting the coordinates of
	 * the vertices with those of their projections.
	 */
	axisEnv.md_id = axis->mod_env.md_id ;
	VSmulmx( axis->_matrix, myEnv->_MATRIX, axisEnv._MATRIX, 
		 &axisEnv._MATRIX_TYPE ) ;

	for( i = 0 ; i < vxCount ; i++ ) {
		sts = om$send(	msg	= message GRgraphics.GRptproject(
							msg,
							&axisEnv._MATRIX_TYPE,
							axisEnv._MATRIX,
							vxList + 3 * i,
							prjPnt,
							&prjParm ),
				targetid= axis->_objid,
				targetos= axis->_osnum ) ;
		__CheckRC( sts, *msg, "GRgraphics.GRptproject", wrapup ) ;

		VSvccpy( vxList + 3 * i, prjPnt ) ;
		vxParms[i] = prjParm.u ;
	}
	/*
	 * Takes the two farthest apart projected points.
	 */
	maxDistSq = 0 ;
	haveFarthestPnt = FALSE ;
	for( i = 0 ; i < vxCount - 1 ; i++ ) {
		for( j = 1 ; j < vxCount ; j++ ) {
			distSq = BSdistptpts(	msg,
						vxList + 3 * i,
						vxList + 3 * j ) ;
			if( distSq > maxDistSq ) {
				haveFarthestPnt	= TRUE ;
				maxDistSq	= distSq ;
				ip[0]		= 3 * i ;
				ip[1]		= 3 * j ;
			}
		}
	}
	
	if( !haveFarthestPnt ) {
		/* Beam has a null length (?) */
		*msg = MSSUCC ; sts = OM_S_SUCCESS ; goto wrapup ;
	}

	t0 = vxParms + ip[0] / 3 ; p0 = vxList + ip[0] ;
	t1 = vxParms + ip[1] / 3 ; p1 = vxList + ip[1] ;

	/*
	 * Order points according to their parameters on the original axis.
	 */
	if( *t0 > *t1 ) {
		double *tmp ;
		
		tmp =  t0 ; t0  =  t1 ;  t1 = tmp ;
		tmp =  p0 ; p0  =  p1 ;  p1 = tmp ;
	}
	if( EQPARMS( *t0, 0. ) && EQPARMS( *t1, 1. ) ) {
		/*
		 * Nothing to do.
		 */
		*msg = MSSUCC ; sts = OM_S_SUCCESS ; goto wrapup ;
	}

	/*
	 * Copy support axis.
	 */
	sts = vs$grCopy(	msg	= msg,
				frEnv	= &axisEnv,
				frObj	= &axis->_grid,
				toEnv	= &axisEnv,
				toObj	= &copy ) ;
	__CheckRC( sts, *msg, "vs$grCopy", wrapup ) ;

	/*
	 * Resize copy: keep portion from p0 to p1.
	 */
	sts = ASextract_cv( copy, p0, p1, &axisEnv, &pdelCv ) ;

	if( sts & 1 ) {

		struct GRid	src ;

		copy		= pdelCv ;
		axis->_grid	= copy ;
		/*
		 * Create a support-only source object, since we have created
		 * a new one and want the system to get rid of it when no
		 * longer needed.
		 */
		sts = as$make_source(	go_grid	= axis->_grid,
					mod_env	= &axisEnv,
					as_os	= copy.osnum,
					as_grid	= &src ) ;
		__CheckRC( sts, 1, "as$make_source", wrapup ) ;

		sts = om$send(	msg	= message NDnode.NDchg_state(
						ND_DEL_NO_CH | ND_WAIT_DEL,
						ND_DEL_NO_CH | ND_WAIT_DEL ),
				targetid= src.objid,
				targetos= src.osnum ) ;

		VSrecordTmpObj( &src, &axisEnv ) ;

	} /* Else use original support axis */

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		_FREE( vxList ) ; _FREE( vxParms ) ;
		if( !( sts & 1 & *msg ) ) {
			vs$bulk_delete(	grids	= &copy,
					theEnv	= &axisEnv ) ;
		}
		return sts ;

} /* method VSgetSupportAxis */
/*----------------------------------------------------------------------------*/

end implementation VSbooBeam ;
