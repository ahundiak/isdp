/* $Id: SMCmdPusHl.sl,v 1.1.1.1 2001/01/04 21:09:00 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdpocket/cmd / SMCmdPusHl.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCmdPusHl.sl,v $
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
# Revision 1.2  1995/08/10  13:13:42  pinnacle
# Replaced: vdpocket/cmd/SMCmdPusHl.sl for:  by yzhu for vds.240
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

/*                File SMCmdPusHl.sl                        */
/*                                                      */
/*  Author: Jean Jasinczuk(ISDC)                        */
/*  Creation date: 2-11-92                              */
/*  Push the active hull on the stack                   */

command_string  SMC_M_PshHl,0,SMPsHl
class           SMCmdPusHl
super_class     VDS_LOCATE	       
product_name    "$VDS"
command_table   "sman.cmd"

specification

#include "exmacros.h"

implementation

#include "VDmsg.h"


from SMglob import SMGetConnected;
from GRcontext import GRgetmodule_env;            
from GRvg import GRkeypoint;            

state_table

state start
  on CMD_TYPE = 0 do SMPushHull state terminate

action SMPushHull
{
  IGRlong msg;
  struct GRid     hull;
  struct GRmd_env mod_env;
  struct GRevent  event;
  IGRlong size;
  
  if(ex$is_cmd_stack_empty()){
    ex$message(msgnumb = VD_E_CmdStkEpt);
    *sts = OM_E_ABORT; return OM_S_SUCCESS; }

  if(!SMGetActHull(NULL,NULL,&mod_env,&hull))
   {*sts = OM_E_ABORT; return OM_S_SUCCESS; }
  
  event.response = EX_OBJID; 
  event.num_id = 1;
  event.num_val  = 0;
  event.located_object[0].located_obj = hull;
  event.located_object[0].module_info = mod_env;

  size = sizeof(struct GRevent) - ( 2 * sizeof (IGRlong)) ;

  status = ex$putque(msg      = &msg,
		     response = &event.response,
		     byte     = &size,
		     buffer   = (IGRchar *) &event.event);
  if(!(status & msg & 1)) {printf("Error putque\n");}
  *sts = OM_S_SUCCESS;
  goto quit;
}





