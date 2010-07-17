/*
	I/STRUCT
	"Create Profile" command.
*/
command_string	VSC_M_VSCrPr,0,VSCrPr
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VScrsectCmd
product_name	"$STRUCT"
form		"VScrProfile.fm",1,0,"-1","-1"
start_state	start

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "msdef.h"
#include "lcdef.h"
#include "VSmsg.h"
#include "vscmddef.h"
#define FORM	0

state main
	prompt_key		VS_P_IdPrflCvs
	accept_key		VS_P_AccWnxPrfl
	locate_class		"GRcompcurve"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	/*
	 * Rigid component will be not located by a fence without the
	 * flag LC_RIGID_COMP_PRISM.
	 */
	locate_owner		"  LC_RIGID_COMP
				 | LC_RIGID_COMP_PRISM
				 | LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER"
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID"
	filter			locate
		on EX_OBJID
			do process_fence( &me->ret )
				on RETURN_CODE = "VS_K_RESTART_CMD"	
							state .
			do getCsAndExps( &me->ret )
				on RETURN_CODE = "VS_K_RESTART_CMD"	
							state .

			do refresh_form( &me->ret )

			do dspProfile( 0 )		state NamingCurve

		on EX_DATA
			do storeProfiles( &me->ret )	
				on RETURN_CODE = "VS_K_RESTART_CMD"	
					do chain_locate( &me->ret )
							state .

			do getCsAndExps( &me->ret )
				on RETURN_CODE = "VS_K_RESTART_CMD"	
							state .

			do refresh_form( &me->ret )

			do dspProfile( 0 )		state NamingCurve

state NamingCurve
	execute			unhiliteCrvs( &me->ret )
	prompt_key		VS_P_SelPrflName
	filter			get_event

		on GR_UNKNOWN_TYPE.VS_K_CH_STATE	state AccRejName

		on EX_BACK_UP				state start

state NamingPara
	prompt_key		VS_P_SelAliasName
	filter			get_event

		on GR_UNKNOWN_TYPE.VS_K_CH_STATE	state AccRejName

		on RESET
			do dspNextPmName( &me->ret )
				on RETURN_CODE = "VS_K_RESTART_CMD"
							state AccRej
			state .

		on EX_BACK_UP				state start

state AccRej
	prompt_key		VS_P_AccRej
	filter			get_event

		on EX_BACK_UP				state start

state AccRejName
	prompt_key		VS_P_AccSelOtherName
	filter			get_event

		on GR_UNKNOWN_TYPE.VS_K_LOAD_ATTR	state NamingCurve

		on GR_UNKNOWN_TYPE.VS_K_CH_STATE	state NamingPara

		on GR_UNKNOWN_TYPE.VS_K_END_STATE	state AccRej

state start	
	execute			resetCmd( &me->ret )
		on ELSE
			state	main

at init		do message_key VS_M_VSCrPr
		do initCmd()
		do formOpByIndex( FORM, VS_FIf_WNEVENT_ON )
at wakeup	do formOpByIndex( FORM, VS_FIf_DISPLAY )
at sleep	do formOpByIndex( FORM, VS_FIf_ERASE )
/*----------------------------------------------------------------------------*/
