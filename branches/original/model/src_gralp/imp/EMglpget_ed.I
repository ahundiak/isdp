/*
Notes
	Ignore feature loops for getting any edges. I was forced to do this
so that options like 'get connectable edges' do not receive edges belonging
to a feature loop. Ideally this could have been done by having two
options for this message - 'loop type' to which the message should go and edge
type of that loop.
*/
class implementation EMSgraloop;

#include "EMS.h"

method EMget_edges(
        IGRlong        *EMmsg;
        IGRint         tree_depth;
        IGRlong        option;
        struct GRid    **edges;
        IGRint         *array_size;
        IGRint         *num_edges)
{
  *EMmsg = EMS_I_FeatureLoop;
  return(OM_S_SUCCESS);
}

end implementation EMSgraloop;
