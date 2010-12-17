#include "machine.h"
#include "WFG.h"
#include "WFFadd_wf.h"

/***************************************************************************
 *                                                                         *
 *  Date:  September 25, 1991.                                             *
 *                                                                         *
 *  Functions:  WFGupdate_transitions                                      *
 *              _WFGadd_transition                                         *
 *              _WFGdelete_transition                                      *
 *              _WFGmodify_transition                                      *
 *                                                                         *
 * These functions are used by the workflow generator.                     * 
 *                                                                         *
 ***************************************************************************/


long WFGupdate_trans (workflow_no, num_trans, trans_list, upd_order)
  long          workflow_no;
  int           num_trans; 
  struct WFFtrans_st trans_list[]; 
  char          *upd_order;
  {
    int     i;
    long    status;
    static  char *fname = "_WFGupdate_trans";

    _NFMdebug ((fname, " workflow_no = <%d>\n", workflow_no));
    _NFMdebug ((fname, " upd_order = <%s>\n", upd_order));

    for (i = 0; i < num_trans; ++i)
     {
        if ((strcmp (trans_list[i].status, WFF_ADD) == 0) &&
            (strcmp (upd_order, WFF_ADD) == 0))
         {
            status = _WFGadd_transition (workflow_no, trans_list[i]);
            if (status != NFM_S_SUCCESS)
             {
                _NFMdebug ((fname, " WFGadd_transition : status = <0x%.8x>\n",
                            status));
                return (status);
             } 
         }
        else if ((strcmp (trans_list[i].status, WFF_DROP) == 0) &&
                 (strcmp (upd_order, WFF_DROP) == 0))
         {
            status = _WFGdelete_transition (workflow_no,  
                          trans_list[i].trans_name, trans_list[i].from_state);
            if (status != NFM_S_SUCCESS)
             {
                _NFMdebug ((fname," WFGdelete_transition : status = <0x%.8x>\n",
                            status));
                return (status);
             } 
         }
        else if ((strcmp (trans_list[i].status, WFF_MODIFY) == 0) &&
                 (strcmp (upd_order, WFF_MODIFY) == 0))
         {
            status = _WFGmodify_transition (workflow_no, trans_list[i]);
            if (status != NFM_S_SUCCESS)
             {
                _NFMdebug ((fname,
                      " WFGmodify_transition : status = <0x%.8x>\n", status));
                return (status);
             } 
         }
     }  

    _NFMdebug ((fname, " Returning SUCCESS : status = <0x%.8x>\n",
                NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }


long _WFGadd_transition (workflow_no, trans_info)
  long  workflow_no;
  struct  WFFtrans_st trans_info; 
  {
    long    status;
    long    trans_no = 0; 
    long    command_no = 0; 
    long    from_state = 0; 
    long    to_state = 0; 
    char    sql_str[512];
    char    out_str[256];
    static  char *fname = "_WFGadd_transition";

    _NFMdebug ((fname, " workflow_no = <%d>\n", workflow_no));

    /* get the command no */

    status = _WFGget_command_no (trans_info.command_name, &command_no);
    if (status != NFM_S_SUCCESS)
     {
        _NFMdebug ((fname, " _WFGget_command_no : status = <0x%.8x>\n",
                    status));
        return (status);
     }

    /* get the from_state no */

    status = _WFGget_state_no (workflow_no, trans_info.from_state, &from_state);
    if (status != NFM_S_SUCCESS)
     {
        _NFMdebug ((fname, " _WFGget_state_no : status = <0x%.8x>\n",
                    status));
        return (status);
     }

    /* get the to_state no */

    status = _WFGget_state_no (workflow_no, trans_info.to_state, &to_state);
    if (status != NFM_S_SUCCESS)
     {
        _NFMdebug ((fname, " _WFGget_state_no : status = <0x%.8x>\n",
                    status));
        return (status);
     }

    /* get the trans_no index */

    status = NFMget_serial_slot ((long) 0, "nfmtransitions", "n_transitionno",
                                 &trans_no);
    if (status != NFM_S_SUCCESS)
     {
        _NFMdebug ((fname, " NFMget_serial_slot : status = <0x%.8x>\n",
                    status));
        return (status);
     }

    out_str[0] = 0;
    WFGtic_it (trans_info.trans_name, out_str);

    /* add the trans to the trans table */

    sprintf (sql_str,
             "%s, %s, %s VALUES (%d, '%s', %d, %d, %d, '%s', '%s', '%s', %d)",
             "INSERT INTO nfmtransitions (n_transitionno, n_transitionname",
             "n_commandno, n_fromstate, n_tostate, n_logonsuccess",
             "n_logonfailure, n_notify, n_workflowno)",
             trans_no, out_str, command_no, from_state, to_state,
             trans_info.logon_success, trans_info.logon_failure,
             trans_info.n_notify, workflow_no);
              
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



long _WFGdelete_transition (workflow_no, trans_name, from_state)
  long  workflow_no;
  char  *trans_name; 
  char  *from_state;  
  {
    long    status;
    long    trans_no = 0;
    long    state_no = 0;
    char    sql_str[256];
    static  char *fname = "_WFGdelete_transition";

    _NFMdebug ((fname, " workflow_no = <%d>\n", workflow_no));

     /* get the from_state no */

     status = _WFGget_state_no (workflow_no, from_state, &state_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, " _WFGget_state_no : status = <0x%.8x>\n", status));
        _NFMdebug ((fname, " Returning : status = <0x%.8x>\n", status));
        return (status);
      }

     status = _WFGget_trans_no (workflow_no, trans_name, state_no, &trans_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, " _WFGget_trans_no : status = <0x%.8x>\n", status));
        _NFMdebug ((fname, " Returning : status = <0x%.8x>\n", status));
        return (status);
      }

    /* delete the trans from the trans table */

    sprintf (sql_str, "DELETE FROM nfmtransitions WHERE %s = %d",
             "n_transitionno", trans_no);

     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS)
      {
        _NFMdebug ((fname, " SQLstmt : status = <0x%.8x>\n", status));
        status = NFM_E_SQL_STMT;
        ERRload_struct (NFM, status, NULL);
        _NFMdebug ((fname, " Returning : status = <0x%.8x>\n", status));
        return (status);
      }

    /* return the serial slot */

    status = NFMreturn_serial_slot ((long) 0, "nfmtransitions",
                                    "n_transitionno", trans_no);
    if (status != NFM_S_SUCCESS)
     {
        _NFMdebug ((fname, " NFMget_serial_slot : status = <0x%.8x>\n",
                    status));
        return (status);
     }

    _NFMdebug ((fname, " Returning SUCCESS : status = <0x%.8x>\n",
                NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }


long _WFGmodify_transition (workflow_no, trans_info)
  long  workflow_no;
  struct  WFFtrans_st trans_info; 
  {
    long    status;
    long    command_no = 0; 
    long    from_state = 0; 
    long    to_state = 0; 
    char    sql_str[1024];
    char    out_str[256];
    static  char *fname = "_WFGmodify_transition";

    _NFMdebug ((fname, " workflow_no = <%d>\n", workflow_no));

    /* get the command no */

    status = _WFGget_command_no (trans_info.command_name, &command_no);
    if (status != NFM_S_SUCCESS)
     {
        _NFMdebug ((fname, " _WFGget_command_no : status = <0x%.8x>\n",
                    status));
        return (status);
     }

    /* get the from_state no */

    status = _WFGget_state_no (workflow_no, trans_info.from_state, &from_state);
    if (status != NFM_S_SUCCESS)
     {
        _NFMdebug ((fname, " _WFGget_state_no : status = <0x%.8x>\n",
                    status));
        return (status);
     }

    /* get the to_state no */

    status = _WFGget_state_no (workflow_no, trans_info.to_state, &to_state);
    if (status != NFM_S_SUCCESS)
     {
        _NFMdebug ((fname, " _WFGget_state_no : status = <0x%.8x>\n",
                    status));
        return (status);
     }

    out_str[0] = 0;
    WFGtic_it (trans_info.trans_name, out_str);
    sql_str[0] = 0;

    /* modify the transition */

    sprintf (sql_str,
             "%s = %d, %s = '%s', %s = %d, %s = %d, %s = '%s', %s = '%s',\
             %s = '%s' %s = %d",
             "UPDATE nfmtransitions set n_commandno", command_no,
             "n_transitionname", out_str, "n_fromstate", from_state,
             "n_tostate", to_state, "n_logonsuccess", trans_info.logon_success,
             "n_logonfailure", trans_info.logon_failure,
             "n_notify", trans_info.n_notify,
             "WHERE n_transitionno", trans_info.trans_no);
     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS)
      {
        _NFMdebug ((fname, " SQLstmt : sql_str = <%s>\n", sql_str));
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

