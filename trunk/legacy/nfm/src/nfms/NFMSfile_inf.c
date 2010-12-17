#include "machine.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"

long NFMSdefine_file_information (in_list)

MEMptr in_list;

{
long   status;
long   ret_status;
char   **data_ptr1;
MEMptr buffer1 = NULL;
MEMptr buffer2 = NULL;

static char *fname = "NFMSdefine_file_information";

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
            MEMclose (&buffer2);
	    MEMclose (&buffer1);
            _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
            return (status);
        }
    }

    status = MEMbuild_array (buffer1);
    if (status != MEM_S_SUCCESS)
    {
	MEMclose (&buffer1);
	MEMclose (&buffer2);
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        return (status);
    }
    data_ptr1 = (char**)buffer1->data_ptr;

    _NFMSdebug(( fname, "Catalog     <%s>\n", data_ptr1[0] ));
    _NFMSdebug(( fname, "Item        <%s>\n", data_ptr1[1] ));
    _NFMSdebug(( fname, "Revision    <%s>\n", data_ptr1[2] ));
    _NFMSdebug(( fname, "Operation   <%s>\n", data_ptr1[3] ));

    ret_status = NFMdefine_file_information( data_ptr1[0], data_ptr1[1], 
		data_ptr1[2], atoi(data_ptr1[3]), buffer2 );
    MEMclose (&buffer1);
    MEMclose (&buffer2);
    _NFMSdebug(( fname, "NFMdefine_file_information <0x%.8x>\n", ret_status));

    status = NFMSsend_error_buffers( ret_status, ret_status );
    _NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));
 
    if (ret_status != NFM_S_SUCCESS)
        return (ret_status);

    return (NFM_S_SUCCESS);

}

long NFMSget_file_information (in_list)

MEMptr in_list;

{
long   status;
long   ret_status;
char   **data_ptr;
MEMptr attr_list = NULL;
MEMptr data_list  = NULL;
MEMptr value_list = NULL;

static char *fname = "NFMSget_file_information";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        return (status);
    }
    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Catalog     <%s>\n", data_ptr[0] ));
    _NFMSdebug(( fname, "Item        <%s>\n", data_ptr[1] ));
    _NFMSdebug(( fname, "Revision    <%s>\n", data_ptr[2] ));
    _NFMSdebug(( fname, "Operation   <%s>\n", data_ptr[3] ));

    ret_status = NFMget_file_information( data_ptr[0], data_ptr[1], 
		data_ptr[2], atol(data_ptr[3]), &attr_list, &data_list, 
		&value_list );
    _NFMSdebug(( fname, "NFMget_file_information <0x%.8x>\n", ret_status));
    if( ret_status != NFM_S_SUCCESS )
    {
        MEMclose( &attr_list );
	MEMclose( &data_list );
	MEMclose( &value_list );
	attr_list = NULL;
        data_list = NULL;
	value_list = NULL;
    }

    status = NFMSsend_three_buffers( ret_status, attr_list, data_list,
			value_list );
    _NFMSdebug(( fname, "NFMSsend_three_buffers <0x%.8x>\n", status ));

    MEMclose (&attr_list);
    MEMclose (&value_list);
    MEMclose (&data_list);
  
    return( ret_status );
}

long NFMSreset_file_information (in_list)

MEMptr in_list;
{
long   status;
long   ret_status;
char   **data_ptr;

static char *fname = "NFMSreset_file_information";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        return (status);
    }
    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Catalog     <%s>\n", data_ptr[0] ));
    _NFMSdebug(( fname, "Item        <%s>\n", data_ptr[1] ));
    _NFMSdebug(( fname, "Revision    <%s>\n", data_ptr[2] ));

    ret_status = NFMreset_file_information( data_ptr[0], data_ptr[1], 
			data_ptr[2]);
    _NFMSdebug(( fname, "NFMreset_file_information <0x%.8x>\n", ret_status));
 
    status = NFMSsend_error_buffers( ret_status, ret_status );
    _NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

    if( ret_status != NFM_S_SUCCESS )
	return( ret_status );

    return( NFM_S_SUCCESS );
}
