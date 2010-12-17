#include "machine.h"
#include "CMDTOOLS.h"

  extern struct NFMglobal_st NFMglobal ;
/* making this a global will avoid duplication of _NFMadd_storage_area code */
  char   STORAGEAREA_NAME [NFM_SANAME+1] ;

 long _NFMadd_storage_area (user_id, attr_list, data_list)
   long    user_id;
   MEMptr  attr_list, data_list;
   {
      char *fname = "_NFMadd_storage_area" ;
      long      status, passwd_field ;
      char      *sql_str, *sql_str1, tmp_str [200] ;
      char      **column, **data, **data1;
      long      x, y, count, comma ;
      long      a, b, sano, sano_pos, saname_pos, type_pos ;
      char      value [100], temp_str [200], e_passwd [50] ;
      char      temp_sa_name [NFM_SANAME+1] ;
      char      n_type [NFM_TYPE+1], n_pathname [NFM_PATHNAME+1] ;
      char      n_nodeno [20], n_devicetype [NFM_DEVICETYPE+1] ;
      char      n_username [NFM_USERNAME+1] ;
      char      n_nfs [NFM_NFS+1], message [512] ;
      MEMptr    sql_buffer = NULL ;

     _NFMdebug ((fname, "ENTER\n")) ;
      STORAGEAREA_NAME [0] = 0 ;
      status = MEMbuild_array (attr_list);
      if (status != MEM_S_SUCCESS)
       {
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		     status)) ;
         return (NFM_E_MEM);         
       }

      status = MEMbuild_array (data_list);
      if (status != MEM_S_SUCCESS)
       {
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		     status)) ;
         return (NFM_E_MEM);         
       }

      column = (char **) attr_list -> column_ptr;
      data   = (char **) attr_list -> data_ptr;

      data1  = (char **) data_list -> data_ptr;

     a = -1; b = -1;
      for (y = 0; y < attr_list -> columns; ++y)
       {
              if (! strcmp (column [y], "n_name"))      a = y;
         else if (! strcmp (column [y], "n_datatype"))  b = y;
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

      sql_str1 = (char *) malloc (MEM_SIZE + data_list -> row_size);
      if (! sql_str1)
       {
         free (sql_str);
         ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Malloc Failed\n")) ;
         return (NFM_E_MALLOC);
       }
      sql_str1 [0] = 0;

      status = NFMset_autocommit_off (0) ;
      if (status != NFM_S_SUCCESS)
	{
	  free (sql_str);
	  free (sql_str1);
	  _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",
		      status));
	  return (status);
	}

      sprintf (sql_str,  "INSERT INTO NFMSTORAGEAREA (");
      sprintf (sql_str1, ") VALUES (");
      comma = 0 ; passwd_field = 0 ;

      sano_pos = -1;  saname_pos = -1; type_pos = -1 ;

      for (x = 0; x < attr_list -> rows; ++x)
       {
         count = attr_list -> columns * x;

         if (! strcmp (data [count + a], "n_sano"))
          {
	    sano_pos = x ;
            status = NFMget_serial_slot (user_id, "nfmstoragearea",
                     data [count + a], &sano);
            if (status != NFM_S_SUCCESS)
             {
               free (sql_str);
               free (sql_str1);
               NFMrollback_transaction (0);
               _NFMdebug ((fname, "Serial No : status = <0x%.8x>\n",
               status));
               return (status);
             }

            sprintf (temp_sa_name, "ta-%d", sano);

/************* mms - no **********
            status = MEMwrite_data (data_list, temp_sa_name, 1, x + 1);
            if (status != MEM_S_SUCCESS)
             {
               free (sql_str);
               free (sql_str1);
               NFMrollback_transaction (0);
               ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			   status));
               return (NFM_E_MEM);
             }
**********************************/
          }
         else if (! strcmp (data [count + a], "n_saname"))
	   saname_pos = x;
	 else if (! strcmp (data [count + a], "n_type"))
	   {
	     NFMupper_case (data1 [x], data1 [x]) ;
	     type_pos = x ;
	   }
       }
      
      if (! strcmp (data1 [type_pos], "T"))
	{
	  status = MEMwrite_data (data_list, temp_sa_name, 1, saname_pos + 1);
	  if (status != MEM_S_SUCCESS)
	    {
	      free (sql_str);
	      free (sql_str1);
	      NFMrollback_transaction (0);
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	      _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			  status));
	      return (NFM_E_MEM);
	    }            
	}


      for (x = 0; x < attr_list -> rows; ++x)
	{
	  count = attr_list -> columns * x;
	  
	  if (! strcmp (data [count + a], "n_sano"))
	    {
/******** already done this - mms *********
	      status = NFMget_serial_slot (user_id, "nfmstoragearea",
					   data [count + a], &sano) ;
	      if (status != NFM_S_SUCCESS)
		{
		  free (sql_str);
		  free (sql_str1);
		  NFMrollback_transaction (0) ;
		  _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",
			      status));
		  return (status);
		}
***************************************/	      
	      sprintf (value, "%d", sano) ;
	      
	      status = MEMwrite_data (data_list, value, 1, x + 1);
	      if (status != MEM_S_SUCCESS)
		{
		  free (sql_str);
		  free (sql_str1);
		  NFMrollback_transaction (0) ;
		  ERRload_struct (NFM, NFM_E_MEM, "", NULL);
		  _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			      status));
		  return (NFM_E_MEM);
		}
	    }
         else if (! strcmp (data [count + a], "n_passwd"))
	   {
	     value [0] = 0; e_passwd [0] = 0;
	     
	     status = NFMencrypt (data1 [x], e_passwd);
	     if (status != NFM_S_SUCCESS)
	       {
		 free (sql_str);
		 free (sql_str1);
		 NFMrollback_transaction (0) ;
		 _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",
			     status));
		 return (status) ;
	       }
	     
	     status = NFMparse_string (e_passwd, value);
	     if (status != NFM_S_SUCCESS)
	       {
		 free (sql_str);
		 free (sql_str1);
		 NFMrollback_transaction (0) ;
		 ERRload_struct (NFM, NFM_E_INVALID_PASSWD, "", NULL);
		 _NFMdebug ((fname, "Parse Passwd : status = <0x%.8x>\n",
			     NFM_E_INVALID_PASSWD));
		 return (NFM_E_INVALID_PASSWD);
	       }
	     passwd_field = 1 ;
	   }  
         else if (! strcmp (data [count + a], "n_username"))
	   {
	     strcpy (n_username, data1 [x]) ;
            if (! strlen (data1 [x]))
             {
               free (sql_str);
               free (sql_str1);
               ERRload_struct (NFM, NFM_E_NULL_USER, "", NULL); 
               _NFMdebug ((fname, "Null User Name : status = <0x%.8x>\n",
               NFM_E_NULL_USER));
               return (NFM_E_NULL_USER);
             }
          }  
         else if (! strcmp (data [count + a], "n_pathname"))
	   {
	     strcpy (n_pathname, data1 [x]) ;
          }  
         else if (! strcmp (data [count + a], "n_saname"))
          {
            if (! strlen (data1 [x]))
             {
               free (sql_str);
               free (sql_str1);
	       NFMrollback_transaction (0) ;
               ERRload_struct (NFM, NFM_E_NULL_STORAGE, "",
                                        NULL);
               _NFMdebug ((fname, "Null SA Name : status = <0x%.8x>\n",
               NFM_E_NULL_STORAGE));
               return (NFM_E_NULL_STORAGE);
             }             
	    else
	      {
		strcpy (STORAGEAREA_NAME, data1 [x]) ;
	      }
          }  
         else if (! strcmp (data [count + a], "n_devicetype"))
          {
	    NFMupper_case (data1 [x], data1 [x]) ;
	    strcpy (n_devicetype, data1 [x]) ;
            status = NFMcheck_device_type (data1 [x]);
            if (status != NFM_S_SUCCESS)
             {
               free (sql_str);
               free (sql_str1);
	       NFMrollback_transaction (0) ;
               _NFMdebug ((fname, "Failure : Device is Bad : status = <0x%.8x>\n",
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
                  free (sql_str1);
		  NFMrollback_transaction (0) ;
                  ERRload_struct (NFM, NFM_E_MEM, "", NULL);
                  _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			      status));
                  return (NFM_E_MEM);
                }  
             }
            else if((strcmp(data1[x],"T")) == 0 )
	      {
               status = MEMwrite_data (data_list, "W", 1, x + 1);
               if (status != MEM_S_SUCCESS)
		 {
                  free (sql_str);
                  free (sql_str1);
                  NFMrollback_transaction (0);
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
                     temp_str, value);
             if (status != NFM_S_SUCCESS)
             {
               _NFMdebug ((fname, "Failed to retrieve n_nfs value\n"));
   	       free (sql_str);
	       free (sql_str1);
	       NFMrollback_transaction (0) ;
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
	       free (sql_str1);
               NFMrollback_transaction (0);
               ERRload_struct (NFM, NFM_E_AS_NFS, "", NULL);
               return (NFM_E_AS_NFS);
             }
	   }
         else if (! strcmp (data [count + a], "n_owner"))
          {
	    if (! strlen (data1 [x]))
	      {
		sprintf (value, "%ld", NFMglobal.NFMuserno) ;
		status = MEMwrite_data (data_list, value, 1, x + 1);
		if (status != MEM_S_SUCCESS)
		  {
		    free (sql_str);
		    free (sql_str1);
		    NFMrollback_transaction (0) ;
		    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
		    return (NFM_E_MEM);
		  }  
	      }
          }  
         else if (! strcmp (data [count + a], "n_nodeno"))
          {
	    strcpy (n_nodeno, data1 [x]) ;
            sprintf (temp_str, "WHERE %s = %s", "n_nodeno", data1 [x]);

            status = NFMget_attr_value (user_id, "NFMNODES", "n_nodeno",
                     temp_str, value);
            if (status != NFM_S_SUCCESS)
             {
               free (sql_str);
               free (sql_str1);

               if (status == NFM_I_BAD_CONDITION)
                {
                  ERRload_struct (NFM, NFM_E_BAD_NODE, "", NULL);
		  NFMrollback_transaction (0) ;
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
               free (sql_str1);
	       NFMrollback_transaction (0) ;
               ERRload_struct (NFM, NFM_E_BAD_NODE, "", NULL);
               _NFMdebug ((fname, "Bad Node : status = <0x%.8x>\n",
               NFM_E_BAD_NODE));
               return (NFM_E_BAD_NODE);
             }
	  }

         if (comma)
          {
            strcat (sql_str,  ", ");
            strcat (sql_str1, ", ");
          }
	  else comma = 1 ;

         strcat (sql_str, data [count + a]);
 
         if (! strncmp (data [count + b], "char", 4))
          {
            strcat (sql_str1, "'");
            if (passwd_field)
	      {
		strcat (sql_str1, value) ;
		passwd_field = 0 ;
	      }
            else
              strcat (sql_str1, data1 [x]);
            strcat (sql_str1, "'");
          }
         else
	   {
	     if (strlen (data [x]))
	       strcat (sql_str1, data1 [x]); 
	     else
	       strcat (sql_str1, "null");
	   }
	}

      strcat (sql_str, sql_str1);
      strcat (sql_str, ")");

      free (sql_str1);

      _NFMdebug ((fname, "n_type %s : n_nfs %s : n_pathname %s\n",
		  n_type, n_nfs, n_pathname)) ;

      if ((strcmp (n_type, "I") == 0) && (strcmp (n_nfs, "Y") == 0) &&
	  (strcmp (n_pathname, "") == 0))
	{
	  NFMrollback_transaction (0) ;
	  _NFMdebug ((fname, "Failure : Path can not be NULL for NFS INTERNAL SA\n")) ;
	  ERRload_struct (NFM, NFM_E_PATH_NOT_BE_NULL_FOR_NFS, "", "");
	  return (NFM_E_PATH_NOT_BE_NULL_FOR_NFS) ;
	}


      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
       {
         free (sql_str);
	 NFMrollback_transaction (0) ;

         if (status  == SQL_E_DUPLICATE_VALUE)
          {
	    sprintf (tmp_str, "select n_sano, n_saname from nfmstoragearea \
where n_nodeno = %s and n_pathname = '%s' and n_devicetype = '%s'",
		     n_nodeno, n_pathname, n_devicetype) ;
	    status = SQLquery (tmp_str, &sql_buffer, MEM_SIZE) ;
	    if (status == SQL_S_SUCCESS)
	      {
		status = MEMbuild_array (sql_buffer) ;
		if (status == MEM_S_SUCCESS)
		  {
		    data = (char **) sql_buffer -> data_ptr ;
		    MEMwrite_data (data_list, data [0], 1, sano_pos + 1);
		    MEMwrite_data (data_list, data [1], 1, saname_pos + 1);
		    strcpy (STORAGEAREA_NAME, data [1]) ;
		  }
	      }

	    if (_NFMdebug_st.NFMdebug_on)
	      {
		MEMprint_buffer ("data list", data_list, _NFMdebug_st.NFMdebug_file) ;
	      }

	    _NFMdebug ((fname, "duplicate saname <%s>\n",
			STORAGEAREA_NAME)) ;
            ERRload_struct (NFM, NFM_E_DUP_ST_AREA, "", NULL);
            _NFMdebug ((fname, "User Exists : status = <0x%.8x>\n",
		      NFM_E_DUP_ST_AREA));
            return (NFM_E_DUP_ST_AREA);         
          }

         ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
         _NFMdebug ((fname, "Sql Syntax : status = <0x%.8x>\n", 
		     status));
         return (NFM_E_SQL_STMT);         
       }

      free (sql_str);

      status = NFMset_autocommit_on (0) ;
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "Failure : status <0x%.8x>\n",
		      status)) ;
	  return (status) ;
	}
      if (_NFMdebug_st.NFMdebug_on)
	{
	  MEMprint_buffer ("data list", data_list, _NFMdebug_st.NFMdebug_file) ;
	}

      _NFMdebug ((fname, "SUCCESSFUL : storagearea name <%s>\n",
		  STORAGEAREA_NAME)) ;
      return (NFM_S_SUCCESS);
   }



long _NFMadd_return_sa_name (attr_list, data_list, saname)
     MEMptr  attr_list, data_list;
     char    *saname ;
{
  char *fname = "_NFMadd_return_sa_name" ;
  long status ;
  
  _NFMdebug ((fname, "ENTER\n")) ;
  status =  _NFMadd_storage_area (NFMglobal.NFMuserid,
				  attr_list, data_list) ;
  
  if ((status != NFM_S_SUCCESS) && (status != NFM_E_DUP_ST_AREA))
    {
      _NFMdebug ((fname, "Failure : storage area failed : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }
  
  strcpy (saname, STORAGEAREA_NAME) ;
  _NFMdebug ((fname, "storagearea name <%s>\n", saname)) ;
  if (status != NFM_S_SUCCESS)
    return (status) ;
  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}


