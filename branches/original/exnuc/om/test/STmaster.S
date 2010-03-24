class specification STmaster (1:0) of Root;
#include  "ST.h"
#include  "OMerrordef.h"

instance STmaster
{
  variable  OM_S_OBJID    objects[];
  variable  char          names[];
};

message   go ();
message   control ();

end specification STmaster;

