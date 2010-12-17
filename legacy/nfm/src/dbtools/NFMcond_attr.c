#include "machine.h"
#include "DBTOOLS.h"

  extern struct NFMglobal_st NFMglobal ;

 long NFMquery_condition_definition (user_id, table_type, table_name,
                                     table_str, cond_str, attr_list)
   long     user_id;
   char     *table_type, *table_name;
   char     *table_str, *cond_str;
   MEMptr   *attr_list;
   {
     static char *fname = "NFMquery_condition_definition" ;
     long     status;
     char     **column, **data;
     long     x, y, a, z;
     char     sql_str [1024];
     long     table_no;
     long     NFMget_table_attr ();
     long     NFMget_systable_attr ();
 
     _NFMdebug ((fname, "Table Type  = <%s> : Table Name = <%s> : Table Str = <%s> : Cond Str = <%s>\n", 
		 table_type, table_name, table_str, cond_str));

     z = 0;

     if (*attr_list)

      {
         status = MEMbuild_array (*attr_list);
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
			status));
            return (NFM_E_MEM);          
          }

         z = (*attr_list) -> rows;
      }
     
     if (! strlen (table_str))
      {

        status = NFMget_table_no (user_id, table_type, table_name,
                 &table_no);
        if (status != NFM_S_SUCCESS)
         {
           _NFMdebug ((fname, "Get Table No : status = <0x%.8x>\n",
           status));
           return (status);          
         }

        sprintf (sql_str, "n_tableno = %d", table_no);
      }
     else
        sprintf (sql_str, "%s", table_str);

     if (strcmp (table_type, "nfmsystem") == 0)
       {
	 status = NFMget_systable_attr (user_id, sql_str, cond_str, attr_list);
	 if (status != NFM_S_SUCCESS)
	   {
	     MEMclose (attr_list);
	     _NFMdebug ((fname, "Get Tab Attr : status = <0x%.8x>\n",
			 status));
	     return (status);          
	   }
       }
     else
       {
	 status = NFMget_table_attr (user_id, sql_str, cond_str, attr_list);
	 if (status != NFM_S_SUCCESS)
	   {
	     MEMclose (attr_list);
	     _NFMdebug ((fname, "Get Tab Attr : status = <0x%.8x>\n",
			 status));
	     return (status);          
	   }
       }

     status = MEMbuild_array (*attr_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);          
      }

     column = (char **) (*attr_list) -> column_ptr;
     data   = (char **) (*attr_list) -> data_ptr;

     a = -1;

     for (y = 0; y < (*attr_list) -> columns; ++y)
       if (! strcmp (column [y], "n_valueno"))   a = y;

     for (x = z; x < (*attr_list) -> rows; ++x)
      {
        status = MEMwrite_data (*attr_list, "0", x + 1, a + 1);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (attr_list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _NFMdebug ((fname, "MEM Write Data : status = <0x%.8x>\n",
		       status));
           return (NFM_E_MEM);          
         }
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMquery_condition_attributes (user_id, table_type, table_name, 
                                     table_str, cond_str,
                                     attr_list, data_list, value_list)
   long     user_id;
   char     *table_type, *table_name;
   char     *table_str, *cond_str;
   MEMptr   *attr_list, *data_list, *value_list;
   {
     static char *fname = "NFMquery_condition_attributes" ;
     long     status;
     char     sql_str [1024];
     long     table_no;
     long     NFMget_table_attr ();
     long     NFMget_systable_attr ();

     _NFMdebug ((fname, "Table Type = <%s> :Table Name = <%s> : Table Str = <%s> : Cond Str = <%s>\n", 
		 table_type, table_name, table_str, cond_str));
    
     if (! strlen (table_str))
      {
        status = NFMget_table_no (user_id, table_type, table_name,
                 &table_no);
        if (status != NFM_S_SUCCESS)
         {
           _NFMdebug ((fname, "Get Table No : status = <0x%.8x>\n",
           status));
           return (status);          
         }

        sprintf (sql_str, "n_tableno = %d", table_no);
      }
     else
        sprintf (sql_str, "%s", table_str);

     if (strcmp (table_type, "nfmsystem") == 0)
       {
	 status = NFMget_systable_attr (user_id, sql_str, cond_str, attr_list);
	 if (status != NFM_S_SUCCESS)
	   {
	     MEMclose (attr_list);
	     MEMclose (data_list);
	     MEMclose (value_list);
	     _NFMdebug ((fname, "Get Tab Attr : status = <0x%.8x>\n",
			 status));
	     return (status);          
	   }
       }
     else
       {
	 status = NFMget_table_attr (user_id, sql_str, cond_str, attr_list);
	 if (status != NFM_S_SUCCESS)
	   {
	     MEMclose (attr_list);
	     MEMclose (data_list);
	     MEMclose (value_list);
	     _NFMdebug ((fname, "Get Tab Attr : status = <0x%.8x>\n",
			 status));
	     return (status);          
	   }
       }
/*
     status = NFMget_data_value (user_id,
              *attr_list, data_list, value_list);
*/
     status = _NFMget_data_value (*attr_list, data_list, 
				  value_list,"A","R");
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

 long NFMquery_condition_attributes_value2 (user_id, table_type, table_name, 
					    table_str, cond_str,
					    attr_list, data_list, value_list)
   long     user_id;
   char     *table_type, *table_name;
   char     *table_str, *cond_str;
   MEMptr   *attr_list, *data_list, *value_list;
   {
     static char *fname = "NFMquery_condition_attributes_value2" ;
     long     status;
     char     sql_str [1024];
     long     table_no;
     long     NFMget_table_attr ();
     long     NFMget_systable_attr ();

     _NFMdebug ((fname, "Table Type = <%s> :Table Name = <%s> : Table Str = <%s> : Cond Str = <%s>\n", 
		 table_type, table_name, table_str, cond_str));
    
     if (! strlen (table_str))
      {
        status = NFMget_table_no (user_id, table_type, table_name,
                 &table_no);
        if (status != NFM_S_SUCCESS)
         {
           _NFMdebug ((fname, "Get Table No : status = <0x%.8x>\n",
           status));
           return (status);          
         }

        sprintf (sql_str, "n_tableno = %d", table_no);
      }
     else
        sprintf (sql_str, "%s", table_str);

     if (strcmp (table_type, "nfmsystem") == 0)
       {
	 status = NFMget_systable_attr (user_id, sql_str, cond_str, attr_list);
	 if (status != NFM_S_SUCCESS)
	   {
	     MEMclose (attr_list);
	     MEMclose (data_list);
	     MEMclose (value_list);
	     _NFMdebug ((fname, "Get Tab Attr : status = <0x%.8x>\n",
			 status));
	     return (status);          
	   }
       }
     else
       {
	 status = NFMget_table_attr (user_id, sql_str, cond_str, attr_list);
	 if (status != NFM_S_SUCCESS)
	   {
	     MEMclose (attr_list);
	     MEMclose (data_list);
	     MEMclose (value_list);
	     _NFMdebug ((fname, "Get Tab Attr : status = <0x%.8x>\n",
			 status));
	     return (status);          
	   }
       }

/*
     status = NFMget_data_value2 (user_id,
              *attr_list, data_list, value_list);
*/
     status = _NFMget_data_value (*attr_list, data_list, value_list,
				  "A", "R");
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

 long NFMquery_condition_information (user_id, table_type, table_name, 
                                      table_str, cond_str,
                                      attr_list, data_list, value_list)
   long     user_id;
   char     *table_type, *table_name;
   char     *table_str, *cond_str;
   MEMptr   *attr_list, *data_list, *value_list;
   {
     static char *fname = "NFMquery_condition_information" ;
     long     status;
     char     sql_str [1024];
     long     table_no;
     long     NFMget_table_attr ();
     long     NFMget_systable_attr ();
     long     _NFMget_data_info ();

     _NFMdebug ((fname, "Table Type = <%s> : Table Name = <%s> : Table Str = <%s> : Cond Str = <%s> \n", 
		 table_type, table_name, table_str, cond_str));
    
     if (! strlen (table_str))
      {
        status = NFMget_table_no (user_id, table_type, table_name,
                 &table_no);
        if (status != NFM_S_SUCCESS)
         {
           _NFMdebug ((fname, "Get Table No : status = <0x%.8x>\n",
           status));
           return (status);          
         }
        sprintf (sql_str, "n_tableno = %d", table_no);
      }
     else
        sprintf (sql_str, "%s", table_str);

     if (strcmp (table_type, "nfmsystem") == 0)
       {
	 status = NFMget_systable_attr (user_id, sql_str, cond_str, attr_list);
	 if (status != NFM_S_SUCCESS)
	   {
	     MEMclose (attr_list);
	     MEMclose (data_list);
	     MEMclose (value_list);
	     _NFMdebug ((fname, "Tab Attr : status = <0x%.8x>\n", status));
	     return (status);          
	   }
       }
     else
       {
	 status = NFMget_table_attr (user_id, sql_str, cond_str, attr_list);
	 if (status != NFM_S_SUCCESS)
	   {
	     MEMclose (attr_list);
	     MEMclose (data_list);
	     MEMclose (value_list);
	     _NFMdebug ((fname, "Tab Attr : status = <0x%.8x>\n", status));
	     return (status);          
	   }
       }
     status = _NFMget_data_info (*attr_list, data_list, value_list);
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

 long NFMquery_change_condition_information (user_id,
                       table_type, table_name,
                       table_str, cond_str, 
                       attr_list, data_list, value_list)
   long     user_id;
   char     *table_type, *table_name;
   char     *table_str, *cond_str;
   MEMptr   *attr_list, *data_list, *value_list;
   {
     static char *fname = "NFMquery_change_condition_information" ;
     long     status;
     MEMptr   temp_attr = NULL, temp_data = NULL, temp_value = NULL;
     long     NFMmerge_change_attributes ();

     _NFMdebug ((fname, "Table Type = <%s> : Table Name = <%s> : Table Str = <%s> : Cond Str = <%s>\n", 
		 table_type, table_name, table_str, cond_str));

     user_id = user_id ;
     status = NFMquery_condition_information (NFMglobal.NFMuserid,
              table_type, table_name, table_str, cond_str,
              &temp_attr, &temp_data, &temp_value);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (&temp_attr);
        MEMclose (&temp_data);
        MEMclose (&temp_value);

        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);

        _NFMdebug ((fname, "Query Cond Info : status = <0x%.8x>\n",
        status));
        return (status);          
      }

     status = NFMmerge_change_attributes (NFMglobal.NFMuserid,
              temp_attr, temp_data, temp_value,
              attr_list, data_list, value_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (&temp_attr);
        MEMclose (&temp_data);
        MEMclose (&temp_value);

        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);

        _NFMdebug ((fname, "Mer ModTabAttr : status = <0x%.8x>\n",
        status));
        return (status);          
      }

     status = MEMclose (&temp_attr);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&temp_data);
        MEMclose (&temp_value);

        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);

            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);          
      }

     status = MEMclose (&temp_data);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&temp_value);

        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
	ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);          
      }

     if (temp_value)
      {
        status = MEMclose (&temp_value);
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
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }
