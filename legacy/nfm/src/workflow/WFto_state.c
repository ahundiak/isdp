#include "machine.h"
#include "WF.h"

 extern struct WFstruct WFinfo;

 long WFset_to_state (user_id, app_name, app_ptr)
   long      user_id;
   char      *app_name;
   MSGptr    app_ptr;
   {      
     static char *fname = "WFset_to_state" ;
     long    status;
     long    WFenter_sdp_trans ();
     long    WFenter_admin_trans ();
     long    WFenter_catalog_trans ();
     long    WFenter_project_trans ();
     long    WFenter_item_trans ();

     _NFMdebug ((fname, "App  Name = <%s> : Entity = <%s> : Command = <%d> : Trans = <%d> : Work Flow = <%d> : Curr State = <%d> : Next State = <%d> : Acl = <%d>\n", 
		 app_name, WFinfo.entity, WFinfo.command, WFinfo.transition,
		 WFinfo.workflow, WFinfo.curr_state, WFinfo.next_state,
		 WFinfo.acl));

     _NFMdebug ((fname, "Project    = <%d>  : Table = <%d> : Item = <%d>\n", 
		 WFinfo.proj_no, WFinfo.catalog_no, WFinfo.item_no));


     status = NFMset_wf_state (app_name, app_ptr.error_no, app_ptr.error_msg);

     if (status != NFM_S_SUCCESS)
     {
        _NFMdebug ((fname, "EXIT : status = <0x%.8x>\n", status));
        return (status);
     }
 
     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
  }

/******************************************************************************

   See NFMto_state.c for the set to state code.
   It replaced this function. 2/19/92 (DT)

     status = NFMstop_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Stop Transaction : status = <0x%.8x>\n",
        status));
        return (status);
      }

     if (app_ptr.error_no == NFM_S_SUCCESS)
      {
        if (WFinfo.transition > 0)
         {
           status = NFMpost_execute_process( WFinfo.transition, app_ptr );
           _NFMdebug ((fname, "Post Trans Proc : status = <0x%.8x>\n",
              status));
         }
	if (WFinfo.entity[0] == 'S') 
         {
           status = WFenter_sdp_trans (user_id);
           if (status != NFM_S_SUCCESS)
            {  
              NFMrollback_transaction (0);
              _NFMdebug ((fname, "Get Sdp Trans  : status = <0x%.8x>\n",
              status));
              return (status);           
            }
         }
        else if (WFinfo.entity[0] == 'A') 
         {
           status = WFenter_admin_trans (user_id);
           if (status != NFM_S_SUCCESS)
            {
              NFMrollback_transaction (0);
              _NFMdebug ((fname, "Get Tab Trans : status = <0x%.8x>\n",
              status));
              return (status);
            }
         }
        else if (WFinfo.entity[0] == 'C')
         {
           status = WFenter_catalog_trans (user_id);
           if (status != NFM_S_SUCCESS)
            {
              NFMrollback_transaction (0);
              _NFMdebug ((fname, "Get Cat Trans : status = <0x%.8x>\n",
              status));
              return (status);
            }
         }
        else if (WFinfo.entity[0] == 'P')
         {
           status = WFenter_project_trans (user_id);
           if (status != NFM_S_SUCCESS)
            {
              NFMrollback_transaction (0);
              _NFMdebug ((fname, "Get Proj Trans : status = <0x%.8x>\n",
              status));
              return (status);
            }
         }
        else if (WFinfo.entity[0] == 'I') 
         {
           status = WFenter_item_trans (user_id);
           if (status != NFM_S_SUCCESS)
            {
              NFMrollback_transaction (0);
              _NFMdebug ((fname, "Get Item Trans : status = <0x%.8x>\n",
              status));
              return (status);
            }
         }
        else if (WFinfo.entity[0] == 'N')
         {
            _NFMdebug ((fname, "No Entity\n")) ;
         }
        else if (WFinfo.entity[0] == 'D')
         {
            _NFMdebug ((fname, "No check validation\n")) ;
         }
        else 
         {
            NFMrollback_transaction (0);
            status = NFM_E_INVALID_ENTITY;
	    ERRload_struct(NFM,status,"",NULL);
            _NFMdebug ((fname, "Invalid Entity : status = <0x%.8x>\n",
            status));
            return (status);
         }
      }

     if (app_ptr.error_no != NFM_E_CANCEL)
      {
        status = WFtransition_log (user_id, app_name, app_ptr);
*************  mms - ignore errors **************************
        if (status != NFM_S_SUCCESS)
         {
           NFMrollback_transaction (0);
           _NFMdebug ((fname, "Enter Activity Log : status = <0x%.8x>\n",
           status));
           return (status);
         }
***************************************************************
        if ((WFinfo.notify[0] == 'Y') && (strcmp (WFinfo.entity, "N")))
         {
           status = WFtransition_mail (user_id, app_name, app_ptr);
           if (status != NFM_S_SUCCESS)
            {
              NFMrollback_transaction (0);
              _NFMdebug ((fname, "Send Mail : status = <0x%.8x>\n",
              status));
              return (status);
            }
         }
      }

     NFMreset_message_struct (user_id);

     _WFinit_wfinfo () ;

     status = NFMstart_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Start Transaction : status = <0x%.8x>\n",
        status));
        return (status);
      }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }
******************************************************************************/

 long WFenter_sdp_trans (user_id)
   long    user_id;
   {
     static char *fname = "WFenter_sdp_trans" ;
     long   status, atol ();
     char   sql_str [1024];

     if (WFinfo.next_state > 1)
      {
        sprintf (sql_str, "UPDATE %s SET %s = %d WHERE %s = %d",
                 "NFMWORKFLOW", "n_stateno", WFinfo.next_state,
                 "n_workflowno", WFinfo.workflow);

        status = SQLstmt (sql_str);
        if (status != SQL_S_SUCCESS)
         {
           _sql_error (status);
           status = NFM_E_SQL_STMT;
	    ERRload_struct(NFM,status,"",NULL);
           _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
           status));
           return (status); 
         }
      }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS); 
   }

 long WFenter_admin_trans (user_id)
   long    user_id;
   {
     static char *fname = "WFenter_admin_trans" ;
     long   status;

     if (WFinfo.next_state > 1)
      {
        status = NFM_E_BAD_ADMIN_COMMAND;
	    ERRload_struct(NFM,status,"",NULL);
        _NFMdebug ((fname, "Bad Admin Command : status = <0x%.8x>\n",
        status));
        return (status); 
      }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS); 
   }

 long WFenter_catalog_trans (user_id)
   long    user_id;
   {
     static char *fname = "WFenter_catalog_trans" ;
     long   status, atol ();
     char   sql_str [2048] ;

     if ((WFinfo.next_state > 1) && (WFinfo.catalog_no > 0))
      {
        sprintf(sql_str,
        "UPDATE nfmcatalogs set n_stateno = %d WHERE n_catalogno = %d",
        WFinfo.next_state, WFinfo.catalog_no);
        status = SQLstmt (sql_str);
        if (status != SQL_S_SUCCESS)
         {
           _sql_error (status);
           status = NFM_E_SQL_STMT;
	    ERRload_struct(NFM,status,"",NULL);
           _NFMdebug ((fname, "SQL Stmt Synt : status = <0x%.8x>\n",
           status));
           return (status); 
         }
      }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS); 
   }

 long WFenter_project_trans (user_id)
   long    user_id;
   {
     static char *fname = "WFenter_project_trans" ;
     long   status, atol ();
     char   sql_str [1024];

     if (WFinfo.next_state > 1)
      {
        if (WFinfo.proj_no < 1)
         {
           status = NFM_E_BAD_PROJECT;
	    ERRload_struct(NFM,status,"",NULL);
           _NFMdebug ((fname, "Bad Project : status = <0x%.8x>\n",
           status));
           return (status); 
         }

        sprintf (sql_str, "UPDATE %s SET %s = %d WHERE %s = %d",
                "NFMPROJECTS", "n_stateno", WFinfo.next_state,
                "n_projectno", WFinfo.proj_no);

        status = SQLstmt (sql_str);
        if (status != SQL_S_SUCCESS)
         {
           _sql_error (status);
           status = NFM_E_SQL_STMT;
	    ERRload_struct(NFM,status,"",NULL);
           _NFMdebug ((fname, "SQL Stmt Synt : status = <0x%.8x>\n",
           status));
           return (status); 
         }
      }

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS); 
   }

 long WFenter_item_trans (user_id)
   long    user_id;
   {
     static char *fname = "WFenter_item_trans" ;
     long   status;
     char   sql_str [2048] ;
     long   WFdelete_signoff ();

     if (WFinfo.next_state > 1)
      {
        if(WFinfo.curr_state != -1)
        {
       	      sprintf(sql_str,
	      "UPDATE %s SET %s = %d , %s = %d WHERE %s = %d",
  	      WFinfo.catalog_name, 
              "n_prevstateno", WFinfo.curr_state,
              "n_stateno ", WFinfo.next_state,
              "n_itemno", WFinfo.item_no);
        }
        else
        {
       	      sprintf(sql_str,
	      "UPDATE %s SET %s = %d WHERE %s = %d",
  	      WFinfo.catalog_name, 
              "n_stateno ", WFinfo.next_state,
              "n_itemno", WFinfo.item_no);
        }
        status = SQLstmt (sql_str);
        if (status != SQL_S_SUCCESS)
         {
           _sql_error (status);
           status = NFM_E_SQL_STMT;
	    ERRload_struct(NFM,status,"",NULL);
           _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
           status));
           return (status); 
         }        
      }
   
/*     status = WFdelete_signoff (user_id);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "Delete Sign Off : status = <0x%.8x>\n",
        status));
        return (status); 
      }
*/
     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS); 
   }

 long WFdelete_signoff (user_id)
   long    user_id;
   {
     static char *fname = "WFdelete_signoff" ;
     long    status;
     char    sql_str [1024], value [50];

     if (WFinfo.next_state > 1 &&
         WFinfo.next_state != WFinfo.curr_state)
      {
	sprintf (value, "%d", WFinfo.catalog_no);

	sprintf (sql_str,
		 "DELETE FROM %s WHERE %s = %s AND %s = %d",
		 "NFMSIGNOFF", "n_catalogno", value, "n_itemno", WFinfo.item_no);

        status = SQLstmt (sql_str);
        if (status != SQL_S_SUCCESS &&
            ((status) != SQL_I_NO_ROWS_FOUND))
         {
            _sql_error (status);
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
