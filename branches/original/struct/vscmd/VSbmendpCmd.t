/*
	I/STRUCT
	"Place Associative Points at Beam Ends" command.
*/
command_string	VSC_M_VSPAsPnBmE,0,VSPAsPnBmE
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
	 * Command shall construct object using the active symbology and
	 * shall not erase/display operand.
	 */
	execute		setFlags( VS_m_POconstWithSymb | VS_m_POnoOperandRedisp)
	prompt_key	VS_P_IdBeam
	accept_key	VS_P_AccWNxBm
	construct_class	"VSbmEndPnts"
	/*
	 * Reject `frozen' beams.
	 */
	execute 	setupActionHandler(
				&me->ret,
				VS_K_noFrozenFeature_LCAH,
				VS_m_BEAM )
	locate_class		"+VSfeature"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	/*
	 * Beams in reference files accepted.
	 */
	locate_owner		"  LC_RIGID_COMP
				 | LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER
				 | LC_REF_OBJECTS"

	/*
	 * Accept locate by name or object.
	 */
	mask			"GRm_DATA
				 | GRm_STRING
				 | GRm_OBJID
				 | GRm_BACK_UP"
	filter			locate
		on EX_DATA or EX_OBJID
			/*
			 * Store beam, put accept point onto event queue (hence
			 * the argument "1").
			 */
			do store_operand( &me->ret, 1 )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			/*
			 * Construct stuff.
			 */
			do operation( &me->ret )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state start
			/*
			 * Flush input, restart.
			 */
			do discard_all_input( &me->ret )	  state start

		on EX_BACK_UP
			do discard_operators( &me->ret )	  state start

at init do message_key VS_M_VSPAsPnBmE
/*----------------------------------------------------------------------------*/

