/****************************************************************
Copyright (c) 1990 and 1991
Intergraph Corporation; All Rights Reserved
Including Application Programs, File Formats, and Visual Displays

Name:		tcp.c

Purpose:	This file contains networking calls associated
	with TCP/IP specific functionality.

Date: 06-29-89

Change History:
	09-13-89 jms	Cleaned up original code and re-wrote parts
			of library.
	09-13-89 jms	Changed XNS communication routines to be
			seperate instead of compile time switches so that all
			routines could be used by the server.
	01-09-90 jms	Modified listen() to allocate its own t_call
			structure do to a bug in t_alloc().
	04-19-90  jms	Added functions tcp_poll() & tcp_handle_event()
			To handle multiple simultaneous connections.
	12-04-90  jms	Modified client_init() to accept node name
			instead of XNS or TCP address. Also added functions
			get_xns() and get_tcp().
	12-07-90  jms	Modified accept_call() to handle additional connect
			indications coming in while attempting to accept.
	02-18-91  jms	Modified client_init to check for ERROR.
**********************************************************************/
#include     <tiuser.h>
#include     <stdio.h>
#include     <fcntl.h>
#include     <string.h>
#include     <netdb.h>
#include     <sys/socket.h>
#include     <sys/types.h>
#include     <sys/stream.h>
#include     <netinet/in.h>

#include     "net.h"

FILE *net_err=0;		/* Network Error file descriptor */

/****************************************************************************
        Name: tcp_mkserver
 Description: This function opens the device /dev/tidco to enable network
	communication via TCP/IP.
****************************************************************************/
tcp_mkserver( port )
int port;			/* Port number to bind to */
{
int fd;				/* Network file descriptor */
struct t_bind *bind;		/* Bind structure */
struct sockaddr_in *dod;	/* DOD address structure */

/* Open communication device */
if( ( fd = t_open( "/dev/tcp", O_RDWR, 0 ) ) < 0 )
     return( NOT_OPEN );

/* Allocate structure for bind */
if( !( bind = (struct t_bind *)t_alloc( fd, T_BIND, T_ALL ) ) )
{
  t_close( fd );
  return( NOT_ALLOC );
}

/* Load bind structure */
bind->qlen = MAX_CONN_IND;
bind->addr.len = sizeof( struct sockaddr_in );
dod = (struct sockaddr_in *)bind->addr.buf;
memset( dod, 0, sizeof( struct sockaddr_in ) );
dod->sin_family = AF_INET;
dod->sin_port = htons( port );

/* Bind to requested address */
if( t_bind( fd, bind, bind ) < 0 ) 
{
     t_error( "BIND" );
     t_free( bind, T_BIND );
     t_close( fd );
     return( NOT_BIND );
}

tcp_max = bind->qlen;

/* Cleanup and exit */
t_free( bind, T_BIND );
return( fd );
} /* end of tcp_mkserver() */

/****************************************************************************
        Name: mkclient
 Description: This function opens the device /dev/tidco to enable network
	communication via TCP/IP and then establishes communication with the
	server on the requested node.
****************************************************************************/
mkclient( node, port )
char *node;				/* Node name of server */
int port;				/* Server port number */
{
int fd;					/* Network file descriptor */
struct t_call *sndcall;			/* Connect structure */
struct sockaddr_in *dod;		/* DOD address structure */
struct t_discon *discon;		/* Disconnect structure */
int x, y, n[4];
char address[80];
char *addr;

/* Translate address */
 printf("Before get_tcp\n");
if( get_tcp( node, address ) )
  return( BAD_NODE_NAME );
 printf("After get_tcp\n");

/* Open communication device */
 printf("Before t_open\n");
if( ( fd = t_open( "/dev/tcp", O_RDWR, 0 ) ) < 0 )
 {
 printf("t_errno %d\n", t_errno);
   if(t_errno == TLOOK) 
      x = t_look(fd);
 printf("t_look %d\n", x);
  return( NOT_OPEN );
 }
 printf("After t_open\n");
 printf("t_errno %d\n", t_errno);

/* Bind to next available socket */
 printf("Before t_bind\n");
if( t_bind( fd, 0, 0 ) < 0 )
{
  t_close( fd );
  return( NOT_BIND );
}

 printf("After t_bind\n");
/* Allocate t_call structure for connect */
if( !( sndcall = (struct t_call *)t_alloc( fd, T_CALL, T_ADDR ) ) )
{
  t_close( fd );
  return( NOT_ALLOC );
}

/* Load address structure */
dod = (struct sockaddr_in *)sndcall->addr.buf;
memset( dod, 0, sizeof( struct sockaddr_in ) );
sscanf( address, "%d.%d.%d.%d", &n[0], &n[1], &n[2], &n[3] );
addr = (char *)&dod->sin_addr;
for( x = 0; x < 4; x++ ) addr[x] = n[x];
dod->sin_family = AF_INET;
dod->sin_port = htons( port );
sndcall->addr.len = sizeof( struct sockaddr_in );

/* Connect to server */
 printf("Before t_connect\n");
if( ( y = t_connect( fd, sndcall, 0 ) ) < 0 )
{
     x = t_look( fd );
     fprintf(net_err,"Bad status returned from t_connect  stat = %d  t_errno = %d errno = %d\n",y,t_errno,errno);
     fprintf(net_err,"t_look returned (HEX) %x", x);
     switch(x)
     {
          case   T_DISCONNECT:
                 discon = (struct t_discon *)t_alloc( fd, T_DIS, T_ALL );
                 t_rcvdis( fd, discon );
                 fprintf(net_err,"  disconnect reason %x\n", discon->reason);
                 t_free( discon, T_DIS );
                 break;

          default:
                 t_error( "CONNECT" );
                 fprintf(net_err,"\n");
                 break;
     }
     t_free( sndcall, T_CALL );
     t_close( fd );
     return( NOT_CONNECT );
}

/* Cleanup and exit */
t_free( sndcall, T_CALL );
return(fd);     /* valid file descriptor */
} /* End of mkclient() */

/****************************************************************************
        Name: get_tcp()
 Description: This function searches the heard directory to retrieve the
	Internet address of the requested node.
****************************************************************************/
get_tcp( node, address )
char *node;		/* Node name of requested node */
char *address;		/* Internet address of requested node */
{
struct hostent *host;
char *p, cnt;

/* Decide if address should be translated */
cnt = 0;
p = strchr( node, '.' );
while( p )
{
  cnt++;
  p = strchr( ++p, '.' );
}

if( cnt == 3 )
{
  strcpy( address, node );
  return( 0 );
}

host = gethostbyname( node );

if( host == 0 ) return( -1 );

sprintf( address, "%d.%d.%d.%d", (unsigned char)host->h_addr[0], (unsigned char)host->h_addr[1],
	(unsigned char)host->h_addr[2], (unsigned char)host->h_addr[3] );

return( 0 );
} /* End of get_tcp() */

/****************************************************************************
        Name: get_taddr
 Description: This function determines the internet address of a newly
	connected client.
****************************************************************************/
get_taddr( buf, serv )
char     *buf;
struct   sockaddr_in *serv;
{
int     dod3,dod2,dod1,dod0;
unsigned char *addr;

addr = (unsigned char *)&serv->sin_addr;
dod3 = addr[0];
dod2 = addr[1];
dod1 = addr[2];
dod0 = addr[3];

sprintf( buf, "%d.%d.%d.%d", dod3, dod2, dod1, dod0 );

return(0);
} /* end of get_taddr() */
