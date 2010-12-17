#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "MEMstruct.h"
#include "UTIstruct.h"
#include "UTIerrordef.h"
#include "UTIglobals.h"
#include "UTIdef.h"
#include "ERR.h"
#include "MSGstruct.h"
#include "DEBUG.h"

#define BUFFER_SIZE 1000

/** Delete this **/
#define UTI_E_UPDSAFILES 999 
/*******************/

char	uti_string[1024];

/*  This routine updates the f_catalog tables for each file successfully
 *  operated on.
 */
UTIupdate_f_catalog( utility, flist )
    int		utility;
    UTIpending  flist;
{
    long	status;
    int		i, current_item =-1, file_purged=0;
    int		max_fileno, new_fileno, sano = 0;
    int		max_version, file_max_version = -1;
    char	**data, **f_data, **data2;

    MEMptr	buffer = NULL, rename = NULL, buffer2 = NULL;
    
    static	char *fname = "UTIupdate_f_catalog";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    current_item = -1;   /** These are used only while restoring **/
    max_version = -1;
    file_max_version = -1;
    while( flist != NULL )
    {
	if( flist->state != -1)
	{

	    if( ( utility == UTIarchive ) || ( utility == UTIarchive_p ))
	    {
	        sprintf( uti_string,
		"UPDATE f_%s SET n_archiveno = %d,n_convertind = '3.2.0',n_fileco='O' WHERE n_fileno = %d", flist->cat.name,flist->rstr.archive_no,flist->file_no);

	    }
	    else if( ( utility == UTIbackup ) || ( utility == UTIbackup_p) )
	    {
	        sprintf( uti_string,
		"UPDATE f_%s SET n_archiveno = %d,n_convertind = '3.2.0' WHERE n_fileno = %d", flist->cat.name,flist->rstr.archive_no,flist->file_no);

/**IMPORTANT	Take n_convertind 3.2.0 indicates that the archive has been 
		done after version NFM 3.2.0
***/ 
	    }
   	    else if( utility == UTIrestore )
	    {
/*************************************************************************
 NAVAIR We don't want to differentiate archives from backups --11/19/92 -DONTU

	      sprintf( uti_string, "SELECT n_archivestate FROM %s WHERE (n_itemno = %d) AND (n_archivestate = 'A')", flist->cat.name, flist->item.val);
	      status = SQLquery( uti_string, &buffer, BUFFER_SIZE );
 	      if( (status != SQL_S_SUCCESS) &&
	          (status != SQL_I_NO_ROWS_FOUND) )
	      {
	       	MEMclose (&buffer);
	        ERRload_struct( UTI, UTI_E_UPDFCATALOG, "%s",
		    			flist->item.name );
		return( UTI_E_UPDFCATALOG );
	      }
	      MEMclose(&buffer);

	      if(status == SQL_S_SUCCESS)/ ** Restore from ARCHIVE ** /
	      {
                / **Just update f_catalog entry and return** /
	        sprintf( uti_string,
		"UPDATE f_%s SET n_restoreflag = '',n_fileco='N' WHERE n_archiveno = %d AND n_fileno = %d", flist->cat.name, flist->rstr.archive_no,flist->file_no);

               / ********** Executed down stairs
               	status = SQLstmt( uti_string );
                if( status != SQL_S_SUCCESS )
                {
                  ERRload_struct( UTI, UTI_E_UPDFCATALOG, "%s",
                                       flist->item.name );
                  return( UTI_E_UPDFCATALOG );
                }
		*********** /

                  / ** Move latest ci_files to encrypted ** /
                  sprintf( uti_string, "SELECT n_cifilename, n_cisano FROM f_%s WHERE n_fileno = %d", flist->file_no);		

                  status = SQLquery( uti_string, &buffer2, BUFFER_SIZE );
                  if( status != SQL_S_SUCCESS )
                  {
                    MEMclose (&buffer);
                    ERRload_struct( UTI, UTI_E_UPDFCATALOG, "%s",
                                         flist->item.name );
                    return( UTI_E_UPDFCATALOG );
                  }
                  MEMbuild_array (buffer2);
                  data2 = (char **) buffer2->data_ptr;
	************************************************************ /

		/ ** Move encrypted to user given ** /
		if(strcmp(flist->ci_file_name, "") != 0)
		{
                  _UTIdebug((fname, "Prepare Move <%s> to <%s> in <%d>\n",
		  flist->home.co_file_name, flist->ci_file_name, 
		  flist->home.sano));
                  status = UTIcopy_f1_to_f2(flist->home.sano, 
					    flist->home.co_file_name,
					    flist->ci_file_name, &rename, 1);
		  if(status != NFM_S_SUCCESS)
		  {
                    _UTIdebug((fname, "Move <%s> to <%s> failed in <%d>\n",
			  flist->home.co_file_name, flist->ci_file_name,
			  flist->home.sano));
                    ERRload_struct( UTI, UTI_E_UPDFCATALOG, "%s",
                                                flist->item.name );
                    return( UTI_E_UPDFCATALOG );
		  }
		}
              } / ** Restore from ARCHIVE ** /	
              else
              {
******************************************************************************/
                if(current_item != flist->item.val)
                {
                  current_item = flist->item.val;		
                  /* Get maximum fileversion for the item*/
                  sprintf( uti_string, "SELECT MAX(n_fileversion) FROM f_%s WHERE n_itemnum = %d", flist->cat.name, flist->item.val);

                  status = SQLquery( uti_string, &buffer, BUFFER_SIZE );
                  if( status != SQL_S_SUCCESS )
                  {
                    MEMclose (&buffer);
                    ERRload_struct( UTI, UTI_E_UPDFCATALOG, "%s",
		    			flist->item.name );
                    return( UTI_E_UPDFCATALOG );
                  }
                  MEMbuild_array (buffer);
                  data = (char **) buffer->data_ptr;
                  max_version = atoi( data[0] );
                  MEMclose( &buffer );

                  /* Get maximum fileversion for the FILE*/
                  sprintf( uti_string, "SELECT MAX(n_fileversion) FROM f_%s WHERE n_itemnum = %d AND n_filenum IN ( SELECT n_filenum FROM f_%s WHERE n_fileno = %d )", flist->cat.name, flist->item.val,flist->cat.name,flist->file_no);		
                  status = SQLquery( uti_string, &buffer, BUFFER_SIZE );
                  if( status != SQL_S_SUCCESS )
                  {
                    MEMclose (&buffer);
                    ERRload_struct( UTI, UTI_E_UPDFCATALOG, "%s",
		    			flist->item.name );
                    return( UTI_E_UPDFCATALOG );
                  }
                  MEMbuild_array (buffer);
                  data = (char **) buffer->data_ptr;
                  file_max_version = atoi( data[0] );
                  MEMclose(&buffer);

                  /** Move latest ci_files to encrypted **/
                  sprintf( uti_string, "SELECT n_fileno, n_cifilename, n_cisano FROM f_%s WHERE n_itemnum = %d AND n_fileversion = %d", 
                  flist->cat.name, flist->item.val,max_version);		

                  status = SQLquery( uti_string, &buffer2, BUFFER_SIZE );
                  if( status != SQL_S_SUCCESS )
                  {
                    MEMclose (&buffer);
                    ERRload_struct( UTI, UTI_E_UPDFCATALOG, "%s",
                                         flist->item.name );
                    return( UTI_E_UPDFCATALOG );
                  }
                  MEMbuild_array (buffer2);
                  data2 = (char **) buffer2->data_ptr;
                  for(i=0;i<(buffer2->rows) * (buffer2->columns);
                          i+= buffer2->columns)
                  {
                    if(strcmp(data2[i+1], "") != 0)
                    {
                      status = UTIcopy_ud_to_NFMencrypted(atoi(data2[i+2]),
                                                          flist->cat.val, 
                                                          atoi(data2[i]), 
                                                          data2[i+1], 
                                                          &rename, 1);
                      if(status != NFM_S_SUCCESS)
                      {
                        _UTIdebug((fname, 
                                   "Rename <%s> to encrypted failed\n",
                                   flist->ci_file_name));

                        /** Don't report the error -DEP
                            Because for some times the latest
                            version files may not exist

                        ERRload_struct( UTI, UTI_E_UPDFCATALOG,
                                             "%s", flist->item.name );
                        return( UTI_E_UPDFCATALOG );
                        **********************************/
                        /** Reset NFM errors **/
                        ERRload_struct( NFM,NFM_S_SUCCESS,NULL);
                      }
                    }
                  }
                  MEMclose(&buffer2);

                  if(max_version < (file_max_version+1))
                      max_version = file_max_version+ 1;
                }

/******* Think of Two multi file items beeing Backed up and flagged for restore
		if((flist->ver+1) > max_version)
			max_version = (flist->ver)+1;
****************************/

               /* Check whether backedup file has been purged or not*/
               sprintf( uti_string, "SELECT n_fileco FROM f_%s WHERE n_fileno = %d AND n_fileco = 'O'", flist->cat.name, flist->file_no );  

               status = SQLquery( uti_string, &buffer2, BUFFER_SIZE );
	       if(status == SQL_I_NO_ROWS_FOUND) 
			file_purged = 0;
	       else if(status == SQL_S_SUCCESS)
			file_purged = 1;
               else
               {
                 MEMclose (&buffer2);
                 ERRload_struct( UTI, UTI_E_UPDFCATALOG, "%s",
                                      flist->item.name );
                 return( UTI_E_UPDFCATALOG );
               }
	       MEMclose(&buffer2);

               /* Get FILE DATA*/
               sprintf( uti_string, "SELECT n_fileversion,n_filenum, n_cifilename, n_cofilename, n_filetype, n_fileclass, n_cisano, n_cosano, n_fileco, n_cifilesize FROM f_%s WHERE n_fileversion = %d AND n_filenum IN ( SELECT n_filenum FROM f_%s WHERE n_fileno = %d ) AND n_itemnum = %d", 
                                     flist->cat.name, file_max_version,
                                     flist->cat.name, flist->file_no,  
                                     flist->item.val);

               status = SQLquery( uti_string, &buffer2, BUFFER_SIZE );
               if( status != SQL_S_SUCCESS )
               {
                 MEMclose (&buffer);
                 ERRload_struct( UTI, UTI_E_UPDFCATALOG, "%s",
                                      flist->item.name );
                 return( UTI_E_UPDFCATALOG );
               }
               MEMbuild_array (buffer2);
               f_data = (char **) buffer2->data_ptr;

               /******* Instead of updating the old f_catalog fileversion, 
                        we add a new one, but clear off the old one **/

               sprintf( uti_string,
               "UPDATE f_%s SET n_restoreflag = '' WHERE n_archiveno = %d AND n_fileno = %d", flist->cat.name, flist->rstr.archive_no,flist->file_no);

               status = SQLstmt( uti_string );
               if( status != SQL_S_SUCCESS )
               {
                 ERRload_struct( UTI, UTI_E_UPDFCATALOG, "%s",
                                      flist->item.name );
                 return( UTI_E_UPDFCATALOG );
               }

               /*****Do I have to lock f_catalog ? ********/
               sprintf(uti_string, "SELECT MAX(n_fileno) FROM f_%s", 
                       flist->cat.name);
		
               status = SQLquery( uti_string, &buffer, BUFFER_SIZE );
               if( status != SQL_S_SUCCESS )
               {
                 MEMclose (&buffer);
                 ERRload_struct( UTI, UTI_E_UPDFCATALOG, "%s",
                                      flist->item.name );
                 return( UTI_E_UPDFCATALOG );
               }
               MEMbuild_array (buffer);
               data = (char **) buffer->data_ptr;
               max_fileno = atoi( data[0] );
               new_fileno = max_fileno + 1;
               MEMclose(&buffer);

               sprintf( uti_string, "INSERT INTO f_%s (n_fileno,n_itemnum, n_fileversion, n_filenum, n_cifilename, n_cofilename, n_filetype, n_fileclass, n_cisano, n_fileco, n_cifilesize) VALUES (%d, %d, %d, %s, '%s', '%s', '%s', '%s', %s, 'N', %s)",
               flist->cat.name,
               new_fileno, flist->item.val,  
               max_version, f_data[1], f_data[2], f_data[3], 
               f_data[4], f_data[5], f_data[6], f_data[9]); 
		
               /** If old ci_file_name is different from the new one,
                   copy old ci_file to new ci_file 
			    (or)
                   If the new ci_file is NULL, 
                   copy the old one to new encrypted**/
		
               sano = atoi(f_data[6]);
               if (strcmp(f_data[2], "") == 0)
               {
		   if(file_purged)/**if file is purged, move it **/
		   {
                        status = UTIcopy_ud_to_NFMencrypted(sano,flist->cat.val,
                                                       new_fileno, 
                                                       flist->home.co_file_name,
                                                       &rename, 1);
                        _UTIdebug((fname,"cat <%s> fileno <%d> has been purged\n", flist->cat.name, flist->file_no));
		   }
		   else /** If the file is still there, copy it to the latest**/
		   {
                        status = UTIcopy_ud_to_NFMencrypted(sano,flist->cat.val,
                                                       new_fileno, 
                                                       flist->home.co_file_name,
                                                       &rename, 0);
                        _UTIdebug((fname,"cat <%s> fileno <%d> was NOT purged\n", flist->cat.name, flist->file_no));
		   }
			
                 if(status != NFM_S_SUCCESS)
                 {
                   _UTIdebug((fname,"Copy (or Move) <%s> to encrypted failed\n",
                                     flist->ci_file_name));
                   ERRload_struct( UTI, UTI_E_UPDFCATALOG, "%s",
                                        flist->item.name );
                   return( UTI_E_UPDFCATALOG );
                 }
               }
               else if (strcmp(flist->home.co_file_name, f_data[2]) != 0)
               {
                 /**storage area is the same, 
                    files are different.**/
		if(file_purged)
		{
                 status = UTIcopy_f1_to_f2(sano, flist->home.co_file_name,
                                           f_data[2], &rename, 1);
                 _UTIdebug((fname,"user given filename: cat <%s> fileno <%d> was purged\n", flist->cat.name, flist->file_no));
		}
		else
		{
                 status = UTIcopy_f1_to_f2(sano, flist->home.co_file_name,
                                           f_data[2], &rename, 0);
                 _UTIdebug((fname,"user given filename: cat <%s> fileno <%d> was NOT purged, Value: <%s>\n", flist->cat.name, flist->file_no));
		}
                 if(status != NFM_S_SUCCESS)
                 {
                   _UTIdebug((fname, "Copy (or MOVE) <%s> to <%s> failed\n",
                                     flist->home.co_file_name, f_data[2]));
                   ERRload_struct( UTI, UTI_E_UPDFCATALOG, "%s",
                                        flist->item.name );
                   return( UTI_E_UPDFCATALOG );
                 }
               }
               MEMclose(&buffer2);
              /**** } if restore from archive else part 11/19/92 NAVAIR******/
	    }
	    else if( utility == UTIrestore_p )
	    {
	        sprintf( uti_string,
		"UPDATE f_%s SET n_restoreflag = '',n_fileco='N' WHERE n_archiveno = %d AND n_fileno = %d", flist->cat.name, flist->rstr.archive_no,flist->file_no);
	    }
	    else if( utility == UTIdelete )
	    {
	        sprintf( uti_string,
		"DELETE FROM f_%s  WHERE n_fileno = %d", 
		flist->cat.name, flist->file_no);
	    }
	    status = SQLstmt( uti_string );
            if( status != SQL_S_SUCCESS )
            {
                ERRload_struct( UTI, UTI_E_UPDFCATALOG,"f_%s",flist->cat.name );
                flist->state = -1;
                return( UTI_E_UPDFCATALOG );
            }
	    /** Unlock f_catalog here **/
	}
	flist = flist->next;
     if(_NFMdebug_st.NFMdebug_on)
     {
        MEMprint_buffers("Rename Buffer", rename, _NFMdebug_st.NFMdebug_file);
     }
     if(rename)
     {
	_UTIdebug((fname, "Ready to do NFMfs_chg_files\n"));
        status = NFMfs_chg_files (&rename) ;
        if (status != NFM_S_SUCCESS)
        {
        	/**NFMrollback_transaction (0) ; **/

  		/* Move encrypted to user given if necessary**/
            	/**UTIrollback_update (0) ; **/
            	MEMclose (&rename) ;
            	_UTIdebug((fname,"Rename files File :status=<0x%.8x>\n",
			 				       status));

		/** We don't have report errors here either
               	ERRload_struct (UTI, UTI_E_UPDFCATALOG, "%s",
               		    	flist->item.name) ;
               	return(UTI_E_UPDFCATALOG) ;
		******************************************/
		/** Reset NFM errors **/
                ERRload_struct( NFM,NFM_S_SUCCESS,NULL);
        } 
     }
     MEMclose(&rename);
    }

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}
/*  This routine updates the catalog table for each file successfully
 *  operated on.
 */
UTIupdate_catalog( utility, flist )
    int		utility;
    UTIpending  flist;
{
    long	status;
    int		update_ok;
    int   	prev_del_item = -1;

    char	sql_insert[1024];
 
    MEMptr	buffer = NULL;

    static	char *fname = "UTIupdate_catalog";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    while( flist != NULL )
    {
	update_ok = 1;
	if( flist->state != -1)
	{
	    if( utility == UTIarchive ) 
	    {
	        sprintf( uti_string,
	 	"UPDATE %s SET n_pendingflag = '',n_archivestate = 'A' WHERE n_itemno = %d", flist->cat.name,flist->item.val );
	    }
	    else if( utility == UTIbackup ) 
	    {
	        sprintf( uti_string,
		"UPDATE %s SET n_pendingflag = '',n_archivestate = 'B' WHERE n_itemno = %d",flist->cat.name, flist->item.val );
	    }
   	    else if( utility == UTIrestore )
	    {
		sprintf(uti_string,
		"SELECT n_fileno FROM f_%s WHERE n_restoreflag IN ('IR', 'MR', 'SR','PR') AND n_itemnum=%d" , flist->cat.name, flist->item.val);

	        status = SQLquery( uti_string, &buffer, BUFFER_SIZE );
	    	if( status == SQL_I_NO_ROWS_FOUND )
	    	{
    			_UTIdebug(( fname, "Item has no flagged files\n"));
	    	}
		else if(status == SQL_S_SUCCESS)
		{
    			_UTIdebug(( fname, "Item has FLAGGED FILES"));
			update_ok = 0;
		}
		else 
		{
    			_UTIdebug(( fname, "Warning: SQLquery failed: <0x%.8x>\n", status));
		}
			
	        sprintf( uti_string,
		"UPDATE %s SET n_pendingflag = '',n_archivestate = '' WHERE n_itemno = %d",flist->cat.name, flist->item.val );
	    }
	    else if( utility == UTIdelete )
	    {
		/*  If there are other versions of this file, we can't
		 *  update the catalog until all versions of the file
	  	 *  have been flagged and deleted.
		 *
		 *  11/30/92: By this time, update_f_catalog should have 
	     	 *  deleted all files in all versions. So check only 
		 *  for version 0 f_catalog entries
		 */
		
		if(prev_del_item == flist->item.val)
		{
			/** If the previous item is the same the current one,
			    skip this element in the list 
			***/
			flist = flist->next;
			continue;
		}
		else
		  	prev_del_item = flist->item.val;

		sprintf( uti_string, 
		"SELECT n_fileversion FROM f_%s WHERE n_itemnum = %d AND n_fileversion = 0",flist->cat.name, flist->item.val);

	        status = SQLquery( uti_string, &buffer, BUFFER_SIZE );
	        if((status != SQL_I_NO_ROWS_FOUND) && 
		   (status != SQL_S_SUCCESS ))
	        {
	            MEMclose (&buffer);
	            ERRload_struct( UTI, UTI_E_UPDCATALOG,"%s",
				    flist->cat.name  );
	  	    return( UTI_E_UPDCATALOG );
		}
		MEMclose(&buffer);

	       	if(status == SQL_I_NO_ROWS_FOUND)
		{	
			/**Add dummy row to f_catalog with version=0 **/

			sprintf(sql_insert, "INSERT INTO f_%s (n_fileno, n_itemnum, n_cisano, n_filenum, n_fileclass, n_fileversion) VALUES (%d, %d, %d, 0, 'C', 0)", flist->cat.name, flist->file_no, flist->item.val, flist->home.sano);   
			status = SQLstmt(sql_insert);

	    		if( status != SQL_S_SUCCESS )
	    		{
	        		_UTIdebug ((fname,"Can't Insert dumy row into f_%s", flist->cat.name));
	    		}

		}
	        sprintf( uti_string,
			"UPDATE %s SET n_pendingflag='',n_archivestate = '', n_status = '' WHERE n_itemno = %d",flist->cat.name, flist->item.val );
	    }
	    else if( utility == UTIarchive_p )
	    {
	        sprintf( uti_string,
		"UPDATE %s SET n_pendingflag = 'pA' WHERE n_itemno = %d",
			flist->cat.name,flist->item.val);
	    }
	    else if( utility == UTIbackup_p )
	    {
	        sprintf( uti_string,
		"UPDATE %s SET n_pendingflag = 'pB' WHERE n_itemno = %d",
			flist->cat.name,flist->item.val);
	    }
   	    else if( utility == UTIrestore_p )
	    {
	        sprintf( uti_string,
		"UPDATE %s SET n_pendingflag = 'pR' WHERE n_itemno = %d",
			flist->cat.name,flist->item.val);
	    }

	    if(update_ok)
	    {
	    	status = SQLstmt( uti_string );
	    	if( status != SQL_S_SUCCESS )
	    	{
	        	ERRload_struct( UTI, UTI_E_UPDCATALOG,"%s", flist->cat.name  );
			return( UTI_E_UPDCATALOG );
	    	}
	    }
	}
	flist = flist->next;
    }

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

/*  This routine inserts a row into the 'nfmarchives' table which
 *  essentially serves as a place holder until a status is received
 *  that the archive/retrieve was successful.
 */
UTIupdate_nfmarchives( utility, rec )
    int		utility;
    NFMarch	rec;
{
    long  	status;

    static	char *fname = "UTIupdate_nfmarchives";
    
    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    if( ( utility == UTIarchive ) || ( utility == UTIbackup ) )
    {
        sprintf( uti_string,
	"UPDATE nfmarchives SET n_archivedate=TIMESTAMP'%s',n_novol=%d,n_archivecopies=%d,n_archivesize=%d,n_archivemethod='%s' WHERE n_archiveno = %d AND n_label = '%s' AND n_saveset = '%s' AND n_sano = %d ",
	rec->archive_date, rec->no_vol, rec->archive_copies,
	rec->archive_size,rec->archive_method,rec->archive_no,rec->label,
	rec->saveset,rec->storageno);
    }
    else if( ( utility == UTIarchive_p ) || ( utility == UTIbackup_p ) )
    {
   	sprintf( uti_string,
	"UPDATE nfmarchives SET n_archivedate=TIMESTAMP'%s',n_novol=%d,n_archivecopies=%d,n_archivesize=%d,n_archivemethod='%s' WHERE n_archiveno = %d AND n_label = '%s' AND n_saveset = '%s' AND n_sano = %d ",
	UTIgen_date(),
	rec->no_vol, rec->archive_copies,rec->archive_size,rec->archive_method,
	rec->archive_no,rec->label,rec->saveset,rec->storageno);
    }
    else if( utility == UTIdelete )
    {
        sprintf( uti_string,
	"DELETE FROM nfmarchives WHERE n_archiveno = %d AND n_label = '%s' AND n_saveset = '%s' AND n_sano = %d ",
	rec->archive_date, rec->no_vol, rec->archive_copies,
	rec->archive_size,rec->archive_method,rec->archive_no,rec->label,
	rec->saveset,rec->storageno);
    }

    status = SQLstmt( uti_string );
    if( status != SQL_S_SUCCESS )
    {
        ERRload_struct( UTI, UTI_E_UPDARCHIVES, NULL, NULL );
        return( UTI_E_UPDARCHIVES );
    }

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

/*  This routine updates a row into the 'nfmarchives' table which
 *  was originally inserted because of an OFF-LINE archive destination.
 *  This routine is called after a successful run of 'Nfmutil'
 */
UTIupdate_nfmarchives_p( group_no, no_copies )
    int		group_no;
    int		no_copies;
{
    long  	status;

    static	char *fname = "UTIupdate_nfmarchives_p";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    sprintf( uti_string,
	"UPDATE nfmarchives SET n_archivedate=TIMESTAMP'%s',n_archivecopies=%d WHERE n_archiveno = %d ", UTIgen_date(), no_copies, group_no );
    status = SQLstmt( uti_string );
    if( status != SQL_S_SUCCESS )
        return( status );

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

/*  This routine updates a row into the 'nfmsaveset' table which
 *  essentially serves as a place holder until a status is received
 *  that the archive/retrieve was successful.
 */
UTIupdate_nfmsavesets( utility,archive_no,flist )
    int		utility;
    int		archive_no;
    UTIpending  flist;
{
    long	status;

    UTIpending	plist;

    static	char *fname = "UTIupdate_nfmsavesets";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    plist = flist;

    while( plist != NULL )
    {
  	if( utility == UTIarchive )
            sprintf(uti_string,
	    "INSERT INTO nfmsavesets(n_archiveno,n_catalogno,n_itemno,n_fileno,n_itemstate) VALUES (%d,%d,%d,%d,'A')",archive_no, plist->cat.val, plist->item.val, plist->file_no);

  	else if( utility == UTIbackup )
            sprintf(uti_string,
	    "INSERT INTO nfmsavesets(n_archiveno,n_catalogno,n_itemno,n_fileno,n_itemstate) VALUES (%d,%d,%d,%d,'B')",archive_no, plist->cat.val, plist->item.val, plist->file_no);

 	else if( utility == UTIrestore )
	{
            sprintf( uti_string, "UPDATE nfmsavesets SET n_itemstate='B',n_restoredate=TIMESTAMP'%s' WHERE n_archiveno = %d AND n_catalogno = %d AND n_itemno = %d AND n_fileno = %d",UTIgen_date(), archive_no, plist->cat.val,plist->item.val,plist->file_no);
            status = SQLstmt( uti_string );
            if( status != SQL_S_SUCCESS )
            {
                ERRload_struct( UTI, UTI_E_UPDSAV, NULL, NULL );
                return( UTI_E_UPDSAV );
            }	
            sprintf( uti_string, "UPDATE nfmsavesets SET n_itemstate='B' WHERE n_archiveno = %d AND n_catalogno = %d AND n_itemno = %d AND n_itemstate != 'P'",
            archive_no, plist->cat.val, plist->item.val);
	}

  	else if( utility == UTIdelete )
            sprintf( uti_string, "DELETE FROM nfmsavesets WHERE n_catalogno = %d AND n_itemno = %d AND n_fileno = %d", plist->cat.val, plist->item.val, plist->file_no );

   	else if( ( utility == UTIarchive_p ) || ( utility == UTIbackup_p) )
            sprintf(uti_string,"INSERT INTO nfmsavesets(n_archiveno,n_catalogno,n_itemno,n_fileno,n_itemstate) VALUES (%d,%d,%d,%d,'P')",
  	    archive_no, plist->cat.val, plist->item.val, plist->file_no);

	else if( utility == UTIrestore_p )
            sprintf(uti_string, "UPDATE nfmsavesets SET n_itemstate = 'P',n_restoreno = %d WHERE n_archiveno = %d AND n_catalogno = %d AND n_itemno = %d AND n_fileno = %d",plist->rstr.restore_no, plist->rstr.archive_no, plist->cat.val,plist->item.val, plist->file_no );

        status = SQLstmt( uti_string );
        if((utility == UTIdelete) && 
	   (status != SQL_S_SUCCESS) && 
	   (status != SQL_I_NO_ROWS_FOUND))
        {
	    _UTIdebug((fname, "Deleting saveset entries failed <0x%.8x>\n", 
								status));
            ERRload_struct( UTI, UTI_E_UPDSAV, "", NULL );
            return( UTI_E_UPDSAV );
        }	
	else if((utility != UTIdelete) && (status != SQL_S_SUCCESS))
        {
            ERRload_struct( UTI, UTI_E_UPDSAV, NULL, NULL );
            return( UTI_E_UPDSAV );
        }	
	plist = plist->next;
    }

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

/*  This routine updates a row into the 'nfmsaveset' table which
 *  was inserted as a result of an OFF-LINE destination. This routine
 *  is called if the 'Nfmutil' was successful.
 */
UTIupdate_nfmsavesets_p( utility, group_no )
    int		utility;
    int		group_no;
{
    long	status;

    static	char *fname = "UTIupdate_nfmsavesets_p";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    if( utility == UTIarchive )
    {
        sprintf( uti_string,"UPDATE nfmsavesets SET n_itemstate='A' WHERE n_archiveno = %d", group_no );
    }
    else if( utility == UTIbackup )
    {
        sprintf( uti_string,"UPDATE nfmsavesets SET n_itemstate='B' WHERE n_archiveno = %d", group_no );
    }
    else if( utility == UTIrestore )
    {
        sprintf( uti_string, 
		 "UPDATE nfmsavesets SET n_itemstate='B',n_restoredate=TIMESTAMP'%s' WHERE n_restoreno = %d",UTIgen_date(), group_no );
    }

    status = SQLstmt( uti_string );
    if( status != SQL_S_SUCCESS )
        return( status );

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}

/* This routine is used to delete the entry in 'nfmarchives' table which
 * was made when the saveset number was assigned. If this routine is called,
 * there was an error made somewhere and the entry needs to be deleted 
 * because it does not correspond to a successful archive.
 */
UTIrm_saveset_entry( archive_no )
    int  archive_no;
{
    long status;

    static char *fname = "UTIrm_saveset_entry";

    sprintf( uti_string, "DELETE FROM nfmarchives WHERE n_archiveno = %d",
	     archive_no );
    status = SQLstmt( uti_string );
    if( status != SQL_S_SUCCESS )
        return( UTI_E_UPDSAV );

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}
/*  This routine builds a MEM buffer containing file names to be deleted
 *  in the utility directory ( /usr/ip32/nfm/utilities ) on the archive/
 *  restore node.
 */
UTIclient_return_buffer( xfer, flist )
    MEMptr	*xfer;
    UTIpending  flist;
{
    long	status;

    MEMptr	buffer;
    UTIpending  link;

    static 	char *fname = "UTIclient_return_buffer";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    link = flist;

    status = MEMopen( &buffer, BUFFER_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &buffer );
	return( status );
    }

    status = MEMwrite_format( buffer, "file_name", "char(80)" );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &buffer );
	return( status );
    }

    while( link != NULL )
    {
	strcpy( uti_string, UTI_CLIENT_PATH );
	/*  If this is an old filename format in the RESTORE saveset,
	 *  it is the old name that must be removed from the client
	 *  utilities directory.
	 */
	if( strlen( link->format.name ) > 0 )
	    strcat( uti_string, link->format.name );
	else
 	    strcat( uti_string, link->ci_file_name );
	strcat( uti_string, "\1" );
        _UTIdebug(( fname, "str <%s>\n", uti_string ));

	status = MEMwrite( buffer, uti_string );
        if( status != MEM_S_SUCCESS )
        {
            MEMclose( &buffer );
            return( status );
        }
	link = link->next;
    }

    *xfer = buffer;

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}
/*  This routine updates the nfmprojectcit table for each file successfully
 *  operated on that is a project member.
 */
UTIupdate_nfmprojectcit( utility, archive_no, flist )
    int		utility;
    int 	archive_no;
    UTIpending  flist;
{
    long	status;

    static	char *fname = "UTIupdate_nfmprojectcit";

    while( flist != NULL )
    {
	if( flist->project_no > 0 )
	{
	    if( flist->state != -1)
	    {
	        if( utility == UTIarchive || utility == UTIbackup ) 
	        {
	            sprintf( uti_string,
		 	"UPDATE nfmprojectcit SET n_archiveno = %d, n_archiveflag = '' WHERE n_projectno = %d AND n_catalogno = %d AND n_itemno = %d",
			archive_no, flist->project_no, flist->cat.val,
			flist->item.val );
  	        }
     	        else if( utility == UTIrestore )
	        {
	            sprintf( uti_string,
			"UPDATE nfmprojectcit SET n_archiveflag = '' WHERE n_projectno = %d AND n_catalogno = %d AND n_itemno = %d",
			flist->project_no, flist->cat.val, flist->item.val );
	        }
  	        status = SQLstmt( uti_string );
	        if( status != SQL_S_SUCCESS )
	        {
	            ERRload_struct( UTI, UTI_E_UPDPROJECT, "%d",
				flist->project_no  );
		    return( UTI_E_UPDPROJECT );
	        }
	    }
	}
	flist = flist->next;
    }

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}
UTIupdate_safiles( flist )
    UTIpending  flist;
{
    static	char *fname = "UTIupdate_safiles";
    long status;

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    while( flist != NULL )
    {
	if( flist->state != -1)
	{
	    sprintf( uti_string,
	    "DELETE FROM nfmsafiles WHERE (n_catalogno = %d) AND (n_itemno = %d) AND (n_fileversion = %d)", flist->cat.val,flist->item.val, flist->ver);

	    status = SQLstmt( uti_string);

            if((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
            {
    		_UTIdebug(( fname, "Unable to delete local file manager entries for catalog: <%s>, item: <%s>\n", flist->cat.name, flist->item.name));
                ERRload_struct( UTI, UTI_I_UPDSAFILES, "%s%s",
                              flist->cat.name,flist->item.name );
                return( UTI_I_UPDSAFILES );
            }
	}
	flist = flist->next;
    }
    _UTIdebug(( fname, "%s\n", "SUCCESSFUL...." ));
    return( UTI_S_SUCCESS );
}
