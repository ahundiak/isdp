#include <sys/types.h>
#include <sys/socket.h>
#include <sys/utsname.h>
#include <sys/stat.h>
#include <netinet/in.h>
#include <utime.h>
#include <netdb.h>
#include <fcntl.h>
#include <ctype.h>
#include <termio.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include "dipdef.h"
#include "defs.h"
#include "req.h"


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

#define SERVER		"/usr/ip32/deltools/delserve"
#define	TCPSERVER	"newprod"
#define FMU	0
#define SNI	1
#define TCP	2

char	*errval[] = {
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
	"Insufficient permissions for operation",
};

REQUEST	*request;
REPLY	*reply = NULL;
int	connected = 0;
long	snid = 0;
int	nettype;
int	sk;
int	xfersize;
char	server_version[VERSION_LEN];
long	perf_delta = 0;
long	perf_bytes = 0;

extern char	*sys_errlist[];
extern unsigned int	decode_slot;
extern short	verbose;
extern short	debug;
extern short	srcmedia;
extern char	progname[STRSIZ];
extern char	*errstr;
extern char	*version;
extern char	*errval[];
#ifdef XNS_NET
extern struct cnfgblk	fmu_cnfg_rmt;
extern unsigned short	inc_status_s;
#endif
extern FILE	*logf;
extern struct utsname	un;
extern char	gf_flag;
/*
 * transmit buffer based on TCP or XNS (SNI)
 */
char	*tx(buf)
char	*buf;
{
    int	i;

#ifdef XNS_NET
    if (nettype == SNI)
	return(sni_txw(&snid, buf, &xfersize, TIMEOUT));
    else if (nettype == TCP) {
	i = write(sk, buf, xfersize);

	if (i < 0 && errno == EPIPE)
	    lostpeer(0);

	if (i == xfersize)
	    return(NULL);
	return("transmit error");
    }
    return("invalid net_type");
#else
    i = write(sk, buf, xfersize);

    if (i < 0 && errno == EPIPE)
	lostpeer(0);

    if (i == xfersize)
	return(NULL);
    return("transmit error");
#endif
}

/*
 * receive buffer based on TCP or XNS (SNI)
 */
char	*rx(buf)
char	*buf;
{
	int	i;
	int	offset;
	int	rsize;
	long	perf_seconds;
	extern	time_t	time();
#ifdef XNS_NET
	char	*err;
#endif

	if (debug)
		time(&perf_seconds);

#ifdef XNS_NET
	if (nettype == SNI) {
		err = sni_rxw(&snid, buf, &xfersize, TIMEOUT);
		if (debug) {
			perf_delta += time(NULL) - perf_seconds;
			perf_bytes += xfersize;
		}
		return(err);
        } else if (nettype == TCP) {
	    offset = 0;
	    rsize = xfersize;
	    while (rsize > 0) {
		i = read(sk, buf + offset, rsize);
		/*
		 * If we've lost our connection to the server,
		 * we need to exit completely.
		 */
		if (i < 0 && errno == ECONNRESET)
		    lostpeer(0);

		/*
		 * if no chars read or a read error then get out
		 */
		if (i < 1)
			break;
		rsize -= i;
		offset += i;
	    }
	    
	    if (debug) {
		perf_delta += time(NULL) - perf_seconds;
		perf_bytes += offset;
	    }

	    if (rsize)
		return("receive error");
	    return(NULL);
	}
	return("invalid net_type");
#else
	offset = 0;
	rsize = xfersize;
	while (rsize > 0) {
	    i = read(sk, buf + offset, rsize);

	    /*
	     * If we've lost our connection to the server,
	     * we need to exit completely.
	     */
	    if (i < 0 && errno == ECONNRESET)
		lostpeer(0);
	    /*
	     * if no chars read or a read error then get out
	     */
	    if (i < 1)
		break;
	    rsize -= i;
	    offset += i;
	}
	
	if (debug) {
	    perf_delta += time(NULL) - perf_seconds;
	    perf_bytes += offset;
	}
	
	if (rsize)
	    return("receive error");
	return(NULL);
#endif
}

char	*send_request()
{
	xfersize = sizeof(REQUEST);
	request->req_len = (int)htocl(xfersize);
		VPRINT("Send_request: ", (char *)request);
	if ((errstr = tx((char *)request))) {
		VPRINT("Transmit error: ", errstr);
		return(errstr);
	}
	return(NULL);
}

char	*receive_file(fd)
int	fd;
{
	char	*buf;
	unsigned int	rsize;
	int	cnt;
	int	offset;

#ifdef CHECKSUM
	unsigned int	rcvd_cksum = 0;
#endif

	perf_delta = 0;
	perf_bytes = 0;
	for (;;) {
		/*
		 * fill in the 1k reply data and the first 15k of buffer data
		 */
		xfersize = NETSIZE;

		if ((errstr = rx((char *)reply)))
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
			if ((errstr = rx(buf)))
				return(errstr);
			cnt -= xfersize;
		}

		rsize = MIN(ctohl((unsigned long)reply->size), RBSIZE);

#ifdef CHECKSUM
		rcvd_cksum = checksum(reply->buf, rsize);

		if (ctohl(reply->cksum) != rcvd_cksum)
			return("Incorrect checksum");
#endif

		if (write(fd, reply->buf, rsize) == -1)
			return("File write error");

		if (ctohl((unsigned long)reply->rep_type) == LAST_BUFFER) {
			if (verbose)
				PRINT ".\n");
			break;
		}

		if (verbose)
			PRINT ".");
	}

	if (debug) {
		if (!perf_delta)
			perf_delta++;
		PRINT "\nDEBUG: Effective transfer rate = %d bytes/second\n",
			perf_bytes / perf_delta);
	}

	return(0);
}

char	*net_keyreq(pptr)
struct prodnode	*pptr;
{
	strncpy(request->prodnum,   pptr->prodnumber, PRODNUM_LEN);
	strncpy(request->prodname,  pptr->prodname,   PRODNAME_LEN);
	strncpy(request->prodflags, pptr->flags,      FLAGS_LEN);
	strncpy(request->prodpath,  pptr->srcdir,     DIR_LEN);
	strncpy(request->prodver,   pptr->prodversion, VERSION_LEN);
	request->req_type = htocl((unsigned long)GET_LOAD_KEY);

	if (!send_request()) {
		xfersize = 1024;
		if ((errstr = rx((char *)reply))) {
			DPRINT("Load key  receive error:", errstr);
			return(NULL);
		}
	}

	if (*reply->str == 0)
		return(0);
	return((char *)reply->str);
}

int	net_keyverify(pptr, lk, custid)
struct prodnode	*pptr;
char	*lk;
char	*custid;
{

	VPRINT1("net_keyverify");
	strncpy(request->prodnum,   pptr->prodnumber, PRODNUM_LEN);
	strncpy(request->prodname,  pptr->prodname,   PRODNAME_LEN);
	strncpy(request->prodflags, pptr->flags,      FLAGS_LEN);
	strncpy(request->prodpath,  pptr->srcdir,     DIR_LEN);
	strncpy(request->loadkey,   lk, KEY_LEN);
	strncpy(request->prodver,   pptr->prodversion, VERSION_LEN);
	request->req_type = htocl((unsigned long)VERIFY_LOAD_KEY);
	strncpy(request->custid,   custid, CUSTID_LEN-1);
	if (!send_request()) {
		xfersize = 1024;
		if ((errstr = rx((char *)reply))) {
			DPRINT("Verify_load_key receive error: ", errstr);
			return(-1);
		}
		if (reply->str[0])
			return(-1);
		else
			decode_slot = ctohl((unsigned long)reply->owner);
	}

	return(0);
}

char	*net_receive(src, dest, pptr)
char	*src, *dest;
struct prodnode	*pptr;
{
	int	rfile = 0;
	int	ofd;
	struct utimbuf utim;

	strcpy(request->prodpath, src);

	if (dest[0] == '-')
		ofd = 1;	/* output file is stdout */
	else {
		if ((ofd = open(dest, O_WRONLY|O_CREAT|O_TRUNC, 0664)) == -1)
			return("Cannot create/write file\n");
		++rfile;
	}

	if (pptr) {
		strncpy(request->prodnum,   pptr->prodnumber, PRODNUM_LEN);
		strncpy(request->prodname,  pptr->prodname,   PRODNAME_LEN);
		strncpy(request->prodflags, pptr->flags,      FLAGS_LEN);
		request->iproc = htocl((unsigned long)decode_slot);
	} else
		strncpy(request->prodflags, "0", FLAGS_LEN);

	request->req_type = htocl((unsigned long)RECEIVE_FILE);

	if ((errstr = send_request())) {
	    if (rfile)
		close(ofd);
	    return(errstr);
	}
	else {
		if (verbose)
			PRINT "VERBOSE: Receiving %s", src);
		if ((errstr = receive_file(ofd))) {
			if (verbose)
				PRINT "\n");
			if (rfile)
			    	close(ofd);
			return(errstr);
		}
	}

	if (rfile) {
		close(ofd);
		chmod(dest, (mode_t)ctohl((unsigned long)reply->mode));
		chown(dest, ctohl((unsigned long)reply->owner), ctohl((unsigned long)reply->group));
		utim.actime = ctohl((unsigned long)reply->atime);
		utim.modtime = ctohl((unsigned long)reply->mtime);
		utime(dest, &utim);
	}

	return(NULL);
}

/*
 * get the load key file from the remote node
 */
int	net_get_load_key_file()
{
	extern char	*net_error();
	extern char	cdrel[16];
	char	*c;
	int	len;

	/*
	 * get the filename from the server and then transfer the file
	 * normally
	 */
	request->req_type = htocl((unsigned long)SEND_LOAD_KEY_FILENAME);
	request->authtyp = 0;

	if (send_request())
		return(-1);

	xfersize = 1024;
	if ((errstr = rx((char *)reply))) {
		DPRINT("Get load key filename error: ", errstr);
		return(-1);
	}

	if (ctohl((unsigned long)reply->rep_type) == REPLY_ERROR) {
		VPRINT("Server error:", errval[ctohl((unsigned long)reply->error)]);
		return(-1);
	}

	if (!reply->str[0]) {
		DPRINT1("Server does not support key file request.");
		return(-1);
	}

	/*
	 * fill in cdrel from basename of file name
	 */
	c = strrchr((char *)reply->str, '/');
	if (c == NULL)
		cdrel[0] = '\0';
	else {
	        if (strcmp(c, "/keyfile") == 0) {
		    len = strlen((char *)reply->str);
		    strcpy(cdrel, (char *)(reply->str + len + 1));
		}
		else {
		    sprintf(cdrel, "%c%c/%c%c/%c%c",
			c[1], c[2], c[3], c[4], c[5], c[6]);
		}
	}

	if ((errstr = net_receive((char *)reply->str, "/usr/tmp/keyfile",
		(struct prodnode *)0))) {
		VPRINT("Error receiving load key file:", errstr);
		return(-1);
	}

	return(0);
}

/*
 * get the serial number file from the remote node
 */
int	net_get_sn_file()
{
	extern char	*net_error();

	/*
	 * get the filename from the server and then transfer the file
	 * normally
	 */
	request->req_type = htocl((unsigned long)SEND_LOAD_KEY_FILENAME);
	request->authtyp = 1;

	if (send_request())
		return(-1);

	xfersize = 1024;
	if ((errstr = rx((char *)reply))) {
		DPRINT("Get serial nnumber filename error: ", errstr);
		return(-1);
	}

	if (ctohl((unsigned long)reply->rep_type) == REPLY_ERROR) {
		VPRINT("Server error:", errval[ctohl((unsigned long)reply->error)]);
		return(-1);
	}

	if (!reply->str[0]) {
		DPRINT1("Server does not support serial no file request.");
		return(-1);
	}

	if ((errstr = net_receive((char *)reply->str, "/usr/tmp/snfile",
		(struct prodnode *)0))) {
		VPRINT("Error receiving serial number file:", errstr);
		return(-1);
	}

	return(0);
}

/*
 * inform the server of our version number and get the server's version too
 */
int	net_get_server_version()
{
	extern char	*net_error();
	int flags;
	extern unsigned short sssn;
/*	static int onetime=0; */
	request->req_type = htocl((unsigned long)GET_VERSION);
	strncpy(request->prodpath, version, VERSION_LEN);
	/*
	 * define the capabilities of this client to the server
	 */
#define MIN_16K		0x01	/* allow for incomplete 62K buffers */
#define NOCHECKSUM	0x02	/* avoid spending time doing checksums */
#define DEBUG		0x04	/* avoid spending time doing checksums */
	
	flags = MIN_16K;
	if (debug)
		flags |= DEBUG;

#ifndef CHECKSUM
	flags |= NOCHECKSUM;
#endif
	VPRINT1("Send request for server version:");
	request->iproc = htocl((unsigned long)flags);
	if (send_request())
		return(-1);
	VPRINT1("net_get_server---rx:");
	xfersize = 1024;
	if ((errstr = rx((char *)reply))) {
		DPRINT("Get server version error: ", errstr);
		return(-1);
	}
	VPRINT1("net_get_server---ctohl:");
	if (ctohl((unsigned long)reply->rep_type) != NORMAL) {
		PRINT "Incompatible server: host DELTOOLS needs to be upgraded.\n");
		return(-1);
	}
	VPRINT1("net_get_server---str[0]:");
	if (!reply->str[0]) {
		DPRINT1("Server does not support version request.");
		return(-1);
	}
	VPRINT1("net_get_server---fill in version:");
	/*
	 * fill in server_version from reply string
	 */
	strncpy(server_version, (char *)reply->str, VERSION_LEN);
	if (debug) {
		PRINT "DEBUG: Client version: %s\n", version);
		PRINT "DEBUG: Server version: %s\n", server_version);
	}
	if (strcmp(version,"07.06.00.00") >= 0 && strcmp(server_version,"07.06.00.00") < 0) {
		DPRINT1("Server does not support Serial Numbers\n");
		VPRINT1("Server does not support Serial Numbers\n");
/*
		if (!onetime)
		    PRINT("		The Server to which Newprod is connecting does not\n		support serial number authorization\n");
*/
		sssn=0;
	}
	else {
		VPRINT1("Server supports serial number authorization\n");	
		sssn=1;
	}
	return(0);
}

/*
 * network closing code
 */
char	*net_disconnect()
{
	if (!connected)
	    return(NULL);

#ifdef XNS_NET
    	if (nettype != SNI && nettype != TCP)
	    return(NULL);
	
	request->req_type = htocl((unsigned long)END_CONNECTION);
	send_request();

	if (nettype == SNI) {
	    if ((errstr = sni_close(&snid)))
		return(errstr);
	}
	else /* (nettype == TCP) */
	    close(sk);

	return(NULL);
#else
	request->req_type = htocl((unsigned long)END_CONNECTION);
	send_request();
	close(sk);

	return(NULL);
#endif
}

/*
 * This routine is called to inform the user that a network error has
 * been encountered and to attempt retry of the operation.
 */
char	*net_error(oper, error, showerr)
char	*oper, *error;
int	showerr;
{
	if (showerr) {
		PRINT "\n*** Network %s error: %s\n", oper, error);
		LPRINT "\n*** Network %s error: %s\n", oper, error);
	}
	return(error);
}

/*
 * connect to remote node, either by FMU (for VAXES) or TCP
 */
#ifdef XNS_NET
char	*xns_connect(connstr)
char	*connstr;
{
    if (srcmedia == NETWORK) {
        /*
	 * try FMU -- will succeed on VMS and UNIX with XNS. 
	 */
	DPRINT1("Trying to connect via FMU to define remote OS type");
	if (!(errstr = fmu_connect(connstr))) {
	    if (fmu_cnfg_rmt.ostype == DIP_OS_VAXVMS)
	        srcmedia = VAX;
	    else 
    	        srcmedia = WORKSTATION;
	    putenv("PROTOCOL=XNS");
	    nettype = FMU;
	    connected = 1;
	    request->revision = 1;
	    return(NULL);	
	}
	else {
    	    return(errstr);
	}
    }
    else {
	DPRINT1("Attempting to connect to remote CD/ROM via SNI");
	if (!(errstr = sni_connect(&snid, connstr, 0, SERVER))) {
	    errstr = "Memory allocation failure";
	    if (!request) {
	      if (!(request = (REQUEST *)calloc(1, sizeof(REQUEST))))
	        return(errstr);
	    }
	    if (!reply) {
	      if (!(reply = (REPLY *)calloc(1, sizeof(REPLY))))
	        return(errstr);
	    }
	    putenv("PROTOCOL=XNS");
	    nettype = SNI;
	    connected = 1;
	    request->revision = 1;
	    return(NULL);
	}
        else
    	    return(errstr);
    }
}

char	*net_connect(connstr)
char	*connstr;
{
	struct sockaddr_in	server;
	struct servent	*sp;
	struct hostent	*hp;
	unsigned long	in;
	char	*nodename, *username, *password;
	char	*xnserror;
	int		xns_installed = 0;
	struct stat	sbuf;

	if ((stat("/usr/lib/nodes", &sbuf) == 0) && S_ISDIR(sbuf.st_mode)) {
	    if ((stat("/usr/ip32/inc", &sbuf) == 0) && S_ISDIR(sbuf.st_mode)) {
		xns_installed = 1;
	    }
	}

        connected = 0;

        errstr = "Memory allocation failure";
	if (!(request = (REQUEST *)calloc(1, sizeof(REQUEST))))
	    return(errstr);

	if (!(reply = (REPLY *)calloc(1, sizeof(REPLY))))
	    return(errstr);

	hp = NULL;
	/*
	 * parse the connect string and see if it resembles an internet address
	 * style
	 */
	in = net_connstr_parse(connstr, &nodename, &username, &password);

        if (in == 0)  {
	    return(xns_connect(connstr));
        }
	else {
	    xnserror = errstr;
	    DPRINT1("Trying to connect via TCP/IP");

	    /*
	     * try a TCP connect - first verify the service exists
	     * if the service doesn't exist, then error out with the inc error
	     */
	    if (!(sp = getservbyname(TCPSERVER, "tcp"))) {
		if (xns_installed) {
		    if (!gf_flag) {
			PRINT "%s: Note: Could not obtain 'newprod' TCP/IP service port.\n", progname);

			PRINT "%s: Note: Attempting to connect via XNS...\n", progname);
		    }
		    return(xns_connect(connstr));
		}
		else
		    return("Could not obtain 'newprod' service");
            }

	    if (in == 2 || in == 4) {  /* String included internet address */
		if (!(hp = (struct hostent *)calloc(sizeof(struct hostent), 1)))
			return("Memory allocation failure");
		in = inet_addr(nodename);
		errstr = (char *)&in;
		hp->h_addr_list = &errstr;
		hp->h_length = 4;
		hp->h_addrtype = AF_INET;
	    } else if (!hp) {
		if (!(hp = gethostbyname(nodename))) {
		    DPRINT("gethostbyname failed on ", nodename);
		    if (xns_installed) {
			if (!gf_flag) {
			    PRINT "%s: Note: Could not determine a TCP/IP address for '%s'.\n", progname, nodename);
			    PRINT "%s: Note: Attempting to connect via XNS...\n", progname);
			}
			return(xns_connect(connstr));
		    }
		    else
			return("Could not resolve host name");
		}
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
		DPRINT1("Socket allocation failed");
		if (xns_installed) {
		    if (!gf_flag) {
			PRINT "%s: Note: Could not allocate a TCP/IP socket.\n", progname);
			PRINT "%s: Note: Attempting to connect via XNS...\n", progname);
		    }
		    return(xns_connect(connstr));
		}
		else
		    return("Socket allocation failed");
	    }

	    if (connect(sk, (struct sockaddr *)&server, sizeof(server)) < 0)
	    {
		DPRINT1("TCP connect failed");
		if (xns_installed) {
		    if (!gf_flag) {
			PRINT "%s: Note: Could not connect to TCP/IP server -- %s.\n", progname, sys_errlist[errno]);
			PRINT "%s: Note: Attempting to connect via XNS...\n", progname);
		    }
		/*
		 * 92/01/22 SCW
		 *	Make sure we close the socket!  Otherwise, TCP/IP
		 *	leaves it in a confused state and it can cause
		 *	a kernel panic when we exit!
		 */
		    close(sk);
		    return(xns_connect(connstr));
		}
		else
		    return("Could not connect to server");
	    }

	    connected = 1;

	    /*
	     * send the username and password to the server and check for
	     * proper authentication
	     */
	    if (srcmedia != NETCDROM)
		srcmedia = TCPIP;

	    putenv("PROTOCOL=TCP/IP");
	    nettype = TCP;
	    request->req_type = htocl((unsigned long)DEFINE_USER);
	    strncpy(request->prodname, username, PRODNAME_LEN);
	    strncpy(request->prodnum,  password, PRODNUM_LEN);
	    request->revision = 1;

	    DPRINT1("Validating the username/password combination");
	    errstr = "Invalid username/password combination";
	    if (!(errstr = send_request())) {
		xfersize = NETSIZE;
		if ((errstr = rx((char *)reply)))
			return(errstr);

		if (ctohl((unsigned long)reply->rep_type) == REPLY_ERROR)
			return(errval[ctohl((unsigned long)reply->error)]);

		return(NULL);
	    }
	}
	return(errstr);
}
#else
char    *net_connect(connstr)
char    *connstr;
{
        struct sockaddr_in      server;
        struct servent  *sp;
        struct hostent  *hp;
        unsigned long   in;
        char    *nodename, *username, *password;
        char    *xnserror;


	connected = 0;

        errstr = "Memory allocation failure";
        xnserror = errstr;
        if (!(request = (REQUEST *)calloc(1, sizeof(REQUEST))))
                return(errstr);

        if (!(reply = (REPLY *)calloc(1, sizeof(REPLY))))
                return(errstr);

        if (srcmedia != NETCDROM)
                srcmedia = TCPIP;

        /*
         * try a TCP connect - first verify the service exists
         * if the service doesn't exist, then error out with the inc error
         */
        if (!(sp = getservbyname(TCPSERVER, "tcp")))
                return("Could not obtain 'newprod' service");

        /*
         * parse the connect string and see if it resembles an internet address
         * style
         */
        in = net_connstr_parse(connstr, &nodename, &username, &password);

        DPRINT1("Trying to connect via TCP");

        if (in == 2 || in == 4) {
                if (!(hp = (struct hostent *)calloc(sizeof(struct hostent), 1)))
		return("Memory allocation failure");
                in = inet_addr(nodename);
                errstr = (char *)&in;
                hp->h_addr_list = &errstr;
                hp->h_length = 4;
                hp->h_addrtype = AF_INET;
        } else if (!(hp = gethostbyname(nodename))) {
                DPRINT("gethostbyname failed on ", nodename);
                return("Could not resolve host name");
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
                DPRINT1("socket allocation failed");
                return("Socket allocation failed");
        }

        if (connect(sk, (struct sockaddr *)&server, sizeof(server)) < 0) {
                DPRINT1("TCP connect failed");
                return("Could not connect to server");
        }

	connected = 1;

        /*
         * send the username and password to the server and check for
         * proper authentication
         */
        request->req_type = htocl(DEFINE_USER);
        strncpy(request->prodname, username, PRODNAME_LEN);
        strncpy(request->prodnum,  password, PRODNUM_LEN);
	request->revision = 1;

        DPRINT1("Validating the username/password combination");
        if (!(errstr = send_request())) {
                xfersize = NETSIZE;
               if ((errstr = rx((char *)reply)))
                        return(errstr);

                if (ctohl(reply->rep_type) == REPLY_ERROR)
                        return(errval[ctohl(reply->error)]);

                return(NULL);
        }

        return(errstr);
}
#endif

int yydone;
#ifndef FLEX
extern int yyprevious;
#else
extern void yyrestart();
#endif
char *csp;
char cs2[1024];
int	addrtype = 0;
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
int	net_connstr_parse(connstr, node, user, pass)
char	*connstr, **node, **user, **pass;
{
	static char	p_nn[128];
	static char	p_un[32];
	static char	p_pw[768];
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


/*
 * This subroutine will get a password from standard input turning
 * off echo of typed-in characters. A return value of zero 
 * indicates that the password has been read into the buffer passed 
 * in. The size parameter indicates the maximum size of password that
 * can be read. A negative return value indicates some error was
 * encountered when attempting to read the password.
 */
int	get_password(buffer, size)
char	*buffer;
int	size;
{
	int	ttyfd, retval;
	struct termio	ttyblk;			/* tty parms for stdin */

	if ((ttyfd = fileno(stdin)) < 0)
		return(-1);
	ioctl(ttyfd, TCGETA, &ttyblk);		/* get current tty block vals */
	ttyblk.c_lflag &= (~ECHO);		/* turn off character ECHO */
	ioctl(ttyfd, TCSETAF, &ttyblk);

	if ((retval = read(ttyfd, buffer, size)) > 0) {
		*(buffer + retval - 1) = '\0';
		retval = 0;			/* return success */
	}

	ttyblk.c_lflag |= ECHO;			/* turn ECHO back on */
	ioctl(ttyfd, TCSETAF, &ttyblk);
	return(retval);
}

char	*NodeAndUser(connstr, result)
char	*connstr, *result;
{
	char	*username, *nodename, *password;
	char	tmpstr[80];
	int	atype;

	strcpy(tmpstr, connstr);
	atype = net_connstr_parse(tmpstr, &nodename, &username, &password);
	if (atype < 3)
	    sprintf(result, "%s.%s%s", nodename, username, password ? ".<password>" : "");
	else
	    sprintf(result, "%s@%s", username, nodename);
	return(result);
}

/*
 * This subroutine will check a connection string, parameter
 * "connstr", for a username/password combination. If no username is
 * located, it will be prompted for. The string is then tested to 
 * determine if it ends in a "." (for older-style connection strings),
 * or with a ":" (for the newer-style user@node:pass strings); if so,
 * a password is prompted for.  The resultant string is in "connstr".
 * Note: it is assumed that adequate storage has been malloc'd for the
 * string "connstr".
 */
void	chek_connstr(connstr)
char	*connstr;
{
	char	*c;				/* for full connect string */
	char	*nodename, *username, *password;
	char	tmpstr[STRSIZ+32];			/* build prompt string here */
	int	addrtype;

	addrtype = net_connstr_parse(connstr, &nodename, &username, &password);

	if (username[0] == '\0') {
		sprintf(tmpstr,
		"Key in \"username.password\" combination for\n\t\t\"%s\" ---> ",
			connstr);
		display_prompt(tmpstr);
		c = connstr + strlen(connstr) - 1;
		if (*c != '.')	{
		    *++c = '.';			/* append '.' to nodename */
		}
		c++;
		fscanf(stdin, "%s", c);	
		getc(stdin);
	}

	c = connstr + strlen(connstr) - 1;	/* point to last char */
	if ((password[0] == '\0') && 
	    (((addrtype < 3) && (*c == '.')) ||
	    ((addrtype >= 3) && (*c == ':')))) {/* prompt for password */
		PRINT "Password: ");    
		++c;
		if (get_password(c, STRSIZ - (c - connstr)))
			PRINT "\nError reading password\n");
		PRINT "\n");			/* get_password disables NL*/
	}

	if (logf)
		fprintf(logf, "Network connection data: %s\n", NodeAndUser(connstr, tmpstr));
}
