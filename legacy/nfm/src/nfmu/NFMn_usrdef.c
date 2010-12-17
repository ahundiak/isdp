#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMdb.h"
#include "NFMerrordef.h"
#include "MEMerrordef.h"
#include "SQLerrordef.h"
#include "NFMdef.h"
#include "ERR.h"
#include "NFMqlu.h"
#include "DEBUG.h"
#include "NFMstruct.h"


/* extern long NFM_M_MAP;*/

/* extern NFMqlufDescr *fdescr; */

extern MEMptr NFMusrs_ptr;
extern MEMptr NFMstor_ptr;

/*
 Doc: NFMuser_defaults_*

 Abstract:
     These functions get/put user defaults from/into the nfmusers
     table. 

 History:
     Jill McCutcheon  November 14, 1990 - Creation

 */

extern struct NFMglobal_st NFMglobal ;
long NFMuser_defaults_login ( user_id, data_list )
    long   user_id;
    MEMptr *data_list;
{
  char *fname = "NFMuser_defaults_login" ;
    long    status;
    int     flag;
    int     c;
    int     r;
    int     i,a1,a2,nx;
 
    char    sql_string[500];
    char    attr_name[20],   attr_no[20];
    char    attr_name2[20];
    char    saname[20],      sano[10];
    char    catalogname[20], catalogno[10];
    char    itemname[60],    itemno[10];
    char    itemrev[20];
    char    setcatname[20],  setcatno[10];
    char    setitemname[60], setitemno[10];
    char    setitemrev[20];
    char    projectname[20], projectno[10];
    char    searchname[20],  searchno[10];
    char    sortname[20],    sortno[10];
    char    reportname[20],  reportno[10];
    char    int_ch[10];
    char    user_no[10],sql_str[200];
    char    datax[20];

    char    **column;
    char    **a_data;
    char    **d_data;
    char    **k_data;

    MEMptr  attr   = NULL;
    MEMptr  buff   = NULL;
    MEMptr  ret_buff = NULL;
    MEMptr  sql_bufr = NULL;
    
    _NFMdebug ((fname, "ENTER\n")) ;

    sprintf (user_no, "%d", NFMglobal.NFMuserno) ;
    _NFMdebug ((fname, "user_no <%s>", user_no));
/*
    if(!NFM_M_MAP)
    {
*/
	status = NFMuser_defaults_login_old( user_id, data_list );
	if(status != NFM_S_SUCCESS)
	{
         _NFMdebug ((fname, "NFMuser_defaults_login_old <0x%.8x>", 
	 status));
	 return(status);
	}
        _NFMdebug ((fname, "SUCCESSFUL\n")) ;
        return( NFM_S_SUCCESS );
/*
    }
*/

	/* NFMusrs_ptr is loaded with nfmusers 
	   data defn and the array is built during Login */
  
    column = (char **) NFMusrs_ptr->column_ptr;
    a1 = -1;
    for(i=0;i<NFMusrs_ptr->columns;i++)
    {
	if(!strcmp(column[i],"n_name"))
	{
		a1 = i;
	}
	else if(!strcmp(column[i],"n_nfmname"))
	{
		a2 = i;
	}
    }
    if(a1 == -1 || a2 == -1)
    {
      _NFMdebug ((fname, "error setting offsets \n",""));
	return(NFM_E_FAILURE);
    }
  
    a_data = (char**) NFMusrs_ptr->data_ptr;

/*  Load attribute names into query string 
 */

    strcpy(attr_name,"n_userno");

    strcpy( sql_string, "SELECT " );
    for( r=0; r < NFMusrs_ptr->rows; ++r )
    {
	c = NFMusrs_ptr->columns * r;
	strcat( sql_string, a_data[c+a1] );
	if( (r+1) < NFMusrs_ptr->rows )
	    strcat( sql_string, ", " );
    } 
    strcat( sql_string, " FROM nfmusers WHERE " );
    strcat( sql_string, attr_name );
    strcat( sql_string, " = " );
    strcat( sql_string, user_no );

    status = SQLquery( sql_string, &buff, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
        _NFMdebug ((fname, "SQLquery = <0x%.8x>", status));
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
    status = MEMopen( &ret_buff, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &buff );
	MEMclose( &ret_buff );
        _NFMdebug ((fname, "MEMopen : <0x%.8x>", status ));
        return( status );
    }

    status = MEMwrite_format( ret_buff, "n_name", "char(60)" );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &buff );
  	MEMclose( &ret_buff );
        _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
	 	   status ));
        return( status );
    }

    for( r=0; r < NFMusrs_ptr->rows; ++r )
    {
	c = NFMusrs_ptr->columns * r;

			/***  STORAGE AREA  ***/

	if( strcmp( a_data[c+a2], "n_sano" ) == 0 )
	{

          if( strcmp( d_data[r], "" ) == 0 )
	  {
	        _NFMdebug ((fname, "NO DEFAULT SA" ));
		strcpy( saname, NFM_DEFAULT_NULL );
          }
	  else
          {
	    strcpy( sano, d_data[r] );
	    _NFMdebug ((fname, "sa_no <%s>", sano ));

	    status = NFMj_query_name_or_num( "nfmstoragearea", "n_saname", 
			"n_sano", sano, saname, 0 );
            if( status != NFM_S_SUCCESS )
	    {
		MEMclose( &buff );
		MEMclose( &ret_buff );
		_NFMdebug ((fname, "Qry  Attr : status <0x%.8x>", 
		status));
		return( status );
	    }
          }
	    _NFMdebug ((fname, "sa_name <%s>", saname ));
	}

	/*** CATALOG ***/

	if( strcmp( a_data[c+a2], "n_catalogno" ) == 0 )
	{
          if( strcmp( d_data[r], "" ) == 0 )
	  {
	        _NFMdebug ((fname, "NO DEFAULT CAT" ));
		strcpy( catalogname, NFM_DEFAULT_NULL );
          }
	  else
          {
	    strcpy( catalogno, d_data[r] );
	    _NFMdebug ((fname, "catalog_no <%s>", catalogno ));

	    status = NFMj_query_name_or_num( "nfmtables","n_tablename",
			 "n_tableno", catalogno, catalogname, 0 );
            if( status != NFM_S_SUCCESS )
	    {
		MEMclose( &buff );
		MEMclose( &ret_buff );
		_NFMdebug ((fname, "Qry  Attr : status <0x%.8x>",  status));
		return( status );
	    }
	  }
	    _NFMdebug ((fname, "catalog_name <%s>",
			catalogname ));
	}

	/***  ITEM_NAME, ITEM_REV ***/

	if( strcmp( a_data[c+a2], "n_itemno" ) == 0 )
	{
          if( strcmp( d_data[r], "" ) == 0 )
	  {
	        _NFMdebug ((fname, "NO DEFAULT ITEM" ));
		strcpy( itemname, NFM_DEFAULT_NULL );
		strcpy( itemrev,  NFM_DEFAULT_NULL );
          }
	  else
          {
	    strcpy( itemno, d_data[r] );
	    _NFMdebug ((fname, "item_no <%s>", itemno ));

	    status = NFMk_query_three_attr( catalogno, "n_itemname",
		"n_itemrev", "n_itemno", "n_saname", attr_name2, "n_sano" );
            if( status != NFM_S_SUCCESS )
	    {
		MEMclose( &buff );
		MEMclose( &ret_buff );
		_NFMdebug ((fname, "Qry  Attr : status <0x%.8x>",  status));
		return( status );
	    }
	    sprintf(sql_str,"SELECT %s, %s FROM %s WHERE n_itemno = %s",
	    "n_saname",attr_name2,catalogname,itemno);
            
	    status = SQLquery(sql_str,&sql_bufr,512);
            if( status != SQL_S_SUCCESS  && status != SQL_I_NO_ROWS_FOUND)
	    {
		MEMclose( &buff );
		MEMclose( &ret_buff );
		_NFMdebug ((fname, "Qry  Attr : status <0x%.8x>",  status));
		return( status );
	    }
	    if(status == SQL_I_NO_ROWS_FOUND)
	    {
		MEMclose( &buff );
		MEMclose( &sql_bufr );
		MEMclose( &ret_buff );
		_NFMdebug ((fname, "No Rows found: status <0x%.8x>",
		 status));
		itemname[0] = 0;
		itemrev[0] = 0;
            }
	    else
	    {
		status = MEMbuild_array(sql_bufr);
		if(status != MEM_S_SUCCESS)
		{
		MEMclose( &buff );
		MEMclose( &sql_bufr );
		MEMclose( &ret_buff );
		_NFMdebug ((fname, "MEMbuild_array: status <0x%.8x>",
		 status));
	    	}
		k_data = (char **) sql_bufr->data_ptr;
		strcpy(itemname,k_data[0]);		
		strcpy(itemrev,k_data[1]);		
		MEMclose(&sql_bufr);
	    }	

	    _NFMdebug ((fname, "item_name <%s> : item_rev <%s>\n",
			itemname, itemrev));
         }
	}
  
	/*** SET CATALOG ***/

	if( strcmp( a_data[c+a2], "n_setcatno" ) == 0 )
	{
          if( strcmp( d_data[r], "" ) == 0 )
	  {
	        _NFMdebug ((fname, "NO DEFAULT SET CAT" ));
		strcpy( setcatname, NFM_DEFAULT_NULL );
          }
	  else
          {
	    strcpy( setcatno, d_data[r] );
	    _NFMdebug ((fname, "setcatno <%s>", setcatno ));

	    status = NFMj_query_name_or_num( "nfmtables", "n_tablename",
			 "n_tableno", setcatno, setcatname, 0 );
            if( status != NFM_S_SUCCESS )
	    {
		MEMclose( &buff );
		MEMclose( &ret_buff );
		_NFMdebug ((fname, "Qry  Attr : status <0x%.8x>",  status));
		return( status );
	    }
	  }
	    _NFMdebug ((fname, "setcatname <%s>", setcatname ));
	}

	/*** SET_ITEM_NAME, SET_ITEM_REV  ***/

	if( strcmp( a_data[c+a2], "n_setitemno" ) == 0 )
	{
          if( strcmp( d_data[r], "" ) == 0 )
	  {
	        _NFMdebug ((fname, "NO DEFAULT SET ITEM" ));
		strcpy( setitemname, NFM_DEFAULT_NULL );
		strcpy( setitemrev,  NFM_DEFAULT_NULL );
          }
	  else
          {
	    strcpy( setitemno, d_data[r] );
	    _NFMdebug ((fname, "setitem_no <%s>", setitemno ));

	    status = NFMk_query_three_attr( setcatno, "n_itemname",
		"n_itemrev", "n_itemno", "n_saname", attr_name2, "n_sano" );
            if( status != NFM_S_SUCCESS )
	    {
		MEMclose( &buff );
		MEMclose( &ret_buff );
		_NFMdebug ((fname, "Qry  Attr : status <0x%.8x>",  status));
		return( status );
	    }
	    sprintf(sql_str,"SELECT %s, %s FROM %s WHERE n_itemno = %s",
	    "n_saname",attr_name2,setcatname,setitemno);
            
	    status = SQLquery(sql_str,&sql_bufr,512);
            if( status != SQL_S_SUCCESS  && status != SQL_I_NO_ROWS_FOUND)
	    {
		MEMclose( &buff );
		MEMclose( &ret_buff );
		_NFMdebug ((fname, "Qry  Attr : status <0x%.8x>",  status));
		return( status );
	    }
	    if(status == SQL_I_NO_ROWS_FOUND)
	    {
		MEMclose( &buff );
		MEMclose( &sql_bufr );
		MEMclose( &ret_buff );
		_NFMdebug ((fname, "No Rows found: status <0x%.8x>",
		 status));
		setitemname[0] = 0;
		setitemrev[0] = 0;
            }
	    else
	    {
		status = MEMbuild_array(sql_bufr);
		if(status != MEM_S_SUCCESS)
		{
		MEMclose( &buff );
		MEMclose( &sql_bufr );
		MEMclose( &ret_buff );
		_NFMdebug ((fname, "MEMbuild_array: status <0x%.8x>",
		 status));
	    	}
		k_data = (char **) sql_bufr->data_ptr;
		strcpy(setitemname,k_data[0]);		
		strcpy(setitemrev,k_data[1]);		
		MEMclose(&sql_bufr);
	    }	


	    _NFMdebug ((fname, "set_name <%s>", setitemname ));

	    _NFMdebug ((fname, "set_itemno <%s>", setitemno ));
          }
	}

	/*** PROJECT ***/
	if( strcmp( a_data[c+a2], "n_projectno" ) == 0 )
	{
          if( strcmp( d_data[r], "" ) == 0 )
	  {
	        _NFMdebug ((fname, "NO DEFAULT PROJECT" ));
		strcpy( projectname, NFM_DEFAULT_NULL );
          }
	  else
          {
	    strcpy( projectno, d_data[r] );
	    _NFMdebug ((fname, "project_no <%s>", projectno ));
   
	    status = NFMj_query_name_or_num( "nfmprojects", "n_projectname", 
					    "n_projectno",
			projectno, projectname, 0 );
            if( status != NFM_S_SUCCESS )
	    {
		MEMclose( &buff );
		MEMclose( &ret_buff );
		_NFMdebug ((fname, "Qry  Attr : status <0x%.8x>", status));
		return( status );
	    }
	  }
 	    _NFMdebug ((fname, "project_name <%s>",projectname));
	}

	/***  SEARCH ***/
	if( strcmp( a_data[c+a2], "n_searchno" ) == 0 )
	{
          if( strcmp( d_data[r], "" ) == 0 )
	  {
	        _NFMdebug ((fname, "NO DEFAULT SEARCH" ));
		strcpy( searchname, NFM_DEFAULT_NULL );
          }
	  else
          {
	    strcpy( searchno, d_data[r] );
	    _NFMdebug ((fname, "search_no <%s>", searchno ));

	    status = NFMj_query_name_or_num( "nfmreports", "n_reportname",
			"n_itemno", searchno, searchname, 0 );
            if( status != NFM_S_SUCCESS )
	    {
		MEMclose( &buff );
		MEMclose( &ret_buff );
		_NFMdebug ((fname, "Qry  Attr : status <0x%.8x>",  status));
		return( status );
	    }
	  }
 	    _NFMdebug ((fname, "search_name <%s>",searchname));
	}

	/*** SORT ***/
	if( strcmp( a_data[c+3], "n_sortno" ) == 0 )
	{
          if( strcmp( d_data[r], "" ) == 0 )
	  {
	        _NFMdebug ((fname, "NO DEFAULT SORT" ));
		strcpy( sortname, NFM_DEFAULT_NULL );
          }
	  else
          {
	    strcpy( sortno, d_data[r] );
	    _NFMdebug ((fname, "sort_no <%s>", sortno ));

	    status = NFMj_query_name_or_num( "nfmreports", "n_reportname",
			"n_itemno", sortno, sortname, 0 );
            if( status != NFM_S_SUCCESS )
	    {
		MEMclose( &buff );
		MEMclose( &ret_buff );
		_NFMdebug ((fname, "Qry  Attr : status <0x%.8x>", status));
		return( status );
	    }
	  }
 	    _NFMdebug ((fname, "sort_name <%s>",sortname));
	}

	/*** REPORT ***/
	if( strcmp( a_data[c+a2], "n_reportno" ) == 0 )
	{
          if( strcmp( d_data[r], "" ) == 0 )
	  {
	        _NFMdebug ((fname, "NO DEFAULT REPORT" ));
		strcpy( reportname, NFM_DEFAULT_NULL );
          }
	  else
          {
	    strcpy( reportno, d_data[r] );
	    _NFMdebug ((fname, "report_no <%s>", reportno ));

	    status = NFMj_query_name_or_num( "nfmreports", "n_reportname",
			"n_itemno", reportno, reportname, 0);
            if( status != NFM_S_SUCCESS )
	    {
		MEMclose( &buff );
		MEMclose( &ret_buff );
		_NFMdebug ((fname, "Qry  Attr : status <0x%.8x>", status));
		return( status );
	    }
	  }
 	    _NFMdebug ((fname, "report_name <%s>",reportname));
	}
    } 

    /*  Now write all the information to the return_buffer */

    strcpy( sql_string, saname );
    strcat( sql_string, "\1" );
    status = MEMwrite( ret_buff, sql_string );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &buff );
	MEMclose( &ret_buff );
	_NFMdebug ((fname, "Write SA : status <0x%.8x>",
		   status));
	return( status );
    }

    strcpy( sql_string, catalogname );
    strcat( sql_string, "\1" );
    status = MEMwrite( ret_buff, sql_string );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &buff );
	MEMclose( &ret_buff );
	_NFMdebug ((fname, "Write CAT : status <0x%.8x>",
		   status));
	return( status );
    }

    strcpy( sql_string, itemname );
    strcat( sql_string, "\1" );
    status = MEMwrite( ret_buff, sql_string );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &buff );
	MEMclose( &ret_buff );
	_NFMdebug ((fname, "Write Item Name : status <0x%.8x>",
		   status));
	return( status );
    }

    strcpy( sql_string, itemrev );
    strcat( sql_string, "\1" );
    status = MEMwrite( ret_buff, sql_string );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &buff );
	MEMclose( &ret_buff );
	_NFMdebug ((fname, "Write Item Rev : status <0x%.8x>",
		   status));
	return( status );
    }

    strcpy( sql_string, setcatname );
    strcat( sql_string, "\1" );
    status = MEMwrite( ret_buff, sql_string );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &buff );
	MEMclose( &ret_buff );
	_NFMdebug ((fname, "Write Set Cat : status <0x%.8x>",
		   status));
	return( status );
    }

    strcpy( sql_string, setitemname );
    strcat( sql_string, "\1" );
    status = MEMwrite( ret_buff, sql_string );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &buff );
	MEMclose( &ret_buff );
	_NFMdebug ((fname, "Write Set Item: status <0x%.8x>",
		   status));
	return( status );
    }

    strcpy( sql_string, setitemrev );
    strcat( sql_string, "\1" );
    status = MEMwrite( ret_buff, sql_string );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &buff );
	MEMclose( &ret_buff );
	_NFMdebug ((fname, "Write Set Item Rev : status <0x%.8x>", status));
	return( status );
    }

    strcpy( sql_string, projectname );
    strcat( sql_string, "\1" );
    status = MEMwrite( ret_buff, sql_string );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &buff );
	MEMclose( &ret_buff );
	_NFMdebug ((fname, "Write Project : status <0x%.8x>",
		   status));
	return( status );
    }

    strcpy( sql_string, searchname );
    strcat( sql_string, "\1" );
    status = MEMwrite( ret_buff, sql_string );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &buff );
	MEMclose( &ret_buff );
	_NFMdebug ((fname, "Write Search : status <0x%.8x>",
		   status));
	return( status );
    }

    strcpy( sql_string, sortname );
    strcat( sql_string, "\1" );
    status = MEMwrite( ret_buff, sql_string );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &buff );
	MEMclose( &ret_buff );
	_NFMdebug ((fname, "Write Sort : status <0x%.8x>",
		   status));
	return( status );
    }

    strcpy( sql_string, reportname );
    strcat( sql_string, "\1" );
    status = MEMwrite( ret_buff, sql_string );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose( &buff );
	MEMclose( &ret_buff );
	_NFMdebug ((fname, "Write Report : status <0x%.8x>",
		   status));
	return( status );
    }

    status = MEMsplit_copy_buffer( ret_buff, data_list, 0 );
    if (status != MEM_S_SUCCESS)
    {
	MEMclose( &buff );
	MEMclose( &ret_buff );
        _NFMdebug ((fname, "MEMsplit_copy_buffer : <0x%.8x>",
                   status));
        return (status);
    }

    MEMclose( &buff );
    MEMclose( &ret_buff );

    _NFMdebug ((fname, "SUCCESSFUL\n")) ;

    return( NFM_S_SUCCESS );    
}

NFMk_query_three_attr( table_no, nfm1, nfm2, nfm3, 
		       attr1, attr2, attr3 )
    char *table_no;	/* i - table to find attributes for */
    char *nfm1; 	/* i - n_nfmname #1 to find */
    char *nfm2;		/* i - n_nfmname #2 to find */
    char *nfm3;		/* i - n_nfmname #3 to find */
    char *attr1;	/* o - n_name for n_nfmname #1 */
    char *attr2;	/* o - n_name for n_nfmname #2 */
    char *attr3;	/* o - n_name for n_nfmname #3 */
{
  char *fname = "NFMk_query_three_attr" ;
    long   status;
    int    r;
    int    c;

    char   sql_string[500];

    char   **data;

    MEMptr buffer   = NULL;

    sprintf( sql_string, 
    "SELECT n_name,n_nfmname FROM nfmattributes WHERE n_tableno = %s",
    table_no); 
    status = SQLquery( sql_string, &buffer, MEM_SIZE );
    if( status != SQL_S_SUCCESS )
    {
        _NFMdebug ((fname, "SQLquery = <0x%.8x>", status));
        MEMclose (&buffer);
        ERRload_struct( NFM, NFM_E_MAP_ATTRIBUTE_NAMES, NULL, NULL );
        return( NFM_E_MAP_ATTRIBUTE_NAMES );
    }

    MEMbuild_array (buffer);
    data = (char**) buffer->data_ptr;

    for( r = 0; r < (buffer->rows*buffer->columns); r+=buffer->columns )
    {
	if( strcmp( data[r+1], nfm1 ) == 0 )
	    strcpy( attr1, data[r] );
	if( strcmp( data[r+1], nfm2 ) == 0 )
	    strcpy( attr2, data[r] );
	if( strcmp( data[r+1], nfm3 ) == 0 )
	    strcpy( attr3, data[r] );
    }
    MEMclose( &buffer );

    _NFMdebug ((fname, "SUCCESSFUL\n")) ;
    return( NFM_S_SUCCESS );
}


