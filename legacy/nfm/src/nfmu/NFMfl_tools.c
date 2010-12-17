#include "machine.h"
#include <stdio.h>
#include "NFMschema.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMflag.h"
#include "ERR.h"
#include "DEBUG.h"

char	flag_s[512];

/*
 Doc: NFMfl_**

 Abstract:
     These functions are tools for flag/cancel utility operations.

 History:
     Jill McCutcheon  November 14, 1990 - Creation

 */

long NFMfl_get_catalog_name (catalog_no, catalog_name)
  char	*catalog_no;    /*  i  */
  char	*catalog_name;  /*  o  */
  {
	long	status;
	char	**data;
	MEMptr	buffer = NULL;

	static  char *fname = "NFMfl_get_catalog_name";

	_NFMdebug(( fname, "catalog_no = <%s>\n", catalog_no));

	/*  Get the catalog name from the nfmcatalogs table  */

	sprintf (flag_s, "SELECT n_catalogname FROM nfmcatalogs WHERE n_catalogno = %s", catalog_no);
	if( (status = SQLquery (flag_s, &buffer, 128)) != SQL_S_SUCCESS)
	  {
		_NFMdebug((fname, "SQLquery = <0x%.8x>\n", status));
		MEMclose (&buffer);
		ERRload_struct( NFM, NFM_E_GET_CATALOG_NAME, "%s", 	
				 catalog_no );
		return( NFM_E_GET_CATALOG_NAME );
	  }

	if ((status = MEMbuild_array (buffer)) != MEM_S_SUCCESS)
	  {
		_NFMdebug((fname,"MEMbuild_array = <0x%.8x>\n", status));
		MEMclose (&buffer);
		ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
		return( NFM_E_MEM );
	  }

	data = (char **) buffer->data_ptr;
	strcpy (catalog_name, data[0]);
	MEMclose (&buffer);

	_NFMdebug((fname, "%s\n", "returning SUCCESS ..."));
	return( NFM_S_SUCCESS );
  }

/*
Doc:	NFMfl_get_catalog_no
*/

long NFMfl_get_catalog_no (catalog, catalog_no)
  char	*catalog;      /*  i  */
  char	*catalog_no;   /*  o  */
  {
	long	status;
	char	**data;
	MEMptr	buffer = NULL;

	static  char *fname = "NFMfl_get_catalog_no";

	_NFMdebug((fname,"catalog = <%s>\n", catalog));

	/*  Get the catalog number from the nfmcatalogs table  */

	sprintf (flag_s, "SELECT n_catalogno FROM nfmcatalogs WHERE n_catalogname = '%s'", catalog);
	if( (status = SQLquery (flag_s, &buffer, MEM_SIZE)) != SQL_S_SUCCESS)
	  {
		_NFMdebug((fname, "SQLquery = <0x%.8x>\n", status));
		MEMclose (&buffer);
		ERRload_struct( NFM, NFM_E_GET_CATALOG_NO, "%s", catalog);
		return( NFM_E_GET_CATALOG_NO );
	  }

	if ((status = MEMbuild_array (buffer)) != MEM_S_SUCCESS)
	  {
		_NFMdebug((fname, "MEMbuild_array = <0x%.8x>\n", status));
		MEMclose (&buffer);
                ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
                return( NFM_E_MEM );
	  }

	data = (char **) buffer->data_ptr;
	strcpy (catalog_no, data[0]);
	MEMclose (&buffer);

	return( NFM_S_SUCCESS );
  }

/*
Doc:	NFMfl_get_item_no
*/

long NFMfl_get_item_no (catalog, item_name, item_rev, item_no)
  char	*catalog;   /*  i  */
  char	*item_name; /*  i  */
  char	*item_rev;  /*  i  */
  char	*item_no;   /*  o  */
  {
	long	status;
	char	**data;
	MEMptr	buffer = NULL;
        char    theItemName[100]; /* ticked item PS */
        char    theItemRevn[100];

	static  char *fname = "NFMget_item_no";

	_NFMdebug((fname, "catalog   = <%s>\n", catalog));
	_NFMdebug((fname, "item_name = <%s>\n", item_name));
	_NFMdebug((fname, "item_rev  = <%s>\n", item_rev));
/* PS */
      NFMtic_to_tics(item_name, theItemName);
      NFMtic_to_tics(item_rev, theItemRevn);
/* PS - item_name and item_rev are replaced with the ticked theItemName and
	theItemRevn
*/
	sprintf (flag_s, "SELECT n_itemno FROM %s WHERE n_itemname = '%s' and n_itemrev = '%s'",catalog, theItemName, theItemRevn);

	if( (status = SQLquery (flag_s, &buffer, MEM_SIZE)) != SQL_S_SUCCESS)
	  {
		_NFMdebug((fname, "SQLquery = <0x%.8x>\n", status));
		MEMclose (&buffer);
		ERRload_struct( NFM, NFM_E_GET_ITEM_NO, "%s", item_name);
		return( NFM_E_GET_ITEM_NO );
	  }

	if ((status = MEMbuild_array (buffer)) != MEM_S_SUCCESS)
	  {
		_NFMdebug((fname, "MEMbuild_array = <0x%.8x>\n", status));
		MEMclose (&buffer);
                ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
                return( NFM_E_MEM );
	  }

	data = (char **) buffer->data_ptr;
	strcpy (item_no, data[0]);
	MEMclose (&buffer);

	_NFMdebug((fname,"%s\n", "returning SUCCESS ..."));
	return (NFM_S_SUCCESS );
  }

/*
Doc:	NFMfl_get_item_no
*/

long NFMfl_get_item_name (catalog_no, item_no, item_name, item_rev)
  char	*catalog_no;   /*  i  */
  char	*item_no;      /*  i  */
  char	*item_name;    /*  o  */
  char	*item_rev;     /*  o  */

  {
	long	status;
	char	**data;
	char    catalog_name[NFM_CATALOGNAME+1];
	MEMptr	buffer = NULL;

	static  char *fname = "NFMfl_get_item_name";

	_NFMdebug((fname, "catalog_no = <%s>\n", catalog_no));
	_NFMdebug((fname, "item_no    = <%s>\n", item_no));

	sprintf (flag_s, "SELECT n_catalogname FROM nfmcatalogs WHERE n_catalogno = %s", catalog_no );
	if( (status = SQLquery (flag_s, &buffer, MEM_SIZE)) != SQL_S_SUCCESS)
	  {
		_NFMdebug((fname, "SQLquery = <0x%.8x>\n", status));
		MEMclose (&buffer);
		ERRload_struct( NFM, NFM_E_GET_CATALOG_NAME, "%s", catalog_no);
		return( NFM_E_GET_CATALOG_NAME );
	  }

	if ((status = MEMbuild_array (buffer)) != MEM_S_SUCCESS)
	  {
		_NFMdebug((fname, "MEMbuild_array = <0x%.8x>\n", status));
		MEMclose (&buffer);
	  	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
		return (NFM_E_MEM);
	  }

	data = (char **) buffer->data_ptr;
	strcpy (catalog_name, data[0]);
	MEMclose (&buffer);

	sprintf (flag_s, "SELECT n_itemname,n_itemrev FROM %s WHERE n_itemno = %s", catalog_name, item_no );
	if( (status = SQLquery (flag_s, &buffer, MEM_SIZE)) != SQL_S_SUCCESS)
	  {
		_NFMdebug((fname, "SQLquery = <0x%.8x>\n", status));
		MEMclose (&buffer);
		ERRload_struct( NFM, NFM_E_BAD_ITEM, NULL, NULL );
		return( NFM_E_BAD_ITEM );
	  }

	if ((status = MEMbuild_array (buffer)) != MEM_S_SUCCESS)
	  {
		_NFMdebug((fname, "MEMbuild_array = <0x%.8x>\n", status));
		MEMclose (&buffer);
	  	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
		return (NFM_E_MEM);
	  }

	data = (char **) buffer->data_ptr;
	strcpy (item_name, data[0]);
	strcpy (item_rev, data[1] );
	MEMclose (&buffer);

	_NFMdebug((fname,"%s\n", "returning SUCCESS ..."));
	return (NFM_S_SUCCESS );
  }

/*  This routine returns NFM_S_SUCCESS for input catalog_no/item_no
 *  having once been archived or backed up - otherwise; status.
 */
long
NFMfl_validate_item_restore( catalog_no, item_no, file_no )
    char	*catalog_no;
    char	*item_no;
    char	*file_no;
{
    long	status;
    char	item_name[NFM_ITEMNAME+1];
    char	item_rev[NFM_ITEMREV+1];

    MEMptr	sql_buffer = NULL;

    static      char *fname = "NFMfl_validate_item_restore";

    _NFMdebug((fname, "Catalog_no <%s>\n", catalog_no ));
    _NFMdebug((fname, "Item_no <%s>\n", item_no));
    _NFMdebug((fname, "File_no <%s>\n", file_no ));

    sprintf( flag_s,
	     "SELECT n_catalogno FROM nfmsavesets WHERE n_catalogno = %s AND n_itemno = %s AND n_fileno = %s", catalog_no, item_no, file_no );
    status = SQLquery( flag_s, &sql_buffer, MEM_SIZE );
    MEMclose( &sql_buffer );
    if( status != SQL_S_SUCCESS) 
    {
	NFMfl_get_item_name( catalog_no, item_no, item_name, item_rev );
        ERRload_struct( NFM, NFM_E_FILE_NOT_ARCHIVED, "%s%s", item_name,
			item_rev  );
	return( NFM_E_FILE_NOT_ARCHIVED );
    }

    _NFMdebug((fname, "%s\n", "returning SUCCESS " ));
    return( NFM_S_SUCCESS );
}
long
NFMfl_validate_set_restore( catalog_no, item_no )
    char	*catalog_no;
    char	*item_no;
{
    long	status;
    char	set_name[NFM_ITEMNAME+1];
    char	set_rev[NFM_ITEMREV+1];

    MEMptr	sql_buffer = NULL;
 
    static	char *fname = "NFMfl_validate_set";

    _NFMdebug((fname, "Catalog_no <%s>\n", catalog_no ));
    _NFMdebug((fname, "Item_no <%s>\n", item_no ));

/*  Go find out if this is an item without a file checked -- which
    is OK for SETS ONLY !!  If NFM_S_SUCCESS is returned, there is
    a file and we need to check the savesets table. Otherwise, 
    there was no file checked in -- return SUCCESS.
 */
    status = NFMfl_check_for_file( catalog_no, item_no );
    if( status == NFM_S_SUCCESS )
    {
        sprintf( flag_s,
	     "SELECT n_catalogno FROM nfmsavesets WHERE n_catalogno = %s AND n_itemno = %s", catalog_no, item_no );
        status = SQLquery( flag_s, &sql_buffer, MEM_SIZE );
        MEMclose( &sql_buffer );
        if( status != SQL_S_SUCCESS) 
        {
	    NFMfl_get_item_name( catalog_no, item_no, set_name, set_rev );
            ERRload_struct( NFM, NFM_E_FILE_NOT_ARCHIVED, "%s%s", set_name,
				set_rev );
   	    return( NFM_E_FILE_NOT_ARCHIVED );
        }
    }
    else
    {
        _NFMdebug((fname, "No file for item <%s>\n", item_no ));	
    }

    _NFMdebug((fname, "%s\n", "returning SUCCESS " ));
    return( NFM_S_SUCCESS );
}

/*  This routine returns the maximum fileversion  for the given
 *  item number in the given file catalog.
 */
long NFMfl_get_max_version ( catalog, itemno, version )
  	char    *catalog;		/* i - catalog name */
	int	itemno;			/* i - item number */
	int	*version;		/* o - max version + 1 */
  {
	long	status;
	char	**data;
	MEMptr	buffer = NULL;

	static  char *fname = "NFMfl_get_max_version";

	_NFMdebug((fname, "%s\n", "Entering ..." ));

	sprintf( flag_s, "SELECT MAX(n_fileversion) FROM f_%s WHERE n_itemno= %d", catalog, itemno );
 	status = SQLquery( flag_s, &buffer, MEM_SIZE );
	if( status != SQL_S_SUCCESS )
	{
	    _NFMdebug((fname, "SQL status <0x%.8x>\n",status ));
	    MEMclose( &buffer );
	    ERRload_struct( NFM, NFM_E_BAD_VERSION, NULL, NULL );
	    return( NFM_E_BAD_VERSION );
	}
	status = MEMbuild_array( buffer );
	if( status != MEM_S_SUCCESS )
	{
	    MEMclose( &buffer );
	    _NFMdebug((fname, "MEMbuild_array <0x%.8x>\n",status ));
                ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
                return( NFM_E_MEM );
	}
	data = (char**) buffer->data_ptr;
	*version = atoi( data[0] );
	MEMclose( &buffer );

	_NFMdebug((fname, "Max fileversion <%ld>\n",  *version ));

	_NFMdebug((fname, "%s\n", "Exiting ..." ));

	return( NFM_S_SUCCESS );
}
NFMfl_check_for_file( catalog_no, item_no )
    char *catalog_no;
    char *item_no;
{
    long	status;

    char	catalog[NFM_CATALOGNAME+1];

    char	**data;

    MEMptr	buffer = NULL;

    static   	char *fname = "NFMfl_check_for_file";

    _NFMdebug((fname, "Catalog_no <%s>\n", catalog_no ));
    _NFMdebug((fname, "Item_no <%s>\n", item_no ));

/*  Get catalog name */
    sprintf( flag_s, "SELECT n_tablename FROM nfmtables WHERE n_tableno=%s",
		      catalog_no );
    if(( status = SQLquery( flag_s, &buffer, MEM_SIZE )) != SQL_S_SUCCESS)
    {
        _NFMdebug((fname, "SQLquery = <0x%.8x>\n", status));
	MEMclose (&buffer);
	ERRload_struct( NFM, NFM_E_SQL_QUERY, NULL, NULL );
	return( NFM_E_SQL_QUERY );
    }
    if ((status = MEMbuild_array (buffer)) != MEM_S_SUCCESS)
    {
	MEMclose (&buffer);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    data = (char **) buffer->data_ptr;
    strcpy( catalog, data[0] );
    MEMclose( &buffer );

/*  Now check n_coout attribute to see if a file was checked in 
 */
    sprintf( flag_s, "SELECT n_status FROM %s WHERE n_itemno = %s",
	     catalog, item_no );
    if(( status = SQLquery( flag_s, &buffer, MEM_SIZE )) != SQL_S_SUCCESS)
    {
        _NFMdebug((fname, "SQLquery = <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_SQL_QUERY, NULL, NULL );
	MEMclose (&buffer);
	return( NFM_E_SQL_QUERY );
    }
    if ((status = MEMbuild_array (buffer)) != MEM_S_SUCCESS)
    {
	MEMclose (&buffer);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    data = (char **) buffer->data_ptr;

    if( strcmp( data[0], "I" ) == 0 )
    {
	MEMclose( &buffer );
	return( NFM_S_SUCCESS );
    }
    MEMclose( &buffer );

    _NFMdebug((fname, "%s\n", "No file checked in" ));	
    return( NFM_E_FAILURE );
}
