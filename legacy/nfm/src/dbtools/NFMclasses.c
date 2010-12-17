#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"

 long NFMget_class_no (user_id, wf_no, class_name, class_no)
   long    user_id;
   long    wf_no;
   char    *class_name;
   long    *class_no;
   {
     static char *fname = "NFMget_class_no" ;
     long    status, atol ();
     char    sql_str [1024], value [50];

     *class_no = 0;

     _NFMdebug ((fname, "Wf    No   = <%d>  : Class Name = <%s>\n",
		 wf_no, class_name)) ;

     sprintf (value, "%d", wf_no);

     sprintf (sql_str, "WHERE %s = '%s' AND %s = %s", 
	      "n_classname", class_name, "n_workflowno", value);


     status = NFMget_attr_value (user_id, "NFMCLASSES", "n_classno",
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           ERRload_struct (NFM, NFM_E_BAD_CLASS, "", NULL);
           _NFMdebug ((fname, "No Such Class : status = <0x%.8x>\n",
           NFM_E_BAD_CLASS));
           return (NFM_E_BAD_CLASS);
         }

        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n", status));
        return (status);
      }

     *class_no = atol (value);

     _NFMdebug ((fname, "SUCCESSFUL : Class No = <%d>\n", *class_no));
     return (NFM_S_SUCCESS);
   }

 long NFMget_class_name (user_id, wf_no, class_no, class_name)
   long    user_id;
   long    wf_no, class_no;
   char    *class_name;
   {
     static char *fname = "NFMget_class_name" ;
     long    status;
     char    sql_str [1024] ;

     class_name [0] = 0;

     _NFMdebug ((fname, "Wf    No   = <%d>  : Class No = <%d>\n",
		 wf_no, class_no)) ;

     sprintf (sql_str, "WHERE %s = %d", "n_classno", class_no);

     status = NFMget_attr_value (user_id, "NFMCLASSES", "n_classname",
              sql_str, class_name);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           ERRload_struct (NFM, NFM_E_BAD_CLASS, "", NULL);
           _NFMdebug ((fname, "No Such Class : status = <0x%.8x>\n",
           NFM_E_BAD_CLASS));
           return (NFM_E_BAD_CLASS);
         }

        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
        status));
        return (status);
      }

     _NFMdebug ((fname, "SUCCESSFUL : Class Name = <%s>\n", class_name));
     return (NFM_S_SUCCESS);
   }

 long NFMget_class_workflow_no (user_id, class_no, wf_no)
   long    user_id;
   long    class_no;
   long    *wf_no;
   {
     static char *fname = "NFMget_class_workflow_no" ;
     long    status, atol ();
     char    sql_str [1024], value [50];

     *wf_no = 0;

     _NFMdebug ((fname, "Class No = <%d>\n", 
		 class_no));

     sprintf (sql_str, "WHERE %s = %d", "n_classno", class_no);

     status = NFMget_attr_value (user_id, "NFMCLASSES", "n_workflowno",
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           ERRload_struct (NFM, NFM_E_BAD_CLASS, "", NULL);
           _NFMdebug ((fname, "No Such Class : status = <0x%.8x>\n",
           NFM_E_BAD_CLASS));
           return (NFM_E_BAD_CLASS);
         }

        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
        status));
        return (status);
      }

     *wf_no = atol (value);

     _NFMdebug ((fname, "SUCCESSFUL : Wf No = <%d>\n", *wf_no));
     return (NFM_S_SUCCESS);
   }
