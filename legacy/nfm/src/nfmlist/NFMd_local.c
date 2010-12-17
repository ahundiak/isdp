#include "machine.h"
#include <stdio.h>
#include "NFMapi.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "DEBUG.h"
#include "ERR.h"

#define  BUFFER_SIZE  4000

long NFMdisplay_local_files( storage, search, sort, syn_list, data_list )

char   *storage;
char   *search;
char   *sort;
MEMptr *syn_list;
MEMptr *data_list;
{
    int    i;
    int    j;
    int    cnt=0;
    long   status;
    char   fmt[20];
    char   str[NFM_SYNONYM+3];
    char   catalog[NFM_CATALOGNAME+1];
    char   select_str[1024];
    char   storage_no[INTEGER+1];
    char   storage_path[NFM_PATHNAME+1];
    char   **data_ptr1;
    char   **data_ptr2;
    MEMptr buffer1 = NULL;
    MEMptr buffer2 = NULL;

    static char *fname = "NFMdisplay_local_files";

    _NFMdebug(( fname, "Storage <%s>\n", storage ));
    _NFMdebug(( fname, "Search  <%s>\n", search ));
    _NFMdebug(( fname, "Sort    <%s>\n", sort ));

    if( strlen( storage ) == 0 )
    {
        ERRload_struct (NFM,  NFM_E_DISPLAY_LOCAL, "%s", " " );
        return ( NFM_E_DISPLAY_LOCAL );
    }

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

    strcpy( str, "Filename\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    strcpy( str, "Catalog\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    strcpy( str, "Item Name\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    strcpy( str, "Revision\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    strcpy( str, "Version\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    strcpy( str, "Checked Out?\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    strcpy( str, "Copied?\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    strcpy( str, "No. of References\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    strcpy( str, "NFS?\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    strcpy( str, "NFS - Mounted SA\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    strcpy( str, "Local Mount Point\1" );
    status = MEMwrite( *syn_list, str );
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
	ERRload_struct( NFM, NFM_E_MEM, "", NULL );
	_NFMdebug(( fname, "MEMopen <0x%.8x>\n", status ));
 	return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_FILENAME );
    status = MEMwrite_format( *data_list, "n_filename", fmt );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( data_list );
        MEMclose( syn_list ); 
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    sprintf( fmt, "char(%d)", NFM_CATALOGNAME );
    status = MEMwrite_format( *data_list, "n_catalogname", fmt );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( data_list );
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    sprintf( fmt, "char(%d)", NFM_ITEMNAME );
    status = MEMwrite_format( *data_list, "n_itemname", fmt );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( data_list );
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    sprintf( fmt, "char(%d)", NFM_ITEMREV );
    status = MEMwrite_format( *data_list, "n_itemrev", fmt );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( data_list );
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    sprintf( fmt, "char(%d)", NFM_FILEVERSION );
    status = MEMwrite_format( *data_list, "n_fileversion", fmt );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( data_list );
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    sprintf( fmt, "char(%d)", NFM_CO );
    status = MEMwrite_format( *data_list, "n_co", fmt );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( data_list );
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    sprintf( fmt, "char(%d)", NFM_COPY );
    status = MEMwrite_format( *data_list, "n_copy", fmt );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( data_list );
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    sprintf( fmt, "char(%d)", NFM_REF );
    status = MEMwrite_format( *data_list, "n_ref", fmt );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( data_list );
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    sprintf( fmt, "char(%d)", NFM_NFS );
    status = MEMwrite_format( *data_list, "n_nfs", fmt );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( data_list );
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    sprintf( fmt, "char(%d)", NFM_SANAME );
    status = MEMwrite_format( *data_list, "n_saname", fmt );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( data_list );
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    sprintf( fmt, "char(%d)", NFM_MOUNTPOINT );
    status = MEMwrite_format( *data_list, "n_mountpoint", fmt );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( data_list );
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    cnt = 0;
    sprintf( select_str, "SELECT n_sano,n_pathname FROM nfmstoragearea WHERE n_saname = '%s'",storage );
    status = SQLquery( select_str, &buffer1, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
        MEMclose( &buffer1 );
        MEMclose( syn_list );
        MEMclose( data_list );
        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_SQL_QUERY);
    }
    status = MEMbuild_array( buffer1 );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &buffer1 );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    data_ptr1 = (char**)buffer1->data_ptr;
    strcpy( storage_no, data_ptr1[0] );
    strcpy( storage_path, data_ptr1[1] );
    MEMclose( &buffer1 );

    sprintf( select_str, "SELECT DISTINCT n_catalogno FROM nfmsafiles WHERE n_sano = %s",storage_no );
    status = SQLquery( select_str, &buffer1, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
        MEMclose( &buffer1 );
        MEMclose( syn_list );
        MEMclose( data_list );
        ERRload_struct (NFM,  NFM_E_DISPLAY_LOCAL, "%s", storage );
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_DISPLAY_LOCAL );
     }
    status = MEMbuild_array( buffer1 );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &buffer1 );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    data_ptr1 = (char**)buffer1->data_ptr;

    for( i=0; i<buffer1->rows*buffer1->columns; ++i )
    {
        sprintf( select_str, "SELECT n_catalogname FROM nfmcatalogs WHERE n_catalogno = %s", data_ptr1[i] );
        status = SQLquery( select_str, &buffer2, MEM_SIZE );
        if( status != SQL_S_SUCCESS )
        {
            MEMclose( &buffer1 );
	    MEMclose( &buffer2 );
            MEMclose( syn_list );
            MEMclose( data_list );
            ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
            _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
            return ( NFM_E_SQL_QUERY);
        }
        status = MEMbuild_array( buffer2 );
        if( status != MEM_S_SUCCESS )
        {
	    MEMclose( &buffer1 );
            MEMclose( &buffer2 );
            ERRload_struct( NFM, NFM_E_MEM, "", NULL );
            _NFMdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
            return( NFM_E_MEM );
        }

        data_ptr2 = (char**)buffer2->data_ptr;
	strncpy( catalog, data_ptr2[0], NFM_CATALOGNAME );
 	MEMclose( &buffer2 );

        sprintf( select_str, "SELECT nfmsafiles.n_filename,%s.n_itemname,%s.n_itemrev,nfmsafiles.n_fileversion,nfmsafiles.n_co,nfmsafiles.n_copy,nfmsafiles.n_ref,nfmsafiles.n_nfs,nfmsafiles.n_cisano,nfmsafiles.n_mountpoint FROM nfmsafiles,%s WHERE (%s.n_itemno=nfmsafiles.n_itemno) AND (nfmsafiles.n_sano = %s) AND (nfmsafiles.n_catalogno = %s)",
catalog, catalog, catalog, catalog, storage_no, data_ptr1[i] );
        if( strlen(search) > 0 )
        {
            strcat( select_str, " AND (" );
            strcat( select_str, search );
            strcat( select_str, ")" );
        }
	strcat( select_str, " ORDER BY " );
	strcat( select_str, catalog );
	strcat( select_str, ".n_itemname," );
 	strcat( select_str, catalog );
	strcat( select_str, ".n_itemrev,nfmsafiles.n_filename,nfmsafiles.n_fileversion" );

        status = SQLquery( select_str, &buffer2, BUFFER_SIZE );
        if( status == SQL_I_NO_ROWS_FOUND )
	{
	    MEMclose( &buffer2 );
	    continue;
	}
        else if( status != SQL_S_SUCCESS )
        {
            MEMclose( &buffer1 );
	    MEMclose( &buffer2 );
            MEMclose( syn_list );
            MEMclose( data_list );
            ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL );
            _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
            return ( NFM_E_SQL_QUERY );
        }
        status = MEMbuild_array( buffer2 );
        if( status != MEM_S_SUCCESS )
        {
	    MEMclose( &buffer1 );
            MEMclose( &buffer2 );
            ERRload_struct( NFM, NFM_E_MEM, "", NULL );
            _NFMdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
            return( NFM_E_MEM );
        }

        data_ptr2 = (char**)buffer2->data_ptr;

	_NFMdebug(( fname, "Rows <%d>\n", buffer2->rows ));
	_NFMdebug(( fname, "Cols <%d>\n", buffer2->columns ));

	for( j=0; j<(buffer2->rows*buffer2->columns); j+=buffer2->columns )
	{
	    sprintf( select_str,"%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",
		     data_ptr2[j], catalog, data_ptr2[j+1], data_ptr2[j+2],
		     data_ptr2[j+3], data_ptr2[j+4], data_ptr2[j+5],
		     data_ptr2[j+6], data_ptr2[j+7], data_ptr2[j+8],
		     data_ptr2[j+9] );
	    _NFMdebug(( fname, "Str <%s>\n", select_str ));
	    ++cnt;
	    status = MEMwrite( *data_list, select_str );
	    if( status != MEM_S_SUCCESS )
	    {
     	        MEMclose( &buffer1 );
                MEMclose( &buffer2 );
                ERRload_struct( NFM, NFM_E_MEM, "", NULL );
                _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
                return( NFM_E_MEM );		
	    }
	}
 	MEMclose( &buffer2 );
    }
    MEMclose( &buffer1 );
 
/*  If there were no rows found at all ... */
    if( cnt == 0 )
    {
        MEMclose( syn_list );
        MEMclose( data_list );
        ERRload_struct (NFM,  NFM_E_DISPLAY_LOCAL, "%s", storage_path );
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_DISPLAY_LOCAL );
    }
 
    _NFMdebug(( fname, "%s\n", "Returning ... " ));
    
    return( NFM_S_SUCCESS );
}

