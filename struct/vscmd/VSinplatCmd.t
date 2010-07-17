/*
	I/STRUCT
	"Intersect Plate with Plate" command.
*/
command_string	VSC_M_VSInPlPl,0,VSInPlPl
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
	/*
	 * Set maximum number of plates which may intersect input plate, here 1.
	 */
	execute		setMinMaxOperators( 1, 1 )
	execute		setJoiningAction( VS_K_JOIN_RESULTS_WITH_DIVISOR )
	on ELSE state main

state main
	prompt_key		VS_P_IdLowPrPl
	accept_key		VS_P_AccWHiPrPl
	construct_class		"VSgapPlate"
	/*
	 * Accept locate by name or object.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID"
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

	filter			locate_noauto
		on EX_DATA
			/*
			 * Store plate, put accept point onto event queue (hence
			 * the argument "1").
			 */
			do store_operand( &me->ret, 1 )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret )	state .
			state getOtherPlate
		on EX_OBJID
			do process_fence( &me->ret, VS_K_OPRND )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			state getOtherPlate

state getOtherPlate
	prompt_key		VS_P_IdHiPrPl
	accept_key		VS_P_AccRej
	execute 		setupActionHandler(
					&me->ret,
					VS_K_filterFeature_LCAH,
				  	VS_m_PLATE )
	locate_class		"+VSfeature"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	locate_owner		"  LC_RIGID_COMP
				 | LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER
				 | LC_REF_OBJECTS"
	/*
	 * Accept locate by name or object.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID | GRm_BACK_UP"
	filter			locate_noauto
		on EX_BACK_UP
			do discard_operators( &me->ret )
			state -

		on EX_DATA or EX_OBJID
			/*
			 * Store plate, do not put accept point onto event
			 * queue (hence the argument "0").
			 */
			do store_operator( &me->ret, 0 )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			do operation( &me->ret )
				/*
				 * User may have located the same plate twice,
				 * In this case no operator has been stored.
				 */
				on RETURN_CODE  = "VS_K_NEED_OP"  state .

				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			do discard_all_input( &me->ret )
			state main

at init	do	message_key VS_M_VSInPlPl
	do	dspAutoJoinMode()
at wakeup	do status_display_button( 1 )
at sleep	do status_display_button( 0 )
/*----------------------------------------------------------------------------*/

