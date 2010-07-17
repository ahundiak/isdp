/* $Id: VRloadattr.sl,v 1.1.1.1 2001/01/04 21:13:10 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrsketch/VRloadattr.sl
 *
 * Description:
     	This file contains the command object needed to extract 
               attributes from component
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRloadattr.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:10  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  2000/02/24  19:04:24  pinnacle
# Replaced: vrsketch/VRloadattr.sl for:  by lawaddel for route
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
# Revision 1.5  1996/05/23  23:18:30  pinnacle
# Replaced: vrsketch/VRloadattr.sl for:  by hverstee for route240
#
# Revision 1.4  1996/05/14  16:14:42  pinnacle
# Replaced: vrsketch/VRloadattr.sl for:  by hverstee for route240
#
# Revision 1.3  1996/03/04  22:48:34  pinnacle
# Replaced: vrsketch/VRloadattr.sl for:  by hverstee for route240
#
# Revision 1.2  1995/12/08  21:23:58  pinnacle
# Replaced: vrsketch/VRloadattr.sl for:  by r240_int for route240
#
 *
 * History:
	momo : 		02-07-1991   	design date
 *
 *	12/06/95	tlb		Remove VRcmd.h
 *      02/24/00        law             tr179900805-Allow duct and trays to
 *                                      be locatable also.(LC_RIGID_COMP)
 *
 *************************************************************************/

command_string       	VRC_M_CPDParamComp,0,VRCPpDgPFC
synonym			VRC_M_CHDParamComp,1,VRCHVDgPFC
synonym			VRC_M_CRDParamComp,2,VRCTDgPFC
class                	VRloadattr
super_class          	VDB_LOCATE
product_name         	"$ROUTE"
command_table		"route.cmd"


specification

instance
{
  IGRshort	product;
}

implementation

#include "VRmsg.h"
#include "VRdef.h"
#include "VRattr_def.h"
#include "VRact_params.h"
#include "VRprivmacros.h"
#include "AS_status.h"


#define	AS_DEBUG

/**********************************************************/

state_table

#include "VRmsg.h"


state main

   on CMD_TYPE = 0 do	message_key          VR_M_CPDParamComp
                   do   VRSetPpProduct					state VR_P
   on CMD_TYPE = 1 do	message_key          VR_M_CHDParamComp
		   do	VRSetHvProduct				     	state VR_H
   on CMD_TYPE = 2 do	message_key          VR_M_CRDParamComp
		   do	VRSetRwProduct					state VR_R

state VR_P
   locate_class		"VRPiping"					
   on ELSE 		state GetAttr


state VR_H
   locate_class		"VRHvac "
   on ELSE 		state GetAttr


state VR_R
   locate_class		"VRRway"
   on ELSE 		state GetAttr


state GetAttr

   prompt_key		VR_P_IdComp
   dynamics		off
   locate_owner         "LC_RIGID_COMP | LC_REF_OBJECTS"
   accept_key		VR_P_AccReject
   relocate_key		VR_S_CompNotFound
   filter		locate

   on EX_DATA	do have_object		state .

   on EX_BACK_UP or EX_RJT_MOVEON	state .


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action VRSetPpProduct
{
  me->product = VR_PIPING;
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action VRSetHvProduct
{
  me->product = VR_HVAC;
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action VRSetRwProduct
{
  me->product = VR_RWAY;
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action have_object
{
  IGRlong		retcode;
  struct	GRid	LocatedObjectId;
  struct	GRid	LocatedObjectSysParamId;
  struct	GRid	LocatedObjectUserParamId;


  me->ret = MSSUCC;

  /*| object is located */

  LocatedObjectId = me->event1.located_object[0].located_obj;

  /*"loc_obj = %d %d\n", LocatedObjectId.objid, LocatedObjectId.osnum */


	/*====== RETREIVE USER ATTRIBUTES FROM THE COMPONENT ======*/

  status = VR$GetCmpAttributes( 	p_retmsg	= &retcode,
				     	Product		= me->product,
				     	p_ComponentId   = &LocatedObjectId,
				     	p_SysParamId 	= &LocatedObjectSysParamId,
					p_UserParamId	= &LocatedObjectUserParamId,
					p_MdEnv	        = &me->ModuleInfo );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  /*^VRprint_user_attr( &LocatedObjectSysParamId );  */
  /*^VRprint_user_attr( &LocatedObjectUserParamId ); */

	/*====== SET THE USER INTERFACE ======*/
    
  VR$active_params( operation	 = VR_REPLACE,
                    VRproduct    = me->product,
                    update_flag  = VR_UPDATE,
	    	    act_param_id = &LocatedObjectSysParamId,
	    	    status	 = retcode );

  VR$active_params( operation	 = VR_REPLACE,
                    VRproduct    = me->product,
                    mode         = VR_USER_MODE,
                    update_flag  = VR_UPDATE,
	    	    act_param_id = &LocatedObjectUserParamId,
	    	    status	 = retcode );

  return OM_S_SUCCESS;
}
