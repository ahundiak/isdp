#include "machine.h"
#include "NFMA.h"

  extern struct NFMglobal_st NFMglobal ;

long NFMquery_change_sa_attributes ( user_id, sa_name, attr_list,
				     data_list, value_list )
    long   user_id;
    char   *sa_name;
    MEMptr *attr_list;
    MEMptr *data_list;
    MEMptr *value_list;
{
    static char *fname = "NFMquery_change_sa_attributes" ;
    long   status;
    int    r;
    int    c;
    char   sql_string[500];
    char   **data;
    MEMptr dbuff  = NULL;

    _NFMdebug ((fname, "St_name=<%s>", sa_name ));
    user_id = user_id ;
    status = NFMquery_add_st_area_attributes (NFMglobal.NFMuserid, attr_list,
					      data_list, value_list);
    if (status != NFM_S_SUCCESS)
      {
	_NFMdebug ((fname, "Qry ADD St Area Attributes : status = <0x%.8x>\n",
		    status)) ;
	return (status) ;
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
    strcat( sql_string, " FROM NFMSTORAGEAREA WHERE n_saname = '" );
    strcat( sql_string, sa_name );
    strcat( sql_string, "'" );

    status = SQLquery( sql_string, &dbuff, MEM_SIZE ) ;
    if (status != SQL_S_SUCCESS) 
    {
      MEMclose( &dbuff );
      _NFMdebug ((fname, "SQLquery = < 0x%.8x >\n", status));
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
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

    status = MEMclose (&dbuff) ;
    if (status != MEM_S_SUCCESS)
      {
	_NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n",
		    status)) ;
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	return (NFM_E_MEM) ;
      }

    _NFMdebug ((fname, "SUCCESSFUL\n")) ;
    return( NFM_S_SUCCESS );
}

 long NFMchange_storage_area (user_id, attr_list, data_list)
   long    user_id;
   MEMptr  attr_list;
   MEMptr  data_list;
   {
      static char *fname = "NFMchange_storage_area" ;
      long      status;
      long	val_exists;
      long      x; 
      long      y; 
      long      count;
      long      a; 
      long      b; 
      long      d;
      long      i; 
      long      j;
      int       comma ;

      char      value [100]; 
      char      temp_str1[200];
      char	temp_str2[200] ;

      char      *sql_str; 

      char      **column; 
      char      **data; 
      char      **data1;
      char      n_type [NFM_TYPE+1], n_pathname [NFM_PATHNAME+1] ;
      char      n_nfs [NFM_NFS+1] ;

      _NFMdebug ((fname, "ENTER\n")) ;

      status = MEMbuild_array (attr_list);
      if (status != MEM_S_SUCCESS)
       {
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
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

      a = -1; d =-1; b =-1 ;
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


      sprintf (sql_str,  "UPDATE NFMSTORAGEAREA SET ");

      i = -1;  j = -1;

      for (x = 0; x < attr_list -> rows; ++x)
       {
         count = attr_list -> columns * x;

         if (! strcmp (data [count + a], "n_sano"))
          {
	    sprintf (temp_str2, " WHERE %s = %s ", data[count+a],data1[x]);
	    continue;
          }
         else if (! strcmp (data [count + a], "n_saname"))
          i = x;
         else if (! strcmp (data [count + a], "n_type"))
          j = x;
       }

      comma = 0 ;

      for (x = 0; x < attr_list -> rows; ++x)
       {
         count = attr_list -> columns * x;
         val_exists = 0;

         if (! strcmp (data [count + a], "n_passwd"))
          {
            sprintf( value, "%s", data1[x]);
            val_exists = 1;
          }  
         else if (! strcmp (data [count + a], "n_username"))
          {
            if (! strlen (data1 [x]))
             {
               free (sql_str);
               ERRload_struct (NFM, NFM_E_NULL_USER, "", NULL);
               _NFMdebug ((fname, "Null User Name : status = <0x%.8x>\n",
               NFM_E_NULL_USER));
               return (NFM_E_NULL_USER);
             }
          }  
         else if (! strcmp (data [count + a], "n_saname"))
          {
            if (! strlen (data1 [x]))
             {
               free (sql_str);
               ERRload_struct (NFM, NFM_E_NULL_STORAGE, "", NULL);
               _NFMdebug ((fname, "Null SA Name : status = <0x%.8x>\n",
               NFM_E_NULL_STORAGE));
               return (NFM_E_NULL_STORAGE);
             }             
          }  
         else if (! strcmp (data [count + a], "n_devicetype"))
          {
            NFMupper_case (data1 [x], data1 [x]) ;
            status = NFMcheck_device_type (data1 [x]);
            if (status != NFM_S_SUCCESS)
             {
               free (sql_str);
               _NFMdebug ((fname, "Device Is Bad : status = <0x%.8x>\n",
               status));
               return (status);
             }             
          }  
         else if (! strcmp (data [count + a], "n_type"))
          {
	    NFMupper_case (data1 [x], data1 [x]) ;
	    strcpy (n_type, data1 [x]) ;
            if (! strlen (data1 [x]))
             {
               status = MEMwrite_data (data_list, "I", 1, x + 1);
               if (status != MEM_S_SUCCESS)
                {
                  free (sql_str);
                  ERRload_struct (NFM, NFM_E_MEM, "", NULL);
                  _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			      status));
                  return (NFM_E_MEM);

                }  
             }
          }  
         else if (! strcmp (data [count + a], "n_nfs"))
          {
            status = NFMget_attr_value (user_id, "NFMNODES", "n_nfs",
                     temp_str1, value);
            if (status != NFM_S_SUCCESS)
            {
              _NFMdebug ((fname, "Failed to retrieve n_nfs value\n"));
              free (sql_str);
              ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
                    "Failed to retrieve NFS information from the Node\n");
              return (status);
            }
            NFMupper_case (data1 [x], data1 [x]) ;
            strcpy (n_nfs, data1 [x]) ;
            if (!strcmp (value, "N") && !strcmp (n_nfs, "Y"))
            {
              _NFMdebug ((fname,
                          "Storage cannot be added using n_nfs = <y>\n\
                          because node does not allow n_nfs\n"));
              free (sql_str);
              NFMrollback_transaction (0);
              ERRload_struct (NFM, NFM_E_CS_NFS, "", NULL);
              return (NFM_E_CS_NFS);
            }
          }  
         else if (! strcmp (data [count + a], "n_pathname"))
          {
	    strcpy (n_pathname, data1 [x]) ;
          }  

         else if (! strcmp (data [count + a], "n_nodeno"))
          {
            sprintf (temp_str1, "WHERE %s = %s", "n_nodeno", data1 [x]);

            status = NFMget_attr_value (user_id, "NFMNODES", "n_nodeno",
                     temp_str1, value);
            if (status != NFM_S_SUCCESS)
             {
               free (sql_str);

               if (status == NFM_I_BAD_CONDITION)
                {
                  ERRload_struct (NFM, NFM_E_BAD_NODE, "", NULL);
                  _NFMdebug ((fname, "Bad Node : status = <0x%.8x>\n",
                  NFM_E_BAD_NODE));
                  return (NFM_E_BAD_NODE);
                }

               _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
               status));
               return (status);
             }
  
            if (strcmp (data1 [x], value))
             {
               free (sql_str);
               ERRload_struct (NFM, NFM_E_BAD_NODE, "", NULL);
               _NFMdebug ((fname, "Bad Node : status = <0x%.8x>\n",
               NFM_E_BAD_NODE));
               return (NFM_E_BAD_NODE);
             }
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
		    if (strlen (data [x]))
		      strcat (sql_str, data1 [x]); 
		    else
		      strcat (sql_str, "null");
		  }
	      }
	  }
      }

      strcat (sql_str, temp_str2);
      _NFMdebug ((fname, "n_type %s : n_nfs %s : n_pathname %s\n",
		  n_type, n_nfs, n_pathname)) ;

      if ((strcmp (n_nfs, "Y") == 0) && (strcmp (n_type, "I") == 0) &&
	  (strcmp (n_pathname, "") == 0))
	{
	  _NFMdebug ((fname, "Failure : path can not be NULL for NFS INTERNAL SA\n")) ;
	  ERRload_struct (NFM, NFM_E_PATH_NOT_BE_NULL_FOR_NFS, "", "") ;
	  return (NFM_E_PATH_NOT_BE_NULL_FOR_NFS) ;
	}
	  

      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
       {
         free (sql_str);

         ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
  	 _NFMdebug ((fname, "Sql Syntax : status = <0x%.8x>\n", status));
         return (NFM_E_SQL_STMT);         
       }

      free (sql_str);

      _NFMdebug ((fname, "SUCCESSFUL\n")) ;
      return (NFM_S_SUCCESS);
   }
