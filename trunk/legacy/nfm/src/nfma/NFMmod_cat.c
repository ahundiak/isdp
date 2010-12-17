#include "machine.h"
#include "NFMA.h"

  extern struct NFMglobal_st NFMglobal ;
  extern long NFM_TRANSACTION ;

 long NFMchange_catalog (user_id, loc_attr, loc_data,
                         attr_list, data_list, value_list)
   long      user_id;
   MEMptr    loc_attr, loc_data;
   MEMptr    attr_list, data_list, value_list;
   {
     char    *fname = "NFMchange_catalog" ;
     long     status, atol ();
     char     **column, **data, **data1;
     long     a, b, i ;
     long     x, y, count;
     char     cat_name [100], file_cat [100], cat_name_old [100];
     MEMptr   attr_list1 = NULL, data_list1 = NULL;
     MEMptr   attr_list2 = NULL, data_list2 = NULL;
     MEMptr   identifier_list = NULL ;
     long     NFMupdate_loc_entry ();
     long     NFMreset_loc_entry () ;

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
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", 
		    status)) ;
        return (NFM_E_MEM);
      }

     status = MEMbuild_array (loc_data);
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", 
		    status));
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

     sprintf (cat_name,     "%s", data1 [i]);
     sprintf (cat_name_old, "%s", data1 [(loc_data -> columns) + i]);
     sprintf (file_cat,     "f_%s", cat_name);  
/***********
     status = NFMchange_catalog_name (user_id, cat_name_old, cat_name);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Change Cat Name : status = <0x%.8x>\n", status));
        return (status);
      }
***************/

     status = NFMsplit_catalog_attributes (NFMglobal.NFMuserid,
					   attr_list, data_list,
					   &attr_list1, &data_list1, 
					   &attr_list2, &data_list2) ;
     if (status != NFM_S_SUCCESS)
      {
/*        if (strcmp (cat_name, cat_name_old))
          NFMchange_catalog_name (user_id, cat_name, cat_name_old); */

        MEMclose (&attr_list1);
        MEMclose (&data_list1);
        MEMclose (&attr_list2);
        MEMclose (&data_list2);
        _NFMdebug ((fname, "Split Cat Buffers : status = <0x%.8x>\n",
        status));
        return (status);
      }

     status = NFMchange_table (user_id, "CATALOG", cat_name,
              attr_list1, data_list1, value_list);
     if (status != NFM_S_SUCCESS)
      {
/*        if (strcmp (cat_name, cat_name_old))
          NFMchange_catalog_name (user_id, cat_name, cat_name_old); */

        MEMclose (&attr_list1);
        MEMclose (&data_list1);
        MEMclose (&attr_list2);
        MEMclose (&data_list2);
        _NFMdebug ((fname, "Create Cat : status = <0x%.8x>\n", status));
        return (status);
      }


     status = NFMchange_table (user_id, "F_CATALOG", file_cat,
              attr_list2, data_list2, value_list);
     if (status != NFM_S_SUCCESS)
      {
        NFMreset_change_table (user_id, "CATALOG", cat_name, 
        attr_list1, data_list1, value_list);

/*        if (strcmp (cat_name, cat_name_old))
          NFMchange_catalog_name (user_id, cat_name, cat_name_old); */

        MEMclose (&attr_list1);
        MEMclose (&data_list1);
        MEMclose (&attr_list2);
        MEMclose (&data_list2);
        _NFMdebug ((fname, "Create File Cat : status = <0x%.8x>\n", status));
        return (status);
      }

     status = NFMstop_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        NFMreset_change_table (user_id, "CATALOG", cat_name, 
        attr_list1, data_list1, value_list);

        NFMreset_change_table (user_id, "F_CATALOG", file_cat, 
        attr_list2, data_list2, value_list);

/*        if (strcmp (cat_name, cat_name_old))
          NFMchange_catalog_name (user_id, cat_name, cat_name_old); */

        MEMclose (&attr_list1);
        MEMclose (&data_list1);
        MEMclose (&attr_list2);
        MEMclose (&data_list2);
        _NFMdebug ((fname, "Stop Transaction : status = <0x%.8x>\n", status));
        return (status);
      }

     status = NFMupdate_loc_entry (user_id, loc_attr, loc_data);
     if (status != NFM_S_SUCCESS)
      {
        NFMrollback_transaction (0);

        NFMreset_change_table (user_id, "CATALOG", cat_name, 
        attr_list1, data_list1, value_list);

        NFMreset_change_table (user_id, "F_CATALOG", file_cat, 
        attr_list2, data_list2, value_list);

/*        if (strcmp (cat_name, cat_name_old))
          NFMchange_catalog_name (user_id, cat_name, cat_name_old); */

        MEMclose (&attr_list1);
        MEMclose (&data_list1);
        MEMclose (&attr_list2);
        MEMclose (&data_list2);
        _NFMdebug ((fname, "Add Loc Entry : status = <0x%.8x>\n", status));
        return (status);
      }

     status = NFMstart_transaction (0);
     if (status != NFM_S_SUCCESS)
      {

        NFMreset_change_table (user_id, "CATALOG", cat_name, 
        attr_list1, data_list1, value_list);

        NFMreset_change_table (user_id, "F_CATALOG", file_cat, 
        attr_list2, data_list2, value_list);

	NFMreset_loc_entry (user_id, loc_attr, loc_data);
/*	if (strcmp (cat_name, cat_name_old))
          NFMchange_catalog_name (user_id, cat_name, cat_name_old); */
        MEMclose (&attr_list1);
        MEMclose (&data_list1);
        MEMclose (&attr_list2);
        MEMclose (&data_list2);
        _NFMdebug ((fname, "Start Transaction : status = <0x%.8x>\n",
        status));
        return (status);
      }

     status = MEMclose (&attr_list1);
     if (status != MEM_S_SUCCESS)
      {

        NFMreset_change_table (user_id, "CATALOG", cat_name, 
        attr_list1, data_list1, value_list);

        NFMreset_change_table (user_id, "F_CATALOG", file_cat, 
        attr_list2, data_list2, value_list);

/*        if (strcmp (cat_name, cat_name_old))
          NFMchange_catalog_name (user_id, cat_name, cat_name_old); */
	NFMreset_loc_entry (user_id, loc_attr, loc_data);
         MEMclose (&data_list1);
        MEMclose (&attr_list2);
        MEMclose (&data_list2);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     status = MEMclose (&data_list1);
     if (status != MEM_S_SUCCESS)
      {

        NFMreset_change_table (user_id, "CATALOG", cat_name, 
        attr_list1, data_list1, value_list);

        NFMreset_change_table (user_id, "F_CATALOG", file_cat, 
        attr_list2, data_list2, value_list);

/*        if (strcmp (cat_name, cat_name_old))
          NFMchange_catalog_name (user_id, cat_name, cat_name_old); */
	NFMreset_loc_entry (user_id, loc_attr, loc_data);
	MEMclose (&attr_list2);
        MEMclose (&data_list2);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     status = MEMclose (&attr_list2);
     if (status != MEM_S_SUCCESS)
      {

        NFMreset_change_table (user_id, "CATALOG", cat_name, 
        attr_list1, data_list1, value_list);

        NFMreset_change_table (user_id, "F_CATALOG", file_cat, 
        attr_list2, data_list2, value_list);

/*        if (strcmp (cat_name, cat_name_old))
          NFMchange_catalog_name (user_id, cat_name, cat_name_old); */
        NFMreset_loc_entry (user_id, loc_attr, loc_data);
	MEMclose (&data_list2);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     status = MEMclose (&data_list2);
     if (status != MEM_S_SUCCESS)
      {
        NFMreset_change_table (user_id, "CATALOG", cat_name, 
        attr_list1, data_list1, value_list);

        NFMreset_change_table (user_id, "F_CATALOG", file_cat, 
        attr_list2, data_list2, value_list);

/*        if (strcmp (cat_name, cat_name_old))
          NFMchange_catalog_name (user_id, cat_name, cat_name_old); */
	NFMreset_loc_entry (user_id, loc_attr, loc_data);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     _NFMdebug ((fname, "SUCCESSFUL\n"));
     return (NFM_S_SUCCESS);
   }

 long NFMupdate_loc_entry (user_id, attr_list, data_list)
   long    user_id;
   MEMptr  attr_list, data_list;
   {
     char    *fname = "NFMupdate_loc_entry" ;
     long    status;
     char    *sql_str, *sql_str1;
     char    **column, **data, **data1, out_str [50];
     long    x, y, count, count1, mod, comma;
     long    a, b, d;

     _NFMdebug ((fname, "ENTER\n")) ;

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     data1  = (char **) data_list -> data_ptr;

     a = -1; b = -1; d = -1;

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))         a = y;
        else if (! strcmp (column [y], "n_datatype"))     b = y;
        else if (! strcmp (column [y], "n_application"))  d = y;
      }
       
     sql_str = (char *) malloc (4 * data_list -> row_size + MEM_SIZE);
     if (! sql_str)
      {
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
        NFM_E_MALLOC));
        return (NFM_E_MALLOC);        
      }
     sql_str [0] = 0;

     sql_str1 = (char *) malloc (4 * data_list -> row_size + MEM_SIZE);
     if (! sql_str1)
      {
        free (sql_str);
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
        NFM_E_MALLOC));
        return (NFM_E_MALLOC);        
      }
     sql_str1 [0] = 0;

     sprintf (sql_str,  "UPDATE %s SET ", "NFMCATALOGS");
     sprintf (sql_str1, " WHERE ");

     comma = 0;  mod = 0;

     count1 = data_list -> columns;

     for (x = 0; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;
        mod = 0;

        if (! strcmp (data [count + d], "NFM"))
         {
           if (! strcmp (data [count + a], "n_catalogno"))
            {
              mod = 0;

              strcat (sql_str1, data [count + a]);
              strcat (sql_str1, " = ");

              if (! strncmp (data [count + b], "char", 4))
               {
                 strcat (sql_str1, "'");
                 strcat (sql_str1, data1 [x]);
                 strcat (sql_str1, "'");
               }
              else
                 strcat (sql_str1, data1 [x]);
            }
           else if (! strcmp (data [count + a], "n_archivestate"))
              mod = 0;
           else if (! strcmp (data [count + a], "n_archiveno"))
              mod = 0;
           else if (! strcmp (data [count + a], "n_pendingflag"))
              mod = 0;
           else if (! strcmp (data [count + a], "n_pendinguser"))
              mod = 0;
           else if (! strcmp (data [count + a], "n_creator"))
              mod = 0;
           else if (! strcmp (data [count + a], "n_creationdate"))
              mod = 0;
           else if (! strcmp (data [count + a], "n_updater"))
              mod = 1;
           else if (! strcmp (data [count + a], "n_updatedate"))
              mod = 1;
           else if (! strcmp (data [count + a], "n_stateno"))
              mod = 1;
           else if (! strcmp (data [count + a], "n_aclno"))
              mod = 1;
           else if (strcmp (data1 [x], data1 [count1 + x]))
              mod = 1;

           if (mod)
            {
              if (comma)  strcat (sql_str, ", ");
              else comma  = 1;

              strcat (sql_str, data [count + a]);
              strcat (sql_str, " = ");

              if (! strncmp (data [count + b], "char", 4))
               {
                 strcat (sql_str, "'");
                 strcat (sql_str, data1 [x]);
                 strcat (sql_str, "'");
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

                strcat (sql_str, "TIMESTAMP '") ;
                strcat (sql_str, out_str);
                strcat (sql_str, "'") ;
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

     strcat (sql_str, sql_str1);

     status = SQLexec_imm (sql_str);
     if (status != SQL_S_SUCCESS)
      {
        free (sql_str);
        free (sql_str1);
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
		    status));
        return (NFM_E_SQL_STMT);
      }

     free (sql_str);
     free (sql_str1);
     
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMreset_loc_entry (user_id, attr_list, data_list)
   long    user_id;
   MEMptr  attr_list, data_list;
   {
     char    *fname = "NFMreset_loc_entry" ;
     long    status;
     char    *sql_str, *sql_str1;
     char    **column, **data, **data1;
     long    x, y, count, count1, mod, comma;
     long    a, b, d;

     _NFMdebug ((fname, "ENTER\n")) ;

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     data1  = (char **) data_list -> data_ptr;

     a = -1; b = -1; d = -1;

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))         a = y;
        else if (! strcmp (column [y], "n_datatype"))     b = y;
        else if (! strcmp (column [y], "n_application"))  d = y;
      }
       

     sql_str = (char *) malloc (4 * data_list -> row_size + MEM_SIZE);
     if (! sql_str)
      {
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
        NFM_E_MALLOC));
        return (NFM_E_MALLOC);        
      }
     sql_str [0] = 0;

     sql_str1 = (char *) malloc (4 * data_list -> row_size + MEM_SIZE);
     if (! sql_str1)
      {
        free (sql_str);
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
        NFM_E_MALLOC));
        return (NFM_E_MALLOC);        
      }
     sql_str1 [0] = 0;

     sprintf (sql_str,  "UPDATE %s SET ", "NFMCATALOGS");
     sprintf (sql_str1, " WHERE ");

     comma = 0;  mod = 0;

     count1 = 0 ;

     for (x = 0; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;
        mod = 0;

        if (! strcmp (data [count + d], "NFM"))
         {
           if (! strcmp (data [count + a], "n_catalogno"))
            {
              mod = 0;

              strcat (sql_str1, data [count + a]);
              strcat (sql_str1, " = ");

              if (! strncmp (data [count + b], "char", 4))
               {
                 strcat (sql_str1, "'");
                 strcat (sql_str1, data1 [x]);
                 strcat (sql_str1, "'");
               }
              else
                 strcat (sql_str1, data1 [x]);
            }
           else if (! strcmp (data [count + a], "n_archivestate"))
              mod = 0;
           else if (! strcmp (data [count + a], "n_archiveno"))
              mod = 0;
           else if (! strcmp (data [count + a], "n_pendingflag"))
              mod = 0;
           else if (! strcmp (data [count + a], "n_pendinguser"))
              mod = 0;
           else if (! strcmp (data [count + a], "n_creator"))
              mod = 0;
           else if (! strcmp (data [count + a], "n_creationdate"))
              mod = 0;
           else if (! strcmp (data [count + a], "n_updater"))
              mod = 1;
           else if (! strcmp (data [count + a], "n_updatedate"))
              mod = 1;
           else if (! strcmp (data [count + a], "n_stateno"))
              mod = 1;
           else if (! strcmp (data [count + a], "n_aclno"))
              mod = 1;
           else if (strcmp (data1 [x], data1 [count1 + x]))
	     /* fix for TR90W1842 if had a not in front of strcmp */
              mod = 1;
	    /***/

           if (mod)
            {
              if (comma)  strcat (sql_str, ", ");
              else comma  = 1;

              strcat (sql_str, data [count + a]);
              strcat (sql_str, " = ");

              if (! strncmp (data [count + b], "char", 4))
               {
                 strcat (sql_str, "'");
                 strcat (sql_str, data1 [x]);
                 strcat (sql_str, "'");
               }
            else if (! strcmp (data [count + b], "timestamp"))
              {
                strcat (sql_str, "TIMESTAMP '") ;
                strcat (sql_str, data1 [x]) ;
                strcat (sql_str, "'") ;
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

     strcat (sql_str, sql_str1);

     status = SQLexec_imm (sql_str);
     if (status != SQL_S_SUCCESS)
      {
        free (sql_str);
        free (sql_str1);
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
		    status));
        return (NFM_E_SQL_STMT);
      }

     free (sql_str);
     free (sql_str1);
     
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }




