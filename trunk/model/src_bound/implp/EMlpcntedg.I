/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloop;

#include "EMS.h"
method EMcount_edges(IGRlong *EMmsg, option; IGRint *count)
{
  IGRlong sts;
  OMuint num_inner;
  OM_S_CHANSELECT to_edges, to_inner;

  *EMmsg = EMS_S_Success;
  sts = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
  if(! (1 & sts)) goto wrapup;
  sts = EMmake_chanselect (EMSloop_to_inner, &to_inner);
  if(! (1 & sts)) goto wrapup;
  sts = om$send(msg = message EMSboundary.EMcount_edges(EMmsg, option, count),
		p_chanselect = &to_edges);
  if(! (1 & *EMmsg & sts)) goto wrapup;
  sts = om$get_channel_count(object = me, p_chanselect = &to_inner,
			     count = &num_inner);
  if(! (1 & sts)) goto wrapup;
  if(num_inner)
    sts = om$send(msg = message EMSboundary.EMcount_edges(EMmsg,option,count),
		  p_chanselect = &to_edges);

wrapup:
  EMWRAPUP(*EMmsg, sts, "In EMSloop.EMcount_edges")
  return(OM_S_SUCCESS);
}

end implementation EMSloop;
