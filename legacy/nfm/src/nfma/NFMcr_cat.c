#include "machine.h"
#include "NFMA.h"

  extern long NFM_TRANSACTION ;

 long NFMcreate_catalog (user_id, loc_attr, loc_data,
                         attr_list, data_list, value_list)
   long      user_id ;
   MEMptr    loc_attr, loc_data;
   MEMptr    attr_list, data_list, value_list;
   {
     static char fname[] = "NFMcreate_catalog" ;
     long     status, atol ();
     long     x, y, count;
     long     a, b,  i, j, k, l, m, n ;
     long     cat_no, f_table_no ;
     char     cat_name [100], file_cat [100], identifier [NFM_IDENTIFIER+1] ;
     char     **column, **data, **data1;
     char     sql_str [1024];
     MEMptr   attr_list1 = NULL, data_list1 = NULL;
     MEMptr   attr_list2 = NULL, data_list2 = NULL;
     MEMptr   identifier_list = NULL ;
     long     _NFMadd_loc_entry ();

     _NFMdebug ((fname, "ENTER\n")) ;

     /* the argument must match what the global variable NFM_TRANSACTION has
	in order to COMMIT WORK will get executed and then it set
	NFM_TRANSACTION to -1 */

     status = NFMset_autocommit_on (0) ;
     if ((status != NFM_S_SUCCESS) || (NFM_TRANSACTION != -1))
       {
	 _NFMdebug ((fname, "Failure to force autocommit on : NFM_TRANSACTION is <%d>\n", NFM_TRANSACTION)) ;
	 return (status) ;
       }

     status = MEMbuild_array (loc_attr);
     if (status != MEM_S_SUCCESS)
      {
	WFload_catalog_no (-1) ;
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", 
		    NFM_E_MEM)) ;
        return (NFM_E_MEM);
      }

     status = MEMbuild_array (loc_data);
     if (status != MEM_S_SUCCESS)
      {
	WFload_catalog_no (-1) ;
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", 
		    NFM_E_MEM));
        return (NFM_E_MEM);
      }

     column = (char **) loc_attr -> column_ptr;
     data   = (char **) loc_attr -> data_ptr;
     data1  = (char **) loc_data -> data_ptr;

     a = -1; b = -1; 

     for (y = 0; y < loc_attr -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))     a = y;
        else if (! strcmp (column [y], "n_datatype")) b = y;
      }

     i = -1;

     for (x = 0; x < loc_attr -> rows; ++x)
      {
        count = loc_attr -> columns * x;
 
        if (! strcmp (data [count + a], "n_catalogname"))  i = x;
      }

     sprintf (cat_name, "%s",   data1 [i]);
     sprintf (file_cat, "f_%s", data1 [i]);  

     _NFMdebug ((fname, "catalogname %s : f_catalogname %s\n",
		 cat_name, file_cat)) ;

     if (!strlen (cat_name) || (!strlen (file_cat)))
       {
	 WFload_catalog_no (-1) ;
	 _NFMdebug ((fname, "Bad catalog name\n")) ;
	 ERRload_struct (NFM, NFM_E_GET_CATALOG_NAME, "", "") ;
	 return (NFM_E_GET_CATALOG_NAME) ;
       }

     status = NFMsplit_template_attributes (attr_list, data_list,
					    &attr_list1, &data_list1, 
					    &attr_list2, &data_list2,
					    &identifier_list) ;
     if (status != NFM_S_SUCCESS)
      {
	WFload_catalog_no (-1) ;
        MEMclose (&attr_list1);
        MEMclose (&data_list1);
        MEMclose (&attr_list2);
        MEMclose (&data_list2);
        _NFMdebug ((fname,  "Split Cat Buffers : status = <0x%.8x>\n", status));
        return (status);
      }

     status = MEMbuild_array (identifier_list) ;
     if (status != MEM_S_SUCCESS)
      {
	WFload_catalog_no (-1) ;
        MEMclose (&attr_list1);
        MEMclose (&data_list1);
        MEMclose (&attr_list2);
        MEMclose (&data_list2);
	MEMclose (&identifier_list) ;
	_NFMdebug ((fname, "MEMbuild_array (identifier_list) : status = <0x%.8x>\n",
		    status)) ;
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        return (NFM_E_MEM);
      }

     data = (char **) identifier_list->data_ptr ;
     identifier [0] = 0 ;
     for (i=0; i<identifier_list->rows && 
	  (strlen (identifier)<NFM_IDENTIFIER); i++)
       {
	 strcat (identifier, data [i]) ;
       }

     identifier [NFM_IDENTIFIER] = 0 ;
     _NFMdebug ((fname, "identifier is %s\n", identifier)) ;

     status = _NFMcreate_table ("CATALOG", cat_name, identifier,  &cat_no,
              attr_list1, data_list1, value_list);
     if (status != NFM_S_SUCCESS)
      {
	if (status != NFM_E_DUP_CATALOG) 
	    NFMdelete_table (user_id, "CATALOG", cat_name);
	WFload_catalog_no (-1) ;
        MEMclose (&attr_list1);
        MEMclose (&data_list1);
        MEMclose (&attr_list2);
        MEMclose (&data_list2);
        _NFMdebug ((fname, "Create Cat : status = <0x%.8x>\n", status));
        return (status);
      }

     status = _NFMcreate_table ("F_CATALOG", file_cat, identifier, &f_table_no,
              attr_list2, data_list2, value_list);
     if (status != NFM_S_SUCCESS)
      {
        NFMdelete_table (user_id, "CATALOG", cat_name);
        NFMdelete_table (user_id, "F_CATALOG", file_cat);
	WFload_catalog_no (-1) ;
        MEMclose (&attr_list1);
        MEMclose (&data_list1);
        MEMclose (&attr_list2);
        MEMclose (&data_list2);
        _NFMdebug ((fname, "Create File Cat : status = <0x%.8x>\n", status));
        return (status);
      }

     status = MEMclose (&attr_list1);
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        NFMdelete_table (user_id, "CATALOG", cat_name);
        NFMdelete_table (user_id, "F_CATALOG", file_cat);
	WFload_catalog_no (-1) ;
        MEMclose (&data_list1);
        MEMclose (&attr_list2);
        MEMclose (&data_list2);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     status = MEMclose (&data_list1);
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        NFMdelete_table (user_id, "CATALOG", cat_name);
        NFMdelete_table (user_id, "F_CATALOG", file_cat);
	WFload_catalog_no (-1) ;
        MEMclose (&attr_list2);
        MEMclose (&data_list2);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     status = MEMclose (&attr_list2);
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        NFMdelete_table (user_id, "CATALOG", cat_name);
        NFMdelete_table (user_id, "F_CATALOG", file_cat);
        MEMclose (&data_list2);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     status = MEMclose (&data_list2);
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        NFMdelete_table (user_id, "CATALOG", cat_name);
        NFMdelete_table (user_id, "F_CATALOG", file_cat);
	WFload_catalog_no (-1) ;
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     status = _NFMadd_loc_entry (cat_name, identifier,cat_no, 
				 loc_attr, loc_data);
     if (status != NFM_S_SUCCESS)
      {
        NFMrollback_transaction (1);
        NFMdelete_table (user_id, "CATALOG", cat_name);
        NFMdelete_table (user_id, "F_CATALOG", file_cat);
        _NFMdebug ((fname, "Add Loc Entry : status = <0x%.8x>\n", status));
        return (status);
      }

     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	NFMdelete_loc_entry (user_id, cat_no) ;
        NFMdelete_table (user_id, "CATALOG", cat_name);
        NFMdelete_table (user_id, "F_CATALOG", file_cat);
	WFload_catalog_no (-1) ;
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);     
      }

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     a = -1; 

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))     a = y;
      }

     i = -1;  j = -1;  k = -1; l = -1; m = -1; n = -1;

     for (x = 0; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;
 
             if (! strcmp (data [count + a], "n_itemno"))      i = x;
        else if (! strcmp (data [count + a], "n_itemname"))    j = x;
        else if (! strcmp (data [count + a], "n_itemrev"))     k = x;
        else if (! strcmp (data [count + a], "n_fileno"))      l = x;
        else if (! strcmp (data [count + a], "n_itemnum"))     m = x;
        else if (! strcmp (data [count + a], "n_fileversion")) n = x;
      }

     sprintf (sql_str, "CREATE UNIQUE INDEX i_%d_1 ON %s (%s)",
              cat_no, cat_name, 
              data [(attr_list -> columns * i) + a]);

     status = SQLexec_imm (sql_str);
     if (status != SQL_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
	NFMdelete_loc_entry (user_id, cat_no) ;
        NFMdelete_table (user_id, "CATALOG", cat_name);
        NFMdelete_table (user_id, "F_CATALOG", file_cat);
/*        NFMdelete_loc_entry (user_id, cat_no); mms - twice ?? */
	WFload_catalog_no (-1) ;
        _NFMdebug ((fname, "Create Index : status = <0x%.8x>\n", 
		    status));
        return (NFM_E_SQL_STMT);        
      }

     sprintf (sql_str, "CREATE UNIQUE INDEX i_%d_2 ON %s (%s, %s)",
              cat_no, cat_name,
              data [(attr_list -> columns * j) + a],
              data [(attr_list -> columns * k) + a]);

     status = SQLexec_imm (sql_str);
     if (status != SQL_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
	NFMdelete_loc_entry (user_id, cat_no) ;
        NFMdelete_table (user_id, "CATALOG", cat_name);
        NFMdelete_table (user_id, "F_CATALOG", file_cat);
/*         NFMdelete_loc_entry (user_id, cat_no); mms - twice ?? */
	WFload_catalog_no (-1) ;
        _NFMdebug ((fname, "Create Index : status = <0x%.8x>\n", 
		    status));
        return (NFM_E_SQL_STMT);        
      }

     sprintf (sql_str, "CREATE UNIQUE INDEX i_%d_3 ON %s (%s)",
              cat_no, file_cat,
              data [(attr_list -> columns * l) + a]);

     status = SQLexec_imm (sql_str);
     if (status != SQL_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
	NFMdelete_loc_entry (user_id, cat_no) ;
        NFMdelete_table (user_id, "CATALOG", cat_name);
        NFMdelete_table (user_id, "F_CATALOG", file_cat);
/*         NFMdelete_loc_entry (user_id, cat_no);  mms - twice ?? */
	WFload_catalog_no (-1) ;
        _NFMdebug ((fname, "Create Index : status = <0x%.8x>\n", 
		    status));
        return (NFM_E_SQL_STMT);        
      }

     sprintf (sql_str, "CREATE INDEX i_%d_4 ON %s (%s)",
              cat_no, file_cat,
              data [(attr_list -> columns * m) + a]) ;

     status = SQLexec_imm (sql_str);
     if (status != SQL_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
	NFMdelete_loc_entry (user_id, cat_no) ;
        NFMdelete_table (user_id, "CATALOG", cat_name);
        NFMdelete_table (user_id, "F_CATALOG", file_cat);
/*        NFMdelete_loc_entry (user_id, cat_no) ; mms - twice ?? */
	WFload_catalog_no (-1) ;
        _NFMdebug ((fname, "Create Index : status = <0x%.8x>\n", 
		    status));
        return (NFM_E_SQL_STMT);        
      }

     status = _NFMcreate_application_table (cat_name, identifier_list);
     if (status != NFM_S_SUCCESS)
       {
	 NFMdelete_loc_entry (user_id, cat_no) ;
	 NFMdelete_table (user_id, "CATALOG", cat_name);
	 NFMdelete_table (user_id, "F_CATALOG", file_cat);
	 WFload_catalog_no (-1) ;
	 MEMclose (&identifier_list) ;
	 _NFMdebug ((fname, "Create Application Table failed : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }


     status = MEMclose (&identifier_list) ;
     if (status != MEM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "MEMclose identifier_list : status = <0x%.8x>\n",
		     status)) ;
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	 return (NFM_E_MEM) ;
       }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long _NFMadd_loc_entry (cat_name, identifier, catalog_no, loc_attr, loc_data)
   char    *cat_name;
   char    *identifier ;
   long    catalog_no ;
   MEMptr  loc_attr, loc_data;
   {
     static char *fname = "_NFMadd_loc_entry" ;
     long     status, atol () ;
     long     x, y, count, comma, add;
     long     a, b, i;
     char     *sql_str, *sql_str1;
     char     **column, **data, **data1;
     char     table_no [15], out_str [50] ;

     _NFMdebug ((fname, "Cat  Name = <%s> : identifier = <%s>\n", 
		 cat_name, identifier));

     column = (char **) loc_attr -> column_ptr;
     data   = (char **) loc_attr -> data_ptr;

     data1  = (char **) loc_data -> data_ptr;

     a = -1; b = -1; 

     for (y = 0; y < loc_attr -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))         a = y;
        else if (! strcmp (column [y], "n_datatype"))     b = y;
      }

     sql_str = (char *) malloc ((4 * loc_data -> row_size) + MEM_SIZE);
     if (! sql_str)
      {
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
        NFM_E_MALLOC));
        return (NFM_E_MALLOC);        
      }
     sql_str [0] = 0;

     sql_str1 = (char *) malloc ((4 * loc_data -> row_size) + MEM_SIZE);
     if (! sql_str1)
      {
        free (sql_str);
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
        NFM_E_MALLOC));
        return (NFM_E_MALLOC);        
      }
     sql_str1 [0] = 0;

     status = WFload_catalog_name (cat_name);

     status = WFload_catalog_no (catalog_no) ;

     sprintf (sql_str,  "INSERT INTO %s (", "NFMCATALOGS");
     sprintf (sql_str1, ") VALUES (");

     comma = 0; i = -1;

     for (x = 0; x < loc_attr -> rows; ++x)
      {
        count = loc_attr -> columns * x;

        add = 0;

	_NFMdebug ((fname, "%s\n", data [count + a])) ;

        if (! strcmp (data [count + a], "n_catalogno"))
         {
           add = 1;

	   sprintf (table_no, "%d", catalog_no);
  
           status = MEMwrite_data (loc_data, table_no, 1, x + 1);
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
        if (! strcmp (data [count + a], "n_identifier"))
         {
           add = 1;

           status = MEMwrite_data (loc_data, identifier, 1, x + 1);
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
        else if (! strcmp (data [count + a], "n_aclno"))
         {
           if (! strlen (data1 [x])) 
	     {
	       _NFMdebug ((fname, "Failure : No Acl specified\n")) ;
	       ERRload_struct (NFM, NFM_E_BAD_ACL, "", "") ;
	       return (NFM_E_BAD_ACL) ;
	     }
	   add = 1; 
           i = x;
         }
        else if (! strcmp (data [count + a], "n_stateno"))
          add = 0;
        else if (! strcmp (data [count + a], "n_updater"))
           add = 0;
        else if (! strcmp (data [count + a], "n_updatedate"))
           add = 0;
        else if (! strcmp (data [count + a], "n_updatetime"))
           add = 0; 
        else if (! strcmp (data [count + a], "n_archivestate"))
           add = 0;
        else if (! strcmp (data [count + a], "n_archiveno"))
           add = 0;
        else if (! strcmp (data [count + a], "n_pendingflag"))
           add = 0;
        else if (! strcmp (data [count + a], "n_pendinguser"))
           add = 0;
        else if (! strcmp (data [count + a], "t_basic"))
           add = 0;
        else if (! strcmp (data [count + a], "t_appl"))
           add = 0;
        else if (strlen (data1 [x])) add = 1; 

        if (add)
         {
           if (comma)
            {
               strcat (sql_str,  ", ");
               strcat (sql_str1, ", ");
            }
           else
               comma = 1;

           strcat (sql_str, data [count + a]);

           if (! strncmp (data [count + b], "char", 4))
            {
               strcat (sql_str1, "'");
               strcat (sql_str1, data1 [x]);
               strcat (sql_str1, "'");
            }
            else if (! strcmp (data [count + b], "timestamp"))
              {
                status = NFMascii_to_timestamp_format (data1 [x], out_str) ;
                if (status != NFM_S_SUCCESS)
                  {
                    _NFMdebug ((fname,"ascii to timestamp:status = <0x%.8x>\n",
                                status)) ;
                    return (status) ;
                  }

                strcat (sql_str1, "TIMESTAMP '") ;
                strcat (sql_str1, out_str);
                strcat (sql_str1, "'") ;
              }
   
           else
            {
               if (strlen (data1 [x]))  strcat (sql_str1, data1 [x]);
               else                     strcat (sql_str1, 'null'); 
            }
         }
      }
     WFload_acl_st (atol (data1 [i])) ;

     status = WFload_wf_struct_for_sts () ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "load transition for acl %d failed : status = <0x%.8x>\n",
		     atol (data1 [i]), status)) ;
	 return (status) ;
       }

     strcat (sql_str, sql_str1);
     strcat (sql_str, ")");

     free (sql_str1);

     status = SQLexec_imm (sql_str);
     if (status != SQL_S_SUCCESS)
      {
         free (sql_str);
         if (status == SQL_E_DUPLICATE_VALUE)
          {
	    ERRload_struct (NFM, NFM_E_DUP_CATALOG, "", NULL);
            _NFMdebug ((fname, "Cat Exists : status = <0x%.8x>\n",
            NFM_E_DUP_CATALOG));
            return (NFM_E_DUP_CATALOG);        
          }

        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
         _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
		     status));
         return (NFM_E_SQL_STMT);        
      }

     free (sql_str);

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }



