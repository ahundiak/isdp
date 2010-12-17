/******************************************************************************

Doc:	net.h

	Copyright (c) 1992
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source:	net.h

Author:	Jeff Silvaggi

Date:	29-JUN-1989

SDM Number:

Description: 	This header file defines all common variables
	used by the communication interface library.

History:
******************************************************************************/
#include     <poll.h>

/* Error returns */
#define     NET_ACCEPTED      -99
#define     NET_REJECTED      -100
#define     NOADRBIND         -101
#define     NOT_ALLOC         -102
#define     NOT_BIND          -103
#define     NOT_CONNECT       -104
#define     NOT_OPEN          -105
#define     NOT_LOOK          -106
#define     NOT_RCV           -107
#define     NOT_RCVREL        -108
#define     NOT_SND           -109
#define     NOT_SNDREL        -110
#define     NOT_CLOSE         -111
#define     NOT_LISTEN        -112
#define     NOT_ACCEPT        -113
#define     NOT_RCVDIS        -114
#define     NOT_SNDDIS        -115
#define     NOT_DISCONNECT    -116
#define     BAD_NODE_NAME     -117
#define     EVENT_OCCURED     -118
#define     SERVER_DISCONNECT -119
#define     NO_SERVER         -120
#define     MACHINE_DOWN      -121

#define     NUM_FDS          1
#define     MAX_CONN_IND     16

/* Commands to Msg Processor */
#define	VALIDATE_CLIENT		0xabcdef01
#define	NO_WAIT	IPC_NOWAIT
#define	WAIT	0

extern     int     t_errno,errno;

/* Define structures for polling */
struct t_call *calls[ MAX_CONN_IND ];		/* Table of outstanding connections */
struct pollfd poll_info[2];			/* Structure for poll()ing streams */

int xns_max, tcp_max;	/* Maximum number of outstanding XNS and TCP connect indications */

/* Format of data packet header */
typedef struct	mail_msg
{
	long	_from_id;	/* 32 bit integer of who sent message */
	long	_cmd;		/* command */
	long	_size;		/* length of this structure + message */
	long	_parms;		/* Command modifier */
} mail_msg;

/* Format of net error structure */
typedef struct
{
	long	errno;		/* errno returned from t_ */
	long	t_errno;	/* t_errno returned from t_ */
	long	t_look;		/* t_look status */
} net_error_str;
