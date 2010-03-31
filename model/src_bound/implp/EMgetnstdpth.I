/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method determines whether the input loop is nested inside the
  loop which receives this message.If it is nested then the enclosing loop
  sends down the input loop to its children,if it has any, to further
  determine the nesting depth and "width" 

History
				
Return Code
   EMS_S_Success		The input loop was nested.
   EMS_I_OutOfBounds		The input loop was not nested.
   EMS_I_Ambiguous		The input loop was construed as coincident
				with this one. The nesting is based on
				loop types as described above.
   EMS_I_Open			The message was sent to an open loop, so
				no loop can be nested inside it.

*/


class implementation EMSloop;

#include "EMS.h"
#include "emsdef.h"
#include "EMSbnddef.h"
#include "EMSopt.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsmacros.h"
#include "OMmacros.h"
#include "emsmacros.h"
#include "timerdef.h"

#define UNKNOWN_NESTING -1
#define BUF_SIZE	20

from EMSedge import EMgetbounds,EMptatpr,EMendpts,EMgetpygeom, 
			EMget_props;

extern IGRboolean _use_timers;

method EMget_nest_depth(IGRlong *EMmsg;
                   GRobjid *loop_id;
                   IGRboolean *found;
                   IGRint *loop_count;
                   IGRint *depth;
                   IGRint *width)
{

     IGRlong     		sts,rc;
     OMuint			count;
     IGRint      		ii;
     OMuint                     has_it;
     OM_S_CHANSELECT 		to_edges, to_inner;
     OM_S_OBJECT_LINKAGE         *loop_loop_link = NULL;


      *EMmsg = EMS_S_Success;
       sts = OM_S_SUCCESS;

      sts = EMmake_chanselect (EMSloop_to_inner, &to_inner);
      if(!(1&sts)) goto wrapup;

       sts = om$get_channel_count
                                 (objid = my_id,
                                 p_chanselect = &to_inner,
                                 count = &has_it);

       EMerr_hndlr (!(1&sts) && !has_it, *EMmsg, EMS_E_Fail,wrapup);

       loop_loop_link = (OM_S_OBJECT_LINKAGE *)
                        om$malloc(size = has_it * sizeof(OM_S_OBJECT_LINKAGE));

       sts = om$get_channel_objects
                                 (objid = my_id,
                                 p_chanselect = &to_inner,
                                 size = has_it,
                                 list = loop_loop_link,
                                 count = &has_it);
       EMerr_hndlr (!(1&sts) && !has_it, *EMmsg, EMS_E_Fail,wrapup);

       *loop_count=has_it;
       for(ii=0;ii<has_it;ii++)
         {
          if(loop_loop_link[ii].S_objid == *loop_id)
            {
             *width = ii;
             (*depth)++;
             goto wrapup;
            }
          }

       for(ii=0;ii<has_it;ii++)
         {
                sts = om$send(msg = message EMSloop.EMget_nest_depth
				(EMmsg,
                                 &loop_loop_link[ii].S_objid,
                                 found,
                                 loop_count,
                                 depth,
                                 width),
                             p_chanselect = &to_inner);
                EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
         }

wrapup:
      if(loop_loop_link)
         om$dealloc(ptr = loop_loop_link);

    EMWRAPUP(*EMmsg,sts,"In EMSloop.EMnesting")
    return(sts);

}
    
end implementation EMSloop;
