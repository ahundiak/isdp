/* $Revision: 1.1 $ */
#include     <stropts.h>
#include     <poll.h>

/* Error returns */
#define     NOADRBIND        -101
#define     NOT_ALLOC        -102
#define     NOT_BIND         -103
#define     NOT_CONNECT      -104
#define     NOT_OPEN         -105
#define     NOT_LOOK         -106
#define     NOT_RCV          -107
#define     NOT_RCVREL       -108
#define     NOT_SND          -109
#define     NOT_SNDREL       -110
#define     NOT_CLOSE        -111
#define     NOT_LISTEN       -112
#define     NOT_ACCEPT       -113
#define     NOT_RCVDIS       -114
#define     NOT_SNDDIS       -115
#define     NOT_DISCONNECT   -116

#define     NUM_FDS          1
#define     MAX_CONN_IND     16

/* Commands to Msg Processor */
#define	SET_LENGTH	0x53544C4E	/*SeT_LeNgth */
#define	NO_WAIT	IPC_NOWAIT
#define	WAIT	0

extern     int     t_errno,errno;

/* Define structures for polling */
struct t_call *calls[ MAX_CONN_IND ];		/* Table of outstanding connections */
struct pollfd poll_info;			/* Structure returned by poll() */
