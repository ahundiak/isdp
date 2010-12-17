#include "machine.h"
#include "NFMRextern.h"
 
#define  BUFFER_SIZE  1000

char	 *strcpy();

NFMRquery_cancel_archive( user_id, catalog, files )
    long   user_id;		/* user name for access */
    char   *catalog;		/* catalog to query */
    MEMptr *files;		/* list of file values */
{
    char   str[40];

    long   status;
    long   ret_status;

    MEMptr info     = NULL;

    static char *fname = "NFMRquery_cancel_archive";


    status = MEMopen( &info, BUFFER_SIZE );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
        return (status);
    }
    
    status = MEMwrite_format( info, "user_id", "char(20)" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
        return (status);
    }
    
    sprintf( str, "%d", NFM_CATALOGNAME );
    status = MEMwrite_format( info, "catalog", str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
        return (status);
    }
    
    sprintf(str, "%ld", user_id);
    strcat (str, "\1");
    strcat (str, catalog );
    strcat (str, "\1" );
    status = MEMwrite( info, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        return (status);
    }

    status = NFMcl_send_buffer( &NFMRglobal.NETid, NFM_QUERY_CANCEL_ARCHIVE , info );
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if( status != NFM_S_SUCCESS )
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_buffer (&NFMRglobal.NETid, &ret_status, files);
    if (status != NFM_S_SUCCESS)
    {
        _NFMRdebug(( fname, "NFMRreceive_buffer:<0x%.8x>\n", status));
        return (status);
    }

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n",  ret_status));
    
    if (ret_status != NFM_S_SUCCESS)
        return (ret_status); 

    return (NFM_S_SUCCESS); 
}

NFMRquery_cancel_backup( user_id, catalog, files )
    long   user_id;		/* user name for access */
    char   *catalog;		/* catalog to query */
    MEMptr *files;		/* list of file values */
{
    char   str[40];

    long   status;
    long   ret_status;

    MEMptr info     = NULL;

    static char *fname = "NFMRquery_cancel_backup";

    status = MEMopen( &info, BUFFER_SIZE );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
        return (status);
    }
    
    status = MEMwrite_format( info, "user_id", "char(20)" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
        return (status);
    }
    
    sprintf( str, "%d", NFM_CATALOGNAME );
    status = MEMwrite_format( info, "catalog", str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
        return (status);
    }
    
    sprintf(str, "%ld", user_id);
    strcat (str, "\1");
    strcat (str, catalog );
    strcat (str, "\1" );
    status = MEMwrite( info, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        return (status);
    }

    status = NFMcl_send_buffer( &NFMRglobal.NETid, NFM_QUERY_CANCEL_BACKUP , info );
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if( status != NFM_S_SUCCESS )
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_buffer (&NFMRglobal.NETid, &ret_status, files);
    if (status != NFM_S_SUCCESS)
    {
        _NFMRdebug(( fname, " NFMRreceive_buffer:<0x%.8x>\n",status));
        return (status);
    }

    if (ret_status != NFM_S_SUCCESS)
        return (ret_status); 

    return (NFM_S_SUCCESS); 
}

NFMRquery_cancel_restore( user_id, catalog, files )
    long   user_id;		/* user name for access */
    char   *catalog;		/* catalog to query */
    MEMptr *files;		/* list of file values */
{
    char   str[40];

    long   status;
    long   ret_status;

    MEMptr info     = NULL;

    static char *fname = "NFMRquery_cancel_restore";

    status = MEMopen( &info, BUFFER_SIZE );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
        return (status);
    }
    
    status = MEMwrite_format( info, "user_id", "char(20)" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
        _NFMR_num ("NFMRquery_cancel_restore : MEMwrite_format : <0x%.8x>", 
		    status );
        return (status);
    }
    
    sprintf( str, "%d", NFM_CATALOGNAME );
    status = MEMwrite_format( info, "catalog", str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        return (status);
    }
    
    sprintf(str, "%ld", user_id);
    strcat (str, "\1");
    strcat (str, catalog );
    strcat (str, "\1" );
    status = MEMwrite( info, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        return (status);
    }

    status = NFMcl_send_buffer( &NFMRglobal.NETid, NFM_QUERY_CANCEL_RESTORE , info );
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if( status != NFM_S_SUCCESS )
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_buffer (&NFMRglobal.NETid, &ret_status, files);
    if (status != NFM_S_SUCCESS)
    {
        _NFMRdebug(( fname, "NFMRreceive_buffer:<0x%.8x>\n",status));
        return (status);
    }

    if (ret_status != NFM_S_SUCCESS)
        return (ret_status); 

    return (NFM_S_SUCCESS); 
}

NFMRquery_cancel_delete( user_id, catalog, files )
    long   user_id;		/* user name for access */
    char   *catalog;		/* catalog to query */
    MEMptr *files;		/* list of file values */
{
    char   str[40];

    long   status;
    long   ret_status;

    MEMptr info     = NULL;

    static char *fname = "NFMRquery_cancel_delete";

    status = MEMopen( &info, BUFFER_SIZE );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
        return (status);
    }
    
    status = MEMwrite_format( info, "user_id", "char(20)" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
        return (status);
    }
    
    sprintf( str, "%d", NFM_CATALOGNAME );
    status = MEMwrite_format( info, "catalog", str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
        return (status);
    }
    
    sprintf(str, "%ld", user_id);
    strcat (str, "\1");
    strcat (str, catalog );
    strcat (str, "\1" );

    status = MEMwrite( info, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        return (status);
    }

    status = NFMcl_send_buffer( &NFMRglobal.NETid, NFM_QUERY_CANCEL_DELETE , info );
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if( status != NFM_S_SUCCESS )
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_buffer (&NFMRglobal.NETid, &ret_status, files);
    if (status != NFM_S_SUCCESS)
    {
        _NFMRdebug(( fname, "NFMRreceive_buffer:<0x%.8x>", status));
        return (status);
    }

    _NFMRdebug(( fname, "Return Status <0x%.8x>\n", ret_status ));

    if (ret_status != NFM_S_SUCCESS)
        return (ret_status); 

    return (NFM_S_SUCCESS); 
}
