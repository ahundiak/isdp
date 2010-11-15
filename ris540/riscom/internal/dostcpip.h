/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**      NAME:                                                   dostcp.h
**      AUTHORS:                                                Grace Oliver
**      CREATION DATE:                                  05/93
**      ABSTRACT:
**              DOS tcp/ip definitions needed by RIS.   Isolate needed defines
**              from various vendors' real or protected mode tcp/ip library.
**
**      
**      REVISION HISTORY:
*/

#ifndef _DOSTCP_H
#define _DOSTCP_H

/*
** Intergraph modifications: (Original file was: c:\pctcpsdk\include\netdb.h)
**    1.  Qualified all pointers as _near or _far.
**    2.  Changed all ints to #defined INTs.
**    3.  Added #pragma align_members for HighC compiles only.
** For now only defining for  MetaWare HighC/C++ compiler
*/

#pragma align_members(2);

#ifndef PTR_DIST
#define PTR_DIST _near
#define INT short
#endif

typedef unsigned long   u_long;
typedef unsigned short  u_short;
typedef unsigned char   u_char;
typedef unsigned long   unslword;
typedef unsigned short  unsword;

typedef long time_t;
struct timeval {
	u_long  tv_sec;
	u_long  tv_usec;
};

#define NBBY    8       /* number of bits in a byte						*/

#ifdef   FD_SETSIZE     /* no matter what they want, they only get 20	*/
#undef   FD_SETSIZE     /* descriptors from DOS, to reset it if they	*/
#endif                  /* tried to change it.							*/

#define  FD_SETSIZE     20      /* maximum number of DOS file descrs	*/

typedef long    fd_mask;        /* longest easily used number type		*/

#define NFDBITS (sizeof(fd_mask)* NBBY) /* Number of File Descr BITS	*/

#define NFDSHIFT        0       /* how far to shift over sizeof(fd_mask) */

#ifndef  howmany        /* used to find howmany longs needed for allowed */
#define  howmany(x,y)   (((x) + ((y) - 1)) / (y)) /* number of FDs       */
#endif

typedef struct fd_set  {
    fd_mask     fds_bits[howmany(FD_SETSIZE, NFDBITS)];
} fd_set;

#define FD_SET(n, p)    ((p)->fds_bits[(n)/NFDBITS] |= (1L << ((n) % NFDBITS)))
#define FD_CLR(n, p)    ((p)->fds_bits[(n)/NFDBITS] &= ~(1L << ((n)% NFDBITS)))
#define FD_ISSET(n, p)  ((p)->fds_bits[(n)/NFDBITS] & (1L << ((n) % NFDBITS)))
#define FD_ZERO(p)      bzero((char *)(p), sizeof(*(p)))

/* 
** return values from gethostby*() in h_errno. comments stolen from the bugs
** mail daveb sent in at the end of feburary. thanx, dave. (stev, 21MAR90)
*/

#define HOST_NOT_FOUND  1       /* Sorry, no such host is known         */
#define TRY_AGAIN       2       /* This is usually a temporary error    */
				                /* and means that the local server did  */
				                /* not receive a response from an       */
				                /* authoritative server.  A retry at    */
                                /* some later time may succeed.         */
#define NO_RECOVERY     3       /* This is a non-recoverable error.     */
#define NO_ADDRESS      4       /* The requested name is valid but does */
				                /* not have an IP address; this is not a*/
				                /* temporary error.  This means another */
				                /* type of request to the name server   */
				                /* may result in an answer.             */

/* 
** Internet Address structure
*/
struct in_addr {
    union {
	struct { u_char  s_b1, s_b2, s_b3, s_b4; }      S_un_b;
	struct { u_short s_w1, s_w2; }                  S_un_w;
	u_long S_addr;
    } S_un;
#define s_addr  S_un.S_addr
#define s_net   S_un.S_un_b.s_b1
#define s_host  S_un.S_un_b.s_b2
#define s_lh    S_un.S_un_b.s_b3
#define s_impno S_un.S_un_b.s_b4
#define s_imp   S_un.S_un_w.s_w2
};

struct sockaddr_in {
    short               sin_family;
    u_short             sin_port;
    struct in_addr      sin_addr;
    char                sin_zero[8];
};


struct hostent {
    char    PTR_DIST *h_name;       		/* primary name of host          */
    char    PTR_DIST *PTR_DIST *h_aliases;  /* other names of host           */
    INT     h_addrtype;             		/* address type (always AF_INET) */
    INT     h_length;                       /* length of address (always 4)  */
    char    PTR_DIST *PTR_DIST *h_addr_list;/* address                       */
};
#define h_addr  h_addr_list[0]              /* backward compatibility        */

struct servent {
    char    PTR_DIST *s_name;       	   /* primary name of service        */
    char    PTR_DIST *PTR_DIST *s_aliases; /* other names of service         */
    INT     s_port;                 	   /* port number to use             */
    char    PTR_DIST *s_proto;      	   /* protocol service is offered on */
};

/* 
** pctcp\include\sys\socket.h Socket Types
*/
#define SOCK_STREAM     1               /* TCP (stream)                 */

/* Address Families
*/
#define AF_INET         2               /* internetwork: UDP, TCP, etc. */

/* Protocol Families
*/
#define PF_INET         AF_INET

struct sockaddr {
    u_short     sa_family;      		/* address family */
    char        sa_data[14];    		/* up to 14 bytes of address */
};

/*
** ftpdefs.h
*/

#define DRVRMSG_DriverLoaded        0x00
#define DRVRMSG_GetBufferAddress    0x01
#define DRVRMSG_ProcessFTPCommand   0x02

#define CLOSE                   0
#define CONNECT                 1
#define GETHOSTBYNAME   2
#define GETSERVBYNAME   3
#define FCNTL                   4
#define READ                    5
#define SOCKET                  6
#define WRITE                   7
#define SLEEP                   8
#define GETDOMAINNAME   9
#define GETHOSTNAME             10
#define SELECT                  11

struct getservbyname_parms {
	char PTR_DIST           *name;                  /* input        */
	char PTR_DIST           *proto;                 /* output       */
	struct servent PTR_DIST	*servent_out_ptr;       /* output       */
	struct servent           servent_out;           /* output       */
	long                     errno;                 /* output       */
	char                     variable;              /* input/output */
};

struct gethostbyname_parms {
	char PTR_DIST           *name;                  /* input        */
	struct hostent PTR_DIST	*hostent_out_ptr;       /* output       */
	struct hostent           hostent_out;           /* output       */
	long                     errno;                 /* output       */
	long                     h_errno;               /* output       */
	char                     variable;              /* input        */
};

struct socket_parms {
	INT                      af;                    /* input        */
	INT                      type;                  /* input        */
	INT                      protocol;              /* input        */
	INT                      socket_out;            /* output       */
	long                     errno;                 /* output       */
};

struct connect_parms {
	INT                      socket;                /* input        */
	struct sockaddr          name;                  /* input        */
	INT                      namelen;               /* input        */
	INT                      connect_rc;            /* output       */
	long                     errno;                 /* output       */
};

struct read_parms {
	INT                      socket;                /* input        */
	INT                      nbytes;                /* input        */
	INT                      read_rc;               /* output       */
	long                     errno;                 /* output       */
	char                     variable;              /* output       */
};

struct write_parms {
	INT                      socket;                /* input        */
	INT                      nbytes;                /* input        */
	INT                      write_rc;              /* output       */
	long                     errno;                 /* output       */
	char                     variable;              /* intput       */
};

struct getdomainname_parms {
	INT                      namelen;               /* output       */
	INT                      getdomainname_rc;      /* output       */
	long                     errno;                 /* output       */
	char                     variable;              /* output       */
};

struct gethostname_parms {
	INT                      namelen;               /* output       */
	INT                      gethostname_rc;        /* output       */
	long                     errno;                 /* output       */
	char                     variable;              /* output       */
};

struct close_parms {
	INT                      socket;                /* intput       */
	INT                      close_rc;              /* output       */
	long                     errno;                 /* output       */
};

struct select_parms {
	INT                      nfds;                  /* input        */
	struct timeval           timeout;		        /* input                */
	struct fd_set PTR_DIST  *readfds_ptr;           /* input                */
	struct fd_set PTR_DIST  *writefds_ptr;          /* input        */
	struct fd_set PTR_DIST  *exceptfds_ptr;         /* input        */
	struct timeval PTR_DIST *timeout_ptr;           /* input        */
	struct fd_set            readfds;               /* input/output */
	struct fd_set            writefds;              /* input/output */
	struct fd_set            exceptfds;             /* input/output */
	INT                      select_rc;             /* output               */
	long                     errno;                 /* output       */
};

struct fcntl_parms {
	INT                      fd;                    /* intput       */
	INT                      cmd;                   /* intput       */
	INT                      arg;                   /* intput       */
	INT                      fcntl_rc;              /* output       */
	long                     errno;                 /* output       */
};

struct sleep_parms {
	INT                      seconds;               /* intput       */
	INT                      sleep_rc;              /* output       */
	long                     errno;                 /* output       */
};

struct commarea {
	struct {
		long                 opcode;
	} heading;

	union {
		char                                    buffer[2048];
		struct getservbyname_parms              getservbyname_commarea;
		struct gethostbyname_parms              gethostbyname_commarea;
		struct socket_parms                     socket_commarea;
		struct connect_parms                    connect_commarea;
		struct read_parms                       read_commarea;
		struct write_parms                      write_commarea;
		struct getdomainname_parms              getdomainname_commarea;
		struct gethostname_parms                gethostname_commarea;
		struct close_parms                      close_commarea;
		struct select_parms                     select_commarea;
		struct fcntl_parms                      fcntl_commarea;
		struct sleep_parms                      sleep_commarea;
	} parm;
};



/* Functions */

u_long  htonl(u_long), ntohl(u_long);
u_short htons(u_short), ntohs(u_short);

/* 
** from pctcp\include\fcntl.h: fcntl requests
*/
#define F_SETFL         4       /* set file flags                       */

/* file flags 
*/
#define FNDELAY         0x0004  /* non-blocking                         */

/*
** 4bsddefs.h
*/
#define recv(s,buff,nbytes,flag)	PCTCP_read(s,buff,nbytes)
#define send(s,buff,nbytes,flag)	PCTCP_write(s,buff,nbytes)
#define close(s)                	PCTCP_close(s)
#define fcntl(fd,cmd,arg)       	PCTCP_fcntl(fd,cmd,arg)
#define sleep(s)                	PCTCP_sleep(s)
#define select(nfds,readfds,writefds,exceptfds,timeout) \
	                    PCTCP_select(nfds,readfds,writefds,exceptfds,timeout)
int     connect(int, struct sockaddr *, int);
int     gethostname(char *, int), sethostname(char *, int);
int     socket(int, int, int);

int PCTCP_read (int, char *, int);
int PCTCP_write (int, char *, int);
int PCTCP_close (int);
int PCTCP_select (
		int,
		struct fd_set *,
		struct fd_set *,
		struct fd_set *,
		struct timeval *);
int PCTCP_fcntl (int, int, int);
int PCTCP_sleep (int);

#define bzero(a,b)      memset(a,0,b)

/*
** netdb.h
*/
struct hostent  PTR_DIST *gethostbyname(char PTR_DIST *);
struct servent  PTR_DIST *getservbyname(char PTR_DIST *, char PTR_DIST *);

#pragma align_members(4);

#endif /*_DOSTCP_H */
