#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMflag.h"
#include "ERR.h"
#include "DEBUG.h"
#include "NFMstruct.h"

/*
 Doc: NFMquery_flag_*

 Abstract:
     These functions query for files that can be flagged.

 History:
     Jill McCutcheon  November 14, 1990 - Creation

 */

extern struct NFMglobal_st NFMglobal;

long NFMquery_flag_archive ( user_id, catalog, files )
    long	user_id;
    char 	*catalog;
    MEMptr	*files;
{
    char 	*fname="NFMquery_flag_archive";
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

    char	**fdata_ptr;
    char	**vdata_ptr;
    char	**data;

    MEMptr	valid= NULL;	/* buffer of valid file information */
    MEMptr	fdata = NULL; 	/* file data buffer */
    MEMptr	vdata = NULL; 	/* version data buffer */
    MEMptr	buffer= NULL;


    _NFMdebug((fname, "Enter: Userid <%d>, Catalog <%s>\n", user_id, catalog));
    is_valid = 0;

/*  Start buffer to send back to requester 
 */
    status = MEMopen( &valid, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &valid );
	_NFMdebug((fname, "MEMopen : <0x%.8x>\n", status ));
	return( status );
    }

    /*  Map attribute names for "catalog" */
		
    sprintf( s, "SELECT n_name, n_name, n_synonym, n_datatype FROM nfmattributes WHERE n_tableno IN ( SELECT n_tableno FROM nfmtables where n_tablename='%s' ) ",catalog );
    if(( status = SQLquery( s, &buffer, MEM_SIZE )) != SQL_S_SUCCESS )
    {
	_NFMdebug ((fname, "SQLquery = <0x%.8x>\n", status));
        MEMclose (&buffer);
        ERRload_struct( NFM, NFM_E_MAP_ATTRIBUTE_NAMES, NULL, NULL );
        return( status );
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
		_NFMdebug((fname,"MEMwrite_format : <0x%.8x>\n", status ));
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
		_NFMdebug((fname,"MEMwrite_format : <0x%.8x>\n", status ));
		return( status );
	    }
	}
	else if( strcmp( data[i], "n_archivestate" ) == 0 )
 	    strcpy( a_archivestate, data[i+1] );
    }
    MEMclose( &buffer );

    /*  Map attribute names for "f_catalog" */
		
    sprintf( s, "SELECT n_name, n_name, n_synonym, n_datatype FROM nfmattributes WHERE n_tableno IN ( SELECT n_tableno FROM nfmtables where n_tablename='f_%s' ) ", catalog );
    if(( status = SQLquery( s, &buffer, MEM_SIZE )) != SQL_S_SUCCESS)
    {
        _NFMdebug ((fname, "SQLquery = <0x%.8x>\n", status));
        MEMclose (&buffer);
        ERRload_struct( NFM, NFM_E_MAP_ATTRIBUTE_NAMES, NULL, NULL );
        return( status );
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
                _NFMdebug((fname,"MEMwrite_format : <0x%.8x>\n", status ));
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
		_NFMdebug((fname,"MEMwrite_format : <0x%.8x>\n", status ));
		return( status );
	    }
	}
	else if( strcmp( data[i], "n_cifilesize" ) == 0 )
 	    strcpy( a_cifilesize, data[i+1] );
	else if( strcmp( data[i], "n_pendingflag" ) == 0 )
	    strcpy( a_pendingflag, data[i+1] );
    }
    MEMclose( &buffer );

    sprintf( s, "SELECT %s,MAX(%s) FROM f_%s GROUP BY %s",
		 a_itemnum, a_fileversion, catalog, a_itemnum );
    status = SQLquery( s, &vdata, MEM_SIZE );
    if( status != SQL_S_SUCCESS)
    {
	MEMclose( &buffer );
	MEMclose( &vdata );
	return( status );
    }
    MEMbuild_array( vdata );
    vdata_ptr = (char**) vdata->data_ptr;
    vconstant = vdata->rows * vdata->columns;
    vcolumns  = vdata->columns;

    for( vcnt = 0; vcnt < vconstant; vcnt += vcolumns )
    {
	buffer = NULL;
        sprintf( s, 
		 "SELECT %s,%s FROM f_%s WHERE %s > 0 AND %s = %s AND %s = %s",
		 a_pendingflag, a_cofilename, catalog, a_cifilesize,
		 a_itemnum, vdata_ptr[vcnt], a_fileversion, vdata_ptr[vcnt+1]);
        status = SQLquery( s, &buffer, MEM_SIZE );
        if( status != SQL_S_SUCCESS)
        {
	    MEMclose( &buffer );
	    continue;
        }
        else
        {
            MEMbuild_array( buffer );
            data = (char**) buffer->data_ptr;

            /*  If the pendingflag is something other than '',
             *  we won't allow this to be flagged.
             */
            if( strcmp( data[0], "" ) )
            {
     	        _NFMdebug((fname, "Pending Flag <%s>\n", data[0] ));
		MEMclose( &buffer );
    	        continue;
	    }
            fdata  = NULL;
	    sprintf( s, "SELECT %s,%s,%s FROM %s WHERE %s = %s", 
 	                 a_itemname, a_itemrev, a_archivestate,
		 	 catalog, a_itemno, vdata_ptr[vcnt]);
            status = SQLquery( s, &fdata, MEM_SIZE );
	    if( status != SQL_S_SUCCESS )
            {
  	        MEMclose( &fdata );	
		MEMclose( &buffer );
	 	continue;
	    }

            MEMbuild_array( fdata );
            fdata_ptr = (char**) fdata->data_ptr;
	    /*  If archivestate is 'A', then this file is currently
	     *	archived. We will not let it be flagged again.
	     */
	    if( strcmp( fdata_ptr[2], "A" ) == 0 )
	    {
     	        _NFMdebug((fname, "Archive State <%s>\n", fdata_ptr[2] ));
		MEMclose( &fdata );
		MEMclose( &buffer );
		continue;
	    }
            _NFMdebug((fname, "%s\n", "Valid File Found " ));
	    is_valid = 1;
	 
            /*  We have all information now. Build return buffer.
             */
            strcpy( s, fdata_ptr[0] );      /* item_name */
	    strcat( s, "\1" );
            strcat( s, fdata_ptr[1] );      /* item_rev */
	    strcat( s, "\1" );
	    strcat( s, vdata_ptr[vcnt+1] ); /* item_version */
 	    strcat( s, "\1" );
            strcat( s, data[1] );           /* co_filename */
            strcat( s, "\1" );

 	    status = MEMwrite( valid, s );
	    if( status != MEM_S_SUCCESS )
	    {
  		MEMclose( &fdata );
	   	MEMclose( &vdata );
		MEMclose( &valid );
		_NFMdebug((fname, "MEMwrite : <0x%.8x>\n" , status ));
    	        return( status );
	    }
            MEMclose( &fdata );
	    MEMclose( &buffer );
        }
    }

/*  If no valid files were found -- reset valid buffer to NULL ( it now has
 *  formats without data if no files were found .
*/
    if( !is_valid )
    {
	ERRload_struct( NFM, NFM_E_NO_FILES_TO_FLAG, "%s", catalog );
	_NFMdebug((fname, "%s\n", "NO VALID FILES FOUND" ));
	return( NFM_E_NO_FILES_TO_FLAG);
    }

    status = MEMsplit_copy_buffer( valid, files, 0 );
    if( status != MEM_S_SUCCESS )
    {
        _NFMdebug ((fname, "MEMsplit = <0x%.8x>\n", status));
        MEMclose( &valid );
        return( status );
    }

    _NFMdebug((fname, "%s\n", "Exit" ));
    return( NFM_S_SUCCESS );
}


/*  This routine is to query for files that can validly be backed up
 */
long NFMquery_flag_backup ( user_id, catalog, files )
    long	user_id;
    char	*catalog;
    MEMptr	*files;
{
    char 	*fname = "NFMquery_flag_backup";
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

    char	**fdata_ptr;
    char	**vdata_ptr;
    char	**data;

    MEMptr	valid= NULL;	/* buffer of valid file information */
    MEMptr	fdata = NULL; 	/* file data buffer */
    MEMptr	vdata = NULL; 	/* version data buffer */
    MEMptr	buffer= NULL;

    _NFMdebug((fname, "Enter: Userid <%d>, Catalog <%s>\n", user_id, catalog));

    is_valid = 0;

/*  Start buffer to send back to requester 
 */
    status = MEMopen( &valid, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &valid );
	_NFMdebug((fname, "MEMopen : <0x%.8x>\n", status ));
	return( status );
    }

    /*  Map attribute names for "catalog" */
		
    sprintf( s, "SELECT n_name, n_name, n_synonym, n_datatype FROM nfmattributes WHERE n_tableno IN ( SELECT n_tableno FROM nfmtables where n_tablename='%s' ) ", catalog );
    if(( status = SQLquery( s, &buffer, MEM_SIZE )) != SQL_S_SUCCESS )
    {
        _NFMdebug ((fname, "SQLquery = <0x%.8x>\n", status));
        MEMclose (&buffer);
        ERRload_struct( NFM, NFM_E_MAP_ATTRIBUTE_NAMES, NULL, NULL );
        return( status );
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
		_NFMdebug((fname,"MEMwrite_format : <0x%.8x>\n", status ));
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
		_NFMdebug((fname,"MEMwrite_format : <0x%.8x>\n", status ));
		return( status );
	    }
	}
        else if( strcmp( data[i], "n_archivestate" ) == 0 )
            strcpy( a_archivestate, data[i+1] );
    }
    MEMclose( &buffer );

    /*  Map attribute names for "f_catalog" */
		
    sprintf( s, "SELECT n_name, n_name, n_synonym, n_datatype FROM nfmattributes WHERE n_tableno IN ( SELECT n_tableno FROM nfmtables where n_tablename='f_%s') ", catalog );
    if(( status = SQLquery( s, &buffer, MEM_SIZE )) != SQL_S_SUCCESS )
    {
        _NFMdebug ((fname, "SQLquery = <0x%.8x>\n", status));
        MEMclose (&buffer);
        ERRload_struct( NFM, NFM_E_MAP_ATTRIBUTE_NAMES, NULL, NULL );
        return( status );
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
                _NFMdebug((fname,"MEMwrite_format : <0x%.8x>\n", status ));
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
		_NFMdebug((fname,"MEMwrite_format : <0x%.8x>\n", status ));
		return( status );
	    }
	}
        else if( strcmp( data[i], "n_cifilesize" ) == 0 )
            strcpy( a_cifilesize, data[i+1] );
	else if( strcmp( data[i], "n_pendingflag" ) == 0 )
  	    strcpy( a_pendingflag, data[i+1] );
    }
    MEMclose( &buffer );

    sprintf( s, "SELECT %s,MAX(%s) FROM f_%s GROUP BY %s",
 	         a_itemnum,a_fileversion,catalog, a_itemnum );
    status = SQLquery( s, &vdata, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
	MEMclose( &buffer );
        MEMclose( &vdata );
	return( status );
    }
    MEMbuild_array( vdata );
    vdata_ptr = (char**) vdata->data_ptr;
    vconstant = vdata->rows * vdata->columns;
    vcolumns  = vdata->columns;

    for( vcnt = 0; vcnt < vconstant; vcnt += vcolumns )
    {
	buffer = NULL;
        sprintf( s, 
		"SELECT %s,%s FROM f_%s WHERE %s > 0 AND %s = %s AND %s = %s",
 	         a_pendingflag, a_cofilename, catalog, a_cifilesize,
		 a_itemnum, vdata_ptr[vcnt], a_fileversion, vdata_ptr[vcnt+1]);
        status = SQLquery( s, &buffer, MEM_SIZE );
        if( status != SQL_S_SUCCESS )
        {
	    MEMclose( &buffer );
	    continue;
        }
        else
        {
            MEMbuild_array( buffer );
            data = (char**) buffer->data_ptr;

            /*  If the pendingflag is something other than '',
             *  we won't allow this to be flagged.
             */
            if( strcmp( data[0], "" ) )
            {
                _NFMdebug((fname, " Pending Flag <%s>\n", data[0] ));
		MEMclose( &buffer );
                continue;
            }
	    fdata  = NULL;
	    sprintf( s, "SELECT %s,%s,%s FROM %s WHERE %s = %s", 
	     a_itemname, a_itemrev, a_archivestate,
	     catalog, a_itemno,vdata_ptr[vcnt]);
	    status = SQLquery( s, &fdata, MEM_SIZE );
	    if( status != SQL_S_SUCCESS)
	    {
		MEMclose( &fdata );	
		MEMclose( &buffer );
		continue;
	    }
	    MEMbuild_array( fdata );
	    fdata_ptr = (char**) fdata->data_ptr;

	    /*  If archivestate is 'A', then this file is currently
	     *	archived. We will not let it be flagged again.
	     */
	    if( strcmp( fdata_ptr[2], "A" ) == 0 ) 
	    {
     	        _NFMdebug((fname, "Archive State <%s>\n", fdata_ptr[2] ));
		MEMclose( &fdata );
		MEMclose( &buffer );
		continue;
	    }

	    /*  We have all information now. Build return buffer.
	     */
            _NFMdebug((fname, "%s\n", "Valid File Found :" ));
            is_valid = 1;

	    strcpy( s, fdata_ptr[0] );      /* item_name */
	    strcat( s, "\1" );
	    strcat( s, fdata_ptr[1] );      /* item_rev */
	    strcat( s, "\1" );
	    strcat( s, vdata_ptr[vcnt+1] ); /* item_version */
 	    strcat( s, "\1" );
	    strcat( s, data[1] );           /* co_filename */
	    strcat( s, "\1" );

	    status = MEMwrite( valid, s );
	    if( status != MEM_S_SUCCESS )
	    {
		MEMclose( &fdata );
	 	MEMclose( &vdata );
		MEMclose( &valid );
		MEMclose( &buffer );
		_NFMdebug((fname,"MEMwrite : <0x%.8x>\n" , status ));
		return( status );
	    }
	    MEMclose( &buffer );
 	    MEMclose( &fdata );
	} 
    }
    MEMclose( &vdata );	

    if( !is_valid )
    {
	ERRload_struct( NFM, NFM_E_NO_FILES_TO_FLAG, "%s", catalog );
	_NFMdebug((fname, "%s\n", "NO VALID FILES FOUND " ));
	return( NFM_E_NO_FILES_TO_FLAG );
    }

    status = MEMsplit_copy_buffer( valid, files, 0 );
    if( status != MEM_S_SUCCESS )
    {
        _NFMdebug ((fname, "MEMsplit = <0x%.8x>\n", status));
        MEMclose( &valid );
        return( status );
    }

    _NFMdebug((fname, "%s\n", "Exit "));
    return( NFM_S_SUCCESS );
}

/*  This routine is to query for files that can validly be restored
 */
long NFMquery_flag_restore ( user_id, catalog, files )
    long	user_id;
    char	*catalog;
    MEMptr	*files;
{
    char 	*fname="NFMquery_flag_restore";
    int		vconstant, vcnt, vcolumns;    
    int		is_valid;
    int		tot_data;
    int		i, prev_item, prev_ver;

    long	status;
    char        s[200];
    char	catalog_no[20];

    char	**fdata_ptr;
    char	**vdata_ptr;
    char	**data;

    MEMptr	valid= NULL;	/* buffer of valid file information */
    MEMptr	fdata = NULL; 	/* file data buffer */
    MEMptr	vdata = NULL; 	/* version data buffer */
    MEMptr	buffer= NULL;


    _NFMdebug((fname, "Enter: Userid <%d>, Catalog <%s>\n", user_id, catalog));
    is_valid = 0;
    prev_item = -1;
    prev_ver = -1;

/*  Get catalog number 
 */
    status = NFMfl_get_catalog_no( catalog, catalog_no );
    if( status != NFM_S_SUCCESS )
    {
	_NFMdebug(( fname, "NFMfl_get_catalog_no : <0x%.8x>\n", status));
	return( status );
    }

/*  Start buffer to send back to requester 
 */
    status = MEMopen( &valid, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &valid );
	ERRload_struct( NFM, NFM_E_MEM, fname, "MEMopen" );
	return( NFM_E_MEM );
    }

    /*  Map attribute names for "catalog" */
		
    sprintf( s, "SELECT n_name, n_synonym, n_datatype FROM nfmattributes WHERE n_tableno IN ( SELECT n_tableno FROM nfmtables where n_tablename='%s' ) ",catalog);
    if(( status = SQLquery( s, &buffer, MEM_SIZE )) != SQL_S_SUCCESS )
    {
        _NFMdebug(( fname, "SQLquery = <0x%.8x>\n", status));
        MEMclose (&buffer);
        ERRload_struct( NFM, NFM_E_MAP_ATTRIBUTE_NAMES, NULL, NULL );
        return( NFM_E_MAP_ATTRIBUTE_NAMES );
    }
    MEMbuild_array (buffer);

    data = (char **) buffer->data_ptr;
    tot_data = (buffer->rows)*(buffer->columns);
    for( i=0; i<tot_data; i+=buffer->columns )
    {
	if( strcmp( data[i], "n_itemname" ) == 0 )
	{
            status = MEMwrite_format( valid, data[i+1], data[i+2] );
	    if( status != MEM_S_SUCCESS )
	    {
		MEMclose( &valid );
		_NFMdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
		ERRload_struct( NFM, NFM_E_MEM, fname, "MEMwrite_format");
		return( NFM_E_MEM );
	    }
	}
	else if( strcmp( data[i], "n_itemrev") == 0 )
	{
	    status = MEMwrite_format( valid, data[i+1], data[i+2] );
	    if( status != MEM_S_SUCCESS )
	    {
		MEMclose( &valid );
		_NFMdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
		ERRload_struct( NFM, NFM_E_MEM, fname, "MEMwrite_format");
		return( NFM_E_MEM );
	    }
	}
    }
    MEMclose( &buffer );

    sprintf( s, "SELECT n_name, n_synonym, n_datatype FROM nfmattributes WHERE n_tableno IN ( SELECT n_tableno FROM nfmtables where n_tablename='f_%s' ) ",catalog);
    if(( status = SQLquery( s, &buffer, MEM_SIZE )) != SQL_S_SUCCESS )
    {
        _NFMdebug(( fname, "SQLquery = <0x%.8x>\n", status));
        MEMclose (&buffer);
        ERRload_struct( NFM, NFM_E_MAP_ATTRIBUTE_NAMES, NULL, NULL );
        return( NFM_E_MAP_ATTRIBUTE_NAMES );
    }
    MEMbuild_array (buffer);

    data = (char **) buffer->data_ptr;
    tot_data = (buffer->rows)*(buffer->columns);
    for( i=0; i<tot_data; i+=buffer->columns )
    {
        if( strcmp( data[i], "n_fileversion" ) == 0 )
	{
	    status = MEMwrite_format( valid, data[i+1], data[i+2] );
	    if( status != MEM_S_SUCCESS )
	    {
		MEMclose( &valid );
                _NFMdebug(( fname, "MEMwrite_format : <0x%.8x>\n",status ));
                ERRload_struct( NFM, NFM_E_MEM, fname, "MEMwrite_format");
                return( NFM_E_MEM );
	    }
	}
        else if( strcmp( data[i], "n_cofilename" ) == 0 )
	{
	    status = MEMwrite_format( valid, data[i+1], data[i+2] );
	    if( status != MEM_S_SUCCESS )
	    {
		MEMclose( &valid );
                _NFMdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
                ERRload_struct( NFM, NFM_E_MEM, fname, "MEMwrite_format");
                return( NFM_E_MEM );
	    }
	}
    }
    MEMclose( &buffer );

    if(NFMglobal.administrator == 1)
    {
    	sprintf( s,"SELECT n_itemnum,n_fileversion,n_restoreflag,n_cofilename,n_fileno FROM f_%s WHERE n_cifilesize > 0",catalog);
    }
    else
    {
    	sprintf( s,"SELECT n_itemnum,MAX(n_fileversion),n_restoreflag,n_cofilename,n_fileno FROM f_%s WHERE n_cifilesize > 0 GROUP BY n_itemnum, n_restoreflag, n_cofilename, n_fileno",catalog);
    }
    	status = SQLquery( s, &vdata, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
        MEMclose( &vdata );
  	_NFMdebug(( fname, "NO files for catalog <%s>\n", catalog ));
        is_valid = 0;
	ERRload_struct( NFM, NFM_E_NO_FILES_TO_FLAG, "%s", catalog );
    }
    else
    {
	MEMbuild_array( vdata );
	vdata_ptr = (char**) vdata->data_ptr;
	vconstant = vdata->rows * vdata->columns;
	vcolumns  = vdata->columns;

	/*  Map this version back to item in catalog table
	 */
	for( vcnt = 0; vcnt < vconstant; vcnt += vcolumns )
	{
            /*  If the pendingflag is something other than '',
             *  we won't allow this to be flagged.
             */
            if( strcmp( vdata_ptr[vcnt+2], "" ) )
            {
                _NFMdebug(( fname,"Pending Flag <%s> -- Skip item_no <%s>\n",vdata_ptr[vcnt+2],vdata_ptr[vcnt] ));
                continue;
            }
	    fdata  = NULL;
  	    /*  Make sure there is an entry in the nfmsavesets table for
	     *  this file. Which is active!
	     */
	    sprintf( s,
	 	"SELECT n_fileno FROM nfmsavesets WHERE n_catalogno=%s AND n_itemno=%s AND n_fileno=%s AND n_itemstate!='I'",catalog_no, vdata_ptr[vcnt], vdata_ptr[vcnt+4] );
 	    status = SQLquery( s, &fdata, MEM_SIZE );
	    if( status != SQL_S_SUCCESS )
	    {
	 	_NFMdebug(( fname, "File_no <%s> not archived\n",
				vdata_ptr[vcnt+4]));
		MEMclose( &fdata );	
		continue;
	    }
   	    MEMclose( &fdata );

	    sprintf( s, "SELECT n_itemname,n_itemrev,n_archivestate FROM %s WHERE n_itemno = %s", catalog, vdata_ptr[vcnt] );

/*******Should I check wheter "n_archivestate IN ('A' or 'B') or not ? *****/


	    status = SQLquery( s, &fdata, MEM_SIZE );
	    if( status != SQL_S_SUCCESS )
	    {
		MEMclose( &fdata );	
		continue;
	    }
	    MEMbuild_array( fdata );
	    fdata_ptr = (char**) fdata->data_ptr;
	    
  	    _NFMdebug(( fname, "%s\n", "Valid File Found"));
 	    is_valid = 1;

	    /*  We have all information now. Build return buffer.
	     */
	    strcpy( s, fdata_ptr[0] );      /* item_name */
	    strcat( s, "\1" );
	    strcat( s, fdata_ptr[1] );      /* item_rev */
	    strcat( s, "\1" );
	    strcat( s, vdata_ptr[vcnt+3] ); /* co_filename */
	    strcat( s, "\1" );
	    strcat( s, vdata_ptr[vcnt+1] ); /* item_ver */
	    strcat( s, "\1" );

	    if((prev_item != atoi(vdata_ptr[vcnt])) || 
	       (prev_ver != atoi(vdata_ptr[vcnt+1])))
	    {
	    	status = MEMwrite( valid, s );
	    	if( status != MEM_S_SUCCESS )
	    	{
			MEMclose( &fdata );
	 		MEMclose( &vdata );
			MEMclose( &valid );
			_NFMdebug(( fname, "MEMwrite : <0x%.8x>\n" ,status ));
			ERRload_struct( NFM, NFM_E_MEM, fname, "MEMwrite" );
			return( NFM_E_MEM );
	    	}
		prev_item = atoi(vdata_ptr[vcnt]);
		prev_ver = atoi(vdata_ptr[vcnt+1]);
	    }
	    else
	    {
		_NFMdebug(( fname,"Item <%s> Ver <%s> is same as the prev item",
			    vdata_ptr[vcnt], vdata_ptr[vcnt+1] ));
	    }

 	    MEMclose( &fdata );

	} /* end 'version' for-loop */
	MEMclose( &vdata );	
    } /* end 'is_valid'  */

    if( !is_valid )
    {
	ERRload_struct( NFM, NFM_E_NO_FILES_FLAGGED, NULL, NULL );
	_NFMdebug(( fname, "%s\n","NO VALID FILES FOUND"));
  	return( NFM_E_NO_FILES_FLAGGED );
    }
    status = MEMsplit_copy_buffer( valid, files, 0 );
    if( status != MEM_S_SUCCESS )
    {
        _NFMdebug(( fname, "MEMsplit = <0x%.8x>\n", status));
        MEMclose( &valid );
	ERRload_struct( NFM, NFM_E_MEM, fname, "MEMsplit_copy" );
        return( NFM_E_MEM );
    }

    _NFMdebug(( fname, "%s\n", "Exiting ... " ));

    return( NFM_S_SUCCESS );
}

/****************************************************************************
 	NFMnew_query_flag_restore ( catalog, item, rev, files )

	New function for querying available item versions for flagging for 
	restore. This only returns the versions of the item required,
	NOT all the items availbale -DEP
*****************************************************************************/
long NFMnew_query_flag_restore ( catalog, item, rev, files )
    char	*catalog;
    char	*item;
    char	*rev;
    MEMptr	*files;
{
    char 	*fname="NFMnew_query_flag_restore";
    int		vconstant, vcnt, vcolumns;    
    int		is_valid;
    int		tot_data;
    int		i, prev_item, prev_ver;
    int         file_not_archived;

    long	status;
    char        s[200];
    char	catalog_no[20], item_no[20];

    char	**fdata_ptr;
    char	**vdata_ptr;
    char	**data;

    MEMptr	valid= NULL;	/* buffer of valid file information */
    MEMptr	fdata = NULL; 	/* file data buffer */
    MEMptr	vdata = NULL; 	/* version data buffer */
    MEMptr	buffer= NULL;


    _NFMdebug((fname, "Enter: Catalog <%s> Item <%s>, revision <%s>\n", catalog, item, rev));
    is_valid = 0;
    prev_item = -1;
    prev_ver = -1;
    file_not_archived = 0;

/*  Get catalog number 
 */
    status = NFMfl_get_catalog_no( catalog, catalog_no );
    if( status != NFM_S_SUCCESS )
    {
	_NFMdebug(( fname, "NFMfl_get_catalog_no : <0x%.8x>\n", status));
	return( status );
    }
/* Get item number */

    status = NFMfl_get_item_no( catalog, item, rev, item_no );
    if( status != NFM_S_SUCCESS )
    {
	_NFMdebug(( fname, "NFMfl_get_item_no : <0x%.8x>\n", status));
	return( status );
    }

/*  Start buffer to send back to requester 
 */
    status = MEMopen( &valid, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &valid );
	ERRload_struct( NFM, NFM_E_MEM, fname, "MEMopen" );
	return( NFM_E_MEM );
    }

    /*  Map attribute names for "catalog" */
		
    sprintf( s, "SELECT n_name, n_synonym, n_datatype FROM nfmattributes WHERE n_tableno IN ( SELECT n_tableno FROM nfmtables where n_tablename='%s' ) ",catalog);
    if(( status = SQLquery( s, &buffer, MEM_SIZE )) != SQL_S_SUCCESS )
    {
        _NFMdebug(( fname, "SQLquery = <0x%.8x>\n", status));
        MEMclose (&buffer);
        ERRload_struct( NFM, NFM_E_MAP_ATTRIBUTE_NAMES, NULL, NULL );
        return( NFM_E_MAP_ATTRIBUTE_NAMES );
    }
    MEMbuild_array (buffer);

    data = (char **) buffer->data_ptr;
    tot_data = (buffer->rows)*(buffer->columns);
    for( i=0; i<tot_data; i+=buffer->columns )
    {
	if( strcmp( data[i], "n_itemname" ) == 0 )
	{
            status = MEMwrite_format( valid, data[i+1], data[i+2] );
	    if( status != MEM_S_SUCCESS )
	    {
		MEMclose( &valid );
		_NFMdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
		ERRload_struct( NFM, NFM_E_MEM, fname, "MEMwrite_format");
		return( NFM_E_MEM );
	    }
	}
	else if( strcmp( data[i], "n_itemrev") == 0 )
	{
	    status = MEMwrite_format( valid, data[i+1], data[i+2] );
	    if( status != MEM_S_SUCCESS )
	    {
		MEMclose( &valid );
		_NFMdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
		ERRload_struct( NFM, NFM_E_MEM, fname, "MEMwrite_format");
		return( NFM_E_MEM );
	    }
	}
    }
    MEMclose( &buffer );

    sprintf( s, "SELECT n_name, n_synonym, n_datatype FROM nfmattributes WHERE n_tableno IN ( SELECT n_tableno FROM nfmtables where n_tablename='f_%s' ) ",catalog);
    if(( status = SQLquery( s, &buffer, MEM_SIZE )) != SQL_S_SUCCESS )
    {
        _NFMdebug(( fname, "SQLquery = <0x%.8x>\n", status));
        MEMclose (&buffer);
        ERRload_struct( NFM, NFM_E_MAP_ATTRIBUTE_NAMES, NULL, NULL );
        return( NFM_E_MAP_ATTRIBUTE_NAMES );
    }
    MEMbuild_array (buffer);

    data = (char **) buffer->data_ptr;
    tot_data = (buffer->rows)*(buffer->columns);
    for( i=0; i<tot_data; i+=buffer->columns )
    {
        if( strcmp( data[i], "n_fileversion" ) == 0 )
	{
	    status = MEMwrite_format( valid, data[i+1], data[i+2] );
	    if( status != MEM_S_SUCCESS )
	    {
		MEMclose( &valid );
                _NFMdebug(( fname, "MEMwrite_format : <0x%.8x>\n",status ));
                ERRload_struct( NFM, NFM_E_MEM, fname, "MEMwrite_format");
                return( NFM_E_MEM );
	    }
	}
/****** This attribute is no longer sent to the client 
        else if( strcmp( data[i], "n_cofilename" ) == 0 )
	{
	    status = MEMwrite_format( valid, data[i+1], data[i+2] );
	    if( status != MEM_S_SUCCESS )
	    {
		MEMclose( &valid );
                _NFMdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
                ERRload_struct( NFM, NFM_E_MEM, fname, "MEMwrite_format");
                return( NFM_E_MEM );
	    }
	}
***********/
    }
    MEMclose( &buffer );

    	sprintf( s,"SELECT n_itemnum,n_fileversion,n_restoreflag,n_cofilename,n_fileno FROM f_%s WHERE (n_cifilesize > 0) AND (n_itemnum=%s)",catalog, item_no);

    status = SQLquery( s, &vdata, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
        MEMclose( &vdata );
  	_NFMdebug(( fname, "NO files for catalog <%s>\n", catalog ));
        is_valid = 0;
	ERRload_struct( NFM, NFM_E_NO_FILES_TO_FLAG, "%s", catalog );
    }
    else
    {
	MEMbuild_array( vdata );
	vdata_ptr = (char**) vdata->data_ptr;
	vconstant = vdata->rows * vdata->columns;
	vcolumns  = vdata->columns;

	/*  Map this version back to item in catalog table
	 */
	for( vcnt = 0; vcnt < vconstant; vcnt += vcolumns )
	{
            /*  If the pendingflag is something other than '',
             *  we won't allow this to be flagged.
             */
            if( strcmp( vdata_ptr[vcnt+2], "" ) )
            {
                _NFMdebug(( fname,"Pending Flag <%s> -- Skip item_no <%s>\n",vdata_ptr[vcnt+2],vdata_ptr[vcnt] ));
                continue;
            }
	    fdata  = NULL;
  	    /*  Make sure there is an entry in the nfmsavesets table for
	     *  this file. Which is active!
	     */
	    sprintf( s,
	 	"SELECT n_fileno FROM nfmsavesets WHERE n_catalogno=%s AND n_itemno=%s AND n_fileno=%s AND n_itemstate!='I'",catalog_no, vdata_ptr[vcnt], vdata_ptr[vcnt+4] );
 	    status = SQLquery( s, &fdata, MEM_SIZE );
	    if( status != SQL_S_SUCCESS )
	    {
		file_not_archived = file_not_archived + 1;
	 	_NFMdebug(( fname, "File_no <%s> not archived\n",
				vdata_ptr[vcnt+4]));
		MEMclose( &fdata );	
		continue;

	    }
   	    MEMclose( &fdata );

	    sprintf( s, "SELECT n_itemname,n_itemrev,n_archivestate FROM %s WHERE n_itemno = %s", catalog, vdata_ptr[vcnt] );

	    status = SQLquery( s, &fdata, MEM_SIZE );
	    if( status != SQL_S_SUCCESS )
	    {
		MEMclose( &fdata );	
		continue;
	    }
	    MEMbuild_array( fdata );
	    fdata_ptr = (char**) fdata->data_ptr;
	    
  	    _NFMdebug(( fname, "%s\n", "Valid File Found"));
 	    is_valid = 1;

	    /*  We have all information now. Build return buffer.
	     */
	    strcpy( s, fdata_ptr[0] );      /* item_name */
	    strcat( s, "\1" );
	    strcat( s, fdata_ptr[1] );      /* item_rev */
	    strcat( s, "\1" );
/******This attribute is no longer sent to the client 
	    strcat( s, vdata_ptr[vcnt+3] ); / * co_filename * /
	    strcat( s, "\1" );
*****************************************************/
	    strcat( s, vdata_ptr[vcnt+1] ); /* item_ver */
	    strcat( s, "\1" );

	    if((prev_item != atoi(vdata_ptr[vcnt])) || 
	       (prev_ver != atoi(vdata_ptr[vcnt+1])))
	    {
	    	status = MEMwrite( valid, s );
	    	if( status != MEM_S_SUCCESS )
	    	{
			MEMclose( &fdata );
	 		MEMclose( &vdata );
			MEMclose( &valid );
			_NFMdebug(( fname, "MEMwrite : <0x%.8x>\n" ,status ));
			ERRload_struct( NFM, NFM_E_MEM, fname, "MEMwrite" );
			return( NFM_E_MEM );
	    	}
		prev_item = atoi(vdata_ptr[vcnt]);
		prev_ver = atoi(vdata_ptr[vcnt+1]);
	    }
	    else
	    {
		_NFMdebug(( fname,"Item <%s> Ver <%s> is same as the prev item",
			    vdata_ptr[vcnt], vdata_ptr[vcnt+1] ));
	    }

 	    MEMclose( &fdata );

	} /* end 'version' for-loop */
	MEMclose( &vdata );	
    } /* end 'is_valid'  */

    if( !is_valid )
    {
	if(file_not_archived == 1)
	{
            ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "File is not archived or backed up");
  	    _NFMdebug(( fname, "%s\n","FILE NOT ARCHIVED"));
    	    return( NFM_E_MESSAGE );
	}
	else
	{
	    ERRload_struct( NFM, NFM_E_NO_FILES_FLAGGED, NULL, NULL );
  	    _NFMdebug(( fname, "%s\n","NO VALID FILES FOUND"));
    	    return( NFM_E_NO_FILES_FLAGGED );
	}
    }
    status = MEMsplit_copy_buffer( valid, files, 0 );
    if( status != MEM_S_SUCCESS )
    {
        _NFMdebug(( fname, "MEMsplit = <0x%.8x>\n", status));
        MEMclose( &valid );
	ERRload_struct( NFM, NFM_E_MEM, fname, "MEMsplit_copy" );
        return( NFM_E_MEM );
    }

    _NFMdebug(( fname, "%s\n", "Exiting ... " ));

    return( NFM_S_SUCCESS );
}

/*  This routine is to query for files that can validly be deleted
 */
long NFMquery_flag_delete ( user_id, catalog, files )
    long	user_id;
    char	*catalog;
    MEMptr	*files;
{
    char  	*fname="NFMquery_flag_delete";
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

    _NFMdebug((fname, "Enter: Userid <%d>, Catalog <%s>\n", user_id, catalog));
    is_valid = 0;
/*  Start buffer to send back to requester 
 */
    status = MEMopen( &valid, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &valid );
	_NFMdebug((fname, "MEMopen : <0x%.8x>\n", status));
	return( status );
    }

    /*  Map attribute names for "catalog" */
		
    sprintf( s, "SELECT n_name, n_name, n_synonym, n_datatype FROM nfmattributes WHERE n_tableno IN ( SELECT n_tableno FROM nfmtables where n_tablename='%s' ) ",catalog );
    if((status = SQLquery( s, &buffer, MEM_SIZE )) != SQL_S_SUCCESS )
    {
	_NFMdebug ((fname, "SQLquery = <0x%.8x>\n", status));
        MEMclose (&buffer);
        ERRload_struct( NFM, NFM_E_MAP_ATTRIBUTE_NAMES, NULL, NULL );
        return( status );
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

	    /* Put synonym name and datatype in buffer title */
	    status = MEMwrite_format( valid, data[i+2], data[i+3] );
	    if( status != MEM_S_SUCCESS )
	    {
		MEMclose( &valid );
		_NFMdebug((fname,"MEMwrite_format : <0x%.8x>\n", status ));
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
		_NFMdebug((fname,"MEMwrite_format : <0x%.8x>\n", status ));
		return( status );
	    }
	}
    }
    MEMclose( &buffer );

    /*  Map attribute names for "f_catalog" */
		
    sprintf( s, "SELECT n_name, n_name, n_synonym, n_datatype FROM nfmattributes WHERE n_tableno IN ( SELECT n_tableno FROM nfmtables where n_tablename='f_%s' ) ",catalog);
    if(( status = SQLquery( s, &buffer, MEM_SIZE )) != SQL_S_SUCCESS )
    {
        _NFMdebug ((fname, "SQLquery = <0x%.8x>\n", status));
        MEMclose (&buffer);
        ERRload_struct( NFM, NFM_E_MAP_ATTRIBUTE_NAMES, NULL, NULL );
        return( status );
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
                _NFMdebug((fname,"MEMwrite_format : <0x%.8x>\n", status ));
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
		_NFMdebug((fname,"MEMwrite_format : <0x%.8x>\n", status ));
		return( status );
	    }
	}
	else if( strcmp( data[i], "n_cifilesize" ) == 0 )
            strcpy( a_cifilesize, data[i+1] );
	else if( strcmp( data[i], "n_pendingflag" ) == 0 )
	    strcpy( a_pendingflag, data[i+1] );
    }
    MEMclose( &buffer );

    sprintf( s, "SELECT %s,MAX(%s) FROM f_%s GROUP BY %s",
  	         a_itemnum, a_fileversion, catalog, a_itemnum );
    status = SQLquery( s, &vdata, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
        MEMclose( &vdata );
	MEMclose( &valid );
        return( status );
    }
    MEMbuild_array( vdata );
    vdata_ptr = (char**) vdata->data_ptr;
    vconstant = vdata->rows * vdata->columns;
    vcolumns  = vdata->columns;

    for( vcnt = 0; vcnt < vconstant; vcnt += vcolumns )
    {
	buffer = NULL;
        sprintf( s, 
		 "SELECT %s,%s FROM f_%s WHERE %s > 0 AND %s = %s AND %s = %s",
  	         a_pendingflag, a_cofilename, catalog, a_cifilesize,
		 a_itemnum, vdata_ptr[vcnt], a_fileversion, vdata_ptr[vcnt+1]);
        status = SQLquery( s, &buffer, MEM_SIZE );
        if( status != SQL_S_SUCCESS )
        {
	    MEMclose( &buffer );
	    continue;
        }
        else
        {	
	    MEMbuild_array( buffer );
   	    data = (char**) buffer->data_ptr;

  	    _NFMdebug((fname, "%s\n", "Valid File Found :"  ));
     	    is_valid = 1;
            /*  If the pendingflag is something other than '',
             *  we won't allow this to be flagged.
             */
            if( strcmp( data[0], "" ) )
            {
                _NFMdebug((fname, "Pending Flag <%s>\n", data[0] ));
		MEMclose( &buffer );
                continue;
            }
	    fdata  = NULL;
	    sprintf( s, "SELECT %s,%s,%s,%s FROM %s WHERE %s = %s", 
	     	     a_itemname, a_itemrev, a_archivestate, a_coout,
		     catalog, a_itemno, vdata_ptr[vcnt]);
	    status = SQLquery( s, &fdata, MEM_SIZE );
	    if( status != SQL_S_SUCCESS )
	    {
		MEMclose( &fdata );	
		MEMclose( &buffer );
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
		_NFMdebug((fname, "Archive State <%s>\n", fdata_ptr[2] ));
		_NFMdebug((fname, "Check Out State <%s>\n", fdata_ptr[3] ));
		MEMclose( &fdata );
		MEMclose( &buffer );
		continue;
	    }

	    /*  We have all information now. Build return buffer.
	     */
	    strcpy( s, fdata_ptr[0] );      /* item_name */
	    strcat( s, "\1" );
	    strcat( s, fdata_ptr[1] );      /* item_rev */
	    strcat( s, "\1" );
	    strcat( s, vdata_ptr[vcnt+1] ); /* item_version */
 	    strcat( s, "\1" );
	    strcat( s, data[1] );           /* co_filename */
	    strcat( s, "\1" );
	    
 	    _NFMdebug((fname, "str <%s>\n", s ));
	    status = MEMwrite( valid, s );
	    if( status != MEM_S_SUCCESS )
	    {
		MEMclose( &buffer );
		MEMclose( &fdata );
	 	MEMclose( &vdata );
		MEMclose( &valid );
		_NFMdebug((fname, "MEMwrite : <0x%.8x>\n" , status ));
		return( status );
	    }
 	    MEMclose( &fdata );
	    MEMclose( &buffer );
        }
    }
    MEMclose( &vdata );	

    if( !is_valid )
    {
        _NFMdebug((fname, "No valid files in <%s>\n", catalog ));
 	ERRload_struct( NFM, NFM_E_NO_FILES_TO_FLAG, "%s", catalog );
	return( NFM_E_NO_FILES_TO_FLAG );
    }

    status = MEMsplit_copy_buffer( valid, files, 0 );
    if( status != MEM_S_SUCCESS )
    {
        _NFMdebug ((fname, "MEMsplit = <0x%.8x>\n", status));
        MEMclose( &valid );
        return( status );
    }

    _NFMdebug((fname, "%s\n", "Exit" ));
    return( NFM_S_SUCCESS );
}
