// #include "NFMf_xferinc.h"

#include <stdio.h>
#include <stdlib.h>
#include <glib.h>

#include "ERR.h"
#include "DEBUG.h"
#include "MEM.h"

#include "NFMerrordef.h"
#include "NFMxferstrct.h"
#include "NFMxferextrn.h"
#include "NFMfto_buf.h"

#include "TFERproto.h"
#include "NETstruct.h"

static int tracex = 0;

/************************************************************************
*	_NFMfs_recv_files
*
*	This function is used by check out in which case the destination
*	for all the files is the same storage location
************************************************************************/

long _NFMfs_recv_files (MEMptr *buffer_ptr)
{
  char  *fname="_NFMfs_recv_files";
  long   status,protocol;
  char **data;

  if (tracex) g_message(">>> %s",fname);

  /* MEM build the buffer_ptr to access the data */
  status = MEMbuild_array (*buffer_ptr);
  g_return_val_if_fail(status == MEM_S_SUCCESS,NFM_E_MEM_BUILD_ARRAY_BUFFER);
  data   = (char **) (*buffer_ptr) -> data_ptr;

  /* Check to see if local sa is set otherwise set it */
  if(filexfer_loc_sa.local_sa_flag != NFM_S_SUCCESS)
  {
    status = NFMget_server_sa_info();
    g_return_val_if_fail(status == NFM_S_SUCCESS,status);
  }
  /* set the value of protocol for Server to Fileserver Connection */
  protocol = NET_TCP;

  /* Receive the files */
  /* This actually connects to the NFMfileserver process which in turn does the ftp stuff
   * Can I bypass it completely?
   *
  status = NFMs_dest_recv_clix(data [FTO_NODENAME], data [FTO_USERNAME], data [FTO_PASSWD], protocol, buffer_ptr);
  g_return_val_if_fail(status == NFM_S_SUCCESS,status);
*/
  status = NFMfs_dest_recv_clix ( buffer_ptr);
  g_return_val_if_fail(status == NFM_S_SUCCESS,status);

  return (NFM_S_SUCCESS);     
}

/************************************************************************
*									*
*			_NFMfs_send_files				*
*									*
*	This function is used by "check in" in which case the source    *
*	for all the files is the same storage location			*
************************************************************************/

long _NFMfs_send_files (MEMptr *buffer_ptr, long *NETid, long close_flag)
{
  char  *fname="_NFMfs_send_files";
  long   status,protocol;
  char **data;

  if (tracex) g_message(">>> %s",fname);

   *NETid = -1;

  /* MEM build the buffer_ptr to access the data */
  status = MEMbuild_array (*buffer_ptr);
  g_return_val_if_fail(status == MEM_S_SUCCESS,NFM_E_MEM_BUILD_ARRAY_BUFFER);
  data   = (char **) (*buffer_ptr) -> data_ptr;

  /* Check to see if local sa is set otherwise set it */
  if(filexfer_loc_sa.local_sa_flag != NFM_S_SUCCESS)
  {
	  status = NFMget_server_sa_info();
    g_return_val_if_fail(status == NFM_S_SUCCESS,status);
  }
  /* set the value of protocol for Server to Fileserver Connection */
  protocol = NET_TCP;

  /* And send it */
  status = NFMfs_src_send_clix ( buffer_ptr);
  g_return_val_if_fail(status == NFM_S_SUCCESS,status);

  return (NFM_S_SUCCESS);     
}
