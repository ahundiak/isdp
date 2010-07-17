/*
	I/STRUCT
	"Create Composite Profile" command.
*/
command_string	VSC_M_VSCrCmPr,0,VSCrCmPr
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VScrcppfCmd
product_name	"$STRUCT"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "VSmsg.h"
#include "vscmddef.h"
#include "vsqryrdbdef.h"

state start
	execute verifyLogin( &me->ret )
	on SUCCESS state realStart

	status_key VS_W_NoDBConnection
	execute waitTimer( 4 )
	on ELSE	   state terminate

state realStart
	execute	createForm()
	on ELSE state main

state main
	execute 		was_init_successful( &me->ret )
		on RETURN_CODE = "MSFAIL"			state abortCmd
	execute 		init_cmd( &me->ret )
	execute 		disable_form( &me->ret )
	execute 		get_nb_plates( &me->ret )
		on ELSE 					state begin


state begin
	prompt_key		VS_P_EnterNbPlate
	filter			get_event

		on GR_UNKNOWN_TYPE.VS_K_SAME_STATE
			do get_nb_plates( &me->ret )		state .
		on GR_UNKNOWN_TYPE.VS_K_END_STATE
			do init_plates_definition( &me->ret )
			do initForm( &me->ret )
				on RETURN_CODE = "VS_K_ABORT_CMD"
								state abortCmd
			do fill_form( &me->ret )
			do enable_form( &me->ret )			state modifyForm


state modifyForm
	prompt_key		VS_P_ModForm
	filter			get_event

		on GR_UNKNOWN_TYPE.VS_K_END_STATE		state side1
		on EX_RESTART					state main


state side1
	prompt_key		VS_P_IdFirstSide
	accept_key		VS_P_AccRej
	filter			VSlocateGadget
	
		on GR_UNKNOWN_TYPE.VS_K_FORM_MOVEON			
			do status 	"Check retrun code" 	state .

		on EX_BACK_UP					state modifyForm

		on EX_RESTART					state main

		on GR_UNKNOWN_TYPE.VS_K_GADGET_LOCATED
			do find_plate2( &me->ret )
				on RETURN_CODE = "VS_K_SAME_STATE"
					do status_key VS_E_BadSide
								state .
								state side2


state side2
	prompt_key		VS_P_IdSeconSide
	accept_key		VS_P_AccRej
	filter			VSlocateGadget

		on EX_BACK_UP					state side1

		on EX_RESTART					state main

		on GR_UNKNOWN_TYPE.VS_K_END_STATE		state side1

		on GR_UNKNOWN_TYPE.VS_K_GADGET_LOCATED
			do find_plate1( &me->ret )
				on RETURN_CODE = "VS_K_SAME_STATE"
					do status_key VS_E_BadSide
								state .
			do draw_plates( &me->ret )		state modifyForm


state abortCmd
	execute abortCmd( &me->ret )
	on ELSE state terminate

at init		do message_key VS_M_VSCrCmPr
		do initRDBdata()
		do setQueryType( &me->ret, VS_K_PLATE_QY )
at wakeup	do verifyLogin( &me->ret )
at delete	do freeRDBdata()
/*----------------------------------------------------------------------------*/
