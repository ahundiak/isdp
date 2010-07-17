/*
	I/STRUCT
	"Place Beam Coordinate System" command.
*/
command_string	VSC_M_VSPlBmCrSy,0,VSPlBmCrSy
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSbeamcsCmd
product_name	"$STRUCT"

/*--STATE TABLE---------------------------------------------------------------*/
state_table

#include "lcdef.h"
#include "vsplatedef.h"
#include "VSmsg.h"
#include "vscmddef.h"
#include "vsdef.h"

state start
	execute	setMinMaxOperators( 0, 0 )
	execute	setFlags( VS_m_POconstWithSymb | VS_m_POnoOperandRedisp )
	on ELSE state main

state main
	message_key		VS_M_VSPlBmCrSy	
	prompt_key		VS_P_IdBeam
	accept_key		VS_P_AccNearEnd
	/*
	 * Reject `frozen' beams.
	 */
	execute 		setupActionHandler(
					&me->ret,
				    	VS_K_noFrozenFeature_LCAH,
				    	VS_m_BEAM )
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
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID"
	filter			locate_noauto
		on EX_DATA or EX_OBJID
			do store_operand( &me->ret, 0 )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .

			do findCloserEnd( &me->ret )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do discard_all_input( &me->ret )
					do status_key VS_E_ErrEncCmdRst
					state main
			state getCardPoint

state getCardPoint
	construct_class	"VSbeamCS"
	execute		displayCS( &me->ret, 1 )
	mask		"GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON"
	prompt_key	VS_P_AccPos
	filter		get_event
		on EX_DATA
			do displayCS( &me->ret, 0 )
			do operation( &me->ret )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			do discard_all_input( &me->ret )
			do initCmd()
			state main
		on EX_BACK_UP
			do displayCS( &me->ret, 0 )
			do discard_all_input( &me->ret )
			do initCmd()
			state -
		on EX_RJT_MOVEON
			do changeCardPoint()
			state .

at init		do initCmd()
at delete	do cleanup()	
/*----------------------------------------------------------------------------*/
