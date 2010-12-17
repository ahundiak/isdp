#include "machine.h"
#include "MEMstruct.h"
#include "NETdef.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "ERR.h"

#define BUFFER_SIZE 1000

/* 
 Doc: NFMSquery_catalog_acl_map
 
 Abstract:
     This function will return the attributes needed to add an ACL mapping
     to a catalog.
 */
 
long NFMSquery_catalog_acl_map (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;
static char *fname = "NFMSquery_catalog_acl_map";

_NFMSdebug ((fname, "%s\n", "Entering ... "));

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug ((fname, "ID      : <%s>\n", data_ptr[0]));
_NFMSdebug ((fname, "catalog : <%s>\n", data_ptr[1]));

user_id = atol (data_ptr[0]);

ret_status = NFMquery_catalog_acl_map (user_id, data_ptr[1], &attr_list,
                                       &data_list, &value_list);
_NFMSdebug ((fname, "NFMquery_catalog_acl_map <0x%.8x>\n", ret_status));
if (ret_status != NFM_S_SUCCESS)
    {
    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&value_list);
    attr_list = NULL;
    data_list = NULL;
    value_list = NULL;
    }

status = NFMSsend_three_buffers( ret_status, attr_list, data_list,value_list );
_NFMSdebug(( fname, "NFMSsend_three_buffers <0x%.8x>\n", status ));

MEMclose (&attr_list);
MEMclose (&data_list);
MEMclose (&value_list);

return (ret_status);
}


/* 
 Doc: NFMSupdate_catalog_acl_map
 
 Abstract:
     This function will add an ACL mapping to a catalog given the updated 
     buffers returned from NFMSquery_catalog_acl_map.

 */
 
long NFMSupdate_catalog_acl_map (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
static char *fname = "NFMSupdate_catalog_acl_map";

_NFMSdebug ((fname, "%s\n", "Entering ..."));

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug ((fname, "ID : <%s>\n", data_ptr[0]));

user_id = atol (data_ptr[0]);

status = MEMreset_buffer_no (in_list, 2);
if (status == MEM_S_SUCCESS)
    {
    status = MEMsplit_copy_buffer (in_list, &attr_list, 0);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&attr_list);
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
        return (status);
        }
    }

ret_status = NFMupdate_catalog_acl_map (user_id, attr_list, data_list);
_NFMSdebug ((fname, "NFMupdate_catalog_acl_map <0x%.8x>\n", ret_status));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

MEMclose (&attr_list);
MEMclose (&data_list);

if( ret_status != NFM_S_SUCCESS )
    return( ret_status );

return (NFM_S_SUCCESS);
}


/* 
 Doc: NFMSquery_catalog_sa_map
 
 Abstract:
     This function will return the attributes needed to add a storage area
     mapping to a catalog.
 */
 
long NFMSquery_catalog_sa_map (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;
static char *fname = "NFMSquery_catalog_sa_map";

_NFMSdebug ((fname, "%s\n", "Entering ..."));

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug ((fname, "ID      : <%s>\n", data_ptr[0]));
_NFMSdebug ((fname, "catalog : <%s>\n", data_ptr[1]));

user_id = atol (data_ptr[0]);

ret_status = NFMquery_catalog_sa_map (user_id, data_ptr[1], &attr_list,
                                       &data_list, &value_list);
_NFMSdebug ((fname, "NFMquery_catalog_sa_map <0x%.8x>\n", ret_status));
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

MEMclose (&attr_list);
MEMclose (&data_list);
MEMclose (&value_list);

return (ret_status);
}


/* 
 Doc: NFMSupdate_catalog_sa_map
 
 Abstract:
     This function will add a storage area mapping to a catalog given the
     updated buffers returned from NFMSquery_catalog_sa_map.

 */
 
long NFMSupdate_catalog_sa_map (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
static char *fname = "NFMSupdate_catalog_sa_map";

_NFMSdebug ((fname, "%s\n", "Entering ..."));

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug ((fname, "ID : <%s>\n", data_ptr[0]));

user_id = atol (data_ptr[0]);

status = MEMreset_buffer_no (in_list, 2);
if (status == MEM_S_SUCCESS)
    {
    status = MEMsplit_copy_buffer (in_list, &attr_list, 0);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&attr_list);
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
        return (status);
        }
    }

ret_status = NFMupdate_catalog_sa_map (user_id, attr_list, data_list);
_NFMSdebug ((fname, "NFMupdate_catalog_sa_map <0x%.8x>\n", ret_status));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

MEMclose (&attr_list);
MEMclose (&data_list);

if( ret_status != NFM_S_SUCCESS )
    return( ret_status );

return (NFM_S_SUCCESS);

}


