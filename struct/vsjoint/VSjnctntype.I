/*
	I/STRUCT
*/ 
class implementation VSjoint ;

#include "EMSmsgdef.h"
#include "vsstfnrdef.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"

from VSstfBeam	import VSgetPlateSide ;
/*----------------------------------------------------------------------------*/
long VSgetJunctionType( msg, elToJoin1, elToJoin2, jType )

long			*msg ;
struct GRobj_env	*elToJoin1,
			*elToJoin2 ;
int			*jType ; {

	/*
	 * This function is interfaced by macro `vs$getJunctionType' defined
	 * in vsjntmacros.h
	 */
	long			sts ;		/* OM return code	*/
	unsigned long		elType1,	/* Type of element 1	*/
				elType2 ;	/* Type of element 2	*/
	struct GRobj_env	*plate,
				*beam ;
	int			stfSide,
				jT = -1,	/* Local junction type	*/
				ACrc ;		/* AC return code	*/
	unsigned long		mask,
				bmType ;	/* Beam or stiffener ?	*/
	struct GRid		supportPlate ;	/* Of stiffener		*/

       	sts = om$send(	msg	= message VSfeature.VSgetResultType(
		       						msg, &elType1 ),
		       	senderid= elToJoin1->_objid,
        		targetid= elToJoin1->_objid,
        		targetos= elToJoin1->_osnum ) ;
	__CheckRC( sts, *msg, "VSfeature.VSgetResultType", wrapup ) ;

       	sts = om$send(	msg	= message VSfeature.VSgetResultType(
	        						msg, &elType2 ),
		       	senderid= elToJoin2->_objid,
        		targetid= elToJoin2->_objid,
        		targetos= elToJoin2->_osnum ) ;
	__CheckRC( sts, *msg, "VSfeature.VSgetResultType", wrapup ) ;

	if( elType1 & VS_m_BEAM ) {
		     if( elType2 & VS_m_BEAM  )		jT = VS_K_J_BM_BM ;
		else if( elType2 & VS_m_PLATE )		jT = VS_K_J_BM_PL ;
		else 					vs$inv_arg() ;
	} else if( elType1 & VS_m_PLATE ) {
		     if( elType2 & VS_m_BEAM  )		jT = VS_K_J_PL_BM ;
		else if( elType2 & VS_m_PLATE )		jT = VS_K_J_PL_PL ;
		else					vs$inv_arg() ;
	} else {
		vs$inv_arg() ;
	}

	__DBGpr_int( "Junction type", jT ) ;

	switch( jT ) {
		case VS_K_J_BM_PL : beam  = elToJoin1 ;
				    plate = elToJoin2 ; break ;

		case VS_K_J_PL_BM : beam  = elToJoin2 ;
				    plate = elToJoin1 ; break ;

		default		  : sts	 = OM_S_SUCCESS ;
				    *msg = MSSUCC ;
				    goto wrapup ;
	}

	sts = om$send(	msg	= message VSpart.VSgetUserEditableAttr(
							msg, &bmType, &mask ),
			senderid= beam->_objid,
			targetid= beam->_objid,
			targetos= beam->_osnum ) ;

	if( bmType != VS_m_STF_BEAM ) {
		sts = OM_S_SUCCESS ; *msg = MSSUCC ; goto wrapup ;
	}

	__DBGpr_com( "Beam is a stiffener" ) ;

	/*
	 * We have a plate-stiffener or a stiffener-plate junction, check if
	 * the plate is a parent of the stiffener, if so we can discover on
	 * which side of the plate the stiffener lies, thus reducing the search
	 * of the matching surfaces to put the joint between.
	 */

	sts = om$send(	msg	= message VSfeature.VSforwardToSource(
					msg, OM_e_wrt_object,
					message ACcpx.ACfind_temp_obj(
							&ACrc,
							VS_K_stSuppPlate,
							&supportPlate ) ),
			senderid= beam->_objid,
			targetid= beam->_objid,
			targetos= beam->_osnum ) ;

	if( !IF_EQ_GRID( supportPlate, plate->_grid ) ) {
		__DBGpr_com( "Input plate not support of stiffener" ) ;
		sts = OM_S_SUCCESS ; *msg = MSSUCC ; goto wrapup ;
	}

	__DBGpr_com( "... and plate its support" ) ;
	/*
	 * Input plate is the one stiffened by stiffener.
	 */		
	sts = om$send(	msg	= message VSfeature.VSforwardToSource(
					msg, OM_e_wrt_object,
					message VSstfBeam.VSgetPlateSide(
							msg, &stfSide ) ),
			senderid= beam->_objid,
			targetid= beam->_objid,
			targetos= beam->_osnum ) ;
	__DBGpr_int( "Stiffener side", stfSide ) ;

	switch( stfSide ) {
		case VS_K_stOnTopOfPlate :
			switch( jT ) {
				case VS_K_J_BM_PL : jT = VS_K_J_ST_TP ; break ;
				case VS_K_J_PL_BM : jT = VS_K_J_TP_ST ; break ;
			}
			break ;
		
		case VS_K_stOnBotOfPlate :
			switch( jT ) {
				case VS_K_J_BM_PL : jT = VS_K_J_ST_BT ; break ;
				case VS_K_J_PL_BM : jT = VS_K_J_BT_ST ; break ;
			}
			break ;
	}

	__DBGpr_int( "Junction type (bettered)", jT ) ;

	wrapup :
		*jType = jT ;

		return sts ;

} /* VSgetJunctionType */
/*----------------------------------------------------------------------------*/

end implementation VSjoint ;
