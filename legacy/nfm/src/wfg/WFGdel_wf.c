#include "machine.h"
#include "WFG.h"

/* extern struct WFstruct WFinfo;  */

 /****************************************************************************
  *                                                                          *
  *  Function:   _WFGdelete_workflow                                         *
  *  Date:       May 20, 1991                                                * 
  *                                                                          *
  *  This function will delete a workflow from the NFM database if it is not *
  *  in use.                                                                 *  
  *                                                                          *
  ****************************************************************************/


 long WFGdelete_workflow (user_id, workflowname)
   long   user_id;
   char   *workflowname;  /* if the no is not given use the name */
   {
     long     status = NFM_S_SUCCESS;
     long     workflowno = 0;
     char     out_str[80];
     char     sql_str [512];
     static   char* fname = "WFGdelete_workflow";

     /* external functions */

     long _WFGcheck_wf_in_use ();
     long _WFGget_workflow_no ();

     _NFMdebug ((fname, ": User Id = <%d>  ", user_id     ));
     _NFMdebug ((fname, ": Wf Name = <%s>\n", workflowname));

     /* if the workflowname is null return an error code */

     if (strcmp (workflowname, "") == 0) 
      {
         _NFMdebug ((fname, ": Error: The workflowname is null\n"));
         status = NFM_E_NULL_WF;
         ERRload_struct (NFM, status, NULL);
         _NFMdebug ((fname, ": return status = <0x%.8x>\n", status));
         return (status);
      }
 
     /* no workflow given, get the workflow number from the name */

     status = _WFGget_workflow_no (workflowname, &workflowno); 
     if (status != NFM_S_SUCCESS)
      {
         _NFMdebug ((fname, ": _WFget_workflow_no : status = <0x%.8x>\n",
                     status));
         _NFMdebug ((fname, ": return status = <0x%.8x>\n", status));
         return (status);
      }

     if (workflowno < 5)
      {
         /* Invalid workflow specified: User cannot delete system wf's */

         _NFMdebug ((fname, ": User cannot delete system workflows\n"));
         status = NFM_E_DEL_SYSTEM_WF;
         ERRload_struct (NFM, status, NULL);
         _NFMdebug ((fname, ": return status = <0x%.8x>\n", status));
         return (status);
      }

     /* check to see if the workflow is usable */

     status =  _WFGcheck_wf_in_use (workflowno);
     if (status != NFM_I_WF_NOT_IN_USE)
      {
         if (status == NFM_I_WF_IN_USE)
          { 
             /* The workflow specified is currently being used. */

             _NFMdebug((fname, ": Workflow <%s> is in use, cannot delete it.\n",
                         workflowname));
             ERRload_struct (NFM, status, NULL);
          }
         _NFMdebug ((fname, ": return status = <0x%.8x>\n", status));
         return (status);
      }

     /* If there are any single tics in the workflow name tic_it (RIS) */

     out_str[0] = 0;
     WFGtic_it (workflowname, out_str);

     /* A rollback will be done upon detection of a SQL error other than
        SQL_I_NO_ROWS_FOUND                                              */

     /* Begin Work */

     status = NFMstop_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname,": Stop Transaction : status = <0x%.8x>\n", status));
        return (status);
      }

     /* Delete all the rows from NFMaccess for the classes/transitions */

     strcpy (sql_str, "DELETE FROM nfmaccess WHERE n_classno IN ");
     strcat (sql_str, "(SELECT n_classno FROM nfmclasses WHERE n_workflowno ");
     strcat (sql_str, "IN (SELECT n_workflowno FROM nfmworkflow WHERE ");
     strcat (sql_str, "n_workflowname = ");  
     strcat (sql_str, "'");  
     strcat (sql_str, out_str);  
     strcat (sql_str, "'");  
     strcat (sql_str, "))");  

     status = SQLstmt (sql_str);
     if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
      {
         NFMrollback_transaction (0);
         _sql_error (status);
         status = NFM_E_SQL_STMT;
         ERRload_struct (NFM, status, NULL);
         _NFMdebug ((fname, ": SQL STMT : status = <0x%.8x>\n",
                     status));
         return (status);
      }

     /* Delete all the classes for the workflow from NFMCLASSES table */

     sprintf (sql_str, "DELETE FROM nfmclasses WHERE n_workflowno = %d",
              workflowno);
     status = SQLstmt (sql_str);
     if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
      {
         NFMrollback_transaction (0);
         _sql_error (status);
         status = NFM_E_SQL_STMT;
         ERRload_struct (NFM, status, NULL);
         _NFMdebug ((fname, ": SQL STMT : status = <0x%.8x>\n",
                     status));
         return (status);
      }

     /* Delete all the transitions for the workflow from NFMTRANSITIONS */ 

     sprintf (sql_str, "DELETE FROM nfmtransitions WHERE n_workflowno = %d",
              workflowno);
     status = SQLstmt (sql_str);
     if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
      {
         NFMrollback_transaction (0);
         _sql_error (status);
         status = NFM_E_SQL_STMT;
         ERRload_struct (NFM, status, NULL);
         _NFMdebug ((fname, ": SQL STMT : status = <0x%.8x>\n",
                     status));
         return (status);
      }

     /* Delete all the states for the workflow from NFMSTATES */ 

     sprintf (sql_str, "DELETE FROM nfmstates WHERE n_workflowno = %d",
              workflowno);
     status = SQLstmt (sql_str);
     if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
      {
         NFMrollback_transaction (0);
         _sql_error (status);
         status = NFM_E_SQL_STMT;
         ERRload_struct (NFM, status, NULL);
         _NFMdebug ((fname, ": SQL STMT : status = <0x%.8x>\n",
                     status));
         return (status);
      }

     /* Delete the workflow from NFMWORKFLOW */ 

     sprintf (sql_str, "DELETE FROM nfmworkflow WHERE n_workflowno = %d",
              workflowno);
     status = SQLstmt (sql_str);
     if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
      {
         NFMrollback_transaction (0);
         _sql_error (status);
         status = NFM_E_SQL_STMT;
         ERRload_struct (NFM, status, NULL);
         _NFMdebug ((fname, ": SQL STMT : status = <0x%.8x>\n",
                     status));
         return (status);
      }

     /* Commit Work */

     status = NFMstart_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname,": Start Transaction : status = <0x%.8x>\n", status));
        return (status);
      }

     _NFMdebug ((fname, ": return status = <0x%.8x>\n", status));
     return (status);
   }

