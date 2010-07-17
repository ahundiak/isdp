/* $Id: VSbagetside.I,v 1.1.1.1 2001/01/04 21:10:13 cvs Exp $  */
/* $Id: VSbagetside.I,v 1.1.1.1 2001/01/04 21:10:13 cvs Exp $  */
/***************************************************************************
 * I/STRUCT
 *
 * File:	vsbmaxis/VSbagetside.I
 *
 * Description: Gets top or bottom of plate
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSbagetside.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:13  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.3  1998/02/20  20:05:02  pinnacle
# CR179800676
#
 *
 * History:
 * MM/DD/YY  AUTHOR    DESCRIPTION
 * 02/20/98  ah        CR179800676 - Allow axis to extend past edge of plate
 ***************************************************************************/

class implementation VSbeamAxis ;

#include <stdio.h>
#include "exmacros.h"
#include "vsbmaxisdef.h"
#include "vsplatedef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

/*----------------------------------------------------------------------------*/
method VSgetSideSupport( long			*msg ;
			 struct GRobj_env	*side ) {

	int			rc ;
	long			sts ;
	struct GRobj_env	plate ;
	char			*sidename ;
	int                     flag;
	
	side->_objid = NULL_OBJID ;

	/*
	 * Retrieve support plate.
	 */
	sts = om$send( msg	= message ACcpx.ACfind_temp_obj(
							       &rc,
							       VS_K_baPlateSupp,
							       &plate._grid ),
		       targetid = my_id ) ;
	*msg = rc & 1 ? MSSUCC : MSFAIL ;
	__CheckRC( sts, *msg, "ACcpx.ACfind_temp_obj", wrapup ) ;

	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
							msg,
							"",
							&plate._grid,
							&plate._matrix_type,
							plate._matrix ),
			targetid= plate._objid,
			targetos= plate._osnum ) ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	/*
	 * Retrieve side of support plate of axis.
	 */
	/* CR179800676 See note in construct feet
	if( (me->flagAttr & ~VS_K_baExtendAxis) == VS_K_baOnTopOfPlate )
		sidename = VS_K_plTopSfPathABS ;
	else	sidename = VS_K_plBotSfPathABS ;
	*/

	sts = om$send(msg = message VSbeamAxis.VSgetPlateSide(msg,&flag),
		      targetid = my_id);
	__CheckRC( sts, *msg, "VSbeamAxis.VSgetPlateSide", wrapup ) ;
	

	if(flag == VS_K_baOnTopOfPlate ) sidename = VS_K_plTopSfPathABS ;
	else	                         sidename = VS_K_plBotSfPathABS ;

	sts = om$send( msg = message NDmacro.ACreturn_foot( msg,
							    sidename,
							    &side->_grid,
							    NULL,
							    NULL ),
		       targetid = plate._objid,
		       targetos = plate._osnum ) ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	side->mod_env = plate.mod_env ;
	side->_md_os = side->_osnum ;

	ex$get_modid( mod_osnum = side->_md_os,
		      mod_id	= &side->_md_id ) ;

	wrapup :
		return sts ;

} /* method VSgetSideSupport */
/*----------------------------------------------------------------------------*/

end implementation VSbeamAxis ;






