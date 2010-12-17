#include "machine.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "ERR.h"

/* 
 Doc: NFMSquery_acl_class_users
 
 Abstract:
     This function will return the attributes needed to add users to an Access
     Control List.

 */
 
long NFMSquery_acl_class_users (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;

static char *fname = "NFMSquery_acl_class_users";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID       : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "acl name : <%s>\n", data_ptr[1]));

user_id = atol (data_ptr[0]);

ret_status = NFMquery_acl_class_users (user_id, data_ptr[1], &attr_list,
                                      &data_list, &value_list);
_NFMSdebug(( fname, "NFMquery_acl_class_users <0x%.8x>\n", ret_status));

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
_NFMSdebug(( fname, "NFMSsend_three_buffers <0x%.8x>\n", status ));

if (NFMmsg_ptr.debug_on)
    {
    MEMprint_buffers ("ACL CLASS ATTR", attr_list, NFMmsg_ptr.debug_file);
    MEMprint_buffers ("ACL CLASS DATA", data_list, NFMmsg_ptr.debug_file);
    MEMprint_buffers ("ACL CLASS VALUES", value_list, NFMmsg_ptr.debug_file);
    }

MEMclose( &attr_list);
MEMclose (&data_list);
MEMclose (&value_list);

return (ret_status);
}


/* 
 Doc: NFMSupdate_acl_class_users
 
 Abstract:
     This function will add users to an Access Control List given the updated 
     buffers returned from NFMSquery_acl_users_attributes.
*/

long NFMSupdate_acl_class_users( in_list )

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;

static char *fname = "NFMSupdate_acl_class_users";

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

ret_status = NFMupdate_acl_class_users (user_id, attr_list, data_list);
_NFMSdebug(( fname, "NFMupdate_acl_class_users <0x%.8x>\n", ret_status));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

MEMclose (&attr_list);
MEMclose (&data_list);

if( ret_status != NFM_S_SUCCESS )
    return( ret_status);

return (NFM_S_SUCCESS);
}


long NFMSdelete_acl (in_list)

MEMptr in_list;

{
long status;
long ret_status;
char **data_ptr;

static char *fname = "NFMSdelete_acl";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return (NFM_E_MEM);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "Workflow Name : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "ACL Name : <%s>\n", data_ptr[1]));

ret_status = NFMdelete_acl ( data_ptr[0], data_ptr[1] );
_NFMSdebug(( fname, "NFMdelete_acl <0x%.8x>\n", ret_status));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

if( ret_status != NFM_S_SUCCESS )
    return( ret_status);

return (NFM_S_SUCCESS);
}



