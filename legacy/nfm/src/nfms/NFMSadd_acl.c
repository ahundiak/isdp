#include "machine.h"
#include "MEMstruct.h"
#include "NETdef.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "ERR.h"

#define BUFFER_SIZE 1000


/* 
 Doc: NFMSquery_acl_attributes
 
 Abstract:
     This function will return the attributes needed to add an Access
     Control List.
     
 */
 
long NFMSquery_acl_attributes (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;

static char *fname = "NFMSquery_acl_attributes";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID           : <%s>\n", data_ptr[0]));

user_id = atol (data_ptr[0]);

ret_status = NFMquery_acl_attributes (user_id, &attr_list, &data_list,
                                     &value_list);
_NFMSdebug(( fname, "NFMquery_acl_attribute <0x%.8x>\n", ret_status ));

if (ret_status != NFM_S_SUCCESS)
    {
    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&value_list);
    attr_list = NULL;
    data_list = NULL;
    value_list = NULL;
    }

status = NFMSsend_three_buffers( ret_status, attr_list, data_list, value_list);
_NFMSdebug(( fname, "NFMSsend_three_buffers <0x%.8x>\n", status));

if (NFMmsg_ptr.debug_on)
    {
    MEMprint_buffers ("ACL ATTR", attr_list, NFMmsg_ptr.debug_file);
    MEMprint_buffers ("ACL DATA", data_list, NFMmsg_ptr.debug_file);
    MEMprint_buffers ("ACL VALUE", value_list, NFMmsg_ptr.debug_file);
    }

MEMclose (&attr_list);
MEMclose (&data_list);
MEMclose (&value_list);

return (NFM_S_SUCCESS);
}


/* 
 Doc: NFMSadd_acl
 
 Abstract:
     This function will add an Access Control List given the updated 
     buffers returned from NFMSquery_acl_attributes.

 */
 
long NFMSadd_acl (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;

MEMptr attr_list = NULL;
MEMptr data_list = NULL;

static char *fname = "NFMSadd_acl";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID           : <%s>\n", data_ptr[0]));

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

ret_status = NFMadd_acl (user_id, attr_list, data_list);
_NFMSdebug(( fname, "NFMadd_acl <0x%.8x>\n", ret_status));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

MEMclose (&attr_list);
MEMclose (&data_list);

if( ret_status != NFM_S_SUCCESS )
    return( ret_status);

return (NFM_S_SUCCESS);
}


