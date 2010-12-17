#include "machine.h"
#include "CMDTOOLS.h"
#include <netdb.h>

 long _NFMadd_node (user_id, attr_list, data_list)
   long    user_id;
   MEMptr  attr_list, data_list;
   {
      char *fname = "_NFMadd_node" ;
      long    status;
      char    *clh_status, *clh_vbyop ();
      char    *sql_str, *sql_str1;
      char    op_sys [10], mach_id [10];
      long    node_no, x, y, count;
      long    a, b ;
      char    value [100], node_name [100];
      char    **column, **data, **data1;
      short   xns_found, tcp_found ;
      struct hostent *host_ptr ;

     _NFMdebug ((fname, "ENTER\n")) ;

      status = MEMbuild_array (attr_list);
      if (status != MEM_S_SUCCESS)
       {
         status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		     status));
         return (NFM_E_MEM);         
       }

      status = MEMbuild_array (data_list);
      if (status != MEM_S_SUCCESS)
       {
         status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		     status));
         return (NFM_E_MEM);         
       }

      column = (char **) attr_list -> column_ptr;
      data   = (char **) attr_list -> data_ptr;

      data1  = (char **) data_list -> data_ptr;

      a = -1; b = -1; 

      for (y = 0; y < attr_list -> columns; ++y)
       {
              if (! strcmp (column [y], "n_name"))      a = y;
         else if (! strcmp (column [y], "n_datatype"))  b = y;
       }

      mach_id [0] = 0;  op_sys [0] = 0;

      for (x = 0; x < attr_list -> rows; ++x)
       {
         count = attr_list -> columns * x;
         
         if (! strcmp (data [count + a], "n_nodename"))
            sprintf (node_name, "%s", data1 [x]);
         else if (! strcmp (data [count + a], "n_machid"))
	  {
            sprintf (mach_id, "%s", data1 [x]);
	    NFMupper_case (mach_id, mach_id);
 	  }
         else if (! strcmp (data [count + a], "n_opsys"))
	  {
            sprintf (op_sys, "%s", data1 [x]);
	    NFMupper_case (op_sys, op_sys);
	  }
       }

      if (! strlen (node_name))
       {
         status = ERRload_struct (NFM, NFM_E_NULL_NODE, "", NULL);
         _NFMdebug ((fname, "Node Name Is Null : status = <0x%.8x>\n",
         NFM_E_NULL_NODE));
         return (NFM_E_NULL_NODE);         
       }

/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
    /* Added for SUN/SCO as NETMAP_info is not supported in the new
         clh_vbyop() -- SSRS - 22/11/93 */
      
    /*  Use what the user inputs if something is there ** JM 6/28/94 **
     */
    if (strlen(op_sys) > 0)
        strncpy(value, op_sys, strlen(op_sys));
    else
        strncpy(value,  "UNIX",  4);
#else
      clh_status = clh_vbyop (node_name, "NETMAP_info", value, 4);
      if (clh_status)
      {
      /*  if this fails, try using what was entered by the user for op_sys
           and mach_id. If there is nothing there then return with error
           message
      */
          if ((strlen(op_sys)==0))
          {
	      ERRload_struct (NETS, NET_E_MESSAGE, "%s", clh_status) ;
	      ERRload_struct (NFM, NFM_E_CLH, "%s%s", 
			 "operating system info", node_name);
              _NFMdebug ((fname, "Clh Look Up : status = <0x%.8x>\n", 
			   NFM_E_CLH));
              return (NFM_E_CLH);          
          }
          else
              strncpy (value, op_sys, strlen(op_sys));
       }

#endif

      if (! strncmp (value, "UNIX", 4))
       {
/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
         /* Added by SSRS - 22/11/93 */
         sprintf (op_sys,   "UNIX");
         sprintf (mach_id,  "UNIX");
#else
         sprintf (op_sys,   "CLIX");
         sprintf (mach_id,  "CLIX");
#endif
       }
      else if (! strncmp (value, "VMS", 3))
       {
         sprintf (op_sys,  "VMS");
         sprintf (mach_id, "VAX");
       }
      else if (! strncmp (value, "VM/SP", 5))
       {
         sprintf (op_sys,  "VM/SP");
         sprintf (mach_id, "IBM4831");
       }

      sql_str = (char *) malloc (MEM_SIZE + attr_list -> rows * 50 + 
                                 data_list -> row_size);
      if (! sql_str)
       {
         status = ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", 
							NFM_E_MALLOC));
         return (NFM_E_MALLOC);
       }
      sql_str [0] = 0;

      sql_str1 = (char *) malloc (MEM_SIZE + data_list -> row_size);
      if (! sql_str1)
       {
         free (sql_str);
         status = ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC));
         return (NFM_E_MALLOC);
       }
      sql_str1 [0] = 0;

      status = NFMstop_transaction (0);
      if (status != NFM_S_SUCCESS)
       {
         free (sql_str);
         free (sql_str1);
         _NFMdebug ((fname, "Stop Transaction : status = <0x%.8x>\n",
         status));
         return (status);
       }

      sprintf (sql_str,  "INSERT INTO NFMNODES (");
      sprintf (sql_str1, ") VALUES (");

      /* if n_tcpip and n_xns are both not "Y" then return error */

      xns_found = 0 ;
      tcp_found = 0 ;

      for (x = 0; x < attr_list -> rows; ++x)
       {
         count = attr_list -> columns * x;
   
         if (! strcmp (data [count + a], "n_tcpip"))
          {
            NFMupper_case (data1 [x], data1 [x]) ;

            if (! strcmp (data1 [x], "Y"))
             {
	       tcp_found = 1;
/********* gone in ISS7.0
               clh_status = clh_vbyop (node_name, 
                            "tcp_address", value, 50);
               if (clh_status)
***********/

	       host_ptr = gethostbyname (node_name) ;
	       if (host_ptr == NULL)
                {
                  free (sql_str);
                  free (sql_str1);
                  status = ERRload_struct (NFM, NFM_E_NO_TCP, "", NULL);
                  _NFMdebug ((fname, "TCP AddrLookUp : status = <0x%.8x>\n",
                  NFM_E_NO_TCP));
                  return (NFM_E_NO_TCP);          
                }
	       _NFMdebug ((fname, "TCPIP FOUND\n")) ;
               sprintf (value, "%s", "Y");
             }
            else 
              sprintf (value, "%s", "N");

            status = MEMwrite_data (data_list, value, 1, x + 1);
            if (status != MEM_S_SUCCESS)
             {
               free (sql_str);
               free (sql_str1);
               status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               NFMrollback_transaction (0);
               _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			   status));
               return (NFM_E_MEM);
             }  
          }  
         else if (! strcmp (data [count + a], "n_xns"))
          {
            NFMupper_case (data1 [x], data1 [x]) ;

            if (! strcmp (data1 [x], "Y"))
             {
	       xns_found = 1 ;

               clh_status = clh_vbyop (node_name, "address", value, 50);
               if (clh_status)
                {
                  free (sql_str);
                  free (sql_str1);
                  status = ERRload_struct (NFM, NFM_E_NO_XNS, "", NULL);
                  _NFMdebug ((fname, "XNS AddrLookUp : status = <0x%.8x>\n",
                  NFM_E_NO_XNS));
                  return (NFM_E_NO_XNS);          
                }
               sprintf (value, "%s", "Y");
             }
            else
              sprintf (value, "%s", "N");

            status = MEMwrite_data (data_list, value, 1, x + 1);
            if (status != MEM_S_SUCCESS)
             {
               free (sql_str);
               free (sql_str1);
               status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               NFMrollback_transaction (0);
               _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			   status));
               return (NFM_E_MEM);
             }  
          }  
         else if ((! strcmp (data [count + a], "n_decnet")) ||
		  (! strcmp (data [count + a], "n_netware")) ||
		  (! strcmp (data [count + a], "n_nfs")))
          {
/*
            NFMupper_case (data1 [x], value) ;
*/
/* change the user input to  N if it is not Y -AV 19 Apr 96 */
 
            NFMupper_case (data1 [x], data1[x]) ;
 
            if (!strcmp(data1[x], "Y"))
                sprintf(value, "%s", data1[x]);
            else
                sprintf(value, "%s", "N");
/* AV */ 


            status = MEMwrite_data (data_list, value, 1, x + 1);
            if (status != MEM_S_SUCCESS)
             {
               free (sql_str);
               free (sql_str1);
               status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               NFMrollback_transaction (0);
               _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			   status));
               return (NFM_E_MEM);
             }  
          }  
         else if (! strcmp (data [count + a], "n_machid"))
          {
            status = MEMwrite_data (data_list, mach_id, 1, x + 1);
            if (status != MEM_S_SUCCESS)
             {
               free (sql_str);
               free (sql_str1);
               status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               NFMrollback_transaction (0);
               _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			   status));
               return (NFM_E_MEM);
             }  
          }  
         else if (! strcmp (data [count + a], "n_opsys"))
          {
            status = MEMwrite_data (data_list, op_sys, 1, x + 1);
            if (status != MEM_S_SUCCESS)
             {
               free (sql_str);
               free (sql_str1);
               status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               NFMrollback_transaction (0);
               _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			   status));
               return (NFM_E_MEM);
             }  
          }  
         else if (! strcmp (data [count + a], "n_nodeno"))
          {
            status = NFMget_serial_slot (user_id, "nfmnodes",
                     data [count + a], &node_no);
            if (status != NFM_S_SUCCESS)
             {
               free (sql_str);
               free (sql_str1);
               NFMrollback_transaction (0);
               _NFMdebug ((fname, "Get Node No : status = <0x%.8x>\n",
               status));
               return (status);
             }

            sprintf (value, "%d", node_no);

            status = MEMwrite_data (data_list, value, 1, x + 1);
            if (status != MEM_S_SUCCESS)
             {
               free (sql_str);
               free (sql_str1);
               status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               NFMrollback_transaction (0);
               _NFMdebug ((fname, "ME Wr Data : status = <0x%.8x>\n",
			   status));
               return (NFM_E_MEM);
             }  
          }

         if (x)
          {
            strcat (sql_str,  ", ");
            strcat (sql_str1, ", ");
          }

         strcat (sql_str, data [count + a]);

         if (! strncmp (data [count + b], "char", 4))
          {
            strcat (sql_str1, "'");
            strcat (sql_str1, data1 [x]); 
            strcat (sql_str1, "'");
          }
         else
          {
            if (strlen (data1 [x]))
              strcat (sql_str1, data1 [x]); 
            else
              strcat (sql_str1, "null");
          }
       }

      if (!(xns_found || tcp_found))
	{
	  NFMrollback_transaction (0) ;
	  ERRload_struct (NFM, NFM_E_BAD_PROTOCOL, "", "" ) ;
	  _NFMdebug ((fname, "Neither tcp nor xns specified : status = <0x%.8x>\n", 
		    NFM_E_BAD_PROTOCOL) );
	  return (NFM_E_BAD_PROTOCOL) ;
	}

      strcat (sql_str, sql_str1);
      strcat (sql_str, ")");

      free (sql_str1);

      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
       {
         free (sql_str);
         NFMrollback_transaction (0);

         if (status == SQL_E_DUPLICATE_VALUE)
          {
            status = ERRload_struct (NFM, NFM_E_DUP_NODE, "", NULL);
            _NFMdebug ((fname, "Node Exists : status = <0x%.8x>\n", NFM_E_DUP_NODE));
            return (NFM_E_DUP_NODE);         
          }

         status = ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
         _NFMdebug ((fname, "Sql Syntax : status = <0x%.8x>\n", status));
         return (NFM_E_SQL_STMT);         
       }

      free (sql_str);

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
