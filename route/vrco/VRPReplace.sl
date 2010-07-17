/* $Id: VRPReplace.sl,v 1.2 2001/01/11 23:26:37 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrco/VRPReplace.sl
 *
 * Description:
 *	Replace Pipe Component state language file.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRPReplace.sl,v $
 *	Revision 1.2  2001/01/11 23:26:37  anand
 *	SP merge
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:43  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  2000/07/14  18:02:38  pinnacle
# Created: route/vrco/VRPReplace.sl by apazhani for Service Pack
#
# Revision 1.2  2000/03/20  06:47:20  pinnacle
# Replaced: vrco/VRPReplace.sl for: CR179801143 by aharihar for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.4  1998/02/28  00:18:46  pinnacle
# Replaced: vrco/VRPReplace.sl for:  by lawaddel for route
#
# Revision 1.3  1997/12/08  14:22:56  pinnacle
# Replaced: vrco/VRPReplace.sl for:  by apazhani for route
#
# Revision 1.2  1997/11/07  20:34:44  pinnacle
# Replaced: vrco/VRPReplace.sl for:  by lawaddel for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.7  1996/04/25  22:10:50  pinnacle
# Replaced: vrco/VRPReplace.sl for:  by ashankar for route240
#
# Revision 1.6  1996/03/05  22:14:18  pinnacle
# Replaced: vrco/VRPReplace.sl for:  by hverstee for route240
#
# Revision 1.5  1996/01/17  00:22:54  pinnacle
# Replaced: vrco/VRPReplace.sl for:  by r240_int for route240
#
# Revision 1.4  1995/12/08  21:20:04  pinnacle
# Replaced: vrco/VRPReplace.sl for:  by r240_int for route240
#
 *
 * History:
 *	Creation : O.N (isdc Paris)		05-04-1991
 *
 *	CHANGE : 
	Karine (isdc Paris)	12-02-1992  
	momo   (isdc Paris)	26-03-1992  
	Manyam	(IGI  Hyd  )	08-10-1993	Added VRValidateIdChg action
        Y. Zhu  (HSV      )     10-24-1995      Added set_prompt action and
 *
 *	12/06/95	tlb		Remove VRcmd.h
 *	01/15/96	tlb	Add VX_FIproto.h, prototypes
 *      11/06/97        law     CR179308634-Livelookup of parts in database
 *      12/08/97        Alwin   CR179421374-Enabled Replacement of Correction
 *                              Components.
 *      02/24/98        law     TR179700739 - Modified state tables to prevent
 *				multiple components with replace command.
 *      03/13/00        Alwin   CR 179900944 (Integrated by Anand)
 *      07/14/00        Alwin   The form should not be displayed unless
 *                              and until the Object is located and
 *                              found its a valid object. So, I'm
 *                              changing the third argument to zero.
 *                              And the form will be displayed in the
 *                              VRLoadForm() method. found while fixing ETL2780

 *************************************************************************/

command_string		VRC_M_PRepComp, 0, VRRpPpCm
class			VRPReplace
super_class		VRCOPiping
product_name		"$ROUTE"
/* product_name		"$SPXR" */
command_table		"route.cmd"
	

form "VRPpCmDsPara",0,0,"-1","-1"
form "VRUserParam", 1, 0,"-1", "-1"
status_display "VRConnectCmp","-1","-1"


specification

instance

{
	IGRboolean	FormUserFlag;
}

implementation

#include <stdio.h>
#include "AS_status.h"

%safe
#include "VX_FIproto.h"
%endsafe

from VRGeneric import VRGetStatus;

#define AS_DEBUG
state_table

#include "VRcompdef.h"
#include "VRsketchdef.h"
#include "VRmsg.h"
#include "ECmsg.h"
#include "VRco.h"
#include "FI.h"

state *
on  EX_DATA.GRst_PERPEND_FROM                        state HaveError
on  EX_DATA.GRst_ANGLE_FROM                          state HaveError
on  EX_DATA.GRst_TANGENT_FROM                        state HaveError
on  EX_DATA.GRst_PERPEND_TO                          state HaveError
on  EX_DATA.GRst_ANGLE_TO                            state HaveError

/* ======================================================================== */

state start

	on ELSE do VRDefaultPocketMenu (&me->ret)
		do VRInitInstance(&me->ret)	
                do status " "
								state GET_OBJ
/* ======================================================================== */
/* CR179308634 - clear-stack lines Added for livelookup */

state GET_OBJ

	status_key		EMS_I_InvkStatusFrm
	message_key		VR_M_PRepComp
	prompt_key		VR_P_IdCompToReplace
	accept_key    		VR_P_AccRejectComponent
	dynamics		off
	locate_eligible		"VRPComp, VRPCComp"
   	locate_owner         	"LC_RIGID_COMP"
	filter			locate

	on EX_BACK_UP or EX_RJT_MOVEON				state .

	on EX_DATA	do VRGetObject ( &me->ret )
		on RETURN_CODE = VRNOT_OK			state .
			do VRChangeActivePocketMenu (&me->ret)
			do VRSetUserFlag( 0 )
			do VRLoadForm ( &me->ret )
			do VRValidateIdChg( &me->ret )
			do VRGetOptionCode (&me->ret, 0 )

/*      If the located object is an error component then the return code
/*      is VRNOT_OK. But the command should still proceed.
/*      TR No: 179421187. Mallik.                                       */
/*              on RETURN_CODE = VRNOT_OK                       state . */

								state ST_FORM

       	on CLEAR_STACK						state terminate

	on EX_FORM_FINISHED  do VRCopyReturnCode (&me->ret)
		on RETURN_CODE = EX_FORM_ERASE			state terminate
								state .

	on EX_STRING	do VRDefaultPocketMenu (&me->ret) 	state .

/* ======================================================================== */

state ST_FORM

	message_key		VR_M_PRepComp
        execute                 set_prompt 
/*	prompt_key 		VR_P_EnterDesignParameters */
	filter			wfi

	on EX_RESET or EX_RJT_MOVEON				state .

	on EX_BACK_UP 						state -

	on ERROR						state HaveError

       	on CLEAR_STACK						state terminate

	on EX_FORM_FINISHED
                do VRCheckForCorrection (&me->ret)
                on RETURN_CODE = VR_CORRECTION             state Correction

		do VRCopyReturnCode (&me->ret)
		   on RETURN_CODE = VRALL_OK
			do VREvaluateComp (&me->ret)
		        on RETURN_CODE = VR_NOT_VALID			
			         do VRRetrieveLocatedContext(&me->ret)
                                 state .
			do VRGetUserFlag (&me->ret)
		        on RETURN_CODE = VRNOT_OK	
			  do VRSetUserFlag( 1 )
			  do VRUpdateForm (&me->ret) 		state .
			  do VRGetCompMatrix(&me->ret)
			  do VRChangeComponent (&me->ret)

		          on RETURN_CODE = VRNOT_OK			state .
		          on ERROR
			      do status_key VR_S_InvalidInput	
                              state .
			  do VReraserpform
			  do VRRotateComponent(&me->ret)		
                          do VRDeleteComponent(&me->ret)
                          state start
			 /*  state ACC_PE  - commented for CR 179900944 */
		   on RETURN_CODE = VRLOC_CMP			state LOC_CMP
		   on RETURN_CODE = EX_FORM_ERASE		state terminate
		state .

	on  EX_STRING or EX_CHAR 
			do VRGetAABBCCCode (&me->ret)	 	
		on RETURN_CODE = MSFAIL
		    	do status_key  VR_S_InvalidAABBCCcode	state .
			do VRSetIdManData( &me->ret )
			do VRLoadForm(&me->ret)
			do VRValidateIdChg( &me->ret )
			do VRGetOptionCode (&me->ret, 1 )
		on RETURN_CODE = VRNOT_OK			state .
			do VRIsReducerRequired (&me->ret)
		on RETURN_CODE = VRREDUCER			state GET_DIAM
								state . 

/* ======================================================================== */

state GET_DIAM
	message_key		VR_M_CPDParamComp
	prompt_key		VR_P_EnterDiamValue
	dynamics		off
	filter			wfi


	on  EX_STRING or EX_CHAR 
			do VRGetOtherValues (&me->ret)	 	
		on RETURN_CODE = MSFAIL
			do status "Invalid diameter value"	state .
								state ST_FORM

	on CLEAR_STACK						state terminate

	on EX_FORM_FINISHED    					state ST_FORM

/* ======================================================================== */

state LOC_CMP

	message_key		VR_M_CPDParamComp
	prompt_key		VR_P_IdComp
	accept_key		VR_P_AccRejectComponent
	dynamics		off
	locate_eligible		"+VRPiping"
   	locate_owner         	"LC_RIGID_COMP | LC_REF_OBJECTS | LC_NO_REF_HEADER"
	filter			locate

	on EX_BACK_UP 						state -

	on EX_DATA	
		do VRCopyComponentAttr (&me->ret)
		state -	

	on ERROR						state HaveError

	on CLEAR_STACK						state terminate

	on  EX_RJT_MOVEON or EX_RESET				state -	

	on EX_FORM_FINISHED					state .


/* ======================================================================== */

state HaveError
   
	status_key  		VR_S_InvDataType

	on ELSE							state -

/* ======================================================================== */

state Correction
 
     status                "Placing the Modified Component"
 
     on ELSE               do VREvalCorComp ( &me->ret )
                           state start
 
/* ======================================================================== */
/* ERROR and CLEAR_STACK modified to prevent new component being left behind*/
/*                   TR179700739                                            */ 

			   /* The below  state will not be called from now on.
			    * 			- Alwin for CR 179900944 */
state ACC_PE

	message_key		VR_M_PRepComp
	prompt_key		VR_P_AccBackupToUndo
	filter			wfi

	on EX_DATA	do VRDeleteComponent(&me->ret)
                        do VRdisprpform				state start

	on ERROR 	do VRRetrieveOldComponent (&me->ret)
			do VRDeleteComponent(&me->ret)		state HaveError

	on EX_BACK_UP	do VRRetrieveOldComponent (&me->ret)
			do VRDeleteComponent(&me->ret)		state start

	on CLEAR_STACK	do VRRetrieveOldComponent (&me->ret)
			do VRDeleteComponent(&me->ret)		state terminate

	on ELSE							state .

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

				method init

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
action init
{
  me->ReplaceCommand = TRUE;
  me->Product = VR_PIPING;
  /*| call VRCOPiping.init with respect to message */
  status = om$send (	mode     = OM_e_wrt_message,
			msg      = message VRCOPiping.init( type, str_ptr ),
			targetid = my_id);
  as$status( action = RET_STATUS );
  me->ReplaceCommand = TRUE;

/* CR179308634 - Added for livelookup */
  me->first_entry = TRUE; /* needed for status display livelookup */
  me->new_live = TRUE; /* Bring up the livelookup form */
  me->proc_livelook = FALSE;

  me->OldCmpTagId= -1;
  return status;
} /* end init method */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                              METHOD: set_prompt                           */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*-------------------------------------------------------------------------+mi
 * Private Message set_prompt
 *
 * Abstract
 *     It is called at execute keyword and used to change the prompt info
 *     according different conditions.
 *
 * Algorithm
 *     if dimension of me->symb_id = 0,
 *           prompt = "Locate Element(s) to Change Path"
 *     else
 *           prompt = "Identify Next Element/Move On"
 *
 * Status/Return Code
 *     status == OM_S_SUCCESS   if success;
 *
 *------------------------------------------------------------------------mi*/
action set_prompt
{
  IGRchar       buffer[DI_PATH_MAX];


          if(!strcmp(me->szActivePocketMenuName, NOTDEFPKTMNU))
             {
                    ex$message( msgnumb = VR_P_EnterDesignParametersNoMenu,
                            buff    = buffer );
             }
          else
             {
                ex$message( msgnumb = VR_P_EnterDesignParameters,
                            buff    = buffer );
             }
          status =
          om$send(msg      = message CEO.prompt( buffer ),
                  targetid = my_id );
          as$status( action = RET_STATUS );

          *sts = OM_S_SUCCESS;
          goto quit;

} /* end set_prompt */

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
/* CR179308634 - Added for livelookup */
action VRdisprpform
{
     if(me->FormPtr)
       FIf_display(me->FormPtr);
}
action VReraserpform
{
     if(me->FormPtr)
       FIf_erase(me->FormPtr);
}

/* added by alwin for CR179421374 */
action VRCheckForCorrection ( IGRlong *sts )
{
  IGRshort nStatus;
  IGRlong msg;
 
  status = om$send ( msg = message VRGeneric.VRGetStatus( &msg, &nStatus ),
                                targetid = me->CompId.objid,
                                targetos = me->CompId.osnum );
 
  if( nStatus & VR_CORRECTION )
  {
    me->ret = VR_CORRECTION;
  }
 
}

