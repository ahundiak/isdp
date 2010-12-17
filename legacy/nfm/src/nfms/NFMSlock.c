#include "machine.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"

long NFMSlock_item (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
static char *fname = "NFMSlock_item";

_NFMSdebug(( fname, "%s\n", "Entering ..."));

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID           : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "catalog name : <%s>\n", data_ptr[1]));
_NFMSdebug(( fname, "item name    : <%s>\n", data_ptr[2]));
_NFMSdebug(( fname, "item rev     : <%s>\n", data_ptr[3]));

user_id = atol (data_ptr[0]);

ret_status = NFMlock_item (user_id, data_ptr[1], data_ptr[2], data_ptr[3]);
_NFMSdebug(( fname, "NFMlock_item  <0x%.8x>\n", ret_status));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

return (ret_status);
}


long NFMSunlock_item (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
static char *fname = "NFMSunlock_item";

_NFMSdebug(( fname, "%s\n", "Entering ..."));

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID           : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "catalog name : <%s>\n", data_ptr[1]));
_NFMSdebug(( fname, "item name    : <%s>\n", data_ptr[2]));
_NFMSdebug(( fname, "item rev     : <%s>\n", data_ptr[3]));

user_id = atol (data_ptr[0]);

ret_status = NFMunlock_item (user_id, data_ptr[1], data_ptr[2], data_ptr[3]);
_NFMSdebug(( fname, "NFMunlock_item <0x%.8x>\n", ret_status));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

return (ret_status);
}



