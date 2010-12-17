#include "machine.h"
#include "CMDTOOLS.h"
#include "WFstruct.h"

 extern struct WFstruct WFinfo;
 extern struct NFMglobal_st NFMglobal ;
 char message [512];

 long NFMquery_item_attributes (user_id, cat_name, item_name, item_rev, 
                                attr_list, data_list, value_list)
   long     user_id;
   char     *cat_name, *item_name, *item_rev;
   MEMptr   *attr_list, *data_list, *value_list;
   {
     static char *fname = "NFMquery_item_attributes" ;
     long      status;
     MEMptr    attr_list1 = NULL, attr_list2 = NULL;
     MEMptr    data_list1 = NULL, data_list2 = NULL;
     char      **column, **data;
     char      **column1, **data1;
     char      **column2, **data2;
     char      *sql_str, sql_str1 [1024];
     char      file_cat [100], value [50], attr [50];
     long      a, b, x, y, z, i, m, count, count1, found, c,d ;
     long      item_no;
     char     user_name [50];
     char     acl_no [50], sa_no [50];
     char     date [50] ;
     long     no_buffers ;
     MEMptr   list = NULL ;
     long     _NFMget_cat_acl_list ();
     long     _NFMget_cat_sa_list ();
     long     _NFMget_proj_acl_list ();
     long     _NFMget_proj_sa_list ();
     long     _NFMget_acl_for_item () ;
     long      _NFMget_internal_sa_list_for_item () ;

     _NFMdebug ((fname, "Cat  Name = <%s> : Item Name = <%s> : Item Rev <%s>\n", 
		 cat_name, item_name, item_rev)) ;
     user_id = user_id ;
     status = NFMget_item_no (NFMglobal.NFMuserid, cat_name,
              item_name, item_rev, &item_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Item No : status = <0x%.8x>\n", status));
        return (status);          
      }

     status = _NFMquery_catalog_attributes (cat_name, 
					    attr_list, data_list, value_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);

        _NFMdebug ((fname, "Query Cat Attr : status = <0x%.8x>\n", status));
        return (status);          
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

     status = NFMsplit_catalog_definition (NFMglobal.NFMuserid,
					   *attr_list, &attr_list1, 
					   &attr_list2);
     if (status != NFM_S_SUCCESS)
       {
	 MEMclose (attr_list);
	 MEMclose (value_list);
	 
	 MEMclose (&attr_list1);
	 MEMclose (&attr_list2);
	 _NFMdebug ((fname, "Split Cat Def : status = <0x%.8x>\n", status));
	 return (status);         
       }

     status = MEMbuild_array (attr_list1);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (value_list);

        MEMclose (&attr_list1);
        MEMclose (&attr_list2);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status)) ;
        return (NFM_E_MEM);        
      }

     column = (char **) attr_list1 -> column_ptr;
     data   = (char **) attr_list1 -> data_ptr;

     a = -1; b = -1; 

     for (y = 0; y < attr_list1 -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))      a = y;
        else if (! strcmp (column [y], "n_datatype"))  b = y;
      }

     sql_str = (char *) malloc (2 * MEM_SIZE + attr_list1 -> rows * 50);
     if (! sql_str)
      {
        MEMclose (attr_list);
        MEMclose (value_list);

        MEMclose (&attr_list1);
        MEMclose (&attr_list2);
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC));
        return (NFM_E_MALLOC);           
      }
     sql_str [0] = 0;

     sprintf (sql_str,  "SELECT ");
     sprintf (sql_str1, " FROM %s WHERE ", cat_name);

     sprintf (value, "%d", item_no);

     for (x = 0; x < attr_list1 -> rows; ++x)
      {
        count = attr_list1 -> columns * x;

        if (x) strcat (sql_str, ", ");
	
        strcat (sql_str, data [count + a]);
	
        if (! strcmp (data [count + a], "n_itemno"))
         {
           strcat (sql_str1, data [count + a]);
           strcat (sql_str1, " = ");

           if (! strncmp (data [count + b], "char", 4))
            {
              strcat (sql_str1, "'");
              strcat (sql_str1, value);
              strcat (sql_str1, "'");
            }
           else
              strcat (sql_str1, value);
         }
      }

     strcat (sql_str, sql_str1);

     status = SQLquery (sql_str, &data_list1, MEM_SIZE);
     if (status != SQL_S_SUCCESS)
      {
        free (sql_str);
        MEMclose (attr_list);
        MEMclose (value_list);

        MEMclose (&attr_list1);
        MEMclose (&attr_list2);

        MEMclose (&data_list1);

        if ((status) == SQL_I_NO_ROWS_FOUND)
         {
        ERRload_struct (NFM, NFM_E_ITEM_NOT_IN_CAT, "", NULL);
           _NFMdebug ((fname, "No Such Cat Entry : status = <0x%.8x>\n",
           NFM_E_ITEM_NOT_IN_CAT));
           return (NFM_E_ITEM_NOT_IN_CAT);           
         }

        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Query Failed : status = <0x%.8x>\n", 
		    status));
        return ( NFM_E_SQL_QUERY);
      }

     free (sql_str);

     status = MEMbuild_array (attr_list2);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (value_list);

        MEMclose (&attr_list1);
        MEMclose (&attr_list2);

        MEMclose (&data_list1);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);        
      }

     sql_str = (char *) malloc (2 * MEM_SIZE + attr_list2 -> rows * 50);
     if (! sql_str)
      {
        MEMclose (attr_list);
        MEMclose (value_list);

        MEMclose (&attr_list1);
        MEMclose (&attr_list2);

        MEMclose (&data_list1);
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC));
        return (NFM_E_MALLOC);           
      }
     sql_str [0] = 0;
     
     column = (char **) attr_list2 -> column_ptr;
     data   = (char **) attr_list2 -> data_ptr;
     
     sprintf (sql_str,  "SELECT ");
     sprintf (sql_str1, " WHERE ");
     sprintf (value, "%d", item_no);

     i = -1;

     for (x = 0; x < attr_list2 -> rows; ++x)
      {
        count = attr_list2 -> columns * x;

        if (x) strcat (sql_str, ", ");

        strcat (sql_str, data [count + a]);

        if (! strcmp (data [count + a], "n_itemnum"))
         {
           strcat (sql_str1, data [count + a]);
           strcat (sql_str1, " = ");

           if (! strncmp (data [count + b], "char", 4))
            {
              strcat (sql_str1, "'");
              strcat (sql_str1, value);
              strcat (sql_str1, "'");
            }
           else
              strcat (sql_str1, value);
         }
        else if (! strcmp (data [count + a], "n_fileversion"))
           i = x;
      }

     if (i < 0)
      {
        free (sql_str);

        MEMclose (attr_list);
        MEMclose (value_list);

        MEMclose (&attr_list1);
        MEMclose (&attr_list2);

        MEMclose (&data_list1);
        ERRload_struct (NFM, NFM_E_CORRUPTED_FILE_CAT, "", NULL);
        _NFMdebug ((fname, "File Cat Is Corrupted : status = <0x%.8x>\n",
        NFM_E_CORRUPTED_FILE_CAT));
        return (NFM_E_CORRUPTED_FILE_CAT);           
      }

     sprintf (file_cat, "f_%s", cat_name);

     sprintf (attr, "max(%s)", data [(attr_list2 -> columns * i) + a]);

     status = NFMget_attr_value (NFMglobal.NFMuserid, file_cat, 
              attr, sql_str1, value);
     if (status != NFM_S_SUCCESS)
      {
        free (sql_str);
        MEMclose (attr_list);
        MEMclose (value_list);

        MEMclose (&attr_list1);
        MEMclose (&attr_list2);

        MEMclose (&data_list1);
        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
        status));
        return (status);
      }

     strcat (sql_str1, " AND ");
     strcat (sql_str1, data [(attr_list2 -> columns * i) + a]);
     strcat (sql_str1, " = ");

     if (! strncmp (data [(attr_list2 -> columns * i) + b], "char", 4))
      {
        strcat (sql_str1, "'");
        strcat (sql_str1, value); 
        strcat (sql_str1, "'");
      }
     else
        strcat (sql_str1, value);

     strcat (sql_str, " FROM ");
     strcat (sql_str, file_cat);
     strcat (sql_str, sql_str1);
     strcat (sql_str, " order by n_filenum") ;
 
     status = SQLquery (sql_str, &data_list2, MEM_SIZE);
     if ((status != SQL_S_SUCCESS) && 
         ((status) != SQL_I_NO_ROWS_FOUND))
      {
        free (sql_str);
        MEMclose (attr_list);
        MEMclose (value_list);

        MEMclose (&attr_list1);
        MEMclose (&attr_list2);

        MEMclose (&data_list1);
        MEMclose (&data_list2);
        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Query Failed : status = <0x%.8x>\n",
		    status));
        return ( NFM_E_SQL_QUERY);
      }

     free (sql_str);

     status = MEMopen (data_list, 2 * MEM_SIZE);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (value_list);
	
        MEMclose (&attr_list1);
        MEMclose (&attr_list2);

        MEMclose (&data_list1);
        MEMclose (&data_list2);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);          
      }

     column = (char **) (*attr_list) -> column_ptr;
     data   = (char **) (*attr_list) -> data_ptr;

     for (x = 0; x < (*attr_list) -> rows; ++x)
      {
        count = (*attr_list) -> columns * x;

        status = MEMwrite_format (*data_list,
                 data [count + a], data [count + b]);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);

           MEMclose (&attr_list1);
           MEMclose (&attr_list2);

           MEMclose (&data_list1);
           MEMclose (&data_list2);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);          
         }
      }

     status = MEMbuild_array (data_list1);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);

        MEMclose (&attr_list1);
        MEMclose (&attr_list2);

        MEMclose (&data_list1);
        MEMclose (&data_list2);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);          
      }

     status = MEMbuild_array (data_list2);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);

        MEMclose (&attr_list1);
        MEMclose (&attr_list2);

        MEMclose (&data_list1);
        MEMclose (&data_list2);

        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);          
      }

     column  = (char **) (*attr_list) -> column_ptr;
     data    = (char **) (*attr_list) -> data_ptr;

     column1 = (char **) data_list1 -> column_ptr;
     data1   = (char **) data_list1 -> data_ptr;

     column2 = (char **) data_list2 -> column_ptr;
     data2   = (char **) data_list2 -> data_ptr;

     sql_str = (char *) malloc ((*data_list) -> row_size);
     if (! sql_str)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);

        MEMclose (&attr_list1);
        MEMclose (&attr_list2);

        MEMclose (&data_list1);
        MEMclose (&data_list2);

        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC));
        return (NFM_E_MALLOC);          
      }

     if (data_list1 -> rows > data_list2 -> rows)
          m = data_list1 -> rows;
     else
          m = data_list2 -> rows;

     for (z = 0; z < m; ++z)
      {
        sql_str [0] = 0;

        for (x = 0; x < (*attr_list) -> rows; ++x)
         {
           count = (*attr_list) -> columns * x;

/*           _NFMdebug ((fname, "Column = <%s>\n", data [count  + a])); */

           found = 0;

           for (y = 0; (y < data_list1 -> columns) && (! found); ++y)
            {
              if (! strcmp (data [count + a], column1 [y]))
               {
/*                 _NFMdebug ((fname, "Column Match = <%s>\n",
                           column1 [y]));
 */
                 if (z < data_list1 -> rows)
                  {
                    count1 = data_list1 -> columns * z;
                    strcat (sql_str, data1 [count1 + y]);
                  }

                 strcat (sql_str, "\1");
                 found = 1;
               }
            }

           for (y = 0; (y < data_list2 -> columns) && (! found); ++y)
            {
              if (! strcmp (data [count + a], column2 [y]))
		{
	  /*                 _NFMdebug ((fname, "Column Match = <%s>\n",
                           column2 [y]));
 */

                 if (z < data_list2 -> rows)
                  {
                    count1 = data_list2 -> columns * z;
                    strcat (sql_str, data2 [count1 + y]);
                  }

                 strcat (sql_str, "\1");
                 found = 1;
               }
            }

           if (! found)
            {
              free (sql_str);
	      
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (value_list);

              MEMclose (&attr_list1);
              MEMclose (&attr_list2);

              MEMclose (&data_list1);
              MEMclose (&data_list2);

        ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL);
              _NFMdebug ((fname, "Corrupted Buffers : status = <0x%.8x>\n",
              NFM_E_CORRUPTED_BUFFERS));
              return (NFM_E_CORRUPTED_BUFFERS);          
            }
         }

        status = MEMwrite (*data_list, sql_str);
        if (status != MEM_S_SUCCESS)
         {
           free (sql_str);

           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);

           MEMclose (&attr_list1);
           MEMclose (&attr_list2);

           MEMclose (&data_list1);
           MEMclose (&data_list2);

        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
           return (NFM_E_MEM);          
         }
      }

     free (sql_str);
   
     status = MEMclose (&attr_list1);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);

        MEMclose (&attr_list2);

        MEMclose (&data_list1);
        MEMclose (&data_list2);

        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     status = MEMclose (&attr_list2);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);

        MEMclose (&data_list1);
        MEMclose (&data_list2);

        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     status = MEMclose (&data_list1);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);

        MEMclose (&data_list2);

        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     status = MEMclose (&data_list2);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     strcpy (user_name, NFMglobal.NFMusername) ;
     status = NFMget_datetime (date) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Ris time stamp failed : status = <0x%x.8>\n",
		     status)) ;
	 return (status) ;
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

     status = MEMbuild_array (*data_list);
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

     c = -1; d = -1;

     for (y = 0; y < (*attr_list) -> columns; ++y)
      {
              if (! strcmp (column [y], "n_name"))      c = y;
         else if (! strcmp (column [y], "n_valueno"))       d = y;
      }

     status = _NFMget_acl_for_item (cat_name, item_name, item_rev,
				    &list) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Failure : get acl for item : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }

/*******
     status = WFget_active_proj_no (&proj_no) ;
     if (proj_no  > 0)
      {
      status = _NFMget_proj_acl_list (NFMglobal.NFMuserno, 
                                      WFinfo.catalog_no, 
                                      proj_no, &list);
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (&list);
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);
           _NFMdebug ((fname, "Proj Acl List : status = <0x%.8x>\n",
           status));
           return (status);          
         }
      }
     else
      {
        status = _NFMget_cat_acl_list (NFMglobal.NFMuserno, WFinfo.catalog_no, &list);
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (&list);
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);
           _NFMdebug ((fname, "Cat Acl List : status = <0x%.8x>\n",
           status));
           return (status);          
         }
      }
******************************************/
     if (list -> rows < 1)
      {
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
	ERRload_struct (NFM, NFM_E_NO_ACLS_FOUND, "", "") ;
	_NFMdebug ((fname, "Failure : No Acls Available for this item\n")) ;
	return (NFM_E_NO_ACLS_FOUND) ;
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

     MEMno_buffers (*value_list, &no_buffers );
     sprintf (acl_no, "%d", no_buffers );

     status = _NFMget_internal_sa_list_for_item (cat_name, item_name, 
						 item_rev, &list) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Failure : internal sa list for item\n",
		     status)) ;
	 return (status) ;
       }

/***************
     if (proj_no > 0)
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
        status = _NFMget_cat_sa_list (WFinfo.catalog_no, &list);
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
***************************************/
     if (list -> rows < 1)
      {
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_NO_ST_AREAS, "", "") ;
	_NFMdebug ((fname, "No storagearea available for item\n")) ;
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
     MEMno_buffers (*value_list, &no_buffers );
     sprintf (sa_no, "%d", no_buffers );

     for (x = 0; x < (*attr_list) -> rows; ++x)
      {
        count = (*attr_list) -> columns * x;
         
        if (! strcmp (data [count + c], "n_itemlock"))
         {
           status = MEMwrite_data (*data_list, "N", 1, x + 1);
           if (status != MEM_S_SUCCESS)
            {
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (value_list);         
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			  status));
              return (NFM_E_MEM);          
            }
         }
        else if (! strcmp (data [count + c], "n_creator"))
         {
           status = MEMwrite_data (*data_list, user_name, 1, x + 1);
           if (status != MEM_S_SUCCESS)
            {
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (value_list);         
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			  status));
              return (NFM_E_MEM);          
            }
         }
        else if (! strcmp (data [count + c], "n_creationdate"))
         {
           status = MEMwrite_data (*data_list, date, 1, x + 1);
           if (status != MEM_S_SUCCESS)
            {
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (value_list);         
              _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
              status));
              return (status);          
            }
         }
        else if (! strcmp (data [count + c], "n_aclno"))
         {
           status = MEMwrite_data (*attr_list, acl_no, x + 1, d + 1);
           if (status != MEM_S_SUCCESS)
            {
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (value_list);         
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			  status));
              return (NFM_E_MEM);          
            }
         }
        else if (! strcmp (data [count + c], "n_cisano"))
         {
           status = MEMwrite_data (*attr_list, sa_no, x + 1, d + 1);
           if (status != MEM_S_SUCCESS)
            {
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (value_list);         
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			  status));
              return (NFM_E_MEM);          
            }
         }
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

/*** value/advice list will have only updatable attributes ***/
 long NFMquery_item_attributes_u (user_id, cat_name, item_name, item_rev, 
                                attr_list, data_list, value_list)
   long     user_id;
   char     *cat_name, *item_name, *item_rev;
   MEMptr   *attr_list, *data_list, *value_list;
   {
     static char *fname = "NFMquery_item_attributes_u" ;
     long      status;
     MEMptr    attr_list1 = NULL, attr_list2 = NULL;
     MEMptr    data_list1 = NULL, data_list2 = NULL;
     char      **column, **data;
     char      **column1, **data1;
     char      **column2, **data2;
     char      *sql_str, sql_str1 [1024];
     char      file_cat [100], value [50], attr [50];
     long      a, b, x, y, z, i, m, count, count1, found, c,d ;
     long      item_no;
     char     user_name [50];
     char     acl_no [50], sa_no [50];
     char     date [50] ;
     long     no_buffers ;
     MEMptr   list = NULL ;
     long     _NFMget_cat_acl_list ();
     long     _NFMget_cat_sa_list ();
     long     _NFMget_proj_acl_list ();
     long     _NFMget_proj_sa_list ();
     long     _NFMget_acl_for_item () ;
     long      _NFMget_internal_sa_list_for_item () ;

     _NFMdebug ((fname, "Cat  Name = <%s> : Item Name = <%s> : Item Rev <%s>\n", 
		 cat_name, item_name, item_rev)) ;
     user_id = user_id ;
     status = NFMget_item_no (NFMglobal.NFMuserid, cat_name,
              item_name, item_rev, &item_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Item No : status = <0x%.8x>\n", status));
        return (status);          
      }

     status = _NFMquery_catalog_attributes_u (cat_name, 
					    attr_list, data_list, value_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);

        _NFMdebug ((fname, "Query Cat Attr : status = <0x%.8x>\n", status));
        return (status);          
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

     status = NFMsplit_catalog_definition (NFMglobal.NFMuserid,
					   *attr_list, &attr_list1, 
					   &attr_list2);
     if (status != NFM_S_SUCCESS)
       {
	 MEMclose (attr_list);
	 MEMclose (value_list);
	 
	 MEMclose (&attr_list1);
	 MEMclose (&attr_list2);
	 _NFMdebug ((fname, "Split Cat Def : status = <0x%.8x>\n", status));
	 return (status);         
       }

     status = MEMbuild_array (attr_list1);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (value_list);

        MEMclose (&attr_list1);
        MEMclose (&attr_list2);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status)) ;
        return (NFM_E_MEM);        
      }

     column = (char **) attr_list1 -> column_ptr;
     data   = (char **) attr_list1 -> data_ptr;

     a = -1; b = -1; 

     for (y = 0; y < attr_list1 -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))      a = y;
        else if (! strcmp (column [y], "n_datatype"))  b = y;
      }

     sql_str = (char *) malloc (2 * MEM_SIZE + attr_list1 -> rows * 50);
     if (! sql_str)
      {
        MEMclose (attr_list);
        MEMclose (value_list);

        MEMclose (&attr_list1);
        MEMclose (&attr_list2);
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC));
        return (NFM_E_MALLOC);           
      }
     sql_str [0] = 0;

     sprintf (sql_str,  "SELECT ");
     sprintf (sql_str1, " FROM %s WHERE ", cat_name);

     sprintf (value, "%d", item_no);

     for (x = 0; x < attr_list1 -> rows; ++x)
      {
        count = attr_list1 -> columns * x;

        if (x) strcat (sql_str, ", ");
	
        strcat (sql_str, data [count + a]);
	
        if (! strcmp (data [count + a], "n_itemno"))
         {
           strcat (sql_str1, data [count + a]);
           strcat (sql_str1, " = ");

           if (! strncmp (data [count + b], "char", 4))
            {
              strcat (sql_str1, "'");
              strcat (sql_str1, value);
              strcat (sql_str1, "'");
            }
           else
              strcat (sql_str1, value);
         }
      }

     strcat (sql_str, sql_str1);

     status = SQLquery (sql_str, &data_list1, MEM_SIZE);
     if (status != SQL_S_SUCCESS)
      {
        free (sql_str);
        MEMclose (attr_list);
        MEMclose (value_list);

        MEMclose (&attr_list1);
        MEMclose (&attr_list2);

        MEMclose (&data_list1);

        if ((status) == SQL_I_NO_ROWS_FOUND)
         {
        ERRload_struct (NFM, NFM_E_ITEM_NOT_IN_CAT, "", NULL);
           _NFMdebug ((fname, "No Such Cat Entry : status = <0x%.8x>\n",
           NFM_E_ITEM_NOT_IN_CAT));
           return (NFM_E_ITEM_NOT_IN_CAT);           
         }

        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Query Failed : status = <0x%.8x>\n", 
		    status));
        return ( NFM_E_SQL_QUERY);
      }

     free (sql_str);

     status = MEMbuild_array (attr_list2);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (value_list);

        MEMclose (&attr_list1);
        MEMclose (&attr_list2);

        MEMclose (&data_list1);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);        
      }

     sql_str = (char *) malloc (2 * MEM_SIZE + attr_list2 -> rows * 50);
     if (! sql_str)
      {
        MEMclose (attr_list);
        MEMclose (value_list);

        MEMclose (&attr_list1);
        MEMclose (&attr_list2);

        MEMclose (&data_list1);
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC));
        return (NFM_E_MALLOC);           
      }
     sql_str [0] = 0;
     
     column = (char **) attr_list2 -> column_ptr;
     data   = (char **) attr_list2 -> data_ptr;
     
     sprintf (sql_str,  "SELECT ");
     sprintf (sql_str1, " WHERE ");
     sprintf (value, "%d", item_no);

     i = -1;

     for (x = 0; x < attr_list2 -> rows; ++x)
      {
        count = attr_list2 -> columns * x;

        if (x) strcat (sql_str, ", ");

        strcat (sql_str, data [count + a]);

        if (! strcmp (data [count + a], "n_itemnum"))
         {
           strcat (sql_str1, data [count + a]);
           strcat (sql_str1, " = ");

           if (! strncmp (data [count + b], "char", 4))
            {
              strcat (sql_str1, "'");
              strcat (sql_str1, value);
              strcat (sql_str1, "'");
            }
           else
              strcat (sql_str1, value);
         }
        else if (! strcmp (data [count + a], "n_fileversion"))
           i = x;
      }

     if (i < 0)
      {
        free (sql_str);

        MEMclose (attr_list);
        MEMclose (value_list);

        MEMclose (&attr_list1);
        MEMclose (&attr_list2);

        MEMclose (&data_list1);
        ERRload_struct (NFM, NFM_E_CORRUPTED_FILE_CAT, "", NULL);
        _NFMdebug ((fname, "File Cat Is Corrupted : status = <0x%.8x>\n",
        NFM_E_CORRUPTED_FILE_CAT));
        return (NFM_E_CORRUPTED_FILE_CAT);           
      }

     sprintf (file_cat, "f_%s", cat_name);

     sprintf (attr, "max(%s)", data [(attr_list2 -> columns * i) + a]);

     status = NFMget_attr_value (NFMglobal.NFMuserid, file_cat, 
              attr, sql_str1, value);
     if (status != NFM_S_SUCCESS)
      {
        free (sql_str);
        MEMclose (attr_list);
        MEMclose (value_list);

        MEMclose (&attr_list1);
        MEMclose (&attr_list2);

        MEMclose (&data_list1);
        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
        status));
        return (status);
      }

     strcat (sql_str1, " AND ");
     strcat (sql_str1, data [(attr_list2 -> columns * i) + a]);
     strcat (sql_str1, " = ");

     if (! strncmp (data [(attr_list2 -> columns * i) + b], "char", 4))
      {
        strcat (sql_str1, "'");
        strcat (sql_str1, value); 
        strcat (sql_str1, "'");
      }
     else
        strcat (sql_str1, value);

     strcat (sql_str, " FROM ");
     strcat (sql_str, file_cat);
     strcat (sql_str, sql_str1);
 
     status = SQLquery (sql_str, &data_list2, MEM_SIZE);
     if ((status != SQL_S_SUCCESS) && 
         ((status) != SQL_I_NO_ROWS_FOUND))
      {
        free (sql_str);
        MEMclose (attr_list);
        MEMclose (value_list);

        MEMclose (&attr_list1);
        MEMclose (&attr_list2);

        MEMclose (&data_list1);
        MEMclose (&data_list2);
        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Query Failed : status = <0x%.8x>\n",
		    status));
        return ( NFM_E_SQL_QUERY);
      }

     free (sql_str);

     status = MEMopen (data_list, 2 * MEM_SIZE);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (value_list);
	
        MEMclose (&attr_list1);
        MEMclose (&attr_list2);

        MEMclose (&data_list1);
        MEMclose (&data_list2);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);          
      }

     column = (char **) (*attr_list) -> column_ptr;
     data   = (char **) (*attr_list) -> data_ptr;

     for (x = 0; x < (*attr_list) -> rows; ++x)
      {
        count = (*attr_list) -> columns * x;

        status = MEMwrite_format (*data_list,
                 data [count + a], data [count + b]);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);

           MEMclose (&attr_list1);
           MEMclose (&attr_list2);

           MEMclose (&data_list1);
           MEMclose (&data_list2);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);          
         }
      }

     status = MEMbuild_array (data_list1);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);

        MEMclose (&attr_list1);
        MEMclose (&attr_list2);

        MEMclose (&data_list1);
        MEMclose (&data_list2);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);          
      }

     status = MEMbuild_array (data_list2);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);

        MEMclose (&attr_list1);
        MEMclose (&attr_list2);

        MEMclose (&data_list1);
        MEMclose (&data_list2);

        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);          
      }

     column  = (char **) (*attr_list) -> column_ptr;
     data    = (char **) (*attr_list) -> data_ptr;

     column1 = (char **) data_list1 -> column_ptr;
     data1   = (char **) data_list1 -> data_ptr;

     column2 = (char **) data_list2 -> column_ptr;
     data2   = (char **) data_list2 -> data_ptr;

     sql_str = (char *) malloc ((*data_list) -> row_size);
     if (! sql_str)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);

        MEMclose (&attr_list1);
        MEMclose (&attr_list2);

        MEMclose (&data_list1);
        MEMclose (&data_list2);

        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC));
        return (NFM_E_MALLOC);          
      }

     if (data_list1 -> rows > data_list2 -> rows)
          m = data_list1 -> rows;
     else
          m = data_list2 -> rows;

     for (z = 0; z < m; ++z)
      {
        sql_str [0] = 0;

        for (x = 0; x < (*attr_list) -> rows; ++x)
         {
           count = (*attr_list) -> columns * x;

/*           _NFMdebug ((fname, "Column = <%s>\n", data [count  + a])); */

           found = 0;

           for (y = 0; (y < data_list1 -> columns) && (! found); ++y)
            {
              if (! strcmp (data [count + a], column1 [y]))
               {
/*                 _NFMdebug ((fname, "Column Match = <%s>\n",
                           column1 [y]));
 */
                 if (z < data_list1 -> rows)
                  {
                    count1 = data_list1 -> columns * z;
                    strcat (sql_str, data1 [count1 + y]);
                  }

                 strcat (sql_str, "\1");
                 found = 1;
               }
            }

           for (y = 0; (y < data_list2 -> columns) && (! found); ++y)
            {
              if (! strcmp (data [count + a], column2 [y]))
		{
	  /*                 _NFMdebug ((fname, "Column Match = <%s>\n",
                           column2 [y]));
 */

                 if (z < data_list2 -> rows)
                  {
                    count1 = data_list2 -> columns * z;
                    strcat (sql_str, data2 [count1 + y]);
                  }

                 strcat (sql_str, "\1");
                 found = 1;
               }
            }

           if (! found)
            {
              free (sql_str);
	      
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (value_list);

              MEMclose (&attr_list1);
              MEMclose (&attr_list2);

              MEMclose (&data_list1);
              MEMclose (&data_list2);

        ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL);
              _NFMdebug ((fname, "Corrupted Buffers : status = <0x%.8x>\n",
              NFM_E_CORRUPTED_BUFFERS));
              return (NFM_E_CORRUPTED_BUFFERS);          
            }
         }

        status = MEMwrite (*data_list, sql_str);
        if (status != MEM_S_SUCCESS)
         {
           free (sql_str);

           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);

           MEMclose (&attr_list1);
           MEMclose (&attr_list2);

           MEMclose (&data_list1);
           MEMclose (&data_list2);

        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
           return (NFM_E_MEM);          
         }
      }

     free (sql_str);
   
     status = MEMclose (&attr_list1);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);

        MEMclose (&attr_list2);

        MEMclose (&data_list1);
        MEMclose (&data_list2);

        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     status = MEMclose (&attr_list2);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);

        MEMclose (&data_list1);
        MEMclose (&data_list2);

        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     status = MEMclose (&data_list1);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);

        MEMclose (&data_list2);

        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     status = MEMclose (&data_list2);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     strcpy (user_name, NFMglobal.NFMusername) ;
     status = NFMget_datetime (date) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Ris time stamp failed : status = <0x%x.8>\n",
		     status)) ;
	 return (status) ;
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

     status = MEMbuild_array (*data_list);
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

     c = -1; d = -1;

     for (y = 0; y < (*attr_list) -> columns; ++y)
      {
              if (! strcmp (column [y], "n_name"))      c = y;
         else if (! strcmp (column [y], "n_valueno"))       d = y;
      }

     status = _NFMget_acl_for_item (cat_name, item_name, item_rev,
				    &list) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Failure : get acl for item : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }
/***************
     status = WFget_active_proj_no (&proj_no) ;
     if (proj_no  > 0)
      {
        status = _NFMget_proj_acl_list (NFMglobal.NFMuserno, WFinfo.catalog_no, 
					proj_no, &list);
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (&list);
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);
           _NFMdebug ((fname, "Proj Acl List : status = <0x%.8x>\n",
           status));
           return (status);          
         }
      }
     else
      {
        status = _NFMget_cat_acl_list (NFMglobal.NFMuserno, WFinfo.catalog_no, &list);
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (&list);
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);
           _NFMdebug ((fname, "Cat Acl List : status = <0x%.8x>\n",
           status));
           return (status);          
         }
      }
***************************************/
     if (list -> rows < 1)
      {
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_CATALOG_ACCESS, "", NULL);
        _NFMdebug ((fname, "Bad User Add Item In Cat : status = <0x%.8x>\n",
        NFM_E_CATALOG_ACCESS));
        return (NFM_E_CATALOG_ACCESS);          
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

     MEMno_buffers (*value_list, &no_buffers );
     sprintf (acl_no, "%d", no_buffers );

     status = _NFMget_internal_sa_list_for_item (cat_name, item_name, 
						 item_rev, &list) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Failure : internal sa list for item\n",
		     status)) ;
	 return (status) ;
       }
/************************
     if (proj_no > 0)
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
        status = _NFMget_cat_sa_list (WFinfo.catalog_no, &list);
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
**************************************/
     if (list -> rows < 1)
      {
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        ERRload_struct (NFM, NFM_E_CATALOG_ACCESS, "", NULL);
        _NFMdebug ((fname, "User Can't Add Item In Cat : status = <0x%.8x>\n",
        NFM_E_CATALOG_ACCESS));
        return (NFM_E_CATALOG_ACCESS);          
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
     MEMno_buffers (*value_list, &no_buffers );
     sprintf (sa_no, "%d", no_buffers );

     for (x = 0; x < (*attr_list) -> rows; ++x)
      {
        count = (*attr_list) -> columns * x;
         
        if (! strcmp (data [count + c], "n_itemlock"))
         {
           status = MEMwrite_data (*data_list, "N", 1, x + 1);
           if (status != MEM_S_SUCCESS)
            {
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (value_list);         
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			  status));
              return (NFM_E_MEM);          
            }
         }
        else if (! strcmp (data [count + c], "n_creator"))
         {
           status = MEMwrite_data (*data_list, user_name, 1, x + 1);
           if (status != MEM_S_SUCCESS)
            {
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (value_list);         
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			  status));
              return (NFM_E_MEM);          
            }
         }
        else if (! strcmp (data [count + c], "n_creationdate"))
         {
           status = MEMwrite_data (*data_list, date, 1, x + 1);
           if (status != MEM_S_SUCCESS)
            {
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (value_list);         
              _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
              status));
              return (status);          
            }
         }
        else if (! strcmp (data [count + c], "n_aclno"))
         {
           status = MEMwrite_data (*attr_list, acl_no, x + 1, d + 1);
           if (status != MEM_S_SUCCESS)
            {
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (value_list);         
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			  status));
              return (NFM_E_MEM);          
            }
         }
        else if (! strcmp (data [count + c], "n_cisano"))
         {
           status = MEMwrite_data (*attr_list, sa_no, x + 1, d + 1);
           if (status != MEM_S_SUCCESS)
            {
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (value_list);         
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			  status));
              return (NFM_E_MEM);          
            }
         }
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }


 long NFMget_cat_acl_list (user_id, cat_name, list)
   long    user_id;
   char    *cat_name;
   MEMptr  *list;
   {
     static char *fname = "NFMget_cat_acl_list" ;
     long    status, atol ();
     MEMptr  list1 = NULL, list2 = NULL;
     char    sql_str [2048], sql_str1 [2048];
     long    cat_no, x, y, z, count, count1, found;
     char    **column, **format, **data, **data1;
     
     _NFMdebug ((fname, "Cat  Name = <%s>\n", cat_name));
     user_id = user_id ;
     status = NFMget_transition_acl_list (NFMglobal.NFMuserid, &list1);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (&list1);
        _NFMdebug ((fname, "Get Trans Acl List : status = <0x%.8x>\n",
        status));
        return (status);
      }

     status = NFMget_catalog_no (NFMglobal.NFMuserid, cat_name, &cat_no);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (&list1);
        _NFMdebug ((fname, "Get Attr Info : status = <0x%.8x>\n",
        status));
        return (status);
      }

     sprintf (sql_str1,
     "SELECT %s.%s, %s.%s, %s.%s FROM %s, %s, %s ",
     "NFMACLS", "n_aclno", "NFMWORKFLOW", "n_workflowname", "NFMACLS", "n_aclname",
     "NFMCATALOGACLMAP", "NFMACLS", "NFMWORKFLOW");

     sprintf (sql_str,
	      "%s WHERE %s.%s = %d AND %s.%s = %s.%s AND %s.%s = %s.%s",
	      sql_str1, "NFMCATALOGACLMAP", "n_catalogno", cat_no,
	      "NFMACLS", "n_aclno", "NFMCATALOGACLMAP", "n_aclno", 
	      "NFMWORKFLOW", "n_workflowno", "NFMACLS", "n_workflowno");

     status = SQLquery (sql_str, &list2, MEM_SIZE);
     if ((status != SQL_S_SUCCESS) &&
         ((status) != SQL_I_NO_ROWS_FOUND))
      {
        MEMclose (&list1);
        MEMclose (&list2);
        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
		    status));
        return ( NFM_E_SQL_QUERY);
      }

     if ((status) == SQL_I_NO_ROWS_FOUND)
      {
        status = MEMsplit_copy_buffer (list1, list, 0);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (&list1);
           MEMclose (&list2);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Copy : status = <0x%.8x>\n",status));
           return (NFM_E_MEM);
         }
      }
     else
      {
        status = MEMbuild_array (list1);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (&list1);
           MEMclose (&list2);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);
         }

        column = (char **) list1 -> column_ptr;
        format = (char **) list1 -> format_ptr;
        data   = (char **) list1 -> data_ptr;

        status = MEMopen (list, MEM_SIZE);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (&list1);
           MEMclose (&list2);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);
         }

        for (y = 0; y < list1 -> columns; ++y)
         {
           status = MEMwrite_format (*list, column [y], format [y]);
           if (status != MEM_S_SUCCESS)
            {
              MEMclose (&list1);
              MEMclose (&list2);
              MEMclose (list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _NFMdebug ((fname, "MEM Wr For : status = <0x%.8x>\n",
			  status));
              return (NFM_E_MEM);
            }
         }

        status = MEMbuild_array (list2);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (&list1);
           MEMclose (&list2);
           MEMclose (list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);
         }

        data1 = (char **) list2 -> data_ptr;

        for (x = 0; x < list2 -> rows; ++x)
         {
           count = list2 -> columns * x;
     
           found = 0;

           for (y = 0; (y < list1 -> rows) && (! found); ++y)
            {
              count1 = list1 -> columns * y; 
 
              if (! strcmp (data1 [count], data [count1]))
               {
                 sql_str [0] = 0;
   
                 for (z = 0; z < list2 -> columns; ++z)
                  {
                    strcat (sql_str, data1 [count + z]);
                    strcat (sql_str, "\1");
                  }

                 found = 1;
 
                 status = MEMwrite (*list, sql_str);
                 if (status != MEM_S_SUCCESS)
                  {
                    MEMclose (&list1);
                    MEMclose (&list2);
                    MEMclose (list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
                    _NFMdebug ((fname, "MEM Wr : status = <0x%.8x>\n",
				status));
                    return (NFM_E_MEM);
                  }
               }
            }
         }
      }

     status = MEMclose (&list1);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list2);
        MEMclose (list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     status = MEMclose (&list2);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMget_proj_acl_list (user_id, cat_name, list)
   long    user_id;
   char    *cat_name;
   MEMptr  *list;
   {
     static char *fname = "NFMget_proj_acl_list" ;
     long    status, atol ();
     MEMptr  list1 = NULL, list2 = NULL;
     char    sql_str [2048], sql_str1 [2048];
     long    cat_no, x, y, z, count, count1, found;
     char    **column, **format, **data, **data1;

     _NFMdebug ((fname, "Cat  Name = <%s>\n", cat_name));
     user_id = user_id ;
     status = NFMget_transition_acl_list (NFMglobal.NFMuserid, &list1);
     if (status != NFM_S_SUCCESS)
       {
	 MEMclose (&list1);
	 _NFMdebug ((fname, "Get Trans Acl List : status = <0x%.8x>\n",
        status));
        return (status);
      }

     status = NFMget_catalog_no (NFMglobal.NFMuserid, cat_name, &cat_no);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (&list1);
        _NFMdebug ((fname, "Get Attr Info : status = <0x%.8x>\n",
        status));
        return (status);
      }

     sprintf (sql_str1,
	      "%s %s.%s, %s.%s, %s.%s %s %s WHERE %s.%s = %d AND %s.%s = %s.%s",
	      "SELECT", "NFMACLS", "n_aclno", 
	      "NFMWORKFLOW", "n_workflowname", 
	      "NFMACLS", "n_aclname",
	      "FROM",
	      "NFMPROJECTACLMAP, NFMCATALOGACLMAP, NFMACLS, NFMWORKFLOW",
	      "NFMPROJECTACLMAP", "n_projectno",  WFinfo.proj_no,
	      "NFMCATALOGACLMAP", "n_mapno", "NFMPROJECTACLMAP", "n_mapno");
     
     sprintf (sql_str,
	      "%s AND %s.%s = %d AND %s.%s = %s.%s AND %s.%s = %s.%s",
	      sql_str1, "NFMCATALOGACLMAP", "n_catalogno", cat_no,
	      "NFMACLS", "n_aclno", "NFMCATALOGACLMAP", "n_aclno", 
	      "NFMWORKFLOW", "n_workflowno", "NFMACLS", "n_workflowno");
     
     status = SQLquery (sql_str, &list2, MEM_SIZE);
     if (status != SQL_S_SUCCESS)
      {
        MEMclose (&list1);
        MEMclose (&list2);
      
        if ((status) == SQL_I_NO_ROWS_FOUND)
         {
        ERRload_struct (NFM, NFM_E_NO_PROJ_CAT_ACL_MAP, "", NULL);
           _NFMdebug ((fname, "Proj Cat Acl Map : status = <0x%.8x>\n",
           NFM_E_NO_PROJ_CAT_ACL_MAP));
           return (NFM_E_NO_PROJ_CAT_ACL_MAP);
         }

        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
		    status));
        return ( NFM_E_SQL_QUERY);
      }

     status = MEMbuild_array (list1);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list1);
        MEMclose (&list2);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }
     
     column = (char **) list1 -> column_ptr;
     format = (char **) list1 -> format_ptr;
     data   = (char **) list1 -> data_ptr;

     status = MEMopen (list, MEM_SIZE);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list1);
        MEMclose (&list2);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     for (y = 0; y < list1 -> columns; ++y)
      {
        status = MEMwrite_format (*list, column [y], format [y]);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (&list1);
           MEMclose (&list2);
           MEMclose (list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Wr For : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);
         }
      }

     status = MEMbuild_array (list2);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list1);
        MEMclose (&list2);
        MEMclose (list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     data1 = (char **) list2 -> data_ptr;

     for (x = 0; x < list2 -> rows; ++x)
      {
        count = list2 -> columns * x;
  
        found = 0;

        for (y = 0; (y < list1 -> rows) && (! found); ++y)
         {
           count1 = list1 -> columns * y;

           if (! strcmp (data1 [count], data [count1]))
            {
              sql_str [0] = 0;
   
              for (z = 0; z < list2 -> columns; ++z)
		{
		  strcat (sql_str, data1 [count + z]);
                 strcat (sql_str, "\1");
               }

              found = 1;

              status = MEMwrite (*list, sql_str);
              if (status != MEM_S_SUCCESS)
               {
                 MEMclose (&list1);
                 MEMclose (&list2);
                 MEMclose (list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
                 _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
			     status));
                 return (NFM_E_MEM);
               }
            }
         }
      }
 
     status = MEMclose (&list1);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list2);
        MEMclose (list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     status = MEMclose (&list2);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }
 
 long NFMget_cat_sa_list (user_id, cat_name, list)
   long    user_id;
   char    *cat_name;
   MEMptr  *list;
   {
     static char *fname = "NFMget_cat_sa_list" ;
     long    status, atol ();
     char    sql_str [2048], value [50];
     long    cat_no;
     
     _NFMdebug ((fname, "Cat  Name = <%s>\n", cat_name));
     user_id = user_id ;
     status = NFMget_catalog_no (NFMglobal.NFMuserid, cat_name, &cat_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Attr Info : status = <0x%.8x>\n",
        status));
        return (status);
      }

     sprintf (sql_str,
	      "%s %s.%s, %s.%s FROM %s, %s WHERE %s.%s = %d AND %s.%s = %s.%s",
	      "SELECT",
	      "NFMSTORAGEAREA", "n_sano", "NFMSTORAGEAREA", "n_saname",
	      "NFMSTORAGEAREA", "NFMCATALOGSAMAP", 
	      "NFMCATALOGSAMAP", "n_catalogno", cat_no,
	      "NFMSTORAGEAREA", "n_sano", "NFMCATALOGSAMAP", "n_sano");
     
     status = SQLquery (sql_str, list, MEM_SIZE);
     if ((status != SQL_S_SUCCESS) && 
         ((status) != SQL_I_NO_ROWS_FOUND))
      {
        MEMclose (list);
        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
		    status));
        return ( NFM_E_SQL_QUERY);
      }

     if ((status ) == SQL_I_NO_ROWS_FOUND)
      {
        status = MEMclose (list);
        if (status != MEM_S_SUCCESS)
	  {
	    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
           return (NFM_E_MEM);
         }

	sprintf (value, "'T'");

	sprintf (sql_str,
		 "SELECT %s, %s FROM %s WHERE %s > 3 AND %s != %s",
		 "n_sano", "n_saname", "NFMSTORAGEAREA",
		 "n_sano", "n_type", value);

        status = SQLquery (sql_str, list, MEM_SIZE);
        if (status != SQL_S_SUCCESS)
         {
           MEMclose (list);

           if ((status) == SQL_I_NO_ROWS_FOUND)
            {
        ERRload_struct (NFM, NFM_E_NO_ST_AREAS, "", NULL);
              _NFMdebug ((fname, "No Storage Area : status = <0x%.8x>\n",
              NFM_E_NO_ST_AREAS));
              return (NFM_E_NO_ST_AREAS);
            }

        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
           _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
		       status));
           return ( NFM_E_SQL_QUERY);
         }
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }
 
 long NFMget_proj_sa_list (user_id, cat_name, list)
   long    user_id;
   char    *cat_name;
   MEMptr  *list;
   {
     static char *fname = "NFMget_proj_sa_list" ;
     long    status, atol ();
     char    sql_str [4096], sql_str1 [2048] ;
     long    cat_no;

     _NFMdebug ((fname, "Cat  Name = <%s>\n", cat_name));
     user_id = user_id ;
     status = NFMget_catalog_no (NFMglobal.NFMuserid, cat_name, &cat_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "PROJ SA LIST : Get Attr Info : status = <0x%.8x>\n",
			    status));
        return (status);
      }

     sprintf (sql_str1,
	      "%s %s.%s, %s.%s FROM %s WHERE %s.%s = %d AND %s.%s = %s.%s",
	      "SELECT",
	      "NFMSTORAGEAREA", "n_sano", "NFMSTORAGEAREA", "n_saname",
	      "NFMSTORAGEAREA, NFMCATALOGSAMAP, NFMPROJECTSAMAP",
	      "NFMCATALOGSAMAP", "n_catalogno", cat_no,
	      "NFMSTORAGEAREA", "n_sano", "NFMCATALOGSAMAP", "n_sano");
     
     sprintf (sql_str, "%s AND %s.%s = %d AND %s.%s = %s.%s",
	      sql_str1, "NFMPROJECTSAMAP", "n_projectno", WFinfo.proj_no,
	      "NFMCATALOGSAMAP", "n_mapno", "NFMPROJECTSAMAP", "n_mapno");

    status = SQLquery (sql_str, list, MEM_SIZE);
    if (status != SQL_S_SUCCESS)
     {
       MEMclose (list);

       if ((status) == SQL_I_NO_ROWS_FOUND)
	 {
	   ERRload_struct (NFM, NFM_E_NO_PROJ_CAT_SA_MAP, "", NULL);
	   _NFMdebug ((fname, "No Proj Sa Area : status = <0x%.8x>\n",
          NFM_E_NO_PROJ_CAT_SA_MAP));
          return (NFM_E_NO_PROJ_CAT_SA_MAP);
        }

        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
       _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
        NFM_E_SQL_QUERY));
       return ( NFM_E_SQL_QUERY);
     }

    _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long _NFMget_cat_acl_list (user_no, cat_no, list)
   long    user_no ;
   long    cat_no ;
   MEMptr  *list;
   {
     static char *fname = "_NFMget_cat_acl_list" ;
     long    status ;
     char    sql_str [1048] ;
     long    command_no ;

     _NFMdebug ((fname, "ENTER : User_no = <%d> : Cat  No = <%d>\n", 
		 user_no, cat_no));

/* is cat mapped */
     
     sprintf (sql_str, "select DISTINCT nfmcatalogaclmap.n_aclno, \
nfmworkflow.n_workflowname, nfmacls.n_aclname \
from nfmcatalogaclmap, nfmacls, nfmworkflow, nfmaclusers \
where nfmcatalogaclmap.n_catalogno = %d \
and nfmacls.n_aclno = nfmcatalogaclmap.n_aclno \
and nfmworkflow.n_workflowno = nfmacls.n_workflowno", 
	      cat_no) ;

     status = SQLquery (sql_str, list, MEM_SIZE);
     if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
       {
	 MEMclose (list) ;
	 ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
	 return (NFM_E_SQL_QUERY) ;
       }

     if (status != SQL_I_NO_ROWS_FOUND)
       {
	 MEMclose (list) ;
/* This query modified - ssk, 25.07.95 **********/
         WFget_command_no (&command_no) ;
	 sprintf (sql_str, "select DISTINCT nfmcatalogaclmap.n_aclno, \
nfmworkflow.n_workflowname, nfmacls.n_aclname \
from nfmcatalogaclmap, nfmacls, nfmworkflow, nfmaclusers, \
nfmaccess, nfmtransitions \
where nfmcatalogaclmap.n_catalogno = %d \
and nfmacls.n_aclno = nfmcatalogaclmap.n_aclno \
and nfmworkflow.n_workflowno = nfmacls.n_workflowno \
and nfmaclusers.n_userno = %d \
and nfmacls.n_aclno = nfmaclusers.n_aclno \
and nfmtransitions.n_transitionno = nfmaccess.n_transitionno \
and nfmaccess.n_classno = nfmaclusers.n_classno \
and nfmtransitions.n_commandno = %d",
		  cat_no, user_no, command_no) ;
	 
	 status = SQLquery (sql_str, list, MEM_SIZE);

	 if (status != SQL_S_SUCCESS)
	   {
	     MEMclose (list);

	     if (status == SQL_I_NO_ROWS_FOUND)
	       {
		 _NFMdebug ((fname, "User does not belong to any mapped acls\n")) ;
		 ERRload_struct (NFM, NFM_E_USER_NOT_IN_MAPPED_ACL, "", NULL);
		 return (NFM_E_USER_NOT_IN_MAPPED_ACL) ;
	       }

	     ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
	     _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
			 status));
	     return ( NFM_E_SQL_QUERY);
	   }
       }
     else  if (status == SQL_I_NO_ROWS_FOUND)
       {
	 MEMclose (list) ;
/********** what the valid acls for this user ???? ***********/
/******  mms - it makes no sense to send acl list
         because is an attribute that can not be changed 
	 PDM needs this  

	 WFget_command_no (&command_no) ;

	 sprintf (sql_str2, "select distinct (nfmaclusers.n_aclno) \
from nfmtransitions, nfmaccess, nfmaclusers \
where nfmtransitions.n_commandno = %d \
and nfmaccess.n_transitionno = nfmtransitions.n_transitionno \
and nfmaclusers.n_classno = nfmaccess.n_classno",
		  command_no) ;


	 sprintf (sql_str, "select distinct (nfmacls.n_aclno), \
nfmworkflow.n_workflowname, nfmacls.n_aclname \
from nfmacls, nfmworkflow, nfmaclusers \
where nfmacls.n_complete = 'Y' \
and nfmworkflow.n_workflowno = nfmacls.n_workflowno \
and nfmaclusers.n_userno = %d \
and nfmacls.n_aclno = nfmaclusers.n_aclno \
and nfmaclusers.n_aclno in (%s)",
		  user_no, sql_str2) ;
********************************/
	 WFget_command_no (&command_no) ;
	 status = _NFMget_acls_for_user (command_no, user_no, list) ;
	 if (status != NFM_S_SUCCESS)
	   {
	     _NFMdebug ((fname, "Failure : status = <0x%.8x>\n")) ;
	     return (status) ;
	   }

/******* mms - This takes long time **********
  sprintf (sql_str, "select distinct (nfmacls.n_aclno), \
  nfmworkflow.n_workflowname, nfmacls.n_aclname \
  from nfmacls, nfmworkflow, nfmaclusers, nfmtransitions, nfmaccess \
where nfmacls.n_complete = 'Y' \
and nfmworkflow.n_workflowno = nfmacls.n_workflowno \
and nfmworkflow.n_workflowtype = 'I' \
and nfmaclusers.n_userno = %d \
and nfmacls.n_aclno = nfmaclusers.n_aclno \
and nfmtransitions.n_transitionno = nfmaccess.n_transitionno \
and nfmaccess.n_classno = nfmaclusers.n_classno \
and nfmtransitions.n_commandno = %d ",
		  user_no, command_no) ;
		  
	 status = SQLquery (sql_str, list, MEM_SIZE);
	 if (status != SQL_S_SUCCESS)
	 {
	   MEMclose (list) ;
	   if (status == SQL_I_NO_ROWS_FOUND)
	   {
	   strcpy (message, "No acls found") ;
	   ERRload_struct (NFM, NFM_E_NO_ACLS_FOUND, "", "") ;
	   _NFMdebug ((fname, "Failure : No acls found : status = <0x%.8x>\n",
	   status)) ;
	   return (NFM_E_NO_ACLS_FOUND) ;
	   }
	   ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
	   _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
	   status));
	   return ( NFM_E_SQL_QUERY);
	   }
	   ****************************************************/


       }
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS) ;
   }

 long _NFMget_proj_acl_list (user_no, cat_no, proj_no, list)
   long    user_no ;
   long    cat_no ;
   long    proj_no ;
   MEMptr  *list;
   {
     static char *fname = "_NFMget_proj_acl_list" ;
     long    status ;
     char    sql_str [2048] ;

     _NFMdebug ((fname, "User no = <%d> : Cat  No = <%d> : Proj No = <%d>\n", 
		 user_no, cat_no, proj_no)) ;

     sprintf (sql_str, "select distinct (nfmacls.n_aclno), \
nfmworkflow.n_workflowname, nfmacls.n_aclname \
from nfmprojectaclmap, nfmcatalogaclmap, nfmacls, nfmworkflow, nfmaclusers \
where nfmprojectaclmap.n_projectno = %d \
and nfmprojectaclmap.n_mapno = nfmcatalogaclmap.n_mapno \
and nfmcatalogaclmap.n_catalogno = %d \
and nfmacls.n_aclno = nfmcatalogaclmap.n_aclno \
and nfmworkflow.n_workflowno = nfmacls.n_workflowno \
and nfmaclusers.n_userno = %d \
and nfmacls.n_aclno = nfmaclusers.n_aclno", 
	      proj_no, cat_no, user_no) ;

     status = SQLquery (sql_str, list, MEM_SIZE);
     if ((status != SQL_S_SUCCESS) &&
         ((status) != SQL_I_NO_ROWS_FOUND))
      {
        MEMclose (&list);
        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
		    status));
        return ( NFM_E_SQL_QUERY);
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }


 long _NFMget_cat_sa_list (cat_no, list)
   long    cat_no ;
   MEMptr  *list;
   {
     static char *fname = "_NFMget_cat_sa_list" ;
     long    status ;
     char    sql_str [2048] ;

     _NFMdebug ((fname, "Cat  No = <%d>\n", cat_no));

     sprintf (sql_str, "select nfmstoragearea.n_sano, nfmstoragearea.n_saname \
from nfmcatalogsamap, nfmstoragearea \
where nfmcatalogsamap.n_catalogno = %d \
and nfmstoragearea.n_sano = nfmcatalogsamap.n_sano",
	      cat_no) ;

     status = SQLquery (sql_str, list, MEM_SIZE);
     if ((status != SQL_S_SUCCESS) &&
         (status != SQL_I_NO_ROWS_FOUND))
      {
	MEMclose (list) ;
        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
		    status));
        return ( NFM_E_SQL_QUERY);
      }

     if (status == SQL_I_NO_ROWS_FOUND)
       {
	 MEMclose (list) ;

	 sprintf (sql_str, "select nfmstoragearea.n_sano, \
nfmstoragearea.n_saname from nfmstoragearea \
where nfmstoragearea.n_sano > 3 \
and nfmstoragearea.n_type !=  'T'") ;

	 status = SQLquery (sql_str, list, MEM_SIZE);
	 if (status != SQL_S_SUCCESS)
	 {
	   MEMclose (list) ;
	   if (status == SQL_I_NO_ROWS_FOUND)
	     {
	       ERRload_struct (NFM, NFM_E_NO_ST_AREAS, "", NULL) ;
	       _NFMdebug ((fname, "No Storageareas : status = <0x%.8x>\n",
			   status)) ;
	       return (NFM_E_NO_ST_AREAS) ;
	     }
	   ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
	   _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
		       status));
	   return ( NFM_E_SQL_QUERY);
	 }
       }

     _NFMdebug ((fname, "SUCCESSFUL\n"));
     return (NFM_S_SUCCESS);
   }

 long _NFMget_cat_internal_sa_list (cat_no, list)
   long    cat_no ;
   MEMptr  *list;
   {
     static char *fname = "_NFMget_cat_internal_sa_list" ;
     long    status ;
     char    sql_str [2048] ;

     _NFMdebug ((fname, "Cat  No = <%d>\n", cat_no));

     sprintf (sql_str, "select nfmstoragearea.n_sano, nfmstoragearea.n_saname \
from nfmcatalogsamap, nfmstoragearea \
where nfmcatalogsamap.n_catalogno = %d \
and nfmstoragearea.n_sano = nfmcatalogsamap.n_sano",
	      cat_no) ;

     status = SQLquery (sql_str, list, MEM_SIZE);
     if ((status != SQL_S_SUCCESS) &&
         (status != SQL_I_NO_ROWS_FOUND))
      {
	MEMclose (list) ;
        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
		    status));
        return ( NFM_E_SQL_QUERY);
      }

     if (status == SQL_I_NO_ROWS_FOUND)
       {
	 MEMclose (list) ;

	 sprintf (sql_str, "select nfmstoragearea.n_sano, nfmstoragearea.n_saname from nfmstoragearea where (nfmstoragearea.n_type =  'B' or nfmstoragearea.n_type = 'I')") ;

	 status = SQLquery (sql_str, list, MEM_SIZE);
	 if (status != SQL_S_SUCCESS)
	 {
	   MEMclose (list) ;
	   if (status == SQL_I_NO_ROWS_FOUND)
	     {
	       ERRload_struct (NFM, NFM_E_NO_ST_AREAS, "", NULL) ;
	       _NFMdebug ((fname, "No Storageareas : status = <0x%.8x>\n",
			   status)) ;
	       return (NFM_E_NO_ST_AREAS) ;
	     }
	   ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
	   _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
		       status));
	   return ( NFM_E_SQL_QUERY);
	 }
       }

     _NFMdebug ((fname, "SUCCESSFUL\n"));
     return (NFM_S_SUCCESS);
   }
 
 long _NFMget_proj_sa_list (cat_no, proj_no, list)
   long    cat_no ;
   long    proj_no ;
   MEMptr  *list;
   {
     static char *fname = "_NFMget_proj_sa_list" ;
     long    status ;
     char    sql_str [1024] ;

     _NFMdebug ((fname, "Cat No = <%d>\n", cat_no));

     sprintf (sql_str, "select nfmstoragearea.n_sano, nfmstoragearea.n_saname \
from nfmprojectsamap, nfmcatalogsamap, nfmstoragearea \
where nfmprojectsamap.n_mapno = nfmcatalogsamap.n_mapno \
and nfmprojectsamap.n_projectno = %d \
and nfmcatalogsamap.n_catalogno = %d \
and nfmstoragearea.n_sano = nfmcatalogsamap.n_sano",
	      proj_no, cat_no) ;

     status = SQLquery (sql_str, list, MEM_SIZE);
     if ((status != SQL_S_SUCCESS) &&
         (status != SQL_I_NO_ROWS_FOUND))
      {
	MEMclose (list) ;
        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
		    status));
        return ( NFM_E_SQL_QUERY);
      }

    _NFMdebug ((fname, "SUCCESSFUL\n")) ;
    return (NFM_S_SUCCESS);
   }

long _NFMget_internal_sa_list_for_item (cat_name, item_name, item_rev, list)
     char *cat_name ;    /* input - catalog name */
     char *item_name ;   /* input - item name */
     char *item_rev ;    /* input - item rev */
     MEMptr *list ;      /* output - list */
{
  char *fname = "_NFMget_internal_sa_list_for_item" ;
  long status ;
  long proj_no ;
  long cat_no ;

  if (WFinfo.catalog_no > 0)
    {
      cat_no = WFinfo.catalog_no ;
    }
  else
    {
      status = NFMget_catalog_no (NFMglobal.NFMuserid, cat_name, &cat_no) ;
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "Failure : Bad Catalog No for %s : status = <0x%.8x>\n",
		      cat_name, status)) ;
	  return (NFM_E_BAD_CATALOG) ;
	}
    }

  status = NFMcheck_item_owned_project (NFMglobal.NFMuserid, cat_name,
					item_name, item_rev, &proj_no);
  if (status != NFM_S_SUCCESS             && 
      status != NFM_E_PROJECT_MEMBER      &&
         status != NFM_E_NOT_PROJECT_MEMBER)
    {
      _NFMdebug ((fname, "Chk Item Proj Mem : status = <0x%.8x>\n",
		  status));
      return (status);
    }

  ERRload_struct (NFM, NFM_S_SUCCESS, "", "") ;
  
  if (status == NFM_E_PROJECT_MEMBER)
    {        
      status = _NFMget_proj_sa_list (cat_no, proj_no, list);
      if (status != NFM_S_SUCCESS)
	{
	  MEMclose (list);
	  _NFMdebug ((fname, "Proj Ci Sa List : status = <0x%.8x>\n",
		      status));
	  return (status);          
	}
    }
  else
    {
      status = _NFMget_cat_internal_sa_list (cat_no, list);
      if (status != NFM_S_SUCCESS)
	{
	  MEMclose (list);
	  _NFMdebug ((fname, "Cat Ci Sa List : status = <0x%.8x>\n",
		      status));
	  return (status);          
	}
    }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return(NFM_S_SUCCESS) ;
}  


long _NFMget_acl_for_item (cat_name, item_name, item_rev, list) 
     char *cat_name ;    /* input - catalog name */
     char *item_name ;   /* input - item name */
     char *item_rev ;    /* input - item rev */
     MEMptr *list ;      /* output - list */
{
  char *fname = "_NFMget_acl_list_for_item" ;
  long status ;
  long proj_no ;
  long cat_no ;

  if (WFinfo.catalog_no > 0)
    {
      cat_no = WFinfo.catalog_no ;
    }
  else
    {
      status = NFMget_catalog_no (NFMglobal.NFMuserid, cat_name, &cat_no) ;
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "Failure : Bad Catalog No for %s : status = <0x%.8x>\n",
		      cat_name, status)) ;
	  return (NFM_E_BAD_CATALOG) ;
	}
    }

  status = NFMcheck_item_owned_project (NFMglobal.NFMuserid, cat_name,
					item_name, item_rev, &proj_no);
  if (status != NFM_S_SUCCESS             && 
      status != NFM_E_PROJECT_MEMBER      &&
         status != NFM_E_NOT_PROJECT_MEMBER)
    {
      _NFMdebug ((fname, "Chk Item Proj Mem : status = <0x%.8x>\n",
		  status));
      return (status);
    }
  
  ERRload_struct (NFM, NFM_S_SUCCESS, "", "") ;
  if (status == NFM_E_PROJECT_MEMBER)
    {        
      status = _NFMget_proj_acl_list (NFMglobal.NFMuserno,
				      cat_no, proj_no, list);
      if (status != NFM_S_SUCCESS)
	{
	  MEMclose (list);
	  _NFMdebug ((fname, "Proj Ci Sa List : status = <0x%.8x>\n",
		      status));
	  return (status);          
	}
    }
  else
    {
      status = _NFMget_cat_acl_list (NFMglobal.NFMuserno,
				     cat_no, list);
      if (status != NFM_S_SUCCESS)
	{
	  MEMclose (list);
	  _NFMdebug ((fname, "Cat Ci Sa List : status = <0x%.8x>\n",
		      status));
	  return (status);          
	}
    }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return(NFM_S_SUCCESS) ;
}  





long NFMcheck_item_owned_project (user_id, cat_name,
                                  item_name, item_rev, proj_no)
   long     user_id;
   char     *cat_name, *item_name, *item_rev;
   long     *proj_no;
   {
     char *fname = "NFMcheck_item_owned_project" ;
     long    status, atol ();
     long    cat_no, item_no;
     char    sql_str [1024], value [50];

     *proj_no = 0;
     user_id = user_id ;
     _NFMdebug ((fname, "Cat  Name = <%s> : Item Name = <%s> : Item Rev = <%s> : Proj No = <%d>\n", 
		 cat_name, item_name, item_rev, proj_no));

     status = NFMget_catalog_no (NFMglobal.NFMuserid, cat_name, &cat_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Cat No : status = <0x%.8x>\n",
        status));
        return (status);
      }

     status = NFMget_item_no (NFMglobal.NFMuserid, cat_name, 
              item_name, item_rev, &item_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Item No : status = <0x%.8x>\n",
        status));
        return (status);
      }

     sprintf (sql_str, "WHERE %s = %d", "n_catalogno", cat_no);

     strcat (sql_str, " AND ");
     strcat (sql_str, "n_itemno");
     strcat (sql_str, " = ");

     sprintf (value, "%d", item_no);

     strcat (sql_str, value);

     strcat (sql_str, " AND ");
     strcat (sql_str, "n_type");
     strcat (sql_str, " = ");

     strcat (sql_str, "'");
     strcat (sql_str, "O");
     strcat (sql_str, "'");

     status = NFMget_attr_value (NFMglobal.NFMuserid, "NFMPROJECTCIT", "n_projectno",
              sql_str, value);
     if (status != NFM_S_SUCCESS && status != NFM_I_BAD_CONDITION)
      {
        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
        status));
        return (status);
      }

     if (atol (value) > 0)
      {
        *proj_no = atol (value);
        ERRload_struct (NFM, NFM_E_PROJECT_MEMBER, "", NULL);
        _NFMdebug ((fname, "Project Member : status = <0x%.8x>\n",
        NFM_E_PROJECT_MEMBER));
        return (NFM_E_PROJECT_MEMBER);
      }
     else
      {
        ERRload_struct (NFM, NFM_E_NOT_PROJECT_MEMBER, "", NULL);
        _NFMdebug ((fname, "Not A Proj Mem : status = <0x%.8x>\n",
        NFM_E_NOT_PROJECT_MEMBER));
        return (NFM_E_NOT_PROJECT_MEMBER);
      }
/****** unreachable *******
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
*************************/
   }


long _NFMget_acls_for_user (commandno, userno, list2)
     long commandno ;
     long userno ;
     MEMptr *list2 ;
{
  char *fname = "_NFMget_acls_for_user" ;
  long status,t, y, offset, i ;
  MEMptr list = NULL, list1 = NULL ;
  char sql_str [1024], **data, **format, **column, **data1 ;

  _NFMdebug ((fname, "command <%d> : user <%d>\n", 
	      commandno, userno)) ;

  strcpy(sql_str, "select nfmacls.n_aclno, \
nfmworkflow.n_workflowname, nfmacls.n_aclname \
from nfmacls, nfmworkflow \
where nfmacls.n_complete = 'Y' \
and nfmworkflow.n_workflowno = nfmacls.n_workflowno \
and nfmworkflow.n_workflowtype = 'I'") ;

  status = SQLquery (sql_str, &list, MEM_SIZE);

  if (status == SQL_S_SUCCESS)
    {
      status= MEMbuild_array (list) ;
      if (status != MEM_S_SUCCESS)
	{
	  MEMclose (&list) ;
	  _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n", status));
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  return (NFM_E_MEM) ;
	}
      data = (char **) list->data_ptr ;

      sprintf (sql_str, "select distinct nfmaclusers.n_aclno \
from nfmaclusers, nfmtransitions, nfmaccess \
where nfmaclusers.n_userno = %d \
and nfmtransitions.n_transitionno = nfmaccess.n_transitionno \
and nfmaccess.n_classno = nfmaclusers.n_classno \
and nfmtransitions.n_commandno = %d ",
	       userno, commandno) ;
      
      status = SQLquery (sql_str, &list1, MEM_SIZE);
      if (status == SQL_S_SUCCESS)
	{
	  status = MEMbuild_array (list1) ;
	  if (status != MEM_S_SUCCESS)
	    {
	      MEMclose (&list) ;
	      MEMclose (&list1) ;
	      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	      return (NFM_E_MEM) ;
	    }
	  column = (char **) list->column_ptr ;
	  format = (char **) list->format_ptr ;
	  status = MEMopen (list2, 2*MEM_SIZE) ;
	  if (status != MEM_S_SUCCESS)
	    {
	      MEMclose (&list) ;
	      MEMclose (&list1) ;
	      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	      _NFMdebug ((fname, "Failure : MEMopen : status = <0x%.8x>\n",
			  status)) ;
	      return (NFM_E_MEM) ;
	    }

	  for (t=0; t<list->columns; t++)
	    {
	      status = MEMwrite_format (*list2, column[t], format [t]) ;
	      if (status != MEM_S_SUCCESS)
		{
		  MEMclose (&list) ;
		  MEMclose (&list1) ;
		  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
		  _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status));
		  return (NFM_E_MEM) ;
		}
	    }

	  data1 = (char **) list1->data_ptr ;
	  for (i=0; i<list->rows; i++)
	    {
	      offset = list->columns*i ;
	      for (y=0; y<list1->rows; y++)
		{
		  if (strcmp (data [offset], data1 [y]) == 0)
		    {
		      break ;
		    }
		}
	      if (y != list1->rows)
		{
		  sprintf (sql_str, "%s\001%s\001%s\001",
			   data [offset], data [offset+1], data [offset+2]) ;
		  /* write this row into new buffer */
		  status = MEMwrite (*list2, sql_str) ;
		  if (status != MEM_S_SUCCESS)
		    {
		      MEMclose (&list) ;
		      MEMclose (&list1) ;
		      _NFMdebug ((fname, "MEMwrite : status = <0x%.8x>\n", status)) ;
		      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
		      return (NFM_E_MEM) ;
		    }
		}
	    }
	}
      else 
	{
	  MEMclose (&list) ;
	  MEMclose (&list1) ;
	  if (status == SQL_I_NO_ROWS_FOUND)
	    {
	      ERRload_struct (NFM, NFM_E_NO_ACLS_FOUND, "", "") ;
	      _NFMdebug ((fname, "Failure : No acls found : status = <0x%.8x>\n",
			  status)) ;
	      return (NFM_E_NO_ACLS_FOUND) ;
	    }
	  else
	    {
	      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
	      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
	      return (NFM_E_SQL_QUERY) ;
	    }
	}
    }
  else
    {
      MEMclose (&list) ;
      if (status == SQL_I_NO_ROWS_FOUND)
	{
	  ERRload_struct (NFM, NFM_E_NO_ACLS_FOUND, "", "") ;
	  _NFMdebug ((fname, "Failure : No acls found : status = <0x%.8x>\n",
		      status)) ;
	  return (NFM_E_NO_ACLS_FOUND) ;
	}
      else
	{
	  _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
	  ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
	  return (NFM_E_SQL_QUERY) ;
	}
    }

  MEMclose (&list) ;
  MEMclose (&list1) ;
	     
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}


