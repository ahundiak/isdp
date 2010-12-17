#include "machine.h"
#include "WF.h"

 extern struct WFstruct WFinfo;
 extern struct NFMglobal_st NFMglobal ;

 long WFquery_acl_attributes (user_id, attr_list, data_list, value_list)
   long      user_id;
   MEMptr    *attr_list, *data_list, *value_list;
   {
     static char *fname = "WFquery_acl_attributes" ;
     long     status;
     char   sql_str [1024], **data, **column ;
     long   column_of_valueno, row_of_wf_no, i, count, a;

     _NFMdebug ((fname, "ENTER\n")) ;
     user_id = user_id ;
     status = NFMquery_table_attributes (NFMglobal.NFMuserid, "nfmsystem",
              "nfmacls", attr_list, data_list, value_list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (value_list);
        _NFMdebug ((fname, "Qry Tab Attr : status = <0x%.8x>\n",
        status));
        return (status);
      }

     status = MEMbuild_array (*attr_list) ;
     if (status != MEM_S_SUCCESS)
       {
         _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
                     status)) ;
	 ERRload_struct (NFM, NFM_E_MEM, "","") ;
         return (NFM_E_MEM) ;
       }

     data = (char **) (*attr_list) -> data_ptr ;
     column = (char **) (*attr_list) -> column_ptr ;

     a = -1; column_of_valueno =-1 ;

     for (i=0; i< (*attr_list)->columns; i++)
       {
         if (! strcmp (column [i], "n_name")) a = i ;
        else if (! strcmp (column [i], "n_valueno")) column_of_valueno = i+1 ;
       }

     count =0 ;
     row_of_wf_no =-1 ;

     for (i=0; i< (*attr_list)->rows; i++)
       {
         count = i * (*attr_list)->columns ;
         if (! (strcmp (data[count + a], "n_workflowno")))
           {
             row_of_wf_no = i+1 ;
           }
       }

     strcpy (sql_str, "select n_workflowno, n_workflowname from nfmworkflow order by n_workflowno") ;

     status = _NFMadd_to_value_list_from_query (attr_list,
						value_list,
						sql_str,
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

 long WFadd_acl (user_id, attr_list, data_list)
   long     user_id;
   MEMptr   attr_list, data_list; 
   {
     static char *fname = "WFadd_acl" ;
     long    status;
     char    *sql_str, *sql_str1;
     char    **column, **data, **data1;
     long    a, b, c, x, y, count;
     long    acl_no;
     char    acl_num [50];

     _NFMdebug ((fname, "ENTER\n")) ;
     user_id = user_id ;
     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
        status = NFM_E_MEM;
        ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     status = MEMbuild_array (data_list);
     if (status != MEM_S_SUCCESS)
      {
        status = NFM_E_MEM;
        ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
        return (NFM_E_MEM) ;
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

     sql_str = (char *) malloc (data_list -> row_size +
                                data_list -> columns * 50 + MEM_SIZE);
     if (! sql_str)
      {
        status = NFM_E_MALLOC;
        ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC)) ;
        return (NFM_E_MALLOC) ;
      }

     sql_str1 = (char *) malloc (data_list -> row_size + MEM_SIZE);
     if (! sql_str1)
      {
        free (sql_str);
        status = NFM_E_MALLOC;
        ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",NFM_E_MALLOC));
        return (NFM_E_MALLOC) ;
      }

     status = NFMstop_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        free (sql_str);
        free (sql_str1);
        _NFMdebug ((fname, "Stop Trans : status = <0x%.8x>\n", status));
        return (status);        
      }

     sprintf (sql_str,  "INSERT INTO %s (", "NFMACLS");
     sprintf (sql_str1, ") VALUES (");

     for (x = 0; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;

        if (x)
         {
            strcat (sql_str,  ", ");
            strcat (sql_str1, ", ");
         }

        if (! strcmp (data [count + a], "n_aclno"))
         {
           status = NFMget_serial_slot (NFMglobal.NFMuserid, "nfmacls",
                    data [count + a], &acl_no);
           if (status != NFM_S_SUCCESS)
            {
              free (sql_str);
              free (sql_str1);
              NFMrollback_transaction (0);
              _NFMdebug ((fname, "Get Serial No : status = <0x%.8x>\n",
              status));
              return (status);        
            }

           sprintf (acl_num, "%d", acl_no);
           WFinfo.acl = acl_no;
           
           status = MEMwrite_data (data_list, acl_num, 1, x + 1);
           if (status != MEM_S_SUCCESS)
            {
              free (sql_str);
              free (sql_str1);
              status = NFM_E_MEM;
              ERRload_struct(NFM,status,"",NULL);
              NFMrollback_transaction (0);
              _NFMdebug ((fname, "MEM Write Data : status = <0x%.8x>\n",
			  status));
              return (NFM_E_MEM) ;   
            }
         }
        else if (! strcmp (data [count + a], "n_aclname"))
          sprintf (WFinfo.acl_name, "%s", data1 [x]);
        else if (! strcmp (data [count + a], "n_complete"))
         {
           status = MEMwrite_data (data_list, "N", 1, x + 1);
           if (status != MEM_S_SUCCESS)
            {
              free (sql_str);
              free (sql_str1);
              status = NFM_E_MEM;
              ERRload_struct(NFM,status,"",NULL);
              NFMrollback_transaction (0);
              _NFMdebug ((fname, "MEM Write Data : status = <0x%.8x>\n",
              status));
              return (NFM_E_MEM) ;
            }
         }

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

     strcat (sql_str, sql_str1);
     strcat (sql_str, ")");

     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS)
      {
        free (sql_str);
        free (sql_str1);
        NFMrollback_transaction (0);

        if (status == SQL_E_DUPLICATE_VALUE)
         {
	   ERRload_struct(NFM,NFM_E_ACL_EXISTS,"",NULL);
           _NFMdebug ((fname, "Acl Exists : status = <0x%.8x>\n",
		       status));
           return (NFM_E_ACL_EXISTS) ;
         }

        ERRload_struct(NFM, NFM_E_SQL_STMT,"",NULL);
        _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
		    status));
        return (NFM_E_SQL_STMT) ;   
      }

     status = NFMset_autocommit_on (0) ;
     if (status != NFM_S_SUCCESS)
      {
        free (sql_str);
        free (sql_str1);
        _NFMdebug ((fname, "Start Trans : status = <0x%.8x>\n",
		    status));
        return (status);
      }

     free (sql_str);
     free (sql_str1);

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);     
      }

 long WFset_acl (user_id, workflow_name, acl_name, attr_list, data_list)
   long    user_id;
   char    *workflow_name, *acl_name;
   MEMptr  attr_list, data_list;
   {
     static char *fname = "WFset_acl" ;
     long      status;
     char      **column, **data;
     char      value [50];
     long      x, y, count, c, wf_no;

     _NFMdebug ((fname, "Workflow Name = <%s> : ACL Name = <%s>\n", 
		 workflow_name, acl_name));
     user_id=user_id ;
     status = NFMget_workflow_no (NFMglobal.NFMuserid, workflow_name, &wf_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Wf No : status = <%d>\n", status));
        return (status);             
      }

     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct(NFM,NFM_E_MEM,"",NULL);
        _NFMdebug ((fname, "MEM Build array : status = <0x%.8x>\n", status));
	return (NFM_E_MEM) ;
      }

     status = MEMbuild_array (data_list) ;
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct(NFM,NFM_E_MEM,"",NULL);
        _NFMdebug ((fname, "MEM Build array : status = <0x%.8x>\n", status));
	return (NFM_E_MEM) ;
      }

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;
     c = -1 ;
     for (y = 0; y < attr_list -> columns; ++y)
       if (! strcmp (column [y], "n_name"))   c = y;

     sprintf (value, "%d", wf_no);

     for (x = 0; x < attr_list -> rows; ++x)
      {
        count = attr_list -> columns * x;
        if (! strcmp (data [count + c], "n_workflowno"))
         {
           sprintf (value, "%d", wf_no);

           status = MEMwrite_data (data_list, value, 1, x + 1);
           if (status != MEM_S_SUCCESS)
            {
              status = NFM_E_MEM;
              ERRload_struct(NFM,status,"",NULL);
              _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
              status));
              return (status);             
            }
         }
        else if (! strcmp (data [count + c], "n_aclname"))
         {
           status = MEMwrite_data (data_list, acl_name, 1, x + 1);
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

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);     
   }

 long WFdrop_acl (user_id, acl_name)
   long    user_id;
   char    *acl_name;
   {
     static char *fname = "WFdrop_acl" ;
     long    status;
     long    wf_no = 0, acl_no;
     char    wf_name [100];
     char    sql_str [1024];
     long    WFcheck_workflow_acl_inuse ();
     long    WFcheck_catalog_acl_inuse ();
     long    WFcheck_project_acl_inuse ();
     long    WFcheck_item_acl_inuse ();
     long    WFcheck_class_users_acl ();
     long    WFcheck_signoff_users_acl ();

     _NFMdebug ((fname, "Acl  Name = <%s>\n", acl_name));
     user_id = user_id ;
     status = NFMget_acl_no (NFMglobal.NFMuserid, acl_name, &acl_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Acl No : status = <0x%.8x>\n",
        status));
        return (status);
      }

     if (acl_no < 5)
      {
        status = NFM_E_SYSTEM_ACL;
        ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "System Acls : status = <0x%.8x>\n",
        status));
        return (status);
      }

     status = NFMget_acl_workflow_no (NFMglobal.NFMuserid, acl_no, wf_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Acl Wf No : status = <0x%.8x>\n",
        status));
        return (status);
      }

     status = NFMget_workflow_name (NFMglobal.NFMuserid, wf_no, wf_name);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Get Work Flow Name : status = <0x%.8x>\n",
        status));
        return (status);
      }

     if (! strcmp (wf_name, "NFM_SDP_WORKFLOW"))
      {
        status = WFcheck_workflow_acl_inuse (NFMglobal.NFMuserid, acl_no);
        if (status != NFM_S_SUCCESS)
         {
           _NFMdebug ((fname, "Chk Wf Acl In Use : status = <0x%.8x>\n",
           status));
           return (status);
         }
      }
     else if (! strcmp (wf_name, "NFM_ADMIN_WORKFLOW"));
     else if (! strcmp (wf_name, "NFM_CATALOG_WORKFLOW"))
      {
        status = WFcheck_catalog_acl_inuse (NFMglobal.NFMuserid, acl_no);
        if (status != NFM_S_SUCCESS)
         {
           _NFMdebug ((fname, "Chk Cat Acl In Use : status = <0x%.8x>\n",
           status));
           return (status);
         }
      }
     else if (! strcmp (wf_name, "NFM_PROJECT_WORKFLOW"))
      {
        status = WFcheck_project_acl_inuse (NFMglobal.NFMuserid, acl_no);
        if (status != NFM_S_SUCCESS)
         {
           _NFMdebug ((fname, "Chk Proj Acl In Use : status = <0x%.8x>\n",
           status));
           return (status);
         }
      }
     else
      {
        status = WFcheck_item_acl_inuse (NFMglobal.NFMuserid, acl_no);
        if (status != NFM_S_SUCCESS)
         {
           _NFMdebug ((fname, "Chk Item Acl In Use : status = <0x%.8x>\n",
           status));
           return (status);
         }
      }

     status = WFcheck_class_users_acl (NFMglobal.NFMuserid, acl_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Check Acl Class Users : status = <0x%.8x>\n",
        status));
        return (status);
      }

     status = WFcheck_signoff_users_acl (NFMglobal.NFMuserid, acl_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Check Acl Sign Users : status = <0x%.8x>\n",
        status));
        return (status);
      }

     sprintf (sql_str, "DELETE FROM %s WHERE %s = %d", 
              "NFMACLS", "n_aclno", acl_no);

     status = NFMstop_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Stop Trans : status = <0x%.8x>\n",
        status));
        return (status);
      }

     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "Sql Stmt Syntax : status = <0x%.8x>\n",
        status));
	ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
        return (NFM_E_SQL_STMT) ;
      }

     status = NFMreturn_serial_slot (NFMglobal.NFMuserid, "nfmacls", "n_aclno", acl_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Ret Serial Slot : status = <0x%.8x>\n",
        status));
        return (status);
      }

     status = NFMset_autocommit_on (0) ;
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Stop Trans : status = <0x%.8x>\n", status));
        return (status);     
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);     
   }


long _WFdelete_acl (acl_no, wf_no, wf_name) 
    long acl_no ;
    long wf_no ;
    char *wf_name ;
   {
     static char *fname = "WFdelete_acl" ;
     long    status, i, state_no ;
     MEMptr  return_buffer = NULL ;
     char    **data, *str, *sql_str1, temp_str [100] ;
     char    sql_str [1024];
     long    WFcheck_workflow_acl_inuse ();
     long    WFcheck_catalog_acl_inuse ();
     long    WFcheck_project_acl_inuse ();
     long    WFcheck_item_acl_inuse ();
     long    WFcheck_class_users_acl ();
     long    WFcheck_signoff_users_acl ();

     _NFMdebug ((fname, "Acl  No = <%d> : Wf No = <%d> : Wf Name = <%s>\n", 
                 acl_no, wf_no, wf_name)) ;

     if (acl_no < 5)
      {
        status = NFM_E_SYSTEM_ACL;
        ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "System Acls : status = <0x%.8x>\n",
        status));
        return (status);
      }

     status = WFcheck_item_acl_inuse (NFMglobal.NFMuserid, acl_no);
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Chk Item Acl In Use : status = <0x%.8x>\n",
		     status));
	 return (status);
       }

     status = NFMset_autocommit_off (0) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Set autocommit_on failed : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }

     /* delete entries in nfmacls, nfmaclusers, nfmcatalogaclmap,
	nfmprojectaclmap, nfmsignoffusers */

     sprintf (sql_str, "DELETE FROM %s WHERE %s = %d", 
              "NFMACLS", "n_aclno", acl_no);

     status = SQLstmt (sql_str);
     if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
      {
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "Sql Stmt Syntax : status = <0x%.8x>\n",
		    status));
	ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
	return (NFM_E_SQL_STMT) ;
      }

     sprintf (sql_str, "DELETE FROM %s WHERE %s = %d", 
              "NFMACLUSERS", "n_aclno", acl_no);

     status = SQLstmt (sql_str);
     if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
      {
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "Sql Stmt Syntax : status = <0x%.8x>\n",
		    status));
	ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
	return (NFM_E_SQL_STMT) ;
      }

     sprintf (sql_str, "SELECT n_mapno from nfmcatalogaclmap where n_aclno = %d",
	      acl_no) ;

     status = SQLquery (sql_str, &return_buffer, MEM_SIZE) ;
     if (status == SQL_S_SUCCESS)
       {
         sprintf (sql_str, "DELETE FROM %s WHERE %s = %d",
                  "NFMCATALOGACLMAP", "n_aclno", acl_no);
         status = SQLstmt (sql_str);
         if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
           {
             NFMrollback_transaction (0);
             _NFMdebug ((fname, "Sql Stmt Syntax : status = <0x%.8x>\n",
                         status));
             ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
             return (NFM_E_SQL_STMT) ;
           }
	 status = MEMbuild_array (return_buffer) ;
	 if (status != MEM_S_SUCCESS)
	   {
	     NFMrollback_transaction (0);
	     _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
			 status)) ;
	     ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	     return (NFM_E_MEM) ;
	   }
	 data = (char **) return_buffer->data_ptr ;
	 str = (char *) malloc (return_buffer->rows * 50) ;
	 if (str == NULL)
	   {
	     NFMrollback_transaction (0);
	     _NFMdebug ((fname, "malloc failed\n")) ;
	     ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
	     return (NFM_E_MALLOC) ;
	   }
	 sql_str1 = (char *) malloc (return_buffer->rows * 50 + 100) ;
	 if (sql_str1 == NULL)
	   {
	     NFMrollback_transaction (0);
	     _NFMdebug ((fname, "malloc failed\n")) ;
	     ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
	     return (NFM_E_MALLOC) ;
	   }
	 str [0] = 0 ;
	 for (i=0; i<return_buffer->rows; i++)
	   {
	     sprintf (temp_str, "(n_mapno = %d)", atol (data [i])) ;
	     if (strlen (str)) strcat (str, " OR ") ;
	     strcat (str, temp_str) ;
	     _NFMdebug ((fname, "str is %s\n",
			 str)) ;
	     status = NFMreturn_serial_slot (NFMglobal.NFMuserid, 
					     "nfmcatalogaclmap",
					     "n_mapno", atol (data [i])) ;
	     if (status != NFM_S_SUCCESS)
	       {
		 NFMrollback_transaction (0);
		 free (str) ;
		 free (sql_str1) ;
		 _NFMdebug ((fname, "Ret Serial Slot : status = <0x%.8x>\n",
			     status));
		 return (status);
	       }
	   }
	 sprintf (sql_str1, "DELETE FROM %s WHERE %s", 
		  "NFMPROJECTACLMAP", str) ;
	 status = SQLstmt (sql_str1);
	 free (str) ;
	 free (sql_str1) ;
	 if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
	   {
	     NFMrollback_transaction (0);
	     _NFMdebug ((fname, "Sql Stmt Syntax : status = <0x%.8x>\n",
			 status));
	     ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
	     return (NFM_E_SQL_STMT) ;
	   }
	 
	 status = MEMclose (&return_buffer) ;
	 if (status != MEM_S_SUCCESS)
	   {
	     NFMrollback_transaction (0);
	     free (str) ;
	     free (sql_str1) ;
	     _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
			 status)) ;
	     ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	     return (NFM_E_MEM) ;
	   }
       }
     else
       {
	 MEMclose (&return_buffer) ;
	 if (status != SQL_I_NO_ROWS_FOUND)
	   {
	     NFMrollback_transaction (0);
	     _NFMdebug ((fname, "SQLquery failed : status = <0x%.8x>\n",
			 status)) ;
	     ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
	     return (NFM_E_SQL_QUERY) ;
	   }
       }

     sprintf (sql_str, "DELETE FROM %s WHERE %s = %d", 
              "NFMSIGNOFFUSERS", "n_aclno", acl_no);

     status = SQLstmt (sql_str);
     if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
      {
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "Sql Stmt Syntax : status = <0x%.8x>\n",
		    status));
	ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
	return (NFM_E_SQL_STMT) ;
      }

     /* if acl has no other workflows -> put workflow in complete state */
     sprintf (sql_str, "Select n_aclno from nfmacls where n_workflowno = %d",
	      wf_no) ;
     
     status = SQLquery (sql_str, &return_buffer, MEM_SIZE) ;
     if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
       {
	 NFMrollback_transaction (0);
	 _NFMdebug ((fname, "Sql Stmt Syntax : status = <0x%.8x>\n",
		    status));
	 ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
	 return (NFM_E_SQL_QUERY) ;
       }

     MEMclose (&return_buffer) ;

     if (status == SQL_I_NO_ROWS_FOUND)
       {
	 strcpy  (sql_str, "select n_stateno from nfmstates where n_statename = 'WORKFLOW COMPLETE'") ;

	 status = SQLquery (sql_str, &return_buffer, MEM_SIZE) ;
	 if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
	   {
	     NFMrollback_transaction (0);
	     _NFMdebug ((fname, "Sql Stmt Syntax : status = <0x%.8x>\n",
			 status));
	     ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
	     return (NFM_E_SQL_QUERY) ;
	   }

	 status = MEMbuild_array (return_buffer) ;
	 if (status != MEM_S_SUCCESS)
	   {
	     NFMrollback_transaction (0);
	     ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	     return (NFM_E_MEM) ;
	   }

	 data = (char **) return_buffer -> data_ptr ;
	 state_no = atol (data [0]) ;
	 status = MEMclose (&return_buffer) ;
	 if (status != MEM_S_SUCCESS)
	 {
	   NFMrollback_transaction (0);
	   ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	   return (NFM_E_MEM) ;
	 }
	 
	 sprintf (sql_str, "update nfmworkflow set n_stateno = %d where n_workflowno = %d", 
		  state_no, wf_no) ;
	 status = SQLstmt (sql_str) ;
	 if (status != SQL_S_SUCCESS)
	   {
	     ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
	     _NFMdebug ((fname, "SQLstmt failed : status = <0x%.8x>\n",
			 status)) ;
	     return (NFM_E_SQL_STMT) ;
	   }
       }

     status = NFMset_autocommit_on (0) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Set autocommit_on failed : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);     
   }



 long WFcheck_workflow_acl_inuse (user_id, acl_no)
   long    user_id;
   long    acl_no;
   {
     static char *fname = "WFcheck_workflow_acl_inuse" ;
     long    status ;
     char    sql_str [1024], value [50];
 
     _NFMdebug ((fname, "Acl  No = <%d>\n", acl_no ));
     user_id = user_id ;
     sprintf (sql_str, "WHERE %s = %d", "n_aclno", acl_no);

     status = NFMget_attr_value (NFMglobal.NFMuserid, "nfmworkflow", "COUNT(*)",
              sql_str, value);
     if (status != NFM_S_SUCCESS && status != NFM_I_BAD_CONDITION)
      {
        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
        status));
        return (status);     
      }

     if (atol (value) > 0)
      {
        status = NFM_E_WF_ACL_IN_USE;
        ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "Acl In Use : status = <0x%.8x>\n", status));
        return (status);     
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);     
   }

 long WFcheck_catalog_acl_inuse (user_id, acl_no)
   long    user_id;
   long    acl_no;
   {
     static char *fname = "WFcheck_catalog_acl_inuse" ;
     long    status ;
     char    sql_str [1024], value [50];

     _NFMdebug ((fname, "Acl  No = <%d>\n", acl_no ));
     user_id = user_id ;
     sprintf (sql_str, "WHERE %s = %d", "n_aclno", acl_no);

     status = NFMget_attr_value (NFMglobal.NFMuserid, "nfmcatalogs", "COUNT(*)",
              sql_str, value);
     if (status != NFM_S_SUCCESS && status != NFM_I_BAD_CONDITION)
      {
        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
        status));
        return (status);     
      }

     if (atol (value) > 0)
      {
        status = NFM_E_CAT_ACL_IN_USE;
        ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "Acl In Use : status = <0x%.8x>\n", status));
        return (status);     
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);     
   }

 long WFcheck_project_acl_inuse (user_id, acl_no)
   long    user_id;
   long    acl_no;
   {
     static char *fname = "WFcheck_project_acl_inuse" ;
     long    status ;
     char    sql_str [1024], value [50];
  
     _NFMdebug ((fname, "Acl  No = <%d>\n", acl_no ));
     user_id = user_id ;
     sprintf (sql_str, "WHERE %s = %d", "n_aclno", acl_no);

     status = NFMget_attr_value (NFMglobal.NFMuserid, "nfmprojects", "COUNT(*)",
              sql_str, value);
     if (status != NFM_S_SUCCESS && status != NFM_I_BAD_CONDITION)
      {
        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
        status));
        return (status);     
      }

     if (atol (value) > 0)
      {
        status = NFM_E_PROJ_ACL_IN_USE;
        ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "Acl In Use : status = <0x%.8x>\n", status));
        return (status);     
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);     
   }

 long WFcheck_item_acl_inuse (user_id, acl_no)
   long    user_id;
   long    acl_no;
   {
     static char *fname = "WFcheck_item_acl_inuse" ;
     long    status ;
     char    sql_str [1024], value [50];
     MEMptr  list = NULL;
     char    **data;
     long    x;

     _NFMdebug ((fname, "Acl  No = <%d>\n", acl_no ));
     user_id = user_id ;
     sprintf (sql_str, "SELECT %s FROM %s", 
	      "n_catalogname", "NFMCATALOGS") ;
 
     status = SQLquery (sql_str, &list, MEM_SIZE);
     if (status != SQL_S_SUCCESS &&
         ((status ) != SQL_I_NO_ROWS_FOUND))
      {
        MEMclose (&list);
        status = NFM_E_SQL_STMT;
        ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "Sql Query Syntax : status = <0x%.8x>\n",
        status));
        return (status);     
      }

     status = MEMbuild_array (list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        status = NFM_E_MEM;
        ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
        status));
        return (status);     
      }

     data = (char **) list -> data_ptr;

     for (x = 0; x < list -> rows; ++x)
      {
	sprintf (sql_str, "WHERE %s = %d", "n_aclno", acl_no);
  
        status = NFMget_attr_value (NFMglobal.NFMuserid, data [x], "COUNT(*)",
				   sql_str, value);

	if (status != NFM_S_SUCCESS && status != NFM_I_BAD_CONDITION)
         {
           MEMclose (&list);
           _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
		       status));
           return (status);     
         }

	if (atol (value) > 0)
	  {
	    MEMclose (&list);
	    status = NFM_E_ITEM_ACL_IN_USE;
	    ERRload_struct(NFM,status,"",NULL);
	    _NFMdebug ((fname, "Acl In Use : status = <0x%.8x>\n",
			status));
	    return (status);     
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

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);     
   }

 long WFcheck_class_users_acl (user_id, acl_no)
   long   user_id;
   long   acl_no;
   {
     static char *fname = "WFcheck_class_user_acl" ;
     long    status ;
     char    sql_str [1024], value [50];
   
     _NFMdebug ((fname, "Acl  No = <%d>\n", acl_no ));
     user_id=user_id ;
     sprintf (sql_str, "WHERE %s = %d", "n_aclno", acl_no);

     status = NFMget_attr_value (NFMglobal.NFMuserid, "nfmaclusers", "COUNT(*)",
              sql_str, value);
     if (status != NFM_S_SUCCESS && status != NFM_I_BAD_CONDITION)
      {
        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
        status));
        return (status);     
      }

     if (atol (value) > 0)
      {
        status = NFM_E_CLASS_USERS_EXIST;
        ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "Class Users Exist : status = <0x%.8x>\n",
        status));
        return (status);     
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);     
   }

 long WFcheck_signoff_users_acl (user_id, acl_no)
   long   user_id;
   long   acl_no;
   {
     static char *fname = "WFcheck_signoff_users_acl" ;
     long    status ;
     char    sql_str [1024], value [50];

     _NFMdebug ((fname, "Acl  No = <%d>\n", acl_no ));
     user_id = user_id ;
     sprintf (sql_str, "WHERE %s = %d", "n_aclno", acl_no);

     status = NFMget_attr_value (NFMglobal.NFMuserid, "nfmsignoffusers", "COUNT(*)",
              sql_str, value);
     if (status != NFM_S_SUCCESS && status != NFM_I_BAD_CONDITION)
      {
        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
        status));
        return (status);     
      }

     if (atol (value) > 0)
      {
        status = NFM_E_SIGN_USERS_EXIST;
        ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "Sign Users Exist : status = <0x%.8x>\n",
        status));
        return (status);     
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);     
   }
