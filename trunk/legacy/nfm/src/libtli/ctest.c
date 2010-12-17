/****************************************************************
Name:		ctest.c

Purpose:	This program establishes a connection with the
	requested server. After the connection is made, packets
	will be exchanged with the server to test network throughput.
	Timing results are written to a file by the server.

Author: Jeff Silvaggi

Date: 08-12-91

Change History:
**********************************************************************/
#include <stdio.h>
#ifndef BSD43
#include <tiuser.h>
#endif
#include <sys/types.h>
#include <netinet/in.h>
#include "net.h"

#define START_TIMER	1
#define STOP_TIMER	2
#define SEND_DATA	3
#define EXIT		4
#define TEST_SIZE	5
#define RECV_DATA	6

struct test_size
{
  long	times;
  long	size;
} test_size;

main( argc, argv )
char **argv;
{
char proto[10];
char socket[10];
char *buffer;
int fd, bytes, status, times;
int msg_size=8192;
int dir;

setbuf( stdout, 0 );

if( argc == 4 )
  msg_size = 8;
else
if( argc == 5 )
  msg_size = atoi( argv[4] );
else
{
  printf("Usage: %s <node> <-PD> <times> [sizeK]:\n", argv[0]);
  printf("   P = protocol (XNS or TCP)\n");
  printf("   D = direction (SEND or RECV)\n");
  exit(1);
}

msg_size *= 1024;

if( toupper(argv[2][1]) == 'X' )
  strcpy( proto, "XNS" );
else
if( toupper(argv[2][1]) == 'T' )
  strcpy( proto, "TCP" );
else
{
  printf("Invalid protocol specified\n");
  exit();
}

/* If user wants to send, tell server to receive */
if( toupper(argv[2][2]) == 'S' )
  dir = RECV_DATA;
else
  dir = SEND_DATA;

times = atoi( argv[3] );
printf("times = %d  message size = %d\n", times, msg_size);

test_size.times = htonl( times );
test_size.size = htonl( msg_size );

msg_size *= times;
printf("Total message size <%d>\n", msg_size );

/* Allocate communication buffer */
buffer = (char *)malloc( msg_size );
if( buffer == 0 )
{
  printf("Error allocating communication buffer\n");
  exit(1);
}

/* Establish connection to server */
printf("Attempting to connect to %s\n", argv[1]);

if( proto[0] == 'T' )
  strcpy( socket, "5010" );
else
  strcpy( socket, "0bd0" );
fd = net_client( argv[1], socket, proto, 0 );
if(fd < 0)
{
  printf("\nclient_init failed : fd = %d\n", fd);
  switch( fd )
  {
    case MACHINE_DOWN:
      printf("HOST not responding\n");
      break;

    case NO_SERVER:
      printf("Requested server is NOT running\n");
      break;
  }
  exit();
}

printf("\nConnection accomplished.\n");

/* Send message size structure */
status = net_send( fd, &test_size, sizeof( test_size ), TEST_SIZE );
if( status )
{
  printf("Error sending message to server\n");
  net_stop( fd );
  exit(1);
}

status = net_recv_size( fd, &bytes );
if( status )
{
  printf("Error receiving size from server\n");
  net_stop( fd );
  exit(1);
}

/* Send timer start */
printf("Start timer...\n");
status = net_send( fd, buffer, 0, START_TIMER );
if( status )
{
  printf("Error sending message to server\n");
  net_stop( fd );
  exit(1);
}

status = net_recv_size( fd, &bytes );
if( status )
{
  printf("Error receiving size from server\n");
  net_stop( fd );
  exit(1);
}

/* If the server is doing the send, send a 0 length message */
if( dir == SEND_DATA )
  msg_size = 0;

printf("Data transfer...\n");

/* Send data */
status = net_send( fd, buffer, msg_size, dir );
if( status )
{
  printf("Error sending message to server\n");
  net_stop( fd );
  exit(1);
}

status = net_recv_size( fd, &bytes );
if( status )
{
  printf("Error receiving size from server\n");
  net_stop( fd );
  exit(1);
}

if( bytes )
{
  status = net_recv( fd, buffer );
  if( status )
  {
    printf("Error receiving data from server\n");
    net_stop( fd );
    exit(1);
  }
}

/* Send timer stop */
printf("Stop timer...\n");
status = net_send( fd, buffer, 0, STOP_TIMER );
if( status )
{
  printf("Error sending message to server\n");
  net_stop( fd );
  exit(1);
}

status = net_recv_size( fd, &bytes );
if( status )
{
  printf("Error receiving size from server\n");
  net_stop( fd );
  exit(1);
}


/* Exit */
printf("\nExiting...\n");
status = net_send( fd, buffer, 0, EXIT );
if( status )
{
  printf("Error sending message to server\n");
  net_stop( fd );
  exit(1);
}

sleep( 2 );
net_stop( fd );
exit(0);
} /* end of main() */
