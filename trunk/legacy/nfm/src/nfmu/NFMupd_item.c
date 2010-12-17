#include "machine.h"
#include "WFstruct.h"
#include "NFMlocks.h"
#include "NFMfto_buf.h"
#include "NFMU.h"

 extern struct WFstruct WFinfo;
 extern struct NFMglobal_st NFMglobal ;

 long NFMprepare_update_item (user_id, cat_name, item_name, item_rev,
                              attr_list, data_list, value_list)
   long    user_id;
   char    *cat_name, *item_name, *item_rev;
   MEMptr  *attr_list, *data_list, *value_list;
   {
     char *fname = "NFMprepare_update_item" ;
     long     status, comma ;
     long     a, b, d, x, y, z, count;
     char     *sql_str, *sql_str1 ;
     char     **column, **data, **data1;
     char     user_name [30], date [30], file_status [NFM_STATUS+1] ;
     char     RISdate [30], tmp_str [200], archive_flag [NFM_ARCHIVESTATE+1] ;
     long     archiveno ;
     char     fileco [10] ;
     long     item_is_co = 0, upd_pos ;
     long     NFMcheck_item_owned_project ();
     long     _NFMcheck_item_condition_update_item ();

     _NFMdebug ((fname, "Cat Name = <%s> : Item Name = <%s> : Item Rev = <%s>\n",
		 cat_name, item_name, item_rev)) ;
     user_id = user_id ;
     status =  _NFMcheck_item_condition_update_item (cat_name,
						     item_name, item_rev,
						     file_status, 
						     archive_flag,
						     &archiveno,
						     fileco) ;
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Check item condition : status = <0x%.8x>\n",
		    status));
        return (status);
      }

     item_is_co = 0 ;
     if ((strcmp (file_status, "I"))  && (strcmp (file_status, "")))
	 item_is_co = 1 ;

     strcpy (user_name, NFMglobal.NFMusername) ;

     status = NFMget_datetime (date) ;
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Date & Time : status = <0x%.8x>\n",
        status));
        return (status);
      }

     status = NFMquery_item_attributes_u (NFMglobal.NFMuserid, cat_name, item_name,
              item_rev, attr_list, data_list, value_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        _NFMdebug ((fname, "Query Item Attr : status = <0x%.8x>\n",
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
		    status)) ;
        return (NFM_E_MEM);
      }

     column = (char **) (*attr_list) -> column_ptr;
     data   = (char **) (*attr_list) -> data_ptr;

     a = -1; b = -1; d = -1; upd_pos = -1;

     for (y = 0; y < (*attr_list) -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))      a = y;
        else if (! strcmp (column [y], "n_datatype"))  b = y;
        else if (! strcmp (column [y], "n_valueno"))    d = y;
	else if (! strcmp (column [y], "n_update"))    upd_pos=y ;
      }

/********** already done in NFMquery_item_attributes *********
     status = NFMcheck_item_owned_project (NFMglobal.NFMuserid, cat_name,
              item_name, item_rev, &proj_no);
     if (status != NFM_S_SUCCESS             && 
         status != NFM_E_PROJECT_MEMBER      &&
         status != NFM_E_NOT_PROJECT_MEMBER)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        _NFMdebug ((fname, "Chk Item Proj Mem : status = <0x%.8x>\n",
        status));
        return (status);
      }

     if (status == NFM_E_PROJECT_MEMBER)
      {        
        status = _NFMget_proj_sa_list (WFinfo.catalog_no, proj_no, &list);
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (&list);
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);
           _NFMdebug ((fname, "Proj Ci Sa List : status = <0x%.8x>\n",
           status));
           return (status);          
         }
      }
     else
      {
        status = _NFMget_cat_internal_sa_list (WFinfo.catalog_no, &list);
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (&list);
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);
           _NFMdebug ((fname, "Cat Ci Sa List : status = <0x%.8x>\n",
           status));
           return (status);          
         }
      }

     if (list -> rows < 1)
       {
	 MEMclose (&list);
	 MEMclose (attr_list);
	 MEMclose (data_list);
	 MEMclose (value_list);
	 ERRload_struct (NFM, NFM_E_NO_ST_AREAS, "", "") ;
	 _NFMdebug ((fname, "No sa list for this item\n")) ;
	 return (NFM_E_NO_ST_AREAS) ;
       }

     if (*value_list)
       {
	 status = MEMappend (list, *value_list);
	 if (status != MEM_S_SUCCESS)
	   {
	     MEMclose (&list);
	     MEMclose (attr_list);
	     MEMclose (data_list);
	     MEMclose (value_list);
	     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	     _NFMdebug ((fname, "MEM Append : status = <0x%.8x>\n",
			 status));
	     return (NFM_E_MEM);          
	   }
       }
     else
      {
        status = MEMsplit_copy_buffer (list, value_list, 0);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (&list);
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);
	   ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Copy : status = <0x%.8x>\n",
		     status));
           return (NFM_E_MEM);          
         }
      }
 
     status = MEMclose (&list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);          
      }
	
      MEMno_buffers (*value_list, &no_buffers);
      sprintf (sa_no, "%d", no_buffers );
******************************************/	
     sql_str = (char *) malloc (50 * (*attr_list) -> rows +
				(*data_list) -> row_size);
     if (! sql_str)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
        NFM_E_MALLOC));
        return (NFM_E_MALLOC);
      }

     z = (*data_list) -> rows;

     for (x = 0; x < z; ++x)
      {
        status = MEMbuild_array (*data_list);
        if (status != MEM_S_SUCCESS)
         {
           free (sql_str);
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);
	   ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);
         }

        data1  = (char **) (*data_list) -> data_ptr;

        count = (*data_list) -> columns * x;
        sql_str [0] = 0;

        for (y = 0; y < (*data_list) -> columns; ++y)
         {
           strcat (sql_str, data1 [count + y]);
           strcat (sql_str, "\1");
         }

        status = MEMwrite (*data_list, sql_str);
        if (status != MEM_S_SUCCESS)
         {
           free (sql_str);
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);
	   ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);
         }
      }

     status = MEMbuild_array (*data_list);
     if (status != MEM_S_SUCCESS)
      {
        free (sql_str);
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     data1  = (char **) (*data_list) -> data_ptr;

     sql_str1 = (char *) malloc (50 * (*attr_list) -> rows +
                                      (*data_list) -> row_size);
     if (! sql_str1)
      {
        free (sql_str);
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
        NFM_E_MALLOC));
        return (NFM_E_MALLOC);
      }

     sql_str [0] = 0;  sql_str1 [0] = 0;

     sprintf (sql_str,  "UPDATE %s SET ", cat_name);
     sprintf (sql_str1, " WHERE ");
 
     comma = 0 ;
     for (x = 0; x < (*attr_list) -> rows; ++x)
      {
        count = (*attr_list) -> columns * x;

        if (! strcmp (data [count + a], "n_itemno"))
         {
           strcat (sql_str1, data [count + a]);
           strcat (sql_str1, " = ");
           strcat (sql_str1, data1 [x]);
         }
        else if (! strcmp (data [count + a], "n_itemlock"))
         {
	   if (comma)
	     {
	       strcat (sql_str, ",") ;
	     }
	   else
	     comma = 1 ;
	   sprintf (tmp_str, "%s = 'U'",
		    data [count+a]) ;
	   strcat (sql_str, tmp_str) ;
/****
           strcat (sql_str, data [count + a]);
           strcat (sql_str, " = ");

	   strcat (sql_str, "'");
	   strcat (sql_str, "U");
	   strcat (sql_str, "'");
*****/
         }
/********
        else if ((! strcmp (archive_flag, "A")) &&
		 (! strcmp (data [count + a], "n_cisano"))) 
         {
           status = MEMwrite_data (*attr_list,
                    "N", x + 1, upd_pos + 1);
           if (status != MEM_S_SUCCESS)
            {
              free (sql_str);
              free (sql_str1);
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (value_list);
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _NFMdebug ((fname, "Wr Data : status = <0x%.8x>\n",
			  status));
              return (NFM_E_MEM);
            }
***/
/******** already done in NFMquery_item_attributes 
           status = MEMwrite_data (*attr_list,
                    sa_no, x + 1, d + 1);
           if (status != MEM_S_SUCCESS)
            {
              free (sql_str);
              free (sql_str1);
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (value_list);
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _NFMdebug ((fname, "Wr Data : status = <0x%.8x>\n",
			  status));
              return (NFM_E_MEM);
            }
************************************************/
/***
         }
***/
/*
        else if (((! strcmp (archive_flag, "A")) ||
		 (! strcmp (archive_flag, "B"))) &&
		 (! strcmp (data [count + a], "n_cifilename")))
*/
	else if ((! strcmp (data [count + a], "n_cifilename")) &&
		 ((!strcmp (fileco, "O")) ||
		  ((! strcmp (fileco, "Y")) && (archiveno > 0)) ||
		  ((! strcmp (fileco, "N")) && (archiveno > 0))))
         {
           status = MEMwrite_data (*attr_list,
                    "N", x + 1, upd_pos + 1);
           if (status != MEM_S_SUCCESS)
            {
              free (sql_str);
              free (sql_str1);
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (value_list);
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _NFMdebug ((fname, "Wr Data : status = <0x%.8x>\n",
			  status));
              return (NFM_E_MEM);
            }
	 }
        else if (item_is_co && (! strcmp (data [count + a], "n_cosano")))
         {
           status = MEMwrite_data (*attr_list,
                    "N", x + 1, upd_pos + 1);
           if (status != MEM_S_SUCCESS)
            {
              free (sql_str);
              free (sql_str1);
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (value_list);
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _NFMdebug ((fname, "Wr Data : status = <0x%.8x>\n",
			  status));
              return (NFM_E_MEM);
            }
         }
        else if (item_is_co && (! strcmp (data [count + a], "n_cofilename")))
         {
           status = MEMwrite_data (*attr_list,
                    "N", x + 1, upd_pos + 1);
           if (status != MEM_S_SUCCESS)
            {
              free (sql_str);
              free (sql_str1);
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (value_list);
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _NFMdebug ((fname, "Wr Data : status = <0x%.8x>\n",
			  status));
              return (NFM_E_MEM);
            }
         }
        else if (! strcmp (data [count + a], "n_updater"))
         {
	   if (comma)
	     strcat (sql_str, ",") ;
	   else
	     comma =1 ;
	   sprintf (tmp_str, "%s = '%s'",
		    data [count+a], NFMglobal.NFMusername) ;
	   strcat (sql_str, tmp_str) ;

           for (y = 0; y < z; ++y)
            {
              status = MEMwrite_data (*data_list,
                       user_name, z + 1, x + 1);
              if (status != MEM_S_SUCCESS)
               {
                 free (sql_str);
                 free (sql_str1);
                 MEMclose (attr_list);
                 MEMclose (data_list);
                 MEMclose (value_list);
		 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
                 _NFMdebug ((fname, "Wr Data : status = <0x%.8x>\n",
			     status));
                 return (NFM_E_MEM);
               }
            }
         }
        else if (! strcmp (data [count + a], "n_updatedate"))
         {
	   if (comma)
	     strcat (sql_str, ",") ;
	   else
	     comma =1 ;
	   status = NFMget_RISdatetime (RISdate) ;
	   if (status != NFM_S_SUCCESS)
	     {
	       _NFMdebug ((fname, "Get Date & Time : status = <0x%.8x>\n",
			   status));
	       return (status);
	     }

	   sprintf (tmp_str, "%s = TIMESTAMP '%s'",
		    data [count+a], RISdate) ;
	   strcat (sql_str, tmp_str) ;

           for (y = 0; y < z; ++y)
            {
              status = MEMwrite_data (*data_list, date, z + 1, x + 1);
              if (status != MEM_S_SUCCESS)
               {
                 free (sql_str);
                 free (sql_str1);
                 MEMclose (attr_list);
                 MEMclose (data_list);
                 MEMclose (value_list);
		 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
                 _NFMdebug ((fname, "Wr Data : status = <0x%.8x>\n",
			     status));
                 return (NFM_E_MEM);
               }
            }
         }
      }

     strcat (sql_str, sql_str1);

     free (sql_str1);

     status = NFMstop_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        free (sql_str);
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "Stop Transaction : status = <0x%.8x>\n",
		    status));
        return (status);
      }
    
     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS)
      {
        free (sql_str);
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        NFMrollback_transaction (0);
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug ((fname,  "SQL Stmt Syntax : status = <0x%.8x>\n",
		    status)) ;
        return (NFM_E_SQL_STMT);
      }

     free (sql_str);

     status = NFMset_process_lock (NFMglobal.NFMuserid, NFM_I_PL_UPDATE);
     if (status != NFM_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "Upd Item Proc Lock : status = <0x%.8x>\n",
        status));
        return (status);
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);     
   }

 long NFMcancel_update_item (user_id, attr_list, data_list)
   long    user_id;
   MEMptr  attr_list, data_list;
   {
     long     status;
     char *fname = "NFMcancel_update_item" ;

     _NFMdebug ((fname, "ENTER\n")) ;
     attr_list = attr_list ;
     user_id = user_id ;
     if ((data_list == NULL) || (data_list->rows == 0))
       {
	 _NFMdebug ((fname, "CORRUPTED BUFFER\n")) ;
	 ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", "") ;
	 return (NFM_E_CORRUPTED_BUFFERS) ;
       }

     status = NFMcheck_process_locks (NFMglobal.NFMuserid);
     if ((status != NFM_S_SUCCESS) && (status != NFM_I_PL_UPDATE))
      {
        ERRload_struct (NFM, NFM_E_BAD_COMMAND_ORDER, "", NULL);
        _NFMdebug ((fname, "Check Process Lock : status = <0x%.8x>\n",
        NFM_E_BAD_COMMAND_ORDER));
        return (NFM_E_BAD_COMMAND_ORDER);
      }

     if (status == NFM_I_PL_UPDATE)
      {
        status = NFMreset_process_lock (NFMglobal.NFMuserid, NFM_I_PL_UPDATE);
        if (status != NFM_S_SUCCESS)
         {
           NFMrollback_transaction (0);
           _NFMdebug ((fname, "Reset Proc Lock : status = <0x%.8x>\n", 
           status));
           return (status);
         }
      }

     status = NFMrollback_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Roll Back Trans : status = <0x%.8x>\n", 
        status));
        return (status);
      }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);     
   }

 long NFMupdate_item (user_id, cat_name, attr_list, data_list)
   long    user_id;
   char    *cat_name;
   MEMptr  attr_list;
   MEMptr  data_list;
   {
     char *fname = "NFMupdate_item" ;
     long     status;
     long     atol() ;
     int      off, num_of_files ;
     MEMptr   attr_list1 = NULL, data_list1 = NULL;
     MEMptr   attr_list2 = NULL, data_list2 = NULL;
     char     **data_ptr ;
     long     NFMupdate_catalog_entry ();
     long     NFMupdate_file_catalog_entry () ;
     long     _NFMrollback_file_operation (), item_no ;
     char     coout[5] ;

     _NFMdebug ((fname, "catalog = <%s>\n", cat_name));
     user_id = user_id ;
     status = NFMcheck_process_locks (NFMglobal.NFMuserid);
     if ((status != NFM_S_SUCCESS) && (status != NFM_I_PL_UPDATE))
      {
	NFMrollback_transaction (0) ;
        ERRload_struct (NFM, NFM_E_BAD_COMMAND_ORDER, "", NULL);
        _NFMdebug ((fname, "Check Process Lock : status = <0x%.8x>\n",
        NFM_E_BAD_COMMAND_ORDER));
        return (NFM_E_BAD_COMMAND_ORDER);
      }

     if (status == NFM_I_PL_UPDATE)
      {
        status = NFMreset_process_lock (NFMglobal.NFMuserid, NFM_I_PL_UPDATE);
        if (status != NFM_S_SUCCESS)
         {
	   NFMrollback_transaction (0) ;
           _NFMdebug ((fname, "Reset Process Lock : status = <0x%.8x>\n", 
           status));
           return (status);
         }
      }

     status = NFMsplit_catalog_attributes (NFMglobal.NFMuserid,
					   attr_list, data_list,
					   &attr_list1, &data_list1, 
					   &attr_list2, &data_list2);
       if (status != NFM_S_SUCCESS)
      {
	NFMrollback_transaction (0) ;
        MEMclose (&attr_list1);
        MEMclose (&attr_list2);
        MEMclose (&data_list1);
        MEMclose (&data_list2);
        _NFMdebug ((fname, "Split Cat List : status = <0x%.8x>\n", status));
        return (status);
      }

     status = MEMbuild_array (data_list1) ;
     if (status != MEM_S_SUCCESS)
       {
        MEMclose (&attr_list1);
        MEMclose (&attr_list2);
        MEMclose (&data_list1);
        MEMclose (&data_list2);
        NFMrollback_transaction (0);
         _NFMdebug ((fname, "Update File Entry : status = <0x%.8x>\n",
        status));
        return (status);
      }

     data_ptr = (char **) data_list1->data_ptr ;

     status = _NFMfind_column_offset (data_list1, "n_status", &off) ;
     if (status != NFM_S_SUCCESS)
       {
        MEMclose (&attr_list1);
        MEMclose (&attr_list2);
        MEMclose (&data_list1);
        MEMclose (&data_list2);
        NFMrollback_transaction (0);
         _NFMdebug ((fname, "Update File Entry : status = <0x%.8x>\n",
        status));
        return (status);
      }

     sprintf (coout, "%s", data_ptr[off]) ;

     status = _NFMfind_column_offset (data_list1, "n_itemno", &off) ;
     if (status != NFM_S_SUCCESS)
       {
        MEMclose (&attr_list1);
        MEMclose (&attr_list2);
        MEMclose (&data_list1);
        MEMclose (&data_list2);
        NFMrollback_transaction (0);
         _NFMdebug ((fname, "Update File Entry : status = <0x%.8x>\n",
        status));
        return (status);
      }
     
     item_no = atol (data_ptr [off]) ;

     status = NFMupdate_file_catalog_entry (NFMglobal.NFMuserid, cat_name,
              attr_list2, data_list2, coout, item_no) ;
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (&attr_list1);
        MEMclose (&attr_list2);
        MEMclose (&data_list1);
        MEMclose (&data_list2);
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "Update File Entry : status = <0x%.8x>\n",
        status));
        return (status);
      }

     num_of_files = data_list2 -> rows/2 ;

     status = NFMupdate_catalog_entry (NFMglobal.NFMuserid, cat_name,
              attr_list1, data_list1);

     if (status != NFM_S_SUCCESS)
      {
	_NFMrollback_file_operation (cat_name, attr_list2, data_list2, 
			     coout, num_of_files) ;
        MEMclose (&attr_list1);
        MEMclose (&attr_list2);
        MEMclose (&data_list1);
        MEMclose (&data_list2);
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "Update Item Entry : status = <0x%.8x>\n",
        status));
        return (status);
      }

     status = MEMclose (&attr_list1);
     if (status != MEM_S_SUCCESS)
      {
	_NFMrollback_file_operation (cat_name, attr_list2, 
			     data_list2, 
			     coout,num_of_files) ;
        MEMclose (&attr_list2);
        MEMclose (&data_list1);
        MEMclose (&data_list2);
        NFMrollback_transaction (0);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM CLose : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     status = MEMclose (&attr_list2);
     if (status != MEM_S_SUCCESS)
      {
	_NFMrollback_file_operation (cat_name, attr_list2, data_list2, 
			     coout,num_of_files) ;
        MEMclose (&data_list1);
        MEMclose (&data_list2);
        NFMrollback_transaction (0);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM CLose : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     status = MEMclose (&data_list1);
     if (status != MEM_S_SUCCESS)
      {
	_NFMrollback_file_operation (cat_name,  attr_list2, data_list2, 
			     coout, num_of_files) ;
        MEMclose (&data_list2);
        NFMrollback_transaction (0);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM CLose : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     status = MEMclose (&data_list2);
     if (status != MEM_S_SUCCESS)
      {
	_NFMrollback_file_operation (cat_name, attr_list2, data_list2, 
			     coout, num_of_files) ;
        NFMrollback_transaction (0);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM CLose : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     status = NFMstart_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
	NFMrollback_transaction (0) ;
	_NFMrollback_file_operation (cat_name, attr_list2, data_list2, 
			     coout, num_of_files) ;
        _NFMdebug ((fname, "Start Transaction : status = <0x%.8x>\n",
        status));
        return (status);
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMupdate_catalog_entry (user_id, cat_name, attr_list, data_list)
   long    user_id;
   char    *cat_name;
   MEMptr  attr_list, data_list;
   {
     char *fname = "NFMupdate_catalog_entry" ;
     long     status, atol ();
     long     x, y, count, count1;
     long     a, b, d, comma, update;
     char     **column, **data, **data1, date [30], out_str [51] ;
     char     *sql_str, *sql_str1;

     _NFMdebug ((fname, "Cat  Name = <%s>\n", cat_name));
     user_id = user_id ;
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

     a = -1; b = -1; d = -1;

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))      a = y;
        else if (! strcmp (column [y], "n_datatype"))  b = y;
        else if (! strcmp (column [y], "n_update"))   d = y;
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

     sprintf (sql_str,  "UPDATE %s SET ", cat_name);
     sprintf (sql_str1, " WHERE ");

     count1 = (data_list -> rows / 2) * data_list -> columns;

     for (x = 0; x < attr_list -> rows; ++x)
      {
         count = attr_list -> columns * x;
         update = 0;

         if (! strcmp (data [count + a], "n_itemno"))
          {
            strcat (sql_str1, data [count + a]);
            strcat (sql_str1, " = ");
            strcat (sql_str1, data1 [count1 + x]);
          }
         else if (! strcmp (data [count + a], "n_updater"))    
	   {
	       update = 1;
	       status = MEMwrite_data (data_list, NFMglobal.NFMusername, 
				       1, x + 1);
	       if (status != MEM_S_SUCCESS)
		 {
		   free (sql_str);
		   free (sql_str1);
		   ERRload_struct (NFM, NFM_E_MEM, "", NULL);
		   _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			       status));
		   return (NFM_E_MEM);
		 }
	     }
         else if (! strcmp (data [count + a], "n_updatedate"))
	   {
	     update = 1;
	     status = NFMget_datetime (date) ;
	     if (status != NFM_S_SUCCESS)
	       {
		 _NFMdebug ((fname, "Get Date & Time : status = <0x%.8x>\n",
			     status));
		 return (status);
	       }
	     
	     status = MEMwrite_data (data_list, date, 1, x + 1);
	     if (status != MEM_S_SUCCESS)
	       {
		 free (sql_str);
		 free (sql_str1);
		 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
		 _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			     status));
		 return (NFM_E_MEM);
	       }
	   }
         else if (! strcmp (data [count + a], "n_itemlock"))
          {
            update = 1;

            status = MEMwrite_data (data_list, "N", 1, x + 1);
            if (status != MEM_S_SUCCESS)
             {
               free (sql_str);
               free (sql_str1);
               ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			   status));
               return (NFM_E_MEM);
             }
          }
         else if ((strcmp (data1 [count1 + x], data1 [x])) &&
		  (strcmp (data [count + d], "Y") == 0))
	   update = 1;
	 
	 
	 if (update)
	   {
	     if (comma)
	       strcat (sql_str,  ", ");
	     comma = 1;
	     
	     strcat (sql_str, data [count + a]);
	     strcat (sql_str, " = ");
	     
	     if (! strncmp (data [count + b], "char", 4))
	       {
		 strcat (sql_str, "'");
		 strcat (sql_str, data1 [x]);
		 strcat (sql_str, "'");
	       }
	     else if (!strcmp (data [count + b], "timestamp"))
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
     
     
     if (comma)
       {
	 strcat (sql_str, sql_str1);
	 
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
       }
	 
     free (sql_str);
     free (sql_str1);
     
     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
	       NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

long NFMupdate_file_catalog_entry (user_id, cat_name,
                                    attr_list, data_list,
                                    coout, item_no)
   long    user_id;
   char    *cat_name;
   MEMptr  attr_list, data_list;
   char    *coout ;
   long    item_no ;
   {
     char *fname = "NFMupdate_file_catalog_entry" ;
     long    status, atol (), num_of_files ;
     long    a, b, x, y, d, z;
     long    count, new_offset, old_offset, comma, update ;
     long    move_file ;
     long    file_no=-1, cat_no, netid, i, offset ;
     long    no_filenum_0 , no_entries, cisano_flag, n_filenum ;
     char    *sql_str, *sql_str1, tmp_str [512] ;
     char    **column, **data, **data1, **datax ;
     char    file_type [20], file_cat [100], file [100] ;
     char    new_file [100], old_file [100],new_cofile [100],old_cofile [100] ;
     char    old_sa [10], new_sa [10], co_sa [10], n_fileco [NFM_FILECO+1] ;
     MEMptr  move_buffer = NULL, sql_buffer = NULL ;
     struct  fto_buf file_buffer ;
     long    NFMcheck_sa_mappings () ;
     long    _NFMrollback_file_operation ();
     MEMptr  return_buffer  = NULL, remove_buffer = NULL ;

     _NFMdebug ((fname, "Cat  Name = <%s> : Item No = <%d> : File status = <%s>\n", 
		 cat_name, item_no, coout));
     user_id = user_id ;

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

     column  = (char **) attr_list -> column_ptr;
     data    = (char **) attr_list -> data_ptr;

     data1   = (char **) data_list -> data_ptr;

     a = -1; b = -1; d = -1;

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))      a = y;
        else if (! strcmp (column [y], "n_datatype"))  b = y;
        else if (! strcmp (column [y], "n_update"))    d = y;
      }

     sql_str = (char *) malloc (50 * attr_list -> rows     +
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

     sprintf (file_cat, "f_%s", cat_name);

     status = NFMget_catalog_no (NFMglobal.NFMuserid, cat_name, &cat_no);
     if (status != NFM_S_SUCCESS)
       {
	 free (sql_str);
	 free (sql_str1);
	 _NFMdebug ((fname, "Get Cat No : status = <0x%.8x>\n",
	    status));
	 return (status);
       }

     num_of_files = data_list->rows/2 ;
     cisano_flag = 0 ;
     n_filenum = -1;
     for (z=0; z<num_of_files; z++)
       {
	 _NFMdebug ((fname, "FILE <%d>\n", z+1)) ;
	 sql_str [0] = 0;  sql_str1 [0] = 0; comma = 0;  
	 
	 sprintf (sql_str,  "UPDATE %s SET ", file_cat);
	 sprintf (sql_str1, " WHERE ");
	 
	 move_file = 0 ;
	 old_offset = ((z+num_of_files)*data_list->columns) ;
	 new_offset = (z*data_list->columns) ;

	 for (x = 0; x < attr_list -> rows; ++x)
	   {
	     update = 0;
	     
	     count = attr_list -> columns * x;
	 
	     if (! strcmp (data [count + a], "n_fileno"))
	       {
		 strcat (sql_str1, data [count + a]);
		 strcat (sql_str1, " = ");
		 strcat (sql_str1, data1 [old_offset + x]);
		 
		 file_no = atol (data1 [old_offset + x]);
	       }
	     else if (! strcmp (data [count + a], "n_fileco"))
	       {
		 strcpy (n_fileco, data1 [old_offset + x]) ;
	       }
	     else if (! strcmp (data [count + a], "n_cifilename"))
	       {
		 new_file [0] = 0;
		 old_file [0] = 0;
		 
		 if (strcmp (data1 [new_offset + x], data1 [old_offset + x]))
		   {
		     update = 1;                     
		     move_file = 1;
		     sprintf (new_file, "%s", data1 [new_offset + x]);
		   }
		 else
		   {
		     update = 0;                  
		     /* if there is no changes in cifilename
			copy into newfilename the oldfilename */
		     sprintf (new_file, "%s", data1[old_offset + x]) ;
		   }
		 
		 sprintf (old_file, "%s", data1 [old_offset + x]);
	       }
	     else if (! strcmp (data [count + a], "n_cisano"))
	       {
		 new_sa [0] = 0;
		 old_sa [0] = 0;
		 cisano_flag = 0 ;
		 
		 if (strcmp (data1 [new_offset + x], data1 [old_offset + x]))
		   {
		     cisano_flag = 1 ;
		     status = NFMcheck_sa_no (NFMglobal.NFMuserid, 
                                              atol (data1 [new_offset + x])) ;
		     if (status != NFM_S_SUCCESS)
		       {
			 _NFMrollback_file_operation (cat_name, 
					      attr_list, data_list, 
					      coout, z) ;
			 free (sql_str);
			 free (sql_str1);
			 _NFMdebug ((fname, "Bad Sa : status = <0x%.8x>\n",
			    status));
			 return (status);
		       }

		     status = NFMcheck_sa_mappings (NFMglobal.NFMuserid, cat_no, item_no,
						    atol (data1 [new_offset + x]));
		     if (status != NFM_S_SUCCESS)
		       {
			 _NFMrollback_file_operation (cat_name,
					      attr_list, data_list, 
					      coout,z) ;
			 free (sql_str);
			 free (sql_str1);
			 _NFMdebug ((fname, "Bad Sa : status = <0x%.8x>\n",
			    status));
			 return (status);
		       }
		     
		     update = 1;
		     move_file = 1;
		     sprintf (new_sa, "%s", data1 [new_offset + x]);
		   }
		 else
		   update = 0;                  
		 sprintf (old_sa, "%s", data1 [old_offset + x]);
	       }
	     else if (! strcmp (data [count + a], "n_cofilename"))
	       {
		 new_cofile [0] = 0;
		 old_cofile [0] = 0;
		 _NFMdebug ((fname, "old cofilename <%s> : new cofilename <%s> : n_status <%s>\n",
			     data1 [old_offset+x], data1 [new_offset + x],
			     coout)) ;
		 
		 /* if old cofilename = "" and new cofilename != "" and n_status flag is blank -> n_filenum = 1 */
		 if (!strlen (data1 [old_offset+x]) &&
		     (strlen (data1 [new_offset + x])) &&
		     (! strcmp (coout, "")))
		   {
		     if (comma)
		       {
			 strcat (sql_str, ",") ;
		       }
		     else comma = 1 ;
		     strcat (sql_str, "n_filenum = 1") ;
		   }
		 else
		 /* if old cofilename != "" and new cofilename = "" and n_status flag is blank -> n_filenum = 0 */
		 if (strlen (data1 [old_offset+x]) &&
		     (!strlen (data1 [new_offset + x])) &&
		     (! strcmp (coout, "")))
		   {
		     if (comma)
		       {
			 strcat (sql_str, ",") ;
		       }
		     else comma = 1 ;
		     strcat (sql_str, "n_filenum = 0") ;
		   }

		 if (strcmp (data1 [new_offset + x], data1 [old_offset + x]))
		   {
		     update = 1;                     
		     sprintf (new_cofile, "%s", data1 [new_offset + x]);
		   }
		 else
		   {
		     update = 0;                  
		     sprintf (new_cofile, "%s", data1[old_offset + x]) ;
		   }
		 
		 sprintf (old_cofile, "%s", data1 [old_offset + x]);

	       }
	     else if (! strcmp (data [count + a], "n_cosano"))
	       {
		 strcpy (co_sa, data1 [old_offset +x]) ;
	       }
	     else if (! strcmp (data [count + a], "n_filetype"))
	       {
		 if (! strcmp (data1 [new_offset + x], data1 [old_offset + x]))
		   {
		     strcpy (file_type, data1 [old_offset +x]) ;
		   }
		 else
		   {
		     strcpy (file_type, data1 [new_offset + x]) ;
		     update = 1 ;
		   }
	       }
	     else if (! strcmp (data [count + a], "n_filenum"))
	       {
		 n_filenum = atol (data1 [old_offset + x]) ;
	       }
	     else if ((strcmp (data1 [new_offset + x], data1 [old_offset + x])) &&
		      (strcmp (data [count + d], "Y") == 0))
	       update = 1;
	     
	     if (update)
	       {
		 if (comma)
		   strcat (sql_str,  ", ");
		 comma = 1;
		 
		 strcat (sql_str, data [count + a]);
		 strcat (sql_str, " = ");
		 
		 if (! strncmp (data [count + b], "char", 4))
		   {
		     strcat (sql_str, "'");
		     strcat (sql_str, data1 [new_offset + x]);
		     strcat (sql_str, "'");
		   }
		 else
		   {
		     if (strlen (data1 [new_offset + x])) 
		       strcat (sql_str, data1 [new_offset + x]);
		     else                    
		       strcat (sql_str, "null");   
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
		 free (sql_str1);
		 
		 if (status == SQL_E_DUPLICATE_VALUE)
		   {
		     _NFMrollback_file_operation (cat_name, attr_list, data_list, 
					  coout,z) ;
		     ERRload_struct (NFM, NFM_E_DUP_FILE, "", NULL);
		     _NFMdebug ((fname, "Item Exst : status = <0x%.8x>\n",
			       NFM_E_DUP_FILE));
		     return (NFM_E_DUP_FILE);
		   }
		 _NFMrollback_file_operation (cat_name, attr_list, data_list, 
				      coout,z);
		 ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
		 _NFMdebug ((fname, "Stmt Syntax : status = <0x%.8x>\n",
			     status));
		 return (NFM_E_SQL_STMT);
	       }
	     
	     if (! strlen (new_sa)) sprintf (new_sa, "%s", old_sa);

	     if ((move_file && (atol (new_sa) > 0)) && (strcmp (coout, "")))
	       {
		 _NFMdebug ((fname, "move file %s <sa %s> to %s <sa %s>\n",
			     old_file, old_sa, new_file, new_sa)) ;
		 if (strcmp (n_fileco, "O"))
		   {
		     _NFMdebug ((fname, "cifile exists\n")) ;
		     status = NFMget_file_name (NFMglobal.NFMuserid, cat_no, 
						file_no,
						file);
		     if (status != NFM_S_SUCCESS)
		       {
			 _NFMrollback_file_operation (cat_name, attr_list, 
					      data_list, 
					      coout,z);
			 free (sql_str);
			 free (sql_str1);
			 _NFMdebug ((fname, "Get File Name : status = <0x%.8x>\n",
				     status));
			 return (status);
		       }

		     sql_str [0] = 0;
		     
		     if (! strlen (new_file)) strcpy (new_file, file) ;
		     
		     if (! strlen (old_file)) strcpy (old_file, file) ;

		     status = _NFMget_sano_info_fto_buf (atol (old_sa),
							 "",
							 &file_buffer) ;
		     if (status != NFM_S_SUCCESS)
		       {
			 _NFMrollback_file_operation (cat_name, 
					      attr_list, data_list, 
					      coout,z);
			 free (sql_str);
			 free (sql_str1);
			 _NFMdebug ((fname, " Bad Storage Area : status = <0x%.8x>\n",
				     status)) ;
			 return (status) ;
		       }

		     status = NFMbuild_fto_buffer (&move_buffer, MEM_SIZE) ;
		     if (status != NFM_S_SUCCESS)
		       {
                         _NFMrollback_file_operation (cat_name,
                                              attr_list, data_list,
                                              coout, z) ;
			 free (sql_str) ;
			 free (sql_str1);
			 MEMclose (&move_buffer);
			 _NFMdebug ((fname, "Build fto buffer failed : status = <0x%.8x>\n",
				     status)) ;
			 return (status) ;
		       }

		     status = NFMload_fto_buf (&move_buffer, &file_buffer) ;
		     if (status != NFM_S_SUCCESS)
		       {
                         _NFMrollback_file_operation (cat_name,
                                              attr_list, data_list,
                                              coout, z) ;
			 _NFMdebug ((fname, "Loading second row failed : status = <0x%.8x>\n",
				     status)) ;
			 return (status) ;
		       }

		     status = _NFMget_sano_info_fto_buf (atol (new_sa),
							 "",
							 &file_buffer) ;
		     if (status != NFM_S_SUCCESS)
		       {
			 _NFMrollback_file_operation (cat_name, 
					      attr_list, data_list, 
					      coout,z);
			 free (sql_str);
			 free (sql_str1);
			 _NFMdebug ((fname, " Bad Storage Area : status = <0x%.8x>\n",
				     status)) ;
			 return (status) ;
		       }
		     strcpy (file_buffer.n_cifilename, new_file) ;
		     strcpy (file_buffer.n_cofilename, old_file) ;
		     file_buffer.n_status1 = NFM_MOVE ;
		     
		     status = NFMload_fto_buf (&move_buffer, &file_buffer) ;
		     if (status != NFM_S_SUCCESS)
		       {
                         _NFMrollback_file_operation (cat_name,
                                              attr_list, data_list,
                                              coout, z) ;
			 _NFMdebug ((fname, "Loading second row failed : status = <0x%.8x>\n",
				     status)) ;
			 return (status) ;
		       }

		     /* remove */		 
		     status = _NFMget_sano_info_fto_buf (atol (old_sa),
							 "",
							 &file_buffer) ;
		     if (status != NFM_S_SUCCESS)
		       {
			 _NFMrollback_file_operation (cat_name, 
					      attr_list, data_list, 
					      coout,z);
			 free (sql_str);
			 free (sql_str1);
			 _NFMdebug ((fname, " Bad Storage Area : status = <0x%.8x>\n",
				     status)) ;
			 return (status) ;
		       }

		     if (! remove_buffer)
		       {
			 status = NFMbuild_fto_buffer (&remove_buffer, MEM_SIZE) ;
			 if (status != NFM_S_SUCCESS)
			   {
			     _NFMrollback_file_operation (cat_name,
						  attr_list, data_list,
						  coout, z) ;
			     free (sql_str) ;
			     free (sql_str1);
			     MEMclose (&move_buffer);
			     MEMclose (&remove_buffer) ;
			     _NFMdebug ((fname, "Build fto buffer failed : status = <0x%.8x>\n",
					 status)) ;
			     return (status) ;
			   }
		       }

		     strcpy (file_buffer.n_cifilename, old_file) ;
		     file_buffer.n_status1 = NFM_DELETE_FILE ;
		     
		     status = NFMload_fto_buf (&remove_buffer, &file_buffer) ;
		     if (status != NFM_S_SUCCESS)
		       {
                         _NFMrollback_file_operation (cat_name,
                                              attr_list, data_list,
                                              coout, z) ;
			 _NFMdebug ((fname, "Loading second row failed : status = <0x%.8x>\n",
				     status)) ;
			 return (status) ;
		       }
		   }

		 if (cisano_flag)
		   {
		     _NFMdebug ((fname, "internal sa changed\n")) ;
		     sprintf (tmp_str, "select n_fileno, n_fileco from f_%s \
where n_fileversion != (select max(n_fileversion) from f_%s where n_itemnum = %d) and n_fileversion != 0 and n_filenum = %d and n_itemnum = %d",
			      cat_name, cat_name, item_no, 
			      n_filenum, item_no) ;
		     status = SQLquery (tmp_str, &sql_buffer, MEM_SIZE) ;
		     if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
		       {
                         _NFMrollback_file_operation (cat_name,
                                              attr_list, data_list,
                                              coout, z) ;
			 _NFMdebug ((fname, "Failure : Sql query : status = <0x%..8x>\n",
				     status)) ;
			 ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
			 return (NFM_E_SQL_QUERY) ;
		       }

		     if (status != SQL_I_NO_ROWS_FOUND)
		       {
			 status = MEMbuild_array (sql_buffer) ;
			 if (status != MEM_S_SUCCESS)
			   {
			     _NFMrollback_file_operation (cat_name,
						  attr_list, data_list,
						  coout, z) ;
			     _NFMdebug ((fname, "Failure : MEMbuild_array : status = <0x%.8x>\n",
					 status)) ;
			     ERRload_struct (NFM, NFM_E_MEM, "", "") ;
			     return (NFM_E_MEM) ;
			   }
			 datax = (char **) sql_buffer->data_ptr ;

			 for (i=0; i<sql_buffer->rows; i++)
			   {
			     offset = i*sql_buffer->columns ;
			     sprintf (tmp_str, "Update f_%s set n_cisano = %s where n_fileno = %s",
				      cat_name, new_sa, 
				      datax [offset]) ;
			     status = SQLstmt (tmp_str) ;
			     if (status != SQL_S_SUCCESS)
			       {
				 _NFMrollback_file_operation (cat_name,
						      attr_list, data_list,
						      coout, z) ;
				 _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",
					     status)) ;
				 ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
				 return (NFM_E_SQL_STMT) ;
			       }
			     
			     if (strcmp (datax [offset+1], "O"))
			       {
				 status = NFMget_file_name (NFMglobal.NFMuserid, 
							    cat_no, 
							    atol(datax [offset]),
							    file);
				 if (status != NFM_S_SUCCESS)
				   {
				     _NFMrollback_file_operation (cat_name,
							  attr_list, data_list,
							  coout, z) ;
				     free (sql_str);
				     free (sql_str1);
				     _NFMdebug ((fname, "Get File Name : status = <0x%.8x>\n",
						 status));
				     return (status);
				   }
				 _NFMdebug ((fname, "move file %s\n", file)) ;
				 sql_str [0] = 0;
				 
			       strcpy(new_file, file) ;

				 strcpy (old_file, file) ;
				 if (! move_buffer)
				   {
				     status = _NFMget_sano_info_fto_buf (atol (old_sa),
									 "",
									 &file_buffer) ;
				     if (status != NFM_S_SUCCESS)
				       {
					 _NFMrollback_file_operation (cat_name,
							      attr_list, data_list,
							      coout, z) ;

					 free (sql_str);
					 free (sql_str1);
					 _NFMdebug ((fname, " Bad Storage Area : status = <0x%.8x>\n",
						     status)) ;
					 return (status) ;
				       }

				     status = NFMbuild_fto_buffer (&move_buffer, MEM_SIZE) ;
				     if (status != NFM_S_SUCCESS)
				       {
					 _NFMrollback_file_operation (cat_name,
							      attr_list, data_list,
							      coout, z) ;
					 free (sql_str) ;
					 free (sql_str1);
					 MEMclose (&move_buffer);
					 _NFMdebug ((fname, "Build fto buffer failed : status = <0x%.8x>\n",
						     status)) ;
					 return (status) ;
				       }

				     status = NFMload_fto_buf (&move_buffer, &file_buffer) ;
				     if (status != NFM_S_SUCCESS)
				       {
					 _NFMrollback_file_operation (cat_name,
							      attr_list, data_list,
							      coout, z) ;
					 _NFMdebug ((fname, "Loading second row failed : status = <0x%.8x>\n",
						     status)) ;
					 return (status) ;
				       }
				   }
				 status = _NFMget_sano_info_fto_buf (atol (new_sa),
								     "",
								     &file_buffer) ;
				 if (status != NFM_S_SUCCESS)
				   {
				     _NFMrollback_file_operation (cat_name,
							  attr_list, data_list,
							  coout, z) ;
				     free (sql_str);
				     free (sql_str1);
				     _NFMdebug ((fname, " Bad Storage Area : status = <0x%.8x>\n",
						 status)) ;
				     return (status) ;
				   }
				 strcpy (file_buffer.n_cifilename, new_file) ;
				 strcpy (file_buffer.n_cofilename, old_file) ;
				 file_buffer.n_status1 = NFM_MOVE ;
				 
				 status = NFMload_fto_buf (&move_buffer, &file_buffer) ;
				 if (status != NFM_S_SUCCESS)
				   {
				     _NFMrollback_file_operation (cat_name,
							  attr_list, data_list,
							  coout, z) ;
				     _NFMdebug ((fname, "Loading second row failed : status = <0x%.8x>\n",
						 status)) ;
				     return (status) ;
				   }
			     
			     /* send file */
				 /*****
				   status = _NFMfs_send_files (&move_buffer,  &netid, 1) ;
				   if (status != NFM_S_SUCCESS)
				   {
				   _NFMdebug ((fname, "Send files failed : status = <0x%.8x>\n",
				   status)) ;
				   return (status) ;
				   }
				   
				   status = MEMclose (&move_buffer) ;
				   if (status != MEM_S_SUCCESS)
				   {
				   _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n",
				   status)) ;
				   ERRload_struct (NFM, NFM_E_MEM, "", "") ;
				   return (NFM_E_MEM) ;
				   }
				   ****/
				 /* remove */		 
				 
				 status = _NFMget_sano_info_fto_buf (atol (old_sa),
								     "",
								     &file_buffer) ;
				 if (status != NFM_S_SUCCESS)
				   {
				     _NFMrollback_file_operation (cat_name,
							  attr_list, data_list,
							  coout, z) ;
				     free (sql_str);
				     free (sql_str1);
				     _NFMdebug ((fname, " Bad Storage Area : status = <0x%.8x>\n",
						 status)) ;
				     return (status) ;
				   }
				 
				 if (! remove_buffer)
				   {
				     status = NFMbuild_fto_buffer (&remove_buffer, MEM_SIZE) ;
				     if (status != NFM_S_SUCCESS)
				       {
					 _NFMrollback_file_operation (cat_name,
							      attr_list, data_list,
							      coout, z) ;
					 free (sql_str) ;
					 free (sql_str1);
					 MEMclose (&move_buffer);
					 _NFMdebug ((fname, "Build fto buffer failed : status = <0x%.8x>\n",
						     status)) ;
					 return (status) ;
				       }
				   }

				 strcpy (file_buffer.n_cifilename, old_file) ;
				 file_buffer.n_status1 = NFM_DELETE_FILE ;
				 
				 status = NFMload_fto_buf (&remove_buffer, &file_buffer) ;
				 if (status != NFM_S_SUCCESS)
				   {
				     _NFMdebug ((fname, "Loading second row failed : status = <0x%.8x>\n",
						 status)) ;
				     return (status) ;
				   }
				 /***			     
			     status = NFMfs_chg_files (&move_buffer) ;
			     if (status != NFM_S_SUCCESS)
			     {
			     _NFMdebug ((fname, "Remove files failed : status = <0x%.8x>\n",
			     status)) ;
			     return (status) ;
			     }
			     
			     status = MEMclose (&move_buffer) ;
			     if (status != MEM_S_SUCCESS)
			     {
			     _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n",
			     status));
			     return (NFM_E_MEM) ;
			     }
			     *******/
			       } /* n_fileco = "O" */
			   } /* for i */
		       }  /* state == SQL_I_NO_ROWS_FOUND*/
		     
		   } /* if cisano_flag */

		 if (move_buffer)
		   {
		     status = _NFMfs_send_files (&move_buffer, &netid, 1) ;
		     if (status != NFM_S_SUCCESS)
		       {
			 _NFMfs_undo_send_files (&move_buffer, &netid, 1) ;
			 _NFMdebug ((fname, "Send files failed : status = <0x%l8x>\n",
				     status)) ;
                         _NFMrollback_file_operation (cat_name,
                                              attr_list, data_list,
                                              coout, z) ;
			 return (status) ;
		       }
		   }

		 if (remove_buffer)
		   {
		     status = NFMfs_chg_files (&remove_buffer) ;
		     if (status != NFM_S_SUCCESS)
		       {
			 _NFMfs_undo_send_files (&move_buffer, &netid, 1) ;
			 NFMfs_undo_chg_files (&remove_buffer) ;
			 _NFMrollback_file_operation (cat_name, attr_list, data_list,
					      coout, z) ;
			 _NFMdebug ((fname, "Change buffer failed : status = <0x%.8x>\n",
				     status)) ;
			 return (status) ;
		       }
		   }
		 MEMclose (&move_buffer) ;
		 MEMclose (&remove_buffer) ;
	       }
	   }
       }


     free (sql_str);
     free (sql_str1);
     
     /* in multiple files per item -> if any f_catalog entry has n_filenum = 0 then delete this entry */

     sprintf (tmp_str, 
	      "Select n_filenum, n_fileno from %s where n_itemnum = %d",
	      file_cat, item_no) ;
     _NFMdebug ((fname, "temp_str is %s\n", tmp_str)) ;

     status = SQLquery (tmp_str, &return_buffer, MEM_SIZE) ;
     if (status != SQL_S_SUCCESS)
       {
	 MEMclose (&return_buffer) ;
	 if (status != SQL_I_NO_ROWS_FOUND)
	   {
	     _NFMrollback_file_operation (cat_name,
				  attr_list, data_list,
				  coout, num_of_files) ;
	     ERRload_struct (NFM, NFM_E_BAD_ITEM, "", "") ;
	     _NFMdebug ((fname, "Failure : No entries in f catalog for item %d\n", 
			 item_no)) ;
	     return (NFM_E_BAD_ITEM) ;
	   }
	 _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
	 ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
	 return (NFM_E_SQL_QUERY) ;
       }

     if (return_buffer -> rows > 1)
       {
/*       if any entry is n_filenum = 0 then delete */
	 status = MEMbuild_array (return_buffer) ;
	 if (status != MEM_S_SUCCESS)
	   {
	     _NFMrollback_file_operation (cat_name,
				  attr_list, data_list,
				  coout, num_of_files) ;
	     _NFMdebug ((fname, "Failure : MEMbuild_array : status = <0x%.8x>\n",
			 status)) ;
	     ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	     return (NFM_E_MEM) ;
	   }

	 data = (char **) return_buffer -> data_ptr ;
	 no_filenum_0 = 0 ;
	 for (i=0; i<return_buffer->rows; i++)
	   {
	     offset = i*return_buffer->columns ;
	     if (atol (data [offset]) == 0) ++no_filenum_0 ;
	   }


	 if (no_filenum_0)
	   {
/* if all are 0 , leave at least one in f_catalog */
	     if (no_filenum_0 == return_buffer->rows)
	       {
		 no_entries = return_buffer->rows-1 ;
	       }
	     else
	       {
		 no_entries = return_buffer->rows ;
	       }
	     for (i=0; i<no_entries; i++)
	       {
		 offset = return_buffer->columns * i ;
		 if (atol (data [offset]) == 0 )
		   {
		     sprintf (sql_str, "Delete from %s where n_fileno = %s",
			      file_cat, data [offset+1]) ;
		     status = SQLstmt (sql_str) ;
		     if ((status != SQL_S_SUCCESS)  && (status != SQL_I_NO_ROWS_FOUND))
		       {
                         _NFMrollback_file_operation (cat_name,
                                              attr_list, data_list,
                                              coout, num_of_files) ;
			 _NFMdebug ((fname, "Failure : Sql stmt : status = <0x%.8x>\n", 
				     status)) ;
			 ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
			 return (NFM_E_SQL_STMT) ;
		       }
		   }
	       }
	   }
       }

     MEMclose (&return_buffer) ;
     
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }


long NFMcheck_sa_mappings (user_id, cat_no, item_no, sa_no)
  long user_id;
  long cat_no ;
  long item_no ;
  long sa_no ;
{
  char *fname = "NFMcheck_sa_mappings" ;
  long status;
  int found, i ;
  char sql_str[1024], s_sa_no [10] ;
  char **data, sa_mapno [40] ;
  MEMptr sql_buffer = NULL; 

  _NFMdebug ((fname, "Catalog No <%d> : Item No <%d> : Storage Area <%d>\n", 
	      cat_no, item_no, sa_no));
  user_id = user_id ;
  /* Found out if storage area is valid mapped sa for this catalog */

  sprintf (sql_str,
	   "SELECT n_mapno, n_sano FROM NFMCATALOGSAMAP WHERE n_catalogno = %d",
	   cat_no) ;

  status = SQLquery (sql_str, &sql_buffer, 1024);
  
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
  {
     MEMclose (&sql_buffer);
     _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status));
   
     ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
     status = NFM_E_SQL_QUERY;
     _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status));
     return (status);
  }

  if (status == SQL_I_NO_ROWS_FOUND) 
    {
      MEMclose (&sql_buffer) ;
      _NFMdebug ((fname, "NO SA MAPPING DONE TO THIS CATALOG\n"));

      return (NFM_S_SUCCESS) ;
    }

  status = MEMbuild_array (sql_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      return (NFM_E_MEM) ;
    }

   data = (char **) sql_buffer -> data_ptr ;

   sprintf (s_sa_no, "%ld", sa_no) ;
   found = 0 ;

   for (i=0; i<sql_buffer->rows; i++) 
     {
       if (strcmp (data [i*sql_buffer->columns+1], s_sa_no) == 0)
	 {
	   strcpy (sa_mapno, data [i*sql_buffer->columns]) ;
	   found = 1 ;
	   break ;
	 }
     }
   
   MEMclose (&sql_buffer) ;

   if (!found)
     {
         status = NFM_E_SA_NOT_IN_CATALOG_MAP;
         ERRload_struct (NFM, status, "", NULL);
	 return (status) ;
     }

  /* Find out if item is owned by any project */

  sprintf (sql_str,
	   "SELECT n_projectno FROM NFMPROJECTCIT WHERE n_catalogno = %d AND n_itemno = %d AND n_type = 'O'", cat_no, item_no) ;

  status = SQLquery (sql_str, &sql_buffer, 1024);
  if (status != SQL_S_SUCCESS)
  {
     MEMclose (&sql_buffer);
     if (status == SQL_I_NO_ROWS_FOUND) return (NFM_S_SUCCESS) ;
     ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
     status = NFM_E_SQL_QUERY;
     _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status));
     return (status);
  }
  MEMclose (&sql_buffer);

  /* item is owned by project */
  /* Find if sa is mapped to that project */
  sprintf (sql_str,
	   "SELECT n_projectno FROM NFMPROJECTSAMAP WHERE n_mapno = %s",
	   sa_mapno) ;

  status = SQLquery (sql_str, &sql_buffer, 1024);
  if (status != SQL_S_SUCCESS)
  {
     MEMclose (&sql_buffer);
     if (status == SQL_I_NO_ROWS_FOUND) 
       {
	 ERRload_struct (NFM, NFM_E_SA_NOT_IN_CATALOG_MAP, NULL, NULL) ;
	 return (NFM_E_SA_NOT_IN_CATALOG_MAP) ;
       }
     ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
     status = NFM_E_SQL_QUERY;
     _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status));
     return (status);
  }
  MEMclose (&sql_buffer);

  _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS); 
}

/* item has to be checked in, not a set, not a member of set, 
   not a member of project */
/* file information of latest version */
long _NFMcheck_item_condition_update_item (catalog_name,
					    item_name, item_rev,
					   file_status,
					   archive_flag,
					   archiveno,
					   fileco)
     char *catalog_name ;
     char *item_name ;
     char *item_rev ;
     char *file_status ;
     char *archive_flag ;
     long *archiveno ;
     char *fileco ;
{
  static char *fname = "_NFMcheck_item_condition_update_item" ;
  MEMptr sql_buffer = NULL ;
  long status, atol(), item_no ;
  char **data ;
  char sql_str [1024];

  _NFMdebug ((fname, "ENTER\n")) ;

  status = NFMget_item_no (NFMglobal.NFMuserid, catalog_name, item_name, item_rev, &item_no) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Bad item <%s %s %s> : status <0x%.8x>\n", 
		  catalog_name, item_name, item_rev, status))  ;
      ERRload_struct (NFM, NFM_E_BAD_ITEM, "", "") ;
      return (NFM_E_BAD_ITEM) ;
    }

  sprintf (sql_str, "select a.n_status, a.n_setindicator, a.n_archivestate, a.n_pendingflag, a.n_itemlock, b.n_fileco, b.n_archiveno from %s a, f_%s b where a.n_itemno = %d and a.n_itemno = b.n_itemnum and b.n_fileversion = (select max(n_fileversion) from f_%s where n_itemnum = %d)",
	   catalog_name, catalog_name, item_no, catalog_name, item_no) ;
  
  status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
  if (status != SQL_S_SUCCESS)
    {
      if (status == SQL_I_NO_ROWS_FOUND)
	{
	  _NFMdebug ((fname, "Bad item : cat %s : item %s : rev %s\n",
		      catalog_name, item_name, item_rev)) ;
	  return (NFM_E_BAD_ITEM) ;
	}

      _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status)) ;
      return (NFM_E_SQL_QUERY) ;
    }

  status = MEMbuild_array (sql_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
		  status)) ;
      return (NFM_E_MEM) ;
    }

  data = (char **) sql_buffer -> data_ptr ;

  strcpy (file_status, data[0]) ;
  *archiveno = 0 ;
  fileco [0] = 0 ;
  archive_flag [0] = 0 ;
  if (strcmp (data [2], ""))
   {
     if (strcmp (data [2], "A") == 0)
       {
	 ERRload_struct (NFM, NFM_E_ITEM_ARCHIVED, "", "") ;
	 strcpy (archive_flag, data [2]) ;
       }
     else if (strcmp (data[2], "B") == 0)
       {
	 ERRload_struct (NFM, NFM_E_ITEM_BACKED_UP, "", "") ;
	 strcpy (archive_flag, data [2]) ;
       }
   }

  if (strcmp (data [3], ""))
    {
	 MEMclose (&sql_buffer) ;
	 ERRload_struct (NFM, NFM_E_ITEM_FLAGGED, "%s", item_name) ;
	 _NFMdebug ((fname, "Item is flagged\n")) ;
	 return (NFM_E_ITEM_FLAGGED) ; 
     }

  if (strcmp (data [4], "N"))
    {
      MEMclose (&sql_buffer) ;
      ERRload_struct (NFM, NFM_E_ITEM_LOCKED, "", "") ;
      _NFMdebug ((fname, "Item is locked\n")) ;
      return (NFM_E_ITEM_LOCKED) ;
    }

/* utilities are item level there all f_cat entries for n_fileno and n_archiveno are the same */

  strcpy (fileco, data [5]) ;
  *archiveno = atol (data [6]) ;

  status = MEMclose (&sql_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n", status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }


  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}


long  _NFMrollback_file_operation (cat_name, attr_list, data_list, 
				   coout, ci_last)
     char *cat_name ;
     MEMptr attr_list, data_list;
     char *coout ;
     long ci_last ;
{
  char *fname = "_NFMrollback_file_operation" ;
  long status ;
  long z, move_file, old_offset, new_offset ;
  long x, count, a, y, num_of_files, file_no, netid ;
  long atol(), cisano_flag, n_filenum , i, offset ;
  long cat_no ;
  char n_fileco [NFM_FILECO+1], new_file [NFM_COFILENAME+1] ;
  char old_file [NFM_COFILENAME+1], file [NFM_COFILENAME+1] ;
  char new_sa [20], old_sa [20] ;
  char **data, **data1, **column, **datax ;
  char tmp_str [1024] ;
  struct  fto_buf file_buffer ;
  MEMptr sql_buffer = NULL, remove_buffer = NULL, move_buffer = NULL ;

  _NFMdebug ((fname, "file status %s : last ci %d\n",
	      coout, ci_last)) ;

  if (strcmp (coout, "")) 
    {
      _NFMdebug ((fname, "No file movement occurred\n")) ;
      return (NFM_S_SUCCESS) ;
    }

  data = (char **) attr_list -> data_ptr ;
  column = (char **) attr_list -> column_ptr ;
  data1 = (char **) data_list -> data_ptr ;

  a = -1;
  
  for (y = 0; y < attr_list -> columns; ++y)
    {
      if (! strcmp (column [y], "n_name"))      a = y;
    }
  
  status = NFMget_catalog_no (NFMglobal.NFMuserid, cat_name, &cat_no);
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Get Cat No : status = <0x%.8x>\n",
		  status));
      return (status);
    }
  n_filenum = -1;
  cisano_flag = 0 ;
  file_no = -1 ;
  num_of_files = data_list->rows/2 ;
  for (z=0; z<ci_last; z++)
    {
      _NFMdebug ((fname, "FILE <%d>\n", z+1)) ;
      
      move_file = 0 ;
      old_offset = ((z+num_of_files)*data_list->columns) ;
      new_offset = (z*data_list->columns) ;
      
      for (x = 0; x < attr_list -> rows; ++x)
	{
	  _NFMdebug ((fname, "x is %d\n", x)) ;
	  count = attr_list -> columns * x;
	  _NFMdebug ((fname, "attribute is <%s>\n", data [count+a])) ;
	  
	  if (! strcmp (data [count + a], "n_fileno"))
	    {
	      file_no = atol (data1 [old_offset + x]);
	    }
	  else if (! strcmp (data [count + a], "n_fileco"))
	    {
	      strcpy (n_fileco, data1 [old_offset + x]) ;
	    }
	  else if (! strcmp (data [count + a], "n_cifilename"))
	    {
	      new_file [0] = 0;
	      old_file [0] = 0;
	      
	      if (strcmp (data1 [new_offset + x], data1 [old_offset + x]))
		{
		  move_file = 1;
		  sprintf (new_file, "%s", data1 [new_offset + x]);
		}
	      else
		{
		  /* if there is no changes in cifilename
		     copy into newfilename the oldfilename */
		  sprintf (new_file, "%s", data1[old_offset + x]) ;
		}
	      
	      sprintf (old_file, "%s", data1 [old_offset + x]);
	    }
	  else if (! strcmp (data [count + a], "n_cisano"))
	    {
	      new_sa [0] = 0;
	      old_sa [0] = 0;
	      cisano_flag = 0 ;
	      
	      if (strcmp (data1 [new_offset + x], data1 [old_offset + x]))
		{
		  cisano_flag = 1 ;
		  move_file = 1;
		  sprintf (new_sa, "%s", data1 [new_offset + x]);
		}
	      else
	      sprintf (old_sa, "%s", data1 [old_offset + x]);
	    }
	  else if (! strcmp (data [count + a], "n_filenum"))
	    {
	      n_filenum = atol (data1 [old_offset + x]) ;
	    }
	}

      if ((move_file && (atol (new_sa) > 0)) && (strcmp (coout, "")))
	{
	  if (strcmp (n_fileco, "O"))
	    {
	      status = NFMget_file_name (NFMglobal.NFMuserid, cat_no, 
					 file_no,
					 file);
	      if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug ((fname, "Get File Name : status = <0x%.8x>\n",
			      status));
		  return (status);
		}
	      
	      
	      if (! strlen (new_file)) strcpy (new_file, file) ;
	      
	      if (! strlen (old_file)) strcpy (old_file, file) ;
	      
	      status = _NFMget_sano_info_fto_buf (atol (new_sa),
						  "",
						  &file_buffer) ;
	      if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug ((fname, " Bad Storage Area : status = <0x%.8x>\n",
			      status)) ;
		  return (status) ;
		}
	      
	      status = NFMbuild_fto_buffer (&move_buffer, MEM_SIZE) ;
	      if (status != NFM_S_SUCCESS)
		{
		  MEMclose (&move_buffer);
		  _NFMdebug ((fname, "Build fto buffer failed : status = <0x%.8x>\n",
			      status)) ;
		  return (status) ;
		}
	      
	      status = NFMload_fto_buf (&move_buffer, &file_buffer) ;
	      if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug ((fname, "Loading second row failed : status = <0x%.8x>\n",
			      status)) ;
		  return (status) ;
		}
	      
	      status = _NFMget_sano_info_fto_buf (atol (old_sa),
						  "",
						  &file_buffer) ;
	      if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug ((fname, " Bad Storage Area : status = <0x%.8x>\n",
			      status)) ;
		  return (status) ;
		}
	      strcpy (file_buffer.n_cifilename, old_file) ;
	      strcpy (file_buffer.n_cofilename, new_file) ;
	      file_buffer.n_status1 = NFM_MOVE ;
	      
	      status = NFMload_fto_buf (&move_buffer, &file_buffer) ;
	      if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug ((fname, "Loading second row failed : status = <0x%.8x>\n",
			      status)) ;
		  return (status) ;
		}
	      
	      /* send file */
	      /* remove */		 
	      status = _NFMget_sano_info_fto_buf (atol (new_sa),
						  "",
						  &file_buffer) ;
	      if (status != NFM_S_SUCCESS)
		{
		  
		  _NFMdebug ((fname, " Bad Storage Area : status = <0x%.8x>\n",
			      status)) ;
		  return (status) ;
		}
	      
	      if (! remove_buffer)
		{
		  status = NFMbuild_fto_buffer (&remove_buffer, MEM_SIZE) ;
		  if (status != NFM_S_SUCCESS)
		    {
		      MEMclose (&move_buffer);
		      MEMclose (&remove_buffer) ;
		      _NFMdebug ((fname, "Build fto buffer failed : status = <0x%.8x>\n",
				  status)) ;
		      return (status) ;
		    }
		}
	      
	      strcpy (file_buffer.n_cifilename, new_file) ;
	      file_buffer.n_status1 = NFM_DELETE_FILE ;
	      
	      status = NFMload_fto_buf (&remove_buffer, &file_buffer) ;
	      if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug ((fname, "Loading second row failed : status = <0x%.8x>\n",
			      status)) ;
		  return (status) ;
		}
	    }
	  if (cisano_flag)
	    {
	      _NFMdebug ((fname, "internal sa changed\n")) ;
	      sprintf (tmp_str, "select n_fileno, n_fileco from f_%s \
where n_fileversion != (select max(n_fileversion) from f_%s) and n_fileversion != 0 and n_filenum = %d",
		       cat_name, cat_name, n_filenum) ;
	      status = SQLquery (tmp_str, &sql_buffer, MEM_SIZE) ;
	      if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
		{
		  _NFMdebug ((fname, "Failure : Sql query : status = <0x%..8x>\n",
			      status)) ;
		  ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
		  return (NFM_E_SQL_QUERY) ;
		}
	      
	      if (status != SQL_I_NO_ROWS_FOUND)
		{
		  status = MEMbuild_array (sql_buffer) ;
		  if (status != MEM_S_SUCCESS)
		    {
		      _NFMdebug ((fname, "Failure : MEMbuild_array : status = <0x%.8x>\n",
				  status)) ;
		      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
		      return (NFM_E_MEM) ;
		    }
		  datax = (char **) sql_buffer->data_ptr ;
		  
		  for (i=0; i<sql_buffer->rows; i++)
		    {
		      offset = i*sql_buffer->columns ;
		      
		      if (strcmp (datax [offset+1], "O"))
			{
			  status = NFMget_file_name (NFMglobal.NFMuserid, 
						     cat_no, 
						     atol(datax [offset]),
						     file);
			  if (status != NFM_S_SUCCESS)
			    {
			      _NFMdebug ((fname, "Get File Name : status = <0x%.8x>\n",
					  status));
			      return (status);
			    }
			  _NFMdebug ((fname, "move file %s\n", file)) ;
			  
			  strcpy(new_file, file) ;
			  
			  strcpy (old_file, file) ;
			  if (! move_buffer)
			    {
			      status = _NFMget_sano_info_fto_buf (atol (new_sa),
								  "",
								  &file_buffer) ;
			      if (status != NFM_S_SUCCESS)
				{
				  _NFMdebug ((fname, " Bad Storage Area : status = <0x%.8x>\n",
					      status)) ;
				  return (status) ;
				}
			      
			      status = NFMbuild_fto_buffer (&move_buffer, MEM_SIZE) ;
			      if (status != NFM_S_SUCCESS)
				{
				  MEMclose (&move_buffer);
				  _NFMdebug ((fname, "Build fto buffer failed : status = <0x%.8x>\n",
					      status)) ;
				  return (status) ;
				}
			      
			      status = NFMload_fto_buf (&move_buffer, &file_buffer) ;
			      if (status != NFM_S_SUCCESS)
				{
				  _NFMdebug ((fname, "Loading second row failed : status = <0x%.8x>\n",
					      status)) ;
				  return (status) ;
				}
			    }
			  status = _NFMget_sano_info_fto_buf (atol (old_sa),
							      "",
							      &file_buffer) ;
			  if (status != NFM_S_SUCCESS)
			    {
			      _NFMdebug ((fname, " Bad Storage Area : status = <0x%.8x>\n",
					  status)) ;
			      return (status) ;
			    }
			  strcpy (file_buffer.n_cifilename, old_file) ;
			  strcpy (file_buffer.n_cofilename, new_file) ;
			  file_buffer.n_status1 = NFM_MOVE ;
			  
			  status = NFMload_fto_buf (&move_buffer, &file_buffer) ;
			  if (status != NFM_S_SUCCESS)
			    {
			      _NFMdebug ((fname, "Loading second row failed : status = <0x%.8x>\n",
					  status)) ;
			      return (status) ;
			    }
			  
			  /* send file */
			  /* remove */		 
			  
			  status = _NFMget_sano_info_fto_buf (atol (new_sa),
							      "",
							      &file_buffer) ;
			  if (status != NFM_S_SUCCESS)
			    {
			      _NFMdebug ((fname, " Bad Storage Area : status = <0x%.8x>\n",
					  status)) ;
			      return (status) ;
			    }
			  
			  if (! remove_buffer)
			    {
			      status = NFMbuild_fto_buffer (&remove_buffer, MEM_SIZE) ;
			      if (status != NFM_S_SUCCESS)
				{
				  MEMclose (&move_buffer);
				  _NFMdebug ((fname, "Build fto buffer failed : status = <0x%.8x>\n",
					      status)) ;
				  return (status) ;
				}
			    }
			  
			  strcpy (file_buffer.n_cifilename, new_file) ;
			  file_buffer.n_status1 = NFM_DELETE_FILE ;
			  
			  status = NFMload_fto_buf (&remove_buffer, &file_buffer) ;
			  if (status != NFM_S_SUCCESS)
			    {
			      _NFMdebug ((fname, "Loading second row failed : status = <0x%.8x>\n",
					  status)) ;
			      return (status) ;
			    }
			} /* n_fileco = "O" */
		    } /* for i */
		}  /* state == SQL_I_NO_ROWS_FOUND*/
	      
	    } /* if cisano_flag */
	  if (move_buffer)
	    {
	      status = _NFMfs_send_files (&move_buffer, &netid, 1) ;
	      if (status != NFM_S_SUCCESS)
		{
		  _NFMfs_undo_send_files (&move_buffer, &netid, 1) ;
		  _NFMdebug ((fname, "Send files failed : status = <0x%l8x>\n",
			      status)) ;
		  return (status) ;
		}
	    }
	  
	  if (remove_buffer)
	    {
	      status = NFMfs_chg_files (&remove_buffer) ;
	      if (status != NFM_S_SUCCESS)
		{
		  _NFMfs_undo_send_files (&move_buffer, &netid, 1) ;
		  NFMfs_undo_chg_files (&remove_buffer) ;
		  _NFMdebug ((fname, "Change buffer failed : status = <0x%.8x>\n",
			      status)) ;
		  return (status) ;
		}
	    }
	  MEMclose (&move_buffer) ;
	  MEMclose (&remove_buffer) ;
	}
    } 
  return (NFM_S_SUCCESS) ;
}



