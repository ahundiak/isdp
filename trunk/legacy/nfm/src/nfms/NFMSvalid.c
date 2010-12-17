#include "machine.h"
#include "MEMstruct.h"
#include "NETdef.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "ERR.h"

#define BUFFER_SIZE 1000


/* 
 Doc: NFMSvalidate_user_access
 
 Abstract:
     This function will see if a user can perform a certain function
     
 */
 
long NFMSvalidate_user_access (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;

static char *fname = "NFMSvalidate_user_access";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID           : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "command      : <%s>\n", data_ptr[1]));
_NFMSdebug(( fname, "workflow     : <%s>\n", data_ptr[2]));
_NFMSdebug(( fname, "project name : <%s>\n", data_ptr[3]));
_NFMSdebug(( fname, "table name   : <%s>\n", data_ptr[4]));
_NFMSdebug(( fname, "item         : <%s>\n", data_ptr[5]));
_NFMSdebug(( fname, "item rev     : <%s>\n", data_ptr[6]));

user_id = atol (data_ptr[0]);

ret_status = NFMvalidate_user_access (user_id, data_ptr[1], data_ptr[2],
                                     data_ptr[3], data_ptr[4], data_ptr[5],
                                     data_ptr[6]);
_NFMSdebug(( fname, "NFMvalidate_user_access <0x%.8x>\n", ret_status));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", ret_status));

if( ret_status != NFM_S_SUCCESS )
    return( ret_status);

return (NFM_S_SUCCESS);
}

