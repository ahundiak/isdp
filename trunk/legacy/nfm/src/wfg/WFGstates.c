#include "machine.h"
#include "WFG.h"
#include "WFFadd_wf.h"
#include "WFGdefs.h"

extern char  WFG_DONT_CARE_STATE [];
extern char  WFG_NO_CHANGE_STATE [];

/***************************************************************************
 *                                                                         *
 *  Date:  September 25, 1991.                                             *
 *                                                                         *
 *  Functions:  WFGupdate_states                                           *
 *              _WFGadd_state                                              *
 *              _WFGdelete_state                                           *
 *              _WFGmodify_state                                           *
 *                                                                         *
 * These functions are used by the workflow generator.                     * 
 *                                                                         *
 ***************************************************************************/


long WFGupdate_states (workflow_no, num_states, state_list, upd_order)
  long          workflow_no;
  int           num_states; 
  struct WFFstate_st state_list[]; 
  char          *upd_order; /* WFF_ADD, WFF_DROP, "" = don't care about order */
  {
    int     i;
    long    status;
    static  char *fname = "_WFGupdate_states";


    _NFMdebug ((fname, " workflow_no = <%d>\n", workflow_no));

    for (i = 0; i < num_states; ++i)
     {
        if ((strcmp (state_list[i].status, WFF_ADD) == 0) &&
            (strcmp (upd_order, WFF_ADD) == 0))
         {
            status = _WFGadd_state (workflow_no, state_list[i]);
            if (status != NFM_S_SUCCESS)
             {
                _NFMdebug ((fname, " WFGadd_state : status = <0x%.8x>\n",
                            status));
                return (status);
             } 
         }
        else if ((strcmp (state_list[i].status, WFF_DROP) == 0) &&
                 (strcmp (upd_order, WFF_DROP) == 0))
         {
            status = _WFGdelete_state (workflow_no, state_list[i].state_name);
            if (status != NFM_S_SUCCESS)
             {
                _NFMdebug ((fname, " WFGdelete_state : status = <0x%.8x>\n",
                            status));
                return (status);
             } 
         }
        else if ((strcmp (state_list[i].status, WFF_MODIFY) == 0) &&
            (strcmp (upd_order, WFF_MODIFY) == 0))
         {
            status = _WFGmodify_state (workflow_no, state_list[i]);
            if (status != NFM_S_SUCCESS)
             {
                _NFMdebug ((fname, " WFGmodify_state : status = <0x%.8x>\n",
                            status));
                return (status);
             } 
         }
     }  

    _NFMdebug ((fname, " Returning SUCCESS : status = <0x%.8x>\n",
                NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }



long _WFGadd_state (workflow_no, state_info)
  long  workflow_no;
  struct  WFFstate_st state_info; 
  {
    long    status;
    char    no_signoffs[16];
    char    seq_no[16];
    char    out_str[128];
    char    out_str1[128];
    char    sql_str[512];
    static  char *fname = "_WFGadd_state";

    _NFMdebug ((fname, " workflow_no = <%d>\n", workflow_no));

    if ((strcmp (state_info.state_name, WFG_DONT_CARE_STATE) == 0) ||
        (strcmp (state_info.state_name, WFG_NO_CHANGE_STATE) == 0)) 
     {
       status = NFM_S_SUCCESS;
       _NFMdebug ((fname, " Returning SUCCESS : status = <0x%.8x>\n", status));
       return (status);
     }

    /* get the state_no index */

    status = NFMget_serial_slot ((long) 0, "nfmstates", "n_stateno",
                                 &state_info.state_no);
    if (status != NFM_S_SUCCESS)
     {
        _NFMdebug ((fname, " NFMget_serial_slot : status = <0x%.8x>\n",
                    status));
        return (status);
     }

    if (strcmp (state_info.seq_no, "") == 0)
       strcpy (seq_no, "0");
    else
       strcpy (seq_no, state_info.seq_no);

    if (strcmp (state_info.no_signoffs, "") == 0)
       strcpy (no_signoffs, "0");
    else
       strcpy (no_signoffs, state_info.no_signoffs);

    /* add the state to the state table */

    /* If the state_name has single tics substitute it with double tics (RIS) */

    out_str[0]  = 0;
    out_str1[0] = 0;
    WFGtic_it (state_info.state_name, out_str);
    WFGtic_it (state_info.state_desc, out_str1);

    sprintf (sql_str,
             "%s, %s, %s VALUES (%d, '%s', '%s', %d, %s, '%s', '%s', '%s', %s)",
             "INSERT INTO nfmstates (n_stateno, n_statename, n_statedesc",
             "n_workflowno, n_signoffs, n_majority, n_transfrom, n_transto",
             "n_seqno)", state_info.state_no, out_str, out_str1,
             workflow_no, no_signoffs, state_info.majority,
             state_info.trans_from, state_info.trans_to, seq_no);

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



long _WFGdelete_state (workflow_no, state_name)
  long  workflow_no;
  char  *state_name; 
  {
    long    status;
    long    state_no = 0;
    char    sql_str[256];
    static  char *fname = "_WFGdelete_state";

    _NFMdebug ((fname, " workflow_no = <%d>\n", workflow_no));

    if ((strcmp (state_name, WFG_DONT_CARE_STATE) == 0) ||
        (strcmp (state_name, WFG_NO_CHANGE_STATE) == 0)) 
     {
       status = NFM_S_SUCCESS;
       _NFMdebug ((fname, " Returning SUCCESS : status = <0x%.8x>\n", status));
       return (status);
     }

     status = _WFGget_state_no (workflow_no, state_name, &state_no);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, " _WFGget_state_no : status = <0x%.8x>\n", status));
        _NFMdebug ((fname, " Returning : status = <0x%.8x>\n", status));
        return (status);
      }

    /* delete the state from the state table */

    sprintf (sql_str, "DELETE FROM nfmstates WHERE %s = %d",
             "n_stateno", state_no);

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

    status = NFMreturn_serial_slot ((long) 0, "nfmstates", "n_stateno",
                                    state_no);
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



long _WFGmodify_state (workflow_no, state_info)
  long  workflow_no;
  struct  WFFstate_st state_info; 
  {
    long    status;
    char    no_signoffs[16];
    char    seq_no[16];
    char    out_str[128];
    char    out_str1[128];
    char    sql_str[512];
    static  char *fname = "_WFGadd_state";

    _NFMdebug ((fname, " workflow_no = <%d>\n", workflow_no));
    _NFMdebug ((fname, " state_no = <%d>\n", state_info.state_no));

    if ((strcmp (state_info.state_name, WFG_DONT_CARE_STATE) == 0) ||
        (strcmp (state_info.state_name, WFG_NO_CHANGE_STATE) == 0)) 
     {
       /* Cannot modify the system defined states. */

       status = NFM_S_SUCCESS;
       _NFMdebug ((fname, " Returning SUCCESS : status = <0x%.8x>\n", status));
       return (status);
     }

    if (strcmp (state_info.seq_no, "") == 0)
       strcpy (seq_no, "0");
    else
       strcpy (seq_no, state_info.seq_no);

    if (strcmp (state_info.no_signoffs, "") == 0)
       strcpy (no_signoffs, "0");
    else
       strcpy (no_signoffs, state_info.no_signoffs);

    /* add the state to the state table */

    /* If the state_name has single tics substitute it with double tics (RIS) */

    out_str[0]  = 0;
    out_str1[0] = 0;
    WFGtic_it (state_info.state_name, out_str);
    WFGtic_it (state_info.state_desc, out_str1);

    sprintf (sql_str,
             "UPDATE nfmstates SET n_statename = '%s',n_statedesc = '%s', n_transfrom = '%s', n_transto = '%s', n_majority = '%s', n_signoffs = %s, n_seqno = %s WHERE n_stateno = %d",
             out_str, out_str1, state_info.trans_from, 
             state_info.trans_to, state_info.majority, 
             no_signoffs, seq_no, state_info.state_no);

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


