/*
	I/STRUCT
	"Create Shell Expansion" command.
*/
command_string	VSC_M_VSCrShExp,0,VSCrShExp
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSshexpCmd
product_name	"$STRUCT"
form		"VSshellExp.fm",0,1,"-1","-1"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "lcdef.h"
#include "VSmsg.h"
#include "vscmddef.h"

state start
	execute 	setFlags( VS_m_POconstWithSymb | VS_m_POnoOperandRedisp)
	execute 		setMinMaxOperators( 0, 3 )
	execute 		init_cmd( &me->ret )
	execute 		hilite_gadget( 0 )
	construct_class 	"VSshellExp"
	prompt_key		VS_P_IdShell
	accept_key		VS_P_AccWRefPlane
	locate_class		"EMSsubbs"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	locate_owner		"  LC_RIGID_COMP
				 | LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER
				 | LC_REF_OBJECTS"
	/*
	 * Accept locate by name.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID"
	filter			locate

		on EX_DATA
		or EX_OBJID	do store_operand( &me->ret, 1 )
					on RETURN_CODE != "VS_K_ACT_SUCCESS"
						do handleError( me->ret )
							state .
							state locRefPlane


state locRefPlane
	execute 		hilite_gadget( 1 )
	prompt_key		VS_P_IdRefPlane
	accept_key		VS_P_AccWStartPlane
	locate_class		"EMSplane"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	locate_owner		"  LC_RIGID_COMP
				 | LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER
				 | LC_REF_OBJECTS"
	/*
	 * Accept locate by name.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID |
				 GRm_BACK_UP | GRm_RJT_MOVEON"
	filter			locate

		on EX_BACK_UP	do discard_all_input( &me->ret )
							state -

		on EX_RJT_MOVEON do display_default_gadget( 1 )
							state locStPlane

		on EX_DATA
		or EX_OBJID	do store_operator( &me->ret, 1 )
					on RETURN_CODE != "VS_K_ACT_SUCCESS"
						do handleError( me->ret )
							state .
							state locStPlane


state locStPlane
	execute 		hilite_gadget( 2 )
	prompt_key		VS_P_IdStartPlane
	accept_key		VS_P_AccWEndPlane
	locate_class		"EMSplane"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	locate_owner		"  LC_RIGID_COMP
				 | LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER
				 | LC_REF_OBJECTS"
	/*
	 * Accept locate by name.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID |
				 GRm_BACK_UP | GRm_RJT_MOVEON"
	filter			locate

		on EX_BACK_UP	do discard_operators( &me->ret )
							state -

		on EX_RJT_MOVEON
				do display_default_gadget( 2 )
				do operation( &me->ret )
					on RETURN_CODE != "VS_K_ACT_SUCCESS"
						do handleError( me->ret )
							state start
				do discard_all_input( &me->ret )
							state start

		on EX_DATA
		or EX_OBJID	do store_operator( &me->ret, 1 )
					on RETURN_CODE != "VS_K_ACT_SUCCESS"
						do handleError( me->ret )
							state .
							state locEndPlane


state locEndPlane
	execute 		hilite_gadget( 3 )
	prompt_key		VS_P_IdEndPlane
	accept_key		VS_P_AccRej
	locate_class		"EMSplane"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	locate_owner		"  LC_RIGID_COMP
				 | LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER
				 | LC_REF_OBJECTS"
	/*
	 * Accept locate by name.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID |
				 GRm_BACK_UP"
	filter			locate

		on EX_BACK_UP	do discard_start_plane( &me->ret )
							state -

		on EX_DATA
		or EX_OBJID	do unhilite_end_gadget( &me->ret )
				do store_operator( &me->ret, 0 )
					on RETURN_CODE != "VS_K_ACT_SUCCESS"
						do handleError( me->ret )
							state .
				do operation( &me->ret )
					on RETURN_CODE != "VS_K_ACT_SUCCESS"
						do handleError( me->ret )
							state start
				do discard_all_input( &me->ret )
							state start


at init do message_key VS_M_VSCrShExp
/*----------------------------------------------------------------------------*/
