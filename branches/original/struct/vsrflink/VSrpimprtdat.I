/*
	I/STRUCT
*/ 
class implementation VSrflPlate ;

#include "OMmacros.h"
#include "EMSutlmacros.h"
#include "EMSopt.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSimportData( long *msg ; int placement ; struct GRobj_env *fromPlate ) {

	long			sts ;		/* OM return code	*/
	int			cnt,
				repChanged ;
	struct GRid		parentFoot,	/* Foot of parent plate	*/
				moi ;		/* Who else ?		*/
	VSpartAttr		myAttr ;	/* My part attributes	*/
	VSplateAttr		myInfo ;	/* Some attributes	*/
	struct ACdb_info	dbInfo ;	/* Info for RDB		*/
	VSdspRep		parentRep ;

	repChanged = FALSE ;
	sts = om$send(	msg     = message ACncpx.ACget_NV_rep( &parentRep ),
			targetid= fromPlate->_objid,
			targetos= fromPlate->_osnum ) ;
	__CheckRC( sts, 1, "ACncpx.ACget_NV_rep", wrapup ) ;

	/*
	 * At placement, take parent's representation and symbology
	 */
	if( placement ) {
		VSdspRep		myRep ;	/* My display repres.	*/
		struct GRsymbology	mySymb ;/* My symbology		*/

		myRep = parentRep ;

		__DBGpr_int( "My rep", myRep ) ;
		sts = om$send(	msg     = message ACncpx.ACput_NV_rep( myRep ),
				targetid= my_id ) ;

		sts = om$send(	msg     = message GRvg.GRgetsymb( msg, &mySymb),
				targetid= fromPlate->_objid,
				targetos= fromPlate->_osnum ) ;
		__CheckRC( sts, *msg, "GRvg.GRgetsymb", wrapup ) ;
		
		sts = om$send(	msg     = message GRvg.GRputsymb( msg, &mySymb),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;

		om$send(msg	= message ACdb_info.ACget_db_info(
								msg, &dbInfo ),
			targetid= fromPlate->_objid,
			targetos= fromPlate->_osnum ) ;

		om$send(msg	= message ACdb_info.ACset_db_info(
								msg, &dbInfo ),
			targetid= my_id ) ;
	}

	/*
	 * Get attributes of parents.
	 */
	myAttr.Iwant	= VS_m_All ;
	myAttr.specific	= (void *) &myInfo ;
	sts = om$send(	msg	= message GRvg.GRgetattr( msg, (char *) &myAttr ),
			targetid= fromPlate->_objid,
			targetos= fromPlate->_osnum ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

	__DBGpr_int( "Orientation", myInfo.orientation ) ;

	/*
	 * NOTE: If parent has a collection of user attributes, it will be
	 * copied to the same Object Space as this object.
	 */
	if( IF_NULL_OBJID( myAttr.usrAttr.objid ) ) {
		myAttr.Iwant &= ~VS_m_UsrAttr ;
	}

	/*
	 * Since we use are base surface as support, the offset is no longer
	 * needed. In a "regular" plate, the offset is that between its
	 * support and its base surface. Likewise we grow the plate out of
	 * the base surface, hence we force the orientation.
	 */
	myInfo.offset = 0. ;
	myInfo.orientation = VS_K_USE_NAT_NORM ;

	__DBGpr_int( "Forced orientation", myInfo.orientation ) ;

	/*
	 * Now feed attributes to self.
	 */
	sts = om$send(	msg	= message GRvg.GRputattr( msg, (char *) &myAttr ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "GRvg.GRputattr", wrapup ) ;

	/*
	 * Get mapping to retrieve top and bottom surfaces from parent and
	 * store it. Must force parent plate to 3D if not already in 3D to
	 * get the indexing into the solid.
	 */
	if( !( parentRep & AC_3D_REP ) ) {
		__DBGpr_com( "Forcing parent's rep..." ) ;
		sts = om$send(	msg     = message ACncpx.ACput_NV_rep( AC_3D_REP ),
				targetid= fromPlate->_objid,
				targetos= fromPlate->_osnum ) ;
		repChanged = TRUE ;

		sts = om$send(	msg     = message NDnode.NDs_compute_node(
						msg, 0, &fromPlate->mod_env ),
				targetid= fromPlate->_objid,
				targetos= fromPlate->_osnum ) ;
		__CheckRC( sts, *msg, "NDnode.NDs_compute_node", wrapup ) ;

				
	}

	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
							msg,
							VS_K_plGrCmpName,
							&parentFoot,
							NULL,
							NULL ),
			targetid= fromPlate->_objid,
			targetos= fromPlate->_osnum ) ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	{ OM_S_CHANSELECT toComps ;
	  ems$make_chanselect( chan_label    = GRcmpowner_to_components,
	  		       chan_selector = &toComps ) ;
	  sts = om$get_channel_count(	p_chanselect	= &toComps,
					objid		= parentFoot.objid,
					osnum		= parentFoot.osnum,
					count		= (OMuint *) &cnt ) ;
	}
	if( sts & 1 ) {
		GRname			cmpNames[2] ;
		int			map[2] ;

#ifdef vsDEBUG
	ShowObj( &parentFoot ) ; ShowObj( &fromPlate->_grid ) ;
#endif
		__DBGpr_int( "Getting mapping, face count", cnt ) ;		
		sts = om$send( msg	= message VSplate.VStopBottomMapping(
						msg, cnt, map, cmpNames ),
				targetid= fromPlate->_objid,
				targetos= fromPlate->_osnum ) ;
		__CheckRC( sts, *msg, "VSplate.VStopBottomMapping", wrapup ) ;

		__DBGpr_int( "Map[0]", map[0] ) ;
		__DBGpr_int( "Map[1]", map[1] ) ;
		me->map[0] = map[0] ; me->map[1] = map[1] ; 
	} else {
		sts = OM_S_SUCCESS ;
	}


	if( placement ) {
		long	rc1,
			rc2 ;
		moi.objid = my_id ; moi.osnum = OM_Gw_current_OS ;
		rc1 = VSfindFindNameForRflElem( &rc2, &fromPlate->_grid, &moi );
	}

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		if( repChanged ) {
			long	rc1,
				rc2 ;
			rc1 = om$send(	msg     = message ACncpx.ACput_NV_rep(
								parentRep ),
					targetid= fromPlate->_objid,
					targetos= fromPlate->_osnum ) ;

			rc1 = om$send(	msg     = message NDnode.NDs_compute_node(
						&rc2, 0, &fromPlate->mod_env ),
					targetid= fromPlate->_objid,
					targetos= fromPlate->_osnum ) ;
				
		}
		return sts ;

} /* method VSimportData */
/*----------------------------------------------------------------------------*/

end implementation VSrflPlate ;

