#include "machine.h"
#include "WF.h"

 long NFMquery_activity_attributes (user_id, attr_list, data_list)
   long      user_id;
   MEMptr    *attr_list;
   MEMptr    *data_list;
   {
     static char *fname = "NFMquery_acitivity_attributes" ;
      long    status;
      MEMptr  value_list = NULL;  /* there will be no user input. */


      status = NFMquery_table_attributes (user_id, "NFMSYSTEM",
               "NFMACTIVITY", attr_list, data_list, &value_list);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose (attr_list);
         MEMclose (data_list);
         MEMclose (&value_list);
         _NFMdebug ((fname, "NFMquery_table_attributes = <%d>\n", status));
         return (status);
       }

     if (value_list)
       {
	 status = MEMclose (&value_list);
	 if (status != MEM_S_SUCCESS)
	   {
	     _NFMdebug ((fname, "MEMclose (&value_list) : status = <0x%.8x>\n",
			 status)) ;
	     return (NFM_E_MEM) ;
	   }
       }

      _NFMdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", 
		  NFM_S_SUCCESS));
      return (NFM_S_SUCCESS);
   }

