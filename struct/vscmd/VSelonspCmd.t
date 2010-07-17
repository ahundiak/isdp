/*
	I/STRUCT
	
	Group generators :
		- "Select Beams On Surface" 
		- "Select Stiffeners On Plate"
*/
command_string	VSC_M_VSSlBmOnSr,0,VSSlBmOnSr
synonym		VSC_M_VSSlStOnPl,1,VSSlStOnPl
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSelonspCmd
product_name	"$STRUCT"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "msdef.h"
#include "lcdef.h"
#include "VSmsg.h"
#include "vscmddef.h"

state start

	on CMD_TYPE = 0	do 	message_key	VS_M_VSSlBmOnSr
			do	prompt_key	VS_P_IdSuppSrfs
			do	setupActionHandler(
						&me->ret,
						VS_K_isSupportOfBeam_LCAH,
						0 )
			do	setupAHrejectSts( VS_I_NoBmOnSr )
			do	locate_class	"EMSsubbs"
					state LocSupport
					
	on CMD_TYPE = 1 do 	message_key	VS_M_VSSlStOnPl
			do 	prompt_key	VS_P_IdPlOrGr
			do	setupActionHandler(
						&me->ret,
						VS_K_isSupportOfStiffener_LCAH,
						0 )
			do	setupAHrejectSts( VS_I_NoStfOnPl )
			do      locate_class	"+VSfeature"
					state LocSupport
					

state LocSupport
	accept_key		VS_P_AccRej
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
			  	 GRm_RJT_MOVEON"
	filter			locate

		on EX_RJT_MOVEON				state terminate

		on EX_DATA	do store_operand( &me->ret, 0 )
					on RETURN_CODE != "VS_K_ACT_SUCCESS"
						do handleError( me->ret ) 
								state .
				do GetAndPutElemsOnGS( &me->ret )
					on RETURN_CODE = "VS_K_RESTART_CMD"
						state haveError
				state terminate	

		on EX_OBJID	do process_fence( &me->ret, VS_K_OPRND )
					on RETURN_CODE = "VS_K_RESTART_CMD"
						state haveError
					on RETURN_CODE = "VS_K_NO_FENCE"
						do status_key VS_W_NoObjLoc
						do waitTimer( 4 )
						state terminate
				do GetAndPutElemsOnGS( &me->ret )
					on RETURN_CODE = "VS_K_RESTART_CMD"
						state haveError
					state terminate


state haveError
	status_key VS_E_ErrEncCmdTrm
	execute waitTimer( 4 )
	on ELSE state terminate
				
/*----------------------------------------------------------------------------*/
