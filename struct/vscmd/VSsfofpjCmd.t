/*
	I/STRUCT
	"Place Surface Of Projection Parallel To Plane" command.
*/
command_string	VSC_M_VSPSrPrPTP,0,VSPSrPrPTP
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSsfofpjCmd
product_name	"$STRUCT"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include <limits.h>
#include "VSmsg.h"
#include "vscmddef.h"

state start
	execute 		setupActionHandler(
					    &me->ret, VS_K_RESET_LCAH, 0 )
	prompt_key		VS_P_IdPlane
	accept_key		VS_P_AccWClCv
	/*
	 * Accept locate by name or object.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID"
	locate_class		"EMSplane"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	locate_owner		"  LC_RIGID_COMP
				 | LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER
				 | LC_REF_OBJECTS"
	filter			locate

		on EX_DATA or EX_OBJID
			/*
			 * Store plane, put accept point onto event queue (hence
			 * the argument "1").
			 */
		   	do store_operand( &me->ret, 1 )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
							 state haveError
				 state getCurves


state getCurves
	prompt_key		VS_P_IdClCv
	accept_key		VS_P_AccRej
	/*
	 * Accept curves but not points.
	 */
	execute 		setupActionHandler(
					&me->ret,
					VS_K_rejectSubClass_LCAH,
					"GRpoint" )
	locate_class		"+GRcurve"
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
	 * Accept locate by name or object.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID |
				 GRm_BACK_UP"
	filter			locate

		on EX_BACK_UP	do discard_all_input( &me->ret ) state start

		on EX_OBJID	do process_fence( &me->ret, VS_K_OPRTR )
					on RETURN_CODE = "VS_K_RESTART_CMD"
								 state haveError
					on RETURN_CODE = "VS_K_NO_FENCE"
					   do status_key VS_W_NoObjLoc
								 state .
					state getWidth
		on EX_DATA	do store_operator( &me->ret, 0 )
					on RETURN_CODE != "VS_K_ACT_SUCCESS"
								 state haveError
					state getWidth


state getWidth
	prompt_key		VS_P_KyInWidth
	filter			VSget_exp

		on EX_BACK_UP	do discard_operators( &me->ret ) state -

		on EX_OBJID or
		   EX_DATA  or
		   EX_STRING	do construct_surface( &me->ret )
					on RETURN_CODE != "VS_K_ACT_SUCCESS"
								 state haveError
				do discard_operators( &me->ret ) state getCurves


state haveError
	status_key VS_E_ErrEncCmdRst
	on ELSE do discard_all_input( &me->ret )	 state start

at init	do message_key VS_M_VSPSrPrPTP
	do setMinMaxOperators( 1, INT_MAX )
	do suppressAutoHilite()
/*----------------------------------------------------------------------------*/
