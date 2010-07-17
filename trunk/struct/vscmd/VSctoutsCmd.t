/*
	I/STRUCT
	"Process Cutouts" command.
*/
command_string	VSC_M_VSPrCt,0,VSPrCt
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSctoutsCmd
product_name	"$STRUCT"
form		"VSprcCtOuts.fm",0,0,"-1","-1"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "VSmsg.h"
#include "vscmddef.h"

state start
	message_key		VS_M_VSPrCt
	prompt_key		VS_P_KyInMcNms
	filter			get_event

		on EX_FORM_FINISHED				state terminate

		on GR_UNKNOWN_TYPE.VS_K_GADGET_LOCATED		state locatePart


state locatePart
	prompt_key		VS_P_IdPartForCt
	accept_key		VS_P_AccRej
	locate_class		"+VSbeam,VSplate"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	locate_owner		"  LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER"
	/*
	 * Accept locate by name.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID |
				 GRm_BACK_UP | GRm_FORM_FINISHED"
	filter			locate

		on EX_BACK_UP					state start

		on EX_FORM_FINISHED				state terminate

		on EX_DATA	do store_part( &me->ret )
					on RETURN_CODE = "VS_K_RESTART_CMD"
								state haveError
								state start

		on EX_OBJID	do process_fence( &me->ret )
					on RETURN_CODE = "VS_K_NO_FENCE"
					   do status_key VS_W_NoObjLoc
								state .
					on RETURN_CODE = "VS_K_RESTART_CMD"
								state haveError
								state start


state haveError
	status_key VS_E_ErrEncCmdRst
	on ELSE do rmLastLocObjs( 0 )
		do setDefaults()				state start


at init 	do setDefaults()
at wakeup	do display_form 0
at sleep	do erase_form	0
at delete	do rmLastLocObjs( 0 )
		do saveDefaults()
/*----------------------------------------------------------------------------*/
