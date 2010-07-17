/*
	I/STRUCT
	"Expand Shell Curve" command.
*/
command_string	VSC_M_VSExpShCv,0,VSExpShCv
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSexshcvCmd
product_name	"$STRUCT"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "OMtypes.h"
#include "lcdef.h"
#include "VSmsg.h"
#include "vscmddef.h"

state start
	execute 	setFlags( VS_m_POconstWithSymb | VS_m_POnoOperandRedisp)
	execute 		setMinMaxOperators( 1, OM_K_MAXINT )
	prompt_key		VS_P_IdShellExp
	accept_key		VS_P_AccWClCv
	locate_class		"VSshellExp"
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
	filter			locate_noauto

		on EX_DATA
		or EX_OBJID	do store_operand( &me->ret, 1 )
					on RETURN_CODE != "VS_K_ACT_SUCCESS"
						do handleError( me->ret )
								  state .
				do ms_on_off  MS_OFF
				do prompt_key VS_P_IdClCv	  state locCurve


state locCurve
	ms_on_off		MS_ON
	accept_key		VS_P_AccWNxClCv
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
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID |
				 GRm_RJT_MOVEON | GRm_BACK_UP"
	filter			locate_noauto

		on EX_DATA
			do store_operator( &me->ret, 1 )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			do ms_on_off MS_OFF
			do prompt_key VS_P_IdClCvMvOn		  state .

		on EX_OBJID
			do process_fence( &me->ret, VS_K_OPRTR )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			do ms_on_off MS_OFF
			do prompt_key VS_P_IdClCvMvOn		  state .

		on EX_RJT_MOVEON
			do operation( &me->ret )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state start
			do discard_all_input( &me->ret )	  state start

		on EX_BACK_UP
			do discard_operators( &me->ret )	  state start

at init do message_key VS_M_VSExpShCv
/*----------------------------------------------------------------------------*/
