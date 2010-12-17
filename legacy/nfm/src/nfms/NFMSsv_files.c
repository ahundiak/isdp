#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "NFMapi.h"

long NFMSsave_item_files (in_list)

MEMptr in_list;

{
long   status;
long   ret_status;
char   **data_ptr;

static char *fname = "NFMSsave_item_files";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        return (status);
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Catalog      <%s>\n", data_ptr[0] ));
    _NFMSdebug(( fname, "Item         <%s>\n", data_ptr[1] ));
    _NFMSdebug(( fname, "Revision     <%s>\n", data_ptr[2] ));

    ret_status = NFMsave_item_files( data_ptr[0], data_ptr[1],data_ptr[2] );

    _NFMSdebug(( fname, "NFMsave_item_files  <0x%.8x>\n", ret_status));

    status = NFMSsend_error_buffers( ret_status, ret_status );
    _NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

    return (ret_status);
}

long NFMSftr_save_item_files (in_list)

MEMptr in_list;

{
long   status;
long   ret_status;
char   **data_ptr;
MEMptr filesBuffer = NULL;
MEMptr keyBuffer = NULL;

static char *fname = "NFMSftr_save_item_files";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        return (status);
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Catalog      <%s>\n", data_ptr[0] ));
    _NFMSdebug(( fname, "Item         <%s>\n", data_ptr[1] ));
    _NFMSdebug(( fname, "Revision     <%s>\n", data_ptr[2] ));

    status = MEMreset_buffer_no (in_list, 2);
    if (status == MEM_S_SUCCESS)
    {
        status = MEMsplit_copy_buffer (in_list, &filesBuffer, 0);
        if (status != MEM_S_SUCCESS)
        {
	    MEMclose( &filesBuffer );
            _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
            return (status);
        }
        status = MEMreset_buffer_no (in_list, 3);
        if (status == MEM_S_SUCCESS)
        {
            status = MEMsplit_copy_buffer (in_list, &keyBuffer, 0);
            if (status != MEM_S_SUCCESS)
            {
  	        MEMclose( &filesBuffer );
		MEMclose( &keyBuffer);
                _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
                return (status);
            }
        }
    }

    ret_status = NFMftr_save_item_files(data_ptr[0],data_ptr[1],data_ptr[2],
		 filesBuffer, keyBuffer );
    _NFMSdebug(( fname, "NFMftr_save_item_files  <0x%.8x>\n", ret_status));

    status = NFMSsend_error_buffers( ret_status, ret_status );
    _NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

    MEMclose (&filesBuffer);
    MEMclose (&keyBuffer);

    return (ret_status);
}
