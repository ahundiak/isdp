
#include "NETnet_inc.h"

/* This is the structure used to pass the 3 statuses for loading into 
   file transfer buffers */

NETnet_buf_status	net_buf_status;

/* Jeff Silvaggi ( DMANDS ) Needs this variable to figure out where severe tli
   networking errors output should go. Currently opened to /dev/console */

extern FILE *net_err ;

/*************************************************************************
 *                                                                       *
 *     Module:    NETtools.c                                             *
 *     Date:      July 7, 1989                                           *
 *                                                                       *
 *     Includes:  TCP/IP and XNS support.                                *
 *     Modified:  December 4, 1989   B.W.                                * 
 *                Modifications made to make work like old NETtools.c    *
 *                                                                       *
 *************************************************************************/

int _NETconnect (nodename,  server_number, port_number, NETid, protocol)
  char *nodename;
  int   server_number;
  int   port_number;
  int  *NETid;
  int   protocol;        /* NET_XNS, or NET_TCP, or NULL */
{
  char *fname="_NETconnect ";
  char *c_status, ptcol[40],node[40];
  int   serverid=0,protocol_switch_flag;

  /* set the tli default output  to /dev/console */
  /* Open net_err ONLY if NOT Already Open */
  if(net_err == (FILE *)0)
  {
	  if((net_err = fopen("/dev/console","a")) == (FILE *)0) net_err = fopen("/dev/null","w") ;
   }

  /* server_number or port_number will be used as server_id */
  /* see if first 5 chars are nfms_
  */
	if(strncmp(nodename,"nfms_",5) == 0) 
	{
    g_critical("nfms_ node name '%s'",nodename);
#if 0
	  c_status = (char *) clh_vbyop (nodename, "Node", node, 40);
		if(c_status!=NULL)
		{
			ERRload_struct(NETC,NET_E_UNKNOWN_NODE,"");
			ERRload_struct(NETS,NET_E_UNKNOWN_NODE,"");
			_NETCdebug((fname,"Unknown node <%s>\n",nodename));
			_NETSdebug((fname,"Unknown node <%s>\n",nodename));
			fclose(net_err);
			return ( NET_E_UNKNOWN_NODE);
		}
#endif
	}
	else strcpy(node,nodename);  

  if(server_number > 0)      serverid = server_number ;
  else if (port_number > 0 ) serverid = port_number ; 
  else
	{
		net_buf_status.status2 = port_number;
		fclose(net_err);
		return(NET_E_TLI_BAD_PORT);
	}
  *NETid = net_client(node,TCP_SOCK,C_TCP,serverid);

	if(*NETid  < 0)
	{
    /* Load jeff_status in status2, and t_errno in status3 */
		net_buf_status.status2 = *NETid;
		net_buf_status.status3 = t_errno;
		fclose(net_err);

		return(NET_E_TLI_CONNECT);
	}

  return (NET_S_SUCCESS);
}

int NETclose (int *NETid)
{
  char *fname="NETclose";
  int     status;

  if (*NETid < 0 )
  {
	  return(NET_S_SUCCESS);
  }
  status = net_stop (*NETid);
  fclose(net_err);
  if(status < 0)
  {
    /* Load jeff_status in status2, and t_errno in status3 */
		net_buf_status.status2 = status;
		net_buf_status.status3 = t_errno;
    *NETid = -1 ;
    return (NET_E_TLI_CLOSE);
  }
  *NETid = -1 ;

  return (NET_S_SUCCESS);
}

int NETbuffer_send (NETid, buffer, len)
  int        *NETid;
  char       *buffer;
  int        *len;
  {
char *fname="NETbuffer_send";
     int        status;

     _NETCdebug ((fname,"Entry : NETid = <%d> Length = <%d>\n", *NETid,*len));
     _NETSdebug ((fname,"Entry : NETid = <%d> Length = <%d>\n", *NETid,*len));
/* Intel/Solaris Port - CN 16 May 95 */
#if (defined(OS_SUNOS) || (defined(OS_SOLARIS) && !defined(OS_INTELSOL)) || defined (__sgi) || \
	defined (OS_HPUX) )
/* fourth parameter was missing ??? MaC */
     status = net_send (*NETid, buffer, *len, 0);
#else
     status = net_send (*NETid, buffer, *len);
#endif
     if(status < 0)
      {
	ERRload_struct(NETC,NET_E_TLI_SEND,"%d%d%d%d",*NETid,*len,status,t_errno);
	ERRload_struct(NETS,NET_E_TLI_SEND,"%d%d%d%d",*NETid,*len,status,t_errno);
        _NETCdebug ((fname, "Failed to send message on tli fd <%d> size <%d>\
net_error <%d> t_errno <%d>\n ", *NETid,*len,status,t_errno))
        _NETCdebug ((fname, "Failed to send message on tli fd <%d> size <%d>\
net_error <%d> t_errno <%d>\n ", *NETid,*len,status,t_errno))
/* Load jeff_status in status2, and t_errno in status3 */
		net_buf_status.status2 = status;
		net_buf_status.status3 = t_errno;
        return (NET_E_TLI_SEND);
      }

     _NETCdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NET_S_SUCCESS));
     _NETSdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NET_S_SUCCESS));
     return (NET_S_SUCCESS);
  }

int NETbuffer_receive (NETid, buffer, len)
  int        *NETid;
  char       *buffer;
  int        *len;
  {
     char *fname="NETbuffer_receive";
     int        status;
     int size ;

     _NETCdebug ((fname,"NETid = <%d> Len = <%d>\n  ", *NETid,*len));
     _NETSdebug ((fname,"NETid = <%d> Len = <%d>\n  ", *NETid,*len));

     status = net_recv_size(*NETid , &size); 
     if (status < 0)
      {
	ERRload_struct(NETC,NET_E_TLI_RECEIVE_SIZE,"%d%d%d%d",*NETid,*len,status,t_errno);
	ERRload_struct(NETS,NET_E_TLI_RECEIVE_SIZE,"%d%d%d%d",*NETid,*len,status,t_errno);
        _NETCdebug ((fname, "Failed to receive message size on tli fd <%d> size <%d>\
net_error <%d> t_errno <%d>\n ", *NETid,*len,status,t_errno))
        _NETCdebug ((fname, "Failed to receive message size on tli fd <%d> size <%d>\
net_error <%d> t_errno <%d>\n ", *NETid,*len,status,t_errno))
/* Load jeff_status in status2, and t_errno in status3 */
		net_buf_status.status2 = status;
		net_buf_status.status3 = t_errno;
        return (NET_E_TLI_RECEIVE_SIZE);
      }
     *len = size ;
     status = net_recv(*NETid, buffer);
     if (status < 0 )
      {
	ERRload_struct(NETC,NET_E_TLI_RECEIVE,"%d%d%d%d",*NETid,*len,status,t_errno);
	ERRload_struct(NETS,NET_E_TLI_RECEIVE,"%d%d%d%d",*NETid,*len,status,t_errno);
        _NETCdebug ((fname, "Failed to receive message  on tli fd <%d> size <%d>\
net_error <%d> t_errno <%d>\n ", *NETid,*len,status,t_errno))
        _NETCdebug ((fname, "Failed to receive message  on tli fd <%d> size <%d>\
net_error <%d> t_errno <%d>\n ", *NETid,*len,status,t_errno))
/* Load jeff_status in status2, and t_errno in status3 */
		net_buf_status.status2 = status;
		net_buf_status.status3 = t_errno;
        return (NET_E_TLI_RECEIVE);
      }

     _NETCdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NET_S_SUCCESS));
     _NETSdebug ((fname, "SUCCESSFUL : status = <0x%.8x>\n", NET_S_SUCCESS));
     return (NET_S_SUCCESS);
  }


_NETaccept(fd)
	int *fd ;
{
	long status , pid ;
	char *fname="_NETaccept";
       _NETSdebug ((fname, "Entry : *fd = <%d>\n", *fd));
/* set the tli default output  to /dev/console */
/* Open net_err ONLY if NOT OPEN */
       if(net_err == (FILE *)0)
       {
        if((net_err = fopen("/dev/console","a")) == (FILE *)0)
                net_err = fopen("/dev/null","w") ;
       }
        
	if((pid=getpid()) < 0)
	{
		_NETSdebug((fname,"getpid failed: pid = <%d>\n",pid));
		ERRload_struct(NETS,NET_E_GETPID,"");
		fclose(net_err);
		return(NET_E_GETPID);
	}
	if((status=NETattach_shm()) != NET_S_SHM_SUCCESS)
	{
		if(status == NET_E_GET_SHM)
		{
			_NETSdebug((fname,"shmget call failed:errno <%d>:status\
 <0x%.8x>\n",errno,status));
		}
		else
		{
			_NETSdebug((fname,"shmat call failed:errno <%d>:status\
 <0x%.8x>\n",errno,status));
		}
		fclose(net_err);
		ERRload_struct(NETS,status,"%d",errno);
		return(status);
	}
	if((status=NETget_fd_from_shm(pid , fd )) != NET_S_SHM_SUCCESS)
	{
		_NETSdebug((fname,"Error accessing file descriptor in shared\
memory for pid <%d>:status <0x%.8x>\n",pid,status));
		ERRload_struct(NETS,status,"%d",pid);
		fclose(net_err);
		return(status);
	}
/* HP PORT - IGI - 16 Jun 94 */
#ifndef OS_HPUX
	if((status=t_sync(*fd)) < 0)
	{
		_NETSdebug((fname,"t_sync Failed for fd <%d>: pid <%d>:status\
 <0x%.8x> : t_errno <%d>\n",*fd,pid,status,t_errno));
		ERRload_struct(NETS,status,"%d%d%d",*fd,pid,t_errno);
/* Load jeff_status in status2, and t_errno in status3 */
		net_buf_status.status2 = status;
		net_buf_status.status3 = t_errno;
		fclose(net_err);
		return(NET_E_T_SYNC);
	}
#endif
	if((status=net_accept(*fd))< 0)
        {
		_NETSdebug((fname,"net_accept failed: fd <%d>:status <%d>:t_errno <%d>\
 status <0x%.8x>\n",*fd,status,t_errno,NET_E_TLI_ACCEPT));
		ERRload_struct(NETS,NET_E_TLI_ACCEPT,"%d%d%d",*fd,status,t_errno);
/* Load jeff_status in status2, and t_errno in status3 */
		net_buf_status.status2 = status;
		net_buf_status.status3 = t_errno;
		fclose(net_err);
		return(NET_E_TLI_ACCEPT);
	}
        _NETSdebug ((fname, "SUCCESSFUL :*fd = <%d>: status = <0x%.8x>\n",*fd, NET_S_SUCCESS));

	return(NET_S_SUCCESS);
}

