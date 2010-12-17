#include "machine.h"
#include "NFMA.h"

  extern struct NFMglobal_st NFMglobal ;

 long NFMdelete_node (user_id, node_name)
   long    user_id;
   char    *node_name;
   {
     static char *fname = "NFMdelete_node" ;
      long      status, atol ();
      char      sql_str [1024];
      long      node_no;
      long      NFMcheck_node_sa ();
      
     _NFMdebug ((fname, " Node Name %s\n", node_name)) ;

      status = NFMget_node_no (NFMglobal.NFMuserid, node_name, &node_no);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Get Sa No : status = <0x%.8x>\n",
		     status));
         return (status);
       }

      status = NFMcheck_node_sa (NFMglobal.NFMuserid, node_no);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Chk If Sa In Node : status = <0x%.8x>\n",
         status));
         return (status);
       }

     sprintf (sql_str, "DELETE FROM %s WHERE %s = %d",
	      "NFMNODES", "n_nodeno", node_no);

      status = NFMstop_transaction (0);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Start Transaction : status = <0x%.8x>\n",
         status));
         return (status);
       }

      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
       {
         NFMrollback_transaction (0);
         ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
         _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
		     status));
         return (NFM_E_SQL_STMT);
       }

      status = NFMreturn_serial_slot (NFMglobal.NFMuserid, "nfmnodes", 
               "n_nodeno", node_no);
      if (status != NFM_S_SUCCESS)
       {
         NFMrollback_transaction (0);
         _NFMdebug ((fname, "Return Serial Slot : status = <0x%.8x>\n",
		     status));
         return (status);
       }

      status = NFMstart_transaction (0);
      if (status != NFM_S_SUCCESS)
       {
         _NFMdebug ((fname, "Start Transaction : status = <0x%.8x>\n",
         status));
         return (status);
       }

      _NFMdebug ((fname, "SUCCESSFUL\n")) ;
      return (NFM_S_SUCCESS);
   }

 long NFMcheck_node_sa (user_id, node_no)
   long    user_id;
   long    node_no;
   {
     static char *fname = "NFMcheck_node_sa" ;
      long     status, atol ();
      char     sql_str [1024], value [50];

     _NFMdebug ((fname, "Node No %d\n", node_no)) ;

     sprintf (sql_str, "WHERE %s = %d", "n_nodeno", node_no);

      status = NFMget_attr_value (NFMglobal.NFMuserid, 
				  "NFMSTORAGEAREA", "COUNT(*)",
				  sql_str, value);
      if (status != NFM_S_SUCCESS && status != NFM_I_BAD_CONDITION)
       {
         _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n",
         status));
         return (status);            
       }

      if (atol (value) > 0)
       {
         ERRload_struct (NFM, NFM_E_NODE_USED, "", NULL);
         _NFMdebug ((fname, "Sa In This Node : status = <0x%.8x>\n",
         NFM_E_NODE_USED));
         return (NFM_E_NODE_USED);            
       }

      _NFMdebug ((fname, "SUCCESSFUL\n")) ;
      return (NFM_S_SUCCESS);    
   }
