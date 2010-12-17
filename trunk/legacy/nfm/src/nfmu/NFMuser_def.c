#include "machine.h"
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include "MEMstruct.h"
#include "NFMdb.h"
#include "NFMdef.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"
#include "NFMschema.h"
#include "NFMstruct.h"

extern struct NFMglobal_st NFMglobal;
/*
 Doc: NFMuser_defaults_*

 Abstract:
     These functions get/put user defaults from/into the nfmusers
     table. 

 History:
     Jill McCutcheon  November 14, 1990 - Creation

 */

long NFMuser_defaults_login_old ( user_id, data_list )
    long   user_id;
    MEMptr *data_list;
{
    long    status;

    char    sql_string[500];
    char    saname[NFM_SANAME+1];
    char    catalogname[NFM_CATALOGNAME+1];
    char    itemname[NFM_ITEMNAME+1];
    char    itemrev[NFM_ITEMREV+1];
    char    setcatname[NFM_CATALOGNAME+1];
    char    setitemname[NFM_ITEMNAME+1];
    char    setitemrev[NFM_ITEMREV+1];
    char    projectname[NFM_PROJECTNAME+1];
    char    searchname[NFM_REPORTNAME+1];
    char    sortname[NFM_REPORTNAME+1];

    char    **d_data;

    static  char *fname = "NFMuser_defaults_login_old";

    MEMptr  buff   = NULL;

    _NFMdebug((fname, "%s\n", "Entering ... " ));
    _NFMdebug((fname, "user_no <%ld>\n", NFMglobal.NFMuserno));

    sprintf( sql_string, "SELECT n_sano,n_catalogno,n_itemno,n_setcatno,n_setitemno,n_projectno,n_searchno,n_sortno  FROM nfmusers WHERE n_userno = %ld",
		NFMglobal.NFMuserno );
    status = SQLquery( sql_string, &buff, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
        _NFMdebug((fname,"SQLquery = <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_USER_DEFAULTS_LOGIN, NULL, NULL );
        MEMclose( &buff );
	return( NFM_E_USER_DEFAULTS_LOGIN );
    }

    MEMbuild_array( buff );
    d_data = (char**) buff->data_ptr;

/*  Now that we have user default information, pick out the default
 *  information we want, map the number to the name and build the
 *  return buffer.
 */
    status = MEMopen( data_list, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &buff );
        return( status );
    }

    status = MEMwrite_format( *data_list, "n_name", "char(60)" );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &buff );
        return( status );
    }
  
    if( strcmp( d_data[0], "" ) == 0 )
    {
        _NFMdebug((fname, "%s\n", "NO DEFAULT SA"));
	strcpy( saname, NFM_DEFAULT_NULL );
    }
    else
    {
        _NFMdebug((fname, " Storage Area Number <%s>\n", d_data[0] ));

        status = NFMj_query_name_or_num( "nfmstoragearea", "n_saname", 
			"n_sano", d_data[0], saname, 0 );
        if( status != NFM_S_SUCCESS )
        {
  	    MEMclose( &buff );
            MEMclose( data_list );
	    return( status );
        }
    _NFMdebug((fname, "sa_name <%s>\n", saname));
    }

    /*** CATALOG ***/
    if( strcmp( d_data[1], "" ) == 0 )
    {
        _NFMdebug((fname, "%s\n", "NO DEFAULT CATALOG"));
	strcpy( catalogname, NFM_DEFAULT_NULL );
    }
    else
    {
        _NFMdebug((fname, "catalog_no <%s>\n", d_data[1]));

        status = NFMj_query_name_or_num( "nfmtables","n_tablename",
			 "n_tableno", d_data[1], catalogname, 0 );
        if( status != NFM_S_SUCCESS )
        {
	    MEMclose( &buff );
            MEMclose( data_list );
	    return( status );
        }
        _NFMdebug((fname, "catalog_name <%s>\n",catalogname));
    }

    /***  ITEM_NAME, ITEM_REV ***/
    if( strcmp( d_data[2], "" ) == 0 )
    {
        _NFMdebug((fname, "%s\n", "NO DEFAULT ITEM"));
	strcpy( itemname, NFM_DEFAULT_NULL );
	strcpy( itemrev,  NFM_DEFAULT_NULL );
    }
    else
    {
        _NFMdebug((fname, "item_no <%s>\n", d_data[2] ));

        status = NFMj_query_name_or_num( catalogname, "n_itemname",
		"n_itemno", d_data[2], itemname, 0 );
        if( status != NFM_S_SUCCESS )
        {
  	    MEMclose( &buff );
            MEMclose( data_list );
	    return( status );
        }
        _NFMdebug((fname, " item_name <%s>", itemname ));

        status = NFMj_query_name_or_num( catalogname, "n_itemrev", "n_itemno",
			d_data[2], itemrev, 0 );
        if( status != NFM_S_SUCCESS )
        {
  	    MEMclose( &buff );
            MEMclose( data_list );
	    return( status );
        }
        _NFMdebug((fname, "item_rev <%s>\n", itemrev));
    }

    /*** SET CATALOG ***/
    if( strcmp( d_data[3], "" ) == 0 )
    {
        _NFMdebug((fname, "%s\n", "NO DEFAULT SET CAT"));
	strcpy( setcatname, NFM_DEFAULT_NULL );
    }
    else
    {
        _NFMdebug((fname, "setcatno <%s>\n", d_data[3] ));

        status = NFMj_query_name_or_num( "nfmtables", "n_tablename",
			 "n_tableno", d_data[3], setcatname, 0 );
        if( status != NFM_S_SUCCESS )
        {
	    MEMclose( &buff );
            MEMclose( data_list );
   	    return( status );
        }
        _NFMdebug((fname, "setcatname <%s>\n", setcatname));
     }

     /*** SET_ITEM_NAME, SET_ITEM_REV  ***/
     if( strcmp( d_data[4], "" ) == 0 )
     {
        _NFMdebug((fname, "%s\n", "NO DEFAULT SET ITEM"));
 	strcpy( setitemname, NFM_DEFAULT_NULL );
	strcpy( setitemrev,  NFM_DEFAULT_NULL );
     }
     else
     {
         _NFMdebug((fname, "setitem_no <%s>\n", d_data[4] ));

         status = NFMj_query_name_or_num( setcatname, "n_itemname",
		  "n_itemno", d_data[4], setitemname, 0 );
         if( status != NFM_S_SUCCESS )
         {
  	     MEMclose( &buff );
            MEMclose( data_list );
	    return( status );
        }
	_NFMdebug((fname, "set_name <%s>\n", setitemname));

        status = NFMj_query_name_or_num( setcatname, "n_itemrev", "n_itemno",
			d_data[4], setitemrev, 0 );
        if( status != NFM_S_SUCCESS )
        {
  	    MEMclose( &buff );
            MEMclose( data_list );
	    return( status );
        }
	    _NFMdebug((fname, "set_itemrev <%s>\n", setitemrev)); 
    }
    /*** PROJECT ***/
    if( strcmp( d_data[5], "" ) == 0 )
    {
        _NFMdebug((fname,"%s\n", "NO DEFAULT PROJECT"));
	strcpy( projectname, NFM_DEFAULT_NULL );
    }
    else
    {
        _NFMdebug((fname, "project_no <%s>\n", d_data[5]));

        status = NFMj_query_name_or_num( "nfmprojects", "n_projectname",
		 "n_projectno",	d_data[5], projectname, 0 );
        if( status != NFM_S_SUCCESS )
        {
  	    MEMclose( &buff );
            MEMclose( data_list );
  	    return( status );
        }
        _NFMdebug((fname, "project_name <%s>\n",projectname));
    }

    /***  SEARCH ***/
    if( strcmp( d_data[6], "" ) == 0 )
    {
        _NFMdebug((fname,"%s\n", "NO DEFAULT SEARCH"));
	strcpy( searchname, NFM_DEFAULT_NULL );
    }
    else
    {
        _NFMdebug((fname, "search_no <%s>\n", d_data[6]));

        status = NFMj_query_name_or_num( "nfmreports", "n_reportname",	
	   	 "n_reportno", d_data[6], searchname, 0 );
        if( status != NFM_S_SUCCESS )
        {
  	    MEMclose( &buff );
   	    MEMclose( data_list );
	    return( status );
        }
        _NFMdebug((fname, "search_name <%s>\n",searchname));
    }

    /*** SORT ***/
    if( strcmp( d_data[7], "" ) == 0 )
    {
        _NFMdebug((fname, "%s\n", "NO DEFAULT SORT"));
	strcpy( sortname, NFM_DEFAULT_NULL );
    }
    else
    {
        _NFMdebug((fname, "sort_no <%s>\n", d_data[7]));

        status = NFMj_query_name_or_num( "nfmreports", "n_reportname",
			"n_reportno", d_data[7], sortname, 0 );
        if( status != NFM_S_SUCCESS )
        {
	    MEMclose( &buff );
            MEMclose( data_list );
	    return( status );
	}
        _NFMdebug((fname, "sort_name <%s>\n",sortname));
    }
    MEMclose( &buff );
 
    /*  Now write all the information to the return_buffer */

    strcpy( sql_string, saname );
    strcat( sql_string, "\1" );
    status = MEMwrite( *data_list, sql_string );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( data_list );
	return( status );
    }

    strcpy( sql_string, catalogname );
    strcat( sql_string, "\1" );
    status = MEMwrite( *data_list, sql_string );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
	return( status );
    }

    strcpy( sql_string, itemname );
    strcat( sql_string, "\1" );
    status = MEMwrite( *data_list, sql_string );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
	return( status );
    }

    strcpy( sql_string, itemrev );
    strcat( sql_string, "\1" );
    status = MEMwrite( *data_list, sql_string );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
	return( status );
    }

    strcpy( sql_string, setcatname );
    strcat( sql_string, "\1" );
    status = MEMwrite( *data_list, sql_string );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
	return( status );
    }

    strcpy( sql_string, setitemname );
    strcat( sql_string, "\1" );
    status = MEMwrite( *data_list, sql_string );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
	return( status );
    }

    strcpy( sql_string, setitemrev );
    strcat( sql_string, "\1" );
    status = MEMwrite( *data_list, sql_string );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
	return( status );
    }

    strcpy( sql_string, projectname );
    strcat( sql_string, "\1" );
    status = MEMwrite( *data_list, sql_string );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
	return( status );
    }

    strcpy( sql_string, searchname );
    strcat( sql_string, "\1" );
    status = MEMwrite( *data_list, sql_string );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
	return( status );
    }

    strcpy( sql_string, sortname );
    strcat( sql_string, "\1" );
    status = MEMwrite( *data_list, sql_string );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
	return( status );
    }

    _NFMdebug((fname, "%s\n", "Exiting ..."));

    return( NFM_S_SUCCESS );
    
}

long NFMuser_defaults_logout ( user_id, data_list )
    long   user_id;
    MEMptr data_list;
{
    long    status;
 
    char    sql_string[500];
    char    sano[10];
    char    catalogno[10];
    char    itemno[10];
    char    setcatno[10];
    char    setitemno[10];
    char    projectno[10];
    char    searchno[10];
    char    sortno[10];
    char    user_no[10];
    char    **d_data;

    static  char *fname = "NFMuser_defaults_logout";

    _NFMdebug((fname, "%s\n", "Entering ..." ));   
    sprintf (user_no, "%ld", NFMglobal.NFMuserno);

    MEMbuild_array( data_list );
    d_data = (char**) data_list->data_ptr;

/*  Now update each value IFF there is a value; otherwise, the default 
 *  remains unchanged.
 */
    strcpy( sql_string, "UPDATE nfmusers SET ");

/*  Get Storage Area number 
 */
    strcpy( sano, "null" );
    if( strcmp( d_data[0], NFM_DEFAULT_NULL ) )
    {
        status = NFMj_query_name_or_num( "nfmstoragearea", "n_sano", 
		"n_saname", d_data[0], sano, 1 );
        if( status != NFM_S_SUCCESS )
  	    return( status );
    }
    strcat( sql_string, "n_sano = " );
    strcat( sql_string, sano );
    strcat( sql_string, ", " );

    _NFMdebug((fname,"sa_no <%s>\n", sano ));

/*  Get Catalog Number 
 */
    strcpy( catalogno, "null" );
    if( strcmp( d_data[1], NFM_DEFAULT_NULL ) )
    {
        status = NFMj_query_name_or_num( "nfmtables", "n_tableno",
		    "n_tablename", d_data[1], catalogno, 1 );
        if( status != NFM_S_SUCCESS )
        {
	    _NFMdebug((fname,"Qry Name : status <0x%.8x>\n", status));
	    return( status );
        }
    }
    strcat( sql_string, "n_catalogno = ");
    strcat( sql_string, catalogno );
    strcat( sql_string, ", " );

    _NFMdebug((fname,"catalog_no <%s>\n", catalogno ));

/*  Get Item Number 
 */
    strcpy( itemno, "null" );
    if( ( strcmp( d_data[1], NFM_DEFAULT_NULL ) ) && 
        ( strcmp( d_data[2], NFM_DEFAULT_NULL ) ) && 
	( strcmp( d_data[3], NFM_DEFAULT_NULL ) ) )
    {
        status = NFMj_query_one_AND( d_data[1], "n_itemno", "n_itemname",
		 "n_itemrev", d_data[2], d_data[3], itemno );
        if( status != NFM_S_SUCCESS )
        {
	    _NFMdebug(( fname,"Qry Name : status <0x%.8x>\n",status));
	    return( status );
        }
    }

    strcat( sql_string, "n_itemno = ");
    strcat( sql_string, itemno );
    strcat( sql_string, ", " );

    _NFMdebug((fname,"item_no <%s>\n", itemno));

/*** Get Set Catalog Number ***/
    strcpy( setcatno, "null" );
    if( strcmp( d_data[4], NFM_DEFAULT_NULL ) )
    {
        status = NFMj_query_name_or_num( "nfmtables", "n_tableno",
		"n_tablename", d_data[4], setcatno, 1 );
        if( status != NFM_S_SUCCESS )
        {
	    _NFMdebug(( fname,"Qry Name : status <0x%.8x>\n", status));
  	    return( status );
        }
    }
    strcat( sql_string, "n_setcatno = ");
    strcat( sql_string, setcatno );
    strcat( sql_string, ", " );

    _NFMdebug((fname,"setcat_no <%s>\n", setcatno));

/*  Get Set Item Number
 */
    strcpy( setitemno, "null" );
    if( ( strcmp( d_data[4], NFM_DEFAULT_NULL ) ) && 
        ( strcmp( d_data[5], NFM_DEFAULT_NULL ) ) && 
	( strcmp( d_data[6], NFM_DEFAULT_NULL ) ) )
    {
        status = NFMj_query_one_AND( d_data[4], "n_itemno", "n_itemname", 
		"n_itemrev", d_data[5], d_data[6], setitemno );
        if( status != NFM_S_SUCCESS )
        {
	    _NFMdebug(( fname,"Qry Name : status <0x%.8x>\n", status));
  	    return( status );
        }
    } 

    strcat( sql_string, "n_setitemno = ");
    strcat( sql_string, setitemno );
    strcat( sql_string, ", " );

    _NFMdebug((fname,"set_item_no <%s>\n", setitemno));

/*  Get Project Number 
 */
    strcpy( projectno, "null" );
    if( strcmp( d_data[7], NFM_DEFAULT_NULL ) )
    {
        status = NFMj_query_name_or_num( "nfmprojects", "n_projectno", 
		"n_projectname", d_data[7], projectno, 1 );
        if( status != NFM_S_SUCCESS )
        {
	    _NFMdebug(( fname,"Qry Name : status <0x%.8x>\n", status));
  	    return( status );
        }
    }

    strcat( sql_string, "n_projectno = ");
    strcat( sql_string, projectno );
    strcat( sql_string, ", " );

    _NFMdebug((fname,"project_no <%s>\n", projectno));

    strcpy( searchno, "null" );
    if( strcmp( d_data[8], NFM_DEFAULT_NULL ) )
    {
        status = NFMj_query_name_or_num( "nfmreports", "n_reportno",
                 "n_reportname", d_data[8], searchno, 1 );
        if( status != NFM_S_SUCCESS )
        {
	    _NFMdebug(( fname,"Qry Name : status <0x%.8x>\n", status));
  	    return( status );
        }
    }

    strcat( sql_string, "n_searchno = ");
    strcat( sql_string, searchno );
    strcat( sql_string, ", " );

    _NFMdebug((fname,"search_no <%s>\n", searchno));

/*  Get Sort Number 
 */
    strcpy( sortno, "null" );
    if( strcmp( d_data[9], NFM_DEFAULT_NULL ) )
    {
        status = NFMj_query_name_or_num( "nfmreports", "n_reportno", 
		"n_reportname", d_data[9], sortno, 1 );
        if( status != NFM_S_SUCCESS )
        {
	    _NFMdebug(( fname,"Qry Name : status <0x%.8x>\n", status));
  	    return( status );
        }
    }

    strcat( sql_string, "n_sortno = ");
    strcat( sql_string, sortno );

    _NFMdebug((fname,"sort_no <%s>\n", sortno));

    strcat( sql_string, " WHERE n_userno = " );
    strcat( sql_string, user_no );

    status = SQLstmt( sql_string );
    if (status != SQL_S_SUCCESS)
    {
        _NFMdebug((fname,"SQLquery = <0x%.8x>\n", status)); 
        return (status);         
    }

    _NFMdebug((fname,"%s\n", "Exiting ..." ));

    return( NFM_S_SUCCESS );
}


NFMj_query_name_or_num( table_name, attr1, attr2, val2, val1, flag )
    /*  Routine to build a query as follows :
     *  <SELECT 'attr1' from 'table_name' where 'attr2' = 'val2'>
     *  'val1' is query result
     */
    char *table_name;	/* i - table to query */
    char *attr1; 	/* i - see above */
    char *attr2;	/* i - see above */
    char *val2;	        /* i - see above */
    char *val1;	        /* o - see above */
    int  flag;		/* 0 if integer, 1 if char */
{
    long   status;

    char   sql_string[500];
    static char *fname = "NFMquery_name_or_num";
    char   **data;

    MEMptr buffer   = NULL;

    _NFMdebug(( fname, "%s\n", "Entering ..." ));
    if( flag )
	sprintf( sql_string, "SELECT %s FROM %s WHERE %s = '%s'",
	         attr1, table_name, attr2, val2 );
    else
	sprintf( sql_string, "SELECT %s FROM %s WHERE %s = %s",
	         attr1, table_name, attr2, val2 );
    status = SQLquery( sql_string, &buffer, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
        _NFMdebug((fname, "SQLquery = <0x%.8x>\n", status));
        MEMclose (&buffer);
        ERRload_struct( NFM, NFM_E_MAP_NAMES_AND_NOS, NULL, NULL );
        return( NFM_E_MAP_NAMES_AND_NOS );
    }
    MEMbuild_array( buffer );
    data = (char**) buffer->data_ptr;
    strcpy( val1, data[0] );

    MEMclose( &buffer );

    _NFMdebug((fname, "%s\n", "Exiting ..." ));
    return( NFM_S_SUCCESS );
}

NFMj_query_one_AND( table_name, attr1, attr2, attr3, val2, val3,
		         val1 )
    /*  Routine to build a query as follows :
     *  <SELECT 'attr1' from 'table_name' where 'attr2' = 'val2' AND
     *  'attr3' = 'val3'>
     *  'val1' is query result
     */
    char *table_name;	/* i - table to query */
    char *attr1; 	/* i - see above */
    char *attr2;	/* i - see above */
    char *attr3;	/* i - see above */
    char *val2;		/* i - see above */
    char *val3;		/* i - see above */
    char *val1;	        /* o - see above */
{
    long   status;

    char   sql_string[500];
    static char *fname = "NFMj_query_one_AND";
    char   **data;

    MEMptr buffer   = NULL;

    _NFMdebug((fname, "%s\n", "Entering ..." ));

    sprintf( sql_string, "SELECT %s FROM %s WHERE %s = '%s' AND %s = '%s'",
	         attr1, table_name, attr2, val2, attr3, val3 );
    status = SQLquery( sql_string, &buffer, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
        _NFMdebug((fname, "SQLquery = <0x%.8x>\n", status));
        MEMclose (&buffer);
        ERRload_struct( NFM, NFM_E_MAP_NAMES_AND_NOS, NULL, NULL );
        return( NFM_E_MAP_NAMES_AND_NOS );
    }
    MEMbuild_array( buffer );
    data = (char**) buffer->data_ptr;
    strcpy( val1, data[0] );

    MEMclose( &buffer );

    _NFMdebug((fname, "%s\n", "Exiting ..." ));

    return( NFM_S_SUCCESS );
}

NFMj_query_two( table_name, attr1, attr2, attr3, val3, val1, val2, flag )
    /*  Routine to build a query as follows :
     *  <SELECT 'attr1','attr2' from 'table_name' where 'attr3' = val3
     *  'val1' and 'val2' is query result
     */
    char *table_name;	/* i - table to query */
    char *attr1; 	/* i - see above */
    char *attr2;	/* i - see above */
    char *attr3;	/* i - see above */
    char *val1;		/* i - see above */
    char *val2;		/* o - see above */
    char *val3;		/* o - see above */
    int  flag;		/* i - 0 if attr3 is integer; 1 if char */
{
    long   status;

    char   sql_string[500];
    static char *fname = "NFMj_query_two";
    char   **data;

    MEMptr buffer   = NULL;

    _NFMdebug((fname, "%s\n", "Entering ..." ));

    if( flag )
        sprintf( sql_string, "SELECT %s,%s FROM %s WHERE %s = '%s'",
	         attr1, attr2, table_name, attr3, val3 );
    else
        sprintf( sql_string, "SELECT %s,%s FROM %s WHERE %s = %s",
	         attr1, attr2, table_name, attr3, val3 );

    status = SQLquery( sql_string, &buffer, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
        _NFMdebug((fname, "SQLquery = <0x%.8x>\n", status));
        MEMclose (&buffer);
        ERRload_struct( NFM, NFM_E_MAP_NAMES_AND_NOS, NULL, NULL );
        return( NFM_E_MAP_NAMES_AND_NOS );
    }
    MEMbuild_array( buffer );
    data = (char**) buffer->data_ptr;
    strcpy( val1, data[0] );
    strcpy( val2, data[1] );

    MEMclose( &buffer );

    _NFMdebug(( fname, "%s\n", "Exiting ... " ));

    return( NFM_S_SUCCESS );
}

/*
 Doc: NFMread_user_defaults

 Abstract:
     This function reads the user's defaults from a file in <env>/system.
     Note that no ERRload_structs are done because we don't want errors
     coming back if this routine has a problem - the user just won't
     have any defaults active.
 */

long NFMread_user_defaults( data_list )

    MEMptr *data_list;
{
    long    status;
    long    NFMread_defaults_file();

    char    path[NFM_PATHNAME+1];
    char    def_name[NFM_REPORTNAME+1];
    char    def_file[NFM_PATHNAME+NFM_REPORTNAME+2];    
    char    lock_file[NFM_PATHNAME+NFM_REPORTNAME+2];    
    char    sql_string[100];
    
    char    **d_data;

    struct  stat   fbuff;
    MEMptr  buff   = NULL;

    static  char *fname = "NFMread_user_defaults";

    strcpy( sql_string, "SELECT n_tableno FROM nfmtables WHERE n_tablename = 'nfmusers'" );
    status = SQLquery( sql_string, &buff, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
        _NFMdebug((fname,"SQLquery = <0x%.8x>\n", status));
        MEMclose( &buff );
	return( NFM_E_USER_DEFAULTS_LOGIN );
    }

    status = MEMbuild_array( buff );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &buff );
        _NFMdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    d_data = (char**) buff->data_ptr;

    /*  Generate the filename to read using the table number and the user
	number.
     */

    status = _NFMbuild_system_path( "nfmadmin", path );
    if( status != NFM_S_SUCCESS )
    {
	_NFMdebug(( fname, "_NFMbuild_system_path <0x%.8x>\n", status ));
	return( status );
    }

    _NFMdebug(( fname, "system path <%s>\n", path ));

    /* Check to see if there is a lock file for this user because
     * another process may be trying to write to this file, now.
     * If they are, it will lock up this read function.
     */
    sprintf( lock_file, "%s/%s_%d.LCK", path, d_data[0], NFMglobal.NFMuserno );
    _NFMdebug(( fname, "Lock file <%s>\n", lock_file ));
    
    /*  Does this lock file exist ?? */

    status = stat( lock_file, &fbuff);
    if( !status )      /* This means the file exists */
    {
	_NFMdebug(( fname, "%s\n", "Lock file exists - skip reading defaults" ));
	return( NFM_E_FAILURE );
    }

    status = NFMnew_file_name( 0, atoi(d_data[0]), NFMglobal.NFMuserno,
                               def_name );
    sprintf( def_file, "%s/%s", path, def_name );
    _NFMdebug(( fname, "defaults file <%s>\n", def_file ));
    MEMclose( &buff );
    
    /*  Does this defaults file exist AND larger than 0 ?? */

    status = stat( def_file, &fbuff);
    if( !status )      /* This means the file exists */
    {
        /*  Check that the size is larger than 0 because a zero length
         *  file is causing fopen to hang.
         */
	_NFMdebug(( fname, "Size of defaults file <%d>\n", fbuff.st_size  ));
        if( fbuff.st_size == 0 )
           return( NFM_E_FAILURE );
    }

    /* Try to read defaults file */
    status = NFMread_defaults_file( def_file, data_list );
    if( status != NFM_S_SUCCESS )
    {
	_NFMdebug(( fname, "NFMread_defaults_file <0x%.8x>\n", status ));
	return( status );	
    }

    return( NFM_S_SUCCESS );
}

long  NFMread_defaults_file( def_file, data_list )
    char   *def_file;
    MEMptr *data_list;
{
    long    status;

    int     i;

    char    ch;
    char    saname[NFM_SANAME+1];
    char    catalogname[NFM_CATALOGNAME+1];
    char    itemname[NFM_ITEMNAME+1];
    char    itemrev[NFM_ITEMREV+1];
    char    setcatname[NFM_CATALOGNAME+1];
    char    setitemname[NFM_ITEMNAME+1];
    char    setitemrev[NFM_ITEMREV+1];
    char    projectname[NFM_PROJECTNAME+1];
    char    searchname[NFM_REPORTNAME+1];
    char    sortname[NFM_REPORTNAME+1];
    char    wfname[NFM_WORKFLOWNAME+1];
    char    aclname[NFM_ACLNAME+1];
    char    nodename[NFM_NODENAME+1];
    char    waname[NFM_SANAME+1];
    char    username[NFM_USERNAME];

/*  Increased the lengh of sql_string from 100 to 200 to solve 
    TR #249407611 -- JGR-IGI-3 Feb 1995 */

    char    sql_string[200];

    char    **data;

    MEMptr  buffer = NULL;

    FILE    *fopen();
    FILE    *defaults;

    static char *fname = "NFMread_defaults_file";
     
    /*  Read the defaults file */
    if (! (defaults = fopen (def_file, "r")))
        return (NFM_E_OPEN_FILE);

    /*  Get storage area name */
    i = 0;
    while ((ch = fgetc (defaults)) != ':')
        i++;
    ch = fgetc (defaults);

    i=0;
    while ((ch = fgetc (defaults)) != '\n')
        saname[i++] = ch;
    saname[i] = '\0';
    _NFMdebug(( fname, "Storage Area Name <%s>\n", saname ));

    /*  Get catalog name */
    i = 0;
    while ((ch = fgetc (defaults)) != ':')
        i++;
    ch = fgetc (defaults);

    i=0;
    while ((ch = fgetc (defaults)) != '\n')
        catalogname[i++] = ch;
    catalogname[i] = '\0';
    _NFMdebug(( fname, "Catalog Name <%s>\n", catalogname ));

    /*  Get item name */
    i = 0;
    while ((ch = fgetc (defaults)) != ':')
        i++;
    ch = fgetc (defaults);

    i=0;
    while ((ch = fgetc (defaults)) != '\n')
        itemname[i++] = ch;
    itemname[i] = '\0';
    _NFMdebug(( fname, "Item Name <%s>\n", itemname ));

    /*  Get item rev */
    i = 0;
    while ((ch = fgetc (defaults)) != ':')
        i++;
    ch = fgetc (defaults);

    i=0;
    while ((ch = fgetc (defaults)) != '\n')
        itemrev[i++] = ch;
    itemrev[i] = '\0';
    _NFMdebug(( fname, "Item Rev <%s>\n", itemrev ));

    /*  Get set catalog */
    i = 0;
    while ((ch = fgetc (defaults)) != ':')
        i++;
    ch = fgetc (defaults);

    i=0;
    while ((ch = fgetc (defaults)) != '\n')
        setcatname[i++] = ch;
    setcatname[i] = '\0';
    _NFMdebug(( fname, "Set Catalog Name <%s>\n", setcatname ));

    /*  Get set name */
    i = 0;
    while ((ch = fgetc (defaults)) != ':')
        i++;
    ch = fgetc (defaults);

    i=0;
    while ((ch = fgetc (defaults)) != '\n')
        setitemname[i++] = ch;
    setitemname[i] = '\0';
    _NFMdebug(( fname, "Set Item Name <%s>\n", setitemname ));

    /*  Get set rev */
    i = 0;
    while ((ch = fgetc (defaults)) != ':')
        i++;
    ch = fgetc (defaults);

    i=0;
    while ((ch = fgetc (defaults)) != '\n')
        setitemrev[i++] = ch;
    setitemrev[i] = '\0';
    _NFMdebug(( fname, "Set Item Rev <%s>\n", setitemrev ));

    /*  Get project */
    i = 0;
    while ((ch = fgetc (defaults)) != ':')
        i++;
    ch = fgetc (defaults);

    i=0;
    while ((ch = fgetc (defaults)) != '\n')
        projectname[i++] = ch;
    projectname[i] = '\0';
    _NFMdebug(( fname, "Project Name <%s>\n", projectname ));

    /*  Get search */
    i = 0;
    while ((ch = fgetc (defaults)) != ':')
        i++;
    ch = fgetc (defaults);

    i=0;
    while ((ch = fgetc (defaults)) != '\n')
        searchname[i++] = ch;
    searchname[i] = '\0';
    _NFMdebug(( fname, "Search Name <%s>\n", searchname ));

    /*  Get sort */
    i = 0;
    while ((ch = fgetc (defaults)) != ':')
        i++;
    ch = fgetc (defaults);

    i=0;
    while ((ch = fgetc (defaults)) != '\n')
        sortname[i++] = ch;
    sortname[i] = '\0';
    _NFMdebug(( fname, "Sort Name <%s>\n", sortname ));

    /*  Get workflow */
    i = 0;
    while ((ch = fgetc (defaults)) != ':')
        i++;
    ch = fgetc (defaults);

    i=0;
    while ((ch = fgetc (defaults)) != '\n')
        wfname[i++] = ch;
    wfname[i] = '\0';
    _NFMdebug(( fname, "WF Name <%s>\n", wfname ));

    /*  Get acl */
    i = 0;
    while ((ch = fgetc (defaults)) != ':')
        i++;
    ch = fgetc (defaults);

    i=0;
    while ((ch = fgetc (defaults)) != '\n')
        aclname[i++] = ch;
    aclname[i] = '\0';
    _NFMdebug(( fname, "ACL Name <%s>\n", aclname ));

    /*  Get node */
    i = 0;
    while ((ch = fgetc (defaults)) != ':')
        i++;
    ch = fgetc (defaults);

    i=0;
    while ((ch = fgetc (defaults)) != '\n')
        nodename[i++] = ch;
    nodename[i] = '\0';
    _NFMdebug(( fname, "Node Name <%s>\n", nodename ));

    /*  Get working area */
    i = 0;
    while ((ch = fgetc (defaults)) != ':')
        i++;
    ch = fgetc (defaults);

    i=0;
    while ((ch = fgetc (defaults)) != '\n')
        waname[i++] = ch;
    waname[i] = '\0';
    _NFMdebug(( fname, "WA Name <%s>\n", waname ));

    /*  Get list option */
    i = 0;
    while ((ch = fgetc (defaults)) != ':')
        i++;
    ch = fgetc (defaults);

    i=0;
    while ((ch = fgetc (defaults)) != '\n')
        username[i++] = ch;
    username[i] = '\0';
    _NFMdebug(( fname, "User Name <%s>\n", username ));

    status = MEMopen( data_list, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	_NFMdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    status = MEMwrite_format( *data_list, "n_name", "char(60)" );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
	_NFMdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    /*  Now write all the information to the return_buffer */
   
    if( strlen(saname) > 0 )
    {
        sprintf( sql_string, "SELECT n_saname FROM nfmstoragearea WHERE n_saname = '%s'", saname );
	status = SQLquery( sql_string, &buffer, MEM_SIZE );
	if( status == SQL_I_NO_ROWS_FOUND )
	    strcpy( saname, "" );
        MEMclose( &buffer );
        buffer = NULL;
    }
    sprintf( sql_string, "%s\1", saname );
    status = MEMwrite( *data_list, sql_string );
    if( status != MEM_S_SUCCESS )
    {
        MEMclose( data_list );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    if( strlen(catalogname) > 0 )
    {
        sprintf( sql_string, "SELECT n_catalogname FROM nfmcatalogs WHERE n_catalogname = '%s'", catalogname );
        status = SQLquery( sql_string, &buffer, MEM_SIZE );
        if( status == SQL_I_NO_ROWS_FOUND )
            strcpy( catalogname, "" );
        MEMclose( &buffer );
        buffer = NULL;
    }
    sprintf( sql_string, "%s\1", catalogname );
    status = MEMwrite( *data_list, sql_string );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    if( (strlen(itemname) > 0) && (strlen(catalogname) > 0) )
    {
        sprintf( sql_string, "SELECT n_itemname FROM %s WHERE n_itemname = '%s'", catalogname, itemname );
        status = SQLquery( sql_string, &buffer, MEM_SIZE );
        if( status == SQL_I_NO_ROWS_FOUND )
	{
            strcpy( itemname, "" );
	    strcpy( itemrev, "" );
        }
        MEMclose( &buffer );
        buffer = NULL;
    }
    sprintf( sql_string, "%s\1", itemname );
    status = MEMwrite( *data_list, sql_string );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    if( (strlen(itemrev) > 0 ) && 
        (strlen(itemname) > 0) && 
	(strlen(catalogname) > 0) )
    {
        sprintf( sql_string, "SELECT n_itemrev FROM %s WHERE n_itemname = '%s' AND n_itemrev = '%s'", catalogname, itemname, itemrev );
        status = SQLquery( sql_string, &buffer, MEM_SIZE );
        if( status == SQL_I_NO_ROWS_FOUND )
            strcpy( itemrev, "" );
        MEMclose( &buffer );
        buffer = NULL;
    }
    sprintf( sql_string, "%s\1", itemrev );
    status = MEMwrite( *data_list, sql_string );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    if( strlen(setcatname) > 0 )
    {
        sprintf( sql_string, "SELECT n_catalogname FROM nfmcatalogs WHERE n_catalogname = '%s'", setcatname );
        status = SQLquery( sql_string, &buffer, MEM_SIZE );
        if( status == SQL_I_NO_ROWS_FOUND )
            strcpy( setcatname, "" );
        MEMclose( &buffer );
        buffer = NULL;
    }
    sprintf( sql_string, "%s\1", setcatname );
    status = MEMwrite( *data_list, sql_string );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }


    if( (strlen(setitemname) > 0) && (strlen(setcatname) > 0) )
    {
        sprintf( sql_string, "SELECT n_itemname FROM %s WHERE n_itemname = '%s'", setcatname, setitemname );
        status = SQLquery( sql_string, &buffer, MEM_SIZE );
        if( status == SQL_I_NO_ROWS_FOUND )
            strcpy( setitemname, "" );
        MEMclose( &buffer );
        buffer = NULL;
    }
    sprintf( sql_string, "%s\1", setitemname );
    status = MEMwrite( *data_list, sql_string );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    if( (strlen(setitemrev) > 0 ) && 
        (strlen(setitemname) > 0) && 
	(strlen(setcatname) > 0) )
    {
        sprintf( sql_string, "SELECT n_itemrev FROM %s WHERE n_itemname = '%s' AND n_itemrev = '%s'", setcatname, setitemname, setitemrev );
        status = SQLquery( sql_string, &buffer, MEM_SIZE );
        if( status == SQL_I_NO_ROWS_FOUND )
            strcpy( setitemrev, "" );
        MEMclose( &buffer );
        buffer = NULL;
    }
    sprintf( sql_string, "%s\1", setitemrev );
    status = MEMwrite( *data_list, sql_string );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    if( strlen(projectname) > 0 )
    {
        sprintf( sql_string, "SELECT n_projectname FROM nfmprojects WHERE n_projectname = '%s'", projectname );
	status = SQLquery( sql_string, &buffer, MEM_SIZE );
	if( status == SQL_I_NO_ROWS_FOUND )
	    strcpy( projectname, "" );
        MEMclose( &buffer );
        buffer = NULL;
    }
    sprintf( sql_string, "%s\1", projectname );
    status = MEMwrite( *data_list, sql_string );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    if( strlen(searchname) > 0 )
    {
        sprintf( sql_string, "SELECT n_reportname FROM nfmreports WHERE n_reportname = '%s'", searchname );
        status = SQLquery( sql_string, &buffer, MEM_SIZE );
        if( status == SQL_I_NO_ROWS_FOUND )
            strcpy( searchname, "" );
        MEMclose( &buffer );
        buffer = NULL;
    }
    sprintf( sql_string, "%s\1", searchname );
    status = MEMwrite( *data_list, sql_string );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    if( strlen(sortname) > 0 )
    {
        sprintf( sql_string, "SELECT n_reportname FROM nfmreports WHERE n_reportname = '%s'", sortname );
        status = SQLquery( sql_string, &buffer, MEM_SIZE );
        if( status == SQL_I_NO_ROWS_FOUND )
            strcpy( sortname, "" );
        MEMclose( &buffer );
        buffer = NULL;
    }
    sprintf( sql_string, "%s\1", sortname );
    status = MEMwrite( *data_list, sql_string );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    if( strlen(wfname) > 0 )
    {
        sprintf( sql_string, "SELECT n_workflowname FROM nfmworkflow WHERE n_workflowname = '%s'", wfname );
        status = SQLquery( sql_string, &buffer, MEM_SIZE );
        if( status == SQL_I_NO_ROWS_FOUND )
            strcpy( wfname, "" );
        MEMclose( &buffer );
        buffer = NULL;
    }
    sprintf( sql_string, "%s\1", wfname );
    status = MEMwrite( *data_list, sql_string );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    if( strlen(aclname) > 0 )
    {
        sprintf( sql_string, "SELECT n_aclname FROM nfmacls WHERE n_aclname = '%s'", aclname );
        status = SQLquery( sql_string, &buffer, MEM_SIZE );
        if( status == SQL_I_NO_ROWS_FOUND )
            strcpy( aclname, "" );
        MEMclose( &buffer );
        buffer = NULL;
    }
    sprintf( sql_string, "%s\1", aclname );
    status = MEMwrite( *data_list, sql_string );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    if( strlen(nodename) > 0 )
    {
       sprintf( sql_string, "SELECT n_nodename FROM nfmnodes WHERE n_nodename = '%s'", nodename );
        status = SQLquery( sql_string, &buffer, MEM_SIZE );
        if( status == SQL_I_NO_ROWS_FOUND )
            strcpy( nodename, "" );
        MEMclose( &buffer );
        buffer = NULL;
    }
    sprintf( sql_string, "%s\1", nodename );
    status = MEMwrite( *data_list, sql_string );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    if( strlen(waname) > 0 )
    {
        sprintf( sql_string, "SELECT n_saname FROM nfmstoragearea WHERE n_saname = '%s'", waname );
        status = SQLquery( sql_string, &buffer, MEM_SIZE );
        if( status == SQL_I_NO_ROWS_FOUND )
            strcpy( waname, "" );
        MEMclose( &buffer );
        buffer = NULL;
    }
    sprintf( sql_string, "%s\1", waname );
    status = MEMwrite( *data_list, sql_string );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    if( strlen(username) > 0 )
    {
        sprintf( sql_string, "SELECT n_username FROM nfmusers WHERE n_username = '%s'", username );
        status = SQLquery( sql_string, &buffer, MEM_SIZE );
        if( status == SQL_I_NO_ROWS_FOUND )
            strcpy( username, "" );
	MEMclose( &buffer );
	buffer = NULL;
    }
    sprintf( sql_string, "%s\1", username );
    status = MEMwrite( *data_list, sql_string );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( data_list );
        _NFMdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }

    fclose( defaults );

    _NFMdebug((fname, "%s\n", "Exiting ..."));

    return( NFM_S_SUCCESS );
    
}


/*
 Doc: NFMwrite_user_defaults

 Abstract:
     This function writes the user's defaults into a file in <env>/system.

 */

long NFMwrite_user_defaults( data_list )

    MEMptr  data_list;
{
    long    status;
    long    NFMwrite_defaults_file();

    char    path[NFM_PATHNAME+1];
    char    def_name[NFM_REPORTNAME+1];
    char    def_file[NFM_PATHNAME+NFM_REPORTNAME+2];    
    char    lock_file[NFM_PATHNAME+NFM_REPORTNAME+2];    
    char    sql_string[100];
    
    char    **d_data;

    FILE    *fopen();
    FILE    *locks;

    struct  stat fbuff;

    static  char *fname = "NFMwrite_user_defaults";

    MEMptr  buff   = NULL;

    strcpy( sql_string, "SELECT n_tableno FROM nfmtables WHERE n_tablename = 'nfmusers'" );
    status = SQLquery( sql_string, &buff, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
        _NFMdebug((fname,"SQLquery = <0x%.8x>\n", status));
        MEMclose( &buff );
	return( NFM_E_USER_DEFAULTS_LOGIN );
    }

    status = MEMbuild_array( buff );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &buff );
        _NFMdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    d_data = (char**) buff->data_ptr;

    /*  Generate the filename to write using the table number and the user
	number.
     */

    status = _NFMbuild_system_path( "nfmadmin", path );
    if( status != NFM_S_SUCCESS )
    {
	_NFMdebug(( fname, "_NFMbuild_system_path <0x%.8x>\n", status ));
	return( status );
    }

    _NFMdebug(( fname, "system path <%s>\n", path ));

    /* Check to see if there is a lock file for this user because
     * another process may be trying to write to this file now.
     * If they are, we won't try to write, too.
     */
    sprintf( lock_file, "%s/%s_%d.LCK", path, d_data[0], NFMglobal.NFMuserno );
    _NFMdebug(( fname, "Lock file <%s>\n", lock_file ));
    
    /*  Does this lock file exist ?? */

    status = stat( lock_file, &fbuff);
    if( !status )      /* This means the file exists */
    {
	_NFMdebug(( fname, "%s\n", "Lock file exists - skip writing defaults" ));
	return( NFM_E_FAILURE );
    }

    status = NFM_mkpath (lock_file, S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);
    if (status != NFM_S_SUCCESS)
    {
        /* failure creating query path */
        _NFMdebug ((fname, "NFM_mkpath: <0x%.8x>\n", status));
        ERRload_struct (NFM, status, NULL);
        return (status);
    }

    /*  Put the lock file out there until we are through writing the
     *  the defaults file.
     */

    locks = fopen( lock_file, "w" );
    if( !locks )
    {
	_NFMdebug(( fname,"%s\n", "Lock file can't be opened - Don't go on" ));
	return( NFM_E_FAILURE );
    }

    _NFMdebug(( fname, "%s\n", "Lock File IS OPEN" ));

    status = NFMnew_file_name( 0, atoi(d_data[0]), NFMglobal.NFMuserno,
                               def_name );
    sprintf( def_file, "%s/%s", path, def_name );
    _NFMdebug(( fname, "defaults file <%s>\n", def_file ));
    MEMclose( &buff );

    /* Try to write defaults file */
    status = NFMwrite_defaults_file( def_file, data_list );
    if( status != NFM_S_SUCCESS )
    {
	_NFMdebug(( fname, "NFMwrite_defaults_file <0x%.8x>\n", status ));
        fclose( locks );
	unlink( lock_file );
	return( status );	
    }

    fclose( locks );
    unlink( lock_file );

    return( NFM_S_SUCCESS );
}


long  NFMwrite_defaults_file( def_file, data_list )
    char   *def_file;
    MEMptr data_list;
{
    long    status;

    char    **d_data;

    FILE    *fopen ();
    FILE    *defaults;

    static  char *fname = "NFMwrite_defaults_file";

    status = MEMbuild_array( data_list );
    if( status != MEM_S_SUCCESS )
    {
	_NFMdebug(( fname, "MEMbuild_array <0x%.8x>\n", status ));
	return( NFM_E_MEM );
    }
    d_data = (char**) data_list->data_ptr;

    defaults = fopen (def_file, "w");
    if (!defaults)
    {
        _NFMdebug ((fname, "%s\n", "Error opening defaults file for write" ));
        return (NFM_E_OPEN_FILE);
    }

    /* write storage area */
    if (fputs ("STORAGE AREA : ", defaults) == EOF)
    {
        _NFMdebug ((fname, "%s\n", "Error writing storage area keyword" ));
        return (NFM_E_FPUTS_FAILURE);
    }

    /* only write if field is not NULL */
    if( strcmp( d_data[0], NFM_DEFAULT_NULL ) )
    {
        if (fputs (d_data[0], defaults) == EOF)
        {
        _NFMdebug ((fname, "%s\n", "Error writing storage area" ));
        return (NFM_E_FPUTS_FAILURE);
        }
    }

    if (fputs ("\n", defaults) == EOF)
    {
        _NFMdebug ((fname, "%s\n", "Error writing EOL" ));
        return (NFM_E_FPUTS_FAILURE);
    }

    /* write catalog */
    if (fputs ("CATALOG : ", defaults) == EOF)
    {
        _NFMdebug ((fname, "%s\n", "Error writing catalog keyword" ));
        return (NFM_E_FPUTS_FAILURE);

    }

    /* only write if field is not NULL */
    if( strcmp( d_data[1], NFM_DEFAULT_NULL ) )
    {
        if (fputs (d_data[1], defaults) == EOF)
        {
        _NFMdebug ((fname, "%s\n", "Error writing catalog" ));
        return (NFM_E_FPUTS_FAILURE);
        }
    }

    if (fputs ("\n", defaults) == EOF)
    {
        _NFMdebug ((fname, "%s\n", "Error writing EOL" ));
        return (NFM_E_FPUTS_FAILURE);
    }

    /* write item name */
    if (fputs ("ITEM : ", defaults) == EOF)
    {
        _NFMdebug ((fname, "%s\n", "Error writing item keyword" ));
        return (NFM_E_FPUTS_FAILURE);
    }

    /* only write if field is not NULL */
    if( strcmp( d_data[2], NFM_DEFAULT_NULL ) )
    {
        if (fputs (d_data[2], defaults) == EOF)
        {
        _NFMdebug ((fname, "%s\n", "Error writing itemname" ));
        return (NFM_E_FPUTS_FAILURE);
        }
    }

    if (fputs ("\n", defaults) == EOF)
    {
        _NFMdebug ((fname, "%s\n", "Error writing EOL" ));
        return (NFM_E_FPUTS_FAILURE);
    }

    /* write revision */
    if (fputs ("REVISION : ", defaults) == EOF)
    {
        _NFMdebug ((fname, "%s\n", "Error writing revision keyword" ));
        return (NFM_E_FPUTS_FAILURE);
    }

    /* only write if field is not NULL */
    if( strcmp( d_data[3], NFM_DEFAULT_NULL ) )
    {
        if (fputs (d_data[3], defaults) == EOF)
        {
        _NFMdebug ((fname, "%s\n", "Error writing revision" ));
        return (NFM_E_FPUTS_FAILURE);
        }
    }

    if (fputs ("\n", defaults) == EOF)
    {
        _NFMdebug ((fname, "%s\n", "Error writing EOL" ));
        return (NFM_E_FPUTS_FAILURE);
    }

    /* write set catalog */
    if (fputs ("SET CATALOG : ", defaults) == EOF)
    {
        _NFMdebug ((fname, "%s\n", "Error writing set catalog keyword" ));
        return (NFM_E_FPUTS_FAILURE);
    }

    /* only write if field is not NULL AND the set item name is not NULL */
    if( (strcmp( d_data[4], NFM_DEFAULT_NULL)) &&
	(strcmp( d_data[5], NFM_DEFAULT_NULL)))
    {
        if (fputs (d_data[4], defaults) == EOF)
        {
        _NFMdebug ((fname, "%s\n", "Error writing set catalog" ));
        return (NFM_E_FPUTS_FAILURE);
        }
    }

    if (fputs ("\n", defaults) == EOF)
    {
        _NFMdebug ((fname, "%s\n", "Error writing EOL" ));
        return (NFM_E_FPUTS_FAILURE);
    }

    /* write set item name */
    if (fputs ("SET ITEM : ", defaults) == EOF)
    {
        _NFMdebug ((fname, "%s\n", "Error writing set item keyword" ));
        return (NFM_E_FPUTS_FAILURE);
    }

    /* only write if field is not NULL */
    if( strcmp( d_data[5], NFM_DEFAULT_NULL ) )
    {
        if (fputs (d_data[5], defaults) == EOF)
        {
        _NFMdebug ((fname, "%s\n", "Error writing set item" ));
        return (NFM_E_FPUTS_FAILURE);
        }
    }

    if (fputs ("\n", defaults) == EOF)
    {
        _NFMdebug ((fname, "%s\n", "Error writing EOL" ));
        return (NFM_E_FPUTS_FAILURE);
    }

    /* write set revision */
    if (fputs ("SET REVISION : ", defaults) == EOF)
    {
        _NFMdebug ((fname, "%s\n", "Error writing set revision keyword" ));
        return (NFM_E_FPUTS_FAILURE);
    }

    /* only write if field is not NULL */
    if( strcmp( d_data[6], NFM_DEFAULT_NULL ) )
    {
        if (fputs (d_data[6], defaults) == EOF)
        {
        _NFMdebug ((fname, "%s\n", "Error writing set revision" ));
        return (NFM_E_FPUTS_FAILURE);
        }
    }

    if (fputs ("\n", defaults) == EOF)
    {
        _NFMdebug ((fname, "%s\n", "Error writing EOL" ));
        return (NFM_E_FPUTS_FAILURE);
    }

    /* write project */
    if (fputs ("PROJECT : ", defaults) == EOF)
    {
        _NFMdebug ((fname, "%s\n", "Error writing project keyword" ));
        return (NFM_E_FPUTS_FAILURE);
    }

    /* only write if field is not NULL */
    if( strcmp( d_data[7], NFM_DEFAULT_NULL ) )
    {
        if (fputs (d_data[7], defaults) == EOF)
        {
        _NFMdebug ((fname, "%s\n", "Error writing project" ));
        return (NFM_E_FPUTS_FAILURE);
        }
    }

    if (fputs ("\n", defaults) == EOF)
    {
        _NFMdebug ((fname, "%s\n", "Error writing EOL" ));
        return (NFM_E_FPUTS_FAILURE);
    }

    /* write search */
    if (fputs ("SEARCH : ", defaults) == EOF)
    {
        _NFMdebug ((fname, "%s\n", "Error writing search keyword" ));
        return (NFM_E_FPUTS_FAILURE);
    }

    /* only write if field is not NULL */
    if( strcmp( d_data[8], NFM_DEFAULT_NULL ) )
    {
        if (fputs (d_data[8], defaults) == EOF)
        {
        _NFMdebug ((fname, "%s\n", "Error writing search" ));
        return (NFM_E_FPUTS_FAILURE);
        }
    }

    if (fputs ("\n", defaults) == EOF)
    {
        _NFMdebug ((fname, "%s\n", "Error writing EOL" ));
        return (NFM_E_FPUTS_FAILURE);
    }

    /* write sort */
    if (fputs ("SORT : ", defaults) == EOF)
    {
        _NFMdebug ((fname, "%s\n", "Error writing sort keyword" ));
        return (NFM_E_FPUTS_FAILURE);
    }

    /* only write if field is not NULL */
    if( strcmp( d_data[9], NFM_DEFAULT_NULL ) )
    {
        if (fputs (d_data[9], defaults) == EOF)
        {
        _NFMdebug ((fname, "%s\n", "Error writing sort" ));
        return (NFM_E_FPUTS_FAILURE);
        }
    }

    if (fputs ("\n", defaults) == EOF)
    {
        _NFMdebug ((fname, "%s\n", "Error writing EOL" ));
        return (NFM_E_FPUTS_FAILURE);
    }

    /* write workflow */
    if (fputs ("WORKFLOW : ", defaults) == EOF)
    {
        _NFMdebug ((fname, "%s\n", "Error writing workflow keyword" ));
        return (NFM_E_FPUTS_FAILURE);
    }

    /* only write if field is not NULL */
    if( strcmp( d_data[10], NFM_DEFAULT_NULL ) )
    {
        if (fputs (d_data[10], defaults) == EOF)
        {
        _NFMdebug ((fname, "%s\n", "Error writing workflow" ));
        return (NFM_E_FPUTS_FAILURE);
        }
    }

    if (fputs ("\n", defaults) == EOF)
    {
        _NFMdebug ((fname, "%s\n", "Error writing EOL" ));
        return (NFM_E_FPUTS_FAILURE);
    }

    /* write acl */
    if (fputs ("ACL : ", defaults) == EOF)
    {
        _NFMdebug ((fname, "%s\n", "Error writing ACL keyword" ));
        return (NFM_E_FPUTS_FAILURE);
    }

    /* only write if field is not NULL */
    if( strcmp( d_data[11], NFM_DEFAULT_NULL ) )
    {
        if (fputs (d_data[11], defaults) == EOF)
        {
        _NFMdebug ((fname, "%s\n", "Error writing acl" ));
        return (NFM_E_FPUTS_FAILURE);
        }
    }

    if (fputs ("\n", defaults) == EOF)
    {
        _NFMdebug ((fname, "%s\n", "Error writing EOL" ));
        return (NFM_E_FPUTS_FAILURE);
    }

    /* write node */
    if (fputs ("NODE : ", defaults) == EOF)
    {
        _NFMdebug ((fname, "%s\n", "Error writing node keyword" ));
        return (NFM_E_FPUTS_FAILURE);
    }

    /* only write if field is not NULL */
    if( strcmp( d_data[12], NFM_DEFAULT_NULL ) )
    {
        if (fputs (d_data[12], defaults) == EOF)
        {
        _NFMdebug ((fname, "%s\n", "Error writing node name" ));
        return (NFM_E_FPUTS_FAILURE);
        }
    }

    if (fputs ("\n", defaults) == EOF)
    {
        _NFMdebug ((fname, "%s\n", "Error writing EOL" ));
        return (NFM_E_FPUTS_FAILURE);
    }

    /* write working area */
    if (fputs ("WORKING AREA : ", defaults) == EOF)
    {
        _NFMdebug ((fname, "%s\n", "Error writing working area keyword" ));
        return (NFM_E_FPUTS_FAILURE);
    }

    /* only write if field is not NULL */
    if( strcmp( d_data[13], NFM_DEFAULT_NULL ) )
    {
        if (fputs (d_data[13], defaults) == EOF)
        {
        _NFMdebug ((fname, "%s\n", "Error writing working area" ));
        return (NFM_E_FPUTS_FAILURE);
        }
    }

    if (fputs ("\n", defaults) == EOF)
    {
        _NFMdebug ((fname, "%s\n", "Error writing EOL" ));
        return (NFM_E_FPUTS_FAILURE);
    }

    /* write user option  */
    if (fputs ("USER : ", defaults) == EOF)
    {
        _NFMdebug ((fname, "%s\n", "Error writing USER keyword" ));
        return (NFM_E_FPUTS_FAILURE);
    }

    /* only write if field is not NULL */
    if( strcmp( d_data[14], NFM_DEFAULT_NULL ) )
    {
        if (fputs (d_data[14], defaults) == EOF)
        {
        _NFMdebug ((fname, "%s\n", "Error writing username" ));
        return (NFM_E_FPUTS_FAILURE);
        }
    }

    if (fputs ("\n", defaults) == EOF)
    {
        _NFMdebug ((fname, "%s\n", "Error writing EOL" ));
        return (NFM_E_FPUTS_FAILURE);
    }

    fclose( defaults );

    return( NFM_S_SUCCESS );
 }

/*
 Doc: NFMdelete_user_defaults

 Abstract:
     This function deletes the user's defaults file from <env>/system.
     This is called during Delete User command.

 */

long NFMdelete_user_defaults( )
{
    long    status;

    char    path[NFM_PATHNAME+1];
    char    def_name[NFM_REPORTNAME+1];
    char    def_file[NFM_PATHNAME+NFM_REPORTNAME+2];    
    char    lock_file[NFM_PATHNAME+NFM_REPORTNAME+2];    
    char    sql_string[100];
    
    char    **d_data;

    FILE    *fopen();

    struct  stat fbuff;

    static  char *fname = "NFMdelete_user_defaults";

    MEMptr  buff   = NULL;

    strcpy( sql_string, "SELECT n_tableno FROM nfmtables WHERE n_tablename = 'nfmusers'" );
    status = SQLquery( sql_string, &buff, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
        _NFMdebug((fname,"SQLquery = <0x%.8x>\n", status));
        MEMclose( &buff );
	return( NFM_E_USER_DEFAULTS_LOGIN );
    }

    status = MEMbuild_array( buff );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &buff );
        _NFMdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
        return( NFM_E_MEM );
    }
    d_data = (char**) buff->data_ptr;

    /*  Generate the filename to using the table number and the user
	number.
     */

    status = _NFMbuild_system_path( "nfmadmin", path );
    if( status != NFM_S_SUCCESS )
    {
	_NFMdebug(( fname, "_NFMbuild_system_path <0x%.8x>\n", status ));
	return( status );
    }

    _NFMdebug(( fname, "system path <%s>\n", path ));

    /* Check to see if there is a lock file for this user because
     * another process may be trying to write to this file now.
     * If they are, we won't try to delete it.
     */
    sprintf( lock_file, "%s/%s_%d.LCK", path, d_data[0], NFMglobal.NFMuserno );
    _NFMdebug(( fname, "Lock file <%s>\n", lock_file ));
    
    /*  Does this lock file exist ?? */

    status = stat( lock_file, &fbuff);
    if( !status )      /* This means the file exists */
    {
	_NFMdebug(( fname, "%s\n", "Lock file exists - skip deletion" ));
	return( NFM_E_FAILURE );
    }

    status = NFMnew_file_name( 0, atoi(d_data[0]), NFMglobal.NFMuserno,
                               def_name );
    sprintf( def_file, "%s/%s", path, def_name );
    _NFMdebug(( fname, "defaults file <%s>\n", def_file ));
    MEMclose( &buff );

    /* Delete defaults file */
    unlink( def_file );

    return( NFM_S_SUCCESS );
}
