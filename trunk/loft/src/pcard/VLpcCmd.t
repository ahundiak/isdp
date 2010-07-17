

command_string	VLC_M_PL_PROFCARD,0,VLPlStPc
command_table	"vl.cmd"
super_class	VLlocateCmd
class		VLpcCmd
product_name	"$LOFT"
options		"siTC"
status_display	"VLpcOption", "-1", "-1"


/* --------------------------- State Table ------------------------ */

state_table
#include "vlmsg.h"

state 	start
message_key		VL_S_PL_PROFCARD
status			" "

	on ELSE							state getStiff

state	getStiff
prompt_key		VL_P_STIFBEAM
locate_eligible		"+VSfeature"
locate_owner		"LC_RIGID_OWNER | LC_FLEX_OWNER | LC_REF_OBJECTS"
locate_properties	"LC_LC_ONLY | LC_DP_ONLY | LC_RW"
execute			VLbeamActionHandlerOn( &me->ret )
filter			locate

	on EX_RJT_MOVEOM					state .
	on EX_BACK_UP						state -
	on EX_OBJID or EX_DATA	
			do VLstoreResponse(&me->ret)
			do VLstoreLocate( &me->ret )
			do VLfreeList( &me->ret, 1 )
			do VLstoreList( &me->ret, 0, 1 )
								state getCs

state	getCs
prompt_key		VL_P_COOR_SYS
status			" "
locate_eligible		"+GRgencs"
execute			VLstructActionHandlerOff( &me->ret )
filter			locate

	on EX_RJT_MOVEOM					state .
	on EX_BACK_UP						state -
	on EX_OBJID or EX_DATA	
			do VLstoreResponse(&me->ret)
			do VLstoreLocate( &me->ret )
			do VLfreeList( &me->ret, 2 )
			do VLstoreList( &me->ret, 0, 2 )	state placePc

state	placePc
status			"Processing Stiffener Profile card.."
prompt 			" "

	execute VLcheckInput( &me->ret )
		on RETURN_CODE = VL_S_SUCCESS
				do VLpcPlace			state start
	on ELSE							state errState

state errState
status		" Drawing Border not found "
error_box	" Drawing Border not found "

	on ELSE							state getStiff

/* --------------------------------------------------------------------	*/
