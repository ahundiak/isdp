class specification STgene (1:0) of Root;
#include  "ST.h"
#include  "OMerrordef.h"
#include  "OMmacros.h"
#define DBME(rtn, name, vla) \
{ \
  int *chunk;\
  chunk = (int*) (me - 8);\
  printf ("    <ST%c%s. me: %x, (-8): %x, vla: %x, my_id: %5d>\n", \
    (rtn), (name), me, *chunk, (vla), my_id);\
}
extern	char*	OM_Gp_sheapBase;

instance STgene
{
  int		size;
};

/* generic message area */


message init (int size);
message	doit (int varyAmount);
message measure ();

end specification STgene;

