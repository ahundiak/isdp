/*
	I/STRUCT
	"Set Beam Arrow Size" command
*/ 
command_string	VSC_M_VSStBmArSz,0,VSStBmArSz
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSbmawszCmd
product_name	"$STRUCT"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "dpbco.h"
#include "vscmddef.h"
#include "VSmsg.h"

state *
	on EX_RESTART	state start

state start
	on NO_INPUT_PENDING
     		do message_key	VS_M_VSStBmArSz
		do prompt_key	VS_P_KyInNwArwSz
		state get_input  
	on ELSE	state get_input

state get_input     
	filter	get_event
		/*
		 * Empty string input: exit command.
		 */
		on EX_VALUE.GRst_DEFAULT
			state terminate

		/*
		 * Distanve value: try to feed DPB.
		 */
		on DISTANCE
			do VSbmawszCmd.putToDpb( sts, me->event1.event.value )

				on RETURN_CODE = "VS_K_ACT_SUCCESS"
					do VSbmawszCmd.displayValue( sts )
					do waitTimer( 4 )
					state terminate

				on RETURN_CODE = "VS_K_ABORT_CMD"
					do status_key VS_E_ErrEncCmdTrm
					do waitTimer( 4 )
					state terminate

				on RETURN_CODE = "CO_E_INVINP"
					/*
					 * Bad input: retry.
					 */
					do status_key VS_I_InvArwSz
					state start

		/*
		 * Filter error.
		 */
		on ERROR or WARNING or SEVERE
                	do error_box_key VS_E_ErrEncCmdTrm  
			state terminate
		state .

/*
 * Display active value at wake-up.
 */
at wakeup	do VSbmawszCmd.displayValue( sts )
/*----------------------------------------------------------------------------*/
