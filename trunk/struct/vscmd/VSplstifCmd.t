/*
	I/STRUCT
	"Place Stiffener" command.
*/
command_string	VSC_M_VSPlSt,0,VSPlSt
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSplstifCmd
product_name	"$STRUCT"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "msdef.h"
#include "lcdef.h"
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
	execute createForm()
	execute initForm( &me->ret )
	on ELSE state locatePlate

state locatePlate
	execute was_init_successful( &me->ret )
		on RETURN_CODE = "MSFAIL" state terminate
	execute 		init_cmd( &me->ret )
	execute 		enable_form( &me->ret )
	execute 		tellUser( MS_NO_MSG )
	execute 		setupActionHandler(
					&me->ret, VS_K_RESET_LCAH, 0 )
	construct_class 	"VSbeamAxis"
	prompt_key		VS_P_IdPlate
	accept_key		VS_P_AccRej
	/*
	 * Reject `frozen' plates.
	 */
	execute 		setupActionHandler(
					&me->ret,
					VS_K_noFrozenFeature_LCAH,
					VS_m_PLATE )
	locate_class		"+VSfeature"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	locate_owner		"  LC_RIGID_COMP
				 | LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER
				 | LC_REF_OBJECTS"
	/*
	 * Accept locate by name.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID"
	filter			locate

		on GR_UNKNOWN_TYPE.VS_K_LOAD_ATTR	     state LoadAttr

		on EX_DATA
		or EX_OBJID
				do store_element( &me->ret, 0 )
					on RETURN_CODE = "VS_K_OBJONCHEXIST"
							     state .
				do swap_side( &me->ret )
					on RETURN_CODE = "VS_K_RESTART_CMD"
							     state haveError
							     state SelectSide


state SelectSide
	execute 		hilight_side( &me->ret )
	prompt_key		VS_P_AccSwapSide
	filter			get_event

		on GR_UNKNOWN_TYPE.VS_K_LOAD_ATTR	     state LoadAttr

		on GR_UNKNOWN_TYPE.VS_K_GOTO_PLATE
                                do unhilight_side( &me->ret )
                                do store_null_objid( 1 )
                                do rmLastLocObjs( 0 )        state locatePlate

		on EX_BACK_UP	do unhilight_side( &me->ret )
				do store_null_objid( 1 )     state locatePlate

		on EX_RJT_MOVEON do swap_side( &me->ret )
					on RETURN_CODE = "VS_K_RESTART_CMD"
							     state haveError
							     state .

		on EX_DATA	 do unhilight_side( &me->ret )
							     state LocSurfOrLine


state LocSurfOrLine
	execute                 SetLastPlSiId( &me->ret )
        construct_class         "VSbeamAxis"
	prompt_key		VS_P_IdSurfOrLine
	accept_key		VS_P_AccWithStartLimit
	/*
	 * Accept curves but not points.
	 */
	execute 		setupActionHandler(
					&me->ret,
					VS_K_rejectSubClass_LCAH,
					"GRpoint" )
	locate_class		"GRcurve,EMSsubbs"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	/*
	 * Rigid component will be not located by a fence without the
	 * flag LC_RIGID_COMP_PRISM.
	 */
	locate_owner		"  LC_RIGID_COMP
				 | LC_RIGID_COMP_PRISM
				 | LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER
				 | LC_REF_OBJECTS"
	/*
	 * Accept locate by name.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID | GRm_BACK_UP"
	filter			locate

		on GR_UNKNOWN_TYPE.VS_K_LOAD_ATTR		state LoadAttr

		on GR_UNKNOWN_TYPE.VS_K_GOTO_PLATE
                                do delete_axis( &me->ret )
				do delete_surface( &me->ret )
                                do rmLastLocObjs( 0 )      	state locatePlate

		on EX_BACK_UP	do store_null_objid( 2 )	state SelectSide

		on EX_OBJID	do process_fence( &me->ret )
					on RETURN_CODE =  "VS_K_NO_FENCE"
						do status_key VS_W_NoObjLoc
						do waitTimer( 4 )
						state .
					on RETURN_CODE != "VS_K_ACT_SUCCESS"
						do status_key VS_E_ErrEncCmdRst
						do waitTimer( 4 )
						state locatePlate
					/* All OK */
					state LocStLimit

		on EX_DATA	do store_element( &me->ret, 2 )
					on RETURN_CODE = "VS_K_ACT_SUCCESS"
						do chain_locate( &me->ret )
				 		state LocStLimit
					on RETURN_CODE = "VS_K_OBJONCHEXIST"
						state .
					on RETURN_CODE = "VS_K_ACT_SUCCESS"
						do status_key VS_E_ErrEncCmdTrm
						state terminate
					/* All OK */
					do chain_locate( &me->ret )
				 	state LocStLimit



state LocStLimit
	execute 		setupActionHandler(
					&me->ret, VS_K_RESET_LCAH, 0 )
	prompt_key		VS_P_IdStartLimit
	accept_key		VS_P_AccWithEndLimit
	locate_class		"EMSsubbs"
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
				 GRm_BACK_UP | GRm_RJT_MOVEON"
	filter			locate

		on GR_UNKNOWN_TYPE.VS_K_LOAD_ATTR		state LoadAttr

		on GR_UNKNOWN_TYPE.VS_K_GOTO_PLATE
                                do delete_axis( &me->ret )
				do delete_surface( &me->ret )
                                do rmLastLocObjs( 0 )           state locatePlate

		on EX_BACK_UP	do store_null_objid( 3 )	state -

		on EX_RJT_MOVEON do store_null_objid( 3 )
				 do store_null_objid( 4 )
				 do construct_axis( &me->ret )
					on RETURN_CODE != "VS_K_ACT_SUCCESS"
						do status_key VS_E_ErrEncCmdRst
						state locatePlate
					/* All OK */
					do hilight_elem( &me->ret )
					do inter_display( &me->ret )
					do enable_form( &me->ret )
					state formActive

		on EX_OBJID	do store_element( &me->ret, 3 )
					on RETURN_CODE = "VS_K_OBJONCHEXIST"
								state .
								state LocEdLimit

		on EX_DATA	do store_element( &me->ret, 3 )
					on RETURN_CODE = "VS_K_OBJONCHEXIST"
								state .
				do chain_locate( &me->ret )
						 		state LocEdLimit


state LocEdLimit
	prompt_key		VS_P_IdEndLimit
	accept_key		VS_P_AccRej
	locate_class		"EMSsubbs"
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
				 GRm_BACK_UP | GRm_RJT_MOVEON"
	filter			locate

		on GR_UNKNOWN_TYPE.VS_K_LOAD_ATTR		state LoadAttr

		on GR_UNKNOWN_TYPE.VS_K_GOTO_PLATE
                                do delete_axis( &me->ret )
				do delete_surface( &me->ret )
                                do rmLastLocObjs( 0 )    	state locatePlate

		on EX_BACK_UP	do store_null_objid( 4 )	state -

		on EX_DATA or
		   EX_OBJID	do store_element( &me->ret, 4 )
					on RETURN_CODE = "VS_K_OBJONCHEXIST"
								state .
				do construct_axis( &me->ret )
					on RETURN_CODE != "VS_K_ACT_SUCCESS"
						do status_key VS_E_ErrEncCmdRst
						state locatePlate
					/* All OK */
					do hilight_elem( &me->ret )
					do inter_display( &me->ret )
					do enable_form( &me->ret )
					state formActive

state formActive
	construct_class "VSstfBeam"
	prompt_key	VS_P_ModForm
	filter		get_event

		on GR_UNKNOWN_TYPE.VS_K_LOAD_ATTR		state LoadAttr

		on GR_UNKNOWN_TYPE.VS_K_GOTO_PLATE              state .

		on EX_BACK_UP	
				do delete_surface( &me->ret )
				do delete_axis( &me->ret )
				do rmLastLocObjs( 0 )
								state LocSurfOrLine


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

		on GR_UNKNOWN_TYPE.VS_K_GOTO_PLATE
                                do delete_axis( &me->ret )
				do delete_surface( &me->ret )
                                do rmLastLocObjs( 0 )     	state locatePlate


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
	on ELSE  state locatePlate

at init 	do message_key VS_M_VSPlSt
		do setMatchKey( "stiffener" )
		do initRDBdata()
		do setQueryType( &me->ret, VS_K_BEAM_QY )
at wakeup	do verifyLogin( &me->ret )
		do checkPWD()
at delete	do freeRDBdata()
/*----------------------------------------------------------------------------*/
