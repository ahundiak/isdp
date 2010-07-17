/*
	I/STRUCT
*/
class implementation VSbeamcsCmd ;

#include <stdio.h>
#include "OMmacros.h"
#include "bstypes.h"
#include "vs.h"
#include "vspart.h"
#include "vsattr.h"
#include "vsdpb.h"
#include "vscmddef.h"
#include "vscmdmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bsdistptpts.h"
#include "vsconstrctcs.h"
#include "vsevalbeamcs.h"
#include "vsvirtualinf.h"
#include "vsvecmxproto.h"

from GRgraphics	import	GRconstruct ;
from VSbeam	import	VSgetSegmentEnds ;
/*----------------------------------------------------------------------------*/
method initCmd() {

	me->where.endNo 	= 0 ;
	me->where.cardPt	= VS_e_BOT_LEFT ;
	me->CS.objid		= NULL_OBJID ;
	me->classAttr		= (char *) &me->where ;

	return OM_S_SUCCESS ;

} /* method initCmd */
/*----------------------------------------------------------------------------*/
method cleanup() {

	if( !IF_NULL_OBJID( me->CS.objid ) ) {
		vs$bulk_display(	dpmode	= GRbe,
					count	= 1,
					grids	= &me->CS,
					theEnv	= &me->cstEnv ) ;
		vs$bulk_delete(	count	= 1,
				grids	= &me->CS,
				theEnv	= &me->cstEnv ) ;
	}
	return OM_S_SUCCESS ;

} /* method cleanup */
/*----------------------------------------------------------------------------*/
method changeCardPoint( long *msg ) {

	switch( me->where.cardPt ) {
		case VS_e_BOT_LEFT : me->where.cardPt = VS_e_BOT_RGHT ; break ;
		case VS_e_BOT_RGHT : me->where.cardPt = VS_e_UPP_RGHT ; break ;
		case VS_e_UPP_RGHT : me->where.cardPt = VS_e_UPP_LEFT ; break ;
		case VS_e_UPP_LEFT : me->where.cardPt = VS_e_BOT_LEFT ; break ;
	}
	return OM_S_SUCCESS ;

} /* method changeCardPoint */
/*----------------------------------------------------------------------------*/
method findCloserEnd( long *msg ) {

	long			sts ;		/* OM return code	*/
	IGRpoint		beamEnds[2] ;	/* Points at end of beam*/
	double			d0sq, d1sq,	/* Dist. to acc. point	*/
				*accPnt ;
	struct GRobj_env	beam ;		/* Located beam		*/
	struct GRmd_env		env ;
	struct GRid		id ;

	sts = om$send(	msg	= message VSlocateCmd.getLocObjs(
								msg, 1, &beam ),
			targetid= my_id ) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;

	/*
	 * Note: located beam may be an image of an original beam, we must get
	 * the transformation matrix orignal -> image and do the multiplication
	 *        mx returned by locate x mx( matrix orignal -> image )
	 */
	sts = VSgetVirtualInfo( msg, &beam._grid, &env, &id ) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;

	VSmulmx( beam._matrix, env._MATRIX, beam._matrix, &beam._matrix_type ) ;

	sts = om$send(	msg	= message VSbeam.VSgetSegmentEnds(
						msg, &beam.mod_env, beamEnds ),
			targetid= beam._objid,
			targetos= beam._osnum ) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;

	/*
	 * Find end closer to accept point.
	 */
	accPnt = &me->event1.event.button.x ;
	d0sq = BSdistptpts( msg, accPnt, beamEnds[0] ) ;
	d1sq = BSdistptpts( msg, accPnt, beamEnds[1] ) ;
	me->where.endNo = d0sq < d1sq ? 0 : 1 ;

	*msg = MSSUCC ;

	wrapup :
		me->ret = sts & 1 & *msg ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;
		return OM_S_SUCCESS ;

} /* method findCloserEnd */
/*----------------------------------------------------------------------------*/
method displayCS( long *msg ; int on ) {

	long			sts ;	/* OM return code	*/
	struct GRobj_env	beam ;

	sts = om$send(	msg	= message VSlocateCmd.getLocObjs(
								msg, 1, &beam ),
			targetid= my_id ) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;

	if( om$is_objid_valid(	objid	= me->CS.objid,
				osnum	= me->CS.osnum ) & 1 ) {
		/*
		 * Delete old CS.
		 */
		vs$bulk_display(	dpmode	= GRbe,
					count	= 1,
					grids	= &me->CS,
					theEnv	= &me->cstEnv ) ;

		vs$bulk_delete(	count	= 1,
				grids	= &me->CS,
				theEnv	= &me->cstEnv ) ;
	}
	if( on ) {
		IGRmatrix		mx ;
		struct GRvg_construct	cst ;
		int			w ;
		struct GRmd_env		env ;
		struct GRid		id ;

		vs$cnstDefaults(msg	= msg,
				symb_id	= me->ModuleInfo.md_id,
				symb	= &me->ActiveRep,
				level	= &me->ActiveLevel,
				display	= &me->ActiveDisplay ) ;
		vs$fill_cnst_list(
				Msg		= msg,
				Display		= &me->ActiveDisplay,
				Level		= me->ActiveLevel,
				Env_info	= &me->cstEnv,
				Cnst_list	= cst ) ;

		w = me->ActiveDisplay.weight ;
		me->ActiveDisplay.weight = 2 ;

		/*
		 * Note: located beam may be an image of an original beam, we
		 * must get the transormation matrix orignal -> image and do
		 * the multiplication
		 *        mx returned by locate x mx( matrix orignal -> image )
		 */
		sts = VSgetVirtualInfo( msg, &beam._grid, &env, &id ) ;
		if( !( sts & 1 & *msg ) ) goto wrapup ;

		VSmulmx( beam._matrix, env._MATRIX,
			 beam._matrix, &beam._matrix_type ) ;

		sts = VSevalBeamCS(
				msg,
				&beam,
				me->where.endNo,
				(enum VScardinal_point) me->where.cardPt,
				mx ) ;
		__CheckRC( sts, *msg, "VSevalBeamCS", wrapup ) ;

		me->ActiveDisplay.weight = w ;

		if( !( sts & 1 & *msg ) ) goto wrapup ;

		sts = VSconstructCS( msg, mx, &cst, &me->CS ) ;
		__CheckRC( sts, *msg, "VSconstructCS", wrapup ) ;

		vs$bulk_display(	dpmode	= GRbd,
					count	= 1,
					grids	= &me->CS,
					theEnv	= &me->cstEnv ) ;
	}

	wrapup :
		me->ret = sts & 1 & *msg ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;
		return OM_S_SUCCESS ;

} /* method displayCS */
/*----------------------------------------------------------------------------*/

end implementation VSbeamcsCmd ;
