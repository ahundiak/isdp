/*
	I/STRUCT
*/ 
class implementation VSbeam ;

#include <stdio.h>
#include "madef.h"
#include "OMmacros.h"
#include "exmacros.h"
#include "acrepdef.h"
#include "vsdpb.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsmeasmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsvecmxproto.h"

from GRcurve	import	GRmidpoint,
			GRendpts ;
/*----------------------------------------------------------------------------*/
long VS2dBeamMassProps( msg, bmId, bmEnv, mp )

long		*msg ;
struct GRid	*bmId ;
struct GRmd_env	*bmEnv ;
VSintegral	*mp ; {

	/*
	 * Approximately evaluates the mass properties of a beam which is
	 * in 2D (symbolic) representation.
	 * The moment of inertia is not computed.
	 */
	long			sts ;		/* OM return code	*/
	int			i ;		/* Loop index		*/
	struct GRid		prflDef ;	/* Beam's profile def.	*/
	struct GRobj_env	profIn3dRep,	/* 3D rep. of profile	*/
				*axis ;		/* Axis of beam		*/
	double			profLength,	/* Length of profile	*/
				profArea ;	/* Area of profile	*/
	double			length,		/* Length of beam	*/
				area,		/* Area of beam		*/
				volume ;	/* Volume of beam	*/
	struct GRparms		refParms ;	/* For GRmidpoint	*/
	IGRpoint		midAxis,	/* Mid-point of axis	*/
				endAxis0,	/* 1st end of axis	*/
				endAxis1,	/* 2nd end of axis	*/
				ctrOfProf ;	/* Center of profile	*/
	VSsuppList		bmSupps ;	/* Supports of beam	*/
	IGRmatrix		CS ;		/* CS of profile	*/

	sts = om$send(	msg	= message VSbeam.VSgetProfileDef(
							msg, &prflDef ),
			senderid= bmId->objid,
			targetid= bmId->objid,
			targetos= bmId->osnum ) ;
	__CheckRC( sts, *msg, "VSbeam.VSgetProfileDef", wrapup ) ;

	sts = vs$get_graphic_section(	msg		= msg,
					sectDef		= &prflDef,
					representation	= AC_3D_REP,
					section		= &profIn3dRep ) ;
	__CheckRC( sts, *msg, "vs$get_graphic_section", wrapup ) ;

	sts = vs$lengthAndAreaOfClPlCv(	msg	= msg,
					curveId	= &profIn3dRep._grid,
					curveEnv= &profIn3dRep.mod_env,
					length	= &profLength,
					area	= &profArea ) ;
	__CheckRC( sts, *msg, "vs$lengthAndAreaOfClPlCv", wrapup ) ;

	sts = om$send(	msg	= message VSbeam.VSgetBeamLength(
							msg, bmEnv, &length ),
			senderid= bmId->objid,
			targetid= bmId->objid,
			targetos= bmId->osnum ) ;
	__CheckRC( sts, *msg, "VSbeam.VSgetBeamLength", wrapup ) ;

	sts = om$send(	msg	= message VSpart.VSgetSupports(
						msg, bmEnv, &i, bmSupps ),
			senderid= bmId->objid,
			targetid= bmId->objid,
			targetos= bmId->osnum ) ;
	__CheckRC( sts, *msg, "VSpart.VSget_supports", wrapup ) ;

	/*
	 * Remainder : #0 supprot surface, #1 support axis.
	 */
	axis = bmSupps + 1 ;

	sts = om$send(	msg	= message VSbeam.VSgetCrossSectionCS(
								msg,
								bmEnv,
								bmSupps + 0,
								bmSupps + 1,
								0.,
								&prflDef,
								CS ),
			senderid= bmId->objid,
			targetid= bmId->objid,
			targetos= bmId->osnum ) ;
	__CheckRC( sts, *msg, "VSbeam.VSgetCrossSectionCS", wrapup ) ;

	/*
	 * Get center of cached profile which is in the xy-plane z = 0.
	 */
	sts = om$send(	msg	= message GRvg.GRcenter(
						msg,
						&profIn3dRep._matrix_type,
						profIn3dRep._matrix,
						ctrOfProf ),
			senderid= bmId->objid,
			targetid= profIn3dRep._objid,
			targetos= profIn3dRep._osnum ) ;

	if( !( sts & 1 & *msg ) ) {
		/*
		 * I have seen this message fail on composite curves ...
		 */
		VSzerovc( ctrOfProf ) ;
	}
	/*
	 * Map center of profile to end #0 of beam.
	 */
	VSmxprodpt( CS, ctrOfProf, ctrOfProf ) ;

	area	= length * profLength + 2 * profArea /* End caps */ ;
	volume	= length * profArea ;

	sts = om$send(	msg	= message GRcurve.GRmidpoint(
							msg,
							&axis->_matrix_type,
							axis->_matrix,
							&refParms,
							midAxis ),
			senderid= bmId->objid,
			targetid= axis->_objid,
			targetos= axis->_osnum ) ;

	sts = om$send(	msg	= message GRcurve.GRendpts(
							msg,
							&axis->_matrix_type,
							axis->_matrix,
							endAxis0,
							endAxis1 ),
			senderid= bmId->objid,
			targetid= axis->_objid,
			targetos= axis->_osnum ) ;

	/*
	 * Map axis points to beam coordinates.
	 */
	 if( bmEnv->_MATRIX_TYPE != MAIDMX ) {
		VSmxprodpt( bmEnv->_MATRIX, midAxis , midAxis  ) ;
		VSmxprodpt( bmEnv->_MATRIX, endAxis0, endAxis0 ) ;
		VSmxprodpt( bmEnv->_MATRIX, endAxis1, endAxis1 ) ;
	}

	mp->dims[0]	= length ;
	mp->area	= area ;
	mp->volume	= volume ;
	/*
	 * Translate center of profile at end #0 (t=0 of axis) to middle of
	 * beam to give approximate centroid.
	 */
	for( i = 0 ; i < 3 ; i++ ) {
		mp->centroid[i] = midAxis[i] + ctrOfProf[i] - endAxis0[i] ;
	}
	for( i = 0 ; i < 6 ; i++ ) {
		mp->MofI.array[i] = 0. ;
	}
	wrapup :
		return sts ;

}  /* VS2dBeamMassProps */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;

