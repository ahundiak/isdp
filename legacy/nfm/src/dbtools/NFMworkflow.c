#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"

 long NFMget_workflow_no (user_id, workflow_name, workflow_no)
   long    user_id;
   char    *workflow_name;
   long    *workflow_no;
   {
     static char *fname = "NFMget_workflow_no" ;
     long    status, atol ();
     char    sql_str [1024], value [50];

     *workflow_no = 0;

     _NFMdebug ((fname, "Workflow Name = <%s>  ", workflow_name));

     sprintf (sql_str, "WHERE %s = '%s'", "n_workflowname", workflow_name);

     status = NFMget_attr_value (user_id, "NFMWORKFLOW", "n_workflowno",
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           ERRload_struct (NFM, NFM_E_BAD_WORKFLOW, "", NULL);
           _NFMdebug ((fname, "No Such Workflow : status = <0x%.8x>\n",
           NFM_E_BAD_WORKFLOW));
           return (NFM_E_BAD_WORKFLOW);
         }

        return (status);
      }

     *workflow_no = atol (value);

     _NFMdebug ((fname, "SUCCESSFUL :Workflow No = <%d>\n", *workflow_no));
     return (NFM_S_SUCCESS);
   }

 long NFMget_workflow_name (user_id, workflow_no, workflow_name)
   long    user_id;
   long    workflow_no;
   char    *workflow_name;
   {
     static char *fname = "NFMget_workflow_name" ;
     long    status;
     char    sql_str [1024];

     workflow_name [0] = 0;

     _NFMdebug ((fname, "Workflow No   = <%d>  ", workflow_no  ));

     sprintf (sql_str, "WHERE %s = %d", "n_workflowno", workflow_no);

     status = NFMget_attr_value (user_id, "NFMWORKFLOW", "n_workflowname",
              sql_str, workflow_name);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           ERRload_struct (NFM, NFM_E_BAD_WORKFLOW, "", NULL);
           _NFMdebug ((fname, "No Such Workflow : status = <0x%.8x>\n",
           NFM_E_BAD_WORKFLOW));
           return (NFM_E_BAD_WORKFLOW);
         }

        return (status);
      }

     _NFMdebug ((fname, "SUCCESSFUL : Workflow Name = <%s>\n", workflow_name));
     return (NFM_S_SUCCESS);
   }

