class specification EMSmigrator (1:0) of Root;
/*
Abstract
    Class to support notification of children for transmigration.

History
    DLB     09/05/91    Modified params to methods, Added EMparent_deleted.
    DLB     08/22/91    Creation.
*/

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"

message EMparent_owned(IGRlong      *EMmsg;
                       OM_S_MESSAGE *messg;
                       OMuword      options);

message EMparent_disowned(IGRlong      *EMmsg;
                          OM_S_MESSAGE *messg;
                          OMuword      options);

reject 
    EMparent_owned,
    EMparent_disowned;

end specification EMSmigrator;
