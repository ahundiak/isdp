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

History

    ??/??/?? - ??? - Creation.
    06/29/93 - WBC - Sending the message GRnotifylis out the to_misc channel
                     to notify those objects that the context's reference
                     file has been detached.
*/

class implementation GRcontext;

#include "grimport.h"
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
      long mask = GR_REFFILE_DETACHED;
      long msg2 = OM_S_SUCCESS;

      chan.u_sel.addr = &me->to_misc;

/* 
   JLA 16 NOV 92 restore deletion mechanism as it used to work in 1.4,
   without notification of the delete to the dependent. If not dependent
   are transformed to non associative and the associative behaviour is 
   not found back when reattaching the reference file  

   WBC 29 JUN 93:  Notifying the dependents that the reference file has
   been detached (instead of indicating a parent was deleted) so that they
   can take the appropriate action.
*/

      om$send( msg = message GRlistener.GRnotifylis(msg, &msg2, &mask, NULL),
          p_chanselect = &chan );

      OMmsg = om$send(msg = message GRgraphics.GRdelete(msg,env),
          p_chanselect = &chan);

/* To not delete the context if error message when sending GRdelete on the
   misc channel allows to keep context when reference file detached 
   if ASsourcein connected to it. Please don't modify JLA nov 92
*/
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
