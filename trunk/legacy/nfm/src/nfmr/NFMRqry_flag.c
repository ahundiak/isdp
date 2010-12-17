#include "machine.h"
#include "NFMRextern.h"
 
#define  BUFFER_SIZE  1000

/*  This function querys the NFM server for all flagged files for the 
 *  given utility.
 */
NFMRquery_flagged_files( user_id, utility, files )
    long   user_id;		/* user name for access */
    int	   utility;		/* ARCHIVE or BACKUP */
    MEMptr *files;		/* list of file values */
{
    char   str[256];
    char   id[20];

    long   status;
    long   ret_status;

    MEMptr info     = NULL;

    static char *fname = "NFMRquery_flagged_files";

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
    
    sprintf (id, "%ld", user_id);

    strcpy (str, id);
    strcat (str, "\1");
    status = MEMwrite( info, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
        return (status);
    }

    status = NFMcl_send_buffer( &NFMRglobal.NETid, utility , info );
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
        _NFMRdebug(( fname, "NFMRreceive_buffer : <0x%.8x>\n", status));
        return (status);
    }
    _NFMRdebug(( fname, "Return Status <0x%.8x>\n", ret_status));

    if (ret_status != NFM_S_SUCCESS)
        return (ret_status); 

    return (NFM_S_SUCCESS); 
}

/*  This function querys the NFM server for all files available 
 *  to be flagged for ARCHIVE. This will be files checked in with
 *  NO pending flags set.
 */
NFMRquery_flag_archive( user_id, catalog, files )
    long   user_id;		/* user id for access */
    char   *catalog;		/* catalog to query */
    MEMptr *files;		/* list of file values */
{
    char   str[256];
    char   id[20];

    long   status;
    long   ret_status;

    MEMptr info     = NULL;

    static char *fname = "NFMRquery_flag_archive";

    status = MEMopen( &info, BUFFER_SIZE );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
	_NFMRdebug(( fname, "MEMopen <0x%.8x>\n", status ));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }
    
    status = MEMwrite_format( info, "user_id", "char(20)" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
	_NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }
    
    sprintf( id, "char(%d)", NFM_CATALOGNAME );
    status = MEMwrite_format( info, "catalog", id );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf (id, "%ld", user_id);
    strcpy (str, id);
    strcat (str, "\1");
    strcat (str, catalog );
    strcat (str, "\1" );
    status = MEMwrite( info, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = NFMcl_send_buffer( &NFMRglobal.NETid, NFM_QUERY_FLAG_ARCHIVE , info );
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if( status != NFM_S_SUCCESS )
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, files);
    _NFMRdebug(( fname, "NFMRreceive_one_buffer:<0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status <0x%.8x>\n", ret_status ));

    if (ret_status != NFM_S_SUCCESS)
        return (ret_status); 

    return (NFM_S_SUCCESS); 
}

/*  This function querys the NFM server for all files available 
 *  to be flagged for BACKUP. This will be files checked in with
 *  NO pending flags set.
 */
NFMRquery_flag_backup( user_id, catalog, files )
    long   user_id;		/* i - user id for access */
    char   *catalog;		/* i - catalog to query */
    MEMptr *files;		/* o - list of file values */
{
    char   str[256];
    char   id[20];

    long   status;
    long   ret_status;

    MEMptr info     = NULL;

    static char *fname = "NFMRquery_flag_backup";

    status = MEMopen( &info, BUFFER_SIZE );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    status = MEMwrite_format( info, "user_id", "char(20)" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( id, "char(%d)", NFM_CATALOGNAME );
    status = MEMwrite_format( info, "catalog", id );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
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
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = NFMcl_send_buffer( &NFMRglobal.NETid, NFM_QUERY_FLAG_BACKUP , info );
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if( status != NFM_S_SUCCESS )
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, files);
    _NFMRdebug(( fname, "NFMRreceive_one_buffer: <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);
 
    _NFMRdebug(( fname, "Return Status <0x%.8x>\n", ret_status ));
    if (ret_status != NFM_S_SUCCESS)
        return (ret_status); 

    return (NFM_S_SUCCESS); 
}

/*  This function querys the NFM server for all files available 
 *  to be flagged for RESTORE. This will be files currently archived
 *  or backed up.
 */
NFMRquery_flag_restore( user_id, catalog, files )
    long   user_id;		/* i - user id for access */
    char   *catalog;		/* i - catalog to query */
    MEMptr *files;		/* o - list of file values */
{
    char   str[256];
    char   id[20];

    long   status;
    long   ret_status;

    MEMptr info     = NULL;

    static char *fname = "NFMRquery_flag_restore";

    status = MEMopen( &info, BUFFER_SIZE );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    status = MEMwrite_format( info, "user_id", "char(20)" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( id, "char(%d)", NFM_CATALOGNAME );
    status = MEMwrite_format( info, "catalog", id );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
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
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = NFMcl_send_buffer( &NFMRglobal.NETid, NFM_QUERY_FLAG_RESTORE , info );
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if( status != NFM_S_SUCCESS )
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, files);
    _NFMRdebug(( fname, "NFMRreceive_one_buffer:<0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status <0x%.8x>\n", ret_status ));
    if (ret_status != NFM_S_SUCCESS)
        return (ret_status); 

    if( _NFMdebug_st.NFMRdebug_on )
	MEMprint_buffers( "FILE LIST", *files,_NFMdebug_st.NFMRdebug_file );

    return (NFM_S_SUCCESS); 
}

NFMRnew_query_flag_restore( catalog, item, revision, files )
    char   *catalog;		/* i - catalog to query */
    char   *item;		/* i - item name */
    char   *revision;		/* i - revision */
    MEMptr *files;		/* o - list of file values */
{
    char   str[256];
    char   id[20];

    long   status;
    long   ret_status;

    MEMptr info     = NULL;

    static char *fname = "NFMRnew_query_flag_restore";

    status = MEMopen( &info, BUFFER_SIZE );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( id, "char(%d)", NFM_CATALOGNAME );
    status = MEMwrite_format( info, "catalog", id );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( id, "char(%d)", NFM_ITEMNAME );
    status = MEMwrite_format( info, "n_itemname", id );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( id, "char(%d)", NFM_ITEMREV );
    status = MEMwrite_format( info, "n_itemrev", id );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf(str, "%s\1", catalog);
    strcat (str, item );
    strcat (str, "\1" );
    strcat (str, revision );
    strcat (str, "\1" );
    status = MEMwrite( info, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = NFMcl_send_buffer( &NFMRglobal.NETid, NFM_QRY_FLAG_RESTORE , info );
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if( status != NFM_S_SUCCESS )
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, files);
    _NFMRdebug(( fname, "NFMRreceive_one_buffer:<0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status <0x%.8x>\n", ret_status ));
    if (ret_status != NFM_S_SUCCESS)
        return (ret_status); 

    if( _NFMdebug_st.NFMRdebug_on )
	MEMprint_buffers( "FILE LIST", *files,_NFMdebug_st.NFMRdebug_file );

    return (NFM_S_SUCCESS); 
}

/*  This function querys the NFM server for all files available 
 *  to be flagged for DELETE. This will be files checked in with
 *  NO pending flags set.
 */
NFMRquery_flag_delete( user_id, catalog, files )
    long   user_id;		/* i - user id for access */
    char   *catalog;		/* i - catalog to query */
    MEMptr *files;		/* o - list of file values */
{
    char   str[256];
    char   id[20];

    long   status;
    long   ret_status;

    MEMptr info     = NULL;

    static char *fname = "NFMRquery_flag_delete";

    status = MEMopen( &info, BUFFER_SIZE );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    status = MEMwrite_format( info, "user_id", "char(20)" );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( id, "char(%d)", NFM_CATALOGNAME );    
    status = MEMwrite_format( info, "catalog", id );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
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
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = NFMcl_send_buffer( &NFMRglobal.NETid, NFM_QUERY_FLAG_DELETE , info );
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if( status != NFM_S_SUCCESS )
    {
        MEMclose (&info);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, files);
    _NFMRdebug(( fname, "NFMRreceive_one_buffer <0x%.8x>\n", status ));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status <0x%.8x>\n", ret_status ));

    if (ret_status != NFM_S_SUCCESS)
        return (ret_status); 

    return (NFM_S_SUCCESS); 
}
