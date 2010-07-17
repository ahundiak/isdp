/*
	I/STRUCT
	"Split Beam with Plate" command.
*/
command_string	VSC_M_VSSpBmPl,0,VSSpBmPl
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSspbeamCmd
product_name	"$STRUCT"
status_display	"VSautoJoint.fm","-1","-1"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "lcdef.h"
#include "vsbeamdef.h"
#include "VSmsg.h"
#include "vsdef.h"
#include "vsjointdef.h"
#include "vscmddef.h"

state start
	execute		setMinMaxOperators( 1, 1 )
	execute		setJoiningAction( VS_K_JOIN_RESULTS_WITH_DIVISOR )
	on ELSE state main

state main
	prompt_key		VS_P_IdBmOrGr
	accept_key		VS_P_AccWHiPrPl
	construct_class		"VSsplBeam"
	/*
	 * Only accept `source' beams. And set rejection status to be displayed
	 * by locate action handler in case user locates a beam which is not
	 * `source'.
	 */
	execute 	setupActionHandler(
					&me->ret,
					VS_K_filterFeature_LCAH,
					VS_m_SRC_generic )
	execute		setupAHrejectSts( VS_W_BeamNotEligible )
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
	filter			locate_noauto
		on EX_DATA
			do store_operand( &me->ret, 1 )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			state getPlate
		on EX_OBJID
			do process_fence( &me->ret, VS_K_OPRND )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			state getPlate

state getPlate
	execute		setupActionHandler( &me->ret, VS_K_RESET_LCAH, 0 )
	prompt_key		VS_P_IdHiPrPl
	accept_key		VS_P_AccRej
	locate_class		"+VSplate"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	locate_owner		"  LC_RIGID_COMP
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

		on EX_DATA or EX_OBJID
			do store_operator( &me->ret, 0 )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			do operation( &me->ret )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			do discard_all_input( &me->ret )
			state main

at init		do message_key VS_M_VSSpBmPl
		do dspAutoJoinMode()
at wakeup	do status_display_button( 1 )
at sleep	do status_display_button( 0 )
/*----------------------------------------------------------------------------*/
