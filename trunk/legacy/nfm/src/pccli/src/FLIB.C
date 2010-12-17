/****************************************************************
Name:		flib.c

Purpose:	This file contains all of the necessary functions
	to interface with the FTP networking library.

Author: Jeff Silvaggi

Date: 08-29-90

Change History:
**********************************************************************/
#include     <stdio.h>
#include     <string.h>
#include     <ctype.h>
#include     <sys/types.h>
#include     <netdb.h>
#ifdef PCTCP
#include     <pctcp/error.h>
#include     <pctcp/types.h>
#include     <pctcp/pctcp.h>
#endif
#include     "comm.h"
#include     "CLIstruct.h"
#include     "proto.h"
#include     <memcheck.h>

#define     NOADRBIND        EOF
#define     NOT_ALLOC        -2
#define     NOT_BIND         -3
#define     NOT_CONNECT      -4
#define     NOT_OPEN         -5
#define     NOT_LOOK         -6
#define     NOT_RCV          -7
#define     NOT_RCVREL       -8
#define     NOT_SND          -9
#define     NOT_SNDREL      -10
#define     NOT_CLOSE       -11
#define     NOT_LISTEN      -12
#define     NOT_ACCEPT      -13
#define     NOT_RCVDIS      -14
#define     NOT_SNDDIS      -15
#define     NOT_DISCONNECT  -16
#define     NO_PARAM        -17
#define     EXT_DATA          4
#define     NO_PROBLEM        0
#define     TOO_BIG         -18
#define		INIT_FAILED		-19
#define     SERVER_DISCONNECT -20
#define     BAD_NODE_NAME     -21
#define	VALIDATE_CLIENT		0xabcdef01

/* Global variables for returning error codes */
int     errno;			/* error code from nfs routines */
int     errcode;		/* error code from nfslib routines */
int client_bytes_to_recv=0;	/* Number of bytes to be received */

/****************************************************************************
        Name: mkclient
 Description: This function creates a socket through which all communications
	are done. Upon creation of the socket, a connection is made to the
	requested server.
****************************************************************************/

#ifdef PCTCP
mkclient( node, port )
char *node;			/* Server node name */
int port;			/* Server port number */
{
int fd;				/* Network file descriptor */
int dod0,dod1,dod2,dod3;
struct addr soc_adr;
unsigned short hld_port;
char address[80];
union
{
	struct { u_char	 s_b1, s_b2, s_b3, s_b4; }	S_un_b;
	struct { u_short s_w1, s_w2; }			S_un_w;
	u_long S_addr;
} S_un;

#ifdef DEBUG
  printf ("Entering mkclient routine: device %s address %s\n",device,address);
#endif

fd = get_tcp( node, address );
if( fd ) return( BAD_NODE_NAME );

/* Prepare to connect structure */
sscanf(address,"%d\.%d\.%d\.%d",&dod3,&dod2,&dod1,&dod0);
S_un.S_un_b.s_b1 = (unsigned char)dod3;
S_un.S_un_b.s_b2 = (unsigned char)dod2;
S_un.S_un_b.s_b3 = (unsigned char)dod1;
S_un.S_un_b.s_b4 = (unsigned char)dod0;

hld_port = ( (port & 0x00ff) << 8) | ( (port &0xff00) >> 8);

soc_adr.fhost = S_un.S_addr;
soc_adr.fsocket = port;
soc_adr.lsocket = 0;		/* Choose an unused local socket */
soc_adr.protocol = STREAM;

/* Create a socket and establish the connection to the requested server */
fd = net_connect( -1, STREAM, &soc_adr );
if(fd < 0)
{
     return(NOT_CONNECT);
}

#ifdef DEBUG
  printf("Leaving mkclient routine: fd %d\n",fd);
#endif

return(fd);
} /* End of mkclient() */

/****************************************************************************
        Name: client_read
 Description: This function receives the requested number of bytes from
	the network.
     Returns: < 0 - Error
	      > 0 - Number of bytes actually read
****************************************************************************/
client_read( fd, buf, nfsbytes, flag )
int     fd;          /* physical device */
char    *buf;        /* pointer to data buffer */
int     nfsbytes;    /* number of bytes to xfer */
int     *flag;       /* pointer to flags returned from t_rcv */
{
int     stat,x;
x = 0;

#ifdef DEBUG
  printf("Entering client_read routine: fd %d  nfsbytes %d\n",fd,nfsbytes);
#endif

while( x < nfsbytes )
{
     stat = net_read( fd, &buf[x], (nfsbytes -x), (struct addr *) NULL, 0 );

     if (stat < 0) return(NOT_RCV);

     x += stat;
}

if (stat < 0) return(NOT_RCV);

return(x);
} /* End of client_read() */

/****************************************************************************
        Name: client_write
 Description: This function sends the requested number of bytes accross
	the network.
     Returns: < 0 - Error
	      > 0 - Number of bytes actually read
****************************************************************************/
client_write( fd, buf, nfsbytes, flag )
int     fd;          /* physical device */
char    *buf;        /* pointer to data buffer */
int     nfsbytes;    /* number of bytes to xfer */
int     flag;        /* flags to notify receiver normally 0 */
{
int     stat, x;

#ifdef DEBUG
  printf("Entering client_write routine: fd %d  count %d \n",fd,nfsbytes);
#endif

x = 0;
while( x < nfsbytes )
{
     stat = net_write( fd, &buf[x], (nfsbytes -x), 0 );

     if (stat < 0) return(NOT_RCV);

     x += stat;
}


#ifdef DEBUG
  printf("After send: stat %d errno %d \n",stat,errno);
#endif

if (stat < 0) return(NOT_SND);

return(stat);
} /* End of client_write() */

/****************************************************************************
        Name: client_stop
 Description: This function sends a shutdown request to the server and closes
	the network connection.
****************************************************************************/
client_stop( fd )
int     fd;		/* Network file descriptor */
{
#ifdef DEBUG
  printf("Entering client_stop routine: fd %d\n",fd);
#endif

net_release( fd );

return(0);
} /* End of client_stop() */

/****************************************************************************
        Name: client_init
 Description: This function calls mkclient() to establish a network connection
	with the requested server. Once a successful connection has been
	established, a VALIDATE_CLIENT command is sent to the server to let the
	server determine whether this client should be allowed to connect.
****************************************************************************/
client_init( node, port, client_id )
char *node;			/* Node name of server to connect to */
int port;			/* Server port number to connect to */
long client_id;			/* Client id used by DMANDS server */
{
struct  mail_msg mp;
int x, stat, fd;

/* Connect to the server */
fd = mkclient( node, port );
if( fd < 0 ) return( fd );

/* Exchange VALIDATE_CLIENT packets */
mp._from_id = client_id;
mp._size = 0;
mp._cmd = VALIDATE_CLIENT;
mp._parms = 0;

stat = client_write( fd, (char *)&mp, sizeof( struct mail_msg ), 0 );
if( stat < 0 ) return( stat );

stat = client_read( fd, (char *)&mp, sizeof( struct mail_msg ), &x );
if( stat < 0 ) return( stat );

if( mp._cmd == ERROR ) return( SERVER_DISCONNECT );

return( fd );
} /* End of client_init() */

#endif
/****************************************************************************
        Name: get_tcp()
 Description: This function searches the heard directory to retrieve the
	Internet address of the requested node.
****************************************************************************/
extern char CLIhostsfile[];

get_tcp( srv_node, address )
char *srv_node;		/* Node name of requested node */
char *address;		/* Internet address of requested node */
{
FILE *fp;
char *p, cnt;
char line[80], node[80];
long n,x;

/* Decide if address should be translated */
cnt = 0;
p = strchr( srv_node, '.' );
while( p )
{
  cnt++;
  p = strchr( ++p, '.' );
}

if( cnt == 3 )
{
  strcpy( address, srv_node );
  return( 0 );
}
/* Modified by DT to read a hosts file that resides somewhere other that
   the root directory. */

/* Search hosts file for net address */
fp = fopen( CLIhostsfile, "r");
if( fp == 0 ) return( -1 );

fgets( line, sizeof( line ), fp );

while( !feof( fp ) )
{
  sscanf( line, "%s %s\n", address, node );

  n = strlen( node );
  for( x=0; x < n; x++ ) node[ x ] = (char) tolower( (int) node[ x ] );

  if( strcmp( node, srv_node ) == 0 ) break;

  fgets( line, sizeof( line ), fp );
}

if( feof(fp) )
{
  fclose( fp );
  return( -1 );
}

fclose( fp );
return( 0 );
} /* End of get_tcp() */

/****************************************************************************
        Name: client_send
 Description: This function sends a buffer accross the network. If the buffer
	is larger than 32K, it will be sent in pieces.
****************************************************************************/
client_send( fd, buf, bytes )
int fd;			/* Network file descriptor */
char *buf;		/* Pointer to buffer of data */
long bytes;		/* Number of bytes to send */
{
int send, status;
long max;
mail_msg hdr;

/* Send header to tell the other end the total message size */
hdr._size = bytes;
send = sizeof( hdr );
status = client_write( fd, (char *)&hdr, send, 0 );
if( status != send ) return( status );

/* Send message in pieces */
max = 30000;
while( bytes )
{
  if( bytes > max )
  {
    send = (short) max;
    bytes -= max;
  }
  else
  {
    send = (short) bytes;
    bytes = 0;
  }

  status = client_write( fd, buf, send, 0 );
  if( status != send ) return( status );

  buf += send;
}

return(0);
} /* end of client_send() */

/****************************************************************************
        Name: client_recv_size
 Description: This function receives the header of a message buffer to
	determine it's size.
****************************************************************************/
client_recv_size( fd, size )
int fd;			/* Network file descriptor */
long *size;		/* Data size return field */
{
int flag, len, status;
mail_msg hdr;

/* Receive message header */
len = sizeof( hdr );
status = client_read( fd, (char *)&hdr, len, &flag );
if( status != len ) return( status );

/* Return data size */
*size = hdr._size;
client_bytes_to_recv = (short) hdr._size;
return(0);
} /* end of client_recv_size() */

/****************************************************************************
        Name: client_recv
 Description: This function receives a buffer accross the network. If the buffer
	is larger than 32K, it will be received in pieces.
****************************************************************************/
client_recv( fd, buf )
int fd;			/* Network file descriptor */
char *buf;		/* Pointer to buffer of data */
{
int recv, flag, status;
long max;

max = 30000;
while( client_bytes_to_recv )
{
  if( client_bytes_to_recv > (short) max )
  {
    recv = (short) max;
    client_bytes_to_recv -= max;
  }
  else
  {
    recv = client_bytes_to_recv;
    client_bytes_to_recv = 0;
  }

  status = client_read( fd, buf, recv, &flag );
  if( status != recv ) return( status );

  buf += recv;
}

return(0);
} /* end of client_recv() */
