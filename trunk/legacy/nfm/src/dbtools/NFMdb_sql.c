#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"

#define  CURSOR_ONE	     1
#define  CURSOR_TWO          2
#define  CURSOR_THREE        3
#define  CURSOR_FOUR         4
#define  CURSOR_FIVE         5
#define  CURSOR_SIX          6
#define  CURSOR_SEVEN        7
#define  CURSOR_EIGHT        8
#define  CURSOR_NINE         9 
#define  CURSOR_TEN          10
#define  CURSOR_ELEVEN       11
#define  CURSOR_TWELVE       12
#define  CURSOR_THIRTEEN     13
#define  CURSOR_FOURTEEN     14
#define  CURSOR_FIFTEEN      15
#define  CURSOR_SIXTEEN      16
#define  CURSOR_SEVENTEEN    17
#define  CURSOR_EIGHTEEN     18
#define  CURSOR_NINETEEN     19
#define  CURSOR_TWENTY       20
#define  CURSOR_TWENTY_ONE   21
#define  CURSOR_TWENTY_TWO   22
#define  CURSOR_TWENTY_THREE 23
#define  CURSOR_TWENTY_FOUR  24
#define  CURSOR_TWENTY_FIVE  25
#define  CURSOR_TWENTY_SIX   26
#define  CURSOR_TWENTY_SEVEN 27
#define  CURSOR_TWENTY_EIGHT 28
#define  CURSOR_TWENTY_NINE  29
#define  CURSOR_THIRTY       30
#define  CURSOR_THIRTY_ONE   31
#define  CURSOR_THIRTY_TWO   32
#define  CURSOR_THIRTY_THREE 33
#define  CURSOR_THIRTY_FOUR  34
#define  CURSOR_THIRTY_FIVE  35
#define  CURSOR_THIRTY_SIX   36
#define  CURSOR_THIRTY_SEVEN 37
#define  CURSOR_THIRTY_EIGHT 38
#define  CURSOR_THIRTY_NINE  39
#define  CURSOR_FORTY        40

/*
 Doc: NFMsqlquery

 Abstract:
     This function queries the database using the input SQL query string.

 */

long NFMsqlquery ( sql_string, buffer_size, data_list )
    char   *sql_string;
    char   *buffer_size;
    MEMptr *data_list;
{
    long   status;
    long   bsize;

    static char *fname = "NFMsqlquery";

    _NFMdebug ((fname, "Sql String = <%s>\n", sql_string ));
    _NFMdebug ((fname, "Buffer Size = <%s>\n", buffer_size ));
    
    bsize  = atol( buffer_size );
    status = SQLquery( sql_string, data_list, bsize );
    if( status != SQL_S_SUCCESS )
    {
        _NFMdebug ((fname, "SQLquery = <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_SQL_QUERY, NULL, NULL );
	MEMclose( data_list );
	return( NFM_E_SQL_QUERY );
    }

    _NFMdebug ((fname, "SUCCESSFUL : <0x%.8x>\n", NFM_S_SUCCESS ));

    return( NFM_S_SUCCESS );
}

long NFMsqlquery_cursor ( sql_string, buffer_size, rows, cursor, data_list )
    char   *sql_string;
    char   *buffer_size;
    long   rows;
    int    cursor;
    MEMptr *data_list;
{
    int    turn_autocommit_on = 0;
    long   status;
    long   bsize;
    
    static char *fname = "NFMsqlquery_cursor";

    _NFMdebug ((fname, "Sql String = <%s>\n", sql_string ));
    _NFMdebug ((fname, "Buffer Size = <%s>\n", buffer_size ));
    _NFMdebug ((fname, "Rows Requested = <%ld>\n", rows ));
    _NFMdebug ((fname, "Cursor = <%d>\n", cursor ));
    

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

    bsize  = atol( buffer_size );

    switch( cursor )
    {
	case  CURSOR_ONE :
	    status = SQLquery( sql_string, data_list, bsize);
	    break;
	
        case  CURSOR_TWO :
            status = SQLquery_cursor2( sql_string, data_list, bsize, rows);
            break;

        case  CURSOR_THREE :
            status = SQLquery_cursor3( sql_string, data_list, bsize, rows);
            break;

        case  CURSOR_FOUR :
            status = SQLquery_cursor4( sql_string, data_list, bsize, rows);
            break;

        case  CURSOR_FIVE :
            status = SQLquery_cursor5( sql_string, data_list, bsize, rows);
            break;

        case  CURSOR_SIX :
            status = SQLquery_cursor6( sql_string, data_list, bsize, rows);
            break;

        case  CURSOR_SEVEN :
            status = SQLquery_cursor7( sql_string, data_list, bsize, rows);
            break;

        case  CURSOR_EIGHT :
            status = SQLquery_cursor8( sql_string, data_list, bsize, rows);
            break;

        case  CURSOR_NINE :
            status = SQLquery_cursor9( sql_string, data_list, bsize, rows);
	    break;

        case  CURSOR_TEN :
            status = SQLquery_cursor10( sql_string, data_list, bsize, rows);
            break;

        case  CURSOR_ELEVEN :
            status = SQLquery_cursor11( sql_string, data_list, bsize, rows);
            break;

        case  CURSOR_TWELVE :
            status = SQLquery_cursor12( sql_string, data_list, bsize, rows);
            break;

        case  CURSOR_THIRTEEN :
            status = SQLquery_cursor13( sql_string, data_list, bsize, rows);
            break;

        case  CURSOR_FOURTEEN :
            status = SQLquery_cursor14( sql_string, data_list, bsize, rows);
            break;

        case  CURSOR_FIFTEEN :
            status = SQLquery_cursor15( sql_string, data_list, bsize, rows);
            break;

        case  CURSOR_SIXTEEN :
            status = SQLquery_cursor16( sql_string, data_list, bsize, rows);
            break;

        case  CURSOR_SEVENTEEN :
            status = SQLquery_cursor17( sql_string, data_list, bsize, rows);
            break;

        case  CURSOR_EIGHTEEN :
            status = SQLquery_cursor18( sql_string, data_list, bsize, rows);
            break;

        case  CURSOR_NINETEEN :
            status = SQLquery_cursor19( sql_string, data_list, bsize, rows);
            break;

        case  CURSOR_TWENTY :
            status = SQLquery_cursor20( sql_string, data_list, bsize, rows);
            break;

        case  CURSOR_TWENTY_ONE :
            status = SQLquery_cursor21( sql_string, data_list, bsize, rows);
            break;

        case  CURSOR_TWENTY_TWO :
            status = SQLquery_cursor22( sql_string, data_list, bsize, rows);
            break;

        case  CURSOR_TWENTY_THREE :
            status = SQLquery_cursor23( sql_string, data_list, bsize, rows);
            break;

        case  CURSOR_TWENTY_FOUR :
            status = SQLquery_cursor24( sql_string, data_list, bsize, rows);
            break;

        case  CURSOR_TWENTY_FIVE :
            status = SQLquery_cursor25( sql_string, data_list, bsize, rows);
            break;

        case  CURSOR_TWENTY_SIX :
            status = SQLquery_cursor26( sql_string, data_list, bsize, rows);
            break;

        case  CURSOR_TWENTY_SEVEN :
            status = SQLquery_cursor27( sql_string, data_list, bsize, rows);
            break;

        case  CURSOR_TWENTY_EIGHT :
            status = SQLquery_cursor28( sql_string, data_list, bsize, rows);
            break;

        case  CURSOR_TWENTY_NINE :
            status = SQLquery_cursor29( sql_string, data_list, bsize, rows);
            break;

        case  CURSOR_THIRTY :
            status = SQLquery_cursor30( sql_string, data_list, bsize, rows);
            break;

        case  CURSOR_THIRTY_ONE :
            status = SQLquery_cursor31( sql_string, data_list, bsize, rows);
            break;

        case  CURSOR_THIRTY_TWO :
            status = SQLquery_cursor32( sql_string, data_list, bsize, rows);
            break;

        case  CURSOR_THIRTY_THREE :
            status = SQLquery_cursor33( sql_string, data_list, bsize, rows);
            break;

        case  CURSOR_THIRTY_FOUR :
            status = SQLquery_cursor34( sql_string, data_list, bsize, rows);
            break;

        case  CURSOR_THIRTY_FIVE :
            status = SQLquery_cursor35( sql_string, data_list, bsize, rows);
            break;

        case  CURSOR_THIRTY_SIX :
            status = SQLquery_cursor36( sql_string, data_list, bsize, rows);
            break;

        case  CURSOR_THIRTY_SEVEN :
            status = SQLquery_cursor37( sql_string, data_list, bsize, rows);
            break;

        case  CURSOR_THIRTY_EIGHT :
            status = SQLquery_cursor38( sql_string, data_list, bsize, rows);
            break;

        case  CURSOR_THIRTY_NINE :
            status = SQLquery_cursor39( sql_string, data_list, bsize, rows);
            break;

        case  CURSOR_FORTY :
            status = SQLquery_cursor40( sql_string, data_list, bsize, rows);
            break;

	default : 
	    status = SQLquery( sql_string, data_list, bsize );
	    break;
    }

    if( (status != SQL_S_SUCCESS) && (status != SQL_I_NO_MORE_DATA) )
    {
	MEMclose( data_list );
        _NFMdebug ((fname, "SQLquery_cursor%d = <0x%.8x>\n",cursor, status));
	ERRload_struct( NFM, NFM_E_SQL_QUERY, NULL, NULL );
	return( NFM_E_SQL_QUERY );
    }

    if( status == SQL_I_NO_MORE_DATA )
    {
	_NFMdebug(( fname, "%s\n", "Returning NFM_I_NO_MORE_BUFFERS" ));
	return( NFM_I_NO_MORE_BUFFERS );
    }

    _NFMdebug ((fname, "SUCCESSFUL : <0x%.8x>\n", NFM_S_SUCCESS ));

    return( NFM_S_SUCCESS );
}

/*
 Doc: NFMsqlstmt

 Abstract:
     This function accesses the database using the input SQL statement.
 */

long NFMsqlstmt ( sql_string, data_list )
    char   *sql_string;
    MEMptr *data_list;
{
    long   status;
    static char *fname = "NFMsqlstmt";

    _NFMdebug ((fname, "Sql String = <%s>\n", sql_string ));

    status = SQLstmt( sql_string );
    if( status != SQL_S_SUCCESS )
    {
        _NFMdebug ((fname, "SQLstmt = <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_SQL_STMT, NULL, NULL );
	return( NFM_E_SQL_STMT );
    }

/* Suggested by Melania for Duke Power for Autocommit ON */
    if (strcmp (sql_string, "SET TRANSACTION AUTOCOMMIT ON") == 0)
    {
     	NFMsetNFM_TRANSACTION(-1) ;
        _NFMdebug ((fname, "MELANIA : set to -1\n")); 
    } else if (strcmp (sql_string, "SET TRANSACTION AUTOCOMMIT OFF") == 0)
    {
	NFMsetNFM_TRANSACTION(0) ;
	_NFMdebug ((fname, "MELANIA : set to 0\n")) ;
    }
/* End - Suggested by Melania for Duke Power for Autocommit ON */

    _NFMdebug ((fname, "SUCCESSFUL : <0x%.8x>\n", NFM_S_SUCCESS));

    return( NFM_S_SUCCESS );
}
