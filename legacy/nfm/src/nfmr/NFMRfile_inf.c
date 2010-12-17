#include "machine.h"
#include "NFMRextern.h"

#define    BUFFER_SIZE    1000

long NFMRget_file_information (catalog_name, item_name, item_revision,
  	operation, attr_list, data_list, value_list )
   char            *catalog_name;   /* I  Item's catalog. */
   char            *item_name;      /* I  Item name. */
   char            *item_revision;  /* I  Item revision. */
   long		   operation;	    /* I  Type of operation. */
   MEMptr	   *attr_list;	    /* O  List of file attributes */
   MEMptr	   *data_list;      /* O  List of file data */
   MEMptr 	   *value_list;	    /* O  List of file attibute values */
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRget_file_information";

    _NFMRdebug(( fname, "catalog         : <%s>\n", catalog_name));
    _NFMRdebug(( fname, "item            : <%s>\n", item_name ));
    _NFMRdebug(( fname, "revision        : <%s>\n", item_revision ));
    _NFMRdebug(( fname, "operation       : <%ld>\n", operation));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    sprintf( fmt, "char(%d)", NFM_CATALOGNAME );    
    status = MEMwrite_format (info, "catalog_name", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    sprintf( fmt, "char(%d)", NFM_ITEMNAME);    
    status = MEMwrite_format (info, "item_name", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    sprintf( fmt, "char(%d)", NFM_ITEMREV );    
    status = MEMwrite_format (info, "item_revision", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    status = MEMwrite_format (info, "operation", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    str = (char*)malloc( NFM_CATALOGNAME +  NFM_ITEMNAME + NFM_ITEMREV +
			 INTEGER );
    strcpy (str, catalog_name);
    strcat (str, "\1");
    strcat (str, item_name);
    strcat (str, "\1");
    strcat (str, item_revision);
    strcat (str, "\1");
    sprintf(fmt, "%ld", operation );
    strcat (str, fmt);
    strcat (str, "\1");

    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    free (str);

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_GET_FILE_INFO, info);
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "NFMcl_send_buffer : <0x%.8x>\n", status));
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_three_buffers (&NFMRglobal.NETid, &ret_status, 
		attr_list, data_list, value_list);
    _NFMRdebug((fname, "NFMRreceive_three_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
	return( ret_status );

    if (_NFMdebug_st.NFMRdebug_on)
    {
        MEMprint_buffers ("ATTR LIST", *attr_list,_NFMdebug_st.NFMRdebug_file);
        MEMprint_buffers ("DATA LIST", *data_list,_NFMdebug_st.NFMRdebug_file);
        MEMprint_buffers ("VAL LIST", *value_list,_NFMdebug_st.NFMRdebug_file);
    }

    return( NFM_S_SUCCESS );
}


 
long NFMRdefine_file_information (catalog_name, item_name, item_revision,
 	                          operation, data_list )
   char            *catalog_name;  /* I  Item's catalog name. */
   char            *item_name;     /* I  Item name. */
   char            *item_revision; /* I  Item revision. */
   long		   operation;	   /* I  Type of operation */
   MEMptr	   data_list;      /* I  Data needed to define file
					 information. (data_list
					 returned from NFMget_file_info) */
{
MEMptr info       = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdefine_file_information";

    _NFMRdebug(( fname, "catalog         : <%s>\n", catalog_name));
    _NFMRdebug(( fname, "item            : <%s>\n", item_name ));
    _NFMRdebug(( fname, "revision        : <%s>\n", item_revision ));
    _NFMRdebug(( fname, "operation       : <%ld>\n", operation ));
    if( _NFMdebug_st.NFMRdebug_on )
        MEMprint_buffers ("DATA LIST", data_list,_NFMdebug_st.NFMRdebug_file);

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    sprintf( fmt, "char(%d)", NFM_CATALOGNAME );    
    status = MEMwrite_format (info, "catalog_name", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    sprintf( fmt, "char(%d)", NFM_ITEMNAME );    
    status = MEMwrite_format (info, "item_name", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    sprintf( fmt, "char(%d)", NFM_ITEMREV );    
    status = MEMwrite_format (info, "item_revision", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    status = MEMwrite_format (info, "operation", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    str = (char*)malloc( NFM_CATALOGNAME + NFM_ITEMNAME + NFM_ITEMREV 
			 + INTEGER);

    strcpy (str, catalog_name);
    strcat (str, "\1");
    strcat (str, item_name);
    strcat (str, "\1");
    strcat (str, item_revision);
    strcat (str, "\1");
    sprintf(fmt, "%ld", operation );
    strcat (str, fmt );
    strcat (str, "\1" );
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
	free (str);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    free (str);

    status = MEMappend (data_list, info);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMappend : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_DEFINE_FILE_INFO, info);
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "NFMcl_send_buffer : <0x%.8x>\n", status));
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_error_buffers(&NFMRglobal.NETid, &ret_status );
    _NFMRdebug((fname, "NFMRreceive_error_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return (ret_status); 

    return( NFM_S_SUCCESS );
}

 
long NFMRreset_file_information (catalog_name, item_name, item_revision )

   char            *catalog_name;  /* I  Item's catalog name. */
   char            *item_name;     /* I  Item name. */
   char            *item_revision; /* I  Item revision. */
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRreset_file_information";

    _NFMRdebug(( fname, "catalog         : <%s>\n", catalog_name));
    _NFMRdebug(( fname, "item            : <%s>\n", item_name ));
    _NFMRdebug(( fname, "revision        : <%s>\n", item_revision ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    sprintf( fmt, "char(%d)", NFM_CATALOGNAME );    
    status = MEMwrite_format (info, "n_catalogname", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
         _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    sprintf( fmt, "char(%d)", NFM_ITEMNAME );    
    status = MEMwrite_format (info, "n_itemname", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    sprintf( fmt, "char(%d)", NFM_ITEMREV );    
    status = MEMwrite_format (info, "n_itemrev", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    str = (char*)malloc( NFM_CATALOGNAME + NFM_ITEMNAME + NFM_ITEMREV );

    strcpy (str, catalog_name);
    strcat (str, "\1");
    strcat (str, item_name);
    strcat (str, "\1");
    strcat (str, item_revision);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
	free (str);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    free (str);

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_RESET_FILE_INFO, info);
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "NFMcl_send_buffer : <0x%.8x>\n", status));
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_error_buffers(&NFMRglobal.NETid, &ret_status);
    _NFMRdebug((fname, "NFMRreceive_error_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return (ret_status); 

    return( NFM_S_SUCCESS );
}

