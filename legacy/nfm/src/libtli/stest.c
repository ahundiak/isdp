/****************************************************************
Name:		stest.c

Purpose:	This program becomes an XNS and TCP/IP server.
	Incomming client connections will be accepted, a timer
	will be started, packets will be exchanged with the client
	and the total turn-around time will be written to a file.

Author: Jeff Silvaggi

Date: 08-12-91

Change History:
**********************************************************************/
#include <stdio.h>
#include <time.h>
#include <signal.h>
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

extern FILE *net_err;		/* Network error file descriptor */
extern int net_client_id;	/* Client ID of connecting client */

/****************************************************************************
        Name: main()
 Description: This is the begginning of the server
****************************************************************************/
main( argc, argv )
char **argv;
{
extern int process_commands();
int pid;

net_err = fopen( "errlog", "w" );
if( net_err == 0 )
{
  printf("Error opening error log\n");
  exit(1);
}

setbuf( net_err, 0 );

signal( SIGHUP, SIG_IGN );
signal( SIGINT, SIG_IGN );

pid = fork();
if( pid == -1 )
{
  printf("Error going into background\n");
  exit(1);
}
/* If parent, exit */
if( pid ) exit(0);

/* Become a server */
if(net_server( "0bd0", 5010 ) <  0)
{
  printf("Can not become server\n");
  exit(0);
}

fprintf( net_err, "Server process id = %d\n", getpid() );

/* Poll for incoming connections */
if( net_poll( process_commands ) < 0)
{
  printf("Can not poll for clients\n");
  exit(0);
}

exit(1);
} /* End of server main */

/****************************************************************************
        Name: process_commands
 Description: This function is a command processor to handle the newly
	connected client.
****************************************************************************/
process_commands( fd, address )
int fd;
char *address;
{
char *buffer, msg[80];
int size, status;
int cmd, dir=0;
time_t	t;
char	cur_time[10];
struct tm *tms;
struct test_size *ts;

/* Accept client connection */
status = net_accept( fd );
if( status < 0 )
{
  net_stop( fd );
  exit(1);
}

t = time(0);
tms = localtime(&t);
sprintf( cur_time, "%.2d:%.2d:%.2d", tms->tm_hour, tms->tm_min, tms->tm_sec);

fprintf(net_err,"\nClient:<%d>  PID:<%d>  Time:<%s>  Address:<%s>\n", net_client_id, getpid(), cur_time, address);

/* Allocate message buffer */
buffer = (char *)malloc( 1000000 );
if( buffer == 0 )
{
  fprintf(net_err, "Error allocating message buffer\n");
  exit(0);
}

/* SERVER COMMAND PROCESSOR */
while( 1 )
{
  /* Wait for command */
  status = net_recv_cmd( fd, &size, &cmd );
  if( status )
  {
    fprintf(net_err,"Error %d receiving size: errno = %d t_errno = %d\n",status,errno,t_errno);
    break;
  }

  /* Receive data */
  status = net_recv( fd, buffer );
  if( status )
  {
    fprintf(net_err,"Error %d receiving data: errno = %d t_errno = %d\n",status,errno,t_errno);
    break;
  }

  if( cmd == EXIT )
  {
    fprintf(net_err,"EXIT selected\n");

    sleep(2);
    break;
  }

  size = 0;
  switch( cmd )
  {
    case START_TIMER:
      fprintf( net_err, "Timer started\n");
      timer( 1,0,0 );
      break;

    case STOP_TIMER:
      timer( 0, "Transfer time", net_err );
      if( dir == SEND_DATA )
        strcpy( msg, "sent" );
      else
        strcpy( msg, "received" );
      fprintf( net_err, "Total trips <%d>  packet size %s <%d>\n", test_size.times, msg, test_size.size );
      break;

    case SEND_DATA:
      dir = SEND_DATA;
      size = test_size.size*test_size.times;
      break;

    case RECV_DATA:
      dir = RECV_DATA;
      break;

    case TEST_SIZE:
      ts = (struct test_size *)buffer;
      test_size.size = ntohl( ts->size );
      test_size.times = ntohl( ts->times );
      break;

    default:
      fprintf( net_err, "Invalid message received...cmd <%d>\n", cmd );
      break;
  }

  /* Send back response */
  status = net_send( fd, buffer, size, 0 );
  if( status )
  {
    fprintf(net_err,"Error %d while sending message: errno = %d  t_errno = %d \n", status, errno, t_errno);
    break;
  }
} /* end command processor loop */

/* End connection to client and exit */
net_stop( fd );
free( buffer );
exit(0);
} /* end of process_commands() */
