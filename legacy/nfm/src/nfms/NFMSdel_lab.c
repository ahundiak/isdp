#include "machine.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "DEBUG.h"
#include "ERR.h"

long NFMSdelete_label (in_list)

MEMptr in_list;

{
long status;
long ret_status;

static char *fname = "NFMSdelete_label";

ret_status = NFMdelete_label ( in_list );

_NFMSdebug(( fname, "Status -> <0x%.8x>\n", ret_status));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

return (ret_status);
}

