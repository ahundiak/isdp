/* $Id: VSjnplbmjnt.I,v 1.1.1.1 2001/01/04 21:10:47 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/vsjoint/VSjnplbmjnt.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSjnplbmjnt.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:47  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.3  1998/03/27  13:56:18  pinnacle
# Replaced: vsjoint/VSjnplbmjnt.I for:  by manoj for struct
#
# Revision 1.2  1997/11/14  12:55:46  pinnacle
# Replaced: vsjoint/VSjnplbmjnt.I for:  by svkadamb for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			suresh		modification 
 *      03/27/98	suresh		added mising prototype
 ***************************************************************************/
/*
	I/STRUCT
*/ 
class implementation VSjoint ;

#include "EMSmsgdef.h"
#include "vsplatedef.h"
#include "vsbeamdef.h"
#include "vssectiondef.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
#include "DImacros.h"

extern long VSfindPlateToBeamJoints();
/*----------------------------------------------------------------------------*/
method VScstPlBmJoint(	long			*msg ;
			struct GRobj_env	elements[2] ;
			VSdspRep		myRep ;
			struct GRvg_construct	*cst ;
			int			jType ;
			int			weldSide ;
			struct GRid		*grJoint ) {

	long		sts ;	/* OM return code		*/
	struct GRobj_env
			*plate,		/* Input plate			*/
			*beam,		/* Input beam			*/
			*plSide = NULL,	/* Pointer to plate side	*/
			plBot,		/* Bottom surface of plate 	*/
			plTop,		/* Top    surface of plate 	*/
			bmSol,		/* Solid of beam		*/
			bmFlg ; 	/* Flange inferior exter. of bm	*/
	int		getTop,		/* Need top of plate ?		*/
			getTopABS,	/* Need abs. top of plate ?	*/
			getBot,		/* Need bottom of plate ?	*/
			getBotABS,	/* Need bottom of plate ?	*/
			getSol,		/* Nedd solid of beam ?		*/	
			getFlg ;	/* Need flange inf. ext. of bm ?*/
	VSdspRep	rep ;		/* Of beam			*/

	SetProc( VSjoint_VScstPlBmJoint ) ; Begin ; __DBGpr_me() ;

	/*
	 * Make out which is the plate and which is the beam from the input
	 * elements. The following rigmarole is an attempt to optimize the
	 * search of the matching (coincident) surfaces between the plate and
	 * the beam. If the input beam is a stiffener and the input plate is
	 * the one stiffened by the stiffener, the the search is over since
	 * we know how the beam was put on the plate hence which surfaces
	 * match.
	 * There's a repetition of swith statement here: although everything
	 * could have been done in one switch, I found it more readable to
	 * decompose the steps :
	 *	1) find the case in which we are
	 *	2) get graphics needed
	 *	3) take appropriate action
	 */
	switch( jType ) {
		case VS_K_J_PL_BM :
		case VS_K_J_BT_ST :
		case VS_K_J_TP_ST : plate = elements + 0 ;
				    beam  = elements + 1 ; break ;
		case VS_K_J_BM_PL :
		case VS_K_J_ST_BT :
		case VS_K_J_ST_TP : plate = elements + 1 ;
				    beam  = elements + 0 ; break ;
		default		  : vs$inv_arg() ;
	}

	sts = om$send(	msg	= message ACncpx.ACget_NV_rep( &rep ),
			targetid= beam->_objid,
			targetos= beam->_osnum ) ;
	if( !( rep & AC_3D_REP ) ) {
		*msg = EMS_E_InvalidCase ; sts = OM_W_ABORT ; goto wrapup ;
	} 


#ifdef vsDEBUG
	printf( "\tPlate" ) ; ShowObj( &plate->_grid ) ;
	printf( "\tBeam " ) ; ShowObj( &beam->_grid  ) ;
#endif

	getTop = getTopABS = getBot = getBotABS = getSol = getFlg = FALSE ;
	switch( jType ) {
		case VS_K_J_ST_BT :
		case VS_K_J_BT_ST :
		case VS_K_J_ST_TP :
		case VS_K_J_TP_ST :
		case VS_K_J_PL_BM :
		case VS_K_J_BM_PL : getTop = getBot = getSol = TRUE ; break ;
		/*
		case VS_K_J_ST_BT :
		case VS_K_J_BT_ST : getBotABS = getFlg = TRUE ; break ;
		case VS_K_J_ST_TP :
		case VS_K_J_TP_ST : getTopABS = getFlg = TRUE ; break ;
		*/
	}

	if( getBot || getBotABS ) {
		char *n = getBot ? VS_K_plBotSfPath : VS_K_plBotSfPathABS ;

		__DBGpr_str( "Plate side", n ) ;
		sts = om$send(	msg	= message NDmacro.ACreturn_foot(
				     		msg, n,
				     		&plBot._grid, NULL, NULL ),
				targetid= plate->_objid,
				targetos= plate->_osnum ) ;
		__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

		plSide = &plBot ;
	}

	if( getTop || getTopABS ) {
		char *n = getTop ? VS_K_plTopSfPath : VS_K_plTopSfPathABS ;

		__DBGpr_str( "Plate side", n ) ;
		sts = om$send(	msg	= message NDmacro.ACreturn_foot(
				     		msg, n,
				     		&plTop._grid, NULL, NULL ),
				targetid= plate->_objid,
				targetos= plate->_osnum ) ;
		__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

		plSide = &plTop ;
	}

	if( getSol ) {
		sts = om$send(	msg	= message NDmacro.ACreturn_foot(
				     		msg, VS_K_bmGrCmpName,
				     		&bmSol._grid, NULL, NULL ),
				targetid= beam->_objid,
				targetos= beam->_osnum ) ;
		__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;
	}

	if( getFlg ) {
		GRname flg ;

		DIstmcpy( flg, VS_K_bmGrCmpName,
			 VS_K_bmBody, VS_K_nmFlgInfE, NULL ) ;

		__DBGpr_str( "Flange", flg ) ;
		sts = om$send(	msg	= message NDmacro.ACreturn_foot(
				     		msg, flg,
				     		&bmFlg._grid, NULL, NULL ),
				targetid= beam->_objid,
				targetos= beam->_osnum ) ;
		__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;
	}

	plTop.mod_env	= plBot.mod_env	= plate->mod_env ;
	bmFlg.mod_env	= bmSol.mod_env	= beam->mod_env ;

	switch( jType ) {
		case VS_K_J_ST_BT :
		case VS_K_J_BT_ST :
		case VS_K_J_ST_TP :
		case VS_K_J_TP_ST :

		case VS_K_J_PL_BM :
		case VS_K_J_BM_PL :
			sts = VSfindPlateToBeamJoints( msg, &plBot, &plTop,
							&bmSol, cst, 
							weldSide, grJoint ) ;
			__CheckRC( sts, *msg, "VSfindPlateToBeamJoints", wrapup ) ;
			break ;
/*
	No need to handle it seperatle for stiffeners _ Suresh
		case VS_K_J_ST_BT :
		case VS_K_J_BT_ST :
		case VS_K_J_ST_TP :
		case VS_K_J_TP_ST :
			sts = VSfindPlateToStfnJoints( msg, plSide, &bmFlg,
							cst, grJoint ) ;
			__CheckRC( sts, *msg, "VSfindPlateToStfnJoints", wrapup ) ;
			break ;
*/

	}


	if( *msg & 1 ) {
		struct GRid	moi ;

		moi.objid	= my_id ;
		moi.osnum	= OM_Gw_current_OS ;
		VSlinkGroup( msg, grJoint, &moi ) ;
	}

	wrapup :
		End
		return sts ;

} /* method VScstPlBmJoint */
/*----------------------------------------------------------------------------*/

end implementation VSjoint ;


