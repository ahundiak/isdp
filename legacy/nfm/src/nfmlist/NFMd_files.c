#include "machine.h"
#include <stdio.h>
#include "NFMapi.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "DEBUG.h"
#include "ERR.h"


long NFMdisplay_item_files( catalog, item, rev, search, sort,
		       syn_list, data_list )

char   *catalog;
char   *item;
char   *rev;
char   *search;
char   *sort;
MEMptr *syn_list;
MEMptr *data_list;
{
    int    i;
    int    j;
    int    tot_cat_data;
    int    tot_fcat_data;
    int    no_flag;
    long   status;
    long   user_id = 0;
    char   fmt[20];
    char   str[NFM_SYNONYM+3];
    char   sa_name[NFM_SANAME+1];
    char   max_version[20];
    char   select_str[2048];
    char   select_str1[1024];
    char   **attr;
    char   **data;
    char   **fcat_attr;
    MEMptr cat_buffer = NULL;
    MEMptr fcat_buffer = NULL;
    MEMptr data_buffer = NULL;
    struct NFMquery_info *search_info = NULL;
    struct NFMquery_info *sort_info = NULL;
    char  theItemName[512]; /* PS */
    char  theItemRevn[512];

    static char *fname = "NFMdisplay_item_files";

    _NFMdebug(( fname, "Catalog <%s>\n", catalog ));
    _NFMdebug(( fname, "Item    <%s>\n", item ));
    _NFMdebug(( fname, "Rev     <%s>\n", rev ));
    _NFMdebug(( fname, "Search  <%s>\n", search ));
    _NFMdebug(( fname, "Sort    <%s>\n", sort ));

    NFMtic_to_tics(item, theItemName);
    NFMtic_to_tics(rev, theItemRevn);

/* item and rev are replaced with the properly ticked theItemName and 
   theItemRevn - PS 
    sprintf( select_str, "SELECT n_itemno FROM %s WHERE n_itemname = '%s' AND n_itemrev = '%s'", catalog, item, rev );
*/
    sprintf( select_str, "SELECT n_itemno FROM %s WHERE n_itemname = '%s' AND n_itemrev = '%s'", catalog, theItemName, theItemRevn );

    status = SQLquery( select_str, &fcat_buffer, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
	_NFMdebug(( fname, "Query <0x%.8x>\n", status ));
	MEMclose( &fcat_buffer );
        ERRload_struct( NFM, NFM_E_SQL_QUERY, "", NULL );
	return( NFM_E_SQL_QUERY );
    }

    status = MEMbuild_array( fcat_buffer );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &fcat_buffer );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _NFMdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
   
    data = (char**)fcat_buffer->data_ptr;
    strcpy( fmt, data[0] );
    MEMclose( &fcat_buffer );

    /*  Get maximum 'n_fileversion' in <f_catalog> */
    sprintf( select_str, "SELECT MAX(n_fileversion) FROM f_%s WHERE n_itemnum = %s", catalog, fmt );
    status = SQLquery( select_str, &fcat_buffer, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
	_NFMdebug(( fname, "Query <0x%.8x>\n", status ));
	MEMclose( &fcat_buffer );
        ERRload_struct( NFM, NFM_E_SQL_QUERY, "", NULL );
	return( NFM_E_SQL_QUERY );
    }

    status = MEMbuild_array( fcat_buffer );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &fcat_buffer );
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _NFMdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
   
    data = (char**)fcat_buffer->data_ptr;
    strcpy( max_version, data[0] );
    MEMclose( &fcat_buffer );
    _NFMdebug(( fname, "Maximum Fileversion <%s>\n", max_version ));

    sprintf( select_str, "SELECT n_synonym, n_name, n_datatype, n_seqno FROM nfmattributes WHERE n_tableno = (SELECT n_tableno FROM nfmtables WHERE n_tablename = '%s') AND n_read = 'Y' ORDER BY n_seqno",catalog );

    status = SQLquery( select_str, &cat_buffer, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
	_NFMdebug(( fname, "Query <0x%.8x>\n", status ));
	MEMclose( &cat_buffer );
        ERRload_struct( NFM, NFM_E_SQL_QUERY, "", NULL );
	return( NFM_E_SQL_QUERY );
    }
  
    status = MEMbuild_array( cat_buffer );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &cat_buffer );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    sprintf( select_str, "SELECT n_synonym, n_name, n_datatype, n_seqno FROM nfmattributes WHERE n_tableno = (SELECT n_tableno FROM nfmtables WHERE n_tablename = 'f_%s') AND n_read = 'Y' ORDER BY n_seqno",catalog );

    status = SQLquery( select_str, &fcat_buffer, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
	_NFMdebug(( fname, "Query <0x%.8x>\n", status ));
	MEMclose( &fcat_buffer );
	MEMclose( &cat_buffer );
        ERRload_struct( NFM, NFM_E_SQL_QUERY, "", NULL );
	return( NFM_E_SQL_QUERY );
    }
  
    status = MEMbuild_array( fcat_buffer );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &fcat_buffer );
        MEMclose( &cat_buffer );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    attr = (char **)cat_buffer->data_ptr;
    tot_cat_data = cat_buffer->rows * cat_buffer->columns;
    fcat_attr = (char **)fcat_buffer->data_ptr;
    tot_fcat_data = fcat_buffer->rows*fcat_buffer->columns;

    status = MEMopen( syn_list, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &fcat_buffer );
	MEMclose( &cat_buffer );
	ERRload_struct( NFM, NFM_E_MEM, "", NULL );
	_NFMdebug(( fname, "MEMopen <0x%.8x>\n", status ));
 	return( NFM_E_MEM );
    }

    status = MEMopen( data_list, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &fcat_buffer );
	MEMclose( &cat_buffer );
	MEMclose( syn_list );
	ERRload_struct( NFM, NFM_E_MEM, "", NULL );
	_NFMdebug(( fname, "MEMopen <0x%.8x>\n", status ));
 	return( NFM_E_MEM );
    }
  
    sprintf( fmt, "char(%d)", NFM_SYNONYM );
    status = MEMwrite_format( *syn_list, "name", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &fcat_buffer );
        MEMclose( &cat_buffer );
	MEMclose( syn_list );
	MEMclose( data_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    /*  Build synonym buffer, columns for data buffer and SELECT statement */

    strcpy( select_str, "SELECT " );

/*  Catalog buffer */

    for( i=0,j=0; i<tot_cat_data; i+=cat_buffer->columns, ++j)
    {
        no_flag = 0;
        if( strcmp( attr[i+1], "n_aclno" ) == 0 )
        {
            no_flag = 1;
            status = NFMd_get_name_synonym( "n_aclname", "nfmacls", str );
	    sprintf( fmt, "char(%d)", NFM_ACLNAME );
        }
        else if( strcmp( attr[i+1], "n_stateno" ) == 0 )
        {
            no_flag = 2;
            status = NFMd_get_name_synonym( "n_statename", "nfmstates",str );
	    sprintf( fmt, "char(%d)", NFM_STATENAME );
        }
	/*  Skip n_prevstateno because I can't do the query on both
	 *  n_stateno and n_prevstateno.
 	 */
        else if( strcmp( attr[i+1], "n_prevstateno" ) == 0 )
	    continue;
        else
        {
            strcpy( str, attr[i] );
	    strcpy( fmt, attr[i+2] );
        }
        strcat( str, "\1" );

        status = MEMwrite( *syn_list, str );
        if( status != MEM_S_SUCCESS )
        {
	    MEMclose( &fcat_buffer );
            MEMclose( &cat_buffer );
  	    MEMclose( syn_list );
	    MEMclose( data_list );
            ERRload_struct( NFM, NFM_E_MEM, "", NULL );
            _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
            return( NFM_E_MEM );
        }

	status = MEMwrite_format( *data_list, attr[i+1], fmt );
        if( status != MEM_S_SUCCESS )
        {
	    MEMclose( &fcat_buffer );
            MEMclose( &cat_buffer );
	    MEMclose( syn_list );
	    MEMclose( data_list );
            ERRload_struct( NFM, NFM_E_MEM, "", NULL );
            _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
            return( NFM_E_MEM );
        }
	if( no_flag == 1 )
	    strcat( select_str, "nfmacls.n_aclname" );

	else if(no_flag == 2)
	    strcat( select_str, "nfmstates.n_statename" );

	else
	{
	    strcat( select_str, catalog );
	    strcat( select_str, "." );
	    strcat( select_str, attr[i+1] );
	}
        strcat( select_str, "," );
    }

/*  f_catalog buffer */

    for( i=0,j=0; i<tot_fcat_data; i+=fcat_buffer->columns, ++j)
    {
 	/* Synonym buffer */
	_NFMdebug(( fname, "Writing synonym <%s>\n", fcat_attr[i] ));
        strcpy( str, fcat_attr[i] );
	strcat( str, "\1" );
        status = MEMwrite( *syn_list, str );
        if( status != MEM_S_SUCCESS )
        {
            MEMclose( &cat_buffer );
	    MEMclose( &fcat_buffer );
  	    MEMclose( syn_list );
	    MEMclose( data_list );
            ERRload_struct( NFM, NFM_E_MEM, "", NULL );
            _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
            return( NFM_E_MEM );
        }

	/* Data buffer columns -- look for storage area numbers 
	 * and put names in their place.
	 */
	if( ( strcmp( fcat_attr[i+1], "n_cisano" ) == 0 ) ||	
	    ( strcmp( fcat_attr[i+1], "n_cosano" ) == 0 ) )
	    sprintf( fmt, "char(%d)", NFM_SANAME );
	else
	    strcpy( fmt, fcat_attr[i+2] );
	_NFMdebug(( fname, "Writing column <%s>\n", fcat_attr[i+1] ));
	status = MEMwrite_format( *data_list, fcat_attr[i+1], fmt );
        if( status != MEM_S_SUCCESS )
        {	
	    MEMclose( &fcat_buffer );
            MEMclose( &cat_buffer );
	    MEMclose( syn_list );
	    MEMclose( data_list );
            ERRload_struct( NFM, NFM_E_MEM, "", NULL );
            _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
            return( NFM_E_MEM );
        }
        strcat( select_str, "f_" );
	strcat( select_str, catalog );
	strcat( select_str, "." );
	strcat( select_str, fcat_attr[i+1] );
        if( (j+1) < fcat_buffer->rows )
            strcat( select_str, "," );
	_NFMdebug(( fname, "Select str <%s>\n", select_str ));
    }
    
    sprintf(select_str1, " FROM f_%s,%s,nfmacls,nfmstates WHERE (f_%s.n_itemnum =%s.n_itemno) AND (%s.n_itemname = '%s') AND (%s.n_itemrev = '%s') AND (%s.n_stateno = nfmstates.n_stateno) AND (f_%s.n_fileversion = %s) AND (%s.n_aclno = nfmacls.n_aclno)",
/* item and rev are changed to theItemName and theItemRevn which are 
   properly ticked - PS
catalog, catalog, catalog, catalog, catalog, item, catalog, rev,
*/
catalog, catalog, catalog, catalog, catalog, theItemName, catalog, theItemRevn,
catalog, catalog, max_version, catalog );
    _NFMdebug(( fname, "%s\n", "After select_str1" ));
    if( strlen(search) > 0 )
    {
        search_info = 
		(struct NFMquery_info *)malloc(sizeof(struct NFMquery_info));
        status = _NFMretrieve_query ( search, search_info );
        if( status != NFM_S_SUCCESS )
        {
  	    _NFMdebug(( fname, "_NFMretrieve_query <0x%.8x>\n", status ));
  	    NFMfree_query_struct( search_info );
	    return( status );
	}
	strcat( select_str1, " AND " );
	strcat( select_str1, search_info->where_clause );
	NFMfree_query_struct( search_info );
    }
    strcat( select_str1, " ORDER BY " );
    if( strlen(sort) > 0 )
    {
        sort_info = 
		(struct NFMquery_info *)malloc(sizeof(struct NFMquery_info));
        status = _NFMretrieve_query ( sort, sort_info );
        if( status != NFM_S_SUCCESS )
        {
  	    _NFMdebug(( fname, "_NFMretrieve_query <0x%.8x>\n", status ));
  	    NFMfree_query_struct( sort_info );
	    return( status );
	}
	strcat( select_str1, sort_info->where_clause );
	NFMfree_query_struct( sort_info );
    }
    else
    {
	strcat( select_str1, catalog );
	strcat( select_str1, "." );
	strcat( select_str1, attr[1] );
    }

    strcat( select_str, select_str1 );
    _NFMdebug(( fname, "%s\n", "Concatenate strings" ));
    status = SQLquery( select_str, &data_buffer, MEM_SIZE );
    if( status == SQL_I_NO_ROWS_FOUND )
    {
	MEMclose( &fcat_buffer );
	MEMclose( &cat_buffer );
	MEMclose( &data_buffer );
        MEMclose( syn_list );
        MEMclose( data_list );
        ERRload_struct (NFM,  NFM_E_DISPLAY_FILES, "%s%s", item, rev );
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_DISPLAY_FILES );
    }
    else if( status != SQL_S_SUCCESS )
    {
	MEMclose( &fcat_buffer );
	MEMclose( &cat_buffer );
	MEMclose( &data_buffer );
	MEMclose( syn_list );
	MEMclose( data_list );
        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_SQL_QUERY);
    }
    MEMclose( &cat_buffer );
    MEMclose( &fcat_buffer );

    status = MEMbuild_array( data_buffer );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &data_buffer );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    data = (char**)data_buffer->data_ptr;
    attr = (char**)data_buffer->column_ptr;
    tot_cat_data = data_buffer->rows*data_buffer->columns;

    for( i=0; i<tot_cat_data; i+=data_buffer->columns )
    {
	strcpy( select_str, "" );
	for( j=0; j<data_buffer->columns; ++j )
	{
	    if( (strcmp( attr[j], "n_cisano" ) == 0 ) ||
		(strcmp( attr[j], "n_cosano" ) == 0 ) )
	    {
   	        if( strcmp( data[i+j], "" ) != 0 )
		{
		    status = NFMget_sa_name(user_id, atol(data[i+j]), sa_name);
		    if( status != NFM_S_SUCCESS )
		    {
		        _NFMdebug(( fname, "NFMget_sa_name <0x%.8x>\n", 
					status ));
 		        MEMclose( syn_list );
	   	        MEMclose( data_list );
		        MEMclose( &data_buffer );
		        return( status );
	  	    }
		    _NFMdebug(( fname, "SA Name <%s>\n", sa_name ));
		    strcat( select_str, sa_name );
		}
		else
		    strcat( select_str, data[i+j] );
	    }
	    else
		strcat( select_str, data[i+j] );

	    strcat( select_str, "\1" );
	}
	_NFMdebug(( fname, "Data String <%s>\n", select_str ));
        status = MEMwrite( *data_list, select_str );
        if( status != MEM_S_SUCCESS )
        {
            MEMclose( &data_buffer );
  	    MEMclose( syn_list );
	    MEMclose( data_list );
            ERRload_struct( NFM, NFM_E_MEM, "", NULL );
            _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
            return( NFM_E_MEM );
        }
    }
    MEMclose( &data_buffer );
    _NFMdebug(( fname, "%s\n", "Returning Success ..." ));

    return( NFM_S_SUCCESS );
}
