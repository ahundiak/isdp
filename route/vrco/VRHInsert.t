/* $Id: VRHInsert.t,v 1.1.1.1 2001/01/04 21:12:42 cvs Exp $  */

/************************************************************************
 * I/ROUTE
 *
 * File:	vrco / VRHInsert.t
 *
 * Description:
 *	State table definition for all Hvac "Insert Component"
 *	commands.
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 *	12/18/90	O.N		Creation
 *	02/12/92	Karine		??????
 *	09/27/94	Manyam		Modified the state table for the
 *					special processing required for
 *					O-C xtion ( width == depth ).
 *	12/06/95	tlb	Remove VRcmd.h, change message key
 *				VR_E_NotHvacComponent not defined - 
 *					replace by VR_S_NotHvacComp
 *********************************************************************/

command_string	VRC_M_InsertHvacTransition, VR_HVACTRANSITION_INSERTION, VRPlTr
synonym		VRC_M_InsertHvacReducer,VR_HVACREDUCER_INSERTION,VRPlHVRd
synonym		VRC_M_InsertHvacMisc, VR_HVACMISC_INSERTION , VRPlUDHVCm
synonym		VRC_M_InsertHvacDev, VR_HVACDEV_INSERTION , VRPlDv
synonym		VRC_M_InsertHvacOffset,VR_HVACOFFSET_INSERTION , VRPlHVOf
synonym		VRC_M_InsertHvacSplit, VR_HVACSPLIT_INSERTION , VRPlHVBr
synonym		VRC_M_InsertDuctEnds,VR_HVACENDS_INSERTION,VRPlDcEn
synonym		VRC_M_InsertHvacTermDev, VR_HVACTERMDEV_INSERTION , VRPlTrDv
class		VRHInsert
product_name	"$ROUTE"
command_table	"route.cmd"
options         "isTC"
start_state	start

status_display"VRHVCmDsPara","-1","-1"
form "VRHVSkParams" , 0, 0,"-1", "-1"         /*   used from sketch   */
form "VRUserParam"  , 1, 0,"-1", "-1"

state_table

#include "VRcompdef.h"
#include "VRmsg.h"
#include "ECmsg.h"
#include "VRco.h"
#include "VRsketchdef.h"

#define	DISPLAYED		2000

state *
on  EX_DATA.GRst_PERPEND_FROM                        		state HaveError
on  EX_DATA.GRst_ANGLE_FROM                          		state HaveError
on  EX_DATA.GRst_TANGENT_FROM                        		state HaveError
on  EX_DATA.GRst_PERPEND_TO                          		state HaveError
on  EX_DATA.GRst_ANGLE_TO                           		state HaveError

on TERMINATE                         state terminate

on GR_UNKNOWN_TYPE.TERMINATE or
   GR_UNKNOWN_TYPE.CLEAR_STACK       state terminate

/* ======================================================================== */

state start

	on ELSE do VRDisplayMessage (&me->ret)
		do VRDefaultPocketMenu (&me->ret)
		do VRInitInstance(&me->ret)		state GET_OBJ

/* ======================================================================== */

state GET_OBJ

	prompt_key		VR_P_IdComp
	status_key		EMS_I_InvkStatusFrm
	accept_key		VR_P_EnterInsertReject
	dynamics		off
	locate_eligible		"VRHComp, VRHCComp, VRHNozz"
   	locate_owner         	"LC_RIGID_COMP"
	filter			locate

	on EX_BACK_UP or EX_RJT_MOVEON				state start

	on EX_DATA	do VRGetLocatedObject ( &me->ret )
				on RETURN_CODE = VRNOT_OK	state -
			do VRDisplayMessage (&me->ret)
				on RETURN_CODE = VRNOT_OK	state .
			do VRLoadForm ( &me->ret )		state GET_CODE

	on ERROR	do status_key VR_S_NotHvacComp	state HaveError	

	on EX_FORM_FINISHED    					state .


/* ======================================================================== */

state HaveFlow

	prompt_key		VR_P_DefineOrientationReverse
	dynamics		DYNTEE
	filter			get_event

	on EX_DATA	do VRComputeOrientationTee(&me->ret)	state HaveOrient

        on EX_RJT_MOVEON
			do VRReverseComponent(&me->ret)		state .

	on EX_BACK_UP
		do VRUnLockId( &me->ret )
		state GET_CODE

	on ELSE							state .

/* ======================================================================== */

state HaveOrient

	prompt_key		VR_P_AcceptOrientationReverse
	dynamics	 	off
	filter			get_event


	on EX_DATA						state PL_CMP

	on EX_BACK_UP
		do VRUnLockId( &me->ret )
		state -

	on EX_RJT_MOVEON
			do VRRotateQuadrant(&me->ret)
			do VRGetReturnCode(&me->ret)
		on RETURN_CODE = IS_ENDLINE_COMP		state .
			do VRComputeOrientationTee(&me->ret)	state .

	on ELSE							state .

/* ======================================================================== */

state PL_CMP

	prompt    ""
	status	  ""
	dynamics  off

	on ELSE		do VRInsertComponent (&me->ret)
		on RETURN_CODE = VRNOT_OK	
			do VRChangeActivePocketMenu (&me->ret)
 			do VRDisplayMessage (&me->ret)		state GET_CODE
								state start
/* ======================================================================== */

state EVAL

	prompt    ""
	status	  ""
	dynamics  off

	on ELSE		do VREvaluateComp (&me->ret)
		on RETURN_CODE = VR_ADDED_PARAM
			do VRUpdateForm (&me->ret)		state MISS
		on RETURN_CODE = VR_NOT_VALID
			do VRRetrieveLocatedContext (&me->ret)	state GET_CODE
			do VRGetReturnCode(&me->ret)
		on RETURN_CODE = IS_ENDLINE_COMP		
			do VRGetCompMatrix(&me->ret)
			do VRRotateComponent(&me->ret)		state HaveOrient
		on RETURN_CODE = VRNOT_OK
			do VRRetrieveLocatedContext (&me->ret)	state GET_CODE
			do VRValidateXtion( &me->ret )
				on RETURN_CODE = VRNOT_OK
					do status_key	VR_S_InvalidOCXtion
								state GET_CODE
			do VRGetCompMatrix(&me->ret)	
			do VRRotateComponent(&me->ret)		state HaveFlow

/* ======================================================================== */

state MISS

	prompt_key    VR_P_ChgPar
	status	  	""
	dynamics  	off
	filter		wfi

	on EX_FORM_FINISHED					state -

/* ======================================================================== */

state GET_CODE

   on CMD_TYPE = VR_HVACMISC_INSERTION  
			do    prompt_key    VR_P_EnterCmpCode   state GET_CODE1
   on ELSE          do    prompt_key    VR_P_EnterAABBCCcode state GET_CODE1

/* ======================================================================== */

state GET_CODE1

	dynamics		off
	filter			wfi

	execute		VRChangeActivePocketMenu (&me->ret)
	execute 	VRDisplayMessage (&me->ret)

	on STATUS_DISP						
			do VRDisplayMessage (&me->ret)
			do status_disp ()			state GET_CODE

	on EX_BACK_UP 	
			do VRRetrieveLocatedContext (&me->ret)
			do VRDisplayMessage (&me->ret)
			do VRDefaultPocketMenu (&me->ret)
			do VRUnLockId( &me->ret )
			state GET_OBJ

	on EX_RESET or EX_RJT_MOVEON				state .


	on EX_FORM_FINISHED
			do VRCopyReturnCode (&me->ret)
		on RETURN_CODE	= VRLOC_CMP
			do VRDefaultPocketMenu (&me->ret)	state LOC_CMP
		on RETURN_CODE = EX_FORM_ERASE
			do VRDisplayMessage (&me->ret)		state GET_CODE
								state EVAL

	on  EX_STRING or EX_CHAR 
			do VRGetAABBCCCode (&me->ret)	 	
		on RETURN_CODE = MSFAIL
			do status_key  VR_S_InvalidAABBCCcode	state .
			do VRDisplayMessage (&me->ret)
			do VRLoadForm(&me->ret)
			do VRSetIdManData( &me->ret )
			do VRIsDisplayed( me->status_display_form_ptr )
		on DISPLAYED					state .
                        do VRSKF_start (&me->ret)
                                on RETURN_CODE = VRSKF_DOIT
                                state FORMIN
			do VRIsReducerRequired (&me->ret)
		on RETURN_CODE = VRREDUCER
			do VRDefaultPocketMenu (&me->ret)	state GET_DIAM
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

state LOC_CMP

	message_key		VR_M_CHDParamComp
	prompt_key		VR_P_IdComp
	accept_key		VR_P_AccRejectComponent
	dynamics		off
	locate_eligible		"VRHComp, VRHCComp"
   	locate_owner         	"LC_RIGID_COMP | LC_REF_OBJECTS | LC_NO_REF_HEADER"
	dynamics		off
	filter			locate

	on EX_BACK_UP 
			do VRChangeActivePocketMenu (&me->ret)
			do VRDisplayMessage (&me->ret)		state -

	on EX_DATA	do VRCopyComponentAttr (&me->ret)
			do VRChangeActivePocketMenu (&me->ret)
			do VRDisplayMessage (&me->ret)		state -	
	on ERROR						state HaveError

	on EX_FORM_FINISHED
		 	do VRCopyReturnCode (&me->ret)
		on  RETURN_CODE = EX_FORM_ERASE
			do VRChangeActivePocketMenu (&me->ret)
			do VRDisplayMessage (&me->ret)		state GET_CODE
								state .

	on  EX_RJT_MOVEON or EX_RESET
			do VRChangeActivePocketMenu (&me->ret)
			do VRDisplayMessage (&me->ret)		state -	

/* ======================================================================== */

state HaveError
   
   	status_key  		VR_S_InvDataType

	on ELSE							state -

/* ======================================================================== */

state GET_DIAM

	prompt			"Enter width, depth"
	dynamics		off
	filter			wfi

	on STATUS_DISP	do VRDisplayMessage (&me->ret)
			do status_disp ()			
			do VRChangeActivePocketMenu (&me->ret)
								state GET_CODE

	on EX_RESET or EX_RJT_MOVEON				state .

	on EX_BACK_UP 	do VRRetrieveLocatedContext (&me->ret)	state GET_CODE

	on  EX_STRING or EX_CHAR 
			do VRGetOtherValues (&me->ret)	 	
		on RETURN_CODE = MSFAIL
			do status "Invalid values entered"	state .
			do VRChangeActivePocketMenu (&me->ret)
								state EVAL

	on EX_FORM_FINISHED    					state EVAL

