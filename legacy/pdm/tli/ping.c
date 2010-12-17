/******************************************************************************

Doc:	ping

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source:	ping.c

Author:	Jeff Silvaggi

Date:	8-SEP-1991

SDM Number:

Description:	This function sends an ICMP ECHO REQUEST to the specified node.
	If the node responds, 0 is returned otherwise -1 is returned.

Examples:
	status = ping( node )

Return Status:
	 0 = Host responding
	-1 = Host unreachable

History:
******************************************************************************/
#include <stdio.h>
#include <fcntl.h>
#include <string.h>
#include <signal.h>
#include <tiuser.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/stream.h>
#include <sys/dlpi.h>
#include <sys/dlppa.h>
#include <sys/dod/inet.h>
#include <sys/dod/dod_ut.h>
#include <sys/dod/iph.h>
#include <sys/dod/icmp.h>
#include <sys/dod/ip.h>

ping( node )
char *node;				/* I - Node to ping */
{
int fd;					/* Streams file descriptor */
int pid, x, n[4], flags;
int host_responding;
char address[80];			/* Internet address of requested node */
struct t_bind *bind;			/* Bind structure */
struct t_unitdata *udata;		/* Unit data structure */
void ping_alarm();			/* Function for catching SIGALRM */
void (*old_sig)();			/* Old SIGALRM signal handler */
struct icmp				/* ICMP message header structure */
{
    unsigned char       type;
    unsigned char       code;
    unsigned short      cksum;
    unsigned short      id;
    unsigned short      sequence;
} *icp;

pid = getpid() & 0xFFFF;

/* Translate destination address */
if( get_tcp( node, address ) )
  return( -1 );

/* Open communication device */
if( ( fd = t_open( "/dev/ip", O_RDWR, 0 ) ) < 0 )
  return(-1);

/* Allocate structure for bind */
if( !( bind = (struct t_bind *)t_alloc( fd, T_BIND, T_ALL ) ) )
{
  t_close( fd );
  return(-1);
}

bind->addr.len = IP_PROTO_SZ;
*(int *) bind->addr.buf = IP_ICMP_PROTO;
bind->qlen = 0;

/* Bind to ICMP protocol */
if( t_bind( fd, bind, bind ) < 0 ) 
{
  t_free( bind, T_BIND );
  t_close( fd );
  return(-1);
}

/* Free bind structure */
t_free( bind, T_BIND );

/* Allocate unit data structure */
if( !( udata = (struct t_unitdata *)t_alloc( fd, T_UNITDATA, T_ALL ) ) )
{
  t_close( fd );
  return(-1);
}

/* Load address */
sscanf( address, "%d.%d.%d.%d", &n[0], &n[1], &n[2], &n[3] );
for( x = 0; x < 4; x++ ) udata->addr.buf[x] = n[x];
udata->addr.len = 4;

/* Load ICMP echo request structure */
icp = (struct icmp *)udata->udata.buf;
icp->type = ICMP_ECHOREQ;
icp->code = 0;
icp->cksum = 0;
icp->sequence = 0;
icp->id = pid;
udata->udata.len = sizeof( struct icmp );
icp->cksum = in_cksum( (ushort *)icp, sizeof(struct icmp) );

/* Send ICMP echo request */
if( t_sndudata( fd, udata ) < 0 )
{
  t_free( udata, T_UNITDATA );
  t_close( fd );
  return(-1);
}

/* Set alarm */
old_sig = signal( SIGALRM, ping_alarm );
alarm(5);

/* Wait for echo response */
host_responding = 0;
while( 1 )
{
  /* Receive the ICMP request */
  if( t_rcvudata( fd, udata, &flags ) < 0 )
    break;

  /* Break if this was our response */
  if (icp->id == pid)
  {
    host_responding = 1;
    break;
  }
}

/* Reset alarm */
alarm(0);
signal( SIGALRM, old_sig );

/* Clean up */
t_free( udata, T_UNITDATA );
t_close( fd );

if( host_responding )
  return(0);
else
  return(-1);
} /* End of ping() */

/****************************************************************************
        Name: ping_alarm
 Description: This function is called if the ICMP ECHO reply has not been
	received after timeout period.
****************************************************************************/
void ping_alarm()
{
return;
}

/*
 *			I N _ C K S U M
 *
 * Checksum routine for Internet Protocol family headers (C Version)
 *
 */
in_cksum(addr, len)
u_short            *addr;
int                 len;
{
    register int        nleft = len;
    register u_short   *w = addr;
    register u_short    answer;
    register int        sum = 0;

    /*
     *  Our algorithm is simple, using a 32 bit accumulator (sum),
     *  we add sequential 16 bit words to it, and at the end, fold
     *  back all the carry bits from the top 16 bits into the lower
     *  16 bits.
     */
    while (nleft > 1)
    {
	sum += *w++;
	nleft -= 2;
    }

    /* mop up an odd byte, if necessary */
    if (nleft == 1)
	sum += *(u_char *) w;

    /*
     * add back carry outs from top 16 bits to low 16 bits
     */
    sum = (sum >> 16) + (sum & 0xffff);/* add hi 16 to low 16 */
    sum += (sum >> 16);		       /* add carry */
    answer = ~sum;		       /* truncate to 16 bits */
    return (answer);
}				       /* in_cksum */
