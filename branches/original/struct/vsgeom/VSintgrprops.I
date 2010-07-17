/* $Id $  */

/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/vsgeom/VSintgrprops.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSintgrprops.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:40  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1999/04/14  19:08:04  pinnacle
# TR179900848, "mass" problem fixed, "twisted" problem still open.
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      04/14/99        ylong           TR179900484
 *
 * -------------------------------------------------------------------*/

/*
	I/STRUCT

	VSgetMassProps interfaced by macro vs$get_mass_props,
	VSgetAreaProps interfaced by macro vs$get_area_props, #define'd in
	"vsmeasmacros.h".
*/
class implementation EMSsurface ;

#include <stdlib.h>
#include <math.h>
#include "OMmacros.h"
#include "msdef.h"
#include "ms.h"
#include "msmacros.h"
#include "bstypes.h"
#include "bsparameters.h"
#include "EMSutlmacros.h"
#include "emsmass.h"
#include "vsglobalmsg.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "maidmx.h"
#include "matrnmx.h"
#include "bsdistptpt.h"
#include "bsdistptpts.h"
#include "vsgetchanobj.h"
#include "vsvecmxproto.h"

from GRowner		import	GRget_number_components ;
from EMSmassprop	import	EMinitialize,
				EMset_density,
				EMget_density,
				EMget_gloloc,
				EMset_type ;

extern OMuword	OPP_EMSmassprop_class_id ;
/*----------------------------------------------------------------------------*/
static long VSget_massprop_obj( msg, surface, MassObj )

long		*msg ;
struct GRid	*surface ;
struct GRid	*MassObj ; {

	long		sts ;		/* OM return code		*/
	OM_S_CHANSELECT Notify ;	/* Notification channel		*/
	OMuword		MassOs = 0 ;	/* Objid of mass object		*/
	OM_S_OBJID	MassId ;	/* Osnum of mass object		*/
	struct GRid	*objects ;	/* List of objects on channel	*/
	int		u,		/* Loop index			*/
			count ;		/* Of objects on channel	*/

	MassObj->objid = MassId = NULL_OBJID ; objects = NULL ;

	ems$make_chanselect(	chan_label	= GRnotify_notification,
				chan_selector	= &Notify ) ;
	
	/*
	 * See if there is already and EMSmassprop object on notification
	 * channel.
	 */
	sts = VS_GetChanObjWithMalloc( surface, &Notify, &count, &objects ) ;
	*msg = sts ? MSSUCC : MSFAIL ;
	__CheckRC( 1, *msg, "VS_GetChanObjWithMalloc", wrapup ) ;

	for( u = 0 ; u < count ; u++ ) {
		if( vs$is_ancestry_valid(
				object	= objects + u,
				classid	= OPP_EMSmassprop_class_id ) ) {
			MassId = objects[u].objid ;
			MassOs = objects[u].osnum ;
			break ;
		}
	}

	if( IF_NULL_OBJID( MassId ) ) {
		/*
		 * Construct mass properties object.
		 */
		struct GRvg_construct cst ;

		cst.msg  	= msg ;
		/*
		 * Must set newflag to TRUE.
		 */
		cst.newflag	= TRUE ;
		cst.geometry	= NULL ;

		MassOs = surface->osnum ;
		*msg = EMS_E_OMerror ;
		sts = om$construct(
			classid	= OPP_EMSmassprop_class_id,
			osnum	= MassOs,
			p_objid	= &MassId,
			msg	= message GRgraphics.GRconstruct( &cst ) ) ;
		__CheckRC( sts, *msg, "om$construct(EMSmassprop)", wrapup ) ;

		/*
		 * Connect it to surface.
		 */
		{ OM_S_CHANSELECT Masspr ;

		  Masspr.type       = OM_e_name ;
		  Masspr.u_sel.name = "EMSmassprop.to_object",

		  sts = om$send( msg	= message Root.connect(
							Masspr,
							GRDGNLIMITS_MAX_I,	
							surface->objid,
							surface->osnum,
							Notify,
							0 ),
				 senderid= MassId,
				 targetid= MassId,
				 targetos= MassOs ) ;
		  __CheckRC( sts, 1, "Root.connect", wrapup ) ;
		}

		/*
		 * Now do some initialization stuff.
		 */
		sts = om$send(	msg	= message EMSmassprop.EMinitialize(
									msg ),
				senderid= MassId,
				targetid= MassId,
				targetos= MassOs ) ;
		__CheckRC( sts, *msg, "EMSmassprop.EMinitialize", wrapup ) ;

	}
	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		MassObj->objid = MassId ;
		MassObj->osnum = MassOs ;
		_FREE( objects ) ;
		return sts ;

} /* VSget_massprop_obj */
/*----------------------------------------------------------------------------*/
static long VSfillPropsArray( msg, opType, surface, env, density, propsArray )

long		*msg ;
int		opType ;
struct GRid	*surface ;
struct GRmd_env	*env ;
double		density ;
double		*propsArray ; {

	long		sts ;		/* OM return code		*/
	int		count,		/* Count of sub-surfaces	*/
			i ;		/* Loop-on-props index		*/
	struct GRid	MassObj ;	/* Mass props object		*/
	double		locProps[NUMB_PROPS] ;
	IGRpoint	inOri,
			outOri ;
	BSmatrix	gloLoc,
			gloLocWorld ;
	IGRboolean	world = TRUE ;
	IGRdouble	savTolerance ,
			newTolerance ;
	BSrc		bsRC ;

	sts = VSget_massprop_obj( msg, surface, &MassObj ) ;
	__CheckRC( sts, *msg, "VSget_massprop_obj", wrapup ) ;
	
	/*
	 * Get the tolerance and makeit more fine 
	 */

	BSxtractpar( &bsRC, BSTOLBASIS, &savTolerance );
	newTolerance = 0.1*savTolerance ;
	BSchangepar( &bsRC, BSTOLBASIS, newTolerance );

	sts = om$send(	msg	= message EMSmassprop.EMset_density(
								msg, density ),
			senderid= surface->objid,
			targetid= MassObj.objid,
			targetos= MassObj.osnum ) ;
	__CheckRC( sts, *msg, "EMSmassprop.EMset_density", wrapup ) ;

	sts = om$send(	msg	= message EMSmassprop.EMset_type( msg, opType ),
			senderid= surface->objid,
			targetid= MassObj.objid,
			targetos= MassObj.osnum ) ;
	__CheckRC( sts, *msg, "EMSmassprop.EMset_type", wrapup ) ;

	/*
	 * Retrieve the number of sub-surfaces in surface.
	 * Caution: object may not be subclass of GRowner.
	 */
	sts = om$send(	msg	= message GRowner.GRget_number_components(
								msg, &count ),
			targetid= surface->objid,
			targetos= surface->osnum,
			senderid= surface->objid ) ;
	if( !( sts & 1 & *msg ) ) count = 0 ;

	for( i = 0 ; i < NUMB_PROPS ; i++ ) propsArray[i] = locProps[i] = 0 ;

	switch( opType ) {

		IGRvector	nullVect ;	/* Null vector (0,0,0)	*/
		double		diagonal ;	/* Of range box		*/
		GRrange 	surfRange ;	/* Range of surface	*/
		BSrc		rc ;		/* BS completion code	*/

		case MASS_PROPERTIES :
		sts = om$send(	msg	= message GRgraphics.GRgetrang(
							msg,
							&env->_MATRIX_TYPE,
							env->_MATRIX,
							&world,
							surfRange ),
				targetid= surface->objid,
				targetos= surface->osnum,
				senderid= surface->objid ) ;
		__CheckRC( sts, *msg, "GRgraphics.GRgetrang", wrapup );

                // TR179900484 by ylong. change diagonal based on mass_prop.u
		diagonal = BSdistptpts( &rc, surfRange, surfRange + 3 ) ;
		diagonal *= 0.2 ;

		sts = om$send(	msg	= message EMSsurface.EMmassprop(
							msg,
							count,
							diagonal,
							env,
							1.,
							VSzerovc( nullVect ),
							&density,
							locProps ),
				targetid= surface->objid,
				targetos= surface->osnum,
				senderid= surface->objid ) ;
		__CheckRC( sts, *msg, "EMSsurface.EMmassprop", wrapup ) ;

		break ;

		case AREA_PROPERTIES :

		sts = om$send(	msg	= message EMSsurface.EMareaprop(
							msg,
							FALSE,
							count,
							env,
							1.,
							VSzerovc( nullVect ),
							locProps ),
				targetid= surface->objid,
				targetos= surface->osnum,
				senderid= surface->objid ) ;
		__CheckRC( sts, *msg, "EMSsurface.EMareaprop", wrapup ) ;

		break ;

		default :	*msg = MSINARG ; break ;

	}

	sts = om$send(	msg	= message EMSmassprop.EMget_gloloc(
								msg, gloLoc ),
			senderid= surface->objid,
			targetid= MassObj.objid,
			targetos= MassObj.osnum ) ;

	VSvccpy( outOri, VSvccpy( inOri, locProps + 2 ) ) ;
	for( i = 0 ; i < 9 ; i++ ) gloLocWorld[i  ] = 0. ;
	for( i = 0 ; i < 3 ; i++ ) gloLocWorld[i*4] = 1. ;
        MScnvtprop( locProps, inOri, gloLoc, propsArray, outOri, gloLocWorld ) ;

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		/*
		 * Clear status field filled by EM*props.
		 */
		ex$message( msgnumb = VS_gI_EmptyMessage ) ;
		/*
		 * Change back to tolerance to its original value
	 	 */
		BSchangepar( &bsRC, BSTOLBASIS, savTolerance );

		return sts ;

} /* VSfillPropsArray */
/*----------------------------------------------------------------------------*/
static void VSxformMassProps( xform, cog, MofI, area, volume, mass )

IGRmatrix	xform ;
IGRpoint	cog ;
double		MofI[6] ;
double		*area ;
double		*volume ;
double		*mass ; {

	short		_4 = 4 ;
	long		RC ;
	short		type ;
	IGRmatrix	Mom,
			xformInv ;
	double		scale ;
	double		scaleSqu ;
	double		scaleCub ;

	enum {		IXX	= 0,
			IYY	= 1,
			IZZ	= 2,
			IXY	= 3,
			IYZ	= 4,
			IZX	= 5 } ;

	/*
	 * We suppose that if there is a scaling, it is uniform and is thus
	 * given by the norm of the 1st column vector.
	 */
	scaleSqu=   xform[0] * xform[0]
		  + xform[4] * xform[4]
		  + xform[8] * xform[8] ;
	scale   = sqrt( scaleSqu ) ;
	scaleCub= scale * scaleSqu ;

	if( area	) *area		*= scaleSqu ;
	if( volume	) *volume	*= scaleCub ;
	if( mass	) *mass		*= scaleCub ;
	if( cog		) VSmxprodpt( xform, cog, cog ) ;

	if( MofI ) {
		Mom[ 0] = MofI[(int)IXX] ;
		Mom[ 1] = MofI[(int)IXY] ;
		Mom[ 2] = MofI[(int)IZX] ;
		Mom[ 3] = 0. ;
		Mom[ 4] = MofI[(int)IXY] ;
		Mom[ 5] = MofI[(int)IYY] ;
		Mom[ 6] = MofI[(int)IYZ] ;
		Mom[ 7] = 0. ;
		Mom[ 8] = MofI[(int)IZX] ;
		Mom[ 9] = MofI[(int)IYZ] ;
		Mom[10] = MofI[(int)IZZ] ;
		Mom[11] = 0. ;
		Mom[12] = 0. ;
		Mom[13] = 0. ;
		Mom[14] = 0. ;
		Mom[15] = 1. ;

		MAtrnmx( &RC, &_4, xform, xformInv ) ;
		VSmulmx( xformInv, Mom, Mom, &type ) ;
		VSmulmx( Mom, xform, Mom, &type ) ;

		MofI[(int)IXX] = Mom[ 0] * scaleCub ;
		MofI[(int)IXY] = Mom[ 1] * scaleCub ;
		MofI[(int)IZX] = Mom[ 2] * scaleCub ;
		MofI[(int)IYY] = Mom[ 5] * scaleCub ;
		MofI[(int)IYZ] = Mom[ 6] * scaleCub ;
		MofI[(int)IZZ] = Mom[10] * scaleCub ;
	}

} /* VSxformMassProps */
/*----------------------------------------------------------------------------*/
long VSgetMassProps( msg, surface, env, density,
			volume, area, centroid, moment, mass )

long		*msg ;
struct GRid	*surface ;
struct GRmd_env	*env ;
double		density,
		*volume,
		*area,
		moment[6],
		*mass ;
IGRpoint	centroid ; {

	long		sts ;
	double		massProps[NUMB_PROPS] ;
	struct GRmd_env	idEnv ;

	MAidmx( msg, idEnv._MATRIX ) ; idEnv._MATRIX_TYPE = MAIDMX ;
	idEnv.md_id = env->md_id ;

	sts = VSfillPropsArray(	msg,
				MASS_PROPERTIES,
				surface,
				&idEnv,
				density,
				massProps ) ;
	__CheckRC( sts, *msg, "VSfillPropsArray", wrapup ) ;

	if( env->_MATRIX_TYPE != MAIDMX ) {
		VSxformMassProps(	env->_MATRIX,
					massProps +  2,
					massProps +  5,
					massProps + 11,
					massProps +  0,
					massProps +  1 ) ;
	}
	if( volume	) *volume = massProps[ 0] ;
	if( mass	) *mass	  = massProps[ 1] ;
	if( area	) *area	  = massProps[11] ;

	if( centroid	) {
		int i ;
		for( i = 0 ; i < 3 ; i++ ) {
			centroid[i] = massProps[2+i] ;
		}
	}
	if( moment ) {
		int	i ;
		for( i = 0 ; i < 6 ; i++ ) {
			moment[i] = massProps[i+5] ;
		}
	}
	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		return sts ;

} /* VSgetMassProps */
/*----------------------------------------------------------------------------*/
long VSgetAreaProps( msg, surface, env, area, centroid, moment )

long		*msg ;
struct GRid	*surface ;
struct GRmd_env	*env ;
double		*area,
		moment[6] ;
IGRpoint	centroid ; {

	long		sts ;
	double		massProps[NUMB_PROPS] ;
	struct GRmd_env	idEnv ;

	MAidmx( msg, idEnv._MATRIX ) ; idEnv._MATRIX_TYPE = MAIDMX ;
	idEnv.md_id = env->md_id ;

	sts = VSfillPropsArray(	msg,
				AREA_PROPERTIES,
				surface,
				&idEnv,
				1.,
				massProps ) ;
	__CheckRC( sts, *msg, "VSfillPropsArray", wrapup ) ;

	if( env->_MATRIX_TYPE != MAIDMX ) {
		VSxformMassProps(	env->_MATRIX,
					massProps +  2,
					massProps +  5,
					massProps + 11,
					(double *) NULL,
					(double *) NULL ) ;
	}
	if( area	) *area	= massProps[11] ;
	if( centroid	) {
		int i ;
		for( i = 0 ; i < 3 ; i++ ) {
			centroid[i] = massProps[2+i] ;
		}
	}
	if( moment ) {
		int	i ;
		for( i = 0 ; i < 6 ; i++ ) {
			moment[i] = massProps[i+5] ;
		}
	}
	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		return sts ;

} /* VSgetAreaProps */
/*----------------------------------------------------------------------------*/

end implementation EMSsurface ;
