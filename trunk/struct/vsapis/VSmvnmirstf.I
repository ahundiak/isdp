/* $Id: VSmvnmirstf.I,v 1.1.1.1 2001/01/04 21:10:10 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vsapis/VSmvnmirstf.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSmvnmirstf.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:10  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.1  1996/02/20  23:45:26  pinnacle
# Created: ./vsapis/VSmvnmirstf.I by azuurhou for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			ef		creation date
 *
 ***************************************************************************/

class implementation VSbeam ;

#include <stdio.h>
#include "madef.h"
#include "exmacros.h"
#include "msdef.h"
#include "nddef.h"
#include "ndmacros.h"
#include "vsbmaxisdef.h"
#include "vsstfnrdef.h"
#include "vsqryrdbdef.h"
#include "vsRDBmacros.h"
#include "vsbeammacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

/*
 * Includes of function prototypes.
 */

from VSstfBeam	import VSgetPlateSide,
		       VSputPlateSide ;

from VSbeamAxis	import VSputPlateSide ;

/*----------------------------------------------------------------------------*/
long VSmove_and_mirror_stiffener( msg, stiffenerId )

long		*msg ;
struct GRid	*stiffenerId ; {

	/*
	 * This function is interfaced by macro 'vs$move_and_mirror_stiffener'.
	 */

	long			sts ;
	int			actualSide,
				newSide,
				type = ND_COMP ;
	struct	GRid		beamAxis ;
	VSpartAttr		attr ;
	VSbeamAttr		info ;
	int			hasDir ;
	IGRvector		xDir ;

	SetProc( VSmove_and_mirror_stiffener ) ; Begin

	__DBGpr_obj( "Stiffener", *stiffenerId ) ;

	/*
	 * Retrieve actual stiffener side.
	 */
	sts = om$send( msg	= message VSstfBeam.VSgetPlateSide( msg, 
								    &actualSide ),
		       senderid = NULL_OBJID,
		       targetid = stiffenerId->objid,
		       targetos = stiffenerId->osnum ) ;

	__CheckRC( sts, *msg, "VSstfBeam.VSgetPlateSide", wrapup ) ;

	/*
	 * Put the opposite side to stiffener.
	 */
	switch( actualSide ) {
		default				:
		case VS_K_stOnTopOfPlate	:
			newSide = VS_K_stOnBotOfPlate ;
			__DBGpr_com( "Actual side is TOP" ) ;
			__DBGpr_com( "New side will be BOTTOM" ) ;
			break ;
		case VS_K_stOnBotOfPlate	:
			newSide = VS_K_stOnTopOfPlate ;
			__DBGpr_com( "Actual side is BOTTOM" ) ;
			__DBGpr_com( "New side will be TOP" ) ;
			break ;
	}

	sts = om$send( msg	= message VSstfBeam.VSputPlateSide( msg, 
								    newSide ),
		       senderid = NULL_OBJID,
		       targetid = stiffenerId->objid,
		       targetos = stiffenerId->osnum ) ;

	__CheckRC( sts, *msg, "VSstfBeam.VSputPlateSide", wrapup ) ;

	sts = om$send( msg	= message VSbeam.VSgetXdirectionForCrossSectionCS(
								           msg, 
								           &hasDir, 
								           xDir ),
		       senderid = NULL_OBJID,
		       targetid = stiffenerId->objid,
		       targetos = stiffenerId->osnum ) ;

	__CheckRC( sts, *msg, "VSBeam.VSgetXdirect...", wrapup ) ;

	if( !hasDir ) {

		attr.Iwant	= VS_m_Symmetry ;
		attr.specific	= (void *) &info ;

		sts = om$send( msg	= message GRvg.GRgetattr( msg, 
								  (char *) &attr ),
			       senderid = NULL_OBJID,
			       targetid = stiffenerId->objid,
			       targetos= stiffenerId->osnum ) ;

		__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

		if( info.sym == VS_e_No_Symm )
			info.sym = VS_e_Y_Symm	;
		else
		if( info.sym == VS_e_Y_Symm  )
			info.sym = VS_e_No_Symm ;

		sts = om$send( msg	= message GRvg.GRputattr( msg, 
								  (char *) &attr ),
			       senderid = NULL_OBJID,
			       targetid = stiffenerId->objid,
			       targetos = stiffenerId->osnum ) ;

		__CheckRC( sts, *msg, "GRvg.GRputattr", wrapup ) ;
	}

	/*
	 * Retrieve the beam axis of stiffener.
	 */
	sts = VSgetBeamAxisOfStiffener( msg,
					stiffenerId,
					&beamAxis ) ;

	__CheckRC( sts, *msg, "VSgetBeamAxisOfStiffener", wrapup ) ;

	/*
	 * Put the opposite side to axis.
	 */
	switch( actualSide ) {
		case VS_K_stOnTopOfPlate	:
			newSide = VS_K_baOnBotOfPlate ;
			break ;
		case VS_K_stOnBotOfPlate	:
			newSide = VS_K_baOnTopOfPlate ;
			break ;
	}

	sts = om$send( msg	= message VSbeamAxis.VSputPlateSide( msg,
							             newSide ),
		       senderid = NULL_OBJID,
		       targetid = beamAxis.objid,
		       targetos = beamAxis.osnum ) ;

	__CheckRC( sts, *msg, "VSbeamAxis.VSputSideSupport", wrapup ) ;

	/*
	 * Recompute from axis, so axis and stiffener will recompute
	 * too.
	 */
	nd$wait_batch( l_obj_info	= &type,
		       type		= GR_GEOM_POSTED,
		       l_object 	= &beamAxis,
		       nb_obj		= 1 ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		End
		return sts ;

} /* VSmove_and_mirror_stiffener */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;
