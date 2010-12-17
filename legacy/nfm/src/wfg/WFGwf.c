#include "machine.h"
#include "WFG.h"
#include "WFGdefs.h"


extern char  WFG_NO_CHANGE_STATE [];

/***************************************************************************
 *                                                                         *
 *  Date:  September 25, 1991.                                             *
 *                                                                         *
 *  Functions:  _WFGinsert_workflow_info                                   *
 *                                                                         *
 * These functions are used by the workflow generator.                     * 
 *                                                                         *
 ***************************************************************************/


long _WFGinsert_workflow_info (workflow_name, workflow_desc)
  char   *workflow_name;
  char   *workflow_desc;
  {
    long    workflow_no;
    long    acl_no;
    long    status;
    char    out_str[80];
    char    out_str1[128];
    char    sql_str[256];
    static  char *fname = "_WFGinsert_workflow_info";

    _NFMdebug ((fname, " workflow_name = <%s>\n", workflow_name));

    /* Get the acl_no for NFM_SDP_ACL */

    status = _WFGget_acl_no ("NFM_SDP_ACL", &acl_no);
    if (status != NFM_S_SUCCESS)
     {
        _NFMdebug ((fname, " _WFGget_acl_no : status = <0x%.8x>\n", status));
        return (status);
     }

    status = NFMget_serial_slot ((long) 0, "nfmworkflow", "n_workflowno",
                                 &workflow_no);
    if (status != NFM_S_SUCCESS)
     {
        _NFMdebug ((fname, " NFMget_serial_slot : status = <0x%.8x>\n",
                    status));
        return (status);
     }

    /* add the workflow info to the workflow table */

    out_str[0]  = 0;
    WFGtic_it (workflow_name, out_str); 
    out_str1[0] = 0;
    WFGtic_it (workflow_desc, out_str1); 

    sprintf (sql_str,
             "INSERT INTO %s (%s, %s) VALUES (%d, '%s', '%s', '%s', %d, %d)",
             "nfmworkflow", "n_workflowno, n_workflowname, n_workflowdesc",
             "n_workflowtype, n_stateno, n_aclno", workflow_no, out_str,
             out_str1, "I", 1, acl_no); 

    status = SQLstmt (sql_str);
    if (status != SQL_S_SUCCESS)
     {
       _NFMdebug ((fname, " SQLstmt : status = <0x%.8x>\n", status));
       status = NFM_E_SQL_STMT;
       ERRload_struct (NFM, status, NULL);
       _NFMdebug ((fname, " Returning : status = <0x%.8x>\n", status));
       return (status);
     }

    _NFMdebug ((fname, " Returning SUCCESS : status = <0x%.8x>\n",
                NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }


long _WFGupdate_workflow_info (workflow_name, old_wf_name, workflow_desc)
  char   *workflow_name;
  char   *old_wf_name;
  char   *workflow_desc;
  {
    long    status;
    char    sql_str[256];
    char    out_str[80];
    char    out_str1[80];
    char    out_str2[128];
    static  char *fname = "_WFGupdate_workflow_info";

    _NFMdebug ((fname, " workflow_name = <%s>\n", workflow_name));
    _NFMdebug ((fname, " old_wf_name   = <%s>\n", old_wf_name));
    _NFMdebug ((fname, " workflow_desc = <%s>\n", workflow_desc));

    /* update the workflow info in the workflow table */

    out_str[0]  = 0;
    WFGtic_it (workflow_name, out_str); 
    out_str1[0] = 0;
    WFGtic_it (old_wf_name, out_str1); 
    out_str2[0] = 0;
    WFGtic_it (workflow_desc, out_str2); 

    sprintf (sql_str,
             "UPDATE %s set %s = '%s', %s = '%s' WHERE %s = '%s'",
             "nfmworkflow", "n_workflowname", out_str,
             "n_workflowdesc", out_str2, "n_workflowname", out_str1);

    status = SQLstmt (sql_str);
    if (status != SQL_S_SUCCESS)
     {
       _NFMdebug ((fname, " SQLstmt : status = <0x%.8x>\n", status));
       status = NFM_E_SQL_STMT;
       ERRload_struct (NFM, status, NULL);
       _NFMdebug ((fname, " Returning : status = <0x%.8x>\n", status));
       return (status);
     }

    _NFMdebug ((fname, " Returning SUCCESS : status = <0x%.8x>\n",
                NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }



long _WFGupdate_wf_state (workflow_no)
  long   workflow_no;
  {
    long    status;
    long    state_no;
    long    wf_no;
    char    state_name[48];
    char    sql_str[256];
    MEMptr  buffer = NULL;

    static  char *fname = "_WFGupdate_wf_state";

    _NFMdebug ((fname, " workflow_no = <%d>\n", workflow_no));

    /* Check to see if the workflow state has been set previously */

    status = _WFGget_wf_state (workflow_no, &state_no, state_name);
    if (status != NFM_S_SUCCESS)
     {
       _NFMdebug ((fname, " _WFGget_wf_state : status = <0x%.8x>\n", status));
       return (status);
     }

    /* If there are access classes set the workflow to complete, */
    /* otherwise reset the workflow state to WFG_NO_CHANGE_STATE (if needed) */ 

    sprintf (sql_str,
             "SELECT %s FROM %s WHERE %s IN (SELECT %s FROM %s WHERE %s = %d)",
             "DISTINCT n_classno", "nfmaccess", "n_classno", "n_classno",
             "nfmclasses", "n_workflowno", workflow_no);   

    status = SQLquery (sql_str, &buffer, MEM_SIZE);
    if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
     {
        MEMclose (&buffer);
        _sql_error (status);
        status = NFM_E_SQL_QUERY;
        ERRload_struct (NFM, status, NULL);
        _NFMdebug ((fname, ": SQL Query Syntax : status = <0x%.8x>\n",
                    status));
        return (status);
     }
    MEMclose (&buffer);

    if (status == SQL_I_NO_ROWS_FOUND)
     {

        if (strcmp (state_name, WFG_NO_CHANGE_STATE) != 0) 
         {
           /* set the state back to WFG_NO_CHANGE_STATE */

           sprintf (sql_str, "UPDATE %s set %s = %d WHERE %s = %d",
                  "nfmworkflow", "n_stateno", 1, "n_workflowno", workflow_no);

           status = SQLstmt (sql_str);
           if (status != SQL_S_SUCCESS)
            {
              _NFMdebug ((fname, " SQLstmt : status = <0x%.8x>\n", status));
              status = NFM_E_SQL_STMT;
              ERRload_struct (NFM, status, NULL);
              _NFMdebug ((fname, " Returning : status = <0x%.8x>\n", status));
              return (status);
            }
         } 
       
       status = NFM_S_SUCCESS; 
       _NFMdebug ((fname, " returning : status = <0x%.8x>\n", status));
       return (status);
     } 


    if ((strcmp (state_name, WFG_WORKFLOW_COMPLETE) == 0) ||
        (strcmp (state_name, WFG_WORKFLOW_USEABLE) == 0)) 
     {
       status = NFM_S_SUCCESS;  /* wf state is set */
       _NFMdebug ((fname, " returning : status = <0x%.8x>\n", status));
       return (status);
     } 

    /* Get the workflow no for NFM_SDP_WORKFLOW */

    status = _WFGget_workflow_no ("NFM_SDP_WORKFLOW", &wf_no);
    if (status != NFM_S_SUCCESS)
     {
       _NFMdebug ((fname, " _WFGget_workflow_no : status = <0x%.8x>\n",
                   status));
       return (status);
     }

    /* Get the state no for WFG_WORKFLOW_COMPLETE */

    status = _WFGget_state_no (wf_no, WFG_WORKFLOW_COMPLETE, &state_no);
    if (status != NFM_S_SUCCESS)
     {
       _NFMdebug ((fname, " _WFGget_state_no : status = <0x%.8x>\n", status));
       return (status);
     }

    /* update the workflow info in the workflow table */

    sprintf (sql_str, "UPDATE %s set %s = %d WHERE %s = %d",
             "nfmworkflow", "n_stateno", state_no, "n_workflowno", workflow_no);

    status = SQLstmt (sql_str);
    if (status != SQL_S_SUCCESS)
     {
       _NFMdebug ((fname, " SQLstmt : status = <0x%.8x>\n", status));
       status = NFM_E_SQL_STMT;
       ERRload_struct (NFM, status, NULL);
       _NFMdebug ((fname, " Returning : status = <0x%.8x>\n", status));
       return (status);
     }

    _NFMdebug ((fname, " Returning SUCCESS : status = <0x%.8x>\n",
                NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }


