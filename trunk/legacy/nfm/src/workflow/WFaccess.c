#include "machine.h"
#include "WF.h"

 extern struct WFstruct WFinfo;

 long WFquery_workflow_access (user_id, workflow_name,
                                attr_list, data_list, value_list)
   long      user_id;
   char      *workflow_name;
   MEMptr    *attr_list, *data_list, *value_list;
   {
     static char *fname="WFquery_workflow_access" ;
     long     status;
     long     a, b, d, x, y, count;
     long     wf_no;
     MEMptr   list = NULL;
     char     **column, **data;
     char     *sql_str, sql_str1 [1024] ;
     long     column_of_valueno, row_of_class_no, row_of_trans_no;

     _NFMdebug ((fname, "Wf   Name = <%s>\n", workflow_name));

     status = NFMget_workflow_no (user_id, workflow_name, &wf_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Wf No : status = <0x%.8x>\n", status));
        return (status);
      }

     if (WFinfo.workflow != wf_no)
      {
        status = NFM_E_BAD_WORKFLOW;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "Check Wf No : status = <0x%.8x>\n", status));
        return (status);
      }

     status = NFMquery_table_attributes (user_id, "NFMSYSTEM",
              "NFMACCESS", attr_list, data_list, value_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        _NFMdebug ((fname, "Qry Tab Attr : status = <0x%.8x>\n", status));
        return (status);
      }

     status = MEMbuild_array (*attr_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        status = NFM_E_MEM;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
        status));
        return (status);
      }

     column = (char **) (*attr_list) -> column_ptr;
     data   = (char **) (*attr_list) -> data_ptr;

     a = -1; b = -1; d = -1;

     for (y = 0; y < (*attr_list) -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))        a = y;
        else if (! strcmp (column [y], "n_datatype"))    b = y;
        else if (! strcmp (column [y], "n_synonym"))     d = y;
	else if (! strcmp (column [y], "n_valueno"))  column_of_valueno = y+1 ;
      }

     status = MEMclose (data_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (value_list);
        status = NFM_E_MEM;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (status);
      }

     sql_str = (char *) malloc ((*attr_list) -> rows * 50 + 
                        (*attr_list) -> row_size + MEM_SIZE);
     if (! sql_str)
      {
        MEMclose (attr_list);
        MEMclose (value_list);
        status = NFM_E_MALLOC;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
        return (status);
      }

     sprintf (sql_str,  "SELECT ");
     sprintf (sql_str1, " FROM %s, %s WHERE ",
              "NFMACCESS", "NFMTRANSITIONS");
     count = 0 ;
     row_of_trans_no =-1 ; row_of_class_no =-1 ;

     for (x = 0; x < (*attr_list) -> rows; ++x)
      {
         count = (*attr_list) -> columns * x;
    
         if (! strcmp (data [count + a], "n_transitionno"))
          {
	    row_of_trans_no = x + 1;
            strcat (sql_str1, "NFMACCESS.");
            strcat (sql_str1, data [count + a]);
            strcat (sql_str1, " = NFMTRANSITIONS.n_transitionno");
          }
	 else if (! strcmp (data [count + a], "n_classno"))
	   {
	     row_of_class_no = x + 1 ;
	   }

         if (x) strcat (sql_str, ", ");

         strcat (sql_str, "NFMACCESS.");
         strcat (sql_str, data [count + a]);
      }

     strcat (sql_str, sql_str1);

     sprintf (sql_str1, " AND %s = %d", "NFMTRANSITIONS.n_transitionno",
              WFinfo.workflow);

     strcat (sql_str, sql_str1);

     status = SQLquery (sql_str, &list, MEM_SIZE);
     if ((status != SQL_S_SUCCESS) &&
         ((status ) != SQL_I_NO_ROWS_FOUND))
      {
        free (sql_str);
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (value_list);
        status = NFM_E_SQL_QUERY;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "SQL Qry Syntax : status = <0x%.8x>\n",
        status));
        return (status);
      }

     sql_str [0] = 0;

     for (y = 0; y < (*attr_list) -> columns; ++y)
      {
             if (y == a) strcat (sql_str, "n_status");
        else if (y == b) strcat (sql_str, "char(15)");
        else if (y == d) strcat (sql_str, "STATUS");

        strcat (sql_str, "\1");
      }

     status = MEMwrite (*attr_list, sql_str);
     if (status != MEM_S_SUCCESS)
      {
        free (sql_str);
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (value_list);
        status = NFM_E_MEM;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
        return (status);
      }

     free (sql_str);

     status = MEMbuild_array (*attr_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (value_list);
        status = NFM_E_MEM;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
        status));
        return (status);
      }

     column = (char **) (*attr_list) -> column_ptr;
     data   = (char **) (*attr_list) -> data_ptr;

     status = MEMopen (data_list, MEM_SIZE);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        status = NFM_E_MEM;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n", status));
        return (status);
      }

     for (x = 0; x < (*attr_list) -> rows; ++x)
      {
        count = (*attr_list) -> columns * x;

        status = MEMwrite_format (*data_list,
                 data [count + a], data [count + b]);;
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (&list);
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);
           status = NFM_E_MEM;
	ERRload_struct(NFM,status,"",NULL);
           _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
           status));
           return (status);
         }
      }

     status = MEMbuild_array (list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        status = NFM_E_MEM;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
        status));
        return (status);
      }

     data = (char**) list -> data_ptr;

     sql_str = (char *) malloc ((*data_list) -> row_size);
     if (! sql_str)
      {
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        status = NFM_E_MALLOC;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
        return (status);
      }

     for (x = 0; x < list -> rows; ++x)
      {
        count = list -> columns * x;

        sql_str [0] = 0;

        for (y = 0; y < list -> columns; ++y)
         {
            strcat (sql_str, data [count + y]);
            strcat (sql_str, "\1");
         }
 
        strcat (sql_str, "\1");

        status = MEMwrite (*data_list, sql_str);
        if (status != MEM_S_SUCCESS)
         {
           free (sql_str);
           MEMclose (&list);
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (value_list);
           status = NFM_E_MEM;
	ERRload_struct(NFM,status,"",NULL);
           _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
           return (status);
         }
      }

     free (sql_str);

     status = MEMclose (&list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        status = NFM_E_MEM;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (status);
      }

     sprintf (sql_str1, "select n_classno, n_classname from nfmclasses \
where n_workflowno = %d  order by n_classno",
	      wf_no) ;

     status = _NFMadd_to_value_list_from_query (attr_list,
						value_list,
						sql_str1,
						row_of_class_no,
						column_of_valueno) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Corrupted value buffer : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }

     sprintf (sql_str1, "select n_transitionno, n_transitionname from nfmtransitions where n_workflowno = %d order by n_transitionno",
	     WFinfo.workflow) ;

     status = _NFMadd_to_value_list_from_query (attr_list,
						value_list,
						sql_str1,
						row_of_trans_no,
						column_of_valueno) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Corrupted value buffer : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);      
   }

 long WFupdate_workflow_access (user_id, attr_list, data_list)
   long      user_id;
   MEMptr    attr_list, data_list;
   {     
     static char *fname = "WFupdate_workflow_access" ;
     long    status;
     long    a, b, y ;
     char    **column, **data, **data1;
     long    WFadd_workflow_access ();
     long    WFdrop_workflow_access ();

     _NFMdebug ((fname, "ENTER\n")) ;
     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
        status = NFM_E_MEM;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", 
        status));
        return (status);      
      }

     status = MEMbuild_array (data_list);
     if (status != MEM_S_SUCCESS)
      {
        status = NFM_E_MEM;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", 
        status));
        return (status);      
      }

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     data1  = (char **) data_list -> data_ptr;

     a = -1; b = -1; 

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))       a = y;
        else if (! strcmp (column [y], "n_datatype"))   b = y;
      }

     status = NFMstop_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Stop Access  : status = <0x%.8x>\n", 
        status));
        return (status);      
      }

     status = WFadd_workflow_access (user_id, attr_list, data_list);
     if (status != NFM_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "Add Wf Classes : status = <0x%.8x>\n", 
        status));
        return (status);      
      }

     status = WFdrop_workflow_access (user_id, attr_list, data_list);
     if (status != NFM_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "Drop WF Classes : status = <0x%.8x>\n", 
        status));
        return (status);      
      }

/*     status = NFMstart_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Start Transaction : status = <0x%.8x>\n", 
        status));
        return (status);      
      }
*/
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);      
   }
  
 long WFadd_workflow_access (user_id, attr_list, data_list)
   long    user_id;
   MEMptr  attr_list, data_list;
   {
     static char *fname = "WFadd_workflow_access" ;
     long   status;
     char   **column, **data, **data1;
     long   a, b, i, x, y, count, count1, comma;
     char   *sql_str, *sql_str1;

     _NFMdebug ((fname, "ENTER\n")) ;

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     data1  = (char **) data_list -> data_ptr;

     a = -1; b = -1; i = -1;

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))     a = y;
        else if (! strcmp (column [y], "n_datatype")) b = y;
      }

     for (x = 0; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;
  
        if (! strcmp (data [count + a], "n_status"))  i = x;
      }
     
     if (i < 0)
      {
        status = NFM_E_CORRUPTED_BUFFERS;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "Corrupted Buffers : status = <0x%.8x>\n",
        status));
        return (status);
      }

     sql_str = (char *) malloc (attr_list -> rows * 50 +
                                data_list -> row_size + MEM_SIZE);
     if (! sql_str)
      {
        status = NFM_E_MALLOC;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
        status));
        return (status);
      }

     sql_str1 = (char *) malloc (data_list -> row_size + MEM_SIZE);
     if (! sql_str1)
      {
        free (sql_str);
        status = NFM_E_MALLOC;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
        status));
        return (status);
      }

     for (y = 0; y < data_list -> rows; ++y)
      {
        count1 = data_list -> columns * y;

        NFMchange_case (data1 [count1 + i], 0);

        if (! strcmp (data1 [count1 + i], "ADD"))
         {
           sprintf (sql_str,  "INSERT INTO %s (", "NFMACCESS");
           sprintf (sql_str1, ") VALUES (");
           comma = 0;

           for (x = 0; x < attr_list -> rows; ++x)
            {
              count = attr_list -> columns * x;

              if (x != i)
               {
                 if (comma)
                  {
                    strcat (sql_str,  ", ");
                    strcat (sql_str1,  ", ");
                  }
                 comma = 1;

                 strcat (sql_str, data [count + a]);
  
                 if (! strncmp (data [count + b], "char", 4))
                  {
                    strcat (sql_str1, "'");
                    strcat (sql_str1, data1 [count1 + x]);
                    strcat (sql_str1, "'");
                  }
                 else
                  {
                    if (strlen (data1 [count1 + x]))
                       strcat (sql_str1, data1 [count1 + x]);
                    else
                       strcat (sql_str1, "null");
                  }
               }
            }

           strcat (sql_str, sql_str1);
           strcat (sql_str, ")");

           status = SQLstmt (sql_str);
           if ((status != SQL_S_SUCCESS) &&
               (status != SQL_E_DUPLICATE_VALUE))
            {
              free (sql_str);
              free (sql_str1);
              status = NFM_E_SQL_STMT;
	      ERRload_struct(NFM,status,"",NULL);
              _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
              status));
              return (status);
            }
         }
      }

     free (sql_str);
     free (sql_str1);

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long WFdrop_workflow_access (user_id, attr_list, data_list)
   long    user_id;
   MEMptr  attr_list, data_list;
   {
     static char *fname = "WFdrop_workflow_access" ;

     _NFMdebug ((fname, "ENTER\n")) ;

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

long WFset_access (user_id, tr_attr, tr_data, cl_attr, cl_data,
                    ac_attr, ac_data)
   long     user_id;
   MEMptr   tr_attr, tr_data;
   MEMptr   cl_attr, cl_data;
   MEMptr   ac_attr, ac_data;
   {
     static char *fname = "WFset_access" ;
     long    status, atol ();
     char    **column1, **data1, **data1_1;
     char    **column2, **data2, **data2_2;
     char    **column3, **data3, **data3_3;
     long    x, y, count, c, row_no, i, j ;

     _NFMdebug ((fname, "ENTER\n")) ;

     status = MEMbuild_array (tr_attr);
     if (status != MEM_S_SUCCESS)
      {
        status = NFMerror (NFM_E_MEM);
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
        status));
        return (status);     
      }

     status = MEMbuild_array (tr_data);
     if (status != MEM_S_SUCCESS)
      {
        status = NFM_E_MEM;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
        status));
        return (status);     
      }

     status = MEMbuild_array (cl_attr);
     if (status != MEM_S_SUCCESS)
      {
        status = NFM_E_MEM;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
        status));
        return (status);     
      }

     status = MEMbuild_array (cl_data);
     if (status != MEM_S_SUCCESS)
      {
        status = NFM_E_MEM;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
        status));
        return (status);     
      }

     status = MEMbuild_array (ac_attr);
     if (status != MEM_S_SUCCESS)
      {
        status = NFM_E_MEM;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
        status));
        return (status);     
      }

     status = MEMbuild_array (ac_data);
     if (status != MEM_S_SUCCESS)
      {
        status = NFM_E_MEM;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
        status));
        return (status);     
      }

     column1 = (char **) tr_attr -> column_ptr;
     data1   = (char **) tr_attr -> data_ptr;

     data1_1 = (char **) tr_data -> data_ptr;

     column2 = (char **) cl_attr -> column_ptr;
     data2   = (char **) cl_attr -> data_ptr;

     data2_2 = (char **) cl_data -> data_ptr;

     column3 = (char **) ac_attr -> column_ptr;
     data3   = (char **) ac_attr -> data_ptr;

     data3_3 = (char **) ac_data -> data_ptr;

     c = -1; i = -1; j = -1;

     for (y = 0; y < tr_attr -> columns; ++y)
        if (! strcmp (column1 [y], "n_name"))   c = y;

     for (x = 0; x < tr_attr -> rows; ++x)
      {
        count = tr_attr -> columns * x;

        if (! strcmp (data1 [count + c], "n_transitionno"))     i = x;
      }

     for (x = 0; x < ac_attr -> rows; ++x)
      {
        count = ac_attr -> columns * x;

        if (! strcmp (data3 [count + c], "n_transitionno"))   j = x;
      }

     if (i < 0 || j < 0)
      {
        status = NFM_E_CORRUPTED_BUFFERS;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "Corrupted Buffers : status = <0x%.8x>\n",
        status));
        return (status);     
      }

     for (x = 0; x < ac_data -> rows; ++x)
      {
        count = ac_data -> columns * x;

        row_no = atol (data3_3 [count + j]);

        status = MEMwrite_data (ac_data,
                 data1_1 [(tr_data -> columns * (row_no - 1)) + i],
                 x + 1, j + 1);
        if (status != MEM_S_SUCCESS)
         {
           status = NFM_E_MEM;
	   ERRload_struct(NFM,status,"",NULL);
           _NFMdebug ((fname, "MEM Wr data : status = <0x%.8x>\n",
           status));
           return (status);     
         }
      }

     i = -1; j = -1;

     for (x = 0; x < cl_attr -> rows; ++x)
      {
        count = cl_attr -> columns * x;

        if (! strcmp (data2 [count + c], "n_classno"))     i = x;
      }

     for (x = 0; x < ac_attr -> rows; ++x)
      {
        count = ac_attr -> columns * x;

        if (! strcmp (data3 [count + c], "n_classno"))     j = x;
      }

     if (i < 0 || j < 0)
      {
        status = NFM_E_CORRUPTED_BUFFERS;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "Corrupted Buffers : status = <0x%.8x>\n",
        status));
        return (status);     
      }

     for (x = 0; x < ac_data -> rows; ++x)
      {
        count = ac_data -> columns * x;
 
        row_no = atol (data3_3 [count + j]);

        status = MEMwrite_data (ac_data,
                 data2_2 [(cl_data -> columns * (row_no - 1)) + i],
                 x + 1, j + 1);
        if (status != MEM_S_SUCCESS)
         {
           status = NFM_E_MEM;
     	   ERRload_struct(NFM,status,"",NULL);
           _NFMdebug ((fname, "MEM Wr data : status = <0x%.8x>\n",
           status));
           return (status);     
         } 
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);     
   }
