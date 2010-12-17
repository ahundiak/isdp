#include "machine.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"

long NFMSlfm_information(in_list)

MEMptr in_list;

{
long   status;
long   ret_status;
char   **data_ptr;
MEMptr data_list = NULL;
static char *fname = "NFMSlfm_information";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        return (status);
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Storage Number <%s>\n", data_ptr[0] ));
    _NFMSdebug(( fname, "Flag           <%s>\n", data_ptr[1] ));
    _NFMSdebug(( fname, "Search         <%s>\n", data_ptr[2] ));
    _NFMSdebug(( fname, "Sort           <%s>\n", data_ptr[3] ));

    ret_status = NFMlfm_information( atol(data_ptr[0]), atol(data_ptr[1]),
				 data_ptr[2], data_ptr[3], &data_list );
    _NFMSdebug(( fname, "NFMlfm_information <0x%.8x>\n", ret_status));
    if (ret_status != NFM_S_SUCCESS)
    {
	MEMclose( &data_list );
	data_list = NULL;
    }

    status = NFMSsend_one_buffer( ret_status, data_list );
    _NFMSdebug(( fname, "NFMSsend_one_buffers <0x%.8x>\n", status ));

    MEMclose( &data_list );

    return (ret_status);
}

long NFMSlfm_update(in_list)

MEMptr in_list;

{
long   status;
long   ret_status;
char   **data_ptr;
MEMptr buffer1 = NULL;
MEMptr buffer2 = NULL;
static char *fname = "NFMSlfm_update";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        return (status);
    }

    status = MEMsplit_copy_buffer (in_list, &buffer1, 0);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&buffer1);
        _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
        return (status);
    }

    status = MEMreset_buffer_no (in_list, 2);
    if (status == MEM_S_SUCCESS)
    {
        status = MEMsplit_copy_buffer (in_list, &buffer2, 0);
        if (status != MEM_S_SUCCESS)
        {
            MEMclose (&buffer1);
            _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
            return (status);
        }
    }

    status = MEMbuild_array (&buffer2);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
	MEMclose (&buffer1);
 	MEMclose (&buffer2);
        return (status);
    }

    data_ptr = (char**)buffer2->data_ptr;

    _NFMSdebug(( fname, "Flag <%s>\n", data_ptr[0] ));

    ret_status = NFMlfm_update( buffer1, atol(data_ptr[0]));
    _NFMSdebug(( fname, "NFMlfm_update <0x%.8x>\n", ret_status));
    MEMclose( &buffer1 );
    MEMclose( &buffer2 );
 
    status = NFMSsend_error_buffers( ret_status, ret_status );
    _NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

    return (ret_status);
}
