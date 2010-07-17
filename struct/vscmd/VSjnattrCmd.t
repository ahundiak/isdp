/*
	I/STRUCT
	"Set Active Joint Attributes" command.
*/
command_string	VSC_M_VSStAcJnAt,0,VSStAcJnAt
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSjnattrCmd
product_name	"$STRUCT"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "VSmsg.h"
#include "vscmddef.h"

state main
	message_key		VS_M_VSStAcJnAt
	ms_on_off		MS_OFF
	execute 		does_form_exist( &me->ret )

		on RETURN_CODE = "VS_K_FORM_EXIST"
					do ms_on_off MS_ON
					do status_key VS_I_AJAfmExists
								state terminate

		on ELSE do createForm( &me->ret )
				on RETURN_CODE = "VS_K_ABORT_CMD"
								state abortCmd
			do initForm( &me->ret )
				on RETURN_CODE = "VS_K_ABORT_CMD"
								state abortCmd
			do displayForm( &me->ret )		state start


state start
	filter_mode		EX_ALL_ASCII_MODE
	filter			wfi

		on CLEAR_STACK or
		   TERMINATE	do deleteForm( &me->ret )
				do ms_on_off MS_ON		state terminate

		on EX_FORM_FINISHED do ms_on_off MS_ON		state terminate

		on EX_CMD_KEY or
		   CMD_STRING or
		   ELSE 					state .


state abortCmd
	status_key VS_E_ErrEncCmdTrm
	on ELSE state terminate


at init 	do disable_enable_pkt_menu( 0 )
at delete	do disable_enable_pkt_menu( 1 )
/*----------------------------------------------------------------------------*/
