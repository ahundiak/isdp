#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"

 long NFMget_transition_no (user_id, wf_no, trans_name, trans_no)
   long    user_id;
   long    wf_no;
   char    *trans_name;
   long    *trans_no;
   {
     static char *fname = "NFMget_transition_no" ;
     long    status, atol ();
     char    sql_str [1024], value [50];

     *trans_no = 0;

     _NFMdebug ((fname, "Wf         No   = <%d>  : Transition Name = <%s>\n",
		 wf_no, trans_name)) ;

     sprintf (value, "%d", wf_no);

     sprintf (sql_str, "WHERE %s = '%s' AND %s = %s",
	      "n_transitionname", trans_name, "n_workflowno", value);

     status = NFMget_attr_value (user_id, "NFMTRANSITIONS", "n_transitionno",
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           ERRload_struct (NFM, NFM_E_BAD_TRANSITION, "", NULL);
           _NFMdebug ((fname, "No Such Transition : status = <0x%.8x>\n",
           NFM_E_BAD_TRANSITION));
           return (NFM_E_BAD_TRANSITION);
         }

        return (status);
      }

     *trans_no = atol (value);

     _NFMdebug ((fname, "SUCCESSFUL : Transition No = <%d>\n", *trans_no));
     return (NFM_S_SUCCESS);
   }

 long NFMget_transition_name (user_id, wf_no, trans_no, trans_name)
   long    user_id;
   long    wf_no, trans_no;
   char    *trans_name;
   {
     static char *fname = "NFMget_transition_name" ;
     long    status;
     char    sql_str [1024] ;

     trans_name [0] = 0;

     _NFMdebug ((fname, "Wf         No   = <%d>  : Transition No <%d>\n",
		 wf_no, trans_no)) ;

     sprintf (sql_str, "WHERE %s = %d", "n_transitionno", trans_no);

     status = NFMget_attr_value (user_id, "NFMTRANSITIONS", "n_transitionname",
              sql_str, trans_name);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           ERRload_struct (NFM, NFM_E_BAD_TRANSITION, "", NULL);
           _NFMdebug ((fname, "No Such Transition : status = <0x%.8x>\n",
           NFM_E_BAD_TRANSITION));
           return (NFM_E_BAD_TRANSITION);
         }

        return (status);
      }

     _NFMdebug ((fname, "SUCCESSFUL :Transition Name = <%s>\n", trans_name));
     return (NFM_S_SUCCESS);
   }

 long NFMcheck_transition_notify (user_id, trans_no)
   long    user_id;
   long    trans_no;
   {
     static char *fname = "NFMcheck_transition_notify" ;
     long    status;
     char    sql_str [1024], value [50];

     _NFMdebug ((fname, "Transition No = <%d>\n", trans_no));

     sprintf (sql_str, "WHERE %s = %d", "n_transitionno", trans_no);

     status = NFMget_attr_value (user_id, "NFMTRANSITIONS", "n_notify",
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           ERRload_struct (NFM, NFM_E_BAD_TRANSITION, "", NULL);
           _NFMdebug ((fname, "No Such Transition : status = <0x%.8x>\n",
           NFM_E_BAD_TRANSITION));
           return (NFM_E_BAD_TRANSITION);
         }
        return (status);
      }

     _NFMdebug ((fname, "Notify = <%s>\n", value));

     if (strcmp (value, "Y"))
      {
           ERRload_struct (NFM, NFM_E_NO_TRANS_NOTIFY, "", NULL);
        _NFMdebug ((fname, "No Trans Mail : status = <0x%.8x>\n", 
		    NFM_E_NO_TRANS_NOTIFY));
        return (NFM_E_NO_TRANS_NOTIFY);
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMcheck_transition_success_log (user_id, trans_no)
   long    user_id;
   long    trans_no;
   {
     static char *fname = "NFMcheck_transition_success_log" ;
     long    status;
     char    sql_str [1024], value [50];

     _NFMdebug ((fname, "Transition No = <%d>  ", trans_no));

     sprintf (sql_str, "WHERE %s = %d", "n_transitionno", trans_no);

     status = NFMget_attr_value (user_id, "NFMTRANSITIONS", "n_logonsuccess",
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           ERRload_struct (NFM, NFM_E_BAD_TRANSITION, "", NULL);
           _NFMdebug ((fname, "No Such Transition : status = <0x%.8x>\n",
           NFM_E_BAD_TRANSITION));
           return (NFM_E_BAD_TRANSITION);
         }
        return (status);
      }

     _NFMdebug ((fname, "Notify = <%s>\n", value));

     if (strcmp (value, "Y"))
      {
           ERRload_struct (NFM, NFM_E_NO_TRANS_LOG, "", NULL);
        _NFMdebug ((fname, "No Trans Succ Log : status = <0x%.8x>\n",
        NFM_E_NO_TRANS_LOG));
        return (NFM_E_NO_TRANS_LOG);
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMcheck_transition_fail_log (user_id, trans_no)
   long    user_id;
   long    trans_no;
   {
     static char *fname = "NFMcheck_transition_fail_log" ;
     long    status;
     char    sql_str [1024], value [50];

     _NFMdebug ((fname, "Transition No = <%d>  ", trans_no));

     sprintf (sql_str, "WHERE %s = %d", "n_transitionno", trans_no);

     status = NFMget_attr_value (user_id, "NFMTRANSITIONS", "n_logonfailure",
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           ERRload_struct (NFM, NFM_E_BAD_TRANSITION, "", NULL);
           _NFMdebug ((fname, "No Such Transition : status = <0x%.8x>\n",
           NFM_E_BAD_TRANSITION));
           return (NFM_E_BAD_TRANSITION);
         }
        return (status);
      }

     _NFMdebug ((fname, "Notify = <%s>\n", value));

     if (strcmp (value, "Y"))
      {
           ERRload_struct (NFM, NFM_E_NO_TRANS_LOG, "", NULL);
        _NFMdebug ((fname, "No Trans Fail Log : status = <0x%.8x>\n",
        NFM_E_NO_TRANS_LOG));
        return (NFM_E_NO_TRANS_LOG);
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }
