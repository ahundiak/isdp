#include "machine.h"
#include "MEMstruct.h"
#include "NETdef.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"

#define BUFFER_SIZE 1000


/* 
 Doc: NFMScreate_table
 
 Abstract:
     This function will create a table with a given set of attributes
     and data.
     
 */
 
long NFMScreate_table (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;

static char *fname = "NFMScreate_table";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    return (status);

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID         : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "table type : <%s>\n", data_ptr[1]));
_NFMSdebug(( fname, "table name : <%s>\n", data_ptr[2]));

user_id = atol (data_ptr[0]);

status = MEMreset_buffer_no (in_list, 2);
if (status == MEM_S_SUCCESS)
    {
    status = MEMsplit_copy_buffer (in_list, &attr_list, 0);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
        return (status);
        }
    }

status = MEMreset_buffer_no (in_list, 3);
if (status == MEM_S_SUCCESS)
    {
    status = MEMsplit_copy_buffer (in_list, &data_list, 0);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&data_list);
        _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
        return (status);
        }
    }

status = MEMreset_buffer_no (in_list, 4);
if (status == MEM_S_SUCCESS)
    {
    status = MEMsplit_copy_buffer (in_list, &value_list, 1);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&data_list);
        _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
        return (status);
        }
    }

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    return (status);

data_ptr = (char **) in_list->data_ptr;

ret_status = NFMcreate_table (user_id, data_ptr[1], data_ptr[2], attr_list,
                          data_list, value_list);
_NFMSdebug(( fname, "NFMcreate_table <0x%.8x>\n", ret_status));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

MEMclose (&attr_list);
MEMclose (&data_list);
MEMclose (&value_list);

if( ret_status != NFM_S_SUCCESS )
    return( ret_status );

return (NFM_S_SUCCESS);

}


