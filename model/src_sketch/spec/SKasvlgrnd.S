/*
  DESCRIPTION

    This class of objects implement the ground constraint for values
    defined in the expression system. This class allows their use within
    the SKmgr-system as read-only variables.
*/

class specification SKasvlgrnd (2:0) of NDnodein, SKground;

#include "nddef.h"
#include "asbox.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#ifndef BASE_EMS
message SKinit_assocvl_ground (IGRlong *msg; IGRushort options;
                               struct GRid *expression_id;
                               IGRchar *expression_name;
                               GRobjid mgrobj;
                               IGRchar *moreinfo;
                               GRobjid *vgval);

override
  debug,
  NDget_objects, NDupdate;

reject
  SKinit;
#endif
end specification SKasvlgrnd;

