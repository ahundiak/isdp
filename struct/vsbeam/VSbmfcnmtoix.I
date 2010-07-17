/*
	I/STRUCT
*/
class implementation VSbeam ;

#include <stdio.h>
#include "OMerrordef.h"
#include "OMmacros.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vssectiondef.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsnameproto.h"

from VSxscurve import VStransUsrNmToCmp ;
/*----------------------------------------------------------------------------*/
method VSfaceNameToIndex(	long		*msg ;
				VSdspRep	myRep ;
				char		*faceName ;
				int		*faceIndex ) {

	long		sts ;		/* OM return code		*/
	struct GRid	profile,	/* Id of occurrence of profile	*/
			curveId ;	/* Id of profile curve		*/
	char		*curveName ;	/* Name of profile curve	*/

	     if( myRep & AC_ENV_REP	)	curveName = VS_K_EnvelopeCv ;
	else if( myRep & AC_2D_REP	)	curveName = VS_K_SchematicCv ;
	else if( myRep == AC_3D_REP 	)	curveName = VS_K_WoFilletCv ;
	else if( myRep == VS_m_3dWFillet)	curveName = VS_K_WFilletCv ;
	else {
		vs$inv_arg() ;
	}

	sts = om$send(	msg	= message VSbeam.VSgetProfileDef(
								msg, &profile ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSbeam.VSgetProfileDef", wrapup ) ;

	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
					msg, curveName, &curveId, NULL, NULL ),
			targetid= profile.objid,
			targetos= profile.osnum ) ;
	*msg = *msg ? MSSUCC : MSFAIL ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	if( myRep & ( AC_ENV_REP | AC_2D_REP ) ) {
		/*
		 * I can do something only if name is in the form "$<n>".
		 */
		int	count ;

		if( !VSreadGenericName( faceName, faceIndex ) ) vs$inv_arg() ;

		/*
		 * Check if by chance we do not overflow ...
		 */
		sts = om$send(
			msg	= message GRowner.GRget_number_components(
								msg, &count ),
			targetid= curveId.objid,
			targetos= curveId.osnum ) ;
		__CheckRC( sts, *msg, "GRowner.GRget_number_components", wrapup ) ;

		if( *faceIndex >= count ) vs$inv_arg() ;

	} else if( myRep & AC_3D_REP ) {
		/*
		 * Ask curve to do the translation.
		 */
		sts = om$send(	msg	= message VSxscurve.VStransUsrNmToCmp(
					msg, faceName, faceIndex, NULL ),
				targetid= curveId.objid,
				targetos= curveId.osnum ) ;
		__CheckRC( sts, *msg, "VSxscurve.VStransUsrNmToCmp", wrapup ) ;
	}

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		return sts ;

} /* method VSfaceNameToIndex */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;

