/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
 /*********************************************************************/
 /* This header file contains info needed by both the "fake" RIS      */
 /* TCP/IP functions and the real-mode TSR TCP/IP processing          */
 /* functions.                                                        */
 /*********************************************************************/
/*
**
**              DOS tcp/ip definitions needed by RIS.   Isolate needed defines
**              from various vendors' real or protected mode tcp/ip library.
**      
**      REVISION HISTORY:
*/

/*
**
**      Macro RIS_FIX_FD_SET added to take care of the problem of the different 
**      value defined for FD_SETSIZE macro for PCNFS and PCTCP.         SK
**
*/
#if defined(PCNFS) || defined(IBMTCP) /* only for PCNFS */

#define RIS_FD_SETSIZE  20  /* Maxmium number of file desc. */

typedef struct ris_fd_set {
    fd_mask     fds_bits[howmany(RIS_FD_SETSIZE, NFDBITS)];
} ris_fd_set;

/* Protected to Real */
#define RIS_FIX_FD_SET_PROT_TO_REAL(a,b) { \
			b.fds_bits[0] = a->fds_bits[0]; \
		}

/* Real to Protected */
#define RIS_FIX_FD_SET_REAL_TO_PROT(a,b) { \
			b->fds_bits[0] = a.fds_bits[0]; \
		}

#endif     /* only for PCNFS */

/*
**	For IBM DOS TCP/IP
**	TCP/IP for IBM has an extra field, sin_len in structure
**	struct sockaddr_in and sa_length in sockaddr.
*/
#if defined(IBMTCP) /* only for IBMTCP */

struct fake_sockaddr {
        u_char  sa_family;              /* address family */
        char    sa_data[14];            /* actually longer; address value */
};

struct fake_sockaddr_in {
        u_char  sin_family;
        u_short sin_port;
        struct  in_addr sin_addr;
        char    sin_zero[8];
};

#endif /* only for IBMTCP */

/*
**              original ftpdefs.h -- follows from here. SK     
*/
#define DRVRMSG_DriverLoaded        0x00
#define DRVRMSG_GetBufferAddress    0x01
#define DRVRMSG_ProcessFTPCommand   0x02

#define CLOSE                   0
#define CONNECT                 1
#define GETHOSTBYNAME           2
#define GETSERVBYNAME           3
#define FCNTL                   4
#define READ                    5
#define SOCKET                  6
#define WRITE                   7
#define SLEEP                   8
#define GETDOMAINNAME           9
#define GETHOSTNAME             10
#define SELECT                  11

#ifndef PTR_DIST
	#define PTR_DIST        _far
	#define INT             short
#endif

struct getservbyname_parms {
	char PTR_DIST           *name;                  /* input        */
	char PTR_DIST           *proto;                 /* output       */
	struct servent PTR_DIST *servent_out_ptr;       /* output       */
	struct servent           servent_out;           /* output       */
	long                     errno;                 /* output       */
	char                     variable;              /* input/output */
};

struct gethostbyname_parms {
	char PTR_DIST           *name;                  /* input        */
	struct hostent PTR_DIST *hostent_out_ptr;       /* output       */
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

#if defined(PCTCP) || defined(PCNFS)
struct connect_parms {
	INT                      socket;                /* input        */
	struct sockaddr          name;                  /* input        */
	INT                      namelen;               /* input        */
	INT                      connect_rc;            /* output       */
	long                     errno;                 /* output       */
};
#endif

#if defined(IBMTCP)
struct connect_parms {
	INT                      socket;                /* input        */
	struct fake_sockaddr     name;                  /* input        */
	INT                      namelen;               /* input        */
	INT                      connect_rc;            /* output       */
	long                     errno;                 /* output       */
};
#endif

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

#if defined(PCTCP)
struct select_parms {
	INT                      nfds;                  /* input        */
	struct timeval           timeout;
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
#endif

#if defined(PCNFS) || defined(IBMTCP)
struct select_parms {
	INT                      nfds;                  /* input        */
	struct timeval           timeout;               /* input                */
	struct ris_fd_set PTR_DIST  *readfds_ptr;       /* input                */
	struct ris_fd_set PTR_DIST  *writefds_ptr;      /* input        */
	struct ris_fd_set PTR_DIST  *exceptfds_ptr;     /* input        */
	struct timeval PTR_DIST *timeout_ptr;           /* input        */
	struct ris_fd_set            readfds;           /* input/output */
	struct ris_fd_set            writefds;          /* input/output */
	struct ris_fd_set            exceptfds;         /* input/output */
	INT                      select_rc;             /* output               */
	long                     errno;                 /* output       */
};
#endif

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
