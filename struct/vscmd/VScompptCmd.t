/*
	I/STRUCT
	"Compress Part" command.
*/
command_string	VSC_M_VSCmPr,0,VSCmPr
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VScompptCmd
product_name	"$STRUCT"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "msdef.h"
#include "lcdef.h"
#include "dp.h"
#include "VSmsg.h"
#include "vsdef.h"
#include "vscmddef.h"

state start
	execute			discard_all_input( &me->ret )
	prompt_key		VS_P_IdPart
	status_key		VS_W_CorruptFile
	/*
	 * Reject `frozen' and image elements.
	 */
	execute 		setupActionHandler(
					&me->ret,
				    	VS_K_filterFeatureNeg_LCAH,
				    	  VS_m_FRZ_generic
					| VS_m_IMG_generic )

	locate_class		"+VSfeature"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	locate_owner		"  LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER"
	/*
	 * Accept locate by name or object.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID | 
				 GRm_RJT_MOVEON"
	filter			locate
		on EX_RJT_MOVEON				 state terminate

		on EX_OBJID	do process_fence( &me->ret, VS_K_OPRND )
					on RETURN_CODE = "VS_K_RESTART_CMD"
						do handleError( me->ret ) 
									state .
					on RETURN_CODE = "VS_K_NO_FENCE"
									state .
				do operation( &me->ret )
					on RETURN_CODE != "VS_K_ACT_SUCCESS"
						do handleError( me->ret ) 
									state .
				state . 

		on EX_DATA
				do store_operand( &me->ret, 0 )
					on RETURN_CODE != "VS_K_ACT_SUCCESS"
						do handleError( me->ret )
									state .
				do operation( &me->ret )
					on RETURN_CODE != "VS_K_ACT_SUCCESS"
						do handleError( me->ret ) 
									state .
				state . 

at init do message_key VS_M_VSCmPr
/*----------------------------------------------------------------------------*/
