/****************************************************************
Copyright (c) 1990 and 1991
Intergraph Corporation; All Rights Reserved
Including Application Programs, File Formats, and Visual Displays

Name:		server.c

Purpose:	This file contains the calls necessary to establish
	a transport endpoint and become a listener.

Author: Jeff Silvaggi

Date: 08-10-91

Change History:
  5/94 - S. Ramesh - Extension implemented to run with 
			bsd interface viz. sockets

                     Define BSD43 as part of CFLAGS in the Makefile 
		     to run this new version.

**********************************************************************/
#include <stdio.h>
#include <fcntl.h>
#include <signal.h>
#include <errno.h>

#ifdef BSD43
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#endif


#include "net.h"

int net_sockets;		/* Total sockets currently opened */
int net_client_id;		/* Connecting client id */

/* OV - IGI-320.
   May 09, 1997. t_errno definition is removed as its a global variable 
   of application scope it should be defined in application only.
   Modification pointed out and requested by PDM 
int t_errno; MVV */

#ifndef BSD43
#include <tiuser.h>

struct				/* Structure of server endpoints */
{
  int fd;			/* Transport endpoint file descriptor */
  int type;			/* Type: 0=XNS  1=TCP */
  char device[80];		/* Device used for communication */
} net_tbl[2];

int call_types[ MAX_CONN_IND ];

#endif

extern FILE *net_err;		/* Network Error file descriptor */

/****************************************************************************
        Name: net_server
 Description: This function creates server transport endpoints for XNS and
	TCP/IP.
****************************************************************************/
net_server( xns_socket, tcp_port )
char *xns_socket;
int tcp_port;
{
int fd;

#ifdef DEBUG
   printf("net_server(): tcp_port: %d\n", tcp_port);
#endif
/* Initialize */
net_sockets = 0;
if( net_err == 0 ) net_err = stderr;

#ifndef BSD43
memset( calls, 0x00, 4 * MAX_CONN_IND );	/* Initialize calls array */
#endif

/* Check if XNS should be used */
/*
if( xns_socket )
{
  fd = xns_mkserver( xns_socket );
  if( fd < 0 )
  {
    fprintf( net_err, "Error %d while starting XNS...errno = %d  t_errno = %d\n", fd, errno, t_errno );
*************************************************
* ADded the following 'return'  -- S. Ramesh 5/94 *
* No Error Reporting Implemented earlier if Failure occurs !!!	*
*************************************************

    return -1;
  }
  else
  {
#ifdef BSD43
    select_info[ net_sockets ].fd = fd;
#else
    poll_info[ net_sockets ].fd = fd;
    net_tbl[ net_sockets ].fd = fd;
    net_tbl[ net_sockets ].type = 0;
    strcpy( net_tbl[ net_sockets ].device, "/dev/tixco" );
#endif
    net_sockets++;
    fprintf( net_err, "XNS enabled\n" );
  }
}
*/

/* Check if TCP/IP should be used */
if( tcp_port )
{
  fd = tcp_mkserver( tcp_port );
  if( fd < 0 )
  {
    fprintf( net_err, "Error %d while starting TCP/IP...errno = %d  t_errno = %d\n", fd, errno, t_errno );
/*************************************************/
/* ADded the following 'return'  -- S. Ramesh 5/94 */
/* No Error Reporting Implemented till now if Failure occurs !!!	*/
/*************************************************/

    return -1;
  }
  else
  {
#ifdef BSD43
    select_info[ net_sockets ].fd = fd;
#else
    poll_info[ net_sockets ].fd = fd;
    net_tbl[ net_sockets ].fd = fd;
    net_tbl[ net_sockets ].type = 1;
    strcpy( net_tbl[ net_sockets ].device, "/dev/tcp" );
#endif
    net_sockets++;
    fprintf( net_err, "TCP/IP enabled\n" );
  }
}

return(net_sockets);
} /* end of net_server() */

/****************************************************************************
        Name: net_poll
 Description: This function polls all opened transport endpoints.
****************************************************************************/
net_poll( cmd_processor )
int (*cmd_processor)();
{
int x, ret;
extern void net_catch();

#ifdef BSD43
   int maxfdpl;
   fd_set readfds;
#endif

#ifdef DEBUG
  printf("net_poll(): Entering...\n");
#endif
/* Avoid parent death and zombie processes */
signal( SIGHUP, SIG_IGN );
signal( SIGCLD, net_catch );

while( 1 )
{

#ifdef BSD43
  FD_ZERO( &readfds );
  for( x = 0, maxfdpl = 0; x < net_sockets; x++ )
  {
    if(select_info[x].fd > maxfdpl) maxfdpl = select_info[x].fd;
    FD_SET( select_info[x].fd, &readfds);
    if(net_listen( select_info[x].fd ) < 0)
	return -1;
  }
  maxfdpl++;

#ifdef DEBUG
  printf("net_poll(): Polling %d sockets\n", maxfdpl);
#endif

  if( (select( maxfdpl, &readfds, NULL, NULL, NULL )) < 0 )
  {
    if( errno == EINTR ) continue;
    perror("net_poll(), SELECT");
    return( -1 );
  }
  for( x = 0; x < net_sockets; x++ )
  {
     if( FD_ISSET( select_info[x].fd, &readfds ) )
     {

#ifdef DEBUG
  printf("net_poll(): Poll success on %d socket\n", select_info[x].fd);
#endif
        ret = net_handle_event(x, cmd_processor);
        if( ret ) return( ret );
     }
  };
#else
  for( x = 0; x < net_sockets; x++ ) poll_info[x].events = POLLIN;

  if( (poll( poll_info, net_sockets, -1 )) < 0 )
  {
    if( errno == EINTR ) continue;
    fprintf( net_err, "Poll failed:  errno = %d  t_errno = %d\n", errno, t_errno );
    return( -1 );
  }

  for( x = 0; x < net_sockets; x++ )
  {
    switch( poll_info[x].revents )
    {
      case 0:
        continue;

      case POLLIN:
        ret = net_handle_event(x, cmd_processor);
        if( ret ) return( ret );
        break;

      default:
        fprintf( net_err, "poll() returned error event\n" );
        return( -1 );
    }
  }
#endif
} /* end of listen loop */

} /* end of net_poll() */

/****************************************************************************
        Name: net_handle_event()
 Description: This function processes events returned by poll.
****************************************************************************/
net_handle_event( idx, cmd_processor )
int idx;
int (*cmd_processor)();
{
int clnt_fd, fd;

#ifdef BSD43
   int			cli_len;
   struct sockaddr_in	client_addr;
   char			*address;
#else
struct t_discon *discon;
int x, ret;
char address[80];
#endif

#ifdef BSD43

   fd = select_info[ idx ].fd;

   cli_len  = sizeof(struct sockaddr_in);
   if( (clnt_fd = accept( fd, (struct sockaddr *) &client_addr,
				&cli_len)) < 0)
   {
      perror("net_handle_event(),ACCEPT");
      return ( -1 );
   }

#ifdef DEBUG
   printf("net_handle_event(): Accepted connection new sock %d\n", clnt_fd);
#endif
   address = inet_ntoa( client_addr.sin_addr);
   net_spawn_server( clnt_fd, address, cmd_processor );


#else

fd = poll_info[ idx ].fd;

switch( t_look( fd ) )
{
  case T_ERROR:
    fprintf( net_err, "t_look returned T_ERROR event\n");
    return( -1 );

  case -1:
    fprintf( net_err, "t_look() failed: errno = %d  t_errno = %d\n", errno, t_errno );
    return( -1 );

  case 0:
    fprintf( net_err, "t_look() returned no event\n" );
    return( -1 );

  case T_DISCONNECT:
    discon = (struct t_discon *)t_alloc( fd, T_DIS, T_ALL );

    if( (t_rcvdis( fd, discon )) < 0 )
    {
      fprintf( net_err, "t_rcvdis failed: errno = %d  t_errno = %d\n", errno, t_errno );
      return( -1 );
    }

    /* Find call indication in calls array and delete it */
    for( x = 0; x < MAX_CONN_IND; x++ )
    {
      if( calls[x] == 0 ) continue;
      if( discon->sequence == calls[ x ]->sequence )
      {
        t_free( calls[ x ], T_CALL );
        calls[ x ] = 0;
      }
    }
    t_free( discon, T_DIS );
    break;

  case T_LISTEN:
    /* Find free element in calls array */
    for( x = 0; x < MAX_CONN_IND && calls[ x ] != 0; x++ )
    if( x >= MAX_CONN_IND )
    {
      fprintf( net_err, "No available calls array entries\n");
      return( -1 );
    }

    ret = net_listen( fd );
    if( ret < 0 ) return( -1 );
    calls[ x ] = (struct t_call *)ret;
    call_types[x] = idx;

    for( x = 0; x < MAX_CONN_IND; x++ )
    {
      if( calls[ x ] == 0 ) continue;

      idx = call_types[ x ];
      clnt_fd = accept_call( net_tbl[ idx ].fd, net_tbl[ idx ].device, x );
  
      /* If outstanding asynchronous event, stop accepting and poll endpoint */
      if( (int)clnt_fd == EVENT_OCCURED ) break;
  
      /* If a connection was accepted, spawn a server process */
      if( (int)clnt_fd > 0 )
      {
/*
        if( net_tbl[ idx ].type == 0 )
          get_xaddr( address, calls[x]->addr.buf );
        else
*/
          get_taddr( address, calls[x]->addr.buf );
        net_spawn_server( clnt_fd, address, cmd_processor );
      }
  
      /* Release connect indication */
      t_free( calls[ x ], T_CALL );
      calls[ x ] = 0;
    }
    break;

} /* end switch */

#endif

return(0);
} /* end of net_handle_event() */

/****************************************************************************
        Name: net_spawn_server
 Description: This function forks a child process and calls the users
	command processor.
****************************************************************************/
net_spawn_server( fd, address, cmd_processor )
int fd;
char *address;
int (*cmd_processor)();
{
int pid, status, flag = 0;
mail_msg hdr;

pid = fork();
if( pid == -1 )
  return( -1 );

/* If parent free resources and return */
if( pid )
{
#ifdef BSD43
  close( fd );
#else
  t_close( fd );
#endif
  return( 0 );
}

#ifdef DEBUG
   printf("net_spawn_server(): Server spawned, trying to read VALIDATE CLIENT\n");
#endif
/* Receive VALIDATE_CLIENT message */
status = net_read( fd, &hdr, sizeof( hdr ), &flag );
if( status < 0 )
{
  fprintf(net_err, "Error %d during net_read of VALIDATE_CLIENT .. errno = %d  t_errno = %d\n", status, errno,t_errno);

#ifdef BSD43
  close( fd );
#else
  t_close( fd );
#endif
  exit(0);
}

/* If size is 0xabcdef01, this is the new version of the client */
if( hdr._size == 0xabcdef01 )
  net_addfd( fd, 1 );
else
  net_addfd( fd, 0 );

net_client_id = hdr._from_id;

/* Call command processor */
signal( SIGCLD, SIG_DFL );		/* Reset death of child signal */
(cmd_processor)( fd, address );

/* If command processor returns, exit */
net_stop( fd );
exit(0);
return(0);
} /* end of net_spawn_server() */

/****************************************************************************
        Name: net_accept
 Description: This function sends an ACCEPTED message to the client.
****************************************************************************/
net_accept( fd )
int fd;
{
int status;
mail_msg hdr;

#ifdef DEBUG
  printf("net_accept(): sending ACCEPTED packet on fd %d\n", fd);
#endif

/* Send ACCEPTED for VALIDATE_CLIENT message */
hdr._cmd = NET_ACCEPTED;
if( net_newlib(fd) )
{
  hdr._size = 0;
  hdr._cmd = htonl( hdr._cmd );
}
else
  hdr._cmd = net_swap( hdr._cmd );

status = net_write( fd, &hdr, sizeof( hdr ), 0 );
if( status < 0 )
{
  fprintf(net_err, "Error %d during net_write of VALIDATE_CLIENT .. errno = %d  t_errno = %d\n", status, errno,t_errno);
#ifdef BSD43
  close( fd );
#else
  t_close( fd );
#endif
  return( -1 );
}

return(0);
} /* end of net_accept() */

/****************************************************************************
        Name: net_reject
 Description: This function sends an ERROR message to the client indicating
	that the new connection has been rejected.
****************************************************************************/
net_reject( fd )
int fd;
{
int status;
mail_msg hdr;


#ifdef DEBUG
  printf("net_accept(): sending REJECTED packet on fd %d\n", fd);
#endif

/* Send REJECTED for VALIDATE_CLIENT message */
hdr._cmd = NET_REJECTED;
if( net_newlib(fd) )
{
  hdr._size = 0;
  hdr._cmd = htonl( hdr._cmd );
}
else
  hdr._cmd = net_swap( hdr._cmd );

status = net_write( fd, &hdr, sizeof( hdr ), 0 );
if( status < 0 )
{
  fprintf(net_err, "Error %d during net_write of VALIDATE_CLIENT .. errno = %d  t_errno = %d\n", status, errno,t_errno);
#ifdef BSD43
  close( fd );
#else
  t_close( fd );
#endif
  return( -1 );
}

return(0);
} /* end of net_reject() */

/****************************************************************************
        Name: net_stop_server
 Description: This function closes all server transport endpoints.
****************************************************************************/
net_stop_server()
{
int     x;

for( x = 0; x < net_sockets; x++ )
#ifdef BSD43
  close( select_info[x].fd );
#else
  t_close( net_tbl[x].fd );
#endif

net_sockets = 0;
return( 0 );
} /* end of net_stop_server() */

/****************************************************************************
        Name: net_listen
 Description: This function listens for network connect requests.
****************************************************************************/
net_listen(ser_fd)
int     ser_fd;
{
#ifdef BSD43
   int sts;
#else
struct t_call *ptr;
#endif

#ifdef BSD43
   if( (sts = listen(ser_fd, 5)) < 0)
   {
	perror("net_listen(), LISTEN");
	return (NOT_LISTEN);
   }
   return sts;
#else
if( ( ptr = (struct t_call *)t_alloc( ser_fd, T_CALL, T_ALL ) ) == NULL )
{
     fprintf( net_err, "NET_LISTEN: t_alloc  errno = %d  t_errno = %d\n", errno, t_errno );
     return(NOT_LISTEN);
}

if( t_listen( ser_fd, ptr ) < 0 )
{
     fprintf( net_err, "NET_LISTEN: t_listen  errno = %d  t_errno = %d\n", errno, t_errno );
     t_free( ptr, T_CALL );
     return( NOT_LISTEN );
}
else
     return( (int)ptr );
#endif

} /* end of net_listen() */

/****************************************************************************
        Name: accept_call
 Description: This function accepts the connect request from the client
	and opens communications.
****************************************************************************/
accept_call( ser_fd, device, call_idx )
int     ser_fd;
char    *device;
int	call_idx;
{
int     clnt_fd;
#ifdef BSD43
   struct sockaddr_in	client_addr;
   int			cli_len;
#else
struct t_call *call;
#endif

#ifdef BSD43

   cli_len = sizeof( struct sockaddr_in);
   if( (clnt_fd = accept( ser_fd, (struct sockaddr *) &client_addr,
				  &cli_len) ) < 0)
   {
      perror("accept_call(), ACCEPT");
#else

call = calls[ call_idx ];
call->opt.len = call->opt.maxlen = 0;
call->udata.len = call->udata.maxlen = 0;

if( ( clnt_fd = t_open( device, O_RDWR, NULL ) ) < 0 )
{
     fprintf(net_err,"ACCEPT: t_open errno = %d  t_errno = %d\n",errno,t_errno);
     return(NOT_OPEN);
}

if( t_bind( clnt_fd, NULL, NULL ) < 0 )
{
     fprintf(net_err,"ACCEPT: t_bind errno = %d  t_errno = %d\n",errno,t_errno);
     t_close( clnt_fd );
     return(NOT_BIND);
}

if( t_accept( ser_fd, clnt_fd, call ) < 0 ) 
{
     t_close( clnt_fd );

     /* If TLOOK, an asynchronous event has occured, otherwise ERROR */
     if( t_errno == TLOOK ) return( EVENT_OCCURED );

     /* If client has already been disconnected, ignore the error */
     if( t_errno == 7 ) return( NOT_ACCEPT );

     fprintf(net_err,"ACCEPT: t_accept errno = %d  t_errno = %d\n",errno,t_errno);
#endif
     return( NOT_ACCEPT );
}

return( clnt_fd );
} /* end of accept_call() */

void net_catch()
{
int stat;
extern void net_catch();

wait( &stat );
signal( SIGCLD, net_catch );
return;
}
