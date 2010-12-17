/****************************************************************
Name:		nfslib.c

Purpose:	This file contains all of the necessary functions
	to interface with the PC NFS toolkit for communication.

Author: Joe Creel

Date: ?

Change History:
	03-22-90  jms	Cleaned up
**********************************************************************/
#include     <stdio.h>
#include     <sys/types.h>
#include     <sys/socket.h>
#include     <netinet/in.h>
#include     <netdb.h>
#include "dbcomm.h"
#include	"comm.h"

#ifdef TESTIT
#include "mbheap.h"
#else
#include <memcheck.h>
#endif


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
#define     SET_LENGTH    0x53544C4E  /*SeT_LeNgth */

/* Global variables for returning error codes */
int     errno1;       /* error code from nfs routines */
int     errcode;     /* error code from nfslib routines */

/****************************************************************************
        Name: mkclient
 Description: This function creates a socket through which all communications
	are done. Upon creation of the socket, a connection is made to the
	requested server.
****************************************************************************/
mkclient( device, address, cl_port, srv_port )
char     *device,*address;
int      cl_port;     /* client port address EOF if computer supplied port */
int      srv_port;    /* server port address EOF if computer supplied port */
{
int     fd,bd,cd,x,y;
int     dod0,dod1,dod2,dod3;
char    taddr[80],addr_array[16];
unsigned long conv_addr;
struct protoent *pn;
struct  sockaddr_in soc_adr;
unsigned short hld_port;

#ifdef DEBUG
  printf ("Entering mkclient routine: device %s address %s\n",device,address);
#endif

/* Create a socket */
if (strlen(device) > 0)		/* If a protocol is specified, use it */
{
     pn = (struct protoent *)getprotobyname(device);
     fd = socket(AF_INET,SOCK_STREAM,pn->p_proto);
}
else				/* Otherwise let the system choose */
     fd = socket(AF_INET,SOCK_STREAM,0);

if (fd < 0) return(NOT_OPEN);

x = y = 0;

/* Prepare to bind to the socket */
get_myipaddr(addr_array);
soc_adr.sin_family = AF_INET;
soc_adr.sin_addr.S_un.S_un_b.s_b1 = (unsigned char)addr_array[0];
soc_adr.sin_addr.S_un.S_un_b.s_b2 = (unsigned char)addr_array[1];
soc_adr.sin_addr.S_un.S_un_b.s_b3 = (unsigned char)addr_array[2];
soc_adr.sin_addr.S_un.S_un_b.s_b4 = (unsigned char)addr_array[3];
soc_adr.sin_port = (short)0;

/* Bind to the newly created socket */
bd = bind( fd, &soc_adr, sizeof( struct sockaddr_in ) );
if (bd < 0)
{
     close(fd);
     return(NOT_BIND);
}

/* Prepare to connect to the server */
sscanf(address,"%d\.%d\.%d\.%d",&dod3,&dod2,&dod1,&dod0);
soc_adr.sin_family = AF_INET;
soc_adr.sin_addr.S_un.S_un_b.s_b1 = (unsigned char)dod3;
soc_adr.sin_addr.S_un.S_un_b.s_b2 = (unsigned char)dod2;
soc_adr.sin_addr.S_un.S_un_b.s_b3 = (unsigned char)dod1;
soc_adr.sin_addr.S_un.S_un_b.s_b4 = (unsigned char)dod0;

hld_port = ( (srv_port & 0x00ff) << 8) | ( (srv_port &0xff00) >> 8);
soc_adr.sin_port = hld_port;

/* Establish the connection to the requested server */
cd = connect( fd, &soc_adr, sizeof( struct sockaddr_in ) );
if (cd < 0)
{
     close(fd);
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
     stat = recv( fd, &buf[x], (nfsbytes -x), flag );

     if (stat < 0) return(NOT_RCV);

     x += stat;
}

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
int     stat;

#ifdef DEBUG
  printf("Entering client_write routine: fd %d  count %d \n",fd,nfsbytes);
#endif

stat = send( fd, buf, nfsbytes, flag );

if (stat < 0) return(NOT_SND);

#ifdef DEBUG
  printf("Leaving client_write routine: stat %d %d \n",stat,errno1);
#endif

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

shutdown(fd,0);
/*close(fd); temporary fix */
return(0);
} /* End of client_stop() */

/****************************************************************************
        Name: client_init
 Description: This function calls mkclient() to establish a network connection
	with the requested server. Once a successful connection has been
	established, a SET_LENGTH command is sent to the server to let the
	server know the maximum message size that will be sent during
	the following dialog.
****************************************************************************/
client_init( client_id, device, address, length, cl_port, srv_port, mod )
long    client_id;
char    *device,*address;
unsigned int     length;	/* my message length */
int     cl_port;		/* client port number if required else EOF */
int     srv_port;		/* server port number if required else EOF */
int	mod;			/* SET_LENGTH command modifier */
{
struct  mail_msg mp;
int     x, stat, fd;

#ifdef DEBUG
  printf("Entering client_init routine: device %s length %d\n",device,length);
#endif

/* Establish connection to requested server */
fd = mkclient( device, address, cl_port, srv_port );

/* If successful, send SET_LENGTH command to server */
if (fd > 0)
{
     mp._from_id = client_id;     /* who sent it */
     mp._size = length;     /* my message size length */
     mp._cmd = SET_LENGTH;     /* set length command */
     mp._parms = mod;

     stat = client_write(fd,&mp,(sizeof(struct mail_msg)),0);
     stat = client_read(fd,&mp,sizeof(struct mail_msg),&x);

     if (stat < 0) return(stat);
}

#ifdef DEBUG
  printf("Leaving client_init routine: fd %d\n",fd);
#endif

return(fd);
} /* End of client_init() */
