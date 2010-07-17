/*
	I/STRUCT
	"Impose Cutouts On Set of Beams" command.
*/
command_string	VSC_M_VSImCtOnSB,0,VSImCtOnSB
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSntbmstCmd
product_name	"$STRUCT"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "lcdef.h"
#include "vsbeamdef.h"
#include "VSmsg.h"
#include "vsdef.h"
#include "vscmddef.h"

state start
	execute			setMinMaxOperators( 1, VS_K_bbMAX_NOTCHES )
	on ELSE state main

state main
	message_key		VS_M_VSImCtOnSB
	prompt_key		VS_P_IdBmSet
	accept_key		VS_P_AccWNtch
	construct_class		"VSbooBeam"
	/*
	 * Reject `frozen' or image beams.
	 */
	execute 	setupActionHandler(
					&me->ret,
					VS_K_filterFeatureNeg_LCAH,
					  VS_m_FRZ_generic
					| VS_m_IMG_generic )
	locate_class		"+VSbeam"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	locate_owner		"  LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER
				 | LC_REF_OBJECTS"

	/*
	 * Accept locate by name or object.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID"
	filter			locate
		on EX_DATA
			do store_operand( &me->ret, 1 )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) 
								state .
			do ms_on_off  MS_OFF
			do prompt_key VS_P_IdNtch		state getSolids
		on EX_OBJID
			do process_fence( &me->ret, VS_K_OPRND )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) 
								state .
			do ms_on_off  MS_OFF
			do prompt_key VS_P_IdNtch		state getSolids

state getSolids
	execute		setupActionHandler( &me->ret, VS_K_RESET_LCAH, 0 )
	ms_on_off		MS_ON
	accept_key		VS_P_AccWNxNtch
	locate_class		"+EMSsolid,EMSsubbs,GRcurve"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	/*
	 * Rigid component will be not located by a fence without the
	 * flag LC_RIGID_COMP_PRISM.
	 */
	locate_owner		"  LC_RIGID_COMP
				 | LC_RIGID_COMP_PRISM
				 | LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER
				 | LC_REF_OBJECTS"
	/*
	 * Accept locate by name or object.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID |
				 GRm_RJT_MOVEON | GRm_BACK_UP"
	filter			locate
		on EX_DATA
			do store_operator( &me->ret, 1 )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) 
								state .
			do ms_on_off MS_OFF
			do prompt_key VS_P_IdNtchMvOn		state .

		on EX_OBJID
			do process_fence( &me->ret, VS_K_OPRTR )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) 
								state .
			do ms_on_off MS_OFF
			do prompt_key VS_P_IdNtchMvOn		state .

		on EX_RJT_MOVEON
			do operation( &me->ret )
				on RETURN_CODE  = "VS_K_NEED_OP"  
								state .
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) 
								state .
			do discard_all_input( &me->ret )	state main

		on EX_BACK_UP
			do discard_operators( &me->ret )	state -

/*----------------------------------------------------------------------------*/
