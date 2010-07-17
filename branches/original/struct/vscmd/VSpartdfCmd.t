/*
	I/STRUCT
	"Review Part Definition" command.
*/
command_string	VSC_M_VSRvStPrDf,0,VSRvStPrDf
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSpartdfCmd
product_name	"$STRUCT"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "VSmsg.h"
#include "vsdef.h"
#include "vscmddef.h"
#define	VS_K_LocStructElm	260

state start
	message_key		VS_M_VSRvStPrDf
	prompt_key		VS_P_IdStructElmt
	/*
	 * Do not accept joints.
	 */
	execute 		setupActionHandler(
					&me->ret,
					VS_K_filterFeatureNeg_LCAH,
					VS_m_JOINT )
	locate_class		"+VSfeature"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	locate_owner		"  LC_RIGID_COMP
				 | LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER
				 | LC_REF_OBJECTS"
	/*
	 * Accept locate by name or object.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID"
	filter			locate

		on EX_OBJID or
		   EX_DATA	do store_part( &me->ret )
					on RETURN_CODE = "VS_K_RESTART_CMD"
								state haveError
				do display_work_form( &me->ret )
					on RETURN_CODE != "VS_K_ACT_SUCCESS"
						do status "Cannot load form"
						do waitTimer( 4 )
								state terminate
				do fill_form( &me->ret )
					on RETURN_CODE = "VS_K_RESTART_CMD"
								state haveError
				do toggleCommand()
				state formActive

state formActive
	prompt		""
	filter		get_event
			on EX_FORM_FINISHED			state terminate
			on GR_UNKNOWN_TYPE.VS_K_LocStructElm	state start

state haveError
	status_key VS_E_ErrEncCmdRst
	on ELSE state start

at init	  do initCmd()
at delete do cleanUp()
/*----------------------------------------------------------------------------*/
