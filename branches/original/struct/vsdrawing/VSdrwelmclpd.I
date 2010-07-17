/*
	I/STRUCT
*/
class implementation VSfeature ;

#include <stdlib.h>
#include "madef.h"
#include "bserr.h"
#include "bstypes.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "EMSutlmacros.h"
#include "vsplatedef.h"
#include "vsjointdef.h"
#include "vsslcdef.h"
#include "vsslc.h"
#include "vsmiscmacros.h"
#include "vsdrwdef.h"
#include "vsdrw.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
#include "vsglobalmsg.h"
/*
 * Includes of function prototypes.
 */
#include "bssf_pl_int.h"
#include "vsgetchanobj.h"
#include "vsvecmxproto.h"

from VSbeam import VSgetSupportAxis ;
/*----------------------------------------------------------------------------*/
int VSdrwIsElementClipped( msg, inp, xData, isClipped )

long		     *msg ;	    /* OUT: Completion code		   */
const VSdrwInputData *inp ;	    /* IN : Data input to interpreter	   */
const VSdrwExecData  *xData ;	    /* IN : Data modified during execution */
int		     *isClipped ; { /* OUT: TRUE/FALSE			   */

	struct IGRplane	clippingPlane ;
	IGRvector	plNormal ;

	*isClipped	= FALSE ;

	plNormal[0] = inp->drwInfo.drwLbsys->matrix[ 2] ;
	plNormal[1] = inp->drwInfo.drwLbsys->matrix[ 6] ;
	plNormal[2] = inp->drwInfo.drwLbsys->matrix[10] ;

	clippingPlane.point	= inp->drwInfo.drwLbsys->diag_pt1 ;
	clippingPlane.normal	= plNormal ;

	if( xData->parsedElmType == VS_gI_Plate ) {
			VSdrwIsPlateClipped(	msg,
						inp->elmId,
						inp->elmEnv,
						&clippingPlane,
						isClipped ) ;
	} else if(    xData->parsedElmType == VS_gI_Beam
		   || xData->parsedElmType == VS_gI_Stiffener ) {
			VSdrwIsBeamClipped(	msg,
						inp->elmId,
						inp->elmEnv,
						&clippingPlane,
						isClipped ) ;
	} else if(  xData->parsedElmType == VS_gI_Joint ) {
			VSdrwIsJointClipped(	msg,
						inp->elmId,
						inp->elmEnv,
						&clippingPlane,
						isClipped ) ;
	} else {
		VSdrwPrintf( "!!! WARNING: is-element-clipped not implemented for %s\n",
				xData->parsedElmDesc ) ;
			*msg = MSSUCC ; isClipped = FALSE ;
	}
	return *msg & 1 ;

} /* VSdrwIsElementClipped */
/*----------------------------------------------------------------------------*/
int VSdrwIsPlateClipped( msg, plId, plEnv, clippingPlane, isClipped )

long			*msg ;		/* OUT: Completion code		*/
const struct GRid	*plId ;		/* IN : Id of plate		*/
const struct GRmd_env	*plEnv ;	/* IN : Module env. of plate	*/
struct IGRplane		*clippingPlane ;/* IN : Clipping plane		*/
int		*isClipped ; {		/* OUT: TRUE/FALSE		*/

	long			sts ;
	int			i,
				numgrps		= 0,
				*numpts		= NULL ;
	IGRpoint		**pts		= NULL ;
	IGRvector		**tans		= NULL ;
	BSpair			**pars		= NULL ;
	struct GRid		botSf ;
	struct IGRbsp_surface	*botGeom	= NULL ;

	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
						msg, VS_K_plTopSfPath,
						&botSf, NULL, NULL ),
			senderid= NULL_OBJID,
			targetid= plId->objid,
			targetos= plId->osnum ) ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	vs$get_geometry(	msg	= msg,
				grobjId	= &botSf,
				grobjEnv= plEnv,
				geometry= &botGeom ) ;
	__CheckRC( 1, *msg, "vs$get_geometry", wrapup ) ;

	BSsf_pl_int(	clippingPlane->point,
			clippingPlane->normal,
			botGeom,
			FALSE,
			&numgrps,
			&numpts,
			&pts,
			&tans,
			&pars,
			msg ) ;

	*isClipped = BSOKAY( *msg ) ? numgrps != 0 : FALSE ;

	_FREE( numpts ) ;
	if( pts ) {
		for( i = 0 ; i < numgrps ; i++ ) {
			_FREE( pts[i] ) ;
		}
		free( (char *) pts ) ;
	}
	if( pars ) {
		for( i = 0 ; i < numgrps ; i++ ) {
			_FREE( pars[i] ) ;
		}
		free( (char *) pars ) ;
	}
	if( tans ) {
		for( i = 0 ; i < numgrps ; i++ ) {
			_FREE( tans[i] ) ;
		}
		free( (char *) tans ) ;
	}
	*msg = MSSUCC ;	
	wrapup :
		_FREE( botGeom ) ;
		return *msg & 1 ;

} /* VSdrwIsPlateClipped */
/*----------------------------------------------------------------------------*/
int VSdrwIsBeamClipped( msg, bmId, bmEnv, clippingPlane, isClipped )

long			*msg ;		/* OUT: Completion code		*/
const struct GRid	*bmId ;		/* IN : Id of beam		*/
const struct GRmd_env	*bmEnv ;	/* IN : Module env. of beam	*/
const struct IGRplane	*clippingPlane ;/* IN : Clipping plane		*/
int			*isClipped ; {	/* OUT: TRUE/FALSE		*/

	long			sts ;
	struct GRobj_env	bmAxis ;
	struct IGRbsp_curve	*axisGeom	= NULL ;

	*isClipped	= FALSE ;

	sts = om$send(	msg	= message VSbeam.VSgetSupportAxis(
				       msg, (struct GRmd_env*) bmEnv, &bmAxis ),
			senderid= NULL_OBJID,
			targetid= bmId->objid,
			targetos= bmId->osnum ) ;
	__CheckRC( sts, *msg, "VSbeam.VSgetSupportAxis", wrapup ) ;

	/*
	 * Have abstract geometry evaluated in beam coordinate system.
	 */
	if( bmEnv->_MATRIX_TYPE != MAIDMX ) {
		VSmulmx(	bmEnv->_MATRIX,
				bmAxis._matrix,
				bmAxis._matrix,
				&bmAxis._matrix_type ) ;
	}
	vs$get_geometry(	msg	= msg,
				grobjId	= &bmAxis._grid,
				grobjEnv= &bmAxis.mod_env,
				geometry= &axisGeom ) ;
	__CheckRC( 1, *msg, "vs$get_geometry", wrapup ) ;

	*isClipped = vs$isPlaneClippingCurve(	cvGeom	= axisGeom,
						plane	= clippingPlane ) ;

	wrapup :
		_FREE( axisGeom ) ;
		*msg = MSSUCC ;
		return *msg & 1 ;

} /* VSdrwIsBeamClipped */
/*----------------------------------------------------------------------------*/
int VSdrwIsJointClipped( msg, jnId, jnEnv, clippingPlane, isClipped )

long			*msg ;		/* OUT: Completion code		*/
const struct GRid	*jnId ;		/* IN : Id of joint		*/
const struct GRmd_env	*jnEnv ;	/* IN : Module env. of joint	*/
const struct IGRplane	*clippingPlane ;/* IN : Clipping plane		*/
int			*isClipped ; {	/* OUT: TRUE/FALSE		*/

	long			sts ;
	int			i,
				jnCvCount ;
	struct GRid		jnGroup,
				*jnCvIds	= NULL ;
	struct IGRbsp_curve	*cvGeom		= NULL ;

	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
						msg, VS_K_jnGrCmpName,
						&jnGroup, NULL, NULL ),
			senderid= NULL_OBJID,
			targetid= jnId->objid,
			targetos= jnId->osnum ) ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	{
	  OM_S_CHANSELECT toCmps ;

	  ems$make_chanselect( chan_label    = GRcmpowner_to_components,
	  		       chan_selector = &toCmps ) ;
	  VS_GetChanObjWithMalloc( &jnGroup, &toCmps, &jnCvCount, &jnCvIds ) ;
	}
	if( !jnCvCount ) goto wrapup ;

	for( i = 0 ; i < jnCvCount ; i++ ) {
		vs$get_geometry(	msg	= msg,
					grobjId	= jnCvIds + i,
					grobjEnv= jnEnv,
					geometry= &cvGeom ) ;
		__CheckRC( 1, *msg, "vs$get_geometry", wrapup ) ;

		*isClipped = vs$isPlaneClippingCurve(
						cvGeom	= cvGeom,
						plane	= clippingPlane ) ;

		_FREE( cvGeom ) ; cvGeom = NULL ;

		if( *isClipped ) break ;
	}
	wrapup :
		*msg = MSSUCC ;
		if( jnCvCount ) _FREE( jnCvIds ) ;
		return *msg & 1 ;

} /* VSdrwIsJointClipped */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;
