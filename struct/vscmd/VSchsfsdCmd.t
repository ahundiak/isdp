/*
	I/STRUCT
	"Move Stiffener To Opposite Side" and
	"Move And Mirror Stiffener" commands.

	Notes :
	-------
		* Change Stiffener Side :

			|  <- stiffener
			|     ( old position )
			|
     reference point -> .-----
		---------------------			---------------------
		|      plate	    |	    =====>	|      plate	    |
		---------------------			---------------------
							    ----.
								|
						  stiffener ->	|
					    ( new position )	|


		* Change Stiffener Side And Mirror :

			|  <- stiffener
			|     ( old position )
			|
     reference point -> .-----
		---------------------			---------------------
		|      plate	    |	    =====>	|      plate	    |
		---------------------			---------------------
								.----
								|
						  stiffener ->	|
					    ( new position )	|

*/
command_string	VSC_M_VSMvSTOpSd,0,VSMvSTOpSd
synonym 	VSC_M_VSMvMrSt,1,VSMvMrSt
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSchsfsdCmd
product_name	"$STRUCT"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "VSmsg.h"
#include "vsdef.h"
#include "vscmddef.h"

state start

	/*
	 * Only retain stiffeners.
	 */
	execute 		setupActionHandler(
					&me->ret,
					VS_K_isAnEditableFeature_LCAH,
					VS_m_STF_BEAM )
	on CMD_TYPE = 0 do	message_key		VS_M_VSMvSTOpSd
								state main
	on CMD_TYPE = 1 do	message_key		VS_M_VSMvMrSt
								state main


state main
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

		on EX_DATA	do store_stiffener( &me->ret )
					on RETURN_CODE = "VS_K_RESTART_CMD"
						state haveError
				do hilight_new_side( &me->ret )
					on RETURN_CODE = "VS_K_RESTART_CMD"
						state haveError
								state acceptSide

		on EX_OBJID	do process_fence( &me->ret )
					on RETURN_CODE = "VS_K_RESTART_CMD"
						state haveError
					on RETURN_CODE = "VS_K_NO_FENCE"
					   do status_key VS_W_NoObjLoc
						state .
				do hilight_new_side( &me->ret )
					on RETURN_CODE = "VS_K_RESTART_CMD"
						state haveError
								state acceptSide


state acceptSide
	prompt_key	VS_P_AccNewSide
	filter		get_event

		on EX_RJT_MOVEON do rmLastLocObjs( 0 )
				 do unhilight_new_side( &me->ret )
				 				state main

		on EX_DATA	 do change_position( &me->ret )
					on RETURN_CODE = "VS_K_RESTART_CMD"
						state haveError
				 do rmLastLocObjs( 0 )
								state main


state haveError
	status_key VS_E_ErrEncCmdRst
	on ELSE do rmLastLocObjs( 0 )				state main
/*----------------------------------------------------------------------------*/
