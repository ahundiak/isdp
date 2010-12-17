#include "machine.h"
#include "NFMA.h"
#include "WFstruct.h"

 extern struct WFstruct WFinfo;

 long NFMupdate_project_members (user_id, attr_list, data_list)
   long      user_id;
   MEMptr    attr_list, data_list;
   {
      static char *fname = "NFMupdate_project_members" ;
      long      status, atol ();
      char      **column, **data, **data1;
      long      a, b, x, y, count;
      long      i, j, k, l, m, n, o;
      char      proj_name [100];
      MEMptr    list = NULL;
      long      NFMdrop_project_member ();
      long      NFMadd_project_member ();

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

      _NFMdebug ((fname, "No. rows in data_list = <%d>\n",
                 data_list->rows));

      a = -1; b = -1; 

      for (y = 0; y < attr_list -> columns; ++y)
       {
              if (! strcmp (column [y], "n_name"))     a = y;
         else if (! strcmp (column [y], "n_datatype")) b = y;
       }

      i = -1; j = -1; k = -1; l = -1; m = -1;
      n = -1; o = -1;

      for (x = 0; x < attr_list -> rows; ++x)
       {
         count = attr_list -> columns * x;

              if (! strcmp (data [count + a], "n_citno"))        i = x;
         else if (! strcmp (data [count + a], "n_catalogname"))  j = x;
         else if (! strcmp (data [count + a], "n_itemname"))     k = x;
         else if (! strcmp (data [count + a], "n_itemrev"))      l = x;
         else if (! strcmp (data [count + a], "n_type"))         m = x;
         else if (! strcmp (data [count + a], "n_status"))       n = x;
         else if (! strcmp (data [count + a], "n_projectname"))  o = x;
       }      

      status = NFMget_project_name (user_id, WFinfo.proj_no,
               proj_name);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Get Proj Name : status = <0x%.8x>\n",
		     status));
         return (status); 
       }

      for (x = 0; x < data_list -> rows; ++x)
       {
         count = data_list -> columns * x;

         status = MEMwrite_data (data_list, proj_name, x + 1, o + 1);
         if (status != MEM_S_SUCCESS)
          {
	    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			status));
            return (NFM_E_MEM); 
          }
       }

      status = NFMquery_table_definition (user_id, "NFMSYSTEM", 
                                          "NFMPROJECTCIT", &list);
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

      for (x = 0; x < data_list -> rows; ++x)
       {
         count = data_list -> columns * x;

         NFMupper_case (data1[ count + n], data1 [count+n]) ;

         if (! strcmp (data1 [count + n], "DROP"))
          {
            status = NFMdrop_project_member (user_id, list, data_list,
                                             WFinfo.proj_no, x);
            if (status != NFM_S_SUCCESS)
             {
               MEMclose (&list);
               NFMrollback_transaction (0);
               _NFMdebug ((fname, "Drop Proj MEM : status = <0x%.8x>\n",
			   status));
               return (status); 
             }
          }
         else if (! strcmp (data1 [count + n], "ADD"))
          {
            status = NFMadd_project_member (user_id, list, data_list, 
                                            WFinfo.proj_no, x);
            if ((status != NFM_S_SUCCESS) && 
                (status != NFM_E_PROJECT_MEM_EXISTS) &&
		(status != NFM_E_PROJECT_MEM_OWNED))
             {
               MEMclose (&list);
               NFMrollback_transaction (0);
               _NFMdebug ((fname, "Add Proj MEM : status = <0x%.8x>\n",
			   status));
               return (status); 
             }
          }
       }  /* for */

      status = MEMclose (&list); 
      if (status != MEM_S_SUCCESS)
       {
         NFMrollback_transaction (0);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Close List : status = <0x%.8x>\n", status));
         return (NFM_E_MEM); 
       }

      status = NFMstart_transaction (0);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Start Transaction : status = <0x%.8x>\n",status));
         return (status); 
       }

      _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
      return (NFM_S_SUCCESS); 
    }


 long NFMdrop_project_member (user_id, cit_attr, data_list, proj_no, row_no)
   long    user_id;
   MEMptr  cit_attr, data_list;
   long    proj_no;
   long    row_no;   
   {
      static char *fname = "NFMdrop_project_member" ;
      long     status, atol ();
      char     **column,  **data;
      char     **column1, **data1;
      long     a, b, y, x, count;
      long     i, j, k, l, m, i1, and;
      long     c_cat_no, c_item_no;
      char     value [50];
      char     sql_str [1024], sql_str1 [1024];
      long     val_exists;
      char     sel_str [1024], c_catno [50], c_itemno [50];
      long     NFMreset_co_out_deleted_member ();
   
      _NFMdebug ((fname, "Proj No     = <%d> : Row No = <%d>\n", 
		  proj_no, row_no));

      sel_str [0] = 0; c_catno [0] = 0; c_itemno [0] = 0;

      column  = (char **) cit_attr -> column_ptr;
      data    = (char **) cit_attr -> data_ptr;

      column1 = (char **) data_list -> column_ptr;
      data1   = (char **) data_list -> data_ptr;

      a = -1; b = -1; 

      for (y = 0; y < cit_attr -> columns; ++y)
       {
              if (! strcmp (column [y], "n_name"))     a = y;
         else if (! strcmp (column [y], "n_datatype")) b = y;
       }

      i = -1; j = -1; k = -1; l = -1; m = -1;

      for (y = 0; y < data_list -> columns; ++y)
       {
              if (! strcmp (column1 [y], "n_citno"))       i = y;
         else if (! strcmp (column1 [y], "n_catalogname")) j = y;
         else if (! strcmp (column1 [y], "n_itemname"))    k = y;
         else if (! strcmp (column1 [y], "n_itemrev"))     l = y;
         else if (! strcmp (column1 [y], "n_type"))        m = y;
       }      
/******************* 4/15/91 ******************************
      if (i < 0 || j < 0 || k < 0 || l < 0 || m < 0)
       {
         ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL);
         _NFMdebug ((fname, "Corrupted Buffers : status = <0x%.8x>\n",
         NFM_E_CORRUPTED_BUFFERS));
         return (NFM_E_CORRUPTED_BUFFERS); 
       }
***********************************************************/
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

      NFMupper_case (data1 [count + m], data1 [count + m]) ;

      if ((! strcmp (data1 [count + m], "O")) &&
          (! strcmp (data1 [count + m], "R")))
       {
         ERRload_struct (NFM, NFM_E_UNKNOWN_PROJECT_TYPE, "", NULL);
         _NFMdebug ((fname, "Unknown Proj Mem Type : status = <0x%.8x>\n",
         NFM_E_UNKNOWN_PROJECT_TYPE));
         return (NFM_E_UNKNOWN_PROJECT_TYPE); 
       }

      sprintf (sql_str, "%s", " WHERE ");
      and = 0;

      for (x = 0; x < cit_attr -> rows; ++x)
       {
         count = cit_attr -> columns * x;
         val_exists = 0;  value [0] = 0;

              if (! strcmp (data [count + a], "n_citno"))         i1 = x;
         else if (! strcmp (data [count + a], "n_projectno"))
          {
             val_exists = 1;
             sprintf (value, "%d", proj_no);
          }
         else if (! strcmp (data [count + a], "n_itemno"))
          {
             val_exists = 1;
             sprintf (value, "%d", c_item_no);
          }
         else if (! strcmp (data [count + a], "n_catalogno"))
          {
             val_exists = 1;
             sprintf (value, "%d", c_cat_no);
          }
         else if (! strcmp (data [count + a], "n_type"))
          {
             val_exists = 1;
             sprintf (value, data1 [(data_list -> columns * row_no) + m]);
          }

         if (val_exists)
          {
            if (and)  strcat (sql_str, " AND ");
            and++;

            strcat (sql_str, data [count + a]);
            strcat (sql_str, " = ");
 
            if (! strncmp (data [count + b], "char", 4))
             {
               strcat (sql_str, "'");
               strcat (sql_str, value);
               strcat (sql_str, "'");
             }
            else
               strcat (sql_str, value);
          }
       }

      if (i1 < 0 || (and < 4))
       {
         ERRload_struct (NFM, NFM_E_CORRUPTED_SYSTEM, "", NULL);
         _NFMdebug ((fname, "System Is Corrupted : status = <0x%.8x>\n",
         NFM_E_CORRUPTED_SYSTEM));
         return (NFM_E_CORRUPTED_SYSTEM); 
       }

      status = NFMget_attr_value (user_id, "NFMPROJECTCIT",
               data [(cit_attr -> columns * i1) + a], sql_str, value);
      if (status != NFM_S_SUCCESS)
       {
         if (status == NFM_I_BAD_CONDITION)
          {
            ERRload_struct (NFM, NFM_E_BAD_PROJECT_MEMBER, "", NULL);
            _NFMdebug ((fname, "No Such Proj Member : status = <0x%.8x>\n",
            NFM_E_BAD_PROJECT_MEMBER));
            return (NFM_E_BAD_PROJECT_MEMBER); 
          }

         _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
         status));
         return (status); 
       }

      sprintf (sql_str1, "DELETE FROM %s %s", "NFMPROJECTCIT", sql_str);

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

      status = NFMreturn_serial_slot (user_id, "nfmprojectcit",
               data [(cit_attr -> columns * i1) + a], atol (value));
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Ret Serial Slot : status = <0x%.8x>\n",
         status));
         return (status); 
       }
      
      _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
      return (NFM_S_SUCCESS); 
   }

 long NFMadd_project_member (user_id, cit_attr, data_list,
                             proj_no, row_no)
   long       user_id;
   MEMptr     cit_attr, data_list;
   long       proj_no;
   long       row_no;
   {
      static char *fname = "NFMadd_project_member" ;
      long      status;
      char      **column,  **data;
      char      **column1, **data1;
      long      a, b, x, y, count;
      long      i, j, k, l, m, and, n, row_id;
      long      i1, j1, k1, l1;
      long      c_cat_no, c_item_no;
      long      comma, insert, found;
      char      value [50];
      long      val_exists;
      char      *cit_str1, *cit_str2;
      char      sql_str [1024];
      long      NFMcheck_project_mapping();
      long      NFMcheck_project_ownership();

      _NFMdebug ((fname, "Project No  = <%d>  : Row No = <%d>\n",
		  proj_no, row_no));

      column  = (char **) cit_attr -> column_ptr;
      data    = (char **) cit_attr -> data_ptr;

      column1 = (char **) data_list -> column_ptr;
      data1   = (char **) data_list -> data_ptr;

      a = -1; b = -1; 

      for (y = 0; y < cit_attr -> columns; ++y)
       {
              if (! strcmp (column [y], "n_name"))         a = y;
         else if (! strcmp (column [y], "n_datatype"))     b = y;
       }
      i = -1; j = -1; k = -1; l = -1; m = -1; n = -1;

      for (y = 0; y < data_list -> columns; ++y)
       {
              if (! strcmp (column1 [y], "n_citno"))       i = y;
         else if (! strcmp (column1 [y], "n_catalogname")) j = y;
         else if (! strcmp (column1 [y], "n_itemname"))    k = y;
         else if (! strcmp (column1 [y], "n_itemrev"))     l = y;
         else if (! strcmp (column1 [y], "n_type"))        m = y;
         else if (! strcmp (column1 [y], "n_projectname")) n = y;
       }      
/******************* 4/15/91 *************************
      if (i < 0 || j < 0 || k < 0 || l < 0 || m < 0 || n < 0)
       {
         ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL);
         _NFMdebug ((fname, "Corrupted Buffers : status = <0x%.8x>\n",
         NFM_E_CORRUPTED_BUFFERS));
         return (NFM_E_CORRUPTED_BUFFERS); 
       }
*******************************************************/
      count = data_list -> columns * row_no;

      status = NFMget_catalog_no (user_id, data1 [count + j], &c_cat_no);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Get Cat No : status = <0x%.8x>\n", status));
         return (status); 
       }

      status = NFMget_item_no (user_id, data1 [count + j],
               data1 [count + k], data1 [count + l], &c_item_no);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Get Item No : status = <0x%.8x>\n", status));
         return (status); 
       }

      if (! strcmp (data1 [count + m], "O"))
	  {
	    status = NFMcheck_project_mapping (user_id, proj_no, 
					       c_cat_no, c_item_no); 
	    if (status != NFM_S_SUCCESS)
	      {
		_NFMdebug ((fname, "Check Project Mapping : status = <0x%.8x>\n",
			    status));
		return (status); 
	      }

	    status = NFMcheck_project_ownership (user_id, proj_no, c_cat_no,
						 c_item_no, data1[count + m]); 
	    if (status != NFM_S_SUCCESS)
	      {
		_NFMdebug ((fname, "Check Project Ownership : status = <0x%.8x>\n",
			    status));
		return (status); 
	      }
	  }

      NFMupper_case (data1 [count + m], data1 [count + m]) ;

      if ((! strcmp (data1 [count + m], "O")) &&
          (! strcmp (data1 [count + m], "R")))
       {
         ERRload_struct (NFM, NFM_E_UNKNOWN_PROJECT_TYPE, "", NULL);
         _NFMdebug ((fname, "Unknown Project Type : status = <0x%.8x>\n",
         NFM_E_UNKNOWN_PROJECT_TYPE));
         return (NFM_E_UNKNOWN_PROJECT_TYPE); 
       }

      sprintf (sql_str, " WHERE ");

      and = 0;
      i1 = -1; j1 = -1; k1 = -1; l1 = -1; 

      for (x = 0; x < cit_attr -> rows; ++x)
       {
         count = cit_attr -> columns * x;
         val_exists = 0;  value [0] = 0;

              if (! strcmp (data [count + a], "n_citno"))         i1 = x;
         else if (! strcmp (data [count + a], "n_catalogno"))
          {
             j1 = x;  val_exists = 1;
             sprintf (value, "%d", c_cat_no);
          }
         else if (! strcmp (data [count + a], "n_itemno"))
          {
             k1 = x;  val_exists = 1;
             sprintf (value, "%d", c_item_no);
          }
         else if (! strcmp (data [count + a], "n_projectno"))
          {
             l1 = x; val_exists = 1;
             sprintf (value, "%d", proj_no);
          }

         if (val_exists)
          {
            if (and)  strcat (sql_str, " AND ");
            and++;

            strcat (sql_str, data [count + a]);
            strcat (sql_str, " = ");
 
            if (! strncmp (data [count + b], "char", 4))
             {
               strcat (sql_str, "'");
               strcat (sql_str, value);
               strcat (sql_str, "'");
             }
            else
               strcat (sql_str, value);
          }
       }
/******************4/15/91 *********************
      if (i1 < 0 || j1 < 0 || k1 < 0 || l1 < 0 || (and < 3))
       {
         ERRload_struct (NFM, NFM_E_CORRUPTED_SYSTEM, "", NULL);
         _NFMdebug ((fname, "System Is Corrupted : status = <0x%.8x>\n",
         NFM_E_CORRUPTED_SYSTEM));
         return (NFM_E_CORRUPTED_SYSTEM); 
       }
**************************************************/
      status = NFMget_attr_value (user_id, "NFMPROJECTCIT",
               data [(cit_attr -> columns * i1) + a], sql_str, value);
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

         ERRload_struct (NFM, NFM_E_PROJECT_MEM_EXISTS, "", NULL);
         _NFMdebug ((fname, "MEMBER EXISTS : status = <0x%.8x>\n", 
		     NFM_E_PROJECT_MEM_EXISTS));
         return (NFM_E_PROJECT_MEM_EXISTS);
       }

      status = NFMget_serial_slot (user_id, "nfmprojectcit",
               data [(cit_attr -> columns * i1) + a], &row_id);
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
      cit_str1 [0] = 0;

      cit_str2 = (char *) malloc (MEM_SIZE + data_list -> row_size);
      if (! cit_str2)
       {
         free (cit_str1);
         ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
		     NFM_E_MALLOC));
         return (NFM_E_MALLOC); 
       }
      cit_str2 [0] = 0;

      comma = 0;

      sprintf (cit_str1,  "INSERT INTO %s (", "NFMPROJECTCIT");
      sprintf (cit_str2, ") VALUES (");

      for (x = 0; x < cit_attr -> rows; ++x)
       {
         count = cit_attr -> columns * x;

         _NFMdebug ((fname, "Attr Name = <%s> : Sql Str 1 = <%s> : Sql Str 2 = <%s>\n", data [count + a], cit_str1, cit_str2));

         value [0] = 0; val_exists = 0; insert = 0;

              if (! strcmp (data [count + a], "n_citno"))
          {
            val_exists = 1; insert = 1;
            sprintf (value, "%d", row_id);
          }
         else if (! strcmp (data [count + a], "n_projectno"))
          {
            val_exists = 1; insert = 1;
            sprintf (value, "%d", proj_no);
          }
         else if (! strcmp (data [count + a], "n_itemno"))
          {
            val_exists = 1; insert = 1;
            sprintf (value, "%d", c_item_no);
          }
         else if (! strcmp (data [count + a], "n_catalogno"))
          {
            val_exists = 1; insert = 1;
            sprintf (value, "%d", c_cat_no);
          }
         else if (! strcmp (data [count + a], "n_archiveno"))    insert = 0;
         else if (! strcmp (data [count + a], "n_archiveflag"))  insert = 0;
         else if (! strcmp (data [count + a], "n_status"))       insert = 0;
         else
          {
            found = 0;

            for (y = 0; ((y < data_list -> columns) && (! found)); ++y)
             {
               if (! strcmp (data [count + a], column1 [y]))
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
               _NFMdebug ((fname, "Corrupted Buffers : status = <0x%.8x>\n",
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

            strcat (cit_str1, data [count + a]);

            if (! strncmp (data [count + b], "char", 4))
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
                  if (strlen (data1 [(data_list -> columns * row_no) + y]))
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
      
      _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
      return (NFM_S_SUCCESS); 
   }


long NFMcheck_project_sa_mapping (user_id, proj_no, cat_no, item_no)
  long user_id;
  long proj_no;
  long cat_no;
  long item_no;     
{
  static char *fname = "NFMcheck_project_sa_mapping" ;
  long status;
  char sql_str[1024], cat_name [50];
  char item_name [NFM_ITEMNAME+1], item_rev [NFM_ITEMREV +1] ;
  MEMptr sql_buffer = NULL; 
  
  _NFMdebug ((fname, "Project No = <%d> : Catalog No = <%d>\n",
	      proj_no, cat_no));
  
  status = NFMget_catalog_name (user_id, cat_no, cat_name) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Getting Catalog Name for Cat No %d failed = status <0x%.8x>\n", cat_no, status)) ;
      return (status) ;
    }
  
  sprintf (sql_str, "SELECT n_cisano FROM f_%s WHERE n_itemnum = %d AND \
n_cisano NOT IN \
(SELECT NFMCATALOGSAMAP.n_sano FROM NFMCATALOGSAMAP, NFMPROJECTSAMAP \
 WHERE %s.%s = %d AND %s.%s = %d AND %s.%s = %s.%s)",
cat_name, item_no,
"NFMPROJECTSAMAP", "n_projectno", proj_no,
"NFMCATALOGSAMAP", "n_catalogno", cat_no,
"NFMPROJECTSAMAP", "n_mapno", "NFMCATALOGSAMAP", "n_mapno"
) ;

  status = SQLquery (sql_str, &sql_buffer, 1024);
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
  {
     MEMclose (&sql_buffer);
     _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status ));
     ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
     _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status));
     return (NFM_E_SQL_QUERY);
   }

   MEMclose (&sql_buffer);

  if (status != SQL_I_NO_ROWS_FOUND)
   {
      strcpy (item_name, "") ;
      NFMget_item_name (user_id, cat_name, item_no,
                        item_name, item_rev) ;
      ERRload_struct (NFM, NFM_E_ITEM_SA_NOT_IN_PROJ_MAP, "%s", item_name) ;
      return (NFM_E_ITEM_SA_NOT_IN_PROJ_MAP) ;
   }

  _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS); 
}

long NFMcheck_project_acl_mapping (user_id, proj_no, cat_no, item_no)
  long user_id;
  long proj_no;
  long cat_no;
  long item_no;
{
  static char *fname = "NFMcheck_project_acl_mapping" ;
  long status;
  char sql_str[1024], cat_name [50] ;
  char item_name [NFM_ITEMNAME+1], item_rev [NFM_ITEMREV + 1];
  MEMptr sql_buffer = NULL; 

  _NFMdebug ((fname, "Project No = <%d> : Catalog No = <%d>\n", 
	      proj_no, cat_no));

  status = NFMget_catalog_name (user_id, cat_no, cat_name) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, 
		  "Getting Catalog Name for Cat No %d failed = status <0x%.8x>\n", cat_no, status)) ;
      return (status) ;
    }

  sprintf (sql_str, "SELECT n_aclno FROM %s WHERE n_itemno = %d AND \
n_aclno NOT IN \
(SELECT NFMCATALOGACLMAP.n_aclno FROM NFMCATALOGACLMAP, NFMPROJECTACLMAP \
 WHERE %s.%s = %d AND %s.%s = %d AND %s.%s = %s.%s)",
cat_name, item_no,
"NFMPROJECTACLMAP", "n_projectno", proj_no,
"NFMCATALOGACLMAP", "n_catalogno", cat_no,
"NFMPROJECTACLMAP", "n_mapno", "NFMCATALOGACLMAP", "n_mapno"
) ;

  status = SQLquery (sql_str, &sql_buffer, 1024);
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
  {
     MEMclose (&sql_buffer);
     ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
     _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status));
     return (NFM_E_SQL_QUERY);
  }

  MEMclose (&sql_buffer);

  if (status != SQL_I_NO_ROWS_FOUND)
   {
     strcpy (item_name, "") ;
     NFMget_item_name (user_id, cat_name, item_no,
                       item_name, item_rev) ;
     ERRload_struct (NFM, NFM_E_ITEM_ACL_NOT_IN_PROJ_MAP, "%s", item_name) ;
     return (NFM_E_ITEM_ACL_NOT_IN_PROJ_MAP) ;
   }

   _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS); 
}


long NFMcheck_project_mapping (user_id, proj_no, cat_no, item_no)
  long user_id;
  long proj_no;
  long cat_no;
  long item_no;
{
  static char *fname = "NFMcheck_project_mapping" ;
  long status;
  long NFMcheck_project_sa_mapping();
  long NFMcheck_project_acl_mapping();

  _NFMdebug ((fname, "Project No = <%d> : Catalog No = <%d>\n", 
	      proj_no, cat_no));

  status = NFMcheck_project_sa_mapping (user_id, proj_no, cat_no, item_no);
  if (status != NFM_S_SUCCESS)
  {
     _NFMdebug ((fname, "Check Project SA Maping : status = <0x%.8x>\n", 
               status));
     return (status);
  }

  status = NFMcheck_project_acl_mapping (user_id, proj_no, cat_no, item_no);
  if (status != NFM_S_SUCCESS)
  {
     _NFMdebug ((fname, "Check Project ACL Maping : status = <0x%.8x>\n", 
               status));
     return (status);
  }

  _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));

  return (NFM_S_SUCCESS); 
}



 long NFMcheck_project_ownership (user_id, proj_no, cat_no, item_no, type)
   long     user_id;                  /* I */
   long     proj_no;                  /* I */
   long     cat_no;                   /* I */
   long     item_no;                  /* I */
   char     *type;                    /* I    ("O" or "R" expected.) */
   {
      static char *fname = "NFMcheck_project_ownership" ;
      long     status;
      MEMptr   cit_attr = NULL;
      MEMptr   sql_buffer = NULL;
      char     **column, **format, **data;
      int      a, b, x, y, count ;
      int      i, j, k, l;
      char     sql_str[1024], sql_str1[512];

      _NFMdebug ((fname, "Project No = <%d> :Catalog No = <%d> : Item No = <%d> : Type = <%s>\n ",
		  proj_no, cat_no, item_no, type));

      if (type[0] != 'O')
      {
         _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
         NFM_S_SUCCESS));
         return (NFM_S_SUCCESS); 
      } 

      status = NFMquery_table_definition (user_id,
               "NFMSYSTEM", "NFMPROJECTCIT", &cit_attr);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose (&cit_attr);
         _NFMdebug ((fname, "Get Table Attr : status = <0x%.8x>\n",
         status));
         return (status);
       }

      status = MEMbuild_array (cit_attr);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&cit_attr);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		     status));
         return (NFM_E_MEM);
       }

      column = (char **) cit_attr -> column_ptr;
      format = (char **) cit_attr -> format_ptr;
      data   = (char **) cit_attr -> data_ptr;

      a = -1; b = -1; 

      for (y = 0; y < cit_attr -> columns; ++y)
       {
              if (! strcmp (column [y], "n_name"))      a = y;
         else if (! strcmp (column [y], "n_datatype"))  b = y;
       }

      i = -1; j = -1; k = -1; l = -1;

      for (x = 0; x < cit_attr -> rows; ++x)
       {
         count = cit_attr -> columns * x;

         if (! strcmp (data [count + a], "n_projectno"))        i = x;
         else if (! strcmp (data [count + a], "n_catalogno"))   j = x;
         else if (! strcmp (data [count + a], "n_itemno"))      k = x;
         else if (! strcmp (data [count + a], "n_type"))        l = x;
       }

      sprintf (sql_str, "SELECT * FROM %s WHERE ", "NFMPROJECTCIT");

/*  An item can only be owned in one project. 
    All others must reference it. */

/*
      count = cit_attr-> columns * i;    / * n_projectno. * /
      if (strncmp (data[count + b], "char", 4) == 0)
         sprintf (sql_str1, "%s = '%d' AND ", data[count + a], proj_no); 
      else
         sprintf (sql_str1, "%s = %d AND ", data[count + a], proj_no); 

      strcat (sql_str, sql_str1);
*/

      count = cit_attr-> columns * j;    /* n_catalogno. */
      if (strncmp (data[count + b], "char", 4) == 0)
         sprintf (sql_str1, "%s = '%d' AND ", data[count + a], cat_no); 
      else
         sprintf (sql_str1, "%s = %d AND ", data[count + a], cat_no); 

      strcat (sql_str, sql_str1);

      count = cit_attr-> columns * k;    /* n_itemno. */
      if (strncmp (data[count + b], "char", 4) == 0)
         sprintf (sql_str1, "%s = '%d' AND ", data[count + a], item_no); 
      else
         sprintf (sql_str1, "%s = %d AND ", data[count + a], item_no); 

      strcat (sql_str, sql_str1);

      count = cit_attr-> columns * l;    /* n_type. */
      if (strncmp (data[count + b], "char", 4) == 0)
         sprintf (sql_str1, "%s = '%s'", data[count + a], type); 
      else
         sprintf (sql_str1, "%s = %s", data[count + a], type); 

      strcat (sql_str, sql_str1);

      status = SQLquery (sql_str, &sql_buffer, 1024);
      if ((status) != SQL_I_NO_ROWS_FOUND)
       {
         MEMclose (&sql_buffer);
         MEMclose (&cit_attr);
         if ((status) == SQL_S_SUCCESS) 
         {
	   status = NFM_E_PROJECT_MEM_OWNED ;
	   ERRload_struct (NFM, NFM_E_PROJECT_MEM_OWNED, "", NULL);
	   _NFMdebug ((fname, "Proj Mem Owned : status = <0x%.8x>\n", 
		     NFM_E_PROJECT_MEM_OWNED));
         }
         else
         { 
	   status = NFM_E_SQL_QUERY ;
	   ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
	   _NFMdebug ((fname, "SQL Query : status = <0x%.8x>\n",
		       status));
         }
         return (status);
       }

      status = MEMclose (&sql_buffer);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&cit_attr);
	 status =NFM_E_MEM ;
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
         return (status);
       }

      status = MEMclose (&cit_attr);
      if (status != MEM_S_SUCCESS)
       {
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);
       }

      _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
      NFM_S_SUCCESS));
      return (NFM_S_SUCCESS); 
    }


