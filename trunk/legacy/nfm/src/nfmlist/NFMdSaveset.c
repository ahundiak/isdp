#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"
#include "NFMschema.h"

#define  BUFFER_SIZE  4000
/*
 Doc: NFMlist_savesets

 Abstract:  This routine queries for contents of nfmsavesets table.
 */

long NFMlist_savesets ( user_id, data_list )
    long   user_id;
    MEMptr *data_list;
{
    long   status;

    int    i;
    int	   j;
    int    k;

    char   sql_string[500];

    char   **data;

    static char *fname = "NFMlist_savesets";

    MEMptr dbuff  = NULL;
    MEMptr rbuff  = NULL;
    MEMptr buffer = NULL;

    _NFMdebug ((fname, "%s\n", "Entering ..."));

    strcpy( sql_string, "SELECT n_synonym, n_datatype, n_name FROM nfmsysattributes WHERE n_tableno IN ( SELECT n_tableno FROM nfmtables where n_tablename='nfmsavesets' )" );
    status = SQLquery( sql_string, &buffer, BUFFER_SIZE);
    if( status != SQL_S_SUCCESS )
    {
        _NFMdebug ((fname,"SQLquery = <0x%.8x>\n", status));
        MEMclose (&buffer);
	ERRload_struct( NFM, NFM_E_SQL_QUERY, NULL, NULL );
	return( NFM_E_SQL_QUERY );
    }

    MEMbuild_array (buffer);

    data = (char **) buffer->data_ptr;
    sprintf( sql_string, "SELECT " );
    for( i=0; i<((buffer->rows*buffer->columns)-buffer->columns);
	      i+=buffer->columns )
    {
	strcat( sql_string, data[i+2] );
        strcat( sql_string, "," );
    }
    strcat( sql_string, data[(buffer->rows*buffer->columns)-1] );
    strcat( sql_string, " FROM nfmsavesets" );

    status = SQLquery( sql_string, &dbuff, BUFFER_SIZE);
    if( status != SQL_S_SUCCESS )
    {
        _NFMdebug ((fname,"SQLquery = <0x%.8x>\n", status));
        MEMclose (&buffer);
	MEMclose (&dbuff);
        ERRload_struct( NFM, NFM_E_DISPLAY_ARCHIVES, NULL, NULL );
        return( NFM_E_DISPLAY_ARCHIVES );	
    }
    MEMbuild_array (dbuff);

/*  We have buffers of synonym names, datatype and data -- Now build
 *  a return buffer of the combination.
 */
    status = MEMopen( &rbuff, BUFFER_SIZE);
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &buffer );
	MEMclose( &dbuff );
	MEMclose( &rbuff );
	_NFMdebug ((fname, "MEMopen : <0x%.8x>\n", status ));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }

    for( i=0,k=0; i<(buffer->rows*buffer->columns); i+=buffer->columns,++k )
    {
	if( strcmp( data[i+2], "n_catalogno" ) == 0 )
	    strcpy( data[i], "Catalog Name" );
	else if( strcmp( data[i+2], "n_itemno" ) == 0 )
	    strcpy( data[i], "Item Name" );
	else if( strcmp( data[i+2], "n_fileno" ) == 0 )
	    strcpy( data[i], "Revision" );

        status = MEMwrite_format( rbuff, data[i], data[i+1] );
        if( status != MEM_S_SUCCESS )
        {
	    MEMclose( &buffer );
	    MEMclose( &rbuff );
  	    MEMclose( &dbuff );
  	    _NFMdebug ((fname, "MEMwrite_format : <0x%.8x>\n", status ));
	    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	    return( NFM_E_MEM );
        }
    }
    MEMclose( &buffer );
	
    data = (char**) dbuff->data_ptr;
    for( i=0,k=0; i<dbuff->rows; ++i)
    {
	sql_string[0] = 0;
	for( j=0; j<dbuff->columns; ++j,++k )
	{
	    strcat( sql_string, data[k] );
	    strcat( sql_string, "\1" );
	}
	status = MEMwrite( rbuff, sql_string );
	if( status != MEM_S_SUCCESS )
 	{
	    MEMclose( &rbuff );
	    MEMclose( &dbuff );
            _NFMdebug ((fname, "MEMwrite : status <0x%.8x>\n", status));
	    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	    return( NFM_E_MEM );
	}
    } 

    status = MEMsplit_copy_buffer( rbuff, data_list, 0 );
    if( status != MEM_S_SUCCESS )
    {
        _NFMdebug ((fname, "MEMsplit_copy_buffer = <0x%.8x>\n", status));
	MEMclose( &rbuff );
        MEMclose( &dbuff );
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    MEMclose( &rbuff );
    MEMclose( &dbuff );

    _NFMdebug (( fname, "SUCCESSFUL : <0x%.8x>\n", NFM_S_SUCCESS));

    return( NFM_S_SUCCESS );
}

long NFMdisplay_savesets( search, sort, syn_list, data_list )

char   *search;
char   *sort;
MEMptr *syn_list;
MEMptr *data_list;
{ 
    int    i;
    int    record_written = FALSE;
    long   status;
    long   user_id = 0;  
    char   fmt[NFM_SYNONYM+3];
    char   catalog_name[NFM_CATALOGNAME+1];
    char   item_name[NFM_ITEMNAME+1];
    char   item_rev[NFM_ITEMREV+1];
    char   co_filename[NFM_COFILENAME+1];
    char   select_str[1024];
    char   **data_ptr;
    char   **data_ptr1;
    MEMptr buffer  = NULL;
    MEMptr buffer1 = NULL;
    static char *fname = "NFMdisplay_savesets";

    _NFMdebug(( fname, "Search  <%s>\n", search ));
    _NFMdebug(( fname, "Sort    <%s>\n", sort ));

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

    strcpy( select_str, "Archive Number\1" );
    status = MEMwrite( *syn_list, select_str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
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

    strcpy( select_str, "Local File Name\1" );
    status = MEMwrite( *syn_list, select_str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    strcpy( select_str, "Item State\1" );
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

    status = MEMopen( data_list, BUFFER_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( syn_list );
	ERRload_struct( NFM, NFM_E_MEM, "", NULL );
	_NFMdebug(( fname, "MEMopen <0x%.8x>\n", status ));
 	return( NFM_E_MEM );
    }
  
    sprintf( fmt, "char(%d)", NFM_SYNONYM );
    status = MEMwrite_format( *data_list, "n_archiveno", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( syn_list );
	MEMclose( data_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    status = MEMwrite_format( *data_list, "n_catalogname", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( syn_list );
	MEMclose( data_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    status = MEMwrite_format( *data_list, "n_itemname", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( syn_list );
	MEMclose( data_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    status = MEMwrite_format( *data_list, "n_itemrev", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( syn_list );
	MEMclose( data_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    status = MEMwrite_format( *data_list, "n_cofilename", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( syn_list );
	MEMclose( data_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    status = MEMwrite_format( *data_list, "n_itemstate", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( syn_list );
	MEMclose( data_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    status = MEMwrite_format( *data_list, "n_restoredate", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( syn_list );
	MEMclose( data_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
   
    strcpy( select_str, "SELECT nfmsavesets.n_archiveno,nfmsavesets.n_catalogno, nfmsavesets.n_itemno,nfmsavesets.n_fileno, nfmsavesets.n_itemstate,nfmsavesets.n_restoredate FROM nfmsavesets" );
    status = SQLquery( select_str, &buffer, BUFFER_SIZE );
    if( status == SQL_I_NO_ROWS_FOUND )
    {
        MEMclose( syn_list );
	MEMclose( data_list );
        MEMclose( &buffer );
        ERRload_struct (NFM, NFM_E_DISPLAY_ARCHIVES, "", NULL);
        return ( NFM_E_DISPLAY_ARCHIVES );
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
	status = NFMfl_get_catalog_name( data_ptr[i+1], catalog_name );
	if( status != NFM_S_SUCCESS )
	{
	    MEMclose( &buffer );
	    MEMclose( syn_list );
  	    MEMclose( data_list );
	    return( status );
	}

        sprintf( select_str, "SELECT n_itemname, n_itemrev FROM %s WHERE n_itemno = %s", catalog_name, data_ptr[i+2] );
        status = SQLquery( select_str, &buffer1, BUFFER_SIZE );
        if( status == SQL_I_NO_ROWS_FOUND )
        {
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

        sprintf( select_str, "SELECT n_cofilename FROM f_%s WHERE n_fileno = %s AND n_itemnum = %s", catalog_name, data_ptr[i+3], data_ptr[i+2]);
        status = SQLquery( select_str, &buffer1, BUFFER_SIZE );
        if( status == SQL_I_NO_ROWS_FOUND )
        {
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
	strcpy( co_filename, data_ptr1[0] );
	MEMclose( &buffer1 );

 	sprintf( select_str, "%s\1%s\1%s\1%s\1%s\1%s\1%s\1", data_ptr[i],
		 catalog_name, item_name, item_rev, co_filename,
		 data_ptr[i+4], data_ptr[i+5] );
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
	record_written = TRUE;
    }

    if (!record_written)
    {
        _NFMdebug(( fname, "No records written\n" ));
        ERRload_struct (NFM, NFM_E_DISPLAY_ARCHIVES, "", NULL);
        return( NFM_E_DISPLAY_ARCHIVES );
    }

    _NFMdebug(( fname, "Returning SUCCESS\n" ));
    ERRload_struct (NFM, NFM_S_SUCCESS, "", NULL);

    return( NFM_S_SUCCESS );
}
