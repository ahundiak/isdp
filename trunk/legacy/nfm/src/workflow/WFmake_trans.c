#include "machine.h"
#include "WF.h"

 extern struct WFstruct WFinfo;
 extern struct NFMglobal_st NFMglobal ;

 long WFquery_override_transition (user_id, attr_list, data_list)
   long   user_id;
   MEMptr *attr_list, *data_list;
   {
     static char *fname = "WFquery_override_transition" ;
     long    status;
     MEMptr  list = NULL, list1 = NULL;
     char    **column, **format, **data;
     char    *sql_str, *sql_str1, *sql_str2, *sql_str3;
     char    value [50];
     long    a, b, d, x, y, count, comma, i =-1;
     long    and1, and2;

     _NFMdebug ((fname, "ENTER\n")) ;

     status = NFMquery_table_definition (user_id, "NFMSYSTEM", "NFMSTATES",
              &list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (&list);
        _NFMdebug ((fname, "Query Table Def : status = <0x%.8x>\n",
        status));
        return (status);
      }

     status = MEMbuild_array (list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
        status));
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        return (NFM_E_MEM);
      }

     column = (char **) list -> column_ptr;
     format = (char **) list -> format_ptr;
     data   = (char **) list -> data_ptr;

     a = -1; b = -1; d = -1;

     status = MEMopen (attr_list, MEM_SIZE);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n",
        status));
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        return (NFM_E_MEM);
      }

     for (y = 0; y < list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))        a = y;
        else if (! strcmp (column [y], "n_datatype"))    b = y;
        else if (! strcmp (column [y], "n_synonym"))     d = y;

        status = MEMwrite_format (*attr_list, column [y], format [y]);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (&list);
           MEMclose (attr_list);
           _NFMdebug ((fname, "MEM Write Format : status = <0x%.8x>\n",
           status));
	   ERRload_struct (NFM, NFM_E_MEM, "", "") ;
           return (NFM_E_MEM);
         }
      }

     status = MEMopen (data_list, MEM_SIZE);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        MEMclose (attr_list);
        _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n",
        status));
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        return (NFM_E_MEM);
      }

     sql_str = (char *) malloc (2 * MEM_SIZE);
     if (! sql_str)
      {
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (data_list);
	status = NFM_E_MALLOC ;
	ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
		  status));
        return (status);
      }

     sql_str1 = (char *) malloc (2 * MEM_SIZE);
     if (! sql_str1)
      {
        free (sql_str);
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (data_list);
	status = NFM_E_MALLOC ;
	ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
		  status));
        return (status);
      }

     sql_str2 = (char *) malloc (MEM_SIZE);
     if (! sql_str2)
      {
        free (sql_str);
        free (sql_str1);
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (data_list);
	status = NFM_E_MALLOC ;
	ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
		  status));
        return (status);
      }

     sql_str3 = (char *) malloc (4 * MEM_SIZE);
     if (! sql_str3)
      {
        free (sql_str);
        free (sql_str1);
        free (sql_str2);
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (data_list);
	status = NFM_E_MALLOC ;
	ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
		  status));
        return (status);
      }

     sprintf (sql_str, "SELECT ");
     sprintf (sql_str1, " FROM %s WHERE ", "NFMSTATES");
     sprintf (sql_str2, " FROM %s WHERE ", "NFMSTATES");

     comma = 0; and1 = 0; and2 = 0;

     for (x = 0; x < list -> rows; ++x)
      {
        count = list -> columns * x;

        if (! strcmp (data [count + a], "n_stateno"))
         {
           if (comma) strcat (sql_str, ", ");
           comma = 1;

           if (and1) strcat (sql_str1, " AND ");
           and1 = 1;

           strcat (sql_str,  data [count + a]);
           strcat (sql_str1, data [count + a]);
           strcat (sql_str1, " = ");
    
           sprintf (value, "%d", WFinfo.curr_state);

           if (! strncmp (data [count + b], "char", 4))
            {
              strcat (sql_str1, "'");
              strcat (sql_str1, value);
              strcat (sql_str1, "'");
            }
           else
              strcat (sql_str1, value);

           sql_str3 [0] = 0;

           for (y = 0; y < list -> columns; ++y)
            {
              strcat (sql_str3, data [count + y]);
              strcat (sql_str3, "\1");
            }

           status = MEMwrite (*attr_list, sql_str3);
           if (status != MEM_S_SUCCESS)
            {
              free (sql_str);
              free (sql_str1);
              free (sql_str2);
              free (sql_str3);
              MEMclose (&list);
              MEMclose (attr_list);
              MEMclose (data_list);
              _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
              status));
	      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
              return (NFM_E_MEM);
            }

           status = MEMwrite_format (*data_list,
                    data [count + a], data [count + b]);
           if (status != MEM_S_SUCCESS)
            {
              free (sql_str);
              free (sql_str1);
              free (sql_str2);
              free (sql_str3);
              MEMclose (&list);
              MEMclose (attr_list);
              MEMclose (data_list);
              _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
              status));
	      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
              return (NFM_E_MEM);
            }
  
	   i = x; 
         }
        else if (! strcmp (data [count + a], "n_statename"))
         {
           if (comma) strcat (sql_str, ", ");
           comma = 1;

           strcat (sql_str, data [count + a]);

           sql_str3 [0] = 0;

           for (y = 0; y < list -> columns; ++y)
            {
              strcat (sql_str3, data [count + y]);
              strcat (sql_str3, "\1");
            }

           status = MEMwrite (*attr_list, sql_str3);
           if (status != MEM_S_SUCCESS)
            {
              free (sql_str);
              free (sql_str1);
              free (sql_str2);
              free (sql_str3);
              MEMclose (&list);
              MEMclose (attr_list);
              MEMclose (data_list);
              _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
              status));
	      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
              return (NFM_E_MEM);
            }

           status = MEMwrite_format (*data_list,
                    data [count + a], data [count + b]);
           if (status != MEM_S_SUCCESS)
            {
              free (sql_str);
              free (sql_str1);
              free (sql_str2);
              free (sql_str3);
              MEMclose (&list);
              MEMclose (attr_list);
              MEMclose (data_list);
              _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
              status));
	      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
              return (NFM_E_MEM);
            }          
         }
        else if (! strcmp (data [count + a], "n_transfrom"))
         {
           if (and1) strcat (sql_str1, " AND ");
           and1 = 1;

           strcat (sql_str1, data [count + a]);
           strcat (sql_str1, " = ");

           if (! strncmp (data [count + b], "char", 4))
            {
              strcat (sql_str1, "'");
              strcat (sql_str1, "Y");
              strcat (sql_str1, "'");
            }
           else 
              strcat (sql_str1, "Y");
         }
        else if (! strcmp (data [count + a], "n_transto"))        
         {
           if (and2) strcat (sql_str2, " AND ");
           and2 = 1;

           strcat (sql_str2, data [count + a]);
           strcat (sql_str2, " = ");

           if (! strncmp (data [count + b], "char", 4))
            {
              strcat (sql_str2, "'");
              strcat (sql_str2, "Y");
              strcat (sql_str2, "'");
            }
           else 
              strcat (sql_str2, "Y");
         }
        else if (! strcmp (data [count + a], "n_workflowno"))        
         {
           if (and2) strcat (sql_str2, " AND ");
           and2 = 1;

           strcat (sql_str2, data [count + a]);
           strcat (sql_str2, " = ");

           sprintf (value, "%d", WFinfo.workflow);

           if (! strncmp (data [count + b], "char", 4))
            {
              strcat (sql_str2, "'");
              strcat (sql_str2, value);
              strcat (sql_str2, "'");
            }
           else 
              strcat (sql_str2, value);
         }
      }

     sql_str3 [0] = 0;

     count = list -> columns * i;

     for (y = 0; y < list -> columns; ++y)
      {
             if (y == a) strcat (sql_str3, "n_status");
        else if (y == b) strcat (sql_str3, "char(15)");
        else if (y == d) strcat (sql_str3, "STATUS"); 
        else             strcat (sql_str3, data [count + y]); 

        strcat (sql_str3, "\1");
      }

     status = MEMwrite (*attr_list, sql_str3);
     if (status != MEM_S_SUCCESS)
      {
        free (sql_str);
        free (sql_str1);
        free (sql_str2);
        free (sql_str3);
        MEMclose (&list);
        MEMclose (&list1);
        MEMclose (attr_list);
        MEMclose (data_list);
        _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
        status));
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        return (NFM_E_MEM);
      }

     status = MEMwrite_format (*data_list, "n_status", "char(15)");
     if (status != MEM_S_SUCCESS)
      {
        free (sql_str);
        free (sql_str1);
        free (sql_str2);
        free (sql_str3);
        MEMclose (&list);
        MEMclose (&list1);
        MEMclose (attr_list);
        MEMclose (data_list);
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
        status));
        return (NFM_E_MEM);
      }          

     sprintf (sql_str3, "%s%s", sql_str, sql_str1);

     free (sql_str1);

     status = SQLquery (sql_str3, &list1, MEM_SIZE);
     if (status != SQL_S_SUCCESS)
      {
        free (sql_str);
        free (sql_str2);
        free (sql_str3);
        MEMclose (&list);
        MEMclose (&list1);
        MEMclose (attr_list);
        MEMclose (data_list);

        if ((status ) == SQL_I_NO_ROWS_FOUND)
         {
	   status = NFM_E_FROM_MAKE_TRANS ;
           ERRload_struct(NFM,status,"",NULL);
           _NFMdebug ((fname, "Not Trans State : status = <0x%.8x>\n",
           status));
           return (status);           
         }

        _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
        status));
        return (NFM_E_SQL_STMT);
      }          

     sprintf (sql_str3, "%s%s", sql_str, sql_str2);

     free (sql_str2);

     status = SQLquery (sql_str3, &list1, MEM_SIZE);
     if (status != SQL_S_SUCCESS)
      {
        free (sql_str);
        free (sql_str3);
        MEMclose (&list);
        MEMclose (&list1);
        MEMclose (attr_list);
        MEMclose (data_list);

        if ((status ) == SQL_I_NO_ROWS_FOUND)
         {
	   status = NFM_E_TO_MAKE_TRANS ;
	   ERRload_struct (NFM, status, "", "") ;
           _NFMdebug ((fname, "Not Trans State : status = <0x%.8x>\n",
           status));
           return (status);           
         }

        _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
        status));
        return (NFM_E_SQL_STMT) ;
      }          

     free (sql_str3);
     free (sql_str);

     status = MEMclose (&list);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        MEMclose (&list1);
        MEMclose (attr_list);
        MEMclose (data_list);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM) ;
      }

     status = MEMbuild_array (list1);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        MEMclose (&list1);
        MEMclose (attr_list);
        MEMclose (data_list);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
        status));
        return (NFM_E_MEM) ;
      }

     data = (char **) list1 -> data_ptr;

     sql_str = (char *) malloc ((*data_list) -> row_size);
     if (! sql_str)
      {
        MEMclose (&list1);
        MEMclose (attr_list);
        MEMclose (data_list);
	status = NFM_E_MALLOC ;
	ERRload_struct (NFM, status, "", "") ;
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
        status));
        return (status);
      }

     for (x = 0; x < list1 -> rows; ++x)
      {
        count = list1 -> columns * x;

        sql_str [0] = 0;

        for (y = 0; y < list1 -> columns; ++y)
         {
           strcat (sql_str, data [count + y]);
           strcat (sql_str, "\1");
         }

        if (! x)  strcat (sql_str, "CURRENT");

        strcat (sql_str, "\1");

        status = MEMwrite (*data_list, sql_str);
        if (status != MEM_S_SUCCESS)
         {
	   ERRload_struct (NFM, NFM_E_MEM, "", "") ;
           free (sql_str);
           MEMclose (&list1);
           MEMclose (attr_list);
           MEMclose (data_list);
           _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
           return (status);
         }
      }

     free (sql_str);

     status = MEMclose (&list1);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        MEMclose (attr_list);
        MEMclose (data_list);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long WFquery_make_transition (user_id, attr_list, data_list)
   long   user_id;
   MEMptr *attr_list, *data_list;
   {
     static char *fname = "WFquery_make_transition" ;
     long    status;
     MEMptr  list = NULL, list1 = NULL, list2 = NULL;
     char    **column, **format, **data;
     char    sql_str [2048], sql_str1 [2048];
     char    sql_str2 [2048], sql_str3 [2048];
     char    value [50];
     long    a, b, d, x, y, count, comma ;
     long    and1, and2;
     long _NFMcheck_item_condition_make_transition () ;
  
     _NFMdebug ((fname, "ENTER\n")) ;
     user_id = user_id ;
     status = _NFMcheck_item_condition_make_transition (WFinfo.catalog_name,
							WFinfo.item_name, 
							WFinfo.item_rev) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }

     status = NFMquery_table_definition (NFMglobal.NFMuserid,
					 "NFMSYSTEM", "NFMSTATES",
              &list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (&list);
        _NFMdebug ((fname, "Query Table Def : status = <0x%.8x>\n",
        status));
        return (status);
      }

     status = MEMbuild_array (list);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        MEMclose (&list);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
        status));
        return (NFM_E_MEM);
      }

     column = (char **) list -> column_ptr;
     format = (char **) list -> format_ptr;
     data   = (char **) list -> data_ptr;

     a = -1; b = -1; d = -1;

     for (y = 0; y < list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))        a = y;
        else if (! strcmp (column [y], "n_datatype"))    b = y;
        else if (! strcmp (column [y], "n_synonym"))     d = y;
      }

     sprintf (sql_str, "SELECT ");
     sprintf (sql_str1, " FROM %s, %s, %s, %s WHERE ",
              "NFMSTATES", "NFMTRANSITIONS", "NFMACLUSERS", "NFMACCESS");
     sprintf (sql_str2, " FROM %s WHERE ", "NFMSTATES");

     comma = 0; and1 = 0; and2 = 0;

     for (x = 0; x < list -> rows; ++x)
      {
        count = list -> columns * x;

        if (! strcmp (data [count + a], "n_stateno"))
         {
           if (comma) strcat (sql_str, ", ");
           comma = 1;

           if (and2) strcat (sql_str2, " AND ");
           and2 = 1;

           strcat (sql_str,  "DISTINCT (NFMSTATES.");

           strcat (sql_str,  data [count + a]);
           strcat (sql_str, ")");
           strcat (sql_str2, data [count + a]);
           strcat (sql_str2, " = ");
    
           sprintf (value, "%d", WFinfo.curr_state);

           if (! strncmp (data [count + b], "char", 4))
            {
              strcat (sql_str2, "'");
              strcat (sql_str2, value);
              strcat (sql_str2, "'");
            }
           else
              strcat (sql_str2, value);
         }
        else if (! strcmp (data [count + a], "n_statename"))
         {
           if (comma) strcat (sql_str, ", ");
           comma = 1;

           strcat (sql_str,  "NFMSTATES.");
           strcat (sql_str, data [count + a]);
         }
        else if (! strcmp (data [count + a], "n_transfrom"))
         {
           if (and2) strcat (sql_str2, " AND ");
           and2 = 1;

           strcat (sql_str2, data [count + a]);
           strcat (sql_str2, " = ");

           if (! strncmp (data [count + b], "char", 4))
            {
              strcat (sql_str2, "'");
              strcat (sql_str2, "Y");
              strcat (sql_str2, "'");
            }
           else 
              strcat (sql_str2, "Y");
         }
        else if (! strcmp (data [count + a], "n_transto"))        
         {
           if (and1) strcat (sql_str1, " AND ");
           and1 = 1;

           strcat (sql_str1, "NFMSTATES.");
           strcat (sql_str1, data [count + a]);
           strcat (sql_str1, " = ");

           if (! strncmp (data [count + b], "char", 4))
            {
              strcat (sql_str1, "'");
              strcat (sql_str1, "Y");
              strcat (sql_str1, "'");
            }
           else 
              strcat (sql_str1, "Y");
         }
        else if (! strcmp (data [count + a], "n_workflowno"))        
         {
           if (and1) strcat (sql_str1, " AND ");
           and1 = 1;

           strcat (sql_str1, "NFMSTATES.");
           strcat (sql_str1, data [count + a]);
           strcat (sql_str1, " = ");

           sprintf (value, "%d", WFinfo.workflow);

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

     sprintf (sql_str3, "%s %s", sql_str, sql_str2);
     _NFMdebug((fname, "NAIDU: sql_str3 = %s\n", sql_str3));

     status = SQLquery (sql_str3, &list1, MEM_SIZE);
     if (status != SQL_S_SUCCESS)
      {
        MEMclose (&list);
        MEMclose (&list1);

        if ((status ) == SQL_I_NO_ROWS_FOUND)
         {
	   status =  NFM_E_NO_TRANSITIONS  ;
           ERRload_struct(NFM,status,"",NULL);
           _NFMdebug ((fname, "Not Trans State : status = <0x%.8x>\n",
           status));
           return (status);           
         }

        _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
        status));
        return (NFM_E_SQL_QUERY) ;
      }          

     strcat (sql_str, sql_str1);
    
     sprintf (sql_str1, " AND %s.%s = %d",
              "NFMACLUSERS", "n_userno", NFMglobal.NFMuserno);

     strcat (sql_str, sql_str1);
    
     sprintf (sql_str1, " AND %s.%s = %d",
              "NFMACLUSERS", "n_aclno", WFinfo.acl);

     strcat (sql_str, sql_str1);

     sprintf (sql_str1, " AND %s.%s =", "NFMACCESS", "n_classno");

     strcat (sql_str, sql_str1);

     sprintf (sql_str1, "%s.%s", "NFMACLUSERS", "n_classno");

     strcat (sql_str, sql_str1);
              
     sprintf (sql_str1, " AND %s.%s = %d",
              "NFMTRANSITIONS", "n_fromstate", WFinfo.curr_state);

     strcat (sql_str, sql_str1);

     sprintf (sql_str1, " AND %s.%s =", "NFMTRANSITIONS", "n_transitionno");

     strcat (sql_str, sql_str1);

     sprintf (sql_str1, "%s.%s", "NFMACCESS", "n_transitionno");

     strcat (sql_str, sql_str1);

     sprintf (sql_str1, " AND %s.%s =", "NFMSTATES", "n_stateno");

     strcat (sql_str, sql_str1);

     sprintf (sql_str1, "%s.%s", "NFMTRANSITIONS", "n_tostate");

     strcat (sql_str, sql_str1);

     _NFMdebug((fname, "NAIDU: sql_str = %s\n", sql_str));
     status = SQLquery (sql_str, &list2, MEM_SIZE);
     if (status != SQL_S_SUCCESS)
      {
        MEMclose (&list);
        MEMclose (&list1);
        MEMclose (&list2);

        if ((status ) == SQL_I_NO_ROWS_FOUND)
         {
	   status = NFM_E_TO_MAKE_TRANS ;
	   ERRload_struct (NFM, status, NULL) ;
           _NFMdebug ((fname, "Not Trans State : status = <0x%.8x>\n",
           status));
           return (status);           
         }

        _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
        status));
        return (NFM_E_SQL_QUERY);
      }          

     status = MEMopen (attr_list, MEM_SIZE);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        MEMclose (&list);
        MEMclose (&list1);
        MEMclose (&list2);
        _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM) ;
      }

     for (y = 0; y < list -> columns; ++y)
      {
        status = MEMwrite_format (*attr_list, column [y], format [y]);
        if (status != MEM_S_SUCCESS)
         {
	   ERRload_struct (NFM, NFM_E_MEM, "", "") ;
           MEMclose (&list);
           MEMclose (&list1);
           MEMclose (&list2);
           MEMclose (attr_list);
           _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
           status));
           return (NFM_E_MEM);
         }
      }

     for (x = 0; x < list -> rows; ++x)
      {
        count = list -> columns * x;

        if ((! strcmp (data [count + a], "n_stateno"))   ||
            (! strcmp (data [count + a], "n_statename")))
         {
           sql_str [0] = 0;

           for (y = 0; y < list -> columns; ++y)
            {
              strcat (sql_str, data [count + y]);
              strcat (sql_str, "\1");
            }

           status = MEMwrite (*attr_list, sql_str);
           if (status != MEM_S_SUCCESS)
            {
	      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
              MEMclose (&list);
              MEMclose (&list1);
              MEMclose (&list2);
              MEMclose (attr_list);
              _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
              status));
              return (NFM_E_MEM);
            }
         }
      }

     for (x = 0; x < list -> rows; ++x)
      {
        count = list -> columns * x;

        if (! strcmp (data [count + a], "n_stateno"))
         {
           sql_str [0] = 0;

           for (y = 0; y < list -> columns; ++y)
            {
              if (y == a)
                strcat (sql_str, "n_status");
              else if (y == b)         
                strcat (sql_str, "char(15)");
              else if (y == d)         
                strcat (sql_str, "STATUS");
              else
                strcat (sql_str, data [count + y]);
              strcat (sql_str, "\1");
            }

           status = MEMwrite (*attr_list, sql_str);
           if (status != MEM_S_SUCCESS)
            {
	      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
              MEMclose (&list);
              MEMclose (&list1);
              MEMclose (&list2);
              MEMclose (attr_list);
              _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
              status));
              return (NFM_E_MEM);
            }
         }
      }

     status = MEMbuild_array (*attr_list);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        MEMclose (&list);
        MEMclose (&list1);
        MEMclose (&list2);
        MEMclose (attr_list);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
        status));
        return (NFM_E_MEM);
      }

     status = MEMopen (data_list, MEM_SIZE);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        MEMclose (&list);
        MEMclose (&list1);
        MEMclose (&list2);
        MEMclose (attr_list);
        _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n",
        status));
        return (NFM_E_MEM);
      }

     data = (char **) (*attr_list) -> data_ptr;

     for (x = 0; x < (*attr_list) -> rows; ++x) 
      {
        count = (*attr_list) -> columns * x;

        status = MEMwrite_format (*data_list, 
                 data [count + a], data [count + b]);
        if (status != MEM_S_SUCCESS)
         {
	   ERRload_struct (NFM, NFM_E_MEM, "", "") ;
           MEMclose (&list);
           MEMclose (&list1);
           MEMclose (&list2);
           MEMclose (attr_list);
           MEMclose (data_list);
           _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
           status));
           return (NFM_E_MEM);
         }
      }

     status = MEMbuild_array (list1);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        MEMclose (&list);
        MEMclose (&list1);
        MEMclose (&list2);
        MEMclose (attr_list);
        MEMclose (data_list);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
        status));
        return (NFM_E_MEM);
      }

     data = (char **) list1 -> data_ptr;

     sql_str [0] = 0;

     for (y = 0; y < list1 -> columns; ++y) 
      {
        strcat (sql_str, data [y]);
        strcat (sql_str, "\1");
      }

     strcat (sql_str, "CURRENT STATE");
     strcat (sql_str, "\1");

     status = MEMwrite (*data_list, sql_str);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        MEMclose (&list);
        MEMclose (&list1);
        MEMclose (&list2);
        MEMclose (attr_list);
        MEMclose (data_list);
        _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
        status));
        return (NFM_E_MEM);
      }

     status = MEMbuild_array (list2);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        MEMclose (&list);
        MEMclose (&list1);
        MEMclose (&list2);
        MEMclose (attr_list);
        MEMclose (data_list);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
        status));
        return (NFM_E_MEM);
      }

     data = (char **) list2 -> data_ptr;

     for (x = 0; x < list2 -> rows; ++x)
      {
        count = list2 -> columns * x;
        sql_str [0] = 0;

        for (y = 0; y < list2 -> columns; ++y) 
         {
           strcat (sql_str, data [count + y]);
           strcat (sql_str, "\1");
         }
        strcat (sql_str, "\1");

        status = MEMwrite (*data_list, sql_str);
        if (status != MEM_S_SUCCESS)
         {
	   ERRload_struct (NFM, NFM_E_MEM, "", "") ;
           MEMclose (&list);
           MEMclose (&list1);
           MEMclose (&list2);
           MEMclose (attr_list);
           MEMclose (data_list);
           _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
           status));
           return (NFM_E_MEM);
         }
      }

     status = MEMclose (&list);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        MEMclose (&list1);
        MEMclose (&list2);
        MEMclose (attr_list);
        MEMclose (data_list);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     status = MEMclose (&list1);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        MEMclose (&list2);
        MEMclose (attr_list);
        MEMclose (data_list);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     status = MEMclose (&list2);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        MEMclose (attr_list);
        MEMclose (data_list);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

 long WFmake_transition (user_id, attr_list, data_list)
   long     user_id;
   MEMptr   attr_list, data_list; 
   {
     static char *fname = "WFmake_transition" ;
     long     status, atol ();
     long     x, y, a, b, i, j, count;
     char     **column, **data, **data1;
     long _NFMcheck_item_condition_make_transition () ;
     struct WFstruct WFinfo2;
     MSGptr app_ptr  ;

     long curstate, nextstate,foundflag ;

     _NFMdebug ((fname, "ENTER\n")) ;

/* init curstate and tostate */

     curstate= nextstate = -1 ;
     foundflag = 0;
     user_id = user_id ;
     status = _NFMcheck_item_condition_make_transition (WFinfo.catalog_name,
							WFinfo.item_name, 
							WFinfo.item_rev) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }

     status = WFcheck_signoff (NFMglobal.NFMuserid) ;
     if (status != NFM_S_SUCCESS)
       {
       _NFMdebug ((fname, "WFcheck_signoff : status = <0x%.8x>", status) );
	   return (status) ;
       }

     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     status = MEMbuild_array (data_list);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;
   
     data1  = (char **) data_list -> data_ptr;

     a = -1; b = -1; 

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))        a = y;
        else if (! strcmp (column [y], "n_datatype"))    b = y;
      }

     i = -1;  j = -1;

     for (x = 0; x < attr_list -> rows; ++x)
      {
         count = attr_list -> columns * x;

              if (! strcmp (data [count + a], "n_status"))   i = x;
         else if (! strcmp (data [count + a], "n_stateno"))  j = x;
      }
/* Only one  current state and one next state is VALID */


     for (x = 0; x < data_list -> rows && foundflag < 2; ++x)
      {
        count = data_list -> columns * x;
 
        NFMupper_case (data1 [count + i], data1 [count+i]) ;

        if (! strcmp (data1 [count + i], "NEXT"))
	{
           nextstate = atol (data1 [count + j]);
	   foundflag++;
	}
        else if (! strncmp (data1 [count + i], "CURRENT", 7))
	{
           curstate = atol (data1 [count + j]);
	   foundflag++;
	}
      }
      if(foundflag >= 2 )
      {
/* Retrieve transition for this workflow, curstate, nextstate */
/* Retrieve transition name , transitionno , commandname , commandno 
   current state name  */
	   status = WFcopy_workflow_structure(65535,0,&WFinfo2);
	   status = WFload_wf_struct_using_from_and_to_state (curstate,nextstate);
	   if(status != NFM_S_SUCCESS)
	   {
		_NFMdebug((fname,"WFinfo load using from state and to state \
failed from state <%d> to state <%d> status <0x%.8x>\n",curstate,nextstate,status));
	   	WFcopy_workflow_structure(65535,1,&WFinfo2);
		return(status);
	   }

	   status = NFMpre_execute_process ( WFinfo.transition);
	   if(status != NFM_S_SUCCESS)
	   {
		_NFMdebug((fname,"Pre execute process failed for command <%s>\
 status <0x%.8x>\n",WFinfo.command_name,status));
	   	WFcopy_workflow_structure(65535,1,&WFinfo2);
		return(status);
	   }
/* THIS WILL BE DONE IN WFset_wf_state 
	   status = NFMpost_execute_process ( WFinfo.transition ,  app_ptr);
	   if(status != NFM_S_SUCCESS)
	   {
		_NFMdebug((fname,"Post execute process failed for command <%s>\
 status <0x%.8x>\n",WFinfo.command_name,status));
	   	WFcopy_workflow_structure(65535,1,&WFinfo2);
		return(status);
	   }
*/
		

      }
      else
      {
	_NFMdebug((fname,"Current state or from state missing current_state <%d>\
 next state <%d>\n",curstate,nextstate));
	ERRload_struct(NFM,NFM_E_INCOMPLETE_TRANSITION,"%d%d",curstate,nextstate);
	return(NFM_E_INCOMPLETE_TRANSITION);
      }

     status = WFhistory_signoff (NFMglobal.NFMuserid) ;
     if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Stamp History Signoff : status : <0x%.8x>\n",
                   status));
         return (status) ;
       }


     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }



/* item has to be checked in, not a set, not a member of set, 
   not a member of project */
long _NFMcheck_item_condition_make_transition (catalog_name,
					       item_name, item_rev)
     char *catalog_name ;
     char *item_name ;
     char *item_rev ;
{
  char *fname = "_NFMcheck_item_conditon_make_transition" ;
  MEMptr sql_buffer = NULL ;
  long status ;
  char **data ;
  char sql_str [1024];

  sprintf (sql_str, "select n_status, n_archivestate, n_pendingflag, n_itemlock from %s where n_itemname = '%s' and n_itemrev = '%s'",
	   catalog_name, item_name, item_rev) ;
  
  status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
  if (status != SQL_S_SUCCESS)
    {
      if (status == SQL_I_NO_ROWS_FOUND)
	{
	  _NFMdebug ((fname, "Bad item : cat %s : item %s : rev %s\n",
		      catalog_name, item_name, item_rev)) ;
	  ERRload_struct (NFM, NFM_E_BAD_ITEM, "", "") ;
	  return (NFM_E_BAD_ITEM) ;
	}

      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
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

/* checked in ?? */  
  if ((strcmp (data [0], "I")) && (strcmp (data [0], "")))
    {
      _NFMdebug ((fname, "Item is not checked in\n")) ;
      MEMclose (&sql_buffer) ;
      ERRload_struct (NFM, NFM_E_ITEM_OUT, "%s", item_name) ;
      return (NFM_E_ITEM_OUT) ;
    }
/* archived ?? */
  else if (strcmp (data [1], ""))
   {
     if (strcmp (data [1], "A") == 0)
       {
	 _NFMdebug ((fname, "Item is archived\n")) ;
	 MEMclose (&sql_buffer) ;
	 ERRload_struct (NFM, NFM_E_ITEM_ARCHIVED, "%s", item_name) ;
	 return (NFM_E_ITEM_ARCHIVED) ;
       }
   }
/* flagged ?? */
  else  if (strcmp (data [2], ""))
    {
	 MEMclose (&sql_buffer) ;
	 ERRload_struct (NFM, NFM_E_ITEM_FLAGGED, "%s", item_name) ;
	 _NFMdebug ((fname, "Item is flagged\n")) ;
	 return (NFM_E_ITEM_FLAGGED) ;
    }
/* locked ?? */
  else if ((strcmp (data [3], "N")) && (strcmp (data [3], "")))
    {
      MEMclose (&sql_buffer) ;
      ERRload_struct (NFM, NFM_E_ITEM_LOCKED, "", "") ;
      _NFMdebug ((fname, "Item is locked\n")) ;
      return (NFM_E_ITEM_LOCKED) ;
    }

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


