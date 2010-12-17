#include "machine.h"
#include "WF.h"

 extern struct WFstruct WFinfo;
 extern struct NFMglobal_st NFMglobal ;

 long WFcheck_acl_complete (wf_no, acl_no)
   long   wf_no;
   long   acl_no ;
   {
     char *fname = "WFcheck_acl_complete" ;
     long     status;
     long     WFcheck_acl_class_users ();
     long     WFcheck_acl_signoff_users ();

     _NFMdebug ((fname, "Wf   No = <%d> : Acl No <%d>\n", wf_no, acl_no  ));
      
     status = WFcheck_acl_class_users (NFMglobal.NFMuserid, wf_no, acl_no) ;
     if (status != NFM_E_CLASS_USERS_COMP)
      {
        _NFMdebug ((fname, "Check Class Users : status = <0x%.8x>\n",
        status));
        return (status);
      }

     status = WFcheck_acl_signoff_users (NFMglobal.NFMuserid, wf_no, acl_no) ;
     if (status != NFM_E_SIGN_USERS_COMP)
      {
        _NFMdebug ((fname, "Check Sign Users : status = <0x%.8x>\n",
        status));
        return (status);
      }

     _NFMdebug ((fname, "SUCCESSFUL : ACL COMPLETE : status = <0x%.8x>\n",
		 NFM_E_ACL_COMPLETE));
     return (NFM_E_ACL_COMPLETE);
   }

 long WFcheck_acl_class_users (user_id, wf_no, acl_no)
   long    user_id;
   long    wf_no, acl_no;
   {
     static char *fname= "WFcheck_acl_class_users" ;
     long    status, atol ();
     char    sql_str [1024], value [50];
     char    attr [50];
     long    classes;

     _NFMdebug ((fname, "Wf   No = <%d> : Acl No = <%d>\n", 
		 wf_no, acl_no));

     sprintf (sql_str, "WHERE %s = %d", "n_workflowno", wf_no);

     status = NFMget_attr_value (user_id, "NFMCLASSES", "COUNT(*)",
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           status = NFM_E_NO_CLASSES_DEFINED;
	   ERRload_struct(NFM,status,"",NULL);
           _NFMdebug ((fname, "WF Classes Not Defined : status = <0x%.8x>\n",
           status));
           return (status);          
         }

        _NFMdebug ((fname, "Get Attr Value : status = <%d>\n",
        status));
        return (status);          
      }

     classes = atol (value);

     sprintf (sql_str, "WHERE %s = %d", "n_aclno", acl_no);

     sprintf (attr, "COUNT(DISTINCT %s)", "n_classno");
 
     status = NFMget_attr_value (user_id, "NFMACLUSERS", attr,
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           status = NFM_E_CLASS_USERS_NOT_COMP;
	   ERRload_struct(NFM,status,"",NULL); 
           _NFMdebug ((fname, "Acl Users Not Complete : status = <0x%.8x>\n",
           status));
           return (status);          
         }

        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
        status));
        return (status);          
      }
     
     if (atol (value) != classes)
      {
        status = NFM_E_ACL_NOT_COMPLETE;
	ERRload_struct(NFM,status,"",NULL); 
        _NFMdebug ((fname, "Acl users Not Complete : status = <0x%.8x>\n",
		    status));
        return (status);          
      }
     else
       {
	 status = NFM_E_CLASS_USERS_COMP;
	 ERRload_struct(NFM,status,"",NULL);
	 _NFMdebug ((fname, "Acl Users Complete : status = <0x%.8x>\n",
		     status));
	 return (status);          
       }
/* never gets here     
     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);          
*/
   }

 long WFcheck_acl_signoff_users (user_id, wf_no, acl_no)
   long    user_id;
   long    wf_no, acl_no;
   {
     static char *fname = "WFcheck_acl_signoff_users" ;
     long    status, atol ();
     char    sql_str [1024], value [50];
     MEMptr  list = NULL;
     char    **data;
     long    x, count;

     _NFMdebug ((fname, "Wf   No = <%d> : Acl No = <%d>\n", 
		 wf_no, acl_no));

     sprintf (sql_str, "SELECT %s, %s FROM %s WHERE %s = %d",
              "n_stateno", "n_signoffs", "NFMSTATES", "n_workflowno", wf_no);
     
     status = SQLquery (sql_str, &list, MEM_SIZE);
     if ((status != SQL_S_SUCCESS) &&
         ((status ) != SQL_I_NO_ROWS_FOUND))
      {
        MEMclose (&list);
        status = NFM_E_SQL_QUERY;
	   ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n",
        status));
        return (status);          
      }

     status = MEMbuild_array (list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = NFM_E_MEM;
	   ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
        return (status);          
      }

     data = (char **) list -> data_ptr;

     for (x = 0; x < list -> rows; ++x)
      {
        count = list -> columns * x;

        if (atol (data [count + 1]) > 0)
         {
           sprintf (value, "%d", acl_no);

           sprintf (sql_str, "WHERE %s = %s AND %s = %s",
                    "n_stateno", data [count], "n_aclno", value);
   
           status = NFMget_attr_value (user_id, "NFMSIGNOFFUSERS",
                    "COUNT(*)", sql_str, value);
           if (status != NFM_S_SUCCESS)
            {
              MEMclose (&list);

              if (status == NFM_I_BAD_CONDITION)
               {
                 status = NFM_E_ACL_NOT_COMPLETE;
		 ERRload_struct(NFM,status,"",NULL);
                 _NFMdebug ((fname, "Sign Usr NotCmp : status = <0x%.8x>\n",
                 status));
                 return (status);          
               }

              _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
              status));
              return (status);          
            }
 
           if (atol (value) < atol (data [count + 1]))
            {
              MEMclose (&list);
              status = NFM_E_ACL_NOT_COMPLETE;
	      ERRload_struct(NFM,status,"",NULL);
              _NFMdebug ((fname, "Sign Users Not Comp : status = <0x%.8x>\n",
			  status));
              return (status);          
            }
         } 
      }
     
     status = MEMclose (&list);
     if (status != MEM_S_SUCCESS)
       {
	 status = NFM_E_MEM;
	 ERRload_struct(NFM,status,"",NULL);
	 _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n",
		     status));
	 return (status);          
       }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
		 NFM_E_SIGN_USERS_COMP));
     return (NFM_E_SIGN_USERS_COMP);          
   }

 long WFenter_acl_complete (user_id)
   long    user_id;
   {
     static char *fname = "WFenter_acl_complete" ;
     long    status;
     char    sql_str [1024], value [50];

     _NFMdebug ((fname, "ENTER\n")) ;
     user_id = user_id ;
     sprintf (value, "'Y'");

     sprintf (sql_str, "UPDATE %s SET %s = %s WHERE %s = %d", 
              "NFMACLS", "n_complete", value, "n_aclno", WFinfo.acl);

     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS)
      {
        status = NFM_E_SQL_STMT;
	   ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "SQL Stmt Failed : status = <0x%.8x>\n",
        status));
        return (status);
      }
     
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long WFenter_acl_not_complete (user_id)
   long    user_id;
   {
     static char *fname = "WFenter_acl_no_complete" ;
     long    status;
     char    sql_str [1024], value [50];

     _NFMdebug ((fname, "ENTER\n")) ;
     user_id = user_id ;
     sprintf (value, "'N'");

     sprintf (sql_str, "UPDATE %s SET %s = %s WHERE %s = %d", 
              "NFMACLS", "n_complete", value, "n_aclno", WFinfo.acl);

     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS)
      {
        status = NFM_E_SQL_STMT;
	   ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "SQL Stmt Failed : status = <0x%.8x>\n",
        status));
        return (status);
      }
     
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long WFcheck_workflow_usable (user_id, wf_no)
   long   user_id;
   long   wf_no;
   {
     static char *fname = "WFcheck_workflow_usable" ;
      long    status, atol ();
      char    sql_str [1024], value [50];

      _NFMdebug ((fname, "Wf   No = <%d>\n", wf_no  ));

      sprintf (value, "'Y'");

      sprintf (sql_str, "WHERE %s = %d AND %s = %s",
                 "n_workflowno", wf_no, "n_complete", value);

      status = NFMget_attr_value (user_id, "NFMACLS", "COUNT(*)",
               sql_str, value);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
         status));
         return (status);
       }

      if (atol (value) > 0)
       {
         status = NFM_E_WORKFLOW_USABLE;
	   ERRload_struct(NFM,status,"",NULL); 
         _NFMdebug ((fname, "WF Is Usable : status = <0x%.8x>\n",
         status));
         return (status);
       }
      else
       {
         status = NFM_E_WORKFLOW_NOT_USABLE;
	   ERRload_struct(NFM,status,"",NULL); 
         _NFMdebug ((fname, "WF Not Usable : status = <0x%.8x>\n",
         status));
         return (status);
       }
/*****  do not get here     
      _NFMdebug ((fname, "SUCCESSFUL\n")) ;
      return (NFM_S_SUCCESS);
******/
   }

 long WFenter_workflow_complete (user_id, attr_list, data_list)
   long    user_id;
   MEMptr  attr_list, data_list;
   {
     static char *fname = "WFenter_workflow_complete";
     long    status;
     char    sql_str [1024], sql_str1 [1024];
     char    **column, **data, **data1;
     char    value [50];
     long    a, b, x, y, count, wf_no1;

     _NFMdebug ((fname, "ENTER\n")) ;

     status = NFMget_workflow_no (user_id, "NFM_SDP_WORKFLOW", &wf_no1);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Attr Info : status = <0x%.8x>\n", status));
        return (status);          
      }

     sprintf (sql_str, "WHERE %s = %d", "n_workflowno", wf_no1);

     strcat (sql_str, " AND ");
     strcat (sql_str, "n_statename");
     strcat (sql_str, " = ");

     strcat (sql_str, "'WORKFLOW COMPLETE'");

     status = NFMget_attr_value (user_id, "NFMSTATES", "n_stateno",
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
        if (status ==  NFM_I_BAD_CONDITION)
         {
           status = NFM_E_NO_WF_COMPLETE_STATE;
	   ERRload_struct(NFM,status,"",NULL);
           _NFMdebug ((fname, "No WF Comp State : status = <0x%.8x>\n",
           status));
           return (status);          
         }

        _NFMdebug ((fname, "Get Attr Info : status = <0x%.8x>\n", status));
        return (status);          
      }

     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
        status = NFM_E_MEM;
	   ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
        return (status);              
      }

     status = MEMbuild_array (data_list);
     if (status != MEM_S_SUCCESS)
      {
        status = NFM_E_MEM;
	   ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
        return (status);              
      }

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     data1 = (char **) data_list -> data_ptr;

     a = -1; b = -1; 
     
     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))       a = y;
        else if (! strcmp (column [y], "n_datatype"))   b = y;
      }

     sprintf (sql_str, "UPDATE %s SET ", "NFMWORKFLOW");
     sprintf (sql_str1, " WHERE ");

     for (x = 0; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;

        if (! strcmp (data [count + a], "n_workflowno"))
         {
           strcat (sql_str1, data [count + a]);
           strcat (sql_str1, " = ");

           if (! strncmp (data [count + b], "char", 4))
            {
              strcat (sql_str1, "'");
              strcat (sql_str1, data1 [x]);
              strcat (sql_str1, "'");
            }
           else
              strcat (sql_str1, data1 [x]);
         }
        else if (! strcmp (data [count + a], "n_stateno"))
         {
           strcat (sql_str, data [count + a]);
           strcat (sql_str, " = ");

           if (! strncmp (data [count + b], "char", 4))
            {
              strcat (sql_str, "'");
              strcat (sql_str, value);
              strcat (sql_str, "'");
            }
           else
              strcat (sql_str, value);
         }
      }

     strcat (sql_str, sql_str1);

     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS)
      {
        status = NFM_E_SQL_STMT;
	   ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n", status));
        return (status);              
      }
           
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);              
   }
 
 long WFenter_workflow_usable (user_id, wf_no)
   long     user_id;
   long     wf_no;
   {
     static char *fname = "WFenter_workflow_usable";
     long   status, atol ();
     char   sql_str [2048], value [50];
     long   wf_no1;

     _NFMdebug ((fname, "Wf   No = <%d>\n", wf_no  ));

     status = NFMget_workflow_no (user_id, "NFM_SDP_WORKFLOW", &wf_no1);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Attr Info : status = <0x%.8x>\n", status));
        return (status);          
      }
    
     sprintf (sql_str, "WHERE %s = %d", "n_workflowno", wf_no1);

     strcat (sql_str, " AND ");
     strcat (sql_str, "n_statename");
     strcat (sql_str, " = ");

     strcat (sql_str, "'WORKFLOW USABLE'");

     status = NFMget_attr_value (user_id, "NFMSTATES", "n_stateno",
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           status = NFM_E_NO_USABLE_STATE;
	   ERRload_struct(NFM,status,"",NULL);
           _NFMdebug ((fname, "No WF Usable State : status = <0x%.8x>\n",
           status));
           return (status);          
         }

        _NFMdebug ((fname, "Get Attr Info : status = <0x%.8x>\n", status));
        return (status);          
      }

     sprintf (sql_str, "UPDATE %s SET %s = %s WHERE ",
              "NFMWORKFLOW", "n_stateno", value);

     strcat (sql_str, "n_workflowno");
     strcat (sql_str, " = ");
    
     sprintf (value, "%d", wf_no);
     strcat (sql_str, value);

     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS)
      {
        status = NFM_E_SQL_STMT;
	   ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n", status));
        return (status);          
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);          
   }
 
 long WFenter_workflow_not_usable (user_id, wf_no)
   long     user_id;
   long     wf_no;
   {
     static char *fname = "WFenter_workflow_not_usable";
     long   status, atol ();
     char   sql_str [2048], value [50];
     long   wf_no1;

     _NFMdebug ((fname, "Wf   No = <%d>\n", wf_no  ));

     status = NFMget_workflow_no (user_id, "NFM_SDP_WORKFLOW", &wf_no1);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Attr Info : status = <0x%.8x>\n", status));
        return (status);          
      }
    
     sprintf (sql_str, "WHERE %s = %d", "n_workflowno", wf_no1);

     strcat (sql_str, " AND ");
     strcat (sql_str, "n_statename");
     strcat (sql_str, " = ");

     strcat (sql_str, "'WORKFLOW COMPLETE'");

     status = NFMget_attr_value (user_id, "NFMSTATES", "n_stateno",
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           status = NFM_E_NO_USABLE_STATE;
	   ERRload_struct(NFM,status,"",NULL);
           _NFMdebug ((fname, "No WF Usable State : status = <0x%.8x>\n",
           status));
           return (status);          
         }

        _NFMdebug ((fname, "Get Attr Info : status = <0x%.8x>\n", status));
        return (status);          
      }

     sprintf (sql_str, "UPDATE %s SET %s = %s WHERE ",
              "NFMWORKFLOW", "n_stateno", value);

     strcat (sql_str, "n_workflowno");
     strcat (sql_str, " = ");
    
     sprintf (value, "%d", wf_no);
     strcat (sql_str, value);

     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS)
      {
        status = NFM_E_SQL_STMT;
	   ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n", status));
        return (status);          
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);          
   }
 
 long WFtransition_log (user_id, app_name, app_ptr)
   long    user_id;
   char    *app_name;
   MSGptr  app_ptr;
   {
     static char *fname = "WFtransition_log";
     long    status;

     _NFMdebug ((fname, "App   Name = <%s> : Error No = <0x%.8x> : Error Msg = <%s>\n", 
		 app_name, app_ptr.error_no, app_ptr.error_msg));

     status = NFM_S_SUCCESS ;

     if (app_ptr.error_no == NFM_S_SUCCESS)
      {
        if (WFinfo.transition > 0 )
         {
	   if(!strcmp(WFinfo.logon_s,"Y"))
           {
		status = NFM_S_SUCCESS;
	   }
	   else
	   {
		status = NFM_E_NO_TRANS_LOG;
	   }
         }
      }
     else
      {
	   if(!strcmp(WFinfo.logon_f,"Y"))
           {
		status = NFM_S_SUCCESS;
	   }
	   else
	   {
		status = NFM_E_NO_TRANS_LOG;
	   }
      }

     if (status == NFM_S_SUCCESS)
      {
        if (WFinfo.transition > 0)
         {
           status = NFMadd_activity_entry (user_id, app_name, app_ptr);
           if (status != NFM_S_SUCCESS)
            {
              _NFMdebug ((fname, "Add Activity ent : status = <0x%.8x>\n",
              status));
              return (status);
            }
         }
      }
     
     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long WFtransition_mail (user_id, app_name, app_ptr)
   long    user_id;
   char    *app_name;
   MSGptr  app_ptr;
   {
     static char *fname = "WFtransition_mail" ;
     long    status;

     _NFMdebug ((fname, "App   Name = <%s> : Error No = <%d>\n", 
		 app_name, app_ptr.error_no));

     if (WFinfo.transition > 0)
      {
        if (!strcmp(WFinfo.notify,"Y"))
         {
           status = NFMsend_mail (user_id, app_name, app_ptr);
           if (status != NFM_S_SUCCESS)
            {
              _NFMdebug ((fname, "Notify : status = <0x%.8x>\n", status));
              return (status);
            }
         }
      }
     
     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

 long _WFquery_state_name (state_no,state_name)
   int      state_no;
   char	    *state_name;
   {
     static char *fname = "_WFquery_state_name" ;
     long   status, atol ();
     char   sql_str [200];
     char   **data;
     MEMptr bufr = NULL;

     _NFMdebug ((fname, "State no = <%d>  ", state_no));

     sprintf (sql_str, 
     "SELECT n_statename FROM nfmstates where n_stateno = %d",state_no);

     status = SQLquery (sql_str,&bufr,512);
     if (status != SQL_S_SUCCESS)
      {
	MEMclose(&bufr);
	if(status == SQL_I_NO_ROWS_FOUND )
	{
		_NFMdebug((fname,"The nfmstates table has no entries for \
state number <%d>\n",state_no));
		ERRload_struct(NFM,NFM_E_STATE_NO_INVALID,"%d",state_no);
		return(NFM_E_STATE_NO_INVALID);
	}
      	ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      	_NFMdebug ((fname, "Sql query failed : status = <0x%.8x>\n",
                  status)) ;
      	_NFMdebug ((fname, "Sql query :status = <%s>\n",
                  sql_str)) ;
      	return (NFM_E_SQL_QUERY) ;
      }
     status = MEMbuild_array(bufr);
     if(status != MEM_S_SUCCESS)
     {
	MEMclose(&bufr);
	_NFMdebug ((fname, "MEMbuild_array failed <0x%.8x>\n",
	status));
        ERRload_struct (NFM, NFM_E_MEM_ERR, "%s%s%s%x", "MEMbuild_array",
fname,"status",status) ;
      return (NFM_E_MEM_ERR) ;
     }
     data = (char **) bufr->data_ptr;
     strcpy(state_name,data[0]);
     MEMclose(&bufr);
     _NFMdebug ((fname, "SUCCESSFUL status <0x%.8x>\n",NFM_S_SUCCESS)) ;
     return (NFM_S_SUCCESS);          
   }
