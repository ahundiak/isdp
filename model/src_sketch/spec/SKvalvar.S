class specification SKvalvar (2:0) of expression, SKvariable;

#include "nddef.h"
#include "asbox.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#ifndef BASE_EMS
message SKgetname (IGRlong *msg; IGRushort opts; IGRchar *name);


override
  debug,
  NDget_objects, NDupdate,
  SKputvar,  SKgetvarlist, SKinit;

#endif

override

  SKgetvar;

end specification SKvalvar;
