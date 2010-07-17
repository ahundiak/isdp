/*
	I/STRUCT
*/ 
class implementation VSbeam ;

#include <stdio.h>
#include "OMmacros.h"
#include "DImacros.h"
#include "exmacros.h"
#include "acrepdef.h"
#include "vsdpb.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes
 */
#include "vsmkencompbx.h"
/*----------------------------------------------------------------------------*/
long VSbeamBox( msg, bmId, bmEnv, box )

long		*msg ;
struct GRid	*bmId ;
struct GRmd_env	*bmEnv ;
GRrange		box ; {

	long		sts ;
	VSdspRep	bmRep ;
	IGRboolean	world = FALSE ;
	GRname		footName ;
	struct GRid	profIn2dRep,
			axisIn2dRep ;
	GRrange		profRng,
			axisRng ;

	sts = om$send(	msg	= message ACncpx.ACget_NV_rep( &bmRep ),
			senderid= bmId->objid,
			targetid= bmId->objid,
			targetos= bmId->osnum ) ;
	__CheckRC( sts, 1, "ACncpx.ACget_NV_rep", wrapup ) ;

	switch( bmRep ) {

	case VS_m_3dWFillet     :
        case VS_m_2dSurface     :
        case AC_3D_REP          :
        case AC_ENV_REP         :
    
		sts = om$send(	msg	= message GRgraphics.GRgetrang(
							msg,
							&bmEnv->_MATRIX_TYPE,
							bmEnv->_MATRIX,
							&world,
							box ),
				senderid= bmId->objid,
				targetid= bmId->objid,
				targetos= bmId->osnum ) ;
		__CheckRC( sts, *msg, "GRgraphics.GRgetrang", wrapup ) ;
		break ;

	case AC_2D_REP		:

		/*
		 * Beam is in 2D rep: access profile and axis owned by 
		 * root macro making 2D representation.
		 */
		DIstmcpy( footName, VS_K_bmGrCmpName, VS_K_bmLnRepProf, NULL ) ;

		sts = om$send(	msg	= message NDmacro.ACreturn_foot(
						msg, footName, &profIn2dRep,
						NULL, NULL ),
				senderid= bmId->objid,
				targetid= bmId->objid,
				targetos= bmId->osnum ) ;
		__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

		DIstmcpy( footName, VS_K_bmGrCmpName, VS_K_bmLnRepAxis, NULL ) ;

		sts = om$send(	msg	= message NDmacro.ACreturn_foot(
						msg, footName, &axisIn2dRep,
						NULL, NULL ),
				senderid= bmId->objid,
				targetid= bmId->objid,
				targetos= bmId->osnum ) ;
		__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

		/*
		 * Get ranges of both.
		 */
		sts = om$send(	msg	= message GRgraphics.GRgetrang(
							msg,
							&bmEnv->_MATRIX_TYPE,
							bmEnv->_MATRIX,
							&world,
							profRng ),
				senderid= profIn2dRep.objid,
				targetid= profIn2dRep.objid,
				targetos= profIn2dRep.osnum ) ;
		__CheckRC( sts, *msg, "GRgraphics.GRgetrang", wrapup ) ;

		sts = om$send(	msg	= message GRgraphics.GRgetrang(
							msg,
							&bmEnv->_MATRIX_TYPE,
							bmEnv->_MATRIX,
							&world,
							axisRng ),
				senderid= axisIn2dRep.objid,
				targetid= axisIn2dRep.objid,
				targetos= axisIn2dRep.osnum ) ;
		__CheckRC( sts, *msg, "GRgraphics.GRgetrang", wrapup ) ;

		VSmakeEncompassingBox( profRng, axisRng, 1., box ) ;
		break;
	}

	wrapup :
		return sts ;

}  /* VSbeamBox */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;

