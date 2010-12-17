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

	5/94 - S. Ramesh 
			't_bind' not working for CLIX. Returns with error
			"Incorrect Address format".

			Corrected as described bellow :
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

			Address  structure "sockaddr_in" is replaced by 
			"dodaddr_t" structure in
			tcp_mkserver() -- for bind address in 't_bind()' call
			mkclient()     -- for destination address in
					 't_connect()' call
                        see 'tcp' on-line manual page for more details about
			address formats.
			 
			Need to define CLIX as part of Makefile CFLAGS
			for this change to take effect. 
	5/94 - S. Ramesh 
			Extension Implemented to run with bsd interface
			viz. sockets.

                        Define BSD43 as part of CFLAGS in the Makefile 
			to run this new version.

**********************************************************************/
#include     <sys/types.h>
#ifndef BSD43
#include     <tiuser.h>
#include     <sys/stream.h>
#endif
#include     <stdio.h>
#include     <fcntl.h>
#include     <string.h>
#include     <netdb.h>
#include     <sys/socket.h>
#include     <netinet/in.h>

#ifdef CLIX
#include     <sys/dod/inet.h>
#include     <sys/dod/dod_ut.h>
#endif

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

#ifndef BSD43

struct t_bind *bind;		/* Bind structure */

#ifdef CLIX
   dodaddr_t *dod;	/* DOD address structure */
#else
   struct sockaddr_in *dod;	/* DOD address structure */
#endif

#else
   struct sockaddr_in *dod;	/* DOD address structure */
#endif

#ifdef DEBUG
  printf("tcp_mkserver(): Entering port: %d\n", port);
#endif

/* Open communication device */
#ifdef BSD43
if( ( fd = socket( AF_INET, SOCK_STREAM, 0 ) ) < 0 )
#else
if( ( fd = t_open( "/dev/tcp", O_RDWR, 0 ) ) < 0 )
#endif
     return( NOT_OPEN );

#ifdef BSD43 

    if((dod = (struct sockaddr_in *) 
	malloc(sizeof(struct sockaddr_in))) == NULL)
    {
       close(fd);

#else

/* Allocate structure for bind */
if( !( bind = (struct t_bind *)t_alloc( fd, T_BIND, T_ALL ) ) )
{
  t_close( fd );
#endif
  return( NOT_ALLOC );
}

/* Load bind structure */

#ifndef BSD43

    bind->qlen = MAX_CONN_IND;

#ifdef CLIX
    bind->addr.len = sizeof( dodaddr_t );
    dod = (dodaddr_t *)bind->addr.buf;
#else
    bind->addr.len = sizeof( struct sockaddr_in );
    dod = (struct sockaddr_in *)bind->addr.buf;
#endif

#endif

#ifdef BSD43
    memset( dod, 0, sizeof( struct sockaddr_in ) );
    dod->sin_family = AF_INET;
    dod->sin_port = htons( port );
#else

#ifdef CLIX
    memset( dod, 0, sizeof( dodaddr_t ) );
    HOST16_TO_NET16( port, dod->port );
#else
    memset( dod, 0, sizeof( struct sockaddr_in ) );
    dod->sin_family = AF_INET;
    dod->sin_port = htons( port );
#endif

#endif

/* Bind to requested address */

#ifdef BSD43
   if( bind(fd, (struct sockaddr *) dod, sizeof(struct sockaddr_in)) < 0)
   {
       perror("tcp_mkserver(),BIND");
       free( dod );
       close ( fd );
#else
if( t_bind( fd, bind, bind ) < 0 ) 
{
     t_error( "BIND" );
     t_free( bind, T_BIND );
     t_close( fd );
#endif
     return( NOT_BIND );
}
#ifndef BSD43
tcp_max = bind->qlen;
#endif

/* Cleanup and exit */
#ifdef BSD43
    free( dod );
#else
t_free( bind, T_BIND );
#endif

#ifdef DEBUG
  printf("tcp_mkserver(): Made server fd: %d\n", fd);
#endif

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
char address[80];

#ifdef BSD43
   struct sockaddr_in *dod;		/* DOD address structure */
   struct sockaddr_in ouraddr;		/* our address structure */
#else

   struct t_call *sndcall;			/* Connect structure */
   struct t_discon *discon;		/* Disconnect structure */
   int x, y, n[4];
   char *addr;

#ifdef CLIX
   dodaddr_t *dod;
#else
   struct sockaddr_in *dod;		/* DOD address structure */
#endif

#endif

#ifdef DEBUG
  printf("mkclient(): Entering .. node: %s, port: %d\n", node, port);
#endif

/* Translate address */
if( get_tcp( node, address ) )
  return( BAD_NODE_NAME );

/* Open communication device */
#ifdef BSD43
if( ( fd = socket( AF_INET, SOCK_STREAM, 0 ) ) < 0 )
#else
if( ( fd = t_open( "/dev/tcp", O_RDWR, 0 ) ) < 0 )
#endif
  return( NOT_OPEN );


/* we dont care what our addrress is */
#ifdef BSD43
    bzero( (char *)&ouraddr, sizeof(struct sockaddr_in));
    ouraddr.sin_family	= AF_INET;
    ouraddr.sin_addr.s_addr = htonl(INADDR_ANY);
    ouraddr.sin_port	= htons(0);
    if( bind( fd, (struct sockaddr *)&ouraddr, 
	     sizeof(struct sockaddr_in) ) < 0 )
    {
      close( fd );
#else
/* Bind to next available socket */
if( t_bind( fd, 0, 0 ) < 0 )
{
  t_close( fd );
#endif
  return( NOT_BIND );
}

/* Allocate t_call structure for connect */
#ifdef BSD43
   if((dod = (struct sockaddr_in *)
	malloc(sizeof(struct sockaddr_in))) == NULL)
   { 
      close ( fd );
#else
if( !( sndcall = (struct t_call *)t_alloc( fd, T_CALL, T_ADDR ) ) )
{
  t_close( fd );
#endif
  return( NOT_ALLOC );
}

/* Load address structure */

#ifdef BSD43

   memset( dod, 0, sizeof( struct sockaddr_in ) );

#else

#ifdef CLIX
   sndcall->addr.len = sizeof( dodaddr_t );
   dod = (dodaddr_t *)sndcall->addr.buf;
   memset( dod, 0, sizeof( dodaddr_t ) );
#else
   sndcall->addr.len = sizeof( struct sockaddr_in );
   dod = (struct sockaddr_in *)sndcall->addr.buf;
   memset( dod, 0, sizeof( struct sockaddr_in ) );
#endif

#endif


#ifdef BSD43
   dod->sin_addr.s_addr = inet_addr ( address );
   dod->sin_family = AF_INET;
   dod->sin_port = htons( port );
#else

   sscanf( address, "%d.%d.%d.%d", &n[0], &n[1], &n[2], &n[3] );
#ifdef CLIX
   HOST16_TO_NET16 ( port, dod->port );
   dod->inet.uc[0] = n[0];
   dod->inet.uc[1] = n[1];
   dod->inet.uc[2] = n[2];
   dod->inet.uc[3] = n[3];
#else
   addr = (char *)&dod->sin_addr;
   for( x = 0; x < 4; x++ ) addr[x] = n[x];
   dod->sin_family = AF_INET;
   dod->sin_port = htons( port );
#endif
#endif


/* Connect to server */
#ifdef BSD43
if( connect ( fd, (struct sockaddr *)dod, 
		    sizeof(struct sockaddr_in)) < 0)
{
     perror("mkclient(),CONNECT");
     free(dod);
     close(fd);
#else

if( ( y = t_connect( fd, sndcall, 0 ) ) < 0 )
{
     x = t_look( fd );
     fprintf(net_err,"mkclient:Bad status returned from t_connect  stat = %d  t_errno = %d errno = %d\n",y,t_errno,errno);
     fprintf(net_err,"mkclient:t_look returned (HEX) 0x%.8x", x);
     switch(x)
     {
          case   T_DISCONNECT:
                 discon = (struct t_discon *)t_alloc( fd, T_DIS, T_ALL );
                 t_rcvdis( fd, discon );
                 fprintf(net_err,"mkclient:disconnect reason 0x%.8x\n", discon->reason);
                 t_free( discon, T_DIS );
                 break;

          default:
                 t_error( "CONNECT" );
                 fprintf(net_err,"\n");
                 break;
     }
     t_free( sndcall, T_CALL );
     t_close( fd );
#endif
     return( NOT_CONNECT );
}

/* Cleanup and exit */
#ifdef BSD43
   free(dod);
#else
t_free( sndcall, T_CALL );
#endif

#ifdef DEBUG
  printf("mkclient(): made client fd: %d\n", fd);
#endif

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

/* Decide if address should be translated */
if( isdigit( node[0] ) )
{
  strcpy( address, node );
  return( 0 );
}

host = gethostbyname( node );

if( host == 0 ) return( -1 );

#ifdef HP
sprintf( address, "%d.%d.%d.%d", (u_char)host->h_addr[0], (u_char)host->h_addr[1],
	(u_char)host->h_addr[2], (u_char)host->h_addr[3] );
#else
sprintf( address, "%d.%d.%d.%d", (unchar)host->h_addr[0], (unchar)host->h_addr[1],
	(unchar)host->h_addr[2], (unchar)host->h_addr[3] );
#endif
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

#ifdef HP
u_char *addr;
addr = (u_char *)&serv->sin_addr;
#else
unchar *addr;
addr = (unchar *)&serv->sin_addr;
#endif

dod3 = addr[0];
dod2 = addr[1];
dod1 = addr[2];
dod0 = addr[3];

sprintf( buf, "%d.%d.%d.%d", dod3, dod2, dod1, dod0 );

return(0);
} /* end of get_taddr() */
