#include "machine.h"
#include "WF.h"

 extern struct WFstruct WFinfo;
 extern struct NFMglobal_st NFMglobal ;

 long WFcheck_signoff (user_id)
 long user_id ;
   {
     static char *fname = "WFcheck_signoff" ;
     MEMptr  list = NULL ;
     long    status, atol() ;
     long    no, no_users, no_act_so ;
     char    override [10];
     char    sql_str [1024] ;
     long    WFget_signoffs () ;

     /* Get minimum number of users needed to signoff on the state */
     /* override = "MJ" if majority needs to signoff , else "MN" */

     _NFMdebug ((fname, "ENTER\n")) ;
     user_id = user_id ; 
     status = NFMcheck_state_signoff (NFMglobal.NFMuserid, WFinfo.curr_state,
              &no, override);
     if (status != NFM_S_SUCCESS)
      {  
        _NFMdebug ((fname, "Check Sign State : status = <0x%.8x>\n",
		  status));
        return (status);                
      }
     
     if (no > 0)
      {
	status = WFget_signoffs (NFMglobal.NFMuserid, WFinfo.curr_state,
				 WFinfo.acl, WFinfo.catalog_no,
				 WFinfo.item_no, 
				 &no_users, &no_act_so) ;
	if (status != NFM_S_SUCCESS)
	  {
	    _NFMdebug ((fname, "Integrity of Nfmsignoff tables Bad : status = <0x%.8x>\n", status) );
	    return (status) ;
	  }

         /* check if override has occured */

      sprintf (sql_str, "select n_reason from \
nfmsignoff, nfmsignoffusers WHERE %s = %d AND %s = %d AND %s AND %s AND %s AND %s %d", 
	       "nfmsignoff.n_catalogno", WFinfo.catalog_no, 
	       "nfmsignoff.n_itemno", WFinfo.item_no,
	       "nfmsignoff.n_userno = nfmsignoffusers.n_userno",
	       "nfmsignoffusers.n_override = 'Y'",
	       "nfmsignoff.n_signoff = 'O'",
	       "nfmsignoff.n_stateno = ", WFinfo.curr_state);

	status = SQLquery (sql_str, &list, MEM_SIZE);
	
	MEMclose (&list) ;

	if (status != SQL_S_SUCCESS)
	  {
	    if (!(status == SQL_I_NO_ROWS_FOUND)) 
	      {
		status = NFM_E_SQL_QUERY;
		ERRload_struct(NFM,status,"",NULL);
		_NFMdebug ((fname, "SQL Query Syntax : status = <0x%.8x>\n", 
			  status));
	      return (status);
	      }
	  }
	else {
	  /* Someone has overidden */
	  _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
	  return (NFM_S_SUCCESS);     
	}

        if (! strcmp (override, "MJ"))
         {
	   if (no_act_so < ((no_users/2)+1))
            {
	        status = NFM_E_NOT_ALL_MAJORITY ;
		ERRload_struct(NFM,status,"",NULL);
               _NFMdebug ((fname, "Majority Not Comp : status = <0x%.8x>\n",
               status));
               return (status);     
            }
         }
        else if (! strcmp (override, "MN")) 
         {
            if (no_users != no_act_so)
             {
               status = NFM_E_NOT_ALL_SIGNEDOFF;
		ERRload_struct(NFM,status,"",NULL);
               _NFMdebug ((fname, "Signoff Not Comp : status = <0x%.8x>\n",
               status));
               return (status);     
             }
         }
        else
	  /* Signoffs are not used on this state */ 
         {
           status = NFM_E_BAD_SIGNOFF;
		ERRload_struct(NFM,status,"",NULL);
           _NFMdebug ((fname, "In Valid Signoff : status = <0x%.8x>\n",
           status));
           return (status);     
         }

      }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);     
   }


 long WFvalidate_signoff_users (user_id)
long user_id ;
   {
     static char *fname = "WFvalidate_signoff" ;
     long    status, atol();
     char    sql_str [1024];
     char    value1 [50];

     sprintf (sql_str, "WHERE %s = %d AND %s = %d AND %s = %d",
              "n_aclno", WFinfo.acl, "n_stateno", WFinfo.curr_state,
              "n_userno", NFMglobal.NFMuserno);

     status = NFMget_attr_value (user_id, "NFMSIGNOFFUSERS", 
              "n_userno", sql_str, value1);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           status = NFM_E_USER_ACCESS_PRIV;
		ERRload_struct(NFM,status,"",NULL);
           _NFMdebug ((fname, "Priv Voilation : status = <0x%.8x>\n",
           status));
           return (status);     
         }

        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
        status));
        return (status);     
      }

     if (atol (value1) != NFMglobal.NFMuserno)
      {
        status = NFM_E_USER_ACCESS_PRIV;
		ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "Priv Voilation : status = <0x%.8x>\n",
        status));
        return (status);     
      }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);     
   }

 long WFvalidate_signoffusers_acl (user_id, cat_name, item_name, item_rev)
long user_id ;
char *cat_name, *item_name, *item_rev ;
   {
     static char *fname = "WFvalidate_signoffusers_acl" ;
     long    status, atol();
     char    sql_str [1024];
     char    value1 [50];

     _NFMdebug ((fname, "Catalog Name = <%s> : Item Name = <%s> : Item Rev = <%s>\n",
		 cat_name, item_name, item_rev)) ;
     user_id = user_id ;
     sprintf (sql_str, "WHERE n_itemname = '%s' AND n_itemrev = '%s'", 
	      item_name, item_rev) ;

     status = NFMget_attr_value (NFMglobal.NFMuserid, cat_name, 
              "n_aclno", sql_str, value1);

     if (status != NFM_S_SUCCESS)
      {
	status = NFM_E_BAD_ITEM;
	ERRload_struct(NFM,status,"",NULL);
	_NFMdebug ((fname, "Priv Voilation : status = <0x%.8x>\n",
		  status));
	return (status);     
      }

      sprintf (sql_str, "WHERE %s = %d AND %s = %d",
              "n_aclno", atoi (value1) , "n_userno", NFMglobal.NFMuserno);

     status = NFMget_attr_value (NFMglobal.NFMuserid, "NFMSIGNOFFUSERS", 
              "n_userno", sql_str, value1);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           status = NFM_E_USER_ACCESS_PRIV;
           ERRload_struct(NFM,status,"",NULL);
           _NFMdebug ((fname, "Priv Voilation : status = <0x%.8x>\n",
           status));
           return (status);     
         }

        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
        status));
        return (status);     
      }

     if (atol (value1) != NFMglobal.NFMuserno)
      {
        status = NFM_E_USER_ACCESS_PRIV;
		ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "Priv Voilation : status = <0x%.8x>\n",
        status));
        return (status);     
      }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);     
   }


long WFhistory_signoff (user_id)
   long    user_id;
{
     static char *fname = "WFhistory_signoff" ;
     long    status;
     char    sql_str [1024], value [50];

     user_id = user_id ;
     if (WFinfo.next_state > 1 &&
         WFinfo.next_state != WFinfo.curr_state)
       {
	sprintf (value, "%d", WFinfo.catalog_no);

	sprintf (sql_str,
		 "UPDATE NFMSIGNOFF SET n_history = 'Y' WHERE n_catalogno = %s AND n_itemno = %d and n_stateno = %d",
		 value, WFinfo.item_no, WFinfo.curr_state);
	
        status = SQLstmt (sql_str);

        if (status != SQL_S_SUCCESS &&
            ((status ) != SQL_I_NO_ROWS_FOUND))
	  {
            status = NFM_E_SQL_STMT;
		ERRload_struct(NFM,status,"",NULL);
            _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
            status));
            return (status);
	  }
      }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }

 long WFget_signoffs (user_id, state_no, acl_no, 
		       catalog_no, item_no, no_users, no_act_users)
   long    user_id;
   long    state_no, acl_no;
   long    item_no, catalog_no ;
   long    *no_users;
   long    *no_act_users;
   {
     static char *fname = "WFget_signoffs" ;
     long    status, atol (), x, y, found ;
     char    sql_str [1024] ;
     char    **data, **data1 ;
     MEMptr  return_buffer = NULL, return_buffer1 = NULL ;

     _NFMdebug ((fname, "State No = <%d> : Acl No = <%d>\n", 
		 state_no, acl_no));
     user_id = user_id ;
     *no_users = 0;

     sprintf (sql_str, 
	      "SELECT n_userno FROM NFMSIGNOFFUSERS WHERE n_aclno = %d and n_stateno = %d",
	      acl_no, state_no) ;

     status = SQLquery (sql_str, &return_buffer, 2*MEM_SIZE) ;
     if (status != SQL_S_SUCCESS)
       {
	 MEMclose (&return_buffer) ;
	 if (status == SQL_I_NO_ROWS_FOUND)
	   {
	     ERRload_struct (NFM, NFM_E_BAD_SIGNOFF, NULL, NULL) ;
	     return (NFM_E_BAD_SIGNOFF) ;
	   }
	 ERRload_struct (NFM, NFM_E_SQL_QUERY, NULL, NULL) ;
	 return (NFM_E_SQL_QUERY) ;
       }

     *no_users = return_buffer -> rows ;

     *no_act_users = 0 ;

     sprintf (sql_str, 
	      "SELECT n_userno FROM NFMSIGNOFF WHERE n_catalogno = %d and n_itemno = %d and (n_history != 'Y' or n_history is NULL)",
	      catalog_no, item_no) ;

     status = SQLquery (sql_str, &return_buffer1, 2*MEM_SIZE) ;
     if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
       {
	 MEMclose (&return_buffer) ;
	 MEMclose (&return_buffer1) ;
	 ERRload_struct (NFM, NFM_E_SQL_QUERY, NULL, NULL) ;
	 return (NFM_E_SQL_QUERY) ;
       }

     if (status == SQL_I_NO_ROWS_FOUND)
     {
       MEMclose (&return_buffer) ;
       MEMclose (&return_buffer1) ;
       *no_act_users = 0 ;
       return (NFM_S_SUCCESS) ;
     }

     *no_act_users = return_buffer1 -> rows ;

     _NFMdebug ((fname, "no of signoff is %d : the ones that have signed off is %d\n", 
		 *no_users, *no_act_users)) ;

/*  If no of active so users > allowable so user purge signoff table */
    if (*no_act_users > *no_users)
      {
	MEMclose (&return_buffer) ;
	MEMclose (&return_buffer1) ;
	_NFMdebug ((fname, "NFMsignoff table has more entries that the ones in NFMsignoffusers : <0x%.8x>\n",
		  NFM_I_SO_AUTO_PURGE));
	ERRload_struct (NFM, NFM_I_SO_AUTO_PURGE, NULL, NULL) ;
	sprintf (sql_str, 
		 "DELETE FROM NFMSIGNOFF WHERE n_itemno = %d and n_catalogno = %d \
AND n_history != 'Y'",
		 item_no, catalog_no) ;
	SQLexec_imm (sql_str) ;
	return (NFM_I_SO_AUTO_PURGE) ;
      }

     status = MEMbuild_array (return_buffer) ;
     if (status != MEM_S_SUCCESS)
       {
	 MEMclose (&return_buffer) ;
	 MEMclose (&return_buffer1) ;
	 ERRload_struct (NFM, NFM_E_MEM, NULL, NULL) ;
	 return (NFM_E_MEM) ;
       }

     status = MEMbuild_array (return_buffer1) ;
     if (status != MEM_S_SUCCESS)
       {
	 MEMclose (&return_buffer) ;
	 MEMclose (&return_buffer1) ;
	 ERRload_struct (NFM, NFM_E_MEM, NULL, NULL) ;
	 return (NFM_E_MEM) ;
       }

     data = (char **) return_buffer->data_ptr ;
     data1 = (char **) return_buffer1->data_ptr ;

     for (x=0; x<return_buffer1->rows; x++)
       {
	 found = 0 ;
	 for (y=0; y<return_buffer->rows; y++)
	   {
	     if (strcmp (data1 [x], data [y]) == 0) 
	       {
		 found = 1 ;
		 break ;
	       }
	   }
	 if (!found)
	   {
	     MEMclose (&return_buffer) ;
	     MEMclose (&return_buffer1) ;
	     sprintf (sql_str,
		      "DELETE FROM NFMSIGNOFF WHERE n_itemno = %d AND \
n_catalogno = %d and n_history != 'Y'",
		      item_no, catalog_no) ;
	     _NFMdebug ((fname, "User is not a valid signoff user for this state : status : <0x%.8x>\n", status));
	     SQLexec_imm (sql_str) ;
	     ERRload_struct (NFM, NFM_I_SO_AUTO_PURGE, NULL, NULL) ;
	     return (NFM_I_SO_AUTO_PURGE) ; 
	   }
	 for (y=x+1; y<return_buffer1->rows; y++)
	   {
	     if (strcmp (data1 [x], data1 [y]) == 0)
	       {
		 MEMclose (&return_buffer) ;
		 MEMclose (&return_buffer1) ;
		 sprintf (sql_str,
			  "DELETE FROM NFMSIGNOFF WHERE n_itemno = %d AND \
n_catalogno = %d and n_history != 'Y'",
			  item_no, catalog_no) ;
		 _NFMdebug ((fname, "Duplicate user in NFMsignoff table : status : <0x%.8x>\n",
			   NFM_I_SO_AUTO_PURGE));
		 SQLexec_imm (sql_str) ;
		 ERRload_struct (NFM, NFM_I_SO_AUTO_PURGE, NULL, NULL) ;
		 return (NFM_I_SO_AUTO_PURGE) ;
	       }
	   }
       }
     
     MEMclose (&return_buffer) ;
     MEMclose (&return_buffer1) ;

     _NFMdebug ((fname, "No Sign Off Users = <%d> : No Act Sign Off Users = <%d> : SUCCESSFUL\n", 
		 *no_users, *no_act_users));
     return (NFM_S_SUCCESS);
   }



 long WFdup_signoffs (user_id, state_no, acl_no, 
		      catalog_no, item_no, no_users, no_act_users)
   long    user_id;
   long    state_no, acl_no;
   long    item_no, catalog_no ;
   long    *no_users;
   long    *no_act_users;
   {
     static char *fname = "WFdup_signoffs" ;
     long    status, atol (), x, y, found, already_in_tab ;
     char    sql_str [1024], s_userno [10] ;
     char    **data, **data1 ;
     MEMptr  return_buffer = NULL, return_buffer1 = NULL ;

     _NFMdebug ((fname, "State No = <%d> : Acl No = <%d>\n", 
		 state_no, acl_no));

     *no_users = 0;
     user_id = user_id ;
     sprintf (sql_str, 
	      "SELECT n_userno FROM NFMSIGNOFFUSERS WHERE n_aclno = %d and n_stateno = %d",
	      acl_no, state_no) ;

     status = SQLquery (sql_str, &return_buffer, 2*MEM_SIZE) ;
     if (status != SQL_S_SUCCESS)
       {
	 MEMclose (&return_buffer) ;
	 if (status == SQL_I_NO_ROWS_FOUND)
	   {
	     ERRload_struct (NFM, NFM_E_BAD_SIGNOFF, NULL, NULL) ;
	     return (NFM_E_BAD_SIGNOFF) ;
	   }
	 ERRload_struct (NFM, NFM_E_SQL_QUERY, NULL, NULL) ;
	 return (NFM_E_SQL_QUERY) ;
       }

     *no_users = return_buffer -> rows ;

     *no_act_users = 0 ;

     sprintf (sql_str, 
	      "SELECT n_userno FROM NFMSIGNOFF WHERE n_catalogno = %d and n_itemno = %d and n_history != 'Y'",
	      catalog_no, item_no) ;

     status = SQLquery (sql_str, &return_buffer1, 2*MEM_SIZE) ;
     if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
       {
	 MEMclose (&return_buffer) ;
	 MEMclose (&return_buffer1) ;
	 ERRload_struct (NFM, NFM_E_SQL_QUERY, NULL, NULL) ;
	 return (NFM_E_SQL_QUERY) ;
       }

     if (status == SQL_I_NO_ROWS_FOUND)
     {
       MEMclose (&return_buffer) ;
       MEMclose (&return_buffer1) ;
       *no_act_users = 0 ;
       return (NFM_S_SUCCESS) ;
     }

     *no_act_users = return_buffer1 -> rows ;

     _NFMdebug ((fname, "no of signoff is %d : the ones that have signed off is %d\n", 
		 *no_users, *no_act_users)) ;

/*  If no of active so users > allowable so user purge signoff table */
    if (*no_act_users > *no_users)
      {
	MEMclose (&return_buffer) ;
	MEMclose (&return_buffer1) ;
	_NFMdebug ((fname, "NFMsignoff table has more entries that the ones in NFMsignoffusers : <0x%.8x>\n",
		  NFM_I_SO_AUTO_PURGE));
	ERRload_struct (NFM, NFM_I_SO_AUTO_PURGE, NULL, NULL) ;
	sprintf (sql_str, 
		 "DELETE FROM NFMSIGNOFF WHERE n_itemno = %d and n_catalogno = %d \
AND n_history != 'Y'",
		 item_no, catalog_no) ;
	SQLexec_imm (sql_str) ;
	return (NFM_I_SO_AUTO_PURGE) ;
      }

     status = MEMbuild_array (return_buffer) ;
     if (status != MEM_S_SUCCESS)
       {
	 MEMclose (&return_buffer) ;
	 MEMclose (&return_buffer1) ;
	 ERRload_struct (NFM, NFM_E_MEM, NULL, NULL) ;
	 return (NFM_E_MEM) ;
       }

     status = MEMbuild_array (return_buffer1) ;
     if (status != MEM_S_SUCCESS)
       {
	 MEMclose (&return_buffer) ;
	 MEMclose (&return_buffer1) ;
	 ERRload_struct (NFM, NFM_E_MEM, NULL, NULL) ;
	 return (NFM_E_MEM) ;
       }

     data = (char **) return_buffer->data_ptr ;
     data1 = (char **) return_buffer1->data_ptr ;

     sprintf (s_userno, "%d", NFMglobal.NFMuserno);

     already_in_tab = 0 ;

     for (x=0; x<return_buffer1->rows; x++)
       {
	 if (strcmp (data1 [x], s_userno) == 0)
	   already_in_tab = 1 ;

	 found = 0 ;
	 for (y=0; y<return_buffer->rows; y++)
	   {
	     if (strcmp (data1 [x], data [y]) == 0) 
	       {
		 found = 1 ;
		 break ;
	       }
	   }
	 if (!found)
	   {
	     MEMclose (&return_buffer) ;
	     MEMclose (&return_buffer1) ;
	     sprintf (sql_str,
		      "DELETE FROM NFMSIGNOFF WHERE n_itemno = %d AND \
n_catalogno = %d and n_history != 'Y'",
		      item_no, catalog_no) ;
	     _NFMdebug ((fname, "User is not a valid signoff user for this state : status : <0x%.8x>\n", status));
	     SQLexec_imm (sql_str) ;
	     ERRload_struct (NFM, NFM_I_SO_AUTO_PURGE, NULL, NULL) ;
	     return (NFM_I_SO_AUTO_PURGE) ; 
	   }
	 for (y=x+1; y<return_buffer1->rows; y++)
	   {
	     if (strcmp (data1 [x], data1 [y]) == 0)
	       {
		 MEMclose (&return_buffer) ;
		 MEMclose (&return_buffer1) ;
		 sprintf (sql_str,
			  "DELETE FROM NFMSIGNOFF WHERE n_itemno = %d AND \
n_catalogno = %d and n_history != 'Y'",
			  item_no, catalog_no) ;
		 _NFMdebug ((fname, "Duplicate user in NFMsignoff table : status : <0x%.8x>\n",
			   NFM_I_SO_AUTO_PURGE));
		 SQLexec_imm (sql_str) ;
		 ERRload_struct (NFM, NFM_I_SO_AUTO_PURGE, NULL, NULL) ;
		 return (NFM_I_SO_AUTO_PURGE) ;
	       }
	   }
       }
     
     MEMclose (&return_buffer) ;
     MEMclose (&return_buffer1) ;

     if (already_in_tab)
       {
	 _NFMdebug ((fname, "Failure : User already signed off\n")) ;
	 ERRload_struct (NFM, NFM_E_USER_ALREADY_SIGNED_OFF, "", "") ;
	 return (NFM_E_USER_ALREADY_SIGNED_OFF);
       }

     _NFMdebug ((fname, "No Sign Off Users = <%d> : No Act Sign Off Users = <%d> : SUCCESSFUL\n", 
		 *no_users, *no_act_users));
     return (NFM_S_SUCCESS);
   }



 long NFMcheck_no_signoff (user_id, state_no, acl_no, no_users)
   long    user_id;
   long    state_no, acl_no;
   long    *no_users;
   {
     char *fname = "NFMcheck_no_signoff" ;
     long    status, atol ();
     char    sql_str [1024], value [50];

     *no_users = 0;
     user_id = user_id ;
     _NFMdebug ((fname, "State No      = <%d> : Acl No = <%d>\n",
		 state_no, acl_no)) ;

     sprintf (value, "%d", acl_no);
    
     sprintf (sql_str, "WHERE %s = %d AND %s = %s",
                 "n_stateno", state_no, "n_aclno", value);

     status = NFMget_attr_value (NFMglobal.NFMuserid, "NFMSIGNOFFUSERS", "COUNT(*)",
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           ERRload_struct (NFM, NFM_E_BAD_STATE, "", NULL);
           _NFMdebug ((fname, "No Such State : status = <0x%.8x>\n",
           NFM_E_BAD_STATE));
           return (NFM_E_BAD_STATE);
         }

        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
        status));
        return (status);
      }

     *no_users = atol (value);

     _NFMdebug ((fname, "SUCCESSFUL : No Sign Off Users = <%d>\n", *no_users));
     return (NFM_S_SUCCESS);
   }


