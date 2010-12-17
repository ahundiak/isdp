#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMstruct.h"
#include "NFMflag.h"
#include "ERR.h"
#include "DEBUG.h"

char	flag_s[512];

/*************
#define NFM_E_ITEM_PRIME_MEMBER 10
*************/

extern struct NFMglobal_st NFMglobal;

/*
 Doc: NFMflag_item_*

 Abstract:
     These functions flag items for archive, backup, restore, or delete

 History:
     Jill McCutcheon  November 14, 1990 - Creation

 */

long NFMflag_item_archive (user_id, catalog, item_name, item_rev)
  long	user_id;
  char	*catalog;
  char	*item_name;
  char	*item_rev;
  {
	long	status;
	char	item_no[20];

	MEMptr  buffer = NULL;
	long    NFMfl_flag_validate_item();

	static  char *fname = "NFMflag_item_archive";

	_NFMdebug(( fname, "catalog    <%s>\n", catalog));
	_NFMdebug(( fname, "item_name  <%s>\n", item_name));
	_NFMdebug(( fname, "item_rev   <%s>\n", item_rev));

	/*  Get the "n_itemno" for this item  */

	if( (status = NFMfl_get_item_no (catalog, item_name, item_rev,	
			item_no)) != NFM_S_SUCCESS)
	{
	  _NFMdebug(( fname, "NFMfl_get_item_no = <0x%.8x>\n", status));
 	  return (status);
        }

	/*  Validate that the item can be flagged for archive  */

	if( (status = NFMfl_flag_validate_item (catalog, item_no, item_name, ARCHIVE))
			!= NFM_S_SUCCESS )
        {
	     _NFMdebug(( fname, "NFMfl_flag_validate_item = <0x%.8x>\n",
  	     		 status));
             return (status);
        }

	sprintf (flag_s, "UPDATE %s SET n_pendingflag = 'IA' WHERE n_itemno = %s", catalog, item_no );
	if ((status = SQLstmt (flag_s)) != SQL_S_SUCCESS)
	  {
		_NFMdebug(( fname, "SQLstmt = <0x%.8x>\n", status));
		ERRload_struct( NFM, NFM_E_FLAG_ARCHIVE, "%s", item_name );
		return (NFM_E_FLAG_ARCHIVE );
	  }
	MEMclose( &buffer );
	_NFMdebug(( fname, "%s\n", "Returning NFM_S_SUCCESS ..."));
	return (NFM_S_SUCCESS);
  }

/*
Doc:	NFMflag_item_backup
*/

long NFMflag_item_backup (user_id, catalog, item_name, item_rev)
  long	user_id;
  char	*catalog;
  char	*item_name;
  char	*item_rev;
  {
	long	status;
	char	item_no[20];

	MEMptr	buffer = NULL;
	long    NFMfl_flag_validate_item();
	static  char *fname = "NFMflag_item_backup";

	_NFMdebug(( fname, "catalog    <%s>\n", catalog));
	_NFMdebug(( fname, "item_name  <%s>\n", item_name));
	_NFMdebug(( fname, "item_rev   <%s>\n", item_rev));

	/*  Get the "n_itemno" for this item  */

	if((status = NFMfl_get_item_no (catalog, item_name, item_rev, item_no))
			!= NFM_S_SUCCESS)
	  {
     	     _NFMdebug(( fname, "NFMfl_get_item_no = <0x%.8x>\n", status));
	     return (status);
	  }

	/*  Validate that the item can be flagged for backup  */

	if( (status = NFMfl_flag_validate_item (catalog, item_no, item_name, BACKUP))
			!= NFM_S_SUCCESS)
	{
	   _NFMdebug(( fname, "NFMfl_flag_validate_item = <0x%.8x>\n",
	   	    status));
     	   return (status);
        }

	/*  Set the "n_pendingflag" for all files for this item to "IB"  */

	sprintf (flag_s,
		      "UPDATE %s SET n_pendingflag = 'IB' WHERE n_itemno = %s",
		      catalog, item_no);

	if( (status = SQLstmt (flag_s)) != SQL_S_SUCCESS)
	  {
		_NFMdebug(( fname, "SQLstmt = <0x%.8x>\n", status));
		ERRload_struct( NFM, NFM_E_FLAG_BACKUP, "%s", item_name );
		return( NFM_E_FLAG_BACKUP );
	  }
	MEMclose( &buffer );
	_NFMdebug(( fname, "%s\n", "Returning NFM_S_SUCCESS ..."));
	return (NFM_S_SUCCESS);
  }

/*
Doc:	NFMflag_item_restore
*/

long NFMflag_item_restore (user_id, catalog, item_name, item_rev)
  long	user_id;
  char	*catalog;
  char	*item_name;
  char	*item_rev;
  {
	long	status;
	int	i;
  	int	restore_flag;

	char	item_no[20];
	char	catalog_no[20];
	char	**data;

	MEMptr  buffer = NULL;

	long    NFMfl_flag_validate_item();
	static  char *fname = "NFMflag_item_restore";

	_NFMdebug(( fname, "catalog    <%s>\n", catalog));
	_NFMdebug(( fname, "item_name  <%s>\n", item_name));
	_NFMdebug(( fname, "item_rev   <%s>\n", item_rev));

	/*  Get the "n_catalogno" for this item  */

	if ((status = NFMfl_get_catalog_no (catalog, catalog_no))
			!= NFM_S_SUCCESS)
	  {
	      _NFMdebug(( fname, "NFMfl_get_catalog_no = <0x%.8x>\n", status));
	      return (status);
	  }

	/*  Get the "n_itemno" for this item  */

	if((status = NFMfl_get_item_no (catalog, item_name, item_rev, item_no))
			!= NFM_S_SUCCESS)
	  {
	    _NFMdebug(( fname, "NFMfl_get_item_no = <0x%.8x>\n", status));
            return (status);
	  }

	
        status = NFMfl_flag_validate_item 
				(catalog, item_no, item_name, RESTORE);
        _NFMdebug(( fname, "After NFMfl_flag_validate_item <%lx>\n", status));

	if(status != NFM_S_SUCCESS)
        {
           _NFMdebug(( fname, "NFMfl_flag_validate_item = <0x%.8x>\n", status));
           return (status);
        }

/*  Validate that the item can be flagged for restore.
 *  Need to get ALL fileno's for this item and only flag any file
 *  with a matching entry in nfmsavesets!!!!!
 */		
/******
        sprintf( flag_s, "SELECT n_fileno FROM f_%s WHERE n_itemnum = %s AND n_fileversion > 0", catalog, item_no );
******/
        sprintf( flag_s, "SELECT n_fileno FROM f_%s WHERE n_itemnum = %s AND n_fileversion > 0 AND n_fileversion IN (SELECT MAX(n_fileversion) from f_%s where n_itemnum = %s AND NOT(n_archiveno is NULL))", catalog, item_no, catalog, item_no);

        if(( status = SQLquery( flag_s, &buffer, MEM_SIZE )) != SQL_S_SUCCESS)
	{
	    _NFMdebug(( fname, "SQLquery = <0x%.8x>\n", status));
  	    MEMclose (&buffer);
	    ERRload_struct( NFM, NFM_E_VALIDATE_RESTORE, "%s", item_name );
	    return( NFM_E_VALIDATE_RESTORE );
	}
	if ((status = MEMbuild_array (buffer)) != MEM_S_SUCCESS)
        {
	    _NFMdebug(( fname, "MEMbuild_array = <0x%.8x>\n", status));
            MEMclose (&buffer);
            return (status );
        }
	restore_flag = 0;
	data = (char **) buffer->data_ptr;
        for( i=0; i<buffer->rows; ++i )
	{
	    if ((status = NFMfl_validate_item_restore
		(catalog_no, item_no, data[i] )) != NFM_S_SUCCESS)
	    {
		_NFMdebug(( fname, "NFMfl_validate_item_restore: catalog <%s>, item <%s>, file_no <%s> is invalid = <0x%.8x>\n", catalog_no, item_no, 
						 data[i], status));
		continue;
  	    }
 	    /*  Set the "n_pendingflag" for this file_no to "IR"  */

  	    sprintf (flag_s, 
		"UPDATE f_%s SET n_restoreflag='IR' WHERE n_itemnum = %s AND n_fileversion> 0 AND n_fileno = %s",catalog, item_no, data[i] );
  	    if ((status = SQLstmt (flag_s)) != SQL_S_SUCCESS)
	    {
		_NFMdebug(( fname, "SQLstmt = <0x%.8x>\n", status));
		ERRload_struct( NFM, NFM_E_FLAG_RESTORE, "%s", item_name );
		return( NFM_E_FLAG_RESTORE );
 	    }
	    restore_flag = 1;
        } /* end row loop */

        if( !restore_flag )
  	{
	    _NFMdebug(( fname, "%s\n", "No Files Flagged for Restore"));
	    ERRload_struct( NFM, NFM_E_NO_FILES_FLAGGED, NULL, NULL );
	    return( NFM_E_NO_FILES_FLAGGED );
	}
	sprintf (flag_s, 
		"UPDATE %s SET n_pendingflag='IR' WHERE n_itemno = %s",
		catalog, item_no );
 	if ((status = SQLstmt (flag_s)) != SQL_S_SUCCESS)
        {
	    _NFMdebug(( fname, "SQLstmt = <0x%.8x>\n", status));
	    ERRload_struct( NFM, NFM_E_FLAG_RESTORE, "%s", item_name );
	    return( NFM_E_FLAG_RESTORE );
        }

        _NFMdebug(( fname, "%s\n", "Returning NFM_S_SUCCESS ..."));
    
        return (NFM_S_SUCCESS);
  }

/*
Doc:	NFMflag_item_delete
*/

long NFMflag_item_delete (user_id, catalog, item_name, item_rev)
  long	user_id;
  char	*catalog;
  char	*item_name;
  char	*item_rev;
  {
	long	status;

	char	item_no[20];

	static  char *fname = "NFMflag_item_delete";
	long    NFMfl_flag_validate_item();

	_NFMdebug(( fname, "catalog    <%s>\n", catalog));
	_NFMdebug(( fname, "item_name  <%s>\n", item_name));
	_NFMdebug(( fname, "item_rev   <%s>\n", item_rev));

	/*  Get the "n_itemno" for this item  */

	if((status = NFMfl_get_item_no (catalog, item_name, item_rev, item_no))
			!= NFM_S_SUCCESS)
	  {
	    _NFMdebug(( fname, "NFMfl_get_item_no = <0x%.8x>\n", status));
	    return (status);
	  }

	/*  Validate that the item can be flagged for delete  */

	if((status = NFMfl_flag_validate_item (catalog, item_no, item_name, DELETE))
			!= NFM_S_SUCCESS)
	  {
	    _NFMdebug(( fname, "NFMfl_flag_validate_item = <0x%.8x>\n", 
			status));
	    return (status);
	  }

	/*  Set the "n_pendingflag" for all files for this item to "ID"  */

	sprintf(flag_s, "UPDATE %s SET n_pendingflag='ID' WHERE n_itemno = %s",
		catalog,item_no );
	if((status = SQLstmt (flag_s)) != SQL_S_SUCCESS)
	  {
		_NFMdebug(( fname, "SQLstmt = <0x%.8x>\n", status));
		ERRload_struct( NFM, NFM_E_FLAG_DELETE, "%s", item_name );
	 	return( NFM_E_FLAG_DELETE );
	  }

	_NFMdebug(( fname, "%s\n", "Returning NFM_S_SUCCESS ..."));
	return (NFM_S_SUCCESS);
  }

/*
Doc:	NFMfl_flag_validate_item
*/

long NFMfl_flag_validate_item (catalog, item_no, item_name, op_flag)
  char	*catalog;     /*  i  */
  char	*item_no;     /*  i  */
  char  *item_name;   /*  i  */
  int	op_flag;      /*  i - validate for a specific operation or not  */
  {
	long	status;
	char	**data;

	char	n_status[5];
	char	archstate[5];

	MEMptr	buffer = NULL;
	static  char *fname = "NFMfl_flag_validate_item";

	_NFMdebug(( fname, "catalog    <%s>\n", catalog));
	_NFMdebug(( fname, "item_no    <%s>\n", item_no));
	_NFMdebug(( fname, "item_name  <%s>\n", item_name));
	_NFMdebug(( fname, "op_flag    <%d>\n", op_flag));

	/*  You can't flag any item for archive if it is a primary member of 
	    a set
	*/
	if(op_flag == ARCHIVE)
	{
		sprintf(flag_s, 
		"SELECT b.n_citno FROM nfmcatalogs a, nfmsetcit b WHERE a.n_catalogname = '%s' AND b.n_ccatalogno = a.n_catalogno AND b.n_citemno = %s AND b.n_type = 'P'", catalog, item_no);
  	       status = SQLquery (flag_s, &buffer, MEM_SIZE);

	       if(status == SQL_S_SUCCESS)
	       {
		_NFMdebug(( fname, "Item <%s> is a PRIMARY member of a SET\n", 
				item_name));
	  	status = NFM_E_ITEM_PRIME_MEMBER;	
		ERRload_struct(NFM, status, "%s", item_name);
		MEMclose (&buffer);
		return( status );
	       }
	       else if(status != SQL_I_NO_ROWS_FOUND)	
	       {
		 _NFMdebug(( fname, "Warning: An ERROR occured in the sql query!!! <0x%.8x>\n", status)); 
		 MEMclose(&buffer);
	       }
	}
	buffer = NULL;
	/*  If this is not a backup or restore operation, check "n_status" in
	    the catalog to see if this item has a file and if it is checked in
	*/
	if ((op_flag == ARCHIVE) || (op_flag == DELETE) || (op_flag == BACKUP)||
	    (op_flag == RESTORE))
	  {
	    sprintf (flag_s, "SELECT n_archivestate,n_status FROM %s WHERE n_itemno = %s", catalog, item_no);
  	    if((status = SQLquery (flag_s, &buffer, MEM_SIZE))!= SQL_S_SUCCESS)
	      {
		_NFMdebug(( fname, "SQLquery = <0x%.8x>\n", status));
		MEMclose (&buffer);
		return( status );
	      }

	    if ((status = MEMbuild_array (buffer)) != MEM_S_SUCCESS)
	      {
		_NFMdebug(( fname, "MEMbuild_array = <0x%.8x>\n", status));
		MEMclose (&buffer);
		return( status );
	      }

	    data = (char **) buffer->data_ptr;
	    strcpy (archstate, data[0]);
  	    strcpy (n_status, data[1]);
	    MEMclose (&buffer);

	/*  Check "n_archstate" in the catalog to see
	    if this item has a file and if it is on disk.
	    The only state we are concerned with is "A"
	    because that means the file is not ON-LINE.
	    Other possible states are ""(no previous action)
	    and "B" (backed up).
         */

	if ((strcmp (archstate, "A") == 0) && (op_flag != RESTORE))
	  {
		_NFMdebug(( fname, "%s\n", "file is archived"));
		ERRload_struct( NFM, NFM_E_ITEM_ARCHIVED, "%s", item_name );
		return( NFM_E_ITEM_ARCHIVED );
	  }
	/*  Check "n_status" in the catalog to see
	    if this item has a file that is checked in  */

	if ((op_flag != BACKUP) &&
	    (strcmp (n_status, "I") != 0 ) && 
	    (strcmp (n_status, "")  != 0 ))
	  {
		_NFMdebug(( fname, "%s\n", "file is not checked in"));
		ERRload_struct( NFM, NFM_E_ITEM_OUT, "%s", item_name);
		return( NFM_E_ITEM_OUT );
	  }

	  if(strcmp(n_status, "") == 0)
	  {
		_NFMdebug(( fname, "%s\n", "file does not exist"));
		ERRload_struct(NFM, NFM_E_NO_FILE, "%s", item_name);
		return( NFM_E_NO_FILE );
	  }
	}

	/*  Check the "n_pendflag" for this item's files
	    to make sure that there are no other requests pending  */

	sprintf (flag_s, "SELECT n_pendingflag FROM %s WHERE n_itemno = %s",
		 catalog, item_no );

	if((status = SQLquery (flag_s, &buffer, MEM_SIZE)) != SQL_S_SUCCESS)
	  {
		_NFMdebug(( fname, "SQLquery = <0x%.8x>\n", status));
		ERRload_struct( NFM, NFM_E_SQL_QUERY, NULL, NULL );
		MEMclose (&buffer);
		return( NFM_E_SQL_QUERY );
	  }
	else
	  {
 	  /*  Files  have pending requests but this may be OK
	      if the current request is the same as the pending
  	       request.
	   */
	      if ((status = MEMbuild_array (buffer)) != MEM_S_SUCCESS)
		{
		    _NFMdebug(( fname, "MEMbuild_array = <0x%.8x>\n", status));
		    MEMclose (&buffer);
		    return( status );
		}

		data = (char **) buffer->data_ptr;
		switch( op_flag )
		{
		    case  ARCHIVE:
		    /*  The current pending flag is legal if it 
			is "","SA","MA","IA".
			8/27/92: Decided that MA and SA are not valid per Linda
			9/1/92: "MB" could be a legal flag. Still not decided
		     */
			if( strcmp( data[0], ""   ) == 0 ||
		 	    strcmp( data[0], "IA" ) == 0 )
			{
			/**    strcmp( data[0], "SA" ) == 0 ||
			       strcmp( data[0], "MA" ) == 0 || are not valid***/
    			_NFMdebug(( fname, "Item flag <%s>\n", data[0] ));
    			break;
			}
			else
			{
			    ERRload_struct( NFM, NFM_E_ITEM_FLAGGED, "%s",
					     item_name );
			    MEMclose (&buffer);
			    return( NFM_E_ITEM_FLAGGED );
			}

		    case  BACKUP:
		    /*  The current pending flag is legal if it 
			is "","SB","MB","IB"
		     */
			if( strcmp( data[0], ""   ) == 0 ||
		 	    strcmp( data[0], "IB" ) == 0 )
			{
		     	/**strcmp( data[0], "SB" ) == 0 ||
			    strcmp( data[0], "MB" ) == 0 ||  not valid***/
    			_NFMdebug(( fname, "Item flag <%s>\n", data[0] ));
    			break;
			}
			else
			{
			    ERRload_struct( NFM, NFM_E_ITEM_FLAGGED, "%s",
					     item_name );
			    MEMclose (&buffer);
			    return( NFM_E_ITEM_FLAGGED );
			}

		    case  RESTORE:
		    /*  The current pending flag is legal if it 
			is "","SR","MR","IR"

			3/18/92 Change plans: If it is already flagged for
			restore, error out.
			if( strcmp( data[0], ""   ) == 0 ||
			    strcmp( data[0], "SR" ) == 0 ||
			    strcmp( data[0], "MR" ) == 0 ||
		 	    strcmp( data[0], "IR" ) == 0 )
			{
    			_NFMdebug(( fname, "Item flag <%s>\n", data[0] ));
    			break;
			}
		     */

			if( strcmp( data[0], "") == 0 )
			{
    			    _NFMdebug(( fname, "Item flag <%s>\n", data[0] ));
            		    break;
			}
			else
			{
			    ERRload_struct( NFM, NFM_E_ITEM_FLAGGED, "%s",
					     item_name );
			    MEMclose (&buffer);
			    return( NFM_E_ITEM_FLAGGED );
			}

		    case  DELETE:
		    /*  The current pending flag is legal if it is "","ID"
		     */
			if( strcmp( data[0], ""   ) == 0 ||
		 	    strcmp( data[0], "ID" ) == 0 )
			{
    			_NFMdebug(( fname, "Item flag <%s>\n", data[0] ));
    			break;
			}
			else
			{
			    ERRload_struct( NFM, NFM_E_ITEM_FLAGGED, "%s",
					     item_name );
			    MEMclose (&buffer);
			    return( NFM_E_ITEM_FLAGGED );
			}
		    default:
			break;
		}
	  }

        MEMclose( &buffer );
	_NFMdebug(( fname, "%s\n", "Returning SUCCESS ..."));

	return( NFM_S_SUCCESS );
  }

long NFMalpha_flag_item_restore (user_id, catalog, item_name, item_rev,
				 item_ver)
  long	user_id;
  char	*catalog;
  char	*item_name;
  char	*item_rev;
  char  *item_ver;
  {
	long	status, col=0;
	int	i, latest_version;

	char    item_no[10], newname[1024];
	char	catalog_no[10];
	char	**data, **data2;

	MEMptr  buffer = NULL, buffer2 = NULL, rename_buffer = NULL;

        static  char *fname = "NFMalpha_flag_item_restore";

	_NFMdebug(( fname, "catalog    <%s>\n", catalog));
	_NFMdebug(( fname, "item_name  <%s>\n", item_name));
	_NFMdebug(( fname, "item_rev   <%s>\n", item_rev));
	_NFMdebug(( fname, "item_ver   <%s>\n", item_ver));

	/*  Get the "n_catalogno" for this item  */

	if ((status = NFMfl_get_catalog_no (catalog, catalog_no))
			!= NFM_S_SUCCESS)
	  {
	    _NFMdebug(( fname, "NFMfl_get_catalog_no = <0x%.8x>\n", status));
	    return (status);
	  }

	/*  Get the "n_itemno" for this item  */

	if((status = NFMfl_get_item_no (catalog, item_name, item_rev, item_no))
			!= NFM_S_SUCCESS)
	  {
	    _NFMdebug(( fname, "NFMfl_get_item_no = <0x%.8x>\n", status));
	    return (status);
	  }

        status = NFMfl_flag_validate_item
                                (catalog, item_no, item_name, RESTORE);
        _NFMdebug(( fname, "After NFMfl_flag_validate_item <%lx>\n", status));

        if(status != NFM_S_SUCCESS)
        {
           _NFMdebug(( fname, "NFMfl_flag_validate_item = <0x%.8x>\n", status));
           return (status);
        }

/*  Validate that the item can be flagged for restore.
 *  Need to get ALL fileno's for this item and only flag any file
 *  with a matching entry in nfmsavesets!!!!!
 */		
        sprintf( flag_s, "SELECT n_fileno, n_filenum FROM f_%s WHERE n_itemnum = %s AND n_fileversion = %s",catalog, item_no, item_ver );
        if(( status = SQLquery( flag_s, &buffer, MEM_SIZE )) != SQL_S_SUCCESS)
	{
	    _NFMdebug(( fname, "SQLquery = <0x%.8x>\n", status));
  	    MEMclose (&buffer);
	    ERRload_struct( NFM, NFM_E_VALIDATE_RESTORE, "%s", item_name );
	    return( NFM_E_VALIDATE_RESTORE );
	}
	if ((status = MEMbuild_array (buffer)) != MEM_S_SUCCESS)
        {
	    _NFMdebug(( fname, "MEMbuild_array = <0x%.8x>\n", status));
            MEMclose (&buffer);
	    ERRload_struct( NFM, NFM_E_MEM, "%s", item_name );
            return (status );
        }

	data = (char **) buffer->data_ptr;
	for( i=0; i<buffer->rows; ++i )
    	{
	    col = i * buffer->columns;
            if ((status = NFMfl_validate_item_restore
                (catalog_no, item_no, data[col] )) != NFM_S_SUCCESS)
            {
                _NFMdebug(( fname, "NFMfl_validate_item_restore: catalog <%s>, item <%s>, file_no <%s> is invalid = <0x%.8x>\n", catalog_no, item_no,
                                                 data[i], status));
                continue;
            }
/*************** Should you bump out if an invalid file is found ? NO
            if ((status = NFMfl_validate_item_restore
   	        (catalog_no, item_no, data[i] )) != NFM_S_SUCCESS)
	    {
	        MEMclose( &buffer );
	        _NFMdebug(( fname, "NFMfl_validate_item_restore = <0x%.8x>\n",
				status));
	        ERRload_struct( NFM, NFM_E_VALIDATE_RESTORE, "%s", item_name );
	        return( NFM_E_VALIDATE_RESTORE );
             }
****************/

            /*  Set the "n_restoreflag" for this file_no to "IR"  */

   	    sprintf (flag_s, 
	  	    "UPDATE f_%s SET n_restoreflag='IR' WHERE n_itemnum = %s AND n_fileno = %s", catalog, item_no, data[col] );
   	    if ((status = SQLstmt (flag_s)) != SQL_S_SUCCESS)
	    {
	        MEMclose( &buffer );
	        _NFMdebug(( fname, "SQLstmt = <0x%.8x>\n", status));
	        ERRload_struct( NFM, NFM_E_FLAG_RESTORE, "%s", item_name );
	        return( NFM_E_FLAG_RESTORE );
   	    }


	}

 	sprintf (flag_s, 
	  	    "UPDATE %s SET n_pendingflag = 'IR' WHERE n_itemno = %s",
			 catalog, item_no );
        if ((status = SQLstmt (flag_s)) != SQL_S_SUCCESS)
	{
	    MEMclose( &buffer );
	    _NFMdebug(( fname, "SQLstmt = <0x%.8x>\n", status));
            ERRload_struct( NFM, NFM_E_FLAG_RESTORE, "%s", item_name );
            return( NFM_E_FLAG_RESTORE );
 	}

        MEMclose( &buffer );
        _NFMdebug(( fname, "%s\n", "Returning NFM_S_SUCCESS ..."));
    
        return (NFM_S_SUCCESS);
  }
