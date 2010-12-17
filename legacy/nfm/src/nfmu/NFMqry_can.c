#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "NFMerrordef.h"
#include "ERR.h"

/*
 Doc: NFMquery_cancel_*

 Abstract:
     These functions query for files that may be unflagged.

 History:
     Jill McCutcheon  November 14, 1990 - Creation

 */

long NFMquery_cancel_archive ( user_id, catalog, files )
    long	user_id;
    char 	*catalog;
    MEMptr	*files;
{
    int		fconstant, fcnt, fcolumns;
    int		vconstant, vcnt, vcolumns;    
    int		is_valid;
    int		tot_data;
    int		i;

    long	status;
    char        s[200];

    char	a_itemnum[21];
    char	a_fileversion[21];
    char	a_cifilesize[21];
    char	a_pendingflag[21];
    char	a_cofilename[21];

    char	a_itemname[21];
    char	a_itemrev[21];
    char	a_itemno[21];

    char	**fdata_ptr;
    char	**vdata_ptr;
    char	**data;

    MEMptr	valid= NULL;	/* buffer of valid file information */
    MEMptr	fdata = NULL; 	/* file data buffer */
    MEMptr	vdata = NULL; 	/* version data buffer */
    MEMptr	buffer= NULL;

    _NFM_str( "%s", "Enter NFMquery_cancel_archive : " );

/*  Start buffer to send back to requester 
 */
    status = MEMopen( &valid, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &valid );
	_NFM_num( "NFMquery_cancel_archive : MEMopen : <0x%.8x>", status );
	return( status );
    }

    /*  Map attribute names for "catalog" */
		
    sprintf( s, "SELECT n_name, n_name, n_synonym, n_datatype FROM nfmattributes WHERE n_tableno IN ( SELECT n_tableno FROM nfmtables where n_tablename='%s' ) ",catalog );
    if(( status = SQLquery( s, &buffer, MEM_SIZE )) != SQL_S_SUCCESS )
    {
	_NFM_num ("NFMquery_cancel_archive: SQLquery = <0x%.8x>", status);
        MEMclose (&buffer);
	ERRload_struct( NFM, NFM_E_MAP_ATTRIBUTE_NAMES, NULL, NULL );
        return( NFM_E_MAP_ATTRIBUTE_NAMES );
    }
    MEMbuild_array (buffer);

    data = (char **) buffer->data_ptr;
    tot_data = (buffer->rows)*(buffer->columns);
    for( i=0; i<tot_data; i+=buffer->columns )
    {
        if( strcmp( data[i], "n_itemno" ) == 0 )
            strcpy( a_itemno, data[i+1] );
        else if( strcmp( data[i], "n_itemname" ) == 0 )
	{
	    strcpy( a_itemname, data[i+1] );

	    /* Put synonym name and datatype in buffer title */
	    status = MEMwrite_format( valid, data[i+2], data[i+3] );
	    if( status != MEM_S_SUCCESS )
	    {
		MEMclose( &valid );
		_NFM_num("NFMquery_cancel_archive:MEMwrite_format : <0x%.8x>",
			   status );
		return( status );
	    }
	}
	else if( strcmp( data[i], "n_itemrev" ) == 0 )
	{
 	    strcpy( a_itemrev, data[i+1] );

	    /* Put synonym name and datatype in buffer title */
	    status = MEMwrite_format( valid, data[i+2], data[i+3] );
	    if( status != MEM_S_SUCCESS )
	    {
		MEMclose( &valid );
		_NFM_num("NFMquery_cancel_archive:MEMwrite_format : <0x%.8x>",
			   status );
		return( status );
	    }
	}
    }
    MEMclose( &buffer );

    /*  Map attribute names for "f_catalog" */
		
    sprintf( s, "SELECT n_name, n_name, n_synonym, n_datatype FROM nfmattributes WHERE n_tableno IN ( SELECT n_tableno FROM nfmtables where n_tablename='f_%s' ) ", catalog );
    if(( status = SQLquery( s, &buffer, MEM_SIZE )) != SQL_S_SUCCESS )
    {
        _NFM_num ("NFMquery_cancel_archive: SQLquery = <0x%.8x>", status);
        MEMclose (&buffer);
        ERRload_struct( NFM, NFM_E_MAP_ATTRIBUTE_NAMES, NULL, NULL );
        return( NFM_E_MAP_ATTRIBUTE_NAMES );
    }
    MEMbuild_array (buffer);

    data = (char **) buffer->data_ptr;
    tot_data = (buffer->rows)*(buffer->columns);
    for( i=0; i<tot_data; i+=buffer->columns )
    {
        if( strcmp( data[i], "n_itemnum" ) == 0 )
            strcpy( a_itemnum, data[i+1] );
	else if( strcmp( data[i], "n_fileversion" ) == 0 )
	{
 	    strcpy( a_fileversion, data[i+1] );

	    /* Put synonym name and datatype in buffer title */
	    status = MEMwrite_format( valid, data[i+2], data[i+3] );
	    if( status != MEM_S_SUCCESS )
	    {
		MEMclose( &valid );
		_NFM_num("NFMquery_cancel_archive:MEMwrite_format : <0x%.8x>",
			   status );
		return( status );
	    }
	}
	else if( strcmp( data[i], "n_cofilename" ) == 0 )
	{
 	    strcpy( a_cofilename, data[i+1] );

	    /* Put synonym name and datatype in buffer title */
	    status = MEMwrite_format( valid, data[i+2], data[i+3] );
	    if( status != MEM_S_SUCCESS )
	    {
		MEMclose( &valid );
		_NFM_num("NFMquery_cancel_archive:MEMwrite_format : <0x%.8x>",
			   status );
		return( status );
	    }
	}
	else if( strcmp( data[i], "n_cifilesize" ) == 0 )
 	    strcpy( a_cifilesize, data[i+1] );
	else if( strcmp( data[i], "n_pendingflag" ) == 0 )
	    strcpy( a_pendingflag, data[i+1] );
    }
    MEMclose( &buffer );

    sprintf( s, "SELECT %s,%s,%s FROM f_%s WHERE %s > 0 AND %s = 'IA'",
		 a_itemnum, a_fileversion, a_cofilename,
		 catalog,a_cifilesize,a_pendingflag);
    status = SQLquery( s, &vdata, MEM_SIZE );
    if( status != SQL_S_SUCCESS)
    {
        is_valid = 0;
	MEMclose( &vdata );
        _NFM_str( "NFMquery_cancel_archive : NO files for catalog:<%s>", 
 	       catalog );
	ERRload_struct( NFM, NFM_E_NO_FILES_TO_CANCEL, "%s", catalog );
    }
    else
    {
        is_valid = 1;
        MEMbuild_array( vdata );
        vdata_ptr = (char**) vdata->data_ptr;
        vconstant = vdata->rows * vdata->columns;
        vcolumns  = vdata->columns;

        /*  Map this version back to item in catalog table
         */
        for( vcnt = 0; vcnt < vconstant; vcnt += vcolumns )
        {
            fdata  = NULL;
	    sprintf( s, "SELECT %s,%s FROM %s WHERE %s = %s", 
 	                 a_itemname, a_itemrev, catalog, 
			 a_itemno,vdata_ptr[vcnt]);
            status = SQLquery( s, &fdata, MEM_SIZE );
	    if( status != SQL_S_SUCCESS )
            {
  	        MEMclose( &fdata );	
	 	continue;
	    }
            MEMbuild_array( fdata );
            fdata_ptr = (char**) fdata->data_ptr;
            /*  We have all information now. Build return buffer.
             */
            strcpy( s, fdata_ptr[0] );      /* item_name */
	    strcat( s, "\1" );
            strcat( s, fdata_ptr[1] );      /* item_rev */
	    strcat( s, "\1" );
            strcat( s, vdata_ptr[vcnt+1] ); /* item_ver */
            strcat( s, "\1" );
            strcat( s, vdata_ptr[vcnt+2] ); /* cofilename */
            strcat( s, "\1" );

 	    status = MEMwrite( valid, s );
	    if( status != MEM_S_SUCCESS )
	    {
  		MEMclose( &fdata );
	   	MEMclose( &vdata );
		MEMclose( &valid );
		_NFM_num( "NFMquery_cancel_archive : MEMwrite : <0x%.8x>" ,
				 status );
    	        return( status );
	    }
            MEMclose( &fdata );

        } /* end 'version' for-loop */
        MEMclose( &vdata );	
    }
/*  If no valid files were found -- reset valid buffer to NULL ( it now has
 *  formats without data if no files were found .
 */
    if( !is_valid )
    {
	ERRload_struct( NFM, NFM_E_NO_FILES_FLAGGED, NULL, NULL );
	_NFM_str( "%s", "NFMquery_cancel_archive : NO VALID FILES FOUND" );
    }

    status = MEMsplit_copy_buffer( valid, files, 0 );
    if( status != MEM_S_SUCCESS )
    {
        _NFM_num ("NFMquery_cancel_archive : MEMsplit = <0x%.8x>", status);
        MEMclose( &valid );
        return( status );
    }

    _NFM_str( "%s", "Exit NFMquery_cancel_archive : " );
    return( NFM_S_SUCCESS );
}


/*  This routine is to query for files that can validly be backed up
 */
long NFMquery_cancel_backup ( user_id, catalog, files )
    long	user_id;
    char	*catalog;
    MEMptr	*files;
{
    int		fconstant, fcnt, fcolumns;
    int		vconstant, vcnt, vcolumns;    
    int		is_valid;
    int		tot_data;
    int		i;

    long	status;
    char        s[200];

    char	a_itemnum[21];
    char	a_fileversion[21];
    char	a_cifilesize[21];
    char	a_pendingflag[21];
    char	a_cofilename[21];

    char	a_itemname[21];
    char	a_itemrev[21];
    char	a_itemno[21];

    char	**fdata_ptr;
    char	**vdata_ptr;
    char	**data;

    MEMptr	valid= NULL;	/* buffer of valid file information */
    MEMptr	fdata = NULL; 	/* file data buffer */
    MEMptr	vdata = NULL; 	/* version data buffer */
    MEMptr	buffer= NULL;

    _NFM_str( "%s", "Enter NFMquery_cancel_backup : " );

/*  Start buffer to send back to requester 
 */
    status = MEMopen( &valid, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &valid );
	_NFM_num( "NFMquery_cancel_backup : MEMopen : <0x%.8x>", status );
	return( status );
    }

    /*  Map attribute names for "catalog" */
		
    sprintf( s, "SELECT n_name, n_name, n_synonym, n_datatype FROM nfmattributes WHERE n_tableno IN ( SELECT n_tableno FROM nfmtables where n_tablename='%s' ) ", catalog );
    if(( status = SQLquery( s, &buffer, MEM_SIZE )) != SQL_S_SUCCESS)
    {
        _NFM_num ("NFMquery_cancel_backup: SQLquery = <0x%.8x>", status);
        MEMclose (&buffer);
        ERRload_struct( NFM, NFM_E_MAP_ATTRIBUTE_NAMES, NULL, NULL );
        return( NFM_E_MAP_ATTRIBUTE_NAMES );
    }
    MEMbuild_array (buffer);

    data = (char **) buffer->data_ptr;
    tot_data = (buffer->rows)*(buffer->columns);
    for( i=0; i<tot_data; i+=buffer->columns )
    {
        if( strcmp( data[i], "n_itemno" ) == 0 )
            strcpy( a_itemno, data[i+1] );
        else if( strcmp( data[i], "n_itemname" ) == 0 )
	{
            strcpy( a_itemname, data[i+1] );
	
	    /* Put synonym name and datatype in return buffer */
            status = MEMwrite_format( valid, data[i+2], data[i+3] );
   	    if( status != MEM_S_SUCCESS )
	    {
		MEMclose( &valid );
		_NFM_num( "NFMquery_cancel_backup : MEMwrite_format : <0x%.8x>",
			    status );
		return( status );
	    }
	}
        else if( strcmp( data[i], "n_itemrev" ) == 0 )
	{
            strcpy( a_itemrev, data[i+1] );

	    /* Put synonym name and datatype in return buffer */
   	    status = MEMwrite_format( valid, data[i+2], data[i+3] );
	    if( status != MEM_S_SUCCESS )
	    {
		MEMclose( &valid );
		_NFM_num( "NFMquery_cancel_backup : MEMwrite_format : <0x%.8x>",
			    status );
		return( status );
	    }
	}
    }
    MEMclose( &buffer );

    /*  Map attribute names for "f_catalog" */
		
    sprintf( s, "SELECT n_name, n_name,n_synonym, n_datatype FROM nfmattributes WHERE n_tableno IN ( SELECT n_tableno FROM nfmtables where n_tablename='f_%s') ", catalog );
    if(( status = SQLquery( s, &buffer, MEM_SIZE )) != SQL_S_SUCCESS )
    {
        _NFM_num ("NFMquery_cancel_backup: SQLquery = <0x%.8x>", status);
        MEMclose (&buffer);
        ERRload_struct( NFM, NFM_E_MAP_ATTRIBUTE_NAMES, NULL, NULL );
        return( NFM_E_MAP_ATTRIBUTE_NAMES );
    }
    MEMbuild_array (buffer);

    data = (char **) buffer->data_ptr;
    tot_data = (buffer->rows)*(buffer->columns);
    for( i=0; i<tot_data; i+=buffer->columns )
    {
        if( strcmp( data[i], "n_itemnum" ) == 0 )
            strcpy( a_itemnum, data[i+1] );
        else if( strcmp( data[i], "n_fileversion" ) == 0 )
	{
            strcpy( a_fileversion, data[i+1] );

	    /* Put synonym name and datatype in return buffer */
	    status = MEMwrite_format( valid, data[i+2], data[i+3] );
	    if( status != MEM_S_SUCCESS )
	    {
		MEMclose( &valid );
		_NFM_num("NFMquery_cancel_backup : MEMwrite_format : <0x%.8x>",
			    status );
		return( status );
	    }
	}
        else if( strcmp( data[i], "n_cofilename" ) == 0 )
	{
            strcpy( a_cofilename, data[i+1] );

	    /* Put synonym name and datatype in return buffer */
	    status = MEMwrite_format( valid, data[i+2], data[i+3] );
	    if( status != MEM_S_SUCCESS )
	    {
		MEMclose( &valid );
		_NFM_num("NFMquery_cancel_backup : MEMwrite_format : <0x%.8x>",
			    status );
		return( status );
	    }
	}
        else if( strcmp( data[i], "n_cifilesize" ) == 0 )
            strcpy( a_cifilesize, data[i+1] );
	else if( strcmp( data[i], "n_pendingflag" ) == 0 )
  	    strcpy( a_pendingflag, data[i+1] );
    }
    MEMclose( &buffer );

    sprintf( s, "SELECT %s,%s,%s FROM f_%s WHERE %s = 'IB' AND %s > 0",
 	     a_itemnum, a_fileversion, a_cofilename,
	     catalog, a_pendingflag, a_cifilesize );
    status = SQLquery( s, &vdata, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
	is_valid = 0;
        MEMclose( &vdata );
        _NFM_str("NFMquery_cancel_backup:No files for catalog : <%s>",catalog);
	ERRload_struct( NFM, NFM_E_NO_FILES_TO_CANCEL, "%s", catalog );
    }
    else
    {
        _NFM_str( "%s", "NFMquery_cancel_backup : Valid File Found :"  );
        is_valid = 1;
        MEMbuild_array( vdata );
        vdata_ptr = (char**) vdata->data_ptr;
        vconstant = vdata->rows * vdata->columns;
	vcolumns  = vdata->columns;

	/*  Map this version back to item in catalog table
	 */
	for( vcnt = 0; vcnt < vconstant; vcnt += vcolumns )
	{
	    fdata  = NULL;
	    sprintf( s, "SELECT %s,%s FROM %s WHERE %s = %s", 
	     a_itemname, a_itemrev, catalog, a_itemno,vdata_ptr[vcnt]);
	    status = SQLquery( s, &fdata, MEM_SIZE );
	    if( status != SQL_S_SUCCESS )
	    {
		MEMclose( &fdata );	
		continue;
	    }
	    MEMbuild_array( fdata );
	    fdata_ptr = (char**) fdata->data_ptr;
	    /*  We have all information now. Build return buffer.
	     */
	    strcpy( s, fdata_ptr[0] );      /* item_name */
	    strcat( s, "\1" );
	    strcat( s, fdata_ptr[1] );      /* item_rev */
	    strcat( s, "\1" );
	    strcat( s, vdata_ptr[vcnt+1] ); /* item_ver */
	    strcat( s, "\1" );
	    strcat( s, vdata_ptr[vcnt+2] ); /* cofilename */
	    strcat( s, "\1" );

	    status = MEMwrite( valid, s );
	    if( status != MEM_S_SUCCESS )
	    {
		MEMclose( &fdata );
	 	MEMclose( &vdata );
		MEMclose( &valid );
		_NFM_num("NFMquery_cancel_backup : MEMwrite : <0x%.8x>" , status );
		return( status );
	    }

 	    MEMclose( &fdata );

	} /* end 'version' for-loop */
	MEMclose( &vdata );	

    } /* end 'is_valid' */  

    if( !is_valid )
    {
	ERRload_struct( NFM, NFM_E_NO_FILES_FOUND, NULL , NULL );
	_NFM_str( "%s", "NFMquery_cancel_backup : NO VALID FILES FOUND " );
    }

    status = MEMsplit_copy_buffer( valid, files, 0 );
    if( status != MEM_S_SUCCESS )
    {
        _NFM_num ("NFMquery_cancel_backup : MEMsplit = <0x%.8x>", status);
        MEMclose( &valid );
        return( status );
    }

    _NFM_str( "%s", "Exit NFMquery_cancel_backup : " );
    return( NFM_S_SUCCESS );
}

/*  This routine is to query for files that can validly be restored
 */
long NFMquery_cancel_restore ( user_id, catalog, files )
    long	user_id;
    char	*catalog;
    MEMptr	*files;
{
    int		fconstant, fcnt, fcolumns;
    int		vconstant, vcnt, vcolumns;    
    int		is_valid;
    int		tot_data;
    int		i;

    long	status;
    char        s[200];

    char	a_itemnum[21];
    char	a_fileversion[21];
    char	a_cifilesize[21];
    char	a_pendingflag[21];
    char	a_cofilename[21];

    char	a_itemname[21];
    char	a_itemrev[21];
    char	a_itemno[21];
    char 	a_archivestate[21];

    char	**fdata_ptr;
    char	**vdata_ptr;
    char	**data;

    MEMptr	valid= NULL;	/* buffer of valid file information */
    MEMptr	fdata = NULL; 	/* file data buffer */
    MEMptr	vdata = NULL; 	/* version data buffer */
    MEMptr	buffer= NULL;

    _NFM_str( "%s", "Enter NFMquery_cancel_restore : " );

/*  Start buffer to send back to requester 
 */
    status = MEMopen( &valid, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &valid );
	_NFM_num( "NFMquery_cancel_restore : MEMopen : <0x%.8x>", status );
	return( status );
    }
    /*  Map attribute names for "catalog" */
		
    sprintf( s, "SELECT n_name, n_name, n_synonym, n_datatype FROM nfmattributes WHERE n_tableno IN ( SELECT n_tableno FROM nfmtables where n_tablename='%s' ) ",catalog);
    if(( status = SQLquery( s, &buffer, MEM_SIZE )) != SQL_S_SUCCESS )
    {
        _NFM_num ("NFMquery_cancel_restore: SQLquery = <0x%.8x>", status);
        MEMclose (&buffer);
        ERRload_struct( NFM, NFM_E_MAP_ATTRIBUTE_NAMES, NULL, NULL );
        return( NFM_E_MAP_ATTRIBUTE_NAMES );
    }
    MEMbuild_array (buffer);

    data = (char **) buffer->data_ptr;
    tot_data = (buffer->rows)*(buffer->columns);
    for( i=0; i<tot_data; i+=buffer->columns )
    {
        if( strcmp( data[i], "n_itemno" ) == 0 )
            strcpy( a_itemno, data[i+1] );
        else if( strcmp( data[i], "n_itemname" ) == 0 )
	{
	    strcpy( a_itemname, data[i+1] );
	    status = MEMwrite_format( valid, data[i+2], data[i+3] );
	    if( status != MEM_S_SUCCESS )
	    {
		MEMclose( &valid );
		_NFM_num("NFMquery_cancel_restore : MEMwrite_format :<0x%.8x>",
			    status );
		return( status );
	    }
	}
	else if( strcmp( data[i], "n_itemrev" ) == 0 )
	{
 	    strcpy( a_itemrev, data[i+1] );
  	    status = MEMwrite_format( valid, data[i+2], data[i+3] );
	    if( status != MEM_S_SUCCESS )
	    {
		MEMclose( &valid );
		_NFM_num("NFMquery_cancel_restore :MEMwrite_format : <0x%.8x>",
			    status );
		return( status );
	    }
	}
	else if( strcmp( data[i], "n_archivestate" ) == 0 )
 	    strcpy( a_archivestate, data[i+1] );
    }
    MEMclose( &buffer );

    /*  Map attribute names for "f_catalog" */
		
    sprintf( s, "SELECT n_name, n_name, n_synonym, n_datatype FROM nfmattributes WHERE n_tableno IN ( SELECT n_tableno FROM nfmtables where n_tablename='f_%s' ) ",catalog);
    if(( status = SQLquery( s, &buffer, MEM_SIZE )) != SQL_S_SUCCESS )
    {
        _NFM_num ("NFMquery_cancel_restore: SQLquery = <0x%.8x>", status);
        MEMclose (&buffer);
        ERRload_struct( NFM, NFM_E_MAP_ATTRIBUTE_NAMES, NULL, NULL );
        return( NFM_E_MAP_ATTRIBUTE_NAMES );
    }
    MEMbuild_array (buffer);

    data = (char **) buffer->data_ptr;
    tot_data = (buffer->rows)*(buffer->columns);
    for( i=0; i<tot_data; i+=buffer->columns )
    {
        if( strcmp( data[i], "n_itemnum" ) == 0 )
 	    strcpy( a_itemnum, data[i+1] );
        else if( strcmp( data[i], "n_fileversion" ) == 0 )
	{
 	    strcpy( a_fileversion, data[i+1] );
	    status = MEMwrite_format( valid, data[i+2], data[i+3] );
	    if( status != MEM_S_SUCCESS )
	    {
		MEMclose( &valid );
		_NFM_num("NFMquery_cancel_restore :MEMwrite_format : <0x%.8x>",
			    status );
		return( status );
	    }
	}
        else if( strcmp( data[i], "n_cofilename" ) == 0 )
	{
 	    strcpy( a_cofilename, data[i+1] );
	    status = MEMwrite_format( valid, data[i+2], data[i+3] );
	    if( status != MEM_S_SUCCESS )
	    {
		MEMclose( &valid );
		_NFM_num("NFMquery_cancel_restore: MEMwrite_format : <0x%.8x>",
			    status );
		return( status );
	    }
	}
	else if( strcmp( data[i], "n_cifilesize" ) == 0 )
            strcpy( a_cifilesize, data[i+1] );
	else if( strcmp( data[i], "n_pendingflag" ) == 0 )
	    strcpy( a_pendingflag, data[i+1] );
    }
    MEMclose( &buffer );

    sprintf( s,"SELECT %s,%s,%s FROM f_%s WHERE %s > 0 AND %s = 'IR'",
  	         a_itemnum, a_fileversion, a_cofilename,
		 catalog, a_cifilesize, a_pendingflag );
    status = SQLquery( s, &vdata, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
        MEMclose( &vdata );
  	_NFM_str( "NFMquery_cancel_restore:NO files for catalog <%s>", 
		    catalog );
        is_valid = 0;
	ERRload_struct( NFM, NFM_E_NO_FILES_TO_CANCEL, "%s", catalog );
    }
    else
    {
	_NFM_str("%s", "NFMquery_cancel_restore : Valid File Found :");
 	is_valid = 1;
	MEMbuild_array( vdata );
	vdata_ptr = (char**) vdata->data_ptr;
	vconstant = vdata->rows * vdata->columns;
	vcolumns  = vdata->columns;

	/*  Map this version back to item in catalog table
	 */
	for( vcnt = 0; vcnt < vconstant; vcnt += vcolumns )
	{
	    fdata  = NULL;
	    sprintf( s, "SELECT %s,%s,%s FROM %s WHERE %s = %s", 
	             a_itemname, a_itemrev, a_archivestate, catalog, 
	             a_itemno, vdata_ptr[vcnt] );
	    status = SQLquery( s, &fdata, MEM_SIZE );
	    if( status != SQL_S_SUCCESS )
	    {
		MEMclose( &fdata );	
		continue;
	    }
	    MEMbuild_array( fdata );
	    fdata_ptr = (char**) fdata->data_ptr;
	    /*  If the archivestate is not 'A' or 'B', we can't unflag.
** Taken out 2/22/1991 because if a file has been successfully restored
   at sometime in the past, the archive state gets cleared and then this
   check won't let you cancel the flagged file. ** 
	    if( strcmp( fdata_ptr[2], "A" ) &&
	        strcmp( fdata_ptr[2], "B" ) )
 	    {
		_NFM_str( "NFMquery_cancel_restore : Archive State <%s>",
			    fdata_ptr[2] );
		MEMclose( &fdata );
		continue;
	    }
	     */ 
	    /*  We have all information now. Build return buffer.
	     */
	    strcpy( s, fdata_ptr[0] );      /* item_name */
	    strcat( s, "\1" );
	    strcat( s, fdata_ptr[1] );      /* item_rev */
	    strcat( s, "\1" );
	    strcat( s, vdata_ptr[vcnt+1] ); /* item_ver */
	    strcat( s, "\1" );
	    strcat( s, vdata_ptr[vcnt+2] ); /* cofilename */
	    strcat( s, "\1" );

	    status = MEMwrite( valid, s );
	    if( status != MEM_S_SUCCESS )
	    {
		MEMclose( &fdata );
	 	MEMclose( &vdata );
		MEMclose( &valid );
		_NFM_num( "NFMquery_cancel_restore : MEMwrite : <0x%.8x>" ,
			    status );
		return( status );
	    }

 	    MEMclose( &fdata );

	} /* end 'version' for-loop */
	MEMclose( &vdata );	
    } /* end 'is_valid'  */

    if( !is_valid )
    {
	ERRload_struct( NFM, NFM_E_NO_FILES_FLAGGED, NULL, NULL );
	_NFM_str( "%s","NFMquery_cancel_restore : NO VALID FILES FOUND");
    }

    status = MEMsplit_copy_buffer( valid, files, 0 );
    if( status != MEM_S_SUCCESS )
    {
        _NFM_num ("NFMquery_cancel_restore : MEMsplit = <0x%.8x>", status);
        MEMclose( &valid );
        return( status );
    }

    _NFM_str( "%s", "Exit NFMquery_cancel_restore : " );

    return( NFM_S_SUCCESS );
}

/*  This routine is to query for files that can validly be deleted
 */
long NFMquery_cancel_delete ( user_id, catalog, files )
    long	user_id;
    char	*catalog;
    MEMptr	*files;
{
    int		fconstant, fcnt, fcolumns;
    int		vconstant, vcnt, vcolumns;    
    int		is_valid;
    int		tot_data;
    int		i;

    long	status;
    char        s[200];

    char	a_itemnum[21];
    char	a_fileversion[21];
    char	a_cifilesize[21];
    char	a_pendingflag[21];
    char	a_cofilename[21];

    char	a_itemname[21];
    char	a_itemrev[21];
    char	a_itemno[21];
    char	a_archivestate[21];
    char 	a_coout[21];

    char	**fdata_ptr;
    char	**vdata_ptr;
    char	**data;

    MEMptr	valid= NULL;	/* buffer of valid file information */
    MEMptr	fdata = NULL; 	/* file data buffer */
    MEMptr	vdata = NULL; 	/* version data buffer */
    MEMptr	buffer= NULL;

/*  Start buffer to send back to requester 
 */
    status = MEMopen( &valid, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &valid );
	_NFM_num( "NFMquery_cancel_delete : MEMopen : <0x%.8x>", status );
	return( status );
    }

    /*  Map attribute names for "catalog" */
		
    sprintf( s, "SELECT n_name, n_name, n_synonym, n_datatype FROM nfmattributes WHERE n_tableno IN ( SELECT n_tableno FROM nfmtables where n_tablename='%s' ) ",catalog );
    if(( status = SQLquery( s, &buffer, MEM_SIZE )) != SQL_S_SUCCESS )
    {
	_NFM_num ("NFMquery_cancel_delete: SQLquery = <0x%.8x>", status);
        MEMclose (&buffer);
        ERRload_struct( NFM, NFM_E_MAP_ATTRIBUTE_NAMES, NULL, NULL );
        return( NFM_E_MAP_ATTRIBUTE_NAMES );
    }
    MEMbuild_array (buffer);

    data = (char **) buffer->data_ptr;
    tot_data = (buffer->rows)*(buffer->columns);
    for( i=0; i<tot_data; i+=buffer->columns )
    {
        if( strcmp( data[i], "n_coout" ) == 0 )
            strcpy( a_coout, data[i+1] );
        else if( strcmp( data[i], "n_archivestate" ) == 0 )
            strcpy( a_archivestate, data[i+1] );
        else if( strcmp( data[i], "n_itemno" ) == 0 )
            strcpy( a_itemno, data[i+1] );
        else if( strcmp( data[i], "n_itemname" ) == 0 )
	{
	    strcpy( a_itemname, data[i+1] );
	    status = MEMwrite_format( valid, data[i+2], data[i+3] );
	    if( status != MEM_S_SUCCESS )
	    {
		MEMclose( &valid );
		_NFM_num( "NFMquery_cancel_delete : MEMwrite_format : <0x%.8x>",
			    status );
		return( status );
	    }
	}
        else if( strcmp( data[i], "n_itemrev" ) == 0 )
	{
            strcpy( a_itemrev, data[i+1] );
	    status = MEMwrite_format( valid, data[i+2], data[i+3] );
	    if( status != MEM_S_SUCCESS )
	    {
		MEMclose( &valid );
		_NFM_num("NFMquery_cancel_delete : MEMwrite_format : <0x%.8x>",
			    status );
		return( status );
	    }
	}
    }
    MEMclose( &buffer );

    /*  Map attribute names for "f_catalog" */
		
    sprintf( s, "SELECT n_name, n_name, n_synonym, n_datatype FROM nfmattributes WHERE n_tableno IN ( SELECT n_tableno FROM nfmtables where n_tablename='f_%s' ) ",catalog);
    if(( status = SQLquery( s, &buffer, MEM_SIZE )) != SQL_S_SUCCESS )
    {
        _NFM_num ("NFMquery_cancel_delete: SQLquery = <0x%.8x>", status);
        MEMclose (&buffer);
        ERRload_struct( NFM, NFM_E_MAP_ATTRIBUTE_NAMES, NULL, NULL );
        return( NFM_E_MAP_ATTRIBUTE_NAMES );
    }
    MEMbuild_array (buffer);

    data = (char **) buffer->data_ptr;
    tot_data = (buffer->rows)*(buffer->columns);
    for( i=0; i<tot_data; i+=buffer->columns )
    {
        if( strcmp( data[i], "n_itemnum" ) == 0 )
 	    strcpy( a_itemnum, data[i+1] );
	else if( strcmp( data[i], "n_fileversion" ) == 0 )
	{
            strcpy( a_fileversion, data[i+1] );
	    status = MEMwrite_format( valid, data[i+2], data[i+3] );
	    if( status != MEM_S_SUCCESS )
	    {
		MEMclose( &valid );
		_NFM_num("NFMquery_cancel_delete : MEMwrite_format : <0x%.8x>",
			    status );
		return( status );
	    }
	}
	else if( strcmp( data[i], "n_cofilename" ) == 0 )
	{
            strcpy( a_cofilename, data[i+1] );
	    status = MEMwrite_format( valid, data[i+2], data[i+3] );
	    if( status != MEM_S_SUCCESS )
	    {
		MEMclose( &valid );
		_NFM_num("NFMquery_cancel_delete : MEMwrite_format : <0x%.8x>",
			    status );
		return( status );
	    }
	}
	else if( strcmp( data[i], "n_cifilesize" ) == 0 )
            strcpy( a_cifilesize, data[i+1] );
	else if( strcmp( data[i], "n_pendingflag" ) == 0 )
	    strcpy( a_pendingflag, data[i+1] );
    }
    MEMclose( &buffer );

    sprintf( s, "SELECT %s,%s,%s FROM f_%s WHERE %s > 0 AND %s = 'ID'",
  	         a_itemnum,a_fileversion,a_cofilename,
		 catalog,a_cifilesize,a_pendingflag);
    status = SQLquery( s, &vdata, MEM_SIZE );
    if( status != SQL_S_SUCCESS)
    {
        MEMclose( &vdata );
        _NFM_str( "NFMquery_cancel_delete : No valid files in <%s>",
		    catalog );
	is_valid = 0;
	ERRload_struct( NFM, NFM_E_NO_FILES_TO_CANCEL, "%s", catalog );
    }
    else
    {	
	_NFM_str( "%s", "NFMquery_cancel_delete : Valid File Found :"  );
 	is_valid = 1;
	MEMbuild_array( vdata );
	vdata_ptr = (char**) vdata->data_ptr;
	vconstant = vdata->rows * vdata->columns;
	vcolumns  = vdata->columns;

	/*  Map this version back to item in catalog table
	 */
	for( vcnt = 0; vcnt < vconstant; vcnt += vcolumns )
	{
	    fdata  = NULL;
	    sprintf( s, "SELECT %s,%s,%s,%s FROM %s WHERE %s = %s", 
	     	     a_itemname, a_itemrev, a_archivestate, a_coout,
		     catalog,a_itemno, vdata_ptr[vcnt]);
	    status = SQLquery( s, &fdata, MEM_SIZE );
	    if( status != SQL_S_SUCCESS )
	    {
		MEMclose( &fdata );	
		continue;
	    }
	    MEMbuild_array( fdata );
	    fdata_ptr = (char**) fdata->data_ptr;
	    /*  The file must be checked in and the archivestate must
	     *  be blank.
	     */
	    if( (strcmp( fdata_ptr[2], "" )) || 
	        (strcmp( fdata_ptr[3], "I" ) ) )
	    {
		_NFM_str( "NFMquery_cancel_delete : Archive State <%s>",
			    fdata_ptr[2] );
		_NFM_str( "NFMquery_cancel_delete : Check Out State <%s>",
			    fdata_ptr[3] );
		MEMclose( &fdata );
		continue;
	    }

	    /*  We have all information now. Build return buffer.
	     */
	    strcpy( s, fdata_ptr[0] );      /* item_name */
	    strcat( s, "\1" );
	    strcat( s, fdata_ptr[1] );      /* item_rev */
	    strcat( s, "\1" );
	    strcat( s, vdata_ptr[vcnt+1] ); /* item_ver */
	    strcat( s, "\1" );
	    strcat( s, vdata_ptr[vcnt+2] ); /* cofilename */
	    strcat( s, "\1" );

            _NFM_str( "NFMquery_cancel_delete : Str <%s>", s );
	    status = MEMwrite( valid, s );
	    if( status != MEM_S_SUCCESS )
	    {
		MEMclose( &fdata );
	 	MEMclose( &vdata );
		MEMclose( &valid );
		_NFM_num( "NFMquery_cancel_delete : MEMwrite : <0x%.8x>" ,
			    status );
		return( status );
	    }

 	    MEMclose( &fdata );

	} /* end 'version' for-loop */
	MEMclose( &vdata );	
    } /* end 'is_valid' */

    if( !is_valid )
    {
	ERRload_struct( NFM, NFM_E_NO_FILES_FLAGGED, NULL, NULL );
	_NFM_str( "%s", "NFMquery_cancel_delete : NO VALID FILES FOUND " );
    }

    status = MEMsplit_copy_buffer( valid, files, 0 );
    if( status != MEM_S_SUCCESS )
    {
        _NFM_num ("NFMquery_cancel_delete : MEMsplit = <0x%.8x>", status);
        MEMclose( &valid );
        return( status );
    }

    _NFM_str( "%s", "Exit NFMquery_cancel_delete : " );
    return( NFM_S_SUCCESS );
}
