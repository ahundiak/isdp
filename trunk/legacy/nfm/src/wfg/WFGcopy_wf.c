#include "machine.h"
#include "WFG.h"
#include "WFFadd_wf.h"


/***************************************************************************
 *                                                                         *
 *                                                                         *
 *  Functions:  WFGcopy_workflow                                            *
 *                                                                         *
 * This function is used by the workflow generator to copy a  workflow    * 
 *                                                                         *
 ***************************************************************************/


long WFGcopy_workflow (workflow_name, wf_desc,
                      num_classes, class_list, num_states, state_list,
                      num_trans, trans_list, num_access, access_list)
  char   *workflow_name;
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
    int     i;
    int     j;
    static  char *fname = "_WFGcopy_workflow";

    _NFMdebug ((fname, " workflow_name = <%s>\n", workflow_name));
    _NFMdebug ((fname, " workflow_desc = <%s>\n", wf_desc));
    _NFMdebug ((fname, " num_classes   = <%d>\n", num_classes));
    _NFMdebug ((fname, " num_states    = <%d>\n", num_states));
    _NFMdebug ((fname, " num_trans     = <%d>\n", num_trans));
    _NFMdebug ((fname, " num_access    = <%d>\n", num_access));

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

    /* get the workflow number */

    status = _WFGget_workflow_no (workflow_name, &workflow_no);
    if (status != NFM_S_SUCCESS)
     {
        _NFMdebug ((fname, " WFGget_workflow_no : status = <0x%.8x>\n",  
                    status));
        return (status);
     }

    /* Add the classes to the database */

    _NFMdebug ((fname, " workflow_no = <%d>\n", workflow_no));
    _NFMdebug ((fname, " num_classes = <%d>\n", num_classes));

    for (i = 0; i < num_classes; ++i)
    {
        status = _WFGadd_class (workflow_no, class_list[i].class_name,
				    &class_list[i].class_no);
        _NFMdebug(( fname, "New class number <%d>\n",class_list[i].class_no ));
        if (status != NFM_S_SUCCESS)
        {
             _NFMdebug ((fname, " WFFadd_class : status = <0x%.8x>\n",
                           status));
             return (status);
        } 
    }

    /* Add the new states to the database */

    for (i = 0; i < num_states; ++i)
    {
        status = _WFGadd_state (workflow_no, state_list[i]);
        if (status != NFM_S_SUCCESS)
        {
            _NFMdebug ((fname, " WFGadd_state : status = <0x%.8x>\n",
                            status));
            return (status);
        } 
    }

    /* Add the new transitions to the database */
    for (i = 0; i < num_trans; ++i)
    {
        status = _WFGadd_transition (workflow_no, trans_list[i]);
        if (status != NFM_S_SUCCESS)
        {
            _NFMdebug ((fname, " WFGadd_transition : status = <0x%.8x>\n",
                            status));
            return (status);
        } 
    }

    /* Add the class access to transitions to the database */

    for (i = 0; i < num_access; ++i)
    {
        for (j = 0; j < access_list[i].num_trans; ++j)
            strcpy (access_list[i].trans_ptr[j].status, WFF_ADD);

        status = _WFGadd_class_access (workflow_no,
                          access_list[i].class_name, access_list[i].trans_ptr,
                          access_list[i].num_trans);
        if (status != NFM_S_SUCCESS)
        {
            _NFMdebug ((fname,
                    " WFGadd_class_access : status = <0x%.8x>\n", status));
            return (status);
        } 
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


