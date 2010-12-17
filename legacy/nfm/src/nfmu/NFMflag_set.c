#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMflag.h"
#include "ERR.h"
#include "DEBUG.h"
#include "NFMschema.h"

/*******************
#define NFM_E_SET_PRIME_MEMBER 11
*******************/

char	flag_s[512];
char	SET_NAME[512];

/*
 Doc:	NFMflag_set_*

 Abstract:
     These functions flag sets for archive, backup or restore utilities.

 History:
     Jill McCutcheon  November 14, 1990 - Creation
 */

long NFMflag_set_archive (user_id, catalog, set_name, set_rev)
  long	user_id;
  char	*catalog;
  char	*set_name;
  char	*set_rev;
  {
	long	status;
	char	flag[4];
	char	set_no[20];
	char	catalog_no[20];
	struct	NFMflag_node_st *head;
	long    NFMfl_flag_build_tree();
	long    NFMfl_flag_update_tree();
	void    NFMfl_flag_free_tree();

	static  char *fname = "NFMflag_set_archive";

	_NFMdebug(( fname, "catalog  = <%s>\n", catalog));
	_NFMdebug(( fname, "set_name = <%s>\n", set_name));
	_NFMdebug(( fname, "set_rev  = <%s>\n", set_rev));

        status = NFMstop_transaction (0);
        if (status != NFM_S_SUCCESS)
        {
          _NFMdebug ((fname, "NFMstop_transaction 0x%.8x\n", status));
          return (status);
        }

	strcpy(SET_NAME, set_name);

	/*  Get the catalog number for this set  */

	if((status = NFMfl_get_catalog_no (catalog, catalog_no)) 
			!= NFM_S_SUCCESS)
	  {
	    _NFMdebug(( fname, "NFMfl_get_catalog_no = <0x%.8x>\n", status));
            NFMrollback_transaction (0);
	    return (status);
	  }

	/*  Get the item number for this set  */

	if ((status = NFMfl_get_item_no (catalog, set_name, set_rev, set_no))
			!= NFM_S_SUCCESS)
	  {
	    _NFMdebug(( fname, "NFMfl_get_item_no = <0x%.8x>\n", status));
            NFMrollback_transaction (0);
	    return (status);
	  }

	/*  Initialize head of the set tree  */

	if ((head = (struct NFMflag_node_st *)
		malloc (sizeof (struct NFMflag_node_st))) == NULL)
	  {
		ERRload_struct( NFM, NFM_E_MALLOC, NULL, NULL );
                NFMrollback_transaction (0);
		return( NFM_E_MALLOC );
	  }

	strcpy (head->catalog_name, catalog);
	strcpy (head->catalog_no, catalog_no);
	strcpy (head->item_no, set_no);
	strcpy (head->ctype, "P");
	head->child = NULL;
	head->sibling = NULL;

	/*  Start the first pass, building the set tree  */

	if ((status = NFMfl_flag_build_tree (head, 0, ARCHIVE))!=NFM_S_SUCCESS)
	  {
	    _NFMdebug(( fname, "NFMfl_flag_build_tree = <0x%.8x>\n", status));
	    NFMfl_flag_free_tree (head);
            NFMrollback_transaction (0);
	    return (status);
	  }

	/*  Start the second pass, updating the flags  */

	strcpy (flag, "SA");
	if ((status = NFMfl_flag_update_tree (head, 0, flag)) != NFM_S_SUCCESS)
	  {
	    _NFMdebug(( fname, "NFMfl_flag_update_tree = <0x%.8x>\n", status));
	    NFMfl_flag_free_tree (head);
            NFMrollback_transaction (0);
	    return (status);
	  }

	/*  Update the nfmsetcit table */
	
	if ((status = NFMfl_update_nfmsetcit(catalog_no, set_no, "A")) 
		      != NFM_S_SUCCESS )
	  {
	    _NFMdebug(( fname, "NFMfl_update_nfmsetcit = <0x%.8x>\n", status));
 	    NFMfl_flag_free_tree (head);
            NFMrollback_transaction (0);
	    return (status);
	  }

	/*  Free space taken up by the set tree structure  */

	NFMfl_flag_free_tree (head);
     
        status = NFMstart_transaction (0);
        if (status != NFM_S_SUCCESS)
          _NFMdebug ((fname, "NFMstart_transaction 0x%.8x\n", status));

	_NFMdebug(( fname, "%s\n", "Returning NFM_S_SUCCESS ..."));
	return (NFM_S_SUCCESS);
  }

/*
Doc:	NFMflag_set_backup
*/

long NFMflag_set_backup (user_id, catalog, set_name, set_rev)
  long	user_id;
  char	*catalog;
  char	*set_name;
  char	*set_rev;
  {
	long	status;
	char	flag[4];
	char	set_no[20];
	char	catalog_no[20];
	struct	NFMflag_node_st *head;
        long    NFMfl_flag_build_tree();
	long    NFMfl_flag_update_tree();
	void    NFMfl_flag_free_tree();

	static  char *fname = "NFMflag_set_backup";

	_NFMdebug(( fname, "catalog   <%s>\n", catalog));
	_NFMdebug(( fname, "set_name  <%s>\n", set_name));
	_NFMdebug(( fname, "set_rev   <%s>\n", set_rev));

	/*  Get the catalog number for this set  */

	strcpy(SET_NAME, set_name);

	if ((status = NFMfl_get_catalog_no (catalog, catalog_no))
			 != NFM_S_SUCCESS)
	  {
	    _NFMdebug(( fname, "NFMfl_get_catalog_no = <0x%.8x>\n", status));
	    return (status);
	  }

	/*  Get the item number for this set  */

	if ((status = NFMfl_get_item_no (catalog, set_name, set_rev, set_no))
			!= NFM_S_SUCCESS)
	  {
	    _NFMdebug(( fname, "NFMfl_get_item_no = <0x%.8x>\n", status));
	    return (status);
	  }

	/*  Initialize head of the set tree  */

	if ((head = (struct NFMflag_node_st *)
		malloc (sizeof (struct NFMflag_node_st))) == NULL)
	  {
		ERRload_struct( NFM, NFM_E_MALLOC, NULL, NULL );
		return( NFM_E_MALLOC );
	  }

	strcpy (head->catalog_name, catalog);
	strcpy (head->catalog_no, catalog_no);
	strcpy (head->item_no, set_no);
	strcpy (head->ctype, "P");
	head->child = NULL;
	head->sibling = NULL;

	/*  Start the first pass, building the set tree  */

	if ((status = NFMfl_flag_build_tree (head, 0, BACKUP))
			!= NFM_S_SUCCESS)
	  {
		_NFMdebug(( fname, "NFMfl_flag_build_tree = <0x%.8x>\n",
			  status));
		NFMfl_flag_free_tree (head);
		return (status);
	  }

	/*  Start the second pass, updating the flags  */

	strcpy (flag, "SB");
	if ((status = NFMfl_flag_update_tree (head, 0, flag))
			!= NFM_S_SUCCESS)
	  {
	    _NFMdebug(( fname, "NFMfl_flag_update_tree = <0x%.8x>\n", status));
	    NFMfl_flag_free_tree (head);
	    return (status);
	  }

	/*  Update the nfmsetcit table */
	
	if((status = NFMfl_update_nfmsetcit( catalog_no, set_no, "B" ) )
			!= NFM_S_SUCCESS )
	  {
	    _NFMdebug(( fname, "NFMfl_update_nfmsetcit = <0x%.8x>\n", status));
	    NFMfl_flag_free_tree (head);
	    return (status);
	  }

	/*  Free space taken up by the set tree structure  */

	NFMfl_flag_free_tree (head);

	_NFMdebug(( fname, "%s\n", "Returning NFM_S_SUCCESS ..."));
	return (NFM_S_SUCCESS);
  }

/*
Doc:	NFMflag_set_restore
*/

long NFMflag_set_restore (user_id, catalog, set_name, set_rev)
  long	user_id;
  char	*catalog;
  char	*set_name;
  char	*set_rev;
  {
	long	status;
	char	flag[4];
	char	set_no[20];
	char	catalog_no[20];
	struct	NFMflag_node_st *head;
	long    NFMfl_flag_build_tree();
	long    NFMfl_flag_update_tree();
        void    NFMfl_flag_free_tree();

	static  char *fname = "NFMflag_set_restore";

	_NFMdebug(( fname, "catalog   <%s>\n", catalog));
	_NFMdebug(( fname, "set_name  <%s>\n", set_name));
	_NFMdebug(( fname, "set_rev   <%s>\n", set_rev));

	strcpy(SET_NAME, set_name);

	/*  Get the catalog number for this set  */

	if ((status = NFMfl_get_catalog_no (catalog, catalog_no)) 
			!= NFM_S_SUCCESS)
	  {
	    _NFMdebug(( fname, "NFMfl_get_catalog_no = <0x%.8x>\n",
			  status));
	    return (status);
	  }

	/*  Get the item number for this set  */

	if ((status = NFMfl_get_item_no (catalog, set_name, set_rev, set_no))
			!= NFM_S_SUCCESS)
	  {
	    _NFMdebug(( fname, "NFMfl_get_item_no = <0x%.8x>\n",  status));
	    return (status);
	  }

	/*  Initialize head of the set tree  */

	if ((head = (struct NFMflag_node_st *)
		malloc (sizeof (struct NFMflag_node_st))) == NULL)
	  {
		ERRload_struct( NFM, NFM_E_MALLOC, NULL, NULL );
		return( NFM_E_MALLOC );
	  }

	strcpy (head->catalog_name, catalog);
	strcpy (head->catalog_no, catalog_no);
	strcpy (head->item_no, set_no);
	strcpy (head->ctype, "P");
	head->child = NULL;
	head->sibling = NULL;

	/*  Start the first pass, building the set tree  */

	if ((status = NFMfl_flag_build_tree (head, 0, RESTORE))
			!= NFM_S_SUCCESS)
	  {
	    _NFMdebug(( fname, "NFMfl_flag_build_tree = <0x%.8x>\n", status));
	    NFMfl_flag_free_tree (head);
	    return (status);
	  }

	/*  Start the second pass, updating the flags  */

	strcpy (flag, "SR");
	if ((status = NFMfl_flag_update_tree (head, 0, flag))
			!= NFM_S_SUCCESS )
	  {
	    _NFMdebug(( fname, "NFMfl_flag_update_tree = <0x%.8x>\n", status));
	    NFMfl_flag_free_tree (head);
	    return (status);
	  }

	/*  Update the nfmsetcit table */
	
	if((status = NFMfl_update_nfmsetcit( catalog_no, set_no, "R" ) )
			!= NFM_S_SUCCESS )
	  {
	    _NFMdebug(( fname, "NFMfl_update_nfmsetcit = <0x%.8x>\n", status));
	    NFMfl_flag_free_tree (head);
	    return (status);
	  }

	/*  Free space taken up by the set tree structure  */

	NFMfl_flag_free_tree (head);

	_NFMdebug(( fname, "%s\n", "Returning SUCCESS ..."));
	return (NFM_S_SUCCESS);
  }

/*
Doc:	NFMfl_flag_validate_set
Returns:
		0 on success,
		non-0 if not valid for flagging
	This is called by build_tree for validating members of a set. 
	A member of a set could be an item or another set 
*/

long NFMfl_flag_validate_set (catalog, set_no, ctype, op_flag)
  char	*catalog;    /*  i - catalog name that the set is in           */
  char	*set_no;     /*  i - item number of the set                    */
  char	*ctype;      /*  i - "P" primary or "S" secondary member       */
  short	op_flag;     /*  i - validate for a specific operation or not  */
  {
	long	status;
	char	**data;
	char	n_status[5];
	char	archstate[5];

	MEMptr	buffer = NULL;

	static  char *fname = "NFMfl_flag_validate_set";

	_NFMdebug(( fname, "catalog    <%s>\n", catalog));
	_NFMdebug(( fname, "set_no     <%s>\n", set_no));
	_NFMdebug(( fname, "ctype      <%s>\n", ctype));
	_NFMdebug(( fname, "op_flag    <%d>\n", op_flag));

	/*  If this is not a restore operation,
	    check to see if this set has a file, and if it
	    is a primary member, see if it is checked in  */

	if ((op_flag == ARCHIVE) || (op_flag == BACKUP))
	  {
		sprintf (flag_s, "SELECT n_archivestate,n_status FROM %s WHERE n_itemno = %s",catalog, set_no);
		if ((status = SQLquery (flag_s, &buffer, MEM_SIZE))
				!= SQL_S_SUCCESS )
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

		/*  Check "n_archivestate" in the catalog to see
		    if this set has a file and if it is on disk.
		    Possible archive states are "A" (archived-not
		    ON-LINE), "B" (backed up but ON-LINE), and
		    "" (no previous action)
		  */

		if ((strcmp (archstate, "A")) == 0)
		  {
			_NFMdebug(( fname, "%s\n", "File is archived"));
			ERRload_struct( NFM, NFM_E_SET_ARCHIVED, "%s",SET_NAME);
			return( NFM_E_SET_ARCHIVED );
		  }

		/*  Check primary members only for checked in status  */

		if ((op_flag == ARCHIVE) && (strcmp (ctype, "P")) == 0)
		  {
		/* Check "n_status" to see if this set's file is checked in  */

			if ((strcmp (n_status, "SN") == 0) ||
			    (strcmp (n_status, "O") == 0)  ||
			    (strcmp (n_status, "M") == 0)  ||
			    (strcmp (n_status, "S") == 0))
			  {
				_NFMdebug(( fname, "%s\n",
					"File is not checked in"));
				ERRload_struct( NFM,NFM_E_SET_MEMBER_OUT, "%s",
						 SET_NAME );
				return( NFM_E_SET_MEMBER_OUT );
			  }
		  }
	  }

	/*  Check the "n_pendingflag" for this set's files
	    to make sure that there are no other requests pending  */

	sprintf (flag_s, "SELECT n_pendingflag FROM %s WHERE n_itemno = %s",
		 catalog, set_no );
	status = SQLquery (flag_s, &buffer, MEM_SIZE);
	if( status != SQL_S_SUCCESS )
	  {
		_NFMdebug(( fname, "SQLquery = <0x%.8x>\n", status));
		MEMclose (&buffer);
		return( status );
	  }
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
  	        /*  The current pending flag is legal if it is "","MA"
		    8/27/92: only "" and MA are valid.
  	            The current pending flag is legal if it is "","IA","MA"
		    10/21/93: -kumar
		 */
		  if( (strcmp( data[0], ""   ) == 0) ||
		      (strcmp( data[0], "IA"   ) == 0) ||
		      (strcmp( data[0], "MA" ) == 0))
		{
		     /** (strcmp( data[0], "SA" ) == 0) ) used to here**/
    		_NFMdebug(( fname, "Set flag <%s>\n", data[0] ));
    		break;
		}
		else
		{
			ERRload_struct(NFM, NFM_E_SET_FLAGGED, "%s", SET_NAME);
			MEMclose (&buffer);
			return( NFM_E_SET_FLAGGED );
		}

 	        case  BACKUP:
		/*  The current pending flag is legal if it is "","IB","MB"
                  Kumar 10.21.93
	         */
	 	    if( (strcmp( data[0], ""   ) == 0) ||
	 	        (strcmp( data[0], "IB"   ) == 0) ||
			(strcmp( data[0], "MB" ) == 0))
		{
		/**	(strcmp( data[0], "SB" ) == 0) )**/
    		_NFMdebug(( fname, "Set flag <%s>\n", data[0] ));
    		break;
		}
		else
		{
 			ERRload_struct(NFM, NFM_E_SET_FLAGGED, "%s", SET_NAME);
			MEMclose (&buffer);
			return( NFM_E_SET_FLAGGED );
	 	}

 	        case  RESTORE:
		/*  The current pending flag is legal if it is "","IR","MR"
                    Kumar - 10.21.93
		 */
		    if( (strcmp( data[0], ""   ) == 0) ||
		        (strcmp( data[0], "IR"   ) == 0) ||
			(strcmp( data[0], "MR" ) == 0))
		{
		/**	(strcmp( data[0], "SR" ) == 0) )**/
    		_NFMdebug(( fname, "Set flag <%s>\n", data[0] ));
    		break;
		}
		else
		{
	              ERRload_struct(NFM, NFM_E_SET_FLAGGED, "%s", SET_NAME);
		      MEMclose (&buffer);
		      return( NFM_E_SET_FLAGGED );
		}

 	        default:
		    break;
		}

	_NFMdebug(( fname, "%s\n", "Returning SUCCESS ..."));
	return (NFM_S_SUCCESS );
  }

/*
Doc:	NFMfl_flag_get_set_members

		Return buffer format:
			n_catalogname char(20)
			n_catalogno   integer
			n_itemno      integer
			n_ctype       char(1)
*/

long NFMfl_flag_get_set_members (catalog_no, set_no, level, buffer)
  char		*catalog_no;  /*  i - catalog number of the parent  */
  char		*set_no;      /*  i - item number of the parent     */
  long		level;        /*  i - level of the parent           */
  MEMptr	*buffer;      /*  o - return output buffer          */
  {
	int	i;
	long	status;

	char	**data;
	char	catalog_name[20];
        char    fmt[20];

	MEMptr	tmp = NULL;

	static  char *fname = "NFMfl_flag_get_set_members";

	_NFMdebug(( fname, "catalog_no   <%s>\n", catalog_no));
	_NFMdebug(( fname, "set_no       <%s>\n", set_no));
	_NFMdebug(( fname, "level        <%d>\n", level));

	/*  Query the nfmsetcit to get information about the set's members  */

	sprintf (flag_s, "SELECT n_ccatalogno,n_citemno,n_type FROM nfmsetcit WHERE n_pcatalogno = %s AND n_pitemno = %s", catalog_no, set_no);
	if ((status = SQLquery (flag_s, &tmp, MEM_SIZE)) != SQL_S_SUCCESS )
	  {
		_NFMdebug(( fname, "SQLquery = <0x%.8x>\n", status));
		MEMclose (&tmp);

		if ((status == SQL_I_NO_ROWS_FOUND))
		{
			return( SQL_I_NO_ROWS_FOUND );
		}
		else
		{
			return( status );
		}
	  }

	if ((status = MEMbuild_array (tmp)) != MEM_S_SUCCESS)
	  {
		MEMclose (&tmp);
		return( status );
	  }

	/*  Open the return buffer  */

	if ((status = MEMopen (buffer, MEM_SIZE)) != MEM_S_SUCCESS )
	  {
		MEMclose (&tmp);
		MEMclose (buffer);
		return( status );
	  }

        sprintf( fmt, "char(%d)", NFM_CATALOGNAME );
	if ((status = MEMwrite_format (*buffer, "n_catalogname", fmt)) != MEM_S_SUCCESS)
	  {
		_NFMdebug(( fname, "MEMwrite_format = <0x%.8x>\n", status));
		MEMclose (&tmp);
		MEMclose (buffer);
		return( status );
	  }

	if ((status = MEMwrite_format (*buffer, "n_catalogno", "integer")) != MEM_S_SUCCESS)
	  {
		_NFMdebug(( fname, "MEMwrite_format = <0x%.8x>\n", status));
		MEMclose (&tmp);
		MEMclose (buffer);
		return( status );
	  }

	if ((status = MEMwrite_format (*buffer, "n_itemno", "integer")) != MEM_S_SUCCESS)
	  {
		_NFMdebug(( fname, "MEMwrite_format = <0x%.8x>\n", status));
		MEMclose (&tmp);
		MEMclose (buffer);
		return( status );
	  }

	if ((status = MEMwrite_format (*buffer, "n_ctype", "char(1)")) != MEM_S_SUCCESS)
	  {
		_NFMdebug(( fname, "MEMwrite_format = <0x%.8x>\n", status));
		MEMclose (&tmp);
		MEMclose (buffer);
		return (status);
	  }

	/*  Get the catalog names from the nfmcatalogs table  */

	data = (char **) tmp->data_ptr;
	for (i = 0; i < tmp->rows * tmp->columns; i += tmp->columns)
	  {
		if ((status = NFMfl_get_catalog_name (data[i], catalog_name))
				!= NFM_S_SUCCESS )
		  {
			_NFMdebug(( fname, "NFMfl_get_catalog_name = <0x%.8x>\n",status));
			MEMclose (&tmp);
			MEMclose (buffer);
			return (status);
		  }

		/*  Only put in the real ctype for first level members  */

/*******************This seems wrong to me. I changed it --DEP
		if (level == 0)
		  {
			sprintf (flag_s, "%s\1%s\1%s\1%s",
				catalog_name, data[i], data[i + 1], data[i + 2]);
		  }
		else
		  {
			sprintf (flag_s, "%s\1%s\1%s\1%s",
				catalog_name, data[i], data[i + 1], "S");
		  }
**********************/

		sprintf (flag_s, "%s\1%s\1%s\1%s",
			catalog_name, data[i], data[i + 1], data[i + 2]);

		if ((status = MEMwrite (*buffer, flag_s)) != MEM_S_SUCCESS)
		  {
			_NFMdebug(( fname, "MEMwrite = <0x%.8x>\n", status));
			MEMclose (&tmp);
			MEMclose (buffer);
			return (status);
		  }
	  }

	/*  Close the temporary buffer  */

	MEMclose (&tmp);

	if ((status = MEMbuild_array (*buffer)) != MEM_S_SUCCESS)
	  {
		_NFMdebug(( fname, "MEMbuild_array = <0x%.8x>\n", status));
		MEMclose (buffer);
		return (status );
	  }

	_NFMdebug(( fname, "%s\n", "Returning SUCCESS ..."));
	return (NFM_S_SUCCESS);
  }

/* 
Doc:	NFMfl_update_nfmsetcit
*/

NFMfl_update_nfmsetcit( catalog_no, set_no, flag )
  char *catalog_no;
  char *set_no;
  char *flag;
  {
    long	status;

    static      char *fname = "NFMfl_update_nfmsetcit";

    _NFMdebug(( fname, "catalog_no = <%s>\n",catalog_no ));
    _NFMdebug(( fname, "set_no     = <%s>\n",set_no ));
    _NFMdebug(( fname, "flag       = <%s>\n",flag ));

/*  Update the nfmsetcit  */

    sprintf (flag_s, "UPDATE nfmsetcit SET n_archiveflag = '%s' WHERE n_pcatalogno = %s AND n_pitemno = %s", flag, catalog_no, set_no);
	if ((status = SQLstmt (flag_s) ) != SQL_S_SUCCESS )
	  {
		_NFMdebug(( fname, "SQLstmt = <0x%.8x>\n", status));
		ERRload_struct( NFM, NFM_E_UPDATE_SETCIT, "%s", set_no );
		return( NFM_E_UPDATE_SETCIT );
	  }
    return (NFM_S_SUCCESS);
  }

/*
Doc:	NFMfl_flag_validate_set_item
	Called by build_tree for validating head of the tree (level 0)
	This is always a set.
*/

long NFMfl_flag_validate_set_item (catalog, item_no, op_flag)
  char	*catalog;     /*  i  */
  char	*item_no;     /*  i  */
  int	op_flag;      /*  i - validate for a specific operation or not  */
  {
	long	status;
	char	**data;

	char	n_status[5];
	char	n_setind[5];
	char	archstate[5];
	char 	itemname[NFM_ITEMNAME+1];
	char    max_version[10];

	MEMptr	buffer = NULL;

	static  char *fname = "NFMfl_flag_validate_set_item";

	_NFMdebug(( fname, "catalog = <%s>\n", catalog));
	_NFMdebug(( fname, "item_no = <%s>\n", item_no));
	_NFMdebug(( fname, "op_flag = <%d>\n", op_flag));

	/*  If this is not a backup or restore operation, check "n_status" in
	    the catalog to see if this item has a file and if it is checked in
	*/

	if (op_flag == ARCHIVE)
	{
		sprintf(flag_s,
		"SELECT b.n_citno FROM nfmcatalogs a, nfmsetcit b WHERE a.n_catalogname = '%s' AND b.n_ccatalogno = a.n_catalogno AND b.n_citemno = %s AND b.n_type = 'P'", catalog, item_no);
		status = SQLquery (flag_s, &buffer, MEM_SIZE);

		if(status == SQL_S_SUCCESS)
		{
		_NFMdebug(( fname, "SET <%s> is a PRIMARY member of a set\n",
					SET_NAME));
			status = NFM_E_SET_PRIME_MEMBER;
			ERRload_struct(NFM, status, "%s", SET_NAME);
			MEMclose (&buffer);
			return( status );
		}
		else if(status != SQL_I_NO_ROWS_FOUND)
		{
		 _NFMdebug(( fname, "Warning: An ERROR occured in the sql query!!! Status = <0x%.8x>\n", status));
			 MEMclose(&buffer);
		}

	} /** op_flag == ARCHIVE **/
	buffer = NULL;
	sprintf (flag_s, "SELECT n_itemname, n_archivestate,n_status,n_setindicator FROM %s WHERE n_itemno = %s", catalog, item_no);
	if ((status = SQLquery (flag_s, &buffer, MEM_SIZE)) != SQL_S_SUCCESS )
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
	strcpy (itemname, data[0]);
	strcpy (archstate, data[1]);
	strcpy (n_status, data[2]);
	strcpy (n_setind, data[3]);
	MEMclose (&buffer);

	if(strcmp (n_setind, "Y") != 0 &&
           strcmp (n_setind, "D") != 0 &&
           strcmp (n_setind, "F") != 0 &&
           strcmp (n_setind, "G") != 0 &&
           strcmp (n_setind, "A") != 0     )
	{
		_NFMdebug(( fname,"Item %s is not a SET!\n",itemname ));
		ERRload_struct( NFM, NFM_E_NOT_SET, "%s", itemname );
		return( NFM_E_NOT_SET );
	}
				
	/*  Check "n_archstate" in the catalog to see
	    if this item has a file and if it is on disk.
	    The only state we are concerned with is "A"
	    because that means the file is not ON-LINE.
	    Other possible states are ""(no previous action)
	    and "B" (backed up).
	 */

	if ((strcmp (archstate, "A")) == 0)
	{
		_NFMdebug(( fname, "Item %s is archived\n", itemname ));
		ERRload_struct( NFM, NFM_E_ITEM_ARCHIVED, "%s", itemname );
		return( NFM_E_ITEM_ARCHIVED );
	}
	/*  Check "n_status" in the catalog to see
	    if this item has a file that is checked in  */

	if ((op_flag == ARCHIVE) && 
	    ((strcmp (n_status, "O") == 0) || (strcmp (n_status, "SN") == 0)))
	{
	    /**Item checkedout with no files (strcmp (n_status, "M") == 0) ||**/

		_NFMdebug(( fname, "%s\n", "File is not checked in"));
		ERRload_struct( NFM, NFM_E_ITEM_OUT, "%s", itemname);
		return( NFM_E_ITEM_OUT );
	}

	/*  Get the maximum fileversion for this item number */
	
	sprintf (flag_s, "SELECT MAX(n_fileversion) FROM f_%s WHERE n_itemnum = %s", catalog, item_no );

	if ((status = SQLquery (flag_s, &buffer, MEM_SIZE)) != SQL_S_SUCCESS)
	  {
		_NFMdebug(( fname, "SQLquery = <0x%.8x>\n", status));
		MEMclose (&buffer);
		return( status );
	  }
	else
	  {
	      if ((status = MEMbuild_array (buffer)) != MEM_S_SUCCESS)
		{
		    _NFMdebug(( fname, "MEMbuild_array = <0x%.8x>\n", status));
		    MEMclose (&buffer);
		    return( status );
		}

		data = (char **) buffer->data_ptr;
		strcpy( max_version, data[0] );
		MEMclose( &buffer );
	  }
	/*  Check the "n_pendingflag" for this item's files
	 *  to make sure that there are no other requests pending.
	 */
	
	sprintf (flag_s, "SELECT n_pendingflag,n_itemname,n_setindicator FROM %s WHERE n_itemno = %s", catalog, item_no );

	if ((status = SQLquery (flag_s, &buffer, MEM_SIZE)) != SQL_S_SUCCESS)
	  {
		_NFMdebug(( fname, "SQLquery = <0x%.8x>\n", status));
		MEMclose (&buffer);
		return( status );
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

		if(strcmp (data[2], "Y") != 0 &&
                   strcmp (data[2], "D") != 0 &&
                   strcmp (data[2], "F") != 0 &&
                   strcmp (data[2], "G") != 0 &&
                   strcmp (data[2], "A") != 0     )
		{
			_NFMdebug(( fname,"Item %s is not a SET!\n",data[1] ));
			ERRload_struct( NFM, NFM_E_NOT_SET, "%s",
					 data[1] );
			return( NFM_E_NOT_SET );
		}
		switch( op_flag )
		{
		    case  ARCHIVE:
		    /*  The current pending flag is legal if it 
		     *  is "" or "SA"
		     */
			if( strcmp( data[0], ""   ) == 0 ||
			    strcmp( data[0], "SA" ) == 0 )
			{
				/** or "MB" according to the new rule ?**/
    				_NFMdebug((fname,"Item <%s> ,flag <%s> is OK\n",					   data[1], data[0] ));
    				break;
			}
			else
			{
			    ERRload_struct( NFM, NFM_E_ITEM_FLAGGED, "%s",
					     data[1]);
			    MEMclose (&buffer);
			    return( NFM_E_ITEM_FLAGGED );
			}

		    case  BACKUP:
		    /*  The current pending flag is legal if it 
		     *  is "" or "SB"
		     */
			if( strcmp( data[0], ""   ) == 0 ||
			    strcmp( data[0], "SB" ) == 0 )
{
    _NFMdebug(( fname, "Item flag <%s>\n", data[0] ));
    break;
}
			else
			{
			    ERRload_struct( NFM, NFM_E_ITEM_FLAGGED, "%s",
					     item_no);
			    MEMclose (&buffer);
			    return( NFM_E_ITEM_FLAGGED );
			}

		    case  RESTORE:
		    /*  The current pending flag is legal if it 
			is "" or "SR"
		     */
			if( strcmp( data[0], ""   ) == 0 ||
			    strcmp( data[0], "SR" ) == 0 )
			{
    			    _NFMdebug(( fname, "Item <%s>, flag <%s> is OK\n",
					 data[1], data[0] ));
    			    break;
			}
			else
			{
			    ERRload_struct( NFM, NFM_E_ITEM_FLAGGED, "%s",
					     data[1]);
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
