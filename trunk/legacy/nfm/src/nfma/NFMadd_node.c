#include "machine.h"
#include "NFMA.h"

 long NFMquery_add_node_attributes (user_id, attr_list,
                                    data_list, value_list)
   long    user_id;
   MEMptr  *attr_list, *data_list, *value_list;
   {
     static char *fname = "NFMquery_add_node_attributes" ;
     long     status;

      _NFMdebug ((fname, "ENTER\n")) ;

      status = NFMquery_table_attributes (user_id,
               "NFMSYSTEM", "NFMNODES",
               attr_list, data_list, value_list);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose (attr_list);
         MEMclose (attr_list);
         MEMclose (attr_list);
         _NFMdebug ((fname, "Qry Cond Attr : status = <0x%.8x>\n",
         status));
         return (status);
       }

      _NFMdebug ((fname, "SUCCESSFUL\n")) ;
      return (NFM_S_SUCCESS);
   }   

 long NFMadd_node (user_id, attr_list, data_list)
   long    user_id;
   MEMptr  attr_list, data_list;
   {
     static char *fname = "NFMadd_node" ;
      long    status;

     _NFMdebug ((fname, "ENTER\n")) ;

     status = _NFMadd_node (user_id, attr_list, data_list) ;
     if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Add Node : status = <0x%.8x>\n",
		     status));
         return (status) ;
       }

      _NFMdebug ((fname, "SUCCESSFUL\n")) ;
      return (NFM_S_SUCCESS);
   }
