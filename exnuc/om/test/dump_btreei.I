class implementation dump_btree;

#include "OMDB.h"
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMintprims.h"

extern int DB_dump_btree();

method dump( )

{
OM_S_RIP rip;
long *root_page;

root_page = DEREF(long,ME.OMbtree->objid,rip);
DB_dump_btree(root_page,4,BTREE_INTEGER);

return(OM_S_SUCCESS);
}


end implementation dump_btree;
