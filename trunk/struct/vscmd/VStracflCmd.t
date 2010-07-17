/*
	I/STRUCT
	"Transfer Element To Active File" command.
*/
command_string	VSC_M_VSTrElAcFl,0,VSTrElAcFl
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VStracflCmd
product_name	"$STRUCT"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "lcdef.h"
#include "VSmsg.h"
#include "vsdef.h"
#include "vscmddef.h"

state start
	execute verifyLogin( &me->ret )
	on SUCCESS state realStart

	status_key VS_W_NoDBConnection
	execute waitTimer( 4 )
	on ELSE	   state terminate

state realStart
	prompt_key	VS_P_IdElement
	accept_key	VS_P_AccWNxElement
	execute 	setupActionHandler(	&me->ret,
						VS_K_actionHandlerInCmd_LCAH,
						my_id )
	locate_class	"+VSfeature,ACconst"
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
	on ELSE state main

state main
	/*
	 * Accept locate by name or object.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID | GRm_RJT_MOVEON"
	ms_on_off		MS_ON
	filter			locate_noauto

		on EX_DATA
			do store_operator( &me->ret, 1 )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			do ms_on_off MS_OFF

			do prompt_key VS_P_IdElementMvOn

			state .

		on EX_OBJID
			do process_fence( &me->ret, VS_K_OPRTR )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .

			do operation( &me->ret )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state realStart
			do discard_all_input( &me->ret )
			state realStart

		on EX_RJT_MOVEON
			do operation( &me->ret )
				on RETURN_CODE = "VS_K_NEED_OP" state .
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state realStart
			/*
			 * Flush input, restart.
			 */
			do discard_all_input( &me->ret )	  state realStart

at init		do message_key VS_M_VSTrElAcFl
		do setMinMaxOperators( 1, 10000 )
		do initRDBdata()
at wakeup	do verifyLogin( &me->ret )
/*----------------------------------------------------------------------------*/
