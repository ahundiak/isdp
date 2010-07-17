/*
	I/STRUCT
	"Place Beam" command.
*/
command_string	VSC_M_VSPBm,0,VSPBm
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSplbeamCmd
product_name	"$STRUCT"

/*----------------------------------------------------------------------------*/
state_table

#include "msdef.h"
#include "lcdef.h"
#include "dp.h"
#include "dpmacros.h"
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
	execute	createForm()
	execute init_cmd( &me->ret )
	on ELSE state locateSurface

state locateSurface
	execute was_init_successful( &me->ret )
		on RETURN_CODE = "MSFAIL" state terminate
	execute			tellUser( VS_I_RejPlSurf )
	execute 		setupActionHandler(
					&me->ret, VS_K_RESET_LCAH, 0 )
	prompt_key		VS_P_IdSuppModForm 
	accept_key		VS_P_AccSuppAx
	locate_class		"EMSsubbs"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY"
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
		on GR_UNKNOWN_TYPE.VS_K_LOAD_ATTR 		state LoadAttr
		
		on EX_RJT_MOVEON 				state PlacePl

		on EX_OBJID	do store_surface( &me->ret )
					on RETURN_CODE = "VS_K_RESTART_CMD"
								state haveError
						 		state LocAxis
		on EX_DATA 	do store_surface( &me->ret )
					on RETURN_CODE = "VS_K_RESTART_CMD"
								state haveError
				do chain_locate( &me->ret )	state LocAxis

state LocAxis
	execute			tellUser( MS_NO_MSG )
	execute			init_cmd( &me->ret ) 
	execute			enable_form( &me->ret )
	prompt_key		VS_P_IdSuppAx
	accept_key		VS_P_AccRej
	construct_class		"VSsrcBeam"
	/*
	 * Accept curves but not points.
	 */
	execute 		setupActionHandler(
					&me->ret,
					VS_K_rejectSubClass_LCAH,
					"GRpoint" )
	locate_class		"GRcurve"
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

		on EX_BACK_UP	do rmLastLocObjs( 0 ) state locateSurface

		on EX_OBJID	do process_fence( &me->ret )
					on RETURN_CODE = "VS_K_RESTART_CMD"
						state haveError
					on RETURN_CODE = "VS_K_NO_FENCE"
					   do status_key VS_W_NoObjLoc
						state .
				do inter_display( &me->ret )
				do enable_form( &me->ret )
				do hilight_elem( &me->ret )
					state formActive
 		on EX_DATA 	do store_axis( &me->ret )
					on RETURN_CODE = "VS_K_RESTART_CMD"
						state haveError
				do inter_display( &me->ret )
				do enable_form( &me->ret )
				do hilight_elem( &me->ret )
					state formActive


state formActive
	prompt_key	VS_P_ModForm
	filter		get_event
	
		on GR_UNKNOWN_TYPE.VS_K_LOAD_ATTR		 state LoadAttr
		
		on EX_BACK_UP	do unhilight_elem( &me->ret )
				do rmLastLocObjs( 1 ) state LocAxis
	

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


state PlacePl
	prompt_key	VS_P_IdWindPlSurf
	execute		tellUser( MS_NO_MSG )
	filter		get_event
		on EX_RJT_MOVEON				state -

		on EX_DATA or 
		   EX_STRING	do place_plane( &me->ret )
					on RETURN_CODE = "VS_K_ABORT_CMD"
								state haveError
					on RETURN_CODE = "VS_K_NO_WINDOW"
								state .
								state LocAxis

state haveError
	status_key VS_E_ErrEncCmdRst
	on ELSE do rmLastLocObjs( 0 )	state locateSurface

at init		do message_key VS_M_VSPBm
		do setMatchKey( "beam" )
		do initRDBdata()
		do setQueryType( &me->ret, VS_K_BEAM_QY )
at wakeup	do verifyLogin( &me->ret )
		do checkPWD()
at delete	do freeRDBdata()
/*----------------------------------------------------------------------------*/
