/* $Id: VRPidPasCmd.sl,v 1.1.1.1 2001/01/04 21:12:43 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrco/VRPidPasCmd.sl
 *
 * Description:
 *	Place crossing symbols in P&ID.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRPidPasCmd.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:43  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.3  1997/10/25  19:17:48  pinnacle
# Replaced: vrco/VRPidPasCmd.sl for:  by onayragu for route
#
# Revision 1.3  1997/10/24  21:08:24  pinnacle
# Replaced: vrco/VRPidPasCmd.sl for:  by kddinov for route
#
# Revision 1.2  1996/11/14  22:35:28  pinnacle
# Replaced: vrco/VRPidPasCmd.sl for:  by hverstee for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.6  1996/03/05  22:05:18  pinnacle
# Replaced: vrco/VRPidPasCmd.sl for:  by hverstee for route240
#
# Revision 1.5  1996/03/04  18:14:10  pinnacle
# Replaced: vrco/VRPidPasCmd.sl for:  by hverstee for route240
#
# Revision 1.4  1996/01/16  21:17:06  pinnacle
# Replaced: vrco/VRPidPasCmd.sl for:  by r240_int for route240
#
# Revision 1.3  1995/12/08  21:20:12  pinnacle
# Replaced: vrco/VRPidPasCmd.sl for:  by r240_int for route240
#
 *
 * History:
 *	Creation : B.D (isdc Paris)		06-Jan-1993
 *
 *	12/06/95	tlb		Remove VRcmd.h
 *	01/15/96	tlb	Add VX_FIproto.h, prototypes
 *
 *************************************************************************/

command_string	VRC_M_PlPidPass, 0, VRPlPidPas
class		VRPidPasCmd
super_class	VRCOProduct
product_name	"$ROUTE"
command_table	"route.cmd"
start_state	start

form "VRPidPass", 0, 0,"-1", "-1"

specification

instance

{
}

implementation

#include <stdio.h>
#include "AS_status.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VRPid.h"
#include "VRutildef.h"
#include "VRutilmacros.h"
#include "vrinit_pto.h"
#include "VRcmd.h"
#include "VRPid.h"

%safe
#include "VX_FIproto.h"
%endsafe

#define AS_DEBUG
#define VR_SPACE_CLKLST		11
#define VR_BRIDGE_CLKLST	13
#define VR_SCALE_FLD		17

state_table

#include "VRcompdef.h"
#include "VRmsg.h"

/* ======================================================================== */

state start

	on ELSE do VRInitInstance(&me->ret)		
		do VRTestRep(&me->ret)
			on RETURN_CODE = FALSE	state terminate
		state GET_OBJ

/* ======================================================================== */

state GET_OBJ

	prompt_key		VR_P_IdComp
	accept_key		VR_P_EnterInsertReject
	status			""
	dynamics		off
	locate_eligible		"VRPComp, VRPCComp"
   	locate_owner         	"LC_RIGID_COMP"
	filter			locate

	on EX_BACK_UP or EX_RJT_MOVEON				state start

 	on EX_DATA 	do VRGetLocatedObject ( &me->ret )
		on RETURN_CODE = VRNOT_OK			state .
			do VRSetPassInfo (&me->ret)	 	
		 	do VREvaluateComp(&me->ret)
		 	do VRGetCompMatrix(&me->ret)
			do VRRotateComponent(&me->ret)		state Orient

/* ======================================================================== */

state Orient
	
	prompt_key		VR_P_AcceptOrientationReverse
	dynamics	off
	filter		wfi
	

	on EX_DATA	do VRInsertComponent (&me->ret)		state start

	on EX_RJT_MOVEON 
			do VRRotateQuadrant(&me->ret)		state .

/* ======================================================================== */

action init
{
  /*| call VDB_LOCATE.init with respect to message */
  status = om$send ( mode     = OM_e_wrt_message,
		  msg      = message VDB_LOCATE.init( type, str_ptr ),
		  targetid = my_id);
  as$status();
  if (me->VDB_terminated) return (status);

  /*| call VRinit_products to load the macro object spaces */
  status = VRinit_products();
  as$status( action = RET_STATUS );

  me->CmpId.objid = NULL_OBJID;

  /*"Type of activated command : %d\n", type */

  me->bPktInquired   = FALSE;
  me->Product 	     = VR_PIPING;
  me->FormUser 	     = NULL;
  me->FormPtr 	     = me->forms[0].form_ptr;

  me->ActiveMessageField    = 0;
  me->ReplaceCommand        = FALSE;
  me->MissParamId.objid     = NULL_OBJID;
 
  FIf_display( me->FormPtr );

  return OM_S_SUCCESS;

} /* end init method */
/***************************************************************************/

action VRTestRep
{

  me->ret = OM_S_SUCCESS; 

  if ( !bVR_IS_PID_ACTIVE ) { 
     me->ret = FALSE ;
     UI_status("Active representation must be P&ID.");
     goto wrapup;
  }

wrapup:

  return OM_S_SUCCESS; 

}
/***************************************************************************/

action VRSetPassInfo
{
	IGRlong		retmsg;
	IGRint		State;
	IGRint		sel_flag,r_pos;

	/* ---- Init itemNum ---- */
	me->CmpItemNum = VR_PID_CROSS;

	/* ---------------------------------------------- */
	/* -- From The Form => Symbol's caracteristics -- */
	/* ---------------------------------------------- */

	/* -- Get macro name -- */

	FIg_get_state( me->FormPtr, VR_SPACE_CLKLST, &State );

	if (State)	strcpy(me->CmpAABBCCcode, VRPID_N_SPACE_MACRO );
	else		strcpy(me->CmpAABBCCcode, VRPID_N_BRIDGE_MACRO );

	/* -- Get Scale (should be length?) -- */
	{
	struct ACrg_coll	Attr;

	strcpy (Attr.name, VR_N_PID_SCALE_DB );
	Attr.desc.type = AC_ATTRIB_DOUBLE;

	FIfld_get_value(me->FormPtr, VR_SCALE_FLD, 0, 0,
			&Attr.desc.value.att_exp, &sel_flag, &r_pos );
	
	/* -- Update the System collection -- */

	status =
	VR$ModifyCollection ( 	p_msg 			= &retmsg,
				Operation 		= VR_UPDATE_COLL,
				p_ParamsListToModify 	= &Attr,
				NbParamsToModify 	= 1,
				p_OutputCollectionId 	= &me->SysParamId );
	as$status();

	}/* end update the System collection */

return OM_S_SUCCESS;
}

action  VRDisplayMessage (IGRlong   *ret)
{
  *ret = MSSUCC;

  ex$message( field   = MESSAGE_FIELD,
              msgnumb = VRC_M_PlPidPass);

  return OM_S_SUCCESS;
}

