
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include <stdio.h>
#include "NFMapi.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "DEBUG.h"
#include "ERR.h"

extern   int  SQLcursor[40];

#define  BUFFER_SIZE  16000

long NFMdisplay_items( catalog, search, sort, type, syn_list, data_list )

char   *catalog;
char   *search;
char   *sort;
int    type;
MEMptr *syn_list;
MEMptr *data_list;
{
    int    i;
    int    j;
    int    tot_data;
    int	   no_flag;
    int    fork = 0;
    int    first_attr = 0;
    long   status;
    long   NFMdisplay_items_short();
    char   fmt[20];
    char   str[NFM_SYNONYM+3];
    char   select_clause[1024];
    char   select_str[1048];
    char   from_str[512];
    char   *search_ptr;
    char   *sort_ptr;
    char   *total_ptr;
    char   **attr;
    MEMptr attr_buffer = NULL;
    struct NFMquery_info *search_info = NULL;
    struct NFMquery_info *sort_info = NULL;

    static char *fname = "NFMdisplay_items";

    _NFMdebug(( fname, "Catalog <%s>\n", catalog ));
    _NFMdebug(( fname, "Search  <%s>\n", search ));
    _NFMdebug(( fname, "Sort    <%s>\n", sort ));
    _NFMdebug(( fname, "Type    <%d>\n", type ));

    if( strlen( catalog ) == 0 )
    {
        ERRload_struct (NFM,  NFM_E_DISPLAY_ITEMS, "%s", " ");
        return ( NFM_E_DISPLAY_ITEMS );
    }

    if( type == NFM_SHORT_DISPLAY )
    {
	status = NFMdisplay_items_short( catalog, search, sort, 
					 syn_list, data_list );
	return( status );
    }

    sprintf( select_str, "SELECT n_synonym, n_name, n_seqno FROM nfmattributes WHERE n_tableno = (SELECT n_tableno FROM nfmtables WHERE n_tablename = '%s') AND n_read = 'Y' ORDER BY n_seqno",catalog );

    status = SQLquery( select_str, &attr_buffer, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
	_NFMdebug(( fname, "Query <0x%.8x>\n", status ));
	MEMclose( &attr_buffer );
        ERRload_struct( NFM, NFM_E_SQL_QUERY, "", NULL );
	return( NFM_E_SQL_QUERY );
    }
  
    status = MEMbuild_array( attr_buffer );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &attr_buffer );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    attr = (char **)attr_buffer->data_ptr;
    tot_data = attr_buffer->rows * attr_buffer->columns;

    status = MEMopen( syn_list, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &attr_buffer );
	ERRload_struct( NFM, NFM_E_MEM, "", NULL );
	_NFMdebug(( fname, "MEMopen <0x%.8x>\n", status ));
 	return( NFM_E_MEM );
    }
  
    sprintf( fmt, "char(%d)", NFM_SYNONYM );
    status = MEMwrite_format( *syn_list, "name", fmt );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &attr_buffer );
	MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    /*  Build synonym buffer and SELECT statement */

    strcpy( select_clause, "" );
    first_attr = 0;
    for( i=0,j=0; i<tot_data; i+=attr_buffer->columns, ++j)
    {
	no_flag = 0;
	if( strcmp( attr[i+1], "n_aclno" ) == 0 )
	{
	    no_flag = 1;
	    status = NFMd_get_name_synonym( "n_aclname", "nfmacls", str );
	}
	else
	    strcpy( str, attr[i] );

	if( strcmp( attr[i+1], "n_stateno" ) == 0 )
	{
	    no_flag = 2;
	    status = NFMd_get_name_synonym( "n_statename", "nfmstates", str );
	}
	else
	    strcpy( str, attr[i] );
 	/*  Skip n_prevstateno because I can't query for both n_stateno and
	 *  n_prevstateno and get anything back.
	 */
	if( strcmp( attr[i+1], "n_prevstateno" ) == 0 )
	    continue;

	strcat( str, "\1" );
        status = MEMwrite( *syn_list, str );
        if( status != MEM_S_SUCCESS )
        {
            MEMclose( &attr_buffer );
  	    MEMclose( syn_list );
            ERRload_struct( NFM, NFM_E_MEM, "", NULL );
            _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
            return( NFM_E_MEM );
        }
	if( no_flag == 1 )
	{
	    if (first_attr == 0)
		first_attr = 1;
	    else
		strcat (select_clause, ",");

            strcat( select_clause, "nfmacls.n_aclname" );
	
        }
	else if( no_flag == 2 )
	{
            if (first_attr == 0)
                first_attr = 1;
            else
                strcat (select_clause, ",");

	    strcat( select_clause, "nfmstates.n_statename" );
	}
	else
	{	
            if (first_attr == 0)
                first_attr = 1;
            else
                strcat (select_clause, ",");

	    strcat( select_clause, "a." );
  	    strcat( select_clause, attr[i+1] );
	}
    }
    strcpy( from_str, " FROM ");
    strcat( from_str, catalog );
    strcat( from_str, " a, " );
    strcat( from_str, " nfmacls, nfmstates" );
    
    if( strlen(search) > 0 )
    {
        search_info = 
		(struct NFMquery_info *)malloc(sizeof(struct NFMquery_info));
        status = _NFMretrieve_query ( search, search_info );
        if( status != NFM_S_SUCCESS )
        {
  	    _NFMdebug(( fname, "_NFMretrieve_query <0x%.8x>\n", status ));
	    return( status );
	}

	search_ptr = (char*)malloc( strlen(search_info->where_clause) + 200 );
        strcpy( search_ptr, " WHERE (a.n_aclno = nfmacls.n_aclno) AND (a.n_stateno = nfmstates.n_stateno) " );

	strcat( search_ptr, " AND " );
	strcat( search_ptr, search_info->where_clause );

        /* Now PAY ATTENTION !!  I need to figure out whether or
	 * not to do aliasing in the 'from' clause for an <f_catalog>.
	 * A function will be called that takes the 'from' clause and its
	 * results tell me the following :
	 	0 - catalog only; don't do anything else
	 	1 - f_catalog only; I need to join the <cat> and <f_cat>
		    in the where clause and alias the <f_cat> in the from
		    clause.
		2 - catalog and f_catalog; I need to alias the <f_cat>
		    in the 'from' clause.
	 */
	if( strlen( search_info->from_clause ) > 0 )
	{
	    _NFMdebug(( fname, "Calling _NFMcat_f_cat with <%s>\n",
				search_info->from_clause ));
	    status = _NFMcat_f_cat( search_info->from_clause, &fork );
	    _NFMdebug(( fname, "From_clause Case  <%d>\n", fork ));
	    if( fork == 1 )
	    {
		strcat( from_str, ", f_" );
		strcat( from_str, catalog );
		strcat( from_str, " f_a " );
		
		strcat( search_ptr, " AND (a.n_itemno = f_a.n_itemnum) " );
	    }
	    else if( fork == 2 )
	    {
		strcat( from_str, ", f_" );
		strcat( from_str, catalog );
		strcat( from_str, " f_a " );
	    }
	}
	NFMfree_query_struct( search_info );
    }
    else
    {
	search_ptr = (char*)malloc( 100 );
        strcpy( search_ptr, " WHERE (a.n_aclno = nfmacls.n_aclno) AND (a.n_stateno = nfmstates.n_stateno) " );
    }

    if( strlen(sort) > 0 )
    {
        sort_info = 
		(struct NFMquery_info *)malloc(sizeof(struct NFMquery_info));
        status = _NFMretrieve_query ( sort, sort_info );
        if( status != NFM_S_SUCCESS )
        {
  	    _NFMdebug(( fname, "_NFMretrieve_query <0x%.8x>\n", status ));
	    return( status );
	}

        sort_ptr = (char*) malloc ( strlen(sort_info->order_by_clause) + 50 );
        strcpy( sort_ptr, " ORDER BY " );
	strcat( sort_ptr, sort_info->order_by_clause );
	NFMfree_query_struct( sort_info );
    }
    else
    {
	sort_ptr = (char*)malloc( 100 );
        strcpy( sort_ptr, " ORDER BY " );
        strcat( sort_ptr, "a." );
	strcat( sort_ptr, attr[1] );
    }

    /* KT - 2/23/93 - If there is a f_catalog attribute in the WHERE clause,
                      use SELECT DISTINCT instead of SELECT */

    if (fork == 1)
        sprintf (select_str, "SELECT DISTINCT %s", select_clause);
    else
        sprintf (select_str, "SELECT %s", select_clause);

    _NFMdebug(( fname, "Select str <%s>\n", select_str ));
    _NFMdebug(( fname, "From str   <%s>\n", from_str ));
    _NFMdebug(( fname, "Search str  <%s>\n", search_ptr ));
    _NFMdebug(( fname, "Sort str  <%s>\n", sort_ptr ));

    total_ptr = (char*)malloc( strlen(search_ptr) + strlen(sort_ptr) +
		strlen(select_str) + strlen(from_str) + 10 );
			
    sprintf( total_ptr, "%s%s%s%s", select_str, from_str, search_ptr,
				     sort_ptr );

    _NFMdebug(( fname, "Full select str <%s>\n", total_ptr ));

    status = SQLquery( total_ptr, data_list, BUFFER_SIZE );

    if( status == SQL_I_NO_ROWS_FOUND )
    {
	MEMclose( &attr_buffer );
        MEMclose( syn_list );
        MEMclose( data_list );
        free( total_ptr );
        free( search_ptr );
        free( sort_ptr );
        ERRload_struct (NFM,  NFM_E_DISPLAY_ITEMS, "%s", catalog);
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_DISPLAY_ITEMS );
    }
    else if( status != SQL_S_SUCCESS )
    {
	MEMclose( &attr_buffer );
	MEMclose( syn_list );
	MEMclose( data_list );
        free( total_ptr );
        free( search_ptr );
        free( sort_ptr );
        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_SQL_QUERY);
    }
    MEMclose( &attr_buffer );

    free( total_ptr );
    free( search_ptr );
    free( sort_ptr );

    return( NFM_S_SUCCESS );
}

long NFMdisplay_items_partial( catalog, search, sort, type, rows, 
			       syn_list, data_list )

char   *catalog;
char   *search;
char   *sort;
int    type;
long   rows;
MEMptr *syn_list;
MEMptr *data_list;
{
    int    i;
    int    j;
    int    tot_data;
    int	   no_flag;
    int    fork = 0;
    int    first_attr = 0;
    long   status;
    long   NFMdisplay_items_short_partial();
    char   fmt[20];
    char   str[NFM_SYNONYM+3];
    char   select_clause[1024];
    char   select_str[1048];
    char   from_str[512];
    char   *search_ptr;
    char   *sort_ptr;
    char   *total_ptr;
    char   **attr;
    MEMptr attr_buffer = NULL;
    struct NFMquery_info *search_info = NULL;
    struct NFMquery_info *sort_info = NULL;

    static char *fname = "NFMdisplay_items_partial";

    _NFMdebug(( fname, "Catalog <%s>\n", catalog ));
    _NFMdebug(( fname, "Search  <%s>\n", search ));
    _NFMdebug(( fname, "Sort    <%s>\n", sort ));
    _NFMdebug(( fname, "Type    <%d>\n", type ));
    _NFMdebug(( fname, "Rows    <%ld>\n", rows ));

/*  If rows == 0, we are just here to close the cursor and clean up
 *  the partial query.
 */
    if( rows == 0 )
    {
	if( type == NFM_FULL_DISPLAY )
	{
            status = SQLquery_cursor2( "", data_list, BUFFER_SIZE, rows );
            if( status != SQL_S_SUCCESS )
            {
                _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
                return ( status );
  	    }
	}
	else
	{
            status = SQLquery_cursor3( "", data_list, BUFFER_SIZE, rows );
            if( status != SQL_S_SUCCESS )
            {
                _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
                return ( status );
  	    }
	}
	return( NFM_S_SUCCESS );
    }
 
    status = NFMcheck_transaction();
    if( status == NFM_E_TRANSACTION_OFF )
    {
	ERRload_struct( NFM, NFM_S_SUCCESS, NULL, NULL );
	_NFMdebug(( fname, "%s\n", "Autocommit was turned off" ));
    }
    else
    {
        status = NFMset_autocommit_off (0);
        _NFMdebug(( fname, "Autocommit status <0x%.8x>\n", status ));
	_NFMdebug(( fname, "%s\n", "Autocommit was turned on" ));
    }

    if( strlen( catalog ) == 0 )
    {
        ERRload_struct (NFM,  NFM_E_DISPLAY_ITEMS, "%s", " ");
        return ( NFM_E_DISPLAY_ITEMS );
    }

    if( type == NFM_SHORT_DISPLAY )
    {
	status = NFMdisplay_items_short_partial( catalog, search, sort, 
					 rows, syn_list, data_list );
	return( status );
    }

    sprintf( select_str, "SELECT n_synonym, n_name, n_seqno FROM nfmattributes WHERE n_tableno = (SELECT n_tableno FROM nfmtables WHERE n_tablename = '%s') AND n_read = 'Y' ORDER BY n_seqno",catalog );

    status = SQLquery( select_str, &attr_buffer, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
	_NFMdebug(( fname, "Query <0x%.8x>\n", status ));
	MEMclose( &attr_buffer );
        ERRload_struct( NFM, NFM_E_SQL_QUERY, "", NULL );
	if( SQLcursor[2] )
	    status = SQLquery_cursor2( "", data_list, MEM_SIZE, 0 );
	return( NFM_E_SQL_QUERY );
    }
  
    status = MEMbuild_array( attr_buffer );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &attr_buffer );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
        if( SQLcursor[2] )
            status = SQLquery_cursor2( "", data_list, MEM_SIZE, 0 );
        return( NFM_E_MEM );
    }

    attr = (char **)attr_buffer->data_ptr;
    tot_data = attr_buffer->rows * attr_buffer->columns;

    /*  Don't rebuild synonym buffer if it was already built
     */

    if( !SQLcursor[2] )
    {
	status = MEMopen( syn_list, MEM_SIZE );
        if( status != MEM_S_SUCCESS )
        {
	    MEMclose( &attr_buffer );
	    ERRload_struct( NFM, NFM_E_MEM, "", NULL );
  	    _NFMdebug(( fname, "MEMopen <0x%.8x>\n", status ));
    	    return( NFM_E_MEM );
        }
  
        sprintf( fmt, "char(%d)", NFM_SYNONYM );
        status = MEMwrite_format( *syn_list, "name", fmt );
        if( status != MEM_S_SUCCESS )
        {
            MEMclose( &attr_buffer );
  	    MEMclose( syn_list );
            ERRload_struct( NFM, NFM_E_MEM, "", NULL );
            _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
            return( NFM_E_MEM );
        }
    } /* END if( !SQLcursor[2] ) */
    else
    {
	MEMclose( syn_list );
	*syn_list = NULL;
    }

    /*  Build synonym buffer and SELECT statement */

    strcpy( select_clause, "" );
    first_attr = 0;
    for( i=0,j=0; i<tot_data; i+=attr_buffer->columns, ++j)
    {
	no_flag = 0;
	if( strcmp( attr[i+1], "n_aclno" ) == 0 )
	{
	    no_flag = 1;
	    if( !SQLcursor[2] )
  	        status = NFMd_get_name_synonym( "n_aclname", "nfmacls", str );
	}
	else
	    strcpy( str, attr[i] );

	if( strcmp( attr[i+1], "n_stateno" ) == 0 )
	{
	    no_flag = 2;
	    if( !SQLcursor[2] )
  	        status = NFMd_get_name_synonym("n_statename","nfmstates",str);
	}
	else
	    strcpy( str, attr[i] );
 	/*  Skip n_prevstateno because I can't query for both n_stateno and
	 *  n_prevstateno and get anything back.
	 */
	if( strcmp( attr[i+1], "n_prevstateno" ) == 0 )
	    continue;

   	if( !SQLcursor[2] )
	{
	    strcat( str, "\1" );
            status = MEMwrite( *syn_list, str );
            if( status != MEM_S_SUCCESS )
            {
                MEMclose( &attr_buffer );
    	        MEMclose( syn_list );
                ERRload_struct( NFM, NFM_E_MEM, "", NULL );
                _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
       		if( SQLcursor[2] )
                    status = SQLquery_cursor2( "", data_list, MEM_SIZE, 0 );
                return( NFM_E_MEM );
            }
	}
	if( no_flag == 1 )
	{
            if (first_attr == 0)
                first_attr = 1;
            else
                strcat (select_clause, ",");
	    strcat( select_clause, "nfmacls.n_aclname" );
	}
	else if( no_flag == 2 )
	{
            if (first_attr == 0)
                first_attr = 1;
            else
                strcat (select_clause, ",");
	    strcat( select_clause, "nfmstates.n_statename" );
	}
	else
	{	
            if (first_attr == 0)
                first_attr = 1;
            else
                strcat (select_clause, ",");
	    strcat( select_clause, "a." );
  	    strcat( select_clause, attr[i+1] );
	}
    }
    strcpy( from_str, " FROM ");
    strcat( from_str, catalog );
    strcat( from_str, " a, " );
    strcat( from_str, " nfmacls, nfmstates" );
    
    if( strlen(search) > 0 )
    {
        search_info = 
		(struct NFMquery_info *)malloc(sizeof(struct NFMquery_info));
        status = _NFMretrieve_query ( search, search_info );
        if( status != NFM_S_SUCCESS )
        {
  	    _NFMdebug(( fname, "_NFMretrieve_query <0x%.8x>\n", status ));
            if( SQLcursor[2] )
                status = SQLquery_cursor2( "", data_list, MEM_SIZE, 0 );
	    return( status );
	}

        search_ptr = (char*)malloc( strlen(search_info->where_clause)+200 );
        strcpy( search_ptr, " WHERE (a.n_aclno = nfmacls.n_aclno) AND (a.n_stateno = nfmstates.n_stateno) " );
	strcat( search_ptr, " AND " );
	strcat( search_ptr, search_info->where_clause );

        /* Now PAY ATTENTION !!  I need to figure out whether or
	 * not to do aliasing in the 'from' clause for an <f_catalog>.
	 * A function will be called that takes the 'from' clause and its
	 * results tell me the following :
	 	0 - catalog only; don't do anything else
	 	1 - f_catalog only; I need to join the <cat> and <f_cat>
		    in the where clause and alias the <f_cat> in the from
		    clause.
		2 - catalog and f_catalog; I need to alias the <f_cat>
		    in the 'from' clause.
	 */
	if( strlen( search_info->from_clause ) > 0 )
	{
	    _NFMdebug(( fname, "Calling _NFMcat_f_cat with <%s>\n",
				search_info->from_clause ));
	    status = _NFMcat_f_cat( search_info->from_clause, &fork );
	    _NFMdebug(( fname, "From_clause Case  <%d>\n", fork ));
	    if( fork == 1 )
	    {
		strcat( from_str, ", f_" );
		strcat( from_str, catalog );
		strcat( from_str, " f_a " );
		
		strcat( search_ptr, " AND (a.n_itemno = f_a.n_itemnum) " );
	    }
	    else if( fork == 2 )
	    {
		strcat( from_str, ", f_" );
		strcat( from_str, catalog );
		strcat( from_str, " f_a " );
	    }
	}
	NFMfree_query_struct( search_info );
    }
    else
    {
	search_ptr = (char*)malloc(100);
        strcpy( search_ptr, " WHERE (a.n_aclno = nfmacls.n_aclno) AND (a.n_stateno = nfmstates.n_stateno) " );
    }

    if( strlen(sort) > 0 )
    {
        sort_info = 
		(struct NFMquery_info *)malloc(sizeof(struct NFMquery_info));
        status = _NFMretrieve_query ( sort, sort_info );
        if( status != NFM_S_SUCCESS )
        {
  	    _NFMdebug(( fname, "_NFMretrieve_query <0x%.8x>\n", status ));
            if( SQLcursor[2] )
                status = SQLquery_cursor2( "", data_list, MEM_SIZE, 0 );
	    return( status );
	}
	sort_ptr = (char*)malloc( strlen(sort_info->order_by_clause) + 50);
        strcpy( sort_ptr, " ORDER BY " );
	strcat( sort_ptr, sort_info->order_by_clause );
	NFMfree_query_struct( sort_info );
    }
    else
    {
        sort_ptr = (char*)malloc(100);
        strcpy( sort_ptr, " ORDER BY " );
        strcat( sort_ptr, "a." );
	strcat( sort_ptr, attr[1] );
    }

    /* KT - 2/23/93 - If there is a f_catalog attribute in the WHERE clause,
                      use SELECT DISTINCT instead of SELECT */

    if (fork == 1)
        sprintf (select_str, "SELECT DISTINCT %s", select_clause);
    else
        sprintf (select_str, "SELECT %s", select_clause);

    _NFMdebug(( fname, "Select str <%s>\n", select_str ));
    _NFMdebug(( fname, "From str   <%s>\n", from_str ));
    _NFMdebug(( fname, "Search str  <%s>\n", search_ptr ));
    _NFMdebug(( fname, "Sort str  <%s>\n", sort_ptr ));

    total_ptr = (char*)malloc( strlen(select_str) + strlen(from_str) + 
		strlen(search_ptr) + strlen(sort_ptr) + 10 );
    sprintf( total_ptr, "%s%s%s%s", select_str, from_str, search_ptr,
			sort_ptr );

    _NFMdebug(( fname, "Full select str <%s>\n", total_ptr ));

    status = SQLquery_cursor2( total_ptr, data_list, BUFFER_SIZE, rows );
    if( status == SQL_I_NO_ROWS_FOUND )
    {
	MEMclose( &attr_buffer );
        MEMclose( syn_list );
        MEMclose( data_list );
	free( search_ptr );
 	free( sort_ptr );
	free( total_ptr );
        ERRload_struct (NFM,  NFM_E_DISPLAY_ITEMS, "%s", catalog);
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_DISPLAY_ITEMS );
    }
    else if( status != SQL_S_SUCCESS && status != SQL_I_NO_MORE_DATA)
    {
	MEMclose( &attr_buffer );
	MEMclose( syn_list );
	MEMclose( data_list );
	free( search_ptr );
 	free( sort_ptr );
	free( total_ptr );
        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_SQL_QUERY);
    }
    MEMclose( &attr_buffer );
    free( search_ptr );
    free( sort_ptr );
    free( total_ptr );

    if( status == SQL_I_NO_MORE_DATA )
	return( NFM_I_NO_MORE_BUFFERS );
    else
        return( NFM_S_SUCCESS );
}

long NFMdisplay_items_short( catalog, search, sort, syn_list, data_list )

char   *catalog;
char   *search;
char   *sort;
MEMptr *syn_list;
MEMptr *data_list;
{
    int    i;
    int    tot_data;
    int    fork;
    long   status;
    char   fmt[20];
    char   str[NFM_SYNONYM+3];
    char   select_clause[1024];
    char   select_str[1048];
    char   from_str[512];
    char   *search_ptr;
    char   *sort_ptr;
    char   *total_ptr;
    char   **attr;
    MEMptr attr_buffer = NULL;
    struct NFMquery_info *search_info = NULL;
    struct NFMquery_info *sort_info = NULL;

    static char *fname = "NFMdisplay_items_short";

    _NFMdebug(( fname, "Catalog <%s>\n", catalog ));
    _NFMdebug(( fname, "Search  <%s>\n", search ));
    _NFMdebug(( fname, "Sort    <%s>\n", sort ));

    if( strlen( catalog ) == 0 )
    {
        ERRload_struct (NFM,  NFM_E_DISPLAY_ITEMS, "%s", " ");
        return ( NFM_E_DISPLAY_ITEMS );
    }

    sprintf( select_str, "SELECT n_synonym FROM nfmattributes WHERE n_tableno = (SELECT n_tableno FROM nfmtables WHERE n_tablename = '%s') AND n_name IN ('n_itemno', 'n_itemname', 'n_itemrev')",catalog );

    status = SQLquery( select_str, &attr_buffer, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
	_NFMdebug(( fname, "Query <0x%.8x>\n", status ));
	MEMclose( &attr_buffer );
        ERRload_struct( NFM, NFM_E_SQL_QUERY, "", NULL );
	return( NFM_E_SQL_QUERY );
    }
  
    status = MEMbuild_array( attr_buffer );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &attr_buffer );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    attr = (char **)attr_buffer->data_ptr;
    tot_data = attr_buffer->rows*attr_buffer->columns;

    status = MEMopen( syn_list, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &attr_buffer );
	ERRload_struct( NFM, NFM_E_MEM, "", NULL );
	_NFMdebug(( fname, "MEMopen <0x%.8x>\n", status ));
 	return( NFM_E_MEM );
    }
  
    sprintf( fmt, "char(%d)", NFM_SYNONYM );
    status = MEMwrite_format( *syn_list, "name", fmt );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( &attr_buffer );
	MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    /*  Build synonym buffer */

    for( i=0; i<tot_data; i+=attr_buffer->columns)
    {
        strcpy( str, attr[i] );
        strcat( str, "\1" );
        status = MEMwrite( *syn_list, str );
        if( status != MEM_S_SUCCESS )
        {
            MEMclose( &attr_buffer );
            MEMclose( syn_list );
            ERRload_struct( NFM, NFM_E_MEM, "", NULL );
            _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
            return( NFM_E_MEM );
        }
    }
    strcpy( from_str, " FROM " );
    strcat( from_str, catalog );
    strcat( from_str, " a " );

    strcpy( select_clause, "a.n_itemno, a.n_itemname, a.n_itemrev");
    if( strlen(search) > 0 )
    {
        search_info = 
		(struct NFMquery_info *)malloc(sizeof(struct NFMquery_info));
        status = _NFMretrieve_query ( search, search_info );
        if( status != NFM_S_SUCCESS )
        {
  	    _NFMdebug(( fname, "_NFMretrieve_query <0x%.8x>\n", status ));
	    return( status );
	}
	search_ptr = (char*)malloc( strlen(search_info->where_clause)+100);
	strcpy( search_ptr, " WHERE " );
	strcat( search_ptr, search_info->where_clause );

        /* Now PAY ATTENTION !!  I need to figure out whether or
	 * not to do aliasing in the 'from' clause for an <f_catalog>.
	 * A function will be called that takes the 'from' clause and its
	 * results tell me the following :
	 	0 - catalog only; don't do anything else
	 	1 - f_catalog only; I need to join the <cat> and <f_cat>
		    in the where clause and alias the <f_cat> in the from
		    clause.
		2 - catalog and f_catalog; I need to alias the <f_cat>
		    in the 'from' clause.
	 */
	if( strlen( search_info->from_clause ) > 0 )
	{
	    _NFMdebug(( fname, "Calling _NFMcat_f_cat with <%s>\n",
				search_info->from_clause ));
	    status = _NFMcat_f_cat( search_info->from_clause, &fork );
	    _NFMdebug(( fname, "From_clause Case  <%d>\n", fork ));
	    if( fork == 1 )
	    {
		strcat( from_str, ", f_" );
		strcat( from_str, catalog );
		strcat( from_str, " f_a " );
		
		strcat( search_ptr, " AND (a.n_itemno = f_a.n_itemnum) " );
	    }
	    else if( fork == 2 )
	    {
		strcat( from_str, ", f_" );
		strcat( from_str, catalog );
		strcat( from_str, " f_a " );
	    }
	}
	NFMfree_query_struct( search_info );
    }
    else
    {
	search_ptr = (char*)malloc(2);
	strcpy( search_ptr, "" );
    }

    if( strlen(sort) > 0 )
    {
        sort_info = 
		(struct NFMquery_info *)malloc(sizeof(struct NFMquery_info));
        status = _NFMretrieve_query ( sort, sort_info );
        if( status != NFM_S_SUCCESS )
        {
  	    _NFMdebug(( fname, "_NFMretrieve_query <0x%.8x>\n", status ));
	    return( status );
	}
        sort_ptr = (char*)malloc(strlen(sort_info->order_by_clause) );
        strcpy( sort_ptr, " ORDER BY " );
	strcat( sort_ptr, sort_info->order_by_clause );
	NFMfree_query_struct( sort_info );
    }
    else
    {
	sort_ptr = (char*)malloc( 100 );
        strcpy( sort_ptr, " ORDER BY " );
        strcat( sort_ptr, "a.n_itemno" );
    }

    /* KT - 2/23/93 - If there is a f_catalog attribute in the WHERE clause,
                      use SELECT DISTINCT instead of SELECT */

    if (fork == 1)
        sprintf (select_str, "SELECT DISTINCT %s", select_clause);
    else
        sprintf (select_str, "SELECT %s", select_clause);

    _NFMdebug(( fname, "Select str <%s>\n", select_str ));
    _NFMdebug(( fname, "From str   <%s>\n", from_str ));
    _NFMdebug(( fname, "Search str  <%s>\n", search_ptr ));
    _NFMdebug(( fname, "Sort str  <%s>\n", sort_ptr ));
   
    total_ptr = (char*)malloc( strlen(select_str) + strlen(from_str) +
		strlen(search_ptr) + strlen(sort_ptr) + 10 );
    sprintf( total_ptr, "%s%s%s%s", select_str, from_str, search_ptr,
				    sort_ptr );

    _NFMdebug(( fname, "Full select str <%s>\n", total_ptr ));

    status = SQLquery( total_ptr, data_list, BUFFER_SIZE );
    if( status == SQL_I_NO_ROWS_FOUND )
    {
	MEMclose( &attr_buffer );
        MEMclose( syn_list );
        MEMclose( data_list );
 	free( total_ptr );
 	free( search_ptr );
 	free( sort_ptr );
        ERRload_struct (NFM,  NFM_E_DISPLAY_ITEMS, "%s", catalog);
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_DISPLAY_ITEMS );
    }
    else if( status != SQL_S_SUCCESS )
    {
	MEMclose( &attr_buffer );
	MEMclose( syn_list );
	MEMclose( data_list );
 	free( total_ptr );
 	free( search_ptr );
 	free( sort_ptr );
        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_SQL_QUERY);
    }
    MEMclose( &attr_buffer );

    free( total_ptr );
    free( search_ptr );
    free( sort_ptr );

    return( NFM_S_SUCCESS );
}

long NFMdisplay_items_short_partial( catalog, search, sort, 
			rows, syn_list, data_list )

char   *catalog;
char   *search;
char   *sort;
long   rows;
MEMptr *syn_list;
MEMptr *data_list;
{
    int    i;
    int    tot_data;
    int    fork;
    long   status;
    char   fmt[20];
    char   str[NFM_SYNONYM+3];
    char   select_clause[1024];
    char   select_str[1048];
    char   from_str[512];
    char   *total_ptr;
    char   *search_ptr;
    char   *sort_ptr;
    char   **attr;
    MEMptr attr_buffer = NULL;
    struct NFMquery_info *search_info = NULL;
    struct NFMquery_info *sort_info = NULL;

    static char *fname = "NFMdisplay_items_short_partial";

    _NFMdebug(( fname, "Catalog <%s>\n", catalog ));
    _NFMdebug(( fname, "Search  <%s>\n", search ));
    _NFMdebug(( fname, "Sort    <%s>\n", sort ));
    _NFMdebug(( fname, "Rows    <%ld>\n", rows ));

    if( strlen( catalog ) == 0 )
    {
        ERRload_struct (NFM,  NFM_E_DISPLAY_ITEMS, "%s", " ");
        return ( NFM_E_DISPLAY_ITEMS );
    }

    /*  If the cursor has been prepared then the synonym list has been built
     *  once already and does not need to be built again. A null buffer will
     *  be sent back in its place.
     */
    if( !SQLcursor[3] )
    {
        sprintf( select_str, "SELECT n_synonym FROM nfmattributes WHERE n_tableno = (SELECT n_tableno FROM nfmtables WHERE n_tablename = '%s') AND n_name IN ('n_itemno', 'n_itemname', 'n_itemrev')",catalog );

        status = SQLquery( select_str, &attr_buffer, MEM_SIZE );
        if( status != SQL_S_SUCCESS )
        {
   	    _NFMdebug(( fname, "Query <0x%.8x>\n", status ));
  	    MEMclose( &attr_buffer );
            ERRload_struct( NFM, NFM_E_SQL_QUERY, "", NULL );
  	    return( NFM_E_SQL_QUERY );
        }
  
        status = MEMbuild_array( attr_buffer );
        if( status != MEM_S_SUCCESS )
        {
            MEMclose( &attr_buffer );
            ERRload_struct( NFM, NFM_E_MEM, "", NULL );
            _NFMdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
            return( NFM_E_MEM );
        }
  
        attr = (char **)attr_buffer->data_ptr;
        tot_data = attr_buffer->rows*attr_buffer->columns;

        status = MEMopen( syn_list, MEM_SIZE );
        if( status != MEM_S_SUCCESS )
        {
  	    MEMclose( &attr_buffer );
 	    ERRload_struct( NFM, NFM_E_MEM, "", NULL );
	    _NFMdebug(( fname, "MEMopen <0x%.8x>\n", status ));
    	    return( NFM_E_MEM );
        }
  
        sprintf( fmt, "char(%d)", NFM_SYNONYM );
        status = MEMwrite_format( *syn_list, "name", fmt );
        if( status != MEM_S_SUCCESS )
        {
            MEMclose( &attr_buffer );
  	    MEMclose( syn_list );
            ERRload_struct( NFM, NFM_E_MEM, "", NULL );
            _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
            return( NFM_E_MEM );
        }

        /*  Build synonym buffer */

        for( i=0; i<tot_data; i+=attr_buffer->columns)
        {
            strcpy( str, attr[i] );
            strcat( str, "\1" );
            status = MEMwrite( *syn_list, str );
            if( status != MEM_S_SUCCESS )
            {
                MEMclose( &attr_buffer );
                MEMclose( syn_list );
                ERRload_struct( NFM, NFM_E_MEM, "", NULL );
                _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
                return( NFM_E_MEM );
            }
        }
    }  /* end if SQLcursor[3] prepared */
    else
    {
	MEMclose( syn_list );
	*syn_list = NULL;
    }
    strcpy( from_str, " FROM " );
    strcat( from_str, catalog );
    strcat( from_str, " a " );

    strcpy( select_clause, "a.n_itemno, a.n_itemname, a.n_itemrev");
    if( strlen(search) > 0 )
    {
        search_info = 
		(struct NFMquery_info *)malloc(sizeof(struct NFMquery_info));
        status = _NFMretrieve_query ( search, search_info );
        if( status != NFM_S_SUCCESS )
        {
  	    _NFMdebug(( fname, "_NFMretrieve_query <0x%.8x>\n", status ));
            if( SQLcursor[3] )
                status = SQLquery_cursor3( "", data_list, MEM_SIZE, 0 );
	    return( status );
	}
	search_ptr = (char*)malloc( strlen(search_info->where_clause) + 100);
	strcpy( search_ptr, " WHERE " );
	strcat( search_ptr, search_info->where_clause );

        /* Now PAY ATTENTION !!  I need to figure out whether or
	 * not to do aliasing in the 'from' clause for an <f_catalog>.
	 * A function will be called that takes the 'from' clause and its
	 * results tell me the following :
	 	0 - catalog only; don't do anything else
	 	1 - f_catalog only; I need to join the <cat> and <f_cat>
		    in the where clause and alias the <f_cat> in the from
		    clause.
		2 - catalog and f_catalog; I need to alias the <f_cat>
		    in the 'from' clause.
	 */
	if( strlen( search_info->from_clause ) > 0 )
	{
	    _NFMdebug(( fname, "Calling _NFMcat_f_cat with <%s>\n",
				search_info->from_clause ));
	    status = _NFMcat_f_cat( search_info->from_clause, &fork );
	    _NFMdebug(( fname, "From_clause Case  <%d>\n", fork ));
	    if( fork == 1 )
	    {
		strcat( from_str, ", f_" );
		strcat( from_str, catalog );
		strcat( from_str, " f_a " );
		
		strcat( search_ptr, " AND (a.n_itemno = f_a.n_itemnum) " );
	    }
	    else if( fork == 2 )
	    {
		strcat( from_str, ", f_" );
		strcat( from_str, catalog );
		strcat( from_str, " f_a " );
	    }
	}
	NFMfree_query_struct( search_info );
    }
    else
    {
	search_ptr = (char*)malloc(2);
       	strcpy( search_ptr, "" );
    }

    if( strlen(sort) > 0 )
    {
        sort_info = 
		(struct NFMquery_info *)malloc(sizeof(struct NFMquery_info));
        status = _NFMretrieve_query ( sort, sort_info );
        if( status != NFM_S_SUCCESS )
        {
  	    _NFMdebug(( fname, "_NFMretrieve_query <0x%.8x>\n", status ));
            if( SQLcursor[3] )
                status = SQLquery_cursor3( "", data_list, MEM_SIZE, 0 );
	    return( status );
	}
        sort_ptr = (char*)malloc( strlen( sort_info->order_by_clause )+50 );
        strcpy( sort_ptr, " ORDER BY " );
	strcat( sort_ptr, sort_info->order_by_clause );
	NFMfree_query_struct( sort_info );
    }
    else
    {
	sort_ptr = (char*)malloc(100);
        strcpy( sort_ptr, " ORDER BY " );
        strcat( sort_ptr, "a.n_itemno" );
    }

    /* KT - 2/23/93 - If there is a f_catalog attribute in the WHERE clause,
                      use SELECT DISTINCT instead of SELECT */

    if (fork == 1)
        sprintf (select_str, "SELECT DISTINCT %s", select_clause);
    else
        sprintf (select_str, "SELECT %s", select_clause);

    _NFMdebug(( fname, "Select str <%s>\n", select_str ));
    _NFMdebug(( fname, "From str   <%s>\n", from_str ));
    _NFMdebug(( fname, "Search str  <%s>\n", sort_ptr ));
    _NFMdebug(( fname, "Sort str  <%s>\n", sort_ptr ));

    total_ptr = (char*)malloc( strlen(select_str) + strlen(from_str) + 
		strlen(search_ptr) + strlen(sort_ptr) + 10 );
    sprintf( total_ptr, "%s%s%s%s", select_str, from_str, search_ptr, 
			sort_ptr);

    _NFMdebug(( fname, "Full select str <%s>\n", total_ptr ));

    status = SQLquery_cursor3( total_ptr, data_list, BUFFER_SIZE, rows );
    if( status == SQL_I_NO_ROWS_FOUND )
    {
	MEMclose( &attr_buffer );
        MEMclose( syn_list );
        MEMclose( data_list );
	free( total_ptr );
	free( search_ptr );
        free( sort_ptr );
        ERRload_struct (NFM,  NFM_E_DISPLAY_ITEMS, "%s", catalog);
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_DISPLAY_ITEMS );
    }
    else if( status != SQL_S_SUCCESS && status != SQL_I_NO_MORE_DATA)
    {
	MEMclose( &attr_buffer );
	MEMclose( syn_list );
	MEMclose( data_list );
	free( total_ptr );
	free( search_ptr );
        free( sort_ptr );
        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_SQL_QUERY);
    }
    MEMclose( &attr_buffer );

    free( total_ptr );
    free( search_ptr );
    free( sort_ptr );

    if( status == SQL_I_NO_MORE_DATA )
	return( NFM_I_NO_MORE_BUFFERS );

    return( NFM_S_SUCCESS );
}
