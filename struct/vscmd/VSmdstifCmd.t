/*
	I/STRUCT
	"Modify Stiffener" command.
*/
command_string	VSC_M_VSMdSt,0,VSMdSt
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSmdstifCmd
product_name	"$STRUCT"


/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "msdef.h"
#include "dp.h"
#include "lcdef.h"
#include "vsdef.h"
#include "VSmsg.h"
#include "vscmddef.h"
#include "vsqryrdbdef.h"

state start
	execute verifyLogin( &me->ret )
	on SUCCESS state realStart

	status_key VS_W_NoDBConnection
	execute initToFailure()
	execute waitTimer( 4 )
	on ELSE	   state terminate

state realStart
	execute createForm()
	execute initForm( &me->ret )
	on ELSE state locateBeam

state locateBeam
	execute was_init_successful( &me->ret )
		on RETURN_CODE = "MSFAIL" state terminate

	/*
	 * Only retain stiffeners.
	 */
	execute 		setupActionHandler(
					&me->ret,
					VS_K_isAnEditableFeature_LCAH,
					VS_m_STF_BEAM )
	execute 		tellUser( MS_NO_MSG )
	execute 		disable_form( &me->ret )
	execute 		ActivateDismissGadget( &me->ret )
	execute 		init_cmd( &me->ret )
	prompt_key		VS_P_IdStOrGr
	accept_key		VS_P_AccRej
	locate_class		"+VSbeam"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	locate_owner		"  LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER"
	/*
	 * Accept locate by name.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID"
	filter			locate

		on EX_OBJID	do process_fence( &me->ret )
					on RETURN_CODE = "VS_K_RESTART_CMD"
						state haveError
					on RETURN_CODE = "VS_K_NO_FENCE"
					   do status_key VS_W_NoObjLoc
						state .
					state formActive
		on EX_DATA	do store_beam( &me->ret )
					on RETURN_CODE = "VS_K_RESTART_CMD"
						state haveError
					state formActive


state formActive
	execute 	load_attributes( &me->ret )
				on RETURN_CODE = "VS_K_ABORT_CMD"
					do status_key VS_E_ErrEncCmdTrm
					state terminate
	execute 	fill_form( &me->ret )
				on RETURN_CODE = "VS_K_ABORT_CMD"
					do status_key VS_E_ErrEncCmdTrm
					state terminate
	execute 	enable_form( &me->ret )
	execute 	tellUser( MS_NO_MSG )
	execute 	hilight_elem( &me->ret )
	execute 	inter_display( &me->ret )

		on ELSE state formModify


state formModify
	prompt_key	VS_P_ModForm
	filter		get_event

		on GR_UNKNOWN_TYPE.VS_K_LOAD_ATTR		state LoadAttr

		on EX_BACK_UP	do unhilight_elem( &me->ret )
				do resetForm( &me->ret )
				do rmLastLocObjs( 0 )
					state locateBeam


state LoadAttr
	execute 		setupActionHandler(
					&me->ret, VS_K_RESET_LCAH, 0 )
	prompt_key		VS_P_IdBmLoadAttr
	accept_key		VS_P_AccRej
	locate_class		"+VSbeam"
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
				 GRm_RJT_MOVEON"
	filter			locate

		on GR_UNKNOWN_TYPE.VS_K_LOAD_ATTR		state .

		on EX_RJT_MOVEON do hilight_elem( &me->ret )
				 do inter_display( &me->ret )	state -

		on EX_DATA	do load_attributes_from_beam( &me->ret )
					on RETURN_CODE = "VS_K_ABORT_CMD"
					do status_key VS_E_ErrEncCmdTrm
					state terminate
				do fill_form( &me->ret )
					on RETURN_CODE = "VS_K_ABORT_CMD"
					do status_key VS_E_ErrEncCmdTrm
					state terminate
				do hilight_elem( &me->ret )
				do inter_display( &me->ret )
				do draw_section_on_form( &me->ret )
								state -


state haveError
	status_key VS_E_ErrEncCmdRst
	on ELSE do rmLastLocObjs( 0 )	state locateBeam

at init 	do message_key VS_M_VSMdSt
		do initRDBdata()
		do setQueryType( &me->ret, VS_K_BEAM_QY )
at wakeup	do verifyLogin( &me->ret )
		do checkPWD()
at delete	do freeRDBdata()
/*----------------------------------------------------------------------------*/
