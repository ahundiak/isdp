#include "machine.h"
#include <stdio.h>
#include "SQLerrordef.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMdef.h"
#include "DEBUG.h"
#include "ERR.h"
#include "NFMstruct.h"

extern   struct NFMglobal_st NFMglobal;

#define BUFFER_SIZE 1000

char    sql_string[200];

/*  This routine validates the existence in the database of various 
 *  entities.
 *  Jill McCutcheon is responsible for this code.
 */

NFMvalidate_project( project_name )
    char *project_name;
{
    long   status;
    MEMptr buffer = NULL;
    static char *fname = "NFMvalidate_project";

    _NFMdebug(( fname, "Project Name : <%s>\n", project_name ));

    if( strlen( project_name ) == 0 )
    {
        ERRload_struct( NFM, NFM_E_INVALID_PROJECT, "%s", " " );
        return( NFM_E_INVALID_PROJECT );
    }

    sprintf( sql_string, 
"SELECT n_projectname FROM nfmprojects WHERE n_projectname = '%s'", 
	project_name );
    status = SQLquery( sql_string, &buffer, BUFFER_SIZE );
    _NFMdebug(( fname, "SQLquery <0x%.8x>\n", status ));
    MEMclose( &buffer );

    if( status == SQL_I_NO_ROWS_FOUND )
    {
	ERRload_struct( NFM, NFM_E_INVALID_PROJECT, "%s", project_name );
	return( NFM_E_INVALID_PROJECT );
    }
    else if( status != SQL_S_SUCCESS )
    {
	ERRload_struct( NFM, NFM_E_SQL_QUERY, NULL, NULL );
	return( NFM_E_SQL_QUERY );
    }

    return(  NFM_S_SUCCESS );
}

NFMvalidate_catalog( catalog_name )
    char *catalog_name;
{
    long   status;

    MEMptr buffer = NULL;
    static char *fname = "NFMvalidate_catalog";

    _NFMdebug(( fname, "catalog name : <%s>\n", catalog_name ));

    if( strlen( catalog_name ) == 0 )
    {
        ERRload_struct( NFM, NFM_E_INVALID_CATALOG, "%s", " " );
        return( NFM_E_INVALID_CATALOG );
    }

    sprintf( sql_string, "SELECT n_catalogname FROM nfmcatalogs WHERE n_catalogname = '%s'",  catalog_name );
    status = SQLquery( sql_string, &buffer, BUFFER_SIZE );

    _NFMdebug(( fname, "SQLquery <0x%.8x>\n", status ));

    MEMclose( &buffer );

    if( status == SQL_I_NO_ROWS_FOUND )
    {
        ERRload_struct( NFM, NFM_E_INVALID_CATALOG, "%s", catalog_name );
        return( NFM_E_INVALID_CATALOG );
    }
    else if( status != SQL_S_SUCCESS )
    {
        ERRload_struct( NFM, NFM_E_SQL_QUERY, NULL, NULL );
        return( NFM_E_SQL_QUERY );
    }

    return(  NFM_S_SUCCESS );
}

NFMvalidate_item( catalog_name, item_name)
    char *catalog_name;
    char *item_name;

{
    long   status;


    MEMptr buffer = NULL;

    static char *fname = "NFMvalidate_item";

    _NFMdebug(( fname, "Catalog Name : <%s>\n", catalog_name ));
    _NFMdebug(( fname, "Item Name    : <%s>\n", item_name ));

    status = NFMvalidate_catalog( catalog_name );
    if( status != NFM_S_SUCCESS )
        return( status );

    if( strlen( item_name ) == 0 )
    {
        ERRload_struct( NFM, NFM_E_INVALID_ITEM, "%s", " " );
        return( NFM_E_INVALID_ITEM );
    }

    sprintf( sql_string, "SELECT n_setindicator FROM %s WHERE n_itemname='%s'",
	     catalog_name, item_name );
    status = SQLquery( sql_string, &buffer, BUFFER_SIZE );
    _NFMdebug(( fname, "SQLquery <0x%.8x>\n", status ));
    MEMclose( &buffer );

    if( status == SQL_I_NO_ROWS_FOUND )
    {
        ERRload_struct( NFM, NFM_E_INVALID_ITEM, "%s", item_name );
        return( NFM_E_INVALID_ITEM );
    }
    else if( status != SQL_S_SUCCESS )
    {
        ERRload_struct( NFM, NFM_E_SQL_QUERY, NULL, NULL );
        return( NFM_E_SQL_QUERY );
    }

    return(  NFM_S_SUCCESS );
}

NFMvalidate_revision( catalog_name, item_name, item_revision, flag )
    char *catalog_name;
    char *item_name;
    char *item_revision;
    int  *flag;
{
    long   status;
    long   mem_status;
    MEMptr buffer = NULL;
    char   **data_ptr;
    static char *fname = "NFMvalidate_revision";

    _NFMdebug(( fname, "Catalog Name  : <%s>\n", catalog_name ));
    _NFMdebug(( fname, "Item Name     : <%s>\n", item_name ));
    _NFMdebug(( fname, "Item Rev      : <%s>\n", item_revision ));
    
    *flag = 0;
    status = NFMvalidate_item( catalog_name, item_name);
    if( status != NFM_S_SUCCESS )
	return( status );
    
    if( strlen( item_revision ) == 0 )
    {
        ERRload_struct( NFM, NFM_E_INVALID_REVISION, "%s%s%s", 
			catalog_name, item_name, " " );
        return( NFM_E_INVALID_REVISION );
    }

    sprintf( sql_string, "SELECT n_setindicator,n_itemname FROM %s WHERE n_itemname = '%s' AND n_itemrev = '%s'",
	     catalog_name, item_name, item_revision );
    status = SQLquery( sql_string, &buffer, BUFFER_SIZE );
    _NFMdebug(( fname, "SQLquery <0x%.8x>\n", status ));

    if( status == SQL_S_SUCCESS )
    {
        mem_status = MEMbuild_array (buffer);
        if( mem_status != MEM_S_SUCCESS )
        {
   	    MEMclose (&buffer);
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            return( NFM_E_MEM );
        }
	data_ptr = (char**)buffer->data_ptr;
   	if( strcmp( data_ptr[0], "" ) != 0 )
	    *flag = 1;
    }
    MEMclose( &buffer );

    _NFMdebug(( fname, "set indicator <%d>\n", *flag ));

    if( status == SQL_I_NO_ROWS_FOUND )
    {
        ERRload_struct( NFM, NFM_E_INVALID_REVISION, "%s%s%s",catalog_name,
			item_name, item_revision );
        return( NFM_E_INVALID_REVISION );
    }
    else if( status != SQL_S_SUCCESS )
    {
        ERRload_struct( NFM, NFM_E_SQL_QUERY, NULL, NULL );
        return( NFM_E_SQL_QUERY );
    }

   return(  NFM_S_SUCCESS );
}

NFMvalidate_search( search_name, owner )
    char *search_name;
    char *owner;
{
    long   status;

    char   **data_ptr;

    MEMptr buffer = NULL;

    static char *fname = "NFMvalidate_search";

    _NFMdebug(( fname, "Search Name : <%s>\n", search_name ));

    if( strlen( search_name ) == 0 )
    {
        ERRload_struct( NFM, NFM_E_INVALID_SEARCH, "%s", " " );
        return( NFM_E_INVALID_SEARCH );
    }

    sprintf( sql_string, 
     "SELECT n_reportname,n_owner FROM nfmreports WHERE n_reportname = '%s' AND n_type = 'W'",  search_name );
    status = SQLquery( sql_string, &buffer, BUFFER_SIZE );
    _NFMdebug((fname, "SQLquery <0x%.8x>\n", status ));

    if( status == SQL_I_NO_ROWS_FOUND )
    {
        ERRload_struct( NFM, NFM_E_INVALID_SEARCH, "%s", search_name );
        return( NFM_E_INVALID_SEARCH );
    }
    else if( status != SQL_S_SUCCESS )
    {
        ERRload_struct( NFM, NFM_E_SQL_QUERY, NULL, NULL );
        return( NFM_E_SQL_QUERY );
    }
    status = MEMbuild_array( buffer );
    if( status != MEM_S_SUCCESS )
    {
	_NFMdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
	MEMclose( &buffer );
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }
    data_ptr = (char**) buffer->data_ptr;

    strcpy( owner, data_ptr[1] );
    MEMclose( &buffer );

/*  Check to see that the current user is the owner of the storage
 *  area or the owner is PUBLIC or the current user is the
 *  administrator.
 */
    _NFMdebug(( fname, "Owner of search <%s>\n", owner ));

    sprintf( sql_string, 
     "SELECT n_username FROM nfmusers WHERE n_userno = %s", owner );
    status = SQLquery( sql_string, &buffer, BUFFER_SIZE );
    _NFMdebug(( fname, "SQLquery <0x%.8x>\n", status ));
    if( status == SQL_I_NO_ROWS_FOUND )
    {
        ERRload_struct( NFM, NFM_E_INVALID_SEARCH, "%s", search_name );
        return( NFM_E_INVALID_SEARCH );
    }

    status = MEMbuild_array (buffer);
    if( status != MEM_S_SUCCESS )
    {
	MEMclose (&buffer);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char **) buffer->data_ptr;

    strcpy( owner, data_ptr[0] );

    if( (strcmp( data_ptr[0], "PUBLIC" ) == 0 ) ||
	(strcmp( data_ptr[0], NFMglobal.NFMusername ) == 0 ) ||
	(NFMglobal.administrator == 1 ) )
    {
	_NFMdebug(( fname, "%s\n", "Valid SEARCH given SEARCH owner" ));
    }
    else
    {
	MEMclose( &buffer );
	_NFMdebug(( fname, "%s\n", "Invalid SEARCH due to SEARCH owner" ));
        ERRload_struct( NFM, NFM_E_INVALID_SEARCH, "%s", search_name );
        return( NFM_E_INVALID_SEARCH );
    }

    MEMclose( &buffer );

    return(  NFM_S_SUCCESS );
}

NFMvalidate_sort( sort_name, owner )
    char *sort_name;
    char *owner;
{
    long   status;

    char   **data_ptr;

    MEMptr buffer = NULL;

    static char *fname = "NFMvalidate_sort";

    _NFMdebug(( fname, "Sort Name : <%s>\n", sort_name ));

    if( strlen( sort_name ) == 0 )
    {
        ERRload_struct( NFM, NFM_E_INVALID_SORT, "%s", " " );
        return( NFM_E_INVALID_SORT );
    }

    sprintf( sql_string, 
     "SELECT n_reportname,n_owner FROM nfmreports WHERE n_reportname = '%s' AND n_type = 'O'", sort_name );
    status = SQLquery( sql_string, &buffer, BUFFER_SIZE );
    _NFMdebug(( fname, "SQLquery <0x%.8x>\n", status ));

    if( status == SQL_I_NO_ROWS_FOUND )
    {
        ERRload_struct( NFM, NFM_E_INVALID_SORT, "%s", sort_name );
        return( NFM_E_INVALID_SORT );
    }
    else if( status != SQL_S_SUCCESS )
    {
        ERRload_struct( NFM, NFM_E_SQL_QUERY, NULL, NULL );
        return( NFM_E_SQL_QUERY );
    }

    status = MEMbuild_array( buffer );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &buffer );
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }
    data_ptr = (char**) buffer->data_ptr;
    strcpy( owner, data_ptr[1] );
    MEMclose( &buffer );

/*  Check to see that the current user is the owner of the storage
 *  area or the owner is PUBLIC or the current user is the
 *  administrator.
 */
    _NFMdebug(( fname, "Owner of search <%s>\n", owner ));

    sprintf( sql_string, 
     "SELECT n_username FROM nfmusers WHERE n_userno = %s", owner );
    status = SQLquery( sql_string, &buffer, BUFFER_SIZE );
    _NFMdebug(( fname, "SQLquery <0x%.8x>\n", status ));
    if( status == SQL_I_NO_ROWS_FOUND )
    {
        ERRload_struct( NFM, NFM_E_INVALID_SORT, "%s", sort_name );
        return( NFM_E_INVALID_SORT );
    }

    status = MEMbuild_array (buffer);
    if( status != MEM_S_SUCCESS )
    {
	MEMclose (&buffer);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char **) buffer->data_ptr;
    strcpy( owner, data_ptr[0] );

    if( (strcmp( data_ptr[0], "PUBLIC" ) == 0 ) ||
	(strcmp( data_ptr[0], NFMglobal.NFMusername ) == 0 ) ||
	(NFMglobal.administrator == 1 ) )
    {
	_NFMdebug(( fname, "%s\n", "Valid SORT given SORT owner" ));
    }
    else
    {
	MEMclose( &buffer );
	_NFMdebug(( fname, "%s\n", "Invalid SORT due to SORT owner" ));
        ERRload_struct( NFM, NFM_E_INVALID_SORT, "%s", sort_name );
        return( NFM_E_INVALID_SORT );
    }

    MEMclose( &buffer );

    return(  NFM_S_SUCCESS );
}

NFMvalidate_st_area( st_area_name )
    char *st_area_name;
{
    long   status;
    MEMptr buffer = NULL;
    static char *fname = "NFMvalidate_st_area";

    _NFMdebug(( fname, "St_area name : <%s>\n", st_area_name ));

    if( strlen( st_area_name ) == 0 )
    {
        ERRload_struct( NFM, NFM_E_INVALID_STORAGE_AREA, "%s", " " );
        return( NFM_E_INVALID_STORAGE_AREA );
    }

    sprintf( sql_string, 
     "SELECT n_saname FROM nfmstoragearea WHERE n_saname = '%s' AND n_type IN ('I','B','W','U')", st_area_name );
    status = SQLquery( sql_string, &buffer, BUFFER_SIZE );

    MEMclose( &buffer );

    _NFMdebug(( fname, "SQLquery <0x%.8x>\n", status ));

    if( status == SQL_I_NO_ROWS_FOUND )
    {
        ERRload_struct( NFM, NFM_E_INVALID_STORAGE_AREA, "%s", st_area_name );
        return( NFM_E_INVALID_STORAGE_AREA );
    }
    else if( status != SQL_S_SUCCESS )
    {
        ERRload_struct( NFM, NFM_E_SQL_QUERY, NULL, NULL );
        return( NFM_E_SQL_QUERY );
    }

    return(  NFM_S_SUCCESS );
}

NFMvalidate_working_area( working_area_name, owner )
    char *working_area_name;
    char *owner;
{
    long   status;
    char   **data_ptr;
    MEMptr buffer = NULL;
    static char *fname = "NFMvalidate_working_area";

    _NFMdebug(( fname, "working_area name : <%s>\n", working_area_name ));

    if( strlen( working_area_name ) == 0 )
    {
        ERRload_struct( NFM, NFM_E_INVALID_WORKING_AREA, "%s", " " );
        return( NFM_E_INVALID_WORKING_AREA );
    }

    sprintf( sql_string, 
     "SELECT n_saname,n_owner FROM nfmstoragearea WHERE n_saname = '%s' AND n_type IN ( 'W', 'B' )",  working_area_name );
    status = SQLquery( sql_string, &buffer, BUFFER_SIZE );
    _NFMdebug(( fname, "SQLquery <0x%.8x>\n", status ));

    if( status == SQL_I_NO_ROWS_FOUND )
    {
        ERRload_struct( NFM, NFM_E_INVALID_WORKING_AREA, "%s", 
			working_area_name );
        return( NFM_E_INVALID_WORKING_AREA );
    }
    else if( status != SQL_S_SUCCESS )
    {
        ERRload_struct( NFM, NFM_E_SQL_QUERY, NULL, NULL );
        return( status );
    }

    status = MEMbuild_array (buffer);
    if( status != MEM_S_SUCCESS )
    {
	MEMclose (&buffer);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char **) buffer->data_ptr;
    strcpy( owner, data_ptr[1] );
    MEMclose( &buffer );

/*  Check to see that the current user is the owner of the storage
 *  area or the owner is PUBLIC or the current user is the
 *  administrator.
 */
    _NFMdebug(( fname, "Owner of sa <%s>\n", owner ));

    sprintf( sql_string, 
     "SELECT n_username FROM nfmusers WHERE n_userno = %s", owner );
    status = SQLquery( sql_string, &buffer, BUFFER_SIZE );
    _NFMdebug(( fname, "SQLquery <0x%.8x>\n", status ));
    if( status == SQL_I_NO_ROWS_FOUND )
    {
        ERRload_struct( NFM, NFM_E_INVALID_WORKING_AREA, "%s", 
			working_area_name );
        return( NFM_E_INVALID_WORKING_AREA );
    }

    status = MEMbuild_array (buffer);
    if( status != MEM_S_SUCCESS )
    {
	MEMclose (&buffer);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char **) buffer->data_ptr;

    strcpy( owner, data_ptr[0] );

    if( (strcmp( data_ptr[0], "PUBLIC" ) == 0 ) ||
	(strcmp( data_ptr[0], NFMglobal.NFMusername ) == 0 ) ||
	(NFMglobal.administrator == 1 ) )
    {
	_NFMdebug(( fname, "%s\n", "Valid working area given WA owner" ));
    }
    else
    {
	MEMclose( &buffer );
	_NFMdebug(( fname, "%s\n", "Invalid WA due to WA owner" ));
        ERRload_struct( NFM, NFM_E_INVALID_WORKING_AREA, "%s", 
			working_area_name );
        return( NFM_E_INVALID_WORKING_AREA );
    }

    MEMclose( &buffer );

    return(  NFM_S_SUCCESS );
}

NFMvalidate_node( node_name )
    char *node_name;
{
    long   status;

    MEMptr buffer = NULL;
    static char *fname = "NFMvalidate_node";

    _NFMdebug(( fname, "Node Name : <%s>\n", node_name ));

    if( strlen( node_name ) == 0 )
    {
        ERRload_struct( NFM, NFM_E_INVALID_NODE, "%s", " " );
        return( NFM_E_INVALID_NODE );
    }
    sprintf( sql_string, 
     "SELECT n_nodename FROM nfmnodes WHERE n_nodename = '%s'", node_name );
    status = SQLquery( sql_string, &buffer, BUFFER_SIZE );

    MEMclose( &buffer );

    _NFMdebug(( fname, "SQLquery <0x%.8x>\n", status ));

    if( status == SQL_I_NO_ROWS_FOUND )
    {
        ERRload_struct( NFM, NFM_E_INVALID_NODE, "%s", node_name );
        return( NFM_E_INVALID_NODE );
    }
    else if( status != SQL_S_SUCCESS )
    {
        ERRload_struct( NFM, NFM_E_SQL_QUERY, NULL, NULL );
        return( NFM_E_SQL_QUERY );
    }

    return(  NFM_S_SUCCESS );
}

NFMvalidate_set_item( set_cat_name, set_item_name )
    char *set_cat_name;
    char *set_item_name;
{
    long   status;
    MEMptr buffer = NULL;
    static char *fname = "NFMvalidate_set_item";

    _NFMdebug(( fname, "Set Cat Name : <%s>\n", set_cat_name ));
    _NFMdebug(( fname, "Set Item Name: <%s>\n", set_item_name ));

    if( strlen( set_cat_name ) == 0 )
    {
        ERRload_struct( NFM, NFM_E_INVALID_CATALOG, "%s"," " );
        return( NFM_E_INVALID_CATALOG );
    }
    if( strlen( set_item_name ) == 0 )
    {
        ERRload_struct( NFM, NFM_E_INVALID_SET_ITEM,"%s.%s",set_cat_name," " );
        return( NFM_E_INVALID_SET_ITEM );
    }

    sprintf( sql_string, "SELECT n_itemname FROM %s WHERE n_itemname = '%s'",
	     set_cat_name, set_item_name );
    status = SQLquery( sql_string, &buffer, BUFFER_SIZE );

    MEMclose( &buffer );

    _NFMdebug(( fname, "SQLquery <0x%.8x>\n", status ));

    if( status == SQL_I_NO_ROWS_FOUND )
    {
        ERRload_struct( NFM, NFM_E_INVALID_SET_ITEM, "%s%s", set_cat_name,
			set_item_name );
        return( NFM_E_INVALID_SET_ITEM );
    }
    else if( status != SQL_S_SUCCESS )
    {
        ERRload_struct( NFM, NFM_E_SQL_QUERY, NULL, NULL );
        return( NFM_E_SQL_QUERY );
    }

    return(  NFM_S_SUCCESS );
}

NFMvalidate_set_rev( set_cat_name, set_item_name, set_item_rev )
    char *set_cat_name;
    char *set_item_name;
    char *set_item_rev;
{
    long   status;

    MEMptr buffer = NULL;

    static char *fname = "NFMvalidate_set_rev";

    _NFMdebug(( fname, "Set Cat Name  : <%s>\n", set_cat_name ));
    _NFMdebug(( fname, "Set Item Name : <%s>\n", set_item_name ));
    _NFMdebug(( fname, "Set Rev Name : <%s>\n", set_item_rev ));

    if( strlen( set_cat_name ) == 0 )
    {
        ERRload_struct( NFM, NFM_E_INVALID_CATALOG, "%s"," " );
        return( NFM_E_INVALID_CATALOG );
    }

    if( strlen( set_item_name ) == 0 )
    {
        ERRload_struct( NFM, NFM_E_INVALID_SET_ITEM, "%s%s",set_cat_name," " );
        return( NFM_E_INVALID_SET_ITEM );
    }

    if( strlen( set_item_rev ) == 0 )
    {
        ERRload_struct( NFM, NFM_E_INVALID_SET_REV, "%s", set_cat_name,
			set_item_name, " " );
        return( NFM_E_INVALID_SET_REV );
    }

    sprintf( sql_string, "SELECT n_itemname FROM %s WHERE n_itemname = '%s' AND n_itemrev = '%s'", set_cat_name, set_item_name, set_item_rev );
    status = SQLquery( sql_string, &buffer, BUFFER_SIZE );

    MEMclose( &buffer );

    _NFMdebug(( fname, "SQLquery <0x%.8x>\n", status ));

    if( status == SQL_I_NO_ROWS_FOUND )
    {
        ERRload_struct( NFM, NFM_E_INVALID_SET_REV, "%s%s%s", set_cat_name,
			set_item_name, set_item_rev );
        return( NFM_E_INVALID_SET_REV );
    }
    else if( status != SQL_S_SUCCESS )
    {
        ERRload_struct( NFM, NFM_E_SQL_QUERY, NULL, NULL );
        return( NFM_E_SQL_QUERY );
    }

   return(  NFM_S_SUCCESS );
}

NFMvalidate_workflow( workflow_name )
    char *workflow_name;
{
    long   status;
    MEMptr buffer = NULL;
    static char *fname = "NFMvalidate_workflow";

    _NFMdebug(( fname, "Workflow Name : <%s>\n", workflow_name ));

    if( strlen( workflow_name ) == 0 )
    {
        ERRload_struct( NFM, NFM_E_INVALID_WORKFLOW, "%s", " " );
        return( NFM_E_INVALID_WORKFLOW );
    }

    sprintf( sql_string, 
     "SELECT n_workflowname FROM nfmworkflow WHERE n_workflowname = '%s'", 
	       workflow_name );
    status = SQLquery( sql_string, &buffer, BUFFER_SIZE );

    MEMclose( &buffer );

    _NFMdebug(( fname, "SQLquery <0x%.8x>\n", status ));

    if( status == SQL_I_NO_ROWS_FOUND )
    {
        ERRload_struct( NFM, NFM_E_INVALID_WORKFLOW, "%s", workflow_name );
        return( NFM_E_INVALID_WORKFLOW );
    }
    else if( status != SQL_S_SUCCESS )
    {
        ERRload_struct( NFM, NFM_E_SQL_QUERY, NULL, NULL );
        return( NFM_E_SQL_QUERY );
    }

    return(  NFM_S_SUCCESS );
}

NFMvalidate_acl( wf_name, acl_name )
    char *wf_name;
    char *acl_name;
{
    long   status;
    MEMptr buffer = NULL;
    static char *fname = "NFMvalidate_acl";

    _NFMdebug(( fname, "WF  Name : <%s>\n", wf_name ));
    _NFMdebug(( fname, "Acl Name : <%s>\n", acl_name ));

    if( strlen( wf_name ) == 0 )
    {
        ERRload_struct( NFM, NFM_E_INVALID_WORKFLOW, "%s", wf_name );
        return( NFM_E_INVALID_WORKFLOW );
    }
    if( strlen( acl_name ) == 0 )
    {
        ERRload_struct( NFM, NFM_E_INVALID_ACL, "%s", acl_name );
        return( NFM_E_INVALID_ACL );
    }

    sprintf( sql_string, 
	    "SELECT n_aclname FROM nfmacls WHERE n_aclname = '%s' AND n_workflowno = (SELECT n_workflowno from nfmworkflow WHERE n_workflowname = '%s')", 
	acl_name, wf_name );
    status = SQLquery( sql_string, &buffer, BUFFER_SIZE );

    MEMclose( &buffer );

    _NFMdebug(( fname, "SQLquery <0x%.8x>\n", status ));

    if( status == SQL_I_NO_ROWS_FOUND )
    {
        ERRload_struct( NFM, NFM_E_INVALID_ACL, "%s", acl_name );
        return( NFM_E_INVALID_ACL );
    }
    else if( status != SQL_S_SUCCESS )
    {
        ERRload_struct( NFM, NFM_E_SQL_QUERY, NULL, NULL );
        return( NFM_E_SQL_QUERY );
    }

    return(  NFM_S_SUCCESS );
}

NFMvalidate_user( user_name )
    char *user_name;
{
    long   status;
    MEMptr buffer = NULL;
    static char *fname = "NFMvalidate_user";

    _NFMdebug(( fname, "User Name : <%s>\n", user_name ));

    if( strlen( user_name ) == 0 )
    {
        ERRload_struct( NFM, NFM_E_INVALID_USER, "%s", user_name );
        return( NFM_E_INVALID_USER );
    }

    sprintf( sql_string, 
	 "SELECT n_username FROM nfmusers WHERE n_username = '%s'", user_name );
    status = SQLquery( sql_string, &buffer, BUFFER_SIZE );

    MEMclose( &buffer );

    _NFMdebug(( fname, "SQLquery <0x%.8x>\n", status ));

    if( status == SQL_I_NO_ROWS_FOUND )
    {
        ERRload_struct( NFM, NFM_E_INVALID_USER, "%s", user_name );
        return( NFM_E_INVALID_USER );
    }
    else if( status != SQL_S_SUCCESS )
    {
        ERRload_struct( NFM, NFM_E_SQL_QUERY, NULL, NULL );
        return( NFM_E_SQL_QUERY );
    }

    return(  NFM_S_SUCCESS );
}

/*  This routine maps the input nfmname in the input catalog to the
 *  application attribute name.
 */

NFMval_map_name( catalog, nfm_name, attr_name )
    char	*catalog;	/* i - catalog name */
    char	*nfm_name;	/* i - nfm attribute name */
    char	*attr_name;	/* o - mapped attribute name */
{
    long	status;
    char	**data_ptr;
    MEMptr	buffer = NULL;
		
    static 	char *fname = "NFMval_map_name";

    sprintf( sql_string, "SELECT n_name FROM nfmattributes WHERE n_tableno IN (SELECT n_tableno FROM nfmtables where n_tablename='%s' ) AND n_name ='%s' ",
	     catalog , nfm_name );
    status = SQLquery( sql_string, &buffer, BUFFER_SIZE);
    if( status != SQL_S_SUCCESS )
    {
        _NFMdebug(( fname, "SQLquery = <0x%.8x>\n", status));
        MEMclose (&buffer);
        return( status );
    }
    status = MEMbuild_array (buffer);
    if( status != MEM_S_SUCCESS )
    {
	MEMclose (&buffer);
	return( status );
    }

    data_ptr = (char **) buffer->data_ptr;
    strcpy( attr_name, data_ptr[0] );

    MEMclose( &buffer );

    return( NFM_S_SUCCESS );
}
