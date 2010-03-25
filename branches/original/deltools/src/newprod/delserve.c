#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mount.h>
#include <sys/time.h>
#include <sys/utsname.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <stdlib.h>
#include <stdio.h>
#include <utime.h>
#include <signal.h>
#include <netdb.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <memory.h>
#include <pwd.h>
#if defined(sun) && defined(SVR4)
#include <shadow.h>
#endif

#if (defined(clipper) || defined(__clipper__) || defined(SCO))
#  if (defined(SYSV) && !defined(SCO))
#    include <sys/sysingr.h>
#  endif
#  ifdef SecureWare
#    include <sys/param.h>
#    include <sys/immu.h>
#    include <sys/region.h>
#    include <sys/proc.h>
#    include <sys/inode.h>
#   ifdef SCO
#    include <sys/security.h>
#    include <sys/audit.h>
#    include <prot.h>
#    include <protcmd.h>
#   else
#    include <sys/sec/sectypes.h>
#    include <sys/sec/security.h>
#    include <sys/sec/audit.h>
#    include <tcb/prot.h>
#    include <tcb/protcmd.h>
#   endif
#  endif
#endif

#ifdef SYSV
#  if defined(SVR3) || defined(sgi)
#    include <sys/statfs.h>
#  endif
#  if defined(SVR4) && !defined(sgi)
#    include <sys/statvfs.h>
#  endif
#include <sys/fstyp.h>
#include <sys/fsid.h>
#endif

#ifdef SunOS_4
#include <sys/param.h>
#include <sys/vfs.h>
#include <mntent.h>
#include <sys/dir.h>
#endif

/* Added ifdef HP here -- MVR 30 Apr 1994 */
#ifdef HP_UX
#include <sys/param.h>
#include <sys/vfs.h>
#include <mntent.h>
#include <sys/dir.h>
/* NMOUNT value derived from MNTHASHSZ macro. -- MVR 30 Apr 1994  */
#define NMOUNT	32
#endif

#ifdef _AIX
#include <sys/vmount.h>
#include <sys/mntctl.h>
#endif

#ifdef OSF
#include <sys/mount.h>
#endif

#ifdef SVR3
#include "fakesyslog.h"
#else
#include <syslog.h>
#endif

#include "defs.h"
#include "req.h"

extern char *sys_errlist[];

extern char cdrel[];

#define PRDEBUG		if (debug) fprintf(log, 
#define CLIENT_READ	0
#define CLIENT_WRITE	1
#define	XNS		0
#define	TCP		1
#define RING		".cmsdr."
#define SERVER		"/usr/ip32/deltools/delserve"
#define TCPSERVER	"newprod"
#define DISK		'n'
#ifdef sun
#define MAILER		"/usr/ucb/mail"
#elif defined(SVR4) && defined(sgi)
#define MAILER		"/usr/bin/mail"
#else
#define MAILER		"/usr/bin/mailx"
#endif
#define MIN_16K		0x01	/* avoid sending all those unused buffers */
#define NOCHECKSUM	0x02	/* avoid spending time doing a checksum */
#define DEBUG		0x04	/* enable debug file output */

#if defined(clipper) || defined(__clipper__) && defined(SecureWare)
struct  pr_passwd       *prpwd = NULL;  /* protected password database record */
struct  pr_term         *prtc = NULL;   /* protected terminal database record */
struct  passwd          nouser;
extern  struct pr_term  *rhost_check();
extern  int             is_a_problem;
extern  int             want_a_timeout;
#define exit            login_die       /* graceful cleanup in case of exit */
#endif
#if defined(SCO) && defined(SecureWare)
struct  pr_passwd       *prpwd = NULL;  /* protected password database record */
struct  pr_term         *prtc = NULL;   /* protected terminal database record */
struct  passwd          nouser;
extern  struct pr_term  *rhost_check();
extern  int             is_a_problem;
extern  int             want_a_timeout;
#define exit            login_die       /* graceful cleanup in case of exit */
#endif


#ifdef NEW_ARCHITECTURES

#if defined(sun) && defined(SunOS_4)
unsigned long   my_arch = SUN_ARCH;
char    *machine = "sun";
#define ARCH_MAGIC      0100403
#endif
 
#if defined(sun) && defined(SVR4)
unsigned long my_arch = S_SOLARIS_ARCH;
char    *machine = "ssl";
#define ARCH_MAGIC      077505
#endif
 
#if (defined(clipper) || defined (__clipper__)) && defined(SVR3)
unsigned long   my_arch = CLIPPER_ARCH;
char    *machine = "clip";
#define ARCH_MAGIC      0000577
#endif
 
#if (defined(clipper) || defined(__clipper__)) && defined(SVR4)
unsigned long   my_arch = C_SVR4_ARCH;
char    *machine = "cio";
#define ARCH_MAGIC      0000577
#endif
 
#ifdef _AIX
unsigned long my_arch = RS6000_ARCH;
char    *machine = "rs6";
#define ARCH_MAGIC      0000737
#endif

#ifdef sgi
unsigned long my_arch = M_SVR3_ARCH;
char	*machine = "sgi";
#define ARCH_MAGIC	0000540
#endif

#ifdef SCO
unsigned long my_arch = I_SVR3_ARCH;
char	*machine = "sco";
#define ARCH_MAGIC	0000514
#endif

/* Added ifdef HP to take care of HP too -- MVR 30 Apr 1994 */
#ifdef HP_UX
unsigned long my_arch = H_HPUX_ARCH;
char	*machine = "hp";
#define ARCH_MAGIC	0001013
#endif

#else	/* ! NEW_ARCHITECTURES */


#if (defined(clipper) || defined (__clipper__))
unsigned long   my_arch = CLIPPER_ARCH;
char    *machine = "clip";
#define ARCH_MAGIC      0000577
#endif

#ifdef sun
unsigned long   my_arch = SUN_ARCH;
char    *machine = "sun";
#define ARCH_MAGIC      0100403
#endif

#ifdef _AIX
unsigned long my_arch = RS6000_ARCH;
char    *machine = "rs6";
#define ARCH_MAGIC      0000737
#endif

#endif /* NEW_ARCHITECTURES */

#define SLOT 623691234

typedef struct {
    int reboot;
    int media;
    char logwhere[128];
    char server[64];
    char model[64];
    char filesystem[64];
    char products[512];
} DELREQ;

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

int	fd;
int	net;		/* type of network, either XNS or TCP */
int	tmpnet;
long	snid;		/* SNI identifier */
long	tmpsnid;
int	xfersize;
int	client_flags = 0;
int	is_su = 0;

struct tran_s {
    int *buf;
    int bufcnt;
    int iproc;
};

struct init_s {
    int fd;
    char        *num, *access, *pflag;
    int iproc;
};

char	*ingrhome = BASEDIR;
char 	deltools_home[STRSIZ];

char	*err;
char	*errstr;
char	*shell;
char	client_version[VERSION_LEN];
REPLY	*reply = NULL;
REQUEST	*request;
DELREQ	*delreq;
FILE	*log;
short	fsmounted = 0;	/* flag if fs mounted already */
short	debug = 1;
short	iso_9660 = 0;
short	foldcase = 0;

#define OLD_REQUEST	((OLD_REQ *)request)

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
    "Invalid permissions for operation",
};

extern char	*version;
extern char	*generate_key_filename();
extern char	*generate_sn_filename();
void	senderror();

/*
 * Find the pathname to the mount point of the passed in directory.
 * Return NULL if the file doesn't exist or isn't an absolute path.
 * (4/17/91 SCW -- NOT NECESSARILY... see below!)
 */
char	*GetMountPoint(path)
char	*path;
{
    dev_t	dev;
    char	*c;
    int	result = 0;
    static char	p[STRSIZ];
    extern char	*strrchr();
    struct stat	statbuf;
    
    if (path[0] != '/')
	return(NULL);
    
    strcpy(p, path);
	
    while ((*p != '\0') && 
	   (((result = stat(p, &statbuf)) < 0) && (errno == ENOENT))) {
	/* We can't simply return NULL if the file doesn't exist.
	 * If we're installing a new product, the destination directory
	 * won't be out there yet.  We still have to get its mount point,
	 * though.  So start taking things off the back until we DO
	 * have a directory that exists.  If we get all the way back to
	 * the beginning, or if stat() fails for some other reason, then
	 * we'll go ahead and return NULL.
	 */
	c = strrchr(p, '/');
	*c = '\0';
    }
    
    if (*p == '\0')		/* No element of the path existed at all */
	return(NULL);
    
    if ((result < 0) && (errno != ENOENT)) /* Some other stat() error */
	return(NULL);
    
    /* NOW we have remaining directory.   Let 'er rip */
    dev = statbuf.st_dev;
    
    for (;;) {
	c = strrchr(p, '/');
	*c = '\0';
	if (c == p)
	    stat("/", &statbuf);
	else
	    stat(p, &statbuf);
	if (statbuf.st_dev != dev)
	    break;
	else if (c == p) {
	    p[1] = '\0';
	    break;
	}
    }
    *c = '/';
    return(p);
}


/*
 * transmit buffer based on TCP or XNS (SNI)
 */
char	*tx(sk, buf)
int	sk;
char	*buf;
{
    int	i;
    extern void cleanup();
    
#ifdef XNS_NET
    if (net == XNS)
	return(sni_txw(&snid, buf, &xfersize, TIMEOUT));
    else {
	i = write(sk, buf, xfersize);
	if (i < 0 && errno == EPIPE) {
	    /*
	     * We lost our connection to the client, so exit.
	     * (Actually, the write() call should generate a SIGPIPE
	     * in this case, so this code is probably never used.)
	     */
	    PRDEBUG "** TX: lost connection to client.\n");
	    cleanup(SIGPIPE);
	}
	if (i == xfersize)
	    return(NULL);
	return("transmit error");
    }
#else
    i = write(sk, buf, xfersize);
    if (i < 0 && errno == EPIPE) {
	/*
	 * We lost our connection to the client, so exit.
	 * (Actually, the write() call should generate a SIGPIPE
	 * in this case, so this code is probably never used.)
	 */
	PRDEBUG "** TX: lost connection to client.\n");
	cleanup(SIGPIPE);
    }
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
    extern void cleanup();
    
#ifdef XNS_NET
    if (net == XNS)
	return(sni_rxw(&snid, buf, &xfersize, TIMEOUT));
    else {
	offset = 0;
	rsize = xfersize;
	while (rsize > 0) {
	    i = read(sk, buf + offset, rsize);
	    if (i < 0 && errno == ECONNRESET) {
		/*
		 * We lost our connection to the client, so exit.
		 */
		PRDEBUG "** RX: lost connection to client.\n");
		cleanup(SIGPIPE);
	    }
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
	if (i < 0  && errno == ECONNRESET) {
	    /*
	     * We lost our connection to the client, so exit.
	     */
	    PRDEBUG "** RX: lost connection to client.\n");
	    cleanup(SIGPIPE);
	}
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

/*
 * server accept code
 */
char	*saccept()
{
#ifdef HOSTS_ACCESS
    char		fullname[256];
    char		inetaddr[32];
    static struct sockaddr	sa;
    static struct sockaddr_in	*sin = (struct sockaddr_in *)(&sa);
    int			salen = sizeof(sa);
    struct hostent	*hp;
#endif

#ifdef XNS_NET
    if (net == XNS) {
	return(sni_accept(&snid));
    }
    else {
	PRDEBUG "getting first request\n");
	if (get_request(CLIENT_READ))
	    return("request error");
	
#ifdef HOSTS_ACCESS
	/*
	 *  Before we go any further, make sure
	 *  that the client is allowed to speak to us.
	 */
	if (getpeername(CLIENT_READ, &sa, &salen) < 0)
	    return("system error");

	fullname[0] = 0;
	strcpy(inetaddr, inet_ntoa(sin->sin_addr));

	if ((hp = gethostbyaddr((char *) (&sin->sin_addr.s_addr),
				sizeof(sin->sin_addr.s_addr),
				AF_INET))) {
	    strncpy(fullname, hp->h_name, sizeof(fullname) - 1);
	    fullname[sizeof(fullname) - 1] = 0;
	}

	syslog(LOG_INFO, "connect from %s (%s)", fullname, inetaddr);

	if (hosts_access(fullname, inetaddr) < 0) {
	    senderror(CLIENT_WRITE, ERR_PERM);
	    return("Connection refused.");
	}   
#endif

	if (request->req_type != DEFINE_USER)
	    return("invalid request");

	PRDEBUG "\trequest to define user\n");
	if (define_user())
	    return("account failed");
	else
	    return((char *)0);
    }
#else  /* not handling XNS networking at all */ 
    PRDEBUG "getting first request\n");
    if (get_request(CLIENT_READ))
        return("request error");

#ifdef HOSTS_ACCESS
    /*
     *  Before we go any further, make sure
     *  that the client is allowed to speak to us.
     */
    if (getpeername(CLIENT_READ, &sa, &salen) < 0)
	return("system error");

    fullname[0] = 0;
    strcpy(inetaddr, inet_ntoa(sin->sin_addr));

    if ((hp = gethostbyaddr((char *) &sin->sin_addr.s_addr,
			    sizeof(sin->sin_addr.s_addr),
			    AF_INET))) {

	strncpy(fullname, hp->h_name, sizeof(fullname) - 1);
	fullname[sizeof(fullname) - 1] = 0;
    }

    if (hosts_access(fullname, inetaddr) < 0) {
	senderror(CLIENT_WRITE, ERR_PERM);
	return("Connection refused.");
    }   
#endif
    if (ctohl(request->req_type) != DEFINE_USER)
	return("invalid request");

    PRDEBUG "\trequest to define user\n");
    if (define_user())
	return("account failed");
    else
    return((char *)0);
#endif
}

/*
 * server network closing code
 */
int	sclose()
{
#ifdef XNS_NET
    if (net == XNS)
	sni_close(&snid);
#endif
    /*
     * nothing special required to close a connection for sockets
     */
    return(0);
}

int     nabdrtran(tp)
struct tran_s *tp;
{
    int n, nbyte;
    int *kp;
    register i;
    register i2 = 0;
    char *base;

    if ((int)tp->buf & 3) {
        errno = EFAULT;
        return(-1);
    }
    base = (char *)tp->buf;
    n = (tp->bufcnt + 3) & ~3;
    nbyte = n;
    while (n > 0) {
        /*
         * Decode the page of data.
         */
        kp = (int *) base;
        for (i = 0; i < nbyte; i += 4, i2 += 4, kp++)
            *kp = htocl(ctohl(*kp) ^ (((tp->iproc + (i2 * i2)) |
                           0x94DA77A3) * 0xD4E6A91B));

        n -= nbyte;
        base += nbyte;
    }
    return (0);
}

void	senderror(sk, errorcode)
int	sk;
int	errorcode;
{
    reply->rep_type = htocl(REPLY_ERROR);
    reply->error = htocl(errorcode);
    xfersize = NETSIZE;
    tx(sk, (char *)reply);
}

/*ARGSUSED*/
int	get_request(sk)
int	sk;
{
    xfersize = sizeof(REQUEST);
    if ((err = rx(CLIENT_READ, (char *)request))){
	senderror(CLIENT_WRITE, ERR_RREQ); /* error in receiving request */
	return(1);
    }
    
    return(0);
}

char	*send_request(sk)
int	sk;
{
    xfersize = sizeof(REQUEST);
    request->req_len = (int)htocl(xfersize);
    if ((errstr = tx(sk, (char *)request))) {
	PRDEBUG "Transmit error: %s\n", errstr);
	return(errstr);
    }
    return(NULL);
}

int	define_user()
{
    char	*epw;
#if defined(SCO) && !defined(SecureWare)
    struct pr_passwd		*prpwd;
#endif
#if defined(SVR4) && defined(sun)
    struct spwd			*spw;
    extern struct spwd		*getspnam();
#endif
    struct passwd		*pw;
    extern struct passwd	*getpwnam();
    extern char			*crypt();
#ifdef SecureWare
    static struct sockaddr      sa;
    static struct sockaddr_in   *sin = (struct sockaddr_in *)(&sa);
    int                         salen = sizeof(sa);
    int                         attempts, max_tries, nopasswd;
    struct hostent              *hp;
#endif
    char                        *user, *password;
    int				anon_login = 0;
    
    is_su = 0;

    if (request->revision == 0) {
	user = OLD_REQUEST->prodname;
	password = OLD_REQUEST->prodnum;
    }
    else {
	user = request->prodname;
	password = request->prodnum;
    }
	
#ifdef DEBUG
    PRDEBUG "Attempting to verify user '%s'\n", user);
#endif

/*
 * Following section of code is used for systems that 
 * implement C2 security using the API provided by
 * SecureWare.  These systems include CLIX and SCO.
 */

#ifdef SecureWare
# ifdef SCO
    if (trustlevel_sco()) {
# else
    if (trustlevel()) {
# endif
	/*
	 * We're running in C2 mode.
         *
         * See if remote host is present in Terminal Control Database
         */

        getpeername(CLIENT_READ, &sa, &salen);

        hp = gethostbyaddr((char *)(&sin->sin_addr.s_addr),
                               sizeof(sin->sin_addr.s_addr),
                               AF_INET);
        if (!hp) {
            /*
             * gethostbyaddr() couldn't resolve remote address.
             */
            senderror(CLIENT_WRITE, ERR_USER);
            exit(1);
        }

        prtc = rhost_check(hp);
        if (!prtc) {
            /*
             *  host wasn't in Terminal Control Database
             *  audit record has already been entered.
             */
            senderror(CLIENT_WRITE, ERR_USER);
            exit(1);
        }

        /*
         * Get login account information from /etc/passwd and from
         * Protected Password Database.
         */
        pw = getpwnam(user);
        login_fillin_user(user, &prpwd, &pw);

        if (prpwd == (struct pr_passwd *) 0) {
            /*
             * No entry in protected password database
	     *
	     * Syntax of "audit_login" call is different on
	     * SCO and CLIX...
             */
# ifdef SCO
            audit_login((struct pr_passwd *) 0, (struct passwd *) 0,
		    user, ES_LOGIN_FAILED);
# else
            audit_login((struct pr_passwd *) 0, (struct passwd *) 0,
		    user, "No entry in protected password database",
		    ES_LOGIN_LOCAL, ES_LOGIN_FAILED);
# endif
            senderror(CLIENT_WRITE, ERR_USER);
            exit(1);
        }

        /*
         *  is account locked out, or user ID retired?
         *  (this also checks for too many failed attempts)
         */
        if (check_lock(prpwd)) {
            alt_login_bad_user(prpwd);
            senderror(CLIENT_WRITE, ERR_USER);
            exit(1);
        }

        /* Check password against protected database */
        if (!alt_login_validate(&prpwd, 0, &nopasswd, &password)) {
            /*
             *  verification failed.  alt_login_validate() has already
             *  called alt_login_bad_user(), which updates the count
             *  of failed login attempts.
             */
            senderror(CLIENT_WRITE, ERR_USER);
            exit(1);
        }

        /* password verified -- clear login attempt count*/
        want_a_timeout = 0;
        alt_login_user_ok_update_passwd_entry(&prpwd, pw);
        if (is_a_problem == 0x07) {
            senderror(CLIENT_WRITE, ERR_USER);
            exit(1);
        }
    }
    else {

	/*
	 * We're not running in C2 mode.
	 */

# ifdef SCO
	prpwd = getprpwnam(user);
        pw = getpwnam(user);

        if (pw == NULL && prpwd == NULL) {
            senderror(CLIENT_WRITE, ERR_USER); /* no such user on this system */
            return(1);
        }


	if (strcmp(user, "anonymous") == 0) {
	    /*
	     * In the case of the special user "anonymous",
	     * any password is acceptable.
	     * 
	     * But we also take the special step of checking
	     * the "home" directory of the account and
	     * performing a "chroot" to it.
	     */
	     anon_login = 1;
        }
	else {
	    /*
	     * verify the password, but only if there's one defined
	     */
	    if (pw->pw_passwd && pw->pw_passwd[0] != '\0') {
	      if ((strlen( pw->pw_passwd) == 1) && (pw->pw_passwd[0] == 'x')) {
		 if (prpwd->uflg.fg_encrypt && prpwd->ufld.fd_encrypt != '\0') {
		     epw = crypt(password, prpwd->ufld.fd_encrypt);
		     if (strcmp(epw, prpwd->ufld.fd_encrypt)) {
			   PRDEBUG "strcmp of epw failed 1.\n");
			   senderror(CLIENT_WRITE, ERR_USER); /* incorrect password */
			 return(1);
		      }
		 PRDEBUG "PW verified in SCO code.\n");
		 }
	      }
	      else {
		 epw = crypt(password, pw->pw_passwd);
		 if (strcmp(epw, pw->pw_passwd)) {
		     PRDEBUG "strcmp of epw failed 2.\n");
		     senderror(CLIENT_WRITE, ERR_USER); /* incorrect password */
		     return(1);
		 }
	      }
	   }
	   else {
	       PRDEBUG "PW failed at 3.\n");
	       senderror(CLIENT_WRITE, ERR_USER); /* incorrect password */
	       return(1);
	   }
       }
# else 	/* not SCO */
        pw = getpwnam(user);

        if (pw == NULL) {
            senderror(CLIENT_WRITE, ERR_USER); /* no such user on this system */
            return(1);
        }


	if (strcmp(user, "anonymous") == 0) {
	    /*
	     * In the case of the special user "anonymous",
	     * any password is acceptable.
	     * 
	     * But we also take the special step of checking
	     * the "home" directory of the account and
	     * performing a "chroot" to it.
	     */
	     anon_login = 1;
        }
	else {
	    /*
	     * verify the password, but only if there's one defined
	     */
	    if (pw->pw_passwd && pw->pw_passwd[0] != '\0') {
		epw = crypt(password, pw->pw_passwd);
		if (strcmp(epw, pw->pw_passwd)) {
		    senderror(CLIENT_WRITE, ERR_USER); /* incorrect password */
		    return(1);
		}
	    }
	}
# endif	/* SCO / !SCO */
     }
/*---*/
#else	/* !SecureWare */

/*
 * This code is for systems that are NOT using the SecureWare
 * C2 API.
 */
#  ifdef SCO
    pw = getpwnam(user);
    prpwd = getprpwnam(user);
    if (pw == NULL && prpwd == NULL) {
	senderror(CLIENT_WRITE, ERR_USER); /* no such user on this system */
	return(1);
    }


    if (strcmp(user, "anonymous") == 0) {
	/*
	 * In the case of the special user "anonymous",
	 * any password is acceptable.
	 * 
	 * But we also take the special step of checking
	 * the "home" directory of the account and
	 * performing a "chroot" to it.
	 */
	 anon_login = 1;
    }
    else {
	/*
	 * verify the password, but only if there's one defined
	 */
	if (pw->pw_passwd && pw->pw_passwd[0] != '\0') {
	    if ((strlen( pw->pw_passwd) == 1) && (pw->pw_passwd[0] == 'x')) {
	       if (prpwd->uflg.fg_encrypt && prpwd->ufld.fd_encrypt != '\0') {
		   epw = crypt(password, prpwd->ufld.fd_encrypt);
		   if (strcmp(epw, prpwd->ufld.fd_encrypt)) {
		       PRDEBUG "strcmp of epw failed 2.\n");
		       senderror(CLIENT_WRITE, ERR_USER); /* incorrect password */
		       return(1);
		    }
	       }	
	    }
	    else {
		epw = crypt(password, pw->pw_passwd);
		if (strcmp(epw, pw->pw_passwd)) {
		    senderror(CLIENT_WRITE, ERR_USER); /* incorrect password */
		    return(1);
		}
	    }
	} 
	else {
	    senderror(CLIENT_WRITE, ERR_USER); /* incorrect password */
	    return(1);
	}
    }
#  elif defined(SVR4) && defined(sun)	/* Solaris 2.x */
    pw = getpwnam(user);
    if (pw == NULL) {
        senderror(CLIENT_WRITE, ERR_USER); /* no such user on this system */
        return(1);
    }

    spw = getspnam(user);
    if (spw == NULL) {
        senderror(CLIENT_WRITE, ERR_USER); /* no such user on this system */
        return(1);
    }
   

    if (strcmp(user, "anonymous") == 0) {
	/*
	 * In the case of the special user "anonymous",
	 * any password is acceptable.
	 * 
	 * But we also take the special step of checking
	 * the "home" directory of the account and
	 * performing a "chroot" to it.
	 */
	 anon_login = 1;
    }
    else {
	/*
	 * verify the password, but only if there's one defined
	 */
	if (spw->sp_pwdp && spw->sp_pwdp[0] != '\0') {
	    epw = crypt(password, spw->sp_pwdp);
	    if (strcmp(epw, spw->sp_pwdp)) {
		senderror(CLIENT_WRITE, ERR_USER); /* incorrect password */
		return(1);
	    }
	}
    }

#  else				/* CLIX, SunOS 4, IRIX 5.x, etc. */
    pw = getpwnam(user);
    if (pw == NULL) {
	senderror(CLIENT_WRITE, ERR_USER); /* no such user on this system */
	return(1);
    }
    

    if (strcmp(user, "anonymous") == 0) {
	/*
	 * In the case of the special user "anonymous",
	 * any password is acceptable.
	 * 
	 * But we also take the special step of checking
	 * the "home" directory of the account and
	 * performing a "chroot" to it.
	 */
	 anon_login = 1;
    }
    else {
	/*
	 * verify the password, but only if there's one defined
	 */
	if (pw->pw_passwd && pw->pw_passwd[0] != '\0') {
	    epw = crypt(password, pw->pw_passwd);
	    if (strcmp(epw, pw->pw_passwd)) {
		senderror(CLIENT_WRITE, ERR_USER); /* incorrect password */
		return(1);
	    }
	}
    }
#   endif	/* SCO / Solaris / other */
#endif /* SecureWare / !SecureWare */
    
    if (anon_login) {
	if (chroot(pw->pw_dir)!= 0) {
	    switch (errno) {
		case ENOTDIR:
		case ENOENT:
		case ENOLINK:
		case EMULTIHOP:
		    senderror(CLIENT_WRITE, ERR_STAT);
		    break;
		
		default:
		    senderror(CLIENT_WRITE, ERR_PERM);
		    break;
	    }
	    return(1);
	}
    }
    else
	chdir(pw->pw_dir);
    
    if (pw->pw_uid == 0)
	is_su = 1;
    
    reply->rep_type = htocl(NORMAL);
    xfersize = NETSIZE;
    tx(CLIENT_WRITE, (char *)reply);
    return(0);
}

void
get_verifier()
{
    extern void get_ring();
    char source_ring[STRSIZ];
    char ws_ring[STRSIZ];
    char *cp;

    sprintf(ws_ring, "/usr/tmp/%s%d", RING, getpid());

    if (access(ws_ring, R_OK) != 0) {
	/* prepare the load key verifier for use */
	sprintf(source_ring, "%s/%s%s", MNTDIR, RING, machine);	
	if (foldcase) {
	    for (cp = source_ring + strlen(MNTDIR); *cp; cp++)
		*cp = (foldcase == UPPER) ? toupper(*cp) : tolower(*cp);
	}
	get_ring(source_ring, ws_ring);
	chmod(ws_ring, 0500);
    }
}

int	verify_load_key()
{
    char		*keyf;
    FILE		*pfd;
    FILE		*f;
    static char		estr1[64];
    static char		estr2[64];
    static char		estr3[64];
    static char		estr4[320];
    static char		estr5[64];
    static char		estr6[64];
    static char		estr7[64];
    char		cmd[128]; 
    char		prodnum[32], prodpath[128],
   			 prodflags[32], loadkey[32], prodver[32];
    char		answer[128];
    char		timestr[32];
    char		custid[65];
    int			result;
    extern char		*crypt();
    extern int		errno;
    unsigned short 	authtyp;
    unsigned short 	evalsn=0;
    char		fname[256];
#if (defined(clipper) || defined(__clipper__)) && defined(SYSV)
    struct init_s 	init;
#endif

    reply->rep_type = htocl(NORMAL);
    reply->str[0] = 0;
    reply->owner = 0;
    if (request->revision == 0) {
	strcpy(prodnum, OLD_REQUEST->prodnum);
	strcpy(prodflags, OLD_REQUEST->prodflags);
	strcpy(prodpath, OLD_REQUEST->prodpath);
	strcpy(loadkey, OLD_REQUEST->loadkey);
	strcpy(prodver, "00.00.00.00");
    }
    else {
	strcpy(prodnum, request->prodnum);
	strcpy(prodflags, request->prodflags);
	strcpy(prodpath, request->prodpath);
	strcpy(loadkey, request->loadkey);
	strcpy(prodver, request->prodver);
	strcpy(custid, request->custid);
    }

    if (debug) {
	fprintf(log, "\tprodnum: %s\n", prodnum);
	fprintf(log, "\tprodver: %s\n", prodver);
	fprintf(log, "\tprodflags: %s\n", prodflags);
	fprintf(log, "\tprodpath: %s\n", prodpath);
	fprintf(log, "\tloadkey: %s\n", loadkey);
	fprintf(log, "\tcustid: %s\n", custid);
    }
    if (atoi(prodflags)) {
#if (defined(clipper) || defined(__clipper__)) && defined(SYSV)
	if (iso_9660) {
#ifdef OLD_LOADKEY_METHOD
	    get_verifier();
#endif

	    sprintf(estr1, "PRODNUMBER=%s", prodnum);
	    putenv(estr1); 
	    sprintf(estr2, "KDATA=%s", loadkey);
	    putenv(estr2);
	    sprintf(estr3, "FLAGS=%s", prodflags);
	    putenv(estr3);
	    sprintf(estr4, "KF=%s", prodpath);
	    putenv(estr4);
	    sprintf(estr5, "PRODVERSION=%s", prodver);
	    putenv(estr5);

	    if ((strlen(loadkey) == SNLEN) && (loadkey[0] == 'E' || loadkey[0] == 'e')) {
	    	sprintf(estr6, "CUSTID=%s", custid);
	    	putenv(estr6);
		sprintf(fname, "%s/%s", ingrhome, KEYSDIR);
	    	sprintf(estr7, "SWESRT=%s", fname);
	    	putenv(estr7);
		sprintf(fname, "%s/%s/%s", ingrhome, KEYSDIR, "cfg");
		if (access(fname, (R_OK | W_OK | X_OK)))
		    mkdir(fname, 0755);
		sprintf(fname, "%s/%s/%s/%s", ingrhome, KEYSDIR, "cfg","sf.dat");
		if ((f = fopen(fname, "r+")) == NULL)
		    if ((f = fopen(fname, "w+")) == NULL){ /* create the file */
	    		PRDEBUG "** Couldn't create Eval sf.dat\n" );
			return(-1);
		    }
		fclose(f);
		evalsn=1;	/* remember this*/
	    }
	    sprintf(timestr, "%d", time(0)/2);

#ifdef OLD_LOADKEY_METHOD
	    sprintf(cmd, "/usr/tmp/%s%d %s", RING, getpid(), crypt(timestr, "sw"));
#else
	    sprintf(cmd, "%s/%s %s", deltools_home, RING, crypt(timestr, "sw"));
#endif
	    if ((pfd = popen(cmd, "r")) == NULL) {
		PRDEBUG "\t** Could not verify: %s\n", sys_errlist[errno]);
		strcpy((char *)reply->str, "PIPE");
		goto send_key;
	    }
	    while ( fgets(answer, 128, pfd) != NULL) ;
	    result = (pclose(pfd) >> 8) & 0xff;
	    if ((strcmp(answer, "ERROR") == 0) || (result != 0)) {
		strcpy((char *)reply->str, answer);
	    }
	    else {
		/*
		 * use the owner field to send the decode salt
		 */
		reply->owner = atoi(answer);
	        if (strlen(loadkey) > 14) {
		    authtyp=0;
		    keyf = generate_key_filename(prodpath);
		}
		else {
		    authtyp=1;
		    keyf = generate_sn_filename(prodpath);
		}
	        if (keyf && !evalsn)
		   make_keyfile_entry(keyf, prodnum, prodver, loadkey, authtyp);
	    }
	}
	else {
	    if ((init.fd = open(prodpath, O_RDONLY)) == -1) {
		reply->str[0] = 2;
		goto send_key;
	    }
	    init.num = prodnum;
	    init.access = loadkey;
	    init.pflag = prodflags;
	    if (syscall(125, SINGRNABDRINIT, &init))
	      reply->str[0] = 1;
	    else {
		/*
		 * use the owner field to send the decode salt slot
		 */
		reply->owner = init.iproc;
	        if (strlen(loadkey) > 14) {
		    authtyp=0;
		    keyf = generate_key_filename(prodpath);
		}
		else {
		    authtyp=1;
		    keyf = generate_sn_filename(prodpath);
		}
	        if (keyf && !evalsn)
		   make_keyfile_entry(keyf, prodnum, prodver, loadkey, authtyp);
	    }
	    close(init.fd);
	}
#else /* not clipper, or not SYSV */
#  ifdef OLD_LOADKEY_METHOD
	get_verifier();
#  endif

	sprintf(estr1, "PRODNUMBER=%s", prodnum);
	putenv(estr1);
	sprintf(estr2, "KDATA=%s", loadkey);
	putenv(estr2);
	sprintf(estr3, "FLAGS=%s", prodflags);
	putenv(estr3);
	sprintf(estr4, "KF=%s", prodpath);
	putenv(estr4);
	sprintf(estr5, "PRODVERSION=%s", prodver);
	putenv(estr5);
	
	    if ((strlen(loadkey) == SNLEN) && (loadkey[0] == 'E' || loadkey[0] == 'e')) {
	    	sprintf(estr6, "CUSTID=%s", custid);
	    	putenv(estr6);
		sprintf(fname, "%s/%s", ingrhome, KEYSDIR);
	    	sprintf(estr7, "SWESRT=%s", fname);
	    	putenv(estr7);
		sprintf(fname, "%s/%s/%s", ingrhome, KEYSDIR, "cfg");
		if (access(fname, (R_OK | W_OK | X_OK)))
		    mkdir(fname, 0755);
		sprintf(fname, "%s/%s/%s/%s", ingrhome, KEYSDIR, "cfg","sf.dat");
		if ((f = fopen(fname, "r+")) == NULL)
		    if ((f = fopen(fname, "w+")) == NULL){ /* create the file */
	    		PRDEBUG "** Couldn't create Eval sf.dat\n" );
			return(-1);
		    }
		fclose(f);
		evalsn=1;	/* remember this*/
	    }

	sprintf(timestr, "%d", time(0)/2);

#  ifdef OLD_LOADKEY_METHOD
	sprintf(cmd, "/usr/tmp/%s%d %s", RING, getpid(), crypt(timestr, "sw"));
#  else
	sprintf(cmd, "%s/%s %s", deltools_home, RING, crypt(timestr, "sw"));
#  endif

	if ((pfd = popen(cmd, "r")) == NULL) {
	    PRDEBUG "\t** Could not verify: %s\n", sys_errlist[errno]);
	    strcpy((char *)reply->str, "PIPE");
	    goto send_key;
	}
	while ( fgets(answer, 128, pfd) != NULL) ;
	result = (pclose(pfd) >> 8) & 0xff;
	if ((strcmp(answer, "ERROR") == 0) || (result != 0)) {
	    strcpy((char *)reply->str, answer);
	}
	else {
	    /*
	     * use the owner field to send the decode salt
	     */
	    reply->owner = htocl(atoi(answer));
	        if (strlen(loadkey) > 14) {
		    authtyp=0;
		    keyf = generate_key_filename(prodpath);
		}
		else {
		    authtyp=1;
		    keyf = generate_sn_filename(prodpath);
		}
	        if (keyf && !evalsn)
	      	   make_keyfile_entry(keyf, prodnum, prodver, loadkey, authtyp);
	}
#endif
    }
    
    send_key:
    xfersize = 1024;
    tx(CLIENT_WRITE,(char *)reply);
    return(0);
}

int	send_version()
{
    if (request->revision == 0) {
	PRDEBUG "request->revision == 0.\n");
	strncpy(client_version, OLD_REQUEST->prodpath, VERSION_LEN);
	client_flags = ctohl(OLD_REQUEST->iproc);
    }
    else {
	PRDEBUG "request->revision !== 0.\n");
	strncpy(client_version, request->prodpath, VERSION_LEN);
	client_flags = ctohl(request->iproc);
    }
    PRDEBUG "\t** version: %s :\n", version);
    debug = client_flags & DEBUG;
    reply->rep_type = htocl(NORMAL);
    strcpy((char *)reply->str, version);
    xfersize = 1024;
    tx(CLIENT_WRITE, (char *)reply);
    return(0);
}

int	send_load_key()
{
    char	*keyf;
    char	prodflags[32], prodnum[32], prodver[32];
    unsigned short authtyp;
    int found = 0;
    reply->rep_type = htocl(NORMAL);
    reply->str[0] = '\0';

    if (request->revision == 0) {
	strcpy(prodflags, OLD_REQUEST->prodflags);
	strcpy(prodnum, OLD_REQUEST->prodnum);
	strcpy(prodver, "00.00.00.00");
    }
    else {
	strcpy(prodflags, request->prodflags);
	strcpy(prodnum, request->prodnum);
	strcpy(prodver, request->prodver);
    }

    if (atoi(prodflags)) {
	authtyp=0;
	if ((keyf = generate_key_filename(request->prodpath))) {
	    found = find_keyfile_entry(keyf, prodnum, prodver, reply->str, authtyp );
	}
	if (!found ) {
	    authtyp=1;
	    if ((keyf = generate_sn_filename(request->prodpath)))
		found = find_keyfile_entry(keyf, prodnum, prodver, reply->str, authtyp );
	}
    }
    if (!found)
	reply->str[0] = '\0';

    xfersize = 1024;
    tx(CLIENT_WRITE, (char *)reply);
    return(0);
}


send_load_key_filename()
{
    char	*keyf;

    if ((keyf = generate_key_filename(MNTDIR))) {
	PRDEBUG "\tkey filename: %s\n", keyf);
	PRDEBUG "\tCD-ROM volume: %s\n", cdrel);
	strcpy((char *)reply->str, keyf);
	strcpy((char *)(reply->str + strlen(keyf) + 1), cdrel);
	reply->rep_type = htocl(NORMAL);
	xfersize = 1024;
	tx(CLIENT_WRITE, (char *)reply);
	return;
    } 
    PRDEBUG "\tno key filename generated\n");
    senderror(CLIENT_WRITE, ERR_NOKEYFILE); /* no available key file */
}

send_sn_filename()
{
    char	*keyf;

    if ((keyf = generate_sn_filename(MNTDIR))) {
	PRDEBUG "\tserial number filename: %s\n", keyf);
	strcpy((char *)reply->str, keyf);
	reply->rep_type = htocl(NORMAL);
	xfersize = 1024;
	tx(CLIENT_WRITE, (char *)reply);
	return;
    } 
    PRDEBUG "\tno serial nnumber filename generated\n");
    senderror(CLIENT_WRITE, ERR_NOSNFILE); /* no available serial no file */
}

int	get_file_stats()
{
    struct stat	statbuf;
    char	*mountpoint;
    char	*cp;
    char	prodnum[32], prodflags[32], prodpath[128], prodname[10];
    
    mountpoint = GetMountPoint(request->prodpath);
    if (mountpoint && (strcmp(mountpoint, MNTDIR) == 0) &&
	iso_9660 && foldcase) {
	/* Get the portion of the pathname below the mount point
	 * of the CD/ROM and fold into uppercase, since ISO9660
	 * filesystem pathnames are all uppercase.
	 */
	for (cp = (request->prodpath + strlen(mountpoint)); *cp != '\0';
	     cp++)
	  *cp = (foldcase == UPPER) ? (char)toupper(*cp) : (char)tolower(*cp);
    }
    
    if (request->revision == 0) {
	strcpy(prodpath, OLD_REQUEST->prodpath);
	strcpy(prodnum, OLD_REQUEST->prodnum);
	strcpy(prodname, OLD_REQUEST->prodname);
	strcpy(prodflags, OLD_REQUEST->prodflags);
    }
    else {
	strcpy(prodpath, request->prodpath);
	strcpy(prodnum, request->prodnum);
	strcpy(prodname, request->prodname);
	strcpy(prodflags, request->prodflags);
    }

    if (debug) {
	fprintf(log, "\tsource filename: %s\n", prodpath);
	fprintf(log, "\tproduct number: %s\n", prodnum);
	fprintf(log, "\tproduct name: %s\n", prodname);
	fprintf(log, "\tflags: %s\n", prodflags);
    }
    
    if ((fd = open(prodpath, O_RDONLY)) == -1) {
	PRDEBUG "\t** Could not open %s: %s\n",
		prodpath, sys_errlist[errno]);
	senderror(CLIENT_WRITE, ERR_OPEN); /* cannot open source file */
	return(1);
    }
    
    if (fstat(fd, &statbuf) == -1) {
	PRDEBUG "\t** Could not stat() %s: %s\n",
		request->prodpath, sys_errlist[errno]);
	senderror(CLIENT_WRITE, ERR_STAT); /* cannot stat source file */
	return(1);
    }
    
    if (!statbuf.st_size) {
	PRDEBUG "\t** %s is a zero-length file.\n",
		request->prodpath);
	senderror(CLIENT_WRITE, ERR_ZERO); /* zero length file */
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



int	send_file()
{
    int	flg;
    int	rsize;
    int	cnt;
    int	offset;
    char	*buf;
    struct tran_s	tran;
    int	bytes_to_send, r_type;

    extern	unsigned int	checksum();
    
    if (request->revision == 0) {
	flg = atoi(OLD_REQUEST->prodflags);
	tran.iproc = ctohl(OLD_REQUEST->iproc);
    }
    else {
	flg = atoi(request->prodflags);
	tran.iproc = ctohl(request->iproc);
    }

    
    PRDEBUG "\tabout to send the file, prodflags = %d\n", flg);
    
    rsize = ctohl(reply->size);
    while (rsize != 0) {
	bytes_to_send = MIN(rsize, RBSIZE);
	r_type = (rsize == bytes_to_send ? LAST_BUFFER : NORMAL);
	reply->rep_type = htocl(r_type);
	
	if (debug) {
	    fprintf(log, "\tsending %d bytes\n", bytes_to_send);
	    fprintf(log, "\tLast buffer? %s == %d\n",
		    r_type == LAST_BUFFER ? "Yes" : "No",
		    r_type);
	}
	
	if (read(fd, (char *)reply->buf, bytes_to_send) != bytes_to_send) {
	    senderror(CLIENT_WRITE, ERR_READ); /* error in reading source file */
	    return(1);
	}
	
	if (flg) {
	    PRDEBUG "\tdecoding %d bytes\n", bytes_to_send);
	    tran.buf = reply->buf;
	    tran.bufcnt = bytes_to_send;
#if (defined(clipper) || defined(__clipper__)) && defined(SYSV)
	    if (iso_9660)
	        nabdrtran(&tran);
	    else
	        syscall(125, SINGRNABDRTRAN, &tran);
#else /* Sun */
	    nabdrtran(&tran);
#endif
	}
	
	/*
	 * buffer is 62k bytes big
	 * first one has reply data (1k) and 7k of data
	 * next have 8k of data
	 * last one has 7k of data, 1k at end unused
	 */
	
	if (!(client_flags & NOCHECKSUM))
	    reply->cksum = checksum(reply->buf, bytes_to_send);
	
	/*
	 * this call sends the 1k of reply data plus the first 15k
	 * of buffer data
	 */
	
	reply->size = htocl(bytes_to_send);
	xfersize = NETSIZE;
	tx(CLIENT_WRITE, (char *)reply);
	
	/*
	 * this call sends buffer data at 16k chunks except for the
	 * last one = 15k
	 */
	cnt = rsize;
	for (offset = 16; cnt > 0 && offset < 62; offset += 16) {
	    xfersize = (offset == 48 ? NETSIZE - 1024 : NETSIZE);
	    buf = (char *)reply + offset * 1024;
	    tx(CLIENT_WRITE, buf);
	    if (client_flags & MIN_16K)
	        cnt -= xfersize;
	}
	rsize -= bytes_to_send;
    }
    close(fd);
    PRDEBUG "\tfile sent\n");
    return(0);
}


/*
 * This routine is used by the remote_newprod function install_software()
 * to connect to other machines in order to retrieve their .defaults
 * files (if needed)
 */

#ifdef XNS_NET
int xns_connect(connstr)
char    *connstr;
{
    extern              char *my_decrypt();

    /*
     * try SNI -- will succeed on VMS and UNIX with XNS.
     */
    if (debug)
        fprintf(stderr, "Trying to connect via SNI\n");

    if ((errstr = sni_connect(&snid, connstr, 0, SERVER))) {
        PRDEBUG "SNI Connect to remote system failed: %s\n", errstr);
        return(-1);
    }
    net = XNS;
    return(snid);
}


int	net_connect(connstr)
char    *connstr;
{
    int			sk;
    struct sockaddr_in	server;
    struct servent	*sp;
    struct hostent	*hp;
    unsigned long	in;
    char    		*nodename, *username, *password;
    char    		*service;
    char		*xnserror;
    int			xns_installed = 0;
    struct stat		sbuf;
    

    if ((stat("/usr/lib/nodes", &sbuf) == 0) && S_ISDIR(sbuf.st_mode)) {
        if ((stat("/usr/ip32/inc", &sbuf) == 0) && S_ISDIR(sbuf.st_mode)) {
            xns_installed = 1;
        }
    }

    hp = NULL;
    /*
     *  parse the connect string and see if it resembles an internet address
     *  style
     */
    in = net_connstr_parse(connstr, &nodename, &username, &password);

    if (debug)
        fprintf(stderr, "Connecting to %s... ", nodename);
    if (in == 0) {
        return(xns_connect(connstr));
    }
    else {
	xnserror = errstr;
	/*
	 * try a TCP connect - first verify the service exists
	 * if the service doesn't exist, then error out with the inc error
	 */
	service = TCPSERVER;
	if (!(sp = getservbyname(service, NULL))) {
	    PRDEBUG "Could not obtain 'newprod' service.\n");
	    if (xns_installed)
		return(xns_connect(connstr));
	    else
		return(-1);
	}
    
	/*
	 * parse the connect string and see if it resembles an internet address
	 * style
	 */
	in = net_connstr_parse(connstr, &nodename, &username, &password);
    
	PRDEBUG "Trying to connect via TCP\n");
	
	if (in == 2 || in == 4) {
	    if (!(hp = (struct hostent *)calloc(sizeof(struct hostent), 1))) {
		PRDEBUG "Memory allocation failure\n");
		return(-1);
	    }
	    in = inet_addr(nodename);
	    errstr = (char *)&in;
	    hp->h_addr_list = &errstr;
	    hp->h_length = 4;
	    hp->h_addrtype = AF_INET;
	} else if (!(hp = gethostbyname(nodename))) {
	    PRDEBUG "gethostbyname failed on %s\n", nodename);
	    if (xns_installed)
		return(xns_connect(connstr));
	    else
		return(-1);
	}
	
#ifndef SYSV
	bzero((char *)&server, sizeof(server));
	bcopy((char *)hp->h_addr, (char *)&server.sin_addr, hp->h_length);
#else
	memset(&server, 0, sizeof(server));
	memcpy(&server.sin_addr, hp->h_addr, hp->h_length);
#endif
	server.sin_family = hp->h_addrtype;
	server.sin_port = sp->s_port;
    
	if ((sk = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
	    PRDEBUG "socket allocation failed\n");
	    if (xns_installed)
		return(xns_connect(connstr));
	    else
		return(-1);
	}
	
	if (connect(sk, (struct sockaddr *)&server, sizeof(server)) < 0) {
	    PRDEBUG "TCP connect failed\n");
	    if (xns_installed)
		return(xns_connect(connstr));
	    else
		return(-1);
	}
	
	/*
	 * send the username and password to the server and check for
	 * proper authentication
	 */
	if (!(request = (REQUEST *)calloc(1, sizeof(REQUEST)))) {
	    PRDEBUG "Memory allocation failure\n");
	    return(-1);
	}
	
	if (!(reply = (REPLY *)calloc(1, sizeof(REPLY)))) {
	    PRDEBUG "Memory allocation failure\n");
	    return(-1);
	}
	
	request->revision = 1;
	request->req_type = htocl(DEFINE_USER);
	strncpy(request->prodname, username, PRODNAME_LEN);
	strncpy(request->prodnum,  password, PRODNUM_LEN);
	
	PRDEBUG "Validating the username/password combination\n");
	if (!(errstr = send_request(sk))) {
	    xfersize = NETSIZE;
	    if ((errstr = rx(sk, (char *)reply))) {
		PRDEBUG "%s\n", errstr);
		return(-1);
	    }
	    
	    if (ctohl(reply->rep_type) == REPLY_ERROR) {
		PRDEBUG "%s\n", errval[ctohl(reply->error)]);
		return(-1);
	    }
	    else
	      return(sk);
	}
	PRDEBUG "%s\n", errstr);
	return(-1);
    }
}
#else
int	net_connect(connstr)
char	*connstr;
{
    int			sk;
    struct sockaddr_in	server;
    struct servent	*sp;
    struct hostent	*hp;
    unsigned long	in;
    char    		*nodename, *username, *password;
    char    		*service;
    char		*xnserror;
    
    xnserror = errstr;
    /*
     * try a TCP connect - first verify the service exists
     * if the service doesn't exist, then error out with the inc error
     */
    service = TCPSERVER;
    if (!(sp = getservbyname(service, NULL))) {
	PRDEBUG "Could not obtain 'newprod' service.\n");
	return(-1);
    }

    /*
     * parse the connect string and see if it resembles an internet address
     * style
     */
    in = net_connstr_parse(connstr, &nodename, &username, &password);

    PRDEBUG "Trying to connect via TCP\n");
    
    if (in == 2 || in == 4) {
	if (!(hp = (struct hostent *)calloc(sizeof(struct hostent), 1))) {
	    PRDEBUG "Memory allocation failure\n");
	    return(-1);
	}
	in = inet_addr(nodename);
	errstr = (char *)&in;
	hp->h_addr_list = &errstr;
	hp->h_length = 4;
	hp->h_addrtype = AF_INET;
    } else if (!(hp = gethostbyname(nodename))) {
	PRDEBUG "gethostbyname failed on %s\n", nodename);
	return(-1);
    }
    
#ifndef SYSV
    bzero((char *)&server, sizeof(server));
    bcopy((char *)hp->h_addr, (char *)&server.sin_addr, hp->h_length);
#else
    memset(&server, 0, sizeof(server));
    memcpy(&server.sin_addr, hp->h_addr, hp->h_length);
#endif
    server.sin_family = hp->h_addrtype;
    server.sin_port = sp->s_port;

    if ((sk = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
	PRDEBUG "socket allocation failed\n");
	return(-1);
    }
    
    if (connect(sk, (struct sockaddr *)&server, sizeof(server)) < 0) {
	PRDEBUG "TCP connect failed\n");
	return(-1);
    }
    
    /*
     * send the username and password to the server and check for
     * proper authentication
     */
    if (!(request = (REQUEST *)calloc(1, sizeof(REQUEST)))) {
	PRDEBUG "Memory allocation failure\n");
	return(-1);
    }
    
    if (!(reply = (REPLY *)calloc(1, sizeof(REPLY)))) {
	PRDEBUG "Memory allocation failure\n");
	return(-1);
    }
    
    request->revision = 1;
    request->req_type = htocl(	DEFINE_USER);
    strncpy(request->prodname, username, PRODNAME_LEN);
    strncpy(request->prodnum,  password, PRODNUM_LEN);
    
    PRDEBUG "Validating the username/password combination\n");
    if (!(errstr = send_request(sk))) {
	xfersize = NETSIZE;
	if ((errstr = rx(sk, (char *)reply))) {
	    PRDEBUG "%s\n", errstr);
	    return(-1);
	}
	
	if (ctohl(reply->rep_type) == REPLY_ERROR) {
	    PRDEBUG "%s\n", errval[ctohl(reply->error)]);
	    return(-1);
	}
	else
	  return(sk);
    }
    PRDEBUG "%s\n", errstr);
    return(-1);
}
#endif


int yydone;
#ifndef OSF
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
int	net_connstr_parse(connstr, node, user, pass)
char	*connstr, **node, **user, **pass;
{
    static char	p_nn[128];
    static char	p_un[32];
    static char	p_pw[768];
    int	result;
    
    *node = p_nn;
    *user = p_un;
    *pass = p_pw;
    
#ifndef OSF
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
    strcpy(*node, conn.node);
    strcpy(*user, conn.user);
    strcpy(*pass, conn.pass);

    return(addrtype);
}


/*
 * The routines "receive_file" and "net_receive" are adapted from the client-side
 * code in "newprod."  It is used here to request model files from other machines
 * to perform remote_newprod installations.
 */

char	*receive_file(sk, fd)
int	sk;
int	fd;
{
    char		*buf;
    unsigned int	rsize;
    int			cnt;
    int			offset;

#ifdef CHECKSUM
    unsigned int	rcvd_cksum = 0;
#endif

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

	rsize = MIN(ctohl((unsigned long)reply->size), RBSIZE);

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
    return(0);
}


int	net_receive(src, dest, sko, ski)
char	*src, *dest;
int	sko, ski;
{
    int	rfile = 0;
    int	ofd;
    struct utimbuf utim;

    strcpy(request->prodpath, src);
    
    if (dest[0] == '-')
      ofd = 1;	/* output file is stdout */
    else {
	if ((ofd = open(dest, O_WRONLY|O_CREAT|O_TRUNC, 0664)) == -1) {
	    PRDEBUG "Cannot create/write file\n");
	    return(-1);
	}
	++rfile;
    }

    if (request->revision == 0)
	strncpy(OLD_REQUEST->prodflags, "0", FLAGS_LEN);
    else
	strncpy(request->prodflags, "0", FLAGS_LEN);
    
    request->req_type = htocl((unsigned long)RECEIVE_FILE);
    
    if ((errstr = send_request(sko))) {
	PRDEBUG "%s\n", errstr);
	return(-1);
    }
    else {
	PRDEBUG "Receiving %s\n", src);
	if ((errstr = receive_file(ski, ofd))) {
	    PRDEBUG "%s\n", errstr);
	    return(-1);
	}
    }
    
    if (rfile) {
	close(ofd);
	chmod(dest, (mode_t)ctohl((unsigned long)reply->mode));
	chown(dest, (uid_t)ctohl((unsigned long)reply->owner), (gid_t)ctohl((unsigned long)reply->group));
	utim.actime = ctohl((unsigned long)reply->atime);
	utim.modtime = ctohl((unsigned long)reply->mtime);
	utime(dest, &utim);
    }
    
    return('\0');
}


/*
 * A variation of the system() function call, except we'll use
 * ksh (if it's available) to run the command.
 */

int	mysystem(cmd)
char	*cmd;
{
    int pid, w;
    int status;
    char *shellname;
    char *args[8];
    
    shellname = strrchr(shell, '/') + 1;
    args[0] = shell;
    args[1] = shellname;
    args[2] = "-c";
    args[3] = cmd;
    args[4] = NULL;
    
    if ((pid = fork()) == 0) {
	execlp(shell, shellname, "-c", cmd, NULL);
	_exit(127);
    }
    else if (pid > 0) {
	while ((w = wait( &status )) != pid && w != -1) {
	    if (w == -1 && errno == EINTR)
	      continue;
	}
	if (w == -1)
	  return(-1);
	else
	  return(status);
    }
    else
      return(-1);
return(0);
}


/*
 * This procedure coordinates with the new remote_newprod program to 
 * perform software installation from remote locations.  remote_newprod
 * connects to the DELSERVE process on this machine and sends a request
 * packet that details the software to be loaded.  The procedure brings
 * over "model" files (pre-configured defaults for getanswer) if needed,
 * constructs and executes the "newprod" command line, and transfers
 * the log of the installation session back to the controlling system.
 */
int	install_software()
{
    char command[512];
    char lfile[256];
    char mfile[256];
    char srcfile[256];
    static char envstr[256];
    int result;
    int sk, ofd;
    struct utsname un;
    
    /*
     * Send a positive response back to the other side --
     * We can do software installations.
     */
    
    PRDEBUG "\t Sending positive acknowledgement\n");
    reply->rep_type = htocl(NORMAL);
    reply->error = 0;
    xfersize = NETSIZE;
    tx(CLIENT_WRITE, (char *)reply);

    /* 
     * Receive the special software installation request structure
     */
    PRDEBUG "\t Waiting for delivery request...\n");
    xfersize = sizeof(DELREQ);
    if (err = rx(CLIENT_READ, (char *)delreq)) {
        senderror(CLIENT_WRITE, ERR_RREQ);
        return(1);
    }

    /*
     * Set up the command
     */
    PRDEBUG "Request to install products:\n");
    PRDEBUG "MEDIA\t\t=\t\t%s\n", ((ctohl(delreq->media) == DISK) ? "DISK" : "CDROM"));
    PRDEBUG "LOGWHERE\t=\t\t%s\n", delreq->logwhere);
    PRDEBUG "PRODUCTS\t=\t\t%s\n", delreq->products);
    PRDEBUG "REBOOT\t\t=\t\t%s\n", (ctohl(delreq->reboot) ? "YES" : "NO"));
    PRDEBUG "SERVER\t\t=\t\t%s\n", delreq->server);
    PRDEBUG "MODEL\t\t=\t\t%s\n", delreq->model);
    PRDEBUG "FILESYSTEM\t=\t\t%s\n", delreq->filesystem);
    sprintf(lfile, "/usr/spool/r.log.%d", getpid());
    sprintf(command, "echo \"Newprod started at `date`\" > %s", lfile);
    system(command);

    if (delreq->model[0] ) {
	/*
	 * If modelfile exists, get it.  MODEL can be either a pathname
	 * (to be obtained from the server), or a node.user.pass tuple
	 * (specifying a different machine to get the file from)
	 */

	sprintf(mfile, "/tmp/defaults.%d", getpid());
	if ((ofd = open(mfile, O_WRONLY|O_CREAT|O_TRUNC, 0777)) < 0) {
	    PRDEBUG "** Open of local modelfile failed: %s\n", 
				sys_errlist[errno]);
	    return(-1);
	}

	if (strchr(delreq->model, '/') != NULL) {
	    /*
	     * The presence of the '/' separator indicates that the modelfile is
	     * on the node controlling the installation.  Request the named
	     * file from them.
	     */
	    receive_file(CLIENT_READ, ofd);
        }
        else {
            /*
	     * Connect to the system named, and get its "/usr/ingr/.defaults"
	     * file
	     *
	     * Since net_connect will possibly change the values of the "net"
	     * flag and "snid" descriptor, we'd better save off the ones
	     * we're using now.
	     */
	    tmpnet = net;
	    tmpsnid = snid;
	    sk = net_connect(delreq->model);
	    if (sk < 0) {
		PRDEBUG "Could not connect to remote system for model file.\n");
	        senderror(CLIENT_WRITE, ERR_READ);
		net = tmpnet;
		snid = tmpsnid;
		return(-1);
            }
	    sprintf(srcfile, "%s/.defaults", BASEDIR);
	    net_receive(srcfile, mfile, sk, sk);
	    request->req_type = htocl((unsigned long) END_CONNECTION);
	    send_request(sk);
#ifdef XNS_NET
	    if (net == TCP)
		close(sk);
	    else
		sni_close(&snid);
#else
	    close(sk);
#endif
	    net = tmpnet;
	    snid = tmpsnid;
	}
	close(ofd);
	sync();
	sync();
	sprintf(command, "/bin/cat %s %s/.defaults > /usr/tmp/defaults.%d", mfile, BASEDIR, getpid());
	PRDEBUG "About to execute command '%s'\n", command);
	mysystem(command);
	sprintf(envstr, "ANSWERS=/usr/tmp/defaults.%d", getpid());
	putenv(envstr);
    }

    /*
     * Construct the command line and run it.
     */
#if defined(SVR4) && defined(NEWDIRS)
    sprintf(command, "%s/bin/newprod %s -y%c %s %s >> %s 2>&1 < /dev/null",
	    ingrhome, delreq->filesystem, ctohl(delreq->media), delreq->server,
	    delreq->products, lfile);
#else
    sprintf(command, "/usr/bin/newprod %s -y%c %s %s >> %s 2>&1 < /dev/null",
	    delreq->filesystem, ctohl(delreq->media), delreq->server,
	    delreq->products, lfile);
#endif
    mysystem(command);
    
    sprintf(command, "echo \"Newprod completed at `date`\" >> %s", lfile);
    system(command);

    if (delreq->model[0]) {
	/*
	 * Save the old defaults file and make the new one permanent.
	 */
	sprintf(command, "mv %s/.defaults %s/.defaults.old", BASEDIR, BASEDIR);
	system(command);
	sprintf(command, "mv /usr/tmp/defaults.%d %s/.defaults", getpid(), BASEDIR);
	system(command);
    }

    /* 
     * If logfile is set, 
     * Transfer logfile back to server.  LOGWHERE can be either the
     * name of a directory on the server where the file should be
     * transferred, or a mailpath specifying a recipient for the
     * file.
     */
    reply->rep_type = htocl(NORMAL);
    reply->error = 0;
    if (strchr(delreq->logwhere, '/')) {
	/*
	 * The LOGWHERE keyword has specified a directory
	 * on the server
	 */
	strcpy((char *)reply->str, lfile);

	xfersize = NETSIZE;
	if ((err = tx(CLIENT_WRITE, (char *)reply))) {
	    PRDEBUG "** Couldn't send reply back!\n");
            return(-1);
        }
        /*
	 * Wait for the other end to ask for the file
	 */
        get_request(CLIENT_READ);
        if (ctohl(request->req_type) != RECEIVE_FILE) {
	    PRDEBUG "** Response received was out of phase!\n");
	    return(-1);
	}
	if (!get_file_stats())
	    send_file();
    }
    else {
	/*
	 * If the LOGWHERE keyword has specified a mailpath, use
	 * it.  Otherwise, mail it to root locally.
	 */
	reply->str[0] = '\0';
	uname(&un);
	if (*delreq->logwhere == '\0')
	    strcpy(delreq->logwhere, "root");
	sprintf(command, "%s -s \"newprod log of %s\" %s < %s > /dev/null 2> /dev/null",
		MAILER, un.nodename, delreq->logwhere, lfile);
	result = (system(command) >> 8) & 0xff;
	if (result == 0)
	    unlink(lfile);
	xfersize = NETSIZE;
	if ((err = tx(CLIENT_WRITE, (char *)reply))) {
	    PRDEBUG "** Couldn't send reply back!\n");
            return(-1);
        }
    }

    /*
     * Clean up and exit.  If the REBOOT flag is turned on, do that.
     */ 
    if (ctohl(delreq->reboot)) {
	PRDEBUG "Preparing to reboot system.\n");
	sync();
	sync();
/*  Added for HP -- 30 Apr 1994 */
#ifdef HP_UX
	execl("/etc/shutdown", "shutdown", "-r", "300", (char *)0);
#endif
#ifdef SVR3
	execl("/bin/sh", "sh", "-c", "/etc/shutdown -y -g300 -i6 < /dev/console > /dev/console 2>&1", (char *)0);
#endif
#ifdef SunOS_4
	execl("/usr/etc/shutdown", "shutdown", "-r", "+5", (char *)0);
#endif
#ifdef OSF
	execl("/sbin/shutdown", "shutdown", "-r", "+5", (char *)0);
#endif
#ifdef _AIX
#endif
        PRDEBUG "** Could not reboot system -- %s\n", sys_errlist[errno]);
	return(-1);
    }
    return(0);
}


int	copy_file(infile, outfile, salt)
char *infile;
char *outfile;
unsigned int	salt;
{
    int			inf, outf;
    int			rcount;
    char		*buf, *bp;
    struct utimbuf	times;
    struct stat		statbuf;
    
    if ((inf = open(infile, O_RDONLY)) < 0) {
	return(1);
    }
    
    if (fstat(inf, &statbuf)) {
	PRDEBUG "Cannot stat %s.\n", infile);
	close(inf);
	return(1);
    }
    
    if ((outf = creat(outfile, statbuf.st_mode)) < 0) {
	PRDEBUG "Cannot open %s for writing.\n", outfile);
	close(inf);
	return(1);
    }
    
    buf = (char *)malloc(62*1024);
    while ((rcount = read(inf, buf, 62*1024)) > 0) {
	if (salt) {
	    for (bp = buf; bp < (buf+rcount); bp += 4)
		*((unsigned int *)bp) ^= salt;
	}
	if (write(outf, buf, rcount) != rcount) {
	    free(buf);
	    close(inf);
	    close(outf);
	    return(-1);
	}
    }
    free(buf);
    close(inf);
    close(outf);
    times.actime = statbuf.st_atime;
    times.modtime = statbuf.st_mtime;
    utime(outfile, &times);
    chown(outfile, statbuf.st_uid, statbuf.st_gid);
    if (rcount < 0)
	return(-1);
    return(0);
}

void    get_ring(source_file, dest_file)
char    *source_file;
char    *dest_file;
{
    int fd;
    unsigned short magic;

    if ((fd = open(source_file, O_RDONLY)) < 0)
        return;
    else {
        /* Snip the magic number out of the file */
        read(fd, (char *)&magic, sizeof magic);
        close(fd);

        /* If it corresponds to the valid magic number for
         * one of our executables, then copy it directly.
         * Otherwise, it's been stored in encrypted form,
         * and we need to decode it as we copy it down.
         */

        if (magic == ARCH_MAGIC)
            copy_file(source_file, dest_file, 0);
	else
            copy_file(source_file, dest_file, SLOT);
    }
}


/*
 * make sure we have access to the file. If not then try mounting the CDROM
 * and trying again.
 */

#if defined(SVR3) || defined(sgi)
void determine_fs_type()
{
    char	source_ring[STRSIZ];
    char	*cp;
    struct statfs stbuf;
    char	fstype[16];

#ifdef sgi
    statfs(MNTDIR, &stbuf, sizeof(struct statfs), 0);
    if (sysfs(GETFSTYP, stbuf.f_fstyp, fstype) < 0) {
	iso_9660=1;
	putenv("ISO9660=Y");
	foldcase=LOWER;
    }
#else
    statfs(MNTDIR, &stbuf, sizeof(struct statfs), 0);
    sysfs(GETFSTYP, stbuf.f_fstyp, fstype);

    if (strncmp(fstype, "CDFS", 4) == 0 ||
	strncmp(fstype, "HS", 2) == 0) {
	iso_9660 = 1;
	putenv("ISO9660=Y");
	    
	/*
	 * Since it's an ISO9660 file system, then file names
	 * are stored in ALL CAPS.  SunOS can cover the difference,
	 * but CLIX can't.
	 * For now, we'll see if we have to fold filenames
	 * to all caps ourselves.
	 */
	sprintf(source_ring, "%s/ws_s.prods", MNTDIR);
	if (access(source_ring, R_OK) != 0) {
	    /* lower case access failed */
	    for (cp = source_ring + strlen(MNTDIR); *cp; cp++)
	      *cp = toupper(*cp);
	    
	    if (access(source_ring, R_OK) == 0) {
		foldcase = UPPER;
		putenv("FOLDCASE=UPPER");
	    }
	    else {
		/*
		 * Neither "ws_s.prods" nor "WS_S.PRODS" were found.
		 * This could be a disc of VAX products.  Look for
		 * "vax.prods" or "VAX.PRODS" -- scw, 4/21/92
		 */
		sprintf(source_ring, "%s/vax.prods", MNTDIR);
		if (access(source_ring, R_OK) != 0) {
		    /* lower case access failed */
		    for (cp = source_ring + strlen(MNTDIR); *cp; cp++)
		      *cp = toupper(*cp);
		    
		    if (access(source_ring, R_OK) == 0) {
			foldcase = UPPER;
			putenv("FOLDCASE=UPPER");
		    }
		    else 
		        PRDEBUG "NOTE: Could not find either ws_s.prods or vax.prods\n");
		}
	    }
	}
	    else {
#if defined(sgi) || defined(SCO)
		foldcase = LOWER;
		putenv("FOLDCASE=LOWER");
#else
		foldcase = 0;
#endif
	}
    }
    else { 
	iso_9660 = 0;
	foldcase = 0;
    }
#endif
}

int	mountfsys()
{
    extern int	errno;
    char	source_ring[STRSIZ];
    char	ws_ring[STRSIZ];
#ifdef sgi
    static char	*fstypes[3] = {"iso9660", "efs", ""};
    char        command[160], buf[160];
    int		mount_error;
    FILE        *sfd;
    char        mdev[64], mpoint[64], mtype[64], mflags[64],
    				mcheck[4], mseq[4];
#elif defined(__clipper__) || defined(clipper)
    char	*fstypes[5] = {"FFS", "CDFS", "S51K", ""};
#elif defined(SCO)
    char        *fstypes[5] = {"HS", "S51K", "S52K", ""};
#endif
    int		fsindex, fstyp;
    char	*cp;
    
    /*
     * if file's path isn't on MNTDIR, then return ok -- no need to mount
     * the CDROM
     */
    if (strncmp(request->prodpath, MNTDIR, strlen(MNTDIR)))
      return(0);
    
#ifndef sgi
    /*
     * If the file is readable, then assume file system has been mounted
     * We need to see if it's on an ISO9660 disc, though.
     */

    if (!access(request->prodpath, R_OK) || fsmounted) {
	determine_fs_type();
	return(0);
    }
#else
    /*
     * Because the method SGI uses to mount ISO9660 CD-ROMs 
     * doesn't work when you've been spawned by inetd (go figure),
     * the CD-ROM has to be mounted manually BEFORE anyone
     * tries to connect to "delserve" to deliver products.
     * So we know what the file system configuration is like.
     */
    iso_9660=1;
    putenv("ISO9660=Y");
    foldcase=LOWER;
    return(0);
#endif 


    /*
     * try mounting CDROM as FFS first
     */
    PRDEBUG "\tMounting the CDROM\n");
    
    for (fsindex = 0; *fstypes[fsindex] != '\0' && !fsmounted; fsindex++) {

#ifdef sgi
        if (fsindex == 0) {
            sfd = fopen("/etc/mtab", "r");
            while (fscanf(sfd,"%s %s %s %s %s %s\n",
                mdev, mpoint, mtype, mflags, mcheck, mseq) != EOF) {
                if ((strcmp(CDROM_DEVICE, mdev) == 0) &&
			      (strcmp(MNTDIR, mpoint) == 0)) {
		    if (strcmp(mtype, "iso9660") == 0) {
			iso_9660 = 1;
			putenv("ISO9660=Y");
		    }
                    fsmounted++;
                }
            }
            fclose(sfd);

	    if (!fsmounted) {
		sprintf(command, "/etc/mount -r -t %s %s %s 2>&1",
			fstypes[fsindex], CDROM_DEVICE, MNTDIR);
		PRDEBUG "\tcommand: %s\n", command);
		mount_error = 0;
		if ((sfd = popen(command, "r")) != NULL) {
		    while (fgets(buf, sizeof(buf), sfd) != NULL) {
			mount_error = 1;
			PRDEBUG "\tMount error: %s\n", buf);
		    }
		    pclose(sfd);
		}

		if (mount_error) {
		    continue;
		}
		else {
		    iso_9660 = 1;
		    putenv("ISO9660=Y");
		    break;
		}
	    }
        }
        else {
#endif
	fstyp = sysfs(GETFSIND, fstypes[fsindex]);

	if (mount(CDROM_DEVICE, MNTDIR, MS_FSS | 1, fstyp, 0, 0)) {
	    PRDEBUG "\t%s mount failed: %s\n", fstypes[fsindex],
					 sys_errlist[errno]);
	    if (errno == EBUSY) {
		/* it's already mounted 
		 * So we won't diddle with fsmounted, but we need to know
		 * if it's an ISO9660 file system or not.
		 */
		determine_fs_type();
		    
#ifdef OLD_LOADKEY_METHOD
		/* prepare the load key verifier for use */
		sprintf(source_ring, "%s/%s%s", MNTDIR, RING, machine);
		if (foldcase) {
		    for (cp = source_ring + strlen(MNTDIR); *cp; cp++)
		    *cp = (foldcase == UPPER) ? toupper(*cp) : tolower(*cp);
		}
	        sprintf(ws_ring, "/usr/tmp/%s%d", RING, getpid());
		unlink(ws_ring);
		get_ring(source_ring, ws_ring);
		chmod(ws_ring, 0500);
#endif
		return(0);
	    }
        }
	else
	    break;
    }
#ifdef sgi
    }
#endif

    if (*fstypes[fsindex] == '\0') {
	senderror(CLIENT_WRITE, ERR_MOUNT); /* cdrom mount */
	return(1);
    }
    else {
	PRDEBUG "\tCDROM Mounted successfuly\n");
	/* We did the mounting */
	fsmounted++;
	if (strcmp(fstypes[fsindex], "CDFS") == 0 ||
		strcmp(fstypes[fsindex], "iso9660") == 0 ||
		strcmp(fstypes[fsindex], "HS") == 0) {
    	    iso_9660 = 1;
	    putenv("ISO9660=Y");
	    
	    /*
	     * Since it's an ISO9660 file system, then file names
	     * are stored in ALL CAPS.  SunOS can cover the difference,
	     * but CLIX can't.
	     * For now, we'll see if we have to fold filenames
	     * to all caps ourselves.
	     */
	    sprintf(source_ring, "%s/ws_s.prods", MNTDIR);
	    if (access(source_ring, R_OK) != 0) {
		/* lower case access failed */
		for (cp = source_ring + strlen(MNTDIR); *cp; cp++)
		  *cp = toupper(*cp);
		
		if (access(source_ring, R_OK) == 0) {
		    foldcase = UPPER;
		    putenv("FOLDCASE=UPPER");
		}
		else {
		    /*
		     * Neither "ws_s.prods" nor "WS_S.PRODS" were found.
		     * This could be a disc of VAX products.  Look for
		     * "vax.prods" or "VAX.PRODS" -- scw, 4/21/92
		     */
		    sprintf(source_ring, "%s/vax.prods", MNTDIR);
		    if (access(source_ring, R_OK) != 0) {
			/* lower case access failed */
			for (cp = source_ring + strlen(MNTDIR); *cp; cp++)
			  *cp = toupper(*cp);
		    
			if (access(source_ring, R_OK) == 0) {
			    foldcase = UPPER;
			    putenv("FOLDCASE=UPPER");
			}
			else 
			    PRDEBUG "NOTE: Could not find either ws_s.prods or vax.prods\n");
		    }
		}
	    }
	    else {
#if defined(sgi) || defined(SCO)
		foldcase = LOWER;
		putenv("FOLDCASE=LOWER");
#else
		foldcase = 0;
#endif
	    }
	    
#ifdef OLD_LOADKEY_METHOD
	    /* prepare the load key verifier for use */
	    sprintf(source_ring, "%s/%s%s", MNTDIR, RING, machine);
	    if (foldcase) {
		for (cp = source_ring + strlen(MNTDIR); *cp; cp++)
		  *cp = (foldcase == UPPER) ? toupper(*cp) : tolower(*cp);
	    }
	    sprintf(ws_ring, "/usr/tmp/%s%d", RING, getpid());
	    unlink(ws_ring);
	    get_ring(source_ring, ws_ring);
	    chmod(ws_ring, 0500);
#endif
	}
	else if (strcmp(fstypes[fsindex], "FFS") == 0) {
	    iso_9660 = 0;
	    foldcase = 0;
	}
	return(0);
    }
}
#endif

#if defined(SVR4) && !defined(sgi)
void determine_fs_type()
{
    char	source_ring[STRSIZ];
    char	*cp;
    struct statvfs stbuf;
    char	fstype[16];

    statvfs(MNTDIR, &stbuf);
    if (strncmp(stbuf.f_basetype, "hsfs", 4) == 0) {
	iso_9660 = 1;
	putenv("ISO9660");
	    
	/*
	 * Since it's an ISO9660 file system, then file names
	 * are stored in ALL CAPS.  SunOS covers the difference
	 * by default,  but CLIX doesn't (mount-time option).
	 * For now, we'll see if we have to fold filenames
	 * to all caps ourselves.
	 */
	sprintf(source_ring, "%s/ws_s.prods", MNTDIR);
	if (access(source_ring, R_OK) != 0) {
	    /* lower case access failed */
	    for (cp = source_ring + strlen(MNTDIR); *cp; cp++)
	      *cp = toupper(*cp);
	    
	    if (access(source_ring, R_OK) == 0) {
		foldcase = UPPER;
		putenv("FOLDCASE=UPPER");
	    }
	    else {
		/*
		 * Neither "ws_s.prods" nor "WS_S.PRODS" were found.
		 * This could be a disc of VAX products.  Look for
		 * "vax.prods" or "VAX.PRODS" -- scw, 4/21/92
		 */
		sprintf(source_ring, "%s/vax.prods", MNTDIR);
		if (access(source_ring, R_OK) != 0) {
		    /* lower case access failed */
		    for (cp = source_ring + strlen(MNTDIR); *cp; cp++)
		      *cp = toupper(*cp);
		    
		    if (access(source_ring, R_OK) == 0) {
			foldcase = UPPER;
			putenv("FOLDCASE=UPPER");
		    }
		    else 
			PRDEBUG "NOTE: Could not find either ws_s.prods or vax.prods\n");
		}
	    }
	}
	else  {
#if defined(SCO) || defined(sgi)
	    foldcase = LOWER;
	    putenv("FOLDCASE=LOWER");
#else
	    foldcase = 0;
#endif
    }
    }
    else { 
	iso_9660 = 0;
	foldcase = 0;
    }
}

int	mountfsys()
{
    extern int	errno;
    char	source_ring[STRSIZ];
    char	ws_ring[STRSIZ];
    char	*fstypes[5] = {"ufs", "hsfs", ""};
    int		fsindex, fstyp;
    char	*cp;
    
    /*
     * if file's path isn't on MNTDIR, then return ok -- no need to mount
     * the CDROM
     */
    if (strncmp(request->prodpath, MNTDIR, strlen(MNTDIR)))
      return(0);
    
    /*
     * If the file is readable, then assume file system has been mounted
     * We need to see if it's on an ISO9660 disc, though.
     */
    if (!access(request->prodpath, R_OK)) {
	determine_fs_type();
	return(0);
    }
    
    /*
     * try mounting CDROM as FFS first
     */
    PRDEBUG "\tMounting the CDROM\n");
    
    for (fsindex = 0; *fstypes[fsindex] != '\0'; fsindex++) {
	fstyp = sysfs(GETFSIND, fstypes[fsindex]);
	if (mount(CDROM_DEVICE, MNTDIR, (MS_FSS | 1), fstyp, 0, 0)) {
	    PRDEBUG "\t%s mount failed: %s\n", fstypes[fsindex],
					 sys_errlist[errno]);
	    if (errno == EBUSY) {
		/* it's already mounted 
		 * So we won't diddle with fsmounted, but we need to know
		 * if it's an ISO9660 file system or not.
		 */
		determine_fs_type();
		    
#ifdef OLD_LOADKEY_METHOD
		/* prepare the load key verifier for use */
		sprintf(source_ring, "%s/%s%s", MNTDIR, RING, machine);
		if (foldcase) {
		    for (cp = source_ring + strlen(MNTDIR); *cp; cp++)
		    *cp = (foldcase == UPPER) ? toupper(*cp) : tolower(*cp);
		}
	        sprintf(ws_ring, "/usr/tmp/%s%d", RING, getpid());
		unlink(ws_ring);
		get_ring(source_ring, ws_ring);
		chmod(ws_ring, 0500);
#endif
		return(0);
	    }
        }
	else
	    break;
    }
    if (*fstypes[fsindex] == '\0') {
	senderror(CLIENT_WRITE, ERR_MOUNT); /* cdrom mount */
	return(1);
    }
    else {
	PRDEBUG "\tCDROM Mounted successfuly\n");
	/* We did the mounting */
	fsmounted++;
	if (strcmp(fstypes[fsindex], "hsfs") == 0) {
    	    iso_9660 = 1;
	    putenv("ISO9660=Y");
	    
	    /*
	     * Since it's an ISO9660 file system, then file names
	     * are stored in ALL CAPS.  SunOS can cover the difference,
	     * but CLIX can't.
	     * For now, we'll see if we have to fold filenames
	     * to all caps ourselves.
	     */
	    sprintf(source_ring, "%s/ws_s.prods", MNTDIR);
	    if (access(source_ring, R_OK) != 0) {
		/* lower case access failed */
		for (cp = source_ring + strlen(MNTDIR); *cp; cp++)
		  *cp = toupper(*cp);
		
		if (access(source_ring, R_OK) == 0) {
		    foldcase = UPPER;
		    putenv("FOLDCASE=UPPER");
		}
		else {
		    /*
		     * Didn't find "ws_s.prods" or "WS_S.PRODS"
		     * Maybe it's a CD of VAX products
		     * Look for "vax.prods" and "VAX.PRODS"
		     */
		    sprintf(source_ring, "%s/vax.prods", MNTDIR);
		    if (access(source_ring, R_OK) != 0) {
			/* lower case access failed */
			for (cp = source_ring + strlen(MNTDIR); *cp; cp++)
			  *cp = toupper(*cp);
		    
			if (access(source_ring, R_OK) == 0) {
			    foldcase = UPPER;
			    putenv("FOLDCASE=UPPER");
			}
			else 
			    PRDEBUG "WARNING: Didn't find ws_s.prods or vax.prods\n");
		    }
		}
	    }
	    else {
#if defined(sgi) || defined(SCO)
		foldcase = LOWER;
		putenv("FOLDCASE=LOWER");
#else
		foldcase = 0;
#endif
	    }
	    
#ifdef OLD_LOADKEY_METHOD
	    /* prepare the load key verifier for use */
	    sprintf(source_ring, "%s/%s%s", MNTDIR, RING, machine);
	    if (foldcase) {
		for (cp = source_ring + strlen(MNTDIR); *cp; cp++)
		  *cp = (foldcase == UPPER) ? toupper(*cp) : tolower(*cp);
	    }
	    sprintf(ws_ring, "/usr/tmp/%s%d", RING, getpid());
	    unlink(ws_ring);
	    get_ring(source_ring, ws_ring);
	    chmod(ws_ring, 0500);
#endif
	}
	else if (strcmp(fstypes[fsindex], "ufs") == 0) {
	    iso_9660 = 0;
	    foldcase = 0;
	}
	return(0);
    }
}
#endif

/* ifdef HP_UX added here -- MVR 30 Apr 1994 */
#ifdef HP_UX
void determine_fs_type()
{
    char	source_ring[STRSIZ];
    char	*cp;
    struct mntent	*mp;
    FILE		*mf;
    short		found = 0;

    /*
     * Find the file system in the mount table to see if it's
     * ISO9660...
     */
    mf = setmntent(MOUNTED, "r");
    while (mp = getmntent(mf)) {
	if (strcmp(MNTDIR, mp->mnt_dir) == 0) {
    /* cdfs on HP is ISO9660 confirmant file system --  MVR 30 Apr 1994 */
	    if (strcmp(mp->mnt_type, MNTTYPE_CDFS) == 0) {
		iso_9660 = 1;
		putenv("ISO9660=Y");
	    }
    /* HFS is HP's native file system -- MVR 30 Apr 1994 */
	    else if (strcmp(mp->mnt_type, MNTTYPE_HFS) == 0) {
		iso_9660 = 0;
		foldcase = 0;
	    }
	    found++;
	    break;
	}
    }
    endmntent(mf);
    if (!found) {
	/* 
	 * MNTDIR wasn't in the mount table.  So just assume that it's
         * a directory sitting off root, which is a HFS  file system.
	 */
	iso_9660 = 0;
	foldcase = 0;
    }

    if (iso_9660) {
	/*
	 * Since it's an ISO9660 file system, then file names
	 * are stored in ALL CAPS.  SunOS covers the difference
	 * by default,  but CLIX doesn't (mount-time option).
	 * For now, we'll see if we have to fold filenames
	 * to all caps ourselves.
	 */
	sprintf(source_ring, "%s/ws_s.prods", MNTDIR);
	if (access(source_ring, R_OK) != 0) {
	    /* lower case access failed */
	    for (cp = source_ring + strlen(MNTDIR); *cp; cp++)
	      *cp = toupper(*cp);
	    
	    if (access(source_ring, R_OK) == 0) {
		foldcase = UPPER;
		putenv("FOLDCASE=UPPER");
	    }
	    else {
		/*
		 * Neither "ws_s.prods" nor "WS_S.PRODS" were found.
		 * This could be a disc of VAX products.  Look for
		 * "vax.prods" or "VAX.PRODS" -- scw, 4/21/92
		 */
		sprintf(source_ring, "%s/vax.prods", MNTDIR);
		if (access(source_ring, R_OK) != 0) {
		    /* lower case access failed */
		    for (cp = source_ring + strlen(MNTDIR); *cp; cp++)
		      *cp = toupper(*cp);
		    
		    if (access(source_ring, R_OK) == 0) {
			foldcase = UPPER;
			putenv("FOLDCASE=UPPER");
		    }
		    else 
			PRDEBUG "NOTE: Could not find either ws_s.prods or vax.prods\n");
		}
	    }
	}
	else  {
	    foldcase = LOWER;
	    putenv("FOLDCASE=LOWER");
    }
    }
}

int	mountfsys()
{
    extern int	errno;
    char	source_ring[STRSIZ];
    char	ws_ring[STRSIZ];
    char	*cp;
   /* ufs_args can be used for cdrom and ufs file systems -- MVR 7 May 94 */
    struct ufs_args mnt_opts;
    struct mntent	*mp;
    FILE	*mf;
    /* The following definitions added newly -- 4 May 1994 */
    struct statfs chkbuf;
    struct stat statbuff;
    
    /*
     * if file's path isn't on MNTDIR, then return ok -- no need to mount
     * the CDROM
     */
    if (strncmp(request->prodpath, MNTDIR, strlen(MNTDIR)))
      return(0);
    
    /*
     * If the file is readable, then either there's already a
     * directory at MNTDIR that has what we want, or the file
     * system is already mounted.  Get the verifier if we need it.
     */
    if (access(request->prodpath, R_OK) == 0) {
	determine_fs_type();
	return(0);
    }
    
    PRDEBUG "\tMounting the CDROM\n");
    mnt_opts.fspec = CDROM_DEVICE;

    /*  Before proceeding to mount the device, check if it can be mounted 
     *	as CDFS. If not reject now ! -- MVR 7 May 1994
    */
    if (statfsdev(CDROM_DEVICE, &chkbuf)) {
    	senderror(CLIENT_WRITE, ERR_MOUNT);
    	return(1);
    }
    else {
	if (chkbuf.f_fsid[1] != MOUNT_CDFS) {
    		senderror(CLIENT_WRITE, ERR_MOUNT);
    		return(1);
	}
    }

   /* goahad  and mount. We are using the vfsmount insted of mount inorder
    * to specify the filesystem type  -- MVR 7 May 1994
   */
    if (vfsmount(MOUNT_CDFS, MNTDIR,  M_RDONLY,(caddr_t) &mnt_opts)) {
	PRDEBUG "\t** CDFS mount failed: %s\n", sys_errlist[errno]);
	if (errno == EBUSY) {
	    /*
	     * It's already mounted.  See if it's  ISO9660...
	     */
	    determine_fs_type();
	    if (iso_9660) {
#ifdef OLD_LOADKEY_METHOD
		/* Get the loadkey verifier off */
		sprintf(source_ring, "%s/%s%s", MNTDIR, RING, machine);
		sprintf(ws_ring, "/usr/tmp/%s%d", RING, getpid());
		unlink(ws_ring);
		get_ring(source_ring, ws_ring);
		chmod(ws_ring, 0500);
#endif
		return(0);
	    }
	}
	else {
	    senderror(CLIENT_WRITE, ERR_MOUNT);
	    return(1);
	}
    }
    else {
	PRDEBUG "\tCDROM Mounted successfuly\n");
	/* We did the mounting */
	fsmounted++;
	
	/* update /etc/mtab */
	system("/etc/mount -u 2>&1 > /dev/null");
	/* we don't really need to do all this stuff !! 
   	   Still we can use it if we don't wan't to do an extra fork. 
   	   -- MVR 2 Jun 1994
 	*/
#ifdef	DONT_USE_FORK
	mf = setmntent(MOUNTED, "a+");
	mp = (struct mntent *)malloc(sizeof(struct mntent));
	mp->mnt_fsname = CDROM_DEVICE;
	mp->mnt_dir = MNTDIR;
	mp->mnt_type = MNTTYPE_CDFS;
	mp->mnt_opts = MNTOPT_RO;
	mp->mnt_freq = 0;
	mp->mnt_passno = 0;

	/* We need to fill the mnt_time and mnt_cnode fields of the newly
	 * mounted filesystem before we can make an entry in the /etc/mnttab.
	 * Let's get this information from stat -- MVR 5 May 1994 
	*/
	stat(MNTDIR, &statbuff);
	mp->mnt_time = statbuff.st_mtime;
	mp->mnt_cnode = statbuff.st_cnode;
	addmntent(mf, mp);
	endmntent(mf);
	free(mp);
#else /* can use fork ! */
	system("/etc/mount -u  2>&1 > /dev/null");
#endif /* DONT_USE_FORK*/
	
    	iso_9660 = 1;
	putenv("ISO9660=Y");
	    
	/*
	 * Since it's an ISO9660 file system, then file names
	 * are stored in ALL CAPS.  SunOS can cover the difference,
	 * but CLIX can't.
	 * For now, we'll see if we have to fold filenames
	 * to all caps ourselves.
	 */
	sprintf(source_ring, "%s/ws_s.prods", MNTDIR);
	if (access(source_ring, R_OK) != 0) {
	/* lower case access failed */
	for (cp = source_ring + strlen(MNTDIR); *cp; cp++)
	  *cp = toupper(*cp);
	
	if (access(source_ring, R_OK) == 0) {
	    foldcase = UPPER;
	    putenv("FOLDCASE=UPPER");
	}
	else {
	    /*
	     * Didn't find "ws_s.prods" or "WS_S.PRODS"
	     * Maybe it's a CD of VAX products
	     * Look for "vax.prods" and "VAX.PRODS"
	     */
	    sprintf(source_ring, "%s/vax.prods", MNTDIR);
	    if (access(source_ring, R_OK) != 0) {
		/* lower case access failed */
		for (cp = source_ring + strlen(MNTDIR); *cp; cp++)
		  *cp = toupper(*cp);
	    
		if (access(source_ring, R_OK) == 0) {
		    foldcase = UPPER;
		    putenv("FOLDCASE=UPPER");
		}
		else 
		    PRDEBUG "WARNING: Didn't find ws_s.prods or vax.prods\n");
	    }
	}
    	}
    	else {
		foldcase = LOWER;
		putenv("FOLDCASE=LOWER");
	}
	    
#ifdef OLD_LOADKEY_METHOD
	/*
	 * Get the verifier
	 */
	sprintf(source_ring, "%s/%s%s", MNTDIR, RING, machine);
	sprintf(ws_ring, "/usr/tmp/%s%d", RING, getpid());
	unlink(ws_ring);
	get_ring(source_ring, ws_ring);
	chmod(ws_ring, 0500);
#endif
	return(0);
    }
}

unmountfs(dir)
char	*dir;
{
    struct mntent *mp, *mpa[NMOUNT];
    int		i, lastentry;
    FILE *mf;

    /* umount used insted of unmount  -- MVR 30 Apr 1994 */
    if (umount(dir) == 0) {

    /* update the /etc/mnttab. two ways of doing it !! */
#ifdef	DONT_USE_FORK
/* dont need to do this stuff. an after thought !! -- MVR 2 Jun 1994 */
	mf = setmntent(MOUNTED, "r");

	/* Read all the entries in */
	lastentry = 0;
	while (mp = getmntent(mf)) {
	    mpa[lastentry] = (struct mntent *)malloc(sizeof(struct mntent));

	    /* Since the first 4 fields are just pointers
	     * instead of full arrays, we have to allocate our own
	     * space for them...
	     */

	    if (mpa[lastentry]->mnt_fsname = (char *)malloc(strlen(mp->mnt_fsname)+1))
		strcpy(mpa[lastentry]->mnt_fsname, mp->mnt_fsname);

	    if (mpa[lastentry]->mnt_dir = (char *)malloc(strlen(mp->mnt_dir)+1))
		strcpy(mpa[lastentry]->mnt_dir, mp->mnt_dir);

	    if (mpa[lastentry]->mnt_type = (char *)malloc(strlen(mp->mnt_type)+1))
		strcpy(mpa[lastentry]->mnt_type, mp->mnt_type);
	    
	    if (mpa[lastentry]->mnt_opts = (char *)malloc(strlen(mp->mnt_opts)+1))
		strcpy(mpa[lastentry]->mnt_opts, mp->mnt_opts);
	    
	    mpa[lastentry]->mnt_freq = mp->mnt_freq;
	    mpa[lastentry]->mnt_passno = mp->mnt_passno;
            /* Read the mnt_time and mnt_cnode too -- MVR 5 May 1994 */
	    mpa[lastentry]->mnt_time = mp->mnt_time;
	    mpa[lastentry]->mnt_cnode = mp->mnt_cnode;
	    
	    lastentry++;
	}

	endmntent(mf);
	mf = setmntent(MOUNTED, "w+");

	/* Write all the entries out except for the one we unmounted. */
	for (i = 0; i < lastentry; i++) {
	    if (strcmp(dir, mpa[i]->mnt_dir) != 0)
		addmntent(mf, mpa[i]);

	    free(mpa[i]->mnt_fsname);
	    free(mpa[i]->mnt_dir);
	    free(mpa[i]->mnt_type);
	    free(mpa[i]->mnt_opts);
	    free(mpa[i]);
	}
	endmntent(mf);
#else	/* can use fork !! */
    	system("/etc/mount -u 2>&1 > /dev/null");
#endif /* DONT_USE_FORK*/
    }
}
#endif

#ifdef SunOS_4
void determine_fs_type()
{
    struct mntent	*mp;
    FILE		*mf;
    short		found = 0;

    /*
     * Find the file system in the mount table to see if it's
     * ISO9660...
     */
    mf = setmntent(MOUNTED, "r");
    while (mp = getmntent(mf)) {
	if (strcmp(MNTDIR, mp->mnt_dir) == 0) {
	    if (strcmp(mp->mnt_type, "hsfs") == 0) {
		iso_9660 = 1;
		foldcase = 0;
		putenv("ISO9660=Y");
	    }
	    else if (strcmp(mp->mnt_type, MNTTYPE_42)) {
		iso_9660 = 0;
		foldcase = 0;
	    }
	    found++;
	    break;
	}
    }
    endmntent(mf);
    if (!found) {
	/*
	 * MNTDIR wasn't in the mount table.  So just assume that it's
         * a directory sitting off root, which is a 4.2 (UFS) file system.
	 */
	iso_9660 = 0;
	foldcase = 0;
    }
}

int	mountfsys()
{
    extern int	errno;
    char	source_ring[STRSIZ];
    char	ws_ring[STRSIZ];
    struct ufs_args mnt_opts;
    struct mntent	*mp;
    FILE	*mf;
    
    /*
     * if file's path isn't on MNTDIR, then return ok -- no need to mount
     * the CDROM
     */
    if (strncmp(request->prodpath, MNTDIR, strlen(MNTDIR)))
      return(0);
    
    /*
     * If the file is readable, then either there's already a
     * directory at MNTDIR that has what we want, or the file
     * system is already mounted.  Get the verifier if we need it.
     */
    if (access(request->prodpath, R_OK) == 0) {
	determine_fs_type();
	return(0);
    }
    
    PRDEBUG "\tMounting the CDROM\n");
    mnt_opts.fspec = CDROM_DEVICE;
    if (mount("hsfs", MNTDIR, (M_NEWTYPE | M_RDONLY), mnt_opts)) {
	PRDEBUG "\t** HSFS mount failed: %s\n", sys_errlist[errno]);
	if (errno == EBUSY) {
	    /*
	     * It's already mounted.  See if it's  ISO9660...
	     */
	    determine_fs_type();
	    if (iso_9660) {
#ifdef OLD_LOADKEY_METHOD
		/* Get the loadkey verifier off */
		sprintf(source_ring, "%s/%s%s", MNTDIR, RING, machine);
		sprintf(ws_ring, "/usr/tmp/%s%d", RING, getpid());
		unlink(ws_ring);
		get_ring(source_ring, ws_ring);
		chmod(ws_ring, 0500);
#endif
		return(0);
	    }
	}
	else {
	    senderror(CLIENT_WRITE, ERR_MOUNT);
	    return(1);
	}
    }
    else {
	PRDEBUG "\tCDROM Mounted successfuly\n");
	/* We did the mounting */
	fsmounted++;
	
	/* update /etc/mtab */
	mf = setmntent(MOUNTED, "a+");
	mp = (struct mntent *)malloc(sizeof(struct mntent));
	mp->mnt_fsname = CDROM_DEVICE;
	mp->mnt_dir = MNTDIR;
	mp->mnt_type = "hsfs";
	mp->mnt_opts = MNTOPT_RO;
	mp->mnt_freq = 0;
	mp->mnt_passno = 0;
	addmntent(mf, mp);
	endmntent(mf);
	free(mp);
	
	iso_9660 = 1;
	foldcase = 0;
#ifdef OLD_LOADKEY_METHOD
	/*
	 * Get the verifier
	 */
	sprintf(source_ring, "%s/%s%s", MNTDIR, RING, machine);
	sprintf(ws_ring, "/usr/tmp/%s%d", RING, getpid());
	unlink(ws_ring);
	get_ring(source_ring, ws_ring);
	chmod(ws_ring, 0500);
#endif
	return(0);
    }
}

unmountfs(dir)
char	*dir;
{
    struct mntent *mp, *mpa[NMOUNT];
    int		i, lastentry;
    FILE *mf;

    if (unmount(dir) == 0) {
	mf = setmntent(MOUNTED, "r");

	/* Read all the entries in */
	lastentry = 0;
	while (mp = getmntent(mf)) {
	    mpa[lastentry] = (struct mntent *)malloc(sizeof(struct mntent));

	    /* Since the first 4 fields are just pointers
	     * instead of full arrays, we have to allocate our own
	     * space for them...
	     */

	    if (mpa[lastentry]->mnt_fsname = (char *)malloc(strlen(mp->mnt_fsname)+1))
		strcpy(mpa[lastentry]->mnt_fsname, mp->mnt_fsname);

	    if (mpa[lastentry]->mnt_dir = (char *)malloc(strlen(mp->mnt_dir)+1))
		strcpy(mpa[lastentry]->mnt_dir, mp->mnt_dir);

	    if (mpa[lastentry]->mnt_type = (char *)malloc(strlen(mp->mnt_type)+1))
		strcpy(mpa[lastentry]->mnt_type, mp->mnt_type);
	    
	    if (mpa[lastentry]->mnt_opts = (char *)malloc(strlen(mp->mnt_opts)+1))
		strcpy(mpa[lastentry]->mnt_opts, mp->mnt_opts);
	    
	    mpa[lastentry]->mnt_freq = mp->mnt_freq;
	    mpa[lastentry]->mnt_passno = mp->mnt_passno;
	    
	    lastentry++;
	}

	endmntent(mf);
	mf = setmntent(MOUNTED, "w+");

	/* Write all the entries out except for the one we unmounted. */
	for (i = 0; i < lastentry; i++) {
	    if (strcmp(dir, mpa[i]->mnt_dir) != 0)
		addmntent(mf, mpa[i]);

	    free(mpa[i]->mnt_fsname);
	    free(mpa[i]->mnt_dir);
	    free(mpa[i]->mnt_type);
	    free(mpa[i]->mnt_opts);
	    free(mpa[i]);
	}
	endmntent(mf);
    }
}
#endif

#ifdef _AIX
void determine_fs_type()
{
    char		*obptr, *stubptr;
    struct vmount	*vbuf, *vptr;
    int			size = 1024, result, found = 0;
    int			i;
	
    /*
     * See if the file system mounted on MNTDIR is 
     * of type MNT_CDROM or not
     */
    if ((vbuf = (struct vmount *)malloc(size)) == NULL)
        return;

    result = mntctl(MCTL_QUERY, size, vbuf);
    if (result < 0) {
        free(vbuf);
	return;
    }
    else if (result == 0) {
        size = *(ulong *)vbuf;
        vbuf = (struct vmount *)realloc(vbuf, size);
        result = mntctl(MCTL_QUERY, size, vbuf);
    }

    vptr = vbuf;
    for (i = 0; i < result; i++, vptr += vptr->vmt_length) {
	/*
	 * In "traditional" parlance, the "OBJECT" is the special
	 * device node used to access the file system, and the "STUB"
	 * is the mount point.
	 */
	obptr = vmt2dataptr(vptr, VMT_OBJECT);
	stubptr = vmt2dataptr(vptr, VMT_STUB);

	if (strcmp(stubptr, MNTDIR) == 0) {
	    found = 1;
	    if (vptr->vmt_gfstype == MNT_CDROM) {
		iso_9660 = 1;
		foldcase = 0;
		putenv("ISO9660=Y");
	    }
	    else {
		iso_9660 = 0;
		foldcase = 0;
	    }
	}
    }
    if (!found) {
	iso_9660 = 0;
	foldcase = 0;
    }
}


int     mountfsys()
{
    extern int errno;
    struct	vmount	*vptr;
    char    source_ring[STRSIZ];
    char    ws_ring[STRSIZ];
    char    cmd[128], answer[128], errstr[128];
    FILE    *pfd;
    int     result, size, i;
    char    *cp;

    /*
     * if file's path isn't on MNTDIR, then return ok -- no need to mount
     * the CDROM
     */
    if (strncmp(request->prodpath, MNTDIR, strlen(MNTDIR)))
	return(0);

    /*
     * if the file is readable, then assume file system has been mounted
     */
    if (!access(request->prodpath, R_OK)) {
	determine_fs_type();
	return(0);
    }
    size = strlen(CDROM_DEVICE) + strlen(MNTDIR) + sizeof (struct vmount);

    if ((vptr = malloc(size)) == NULL) {
	senderror(CLIENT_WRITE, ERR_MOUNT);
	return(1);
    }
	
    vptr->vmt_revision = VMT_REVISION;
    vptr->vmt_length = size;
    vptr->vmt_flags &= MNT_READONLY;
    vptr->vmt_gfstype = MNT_CDROM;
    vptr->vmt_data[VMT_OBJECT].vmt_off =  sizeof(struct vmount);
    vptr->vmt_data[VMT_OBJECT].vmt_size = strlen(CDROM_DEVICE);
    vptr->vmt_data[VMT_STUB].vmt_off = sizeof(struct vmount) + strlen(CDROM_DEVICE);
    vptr->vmt_data[VMT_STUB].vmt_size = strlen(MNTDIR);
    for (i = VMT_HOST; i <= VMT_LASTINDEX; i++) {
	vptr->vmt_data[i].vmt_off = 0;
	vptr->vmt_data[i].vmt_size = 0;
    }

    if (vmount(vptr, size) < 0) {
	if (errno == EBUSY) {
	    /* It's already mounted. */
	    determine_fs_type();

	    if (iso_9660) {
#ifdef OLD_LOADKEY_METHOD
		/* Get the loadkey verifier off */
		sprintf(source_ring, "%s/%s%s", MNTDIR, RING, machine);
		sprintf(ws_ring, "/usr/tmp/%s%d", RING, getpid());
		unlink(ws_ring);
		get_ring(source_ring, ws_ring);
		chmod(ws_ring, 0500);
#endif
		return(0);
	    }
	}
	else {
	    senderror(CLIENT_WRITE, ERR_MOUNT);
	    return(1);
	}
    }
    else {
	PRDEBUG "\tCDROM Mounted successfully\n");
	/* We did the mounting */
	fsmounted++;
	iso_9660 = 1;
	foldcase = 0;
	sprintf(source_ring, "%s/%s%s", MNTDIR, RING, machine);
	sprintf(ws_ring, "/usr/tmp/%s%d", RING, getpid());
	unlink(ws_ring);
	get_ring(source_ring, ws_ring);
	chmod(ws_ring, 0500);
	return(0);
    }
}
#endif


#ifdef OSF
void	determine_fs_type()
{
#define MOUNT_CDFS	99
    struct	statfs	*sfbuf, *mp;
    int		entries, result, i;
    long	bufsiz;

    /* How can we see if the device has an ISO9660 file
     * system on it? 
     */
    entries = getfsstat((struct statfs *)0, 0, 0);
    bufsiz = entries * sizeof(struct statfs);
    sfbuf = (struct statfs *)malloc(bufsiz);

    result = getfsstat(sfbuf, bufsiz, MNT_NOWAIT);

    for (i = 0, mp = sfbuf; i < entries; i++, mp++) {
	if ((strcmp(MNTDIR, mp->f_mntonname) == 0) && 
				(mp->f_type == MOUNT_CDFS)) {
	    iso_9660 = 1;
	    putenv("ISO9660=Y");
	}
    }
}

mountfsys()
{
    char	source_ring[STRSIZ];
    char	ws_ring[STRSIZ];
    struct ufs_args mnt_opts;

    /*
     * if file's path isn't on MNTDIR, then return ok -- no need to mount
     * the CDROM
     */
    if (strncmp(request->prodpath, MNTDIR, strlen(MNTDIR)))
      return(0);
    
    /*
     * If the file is readable, then either there's already a
     * directory at MNTDIR that has what we want, or the file
     * system is already mounted.  Get the verifier if we need it.
     */
    if (access(request->prodpath, R_OK) == 0) {
	determine_fs_type();
	return(0);
    }
    
    PRDEBUG "\tMounting the CDROM\n");
    mnt_opts.fspec = CDROM_DEVICE;
    if (mount(MOUNT_CDFS, MNTDIR, M_RDONLY, (caddr_t)&mnt_opts)) {
	PRDEBUG "\t** CD/ROM mount failed: %s\n", sys_errlist[errno]);
	if (errno == EBUSY) {
	    /*
	     * It's already mounted.  See if it's  ISO9660...
	     */
	    determine_fs_type();
	    if (iso_9660) {
#ifdef OLD_LOADKEY_METHOD
		/* Get the loadkey verifier off */
		sprintf(source_ring, "%s/%s%s", MNTDIR, RING, machine);
		sprintf(ws_ring, "/usr/tmp/%s%d", RING, getpid());
		unlink(ws_ring);
		get_ring(source_ring, ws_ring);
		chmod(ws_ring, 0500);
#endif
		return(0);
	    }
	}
	else {
	    senderror(CLIENT_WRITE, ERR_MOUNT);
	    return(1);
	}
    }
    else {
	PRDEBUG "\tCDROM Mounted successfuly\n");
	/* We did the mounting */
	fsmounted++;
	
	iso_9660 = 1;
	foldcase = 0;
#ifdef OLD_LOADKEY_METHOD
	/*
	 * Get the verifier
	 */
	sprintf(source_ring, "%s/%s%s", MNTDIR, RING, machine);
	sprintf(ws_ring, "/usr/tmp/%s%d", RING, getpid());
	unlink(ws_ring);
	get_ring(source_ring, ws_ring);
	chmod(ws_ring, 0500);
#endif
	return(0);
    }
}
#endif

#if defined(SYSV) || defined(OSF) || defined(_AIX)
/*ARGSUSED*/
void cleanup(sig)
int sig;
{
    char ws_ring[STRSIZ];
#ifdef sgi
    char command[STRSIZ];
#endif

    if (sig == SIGPIPE)
	PRDEBUG "*** Lost connection with client; cleaning up.\n");
    else
	PRDEBUG "*** Termination signal received; closing the connection\n");

    sclose();

    if (fsmounted) {
	PRDEBUG "Unmounting the CDROM\n");
#if defined(SYSV) && !defined(sgi)
	umount(CDROM_DEVICE);
#endif
#ifdef OSF
	umount(MNTDIR, MNT_NOFORCE);
#endif
#ifdef _AIX
	umount(MNTDIR);
#endif
#ifdef sgi
	sprintf(command, "umount %s", CDROM_DEVICE);
	system(command);
#endif
    }

    sprintf(ws_ring, "/usr/tmp/%s%d", RING, getpid());
    unlink(ws_ring);

    if (debug)
	fclose(log);
    exit(0);
}

#else
/*ARGSUSED*/
void cleanup(sig, code, scp, addr)
int sig,code;
struct sigcontext *scp;
char *addr;
{
    char ws_ring[STRSIZ];

    if (sig == SIGPIPE)
	PRDEBUG "*** Lost connection with client; cleaning up.\n");
    else
	PRDEBUG "*** Termination signal received; closing the connection\n");

    sclose();

    if (fsmounted) {
	PRDEBUG "Unmounting the CDROM\n");
/* Added HP here -- MVR 4 May 1994 */
#if defined(SunOS_4) || defined(HP_UX)
	unmountfs(MNTDIR);
#else
	umount(MNTDIR);
#endif
    }

    sprintf(ws_ring, "/usr/tmp/%s%d", RING, getpid());
    unlink(ws_ring);

    if (debug)
	fclose(log);
    exit(0);
}
#endif


int	main(argc, argv)
int	argc;
char	**argv;
{
    char ws_ring[STRSIZ];
#ifdef sgi
    char command[128];
#endif
    char *c;
#ifdef sun
    static char *path;
    char *pptr;
#endif
    
#if defined(SecureWare) && !defined (SCO)
    if (trustlevel())
        set_auth_parameters(argc, argv);
#endif
#ifdef SCO
        set_auth_parameters(argc, argv);
#endif

    if (isatty(0)) {
	PRINT "This image is the newprod delivery server for remote\n");
	PRINT "CD/ROM drives. It must be invoked via newprod through\n");
	PRINT "the network.\n");
	exit(255);
    } 

    if (debug) {
	log = fopen("/tmp/slog", "w");
	setbuf(log, NULL);
	fprintf(log, "%s started, %d args\n", argv[0], argc);
    }

    if (argc > 1)
	net = (argv[1][1] == 't' ? TCP : XNS);
    else 
	net = XNS;

    if (net == XNS) {
        if (geteuid() == 0) 
	    is_su = 1;
    }

    ingrhome = BASEDIR;
#if defined(SVR4) && defined(NEWDIRS)
    if ((c = getenv("INGRHOME")) && *c) {
	ingrhome = c;
	c = strchr(ingrhome, ':');
	if (c)
	    *c = '\0';
    }
#endif
    sprintf(deltools_home, "%s/deltools", ingrhome);


#ifdef LOG_MAIL
    (void) openlog(argv[0], LOG_PID, LOG_MAIL);
#else
    (void) openlog(argv[0], LOG_PID, LOG_AUTH);
#endif


    request = (REQUEST *)malloc(sizeof(REQUEST));
    reply = (REPLY *)malloc(sizeof(REPLY));
    delreq = (DELREQ *)malloc(sizeof(DELREQ));

    /*
     * Make sure various interrupting signals and exception conditions
     * (lost peer connection) are handled cleanly...
     */
    signal(SIGTERM, cleanup);
    signal(SIGINT, cleanup);
    signal(SIGQUIT, cleanup);
    signal(SIGHUP, cleanup); 
    signal(SIGPIPE, cleanup);

#ifdef SunOS_4
    /*
     * Make sure that /usr/ucb is in the path for Suns, otherwise,
     * you can't find the uncompress utility...
     */
    pptr = (char *)getenv("PATH");
    if (strstr(pptr, "/usr/ucb") == NULL) {
	path = (char *)malloc(strlen(pptr) + 15);
	strcpy(path, "PATH=");
	strcat(path, pptr);
	strcat(path, ":/usr/ucb");
	putenv(path);
    }
#endif
    
#ifdef OSF
    if (access("/usr/sbin/ksh", X_OK) == 0) {
	shell = "/usr/sbin/ksh";
	putenv("SHELL=/usr/sbin/ksh");
	putenv("ENV=");
    }
    else {
	shell = "/sbin/sh";
	putenv("SHELL=/sbin/sh");
    }
#else
    if (access("/bin/ksh", X_OK) == 0) {
	shell = "/bin/ksh";
	putenv("SHELL=/bin/ksh");
	putenv("ENV=");
    }
    else {
	shell = "/bin/sh";
	putenv("SHELL=/bin/sh");
    }
#endif
    
    if ((err = saccept())) {
	goto finish;
    }
    for(;;) {
	PRDEBUG "Getting a request\n");
        /*
	 * if there's an error from get_request, then terminate
	 */
	if (get_request(CLIENT_READ))
	    break;
	switch (ctohl(request->req_type)) {

	case DEFINE_USER:
	PRDEBUG "Call define_user\n");
	    define_user();
	    break;
	
	case GET_VERSION:
	PRDEBUG "call send_version\n");
	    send_version();
	    if (debug) {
		fprintf(log, "server version: %s\n", version);
		fprintf(log, "client version: %s\n", client_version);
		fprintf(log, "client flags: %x\n", client_flags);
	    }
	    break;

	case SEND_LOAD_KEY_FILENAME:
	    PRDEBUG "request to send load key file name\n");
	    if (request->authtyp)
	        send_sn_filename();
	    else
	        send_load_key_filename();
	    break;

	case GET_LOAD_KEY:
	    PRDEBUG "request for load key\n");
	    if (iso_9660 && foldcase) {
	       for (c = request->prodpath+strlen(GetMountPoint(request->prodpath)); *c; c++)
		   *c = (foldcase == UPPER) ? toupper(*c) : tolower(*c);
	    }
	    send_load_key();
	    break;

	case VERIFY_LOAD_KEY:
	    PRDEBUG "request to verify a key\n");
	    if (mountfsys())
		break;

	    if (iso_9660 && foldcase) {
	        for (c = request->prodpath+strlen(GetMountPoint(request->prodpath)); *c; c++)
		    *c = (foldcase == UPPER) ? toupper(*c) : tolower(*c);
	    }
	    verify_load_key();
		break;

	case RECEIVE_FILE:
	    PRDEBUG "request for file\n");
	    if (mountfsys())
		break;
	    if (!get_file_stats())
		send_file();
	    break;

	case INSTALL_PRODUCTS:
    	    PRDEBUG "request to install products\n");
	    if (!is_su) {
		PRDEBUG "\t Insufficient permission to install software\n");
		senderror(CLIENT_WRITE, ERR_PERM);
	    }
	    else {
	        install_software();
	    }
	    break;
	    
	case END_CONNECTION:
	    PRDEBUG "request to end connection\n");
	    goto finish;

	default:
	    senderror(CLIENT_WRITE, ERR_NOSUCHREQUEST);
	    break;
	}
    }

finish:
    PRDEBUG "Closing the connection\n");
    sclose();

    if (fsmounted) {
	PRDEBUG "Unmounting the CDROM\n");
#if defined(SYSV) && !defined(sgi)
	umount(CDROM_DEVICE);
#endif
#ifdef sgi
	sprintf(command, "umount %s", CDROM_DEVICE);
	system(command);
#endif
/* call umountfs for HP too -- MVR  30 Apr 1994*/
#if defined(SunOS_4) || defined(HP_UX)
        unmountfs(MNTDIR);
#endif
#ifdef OSF
	umount(MNTDIR, MNT_NOFORCE);
#endif
#ifdef _AIX
	umount(MNTDIR);
#endif
    }

    sprintf(ws_ring, "/usr/tmp/%s%d", RING, getpid());
    unlink(ws_ring);

    if (debug)
	fclose(log);

    closelog();

    exit(0);
}




#ifdef SCO
trustlevel_sco()
{
    char buf[256]; 
    int c,i,nc=0;
    FILE *fp;
    int chkbuf();

    fp = fopen("/etc/initscript","r");
    while ((c = getc(fp)) != EOF){
        if (c == '\n'){
	    if (nc) {
	       if (chkbuf(nc,buf)){
		   PRDEBUG "trustlevel 1\n");
		   return(1);
	       }
	    }
	    nc=0;
        }
	else
	    buf[nc++]=c;

	if (nc >=255){
	    if (chkbuf(nc,buf)) {
		PRDEBUG "trustlevel 1\n");
		return(1);
	    }
	    nc=0;
        }
    }
    PRDEBUG "trustlevel 0\n");
    return(0);
}


chkbuf(nc,buf)
int nc;
char buf[];
{
    int i;
    char *uchar, *nchar;

    buf[nc]='\0';

    if (uchar=strstr(buf,"umask")) {
	if (nchar=strstr(uchar,"077")) {
	    return(077);
        }
    }
    return(0);
}
#endif
