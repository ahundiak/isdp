/*
	I/STRUCT
	"Extend and Trim Beam" command.
*/
command_string	VSC_M_VSExTrBm,0,VSExTrBm
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSxtbeamCmd
product_name	"$STRUCT"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "lcdef.h"
#include "vsplatedef.h"
#include "VSmsg.h"
#include "vsdef.h"
#include "vscmddef.h"

state start
	execute			setMinMaxOperators( 1, 1 )
	on ELSE state main

state main
	prompt_key		VS_P_IdBmOrGr
	accept_key		VS_P_AccRej
	/*
	 * Reject `frozen' and image beams.
	 */
	execute 		setupActionHandler(
					&me->ret,
					VS_K_filterFeatureNeg_LCAH,
					  VS_m_FRZ_generic
					| VS_m_IMG_generic )
	locate_class		"+VSbeam"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	/*
	 * Beams in reference files accepted.
	 * Beams rigidly owned not accepted (LC_RIGID_COMP).
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
			do store_operand( &me->ret, 0 )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			/*
			 * The following action is used to test whether beam
			 * has not already been extended at both ends.
			 */
			do findCloserEnd( &me->ret )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do discard_all_input( &me->ret )
					state main
			state getSurface
		on EX_OBJID
			do process_fence( &me->ret, VS_K_OPRND )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			/*
			 * The following action is used to test whether beam
			 * has not already been extended at both ends. The test
			 * will be done on the 1st beam.
			 */
			do findCloserEnd( &me->ret )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do discard_all_input( &me->ret )
					state main
			state getSurface

state getSurface
	execute		setupActionHandler( &me->ret, VS_K_RESET_LCAH, 0 )
	prompt_key		VS_P_IdSf
	accept_key		VS_P_AccRej
	construct_class		"VSxtrBeam"
	locate_class		"+EMSsubbs"
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
			/*
			 * The following action is used to get the beam end
			 * which is the closer to the located surface.
			 */
			do findCloserEnd( &me->ret )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do discard_all_input( &me->ret )
					state main
			state chooseEnd

state chooseEnd
	execute		displaySection( &me->ret, 1 )
	mask		"GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON"
	prompt_key	VS_P_AccEndRjt
	filter		get_event
		on EX_DATA
			do displaySection( &me->ret, 0 )
			do operation( &me->ret )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			do discard_all_input( &me->ret )
			state main
		on EX_BACK_UP
			do displaySection( &me->ret, 0 )
			do rmLastLocObjs( 1 )
			do decrease_operator()
			state -
		on EX_RJT_MOVEON
			do changeEnd( &me->ret )
			state .

at init		do message_key VS_M_VSExTrBm
		do initCmd()
		do setFlags( VS_m_POallOprtsOn1Opnd )
at delete	do cleanup()
/*----------------------------------------------------------------------------*/
