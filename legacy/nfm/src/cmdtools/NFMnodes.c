#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"

 long NFMget_node_no (user_id, node_name, node_no)
   long    user_id;
   char    *node_name;
   long    *node_no;
   {
     static char *fname = "NFMget_node_no" ;
     long    status, atol ();
     char    sql_str [1024], value [50];

     *node_no = 0;
     _NFMdebug ((fname, "User Id %d : Node Name %s\n",
		 user_id, node_name)) ;

     sprintf (sql_str, "WHERE %s = '%s'", "n_nodename", node_name);

     status = NFMget_attr_value (user_id, "NFMNODES", "n_nodeno",
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           ERRload_struct (NFM, NFM_E_BAD_NODE, "", NULL);
           _NFMdebug ((fname, "No Such Node : status = <0x%.8x>\n", NFM_E_BAD_NODE)) ;
           return (NFM_E_BAD_NODE);
         }

        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n", status));
        return (status);
      }

     *node_no = atol (value);

     _NFMdebug ((fname, "SUCCESSFUL : NODE NO : Node No = <%d>\n", *node_no));

     return (NFM_S_SUCCESS);
   }

 long NFMget_node_name (user_id, node_no, node_name)
   long    user_id;
   long    node_no;
   char    *node_name;
   {
     static char *fname = "NFMget_node_name" ;
     long    status;
     char    sql_str [1024];

     node_name [0] = 0;

     _NFMdebug ((fname, "User id %d : Node No %d\n", user_id, node_no)) ;

     sprintf (sql_str, "WHERE %s = %d","n_nodeno", node_no);

     status = NFMget_attr_value (user_id, "NFMNODES", "n_nodename",
              sql_str, node_name);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           ERRload_struct (NFM, NFM_E_BAD_NODE, "", NULL);
           _NFMdebug ((fname, "NODE NAME : No Such Node : status = <0x%.8x>\n", NFM_E_BAD_NODE));
           return (NFM_E_BAD_NODE);
         }

        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n", status));
        return (status);
      }

     _NFMdebug ((fname, "SUCCESSFUL : Node Name = <%s>\n", node_name));

     return (NFM_S_SUCCESS);
   }
