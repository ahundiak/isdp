#include "machine.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"

long NFMSdelete_catalog (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
long catalog_no;
char **data_ptr;

static char *fname = "NFMSdelete_catalog";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID           : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "catalog name : <%s>\n", data_ptr[1]));

user_id = atol (data_ptr[0]);

ret_status = NFMdelete_catalog (user_id, data_ptr[1], &catalog_no);
_NFMSdebug(( fname, "NFMdelete_catalog <0x%.8x>\n", status));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

return (ret_status);

}


