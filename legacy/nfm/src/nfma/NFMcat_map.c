#include "machine.h"
#include "NFMA.h"
#include "WFstruct.h"

 extern struct WFstruct WFinfo;

 long NFMquery_catalog_acl_map (user_id, cat_name,
                               attr_list, data_list, value_list)
   long      user_id;
   char      *cat_name;
   MEMptr    *attr_list, *data_list, *value_list;
   {
     static char *fname = "NFMquery_catalog_acl_map";
     long     status;
     long     a, b, d, x, y, count;
     long     tab_no;
     MEMptr   list = NULL;
     char     **column, **data;
     char     *sql_str, sql_str1 [1024], value [50] ;
     long     column_of_valueno, row_of_aclno, row_of_cat_no ;

     _NFMdebug ((fname, "Cat  Name = <%s>\n", cat_name));
     row_of_aclno = -1; row_of_cat_no = -1; column_of_valueno = -1;
     status = NFMget_catalog_no (user_id, cat_name, &tab_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Cat No : status = <0x%.8x>\n",
        status));
        return (status);
      }

     if (WFinfo.catalog_no != tab_no)
      {
        ERRload_struct (NFM, NFM_E_BAD_CATALOG, "", NULL);
        _NFMdebug ((fname, "Check Cat No : status = <0x%.8x>\n",
        NFM_E_BAD_CATALOG));
        return (NFM_E_BAD_CATALOG);
      }

     status = NFMquery_table_attributes (user_id, "NFMSYSTEM",
              "NFMCATALOGACLMAP", attr_list, data_list, value_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        _NFMdebug ((fname, "Qry Tab Attr : status = <0x%.8x>\n",
		  status));
        return (status);
      }

     status = MEMbuild_array (*attr_list);
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

     column = (char **) (*attr_list) -> column_ptr;
     data   = (char **) (*attr_list) -> data_ptr;

     a = -1; b = -1; d = -1;

     for (y = 0; y < (*attr_list) -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))        a = y;
        else if (! strcmp (column [y], "n_datatype"))    b = y;
        else if (! strcmp (column [y], "n_synonym"))     d = y;
	else if (! strcmp (column [y], "n_valueno"))  column_of_valueno = y +1 ;
      }

     status = MEMclose (data_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     sql_str = (char *) malloc ((*attr_list) -> rows * 50 + 
                        (*attr_list) -> row_size + MEM_SIZE);
     if (! sql_str)
      {
        MEMclose (attr_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
        NFM_E_MALLOC));
        return (NFM_E_MALLOC);
      }

     sprintf (sql_str,  "SELECT ");
     sprintf (sql_str1, " FROM %s WHERE ", "NFMCATALOGACLMAP");

     for (x = 0; x < (*attr_list) -> rows; ++x)
      {
         count = (*attr_list) -> columns * x;

         if (! strcmp (data [count + a], "n_catalogno"))
          {
	    row_of_cat_no = x + 1;
            strcat (sql_str1, data [count + a]);
            strcat (sql_str1, " = ");
      
            sprintf (value, "%d", WFinfo.catalog_no);

            if (! strncmp (data [count + b], "char", 4))
             {
               strcat (sql_str1, "'");
               strcat (sql_str1, value);
               strcat (sql_str1, "'");
             }
            else
               strcat (sql_str1, value);
          }
         else if (! strcmp (data [count + a], "n_aclno"))
          {
	    row_of_aclno = x + 1;
	  }

         if (x) strcat (sql_str, ", ");

         strcat (sql_str, data [count + a]);
      }

     strcat (sql_str, sql_str1);

     status = SQLquery (sql_str, &list, MEM_SIZE);
     if ((status != SQL_S_SUCCESS) &&
         ((status ) != SQL_I_NO_ROWS_FOUND))
      {
        free (sql_str);
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Qry Syntax : status = <0x%.8x>\n",
		    status));
        return (NFM_E_SQL_QUERY);
      }

     sql_str [0] = 0;

     for (y = 0; y < (*attr_list) -> columns; ++y)
      {
             if (y == a) strcat (sql_str, "n_status");
        else if (y == b) strcat (sql_str, "char(15)");
        else if (y == d) strcat (sql_str, "STATUS");

        strcat (sql_str, "\1");
      }

     status = MEMwrite (*attr_list, sql_str);
     if (status != MEM_S_SUCCESS)
      {
        free (sql_str);
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     free (sql_str);

     status = MEMbuild_array (*attr_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     column = (char **) (*attr_list) -> column_ptr;
     data   = (char **) (*attr_list) -> data_ptr;

     status = MEMopen (data_list, MEM_SIZE);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     for (x = 0; x < (*attr_list) -> rows; ++x)
      {
        count = (*attr_list) -> columns * x;

        status = MEMwrite_format (*data_list,
                 data [count + a], data [count + b]);;
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (&list);
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);
	   ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);
         }
      }

     status = MEMbuild_array (list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     data = (char**) list -> data_ptr;

     sql_str = (char *) malloc ((*data_list) -> row_size);
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

     for (x = 0; x < list -> rows; ++x)
      {
        count = list -> columns * x;

        sql_str [0] = 0;

        for (y = 0; y < list -> columns; ++y)
         {
            strcat (sql_str, data [count + y]);
            strcat (sql_str, "\1");
         }
 
        strcat (sql_str, "\1");

        status = MEMwrite (*data_list, sql_str);
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

     status = MEMclose (&list);
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
     
     strcpy (sql_str1, "select nfmacls.n_aclno, nfmworkflow.n_workflowname, nfmacls.n_aclname from NFMACLS, NFMWORKFLOW \
where nfmworkflow.n_workflowno = nfmworkflow.n_workflowno AND \
nfmworkflow.n_workflowno = nfmacls.n_workflowno AND \
nfmworkflow.n_workflowname != 'NFM_SDP_WORKFLOW' AND \
nfmworkflow.n_workflowname != 'NFM_CATALOG_WORKFLOW' AND \
nfmworkflow.n_workflowname != 'NFM_PROJECT_WORKFLOW' AND \
nfmworkflow.n_workflowname != 'NFM_ADMIN_WORKFLOW' \
order by nfmacls.n_aclno") ;

     status = _NFMadd_to_value_list_from_query (attr_list,
						value_list,
						sql_str1,
						row_of_aclno,
						column_of_valueno) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Corrupted value buffer : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }

     sprintf (sql_str1, "select n_catalogno, n_catalogname from nfmcatalogs \
where n_catalogno = %d order by n_catalogno",
	      tab_no) ;

     status = _NFMadd_to_value_list_from_query (attr_list,
						value_list,
						sql_str1,
						row_of_cat_no, 
						column_of_valueno) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Corrupted value buffer : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);      
   }

 long NFMupdate_catalog_acl_map (user_id, attr_list, data_list)
   long      user_id;
   MEMptr    attr_list, data_list;
   {     
     static char *fname = "NFMupdate_catalog_acl_map" ;
     long    status;
     long    a, b, i, x, y, count;
     char    **column, **data, **data1;
     char    tab_no [50] ;
     long    NFMadd_catalog_acl_map ();
     long    NFMdrop_catalog_acl_map ();
      
     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array: status = <0x%.8x>\n", 
		    status));
        return (NFM_E_MEM);      
      }

     status = MEMbuild_array (data_list);
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array: status = <0x%.8x>\n", 
		    status));
        return (NFM_E_MEM);      
      }

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     data1  = (char **) data_list -> data_ptr;

     a = -1; b = -1; i = -1;

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))       a = y;
        else if (! strcmp (column [y], "n_datatype"))   b = y;
      }

     
     for (x = 0; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;
  
        if (! strcmp (data [count + a], "n_catalogno"))   i = x;
      }

     sprintf (tab_no, "%d", WFinfo.catalog_no);


     for (x = 0; x < data_list -> rows; ++x)
      {
        count = data_list -> columns * x;

        status = MEMwrite_data (data_list, tab_no, x + 1, i + 1);    
        if (status != MEM_S_SUCCESS)
         {
	   ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n", 
		       status));
           return (NFM_E_MEM);      
         }
      }
 
     status = NFMstop_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Stop Trans  : status = <0x%.8x>\n", 
        status));
        return (status);      
      }

     status = NFMadd_catalog_acl_map (user_id, attr_list, data_list);
     if (status != NFM_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "Add Cat Acl Map : status = <0x%.8x>\n", 
        status));
        return (status);      
      }

     status = NFMdrop_catalog_acl_map (user_id, attr_list, data_list);
     if (status != NFM_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "Drop Cat Acl Map : status = <0x%.8x>\n", 
        status));
        return (status);      
      }


     status = NFMstart_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Start Transaction : status = <0x%.8x>\n",
        status));
        return (status);      
      }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);      
   }
  
 long NFMadd_catalog_acl_map (user_id, attr_list, data_list)
   long    user_id;
   MEMptr  attr_list, data_list;
   {
     static char *fname = "NFMadd_catalog_acl_map";
     long   status, cat_no;
     char   **column, **data, **data1;
     char   itemname [NFM_ITEMNAME+1], itemrev [NFM_ITEMREV+1] ;
     long   map_no;
     char   value [50], cat_name [50], aclmap_str[100], str[100];
     long   a, b, i, x, y, count, count1, comma, j, k;
     char   *sql_str, *sql_str1, *acl_str ;
     MEMptr return_buffer = NULL;

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     data1  = (char **) data_list -> data_ptr;

     if (data_list ->rows == 0)
       {
	 _NFMdebug ((fname, "No Acls Found in buffer to be added to cat mapping\n"));
	 ERRload_struct (NFM, NFM_E_NO_ACL_MAP_FOUND_FOR_CAT, "", NULL) ;
	 return (NFM_E_NO_ACL_MAP_FOUND_FOR_CAT) ;
       }

     a = -1; b = -1; i = -1;

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))     a = y;
        else if (! strcmp (column [y], "n_datatype")) b = y;
      }

     j = -1; j = -1; k = -1;

     for (x = 0; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;
  
             if (! strcmp (data [count + a], "n_status"))    i=x;
	else if (! strcmp (data [count + a], "n_catalogno")) j=x;
	else if (! strcmp (data [count + a], "n_aclno"))     k=x;
      }

     cat_no = (long) atol(data1 [j]);

     status = NFMget_catalog_name (user_id, cat_no, cat_name) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "BAD CATALOG : status = <0x%.8x>\n", status));
	 return (status) ;
       }

     /* Allocating 50 more bytes as acl_str size is insufficient some times
        SSRS 2 Mar 94 */
     acl_str = (char *) malloc (data_list->rows * 50 + 150) ;
     if (acl_str == NULL)
       {
	 _NFMdebug ((fname, "Malloc Failed (acl_str)\n"));
	 ERRload_struct (NFM, NFM_E_MALLOC, "", NULL) ;
	 return (NFM_E_MALLOC) ;
       }

     sprintf (acl_str, "SELECT n_aclno, n_itemname, n_itemrev from %s WHERE ", 
	      cat_name) ;

     sprintf (aclmap_str,
	      " AND n_aclno NOT IN (SELECT n_aclno FROM NFMCATALOGACLMAP \
WHERE n_catalogno = %d)", cat_no) ;

     comma = 0 ;

     for (x = 0; x < data_list -> rows; ++x)
      {
        count = data_list -> columns * x;

        if (! strcmp (data1 [count + i], "ADD"))
	  {
	    if (!comma)
	      {
		sprintf (str, " n_aclno != %s", data1 [count+k]) ;
		comma = 1 ;
	      }
	    else
	      sprintf (str, " AND n_aclno != %s", data1 [count+k]) ;
	    _NFMdebug ((fname, "concataning %s\n", str));
	    strcat (acl_str, str) ;
	  }
      }

     if (comma)
       {
	 strcat (acl_str, aclmap_str) ;
	/* is any of the item of this catalog do not follow the new acls */
	 status = SQLquery (acl_str, &return_buffer, MEM_SIZE);
	 if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
	   {
             free (acl_str) ;
	     _NFMdebug ((fname, "SQL query ERROR : status = <0x%.8x>\n",
		       status));
	     return (NFM_E_SQL_QUERY) ;
	   }

	 if (status != SQL_I_NO_ROWS_FOUND)
	   {
             free (acl_str) ;
	     status = MEMbuild_array (return_buffer) ;
	     if (status == MEM_S_SUCCESS)
	       {
		 data = (char **) return_buffer-> data_ptr ;
		 strcpy (itemname, data [1]) ;
		 strcpy (itemrev, data [2]) ;
	       }
	     MEMclose (&return_buffer) ;
	     _NFMdebug ((fname,"Item %s : Revision %s does not follow one of the specified ACLs : status = <0x%.8x>\n", 
			 itemname, itemrev, status)) ;
	     ERRload_struct (NFM, NFM_E_ITEM_NOT_FOLLOW_ACL, "%s %s", 
			     itemname, itemrev);
	     return (NFM_E_ITEM_NOT_FOLLOW_ACL) ;
	   }

	 status = MEMclose (&return_buffer) ;
	 if (status != MEM_S_SUCCESS)
	   {
             free (acl_str);
	     _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n", status));
	     ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
	     return (NFM_E_MEM) ;
	   }
       }

    _NFMdebug ((fname, "after sql statement SSRS 28 Feb 94\n"));
     free (acl_str) ;

     sql_str = (char *) malloc (attr_list -> rows * 50 +
                                data_list -> row_size + MEM_SIZE);
     if (! sql_str)
      {
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
        NFM_E_MALLOC));
        return (NFM_E_MALLOC);
      }

     sql_str1 = (char *) malloc (data_list -> row_size + MEM_SIZE);
     if (! sql_str1)
      {
        free (sql_str);
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
        NFM_E_MALLOC));
        return (NFM_E_MALLOC);
      }

     for (y = 0; y < data_list -> rows; ++y)
      {
        count1 = data_list -> columns * y;

        NFMupper_case (data1 [count1 + i], data1 [count1 + i]) ;

        if (! strcmp (data1 [count1 + i], "ADD"))
         {
           sprintf (sql_str,  "INSERT INTO %s (", "NFMCATALOGACLMAP");
           sprintf (sql_str1, ") VALUES (");

           comma = 0;

           for (x = 0; x < attr_list -> rows; ++x)
            {
              count = attr_list -> columns * x;

              if (x != i)
               {
                 if (! strcmp (data [count + a], "n_mapno"))
                  {
                    status = NFMget_serial_slot (user_id,
                             "nfmcatalogaclmap",
                             data [count + a], &map_no);
                    if (status != NFM_S_SUCCESS)
                     {
                       free (sql_str);
                       free (sql_str1);
                       _NFMdebug ((fname, "Serl No : status = <0x%.8x>\n",
                       status));
                       return (status);
                     }

                    sprintf (value, "%d", map_no);

                    status = MEMwrite_data (data_list, value,
                             y + 1, x + 1);
                    if (status != MEM_S_SUCCESS)
                     {
                       free (sql_str);
                       free (sql_str1);
		       ERRload_struct (NFM, NFM_E_MEM, "", NULL);
                       _NFMdebug ((fname, "Wr Data : status = <0x%.8x>\n",
				   status));
                       return (NFM_E_MEM);
                     }
                  }

                 if (comma)
                  {
                    strcat (sql_str,  ", ");
                    strcat (sql_str1, ", ");
                  }
                 comma = 1;

                 strcat (sql_str, data [count + a]);
  
                 if (! strncmp (data [count + b], "char", 4))
                  {
                    strcat (sql_str1, "'");
                    strcat (sql_str1, data1 [count1 + x]);
                    strcat (sql_str1, "'");
                  }
                 else
                  {
                    if (strlen (data1 [count1 + x]))
                       strcat (sql_str1, data1 [count1 + x]);
                    else
                       strcat (sql_str1, "null");
                  }
               }
            }

           strcat (sql_str, sql_str1);
           strcat (sql_str, ")");

           status = SQLstmt (sql_str);
           if ((status != SQL_S_SUCCESS) &&
               (status != SQL_E_DUPLICATE_VALUE))
            {
              free (sql_str);
              free (sql_str1);
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "Stmt Synt : status = <0x%.8x>\n",
			  status));
              return (NFM_E_SQL_STMT);
            }
         }
      }

     free (sql_str);
     free (sql_str1);

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

 long NFMdrop_catalog_acl_map (user_id, attr_list, data_list)
   long    user_id;
   MEMptr  attr_list, data_list;
   {
     static char *fname = "NFMdrop_catalog_acl_map";
     long   status;
     long   NFMupdate_catalog_state ();
     int    drop,comma;
     char   **column, **data, **data1;
     char   value [50] ;
     char   cat_name[50];
     long   a, b, i, j, x, y, count,k,l, cat_no;
     char   sql_str [1024], str [100], *acl_str;
     MEMptr return_buffer = NULL;

     drop = 0;
     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     data1  = (char **) data_list -> data_ptr;

     if (data_list -> rows < 1)
     {
        return (NFM_S_SUCCESS);
     }

     a = -1; b = -1;  i = -1; j = -1;

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))     a = y;
        else if (! strcmp (column [y], "n_datatype")) b = y;
      }


     i = -1; j = -1; k = -1; l = -1;

     for (x = 0; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;
  
             if (! strcmp (data [count + a], "n_status"))    i = x;
        else if (! strcmp (data [count + a], "n_mapno"))     j = x;
        else if (! strcmp (data [count + a], "n_catalogno")) k = x;
        else if (! strcmp (data [count + a], "n_aclno"))     l = x;
      }


     cat_no = (long)  atol (data1 [k]) ;
     status = NFMget_catalog_name (user_id, cat_no, cat_name) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "BAD CATALOG : status = <0x%.8x>\n", status)) ;
	 return (status) ;
       }

     acl_str = (char *) malloc (data_list->rows * 50) ;
     if (acl_str == NULL)
       {
	 _NFMdebug ((fname, "Malloc Failed (acl_str)\n"));
	 ERRload_struct (NFM, NFM_E_MALLOC, "", NULL) ;
	 return (NFM_E_MALLOC) ;
       }

     sprintf (acl_str, "SELECT n_aclno from %s \
WHERE ", cat_name) ;

     comma = 0 ;

     for (x = 0; x < data_list -> rows; ++x)
      {
        count = data_list -> columns * x;

        if (! strcmp (data1 [count + i], "DROP"))
	  {
	    if (!comma)
	      {
		sprintf (str, " n_aclno = %s", data1 [count+l]) ;
		comma = 1 ;
	      }
	    else
	      sprintf (str, " OR n_aclno = %s", data1 [count+l]) ;
	    strcat (acl_str, str) ;
	  }
      }

     if (comma)
       {
	/* is any of the item of this catalog follow the new acls */
	 status = SQLquery (acl_str, &return_buffer, MEM_SIZE);
	 if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
	   {
             free (acl_str);
	     _NFMdebug ((fname, "SQL query ERROR : status = <0x%.8x>\n",
		       status));
	     return (NFM_E_SQL_QUERY) ;
	   }

	 if (status != SQL_I_NO_ROWS_FOUND)
	   {
             free (acl_str);
	     MEMclose (&return_buffer) ;
	     _NFMdebug ((fname, "An item follows one of the deleted ACLs : status = <0x%.8x>\n", status)) ;
	     ERRload_struct (NFM, NFM_E_ITEM_FOLLOWS_ACL, "", NULL) ;
	     return (NFM_E_ITEM_FOLLOWS_ACL) ;
	   }

	 status = MEMclose (&return_buffer) ;
	 if (status != MEM_S_SUCCESS)
	   {
             free (acl_str);
	     _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n", status));
	     ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
	     return (NFM_E_MEM) ;
	   }
       }

     free(acl_str) ;


     for (y = 0; y < data_list -> rows; ++y)
      {
        count = data_list -> columns * y;

        NFMupper_case (data1 [count + i], data1 [count+i]) ;

        if (! strcmp (data1 [count + i], "DROP"))
         {
           drop = 1;
/*           if (! strncmp (n_dtype, "char", 4))
              sprintf (sql_str, "WHERE %s = '%s'",
                       n_attr, data1 [count + j]);
           else
              sprintf (sql_str, "WHERE %s = %s",
                       n_attr, data1 [count + j]);
 */
           sprintf (sql_str, "WHERE n_mapno = %s", data1 [count + j]) ;

           status = NFMget_attr_value (user_id, "NFMPROJECTACLMAP",
                    "COUNT(*)", sql_str, value);
           if (status != NFM_S_SUCCESS && status != NFM_I_BAD_CONDITION)
            {
               _NFMdebug ((fname, "Atr Value : status = <0x%.8x>\n",
               status));
               return (status);
            }

           if (atol (value) > 0)
            {
	      ERRload_struct (NFM, NFM_E_PROJ_ACL_MAP_EXISTS, "", NULL);
	      _NFMdebug ((fname, "Proj Map Exists : status = <0x%.8x>\n",
			  NFM_E_PROJ_ACL_MAP_EXISTS));
	      return (NFM_E_PROJ_ACL_MAP_EXISTS);
            }

           if (! strncmp (data [(attr_list -> columns * j) + b],
                          "char", 4))
              sprintf (sql_str, "DELETE FROM %s WHERE %s = '%s'",
                       "NFMCATALOGACLMAP", 
                       data [(attr_list -> columns * j) + a], 
                       data1 [count + j]);
           else
              sprintf (sql_str, "DELETE FROM %s WHERE %s = %s",
                       "NFMCATALOGACLMAP", 
                       data [(attr_list -> columns * j) + a], 
                       data1 [count + j]);

           status = SQLstmt (sql_str);
           if (status != SQL_S_SUCCESS)
            {
              if ((status) == SQL_I_NO_ROWS_FOUND)
               {
		 ERRload_struct (NFM, NFM_E_BAD_CAT_ACL_MAP, "", NULL);
                 _NFMdebug ((fname, "Bad Cat Sa Map : status = <0x%.8x>\n",
                 NFM_E_BAD_CAT_ACL_MAP));
                 return (NFM_E_BAD_CAT_ACL_MAP);
               }

	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "Stmt Synt : status = <0x%.8x>\n",
			  status));
              return (NFM_E_SQL_STMT);
            }

           status = NFMreturn_serial_slot (user_id, "nfmcatalogaclmap",
                    data [(attr_list -> rows * j) + a],
                    atol (data1 [count + j]));
           if (status != NFM_S_SUCCESS)
            {
              _NFMdebug ((fname, "Ret Ser No : status = <0x%.8x>\n",
              status));
              return (status);
            }
         }
      }

     if (drop)  /* B.W. 7/17/90  */
      {
         status = NFMupdate_catalog_state (user_id, WFinfo.catalog_no);
         if (status != NFM_S_SUCCESS)  
          {
            _NFMdebug ((fname, "Update Cat State : status = <0x%.8x>\n",
            status));
            return (status);
          }
      }


     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

 long NFMquery_catalog_sa_map (user_id, cat_name,
                               attr_list, data_list, value_list)
   long      user_id;
   char      *cat_name;
   MEMptr    *attr_list, *data_list, *value_list;
   {
     static char *fname = "NFMquery_catalog_sa_map";
     long     status;
     long     a, b, d, x, y, count;
     long     tab_no;
     MEMptr   list = NULL;
     char     **column, **data;
     char     *sql_str, sql_str1 [1024], value [50];
     long     column_of_valueno, row_of_sano, row_of_cat_no ;

     _NFMdebug ((fname, "Cat  Name = <%s>\n", cat_name));

     row_of_sano = -1; row_of_cat_no =-1 ; column_of_valueno = -1;
     status = NFMget_catalog_no (user_id, cat_name, &tab_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Cat No : status = <0x%.8x>\n",
        status));
        return (status);
      }

     if (WFinfo.catalog_no != tab_no)
      {
        ERRload_struct (NFM, NFM_E_BAD_CATALOG, "", NULL);
        _NFMdebug ((fname, "Check Cat No : status = <0x%.8x>\n", 
        NFM_E_BAD_CATALOG));
        return (NFM_E_BAD_CATALOG);
      }

     status = NFMquery_table_attributes (user_id, "NFMSYSTEM",
              "NFMCATALOGSAMAP", attr_list, data_list, value_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        _NFMdebug ((fname, "Qry Tab Attr : status = <0x%.8x>\n",
        status));
        return (status);
      }

     status = MEMbuild_array (*attr_list);
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

     column = (char **) (*attr_list) -> column_ptr;
     data   = (char **) (*attr_list) -> data_ptr;

     a = -1; b = -1; d = -1;

     for (y = 0; y < (*attr_list) -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))        a = y;
        else if (! strcmp (column [y], "n_datatype"))    b = y;
        else if (! strcmp (column [y], "n_synonym"))     d = y;
	else if (! strcmp (column [y], "n_valueno"))  column_of_valueno = y+1 ;
      }
     status = MEMclose (data_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     sql_str = (char *) malloc ((*attr_list) -> rows * 50 + 
                        (*attr_list) -> row_size + MEM_SIZE);
     if (! sql_str)
      {
        MEMclose (attr_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
        NFM_E_MALLOC));
        return (NFM_E_MALLOC);
      }

     sprintf (sql_str,  "SELECT ");
     sprintf (sql_str1, " FROM %s WHERE ", "NFMCATALOGSAMAP");
     row_of_cat_no = -1 ;
     for (x = 0; x < (*attr_list) -> rows; ++x)
      {
         count = (*attr_list) -> columns * x;
    
         if (! strcmp (data [count + a], "n_catalogno"))
          {
	    row_of_cat_no = x+1 ;
            strcat (sql_str1, data [count + a]);
            strcat (sql_str1, " = ");
      
            sprintf (value, "%d", WFinfo.catalog_no);

            if (! strncmp (data [count + b], "char", 4))
             {
               strcat (sql_str1, "'");
               strcat (sql_str1, value);
               strcat (sql_str1, "'");
             }
            else
               strcat (sql_str1, value);
          }
         else if (! strcmp (data [count + a], "n_sano"))
          {
	    row_of_sano = x + 1;
	  }

         if (x) strcat (sql_str, ", ");

         strcat (sql_str, data [count + a]);
      }

     strcat (sql_str, sql_str1);

     status = SQLquery (sql_str, &list, MEM_SIZE);
     if ((status != SQL_S_SUCCESS) &&
         ((status) != SQL_I_NO_ROWS_FOUND))
      {
        free (sql_str);
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Qry Syntax : status = <0x%.8x>\n",
		    status));
        return (NFM_E_SQL_QUERY);
      }

     sql_str [0] = 0;

     for (y = 0; y < (*attr_list) -> columns; ++y)
      {
             if (y == a) strcat (sql_str, "n_status");
        else if (y == b) strcat (sql_str, "char(15)");
        else if (y == d) strcat (sql_str, "STATUS");

        strcat (sql_str, "\1");
      }

     status = MEMwrite (*attr_list, sql_str);
     if (status != MEM_S_SUCCESS)
      {
        free (sql_str);
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     free (sql_str);

     status = MEMbuild_array (*attr_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     column = (char **) (*attr_list) -> column_ptr;
     data   = (char **) (*attr_list) -> data_ptr;

     status = MEMopen (data_list, MEM_SIZE);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     for (x = 0; x < (*attr_list) -> rows; ++x)
      {
        count = (*attr_list) -> columns * x;

        status = MEMwrite_format (*data_list,
                 data [count + a], data [count + b]);;
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (&list);
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);
        status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);
         }
      }

     status = MEMbuild_array (list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     data = (char**) list -> data_ptr;

     sql_str = (char *) malloc ((*data_list) -> row_size);
     if (! sql_str)
      {
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        status = ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
		    NFM_E_MALLOC));
        return (NFM_E_MALLOC);
      }

     for (x = 0; x < list -> rows; ++x)
      {
        count = list -> columns * x;

        sql_str [0] = 0;

        for (y = 0; y < list -> columns; ++y)
         {
            strcat (sql_str, data [count + y]);
            strcat (sql_str, "\1");
         }
 
        strcat (sql_str, "\1");

        status = MEMwrite (*data_list, sql_str);
        if (status != MEM_S_SUCCESS)
         {
           free (sql_str);
           MEMclose (&list);
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);
        status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);
         }
      }

     free (sql_str);

     status = MEMclose (&list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n",status));
        return (NFM_E_MEM);
      }

     strcpy (sql_str1, "select n_sano, n_saname from nfmstoragearea where n_type = 'I' or n_type = 'B' order by n_sano") ;

     status = _NFMadd_to_value_list_from_query (attr_list,
						value_list,
						sql_str1,
						row_of_sano,
						column_of_valueno) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Corrupted value buffer : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }

     sprintf (sql_str1, "select n_catalogno, n_catalogname from nfmcatalogs \
where n_catalogno = %d order by n_catalogno",
	      tab_no) ;

     status = _NFMadd_to_value_list_from_query (attr_list,
						value_list,
						sql_str1,
						row_of_cat_no, 
						column_of_valueno) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Corrupted value buffer : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);      
   }

 long NFMupdate_catalog_sa_map (user_id, attr_list, data_list)
   long      user_id;
   MEMptr    attr_list, data_list;
   {     
     static char *fname = "NFMupdate_catalog_sa_map";
     long    status;
     long    a, b, i, x, y, count;
     char    **column, **data, **data1;
     char    tab_no [50] ;
     long    NFMadd_catalog_sa_map ();
     long    NFMdrop_catalog_sa_map ();

     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
        status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array: status = <0x%.8x>\n", 
		    status));
        return (NFM_E_MEM);      
      }

     status = MEMbuild_array (data_list);
     if (status != MEM_S_SUCCESS)
      {
        status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array: status = <0x%.8x>\n", 
		    status));
        return (NFM_E_MEM);      
      }

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     data1  = (char **) data_list -> data_ptr;

     a = -1; b = -1;  i = -1;

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))       a = y;
        else if (! strcmp (column [y], "n_datatype"))   b = y;
      }
     
     for (x = 0; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;
  
        if (! strcmp (data [count + a], "n_catalogno"))   i = x;
      }

     sprintf (tab_no, "%d", WFinfo.catalog_no);

     for (x = 0; x < data_list -> rows; ++x)
      {
        count = data_list -> columns * x;

        status = MEMwrite_data (data_list, tab_no, x + 1, i + 1);
        if (status != MEM_S_SUCCESS)
         {
        status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n", 
		       status));
           return (NFM_E_MEM);      
         }
      }
 
     status = NFMstop_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Stop Trans  : status = <0x%.8x>\n", 
        status));
        return (status);      
      }

     status = NFMadd_catalog_sa_map (user_id, attr_list, data_list);
     if (status != NFM_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "Add Cat Sa Map : status = <0x%.8x>\n", 
        status));
        return (status);
      }

     status = NFMdrop_catalog_sa_map (user_id, attr_list, data_list);
     if (status != NFM_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "Drop Cat Sa Map : status = <0x%.8x>\n", 
        status));
        return (status);      
      }

     status = NFMstart_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Start Transaction : status = <0x%.8x>\n", 
        status));
        return (status);      
      }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);      
   }
  
 long NFMadd_catalog_sa_map (user_id, attr_list, data_list)
   long    user_id;
   MEMptr  attr_list, data_list;
   {
     static char *fname = "NFMadd_catalog_sa_map";
     long   status;
     char   **column, **data, **data1;
     long   map_no, cat_no;
     char   value [50], cat_name [50], samap_str[200], str[100];
     char   itemname [NFM_ITEMNAME +1], itemrev [NFM_ITEMREV +1];
     long   a, b, i, x, y, count, count1, comma,j,k;
     char   *sql_str, *sql_str1, *sa_str;
     MEMptr return_buffer = NULL;

     _NFMdebug ((fname, "ENTER\n")) ;

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     data1  = (char **) data_list -> data_ptr;


     if (data_list ->rows == 0)
       {
         _NFMdebug ((fname, "No New SAs Found in buffer to be added to cat mapping\n"));
         ERRload_struct (NFM, NFM_E_NO_SA_MAP_FOUND_FOR_CAT, "", NULL) ;
         return (NFM_E_NO_SA_MAP_FOUND_FOR_CAT) ;
       }

     a = -1; b = -1;  i = -1;

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))     a = y;
        else if (! strcmp (column [y], "n_datatype")) b = y;
      }

     i = -1; j = -1; k = -1;

     for (x = 0; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;
  
              if (! strcmp (data [count + a], "n_status"))    i = x;
        else  if (! strcmp (data [count + a], "n_catalogno")) j = x;
        else  if (! strcmp (data [count + a], "n_sano"))      k = x;
      }

     cat_no = (long) atol(data1 [j]);

     status = NFMget_catalog_name (user_id, cat_no, cat_name) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "BAD CATALOG : status = <0x%.8x>\n", status)) ;
	 return (status) ;
       }

     sa_str = (char *) malloc (data_list->rows * 50 + 500) ;
     if (sa_str == NULL)
       {
	 _NFMdebug ((fname, "Malloc Failed (sa_str)\n"));
	 ERRload_struct (NFM, NFM_E_MALLOC, "", NULL) ;
	 return (NFM_E_MALLOC) ;
       }

     sprintf (sa_str, "SELECT a.n_itemname, a.n_itemrev, b.n_cisano from %s a, f_%s b WHERE ", 
	      cat_name, cat_name) ;

     sprintf (samap_str, "%s (%s %d)", 
      " AND a.n_itemno = b.n_itemnum AND b.n_cisano NOT IN ",
      "SELECT n_sano FROM NFMCATALOGSAMAP WHERE n_catalogno =", cat_no) ;

     comma = 0 ;

     for (x = 0; x < data_list -> rows; ++x)
      {
        count = data_list -> columns * x;

        if (! strcmp (data1 [count + i], "ADD"))
	  {
	    if (!comma)
	      {
		sprintf (str, " b.n_cisano != %s", data1 [count+k]) ;
		comma = 1 ;
	      }
	    else
	      sprintf (str, " AND b.n_cisano != %s", data1 [count+k]) ;
	    strcat (sa_str, str) ;
	  }
      }

     if (comma)
       {
	 strcat (sa_str, samap_str) ;
	/* is any of the item of this catalog do not follow the new sa */
	 status = SQLquery (sa_str, &return_buffer, MEM_SIZE);
	 if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
	   {
             free (sa_str) ;
	     _NFMdebug ((fname, "SQL query ERROR : status = <0x%.8x>\n",
		       status));
	     return (NFM_E_SQL_QUERY) ;
	   }

	 if (status != SQL_I_NO_ROWS_FOUND)
	   {
             free (sa_str);
	     status = MEMbuild_array (return_buffer) ;
	     if (status == MEM_S_SUCCESS)
	       {
		 data = (char **) return_buffer->data_ptr ;
		 strcpy (itemname, data [0]) ;
		 strcpy (itemrev, data [1]) ;
	       }
	     MEMclose (&return_buffer) ;
	     _NFMdebug ((fname, "Item %s : Rev %s does not follow one of the specified SAs : status = <0x%.8x>\n", 
			 itemname, itemrev, status));
	     ERRload_struct (NFM, NFM_E_ITEM_NOT_FOLLOW_SA, "%s%s", 
			     itemname, itemrev) ;
	     return (NFM_E_ITEM_NOT_FOLLOW_SA) ;
	   }

	 status = MEMclose (&return_buffer) ;
	 if (status != MEM_S_SUCCESS)
	   {
             free (sa_str);
	     _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n", status));
	     ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
	     return (NFM_E_MEM) ;
	   }
       }

     free (sa_str) ;

     sql_str = (char *) malloc (attr_list -> rows * 50 +
                                data_list -> row_size + MEM_SIZE);
     if (! sql_str)
      {
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
        NFM_E_MALLOC));
        return (NFM_E_MALLOC);
      }

     sql_str1 = (char *) malloc (data_list -> row_size + MEM_SIZE);
     if (! sql_str1)
      {
        free (sql_str);
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
        NFM_E_MALLOC));
        return (NFM_E_MALLOC);
      }

     for (y = 0; y < data_list -> rows; ++y)
      {
	_NFMdebug ((fname, "y is %d\n", y)) ;
        count1 = data_list -> columns * y;

        NFMupper_case (data1 [count1 + i], data1 [count1 + i]) ;

        if (! strcmp (data1 [count1 + i], "ADD"))
         {
           sprintf (sql_str,  "INSERT INTO %s (", "NFMCATALOGSAMAP");
           sprintf (sql_str1, ") VALUES (");

           comma = 0;

           for (x = 0; x < attr_list -> rows; ++x)
            {
              count = attr_list -> columns * x;

              if (x != i)
               {
                 if (! strcmp (data [count + a], "n_mapno"))
                  {
                    status = NFMget_serial_slot (user_id,
                             "nfmcatalogsamap",
                             data [count + a], &map_no);
                    if (status != NFM_S_SUCCESS)
                     {
                       free (sql_str);
                       free (sql_str1);
                       _NFMdebug ((fname, "Ser No : status = <0x%.8x>\n",
                       status));
                       return (status);
                     }

                    sprintf (value, "%d", map_no);

                    status = MEMwrite_data (data_list, value,
                             y + 1, x + 1);
                    if (status != MEM_S_SUCCESS)
                     {
                       free (sql_str);
                       free (sql_str1);
		       ERRload_struct (NFM, NFM_E_MEM, "", NULL);
                       _NFMdebug ((fname, "Wr Data : status = <0x%.8x>\n",
				   status));
                       return (NFM_E_MEM);
                     }
                  }

                 if (comma)
                  {
                    strcat (sql_str,  ", ");
                    strcat (sql_str1, ", ");
                  }
                 comma = 1;

                 strcat (sql_str, data [count + a]);
  
                 if (! strncmp (data [count + b], "char", 4))
                  {
                    strcat (sql_str1, "'");
                    strcat (sql_str1, data1 [count1 + x]);
                    strcat (sql_str1, "'");
                  }
                 else
                  {
                    if (strlen (data1 [count1 + x]))
                       strcat (sql_str1, data1 [count1 + x]);
                    else
                       strcat (sql_str1, "null");
                  }
               }
	      _NFMdebug ((fname, "sql str1 <%s>\n", sql_str1)) ;
            }

           strcat (sql_str, sql_str1);
           strcat (sql_str, ")");
	   _NFMdebug ((fname, "sql str is <%s>\n", sql_str)) ;
           status = SQLstmt (sql_str);
           if ((status != SQL_S_SUCCESS) &&
               (status != SQL_E_DUPLICATE_VALUE))
            {
              free (sql_str);
              free (sql_str1);
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "Stmt Synt : status = <0x%.8x>\n",
			  status));
              return (NFM_E_SQL_STMT);
            }
         }
      }

     free (sql_str);
     free (sql_str1);

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMdrop_catalog_sa_map (user_id, attr_list, data_list)
   long    user_id;
   MEMptr  attr_list, data_list;
   {
     static char *fname = "NFMdrop_catalog_sa_map";
     long   status, cat_no;
     long   NFMupdate_catalog_state ();
     int    drop, comma;
     char   **column, **data, **data1;
     char   value [50], cat_name [50];
     long   a, b, i, j, x, y, count,k,l ;
     char   sql_str [1024], *sa_str, str[100];
     MEMptr return_buffer = NULL ;

     drop = 0;
     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     data1  = (char **) data_list -> data_ptr;

     a = -1; b = -1; i = -1; j = -1; k =-1; l =-1 ;

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))     a = y;
        else if (! strcmp (column [y], "n_datatype")) b = y;
      }

     for (x = 0; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;
  
             if (! strcmp (data [count + a], "n_status"))    i = x;
        else if (! strcmp (data [count + a], "n_mapno"))     j = x;
        else if (! strcmp (data [count + a], "n_catalogno")) k = x;
        else if (! strcmp (data [count + a], "n_sano"))      l = x;
      }

     cat_no = (long)  atol (data1 [k]) ;
     status = NFMget_catalog_name (user_id, cat_no, cat_name) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "BAD CATALOG : status = <0x%.8x>\n", status)) ;
	 return (status) ;
       }

     sa_str = (char *) malloc (data_list->rows * 500) ;
     if (sa_str == NULL)
       {
	 _NFMdebug ((fname, "Malloc Failed (sa_str)\n"));
	 ERRload_struct (NFM, NFM_E_MALLOC, "", NULL) ;
	 return (NFM_E_MALLOC) ;
       }

     sprintf (sa_str, "SELECT n_cisano from f_%s \
WHERE ", cat_name) ;

     comma = 0 ;

     for (x = 0; x < data_list -> rows; ++x)
      {
        count = data_list -> columns * x;
        if (! strcmp (data1 [count + i], "DROP"))
	  {
	    if (!comma)
	      {
		sprintf (str, " n_cisano = %s", data1 [count+l]) ;
		comma = 1 ;
	      }
	    else
	      sprintf (str, " OR n_cisano = %s", data1 [count+l]) ;
	    strcat (sa_str, str) ;
	  }
      }

     if (comma)
       {
	/* is any of the item of this catalog follow the new acls */
	 status = SQLquery (sa_str, &return_buffer, MEM_SIZE);
	 if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
	   {
             free (sa_str) ;
	     _NFMdebug ((fname, "SQL query ERROR : status = <0x%.8x>\n",
		       status));
	     return (NFM_E_SQL_QUERY) ;
	   }

	 if (status != SQL_I_NO_ROWS_FOUND)
	   {
             free (sa_str);
	     MEMclose (&return_buffer) ;
	     _NFMdebug ((fname, "An Item follows one of the specified SAs : status = <0x%.8x>\n", status));
	     ERRload_struct (NFM, NFM_E_ITEM_FOLLOWS_SA, "", NULL) ;
	     return (NFM_E_ITEM_FOLLOWS_SA) ;
	   }

	 status = MEMclose (&return_buffer) ;
	 if (status != MEM_S_SUCCESS)
	   {
             free (sa_str);
	     _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n", status));
	     ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
	     return (NFM_E_MEM) ;
	   }
       }
 
     free (sa_str) ;

     for (y = 0; y < data_list -> rows; ++y)
      {
        count = data_list -> columns * y;

        NFMupper_case (data1 [count + i], data1 [count + i]) ;

        if (! strcmp (data1 [count + i], "DROP"))
         {
           drop = 1;
/*
           if (! strncmp (n_dtype, "char", 4))
              sprintf (sql_str, "WHERE %s = '%s'",
                       n_attr, data1 [count + j]);
           else
              sprintf (sql_str, "WHERE %s = %s",
                       n_attr, data1 [count + j]);
*/
           sprintf (sql_str, "WHERE n_mapno = %s",
                    data1 [count + j]) ;

           status = NFMget_attr_value (user_id, "NFMPROJECTSAMAP",
                    "COUNT(*)", sql_str, value);
           if (status != NFM_S_SUCCESS && status != NFM_I_BAD_CONDITION)
            {
               _NFMdebug ((fname, "Attr Value : status = <0x%.8x>\n",
               status));
               return (status);
            }

           if (atol (value) > 0)
            {
        status = ERRload_struct (NFM, NFM_E_PROJ_SA_MAP_EXISTS, "", NULL);
               _NFMdebug ((fname, "Proj Map Exists : status = <0x%.8x>\n",
               NFM_E_PROJ_SA_MAP_EXISTS));
               return (NFM_E_PROJ_SA_MAP_EXISTS);
            }

           if (! strncmp (data [(attr_list -> columns * j) + b],
                          "char", 4))
              sprintf (sql_str, "DELETE FROM %s WHERE %s = '%s'",
                       "NFMCATALOGSAMAP", 
                       data [(attr_list -> columns * j) + a], 
                       data1 [count + j]);
           else
              sprintf (sql_str, "DELETE FROM %s WHERE %s = %s",
                       "NFMCATALOGSAMAP", 
                       data [(attr_list -> columns * j) + a], 
                       data1 [count + j]);

           status = SQLstmt (sql_str);
           if (status != SQL_S_SUCCESS)
            {
              if ((status) == SQL_I_NO_ROWS_FOUND)
               {
        status = ERRload_struct (NFM, NFM_E_BAD_CAT_SA_MAP, "", NULL);
                 _NFMdebug ((fname, "Bad Cat Sa Map : status = <0x%.8x>\n",
                 NFM_E_BAD_CAT_SA_MAP));
                 return (NFM_E_BAD_CAT_SA_MAP);
               }

        status = ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
              _NFMdebug ((fname, "Stmt Synt : status = <0x%.8x>\n",
			  status));
              return (NFM_E_SQL_STMT);
            }

           status = NFMreturn_serial_slot (user_id, "nfmcatalogsamap",
                    data [(attr_list -> rows * j) + a],
                    atol (data1 [count + j]));
           if (status != NFM_S_SUCCESS)
            {
              _NFMdebug ((fname, "Ret Ser No : status = <0x%.8x>\n",
              status));
              return (status);
            }
         }
      }

     if (drop)  /* B.W. 7/17/90  */
      {
         status = NFMupdate_catalog_state (user_id, WFinfo.catalog_no);
         if (status != NFM_S_SUCCESS)  
          {
            _NFMdebug ((fname, "Update Cat State : status = <0x%.8x>\n",
            status));
            return (status);
          }
      }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

  /**********************************************************************
   *   This function will check to see if all the mapping (acl & sa)    *
   *   for a catalog has been done.  If so it will reset the catalog    *
   *   state in NFMcatalogs to the "CATALOG CREATED" state.             *
   *   This function uses the hard coded state "CATALOG CREATED" and    *
   *   therefore if the statename changes the hardcoded name must be    *
   *   changed here also.  This should be considered a temporary fix    *
   **********************************************************************/

  long NFMupdate_catalog_state (user_id, cat_num)
    long   user_id; 
    long   cat_num;
  {
    static char *fname = "NFMupdate_catalog_state";
    long   status;
    long   workflowno, stateno;
    long NFMget_workflow_no(), NFMget_state_no();
    char   sql_str[256]; 
    MEMptr sql_buffer = NULL; 

     _NFMdebug ((fname, "catalog_number = <%d>\n", cat_num));

     workflowno = 0;  stateno = 0;
     sprintf (sql_str, "SELECT %s FROM NFMCATALOGACLMAP WHERE %s = %d",
              "n_mapno", "n_catalogno", cat_num);
     status = SQLquery (sql_str, &sql_buffer, 256);

     if ((status) != SQL_I_NO_ROWS_FOUND)
     {
        MEMclose (&sql_buffer);
        if (status != SQL_S_SUCCESS)
        {
        status = ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
           status = NFM_E_SQL_QUERY;
           _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status));
        }
        else
        {
           status = NFM_S_SUCCESS;
           _NFMdebug ((fname, "Cat ACL Map Exist : status = <0x%.8x>\n",
                     status));
        }
        return (status);
     } 

     status = MEMclose (&sql_buffer);
     if (status != MEM_S_SUCCESS)
     {
        _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n", status));
        return (status);
     }
     sql_buffer = NULL; 
 
     sprintf (sql_str, "SELECT %s FROM NFMCATALOGSAMAP WHERE %s = %d",
              "n_mapno", "n_catalogno", cat_num);
     status = SQLquery (sql_str, &sql_buffer, 256);

     if ((status) != SQL_I_NO_ROWS_FOUND)
     {
        MEMclose (&sql_buffer);
        if (status != SQL_S_SUCCESS)
        {
        status = ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
           status = NFM_E_SQL_QUERY;
           _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status));
        }
        else
        {
           status = NFM_S_SUCCESS;
           _NFMdebug ((fname, "Cat SA Map Exist : status = <0x%.8x>\n",
                     status));
        }
        return (status);
     } 

     /* there is no catalog mapping, set the state back to CATALOG CREATED */

     status = NFMget_workflow_no (user_id, "NFM_CATALOG_WORKFLOW",
                                  &workflowno);
     if (status != NFM_S_SUCCESS)
     {
        _NFMdebug ((fname, "Get WF No : status = <0x%.8x>\n", status));
        return (status);
     }

     status = NFMget_state_no (user_id, workflowno, "CATALOG CREATED",
                               &stateno);
     if (status != NFM_S_SUCCESS)
     {
        _NFMdebug ((fname, "Get State No : status = <0x%.8x>\n", status));
        return (status);
     }

     sprintf (sql_str, "UPDATE %s SET %s = %d WHERE %s = %d",
              "NFMCATALOGS", "n_stateno", stateno, "n_catalogno", cat_num); 
     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS)
     {
        status = ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug ((fname, "SQL Stmt : status = <0x%.8x>\n", status));
        return (NFM_E_SQL_STMT);
     } 

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
  }

