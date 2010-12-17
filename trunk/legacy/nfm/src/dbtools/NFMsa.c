#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"
#include "NFMfto_buf.h"
#include "DBTproto.h"

 long NFMget_sa_no (user_id, sa_name, sa_no)
   long    user_id;
   char    *sa_name;
   long    *sa_no;
   {
     static char *fname = "NFMget_sa_no" ;
     long    status, atol ();
     char    sql_str [1024], value [50];

     *sa_no = 0;

     _NFMdebug ((fname, "Sa Name = <%s>\n",
		 sa_name)) ;

     sprintf (sql_str, "WHERE n_saname = '%s'", sa_name) ;

     status = NFMget_attr_value (user_id, "NFMSTORAGEAREA", "n_sano",
				 sql_str, value) ;
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           ERRload_struct (NFM, NFM_E_BAD_ST_AREA, "", NULL);
           _NFMdebug ((fname, "No Such Sa : status = <0x%.8x>\n", 
		       NFM_E_BAD_ST_AREA));
           return (NFM_E_BAD_ST_AREA);
         }

        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n", status));
        return (status);
      }

     *sa_no = atol (value);

     _NFMdebug ((fname, "SUCCESSFUL No = <%d>\n", *sa_no));
     return (NFM_S_SUCCESS);
   }

 long NFMget_sa_name (user_id, sa_no, sa_name)
   long    user_id;
   long    sa_no;
   char    *sa_name;
   {
     static char *fname = "NFMget_sa_name" ;
     long    status;
     char    sql_str [1024];

     sa_name [0] = 0;

     _NFMdebug ((fname, "Sa   No   = <%d> \n", sa_no)) ;

     sprintf (sql_str, "WHERE n_sano = %d", sa_no) ;

     status = NFMget_attr_value (user_id, "NFMSTORAGEAREA", "n_saname",
              sql_str, sa_name);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           ERRload_struct (NFM, NFM_E_BAD_ST_AREA, "", NULL);
           _NFMdebug ((fname, "No Such Sa : status = <0x%.8x>\n", 
		       NFM_E_BAD_ST_AREA));
           return (NFM_E_BAD_ST_AREA);
         }

        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n", status));
        return (status);
      }

     _NFMdebug ((fname, "Sa Name = <%s> : SUCCESSFUL\n", sa_name));
     return (NFM_S_SUCCESS);
   }

 long NFMcheck_sa_no (user_id, sa_no)
   long    user_id;
   long    sa_no;
   {
     static char *fname = "NFMcheck_sa_no" ;
     long    status, atol ();
     char    sql_str [1024], value [50];
     
     _NFMdebug ((fname, "Sa   No = <%d>\n", sa_no  ));

     if (sa_no == 0) return (NFM_S_SUCCESS);

     sprintf (sql_str, "WHERE n_sano = %d", sa_no) ;

     status = NFMget_attr_value (user_id, "NFMSTORAGEAREA", "COUNT(*)",
              sql_str, value);
     if (status != NFM_S_SUCCESS)
      {
        if (status == NFM_I_BAD_CONDITION)
         {
           ERRload_struct (NFM, NFM_E_BAD_ST_AREA, "", NULL);
           _NFMdebug ((fname, "No Such Sa : status = <0x%.8x>\n", 
		     NFM_E_BAD_ST_AREA));
           return (NFM_E_BAD_ST_AREA);
         }

        _NFMdebug ((fname, "Get Attr Value : status = <0x%.8x>\n", status));
        return (status);
      }

     if (atol (value) != 1)
      {
	ERRload_struct (NFM, NFM_E_BAD_ST_AREA, "", NULL);
        _NFMdebug ((fname, "No Such Sa : status = <0x%.8x>\n",
		    NFM_E_BAD_ST_AREA));
        return (NFM_E_BAD_ST_AREA);
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long NFMget_sa_no_info (user_id, sa_no, 
                         node_name, user_name, passwd,
                         path_name, device_type, 
                         mach_id, op_sys,
                         net_tcp, net_xns, net_dec)
   long    user_id;
   long    sa_no;
   char    *node_name, *user_name, *passwd, *path_name, *device_type;
   char    *mach_id, *op_sys, *net_tcp, *net_xns, *net_dec;
   {
     static char *fname = "NFMget_sa_no_info" ;
     long     status;
     MEMptr   list = NULL;
     char     **data;
     char     sql_str [2048];

     node_name [0] = 0; user_name   [0] = 0; passwd  [0] = 0;
     path_name [0] = 0; device_type [0] = 0;
     mach_id   [0] = 0; op_sys      [0] = 0;
     net_tcp   [0] = 0; net_xns     [0] = 0; net_dec [0] = 0;

     _NFMdebug ((fname, "Sa     No   = <%d>\n", sa_no)) ;

     sprintf (sql_str,
     "%s %s, %s, %s, %s, %s, %s, %s, %s, %s, %s FROM %s WHERE %s = %d %s",
     "SELECT",

     "NFMNODES.n_nodename",     "NFMSTORAGEAREA.n_username", 
     "NFMSTORAGEAREA.n_passwd", 

     "NFMSTORAGEAREA.n_pathname", "NFMSTORAGEAREA.n_devicetype",

     "NFMNODES.n_machid",         "NFMNODES.n_opsys",

     "NFMNODES.n_tcpip", "NFMNODES.n_xns", "NFMNODES.n_decnet", 

     "NFMSTORAGEAREA, NFMNODES", 
     "NFMSTORAGEAREA.n_sano", sa_no,
     "AND NFMSTORAGEAREA.n_nodeno = NFMNODES.n_nodeno");

     status = SQLquery (sql_str, &list, MEM_SIZE);
     if (status != SQL_S_SUCCESS)
      {
        MEMclose (&list);

        if ((status) == SQL_I_NO_ROWS_FOUND)
         {
           ERRload_struct (NFM, NFM_E_BAD_ST_AREA, "", NULL);
           _NFMdebug ((fname, "NO Such Node : status = <0x%.8x>\n",
           NFM_E_BAD_ST_AREA));
           return (NFM_E_BAD_ST_AREA);
         }

	ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "Query Syntax : status = <0x%.8x>\n",
		    status));
        return ( NFM_E_SQL_QUERY);
      }

     status = MEMbuild_array (list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     data = (char **) list -> data_ptr;

     sprintf (node_name,   "%s", data [0]);
     sprintf (user_name,   "%s", data [1]);
     sprintf (passwd,      "%s", data [2]);
     sprintf (path_name,   "%s", data [3]);
     sprintf (device_type, "%s", data [4]);
     sprintf (mach_id,     "%s", data [5]);
     sprintf (op_sys,      "%s", data [6]);
     sprintf (net_tcp,     "%s", data [7]);
     sprintf (net_xns,     "%s", data [8]);
     sprintf (net_dec,     "%s", data [9]);

     status = MEMclose (&list);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Close : status = <0x%.8x>\n", status));
        return (NFM_E_MEM);
      }

     _NFMdebug ((fname, "SUCCESSFUL : Node Name = <%s> : User Name = <%s> : Passwd = <%s> : Path Name = <%s> : Device Type = <%s> : Mach Id = <%s> : Op Sys = <%s> : Tcp = <%s> : Xns = <%s> : Dec = <%s>\n",
		 node_name, user_name, passwd, path_name,
		 device_type, mach_id, op_sys, net_tcp, net_xns, net_dec)) ;
     return (NFM_S_SUCCESS);
   }

 long NFMget_sa_no_buffer (user_id, sa_no, list)
   long    user_id;
   long    sa_no;
   MEMptr  *list;
   {
     static char *fname = "NFMget_sa_no_buffer" ;
     long     status;
     char     sql_str [2048];

     _NFMdebug ((fname, "Sa   No = <%d>\n", sa_no  )) ;

     sprintf (sql_str,
     "%s %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s %s WHERE %s = %d %s",
     "SELECT",

     "NFMSTORAGEAREA.n_sano",
     "NFMNODES.n_nodename",     "NFMSTORAGEAREA.n_username", 
     "NFMSTORAGEAREA.n_passwd", 

     "NFMSTORAGEAREA.n_pathname", "NFMSTORAGEAREA.n_devicetype",

     "NFMNODES.n_machid",         "NFMNODES.n_opsys",

     "NFMNODES.n_tcpip", "NFMNODES.n_xns", "NFMNODES.n_decnet", 

     "FROM NFMSTORAGEAREA, NFMNODES", 
     "NFMSTORAGEAREA.n_sano", sa_no,
     "AND NFMSTORAGEAREA.n_nodeno = NFMNODES.n_nodeno");

     status = SQLquery (sql_str, list, MEM_SIZE);
     if (status != SQL_S_SUCCESS)
      {
        MEMclose (list);
        _sql_error (status);

        if ((status) == SQL_I_NO_ROWS_FOUND)
         {
           ERRload_struct (NFM, NFM_E_BAD_ST_AREA, "", NULL);
           _NFMdebug ((fname, "NO Such Node : status = <0x%.8x>\n",
           NFM_E_BAD_ST_AREA));
           return (NFM_E_BAD_ST_AREA);
         }

	ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
        _NFMdebug ((fname, "Query Syntax : status = <0x%.8x>\n",
		    status));
        return ( NFM_E_SQL_QUERY);
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }


long _NFMget_sano_info_fto_buf (sa_no, sa_name, file_buffer)
     long sa_no ;
     char *sa_name ;
     struct fto_buf *file_buffer ;
{ 
  static char *fname = "_NFMget_sano_info_fto_buf" ;
  MEMptr  list = NULL ;
  long    status ;
  char    sql_str [1024], clause [100] ;
  char    **data;

  _NFMdebug ((fname, "ENTER : sano %d : saname %s\n",
	      sa_no, sa_name)) ;
  if (sa_no != 0)
    sprintf (clause, "NFMSTORAGEAREA.n_sano = %d", sa_no) ;
  else
    sprintf (clause, "NFMSTORAGEAREA.n_saname = '%s'", sa_name);

  memset ((char *) file_buffer, NULL, sizeof (struct fto_buf)) ;

  sprintf (sql_str,
  "%s %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s %s WHERE %s %s",
  "SELECT",
  "NFMNODES.n_nodename",     
  "NFMSTORAGEAREA.n_username", 
  "NFMSTORAGEAREA.n_passwd", 
  "NFMSTORAGEAREA.n_pathname", 
  "NFMSTORAGEAREA.n_devicetype",
  "NFMSTORAGEAREA.n_plattername",
  "NFMSTORAGEAREA.n_partition",
  "NFMSTORAGEAREA.n_nfs",
  "NFMSTORAGEAREA.n_compress",
  "NFMNODES.n_machid",         
  "NFMNODES.n_opsys",
  "NFMNODES.n_tcpip", 
  "NFMNODES.n_xns", 
  "NFMNODES.n_decnet", 
  "NFMNODES.n_netware",
  

  "FROM NFMSTORAGEAREA, NFMNODES", 
  clause,	   
  "AND NFMSTORAGEAREA.n_nodeno = NFMNODES.n_nodeno");

  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    if ((status) == SQL_I_NO_ROWS_FOUND)
    {
      _NFMdebug ((fname, "Bad storage area : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_BAD_ST_AREA, "", "") ;
      return (NFM_E_BAD_ST_AREA);
    }
    _NFMdebug ((fname, "Query Syntax  <0x%.8x>\n",
		status)) ;
    ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
    return ( NFM_E_SQL_QUERY);
  }

  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    _NFMdebug ((fname, "MEMbuild_array (list) <0x%.8x> ", NFM_E_MEM));
    ERRload_struct (NFM, NFM_E_MEM, "", "") ;
    return (NFM_E_MEM);
  }
  data = (char **) list->data_ptr;
  strcpy (file_buffer->n_nodename, data[0]);
  strcpy (file_buffer->n_username, data[1]);
  strcpy (file_buffer->n_passwd, data[2]);
  strcpy (file_buffer->n_pathname, data[3]);
  strcpy (file_buffer->n_devicetype, data[4]);
  strcpy (file_buffer->n_plattername, data[5]);
  strcpy (file_buffer->n_partition, data[6]);
  strcpy (file_buffer->n_nfs, data[7]);
  strcpy (file_buffer->n_compress, data[8]);
  strcpy (file_buffer->n_machid, data[9]);
  strcpy (file_buffer->n_opsys, data[10]);
  strcpy (file_buffer->n_tcpip, data[11]);
  strcpy (file_buffer->n_xns, data[12]);
  strcpy (file_buffer->n_decnet, data[13]);
  strcpy (file_buffer->n_netware, data [14]) ;

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMclose (list): <0x%.8x>", status));
    ERRload_struct (NFM, NFM_E_MEM, "", "") ;
    return (NFM_E_MEM)  ;
  }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}



