#include "machine.h"
#include "MEMstruct.h"
#include "NETdef.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "ERR.h"

/* 
 Doc: NFMSchange_catalog
 
 Abstract:
     This function will change a catalog with a given set of LOC attributes
     and data (modified buffers returned from NFMRquery_loc_attributes) and a 
     given set of change CATALOG attributes, data, and values (modified buffers
     returned from NFMRquery_change_catalog_attributes).
 */
 
long NFMSchange_catalog (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
MEMptr loc_attr = NULL;
MEMptr loc_data = NULL;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;

static char *fname = "NFMSchange_catalog";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    return (status);

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID : <%s>\n", data_ptr[0]));

user_id = atol (data_ptr[0]);

status = MEMreset_buffer_no (in_list, 2);
if (status == MEM_S_SUCCESS)
    {
    status = MEMsplit_copy_buffer (in_list, &loc_attr, 0);
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
    status = MEMsplit_copy_buffer (in_list, &loc_data, 0);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
        return (status);
        }
    }

status = MEMreset_buffer_no (in_list, 4);
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

status = MEMreset_buffer_no (in_list, 5);
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

status = MEMreset_buffer_no (in_list, 6);
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

ret_status = NFMchange_catalog (user_id, loc_attr, loc_data, 
		attr_list, data_list, value_list);
_NFMSdebug(( fname, "NFMchange_catalog <0x%.8x>\n", ret_status ));

MEMclose (&loc_attr);
MEMclose (&loc_data);
MEMclose (&attr_list);
MEMclose (&data_list);
MEMclose (&value_list);

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));
 
if( ret_status != NFM_S_SUCCESS )
    return( ret_status );

return (NFM_S_SUCCESS);
}


