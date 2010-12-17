#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "ERR.h"

long NFMSmultiple_catalog_search(in_list)

MEMptr in_list;

{
long   status;
long   ret_status;
int    i;
char   **data_ptr;
char   **data_ptr2;
MEMptr buffer = NULL;
MEMptr ret_list = NULL;
MEMptr syn_list = NULL;
static char *fname = "NFMSmultiple_catalog_search";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return (NFM_E_MEM);
    }

    status = MEMreset_buffer_no (in_list, 2);
    if (status == MEM_S_SUCCESS)
    {
        status = MEMsplit_copy_buffer (in_list, &buffer, 0);
        if (status != MEM_S_SUCCESS)
        {
            MEMclose (&buffer);
            _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            return (NFM_E_MEM);
        }
    }

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return (NFM_E_MEM);
    }

    data_ptr = (char**)in_list->data_ptr;

    for( i=0; i<(in_list->rows*in_list->columns); i+=in_list->columns )
        _NFMSdebug(( fname, "Catalog <%s>\n", data_ptr[i] ));

    data_ptr2 = (char**)buffer->data_ptr;

    _NFMSdebug(( fname, "Item Search <%s>\n", data_ptr2[0] ));
    _NFMSdebug(( fname, "Item Sort   <%s>\n", data_ptr2[1] ));

    ret_status = NFMmultiple_catalog_search( in_list, data_ptr2[0],
		data_ptr2[1], &ret_list, &syn_list );
    _NFMSdebug(( fname, "NFMmultiple_catalog_search <0x%.8x>\n", status));
    if (ret_status != NFM_S_SUCCESS)
    {
	MEMclose( &ret_list);
	MEMclose( &buffer );
	MEMclose( &syn_list );
	ret_list = NULL;
	syn_list = NULL;
    }

    status = NFMSsend_two_buffers( ret_status, ret_list, syn_list );
    _NFMSdebug(( fname, "NFMSsend_two_buffers <0x%.8x>\n", status ));

    if( _NFMdebug_st.NFMSdebug_on )
    {
	MEMprint_buffers( "BUFFER LIST", ret_list,
			  _NFMdebug_st.NFMSdebug_file );
	MEMprint_buffers( "SYNONYM LIST", syn_list, 
			  _NFMdebug_st.NFMSdebug_file);
    }

    MEMclose( &buffer );
    MEMclose( &ret_list );
    MEMclose( &syn_list );

    return (NFM_S_SUCCESS);
}

long NFMSblock_multiple_catalog_search(in_list)

MEMptr in_list;

{
long   status;
long   ret_status;
int    no_buffers;
int    i;
char   **data_ptr;
char   **data_ptr2;
MEMptr buffer = NULL;
MEMptr ret_list = NULL;
MEMptr syn_list = NULL;
static char *fname = "NFMSblock_multiple_catalog_search";

    status = MEMno_buffers (in_list, &no_buffers);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMno_buffers : <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return (NFM_E_MEM);
    }
    _NFMSdebug(( fname, "Number of buffers <%d>\n", no_buffers ));

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return (NFM_E_MEM);
    }

    buffer = NULL;
    if( no_buffers > 1 )
    {
        status = MEMreset_buffer_no (in_list, 2);
        if (status == MEM_S_SUCCESS)
        {
            status = MEMsplit_copy_buffer (in_list, &buffer, 0);
            if (status != MEM_S_SUCCESS)
            {
                MEMclose (&buffer);
                _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
                ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
                return (NFM_E_MEM);
            }
   	    data_ptr2 = (char**)buffer->data_ptr;

	    for( i=0; i<(buffer->rows*buffer->columns); i+=buffer->columns )
	        _NFMSdebug(( fname, "Catalog <%s>\n", data_ptr2[i] ));
        }
    }
    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return (NFM_E_MEM);
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Item Search <%s>\n", data_ptr[0] ));
    _NFMSdebug(( fname, "Item Sort   <%s>\n", data_ptr[1] ));
    _NFMSdebug(( fname, "Row Size    <%s>\n", data_ptr[2] ));

    ret_status = NFMblock_multiple_catalog_search( buffer, data_ptr[0],
		data_ptr[1], &ret_list, &syn_list, atol(data_ptr[2]) );

    _NFMSdebug(( fname,"NFMblock_multiple_catalog_search <0x%.8x>\n", 
	ret_status));
    if  ((ret_status != NFM_S_SUCCESS) && 
	 (ret_status != NFM_I_NO_MORE_BUFFERS) &&
         (ret_status != NFM_I_SAC_SOME_CATALOGS))
    {
	MEMclose( &ret_list);
	MEMclose( &buffer );
	MEMclose( &syn_list );
	ret_list = NULL;
	syn_list = NULL;
    }

    status = NFMSsend_two_buffers( ret_status, ret_list, syn_list );
    _NFMSdebug(( fname, "NFMSsend_two_buffers <0x%.8x>\n", status ));

    if( _NFMdebug_st.NFMSdebug_on )
    {
	MEMprint_buffers( "BUFFER LIST", ret_list,
			  _NFMdebug_st.NFMSdebug_file );
	MEMprint_buffers( "SYNONYM LIST", syn_list, 
			  _NFMdebug_st.NFMSdebug_file);
    }

    MEMclose( &buffer );
    MEMclose( &ret_list );
    MEMclose( &syn_list );

    return (NFM_S_SUCCESS);
}

long NFMSblock_multi_cat_srch_m_crsr(in_list)

MEMptr in_list;

{
long   status;
long   ret_status;
int    no_buffers;
int    i;
char   **data_ptr;
char   **data_ptr2;
MEMptr buffer = NULL;
MEMptr ret_list = NULL;
MEMptr syn_list = NULL;
static char *fname = "NFMSblock_mult_cat_srch_m_crsr";

    status = MEMno_buffers (in_list, &no_buffers);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMno_buffers : <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return (NFM_E_MEM);
    }
    _NFMSdebug(( fname, "Number of buffers <%d>\n", no_buffers ));

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return (NFM_E_MEM);
    }

    buffer = NULL;
    if( no_buffers > 1 )
    {
        status = MEMreset_buffer_no (in_list, 2);
        if (status == MEM_S_SUCCESS)
        {
            status = MEMsplit_copy_buffer (in_list, &buffer, 0);
            if (status != MEM_S_SUCCESS)
            {
                MEMclose (&buffer);
                _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
                ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
                return (NFM_E_MEM);
            }
   	    data_ptr2 = (char**)buffer->data_ptr;

	    for( i=0; i<(buffer->rows*buffer->columns); i+=buffer->columns )
	        _NFMSdebug(( fname, "Catalog <%s>\n", data_ptr2[i] ));
        }
    }
    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return (NFM_E_MEM);
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Item Search <%s>\n", data_ptr[0] ));
    _NFMSdebug(( fname, "Item Sort   <%s>\n", data_ptr[1] ));
    _NFMSdebug(( fname, "Row Size    <%s>\n", data_ptr[2] ));
    _NFMSdebug(( fname, "cursor_id   <%s>\n", data_ptr[3] ));

    ret_status = NFMblock_multi_cat_srch_m_crsr( buffer, data_ptr[0],
		data_ptr[1], &ret_list, &syn_list, atol(data_ptr[2]),atol(data_ptr[3]) );

    _NFMSdebug(( fname,"NFMblock_multi_cat_srch_m_crsr <0x%.8x>\n", 
	ret_status));
    if  ((ret_status != NFM_S_SUCCESS) && 
	 (ret_status != NFM_I_NO_MORE_BUFFERS) &&
         (ret_status != NFM_I_SAC_SOME_CATALOGS))
    {
	MEMclose( &ret_list);
	MEMclose( &buffer );
	MEMclose( &syn_list );
	ret_list = NULL;
	syn_list = NULL;
    }

    status = NFMSsend_two_buffers( ret_status, ret_list, syn_list );
    _NFMSdebug(( fname, "NFMSsend_two_buffers <0x%.8x>\n", status ));

    if( _NFMdebug_st.NFMSdebug_on )
    {
	MEMprint_buffers( "BUFFER LIST", ret_list,
			  _NFMdebug_st.NFMSdebug_file );
	MEMprint_buffers( "SYNONYM LIST", syn_list, 
			  _NFMdebug_st.NFMSdebug_file);
    }

    MEMclose( &buffer );
    MEMclose( &ret_list );
    MEMclose( &syn_list );

    return (NFM_S_SUCCESS);
}

long NFMSftr_search (in_list)

MEMptr in_list;

{
long   status;
long   ret_status;
int    no_buffers;
int    i;
char   **data_ptr;
char   **data_ptr2;
MEMptr buffer = NULL;
MEMptr ret_list = NULL;
MEMptr syn_list = NULL;
static char *fname = "NFMSftr_search";

    status = MEMno_buffers (in_list, &no_buffers);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMno_buffers : <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return (NFM_E_MEM);
    }
    _NFMSdebug(( fname, "Number of buffers <%d>\n", no_buffers ));

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return (NFM_E_MEM);
    }

    buffer = NULL;
    if( no_buffers > 1 )
    {
        status = MEMreset_buffer_no (in_list, 2);
        if (status == MEM_S_SUCCESS)
        {
            status = MEMsplit_copy_buffer (in_list, &buffer, 0);
            if (status != MEM_S_SUCCESS)
            {
                MEMclose (&buffer);
                _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
                ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
                return (NFM_E_MEM);
            }
   	    data_ptr2 = (char**)buffer->data_ptr;

	    for( i=0; i<(buffer->rows*buffer->columns); i+=buffer->columns )
	        _NFMSdebug(( fname, "Catalog <%s>\n", data_ptr2[i] ));
        }
    }
    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return (NFM_E_MEM);
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Item Search <%s>\n", data_ptr[0] ));
    _NFMSdebug(( fname, "Item Sort   <%s>\n", data_ptr[1] ));
    _NFMSdebug(( fname, "Row Size    <%s>\n", data_ptr[2] ));
    _NFMSdebug(( fname, "cursor_id   <%s>\n", data_ptr[3] ));
    _NFMSdebug(( fname, "ftr_search   <%s>\n", data_ptr[4] ));

    ret_status = NFMftr_search( buffer, data_ptr[0],
		data_ptr[1], &ret_list, &syn_list, atol(data_ptr[2]),
		atol(data_ptr[3]), data_ptr[4] );

    _NFMSdebug(( fname,"NFMftr_search <0x%.8x>\n", ret_status));
    if  ((ret_status != NFM_S_SUCCESS) && 
	 (ret_status != NFM_I_NO_MORE_BUFFERS) &&
         (ret_status != NFM_I_SAC_SOME_CATALOGS))
    {
	MEMclose( &ret_list);
	MEMclose( &buffer );
	MEMclose( &syn_list );
	ret_list = NULL;
	syn_list = NULL;
    }

    status = NFMSsend_two_buffers( ret_status, ret_list, syn_list );
    _NFMSdebug(( fname, "NFMSsend_two_buffers <0x%.8x>\n", status ));

    if( _NFMdebug_st.NFMSdebug_on )
    {
	MEMprint_buffers( "BUFFER LIST", ret_list,
			  _NFMdebug_st.NFMSdebug_file );
	MEMprint_buffers( "SYNONYM LIST", syn_list, 
			  _NFMdebug_st.NFMSdebug_file);
    }

    MEMclose( &buffer );
    MEMclose( &ret_list );
    MEMclose( &syn_list );

    return (NFM_S_SUCCESS);
}
