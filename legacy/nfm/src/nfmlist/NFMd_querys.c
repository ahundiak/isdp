#include "machine.h"
#include <stdio.h>
#include "NFMapi.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "DEBUG.h"
#include "ERR.h"


long NFMdisplay_querys( query_type, search, sort, type, syn_list, data_list )

char   *query_type;
char   *search;
char   *sort;
int    type;
MEMptr *syn_list;
MEMptr *data_list;
{
    long   status;
    long   NFMdisplay_querys_short();
    char   fmt[20];
    char   str[NFM_SYNONYM+3];
    char   select_str[1024];

    static char *fname = "NFMdisplay_querys";

    _NFMdebug(( fname, "Query Type  <%s>\n", query_type ));
    _NFMdebug(( fname, "Type  <%d>\n", type ));
    _NFMdebug(( fname, "Search <%s>\n", search ));
    _NFMdebug(( fname, "Sort  <%s>\n", sort ));

    if( type == NFM_SHORT_DISPLAY )
    {
        status = NFMdisplay_querys_short(query_type, search, sort, 
			syn_list, data_list );
        return( status );
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

	strcpy( str, "Criteria Name\1" );
        status = MEMwrite( *syn_list, str );
        if( status != MEM_S_SUCCESS )
        {
  	    MEMclose( syn_list );
            ERRload_struct( NFM, NFM_E_MEM, "", NULL );
            _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
            return( NFM_E_MEM );
        }
        strcpy( str, "Description\1" );
        status = MEMwrite( *syn_list, str );
        if( status != MEM_S_SUCCESS )
        {
            MEMclose( syn_list );
            ERRload_struct( NFM, NFM_E_MEM, "", NULL );
            _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
            return( NFM_E_MEM );
        }
        strcpy( str, "Application\1" );
        status = MEMwrite( *syn_list, str );
        if( status != MEM_S_SUCCESS )
        {
            MEMclose( syn_list );
            ERRload_struct( NFM, NFM_E_MEM, "", NULL );
            _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
            return( NFM_E_MEM );
        }
        strcpy( str, "Type\1" );
        status = MEMwrite( *syn_list, str );
        if( status != MEM_S_SUCCESS )
        {
            MEMclose( syn_list );
            ERRload_struct( NFM, NFM_E_MEM, "", NULL );
            _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
            return( NFM_E_MEM );
        }
        strcpy( str, "Table Type\1" );
        status = MEMwrite( *syn_list, str );
        if( status != MEM_S_SUCCESS )
        {
            MEMclose( syn_list );
            ERRload_struct( NFM, NFM_E_MEM, "", NULL );
            _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
            return( NFM_E_MEM );
        }
        strcpy( str, "Owner\1" );
        status = MEMwrite( *syn_list, str );
        if( status != MEM_S_SUCCESS )
        {
            MEMclose( syn_list );
            ERRload_struct( NFM, NFM_E_MEM, "", NULL );
            _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
            return( NFM_E_MEM );
        }
    sprintf( select_str, "SELECT nfmreports.n_reportname,nfmreports.n_reportdesc,nfmreports.n_application,nfmreports.n_apptype,nfmreports.n_tabletype,nfmusers.n_username FROM nfmreports, nfmusers WHERE (nfmreports.n_owner = nfmusers.n_userno) AND (nfmreports.n_type = '%s')", query_type);
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
        strcat( select_str, " ORDER BY nfmreports.n_reportname" );

    status = SQLquery( select_str, data_list, MEM_SIZE );
    if( status == SQL_I_NO_ROWS_FOUND )
    {
        MEMclose( syn_list );
        MEMclose( data_list );
	if( strcmp( query_type, "W" ) == 0 )
	{
            ERRload_struct (NFM,  NFM_E_DISPLAY_SEARCHES, "", NULL);
            _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
            return ( NFM_E_DISPLAY_SEARCHES );
	}
	else if( strcmp( query_type, "O" ) == 0 )
	{
            ERRload_struct (NFM,  NFM_E_DISPLAY_SORTS, "", NULL);
            _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
            return ( NFM_E_DISPLAY_SORTS );
	}
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

long NFMdisplay_querys_short( query_type, search, sort, syn_list, data_list )

char   *query_type;
char   *search;
char   *sort;
MEMptr *syn_list;
MEMptr *data_list;
{
    long   status;
    char   fmt[20];
    char   select_str[1024];

    static char *fname = "NFMdisplay_querys_short";

    _NFMdebug(( fname, "Search <%s>\n", search ));
    _NFMdebug(( fname, "Sort   <%s>\n", sort ));

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

    /*  Build synonym buffer */

    strcpy( select_str, "Query Number\1" );
    status = MEMwrite( *syn_list, select_str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    strcpy( select_str, "Query Name\1");
    status = MEMwrite( *syn_list, select_str );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( syn_list );
        ERRload_struct( NFM, NFM_E_MEM, "", NULL );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    sprintf( select_str, "SELECT n_reportno, n_reportname FROM nfmreports WHERE n_type = '%s'", query_type);
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
    status = SQLquery( select_str, data_list, MEM_SIZE );
    if( status == SQL_I_NO_ROWS_FOUND )
    {
        MEMclose( syn_list );
        MEMclose( data_list );
	if( strcmp( query_type, "W" ) == 0 )
	{
            ERRload_struct (NFM,  NFM_E_DISPLAY_SEARCHES, "", NULL);
            _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
            return ( NFM_E_DISPLAY_SEARCHES );
	}
	else if( strcmp( query_type, "O" ) == 0 )
	{
            ERRload_struct (NFM,  NFM_E_DISPLAY_SORTS, "", NULL);
            _NFMdebug(( fname, "Query Status = <0x%.8x>\n", status));
            return ( NFM_E_DISPLAY_SORTS );
	}
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
