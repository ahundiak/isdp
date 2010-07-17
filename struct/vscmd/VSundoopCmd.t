/* $Id: VSundoopCmd.t,v 1.1.1.1 2001/01/04 21:10:28 cvs Exp $  */
 
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vscmd/VSundoopCmd.t
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSundoopCmd.t,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:28  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.3  1998/03/11  13:34:04  pinnacle
# Replaced: vscmd/VSundoopCmd.t for:  by rchennup for struct
#
# Revision 1.2  1997/10/06  06:58:58  pinnacle
# Replaced: vscmd/VSundoopCmd.t for:  by svkadamb for struct
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *                      suresh          modification
 ***************************************************************************/
/*
	I/STRUCT
	"Remove Operator" command.
*/

command_string	VSC_M_VSRmOp,0,VSRmOp
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSundoopCmd
product_name	"$STRUCT"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "OMtypes.h"
#include "msdef.h"
#include "lcdef.h"
#include "VSmsg.h"
#include "dp.h"
#include "vscmddef.h"

state start
	execute 		setupActionHandler( &me->ret, VS_K_RESET_LCAH,0)
	execute			setMinMaxOperators( 1, OM_K_MAXINT )
	message_key		VS_M_VSRmOp
	prompt_key		VS_P_IdResPart
	unhighlight_mode 	GRhhd
	locate_display		"ELEM_HILIGHT"
	locate_class		"+VSmodFeature,VSsubFeature"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	/*
	 * Features rigidly owned not accepted (LC_RIGID_COMP).
	 */
	locate_owner		"  LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER"

	/*
	 * Accept locate by name or object.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID"
	filter			locate
		on EX_OBJID or EX_DATA
			do store_operand( &me->ret, 0 )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			do hiliteOperators( &me->ret )
			do ms_on_off	MS_OFF			state getOptype

state getOptype
	ms_on_off		MS_ON
	prompt_key		VS_P_IdOprMvOnforAll
	/*
	 * Filter out objects which are not operators of result located in
	 * previous state.
	 */
	execute 		setupActionHandler(
					&me->ret,
					VS_K_actionHandlerInCmd_LCAH,
					my_id )
	unhighlight_mode 	GRhd
	locate_display		"ELEM_HILIGHT | LC_ERASE_LOC_ELEMENT"
	locate_class		"+GRvg"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	locate_owner		"  LC_RIGID_COMP
				 | LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER
				 | LC_REF_OBJECTS"
	/*
	 * Accept locate by name.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID | 
				 GRm_RJT_MOVEON | GRm_BACK_UP "
	filter			locate

	on EX_DATA or EX_OBJID		
			do store_operator( &me->ret, 1 )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state getOperator
			do ms_on_off	MS_OFF
			do prompt_key	VS_P_IdOperatorMvOn	  state getOperator


	on EX_RJT_MOVEON
		do getAllOperators( &me->ret )
			on RETURN_CODE != "VS_K_ACT_SUCCESS"
				do handleError( me->ret ) state start
		do operation( &me->ret )
			on RETURN_CODE != "VS_K_ACT_SUCCESS"
				do handleError( me->ret ) state start
		do discard_all_input( &me->ret )	  state start

state getOperator
	ms_on_off		MS_ON
	accept_key		VS_P_AccWNextOperator
	/*
	 * Filter out objects which are not operators of result located in
	 * previous state.
	 */
	execute 		setupActionHandler(
					&me->ret,
					VS_K_actionHandlerInCmd_LCAH,
					my_id )
	unhighlight_mode 	GRhd
	locate_display		"ELEM_HILIGHT | LC_ERASE_LOC_ELEMENT"
	locate_class		"+GRvg"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	locate_owner		"  LC_RIGID_COMP
				 | LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER
				 | LC_REF_OBJECTS"
	/*
	 * Accept locate by name.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID | 
				 GRm_RJT_MOVEON | GRm_BACK_UP "
	filter			locate

		on EX_DATA
			do store_operator( &me->ret, 1 )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			do ms_on_off	MS_OFF
			do prompt_key	VS_P_IdOperatorMvOn	  state .

		on EX_BACK_UP
			do discard_operators( &me->ret )	  state start

		on EX_RJT_MOVEON
			do operation( &me->ret )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state start
			do discard_all_input( &me->ret )	  state start

at wakeup do hiliteResult( &me->ret )
	  do hiliteOperators( &me->ret )
/*----------------------------------------------------------------------------*/
