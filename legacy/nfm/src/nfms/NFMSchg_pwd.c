#include "machine.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "DEBUG.h"
#include "ERR.h"

long NFMSchange_storage_area_passwd (in_list)
MEMptr in_list;
{

long status;
long ret_status;
long user_id;
char **data_ptr;

static char *fname = "NFMSchange_storage_area_passwd";

status = MEMbuild_array (in_list);
if( status != MEM_S_SUCCESS )
{
    _NFMSdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
}
data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID           : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "storage name : <%s>\n", data_ptr[1]));
_NFMSdebug(( fname, "old passwd   : <%s>\n", data_ptr[2]));
_NFMSdebug(( fname, "new passwd   : <%s>\n", data_ptr[3]));

user_id = atol (data_ptr[0]);

ret_status = NFMchange_storage_area_passwd (user_id, data_ptr[1], data_ptr[2],
                                        data_ptr[3]);
_NFMSdebug(( fname, "NFMchange_storage_area_passwd <0x%.8x>\n", ret_status));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

return (ret_status);
}

long NFMSchange_user_passwd (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;

static char *fname = "NFMSchange_user_passwd";

status = MEMbuild_array (in_list);
if( status != MEM_S_SUCCESS )
{
    _NFMSdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
}
data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID         : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "user name  : <%s>\n", data_ptr[1]));
_NFMSdebug(( fname, "old passwd : <%s>\n", data_ptr[2]));
_NFMSdebug(( fname, "new passwd : <%s>\n", data_ptr[3]));

user_id = atol (data_ptr[0]);

ret_status = NFMchange_user_passwd (user_id, data_ptr[1], data_ptr[2], 
				    data_ptr[3]);
_NFMSdebug(( fname, "NFMchange_user_passwd <0x%.8x>\n", ret_status));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

return (ret_status);
}

long NFMSchange_working_area_passwd (in_list)
MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;

static char *fname = "NFMSchange_storage_area_passwd";

status = MEMbuild_array (in_list);
if( status != MEM_S_SUCCESS )
{
    _NFMSdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
    ERRload_struct( NFM, NFM_E_MEM,NULL, NULL );
    return( NFM_E_MEM );
}

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "storage name : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "old passwd   : <%s>\n", data_ptr[1]));
_NFMSdebug(( fname, "new passwd   : <%s>\n", data_ptr[2]));

ret_status = NFMchange_working_area_passwd (data_ptr[0], data_ptr[1], 
					data_ptr[2]);
_NFMSdebug(( fname, "NFMchange_working_area_passwd <0x%.8x>\n", ret_status));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

return( ret_status);
}

