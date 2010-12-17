#include "machine.h"
#include "MEMstruct.h"
#include "NETdef.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "NFMschema.h"
#include "DEBUG.h"
#include "ERR.h"

#define BUFFER_SIZE 1000


/* 
 Doc: NFMSquery_acl_attributes_condition
 
 Abstract:
     This function will return the attributes needed to ACL operations 
     
 */
 
long NFMSquery_acl_attributes_condition (in_list)

MEMptr in_list;

{
long status;
long ret_status;
char **data_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;

static char *fname = "NFMSquery_acl_attributes_condition" ;

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "condition           : <%s>\n", data_ptr[0]));

ret_status = NFMquery_acl_attributes_condition (data_ptr[0], 
						&attr_list, &data_list,
						&value_list);
_NFMSdebug(( fname, "NFMquery_acl_attribute_condition <0x%.8x>\n", 
	    ret_status ));

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
 Doc: NFMSget_acl_classes_for_copy
 
 Abstract:
     This function will add an Access Control List given the updated 
     buffers returned from NFMSquery_acl_attributes.

 */
 
long NFMSget_acl_classes_for_copy (in_list)

MEMptr in_list;

{
long status;
long ret_status;
char **data_ptr;

MEMptr attr_list = NULL;
MEMptr value_list = NULL;
MEMptr return_buffer = NULL ;
char old_aclname [NFM_ACLNAME+1] ;
long new_wfno ;
static char *fname = "NFMSget_acl_classes_for_copy" ;

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;

strcpy (old_aclname, data_ptr[0]);
new_wfno = atol (data_ptr[1]) ;

ret_status = NFMget_acl_classes_for_copy (old_aclname, new_wfno, 
					  &attr_list, &value_list);

_NFMSdebug(( fname, "NFMget_acl_classes_for_copy <0x%.8x>\n", ret_status));

status = NFMSsend_two_buffers( ret_status, attr_list, value_list) ;
_NFMSdebug(( fname, "NFMSsend_two_buffers <0x%.8x>\n", status));

if (NFMmsg_ptr.debug_on)
    {
    MEMprint_buffers ("ACL ATTR", attr_list, NFMmsg_ptr.debug_file);
    MEMprint_buffers ("ACL VALUE", value_list, NFMmsg_ptr.debug_file);
    }

MEMclose (&attr_list);
MEMclose (&value_list);
MEMclose (&return_buffer) ;

if( ret_status != NFM_S_SUCCESS )
    return( ret_status);

return (NFM_S_SUCCESS);
}


/* 
 Doc: NFMScopy_acl_users
 
 Abstract:
     This function will add an Access Control List given the updated 
     buffers returned from NFMSquery_acl_attributes.

 */
 
long NFMScopy_acl_users (in_list)

MEMptr in_list;

{
long status;
long ret_status;
char **data_ptr;
char old_aclname [NFM_ACLNAME+1], new_aclname [NFM_ACLNAME+1] ;
long new_wfno ;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;

static char *fname = "NFMScopy_acl_users";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;

strcpy (new_aclname, data_ptr[0]);
new_wfno = atol (data_ptr[1]);
strcpy (old_aclname, data_ptr[2]);

status = MEMreset_buffer_no (in_list, 2);
if (status == MEM_S_SUCCESS)
    {
    status = MEMsplit_copy_buffer (in_list, &data_list, 0);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
        return (status);
        }
    }

ret_status = NFMcopy_acl_users (new_aclname, new_wfno, old_aclname, 
			  data_list);
_NFMSdebug(( fname, "NFMcopy_acl_users <0x%.8x>\n", ret_status));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

MEMclose (&data_list);

if( ret_status != NFM_S_SUCCESS )
    return( ret_status);

return (NFM_S_SUCCESS);
}

