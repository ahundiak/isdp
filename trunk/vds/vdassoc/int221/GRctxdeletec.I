/* $Id: GRctxdeletec.I,v 1.1.1.1 2001/01/04 21:07:42 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc/int221 / GRctxdeletec.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: GRctxdeletec.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:42  cvs
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

/*
Name
	GRdeletectx - deletes input context

Synopsis
    	GRdeletectx(msg,env)
	
 	IGRlong	*msg		completion code
	struct GRmd_env *env	environment information.  This 
				information is necessary to 
				delete any graphics objects
				connected to the to_misc 
				channel
Description
	This method deletes the context object

Diagnostics
	The possible return codes values in the msg 
	field are:

	MSSUCC - successful completion
	MSFAIL - error
Notes
	None.
*/

class implementation GRcontext;

/* JLA #include "grimport.h" */
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

from GRgraphics import GRdelete;
from GRlistener import GRnotifylis;

method GRdeletectx ( long *msg; struct GRmd_env *env )
{
  long OMmsg;
  IGRuint  count;

  OM_S_CHANSELECT chan;

  OMmsg = OM_S_SUCCESS;
  *msg = MSSUCC;

  chan.type = OM_e_addr;
  chan.u_sel.addr = &me->to_nested_files;

  OMmsg = om$get_channel_count(objid = my_id,
      p_chanselect = &chan,
      count = &count);

  if ( 1 & OMmsg)
  {
    if (count > 1)
    {
      /* delete contexts nested inside this one */
      OMmsg = om$send(msg = message GRcontext.GRdeletectx(msg,env),
          p_chanselect = &chan,
          from = 1);
    }
    if ( 1 & OMmsg)
    {
      chan.u_sel.addr = &me->to_misc;
/* 
      long mask = GR_DELETED;
      long msg2 = OM_S_SUCCESS;

   JLA 16 NOV 92 restore deletion mechanism as it used to work in 1.4,
   without notification of the delete to the dependent. If not dependent
   are transformed to non associative and the associative behaviour is 
   not found back when reattaching the reference file  

      om$send( msg = message GRlistener.GRnotifylis ( msg, &msg2, &mask, NULL ),
          p_chanselect = &chan );

*/


/* JLA 16 NOV 92 : This GRgraphics.GRdelete on to_misc channel and the root 
   delete to myself seems totaly wrong to me since dependent objects are 
   connected on the to_misc channel .... But it explains why in 1.4.5
   context object are not deleted since sources connected on the 
   notify channel don't understand the message GRgraphics.GRdelete.
   The context element should only be deleted when nothing remains
   connected to them ===> support only element technics.
*/

      OMmsg = om$send(msg = message GRgraphics.GRdelete(msg,env),
          p_chanselect = &chan);

      if (1 & OMmsg & *msg)
      {
        OMmsg = om$send(msg = message Root.delete(count),
            targetid = my_id);
      }
    }
  }
  else
    *msg = MSFAIL;

  return OMmsg;
}

end implementation GRcontext;
