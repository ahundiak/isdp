#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <glib.h>

#include "ERR.h"
#include "DEBUG.h"
#include "MEM.h"

#include "NFMerrordef.h"
#include "NFMxferstrct.h"
#include "NFMxferextrn.h"
#include "NFMfto_buf.h"

#include "NFMsysstruct.h"
#include "SYSTproto.h"

#include "TFERproto.h"

#include "NETdef.h"
#include "NETproto.h"
#include "NETstruct.h"
#include "NETnetstruct.h"
#include "NETnetextern.h"

static int tracex = 1;

NFMxfer_buf_status	 xfer_buf_status;
NFMfilexfer_local_sa filexfer_loc_sa;

long CLIENT_NETid = -1;

#define  NFMBUFFER_INFO  1

int NFMaccept (
  int *inpipe,
  int *outpipe,
  int protocol /* NET_XNS, or NET_TCP, or NULL */
)
{
  char *fname="NFMaccept ";
  int         status, status1;
  int         length;
  NFMbuffer_info buffer_info;
  FILE       *fp_stdout;

  status = _NETaccept(inpipe);
  g_return_val_if_fail(status == NET_S_SUCCESS,NFM_E_TLI_ACCEPT);
  CLIENT_NETid = *outpipe = *inpipe ;

  /* receive the username from the client. */
  length = sizeof (NFMbuffer_info);

  status = NFMrecv_info (NFMBUFFER_INFO, inpipe, (char *) &buffer_info, &length); 
  if (status != NET_S_SUCCESS)
  { 
	  NFMsrv_fs_exit((long *)inpipe,(long *)outpipe);
    return (status);
  }
        
  status = NFMload_user_info (buffer_info.username);

  strcpy (buffer_info.username, "");
  buffer_info.size    = 0; 
  buffer_info.request = status;

  length = sizeof (NFMbuffer_info);

  status1 = NFMsend_info (NFMBUFFER_INFO, outpipe, (char *) &buffer_info, &length); 
  if (status1 != NET_S_SUCCESS)
  {
	  NFMsrv_fs_exit((long *)inpipe,(long *)outpipe);
    return (status1);
  }
  if (status != NFM_S_SUCCESS)
  {
	  NFMsrv_fs_exit((long *)inpipe,(long *)outpipe);
    return (status);
  }
  if((fp_stdout = freopen("/dev/null","w",stdout)) == (FILE *)0)
  {
    status = NFM_E_FOPEN;
    NFMsrv_fs_exit((long *)inpipe,(long *)outpipe);
		return(status);
  }
  return (NFM_S_SUCCESS);
}

int NFMconnect (nodename, user_name, passwd, 
                server_number, port_number,
                NETid, protocol)
  char  *nodename;
  char  *user_name;      /* decrypted user_name    */ 
  char  *passwd;         /* decrypted password     */
  int   server_number;
  int   port_number;
  int   *NETid;
  int   protocol;        /* NET_XNS, or NET_TCP, or NULL */
{
  char   *fname="NFMconnect ";
  char    node[40];
  int     status,length;
  NFMbuffer_info buffer_info;

  // No swapping
  // server_number = swapbytes (server_number);


	net_buf_status.status1 = net_buf_status.status2 = net_buf_status.status3= 0;
  status = _NETconnect(nodename,server_number, port_number, NETid, protocol);
  g_return_val_if_fail(status == NET_S_SUCCESS,status);

  /* send servers username to the server. */ 
  strcpy (buffer_info.username, user_name);
  buffer_info.size    = 0; 
  buffer_info.request = 0;

  length = sizeof (NFMbuffer_info);

  /* KT - 1/5/92 - SUN Port */
  status = NFMsend_info (NFMBUFFER_INFO, NETid, (char *) &buffer_info, &length); 
  g_return_val_if_fail(status == NET_S_SUCCESS,status);

  /* receive a reply from the server. */
  length = sizeof (NFMbuffer_info);

  /* KT - 1/5/92 - SUN Port */
  status = NFMrecv_info (NFMBUFFER_INFO, NETid, (char *) &buffer_info, &length); 
  g_return_val_if_fail(status == NET_S_SUCCESS,status);

  /* get the status from buffer_info.request. */
  status = buffer_info.request;
  g_return_val_if_fail(status == NFM_S_SUCCESS,status);

  return (NFM_S_SUCCESS);
}


int NFMdisconnect (int *NETid)
{
  char *fname="NFMdisconnect";
  int      status;
  int      length;
  NFMbuffer_info buffer_info;

  buffer_info.size = 0;
  buffer_info.request = EXIT;

  g_return_val_if_fail(!(*NETid < 0),NFM_S_SUCCESS);
  length = sizeof (NFMbuffer_info);

  /* KT - 1/5/92 - SUN Port */
  status = NFMsend_info (NFMBUFFER_INFO, NETid, (char *) &buffer_info, &length);
  if (status != NET_S_SUCCESS)
  {
    NETclose(NETid);
    return (status);   
  }
  length = sizeof (NFMbuffer_info);

  /* KT - 1/5/92 - SUN Port */
  status = NFMrecv_info (NFMBUFFER_INFO, NETid, (char *) &buffer_info, &length);
  if (status != NET_S_SUCCESS)
  {
    NETclose(NETid);
    return (status);   
  }
  status = NETclose (NETid);
  g_return_val_if_fail(status == NET_S_SUCCESS,status);

  status = buffer_info.request;
  g_return_val_if_fail(status == NFM_S_SUCCESS,status);

  return (NFM_S_SUCCESS);
}

