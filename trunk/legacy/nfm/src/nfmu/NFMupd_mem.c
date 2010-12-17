#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"

 long NFMupdate_set_members (user_id, attr_list, data_list)
   long      user_id;
   MEMptr    attr_list, data_list;
   {
      static char *fname = "NFMupdate_set_members" ;
      long      status, atol ();
      char      **column, **data, **data1;
      long      a, b, x, y, count;
      long      i, j, k, l, m, n, o, p, q;
      long      cat_no, item_no;
      long      coout_status;
      char      co_status [10];
      MEMptr    list = NULL;
      long      NFMdrop_set_member ();
      long      NFMadd_set_member ();

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
              if (! strcmp (column [y], "n_name"))     a = y;
         else if (! strcmp (column [y], "n_datatype")) b = y;
       }

      i = -1; j = -1; k = -1; l = -1; m = -1;
      n = -1; o = -1; p = -1; q = -1;

      for (x = 0; x < attr_list -> rows; ++x)
       {
         count = attr_list -> columns * x;

              if (! strcmp (data [count + a], "n_citno"))        i = x;
         else if (! strcmp (data [count + a], "n_catalogname"))  j = x;
         else if (! strcmp (data [count + a], "n_itemname"))     k = x;
         else if (! strcmp (data [count + a], "n_itemrev"))      l = x;
         else if (! strcmp (data [count + a], "n_type"))         m = x;
         else if (! strcmp (data [count + a], "n_level"))        n = x;
         else if (! strcmp (data [count + a], "n_setindicator")) o = x;
         else if (! strcmp (data [count + a], "n_coout"))        p = x;
         else if (! strcmp (data [count + a], "n_status"))       q = x;
       }      

      cat_no = 0;   item_no = 0;

      status = NFMget_catalog_no (user_id, data1 [j], &cat_no);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Get Cat No : status = <0x%.8x>\n",
         status));
         return (status); 
       }

      status = NFMget_item_no (user_id, data1 [j],
               data1[k], data1[l], &item_no);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Get Item No : status = <0x%.8x>\n",
         status));
         return (status); 
       }

      status = NFMcheck_item_setindicator (user_id, data1 [j], item_no);
      if (status != NFM_S_SUCCESS && status != NFM_E_SET)
       {
         _NFMdebug ((fname, "Get Item No : status = <0x%.8x>\n",
         status));
         return (status); 
       }

      status = NFMcheck_co_status (user_id, data1 [j],
               item_no, co_status);
/*  If sets is checked out do not allow any members to be added
       if ((status != NFM_S_SUCCESS)         &&
          (status != NFM_E_NO_FILE)         &&
          (status != NFM_E_ITEM_OUT)        && 
          (status != NFM_E_ITEM_IN)         &&
          (status != NFM_E_SET_OUT)         &&
          (status != NFM_E_SET_OUT_NO_FILE) &&    
          (status != NFM_E_MEM_OUT)         &&
          (status != NFM_E_MEM_OUT_NO_FILE))
 */
      if ((status != NFM_S_SUCCESS)         &&
          (status != NFM_E_NO_FILE)         &&
          (status != NFM_E_ITEM_IN))
       {

	 if ((status == NFM_E_ITEM_OUT)        ||
	     (status == NFM_E_SET_OUT)         ||
	     (status == NFM_E_SET_OUT_NO_FILE) ||    
	     (status == NFM_E_MEM_OUT)         ||
	     (status == NFM_E_MEM_OUT_NO_FILE))
	   {
	     _NFMdebug ((fname, "Set is Checked Out : status = <0x%.8x>\n",
			 status));
	     ERRload_struct (NFM, NFM_E_SET_OUT, "%s", data1 [k]) ;
	     return (NFM_E_SET_OUT); 
	   }
	 else
	   {
	     _NFMdebug ((fname, "Check Co Status : status = <0x%.8x>\n",
			 status));
	     ERRload_struct (NFM, NFM_E_UNKNOWN_CO_FLAG, "", NULL) ;
	     return (NFM_E_UNKNOWN_CO_FLAG) ;
	   }
       }

      coout_status = status;

      status = NFMquery_attributes_definition (user_id, "NFMSYSTEM", 
								"NFMSETCIT", &list);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose (&list);
         _NFMdebug ((fname, "Qry Tab Def : status = <0x%.8x>\n",
         status));
         return (status); 
       }

      status = MEMbuild_array (list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&list);
	 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		     status));
         return (NFM_E_MEM);       
       }

      status = NFMstop_transaction (0);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose (&list);
         _NFMdebug ((fname, "Stop Transaction : status = <0x%.8x>\n",
         status));
         return (status); 
       }

      for (x = 1; x < data_list -> rows; ++x)
       {
         count = data_list -> columns * x;

         if (! strlen (data1 [count + n]))
          {
            status = MEMwrite_data (data_list, "1", x + 1, n + 1);
            if (status != MEM_S_SUCCESS)
             {
               MEMclose (&list);
               NFMrollback_transaction (0);
	       ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               _NFMdebug ((fname, " MEM Wr Data : status = <0x%.8x>\n",
			   status));
               return (NFM_E_MEM); 
             }
          }

         if (atol (data1 [count + n]) == 1)
          {
            NFMchange_case (data1[ count + q], 0);

            if (! strcmp (data1 [count + q], "DROP"))
             {
               status = NFMdrop_set_member (user_id, list, data_list,
                        cat_no, item_no, coout_status, x);
               if (status != NFM_S_SUCCESS)
                {
                  MEMclose (&list);
                  NFMrollback_transaction (0);
                  _NFMdebug ((fname, "Drop MEM : status = <0x%.8x>\n",
                  status));
                  return (status); 
                }
             }
            else
             {
               if (! strlen (data1 [count + i]))
                {
                  status = NFMadd_set_member (user_id, list, data_list, 
                           cat_no, item_no, co_status, x);
                  if ((status != NFM_S_SUCCESS) && 
                      (status != NFM_E_SET_MEM_EXISTS))
                   {
                     MEMclose (&list);
                     NFMrollback_transaction (0);
                     _NFMdebug ((fname, "Add MEM : status = <0x%.8x>\n",
                     status));
                     return (status); 
                   }
                }
             }
          }
       }

      status = MEMclose (&list); 
      if (status != MEM_S_SUCCESS)
       {
         NFMrollback_transaction (0);
	 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Close List : status = <0x%.8x>\n",
		     status));
         return (NFM_E_MEM); 
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

 long NFMdrop_set_member (user_id, cit_attr, data_list, 
                          cat_no, item_no, p_co_status, row_no)
   long    user_id;
   MEMptr  cit_attr, data_list;
   long    cat_no, item_no, p_co_status;
   long    row_no;   
   {
      static char *fname = "NFMdrop_set_member" ;
      long     status, atol ();
      char     **column,  **data;
      char     **column1, **data1;
      long     y, x, count;
      long     i, j, k, l, m, i1, and;
      long     c_cat_no, c_item_no;
      long     set_status, coout_status;
      char     co_status [10], value [50];
      char     sql_str [1024], sql_str1 [1024];
      long     val_exists, level;
      char     cat_name [50];
      char     sel_str [1024], c_catno [50], c_itemno [50];
      long     NFMreset_co_out_deleted_member ();
      long     NFMget_parent_checkout_level ();
   
      _NFMdebug ((fname, "Cat  No = <%d> : Item No = <%d> : Parent Co = <%d> : Row No = <%d>\n", 
		  cat_no, item_no, p_co_status, row_no));

      sel_str [0] = '\0'; c_catno [0] = '\0'; c_itemno [0] = '\0';

      column  = (char **) cit_attr -> column_ptr;
      data    = (char **) cit_attr -> data_ptr;

      column1 = (char **) data_list -> column_ptr;
      data1   = (char **) data_list -> data_ptr;

      i = -1; j = -1; k = -1; l = -1; m = -1;

      for (y = 0; y < data_list -> columns; ++y)
       {
              if (! strcmp (column1 [y], "n_citno"))       i = y;
         else if (! strcmp (column1 [y], "n_catalogname")) j = y;
         else if (! strcmp (column1 [y], "n_itemname"))    k = y;
         else if (! strcmp (column1 [y], "n_itemrev"))     l = y;
         else if (! strcmp (column1 [y], "n_type"))        m = y;
       }      
/*********************  4/16/91 *****************************
      if (i < 0 || j < 0 || k < 0 || l < 0 || m < 0)
       {
         _NFMdebug ((fname, "Corrupted Buffers : status = <0x%.8x>\n",
         NFM_E_CORRUPTED_BUFFERS));
         return (NFM_E_CORRUPTED_BUFFERS); 
       }
*************************************************************/
      count = data_list -> columns * row_no;

      status = NFMget_catalog_no (user_id, data1 [count + j], &c_cat_no);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Get Cat No : status = <0x%.8x>\n",
         status));
         return (status); 
       }

      status = NFMget_item_no (user_id, data1 [count + j], 
               data1 [count + k], data1 [count + l], &c_item_no);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Get Item No : status = <0x%.8x>\n",
         status));
         return (status); 
       }


      status = NFMcheck_item_setindicator (user_id,
               data1 [count + j], c_item_no);
      if (status != NFM_S_SUCCESS && status != NFM_E_SET &&
          status != NFM_E_NOT_SET)
       {
         _NFMdebug ((fname, "Check Set Indicator : status = <0x%.8x>\n",
         status));
         return (status); 
       }

      set_status = status;

      status = NFMcheck_co_status (user_id, data1 [count + j],
               c_item_no, co_status);
      if ((status != NFM_S_SUCCESS)         &&
          (status != NFM_E_NO_FILE)         &&
          (status != NFM_E_ITEM_OUT)        &&
          (status != NFM_E_ITEM_IN)         &&
          (status != NFM_E_SET_OUT)         && 
          (status != NFM_E_SET_OUT_NO_FILE) &&
          (status != NFM_E_MEM_OUT)         && 
          (status != NFM_E_MEM_OUT_NO_FILE))
       {
         _NFMdebug ((fname, "Check Co Status : status = <0x%.8x>\n",
         status));
         return (status); 
       }

      coout_status = status;

      NFMchange_case (data1 [count + m], 0);

      if ((! strcmp (data1 [count + m], "S")) &&
          (! strcmp (data1 [count + m], "P")))
       {
           status = ERRload_struct (NFM, NFM_E_UNKNOWN_SET_TYPE, "", NULL);
	   _NFMdebug ((fname, "Unknown Mem Type : status = <0x%.8x>\n",
		       NFM_E_UNKNOWN_SET_TYPE));
	   return (NFM_E_UNKNOWN_SET_TYPE); 
       }

      if (! strcmp (data1 [count + m], "P"))
       {
         if ((p_co_status == NFM_E_SET_OUT            ||
              p_co_status == NFM_E_SET_OUT_NO_FILE    ||
              p_co_status == NFM_E_MEM_OUT            ||
              p_co_status == NFM_E_MEM_OUT_NO_FILE)   &&
             (coout_status == NFM_E_MEM_OUT           ||
              coout_status == NFM_E_MEM_OUT_NO_FILE))
          {
            level = -1;

            if ((p_co_status == NFM_E_SET_OUT           || 
                 p_co_status == NFM_E_SET_OUT_NO_FILE)  &&
                (set_status == NFM_E_SET))
             {
               status = NFMget_catalog_name (user_id, cat_no, cat_name);
               if (status != NFM_S_SUCCESS)
                {
                  _NFMdebug ((fname, "Cat Name : status = <0x%.8x>\n",
                  status));
                  return (status); 
                }

               status = NFMget_set_checkout_level (user_id, cat_name,
                        item_no, &level);
               if (status != NFM_S_SUCCESS)
                {
                  _NFMdebug ((fname, "Set CoLvl : status = <0x%.8x>\n",
                  status));
                  return (status); 
                }
             }
            else if ((p_co_status == NFM_E_MEM_OUT          || 
                      p_co_status == NFM_E_MEM_OUT_NO_FILE) &&
                     (set_status == NFM_E_SET))
             {
               status = NFMget_catalog_name (user_id, cat_no, cat_name);
               if (status != NFM_S_SUCCESS)
                {
                  _NFMdebug ((fname, "Cat Name : status = <0x%.8x>\n",
                  status));
                  return (status); 
                }

               status = NFMget_parent_checkout_level (user_id, cat_no,
                        item_no, &level, sel_str, c_catno, c_itemno);
               if (status != NFM_S_SUCCESS)
                {
                  _NFMdebug ((fname, "Par CoLvl : status = <0x%.8x>\n",
                  status));
                  return (status); 
                }
             }

            status = NFMreset_co_out_deleted_member (user_id, 
                     data1 [count + j], c_item_no, level - 1,
                     set_status, coout_status);
            if (status != NFM_S_SUCCESS)
             {
               _NFMdebug ((fname, "Reset Co Out : status = <0x%.8x>\n",
               status));
               return (status); 
             }
          }
       }

      sprintf (sql_str, " WHERE ");
      and = 0;

      for (x = 0; x < cit_attr -> rows; ++x)
       {
         count = cit_attr -> columns * x;
         val_exists = 0;  value [0] = '\0';

              if (! strcmp (data [count + 2], "n_citno"))         i1 = x;
         else if (! strcmp (data [count + 2], "n_pcatalogno"))
          {
             val_exists = 1;
             sprintf (value, "%d", cat_no);
          }
         else if (! strcmp (data [count + 2], "n_pitemno"))
          {
             val_exists = 1;
             sprintf (value, "%d", item_no);
          }
         else if (! strcmp (data [count + 2], "n_ccatalogno"))
          {
             val_exists = 1;
             sprintf (value, "%d", c_cat_no);
          }
         else if (! strcmp (data [count + 2], "n_citemno"))
          {
             val_exists = 1;
             sprintf (value, "%d", c_item_no);
          }
         else if (! strcmp (data [count + 2], "n_type"))
          {
             val_exists = 1;
             sprintf (value, data1 [(data_list -> columns * row_no) + m]);
          }

         if (val_exists)
          {
            if (and)  strcat (sql_str, " AND ");
            and++;

            strcat (sql_str, data [count]);
            strcat (sql_str, " = ");
 
            if (! strncmp (data [count + 1], "char", 4))
             {
               strcat (sql_str, "'");
               strcat (sql_str, value);
               strcat (sql_str, "'");
             }
            else
               strcat (sql_str, value);
          }
       }
/*********************  4/15/91 ******************************
      if (i1 < 0 || (and < 5))
       {
       ERRload_struct (NFM, NFM_E_CORRUPTED_SYSTEM, "", NULL);
       _NFMdebug ((fname, "System Is Corrupted : status = <0x%.8x>\n",
       NFM_E_CORRUPTED_SYSTEM));
       return (NFM_E_CORRUPTED_SYSTEM); 
       }
***************************************************************/
      status = NFMget_attr_value (user_id, "NFMSETCIT",
               data [(cit_attr -> columns * i1)], sql_str, value);
      if (status != NFM_S_SUCCESS)
       {
         if (status == NFM_I_BAD_CONDITION)
          {
	    ERRload_struct (NFM, NFM_E_BAD_SET_MEMBER, "", NULL);
            _NFMdebug ((fname, "No Such Member : status = <0x%.8x>\n",
			NFM_E_BAD_SET_MEMBER));
            return (NFM_E_BAD_SET_MEMBER); 
          }
	 
         _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
		     status));
         return (status); 
       }
      
      sprintf (sql_str1, "DELETE FROM %s %s", "NFMSETCIT", sql_str);

      status = SQLstmt (sql_str1);
      if (status != SQL_S_SUCCESS)
       {
           ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
	   _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
		       status));
	   return (NFM_E_SQL_STMT); 
	 } 
         
      status = MEMwrite_data (data_list, value, row_no + 1, i1 + 1);
      if (status != MEM_S_SUCCESS)
       {
	 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	 _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
		     status));
         return (NFM_E_MEM); 
       }

      status = NFMreturn_serial_slot (user_id, "nfmsetcit",
               data [(cit_attr -> columns * i1)], atol (value));
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Ret Serial Slot : status = <0x%.8x>\n",
         status));
         return (status); 
       }
      
      _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
      NFM_S_SUCCESS));
      return (NFM_S_SUCCESS); 
   }

 long NFMadd_set_member (user_id, cit_attr, data_list,
                         cat_no, item_no, p_co_status, row_no)
   long       user_id;
   MEMptr     cit_attr, data_list;
   long       cat_no, item_no, p_co_status;
   long       row_no;
   {
      static char *fname = "NFMadd_set_member" ;
      long      status, set_status;
      char      **column,  **data;
      char      **column1, **data1;
      long      x, y, count;
      long      i, j, k, l, m, and, row_id;
      long      i1, j1, k1, l1, m1;
      long      c_cat_no, c_item_no;
      long      comma, insert, found;
      char      co_status [10], value [50];
      long      val_exists;
      char      *cit_str1, *cit_str2;
      char      sql_str [1024];
      long      NFMcheck_set_loop ();
      long      NFMcheck_parent_loop ();

      _NFMdebug ((fname, "Cat  No = <%d> : Item No = <%d> : Parent CO = <%d> : Row No = <%d>\n", 
		  cat_no, item_no, p_co_status, row_no));

      column  = (char **) cit_attr -> column_ptr;
      data    = (char **) cit_attr -> data_ptr;

      column1 = (char **) data_list -> column_ptr;
      data1   = (char **) data_list -> data_ptr;

      i = -1; j = -1; k = -1; l = -1; m = -1;

      for (y = 0; y < data_list -> columns; ++y)
       {
              if (! strcmp (column1 [y], "n_citno"))       i = y;
         else if (! strcmp (column1 [y], "n_catalogname")) j = y;
         else if (! strcmp (column1 [y], "n_itemname"))    k = y;
         else if (! strcmp (column1 [y], "n_itemrev"))     l = y;
         else if (! strcmp (column1 [y], "n_type"))        m = y;
       }      
/*********************  4/16/91 ****************************
      if (i < 0 || j < 0 || k < 0 || l < 0 || m < 0)
       {
           ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL);
           _NFMdebug ((fname, "Corrupted Buffers : status = <0x%.8x>\n",
               NFM_E_CORRUPTED_BUFFERS));
           return (NFM_E_CORRUPTED_BUFFERS); 
       }
*************************************************************/
      count = data_list -> columns * row_no;

      status = NFMget_catalog_no (user_id, data1 [count + j], &c_cat_no);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Get Cat No : status = <0x%.8x>\n",
		     status));
         return (status); 
       }

      status = NFMget_item_no (user_id, data1 [count + j],
               data1 [count + k], data1 [count + l], &c_item_no);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Get Item No : status = <0x%.8x>\n",
		   status));
         return (status); 
       }
/***************  this call ignores if item is set or not *********
      set_status = NFMcheck_item_setindicator (user_id,
               data1 [count + j], c_item_no);
      if (set_status != NFM_S_SUCCESS && set_status != NFM_E_SET &&
          set_status != NFM_E_NOT_SET)
       {
         _NFMdebug ((fname, "Check Set Indicator : status = <0x%.8x>\n",
         status));
         return (status); 
       }
********************************************************************/
      status = NFMcheck_co_status (user_id, data1 [count + j], 
               c_item_no, co_status);
      if ((status != NFM_S_SUCCESS)         && 
          (status != NFM_E_NO_FILE)         &&
          (status != NFM_E_ITEM_OUT)        &&
          (status != NFM_E_ITEM_IN)         &&
          (status != NFM_E_SET_OUT)         && 
          (status != NFM_E_SET_OUT_NO_FILE) &&
          (status != NFM_E_MEM_OUT)         &&
          (status != NFM_E_MEM_OUT_NO_FILE))
       {
         _NFMdebug ((fname, "Check Co Status : status = <0x%.8x>\n",
         status));
         return (status); 
       }

      NFMchange_case (data1 [count + m], 0);

      if ((! strcmp (data1 [count + m], "S")) &&
          (! strcmp (data1 [count + m], "P")))
       {
	 ERRload_struct (NFM, NFM_E_UNKNOWN_SET_TYPE, "", NULL);
         _NFMdebug ((fname, "Unknown Set Type : status = <0x%.8x>\n",
		     NFM_E_UNKNOWN_SET_TYPE));
         return (NFM_E_UNKNOWN_SET_TYPE); 
       }

      if (! strcmp (data1 [count + m], "P"))
       {
         if ((p_co_status == NFM_E_SET_OUT)         ||
             (p_co_status == NFM_E_SET_OUT_NO_FILE) ||
             (p_co_status == NFM_E_MEM_OUT)         ||
             (p_co_status == NFM_E_MEM_OUT_NO_FILE))
          {
	    ERRload_struct (NFM, NFM_E_ADD_PRI_MEM_SO, "", NULL);
            _NFMdebug ((fname, "Add Pri Mem To Out Set : status = <0x%.8x>\n",
			NFM_E_ADD_PRI_MEM_SO));
            return (NFM_E_ADD_PRI_MEM_SO); 
          }
       }

      if (set_status == NFM_E_SET)
	{
	  status = NFMcheck_set_loop (user_id, cit_attr, cat_no, item_no,
				      cit_attr, cat_no, item_no,
				      c_cat_no, c_item_no,
				      j1, k1, l1, m1) ;
	  if (status != NFM_S_SUCCESS)
	    {
	      _NFMdebug ((fname, "Chk Set Loop : status = <0x%.8x>\n",
			  status));
	      return (status);
	    }
	}

      sprintf (sql_str, " WHERE ");

      and = 0;
      i1 = -1; j1 = -1; k1 = -1; l1 = -1; m1 = -1;

      for (x = 0; x < cit_attr -> rows; ++x)
       {
         count = cit_attr -> columns * x;
         val_exists = 0;  value [0] = '\0';

              if (! strcmp (data [count + 2], "n_citno"))         i1 = x;
         else if (! strcmp (data [count + 2], "n_pcatalogno"))
          {
             j1 = x;  val_exists = 1;
             sprintf (value, "%d", cat_no);
          }
         else if (! strcmp (data [count + 2], "n_pitemno"))
          {
             k1 = x;  val_exists = 1;
             sprintf (value, "%d", item_no);
          }
         else if (! strcmp (data [count + 2], "n_ccatalogno"))
          {
             l1 = x; val_exists = 1;
             sprintf (value, "%d", c_cat_no);
          }
         else if (! strcmp (data [count + 2], "n_citemno"))
          {
             m1 = x; val_exists = 1;
             sprintf (value, "%d", c_item_no);
          }

         if (val_exists)
          {
            if (and)  strcat (sql_str, " AND ");
            and++;

            strcat (sql_str, data [count]);
            strcat (sql_str, " = ");
 
            if (! strncmp (data [count + 1], "char", 4))
             {
               strcat (sql_str, "'");
               strcat (sql_str, value);
               strcat (sql_str, "'");
             }
            else
               strcat (sql_str, value);
          }
       }
/************************** 4/16/91 ******************************
      if (i1 < 0 || j1 < 0 || k1 < 0 || l1 < 0 || m1 < 0 || (and < 4))
       {
         ERRload_struct (NFM, NFM_E_CORRUPTED_SYSTEM, "", NULL);
         _NFMdebug ((fname, "System Is Corrupted : status = <0x%.8x>\n",
         NFM_E_CORRUPTED_SYSTEM));
         return (NFM_E_CORRUPTED_SYSTEM); 
       }
*******************************************************************/
      status = NFMget_attr_value (user_id, "NFMSETCIT",
               data [(cit_attr -> columns * i1)], sql_str, value);
      if ((status != NFM_S_SUCCESS) && (status != NFM_I_BAD_CONDITION))
       {
         _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
         status));
         return (status); 
       }

      if (status != NFM_I_BAD_CONDITION)
       {
         status = MEMwrite_data (data_list, value, row_no + 1, i + 1);
         if (status != MEM_S_SUCCESS)
          {
	    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			status));
            return (NFM_E_MEM); 
          }

	 ERRload_struct (NFM, NFM_E_SET_MEM_EXISTS, "", NULL);
         _NFMdebug ((fname, "MEMBER EXISTS : status = <0x%.8x>\n",
		     NFM_E_SET_MEM_EXISTS));
         return (NFM_E_SET_MEM_EXISTS);
       }

      status = NFMget_serial_slot (user_id, "nfmsetcit",
               data [(cit_attr -> columns * i1)], &row_id);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Get Serial No : status = <0x%.8x>\n",
         status));
         return (status);          
       }

      cit_str1 = (char *) malloc (MEM_SIZE + cit_attr -> rows * 50 +
                                  data_list -> row_size);
      if (! cit_str1)
       {
	 ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
		     NFM_E_MALLOC));
         return (NFM_E_MALLOC); 
       }
      cit_str1 [0] = '\0';

      cit_str2 = (char *) malloc (MEM_SIZE + data_list -> row_size);
      if (! cit_str2)
       {
         free (cit_str1);
	 ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
		     NFM_E_MALLOC));
         return (NFM_E_MALLOC); 
       }
      cit_str2 [0] = '\0';

      comma = 0;

      sprintf (cit_str1,  "INSERT INTO %s (", "NFMSETCIT");
      sprintf (cit_str2, ") VALUES (");

      for (x = 0; x < cit_attr -> rows; ++x)
       {
         count = cit_attr -> columns * x;

         _NFMdebug ((fname, "Attr Name  : <%s>  : Sql Str 1 = <%s> : Sql Str 2 = <%s>\n", 
		     data [count], cit_str1, cit_str2));

         value [0] = '\0'; val_exists = 0; insert = 0;

         if (strcmp (data [count + 4], "NFM"))
          {
            insert = 0;
          }
         else if (! strcmp (data [count + 2], "n_citno"))
          {
            val_exists = 1; insert = 1;
            sprintf (value, "%d", row_id);
          }
         else if (! strcmp (data [count + 2], "n_pcatalogno"))
          {
            val_exists = 1; insert = 1;
            sprintf (value, "%d", cat_no);
          }
         else if (! strcmp (data [count + 2], "n_pitemno"))
          {
            val_exists = 1; insert = 1;
            sprintf (value, "%d", item_no);
          }
         else if (! strcmp (data [count + 2], "n_ccatalogno"))
          {
            val_exists = 1; insert = 1;
            sprintf (value, "%d", c_cat_no);
          }
         else if (! strcmp (data [count + 2], "n_citemno"))
          {
            val_exists = 1; insert = 1;
            sprintf (value, "%d", c_item_no);
          }
         else if (! strcmp (data [count + 2], "n_archiveno"))
            insert = 0;
         else if (! strcmp (data [count + 2], "n_archiveflag"))
            insert = 0;
         else
          {
            found = 0;

            for (y = 0; ((y < data_list -> columns) && (! found)); ++y)
             {
               if (! strcmp (data [count], column1 [y]))
                {
                  insert = 1;
                  found  = 1;
                } 
             }

            if (! found) 
             {
               free (cit_str1);
               free (cit_str2);
	       ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL);
               _NFMdebug ((fname, "Corr Buffers : status = <0x%.8x>\n",
               NFM_E_CORRUPTED_BUFFERS));
               return (NFM_E_CORRUPTED_BUFFERS);              
             }

            else
               y = y - 1;
          }

         if (insert)
          {
            if (comma)
             {
               strcat (cit_str1,  ", ");
               strcat (cit_str2, ", ");
             }
            comma = 1;

            strcat (cit_str1, data [count]);

            if (! strncmp (data [count + 1], "char", 4))
             {
               strcat (cit_str2, "'");

               if (val_exists) strcat (cit_str2, value);
               else
                  strcat (cit_str2,
                          data1 [(data_list -> columns * row_no) + y]);

               strcat (cit_str2, "'");
             }
            else
             {
               if (val_exists)
                {
                  if (strlen (value))  strcat (cit_str2, value);
                  else                 strcat (cit_str2, "null");
                }
               else
                {
                  if (strlen
                         (data1 [(data_list -> columns * row_no) + y]))
                    strcat (cit_str2,
                         data1 [(data_list -> columns * row_no) + y]);
                  else strcat (cit_str2, "null");
                }
             }
          }
       }

      strcat (cit_str1, cit_str2);
      strcat (cit_str1, ")");

      free (cit_str2);

      status = SQLstmt (cit_str1);
      if (status != SQL_S_SUCCESS)
       {
         free (cit_str1);
         ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
         _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
		     status));
         return (NFM_E_SQL_STMT); 
       }

      free (cit_str1);

      sprintf (value, "%d", row_id);

      status = MEMwrite_data (data_list, value, row_no + 1, i + 1);
      if (status != MEM_S_SUCCESS)
       {
	 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
		     status));
         return (NFM_E_MEM); 
       }
      
      _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
      NFM_S_SUCCESS));
      return (NFM_S_SUCCESS); 
   }

 long NFMcheck_set_loop (user_id, cit_attr, p_cat_no, p_item_no,
                         c_cat_no, c_item_no, pc_off, pi_off, 
                         cc_off, ci_off)
   long     user_id;
   MEMptr   cit_attr;
   long     p_cat_no, p_item_no;
   long     c_cat_no, c_item_no;
   long     pc_off, pi_off;
   long     cc_off, ci_off;
   {
      static char *fname = "NFMcheck_set_loop" ;
      long     status, atol ();
      MEMptr   list = NULL, p_list = NULL;
      char     *sql_str;
      char     **data;
      char     value [100];
      long     x, count;
      long     NFMcheck_parent_loop ();

      _NFMdebug ((fname, "PC   No  = <%d> : PI No = <%d> : CC No = <%d> : CI No = <%d> : PC Offset = <%d> : PI Offset = <%d> : CC Offset = <%d> : CI Offset = <%d>\n",
		  p_cat_no, p_item_no, c_cat_no, c_item_no, pc_off,
		  pi_off, cc_off, ci_off));

      if ((p_cat_no == c_cat_no) && (p_item_no == c_item_no))
       {
	 ERRload_struct (NFM, NFM_E_SET_IN_LOOP, "", NULL);
         _NFMdebug ((fname, "Set in Loop : status = <0x%.8x>\n",
		     NFM_E_SET_IN_LOOP));
         return (NFM_E_SET_IN_LOOP);
       }

      status = MEMopen (&list, 2 * MEM_SIZE);
      if (status != MEM_S_SUCCESS)
       {
           status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);
       }

      status = MEMwrite_format (list, "cat_no", "integer");
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
		     status));
         return (NFM_E_MEM);
       }

      status = MEMwrite_format (list, "item_no", "integer");
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
		     status));
         return (NFM_E_MEM);
       }

      status = MEMwrite_format (list, "flag", "char(1)");
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
		     status));
         return (NFM_E_MEM);
       }

      sql_str = (char *) malloc (2 * MEM_SIZE);
      if (! sql_str)
       {
         MEMclose (&list);
         ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
		     NFM_E_MALLOC));
         return (NFM_E_MALLOC);
       }
      
      sprintf (sql_str, "%d\1%d\1\1", c_cat_no, c_item_no);

      status = MEMwrite (list, sql_str);
      if (status != MEM_S_SUCCESS)
       {
         free (sql_str);
         MEMclose (&list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);
       }

      sprintf (sql_str, "%d\1%d\1\1", p_cat_no, p_item_no);

      status = MEMwrite (list, sql_str);
      if (status != MEM_S_SUCCESS)
       {
         free (sql_str);
         MEMclose (&list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);
       }

      data = (char **) cit_attr -> data_ptr;

      sprintf (sql_str, "SELECT %s, %s FROM %s WHERE ",
               data [(cit_attr -> columns * pc_off)],
               data [(cit_attr -> columns * pi_off)],
               "NFMSETCIT");

      strcat (sql_str, data [(cit_attr -> columns * cc_off)]);
      strcat (sql_str, " = ");

      sprintf (value, "%d", p_cat_no);

      if (! strncmp (data [(cit_attr -> columns * cc_off) + 1],
                     "char", 4))
       {
         strcat (sql_str, ",");
         strcat (sql_str, value);
         strcat (sql_str, ",");
       }
      else
         strcat (sql_str, value);
        
      strcat (sql_str, " AND ");

      strcat (sql_str, data [(cit_attr -> columns * ci_off)]);
      strcat (sql_str, " = ");

      sprintf (value, "%d", p_item_no);

      if (! strncmp (data [(cit_attr -> columns * ci_off) + 1],
                     "char", 4))
       {
         strcat (sql_str, ",");
         strcat (sql_str, value);
         strcat (sql_str, ",");
       }
      else
         strcat (sql_str, value);

      status = SQLquery (sql_str, &p_list, MEM_SIZE);
      if ((status != SQL_S_SUCCESS) && 
          ((status) != SQL_I_NO_ROWS_FOUND))
       {
         free (sql_str);
         MEMclose (&list);
         MEMclose (&p_list);
         ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
         _NFMdebug ((fname, "SQL Stmt Failed : status = <0x%.8x>\n",
		     status));
         return ( NFM_E_SQL_QUERY);
       }

      free (sql_str);

      status = MEMbuild_array (p_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&list);
         MEMclose (&p_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		     status));
         return (NFM_E_MEM);
       }

      data = (char **) p_list -> data_ptr;

      for (x = 0; x < p_list -> rows; ++x)
       {
         count = p_list -> columns * x;

         status = NFMcheck_parent_loop (user_id, cit_attr, list,
                  atol (data [count]), atol (data [count + 1]),
                  pc_off, pi_off, cc_off, ci_off);
         if (status != NFM_S_SUCCESS)
          {
            MEMclose (&list);
            MEMclose (&p_list);
            _NFMdebug ((fname, "Chk Par In Loop : status = <0x%.8x>\n",
            status));
            return (status);
          }
       }

      status = MEMclose (&p_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&p_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM CLose : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);
       }

      status = MEMclose (&list);
      if (status != MEM_S_SUCCESS)
       {
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM CLose : status = <0x%.8x>\n",status));
         return (NFM_E_MEM);
       }
 
      _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
      NFM_S_SUCCESS));
      return (NFM_S_SUCCESS); 
   }

 long NFMcheck_parent_loop (user_id, cit_attr, par_list, cat_no, item_no,
                            pc_off, pi_off, cc_off, ci_off)
   long    user_id;
   MEMptr  cit_attr, par_list;
   long    cat_no, item_no;
   long    pc_off, pi_off, cc_off, ci_off;
   {
     static char *fname = "NFMcheck_parent_loop" ;
      long     status, atol ();
      char     **data;
      long     x, count, row_no;
      char     *sql_str;
      char     value [100];
      MEMptr   list = NULL;

      _NFMdebug ((fname, "Cat  No = <%d> : Item No = <%d> : PC Offset = <%d> : PI Offset = <%d> : CC Offset = <%d> : CI Offset = <%d>\n",
		  cat_no, item_no, pc_off, pi_off, cc_off, ci_off));

      status = MEMbuild_array (par_list);
      if (status != MEM_S_SUCCESS)
       {
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		     status));
         return (NFM_E_MEM);            
       }
 
      data = (char **) par_list -> data_ptr;

      for (x = 0; x < par_list -> rows; ++x)
       {
         count = par_list -> columns * x;

         if (strcmp (data [count + 2], "N"))
          {
            if ((atol (data [count]) == cat_no) &&
                (atol (data [count + 1]) == item_no))
             {
	       ERRload_struct (NFM, NFM_E_SET_IN_LOOP, "", NULL);
               _NFMdebug ((fname, "Set In Loop : status = <0x%.8x>\n",
			   NFM_E_SET_IN_LOOP));
               return (NFM_E_SET_IN_LOOP);            
             }
          }
       }

      sql_str = (char *) malloc (2 * MEM_SIZE);
      if (! sql_str)
       {
	 ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
		     NFM_E_MALLOC));
         return (NFM_E_MALLOC);            
       }

      sprintf (sql_str, "%d\1%d\1", cat_no, item_no);
 
      status = MEMwrite (par_list, sql_str);
      if (status != MEM_S_SUCCESS)
       {
         free (sql_str);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);            
       }

      row_no = par_list -> rows;

      data = (char **) cit_attr -> data_ptr;

      sprintf (sql_str, "SELECT %s, %s FROM nfmsetcit WHERE ",
               data [(cit_attr -> columns * pc_off)],
               data [(cit_attr -> columns * pi_off)]);

      strcat (sql_str, data [(cit_attr -> columns * cc_off)]);

      sprintf (value, "%d", cat_no);

      if (! strncmp (data [(cit_attr -> columns * cc_off) + 1],
                     "char", 4))
       {
         strcat (sql_str, ",");
         strcat (sql_str, value);
         strcat (sql_str, ",");
       }
      else
         strcat (sql_str, value);
        
      strcat (sql_str, " AND ");

      strcat (sql_str, data [(cit_attr -> columns * ci_off)]);

      sprintf (value, "%d", item_no);

      if (! strncmp (data [(cit_attr -> columns * ci_off) + 1],
                     "char", 4))
       {
         strcat (sql_str, ",");
         strcat (sql_str, value);
         strcat (sql_str, ",");
       }
      else
         strcat (sql_str, value);

      status = SQLquery (sql_str, &list, MEM_SIZE);
      if ((status != SQL_S_SUCCESS) && 
          ((status) != SQL_I_NO_ROWS_FOUND))
       {
         free (sql_str);
         MEMclose (&list);
         ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
         _NFMdebug ((fname, "SQL Stmt Failed : status = <0x%.8x>\n",
		     status));
         return ( NFM_E_SQL_QUERY);
       }

      free (sql_str);

      status = MEMbuild_array (list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		     status));
         return (NFM_E_MEM);
       }

      data = (char **) list -> data_ptr;

      for (x = 0; x < list -> rows; ++x)
       {
         count = list -> columns * x;

         status = NFMcheck_parent_loop (user_id, cit_attr, par_list,
                  atol (data [count]), atol (data [count + 1]),
                  pc_off, pi_off, cc_off, ci_off);
         if (status != NFM_S_SUCCESS)
          {
            MEMclose (&list);
            _NFMdebug ((fname, "Chk Par In Loop : status = <0x%.8x>\n",
            status));
            return (status);
          }
       }

      status = MEMwrite_data (list, "N", row_no, 3);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
		     status));
         return (NFM_E_MEM);            
       }

      status = MEMclose (&list);
      if (status != MEM_S_SUCCESS)
       {
	 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n",
		     status));
         return (NFM_E_MEM);            
       }
      
      _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
		  NFM_S_SUCCESS));
      return (NFM_S_SUCCESS); 
   }

 long NFMreset_co_out_deleted_member (user_id, cat_name, item_no, level,
                                      set_status, co_status)
   long     user_id;
   char     *cat_name;
   long     item_no, level;
   long     set_status, co_status;
   {
     static char *fname = "NFMreset_co_out_deleted_member" ;
      long    status;
      char    sql_str [1024], value1 [50], value2 [50];
      char    level_num [50];
  
      _NFMdebug ((fname, "Cat Name = <%s> : Item No = <%d> : Level = <%d> : Set Stat = <%d> : Co Stat = <%d>\n",
		  cat_name, item_no, level, set_status, co_status));

      if (level >= 0)
        sprintf (level_num, "%d", level);
      else
        sprintf (level_num, "-1");
      
      if (set_status == NFM_E_SET)
       {
         if (co_status == NFM_E_MEM_OUT)
          {
	    sprintf (value1, "'SO'");
   
	    sprintf (value2, "%s", level_num);
          }
         else if (co_status == NFM_E_MEM_OUT_NO_FILE)
          {
	    sprintf (value1, "'SN'");

	    sprintf (value2, "%s", level_num);
          }
       }
      else
       {
         if (co_status == NFM_E_MEM_OUT)
          {
	    sprintf (value1, "'IO'");
   
	    sprintf (value2, "null");
          }
         else if (co_status == NFM_E_MEM_OUT_NO_FILE)
          {
	    sprintf (value1, "''");

	    sprintf (value2, "null");
          }
       }

     sprintf (sql_str, "UPDATE %s SET %s = %s, %s = %s WHERE %s = %d",
       cat_name, "n_status", value1, "n_colevel", value2, "n_itemno", item_no);

      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
       {
	 ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
         _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
		     status));
         return (NFM_E_SQL_STMT);
       }
      
      _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
      NFM_S_SUCCESS));
      return (NFM_S_SUCCESS); 
   }

 long NFMget_parent_checkout_level (user_id, cat_no, item_no, level,
                                    sel_str, c_catno, c_itemno, c_type)
   long    user_id;
   long    cat_no, item_no;
   long    *level;
   char    *sel_str, *c_catno, *c_itemno, *c_type;
   {
     static char *fname = "NFMget_parent_checkout_level" ;
      long    status, atol ();
      MEMptr  list = NULL;
      char    **column, **data;
      long    x, count;
      long    comma, found;
      char    cat_name [100], co_status [10];
      char    sql_str [1024];

      _NFMdebug ((fname, "Cat No  = <%d> : Item No = <%d> : Level = <%d> : Sel Str = <%s> : Cat No = <%s> : Item No = <%s>\n", 
		  cat_no, item_no, level, sel_str, c_catno, c_itemno)) ;

      if (! strlen (sel_str))
       {
         status = NFMquery_attributes_definition (user_id, 
                  "NFMSYSTEM", "NFMSETCIT", &list);
         if (status != NFM_S_SUCCESS)
          {
            MEMclose (&list);
            _NFMdebug ((fname, "Query Table Attr : status = <0x%.8x>\n",
            status));
            return (status);
          }  

         status = MEMbuild_array (list);
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (&list);
	    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
			status));
            return (NFM_E_MEM);
          }

         column = (char **) list -> column_ptr;
         data   = (char **) list -> data_ptr;

         for (x = 0; x < list -> rows; ++x)
          {
            count = list -> columns * x;

            if (! strcmp (data [count + 2], "n_pcatalogno"))
             {
               if (comma) strcat (sel_str, ", ");
               comma = 1;

               strcat (sel_str, data [count]);
             }
            else if (! strcmp (data [count + 2], "n_pitemno"))
             {
               if (comma) strcat (sel_str, ", ");
               comma = 1;

               strcat (sel_str, data [count]);
             }
            else if (! strcmp (data [count + 2], "n_ccatalogno"))
              sprintf (c_catno, "%s", data [count]);
            else if (! strcmp (data [count + 2], "n_citemno"))
              sprintf (c_itemno, "%s", data [count]);
          }

         status = MEMclose (&list);
         if (status != MEM_S_SUCCESS)
          {
	    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n",
			status));
            return (NFM_E_MEM);
          }
       }

      sprintf (sql_str,
               "SELECT %s FROM %s WHERE %s = %d AND %s = %d AND %s = 'P'",
               sel_str, c_catno, cat_no, c_itemno, item_no, c_type);

      status = SQLquery (sql_str, &list, MEM_SIZE);
      if ((status != SQL_S_SUCCESS)  &&
          ((status) != SQL_I_NO_ROWS_FOUND))
       {
         MEMclose (&list);
	 ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
         _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
		     status));
         return ( NFM_E_SQL_QUERY);
       }
        
      status = MEMbuild_array (list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&list);
	 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		     status));
         return (NFM_E_MEM);
       }

      data = (char **) list -> data_ptr;
      
      found = 0;

      for (x = 0; (x < list -> rows) && (! found); ++x)
       {
         count = list -> columns * x;

         status = NFMget_catalog_name (user_id, data [count], cat_name);
         if (status != NFM_S_SUCCESS)
          {
            MEMclose (&list);
            _NFMdebug ((fname, "Get Cat No : status = <0x%.8x>\n",
            status));
            return (status);
          }

         status = NFMcheck_co_status (user_id, data [count],
                  atol (data [count + 1]), co_status);
         if (status != NFM_S_SUCCESS         &&
             status != NFM_E_NO_FILE         &&
             status != NFM_E_ITEM_OUT        &&
             status != NFM_E_ITEM_IN         &&
             status != NFM_E_SET_OUT         && 
             status != NFM_E_SET_OUT_NO_FILE &&
             status != NFM_E_MEM_OUT         &&
             status != NFM_E_MEM_OUT_NO_FILE)
          {
            MEMclose (&list);
            _NFMdebug ((fname, "Get Co Status : status = <0x%.8x>\n",
            status));
            return (status);
          }

         if (status == NFM_E_SET_OUT || status == NFM_E_SET_OUT_NO_FILE)
          {
            status = NFMget_set_checkout_level (user_id, cat_name,
                     item_no, level);
            if (status != NFM_S_SUCCESS)
             {
               MEMclose (&list);
               _NFMdebug ((fname, "Get Set Co Lvl : status = <0x%.8x>\n",
               status));
               return (status);
             }

            if (status == NFM_S_SUCCESS)
             {
               MEMclose (&list);
               _NFMdebug ((fname, "Level = <%d> : SUCCESSFUL\n", *level));
               return (NFM_S_SUCCESS);                
             }
          }

         status = NFMget_parent_checkout_level (user_id,
                  atol (data [count]),
                  atol (data [count + 1]), level, sel_str,
                  c_catno, c_itemno, c_type);
         if (status != NFM_S_SUCCESS)
          {
            MEMclose (&list);
            _NFMdebug ((fname, "Get Par Co Level : status = <0x%.8x>\n",
            status));
            return (status); 
          }

         if (status == NFM_S_SUCCESS)
          {
            *level = *level - 1;
            found = 1;
          }
       }

      status = MEMclose (&list);
      if (status != MEM_S_SUCCESS)
       {
	 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
         return (NFM_E_MEM); 
       }

      _NFMdebug ((fname, "Level = <%d> : SUCCESSFUL\n", *level));

      return (NFM_S_SUCCESS); 
   }

 long NFMupd_set_mem_co (user_id, attr_list, data_list)
   long      user_id;
   MEMptr    attr_list, data_list;
   {
      static char *fname = "NFMupd_set_mem_co" ;
      long      status, atol ();
      char      **column, **data, **data1;
      long      a, b, x, y, count;
      long      i, j, k, l, m, n, o, p, q;
      long      cat_no, item_no;
      long      coout_status;
      char      co_status [10];
      MEMptr    list = NULL;
      long      NFMdrop_set_member ();
      long      NFMadd_set_member ();

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
              if (! strcmp (column [y], "n_name"))     a = y;
         else if (! strcmp (column [y], "n_datatype")) b = y;
       }

      i = -1; j = -1; k = -1; l = -1; m = -1;
      n = -1; o = -1; p = -1; q = -1;

      for (x = 0; x < attr_list -> rows; ++x)
       {
         count = attr_list -> columns * x;

              if (! strcmp (data [count + a], "n_citno"))        i = x;
         else if (! strcmp (data [count + a], "n_catalogname"))  j = x;
         else if (! strcmp (data [count + a], "n_itemname"))     k = x;
         else if (! strcmp (data [count + a], "n_itemrev"))      l = x;
         else if (! strcmp (data [count + a], "n_type"))         m = x;
         else if (! strcmp (data [count + a], "n_level"))        n = x;
         else if (! strcmp (data [count + a], "n_setindicator")) o = x;
         else if (! strcmp (data [count + a], "n_coout"))        p = x;
         else if (! strcmp (data [count + a], "n_status"))       q = x;
       }      

      cat_no = 0;   item_no = 0;

      status = NFMget_catalog_no (user_id, data1 [j], &cat_no);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Get Cat No : status = <0x%.8x>\n",
         status));
         return (status); 
       }

      status = NFMget_item_no (user_id, data1 [j],
               data1[k], data1[l], &item_no);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Get Item No : status = <0x%.8x>\n",
         status));
         return (status); 
       }

      status = NFMcheck_item_setindicator (user_id, data1 [j], item_no);
      if (status != NFM_S_SUCCESS && status != NFM_E_SET)
       {
         _NFMdebug ((fname, "Get Item No : status = <0x%.8x>\n",
         status));
         return (status); 
       }

      status = NFMcheck_co_status (user_id, data1 [j],
               item_no, co_status);
      if ((status != NFM_S_SUCCESS)         &&
          (status != NFM_E_NO_FILE)         &&
          (status != NFM_E_ITEM_OUT)        &&
          (status != NFM_E_ITEM_IN)         &&
          (status != NFM_E_SET_OUT)         &&
          (status != NFM_E_SET_OUT_NO_FILE) &&
          (status != NFM_E_MEM_OUT)  &&
          (status != NFM_E_MEM_OUT_NO_FILE))
	{
	  _NFMdebug ((fname, "Check Co Status : status = <0x%.8x>\n",
		      status));
	  ERRload_struct (NFM, NFM_E_UNKNOWN_CO_FLAG, "", NULL) ;
	  return (NFM_E_UNKNOWN_CO_FLAG) ;
       }

      coout_status = status;

      status = NFMquery_attributes_definition (user_id, "NFMSYSTEM", 
					       "NFMSETCIT", &list);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose (&list);
         _NFMdebug ((fname, "Qry Tab Def : status = <0x%.8x>\n",
         status));
         return (status); 
       }

      status = MEMbuild_array (list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&list);
	 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		     status));
         return (NFM_E_MEM);       
       }

      status = NFMstop_transaction (0);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose (&list);
         _NFMdebug ((fname, "Stop Transaction : status = <0x%.8x>\n",
         status));
         return (status); 
       }

      for (x = 1; x < data_list -> rows; ++x)
       {
         count = data_list -> columns * x;

         if (! strlen (data1 [count + n]))
          {
            status = MEMwrite_data (data_list, "1", x + 1, n + 1);
            if (status != MEM_S_SUCCESS)
             {
               MEMclose (&list);
               NFMrollback_transaction (0);
	       ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               _NFMdebug ((fname, " MEM Wr Data : status = <0x%.8x>\n",
			   status));
               return (NFM_E_MEM); 
             }
          }

         if (atol (data1 [count + n]) == 1)
          {
            NFMchange_case (data1[ count + q], 0);

            if (! strcmp (data1 [count + q], "DROP"))
             {
               status = NFMdrop_set_member (user_id, list, data_list,
                        cat_no, item_no, coout_status, x);
               if (status != NFM_S_SUCCESS)
                {
                  MEMclose (&list);
                  NFMrollback_transaction (0);
                  _NFMdebug ((fname, "Drop MEM : status = <0x%.8x>\n",
                  status));
                  return (status); 
                }
             }
            else
             {
               if (! strlen (data1 [count + i]))
                {
                  status = NFMadd_set_member (user_id, list, data_list, 
                           cat_no, item_no, co_status, x);
                  if ((status != NFM_S_SUCCESS) && 
                      (status != NFM_E_SET_MEM_EXISTS))
                   {
                     MEMclose (&list);
                     NFMrollback_transaction (0);
                     _NFMdebug ((fname, "Add MEM : status = <0x%.8x>\n",
                     status));
                     return (status); 
                   }
                }
             }
          }
       }

      status = MEMclose (&list); 
      if (status != MEM_S_SUCCESS)
       {
         NFMrollback_transaction (0);
	 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Close List : status = <0x%.8x>\n",
		     status));
         return (NFM_E_MEM); 
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


