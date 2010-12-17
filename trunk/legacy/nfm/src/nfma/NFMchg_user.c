#include "machine.h"
#include "NFMA.h"

  extern struct NFMglobal_st NFMglobal ;

long NFMquery_change_user_attributes ( user_id, user_name, attr_list,
				       data_list, value_list )
    long   user_id;
    char   *user_name;
    MEMptr *attr_list;
    MEMptr *data_list;
    MEMptr *value_list;
{
  static char *fname = "NFMquery_change_user_attributes" ;
    long   status;
    int    r;
    int    c;
    char   sql_string[500];
    char   **data;
    MEMptr dbuff  = NULL;

  _NFMdebug ((fname, "Node_name=<%s>", user_name ));

  status = NFMquery_add_user_attributes (NFMglobal.NFMuserid,
					 attr_list, data_list, value_list) ;
  if( status != NFM_S_SUCCESS )
    {
      _NFMdebug ((fname, "Qry  Attr : status < 0x%.8x >\n",
		  status));
      return( status );
    }

    status = MEMbuild_array( *attr_list ) ;
    if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMbuild_array : data_list : status = <0x%.8x>\n",
                    status)) ;
        ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        return (NFM_E_MEM) ;
      }

    status = MEMbuild_array( *data_list );
    if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMbuild_array : data_list : status = <0x%.8x>\n",
                    status)) ;
        ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        return (NFM_E_MEM) ;
      }

    data = (char**) (*attr_list)->data_ptr;

/*  Load attribute names into query string 
 */
    strcpy( sql_string, "SELECT " );
    for( r=0; r < (*attr_list)->rows; ++r )
    {
	c = (*attr_list)->columns * r;
	strcat( sql_string, data[c] );
	if( (r+1) < (*attr_list)->rows )
	    strcat( sql_string, ", " );
    } 
    strcat( sql_string, " FROM NFMUSERS WHERE n_username = '" );
    strcat( sql_string, user_name );
    strcat( sql_string, "'" );

    status = SQLquery( sql_string, &dbuff, MEM_SIZE ) ;
    if( status != SQL_S_SUCCESS)
    {
        _NFMdebug ((fname, "SQLquery = < 0x%.8x >\n", status));
        MEMclose( &dbuff );
	return(NFM_E_SQL_QUERY);
    }

    status = MEMbuild_array ( dbuff ) ;
    if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMbuild_array dbuff : status = <0x%.8x>\n",
                    status));
        ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        return (NFM_E_MEM) ;
      }

    data = (char **) dbuff->data_ptr ;

    for( r=0; r < (*attr_list)->rows; ++r )
    {
        status = MEMwrite_data ( *data_list, data[r], 1, r+1) ;
        if (status != MEM_S_SUCCESS)
          {
            ERRload_struct (NFM, NFM_E_MEM, "", "") ;
            _NFMdebug ((fname, "MEMwrite_data : status = <0x%.8x>\n",
                        status)) ;
            return (NFM_E_MEM) ;
          }
    }

    _NFMdebug ((fname, "SUCCESSFUL\n")) ;
    return( NFM_S_SUCCESS );
}


 long NFMchange_user (user_id, attr_list, data_list)
   long    user_id;
   MEMptr  attr_list;
   MEMptr  data_list;
   {
     static char *fname = "NFMchange_user" ;
      long      status;
      long      x; 
      long	y; 
      long	count; 
      long	val_exists;
      long      a; 
      long  	b; 
      long      d;
      int       comma ;
      char      value [100];
      char	temp_str[100];

      char      *sql_str; 

      char      **column; 
      char	**data; 
      char	**data1;

     _NFMdebug ((fname, "ENTER\n")) ;
      status = MEMbuild_array (attr_list);
      if (status != MEM_S_SUCCESS)
       {
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		     status));
         return (NFM_E_MEM);         
       }

      status = MEMbuild_array (data_list);
      if (status != MEM_S_SUCCESS)
       {
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		     status));
         return (NFM_E_MEM);         
       }

      column = (char **) attr_list -> column_ptr;
      data   = (char **) attr_list -> data_ptr;

      data1  = (char **) data_list -> data_ptr;

      for (y = 0; y < attr_list -> columns; ++y)
       {
              if (! strcmp (column [y], "n_name"))      a = y;
         else if (! strcmp (column [y], "n_datatype"))  b = y;
	 else if (! strcmp (column [y], "n_update"))    d = y;
       }

      sql_str = (char *) malloc (MEM_SIZE + attr_list -> rows * 50 + 
                                 data_list -> row_size);
      if (! sql_str)
       {
         ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", 
		     NFM_E_MALLOC));
         return (NFM_E_MALLOC);
       }
      sql_str [0] = 0;

      status = NFMstop_transaction (0);
      if (status != NFM_S_SUCCESS)
       {
         free (sql_str);
         _NFMdebug ((fname, "Stop Transaction : status = <0x%.8x>\n",
         status));
         return (status);
       }

      sprintf (sql_str,  "UPDATE NFMUSERS SET ");
      comma = 0 ;

      for (x = 0; x < attr_list -> rows; ++x)
       {
         count = attr_list -> columns * x;
         val_exists = 0;

         if (! strcmp (data [count + a], "n_passwd"))
          {
            sprintf( value, "%s", data1[x] );
            val_exists = 1;
          }  
         else if (! strcmp (data [count + a], "n_username"))
          {
            if (! strlen (data1 [x]))
             {
               free (sql_str);
               NFMrollback_transaction (0);
	       ERRload_struct (NFM, NFM_E_NULL_USER, "", NULL);
               _NFMdebug ((fname, "User Name Is Null : status = <0x%.8x>\n",
               NFM_E_NULL_USER));
               return (NFM_E_NULL_USER);
             }
          }  
         else if (! strcmp (data [count + a], "n_userno"))
          {
	    sprintf (temp_str, " WHERE %s = %s", data[count+a],data1[x]);
	    continue;
          }

	 if (! strcmp (data [count + d], "Y"))
	   {
	     if (comma)
	       strcat (sql_str,  ", ");
	     else comma = 1 ;

	     strcat (sql_str, data [count + a]);
	     strcat (sql_str, "=" );
	     
	     if (! strncmp (data [count + b], "char", 4))
	       {
		 strcat (sql_str, "'");
		 if (val_exists)
		   strcat (sql_str, value); 
		 else
		   strcat (sql_str, data1 [x]); 
		 strcat (sql_str, "'");
	       }
	     else
	       {
		 if (val_exists)
		   {
		     if (strlen (value))
		       strcat (sql_str, value); 
		     else
		       strcat (sql_str, "null");
		   }
		 else
		   {
		     if (strlen (data1 [x]))
		       strcat (sql_str, data1 [x]); 
		     else
		       strcat (sql_str, "null");
		   }
	       }
	   }
       }

      strcat (sql_str, temp_str );

      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
       {
         free (sql_str);
         NFMrollback_transaction (0);
         ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
         _NFMdebug ((fname, "Sql Syntax : status = <0x%.8x>\n", status));
         return (NFM_E_SQL_STMT);         
       }

      free (sql_str);

      status = NFMstart_transaction (0);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Start Transaction : status = <0x%.8x>\n",
         status));
         return (status);
       }

      _NFMdebug ((fname, "SUCCESSFUL\n")) ;
      return (NFM_S_SUCCESS);
   }
