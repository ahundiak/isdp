#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "UTIerrordef.h"
#include "UTIstruct.h"
#include "UTIglobals.h"
#include "UTIdef.h"
#include "ERR.h"
#include "DEBUG.h"
#include "NFMschema.h"

extern	 UTIpending  UTIflist;

char	 uti_string[1024];

/*  Query for storage areas ( attributes and values )
 */
UTIquery_sa( sa_value )
    MEMptr  *sa_value;
{
    int		i;

    long	status;

    char	**data_ptr;
    char   	fmt[NFM_SYNONYM+1];
   
    MEMptr  value = NULL;

    static  char *fname = "UTIquery_sa";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    status = MEMopen( sa_value, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	MEMclose( sa_value );
	return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", INTEGER );
    status = MEMwrite_format( *sa_value, "Storage Area Number", fmt );
    if( status != MEM_S_SUCCESS )
    {
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	MEMclose( sa_value );
	return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_SANAME );
    status = MEMwrite_format( *sa_value, "Storage Area Name", fmt );
    if( status != MEM_S_SUCCESS )
    {
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	MEMclose( sa_value );
	return( NFM_E_MEM );
    }
 
    sprintf( fmt, "char(%d)", NFM_DEVICETYPE );
    status = MEMwrite_format( *sa_value, "Device Type", fmt );
    if( status != MEM_S_SUCCESS )
    {
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	MEMclose( sa_value );
	return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", INTEGER );
    status = MEMwrite_format( *sa_value, "Node Number", fmt );
    if( status != MEM_S_SUCCESS )
    {
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	MEMclose( sa_value );
	return( NFM_E_MEM );
    }

/*  This query is built this was to preserve the '%-UTIL' which does not
 *  remain intact through a 'sprintf' .
 */
/** Also do not show storage area types W and S **/

    strcpy( uti_string,"SELECT n_sano,n_saname,n_devicetype,n_nodeno FROM nfmstoragearea WHERE n_sano != " );
    sprintf( fmt, "%d", UTI_RES_SA );
    strcat( uti_string, fmt );
    strcat( uti_string, 
	" AND n_saname NOT LIKE '%-UTIL' AND n_type IN ('U','B')" );

    status = SQLquery( uti_string, &value, MEM_SIZE );
    if( status == SQL_I_NO_ROWS_FOUND )
    {
	/** There are no storage areas available for utility operations**/
	ERRload_struct( UTI, UTI_E_NO_UTILSA, "", NULL );
	MEMclose( &value );
	return( UTI_E_NO_UTILSA );
    }

    if( status != SQL_S_SUCCESS )
    {
	ERRload_struct( UTI, UTI_E_QUERYSA, "%d", UTI_RES_SA );
	MEMclose( &value );
	return( UTI_E_QUERYSA );
    }
    MEMbuild_array( value );
    data_ptr = (char **)value->data_ptr;
    for( i=0; i<(value->rows*value->columns); i+=value->columns )
    {
	sprintf( uti_string, "%s\1%s\1%s\1%s\1", data_ptr[i], data_ptr[i+1],
		 data_ptr[i+2], data_ptr[i+3] );

        status = MEMwrite( *sa_value, uti_string );
        if( status != MEM_S_SUCCESS )
        {
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
  	    MEMclose( sa_value );
   	    return( NFM_E_MEM );
	}
    }

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

/*  Query for labels
 */
UTIquery_labels( label_value )
    MEMptr  *label_value;
{
    long	status;

    MEMptr	value = NULL;

    static	char *fname = "UTIquery_labels";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    sprintf( uti_string, "SELECT DISTINCT n_label FROM nfmarchives WHERE n_label NOT IN ('DISK_A','DISK_B','DISK_C','DISK_O','DISK_F','DISK_J')");
    status = SQLquery( uti_string, &value, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
	MEMclose( &value );
	/**ERRload_struct( UTI, UTI_E_QUERYLABELS, NULL, NULL );**/
	return( UTI_E_QUERYLABELS );
    }

    *label_value = value;

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

/*  Query for flagged files
 */
UTIquery_files_flagged_for_archive_or_backup( file_value, utility )
    MEMptr	*file_value;
    int		utility; /** This can be Archive, backup or Restore **/
{
    int		link_no     = 0;
    int		ccnt        = 0;
    int		icnt	    = 0;
    int		fcnt	    = 0;
    int		files_cnt   = 0;
    int		isflag      = 0;
    int  	project_no  = 0;
    int		max_version = 0;
   
    long	status;

    char 	char_utility[10];
    char	fmt[NFM_SYNONYM+1];
    char	last_cat[NFM_CATALOGNAME+1];
    char	last_item[NFM_ITEMNAME+1];
    char	last_rev[NFM_ITEMREV+1];

    char	**cat_ptr;
    char	**icat_ptr;
    char	**fcat_ptr;
    char 	**files_ptr;

    MEMptr	chosen= NULL;	/* buffer of chosen file information */
    MEMptr	cat  = NULL;	/* catalog data buffer */
    MEMptr	icat = NULL; 	/* item data buffer */
    MEMptr	fcat = NULL; 	/* f_catalog data buffer */
    MEMptr      files= NULL;    /* files data buffer */

    UTIpending	savedlist = NULL;
    UTIpending  link = NULL;
    UTIpending	listend = NULL;
    UTIpending	UTImake_list();

    char	*UTIbuild_nfm_name();
    
    static	char *fname = "UTIquery_flagged_files_a_b_r";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));
    
    isflag = 0;
    savedlist = listend = NULL;
    UTIflist  = NULL;
    link_no = 0;

    strcpy( uti_string, "SELECT n_catalogname,n_catalogno FROM nfmcatalogs");
    status = SQLquery( uti_string, &cat, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
	ERRload_struct( UTI, UTI_E_QUERYCATALOGS, NULL, NULL );
	return( UTI_E_QUERYCATALOGS );
    }
    
    MEMbuild_array( cat );
    cat_ptr = (char**) cat->data_ptr;

/*  Start buffer to send back to requester 
 */
    status = MEMopen( &chosen, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &chosen );
	MEMclose( &cat );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _UTIdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (NFM_E_MEM);
    }

    sprintf( fmt, "char(%d)", NFM_CATALOGNAME );
    status = MEMwrite_format( chosen, "Catalog Name", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &chosen );
	MEMclose( &cat );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _UTIdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (NFM_E_MEM);
     }

    sprintf( fmt, "char(%d)", NFM_ITEMNAME );
    status = MEMwrite_format( chosen, "Item Name", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &chosen );
	MEMclose( &cat );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _UTIdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (NFM_E_MEM);
    }

    sprintf( fmt, "char(%d)", NFM_ITEMREV );
    status = MEMwrite_format( chosen, "Revision", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &chosen );
	MEMclose( &cat );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _UTIdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (NFM_E_MEM);
    }

    sprintf( fmt, "char(%d)", NFM_PENDINGFLAG );
    status = MEMwrite_format( chosen, "Flag", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &chosen );
	MEMclose( &cat );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _UTIdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (NFM_E_MEM);
    }

    status = MEMwrite_format( chosen, "Link", "char(15)" );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &chosen );
	MEMclose( &cat );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _UTIdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (NFM_E_MEM);
    }

    strcpy( last_cat, "" );
    strcpy( last_item, "" );
    strcpy( last_rev, "" );

    /*  Loop through all catalogs searching for flagged files 
     */
    for( ccnt=0; ccnt<(cat->rows*cat->columns); ccnt+=cat->columns )
    {
	icat = NULL;
	_UTIdebug(( fname, "Query Catalog <%s>\n", cat_ptr[ccnt] ));

 	sprintf( uti_string, "SELECT n_itemno,n_itemname,n_itemrev,n_setindicator,n_pendingflag FROM %s WHERE n_pendingflag IN ( '%s','%s','%s','%s')",
	 cat_ptr[ccnt], UTI_PENDING_FLAGS[0],UTI_PENDING_FLAGS[1], 
	 UTI_PENDING_FLAGS[2], UTI_PENDING_FLAGS[3]);

	status = SQLquery( uti_string, &icat, MEM_SIZE );
	if( status != SQL_S_SUCCESS )
	{
	    MEMclose( &icat );
	    _UTIdebug((fname, "NO flags for catalog <%s>\n",cat_ptr[ccnt] ));
	    continue;	
	}
	
	MEMbuild_array( icat );
	icat_ptr = (char**) icat->data_ptr;

	for( icnt = 0; icnt<(icat->rows*icat->columns); icnt+=icat->columns )
	{
	    fcat  = NULL;

	    if(utility == UTIarchive)
	    {
	     	sprintf( uti_string, "SELECT n_fileno FROM f_%s WHERE n_itemnum = %s AND n_fileversion IN (SELECT MAX(n_fileversion) FROM f_%s WHERE n_itemnum = %s AND n_fileco='N')", cat_ptr[ccnt], icat_ptr[icnt], 
			cat_ptr[ccnt], icat_ptr[icnt] );
	    }
	    else if(utility == UTIbackup)
	    {
	     	sprintf( uti_string, "SELECT n_fileno FROM f_%s WHERE n_itemnum = %s AND n_fileversion IN (SELECT MAX(n_fileversion) FROM f_%s WHERE n_itemnum = %s AND n_fileco is not NULL)", cat_ptr[ccnt], icat_ptr[icnt], 
			cat_ptr[ccnt], icat_ptr[icnt] );
	    }
	    else if(utility == UTIrestore)
	    {
	     	sprintf( uti_string, "SELECT n_fileno FROM f_%s WHERE n_itemnum = %s AND n_fileversion IN (SELECT DISTINCT(n_fileversion) FROM f_%s WHERE n_itemnum = %s AND n_restoreflag IN ('%s', '%s', '%s', '%s'))", 
	 	cat_ptr[ccnt], icat_ptr[icnt], 
		cat_ptr[ccnt], icat_ptr[icnt], 
		UTI_PENDING_FLAGS[0],UTI_PENDING_FLAGS[1],
            	UTI_PENDING_FLAGS[2], UTI_PENDING_FLAGS[3] );
	    }

	    status = SQLquery( uti_string, &fcat, MEM_SIZE );
	    if( status != SQL_S_SUCCESS )
	    {
		MEMclose( &fcat );	
		continue;
	    }
	    MEMbuild_array( fcat );
	    fcat_ptr = (char**) fcat->data_ptr;
	  
 	    for( fcnt=0; fcnt<(fcat->rows*fcat->columns); fcnt+=fcat->columns )
	    {
		files = NULL;

	        sprintf( uti_string, "SELECT n_archiveno,n_cifilesize,n_cisano,n_cifilename,n_filetype,n_cofilename,n_convertind FROM f_%s WHERE n_fileno = %s", cat_ptr[ccnt], fcat_ptr[fcnt] );
  	        status = SQLquery( uti_string, &files, MEM_SIZE );
	        if( status != SQL_S_SUCCESS )
	        {
	_UTIdebug(( fname, " fcatalog entry not found for fileno <%s>, f_catalog <f_%s>\n", cat_ptr[ccnt], fcat_ptr[fcnt]));
	   	    MEMclose( &files );	
		    continue;
	        }
	        MEMbuild_array( files );

		isflag = 1;
		_UTIdebug(( fname, "%s\n", "Flagged File Found" ));
	        files_ptr = (char**) files->data_ptr;
	   
                for( files_cnt=0; files_cnt<(files->rows*files->columns); 
	   	     files_cnt+=files->columns )
	        {
    	            link_no += 1;
	  	    if( (strcmp( last_cat, cat_ptr[ccnt] ) == 0 ) &&
			(strcmp( last_item, icat_ptr[icnt+1] ) == 0 ) &&
			(strcmp( last_rev,  icat_ptr[icnt+2] ) == 0 ))
		    {
			    _UTIdebug(( fname, "%s\n", 	"Same Cat.Item.Rev As Last One" ));
		    }
		    else
	 	    {
    	                /****link_no += 1; used to be here***/
  	                sprintf( uti_string, "%s\1%s\1%s\1%s\1%d\1",
	  		   cat_ptr[ccnt], icat_ptr[icnt+1], icat_ptr[icnt+2],
		  	   icat_ptr[icnt+4], link_no );
  	                status = MEMwrite( chosen, uti_string );
	                if( status != MEM_S_SUCCESS )
	                {
 	 	            MEMclose( &cat );
    	  	            MEMclose( &icat );
	             	    MEMclose( &fcat );
		            MEMclose( &chosen );
			    MEMclose( &files );
			    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
		            return( NFM_E_MEM );
	                }
	    	        strcpy( last_cat, cat_ptr[ccnt] );
 		        strcpy( last_item, icat_ptr[icnt+1] );
		        strcpy( last_rev,  icat_ptr[icnt+2] );
		    }

 	        /*  Now add a link to the linked list of chosen files.
	         *  This linked list will hang around waiting on the request
  	         *  response which will be a buffer of chosen files represented
	         *  by their link number. The link number will be matched up
	         *  to link numbers in this linked list so that the querys 
	         *  don't have to be performed again.
	         */
	        link = UTImake_list();
	        link->rstr.archive_no = atoi( files_ptr[files_cnt] );
	        link->rstr.storage_no = atoi( files_ptr[files_cnt+2] );
	        strcpy( link->cat.name, cat_ptr[ccnt] );
	        link->cat.val = atoi( cat_ptr[ccnt+1] );
	        strcpy( link->item.name, icat_ptr[icnt+1] );
	        link->item.val= atoi( icat_ptr[icnt] );
	        link->rev = UTIload( icat_ptr[icnt+2] );
	        link->ver = max_version;
	        link->file_no = atoi( fcat_ptr[fcnt] );
	        link->state   = link_no;
	        link->set_indicator = UTIload( icat_ptr[icnt+3] );
  	        /*  Find out if this is a project member that is also flagged 
	         */
	        if( (strcmp( icat_ptr[icnt+4], "PA" ) == 0) ||
		    (strcmp( icat_ptr[icnt+4], "PB" ) == 0)||
		    (strcmp( icat_ptr[icnt+4], "PR" ) == 0))
	        {
	            status = UTIproject_member( link->cat.val, 
			atol( icat_ptr[icnt] ),icat_ptr[icnt+4], &project_no );
	            if( status != UTI_S_SUCCESS )
		        link->project_no = 0;
	            else
   	  	        link->project_no = project_no;
	        }

  	        /*  Get file storage information and true filename according
	         *  to where the file is stored.
	         */
	        status = UTIget_fs_info( link, link->rstr.storage_no );
	        link->size = atoi( files_ptr[files_cnt+1] );
	        strcpy( link->type.name, files_ptr[files_cnt+4] );

		if(utility == UTIrestore)		
		{
			status = UTIget_rstr_info( link );
                	if( status != UTI_S_SUCCESS )
                	{
                    		MEMclose( &cat );
                    		MEMclose( &icat );
                    		MEMclose( &fcat );
                    		MEMclose( &chosen );
                    		return( status );
                	}
	        	/*  If the format is '2.0.1', this filename was 
	         	*  archived or backed up in the old format. The
	         	*  file must be accessed in the cpio file with
	         	*  the old format but put back on disk in the 
	         	*  new format. So get old format name ...
	         	*/
	        	if( ( strcmp( files_ptr[files_cnt+6], "2.0.1" ) == 0 )||
		    	( strcmp( files_ptr[files_cnt+6], "2.1.0" ) == 0 ))
			{
	            	     NFMold_file_name(UTIuser_id, atoi(cat_ptr[ccnt+1]),
		                      atoi(fcat_ptr[fcnt]), link->format.name );
		    	     link->format.val = 2100;
			}
			else if( strcmp(files_ptr[files_cnt+6], "3.0.0") == 0)
			{
				link->format.val = 3000;
			}
			else if( strcmp(files_ptr[files_cnt+6], "3.2.0") == 0)
			{
				link->format.val = 3200;
			}
			else
				link->format.val = 0;

		}
       
		if( utility == UTIarchive )
	            strcpy( char_utility, "ARCHIVE" );
	 	else if( utility == UTIbackup )
		    strcpy( char_utility, "BACKUP" );
	 	else if( utility == UTIrestore )
		    strcpy( char_utility, "RESTORE" );

   		if( strlen( files_ptr[files_cnt+3] ) == 0 )
	                link->ci_file_name = 
 			  UTIbuild_nfm_name(cat_ptr[ccnt+1],fcat_ptr[fcnt] );
		    else
		        link->ci_file_name = UTIload( files_ptr[files_cnt+3] );

 		    strcpy( link->home.co_file_name,
 		        UTIbuild_nfm_name( cat_ptr[ccnt+1],fcat_ptr[fcnt]));
		}
	        /*  Add on the link 
	         */
	        if( savedlist == NULL )
	   	     savedlist = listend = link; /* First link */
	        else
	        {
		    listend->next = link;
		    listend = link;
	        }
	        UTIprint_pending_files( link );
	        MEMclose( &files );
	    } /* end 'file_catalog' loop */
	    MEMclose( &fcat );
        } /* end 'item' for-loop */
        MEMclose( &icat );	
    } /* end 'catalog' for-loop */
    MEMclose( &cat );

/*  If no files were flagged -- reset chosen buffer to NULL ( it now has
 *  formats without data if no files were found .
 */
    if( utility == UTIarchive )
	 strcpy( char_utility, "ARCHIVE" );
    else if( utility == UTIbackup )
	 strcpy( char_utility, "BACKUP" );
    else if( utility == UTIrestore )
	 strcpy( char_utility, "RESTORE" );

    if( !isflag )
    {
	MEMclose( &chosen );
	chosen = NULL;
	_UTIdebug(( fname, "%s\n", "NO FLAGGED FILES FOUND " ));
	ERRload_struct( UTI, UTI_E_NO_FILES_FLAGGED, "%s", char_utility);
        UTIflist = savedlist;  	/* linked list of files */
        *file_value = chosen;	/* buffer of requester */
	return(UTI_E_NO_FILES_FLAGGED);
    }

    UTIflist = savedlist;  	/* linked list of files */
    *file_value = chosen;	/* buffer of requester */

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

UTIquery_files_flagged_for_restore( file_value )
    MEMptr	*file_value;
{
    int		link_no;
    int		ccnt;
    int		icnt;
    int		fcnt;
    int		isflag;
    int  	project_no;

    long	status;

    char 	char_utility[10];
    char	fmt[NFM_SYNONYM+1];

    char	**cat_ptr;
    char	**icat_ptr;
    char	**fcat_ptr;

    MEMptr	chosen= NULL;	/* buffer of chosen file information */
    MEMptr	cat  = NULL;	/* catalog data buffer */
    MEMptr	icat = NULL; 	/* item data buffer */
    MEMptr	fcat = NULL; 	/* file data buffer */

    UTIpending	savedlist;
    UTIpending  link;
    UTIpending	listend;
    UTIpending	UTImake_list();

    char	*UTIbuild_nfm_name();
    
    static	char *fname = "UTIquery_flagged_files";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));
    
    isflag = 0;
    savedlist = listend = NULL;
    UTIflist  = NULL;
    link_no = 0;

    strcpy( uti_string, "SELECT n_catalogname,n_catalogno FROM nfmcatalogs");
    status = SQLquery( uti_string, &cat, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
	ERRload_struct( UTI, UTI_E_QUERYCATALOGS, NULL, NULL );
	return( UTI_E_QUERYCATALOGS );
    }
    
    MEMbuild_array( cat );
    cat_ptr = (char**) cat->data_ptr;

/*  Start buffer to send back to requester 
 */
    status = MEMopen( &chosen, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &chosen );
	MEMclose( &cat );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _UTIdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        return (NFM_E_MEM);
    }

    sprintf( fmt, "char(%d)", NFM_CATALOGNAME );
    status = MEMwrite_format( chosen, "Catalog Name", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &chosen );
	MEMclose( &cat );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _UTIdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (NFM_E_MEM);
     }

    sprintf( fmt, "char(%d)", NFM_ITEMNAME );
    status = MEMwrite_format( chosen, "Item Name", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &chosen );
	MEMclose( &cat );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _UTIdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (NFM_E_MEM);
    }

    sprintf( fmt, "char(%d)", NFM_ITEMREV );
    status = MEMwrite_format( chosen, "Revision", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &chosen );
	MEMclose( &cat );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _UTIdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (NFM_E_MEM);
    }

    sprintf( fmt, "char(%d)", NFM_COFILENAME );
    status = MEMwrite_format( chosen, "Local File Name", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &chosen );
	MEMclose( &cat );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _UTIdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (NFM_E_MEM);
    }

    sprintf( fmt, "char(%d)", NFM_PENDINGFLAG );
    status = MEMwrite_format( chosen, "Flag", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &chosen );
	MEMclose( &cat );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _UTIdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (NFM_E_MEM);
    }

    status = MEMwrite_format( chosen, "Link", "char(15)" );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &chosen );
	MEMclose( &cat );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _UTIdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (NFM_E_MEM);
    }

    /*  Loop through all catalogs searching for flagged files 
     */
    for( ccnt = 0; ccnt<(cat->rows*cat->columns); ccnt+=cat->columns )
    {
	icat = NULL;
	_UTIdebug(( fname, "Query Catalog <%s>\n", cat_ptr[ccnt] ));

	sprintf( uti_string, "SELECT n_itemno,n_itemname,n_itemrev,n_setindicator,n_pendingflag FROM %s WHERE n_pendingflag IN ( '%s','%s','%s','%s')",
	 cat_ptr[ccnt], UTI_PENDING_FLAGS[0],UTI_PENDING_FLAGS[1], 
	 UTI_PENDING_FLAGS[2], UTI_PENDING_FLAGS[3]);

	status = SQLquery( uti_string, &icat, MEM_SIZE );
	if( status != SQL_S_SUCCESS )
	{
	    MEMclose( &icat );
	    _UTIdebug((fname, "NO flags for catalog <%s>\n",cat_ptr[ccnt] ));
	    /**
	    ERRload_struct( UTI, UTI_E_NO_FILES_FLAGGED, "%s", cat_ptr[ccnt]);
	    **/
	    continue;	
	}
	
	_UTIdebug(( fname, "%s\n", "Flagged Item Found"  ));
 	isflag = 1;
	MEMbuild_array( icat );
	icat_ptr = (char**) icat->data_ptr;

	for( icnt = 0; icnt<(icat->rows*icat->columns); icnt+=icat->columns )
	{
	    fcat  = NULL;
	    sprintf( uti_string, "SELECT n_fileno,n_fileversion,n_archiveno,n_cifilesize,n_cisano,n_cifilename,n_filetype,n_cofilename,n_convertind FROM f_%s WHERE n_itemnum = %d AND n_restoreflag IN ( '%s','%s','%s','%s')", 
	    cat_ptr[ccnt], atoi(icat_ptr[icnt]), 
	    UTI_PENDING_FLAGS[0],UTI_PENDING_FLAGS[1],
	    UTI_PENDING_FLAGS[2], UTI_PENDING_FLAGS[3] );
	    status = SQLquery( uti_string, &fcat, MEM_SIZE );
	    if( status != SQL_S_SUCCESS )
	    {
		MEMclose( &fcat );	
		continue;
	    }
	    MEMbuild_array( fcat );
	    fcat_ptr = (char**) fcat->data_ptr;
	  
            for( fcnt=0; fcnt<(fcat->rows*fcat->columns); fcnt+=fcat->columns )
	    {
	        link_no += 1;
  	        sprintf( uti_string, "%s\1%s\1%s\1%s\1%s\1%d\1",
			 cat_ptr[ccnt], icat_ptr[icnt+1], icat_ptr[icnt+2],
			 fcat_ptr[fcnt+7], icat_ptr[icnt+4], link_no );
  	        status = MEMwrite( chosen, uti_string );
	        if( status != MEM_S_SUCCESS )
	        {
	 	    MEMclose( &cat );
	  	    MEMclose( &icat );
	     	    MEMclose( &fcat );
		    MEMclose( &chosen );
		    return( status );
	        }
 	        /*  Now add a link to the linked list of chosen files.
	         *  This linked list will hang around waiting on the request
  	         *  response which will be a buffer of chosen files represented
	         *  by their link number. The link number will be matched up
	         *  to link numbers in this linked list so that the querys 
	         *  don't have to be performed again.
	         */
	        link = UTImake_list();
	        link->rstr.archive_no = atoi( fcat_ptr[fcnt+2] );
	        link->rstr.storage_no = atoi( fcat_ptr[fcnt+4] );
	        strcpy( link->cat.name, cat_ptr[ccnt] );
	        link->cat.val = atoi( cat_ptr[ccnt+1] );
	        strcpy( link->item.name, icat_ptr[icnt+1] );
	        link->item.val= atoi( icat_ptr[icnt]);
	        link->rev = UTIload( icat_ptr[icnt+2] );
	        link->ver = atoi( fcat_ptr[fcnt+1] );
	        link->file_no = atoi( fcat_ptr[fcnt] );
	        link->state   = link_no;
	        link->set_indicator = UTIload( icat_ptr[icnt+3] );
  	        /*  Find out if this is a project member that is also flagged 
	         */
	        if( (strcmp( icat_ptr[icnt+4], "PR" ) == 0))
	        {
	            status = UTIproject_member( link->cat.val, 
			atol(icat_ptr[icnt]), icat_ptr[icnt+4], &project_no );
	            if( status != UTI_S_SUCCESS )
		        link->project_no = 0;
	            else
   	  	        link->project_no = project_no;
	        }

  	        /*  Get file storage information and true filename according
	         *  to where the file is stored.
	         */
	        status = UTIget_fs_info( link, link->rstr.storage_no );
	        link->size = atoi( fcat_ptr[fcnt+3] );
	        strcpy( link->type.name, fcat_ptr[fcnt+6] );

  	        strcpy( char_utility, "RESTORE" );
  	        if( strlen( fcat_ptr[fcnt+5] ) == 0 )
	            link->ci_file_name = UTIbuild_nfm_name(cat_ptr[ccnt+1],
							 fcat_ptr[fcnt]);
 	        else
		    link->ci_file_name = UTIload( fcat_ptr[fcnt+5] );
                strcpy( link->home.co_file_name, link->ci_file_name );
  	        status = UTIget_rstr_info( link );
	        if( status != UTI_S_SUCCESS )
	        {
	            MEMclose( &cat );
	            MEMclose( &icat );
      	            MEMclose( &fcat );
	            MEMclose( &chosen );		    
	            return( status );
	        }
	        /*  If the format is '2.0.1', this filename was 
	         *  archived or backed up in the old format. The
	         *  file must be accessed in the cpio file with
	         *  the old format but put back on disk in the 
	         *  new format. So get old format name ...
	         */
	        if( ( strcmp( fcat_ptr[fcnt+8], "2.0.1" ) == 0 ) ||
		    ( strcmp( fcat_ptr[fcnt+8], "2.1.0" ) == 0 ))
		{
	            NFMold_file_name(UTIuser_id, atoi(cat_ptr[ccnt+1]),
		                 atoi(fcat_ptr[fcnt]), link->format.name );
		    link->format.val = 2100;
		}
		else if( strcmp(fcat_ptr[fcnt+8], "3.0.0") == 0)
		{
			link->format.val = 3000;
		}
		else if( strcmp(fcat_ptr[fcnt+8], "3.2.0") == 0)
		{
			link->format.val = 3200;
		}
		else
			link->format.val = 0;

	        /*  Add on the link 
	         */
	        if( savedlist == NULL )
	   	     savedlist = listend = link; /* First link */
	        else
	        {
		    listend->next = link;
		    listend = link;
	        }
	        UTIprint_pending_files( link );
	    } /* end 'file_catalog' loop */
	    MEMclose( &fcat );
        } /* end 'item' for-loop */
        MEMclose( &icat );	
    } /* end 'catalog' for-loop */
    MEMclose( &cat );

/*  If no files were flagged -- reset chosen buffer to NULL ( it now has
 *  formats without data if no files were found .
 */

    strcpy( char_utility, "RESTORE" );
    if( !isflag )
    {
	MEMclose( &chosen );
	chosen = NULL;
	_UTIdebug(( fname, "%s\n", "NO FLAGGED FILES FOUND " ));
	ERRload_struct( UTI, UTI_E_NO_FILES_FLAGGED, "%s", char_utility );
      	UTIflist = savedlist;  	/* linked list of files */
    	*file_value = chosen;	/* buffer of requester */
	return(UTI_E_NO_FILES_FLAGGED);
    }

    UTIflist = savedlist;  	/* linked list of files */
    *file_value = chosen;	/* buffer of requester */

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

UTIquery_files_flagged_for_delete( file_value )
    MEMptr	*file_value;
{
    int		link_no     = 0;
    int		ccnt        = 0;
    int		icnt	    = 0;
    int		fcnt	    = 0;
    int		files_cnt   = 0;
    int		isflag      = 0;
    int  	project_no  = 0;
    int		max_version = 0;
   
    long	status;

    char 	char_utility[10];
    char	fmt[NFM_SYNONYM+1];

    char	**cat_ptr;
    char	**icat_ptr;
    char 	**files_ptr;

    MEMptr	chosen= NULL;	/* buffer of chosen file information */
    MEMptr	cat  = NULL;	/* catalog data buffer */
    MEMptr	icat = NULL; 	/* item data buffer */
    MEMptr	fcat = NULL; 	/* f_catalog data buffer */
    MEMptr      files= NULL;    /* files data buffer */

    UTIpending	savedlist = NULL;
    UTIpending  link = NULL;
    UTIpending	listend = NULL;
    UTIpending	UTImake_list();

    char	*UTIbuild_nfm_name();
    
    static	char *fname = "UTIquery_files_flagged_for_delete";

    int first_file = 1;

    _UTIdebug(( fname, "%s\n", "Entering ..." ));
    
    isflag = 0;
    savedlist = listend = NULL;
    UTIflist  = NULL;
    link_no = 0;

    strcpy( uti_string, "SELECT n_catalogname,n_catalogno FROM nfmcatalogs");
    status = SQLquery( uti_string, &cat, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
	ERRload_struct( UTI, UTI_E_QUERYCATALOGS, NULL, NULL );
	return( UTI_E_QUERYCATALOGS );
    }
    
    MEMbuild_array( cat );
    cat_ptr = (char**) cat->data_ptr;

/*  Start buffer to send back to requester 
 */
    status = MEMopen( &chosen, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &chosen );
	MEMclose( &cat );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _UTIdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (NFM_E_MEM);
    }

    sprintf( fmt, "char(%d)", NFM_CATALOGNAME );
    status = MEMwrite_format( chosen, "Catalog Name", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &chosen );
	MEMclose( &cat );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _UTIdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (NFM_E_MEM);
     }

    sprintf( fmt, "char(%d)", NFM_ITEMNAME );
    status = MEMwrite_format( chosen, "Item Name", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &chosen );
	MEMclose( &cat );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _UTIdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (NFM_E_MEM);
    }

    sprintf( fmt, "char(%d)", NFM_ITEMREV );
    status = MEMwrite_format( chosen, "Revision", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &chosen );
	MEMclose( &cat );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _UTIdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (NFM_E_MEM);
    }

    sprintf( fmt, "char(%d)", NFM_PENDINGFLAG );
    status = MEMwrite_format( chosen, "Flag", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &chosen );
	MEMclose( &cat );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _UTIdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (NFM_E_MEM);
    }

    status = MEMwrite_format( chosen, "Link", "char(15)" );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &chosen );
	MEMclose( &cat );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _UTIdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (NFM_E_MEM);
    }

    /*  Loop through all catalogs searching for flagged files 
     */
    for( ccnt=0; ccnt<(cat->rows*cat->columns); ccnt+=cat->columns )
    {
	icat = NULL;
	_UTIdebug(( fname, "Query Catalog <%s>\n", cat_ptr[ccnt] ));

 	sprintf( uti_string, "SELECT n_itemno,n_itemname,n_itemrev,n_setindicator,n_pendingflag FROM %s WHERE n_pendingflag IN ( '%s','%s','%s','%s')",
	 cat_ptr[ccnt], UTI_PENDING_FLAGS[0],UTI_PENDING_FLAGS[1], 
	 UTI_PENDING_FLAGS[2], UTI_PENDING_FLAGS[3]);

	status = SQLquery( uti_string, &icat, MEM_SIZE );
	if( status != SQL_S_SUCCESS )
	{
	    MEMclose( &icat );
	    _UTIdebug((fname, "NO flags for catalog <%s>\n",cat_ptr[ccnt] ));
	    continue;	
	}
	
	MEMbuild_array( icat );
	icat_ptr = (char**) icat->data_ptr;

	for( icnt = 0; icnt<(icat->rows*icat->columns); icnt+=icat->columns )
	{
	    fcat  = NULL;
	/** Get all the files attached to itemnumber (all versions) **/
	    files = NULL;
	    sprintf( uti_string, "SELECT MAX(n_fileversion) FROM f_%s WHERE n_itemnum = %s", cat_ptr[ccnt], icat_ptr[icnt] );

  	    status = SQLquery( uti_string, &files, MEM_SIZE );
	    if( status != SQL_S_SUCCESS )
	    {
	        _UTIdebug(( fname, "Get MAX version faild, itemnum: <%d>, f_catalog: f_%s \n", icat_ptr[icnt] ));
	   	MEMclose( &files );	
	        continue;
	    }
	    MEMbuild_array( files );
	    files_ptr = (char **)files->data_ptr;
      	    max_version = atoi(files_ptr[0]);
	    MEMclose(&files);

	    sprintf( uti_string, "SELECT n_archiveno,n_cifilesize,n_cisano,n_cifilename,n_filetype,n_cofilename,n_convertind,n_fileno,n_fileversion,n_filenum, n_fileco FROM f_%s WHERE n_itemnum = %s ORDER BY n_fileversion, n_filenum", cat_ptr[ccnt], icat_ptr[icnt] );

  	    status = SQLquery( uti_string, &files, MEM_SIZE );
	    if( status != SQL_S_SUCCESS )
	    {
	   	MEMclose( &files );	
	        continue;
	    }
	    MEMbuild_array( files );

	    isflag = 1;
	    _UTIdebug(( fname, "%s\n", "Flagged File Found" ));
	    files_ptr = (char**) files->data_ptr;
	 
	    first_file = 1;
            for( files_cnt=0; files_cnt<(files->rows*files->columns); 
	   	     files_cnt+=files->columns )
	    {
		if(first_file)
	 	{
		    first_file = 0;
    	            link_no += 1;
  	            sprintf( uti_string, "%s\1%s\1%s\1%s\1%d\1",
	  	           cat_ptr[ccnt], icat_ptr[icnt+1], icat_ptr[icnt+2],
		  	   icat_ptr[icnt+4], link_no );
  	            status = MEMwrite( chosen, uti_string );
	            if( status != MEM_S_SUCCESS )
	            {
 	 	     	MEMclose( &cat );
    	  	        MEMclose( &icat );
	             	MEMclose( &fcat );
		        MEMclose( &chosen );
			MEMclose( &files );
			ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
		        return( NFM_E_MEM );
	             }
		}

 	        /*  Now add a link to the linked list of chosen files.
	         *  This linked list will hang around waiting on the request
  	         *  response which will be a buffer of chosen files represented
	         *  by their link number. The link number will be matched up
	         *  to link numbers in this linked list so that the querys 
	         *  don't have to be performed again.
	         */
	        link = UTImake_list();
	        link->rstr.archive_no = atoi( files_ptr[files_cnt] );
	        link->rstr.storage_no = atoi( files_ptr[files_cnt+2] );
	        strcpy( link->cat.name, cat_ptr[ccnt] );
	        link->cat.val = atoi( cat_ptr[ccnt+1] );
	        strcpy( link->item.name, icat_ptr[icnt+1] );
	        link->item.val= atoi( icat_ptr[icnt] );
	        link->rev = UTIload( icat_ptr[icnt+2] );
	        link->ver = atoi( files_ptr[files_cnt+8] );
	        link->file_no = atoi( files_ptr[files_cnt+7] );
	        link->state   = link_no;
	        link->set_indicator = UTIload( icat_ptr[icnt+3] );

  	        /*  Get file storage information and true filename according
	         *  to where the file is stored.
	         */
	        status = UTIget_fs_info( link, link->rstr.storage_no );

		if(strcmp(files_ptr[files_cnt+10], "O")==0)
		{
	    	    _UTIdebug(( fname, "f_%s: fileno <%s> has been purged\n",
				cat_ptr[ccnt], files_ptr[files_cnt+7]));
	            link->size = -999; /** Magic number indicates that the file
					   has been purged **/
		}
		else
	            link->size = atoi( files_ptr[files_cnt+1] );
	        strcpy( link->type.name, files_ptr[files_cnt+4] );
       
                strcpy( char_utility, "DELETE" );

   		if((strlen( files_ptr[files_cnt+3] ) == 0 ) ||
		    (max_version > link->ver))
		{
	            link->ci_file_name = 
 		    UTIbuild_nfm_name(cat_ptr[ccnt+1],files_ptr[files_cnt+7] );
		}
		else
		    link->ci_file_name = UTIload( files_ptr[files_cnt+3] );

 		strcpy( link->home.co_file_name,
 		    UTIbuild_nfm_name( cat_ptr[ccnt+1],files_ptr[files_cnt+7]));
  
	       /*  Add on the link 
	       */
	       if( savedlist == NULL )
	           savedlist = listend = link; /* First link */
	       else
	       {
		   listend->next = link;
		   listend = link;
	       }
	       UTIprint_pending_files( link );
	    }/** end 'file' for-loop **/
	    MEMclose( &files );
	    MEMclose( &fcat );
        } /* end 'item' for-loop */
        MEMclose( &icat );	
    } /* end 'catalog' for-loop */
    MEMclose( &cat );

/*  If no files were flagged -- reset chosen buffer to NULL ( it now has
 *  formats without data if no files were found .
 */
    strcpy( char_utility, "DELETE" );
    if( !isflag )
    {
	MEMclose( &chosen );
	chosen = NULL;
	_UTIdebug(( fname, "%s\n", "NO FLAGGED FILES FOUND " ));
	ERRload_struct( UTI, UTI_E_NO_FILES_FLAGGED, "%s", char_utility);
    	UTIflist = savedlist;  	/* linked list of files */
    	*file_value = chosen;	/* buffer of requester */
	return(UTI_E_NO_FILES_FLAGGED);
    }

    UTIflist = savedlist;  	/* linked list of files */
    *file_value = chosen;	/* buffer of requester */

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

/*  This routine generates the file storage information needed 
 *  using the input storage area, filename, and table number.
 */

UTIget_fs_info( flist, sa_no )
    UTIpending flist;
    int        sa_no;
{
    int    node_no;
    long   status;

    char   **data_ptr;

    MEMptr sql_buffer = NULL;

    static char *fname = "UTIget_fs_info";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    sprintf( uti_string, 
	     "SELECT n_nodeno, n_username, n_passwd, n_pathname,n_devicetype FROM nfmstoragearea WHERE n_sano = %d", sa_no );
    status = SQLquery( uti_string, &sql_buffer, MEM_SIZE );
    if( status != SQL_S_SUCCESS ) 
    {
	MEMclose( &sql_buffer );
	ERRload_struct( UTI, UTI_E_QUERYSA, "%d", sa_no );
	return( UTI_E_QUERYSA );
    }
    MEMbuild_array( sql_buffer );

    data_ptr = (char**) sql_buffer->data_ptr;
    node_no  = atoi( data_ptr[0] );
    strcpy( flist->home.user_name,   data_ptr[1] );
    strcpy( flist->home.passwd,      data_ptr[2] );
    strcpy( flist->home.path,        data_ptr[3] );
    strcpy( flist->home.device_type, data_ptr[4] );
    flist->home.sano = sa_no;
    MEMclose( &sql_buffer );

/*  Get information from nodes table 
 */    

    sprintf( uti_string,"SELECT n_nodename,n_opsys,n_machid,n_xns,n_tcpip,n_decnet,n_netware,n_nfs FROM nfmnodes where n_nodeno = %d", node_no );
    status = SQLquery( uti_string, &sql_buffer, MEM_SIZE );
    if( status != SQL_S_SUCCESS ) 
    {
	MEMclose( &sql_buffer );
	ERRload_struct( UTI, UTI_E_QUERYNODE, "%d", node_no );
	return( UTI_E_QUERYNODE );
    }
    MEMbuild_array( sql_buffer );

    data_ptr = (char**) sql_buffer->data_ptr;
    strcpy( flist->home.node_name, data_ptr[0] );
    strcpy( flist->home.op_sys,    data_ptr[1] );  
    strcpy( flist->home.mach_id,   data_ptr[2] );
    flist->home.protocol =
	 UTIset_protocol( data_ptr[3], data_ptr[4], data_ptr[5], data_ptr[6],
			  data_ptr[7] );
    UTIgood_path( flist->home.path, flist->home.op_sys );

    UTIprint_fs( flist->home );

    MEMclose( &sql_buffer );

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}
/*  This routine returns the next restore group_no
 */
UTIget_rstr_no()
{
    long	status;

    char	**data_ptr;

    MEMptr	sql_buffer = NULL;

    static	char *fname = "UTIget_rstr_no";
 
    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    strcpy( uti_string, "SELECT MAX(n_restoreno) FROM nfmsavesets" );
    status = SQLquery( uti_string, &sql_buffer, MEM_SIZE );
    if( status != SQL_S_SUCCESS ) 
    {
	MEMclose( &sql_buffer );
	UTI_GROUP_NO = 0;
	return( UTI_S_SUCCESS );
    }
    MEMbuild_array( sql_buffer );

    data_ptr = (char**) sql_buffer->data_ptr;
    UTI_GROUP_NO = atoi( data_ptr[0] );

    MEMclose( &sql_buffer );

    _UTIdebug(( fname, "UTI_GROUP_NO <%d>\n",UTI_GROUP_NO ));

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

/*  This routine generates the restore information needed 
 */
UTIget_rstr_info( flist )
    UTIpending flist;
{
    long	status;

    char	**data_ptr;

    MEMptr	sql_buffer = NULL;

    static	char *fname = "UTIget_rstr_info";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

/*  Get label, saveset and storagearea number 
 */
    sprintf( uti_string, "SELECT n_label, n_saveset, n_sano FROM nfmarchives WHERE n_archiveno = %d", flist->rstr.archive_no );
    status = SQLquery( uti_string, &sql_buffer, MEM_SIZE );
    if( status != SQL_S_SUCCESS ) 
    {
	MEMclose( &sql_buffer );
	ERRload_struct( UTI, UTI_E_QUERYLS, NULL, NULL );
	return( UTI_E_QUERYLS );
    }
    MEMbuild_array( sql_buffer );

    data_ptr = (char**) sql_buffer->data_ptr;
    flist->label 	   = UTIload( data_ptr[0] );
    flist->saveset	   = UTIload( data_ptr[1] );
    flist->rstr.storage_no = atoi( data_ptr[2] );
    MEMclose( &sql_buffer );

/*  Get node number
 */
    sprintf(uti_string,"SELECT n_nodeno,n_devicetype FROM nfmstoragearea WHERE n_sano = %d",flist->rstr.storage_no );
    status = SQLquery( uti_string, &sql_buffer, MEM_SIZE );
    if( status != SQL_S_SUCCESS ) 
    {
	MEMclose( &sql_buffer );
	ERRload_struct( UTI, UTI_E_QUERYSA, "%d", flist->rstr.storage_no );
	return( UTI_E_QUERYSA );
    }
    MEMbuild_array( sql_buffer );

    data_ptr = (char**) sql_buffer->data_ptr;
    flist->node.val = atoi( data_ptr[0] );
/*  If OFF-LINE devicetype, change storage_no to -(storage_no) 
 */
    if( ( strcmp( data_ptr[1], "MT" )) == 0 ||
	( strcmp( data_ptr[1], "UT" )) == 0 ||
	( strcmp( data_ptr[1], "CT" )) == 0 ||
	( strcmp( data_ptr[1], "TJ" )) == 0 ||
	( strcmp( data_ptr[1], "FD" )) == 0 )
	flist->rstr.storage_no = -(flist->rstr.storage_no);

    MEMclose( &sql_buffer );

/*  Get node number
 */
    sprintf(uti_string,"SELECT n_nodename FROM nfmnodes WHERE n_nodeno = %d",
	    flist->node.val );
    status = SQLquery( uti_string, &sql_buffer, MEM_SIZE );
    if( status != SQL_S_SUCCESS ) 
    {
	MEMclose( &sql_buffer );
	ERRload_struct( UTI, UTI_E_QUERYNODE, "%d", flist->node.val );
	return( UTI_E_QUERYNODE );
    }
    MEMbuild_array( sql_buffer );

    data_ptr = (char**) sql_buffer->data_ptr;
    strcpy( flist->node.name, data_ptr[0] );

    MEMclose( &sql_buffer );

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

/* This routine returns all vital information concerning an archive
 * that is necessary to restore a file from that archive.
 */

UTIreturn_NFMarchives( archive_no, nfmrec, utirec  )
    int     archive_no;
    NFMarch *nfmrec;
    UTIarch *utirec;
{
    int	    node_no;

    long    status;

    char    uti_string[256];  
    char    **data_ptr1;
    char    **data_ptr2;

    NFMarch nfmloc = NULL;
    UTIarch utiloc = NULL;

    MEMptr buffer1 = NULL;
    MEMptr buffer2 = NULL;

    static char *fname = "UTIreturn_NFMarchives";

    _UTIdebug(( fname, "archive_no <%d>\n", archive_no ));

    sprintf( uti_string, "SELECT n_label,n_saveset,n_sano,n_archivedate,n_novol,n_archivecopies,n_archivesize,n_archivemethod FROM nfmarchives WHERE n_archiveno = %d", archive_no );
    status = SQLquery( uti_string, &buffer1, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
	MEMclose( &buffer1 );
 	ERRload_struct( UTI, UTI_E_QUERYARCHIVES, "%d", archive_no);
	return( UTI_E_QUERYARCHIVES );
    }
    MEMbuild_array( buffer1 );
    data_ptr1 = (char**)buffer1->data_ptr;

    nfmloc 	           = (NFMarch) malloc( sizeof( struct nfmarchives ));
    nfmloc->archive_no	   = archive_no;
    nfmloc->label          = UTIload( data_ptr1[0] );
    nfmloc->saveset        = UTIload( data_ptr1[1] );
    nfmloc->storageno	   = atoi( data_ptr1[2] );
    nfmloc->archive_date   = UTIload( data_ptr1[3] );
    nfmloc->archive_method = UTIload( data_ptr1[7] );
    nfmloc->archive_copies = atoi( data_ptr1[5] );
    nfmloc->archive_size   = atoi( data_ptr1[6] );
    nfmloc->no_vol         = atoi( data_ptr1[4] );
   
    MEMclose( &buffer1 );

    sprintf( uti_string, "SELECT n_nodeno,n_username,n_passwd,n_devicetype,n_pathname FROM nfmstoragearea WHERE n_sano = %d", nfmloc->storageno );
    status = SQLquery( uti_string, &buffer1, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
 	ERRload_struct( UTI, UTI_E_QUERYSA, "%d", nfmloc->storageno );
	MEMclose( &buffer1 );
	return( UTI_E_QUERYSA );
    }
    MEMbuild_array( buffer1 );
    data_ptr1 = (char**)buffer1->data_ptr;
    node_no = atoi( data_ptr1[0] );

    sprintf( uti_string, "SELECT n_nodename,n_tcpip,n_xns,n_decnet,n_opsys,n_netware,n_nfs FROM nfmnodes WHERE n_nodeno = %d", node_no );
    status = SQLquery( uti_string, &buffer2, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
 	ERRload_struct( UTI, UTI_E_QUERYNODE, "%d", node_no );
	MEMclose( &buffer1 );
	MEMclose( &buffer2 );
	return( UTI_E_QUERYNODE );
    }
    MEMbuild_array( buffer2 );
    data_ptr2 = (char**)buffer2->data_ptr;

    utiloc		   = (UTIarch)malloc( sizeof( struct archive_loc) );
    utiloc->label	   = UTIload( nfmloc->label );
    utiloc->saveset	   = UTIload( nfmloc->saveset );
    strcpy( utiloc->node.name, data_ptr2[0] );
    utiloc->node.val	   = node_no;
    utiloc->user_name      = UTIload( data_ptr1[1] );
    utiloc->password  	   = UTIload( data_ptr1[2] );
    utiloc->path_name	   = UTIgood_path( data_ptr1[4], data_ptr2[4] );
    nfmloc->archive_path   = UTIload( data_ptr1[4] );
    utiloc->device_type    = UTIload( data_ptr1[3] );
    utiloc->device_name    = UTIload( data_ptr1[4] );
    utiloc->op_sys	   = UTIload( data_ptr2[4] );
    utiloc->protocol	   = UTIset_protocol( data_ptr2[1],data_ptr2[2], 
			      data_ptr2[3], data_ptr2[5], data_ptr2[6] );
    strcpy( UTI_ARCHIVE_OPSYS, data_ptr2[4] );

    MEMclose( &buffer1 );
    MEMclose( &buffer2 );

    if( OFF_LINE )
    {
        sprintf( uti_string, "SELECT n_sano,n_pathname FROM nfmstoragearea WHERE n_nodeno = %d and n_saname = '%d-UTIL'",node_no, node_no );
        status = SQLquery( uti_string, &buffer2, MEM_SIZE );
        if( status != SQL_S_SUCCESS )
        {
     	    ERRload_struct( UTI, UTI_E_QUERYSA, "%d", node_no );
	    MEMclose( &buffer2 );
	    return( UTI_E_QUERYSA );
        }

        MEMbuild_array( buffer2 );
        data_ptr2 = (char**)buffer2->data_ptr;
        UTI_CLIENT_SA = atol( data_ptr2[0] );
        strcpy( UTI_CLIENT_PATH, data_ptr2[1] );
	if( strcmp( UTI_ARCHIVE_OPSYS, "VMS" ) != 0 )
   	    strcat( UTI_CLIENT_PATH, "/" );
        _UTIdebug(( fname, "UTI_CLIENT_SA : <%ld>\n", UTI_CLIENT_SA ));
        _UTIdebug(( fname, "UTI_CLIENT_PATH : <%s>\n", UTI_CLIENT_PATH));
        MEMclose( &buffer2 );
    }

    UTIupcase( utiloc->device_type );
    UTIupcase( utiloc->op_sys );
    
    UTIprint_nfmarchives( nfmloc );
    UTIprint_archive_loc( utiloc );

    *nfmrec = nfmloc;
    *utirec = utiloc;

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}
/*  This routine sets globals depending on the device type
 */
UTIget_device_type( type )
    char  *type;
{

    static char *fname = "UTIget_device_type";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    if( strcmp( type, "MT" ) == 0 )
    {
	UTI_MTAPE = 1;
	UTI_MEDIA = M_TAPE;
    }
    else if( strcmp( type, "UT" ) == 0 )
    {
	UTI_UTAPE = 1;
	UTI_MEDIA = U_TAPE;
    }
    else if( strcmp( type, "CT" ) == 0 )
    {
	UTI_CTAPE = 1;
	UTI_MEDIA = C_TAPE;
    }
    else if( strcmp( type, "OD" ) == 0 )
    {
	UTI_ODISK = 1;
	UTI_MEDIA = O_DISK;
    }
    else if( strcmp( type, "MO" ) == 0 )
    {
	UTI_JBOX = 1;
	UTI_MEDIA = JUKE_BOX;
    }
    else if( strcmp( type, "WR" ) == 0 )
    {
	UTI_JBOX = 1;
	UTI_MEDIA = JUKE_BOX;
    }
    else if( strcmp( type, "FD" ) == 0 )
    {
	UTI_FDISK = 1;
	UTI_MEDIA = F_DISK;
    }
    else if( strcmp( type, "HD" ) == 0 )
    {
	UTI_HDISK = 1;
	UTI_MEDIA = H_DISK;
    }
    else if( strcmp( type, "CA" ) == 0 )
    {
	UTI_CACHE = 1;
	UTI_MEDIA = CACHE;
    }
    else if( strcmp( type, "TJ" ) == 0 )
    {
	UTI_UTAPE = 1;
	UTI_MEDIA = TJB;
    }

    _UTIdebug(( fname, "UTI_MEDIA <%d>\n", UTI_MEDIA )); 
    _UTIdebug(( fname, "device_type <%s>\n", type));    

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}
/*  This routine finds the entries in the nfmsavesets table with
 *  the same group_no with a matching 'utility pending' status.
 *  A list is built using the found members.
 */
UTIfind_group_members( group_no, flist, flag )
    int 	group_no;
    UTIpending  *flist;
    char	flag;
{
    int 	status;
    int		tot_data;
    int 	i;

    char	**data_ptr;

    UTIpending  savedlist;
    UTIpending  link;
    UTIpending  listend;
    UTIpending  UTImake_list();
  
    MEMptr	buffer = NULL;

    static	char *fname = "UTIfind_group_members";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    savedlist = listend = NULL;

    if( ( flag == 'A' ) || ( flag == 'B' ) )
    {
        sprintf( uti_string, 
	     "SELECT n_catalogno,n_itemno,n_fileno,n_archiveno FROM nfmsavesets WHERE n_archiveno = %d AND n_itemstate = 'P'",group_no );
    }
    else
    {
        sprintf( uti_string, 
	     "SELECT n_catalogno,n_itemno,n_fileno,n_archiveno FROM nfmsavesets WHERE n_restoreno = %d AND n_itemstate = 'P'",group_no );
    }
    status = SQLquery( uti_string, &buffer, MEM_SIZE );
    if( status != SQL_S_SUCCESS ) 
    {
	MEMclose( &buffer );
	ERRload_struct( UTI, UTI_E_QUERY_SAVESET_GROUP, "%d", group_no );
	return( UTI_E_QUERY_SAVESET_GROUP );
    }
    status = MEMbuild_array( buffer );
    data_ptr = (char**)buffer->data_ptr;
    tot_data = buffer->rows * buffer->columns;
    
    for( i=0; i<tot_data; i+=buffer->columns )
    {
        link = UTImake_list();
	link->ver = 1 ; /** Not a real version, 
				but to make UTIdelete_files work !!! **/
	link->rstr.restore_no = group_no;

        _UTIdebug((fname, "restoreno <%s>\n", link->rstr.restore_no));
        _NFMdebug((fname, "restoreno <%s>\n", link->rstr.restore_no));

  	link->cat.val = atoi( data_ptr[i] );
	status = UTIget_catalog_name( link->cat.val, link->cat.name );
	if( status != UTI_S_SUCCESS )
	{	
	    MEMclose( &buffer );	
	    return( status );
	}
        link->item.val= atoi( data_ptr[i+1] );
	link->file_no = atoi( data_ptr[i+2] );
	link->rstr.archive_no = atoi( data_ptr[i+3] );
 
        _UTIdebug((fname, "archiveno <%s>\n", link->rstr.archive_no));
        _NFMdebug((fname, "archiveno <%s>\n", link->rstr.archive_no));

	status = UTIget_pending_info( link,flag );
	if( status != UTI_S_SUCCESS )
	{	
	    MEMclose( &buffer );	
	    return( status );
	}
	UTIprint_pending_files( link );

	if( savedlist == NULL )
	    savedlist = listend = link;
	else
	{
	    listend->next = link;
	    listend = link;
	}
	_UTIdebug((fname, "filename <%s>\n", link->ci_file_name));
	_NFMdebug((fname, "filename <%s>\n", link->ci_file_name));
    }
    *flist = savedlist;

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}
/*  This routine retrieves a catalog name given a catalog number
 */
UTIget_catalog_name( catalog_no, catalog_name )
    int 	catalog_no;
    char	*catalog_name;
{
    long	status;
    char	**data;
    MEMptr	buffer = NULL;

    static	char *fname = "UTIget_catalog_name";

    _UTIdebug(( fname, "catalog_no <%d>\n", catalog_no ));

    sprintf( uti_string,
	     "SELECT n_tablename from nfmtables where n_tableno=%d",
	     catalog_no );
    status = SQLquery( uti_string, &buffer, MEM_SIZE );
    if( status != SQL_S_SUCCESS ) 
    {
	MEMclose( &buffer );
	ERRload_struct( UTI, UTI_E_GET_CATALOG_NAME, "%d", catalog_no);
	return( UTI_E_GET_CATALOG_NAME );
    }
    status = MEMbuild_array( buffer );
    data   = (char**)buffer->data_ptr;
    strcpy( catalog_name, data[0] );
    MEMclose( &buffer );

    _UTIdebug(( fname, "catalog_name <%s>\n", catalog_name ));

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

/*  This routine rebuilds buffer information about pending files that
 *  need to be transferred.
 */
UTIget_pending_info( link, flag )
    UTIpending  link;
    char	flag;
{
    long	status;

    char	a_cisano[20];
    char 	a_fileno[20];
    char	*UTIbuild_nfm_name();
    char	**data_ptr;
    MEMptr	buffer = NULL;

    static	char *fname = "UTIget_pending_info";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    sprintf( uti_string,"SELECT f_%s.n_cisano,f_%s.n_cifilename,f_%s.n_filetype,f_%s.n_cofilename,f_%s.n_cifilesize,f_%s.n_convertind FROM f_%s,%s WHERE %s.n_pendingflag IN ('p%c') AND f_%s.n_fileno = %d AND f_%s.n_itemnum=%s.n_itemno",
	link->cat.name, link->cat.name, link->cat.name, link->cat.name,
	link->cat.name, link->cat.name, link->cat.name, link->cat.name,
	link->cat.name, flag, link->cat.name, link->file_no,
	link->cat.name, link->cat.name);
    status = SQLquery( uti_string, &buffer, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
	_UTIdebug(( fname, "Failed SQL for file <%d>\n",link->file_no ));
        MEMclose( &buffer );
	ERRload_struct( UTI, UTI_E_FSINFO, "%d", link->file_no );
	return( UTI_E_FSINFO );
    }
    MEMbuild_array( buffer );

    data_ptr = (char**)buffer->data_ptr;
    link->home.sano       = atoi( data_ptr[0] );
    sprintf( a_cisano, "%d", link->cat.val );
    sprintf( a_fileno, "%d", link->file_no );

    if( strlen( data_ptr[1] ) == 0 )
        link->ci_file_name    = UTIbuild_nfm_name( a_cisano, a_fileno );
    else
	link->ci_file_name    = UTIload( data_ptr[1] );

    strcpy( link->type.name,  data_ptr[2] );

    /** Changed this to put encrypted file_name always --Dontu in 3.1.0.7 
	strcpy( link->home.co_file_name, link->ci_file_name );**/

        strcpy(link->home.co_file_name,UTIbuild_nfm_name( a_cisano, a_fileno ));

    link->size = atoi( data_ptr[4] );

    /*  If the n_convertind attribute has a value, the old filename
     *  format may be needed.
     */
    if( (strcmp(data_ptr[5], "2.1.0") == 0) || 
	(strcmp(data_ptr[5], "2.0.1") == 0))
    {
        NFMold_file_name( UTIuser_id, atoi(a_cisano),
                          atoi(a_fileno), link->format.name );
	link->format.val = 2100;
    }
    else if(strcmp(data_ptr[5], "3.0.0") == 0)
    {
	link->format.val = 3000;	
    }
    else if(strcmp(data_ptr[5], "3.2.0") == 0)
    {
	link->format.val = 3200;	
    }
    else
	link->format.val = 0;
    
    MEMclose( &buffer );

    sprintf( uti_string, "SELECT n_nodeno,n_username,n_passwd,n_devicetype,n_pathname FROM nfmstoragearea WHERE n_sano = %d",link->home.sano );
    status = SQLquery( uti_string, &buffer, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
	MEMclose( &buffer );
	ERRload_struct( UTI, UTI_E_QUERYSA, "%d", link->home.sano );
	return( UTI_E_QUERYSA );
    }
    MEMbuild_array( buffer );

    data_ptr = (char**)buffer->data_ptr;
    link->node.val =        atoi(  data_ptr[0] );
    strcpy( link->home.user_name,  data_ptr[1] );
    strcpy( link->home.passwd,     data_ptr[2] );
    strcpy( link->home.device_type,data_ptr[3] );
    strcpy( link->home.path,	   data_ptr[4] );
    MEMclose( &buffer );

    sprintf( uti_string,"SELECT n_nodename,n_tcpip,n_xns,n_decnet,n_opsys,n_machid,n_netware,n_nfs FROM nfmnodes WHERE n_nodeno = %d",link->node.val );
    status = SQLquery( uti_string, &buffer, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
	MEMclose( &buffer );
	ERRload_struct( UTI, UTI_E_QUERYNODE, "%d", link->node.val );
	return( UTI_E_QUERYNODE );
    }
    MEMbuild_array( buffer );
    data_ptr = (char**)buffer->data_ptr;
    strcpy( link->home.node_name, data_ptr[0] );
    strcpy( link->home.op_sys,    data_ptr[4] );
    link->home.protocol = UTIset_protocol(data_ptr[2],data_ptr[1],data_ptr[3],
					  data_ptr[6],data_ptr[7]);
    strcpy( link->home.mach_id,   data_ptr[5] );
    MEMclose( &buffer );

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

/*  This routine returns the storage area number corresponding to the
 *  input group number.
 */
UTIget_client_sa( group_no, utility )
    int	group_no;
    int utility;
{
    int		nodeno;
    int		sano;

    long	status;

    char	**data_ptr;
    MEMptr	buffer = NULL;
		
    static	char *fname = "UTIget_client_sa";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    if( ( utility == UTIarchive ) || ( utility == UTIbackup ) )
    {
        sprintf( uti_string, "SELECT n_sano FROM nfmarchives WHERE n_archvieno = %d", group_no );
    }
    else 
    {
        sprintf( uti_string, "SELECT n_sano FROM nfmarchives WHERE n_archiveno = (SELECT n_archiveno FROM nfmsavesets WHERE n_restoreno = %d)", group_no );
    }
    status = SQLquery( uti_string, &buffer, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
        MEMclose( &buffer );
	ERRload_struct( UTI, UTI_E_FSINFO, "%d", group_no );
	return( UTI_E_FSINFO );
    }
    MEMbuild_array( buffer );
    data_ptr      = (char**)buffer->data_ptr;
    sano = atoi( data_ptr[0] );
    MEMclose( &buffer );

    sprintf( uti_string, "SELECT n_nodeno FROM nfmstoragearea WHERE n_sano = %d", sano );
    status = SQLquery( uti_string, &buffer, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
        MEMclose( &buffer );
	ERRload_struct( UTI, UTI_E_FSINFO, "%d", sano );
	return( UTI_E_FSINFO );
    }
    MEMbuild_array( buffer );
    data_ptr      = (char**)buffer->data_ptr;
    nodeno = atoi( data_ptr[0] );
    MEMclose( &buffer );

    sprintf( uti_string, "SELECT n_sano FROM nfmstoragearea WHERE n_saname = '%d-UTIL'",nodeno );
    status = SQLquery( uti_string, &buffer, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
        MEMclose( &buffer );
	ERRload_struct( UTI, UTI_E_FSINFO, "%d", group_no );
	return( UTI_E_FSINFO );
    }
    MEMbuild_array( buffer );
    data_ptr      = (char**)buffer->data_ptr;
    UTI_CLIENT_SA = atoi( data_ptr[0] );
    MEMclose( &buffer );

    _UTIdebug(( fname, "UTI_CLIENT_SA : <%d>\n", UTI_CLIENT_SA ));

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

/*  This routine returns a project number if this catalog_no, item_no
 *  is in the nfmprojectcit table.
 */
UTIproject_member( catalog_no, item_no, flag, project_no )
    int  catalog_no;
    int  item_no;
    char *flag;
    int  *project_no;
{
    long	status;
    char        tmp_flag[2];
    char	**data_ptr;
    MEMptr	buffer = NULL;
		
    static	char *fname = "UTIproject_member";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    strcpy( tmp_flag, "" );
    if( strcmp( flag, "PA" ) == 0 )
	strcpy( tmp_flag, "A" );
    else if( strcmp( flag, "PB" ) == 0 )
	strcpy( tmp_flag, "B" );
    else if( strcmp( flag, "PR" ) == 0 )
	strcpy( tmp_flag, "R" );

    sprintf( uti_string, "SELECT n_projectno FROM nfmprojectcit WHERE n_catalogno = %d AND n_itemno = %d AND n_archiveflag = '%s'",
	catalog_no, item_no, tmp_flag);
    status = SQLquery( uti_string, &buffer, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
        MEMclose( &buffer );
	return( status );
    }
    MEMbuild_array( buffer );
    data_ptr      = (char**)buffer->data_ptr;
    *project_no = atoi( data_ptr[0] );
    MEMclose( &buffer );

    _UTIdebug(( fname, "Project Number <%d>\n", *project_no ));

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}
