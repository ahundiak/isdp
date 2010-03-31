/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloopset;

#include "EMS.h"

#define LOOP_INC 10

from EMSloop import EMget_loops;

method EMget_loops(IGRlong *EMmsg;IGRlong option;IGRint *depth;
                   GRobjid **loop_ids;
		   IGRushort **props;IGRint *buf_size,*count)
{
  IGRlong sts;
  OM_S_CHANSELECT loop_channel;
  IGRint  i, loc_depth;
  OMuint loc_count;

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;
  EMerr_hndlr (*depth <= 0, *EMmsg, EMS_E_InvalidArg, wrapup);

  loop_channel.type = OM_e_addr;
  loop_channel.u_sel.addr = &ME.EMSloopset->to_loops;

  *count = 0;
  if(buf_size && !(*buf_size))
   {
     if(loop_ids)
      {
       *loop_ids = (GRobjid *) om$malloc(size=LOOP_INC*sizeof(GRobjid));
       EMerr_hndlr(!(*loop_ids),*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);
      }
     if(props)
      {
       *props = (IGRushort *) om$malloc(size=LOOP_INC*
				sizeof(IGRushort));
       EMerr_hndlr(!props,*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);
      }
     *buf_size = LOOP_INC;
   }

  if (*depth > 0)
    {
    sts = om$get_channel_count (object = me, p_chanselect = &loop_channel,
           count = &loc_count);
    if (!(1&sts)) goto wrapup;
    for (i=0; i<loc_count; i++)
      {
      loc_depth = *depth;
      sts = om$send(msg = message EMSloop.EMget_loops
                         (EMmsg,option,&loc_depth,loop_ids,props,
                          buf_size,count),
                    p_chanselect = &loop_channel,from=i, to=i);
      if( (sts == OM_W_REJECTED_METHOD) ||
          (sts == OM_W_UNKNOWN_MSG)) sts = OM_S_SUCCESS;
      EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_LoopError,wrapup);
      }
    }
  
wrapup:
  EMWRAPUP(*EMmsg,sts,"In EMSloopset.EMget_loops")
  return(sts);

}

end implementation EMSloopset;
