/* $Id: VRPInsert.t,v 1.1.1.1 2001/01/04 21:12:43 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrco/VRPInsert.t
 *
 * Description:
 *	insert Valve state language file.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRPInsert.t,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:43  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.2  1997/02/24  22:06:26  pinnacle
# Replaced: vrco/VRPInsert.t for:  by hverstee for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.4  1996/05/17  22:00:38  pinnacle
# Replaced: vrco/VRPInsert.t for:  by hverstee for route240
#
# Revision 1.3  1995/12/08  21:18:28  pinnacle
# Replaced: vrco/VRPInsert.t for:  by r240_int for route240
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	Creation : 	O.N (isdc Paris)		18-12-1990
 	Modified:	Karine  (isdc Paris)	12-02-1992 
 *
 *	12/06/95	tlb	Remove VRcmd.h
 *				VR_E_NotPipingComponent not defined - 
 *					replace by VR_S_NotPipingComp
 *
 *************************************************************************/
command_string	VRC_M_InsertPipingValve,     VR_VALVE_INSERTION,      VRInPpVl
synonym		VRC_M_InsertPipingReducer,   VR_REDUCER_INSERTION,    VRInPpRd
synonym		VRC_M_InsertPipingMisc,      VR_MISC_INSERTION,       VRInPpMs
synonym		VRC_M_InsertPipingFlange,    VR_FLANGE_INSERTION,     VRInPpFl
synonym		VRC_M_InsertPipingConnector, VR_CONNECTOR_INSERTION,  VRInPpCn
synonym		VRC_M_InsertPipingInstrument,VR_INSTRUMENT_INSERTION, VRInPpIn
synonym		VRC_M_InsertPipingSpecialty, VR_SPECIALTY_INSERTION,  VRInPpSp
synonym		VRC_M_InsertPipeEnds,        VR_PIPEENDS_INSERTION,   VRInPpEn
class		VRPInsert
product_name	"$ROUTE"
command_table	"route.cmd"
options         "isTC"
start_state	start

status_display "VRPpCmDsPara","-1","-1"
form "VRPipSkParams" , 0, 0,"-1", "-1"         /*   used from sketch   */
form "VRUserParam", 1, 0,"-1", "-1"

state_table

#include "VRcompdef.h"
#include "VRmsg.h"
#include "ECmsg.h"
#include "VRco.h"
#include "VRsketchdef.h"

#define	DISPLAYED		2000

state *
on  EX_DATA.GRst_PERPEND_FROM                        state HaveError
on  EX_DATA.GRst_ANGLE_FROM                          state HaveError
on  EX_DATA.GRst_TANGENT_FROM                        state HaveError
on  EX_DATA.GRst_PERPEND_TO                          state HaveError
on  EX_DATA.GRst_ANGLE_TO                            state HaveError

on TERMINATE                         state terminate

on GR_UNKNOWN_TYPE.TERMINATE or
   GR_UNKNOWN_TYPE.CLEAR_STACK       state terminate

/* ======================================================================== */

state start

	on ELSE
		do VRDisplayMessage (&me->ret)
		do VRDefaultPocketMenu (&me->ret)
		do VRInitInstance(&me->ret)
		state GET_OBJ

/* ======================================================================== */

state GET_OBJ

	prompt_key		VR_P_IdComp
	status_key		EMS_I_InvkStatusFrm
	accept_key		VR_P_EnterInsertReject
	status			""
	dynamics		off
	locate_eligible		"VRPComp, VRPCComp, VRPNozz"
   	locate_owner         	"LC_RIGID_COMP"
	filter			locate

	on EX_BACK_UP or EX_RJT_MOVEON
		state start

 	on EX_DATA
		do VRGetLocatedObject ( &me->ret )
			on RETURN_CODE = VRNOT_OK
			state .
		do VRLoadForm ( &me->ret )
		state GET_CODE

	on ERROR
		do status_key VR_S_NotPipingComp 
		state HaveError	

	on EX_FORM_FINISHED
		state LOC_CMP

/* ======================================================================== */

state HaveFlow


	prompt_key		VR_P_DefineOrientationReverse
	dynamics		DYNTEE
	filter			get_event

	on EX_DATA
		state HaveOrient

        on EX_RJT_MOVEON
		do VRReverseComponent(&me->ret)
		state .

	on EX_BACK_UP
		do VRUnLockId( &me->ret )
		state GET_CODE

	on EX_FORM_FINISHED
		state .

	on ELSE
		state -

/* ======================================================================== */

state HaveOrient

	prompt_key		VR_P_GiveDataOrKeyinToOrientCmp
	dynamics	 	DYNTEE
	filter			get_event

	on EX_DATA
		do VRComputeCmpAngle(&me->ret)
		do VRRotateComponent (&me->ret)
		state PL_CMP

	on EX_BACK_UP
		do VRUnLockId( &me->ret )
		state -

	on DISTANCE
		do VROrientByAngle (&me->ret)
			on RETURN_CODE = VRNOT_OK
			do VRRotateComponent (&me->ret)
			state PL_CMP
		do VRRotateComponent (&me->ret)
		state .

	on EX_RJT_MOVEON
		do VRRotateQuadrant ( &me->ret )
		state .

	on EX_FORM_FINISHED
		state .

/* ======================================================================== */

state GET_CODE

	prompt_key		VR_P_EnterAABBCCcode
	dynamics		off
	filter			wfi

	execute		VRChangeActivePocketMenu (&me->ret)

	on EX_BACK_UP
		do VRRetrieveLocatedContext (&me->ret)
		do VRDefaultPocketMenu (&me->ret)
		do VRUnLockId( &me->ret )
		state GET_OBJ

	on EX_RESET or EX_RJT_MOVEON
		state .

        on EX_FORM_FINISHED
                do VRCopyReturnCode (&me->ret)
                        on RETURN_CODE  = VRLOC_CMP
                        do VRDefaultPocketMenu (&me->ret)
                        state LOC_CMP

                        on  RETURN_CODE = EX_FORM_ERASE
                        state .
                state EVAL

	on EX_CHAR or EX_STRING
		do VRGetAABBCCCode (&me->ret)
			on RETURN_CODE = MSFAIL
			do status_key  VR_S_InvalidAABBCCcode
			state .
		do VRLoadForm(&me->ret)
		do VRSetIdManData( &me->ret )
		do VRIsDisplayed( me->status_display_form_ptr )
			on DISPLAYED
			do VRGetOptionCode (&me->ret, 1 )
			state .
                do VRSKF_start (&me->ret)
                        on RETURN_CODE = VRSKF_DOIT
                        state FORMIN
		do VRIsReducerRequired (&me->ret)
			on RETURN_CODE = VRREDUCER
			do VRDefaultPocketMenu (&me->ret)
			state GET_DIAM
		state EVAL

/* ======================================================================== */

state FORMIN

      prompt        "Change Parameters"
      status       ""
      dynamics     off
      filter       wfi

      on EX_FORM_FINISHED
	do VRIsReducerRequired (&me->ret)
		on RETURN_CODE = VRREDUCER
		do VRDefaultPocketMenu (&me->ret)
		state GET_DIAM
	state EVAL

      on ELSE
        state .

/* ======================================================================== */

state MISS

       prompt_key   VR_P_ChgPar
       status       ""
       dynamics     off
       filter       wfi

       on EX_FORM_FINISHED      state EVAL

       on ELSE
          state GET_CODE

/* ======================================================================== */

state EVAL

	prompt    ""
	status	  ""
	dynamics  off

	on ELSE
		do VREvaluateComp(&me->ret)
			on RETURN_CODE = VR_ADDED_PARAM
	                do VRUpdateForm (&me->ret)
                        state MISS

			on RETURN_CODE = VR_NOT_VALID
			do VRRetrieveLocatedContext (&me->ret)
			state -
		do VRGetReturnCode(&me->ret)
			on RETURN_CODE = IS_ENDLINE_COMP
			do VRGetCompMatrix(&me->ret)
			do VRRotateComponent(&me->ret)
			state PL_CMP

			on RETURN_CODE = IS_OLET
			do VRGetCompMatrix(&me->ret)
			do VRRotateComponent(&me->ret)
			state HaveOrient

			on RETURN_CODE = VRNOT_OK
			do VRRetrieveLocatedContext (&me->ret)
			state GET_CODE
		do VRGetCompMatrix(&me->ret)
		do VRRotateComponent(&me->ret)
		state HaveFlow

/* ======================================================================== */

state PL_CMP

	prompt    ""
	status	  ""
	dynamics  off

	on ELSE
		do VRInsertComponent (&me->ret)
			on RETURN_CODE = VRNOT_OK	
			do VRChangeActivePocketMenu (&me->ret)
			state GET_CODE
		state start

/* ======================================================================== */

state LOC_CMP

	message_key		VR_M_CPDParamComp
	prompt_key		VR_P_IdComp
	accept_key		VR_P_AccRejectComponent
	dynamics		off
	locate_eligible		"VRPComp"
   	locate_owner         	"LC_RIGID_COMP | LC_REF_OBJECTS | LC_NO_REF_HEADER"
	dynamics		off
	filter			locate

	on EX_BACK_UP
		do VRChangeActivePocketMenu (&me->ret)
		state -

	on EX_DATA
		do VRCopyComponentAttr (&me->ret)
		do VRChangeActivePocketMenu (&me->ret)
		state -

	on ERROR
		state HaveError

	on EX_FORM_FINISHED
		do VRCopyReturnCode (&me->ret)
			on  RETURN_CODE = EX_FORM_ERASE
			do VRChangeActivePocketMenu (&me->ret)
			state GET_CODE
		state .

	on  EX_RJT_MOVEON or EX_RESET
		do VRChangeActivePocketMenu (&me->ret)
		state -	

/* ======================================================================== */

state HaveError
   
	status_key		VR_S_InvDataType

	on ELSE
		state -

/* ======================================================================== */

state GET_DIAM

	prompt_key		VR_P_EnterDiamValue
	dynamics		off
	filter			wfi

	on STATUS_DISP
		do VRChangeActivePocketMenu (&me->ret)
		do status_disp ()
		state . 

	on EX_RESET or EX_RJT_MOVEON
		state .

	on ERROR
		state HaveError

	on EX_BACK_UP
		do VRRetrieveLocatedContext (&me->ret)
		state -

	on  EX_STRING or EX_CHAR 
		do VRGetOtherValues (&me->ret)	 	
			on RETURN_CODE = MSFAIL
			do status "Invalid diameter value"
			state .
		do VRChangeActivePocketMenu (&me->ret)
		state EVAL

	on EX_FORM_FINISHED
		state EVAL

/* ======================================================================== */
