/*
	I/STRUCT
	"Intersect Beam with Surface" command.
*/
command_string	VSC_M_VSInBmSr,0,VSInBmSr
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSpartopCmd
product_name	"$STRUCT"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "msdef.h"
#include "lcdef.h"
#include "VSmsg.h"
#include "vsdef.h"
#include "vscmddef.h"

state start
	/*
	 * Set min. and max. numbers of operators that command may accept:
	 * a surface or a surface and an expression.
	 */
	execute		setMinMaxOperators( 1, 2 )
	/*
	 * Command shall construct object using the active symbology and
	 * the active display representation.
	 */
	execute		setFlags( VS_m_POconstWithSymb | VS_m_POconstWithRep )
	construct_class		"VSintCrsSctn"
	/*
	 * Located object #0 : a beam.
	 */
	prompt_key		VS_P_IdBeam
	accept_key		VS_P_AccWSf
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
	filter			locate
		on EX_DATA or EX_OBJID
			/*
			 * Store beam, put accept point onto event queue.
			 */
			do store_operand( &me->ret, 1 )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			state locSurface

state locSurface
	execute		setupActionHandler( &me->ret, VS_K_RESET_LCAH, 0 )
	/*
	 * Located object #1 : a surface.
	 */
	prompt_key		VS_P_IdSf
	accept_key		VS_P_AccRej
	locate_class		"+EMSsubbs"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	locate_owner		"  LC_RIGID_COMP
				 | LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER
				 | LC_REF_OBJECTS"
	/*
	 * Accept locate by name.
	 */
	mask			"GRm_DATA | GRm_STRING
				 | GRm_OBJID | GRm_BACK_UP"
	filter			locate
		on EX_DATA or EX_OBJID
			do store_operator( &me->ret, 0 )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
				state getOffset

		on EX_BACK_UP
			do discard_operators( &me->ret )	  state -

state getOffset
	/*
	 * Located object #2 : an expression (optional).
	 */
	prompt_key		VS_P_KyInOffset
	locate_mask		"GRm_DATA | GRm_RESET | GRm_STRING | GRm_OBJID |
				 GRm_BACK_UP"
	accept_mask		"GRm_DATA | GRm_RESET | GRm_OBJID"
	filter			VSget_exp
		on ERROR 					    state .

		on EX_BACK_UP
		 	do rmLastLocObjs( 1 )
			do decrease_operator()			    state -

		on EX_RJT_MOVEON
			/*
			 * No offset expression input.
			 */
			do operation( &me->ret )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state start
			do discard_all_input( &me->ret )	  state start

		on EX_OBJID or EX_DATA or EX_STRING
			do store_operator( &me->ret, 0 )
			do operation( &me->ret )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state start
			do discard_all_input( &me->ret )	  state start

at init do message_key VS_M_VSInBmSr
/*----------------------------------------------------------------------------*/
