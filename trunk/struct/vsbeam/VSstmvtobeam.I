/*
	I/STRUCT
*/ 
class implementation VSstfBeam ;

#include "exmacros.h"
#include "nddef.h"
#include "asmacros.h"
#include "EMSmsgdef.h"
#include "vsplatedef.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsophstproto.h"
/*----------------------------------------------------------------------------*/
long VSmoveStiffenerToBeam( msg, stiffener )

long			*msg ;
struct GRobj_env	*stiffener ; {

	long		sts ;		/* OM return code		*/
	VSopHistory	*history ;	/* History of stiffener		*/
	struct GRid	stfId,		/* Id of top stiffener		*/
			parents[4],	/* Parents of top stiffener	*/
			sideId,		/* Id of plate side		*/
			srcId ;		/* Id of source object on side	*/
	struct GRmd_env	stfEnv,		/* Environment of top stiffener	*/
			sideEnv ;	/* Environment of plate side	*/
	int		count,		/* ... of parents		*/
			side,		/* Side index of stiffened plate*/
			rc ;		/* ACattach's return code	*/
	char		*sideName ;	/* Side name of stiffened plate	*/

	history = NULL ;
	/*
	 * Get source stiffener on top of the history.
	 */
	sts = om$send(	msg	= message VSfeature.VSgetOperationHistory(
							msg,
							&stiffener->mod_env,
							&history ),
			senderid= stiffener->_objid,
			targetid= stiffener->_objid,
			targetos= stiffener->_osnum ) ;
	__CheckRC( sts, *msg, "VSfeature.VSgetOperationHistory", wrapup ) ;

	stfId.objid	= history->resultId ;
	stfId.osnum	= history->resultOs ;
	stfEnv		= history->resultEnv;

	/*
	 * Get parents of stiffener.
	 * 0 : plate
	 * 1 : curve
	 * 2 : private data
	 * 3 : collection of user attributes (optional).
	 */
	sts = om$send(	msg	= message NDnode.NDget_objects(	ND_ROOT,
								parents,
								4,
								NULL,
						/* From : */	0,
						/* To   : */	3,
								&count ),
			senderid= stfId.objid,
			targetid= stfId.objid,
			targetos= stfId.osnum ) ;
	__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup ) ;

	/*
	 * Find on which side of plate stiffener was placed.
	 */
	sts = om$send(	msg	= message VSstfBeam.VSgetPlateSide(
								msg, &side ),
			senderid= stfId.objid,
			targetid= stfId.objid,
			targetos= stfId.osnum ) ;
	__CheckRC( sts, 1, "VSstfBeam.VSgetPlateSide", wrapup ) ;

	switch( side ) {
		case VS_K_stOnTopOfPlate	:
				sideName = VS_K_plTopSfPathABS ;
				break ;
		case VS_K_stOnBotOfPlate	:
				sideName = VS_K_plBotSfPathABS ;
				break ;
		default				: vs$inv_arg() ;
	}

	/*
	 * Put a source object onto plate side.
	 */
	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
						msg, sideName, &sideId,
						&sideEnv._MATRIX_TYPE,
						sideEnv._MATRIX ),
			senderid= parents[0].objid,
			targetid= parents[0].objid,
			targetos= parents[0].osnum ) ;
	__CheckRC( sts, 1, "NDmacro.NDreturn_foot", wrapup ) ;

	sideEnv._MD_OS = sideId.osnum ;
	ex$get_modid( mod_osnum = sideEnv._MD_OS, mod_id = &sideEnv._MD_ID ) ;

	sts = as$make_source(	go_grid	= sideId,
				mod_env	= &sideEnv,
				as_grid	= &srcId ) ;
	__CheckRC( sts, 1, "as$make_source", wrapup ) ;

	/*
	 * Now change class of stiffener to VSsrcBeam.
	 */
	*msg = EMS_E_OMerror ;
	sts = om$change_class(	classname	= "VSsrcBeam",
				objid		= stfId.objid,
				osnum		= stfId.osnum ) ;
	__CheckRC( sts, 1, "om$change_class", wrapup ) ;

	/*
	 * Change parent #0 of new beam : it must be the plate side (in fact the
	 * source object on it).
	 */
	sts = om$send(	msg	= message NDnode.NDchange_connect(
						1, parents + 0, &srcId ),
			senderid= stfId.objid,
			targetid= stfId.objid,
			targetos= stfId.osnum ) ;
	__CheckRC( sts, 1, "NDnode.NDchange_connect", wrapup ) ;

	/*
	 * Now tell object to bind to new macro macro definition.
	 */
	sts = om$send(	msg	= message ACcpx.ACattach( &rc, "VSsrcBeam" ),
			senderid= stfId.objid,
			targetid= stfId.objid,
			targetos= stfId.osnum ) ;
	*msg = rc ? MSSUCC : MSFAIL ;

	sts 	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	wrapup :
		VSfreeOpHistory( history ) ;
		return sts ;

} /* VSmoveStiffenerToBeam */
/*----------------------------------------------------------------------------*/

end implementation VSstfBeam ;
