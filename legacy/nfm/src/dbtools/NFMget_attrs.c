#include "machine.h"
#include "DBTOOLS.h"
long _NFMget_attributes_from_query ( sql_string, attr_list)
    char   *sql_string ;
    MEMptr *attr_list;
{
  char *fname = "_NFMget_attributes_from_query" ;
  long   status;
  long   r, c, i, x, y, offset ;
  char   **data, *str, **column_p, **column ;
  char   datatype [20] ;
  MEMptr buffer   = NULL;
  
  _NFMdebug ((fname, "sql_string <%s>\n", sql_string)) ;

  if ( *attr_list == NULL)
    {
      status = SQLquery( sql_string, &buffer, MEM_SIZE );
      if( status != SQL_S_SUCCESS )
	{
	  _NFMdebug ((fname, "SQLquery = <0x%.8x>", status));
	  MEMclose (&buffer);
	  if (status == SQL_I_NO_ROWS_FOUND)
	    {
	      _NFMdebug ((fname, "No rows found\n")) ;
	      return (status) ;
	    }
	  ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
	  return( NFM_E_SQL_QUERY) ;
	}
      
      status = MEMbuild_array (buffer);
      if (status != MEM_S_SUCCESS)
	{
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n", status));
	  return (NFM_E_MEM) ;
	}
      data = (char**) buffer->data_ptr;
      
      status = MEMopen( attr_list, MEM_SIZE );
      if( status != MEM_S_SUCCESS )
	{
	  MEMclose (attr_list) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  MEMclose( &buffer );
	  _NFMdebug ((fname, "MEMopen : <0x%.8x>", status ));
	  return( NFM_E_MEM );
	}
      
      status = MEMwrite_format( *attr_list, "n_name", "char(20)" );
      if( status != MEM_S_SUCCESS )
	{
	  MEMclose (attr_list) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  MEMclose( &buffer );
	  _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
		      status ));
	  return( NFM_E_MEM );
	}    	
      status = MEMwrite_format( *attr_list, "n_datatype", "char(15)" );
      if( status != MEM_S_SUCCESS )
	{
	  MEMclose (attr_list) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  MEMclose( &buffer );
	  _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
		      status ));
	  return( NFM_E_MEM );
	}    	
      status = MEMwrite_format( *attr_list, "n_synonym", "char(40)" );
      if( status != MEM_S_SUCCESS )
	{
	  MEMclose (attr_list) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  MEMclose( &buffer );
	  _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
		      status ));
	  return( NFM_E_MEM );
	}
      
      status = MEMwrite_format( *attr_list, "n_application", "char(3)" );
      if( status != MEM_S_SUCCESS )
	{
	  MEMclose (attr_list) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  MEMclose( &buffer );
	  _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
		      status ));
	  return( NFM_E_MEM );
	}
      
      status = MEMwrite_format( *attr_list, "n_read", "char(1)" );
      if( status != MEM_S_SUCCESS )
	{
	  MEMclose (attr_list) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  MEMclose( &buffer );
	  _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
		      status ));
	  return( NFM_E_MEM );
	}    	
      status = MEMwrite_format( *attr_list, "n_write", "char(1)" );
      if( status != MEM_S_SUCCESS )
	{
	  MEMclose (attr_list) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  MEMclose( &buffer );
	  _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
		      status ));
	  return( NFM_E_MEM );
	}    	
      status = MEMwrite_format( *attr_list, "n_update", "char(1)" );
      if( status != MEM_S_SUCCESS )
	{
	  MEMclose (attr_list) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  MEMclose( &buffer );
	  _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
		      status ));
	  return( NFM_E_MEM );
	}    	
      status = MEMwrite_format( *attr_list, "n_delete", "char(1)" );
      if( status != MEM_S_SUCCESS )
	{
	  MEMclose (attr_list) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  MEMclose( &buffer );
	  _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
		      status ));
	  return( NFM_E_MEM );
	}    	
      status = MEMwrite_format( *attr_list, "n_null", "char(1)" );
      if( status != MEM_S_SUCCESS )
	{
	  MEMclose (attr_list) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  MEMclose( &buffer );
	  _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
		      status ));
	  return( NFM_E_MEM );
	}    	
      
      status = MEMwrite_format( *attr_list, "n_checkin", "char(1)" );
      if( status != MEM_S_SUCCESS )
	{
	  MEMclose (attr_list) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  MEMclose( &buffer );
	  _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
		      status ));
	  return( NFM_E_MEM );
	}    	
      status = MEMwrite_format( *attr_list, "n_checkout", "char(1)" );
      if( status != MEM_S_SUCCESS )
	{
	  MEMclose (attr_list) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  MEMclose( &buffer );
	  _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
		      status ));
	  return( NFM_E_MEM );
	}    	
      
      status = MEMwrite_format( *attr_list, "n_seqno", "integer" );
      if( status != MEM_S_SUCCESS )
	{
	  MEMclose (attr_list) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  MEMclose( &buffer );
	  _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
		      status ));
	  return( NFM_E_MEM );
	}
      status = MEMwrite_format( *attr_list, "n_attrno", "integer" );
      if( status != MEM_S_SUCCESS )
	{
	  MEMclose (attr_list) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  MEMclose( &buffer );
	  _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
		      status ));
	  return( NFM_E_MEM );
	}    	
      
      status = MEMwrite_format( *attr_list, "n_tableno", "integer" );
      if( status != MEM_S_SUCCESS )
	{
	  MEMclose (attr_list) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  MEMclose( &buffer );
	  _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
		      status ));
	  return( NFM_E_MEM );
	}    	
      
      status = MEMwrite_format( *attr_list, "n_valueno", "integer" );
      if( status != MEM_S_SUCCESS )
	{
	  MEMclose (attr_list) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  MEMclose( &buffer );
	  _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
		      status ));
	  return( NFM_E_MEM );
	}    	
/*******      
      status = MEMwrite_format( *attr_list, "n_adviceno", "integer" );
      if( status != MEM_S_SUCCESS )
	{
	  MEMclose (attr_list) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  MEMclose( &buffer );
	  _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
		      status ));
	  return( NFM_E_MEM );
	}    	
      
*****************/
      sprintf (datatype, "char(%d)", NFM_VALUE) ;
      status = MEMwrite_format( *attr_list, "n_advice", datatype) ;
      if( status != MEM_S_SUCCESS )
	{
	  MEMclose (attr_list) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  MEMclose( &buffer );
	  _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
		      status ));
	  return( NFM_E_MEM );
	}    	
      
      
      for( r = 0; r < (buffer->rows*buffer->columns); r+=buffer->columns )
	{
	  sql_string [0] = 0 ;
	  for( c = 0; c < (buffer->columns); ++c )
	    {
	      strcat( sql_string, data[r+c] );
	      strcat( sql_string, "\001" );
	    }
	  /* n_valueno = 0 */
	  strcat( sql_string, "0\001" );
	  /* n_adviceno = 0 */
	  strcat( sql_string, "\001" );
	  
	  status = MEMwrite( *attr_list, sql_string );
	  if( status != MEM_S_SUCCESS )
	    {
	      MEMclose (attr_list) ;
	      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	      MEMclose( &buffer );
	      _NFMdebug ((fname, "MEMwrite_format:<0x%.8x>", 
			  status ));
	      return( NFM_E_MEM );
	    }    	
	}
    }
  else
    {
      status = SQLquery( sql_string, &buffer, MEM_SIZE );
      if( status != SQL_S_SUCCESS )
	{
	  _NFMdebug ((fname, "SQLquery = <0x%.8x>", status));
	  MEMclose (&buffer);
	  if (status == SQL_I_NO_ROWS_FOUND)
	    {
	      _NFMdebug ((fname, "No rows found\n")) ;
	      return (status) ;
	    }
	  ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
	  return( NFM_E_SQL_QUERY) ;
	}
      
      status = MEMbuild_array (buffer);
      if (status != MEM_S_SUCCESS)
	{
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n", status));
	  return (NFM_E_MEM) ;
	}

      status = MEMbuild_array (*attr_list) ;
      if (status != MEM_S_SUCCESS)
	{
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n", status));
	  return (NFM_E_MEM) ;
	}

      data = (char **) buffer->data_ptr;
      column = (char **) buffer->column_ptr ;
      column_p = (char **) (*attr_list)->column_ptr ;
      str = (char *) malloc ((*attr_list)->columns * 100) ;
      if (str == NULL)
	{
	  _NFMdebug ((fname, "Malloc failed\n")) ;
	  ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
	  return (NFM_E_MALLOC) ;
	}
 
      for (i=0; i<buffer->rows; i++)
	{
	  offset = i*buffer->columns ;
	  str [0] = 0 ;
	  for (x=0; x<(*attr_list)->columns; x++)
	    {
	      for (y=0; y<buffer->columns; y++) 
		{
		  if (strcmp (column [y], column_p [x]) == 0)
		    {
		      strcat (str, data [offset+y]) ;
		      break ;
		    }
		}
	      strcat (str, "\001") ;
	    }
	  
	  status = MEMwrite (*attr_list, str) ;
	  if (status != MEM_S_SUCCESS)
	    {
	      _NFMdebug ((fname, "MEMwrite failed : status = <0x%.8x>\n",
			  status)) ;
	      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	      return (NFM_E_MEM) ;
	    }
	  
	  status = MEMbuild_array (*attr_list) ;
	  if (status != MEM_S_SUCCESS)
	    {
	      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
			  status)) ;
	      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	      return (NFM_E_MEM) ;
	    }
	  column_p = (char **) (*attr_list)->column_ptr ;
	}
      free (str) ;
    }

  status = MEMclose( &buffer );
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (attr_list) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n", status)) ;
      return (NFM_E_MEM) ;
    }

    _NFMdebug ((fname, "SUCCESSFUL\n")) ;
    return( NFM_S_SUCCESS );
}



long NFMquery_attr_def (user_id, table_type, table_name,
                        table_str, cond_str, attr_list)
   long     user_id;
   char     *table_type, *table_name;
   char     *table_str, *cond_str;
   MEMptr   *attr_list;
   {
     static char *fname = "NFMquery_attr_def" ;
     long     status;
     char     sql_str [1024];
     long     table_no ;
     long     NFMget_attr_def ();
     long     NFMget_sysattr_def ();
 
     _NFMdebug ((fname, "Table Type  = <%s> : Table Name = <%s> : Table Str = <%s> : Cond Str = <%s>\n", 
		 table_type, table_name, table_str, cond_str));
     
     if (! strlen (table_str))
      {
        status = NFMget_table_no (user_id, table_type, table_name,
                 &table_no);
        if (status != NFM_S_SUCCESS)
         {
           _NFMdebug ((fname, "Get Table No : status = <0x%.8x>\n",
           status));
           return (status);          
         }

        sprintf (sql_str, "n_tableno = %d", table_no);
      }
     else
        sprintf (sql_str, "%s", table_str);

     if (strcmp (table_type, "nfmsystem") == 0)
       {
	 status = NFMget_sysattr_def (user_id, sql_str, 
				      cond_str, attr_list);
	 if (status != NFM_S_SUCCESS)
	   {
	     MEMclose (attr_list);
	     _NFMdebug ((fname, "Get Tab Attr : status = <0x%.8x>\n",
			 status));
	     return (status);          
	   }
       }
     else
       {
	 status = NFMget_attr_def (user_id, sql_str, 
				   cond_str, attr_list);
	 if (status != NFM_S_SUCCESS)
	   {
	     MEMclose (attr_list);
	     _NFMdebug ((fname, "Get Tab Attr : status = <0x%.8x>\n",
			 status));
	     return (status);          
	   }
       }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
		 NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

long _NFMquery_systable_attributes (table_name, 
				    attr_list, data_list, value_list)
   char     *table_name;
   MEMptr   *attr_list, *data_list, *value_list;
   {
     static char *fname = "_NFMquery_systable_attributes" ;
     long     status;
     long     next_seq_no ;
     long     _NFMget_systable_attr () ;
     long     _NFMget_data_info ();

     _NFMdebug ((fname, "Table Name = <%s> \n",	 table_name));
    
     status = _NFMget_systable_attr (table_name,attr_list, &next_seq_no);
     if (status != NFM_S_SUCCESS)
       {
	 MEMclose (attr_list);
	 MEMclose (data_list);
	 MEMclose (value_list);
	 _NFMdebug ((fname, "Get Tab Attr : status = <0x%.8x>\n",
		     status));
	 return (status);          
       }

     status = _NFMget_data_info (*attr_list, data_list, value_list) ;
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        _NFMdebug ((fname, "Get Data Values : status = <0x%.8x>\n",
        status));
        return (status);          
      }
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }


 long NFMget_table_attr (user_id, table_str, cond_str, list)
   long     user_id ;
   char     *table_str, *cond_str;
   MEMptr   *list;
   {
     static char *fname = "NFMget_table_attr" ;
     long     status;
     char     sql_str [2048];

     _NFMdebug ((fname, "Table Str = <%s> : Cond str = <%s>\n", 
		 table_str, cond_str));
     user_id = user_id ;
     if (strlen (cond_str))
       sprintf (sql_str, 
       "SELECT %s%s%s FROM %s WHERE %s AND %s %s",
       "n_name, n_datatype, n_synonym, ",
       "n_application, n_read, n_write, n_update, n_delete, n_null, ",
       "n_checkin, n_checkout, n_seqno, n_attrno, n_tableno",
       "NFMATTRIBUTES", cond_str, table_str, "ORDER BY n_tableno,n_seqno");
     else
       sprintf (sql_str, "SELECT %s%s%s FROM %s WHERE %s %s",
       "n_name, n_datatype, n_synonym, ",
       "n_application, n_read, n_write, n_update, n_delete, n_null, ",
       "n_checkin, n_checkout, n_seqno, n_attrno, n_tableno",
       "NFMATTRIBUTES", table_str, "ORDER BY n_tableno,n_seqno");

     status = _NFMget_attributes_from_query ( sql_str, list) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Get attributes from query : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMget_systable_attr (user_id, table_str, cond_str, list)
   long user_id ;
   char     *table_str, *cond_str;
   MEMptr   *list;
   {
     static char *fname = "NFMget_systable_attr" ;
     long     status;
     char     sql_str [2048];

     _NFMdebug ((fname, "Table Str = <%s> : Cond str = <%s>\n", 
		 table_str, cond_str));

     user_id = user_id ;
     if (strlen (cond_str))
       sprintf (sql_str, 
       "SELECT %s%s%s FROM %s WHERE %s AND %s %s",
       "n_name, n_datatype, n_synonym, ",
       "n_application, n_read, n_write, n_update, n_delete, n_null, ",
       "n_checkin, n_checkout, n_seqno, n_attrno, n_tableno",
       "NFMSYSATTRIBUTES", cond_str, table_str, "ORDER BY n_tableno,n_seqno");
     else
       sprintf (sql_str, "SELECT %s%s%s FROM %s WHERE %s %s",
       "n_name, n_datatype, n_synonym, ",
       "n_application, n_read, n_write, n_update, n_delete, n_null, ",
       "n_checkin, n_checkout, n_seqno, n_attrno, n_tableno",
       "NFMSYSATTRIBUTES", table_str, "ORDER BY n_tableno, n_seqno");

     status = _NFMget_attributes_from_query ( sql_str, list) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Get attributes from query : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMget_attr_def (user_id, table_str, cond_str, list)
   long     user_id;
   char     *table_str, *cond_str;
   MEMptr   *list;
   {
     static char *fname = "NFMget_attr_def" ;
     long     status;
     char     sql_str [2048];

     _NFMdebug ((fname, "Table Str = <%s> : Cond Str = <%s>\n", 
		 table_str, cond_str));
     user_id = user_id ;
     if (strlen (cond_str))
       sprintf (sql_str, 
       "SELECT %s FROM %s WHERE %s AND %s %s",
       "n_name, n_datatype, n_name, n_synonym, n_application, n_seqno",
       "NFMATTRIBUTES", cond_str, table_str, "ORDER BY n_seqno");
     else
       sprintf (sql_str, "SELECT %s FROM %s WHERE %s %s",
       "n_name, n_datatype, n_name,  n_synonym, n_application, n_seqno",
       "NFMATTRIBUTES", table_str, "ORDER BY n_seqno");

     status = SQLquery (sql_str, list, 2 * MEM_SIZE);
     if (status != SQL_S_SUCCESS)
      {
        MEMclose (list);
   
        if ((status) == SQL_I_NO_ROWS_FOUND)
         {
            ERRload_struct (NFM, NFM_E_BAD_ATTR, "", NULL);
           _NFMdebug ((fname, "No Such Columns : status = <0x%.8x>\n", 
           NFM_E_BAD_ATTR));
           return (NFM_E_BAD_ATTR);         
         }

	ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "Query Syntax : status = <0x%.8x>\n",
		    status));
        return (NFM_E_SQL_QUERY);         
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMget_sysattr_def (user_id, table_str, cond_str, list)
   long     user_id;
   char     *table_str, *cond_str;
   MEMptr   *list;
   {
     static char *fname = "NFMget_attr_def" ;
     long     status;
     char     sql_str [2048];

     _NFMdebug ((fname, "Table Str = <%s> : Cond Str = <%s>\n", 
		 table_str, cond_str));
     user_id = user_id ;
     if (strlen (cond_str))
       sprintf (sql_str, 
       "SELECT %s FROM %s WHERE %s AND %s %s",
       "n_name, n_datatype, n_name, n_synonym, n_application, n_seqno",
       "NFMSYSATTRIBUTES", cond_str, table_str, "ORDER BY n_seqno");
     else
       sprintf (sql_str, "SELECT %s FROM %s WHERE %s %s",
       "n_name, n_datatype, n_name,  n_synonym, n_application, n_seqno",
       "NFMSYSATTRIBUTES", table_str, "ORDER BY n_seqno");

     status = SQLquery (sql_str, list, 2 * MEM_SIZE);
     if (status != SQL_S_SUCCESS)
      {
        MEMclose (list);
   
        if ((status) == SQL_I_NO_ROWS_FOUND)
         {
            ERRload_struct (NFM, NFM_E_BAD_ATTR, "", NULL);
           _NFMdebug ((fname, "No Such Columns : status = <0x%.8x>\n", 
           NFM_E_BAD_ATTR));
           return (NFM_E_BAD_ATTR);         
         }

            ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "Query Syntax : status = <0x%.8x>\n",
		    status));
        return (NFM_E_SQL_QUERY);         
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMmerge_change_attributes (user_id,
                                  temp_attr, temp_data, temp_value,
                                  attr_list, data_list, value_list)
   long     user_id;
   MEMptr   temp_attr,  temp_data,  temp_value;
   MEMptr   *attr_list, *data_list, *value_list;
   {
     static char *fname = "NFMmerge_change_attributes" ;
     long    status, atol ();
     char    *sql_str;
     char    value [50];
     char    **column,  **format,  **data;
     char    **column1, **format1, **data1;
     long    x, y, count;
     long    init_rows, init_buffers;
     MEMptr  list = NULL;

     _NFMdebug ((fname, "ENTER\n")) ;
     user_id = user_id ;

     status = MEMbuild_array (temp_attr);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);

            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);          
      }

     column = (char **) temp_attr -> column_ptr;
     format = (char **) temp_attr -> format_ptr;
     data   = (char **) temp_attr -> data_ptr;

     if (! (*attr_list))
      {
        status = MEMopen (attr_list, 2 * MEM_SIZE);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);

            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n", status));
           return (NFM_E_MEM);          
         }

        for (y = 0; y < temp_attr -> columns; ++y)
         {
           status = MEMwrite_format (*attr_list, column [y], format [y]);
           if (status != MEM_S_SUCCESS)
            {
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (value_list);

            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
			  status));
              return (NFM_E_MEM);          
            }
         }

        for (y = 0; y < temp_attr -> columns; ++y)
         {
	   sprintf (value, "new_%s", column [y]);
	   
	   status = MEMwrite_format (*attr_list, value, format [y]);
	   if (status != MEM_S_SUCCESS)
	     {
	       MEMclose (attr_list);
	       MEMclose (data_list);
	       MEMclose (value_list);
	       
	       ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	       _NFMdebug ((fname, "MEM Wr For : status = <0x%.8x>\n",
			   status));
	       return (NFM_E_MEM);          
	     }
	 }
      }

     init_rows = (*attr_list) -> rows;

     if (*value_list)  
       {
	 status = MEMno_buffers (*value_list, &init_buffers);
	 if (status != MEM_S_SUCCESS) 
	   {
	     MEMclose (attr_list);
	     MEMclose (data_list);
	     MEMclose (value_list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	     _NFMdebug ((fname, "MEMno_buffers : status = <0x%.8x>\n",
			 status));
	     return (NFM_E_MEM) ;
	   }
       }
     else  init_buffers = 0;

     sql_str = (char *) malloc ((*attr_list) -> row_size);
     if (! sql_str)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
            ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
        NFM_E_MALLOC));
        return (NFM_E_MALLOC);          
      }
     sql_str [0] = 0;

     for (x = 0; x < temp_attr -> rows; ++x)
      {
        count = temp_attr -> columns * x;
        sql_str [0] = 0;

        for (y = 0; y < temp_attr -> columns; ++y)
         {
/*
           if ((! strcmp (column [y], "n_valueno"))   ||
               (! strcmp (column [y], "n_adviceno")))
*/
           if (! strcmp (column [y], "n_valueno"))
            {
              if (atol (data [count + y]) > 0)
               {
                 sprintf (value, "%d", 
                          init_buffers + atol (data [count + y]));
                 strcat (sql_str, value);
               }
              else
                strcat (sql_str, data [count + y]);
            }
           else
              strcat (sql_str, data [count + y]);

           strcat (sql_str, "\1");
         }

        for (y = 0; y < temp_attr -> columns; ++y)
         {
/*	   if ((! strcmp (column [y], "n_valueno"))   ||
	       (! strcmp (column [y], "n_adviceno"))) 
*/
	   if (! strcmp (column [y], "n_valueno"))
	     {
	       if (atol (data [count + y]) > 0)
		 {
		   sprintf (value, "%d", 
			    init_buffers + atol (data [count + y]));
		   strcat (sql_str, value);
		 }
	       else
		 strcat (sql_str, data [count + y]);
	     }
	   else
	     strcat (sql_str, data [count + y]);
	   
	   strcat (sql_str, "\1");
         }

        status = MEMwrite (*attr_list, sql_str);
        if (status != MEM_S_SUCCESS)
         {
           free (sql_str);
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);

            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);          
         }
      }

     free (sql_str);

     if (! init_rows)
      {
        status = MEMsplit_copy_buffer (temp_data, data_list, 1);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);

            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Copy : status = <0x%.8x>\n", status));
           return (NFM_E_MEM);          
         }

        status = MEMbuild_array (*data_list);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);

            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);          
         }

        data = (char **) (*data_list) -> data_ptr;

        sql_str = (char *) malloc ((*data_list) -> row_size);
        if (! sql_str)
         {
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);

            ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
           _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
           NFM_E_MALLOC));
           return (NFM_E_MALLOC);          
         }

        sql_str [0] = 0;

        for (y = 0; y < (*data_list) -> columns; ++y)
         {
           strcat (sql_str, data [y]);
           strcat (sql_str, "\1");
         }

        status = MEMwrite (*data_list, sql_str);
        if (status != MEM_S_SUCCESS)
         {
           free (sql_str);

           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);

            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);          
         }
    
        free (sql_str);
      }
     else
      {
        status = MEMbuild_array (*data_list);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);

            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);          
         }

        column = (char **) (*data_list) -> column_ptr;
        format = (char **) (*data_list) -> format_ptr;
        data   = (char **) (*data_list) -> data_ptr;

        status = MEMbuild_array (temp_data);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);

            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);          
         }

        column1 = (char **) temp_data -> column_ptr;
        format1 = (char **) temp_data -> format_ptr;
        data1   = (char **) temp_data -> data_ptr;

        status = MEMopen (&list, MEM_SIZE);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);

            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);          
         }

        for (y = 0; y < (*data_list) -> columns; ++y)
         {
           status = MEMwrite_format (list, column [y], format [y]);
           if (status != MEM_S_SUCCESS)
            {
              MEMclose (&list);

              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (value_list);
 
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _NFMdebug ((fname, "MEM Write For : status = <0x%.8x>\n",
			  status));
              return (NFM_E_MEM);          
            }
         }

        for (y = 0; y < temp_data -> columns; ++y)
         {
           status = MEMwrite_format (list, column1 [y], format1 [y]);
           if (status != MEM_S_SUCCESS)
            {
               MEMclose (&list);

               MEMclose (attr_list);
               MEMclose (data_list);
               MEMclose (value_list);

            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               _NFMdebug ((fname, "MEM Write For : status = <0x%.8x>\n",
			   status));
               return (NFM_E_MEM);          
            }
         }

        sql_str = (char *) malloc (list -> row_size);
        if (! sql_str)
         {
           MEMclose (&list);

           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);

            ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
           _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
           NFM_E_MALLOC));
           return (NFM_E_MALLOC);          
         }

        for (x = 0; x < (*data_list) -> rows; ++x)
         {
            count = (*data_list) -> columns * x;

            sql_str [0] = 0;

            for (y = 0; y < (*data_list) -> columns; ++y)
              strcat (sql_str, data [count + y]);

            for (y = 0; y < temp_data -> columns; ++y)
              strcat (sql_str, data1 [y]);

            strcat (sql_str, "\1");

            status = MEMwrite (list, sql_str);
            if (status != MEM_S_SUCCESS)
             {
               free (sql_str);
               MEMclose (&list);
               MEMclose (attr_list);
               MEMclose (data_list);
               MEMclose (value_list);

            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
			   status));
               return (NFM_E_MEM);          
             }
         }

        free (sql_str);

        status = MEMclose (data_list);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (&list);
           MEMclose (attr_list);
           MEMclose (value_list);

            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);          
         }

        status = MEMsplit_copy_buffer (list, data_list, 0);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (&list);
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);

            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Copy : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);          
         }

        status = MEMclose (list);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);

            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);          
         }
      }

     if (! init_rows)
      {
        if (temp_value)
         {
           status = MEMsplit_copy_buffer (temp_value, value_list, 1);
           if (status != MEM_S_SUCCESS)
            {
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (value_list);

            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _NFMdebug ((fname, "MEM Copy : status = <0x%.8x>\n",
			  status));
              return (NFM_E_MEM);          
            }
         }
      }
     else
      {
        if (temp_value)
         {
           if (! (*value_list))
            {
              status = MEMsplit_copy_buffer (temp_value, value_list, 1);
              if (status != MEM_S_SUCCESS)
               {
                 MEMclose (attr_list);
                 MEMclose (data_list);
                 MEMclose (value_list);

            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
                 _NFMdebug ((fname, "MEM Copy : status = <0x%.8x>\n",
			     status));
                 return (NFM_E_MEM);          
               }
            }
           else
            {
              status = MEMappend (temp_value, *value_list);
              if (status !=  MEM_S_SUCCESS)
               {
                 MEMclose (attr_list);
                 MEMclose (data_list);
                 MEMclose (value_list);

            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
                 _NFMdebug ((fname, "MEM Append : status = <0x%.8x>\n",
			     status));
                 return (NFM_E_MEM);          
               }
            }
         }
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

     
 long _NFMget_table_attr (table_name, list)
   char     *table_name ;
   MEMptr   *list;
   {
     static char *fname = "_NFMget_table_attr" ;
     long     status ;
     char     sql_str [2048], table_str [500];

     _NFMdebug ((fname, "Enter\n")) ;

      sprintf (table_str, "n_tableno in (select n_tableno from nfmtables \
where (n_tablename = '%s' and n_tabletype = 'catalog') \
or (n_tablename = 'f_%s' and n_tabletype = 'f_catalog'))",
	       table_name, table_name) ;

     sprintf (sql_str, "SELECT %s%s%s FROM %s WHERE %s %s",
              "n_name, n_datatype, n_synonym, ",
              "n_application, n_read, n_write, n_update, n_delete, n_null, ",
              "n_checkin, n_checkout, n_seqno, n_attrno,n_tableno",
              "NFMATTRIBUTES", table_str, "ORDER BY n_tableno,n_seqno");


     status = _NFMget_attributes_from_query ( sql_str, list) ;
     if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Get attributes from query : status = <0x%.8x>\n",
                     status)) ;
         return (status) ;
       }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

/**********only updatable attributes *********/
 long _NFMget_table_attr_u (table_name, list)
   char     *table_name ;
   MEMptr   *list;
   {
     static char *fname = "_NFMget_table_attr_u" ;
     long     status ;
     char     sql_str [2048], table_str [500];

     _NFMdebug ((fname, "Enter\n")) ;

      sprintf (table_str, "n_tableno in (select n_tableno from nfmtables \
where (n_tablename = '%s' and n_tabletype = 'catalog') \
or (n_tablename = 'f_%s' and n_tabletype = 'f_catalog'))",
	       table_name, table_name) ;

     sprintf (sql_str, "SELECT %s%s%s FROM %s WHERE %s AND n_update = 'Y' %s",
              "n_name, n_datatype, n_synonym, ",
              "n_application, n_read, n_write, n_update, n_delete, n_null, ",
              "n_checkin, n_checkout, n_seqno, n_attrno,n_tableno",
              "NFMATTRIBUTES", table_str, "ORDER BY n_tableno,n_seqno");


     status = _NFMget_attributes_from_query ( sql_str, list) ;
     if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Get attributes from query : status = <0x%.8x>\n",
                     status)) ;
         return (status) ;
       }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }


 long _NFMget_systable_attr (table_name, list, next_seq)
   char     *table_name ;
   MEMptr   *list;
   long     *next_seq ;
   {
     static char *fname = "_NFMget_systable_attr" ;
     long     status ;
     char     sql_str [2048], table_str [100];
     char     **data ;
     long     atol () ;

     _NFMdebug ((fname, "Enter\n")) ;

      sprintf (table_str, "n_tableno in (select n_tableno from nfmtables \
where n_tablename = '%s')",
	       table_name) ;

     sprintf (sql_str, "SELECT %s%s%s FROM %s WHERE %s %s",
	      "n_name, n_datatype, n_synonym, ",
	      "n_application, n_read, n_write, n_update, n_delete, n_null, ",
	      "n_checkin, n_checkout, n_seqno, n_attrno, n_tableno",
	      "NFMSYSATTRIBUTES", table_str, "ORDER BY n_tableno,n_seqno");


     status = _NFMget_attributes_from_query ( sql_str, list) ;
     if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Get attributes from query : status = <0x%.8x>\n",
                     status)) ;
         return (status) ;
       }

     status = MEMbuild_array (*list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
	ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);         
      }
     data = (char **) (*list)->data_ptr ;
     
     *next_seq = atol (data [(((*list) -> rows -1) * ((*list) -> columns)) + 11]) + 1 ;

     _NFMdebug ((fname, "SUCCESSFUL : next seq number %d : status = <0x%.8x>\n",
     *next_seq, NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

 long _NFMget_table_attr_for_appl (list, application)
   MEMptr   *list;
   MEMptr   application;
   {
     static char *fname = "_NFMget_table_attr_for_appl" ;
     long     status, i, t_basic_found, comma ;
 /* size of table_str changed from 100 to 300 - SSRS - 16/11/93 */
     char     sql_str [2048], table_str [300], tmp_str [1024], cond_str [1024];
     char     **data ;

     _NFMdebug ((fname, "ENTER\n")) ;

     status = MEMbuild_array (application) ;
     if (status != MEM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n", status));
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	 return (NFM_E_MEM) ;
       }
     
     data = (char **) application->data_ptr ;

     t_basic_found = 0 ;
     cond_str [0] = 0 ;
     tmp_str [0] = 0 ;     /* added by SSRS - 17/11/93 */
     sql_str [0] = 0 ;     /* added by SSRS - 17/11/93 */
     table_str [0] = 0 ;   /* added by SSRS - 17/11/93 */
     comma = 0 ;
     for (i=0; i<application->rows ; i++)
       {
	 if (strcmp (data [i*application->columns], "t_basic") == 0)
	   {
	     t_basic_found = 1 ;
	     sprintf (tmp_str, "(n_tabletype = 't_basic' and n_identifier = '%s') or  (n_tabletype = 't_appl' and n_identifier = '%s')",
		      data[i*application->columns+1],
		      data[i*application->columns+1]) ;
	   }
	 else if (strcmp (data [i*application->columns], "t_appl") == 0)
	   {
	     sprintf (tmp_str, "(n_tabletype = 't_appl' and n_identifier = '%s')",
		      data[i*application->columns+1]) ;
	   }

	 if (comma) strcat (cond_str, " or ") ;
	 else comma = 1 ;
	 strcat (cond_str, tmp_str) ;
       }

     if (! t_basic_found)
       {
	 _NFMdebug ((fname, "t_basic not in the buffer\n")) ;
	 ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Bad template") ;
	 return (NFM_E_MESSAGE) ;
       }
     
     sprintf (table_str, "n_tableno in (select n_tableno from nfmtables where (n_tablename = 'catalog' or n_tablename = 'f_catalog') and (%s))",
	     cond_str) ;
     
     
     sprintf (sql_str, "SELECT %s%s%s FROM %s WHERE %s %s",
	      "n_name, n_datatype, n_synonym, ",
	      "n_application, n_read, n_write, n_update, n_delete, n_null, ",
	      "n_checkin, n_checkout, n_seqno, n_attrno, n_tableno",
	      "NFMATTRIBUTES", table_str, "ORDER BY n_tableno,n_seqno");


     status = _NFMget_attributes_from_query ( sql_str, list) ;
     if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Get attributes from query : status = <0x%.8x>\n",
                     status)) ;
         return (status) ;
       }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMget_attr_no (user_id, table_type, table_name,
                      attr_name, attr_no)
   long     user_id;
   char     *table_type, *table_name;
   char     *attr_name;
   long     *attr_no;
   {
     static char *fname = "NFMget_attr_no" ;
     long     status, atol() ;
     char     sql_str [1024];
     MEMptr   list = NULL;
     char     **data;

     *attr_no = 0;
     user_id = user_id ;
     _NFMdebug ((fname, "Table Type = <%s> : Table Name = <%s> : NFM Name = <%s>\n",
		 table_type, table_name, attr_name));

     NFMlower_case (table_type, table_type) ;
     if (strcmp (table_type, "nfmsystem")) 
       {
/* per pdm - change catalog	 NFMlower_case (table_name, table_name) ; */
	 sprintf (sql_str, 
		  "%s %s WHERE %s = '%s' AND %s = '%s' AND %s = '%s' AND %s = %s",
		  "SELECT NFMATTRIBUTES.n_attrno",
		  "FROM NFMATTRIBUTES, NFMTABLES",
		  "NFMATTRIBUTES.n_name", attr_name,
		  "NFMTABLES.n_tabletype",   table_type,
		  "NFMTABLES.n_tablename",   table_name,
		  "NFMATTRIBUTES.n_tableno", "NFMTABLES.n_tableno");
       }
     else
       {
	 sprintf (sql_str, 
		  "%s %s WHERE %s = '%s' AND %s = '%s' AND %s = '%s' AND %s = %s",
		  "SELECT NFMSYSATTRIBUTES.n_attrno",
		  "FROM NFMSYSATTRIBUTES, NFMTABLES",
		  "NFMSYSATTRIBUTES.n_name", attr_name,
		  "NFMTABLES.n_tabletype",   table_type,
		  "NFMTABLES.n_tablename",   table_name,
		  "NFMSYSATTRIBUTES.n_tableno", "NFMTABLES.n_tableno");
       }

     status = SQLquery (sql_str, &list, MEM_SIZE);
     if (status != SQL_S_SUCCESS)
      {
        MEMclose (&list);
 
        if ((status ) == SQL_I_NO_ROWS_FOUND)
         {
           ERRload_struct (NFM, NFM_E_BAD_ATTR, "", NULL);
           _NFMdebug ((fname, "No Such Attr : status = <0x%.8x>\n", 
                      NFM_E_BAD_ATTR));
           return (NFM_E_BAD_ATTR);
         }

	ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n", 
		    status));
        return (NFM_E_SQL_QUERY);
      }

     status = MEMbuild_array (list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
           status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     data = (char **) list -> data_ptr;

     *attr_no = atol (data [0]);

     status = MEMclose (&list);
     if (status != MEM_S_SUCCESS)
      {
           status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }
     
     /* Changed by kumar */
     _NFMdebug ((fname, "Attr No = <%d> : SUCCESSFUL\n", *attr_no));
     return (NFM_S_SUCCESS);
   }
long NFMj_query_attributes ( table_name, table_type, nname, 
			    ret_name, attr_list )
    char   *table_name;
    char   *table_type ;
    char   *nname;
    char   *ret_name;
    MEMptr *attr_list;
{
  static char *fname = "NFMj_query_attributes" ;
    long   status;
    char   sql_string[500];

    _NFMdebug ((fname, "Table name  = <%s> : Table Type = <%s> : NFM name = <%s>\n",
		table_name, table_type, nname));
  ret_name = ret_name ;
    if (strcmp (table_type, "nfmsystem") == 0)
      {
	sprintf( sql_string, "SELECT n_name,n_datatype,n_synonym,n_application,n_read,n_write,n_update,n_delete,n_null,n_checkin,n_checkout,n_seqno,n_attrno,n_tableno FROM nfmsysattributes WHERE n_tableno IN ( SELECT n_tableno FROM nfmtables where n_tablename='%s') ", table_name );
      }
    else
      {
	sprintf( sql_string, "SELECT n_name,n_datatype,n_synonym,n_application,n_read,n_write,n_update,n_delete,n_null,n_checkin,n_checkout,n_seqno, n_attrno, n_tableno FROM nfmattributes WHERE n_tableno IN ( SELECT n_tableno FROM nfmtables where n_tablename='%s') ", table_name );
      }

  status = _NFMget_attributes_from_query ( sql_string, attr_list) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Get attributes from query : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }
  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;

}

long NFMquery_attributes ( table_name, table_type, attr_list)
    char   *table_name;
    char   *table_type ;
    MEMptr *attr_list;
{
  static char *fname = "NFMquery_attributes" ;
    long   status;
    char   sql_string[500];

    _NFMdebug ((fname, "Table name  = <%s> : Table Type = <%s>\n",
		table_name, table_type)) ;

    if (strcmp (table_type, "nfmsystem") == 0)
      {
	sprintf( sql_string, "SELECT n_name,n_datatype,n_synonym,n_application,n_read,n_write,n_update,n_delete,n_null,n_checkin,n_checkout,n_seqno,n_attrno,n_tableno FROM nfmsysattributes WHERE n_tableno IN ( SELECT n_tableno FROM nfmtables where n_tablename='%s') ", table_name );
      }
    else
      {
	sprintf( sql_string, "SELECT n_name,n_datatype,n_synonym,n_application,n_read,n_write,n_update,n_delete,n_null,n_checkin,n_checkout,n_seqno, n_attrno, n_tableno FROM nfmattributes WHERE n_tableno IN ( SELECT n_tableno FROM nfmtables where n_tablename='%s') ", table_name );
      }

  status = _NFMget_attributes_from_query ( sql_string, attr_list) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Get attributes from query : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }
  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;

}

