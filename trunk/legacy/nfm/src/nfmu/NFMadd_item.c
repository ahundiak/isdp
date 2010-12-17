#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMdb.h"
#include "NFMerrordef.h"
#include "NFMstruct.h"
#include "ERR.h"
#include "DEBUG.h"
#include "WFstruct.h"

extern struct NFMglobal_st NFMglobal ;
extern struct WFstruct WFinfo ;
 
 long NFMadd_item (user_id, cat_name, attr_list, data_list)
   long    user_id;
   char    *cat_name;
   MEMptr  attr_list;
   MEMptr  data_list;
   {
     static char *fname = "NFMadd_item" ;
     long     status;
     long     cat_no, item_no, proj_no ;
     MEMptr   attr_list1 = NULL, data_list1 = NULL;
     MEMptr   attr_list2 = NULL, data_list2 = NULL;
     char     fcat_name[61];
     char     lock_tables [100];
     long     NFMadd_catalog_entry ();
     long     NFMadd_file_catalog_entry ();
     long  _NFMdelete_cat_itemno ();

     _NFMdebug ((fname, "table name  = <%s>\n", cat_name));
     user_id = user_id ;
     status = NFMsplit_catalog_attributes (NFMglobal.NFMuserid,
					   attr_list, data_list,
					   &attr_list1, &data_list1, 
					   &attr_list2, &data_list2);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (&attr_list1);
        MEMclose (&attr_list2);
        MEMclose (&data_list1);
        MEMclose (&data_list2);
        _NFMdebug ((fname, "Split Cat List : status = <0x%.8x>\n", status));
        return (status);
      }

     status = NFMset_autocommit_off (0) ;
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (&attr_list1);
        MEMclose (&attr_list2);
        MEMclose (&data_list1);
        MEMclose (&data_list2);
        _NFMdebug ((fname, "Failure : Set autocommit off : status = <0x%.8x>\n",
        status));
        return (status);
      }
     sprintf (lock_tables, "NFMINDEX, %s", cat_name) ;
     status = NFMlock_table (lock_tables) ;
     if (status != NFM_S_SUCCESS)
     {
       MEMclose (&attr_list1);
       MEMclose (&attr_list2);
       MEMclose (&data_list1);
       MEMclose (&data_list2);
       ERRload_struct (NFM, NFM_E_FAILURE, "", NULL);
       _NFMdebug ( (fname, "NFMlock_table: 0x%.8x", NFM_E_FAILURE) );
       return (NFM_E_FAILURE);
     }
     status = NFMadd_catalog_entry (NFMglobal.NFMuserid, cat_name, &item_no,
              attr_list1, data_list1);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (&attr_list1);
        MEMclose (&attr_list2);
        MEMclose (&data_list1);
        MEMclose (&data_list2);
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "Make Item Entry : status = <0x%.8x>\n", status));
        return (status);
      }

      status = SQLstmt ("COMMIT WORK");
      if (status != SQL_S_SUCCESS)
      {
        MEMclose (&attr_list1);
        MEMclose (&attr_list2);
        MEMclose (&data_list1);
        MEMclose (&data_list2);
        ERRload_struct (NFM, NFM_E_FAILURE, "", NULL);
        status = NFM_E_FAILURE;
        return (status);
      }

     sprintf (fcat_name, "f_%s", cat_name);
     status = NFMlock_table (fcat_name);
     if (status != NFM_S_SUCCESS)
     {
       MEMclose (&attr_list1);
       MEMclose (&attr_list2);
       MEMclose (&data_list1);
       MEMclose (&data_list2);
       _NFMdelete_cat_itemno (cat_name, item_no) ;
       ERRload_struct (NFM, NFM_E_FAILURE, "", NULL);
       _NFMdebug ( (fname, "NFMlock_table: 0x%.8x", status) );
       return (status);
     }

     status = NFMadd_file_catalog_entry (NFMglobal.NFMuserid, cat_name, item_no,
              attr_list2, data_list2);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (&attr_list1);
        MEMclose (&attr_list2);
        MEMclose (&data_list1);
        MEMclose (&data_list2);
        NFMrollback_transaction (0);
       _NFMdelete_cat_itemno (cat_name, item_no) ;
        _NFMdebug ((fname, "Make File Entry : status = <0x%.8x>\n", status));
        return (status);
      }
/*
      status = SQLstmt ("COMMIT WORK");
      if (status != SQL_S_SUCCESS)
      {
        MEMclose (&attr_list1);
        MEMclose (&attr_list2);
        MEMclose (&data_list1);
        MEMclose (&data_list2);
        ERRload_struct (NFM, NFM_E_FAILURE, "", NULL);
       _NFMdelete_cat_itemno (cat_name, item_no) ;
        status = NFM_E_FAILURE;
        return (status);
      }
*/
     status = NFMset_autocommit_on (0) ;
     if (status != NFM_S_SUCCESS)
       {
        MEMclose (&attr_list1);
        MEMclose (&attr_list2);
        MEMclose (&data_list1);
        MEMclose (&data_list2);
       _NFMdelete_cat_itemno (cat_name, item_no) ;
        NFMrollback_transaction (0);
	return (status) ;
       }

     WFload_item_no (item_no) ;
/*     WFinfo.item_no = item_no; */

     status = MEMclose (&attr_list1);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&attr_list2);
        MEMclose (&data_list1);
        MEMclose (&data_list2);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	_NFMdelete_cat_itemno (cat_name, item_no) ;
        _NFMdebug ((fname, "MEM CLose : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     status = MEMclose (&attr_list2);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&data_list1);
        MEMclose (&data_list2);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
       _NFMdelete_cat_itemno (cat_name, item_no) ;
        _NFMdebug ((fname, "MEM CLose : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     status = MEMclose (&data_list1);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&data_list2);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM CLose : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     status = MEMclose (&data_list2);
     if (status != MEM_S_SUCCESS)
      {
       _NFMdelete_cat_itemno (cat_name, item_no) ;
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM CLose : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     WFget_active_proj_no (&proj_no) ;
     if (proj_no > 0)
      {
	status = NFMget_catalog_no (NFMglobal.NFMuserid, cat_name, &cat_no);
	if (status != NFM_S_SUCCESS)
	  {
	    _NFMdelete_cat_itemno (cat_name, item_no) ;
	    _NFMdebug ((fname, "Get Catalog No : status = <0x%.8x>\n", status));
	    return (status);
	  }

        status = NFMinternal_add_project_member (NFMglobal.NFMuserid, 
                 proj_no, cat_no, item_no);
        if (status != NFM_S_SUCCESS)
         {
	   _NFMdelete_cat_itemno (cat_name, item_no) ;
           _NFMdebug ((fname, "Item -> Project: status = <0x%.8x>\n",
           status));
           return (status);
         }
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
  }

 long NFMadd_catalog_entry (user_id, cat_name, item_no,
                            attr_list, data_list)
   long    user_id;
   char    *cat_name;
   long    *item_no;
   MEMptr  attr_list, data_list;
   {
     static char *fname = "NFMadd_catalog_entry" ;
     long    status, insert, atol ();
     char    **column, **data, **data1;
     long    a, b, x, y, count, comma, i;
     char    *sql_str, *sql_str1;
     long    check;
     char    sql_str2 [1024], n_attr [100];
     char    value [50], out_str [50];

     *item_no = 0;

     _NFMdebug ((fname, "Cat  Name = <%s> : Item No = <%d>\n", 
		 cat_name, *item_no));

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

     a = -1; b = -1; 

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))      a = y;
        else if (! strcmp (column [y], "n_datatype"))  b = y;
      }

     sql_str = (char *) malloc (50 * attr_list -> rows +
                                     data_list -> row_size);
     if (! sql_str)
      {
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
        NFM_E_MALLOC));
        return (NFM_E_MALLOC);
      }

     sql_str1 = (char *) malloc (50 * attr_list -> rows +
                                 data_list -> row_size);
     if (! sql_str1)
      {
        free (sql_str);
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
        NFM_E_MALLOC));
        return (NFM_E_MALLOC);
      }

     sql_str [0] = 0;  sql_str1 [0] = 0; comma = 0;

     sprintf (sql_str,  "INSERT INTO %s (", cat_name);
     sprintf (sql_str1, ") VALUES (");

     sprintf (sql_str2, "WHERE ");
     check = 0;

     i = -1;

     for (x = 0; x < attr_list -> rows; ++x)
      {
         count = attr_list -> columns * x;
         insert = 0;

         if (! strcmp (data [count + a], "n_itemno"))
          {
            insert = 1;

            status = NFMget_serial_slot (user_id, cat_name,
                     data [count + a], item_no);
            if (status != NFM_S_SUCCESS)
             {
               free (sql_str);
               free (sql_str1);
               _NFMdebug ((fname, "Get Serial No : status = <0x%.8x>\n",
               status));
               return (status);
             }

            sprintf (value, "%d", *item_no);
            sprintf (n_attr, "%s", data [count + a]);

            status = MEMwrite_data (data_list, value, 1, x + 1);
            if (status != MEM_S_SUCCESS)
             {
               free (sql_str);
               free (sql_str1);
               ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               _NFMdebug ((fname, "Write Data : status = <0x%.8x>\n",
			   status));
               return (NFM_E_MEM);
             }
          }
         else if (! strcmp (data [count + a], "n_aclno"))
          {
            insert = 1;
	    
	    WFload_acl_st (atol (data1 [x])) ;
	    
	    status = WFload_wf_struct_for_sts () ;
	    if (status != NFM_S_SUCCESS)
	      {
		_NFMdebug ((fname, "load transition for acl %d failed : status = <0x%.8x>\n",
			    atol (data1 [x]), status)) ;
		return (status) ;
	      }
          }
         else if (! strcmp (data [count + a], "n_itemrev"))
          {
            insert = 1;
	    WFload_item_rev (data1[x]) ;
/*            sprintf (WFinfo.item_rev, "%s", data1 [x]); */

            if (check) strcat (sql_str2, " AND ");
            check = 1;

            strcat (sql_str2, data [count + a]);
            strcat (sql_str2, " = ");

            if (! strncmp (data [count + b], "char", 4))
             {
               strcat (sql_str2, "'");
               strcat (sql_str2, data1 [x]);
               strcat (sql_str2, "'");
             }
            else
               strcat (sql_str2, data1 [x]);
          }
         else if (! strcmp (data [count + a], "n_itemname"))
          {
            insert = 1;
	    WFload_item_name (data1 [x]) ;
/*            sprintf (WFinfo.item_name, "%s", data1 [x]); */

            if (check) strcat (sql_str2, " AND ");
            check = 1;

            strcat (sql_str2, data [count + a]);
            strcat (sql_str2, " = ");

            if (! strncmp (data [count + b], "char", 4))
             {
               strcat (sql_str2, "'");
               strcat (sql_str2, data1 [x]);
               strcat (sql_str2, "'");
             }
            else
               strcat (sql_str2, data1 [x]);
          }
         else if (! strcmp (data [count + a], "n_stateno"))
           insert = 0;
         else if (! strcmp (data [count + a], "n_prevstate"))
           insert = 0;
         else if (! strcmp (data [count + a], "n_updater"))
           insert = 0;
         else if (! strcmp (data [count + a], "n_updatedate"))
           insert = 0;
         else if (! strcmp (data [count + a], "n_updatetime"))
           insert = 0;
         else if (! strcmp (data [count + a], "n_coout"))
           insert = 0;
         else if (! strcmp (data [count + a], "n_colevel"))
           insert = 0;
         else if (! strcmp (data [count + a], "n_archivestate"))
           insert = 0;
         else if (strlen (data1 [x]))  insert = 1;

         if (insert)
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
		strcat (sql_str1, out_str) ;
		strcat (sql_str1, "'") ;
	      }
            else
             {
               if (strlen (data1 [x])) strcat (sql_str1, data1 [x]);
               else                    strcat (sql_str1, "null");   
             }
          }
      }
/******** DUR Wanted to update n_stateno here ***********
     strcat (sql_str, "n_stateno = ") ;
     sprintf (out_str, "%d", WFinfo.curr_state) ;
     strcat (sql_str1, out_str)  ;
*********************************************************/
     strcat (sql_str, sql_str1);
     strcat (sql_str, ")");

     _NFMdebug ((fname, "cat name %s : n_attr %s : sql_str %s\n",
		 cat_name, n_attr, sql_str2)) ;


     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS)
      {
        free (sql_str);
        free (sql_str1);

        if (status == SQL_E_DUPLICATE_VALUE)
         {
           ERRload_struct (NFM, NFM_E_DUP_ITEM, "", NULL);
           _NFMdebug ((fname, "Item Exists : status = <0x%.8x>\n",
           NFM_E_DUP_ITEM));
           return (NFM_E_DUP_ITEM);
         }

        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
		    status));
        return (NFM_E_SQL_STMT);
      }

     free (sql_str);
     free (sql_str1);

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

 long NFMadd_file_catalog_entry (user_id, cat_name, item_no,
                                 attr_list, data_list)
   long    user_id;
   char    *cat_name;
   long    item_no;
   MEMptr  attr_list, data_list;
   {
     static char *fname = "NFMadd_file_catalog_entry" ;
     long    status, file_no, atol () ;
     char    **column, **data, **data1;
     long    a, b, x, y, count, comma, insert, local_file_exists;
     long    cisano_exists ;
     char    *sql_str, *sql_str1, sql_str2[1024] ;
     char    value [50], file_no_str[50] ;
     char    n_filetype [NFM_FILETYPE+1] ;

     _NFMdebug ((fname, "Cat  Name = <%s> : Item No = <%d>\n", 
		 cat_name, item_no));

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

     a = -1; b = -1; 

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))      a = y;
        else if (! strcmp (column [y], "n_datatype"))  b = y;
      }

     sql_str = (char *) malloc (50 * attr_list -> rows +
                                     data_list -> row_size);
     if (! sql_str)
      {
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
        NFM_E_MALLOC));
        return (NFM_E_MALLOC);
      }

     sql_str1 = (char *) malloc (50 * attr_list -> rows +
                                      data_list -> row_size);
     if (! sql_str1)
      {
        free (sql_str);
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
        NFM_E_MALLOC));
        return (NFM_E_MALLOC);
      }

     sql_str [0] = 0;  sql_str1 [0] = 0; comma = 0;

     sprintf (sql_str,  "INSERT INTO f_%s (", cat_name);
     sprintf (sql_str1, ") VALUES (");

     cisano_exists = 0 ;
     local_file_exists = 0 ;
     for (x = 0; x < attr_list -> rows; ++x)
      {
         insert = 0;

         count = attr_list -> columns * x;

         if (! strcmp (data [count + a], "n_itemnum"))
          {
            insert = 1;

            sprintf (value, "%d", item_no);

            status = MEMwrite_data (data_list, value, 1, x + 1);
            if (status != MEM_S_SUCCESS)
             {
               free (sql_str);
               free (sql_str1);
               ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               _NFMdebug ((fname, "Write Data : status = <0x%.8x>\n",
			   status));
               return (NFM_E_MEM);
             }
          }
         else if (! strcmp (data [count + a], "n_fileno"))
          {
            insert = 1;

            sprintf (value, "f_%s", cat_name);

            /*
            status = NFMget_serial_slot (user_id, value, 
                     data [count + a], &file_no);
            if (status != NFM_S_SUCCESS)
             {
               free (sql_str);
               free (sql_str1);
               _NFMdebug ((fname, "Get Ser No : status = <0x%.8x>\n",
               status));
               return (status);
             }            
            */
            
            sprintf (sql_str2, "MAX(%s)", data[count+a]);
            status = NFMget_attr_value (user_id, value, sql_str2, "", 
                                        file_no_str);
            if (status != NFM_S_SUCCESS)
             {
               free (sql_str);
               free (sql_str1);
               _NFMdebug ((fname, "NFMget_attr_value : status = <0x%.8x>\n",
			   status));
               return (status);
             }
            
            file_no = atol (file_no_str) + 1;
            sprintf (value, "%d", file_no); 

            status = MEMwrite_data (data_list, value, 1, x + 1);
            if (status != MEM_S_SUCCESS)
             {
               free (sql_str);
               free (sql_str1);
               ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               _NFMdebug ((fname, "Write Data : status = <0x%.8x>\n",
			   status));
               return (NFM_E_MEM);
             }
          }
         else if (! strcmp (data [count + a], "n_filenum"))
          {
            insert = 0;
	  }
         else if (! strcmp (data [count + a], "n_fileversion"))
          {
            insert = 1;

            status = MEMwrite_data (data_list, "0", 1, x + 1);
            if (status != MEM_S_SUCCESS)
             {
               free (sql_str);
               free (sql_str1);
               ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               _NFMdebug ((fname, "Write Data : status = <0x%.8x>\n",
			   status));
               return (NFM_E_MEM);
             }
          }
         else if (! strcmp (data [count + a], "n_fileclass"))
          {
            insert = 1;

            status = MEMwrite_data (data_list, "C", 1, x + 1);
            if (status != MEM_S_SUCCESS)
             {
               free (sql_str);
               free (sql_str1);
               ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               _NFMdebug ((fname, "Write Data : status = <0x%.8x>\n",
			   status));
               return (NFM_E_MEM);
             }
          }
         else if (! strcmp (data [count + a], "n_cifilename"))
          {
            if (strlen (data1 [x]))  insert = 1;
            else                     insert = 0;
          }
         else if (! strcmp (data [count + a], "n_cofilename"))
          {
            if (strlen (data1 [x]))  
	      {
		local_file_exists = 1 ;
		insert = 1;
	      }
            else    
	      insert = 0;
          }
         else if (! strcmp (data [count + a], "n_cisano"))
          {
	    if (strlen (data1 [x]))
	      {
		cisano_exists = 1 ;
		insert = 1;
		
		status = NFMcheck_sa_no (user_id, atol (data1 [x]));
		if (status != NFM_S_SUCCESS)
		  {
		    free (sql_str);
		    free (sql_str1);
		    _NFMdebug ((fname, "Bad CiSa No : status = <0x%.8x>\n",
				status));
		    return (status);
		  }
	      }
          }
         else if (! strcmp (data [count + a], "n_cosano"))
          {
            if (strlen (data1 [x]))
             {
               insert = 1;

               status = NFMcheck_sa_no (user_id, atol (data1 [x]));
               if (status != NFM_S_SUCCESS)
                {
                  free (sql_str);
                  free (sql_str1);
                  _NFMdebug ((fname, "Bad Co SA : status = <0x%.8x>\n",
                  status));
                  return (status);
                }
             }
            else
               insert = 0;
          }
         else if (! strcmp (data [count + a], "n_iconno"))
           insert = 1;
         else if (! strcmp (data [count + a], "n_filetype"))
	   {
	     NFMupper_case (data1 [x], data1 [x]) ;
	     strcpy (n_filetype, data1 [x]) ;
	     insert = 1;
	   }
         else if (! strcmp (data [count + a], "n_archiveno"))
           insert = 0;
         else if (! strcmp (data [count + a], "n_pendingflag"))
           insert = 0;
         else if (! strcmp (data [count + a], "n_pendinguser"))
           insert = 0;
         else if (! strcmp (data [count + a], "n_cifilesize"))
           insert = 0;
         else if (! strcmp (data [count + a], "n_ciuser"))
           insert = 0;
         else if (! strcmp (data [count + a], "n_cidate"))
           insert = 0;
         else if (! strcmp (data [count + a], "n_citime"))
           insert = 0;
         else if (! strcmp (data [count + a], "n_fileco"))
           insert = 0;
         else if (! strcmp (data [count + a], "n_cocomment"))
           insert = 0;
         else if (! strcmp (data [count + a], "n_couser"))
           insert = 0;
         else if (! strcmp (data [count + a], "n_codate"))
           insert = 0;
         else if (! strcmp (data [count + a], "n_cotime"))
           insert = 0;
         else
           insert = 1;

         if (insert)
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
            else
             {
               if (strlen (data1 [x])) strcat (sql_str1, data1 [x]);
               else                    strcat (sql_str1, "null");   
             }
          }
      }

     if (comma)
       {
	 strcat (sql_str,  ", ");
	 strcat (sql_str1, ", ");
       }

     strcat (sql_str, "n_filenum") ;

     if (local_file_exists)
       {
	 strcat (sql_str1, "1") ;
	 if (! cisano_exists)
	   {
	     _NFMdebug ((fname, "Input to local file name requires entry on the internal storage location\n")) ;
	     ERRload_struct (NFM, NFM_E_ISA_REQUIRED, NULL, "") ;
	     return (NFM_E_ISA_REQUIRED) ;
	   }
       }
     else
       {
	 strcat (sql_str1, "0") ;
	 if (strcmp (n_filetype, "M") == 0)
	   {
	     _NFMdebug ((fname, "A M(icrostation) Item requires the name of the microstation file name\n")) ;
	     ERRload_struct (NFM, NFM_E_MS_LOCAL_REQUIRED, "", "") ;
	     return (NFM_E_MS_LOCAL_REQUIRED) ;
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
           ERRload_struct (NFM, NFM_E_DUP_FILE, "", NULL);
           _NFMdebug ((fname, "Item Exists : status = <0x%.8x>\n",
		     NFM_E_DUP_FILE));
           return (NFM_E_DUP_FILE);
         }

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



long  _NFMdelete_cat_itemno (cat_name, item_no) 
     char *cat_name ;
     long item_no ;
{
  char *fname = "_NFMdelete_cat_itemno" ;
  char sql_str [512] ;
  long status ;

  sprintf (sql_str, "delete from %s where n_itemno = %d",
	   cat_name, item_no) ;
  status = SQLstmt (sql_str) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
      return (NFM_E_SQL_STMT) ;
    }

  sprintf (sql_str, "delete from f_%s where n_itemnum = %d",
	   cat_name, item_no) ;
  status = SQLstmt (sql_str) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
      return (NFM_E_SQL_STMT) ;
    }

  sprintf (sql_str, "delete from nfmprojectcit where n_itemno = %d",
	   item_no) ;
  status = SQLstmt (sql_str) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
      return (NFM_E_SQL_STMT) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}
