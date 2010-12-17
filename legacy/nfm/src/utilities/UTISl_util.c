#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMtypes.h"
#include "NFMSextern.h"
#include "UTIerrordef.h"
#include "ERR.h"
#include "DEBUG.h"
#include "NFMschema.h"

#define BUFFER_SIZE 1000

long NFMSlist_archive( in_list, out_list )
    MEMptr	in_list;
    MEMptr	*out_list;
{
    long	status;

    MEMptr	file_value  = NULL;

    static 	char *fname = "UTIlist_archive";

/*  Query and build pending flagged files list
 */
    status = UTIlist_flagged_files( NFM_ARCHIVE_LIST, &file_value );
    if( status != UTI_S_SUCCESS )
	return( status );

/*  Now build out_list buffer to send back to requester.
 */
    if( file_value )    
    {
	_UTIdebug(( fname, "%s\n", "** FLAGGED FILES **" ));
	ERRreset_struct(); /*  Get rid of any messages about catalogs
			    *  that did not have flagged files.
			    */
    }
    else
    {
	_UTIdebug(( fname, "%s\n", "** NO FLAGGED FILES **" ));
	status = MEMopen( &file_value, BUFFER_SIZE );
        if( status != MEM_S_SUCCESS )
        {
	    MEMclose( &file_value );
  	    return( status );
        }
    }
  
    *out_list = file_value;

    return( NFM_S_SUCCESS );
}

long NFMSlist_backup( in_list, out_list )
    MEMptr	in_list;
    MEMptr	*out_list;
{
    long	status;

    MEMptr	file_value  = NULL;

    static	char *fname = "UTIlist_backup";

/*  Query and build pending flagged files list
 */
    status = UTIlist_flagged_files( NFM_BACKUP_LIST, &file_value );
    if( status != UTI_S_SUCCESS )
	return( status );

/*  Now build out_list buffer to send back to requester.
 */
    if( file_value )    
    {
        _UTIdebug(( fname, "%s\n", "** FLAGGED FILES **" ));
        ERRreset_struct(); /*  Get rid of any messages about catalogs
                            *  that did not have flagged files.
                            */
    }
    else
    {
	_UTIdebug(( fname, "%s\n", "** NO FLAGGED FILES **" ));
	status = MEMopen( &file_value, BUFFER_SIZE );
        if( status != MEM_S_SUCCESS )
        {
	    MEMclose( &file_value );
  	    return( status );
        }
    }
  
    *out_list = file_value;

    return( NFM_S_SUCCESS );
}

long NFMSlist_restore( in_list, out_list )
    MEMptr	in_list;
    MEMptr	*out_list;
{
    long	status;

    MEMptr	file_value  = NULL;

    static	char *fname = "UTIlist_restore";

/*  Query and build pending flagged files list
 */
    status = UTIlist_flagged_files( NFM_RESTORE_LIST, &file_value );
    if( status != UTI_S_SUCCESS )
	return( status );

/*  Now build out_list buffer to send back to requester.
 */
    if( file_value )    
    {
        _UTIdebug(( fname, "%s\n", "** FLAGGED FILES **" ));
        ERRreset_struct(); /*  Get rid of any messages about catalogs
                            *  that did not have flagged files.
                            */
    }
    else
    {
	_UTIdebug(( fname, "%s\n", "** NO file_value **" ));
	status = MEMopen( &file_value, BUFFER_SIZE );
        if( status != MEM_S_SUCCESS )
        {
	    MEMclose( &file_value );
  	    return( status );
        }
    }
  
    *out_list = file_value;

    return( NFM_S_SUCCESS );
}

long NFMSlist_delete( in_list, out_list )
    MEMptr	in_list;
    MEMptr	*out_list;
{
    long	status;

    MEMptr	file_value  = NULL;

    static	char *fname = "UTIlist_delete";

/*  Query and build pending flagged files list
 */
    status = UTIlist_flagged_files( NFM_DELETE_LIST, &file_value );
    if( status != UTI_S_SUCCESS )
	return( status );

/*  Now build out_list buffer to send back to requester.
 */
    if( file_value )    
    {
        _UTIdebug(( fname, "%s\n", "** FLAGGED FILES **" ));
        ERRreset_struct(); /*  Get rid of any messages about catalogs
                            *  that did not have flagged files.
                            */
    }
    else
    {
	_UTIdebug(( fname, "%s\n", "** NO FLAGGED FILES **" ));
	status = MEMopen( &file_value, BUFFER_SIZE );
        if( status != MEM_S_SUCCESS )
        {
	    MEMclose( &file_value );
  	    return( status );
        }
    }
  
    *out_list = file_value;

    return( NFM_S_SUCCESS );
}

/*  Query for flagged files -- Used in Displays 
 */
UTIlist_flagged_files( utility, file_value )
    int		utility;
    MEMptr	*file_value;
{
    int		cconstant, ccnt, ccolumns;
    int		vconstant, vcnt, vcolumns;    
    int		isflag;
    int		tot_data;
    int		i;

    long	status;

    char	UTI_PENDING_FLAGS[4][3];
    char	uti_string[1024];

    char	**cdata_ptr;
    char	**vdata_ptr;

    MEMptr	chosen= NULL;	/* buffer of chosen file information */
    MEMptr	cdata = NULL;	/* catalog data buffer */
    MEMptr	vdata = NULL; 	/* version data buffer */

    static 	char *fname = "UTIlist_flagged_files";

/*  Set up pending flags depending on 'utility'
 */
    switch( utility )
    {
	case  NFM_ARCHIVE_LIST :
	    strcpy( UTI_PENDING_FLAGS[0], "IA" );
	    strcpy( UTI_PENDING_FLAGS[1], "MA" );
	    strcpy( UTI_PENDING_FLAGS[2], "SA" );
	    strcpy( UTI_PENDING_FLAGS[3], "PA" );
	    break;
	
	case  NFM_BACKUP_LIST :
  	    strcpy( UTI_PENDING_FLAGS[0], "IB" );
	    strcpy( UTI_PENDING_FLAGS[1], "MB" );
	    strcpy( UTI_PENDING_FLAGS[2], "SB" );
	    strcpy( UTI_PENDING_FLAGS[3], "PB" );
	    break;

	case  NFM_RESTORE_LIST :
	    strcpy( UTI_PENDING_FLAGS[0], "IR" );
	    strcpy( UTI_PENDING_FLAGS[1], "MR" );
	    strcpy( UTI_PENDING_FLAGS[2], "SR" );
	    strcpy( UTI_PENDING_FLAGS[3], "PR" );
	    break;

	default :
	    break;
    }

    isflag     = 0;

    strcpy( uti_string, "SELECT n_catalogname,n_catalogno FROM nfmcatalogs");
    status = SQLquery( uti_string, &cdata, BUFFER_SIZE );
    if( status != SQL_S_SUCCESS  )
    {
	ERRload_struct( UTI, UTI_E_QUERYCATALOGS, NULL, NULL );
	return( UTI_E_QUERYCATALOGS );
    }
    
    MEMbuild_array( cdata );
    cdata_ptr = (char**) cdata->data_ptr;
    cconstant = cdata->columns * cdata->rows;
    ccolumns  = cdata->columns;

/*  Start buffer to send back to requester 
 */
    status = MEMopen( &chosen, BUFFER_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &chosen );
	MEMclose( &cdata );
        ERRload_struct( NFM, NFM_E_MEM, "%s%s", fname, "MEMopen");
        _UTIdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        return (NFM_E_MEM);
    }

    sprintf( uti_string, "char(%d)", NFM_CATALOGNAME );
    status = MEMwrite_format( chosen, "Catalog Name", uti_string );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &chosen );
	MEMclose( &cdata );
        ERRload_struct( NFM, NFM_E_MEM, "%s%s", fname, "MEMwrite_format" );
        _UTIdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (NFM_E_MEM);
    }

    sprintf( uti_string, "char(%d)", NFM_ITEMNAME );
    status = MEMwrite_format( chosen, "Item Name", uti_string );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &chosen );
	MEMclose( &cdata );
        ERRload_struct( NFM, NFM_E_MEM, "%s%s", fname, "MEMwrite_format");
        _UTIdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (NFM_E_MEM);
    }

    sprintf( uti_string, "char(%d)", NFM_ITEMREV );
    status = MEMwrite_format( chosen, "Revision", uti_string );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &chosen );
	MEMclose( &cdata );
        ERRload_struct( NFM, NFM_E_MEM, "%s%s", fname, "MEMwrite_format");
        _UTIdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (NFM_E_MEM);
     }
    /*  Loop through all catalogs searching for flagged files 
     */
    for( ccnt = 0; ccnt < cconstant; ccnt += ccolumns )
    {
	vdata = NULL;
	_UTIdebug(( fname, "Query catalog <%s>\n", cdata_ptr[ccnt] ));

	sprintf( uti_string, "SELECT n_itemname,n_itemrev FROM %s WHERE n_pendingflag IN ( '%s','%s','%s','%s')",
	 cdata_ptr[ccnt], UTI_PENDING_FLAGS[0], UTI_PENDING_FLAGS[1], 
	 UTI_PENDING_FLAGS[2], UTI_PENDING_FLAGS[3]);

	status = SQLquery( uti_string, &vdata, BUFFER_SIZE );
	if( status != SQL_S_SUCCESS )
	{
	    MEMclose( &vdata );
	    _UTIdebug(( fname, "NO flags for catalog <%s>\n",cdata_ptr[ccnt]));
	    ERRload_struct( UTI, UTI_E_NO_FILES_FLAGGED, "%s", 
			     cdata_ptr[ccnt]);
	    continue;	
	}
	
	_UTIdebug(( fname, "%s\n", "Flagged File Found" ) );
 	isflag     = 1;
	MEMbuild_array( vdata );
	vdata_ptr = (char**) vdata->data_ptr;
	vconstant = vdata->rows * vdata->columns;
	vcolumns  = vdata->columns;
   
	for( vcnt=0; vcnt<vconstant; vcnt += vdata->columns )
	{
            strcpy( uti_string, cdata_ptr[ccnt] );   /* catalog name */
            strcat( uti_string, "\1" );
            strcat( uti_string, vdata_ptr[vcnt] );      /* item_name */
            strcat( uti_string, "\1" );
            strcat( uti_string, vdata_ptr[vcnt+1] );      /* item_rev */
            strcat( uti_string, "\1" );

            status = MEMwrite( chosen, uti_string );
            if( status != MEM_S_SUCCESS )
            {
       	        MEMclose( &cdata );
                MEMclose( &vdata );
  	        MEMclose( &chosen );
 	        ERRload_struct( NFM, NFM_E_MEM, "%s%s", fname, "MEMwrite");
	        _UTIdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
	        return (NFM_E_MEM);
   	    }
	}
	MEMclose( &vdata );	
    } /* end 'catalog' for-loop */
    MEMclose( &cdata );

/*  If no files were flagged -- reset chosen buffer to NULL ( it now has
 *  formats without data if no files were found .
 */
    if( !isflag )
    {
	MEMclose( &chosen );
	chosen = NULL;
	_UTIdebug(( fname, "%s\n", "NO FLAGGED FILES FOUND " ));
 	ERRload_struct( UTI, UTI_I_NO_FLAGGED_FILES, NULL, NULL );
        return( UTI_I_NO_FLAGGED_FILES );
    }

    *file_value = chosen;

    return( UTI_S_SUCCESS );
}
