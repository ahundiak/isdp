#include "machine.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"

long NFMSupdate_user_defaults (in_list)

MEMptr in_list;

{
long status;
long user_id;
long ret_status;
char **data_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;

static char *fname = "NFMSupdate_user_defaults";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
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
/*
ret_status = NFMupdate_user_defaults (user_id, attr_list, data_list);
_NFMSdebug(( fname, "NFMupdate_user_defaults <0x%.8x>\n", ret_status ));

status = NFMSsend_error_buffers( ret_status, ret_status ));
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));
*/

MEMclose (&attr_list);
MEMclose (&data_list);

return (ret_status);
}


long NFMSquery_user_defaults (in_list)

MEMptr in_list;

{
long status;
long ret_status;
long user_id;
char **data_ptr;
MEMptr data_list = NULL;

static char *fname = "NFMSquery_user_defaults";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID : <%s>\n", data_ptr[0]));

user_id = atol (data_ptr[0]);

_NFMSdebug(( fname, "user_id : <%ld>\n", user_id));
/*
ret_status = NFMquery_user_defaults (user_id, &attr_list, &data_list);
_NFMSdebug(( fname, "NFMquery_user_defaults : <0x%.8x>\n", ret_status));
if (ret_status != NFM_S_SUCCESS)
    {
    MEMclose (&attr_list);
    MEMclose (&data_list);
    attr_list = NULL;
    data_list = NULL;
    }

status = NFMSsend_two_buffers( ret_status, attr_list, data_list );
_NFMSdebug(( fname, "NFMsend_two_buffers <0x%.8x>\n", status ));
*/

return( ret_status );
}
