#include "machine.h"
#include "NFMRextern.h"

#define    BUFFER_SIZE    1000
 
long NFMRpurge_versions (catalog_name, item_name, item_rev)

char    *catalog_name; /* i - catalog to add this item */
char    *item_name;    /* i - item to be purged */
char    *item_rev;     /* i - revision of item to be purged */

{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;


static char *fname = "NFMRpurge_versions";

    _NFMRdebug(( fname, "catalog : <%s>\n", catalog_name));
    _NFMRdebug(( fname, "item    : <%s>\n", item_name));
    _NFMRdebug(( fname, "rev     : <%s>\n", item_rev));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf( fmt, "char(%d)", NFM_CATALOGNAME );    
    status = MEMwrite_format (info, "catalog_name", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_ITEMNAME );
    status = MEMwrite_format (info, "item_name", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_ITEMREV );
    status = MEMwrite_format (info, "item_rev", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( NFM_CATALOGNAME + NFM_ITEMNAME + NFM_ITEMREV );

    strcpy (str, catalog_name);
    strcat (str, "\1");
    strcat (str, item_name);
    strcat (str, "\1");
    strcat (str, item_rev);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
	free (str);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        return (status);
    }
    
    free (str);

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_PURGE_VERSIONS, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "NFMcl_send_buffer : <0x%.8x>\n", status));
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_error_buffers (&NFMRglobal.NETid, &ret_status);
    _NFMRdebug(( fname, "NFMRreceive_error_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return (ret_status); 

    return( NFM_S_SUCCESS );
}
 
long NFMRroll_version_forward (catalog_name, item_name, item_rev, data_list)

char    *catalog_name; /* i - catalog for this item */
char    *item_name;    /* i - item to be rolled forward */
char    *item_rev;     /* i - revision of item to be rolled forward */
MEMptr  data_list;     /* i - File level information */
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRroll_version_forward";

    _NFMRdebug(( fname, "catalog : <%s>\n", catalog_name));
    _NFMRdebug(( fname, "item    : <%s>\n", item_name));
    _NFMRdebug(( fname, "rev     : <%s>\n", item_rev));

    if( _NFMdebug_st.NFMRdebug_on )
	MEMprint_buffers( "VERSION LIST", data_list, _NFMdebug_st.NFMRdebug_file );

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", NFM_CATALOGNAME );
    status = MEMwrite_format (info, "catalog_name", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_ITEMNAME );    
    status = MEMwrite_format (info, "item_name", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", NFM_ITEMREV );
    status = MEMwrite_format (info, "item_rev", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( NFM_CATALOGNAME + NFM_ITEMNAME + NFM_ITEMREV );
    
    strcpy (str, catalog_name);
    strcat (str, "\1");
    strcat (str, item_name);
    strcat (str, "\1");
    strcat (str, item_rev);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
	free (str);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);

    status = MEMappend (data_list, info);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMappend : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_ROLL_VERSION_FORWARD, info);
    _NFMRdebug(( fname, "Send Buffer <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "NFMcl_send_buffer : <0x%.8x>\n", status));
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_error_buffers (&NFMRglobal.NETid, &ret_status);
    _NFMRdebug(( fname, "NFMRreceive_error_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return (ret_status); 

    return( NFM_S_SUCCESS );
}

 
long NFMRget_item_versions (catalog_name, item_name, item_rev, syn_list,
			   data_list)

char    *catalog_name; /* i - catalog for this item */
char    *item_name;    /* i - item to be rolled forward */
char    *item_rev;     /* i - revision of item to be rolled forward */
MEMptr  *syn_list;      /* o - synonym list */
MEMptr  *data_list;     /* o - data list */
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRget_item_versions";

    _NFMRdebug(( fname, "catalog : <%s>\n", catalog_name));
    _NFMRdebug(( fname, "item    : <%s>\n", item_name));
    _NFMRdebug(( fname, "rev     : <%s>\n", item_rev));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", NFM_CATALOGNAME );
    status = MEMwrite_format (info, "catalog_name", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_ITEMNAME );    
    status = MEMwrite_format (info, "item_name", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", NFM_ITEMREV );
    status = MEMwrite_format (info, "item_rev", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( NFM_CATALOGNAME + NFM_ITEMNAME + NFM_ITEMREV );
    
    strcpy (str, catalog_name);
    strcat (str, "\1");
    strcat (str, item_name);
    strcat (str, "\1");
    strcat (str, item_rev);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
	free (str);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    free (str);

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_GET_ITEM_VERSIONS, info);
    _NFMRdebug(( fname, "Send Buffer <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "NFMcl_send_buffer : <0x%.8x>\n", status));
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers (&NFMRglobal.NETid, &ret_status, 
		syn_list, data_list);
    _NFMRdebug(( fname, "NFMRreceive_two_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return (ret_status); 

    if(_NFMdebug_st.NFMRdebug_on)
    {
        MEMprint_buffers( "SYN LIST",  *syn_list,
                           _NFMdebug_st.NFMRdebug_file );
        MEMprint_buffers( "DATA LIST", *data_list,
                           _NFMdebug_st.NFMRdebug_file );
    }

    return( NFM_S_SUCCESS );
}

