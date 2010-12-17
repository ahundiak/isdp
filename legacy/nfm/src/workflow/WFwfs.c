#include "machine.h"
#include "WF.h"

 extern struct WFstruct WFinfo;

 long WFquery_workflow_attributes (user_id, 
                                   attr_list, data_list, value_list)
   long      user_id;
   MEMptr    *attr_list, *data_list, *value_list;
   {
     static char *fname = "WFquery_workflow_attributes" ;
     long     status;
     char     **column, **data;
     MEMptr   list = NULL;
     long     c, d, x, y, count;
     char     acl_no [50];
     int      no_buffers;

     _NFMdebug ((fname, "ENTER\n")) ;

     status = NFMquery_table_attributes (user_id, "NFMSYSTEM",
              "NFMWORKFLOW", attr_list, data_list, value_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        _NFMdebug ((fname, "Qry Tab Attr : status = <0x%.8x>\n", status));
        return (status);
      }

     status = NFMget_transition_acl_list (user_id, &list);
     if (status != NFM_S_SUCCESS)
       {
	 MEMclose (&list);
	 MEMclose (attr_list);
	 MEMclose (data_list);
	 MEMclose (value_list);
	 _NFMdebug ((fname, "Get Acl List : status = <0x%.8x>\n",
		     status));
	 return (status);
       }
     
     acl_no [0] = 0;
     
     if (list)
       {
	 if (*value_list)
	   {
	     status = MEMappend (list, *value_list);
	     if (status != MEM_S_SUCCESS)
               {
                 MEMclose (&list);
                 MEMclose (attr_list);
                 MEMclose (data_list);
                 MEMclose (value_list);
		 ERRload_struct(NFM,status,"",NULL);
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
		 ERRload_struct(NFM,status,"",NULL);
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
	     ERRload_struct(NFM,status,"",NULL);
	     _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n",
			 status));
	     return (NFM_E_MEM) ;
	   }
	 status = MEMno_buffers (*value_list,&no_buffers);
	 if (status != MEM_S_SUCCESS)
	   {
	     MEMclose (attr_list);
	     MEMclose (data_list);
	     MEMclose (value_list);
	     ERRload_struct(NFM,status,"",NULL);
	     _NFMdebug ((fname, "MEM No Buffers : status = <0x%.8x>\n",
			 status));
	     return (NFM_E_MEM) ;
	   }
	 sprintf (acl_no, "%d", no_buffers);
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
     
     c = -1; d = -1;
     
     for (y = 0; y < (*attr_list) -> columns; ++y)
       {                
	 if (! strcmp (column [y], "n_name"))    c = y;
	 else if (! strcmp (column [y], "n_valueno"))     d = y;
       }
     
     for (x = 0; x < (*attr_list) -> rows; ++x)
       {
	 count = (*attr_list) -> columns * x;
	 
	 if (! strcmp (data [count + c], "n_aclno"))
	   {
	     status = MEMwrite_data (*attr_list, acl_no, x + 1, d + 1);
	     if (status != MEM_S_SUCCESS)
               {
                 MEMclose (attr_list);
                 MEMclose (data_list);
                 MEMclose (value_list);
		 ERRload_struct(NFM,status,"",NULL);
                 _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			     status)) ;
                 return (NFM_E_MEM) ;
               }
	   }
       }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);      
   }

 long WFadd_workflow (user_id, attr_list, data_list)
   long     user_id;
   MEMptr   attr_list, data_list; 
   {
     static char *fname = "WFadd_workflow" ;
     long    status;
     char    *sql_str, *sql_str1;
     char    **column, **data, **data1;
     long    a, b, c, x, y, i =-1, count, comma, add;
     long    wf_no, state_no;
     char    wf_num [50];

     _NFMdebug ((fname, "ENTER\n")) ;

     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array 1 : status = <0x%.8x>\n", status));
        return (NFM_E_MEM) ;
      }

     status = MEMbuild_array (data_list);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array 2 : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);        
      }

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     data1  = (char **) data_list -> data_ptr;

     a = -1; b = -1; c = -1;

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))      a = y;
        else if (! strcmp (column [y], "n_datatype"))  b = y;
      }

     if (a < 0 || b < 0)
      {
        status = NFM_E_CORRUPTED_BUFFERS;
		 ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "Corrupted Buffers : status = <0x%.8x>\n", status));
        return (NFM_E_CORRUPTED_BUFFERS);
      }

     sql_str = (char *) malloc (data_list -> row_size +
                                data_list -> columns * 50 + MEM_SIZE);
     if (! sql_str)
      {
        status = NFM_E_MALLOC;
		 ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC));
        return (status);        
      }

     sql_str1 = (char *) malloc (data_list -> row_size + MEM_SIZE);
     if (! sql_str1)
      {
        free (sql_str);
        status = NFM_E_MALLOC;
		 ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC));
        return (status);        
      }

     sprintf (sql_str,  "INSERT INTO %s (", "NFMWORKFLOW");
     sprintf (sql_str1, ") VALUES (");
     comma = 0;

     for (x = 0; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;
        add = 0;
         
        if (! strcmp (data [count + a], "n_workflowno"))
         {
           status = NFMget_serial_slot (user_id, "nfmworkflow",
                    data [count + a], &wf_no);
           if (status != NFM_S_SUCCESS)
            {
              free (sql_str);
              free (sql_str1);
              _NFMdebug ((fname, "Get Serial No : status = <0x%.8x>\n",
              status));
              return (status);        
            }

           WFinfo.workflow = wf_no;
           sprintf (wf_num, "%d", wf_no);

           status = MEMwrite_data (data_list, wf_num, 1, x + 1);
           if (status != MEM_S_SUCCESS)
            {
              free (sql_str);
              free (sql_str1);
	      ERRload_struct(NFM,status,"",NULL);
              _NFMdebug ((fname, "MEM Write Data : status = <0x%.8x>\n",
			  status));
              return (NFM_E_MEM) ;
            }

           add = 1;
         }
        else if (! strcmp (data [count + a], "n_aclno"))
         {
           add = 1;
           i = x;
         }
        else if (! strcmp (data [count + a], "n_stateno"))
           add = 0;
        else if (! strcmp (data [count + a], "n_workflowname"))
         {
           sprintf (WFinfo.workflow_name, "%s", data1 [x]);
           add = 1;
         }
        else 
          add = 1;
         
        if (add)
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
              strcat (sql_str1, data1 [x]);
              strcat (sql_str1, "'");
            }
           else
            {
              if (strlen (data1 [x]))
                strcat (sql_str1, data1 [x]);
              else
                strcat (sql_str1, "null");
            }
         }
      }

     if (wf_no > 5)
      {
        status = NFMget_acl_state_no (user_id, atol (data1 [i]),
                 &state_no);
        if (status != NFM_S_SUCCESS)
         {
           free (sql_str);
           free (sql_str1);
           _NFMdebug ((fname, "Get Acl State No : status = <0x%.8x>\n",
           status));
           return (status);        
         }
      }

     strcat (sql_str, sql_str1);
     strcat (sql_str, ")");

     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS)
      {
        free (sql_str);
        free (sql_str1);

        if (status == SQL_E_DUPLICATE_VALUE)
         {
           status = NFM_E_WORKFLOW_EXISTS;
		 ERRload_struct(NFM,status,"",NULL);
           _NFMdebug ((fname, "WF Exists : status = <0x%.8x>\n", status));
           return (status);        
         }

	ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n", status));
        return (NFM_E_SQL_STMT) ;
      }

     free (sql_str);
     free (sql_str1);

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);     
   }

 long WFload_workflow_list (user_id, attr_list, data_list,
                            inline, workflow_name)
   long     user_id;
   MEMptr   attr_list, data_list;
   char     *inline;
   char     *workflow_name;
   {
     static char *fname = "WFload_workflow_list" ;
     long    status;
     char    *token, *strtok ();
     long    x, y, count, c;
     char    **column, **data, **data1;
     long    acl_no, wf_no;
     char    value [50], wf_name [100], message [512] ;

     workflow_name [0] = 0;
     
     _NFMdebug ((fname, "Inline : <%s>  Workflow Name <%s>\n",
		 inline, workflow_name)) ;

     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct(NFM, NFM_E_MEM,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status)) ;
        return (NFM_E_MEM) ;
      }

     status = MEMbuild_array (data_list);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct(NFM,NFM_E_MEM,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
        return (NFM_E_MEM) ;
      }

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     data1  = (char **) data_list -> data_ptr;

     c = -1 ;
     for (y = 0; y < attr_list -> columns; ++y)
       if (! strcmp (column [y], "n_name"))    c = y;

     y = 0;

     for (x = 0; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;

        _NFMdebug ((fname, "Column Name : <%s>\n", data [count + c]));
	
        if ((! strcmp (data [count + c], "n_workflowno")) ||
            (! strcmp (data [count + c], "n_stateno")));
        else
	  {
	    token = NULL;
	    
	    if (y)     token = strtok (NULL, "|");
	    else       token = strtok (inline, "|");
	    
	    y = 1;
	    
	    if (token)
	      { 
		if (! strcmp (data [count + c], "n_workflowname"))
		  {
		    sprintf (workflow_name, "%s", token);
		    if (strlen (workflow_name) > 20)
		      {
			strcpy(message,"Workflow Name exceeds 20 characters");
			_NFMdebug ((fname, "Failure : %s\n", message)) ;
			ERRload_struct (NFM, NFM_E_MESSAGE, "%s", message) ;
			return (NFM_E_MESSAGE) ;
		      }
		  }
		
		if (! strcmp (data [count + c], "n_aclno"))
		  {
                 status = NFMget_acl_no (user_id, token, &acl_no);
                 if (status != NFM_S_SUCCESS && status != NFM_E_BAD_ACL)
                  {
                    _NFMdebug ((fname, "Get Acl No : status = <0x%.8x>\n",
				status));
                    return (status);                     
                  }
		 
                 if (status == NFM_E_BAD_ACL)
		   {
		     status = NFMget_acl_no (user_id, "NFM_SDP_ACL",
					     &acl_no);
		     if (status != NFM_S_SUCCESS)
		       {
			 if (strcmp (workflow_name, "NFM_SDP_WORKFLOW"))
                        {
                          _NFMdebug ((fname, "Acl No : status = <0x%.8x>\n",
				      status));
                          return (status);                     
                        }
			 else if (status == NFM_E_BAD_ACL)
			   acl_no = 1;
		       }
		     else
		       {
			 status = NFMget_acl_workflow_no (user_id, acl_no,
							  &wf_no);
			 if (status != NFM_S_SUCCESS)
			   {
			     _NFMdebug ((fname, "Wf No : status = <0x%.8x>\n",
					 status));
			     return (status);
			   }
			 
			 status = NFMget_workflow_name (user_id, wf_no,
							wf_name);
			 if (status != NFM_S_SUCCESS)
			   {
			     _NFMdebug ((fname, "Wf Name : status = <0x%.8x>\n",
					 status));
			     return (status);
			   }
			 
			 if (strcmp (wf_name, "NFM_SDP_ACL"))
			   {
			     status = NFM_E_NOT_SDP_WORKFLOW;
			     ERRload_struct(NFM,status,"",NULL);
			     _NFMdebug ((fname, "Not SDP Wf : status = <0x%.8x>\n",
					 status));
			     return (status);
			   }
		       }
		   }
                 else
		   {
		     status = NFMget_acl_workflow_no (user_id, acl_no,
						      &wf_no);
		     if (status != NFM_S_SUCCESS)
		       {
			 _NFMdebug ((fname, "Acl Wf No : status = <0x%.8x>\n",
				     status));
			 return (status);
		       }
		     
		     status = NFMget_workflow_name (user_id, wf_no,
						    wf_name);
		     if (status != NFM_S_SUCCESS)
		       {
			 _NFMdebug ((fname, "Wf Name : status = <0x%.8x>\n",
				     status));
			 return (status);
		       }
		     
		     if (strcmp (wf_name, "NFM_SDP_WORKFLOW"))
		       {
			 status = NFM_E_NOT_SDP_WORKFLOW;
			 ERRload_struct(NFM,status,"",NULL);
			 _NFMdebug ((fname, "Not Sdp Wf : status = <0x%.8x>\n",
				     status));
			 return (status);                     
		       }
		   }
		 
                 sprintf (value, "%d", acl_no);
		 
                 status = MEMwrite_data (data_list, value, 1, x + 1);
                 if (status != MEM_S_SUCCESS)
		   {
		     ERRload_struct(NFM, NFM_E_MEM,"",NULL);
		     _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
				 status));
		     return (NFM_E_MEM) ;
		   }
               }
              else 
               {
                 status = MEMwrite_data (data_list, token, 1, x + 1);
                 if (status != MEM_S_SUCCESS)
                  {
                    status = NFM_E_MEM;
		    ERRload_struct(NFM,status,"",NULL);
                    _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
                    status));
                    return (status);                     
                  }
               }
            }
         }
      }
     _NFMdebug ((fname, "Wf Name = %s : SUCCESSFUL\n", workflow_name)) ;
     return (NFM_S_SUCCESS);         
   }
