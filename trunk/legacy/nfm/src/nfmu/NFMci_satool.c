#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMattr_def.h"
#include "NFMstruct.h"
#include "ERR.h"
#include "MSGstruct.h"

extern MSGptr NFMmsg_ptr;

struct sto_area_info STO_info;

long _NFMsa_info (sa_name)
char    *sa_name;
{ 
  /***
  This function queries the storage area information given the 
  storage name, and stores in the global structure. (the name of the global 
  variable should probably be changed to something generic.)
 
  CHANGE HISTORY:
    01/31/91 MFB creation.
  ***/

  MEMptr  list = NULL;
  long    status, atol ();
  char    sql_str [1024];
  char    **data;

  if (NFMmsg_ptr.debug_on)
  _NFM_num ("_NFMsa_info: enter");

  sprintf (sql_str,
  "%s %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s %s WHERE %s = '%s' %s",
  "SELECT",
  "NFMSTORAGEAREA.n_sano",
  "NFMNODES.n_nodename",     
  "NFMSTORAGEAREA.n_username", 
  "NFMSTORAGEAREA.n_passwd", 
  "NFMSTORAGEAREA.n_pathname", 
  "NFMSTORAGEAREA.n_devicetype",
  "NFMNODES.n_machid",         
  "NFMNODES.n_opsys",
  "NFMNODES.n_tcpip", 
  "NFMNODES.n_xns", 
  "NFMNODES.n_decnet", 

  "FROM NFMSTORAGEAREA, NFMNODES", 
  "NFMSTORAGEAREA.n_saname", sa_name,
  "AND NFMSTORAGEAREA.n_nodeno = NFMNODES.n_nodeno");

  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    if ((status) == SQL_I_NO_ROWS_FOUND)
    {
      status = ERRload_struct (NFM, NFM_E_BAD_ST_AREA, "", NULL);
      _NFM_num ("_NFMsa_info : Bad Storage = <0x%.8x>\n",
      NFM_E_BAD_ST_AREA);
      return (NFM_E_BAD_ST_AREA);
    }
    status = ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
    _NFM_num ("_NFMsa_info: Query Syntax  <0x%.8x>\n",
    NFM_E_SQL_QUERY);
    return ( NFM_E_SQL_QUERY);
  }

  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    status = NFMerror (NFM, NFM_E_MEM, NULL);
    _NFM_num ("_NFM_ci_sa_info: MEMbuild_array (list) <0x%.8x> ", NFM_E_MEM);
    return (NFM_E_MEM);
  }
  data = (char **) list->data_ptr;
  STO_info.sano  = atol (data[0]);
  strcpy (STO_info.nodename, data[1]);
  strcpy (STO_info.username, data[2]);
  strcpy (STO_info.passwd, data[3]);
  strcpy (STO_info.pathname, data[4]);
  strcpy (STO_info.devicetype, data[5]);
  strcpy (STO_info.machid, data[6]);
  strcpy (STO_info.opsys, data[7]);
  strcpy (STO_info.tcpip, data[8]);
  strcpy (STO_info.xns, data[9]);
  strcpy (STO_info.decnet, data[10]);

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    ERRload_struct (NFM, NFM_E_MEM, NULL);
    _NFM_num ("_NFMsa_info: MEMclose (list): <0x%.8x>", status);
    return (status);
  }

  if (NFMmsg_ptr.debug_on)
  _NFM_num ("_NFMsa_info: exit SUCCESSFUL <0x%.8x>\n", NFM_S_SUCCESS);
  return (NFM_S_SUCCESS);
}

long _NFMsa_buffer ( list )
MEMptr  *list;
{
  /***
  This function will prepare a buffer format, and fill the data with the 
  information in the global structure.

  CHANGE HISTORY:
    01/31/91 MFB creation
  ***/
 
  long     status;
  char     sql_str [2048];
  long     _NFMsa_buffer_format ();
  void     _NFMprint_STO_info();

  if (NFMmsg_ptr.debug_on)
  _NFM_num ("_NFMsa_buffer: enter...");
  status = _NFMsa_buffer_format (list);

  sprintf (sql_str, "%d\1", STO_info.sano);
  strcat (sql_str, STO_info.nodename);
  strcat (sql_str,"\1");
  strcat (sql_str, STO_info.username);
  strcat (sql_str,"\1");
  strcat (sql_str, STO_info.passwd);
  strcat (sql_str,"\1");
  strcat (sql_str, STO_info.pathname);
  strcat (sql_str,"\1");
  strcat (sql_str, STO_info.devicetype);
  strcat (sql_str,"\1");
  strcat (sql_str, STO_info.machid);
  strcat (sql_str,"\1");
  strcat (sql_str, STO_info.opsys);
  strcat (sql_str,"\1");
  strcat (sql_str, STO_info.tcpip);
  strcat (sql_str,"\1");
  strcat (sql_str, STO_info.xns);
  strcat (sql_str,"\1");
  strcat (sql_str, STO_info.decnet);
  strcat (sql_str,"\1");

  status = MEMwrite (*list, sql_str);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (list);
    _NFM_num ("_NFMsa_buffer: MEMwrite (list) <0x%.8x>", 
    status);
    return (status);
  }

  if (NFMmsg_ptr.debug_on)
  _NFM_num ("_NFMsa_buffer: exit successful");
  return (NFM_S_SUCCESS);  
  
}

long _NFMsa_buffer_format (list)
MEMptr *list;
{
  long status;

  if (NFMmsg_ptr.debug_on)
  _NFM_num ("_NFMsa_buffer_format: enter ...");

  status = MEMopen (list, 2* MEM_SIZE);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (list);
    _NFM_num ("_NFMsa_buffer_format: MEMopen (list) <0x%.8x>", status);
    return (status);
  }

  status = MEMwrite_format (*list, "n_sano", "integer");
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (list);
    _NFM_num ("_NFMsa_buffer_format: MEMwrite_format (n_sano) <0x%.8x>", 
    status);
    return (status);
  }

  status = MEMwrite_format (*list, "n_nodename", "char(30)");
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (list);
    _NFM_num ("_NFMsa_buffer_format: MEMwrite_format (n_nodename) <0x%.8x>",
    status);
    return (status);
  }

  status = MEMwrite_format (*list, "n_username", "char(14)");
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (list);
    _NFM_num ("_NFMsa_buffer_format: MEMwrite_format (n_username) <0x%.8x>",
    status);
    return (status);
  }

  status = MEMwrite_format (*list, "n_passwd", "char(50)");
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (list);
    _NFM_num ("_NFMsa_buffer_format: MEMwrite_format (n_passwd) <0x%.8x>",
    status);
    return (status);
  }

  status = MEMwrite_format (*list, "n_pathname", "char(50)");
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (list);
    _NFM_num ("_NFMsa_buffer_format: MEMwrite_format (n_pathname) <0x%.8x>",
    status);
    return (status);
  }

  status = MEMwrite_format (*list, "n_devicetype", "char(2)");
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (list);
    _NFM_num ("_NFMsa_buffer_format: MEMwrite_format (n_devicetype)<0x%.8x>",
    status);
    return (status);
  }

  status = MEMwrite_format (*list, "n_machid", "char(10)");
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (list);
    _NFM_num ("_NFMsa_buffer_format: MEMwrite_format (n_machid) <0x%.8x>",
    status);
    return (status);
  }

  status = MEMwrite_format (*list, "n_opsys", "char(10)");
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (list);
    _NFM_num ("_NFMsa_buffer_format: MEMwrite_format (n_opsys) <0x%.8x>",
    status);
    return (status);
  }

  status = MEMwrite_format (*list, "n_tcpip", "char(1)");
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (list);
    _NFM_num ("_NFMsa_buffer_format: MEMwrite_format (n_tcpip) <0x%.8x>",
    status);
    return (status);
  }

  status = MEMwrite_format (*list, "n_xns", "char(1)");
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (list);
    _NFM_num ("_NFMsa_buffer_format: MEMwrite_format (n_xns) <0x%.8x>",
    status);
    return (status);
  }


  status = MEMwrite_format (*list, "n_decnet", "char(1)");
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (list);
    _NFM_num ("_NFMsa_buffer_format: MEMwrite_format (n_decnet) <0x%.8x>",
    status);
    return (status);
  }

  if (NFMmsg_ptr.debug_on)
  _NFM_num ("_NFMsa_buffer_format: exit successfull");
  return (NFM_S_SUCCESS);

}

/* PUT IN PASSWORD SO THAT TEMP SA HAS PASSWD MRG 07/18/91 */
long _NFMadd_temp_sa (user_id, node_name,
                           user_name, path_name,passwd)
long     user_id;
char     *node_name, *user_name, *path_name,*passwd;
{
  long     status, atol ();
  char     *sql_str, *c_status;
  MEMptr   attr_list = NULL, data_list = NULL, value_list = NULL;
  char     **data, **column;
  long     x, y, count, i, j, and, node_no;
  char     value [50], value1[50];
  char     *clh_status, *clh_vbyop ();
      
  if (NFMmsg_ptr.debug_on)
  {
  _NFM_num ("_NFMadd_temp_sa: enter");
  _NFM_str ("_NFMadd_temp_sa: Node Name = <%s>  ", node_name);
  _NFM_str ("_NFMadd_temp_sa: User Name = <%s>  ", user_name);
  _NFM_str ("_NFMadd_temp_sa: Path Name = <%s>  ", path_name);
  }

  status = NFMquery_condition_attributes (user_id,
                  "nfmsystem", "nfmnodes", "", "",
                 &attr_list, &data_list, &value_list);
  if (status != NFM_S_SUCCESS)
  {
     MEMclose (attr_list);
     MEMclose (&data_list);
     MEMclose (&value_list);
    _NFM_num ("_NFMadd_temp_sa: NFMquery_condition_attributes: status = <0x%.8x>\n", status);
        return (status);
  }
  MEMclose (&value_list);  /* no need for this information because this   */
                           /* function is manualy adding the storage area */

  status = MEMbuild_array (attr_list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&attr_list);
    MEMclose (&data_list);
    status = ERRload_struct (NFM, NFM_E_MEM, NULL);
    _NFM_num ("_NFMadd_temp_sa: MEM Build Array : status = <0x%.8x>\n",
    NFM_E_MEM);
    return (NFM_E_MEM);
  }

  status = MEMbuild_array (data_list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&attr_list);
    MEMclose (&data_list);
    status = ERRload_struct (NFM, NFM_E_MEM, NULL);
    _NFM_num ("_NFMadd_temp_sa: MEM Build Array : status = <0x%.8x>\n",
    NFM_E_MEM);
    return (NFM_E_MEM);
  }

  column = (char **) attr_list -> column_ptr;
  data   = (char **) attr_list -> data_ptr;

  i = -1; j = -1;

  for (x = 0; x < attr_list -> rows; ++x)
  {
    count = attr_list -> columns * x;

    if (! strcmp (data [count + INDEX_N_NAME], "n_nodeno"))    i = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_nodename"))  j = x;
  }

  sql_str = (char *) malloc (4 * MEM_SIZE);
  if (! sql_str)
  {
    MEMclose (&attr_list);
    MEMclose (&data_list);
    _NFM_num ("_NFMadd_temp_sa: Get Attr Value : status = <0x%.8x>\n", status);
    return (status);
  }
  sql_str [0] = 0;

  sprintf (sql_str, " WHERE %s = ",
           data [(attr_list -> columns * j) + INDEX_N_NAME]);

  if (! strncmp (data [(attr_list -> columns * j) + INDEX_N_DATATYPE], 
                 "char", 4))
  {
    strcat (sql_str, "'");
    strcat (sql_str, node_name);
    strcat (sql_str, "'");
  }
  else
    strcat (sql_str, node_name);

  status = NFMget_attr_value (user_id, "NFMNODES",
                       data [(attr_list -> columns * i) + INDEX_N_NAME], 
                       sql_str, value1);
  if ((status != NFM_S_SUCCESS) && (status != NFM_I_BAD_CONDITION))
  {
    free (sql_str);
    MEMclose (&attr_list);
    MEMclose (&data_list);
    _NFM_num ("_NFMadd_temp_sa: Get Attr Value : status = <0x%.8x>\n", status);
    return (status);
  }

  if (status == NFM_I_BAD_CONDITION)
  {
    for (x = 0; x < attr_list -> rows; ++x)
    {
      count = attr_list -> columns * x;
      if (! strcmp (data [count + INDEX_N_NAME], "n_nodename"))
      {
        status = MEMwrite_data (data_list, node_name, 1, x + 1);
        if (status != MEM_S_SUCCESS)
        {
          free (sql_str);
          MEMclose (&attr_list);
          MEMclose (&data_list);
          status = ERRload_struct (NFM, NFM_E_MEM, NULL);
                   _NFM_num ("_NFMadd_temp_sa: MEM Wr Data:<0x%.8x>\n",
          NFM_E_MEM);
          return (NFM_E_MEM);
        }
        strcpy (STO_info.nodename, node_name);
      }
      else if (! strcmp (data [count + INDEX_N_NAME], "n_tcpip"))
      {

        c_status = (char *) clh_vbyop (node_name, 
                   "tcp_address", value, 10);
        if (c_status) sprintf (value, "%s", "N");
        else          sprintf (value, "%s", "Y");
 

/* Temporary storage area nodes protocol should be NULL */	

        status = MEMwrite_data (data_list, value, 1, x + 1);
        if (status != MEM_S_SUCCESS)
        {
          free (sql_str);
          MEMclose (&attr_list);
          MEMclose (&data_list);
          status = ERRload_struct (NFM, NFM_E_MEM, NULL);
          _NFM_num ("_NFMadd_temp_sa: MEM Wr Data : status = <0x%.8x>\n",
          NFM_E_MEM);
          return (NFM_E_MEM);
        }
/* Load 'N' in structure eventhough TCPIP exists
   this will force a value of NULL for protocol, and allow
   NETconnect to choose appropriate protocol
*/
        strcpy (STO_info.tcpip, "N");
      }
      else if (! strcmp (data [count + INDEX_N_NAME], "n_xns"))
      {
        c_status = (char *) clh_vbyop (node_name,
                           "address", value, 10);

        if (c_status) sprintf (value, "%s", "N");
        else          sprintf (value, "%s", "Y");
 
/* Temporary storage area nodes protocol should be NULL */	

        status = MEMwrite_data (data_list, value, 1, x + 1);
        if (status != MEM_S_SUCCESS)
        {
          free (sql_str);
          MEMclose (&attr_list);
          MEMclose (&data_list);
          /* status = NFMerror (NFM_E_MEM); */
          status = ERRload_struct (NFM, NFM_E_MEM, NULL);
          _NFM_num ("_NFMadd_temp_sa: MEM Wr Data : status = <0x%.8x>\n",
          NFM_E_MEM);
          return (NFM_E_MEM);
        }
/* Load 'N' in structure eventhough XNS exists
   this will force a value of NULL for protocol, and allow
   NETconnect to choose appropriate protocol
*/
        strcpy (STO_info.xns, "N");
      }
      else if (! strcmp (data [count + INDEX_N_NAME], "n_decnet"))
      {
        status = MEMwrite_data (data_list, "N", 1, x + 1);
        if (status != MEM_S_SUCCESS)
        {
          free (sql_str);
          MEMclose (&attr_list);
          MEMclose (&data_list);
          status = ERRload_struct (NFM, NFM_E_MEM, NULL);
          _NFM_num ("_NFMadd_temp_sa: MEM Wr Data : status = <0x%.8x>\n",
          NFM_E_MEM);
          return (NFM_E_MEM);
        }
        strcpy (STO_info.decnet, "N");
      }
    }

    status = _NFMadd_node (user_id, attr_list, data_list);
    if (status != NFM_S_SUCCESS)
    {
      free (sql_str);
      MEMclose (&attr_list);
      MEMclose (&data_list);
      _NFM_num ("_NFMadd_temp_sa: Add Node : status = <0x%.8x>\n", status);
      return (status);
    }

    status = NFMget_attr_value (user_id, "NFMNODES",
             data [(attr_list -> columns * i) + INDEX_N_NAME], sql_str, value1);
    if (status != NFM_S_SUCCESS)
    {
      free (sql_str);
      MEMclose (&attr_list);
      MEMclose (&data_list);

      if (status == NFM_I_BAD_CONDITION) 
      {
        status = ERRload_struct (NFM, NFM_E_BAD_NODE, "", NULL);
        _NFM_num ("_NFMadd_temp_sa: Bad Node : status = <0x%.8x>\n",
        NFM_E_BAD_NODE);
        return (NFM_E_BAD_NODE);
      }

      _NFM_num ("_NFMadd_temp_sa: Get Attr Value : status = <0x%.8x>\n",
      status);
      return (status);
    }
  }
  else 
  {
    strcpy (STO_info.nodename, node_name);
/* Load 'N' in structure eventhough XNS and/or TCP exists
   this will force a value of NULL for protocol, and allow
   NETconnect to choose appropriate protocol
*/
    strcpy (STO_info.tcpip, "N") ;
    strcpy (STO_info.xns, "N") ;
/*
    c_status = (char *) clh_vbyop (node_name,
                   "tcp_address", value, 10);
    if (c_status) 
      strcpy (STO_info.tcpip, "N");
    else  
      strcpy (STO_info.tcpip, "Y");
    c_status = (char *) clh_vbyop (node_name,
                           "address", value, 10);
    if (c_status) 
      strcpy (STO_info.xns, "N");
    else    
      strcpy (STO_info.xns, "Y");
 */
    strcpy (STO_info.decnet, "N");
  }

  /*** added 1/25/91, to retrieve information for machid, opsys and store ***/
  /*** them in global variable ***/

#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
  /* Added for SUN as NETMAP_info is not supported in the new clh_vbyop().
     SSRS - 22/11/93
  */
  strncpy(value,  "UNIX",  4);
#else
  clh_status = clh_vbyop (node_name, "NETMAP_info", value, 4);
  if (clh_status)
  {
    ERRload_struct (NETS, NET_E_MESSAGE, "%s", clh_status) ;
    ERRload_struct (NFM, NFM_E_CLH, "%s%s", 
		    "operating system information", node_name);
    _NFM_num ("_NFMadd_temp_sa: clhvbyop: <0x%.8x>\n", NFM_E_CLH);
    return (NFM_E_CLH);
  }
#endif
  if (! strncmp (value, "UNIX", 4))
  {
	
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
    /* Added for SUN/SCO by SSRS - 22/11/93 */
    strcpy (STO_info.opsys,   "UNIX");
    strcpy (STO_info.machid,  "UNIX");
    _NFM_num ("It is unix & unix");
#else
    strcpy (STO_info.opsys,  "CLIX");
    strcpy (STO_info.machid, "CLIX");
    _NFM_num ("It is clix & clix");
#endif
    _NFM_num ("machid: %s ", STO_info.machid);
    _NFM_num ("opsys:  %s ", STO_info.opsys);
  }
  else if (! strncmp (value, "VMS", 3))
  {
    strcpy (STO_info.opsys,  "VMS");
    strcpy (STO_info.machid, "VAX");
    strcpy (STO_info.xns, "Y");
  }
  else if (! strncmp (value, "VM/SP", 5))
  {
    strcpy (STO_info.opsys,  "VM/SP");
    strcpy (STO_info.machid, "IBM4831");
  }

  /*** end 1/25/91***/

  status = MEMclose (&attr_list);
  if (status != MEM_S_SUCCESS)
  {
    free (sql_str);
    MEMclose (&data_list);
    status = ERRload_struct (NFM, NFM_E_MEM, NULL);
    _NFM_num ("_NFMadd_temp_sa: MEM Build Array : status = <0x%.8x>\n",
    NFM_E_MEM);
    return (NFM_E_MEM);
  }

  status = MEMclose (&data_list);
  if (status != MEM_S_SUCCESS)
  {
    free (sql_str);
    status = ERRload_struct (NFM, NFM_E_MEM, NULL);
    _NFM_num ("_NFMadd_temp_sa: MEM Build Array : status = <0x%.8x>\n",
    NFM_E_MEM);
    return (NFM_E_MEM);
  }

  node_no = atol (value1);

  status = NFMquery_table_attributes (user_id, "NFMSYSTEM",
           "NFMSTORAGEAREA", &attr_list, &data_list, &value_list);

  if (status != NFM_S_SUCCESS)
  {
    free (sql_str);
    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&value_list);
    _NFM_num ("_NFMadd_temp_sa:NFMquery_table_attribute <0x%.8x>\n",
     status);
    return (status);
  }

  MEMclose (&value_list);

  status = MEMbuild_array (attr_list);
  if (status != MEM_S_SUCCESS)
  {
    free (sql_str);
    MEMclose (&attr_list);
    MEMclose (&data_list);
    status = ERRload_struct (NFM, NFM_E_MEM, NULL);
    _NFM_num ("_NFMadd_temp_sa: MEM Build Array : status = <0x%.8x>\n",
    NFM_E_MEM);
    return (NFM_E_MEM);
  }

  status = MEMbuild_array (data_list);
  if (status != MEM_S_SUCCESS)
  {
    free (sql_str);
    MEMclose (&attr_list);
    MEMclose (&data_list);
    status = ERRload_struct (NFM, NFM_E_MEM, NULL);
    _NFM_num ("_NFMadd_temp_sa: MEM Build Array : status = <0x%.8x>\n",
    NFM_E_MEM);
    return (NFM_E_MEM);
  }

  column = (char **) attr_list -> column_ptr;
  data   = (char **) attr_list -> data_ptr;

  i = -1; and = 0;  sql_str [0] = 0;

  sprintf (sql_str, " WHERE ");

  for (x = 0; x < attr_list -> rows; ++x)
  {
    count = attr_list -> columns * x;

    if (! strcmp (data [count + INDEX_N_NAME], "n_sano"))   
       i = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_nodeno")) 
    {
      if (and) strcat (sql_str, " AND ");
      and = 1;
 
      strcat (sql_str, data [count + INDEX_N_NAME]);
      strcat (sql_str, " = ");
 
      if (! strncmp (data [count + INDEX_N_DATATYPE], "char", 4))
      {
        strcat (sql_str, "'");
        strcat (sql_str, value1);            
        strcat (sql_str, "'");
      }
      else
        strcat (sql_str, value1);
    }
    else if (! strcmp (data [count + INDEX_N_NAME], "n_username")) 
    {
      if (and) strcat (sql_str, " AND ");
      and = 1;

      strcat (sql_str, data [count + INDEX_N_NAME]);
      strcat (sql_str, " = ");

      if (! strncmp (data [count + INDEX_N_DATATYPE], "char", 4))
      {
        strcat (sql_str, "'");
        strcat (sql_str, user_name);            
        strcat (sql_str, "'");
      }
      else
        strcat (sql_str, user_name);
    }
    else if (! strcmp (data [count + INDEX_N_NAME], "n_pathname")) 
    {
      if (and) strcat (sql_str, " AND ");
      and = 1;

      strcat (sql_str, data [count + INDEX_N_NAME]);
      strcat (sql_str, " = ");

      if (! strncmp (data [count + INDEX_N_DATATYPE], "char", 4))
      {
        strcat (sql_str, "'");
        strcat (sql_str, path_name);            
        strcat (sql_str, "'");
      }
      else
        strcat (sql_str, path_name);
    }
    else if (! strcmp (data [count + INDEX_N_NAME], "n_devicetype")) 
    {
      if (and) strcat (sql_str, " AND ");
      and = 1;

      strcat (sql_str, data [count + INDEX_N_NAME]);
      strcat (sql_str, " = ");

      if (! strncmp (data [count + INDEX_N_DATATYPE], "char", 4))
      {
        strcat (sql_str, "'");
        strcat (sql_str, "HD");            
        strcat (sql_str, "'");
      }
      else
        strcat (sql_str, "HD");
    }
  }

  status = NFMget_attr_value (user_id, "NFMSTORAGEAREA",
            data [(attr_list -> columns * i) + INDEX_N_NAME], sql_str, value);
  if ((status != NFM_S_SUCCESS) && (status != NFM_I_BAD_CONDITION))
  {
    free (sql_str);
    MEMclose (&attr_list);
    MEMclose (&data_list);
    _NFM_num ("_NFMadd_temp_sa: Get Attr Value : status = <0x%.8x>\n", status);
    return (status);
  }

  if (status == NFM_I_BAD_CONDITION)
  {
    for (x = 0; x < attr_list -> rows; ++x)
    {
      count = attr_list -> columns * x;

      if (! strcmp (data [count + INDEX_N_NAME], "n_nodeno"))
      {
        sprintf (value, "%d", node_no);

        status = MEMwrite_data (data_list, value, 1, x + 1);
        if (status != MEM_S_SUCCESS)
        {
          free (sql_str);
          MEMclose (&attr_list);
          MEMclose (&data_list);
          status = ERRload_struct (NFM, NFM_E_MEM, NULL);
          _NFM_num ("_NFMadd_temp_sa: MEM Wr Data : status = <0x%.8x>\n",
          NFM_E_MEM);
          return (NFM_E_MEM);
        }
      }
      else if (! strcmp (data [count + INDEX_N_NAME], "n_username"))
      {
        status = MEMwrite_data (data_list, user_name, 1, x + 1);
        if (status != MEM_S_SUCCESS)
        {
          free (sql_str);
          MEMclose (&attr_list);
          MEMclose (&data_list);
          status = ERRload_struct (NFM, NFM_E_MEM, NULL);
          _NFM_num ("_NFMadd_temp_sa: MEM Wr Data : status = <0x%.8x>\n",
          NFM_E_MEM);
          return (NFM_E_MEM);
        }
        strcpy (STO_info.username, user_name);
      }
      else if (! strcmp (data [count + INDEX_N_NAME], "n_pathname"))
      {
        status = MEMwrite_data (data_list, path_name, 1, x + 1);
        if (status != MEM_S_SUCCESS)
        {
          free (sql_str);
          MEMclose (&attr_list);
          MEMclose (&data_list);
          status = ERRload_struct (NFM, NFM_E_MEM, NULL);
          _NFM_num ("_NFMadd_temp_sa: MEM Wr Data : status = <0x%.8x>\n",
          NFM_E_MEM);
          return (NFM_E_MEM);
        }
        strcpy (STO_info.pathname, path_name);
      }
      else if (! strcmp (data [count + INDEX_N_NAME], 
                 "n_devicetype"))
      {
        status = MEMwrite_data (data_list, "HD", 1, x + 1);
        if (status != MEM_S_SUCCESS)
        {
          free (sql_str);
          MEMclose (&attr_list);
          MEMclose (&data_list);
          status = ERRload_struct (NFM, NFM_E_MEM, NULL);
          _NFM_num ("_NFMadd_temp_sa: MEM Wr Data : status = <0x%.8x>\n",
                   NFM_E_MEM);
          return (NFM_E_MEM);
        }
        strcpy (STO_info.devicetype, "HD");
      }
      else if (! strcmp (data [count + INDEX_N_NAME], "n_type"))
      {
        status = MEMwrite_data (data_list, "T", 1, x + 1);
        if (status != MEM_S_SUCCESS)
        {
          free (sql_str);
          MEMclose (&attr_list);
          MEMclose (&data_list);
          status = ERRload_struct (NFM, NFM_E_MEM, NULL);
          _NFM_num ("_NFMadd_temp_sa: MEM Wr Data : status = <0x%.8x>\n",
                   NFM_E_MEM);
          return (NFM_E_MEM);
        }
      }
      else if (! strcmp (data [count + INDEX_N_NAME], "n_passwd"))
      {
        status = MEMwrite_data (data_list, passwd, 1, x + 1);
        if (status != MEM_S_SUCCESS)
        {
          free (sql_str);
          MEMclose (&attr_list);
          MEMclose (&data_list);
          status = ERRload_struct (NFM, NFM_E_MEM, NULL);
          _NFM_num ("_NFMadd_temp_sa: MEM Wr Data : status = <0x%.8x>\n",
                   NFM_E_MEM);
          return (NFM_E_MEM);
        }
      }

    }

    status = _NFMadd_storage_area (user_id, attr_list, data_list);
    if (status != NFM_S_SUCCESS)
    {
      free (sql_str);
      MEMclose (&attr_list);
      MEMclose (&data_list);
      _NFM_num ("_NFMadd_temp_sa: Add Node : status = <0x%.8x>\n", status);
      return (status);
    }

 /** Kummar find problem in this area. Data seeting incorrectally 10/18/1993**/

  status = MEMbuild_array (attr_list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&attr_list);
    MEMclose (&data_list);
    status = ERRload_struct (NFM, NFM_E_MEM, NULL);
    _NFM_num ("_NFMadd_temp_sa: MEM Build Array : status = <0x%.8x>\n",
    NFM_E_MEM);
    return (NFM_E_MEM);
  }
    data = (char **)attr_list -> data_ptr;

   /**************************************/
    status = NFMget_attr_value (user_id, "NFMSTORAGEAREA",
              data [(attr_list -> columns * i) + INDEX_N_NAME], sql_str, value);
    if (status != NFM_S_SUCCESS)
    {
      free (sql_str);
      MEMclose (&attr_list);
      MEMclose (&data_list);
      if (status == NFM_I_BAD_CONDITION) 
      {
        status = ERRload_struct (NFM, NFM_E_BAD_ST_AREA, "", NULL);
        _NFM_num ("_NFMadd_temp_sa: Bad Device : status = <0x%.8x>\n",
        NFM_E_BAD_ST_AREA);
        return (NFM_E_BAD_ST_AREA);
      }

      _NFM_num ("_NFMadd_temp_sa: Get Attr Value : status = <0x%.8x>\n",
      status);
      return (status);
    }
  }
  else
  {
    strcpy (STO_info.username, user_name);
    strcpy (STO_info.pathname, path_name);
    strcpy (STO_info.devicetype, "HD");
  }

  status = MEMclose (&attr_list);
  if (status != MEM_S_SUCCESS)
  {
    free (sql_str);
    MEMclose (&data_list);
    /* status = NFMerror (NFM_E_MEM); */
    status = ERRload_struct (NFM, NFM_E_MEM, NULL);
    _NFM_num ("_NFMadd_temp_sa: MEM Close : status = <0x%.8x>\n", NFM_E_MEM);
    return (NFM_E_MEM);
  }

  status = MEMclose (&data_list);
  if (status != MEM_S_SUCCESS)
  {
    free (sql_str);
    /* status = NFMerror (NFM_E_MEM); */
    ERRload_struct (NFM, NFM_E_MEM, NULL);
    _NFM_num ("_NFMadd_temp_sa: MEM Close : status = <0x%.8x>\n", NFM_E_MEM);
    return (NFM_E_MEM);
  }

  free (sql_str);

  
  STO_info.sano = atol (value);

  if (NFMmsg_ptr.debug_on)
  _NFM_num ("_NFMadd_temp_sa : exit SUCCESSFUL <0x%.8x>\n", NFM_S_SUCCESS);
  return (NFM_S_SUCCESS);
}

void _NFMprint_STO_info ()
{

  _NFM_num ("STO_info.sano = %d", STO_info.sano);
  _NFM_str ("STO_info.nodename = %s", STO_info.nodename);
  _NFM_str ("STO_info.username = %s", STO_info.username);
  _NFM_str ("STO_info.passwd = %s", STO_info.passwd);
  _NFM_str ("STO_info.pathname = %s", STO_info.pathname);
  _NFM_str ("STO_info.devicetype = %s", STO_info.devicetype);
  _NFM_str ("STO_info.machid = %s", STO_info.machid);
  _NFM_str ("STO_info.opsys = %s", STO_info.opsys);
  _NFM_str ("STO_info.tcpip = %s", STO_info.tcpip);
  _NFM_str ("STO_info.xns = %s", STO_info.xns);
  _NFM_str ("STO_info.decnet = %s", STO_info.decnet);
}
