#include "machine.h"
#include "WF.h"

 extern struct WFstruct WFinfo;
 extern struct NFMglobal_st NFMglobal ;

 long WFquery_signoff_attributes (user_id,
                                  attr_list, data_list, value_list)
   long    user_id;
   MEMptr  *attr_list, *data_list, *value_list;
{
  char *fname = "WFquery_signoff_attributes" ;
  long     status;
  char     **column, **data, **data1;
  long     a, b, d, e, x, y, count;
  char     value [50];
  long     WFcheck_user_override ();
  
  _NFMdebug ((fname, "ENTER\n")) ;
  user_id = user_id ;
  status = NFMquery_table_attributes (NFMglobal.NFMuserid, "NFMSYSTEM",
				      "NFMSIGNOFF", attr_list, data_list, value_list);
  if (status != NFM_S_SUCCESS)
    {
      MEMclose (attr_list);
      MEMclose (data_list);
      MEMclose (value_list);
      _NFMdebug ((fname, "Query Tab Attr : status = <0x%.8x>\n",
		status));
      return (status);
    }
  
  status = MEMbuild_array (*attr_list);
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (attr_list);
      MEMclose (data_list);
      MEMclose (value_list);
      status = NFM_E_MEM;
       ERRload_struct(NFM,status,"",NULL);
      _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		status));
      return (status);
    }
  
  status = MEMbuild_array (*data_list);
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (attr_list);
      MEMclose (data_list);
      MEMclose (value_list);
      status = NFM_E_MEM;
       ERRload_struct(NFM,status,"",NULL);
      _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		status));
      return (status);
    }
  
  column = (char **) (*attr_list) -> column_ptr;
  data   = (char **) (*attr_list) -> data_ptr;
  
  data1  = (char **) (*data_list) -> data_ptr;
  
  a = -1; b = -1; e = -1; d = -1;
  
  for (y = 0; y < (*attr_list) -> columns; ++y)
    {
      if (! strcmp (column [y], "n_name"))         a = y;
      else if (! strcmp (column [y], "n_datatype"))     b = y;
      else if (! strcmp (column [y], "n_read"))         d = y;
      else if (! strcmp (column [y], "n_write"))        e = y;
    }
  
  for (x = 0; x < (*attr_list) -> rows; ++x)
    {
      count = (*attr_list) -> columns * x;
      
      if (! strcmp (data [count + a], "n_catalogno"))
	{
	  sprintf (value, "%d", WFinfo.catalog_no);
	  
	  status = MEMwrite_data (*data_list, value, 1, x + 1);
	  if (status != MEM_S_SUCCESS)
            {
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (value_list);
              status = NFM_E_MEM;
       ERRload_struct(NFM,status,"",NULL);
              _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			status));
              return (status);
            }
	}
      else if (! strcmp (data [count + a], "n_itemno"))
	{
	  sprintf (value, "%d", WFinfo.item_no);
	  
	  status = MEMwrite_data (*data_list, value, 1, x + 1);
	  if (status != MEM_S_SUCCESS)
            {
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (value_list);
              status = NFM_E_MEM;
       ERRload_struct(NFM,status,"",NULL);
              _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			status));
              return (status);
            }
	}
      else if (! strcmp (data [count + a], "n_userno"))
	{
	  sprintf (value, "%d", NFMglobal.NFMuserno) ;
	  
	  status = MEMwrite_data (*data_list, value, 1, x + 1);
	  if (status != MEM_S_SUCCESS)
            {
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (value_list);
              status = NFM_E_MEM;
       ERRload_struct(NFM,status,"",NULL);
              _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			status));
              return (status);
            }
	}
      else if (! strcmp (data [count + a], "n_signoff"))
	{
	  /* if user has override priviledges
	     then n_write, n_read attributes are set to "Y" 
             else n_write, n_read attributes are set to "N" */
	  status = WFcheck_user_override (NFMglobal.NFMuserid);
	  if (status != NFM_S_SUCCESS && status != NFM_E_NO_OVERRIDE)
            {
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (value_list);
              _NFMdebug ((fname, "Override Power : status = <0x%.8x>\n",
			status));
              return (status);
            }
	  
	  if (status == NFM_E_NO_OVERRIDE)
            {
              status = MEMwrite_data (*attr_list, "N", x + 1, d + 1);
              if (status != MEM_S_SUCCESS)
		{
		  MEMclose (attr_list);
		  MEMclose (data_list);
		  MEMclose (value_list);
		  status = NFM_E_MEM;
       ERRload_struct(NFM,status,"",NULL);
		  _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			    status));
		  return (status);
		}
	      
              status = MEMwrite_data (*attr_list, "N", x + 1, e + 1);
              if (status != MEM_S_SUCCESS)
		{
		  MEMclose (attr_list);
		  MEMclose (data_list);
		  MEMclose (value_list);
		  status = NFM_E_MEM;
       ERRload_struct(NFM,status,"",NULL);
		  _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			    status));
		  return (status);
		}
            }
	  else
	    {
	      /* user as write priviledges */
	      
	      status = MEMwrite_data (*attr_list, "Y", x + 1, d + 1);
	      if (status != MEM_S_SUCCESS)
		{
		  MEMclose (attr_list);
		  MEMclose (data_list);
		  MEMclose (value_list);
		  status = NFM_E_MEM;
       ERRload_struct(NFM,status,"",NULL);
		  _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			    status));
		  return (status);
		}
	      
	      status = MEMwrite_data (*attr_list, "Y", x + 1, e + 1);
	      if (status != MEM_S_SUCCESS)
		{
		  MEMclose (attr_list);
		  MEMclose (data_list);
		  MEMclose (value_list);
		  status = NFM_E_MEM;
                  ERRload_struct(NFM,status,"",NULL);
		  _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			    status));
		  return (status);
		}
	    }
	}
      else if (! strcmp (data [count + a], "n_reason"))
	{
	  status = MEMwrite_data (*attr_list, "Y", x+1, d+1);
	  if (status != MEM_S_SUCCESS)
            {
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (value_list);
              status = NFM_E_MEM;
       ERRload_struct(NFM,status,"",NULL);
              _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			status));
              return (status);
            }
	  status = MEMwrite_data (*attr_list, "Y", x+1, e+1);
	  if (status != MEM_S_SUCCESS)
            {
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (value_list);
              status = NFM_E_MEM;
       ERRload_struct(NFM,status,"",NULL);
              _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			status));
              return (status);
            }
	}
    }
  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}



 long WFsignoff (user_id, attr_list, data_list)
   long      user_id;
   MEMptr    attr_list, data_list;
   {
     char *fname = "WFsignoff" ;
     long    status;
     char    *sql_str, *sql_str1;
     long    a, b, x, y, count, comma;
     char    **column, **data, **data1;
     char    override[10], s_stateno [10];
     long    no_users, no_act_so ;

     _NFMdebug ((fname, "ENTER\n")) ;
     user_id = user_id ;
     status = WFvalidate_signoff_users (NFMglobal.NFMuserid);
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Valid Sign Off : status = <0x%.8x>\n",
		   status));
	 return (status);
       }

     status = WFdup_signoffs (NFMglobal.NFMuserid, WFinfo.curr_state, WFinfo.acl,
			      WFinfo.catalog_no, WFinfo.item_no,
			      &no_users, &no_act_so) ;
     if ((status != NFM_S_SUCCESS) && (status != NFM_I_SO_AUTO_PURGE)) 
       {
	 _NFMdebug ((fname, "WFget_signoffs : status = <0x%.8x>\n", 
		   status) );
	 return (status) ;
       }

     if (status == NFM_I_SO_AUTO_PURGE)
	 ERRload_struct (NFM, NFM_S_SUCCESS, NULL, NULL) ;
     
     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
        status = NFM_E_MEM;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
        return (status);
      }

     status = MEMbuild_array (data_list);
     if (status != MEM_S_SUCCESS)
      {
        status = NFM_E_MEM;
       ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
        return (status);
      }


     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     data1   = (char **) data_list -> data_ptr;

     a = -1; b = -1; 

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))         a = y;
        else if (! strcmp (column [y], "n_datatype"))     b = y;
      }

     sql_str = (char *) malloc (MEM_SIZE + attr_list -> rows * 50 +
                                data_list -> row_size);
     if (! sql_str)
      {
        status = NFM_E_MALLOC;
       ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
        return (status);
      }

     sql_str1 = (char *) malloc (MEM_SIZE + data_list -> row_size);
     if (! sql_str)
      {
        free (sql_str);
        status = NFM_E_MALLOC;
       ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
        return (status);
      }

     sprintf (sql_str,  "INSERT INTO %s (", "NFMSIGNOFF");
     sprintf (sql_str1, ") VALUES (");
     comma = 0;
     
     for (x = 0; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;
       
        if (comma)
         {
           strcat (sql_str, ", ");
           strcat (sql_str1, ", ");
         }
        comma = 1;

        if (! strcmp (data [count + a], "n_signoff"))
         {
           NFMchange_case (data1 [x], 0);

           if (strcmp (data1 [x], "Y") == 0)
	     strcpy (override, "O") ;
	   else strcpy (override, "X") ;

	   status = MEMwrite_data (data_list, override, 1, x + 1);
	   if (status != MEM_S_SUCCESS)
	     {
	       free (sql_str);
	       status = NFM_E_MEM;
	       ERRload_struct(NFM,status,"",NULL);
	       _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			 status));
	       return (status);
	     }
	 }
        else if (! strcmp (data [count + a], "n_stateno"))
         {
	   sprintf (s_stateno, "%ld", WFinfo.curr_state) ;

	   status = MEMwrite_data (data_list, s_stateno, 1, x + 1);
	   if (status != MEM_S_SUCCESS)
	     {
	       free (sql_str);
	       status = NFM_E_MEM;
	       ERRload_struct(NFM,status,"",NULL);
	       _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			 status));
	       return (status);
	     }
	 }
        else if (! strcmp (data [count + a], "n_history"))
         {
	   status = MEMwrite_data (data_list, "N", 1, x + 1);
	   if (status != MEM_S_SUCCESS)
	     {
	       free (sql_str);
	       status = NFM_E_MEM;
	       ERRload_struct(NFM,status,"",NULL);
	       _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			 status));
	       return (status);
	     }
	 }
	
        strcat (sql_str, data [count + a]);
 
        if (! strncmp (data [count  + b], "char", 4))
         {
           strcat (sql_str1, "'");
           strcat (sql_str1, data1 [x]);
           strcat (sql_str1, "'");
         }
        else
         {
           if (strlen (data1 [x]))
             strcat (sql_str1, data1 [x]);
           else
             strcat (sql_str1, "null");
         }
      }

     strcat (sql_str, sql_str1);
     strcat (sql_str, ")");

     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS)
      {
        free (sql_str);
        free (sql_str1);

        if (status == SQL_E_DUPLICATE_VALUE)
         {
           status = NFM_E_USER_SIGNED;
	   ERRload_struct(NFM,status,"",NULL);
           _NFMdebug ((fname, "User Already Signed : status = <0x%.8x>\n",
           status));
           return (status);
         }

        status = NFM_E_SQL_STMT;
       ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n", status));
        return (status);
      }

     free (sql_str);
     free (sql_str1);

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long WFcheck_user_override (user_id)
   long    user_id;
   {
     char *fname = "WFcheck_user_override" ;
     long    status;
     char    value [50];
     char    sql_str [1024];

     _NFMdebug ((fname, "ENTER\n")) ;
     user_id = user_id ;
     sprintf (sql_str, "WHERE %s = %d AND %s = %d AND %s = %d",
              "n_stateno", WFinfo.curr_state, "n_userno",
              NFMglobal.NFMuserno, "n_aclno", WFinfo.acl);

     status = NFMget_attr_value (NFMglobal.NFMuserid, "NFMSIGNOFFUSERS", "n_override",
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           status = NFM_E_BAD_SIGNOFF;
	   ERRload_struct(NFM,status,"",NULL);
           _NFMdebug ((fname, "Bad Sign Off State : status = <0x%.8x>\n",
           status));
           return (status);
         }
   
        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
        status));
        return (status);
      }

     if (strcmp (value, "Y"))
      {
        status = NFM_E_NO_OVERRIDE;
       ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "No Override Power : status = <0x%.8x>\n", status));
        return (status);
     }
     
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }



 long WFpurge_signoff (user_id, catalog_name, item_name, item_rev)
   long      user_id;
   char      *catalog_name ;
   char      *item_name ;
   char      *item_rev ;
   {
     char *fname = "WFpurge_signoff" ;
     long    status, catalog_no, item_no ;
     char    tmp_stmt[1024], sql_str [1024] ;
     long    comma;

     _NFMdebug ((fname, "ENTER\n")) ;

     user_id = user_id ;
     sprintf (sql_str, "DELETE FROM NFMSIGNOFF WHERE ") ;

     comma = 0;
     
     if ((strlen (catalog_name)) && (strlen (item_name)) && (strlen (item_rev)))
       {
	 status = WFvalidate_signoffusers_acl (NFMglobal.NFMuserid, catalog_name,
					       item_name, item_rev) ;
	 if (status != NFM_S_SUCCESS) 
	   {
	     _NFMdebug ((fname, "WFvalidate_signoffusers_acl : status : <0x%.8x>\n", status));
	     return (status) ;
	   }

	 status = NFMget_catalog_no (NFMglobal.NFMuserid, catalog_name, &catalog_no) ;
	 if (status != NFM_S_SUCCESS) 
	   {
	     status = NFM_E_BAD_CATALOG;
             ERRload_struct(NFM,status,"",NULL);
	     _NFMdebug ((fname, "Bad Cat Name : status = <0x%.8x>\n", status));
	     return (status) ;
	   }
	 
	 status = NFMget_item_no (NFMglobal.NFMuserid, catalog_name, item_name, item_rev, &item_no) ;
	 if (status != NFM_S_SUCCESS) 
	   {
	     status = NFM_E_BAD_ITEM;
             ERRload_struct(NFM,status,"",NULL);
	     _NFMdebug ((fname, "Bad Item : status = <0x%.8x>\n", status));
	     return (status) ;
	   }
	 
	 sprintf (tmp_stmt, "n_catalogno = %ld AND n_itemno = %ld \
AND n_history = 'Y'",
		  catalog_no, item_no) ;
	 
	 strcat (sql_str, tmp_stmt) ;
	 
	 status = SQLstmt (sql_str);
	 if (status != SQL_S_SUCCESS)
	   {
	     if ((status ) == SQL_I_NO_ROWS_FOUND)
	       {
		 _NFMdebug ((fname, "No rows found\n")) ;
                 ERRload_struct(NFM, NFM_E_SQL_STMT,"",NULL); 
		 return (SQL_I_NO_ROWS_FOUND) ;
	       }
	     else
	       {
		 status = NFM_E_SQL_STMT;
                 ERRload_struct(NFM,status,"",NULL);
		 _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
			   status));
		 return (status);
	       }
	   }
       }
     else 
       {
	 status = NFM_E_BAD_ITEM;
	 ERRload_struct(NFM,status,"",NULL);
	 _NFMdebug ((fname, "No Active Item : status = <0x%.8x>\n", status) );
	 return (status) ;
       }
     
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }





