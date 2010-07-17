/*
	I/STRUCT
	"Place Joint" command.
*/
command_string	VSC_M_VSMdJn,0,VSMdJn
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSmodJntCmd 
product_name	"$STRUCT"
form		"VSactJnAttr.fm",0,0,"-1","-1"
form		"VSaddUsrAtt.fm",1,0,"-1","-1"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "lcdef.h"
#include "VSmsg.h"
#include "vsdef.h"
#include "vscmddef.h"

state start
	/*
	 * Set min. and max. numbers of boundary curves that command may accept.
	 */
	execute			setMinMaxOperators( 0, 0 )
	prompt_key		VS_P_IdJoint
	accept_key		VS_P_AccRej
	locate_class		"+VSjoint"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	locate_owner		"  LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER"

	/*
	 * Accept locate by name or object.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID"
	filter			locate

		on EX_DATA or EX_OBJID
			do store_operand( &me->ret, 0 )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) 
							 state .
			do fillForm( &me->ret )
			do display_form 0
			state modifyForm

state modifyForm
	display_form 0
	prompt_key	VS_P_ModForm
	mask		"GRm_FORM_FINISHED | GRm_RESTART"
	filter		get_event
		on EX_FORM_FINISHED	state terminate
		on EX_RESTART
			do erase_form 0
			do erase_form 1
			do discard_all_input( &me->ret )	
			state start

at init do message_key VS_M_VSMdJn
/*----------------------------------------------------------------------------*/
