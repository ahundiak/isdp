#include "machine.h"
#include "NFMA.h"
#include "WFstruct.h"

  extern struct WFstruct WFinfo;

 long NFMquery_process_attributes (user_id, attr_list, data_list, value_list)
   long      user_id;
   MEMptr    *attr_list, *data_list, *value_list;
   {
     static char *fname = "NFMquery_process_attributes" ;
      long    status;
      long    table_no, atol();
      char    str[256];
      char    **data;
      MEMptr  buffer = NULL;
      struct WFstruct wf_struct;

     _NFMdebug ((fname, "ENTER\n")) ;

      sprintf (str, "SELECT n_tableno from NFMTABLES where n_tablename = '%s'",
               "nfmprocesses");
      status = SQLquery (str, &buffer, MEM_SIZE);
      if (status != SQL_S_SUCCESS)
       {
          MEMclose (&buffer);
          _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status));
          if (status != SQL_I_NO_ROWS_FOUND)
           {
              status = NFMerror (NFM_E_SQL_QUERY); 
           }
          ERRload_struct (NFM, NFM_E_SQL_QUERY, NULL);
          _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status));
         return (status);
       } 

      status = MEMbuild_array (buffer);
      if (status != MEM_S_SUCCESS)
       {
          MEMclose (&buffer);
          _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
                    status));
         return (NFM_E_MEM);
       }

      data = (char **) buffer->data_ptr;
      table_no = atol (data[0]); 
      MEMclose (&buffer); 

      status = WFcopy_workflow_structure (user_id, 0, &wf_struct);
      if (status != NFM_S_SUCCESS)
       {
         WFcopy_workflow_structure (user_id, 1, &wf_struct);
         _NFMdebug ((fname, "Copy Wf Struct Local : status = <0x%.8x>\n",
                    status));
         return (status);
       }

       /* Hardcode values in this structure to get pass query table def */

       strcpy(WFinfo.entity, "NFMSDP");
       WFinfo.workflow   = 1;
       WFinfo.acl        = 1;

       WFinfo.curr_state = 1;
       WFinfo.next_state = 0;

       WFinfo.proj_no    = -1;
       WFinfo.catalog_no     = table_no;
       WFinfo.item_no    = 0;

       strcpy(WFinfo.workflow_name, "NFM_SDP_WORKFLOW");
       strcpy(WFinfo.acl_name, "NFM_SDP_ACL");
       strcpy(WFinfo.proj_name, "");
       strcpy(WFinfo.catalog_name, "nfmprocesses");
       strcpy(WFinfo.item_name, "");
       strcpy(WFinfo.item_rev, "");
       strcpy(WFinfo.logon_s, "N");
       strcpy(WFinfo.logon_f, "N");
       strcpy(WFinfo.notify, "N");


      status = NFMquery_table_attributes (user_id, "NFMSYSTEM",
               "NFMPROCESSES", attr_list, data_list, value_list);
      if (status != NFM_S_SUCCESS)
       {
         WFcopy_workflow_structure (user_id, 1, &wf_struct);
         MEMclose (attr_list);
         MEMclose (data_list);
         MEMclose (value_list);
         _NFMdebug ((fname, "SUCCESSFUL : status = <%d>\n", status));
         return (status);
       }

      status = WFcopy_workflow_structure (user_id, 1, &wf_struct);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Copy Wf Struct GLobal : status = <0x%.8x>\n",
                   status));
         MEMclose (attr_list);
         MEMclose (data_list);
         MEMclose (value_list);
         return (status);
       }

      _NFMdebug ((fname, "SUCCESSFUL\n")) ;
      return (NFM_S_SUCCESS);
   }

