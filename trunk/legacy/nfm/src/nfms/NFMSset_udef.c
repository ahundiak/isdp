#include "machine.h"
#include "MEMstruct.h"
#include "NETdef.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "ERR.h"

/* 
 Doc: NFMSset_user_defaults
 
 Abstract:
     This function will get the user defaults that are stored in
     the nfmusers table using the user_id.
          
 */
 
long NFMSset_user_defaults (in_list)

MEMptr in_list;

{
    long status;
    long ret_status;
    long user_id;

    char **data_ptr;

    MEMptr data_list = NULL;
 
    static char *fname = "NFMSset_user_defaults";

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
        status = MEMsplit_copy_buffer (in_list, &data_list, 0);
        if (status != MEM_S_SUCCESS)
        {
            MEMclose (&data_list);
            _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n",status));
            return (status);
        }
    }

    ret_status = NFMuser_defaults_logout(user_id, data_list);
    _NFMSdebug(( fname, "NFMuser_defaults_logout\n", ret_status));

    status = NFMSsend_error_buffers( ret_status, ret_status );
    _NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

    MEMclose( &data_list );

    return (ret_status);
}

/* 
 Doc: NFMSwrite_user_defaults
 
 Abstract:
     This function will write the user defaults into the file in
     the <env>/system directory.
          
 */
 
long NFMSwrite_user_defaults (in_list)

MEMptr in_list;

{
    long status;
    long ret_status;
  
    static char *fname = "NFMSwrite_user_defaults";

    ret_status = NFMwrite_user_defaults (in_list);
    _NFMSdebug(( fname, "NFMwrite_user_defaults\n", ret_status));

    status = NFMSsend_error_buffers( ret_status, ret_status );
    _NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

    return (ret_status);
}
