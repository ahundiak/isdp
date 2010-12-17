#include "machine.h"
#include "MEMstruct.h"
#include "NETdef.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "ERR.h"

/* 
 Doc: NFMSquery_project_members
 
 Abstract:
     This function will return the attributes needed to add items
     to a project.
 */
 
long NFMSquery_project_members (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;

static char *fname = "NFMSquery_project_members";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID      : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "project : <%s>\n", data_ptr[1]));

user_id = atol (data_ptr[0]);

ret_status = NFMquery_project_members (user_id, data_ptr[1], &attr_list,
                                       &data_list);
_NFMSdebug(( fname, "NFMquery_project_members\n", ret_status));

if (ret_status != NFM_S_SUCCESS)
    {
    MEMclose (&attr_list);
    MEMclose (&data_list);
    attr_list = NULL;
    data_list = NULL;
    }

status = NFMSsend_two_buffers( ret_status, attr_list, data_list );
_NFMSdebug(( fname, "NFMSsend_two_buffers <0x%.8x>\n", status ));

MEMclose (&attr_list);
MEMclose (&data_list);

return (ret_status);
}

/* 
 Doc: NFMSupdate_project_members
 
 Abstract:
     This function will add items to a project given the updated 
     buffers returned from NFMSquery_project_members.
          
 */
 
long NFMSupdate_project_members (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;

static char *fname = "NFMSupdate_project_members";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID : <%s>\n", data_ptr[0]));

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

ret_status = NFMupdate_project_members (user_id, attr_list, data_list);
_NFMSdebug(( fname, "NFMupdate_project_members\n", ret_status));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

MEMclose (&attr_list);
MEMclose (&data_list);

if( ret_status != NFM_S_SUCCESS )
    return( ret_status);

return (NFM_S_SUCCESS);
}


/* 
 Doc: NFMSquery_project_members
 
 Abstract:
     This function will return the items that can be added
     to a project.
     
 */
 
long NFMSqry_items_in_cat_for_project(in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
MEMptr data_list = NULL;

static char *fname = "NFMSquery_items_for_project";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID      : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "project : <%s>\n", data_ptr[1]));
_NFMSdebug(( fname, "catalog : <%s>\n", data_ptr[2]));
user_id = atol (data_ptr[0]);

ret_status = NFMqry_items_in_cat_for_project (user_id, data_ptr[1],data_ptr[2],
					     &data_list );
_NFMSdebug(( fname, "NFMqry_items_in_cat_for_project\n", ret_status));

status = NFMSsend_one_buffer( ret_status, data_list );
_NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));

if (ret_status != NFM_S_SUCCESS)
    return (ret_status);

return (NFM_S_SUCCESS);
}
 
long NFMSqry_project_members (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;

static char *fname = "NFMSqry_project_members";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID      : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "project : <%s>\n", data_ptr[1]));

user_id = atol (data_ptr[0]);
/*
ret_status = NFMqry_project_members (user_id, data_ptr[1], &attr_list,
                                       &data_list);
*/
_NFMSdebug(( fname, "NFMqry_project_members\n", ret_status));
if (ret_status != NFM_S_SUCCESS)
    {
    MEMclose (&attr_list);
    MEMclose (&data_list);
    attr_list = NULL;
    data_list = NULL;
    }

status = NFMSsend_two_buffers( ret_status, attr_list, data_list );
_NFMSdebug(( fname, "NFMSsend_two_buffers <0x%.8x>\n", status ));

MEMclose (&attr_list);
MEMclose (&data_list);

return (ret_status);
}
