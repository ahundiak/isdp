/* $Id: VRRInsert.t,v 1.1.1.1 2001/01/04 21:12:43 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrco/VRRInsert.t
 *
 * Description:
 *	insert Valve state language file.
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRRInsert.t,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:43  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.2  1997/02/24  22:05:44  pinnacle
# Replaced: vrco/VRRInsert.t for:  by hverstee for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.6  1996/02/27  07:13:14  pinnacle
# Replaced: vrco/VRRInsert.t for:  by ashankar for route240
#
# Revision 1.5  1996/02/20  04:18:26  pinnacle
# Replaced: vrco/VRRInsert.t for:  by ashankar for route240
#
# Revision 1.4  1996/02/19  05:40:44  pinnacle
# Replaced: vrco/VRRInsert.t for:  by ashankar for route240
#
# Revision 1.3  1995/12/08  21:18:42  pinnacle
# Replaced: vrco/VRRInsert.t for:  by r240_int for route240
#
 *
 * History:
 *	Creation : O.N (isdc Paris)		18-12-1990
 *	12/06/95	tlb	Remove VRcmd.h
 *				VR_E_NotHvacComponent not defined - 
 *					replace by VR_S_NotHvacComp
 *
 *************************************************************************/
command_string		VRC_M_InsertRwayReducer,VR_RWAYREDUCER_INSERTION,VRPlRwRd
synonym			VRC_M_InsertRwayMisc, VR_RWAYMISC_INSERTION , VRPlUDRwCm
synonym			VRC_M_InsertRwayOffset,VR_RWAYOFFSET_INSERTION , VRPlRwOf
synonym			VRC_M_InsertRwaySplit, VR_RWAYSPLIT_INSERTION , VRPlRwBr
class			VRRInsert
product_name		"$ROUTE"
command_table		"route.cmd"
options         "isTC"

start_state		start

status_display"VRRwCmDsPara","-1","-1"
form "VRRwaySkParams", 0, 0,"-1", "-1"           /*    used from sketch   */
form "VRUserParam", 1, 0,"-1", "-1"

state_table

#include "VRcompdef.h"
#include "VRmsg.h"
#include "ECmsg.h"
#include "VRsketchdef.h"
#include "VRco.h"

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

	on ELSE do VRDisplayMessage (&me->ret)
		do VRDefaultPocketMenu (&me->ret)
		do VRInitInstance(&me->ret)		state GET_OBJ

/* ======================================================================== */

state GET_OBJ

	prompt_key		VR_P_IdComp
	status_key		EMS_I_InvkStatusFrm
	accept_key		VR_P_EnterInsertReject
	dynamics		off
	locate_eligible		"VRRComp, VRRCComp"
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

	on EX_DATA	do  VRComputeOrientationTee(&me->ret)	state HaveOrient

        on EX_RJT_MOVEON
			do VRReverseComponent(&me->ret)		state .

	on EX_BACK_UP 						state GET_CODE

	on ELSE							state -

/* ======================================================================== */

state HaveOrient

	prompt_key		VR_P_AcceptOrientationReverse
	dynamics	 	off
	filter			get_event


	on EX_DATA						state PL_CMP

	on EX_RJT_MOVEON
			do VRRotateQuadrant(&me->ret)
			do VRComputeOrientationTee(&me->ret)	state .

	on EX_BACK_UP 						state -


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
			do VRRotateComponent(&me->ret)		state PL_CMP
		on RETURN_CODE = VRNOT_OK
			do VRRetrieveLocatedContext (&me->ret)	state GET_CODE
			do VRGetCompMatrix(&me->ret)
			do VRRotateComponent(&me->ret)		state HaveFlow

/***************************************************************************/

state MISS

	prompt_key    VR_P_ChgPar
	status	  	""
	dynamics  	off
	filter		wfi

	on EX_FORM_FINISHED					state -


/* ======================================================================== */

state GET_CODE

        on CMD_TYPE = VR_RWAYMISC_INSERTION 
			do   prompt_key VR_P_EnterCmpCode     state GET_CODE1
        on ELSE         do   prompt_key VR_P_EnterAABBCCcode     state GET_CODE1

/*========================================================================== */

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
		on RETURN_CODE = VRNOT_OK			state start
								state GET_OBJ

	on EX_RESET or EX_RJT_MOVEON				state .

	on EX_FORM_FINISHED
			do VRCopyReturnCode (&me->ret)
		on RETURN_CODE = VRLOC_CMP
			do VRDefaultPocketMenu (&me->ret)	state LOC_CMP
		on RETURN_CODE = EX_FORM_ERASE
			do VRDisplayMessage (&me->ret)		state GET_CODE
		on RETURN_CODE = VRALL_OK			state EVAL
								state .
	
	on  EX_STRING or EX_CHAR 
			do VRGetAABBCCCode (&me->ret)	 	
		on RETURN_CODE = MSFAIL
			do status_key  VR_S_InvalidAABBCCcode	state .
			do VRDisplayMessage (&me->ret)
			do VRLoadForm(&me->ret)
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
	locate_eligible		"VRRComp,VRRCComp"
   	locate_owner         	"LC_RIGID_COMP | LC_REF_OBJECTS | LC_NO_REF_HEADER"
	dynamics		off
	filter			locate

	on EX_BACK_UP   do VRChangeActivePocketMenu (&me->ret)
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
			do VRChangeActivePocketMenu (&me->ret)	state GET_CODE

	on EX_RESET or EX_RJT_MOVEON				state .

	on EX_BACK_UP 	do VRRetrieveLocatedContext (&me->ret)	state GET_CODE

	on  EX_STRING or EX_CHAR 
			do VRGetOtherValues (&me->ret)	 	
		on RETURN_CODE = MSFAIL
			do status "Invalid values entered"	state .
			do VRChangeActivePocketMenu (&me->ret)	state EVAL

	on EX_FORM_FINISHED    					state EVAL



