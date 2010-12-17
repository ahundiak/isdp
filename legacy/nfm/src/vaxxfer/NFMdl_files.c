#include "machine.h"
#define  INCLUDE_EXTERN 1

#include "NFMf_xferinc.h"
#include "NFMattr_def.h"


long _NFMdel_in_files (user_id, sa_no, passwd, list)
long    user_id;
long    sa_no;
char    *passwd;
MEMptr  *list;
{
char *fname="NFMdel_in_files ";
  /***
  CHANGE HISTORY:
    01/31/91 MFB this function is modified version of the NFMdelete_in_files
                 to improve the performance.
  ***/

  long     status;
  MEMptr   sa_list = NULL, trans_list = NULL;
  char     **column, **data;
  long      protocol;
  char     encr_passwd [50];
  long     NFMftp_delete_files_co ();

  _NFMdebug ((fname,"_NFMdel_in_files: SA   No = <%d>  ", sa_no  ));
  _NFMdebug ((fname,"_NFMdel_in_files: Passwd  = <%s>\n", passwd ));

  /* get the check_in storage area information */

  status = _NFMsa_buffer (&sa_list);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&sa_list);
    _NFMdebug ((fname,"_NFMdel_in_files: _NFMci_sa_buffer <0x%.8x>\n", status));
    return (status);        
  }

  status = MEMappend (*list, sa_list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&sa_list);
    status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFMdebug ((fname,"_NFMdel_in_files: MEM Append <0x%.8x>\n", NFM_E_MEM));
    return (NFM_E_MEM);             
  }
 
  status = MEMbuild_array (sa_list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&sa_list);
    status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFMdebug ((fname,"_NFMdel_in_files: MEM Build Array  <0x%.8x>\n", NFM_E_MEM));
    return (NFM_E_MEM);        
  }
 
  column = (char **) sa_list -> column_ptr;
  data   = (char **) sa_list -> data_ptr;
 
  if (strlen (passwd))
  {
    status = NFMencrypt (passwd, encr_passwd);
    if (status != NFM_S_SUCCESS)
    {
      MEMclose (&sa_list);
      status = ERRload_struct (NFM, NFM_E_NET, "", NULL);
      _NFMdebug ((fname,"_NFMdel_in_files: NFM Encrypt <0x%.8x>\n", NFM_E_NET));
      return (NFM_E_NET);             
    }
 
    status = MEMwrite_data (sa_list, encr_passwd, 1, INDEX_N_PASSWD + 1);
    if (status != MEM_S_SUCCESS)
    {
      MEMclose (&sa_list);
      status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      _NFMdebug ((fname,"_NFMdel_in_files: MEM Wr Data  <0x%.8x>\n", NFM_E_MEM));
      return (NFM_E_MEM);             
    }
  }
 
  /*
  mb_time2 = times (&mb_tms2);
  mb_total = mb_time2 - mb_time1;

  if ( !_NFMdebug_st.NFMdebug_on)
  {
    _NFMdebug_st.NFMdebug_on = 1;
    strcpy (_NFMdebug_st.NFMdebug_file, "/usr2/nfmadmin/time_ci.new");
    _NFMdebug ((fname,"before delete files, mb_total = %d", mb_total));
    _NFMdebug ((fname,"utime = %d", mb_tms2.tms_utime - mb_tms1.tms_utime));
    _NFMdebug ((fname,"stime = %d", mb_tms2.tms_stime - mb_tms1.tms_stime));
    _NFMdebug_st.NFMdebug_on = 0;
  }
  */

  if (! strcmp (data [INDEX_N_TCPIP], "Y")) protocol = NET_TCP;
  else if (! strcmp (data [INDEX_N_XNS], "Y")) protocol = NET_XNS;
  else                               protocol = NULL;

/* Added comparision with UNIX for SUN - SSRS - 7/12/93 */
  if ((! strcmp (data [INDEX_N_MACHID], "CLIX")) || 
     (! strcmp (data [INDEX_N_MACHID],  "UNIX"))) 
  {
    status = NFMcl_delete_files_co (data [INDEX_N_NODENAME], 
                                    data [INDEX_N_USERNAME], 
                                    data [INDEX_N_PASSWD],
                                    protocol, sa_list, &trans_list);
    if (status != NFM_S_SUCCESS)
    {
      MEMclose (&sa_list);
      MEMclose (&trans_list);
      _NFMdebug ((fname,"_NFMdel_in_files: Del Co Files : <0x%.8x>\n", status));
      return (status);             
    }
  }
  else if ((! strcmp (data [INDEX_N_MACHID], "VAX")) && (protocol == NET_XNS)) /* VAX - IGI */
  {
    status = NFMfmu_delete_files (data [INDEX_N_NODENAME], 
                                     data [INDEX_N_USERNAME], 
                                     data [INDEX_N_PASSWD],
                                     sa_list, &trans_list,FMU_DEL_CO);
    if (status != NFM_S_SUCCESS)
    {
      MEMclose (&sa_list);
      MEMclose (&trans_list);
      _NFMdebug ((fname,"_NFMdel_in_files: Del Co Files : <0x%.8x>\n", status));
      return (status);             
    }
  }
  else
  {
    status = NFMftp_delete_files_co (data [INDEX_N_NODENAME], 
                                     data [INDEX_N_USERNAME], 
                                     data [INDEX_N_PASSWD],
                                     sa_list, &trans_list);
    if (status != NFM_S_SUCCESS)
    {
      MEMclose (&sa_list);
      MEMclose (&trans_list);
      _NFMdebug ((fname,"_NFMdel_in_files: Del Co Files : <0x%.8x>\n", status));
      return (status);             
    }
  }
 
  status = MEMclose (&sa_list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&trans_list);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFMdebug ((fname,"_NFMdel_in_files: MEM Close : <0x%.8x>\n", NFM_E_MEM));
    return (NFM_E_MEM);             
  }

  status = MEMbuild_array (trans_list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&trans_list);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFMdebug ((fname,"_NFMdel_in_files: MEM Build Array :  <0x%.8x>\n", NFM_E_MEM));
    return (NFM_E_MEM);             
  }

  if ((*list) -> rows != trans_list -> rows)
  {
    MEMclose (&trans_list);
    ERRload_struct (NFM, NFM_E_DELETE_FILE, "", NULL);
    _NFMdebug ((fname,"_NFMdel_in_files: File Out Trans :  <0x%.8x>\n", NFM_E_DELETE_FILE));
    return (NFM_E_DELETE_FILE);             
  }

  status = MEMclose (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&trans_list);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFMdebug ((fname,"_NFMdel_in_files: MEM Close :  <0x%.8x>\n", NFM_E_MEM));
    return (NFM_E_MEM);             
  }

  status = MEMsplit_copy_buffer (trans_list, list, 0);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&trans_list);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFMdebug ((fname,"_NFMdel_in_files: MEM Copy : <0x%.8x>\n", NFM_E_MEM));
    return (NFM_E_MEM);     
  }

  status = MEMclose (&trans_list);
  if (status != MEM_S_SUCCESS)
  {
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFMdebug ((fname,"_NFMdel_in_files: MEM Close : <0x%.8x>\n", NFM_E_MEM));
    return (NFM_E_MEM);     
  }


  _NFMdebug ((fname,"_NFMdel_in_files: exit SUCCESSFUL: <0x%.8x>\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}

