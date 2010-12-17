#include "machine.h"
#include "NFMRextern.h"

#define   BUFFER_SIZE  1000

long NFMRdefine_query (query_name, query_desc, query_type, 
	application, user_name, query_info)
 
   char            *query_name;     /*  I  Name assigned to the query. */
   char 	   *query_desc;     /*  I  Query description. */
   long            query_type;      /*  I  Type of query being defined.
                                          Possible values:
                                          NFM_WHERE_CLAUSE;
                                          NFM_ORDER_BY_CLAUSE;
                                          NFM_SIMPLE_QUERY;
                                          NFM_EXPERT_QUERY. */
   char            *application;    /*  I  Application defining the query. */
   char            *user_name  ;    /*  I  User who is creating the query. */
   struct
   NFMquery_info   query_info;      /*  I  Structure containing the
                                          information needed to define the
                                          query. */
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdefine_query";

    _NFMRdebug(( fname, "query_name      : <%s>\n", query_name));
    _NFMRdebug(( fname, "query_desc      : <%s>\n", query_desc ));
    _NFMRdebug(( fname, "query_type      : <%ld>\n", query_type ));
    _NFMRdebug(( fname, "application     : <%s>\n", application));
    _NFMRdebug(( fname, "user_name       : <%s>\n", user_name ));


    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(query_name)+1) );    
    status = MEMwrite_format (info, "query_name", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", (strlen(query_desc)+1) );
    status = MEMwrite_format (info, "query_desc", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    status = MEMwrite_format (info, "query_type", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", NFM_APPLICATION );
    status = MEMwrite_format (info, "application", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", NFM_USERNAME);    
    status = MEMwrite_format (info, "user_name", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", (strlen( query_info.select_clause )+1));
    status = MEMwrite_format (info, "select_clause", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", (strlen( query_info.from_clause )+1));
    status = MEMwrite_format (info, "from_clause", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", (strlen( query_info.where_clause )+1));
    status = MEMwrite_format (info, "where_clause", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", (strlen( query_info.order_by_clause )+1));
    status = MEMwrite_format (info, "order_by_clause", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", (strlen( query_info.prompts )+1));
    status = MEMwrite_format (info, "prompts", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( 100 + strlen(query_info.select_clause)
          + strlen(query_info.from_clause) + strlen(query_info.where_clause) 
	  + strlen(query_info.order_by_clause) + strlen(query_info.prompts));
    
    strcpy (str, query_name);
    strcat (str, "\1");
    strcat (str, query_desc);
    strcat (str, "\1" );
    sprintf(fmt, "%ld", query_type );
    strcat (str, fmt);
    strcat (str, "\1");
    strcat (str, application);
    strcat (str, "\1");
    strcat (str, user_name);
    strcat (str, "\1");
    strcat (str, query_info.select_clause );
    strcat (str, "\1");
    strcat (str, query_info.from_clause );
    strcat (str, "\1");
    strcat (str, query_info.where_clause );
    strcat (str, "\1");
    strcat (str, query_info.order_by_clause );
    strcat (str, "\1");
    strcat (str, query_info.prompts );
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

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_DEFINE_QUERY, info);
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "NFMcl_send_buffer : <0x%.8x>\n", status));
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_error_buffers (&NFMRglobal.NETid, &ret_status );
    _NFMRdebug((fname, "NFMRreceive_error_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return (ret_status); 

    return( NFM_S_SUCCESS );
}
 
long NFMRdelete_query (query_name)

   char            *query_name;     /*  I  Name assigned to the query. */
{
MEMptr info = NULL;
char   str[100];
char   fmt[20];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRdelete_query";

    _NFMRdebug(( fname, "query_name      : <%s>\n", query_name));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_REPORTNAME );
    status = MEMwrite_format (info, "query_name", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    strcpy (str, query_name);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_DELETE_QUERY, info);
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "NFMcl_send_buffer : <0x%.8x>\n", status));
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_error_buffers (&NFMRglobal.NETid, &ret_status);
    _NFMRdebug((fname, "NFMRreceive_error_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));
   
    if( ret_status != NFM_S_SUCCESS )
	return( ret_status );

    return( NFM_S_SUCCESS );
}

long NFMRretrieve_query (query_name, query_info)
 
   char            *query_name;     /*  I  Name assigned to the query. */
   struct
   NFMquery_info   *query_info;     /*  O  Pointer to structure containing 
                                           the information returned to
					   define the query. */
{
MEMptr info = NULL;
char   str[NFM_REPORTNAME+1];
char   fmt[20];
char   **data_ptr;
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRretrieve_query";

    _NFMRdebug(( fname, "query_name      : <%s>\n", query_name));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (strlen(query_name)+1) );    
    status = MEMwrite_format (info, "query_name", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    strcpy (str, query_name);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_RETRIEVE_QUERY, info);
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "NFMcl_send_buffer : <0x%.8x>\n", status));
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, &info);
    _NFMRdebug((fname, "NFMRreceive_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        {
        MEMclose (&info);
        return (ret_status);
        }

    status = MEMbuild_array (info);
    if (status != MEM_S_SUCCESS)
    {
	MEMclose( &info );
        _NFMRdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)info->data_ptr;

    _NFMRdebug(( fname, "Select Clause   <%s>\n", data_ptr[0] ));
    _NFMRdebug(( fname, "From Clause     <%s>\n", data_ptr[1] ));
    _NFMRdebug(( fname, "Where Clause    <%s>\n", data_ptr[2] ));
    _NFMRdebug(( fname, "Order By Clause <%s>\n", data_ptr[3] ));
    _NFMRdebug(( fname, "Prompts         <%s>\n", data_ptr[4] ));  
    
    query_info->select_clause   = (char*)malloc( strlen( data_ptr[0] )+1);
    query_info->from_clause     = (char*)malloc( strlen( data_ptr[1] )+1);
    query_info->where_clause    = (char*)malloc( strlen( data_ptr[2] )+1);
    query_info->order_by_clause = (char*)malloc( strlen( data_ptr[3] )+1);
    query_info->prompts         = (char*)malloc( strlen( data_ptr[4] )+1);

    strcpy( query_info->select_clause,   data_ptr[0] );
    strcpy( query_info->from_clause,     data_ptr[1] );
    strcpy( query_info->where_clause,    data_ptr[2] );
    strcpy( query_info->order_by_clause, data_ptr[3] );
    strcpy( query_info->prompts,         data_ptr[4] );

    MEMclose (&info);

    return( NFM_S_SUCCESS );
}


long NFMRretrieve_query_info (query_name, query_type, application, appl_type,
                              query_desc, owner, query_info)
 
   char     *query_name;             /* I - Query name. */
   char     *query_type;             /* I - Query type: W-search, O-order_by. */
   char     *application;            /* I - Application who defined query. */
   char     *appl_type;              /* I - Appl. type assigned to query. */
   char     *query_desc;             /* O - Query description. */
   char     *owner;                  /* O - Owner of the query. */
   struct NFMquery_info *query_info; /* O - Structure pointer of returned */

{
MEMptr info = NULL;
char   str[NFM_REPORTNAME+NFM_TYPE+NFM_APPLICATION+NFM_APPTYPE+100];
char   fmt[20];
char   **data_ptr;
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRretrieve_query_info";

    _NFMRdebug(( fname, "query_name  : <%s>\n", query_name));
    _NFMRdebug(( fname, "query_type  : <%s>\n", query_type));
    _NFMRdebug(( fname, "application : <%s>\n", application));
    _NFMRdebug(( fname, "appl_type   : <%s>\n", appl_type));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", (NFM_REPORTNAME+1) );    
    status = MEMwrite_format (info, "query_name", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", (NFM_TYPE+1) );    
    status = MEMwrite_format (info, "query_type", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", (NFM_APPLICATION+1) );    
    status = MEMwrite_format (info, "application", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", (NFM_APPTYPE+1) );    
    status = MEMwrite_format (info, "appl_type", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    strcpy (str, query_name);
    strcat (str, "\1");
    strcat (str, query_type);
    strcat (str, "\1");
    strcat (str, application);
    strcat (str, "\1");
    strcat (str, appl_type);
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_RETRIEVE_QUERY_INFO,
                                info);
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "NFMcl_send_buffer : <0x%.8x>\n", status));
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, &info);
    _NFMRdebug((fname, "NFMRreceive_one_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "NFMRreceive_buffer : <0x%.8x>\n", status));
        return (status);
    }

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        {
        MEMclose (&info);
        return (ret_status); 
        }

    status = MEMbuild_array (info);
    if (status != MEM_S_SUCCESS)
    {
	MEMclose( &info );
        _NFMRdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)info->data_ptr;

    _NFMRdebug(( fname, "Description     <%s>\n", data_ptr[0] ));
    _NFMRdebug(( fname, "Owner           <%s>\n", data_ptr[1] ));
    _NFMRdebug(( fname, "Select Clause   <%s>\n", data_ptr[2] ));
    _NFMRdebug(( fname, "From Clause     <%s>\n", data_ptr[3] ));
    _NFMRdebug(( fname, "Where Clause    <%s>\n", data_ptr[4] ));
    _NFMRdebug(( fname, "Order By Clause <%s>\n", data_ptr[5] ));
    _NFMRdebug(( fname, "Prompts         <%s>\n", data_ptr[6] ));  
    
    query_info->select_clause   = (char*)malloc( strlen( data_ptr[2] )+1);
    query_info->from_clause     = (char*)malloc( strlen( data_ptr[3] )+1);
    query_info->where_clause    = (char*)malloc( strlen( data_ptr[4] )+1);
    query_info->order_by_clause = (char*)malloc( strlen( data_ptr[5] )+1);
    query_info->prompts         = (char*)malloc( strlen( data_ptr[6] )+1);

    strcpy( query_desc,                  data_ptr[0] );
    strcpy( owner,                       data_ptr[1] );
    strcpy( query_info->select_clause,   data_ptr[2] );
    strcpy( query_info->from_clause,     data_ptr[3] );
    strcpy( query_info->where_clause,    data_ptr[4] );
    strcpy( query_info->order_by_clause, data_ptr[5] );
    strcpy( query_info->prompts,         data_ptr[6] );

    MEMclose( &info );

    return( NFM_S_SUCCESS );
}

