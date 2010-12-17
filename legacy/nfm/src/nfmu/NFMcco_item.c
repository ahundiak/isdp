#include "machine.h"
#include "NFMU.h"

extern struct NFMglobal_st NFMglobal ;

 long NFMcancel_co_item (user_id, item_list)
   long      user_id;    /* input mand. - user_id */
   MEMptr    item_list;  /* input mand. */
   {
     static char *fname = "NFMcancel_co_item" ;
     long    status   ;
     int     x ;
     char    **column, **data ;
     char    catalog_name[30], item_name[NFM_ITEMNAME + 1] ;
     char    item_rev[NFM_ITEMREV+1] ;
     MEMptr  attr_list = NULL, data_list = NULL ;
     long    NFMprep_can_co_item () ;
     long    NFMcomplete_can_co_item () ;
   
     _NFMdebug ((fname, "ENTER\n")) ;
     user_id = NFMglobal.NFMuserid ;
     status = MEMbuild_array (item_list);
     if (status != MEM_S_SUCCESS)
       {
        ERRload_struct (NFM, NFM_E_MEM, "", NULL); 
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", 
		    status));
        return (NFM_E_MEM);
      }

     column = (char **) item_list -> column_ptr;
     data   = (char **) item_list -> data_ptr;

     
     for (x = 0; x < item_list -> columns; ++x)
      {
	if (! strcmp (column [x], "n_catalogname"))
	  strcpy (catalog_name, data [x]) ;
	else if (! strcmp (column [x], "n_itemname"))
	  strcpy (item_name, data [x]) ;
	else if (! strcmp (column [x], "n_itemrev"))
	  strcpy (item_rev, data [x]) ;
      }
     
     /* catalog_name, item_name and item_rev must have valid value */

     if ((strlen (catalog_name)) && (strlen (item_name)) && (strlen (item_rev)))
       {
	 /* get check in type buffers */
	 status = NFMprep_can_co_item (user_id, catalog_name, item_name,
                                       item_rev, &attr_list, &data_list) ;
	 if (status != NFM_S_SUCCESS)
	   {
	     MEMclose (&attr_list) ;
             MEMclose (&data_list) ;
	     _NFMdebug ((fname, "Prep Can CO : status = <0x%.8x>\n", status));
	     return (status) ;
	   }

	 if (_NFMdebug_st.NFMdebug_on)
	   {
	     MEMprint_buffer ("attr_list", attr_list, _NFMdebug_st.NFMdebug_file) ;
	     MEMprint_buffer ("data_list", data_list , _NFMdebug_st.NFMdebug_file);
	   }
	 
	 /* perform cancel checkout item */
	 status = NFMcomplete_can_co_item (user_id, attr_list, data_list) ;
	 if (status != NFM_S_SUCCESS)
	   {
	     MEMclose (&attr_list) ;
             MEMclose (&data_list) ;
	     _NFMdebug ((fname, "Compl Can CO : status = <0x%.8x>\n", 
		       status));
	     return (status) ;
	   }

         MEMclose (&attr_list)  ;
         MEMclose (&data_list) ;
       }
     else 
       {
         ERRload_struct (NFM, NFM_E_BAD_ITEM, "", NULL);
	 _NFMdebug ((fname, "No Active Item : status = <0x%.8x>\n", 
		   NFM_E_BAD_ITEM));
	 return (NFM_E_BAD_ITEM) ;
       }
     
     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }



long NFMprep_can_co_item (user_id, cat_name, item_name, item_rev,
			   attr_list, data_list)
   long    user_id;    /* input mand - user_id */
   char    *cat_name ; /* input mand - catalog name */
   char    *item_name; /* input mand - item name */
   char    *item_rev;  /* input mand - item rev */
   MEMptr  *attr_list; /* output */
   MEMptr  *data_list; /* output */
{
  static char *fname = "NFMprep_can_co_item" ;
  long     status, item_no ;
  char     co_status [5] ;
  
  _NFMdebug ((fname, "Cat  Name = <%s>  : Item Name = <%s> : Item Rev = <%s>\n",
	      cat_name, item_name, item_rev));
  user_id = NFMglobal.NFMuserid ;
  status = NFMget_item_no (user_id, cat_name,
			   item_name, item_rev, &item_no);
  if (status != NFM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_BAD_ITEM, "", NULL) ;
      _NFMdebug ((fname, "Get Item No : status = <0x%.8x>\n", status));
      return (status);
    }
  
  /* check if item can be checked out*/
  status = NFMcheck_co_status (user_id, cat_name, item_no, co_status);
  if ((status != NFM_S_SUCCESS) && (status != NFM_E_ITEM_OUT))
    {
      ERRload_struct (NFM, status, "", NULL) ;
      _NFMdebug ((fname, "Check Item :Co Status = <%s> : status = <0x%.8x>\n",
		  co_status, status));
      return (status);
    }
  
  status = NFMquery_ci_attributes (user_id, cat_name,
				   attr_list, data_list);
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Get Co Attr : status = <0x%.8x>\n", status));
      return (status);
    }
  
  status = NFMget_item_ci_list (user_id, cat_name, item_no,
				"", "", "", *attr_list, *data_list, 1);
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Get Ci Attr : status = <0x%.8x>\n", status));
      return (status);        
    }
  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}

long NFMcomplete_can_co_item (user_id, attr_list, data_list)
     long    user_id;      /* input mand - user_id */
     MEMptr  attr_list;    /* input mand */
     MEMptr  data_list;    /* input mand */
{
  static char *fname = "NFMcomplete_can_co_item" ;
  long       status;
  long       row_init, row_final;
  long       item_no ;
  char       temp_cat [100];
  char       **column, **data, **data1;
  long       a, b, x, y, count;
  long       i, j, k, l, m;
  long       NFMupd_cancel_co_file ();
  long       atol() ;
  
  _NFMdebug ((fname, "ENTER\n")) ;
  user_id = NFMglobal.NFMuserid ;

  if (_NFMdebug_st.NFMdebug_on)
    {
      MEMprint_buffer ("attr_list", attr_list, _NFMdebug_st.NFMdebug_file) ;
      MEMprint_buffer ("data_list", data_list , _NFMdebug_st.NFMdebug_file);
    }

  status = MEMbuild_array (attr_list);
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		  status));
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      return (NFM_E_MEM);
    }
  
  status = MEMbuild_array (data_list);
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		  status));
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
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

  i = -1; j = -1; k = -1; l = -1; m = -1;
  
  for (x = 0; x < attr_list -> rows; ++x)
    {
      count = attr_list -> columns * x;
      
           if (! strcmp (data [count + a], "n_catalogname"))  i = x;
      else if (! strcmp (data [count + a], "n_itemno"))       j = x;
      else if (! strcmp (data [count + a], "n_type"))         k = x;
      else if (! strcmp (data [count + a], "n_status"))        l = x;
      else if (! strcmp (data [count + a], "n_fileversion"))  m = x;
    }

  row_init = 0;  row_final = data_list -> rows;
  
  sprintf (temp_cat,  "%s", data1 [i]);
  item_no = atol (data1 [j]);
  
  _NFMdebug ((fname, "catalog name %s : itemno %d\n",
	      temp_cat, item_no)) ;

  status = NFMstop_transaction (0);
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Stop Transaction : status = <%d>\n",
		status));
      return (status);
    }
  
  status = NFMupd_cancel_co_file (user_id, 
				  row_init, row_final,
				  temp_cat, item_no, attr_list, data_list); 
  if (status != NFM_S_SUCCESS)
    {
      NFMrollback_transaction (0);
      _NFMdebug ((fname, "Upd Ci Files List : status = <0x%.8x>\n",
		status));
      return (status);               
    }

  status = NFMstart_transaction (0);
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Start Transaction : status = <%d>\n",
		status));
      return (status);
    }
  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);     
}


long NFMupd_cancel_co_file (user_id, i_row, f_row,
			    cat_name, item_no, 
			    attr_list, data_list)
     long      user_id;          /* input mand - user_id */
     long      i_row, f_row;     /* input mand - first/last row in data_list */
     char      *cat_name;        /* input mand - catalog name */
     long      item_no;          /* input mand - item no */
     MEMptr    attr_list, data_list ; /* input mand -check in buffers */
{
  static char *fname = "NFMupd_cancel_co_file" ;
  long     status, atol () ;
  char     file_cat [100];
  char     **column, **data, **data1;
  char     **column3, **data3;
  long     a, b, d, x, y, z;
  long     count, count1, count3;
  long     comma, found, update;
  MEMptr   list = NULL ;
  char     *sql_str, sql_str1 [1024], value [50], message [512] ;
  
  _NFMdebug ((fname, "Init  Row  = <%d> : Final Row = <%d> : Cat Name = <%s> : Item No = <%d>\n",
	      i_row, f_row, cat_name, item_no));
  
  sprintf (file_cat, "f_%s", cat_name);

  status = MEMbuild_array (attr_list) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }

  status = MEMbuild_array (data_list) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }
  
  if (_NFMdebug_st.NFMdebug_on)
    {
      MEMprint_buffer ("attr_list", attr_list, _NFMdebug_st.NFMdebug_file) ;
      MEMprint_buffer ("data_list", data_list , _NFMdebug_st.NFMdebug_file);
    }
      
  column = (char **) attr_list -> column_ptr;
  data   = (char **) attr_list -> data_ptr;
  
  data1   = (char **) data_list -> data_ptr;
  
  a = -1; b = -1; d = -1;
  
  for (y = 0; y < attr_list -> columns; ++y)
    {
           if (! strcmp (column [y], "n_name"))          a = y;
      else if (! strcmp (column [y], "n_datatype"))      b = y;
      else if (! strcmp (column [y], "n_application"))   d = y;
    }

  status = NFMquery_attributes_definition (user_id, "F_CATALOG",
					   file_cat, &list);
  if (status != NFM_S_SUCCESS)
    {
      MEMclose (&list);
      _NFMdebug ((fname, "Qry Cat Attr : status = <0x%.8x>\n", status));
      return (status);
    }
  
  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&list);
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		  status));
      return (NFM_E_MEM);
    }
  
  column3 = (char **) list -> column_ptr;
  data3   = (char **) list -> data_ptr;
  
  sql_str = (char *) malloc (data_list -> row_size +
			     attr_list -> rows * 50 + MEM_SIZE);     
  if (! sql_str)
    {
      MEMclose (&list);
      ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
      _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC));
      return (NFM_E_MALLOC);
    }

  
  for (x = i_row; x < f_row; ++x)
    {
      count1 = data_list -> columns * x;
      comma = 0;
      sql_str  [0] = 0; sql_str1 [0] = 0;
      sprintf (sql_str,  "UPDATE %s SET ", file_cat);
      sprintf (sql_str1, " WHERE ");

      for (y = 0; y < attr_list -> rows; ++y)
	{
	  count = attr_list -> columns * y;
	  update = 0; found = 0;
	  
	  for (z = 0; ((z < list -> rows) && (! found)); ++z)
	    {
	      count3 = list -> columns * z;
	      
	      if (! strcmp (data3 [count3 + 2], data [count + a]))
		{
		  found = 1;
		  
		  if (! strcmp (data [count + a], "n_fileno"))
		    {
		      strcat (sql_str1, data3 [count3]);
		      strcat (sql_str1, " = ");
		      strcat (sql_str1, data1 [count1 + y]);
		    }
		  else if (! strcmp (data [count + a], "n_couser"))
		    {
		      if (strcmp (NFMglobal.NFMusername, data1 [count1+y]))
			{
			  strcpy (message, "Not check out user") ;
			  _NFMdebug ((fname, "%s\n", message)) ;
			  ERRload_struct (NFM, NFM_E_MESSAGE, "%s", message) ;
			  return (NFM_E_MESSAGE) ;
			}
		    }
		  else if (! strcmp (data [count + a], "n_fileco"))
		    {
		      strcpy (value, "") ;
		      update = 1;
		    }
		  else if (! strcmp (data [count + a], "n_cocomment"))
		    {
		      sprintf (value, "CO WAS CANCELED") ;
		      update = 1;
		    }
		}

	      if (update)
                {
                  if (comma) strcat (sql_str, ", ");
                  comma = 1;
		  
                  strcat (sql_str, data3 [count3]);
                  strcat (sql_str, " = ");
    
                  if (! strncmp (data3 [count3 + 1], "char", 4))
                   {
                     strcat (sql_str, "'");
                     strcat (sql_str, value);
                     strcat (sql_str, "'");
                   }
                  else
                   {
                     if (! strlen (value))
                       strcat (sql_str, "null");
                     else
                       strcat (sql_str, value);
                   }
                }
            }
	}
      
      strcat (sql_str, sql_str1);
      
      if (comma) 
	{
	  status = SQLstmt (sql_str);
	  if (status != SQL_S_SUCCESS)
	    {
	      free (sql_str);
	      MEMclose (&list) ;
              ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
	      _NFMdebug ((fname, "SQL Stmt Failed : status = <0x%.8x>\n",
			  status));
	      return (NFM_E_SQL_STMT);
	    }
	}
    }

     status = MEMclose (&list);
     if (status != MEM_S_SUCCESS)
      {
        free (sql_str);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n",
		    status));
	ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
        return (NFM_E_MEM);
      }

     status = NFMquery_attributes_definition (user_id,
              "CATALOG", cat_name, &list);
     if (status != NFM_S_SUCCESS)
      {
        free (sql_str);
        MEMclose (&list);
        _NFMdebug ((fname, "Query Table Def : status = <0x%.8x>\n",
        status));
        return (status);
      }

     status = MEMbuild_array (list);
     if (status != MEM_S_SUCCESS)
      {
        free (sql_str);
        MEMclose (&list);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        return (NFM_E_MEM);
      }

     data3 = (char **) list -> data_ptr;

     for (x = i_row; x < i_row + 1; ++x)
      {
        count1 = data_list -> columns * x;
 
        comma = 0; update = 0;

        sql_str  [0] = 0; sql_str1 [0] = 0;

        sprintf (sql_str,  "UPDATE %s SET ", cat_name);
        sprintf (sql_str1, " WHERE ");

        for (y = 0; y < attr_list -> rows; ++y)
         {
           count = attr_list -> columns * y;
           found = 0;

           for (z = 0; ((z < list -> rows) && (! found)); ++z)
            {
               count3 = list -> columns * z;

               if (! strcmp (data [count + d], "NFM"))
                {
                  if (! strcmp (data [count + a], data3 [count3 + 2]))
                   {
                     found = 1;

                     if (! strcmp (data [count + a], "n_itemno"))
                      {
                        strcat (sql_str1, data3 [count3]);
                        strcat (sql_str1, " = ");
    
                        if (! strncmp (data3 [count3 + 1], "char", 4))
                         {
                           strcat (sql_str1, "'");
                           strcat (sql_str1, data1 [count1 + y]);
                           strcat (sql_str1, "'");
                         }
                        else
                           strcat (sql_str1, data1 [count1 + y]);
                      }
                     else if (! strcmp (data [count + a], "n_status"))
                      {
                        if (comma) strcat (sql_str, ", ");
                        comma = 1;
   
                        strcat (sql_str, data3 [count3]);
                        strcat (sql_str, " = ");
    
                       if (! strncmp (data3 [count3 + 1], "char", 4))
                        {
                          strcat (sql_str, "'");

                          if ((! strcmp (data1 [count1 + y], "SN")) ||
                              (! strcmp (data1 [count1 + y], "MN")))
                            strcat (sql_str, "");
                          else
                            strcat (sql_str, "I");

                          strcat (sql_str, "'");
                        }
                      }

                     else if (! strcmp (data [count + a], "n_colevel"))
                      {
                        if (comma) strcat (sql_str, ", ");
                        comma = 1;
   
                        strcat (sql_str, data3 [count3]);
                        strcat (sql_str, " = ");
   
                        if (! strncmp (data3 [count3 + 1], "char", 4))
                         {
                           strcat (sql_str, "'");
                           strcat (sql_str, "'");
                         }
                        else
			  strcat (sql_str, "null");
                      }
                   }
                }
            }
         }

        strcat (sql_str, sql_str1);

        status = SQLstmt (sql_str);
        if (status != SQL_S_SUCCESS)
         {
            free (sql_str);
	    MEMclose (&list) ;
	    ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
            _NFMdebug ((fname, "SQL Stmt Failed : status = <0x%.8x>\n",
			status));
            return (NFM_E_SQL_STMT);
         }
      }
     
     free (sql_str);

     status = MEMclose (&list);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	_NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
	return (NFM_E_MEM);
      }
 
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }



