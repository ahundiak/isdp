#include "machine.h"
#include "WFG.h"
#include "WFFadd_wf.h"


/***************************************************************************
 *                                                                         *
 *  Date:  September 25, 1991.                                             *
 *                                                                         *
 *  Functions:  WFGadd_workflow                                            *
 *                                                                         *
 * This function is used by the workflow generator to adda new workflow    * 
 * or to change a workflow that is not in use (has no ACL).                *
 *                                                                         *
 ***************************************************************************/


long WFGadd_workflow (user_id, workflow_name, old_wf_name, wf_desc,
                      num_classes, class_list, num_states, state_list,
                      num_trans, trans_list, num_access, access_list)
  long   user_id;  /* not used */
  char   *workflow_name;
  char   *old_wf_name;
  char   *wf_desc;
  int    num_classes;
  struct WFFclass_st  class_list[]; 
  int    num_states;
  struct WFFstate_st  state_list[]; 
  int    num_trans;
  struct WFFtrans_st  trans_list[]; 
  int    num_access;
  struct WFFaccess_st access_list[]; 
  {
    long    workflow_no;
    long    status;
    static  char *fname = "_WFGadd_workflow";

    _NFMdebug ((fname, " workflow_name = <%s>\n", workflow_name));
    _NFMdebug ((fname, " old_wf_name   = <%s>\n", old_wf_name));
    _NFMdebug ((fname, " workflow_desc = <%s>\n", wf_desc));
    _NFMdebug ((fname, " num_classes   = <%d>\n", num_classes));
    _NFMdebug ((fname, " num_states    = <%d>\n", num_states));
    _NFMdebug ((fname, " num_trans     = <%d>\n", num_trans));
    _NFMdebug ((fname, " num_access    = <%d>\n", num_access));

    if (strcmp (old_wf_name, "") == 0)
     {
        /* Begin the transaction */

        status = NFMstop_transaction (0);
         if (status != NFM_S_SUCCESS)
          {
            _NFMdebug ((fname,": Stop Transaction : status = <0x%.8x>\n",
                        status));
            return (status);
          }

        /* the workflow does not exist, add it to the database */

        status = _WFGinsert_workflow_info (workflow_name, wf_desc); 
        if (status != NFM_S_SUCCESS)
         {
            _NFMdebug ((fname, " WFGinsert_workflow_info : status = <0x%.8x>\n",
                        status));
            NFMrollback_transaction (0);
            return (status);
         }
     }
    else
     {
        /* the workflow info may need to be modified */

        status = _WFGupdate_workflow_info (workflow_name, old_wf_name, wf_desc); 
        if (status != NFM_S_SUCCESS)
         {
            _NFMdebug ((fname, " WFGupdate_workflow_info : status = <0x%.8x>\n",
                        status));
            NFMrollback_transaction (0);
            return (status);
         }
     }

    /* get the workflow number */

    status = _WFGget_workflow_no (workflow_name, &workflow_no);
    if (status != NFM_S_SUCCESS)
     {
        _NFMdebug ((fname, " WFGget_workflow_no : status = <0x%.8x>\n",  
                    status));
        if (strcmp (old_wf_name, "") == 0)
           NFMrollback_transaction (0);
        return (status);
     }

    if (strcmp (old_wf_name, "") != 0)
     {
        /* Begin the transaction */

        status = NFMstop_transaction (0);
         if (status != NFM_S_SUCCESS)
          {
            _NFMdebug ((fname,": Stop Transaction : status = <0x%.8x>\n",
                        status));
            return (status);
          }
     } 

    /* Drop the access */

    status = WFGupdate_class_access (workflow_no, num_access, access_list,
                                     WFF_DROP); 
    if (status != NFM_S_SUCCESS)
     {
        _NFMdebug ((fname, " WFGupdate_class_access : status = <0x%.8x>\n",  
                    status));
        NFMrollback_transaction (0);
        return (status);
     }

    /* Drop the classes from the database */

    status = WFGupdate_classes (workflow_no, num_classes, class_list,
                                WFF_DROP); 
    if (status != NFM_S_SUCCESS)
     {
        _NFMdebug ((fname, " WFGupdate_classes : status = <0x%.8x>\n", status));
        NFMrollback_transaction (0);
        return (status);
     }

    /* Modify the existing classes in the database */

    status = WFGupdate_classes (workflow_no, num_classes, class_list,
                                WFF_MODIFY); 
    if (status != NFM_S_SUCCESS)
     {
        _NFMdebug ((fname, " WFGupdate_classes : status = <0x%.8x>\n", status));
        NFMrollback_transaction (0);
        return (status);
     }

    /* Add the classes to the database */

    status = WFGupdate_classes (workflow_no, num_classes, class_list,
                                WFF_ADD); 
    if (status != NFM_S_SUCCESS)
     {
        _NFMdebug ((fname, " WFGupdate_classes : status = <0x%.8x>\n", status));
        NFMrollback_transaction (0);
        return (status);
     }

    /* Drop the transitions from the database */

    status = WFGupdate_trans (workflow_no, num_trans, trans_list,
                               WFF_DROP); 
    if (status != NFM_S_SUCCESS)
     {
        _NFMdebug ((fname, " WFGupdate_trans : status = <0x%.8x>\n", status));
        NFMrollback_transaction (0);
        return (status);
     }

    /* Drop the states from the database */

    status = WFGupdate_states (workflow_no, num_states, state_list,
                               WFF_DROP); 
    if (status != NFM_S_SUCCESS)
     {
        _NFMdebug ((fname, " WFGupdate_states : status = <0x%.8x>\n", status));
        NFMrollback_transaction (0);
        return (status);
     }

    /* Add the new states to the database */

    status = WFGupdate_states (workflow_no, num_states, state_list,
                               WFF_ADD); 
    if (status != NFM_S_SUCCESS)
     {
        _NFMdebug ((fname, " WFGupdate_states : status = <0x%.8x>\n", status));
        NFMrollback_transaction (0);
        return (status);
     }

    /* Modify the existing states in the database */

    status = WFGupdate_states (workflow_no, num_states, state_list,
                               WFF_MODIFY); 
    if (status != NFM_S_SUCCESS)
     {
        _NFMdebug ((fname, " WFGupdate_states : status = <0x%.8x>\n", status));
        NFMrollback_transaction (0);
        return (status);
     }

    /* Add the new transitions to the database */

    status = WFGupdate_trans (workflow_no, num_trans, trans_list,
                               WFF_ADD); 
    if (status != NFM_S_SUCCESS)
     {
        _NFMdebug ((fname, " WFGupdate_trans : status = <0x%.8x>\n", status));
        NFMrollback_transaction (0);
        return (status);
     }

    /* Modify the existing transitions in the database */

    status = WFGupdate_trans (workflow_no, num_trans, trans_list,
                               WFF_MODIFY); 
    if (status != NFM_S_SUCCESS)
     {
        _NFMdebug ((fname, " WFGupdate_trans : status = <0x%.8x>\n", status));
        NFMrollback_transaction (0);
        return (status);
     }

    /* Add the class access to transitions to the database */

    status = WFGupdate_class_access (workflow_no, num_access, access_list,
                                     WFF_ADD); 
    if (status != NFM_S_SUCCESS)
     {
        _NFMdebug ((fname, " WFGupdate_class_access : status = <0x%.8x>\n",  
                    status));
        NFMrollback_transaction (0);
        return (status);
     }

    /* Check to see if the workflow state needs to be modified, if it does the
       function _WFGupdate_wf_state will update it.                           
     */

    status = _WFGupdate_wf_state (workflow_no);
    if (status != NFM_S_SUCCESS)
     {
        _NFMdebug ((fname, "WFGupdate_wf_state : status = <0x%.8x>\n", status));
        NFMrollback_transaction (0);
        return (status);
     }

    /* Commit the work */

    status = NFMstart_transaction (0);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname,": Stop Transaction : status = <0x%.8x>\n", status));
        return (status);
      }

    _NFMdebug ((fname, " Returning SUCCESS : status = <0x%.8x>\n",
                NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }


