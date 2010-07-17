/* $Id: VRsketch.t,v 1.1.1.1 2001/01/04 21:13:10 cvs Exp $  */

/***********************************************************************
 * I/ROUTE
 *
 * File:        vrsketch/VRsketch.t
 *
 * Description:
 *  This file contains the commands : 
		Piping  sketch : VRSkPipeLine,0,VRSkPp
 *	        HVAC    sketch : VRSkDuctLine,1,VRSkDcLn
 *		Raceway sketch : VRSkRaceway,2,VRSkRw
 *
 *
 *  To start sketching a network the system asks user to identify element 
 *  or enter data point. To identify element user has two ways :
 *  he can select locate gadget on the sketch form and locate an element or
 *  gives a tentative point on the desired element.
 *  For the next step the system asks for the next point. This point can be 
 *  given by a tentative point, by locating a component ( in the two cases 
 *  system activate the construct point mecanism to construct all different
 *  ways to sketch from start point to the given one. In the locate case system
 *  connect the current network to the one who has got locating element ),
 *  by a regular point, by giving a distance along choissen direction. This
 *  point can be in the orthogonal mode or skewed mode ( skewed mode is 
 *  ( activated on the sketch form ).
 *  Between two given points system creates a segment, it connects 
 *  automatically two or more creating segments by component ( elbow, tee,..).
 *  the first segment starts with dangling and the end one finishs with a
 *  dangling. With the sketch user can connects two seperate networks. To
 *  connect network user can locate dangling, elbow or pipe to start from one
 *  of these network and the same to end to the other.
 *  In the sketch user gives attributes of automatic component to place using
 *  the active design parameters and the additiannal design parameters forms
 *  With the sketch command user is able to place reducer, flanges along 
 *a line and reducing elbow ( in HVAC ) or reducing branch component,
 *  he is able to place components fitting to fitting too ( fitting to 
 *  fitting mode is activated on the sketch form )
 *
 *  NB    :     
 *	the state is clearly to undestand the different possibilities 
 *	of the sketch command.
 * 
 *  VRsketch.t ==> this file contains the state table
 *
 * Log History:
 *	$Log: VRsketch.t,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:10  cvs
 *	Initial import to CVS
 *	
# Revision 1.3  2000/03/27  01:31:56  pinnacle
# Replaced: vrsketch/VRsketch.t for: CR179801143 by aharihar for route
#
# Revision 1.2  2000/03/22  21:49:22  pinnacle
# Replaced: vrsketch/VRsketch.t for:  by lawaddel for route
#
# Revision 1.1  2000/03/20  06:34:48  pinnacle
# Created: vrsketch/VRsketch.t by aharihar for route
#
 *
 * History:
 *      Feb 2000	Anand   Split VRsketch.sl into .t, .S and .I
 *   26 Mar 2000	Anand   Moved Status button toggle to state N_P
 ***********************************************************************/

class                	VRsketch
super_class          	VRCmpMgr
product_name         	"$ROUTE"
command_table		"route.cmd"
options			"isTC"

command_string       	VRC_M_SkPipeLine,0,VRSkPp
synonym			VRC_M_SkDuctLine,1,VRSkDcLn
synonym			VRC_M_SkRaceway,2,VRSkRw

form "VRSkMissParams",0,0,"-1","-1"
status_display "VRConnectCmp","-1","-1"

/**********************************************************/

state_table

#include "VRmsg.h"
#include "ECmsg.h"
#include "VRdef.h"
#include "VRco.h"
#include "VRcompdef.h"
#include "grownerdef.h"
#include "VRsketchdef.h"

#define DYN 		1      /* dynamic is active at 1 */
#define DYNTEE		2      /* dynamic for orientation tee */
#define FALSE		0      /* */
#define TRUE		1      /* */
#define NOT_VALID       100    /* any thing */
#define	STOP		20
#define LLP_FLG         299

#define	VR_LINE_NUM	0
#define	VR_TAG_NUM	1
#define NO_MORE_SOLUTIONS 101  

state *
on  EX_DATA.GRst_PERPEND_FROM                        	state have_error
on  EX_DATA.GRst_ANGLE_FROM                          	state have_error
on  EX_DATA.GRst_TANGENT_FROM                        	state have_error
on  EX_DATA.GRst_PERPEND_TO                          	state have_error
on  EX_DATA.GRst_ANGLE_TO                            	state have_error
on  GR_UNKNOWN_TYPE.TERMINATE				state terminate
on  GR_UNKNOWN_TYPE.CLEAR_STACK				state terminate


state main

   on CMD_TYPE = 0 do	message_key	VR_M_SkPipeLine	state init_start
   on CMD_TYPE = 1 do	message_key	VR_M_SkDuctLine	state init_start
   on CMD_TYPE = 2 do	message_key	VR_M_SkRaceway	state init_start


state init_start
   execute VRInitInstance( &me->ret )
   execute VRSkInitInstance( &me->ret )
   execute VRSkFormBottonOff( &me->ret )
   execute VRSkPopupStatusField( &me->ret )
   execute status_display_button(1)
   on ELSE
   state start

state start
   prompt_key		VR_P_IdElemDataPointToStart
   status_key		EMS_I_InvkStatusFrm
   dynamics		off
   filter		get_event

   on EX_BACK_UP or EX_RJT_MOVEON
	state init_start

   on EX_DATA.GRst_KEYPOINT
	do VRskfstelm( &me->ret )	
	do VRskupdate_event( &me->ret )
								state N_P

   on EX_DATA
	do VRskfstpt( &me->ret )
	do VRskupdate_event( &me->ret )
								state N_P

   on  EX_FORM_FINISHED
	do VRSkSetRetCode( 0 )
		on RETURN_CODE = LLP_FLG
		do status_key	VR_S_VRSkNotPos
								state .
		on RETURN_CODE = PP_LOCATE or RETURN_CODE = HV_LOCATE
								state LOC_CMP
	state .
   on EX_STRING
	do status_key	VR_S_VRSkNotPos
								state .

   on ELSE							state .

state N_P
   prompt_key	VR_P_NextPoint
   dynamics	DYN
   filter	get_event
   status_key	EMS_I_InvkStatusFrm

   execute	status_display_button(1)

   on EX_RJT_MOVEON
	do VRskendline( &me->ret )
	state init_start
      
   on EX_DATA.GRst_KEYPOINT
	do VRskgetnxtpt( &me->ret )
		on ERROR
		do VRskupdate_event( &me->ret )
		state .
	state N_C

   on EX_DATA.GRst_REGULAR
	do VRsknextpt( &me->ret )
		on ERROR
		do VRskupdate_event( &me->ret )
		state .
	do VRskcrseg( &me->ret )
	on RETURN_CODE = ADDITIONAL_PARAMS
	  do VRskupdate_form( &me->ret )
	  state ADD_MISS_PARAM
	do VRskupdate_event( &me->ret )
	state .

   on EX_DATA
	do VRskgetnxtpt( &me->ret )	
		on ERROR
		do VRskupdate_event( &me->ret )
		state .
	state N_C

   on DISTANCE
	do VRskdelta( &me->ret )
		on ERROR
		do VRskupdate_event( &me->ret )
		state .
	do VRskcrseg( &me->ret )	
	do VRskupdate_event( &me->ret )
	state .

   on EX_BACK_UP
	do VRskdelseg( &me->ret )
		on RETURN_CODE = NO_PREVIOUS_SEG
		do VRskupdate_event( &me->ret )
		state init_start
	do VRskupdate_event( &me->ret )
	state .

  /* Modified for CR179308634 - Livelookup of parts in db */
   on  EX_FORM_FINISHED
	do VRSkSetRetCode( 0 )
		on RETURN_CODE = LLP_FLG
		do VRInitInstance( &me->ret )
		do VRSkGetCmpCode( &me->ret )
		do VRSkActiveEmsPocket( &me->ret )
		do VRSwapSketchForm( VR_MANUAL )
		  state GET_PARAMS

		on RETURN_CODE = PP_SKEWED or RETURN_CODE = HV_SKEWED
		state SWD_ANG

		on RETURN_CODE = PP_LOCATE or RETURN_CODE = HV_LOCATE
		state LOC_CMP

                on RETURN_CODE = VR_BLOCK_LOCATE
                do status "LOCATE - need at least one set of coordinates first"
                state .

		on RETURN_CODE = VR_NOT_VALID
		do status_key VR_S_InvalidInput
		do VRSkPopupStatusField( &me->ret )
		do VRSkPartialInitInst( &me->ret )
		state .
	state .

   on EX_STRING
	do VRInitInstance( &me->ret )
	do VRSkGetCmpCode( &me->ret )
		on ERROR
		do status_key	VR_S_InvalidAABBCCcode
		state .
	do VRSkActiveEmsPocket( &me->ret )
	do VRSwapSketchForm( VR_MANUAL )
	state GET_PARAMS


state ADD_MISS_PARAM
   prompt	""
   status	""
   dynamics	off
   filter	wfi

   on EX_BACK_UP or EX_RJT_MOVEON
	do VRSkEraseMissingForm( &me->ret )
	state -
   on EX_FORM_FINISHED
	do VRSkEraseMissingForm( &me->ret )
	do VRskcrseg( &me->ret )
	state -
   on ELSE
	state .


state SWD_ANG
   prompt_key   VR_P_Angle
   dynamics	DYN
   filter	get_event

   on EX_RJT_MOVEON
	do VRSkPopupSkewed( &me->ret )
	do VRskendline( &me->ret )
	state init_start
      
   on EX_DATA.GRst_KEYPOINT  	
	do VRskgetnxtpt( &me->ret )
		on ERROR
		do VRskupdate_event( &me->ret )
		state .
	state N_C

   on EX_DATA.GRst_REGULAR
	do VRsknextpt( &me->ret )
		on ERROR
		do VRskupdate_event( &me->ret )
		state N_P
	do VRskcrseg( &me->ret )
	do VRSkPopupSkewed( &me->ret )
	do VRskupdate_event( &me->ret )
	state N_P

   on EX_DATA
	do VRskgetnxtpt( &me->ret )
		on ERROR
		do VRskupdate_event( &me->ret )
		state .
	state N_C

   on ANGLE
	do VRskgetangle( &me->ret )
	state SWD_LEN

   on EX_BACK_UP
	do VRSkPopupSkewed( &me->ret )
	do VRskdelangle( &me->ret )
	do VRskupdate_event( &me->ret )
	state -

   on  EX_FORM_FINISHED
	do VRSkSetRetCode( 0 )
		on RETURN_CODE = PP_LOCATE or RETURN_CODE = HV_LOCATE
		state LOC_CMP

		on RETURN_CODE = PP_SKEWED or RETURN_CODE = HV_SKEWED
		do VRskdelangle( &me->ret )
		do VRskupdate_event( &me->ret )
		state N_P
		
		on RETURN_CODE = MAINTAIN_SKEW
		do VRIsPrevSegSkewed( &me->ret )
			on RETURN_CODE = VRNOT_OK
			state SWD_LEN
		do VRSkPopupSkewed( &me->ret )
		do VRskdelangle( &me->ret )
		do VRskupdate_event( &me->ret )
		state N_P

	state .

   on EX_STRING
	do VRskdelangle( &me->ret )
	do VRInitInstance( &me->ret )
	do VRSkGetCmpCode( &me->ret )
		on ERROR
		do status_key	VR_S_InvalidAABBCCcode
		state .
	do VRSkActiveEmsPocket( &me->ret )
   	do VRSwapSketchForm( VR_MANUAL )
	state GET_PARAMS

state SWD_LEN
   prompt_key	VR_P_Length
   dynamics	DYN
   filter	get_event

    on EX_RJT_MOVEON
	do VRSkPopupSkewed( &me->ret )
	do VRskendline( &me->ret )
	state init_start
      
   on EX_DATA.GRst_KEYPOINT
	do VRskgetnxtpt( &me->ret )
		on ERROR
		do VRskupdate_event( &me->ret )
		state .
	state N_C

   on EX_DATA.GRst_REGULAR      
   	do VRsknextpt( &me->ret )
		on ERROR
		do VRskupdate_event( &me->ret )
		state .
	do VRSkPopupSkewed( &me->ret )
	do VRskcrseg( &me->ret )
	do VRskupdate_event( &me->ret )
	state N_P

   on EX_DATA
	do VRskgetnxtpt( &me->ret )	
		on ERROR
		do VRskupdate_event( &me->ret )
		state .
	state N_C

   on DISTANCE
	do VRskdelta( &me->ret ) 
		on ERROR
		do VRskupdate_event( &me->ret )
		state .
	do VRSkPopupSkewed( &me->ret )
	do VRskcrseg( &me->ret )	
	do VRskupdate_event( &me->ret )
	state N_P

   on EX_BACK_UP
	do VRskdelangle( &me->ret )
	do VRskupdate_event( &me->ret )
	state -

   on  EX_FORM_FINISHED
	do VRSkSetRetCode( 0 )
		on RETURN_CODE = PP_LOCATE or RETURN_CODE = HV_LOCATE
		state LOC_CMP

		on RETURN_CODE = PP_SKEWED or RETURN_CODE = HV_SKEWED
		do VRskdelangle( &me->ret )
		do VRskupdate_event( &me->ret )
		state N_P

		on RETURN_CODE = MAINTAIN_SKEW
		state SWD_ANG
	state .

   on EX_STRING
	do VRSkPopupSkewed( &me->ret )
	do VRskdelangle( &me->ret )
	do VRInitInstance( &me->ret )
	do VRSkGetCmpCode( &me->ret )
		on ERROR
		do status_key	VR_S_InvalidAABBCCcode
		state .
	do VRSkActiveEmsPocket( &me->ret )
	do VRSwapSketchForm( VR_MANUAL )
	state GET_PARAMS

state N_C
   prompt_key	VR_P_AccReject
   dynamics	off
   filter	get_event

   on EX_BACK_UP
        do VRSkPopupSkewed( &me->ret )
	do VRskupdate_event( &me->ret )
	do VRskinit_buffer( &me->ret )
	state N_P

   on EX_RJT_MOVEON
	do VRsknextchoice( &me->ret )
                on RETURN_CODE = NO_MORE_SOLUTIONS
                do VRSkPopupSkewed( &me->ret )
                do VRskupdate_event( &me->ret )
                do VRskinit_buffer( &me->ret )
                state N_P
	state .

   on EX_DATA.GRst_REGULAR
	do VRSkPopupSkewed( &me->ret )
	do VRskcstsol( &me->ret )
		on ERROR
		do VRskupdate_event( &me->ret )
		do VRskinit_buffer( &me->ret )
		state N_P
	do VRSkSetRetCode( 0 )
		on RETURN_CODE = 10
		state N_C
	do VRskupdate_event( &me->ret )	
	do VRskinit_buffer( &me->ret )
	state N_P

   on  EX_FORM_FINISHED
	state .


state LOC_CMP
   prompt_key		VR_P_IdComp
   dynamics		off
   locate_owner         "LC_RIGID_COMP | LC_REF_OBJECTS"
   accept_key		VR_P_AccReject
   relocate_key		VR_S_CompNotFound
   filter		locate

   on EX_DATA
	do VRSkGetLocateState( &me->ret )
		on RETURN_CODE = NO_PREVIOUS_SEG
		do VRSkGetEvent( &me->ret )
			on ERROR
			do VRskupdate_event( &me->ret )
			state .
		do VRskfstelm ( &me->ret )
		do VRSkPopupLocate( &me->ret )
		do VRskupdate_event( &me->ret )
		state N_P
	do VRSkGetEvent( &me->ret )
		on ERROR
		do VRSkPopupSkewed( &me->ret )
		do VRSkPopupLocate( &me->ret )
		do VRskupdate_event( &me->ret )
		state -
	do VRskgetnxtpt( &me->ret )
		on ERROR
		do VRSkPopupSkewed( &me->ret )
		do VRSkPopupLocate( &me->ret )
		do VRskupdate_event( &me->ret )
		state -
	do VRSkPopupLocate( &me->ret )
	do VRSkSetRetCode( 0 )
		on RETURN_CODE = STOP
		do VRskupdate_event( &me->ret )
		state init_start
	do VRSkPopupSkewed( &me->ret )
	do VRskupdate_event( &me->ret )
	state N_C



   on EX_BACK_UP or EX_RJT_MOVEON				
	do VRSkGetLocateState( &me->ret )
	do VRSkPopupSkewed( &me->ret )
	do VRSkPopupLocate( &me->ret )
		on RETURN_CODE = NO_PREVIOUS_SEG
		state init_start
	state N_P


   on  EX_FORM_FINISHED
	do VRSkSetRetCode( 0 )
		on RETURN_CODE = PP_LOCATE or RETURN_CODE = HV_LOCATE	
		do VRSkPopupSkewed( &me->ret )
		state N_P
		on RETURN_CODE = PP_SKEWED or RETURN_CODE = HV_SKEWED
		state .
	state .

/* VRskformon/VRskformoff Added for CR179308634 - Livelookup of parts in db */

state GET_PARAMS
   prompt_key	VR_P_ChgPar
   dynamics	off
   filter	get_event

   on EX_RJT_MOVEON or EX_BACK_UP
	do VRSwapSketchForm( VR_AUTOMATIQUE )
	do VRSkPopupStatusField( &me->ret )
	do VRSkUnLockId( VR_TAG_NUM )
	state -

   on  EX_FORM_FINISHED
	do VRSkSetCmpInstance( &me->ret )
	do VREvaluateComp( &me->ret )
		on RETURN_CODE = VR_ADDED_PARAM
		do VRskupdate_form( &me->ret )
		state ADD_PARAM

		on RETURN_CODE = VR_NOT_VALID
		do VRSwapSketchForm( VR_AUTOMATIQUE )
		do VRSkUnLockId( VR_TAG_NUM )
		do VRDeleteGraphics( &me->ret )
		state N_P
	do VRGetReturnCode( &me->ret )
	do VRSkSetRetCode( 0 )
		on RETURN_CODE = IS_NO_ORIENT						
                do VRskformoff(&me->ret)
       		do VRSkInitCmpOrient( &me->ret )
		state PL_CMP

		on RETURN_CODE = IS_ENDLINE_COMP
		do VRSkInitCmpOrient( &me->ret )
		do VRSkSetRetCode( 1 )
			on RETURN_CODE = VR_HVAC
			state HV_ORI_CMP
		do VRPlaceCmp( &me->ret )
			on ERROR
			state .
		do VRSkUpdateNetWork( &me->ret )
		do VRSkEndLineRoute( &me->ret )
		do VRSwapSketchForm( VR_AUTOMATIQUE )
		do VRSkEraseMissingForm( &me->ret )	
		do VRSKEraseHvacTee( &me->ret )			
		do VRSkPopupStatusField( &me->ret )
		state init_start
	do VRSkInitCmpOrient( &me->ret )		
	do VRSkSetRetCode( 1 )
		on RETURN_CODE = VR_PIPING
		state REVERSE_PP_CMP

	state REVERSE_HV_CMP


state ADD_PARAM

   prompt_key	VR_P_EnterDesignParameters
   status	""
   dynamics	off
   filter	wfi

   on EX_BACK_UP or EX_RJT_MOVEON						
	do VRSkEraseMissingForm( &me->ret )
	state -

   on EX_FORM_FINISHED
	do VREvaluateComp( &me->ret )
		on RETURN_CODE = VR_ADDED_PARAM
		do VRskupdate_form( &me->ret )
		state .

		on ERROR
		do VRDeleteGraphics( &me->ret )
		state .
	do VRskupdate_form( &me->ret )
	do VRGetReturnCode( &me->ret )
	do VRSkSetRetCode( 0 )
		on RETURN_CODE = IS_NO_ORIENT
		do VRSkInitCmpOrient( &me->ret )
		state PL_CMP

		on RETURN_CODE = IS_ENDLINE_COMP
		do VRSkInitCmpOrient( &me->ret )
   		do VRPlaceCmp( &me->ret )
			on ERROR
			state .

		do VRSkUpdateNetWork( &me->ret )
		do VRSkEndLineRoute( &me->ret )
		do VRSwapSketchForm( VR_AUTOMATIQUE )
		do VRSkEraseMissingForm	( &me->ret )		
		do VRSkPopupStatusField( &me->ret )
		state init_start

	do VRSkInitCmpOrient( &me->ret )		
		on RETURN_CODE = NO_PREV_SEG
		state MX_ORI 
	do VRSkSetRetCode( 1 )
		on RETURN_CODE = VR_PIPING
		state REVERSE_PP_CMP
	state REVERSE_HV_CMP


state MX_ORI
   prompt	" Data to accept moveon to continue"
   dynamics	DYNTEE
   filter	get_event

  on EX_DATA
	state REVERSE_PP_CMP

  on EX_RJT_MOVEON
	state . 


state REVERSE_HV_CMP

   execute VRSkDisplayOrientTee( &me->ret )

   prompt_key	VR_P_DefineOrientationReverse
   dynamics	off
   filter	get_event

   on EX_DATA
	do VRSkDisplayOrientTee( &me->ret )
	state HV_ORI_CMP

   on EX_RJT_MOVEON
	do VRReverseComponent( &me->ret )
	state .

   on EX_BACK_UP
	do VRSKEraseHvacTee( &me->ret )
	state -


state REVERSE_PP_CMP

   execute VRSkDisplayOrientTee( &me->ret )
   execute VRskformoff(&me->ret)

   prompt_key	VR_P_DefineOrientationReverse
   dynamics	off
   filter	get_event

   on EX_DATA
	state PP_ORI_CMP

   on EX_RJT_MOVEON
	do VRReverseComponent( &me->ret )
	state .

   on EX_BACK_UP
	do VRSKEraseHvacTee( &me->ret )
	state -


state PP_ORI_CMP

   execute VRDisplayAngle ( &me->ret )

   prompt_key	VR_P_GiveDataOrKeyinToOrientCmp
   dynamics	DYNTEE
   filter	get_event

   on EX_DATA
	do VRComputeCmpAngle( &me->ret )		
	do VRRotateComponent( &me->ret )
        do VRskformon(&me->ret)
	state PL_CMP

   on DISTANCE
	do VROrientByAngle (&me->ret)
		on RETURN_CODE = VRNOT_OK
		do VRRotateComponent (&me->ret)
                do VRskformon(&me->ret)
		state PL_CMP
	do VRRotateComponent (&me->ret)
	state .

   on EX_BACK_UP
        do VRskformon(&me->ret)
	state -

   on EX_RJT_MOVEON
	do VRRotateQuadrant( &me->ret )
	state .

   on EX_FORM_FINISHED
	state .


state HV_ORI_CMP

   prompt_key	VR_P_AcceptOrientationReverse
   dynamics	off
   filter	get_event

   on EX_DATA
	do VRGetReturnCode(&me->ret)
		on RETURN_CODE = IS_ENDLINE_COMP
		state PL_CMP
	do VRSKEraseHvacTee( &me->ret )
	state PL_CMP

   on EX_BACK_UP
	do VRGetReturnCode(&me->ret)
		on RETURN_CODE = IS_ENDLINE_COMP
		state -
	do VRSKEraseHvacTee( &me->ret )
	state -

   on EX_RJT_MOVEON
	do VRGetReturnCode(&me->ret)
		on RETURN_CODE = IS_ENDLINE_COMP
		do VRRotateQuadrant( &me->ret )
		state .		
	do VRSKEraseHvacTee( &me->ret )
	do VRRotateQuadrant( &me->ret )
	state .

   on EX_FORM_FINISHED
	state .


state PL_CMP

   prompt       ""
   status	""
   dynamics	off

   on ELSE
        do VRskformon(&me->ret)
	do VRPlaceCmp( &me->ret )
	do VRSwapSketchForm( VR_AUTOMATIQUE )
	do VRSkEraseMissingForm( &me->ret )		
	do VRSkPopupSkewed( &me->ret )		
		on ERROR
		do VRSkPopupStatusField( &me->ret )
		do VRDeleteGraphics( &me->ret )
		do VRskendline( &me->ret )
		state init_start
	do VRSkPopupStatusField( &me->ret )
	do VRSkUpdateNetWork( &me->ret )
   	do VRskrestart( &me->ret )
		on RETURN_CODE = VR_NEED_CPT
			state GET_DATA
		on ERROR
		do VRSkEndLineRoute( &me->ret )
		state init_start
	state N_P

state GET_DATA

   prompt_key	VR_P_GiveDataNearCpt
   dynamics	off
   filter	get_event


   on EX_RJT_MOVEON
	do VRSkEndLineRoute( &me->ret )
	do VRSkPartialInitInst( &me->ret )
	state init_start

   on EX_BACK_UP
	do VRskdelseg( &me->ret )
	do VRskupdate_event( &me->ret )
	state N_P

   on EX_DATA
	do VRSkGetCptInfo( &me->ret )
	state N_P


state have_error
   
   status_key  VR_S_InvDataType

   on ELSE
	state -


