#include "machine.h"
#include "NFMRextern.h"

#define    BUFFER_SIZE    1000

long NFMRmultiple_catalog_search ( cat_buffer,
                 item_search_str, item_sort_str,
		 out_buffer_list, syn_list)

  MEMptr         cat_buffer;      /*  I Buffer of catalog names. */
  char           *item_search_str; /*  I Item search string. */
  char           *item_sort_str;   /*  I Item sort string. */
  MEMptr         *out_buffer_list; /*  O Output buffer. */
  MEMptr         *syn_list;        /*  O Synonym list. */
{
MEMptr info = NULL;
char   *str;
char   **data_ptr;
char   fmt[20];
long   status = 0;
long   ret_status = 0;
int    i;

static char *fname = "NFMRsearch_across_catalogs";

    status = MEMbuild_array( cat_buffer );
    if( status != MEM_S_SUCCESS )
    {
	_NFMRdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    data_ptr = (char**) cat_buffer->data_ptr;

    for( i=0; i<(cat_buffer->rows*cat_buffer->columns);i+=cat_buffer->columns )
	_NFMRdebug(( fname, "Catalog <%s>\n", data_ptr[i] ));

    _NFMRdebug(( fname, "item_search_str : <%s>\n", item_search_str));
    _NFMRdebug(( fname, "item_sort_str   : <%s>\n", item_sort_str));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    sprintf( fmt, "char(%d)", (strlen(item_search_str)+1));    
    status = MEMwrite_format (info, "item_search", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    sprintf( fmt, "char(%d)", (strlen(item_sort_str)+1));
    status = MEMwrite_format (info, "item_sort", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    str = (char*)malloc( strlen(item_search_str)+ strlen(item_sort_str)+10);
    strcpy (str, item_search_str);
    strcat (str, "\1");
    strcat (str, item_sort_str);
    strcat (str, "\1");

    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    status = MEMappend (info, cat_buffer );
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMappend : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_SEARCH_ACROSS_CATALOGS, cat_buffer);
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
	MEMclose( &info );
        _NFMRdebug(( fname, "NFMcl_send_buffer : <0x%.8x>\n", status));
        return (status);
    }
 
    MEMclose( &info );

    status = NFMRreceive_two_buffers (&NFMRglobal.NETid, &ret_status, 
		out_buffer_list, syn_list);
    _NFMRdebug(( fname, "NFMRreceive_two_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));
    if (ret_status != NFM_S_SUCCESS)
        return (ret_status);

    return( NFM_S_SUCCESS );

}


long NFMRblock_multiple_catalog_search ( cat_buffer,
                 item_search_str, item_sort_str,
		 out_buffer_list, syn_list, row_size)

  MEMptr         cat_buffer;       /*  I Buffer of catalog names. */
  char           *item_search_str; /*  I Item search string. */
  char           *item_sort_str;   /*  I Item sort string. */
  MEMptr         *out_buffer_list; /*  O Output buffer. */
  MEMptr         *syn_list;        /*  O Synonym list. */
  long		 row_size;	   /*  I Rows to return. */
{
MEMptr info = NULL;
char   *str;
char   **data_ptr;
char   fmt[20];
long   status = 0;
long   ret_status = 0;
int    i;

static char *fname = "NFMRblock_search_across_catalogs";


    _NFMRdebug(( fname, "item_search_str : <%s>\n", item_search_str));
    _NFMRdebug(( fname, "item_sort_str   : <%s>\n", item_sort_str));
    _NFMRdebug(( fname, "row_size        : <%ld>\n", row_size));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    sprintf( fmt, "char(%d)", (strlen(item_search_str)+1));    
    status = MEMwrite_format (info, "item_search", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    sprintf( fmt, "char(%d)", (strlen(item_sort_str)+1));
    status = MEMwrite_format (info, "item_sort", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    status = MEMwrite_format (info, "row_size", "integer" );
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    str = (char*)malloc( strlen(item_search_str)+ strlen(item_sort_str)+10);
    strcpy (str, item_search_str);
    strcat (str, "\1");
    strcat (str, item_sort_str);
    strcat (str, "\1");
    sprintf(fmt, "%ld\n", row_size );
    strcat (str, fmt );
    strcat (str, "\1" );

    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    if( cat_buffer != NULL )
    {
        status = MEMbuild_array( cat_buffer );
        if( status != MEM_S_SUCCESS )
        {
  	    _NFMRdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            return (NFM_E_MEM);
        }
        data_ptr = (char**) cat_buffer->data_ptr;
  
        for( i=0; i<(cat_buffer->rows*cat_buffer->columns);i+=cat_buffer->columns )
  	    _NFMRdebug(( fname, "Catalog <%s>\n", data_ptr[i] ));
    
        status = MEMappend (cat_buffer, info );
        if (status != MEM_S_SUCCESS)
        {
            MEMclose (&info);
            _NFMRdebug(( fname, "MEMappend : <0x%.8x>\n", status));
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            return (NFM_E_MEM);
        }
    }

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_BLOCK_SEARCH_ACROSS_CATALOGS, info);
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
	MEMclose( &info );
        _NFMRdebug(( fname, "NFMcl_send_buffer : <0x%.8x>\n", status));
        return (status);
    }
 
    MEMclose( &info );

    status = NFMRreceive_two_buffers (&NFMRglobal.NETid, &ret_status, 
		out_buffer_list, syn_list);
    _NFMRdebug(( fname, "NFMRreceive_two_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));
    if (ret_status != NFM_S_SUCCESS)
        return (ret_status);

    return( NFM_S_SUCCESS );

}


