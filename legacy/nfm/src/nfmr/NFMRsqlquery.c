#include "machine.h"
#include "NFMRextern.h"
#include "NFMdef.h"

#define    BUFFER_SIZE    1000


/* 
 Doc: NFMRsqlquery
 
 Abstract:
      This function will query the database using the input SQL
      string. The return buffer in the result of the SQL query.     


 */

long NFMRsqlquery( sql_string, buffer_size, sql_buffer )
    char   *sql_string;  /* i - sql string */
    char   *buffer_size; /* i - user chooses query buffer size */
    MEMptr *sql_buffer;  /* o - result of sql string */

{
    MEMptr info     = NULL;

    long   status;
    long   ret_status;
    int    len;

    char   *str;
    char   str_dtype[10];
    static char *fname = "NFMRsqlquery";

    _NFMRdebug(( fname, "str : <%s>\n", sql_string));
    _NFMRdebug(( fname, "size : <%s>\n", buffer_size));

    len = strlen( sql_string ) + 30;
    str = (char*)malloc(len);
    sprintf( str_dtype, "char(%d)", len);

    _NFMRdebug(( fname, "str_dtype : <%s>\n", str_dtype));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    status = MEMwrite_format (info, "sql", str_dtype );
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    status = MEMwrite_format (info, "size", "integer" );
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    strcpy (str, sql_string );
    strcat (str, "\1" );
    strcat (str, buffer_size );
    strcat (str, "\1" );

    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    free( str );

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_SQL_QUERY, info);
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }
    MEMclose (&info);

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, 
			sql_buffer);
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));
    if( ret_status != NFM_S_SUCCESS )
	return( ret_status );

    if (_NFMdebug_st.NFMRdebug_on)
        MEMprint_buffers ("SQL BUFFER", *sql_buffer, _NFMdebug_st.NFMRdebug_file);

    return( NFM_S_SUCCESS );
}

long NFMRsqlquery_cursor( sql_string, buffer_size, rows, cursor, sql_buffer )
    char   *sql_string;  /* i - sql string */
    char   *buffer_size; /* i - user chooses query buffer size */
    long   rows;	 /* i - number of rows to return */
    int    cursor;	 /* i - cursor id ( 11-40 available for 
				applications ) */
    MEMptr *sql_buffer;  /* o - result of sql string */

{
    MEMptr info     = NULL;

    long   status;
    long   ret_status;
    int    len;

    char   *str;
    char   str_dtype[10];
    static char *fname = "NFMRsqlquery_block";

    _NFMRdebug(( fname, "str    : <%s>\n", sql_string));
    _NFMRdebug(( fname, "size   : <%s>\n", buffer_size));
    _NFMRdebug(( fname, "rows   : <%ld>\n", rows));
    _NFMRdebug(( fname, "cursor : <%d>\n", cursor));

    len = strlen( sql_string ) + 30;
    str = (char*)malloc(len);
    sprintf( str_dtype, "char(%d)", len);

    _NFMRdebug(( fname, "str_dtype : <%s>\n", str_dtype));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    status = MEMwrite_format (info, "sql", str_dtype );
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    status = MEMwrite_format (info, "size", "integer" );
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    status = MEMwrite_format (info, "rows", "integer" );
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }

    status = MEMwrite_format (info, "cursor", "integer" );
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    strcpy (str, sql_string );
    strcat (str, "\1" );
    strcat (str, buffer_size );
    strcat (str, "\1" );
    sprintf(str_dtype, "%ld", rows );
    strcat (str, str_dtype );
    strcat (str, "\1" );
    sprintf(str_dtype, "%d", cursor );
    strcat (str, str_dtype );
    strcat (str, "\1" );

    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    free( str );

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_SQL_QUERY_PARTIAL, 
				info);
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }
    MEMclose (&info);

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid,&ret_status,sql_buffer);
    _NFMRdebug(( fname, "NFMRreceive_one_buffer <0x%.8x>\n", status ));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));
    if( ret_status != NFM_S_SUCCESS )
	return( ret_status );

    if (_NFMdebug_st.NFMRdebug_on)
        MEMprint_buffers ("SQL BUFFER", *sql_buffer, _NFMdebug_st.NFMRdebug_file);

    return( NFM_S_SUCCESS );
}
