#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMflag.h"
#include "ERR.h"
#include "DEBUG.h"
/**#include "NFMschema.h"**/

extern char SET_NAME[512];
extern char flag_s[512];

/*
Doc:	NFMfl_flag_update_tree
*/
long NFMfl_flag_update_tree (node, level, flag)
  struct NFMflag_node_st *node;
  long   level;
  char   *flag;
  {
	long	status, status2, status3;
	int	i;
	int	tot_data;
        int     restore_flag;

	char	**data;
	char    pendflag[5];
	char	tmpflag[5];
	char    max_version[10];

	MEMptr	buffer = NULL, buff = NULL;
	static  char *fname = "NFMfl_flag_update_tree";

	_NFMdebug(( fname, "level = <%d>\n", level));
	_NFMdebug(( fname, "flag  = <%s>\n", flag));

	strcpy (tmpflag, flag);

	/*  If this is not the starting point of the operation,
	    set the flag to reflect that this is a set member  */

	if (level != 0)
		tmpflag[0] = 'M';

	if( tmpflag[1] == 'R' )
	{

	   if(strcmp(node->ctype,"S") == 0) 
	   {
	      _NFMdebug(( fname, "***Flagging secondary member for Restore: Returing Success***\n" ));
	      return(NFM_S_SUCCESS);
	   }
	

/*  Need to get ALL fileno's for this item and only flag any file
 *  with a matching entry in nfmsavesets!!!!!
 */		
        sprintf( flag_s, "SELECT n_fileno, n_fileversion, n_filenum FROM f_%s WHERE n_itemnum = %s AND n_fileversion IN (SELECT MAX(n_fileversion) from f_%s where n_itemnum = %s AND NOT(n_archiveno is NULL))", node->catalog_name, node->item_no, node->cata
            return (status2 );
        }

	restore_flag = 0;
	if(status == SQL_S_SUCCESS)
	{
	    data = (char **) buffer->data_ptr;
	    tot_data = buffer->rows * buffer->columns;
	}
	else
	{
	    tot_data = 0;
	    restore_flag = 1;
	}
        for( i=0; i<tot_data; i+=buffer->columns )
	  {
	        status = NFMfl_validate_item_restore( node->catalog_no,
			 node->item_no, data[i] );
	        if( (status != NFM_S_SUCCESS ) && 
		  (strcmp( data[i+1], "0") == 0 )) /* File version=0 -> OK */
	        {
		    _NFMdebug(( fname, "Passing version <%s>\n", data[i+1]));
		    restore_flag = 1;
		    continue;
  	        }
	        else if( status != NFM_S_SUCCESS )
	        {
		    _NFMdebug(( fname, "Passing version <%s>", data[i+1] ));
		    continue;
	        }
		
  	    	sprintf (flag_s, 
			"UPDATE f_%s SET n_restoreflag='%s' WHERE n_itemnum = %s AND n_fileversion> 0 AND n_fileno = %s",
			node->catalog_name, tmpflag, node->item_no,data[i] );
     	if ((status = SQLstmt (flag_s)) != SQL_S_SUCCESS)
    	{
        sprintf( flag_s, "SELECT n_itemno  FROM %s WHERE n_itemno = %s AND p_par
ttype = 'P' ", node->catalog_name, node->item_no);
        status3 = SQLquery( flag_s, &buff, MEM_SIZE );
          if(status3 != SQL_S_SUCCESS)
                 {
                   MEMclose(&buff);
			_NFMdebug(( fname, "SQLstmt = <0x%.8x>\n", status));
			ERRload_struct(NFM, NFM_E_FLAG_RESTORE, "%s", SET_NAME);
			return( NFM_E_FLAG_RESTORE );
                  }
                   MEMclose(&buff);
   	 }
	    	restore_flag = 1;
          } /* end row loop */
	  if( restore_flag == 0 )
	  {
	    _NFMdebug(( fname, "No Files Flagged for Item <%s>\n",
			node->item_no ));
	    ERRload_struct( NFM, NFM_E_FLAG_RESTORE, "%s", SET_NAME);
	    return( NFM_E_FLAG_RESTORE );
	  }
        }
	MEMclose(&buffer);

	/*  Get maximum fileversion for this item number */
	sprintf (flag_s, "SELECT MAX(n_fileversion) FROM f_%s WHERE n_itemnum = %s", node->catalog_name, node->item_no);
	if ((status = SQLquery (flag_s, &buffer, MEM_SIZE))
			!= SQL_S_SUCCESS )
	  {
		MEMclose (&buffer);
       sprintf( flag_s, "SELECT n_itemno  FROM %s WHERE n_itemno = %s AND p_par
ttype = 'P' ", node->catalog_name, node->item_no);
        status3 = SQLquery( flag_s, &buff, MEM_SIZE );
          if(status3 != SQL_S_SUCCESS)
            {
		_NFMdebug(( fname, "SQLquery = <0x%.8x>\n", status));
		MEMclose (&buff);
		return( status );
             }
	  }
        if(status == SQL_S_SUCCESS)
        {
	if ((status = MEMbuild_array (buffer)) != MEM_S_SUCCESS)
	  {
		_NFMdebug(( fname, "MEMbuild_array = <0x%.8x>\n", status));
		MEMclose (&buffer);
		return (status);
	  }

	data = (char **) buffer->data_ptr;
	if( (strcmp( data[0], "0" ) == 0 ))
	  {
	    _NFMdebug(( fname, "%s\n", "Max version is 0 " ));
	    MEMclose (&buffer);
	    if ((strcmp (node->ctype, "S") == 0) &&
		     (tmpflag[1] == 'A'))
	    {
		/*  Backup secondary members regardless  */
			tmpflag[1] = 'B';
	    }
	  }
          else
  	    strcpy (max_version, data[0]);
	    MEMclose (&buffer);
        }
        else
  	    strcpy (max_version, "0");

	/*  Check this item to see if it has already been updated  */

  	    sprintf (flag_s,"SELECT n_pendingflag FROM %s WHERE n_itemno = %s",
			 node->catalog_name,node->item_no);

	    if ((status = SQLquery (flag_s, &buffer, MEM_SIZE))
		   != SQL_S_SUCCESS )
  	    {
		_NFMdebug(( fname, "SQLquery = <0x%.8x>\n", status));
		MEMclose (&buffer);
		ERRload_struct( NFM, NFM_E_SQL_QUERY, NULL, NULL );
		return( NFM_E_SQL_QUERY );
	    }
	    if ((status = MEMbuild_array (buffer)) != MEM_S_SUCCESS)
 	    {
		_NFMdebug(( fname, "MEMbuild_array = <0x%.8x>\n", status));
		MEMclose (&buffer);
		return (status);
	    }

  	    data = (char **) buffer->data_ptr;
	    strcpy (pendflag, data[0]);
	    MEMclose (&buffer);

	/*  See if this item has already been flagged
	    for archive, and if it is a primary member  */


	    if ((pendflag[1] == 'A') &&
		((strcmp (node->ctype, "P")) == 0))
 	    {
	/*  This case should not occur anymore in 3.0 */
/****************************
		/ *  Override archive with backup  * /
			tmpflag[1] = 'B';
*****************************/
		ERRload_struct( NFM, NFM_E_FLAG_SET, "%s", SET_NAME);
		return( NFM_E_FLAG_SET );

	    }
	    else if ((strcmp (node->ctype, "S") == 0) &&
		     (tmpflag[1] == 'A'))
	    {
		/*  Backup secondary members regardless  */
			tmpflag[1] = 'B';
	    }

	/*  Set the pending flag for all files for this set  */
            sprintf (flag_s,
		"UPDATE %s SET n_pendingflag = '%s' WHERE n_itemno = %s",
		node->catalog_name, tmpflag, node->item_no );
	    if ((status = SQLstmt (flag_s)) != SQL_S_SUCCESS )
	    {
		_NFMdebug(( fname, "SQLstmt = <0x%.8x>\n", status));
		ERRload_struct( NFM, NFM_E_FLAG_SET, "%s", SET_NAME);
		return( NFM_E_FLAG_SET );
 	    }
	node = node->child;
	while (node != NULL)
	  {
		/*  Call this function for the node's child  */

		/** If node is a Secondary child type, and the flag
		    is restore, don't even bother to look at children**/

		if((tmpflag[1] != 'R') || (strcmp(node->ctype,"S")!= 0))  
		{
		  if ((status = NFMfl_flag_update_tree 
				  (node, level + 1, tmpflag)) != NFM_S_SUCCESS )
		  {
		    _NFMdebug(( fname, "NFMfl_flag_update_tree = <0x%.8x>\n",
				status));
			return (status);
		  }
		}

		/*  Call this function for the node's sibling  */

		node = node->sibling;
	  }

	_NFMdebug(( fname, "%s\n", "Returning SUCCESS  ..."));
	return (NFM_S_SUCCESS );
  }

/*
Doc:	NFMfl_flag_build_tree
*/

long NFMfl_flag_build_tree (node, level, op_flag)
  struct NFMflag_node_st *node;
  long	level;
  short	op_flag;
  {
	int    i;
	long   status;
	char   **data;
	MEMptr buffer = NULL;
	struct NFMflag_node_st *child;
	struct NFMflag_node_st *sibling;

        long   NFMfl_flag_validate_set();
	long   NFMfl_flag_get_set_members();
	long   NFMfl_flag_validate_set_item();

	static char *fname = "NFMfl_flag_build_tree";

	_NFMdebug(( fname, "level    <%d>\n", level));
	_NFMdebug(( fname, "op_flag  <%d>\n", op_flag));

	/*  Validate which operation the set can be flagged for  */

	if (op_flag == RESTORE)
	  {
		/*  Validate that the set can be flagged for restore  */

		/*  If the node is a secondary member, skip it */
		if(strcmp(node->ctype,"S") != 0) 
		{
		  if ((status = NFMfl_validate_set_restore
		      (node->catalog_no, node->item_no)) != NFM_S_SUCCESS)
		  {
			_NFMdebug(( fname, "NFMfl_validate_set_restore = <0x%.8x>\n",status));
			return (status);
		  }
		}
	  }
	else
	  {
		if (level == 0)
		  {
			/*  This is the head of the tree  */

			if ((status = NFMfl_flag_validate_set_item
				(node->catalog_name, node->item_no, op_flag))
				!= NFM_S_SUCCESS)
			  {
				_NFMdebug(( fname, "NFMfl_flag_validate_item = <0x%.8x>\n",status));
				return (status);
			  }
		  }
		else
		  {
			if ((status = NFMfl_flag_validate_set
				(node->catalog_name, node->item_no,
				 node->ctype, op_flag)) != NFM_S_SUCCESS)
			  {
				_NFMdebug(( fname, "NFMfl_flag_validate_set = <0x%.8x>\n",status));
				return (status);
			  }
		  }
	  }

	/*  Get any members of this set  */

	status = NFMfl_flag_get_set_members
		(node->catalog_no, node->item_no, level, &buffer);
	if (status == NFM_S_SUCCESS)
	  {
		/*  There are set members, allocate space for a node  */

		if ((child = (struct NFMflag_node_st *)
			malloc (sizeof (struct NFMflag_node_st))) == NULL)
		  {
			MEMclose (&buffer);
			ERRload_struct( NFM, NFM_E_MALLOC, NULL, NULL );
			return( NFM_E_MALLOC );
		  }

		/*  Initialize the node  */

		data = (char **) buffer->data_ptr;
		strcpy (child->catalog_name, data[0]);
		strcpy (child->catalog_no, data[1]);
		strcpy (child->item_no, data[2]);
		strcpy (child->ctype, data[3]);
		child->child = NULL;
		child->sibling = NULL;
		node->child = child;

		for (i = 4; i < buffer->rows * buffer->columns; i += buffer->columns)
		  {
			/*  Allocate space for a sibling node  */

			if ((sibling = (struct NFMflag_node_st *)
			   malloc (sizeof (struct NFMflag_node_st))) == NULL)
			  {
				MEMclose (&buffer);
				ERRload_struct( NFM, NFM_E_MALLOC,NULL,NULL );
				return( NFM_E_MALLOC );
			  }

			/*  Initialize sibling node  */

			strcpy (sibling->catalog_name, data[i]);
			strcpy (sibling->catalog_no, data[i + 1]);
			strcpy (sibling->item_no, data[i + 2]);
			strcpy (sibling->ctype, data[i + 3]);
			sibling->child = NULL;
			sibling->sibling = NULL;

			child->sibling = sibling;
			child = sibling;
		  }

		/*  Close the buffer  */

		MEMclose (&buffer);
	  }
	else if (status == SQL_I_NO_ROWS_FOUND)
	  {
		/*  There are no members, just return  */
		
		;
	  }
	else
	  {
		/*  An error occurred during the query  */

		_NFMdebug(( fname, "NFMfl_flag_get_set_members = <0x%.8x>\n",status));
		return (status);
	  }

	node = node->child;
	while (node != NULL)
	  {
		/*  Call this function for the first member  */

		if ((status = NFMfl_flag_build_tree (node, level + 1, op_flag))
				!= NFM_S_SUCCESS )
		  {
			_NFMdebug(( fname, "NFMfl_flag_build_tree = <0x%.8x>\n", status));
			return (status);
		  }

		/*  Call this function for the first member's sibling  */

		node = node->sibling;
	  }

	_NFMdebug(( fname, "%s\n", "Returning SUCCESS ..."));
	return (NFM_S_SUCCESS);
  }

/*
Doc:	NFMfl_flag_free_tree
*/

void NFMfl_flag_free_tree (node)
  struct NFMflag_node_st *node;
  {
	void	NFMfl_flag_free_tree ();
        static  char *fname = "NFMfl_flag_free_tree";

	_NFMdebug(( fname, "%s\n", "Entering ..." ));

	if (node->child != NULL)
		NFMfl_flag_free_tree (node->child);

	if (node->sibling != NULL)
		NFMfl_flag_free_tree (node->sibling);

	if (node) free (node);

	_NFMdebug(( fname, "%s\n", "Exiting ..."));
  }

/*
Doc:	NFMfl_cancel_build_tree
*/

long NFMfl_cancel_build_tree (node, level, utility)
  struct NFMflag_node_st *node;
  long	level;
  char  utility;
  {
	int    i;
	long   status;
	char   type;
	char   **data;
	MEMptr buffer = NULL;
	struct NFMflag_node_st *child;
	struct NFMflag_node_st *sibling;

	long	NFMfl_cancel_build_tree ();

	extern	long NFMfl_flag_get_set_members ();

	static  char *fname = "NFMcancel_build_tree";

	_NFMdebug((fname, "level = <%d>\n", level));

	/*  'S' for set, 'M' for set member  */

	if (level == 0)
		type = 'S';
	else
		type = 'M';

	/*  Get any members of this set  */

	status = NFMfl_flag_get_set_members
		(node->catalog_no, node->item_no, level, &buffer);
	if (status == NFM_S_SUCCESS)
	  {
		/*  There are set members, allocate space for a node  */

		if ((child = (struct NFMflag_node_st *)
			malloc (sizeof (struct NFMflag_node_st))) == NULL)
		  {
			_NFMdebug((fname, "%s\n", "malloc failed"));
			MEMclose (&buffer);
			ERRload_struct( NFM, NFM_E_MALLOC, NULL, NULL );
 		        return( NFM_E_MALLOC );
		  }

		/*  Initialize the node  */

		data = (char **) buffer->data_ptr;
		strcpy (child->catalog_name, data[0]);
		strcpy (child->catalog_no, data[1]);
		strcpy (child->item_no, data[2]);
		strcpy (child->ctype, data[3]);
		child->child = NULL;
		child->sibling = NULL;
		node->child = child;

		for (i = 4; i < buffer->rows * buffer->columns; i += buffer->columns)
		  {
			/*  Allocate space for a sibling node  */

			if ((sibling = (struct NFMflag_node_st *)
				malloc (sizeof (struct NFMflag_node_st))) == NULL)
			  {
				MEMclose (&buffer);
				ERRload_struct( NFM, NFM_E_MALLOC,NULL,NULL );
		 		return( NFM_E_MALLOC );
			  }

			/*  Initialize sibling node  */

			strcpy (sibling->catalog_name, data[i]);
			strcpy (sibling->catalog_no, data[i + 1]);
			strcpy (sibling->item_no, data[i + 2]);
			strcpy (sibling->ctype, data[i + 3]);
			sibling->child = NULL;
			sibling->sibling = NULL;

			child->sibling = sibling;
			child = sibling;
		  }

		/*  Close the buffer  */

		MEMclose (&buffer);
	  }
	else if (status == SQL_I_NO_ROWS_FOUND)
	  {
		/*  There are no members, just return  */

		;
	  }
	else
	  {
		/*  An error occurred during the query  */

		_NFMdebug((fname, "NFMfl_flag_get_set_members = <0x%.8x>\n",
			status));
		return (status);
	  }

	node = node->child;
	while (node != NULL)
	  {
		/*  Call this function for the first member  */

		if((status = NFMfl_cancel_build_tree (node, level + 1,utility))
			   != NFM_S_SUCCESS)
		  {
		    _NFMdebug((fname,"NFMfl_cancel_build_tree = <0x%.8x>\n",
				status));
			return (status);
		  }

		/*  Call this function for the first member's sibling  */

		node = node->sibling;
	  }

	_NFMdebug((fname,"%s\n","returning NFM_S_SUCCESS..."));
	return( NFM_S_SUCCESS );
  }


/*
Doc:	NFMfl_cancel_update_tree
*/

long NFMfl_cancel_update_tree (node)
  struct NFMflag_node_st *node;
  {
	long	status;

	long	NFMfl_cancel_update_tree ();

/*******
	extern	long SQLstmt ();
	extern	long SQLquery ();
	extern	long MEMbuild_array ();
*******/

	static  char *fname = "NFMcancel_update_tree";

	_NFMdebug((fname,"%s\n", "Entering ..."));

	/*  Set the pending flag for all files for this set  */

	sprintf (flag_s, "UPDATE %s SET n_pendingflag = NULL WHERE n_itemno = %s",node->catalog_name,node->item_no );
	if ((status = SQLstmt (flag_s)) != SQL_S_SUCCESS)
	  {
		_NFMdebug((fname, "SQLstmt = <0x%.8x>\n", status));
		ERRload_struct( NFM, NFM_E_CANCEL_SET_FLAG, "%s",
				 node->item_no );
 		return( NFM_E_CANCEL_SET_FLAG );
	  }

	sprintf (flag_s, "UPDATE f_%s SET n_restoreflag = NULL WHERE n_itemnum = %s",node->catalog_name,node->item_no );
	if ((status = SQLstmt (flag_s)) != SQL_S_SUCCESS)
	  {
         sprintf( flag_s, "SELECT n_itemno  FROM %s WHERE n_itemno = %s AND p_parttype = 'P' ", node->catalog_name, node->item_no);
        status3 = SQLquery( flag_s, &buff, MEM_SIZE );
          if(status3 != SQL_S_SUCCESS)
            {
		_NFMdebug((fname, "SQLstmt = <0x%.8x>\n", status));
		ERRload_struct( NFM, NFM_E_CANCEL_SET_FLAG, "%s",
				 node->item_no );
 		return( NFM_E_CANCEL_SET_FLAG );
             }
	  }

	node = node->child;
	while (node != NULL)
	  {
		/*  Call this function for the node's child  */

		if((status = NFMfl_cancel_update_tree (node)) != NFM_S_SUCCESS)
		  {
			_NFMdebug((fname, 
			"NFMfl_cancel_update_tree = <0x%.8x>\n",status));
			return (status);
		  }

		/*  Call this function for the node's sibling  */

		node = node->sibling;
	  }

	_NFMdebug((fname, "%s\n", "returning NFM_S_SUCCESS ..."));
	return( NFM_S_SUCCESS );
  }


/*
Doc:	NFMfl_cancel_update_tree
*/

long NFMfl_cancel_update_tree_new (node)
  struct NFMflag_node_st *node;
  {
	long	status;
 
	long	NFMfl_cancel_update_tree_new ();

/***
	extern	long SQLstmt ();
	extern	long SQLquery ();
	extern	long MEMbuild_array ();
***/

	static  char *fname = "NFMcancel_update_tree_new";

	_NFMdebug((fname,"%s\n", "Entering ..."));

	/*  Set the pending flag for all files for this set  */

	sprintf(flag_s, "UPDATE %s SET n_pendingflag = '' WHERE n_itemno = %s",
		node->catalog_name, node->item_no );
	if ((status = SQLstmt (flag_s)) != SQL_S_SUCCESS)
	  {
		_NFMdebug((fname, "SQLstmt = <0x%.8x>\n", status));
		ERRload_struct( NFM, NFM_E_CANCEL_SET_FLAG, "%s",
				 node->item_no );
 		return( status );
	  }

	sprintf(flag_s, "UPDATE f_%s SET n_restoreflag = '' WHERE n_itemnum = %s",node->catalog_name, node->item_no );
      if ((status = SQLstmt (flag_s)) != SQL_S_SUCCESS)
		_NFMdebug((fname, "SQLstmt = <0x%.8x>\n", status));

	node = node->child;
	while (node != NULL)
	  {
		/*  Call this function for the node's child  */

		if((status = NFMfl_cancel_update_tree (node)) != NFM_S_SUCCESS)
		  {
			_NFMdebug((fname, 
			"NFMfl_cancel_update_tree = <0x%.8x>\n",status));
			return (status);
		  }

		/*  Call this function for the node's sibling  */

		node = node->sibling;
	  }

	_NFMdebug((fname, "%s\n", "returning NFM_S_SUCCESS ..."));
	return( NFM_S_SUCCESS );
  }

/*
Doc:	NFMfl_cancel_build_tree_new
*/

long NFMfl_cancel_build_tree_new (node, level)
  struct NFMflag_node_st *node;
  long	level;
  {
	int    i;
	long   status;
	char   type;
	char   **data;
	MEMptr buffer = NULL;
	struct NFMflag_node_st *child;
	struct NFMflag_node_st *sibling;

	long	NFMfl_cancel_build_tree_new ();

	extern	long NFMfl_flag_get_set_members ();

	static  char *fname = "NFMcancel_build_tree_new";

	_NFMdebug((fname, "level = <%d>\n", level));

	/*  'S' for set, 'M' for set member  */

	if (level == 0)
		type = 'S';
	else
		type = 'M';

	/*  Get any members of this set  */

	status = NFMfl_flag_get_set_members
		(node->catalog_no, node->item_no, level, &buffer);
	if (status == NFM_S_SUCCESS)
	  {
		/*  There are set members, allocate space for a node  */

		if ((child = (struct NFMflag_node_st *)
			malloc (sizeof (struct NFMflag_node_st))) == NULL)
		  {
			_NFMdebug((fname, "%s\n", "malloc failed"));
			MEMclose (&buffer);
			ERRload_struct( NFM, NFM_E_MALLOC, NULL, NULL );
 		        return( NFM_E_MALLOC );
		  }

		/*  Initialize the node  */

		data = (char **) buffer->data_ptr;
		strcpy (child->catalog_name, data[0]);
		strcpy (child->catalog_no, data[1]);
		strcpy (child->item_no, data[2]);
		strcpy (child->ctype, data[3]);
		child->child = NULL;
		child->sibling = NULL;
		node->child = child;

		for (i = 4; i < buffer->rows * buffer->columns; i += buffer->columns)
		  {
			/*  Allocate space for a sibling node  */

			if ((sibling = (struct NFMflag_node_st *)
				malloc (sizeof (struct NFMflag_node_st))) == NULL)
			  {
				MEMclose (&buffer);
				ERRload_struct( NFM, NFM_E_MALLOC,NULL,NULL );
		 		return( NFM_E_MALLOC );
			  }

			/*  Initialize sibling node  */

			strcpy (sibling->catalog_name, data[i]);
			strcpy (sibling->catalog_no, data[i + 1]);
			strcpy (sibling->item_no, data[i + 2]);
			strcpy (sibling->ctype, data[i + 3]);
			sibling->child = NULL;
			sibling->sibling = NULL;

			child->sibling = sibling;
			child = sibling;
		  }

		/*  Close the buffer  */

		MEMclose (&buffer);
	  }
	else if (status == SQL_I_NO_ROWS_FOUND)
	  {
		/*  There are no members, just return  */

		;
	  }
	else
	  {
		/*  An error occurred during the query  */

		_NFMdebug((fname, "NFMfl_flag_get_set_members = <0x%.8x>\n",
			status));
		return (status);
	  }

	node = node->child;
	while (node != NULL)
	  {
		/*  Call this function for the first member  */

		if((status = NFMfl_cancel_build_tree_new (node, level + 1))
			   != NFM_S_SUCCESS)
		  {
		    _NFMdebug((fname,"NFMfl_cancel_build_tree_new=<0x%.8x>\n",
				status));
			return (status);
		  }

		/*  Call this function for the first member's sibling  */

		node = node->sibling;
	  }

	_NFMdebug((fname,"%s\n","returning NFM_S_SUCCESS..."));
	return( NFM_S_SUCCESS );
  }

-----------------------------------------x------------------------------------

