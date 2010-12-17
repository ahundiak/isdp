#include "machine.h"
/* #include "NFMdb.h" */
#include "WF.h"

 extern struct WFstruct WFinfo;

 long WFquery_workflow_classes (user_id, workflow_name,
                                attr_list, data_list, value_list)
   long      user_id;
   char      *workflow_name;
   MEMptr    *attr_list, *data_list, *value_list;
   {
     static char *fname = "WFquery_workflow_classes" ;
     long     status;
     long     a, b, d, x, y, count;
     long     wf_no;
     MEMptr   list = NULL;
     char     **column, **data;
     char     *sql_str, sql_str1 [1024], value [50];
     long     column_of_valueno, row_of_wf_no ;

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
              "NFMCLASSES", attr_list, data_list, value_list);
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

     a = -1; b = -1; d = -1; column_of_valueno = -1;

     for (y = 0; y < (*attr_list) -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))        a = y;
        else if (! strcmp (column [y], "n_datatype"))    b = y;
        else if (! strcmp (column [y], "n_synonym"))     d = y;
        else if (! strcmp (column [y], "n_valueno")) column_of_valueno = y+1 ;
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
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
        status));
        return (status);
      }

     sprintf (sql_str,  "SELECT ");
     sprintf (sql_str1, " FROM %s WHERE ", "NFMCLASSES");

     count =0; row_of_wf_no = -1 ;
 
     for (x = 0; x < (*attr_list) -> rows; ++x)
      {
         count = (*attr_list) -> columns * x;
    
         if (! strcmp (data [count + a], "n_workflowno"))
          {
	    row_of_wf_no = x + 1;
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

         if (x) strcat (sql_str, ", ");

         strcat (sql_str, data [count + a]);
      }

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
        if (status < MEM_S_SUCCESS)
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
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
        status));
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

     strcpy (sql_str1, "select n_workflowno, n_workflowname from nfmworkflow order by n_workflowno") ;

     status = _NFMadd_to_value_list_from_query (attr_list,
						value_list,
						sql_str1,
						row_of_wf_no,
						column_of_valueno) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Corrupted value buffer : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }



     _NFMdebug ((fname, "SUCCESSFUL\n"));
     return (NFM_S_SUCCESS);      
   }

 long WFupdate_workflow_classes (user_id, attr_list, data_list)
   long      user_id;
   MEMptr    attr_list, data_list;
   {     
     char *fname = "WFupdate_workflow_classes" ;
     long    status;
     long    WFadd_workflow_classes ();
     long    WFdrop_workflow_classes ();

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
 
     status = NFMstop_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Stop Trans  : status = <0x%.8x>\n", 
        status));
        return (status);      
      }

     status = WFadd_workflow_classes (user_id, attr_list, data_list);
     if (status != NFM_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "Add Wf Classes : status = <0x%.8x>\n", status));
        return (status);      
      }

     status = WFdrop_workflow_classes (user_id, attr_list, data_list);
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
  
 long WFadd_workflow_classes (user_id, attr_list, data_list)
   long    user_id;
   MEMptr  attr_list, data_list;
   {
     char *fname = "WFadd_workflow_classes" ;
     long   status;
     char   **column, **data, **data1;
     long   a, b, i, x, y, count, count1, comma;
     char   *sql_str, *sql_str1;
     long   class_no;
     char   value [50];

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
           sprintf (sql_str,  "INSERT INTO %s (", "NFMCLASSES");
           sprintf (sql_str1, ") VALUES (");
           comma = 0;

           for (x = 0; x < attr_list -> rows; ++x)
            {
              count = attr_list -> columns *  x;

              if (! strcmp (data [count + a], "n_classno"))
               {
                 status = NFMget_serial_slot (user_id, "nfmclasses",
                          data [count + a], &class_no);
                 if (status != NFM_S_SUCCESS)
                  {
                    free (sql_str);
                    free (sql_str1);
                    _NFMdebug ((fname, "Ser Slot : status = <0x%.8x>\n",
                    status));
                    return (status);
                  }
  
                 sprintf (value, "%d", class_no);

                 status = MEMwrite_data (data_list, value, y + 1, x + 1);
                 if (status != MEM_S_SUCCESS)  /* DUR 1/7/91 */
                  {
                    free (sql_str);
                    free (sql_str1);
                    status = NFM_E_MEM;
        	    ERRload_struct(NFM,status,"",NULL);
                    _NFMdebug ((fname, "Wr Data : status = <0x%.8x>\n",
                    status));
                    return (status);
                  }
               }
              else if (! strcmp (data [count + a], "n_workflowno"))
               {
                 sprintf (value, "%d", WFinfo.workflow);

                 status = MEMwrite_data (data_list, value, y + 1, x + 1);
                 if (status != MEM_S_SUCCESS)  /* DUR 1/7/91 */
                  {
                    free (sql_str);
                    free (sql_str1);
                    status = NFM_E_MEM;
        	    ERRload_struct(NFM,status,"",NULL);
                    _NFMdebug ((fname, "Wr Data : status = <0x%.8x>\n",
                    status));
                    return (status);
                  }
               }

              if (x != i)
               {
                 if (comma) 
                  {
                    strcat (sql_str,  ", ");
                    strcat (sql_str1, ", ");
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
           if (status != SQL_S_SUCCESS)
            {
              free (sql_str);
              free (sql_str1);

              if (status != SQL_E_DUPLICATE_VALUE)
               {
                 status = NFM_E_CLASS_EXISTS;
                 ERRload_struct(NFM,status,"",NULL);
                 _NFMdebug ((fname, "Dup Class : status = <0x%.8x>\n",
                 status));
                 return (status);
               }

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

 long WFdrop_workflow_classes (user_id, attr_list, data_list)
   long    user_id;
   MEMptr  attr_list, data_list;
   {
     char *fname = "WFdrop_workflow_classes" ;

     _NFMdebug ((fname, "ENTER\n")) ;

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long WFload_classes_list (user_id, attr_list, data_list, inline)
   long     user_id;
   MEMptr   attr_list, data_list;
   char     *inline;
   {
     char *fname = "WFload_classes_list" ;
     long    status;
     char    *sql_str, *token, *strtok ();
     long    x, y, count, c;
     char    **column, **data;
    
     _NFMdebug ((fname, "Inline    : <%s>\n", inline ));

     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
        status = NFM_E_MEM;
        ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <%d>\n",
        status));
        return (status);          
      }

     sql_str = (char *) malloc (data_list -> row_size + MEM_SIZE);
     if (! sql_str)
      {
        status = NFM_E_MALLOC;
        ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
        return (status);          
      }
     sql_str [0] = 0;

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     for (y = 0; y < attr_list -> columns; ++y)
       if (! strcmp (column [y], "n_name"))    c = y;

     y = 0;
      
     for (x = 0; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;

        _NFMdebug ((fname, "Column Name : <%s>", data [count + c]));

        if (! strcmp (data [count + c], "n_classno"));
        else if (! strcmp (data [count + c], "n_workflowno"));
        else if (! strcmp (data [count + c], "n_status"))
          strcat (sql_str, "ADD");
        else
         {
           if (y)     token = strtok (NULL, "|");
           else       token = strtok (inline, "|");
 
           y = 1;

           if (token) strcat (sql_str, token);
         }

        strcat (sql_str, "\1");
      }

     _NFMdebug ((fname, "Sql Str : <%s>", sql_str));
      
     status = MEMwrite (data_list, sql_str);
     if (status != MEM_S_SUCCESS)
      {
        free (sql_str);
        status = NFM_E_MEM;
        ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
        status));
        return (status);          
      }

     free (sql_str);

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);         
   }
