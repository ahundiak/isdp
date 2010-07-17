/*
	I/STRUCT
	"Review Operation History" command.
*/
command_string	VSC_M_VSRvOpHs,0,VSRvOpHs
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSophistCmd
product_name	"$STRUCT"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "msdef.h"
#include "dp.h"
#include "lcdef.h"
#include "VSmsg.h"
#include "vsdef.h"
#include "vscmddef.h"
#include "vsrvformdef.h"
#define	 VS_K_LocStructElm 260

state start
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
		on EX_OBJID or EX_DATA
			do store_operand( &me->ret, 0 )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			do operation( &me->ret )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			do toggleCommand()
			state formActive				

state formActive
	prompt_key	VS_P_SelRow
	filter		get_event
			on EX_FORM_FINISHED			state terminate
			on GR_UNKNOWN_TYPE.VS_K_LocStructElm	state start

at init   do message_key VS_M_VSRvOpHs
	  do createForm()
at wakeup do setStackedStatus( 0 )
at sleep  do setStackedStatus( 1 )
at delete do cleanUp()
/*----------------------------------------------------------------------------*/
