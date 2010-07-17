/*
	I/STRUCT
	"Merge Shell Expansion" command.
*/
command_string	VSC_M_VSMerShExp,0,VSMerShExp
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSmeshexCmd
product_name	"$STRUCT"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "OMtypes.h"
#include "lcdef.h"
#include "VSmsg.h"
#include "vscmddef.h"

state start
	execute 		setFlags( VS_m_POnoOperandRedisp )
	execute 		setMinMaxOperators( 1, 1 )
	construct_class 	"VSmergeShExp"
	prompt_key		VS_P_IdFrShellExp
	accept_key		VS_P_AccWToShellExp
	locate_class		"VSshellExp"
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
	filter			locate_noauto

		on EX_DATA
		or EX_OBJID	do store_operand( &me->ret, 1 )
					on RETURN_CODE != "VS_K_ACT_SUCCESS"
						do handleError( me->ret )
								  state .
								  state locShExp


state locShExp
	prompt_key		VS_P_IdToShellExp
	accept_key		VS_P_AccRej
	locate_class		"VSshellExp"
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
	filter			locate_noauto

		on EX_DATA
		or EX_OBJID
			do store_operator( &me->ret, 0 )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			do operation( &me->ret )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state start
			do merge_expanded_curve( &me->ret )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state start
			do discard_all_input( &me->ret )	  state start

		on EX_BACK_UP					  state start

at init do message_key VS_M_VSMerShExp
/*----------------------------------------------------------------------------*/
