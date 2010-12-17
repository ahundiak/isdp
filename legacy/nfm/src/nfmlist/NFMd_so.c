#include "machine.h"
#include <stdio.h>
#include "NFMapi.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "DEBUG.h"
#include "ERR.h"


long NFMdisplay_signoff_users( acl_name, search, sort, syn_list, data_list )

char   *acl_name;
char   *search;
char   *sort;
MEMptr *syn_list;
MEMptr *data_list;
{
    long   status;
    char   fmt[20];
    char   str[NFM_SYNONYM+3];
    char   select_str[1024];

    static char *fname = "NFMdisplay_signoff_users";

    _NFMdebug(( fname, "WF Name <%s>\n", acl_name ));
    _NFMdebug(( fname, "Search  <%s>\n", search ));
    _NFMdebug(( fname, "Sort    <%s>\n", sort ));

    if( strlen( acl_name ) == 0 )
    {
        ERRload_struct (NFM,  NFM_E_DISPLAY_SO_USERS, "%s", " " );
        return ( NFM_E_DISPLAY_SO_USERS );
    }

    status = MEMopen( syn_list, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	ERRload_struct( NFM, NFM_E_MEM, "", NULL );
	_NFMdebug(( fname, "MEMopen <0x%.8x>\n", status ));
 	return( NFM_E_MEM );
    }
  
    sprintf( fmt, "char(%d)", NFM_SYNONYM );
    status = MEMwrite_format( *syn_list, "name", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    strcpy( str, "State\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    strcpy( str, "User Name\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
     }
     strcpy( str, "Override Priv?\1" );
     status = MEMwrite( *syn_list, str );
     if( status != MEM_S_SUCCESS )
     {
         MEMclose( syn_list );
         ERRload_struct( NFM, NFM_E_MEM, "", NULL );
         _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
         return( NFM_E_MEM );
     }

    sprintf( select_str, "SELECT nfmstates.n_statename,nfmusers.n_username, nfmsignoffusers.n_override FROM nfmsignoffusers, nfmstates, nfmusers,nfmacls WHERE (nfmstates.n_stateno = nfmsignoffusers.n_stateno) AND (nfmusers.n_userno= nfmsignoffusers.n_userno) AND (nfmacls.n_aclname = '%s') AND (nfmacls.n_aclno =nfmsignoffusers.n_aclno)",acl_name );
    if( strlen(search) > 0 )
    {
        strcat( select_str, " AND (" );
        strcat( select_str, search );
        strcat( select_str, ")" );
    }
    if( strlen(sort) > 0 )
    {
        strcat( select_str, " ORDER BY " );
        strcat( select_str, sort );
    }
    else
        strcat( select_str, " ORDER BY nfmusers.n_username" );

    status = SQLquery( select_str, data_list, MEM_SIZE );
    if( status == SQL_I_NO_ROWS_FOUND )
    {
        MEMclose( syn_list );
        MEMclose( data_list );
        ERRload_struct (NFM,  NFM_E_DISPLAY_SO_USERS, "%s", acl_name );
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_DISPLAY_SO_USERS );
    }
    else if( status != SQL_S_SUCCESS )
    {
	MEMclose( syn_list );
	MEMclose( data_list );
        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_SQL_QUERY);
    }

    return( NFM_S_SUCCESS );
}

long NFMdisplay_so_history( catalog, item, rev, syn_list, data_list )

char   *catalog;
char   *item;
char   *rev;
MEMptr *syn_list;
MEMptr *data_list;
{
    long   status;
    long   user_id;
    long   catalog_no;
    long   item_no;
    char   fmt[20];
    char   str[NFM_SYNONYM+3];
    char   select_str[1024];
    static char *fname = "NFMdisplay_so_history";

    _NFMdebug(( fname, "Catalog    <%s>\n", catalog ));
    _NFMdebug(( fname, "Item       <%s>\n", item ));
    _NFMdebug(( fname, "Revision   <%s>\n", rev ));

    if( (strlen( catalog ) == 0 ) ||
	(strlen( item )    == 0 ) ||
	(strlen( rev )     == 0 ))
    {
        ERRload_struct (NFM,  NFM_E_DISPLAY_SO_HISTORY, "%s%s%s", " ", 
			" ", " " ); 
        return ( NFM_E_DISPLAY_SO_HISTORY );
    }

    status = NFMget_catalog_no (user_id, catalog, &catalog_no);
    if (status != NFM_S_SUCCESS)
    {
       _NFMdebug(( fname, "NFMget_catalog_no = <0x%.8x>\n", status));
       return (status);
    }

    status = NFMget_item_no (user_id, catalog, item, rev, &item_no);
    if (status != NFM_S_SUCCESS)
    {
       _NFMdebug(( fname, "NFMget_item_no = <0x%.8x>\n", status));
       return (status);
    }

    status = MEMopen( syn_list, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	ERRload_struct( NFM, NFM_E_MEM, "", NULL );
	_NFMdebug(( fname, "MEMopen <0x%.8x>\n", status ));
 	return( NFM_E_MEM );
    }
  
    sprintf( fmt, "char(%d)", NFM_SYNONYM );
    status = MEMwrite_format( *syn_list, "name", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    strcpy( str, "State\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    strcpy( str, "User Name\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    strcpy( str, "Signoff\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    strcpy( str, "Comment\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    sprintf( select_str, 
"SELECT nfmstates.n_statename,nfmusers.n_username, nfmsignoff.n_signoff,nfmsignoff.n_reason FROM nfmsignoff,nfmusers,nfmstates WHERE nfmusers.n_userno = nfmsignoff.n_userno AND nfmsignoff.n_catalogno = %ld AND nfmsignoff.n_itemno = %ld AND nfmsignoff.n_userno= nfmusers.n_userno AND nfmsignoff.n_history = 'Y' and nfmstates.n_stateno = nfmsignoff.n_stateno ORDER BY nfmusers.n_username",catalog_no,item_no);

    status = SQLquery( select_str, data_list, MEM_SIZE );
    if( status == SQL_I_NO_ROWS_FOUND )
    {
        MEMclose( syn_list );
        MEMclose( data_list );
        ERRload_struct (NFM,  NFM_E_DISPLAY_SO_HISTORY, "%s%s%s", 
			catalog, item, rev );
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_DISPLAY_SO_HISTORY );
    }
    else if( status != SQL_S_SUCCESS )
    {
	MEMclose( syn_list );
	MEMclose( data_list );
        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_SQL_QUERY);
    }

    return( NFM_S_SUCCESS );
}

long NFMdisplay_so_on_item( catalog, item, rev, syn_list, data_list )

char   *catalog;
char   *item;
char   *rev;
MEMptr *syn_list;
MEMptr *data_list;
{
    long   status;
    long   user_id;
    long   catalog_no;
    long   item_no;
    long   state_no;
    long   acl_no;
    long   offset1;
    long   i,y ;
    char   fmt[20];
    char   str[NFM_SYNONYM+3];
    char   select_str[1024];
    char   sec_query [512] ;
    char   **attr;
    char   **data1 ;
    char   **column ;
    MEMptr attr_buffer = NULL;
    MEMptr data_list1 = NULL ;

    static char *fname = "NFMdisplay_so_on_item";

    _NFMdebug(( fname, "Catalog    <%s>\n", catalog ));
    _NFMdebug(( fname, "Item       <%s>\n", item ));
    _NFMdebug(( fname, "Revision   <%s>\n", rev ));
    if( (strlen( catalog ) == 0 ) ||
	(strlen( item )    == 0 ) ||
	(strlen( rev )     == 0 ))
    {
        ERRload_struct (NFM,  NFM_E_DISPLAY_SO_HISTORY, "%s%s%s", " ", 
			" ", " " ); 
        return ( NFM_E_DISPLAY_SO_HISTORY );
    }

    status = NFMget_catalog_no (user_id, catalog, &catalog_no);
    if (status != NFM_S_SUCCESS)
    {
       _NFMdebug(( fname, "NFMget_catalog_no = <0x%.8x>\n", status));
       return (status);
    }

    status = NFMget_item_no (user_id, catalog, item, rev, &item_no);
    if (status != NFM_S_SUCCESS)
    {
       _NFMdebug(( fname, "NFMget_item_no = <0x%.8x>\n", status));
       return (status);
    }

    sprintf (select_str, 
"SELECT n_stateno, n_aclno FROM %s WHERE n_itemno = %ld", catalog, item_no) ;

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
    state_no = atol( attr[0] );
    acl_no   = atol( attr[1] );
    MEMclose( &attr_buffer );

    status = MEMopen( syn_list, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	ERRload_struct( NFM, NFM_E_MEM, "", NULL );
	_NFMdebug(( fname, "MEMopen <0x%.8x>\n", status ));
 	return( NFM_E_MEM );
    }
  
    sprintf( fmt, "char(%d)", NFM_SYNONYM );
    status = MEMwrite_format( *syn_list, "name", fmt );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    strcpy( str, "User Name\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    strcpy( str, "Signoff\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    strcpy( str, "Comment\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    strcpy( str, "Override Priv?\1" );
    status = MEMwrite( *syn_list, str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

/*** this query returns the users that have signed off ******/
    sprintf (sec_query, "nfmsignoff.n_catalogno = %ld and nfmsignoff.n_itemno = %ld and nfmsignoff.n_stateno = %ld and nfmsignoff.n_history != 'Y'",
	     catalog_no, item_no, state_no) ;

    sprintf( select_str, 
	    "SELECT distinct (nfmusers.n_username), nfmsignoff.n_signoff, nfmsignoff.n_reason, nfmsignoffusers.n_override FROM nfmsignoffusers , nfmusers,nfmsignoff  WHERE (%s) and nfmusers.n_userno = nfmsignoff.n_userno and nfmsignoff.n_userno = nfmsignoffusers.n_userno and nfmsignoff.n_stateno = nfmsignoffusers.n_stateno",
	    sec_query) ;

    status = SQLquery( select_str, data_list, MEM_SIZE );
    if(( status != SQL_S_SUCCESS ) && ( status != SQL_I_NO_ROWS_FOUND ))
    {
	MEMclose( syn_list );
	MEMclose( data_list );
        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_SQL_QUERY);
    }

/**** lists of users that have not signed off ******/
    if( status == SQL_I_NO_ROWS_FOUND )
      {
	sprintf( select_str, 
		"SELECT distinct (nfmusers.n_username), nfmsignoffusers.n_override FROM nfmsignoffusers , nfmusers WHERE nfmsignoffusers.n_aclno = %ld and nfmsignoffusers.n_stateno = %ld and nfmsignoffusers.n_userno = nfmusers.n_userno",
		acl_no, state_no) ;
      }
    else
      {
	sprintf( select_str, 
		"SELECT distinct (nfmusers.n_username), nfmsignoffusers.n_override FROM nfmsignoffusers , nfmusers,nfmsignoff WHERE nfmsignoffusers.n_aclno = %ld and nfmsignoffusers.n_stateno = %ld and nfmsignoffusers.n_userno not in (select n_userno from nfmsignoff where %s) and nfmsignoffusers.n_userno = nfmusers.n_userno",
		acl_no, state_no, sec_query) ;
      }
	
    status = SQLquery( select_str, &data_list1, MEM_SIZE );
    if(( status != SQL_S_SUCCESS ) & (status != SQL_I_NO_ROWS_FOUND ))
    {
	MEMclose( syn_list );
	MEMclose( data_list );
        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
        return ( NFM_E_SQL_QUERY);
    }

    status = MEMbuild_array (*data_list) ;
    if (status != MEM_S_SUCCESS)
      {
	_NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n", status));
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	return (NFM_E_MEM) ;
      }

    status = MEMbuild_array (data_list1) ;
    if (status != MEM_S_SUCCESS)
      {
	_NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n", status));
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	return (NFM_E_MEM) ;
      }

    column = (char **) (*data_list) -> column_ptr ;
    data1 = (char **) data_list1 -> data_ptr ;

    for (i=0; i<data_list1->rows; i++)
      {
	offset1 = i*data_list1->columns ;
	select_str [0] = 0 ;
	for (y=0; y<(*data_list)->columns; y++)
	  {
	    if (strcmp (column [y], "n_username")== 0)
	      {
		_NFMdebug ((fname, "username is %s\n", data1 [offset1])) ;
		strcat (select_str, data1 [offset1]) ;
	      }
	    else if (strcmp (column [y], "n_signoff") == 0)
	      {
	      }
	    else if (strcmp (column [y], "n_reason") == 0)
	      {
	      }
	    else if (strcmp (column [y], "n_override") == 0)
	      {
		strcat (select_str, data1[offset1+1]) ;
	      }
	    strcat (select_str, "\001") ;
	  }

	status = MEMwrite (*data_list, select_str) ;
	if (status != MEM_S_SUCCESS)
	  {
	    _NFMdebug ((fname, "MEMwrite : status = <0x%.8x>\n", status)) ;
	    ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	    return (NFM_E_MEM) ;
	  }
	status = MEMbuild_array (*data_list) ;
	if (status != MEM_S_SUCCESS)
	  {
	    _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
			status)) ;
	    ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	    return (NFM_E_MEM) ;
	  }
	column = (char **) (*data_list)->column_ptr ;
      }

    _NFMdebug ((fname, "SUCCESSFUL\n")) ;
    return( NFM_S_SUCCESS );
}
