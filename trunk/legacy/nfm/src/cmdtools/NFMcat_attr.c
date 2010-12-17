#include "machine.h"
#include "CMDTOOLS.h"

#define F_CAT_TYPE 0
#define CAT_TYPE 1

  extern struct NFMglobal_st NFMglobal ;

 long NFMquery_catalog_definition (user_id, cat_name, attr_list)
   long     user_id;
   char     *cat_name;
   MEMptr   *attr_list;
   {
     static char *fname = "NFMquery_catalog_definition" ;
     long     status;
     char     sql_str [1024], file_cat [100];
     long     table_no1, table_no2;

     _NFMdebug ((fname, "CAT  Name  = <%s>\n", cat_name));

     status = NFMget_table_no (user_id, "CATALOG", cat_name,
              &table_no1);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Table No : status = <0x%.8x>\n",
        status));
        return (status);          
      }

     sprintf (file_cat, "f_%s", cat_name);

     status = NFMget_table_no (user_id, "F_CATALOG", file_cat,
              &table_no2);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Table No : status = <0x%.8x>\n",
        status));
        return (status);          
      }

     sprintf (sql_str, " n_tableno = %d OR n_tableno = %d",
              table_no1, table_no2);

     status = NFMquery_condition_definition (user_id,
              "", "", sql_str, "",  attr_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (attr_list);
        _NFMdebug ((fname, "Tab Definition : status = <0x%.8x>\n",
        status));
        return (status);          
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMquery_catalog_attributes (user_id, cat_name,
                    attr_list, data_list, value_list)
   long     user_id;
   char     *cat_name;
   MEMptr   *attr_list, *data_list, *value_list;
   {
     static char *fname = "NFMquery_catalog_attributes" ;
     long     status;
     char     sql_str [1024], file_cat [100];
     long     table_no1, table_no2;

     _NFMdebug ((fname, "Cat  Name = <%s>\n", cat_name ));

     status = NFMget_table_no (user_id, "CATALOG", cat_name,
              &table_no1);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Table No : status = <0x%.8x>\n",
        status));
        return (status);          
      }

     sprintf (file_cat, "f_%s", cat_name);

     status = NFMget_table_no (user_id, "F_CATALOG", file_cat,
              &table_no2);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Table No : status = <0x%.8x>\n",
        status));
        return (status);          
      }

     sprintf (sql_str, " n_tableno = %d OR n_tableno = %d",
              table_no1, table_no2);

     status = NFMquery_condition_attributes (user_id, 
              "", "", sql_str, "", attr_list, data_list, value_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        _NFMdebug ((fname, "Cond Tab Attr : status = <0x%.8x>\n",
        status));
        return (status);          
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMquery_catalog_information (user_id, cat_name,
                     attr_list, data_list, value_list)
   long     user_id;
   char     *cat_name;
   MEMptr   *attr_list, *data_list, *value_list;
   {
     static char *fname = "NFMquery_catalog_information" ;
     long     status;
     char     sql_str [1024], file_cat [100];
     long     table_no1, table_no2;
     char     **data, **column;
     long     a, c, x, y, count;

     _NFMdebug ((fname, "Cat  Name = <%s>\n", cat_name ));

     status = NFMget_table_no (user_id, "CATALOG", cat_name,
              &table_no1);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Table No : status = <0x%.8x>\n",
        status));
        return (status);          
      }

     sprintf (file_cat, "f_%s", cat_name);

     status = NFMget_table_no (user_id, "F_CATALOG", file_cat,
              &table_no2);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Table No : status = <0x%.8x>\n",
        status));
        return (status);          
      }

     sprintf (sql_str, " n_tableno = %d OR n_tableno = %d",
              table_no1, table_no2);

     status = NFMquery_condition_information (user_id, 
              "", "", sql_str, "", attr_list, data_list, value_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        _NFMdebug ((fname, "Cond Tab Attr : status = <0x%.8x>\n",
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
  
     a = -1; c = -1;

     for (y = 0; y < (*attr_list) -> columns; ++y)
      {
             if (! strcmp (column [y], "n_valueno"))       a = y;
/*        else if (! strcmp (column [y], "n_adviceno"))      b = y; */
        else if (! strcmp (column [y], "n_name"))          c = y;
     }
      
     for (x = 0; x < (*attr_list) -> rows; ++x)
      {
         count = (*attr_list) -> columns * x;

         if ((! strcmp (data [count + c], "n_aclno"))   ||
             (! strcmp (data [count + c], "n_cisano")))
          {
            status = MEMwrite_data (*attr_list, "-1", x + 1, a + 1);
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
/***************  do not disable advisory information ***********
            status = MEMwrite_data (*attr_list, "-1", x + 1, b + 1);
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
*******************************************************************/
          }
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMquery_change_catalog_information (user_id, cat_name,
                            attr_list, data_list, value_list)
   long     user_id;
   char     *cat_name;
   MEMptr   *attr_list, *data_list, *value_list;
   {
     static char *fname = "NFMquery_change_catalog_information" ;
     long     status;
     char     sql_str [1024], file_cat [100];
     long     table_no1, table_no2;
     char     **data, **column;
     long     a, c, a1, x, y, count;

     _NFMdebug ((fname, "Cat  Name = <%s>\n", cat_name));

     status = NFMget_table_no (user_id, "CATALOG", cat_name,
              &table_no1);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Table No : status = <0x%.8x>\n",
        status));
        return (status);          
      }

     sprintf (file_cat, "f_%s", cat_name);

     status = NFMget_table_no (user_id, "F_CATALOG", file_cat,
              &table_no2);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Table No : status = <0x%.8x>\n",
        status));
        return (status);          
      }

     sprintf (sql_str, " n_tableno = %d OR n_tableno = %d",
              table_no1, table_no2);

     status = NFMquery_change_condition_information (user_id,
              "", "", sql_str, "", attr_list, data_list, value_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        _NFMdebug ((fname, "Mod Tab Attr : status = <0x%.8x>\n",
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
  
     a  = -1; c = -1;
     a1 = -1; 

     for (y = 0; y < (*attr_list) -> columns; ++y)
      {
             if (! strcmp (column [y], "n_valueno"))     a  = y;
/*        else if (! strcmp (column [y], "n_adviceno"))      b  = y; */
        else if (! strcmp (column [y], "new_n_valueno")) a1 = y;
/*        else if (! strcmp (column [y], "new_n_adviceno"))  b1 = y; */
        else if (! strcmp (column [y], "n_name"))    c  = y;
     }

     for (x = 0; x < (*attr_list) -> rows; ++x)
      {
         count = (*attr_list) -> columns * x;

         if ((! strcmp (data [count + c], "n_aclno"))   ||
             (! strcmp (data [count + c], "n_cisano")))
          {
            status = MEMwrite_data (*attr_list, "-1", x + 1, a + 1);
            if (status != MEM_S_SUCCESS)
             {
               MEMclose (attr_list);
               MEMclose (data_list);
               MEMclose (value_list);
               ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               _NFMdebug ((fname, "Wr Data : status = <0x%.8x>\n",
			   status));
               return (NFM_E_MEM);
             }
/***************  do not disable advisory information ***********
            status = MEMwrite_data (*attr_list, "-1", x + 1, b + 1);
            if (status != MEM_S_SUCCESS)
             {
               MEMclose (attr_list);
               MEMclose (data_list);
               MEMclose (value_list);
               ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               _NFMdebug ((fname, "Wr Data : status = <0x%.8x>\n",
			   status));
               return (NFM_E_MEM);
             }
******************************************************************/
            status = MEMwrite_data (*attr_list, "-1", x + 1, a1 + 1);
            if (status != MEM_S_SUCCESS)
             {
               MEMclose (attr_list);
               MEMclose (data_list);
               MEMclose (value_list);
               ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               _NFMdebug ((fname, "Wr Data : status = <0x%.8x>\n",
			   status));
               return (NFM_E_MEM);
             }
/***************  do not disable advisory information ***********
            status = MEMwrite_data (*attr_list, "-1", x + 1, b1 + 1);
            if (status != MEM_S_SUCCESS)
             {
               MEMclose (attr_list);
               MEMclose (data_list);
               MEMclose (value_list);
               ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               _NFMdebug ((fname, "Wr Data : status = <0x%.8x>\n",
			   status));
               return (NFM_E_MEM);
             }
******************************************************************/
          }
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }



 long NFMsplit_catalog_definition (user_id, attr_list,
				   attr_list1, attr_list2)
   long      user_id ;
   MEMptr    attr_list;
   MEMptr    *attr_list1;
   MEMptr    *attr_list2;
   {
     static char *fname = "NFMsplit_catalog_definition" ;
     long    status;
     char    *sql_str, *str ;
     MEMptr  sql_buffer = NULL ;
     char    **column, **format, **data, **table_data ;
     long    x, y, count, a, b, or_clause, filetype, offset, e;
     long    table_no ;

     _NFMdebug ((fname, "ENTER\n")) ;
     user_id = user_id ;
     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     status = MEMopen (attr_list1, 2 * MEM_SIZE);
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     status = MEMopen (attr_list2, 2 * MEM_SIZE);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list1);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     column = (char **) attr_list -> column_ptr;
     format = (char **) attr_list -> format_ptr;
     data   = (char **) attr_list -> data_ptr;

     a = -1; b = -1; e = -1;

     for (y = 0; y < attr_list -> columns; ++y)
       {
	 if (! strcmp (column [y], "n_name"))              a = y;
	 else if (! strcmp (column [y], "n_datatype"))     b = y;
	 else if (! strcmp (column [y], "n_tableno"))      e = y;
	 
	 status = MEMwrite_format (*attr_list1, column [y], format [y]);
	 if (status != MEM_S_SUCCESS)
	   {
	     MEMclose (attr_list1);
	     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	     _NFMdebug ((fname, "MEM Write Format : status = <0x%.8x>\n",
			 status));
	     return (NFM_E_MEM);
	   }
	 
	 status = MEMwrite_format (*attr_list2, column [y], format [y]);
	 if (status != MEM_S_SUCCESS)
	   {
	     MEMclose (attr_list1);
	     MEMclose (attr_list2);
	     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	     _NFMdebug ((fname, "MEM Write Format : status = <0x%.8x>\n",
			 status));
	     return (NFM_E_MEM);
	   }
       }

     sql_str = (char *) malloc (attr_list->rows * 30) ;
     if (sql_str == NULL)
       {
	 _NFMdebug ((fname, "Malloc failed\n")) ;
	 ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
	 return (NFM_E_MALLOC) ;
       }

     str = (char *) malloc (attr_list->rows*30 + 100) ;
     if (str == NULL)
       {
	 free (sql_str) ;
	 _NFMdebug ((fname, "Malloc failed\n")) ;
	 ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
	 return (NFM_E_MALLOC) ;
       }

     sql_str [0] = 0 ;
     or_clause = 0 ;
     for (y = 0; y < attr_list -> rows; ++y)
       {
	 count = y*attr_list->columns ;
	 if (strlen (data [count+e]))
	   {
	     if (or_clause) strcat (sql_str, " ,");
	     else 
	       {
		 or_clause = 1 ;
	       }
	     strcat (sql_str, data [count + e]);
	   }
       }

     sprintf (str, 
	      "select DISTINCT n_tableno, n_tabletype, n_identifier from nfmtables where n_tableno in (%s)",
	      sql_str) ;
     status = SQLquery (str, &sql_buffer, MEM_SIZE) ;
     if (status != SQL_S_SUCCESS)
       {
	 MEMclose (&sql_buffer) ;
	 free (sql_str) ;
	 free (str) ;
	 ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
	 _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n",
		     status)) ;
	 return (NFM_E_SQL_QUERY) ;
       }

     free (sql_str) ;
     free (str) ;

     status = MEMbuild_array (sql_buffer) ;
     if (status != MEM_S_SUCCESS)
       {
	 MEMclose (&sql_buffer) ;
	 _NFMdebug ((fname, "MEMbuild_array (sql_buffer) : status = <0x%.8x>\n",
		     status)) ;
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	 return (NFM_E_MEM) ;
       }

     table_data = (char **) sql_buffer -> data_ptr ;

     sql_str = (char *) malloc (attr_list -> row_size);
     if (! sql_str)
      {
        MEMclose (attr_list1);
        MEMclose (attr_list2);
	MEMclose (&sql_buffer) ;
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed\n")) ;
        return (NFM_E_MALLOC);
      }
     sql_str [0] = 0;

     for (x = 0; x < attr_list -> rows; ++x)
      {
         count = attr_list -> columns * x;
         sql_str [0] = 0;

	 table_no = atol (data [count+e]) ;

	 filetype = CAT_TYPE ;
	 for (y=0; y<sql_buffer->rows; y++)
	   {
	     offset = y*sql_buffer->columns ;
/*	     _NFMdebug ((fname, "%d : %s : %s\n",
			 atol (table_data[offset]), 
			 table_data[offset+1], 
			 table_data[offset+2])) ; */
			 
	     if (table_no == atol (table_data[offset]))
	       {
		 if (strcmp (table_data[offset+1], "f_catalog") == 0)
		   filetype = F_CAT_TYPE;
		 else 
		   filetype = CAT_TYPE ;
		 break ;
	       }
	   }

         for (y = 0; y < attr_list -> columns; ++y)
          {
            strcat (sql_str, data [count + y]);
            strcat (sql_str, "\1");
          }

	 if (filetype == F_CAT_TYPE)
	   {
            status = MEMwrite (*attr_list2, sql_str);
            if (status != MEM_S_SUCCESS)
             {
               free (sql_str);
               MEMclose (attr_list1);
               MEMclose (attr_list2);
	       MEMclose (&sql_buffer) ;
               ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
			   status));
               return (NFM_E_MEM);
             }
          }
         else
          {
            status = MEMwrite (*attr_list1, sql_str);
            if (status != MEM_S_SUCCESS)
             {
               free (sql_str);
               MEMclose (attr_list1);
               MEMclose (attr_list2);
	       MEMclose (&sql_buffer) ;
               ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
			   status));
               return (NFM_E_MEM);
             }
          }
      }
     free (sql_str);
     MEMclose (&sql_buffer) ;

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }


long NFMsplit_catalog_attributes (user_id,
				  attr_list, data_list, 
				  attr_list1, data_list1,
				  attr_list2, data_list2)
   long      user_id ;
   MEMptr    attr_list, data_list;
   MEMptr    *attr_list1, *data_list1;
   MEMptr    *attr_list2, *data_list2;
   {
     static char *fname = "NFMsplit_catalog_attributes" ;
     long    status;
     char    **column, **data;
     char    **data1, **data2, **data3;
     long    x, y, z, count, count1, count2, count3;
     long    a, b, found;
     char    *sql_str1, *sql_str2;

     _NFMdebug ((fname, "ENTER\n")) ;
     user_id = user_id ;
     status = NFMsplit_catalog_definition (NFMglobal.NFMuserid,
					   attr_list, attr_list1, attr_list2);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (attr_list1);
        MEMclose (attr_list2);
        _NFMdebug ((fname, "Split Cat Def : status = <0x%.8x>\n",
        status));
        return (status);
      }

     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list1);
        MEMclose (attr_list2);

        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }
   
     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     a = -1; b = -1; 

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))      a = y;
        else if (! strcmp (column [y], "n_datatype"))  b = y;
      }

     status = MEMbuild_array (*attr_list1);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list1);
        MEMclose (attr_list2);

        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }
 
     data1 = (char **) (*attr_list1) -> data_ptr;

     status = MEMopen (data_list1, 2 * MEM_SIZE);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list1);
        MEMclose (attr_list2);

        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     for (x = 0; x < (*attr_list1) -> rows; ++x)
      {
        count = (*attr_list1) -> columns * x;

        status = MEMwrite_format (*data_list1,
                 data1 [count + a], data1 [count + b]);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (attr_list1);
           MEMclose (attr_list2);
 
           MEMclose (data_list1);

           ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);
         }
      }

     status = MEMbuild_array (*attr_list2);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list1);
        MEMclose (attr_list2);

        MEMclose (data_list1);

        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }
 
     data2 = (char **) (*attr_list2) -> data_ptr;

     status = MEMopen (data_list2, 2 * MEM_SIZE);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list1);
        MEMclose (attr_list2);

        MEMclose (data_list1);

        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     for (x = 0; x < (*attr_list2) -> rows; ++x)
      {
        count = (*attr_list1) -> columns * x;

        status = MEMwrite_format (*data_list2,
                 data2 [count + a], data2 [count + b]);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (attr_list1);
           MEMclose (attr_list2);
 
           MEMclose (data_list1);
           MEMclose (data_list2);

           ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);
         }
      }

     sql_str1 = (char *) malloc ((*data_list1) -> row_size);
     if (! sql_str1)
      {
        MEMclose (attr_list1);
        MEMclose (attr_list2);

        MEMclose (data_list1);
        MEMclose (data_list2);

        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
        NFM_E_MALLOC));
        return (NFM_E_MALLOC);
      }
     sql_str1 [0] = 0;

     sql_str2 = (char *) malloc ((*data_list2) -> row_size);
     if (! sql_str2)
      {
        free (sql_str1);

        MEMclose (attr_list1);
        MEMclose (attr_list2);

        MEMclose (data_list1);
        MEMclose (data_list2);

        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
        NFM_E_MALLOC));
        return (NFM_E_MALLOC);
      }
     sql_str2 [0] = 0;

     status = MEMbuild_array (data_list);
     if (status != MEM_S_SUCCESS)
      {
        free (sql_str1);
        free (sql_str2);

        MEMclose (attr_list1);
        MEMclose (attr_list2);

        MEMclose (data_list1);
        MEMclose (data_list2);

        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     data3 = (char **) data_list -> data_ptr;
 
     for (z = 0; z < data_list -> rows; ++z)
      {
        count3 = data_list -> columns * z;

        sql_str1 [0] = 0; sql_str2 [0] = 0;

        for (x = 0; x < attr_list -> rows; ++x)
         {
           count = attr_list -> columns * x;
           found = 0;
          
           for (y = 0; (y < (*attr_list1) -> rows) && (! found); ++y) 
            {
              count1 = (*attr_list1) -> columns * y;
 
              if (! strcmp (data [count + a], data1 [count1 + a]))
               {
                 strcat (sql_str1, data3 [count3 + x]);
                 strcat (sql_str1, "\1");

                 found = 1;
               }
            }

           for (y = 0; (y < (*attr_list2) -> rows) && (! found); ++y) 
            {
              count2 = (*attr_list2) -> columns * y;

              if (! strcmp (data [count + a], data2 [count2 + a]))
               {
                 strcat (sql_str2, data3 [count3 + x]);
                 strcat (sql_str2, "\1");

                 found = 1;
               }              
            }

           if (! found)
            {
              free (sql_str1);
              free (sql_str2);
 
              MEMclose (attr_list1);
              MEMclose (attr_list2);

              MEMclose (data_list1);
              MEMclose (data_list2);

              ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL);
              _NFMdebug ((fname, "Corrupted Buffers : status = <0x%.8x>\n",
              NFM_E_CORRUPTED_BUFFERS));
              return (NFM_E_CORRUPTED_BUFFERS);
            }
         }

        status = MEMwrite (*data_list1, sql_str1);
        if (status != MEM_S_SUCCESS)
         {
           free (sql_str1);
           free (sql_str2);

           MEMclose (attr_list1);
           MEMclose (attr_list2);

           MEMclose (data_list1);
           MEMclose (data_list2);

           ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);
         }

        status = MEMwrite (*data_list2, sql_str2);
        if (status != MEM_S_SUCCESS)
         {
           free (sql_str1);
           free (sql_str2);

           MEMclose (attr_list1);
           MEMclose (attr_list2);

           MEMclose (data_list1);
           MEMclose (data_list2);

           ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);
         }
      }

     free (sql_str1);
     free (sql_str2);

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }



 long _NFMquery_catalog_attributes (catalog_name,
				     attr_list, data_list, value_list)
   char     *catalog_name ;
   MEMptr   *attr_list, *data_list, *value_list;
   {
     static char *fname = "_NFMquery_catalog_attributes" ;
     long     status;
     long     _NFMget_table_attr ();
     long     _NFMget_data_info ();

     _NFMdebug ((fname, "ENTER\n")) ;

     status = _NFMget_table_attr (catalog_name,  attr_list) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Table attr : status = <0x%.8x>\n, status")) ;
	 return (status) ;
       }

     status = _NFMget_data_value (*attr_list, data_list, value_list,
				  "A", "R") ;
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        _NFMdebug ((fname, "Get Data Values : status = <0x%.8x>\n",
        status));
        return (status);          
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

/*** validatation/advisory list will only have writable attributes ***/
 long _NFMquery_catalog_attributes_w (catalog_name,
				     attr_list, data_list, value_list)
   char     *catalog_name ;
   MEMptr   *attr_list, *data_list, *value_list;
   {
     static char *fname = "_NFMquery_catalog_attributes_w" ;
     long     status;
     long     _NFMget_table_attr ();
     long     _NFMget_data_info ();

     _NFMdebug ((fname, "ENTER\n")) ;

     status = _NFMget_table_attr (catalog_name,  attr_list) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Table attr : status = <0x%.8x>\n, status")) ;
	 return (status) ;
       }
/*
     status = _NFMget_data_value_w (*attr_list, data_list, value_list);
*/
     status = _NFMget_data_value (*attr_list, data_list, value_list,
				  "W", "R");
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        _NFMdebug ((fname, "Get Data Values : status = <0x%.8x>\n",
        status));
        return (status);          
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

/*** validatation/advisory information for updatable attributes only ***/
 long _NFMquery_catalog_attributes_u (catalog_name,
				     attr_list, data_list, value_list)
   char     *catalog_name ;
   MEMptr   *attr_list, *data_list, *value_list;
   {
     static char *fname = "_NFMquery_catalog_attributes_w" ;
     long     status;
     long     _NFMget_table_attr ();
     long     _NFMget_data_info ();

     _NFMdebug ((fname, "ENTER\n")) ;

     status = _NFMget_table_attr (catalog_name,  attr_list) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Table attr : status = <0x%.8x>\n, status")) ;
	 return (status) ;
       }
/*
     status = _NFMget_data_value_u (*attr_list, data_list, value_list);
*/
     status = _NFMget_data_value (*attr_list, data_list, value_list,
				  "U", "R");
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        _NFMdebug ((fname, "Get Data Values : status = <0x%.8x>\n",
        status));
        return (status);          
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMget_ris_attributes (catalog_name, attrList)
   char     *catalog_name ;
   MEMptr   *attrList;
   {
     static char *fname = "NFMget_ris_attributes";
     int      i;
     long     status;
     char     sql_str[200];
     char     fmt[20];
     char     **data_ptr;
     MEMptr   buffer = NULL;

     _NFMdebug ((fname, "RIS catalog <%s>\n", catalog_name)) ;

    /*  Format the return buffer */
    status = MEMopen (attrList, MEM_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (attrList);
        _NFMdebug ((fname, "MEMopen = <0x%.8x>\n", status)); 
        ERRload_struct (NFM, NFM_E_MEM, NULL);
        return (status);
    }
    status = MEMwrite_format (*attrList, "attrName", "char(40)");
    if (status != MEM_S_SUCCESS)
    {
         MEMclose (attrList);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Write Format : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);
    }
    status = MEMwrite_format (*attrList, "dataType", "char(20)");
    if (status != MEM_S_SUCCESS)
    {
         MEMclose (attrList);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Write Format : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);
    }

/* MRG Change DBMS TYPE STRING TO RIS_TYPE_STRING */

/* JUJARE - 3 Aug 95
   ris_colums cannot be accessed through RIS interface for RIS 5.0 and later.
   So Changed ris_columns to ris5columns  */

     sprintf (sql_str, "SELECT column_name,ris_type_string,char_max_length FROM ris5columns WHERE table_name = '%s'", catalog_name);
     status = SQLquery (sql_str, &buffer, MEM_SIZE);
     if (status != SQL_S_SUCCESS)
     {
        ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        MEMclose (&buffer);
        _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
                    status));
        return (NFM_E_SQL_QUERY);
     }
     status = MEMbuild_array (buffer);
     if (status != MEM_S_SUCCESS)
     {
         MEMclose (&buffer);
         _NFMdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
         return (status);
     }
     data_ptr = (char**) buffer->data_ptr;

    for (i=0; i<buffer->rows*buffer->columns; i+=buffer->columns)
    {
        if (strcmp(data_ptr[i+1], "char") == 0)
           sprintf (fmt, "char(%s)", data_ptr[i+2]);
        else
	   sprintf (fmt, "%s", data_ptr[i+1]);

     /*  Write row into buffer */
        sprintf (sql_str, "%s\1%s\1", data_ptr[i], fmt);
        status = MEMwrite (*attrList, sql_str);
        if (status != MEM_S_SUCCESS)
        {
            MEMclose (&buffer);
            _NFMdebug ((fname, "MEMwrite = <0x%.8x>\n", status));
            return (status);
        }
     } /* end loop */

     MEMclose (&buffer);
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }
