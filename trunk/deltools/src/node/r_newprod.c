#include <sys/types.h>
#include <ctype.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <sys/utsname.h>
#include <netinet/in.h>
#include <sys/signal.h>
#include <netdb.h>
#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <termio.h>
#include <string.h>
#include <errno.h>
#include "infp.h"

#define	PRODNUM_LEN	32		/*max length of product number string*/
#define	PRODNAME_LEN	10		/*max size of name */
#define	TITLE_LEN	40		/*max size of title */
#define	VERSION_LEN	12		/*max size of version */
#define	FLAGS_LEN	32		/*max size of flags field*/
#define	FIXDATE_LEN	12		/*max length of fixes date string*/
#define	DIR_LEN		128		/*max length of VMS/Unix dir string*/
#define	KEY_LEN		32		/*max length of load key string*/
#define CUSTID_LEN	66		/*max length of eval Ser.no. custid*/
#define STRSIZ		128

#define OLD_PRODNUM_LEN 10
#define OLD_KEY_LEN	20
#define OLD_DIR_LEN	80
#include "req.h"

#define DISK		'n'
#define CDROM		'r'
#define TRUE		1
#define FALSE		0
#ifdef XNS_NET
#define SERVER		"/usr/ip32/deltools/delserve"
#endif

#define	TCPSERVER	"newprod"
#define	XNS	0
#define	TCP	1
#define NO	0
#define YES	1

#ifdef L_ENDIAN
#define htocl(x)	(x)
#define ctohl(x)	(x)
#else
unsigned long htocl(i)
unsigned long i;
{
    unsigned long s;
    char *bytes;
    char *swbytes;

    bytes = (char *)&i;
    swbytes = (char *)&s;

    swbytes[0] = bytes[3];
    swbytes[1] = bytes[2];
    swbytes[2] = bytes[1];
    swbytes[3] = bytes[0];
    
    return(s);
}
#define ctohl(x)	htocl(x)
#endif

typedef struct {
    int reboot;
    int media;
    char logwhere[128];
    char server[64];
    char model[64];
    char filesystem[64];
    char products[512];
} DELREQ;

char	*def_words[] = {
    "SERVER",
    "MEDIA",
    "LOGWHERE",
    "MODEL",
    "PRODUCTS",
    "MAX",
    "FILESYSTEM",
    "TARGET",
    "REBOOT",
    "DEBUG",
    "EXIT",
    ""
};

char    *errval[] = {
    "Error in receiving request",
    "Cannot mount CD/ROM",
    "Cannot open file",
    "Cannot stat file",
    "Error in reading file",
    "Key flag not found",
    "Invalid NABDR init data",
    "Invalid username/password combination",
    "No key file available",
    "Request not supported by the server",
    "Request for zero length file",
    "Invalid permissions for operation",
};
extern char	*factorize();

extern char *sys_errlist[];
extern char *version;
char	progname[128];
char	*errstr;
char	server[128] = {""};
char	products[512] = {"u"};
char	*d_products = "u";
char	logwhere[512];
char	*d_logwhere = "./";
char	filesys[64] = {""};
char	logfile[512] = {"/usr/spool/r.log"};
char	defaults[512] = {"/usr/ip32/.defaults"};
char	model[128] = {""};
int	media = DISK;
int	debug = FALSE;
int	reboot = NO;
int	fanout = 8;
int	pending = 0;
int	fd;
int	sk = 0;
int	flags;
int	connected = 0;

int net;
char server_version[VERSION_LEN];
int xfersize;

DELREQ	*delreq;
REQUEST	*request;
REPLY	*reply = NULL;

#if !((defined(clipper) || defined(__clipper__)) && defined(SYSV))
int mkdirp(name, mode)
char *name;
int mode;
{
	char *tdp, *np, *lastpos;
	struct stat	statbuf;
	char tmpdir[256];
	
	strcpy(tmpdir, name);
	tdp = tmpdir;
	np = name;
	lastpos = strrchr(name, '/');

	if (np < lastpos)
		*tdp++ = *np++;

	while (np < lastpos) {
	  while (*np != '/' && np < lastpos)
	    *tdp++ = *np++;
	  
	  /* temporarily place a null to end the string */
          *tdp = '\0';

	  if (stat(tmpdir, &statbuf) < 0) {
		  if (mkdir(tmpdir, (mode_t)mode) < 0) {
			if (errno != EEXIST) {
			  free(tmpdir);
			  return(-1);
			}
		  }
	  }
	  if (*np == '/')
	    *tdp++ = *np++;
        }
	free(tmpdir);
	if (mkdir(name, (mode_t)mode) < 0) {
	    if (errno != EEXIST) {
	        return(-1);
	    }
	}
	return(0);     
}
#endif


/*
 * transmit buffer based on TCP or XNS (SNI)
 */
char	*tx(sk, buf)
int	sk;
char	*buf;
{
	int	i;

#ifdef XNS_NET
	if (net == XNS)
		return(sni_txw(&sk, buf, &xfersize, TIMEOUT));
	else {
		i = write(sk, buf, xfersize);
		if (i == xfersize)
			return(NULL);
		return("transmit error");
	}
#else
	i = write(sk, buf, xfersize);
	if (i == xfersize)
		return(NULL);
	return("transmit error");
#endif
}

/*
 * receive buffer based on TCP or XNS (SNI)
 */
char	*rx(sk, buf)
int	sk;
char	*buf;
{
	int	i;
	int	offset;
	int	rsize;

#ifdef XNS_NET
	if (net == XNS)
		return(sni_rxw(&sk, buf, &xfersize, TIMEOUT));
	else {
		offset = 0;
		rsize = xfersize;
		while (rsize > 0) {
			i = read(sk, buf + offset, rsize);
			/*
			 * if no chars read or a read error, then get out
			 */
			if (i < 1)
				break;
			rsize -= i;
			offset += i;
		}
		if (rsize)
			return("receive error");
		return(NULL);
	}
#else
	offset = 0;
	rsize = xfersize;
	while (rsize > 0) {
		i = read(sk, buf + offset, rsize);
		/*
		 * if no chars read or a read error, then get out
		 */
		if (i < 1)
			break;
		rsize -= i;
		offset += i;
	}
	if (rsize)
		return("receive error");
	return(NULL);
#endif
}

void    senderror(sk, errorcode)
int	sk;
int     errorcode;
{
    reply->rep_type = htocl(REPLY_ERROR);
    reply->error = htocl(errorcode);
    xfersize = NETSIZE;
    tx(sk, (char *)reply);
}


char	*send_request(sk)
int	sk;
{
	xfersize = sizeof(REQUEST);
	request->req_len = (int)htocl(xfersize);
	request->revision = 1;
	if ((errstr = tx(sk, (char *)request))) {
		fprintf(stderr, "Transmit error: %s\n", errstr);
		return(errstr);
	}
	return(NULL);
}


int     net_get_server_version(sk)
int	sk;
{
        extern char     *net_error();

        request->req_type = htocl((unsigned long)GET_VERSION);
        strncpy(request->prodpath, version, VERSION_LEN);
        /*
         * define the capabilities of this client to the server
         */
#define MIN_16K         0x01    /* allow for incomplete 62K buffers */
#define NOCHECKSUM      0x02    /* avoid spending time doing checksums */
#define DEBUG           0x04    /* avoid spending time doing checksums */

        flags = MIN_16K;
        if (debug)
                flags |= DEBUG;

#ifndef CHECKSUM
        flags |= NOCHECKSUM;
#endif

        request->iproc = htocl((unsigned long)flags);

        if (send_request(sk))
                return(-1);

        xfersize = 1024;
        if ((errstr = rx(sk, (char *)reply))) {
                fprintf(stderr, "Get server version error: %s\n", errstr);
                return(-1);
        }

        if (ctohl((unsigned long)reply->rep_type) != NORMAL) {
                fprintf(stderr, "Incompatible server: host DELTOOLS needs to be upgraded.\
n");
                return(-1);
        }
        if (!reply->str[0]) {
                fprintf(stderr, "Server does not support version request.\n");
                return(-1);
        }

        /*
         * fill in server_version from reply string
         */
        strncpy(server_version, (char *)reply->str, VERSION_LEN);
        if (debug) {
                fprintf(stderr, "DEBUG: Client version: %s\n", version);
                fprintf(stderr, "DEBUG: Server version: %s\n", server_version);
        }
        return(0);
}

int     get_file_stats(sk)
int	sk;
{
        struct stat     statbuf;

        if (debug) {
                fprintf(stderr, "\tsource filename: %s\n", request->prodpath);
                fprintf(stderr, "\tproduct number: %s\n", request->prodnum);
                fprintf(stderr, "\tproduct name: %s\n", request->prodname);
                fprintf(stderr, "\tflags: %s\n", request->prodflags);
        }

        if ((fd = open(request->prodpath, O_RDONLY)) == -1) {
                senderror(sk, ERR_OPEN); /* cannot open source file */
                return(1);
        }
	
	if (fstat(fd, &statbuf) == -1) {
                senderror(sk, ERR_STAT); /* cannot stat source file */
                return(1);
        }

        if (!statbuf.st_size) {
                senderror(sk, ERR_ZERO); /* zero length file */
                return(1);
        }

        reply->rep_type = htocl(NORMAL);
        reply->error = 0;
        reply->mode = htocl(statbuf.st_mode);
        reply->size = htocl(statbuf.st_size);
        reply->owner = htocl(statbuf.st_uid);
        reply->group = htocl(statbuf.st_gid);
        reply->atime = htocl(statbuf.st_atime);
        reply->mtime = htocl(statbuf.st_mtime);

        return(0);
}

int     send_file(sk)
int	sk;
{
        int     flg;
        int     rsize;
        int     cnt;
        int     offset;
        char    *buf;
        int     bytes_to_send, r_type;

        extern  unsigned int    checksum();

        flg = atoi(request->prodflags);
/*        tran.iproc = ctohl(request->iproc); */

	if (debug)
	    fprintf(stderr, "\tabout to send the file, prodflags = %d\n", flg);

        rsize = ctohl(reply->size);
        while (rsize != 0) {
                bytes_to_send = IMIN(rsize, RBSIZE);
                r_type = (rsize == bytes_to_send ? LAST_BUFFER : NORMAL);
                reply->rep_type = htocl(r_type);

                if (debug) {
                        fprintf(stderr, "\tsending %d bytes\n", bytes_to_send);
                        fprintf(stderr, "\tLast buffer? %s == %d\n",
                                r_type == LAST_BUFFER ? "Yes" : "No",
                                r_type);
                }

                if (read(fd, (char *)reply->buf, bytes_to_send) != bytes_to_send) {
                        senderror(sk, ERR_READ); /* error in reading source file */
                        return(1);
                }

                /*
                 * buffer is 62k bytes big
                 * first one has reply data (1k) and 7k of data
                 * next have 8k of data
                 * last one has 7k of data, 1k at end unused
                 */
/*
                if (!(flags & NOCHECKSUM))
                        reply->cksum = checksum(reply->buf, bytes_to_send);
*/
                /*
                 * this call sends the 1k of reply data plus the first 15k
                 * of buffer data
                 */

                reply->size = htocl(bytes_to_send);
                xfersize = NETSIZE;
                tx(sk, (char *)reply);

                /*
                 * this call sends buffer data at 16k chunks except for the
                 * last one = 15k
                 */
                cnt = rsize;
                for (offset = 16; cnt > 0 && offset < 62; offset += 16) {
                        xfersize = (offset == 48 ? NETSIZE - 1024 : NETSIZE);
                        buf = (char *)reply + offset * 1024;
                        tx(sk, buf);
                        if (flags & MIN_16K)
                                cnt -= xfersize;
                }

                rsize -= bytes_to_send;
        }
        close(fd);
	if (debug)
	    fprintf(stderr, "\tfile sent\n");
        return(0);
}




char    *receive_file(sk, fd)
int	sk;
int     fd;
{
    char    *buf;
    unsigned int    rsize;
    int     cnt;
    int     offset;
    long    perf_bytes, perf_delta;

#ifdef CHECKSUM
    unsigned int    rcvd_cksum = 0;
#endif

    perf_delta = 0;
    perf_bytes = 0;
    for (;;) {
	/*
	 * fill in the 1k reply data and the first 15k of buffer data
	 */
	xfersize = NETSIZE;
	
	if ((errstr = rx(sk, (char *)reply)))
	    return(errstr);
	if (ctohl((unsigned long)reply->rep_type) == REPLY_ERROR)
	    return(errval[ctohl((unsigned long)reply->error)]);
	
	/*
	 * receive buffer data at 16k chunks, except the last one = 15k
	 */
	cnt = ctohl((unsigned int)reply->size);
	for (offset = 16; cnt > 0 && offset < 62; offset += 16) {
	    xfersize = (offset == 48 ? NETSIZE - 1024 : NETSIZE);
	    buf = (char *)reply + offset * 1024;
	    if ((errstr = rx(sk, buf)))
		return(errstr);
	    cnt -= xfersize;
	}
	
	rsize = IMIN(ctohl((unsigned long)reply->size), RBSIZE);
	
#ifdef CHECKSUM
	rcvd_cksum = checksum(reply->buf, rsize);
	if (ctohl(reply->cksum) != rcvd_cksum)
	    return("Incorrect checksum");
#endif
	
	if (write(fd, (char *)reply->buf, rsize) == -1)
	    return("File write error");
	
	if (ctohl((unsigned long)reply->rep_type) == LAST_BUFFER) {
	    break;
        }
    }

    if (debug) {
        if (!perf_delta)
	    perf_delta++;
    }
    return(0);
}

int yydone;
#ifndef FLEX
extern int yyprevious;
#endif
char *csp;
char cs2[1024];
int     addrtype = 0;
struct {
        char node[128];
        char user[32];
        char pass[768];
} conn;

int
yywrap()
{
        return(1);
}


/*
 * Use the LEX connection string parser to find the
 * nodename, username, and password.  Return the following
 * values:
 *
 *  0 - address is an XNS ethernet address
 *  1 - address is a node.user.pass tuple
 *  2 - address contains an Internet nnn.nnn.nnn.nnn address
 *  3 - address is in user@nodename:password format
 *  4 - address is in user@nnn.nnn.nnn.nnn:password format
 */
int     net_connstr_parse(connstr, node, user, pass)
char    *connstr, **node, **user, **pass;
{
        static char     p_nn[128];
        static char     p_un[32];
        static char     p_pw[768];
        int result;

        *node = p_nn;
        *user = p_un;
        *pass = p_pw;

#ifndef FLEX
        yyprevious = '\n';
#endif
        strcpy(cs2, connstr);
        strcat(cs2, "\n");
        csp = cs2;
        conn.node[0] = 0; conn.user[0] = 0; conn.pass[0] = 0;

        yydone = 0; result = 1;
        while (!yydone && result) {
            result = yylex();
        }

#ifdef FLEX
	yyrestart(stdin);
#endif

        strcpy(*node, conn.node);
        strcpy(*user, conn.user);
        strcpy(*pass, conn.pass);

        return (addrtype);
}




#ifdef XNS_NET
int xns_connect(connstr)
char	*connstr;
{
    char *cp;
    char                *node, *user, *pass;
    char		dec_pass[32];
    extern		char *my_decrypt();
    int                 addrtype;

    /*
     * try SNI -- will succeed on VMS and UNIX with XNS. 
     */
    if (debug)
	fprintf(stderr, "Trying to connect via SNI\n");

    if ((errstr = sni_connect((long*)&sk, connstr, 0, SERVER))) {
	if (strstr(errstr, "Password") != 0) {
	    /* 
	     * maybe the password was still encrypted.
	     * Try decrypting it and connecting again.
	     */
            addrtype = net_connstr_parse(connstr, &node, &user, &pass);
            strcpy(dec_pass, my_decrypt(pass));
            if (addrtype < 3)
                sprintf(connstr, "%s.%s.%s", node, user, dec_pass);
            else
                sprintf(connstr, "%s@%s:%s", user, node, dec_pass);

	    if ((errstr = sni_connect((long*)&sk, connstr, 0, SERVER))) {
		fprintf(stderr, "SNI Connect to remote system failed: %s\n", errstr);
		return(-1);
	    }
	}
	else {
	    fprintf(stderr, "SNI Connect to remote system failed: %s\n", errstr);
	    return(-1);
	}
    }
    net = XNS;
    request->revision = 1;
    return(sk);
}

int net_connect(connstr)
char    *connstr;
{
        struct sockaddr_in      server;
        struct servent  *sp;
        struct hostent  *hp;
        unsigned long   in;
        char    	*nodename, *username, *password;
        char    	*xnserror;
        char    	*service;
	extern		char *my_decrypt();
	int		xns_installed = 0;
	struct stat	sbuf;

	if ((stat("/usr/lib/nodes", &sbuf) == 0) && S_ISDIR(sbuf.st_mode)) {
	    if ((stat("/usr/ip32/inc", &sbuf) == 0) && S_ISDIR(sbuf.st_mode)) {
		xns_installed = 1;
	    }
	}

	connected = 0;
        hp = NULL;
        /*
         * parse the connect string and see if it resembles an internet address
         * style
         */
        in = net_connstr_parse(connstr, &nodename, &username, &password);

	if (debug)
	    fprintf(stderr, "Connecting to %s... ", nodename);
        if (in == 0) {
	    return(xns_connect(connstr));
        }
        else {
	    xnserror = errstr;
	    if (debug)
		fprintf(stderr, "Trying to connect via TCP\n");

	    /*
	     * try a TCP connect - first verify the service exists
	     * if the service doesn't exist, then error out with the inc error
	     */
	    service = TCPSERVER;
	    if (!(sp = getservbyname(service, "tcp"))) {
		if (debug)
		    fprintf(stderr, "Could not obtain 'newprod' service\n");
		if (xns_installed)
		    return(xns_connect(connstr));
		else
		    return(-1);
	    }

	    if (in == 2 || in == 4) {	/* connstr had an internet address in it */
		if (!(hp = (struct hostent *)calloc(sizeof(struct hostent), 1))) {
		    fprintf(stderr, "Memory allocation error\n");
		    return(-1);
		}
		in = inet_addr(nodename);
		errstr = (char *)&in;
		hp->h_addr_list = &errstr;
		hp->h_length = 4;
		hp->h_addrtype = AF_INET;
	    } else if (!(hp = gethostbyname(nodename))) {
		if (debug)
		    fprintf(stderr, "Could not resolve host name %s.\n", nodename);
		if (xns_installed)
		    return(xns_connect(connstr));
		else
		    return(-1);
	    }

#ifndef SYSV
	    bzero((char *)&server, sizeof(server));
	    bcopy((char *)hp->h_addr, (char *)&server.sin_addr, hp->h_length);
#else
	    memset((char *)&server, 0, sizeof(server));
	    memcpy((char *)&server.sin_addr, (char *)hp->h_addr, hp->h_length);
#endif
	    server.sin_family = hp->h_addrtype;
	    server.sin_port = sp->s_port;

	    if ((sk = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
		if (debug)
		    fprintf(stderr, "Socket allocation failed\n");
		if (xns_installed)
		    return(xns_connect(connstr));
		else
		    return(-1);
	    }

	    if (connect(sk, (struct sockaddr *)&server, sizeof(server)) < 0) {
		if (debug)
		    fprintf(stderr, "Connection to TCP server failed -- %s\n", sys_errlist[errno]);
		/*
		 * Close the socket!
		 * Otherwise, the inode can be partially released
		 * with socket data in it, and sni can accidentally
		 * pick it up.  When closing, you'll DIE!
		 */
		close(sk);
		if (xns_installed)
		    return(xns_connect(connstr));
		else
		    return(-1);
	    }
	    net = TCP;
	}

	connected = 1;

	/*
	 * send the username and password to the server and check for
	 * proper authentication
	 */
	request->revision = 1;
        request->req_type = htocl(DEFINE_USER);
        strncpy(request->prodname, username, PRODNAME_LEN);
        strncpy(request->prodnum,  password, PRODNUM_LEN);

        if (debug)
	    fprintf(stderr, "Validating the username/password combination\n");
        if (!(errstr = send_request(sk))) {
            xfersize = NETSIZE;
	    if ((errstr = rx(sk, (char *)reply))) {
		return(-1);
	    }

	    if (ctohl(reply->rep_type) == REPLY_ERROR) {
		if (ctohl(reply->error) == ERR_USER) {
		    /* 
		     * maybe we sent an encrypted password.
		     * Try decrypting it and try again.
		     */
		    strncpy(request->prodnum, my_decrypt(password), PRODNUM_LEN);
		    if (!(errstr = send_request(sk))) {
			xfersize = NETSIZE;
			if ((errstr = rx(sk, (char *)reply))) {
			    return(-1);
			}

			if (ctohl(reply->rep_type) == REPLY_ERROR) {
			    fprintf(stderr, errval[ctohl(reply->error)]);
			    return(-1);
			}
			else
			    return(sk);
		    }
		    else {
			fprintf(stderr, errstr);
			return(-1);
		    }
		}
		else {
		    fprintf(stderr, errval[ctohl(reply->error)]);
                    return(-1);
		}
	    }
	    else
		return(sk);
        }
	else {
	    fprintf(stderr, errstr);
	    return(-1);
	}
   
}
#else
int net_connect(connstr)
char    *connstr;
{
        struct sockaddr_in      server;
        struct servent  *sp;
        struct hostent  *hp;
        unsigned long   in;
        char    	*nodename, *username, *password;
        char    	*xnserror;
        char    	*service;
	int		sk;
	extern char	*my_decrypt();

	connected = 0;

	/*
	 * try a TCP connect - first verify the service exists
	 * if the service doesn't exist, then error out with the inc error
	 */
	service = TCPSERVER;
	if (!(sp = getservbyname(service, "tcp"))) {
	    fprintf(stderr, "Could not obtain 'newprod' service\n");
	    return(-1);
	}

        /* parse the connect string and see if it resembles an internet address
	 * style
	 */
	in = net_connstr_parse(connstr, &nodename, &username, &password);

	if (debug)
	    fprintf(stderr, "Trying to connect via TCP\n");

	if (in == 2 || in == 4) {
	    if (!(hp = (struct hostent *)calloc(sizeof(struct hostent), 1))) {
		fprintf(stderr, "Memory allocation failure.\n");
		return(-1);
	    }
	    in = inet_addr(nodename);
	    errstr = (char *)&in;
	    hp->h_addr_list = &errstr;
	    hp->h_length = 4;
	    hp->h_addrtype = AF_INET;
	} else if (!(hp = gethostbyname(nodename))) {
	    fprintf(stderr, "Could not resolve host name %s\n", nodename);
	    return(-1);
	}

#ifndef SYSV
	bzero((char*)&server, sizeof(server));
	bcopy((char *)hp->h_addr, (char *)&server.sin_addr, hp->h_length);
#else
	memset((char *)&server, 0, sizeof(server));
	memcpy((char *)&server.sin_addr, (char *)hp->h_addr, hp->h_length);
#endif
	server.sin_family = hp->h_addrtype;
	server.sin_port = sp->s_port;

	if ((sk = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
	    if (debug)
		fprintf(stderr, "Socket allocation failed\n");
	    return(-1);
	}

	if (connect(sk, (struct sockaddr *)&server, sizeof(server)) < 0) {
	    if (debug)
		fprintf(stderr, "Connection to TCP server failed -- %s\n", sys_errlist[errno]);
	    return(-1);
	}
	net = TCP;

 	connected = 1;

	/*
	 * send the username and password to the server and check for
	 * proper authentication
	 */
	request->revision = 1;
        request->req_type = htocl(DEFINE_USER);
        strncpy(request->prodname, username, PRODNAME_LEN);
        strncpy(request->prodnum,  password, PRODNUM_LEN);

        if (debug)
	    fprintf(stderr, "Validating the username/password combination\n");
        if (!(errstr = send_request(sk))) {
	    xfersize = NETSIZE;
            if ((errstr = rx(sk, (char *)reply))) {
		return(-1);
	    }

	    if (ctohl(reply->rep_type) == REPLY_ERROR) {
		if (ctohl(reply->error) == ERR_USER) {
		    /*
		     * maybe we sent an encrypted password.
		     * Try decrypting it and try again.
		     */
		    strncpy(request->prodnum, my_decrypt(password), PRODNUM_LEN)
;
		    if (!(errstr = send_request(sk))) {
			xfersize = NETSIZE;
			if ((errstr = rx(sk, (char *)reply))) {
			    return(-1);
			}

			if (ctohl(reply->rep_type) == REPLY_ERROR) {
			    fprintf(stderr, errval[ctohl(reply->error)]);
			    return(-1);
			}
			else
			    return(sk);
		    }
		    else {
			fprintf(stderr, errstr);
			return(-1);
		    }
		}
		else {
		    fprintf(stderr, errval[ctohl(reply->error)]);
		    return(-1);
		}
	    }
	    else
		return(sk);
        }
	else {
	    fprintf(stderr, errstr);
	    return(-1);
	}
}
#endif

/*
 * network closing code
 */
char    *net_disconnect(sk)
int sk;
{
	if (!connected)
	    return(NULL);

        request->req_type = htocl((unsigned long)END_CONNECTION);
        send_request(sk);

#ifdef XNS_NET
	if (net == XNS)
	    if ((errstr = sni_close(&sk)))
		return(errstr);
	else
	    close(sk);
#else
	close(sk);
#endif

        return(NULL);
}

char    *NodeAndUser(connstr)
char    *connstr;
{
        char    *c, *username, *nodename, *password;
	static  char result[80];
        char    tmpstr[80];
        int     atype;

        strcpy(tmpstr, connstr);
        atype = net_connstr_parse(tmpstr, &nodename, &username, &password);
        if (atype < 3)
            sprintf(result, "%s.%s%s", nodename, username, password ? ".<password>" : "");
        else
            sprintf(result, "%s@%s", username, nodename);
        return(result);
}


remote_newprod(target)
char *target;
{
    char	*errstr, *np;
    char	*tnode, *dummy1, *dummy2;
    char	lfname[128];
    int		pid, ofd;
    int		sk;
    
    if ((pid = fork()) == 0) {
	if (debug) {
	    printf("\n\n%s: Invoking newprod on node %s\n", progname, NodeAndUser(target));
	    printf("MEDIA\t\t=\t%s\n", (media == DISK ? "DISK" : "CDROM"));
	    printf("MAX\t\t=\t%d\n", fanout);
	    printf("LOGWHERE\t=\t%s\n", logwhere);
	    printf("PRODUCTS\t=\t%s\n", products);
	    printf("REBOOT\t\t=\t%s\n", (reboot ? "YES" : "NO"));
	    printf("SERVER\t\t=\t%s\n", server);
	    printf("MODEL\t\t=\t%s\n", model);
	    printf("FILESYSTEM\t=\t%s\n", filesys);
	    printf("TARGET\t\t=\t%s\n", NodeAndUser(target));
	}
	sk = net_connect(target);
	if (sk < 0) {
	    fprintf(stderr, "ERROR: Connection to %s failed.\n", NodeAndUser(target));
	    _exit(1);
	}

	if (net_get_server_version(sk)) {
	    fprintf(stderr, "ERROR: Could not obtain version of delivery agent on %s\n", NodeAndUser(target));
	    _exit(1);
	}

	if (strncmp(server_version, "06.", 3) < 0) {
	    fprintf(stderr, "ERROR: Delivery agent on %s is not recent enough to support\n", NodeAndUser(target));
	    fprintf(stderr, "server-based remote delivery\n");
	    _exit(1);
	}

	/*
	 * Send request structure to remote machine
	 */
	request->req_type = htocl(INSTALL_PRODUCTS);
	if (errstr = send_request(sk)) {
	    fprintf(stderr, "ERROR: Request to %s failed: %s\n", NodeAndUser(target), errstr);
	    _exit(1);
	}

	xfersize=NETSIZE;
	if (errstr = rx(sk, (char *)reply)) {
	    fprintf(stderr, "ERROR: Reply from initial request failed: %s\n", errstr);
	    _exit(1);
	}
	if (ctohl((unsigned long)reply->rep_type == REPLY_ERROR)) {
	    fprintf(stderr, "ERROR: Request to install software was DENIED by %s\n", NodeAndUser(target));
	    fprintf(stderr, "REASON: %s\n", errval[ctohl((unsigned long)reply->error)]);
	    _exit(1);
	}
	else {
	    /*
	     * We're allowed.  Construct the special software installation
	     * request structure that gives all of this wonderful information.
	     */
	    delreq->media = htocl(media);
	    delreq->reboot = htocl(reboot);
	    strcpy(delreq->logwhere, logwhere);
	    strcpy(delreq->server, server);
	    strcpy(delreq->model, model);
	    strcpy(delreq->filesystem, filesys);
	    strcpy(delreq->products, products);

	    xfersize = sizeof(DELREQ);

	    if (errstr = tx(sk, (char *)delreq)) {
		fprintf(stderr, "ERROR: transfer of delivery request failed: %s\n",
			errstr);
		_exit(1);
	    }

	    /*
	     * If model is non-NULL and it is a filename (on this machine),
	     * then we have to be ready to give them the file.
	     */
	    if ((*model != '\0') && (strchr(model, '/') != NULL)) {
		strcpy(request->prodpath, model);
		strcpy(request->prodflags, "0");
		if (!get_file_stats(sk))
		    send_file(sk);
		else {
		    fprintf(stderr, "ERROR: could not obtain file stats to send file.\n");
		    _exit(1);
		}
	    }
	    
	    xfersize = NETSIZE;
	    if (errstr = rx(sk, (char *)reply)) {
		fprintf(stderr, "ERROR: Reply from delivery request failed: %s\n", errstr);
		_exit(1);
	    }
	    if (ctohl((unsigned long)reply->rep_type == REPLY_ERROR)) {
		fprintf(stderr, "WARNING: Software delivery to %s failed.\n", NodeAndUser(target));
		_exit(1);
	    }
	    else {
		/*
		 * Look at the str field.  If it's got the name of a file
		 * in it, get it.
		 */
		if (reply->str[0]) {
		    strcpy(request->prodpath, (char *)reply->str);
		    if (access(logwhere, W_OK) != 0) {
			mkdirp(logwhere, 0644);
		    }
                    net_connstr_parse(target, &tnode, &dummy1, &dummy2);
		    sprintf(lfname, "%s/%s.nlog", logwhere, tnode); 
		    ofd = open(lfname, O_WRONLY|O_CREAT|O_TRUNC, 0644);
		    if (ofd < 0) {
			fprintf(stderr, "ERROR: Could not create log file %s -- %s\n", lfname, sys_errlist[errno]);
			_exit(1);
		    }
		    strncpy(request->prodflags, "0", FLAGS_LEN);
		    request->req_type = htocl((unsigned long) RECEIVE_FILE);
		    if ((errstr = send_request(sk))) {
			fprintf(stderr, "ERROR: transfer of request for logfile failed: %s\n",
				errstr);
			_exit(1);
		    }
		    else {
			if (errstr = receive_file(sk, ofd)) {
			    fprintf(stderr, "ERROR: transfer of logfile failed: %s\n", errstr);
			    _exit(1);
			}
			else
			    close(ofd);
		    }
		}
		exit(0);
	    }
	}
    }
    else if (pid < 0) {
	perror("ERROR: creation of child process failed");
	return(-1);
    }
    else
	return(0);
}

/*ARGSUSED*/
void reapchild(dummy)
int dummy;
{
    int		statloc;
    int		child_pid;
    
    child_pid = wait(&statloc);
    pending--;
#ifdef SYSV
    signal(SIGCHLD, reapchild);
#endif
}

/*ARGSUSED*/
void let_another_go(dummy)
int dummy;
{
    pending--;
    signal(SIGUSR1, let_another_go);
}

char    *my_decrypt(pass_num)
char    *pass_num;
/*****************************************************************************/
/* this routine decrypts a godel number created by my_crypt                  */
/*****************************************************************************/
{
        infp    pass;
	char	*dcpass;

        infpInit(&pass, 0);
        infpSetStr(&pass, pass_num);

        dcpass = factorize(&pass);
        return(dcpass);
} /* my_decrypt */


main(argc, argv)
int argc;
char *argv[];
{
    static char	datafile[256] = {"r_newprod.dat"};
    char	str[1024];
    char	*sp;
    char	keyword[64];
    char	*kp;
    char	data[992];
    char	*dp;
    char	dec_pass[32];
    char	*envstr;
    FILE	*cfd; 
    int		value;
    int		targeted = 0;
    int		i;
    char	*host, *user, *pass;
    int		addrtype;

    strcpy(progname, argv[0]);
    request = (REQUEST *)malloc(sizeof(REQUEST));
    reply = (REPLY *)malloc(sizeof(REPLY));
    delreq = (DELREQ *)malloc(sizeof(DELREQ));

    /* Make sure logwhere is initialized to something
     * Otherwise the remote system may try to send mail to
     * someplace strange
     */
    logwhere[0] = 0;

    if ((envstr = (char *)getenv("DATAFILE")) && *envstr)
	strcpy(datafile, envstr);
 
    if ((envstr = (char *)getenv("DEBUG")) && *envstr)
	debug = TRUE;

    if ((cfd = fopen(datafile, "r")) == NULL) {
	sprintf(str, "Open of file %s failed", datafile);
	perror(str);
	exit(1);
    }

    /* Catch the expiring children */
    signal(SIGCHLD, reapchild);

    /* Catch the signal that allows another session to start */
    signal(SIGUSR1, let_another_go);

    while (fgets(str, 1024, cfd)) {
	/* Skip over blank lines and comment lines */
	if (*str == '\n' || *str == '#')
	    continue;

	sp = str;
	kp = keyword;
	while (*sp != ' ' && *sp != '\t' && *sp != '\n')
	    *kp++ = *sp++;

	*kp = '\0';

	if (*sp != '\n') {
	    while (*sp == ' ' || *sp == '\t')
		sp++;
	}
	
	strcpy(data, sp);
	dp = strrchr(data, '\n');
	*dp = '\0';
	
	if (debug) 
	    fprintf(stderr, ">>> %s\t=\t%s\n", keyword, data);

	for (i = 0; *def_words[i] != '\0'; i++)
	if (strncmp(keyword, def_words[i], strlen(def_words[i])) == 0) 
	    break;
	
	if (*def_words[i] != '\0') {
	    switch (i) {
	    case 0:			/* SERVER */
		if (*data == '\0') {
		    fprintf(stderr, "%s: Error: Blank definition for SERVER keyword.\n", argv[0]);
		    exit(2);
		}
		else {
		    strcpy(server, data);
		}
	        break;
	    case 1:			/* MEDIA */
		if (*data) {
		    dp = data;
		    while (*dp != '\0') {
			*dp = toupper(*dp);
			dp++;
		    }
		    if (strcmp(data, "CDROM") == 0)
			media = CDROM;
		    else if (strcmp(data, "DISK") == 0)
			media = DISK;
		    else {
			fprintf(stderr, "%s: Error: Invalid value for %s keyword - %s.\n", argv[0], def_words[i], data);
			fprintf(stderr, "MEDIA value must be CDROM or DISK.\n");
			exit(2);
		    }
		}
		else
		    media = DISK;
		break;
	    case 2:			/* LOGWHERE */
		if (*data)
		    strcpy(logwhere, data);
		else
		    strcpy(logwhere, d_logwhere);
		break;
	    case 3:			/* MODEL */
		strcpy(model, data);
		break;
	    case 4:			/* PRODUCTS */
		if (*data)
		    strcpy(products, data);
		else
		    strcpy(products, d_products);
		break;
	    case 5:			/* MAX */
	        if ((value = atoi(data)) > 0)
		    fanout = value;
		break;
	    case 6:			/* FILESYSTEM */
		if (*data) {
		    sprintf(filesys, "-b %s", data);
		}
		else
		    strcpy(filesys, "");
		break;
		    
	    case 7:			/* TARGET */
		if (*server == '\0') {
		    fprintf(stderr, "%s: Error: No SERVER declared before TARGET %s\n", argv[0], data);
		    exit(2);
		}
		targeted++;

                addrtype=net_connstr_parse(data, &host, &user, &pass);

		if ((int)strlen(pass) > 12) {
		    /* Probably an encrypted password */
                    strcpy(dec_pass, my_decrypt(pass));
                    if (addrtype < 3)
                        sprintf(data, "%s.%s.%s", host, user, dec_pass);
                    else
                        sprintf(data, "%s@%s:%s", user, host, dec_pass);
		}
		while (1) {
		    if (pending < fanout) {
			pending++;
			remote_newprod(data); 
			sleep(10);
			break;
		    }
		    else {
			sleep(5);
		    }
		}
		break;
	    case 8:			/* REBOOT */
		if (*data) {
		    dp = data;
		    while (*dp != '\0') {
			*dp = toupper(*dp);
			dp++;
		    }
		    if (strcmp(data, "YES") == 0)
			reboot = YES;
		    else if (strcmp(data, "NO") == 0)
			reboot = NO;
		    else {
			fprintf(stderr, "%s: Error: Invalid value for %s keyword - %s.\n", argv[0], def_words[i], data);
			fprintf(stderr, "REBOOT value must be YES or NO.\n");
			exit(2);
		    }
		}
		else
		    reboot = NO;
		break;
	    case 9:			/* DEBUG */
		debug = TRUE;
		break;
	    case 10:			/* EXIT */
		exit(0);
		break;
	    default:
		fprintf(stderr, "%s: Error: Invalid keyword \"%s\".\n", argv[0], def_words[i]);
		exit(2);
		break;
	    }
	}
	else {
	    fprintf(stderr, "%s: Error: Invalid keyword \"%s\".\n", argv[0], keyword);
	    exit(2);
	}
    }
    if (!targeted) {
	fprintf(stderr, "%s: Error: No TARGET keywords specified in file.\n", argv[0]);
	exit(2);
    }

    if (pending > 0) {
	while (pending > 0)
	    sleep(5);
    }
    exit(0);
}



    
