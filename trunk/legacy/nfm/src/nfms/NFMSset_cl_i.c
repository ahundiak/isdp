#include "machine.h"
#include "MEMstruct.h"
#include "NETdef.h"
#include "DEBUG.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "NFMSextern.h"
#include "NETstruct.h"

 
long NFMSset_client_info ()


{
long status,ret_status;
static char *fname = "NFMSset_client_info";

_NFMSdebug(( fname, "%s\n", "Entering ..."));

ret_status = NFMset_client_info();

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

return (NFM_S_SUCCESS);
}
 
