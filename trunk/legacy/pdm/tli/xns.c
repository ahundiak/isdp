/****************************************************************
Copyright (c) 1990 and 1991
Intergraph Corporation; All Rights Reserved
Including Application Programs, File Formats, and Visual Displays

Name:		xns.c

Purpose:	This file contains networking calls associated
	with XNS specific functionality.

Date: 06-29-89

Change History:
	09-13-89  jms	Cleaned up original code and re-wrote parts
			of library.
	09-13-89  jms	Changed XNS communication routines to be
			seperate instead of compile time switches so that all
			routines could be used by the server.
	01-09-90  jms	Created a seperate xns_listen() function because
			of the changes that were made to TCP/IP listen().
	04-19-90  jms	Added functions xns_poll() & xns_handle_event()
			To handle multiple simultaneous connections.
	12-07-90  jms	Modified xns_mkclient() to re-try connect for 30 seconds.
	03-25-91  jms	Modified xns_mkclient() to not do a re-try if the server
			is not running or the requested machine is not up.
**********************************************************************/
#include     <stdio.h>
#include     <tiuser.h>
#include     <string.h>
#include     <signal.h>
#include     <fcntl.h>
#include     <sys/types.h>
#include     <sys/xns/led.h>
#include     <sys/xns/xns.h>
#include     "net.h"

extern FILE *net_err;
char srv_conn_timeout;		/* Connect timeout flag */

/****************************************************************************
        Name: xns_mkserver
 Description: This function opens the device /dev/tixco to enable network
	communication via XNS.
****************************************************************************/
xns_mkserver( socket )
char *socket;		/* Socket to bind to */
{
int fd;			/* Network file descriptor */
struct t_bind *bind;	/* Bind structure */
XNA *xaddr;		/* XNS address structure */

/* Open communiction device */
if( ( fd = t_open( "/dev/tixco", O_RDWR, 0 ) ) < 0 )
  return( NOT_OPEN );

/* Allocate bind structure */
if( !( bind = (struct t_bind *)t_alloc( fd, T_BIND, T_ALL ) ) )
{
  t_close( fd );
  return(NOT_ALLOC);
}

/* Load bind structure */
bind->qlen = MAX_CONN_IND;
bind->addr.len = sizeof( XNA );
xaddr = (XNA *)bind->addr.buf;
memset( xaddr, 0, sizeof( XNA ) );
xaddr->xna_socket[0] = atoh(socket[0],socket[1]);
xaddr->xna_socket[1] = atoh(socket[2],socket[3]);

/* Bind to requested address */
if( t_bind( fd, bind, bind ) < 0 ) 
{
  t_error( "BIND" );
  t_free( bind, T_BIND );
  t_close( fd );
  return( NOT_BIND );
}

xns_max = bind->qlen;

/* Cleanup and return */
t_free( bind, T_BIND );
return( fd );
} /* end of xns_mkserver() */

/****************************************************************************
        Name: xns_cvt_addr
 Description: This function reformats the netaddr for use by the network routines.
****************************************************************************/
xns_cvt_addr( buff, serv )
char     *buff;
XNA *serv;
{
int     i,j;
i = 0;
for(j=0;j<8;j+=2) 
     serv->xna_net[i++] = atoh(buff[j],buff[j+1]);
i=0;
for(j=8;j<20;j+=2) 
     serv->xna_host[i++] = atoh(buff[j],buff[j+1]);
i=0;
for(j=20;j<24;j+=2) 
     serv->xna_socket[i++] = atoh(buff[j],buff[j+1]);
} /* end of xns_cvt_addr() */

/****************************************************************************
        Name: atoh
 Description: This function takes two hex digits as input and returns the
	ASCII character that they represent.
****************************************************************************/
atoh(c1,c2)
char     c1,c2;
{
char     x;
x = 0;
if (c1 >= '0' & c1 <= '9') x = (c1 - '0') << 4;
if (c1 >= 'A' & c1 <= 'F') x = (c1 - '7') << 4;
if (c1 >= 'a' & c1 <= 'f') {
     c1 &= 0xDF;
     x = (c1 - '7')<< 4;
     }
if (c2 >= '0' & c2 <= '9') x |= (c2 - '0');
if (c2 >= 'A' & c2 <= 'F') x |= (c2 - '7');
if (c2 >= 'a' & c2 <= 'f') {
     c2 &= 0xDF;
     x |= (c2 - '7');
     }
return((char)x);
} /* end of atoh() */

/****************************************************************************
        Name: xns_mkclient
 Description: This function opens the device /dev/tixco to enable network
	communication via XNS and then establishes communication with the
	server on the requested node.
****************************************************************************/
xns_mkclient( node, socket )
char *node;			/* Node to connect to */
char *socket;			/* Socket to connect to */
{
int fd;				/* Network file descriptor */
struct t_call *sndcall;		/* Connect structure */
struct t_discon *discon;	/* Disconnect structure */
XNA *xaddr;			/* XNS address structure */
int x, y;
char taddr[80], timeout_seconds;
char *timeout;
void (*old_sig)();
void xns_catch_alarm();
char address[80];

if( get_xns( node, address ) )
  return( BAD_NODE_NAME );

/* Read TIMEOUT period, default to 15 if not set */
timeout = (char *)getenv( "TIMEOUT" );
if( timeout )
  timeout_seconds = atoi( timeout );
else
  timeout_seconds = 15;

x = y = 0;

/* Strip out all except numbers and characters */
while( y < strlen(address) )
{
     if( (address[y] >= '0' & address[y] <= '9') | (address[y] >= 'A') ) 
               taddr[x++] = address[y++];
     else 
          y++;
}

memcpy( &taddr[ x ], socket, 4 );	/* Append socket number to address */

/* Open device for communication */
if( ( fd = t_open( "/dev/tixco", O_RDWR, 0 ) ) < 0 )
  return( NOT_OPEN );

/* Bind to next available socket */
if( t_bind( fd, NULL, NULL ) < 0 )
{
  t_close( fd );
  return( NOT_BIND );
}

/* Allocate connect structure */
if( !( sndcall = (struct t_call *)t_alloc( fd, T_CALL, T_ADDR ) ) ) 
{
  t_close( fd );
  return( NOT_ALLOC );
}

/* Load connect structure */
sndcall->addr.len = sizeof( XNA );
xaddr = (XNA *)sndcall->addr.buf;
xns_cvt_addr( taddr, xaddr );		/* Load address into structure */

/* Setup to catch ALARM */
srv_conn_timeout = 0;
old_sig = signal( SIGALRM, xns_catch_alarm );

/* Attempt to connect to server for 30 seconds */
y = 15;
while( y-- )
{
  alarm( timeout_seconds );	/* Set connect timeout */

  /* Attempt to connect */
  if( ( t_connect( fd, sndcall, 0 ) ) == 0 )
  {
    alarm( 0 );		/* Cancel alarm */
    signal( SIGALRM, old_sig );
    t_free( sndcall, T_CALL );
    return( fd );     /* valid file descriptor */
  }

  alarm( 0 );		/* Cancel alarm */

  /* Return if HOST is not responding */
  if( srv_conn_timeout )
  {
    signal( SIGALRM, old_sig );
    t_free( sndcall, T_CALL );
    t_close( fd );
    return( MACHINE_DOWN );
  }
  
  x = t_look( fd );
  if( x != T_DISCONNECT ) break;

  discon = (struct t_discon *)t_alloc(fd,T_DIS,T_ALL);
  t_rcvdis(fd,discon);

  /* Return if server is not running */
  if( discon->reason == 2 )
  {
    signal( SIGALRM, old_sig );
    t_free( discon,T_DIS );
    t_free( sndcall, T_CALL );
    t_close( fd );
    return( NO_SERVER );
  }

  t_free(discon,T_DIS);
  sleep( 2 );
}
  
signal( SIGALRM, old_sig );

if( y )
{
  fprintf(net_err,"t_connect error:  t_errno = %d errno = %d\n", t_errno, errno);
  t_error("CONNECT");
  fprintf(net_err,"  t_look status (hex) %X\n",x);
}
else
{
  fprintf(net_err,"Unable to connect to server after 30 seconds\n");
  fprintf(net_err,"  t_errno = %d errno = %d\n", t_errno, errno);
  fprintf(net_err,"  t_look status (hex) %X\n",x);
}

/* Clean up and return */
t_free( sndcall, T_CALL );
t_close( fd );
return( NOT_CONNECT );
} /* End of xns_mkclient() */

/****************************************************************************
        Name: xns_catch_alarm
 Description: This function is called if it took longer than 30 seconds to 
	connect to the requested server.
****************************************************************************/
void xns_catch_alarm()
{
srv_conn_timeout = 1;
return;
}

/****************************************************************************
        Name: get_xaddr
 Description: This function determines the Ethernet address of a newly
	connected client.
****************************************************************************/
get_xaddr( address, serv )
char *address;
XNA *serv;
{

sprintf( address, "%.2x%.2x%.2x%.2x.%.2x-%.2x-%.2x-%.2x-%.2x-%.2x", serv->xna_net[0], serv->xna_net[1], serv->xna_net[2],
	serv->xna_net[3], serv->xna_host[0], serv->xna_host[1], serv->xna_host[2], serv->xna_host[3], serv->xna_host[4],
	serv->xna_host[5] );

return(0);
}

/****************************************************************************
        Name: get_xns()
 Description: This function searches the heard directory to retrieve the
	Ethernet address of the requested node.
****************************************************************************/
get_xns( node, address )
char *node;		/* Node name of requested node */
char *address;		/* Ethernet address of requested node */
{
char line[132], *ptr;
int x;

if( clh_vbyop( node, "Address", line, 80 ) )
  return(-1);

/* Convert LAN to 8 digits */
ptr = strchr( line, '.' );
sscanf( line, "%x.", &x);
sprintf( address, "%.8x.%s", x, ++ptr );

return( 0 );
} /* End of get_xns() */
