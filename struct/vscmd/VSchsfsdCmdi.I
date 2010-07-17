/*
	I/STRUCT
*/
class implementation VSchsfsdCmd ;

#include <stdio.h>
#include <stdlib.h>
#include "exmacros.h"
#include "COBmacros.h"
#include "godef.h"
#include "dp.h"
#include "dpmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "EMSmsgdef.h"
#include "vsoptdef.h"
#include "vssectiondef.h"
#include "vsdpb.h"
#include "vspart.h"
#include "vsdpb.h"
#include "vsbeam.h"
#include "vsbeamdef.h"
#include "vsdef.h"
#include "vs.h"
#include "vsattr.h"
#include "vsdef.h"
#include "vsstfnrdef.h"
#include "vsplatedef.h"
#include "vsbmaxisdef.h"
#include "vscmddef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsgetaxofstf.h"
#include "vsioproto.h"
#include "vsophstproto.h"

from VSbeam	import VSgetXdirectionForCrossSectionCS ;
from VSstfBeam	import VSgetPlateSide,
		       VSputPlateSide ;
from VSbeamAxis import VSputPlateSide ;
from VSfeature	import VSgetOperationHistory ;
from ACcpx	import ACfind_temp_obj ;
from NDmacro	import ACreturn_foot ;
from GRvg	import GRgetattr,
		       GRputattr ;

from ACpretend  import ACfind_parent ;

extern OMuword	OPP_VStwsBeam_class_id;
/*----------------------------------------------------------------------------*/
method store_stiffener( int * sts ) {

	long		sts,
			msg ;
	VSopHistory	*history = NULL ;

	struct GRlc_info	*toStore = me->event1.located_object ;

	sts = om$send( msg	= message VSfeature.VSgetOperationHistory(
						&msg, &toStore->module_info,
						&history ),
			targetid= toStore->located_obj.objid,
			targetos= toStore->located_obj.osnum ) ;
	__CheckRC( sts, msg, "VSfeature.VSgetOperationHistory", wrapup ) ;

	toStore->located_obj.objid	= history->resultId ;
	toStore->located_obj.osnum	= history->resultOs ;
	toStore->module_info		= history->resultEnv;

	sts = om$send( msg	= message VSlocateCmd.addLocObj(
							&toStore->located_obj,
							&toStore->module_info,
							0 ),
		       targetid = my_id ) ;

	me->number_of_stiffeners = 1 ;

	wrapup :
		VSfreeOpHistory( history ) ;
		me->ret = sts & 1 ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;

		return OM_S_SUCCESS ;

} /* method store_stiffener */
/*----------------------------------------------------------------------------*/
method process_fence( int * sts ) {

	long			sts,
				msg ;
	int			nbStiff ;
	struct GRobj_env	fence,
				*Stiff ;
	VSopHistory		*history = NULL ;

	me->number_of_stiffeners = 0 ;

	fence._grid	= me->event1.located_object[0].located_obj ;
	fence.mod_env	= me->event1.located_object[0].module_info ;

	vs$process_fence(	msg		= &msg,
				fence		= &fence,
				classList	= me->locate_eligible,
				filter		= me->PFAH,
				args		= &me->PFAHarg,
				p_count 	= &nbStiff,
				p_content	= &Stiff,
				response	= me->response,
				response_data	= me->response_data ) ;

	if( *me->response != EX_DATA || !nbStiff ) {
		me->ret = VS_K_NO_FENCE ;
		goto wrapup ;
	}

	if( msg & 1 ) {
		int		h ;

		sts = MSSUCC ;

		for( h = 0 ; h < nbStiff && (sts & 1) ; h++ ) {

			sts = om$send(
				msg	= message VSfeature.VSgetOperationHistory(
							&msg, &Stiff[h].mod_env,
							&history ),
				targetid= Stiff[h]._objid,
				targetos= Stiff[h]._osnum ) ;
			Stiff[h]._objid = history->resultId ;
			Stiff[h]._osnum = history->resultOs ;
			Stiff[h].mod_env= history->resultEnv;

			VSfreeOpHistory( history ) ;

			sts = om$send(
				msg	= message VSlocateCmd.addLocObj(
						     &Stiff[h]._grid,
						     &Stiff[h].mod_env,
						     me->number_of_stiffeners ),
				targetid= my_id ) ;
			me->number_of_stiffeners++ ;
		}
		_FREE( Stiff ) ;

		if( !me->number_of_stiffeners ) {
			me->ret = VS_K_NO_FENCE ;
			goto wrapup ;
		}
	} else {
		sts = MSFAIL ;
	}

	me->ret = sts & 1 & msg ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;

	wrapup :
		return OM_S_SUCCESS ;

} /* method process_fence */
/*----------------------------------------------------------------------------*/
method hilight_new_side( long *msg ) {

	long			sts ;
	int			ACrc ;			/* AC completion code */
	int			i ;
	int			whichSide ;
	struct GRobj_env	*stiffeners = NULL,
				side,
				plate ;
	char			*sidename ;

	/*
	 * For all stiffeners located, highlight the opposite side and show the
	 * normal which indicates the new position of the stiffener.
	 */
	stiffeners = _MALLOC( me->number_of_stiffeners, struct GRobj_env ) ;
	if( !stiffeners ) {
		sts = OM_W_ABORT ;
		*msg = EMS_E_NoDynamicMemory ;
		goto wrapup ;
	}

	sts = om$send( msg	= message VSlocateCmd.getLocObjs(
						       msg,
						       me->number_of_stiffeners,
						       stiffeners ),
		       targetid = my_id ) ;

	__CheckRC( sts, *msg, "VSlocateCmd.getLocObjs", wrapup ) ;

	for( i = 0 ; i < me->number_of_stiffeners ; i++ ) {
		/*
		 * Retrieve plate of stiffener.
		 */
		if( vs$is_ancestry_valid(object= &stiffeners[i]._grid,
					classid = OPP_VStwsBeam_class_id ) ) {
			struct GRobj_env	axis ;
			sts = om$send( msg = message ACcpx.ACfind_temp_obj(
							&ACrc,
							VS_K_bmSuppAxis,
							&axis._grid ),
				targetid = stiffeners[i]._objid,
				targetos = stiffeners[i]._osnum );
			*msg = ACrc ? MSSUCC : MSFAIL ;
			__CheckRC( sts, *msg, "ACcpx.ACfind_temp_obj", wrapup );

        		sts = om$send( msg = message ACpretend.ACfind_parent( 
								&axis._grid,
                                                                NULL, NULL ),
                       			targetid = axis._objid ,
                        		targetos = axis._osnum );

			__DBGpr_obj(" Axis Object", axis._grid );

			sts = om$send( msg	= message ACcpx.ACfind_temp_obj(
							       &ACrc,
							       VS_K_baPlateSupp,
							       &plate._grid ),
				       targetid = axis._objid,
				       targetos = axis._osnum ) ;

			*msg = ACrc ? MSSUCC : MSFAIL ;
			__CheckRC( sts, *msg, "ACcpx.ACfind_temp_obj", wrapup );
		} else {

		sts = om$send( msg	= message ACcpx.ACfind_temp_obj(
							       &ACrc,
							       VS_K_stSuppPlate,
							       &plate._grid ),
			       targetid = stiffeners[i]._objid,
			       targetos = stiffeners[i]._osnum ) ;

		*msg = ACrc ? MSSUCC : MSFAIL ;
		__CheckRC( sts, *msg, "ACcpx.ACfind_temp_obj", wrapup ) ;
		}

		sts = om$send(	msg	= message NDmacro.ACreturn_foot(
							msg,
							"",
							&plate._grid,
							&plate._matrix_type,
							plate._matrix ),
				targetid= plate._objid,
				targetos= plate._osnum ) ;

		/*
		 * Retrieve actual stiffener side.
		 */
		sts = om$send( msg	= message VSstfBeam.VSgetPlateSide(
								   msg,
								   &whichSide ),
			       targetid = stiffeners[i]._objid,
			       targetos = stiffeners[i]._osnum ) ;
		__CheckRC( sts, *msg, "VSstfBeam.VSgetPlateSide", wrapup ) ;

		/*
		 * Retrieve opposite side.
		 */
		switch( whichSide ) {
			default : /* Should not get here */
			case VS_K_stOnTopOfPlate	:
				sidename = VS_K_plBotSfPathABS ;
				break ;
			case VS_K_stOnBotOfPlate	:
				sidename = VS_K_plTopSfPathABS ;
				break ;
		}

		sts = om$send( msg	= message NDmacro.ACreturn_foot(
							     msg,
							     sidename,
							     &side.obj_id,
							     NULL,
							     NULL ),
			       targetid = plate._objid,
			       targetos = plate._osnum ) ;
		__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

		side.mod_env	= plate.mod_env ;
		side._md_os	= side._osnum ;

		ex$get_modid(	mod_osnum	= side._md_os,
				mod_id		= &side._md_id ) ;

		/*
		 * Highlight opposite side.
		 */
		vs$bulk_display( count	= 1,
				 dpmode = GRhdo,
				 objenvs= &side ) ;

		/*
		 * Show new position of stiffener.
		 */
		VSdisplaySurfaceNormal( msg,
					&side,
					TRUE,
					&me->ActiveDisplay,
					GRhd ) ;
	}

	wrapup :
		_FREE( stiffeners ) ;
		me->ret = sts & *msg & 1 ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;
		return OM_S_SUCCESS ;

} /* method hilight_new_side */
/*----------------------------------------------------------------------------*/
method change_position( long *msg ) {

	long			sts ;
	int			i ;
	int			whichSide ;
	int			newSide ;
	int			type = ND_COMP ;
	struct	GRobj_env	*stiffeners = NULL ;
	struct	GRid		beamAxis ;
	VSpartAttr		attr ;
	VSbeamAttr		info ;
	int			hasDir ;
	IGRvector		xDir ;

	/*
	 * Unhilight all side and normal.
	 */
	dp$erase_hilite( msg = msg ) ;

	/*
	 * Get located stiffener(s).
	 */
	stiffeners = _MALLOC(  me->number_of_stiffeners, struct GRobj_env ) ;
	if( !stiffeners ) {
		sts  = OM_W_ABORT ;
		*msg = EMS_E_NoDynamicMemory ;
		goto wrapup ;
	}

	sts = om$send( msg	= message VSlocateCmd.getLocObjs(
						       msg,
						       me->number_of_stiffeners,
						       stiffeners ),
		       targetid = my_id ) ;
	__CheckRC( sts, *msg, "VSlocateCmd.getLocObjs", wrapup ) ;

	for( i = 0 ; i < me->number_of_stiffeners ; i++ ) {

		int	doSym ;

		/*
		 * Retrieve actual stiffener side.
		 */
		sts = om$send( msg	= message VSstfBeam.VSgetPlateSide(
							msg, &whichSide ),
			       targetid = stiffeners[i]._objid,
			       targetos = stiffeners[i]._osnum ) ;
		__CheckRC( sts, *msg, "VSstfBeam.VSgetPlateSide", wrapup ) ;

		/*
		 * Put the opposite side to stiffener.
		 */
		switch( whichSide ) {
			default				:
			case VS_K_stOnTopOfPlate	:
				newSide = VS_K_stOnBotOfPlate ;
				break ;
			case VS_K_stOnBotOfPlate	:
				newSide = VS_K_stOnTopOfPlate ;
				break ;
		}

		sts = om$send( msg	= message VSstfBeam.VSputPlateSide(
								msg, newSide ),
			       targetid = stiffeners[i]._objid,
			       targetos = stiffeners[i]._osnum ) ;
		__CheckRC( sts, *msg, "VSstfBeam.VSputPlateSide", wrapup ) ;

		sts = om$send(	msg	= message VSbeam.VSgetXdirectionForCrossSectionCS(
							msg, &hasDir, xDir ),
				targetid = stiffeners[i]._objid,
				targetos = stiffeners[i]._osnum ) ;
		__CheckRC( sts, *msg, "VSBeam.VSgetXdirect...", wrapup ) ;

		/*
		 * If command "Change Stiffener Side And Mirror", retrieve
		 * symmetry and put the opposite ( No Symm -> Y Symm and
		 * Y Symm -> No Symm ).
		 */
		if( me->mytype == 0 )	doSym = hasDir ;
		else			doSym = !hasDir ; 

		if( doSym ) {

			attr.Iwant	= VS_m_Symmetry ;
			attr.specific	= (void *) &info ;
			sts = om$send(	msg	= message GRvg.GRgetattr(
							msg, (char *) &attr ),
					targetid= stiffeners[i]._objid,
					targetos= stiffeners[i]._osnum ) ;
			__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

			if( info.sym == VS_e_No_Symm )
				info.sym = VS_e_Y_Symm	;
			else
			if( info.sym == VS_e_Y_Symm  )
				info.sym = VS_e_No_Symm ;

			sts = om$send(	msg	= message GRvg.GRputattr(
							msg, (char *) &attr ),
					targetid= stiffeners[i]._objid,
					targetos= stiffeners[i]._osnum ) ;
			__CheckRC( sts, *msg, "GRvg.GRputattr", wrapup ) ;
		}

		/*
		 * Retrieve the beam axis of stiffener.
		 */
		sts = VSgetBeamAxisOfStiffener( msg,
						&stiffeners[i]._grid,
						&beamAxis ) ;
		__CheckRC( sts, *msg, "VSgetBeamAxisOfStiffener", wrapup ) ;

		/*
		 * Put the opposite side to axis.
		 */
		switch( whichSide ) {
			case VS_K_stOnTopOfPlate	:
				newSide = VS_K_baOnBotOfPlate ;
				break ;
			case VS_K_stOnBotOfPlate	:
				newSide = VS_K_baOnTopOfPlate ;
				break ;
		}

		sts = om$send( msg	= message VSbeamAxis.VSputPlateSide(
								      msg,
								      newSide ),
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
	}

	wrapup :

		_FREE( stiffeners ) ;
		me->ret = sts & *msg & 1 ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;
		return OM_S_SUCCESS ;

} /* method change_position */
/*----------------------------------------------------------------------------*/
method unhilight_new_side( int *sts ) {

	dp$erase_hilite( msg = sts ) ;
	return OM_S_SUCCESS ;

} /* method unhilight_new_side */
/*----------------------------------------------------------------------------*/

end implementation VSchsfsdCmd ;
