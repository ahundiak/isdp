#include "machine.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "DEBUG.h"
#include "ERR.h"

long NFMScancel_item_archive_flag (in_list)

MEMptr in_list;
{
long status;
long ret_status;
long user_id;
char **data_ptr;
static char *fname = "NFMScancel_item_archive_flag";

_NFMSdebug(( fname, "%s\n", "Entering ..." ));

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
_NFMSdebug(( fname, "item name    : <%s>\n", data_ptr[2]));
_NFMSdebug(( fname, "item rev     : <%s>\n", data_ptr[3]));

user_id = atol (data_ptr[0]);

ret_status = NFMcancel_item_archive_flag (user_id, data_ptr[1], data_ptr[2], 
		data_ptr[3]);
_NFMSdebug(( fname, "NFMcancel_item_archive <0x%.8x>\n", ret_status ));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

return (NFM_S_SUCCESS);
}


long NFMScancel_item_backup_flag (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
static char *fname = "NFMScancel_item_backup_flag";

_NFMSdebug(( fname, "%s\n", "Entering ..."));

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID           : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "catalog name : <%s>\n", data_ptr[1]));
_NFMSdebug(( fname, "item name    : <%s>\n", data_ptr[2]));
_NFMSdebug(( fname, "item rev     : <%s>\n", data_ptr[3]));

user_id = atol (data_ptr[0]);

ret_status = NFMcancel_item_backup_flag (user_id, data_ptr[1], data_ptr[2], 
		data_ptr[3]);
_NFMSdebug(( fname, "NFMcancel_item_backup <0x%.8x>\n", ret_status ));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

return (ret_status);
}


long NFMScancel_item_restore_flag (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
static char *fname = "NFMScancel_item_restore_flag";

_NFMSdebug(( fname, "%s\n", "Entering ..." ));

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID           : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "catalog name : <%s>\n", data_ptr[1]));
_NFMSdebug(( fname, "item name    : <%s>\n", data_ptr[2]));
_NFMSdebug(( fname, "item rev     : <%s>\n", data_ptr[3]));

user_id = atol (data_ptr[0]);

ret_status = NFMcancel_item_restore_flag (user_id, data_ptr[1], data_ptr[2],
		 data_ptr[3]);
_NFMSdebug(( fname, "NFMcancel_item_restore <0x%.8x>\n", ret_status ));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

if( ret_status != NFM_S_SUCCESS )
    return( ret_status );

return (NFM_S_SUCCESS);
}


long NFMScancel_item_delete_flag (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
static char *fname = "NFMScancel_item_delete_flag";

_NFMSdebug(( fname, "%s\n", "Entering ..." ));

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID           : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "catalog name : <%s>\n", data_ptr[1]));
_NFMSdebug(( fname, "item name    : <%s>\n", data_ptr[2]));
_NFMSdebug(( fname, "item rev     : <%s>\n", data_ptr[3]));

user_id = atol (data_ptr[0]);

ret_status = NFMcancel_item_delete_flag (user_id, data_ptr[1], data_ptr[2], 
		data_ptr[3]);
_NFMSdebug(( fname, "NFMcancel_item_delete <0x%.8x>\n", ret_status ));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

if( ret_status != NFM_S_SUCCESS )
    return( ret_status );

return (NFM_S_SUCCESS);
}




