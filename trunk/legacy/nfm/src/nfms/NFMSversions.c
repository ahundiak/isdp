#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "ERR.h"

long NFMSpurge_versions(in_list)

MEMptr in_list;

{
long   status;
long   ret_status;
char   **data_ptr;
static char *fname = "NFMSpurge_versions";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Catalog  <%s>\n", data_ptr[0] ));
    _NFMSdebug(( fname, "Item     <%s>\n", data_ptr[1] ));
    _NFMSdebug(( fname, "Revision <%s>\n", data_ptr[2] ));

    ret_status = NFMpurge_versions( data_ptr[0], data_ptr[1], data_ptr[2] );
    _NFMSdebug(( fname, "NFMpurge_versions  <0x%.8x>\n", ret_status));

    status = NFMSsend_error_buffers( ret_status, ret_status );
    _NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

    if( ret_status != NFM_S_SUCCESS )
	return( ret_status );

    return (NFM_S_SUCCESS);
}

long NFMSget_item_versions(in_list)

MEMptr in_list;

{
long   status;
long   ret_status;
char   **data_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
static char *fname = "NFMSget_item_versions";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Catalog   <%s>\n", data_ptr[0] ));
    _NFMSdebug(( fname, "Item      <%s>\n", data_ptr[1] ));
    _NFMSdebug(( fname, "Revision  <%s>\n", data_ptr[2] ));

    ret_status = NFMget_item_versions( data_ptr[0], data_ptr[1], data_ptr[2],
				   &attr_list, &data_list );
    _NFMSdebug(( fname, "NFMget_item_versions <0x%.8x>\n", status));

    if (ret_status != NFM_S_SUCCESS)
    {
 	MEMclose (&attr_list);     
	MEMclose (&data_list);
 	attr_list = NULL;
	data_list = NULL;
    }
    status = NFMSsend_two_buffers( ret_status, attr_list, data_list );
    _NFMSdebug(( fname, "NFMSsend_two_buffers <0x%.8x>\n", status ));

    if( ret_status != NFM_S_SUCCESS )
	return( ret_status );

    if( _NFMdebug_st.NFMSdebug_on )
    {
	MEMprint_buffers( "SYNONYM LIST", attr_list,
			  _NFMdebug_st.NFMSdebug_file );
	MEMprint_buffers( "DATA LIST", data_list, _NFMdebug_st.NFMSdebug_file);
    }

    MEMclose( &attr_list );
    MEMclose( &data_list );

    return (NFM_S_SUCCESS);
}

long NFMSroll_version_forward(in_list)

MEMptr in_list;

{
long   status;
long   ret_status;
char   **data_ptr;
MEMptr buffer1 = NULL;
MEMptr buffer2 = NULL;
static char *fname = "NFMSroll_version_forward";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }

    status = MEMsplit_copy_buffer (in_list, &buffer1, 0);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&buffer1);
        _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMreset_buffer_no (in_list, 2);
    if (status == MEM_S_SUCCESS)
    {
        status = MEMsplit_copy_buffer (in_list, &buffer2, 0);
        if (status != MEM_S_SUCCESS)
        {
            MEMclose (&buffer1);
            _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            return( NFM_E_MEM );
        }
    }

    status = MEMbuild_array (buffer1);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
	MEMclose (&buffer1);
 	MEMclose (&buffer2);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)buffer1->data_ptr;

    _NFMSdebug(( fname, "Catalog   <%s>\n", data_ptr[0] ));
    _NFMSdebug(( fname, "Item      <%s>\n", data_ptr[1] ));
    _NFMSdebug(( fname, "Revision  <%s>\n", data_ptr[2] ));

    ret_status = NFMroll_version_forward( data_ptr[0], data_ptr[1],
				      data_ptr[2], buffer2 );
    _NFMSdebug(( fname, "NFMroll_version_forward <0x%.8x>\n", status));

    MEMclose( &buffer1 );
    MEMclose( &buffer2 );

    status = NFMSsend_error_buffers( ret_status, ret_status );
    _NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x\n", status ));

    if (ret_status != NFM_S_SUCCESS)
        return (ret_status);

    return (NFM_S_SUCCESS);
}

