/*
	I/STRUCT
	"Modify Plate" command.
*/
command_string	VSC_M_VSMdPl,0,VSMdPl
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSmdplatCmd
product_name	"$STRUCT"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "msdef.h"
#include "lcdef.h"
#include "dp.h"
#include "VSmsg.h"
#include "vsdef.h"
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
	execute	createForm()
	execute setFormTitle()
	on ELSE state locatePlate

state locatePlate
	execute was_init_successful( &me->ret )
		on RETURN_CODE = "MSFAIL" state terminate

	execute			tellUser( MS_NO_MSG )
	execute			disable_form( &me->ret )
	execute			ActivateDismissGadget( &me->ret )
	execute			init_cmd( &me->ret )
	execute 		setupActionHandler(
					&me->ret,
					VS_K_isAnEditableFeature_LCAH,
					VS_m_SRC_PLATE )
	prompt_key		VS_P_IdPlOrGr
	accept_key		VS_P_AccRej
	locate_class		"+VSplate"
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
		on EX_DATA 	do store_support( &me->ret )
					on RETURN_CODE = "VS_K_RESTART_CMD"
						state haveError
					state formActive

state formActive
	execute		load_attributes( &me->ret )
				on RETURN_CODE = "VS_K_ABORT_CMD"
					do status_key VS_E_ErrEncCmdTrm
					state terminate
	execute		fill_form( &me->ret )
				on RETURN_CODE = "VS_K_ABORT_CMD"
					do status_key VS_E_ErrEncCmdTrm
					state terminate
	execute		enable_form( &me->ret )
	execute		display_support_normal( GRhd )
	execute		dpLocObjs( &me->ret, 0, GRhd )
	execute		tellUser( MS_NO_MSG )
	on ELSE state formModify

state formModify
	prompt_key	VS_P_ModForm
	filter		get_event
	
		on GR_UNKNOWN_TYPE.VS_K_LOAD_ATTR		state LoadAttr

		on EX_BACK_UP	do resetForm( &me->ret )
				do display_support_normal( GRhe )
				do rmLastLocObjs( 0 ) state locatePlate

state LoadAttr
	execute 		setupActionHandler(
					&me->ret, VS_K_RESET_LCAH, 0 )
	execute			display_support_normal( GRhe )
	prompt_key		VS_P_IdPlLoadAttr
	accept_key		VS_P_AccRej
	locate_class		"+VSplate"
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
		
		on EX_RJT_MOVEON do display_support_normal( GRhd )
				 do dpLocObjs( &me->ret, 0, GRhd )
				 				state -
		
		on EX_DATA	do load_attributes_from_plate( &me->ret )
					on RETURN_CODE = "VS_K_ABORT_CMD"
					do status_key VS_E_ErrEncCmdTrm
					state terminate
				do fill_form( &me->ret )
					on RETURN_CODE = "VS_K_ABORT_CMD"
					do status_key VS_E_ErrEncCmdTrm
					state terminate
				do display_support_normal( GRhd )
				do dpLocObjs( &me->ret, 0, GRhd )
							        state -

state haveError
	status_key VS_E_ErrEncCmdRst
	on ELSE do rmLastLocObjs( 0 )		state locatePlate

at init		do message_key VS_M_VSMdPl
		do initRDBdata()
		do setQueryType( &me->ret, VS_K_PLATE_QY )
at wakeup	do verifyLogin( &me->ret )
		do checkPWD()
at delete	do freeRDBdata()
/*----------------------------------------------------------------------------*/
