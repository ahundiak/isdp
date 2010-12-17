#include "machine.h"

#include "NFMA.h"

  extern struct NFMglobal_st NFMglobal ;

long NFMquery_change_node_attributes ( user_id, node_name, attr_list,
				       data_list, value_list )
    long   user_id;
    char   *node_name;
    MEMptr *attr_list;
    MEMptr *data_list;
    MEMptr *value_list;
{
  static char *fname = "NFMquery_change_node_attributes" ;
    long   status;
    int    r;
    int    c;
    char   sql_string[500];
    char   **data;
    MEMptr dbuff  = NULL;

  _NFMdebug ((fname, "User id %d : Node Name %s\n",
	      user_id, node_name)) ;

  status = NFMquery_add_node_attributes (NFMglobal.NFMuserid, attr_list,
					 data_list, value_list);
    if( status != NFM_S_SUCCESS )
      {
	_NFMdebug ((fname, "Qry  Attr : status < 0x%.8x >\n",
		    status));
	return( status );
      }


    status = MEMbuild_array( *attr_list ) ;
    if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMbuild_array : data_list : status = <0x%.8x>\n",
                    status)) ;
        ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        return (NFM_E_MEM) ;
      }


    status = MEMbuild_array( *data_list );
     if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMbuild_array : data_list : status = <0x%.8x>\n",
                    status)) ;
        ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        return (NFM_E_MEM) ;
      }

    data = (char**) (*attr_list)->data_ptr;

/*  Load attribute names into query string 
 */
    strcpy( sql_string, "SELECT " );
    for( r=0; r < (*attr_list)->rows; ++r )
    {
	c = (*attr_list)->columns * r;
	strcat( sql_string, data[c] );
	if( (r+1) < (*attr_list)->rows )
	    strcat( sql_string, ", " );
    } 
    strcat( sql_string, " FROM NFMNODES WHERE n_nodename = '" );
    strcat( sql_string, node_name );
    strcat( sql_string, "'" );

  
    status = SQLquery( sql_string, &dbuff, MEM_SIZE ) ;
    if (status != SQL_S_SUCCESS) 
    {
        _NFMdebug ((fname, "SQLquery = < 0x%.8x >\n", status));
        MEMclose( &dbuff );
	return(NFM_E_SQL_QUERY);
    }

    status = MEMbuild_array ( dbuff ) ;
    if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMbuild_array dbuff : status = <0x%.8x>\n",
                    status));
        ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        return (NFM_E_MEM) ;
      }

    data = (char **) dbuff->data_ptr ;

        for( r=0; r < (*attr_list)->rows; ++r )
	  {
        status = MEMwrite_data ( *data_list, data[r], 1, r+1) ;
        if (status != MEM_S_SUCCESS)
          {
            ERRload_struct (NFM, NFM_E_MEM, "", "") ;
            _NFMdebug ((fname, "MEMwrite_data : status = <0x%.8x>\n",
                        status)) ;
            return (NFM_E_MEM) ;
          }
      }

    status = MEMclose (&dbuff) ;
    if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n",
                    status)) ;
        ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        return (NFM_E_MEM) ;
      }

    _NFMdebug ((fname, "SUCCESSFUL\n")) ;
    return( NFM_S_SUCCESS );
}

long NFMchange_node (user_id, attr_list, data_list)
    long    user_id;
    MEMptr  attr_list, data_list;
{
  static char *fname = "NFMchange_node" ;
    long    status;
    long    x;
    long    y;
    long    count;
    long    a;
    long    b;
    long    d;

    char    op_sys [10];
    char    mach_id [10];
    char    value [100];
    char    temp_str[100];
    char    node_name[100];

    char    *clh_status;
    char    *clh_vbyop ();
    char    *sql_str;
 
    char    **column;
    char    **data;
    char    **data1;
    int     comma;

    _NFMdebug ((fname, "User Id   = <%d>\n", user_id));
    status = MEMbuild_array (attr_list);
    if (status != MEM_S_SUCCESS)
    {
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);         
    }

    status = MEMbuild_array (data_list);
    if (status != MEM_S_SUCCESS)
    {
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n", status));
         return (NFM_E_MEM);         
    }

    column = (char **) attr_list -> column_ptr;
    data   = (char **) attr_list -> data_ptr;

    data1  = (char **) data_list -> data_ptr;

    a = -1; b = -1; d = -1;

    for (y = 0; y < attr_list -> columns; ++y)
    {
              if (! strcmp (column [y], "n_name"))      a = y;
         else if (! strcmp (column [y], "n_datatype"))  b = y;
	 else if (! strcmp (column [y], "n_update"))    d = y;
    }

    mach_id[0] = 0;
    op_sys[0]  = 0;

    for (x = 0; x < attr_list -> rows; ++x)
    {
         count = attr_list -> columns * x;
         
         if (! strcmp (data [count + a], "n_nodename"))
            sprintf (node_name, "%s", data1 [x]);
         else if (! strcmp (data [count + a], "n_machid"))
	 {
            sprintf (mach_id, "%s", data1 [x]);
	    NFMupper_case (mach_id, mach_id) ;
	 }
         else if (! strcmp (data [count + a], "n_opsys"))
	 {
            sprintf (op_sys, "%s", data1 [x]);
	    NFMupper_case (op_sys, op_sys) ;
	 }
    }

    if (! strlen (node_name))
    {
         ERRload_struct (NFM, NFM_E_NULL_NODE, "", NULL);
         _NFMdebug ((fname, "Node Name Is Null : status = <0x%.8x>\n",
         NFM_E_NULL_NODE));
         return (NFM_E_NULL_NODE);         
    }

/*    mach_id [0] = 0;  op_sys [0] = 0;   IGI-23.5.95  */

/* HP-PORT IGI 25 Aug 94 */
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))

    /* Added for SUN/SCO as NETMAP_info is not supported in the new clh_vbyop().
       SSRS - 22/11/93 
    */
    /*  Use what the user inputs if something is there ** JM 6/28/94 **
     */
    if (strlen(op_sys) > 0)
	strncpy(value, op_sys, strlen(op_sys));
    else
        strncpy(value, "UNIX", 4); 
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
			 "operating system information", node_name);
           _NFMdebug ((fname, "Clh Look Up : status = <0x%.8x>\n", NFM_E_CLH));
           return (NFM_E_CLH);          
	 }
	 else
	     strncpy (value, op_sys, strlen(op_sys));
    }
#endif

/*  IGI - 23.5.95
    if (! strncmp (value, "UNIX", 4))
    {   */
/* HP-PORT IGI 25 Aug 94 */
/*#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))  */
         /* Added for SUN/SCO by SSRS - 22/11/93 */
/*         sprintf (op_sys,  "UNIX");
         sprintf (mach_id, "UNIX");
#else
         sprintf (op_sys,  "CLIX");
         sprintf (mach_id, "CLIX");
#endif
    } */
/*    else if (! strncmp (value, "VMS", 3))
    {
         sprintf (op_sys,  "VMS");
         sprintf (mach_id, "VAX");
    }
    else if (! strncmp (value, "VM/SP", 5))
    {
         sprintf (op_sys,  "VM/SP");
         sprintf (mach_id, "IBM4831");
    }
  */
    sql_str = (char *) malloc (MEM_SIZE + attr_list -> rows * 50 + 
                                 data_list -> row_size);
    if (! sql_str)
    {
         ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
         _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", 
		     NFM_E_MALLOC));
         return (NFM_E_MALLOC);
    }
    sql_str [0] = 0;

    status = NFMstop_transaction (0);
    if (status != NFM_S_SUCCESS)
    {
         free (sql_str);
         _NFMdebug ((fname, "Stop Transaction : status = <0x%.8x>\n",
         status));
         return (status);
    }

    sprintf (sql_str,  "UPDATE NFMNODES SET ");
    comma = 0;

    for (x = 0; x < attr_list -> rows; ++x)
    {
         count = attr_list -> columns * x;
   
         if (! strcmp (data [count + a], "n_tcpip"))
          {
            NFMupper_case (data1 [x], data1 [x]) ;

            if (! strcmp (data1 [x], "Y"))
             {
               clh_status = clh_vbyop (node_name,"tcp_address", value, 50);
               if (clh_status)
                {
                  free (sql_str);
                  ERRload_struct (NFM, NFM_E_NO_TCP, "", NULL);
                  _NFMdebug ((fname, "TCP AddrLookUp : status = <0x%.8x>\n",
                  NFM_E_NO_TCP));
                  return (NFM_E_NO_TCP);          
                }

               sprintf (value, "%s", "Y");
             }
            else 
               sprintf (value, "%s", "N");

            status = MEMwrite_data (data_list, value, 1, x + 1);
            if (status != MEM_S_SUCCESS)
             {
               free (sql_str);
               ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               NFMrollback_transaction (0);
               _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			   status)) ;
               return (NFM_E_MEM);
             }  
          }  
         else if (! strcmp (data [count + a], "n_xns"))
          {
            NFMupper_case (data1 [x], data1 [x]) ;

            if (! strcmp (data1 [x], "Y"))
             {
               clh_status = clh_vbyop (node_name, "address", value, 50);
               if (clh_status)
                {
                  free (sql_str);
                  ERRload_struct (NFM, NFM_E_NO_XNS, "", NULL);
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
               ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               NFMrollback_transaction (0);
               _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			   status));
               return (NFM_E_MEM);
             }  
          }  
         else if ((! strcmp (data [count + a], "n_netware")) ||
		  (! strcmp (data [count + a], "n_nfs")))
          {
            NFMupper_case (data1 [x], data1[x]) ;

/* set it to N if value is not Y - PS Sep 14, 95 */
            if ( strcmp (data1 [x], "Y") != 0)
              sprintf (value, "%s", "N");

            status = MEMwrite_data (data_list, value, 1, x + 1);
            if (status != MEM_S_SUCCESS)
             {
               free (sql_str);
               ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               NFMrollback_transaction (0);
               _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			   status));
               return (NFM_E_MEM);
             }  
          }  
/******** durwood said to leave like this since we do not support it ***/
         else if (! strcmp (data [count + a], "n_decnet"))
          {
            sprintf (value, "%s", "N");

            status = MEMwrite_data (data_list, value, 1, x + 1);
            if (status != MEM_S_SUCCESS)
             {
               free (sql_str);
               ERRload_struct (NFM, NFM_E_MEM, "", NULL);
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
               ERRload_struct (NFM, NFM_E_MEM, "", NULL);
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
               ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               NFMrollback_transaction (0);
               _NFMdebug ((fname, "MEM Wr Data : status = <0x%.8x>\n",
			   status));
               return (NFM_E_MEM);
             }  
          }  
         else if (! strcmp (data [count + a], "n_nodeno"))
          {
	    sprintf( temp_str, " WHERE %s = %s ",data[count+a],data1[x] );
	    continue;
          }

	 if (! strcmp (data [count + d], "Y"))
	   {
	     if (comma)
	       strcat (sql_str,  ", ");
	     else
	       comma = 1;
	     
	     strcat (sql_str, data [count + a]);
	     strcat (sql_str, "=" );
	     
	     if (! strncmp (data [count + b], "char", 4))
	       {
		 strcat (sql_str, "'");
		 strcat (sql_str, data1 [x]); 
		 strcat (sql_str, "'");
	       }
	     else
	       {
		 if (strlen (data1 [x]))
		   strcat (sql_str, data1 [x]); 
		 else
		   strcat (sql_str, "null");
	       }
	   }
       }

      strcat (sql_str, temp_str );

      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
	{
         free (sql_str);
         NFMrollback_transaction (0);
         ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
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

      _NFMdebug ((fname, "SUCCESSFUL\n"));
      return (NFM_S_SUCCESS);
   }

