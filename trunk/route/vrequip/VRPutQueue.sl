/* $Id: VRPutQueue.sl,v 1.1.1.1 2001/01/04 21:12:51 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrequip/VRPutQueue.sl
 *
 * Description:
 *	Put in event queue the referenciel associated to an Equipment
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRPutQueue.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:51  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.7  1996/03/28  23:57:26  pinnacle
# Replaced: vrequip/VRPutQueue.sl for:  by hverstee for route240
#
# Revision 1.6  1996/03/04  21:13:52  pinnacle
# Replaced: vrequip/VRPutQueue.sl for:  by hverstee for route240
#
# Revision 1.5  1996/02/27  07:20:46  pinnacle
# Replaced: vrequip/VRPutQueue.sl for:  by ashankar for route240
#
# Revision 1.4  1996/01/30  10:55:58  pinnacle
# Replaced: vrequip/VRPutQueue.sl for:  by ashankar for route240
#
# Revision 1.3  1995/12/08  21:21:52  pinnacle
# Replaced: vrequip/VRPutQueue.sl for:  by r240_int for route240
#
 *
 * History:
 *	Creation : Karine Barbette (isdc Paris)		18-03-1992
 *
 *	12/06/95	tlb		Remove VRcmd.h
 *************************************************************************/

command_string		VRC_M_PutRefEventQueue,0,VRPutRefQu
class			VRPutQueue
super_class		VDB_LOCATE
product_name		"$ROUTE"
command_table		"route.cmd"
start_state		start

specification

instance

{
  long	stack_empty;
}

implementation

#include <stdio.h>
#include "AS_status.h"
#include "godef.h"
#include "gr.h"
#include "igrdp.h"
#include "griodef.h"
#include "grio.h"
#include "igr.h"
#include "go.h"
#include "ex.h"
#include "exmacros.h"
#include "dpmacros.h"

from	VREquipment	import	VRGetRefId;
from	NDnode		import	ASreturn_go;

/* ======================================================================== */
state_table

#include "VRmsg.h"

at init do set_instance

state start
	execute check_cmd_stack
	  on SUCCESS			state realstate
           on ELSE	                state emptystk

state emptystk

    	status_key VR_E_CmdStkEpt

        on ELSE
	   state my_xxterm

state realstate
	prompt_key			VR_P_SelRouteEquip
	locate_eligible		"VREquipment"
	locate_owner         	"LC_RIGID_OWNER | LC_FLEX_COMP"
 	filter			locate

	on EX_DATA	do VRSetRefOnQueue		state my_xxterm

        on ELSE
	state my_xxterm

state my_xxterm

        on ELSE
            state terminate

/* ======================================================================== */

action VRSetRefOnQueue
{
  IGRlong		msg;
  IGRlong		size;
  IGRint		response;
  struct GRid		EquipId, RefId, GraphicId;
	
  EquipId = me->event1.located_object[0].located_obj;

  status = dp$erase_hilite ( msg   = &msg,
                             osnum = me->ModuleInfo.md_id.osnum);

  status =
  om$send( msg      = message VREquipment.VRGetRefId( &msg, &RefId ),
	   targetid = EquipId.objid,
	   targetos = EquipId.osnum );

  status =
  om$send( msg      = message NDnode.ASreturn_go( &GraphicId, NULL, NULL),
	   targetid = RefId.objid,
	   targetos = RefId.osnum);
  as$status();

  me->event1.num_id   = 1;
  me->event1.num_val  = 0;
  me->event1.response = 0;
  me->event1.subtype  = GRst_LOCATE;
  me->event1.located_object[0].located_obj = GraphicId;
  me->event1.located_object[0].module_info = me->ModuleInfo;

  response = EX_OBJID;
 
  size = sizeof(struct GRevent );

  status = ex$putque(	msg      = &msg,
			response = &response,
     	 		byte     = &size,
     	 		buffer   = (IGRchar *)&me->event1.event);
  as$status();

  goto quit;
}

action check_cmd_stack
{
   status = OM_S_SUCCESS;
   *sts = me->stack_empty ? MSFAIL : MSSUCC;

   goto quit;
}

action set_instance
{
   status = OM_S_SUCCESS;

   me->stack_empty = ex$is_cmd_stack_empty() ?  TRUE : FALSE;
   *sts = MSSUCC;

   goto quit;
}
