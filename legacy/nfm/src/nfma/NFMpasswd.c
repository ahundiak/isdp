#include "machine.h"
#include "NFMA.h"

  extern struct NFMglobal_st NFMglobal ;

/**************************************************************************
 *                                                                        *
 *     Function:   NFMchange_storage_area_passwd.                         *
 *     Date    :   April 12, 1990                                         *
 *                                                                        *
 *                 This function is used to change an existing storage    *
 *                 area password in NFM.                                  * 
 **************************************************************************/

int NFMchange_storage_area_passwd (user_id, st_name, old_passwd, new_passwd)
   long    user_id;
   char    *st_name;
   char    *old_passwd, *new_passwd;
   {
     static char *fname = "NFMchange_storagea_area_passwd" ;
      long      status;
      char      *sql_str;
      char      *sql_str1;
      char      **data;
      char      e_old_passwd [50], e_new_passwd [50];
      char      p_passwd[50];
      MEMptr    sql_buffer = NULL;

      _NFMdebug ((fname, "St   Name   = <%s> : Old Paswd = <%s> : New Paaswd = <%s>\n", 
		  st_name, old_passwd, new_passwd)) ;

      e_old_passwd [0] = 0; e_new_passwd [0] = 0;

      sql_str = (char *) malloc (2 * MEM_SIZE);
      if (sql_str == NULL)
       {
         ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC));
         return (NFM_E_MALLOC);
       }  
      sql_str[0] = 0;

      sql_str1 = (char *) malloc (MEM_SIZE);
      if (sql_str1 == NULL)
       {
         free (sql_str);
         ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC));
         return (NFM_E_MALLOC);
       }  
      sql_str1[0] = 0;

     sprintf (sql_str, 
	      "SELECT %s.%s, %s.%s, %s.%s FROM %s, %s WHERE %s.%s = '%s'",
	      "NFMNODES", "n_nodename", "NFMSTORAGEAREA", "n_username",
	      "NFMSTORAGEAREA", "n_passwd", "NFMNODES", "NFMSTORAGEAREA",
	      "NFMSTORAGEAREA", "n_saname", st_name);

      sprintf (sql_str1, " AND %s.%s = %s.%s", "NFMNODES", "n_nodeno",
               "NFMSTORAGEAREA", "n_nodeno");

      strcat (sql_str, sql_str1);
      free (sql_str1);

      status = SQLquery (sql_str, &sql_buffer, 512);
      if (status != SQL_S_SUCCESS)
       {
         free (sql_str);
         MEMclose (&sql_buffer);
         if ((status) == SQL_I_NO_ROWS_FOUND)
          {
         ERRload_struct (NFM, NFM_E_BAD_ST_AREA, "", NULL);
             _NFMdebug ((fname, "No Such St Area : status = <0x%.8x>\n",
             NFM_E_BAD_ST_AREA)) ;
             return (NFM_E_BAD_ST_AREA);
          }

         ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
         _NFMdebug ((fname, "SQL Query Failed : status = <0x%.8x>\n", status));
         return ( NFM_E_SQL_QUERY);
       }

      status = MEMbuild_array (sql_buffer);
      if (status != MEM_S_SUCCESS)
       {
         free (sql_str);
         MEMclose (&sql_buffer);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);
       }

      data = (char **) sql_buffer->data_ptr;
      
/*
      status = NFMfile_connect (data[0], data[1], data[2], NULL);
      if (status != NFM_S_SUCCESS)
       {
         free (sql_str);
         MEMclose (&sql_buffer);
         ERRload_struct (NFM, NFM_E_NET, "", NULL);
         _NFMdebug ((fname, "Cannot Connect w/Login : status = <0x%.8x>\n",
	 status)) ;
         return (status);      
       }

      status = NFMdisconnect ();
      if (status != NFM_S_SUCCESS)
       {
         free (sql_str);
         MEMclose (&sql_buffer);
         ERRload_struct (NFM, NFM_E_NET, "", NULL);
         _NFMdebug ((fname, "NETfile Disconnect Failed  : status = <0x%.8x>\n",
	 status));
         return (status);
       }
*/

      status = NFMdecrypt (data [2], e_old_passwd);
      if (status != NFM_S_SUCCESS)
       {
         free (sql_str);
         MEMclose (&sql_buffer);
         _NFMdebug ((fname, "NET Decrypt Passwd : status = <0x%.8x>\n",
         status));
         return (status);         
       }

      status = MEMclose (&sql_buffer);
      if (status != MEM_S_SUCCESS)
       {
         free (sql_str);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEMclose Failed : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);         
       }

      if (strcmp (old_passwd, e_old_passwd))
       {
         free (sql_str);
         ERRload_struct (NFM, NFM_E_INVALID_PASSWD, "", NULL);
         _NFMdebug ((fname, "Bad Passwd : status = <0x%.8x>\n", NFM_E_INVALID_PASSWD));
         return (NFM_E_INVALID_PASSWD);         
       }

      status = NFMencrypt (new_passwd, e_new_passwd);
      if (status != NFM_S_SUCCESS)
       {
         free (sql_str);
         ERRload_struct (NFM, NFM_E_NET, "", NULL);
         _NFMdebug ((fname, "NET Encrypt Failed : status = <0x%.8x>\n",NFM_E_NET));
         return (status);
       }

      status = NFMparse_string (e_new_passwd, p_passwd);
      if (status != NFM_S_SUCCESS)
       {
         free (sql_str);
         _NFMdebug ((fname, "NFMparse_string Failed : status = <0x%.8x>\n",
                   status));
         return (status);
       }

     sprintf (sql_str, "UPDATE %s SET %s = '%s' WHERE %s = ",
	      "NFMSTORAGEAREA", "n_passwd", p_passwd, "n_saname");

     strcat (sql_str, "'");
     strcat (sql_str, st_name);
     strcat (sql_str, "'");

      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
       {
         free (sql_str);
         ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
         _NFMdebug ((fname, "Sql Stmt : status = <0x%.8x>\n", status));
         return (NFM_E_SQL_STMT);         
       }

      free (sql_str);

      _NFMdebug ((fname, "SUCCESSFUL\n")) ;
      return (NFM_S_SUCCESS);
   }



/**************************************************************************
 *                                                                        *
 *     Function:   NFMchange_user_passwd.                                 *
 *     Date    :   April 12, 1990                                         *
 *                                                                        *
 *                 This function is used to change an existing users      *
 *                 password in NFM.                                       * 
 *                                                                        *
 *                 if the user_name is given the passwd will be changed   *
 *                 for the user specified in user_name, otherwise the     *
 *                 passwd will be changed for the user specified in       *
 *                 user_id.                                               *
 *                                                                        *
 **************************************************************************/

 int NFMchange_user_passwd (user_id, user_name, old_passwd, new_passwd)
   long    user_id;
   char    *user_name;
   char    *old_passwd, *new_passwd;
   {
     static char *fname = "NFMchange_user_passwd" ;
      long      status;
      char      *sql_str; 
      char      user_no [20];
      char      **data;
      char      e_passwd [50];
      char      p_passwd [50];
      MEMptr    sql_buffer = NULL;

      _NFMdebug ((fname, "user name   = <%s>  : old passwd = <%s> : new passwd = <%s>\n", 
		  user_name, old_passwd, new_passwd));


      sql_str = (char *) malloc (2 * MEM_SIZE);
      if (sql_str == NULL)
       {
         ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC));
         return (NFM_E_MALLOC);
       }  
      sql_str[0] = 0;

      if (! strcmp (user_name, ""))  /* update user user_id */
       {
          sprintf (user_no, "%d", NFMglobal.NFMuserno) ;

	  sprintf (sql_str, "SELECT %s FROM %s WHERE %s = %s", 
		   "n_passwd", "NFMUSERS", "n_userno", user_no);
          
          status = SQLquery (sql_str, &sql_buffer, 256);
          if (status != SQL_S_SUCCESS)
           {
             free (sql_str);
             MEMclose (&sql_buffer); 
             if ((status) == SQL_I_NO_ROWS_FOUND)
             {
                ERRload_struct (NFM, NFM_E_BAD_USER, "", NULL);
                status = NFM_E_BAD_USER;
             }
             else
             {
                ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
                status = NFM_E_SQL_QUERY;
             }
             _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status));
             return (status);
           }  
         
          status = MEMbuild_array (sql_buffer);
          if (status != MEM_S_SUCCESS)
           {
             free (sql_str);
             MEMclose (&sql_buffer); 
             _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n", status));
             return (status);
           }  

          data = (char **) sql_buffer->data_ptr;
          e_passwd[0] = 0; 

          status = NFMdecrypt (data[0], e_passwd); 
          if (status != NFM_S_SUCCESS)
           {
             free (sql_str);
             MEMclose (&sql_buffer); 
             _NFMdebug ((fname, "NETdecrypt : status = <0x%.8x>\n", status));
             return (status);
           }  

          if (strcmp (old_passwd, e_passwd))
           {
             free (sql_str);
         ERRload_struct (NFM, NFM_E_INVALID_PASSWD, "", NULL);
             MEMclose (&sql_buffer); 
             _NFMdebug ((fname, "Invalid Passwd : status = <0x%.8x>\n", NFM_E_INVALID_PASSWD));
             return (NFM_E_INVALID_PASSWD);
           }  

          status = MEMclose (&sql_buffer);
          if (status != MEM_S_SUCCESS)
           {
             free (sql_str);
             _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n", status));
             return (status);
           }  
       
          e_passwd[0] = 0;

          status = NFMencrypt (new_passwd, e_passwd);
          if (status != NFM_S_SUCCESS)
           {
             free (sql_str);
             _NFMdebug ((fname, "NETencrypt : status = <0x%.8x>\n", status));
             return (status);
           }  

           status = NFMparse_string (e_passwd, p_passwd);
           if (status != NFM_S_SUCCESS)
            {
              free (sql_str);
              _NFMdebug ((fname, "NFMparse_string Failed : status = <0x%.8x>\n",
                        status));
              return (status);
            }
        
	  sprintf (sql_str, "UPDATE %s SET %s = '%s' WHERE %s = ",
		   "NFMUSERS", "n_passwd", p_passwd, "n_userno"); 

	  strcat (sql_str, user_no); 
       }
      else
       {
          e_passwd[0] = 0;

          status = NFMencrypt (new_passwd, e_passwd);
          if (status != NFM_S_SUCCESS)
           {
             free (sql_str);
             _NFMdebug ((fname, "NETencrypt : status = <0x%.8x>\n", status));
             return (status);
           }  

           status = NFMparse_string (e_passwd, p_passwd);
           if (status != NFM_S_SUCCESS)
            {
              free (sql_str);
              _NFMdebug ((fname, "NFMparse_string Failed : status = <0x%.8x>\n",
                        status));
              return (status);
            }

	  sprintf (sql_str, "UPDATE %s SET %s = '%s' WHERE %s = ",
		   "NFMUSERS", "n_passwd", p_passwd, "n_username"); 

	  strcat (sql_str, "'"); 
	  strcat (sql_str, user_name); 
	  strcat (sql_str, "'"); 
       }

       status = SQLstmt (sql_str);
       if (status != SQL_S_SUCCESS)
        {
          free (sql_str);

	  if ((status) == SQL_I_NO_ROWS_FOUND)
	    {
	      _NFMdebug ((fname, "Bad User = <0x%.8x>\n",
			NFM_E_BAD_USER) );
	      ERRload_struct (NFM, NFM_E_BAD_USER, "", NULL);
	      return (NFM_E_BAD_USER) ;
	    }
	  
	  ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
          _NFMdebug ((fname, "SQL Stmt : status = <0x%.8x>\n", status));
          return (NFM_E_SQL_STMT);         
        }

       free (sql_str);

      _NFMdebug ((fname, "SUCCESSFUL\n")) ;
      return (NFM_S_SUCCESS);
   }

 
