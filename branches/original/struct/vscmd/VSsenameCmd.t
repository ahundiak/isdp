/*
	I/STRUCT
	"Attach Logical Name To Face" command.
*/
command_string	VSC_M_VSAtLNmTFc,0,VSAtLNmTFc
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSsenameCmd
product_name	"$STRUCT"
form		"VSnmPrfFces.fm",1,0,"-1","-1"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "msdef.h"
#include "lcdef.h"
#include "VSmsg.h"
#include "vscmddef.h"

#define FIRST_COMPONENT	0
#define CURRENT_FACE	-1
#define FORM		0

state start
	execute			resetCmd()
	prompt_key		VS_P_IdPrflCv
	locate_class		"GRcompcurve"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	locate_owner		"  LC_RIGID_COMP 
				 | LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER"
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID"
	filter			locate_noauto
		on EX_OBJID or EX_DATA	
			do getCtrAndCmpsOfPrfl( &me->ret )
				on RETURN_CODE = "VS_K_RESTART_CMD"	state .

			do drwPrflOnForm( FIRST_COMPONENT )	state ModifyForm

state ModifyForm
	prompt_key		VS_P_SelName
	filter			VSget_event_with_dynamics

		on GR_UNKNOWN_TYPE.VS_K_DYN_MOUSE		state .

		on GR_UNKNOWN_TYPE.VS_K_CH_STATE		state AccRejName

		on EX_BACK_UP
			do disable_gadgets( &me->ret )
			do unhiliteProfile( &me->ret )
			do repaint_form( &me->ret )
			do rmLastLocObjs( 0 )			state start

state AccRej
	prompt_key		VS_P_AccRej
	filter			get_event

		on GR_UNKNOWN_TYPE.VS_K_CH_STATE		state ModifyForm

		on EX_BACK_UP
			do disable_gadgets( &me->ret )
			do repaint_form( &me->ret )
			do rmLastLocObjs( 0 )			state start

state AccRejName
	prompt_key		VS_P_AccSelOtherName
	filter			VSget_event_with_dynamics

		on GR_UNKNOWN_TYPE.VS_K_DYN_MOUSE	state .

		on GR_UNKNOWN_TYPE.VS_K_LOAD_ATTR	state ModifyForm

		on GR_UNKNOWN_TYPE.VS_K_CH_STATE	state AccRej

at init		do message_key		VS_M_VSAtLNmTFc
		do initCmd()
		do formOpByIndex( FORM, VS_FIf_WNEVENT_ON )
		do formOpByIndex( FORM, VS_FIf_BTEVENT_ON )
		do disable_gadgets( &me->ret )
at wakeup	do formOpByIndex( FORM, VS_FIf_DISPLAY )
		do set_dynamics_in_form( &me->ret, me->forms[FORM].form_ptr )
		do drwPrflOnForm( CURRENT_FACE )
at sleep	do formOpByIndex( FORM, VS_FIf_ERASE )
		do keyin_key( VS_I_EmptyMessage )
/*----------------------------------------------------------------------------*/
