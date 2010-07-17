/* $Id: VSntplatCmd.t,v 1.1.1.1 2001/01/04 21:10:26 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vscmd/VSntplatCmd.t
 *
 * Description: State table for "Impose Cutout On Plate".
 *		Creates struct/config/commands/VSImCtOnPl.
 *
 * Dependencies: Methods are in file, vscmdsup/VSpartopCmdi.I.
 *
 * Revision History:
 *      $Log: VSntplatCmd.t,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:26  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1998/08/14  15:33:24  pinnacle
# TR_179801428: Changed state main to accept group of inputs
#
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      08/13/98  EJM     TR#179801428  Support group input
 *			  Added code under EX_OBJID in state "main"
 ***************************************************************************/

command_string	VSC_M_VSImCtOnPl,0,VSImCtOnPl
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
	 * Set min. and max. numbers of notching solids that command may accept.
	 */
	execute			setMinMaxOperators( 1, VS_K_bpMAX_NOTCHES )
	on ELSE state main

state main
	prompt_key		VS_P_IdPlOrGr
	accept_key		VS_P_AccWNtch
	construct_class		"VSbooPlate"
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
		on EX_DATA
			/*
			 * Store plate, put accept point onto event queue (hence
			 * the argument "1").
			 */
			do store_operand( &me->ret, 1 )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) 
								state .
			do ms_on_off  MS_OFF
			do prompt_key VS_P_IdNtch		state getSolids

                on EX_OBJID
			do setFlags( VS_m_POallOprtsOn1Opnd )
                        do process_fence( &me->ret, VS_K_OPRND )
                                on RETURN_CODE != "VS_K_ACT_SUCCESS"
                                        do handleError( me->ret ) state .
                        do ms_on_off  MS_OFF
                        do prompt_key VS_P_IdNtch               state getSolids



state getSolids
	ms_on_off		MS_ON
	accept_key		VS_P_AccWNxNtch
	locate_class		"+EMSsolid,EMSsubbs,GRcurve"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	execute			setupActionHandler(	&me->ret,
						VS_K_isAClosedPlanarCurve_LCAH,
						0 )
	execute			setupAHrejectSts( VS_W_CvNtClsdOrNtPlnr )
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
			 * Store solid, put accept point onto event queue (hence
			 * the argument "1").
			 */
			do store_operator( &me->ret, 1 )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			do ms_on_off MS_OFF
			do prompt_key VS_P_IdNtchMvOn		  state .

		on EX_OBJID
			/*
			 * It may be either a graphic set or a solid.
			 */
			do process_fence( &me->ret, VS_K_OPRTR )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) 
								  state .
			do ms_on_off MS_OFF
			do prompt_key VS_P_IdNtchMvOn		  state .

		on EX_RJT_MOVEON
			do operation( &me->ret )
				on RETURN_CODE  = "VS_K_NEED_OP"  state .
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			/*
			 * Flush input, restart.
			 */
			do discard_all_input( &me->ret )  	  state main

		on EX_BACK_UP
			do discard_operators( &me->ret )  	  state -


at init do message_key VS_M_VSImCtOnPl
/*----------------------------------------------------------------------------*/
