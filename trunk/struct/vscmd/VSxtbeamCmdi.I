/*
	I/STRUCT
*/
class implementation VSxtbeamCmd ;

#include <string.h>
#include "OMmacros.h"
#include "bstypes.h"
#include "vs.h"
#include "vspart.h"
#include "vsattr.h"
#include "vsplatedef.h"
#include "vsplate.h"
#include "vsoptdef.h"
#include "vsmiscmacros.h"
#include "vscmddef.h"
#include "vscmdmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bsdistptpts.h"
#include "vsophstproto.h"

from GRgraphics	import	GRconstruct ;
from VSfeature	import	VSgetOperationHistory ;
from VSbeam	import	VSextractProfile,
			VSgetSegmentEnds ;
from VSxtrBeam	import	VSgetExtendedEnd ;
/*----------------------------------------------------------------------------*/
method initCmd() {

	me->whichEnd 		= 0 ;
	me->classAttr		= (char *) &me->whichEnd ;
	me->xSection.objid	= NULL_OBJID ;

	return OM_S_SUCCESS ;

} /* method initCmd */
/*----------------------------------------------------------------------------*/
method cleanup() {

	if( !IF_NULL_OBJID( me->xSection.objid ) ) {
		vs$bulk_display(	dpmode	= GRbe,
					grids	= &me->xSection,
					theEnv	= &me->cstEnv ) ;
		vs$bulk_delete(	count	= 1,
				grids	= &me->xSection,
				theEnv	= &me->cstEnv ) ;
	}
	return OM_S_SUCCESS ;

} /* method cleanup */
/*----------------------------------------------------------------------------*/
method changeEnd( long *msg ) {

	if( me->availableEnds == 2 ) {
		switch( me->whichEnd ) {
			default:
			case 0 : me->whichEnd = 1 ; break ;
			case 1 : me->whichEnd = 0 ; break ;
		}
	}
	*msg = VS_K_ACT_SUCCESS ;
	return OM_S_SUCCESS ;

} /* method changeEnd */
/*----------------------------------------------------------------------------*/
method findCloserEnd( long *msg ) {

	long			sts ;		/* OM return code	*/
	IGRpoint		beamEnds[2] ;	/* Points at end of beam*/
	double			d0sq, d1sq ;	/* Dist. to acc. point	*/
	struct GRobj_env	beam ;		/* Located beam		*/
	VSopHistory		*history,	/* History of beam	*/
				*prevXtBm,	/* Previous extended bm.*/
				*h ;
	int			nbExtension ;

	history = NULL ;

	sts = om$send(	msg	= message VSlocateCmd.getLocObjs(
								msg, 1, &beam ),
			targetid= my_id ) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;

	sts = om$send(	msg	= message VSfeature.VSgetOperationHistory(
							msg,
							&beam.mod_env,
							&history ),
			targetid= beam._objid,
			targetos= beam._osnum ) ;
	__CheckRC( sts, *msg, "VSfeature.VSgetOperationHistory", wrapup ) ;

	nbExtension = 0 ; prevXtBm = NULL ;
	for( h = history ; h ; h = h->next ) {
		if( VS_OP_TYPE( h->resultType ) == VS_m_XTR_BEAM ) {
			nbExtension++ ;
			prevXtBm = h ;
		}
	}
	switch( nbExtension ) {
	double	*accPnt ;
	int	xtEnd ;

	case 2 :	/*
			 * Cannot extend anymore.
			 */
			me->availableEnds = 0 ; *msg = MSINARG ; break ;
	case 1 :	/*
			 * Find end where we can extend.
			 */
			me->availableEnds = 1 ;
			om$send(msg	= message VSxtrBeam.VSgetExtendedEnd(
								msg, &xtEnd ),
				targetid= prevXtBm->resultId,
				targetos= prevXtBm->resultOs ) ;

			switch( xtEnd ) {
				case 0 : me->whichEnd = 1 ; break ;
				case 1 : me->whichEnd = 0 ; break ;
			}
			*msg = MSSUCC ;
			break ;
	case 0 :/*
		 * Propose closest point.
		 */
		me->availableEnds = 2 ;
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
		me->whichEnd = d0sq < d1sq ? 0 : 1 ;

		*msg = MSSUCC ;
		break ;
	}

	wrapup :
		if( history ) VSfreeOpHistory( history ) ;
		me->ret = sts & 1 & *msg ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;
		return OM_S_SUCCESS ;

} /* method findCloserEnd */
/*----------------------------------------------------------------------------*/
method displaySection( long *msg ; int on ) {

	long			sts ;	/* OM return code	*/
	struct GRobj_env	beam ;

	sts = om$send(	msg	= message VSlocateCmd.getLocObjs(
								msg, 1, &beam ),
			targetid= my_id ) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;

	if( om$is_objid_valid(	objid	= me->xSection.objid,
				osnum	= me->xSection.osnum ) & 1 ) {
		/*
		 * Delete old section.
		 */
		vs$bulk_display(	dpmode	= GRhe,
					count	= 1,
					grids	= &me->xSection,
					theEnv	= &me->cstEnv ) ;

		vs$bulk_delete(	count	= 1,
				grids	= &me->xSection,
				theEnv	= &me->cstEnv ) ;
	}
	if( on ) {
		struct GRvg_construct	cst ;
		int			w ;

		vs$cnstDefaults(	msg	= msg,
					symb_id	= me->ModuleInfo.md_id,
					symb	= &me->ActiveRep,
					level	= &me->ActiveLevel,
					display	= &me->ActiveDisplay ) ;

		VSfixBeamRep(   me->ActiveRep.representation,
				&me->ActiveRep.representation ) ;

		vs$fill_cnst_list(
				Msg		= msg,
				Display		= &me->ActiveDisplay,
				Level		= me->ActiveLevel,
				Env_info	= &me->cstEnv,
				Cnst_list	= cst ) ;

		w = me->ActiveDisplay.weight ;
		me->ActiveDisplay.weight = 2 ;
		sts = om$send(	msg	= message VSbeam.VSextractProfile(
						msg,
						&beam.mod_env,
						NULL, NULL,
						(double) me->whichEnd,
						&cst,
						me->ActiveRep.representation,
						&me->xSection ),
				targetid= beam._objid,
				targetos= beam._osnum ) ;
		me->ActiveDisplay.weight = w ;

		__CheckRC( sts, *msg, "VSbeam.VSextractProfile", wrapup ) ;

		vs$bulk_display(	dpmode	= GRhd,
					count	= 1,
					grids	= &me->xSection,
					theEnv	= &me->cstEnv ) ;
	}

	wrapup :
		me->ret = sts & 1 & *msg ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;
		return OM_S_SUCCESS ;

} /* method displaySection */
/*----------------------------------------------------------------------------*/

end implementation VSxtbeamCmd ;
