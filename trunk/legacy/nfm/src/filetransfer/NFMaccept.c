
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

/* All the global variables that are defined in this library will be
   defined here. Do not define INCLUDE_EXTERN here */
#include "NFMf_xferinc.h"

NFMxfer_buf_status	xfer_buf_status;
NFMfilexfer_local_sa    filexfer_loc_sa;

long CLIENT_NETid = -1;

int NFMaccept (inpipe, outpipe, protocol)
  int        *inpipe;
  int        *outpipe;
  int        protocol;        /* NET_XNS, or NET_TCP, or NULL */
  {
     char *fname="NFMaccept ";
     int         status, status1;
     int         length;
     NFMbuffer_info buffer_info;
     FILE	*fp_stdout;

     _NFMdebug((fname,"Inpipe <%d> Outpipe <%d> Protocol <%d>\n",*inpipe,*outpipe,protocol));

     status = _NETaccept(inpipe);
     if (status  != NET_S_SUCCESS )
      { 
        _NFMdebug ((fname,"Failed to accept incoming tli connection on fd <%d>\
 status <0x%.8x>\n",*inpipe,status));
        return (NFM_E_TLI_ACCEPT);
      }
      CLIENT_NETid = *outpipe = *inpipe ;

     /* receive the username from the client. */

     length = sizeof (NFMbuffer_info);

/* KT - 1/5/92 - SUN Port */
     status = NFMrecv_info (NFMBUFFER_INFO, inpipe, (char *) &buffer_info, &length); 
     if (status != NET_S_SUCCESS)
      { 
        _NFMdebug ((fname," Failed to receive buffer after accept :status = <0x%.8x>\n", status));
	NFMsrv_fs_exit((long *)inpipe,(long *)outpipe);
        return (status);
      }
        
     status = NFMload_user_info (buffer_info.username);
     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname,"Load user info failed: status = <0x%.8x>\n", status));
      }

     strcpy (buffer_info.username, "");
     buffer_info.size    = 0; 
     buffer_info.request = status;

     length = sizeof (NFMbuffer_info);

/* KT - 1/5/92 - SUN Port */
     status1 = NFMsend_info (NFMBUFFER_INFO, outpipe, (char *) &buffer_info, &length); 
     if (status1 != NET_S_SUCCESS)
      {
        _NFMdebug ((fname,"NET buffer send failed after accept status = <0x%.8x>\n", status1));
	NFMsrv_fs_exit((long *)inpipe,(long *)outpipe);
        return (status1);
      }


     if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname,"NFMload_user_info : status = <0x%.8x>\n", status));
	NFMsrv_fs_exit((long *)inpipe,(long *)outpipe);
        return (status);
      }
     if((fp_stdout = freopen("/dev/null","w",stdout)) == (FILE *)0)
      {
           	status = NFM_E_FOPEN;
        	ERRload_struct(NFM,status,"%s%d%s","freopen stdout to /dev/null",errno,"r");
        	_NFMdebug((fname,"freopen failed for stdout: filename <%s> errno <%d> fopen type <%s> \
 status <0x%.8x>\n","/dev/null",errno,"r",status));
        	NFMsrv_fs_exit((long *)inpipe,(long *)outpipe);
		return(status);
      }

     _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
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
    char *fname="NFMconnect ";
    char    node[40];
    int     status,length;
    NFMbuffer_info buffer_info;
  	
/* KT - 1/5/92 - SUN Port */
/* If SUN, swap the server_number bytes for transfer */
/* MSSP - 29 Dec 93. Replaced sparc with OS_SUNOS || OS_SOLARIS */
/* HP PORT-IGI- 10 Jun 1994 */
/* IntelPort - Neelima 16.5.95 */
#if (defined OS_SUNOS || (defined(OS_SOLARIS) && !defined(OS_INTELSOL))|| \
    defined OS_HPUX)
    server_number = swapbytes (server_number);
#endif

    _NFMdebug((fname,"Node <%s> User <%s> Srv_no <%d> Port_no <%d>\n NETid <%d>\
protocol <%d>\n",nodename,user_name,server_number,port_number,*NETid,protocol));
	net_buf_status.status1 = net_buf_status.status2 = net_buf_status.status3= 0;
        status = _NETconnect(nodename,server_number, port_number, NETid, protocol);

	if(status != NET_S_SUCCESS)
	{
		_NFMdebug((fname,"Connect Failed node <%s> protocol <%d> server\
 number <%d> port number <%d> NETid <%d>\n",nodename,protocol,server_number,
port_number, *NETid));
		return(status);
	}
    /* send servers username to the server. */ 

    strcpy (buffer_info.username, user_name);
    buffer_info.size    = 0; 
    buffer_info.request = 0;

    length = sizeof (NFMbuffer_info);

/* KT - 1/5/92 - SUN Port */
    status = NFMsend_info (NFMBUFFER_INFO, NETid, (char *) &buffer_info, &length); 
    if (status != NET_S_SUCCESS)
     { 
       _NFMdebug ((fname, "Buffer send failed for client : status = <0x%.8x>\n", status));
       NETclose(NETid);
       return (status);
     }

    /* receive a reply from the server. */

    length = sizeof (NFMbuffer_info);

/* KT - 1/5/92 - SUN Port */
    status = NFMrecv_info (NFMBUFFER_INFO, NETid, (char *) &buffer_info, &length); 
    if (status != NET_S_SUCCESS)
     { 
       _NFMdebug ((fname, "Buffer receive failed for client : status = <0x%.8x>\n", status));
       NETclose(NETid);
       return (status);
     }

    /* get the status from buffer_info.request. */

    status = buffer_info.request;
    if (status != NFM_S_SUCCESS)
     {
       _NFMdebug ((fname, "Server Status in buffer_info : status = <0x%.8x>\n", status));
       ERRload_struct(NFM,status,"",NULL);
       NETclose(NETid);
       return (status);
     }

    _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }


int NFMdisconnect (NETid)
  int *NETid ;
  {
    char *fname="NFMdisconnect";
    int      status;
    int      length;
    NFMbuffer_info buffer_info;
    buffer_info.size = 0;
    buffer_info.request = EXIT;

    _NFMdebug ((fname,"Entry : NETid = <%d>\n", *NETid));
    if(*NETid < 0)
    {
       _NFMdebug ((fname,"Previous connection does not exist: NETid = <%d>\n", *NETid));
       return (NFM_S_SUCCESS);   
     }
    length = sizeof (NFMbuffer_info);

/* KT - 1/5/92 - SUN Port */
    status = NFMsend_info (NFMBUFFER_INFO, NETid, (char *) &buffer_info, &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug ((fname,"EXIT send failed: status = <0x%.8x>\n", status));
       NETclose(NETid);
       return (status);   
     }

    length = sizeof (NFMbuffer_info);

/* KT - 1/5/92 - SUN Port */
    status = NFMrecv_info (NFMBUFFER_INFO, NETid, (char *) &buffer_info,
             &length);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug ((fname,"EXIT receive failed: status = <0x%.8x>\n", status));
       NETclose(NETid);
       return (status);   
     }

    status = NETclose (NETid);
    if (status != NET_S_SUCCESS)
     {
       _NFMdebug ((fname,"NETclose failed: status = <0x%.8x>\n", status));
       return (status);   
     }

    status = buffer_info.request;
    if (status != NFM_S_SUCCESS)
     {
       _NFMdebug ((fname,"NFMdisconnect:Server : status = <0x%.8x>\n", status));
       ERRload_struct(NFM,NFM_E_FAILURE,"%s%x","NFMdisconnect:Server Status:",status);
       return (status);   
     }
  
    _NFMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }

