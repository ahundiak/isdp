#include "machine.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"

/* 
 Doc: NFMSchange_user
 
 Abstract:
     This function will change a user given the updated 
     buffers returned from NFMSquery_change_user_attributes.
 */
 
long NFMSchange_user (in_list)

MEMptr in_list;

{
    long status;
    long ret_status;
    long user_id;

    char **data_ptr;

    MEMptr attr_list = NULL;
    MEMptr data_list = NULL;
 
    static char *fname = "NFMSchange_user";

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
            _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n",status));
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
            _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n",status));
            return (status);
        }
    }

    ret_status = NFMchange_user (user_id, attr_list, data_list);
    _NFMSdebug(( fname, "NFMchange_user <0x%.8x>\n", ret_status ));

    MEMclose (&attr_list);
    MEMclose (&data_list);

    status = NFMSsend_error_buffers( ret_status, ret_status );
    _NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status));

    return( ret_status);
}
