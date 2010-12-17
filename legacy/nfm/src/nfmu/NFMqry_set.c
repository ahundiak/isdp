#include "machine.h"
#include "NFMU.h"

 long NFMquery_set_members (user_id, cat_name, item_name, item_rev,
                            level, type,
                            attr_list, data_list)
   long     user_id;
   char     *cat_name;
   char     *item_name, *item_rev;
   long     level, type;
   MEMptr   *attr_list, *data_list;
   {
     static char *fname = "NFMquery_set_members";
      long     status;
      long     cat_no, item_no;
      char     p_catno [50], p_itemno [50];
      char     c_catno [50], p_type [50];
      long     c_catoffset, c_itemoffset, c_typeoffset;
      char     *sql_str;
      char     cit_str [1024], co_status [10];
      char     **column, **data;
      /* long     c, x, y, count; */
      long     c, x, count;
      long     NFMset_attributes ();
      long     NFMload_set_members ();

     _NFMdebug ((fname, "Cat   Name = <%s> : Item Name = <%s> : Item Rev = <%s> : Level = <%d> : Type = <%d>\n", 
		 cat_name, item_name, item_rev, level, type));
     
     status = NFMget_catalog_no (user_id, cat_name, &cat_no);
     if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Get Cat No : status = <0x%.8x>\n", status));
         return (status); 
       }
     
     status = NFMget_item_no (user_id, cat_name, 
			      item_name, item_rev, &item_no);
     if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Get Item No : status = <0x%.8x>\n", status));
         return (status); 
       }
     
/*  Item will become a set when a member is added  ****************
     status = NFMcheck_item_setindicator (user_id, cat_name, item_no);
     if (status != NFM_S_SUCCESS && status != NFM_E_SET)
       {
         _NFMdebug ((fname, "Check Set Indicator : status = <0x%.8x>\n",
		     status));
         return (status); 
       }
*/
     
     status = NFMcheck_co_status (user_id, cat_name, item_no, co_status);
     if ((status != NFM_S_SUCCESS)            &&
	 (status != NFM_E_NO_FILE)            &&
	 (status != NFM_E_ITEM_OUT)           &&
	 (status != NFM_E_ITEM_IN)            &&
	 (status != NFM_E_SET_OUT)            &&
	 (status != NFM_E_SET_OUT_NO_FILE)    &&
	 (status != NFM_E_MEM_OUT)            &&
	 (status != NFM_E_MEM_OUT_NO_FILE)    &&
	 (status != NFM_E_ITEM_IN_TRANS)      &&
	 (status != NFM_E_ITEM_OUT_TRANS)     &&
	 (status != NFM_E_NO_FILE_IN_TRANS)   &&
	 (status != NFM_E_NO_FILE_OUT_TRANS))
       {
         _NFMdebug ((fname, "Check Co State : status = <0x%.8x>\n",
         status));
         return (status); 
       }
     
     status = NFMset_attributes (user_id, 
				 p_catno, p_itemno, p_type, c_catno,
				 &c_catoffset, &c_itemoffset, &c_typeoffset, 
				 cit_str, attr_list, data_list);
     if (status != NFM_S_SUCCESS)
       {
         MEMclose (attr_list);
         MEMclose (data_list);
         _NFMdebug ((fname, "Query Set Attr Def : status = <0x%.8x>\n",
		     status));
         return (status); 
       }
     
     status = MEMbuild_array (*attr_list);
     if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
         MEMclose (data_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		     status));
         return (NFM_E_MEM); 
       }

      column = (char **) (*attr_list) -> column_ptr;
      data   = (char **) (*attr_list) -> data_ptr;

      c = -1;

      for (x = 0; x < (*attr_list) -> columns; ++x)
        if (! strcmp (column [x], "n_name"))    c = x;

      sql_str = (char *) malloc ((*data_list) -> row_size);
      if (! sql_str)
       {
         MEMclose (attr_list);
         MEMclose (data_list);
         ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
         NFM_E_MALLOC));
         return (NFM_E_MALLOC); 
       }
      sql_str [0] = 0;

      for (x = 0; x < (*attr_list) -> rows; ++x)
       {
         count = (*attr_list) -> columns * x;

         if (! strcmp (data [count + c], "n_catalogname"))
           strcat (sql_str, cat_name);
         else if (! strcmp (data [count + c], "n_itemname"))
           strcat (sql_str, item_name);
         else if (! strcmp (data [count + c], "n_itemrev"))
           strcat (sql_str, item_rev);
         else if (! strcmp (data [count + c], "n_type"))
           strcat (sql_str, "P");
         else if (! strcmp (data [count + c], "n_level"))
            strcat (sql_str, "0");
         else if (! strcmp (data [count + c], "n_coout"))
            strcat (sql_str, co_status);
         else if (! strcmp (data [count + c], "n_setindicator"))
            strcat (sql_str, "Y");
 
         strcat (sql_str, "\1");
       }

      status = MEMwrite (*data_list, sql_str);
      if (status != MEM_S_SUCCESS)
       {
         free (sql_str);
         MEMclose (attr_list);
         MEMclose (data_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Write Failed : status = <0x%.8x>\n",
		     status));
         return (NFM_E_MEM); 
       }

      free (sql_str);

      status = NFMload_set_members (user_id, 
               p_catno, p_itemno, p_type, c_catno,
               c_catoffset, c_itemoffset, c_typeoffset,
               cit_str, level, 1, type,
               cat_no, item_no, *attr_list, *data_list);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose (attr_list);
         MEMclose (data_list);
         _NFMdebug ((fname, "Load Child Level 0 : status = <0x%.8x>\n",
         status));
         return (status); 
       }

      _NFMdebug ((fname, "SUCCESSFUL\n")) ;
      return (NFM_S_SUCCESS); 
   }

 long NFMload_set_members (user_id, p_catno, p_itemno, p_type, c_catno,
                           c_catoffset, c_itemoffset, c_typeoffset,
                           cit_str, 
                           max_level, curr_level, type, 
                           cat_no, item_no,
                           attr_list, data_list)
   long    user_id;
   char    *p_catno, *p_itemno, *p_type, *c_catno;
   long    c_catoffset, c_itemoffset, c_typeoffset;
   char    *cit_str;
   long    max_level, curr_level, type;
   long    cat_no, item_no;
   MEMptr  attr_list, data_list;
   {
     static char *fname = "NFMload_set_members" ;
      long      status, atol ();
      char      *sql_str, value [50];
      MEMptr    list = NULL;
      char      **column,  **data;
      char      **column1, **data1;
      char      **data2;
      long      a, x, y, z, count, count1, count2;
      long      i, j, k, l;
      long      set_status, found;
      char      cat_name [100], co_status [10];
      char      item_name[NFM_ITEMNAME + 1],item_rev[NFM_ITEMREV +1] ;
      
      _NFMdebug ((fname, "Cat   Attr   = <%s> : Item Attr = <%s> : Type Attr = <%s> :  C Cat No = <%s> : Cat Offset = <%d> : Item Offset = <%d> : Type Offset = <%d> : Cit Str = <%s> : Max Level = <%d> : Curr Level = <%d> : Type = <%d> : Cat No = <%d> : Item No = <%d>\n",
		  p_catno, p_itemno, p_type, c_catno, c_catoffset,
		  c_itemoffset, c_typeoffset, cit_str, max_level,
		  curr_level, type, cat_no, item_no));

      if ((curr_level > max_level) && (max_level >= 0))
       {
         _NFMdebug ((fname, "CURR LVL %d > MAX LVL %d : status = <0x%.8x>\n",
		     curr_level, max_level, NFM_S_SUCCESS));
         return (NFM_S_SUCCESS);
       }

      sql_str = (char *) malloc (strlen (cit_str) + 2 * MEM_SIZE);
      if (! sql_str)
       {
         ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
         NFM_E_MALLOC));
         return (NFM_E_MALLOC);
       }
      sql_str [0] = 0;
      
      sprintf (sql_str,
      "%s %s %s %s %s %s = %d %s %s = %d %s (%s = 'S' OR %s = 'P') %s %s",
      "SELECT", cit_str, 
      "FROM", "NFMSETCIT", "WHERE",
      p_catno, cat_no, "AND", p_itemno, item_no, "AND",
      p_type, p_type, "ORDER BY", c_catno);

      status = SQLquery (sql_str, &list, MEM_SIZE);
      if ((status != SQL_S_SUCCESS) &&
          ((status) != SQL_I_NO_ROWS_FOUND))
       {
         free (sql_str);
         MEMclose (&list);
         ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
         _NFMdebug ((fname, "status = <0x%.8x>\n", status));
         return ( NFM_E_SQL_QUERY); 
       }

      free (sql_str);

      if (status == SQL_I_NO_ROWS_FOUND)
	{
         _NFMdebug ((fname, "NO CHILDREN"));
       }
      else
	{
	  column = (char **) attr_list -> column_ptr;
	  data   = (char **) attr_list -> data_ptr;

         a = -1; 

         for (y = 0; y < attr_list -> columns; ++y)
          {
                 if (! strcmp (column [y], "n_name"))       a = y;
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

         column1 = (char **) list -> column_ptr;
         data1   = (char **) list -> data_ptr;

         sql_str = (char *) malloc (512) ;
         if (! sql_str)
          {
            free (sql_str);
            MEMclose (&list);
         ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
            _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
            NFM_E_MALLOC));
            return (NFM_E_MALLOC);
          }
         sql_str [0] = 0;

         for (y = 0; y < list -> rows; ++y)
          {
            count1 = list -> columns * y;

            status = NFMget_catalog_name (user_id,
                     atol (data1 [count1 + c_catoffset]), cat_name);
            if (status != NFM_S_SUCCESS)
             {
               free (sql_str);
               MEMclose (&list);
               _NFMdebug ((fname, "Get Cat No : status = <0x%.8x>\n",
               status));
               return (status);
             }

            status = NFMget_item_name (user_id, cat_name,
                     atol (data1 [count1 + c_itemoffset]),
                     item_name, item_rev);
            if (status != NFM_S_SUCCESS)
             {
               free (sql_str);
               MEMclose (&list);
               _NFMdebug ((fname, "Get Item No : status = <0x%.8x>\n",
               status));
               return (status);
             }

            found = 0;

            if (type)
             {
               i = -1; j = -1; k = -1; l = -1;

               for (x = 0; x < attr_list -> rows; ++x)
                {
                  count = attr_list -> columns * x;

                  if (! strcmp (data [count + a], "n_catalogname"))
                     i = x;
                  else if (! strcmp (data [count + a], "n_itemname"))
                     j = x;
                  else if (! strcmp (data [count + a], "n_itemrev"))
                     k = x;
                  else if (! strcmp (data [count + a], "n_type"))
                     l = x;
                }

               status = MEMbuild_array (data_list);
               if (status != MEM_S_SUCCESS)
                {
                  free (sql_str);
                  MEMclose (&list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
                  _NFMdebug ((fname, "Build Array : status = <0x%.8x>\n",
			      status));
                  return (NFM_E_MEM);
                }

               data2 = (char **) data_list -> data_ptr;

               for (x = 0; (x < data_list -> rows) && (! found); ++x)
                {
                  count2 = data_list -> columns * x;

                  if ((! strcmp (data2 [count2 + i], cat_name))   &&
                      (! strcmp (data2 [count2 + j], item_name))  &&
                      (! strcmp (data2 [count2 + k], item_rev)))
                   {
                     found = 1;

                     if (! strcmp (data1 [count1 + c_typeoffset], "P"))
                      {
                        if (! strcmp (data2 [count2 + l],  "S"))
                         {
                           status = MEMwrite_data (data_list, "P",
                                    x + 1, l + 1);
                           if (status != MEM_S_SUCCESS)
                            {
                              free (sql_str);
                              MEMclose (&list);
			      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
                              _NFMdebug ((fname, "Wr Data : status = <0x%.8x>\n",
					  status));
                              return (NFM_E_MEM);
                            }
                         }
                      }
                   }
                }
             }

            if (! found)
             {
               status = NFMcheck_item_setindicator (user_id, 
                        cat_name, atol (data1 [count1 + c_itemoffset]));
               if (status != NFM_S_SUCCESS && status != NFM_E_SET &&
                   status != NFM_E_NOT_SET)
                {
                  free (sql_str);
                  MEMclose (&list);
                  _NFMdebug ((fname, "Chk Set Ind : status = <0x%.8x>\n",
                  status));
                  return (status);
                }

               set_status = status;
         
               status = NFMcheck_co_status (user_id, cat_name,
                        atol (data1 [count1 + c_itemoffset]), co_status);
               /*
               if ((status != NFM_S_SUCCESS)             &&
                   (status != NFM_E_NO_FILE)             &&
                   (status != NFM_E_ITEM_OUT)            && 
                   (status != NFM_E_ITEM_IN)             &&
                   (status != NFM_E_SET_OUT)             &&
                   (status != NFM_E_MEM_OUT)             && 
                   (status != NFM_E_SET_OUT_NO_FILE)     &&
                   (status != NFM_E_MEM_OUT_NO_FILE)     &&
                   (status != NFM_E_ITEM_IN_TRANS)       &&
                   (status != NFM_E_ITEM_OUT_TRANS)      &&
                   (status != NFM_E_NO_FILE_IN_TRANS)    &&
                   (status != NFM_E_NO_FILE_OUT_TRANS))
                {
                  free (sql_str);
                  MEMclose (&list);
                  _NFMdebug ((fname, "Chk Co Stat : status = <0x%.8x>\n",
                  status));
                  return (status); 
                }
              */

               sql_str [0] = 0;
 
               for (x = 0; x < attr_list -> rows; ++x)
                {
                   count = attr_list -> columns * x;

                   _NFMdebug ((fname, "attr column : <%s>\n", data [count + a]));

                   if (! strcmp (data [count + a], "n_catalogname"))
                     strcat (sql_str, cat_name);
                   else if (! strcmp (data [count + a], "n_itemname"))
                     strcat (sql_str, item_name);
                   else if (! strcmp (data [count + a], "n_itemrev"))
                     strcat (sql_str, item_rev);
                   else if (! strcmp (data [count + a], "n_level"))
                    {
                       sprintf (value, "%d", curr_level);
                       strcat (sql_str, value);
                    }
                   else if (! strcmp (data [count + a], "n_setindicator"))
                    {
                       if (set_status == NFM_E_SET)
                          strcat (sql_str, "Y");
                       else if (set_status == NFM_E_NOT_SET) 
                          strcat (sql_str, "N");
                    }
                   else if (! strcmp (data [count + a], "n_coout"))
                     strcat (sql_str, co_status);
                   else if (! strcmp (data [count + a], "n_status"));
                   else
                    {
                      found = 0;

                      for (z = 0; ((z < list -> columns) &&
                                   (! found)); ++z)   
                       {
                         _NFMdebug ((fname,"data column : <%s>\n", column1 [z]));

                         if (! strcmp (data [count + a], column1 [z]))
                          {
                             strcat (sql_str, data1 [count1 + z]);
                             found = 1;
                          }
                       }

                      if (! found)
                       {
                         free (sql_str);
                         MEMclose (&list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
                         _NFMdebug ((fname, "Buff Corrupt : status = <0x%.8x>\n",
				     status));
                         return (NFM_E_MEM);                   
                       }
                    }
 
                   strcat (sql_str, "\1");
                }

               status = MEMwrite (data_list, sql_str);
               if (status != MEM_S_SUCCESS)
                {
                  free (sql_str);
                  MEMclose (&list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
                  _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
			      status));
                  return (NFM_E_MEM);
                }

               if (set_status == NFM_E_SET)
                {
                  status = NFMload_set_members (user_id,
                           p_catno, p_itemno, p_type, c_catno,
                           c_catoffset, c_itemoffset, c_typeoffset,
                           cit_str,
                           max_level, curr_level + 1, type,
                           atol (data1 [count1 + c_catoffset]),
                           atol (data1 [count1 + c_itemoffset]), 
                           attr_list, data_list);
                  if (status != NFM_S_SUCCESS)
                   {
                     free (sql_str);
                     MEMclose (&list);
                     _NFMdebug ((fname, "Ld Mem : status = <0x%.8x>\n",
                     status));
                     return (status);
                   }
                }
               else
                  _NFMdebug ((fname, "ITEM NOT A SET\n"));
             }
          }

         free (sql_str);
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
    
 long NFMset_attributes (user_id, p_catno, p_itemno,
                         p_type, c_catno,
                         c_catoffset, c_itemoffset, c_typeoffset,
                         cit_str, 
                         attr_list, data_list)
   long     user_id;
   char     *p_catno, *p_itemno, *p_type, *c_catno;
   long     *c_catoffset, *c_itemoffset, *c_typeoffset;
   char     *cit_str;
   MEMptr   *attr_list, *data_list;
   {
      static char *fname = "NFMset_attributes" ;
      long     status;
      MEMptr   cit_attr = NULL;
      char     **column, **format, **data;
      long     a, x, y, count, insert, comma;
      char     *sql_str, *sql_str1, value [50];
      char     column_name  [50], data_type  [20];
      char     column_name1 [50], data_type1 [20];

      p_catno [0] = 0; p_itemno [0] = 0; 
      p_type [0] = 0;  c_catno [0] = 0;
      *c_catoffset = -1; *c_itemoffset = -1; *c_typeoffset = -1;
      cit_str [0] = 0;

      _NFMdebug ((fname, "Cat  No  = <%s> : Item No = <%s> : Type = <%s> : C Cat No = <%s> : Cat Off = <%d> : item Off = <%d> : Type Off = <%d> : Cit Str = <%s>\n", 
  p_catno, p_itemno, p_type, c_catno, *c_catoffset, *c_itemoffset,
  *c_typeoffset, cit_str));

      status = NFMquery_table_definition (user_id, 
               "NFMSYSTEM", "NFMSETCIT", &cit_attr);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose (&cit_attr);
         _NFMdebug ((fname, "Get Table Attr : status = <0x%.8x>\n", status));
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

      status = MEMopen (attr_list, MEM_SIZE);
      if (status != MEM_S_SUCCESS)
       {
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);
       }

      a = -1; 

      for (y = 0; y < cit_attr -> columns; ++y)
       {
              if (! strcmp (column [y], "n_name"))      a = y;

         status = MEMwrite_format (*attr_list, column [y], format [y]);
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (&cit_attr);
            MEMclose (attr_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            _NFMdebug ((fname, "MEM Wr For : status = <0x%.8x>\n", status));
            return (NFM_E_MEM);
          }
       }

      sql_str = (char *) malloc ((*attr_list) -> row_size);
      if (! sql_str)
       {
         MEMclose (&cit_attr);
         MEMclose (attr_list);
         ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC));
         return (NFM_E_MALLOC);
       }

      /*       add :: n_level integer   */

      sql_str [0] = 0;

      for (y = 0; y < cit_attr -> columns; ++y)
       {
         if (! strcmp (column [y], "n_name"))
          {
            strcat  (sql_str, "n_level");
            sprintf (column_name,   "%s", "n_level");
          }
         else if (! strcmp (column [y], "n_datatype"))
          {
            strcat  (sql_str, "integer");
            sprintf (data_type, "%s", "integer");
          }
         else if (! strcmp (column [y], "n_synonym"))
            strcat (sql_str, "Level");
         else if (! strcmp (column [y], "n_nfmname"))
            strcat (sql_str, "n_level");
         else if (! strcmp (column [y], "n_opentonfm"))
            strcat (sql_str, "Y");
         else if (! strcmp (column [y], "n_application"))
            strcat (sql_str, "NFM");
         else if (! strcmp (column [y], "n_read"))
            strcat (sql_str, "Y");
         else if (! strcmp (column [y], "n_write"))
            strcat (sql_str, "Y");
         else if (! strcmp (column [y], "n_update"))
            strcat (sql_str, "Y");
         else if (! strcmp (column [y], "n_delete"))
            strcat (sql_str, "N");
         else if (! strcmp (column [y], "n_null"))
            strcat (sql_str, "N");
         else if (! strcmp (column [y], "n_keyin"))
            strcat (sql_str, "0");
         else if (! strcmp (column [y], "n_checkin"))
            strcat (sql_str, "N");
         else if (! strcmp (column [y], "n_checkout"))
            strcat (sql_str, "N");
         else if (! strcmp (column [y], "n_seqno"))
          {
            sprintf (value, "%d", (*attr_list) -> rows);
            strcat (sql_str, value);
          }
         else if (! strcmp (column [y], "n_listno"))
            strcat (sql_str, "0");
          
         strcat (sql_str, "\1");
       }

      status = MEMwrite (*attr_list, sql_str);
      if (status != MEM_S_SUCCESS)
       {
         free (sql_str);
         MEMclose (&cit_attr);
         MEMclose (attr_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);
       }

      status = MEMopen (data_list, MEM_SIZE);
      if (status != MEM_S_SUCCESS)
       {
         free (sql_str);
         MEMclose (&cit_attr);
         MEMclose (attr_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);
       }

      status = MEMwrite_format (*data_list, column_name, data_type);
      if (status != MEM_S_SUCCESS)
       {
         free (sql_str);
         MEMclose (&cit_attr);
         MEMclose (attr_list);
         MEMclose (data_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Wr For : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);
       }

      sql_str1 = (char *) malloc ((*attr_list) -> row_size);
      if (! sql_str1)
       {
         free (sql_str);
         MEMclose (&cit_attr);
         MEMclose (attr_list);
         MEMclose (data_list);
         ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC));
         return (NFM_E_MALLOC);
       }

      for (x = 0; x < cit_attr -> rows; ++x)
       {
         count = cit_attr -> columns * x;

         sql_str      [0] = 0;    sql_str1   [0] = 0;

         column_name  [0] = 0;    data_type  [0] = 0;
         column_name1 [0] = 0;    data_type1 [0] = 0;

         insert = 1;

         if (! strcmp (data [count + a], "n_pcatalogno"))
           insert = 0;
         else if (! strcmp (data [count + a], "n_pitemno"))
           insert = 0;
         else if (! strcmp (data [count + a], "n_archiveno"))
           insert = 0;
         else if (! strcmp (data [count + a], "n_archiveflag"))
           insert = 0;
         else if (! strcmp (data [count + a], "n_ccatalogno"))
          {
            for (y = 0; y < cit_attr -> columns; ++y)
             {
               if (! strcmp (column [y], "n_name"))
                {
                  strcat (sql_str, "n_catalogname");
                  sprintf (column_name, "%s", "n_catalogname");
                }
               else if (! strcmp (column [y], "n_datatype"))
                {
                  strcat (sql_str, "char(20)");
                  sprintf (data_type, "%s", "char(20)");
                }
               else if (! strcmp (column [y], "n_synonym"))
                {
                  strcat (sql_str, "Catalog Name");
                }
               else if (! strcmp (column [y], "n_nfmname"))
                {
                  strcat (sql_str, "n_catalogname");
                }
               else
                {
                  strcat (sql_str, data [count + y]);
                }

               strcat (sql_str, "\1");
             }
          }
         else if (! strcmp (data [count + a], "n_citemno"))
          {
            insert = 2;

            for (y = 0; y < cit_attr -> columns; ++y)
             {
               if (! strcmp (column [y], "n_name"))
                {
                  strcat (sql_str,  "n_itemname");
                  strcat (sql_str1, "n_itemrev");

                  sprintf (column_name, "%s", "n_itemname");
                  sprintf (column_name1, "%s", "n_itemrev");
                }
               else if (! strcmp (column [y], "n_datatype"))
                {
                  status = NFMget_max_attr_size (user_id, "n_itemname", 
                           data_type);
                  if (status != NFM_S_SUCCESS)
                   {
                     free (sql_str);
                     free (sql_str1);
                     MEMclose (&cit_attr);
                     MEMclose (attr_list);
                     MEMclose (data_list);
                     _NFMdebug ((fname, "Max Size : status = <0x%.8x>\n",
                     status));
                     return (status);
                   }

                  strcat (sql_str, data_type);

                  status = NFMget_max_attr_size (user_id, "n_itemrev", 
                           data_type1);
                  if (status != NFM_S_SUCCESS)
                   {
                     free (sql_str);
                     free (sql_str1);
                     MEMclose (&cit_attr);
                     MEMclose (attr_list);
                     MEMclose (data_list);
                     _NFMdebug ((fname, "Max Size : status = <0x%.8x>\n",
                     status));
                     return (status);
                   }

                  strcat (sql_str1, data_type1);
                }
               else if (! strcmp (column [y], "n_nfmname"))
                {
                  strcat (sql_str,  "n_itemname");
                  strcat (sql_str1, "n_itemrev");
                }
               else if (! strcmp (column [y], "n_synonym"))
                {
                  strcat (sql_str,  "Item Name");
                  strcat (sql_str1, "Item Revision");
                }
               else
                {
                  strcat (sql_str,  data [count + y]);
                  strcat (sql_str1, data [count + y]);
                }

               strcat (sql_str,  "\1");
               strcat (sql_str1, "\1");
             }
          }
         else
          {
            for (y = 0; y < cit_attr -> columns; ++y)
             {
               if (! strcmp (column [y], "n_name"))
                {
                  strcat  (sql_str, data [count + y]);
                  sprintf (column_name, "%s", data [count + y]);
                }
               else if (! strcmp (column [y], "n_datatype"))
                {
                  strcat  (sql_str, data [count + y]);
                  sprintf (data_type, "%s", data [count + y]);
                }
               else 
                  strcat (sql_str, data [count + y]);
               strcat (sql_str, "\1");
             }
          }

         if (insert)
          {
            status = MEMwrite (*attr_list, sql_str);
            if (status != MEM_S_SUCCESS)
             {
               free (sql_str);
               free (sql_str1);
               MEMclose (&cit_attr);
               MEMclose (attr_list);
               MEMclose (data_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
			   status));
               return (NFM_E_MEM);
             }

            status = MEMwrite_format (*data_list, column_name, data_type);
            if (status != MEM_S_SUCCESS)
             {
               free (sql_str);
               free (sql_str1);
               MEMclose (&cit_attr);
               MEMclose (attr_list);
               MEMclose (data_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               _NFMdebug ((fname, "MEM Wr For : status = <0x%.8x>\n",
			   status));
               return (NFM_E_MEM);
             }
    
            if (insert == 2)
             {
               status = MEMwrite (*attr_list, sql_str1);
               if (status != MEM_S_SUCCESS)
                {
                  free (sql_str);
                  free (sql_str1);
                  MEMclose (&cit_attr);
                  MEMclose (attr_list);
                  MEMclose (data_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
                  _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
			      status));
                  return (NFM_E_MEM);
                }

               status = MEMwrite_format (*data_list,
                        column_name1, data_type1);
               if (status != MEM_S_SUCCESS)
                {
                  free (sql_str);
                  free (sql_str1);
                  MEMclose (&cit_attr);
                  MEMclose (attr_list);
                  MEMclose (data_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
                  _NFMdebug ((fname, "MEM Wr For : status = <0x%.8x>\n",
			      status));
                  return (NFM_E_MEM);
                }
             }
          }
       }

      free (sql_str1);

      /*       add :: n_setind char(1)   */

      sql_str [0] = 0;

      for (y = 0; y < cit_attr -> columns; ++y)
       {
         if (! strcmp (column [y], "n_name"))
          {
            strcat  (sql_str, "n_setindicator");
            sprintf (column_name, "%s", "n_setindicator");
          }
         else if (! strcmp (column [y], "n_datatype"))
          {
            strcat  (sql_str, "char(1)");
            sprintf (data_type, "%s", "char(1)");
          }
         else if (! strcmp (column [y], "n_synonym"))
            strcat (sql_str, "Set Flag");
         else if (! strcmp (column [y], "n_nfmname"))
            strcat (sql_str, "n_setindicator");
         else if (! strcmp (column [y], "n_opentonfm"))
            strcat (sql_str, "Y");
         else if (! strcmp (column [y], "n_application"))
            strcat (sql_str, "NFM");
         else if (! strcmp (column [y], "n_read"))
            strcat (sql_str, "N");
         else if (! strcmp (column [y], "n_write"))
            strcat (sql_str, "N");
         else if (! strcmp (column [y], "n_update"))
            strcat (sql_str, "N");
         else if (! strcmp (column [y], "n_delete"))
            strcat (sql_str, "N");
         else if (! strcmp (column [y], "n_null"))
            strcat (sql_str, "N");
         else if (! strcmp (column [y], "n_keyin"))
            strcat (sql_str, "0");
         else if (! strcmp (column [y], "n_checkin"))
            strcat (sql_str, "N");
         else if (! strcmp (column [y], "n_checkout"))
            strcat (sql_str, "N");
         else if (! strcmp (column [y], "n_seqno"))
          {
            sprintf (value, "%d", (*attr_list) -> rows);
            strcat (sql_str, value);
          }
         else if (! strcmp (column [y], "n_listno"))
            strcat (sql_str, "0");
          
         strcat (sql_str, "\1");
       }

      status = MEMwrite (*attr_list, sql_str);
      if (status != MEM_S_SUCCESS)
       {
         free (sql_str);
         MEMclose (&cit_attr);
         MEMclose (attr_list);
         MEMclose (data_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);
       }

      status = MEMwrite_format (*data_list, column_name, data_type);
      if (status != MEM_S_SUCCESS)
       {
         free (sql_str);
         MEMclose (&cit_attr);
         MEMclose (attr_list);
         MEMclose (data_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Wr For : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);
       }

      /*       add :: n_coout char(2)  */

      sql_str [0] = 0;

      for (y = 0; y < cit_attr -> columns; ++y)
       {
         if (! strcmp (column [y], "n_name"))
          {
            strcat  (sql_str, "n_coout");
            sprintf (column_name, "%s", "n_coout");
          }
         else if (! strcmp (column [y], "n_datatype"))
          {
            strcat  (sql_str, "char(2)");
            sprintf (data_type, "%s", "char(2)");
          }
         else if (! strcmp (column [y], "n_synonym"))
            strcat (sql_str, "CO Status");
         else if (! strcmp (column [y], "n_nfmname"))
            strcat (sql_str, "n_coout");
         else if (! strcmp (column [y], "n_opentonfm"))
            strcat (sql_str, "Y");
         else if (! strcmp (column [y], "n_application"))
            strcat (sql_str, "NFM");
         else if (! strcmp (column [y], "n_read"))
            strcat (sql_str, "N");
         else if (! strcmp (column [y], "n_write"))
            strcat (sql_str, "N");
         else if (! strcmp (column [y], "n_update"))
            strcat (sql_str, "N");
         else if (! strcmp (column [y], "n_delete"))
            strcat (sql_str, "N");
         else if (! strcmp (column [y], "n_null"))
            strcat (sql_str, "N");
         else if (! strcmp (column [y], "n_keyin"))
            strcat (sql_str, "0");
         else if (! strcmp (column [y], "n_checkin"))
            strcat (sql_str, "N");
         else if (! strcmp (column [y], "n_checkout"))
            strcat (sql_str, "N");
         else if (! strcmp (column [y], "n_seqno"))
          {
            sprintf (value, "%d", (*attr_list) -> rows);
            strcat (sql_str, value);
          }
         else if (! strcmp (column [y], "n_listno"))
            strcat (sql_str, "0");
          
         strcat (sql_str, "\1");
       }

      status = MEMwrite (*attr_list, sql_str);
      if (status != MEM_S_SUCCESS)
       {
         free (sql_str);
         MEMclose (&cit_attr);
         MEMclose (attr_list);
         MEMclose (data_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);
       }

      status = MEMwrite_format (*data_list, column_name, data_type);
      if (status != MEM_S_SUCCESS)
       {
         free (sql_str);
         MEMclose (&cit_attr);
         MEMclose (attr_list);
         MEMclose (data_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Wr For : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);
       }

      /*       add :: status char (10)   */

      sql_str [0] = 0;

      for (y = 0; y < cit_attr -> columns; ++y)
       {
         if (! strcmp (column [y], "n_name"))
          {
            strcat  (sql_str, "n_status");
            sprintf (column_name, "%s", "n_status");
          }
         else if (! strcmp (column [y], "n_datatype"))
          {
            strcat  (sql_str, "char(10)");
            sprintf (data_type, "%s", "char(10)");
          }
         else if (! strcmp (column [y], "n_synonym"))
            strcat (sql_str, "Status");
         else if (! strcmp (column [y], "n_nfmname"))
            strcat (sql_str, "n_status");
         else if (! strcmp (column [y], "n_opentonfm"))
            strcat (sql_str, "Y");
         else if (! strcmp (column [y], "n_application"))
            strcat (sql_str, "NFM");
         else if (! strcmp (column [y], "n_read"))
            strcat (sql_str, "N");
         else if (! strcmp (column [y], "n_write"))
            strcat (sql_str, "N");
         else if (! strcmp (column [y], "n_update"))
            strcat (sql_str, "N");
         else if (! strcmp (column [y], "n_delete"))
            strcat (sql_str, "N");
         else if (! strcmp (column [y], "n_null"))
            strcat (sql_str, "N");
         else if (! strcmp (column [y], "n_keyin"))
            strcat (sql_str, "0");
         else if (! strcmp (column [y], "n_checkin"))
            strcat (sql_str, "N");
         else if (! strcmp (column [y], "n_checkout"))
            strcat (sql_str, "N");
         else if (! strcmp (column [y], "n_seqno"))
          {
            sprintf (value, "%d", (*attr_list) -> rows);
            strcat (sql_str, value);
          }
         else if (! strcmp (column [y], "n_listno"))
            strcat (sql_str, "0");
          
         strcat (sql_str, "\1");
       }

      status = MEMwrite (*attr_list, sql_str);
      if (status != MEM_S_SUCCESS)
       {
         free (sql_str);
         MEMclose (&cit_attr);
         MEMclose (attr_list);
         MEMclose (data_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);
       }

      status = MEMwrite_format (*data_list, column_name, data_type);
      if (status != MEM_S_SUCCESS)
       {
         free (sql_str);
         MEMclose (&cit_attr);
         MEMclose (attr_list);
         MEMclose (data_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Wr For : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);
       }

      free (sql_str);

      comma  = 0; y = 0;

      for (x = 0; x < cit_attr -> rows; ++x)
       {
         count = cit_attr -> columns * x;

         if (! strcmp (data [count + a], "n_pcatalogno"))
            sprintf (p_catno, "%s", data [count + a]);
         else if (! strcmp (data [count + a], "n_pitemno"))
            sprintf (p_itemno, "%s", data [count + a]);
         else if ((! strcmp (data [count + a], "n_archiveno"))    ||
                  (! strcmp (data [count + a], "n_archiveflag")));
         else
          {
             if (comma)  strcat (cit_str, ", ");
             comma = 1;

             if (! strcmp (data [count + a], "n_ccatalogno"))
              {
                sprintf (c_catno, "%s", data [count + a]);
                *c_catoffset = y;
              }
             else if (! strcmp (data [count + a], "n_citemno"))
                *c_itemoffset = y;
             else if (! strcmp (data [count + a], "n_type"))
              {
                sprintf (p_type, "%s", data [count + a]);
                *c_typeoffset = y;
              }

             strcat (cit_str, data [count + a]);

             y = y + 1;
          }
       }

      status = MEMclose (&cit_attr);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
         MEMclose (data_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);
       }

      _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
      return (NFM_S_SUCCESS); 
   }


 long NFMqry_set_members (user_id, cat_name, item_name, item_rev,
                            attr_list, data_list)
   long     user_id;
   char     *cat_name;
   char     *item_name, *item_rev;
   MEMptr   *attr_list, *data_list;
   {
     static char *fname = "NFMqry_set_members";
      long     status;
      long     cat_no, item_no;
      int      lock_off ;
      int      cat_off, item_off, item_rev_off, type_off, set_off, coout_off;
      char     set_ind [5] ;
      char     sql_str [512];
      /* char     co_status [10], type [5], lock [5] ; */
      char     co_status [10], lock [5] ;
      char     **column, **data;
      /* long     c, x, y, count; */
      long     y;
      MEMptr   return_buffer = NULL ;
      long     _NFMset_buffer ();
      long     _NFMload_set_mem_short (), atol () ;

      _NFMdebug ((fname, "Cat   Name = <%s> : Item Name = <%s> : Item Rev = <%s>\n", 
		  cat_name, item_name, item_rev));

      status = NFMget_catalog_no (user_id, cat_name, &cat_no);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Get Cat No : status = <0x%.8x>\n", status));
         return (status); 
       }

     sprintf (sql_str, "Select %s, %s, %s, %s FROM %s WHERE %s = '%s' AND %s = '%s'",
	      "n_itemno", "n_setindicator", "n_coout",
	      "n_itemlock", cat_name, 
	      "n_itemname", item_name, "n_itemrev", item_rev) ;

     status = SQLquery (sql_str, &return_buffer, MEM_SIZE) ;
     if (status != SQL_S_SUCCESS)
       {
	 MEMclose (&return_buffer) ;
	 if (status == SQL_I_NO_ROWS_FOUND)
	   {
	     _NFMdebug ((fname, "Bad Item %s : %s : %s\n",
			 cat_name, item_name, item_rev));
	     ERRload_struct (NFM, NFM_E_BAD_ITEM, "", NULL) ;
	     return (NFM_E_BAD_ITEM) ;
	   }
	 _NFMdebug ((fname, "SQL query Failed : status = <0x%.8x>\n",
		     status));
	 ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL) ;
	 return (NFM_E_SQL_QUERY) ;
       }

     status = MEMbuild_array (return_buffer) ;
     if (status != MEM_S_SUCCESS)
       {
	 MEMclose (&return_buffer) ;
	 ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
	 _NFMdebug ((fname, "MEMbuild_array (return_buffer) : status = <0x%.8x>\n",
		     status));
	 return (NFM_E_MEM) ;
       }

     data = (char **) return_buffer -> data_ptr ;

     item_no = atol (data [0]) ;
     strcpy (set_ind, data [1]) ;
     strcpy (co_status, data [2]) ;
     strcpy (lock, data [3]) ;

     status = MEMclose (&return_buffer) ;
     if (status != MEM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "MEMclose (return_buffer) : status = <0x%.8x>\n",
		     status)) ;
	 ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
	 return (NFM_E_MEM) ;
       }
     
     if (strcmp (set_ind, "Y") != 0)
       {
	 ERRload_struct (NFM, NFM_E_NOT_SET, "", NULL) ;
	 _NFMdebug ((fname, "Item not a set\n")) ;
	 return (NFM_E_NOT_SET) ;
       }

      status = _NFMset_buffer (user_id, attr_list, data_list);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose (attr_list);
         MEMclose (data_list);
         _NFMdebug ((fname, "Query Set Attr Def : status = <0x%.8x>\n",
         status));
         return (status); 
       }

     status = MEMbuild_array (*data_list) ;
     if (status != MEM_S_SUCCESS)
       {
          ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
          MEMclose (data_list) ;
	  MEMclose (attr_list);
	  _NFMdebug ((fname, "MEMbuild_array (*data_list)\n", status));
          return (NFM_E_MEM) ;
        }

      column = (char **) (*data_list) -> column_ptr ;

      for (y=0; y< (*data_list)->columns; y++)
        {
          if (strcmp (column [y], "n_catalogname") == 0) cat_off = y ;
          else if (strcmp (column [y], "n_itemname") ==0) item_off = y ;
          else if (strcmp (column [y], "n_itemrev") ==0)  item_rev_off = y;
          else if (strcmp (column [y], "n_type") == 0)    type_off = y ;
	  else if (strcmp (column [y], "n_setindicator") == 0)set_off = y ;
	  else if (strcmp (column [y], "n_coout") == 0)   coout_off = y ;
	  else if (strcmp (column [y], "n_itemlock") == 0)    lock_off = y ;
        }

     sql_str [0] = 0 ;
     for (y =0; y <(*data_list)->columns ; y++)
       {
	 if (y==cat_off)
	   strcat (sql_str, cat_name);
	 else if (y==item_off)
	   strcat (sql_str, item_name) ;
	 else if (y==item_rev_off)
	   strcat (sql_str, item_rev) ;
	 else if (y==type_off)
	   strcat (sql_str, "P") ;
	 else if (y==set_off)
	   strcat (sql_str, "Y") ;
	 else if (y==coout_off)
	   strcat (sql_str, co_status) ;
	 else if (y==lock_off)
	   strcat (sql_str, lock) ;
	 strcat (sql_str, "\1") ;
       }
     
     _NFMdebug ((fname, "Cat Name (%d) = <%s> : Item Name (%d) = <%s> : Item Rev (%d) = <%s> : Type (%d)= <%s> : Set Ind (%d) = <%s> : Co Flag (%d) = <%s> : Lock Flag (%d) : <%s>\n",
		 cat_off, cat_name, item_off, item_name, item_rev_off,
		 item_rev, type_off, "P", set_off, "Y", coout_off, co_status,
		 lock_off, lock));

     status = MEMwrite (*data_list, sql_str);
     if (status != MEM_S_SUCCESS)
	{
	  ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Write Failed : status = <0x%.8x>\n",
		     status));
	  return (NFM_E_MEM); 
       }

      status = _NFMload_set_mem_short (user_id, cat_no, item_no, 
				       *attr_list, *data_list);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose (attr_list);
         MEMclose (data_list);
         _NFMdebug ((fname, "Load Child Level 0 : status = <0x%.8x>\n",
         status));
         return (status); 
       }

     if ((*data_list)->rows == 1)
       {
	 _NFMdebug ((fname, "No items in set %s : %s : %s\n",
		     cat_name, item_name, item_rev));
	 ERRload_struct (NFM, NFM_E_NO_ITEMS_FOUND, "", NULL) ;
	 return (NFM_E_NO_ITEMS_FOUND) ;
       }

      _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
      NFM_S_SUCCESS));
      return (NFM_S_SUCCESS); 
   }

long _NFMset_buffer (user_id, attr_list, data_list)
     long user_id ;
     MEMptr *attr_list ;    /* Output */
     MEMptr *data_list ;    /* Output */
{
  static char *fname = "_NFMset_buffer" ;
  long status ;
  char sql_str [512] ;
  int  x,y, count, a,b ;
  char **data, **column ;

  status = NFMi_template (attr_list);
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Template Failed :  status =  <0x%.8x> \n", status));
      return (status);
    }

  for (x = 0; x < 7; ++x)
    {
      sql_str [0] = 0;
      
      switch (x)
	{
          case 0 : 
           sprintf (sql_str,
       "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%s\1%s\1%d\1%d\1",
          "n_catalogname", "char(20)", "Catalog Name", "n_catalogname",
          "Y", "NFM", "Y", "N", "N", "N", "N", -1, "N", "N", x, 0);
          break;

          case 1 : 
           sprintf (sql_str,
       "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%s\1%s\1%d\1%d\1",
          "n_itemname", "char(60)", "Item Name", "n_itemname",
          "Y", "NFM", "Y", "N", "N", "N", "N", -1, "N", "N", x, 0);
          break;

          case 2 : 
           sprintf (sql_str,
       "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%s\1%s\1%d\1%d\1",
          "n_itemrev", "char(60)", "Item Rev", "n_itemrev",
          "Y", "NFM", "Y", "N", "N", "N", "N", -1, "N", "N", x, 0);
          break;

          case 3 : 
           sprintf (sql_str,
       "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%s\1%s\1%d\1%d\1",
          "n_type", "char(2)", "Type (P,S)", "n_type",
          "Y", "NFM", "Y", "N", "N", "N", "N", -1, "N", "N", x, 0);
          break;

          case 4 : 
           sprintf (sql_str,
       "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%s\1%s\1%d\1%d\1",
          "n_setindicator", "char(1)", "Set", "n_setindicator",
          "Y", "NFM", "Y", "N", "N", "N", "N", -1, "N", "N", x, 0);
          break;

          case 5 : 
           sprintf (sql_str,
       "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%s\1%s\1%d\1%d\1",
          "n_coout", "char(1)", "Co Flag", "n_coout",
          "Y", "NFM", "Y", "N", "N", "N", "N", -1, "N", "N", x, 0);
          break;

          case 6 : 
           sprintf (sql_str,
       "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%s\1%s\1%d\1%d\1",
          "n_itemlock", "char(1)", "Item Lock", "n_itemlock",
          "Y", "NFM", "Y", "N", "N", "N", "N", -1, "N", "N", x, 0);
          break;

         }

        status = MEMwrite (*attr_list, sql_str);
        if (status != MEM_S_SUCCESS)
         {
           _NFMdebug ((fname, "MEM Write : status =  <0x%.8x> \n", status));
	   ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
           return (NFM_E_MEM);
         }
       }

      status = MEMbuild_array (*attr_list);
      if (status != MEM_S_SUCCESS)
       {
	 ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
         _NFMdebug ((fname, "MEM Build Array : status =  <0x%.8x> \n",
         status));
         return (NFM_E_MEM);         
       }

      data   = (char **) (*attr_list) -> data_ptr;
      column = (char **) (*attr_list) -> column_ptr;

      for (y = 0; y < (*attr_list) -> columns; ++y)
       {
              if (! strcmp (column [y], "n_name"))      a = y;
         else if (! strcmp (column [y], "n_datatype"))  b = y;
       }

      status = MEMopen (data_list, 2 * MEM_SIZE);
      if (status != MEM_S_SUCCESS)
       {
         _NFMdebug ((fname, "MEM Open : status =  <0x%.8x> \n", status));
	 ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
         return (NFM_E_MEM);         
       }

      sql_str [0] = 0;

      for (x = 0; x < (*attr_list) -> rows; ++x)
       {
          count = (*attr_list) -> columns * x;

          status = MEMwrite_format (*data_list,
                   data [count + a], data [count + b]);
          if (status != MEM_S_SUCCESS)
           {
              _NFMdebug ((fname, "MEM Wr Format : status =  <0x%.8x> \n",
              status));
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
              return (NFM_E_MEM);
           }

       }

  _NFMdebug ((fname, "SUCCESSFUL\n"));
  return (NFM_S_SUCCESS) ;
}


 long _NFMload_set_mem_short (user_id, p_catno, p_itemno, 
			      attr_list, data_list)
   long    user_id;
   long    p_catno, p_itemno ;
   MEMptr  attr_list, data_list;
   {
     long      status, atol (), prev_cat_no ;
     /* char      sql_str [512], value [50]; */
     char      sql_str [512];
     MEMptr    list = NULL;
     char      **column,  **data, **data1 ;
     int       y, x ;
     int       count, cat_off, item_off, item_rev_off, set_off, coout_off ;
     int       type_off, lock_off ;
     char      cat_name [100], co_status [10], type [5], lock[5] ;
     char      *set_buffer, tmp_str [20] ;
     char      item_name [NFM_ITEMNAME+1], item_rev[NFM_ITEMREV+1];
     MEMptr    return_buffer = NULL ;
     static char *fname = "_NFMload_set_mem_short" ;

      sprintf (sql_str,
      "SELECT  %s FROM NFMSETCIT \
WHERE  n_pcatalogno = %d AND n_pitemno = %d AND (n_type = 'S' OR n_type = 'P') \
ORDER BY n_ccatalogno",
      "n_ccatalogno, n_citemno, n_type",
      p_catno, p_itemno) ;

      status = SQLquery (sql_str, &list, MEM_SIZE);
      if ((status != SQL_S_SUCCESS) &&
          ((status) != SQL_I_NO_ROWS_FOUND))
       {
         MEMclose (&list);
         ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
         _NFMdebug ((fname, "status = <0x%.8x>\n", status));
         return ( NFM_E_SQL_QUERY); 
       }

      if (status == SQL_I_NO_ROWS_FOUND)
	{
	  MEMclose (&list) ;
         _NFMdebug ((fname, "NO CHILDREN\n"));
	 return (NFM_S_SUCCESS) ;
       }

     set_buffer = (char *) malloc (list->rows) ;
     if (set_buffer == NULL) 
       {
	 _NFMdebug ((fname, "MALLOC failed\n"));
	 ERRload_struct (NFM, NFM_E_MALLOC, "", NULL) ;
	 return (NFM_E_MALLOC) ;
       }

     memset (set_buffer, NULL, list->rows) ;

     status = MEMbuild_array (data_list) ;
     if (status != MEM_S_SUCCESS)
       {
	 free (set_buffer);
	 _NFMdebug ((fname, "MEMbuild_array (data_list) Failed : status = <0x%.8x>\n",
		     status));
	 ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
	 MEMclose (&list) ;
	 return (NFM_E_MEM) ;
       }

     column = (char **) data_list -> column_ptr ;

     for (y=0; y< data_list->columns; y++)
       {
	 if (strcmp (column [y], "n_catalogname") == 0) cat_off = y ;
	 else if (strcmp (column [y], "n_itemname") ==0) item_off = y ;
	 else if (strcmp (column [y], "n_itemrev") ==0)  item_rev_off = y;
	 else if (strcmp (column [y], "n_type") == 0)    type_off = y ;
	 else if (strcmp (column [y], "n_setindicator") == 0) set_off = y;
	 else if (strcmp (column [y], "n_coout") == 0) coout_off = y ;
	 else if (strcmp (column [y], "n_itemlock") == 0) lock_off = y ;
       }

     status = MEMbuild_array (list);
     if (status != MEM_S_SUCCESS)
       {
	 free (set_buffer) ;
	 MEMclose (&list);
	 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	 _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		     status));
	 return (NFM_E_MEM);
       }
     

     data = (char **) list-> data_ptr ;

     prev_cat_no = 0 ;
     
     for (y = 0; y < list -> rows; ++y)
       {
	 count = list -> columns * y;
	 if (prev_cat_no != atol (data [count]))
	   {
	     status = NFMget_catalog_name (user_id,
					   atol (data [count]), 
					   cat_name);
	     if (status != NFM_S_SUCCESS)
	       {
		 free (set_buffer);
		 MEMclose (&list);
		 _NFMdebug ((fname, "Get Cat No : status = <0x%.8x>\n",
			     status));
		 return (status);
	       }
	     prev_cat_no = atol (data [count]) ;
	   }

	 strcpy (type, data [count +2]) ;
	 
	 sprintf (sql_str, "Select %s, %s, %s, %s, %s FROM %s WHERE %s = %s",
		  "n_itemname",  "n_itemrev", "n_setindicator", "n_coout",
		  "n_itemlock", cat_name, 
		  "n_itemno", data [count+1]) ;
	 
	 status = SQLquery (sql_str, &return_buffer, MEM_SIZE) ;
	 if (status != SQL_S_SUCCESS)
	   {
	     MEMclose (&return_buffer) ;
	     if (status == SQL_I_NO_ROWS_FOUND)
	       {
		 _NFMdebug ((fname, "Bad Item %s : %s : %s\n",
			     cat_name, item_name, item_rev));
		 ERRload_struct (NFM, NFM_E_BAD_ITEM, "", NULL) ;
		 return (NFM_E_BAD_ITEM) ;
	       }
	     _NFMdebug ((fname, "SQL query Failed : status = <0x%.8x>\n",
			 status));
	     ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL) ;
	     return (NFM_E_SQL_QUERY) ;
	   }
	 
	 status = MEMbuild_array (return_buffer) ;
	 if (status != MEM_S_SUCCESS)
	   {
	     MEMclose (&return_buffer) ;
	     ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
	     _NFMdebug ((fname, "MEMbuild_array (return_buffer) : status = <0x%.8x>\n",
			 status));
	     return (NFM_E_MEM) ;
	   }

	 data1 = (char **) return_buffer -> data_ptr ;
	 
	 strcpy (item_name, data1 [0]);
	 strcpy (item_rev, data1 [1]) ;
	 if (strcmp (data1 [3], "Y") == 0)
	   set_buffer [y] = 'Y' ;
	 else
	   set_buffer [y] = 'N' ;
	 strcpy (co_status, data1 [3]) ;
	 strcpy (lock, data1 [4]) ;
	 
	 status = MEMclose (&return_buffer) ;
	 if (status != MEM_S_SUCCESS)
	   {
	     _NFMdebug ((fname, "MEMclose (return_buffer) : status = <0x%.8x>\n",
			 status)) ;
	     ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
	     return (NFM_E_MEM) ;
	   }
	 
	 sql_str [0] = 0 ;
	 
	 for (x =0; x <data_list->columns ; x++)
	   {
	     if (x==cat_off)
	       strcat (sql_str, cat_name);
	     else if (x==item_off)
	       strcat (sql_str, item_name) ;
	     else if (x==item_rev_off)
	       strcat (sql_str, item_rev) ;
	     else if (x==type_off)
	       strcat (sql_str, type) ;
	     else if (x==set_off)
	       {
		 sprintf (tmp_str, "%c", set_buffer[y]) ;
		 strcat (sql_str, tmp_str) ;
	       }
	     else if (x==coout_off)
	       strcat (sql_str, co_status);
	     else if (x==lock_off)
	       strcat (sql_str, lock) ;
	     strcat (sql_str, "\1") ;
	   }

     _NFMdebug ((fname, "Cat Name (%d) = <%s> : Item Name (%d) = <%s> : Item Rev (%d) = <%s> : Type (%d)= <%s> : Set Ind (%d) = <%s> : Co Flag (%d) = <%s> : Lock Flag (%d) = <%s>\n",
		 cat_off, cat_name, item_off, item_name, item_rev_off,
		 item_rev, type_off, "P", set_off, "Y", coout_off, co_status,
		 lock_off, lock));
	 
	 status = MEMwrite (data_list, sql_str);
	 if (status != MEM_S_SUCCESS)
	   {
	     MEMclose (&list) ;
	     free (set_buffer);
	     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	     _NFMdebug ((fname, "MEM Write Failed : status = <0x%.8x>\n",
			 status));
	     return (NFM_E_MEM); 
	   }
       }

     for (y= 0; y<list->rows; y++)
       {
	 count = y*list->columns ;
	 if (set_buffer [y] == 'Y')
	   {
	     status = _NFMload_set_mem_short (user_id,
					     atol(data [count]), 
					     atol (data [count+1]),
					     attr_list, data_list);
	     if (status != NFM_S_SUCCESS)
	       {
		 free(set_buffer) ;
		 MEMclose (&list);
		 _NFMdebug ((fname, "Ld Mem : status = <0x%.8x>\n",
			     status));
		 return (status);
	       }
	   }
       }


     free (set_buffer);

     status = MEMclose (&list);
      if (status != MEM_S_SUCCESS)
	{
	  ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	  _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n",
		     status));
	  return (NFM_E_MEM);
	}

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS) ;
   }


