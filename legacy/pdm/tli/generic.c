/****************************************************************
Copyright (c) 1990 and 1991
Intergraph Corporation; All Rights Reserved
Including Application Programs, File Formats, and Visual Displays

Name:		generic.c

Purpose:	This file contains generic TLI interface calls.

Author:	Jeff Silvaggi

Date: 08-12-91

Change History:
**********************************************************************/
#include     <tiuser.h>
#include     <stdio.h>
#include     <fcntl.h>

#include     "net.h"

#define NET_MAX 2000		/* Maximum message size */

extern FILE *net_err;		/* Network Error file descriptor */
int net_bytes_to_recv=0;	/* Number of bytes to be received */

/****************************************************************************
        Name: net_write
 Description: This function sends the requested buffer accross the network
	to the client.
****************************************************************************/
net_write( ser_fd, buf, nbytes, flag )
int     ser_fd;     /* physical device */
char    *buf;       /* pointer to data buffer */
int     nbytes;     /* number of bytes to xfer */
int     flag;       /* flags to notify receiver normally 0 */
{
int     stat;
stat = 0;

if( nbytes >= 0 )
{
  if( ( stat = t_snd( ser_fd, buf, nbytes, flag ) ) < 0 )
  {
    fprintf( net_err, "SEND ERROR NET_WRITE(): errno = %d  t_errno = %d\n", errno, t_errno);

    /* If an event occured, found out which one */
    if( t_errno == 9 )
    {
      stat = t_look( ser_fd );
      fprintf( net_err, "  t_look returned %d\n", stat );
    }
    return( NOT_SND );
  }
}

return(stat);
} /* end of net_write() */

/****************************************************************************
        Name: net_read
 Description: This function receives a request buffer over the network from
	the client.
****************************************************************************/
net_read( ser_fd, buf, nbytes, flag )
int     ser_fd;     /* physical device */
char    *buf;       /* pointer to data buffer */
int     nbytes;     /* number of bytes to xfer */
int     *flag;      /* flags from server normally 0 */
{
int     stat;
int     x;
x = 0;

while( x < nbytes )
{
  if( ( stat = t_rcv( ser_fd,&buf[x],(nbytes -x),flag ) ) < 0 )
  {
    fprintf( net_err, "Receive ERROR NET_READ(): errno = %d  t_errno = %d\n", errno, t_errno);

    /* If an event occured, found out which one */
    if( t_errno == 9 )
    {
      stat = t_look( ser_fd );
      fprintf( net_err, "  t_look returned %d\n", stat );
    }
    return( NOT_RCV );
  }

  x += stat;
}

return(x);
} /* end of net_read() */

/****************************************************************************
        Name: net_client
 Description: This function calls the appropriate mkclient() function to
	establish a connection with the server on the requested node.
****************************************************************************/
net_client( node, socket, protocol, from_id )
char *node;			/* Node name of server to connect to */
char *socket;			/* Socket/port number to connect to */
char *protocol;			/* Type of protocol to use TCP or XNS */
long from_id;			/* Client id used by DMANDS server */
{
int port;			/* TCP/IP port number to connect to */
struct  mail_msg mp;
int x, stat, fd;

if( net_err == 0 ) net_err = stderr;

if( protocol[0] == 'T' || protocol[0] == 't' )
{
  printf("Going to make a mkclient connection\n");
  port = atoi( socket );
  fd = mkclient( node, port );
  printf("Made a mkclient connection\n");
  printf("fd %d\n", fd);
}
/*
else
{
  fd = xns_mkclient( node, socket );
}
*/

if( fd < 0 ) return( fd );

/* Exchange VALIDATE_CLIENT packets */
mp._from_id = from_id;
mp._size = 0;
mp._cmd = VALIDATE_CLIENT;
mp._parms = 0;

stat = net_write( fd, (char *)&mp, sizeof( struct mail_msg ), 0 );
if( stat < 0 ) return( stat );

stat = net_read( fd, (char *)&mp, sizeof( struct mail_msg ), &x );
if( stat < 0 ) return( stat );

if( mp._cmd == NET_REJECTED ) return( SERVER_DISCONNECT );

return( fd );
} /* End of net_client() */

/****************************************************************************
        Name: net_stop
 Description: This function sends a network disconnect request and closes
	network communication.
****************************************************************************/
net_stop( fd )
int fd;
{

t_close( fd );
return( 0 );
} /* end of net_stop() */

/****************************************************************************
        Name: net_send
 Description: This function sends a buffer accross the network. If the buffer
	is larger than 32K, it will be sent in pieces.
****************************************************************************/
net_send( fd, buf, bytes, cmd )
int fd;			/* Network file descriptor */
char *buf;		/* Pointer to buffer of data */
int bytes;		/* Number of bytes to send */
int cmd;		/* Command number */
{
int send, status;
mail_msg hdr;
char *fr, *to;

/* Send header to tell the other end the total message size */
hdr._size = htonl( bytes );
hdr._cmd = htonl( cmd );
send = sizeof( hdr );
status = net_write( fd, (char *)&hdr, send, 0 );
if( status != send ) return( status );

/* Send message in pieces */
while( bytes )
{
  if( bytes > NET_MAX )
  {
    send = NET_MAX;
    bytes -= NET_MAX;
  }
  else
  {
    send = bytes;
    bytes = 0;
  }

  status = net_write( fd, buf, send, 0 );
  if( status != send ) return( status );

  buf += send;
}

return(0);
} /* end of net_send() */

/****************************************************************************
        Name: net_recv_size
 Description: This function receives the header of a message buffer to
	determine it's size.
****************************************************************************/
net_recv_size( fd, size )
int fd;			/* Network file descriptor */
int *size;		/* Data size return field */
{
int flag, len, status;
mail_msg hdr;
long bytes;

/* Receive message header */
len = sizeof( hdr );
status = net_read( fd, (char *)&hdr, len, &flag );
if( status != len ) return( status );

/* Return data size */
bytes = ntohl( hdr._size );
*size = bytes;
net_bytes_to_recv = bytes;
return(0);
} /* end of net_recv_size() */

/****************************************************************************
        Name: net_recv_cmd
 Description: This function receives the header of a message buffer to
	determine it's size.
****************************************************************************/
net_recv_cmd( fd, size, cmd )
int fd;			/* Network file descriptor */
int *size;		/* Data size return field */
int *cmd;		/* Command number */
{
int flag, len, status;
mail_msg hdr;

/* Receive message header */
len = sizeof( hdr );
status = net_read( fd, (char *)&hdr, len, &flag );
if( status != len ) return( status );

/* Return data size */
*size = ntohl( hdr._size );
*cmd = ntohl( hdr._cmd );
net_bytes_to_recv = ntohl( hdr._size );
return(0);
} /* end of net_recv_cmd() */

/****************************************************************************
        Name: net_recv
 Description: This function receives a buffer accross the network. If the buffer
	is larger than 32K, it will be received in pieces.
****************************************************************************/
net_recv( fd, buf )
int fd;			/* Network file descriptor */
char *buf;		/* Pointer to buffer of data */
{
int recv, flag, status;

while( net_bytes_to_recv )
{
  if( net_bytes_to_recv > NET_MAX )
  {
    recv = NET_MAX;
    net_bytes_to_recv -= NET_MAX;
  }
  else
  {
    recv = net_bytes_to_recv;
    net_bytes_to_recv = 0;
  }

  status = net_read( fd, buf, recv, &flag );
  if( status != recv ) return( status );

  buf += recv;
}

return(0);
} /* end of net_recv() */
