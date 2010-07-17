/*
	I/STRUCT
	"Select Macro Feet" command
*/
command_string	VSC_M_VSSlMcFt,0,VSSlMcFt
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSslmcftCmd
product_name	"$STRUCT"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "msdef.h"
#include "lcdef.h"
#include "VSmsg.h"
#include "vscmddef.h"

state start
	execute		setMinMaxOperators( 0, 0 )
	message_key	VS_M_VSSlMcFt
	prompt_key	VS_P_KInMcFoot
	mask		"GRm_STRING"
	filter		get_event
		on EX_STRING
			do checkRegExp( &me->ret )
				on RETURN_CODE != "MSSUCC"
					do status_key VS_W_InvRegExp
					state .
			state locateMacros

state locateMacros
	prompt_key		VS_P_IdMcSet
	accept_key		VS_P_AccRej
	locate_class		"ACncpx"
	locate_properties	"LC_LC_ONLY | LC_DP_ONLY | LC_RW"
	locate_owner		"  LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER
				 | LC_REF_OBJECTS"
	mask			"  GRm_DATA
				 | GRm_STRING
				 | GRm_OBJID
				 | GRm_BACK_UP"
	filter			locate
		on EX_BACK_UP	state -
		on EX_DATA
			do store_operand( &me->ret, 0 )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret )	state .
			do operation( &me->ret )
				on RETURN_CODE =  "VS_K_NO_FENCE"	state .
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret )	state .
			state acceptSet
		on EX_OBJID
			do process_fence( &me->ret, VS_K_OPRND )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret )	state .
			do operation( &me->ret )
				on RETURN_CODE =  "VS_K_NO_FENCE"	state .
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret )	state .
			state acceptSet

state acceptSet
	execute		displaySet( GRhd )
	prompt_key	VS_P_AccSetRjt
	mask		"GRm_DATA | GRm_RJT_MOVEON | GRm_BACK_UP"
	filter		get_event
		on EX_DATA
			do displaySet( GRhe )
			do putSetOntoQ()
			do discard_all_input( &me->ret )
			state terminate
		on EX_RJT_MOVEON
			do displaySet( GRhe )
			do dissolveSet()
			do discard_all_input( &me->ret )
			state start
		on EX_BACK_UP
			do displaySet( GRhe )
			do dissolveSet()
			do discard_all_input( &me->ret )
			state -
/*----------------------------------------------------------------------------*/
