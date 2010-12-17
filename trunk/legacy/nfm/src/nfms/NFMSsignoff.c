#include "machine.h"
#include "MEMstruct.h"
#include "NETdef.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "ERR.h"

#define BUFFER_SIZE 1000


/* 
 Doc: NFMSquery_acl_signoff_users
 
 Abstract:
     This function will return the attributes needed to add signoff users to
     an Access Control List.

 */
 
long NFMSquery_acl_signoff_users (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;

static char *fname = "NFMSquery_acl_signoff_users";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID       : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "acl_name : <%s>\n", data_ptr[1]));

user_id = atol (data_ptr[0]);

ret_status = NFMquery_acl_signoff_users (user_id, data_ptr[1], &attr_list,
                                        &data_list, &value_list);
_NFMSdebug(( fname, "NFMquery_acl_signoff_users <0x%.8x>\n", ret_status));

if (ret_status != NFM_S_SUCCESS)
    {
    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&value_list);
    attr_list = NULL;
    data_list = NULL;
    value_list = NULL;
    }

status = NFMSsend_three_buffers( ret_status, attr_list, data_list,value_list);
_NFMSdebug(( fname, "NFMSsend_three_buffers <0x%.8x>\n", status ));

MEMclose (&attr_list);
MEMclose (&data_list);
MEMclose (&value_list);

return (ret_status);
}


/* 
 Doc: NFMSupdate_acl_signoff_users
 
 Abstract:
     This function will enter signoff users to an Access Control List given
     the updated buffers returned from NFMSquery_acl_signoff_users.
          
 */
 
long NFMSupdate_acl_signoff_users (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;

static char *fname = "NFMSupdate_acl_signoff_users";

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

ret_status = NFMupdate_acl_signoff_users (user_id, attr_list, data_list);
_NFMSdebug(( fname, "NFMupdate_acl_signoff_users <0x%.8x>\n", ret_status));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

MEMclose (&attr_list);
MEMclose (&data_list);

if( ret_status != NFM_S_SUCCESS )
    return( ret_status);

return (NFM_S_SUCCESS);
}



/* 
 Doc: NFMSsignoff
 
 Abstract:
     This function will sign a user off given the buffers returned from
     NFMquery_signoff_attributes.
 */
 
long NFMSsignoff (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;

static char *fname = "NFMSsignoff";

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

ret_status = NFMsignoff (user_id, attr_list, data_list);
_NFMSdebug(( fname, "NFMsignoff <0x%.8x>\n", ret_status));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

MEMclose (&attr_list);
MEMclose (&data_list);

if( ret_status != NFM_S_SUCCESS )
    return( ret_status);

return (NFM_S_SUCCESS);

}



/* 
 Doc: NFMSquery_signoff_attributes
 
 Abstract:
     This function will return the attributes needed to signoff a user.

 */
 
long NFMSquery_signoff_attributes (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;

static char *fname = "NFMSquery_signoff_attributes";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID       : <%s>\n", data_ptr[0]));

user_id = atol (data_ptr[0]);

ret_status = NFMquery_signoff_attributes (user_id, &attr_list, &data_list,
                                         &value_list);
_NFMSdebug(( fname, "NFMquery_signoff_attributes <0x%.8x>\n", ret_status));

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
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

MEMclose (&attr_list);
MEMclose (&data_list);
MEMclose (&value_list);

return (ret_status);
}


/*
 Doc: NFMSpurge_signoff

 Abstract:
     This function will sign a user off given the buffers returned from
     NFMquery_signoff_attributes.

 */

long NFMSpurge_signoff (in_list)

     MEMptr in_list;   /* input mand */
{
  long status;
  long ret_status;
  long user_id ;
  char **data_ptr;
  
static char *fname = "NFMSpurge_signoff";
  
  status = MEMbuild_array (in_list);
  if (status != MEM_S_SUCCESS)
    {
      _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
      return (status);
    }
  
  data_ptr = (char **) in_list->data_ptr;
  
  _NFMSdebug(( fname, "ID           : <%s>\n", data_ptr[0]));
  
  user_id = atol (data_ptr[0]);
  
  ret_status = NFMpurge_signoff (user_id, data_ptr [1], data_ptr [2], 
		data_ptr [3]);
  _NFMSdebug(( fname, "NFMpurge_signoff <0x%.8x>\n", ret_status));

  status = NFMSsend_error_buffers( ret_status, ret_status );
  _NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

  if( ret_status != NFM_S_SUCCESS )
    return( ret_status);

  return (NFM_S_SUCCESS);

}



