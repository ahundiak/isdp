#include "machine.h"
#define  INCLUDE_EXTERN 1

#include "NFMf_xferinc.h"


/************************************************************************
*									*
*			_NFMfs_recv_files				*
*									*
*	This function is used by check out in which case the destination*
*	for all the files is the same storage location			*
************************************************************************/

long _NFMfs_recv_files (buffer_ptr)

MEMptr  *buffer_ptr;
{
  char *fname="_NFMfs_recv_files";
  long     status,protocol;
  char     **data;

  _NFMdebug((fname,"Entry > MEMptr: *buffer_ptr = <%x>\n",*buffer_ptr));



/* MEM build the buffer_ptr to access the data */

  status = MEMbuild_array (*buffer_ptr);
  if (status != MEM_S_SUCCESS)
  {
    ERRload_struct (NFM, NFM_E_MEM_ERR,"%s%s%s%x", "MEMbuild_array for *buffer_ptr",fname,"status",status); 
    _NFMdebug((fname,"MEM operation failed: Operation <%s> for <%s> status <0x%.8x>\n","MEMbuild_array","*buffer_ptr",status));
/* Return NFM_E_FAILURE to indicate General failure: Do not look in buffer */
    return (NFM_E_MEM_BUILD_ARRAY_BUFFER);        
  }
/* Check to see if local sa is set otherwise set it */
  if(filexfer_loc_sa.local_sa_flag != NFM_S_SUCCESS)
  {
	status = NFMget_server_sa_info();
	if(status != NFM_S_SUCCESS)
	{
		_NFMdebug((fname,"Failed to set server information in local\
buffer. status : <0x%.8x>\n",status));
		ERRload_struct(NFM,NFM_I_LOAD_SERVER_NODE_INFO,"%x",status);
	}
  }


  data   = (char **) (*buffer_ptr) -> data_ptr;

/* set the value of protocol 
   for Server to Fileserver Connection */

  if (! strcmp (data [FTO_TCPIP], "Y") &&
      ! strcmp (filexfer_loc_sa.LOCAL_SA[FTO_TCPIP],"Y")) protocol = NET_TCP;
  else if (! strcmp (data [FTO_XNS], "Y") &&
           ! strcmp ( filexfer_loc_sa.LOCAL_SA[FTO_XNS], "Y")) protocol = NET_XNS;
  else      
  {
                         protocol = NULL;
     _NFMdebug((fname,"<WARNING> No match found for protocol between Server and\
file_server proceeding with NULL\n"));
  }



/* check if the destination location is a CLIX m/c */

  if ((! strcmp (data [FTO_OPSYS], "CLIX"))||(! strcmp (data [FTO_OPSYS], "UNIX")))
  {
    status = NFMs_dest_recv_clix(data [FTO_NODENAME], 
                                 data [FTO_USERNAME], 
				 data [FTO_PASSWD],
			         protocol, buffer_ptr);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname,"NFM File server destination receive clix : status = <0x%.8x>\n",
      status));
      return (status);             
    }
  }
  else
  {
/* Call function to receive files at a temporary location on server node 
   and transfer them to the destination node */
    status = NFMs_dest_recv_nonclix(data [FTO_NODENAME], 
                                   data [FTO_USERNAME], 
				   data [FTO_PASSWD],
			           protocol, buffer_ptr);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname,"NFM File server destination receive non clix : status = <0x%.8x>\n",
      status));
      return (status);             
    }

  }
  _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);     
}

/************************************************************************
*									*
*			_NFMfs_send_files				*
*									*
*	This function is used by "check in" in which case the source    *
*	for all the files is the same storage location			*
************************************************************************/

long _NFMfs_send_files (buffer_ptr, NETid,close_flag)

MEMptr  *buffer_ptr;
long *NETid,close_flag;
{
  char *fname="_NFMfs_send_files";
  long     status,protocol;
  char     **data;

  _NFMdebug((fname,"Entry > MEMptr: buffer = <%x>\n",*buffer_ptr));

/* Set NETid to -1 */

   *NETid = -1;

/* MEM build the buffer_ptr to access the data */

  status = MEMbuild_array (*buffer_ptr);
  if (status != MEM_S_SUCCESS)
  {
    ERRload_struct (NFM, NFM_E_MEM_ERR,"%s%s%s%x", "MEMbuild_array for *buffer_ptr",fname,"status",status); 
    _NFMdebug((fname,"MEM operation failed: Operation <%s> for <%s> status <0x%.8x>\n","MEMbuild_array","*buffer_ptr",status));
    return (NFM_E_SEVERE_ERROR);        
  }
/* Check to see if local sa is set otherwise set it */
  if(filexfer_loc_sa.local_sa_flag != NFM_S_SUCCESS)
  {
	status = NFMget_server_sa_info();
	if(status != NFM_S_SUCCESS)
	{
		_NFMdebug((fname,"Failed to set server information in local\
buffer. status : <0x%.8x>\n",status));
		ERRload_struct(NFM,NFM_I_LOAD_SERVER_NODE_INFO,"%x",status);
	}
  }


  data   = (char **) (*buffer_ptr) -> data_ptr;

/* set the value of protocol for check out destination location  */

  if (! strcmp (data [FTO_TCPIP], "Y") &&
      ! strcmp (filexfer_loc_sa.LOCAL_SA[FTO_TCPIP],"Y")) protocol = NET_TCP;
  else if (! strcmp (data [FTO_XNS], "Y") &&
           ! strcmp ( filexfer_loc_sa.LOCAL_SA[FTO_XNS], "Y")) protocol = NET_XNS;
  else      
  {
                         protocol = NULL;
     _NFMdebug((fname,"<WARNING> No match found for protocol between Server and\
file_server proceeding with NULL\n"));
  }

/* check if the destination location is a CLIX m/c */

  if ((! strcmp (data [FTO_OPSYS], "CLIX"))||(! strcmp (data [FTO_OPSYS], "UNIX")))
  {
    status = NFMs_src_send_clix(data [FTO_NODENAME], 
                                 data [FTO_USERNAME], 
				   data [FTO_PASSWD],
			         protocol, buffer_ptr,NETid,close_flag);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname,"NFM File server source send clix : status = <0x%.8x>\n",
      status));
      return (status);             
    }
  }
  else
  {
/* Call function to receive files at a temporary location on server node 
   and transfer them to the destination node */
    status = NFMs_src_send_nonclix(data [FTO_NODENAME], 
                                   data [FTO_USERNAME], 
				   data [FTO_PASSWD],
			           protocol, buffer_ptr);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname,"NFM File server source send non clix : status = <0x%.8x>\n",
      status));
      return (status);             
    }

  }

  _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);     

}
