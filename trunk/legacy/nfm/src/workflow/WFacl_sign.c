#include "machine.h"
#include "WF.h"

 extern struct WFstruct WFinfo;

 long WFquery_acl_signoff_users (user_id, acl_name,
                                 attr_list, data_list, value_list)
   long      user_id;
   char      *acl_name;
   MEMptr    *attr_list, *data_list, *value_list;
   {
     static char *fname = "WFquery_acl_signoff_users" ;
     long     status;
     long     a, b, d, x, y, count;
     long     wf_no, acl_no;
     MEMptr   list = NULL;
     char     **column, **data;
     char     *sql_str, sql_str1 [1024], value [50];
     long     column_of_valueno, row_of_acl_no, row_of_state_no,row_of_user_no;

     _NFMdebug ((fname, "Acl  Name = <%s>\n", acl_name));

     status = NFMget_acl_no (user_id, acl_name, &acl_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Acl No : status = <0x%.8x>\n", status));
        return (status);
      }

     WFinfo.acl = acl_no;

     status = NFMget_acl_workflow_no (user_id, acl_no, &wf_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Acl Wf No : status = <0x%.8x>\n",
        status));
        return (status);
      }

     WFinfo.workflow = wf_no;

     status = NFMquery_table_attributes (user_id, "NFMSYSTEM",
              "NFMSIGNOFFUSERS", attr_list, data_list, value_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        _NFMdebug ((fname, "Qry Tab Attr : status = <0x%.8x>\n",
        status));
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

     a = -1; b = -1; d = -1; column_of_valueno =-1 ;

     for (y = 0; y < (*attr_list) -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))        a = y;
        else if (! strcmp (column [y], "n_datatype"))    b = y;
        else if (! strcmp (column [y], "n_synonym"))     d = y;
	else if (! strcmp (column [y], "n_valueno")) column_of_valueno =y+1 ;
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
     sprintf (sql_str1, " FROM %s WHERE ", "NFMSIGNOFFUSERS");
     count =0 ; row_of_acl_no =-1 ;
     row_of_state_no = -1; row_of_user_no = -1;

     for (x = 0; x < (*attr_list) -> rows; ++x)
      {
         count = (*attr_list) -> columns * x;
    
         if (! strcmp (data [count + a], "n_aclno"))
          {
	    row_of_acl_no = x + 1;
            strcat (sql_str1, data [count + a]);
            strcat (sql_str1, " = ");
      
            sprintf (value, "%d", WFinfo.acl);

            if (! strncmp (data [count + b], "char", 4))
             {
               strcat (sql_str1, "'");
               strcat (sql_str1, value);
               strcat (sql_str1, "'");
             }
            else
               strcat (sql_str1, value);
          }
	 else if (! strcmp (data [count + a], "n_stateno"))
	   {
	     row_of_state_no = x + 1;
	   }
	 else if (! strcmp (data [count + a], "n_userno"))
	   {
	     row_of_user_no = x + 1;
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
           _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
           status));
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

     sprintf (sql_str1, "select nfmacls.n_aclno, nfmworkflow.n_workflowname, nfmacls.n_aclname from nfmacls, nfmworkflow \
where nfmworkflow.n_workflowno = nfmacls.n_workflowno and \
nfmacls.n_aclno = %d",
	     acl_no) ;

     status = _NFMadd_to_value_list_from_query (attr_list,
						value_list,
						sql_str1,
						row_of_acl_no,
						column_of_valueno) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Corrupted value buffer : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }

     sprintf (sql_str1, "select n_stateno, n_statename, n_signoffs from nfmstates where n_workflowno = %d and n_signoffs > 0 order by n_stateno",
	     wf_no) ;

     status = _NFMadd_to_value_list_from_query (attr_list,
						value_list,
						sql_str1,
						row_of_state_no,
						column_of_valueno) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Corrupted value buffer : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }

     strcpy (sql_str1, "select n_userno, n_username from nfmusers order by n_userno") ;

     status = _NFMadd_to_value_list_from_query (attr_list,
						value_list,
						sql_str1,
						row_of_user_no,
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

 long WFupdate_acl_signoff_users (user_id, attr_list, data_list)
   long      user_id;
   MEMptr    attr_list, data_list;
   {     
     static char *fname = "WFupdate_acl_signoff_users" ;
     long    status;
     long    wf_no;
     long    WFadd_acl_signoff_users ();
     long    WFdrop_acl_signoff_users ();

     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
        status = NFM_E_MEM;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array: status = <0x%.8x>\n", 
        status));
        return (status);      
      }

     status = MEMbuild_array (data_list);
     if (status != MEM_S_SUCCESS)
      {
        status = NFM_E_MEM;
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array: status = <0x%.8x>\n", 
        status));
        return (status);      
      }
 
     status = NFMstop_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Stop Transaction  : status = <0x%.8x>\n", 
        status));
        return (status);      
      }

     status = WFadd_acl_signoff_users (user_id, attr_list, data_list);
     if (status != NFM_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "Add Acl Sign Users : status = <0x%.8x>\n", 
        status));
        return (status);      
      }

     status = WFdrop_acl_signoff_users (user_id, attr_list, data_list);
     if (status != NFM_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "Drop Acl Sign Usrs : status = <0x%.8x>\n", 
        status));
        return (status);      
      }

     status = NFMget_acl_workflow_no (user_id, WFinfo.acl, &wf_no);
     if (status != NFM_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "Get Acl WF No : status = <0x%.8x>\n", 
        status));
        return (status);      
      }
    
     status = WFcheck_acl_complete (wf_no, WFinfo.acl);
     if (status != NFM_E_ACL_COMPLETE     &&
         status != NFM_E_ACL_NOT_COMPLETE)
      {
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "Check Acl Usable  : status = <0x%.8x>\n", 
        status));
        return (status);      
      }

     ERRreset_struct () ;

     if (status == NFM_E_ACL_COMPLETE)
      {
         status = WFenter_acl_complete (user_id);
         if (status != NFM_S_SUCCESS)
          {
            NFMrollback_transaction (0);
            _NFMdebug ((fname, "Acl Usable  : status = <0x%.8x>\n", 
            status));
            return (status);      
          }
      }
     else if (status != NFM_E_ACL_NOT_COMPLETE)
      {
         status = WFenter_acl_not_complete (user_id);
         if (status != NFM_S_SUCCESS)
          {
            NFMrollback_transaction (0);
            _NFMdebug ((fname, "Acl Not Usble  : status = <0x%.8x>\n", 
            status));
            return (status);      
          }
      }

     status = WFcheck_workflow_usable (user_id, wf_no);
     if (status != NFM_E_WORKFLOW_USABLE     &&
         status != NFM_E_WORKFLOW_NOT_USABLE)
      {
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "Check WF Usable  : status = <0x%.8x>\n", 
        status));
        return (status);      
      }

     ERRreset_struct () ;

     if (status == NFM_E_WORKFLOW_USABLE)
      {
        status = WFenter_workflow_usable (user_id, wf_no);
        if (status != NFM_S_SUCCESS)
         {
           NFMrollback_transaction (0);
           _NFMdebug ((fname, "WF Usable  : status = <0x%.8x>\n", 
           status));
           return (status);      
         }
      }
     else if (status == NFM_E_WORKFLOW_NOT_USABLE)
      {
        status = WFenter_workflow_not_usable (user_id, wf_no);
        if (status != NFM_S_SUCCESS)
         {
           NFMrollback_transaction (0);
           _NFMdebug ((fname, "WF Not Usable  : status = <0x%.8x>\n", 
           status));
           return (status);      
         }
      }

     status = NFMstart_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Start Transaction  : status = <0x%.8x>\n", 
        status));
        return (status);      
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);      
   }

 long WFadd_acl_signoff_users (user_id, attr_list, data_list)
   long    user_id;
   MEMptr  attr_list, data_list;
   {
     static char *fname = "WFadd_acl_signoff_users" ;
     long   status;
     char   **column, **data, **data1;
     long   a, b, i, j, x, y, count, count1, comma;
     char   *sql_str, *sql_str1;
     char   value [50];

     _NFMdebug ((fname, "ENTER\n")) ;
     user_id = user_id ;
     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     data1  = (char **) data_list -> data_ptr;

     a = -1; b = -1; i = -1; j = -1;

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))     a = y;
        else if (! strcmp (column [y], "n_datatype")) b = y;
      }


     for (x = 0; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;
 
        if (! strcmp (data [count + a], "n_status"))  i = x;
        if (! strcmp (data [count + a], "n_override"))    j = x;
      }
     
     if (i < 0 || j < 0)
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

     sprintf (value, "%d", WFinfo.acl);

     for (y = 0; y < data_list -> rows; ++y)
      {
        count1 = data_list -> columns * y;

        NFMchange_case (data1 [count1 + i], 0);

        if (! strcmp (data1 [count1 + i], "ADD"))
         {
           sprintf (sql_str,  "INSERT INTO %s (", "NFMSIGNOFFUSERS");
           sprintf (sql_str1, ") VALUES (");
           comma = 0;

           NFMchange_case (data1 [count1 + j], 0);
   
           if (strlen (data1 [count1 + j]))
            {
              if ((strcmp (data1 [count1 + j], "Y")) &&
                  (strcmp (data1 [count1 + j], "N")))
               {
                 free (sql_str1);
                 free (sql_str1);
                 status = NFM_E_INVALID_OVERRIDE;
	         ERRload_struct(NFM,status,"",NULL);
                 _NFMdebug ((fname, "Inv Override : status = <0x%.8x>\n",
                 status));
                 return (status);
               }
            }
           else
            {
              status = MEMwrite_data (data_list, "N", y + 1, j + 1);
              if (status != MEM_S_SUCCESS)
               {
                 free (sql_str1);
                 free (sql_str1);
                 status = NFM_E_MEM;
	         ERRload_struct(NFM,status,"",NULL);
                 _NFMdebug ((fname, "Wr Data : status = <0x%.8x>\n",
                 status));
                 return (status);
               }
            }

           for (x = 0; x < attr_list -> rows; ++x)
            {
              count = attr_list -> columns * x;

              if (x != i)
               {
                 if (! strcmp (data [count + a], "n_aclno"))
                  {
                    status = MEMwrite_data (data_list, value,
                             y + 1, x + 1);
                    if (status != MEM_S_SUCCESS)
                     {
                       free (sql_str);
                       free (sql_str1);
                        status = NFM_E_MEM;
	                ERRload_struct(NFM,status,"",NULL);
                       _NFMdebug ((fname, "WrDa : status = <0x%.8x>\n",
                       status));
                       return (status);
                     }
                  }
           
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
           if ((status != SQL_S_SUCCESS) &&
               (status != SQL_E_DUPLICATE_VALUE))
            {
              free (sql_str);
              free (sql_str1);
              status = NFM_E_SQL_STMT;
	      ERRload_struct(NFM,status,"",NULL);
              _NFMdebug ((fname, "SQL Stmt Synt : status = <0x%.8x>\n",
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

 long WFdrop_acl_signoff_users (user_id, attr_list, data_list)
   long    user_id;
   MEMptr  attr_list, data_list;
   {
     static char *fname = "WFdrop_acl_signoff_users" ;
     long   status;
     char   **column, **data, **data1;
     long   a, b, i, j, k, l;
     long   x, y, count, count1, and;
     char   *sql_str;

     _NFMdebug ((fname, "ENTER\n")) ;
     user_id = user_id ;
     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     data1  = (char **) data_list -> data_ptr;

     a = -1; b = -1; i = -1; j = -1; k = -1; l = -1;

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))     a = y;
        else if (! strcmp (column [y], "n_datatype")) b = y;
      }

     for (x = 0; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;
  
             if (! strcmp (data [count + a], "n_status"))  i = x;
        else if (! strcmp (data [count + a], "n_aclno"))   j = x;
        else if (! strcmp (data [count + a], "n_stateno")) k = x;
        else if (! strcmp (data [count + a], "n_userno"))  l = x;
      }
     

     sql_str = (char *) malloc (attr_list -> rows * 50 +
                                data_list -> row_size + MEM_SIZE);
     if (! sql_str)
      {
        _NFMdebug ((fname, "Malloc Failed\n")) ;
	ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
        return (NFM_E_MALLOC) ;
      }

     for (y = 0; y < data_list -> rows; ++y)
      {
        count1 = data_list -> columns * y;

        NFMchange_case (data1 [count1 + i], 0);

        if (! strcmp (data1 [count1 + i], "DROP"))
         {
           sprintf (sql_str,  "DELETE FROM %s WHERE ", "NFMSIGNOFFUSERS");
           and = 0;

           for (x = 0; x < attr_list -> rows; ++x)
            {
              count = attr_list -> columns * x;

              if (x == j || x == k || x == l)
               {
                 if (and) strcat (sql_str,  " AND ");
                 and = 1;

                 strcat (sql_str, data [count + a]);
                 strcat (sql_str, " = ");

                 if (! strncmp (data [count + b], "char", 4))
                  {
                    strcat (sql_str, "'");
                    strcat (sql_str, data1 [count1 + x]);
                    strcat (sql_str, "'");
                  }
                 else
                  {
                    if (strlen (data1 [count1 + x]))
                       strcat (sql_str, data1 [count1 + x]);
                    else
                       strcat (sql_str, "null");
                  }
               }
            }

           status = SQLstmt (sql_str);
           if ((status != SQL_S_SUCCESS) &&
               ((status ) != SQL_I_NO_ROWS_FOUND))
            {
              free (sql_str);
              _NFMdebug ((fname, "SQL Stmt Syn : status = <0x%.8x>\n",
              status));
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
              return (NFM_E_SQL_STMT) ;
            }
         }
      }

     free (sql_str);

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long WFset_acl_signoff_users (user_id, wf_name, user_name,
                             attr_list, data_list)
   long    user_id;
   char    *wf_name, *user_name;
   MEMptr  attr_list, data_list;
   {
     static char *fname = "WFset_acl_signoff_users" ;
     long      status, atol ();
     MEMptr    list = NULL;
     char      **column, **data, **data1;
     long      c, x, y, count, count1, wf_no, user_no;
     char      user_num [50];
     char      sql_str [1024];

     _NFMdebug ((fname, "Wf   Name = <%s> : User Name = <%s>\n", 
		 wf_name, user_name));

     status = NFMget_workflow_no (user_id, wf_name, &wf_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get WF No : status = <0x%.8x>\n", status));
        return (status);             
      }

     status = NFMget_user_no (user_id, user_name, &user_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get User No : status = <0x%.8x>\n",
        status));
        return (status);             
      }

     sprintf (user_num, "%d", user_no);

     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEM Build array : status = <0x%.8x>\n",
        status));
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        return (NFM_E_MEM) ;
      }

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     sprintf (sql_str, "SELECT %s, %s FROM %s WHERE %s = %d",
              "n_stateno", "n_signoffs", "NFMSTATES", 
              "n_workflowno", wf_no);

     status = SQLquery (sql_str, &list, MEM_SIZE);
     if ((status != SQL_S_SUCCESS) &&
         ((status ) != SQL_I_NO_ROWS_FOUND))
      {
        MEMclose (&list);
        _NFMdebug ((fname, "Sql Query Syntax : status = <0x%.8x>\n",
        status));
	ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
        return (NFM_E_SQL_QUERY) ;
      }

     status = MEMbuild_array (list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
        status));
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        return (NFM_E_MEM) ;
      }

     data1 = (char **) list -> data_ptr;

     c = -1 ;
     for (y = 0; y < attr_list -> columns; ++y)
       if (! strcmp (column [y], "n_name"))   c = y;

     for (y = 0; y < list -> rows; ++y)
      {
        count1 = list -> columns * y;

        sql_str [0] = 0;

        if (atol (data1 [count1 + 1]) > 0)
         {
           for (x = 0; x < attr_list -> rows; ++x)
            {
              count = attr_list -> columns * x;

              if (! strcmp (data [count + c], "n_aclno"));
              else if (! strcmp (data [count + c], "n_status"))
                strcat (sql_str, "ADD");
              else if (! strcmp (data [count + c], "n_userno"))
                strcat (sql_str, user_num);  
              else if (! strcmp (data [count + c], "n_stateno"))
                strcat (sql_str, data1 [count1]);  
              else if (! strcmp (data [count + c], "n_override"))
                strcat (sql_str, "N");  

              strcat (sql_str, "\1");
            }

           status = MEMwrite (data_list, sql_str);
           if (status != MEM_S_SUCCESS)
            {
              MEMclose (&list);
              _NFMdebug ((fname, "MEM Write : status = <0x%.8x>\n",
              status));
	      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
              return (NFM_E_MEM) ;
            }
         }
      }

     MEMclose (&list);

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);     
   }
