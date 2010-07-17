/* $Id: VSplnjntCmd.t,v 1.1.1.1 2001/01/04 21:10:26 cvs Exp $  */
 
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vscmd/VSplnjntCmd.t
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSplnjntCmd.t,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:26  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.3  1998/01/06  09:15:52  pinnacle
# Replaced: vscmd/VSplnjntCmd.t for:  by svkadamb for struct
#
# Revision 1.1  1997/11/14  12:17:52  pinnacle
# Created: vscmd/VSplnjntCmd.t by svkadamb for struct
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *                      suresh          modification
 ***************************************************************************/

/*
	I/STRUCT
	"Place New Joint" command.
*/
command_string	VSC_M_VSPlNJn,0,VSPlNJn
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSplnjntCmd 
product_name	"$STRUCT"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "lcdef.h"
#include "vsplatedef.h"
#include "VSmsg.h"
#include "vsdef.h"
#include "vscmddef.h"

/*
 * NOTE: in this command, the 1st and 2nd elements have a symmetrical role, but
 * we store the 1st as the operand and the second as the operator for commodity.
 */

state start
	execute			setMatchKey( "joint" )
	/*
	 * Reject joints in all locates (they are VSfeatures too).
	 */
	execute 		setupActionHandler(
					&me->ret,
					VS_K_filterFeatureNeg_LCAH,
					VS_m_JOINT )
	on ELSE state get1stElmt

state get1stElmt
	prompt			"Identify First Part( Set )"
	accept_key		VS_P_AccRej
	locate_class		"+VSfeature"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	/*
	 * Rigid component will be not located by a fence without the
         * flag LC_RIGID_COMP_PRISM.
	 * Elements in reference files accepted.
	 */
	locate_owner		"  LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_RIGID_COMP_PRISM
				 | LC_FLEX_OWNER
				 | LC_RIGID_COMP
				 | LC_REF_OBJECTS"
	/*
	 * Accept locate by name or object.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID"
	filter			locate

		on EX_DATA
			do store_first_feature( &me->ret )
                                on RETURN_CODE != "VS_K_ACT_SUCCESS"
                                        do handleError( me->ret )
						state .
                                on RETURN_CODE = "VS_K_NO_OBJ"
                                        state  get1stElmt
                                state get2ndElmt
		on EX_OBJID
			do process_set( &me->ret, 1 )
				on RETURN_CODE = "VS_K_RESTART_CMD"
					state haveError
				on RETURN_CODE = "VS_K_NO_FENCE"
                                        do status_key VS_W_NoObjLoc
                                                state .
				state get2ndElmt

state get2ndElmt
	prompt                  "Identify Second Part ( Set )/Move-on"
	accept_key		VS_P_AccRej
	locate_class            "+VSfeature"
	locate_properties       "LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	/*
	 * Rigid component will be not located by a fence without the
         * flag LC_RIGID_COMP_PRISM.
	 * Elements in reference files accepted.
	 */
	locate_owner		"  LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_RIGID_COMP_PRISM
				 | LC_FLEX_OWNER
				 | LC_RIGID_COMP
				 | LC_REF_OBJECTS"

	/*
	 * Accept locate by name or object.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID 
				| GRm_RJT_MOVEON"
	filter			locate
		on EX_DATA 
			do store_second_feature( &me->ret )
                                on RETURN_CODE != "VS_K_ACT_SUCCESS"
                                        do handleError( me->ret )
						state .
                                on RETURN_CODE = "VS_K_NO_OBJ"
                                        state  get2ndElmt
                                state formActive
		on EX_OBJID
			do process_set( &me->ret, 2 )
				on RETURN_CODE = "VS_K_RESTART_CMD"
					state haveError
				on RETURN_CODE = "VS_K_NO_FENCE"
                                        do status_key VS_W_NoObjLoc
                                                state .
				state formActive
		on EX_BACK_UP
                        /*
                         * Remove the first set of features selected for
                         * joining with the secong set
                         */
                        do rmLocSet( &me->ret, 1 )    state -
 
                on EX_RJT_MOVEON
                        do validateFirstSet( &me->ret )
                                on RETURN_CODE != "VS_K_ACT_SUCCESS"
                                        do handleError( me->ret ) 
						state .
                                state formActive

state formActive
        execute         createForm()
	on RETURN_CODE != "VS_K_ACT_SUCCESS"
		do handleError( me->ret ) state haveError

	on ELSE		state formDisp

state formDisp
        prompt_key      VS_P_ModForm
        construct_class "VSsrcJoint"
        filter          get_event

		on GR_UNKNOWN_TYPE.VS_K_SAME_STATE	
			do status 	" "		state formDisp
		on GR_UNKNOWN_TYPE.VS_K_CH_STATE	state getGeometry
                /*
                 * Remove all the located objects
		 */
                on EX_BACK_UP  do cleanUp() 
			state start
		on ELSE	state terminate

state getGeometry
	prompt                  "Identify Joint Geometry"
	accept_key		VS_P_AccRej
	execute                 setupActionHandler(
						&me->ret,
						VS_K_rejectSubClass_LCAH,
						"GRpoint" )

	locate_class            "GRcurve"
	locate_properties       "LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	/*
	 * Elements in reference files accepted.
	 */
	locate_owner		"  LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER
				 | LC_RIGID_COMP
				 | LC_REF_OBJECTS"

	/*
	 * Accept locate by name or object.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID 
				| GRm_RJT_MOVEON"
	filter			locate
		on EX_DATA or EX_OBJID
			do store_geometry( &me->ret )
                                on RETURN_CODE != "VS_K_ACT_SUCCESS"
                                        do handleError( me->ret ) 
						state .
			state formDisp

state haveError
	status_key VS_E_ErrEncCmdRst
	on ELSE	do cleanUp()	state start

at init		do message_key VS_M_VSPlNJn
at wakeup	do checkPWD()
/*----------------------------------------------------------------------------*/
