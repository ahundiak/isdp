#include "machine.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "UTIerrordef.h"
#include "UTIstruct.h"
#include "UTIglobals.h"
#include "ERR.h"
#include "DEBUG.h"

#define  BUFFER_SIZE  1000

long NFMSarchive_files( in_list )
    MEMptr	in_list;
{
    long	status;
    long	ret_status;
    char 	**data_ptr; 
    MEMptr	msg_list  = NULL;
    MEMptr	file_list = NULL;

    static 	char *fname = "NFMSarchive_files";

    status = MEMbuild_array( in_list );
    if( status != MEM_S_SUCCESS )
    {
	_NFMSdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }

    data_ptr = (char **)in_list->data_ptr;

    _NFMSdebug(( fname, "Server  <%s>\n", data_ptr[0] ));
    _NFMSdebug(( fname, "Env     <%s>\n", data_ptr[1] ));
    _NFMSdebug(( fname, "User    <%s>\n", data_ptr[2] ));
    _NFMSdebug(( fname, "Passwd  <%s>\n", data_ptr[3] ));
    _NFMSdebug(( fname, "Sa Num  <%s>\n", data_ptr[4] ));
    _NFMSdebug(( fname, "Label   <%s>\n", data_ptr[5] ));

    status = MEMreset_buffer_no (in_list, 2);
    if (status == MEM_S_SUCCESS)
    {
        status = MEMsplit_copy_buffer (in_list, &file_list, 1);
        if (status != MEM_S_SUCCESS)
        {
            MEMclose (&file_list);
            _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n",status));
            return (status);
        }
    }

    status = MEMbuild_array( in_list );
    if( status != MEM_S_SUCCESS )
    {
	_NFMSdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }

    data_ptr = (char **)in_list->data_ptr;

    ret_status = NFMarchive_files( data_ptr[0], data_ptr[1], data_ptr[2],
	       data_ptr[3], data_ptr[4], data_ptr[5], file_list, &msg_list );
    _NFMSdebug(( fname, "NFMarchive_files <0x%.8x>\n", ret_status ));
    MEMclose( &file_list );

    if( ret_status != NFM_S_SUCCESS )
    {
	MEMclose( &msg_list );
	msg_list = NULL;
    }

    status = NFMSsend_one_buffer( ret_status, msg_list );
    _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));

    MEMclose( &msg_list );

    return( ret_status );
}
 

long NFMSbackup_files( in_list )
    MEMptr	in_list;
{
    long	status;
    long	ret_status;
    char 	**data_ptr; 
    MEMptr	msg_list  = NULL;
    MEMptr	file_list = NULL;

    static 	char *fname = "NFMSbackup_files";

    status = MEMbuild_array( in_list );
    if( status != MEM_S_SUCCESS )
    {
	_NFMSdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }

    data_ptr = (char **)in_list->data_ptr;

    _NFMSdebug(( fname, "Server  <%s>\n", data_ptr[0] ));
    _NFMSdebug(( fname, "Env     <%s>\n", data_ptr[1] ));
    _NFMSdebug(( fname, "User    <%s>\n", data_ptr[2] ));
    _NFMSdebug(( fname, "Passwd  <%s>\n", data_ptr[3] ));
    _NFMSdebug(( fname, "Sa Num  <%s>\n", data_ptr[4] ));
    _NFMSdebug(( fname, "Label   <%s>\n", data_ptr[5] ));

    status = MEMreset_buffer_no (in_list, 2);
    if (status == MEM_S_SUCCESS)
    {
        status = MEMsplit_copy_buffer (in_list, &file_list, 1);
        if (status != MEM_S_SUCCESS)
        {
            MEMclose (&file_list);
            _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n",status));
            return (status);
        }
    }
    status = MEMbuild_array( in_list );
    if( status != MEM_S_SUCCESS )
    {
        _NFMSdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char **)in_list->data_ptr;

    ret_status = NFMbackup_files( data_ptr[0], data_ptr[1], data_ptr[2],
	       data_ptr[3], data_ptr[4], data_ptr[5], file_list, &msg_list );
    _NFMSdebug(( fname, "NFMbackup_files <0x%.8x>\n", ret_status ));
    MEMclose( &file_list );

    if( ret_status != NFM_S_SUCCESS )
    {
	MEMclose( &msg_list );
	msg_list = NULL;
    }

    status = NFMSsend_one_buffer( ret_status, msg_list );
    _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));

    MEMclose( &msg_list );

    return( ret_status );
}
 

long NFMSrestore_files( in_list )
    MEMptr	in_list;
{
    long	status;
    long	ret_status;
    char 	**data_ptr;
    MEMptr	msg_list  = NULL; 
    MEMptr	file_list = NULL;

    static 	char *fname = "NFMSrestore_files";

    status = MEMbuild_array( in_list );
    if( status != MEM_S_SUCCESS )
    {
	_NFMSdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }

    data_ptr = (char **)in_list->data_ptr;

    _NFMSdebug(( fname, "Server  <%s>\n", data_ptr[0] ));
    _NFMSdebug(( fname, "Env     <%s>\n", data_ptr[1] ));
    _NFMSdebug(( fname, "User    <%s>\n", data_ptr[2] ));
    _NFMSdebug(( fname, "Passwd  <%s>\n", data_ptr[3] ));

    status = MEMreset_buffer_no (in_list, 2);
    if (status == MEM_S_SUCCESS)
    {
        status = MEMsplit_copy_buffer (in_list, &file_list, 1);
        if (status != MEM_S_SUCCESS)
        {
            MEMclose (&file_list);
            _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n",status));
            return (status);
        }
    }

    status = MEMbuild_array( in_list );
    if( status != MEM_S_SUCCESS )
    {
        _NFMSdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char **)in_list->data_ptr;


    ret_status = NFMrestore_files( data_ptr[0], data_ptr[1], data_ptr[2],
	       data_ptr[3], file_list, &msg_list );
    _NFMSdebug(( fname, "NFMrestore_files <0x%.8x>\n", ret_status ));
    MEMclose( &file_list );
    if( ret_status != NFM_S_SUCCESS )
    {
	MEMclose( &msg_list );
	msg_list = NULL;
    }

    status = NFMSsend_one_buffer( ret_status, msg_list );
    _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));

    MEMclose( &msg_list );

    return( ret_status );
}
 

long NFMSdelete_files( in_list )
    MEMptr	in_list;
{
    long	status;
    long	ret_status;
    char 	**data_ptr;
    MEMptr	file_list = NULL;

    static 	char *fname = "NFMSdelete_files";

    status = MEMbuild_array( in_list );
    if( status != MEM_S_SUCCESS )
    {
	_NFMSdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }

    data_ptr = (char **)in_list->data_ptr;

    _NFMSdebug(( fname, "Server  <%s>\n", data_ptr[0] ));
    _NFMSdebug(( fname, "Env     <%s>\n", data_ptr[1] ));
    _NFMSdebug(( fname, "User    <%s>\n", data_ptr[2] ));
    _NFMSdebug(( fname, "Passwd  <%s>\n", data_ptr[3] ));

    status = MEMreset_buffer_no (in_list, 2);
    if (status == MEM_S_SUCCESS)
    {
        status = MEMsplit_copy_buffer (in_list, &file_list, 1);
        if (status != MEM_S_SUCCESS)
        {
            MEMclose (&file_list);
            _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n",status));
            return (status);
        }
    }

    status = MEMbuild_array( in_list );
    if( status != MEM_S_SUCCESS )
    {
        _NFMSdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char **)in_list->data_ptr;

    ret_status = NFMdelete_files( data_ptr[0], data_ptr[1], data_ptr[2],
	       data_ptr[3], file_list );
    _NFMSdebug(( fname, "NFMdelete_files <0x%.8x>\n", ret_status ));

    MEMclose( &file_list );

    status = NFMSsend_error_buffers( ret_status, ret_status );
    _NFMSdebug(( fname, "NFMSsend_error_buffer <0x%.8x>\n", status ));

    return( ret_status );
}
 
 
