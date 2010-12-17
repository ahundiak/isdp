#include "machine.h"
#include "NFMA.h"

 long NFMquery_add_user_attributes (user_id, 
                                    attr_list, data_list, value_list)
   long    user_id;
   MEMptr  *attr_list, *data_list, *value_list;
   {
     static char *fname = "NFMquery_add_user_attributes" ;
      long     status;

     _NFMdebug ((fname, "ENTER\n")) ;

     status = NFMquery_table_attributes (user_id, "NFMSYSTEM",
               "NFMUSERS", attr_list, data_list, value_list);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose (attr_list);
         MEMclose (attr_list);
         MEMclose (attr_list);
         _NFMdebug ((fname, "Qry Cond Attr : status = <0x%.8x>\n",
         status));
         return (status);
       }

      _NFMdebug ((fname, "SUCCESSFUL\n")) ;
      return (NFM_S_SUCCESS);
   }   

 long NFMadd_user (user_id, attr_list, data_list)
   long    user_id;
   MEMptr  attr_list, data_list;
   {
     static char *fname = "NFMadd_user" ;
      long      status;
      char      *sql_str, *sql_str1;
      char      value [100], e_passwd [50];
      long      x, y, count, val_exists;
      long      a, b ;
      char      **column, **data, **data1;

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

     a =-1 ; b =-1;
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
         _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", 
                    NFM_E_MALLOC));
         return (NFM_E_MALLOC);
       }
      sql_str1 [0] = 0;

      status = NFMstop_transaction (0);
      if (status != NFM_S_SUCCESS)
       {
         free (sql_str);
         free (sql_str1);
         _NFMdebug ((fname, "Stop Transaction : status = <0x%.8x>\n",
         status));
         return (status);
       }

      sprintf (sql_str,  "INSERT INTO NFMUSERS (");
      sprintf (sql_str1, ") VALUES (");

      for (x = 0; x < attr_list -> rows; ++x)
       {
         count = attr_list -> columns * x;
         val_exists = 0;

         if (! strcmp (data [count + a], "n_passwd"))
          {
            value [0] = 0; e_passwd [0] = 0;

            status = NFMencrypt (data1 [x], e_passwd);
            if (status != NFM_S_SUCCESS)
             {
               free (sql_str);
               free (sql_str1);
               NFMrollback_transaction (0);
               ERRload_struct (NFM, NFM_E_NET, "", NULL);
               _NFMdebug ((fname, "Encrypt Failed : status = <0x%.8x>\n",
			   status));
               return (status);
             }

            status = NFMparse_string (e_passwd, value);
            if (status != NFM_S_SUCCESS)
             {
               free (sql_str);
               free (sql_str1);
               NFMrollback_transaction (0);
               ERRload_struct (NFM, NFM_E_INVALID_PASSWD, "", NULL);
               _NFMdebug ((fname, "Parse Passwd : status = <0x%.8x>\n",
               NFM_E_INVALID_PASSWD));
               return (NFM_E_INVALID_PASSWD);
             }
            
            val_exists = 1;
          }  
         else if (! strcmp (data [count + a], "n_username"))
          {
            if (! strlen (data1 [x]))
             {
               free (sql_str);
               free (sql_str1);
               NFMrollback_transaction (0);
               ERRload_struct (NFM, NFM_E_NULL_USER, "", NULL);
               _NFMdebug ((fname, "User Name Is Null : status = <0x%.8x>\n",
               NFM_E_NULL_USER));
               return (NFM_E_NULL_USER);
             }
          }  
         else if (! strcmp (data [count + a], "n_userno"))
          {
            status = NFMget_serial_slot (user_id, "nfmusers",
                     data [count + a], &val_exists);
            if (status != NFM_S_SUCCESS)
             {
               free (sql_str);
               free (sql_str1);
               NFMrollback_transaction (0);
               _NFMdebug ((fname, "Get Node No : status = <0x%.8x>\n",
               status));
               return (status);
             }

            sprintf (value, "%d", val_exists);

            val_exists = 0;

            status = MEMwrite_data (data_list, value, 1, x + 1);
            if (status != MEM_S_SUCCESS)
             {
               free (sql_str);
               free (sql_str1);
               NFMrollback_transaction (0);
               ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               _NFMdebug ((fname, "Get Node No : status = <0x%.8x>\n",
			   status));
               return (NFM_E_MEM);
             }  
          }

         if (x)
          {
            strcat (sql_str,  ", ");
            strcat (sql_str1, ", ");
          }

         strcat (sql_str, data [count + a]);
 
         if (! strncmp (data [count + b], "char", 4))
          {
            strcat (sql_str1, "'");
            if (val_exists)
              strcat (sql_str1, value); 
            else
              strcat (sql_str1, data1 [x]); 
            strcat (sql_str1, "'");
          }
         else
          {
            if (val_exists)
             {
               if (strlen (value))
                 strcat (sql_str1, value); 
               else
                 strcat (sql_str1, "null");
             }
            else
             {
               if (strlen (data1 [x]))
                 strcat (sql_str1, data1 [x]); 
               else
                 strcat (sql_str1, "null");
             }
          }
       }

      strcat (sql_str, sql_str1);
      strcat (sql_str, ")");

      free (sql_str1);

      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
       {
         free (sql_str);
         NFMrollback_transaction (0);

         if (status == SQL_E_DUPLICATE_VALUE)
          {
            ERRload_struct (NFM, NFM_E_DUP_USER, "", NULL);
            _NFMdebug ((fname, "User Exists : status = <0x%.8x>\n", 
                       NFM_E_DUP_USER));
            return (NFM_E_DUP_USER);         
          }

         ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
         _NFMdebug ((fname, "Sql Syntax : status = <0x%.8x>\n", 
		     status)) ;
	 return (NFM_E_SQL_STMT);         
       }

/******* 11/20/90, remove all use and references to the nfmlocaltables *******

      status = NFMupdate_local_tables (user_id, "M", 
               "NFMSYSTEM", "NFMACLUSERS");
      if (status != NFM_S_SUCCESS)
       {
         free (sql_str);
         NFMrollback_transaction (0);
         _NFMdebug ((fname, "Upd Lcl Table : status = <0x%.8x>\n",
         status));
         return (status);         
       }

      status = NFMupdate_local_tables (user_id, "M", 
               "NFMSYSTEM", "NFMSIGNOFFUSERS");
      if (status != NFM_S_SUCCESS)
       {
         free (sql_str);
         NFMrollback_transaction (0);
         _NFMdebug ((fname, "Upd Lcl Table : status = <0x%.8x>\n",
         status));
         return (status);         
       }
 ******* END  ------ 11/20/90 ************************************************/


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
