#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"
#include "WFstruct.h"
#include "MEMstruct.h"

  extern struct WFstruct WFinfo ;

 long NFMget_state_no (user_id, wf_no, state_name, state_no)
   long    user_id;
   long    wf_no;
   char    *state_name;
   long    *state_no;
   {
     static char *fname = "NFMget_state_no" ;
     long    status, atol ();
     char    sql_str [1024], value [50];

     *state_no = 0;

     _NFMdebug ((fname, "Wf    No   = <%d>  : state name = <%s>\n", 
		 wf_no, state_name));

     sprintf (value, "%d", wf_no);

     sprintf (sql_str, "WHERE %s = '%s' AND %s = %s", 
	      "n_statename", state_name, "n_workflowno", value);

     status = NFMget_attr_value (user_id, "NFMSTATES", "n_stateno",
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           /* status = NFMerror (NFM_E_BAD_STATE); */
           status = ERRload_struct (NFM, NFM_E_BAD_STATE, "", NULL);
           _NFMdebug ((fname, "No Such State : status = <0x%.8x>\n",
           NFM_E_BAD_STATE));
           return (NFM_E_BAD_STATE);
         }

        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n", status));
        return (status);
      }

     *state_no = atol (value);

     _NFMdebug ((fname, "SUCCESSFUL : State No = <%d>\n", *state_no));
     return (NFM_S_SUCCESS);
   }

 long NFMget_state_name (user_id, wf_no, state_no, state_name)
   long    user_id;
   long    wf_no, state_no;
   char    *state_name;
   {
     static char *fname = "NFMget_state_name" ;
     long    status;
     char    sql_str [1024] ;

     state_name [0] = 0;

     _NFMdebug ((fname, "Wf    No   = <%d> : State no = <%d>\n",
		 wf_no, state_no)) ;

     sprintf (sql_str, "WHERE %s = %d","n_stateno", state_no);

     status = NFMget_attr_value (user_id, "NFMSTATES", "n_statename",
              sql_str, state_name);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           /* status = NFMerror (NFM_E_BAD_STATE); */
           status = ERRload_struct (NFM, NFM_E_BAD_STATE, "", NULL);
           _NFMdebug ((fname, "No Such State : status = <0x%.8x>\n",
           NFM_E_BAD_STATE));
           return (NFM_E_BAD_STATE);
         }

        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
        status));
        return (status);
      }

     _NFMdebug ((fname, "SUCCESSFUL : State Name = <%s>\n", state_name));
     return (NFM_S_SUCCESS);
   }

 long NFMget_state_workflow_no (user_id, state_no, wf_no)
   long    user_id;
   long    state_no;
   long    *wf_no;
   {
     static char *fname = "NFMget_state_workflow_no" ;
     long    status, atol ();
     char    sql_str [1024], value [50];

     *wf_no = 0;

     _NFMdebug ((fname, "State No = <%d>\n", state_no));

     sprintf (sql_str, "WHERE %s = %d", "n_stateno", state_no);

     status = NFMget_attr_value (user_id, "NFMSTATES", "n_workflowno",
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           /* status = NFMerror (NFM_E_BAD_STATE); */
           status = ERRload_struct (NFM, NFM_E_BAD_STATE, "", NULL);
           _NFMdebug ((fname, "No Such State : status = <0x%.8x>\n",
           NFM_E_BAD_STATE));
           return (NFM_E_BAD_STATE);
         }

        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
        status));
        return (status);
      }

     *wf_no = atol (value);

     _NFMdebug ((fname, "SUCCESSFUL : Wf No = <%d>\n", *wf_no));
     return (NFM_S_SUCCESS);
   }

 long NFMcheck_state_signoff (user_id, state_no, no_signoff, override)
   long    user_id;
   long    state_no;
   long    *no_signoff;
   char    *override;
   {
     static char *fname = "NFMcheck_state_signoff" ;
     long    status, atol ();
     char    sql_str [1024], value [50];

     *no_signoff = 0;

     _NFMdebug ((fname, "State No      = <%d>  : No Signoff %d : Overridef <%s>\n", 
		 state_no, *no_signoff, override));

     sprintf (sql_str, "WHERE %s = %d", "n_stateno", state_no);

     status = NFMget_attr_value (user_id, "NFMSTATES", "n_signoffs",
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           /* status = NFMerror (NFM_E_BAD_STATE); */
           status = ERRload_struct (NFM, NFM_E_BAD_STATE, "", NULL);
           _NFMdebug ((fname, "No Such State : status = <0x%.8x>\n",
           NFM_E_BAD_STATE));
           return (NFM_E_BAD_STATE);
         }

        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
        status));
        return (status);
      }

     *no_signoff = atol (value);

     status = NFMget_attr_value (user_id, "NFMSTATES", "n_majority",
              sql_str, override);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           /* status = NFMerror (NFM_E_BAD_STATE); */
           status = ERRload_struct (NFM, NFM_E_BAD_STATE, "", NULL);
           _NFMdebug ((fname, "No Such State : status = <0x%.8x>\n",
           NFM_E_BAD_STATE));
           return (NFM_E_BAD_STATE);
         }

        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
        status));
        return (status);
      }

     _NFMdebug ((fname, "SUCCESSFUL : No Sign Off = <%d>  : Type <%s>\n",
		 *no_signoff, override));
     return (NFM_S_SUCCESS);
   }

 long NFMget_acl_state_no (user_id, acl_no, state_no)
   long    user_id;
   long    acl_no;
   long    *state_no;
   {
     static char *fname = "NFMget_acl_state_no" ;
     long    status, atol ();
     char    sql_str [2048], **data ;
     MEMptr  sql_buffer = NULL ;
     /* char    attr [100], value[50] ; */
     char    value[50] ;
     *state_no = 0;

     _NFMdebug ((fname, "Acl No = <%d>\n\n", 
		 acl_no));

     sprintf (sql_str, 
	      "SELECT DISTINCT nfmtransitions.n_tostate, nfmtransitions.n_transitionno, nfmacls.n_workflowno, nfmtransitions.n_fromstate, \
nfmworkflow.n_workflowname, nfmacls.n_aclname, \
nfmtransitions.n_transitionname, nfmstates.n_statename \
from nfmtransitions, nfmacls, nfmworkflow, nfmstates \
WHERE %s.%s = %d AND %s.%s = %d AND %s.%s = %s.%s AND %s.%s = %s.%s AND \
%s.%s = %s.%s",
	      "NFMACLS", "n_aclno", acl_no, 
	      "NFMTRANSITIONS", "n_commandno", WFinfo.command,
	      "NFMTRANSITIONS", "n_workflowno", "NFMACLS", "n_workflowno",
	      "NFMTRANSITIONS", "n_workflowno", "NFMWORKFLOW", "n_workflowno",
	      "NFMSTATES", "n_stateno", "NFMTRANSITIONS", "n_tostate");
     
     status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
     if (status != SQL_S_SUCCESS)
       {
	 if (status == SQL_I_NO_ROWS_FOUND)
	   {
	     ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
	     _NFMdebug ((fname, "No To State No workflow no transition : status = <0x%.8x>\n",
			 status)) ;
	     return (NFM_E_SQL_QUERY) ;
	   }
	 
	 ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
	 _NFMdebug ((fname, "Get Attr value : status = <0x%.8x>\n",
		     status));
	 return (status);
       }
     
     status = MEMbuild_array (sql_buffer) ;
     if (status != MEM_S_SUCCESS)
       {
	 MEMclose (&sql_buffer) ;
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	 _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
		     status)) ;
	 return (NFM_E_MEM) ;
       }

     data = (char **) sql_buffer -> data_ptr ;

     *state_no = WFinfo.next_state = atol (data [0]);

     WFinfo.transition = atol (data [1]);
     WFinfo.acl        = acl_no;

/******  At this point WFinfo.workflow and WFinfo.wf_name have the correct
         information.  The two calls commented out below where putting the
         wrong workflow information (NFM_SDP_WPRKFLOW) into the WFinfo
         structure during "Load Workflow" command.  B.W.  02-10-1992 ********/ 

     /**** WFinfo.workflow = atol (data [2]) ; *****/
     WFinfo.curr_state = atol (data [3]) ;
     /**** strcpy (WFinfo.wf_name,data [4]) ; ******/
     strcpy (WFinfo.acl_name, data [5]) ;
     strcpy (WFinfo.transition_name, data [6]) ;
     strcpy (WFinfo.next_statename, data [7]) ;
     status = MEMclose (&sql_buffer) ;
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	_NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n", status)) ;
	return (NFM_E_MEM) ;
      }

     _NFMdebug ((fname, "Current State No (WFinfo.curr_state) %d : Next State No (WFinfo.next_state) %d : Transition No (WFinfo.transition) = <%d> : WFinfo.workflow\n",
                WFinfo.curr_state, WFinfo.next_state, WFinfo.transition, WFinfo.workflow));

     _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS));
     return (NFM_S_SUCCESS);
   }



