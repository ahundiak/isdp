#include "machine.h"
#include "NFMRextern.h"
#include "NFMdef.h"

#define    BUFFER_SIZE    1000


/* 
 Doc: NFMRsqlstmt
 
 Abstract:
      This function will access the database using the input SQL
      statement. 
 */

long NFMRsqlstmt( sql_string )
    char   *sql_string;  /* i - sql string */

{
    MEMptr info     = NULL;

    long   status;
    long   ret_status;
    int    len;
    char   str_dtype[10];
    static char *fname = "NFMRsqlstmt";

    _NFMRdebug(( fname, "str : <%s>\n", sql_string));

    len = strlen( sql_string ) + 1;
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

    status = MEMwrite (info, sql_string);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
    }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_SQL_STMT, info);
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        return (status);
    }
    MEMclose (&info);

    status = NFMRreceive_error_buffers (&NFMRglobal.NETid, &ret_status);
    _NFMRdebug(( fname, "NFMRreceive_error_buffers <0x%.8x>\n", status ));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));
    if( ret_status != NFM_S_SUCCESS )
        return (ret_status);

    return( NFM_S_SUCCESS );
}
