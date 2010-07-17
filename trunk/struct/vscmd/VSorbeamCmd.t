/*
	I/STRUCT
	"Define Beam Orientation" command.
	"Display Structural Element Orientation" command.
*/
command_string	VSC_M_VSDfBmOr,0,VSDfBmOr
synonym		VSC_M_VSDsStElOr,1,VSDsStElOr
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSorbeamCmd
product_name	"$STRUCT"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "lcdef.h"
#include "vsplatedef.h"
#include "VSmsg.h"
#include "vsdef.h"
#include "vscmddef.h"

state start
	on CMD_TYPE = 0	
		do message_key		VS_M_VSDfBmOr
		do prompt_key		VS_P_IdBeam
		do construct_class	"VSornBeam"
		/*
		 * Reject `frozen' or image features: they cannot change their
		 * orientation.
		 */
		do setupActionHandler(	&me->ret,
					VS_K_filterFeatureNeg_LCAH,
					VS_m_FRZ_generic | VS_m_IMG_generic )
		do locate_class		"+VSbeam"
		do locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
		do locate_owner		"  LC_RIGID_OWNER
				 	 | LC_FLEX_COMP
				 	 | LC_FLEX_OWNER
				 	 | LC_REF_OBJECTS"
		state LocStructElm

	on CMD_TYPE = 1
		do message_key		VS_M_VSDsStElOr
		do prompt_key		VS_P_IdStructElmt
		do locate_class		"+VSfeature"
		do locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
		do locate_owner		"  LC_RIGID_COMP
				 	 | LC_RIGID_OWNER
				 	 | LC_FLEX_COMP
				 	 | LC_FLEX_OWNER
				 	 | LC_REF_OBJECTS"
		/*
		 * Reject `frozen' features: they cannot show their orientation.
		 * Note: images can show theirs.
		 */
		do setupActionHandler(	&me->ret,
					VS_K_filterFeatureNeg_LCAH,
					VS_m_FRZ_generic )
		state LocStructElm

state LocStructElm
	accept_key	VS_P_AccRej
	/*
	 * Accept locate by name or object.
	 */
	mask		"GRm_DATA | GRm_STRING | GRm_OBJID"
	filter		locate

		on EX_DATA or EX_OBJID	do store_operand( &me->ret, 0 )
			on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			do operation( &me->ret )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			do discard_all_input( &me->ret )
		state LocStructElm

/*----------------------------------------------------------------------------*/
