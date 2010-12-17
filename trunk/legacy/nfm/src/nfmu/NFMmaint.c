#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMdb.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"
#include "NFMschema.h"

long NFMquery_savesets_to_delete ( syn_list, data_list )
    MEMptr *syn_list;
    MEMptr *data_list;
{
    long   status;
    int    i;
    char   fmt[NFM_SYNONYM+3];
    char   catalog_name[NFM_CATALOGNAME+1];
    char   item_name[NFM_ITEMNAME+1];
    char   item_rev[NFM_ITEMREV+1];
    char   select_str[1024];
    char   **data_ptr;
    char   **data_ptr1;
    MEMptr buffer  = NULL;
    MEMptr buffer1 = NULL;

    static char *fname = "NFMquery_savesets_to_delete";

    _NFMdebug(( fname, "%s\n", "Entering ..."));

/*  Open and format return buffer
 */

    status = MEMopen( syn_list, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	ERRload_struct( NFM, NFM_E_MEM, "", NULL );
	_NFMdebug(( fname, "MEMopen <0x%.8x>\n", status ));
 	return( NFM_E_MEM );
    }
  
    sprintf( fmt, "char(%d)", NFM_SYNONYM );
    status = MEMwrite_format( *syn_list, "name", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    strcpy( select_str, "Catalog Name\1" );
    status = MEMwrite( *syn_list, select_str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    strcpy( select_str, "Item Name\1" );
    status = MEMwrite( *syn_list, select_str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    strcpy( select_str, "Revision\1" );
    status = MEMwrite( *syn_list, select_str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    strcpy( select_str, "Local Filename\1" );
    status = MEMwrite( *syn_list, select_str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    strcpy( select_str, "File Version\1" );
    status = MEMwrite( *syn_list, select_str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    strcpy( select_str, "Restore Date\1" );
    status = MEMwrite( *syn_list, select_str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    status = MEMopen( data_list, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( syn_list );
	ERRload_struct( NFM, NFM_E_MEM, "", NULL );
	_NFMdebug(( fname, "MEMopen <0x%.8x>\n", status ));
 	return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_CATALOGNAME );
    status = MEMwrite_format( *data_list, "n_catalogname", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( syn_list );
	MEMclose( data_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format(catalogname) <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_ITEMNAME );
    status = MEMwrite_format( *data_list, "n_itemname", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( syn_list );
	MEMclose( data_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format(itemname) <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_ITEMREV );
    status = MEMwrite_format( *data_list, "n_itemrev", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( syn_list );
	MEMclose( data_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format(itemrev) <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_COFILENAME );
    status = MEMwrite_format( *data_list, "n_cofilename", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( syn_list );
	MEMclose( data_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format(cofilename) <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_FILEVERSION );
    status = MEMwrite_format( *data_list, "n_fileversion", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( syn_list );
	MEMclose( data_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format(fileversion) <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_DATE );
    status = MEMwrite_format( *data_list, "n_restoredate", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( syn_list );
	MEMclose( data_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format(restoredate) <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
   
    status = MEMwrite_format( *data_list, "n_catalogno", "integer" );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( syn_list );
	MEMclose( data_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format(catalogno) <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    status = MEMwrite_format( *data_list, "n_itemno", "integer" );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( syn_list );
	MEMclose( data_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format(itemno) <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    status = MEMwrite_format( *data_list, "n_fileno", "integer" );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( syn_list );
	MEMclose( data_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format(fileno) <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    strcpy( select_str, "SELECT nfmsavesets.n_catalogno,nfmsavesets.n_itemno,nfmsavesets.n_fileno,nfmsavesets.n_itemstate,nfmsavesets.n_restoredate FROM nfmsavesets WHERE nfmsavesets.n_itemstate IN ('I','B')" );
    status = SQLquery( select_str, &buffer, MEM_SIZE );
    if( status == SQL_I_NO_ROWS_FOUND )
    {
        MEMclose( syn_list );
	MEMclose( data_list );
        MEMclose( &buffer );
        ERRload_struct (NFM, NFM_E_DELETE_SAVESET, "", NULL);
        return ( NFM_E_DELETE_SAVESET );
    }
    else if( status != SQL_S_SUCCESS )
    {
	MEMclose( syn_list );
	MEMclose( data_list );
	MEMclose( &buffer );
        ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_SQL_QUERY );
    }

/*  Loop thru getting catalog, item names before building the buffer */
    status = MEMbuild_array( buffer );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( syn_list );
	MEMclose( data_list );
	MEMclose( &buffer );
	_NFMdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }
    data_ptr = (char**)buffer->data_ptr;

    for( i=0; i<(buffer->rows*buffer->columns); i+=buffer->columns )
    {
	status = NFMfl_get_catalog_name( data_ptr[i], catalog_name );
	if( status != NFM_S_SUCCESS )
	{
	    MEMclose( &buffer );
	    MEMclose( syn_list );
  	    MEMclose( data_list );
	    return( status );
	}

        sprintf( select_str, "SELECT n_itemname, n_itemrev FROM %s WHERE n_itemno = %s", catalog_name, data_ptr[i+1] );
        status = SQLquery( select_str, &buffer1, MEM_SIZE );
        if( status == SQL_I_NO_ROWS_FOUND )
	{
	    _NFMdebug(( fname, "Saveset mismatch on item_no <%s> in catalog <%s>\n", data_ptr[i+1], catalog_name ));
	    _NFMdebug(( fname, "%s\n", "Entry no longer exists in catalog" ));
	    MEMclose( &buffer1 );
	    buffer1 = NULL;
	    continue;
        }
        else if( status != SQL_S_SUCCESS )
        {
   	    MEMclose( syn_list );
	    MEMclose( data_list );
	    MEMclose( &buffer );
	    MEMclose( &buffer1 );
            ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
            _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
            return ( NFM_E_SQL_QUERY );
        }

        status = MEMbuild_array( buffer1 );
        if( status != MEM_S_SUCCESS )
        {
	    MEMclose( syn_list );
   	    MEMclose( data_list );
	    MEMclose( &buffer );
	    MEMclose( &buffer1 );
   	    _NFMdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
  	    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	    return( NFM_E_MEM );
        }
        data_ptr1 = (char**)buffer1->data_ptr;
	strcpy( item_name, data_ptr1[0] );
	strcpy( item_rev,  data_ptr1[1] );
	MEMclose( &buffer1 );

        sprintf( select_str, "SELECT n_cofilename, n_fileversion FROM f_%s WHERE n_fileno = %s AND n_itemnum = %s", catalog_name, data_ptr[i+2], data_ptr[i+1] );
        status = SQLquery( select_str, &buffer1, MEM_SIZE );
        if( status == SQL_I_NO_ROWS_FOUND )
        {
	    MEMclose( &buffer1 );
	    buffer1 = NULL;
	    _NFMdebug(( fname, "Saveset mismatch on item <%s.%s> in catalog <%s>\n", item_name, item_rev, catalog_name ));
	    _NFMdebug(( fname, "%s\n", "Entry no longer exists in f_catalog" ));
	    continue;
        }
        else if( status != SQL_S_SUCCESS )
        {
   	    MEMclose( syn_list );
	    MEMclose( data_list );
	    MEMclose( &buffer );
	    MEMclose( &buffer1 );
            ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
            _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
            return ( NFM_E_SQL_QUERY );
        }

        status = MEMbuild_array( buffer1 );
        if( status != MEM_S_SUCCESS )
        {
	    MEMclose( syn_list );
   	    MEMclose( data_list );
	    MEMclose( &buffer );
	    MEMclose( &buffer1 );
   	    _NFMdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
  	    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	    return( NFM_E_MEM );
        }
        data_ptr1 = (char**)buffer1->data_ptr;

 	sprintf( select_str, "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1", 
		 catalog_name, item_name, item_rev, data_ptr1[0],
		 data_ptr1[1], data_ptr[i+4], data_ptr[i], data_ptr[i+1],
		 data_ptr[i+2] );
	status = MEMwrite( *data_list, select_str );
	if( status != MEM_S_SUCCESS )
	{
	    _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
	    MEMclose( &buffer );
	    MEMclose( syn_list );
	    MEMclose( data_list );
	    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	    return( NFM_E_MEM );
	}
	MEMclose( &buffer1 );
	buffer1 = NULL;
    }

    return( NFM_S_SUCCESS );
}

/*  This routine takes input archive numbers and after ensuring that
 *  there are no actively archived members of a saveset, it deletes
 *  that saveset ( archive_no ).
 */

long NFMdelete_savesets( data_list )
    MEMptr data_list;
{
    long   status;
    long   return_status = NFM_S_SUCCESS;

    int    i;

    char   sql_string[200];

    char   **data;
    char   **data1;

    MEMptr arch_no = NULL;
    MEMptr buffer  = NULL;

    static char *fname = "NFMdelete_savesets";

    _NFMdebug(( fname, "%s\n", "Entering ..." ));

    status = MEMbuild_array( data_list );
    if( status != MEM_S_SUCCESS )
    {
        _NFMdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data = (char**)data_list->data_ptr;

    status = MEMopen( &arch_no, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	ERRload_struct( NFM, NFM_E_MEM, "", NULL );
	_NFMdebug(( fname, "MEMopen <0x%.8x>\n", status ));
 	return( NFM_E_MEM );
    }

    status = MEMwrite_format( arch_no, "n_archiveno", "integer" );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &arch_no );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    for( i=0; i<data_list->rows*data_list->columns; i+=data_list->columns )
    {
        _NFMdebug(( fname, "catalog_no = <%s>  item_no = <%s>  file_no = <%s>\n", data[i+6], data[i+7], data[i+8] ));

        sprintf( sql_string, "SELECT n_archiveno FROM nfmsavesets WHERE n_catalogno = %s AND n_itemno = %s AND n_fileno = %s",data[i+6], data[i+7],data[i+8]);
        status = SQLquery( sql_string, &buffer, MEM_SIZE );
        if( status != SQL_S_SUCCESS )
        {
	    MEMclose( &buffer );
	    MEMclose( &arch_no );
    	    ERRload_struct( NFM, NFM_E_DELETE_SAVESET, "%s%s%s", data[i],
			   data[i+1], data[i+2] );
            _NFMdebug((fname, "SQLquery <0x%.8x>\n",status));
	    return( NFM_E_DELETE_SAVESET );
        }

	status = MEMbuild_array( buffer );
	if( status != MEM_S_SUCCESS )
	{
	    MEMclose( &buffer );
	    MEMclose( &arch_no );
	    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	    _NFMdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
	    return( NFM_E_MEM );
	}

	data1 = (char**) buffer->data_ptr;

	sprintf( sql_string, "%s\1", data1[0] );
	status = MEMwrite( arch_no, sql_string );
 	if( status != MEM_S_SUCCESS )
	{
	    MEMclose( &buffer );
	    MEMclose( &arch_no );
	    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	    _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
	    return( NFM_E_MEM );
	}
	MEMclose( &buffer );

	sprintf( sql_string, "DELETE FROM nfmsavesets WHERE n_catalogno = %s AND n_itemno = %s AND n_fileno = %s", data[i+6], data[i+7], data[i+8]);
	status = SQLstmt( sql_string );
	if( status != SQL_S_SUCCESS )
	{
	    MEMclose( &arch_no );
	    _NFMdebug(( fname, "SQLstmt <0x%.8x>\n", status ));
	    ERRload_struct( NFM, NFM_E_SQL_STMT, NULL, NULL );
	    return( NFM_E_SQL_STMT );	    
	}
	
	/*  If n_fileco is NULL for this file, delete it from the f_cat
 	 *  also.
	 */
	sprintf( sql_string, "SELECT n_fileco FROM f_%s WHERE n_itemnum = %s AND n_fileno = %s AND n_fileco IS NULL", data[i], data[i+7], data[i+8] );
        status = SQLquery( sql_string, &buffer, MEM_SIZE );
        if( (status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND) )
        {
	    MEMclose( &buffer );
	    MEMclose( &arch_no );
    	    ERRload_struct( NFM, NFM_E_SAVESET_MISMATCH, "%s%s", data[i+7],
			    data[i]);
            _NFMdebug((fname, "SQLquery <0x%.8x>\n",status));
	    return( NFM_E_SAVESET_MISMATCH );
        }
	else if( status == SQL_I_NO_ROWS_FOUND )
	{
	    MEMclose( &buffer );
	    buffer = NULL;
	    continue;
	}
	else
	{
	    sprintf( sql_string, "DELETE FROM f_%s WHERE n_itemnum = %s AND n_fileno = %s", data[i], data[i+7], data[i+8] );
  	    status = SQLstmt( sql_string );
	    if( status != SQL_S_SUCCESS )
	    {
 	        MEMclose( &arch_no );
	        _NFMdebug(( fname, "SQLstmt <0x%.8x>\n", status ));
	        ERRload_struct( NFM, NFM_E_SQL_STMT, NULL, NULL );
	        return( NFM_E_SQL_STMT );	    
	    }
	    MEMclose( &buffer );
	}
    }
    /*  Now delete any nfmarchives entries not having a corresponding entry
     *  in the nfmsavesets table.
     */

    status = MEMbuild_array( arch_no );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &arch_no );
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	_NFMdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
	return( NFM_E_MEM );
    }
    data = (char**) arch_no->data_ptr;

    for( i=0; i<arch_no->rows; ++i )
    {
	sprintf( sql_string, "SELECT n_archiveno FROM nfmsavesets WHERE n_archiveno = %s", data[i] );
	status = SQLquery( sql_string, &buffer, MEM_SIZE );
        if( (status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND) )
        {
	    MEMclose( &buffer );
	    MEMclose( &arch_no );
    	    ERRload_struct( NFM, NFM_E_SQL_QUERY, NULL, NULL );
            _NFMdebug((fname, "SQLquery <0x%.8x>\n",status));
	    return( NFM_E_SQL_QUERY );
        }
	else if( status == SQL_I_NO_ROWS_FOUND )
	{
	    sprintf( sql_string, "DELETE FROM nfmarchives WHERE n_archiveno = %s", data[i] );
  	    status = SQLstmt( sql_string );
	    if( status != SQL_S_SUCCESS )
	    {
 	        MEMclose( &arch_no );
	 	MEMclose( &buffer );
	        _NFMdebug(( fname, "SQLstmt <0x%.8x>\n", status ));
	        ERRload_struct( NFM, NFM_E_SQL_STMT, NULL, NULL );
	        return( NFM_E_SQL_STMT );	    
	    }
	}
        MEMclose( &buffer );
	buffer = NULL;
    }

    MEMclose( &arch_no );  

    _NFMdebug(( fname, "%s\n", "Exiting ..." ));

    return( return_status );
}

long NFMquery_archives_to_delete ( syn_list, data_list )
    MEMptr *syn_list;
    MEMptr *data_list;
{
    long   status;

    char   sql_string[500];
    char   fmt[NFM_SYNONYM+1];

    static char *fname = "NFMquery_archives_to_delete";

    _NFMdebug(( fname, "%s\n", "Entering ... (new)"));

/*  Open and format return buffer
 */
    status = MEMopen( syn_list, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( syn_list );
	_NFMdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_SYNONYM );
    status = MEMwrite_format( *syn_list, "name", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( syn_list );
	_NFMdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }

    sprintf( sql_string, "%s\1", "Archive Number" );
    status = MEMwrite( *syn_list, sql_string );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( syn_list );
	_NFMdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }

    sprintf( sql_string, "%s\1", "Saveset" );
    status = MEMwrite( *syn_list, sql_string );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        _NFMdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( sql_string, "%s\1", "Label" );
    status = MEMwrite( *syn_list, sql_string );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        _NFMdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( sql_string, "%s\1", "Archive Date" );
    status = MEMwrite( *syn_list, sql_string );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        _NFMdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( sql_string, "%s\n", "Archive Size" );
    status = MEMwrite( *syn_list, sql_string );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        _NFMdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    strcpy( sql_string, "SELECT n_archiveno, n_saveset, n_label, n_archivedate, n_archivesize FROM nfmarchives");
    status = SQLquery( sql_string, data_list, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
        _NFMdebug((fname, "SQLquery = <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_QUERY_ARCHIVE_TABLE, NULL, NULL );
	MEMclose( syn_list );
	MEMclose( data_list );
        return( NFM_E_QUERY_ARCHIVE_TABLE );
    }
 
    _NFMdebug((fname, "SUCCESSFUL : <0x%.8x>\n", NFM_S_SUCCESS));

    return( NFM_S_SUCCESS );
}

/*  This routine takes input archive numbers and after ensuring that
 *  there are no actively archived members of a saveset, it deletes
 *  that saveset ( archive_no ).
 */

long NFMdelete_archives( data_list )
    MEMptr data_list;
{
    long   status;
    long   return_status = NFM_S_SUCCESS;

    int    i;
    int    j;

    char   sql_string[200];

    char   **data;
    char   **state;

    static char *fname = "NFMdelete_archives";

    MEMptr buffer = NULL;

    _NFMdebug(( fname, "%s\n", "Entering ..." ));

    status = MEMbuild_array( data_list );
    if( status != MEM_S_SUCCESS )
    {
	_NFMdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }
    data = (char**)data_list->data_ptr;

    for( i=0; i<data_list->rows*data_list->columns; i+=data_list->columns )
    {
        _NFMdebug(( fname, "archive_no = <%s>\n", data[i]));
        sprintf( sql_string, "SELECT n_itemstate FROM nfmsavesets WHERE n_archiveno = %s",data[i] );
	status = SQLquery( sql_string, &buffer, MEM_SIZE );
        if( status != SQL_S_SUCCESS )
        {
	   MEMclose( &buffer );
           _NFMdebug((fname, "Sql Stmt  <0x%.8x>\n",status));
  	   ERRload_struct( NFM, NFM_E_SQL_QUERY, NULL, NULL );
	   return( NFM_E_SQL_QUERY );
        }
        status = MEMbuild_array( buffer );
        if( status != MEM_S_SUCCESS )
        {
  	    _NFMdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
	    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
 	    return( NFM_E_MEM );
        }
        state = (char**)buffer->data_ptr;

	for( j=0; j<buffer->rows*buffer->columns; j+=buffer->columns )
	{
	    if( strcmp( state[j], "A" ) == 0 )
	    {
		_NFMdebug(( fname, "Found n_itemstate = <%s>\n", state[j]));
		MEMclose( &buffer );	
		ERRload_struct( NFM, NFM_E_DELETE_ARCHIVE, "%s\n", data[i]);
		return( NFM_E_DELETE_ARCHIVE );
	    }
	}
	
  	MEMclose( &buffer );

        sprintf( sql_string, "DELETE FROM NFMSAVESETS WHERE n_archiveno = %s",data[i] );
        status = SQLstmt( sql_string );
        if( status != SQL_S_SUCCESS )
        {
  	   ERRload_struct( NFM, NFM_E_DELETE_ARCHIVE, "%s", data[i]);
           _NFMdebug((fname, "Sql Stmt : status = <0x%.8x>\n",status));
	   return( NFM_E_DELETE_ARCHIVE);
        }

        /* This saveset is OK to delete from nfmarchives table */
	sprintf( sql_string, "DELETE FROM NFMARCHIVES WHERE n_archiveno = %s", data[i] );
        status = SQLstmt( sql_string );
        if( status != SQL_S_SUCCESS )
        {
	    ERRload_struct( NFM, NFM_E_DELETE_ARCHIVE, "%s", data[i]);
            _NFMdebug((fname, "Sql Stmt : status = <0x%.8x>\n",status));
  	    return( NFM_E_DELETE_ARCHIVE );
        }
    }

    _NFMdebug(( fname, "%s\n", "Exiting ..." ));

    return( return_status );
}
