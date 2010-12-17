#include "machine.h"
#include   "NFMRextern.h"
#define    BUFFER_SIZE    1000
 

long NFMRdisplay_nodes (search, sort, type, syn_list, data_list)

   char            *search;          /* I  Search string for select clause. */
   char            *sort;            /* I  Sort string for order by clause. */
   int             type;             /* I  (NFM_FULL_DISPLAY or
                                            NFM_SHORT_DISPLAY). */
   MEMptr          *syn_list;        /* O  Synonym list. */
   MEMptr          *data_list;       /* O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdisplay_nodes";

    _NFMRdebug(( fname, "search  : <%s>\n", search ));
    _NFMRdebug(( fname, "sort    : <%s>\n", sort ));
    _NFMRdebug(( fname, "type    : <%d>\n", type ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format(dis_type) : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(search)+1));    
    status = MEMwrite_format (info, "search", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format(search) : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(sort)+1) );
    status = MEMwrite_format (info, "sort", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format(sort) : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMwrite_format (info, "type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format(type) : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( INTEGER*2 + strlen(search) + strlen(sort) );

    sprintf(str, "%d", DSP_DISPLAY_NODES );
    strcat (str, "\1" );
    strcat (str, search);
    strcat (str, "\1");
    strcat (str, sort);
    strcat (str, "\1");
    sprintf(fmt, "%d", type );
    strcat (str, fmt);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers(&NFMRglobal.NETid, &ret_status,syn_list,data_list);
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
 
long NFMRdisplay_storage_areas (search, sort, type, syn_list, data_list)

   char            *search;         /* I  Search string for select clause. */
   char            *sort;           /* I  Sort string for order by clause. */
   int             type;            /* I  (NFM_FULL_DISPLAY or
                                          NFM_SHORT_DISPLAY). */
   MEMptr          *syn_list;       /* O  Synonym list. */
   MEMptr          *data_list;      /* O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdisplay_storage_areas";

    _NFMRdebug(( fname, "search  : <%s>\n", search ));
    _NFMRdebug(( fname, "sort    : <%s>\n", sort ));
    _NFMRdebug(( fname, "type    : <%d>\n", type ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", (strlen( search ) + 1 ) );
    status = MEMwrite_format (info, "search", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(sort)+1) );
    status = MEMwrite_format (info, "sort", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMwrite_format (info, "type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( INTEGER*2 + strlen(search) + strlen(sort) );

    sprintf(str, "%d", DSP_DISPLAY_STORAGE_AREAS );
    strcat (str, "\1" );
    strcat (str, search);
    strcat (str, "\1");
    strcat (str, sort);
    strcat (str, "\1");
    sprintf(fmt, "%d", type );
    strcat (str, fmt);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers(&NFMRglobal.NETid, &ret_status,syn_list,data_list);
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
 

long NFMRdisplay_working_areas (search, sort, type, syn_list, data_list)

   char            *search;         /* I  Search string for select clause. */
   char            *sort;           /* I  Sort string for order by clause. */
   int             type;            /* I  (NFM_FULL_DISPLAY or
                                          NFM_SHORT_DISPLAY). */
   MEMptr          *syn_list;       /* O  Synonym list. */
   MEMptr          *data_list;      /* O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdisplay_working_areas";

    _NFMRdebug(( fname, "search  : <%s>\n", search ));
    _NFMRdebug(( fname, "sort    : <%s>\n", sort ));
    _NFMRdebug(( fname, "type    : <%d>\n", type ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", (strlen( search ) + 1 ) );
    status = MEMwrite_format (info, "search", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(sort)+1) );
    status = MEMwrite_format (info, "sort", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMwrite_format (info, "type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( INTEGER*2 + strlen(search) + strlen(sort) );

    sprintf(str, "%d", DSP_DISPLAY_WORKING_AREAS );
    strcat (str, "\1" );
    strcat (str, search);
    strcat (str, "\1");
    strcat (str, sort);
    strcat (str, "\1");
    sprintf(fmt, "%d", type );
    strcat (str, fmt);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers(&NFMRglobal.NETid, &ret_status,syn_list,data_list);
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
 
long NFMRdisplay_users (search, sort, type, syn_list, data_list)

   char            *search;         /* I  Search string for select clause. */
   char            *sort;           /* I  Sort string for order by clause. */
   int             type;            /* I  (NFM_FULL_DISPLAY or
                                          NFM_SHORT_DISPLAY). */
   MEMptr          *syn_list;       /* O  Synonym list. */
   MEMptr          *data_list;      /* O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdisplay_users";

    _NFMRdebug(( fname, "search  : <%s>\n", search ));
    _NFMRdebug(( fname, "sort    : <%s>\n", sort ));
    _NFMRdebug(( fname, "type    : <%d>\n", type ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", (strlen(search)+1) );
    status = MEMwrite_format (info, "search", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(sort)+1));
    status = MEMwrite_format (info, "sort", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMwrite_format (info, "type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( INTEGER*2 + strlen(search) + strlen(sort) );
 
    sprintf(str, "%d", DSP_DISPLAY_USERS );
    strcat (str, "\1" );
    strcat (str, search);
    strcat (str, "\1");
    strcat (str, sort);
    strcat (str, "\1");
    sprintf(fmt, "%d", type );
    strcat (str, fmt);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers(&NFMRglobal.NETid, &ret_status,syn_list,data_list);
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

long NFMRdisplay_catalogs (search, sort, type, syn_list, data_list)

   char            *search;         /* I  Search string for select clause. */
   char            *sort;           /* I  Sort string for order by clause. */
   int             type;            /* I  (NFM_FULL_DISPLAY or
                                          NFM_SHORT_DISPLAY). */
   MEMptr          *syn_list;       /* O  Synonym list. */
   MEMptr          *data_list;      /* O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdisplay_catalogs";

    _NFMRdebug(( fname, "search  : <%s>\n", search ));
    _NFMRdebug(( fname, "sort    : <%s>\n", sort ));
    _NFMRdebug(( fname, "type    : <%d>\n", type ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", (strlen(search)+1) );
    status = MEMwrite_format (info, "search", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(sort)+1));
    status = MEMwrite_format (info, "sort", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMwrite_format (info, "type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( INTEGER*2 + strlen(search) + strlen(sort) );

    sprintf(str, "%d", DSP_DISPLAY_CATALOGS );
    strcat (str, "\1" );
    strcat (str, search);
    strcat (str, "\1");
    strcat (str, sort);
    strcat (str, "\1");
    sprintf(fmt, "%d", type );
    strcat (str, fmt);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers(&NFMRglobal.NETid, &ret_status, syn_list, data_list);
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
 
long NFMRdisplay_items (catalog, search, sort, type, syn_list, data_list)

   char		   *catalog;	    /* I  Catalog name. */
   char            *search;         /* I  Search string for select clause. */
   char            *sort;           /* I  Sort string for order by clause. */
   int             type;            /* I  (NFM_FULL_DISPLAY or
                                          NFM_SHORT_DISPLAY). */
   MEMptr          *syn_list;       /* O  Synonym list. */
   MEMptr          *data_list;      /* O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdisplay_items";

    _NFMRdebug(( fname, "catalog : <%s>\n", catalog));
    _NFMRdebug(( fname, "search  : <%s>\n", search ));
    _NFMRdebug(( fname, "sort    : <%s>\n", sort ));
    _NFMRdebug(( fname, "type    : <%d>\n", type ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", NFM_CATALOGNAME );    
    status = MEMwrite_format (info, "catalog", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(search)+1));
    status = MEMwrite_format (info, "search", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(sort)+1));
    status = MEMwrite_format (info, "sort", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMwrite_format (info, "type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( NFM_CATALOGNAME + INTEGER*2 + strlen(search) +
	  strlen(sort) );

    sprintf(str, "%d", DSP_DISPLAY_ITEMS );
    strcat (str, "\1" );
    strcat (str, catalog);
    strcat (str, "\1");
    strcat (str, search);
    strcat (str, "\1");
    strcat (str, sort);
    strcat (str, "\1");
    sprintf(fmt, "%d", type );
    strcat (str, fmt);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers(&NFMRglobal.NETid, &ret_status,syn_list,data_list);
    _NFMRdebug(( fname, "NFMRreceive_two_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return (ret_status); 
/*
    if(_NFMdebug_st.NFMRdebug_on)
    {
        MEMprint_buffers( "SYN LIST",  *syn_list,
                           _NFMdebug_st.NFMRdebug_file );
        MEMprint_buffers( "DATA LIST", *data_list,
                           _NFMdebug_st.NFMRdebug_file );
    }
*/
    return( NFM_S_SUCCESS );
}


long NFMRdisplay_items_partial (catalog, search, sort, type, rows, 
				syn_list, data_list)

   char		   *catalog;	    /* I  Catalog name. */
   char            *search;         /* I  Search string for select clause. */
   char            *sort;           /* I  Sort string for order by clause. */
   int             type;            /* I  (NFM_FULL_DISPLAY or
                                          NFM_SHORT_DISPLAY). */
   long		   rows;	    /* I  Number of rows to return. */
   MEMptr          *syn_list;       /* O  Synonym list. */
   MEMptr          *data_list;      /* O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdisplay_items_partial";

    _NFMRdebug(( fname, "catalog : <%s>\n", catalog));
    _NFMRdebug(( fname, "search  : <%s>\n", search ));
    _NFMRdebug(( fname, "sort    : <%s>\n", sort ));
    _NFMRdebug(( fname, "type    : <%d>\n", type ));
    _NFMRdebug(( fname, "rows    : <%ld>\n", rows ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", NFM_CATALOGNAME );    
    status = MEMwrite_format (info, "catalog", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(search)+1));
    status = MEMwrite_format (info, "search", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(sort)+1));
    status = MEMwrite_format (info, "sort", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMwrite_format (info, "type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMwrite_format (info, "rows", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( NFM_CATALOGNAME + INTEGER*3 + strlen(search) +
	  strlen(sort) );

    sprintf(str, "%d", DSP_DISPLAY_ITEMS_PARTIAL );
    strcat (str, "\1" );
    strcat (str, catalog);
    strcat (str, "\1");
    strcat (str, search);
    strcat (str, "\1");
    strcat (str, sort);
    strcat (str, "\1");
    sprintf(fmt, "%d", type );
    strcat (str, fmt);
    strcat (str, "\1");
    sprintf(fmt, "%d", rows );
    strcat (str, fmt);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers(&NFMRglobal.NETid, &ret_status,syn_list,data_list);
    _NFMRdebug(( fname, "NFMRreceive_two_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));
/* 
    if(_NFMdebug_st.NFMRdebug_on)
    {
        MEMprint_buffers( "SYN LIST",  *syn_list,
                           _NFMdebug_st.NFMRdebug_file );
        MEMprint_buffers( "DATA LIST", *data_list,
                           _NFMdebug_st.NFMRdebug_file );
    }
*/
    if( ret_status != NFM_S_SUCCESS )
        return (ret_status); 

    return( NFM_S_SUCCESS );
}


long NFMRdisplay_item_files (catalog, item, rev, search, sort, 
			     syn_list, data_list)

   char		   *catalog;	    /* I  Catalog name. */
   char		   *item;	    /* I  Item name. */
   char		   *rev;	    /* I  Revision. */
   char            *search;         /* I  Search string for select clause. */
   char            *sort;           /* I  Sort string for order by clause. */
   MEMptr          *syn_list;       /* O  Synonym list. */
   MEMptr          *data_list;      /* O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdisplay_item_files";

    _NFMRdebug(( fname, "catalog : <%s>\n", catalog));
    _NFMRdebug(( fname, "item    : <%s>\n", item));
    _NFMRdebug(( fname, "rev     : <%s>\n", rev));
    _NFMRdebug(( fname, "search  : <%s>\n", search ));
    _NFMRdebug(( fname, "sort    : <%s>\n", sort ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_CATALOGNAME );    
    status = MEMwrite_format (info, "catalog", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", NFM_ITEMNAME );    
    status = MEMwrite_format (info, "item", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", NFM_ITEMREV );    
    status = MEMwrite_format (info, "revision", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(search)+1) );
    status = MEMwrite_format (info, "search", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(sort)+1) );
    status = MEMwrite_format (info, "sort", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( NFM_CATALOGNAME + NFM_ITEMNAME + NFM_ITEMREV +
	  INTEGER + strlen(search) + strlen(sort) );
 
    sprintf(str, "%d", DSP_DISPLAY_ITEM_FILES );
    strcat (str, "\1" );
    strcat (str, catalog);
    strcat (str, "\1");
    strcat (str, item );
    strcat (str, "\1" );
    strcat (str, rev );
    strcat (str, "\1" );
    strcat (str, search);
    strcat (str, "\1");
    strcat (str, sort);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers (&NFMRglobal.NETid, &ret_status,syn_list,data_list);
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
 
long NFMRdisplay_workflows (search, sort, type, syn_list, data_list)

   char            *search;          /*  I  Search string. */
   char            *sort;            /*  I  Sort string. */
   int             type;             /*  I  (NFM_FULL_DISPLAY or
                                             NFM_SHORT_DISPLAY). */
   MEMptr          *syn_list;        /*  O  Synonym list. */
   MEMptr          *data_list;       /*  O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdisplay_workflows";

    _NFMRdebug(( fname, "search  : <%s>\n", search ));
    _NFMRdebug(( fname, "sort    : <%s>\n", sort ));
    _NFMRdebug(( fname, "type    : <%d>\n", type ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", (strlen(search)+1) );
    status = MEMwrite_format (info, "search", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(sort)+1) );
    status = MEMwrite_format (info, "sort", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMwrite_format (info, "type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( INTEGER*2 + strlen(search) + strlen(sort) );

    sprintf(str, "%d", DSP_DISPLAY_WORKFLOWS );
    strcat (str, "\1" );
    strcat (str, search);
    strcat (str, "\1");
    strcat (str, sort);
    strcat (str, "\1");
    sprintf(fmt, "%d", type );
    strcat (str, fmt);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers (&NFMRglobal.NETid, &ret_status,syn_list,data_list);
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
 
long NFMRdisplay_acls (wf_name, search, sort, type, syn_list, data_list)

   char 	   *wf_name;	     /*  I  Workflow name. */
   char            *search;          /*  I  Search string. */
   char            *sort;            /*  I  Sort string. */
   int             type;             /*  I  (NFM_FULL_DISPLAY or
                                             NFM_SHORT_DISPLAY). */
   MEMptr          *syn_list;        /*  O  Synonym list. */
   MEMptr          *data_list;       /*  O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdisplay_acls";

    _NFMRdebug(( fname, "wf_name : <%s>\n", wf_name ));
    _NFMRdebug(( fname, "search  : <%s>\n", search ));
    _NFMRdebug(( fname, "sort    : <%s>\n", sort ));
    _NFMRdebug(( fname, "type    : <%d>\n", type ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_WORKFLOWNAME );    
    status = MEMwrite_format (info, "wf_name", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(search)+1) );
    status = MEMwrite_format (info, "search", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(sort)+1));
    status = MEMwrite_format (info, "sort", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMwrite_format (info, "type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( NFM_WORKFLOWNAME + INTEGER*2 + 
	  strlen(search) + strlen(sort) );

    sprintf(str, "%d", DSP_DISPLAY_ACLS );
    strcat (str, "\1" );
    strcat (str, wf_name);
    strcat (str, "\1" );
    strcat (str, search);
    strcat (str, "\1");
    strcat (str, sort);
    strcat (str, "\1");
    sprintf(fmt, "%d", type );
    strcat (str, fmt);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers(&NFMRglobal.NETid, &ret_status, syn_list,data_list );
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

long NFMRdisplay_classes (wf_name, search, sort, type, syn_list, data_list)

   char            *wf_name;         /*  I  Workflow name. */
   char            *search;          /*  I  Search string for select clause. */
   char            *sort;            /*  I  Sort string for order by clause. */
   int             type;             /*  I  (NFM_FULL_DISPLAY or
                                          NFM_SHORT_DISPLAY). */
   MEMptr          *syn_list;        /*  O  Synonym list. */
   MEMptr          *data_list;       /*  O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdisplay_classes";

    _NFMRdebug(( fname, "wf_name : <%s>\n", wf_name ));
    _NFMRdebug(( fname, "search  : <%s>\n", search ));
    _NFMRdebug(( fname, "sort    : <%s>\n", sort ));
    _NFMRdebug(( fname, "type    : <%d>\n", type ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_WORKFLOWNAME );    
    status = MEMwrite_format (info, "wf_name", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(search)+1));
    status = MEMwrite_format (info, "search", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(sort)+1));
    status = MEMwrite_format (info, "sort", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMwrite_format (info, "type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( NFM_WORKFLOWNAME + INTEGER*2 + 
	  strlen(search) + strlen(sort) );

    sprintf(str, "%d", DSP_DISPLAY_CLASSES );
    strcat (str, "\1" );
    strcat (str, wf_name);
    strcat (str, "\1" );
    strcat (str, search);
    strcat (str, "\1");
    strcat (str, sort);
    strcat (str, "\1");
    sprintf(fmt, "%d", type );
    strcat (str, fmt);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers(&NFMRglobal.NETid, &ret_status, syn_list, data_list);
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

long NFMRdisplay_programs (search, sort, type, syn_list, data_list)

   char            *search;          /* I  Search string for select clause. */
   char            *sort;            /* I  Sort string for order by clause. */
   int             type;             /* I  (NFM_FULL_DISPLAY or
                                            NFM_SHORT_DISPLAY). */
   MEMptr          *syn_list;        /* O  Synonym list. */
   MEMptr          *data_list;       /* O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdisplay_programs";

    _NFMRdebug(( fname, "search  : <%s>\n", search ));
    _NFMRdebug(( fname, "sort    : <%s>\n", sort ));
    _NFMRdebug(( fname, "type    : <%d>\n", type ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", (strlen(search)+1));
    status = MEMwrite_format (info, "search", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(sort)+1));
    status = MEMwrite_format (info, "sort", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMwrite_format (info, "type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( INTEGER*2 + strlen(search) + strlen(sort) );

    sprintf(str, "%d", DSP_DISPLAY_PROGRAMS );
    strcat (str, "\1" );
    strcat (str, search);
    strcat (str, "\1");
    strcat (str, sort);
    strcat (str, "\1");
    sprintf(fmt, "%d", type );
    strcat (str, fmt);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers(&NFMRglobal.NETid, &ret_status,syn_list,data_list);
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

long NFMRdisplay_querys (type, search, sort, l_type, syn_list, data_list)

   char            *type;             /* I  'W' for search criteria
                                            'O' for sort criteria. */
   char		   *search;	     /* I  Search string. */
   char		   *sort;	     /* I  Sort string. */
   int		   l_type;	     /* I  Type of list. */
   MEMptr          *syn_list;        /* O  Synonym list. */
   MEMptr          *data_list;       /* O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdisplay_querys";

    _NFMRdebug(( fname, "query type    : <%s>\n", type ));
    _NFMRdebug(( fname, "search        : <%s>\n", search ));
    _NFMRdebug(( fname, "sort          : <%s>\n", sort ));
    _NFMRdebug(( fname, "list type     : <%d>\n", l_type ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", strlen(type)+1 );
    status = MEMwrite_format (info, "type", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(search)+1));    
    status = MEMwrite_format (info, "search", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format(search) : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(sort)+1) );
    status = MEMwrite_format (info, "sort", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format(sort) : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMwrite_format (info, "l_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format(l_type) : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( INTEGER*2 + strlen(type) + strlen(search) 
			 + strlen(sort) );

    sprintf(str, "%d", DSP_DISPLAY_QUERYS );
    strcat (str, "\1" );
    strcat (str, type );
    strcat (str, "\1" );
    strcat (str, search );
    strcat (str, "\1" );
    strcat (str, sort );
    strcat (str, "\1" );
    sprintf(fmt, "%d", l_type );
    strcat (str, fmt);
    strcat (str, "\1");

    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers(&NFMRglobal.NETid, &ret_status,syn_list,data_list);
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
 
long NFMRdisplay_transitions (wf_name, search, sort, type, syn_list, data_list)

   char 	   *wf_name;	     /*  I  Workflow name. */
   char            *search;          /*  I  Search string. */
   char            *sort;            /*  I  Sort string. */
   int             type;             /*  I  (NFM_FULL_DISPLAY or
                                             NFM_SHORT_DISPLAY). */
   MEMptr          *syn_list;        /*  O  Synonym list. */
   MEMptr          *data_list;       /*  O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdisplay_transitions";

    _NFMRdebug(( fname, "wf_name : <%s>\n", wf_name ));
    _NFMRdebug(( fname, "search  : <%s>\n", search ));
    _NFMRdebug(( fname, "sort    : <%s>\n", sort ));
    _NFMRdebug(( fname, "type    : <%d>\n", type ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_WORKFLOWNAME );    
    status = MEMwrite_format (info, "wf_name", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(search)+1));
    status = MEMwrite_format (info, "search", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(sort)+1));
    status = MEMwrite_format (info, "sort", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMwrite_format (info, "type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( NFM_WORKFLOWNAME + INTEGER*2 + 
	  strlen(search) + strlen(sort) );

    sprintf(str, "%d", DSP_DISPLAY_TRANSITIONS );
    strcat (str, "\1" );
    strcat (str, wf_name);
    strcat (str, "\1" );
    strcat (str, search);
    strcat (str, "\1");
    strcat (str, sort);
    strcat (str, "\1");
    sprintf(fmt, "%d", type );
    strcat (str, fmt);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers(&NFMRglobal.NETid, &ret_status,syn_list,data_list);
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
 
long NFMRdisplay_aclusers (acl_name, search, sort, syn_list, data_list)

   char 	   *acl_name;	     /*  I  Acess control list name. */
   char            *search;          /*  I  Search string. */
   char            *sort;            /*  I  Sort string. */
   MEMptr          *syn_list;        /*  O  Synonym list. */
   MEMptr          *data_list;       /*  O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdisplay_aclusers";

    _NFMRdebug(( fname, "acl_name : <%s>\n", acl_name ));
    _NFMRdebug(( fname, "search  : <%s>\n", search ));
    _NFMRdebug(( fname, "sort    : <%s>\n", sort ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_ACLNAME );    
    status = MEMwrite_format (info, "acl_name", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(search)+1));
    status = MEMwrite_format (info, "search", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(sort)+1));
    status = MEMwrite_format (info, "sort", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( NFM_ACLNAME + INTEGER + 
	  strlen(search) + strlen(sort) );

    sprintf(str, "%d", DSP_DISPLAY_ACLUSERS );
    strcat (str, "\1" );
    strcat (str, acl_name);
    strcat (str, "\1" );
    strcat (str, search);
    strcat (str, "\1");
    strcat (str, sort);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers (&NFMRglobal.NETid, &ret_status, syn_list,
				       data_list);
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
 
long NFMRdisplay_archives (search, sort, syn_list, data_list)

   char            *search;         /* I  Search string for select clause. */
   char            *sort;           /* I  Sort string for order by clause. */
   MEMptr          *syn_list;       /* O  Synonym list. */
   MEMptr          *data_list;      /* O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdisplay_archives";

    _NFMRdebug(( fname, "search  : <%s>\n", search ));
    _NFMRdebug(( fname, "sort    : <%s>\n", sort ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", (strlen(search)+1));
    status = MEMwrite_format (info, "search", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(sort)+1));
    status = MEMwrite_format (info, "sort", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( strlen(search) + strlen(sort) + INTEGER );

    sprintf(str, "%d", DSP_DISPLAY_ARCHIVES );
    strcat (str, "\1" );
    strcat (str, search);
    strcat (str, "\1");
    strcat (str, sort);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers(&NFMRglobal.NETid, &ret_status, syn_list, data_list);
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

long NFMRdisplay_projects (search, sort, type, syn_list, data_list)

   char            *search;          /* I  Search string for select clause. */
   char            *sort;            /* I  Sort string for order by clause. */
   int             type;             /* I  (NFM_FULL_DISPLAY or
                                            NFM_SHORT_DISPLAY). */
   MEMptr          *syn_list;        /* O  Synonym list. */
   MEMptr          *data_list;       /* O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdisplay_projects";

    _NFMRdebug(( fname, "search  : <%s>\n", search ));
    _NFMRdebug(( fname, "sort    : <%s>\n", sort ));
    _NFMRdebug(( fname, "type    : <%d>\n", type ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", (strlen(search)+1));
    status = MEMwrite_format (info, "search", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(sort)+1));
    status = MEMwrite_format (info, "sort", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMwrite_format (info, "type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( INTEGER*2 + strlen(search) + strlen(sort) );

    sprintf(str, "%d", DSP_DISPLAY_PROJECTS );
    strcat (str, "\1" );
    strcat (str, search);
    strcat (str, "\1");
    strcat (str, sort);
    strcat (str, "\1");
    sprintf(fmt, "%d", type );
    strcat (str, fmt);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers(&NFMRglobal.NETid, &ret_status,syn_list,data_list);
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


long NFMRdisplay_project_members (project, search, sort, syn_list, data_list)

   char		   *project;	    /* I  Project name. */
   char            *search;         /* I  Search string for select clause. */
   char            *sort;           /* I  Sort string for order by clause. */
   MEMptr          *syn_list;       /* O  Synonym list. */
   MEMptr          *data_list;      /* O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdisplay_project_members";

    _NFMRdebug(( fname, "project : <%s>\n", project));
    _NFMRdebug(( fname, "search  : <%s>\n", search ));
    _NFMRdebug(( fname, "sort    : <%s>\n", sort ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", NFM_PROJECTNAME );    
    status = MEMwrite_format (info, "project", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(search)+1));
    status = MEMwrite_format (info, "search", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(sort)+1));
    status = MEMwrite_format (info, "sort", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( NFM_PROJECTNAME + strlen(search) + strlen(sort) 
			 + INTEGER);

    sprintf(str, "%d", DSP_DISPLAY_PROJECT_MEMBERS );
    strcat (str, "\1" );
    strcat (str, project);
    strcat (str, "\1");
    strcat (str, search);
    strcat (str, "\1");
    strcat (str, sort);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers(&NFMRglobal.NETid, &ret_status,syn_list,data_list);
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
 

long NFMRdisplay_project_members_partial (project, search, sort, rows, 
					  syn_list, data_list)

   char		   *project;	    /* I  Project name. */
   char            *search;         /* I  Search string for select clause. */
   char            *sort;           /* I  Sort string for order by clause. */
   long		   rows;	    /* I  Rows to return */
   MEMptr          *syn_list;       /* O  Synonym list. */
   MEMptr          *data_list;      /* O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdisplay_project_members";

    _NFMRdebug(( fname, "project : <%s>\n", project));
    _NFMRdebug(( fname, "search  : <%s>\n", search ));
    _NFMRdebug(( fname, "sort    : <%s>\n", sort ));
    _NFMRdebug(( fname, "rows    : <%ld>\n", rows ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", NFM_PROJECTNAME );    
    status = MEMwrite_format (info, "project", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(search)+1));
    status = MEMwrite_format (info, "search", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(sort)+1));
    status = MEMwrite_format (info, "sort", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMwrite_format (info, "rows", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( NFM_PROJECTNAME + strlen(search) + strlen(sort) 
			 + INTEGER*2);

    sprintf(str, "%d", DSP_DISPLAY_PROJECT_MEMBERS_PARTIAL );
    strcat (str, "\1" );
    strcat (str, project);
    strcat (str, "\1");
    strcat (str, search);
    strcat (str, "\1");
    strcat (str, sort);
    strcat (str, "\1");
    sprintf(fmt, "%ld\1", rows );
    strcat (str, fmt );
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers(&NFMRglobal.NETid, &ret_status,syn_list,data_list);
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
 
long NFMRdisplay_catalog_acl_mapping (catalog, search, sort,
				      syn_list, data_list)

   char		   *catalog;	    /* I  Catalog name. */
   char            *search;         /* I  Search string for select clause. */
   char            *sort;           /* I  Sort string for order by clause. */
   MEMptr          *syn_list;       /* O  Synonym list. */
   MEMptr          *data_list;      /* O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdisplay_catalog_acl_mapping";

    _NFMRdebug(( fname, "catalog : <%s>\n", catalog));
    _NFMRdebug(( fname, "search  : <%s>\n", search ));
    _NFMRdebug(( fname, "sort    : <%s>\n", sort ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", NFM_CATALOGNAME );    
    status = MEMwrite_format (info, "catalog", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(search)+1));
    status = MEMwrite_format (info, "search", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(sort)+1));
    status = MEMwrite_format (info, "sort", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( NFM_CATALOGNAME + strlen(search) + strlen(sort) 
			 + INTEGER );

    sprintf(fmt, "%d", DSP_DISPLAY_CATALOG_ACL_MAPPING );
    strcpy (str, fmt );
    strcat (str, "\1" );
    strcat (str, catalog);
    strcat (str, "\1");
    strcat (str, search);
    strcat (str, "\1");
    strcat (str, sort);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers(&NFMRglobal.NETid, &ret_status, syn_list, data_list);
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

 
long NFMRdisplay_catalog_sa_mapping (catalog, search, sort,
				      syn_list, data_list)

   char		   *catalog;	    /* I  Catalog name. */
   char            *search;         /* I  Search string for select clause. */
   char            *sort;           /* I  Sort string for order by clause. */
   MEMptr          *syn_list;       /* O  Synonym list. */
   MEMptr          *data_list;      /* O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdisplay_catalog_sa_mapping";

    _NFMRdebug(( fname, "catalog : <%s>\n", catalog));
    _NFMRdebug(( fname, "search  : <%s>\n", search ));
    _NFMRdebug(( fname, "sort    : <%s>\n", sort ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", NFM_CATALOGNAME );    
    status = MEMwrite_format (info, "catalog", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(search)+1));
    status = MEMwrite_format (info, "search", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(sort)+1));
    status = MEMwrite_format (info, "sort", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( NFM_CATALOGNAME + strlen(search) + strlen(sort) 
			 + INTEGER);

    sprintf(str, "%d", DSP_DISPLAY_CATALOG_SA_MAPPING );
    strcat (str, "\1" );
    strcat (str, catalog);
    strcat (str, "\1");
    strcat (str, search);
    strcat (str, "\1");
    strcat (str, sort);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers(&NFMRglobal.NETid, &ret_status, syn_list, data_list);
    _NFMRdebug(( fname, "NFMRreceive_two_buffer : <0x%.8x>\n", status));
    if( status != NFM_S_SUCCESS )
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

long NFMRdisplay_project_acl_mapping (project, search, sort,
				      syn_list, data_list)

   char		   *project;	    /* I  Project name. */
   char            *search;         /* I  Search string for select clause. */
   char            *sort;           /* I  Sort string for order by clause. */
   MEMptr          *syn_list;       /* O  Synonym list. */
   MEMptr          *data_list;      /* O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdisplay_project_acl_mapping";

    _NFMRdebug(( fname, "project : <%s>\n", project));
    _NFMRdebug(( fname, "search  : <%s>\n", search ));
    _NFMRdebug(( fname, "sort    : <%s>\n", sort ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", NFM_PROJECTNAME );    
    status = MEMwrite_format (info, "project", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(search)+1));
    status = MEMwrite_format (info, "search", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(sort)+1));
    status = MEMwrite_format (info, "sort", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( NFM_PROJECTNAME + strlen(search) + strlen(sort) 
			 + INTEGER);

    sprintf(str, "%d", DSP_DISPLAY_PROJECT_ACL_MAPPING );
    strcat (str, "\1" );
    strcat (str, project);
    strcat (str, "\1");
    strcat (str, search);
    strcat (str, "\1");
    strcat (str, sort);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers(&NFMRglobal.NETid, &ret_status,syn_list,data_list);
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
 
long NFMRdisplay_project_sa_mapping (project, search, sort,
				      syn_list, data_list)

   char		   *project;	    /* I  Project name. */
   char            *search;         /* I  Search string for select clause. */
   char            *sort;           /* I  Sort string for order by clause. */
   MEMptr          *syn_list;       /* O  Synonym list. */
   MEMptr          *data_list;      /* O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdisplay_project_sa_mapping";

    _NFMRdebug(( fname, "project : <%s>\n", project));
    _NFMRdebug(( fname, "search  : <%s>\n", search ));
    _NFMRdebug(( fname, "sort    : <%s>\n", sort ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", NFM_PROJECTNAME );    
    status = MEMwrite_format (info, "project", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(search)+1));
    status = MEMwrite_format (info, "search", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(sort)+1));
    status = MEMwrite_format (info, "sort", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( NFM_PROJECTNAME + strlen(search) + strlen(sort) 
			 + INTEGER );

    sprintf(str, "%d", DSP_DISPLAY_PROJECT_SA_MAPPING );
    strcat (str, "\1" );
    strcat (str, project);
    strcat (str, "\1");
    strcat (str, search);
    strcat (str, "\1");
    strcat (str, sort);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers(&NFMRglobal.NETid, &ret_status,syn_list,data_list);
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
 
long NFMRdisplay_sets (catalog, search, sort, syn_list, data_list)

   char		   *catalog;	    /* I  Catalog name. */
   char            *search;         /* I  Search string for select clause. */
   char            *sort;           /* I  Sort string for order by clause. */
   MEMptr          *syn_list;       /* O  Synonym list. */
   MEMptr          *data_list;      /* O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdisplay_sets";

    _NFMRdebug(( fname, "catalog : <%s>\n", catalog));
    _NFMRdebug(( fname, "search  : <%s>\n", search ));
    _NFMRdebug(( fname, "sort    : <%s>\n", sort ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", NFM_CATALOGNAME );    
    status = MEMwrite_format (info, "catalog", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(search)+1));
    status = MEMwrite_format (info, "search", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(sort)+1));
    status = MEMwrite_format (info, "sort", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( NFM_CATALOGNAME + strlen(search) + strlen(sort)
			 + INTEGER );

    sprintf(str, "%d", DSP_DISPLAY_SETS );
    strcat (str, "\1" );
    strcat (str, catalog);
    strcat (str, "\1");
    strcat (str, search);
    strcat (str, "\1");
    strcat (str, sort);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers(&NFMRglobal.NETid, &ret_status,syn_list,data_list);
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

  
long NFMRdisplay_signoff_users (acl_name, search, sort, syn_list, data_list)

   char 	   *acl_name;	     /*  I  Acess control list name. */
   char            *search;          /*  I  Search string. */
   char            *sort;            /*  I  Sort string. */
   MEMptr          *syn_list;        /*  O  Synonym list. */
   MEMptr          *data_list;       /*  O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdisplay_signoff_users";

    _NFMRdebug(( fname, "acl_name : <%s>\n", acl_name ));
    _NFMRdebug(( fname, "search  : <%s>\n", search ));
    _NFMRdebug(( fname, "sort    : <%s>\n", sort ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_ACLNAME );    
    status = MEMwrite_format (info, "acl_name", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(search)+1));
    status = MEMwrite_format (info, "search", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(sort)+1));
    status = MEMwrite_format (info, "sort", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    str = (char*)malloc( NFM_ACLNAME + INTEGER + 
	  strlen(search) + strlen(sort) );

    sprintf(str, "%d", DSP_DISPLAY_SIGNOFF_USERS );
    strcat (str, "\1" );
    strcat (str, acl_name);
    strcat (str, "\1" );
    strcat (str, search);
    strcat (str, "\1");
    strcat (str, sort);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers(&NFMRglobal.NETid, &ret_status,syn_list,data_list);
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
 
long NFMRdisplay_so_history (catalog, item, rev,
			     syn_list, data_list)

   char		   *catalog;	    /* I  Catalog name. */
   char		   *item;	    /* I  Item name. */
   char		   *rev;	    /* I  Revision. */
   MEMptr          *syn_list;       /* O  Synonym list. */
   MEMptr          *data_list;      /* O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdisplay_signoff_history";

    _NFMRdebug(( fname, "catalog : <%s>\n", catalog));
    _NFMRdebug(( fname, "item    : <%s>\n", item));
    _NFMRdebug(( fname, "rev     : <%s>\n", rev));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_CATALOGNAME );    
    status = MEMwrite_format (info, "catalog", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", NFM_ITEMNAME );    
    status = MEMwrite_format (info, "item", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", NFM_ITEMREV );    
    status = MEMwrite_format (info, "revision", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( NFM_CATALOGNAME + NFM_ITEMNAME + NFM_ITEMREV
		    	 + INTEGER );

    sprintf(str, "%d", DSP_DISPLAY_SO_HISTORY );
    strcat (str, "\1" );
    strcat (str, catalog);
    strcat (str, "\1");
    strcat (str, item );
    strcat (str, "\1" );
    strcat (str, rev );
    strcat (str, "\1" );
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers(&NFMRglobal.NETid, &ret_status,syn_list,data_list);
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
 
long NFMRdisplay_so_on_item (catalog, item, rev,
			     syn_list, data_list)

   char		   *catalog;	    /* I  Catalog name. */
   char		   *item;	    /* I  Item name. */
   char		   *rev;	    /* I  Revision. */
   MEMptr          *syn_list;       /* O  Synonym list. */
   MEMptr          *data_list;      /* O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdisplay_signoff_on_item";

    _NFMRdebug(( fname, "catalog : <%s>\n", catalog));
    _NFMRdebug(( fname, "item    : <%s>\n", item));
    _NFMRdebug(( fname, "rev     : <%s>\n", rev));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_CATALOGNAME );    
    status = MEMwrite_format (info, "catalog", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", NFM_ITEMNAME );    
    status = MEMwrite_format (info, "item", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", NFM_ITEMREV );    
    status = MEMwrite_format (info, "revision", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( NFM_CATALOGNAME + NFM_ITEMNAME + NFM_ITEMREV 
			 + INTEGER );

    sprintf(str, "%d", DSP_DISPLAY_SO_ON_ITEM );
    strcat (str, "\1" );
    strcat (str, catalog);
    strcat (str, "\1");
    strcat (str, item );
    strcat (str, "\1" );
    strcat (str, rev );
    strcat (str, "\1" );
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers(&NFMRglobal.NETid, &ret_status,syn_list,data_list);
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


long NFMRdisplay_set_members (catalog, item, rev, search, sort, 
			     syn_list, data_list)

   char		   *catalog;	    /* I  Catalog name. */
   char		   *item;	    /* I  Item name. */
   char		   *rev;	    /* I  Revision. */
   char            *search;         /* I  Search string for select clause. */
   char            *sort;           /* I  Sort string for order by clause. */
   MEMptr          *syn_list;       /* O  Synonym list. */
   MEMptr          *data_list;      /* O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdisplay_set_members";

    _NFMRdebug(( fname, "catalog : <%s>\n", catalog));
    _NFMRdebug(( fname, "item    : <%s>\n", item));
    _NFMRdebug(( fname, "rev     : <%s>\n", rev));
    _NFMRdebug(( fname, "search  : <%s>\n", search ));
    _NFMRdebug(( fname, "sort    : <%s>\n", sort ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_CATALOGNAME );    
    status = MEMwrite_format (info, "catalog", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", NFM_ITEMNAME );    
    status = MEMwrite_format (info, "item", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", NFM_ITEMREV );    
    status = MEMwrite_format (info, "revision", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(search)+1) );
    status = MEMwrite_format (info, "search", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(sort)+1) );
    status = MEMwrite_format (info, "sort", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( NFM_CATALOGNAME + NFM_ITEMNAME + NFM_ITEMREV +
	  INTEGER + strlen(search) + strlen(sort) );
 
    sprintf(str, "%d", DSP_DISPLAY_SET_MEMBERS );
    strcat (str, "\1" );
    strcat (str, catalog);
    strcat (str, "\1");
    strcat (str, item );
    strcat (str, "\1" );
    strcat (str, rev );
    strcat (str, "\1" );
    strcat (str, search);
    strcat (str, "\1");
    strcat (str, sort);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers (&NFMRglobal.NETid, &ret_status,syn_list,data_list);
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

long NFMRdisplay_set_members_partial (catalog, item, rev, search, sort, rows,
			     syn_list, data_list)

   char		   *catalog;	    /* I  Catalog name. */
   char		   *item;	    /* I  Item name. */
   char		   *rev;	    /* I  Revision. */
   char            *search;         /* I  Search string for select clause. */
   char            *sort;           /* I  Sort string for order by clause. */
   long		   rows;	    /* I  Number of rows to return */  
   MEMptr          *syn_list;       /* O  Synonym list. */
   MEMptr          *data_list;      /* O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdisplay_set_members_partial";

    _NFMRdebug(( fname, "catalog : <%s>\n", catalog));
    _NFMRdebug(( fname, "item    : <%s>\n", item));
    _NFMRdebug(( fname, "rev     : <%s>\n", rev));
    _NFMRdebug(( fname, "search  : <%s>\n", search ));
    _NFMRdebug(( fname, "sort    : <%s>\n", sort ));
    _NFMRdebug(( fname, "rows    : <%ld>\n", rows ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_CATALOGNAME );    
    status = MEMwrite_format (info, "catalog", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", NFM_ITEMNAME );    
    status = MEMwrite_format (info, "item", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", NFM_ITEMREV );    
    status = MEMwrite_format (info, "revision", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(search)+1) );
    status = MEMwrite_format (info, "search", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(sort)+1) );
    status = MEMwrite_format (info, "sort", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMwrite_format (info, "rows", "integer" );
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( NFM_CATALOGNAME + NFM_ITEMNAME + NFM_ITEMREV +
	  INTEGER*2 + strlen(search) + strlen(sort) );
 
    sprintf(str, "%d", DSP_DISPLAY_SET_MEMBERS_PARTIAL );
    strcat (str, "\1" );
    strcat (str, catalog);
    strcat (str, "\1");
    strcat (str, item );
    strcat (str, "\1" );
    strcat (str, rev );
    strcat (str, "\1" );
    strcat (str, search);
    strcat (str, "\1");
    strcat (str, sort);
    strcat (str, "\1");
    sprintf(fmt, "%ld\1", rows );
    strcat (str, fmt );
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers (&NFMRglobal.NETid, &ret_status,syn_list,data_list);
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

long NFMRdisplay_where_used_set (catalog, item, rev, syn_list, data_list)

   char		   *catalog;	    /* I  Catalog name. */
   char		   *item;	    /* I  Item name. */
   char		   *rev;	    /* I  Revision. */
   MEMptr          *syn_list;       /* O  Synonym list. */
   MEMptr          *data_list;      /* O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdisplay_where_used_set";

    _NFMRdebug(( fname, "catalog : <%s>\n", catalog));
    _NFMRdebug(( fname, "item    : <%s>\n", item));
    _NFMRdebug(( fname, "rev     : <%s>\n", rev));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_CATALOGNAME );    
    status = MEMwrite_format (info, "catalog", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", NFM_ITEMNAME );    
    status = MEMwrite_format (info, "item", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", NFM_ITEMREV );    
    status = MEMwrite_format (info, "revision", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( NFM_CATALOGNAME + NFM_ITEMNAME + NFM_ITEMREV +
	  INTEGER);
 
    sprintf(str, "%d", DSP_DISPLAY_WHERE_USED_SET );
    strcat (str, "\1" );
    strcat (str, catalog);
    strcat (str, "\1");
    strcat (str, item );
    strcat (str, "\1" );
    strcat (str, rev );
    strcat (str, "\1" );
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers (&NFMRglobal.NETid, &ret_status,syn_list,data_list);
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

long NFMRdisplay_where_used_project (catalog, item, rev, syn_list, data_list)

   char		   *catalog;	    /* I  Catalog name. */
   char		   *item;	    /* I  Item name. */
   char		   *rev;	    /* I  Revision. */
   MEMptr          *syn_list;       /* O  Synonym list. */
   MEMptr          *data_list;      /* O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdisplay_where_used_project";

    _NFMRdebug(( fname, "catalog : <%s>\n", catalog));
    _NFMRdebug(( fname, "item    : <%s>\n", item));
    _NFMRdebug(( fname, "rev     : <%s>\n", rev));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_CATALOGNAME );    
    status = MEMwrite_format (info, "catalog", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", NFM_ITEMNAME );    
    status = MEMwrite_format (info, "item", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", NFM_ITEMREV );    
    status = MEMwrite_format (info, "revision", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( NFM_CATALOGNAME + NFM_ITEMNAME + NFM_ITEMREV +
	  INTEGER);
 
    sprintf(str, "%d", DSP_DISPLAY_WHERE_USED_PROJECT );
    strcat (str, "\1" );
    strcat (str, catalog);
    strcat (str, "\1");
    strcat (str, item );
    strcat (str, "\1" );
    strcat (str, rev );
    strcat (str, "\1" );
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers (&NFMRglobal.NETid, &ret_status,syn_list,data_list);
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

long NFMRdisplay_archive_flags (search, sort, syn_list, data_list)

   char            *search;          /* I  Search string for select clause. */
   char            *sort;            /* I  Sort string for order by clause. */
   MEMptr          *syn_list;        /* O  Synonym list. */
   MEMptr          *data_list;       /* O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdisplay_archive_flags";

    _NFMRdebug(( fname, "search  : <%s>\n", search ));
    _NFMRdebug(( fname, "sort    : <%s>\n", sort ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format(dis_type) : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(search)+1));    
    status = MEMwrite_format (info, "search", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format(search) : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(sort)+1) );
    status = MEMwrite_format (info, "sort", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format(sort) : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( INTEGER + strlen(search) + strlen(sort) );

    sprintf(str, "%d", DSP_DISPLAY_ARCHIVE_FLAGS );
    strcat (str, "\1" );
    strcat (str, search);
    strcat (str, "\1");
    strcat (str, sort);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers(&NFMRglobal.NETid, &ret_status,syn_list,data_list);
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

long NFMRdisplay_backup_flags (search, sort, syn_list, data_list)

   char            *search;          /* I  Search string for select clause. */
   char            *sort;            /* I  Sort string for order by clause. */
   MEMptr          *syn_list;        /* O  Synonym list. */
   MEMptr          *data_list;       /* O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdisplay_backup_flags";

    _NFMRdebug(( fname, "search  : <%s>\n", search ));
    _NFMRdebug(( fname, "sort    : <%s>\n", sort ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format(dis_type) : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(search)+1));    
    status = MEMwrite_format (info, "search", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format(search) : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(sort)+1) );
    status = MEMwrite_format (info, "sort", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format(sort) : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( INTEGER + strlen(search) + strlen(sort) );

    sprintf(str, "%d", DSP_DISPLAY_BACKUP_FLAGS );
    strcat (str, "\1" );
    strcat (str, search);
    strcat (str, "\1");
    strcat (str, sort);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers(&NFMRglobal.NETid, &ret_status,syn_list,data_list);
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

long NFMRdisplay_restore_flags (search, sort, syn_list, data_list)

   char            *search;          /* I  Search string for select clause. */
   char            *sort;            /* I  Sort string for order by clause. */
   MEMptr          *syn_list;        /* O  Synonym list. */
   MEMptr          *data_list;       /* O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdisplay_restore_flags";

    _NFMRdebug(( fname, "search  : <%s>\n", search ));
    _NFMRdebug(( fname, "sort    : <%s>\n", sort ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format(dis_type) : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(search)+1));    
    status = MEMwrite_format (info, "search", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format(search) : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(sort)+1) );
    status = MEMwrite_format (info, "sort", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format(sort) : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( INTEGER + strlen(search) + strlen(sort) );

    sprintf(str, "%d", DSP_DISPLAY_RESTORE_FLAGS );
    strcat (str, "\1" );
    strcat (str, search);
    strcat (str, "\1");
    strcat (str, sort);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers(&NFMRglobal.NETid, &ret_status,syn_list,data_list);
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

long NFMRdisplay_delete_flags (search, sort, syn_list, data_list)

   char            *search;          /* I  Search string for select clause. */
   char            *sort;            /* I  Sort string for order by clause. */
   MEMptr          *syn_list;        /* O  Synonym list. */
   MEMptr          *data_list;       /* O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdisplay_delete_flags";

    _NFMRdebug(( fname, "search  : <%s>\n", search ));
    _NFMRdebug(( fname, "sort    : <%s>\n", sort ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format(dis_type) : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(search)+1));    
    status = MEMwrite_format (info, "search", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format(search) : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(sort)+1) );
    status = MEMwrite_format (info, "sort", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format(sort) : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( INTEGER + strlen(search) + strlen(sort) );

    sprintf(str, "%d", DSP_DISPLAY_DELETE_FLAGS );
    strcat (str, "\1" );
    strcat (str, search);
    strcat (str, "\1");
    strcat (str, sort);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers(&NFMRglobal.NETid, &ret_status,syn_list,data_list);
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

long NFMRdisplay_local_files (storage_area, search, sort, syn_list, data_list)

   char		   *storage_area;    /* I  Storage area. */
   char            *search;          /* I  Search string for select clause. */
   char            *sort;            /* I  Sort string for order by clause. */
   MEMptr          *syn_list;        /* O  Synonym list. */
   MEMptr          *data_list;       /* O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdisplay_local_files";

    _NFMRdebug(( fname, "storage : <%s>\n", storage_area ));
    _NFMRdebug(( fname, "search  : <%s>\n", search ));
    _NFMRdebug(( fname, "sort    : <%s>\n", sort ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format(dis_type) : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_SANAME);    
    status = MEMwrite_format (info, "search", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format(search) : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(search)+1));    
    status = MEMwrite_format (info, "search", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format(search) : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(sort)+1) );
    status = MEMwrite_format (info, "sort", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format(sort) : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( INTEGER + NFM_SANAME + strlen(search) + strlen(sort));

    sprintf(str, "%d", DSP_DISPLAY_LOCAL_FILES );
    strcat (str, "\1" );
    strcat (str, storage_area );
    strcat (str, "\1" );
    strcat (str, search);
    strcat (str, "\1");
    strcat (str, sort);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers(&NFMRglobal.NETid, &ret_status,syn_list,data_list);
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

long NFMRget_acl_list_for_catalog (catalog_name, syn_list, data_list)

   char		   *catalog_name;    /* I  Guess. */
   MEMptr          *syn_list;        /* O  Synonym list. */
   MEMptr          *data_list;       /* O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRget_acl_list_for_catalog";

    _NFMRdebug(( fname, "catalog_name : <%s>\n", catalog_name ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format(dis_type) : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_CATALOGNAME);    
    status = MEMwrite_format (info, "catalog", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format(search) : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( INTEGER + NFM_CATALOGNAME );

    sprintf(str, "%d", NFM_GET_WF_AND_COMPLETED_ACL_LIST );
    strcat (str, "\1" );
    strcat (str, catalog_name );
    strcat (str, "\1" );

    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers(&NFMRglobal.NETid, &ret_status,syn_list,data_list);
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

long NFMRget_state_list_for_acl (acl_no, syn_list, data_list)

   long		   acl_no;          /* I  ACL number */
   MEMptr          *syn_list;        /* O  Synonym list. */
   MEMptr          *data_list;       /* O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRget_state_list_for_acl";

    _NFMRdebug(( fname, "ACL No : <%ld>\n", acl_no ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMwrite_format (info, "acl_no", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( INTEGER*2 );

    sprintf(str, "%d", NFM_GET_STATE_LIST_FOR_WORKFLOW );
    strcat (str, "\1" );
    sprintf(fmt, "%ld", acl_no );
    strcat (str, fmt );
    strcat (str, "\1" );

    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers(&NFMRglobal.NETid, &ret_status,syn_list,data_list);
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

long NFMRdisplay_savesets (search, sort, syn_list, data_list)

   char            *search;         /* I  Search string for select clause. */
   char            *sort;           /* I  Sort string for order by clause. */
   MEMptr          *syn_list;       /* O  Synonym list. */
   MEMptr          *data_list;      /* O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdisplay_savesets";

    _NFMRdebug(( fname, "search  : <%s>\n", search ));
    _NFMRdebug(( fname, "sort    : <%s>\n", sort ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", (strlen(search)+1));
    status = MEMwrite_format (info, "search", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(sort)+1));
    status = MEMwrite_format (info, "sort", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( strlen(search) + strlen(sort) + INTEGER );

    sprintf(str, "%d", DSP_DISPLAY_SAVESETS );
    strcat (str, "\1" );
    strcat (str, search);
    strcat (str, "\1");
    strcat (str, sort);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers(&NFMRglobal.NETid, &ret_status, syn_list, data_list);
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

long NFMRdisplay_items_on_tape (search, sort, syn_list, data_list)

   char            *search;         /* I  Search string for select clause. */
   char            *sort;           /* I  Sort string for order by clause. */
   MEMptr          *syn_list;       /* O  Synonym list. */
   MEMptr          *data_list;      /* O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdisplay_items_on_tape";

    _NFMRdebug(( fname, "search  : <%s>\n", search ));
    _NFMRdebug(( fname, "sort    : <%s>\n", sort ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", (strlen(search)+1));
    status = MEMwrite_format (info, "search", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(sort)+1));
    status = MEMwrite_format (info, "sort", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( strlen(search) + strlen(sort) + INTEGER );

    sprintf(str, "%d", DSP_DISPLAY_ITEMS_ON_TAPE );
    strcat (str, "\1" );
    strcat (str, search);
    strcat (str, "\1");
    strcat (str, sort);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers(&NFMRglobal.NETid, &ret_status, syn_list, data_list);
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

long NFMRdisplay_labels (search, sort, syn_list, data_list)

   char            *search;         /* I  Search string for select clause. */
   char            *sort;           /* I  Sort string for order by clause. */
   MEMptr          *syn_list;       /* O  Synonym list. */
   MEMptr          *data_list;      /* O  Data list. */
 
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdisplay_labels";

    _NFMRdebug(( fname, "search  : <%s>\n", search ));
    _NFMRdebug(( fname, "sort    : <%s>\n", sort ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMwrite_format (info, "display_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", (strlen(search)+1));
    status = MEMwrite_format (info, "search", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(sort)+1));
    status = MEMwrite_format (info, "sort", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( strlen(search) + strlen(sort) + INTEGER );

    sprintf(str, "%d", DSP_DISPLAY_LABELS );
    strcat (str, "\1" );
    strcat (str, search);
    strcat (str, "\1");
    strcat (str, sort);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    free (str);
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_MULTI_BUFFER_MASTER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_two_buffers(&NFMRglobal.NETid, &ret_status, syn_list, data_list);
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
