/****************************************************************LIDATE

Copyright (c) 1990 and 1991
Intergraph Corporation; All Rights Reserved
Including Application Programs, File Formats, and Visual Displays

Name:		generic.c

Purpose:	This file contains generic TLI interface calls.

Author:	Jeff Silvaggi

Date: 08-12-91

Change History:

  5/94 - S. Ramesh - Extension implemented to run with 
			bsd interface viz. sockets

                     Define BSD43 as part of CFLAGS in the Makefile 
		     to run this new version.

**********************************************************************/
#include "machine.h"
#ifndef BSD43
#include     <tiuser.h>
#endif
#include     <stdio.h>
#include     <fcntl.h>

#ifdef HP
#include <netinet/in.h>
#endif

#include     "net.h"

#define NET_MAX 2000		/* Maximum message size */

extern FILE *net_err;		/* Network Error file descriptor */
int net_bytes_to_recv=0;	/* Number of bytes to be received */

typedef struct net_conlst	/* Linked list structure of open connections */
{
  int	fd;			/* Network file descriptor */
  int	newlib;			/* New library flag: 0=old 1=new */
  struct net_conlst *next;	/* Next entry */
} net_conlst;

net_conlst *net_first=0;

/****************************************************************************
        Name: net_addfd
 Description: This function adds a new open connection to the connection list.
****************************************************************************/
net_addfd( fd, newlib )
int fd;
int newlib;
{
net_conlst *ent;

ent = (net_conlst *)malloc( sizeof( net_conlst ) );
ent->fd = fd;
ent->newlib = newlib;
ent->next = net_first;
net_first = ent;
return( 0 );
} /* end of net_addfd() */

/****************************************************************************
        Name: net_newlib
 Description: This function searches the connection linked list for the
	network file descriptor. If a match if found, the newlib flag for this
	fd is returned to the calling function.
****************************************************************************/
net_newlib( fd )
int fd;
{
net_conlst *ent;

ent = net_first;
while( ent )
{
  if( ent->fd == fd ) return( ent->newlib );
  ent = ent->next;
}

return( 0 );
} /* end of net_newlib() */

/****************************************************************************
        Name: net_rmfd
 Description: This function removes a file descriptor from the connection
	linked list.
****************************************************************************/
net_rmfd( fd )
int fd;
{
net_conlst *ent, *prev;

prev = 0;
ent = net_first;
while( ent )
{
  if( ent->fd == fd )
  {
    if( prev )
      prev->next = ent->next;
    else
      net_first = ent->next;

    free( ent );
    return( 0 );
  }

  prev = ent;
  ent = ent->next;
}

return( 0 );
} /* end of net_rmfd() */

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

#ifdef DEBUG
  printf("net_write(): Entering to send %d bytes on %d (fd)\n", nbytes, ser_fd);
#endif

if( nbytes >= 0 )
{
#ifdef BSD43
  if( ( stat = send( ser_fd, buf, nbytes, flag ) ) < 0 )
  {
      perror("net_write(), SEND");
#else
  if( ( stat = t_snd( ser_fd, buf, nbytes, flag ) ) < 0 )
  {
    fprintf( net_err, "SEND ERROR NET_WRITE(): errno = %d  t_errno = %d\n", errno, t_errno);

    /* If an event occured, found out which one */
    if( t_errno == 9 )
    {
      stat = t_look( ser_fd );
      fprintf( net_err, "  t_look returned %d\n", stat );
    }
#endif
    return( NOT_SND );
  }

#ifdef DEBUG
  printf("net_write(): Leaving sent %d bytes on %d (fd)\n", nbytes, ser_fd);
#endif

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


#ifdef DEBUG
  printf("net_read(): Entering to read %d bytes on %d (fd)\n", nbytes, ser_fd);
#endif

while( x < nbytes )
{
#ifdef BSD43
  if( ( stat = recv( ser_fd, &buf[x],(nbytes -x),*flag ) ) < 0 )
  {
      perror("net_read, RECV");
#else
  if( ( stat = t_rcv( ser_fd,&buf[x],(nbytes -x),flag ) ) < 0 )
  {
    fprintf( net_err, "Receive ERROR NET_READ(): errno = %d  t_errno = %d\n", errno, t_errno);

    /* If an event occured, found out which one */
    if( t_errno == 9 )
    {
      stat = t_look( ser_fd );
      fprintf( net_err, "  t_look returned %d\n", stat );
    }
#endif
    return( NOT_RCV );
  }

  x += stat;
}


#ifdef DEBUG
  printf("net_read(): Leaving read %d bytes on %d (fd)\n", x, ser_fd);
#endif

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
int x=0, stat, fd = -1;
/* srinivas */
struct t_info *info;
int	retinfo;

#ifdef DEBUG
  printf("net_client(): Entering to become client of '%s'\n", node);
#endif

if( net_err == 0 ) net_err = stderr;

if( protocol[0] == 'T' || protocol[0] == 't' )
{
  port = atoi( socket );
  fd = mkclient( node, port );
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
mp._size = 1;
mp._cmd = VALIDATE_CLIENT; 
mp._parms = 0;

stat = net_write( fd, (char *)&mp, sizeof( struct mail_msg ), 0 );
if( stat < 0 ) return( stat );

stat = net_read( fd, (char *)&mp, sizeof( struct mail_msg ), &x );
if( stat < 0 ) return( stat );

/* srinivas */
info = (struct t_info *)t_alloc( fd, T_INFO, T_ALL );
retinfo =  t_getinfo(fd, info); /* srinivas */

/* If size has been set to 0xabcdef01, this is the new version of the server */
if( mp._size == 0xabcdef01 ) 
{
  net_addfd( fd, 1 );
  mp._cmd =  ntohl(mp._cmd) ;
}
else
{
  net_addfd( fd, 0 );
  mp._cmd = net_swap(mp._cmd) ;
}

if( mp._cmd == NET_REJECTED ) return( SERVER_DISCONNECT );


#ifdef DEBUG
  printf("net_client(): Leaving became client fd: %d \n", fd);
#endif
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
#ifdef BSD43
   close( fd );
#else
t_close( fd );
#endif
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

#ifdef DEBUG
  fprintf(net_err, "net_send(): Enetring to send %d bytes on fd %d\n", bytes, fd);
#endif

/* Send header to tell the other end the total message size */

if( net_newlib(fd) )
{
  hdr._size = htonl( bytes );
  hdr._cmd = htonl( cmd );
}
else
{
  hdr._size = net_swap( bytes );
  hdr._cmd = net_swap( cmd );
}

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


#ifdef DEBUG
  fprintf(net_err, "net_send(): Leaving sent %d bytes on fd %d\n", bytes, fd);
#endif

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
int flag=0, len, status;
mail_msg hdr;

#ifdef DEBUG
  printf("net_recv_size(): Entering to receive size on fd: %d\n", fd);
#endif

/* Receive message header */
len = sizeof( hdr );
status = net_read( fd, (char *)&hdr, len, &flag );
if( status != len ) return( status );

/* Return data size */
if( net_newlib(fd) )
  *size = ntohl( hdr._size );
else
  *size = net_swap( hdr._size );

net_bytes_to_recv = *size;

#ifdef DEBUG
  printf("net_recv_size(): Leaving received size %d\n", *size);
#endif

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
int flag=0, len, status;
mail_msg hdr;

#ifdef DEBUG
  printf("net_recv_cmd(): Entering to receive cmd on fd %d\n", fd);
#endif

/* Receive message header */
len = sizeof( hdr );
status = net_read( fd, (char *)&hdr, len, &flag );
if( status != len ) return( status );

/* Return data size */
if( net_newlib(fd) )
{
  *size = ntohl( hdr._size );
  *cmd = ntohl( hdr._cmd );
}
else
{
  *size = net_swap( hdr._size );
  *cmd = net_swap( hdr._cmd );
}

net_bytes_to_recv = *size;

#ifdef DEBUG
  printf("net_recv_cmd(): Leaving received cmd %d\n", *cmd);
#endif

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
int recv, flag=0, status;

#ifdef DEBUG
  printf("net_recv(): Entering to receive on fd: %d\n", fd);
#endif

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


#ifdef DEBUG
  printf("net_recv(): Leaving received %d bytes\n", recv);
#endif

return(0);
} /* end of net_recv() */

/****************************************************************************
        Name: net_swap
 Description: This function swaps bytes within a long.
****************************************************************************/
net_swap( in )
long in;
{
char *fr, *to;
long out;
#ifdef OS_INTELSOL
	return(in);  
#else
fr = (char *)&in;
to = (char *)&out;
to[0] = fr[3];
to[1] = fr[2];
to[2] = fr[1];
to[3] = fr[0];
return( out );
#endif

} /* end of net_swap() */

