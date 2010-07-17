/*
	I/STRUCT
	"Split Plate" command.
*/
command_string	VSC_M_VSSpPl,0,VSSpPl
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSspplatCmd
product_name	"$STRUCT"
status_display	"VSautoJoint.fm","-1","-1"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "lcdef.h"
#include "vsplatedef.h"
#include "VSmsg.h"
#include "vsdef.h"
#include "vsjointdef.h"
#include "vscmddef.h"

state start
	execute 		setMinMaxOperators( 1, 1 )
	execute 		setJoiningAction( VS_K_JOIN_RESULTS_TOGETHER )
	on ELSE state main

state main
	prompt_key		VS_P_IdPlOrGr
	accept_key		VS_P_AccWSpCv
	construct_class 	"VSsplPlate"
	/*
	 * Reject `frozen' and image plates.
	 */
	execute 	setupActionHandler(
					&me->ret,
					VS_K_filterFeatureNeg_LCAH,
					  VS_m_FRZ_generic
					| VS_m_IMG_generic )
	locate_class		"+VSplate"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	/*
	 * Plates in reference files accepted.
	 * Plates rigidly owned not accepted (LC_RIGID_COMP).
	 */
	locate_owner		"  LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER
				 | LC_REF_OBJECTS"
	/*
	 * Accept locate by name or object.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID"
	filter			locate_noauto
		on EX_DATA
			do store_operand( &me->ret, 1 )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			state getCurve
		on EX_OBJID
			do process_fence( &me->ret, VS_K_OPRND )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			state getCurve

state getCurve
	prompt_key		VS_P_IdSpCv
	accept_key		VS_P_AccRej
	/*
	 * Accept curves but not points and planes.
	 */
	execute 		setupActionHandler(
					&me->ret,
					VS_K_rejectSubClass_LCAH,
					"GRpoint" )
	locate_class		"+GRcurve,EMSplane"
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
				 GRm_BACK_UP"
	filter			locate_noauto
		on EX_BACK_UP
			do discard_operators( &me->ret )
			state -

		on EX_DATA
			do store_operator( &me->ret, 0 )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			do operation( &me->ret )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			do discard_all_input( &me->ret )
			state main

		on EX_OBJID
			do process_fence( &me->ret, VS_K_OPRTR )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			do operation( &me->ret )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			do discard_all_input( &me->ret )
			state main

at init		do message_key VS_M_VSSpPl
		do dspAutoJoinMode()
at wakeup	do status_display_button( 1 )
at sleep	do status_display_button( 0 )
/*----------------------------------------------------------------------------*/
