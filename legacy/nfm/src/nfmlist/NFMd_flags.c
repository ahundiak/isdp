#include "machine.h"
#include <stdio.h>
#include "NFMapi.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "UTIerrordef.h"
#include "DEBUG.h"
#include "ERR.h"
 
#define  BUFFER_SIZE  4000

long NFMdisplay_archive_flags( search, sort, syn_list, data_list )

char   *search;
char   *sort;
MEMptr *syn_list;
MEMptr *data_list;
{
    int    cconstant;
    int    vconstant;
    int    ccnt;
    int    vcnt;
    int    isflag = 0;
    long   status;
    char   fmt[20];
    char   str[NFM_SYNONYM+3];
    char   select_str[1024];
    char   **vdata_ptr;
    char   **cdata_ptr;
    MEMptr vdata = NULL;
    MEMptr cdata = NULL;

    static char *fname = "NFMdisplay_archive_flags";

    _NFMdebug(( fname, "Search <%s>\n", search ));
    _NFMdebug(( fname, "Sort   <%s>\n", sort ));

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
    strcpy( str, "Pending Flag\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

/*  Start buffers to send back to requester 
 */
    status = MEMopen( data_list, BUFFER_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
        MEMclose( syn_list );
	return( status );
    }

    sprintf( fmt, "char(%d)", NFM_CATALOGNAME );
    status = MEMwrite_format( *data_list, "Catalog Name", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
        MEMclose( syn_list );
	return( status );
    }

    sprintf( fmt, "char(%d)", NFM_ITEMNAME );
    status = MEMwrite_format( *data_list, "Item Name", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
        MEMclose( syn_list );
	return( status );
    }

    sprintf( fmt, "char(%d)", NFM_ITEMREV );
    status = MEMwrite_format( *data_list, "Revision", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
        MEMclose( syn_list );
	return( status );
    }

    sprintf( fmt, "char(%d)", NFM_PENDINGFLAG );
    status = MEMwrite_format( *data_list, "Pending Flag", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
        MEMclose( syn_list );
	return( status );
    }

    strcpy(select_str,"SELECT n_catalogname, n_catalogno FROM nfmcatalogs");
    status = SQLquery( select_str, &cdata, MEM_SIZE );
    if( status != SQL_S_SUCCESS  )
    {
	_NFMdebug(( fname, "Query status <0x%.8x>\n", status ));
	ERRload_struct( NFM, NFM_E_SQL_QUERY, NULL, NULL );
	MEMclose( data_list );
        MEMclose( syn_list );
	return( NFM_E_SQL_QUERY );
    }
    
    MEMbuild_array( cdata );
    cdata_ptr = (char**) cdata->data_ptr;
    cconstant = cdata->columns * cdata->rows;

    /*  Loop through all catalogs searching for flagged files 
     */
    for( ccnt = 0; ccnt < cconstant; ccnt += cdata->columns )
    {
	vdata = NULL;
	_NFMdebug(( fname, "Query catalog <%s>\n", cdata_ptr[ccnt] ));

	sprintf( select_str, "SELECT n_itemname,n_itemrev,n_pendingflag FROM %s WHERE n_pendingflag IN ( 'IA','MA','SA','PA')",cdata_ptr[ccnt]);

	status = SQLquery( select_str, &vdata, MEM_SIZE );
	if( status != SQL_S_SUCCESS )
	{
	    MEMclose( &vdata );
	    _NFMdebug(( fname, "NO flags for catalog <%s>\n",cdata_ptr[ccnt]));
	    ERRload_struct( UTI, UTI_E_NO_FILES_FLAGGED, "%s", 
			     cdata_ptr[ccnt]);
	    continue;	
	}
	
	_NFMdebug(( fname, "%s\n", "Flagged File Found" ) );
 	isflag     = 1;
	MEMbuild_array( vdata );
	vdata_ptr = (char**) vdata->data_ptr;
	vconstant = vdata->rows * vdata->columns;

	for( vcnt = 0; vcnt < vconstant; vcnt += vdata->columns )
	{
	    sprintf( select_str, "%s\1%s\1%s\1%s\1", cdata_ptr[ccnt],
			vdata_ptr[vcnt], vdata_ptr[vcnt+1], vdata_ptr[vcnt+2]);

	    status = MEMwrite( *data_list, select_str );
	    if( status != MEM_S_SUCCESS )
	    {
		MEMclose( &cdata );
	 	MEMclose( &vdata );
	        MEMclose( syn_list );
		MEMclose( data_list );
		return( status );
	    }
	} /* end 'item' for-loop */
	MEMclose( &vdata );	

    } /* end 'catalog' for-loop */
    MEMclose( &cdata );

/*  If no files were flagged -- reset chosen buffer to NULL ( it now has
 *  formats without data if no files were found .
 */
    if( !isflag )
    {
	MEMclose( data_list );
	*data_list = NULL;
	_NFMdebug(( fname, "%s\n", "NO FLAGGED FILES FOUND " ));
 	ERRload_struct( UTI, UTI_I_NO_FLAGGED_FILES, NULL, NULL );
        return( UTI_I_NO_FLAGGED_FILES );
    }
/*  If there are flagged files, reset the error structure because
 *  there may be error messages loaded from catalogs that had no
 *  flagged files.
 */
    ERRreset_struct();

    return( NFM_S_SUCCESS );
}

long NFMdisplay_backup_flags( search, sort, syn_list, data_list )

char   *search;
char   *sort;
MEMptr *syn_list;
MEMptr *data_list;

{
    int    cconstant;
    int    vconstant;
    int    ccnt;
    int    vcnt;
    int    isflag = 0;
    long   status;
    char   fmt[20];
    char   str[NFM_SYNONYM+3];
    char   select_str[1024];
    char   **cdata_ptr;
    char   **vdata_ptr;
    MEMptr cdata = NULL;
    MEMptr vdata = NULL;

    static char *fname = "NFMdisplay_backup_flags";

    _NFMdebug(( fname, "Search <%s>\n", search ));
    _NFMdebug(( fname, "Sort   <%s>\n", sort ));

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
    strcpy( str, "Pending Flag\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

/*  Start buffers to send back to requester 
 */
    status = MEMopen( data_list, BUFFER_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
        MEMclose( syn_list );
	return( status );
    }

    sprintf( fmt, "char(%d)", NFM_CATALOGNAME );
    status = MEMwrite_format( *data_list, "Catalog Name", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
        MEMclose( syn_list );
	return( status );
    }

    sprintf( fmt, "char(%d)", NFM_ITEMNAME );
    status = MEMwrite_format( *data_list, "Item Name", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
        MEMclose( syn_list );
	return( status );
    }

    sprintf( fmt, "char(%d)", NFM_ITEMREV );
    status = MEMwrite_format( *data_list, "Revision", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
        MEMclose( syn_list );
	return( status );
    }

    sprintf( fmt, "char(%d)", NFM_PENDINGFLAG );
    status = MEMwrite_format( *data_list, "Pending Flag", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
        MEMclose( syn_list );
	return( status );
    }

    strcpy(select_str,"SELECT n_catalogname, n_catalogno FROM nfmcatalogs");
    status = SQLquery( select_str, &cdata, MEM_SIZE );
    if( status != SQL_S_SUCCESS  )
    {
	_NFMdebug(( fname, "Query status <0x%.8x>\n", status ));
	ERRload_struct( NFM, NFM_E_SQL_QUERY, NULL, NULL );
	MEMclose( data_list );
        MEMclose( syn_list );
	return( NFM_E_SQL_QUERY );
    }
    
    MEMbuild_array( cdata );
    cdata_ptr = (char**) cdata->data_ptr;
    cconstant = cdata->columns * cdata->rows;

    /*  Loop through all catalogs searching for flagged files 
     */
    for( ccnt = 0; ccnt < cconstant; ccnt += cdata->columns )
    {
	vdata = NULL;
	_NFMdebug(( fname, "Query catalog <%s>\n", cdata_ptr[ccnt] ));

        sprintf( select_str, "SELECT n_itemname,n_itemrev,n_pendingflag FROM %s WHERE n_pendingflag IN ( 'IB','MB','SB','PB')",cdata_ptr[ccnt]);

	status = SQLquery( select_str, &vdata, MEM_SIZE );
	if( status != SQL_S_SUCCESS )
	{
	    MEMclose( &vdata );
	    _NFMdebug(( fname, "NO flags for catalog <%s>\n",cdata_ptr[ccnt]));
	    ERRload_struct( UTI, UTI_E_NO_FILES_FLAGGED, "%s", 
			     cdata_ptr[ccnt]);
	    continue;	
	}
	
	_NFMdebug(( fname, "%s\n", "Flagged File Found" ) );
 	isflag     = 1;
	MEMbuild_array( vdata );
	vdata_ptr = (char**) vdata->data_ptr;
	vconstant = vdata->rows * vdata->columns;

	for( vcnt = 0; vcnt < vconstant; vcnt += vdata->columns )
	{
	    sprintf( select_str, "%s\1%s\1%s\1%s\1", cdata_ptr[ccnt],
			vdata_ptr[vcnt], vdata_ptr[vcnt+1], vdata_ptr[vcnt+2]);

	    status = MEMwrite( *data_list, select_str );
	    if( status != MEM_S_SUCCESS )
	    {
		MEMclose( &cdata );
	 	MEMclose( &vdata );
	        MEMclose( syn_list );
		MEMclose( data_list );
		return( status );
	    }
	} /* end 'item' for-loop */
	MEMclose( &vdata );	

    } /* end 'catalog' for-loop */
    MEMclose( &cdata );

/*  If no files were flagged -- reset chosen buffer to NULL ( it now has
 *  formats without data if no files were found .
 */
    if( !isflag )
    {
	MEMclose( data_list );
	*data_list = NULL;
	_NFMdebug(( fname, "%s\n", "NO FLAGGED FILES FOUND " ));
 	ERRload_struct( UTI, UTI_I_NO_FLAGGED_FILES, NULL, NULL );
        return( UTI_I_NO_FLAGGED_FILES );
    }
/*  If there are flagged files, reset the error structure because
 *  there may be error messages loaded from catalogs that had no
 *  flagged files.
 */
    ERRreset_struct();

    return( NFM_S_SUCCESS );
}

long NFMdisplay_restore_flags( search, sort, syn_list, data_list )

char   *search;
char   *sort;
MEMptr *syn_list;
MEMptr *data_list;
{
    int    cconstant;
    int    vconstant;
    int    ccnt;
    int    vcnt;
    int    isflag = 0;
    long   status;
    char   fmt[20];
    char   str[NFM_SYNONYM+3];
    char   select_str[1024];
    char   **vdata_ptr;
    char   **cdata_ptr;
    MEMptr vdata = NULL;
    MEMptr cdata = NULL;

    static char *fname = "NFMdisplay_restore_flags";

    _NFMdebug(( fname, "Search <%s>\n", search ));
    _NFMdebug(( fname, "Sort   <%s>\n", sort ));

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
    strcpy( str, "Local Filename\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    strcpy( str, "File Version\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    strcpy( str, "Pending Flag\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

/*  Start buffers to send back to requester 
 */
    status = MEMopen( data_list, BUFFER_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
        MEMclose( syn_list );
	return( status );
    }

    sprintf( fmt, "char(%d)", NFM_CATALOGNAME );
    status = MEMwrite_format( *data_list, "Catalog Name", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
        MEMclose( syn_list );
	return( status );
    }

    sprintf( fmt, "char(%d)", NFM_ITEMNAME );
    status = MEMwrite_format( *data_list, "Item Name", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
        MEMclose( syn_list );
	return( status );
    }

    sprintf( fmt, "char(%d)", NFM_ITEMREV );
    status = MEMwrite_format( *data_list, "Revision", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
        MEMclose( syn_list );
	return( status );
    }

    sprintf( fmt, "char(%d)", NFM_FILENAME );
    status = MEMwrite_format( *data_list, "Local Filename", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
        MEMclose( syn_list );
	return( status );
    }

    sprintf( fmt, "char(%d)", NFM_FILEVERSION );
    status = MEMwrite_format( *data_list, "Fileversion", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
        MEMclose( syn_list );
	return( status );
    }

    sprintf( fmt, "char(%d)", NFM_PENDINGFLAG );
    status = MEMwrite_format( *data_list, "Pending Flag", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
        MEMclose( syn_list );
	return( status );
    }

    strcpy(select_str,"SELECT n_catalogname, n_catalogno FROM nfmcatalogs");
    status = SQLquery( select_str, &cdata, MEM_SIZE );
    if( status != SQL_S_SUCCESS  )
    {
	_NFMdebug(( fname, "Query status <0x%.8x>\n", status ));
	ERRload_struct( NFM, NFM_E_SQL_QUERY, NULL, NULL );
	MEMclose( data_list );
        MEMclose( syn_list );
	return( NFM_E_SQL_QUERY );
    }
    
    MEMbuild_array( cdata );
    cdata_ptr = (char**) cdata->data_ptr;
    cconstant = cdata->columns * cdata->rows;

    /*  Loop through all catalogs searching for flagged files 
     */
    for( ccnt = 0; ccnt < cconstant; ccnt += cdata->columns )
    {
	vdata = NULL;
	_NFMdebug(( fname, "Query catalog <%s>\n", cdata_ptr[ccnt] ));

        sprintf( select_str, "SELECT %s.n_itemname,%s.n_itemrev,f_%s.n_cofilename,f_%s.n_fileversion,%s.n_pendingflag FROM %s,f_%s WHERE %s.n_pendingflag IN ( 'IR','MR','SR','PR') AND f_%s.n_restoreflag IN ('IR','MR','SR','PR' ) AND %s.n_itemno=f_%s.n_itemnum",cdata_ptr[ccnt], cdata_ptr[ccnt],cdata_ptr[ccnt], cdata_ptr[ccnt], cdata_ptr[ccnt], cdata_ptr[ccnt],cdata_ptr[ccnt],cdata_ptr[ccnt],cdata_ptr[ccnt],cdata_ptr[ccnt],cdata_ptr[ccnt]);

	status = SQLquery( select_str, &vdata, BUFFER_SIZE );
	if( status != SQL_S_SUCCESS )
	{
	    MEMclose( &vdata );
	    _NFMdebug(( fname, "NO flags for catalog <%s>\n",cdata_ptr[ccnt]));
	    ERRload_struct( UTI, UTI_E_NO_FILES_FLAGGED, "%s", 
			     cdata_ptr[ccnt]);
	    continue;	
	}
	
	_NFMdebug(( fname, "%s\n", "Flagged File Found" ) );
 	isflag     = 1;
	MEMbuild_array( vdata );
	vdata_ptr = (char**) vdata->data_ptr;
	vconstant = vdata->rows * vdata->columns;
	for( vcnt = 0; vcnt < vconstant; vcnt += vdata->columns )
	{
	    sprintf( select_str, "%s\1%s\1%s\1%s\1%s\1%s\1", 
	cdata_ptr[ccnt],vdata_ptr[vcnt], vdata_ptr[vcnt+1], vdata_ptr[vcnt+2],
	vdata_ptr[vcnt+3], vdata_ptr[vcnt+4] );

	    status = MEMwrite( *data_list, select_str );
	    if( status != MEM_S_SUCCESS )
	    {
		MEMclose( &cdata );
	 	MEMclose( &vdata );
	        MEMclose( syn_list );
		MEMclose( data_list );
		return( status );
	    }
	} /* end 'item' for-loop */
	MEMclose( &vdata );
    } /* end 'catalog' for-loop */
    MEMclose( &cdata );

/*  If no files were flagged -- reset chosen buffer to NULL ( it now has
 *  formats without data if no files were found .
 */
    if( !isflag )
    {
	MEMclose( data_list );
	*data_list = NULL;
	_NFMdebug(( fname, "%s\n", "NO FLAGGED FILES FOUND " ));
 	ERRload_struct( UTI, UTI_I_NO_FLAGGED_FILES, NULL, NULL );
        return( UTI_I_NO_FLAGGED_FILES );
    }
/*  If there are flagged files, reset the error structure because
 *  there may be error messages loaded from catalogs that had no
 *  flagged files.
 */
    ERRreset_struct();

    return( NFM_S_SUCCESS );
}

long NFMdisplay_delete_flags( search, sort, syn_list, data_list )

char   *search;
char   *sort;
MEMptr *syn_list;
MEMptr *data_list;
{
    int    cconstant;
    int    vconstant;
    int    ccnt;
    int    vcnt;
    int    isflag = 0;
    long   status;
    char   fmt[20];
    char   str[NFM_SYNONYM+3];
    char   select_str[1024];
    char   **cdata_ptr;
    char   **vdata_ptr;
    MEMptr cdata = NULL;
    MEMptr vdata = NULL;

    static char *fname = "NFMdisplay_delete_flags";

    _NFMdebug(( fname, "Search <%s>\n", search ));
    _NFMdebug(( fname, "Sort   <%s>\n", sort ));

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
    strcpy( str, "Pending Flag\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

/*  Start buffers to send back to requester 
 */
    status = MEMopen( data_list, BUFFER_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
        MEMclose( syn_list );
	return( status );
    }

    sprintf( fmt, "char(%d)", NFM_CATALOGNAME );
    status = MEMwrite_format( *data_list, "Catalog Name", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
        MEMclose( syn_list );
	return( status );
    }

    sprintf( fmt, "char(%d)", NFM_ITEMNAME );
    status = MEMwrite_format( *data_list, "Item Name", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
        MEMclose( syn_list );
	return( status );
    }

    sprintf( fmt, "char(%d)", NFM_ITEMREV );
    status = MEMwrite_format( *data_list, "Revision", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
        MEMclose( syn_list );
	return( status );
    }

    sprintf( fmt, "char(%d)", NFM_PENDINGFLAG );
    status = MEMwrite_format( *data_list, "Pending Flag", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
        MEMclose( syn_list );
	return( status );
    }

    strcpy(select_str,"SELECT n_catalogname, n_catalogno FROM nfmcatalogs");
    status = SQLquery( select_str, &cdata, MEM_SIZE );
    if( status != SQL_S_SUCCESS  )
    {
	_NFMdebug(( fname, "Query status <0x%.8x>\n", status ));
	ERRload_struct( NFM, NFM_E_SQL_QUERY, NULL, NULL );
	MEMclose( data_list );
        MEMclose( syn_list );
	return( NFM_E_SQL_QUERY );
    }
    
    MEMbuild_array( cdata );
    cdata_ptr = (char**) cdata->data_ptr;
    cconstant = cdata->columns * cdata->rows;

    /*  Loop through all catalogs searching for flagged files 
     */
    for( ccnt = 0; ccnt < cconstant; ccnt += cdata->columns )
    {
	vdata = NULL;
	_NFMdebug(( fname, "Query catalog <%s>\n", cdata_ptr[ccnt] ));

        sprintf( select_str, "SELECT n_itemname,n_itemrev,n_pendingflag FROM %s WHERE n_pendingflag IN ( 'ID','MD','SD','PD')",cdata_ptr[ccnt]);

	status = SQLquery( select_str, &vdata, BUFFER_SIZE );
	if( status != SQL_S_SUCCESS )
	{
	    MEMclose( &vdata );
	    _NFMdebug(( fname, "NO flags for catalog <%s>\n",cdata_ptr[ccnt]));
	    ERRload_struct( UTI, UTI_E_NO_FILES_FLAGGED, "%s", 
			     cdata_ptr[ccnt]);
	    continue;	
	}
	
	_NFMdebug(( fname, "%s\n", "Flagged File Found" ) );
 	isflag     = 1;
	MEMbuild_array( vdata );
	vdata_ptr = (char**) vdata->data_ptr;
	vconstant = vdata->rows * vdata->columns;
	for( vcnt = 0; vcnt < vconstant; vcnt += vdata->columns )
	{
	    sprintf( select_str, "%s\1%s\1%s\1%s\1", cdata_ptr[ccnt],
			vdata_ptr[vcnt], vdata_ptr[vcnt+1], vdata_ptr[vcnt+2]);

	    status = MEMwrite( *data_list, select_str );
	    if( status != MEM_S_SUCCESS )
	    {
		MEMclose( &cdata );
	 	MEMclose( &vdata );
	        MEMclose( syn_list );
		MEMclose( data_list );
		return( status );
	    }
	} /* end 'item' for-loop */
	MEMclose( &vdata );	

    } /* end 'catalog' for-loop */
    MEMclose( &cdata );

/*  If no files were flagged -- reset chosen buffer to NULL ( it now has
 *  formats without data if no files were found .
 */
    if( !isflag )
    {
	MEMclose( data_list );
	*data_list = NULL;
	_NFMdebug(( fname, "%s\n", "NO FLAGGED FILES FOUND " ));
 	ERRload_struct( UTI, UTI_I_NO_FLAGGED_FILES, NULL, NULL );
        return( UTI_I_NO_FLAGGED_FILES );
    }
/*  If there are flagged files, reset the error structure because
 *  there may be error messages loaded from catalogs that had no
 *  flagged files.
 */
    ERRreset_struct();

    return( NFM_S_SUCCESS );
}
