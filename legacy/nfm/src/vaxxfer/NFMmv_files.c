#include "machine.h"
#define  INCLUDE_EXTERN 1

#include "NFMf_xferinc.h"
#include "NFMattr_def.h"

long _NFMmv_files_out (user_id, sa_no, passwd, list)
long    user_id;
long    sa_no;    
char    *passwd;
MEMptr  *list;
{
char *fname="NFMmv_files_out ";
  /***
  CHANGE HISTORY:
    01/31/91 MFB this function is modified version of the NFMmove_files_out
                 to improve the performance.
  ***/

  long     status;
  MEMptr   sa_list = NULL, sa1_list = NULL, trans_list = NULL;
  char     **column, **data;
  long     protocol;
  char     encr_passwd [50];
  long     NFMfmu_ftp_get_files_out ();

  _NFMdebug ((fname,"_NFMmv_files_out: SA   No = <%d>  ", sa_no  ));
  _NFMdebug ((fname,"_NFMmv_files_out: Passwd  = <%s>\n", passwd ));

  status = _NFMsa_buffer (&sa_list);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&sa_list);
    _NFMdebug ((fname,"_NFMmv_files_out: SA Buff Info : status = <0x%.8x>\n",
    status));
    return (status);        
  }

  status = MEMappend (*list, sa_list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&sa_list);
    status = ERRload_struct (NFM, NFM_E_MEM, "", NULL); 
    _NFMdebug ((fname,"_NFMmv_files_out: MEM Append : status = <0x%.8x>\n", NFM_E_MEM));
    return (NFM_E_MEM);             
  }

  status = MEMbuild_array (sa_list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&sa_list);
    status = ERRload_struct (NFM, NFM_E_MEM, "", NULL); 
    _NFMdebug ((fname,"_NFMmv_files_out: MEM Build Array : status = <0x%.8x>\n",
    NFM_E_MEM));
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
      ERRload_struct (NFM, NFM_E_NET, "", NULL); 
      _NFMdebug ((fname,"_NFMmv_files_out: NFM Encrypt : status = <0x%.8x>\n",
      NFM_E_NET));
      return (NFM_E_NET);
    }

    status = MEMwrite_data (sa_list, encr_passwd, 1, INDEX_N_PASSWD + 1);
    if (status != MEM_S_SUCCESS)
    {
      MEMclose (&sa_list);
      ERRload_struct (NFM, NFM_E_MEM, "", NULL); 
      _NFMdebug ((fname,"_NFMmv_files_out: MEM Wr Data : status = <0x%.8x>\n",
      NFM_E_MEM));
      return (NFM_E_MEM);
    }
  }

  if (! strcmp (data [INDEX_N_TCPIP], "Y")) protocol = NET_TCP;
  else if (! strcmp (data [INDEX_N_XNS], "Y")) protocol = NET_XNS;
  else                               protocol = NULL;

/* Added comparision with UNIX for SUN port - SSRS - 7/12/93 */
  if ((! strcmp (data [INDEX_N_MACHID], "CLIX")) ||
       (!strcmp (data [INDEX_N_MACHID], "UNIX")))
  {
    status = NFMcl_get_files_out (data [INDEX_N_NODENAME], 
                                  data [INDEX_N_USERNAME], 
                                  data [INDEX_N_PASSWD],
             protocol, sa_list, &trans_list);
    if (status != NFM_S_SUCCESS)
    {
      MEMclose (&sa_list);
      MEMclose (&trans_list);
      _NFMdebug ((fname,"_NFMmv_files_out: Get Files Out : status = <0x%.8x>\n",
      status));
      return (status);             
    }
  }
  else    if((! strcmp (data [INDEX_N_MACHID], "VAX")) && (protocol == NET_XNS)) /* VAX - IGI */
  {
    status = NFMget_sa_no_buffer (user_id, 1, &sa1_list);
    if (status != NFM_S_SUCCESS)
    {
      MEMclose (&sa_list);
      MEMclose (&sa1_list);
      _NFMdebug ((fname,"_NFMmv_files_out: SA Buff Info : status = <0x%.8x>\n",
      status));
      return (status);        
    }
     
    status = NFMfmu_ftp_get_files_out (user_id, data [INDEX_N_NODENAME],
                 data [INDEX_N_USERNAME], data [INDEX_N_PASSWD],
                 sa_list, sa1_list, &trans_list,NET_FMU);
    if (status != NFM_S_SUCCESS)
    {
      MEMclose (&sa_list);
      MEMclose (&sa1_list);
      MEMclose (&trans_list);
      _NFMdebug ((fname,"_NFMmv_files_out: Get Files Out : status = <0x%.8x>\n",
      status));
      return (status);             
    }

    status = MEMclose (&sa1_list);
    if (status != MEM_S_SUCCESS)
    {
      MEMclose (&sa_list);
      MEMclose (&trans_list);
      status = ERRload_struct (NFM, NFM_E_MEM, "", NULL); 
      _NFMdebug ((fname,"_NFMmv_files_out: MEM Close : status = <0x%.8x>\n",
      NFM_E_MEM));
      return (NFM_E_MEM);             
    }
  }
  else
  {
    status = NFMget_sa_no_buffer (user_id, 1, &sa1_list);
    if (status != NFM_S_SUCCESS)
    {
      MEMclose (&sa_list);
      MEMclose (&sa1_list);
      _NFMdebug ((fname,"_NFMmv_files_out: SA Buff Info : status = <0x%.8x>\n",
      status));
      return (status);        
    }
     
    status = NFMfmu_ftp_get_files_out (user_id, data [INDEX_N_NODENAME],
                 data [INDEX_N_USERNAME], data [INDEX_N_PASSWD],
                 sa_list, sa1_list, &trans_list,NET_FTP);
    if (status != NFM_S_SUCCESS)
    {
      MEMclose (&sa_list);
      MEMclose (&sa1_list);
      MEMclose (&trans_list);
      _NFMdebug ((fname,"_NFMmv_files_out: Get Files Out : status = <0x%.8x>\n",
      status));
      return (status);             
    }

    status = MEMclose (&sa1_list);
    if (status != MEM_S_SUCCESS)
    {
      MEMclose (&sa_list);
      MEMclose (&trans_list);
      status = ERRload_struct (NFM, NFM_E_MEM, "", NULL); 
      _NFMdebug ((fname,"_NFMmv_files_out: MEM Close : status = <0x%.8x>\n",
      NFM_E_MEM));
      return (NFM_E_MEM);             
    }
  }

  status = MEMclose (&sa_list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&trans_list);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL); 
    _NFMdebug ((fname,"_NFMmv_files_out: MEM Close : status = <0x%.8x>\n", NFM_E_MEM));
    return (NFM_E_MEM);             
  }

  status = MEMbuild_array (trans_list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&trans_list);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL); 
    _NFMdebug ((fname,"_NFMmv_files_out: MEM Build Array : status = <0x%.8x>\n",
    NFM_E_MEM));
    return (NFM_E_MEM);             
  }

  if ((*list) -> rows != trans_list -> rows)
  {
    MEMclose (&trans_list);
    ERRload_struct (NFM, NFM_E_FILE_OUT_TRANSFER, "", NULL); 
    _NFMdebug ((fname,"_NFMmv_files_out: File Out Trans : status = <0x%.8x>\n",
    NFM_E_FILE_OUT_TRANSFER));
    return (NFM_E_FILE_OUT_TRANSFER);             
  }

  status = MEMclose (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&trans_list);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL); 
    _NFMdebug ((fname,"_NFMmv_files_out: MEM Close : status = <0x%.8x>\n", NFM_E_MEM));
    return (NFM_E_MEM);             
  }

  status = MEMsplit_copy_buffer (trans_list, list, 0);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&trans_list);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL); 
    _NFMdebug ((fname,"_NFMmv_files_out: MEM Copy : status = <0x%.8x>\n", NFM_E_MEM));
    return (NFM_E_MEM);     
  }

  status = MEMclose (&trans_list);
  if (status != MEM_S_SUCCESS)
  {
    ERRload_struct (NFM, NFM_E_MEM, "", NULL); 
    _NFMdebug ((fname,"_NFMmv_files_out: MEM Close : status = <0x%.8x>\n", NFM_E_MEM));
    return (NFM_E_MEM);     
  }


  _NFMdebug ((fname,"_NFMmv_files_out: SUCCESSFUL : status = <0x%.8x>\n",
  NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);     
}




long _NFMmv_files_in (user_id, sa_no, passwd, list)
long    user_id;
long    sa_no;
char    *passwd;
MEMptr  *list;
{
char *fname="NFMmv_files_in ";
  long     status;
  MEMptr   sa_list = NULL, trans_list = NULL, sa1_list = NULL;
  char     **column, **data;
  long     protocol;
  char     encr_passwd [50];
  long     NFMfmu_ftp_get_files_in ();

  _NFMdebug ((fname,"_NFMmv_files_in: enter ..."));
  _NFMdebug ((fname,"_NFMmv_files_in: SA   No = <%d>  ", sa_no  ));
  _NFMdebug ((fname,"_NFMmv_files_in: Passwd  = <%s>\n", passwd ));

  status = _NFMsa_buffer (&sa_list);

  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&sa_list);
    _NFMdebug ((fname,"_NFMmv_files_in: SA Buff Info : status = <0x%.8x>\n", status));
    return (status);        
  }

  status = MEMappend (*list, sa_list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&sa_list);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFMdebug ((fname,"_NFMmv_files_in: MEM Append : status = <0x%.8x>\n", NFM_E_MEM));
    return (NFM_E_MEM);             
  }

  status = MEMbuild_array (sa_list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&sa_list);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL); 
    _NFMdebug ((fname,"_NFMmv_files_in: MEM Build Array : status = <0x%.8x>\n",
    NFM_E_MEM));
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
      ERRload_struct (NFM, NFM_E_NET, "", NULL); 
      _NFMdebug ((fname,"_NFMmv_files_in: NFM Encrypt : status = <0x%.8x>\n",
      NFM_E_NET));
      return (NFM_E_NET);
    }

    status = MEMwrite_data (sa_list, encr_passwd, 1, INDEX_N_PASSWD + 1);
    if (status != MEM_S_SUCCESS)
    {
      MEMclose (&sa_list);
      ERRload_struct (NFM, NFM_E_MEM, "", NULL); 
      _NFMdebug ((fname,"_NFMmv_files_in: MEM Wr Data : status = <0x%.8x>\n",
      NFM_E_MEM));
      return (NFM_E_MEM);
    }
  }


  if (! strcmp (data [INDEX_N_TCPIP], "Y")) protocol = NET_TCP;
  else if (! strcmp (data [INDEX_N_XNS], "Y")) protocol = NET_XNS;
  else                               protocol = NULL;

/* Added comparision with UNIX for SUN port - SSRS - 7/12/93 */
  if ((! strcmp (data [INDEX_N_MACHID], "CLIX")) ||
       (!strcmp (data [INDEX_N_MACHID],  "UNIX")))
  {
    status = NFMcl_get_files_in (data [INDEX_N_NODENAME], 
                                 data [INDEX_N_USERNAME], 
                                 data [INDEX_N_PASSWD],
                 protocol, sa_list, &trans_list);
    if (status != NFM_S_SUCCESS)
    {
      MEMclose (&sa_list);
      MEMclose (&trans_list);
      _NFMdebug ((fname,"_NFMmv_files_in: Get Files In : status = <0x%.8x>\n",
      status));
      return (status);             
    }
  }
  else    if ((! strcmp (data [INDEX_N_MACHID], "VAX")) && (protocol == NET_XNS))/* VAX - IGI */
  {
    status = NFMget_sa_no_buffer (user_id, 1, &sa1_list);
    if (status != NFM_S_SUCCESS)
    {
      MEMclose (&sa_list);
      _NFMdebug ((fname,"_NFMmv_files_in: SA Buff Info : status = <0x%.8x>\n",
      status));
      return (status);        
    }

    status = NFMfmu_ftp_get_files_in (user_id, data [INDEX_N_NODENAME],
              data [INDEX_N_USERNAME], data [INDEX_N_PASSWD], 
              sa_list, sa1_list, &trans_list,NET_FMU);
    if (status != NFM_S_SUCCESS)
    {
      MEMclose (&sa_list);
      MEMclose (&trans_list);
      _NFMdebug ((fname,"_NFMmv_files_in: Get Files In : status = <0x%.8x>\n",
      status));
      return (status);             
    }

    status = MEMclose (&sa1_list);
    if (status != MEM_S_SUCCESS)
    {
      MEMclose (&sa_list);
      MEMclose (&trans_list);
      ERRload_struct (NFM, NFM_E_MEM, "", NULL); 
      _NFMdebug ((fname,"_NFMmv_files_in: MEM Close: <0x%.8x>\n", NFM_E_MEM));
      return (NFM_E_MEM);             
    }

  }
  else
  {
    status = NFMget_sa_no_buffer (user_id, 1, &sa1_list);
    if (status != NFM_S_SUCCESS)
    {
      MEMclose (&sa_list);
      _NFMdebug ((fname,"_NFMmv_files_in: SA Buff Info : status = <0x%.8x>\n",
      status));
      return (status);        
    }

    status = NFMfmu_ftp_get_files_in (user_id, data [INDEX_N_NODENAME],
              data [INDEX_N_USERNAME], data [INDEX_N_PASSWD], 
              sa_list, sa1_list, &trans_list,NET_FTP);
    if (status != NFM_S_SUCCESS)
    {
      MEMclose (&sa_list);
      MEMclose (&trans_list);
      _NFMdebug ((fname,"_NFMmv_files_in: Get Files In : status = <0x%.8x>\n",
      status));
      return (status);             
    }

    status = MEMclose (&sa1_list);
    if (status != MEM_S_SUCCESS)
    {
      MEMclose (&sa_list);
      MEMclose (&trans_list);
      ERRload_struct (NFM, NFM_E_MEM, "", NULL); 
      _NFMdebug ((fname,"_NFMmv_files_in: MEM Close: <0x%.8x>\n", NFM_E_MEM));
      return (NFM_E_MEM);             
    }
  }

  status = MEMclose (&sa_list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&trans_list);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL); 
    _NFMdebug ((fname,"_NFMmv_files_in: MEM Close: <0x%.8x>\n", NFM_E_MEM));
    return (NFM_E_MEM);             
  }

  status = MEMbuild_array (trans_list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&trans_list);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL); 
    _NFMdebug ((fname,"_NFMmv_files_in: MEM Build Array : status = <0x%.8x>\n",
    NFM_E_MEM));
    return (NFM_E_MEM);             
  }

  if ((*list) -> rows != trans_list -> rows)
  {
    MEMclose (&trans_list);
    ERRload_struct (NFM, NFM_E_FILE_IN_TRANSFER, "", NULL); 
    _NFMdebug ((fname,"_NFMmv_files_in: File In Trans : status = <0x%.8x>\n",
    NFM_E_FILE_IN_TRANSFER));
    return (status);             
  }

  status = MEMclose (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&trans_list);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL); 
    _NFMdebug ((fname,"_NFMmv_files_in: MEM Close : status = <0x%.8x>\n", NFM_E_MEM));
    return (NFM_E_MEM);             
  }

  status = MEMsplit_copy_buffer (trans_list, list, 0);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&trans_list);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL); 
    _NFMdebug ((fname,"_NFMmv_files_in: MEM Copy : status = <0x%.8x>\n", NFM_E_MEM));
    return (NFM_E_MEM);     
  }

  status = MEMclose (&trans_list);
  if (status != MEM_S_SUCCESS)
  {
    ERRload_struct (NFM, NFM_E_MEM, "", NULL); 
    _NFMdebug ((fname,"_NFMmv_files_in: MEM Close : status = <0x%.8x>\n", NFM_E_MEM));
    return (NFM_E_MEM);     
  }

  _NFMdebug ((fname,"_NFMmv_files_in: SUCCESSFUL : status = <0x%.8x>\n",
  NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);     
}

