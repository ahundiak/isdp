#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"

 long NFMget_acl_no (user_id, acl_name, acl_no)
   long    user_id;
   char    *acl_name;
   long    *acl_no;
   {
     static char *fname = "NFMget_acl_no" ;
     long    status, atol ();
     char    sql_str [1024], value [50];

     *acl_no = 0;

     _NFMdebug ((fname, "Acl Name = <%s>\n",  acl_name)) ;

     sprintf (sql_str, "WHERE %s = '%s'", "n_aclname", acl_name);

     status = NFMget_attr_value (user_id, "NFMACLS", "n_aclno",
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           ERRload_struct (NFM, NFM_E_BAD_ACL, "", NULL);
           _NFMdebug ((fname, "No Such Acl : status = <0x%.8x>\n", 
		       NFM_E_BAD_ACL));
           return (NFM_E_BAD_ACL);
         }

        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n", status));
        return (status);
      }

     *acl_no = atol (value);

     _NFMdebug ((fname, "SUCCESSFUL :  Acl No = <%d>\n", *acl_no));
     return (NFM_S_SUCCESS);
   }

 long NFMget_acl_name (user_id, acl_no, acl_name)
   long    user_id;
   long    acl_no;
   char    *acl_name;
   {
     static char *fname = "NFMget_acl_name" ;
     long    status;
     char    sql_str [1024];

     acl_name [0] = 0;

     _NFMdebug ((fname, "Acl  No  = <%d>  ", acl_no  ));

     sprintf (sql_str, "WHERE %s = %d", "n_aclno", acl_no);

     status = NFMget_attr_value (user_id, "NFMACLS", "n_aclname",
              sql_str, acl_name);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           ERRload_struct (NFM, NFM_E_BAD_ACL, "", NULL);
           _NFMdebug ((fname, "No Such Acl : status = <0x%.8x>\n", 
		       NFM_E_BAD_ACL));
           return (NFM_E_BAD_ACL);
         }
        return (status);
      }

     _NFMdebug ((fname, "SUCCESSFUL : Acl Name = <%s>\n", acl_name));
     return (NFM_S_SUCCESS);
   }

 long NFMget_acl_workflow_no (user_id, acl_no, wf_no)
   long    user_id;
   long    acl_no;
   long    *wf_no;
   {
     static char *fname = "NFMget_acl_workflow_no" ;
     long    status, atol ();
     char    sql_str [1024], value [50];

     *wf_no = 0;

     _NFMdebug ((fname, "ACL WF NO : Acl      No = <%d>  ", acl_no ));

     sprintf (sql_str, "WHERE %s = %d", "n_aclno", acl_no);

     status = NFMget_attr_value (user_id, "NFMACLS", "n_workflowno",
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           ERRload_struct (NFM, NFM_E_BAD_ACL, "", NULL);
           _NFMdebug ((fname, "No Such Acl : status = <0x%.8x>\n", 
		       NFM_E_BAD_ACL));
           return (NFM_E_BAD_ACL);
         }
        return (status);
      }

     *wf_no = atol (value);

     _NFMdebug ((fname, "SUCCESSFUL : Workflow No = <%d>\n", *wf_no));
     return (NFM_S_SUCCESS);
   }
