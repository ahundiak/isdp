#include "machine.h"
#include <ctype.h>
/* #include "NFMdb.h" */
#include "WF.h"

 extern struct WFstruct WFinfo;
 extern struct NFMglobal_st NFMglobal ;

 long WFquery_workflow_transitions (user_id, app_name, workflow_name,
                                    attr_list, data_list, value_list)
   long      user_id;
   char      *app_name;
   char      *workflow_name;
   MEMptr    *attr_list, *data_list, *value_list;
   {
     static char *fname = "WFquery_workflow_transitions" ;
     long     status;
     long     a, b, d, x, y, count;
     long     wf_no;
     MEMptr   list = NULL;
     char     **column, **data;
     char     *sql_str, sql_str1 [1024], value [50];
     long     column_of_valueno;
     long     row_of_comm_no, row_of_from_state ;
     long     row_of_to_state, row_of_wf_no ;

     _NFMdebug ((fname, "App  Name = <%s>  : Wf Name = <%s>\n", 
		 app_name, workflow_name)) ;

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
              "NFMTRANSITIONS", attr_list, data_list, value_list);
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
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
        status));
        return (NFM_E_MEM) ;
      }

     column = (char **) (*attr_list) -> column_ptr;
     data   = (char **) (*attr_list) -> data_ptr;

     a = -1; b = -1; d = -1; column_of_valueno = -1 ;

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
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM) ;
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
     sprintf (sql_str1, " FROM %s WHERE ", "NFMTRANSITIONS");
     count =0;

     row_of_comm_no = -1 ; row_of_from_state = -1;
     row_of_to_state = -1 ; row_of_wf_no = -1 ;

     for (x = 0; x < (*attr_list) -> rows; ++x)
      {
         count = (*attr_list) -> columns * x;
    
         if (! strcmp (data [count + a], "n_workflowno"))
          {
	    row_of_wf_no = x + 1 ;
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
	 else if (! strcmp (data [count + a], "n_commandno"))
	   {
	     row_of_comm_no = x + 1 ;
	   }
	 else if (! strcmp (data [count + a], "n_fromstate"))
	   {
	     row_of_from_state = x + 1 ;
	   }
	 else if (! strcmp (data [count + a], "n_tostate"))
	   {
	     row_of_to_state = x + 1;
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
        _NFMdebug ((fname, "SQL Qry Syntax : status = <0x%.8x>\n", status));
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
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
        return (NFM_E_MEM) ;
      }

     free (sql_str);

     status = MEMbuild_array (*attr_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (value_list);
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
        status));
        return (NFM_E_MEM) ;
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
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Open : status = <0x%.8x>\n", status));
        return (NFM_E_MEM) ;
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
	   ERRload_struct(NFM,status,"",NULL);
           _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>\n",
           status));
           return (NFM_E_MEM) ;
         }
      }

     status = MEMbuild_array (list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
        status));
        return (NFM_E_MEM) ;
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
        return (NFM_E_MALLOC);
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
	   ERRload_struct(NFM,status,"",NULL);
           _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n", status));
           return (NFM_E_MEM) ;
         }
      }

     free (sql_str);

     status = MEMclose (&list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM) ;
      }


     sprintf (sql_str1, "select n_commandno, n_commandname from nfmcommands where n_transcommand = 'Y' and n_application = '%s' order by n_commandno",
	     NFMglobal.application) ;

     status = _NFMadd_to_value_list_from_query (attr_list,
						value_list,
						sql_str1,
						row_of_comm_no,
						column_of_valueno) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Corrupted value buffer : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }

     sprintf (sql_str1, "select n_stateno, n_statename from nfmstates where n_workflowno = %d order by n_stateno",
	      wf_no) ;

     status = _NFMadd_to_value_list_from_query (attr_list,
						value_list,
						sql_str1,
						row_of_from_state,
						column_of_valueno) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Corrupted value buffer : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }

     status = _NFMadd_to_value_list_from_query (attr_list,
						value_list,
						sql_str1,
						row_of_to_state,
						column_of_valueno) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Corrupted value buffer : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }

     strcpy  (sql_str1, "select n_workflowno, n_workflowname from nfmworkflow order by n_workflowno") ;

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

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);      
   }

 long WFupdate_workflow_transitions (user_id, attr_list, data_list)
   long      user_id;
   MEMptr    attr_list, data_list;
   {     
     static char *fname = "WFupdate_workflow_transitions" ;
     long    status;
     long    WFadd_workflow_transitions ();
     long    WFdrop_workflow_transitions ();

     _NFMdebug ((fname, "ENTER\n")) ;
  
     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", 
        status));
        return (NFM_E_MEM) ;
      }

     status = MEMbuild_array (data_list);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", 
        status));
        return (NFM_E_MEM) ;
      }
 
     status = NFMstop_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Stop Trans  : status = <0x%.8x>\n", 
        status));
        return (status);      
      }

     status = WFadd_workflow_transitions (user_id, attr_list, data_list);
     if (status != NFM_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "Add Wf Classes : status = <0x%.8x>\n", 
        status));
        return (status);      
      }

     status = WFdrop_workflow_transitions (user_id, attr_list, data_list);
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
  
 long WFadd_workflow_transitions (user_id, attr_list, data_list)
   long    user_id;
   MEMptr  attr_list, data_list;
   {
     static char *fname = "WFadd_workflow_transitions" ;
     long   status, atol ();
     char   **column, **data, **data1;
     long   a, b, i, x, y, count, count1, comma;
     char   *sql_str, *sql_str1;
     long   trans_no;
     char   entity[20];
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
		    NFM_E_MALLOC));
        return (NFM_E_MALLOC) ;
      }

     sql_str1 = (char *) malloc (data_list -> row_size + MEM_SIZE);
     if (! sql_str1)
      {
        free (sql_str);
        status = NFM_E_MALLOC;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
		    NFM_E_MALLOC));
        return (NFM_E_MALLOC) ;
      }

     for (y = 0; y < data_list -> rows; ++y)
      {
        count1 = data_list -> columns * y;

        NFMchange_case (data1 [count1 + i], 0);

        if (! strcmp (data1 [count1 + i], "ADD"))
         {
           sprintf (sql_str,  "INSERT INTO %s (", "NFMTRANSITIONS");
           sprintf (sql_str1, ") VALUES (");
           comma = 0;

           for (x = 0; x < attr_list -> rows; ++x)
            {
              count = attr_list -> columns * x;

              if (! strcmp (data [count + a], "n_transitionno"))
               {
                 status = NFMget_serial_slot (user_id, "nfmtransitions",
                          data [count + a], &trans_no);
                 if (status != NFM_S_SUCCESS)
                  {
                    free (sql_str);
                    free (sql_str1);
                    _NFMdebug ((fname, "Serial Slot : status = <0x%.8x>\n",
                    status));
                    return (status);
                  }
  
                 sprintf (value, "%d", trans_no);

                 status = MEMwrite_data (data_list, value, y + 1, x + 1);
                 if (status != MEM_S_SUCCESS)
                  {
                    free (sql_str);
                    free (sql_str1);
		    ERRload_struct(NFM,status,"",NULL);
                    _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
				status));
                    return (NFM_E_MEM) ;
                  }
               }
              else if (! strcmp (data [count + a], "n_workflowno"))
               {
                 sprintf (value, "%d", WFinfo.workflow);

                 status = MEMwrite_data (data_list, value, y + 1, x + 1);
                 if (status != MEM_S_SUCCESS)
                  {
                    free (sql_str);
                    free (sql_str1);
		    ERRload_struct(NFM,status,"",NULL);
                    _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
                    status));
                    return (NFM_E_MEM) ;
                  }
               }
              else if (! strcmp (data [count + a], "n_commandno"))
               {
                 status = NFMget_command_entity (user_id,
                         atol (data1 [count1 + x]), entity);
                 if (status != NFM_S_SUCCESS)
                  {
                    free (sql_str);
                    free (sql_str1);
                    _NFMdebug ((fname, "Get Ent : status = <0x%.8x>\n",
                    status));
                    return (status);
                  }

                 if (WFinfo.workflow > 4)
		   {
		     if ((entity [0] != 'N') && (entity [0] != 'I') &&
			 (entity [0] != 'D'))
/*                    if (strcmp(entity,"NFMNOENTITY") && 
                        strcmp(entity,"NFMITEM")) */
                     {
                       free (sql_str);
                       free (sql_str1);
                       status = NFM_E_INVALID_ENTITY;
		       ERRload_struct(NFM,status,"",NULL);
                       _NFMdebug ((fname, "Bad Ent : status = <0x%.8x>\n",
                       status));
                       return (status);
                     }
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
                 status = NFM_E_TRANS_EXISTS;
	ERRload_struct(NFM,status,"",NULL);
                 _NFMdebug ((fname, "Dup Trans : status = <0x%.8x>\n",
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

 long WFdrop_workflow_transitions (user_id, attr_list, data_list)
   long    user_id;
   MEMptr  attr_list, data_list;
   {
     static char *fname = "WFdrop_workflow_transitions" ;
     long   status;

     _NFMdebug ((fname, "ENTER\n")) ;

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long WFload_trans_acc_list (user_id, no_classes,
                             trans_attr, trans_data,
                             access_attr, access_data, inline)
   long     user_id;
   long     no_classes;
   MEMptr   trans_attr, trans_data, access_attr, access_data;
   char     *inline;
   {
     static char *fname = "WFload_trans_acc_list" ;
     long    status, atol ();
     char    *token, *sql_str, *strtok ();
     char    value [50];
     long    x, y, z, count, c, comm_no;
     char    **column, **data;
     long    NFMenter_command ();
     
     _NFMdebug ((fname, "No     Classes : <%d> : Inline <%s>\n", 
		 no_classes, inline));

     if (no_classes < 1)
      {
        status = NFMerror (NFM_E_NO_CLASSES);
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "Bad No Classes : status = <0x%.8x>\n", status));
        return (status);          
      }

     status = MEMbuild_array (trans_attr);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
        status));
        return (NFM_E_MEM) ;
      }

     column = (char **) trans_attr -> column_ptr;
     data   = (char **) trans_attr -> data_ptr;

     for (y = 0; y < trans_attr -> columns; ++y)
       if (! strcmp (column [y], "n_name"))    c = y;

     y = 0;

     sql_str = (char *) malloc (trans_data -> row_size + MEM_SIZE);
     if (! sql_str)
      {
        status = NFM_E_MALLOC;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC));
        return (NFM_E_MALLOC) ;
      }
     sql_str [0] = 0;

     for (x = 0; x < trans_attr -> rows; ++x)
      {
        count = trans_attr -> columns * x;

        _NFMdebug ((fname, "Column Name : <%s>", data [count + c]));

        if (! strcmp (data [count + c], "n_transitionno"));
        else if (! strcmp (data [count + c], "n_workflowno"));
        else if (! strcmp (data [count + c], "n_status"))
           strcat (sql_str, "ADD");
        else
         {
           if (y)     token = strtok (NULL, "|");
           else       token = strtok (inline, "|");
 
           y = 1;

           if (! strcmp (data [count + c], "n_commandno"))
            {
              if (token)
               {
                 for (z = strlen (token); 
                      isspace (token [z - 1]) && z > 0;
                      --z)
                   token [z - 1] = 0;

                 status = NFMget_nfm_command_no (user_id, token,
                          &comm_no);
                 if (status != NFM_S_SUCCESS && 
                     status != NFM_E_BAD_COMMAND)
                  {
                    free (sql_str);
                    _NFMdebug ((fname, "Get Comm No : status = <0x%.8x>\n",
                    status));
                    return (status);          
                  }

                 if (status == NFM_E_BAD_COMMAND)
                  {
		    ERRload_struct( NFM, NFM_S_SUCCESS, NULL, NULL );
                    status = NFMenter_command (user_id, NFMglobal.application,
                             token, &comm_no);
                    if (status != NFM_S_SUCCESS)
                     {
                       free (sql_str);
                       _NFMdebug ((fname, "Ent Comm : status = <0x%.8x>\n",
                       status));
                       return (status);      
                     }
                  }
               }
              else
               {
                 free (sql_str);
                 status = NFM_E_BAD_COMMAND;
	ERRload_struct(NFM,status,"",NULL);
                 _NFMdebug ((fname, "No Comm No : status = <0x%.8x>\n",
                 status));
                 return (status);          
               }

              sprintf (value, "%d", comm_no);

              strcat (sql_str, value);
            }
           else if (token) strcat (sql_str, token);
         }

        strcat (sql_str, "\1");
      }

     _NFMdebug ((fname, "Sql Str : <%s>\n", sql_str));

     status = MEMwrite (trans_data, sql_str);
     if (status != MEM_S_SUCCESS)
      {
        free (sql_str);
	ERRload_struct(NFM,NFM_E_MEM,"",NULL);
        _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
		    status)) ;
	return (NFM_E_MEM) ;
      }

     free (sql_str);

     status = MEMbuild_array (access_attr);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
        status));
        return (NFM_E_MEM) ;
      }

     column = (char **) access_attr -> column_ptr;
     data   = (char **) access_attr -> data_ptr;

     for (y = 0; y < access_attr -> columns; ++y)
       if (! strcmp (column [y], "n_name"))    c = y;

     sql_str = (char *) malloc (access_data -> row_size + MEM_SIZE);
     if (! sql_str)
      {
        status = NFM_E_MALLOC;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC));
        return (status);          
      }
     sql_str [0] = 0;

     for (y = 0; y < no_classes; ++y)
      {
        token = strtok (NULL, "|");

        /* The conditon 'token != NULL' added to avoid SEGV.
           SSRS - 26/11/93
        */
        if (token != NULL && atol (token) > 0)
         {
           sql_str [0] = 0;

           for (x = 0; x < access_attr -> rows; ++x)
            {
              count = access_attr -> columns * x;

              _NFMdebug ((fname, "Column Name : <%s>",
                        data [count + c]));
 
              if (! strcmp (data [count + c], "n_transitionno"))
               {
                 sprintf (value, "%d", trans_data -> rows);
                 strcat (sql_str, value);
               }
              else if (! strcmp (data [count + c], "n_status"))
                 strcat (sql_str, "ADD");
              else
               {
                 if (token) strcat (sql_str, token);
               }

              strcat (sql_str, "\1");
            }

           _NFMdebug ((fname, "Sql Str : <%s>\n", sql_str));

           status = MEMwrite (access_data, sql_str);
           if (status != MEM_S_SUCCESS)
            {
              free (sql_str); 
	      ERRload_struct(NFM,status,"",NULL);
              _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
			  status));
              return (NFM_E_MEM) ;
            }
         }
      }

     free (sql_str);
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);         
   }

 long WFset_transitions (user_id, st_attr, st_data, tr_attr, tr_data)
   long     user_id;
   MEMptr   st_attr, st_data;
   MEMptr   tr_attr, tr_data;
   {
     static char *fname = "WFset_transitions" ;
     long   status, atol ();
     char   **column1, **data1, **data1_1;
     char   **column2, **data2, **data2_2;
     long   x, y, count, i, j, k, c;

     _NFMdebug ((fname, "ENTER\n")) ;

     status = MEMbuild_array (st_attr);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM) ;           
      }

     status = MEMbuild_array (st_data);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM) ;           
      }
     
     status = MEMbuild_array (tr_attr);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
        status));
        return (NFM_E_MEM) ;
      }

     status = MEMbuild_array (tr_data);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct(NFM,NFM_E_MEM,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM) ;           
      }

     column1 = (char **) st_attr -> column_ptr;
     data1   = (char **) st_attr -> data_ptr;

     data1_1 = (char **) st_data -> data_ptr;

     column2 = (char **) tr_attr -> column_ptr;
     data2   = (char **) tr_attr -> data_ptr;

     data2_2 = (char **) tr_data -> data_ptr;

     c = -1; i = -1; j = -1; k = -1;

     for (y = 0; y < tr_attr -> columns; ++y)
        if (! strcmp (column2 [y], "n_name"))   c = y;

     for (x = 0; x < st_attr -> rows; ++x)
      {
        count = st_attr -> columns * x;

        if (! strcmp (data1 [count + c], "n_stateno"))   i = x;
      }

     for (x = 0; x < tr_attr -> rows; ++x)
      {
        count = tr_attr -> columns * x;

             if (! strcmp (data2 [count + c], "n_fromstate"))   j = x;
        else if (! strcmp (data2 [count + c], "n_tostate"))     k = x;
      }


     for (x = 0; x < tr_data -> rows; ++x)
      {
        count = tr_data -> columns * x;

        _NFMdebug ((fname, "From State = <%s>\n", data2_2 [count + j]));

        if (atol (data2_2 [count + j]) > 1)
         {
           status = MEMwrite_data (tr_data,
                    data1_1 [(st_data -> columns * 
                    (atol (data2_2 [count + j]) - 2)) + i],
                    x + 1, j + 1);
           if (status != MEM_S_SUCCESS)
            {
              status = NFM_E_MEM;
	ERRload_struct(NFM,status,"",NULL);
              _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
              status));
              return (NFM_E_MEM) ;
            }
         }

        _NFMdebug ((fname, "To State = <%s>\n", data2_2 [count + k]));

        if (atol (data2_2 [count + k]) > 1)
         {
           status = MEMwrite_data (tr_data,
                    data1_1 [(st_data -> columns * 
                    (atol (data2_2 [count + k]) - 2)) + i],
                    x + 1, k + 1);
           if (status != MEM_S_SUCCESS)
            {
              status = NFM_E_MEM;
	ERRload_struct(NFM,status,"",NULL);
              _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
              status));
              return (NFM_E_MEM) ;
            }
         }
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);     
   }

 long NFMenter_command (user_id, app_name, comm_name, comm_no)
   long    user_id;
   char    *app_name, *comm_name;
   long    *comm_no;
   {
     static char *fname = "NFMenter_command" ;
     long    status;
     MEMptr  attr_list = NULL;
     char    **column, **data;
     char    *sql_str, *sql_str1, value [50];
     long    a, b, x, y, count, comma;

     _NFMdebug ((fname, "App  Name = <%s> : Comm Name = <%s>\n",
		 app_name, comm_name)) ;

     status = NFMquery_attributes_definition (user_id, "NFMSYSTEM",
              "NFMCOMMANDS", &attr_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (&attr_list);
        _NFMdebug ((fname, "Qry Tab Def : status = <0x%.8x>\n",
        status));
        return (status);        
      }

     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&attr_list);
        status = NFM_E_MEM;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM) ;
      }

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     a = -1; b = -1; 

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))       a = y;
        else if (! strcmp (column [y], "n_datatype"))   b = y;
      }

     sql_str = (char *) malloc (attr_list -> rows * 100 + 4 * MEM_SIZE);
     if (! sql_str)
      {
        MEMclose (&attr_list);
        status = NFM_E_MALLOC;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM) ; 
      }

     sql_str1 = (char *) malloc (4 * MEM_SIZE);
     if (! sql_str1)
      {
        free (sql_str);
        MEMclose (&attr_list);
        status = NFM_E_MALLOC;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
		    NFM_E_MALLOC));
        return (NFM_E_MALLOC) ;
      }

     sprintf (sql_str,  "INSERT INTO %s (", "NFMCOMMANDS");
     sprintf (sql_str1, ") VALUES (");
     comma = 0;

     for (x = 0; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;

        if (! strcmp (data [count + a], "n_commandno"))
         {
            status = NFMget_serial_slot (user_id, "nfmcommands",
                     data [count + a], comm_no);
            if (status != NFM_S_SUCCESS)
             {
               free (sql_str);
               free (sql_str1);
               MEMclose (&attr_list);
               _NFMdebug ((fname, "Get Serial Slot : status = <0x%.8x>\n",
               status));
               return (status);      
             }
            
            sprintf (value, "%d", *comm_no);

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
               strcat (sql_str1, value);
               strcat (sql_str1, "'");
             }
            else
               strcat (sql_str1, value);
         }
        else if (! strcmp (data [count + a], "n_commandname"))
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
               strcat (sql_str1, comm_name);
               strcat (sql_str1, "'");
             }
            else
             {
               if (strlen (comm_name))
                 strcat (sql_str1, comm_name);
               else
                 strcat (sql_str1, "null");
             }
         }
        else if (! strcmp (data [count + a], "n_entity"))
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
               strcat (sql_str1, "NFMITEM");
               strcat (sql_str1, "'");
             }
            else
               strcat (sql_str1, "NFMITEM");
         }
        else if (! strcmp (data [count + a], "n_application"))
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
               strcat (sql_str1, app_name);
               strcat (sql_str1, "'");
             }
            else
             {
               if (strlen (app_name))
                 strcat (sql_str1, app_name);
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
        MEMclose (&attr_list);

        if (status  == SQL_E_DUPLICATE_VALUE)
         {
           status = NFM_E_COMMAND_EXISTS;
	ERRload_struct(NFM,status,"",NULL);
           _NFMdebug ((fname, "Comm Exists : status = <0x%.8x>\n", status));
           return (status);      
         }

        status = NFM_E_SQL_STMT;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n", status));
        return (status);      
      }

     free (sql_str);
     free (sql_str1);

     status = MEMclose (&attr_list);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM) ;
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);      
      }
