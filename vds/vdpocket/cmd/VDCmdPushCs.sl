/* $Id: VDCmdPushCs.sl,v 1.1.1.1 2001/01/04 21:09:00 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdpocket/cmd / VDCmdPushCs.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdPushCs.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:00  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1995/09/26  21:21:48  pinnacle
# Replaced: vdpocket/cmd/VDCmdPushCs.sl for:  by sundar for vds.240
#
# Revision 1.2  1995/08/10  13:13:28  pinnacle
# Replaced: vdpocket/cmd/VDCmdPushCs.sl for:  by yzhu for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 VDCmdPushCs.sl
 Put in event queue the referenciel associated to an Equipment 

 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
command_string		VDC_M_PshEqCs,0,VDPushCs
class			VDCmdPushCs
super_class		CEO_LOCATE
product_name		"$VDS"
command_table		"vds.cmd"
start_state		start

specification

instance

{
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
#include "VDSequipdef.h"
#include "VDmsg.h"


/* ======================================================================== */
state_table

#include    "VDmsg.h"

state start
	message_key     VD_M_PshEqCs
	prompt_key  	VD_P_IdEquip
	locate_class	"VDequipment"
	locate_owner   	"LC_RIGID_OWNER | LC_FLEX_COMP"
 	filter		locate

	on EX_DATA or EX_STRING or EX_OBJID
	   do VDPushCsOnQueue	
		on ERROR
		    do status_key VD_E_ErrEqCs	state terminate	
								state terminate

/* ======================================================================== */
action VDPushCsOnQueue
{
  IGRlong		msg;
  IGRlong		size;
  IGRint		info, response;
  struct GRid		EquipId, RefId;

  EquipId = me->event1.located_object[0].located_obj;

  status = dp$erase_hilite ( msg   = &msg,
                             osnum = me->ModuleInfo.md_id.osnum);

          
  status = VDGetCsFromEq(&EquipId, &RefId, &info);
  if(!(status & 1)) {
	me->ret= OM_E_ABORT;
	goto quit;
  }

  me->event1.num_id   = 1;
  me->event1.num_val  = 0;
  me->event1.response = 0;
  me->event1.subtype  = GRst_LOCATE;
  me->event1.located_object[0].located_obj = RefId;
  me->event1.located_object[0].module_info = me->ModuleInfo;

  response = EX_OBJID;
 
  size = sizeof(struct GRevent );

  status = ex$putque(	msg      = &msg,
			response = &response,
     	 		byte     = &size,
     	 		buffer   = (IGRchar *)&me->event1.event);
  as$status();

  return OM_S_SUCCESS;
}

