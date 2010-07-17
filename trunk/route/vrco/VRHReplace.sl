/* $Id: VRHReplace.sl,v 1.1.1.1 2001/01/04 21:12:42 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrco/VRHReplace.sl
 *
 * Description:
 *	Replace Hvac Component state language file.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRHReplace.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:42  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  2000/03/22  17:18:46  pinnacle
# (No comment)
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.5  1996/04/25  22:04:32  pinnacle
# Replaced: vrco/VRHReplace.sl for:  by ashankar for route240
#
# Revision 1.4  1996/03/05  22:16:24  pinnacle
# Replaced: vrco/VRHReplace.sl for:  by hverstee for route240
#
# Revision 1.3  1995/12/08  21:19:34  pinnacle
# Replaced: vrco/VRHReplace.sl for:  by r240_int for route240
#
 *
 * History:
 	Creation : O.N (isdc Paris)		05-04-1991


 	CHANGE HISTORY: Karine  (isdc Paris)   12-02-1992 
		 	momo    (isdc Paris)   26-03-1992 
		 	Karine  (isdc Paris)   20-12-1992

 *	12/06/95	tlb		Remove VRcmd.h
 *	03/13/2000	Alwin	Removed the option to accept/backup after running the
 *						form. As per request CR179900944
 *
 *************************************************************************/

command_string		VRC_M_HRepComp, 0, VRRpHVCm
class			VRHReplace
super_class		VRCOHvac
product_name		"$ROUTE"
command_table		"route.cmd"


form "VRHVCmDsPara",0,1,"-1","-1"
form "VRUserParam", 1, 0,"-1", "-1"
status_display "VRConnectCmp","-1","-1"

specification

instance

{
	IGRboolean	FormUserFlag;
}

implementation

#include <stdio.h>
#include "VRco.h"
#include "AS_status.h"

#define AS_DEBUG

state_table

#include "VRcompdef.h"
#include "VRmsg.h"
#include "ECmsg.h"
#include "VRco.h"
#include "VRsketchdef.h"
#include "VRDbStruct.h"

state *
on  EX_DATA.GRst_PERPEND_FROM                        state HaveError
on  EX_DATA.GRst_ANGLE_FROM                          state HaveError
on  EX_DATA.GRst_TANGENT_FROM                        state HaveError
on  EX_DATA.GRst_PERPEND_TO                          state HaveError
on  EX_DATA.GRst_ANGLE_TO                            state HaveError

/* ======================================================================== */

state start

	on ELSE	do VRDefaultPocketMenu (&me->ret)
		do VRInitInstance(&me->ret)			state GET_OBJ

/* ======================================================================== */

state GET_OBJ

	message_key		VR_M_HRepComp
	prompt_key		VR_P_IdCompToReplace
	status_key		EMS_I_InvkStatusFrm
	accept_key    		VR_P_AccRejectComponent
	dynamics		off
	locate_eligible		"VRHComp, VRHCComp"
   	locate_owner         	"LC_RIGID_COMP"
	filter			locate

	on EX_BACK_UP or EX_RJT_MOVEON				state .

	on EX_DATA	do VRGetObject ( &me->ret )
		on RETURN_CODE = VRNOT_OK			state .
			do VRChangeActivePocketMenu (&me->ret)
			do VRSetUserFlag( 0 )
			do VRLoadForm ( &me->ret )
			do VRValidateIdChg( &me->ret )
								state ST_FORM

	on EX_FORM_FINISHED    					state .

/* ======================================================================== */

state ST_FORM

	message_key		VR_M_HRepComp
	prompt_key 		VR_P_EnterDesignParameters
	filter			wfi

	on EX_RESET or EX_RJT_MOVEON				state .

	on EX_BACK_UP 						state -

	on ERROR						state HaveError

	on EX_FORM_FINISHED
		do VRCopyReturnCode (&me->ret)
		on RETURN_CODE	= VRALL_OK
			do VREvaluateComp(&me->ret)
			on RETURN_CODE = VR_NOT_VALID
				do VRRetrieveLocatedContext(&me->ret)	state .
			do VRGetUserFlag (&me->ret)
			on RETURN_CODE = VRNOT_OK
				do VRSetUserFlag( 1 )
				do VRUpdateForm (&me->ret)		state .
			do VRGetCompMatrix(&me->ret)
			do VRChangeComponent (&me->ret)
			on RETURN_CODE = VRNOT_OK			state .
		on ERROR		
			do status_key VR_S_InvalidInput 	state .
		do VRRotateComponent(&me->ret)		
		do VRDeleteComponent(&me->ret) 			state start /*state ACC_PE*/

		on RETURN_CODE	= VRLOC_CMP			state LOC_CMP
		on RETURN_CODE = EX_FORM_ERASE			state .
		state .

	on  EX_STRING or EX_CHAR 
		do VRGetAABBCCCode (&me->ret)	 	
		on RETURN_CODE = MSFAIL
			do status_key  VR_S_InvalidAABBCCcode	state .
		do VRSetIdManData( &me->ret )
		do VRLoadForm( &me->ret )
		do VRValidateIdChg( &me->ret )
		state .
			
/* ======================================================================== */

state LOC_CMP

	message_key		VR_M_CPDParamComp
	prompt_key		VR_P_IdComp
	accept_key		VR_P_AccRejectComponent
	dynamics		off
	locate_eligible		"VRHComp,VRHCComp"
   	locate_owner         	"LC_RIGID_COMP|LC_REF_OBJECTS|LC_NO_REF_HEADER"
	filter			locate

	on EX_BACK_UP 						state -

	on EX_DATA	do VRCopyComponentAttr (&me->ret) 	state -	
	on ERROR						state HaveError

	on  EX_RJT_MOVEON or EX_RESET				state -	

	on EX_FORM_FINISHED   					state .

/* ======================================================================== */

state HaveError
   
	status_key		VR_S_InvDataType

	on ELSE							state -

/* ======================================================================== */


/* This piece of code won't be executed from now on, as per request 
CR179900944. Instead of calling this state, the command would call 
VRDeleteComponent method and direct the contrl to start. Alwin */
state ACC_PE

	message_key		VR_M_HRepComp
	prompt_key		VR_P_AccBackupToUndo
	filter			wfi


	on EX_DATA	do VRDeleteComponent(&me->ret)		state start

	on ERROR						state HaveError

	on EX_BACK_UP 	do VRRetrieveOldComponent(&me->ret)
			do VRDeleteComponent(&me->ret)		state start

	on  ELSE 						state . 


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

				method init ( 26-03-1992 )

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action init
{
  me->ReplaceCommand = TRUE;
  me->Product = VR_HVAC;
  /*| call VRCOHvac.init with respect to message */
  status = om$send (	mode     = OM_e_wrt_message,
			msg      = message VRCOHvac.init( type, str_ptr ),
			targetid = my_id);
  as$status( action = RET_STATUS );

  me->ReplaceCommand = TRUE;
  me->OldCmpTagId= -1;
  return (status);
}

action VRSetUserFlag ( IGRboolean flag )
{
	me->FormUserFlag = flag;
}

action VRGetUserFlag ( IGRint *sts )
{
	if( ( !me->FormUserFlag ) && ( me->MissParamId.objid != NULL_OBJID ) )
		me->ret = VRNOT_OK;
	else
		me->ret = VRALL_OK;
}
