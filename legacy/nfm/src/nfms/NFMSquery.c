#include "machine.h"
#include "MEMstruct.h"
#include "NFMschema.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "NFMapi.h"

long NFMSdefine_query(in_list)

MEMptr in_list;

{
long   status;
long   ret_status;
char   **data_ptr;

struct NFMquery_info query_info;

static char *fname = "NFMSdefine_query";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        return (status);
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Query Name  <%s>\n", data_ptr[0] ));
    _NFMSdebug(( fname, "Query Desc  <%s>\n", data_ptr[1] ));
    _NFMSdebug(( fname, "Query Type  <%s>\n", data_ptr[2] ));
    _NFMSdebug(( fname, "Application <%s>\n", data_ptr[3] ));
    _NFMSdebug(( fname, "User Name   <%s>\n", data_ptr[4] ));
    _NFMSdebug(( fname, "Select Clause   <%s>\n", data_ptr[5] ));
    _NFMSdebug(( fname, "From Clause     <%s>\n", data_ptr[6] ));
    _NFMSdebug(( fname, "Where Clause    <%s>\n", data_ptr[7] ));
    _NFMSdebug(( fname, "Order By Clause <%s>\n", data_ptr[8] ));
    _NFMSdebug(( fname, "Prompts         <%s>\n", data_ptr[9] ));  
    
    query_info.select_clause   = (char*)malloc( strlen( data_ptr[5] )+1);
    query_info.from_clause     = (char*)malloc( strlen( data_ptr[6] )+1);
    query_info.where_clause    = (char*)malloc( strlen( data_ptr[7] )+1);
    query_info.order_by_clause = (char*)malloc( strlen( data_ptr[8] )+1);
    query_info.prompts         = (char*)malloc( strlen( data_ptr[9] )+1);

    strcpy( query_info.select_clause, data_ptr[5] );
    strcpy( query_info.from_clause,   data_ptr[6] );
    strcpy( query_info.where_clause,  data_ptr[7] );
    strcpy( query_info.order_by_clause, data_ptr[8] );
    strcpy( query_info.prompts	      , data_ptr[9] );

    ret_status = NFMdefine_query( data_ptr[0], data_ptr[1], atoi(data_ptr[2]), 
		data_ptr[3], data_ptr[4], query_info );
    _NFMSdebug(( fname, "NFMdefine_query\n", ret_status));

    status = NFMSsend_error_buffers( ret_status, ret_status );
    _NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

    return (ret_status);
}

long NFMSdefine_ftr_query(in_list)

MEMptr in_list;

{
long   status;
long   ret_status;
char   **data_ptr;

struct NFMquery_ftr_info query_info;

static char *fname = "NFMSdefine_ftr_query";


    if( _NFMdebug_st.NFMSdebug_on )
	MEMprint_buffers( "QUERY INFO", in_list,_NFMdebug_st.NFMSdebug_file);
    
    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        return (status);
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Query Name  <%s>\n", data_ptr[0] ));
    _NFMSdebug(( fname, "Query Desc  <%s>\n", data_ptr[1] ));
    _NFMSdebug(( fname, "Query Type  <%s>\n", data_ptr[2] ));
    _NFMSdebug(( fname, "Application <%s>\n", data_ptr[3] ));
    _NFMSdebug(( fname, "User Name   <%s>\n", data_ptr[4] ));
    _NFMSdebug(( fname, "Select Clause   <%s>\n", data_ptr[5] ));
    _NFMSdebug(( fname, "From Clause     <%s>\n", data_ptr[6] ));
    _NFMSdebug(( fname, "Where Clause    <%s>\n", data_ptr[7] ));
    _NFMSdebug(( fname, "Order By Clause <%s>\n", data_ptr[8] ));
    _NFMSdebug(( fname, "Prompts         <%s>\n", data_ptr[9] ));  
    _NFMSdebug(( fname, "FTR             <%s>\n", data_ptr[10] ));  
    _NFMSdebug(( fname, "AQS             <%s>\n", data_ptr[11] ));  
    _NFMSdebug(( fname, "AQF             <%s>\n", data_ptr[12] ));  
    _NFMSdebug(( fname, "AQW             <%s>\n", data_ptr[13] ));  
    
    query_info.select_clause   = (char*)malloc( strlen( data_ptr[5] )+1);
    query_info.from_clause     = (char*)malloc( strlen( data_ptr[6] )+1);
    query_info.where_clause    = (char*)malloc( strlen( data_ptr[7] )+1);
    query_info.order_by_clause = (char*)malloc( strlen( data_ptr[8] )+1);
    query_info.prompts         = (char*)malloc( strlen( data_ptr[9] )+1);
    query_info.ftr             = (char*)malloc( strlen( data_ptr[10])+1);
    query_info.aqs             = (char*)malloc( strlen( data_ptr[11])+1);
    query_info.aqf             = (char*)malloc( strlen( data_ptr[12])+1);
    query_info.aqw             = (char*)malloc( strlen( data_ptr[13])+1);

    strcpy( query_info.select_clause, data_ptr[5] );
    strcpy( query_info.from_clause,   data_ptr[6] );
    strcpy( query_info.where_clause,  data_ptr[7] );
    strcpy( query_info.order_by_clause, data_ptr[8] );
    strcpy( query_info.prompts	      , data_ptr[9] );
    strcpy( query_info.ftr            , data_ptr[10]);
    strcpy( query_info.aqs            , data_ptr[11]);
    strcpy( query_info.aqf            , data_ptr[12]);
    strcpy( query_info.aqw            , data_ptr[13]);

    ret_status = NFMdefine_ftr_query( data_ptr[0], data_ptr[1], 
		atoi(data_ptr[2]), data_ptr[3], data_ptr[4], query_info );
    _NFMSdebug(( fname, "NFMdefine_ftr_query\n", ret_status));

    status = NFMSsend_error_buffers( ret_status, ret_status );
    _NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

    return (ret_status);
}

long NFMSdelete_query(in_list)

MEMptr in_list;
{
long   status;
long   ret_status;
char   **data_ptr;
static char *fname = "NFMSdelete_query";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        return (status);
    }
    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Query Name <%s>\n", data_ptr[0] ));

    ret_status = NFMdelete_query( data_ptr[0] );
    _NFMSdebug(( fname, "NFMdelete_query\n", ret_status));

    status = NFMSsend_error_buffers( ret_status, ret_status );
    _NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));
 
    return (ret_status);
}

long NFMSdelete_ftr_query(in_list)

MEMptr in_list;
{
long   status;
long   ret_status;
char   **data_ptr;
static char *fname = "NFMSdelete_ftr_query";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        return (status);
    }
    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Query Name <%s>\n", data_ptr[0] ));
    _NFMSdebug(( fname, "Query Type <%s>\n", data_ptr[1] ));

    ret_status = NFMdelete_ftr_query( data_ptr[0], data_ptr[1] );
    _NFMSdebug(( fname, "NFMdelete_ftr_query <0x%.8x>\n", ret_status));

    status = NFMSsend_error_buffers( ret_status, ret_status );
    _NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));
 
    return (ret_status);
}

long NFMSretrieve_query(in_list)

MEMptr in_list;

{
long   status;
long   ret_status;
char   *str;
char   **data_ptr;
char   fmt[20];
MEMptr data_list = NULL;

struct NFMquery_info *query_info;

static char *fname = "NFMSretrieve_query";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        return (status);
    }

    data_ptr = (char**)in_list->data_ptr;

    query_info =(struct NFMquery_info *)malloc(sizeof( struct NFMquery_info ));

    _NFMSdebug(( fname, "Query Name  <%s>\n", data_ptr[0] ));

    ret_status = NFMretrieve_query( data_ptr[0], query_info );
    _NFMSdebug(( fname, "NFMretrieve_query\n", ret_status));
    if( ret_status != NFM_S_SUCCESS )
    {        
        status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));
        return (ret_status);
    }
    status = MEMopen (&data_list, MEM_SIZE);
    if (status != MEM_S_SUCCESS)
    {
	MEMclose( &data_list );
        _NFMSdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));
        return (status);
    }
    
    sprintf( fmt, "char(%d)", (strlen( query_info->select_clause )+1));
    status = MEMwrite_format (data_list, "select_clause", fmt);
    if (status != MEM_S_SUCCESS)
    {
	MEMclose( &data_list );
	data_list = NULL;
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));
        return (status);
    }
    
    sprintf( fmt, "char(%d)", (strlen( query_info->from_clause )+1));
    status = MEMwrite_format (data_list, "from_clause", fmt);
    if (status != MEM_S_SUCCESS)
    {
	MEMclose( &data_list );
	data_list = NULL;
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));
        return (status);
    }
    
    sprintf( fmt, "char(%d)", (strlen( query_info->where_clause )+1));
    status = MEMwrite_format (data_list, "where_clause", fmt);
    if (status != MEM_S_SUCCESS)
    {
	MEMclose( &data_list );
	data_list = NULL;
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));
        return (status);
    }
    
    sprintf( fmt, "char(%d)", (strlen( query_info->order_by_clause )+1));
    status = MEMwrite_format (data_list, "order_by_clause", fmt);
    if (status != MEM_S_SUCCESS)
    {
	MEMclose( &data_list );
	data_list = NULL;
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));
        return (status);
    }
    
    sprintf( fmt, "char(%d)", (strlen( query_info->prompts )+1));
    status = MEMwrite_format (data_list, "prompts", fmt);
    if (status != MEM_S_SUCCESS)
    {
	MEMclose( &data_list );
	data_list = NULL;
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));
        return (status);
    }

    str = (char*)malloc( strlen(query_info->select_clause)
          + strlen(query_info->from_clause) + strlen(query_info->where_clause) 
	  + strlen(query_info->order_by_clause) + strlen(query_info->prompts)
	  + 10 );    
    strcpy (str, query_info->select_clause );
    strcat (str, "\1");
    strcat (str, query_info->from_clause );
    strcat (str, "\1");
    strcat (str, query_info->where_clause );
    strcat (str, "\1");
    strcat (str, query_info->order_by_clause );
    strcat (str, "\1");
    strcat (str, query_info->prompts );
    strcat (str, "\1" );
    status = MEMwrite (data_list, str);
    if (status != MEM_S_SUCCESS)
    {
	MEMclose( &data_list );
	data_list = NULL;
        _NFMSdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));
        return (status);
    }
 
    free (str);

    if( _NFMdebug_st.NFMSdebug_on )
	MEMprint_buffers( "QUERY INFO", data_list,_NFMdebug_st.NFMSdebug_file);

    MEMclose(  &data_list );

    return (NFM_S_SUCCESS);
}

long NFMSretrieve_query_info (in_list)

MEMptr in_list;

{
long   status;
long   ret_status;
char   *str;
char   **data_ptr;
char   fmt[20];
char   query_desc[NFM_REPORTDESC+1];
char   owner[NFM_USERNAME+1];
MEMptr data_list = NULL;
struct NFMquery_info *query_info;

static char *fname = "NFMSretrieve_query_info";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        return (status);
    }

    data_ptr = (char**)in_list->data_ptr;

    query_info =(struct NFMquery_info *)malloc(sizeof( struct NFMquery_info ));

    _NFMSdebug(( fname, "Query Name  <%s>\n", data_ptr[0] ));
    _NFMSdebug(( fname, "Query Type  <%s>\n", data_ptr[1] ));
    _NFMSdebug(( fname, "Application <%s>\n", data_ptr[2] ));
    _NFMSdebug(( fname, "Appl Type   <%s>\n", data_ptr[3] ));

    ret_status = NFMretrieve_query_info (data_ptr[0], data_ptr[1], data_ptr[2],
                                   data_ptr[3], query_desc, owner,query_info );
    _NFMSdebug(( fname, "NFMretrieve_query_info\n", ret_status));
    if( ret_status != NFM_S_SUCCESS )
    {
	status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffers <0x%.8x>\n", status ));
        return (ret_status);
    }

    status = MEMopen (&data_list, MEM_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMopen : <0x%.8x>\n", status));
	MEMclose( &data_list );
	data_list = NULL;
	status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffers <0x%.8x>\n", status ));
        return (status);
    }
    
    sprintf( fmt, "char(%d)", (NFM_REPORTDESC+1));
    status = MEMwrite_format (data_list, "query_desc", fmt);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
	MEMclose( &data_list );
	data_list = NULL;
	status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffers <0x%.8x>\n", status ));
        return (status);
    }
    
    sprintf( fmt, "char(%d)", (NFM_USERNAME+1));
    status = MEMwrite_format (data_list, "owner", fmt);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
	MEMclose( &data_list );
	data_list = NULL;
	status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffers <0x%.8x>\n", status ));
        return (status);
    }
    
    sprintf( fmt, "char(%d)", (strlen( query_info->select_clause )+1));
    status = MEMwrite_format (data_list, "select_clause", fmt);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
	MEMclose( &data_list );
	data_list = NULL;
	status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffers <0x%.8x>\n", status ));
        return (status);
    }
    
    sprintf( fmt, "char(%d)", (strlen( query_info->from_clause )+1));
    status = MEMwrite_format (data_list, "from_clause", fmt);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
	MEMclose( &data_list );
	data_list = NULL;
	status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffers <0x%.8x>\n", status ));
        return (status);
    }
    
    sprintf( fmt, "char(%d)", (strlen( query_info->where_clause )+1));
    status = MEMwrite_format (data_list, "where_clause", fmt);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
	MEMclose( &data_list );
	data_list = NULL;
	status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffers <0x%.8x>\n", status ));
        return (status);
    }
    
    sprintf( fmt, "char(%d)", (strlen( query_info->order_by_clause )+1));
    status = MEMwrite_format (data_list, "order_by_clause", fmt);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
	MEMclose( &data_list );
	data_list = NULL;
	status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffers <0x%.8x>\n", status ));
        return (status);
    }
    
    sprintf( fmt, "char(%d)", (strlen( query_info->prompts )+1));
    status = MEMwrite_format (data_list, "prompts", fmt);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
	MEMclose( &data_list );
	data_list = NULL;
	status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffers <0x%.8x>\n", status ));
        return (status);
    }

    str = (char*)malloc( NFM_REPORTDESC + NFM_USERNAME
          + strlen(query_info->select_clause)
          + strlen(query_info->from_clause) + strlen(query_info->where_clause) 
	  + strlen(query_info->order_by_clause) + strlen(query_info->prompts)
	  + 12 );    
    strcpy (str, query_desc);
    strcat (str, "\1");
    strcat (str, owner);
    strcat (str, "\1");
    strcat (str, query_info->select_clause );
    strcat (str, "\1");
    strcat (str, query_info->from_clause );
    strcat (str, "\1");
    strcat (str, query_info->where_clause );
    strcat (str, "\1");
    strcat (str, query_info->order_by_clause );
    strcat (str, "\1");
    strcat (str, query_info->prompts );
    strcat (str, "\1" );
    status = MEMwrite (data_list, str);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
	MEMclose( &data_list );
	data_list = NULL;
	status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffers <0x%.8x>\n", status ));
        return (status);
    }
 
    free (str);

    status = NFMSsend_one_buffer( ret_status, data_list );
    _NFMSdebug(( fname, "NFMSsend_one_buffers <0x%.8x>\n", status ));

    if( _NFMdebug_st.NFMSdebug_on )
	MEMprint_buffers( "QUERY INFO", data_list,_NFMdebug_st.NFMSdebug_file);

    MEMclose( &data_list );

    return (NFM_S_SUCCESS);
}

long NFMSretrieve_ftr_query(in_list)

MEMptr in_list;

{
long   status;
long   ret_status;
char   *str;
char   **data_ptr;
char   fmt[20];
MEMptr data_list = NULL;

struct NFMquery_ftr_info *query_info;

static char *fname = "NFMSretrieve_ftr_query";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        return (status);
    }

    data_ptr = (char**)in_list->data_ptr;

    query_info =(struct NFMquery_ftr_info *)malloc(sizeof( struct NFMquery_ftr_info ));

    _NFMSdebug(( fname, "Query Name  <%s>\n", data_ptr[0] ));

    ret_status = NFMretrieve_ftr_query( data_ptr[0], query_info );
    _NFMSdebug(( fname, "NFMretrieve_ftr_query\n", ret_status));
    if( ret_status != NFM_S_SUCCESS )
    {        
        status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));
        return (ret_status);
    }
    status = MEMopen (&data_list, MEM_SIZE);
    if (status != MEM_S_SUCCESS)
    {
	MEMclose( &data_list );
        _NFMSdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));
        return (status);
    }
    
    sprintf( fmt, "char(%d)", (strlen( query_info->select_clause )+1));
    status = MEMwrite_format (data_list, "select_clause", fmt);
    if (status != MEM_S_SUCCESS)
    {
	MEMclose( &data_list );
	data_list = NULL;
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));
        return (status);
    }
    
    sprintf( fmt, "char(%d)", (strlen( query_info->from_clause )+1));
    status = MEMwrite_format (data_list, "from_clause", fmt);
    if (status != MEM_S_SUCCESS)
    {
	MEMclose( &data_list );
	data_list = NULL;
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));
        return (status);
    }
    
    sprintf( fmt, "char(%d)", (strlen( query_info->where_clause )+1));
    status = MEMwrite_format (data_list, "where_clause", fmt);
    if (status != MEM_S_SUCCESS)
    {
	MEMclose( &data_list );
	data_list = NULL;
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));
        return (status);
    }
    
    sprintf( fmt, "char(%d)", (strlen( query_info->order_by_clause )+1));
    status = MEMwrite_format (data_list, "order_by_clause", fmt);
    if (status != MEM_S_SUCCESS)
    {
	MEMclose( &data_list );
	data_list = NULL;
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));
        return (status);
    }
    
    sprintf( fmt, "char(%d)", (strlen( query_info->prompts )+1));
    status = MEMwrite_format (data_list, "prompts", fmt);
    if (status != MEM_S_SUCCESS)
    {
	MEMclose( &data_list );
	data_list = NULL;
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));
        return (status);
    }

    sprintf( fmt, "char(%d)", (strlen( query_info->ftr )+1));

    status = MEMwrite_format (data_list, "ftr", fmt);
    if (status != MEM_S_SUCCESS)
    {
	MEMclose( &data_list );
	data_list = NULL;
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));
        return (status);
    }

    sprintf( fmt, "char(%d)", (strlen( query_info->aqs )+1));

    status = MEMwrite_format (data_list, "aqs", fmt);
    if (status != MEM_S_SUCCESS)
    {
	MEMclose( &data_list );
	data_list = NULL;
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));
        return (status);
    }


    sprintf( fmt, "char(%d)", (strlen( query_info->aqf )+1));

    status = MEMwrite_format (data_list, "aqf", fmt);
    if (status != MEM_S_SUCCESS)
    {
	MEMclose( &data_list );
	data_list = NULL;
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));
        return (status);
    }


    sprintf( fmt, "char(%d)", (strlen( query_info->aqw )+1));

    status = MEMwrite_format (data_list, "aqw", fmt);
    if (status != MEM_S_SUCCESS)
    {
	MEMclose( &data_list );
	data_list = NULL;
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));
        return (status);
    }

    str = (char*)malloc( strlen(query_info->select_clause)
          + strlen(query_info->from_clause) 
	  + strlen(query_info->where_clause) 
	  + strlen(query_info->order_by_clause) 
	  + strlen(query_info->prompts)
	  + strlen(query_info->ftr)
	  + strlen(query_info->aqs)
	  + strlen(query_info->aqf)
	  + strlen(query_info->aqw)
	  + 15 );    
    strcpy (str, query_info->select_clause );
    strcat (str, "\1");
    strcat (str, query_info->from_clause );
    strcat (str, "\1");
    strcat (str, query_info->where_clause );
    strcat (str, "\1");
    strcat (str, query_info->order_by_clause );
    strcat (str, "\1");
    strcat (str, query_info->prompts );
    strcat (str, "\1" );
    strcat (str, query_info->ftr );
    strcat (str, "\1" );
    strcat (str, query_info->aqs );
    strcat (str, "\1" );
    strcat (str, query_info->aqf );
    strcat (str, "\1" );
    strcat (str, query_info->aqw );
    strcat (str, "\1" );
    status = MEMwrite (data_list, str);
    if (status != MEM_S_SUCCESS)
    {
	MEMclose( &data_list );
	data_list = NULL;
        _NFMSdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));
        return (status);
    }
 
    free (str);

    if( _NFMdebug_st.NFMSdebug_on )
	MEMprint_buffers( "QUERY INFO", data_list,_NFMdebug_st.NFMSdebug_file);

    MEMclose(  &data_list );

    return (NFM_S_SUCCESS);
}

long NFMSretrieve_ftr_query_info (in_list)

MEMptr in_list;

{
long   status;
long   ret_status;
char   *str;
char   **data_ptr;
char   fmt[20];
char   query_desc[NFM_REPORTDESC+1];
char   owner[NFM_USERNAME+1];
MEMptr data_list = NULL;
struct NFMquery_ftr_info *query_info;

static char *fname = "NFMSretrieve_ftr_query_info";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        return (status);
    }

    data_ptr = (char**)in_list->data_ptr;

    query_info =(struct NFMquery_ftr_info *)malloc(sizeof( struct NFMquery_ftr_info ));

    _NFMSdebug(( fname, "Query Name  <%s>\n", data_ptr[0] ));
    _NFMSdebug(( fname, "Query Type  <%s>\n", data_ptr[1] ));
    _NFMSdebug(( fname, "Application <%s>\n", data_ptr[2] ));
    _NFMSdebug(( fname, "Appl Type   <%s>\n", data_ptr[3] ));

    ret_status = NFMretrieve_ftr_query_info (data_ptr[0], data_ptr[1], 
		data_ptr[2],data_ptr[3], query_desc, owner,query_info );
    _NFMSdebug(( fname, "NFMretrieve_ftr_query_info\n", ret_status));
    if( ret_status != NFM_S_SUCCESS )
    {
	status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffers <0x%.8x>\n", status ));
        return (ret_status);
    }

    _NFMdebug ((fname, "From <%s>\n", query_info->from_clause ));
    _NFMdebug ((fname, "Where <%s>\n", query_info->where_clause ));
    _NFMdebug ((fname, "Prompts <%s>\n", query_info->prompts ));
    _NFMdebug ((fname, "FTR <%s>\n", query_info->ftr ));
    _NFMdebug ((fname, "AQS <%s>\n", query_info->aqs ));
    _NFMdebug ((fname, "AQF <%s>\n", query_info->aqf ));
    _NFMdebug ((fname, "AQW <%s>\n", query_info->aqw ));

    status = MEMopen (&data_list, MEM_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMopen : <0x%.8x>\n", status));
	MEMclose( &data_list );
	data_list = NULL;
	status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffers <0x%.8x>\n", status ));
        return (status);
    }
    
    sprintf( fmt, "char(%d)", (NFM_REPORTDESC+1));
    status = MEMwrite_format (data_list, "query_desc", fmt);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
	MEMclose( &data_list );
	data_list = NULL;
	status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffers <0x%.8x>\n", status ));
        return (status);
    }
    
    sprintf( fmt, "char(%d)", (NFM_USERNAME+1));
    status = MEMwrite_format (data_list, "owner", fmt);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
	MEMclose( &data_list );
	data_list = NULL;
	status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffers <0x%.8x>\n", status ));
        return (status);
    }
    
    sprintf( fmt, "char(%d)", (strlen( query_info->select_clause )+2));
    status = MEMwrite_format (data_list, "select_clause", fmt);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
	MEMclose( &data_list );
	data_list = NULL;
	status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffers <0x%.8x>\n", status ));
        return (status);
    }
    
    sprintf( fmt, "char(%d)", (strlen( query_info->from_clause )+2));
    status = MEMwrite_format (data_list, "from_clause", fmt);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
	MEMclose( &data_list );
	data_list = NULL;
	status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffers <0x%.8x>\n", status ));
        return (status);
    }
    
    sprintf( fmt, "char(%d)", (strlen( query_info->where_clause )+2));
    status = MEMwrite_format (data_list, "where_clause", fmt);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
	MEMclose( &data_list );
	data_list = NULL;
	status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffers <0x%.8x>\n", status ));
        return (status);
    }
    
    sprintf( fmt, "char(%d)", (strlen( query_info->order_by_clause )+2));
    status = MEMwrite_format (data_list, "order_by_clause", fmt);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
	MEMclose( &data_list );
	data_list = NULL;
	status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffers <0x%.8x>\n", status ));
        return (status);
    }
    
    sprintf( fmt, "char(%d)", (strlen( query_info->prompts )+2));
    status = MEMwrite_format (data_list, "prompts", fmt);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
	MEMclose( &data_list );
	data_list = NULL;
	status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffers <0x%.8x>\n", status ));
        return (status);
    }
    sprintf( fmt, "char(%d)", (strlen( query_info->ftr )+2));
    status = MEMwrite_format (data_list, "ftr", fmt);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
	MEMclose( &data_list );
	data_list = NULL;
	status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffers <0x%.8x>\n", status ));
        return (status);
    }
    sprintf( fmt, "char(%d)", (strlen( query_info->aqs )+2));
    status = MEMwrite_format (data_list, "aqs", fmt);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
	MEMclose( &data_list );
	data_list = NULL;
	status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffers <0x%.8x>\n", status ));
        return (status);
    }

    sprintf( fmt, "char(%d)", (strlen( query_info->aqf )+2));
    status = MEMwrite_format (data_list, "aqf", fmt);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
	MEMclose( &data_list );
	data_list = NULL;
	status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffers <0x%.8x>\n", status ));
        return (status);
    }
    
    sprintf( fmt, "char(%d)", (strlen( query_info->aqw )+2));
    status = MEMwrite_format (data_list, "aqw", fmt);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
	MEMclose( &data_list );
	data_list = NULL;
	status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffers <0x%.8x>\n", status ));
        return (status);
    }

    str = (char*)malloc( NFM_REPORTDESC + NFM_USERNAME
          + strlen(query_info->select_clause)
          + strlen(query_info->from_clause) 
	  + strlen(query_info->where_clause) 
	  + strlen(query_info->order_by_clause) 
	  + strlen(query_info->prompts)
	  + strlen(query_info->ftr)
	  + strlen(query_info->aqs)
	  + strlen(query_info->aqf)
	  + strlen(query_info->aqw)
	  + 30 );    
    strcpy (str, query_desc);
    strcat (str, "\1");
    strcat (str, owner);
    strcat (str, "\1");
    strcat (str, query_info->select_clause );
    strcat (str, "\1");
    strcat (str, query_info->from_clause );
    strcat (str, "\1");
    strcat (str, query_info->where_clause );
    strcat (str, "\1");
    strcat (str, query_info->order_by_clause );
    strcat (str, "\1");
    strcat (str, query_info->prompts );
    strcat (str, "\1" );
    strcat (str, query_info->ftr );
    strcat (str, "\1" );
    strcat (str, query_info->aqs );
    strcat (str, "\1" );
    strcat (str, query_info->aqf );
    strcat (str, "\1" );
    strcat (str, query_info->aqw );
    strcat (str, "\1" );

    _NFMdebug ((fname, "str <%s>\n", str ));
    status = MEMwrite (data_list, str);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
	MEMclose( &data_list );
	data_list = NULL;
	status = NFMSsend_one_buffer( ret_status, data_list );
        _NFMSdebug(( fname, "NFMSsend_one_buffers <0x%.8x>\n", status ));
        return (status);
    }
 
    free (str);

    status = NFMSsend_one_buffer( ret_status, data_list );
    _NFMSdebug(( fname, "NFMSsend_one_buffers <0x%.8x>\n", status ));

    if( _NFMdebug_st.NFMSdebug_on )
	MEMprint_buffers( "QUERY INFO", data_list,_NFMdebug_st.NFMSdebug_file);

    MEMclose( &data_list );

    return (NFM_S_SUCCESS);
}

