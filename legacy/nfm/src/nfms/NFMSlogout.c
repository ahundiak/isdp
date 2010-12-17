#include "machine.h"
#include "MEMstruct.h"
#include "NETdef.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "ERR.h"

long NFMSlogout (in_list)

MEMptr in_list;
{
long   status;
long   ret_status;

static char *fname = "NFMSlogout";

ret_status = NFMlogoff ();
_NFMSdebug(( fname, "NFMlogoff <0x%.8x>\n", ret_status));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

if( ret_status != NFM_S_SUCCESS )
    return( ret_status);

return (NFM_S_SUCCESS);

}

