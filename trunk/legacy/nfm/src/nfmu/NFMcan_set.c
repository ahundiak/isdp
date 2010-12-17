#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "MSGstruct.h"
#include "NFMerrordef.h"
#include "NFMflag.h"
#include "ERR.h"
#include "DEBUG.h"

char	flag_s[512];

/**************************************************************************
 *
 *  NFMfl_cancel_build_tree (), NFMfl_cancel_update_tree (),
 *  NFMfl_cancel_update_tree_new (), and NFMfl_cancel_build_tree_new ()
 *  are now in cmdtools due to include file dependencies with the
 *  prototype files - Glenn Scott 2/26/92
 *
 **************************************************************************/

/*
 Doc: NFMcancel_set_archive_flag

 Abstract:
     This function will cancel set flags for archive utility operations.

 History:
     Jill McCutcheon  November 14, 1990 - Creation

 */

long NFMcancel_set_archive_flag (user_id, catalog, set_name, set_rev)
  long	user_id;
  char	*catalog;
  char	*set_name;
  char	*set_rev;
  {
	long	status;
	char	set_no[20];
	char	catalog_no[20];
	char    utility;
	struct	NFMflag_node_st *head;

	long	NFMfl_cancel_build_tree ();
	long	NFMfl_cancel_update_tree ();
	long    NFMfl_check_set_flag();

	extern	void NFMfl_flag_free_tree ();
	extern	long NFMfl_get_catalog_no ();
	extern	long NFMfl_get_item_no ();

	static  char *fname = "NFMcancel_set_archive";

	_NFMdebug(( fname, "user_id  = <%d>\n", user_id));
	_NFMdebug(( fname, "catalog  = <%s>\n", catalog));
	_NFMdebug(( fname, "set_name = <%s>\n", set_name));
	_NFMdebug(( fname, "set_rev  = <%s>\n", set_rev));

	utility = 'A';

	/*  Get the catalog number for the catalog  */

	if((status=NFMfl_get_catalog_no (catalog, catalog_no))!= NFM_S_SUCCESS)
	  {
		_NFMdebug((fname,"NFMfl_get_catalog_no = <0x%.8x>\n", status));
		return (status);
	  }

	/*  Get the "n_itemno" for this set  */

	if( (status = NFMfl_get_item_no (catalog, set_name, set_rev,
			set_no)) != NFM_S_SUCCESS)
	  {
		_NFMdebug((fname, "NFMfl_get_item_no = <0x%.8x>\n", status));
		return (status);
	  }

	/*  See if the set is flagged */

	if( (status = NFMfl_check_set_flag (catalog_no, set_name, set_rev, 
					    set_no, "A" )) != NFM_S_SUCCESS)
	  {
		_NFMdebug(( fname, "NFMfl_check_set_flag = <0x%.8x>\n", 
				status ));
	  	return (status);
	  }			

	/*  Initialize head of the set tree  */

	if ((head = (struct NFMflag_node_st *)
		malloc (sizeof (struct NFMflag_node_st))) == NULL)
	  {
		_NFMdebug((fname, "%s\n","malloc failed"));
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

	status = NFMfl_cancel_build_tree (head, 0, utility );
	if( (status != NFM_S_SUCCESS) && (status != NFM_E_MEMBER_NOT_FLAGGED))
	  {
		_NFMdebug((fname, "NFMcancel_build_tree = <0x%.8x>\n",status));
		NFMfl_flag_free_tree (head);
		return (status);
	  }

	/*  Start the second pass, updating the flags  */

	if ((status = NFMfl_cancel_update_tree (head)) != NFM_S_SUCCESS)
	  {
		_NFMdebug((fname, "NFMfl_cancel_update_tree = <0x%.8x>\n",
			   status));
		NFMfl_flag_free_tree (head);
		return (status);
	  }

	/*  Free space taken up by the set tree structure  */

	NFMfl_flag_free_tree (head);

	_NFMdebug(( fname, "%s\n", "returning NFM_S_SUCCESS ..."));
	return (NFM_S_SUCCESS);
  }

/*
 Doc:	NFMcancel_set_backup_flag

 Abstract:
     This function will cancel set flags for backup utility operations.

 History:
     Jill McCutcheon  November 14, 1990 - Creation

 */

long NFMcancel_set_backup_flag (user_id, catalog, set_name, set_rev)
  long	user_id;
  char	*catalog;
  char	*set_name;
  char	*set_rev;
  {
	long	status;
	char	set_no[20];
	char	catalog_no[20];
	char    utility;
	struct	NFMflag_node_st *head;

	long	NFMfl_cancel_build_tree ();
	long	NFMfl_cancel_update_tree ();
        long    NFMfl_check_set_flag ();

	extern	void NFMfl_flag_free_tree ();
	extern	long NFMfl_get_catalog_no ();
	extern	long NFMfl_get_item_no ();

	static  char *fname = "NFMcancel_set_backup";

	_NFMdebug((fname, "user_id  = <%d>\n", user_id));
	_NFMdebug((fname, "catalog  = <%s>\n", catalog));
	_NFMdebug((fname, "set_name = <%s>\n", set_name));
	_NFMdebug((fname, "set_rev  = <%s>\n", set_rev));

	utility = 'B';

	/*  Get the catalog number for the catalog  */

	if (( status = NFMfl_get_catalog_no (catalog, catalog_no))
			 != NFM_S_SUCCESS)
	  {
		_NFMdebug((fname,"NFMfl_get_catalog_no = <0x%.8x>\n",status));
		return (status);
	  }

	/*  Get the "n_itemno" for this set  */

	if ((status = NFMfl_get_item_no (catalog, set_name, set_rev,
		  			set_no)) != NFM_S_SUCCESS)
	  {
		_NFMdebug((fname, "NFMfl_get_item_no = <0x%.8x>\n", status));
		return (status);
	  }

        /*  See if the set is flagged IN setcit table*/

        if( (status = NFMfl_check_set_flag (catalog_no, set_name, set_rev, 
				  	    set_no, "B" )) != NFM_S_SUCCESS)
          {
                _NFMdebug(( fname, "NFMfl_check_set_flag = <0x%.8x>\n",
                                status ));
                return (status);
          }

	/*  Initialize head of the set tree  */

	if ((head = (struct NFMflag_node_st *)
		malloc (sizeof (struct NFMflag_node_st))) == NULL)
	  {
		_NFMdebug((fname,"%s\n", "malloc failed"));
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

	status = NFMfl_cancel_build_tree (head, 0, utility );
	if( (status != NFM_S_SUCCESS) && (status != NFM_E_MEMBER_NOT_FLAGGED))
	  {
		_NFMdebug((fname,"NFMcancel_build_tree = <0x%.8x>\n", status));
		NFMfl_flag_free_tree (head);
		return (status);
	  }

	/*  Start the second pass, updating the flags  */

	if ((status = NFMfl_cancel_update_tree (head)) != NFM_S_SUCCESS)
	  {
		_NFMdebug((fname,"NFMfl_cancel_update_tree = <0x%.8x>\n",
			   status));
		NFMfl_flag_free_tree (head);
		return (status);
	  }

	/*  Free space taken up by the set tree structure  */

	NFMfl_flag_free_tree (head);

	_NFMdebug((fname,"%s\n", "returning NFM_S_SUCCESS ..."));
	return (NFM_S_SUCCESS);
  }

/*
 Doc:	NFMcancel_set_restore_flag

 Abstract:
     This function will cancel set flags for restore utility operations.

 History:
     Jill McCutcheon  November 14, 1990 - Creation

 */

long NFMcancel_set_restore_flag (user_id, catalog, set_name, set_rev)
  long	user_id;
  char	*catalog;
  char	*set_name;
  char	*set_rev;
  {
	long	status;
	char	set_no[20];
	char	catalog_no[20];
	char    utility;
	struct	NFMflag_node_st *head;

	long	NFMfl_cancel_build_tree ();
	long	NFMfl_cancel_update_tree ();
	long    NFMfl_check_set_flag ();

	extern	void NFMfl_flag_free_tree ();
	extern	long NFMfl_get_catalog_no ();
	extern	long NFMfl_get_item_no ();

	static  char *fname = "NFMcancel_set_restore";

	_NFMdebug((fname, "user_id  = <%d>\n", user_id));
	_NFMdebug((fname, "catalog  = <%s>\n", catalog));
	_NFMdebug((fname, "set_name = <%s>\n", set_name));
	_NFMdebug((fname, "set_rev  = <%s>\n", set_rev));

	utility = 'R';

	/*  Get the catalog number for the catalog  */

	if ((status = NFMfl_get_catalog_no (catalog, catalog_no))
			!= NFM_S_SUCCESS)
	  {
		_NFMdebug((fname, "NFMfl_get_catalog_no = <0x%.8x>\n",status));
		return (status);
	  }

	/*  Get the "n_itemno" for this set  */

	if ((status = NFMfl_get_item_no (catalog, set_name, set_rev, set_no))
		!= NFM_S_SUCCESS)
	  {
		_NFMdebug((fname, "NFMfl_get_item_no = <0x%.8x>\n", status));
		return (status);
	  }

        /*  See if the set is flagged */

        if( (status = NFMfl_check_set_flag (catalog_no, set_name, set_rev, 
					    set_no, "R" )) != NFM_S_SUCCESS)
          {
                _NFMdebug(( fname, "NFMfl_check_set_flag = <0x%.8x>\n",
                                status ));
                return (status);
          }

	/*  Initialize head of the set tree  */

	if ((head = (struct NFMflag_node_st *)
		malloc (sizeof (struct NFMflag_node_st))) == NULL)
	  {
		_NFMdebug((fname, "%s\n", "malloc failed"));
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

	status = NFMfl_cancel_build_tree (head, 0, utility );
	if( (status != NFM_S_SUCCESS) && (status != NFM_E_MEMBER_NOT_FLAGGED))
	  {
		_NFMdebug((fname, "NFMcancel_build_tree = <0x%.8x>\n",status));
		NFMfl_flag_free_tree (head);
		return (status);
	  }

	/*  Start the second pass, updating the flags  */

	if (( status = NFMfl_cancel_update_tree (head)) != NFM_S_SUCCESS)
	  {
		_NFMdebug((fname, "NFMfl_cancel_update_tree = <0x%.8x>\n", 
				status));
		NFMfl_flag_free_tree (head);
		return (status);
	  }

	/*  Free space taken up by the set tree structure  */

	NFMfl_flag_free_tree (head);

	_NFMdebug((fname, "%s\n", "returning NFM_S_SUCCESS ..."));
	return (NFM_S_SUCCESS);
  }

/*
 Doc: NFMcancel_set_flag

 Abstract:
     This function will cancel set flags for archive utility operations.

 History:
     Jill McCutcheon  November 14, 1990 - Creation

 */

long NFMcancel_set_flag (catalog, set_name, set_rev)
  char	*catalog;
  char	*set_name;
  char	*set_rev;
  {
	long	status;
	char	set_no[20];
	char	catalog_no[20];
	struct	NFMflag_node_st *head;

	long	NFMfl_cancel_build_tree_new ();
	long	NFMfl_cancel_update_tree_new ();

	extern	void NFMfl_flag_free_tree ();
	extern	long NFMfl_get_catalog_no ();
	extern	long NFMfl_get_item_no ();

	static  char *fname = "NFMcancel_set_flag";

	_NFMdebug(( fname, "catalog  = <%s>\n", catalog));
	_NFMdebug(( fname, "set_name = <%s>\n", set_name));
	_NFMdebug(( fname, "set_rev  = <%s>\n", set_rev));

	/*  Get the catalog number for the catalog  */

	if((status=NFMfl_get_catalog_no (catalog, catalog_no))!= NFM_S_SUCCESS)
	  {
		_NFMdebug((fname,"NFMfl_get_catalog_no = <0x%.8x>\n", status));
		return (status);
	  }

	/*  Get the "n_itemno" for this set  */

	if( (status = NFMfl_get_item_no (catalog, set_name, set_rev,
			set_no)) != NFM_S_SUCCESS)
	  {
		_NFMdebug((fname, "NFMfl_get_item_no = <0x%.8x>\n", status));
		return (status);
	  }

	/*  Initialize head of the set tree  */

	if ((head = (struct NFMflag_node_st *)
		malloc (sizeof (struct NFMflag_node_st))) == NULL)
	  {
		_NFMdebug((fname, "%s\n","malloc failed"));
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

	status = NFMfl_cancel_build_tree_new (head, 0);
	if( (status != NFM_S_SUCCESS) && (status != NFM_E_MEMBER_NOT_FLAGGED))
	  {
		_NFMdebug((fname, "NFMcancel_build_tree = <0x%.8x>\n",status));
		NFMfl_flag_free_tree (head);
		return (status);
	  }

	/*  Start the second pass, updating the flags  */

	if ((status = NFMfl_cancel_update_tree_new (head)) != NFM_S_SUCCESS)
	  {
		_NFMdebug((fname, "NFMfl_cancel_update_tree = <0x%.8x>\n",
			   status));
		NFMfl_flag_free_tree (head);
		return (status);
	  }

	/*  Free space taken up by the set tree structure  */

	NFMfl_flag_free_tree (head);

	_NFMdebug(( fname, "%s\n", "returning NFM_S_SUCCESS ..."));
	return (NFM_S_SUCCESS);
  }

long  NFMfl_check_set_flag (catalog_no, set_name, set_rev, set_no, flag)
  	char  *catalog_no;
	char  *set_name;
	char  *set_rev;
	char  *set_no;
 	char  *flag;
{
	long   status;
	char   **data;
	MEMptr buffer = NULL;

	extern	long SQLquery ();
	extern	long MEMbuild_array ();

	static char *fname = "NFMfl_check_set_flag";

	_NFMdebug(( fname, "Catalog_no  <%s>\n", catalog_no ));
	_NFMdebug(( fname, "Set_name    <%s>\n", set_name ));
	_NFMdebug(( fname, "Set_rev     <%s>\n", set_rev ));
	_NFMdebug(( fname, "Set_no      <%s>\n", set_no ));
	_NFMdebug(( fname, "Flag	<%s>\n", flag ));

	sprintf( flag_s, "SELECT n_archiveflag FROM nfmsetcit WHERE n_pcatalogno = %s AND n_pitemno = %s", catalog_no, set_no );
    if(( status = SQLquery( flag_s, &buffer, MEM_SIZE )) != SQL_S_SUCCESS)
    {
        _NFMdebug((fname, "SQLquery = <0x%.8x>\n", status));
	MEMclose (&buffer);
        ERRload_struct( NFM, NFM_E_CANCEL_SET_FLAG, "%s%s", set_name, set_rev );
        return( NFM_E_CANCEL_SET_FLAG );
    }
    if ((status = MEMbuild_array (buffer)) != MEM_S_SUCCESS)
    {
	_NFMdebug((fname, "MEMbuild_array = <0x%.8x>\n", status));
	MEMclose (&buffer);
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }

    data = (char **) buffer->data_ptr;
    if( strcmp( data[0], flag ) != 0 )
    {
	MEMclose( &buffer );
	_NFMdebug(( fname, "Set is not flagged for <%s>\n", flag ));
	ERRload_struct( NFM, NFM_E_CANCEL_SET_FLAG, "%s%s", set_name, set_rev );
	return( NFM_E_CANCEL_SET_FLAG );
    }

    MEMclose( &buffer );
 
    return( NFM_S_SUCCESS );
}

