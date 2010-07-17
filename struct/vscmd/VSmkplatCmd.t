/*
	I/STRUCT
	"Impose Markings on Plate" command.
*/
command_string	VSC_M_VSImMrOnPl,0,VSImMrOnPl
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSpartopCmd
product_name	"$STRUCT"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "lcdef.h"
#include "vsplatedef.h"
#include "VSmsg.h"
#include "vsdef.h"
#include "vscmddef.h"

state start
	/*
	 * Set maximum number of boundary curves which command may accept.
	 */
	execute			setMinMaxOperators( 1, VS_K_MAX_BOUNDARIES )
	on ELSE state main

state main
	prompt_key		VS_P_IdPlate
	accept_key		VS_P_AccWMk
	construct_class		"VSmrkPlate"
	/*
	 * Reject `frozen' and image plates.
	 */
	execute 		setupActionHandler(
					&me->ret,
					VS_K_filterFeatureNeg_LCAH,
					  VS_m_FRZ_generic
					| VS_m_IMG_generic )
	locate_class		"+VSplate"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	/*
	 * Plates in reference files accepted.
	 * Plates rigidly owned not accepted (LC_RIGID_COMP).
	 */
	locate_owner		"  LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER
				 | LC_REF_OBJECTS"

	/*
	 * Accept locate by name or object.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID"
	filter			locate_noauto
		on EX_DATA or EX_OBJID
			/*
			 * Store plate, put accept point onto event queue (hence
			 * the argument "1").
			 */
			do store_operand( &me->ret, 1 )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) 
								state .
			do ms_on_off  MS_OFF
			do prompt_key VS_P_IdMk			state getCurves

state getCurves
	ms_on_off		MS_ON
	accept_key		VS_P_AccWNxMk
	/*
	 * Accept curves but not points.
	 */
	execute 		setupActionHandler(
					&me->ret,
					VS_K_rejectSubClass_LCAH,
					"GRpoint" )
	locate_class		"+GRcurve"
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
	 * Accept locate by name or object.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID |
                                 GRm_RJT_MOVEON | GRm_BACK_UP"

	filter			locate_noauto
		on EX_DATA
			/*
			 * Store curve, put accept point onto event queue (hence
			 * the argument "1").
			 */
			do store_operator( &me->ret, 1 )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) 	
								state .
			do ms_on_off MS_OFF
			do prompt_key VS_P_IdMkMvOn	  	state .

		on EX_OBJID
			/*
			 * It may be either a graphic set or a curve.
			 */
			do process_fence( &me->ret, VS_K_OPRTR )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) 
								state .
			do ms_on_off MS_OFF
			do prompt_key VS_P_IdMkMvOn	  	state .

		on EX_RJT_MOVEON
			do operation( &me->ret )
				on RETURN_CODE =  "VS_K_NEED_OP"  
								state .
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) 
								state main
			/*
			 * Flush input, restart.
			 */
			do discard_all_input( &me->ret )	state main

		on EX_BACK_UP
			do discard_operators( &me->ret )	state -

at init do message_key VS_M_VSImMrOnPl
/*----------------------------------------------------------------------------*/
