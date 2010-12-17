#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMflag.h"
#include "ERR.h"
#include "DEBUG.h"

char	flag_s[512];
/***DELETE THIS
#define NFM_E_ITEM_FLAG_PROJ_MEM 999
****/

long NFMcancel_item_archive_flag (user_id, catalog, item_name, item_rev)
  long	user_id;
  char	*catalog;
  char	*item_name;
  char	*item_rev;
  {
	long	status;

	char	**data;
	char	item_no[20];

	MEMptr	buffer = NULL;

	extern	long NFMfl_get_item_no ();
	extern	long MEMbuild_array ();
	extern	long SQLquery ();
	extern	long SQLstmt ();

  	static  char *fname = "NFMcancel_item_archive_flag";

	_NFMdebug(( fname, "user_id   = <%d>\n", user_id));
	_NFMdebug(( fname, "catalog   = <%s>\n", catalog));
	_NFMdebug(( fname, "item_name = <%s>\n", item_name));
	_NFMdebug(( fname, "item_rev  = <%s>\n", item_rev));

	/*  Get the "n_itemno" for this item  */

	status = NFMfl_get_item_no (catalog, item_name, item_rev, item_no);
	if( status != NFM_S_SUCCESS )
	  {
		_NFMdebug(( fname, "NFMfl_get_item_no = <0x%.8x>\n", status));
		return (status);
	  }

	/*  Get the "n_pendingflag" for this item  */

	sprintf (flag_s, "SELECT n_pendingflag FROM %s WHERE n_itemno = %s",
						 	   catalog,item_no);
	status = SQLquery (flag_s, &buffer, MEM_SIZE);
	if( status != SQL_S_SUCCESS )
	  {
		_NFMdebug(( fname, "SQLquery = <0x%.8x>\n", status));
		ERRload_struct( NFM, NFM_E_SQL_QUERY, NULL, NULL );
		MEMclose (&buffer);
	        return( NFM_E_SQL_QUERY );
	  }

	status = MEMbuild_array (buffer);
	if( status != MEM_S_SUCCESS )
	  {
		_NFMdebug(( fname, "MEMbuild_array = <0x%.8x>\n", status));
		MEMclose (&buffer);
		ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
     	        return( NFM_E_MEM );
	  }

	data = (char **) buffer->data_ptr;

   	    /*  See if the item has been flagged as other than an item  */
  	    if ((strcmp (data[0], "")) == 0)
	    {
	    	_NFMdebug(( fname, "%s\n", "Item has not been flagged"));
  	    	ERRload_struct( NFM, NFM_E_ITEM_NOT_FLAGGED, "%s%s",
			 	item_name, item_rev );
	    	return( NFM_E_ITEM_NOT_FLAGGED );
            }
  	    else if ((strcmp (data[0], "MA")) == 0)
	    {
	    	_NFMdebug(( fname, "%s\n", "Item has been flagged as a set member, it is NOT ok to cancel it\n "));

		/***8/27/92 OK to cancel an "M?" flag through item cancel
		    9/2/92 This is changed back ***/ 

  	    	ERRload_struct( NFM, NFM_E_ITEM_FLAG_SET_MEM, "%s%s",
			 	item_name, item_rev );
	    	return( NFM_E_ITEM_FLAG_SET_MEM );
	    }
  	    else if ((strcmp (data[0], "PA")) == 0)
	    {
	    	_NFMdebug(( fname, "%s\n", "Item has been flagged as a project member"));
  	    	ERRload_struct( NFM, NFM_E_ITEM_FLAG_PROJ_MEM, "%s%s",
			 	item_name, item_rev );
	    	return( NFM_E_ITEM_FLAG_PROJ_MEM );
	    }
 	    else if ( strcmp( data[0], "IA") != 0 )
	    {
 	    	_NFMdebug(( fname, "%s\n", "Item not flagged as an item"));
	    	ERRload_struct( NFM, NFM_E_NOT_FLAGGED_AS_ITEM_ARCHI,
				 	"%s%s", item_name, item_rev );
	    	return( NFM_E_NOT_FLAGGED_AS_ITEM_ARCHI );
	    }

	    /*  Set the "n_pendingflag" for this item_version to ""  */

   	    sprintf(flag_s,"UPDATE %s SET n_pendingflag = NULL WHERE n_itemno = %s",catalog, item_no);
 	    status = SQLstmt (flag_s);
	    if( status != SQL_S_SUCCESS )
	    {
		_NFMdebug(( fname, "SQLstmt = <0x%.8x>\n", status));
		MEMclose( &buffer );
		ERRload_struct( NFM, NFM_E_CANCEL_ARCHIVE_FLAG,"%s%s",
				 item_name, item_rev );
 		return( NFM_E_CANCEL_ARCHIVE_FLAG );
	    }
	MEMclose (&buffer);

	_NFMdebug(( fname, "%s\n", "Returning NFM_S_SUCCESS ..."));
	return (NFM_S_SUCCESS);
  }

/*
Doc:	NFMcancel_item_backup_flag

 Abstract:
     This function will cancel flags for backup utility operations.

 History:
     Jill McCutcheon  November 14, 1990 - Creation

 */

long NFMcancel_item_backup_flag (user_id, catalog, item_name, item_rev)
  long	user_id;
  char	*catalog;
  char	*item_name;
  char	*item_rev;
  {
	long	status;
	int	i;
        int     flagged_item;
        int     flagged_backup;

	char	**data;
	char	item_no[20];

	MEMptr	buffer = NULL;

	extern	long NFMfl_get_item_no ();
	extern	long MEMbuild_array ();
	extern	long SQLquery ();
	extern	long SQLstmt ();

	static  char *fname = "NFMcancel_item_backup_flag";

	_NFMdebug(( fname, "user_id   = <%d>\n", user_id));
	_NFMdebug(( fname, "catalog   = <%s>\n", catalog));
	_NFMdebug(( fname, "item_name = <%s>\n", item_name));
	_NFMdebug(( fname, "item_rev  = <%s>\n", item_rev));

	/*  Get the "n_itemno" for this item  */

	status = NFMfl_get_item_no (catalog, item_name, item_rev, item_no);
	if( status != NFM_S_SUCCESS )
	  {
		_NFMdebug(( fname, "NFMfl_get_item_no = <0x%.8x>\n", status));
		return (status);
	  }

	/*  Get the "n_pendingflag" for this item  */

	sprintf (flag_s, "SELECT n_pendingflag FROM %s WHERE n_itemno = %s",
						 	   catalog,item_no);

	status = SQLquery (flag_s, &buffer, MEM_SIZE);
	if( status != SQL_S_SUCCESS )
	  {
		_NFMdebug(( fname, "SQLquery = <0x%.8x>\n", status));
		MEMclose (&buffer);
		ERRload_struct( NFM, NFM_E_SQL_QUERY, NULL, NULL );
	        return( NFM_E_SQL_QUERY );
	  }

	status = MEMbuild_array (buffer);
	if( status != MEM_S_SUCCESS )
	  {
		_NFMdebug(( fname, "MEMbuild_array = <0x%.8x>\n", status));
		MEMclose (&buffer);
		ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
     	        return( NFM_E_MEM );
	  }

	data = (char **) buffer->data_ptr;

   	/*  See if the item has been flagged as other than an item  */
  	if ((strcmp (data[0], "")) == 0)
	{
	   _NFMdebug(( fname, "%s\n", "Item has not been flagged"));
  	   ERRload_struct( NFM, NFM_E_ITEM_NOT_FLAGGED, "%s%s",
	 	item_name, item_rev );
	   return( NFM_E_ITEM_NOT_FLAGGED );
        }
  	else if ((strcmp (data[0], "MB")) == 0)
	{
	   _NFMdebug(( fname, "%s\n", "Item has been flagged as a set member, but it is NOT ok to cancel it here"));

	/** 8/26/92: OK to cancel "M?" flags now. **/
	/** 9/2/92: This decision is changed back **/

  	   ERRload_struct( NFM, NFM_E_ITEM_FLAG_SET_MEM, "%s%s",
	 			item_name, item_rev );
	   return( NFM_E_ITEM_FLAG_SET_MEM );
	}
  	else if ((strcmp (data[0], "PB")) == 0)
	{
	   _NFMdebug(( fname, "%s\n", "Item has been flagged as a project member"));
  	   ERRload_struct( NFM, NFM_E_ITEM_FLAG_PROJ_MEM, "%s%s",
				item_name, item_rev );
	   return( NFM_E_ITEM_FLAG_PROJ_MEM );
	}
 	else if ( strcmp( data[0], "IB") != 0 )
	{
 	    _NFMdebug(( fname, "%s\n", "Item not flagged as an item"));
	    ERRload_struct( NFM, NFM_E_NOT_FLAGGED_AS_ITEM_BACKU,
			 	"%s%s", item_name, item_rev );
	    return( NFM_E_NOT_FLAGGED_AS_ITEM_BACKU );
	}

    /*  Set the "n_pendingflag" for all files for this item to ""  */

        sprintf (flag_s, "UPDATE %s SET n_pendingflag = NULL WHERE n_itemno = %s",	catalog, item_no);
 	status = SQLstmt (flag_s);
  	if( status != SQL_S_SUCCESS )
	{
	    MEMclose( &buffer );
	    _NFMdebug(( fname, "SQLstmt = <0x%.8x>\n", status));
	    ERRload_struct( NFM, NFM_E_CANCEL_BACKUP_FLAG, "%s%s",
			 item_name, item_rev );
 	    return( NFM_E_CANCEL_BACKUP_FLAG );
	}
	MEMclose (&buffer);

	_NFMdebug(( fname, "%s\n", "Returning NFM_S_SUCCESS ..."));
	return (NFM_S_SUCCESS);
  }

/*
Doc:	NFMcancel_item_restore_flag

 Abstract:
     This function will cancel flags for restore utility operations.

 History:
     Jill McCutcheon  November 14, 1990 - Creation

 */

long NFMcancel_item_restore_flag (user_id, catalog, item_name, item_rev)
  long	user_id;
  char	*catalog;
  char	*item_name;
  char	*item_rev;
  {
	long	status;
	int	i;
        int     flagged_item;
        int     flagged_restore;

	char	**data;
	char	item_no[20];

	MEMptr	buffer = NULL;

	extern	long NFMfl_get_item_no ();
	extern	long MEMbuild_array ();
	extern	long SQLquery ();
	extern	long SQLstmt ();

	static  char *fname = "NFMcancel_item_restore";

	_NFMdebug(( fname, "user_id   = <%d>\n", user_id));
	_NFMdebug(( fname, "catalog   = <%s>\n", catalog));
	_NFMdebug(( fname, "item_name = <%s>\n", item_name));
	_NFMdebug(( fname, "item_rev  = <%s>\n", item_rev));

	/*  Get the "n_itemno" for this item  */

	status = NFMfl_get_item_no (catalog, item_name, item_rev, item_no);
	if(status != NFM_S_SUCCESS )
	  {
		_NFMdebug(( fname, "NFMfl_get_item_no = <0x%.8x>\n", status));
		return (status);
	  }

	/*  Get the "n_pendingflag" for this item  */

	sprintf (flag_s, "SELECT n_pendingflag FROM %s WHERE n_itemno = %s",
			catalog,item_no);

	status = SQLquery (flag_s, &buffer, MEM_SIZE);
	if( status != SQL_S_SUCCESS)
	  {
		_NFMdebug(( fname, "SQLquery = <0x%.8x>\n", status));
		MEMclose (&buffer);
		ERRload_struct( NFM, NFM_E_SQL_QUERY, NULL, NULL );
	        return( NFM_E_SQL_QUERY );
	  }

	status = MEMbuild_array (buffer);
	if(status != MEM_S_SUCCESS)
	  {
		_NFMdebug(( fname, "MEMbuild_array = <0x%.8x>\n", status));
		MEMclose (&buffer);
		ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
     	        return( NFM_E_MEM );
	  }

	data = (char **) buffer->data_ptr;

        /*  See if the item has been flagged as other than an item  */
        if ((strcmp (data[0], "")) == 0)
	{
	    _NFMdebug(( fname, "%s\n", "Item has not been flagged"));
  	    ERRload_struct( NFM, NFM_E_ITEM_NOT_FLAGGED, "%s%s",
			 item_name, item_rev );
	    return( NFM_E_ITEM_NOT_FLAGGED );
	}
  	else if ((strcmp (data[0], "MR")) == 0)
	{
	   _NFMdebug(( fname, "%s\n", "Item has been flagged as a set member, it is NOT ok to cancel it"));

  	   ERRload_struct( NFM, NFM_E_ITEM_FLAG_SET_MEM, "%s%s",
	 			item_name, item_rev );
	   return( NFM_E_ITEM_FLAG_SET_MEM );
	}
  	else if ((strcmp (data[0], "PR")) == 0)
	{
	   _NFMdebug(( fname, "%s\n", "Item has been flagged as a project member"));
  	   ERRload_struct( NFM, NFM_E_ITEM_FLAG_PROJ_MEM, "%s%s",
				item_name, item_rev );
	   return( NFM_E_ITEM_FLAG_PROJ_MEM );
	}
        else if ( strcmp( data[0], "IR") != 0 )
        {
 	    _NFMdebug(( fname, "%s\n","Item not flagged as an item"));
	    ERRload_struct( NFM, NFM_E_NOT_FLAGGED_AS_ITEM_RESTO,
				 "%s%s", item_name, item_rev );
	    return( NFM_E_NOT_FLAGGED_AS_ITEM_RESTO );
        }
	/*  Set the "n_pendingflag" for all files for this item to ""  */

	sprintf (flag_s, "UPDATE %s SET n_pendingflag = NULL WHERE n_itemno = %s",catalog, item_no);

	status = SQLstmt (flag_s);
  	if( status != SQL_S_SUCCESS )
	{
	    _NFMdebug(( fname, "SQLstmt = <0x%.8x>\n", status));
	    MEMclose( &buffer );
	    ERRload_struct( NFM, NFM_E_CANCEL_RESTORE_FLAG, "%s%s",
			 item_name, item_rev );
 	    return( NFM_E_CANCEL_RESTORE_FLAG );
	}

	sprintf (flag_s, "UPDATE f_%s SET n_restoreflag = NULL WHERE n_itemnum = %s",catalog, item_no);

	status = SQLstmt (flag_s);
  	if( status != SQL_S_SUCCESS )
	{

         /* FIX by kumar for PDM to take care parametric parts which do not
            have f_catalog entries - 10.21.93 */

	sprintf (flag_s, "SELECT n_catalogno FROM nfmcatalogs WHERE n_catalogname = %s AND n_type in ('CID','EID', 'P') ", catalog);
	status = SQLquery (flag_s, &buffer, MEM_SIZE);
	if( status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND)
	  {
	    _NFMdebug(( fname, "SQLstmt = <0x%.8x>\n", status));
	    MEMclose( &buffer );
	    ERRload_struct( NFM, NFM_E_CANCEL_RESTORE_FLAG, "%s%s",
			 item_name, item_rev );
 	    return( NFM_E_CANCEL_RESTORE_FLAG );
	  }
	MEMclose (&buffer);
        }

	_NFMdebug(( fname, "%s\n", "Returning NFM_S_SUCCESS ..."));
	return (NFM_S_SUCCESS);
  }

/*
 Doc:	NFMcancel_item_delete_flag

 Abstract:
     This function will cancel flags for delete utility operations.

 History:
     Jill McCutcheon  November 14, 1990 - Creation

 */

long NFMcancel_item_delete_flag (user_id, catalog, item_name, item_rev)
  long	user_id;
  char	*catalog;
  char	*item_name;
  char	*item_rev;
  {
	long	status;
	int	i;
        int     flagged_item;
        int     flagged_delete;

	char	**data;
	char	item_no[20];

	MEMptr	buffer = NULL;

	extern	long NFMfl_get_item_no ();
	extern	long MEMbuild_array ();
	extern	long SQLquery ();
	extern	long SQLstmt ();

	static  char *fname = "NFMcancel_item_delete_flag";

	_NFMdebug(( fname, "user_id   = <%d>\n", user_id));
	_NFMdebug(( fname, "catalog   = <%s>\n", catalog));
	_NFMdebug(( fname, "item_name = <%s>\n", item_name));
	_NFMdebug(( fname, "item_rev  = <%s>\n", item_rev));

	/*  Get the "n_itemno" for this item  */

	status = NFMfl_get_item_no (catalog, item_name, item_rev, item_no);
	if( status != NFM_S_SUCCESS )
	  {
		_NFMdebug(( fname, "NFMfl_get_item_no = <0x%.8x>\n", status));
		return (status);
	  }

	/*  Get the "n_pendingflag" for this item  */

	sprintf (flag_s, "SELECT n_pendingflag FROM %s WHERE n_itemno = %s",
						 	   catalog,item_no);

	status = SQLquery (flag_s, &buffer, MEM_SIZE);
	if( status != SQL_S_SUCCESS)
	  {
		_NFMdebug(( fname, "SQLquery = <0x%.8x>\n", status));
		MEMclose (&buffer);
		ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	        return( NFM_E_MEM );
	  }

	status = MEMbuild_array (buffer);
	if( status != MEM_S_SUCCESS)
	  {
		_NFMdebug(( fname, "MEMbuild_array= <0x%.8x>\n",status));
		MEMclose (&buffer);
		ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
     	        return( NFM_E_MEM );
	  }

	data = (char **) buffer->data_ptr;

        /*  See if the item has been flagged as other than an item  */
        if ((strcmp (data[0], "")) == 0)
	{
	   _NFMdebug(( fname, "%s\n", "Item has not been flagged"));
  	   ERRload_struct( NFM, NFM_E_ITEM_NOT_FLAGGED, "%s%s",
		 item_name, item_rev );
	   return( NFM_E_ITEM_NOT_FLAGGED );
	}
  	else if ((strcmp (data[0], "MD")) == 0)
	{
	   _NFMdebug(( fname, "%s\n", "Error: Item has been flagged as a set member"));
  	   ERRload_struct( NFM, NFM_E_ITEM_FLAG_SET_MEM, "%s%s",
	 			item_name, item_rev );
	   return( NFM_E_ITEM_FLAG_SET_MEM );
	}
  	else if ((strcmp (data[0], "PD")) == 0)
	{
	   _NFMdebug(( fname, "%s\n", "Item has been flagged as a project member"));
  	   ERRload_struct( NFM, NFM_E_ITEM_FLAG_PROJ_MEM, "%s%s",
				item_name, item_rev );
	   return( NFM_E_ITEM_FLAG_PROJ_MEM );
	}
        else if ( strcmp( data[0], "ID") != 0 )
        {
 	   _NFMdebug(( fname, "%s\n", "Item not flagged as an item"));
	   ERRload_struct( NFM, NFM_E_NOT_FLAGGED_AS_ITEM_DELET,
			 "%s%s", item_name, item_rev );
	   return( NFM_E_NOT_FLAGGED_AS_ITEM_DELET );
        }
	/*  Set the "n_pendingflag" for all files for this item to ""  */

  	sprintf (flag_s, "UPDATE %s SET n_pendingflag = NULL WHERE n_itemno = %s",catalog, item_no);
	status = SQLstmt (flag_s);
	if( status != SQL_S_SUCCESS )
	{
	    _NFMdebug(( fname, "SQLstmt = <0x%.8x>\n", status));
	    ERRload_struct( NFM, NFM_E_CANCEL_DELETE_FLAG, "%s%s",
			 item_name, item_rev );
 	    return( NFM_E_CANCEL_DELETE_FLAG );
	}
	MEMclose (&buffer);

	_NFMdebug(( fname, "%s\n", "Returning NFM_S_SUCCESS ..."));
	return (NFM_S_SUCCESS);
  }

long NFMcancel_item_flag (catalog, item_name, item_rev)
  char	*catalog;
  char	*item_name;
  char	*item_rev;
  {
	long	status;
        char    item_no[10];
	extern	long NFMfl_get_item_no ();
	extern	long SQLstmt ();
	static  char *fname = "NFMcancel_item_flag";

	_NFMdebug(( fname, "catalog   <%s>\n", catalog));
	_NFMdebug(( fname, "item_name <%s>\n", item_name));
	_NFMdebug(( fname, "item_rev  <%s>\n", item_rev));

	sprintf (flag_s, "UPDATE %s SET n_pendingflag = NULL WHERE n_itemname = '%s' AND n_itemrev = '%s' AND n_pendingflag IN ('IA','IB','IR','ID')", catalog, item_name, item_rev );
	status = SQLstmt (flag_s);
	if( status != SQL_S_SUCCESS)
        {
	    _NFMdebug(( fname, "SQLquery = <0x%.8x>\n", status));
	    ERRload_struct( NFM, NFM_E_CANCEL_ITEM_FLAG, "%s%s",
				 item_name, item_rev );
	    return( NFM_E_CANCEL_ITEM_FLAG );
	}

	/*  Get the "n_itemno" for this item  */

	status = NFMfl_get_item_no (catalog, item_name, item_rev, item_no);
	if( status != NFM_S_SUCCESS )
        {
	    _NFMdebug((fname," NFMfl_get_item_no = <0x%.8x>\n", status));
	    return (status);
	}

	sprintf (flag_s, "UPDATE f_%s SET n_restoreflag = NULL WHERE n_itemnum = %s AND n_restoreflag = 'IR'", catalog, item_no );
	status = SQLstmt (flag_s);
	if( status != SQL_S_SUCCESS)
        {
	    _NFMdebug(( fname, "SQLquery = <0x%.8x>\n", status));
/*
    Don't load an error message because the return status may be
    NO_ROWS_FOUND. We don't know if this is a cancel restore command
    so we must always clear that flag out even if it is not cancel
    restore.
	    ERRload_struct( NFM, NFM_E_CANCEL_ITEM_FLAG, "%s%s",
				 item_name, item_rev );
	    return( NFM_E_CANCEL_ITEM_FLAG );
*/
	}


	_NFMdebug(( fname, "%s\n", "Returning NFM_S_SUCCESS ..."));
	return (NFM_S_SUCCESS);
  }
