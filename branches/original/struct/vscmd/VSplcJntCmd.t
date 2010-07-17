/*
	I/STRUCT
	"Place Joint" command.
*/
command_string	VSC_M_VSPlJn,0,VSPlJn
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSplcJntCmd 
product_name	"$STRUCT"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "lcdef.h"
#include "vsplatedef.h"
#include "VSmsg.h"
#include "vsdef.h"
#include "vscmddef.h"

/*
 * NOTE: in this command, the 1st and 2nd elements have a symmetrical role, but
 * we store the 1st as the operand and the second as the operator for commodity.
 */

state start
	execute			setMatchKey( "joint" )
	execute			setMinMaxOperators( 1, 1 )
	/*
	 * Reject joints in all locates (they are VSfeatures too).
	 */
	execute 		setupActionHandler(
					&me->ret,
					VS_K_filterFeatureNeg_LCAH,
					VS_m_JOINT )
	on ELSE state get1stElmt

state get1stElmt
	prompt_key		VS_P_Id1stElmt
	accept_key		VS_P_AccW2ndElmnt
	locate_class		"+VSfeature"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	/*
	 * Elements in reference files accepted.
	 */
	locate_owner		"  LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER
				 | LC_RIGID_COMP
				 | LC_REF_OBJECTS"

	/*
	 * Accept locate by name or object.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID"
	filter			locate_noauto

		on EX_DATA or EX_OBJID
			/*
			 * Store element, put accept point onto event queue
			 * (hence the argument "1").
			 */
			do store_operand( &me->ret, 1 )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) 
							 state .
			do ms_on_off  MS_OFF
			do prompt_key VS_P_Id2ndElmt	 state get2ndElmt

state get2ndElmt
	ms_on_off		MS_ON
	accept_key		VS_P_AccWNxClCv
	accept_key		VS_P_AccRej
	/*
	 * Elements in reference files accepted.
	 */
	locate_owner		"  LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER
				 | LC_RIGID_COMP
				 | LC_REF_OBJECTS"

	/*
	 * Accept locate by name or object.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID"
	filter			locate_noauto
		on EX_DATA or EX_OBJID
			/*
			 * Store element, don't put accept point onto event
			 * queue (hence the argument "0").
			 */
			do store_operator( &me->ret, 0 )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .

			do operation( &me->ret )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state get1stElmt
			/*
			 * Flush input, restart.
			 */
			do discard_all_input( &me->ret )	  state get1stElmt

		on EX_BACK_UP
			do discard_operators( &me->ret )	  state -

at init		do message_key VS_M_VSPlJn
at wakeup	do checkPWD()
/*----------------------------------------------------------------------------*/
