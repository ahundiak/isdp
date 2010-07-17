/*
	I/STRUCT
	"Set Active Unit(s) of Mass Measure" command
*/ 
command_string	VSC_M_VSStAcUnMM,0,VSStAcUnMM
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSstunitCmd
product_name	"$STRUCT"
status_display	"VSunitAlias.fm","-1","-1" 
/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "dpbco.h"
#include "VSmsg.h"
#include "vscmddef.h"
#include "vsmeasdef.h"

state *
	on EX_RESTART	state start

state start
	/*
	 * We want to decipher input of the type "<unit1>,<unit2>,<unit3>"
	 */
	on NO_INPUT_PENDING
		do message_key	VS_M_VSStAcUnMM
		do prompt_key	VS_P_KyInMassMeas
		state get_first_input
       
	on ELSE		state get_first_input

state get_first_input

	filter	get_event
		on NULL_TEXT_VALUE	
			state terminate
		on TEXT_VALUE
			do storeEvent( &me->event1, 0 )
			state get_second_input
 
state get_second_input

	on NO_INPUT_PENDING
		do storeEvent( &me->event1, 1 )
                state get_third_input

	filter	get_event
		on TEXT_VALUE
			do storeEvent( &me->event1, 1 )
			state get_third_input

state get_third_input

	on NO_INPUT_PENDING
		do storeEvent( &me->event1, 2 )
		state have_input

	filter	get_event
		on TEXT_VALUE
			do storeEvent( &me->event1, 2 )
                        state have_input

state have_input
	execute putActiveUnits( &me->ret )

	on RETURN_CODE = "VS_K_ACT_SUCCESS"
		do displayActiveUnits( &me->ret )
		do waitTimer( 4 )
		state terminate

	on RETURN_CODE = "CO_E_INVINP"
		do status_key VS_I_InvMassMeas
		state start

	on ELSE
		do status_key VS_E_ErrEncCmdTrm
		do waitTimer( 4 )
		state terminate

at init   do setUOMtable( VS_K_uomMASS )
at wakeup do displayActiveUnits( &me->ret )
	  do status_display_button( 1 )
at sleep  do status_display_button( 0 )

/*----------------------------------------------------------------------------*/
