/* $Id: VRRReplace.sl,v 1.2 2001/01/11 23:52:06 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrco/VRRReplace.sl
 *
 * Description:
 *	Replace Race Way Component state language file.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRRReplace.sl,v $
 *	Revision 1.2  2001/01/11 23:52:06  anand
 *	SP merge
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:43  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  2000/04/27  20:02:34  pinnacle
# Created: route/vrco/VRRReplace.sl by apazhani for Service Pack
#
# Revision 1.3  2000/03/13  20:31:34  pinnacle
# Replaced: vrco/VRRReplace.sl for:  by apazhani for route
#
# Revision 1.2  1999/04/19  09:31:00  pinnacle
# Replaced: vrco/VRRReplace.sl for:  by apazhani for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.2  1997/02/13  22:39:32  pinnacle
# Replaced: vrco/VRRReplace.sl for:  by lawaddel for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.5  1996/04/25  22:15:26  pinnacle
# Replaced: vrco/VRRReplace.sl for:  by ashankar for route240
#
# Revision 1.4  1996/03/05  22:10:20  pinnacle
# Replaced: vrco/VRRReplace.sl for:  by hverstee for route240
#
# Revision 1.3  1995/12/08  21:20:46  pinnacle
# Replaced: vrco/VRRReplace.sl for:  by r240_int for route240
#
 *
 * History:
 * 	Creation : O.N (isdc Paris)		05-04-1991
 *
 *	CHANGE HISTORY: Karine  (isdc Paris)	12-02-1992 
		 	Karine  (isdc Paris)	20-12-1992 
 *
 *	12/06/95	tlb		Remove VRcmd.h
 *      04/19/99        Alwin           The form should not be displayed unless
 *                                      and until the Object is located and
 *                                      found its a valid object. So, I'm
 *                                      changing the third argument to zero.
 *                                      And the form will be displayed in the
 *                                      VRLoadForm() method. Alwin
 *	03/13/2000	Alwin		Removed the option to accept/backup 
 *					after running the form.  As per request
 *					CR179900944
 *	04/27/2000	Alwin		A New state COPY_GRAPHIC_ATTRS has
 *					been added to copy Grpahical
 *					attributes, for CR179900999.
 *************************************************************************/

command_string		VRC_M_RRepComp, 0, VRRpRwCm
class			VRRReplace
super_class		VRCORway
/* product_name		"$SPXR" */
product_name		"$ROUTE"
command_table		"route.cmd"


form "VRRwCmDsPara",0,0,"-1","-1"
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

#define AS_DEBUG

state_table

#include "VRcompdef.h"
#include "VRmsg.h"
#include "ECmsg.h"
#include "VRco.h"
#include "VRsketchdef.h"

#define VRCOPY_GRAPHIC_ATTRS 1000

state *
on  EX_DATA.GRst_PERPEND_FROM 			state HaveError
on  EX_DATA.GRst_ANGLE_FROM                     state HaveError
on  EX_DATA.GRst_TANGENT_FROM                   state HaveError
on  EX_DATA.GRst_PERPEND_TO                     state HaveError
on  EX_DATA.GRst_ANGLE_TO                       state HaveError

/* ======================================================================== */

state start

	on ELSE do VRDefaultPocketMenu (&me->ret)
		do VRInitInstance(&me->ret)			state GET_OBJ

/* ======================================================================== */
state GET_OBJ

	message_key		VR_M_RRepComp
	prompt_key		VR_P_IdCompToReplace
	status_key		EMS_I_InvkStatusFrm
	accept_key    		VR_P_AccRejectComponent
	dynamics		off
	locate_eligible		"VRRComp,VRRCComp"
   	locate_owner   		"LC_RIGID_COMP"
	filter			locate

	on EX_BACK_UP or EX_RJT_MOVEON				state .

	on EX_DATA	do VRGetObject ( &me->ret )
		on RETURN_CODE = VRNOT_OK			state .
			do VRChangeActivePocketMenu (&me->ret)
			do VRSetUserFlag ( 0 )
			do VRLoadForm ( &me->ret )		state ST_FORM

	on EX_FORM_FINISHED    					state .

/* ======================================================================== */

state ST_FORM

	message_key		VR_M_RRepComp
	prompt_key 		VR_P_EnterDesignParameters
	filter			wfi

	on EX_RESET or EX_RJT_MOVEON				state .

	on EX_BACK_UP 						state -

	on ERROR						state HaveError

	on EX_FORM_FINISHED
		do VRCopyReturnCode (&me->ret)
		on RETURN_CODE = VRALL_OK
			do VREvaluateComp (&me->ret)
			on RETURN_CODE = VR_NOT_VALID			
			   do VRRetrieveLocatedContext(&me->ret)	state .
			do VRGetUserFlag (&me->ret)
			on RETURN_CODE = VRNOT_OK
			   do VRSetUserFlag ( 1 )
			   do VRUpdateForm (&me->ret) 		state .
			do VRGetCompMatrix(&me->ret)
			do VRChangeComponent (&me->ret)
			on RETURN_CODE = VRNOT_OK			state .
			on ERROR		
			  do status_key VR_S_InvalidInput		state .
			do VRRotateComponent(&me->ret)
			do VRDeleteComponent(&me->ret)		state start /*state ACC_PE*/
		on RETURN_CODE	= VRLOC_CMP				state LOC_CMP
		on RETURN_CODE	= VRCOPY_GRAPHIC_ATTRS	state COPY_GRAPHIC_ATTRS
		on  RETURN_CODE = EX_FORM_ERASE			state .
		state .

	on  EX_STRING or EX_CHAR 
			do VRGetAABBCCCode (&me->ret)	 	
		on RETURN_CODE = MSFAIL
		    	do status_key  VR_S_InvalidAABBCCcode	state .
			do VRLoadForm(&me->ret)			state .

/* ======================================================================== */

/* This state has been added to Copy the Missing/Graphical attributes from
another component of similar nature ( same macro name ). CR179900999 Alwin */

state COPY_GRAPHIC_ATTRS

    message			"Copy Graphical Attributes from Component"
    prompt_key      VR_P_IdComp
    accept_key      VR_P_AccRejectComponent
    dynamics        off
    locate_eligible     "VRRComp,VRRCComp "
    locate_owner            "LC_RIGID_COMP | LC_REF_OBJECTS | LC_NO_REF_HEADER"
    filter          locate

    on EX_BACK_UP                       state -

    on EX_DATA  do VRCopyComponentAttr (&me->ret)   state -
    on ERROR                        state HaveError

    on  EX_RJT_MOVEON or EX_RESET               state -

    on EX_FORM_FINISHED                 state .


/* ======================================================================== */


state LOC_CMP

	message_key		VR_M_CPDParamComp
	prompt_key		VR_P_IdComp
	accept_key		VR_P_AccRejectComponent
	dynamics		off
	locate_eligible		"VRRComp,VRRCComp "
   	locate_owner         	"LC_RIGID_COMP | LC_REF_OBJECTS | LC_NO_REF_HEADER"
	filter			locate

	on EX_BACK_UP 						state -

	on EX_DATA	do VRCopyComponentAttr (&me->ret)	state -	
	on ERROR						state HaveError

	on  EX_RJT_MOVEON or EX_RESET				state -	

	on EX_FORM_FINISHED					state .


/* ======================================================================== */

state HaveError
   
	status_key  		VR_S_InvDataType

	on ELSE							state -

/* ======================================================================== */

/* This piece of code won't be executed from now on, as per request
CR179900944. Instead of calling this state, the command would call 
VRDeleteComponent method and direct the contrl to start. Alwin */
state ACC_PE

	message_key		VR_M_RRepComp
	prompt_key		VR_P_AccBackupToUndo
	filter			wfi

	on EX_DATA	do VRDeleteComponent(&me->ret)		state start

	on ERROR						state HaveError

	on EX_BACK_UP 	do VRRetrieveOldComponent (&me->ret)	
			do VRDeleteComponent(&me->ret)		state start

	on ELSE							state .

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

				method VRInitInstance (law 19-12-96)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
action VRInitInstance
{
  status = OM_S_SUCCESS;

  /*| call VRCORway.init with respect to message */
  status = om$send (    mode     = OM_e_wrt_message,
                        msg      = message VRCORway.VRInitInstance(&me->ret),
                        targetid = my_id);
   if(me->Product == VR_RWAY)
   {
      FIg_erase( me->FormPtr, LABRAIR_FLOW );
      FIg_erase( me->FormPtr, RAIR_FLOW );
      FIg_erase( me->FormPtr, LABREQUI_DIA );
      FIg_erase( me->FormPtr, REQUI_DIA );
   }
  return status;
}
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

				method init ( momo 26-03-1992 )

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action init
{
  me->ReplaceCommand = TRUE;
  me->Product = VR_RWAY;
  /*| call VRCORway.init with respect to message */
  status = om$send (	mode     = OM_e_wrt_message,
			msg      = message VRCORway.init( type, str_ptr ),
			targetid = my_id);
  as$status( action = RET_STATUS );
  me->ReplaceCommand = TRUE;
  return status;
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
