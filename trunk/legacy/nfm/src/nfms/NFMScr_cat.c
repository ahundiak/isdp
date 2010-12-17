#include "machine.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"

/* 
 Doc: NFMScreate_catalog
 
 Abstract:
     This function will create a catalog with a given set of LOC attributes
     and data (modified buffers returned from NFMRquery_loc_attributes) and a 
     given set of CATALOG attributes, data, and values (modified buffers
     returned from NFMRquery_catalog_attributes).

 */
 
long NFMScreate_catalog (in_list)

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

static char *fname = "NFMScreate_catalog";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
{
    _NFMSdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
}

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

if (_NFMdebug_st.NFMSdebug_on)
    {
    MEMprint_buffers ("LOC ATTR", loc_attr, _NFMdebug_st.NFMSdebug_file);
    MEMprint_buffers ("LOC DATA", loc_data, _NFMdebug_st.NFMSdebug_file);
    MEMprint_buffers ("CAT ATTR", attr_list, _NFMdebug_st.NFMSdebug_file);
    MEMprint_buffers ("CAT DATA", data_list, _NFMdebug_st.NFMSdebug_file);
    MEMprint_buffers ("CAT VALUE", value_list, _NFMdebug_st.NFMSdebug_file);
    }

ret_status = NFMcreate_catalog (user_id, loc_attr, loc_data, attr_list, 
		data_list, value_list);
_NFMSdebug(( fname, "NFMcreate_catalog <0x%.8x>\n", ret_status ));

MEMclose (&loc_attr);
MEMclose (&loc_data);
MEMclose (&attr_list);
MEMclose (&data_list);
MEMclose (&value_list);

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

return( ret_status );

}


