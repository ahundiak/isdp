/* $Id: VSjnbmbmjnt.I,v 1.1.1.1 2001/01/04 21:10:43 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/vsjoint/VSjnbmbmjnt.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSjnbmbmjnt.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:43  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1997/11/14  13:23:12  pinnacle
# Replaced: vsjoint/VSjnbmbmjnt.I for:  by svkadamb for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			suresh		modification 
 ***************************************************************************/
/*
	I/STRUCT
*/ 
class implementation VSjoint ;

#include "EMSmsgdef.h"
#include "vsbeamdef.h"
#include "vssectiondef.h"
#include "vswelddef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

/*----------------------------------------------------------------------------*/
method VScstBmBmJoint(	long			*msg ;
			struct GRobj_env	beams[2] ;
			VSdspRep		myRep ;
			struct GRvg_construct	*cst ;
			int			weldSide ;
			struct GRid		*grJoint ) {

	long			sts ;		/* OM return code	*/
	struct GRobj_env	bmSol0,		/* Solid of beam #0	*/
				bmSol1 ;	/* Solid of beam #1	*/
	VSdspRep		rep ;		/* Of one beam		*/

	SetProc( VSjoint_VScstBmBmJoint ) ; Begin ; __DBGpr_me() ;

#ifdef vsDEBUG
	printf( "\tBeam 0 " ) ; ShowObj( &beams[0]._grid ) ;
	printf( "\tBeam 1 " ) ; ShowObj( &beams[1]._grid ) ;
#endif

	sts = om$send(	msg	= message ACncpx.ACget_NV_rep( &rep ),
			targetid= beams[0]._objid,
			targetos= beams[0]._osnum ) ;
	if( !( rep & AC_3D_REP ) ) {
		*msg = EMS_E_InvalidCase ; sts = OM_W_ABORT ; goto wrapup ;
	} 
	sts = om$send(	msg	= message ACncpx.ACget_NV_rep( &rep ),
			targetid= beams[1]._objid,
			targetos= beams[1]._osnum ) ;
	if( !( rep & AC_3D_REP ) ) {
		*msg = EMS_E_InvalidCase ; sts = OM_W_ABORT ; goto wrapup ;
	} 

	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
				     		msg, VS_K_bmGrCmpName,
				     		&bmSol0._grid, NULL, NULL ),
			targetid= beams[0]._objid,
			targetos= beams[0]._osnum ) ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
				     		msg, VS_K_bmGrCmpName,
				     		&bmSol1._grid, NULL, NULL ),
			targetid= beams[1]._objid,
			targetos= beams[1]._osnum ) ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	bmSol0.mod_env	= beams[0].mod_env ;
	bmSol1.mod_env	= beams[1].mod_env ;

	switch( weldSide ) {
		case VS_K_wldLeftSide  :
			__DBGpr_com(" Weld Left Side" );
			break ;
		case VS_K_wldRightSide :
			__DBGpr_com(" Weld Right Side" );
			break ;
		case VS_K_wldBothSides :
			__DBGpr_com(" Weld Both Sides" );
			break ;
	}
	sts = VSfindBeamToBeamJoints( msg, &bmSol0, &bmSol1, cst, weldSide, grJoint ) ;
	__CheckRC( sts, *msg, "VSfindBeamToBeamJoints", wrapup ) ;

	if( *msg == EMS_I_NoSolution ) *msg = EMS_E_NoSolution ;

	if( *msg & 1 ) {
		struct GRid	moi ;

		moi.objid	= my_id ;
		moi.osnum	= OM_Gw_current_OS ;
		VSlinkGroup( msg, grJoint, &moi ) ;
	}

	wrapup :
		End
		return sts ;

} /* method VScstBmBmJoint */
/*----------------------------------------------------------------------------*/

end implementation VSjoint ;

