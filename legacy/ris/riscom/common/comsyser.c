/* Do not alter this SPC information: $Revision: 1.2.28.1 $ */
/*
**	NAME:							comsyser.c
**	AUTHORS:						Dan Karier
**	CREATION DATE:					7/89
**	ABSTRACT:
**		given an OS error number, write the system's error message
**		to the buffer, null terminated, without overflowing.
**		
**	
**	REVISION HISTORY:
*/

/*
**	INCLUDES
*/

#if defined(unix) && !defined(sco)
# include <errno.h>
#endif

#if defined(WIN32) || defined(DOS)
#include <stdio.h>
#include <errno.h>
#endif

#ifdef vms
#include <ssdef.h>
#include <descrip.h>
#endif

#include "ris.h"


/*
**	DEFINES
*/

/*
**	TYPES
*/
#if defined(unix) && !defined(sco) || defined(WIN32) || defined(DOS)
typedef struct errno_info_s
{
	int		no;
	char	*name;
}errno_info_s; 
#endif

/*
**	FUNCTION PROTOTYPES
*/
#define comsyser_c
#include "sys.prt"
#include "comsyser.prt"

/*
**	VARIABLES
*/

#if defined(unix) && !defined(sco) || defined(WIN32) || defined(DOS)
static errno_info_s errno_info[] = 
{
#if defined(unix)
	{	EPERM,	"EPERM"	},
	{	ENOENT,	"ENOENT"	},
	{	ESRCH,	"ESRCH"	},
	{	EINTR,	"EINTR"	},
	{	EIO,	"EIO"	},
	{	ENXIO,	"ENXIO"	},
	{	E2BIG,	"E2BIG"	},
	{	ENOEXEC,	"ENOEXEC"	},
	{	EBADF,	"EBADF"	},
	{	ECHILD,	"ECHILD"	},
	{	EAGAIN,	"EAGAIN"	},
	{	ENOMEM,	"ENOMEM"	},
	{	EACCES,	"EACCES"	},
	{	EFAULT,	"EFAULT"	},
	{	ENOTBLK,	"ENOTBLK"	},
	{	EBUSY,	"EBUSY"	},
	{	EEXIST,	"EEXIST"	},
	{	EXDEV,	"EXDEV"	},
	{	ENODEV,	"ENODEV"	},
	{	ENOTDIR,	"ENOTDIR"	},
	{	EISDIR,	"EISDIR"	},
	{	EINVAL,	"EINVAL"	},
	{	ENFILE,	"ENFILE"	},
	{	EMFILE,	"EMFILE"	},
	{	ENOTTY,	"ENOTTY"	},
	{	ETXTBSY,	"ETXTBSY"	},
	{	EFBIG,	"EFBIG"	},
	{	ENOSPC,	"ENOSPC"	},
	{	ESPIPE,	"ESPIPE"	},
	{	EROFS,	"EROFS"	},
	{	EMLINK,	"EMLINK"	},
	{	EPIPE,	"EPIPE"	},
	{	EDOM,	"EDOM"	},
	{	ERANGE,	"ERANGE"	},
	{	ENOMSG,	"ENOMSG"	},
	{	EIDRM,	"EIDRM"	},
#if defined(__clipper__) || defined(__hpux__) 
	{	ECHRNG,	"ECHRNG"	},
	{	EL2NSYNC,	"EL2NSYNC"	},
	{	EL3HLT,	"EL3HLT"	},
	{	EL3RST,	"EL3RST"	},
	{	ELNRNG,	"ELNRNG"	},
	{	EUNATCH,	"EUNATCH"	},
	{	ENOCSI,	"ENOCSI"	},
	{	EL2HLT,	"EL2HLT"	},
#endif
	{	EDEADLK,	"EDEADLK"	},
	{	ENOLCK,	"ENOLCK"	},
#if defined(__clipper__)
	{	EBADE,	"EBADE"	},
	{	EBADR,	"EBADR"	},
	{	EXFULL,	"EXFULL"	},
	{	ENOANO,	"ENOANO"	},
	{	EBADRQC,	"EBADRQC"	},
	{	EBADSLT,	"EBADSLT"	},
	{	EDEADLOCK,	"EDEADLOCK"	},
	{	EBFONT,	"EBFONT"	},
#endif
	{	ENOSTR,	"ENOSTR"	},
#if defined(__clipper__) || defined(__hpux__)
	{	ENODATA,	"ENODATA"	},
#endif
	{	ETIME,	"ETIME"	},
	{	ENOSR,	"ENOSR"	},
	{	ENONET,	"ENONET"	},
#if defined(__clipper__) || defined(__hpux__)
	{	ENOPKG,	"ENOPKG"	},
#endif
	{	EREMOTE,	"EREMOTE"	},
	{	ENOLINK,	"ENOLINK"	},
	{	EADV,	"EADV"	},
	{	ESRMNT,	"ESRMNT"	},
	{	ECOMM,	"ECOMM"	},
	{	EPROTO,	"EPROTO"	},
	{	EMULTIHOP,	"EMULTIHOP"	},
#if defined(__clipper__)
	{	ELBIN,	"ELBIN"	},
#endif
#if ! defined(__Sol2__) && !defined(Soli)
	{	EDOTDOT,	"EDOTDOT"	},
#endif
	{	EBADMSG,	"EBADMSG"	},
#if defined(__clipper__)
	{	ENOTUNIQ,	"ENOTUNIQ"	},
	{	EBADFD,	"EBADFD"	},
#endif
#if !defined(__hpux__)
	{	EREMCHG,	"EREMCHG"	},
#endif
#if defined(__clipper__)
	{	ELIBACC,	"ELIBACC"	},
	{	ELIBBAD,	"ELIBBAD"	},
	{	ELIBSCN,	"ELIBSCN"	},
	{	ELIBMAX,	"ELIBMAX"	},
	{	ELIBEXEC,	"ELIBEXEC"	},
#endif
	{	ENAMETOOLONG,	"ENAMETOOLONG"	},
	{	EWOULDBLOCK,	"EWOULDBLOCK"	},
	{	EINPROGRESS,	"EINPROGRESS"	},
	{	EALREADY,	"EALREADY"	},
	{	ENOTSOCK,	"ENOTSOCK"	},
	{	EDESTADDRREQ,	"EDESTADDRREQ"	},
	{	EMSGSIZE,	"EMSGSIZE"	},
	{	EPROTOTYPE,	"EPROTOTYPE"	},
	{	EPROTONOSUPPORT,	"EPROTONOSUPPORT"	},
	{	ESOCKTNOSUPPORT,	"ESOCKTNOSUPPORT"	},
	{	EOPNOTSUPP,	"EOPNOTSUPP"	},
	{	EPFNOSUPPORT,	"EPFNOSUPPORT"	},
	{	EAFNOSUPPORT,	"EAFNOSUPPORT"	},
	{	EADDRINUSE,	"EADDRINUSE"	},
	{	EADDRNOTAVAIL,	"EADDRNOTAVAIL"	},
	{	ENETDOWN,	"ENETDOWN"	},
	{	ENETUNREACH,	"ENETUNREACH"	},
	{	ENETRESET,	"ENETRESET"	},
	{	ECONNABORTED,	"ECONNABORTED"	},
	{	ECONNRESET,	"ECONNRESET"	},
	{	ENOBUFS,	"ENOBUFS"	},
	{	EISCONN,	"EISCONN"	},
	{	ENOTCONN,	"ENOTCONN"	},
	{	ESHUTDOWN,	"ESHUTDOWN"	},
	{	ETOOMANYREFS,	"ETOOMANYREFS"	},
	{	ETIMEDOUT,	"ETIMEDOUT"	},
	{	ECONNREFUSED,	"ECONNREFUSED"	},
	{	EHOSTDOWN,	"EHOSTDOWN"	},
	{	EHOSTUNREACH,	"EHOSTUNREACH"	},
	{	ENOPROTOOPT,	"ENOPROTOOPT"	}
#endif /* unix */
#if defined (WIN32)
	{	EPERM,	"EPERM"	},
	{	ENOENT,	"ENOENT"	},
	{	ESRCH,	"ESRCH"	},
	{	EINTR,	"EINTR"	},
	{	EIO,	"EIO"	},
	{	ENXIO,	"ENXIO"	},
	{	E2BIG,	"E2BIG"	},
	{	ENOEXEC,	"ENOEXEC"	},
	{	EBADF,	"EBADF"	},
	{	ECHILD,	"ECHILD"	},
	{	EAGAIN,	"EAGAIN"	},
	{	ENOMEM,	"ENOMEM"	},
	{	EACCES,	"EACCES"	},
	{	EFAULT,	"EFAULT"	},
	{	EBUSY,	"EBUSY"	},
	{	EEXIST,	"EEXIST"	},
	{	EXDEV,	"EXDEV"	},
	{	ENODEV,	"ENODEV"	},
	{	ENOTDIR,	"ENOTDIR"	},
	{	EISDIR,	"EISDIR"	},
	{	EINVAL,	"EINVAL"	},
	{	ENFILE,	"ENFILE"	},
	{	EMFILE,	"EMFILE"	},
	{	ENOTTY,	"ENOTTY"	},
	{	EFBIG,	"EFBIG"	},
	{	ENOSPC,	"ENOSPC"	},
	{	ESPIPE,	"ESPIPE"	},
	{	EROFS,	"EROFS"	},
	{	EMLINK,	"EMLINK"	},
	{	EPIPE,	"EPIPE"	},
	{	EDOM,	"EDOM"	},
	{	ERANGE,	"ERANGE"	},
	{	EDEADLOCK,	"EDEADLOCK"	},
#endif /* WIN32 */
#if defined(DOS) 
    {   EZERO,  "EZERO" },
    {   EPERM,  "EPERM" },
    {   ENOENT, "ENOENT"    },
    {   ENOENT, "ENOENT"    },
    {   ESRCH,  "ESRCH" },
    {   ESRCH,  "ESRCH" },
    {   EINTR,  "EINTR" },
    {   EIO,    "EIO"   },
    {   ENXIO,  "ENXIO" },
    {   E2BIG,  "E2BIG" },
    {   ENOEXEC,    "ENOEXEC"   },
    {   EBADF,  "EBADF" },
    {   ECHILD, "ECHILD"    },
    {   EAGAIN, "EAGAIN"    },
    {   ENOMEM, "ENOMEM"    },
    {   EACCES, "EACCES"    },
    {   EFAULT, "EFAULT"    },
    {   ENOTBLK,    "ENOTBLK"   },
    {   EBUSY,  "EBUSY" },
    {   EEXIST, "EEXIST"    },
    {   EXDEV,  "EXDEV" },
    {   ENODEV, "ENODEV"    },
    {   ENOTDIR,    "ENOTDIR"   },
    {   EISDIR, "EISDIR"    },
    {   EINVAL, "EINVAL"    },
    {   ENFILE, "ENFILE"    },
    {   EMFILE, "EMFILE"    },
    {   ENOTTY, "ENOTTY"    },
    {   ETXTBSY,    "ETXTBSY"   },
    {   EFBIG,  "EFBIG" },
    {   ENOSPC, "ENOSPC"    },
    {   ESPIPE, "ESPIPE"    },
    {   EROFS,  "EROFS" },
    {   EMLINK, "EMLINK"    },
    {   EPIPE,  "EPIPE" },
    {   EDOM,   "EDOM"  },
    {   ERANGE, "ERANGE"    },
    {   EWOULDBLOCK, "EWOULDBLOCK"  },
    {   EDEADLK, "EDEADLK" },
    {   EDEADLOCK, "EDEADLOCK"  },
    {   EINPROGRESS, "EINPROGRESS" },
    {   EALREADY, "EALREADY"    },
    {   ENOTSOCK, "ENOTSOCK"    },
    {   EDESTADDRREQ, "EDESTADDRREQ"    },
    {   EMSGSIZE, "EMSGSIZE"    },
    {   EPROTOTYPE, "EPROTOTYPE" },
    {   ENOPROTOOPT, "ENOPROTOOPT"  },
    {   EPROTONOSUPPORT, "EPROTONOSUPPORT"  },
    {   ESOCKTNOSUPPORT, "ESOCKTNOSUPPORT"  },
    {   EOPNOTSUPP, "EOPNOTSUPP"    },
    {   EPFNOSUPPORT, "EPFNOSUPPORT"    },
    {   EAFNOSUPPORT, "EAFNOSUPPORT"    },
    {   EADDRINUSE, "EADDRINUSE"    },
    {   EADDRNOTAVAIL, "EADDRNOTAVAIL"  },
    {   ENETDOWN, "ENETDOWN"    },
    {   ENETUNREACH, "ENETUNREACH"  },
    {   ENETRESET, "ENETRESET"  },
    {   ECONNABORTED, "ECONNABORTED"    },
    {   ECONNRESET, "ECONNRESET"    },
    {   ENOBUFS, "ENOBUFS"  },
    {   EISCONN, "EISCONN"  },
    {   ENOTCONN, "ENOTCONN"    },
    {   ESHUTDOWN, "ESHUTDOWN"  },
    {   ETOOMANYREFS, "ETOOMANYREFS"    },
    {   ECONNREFUSED, "ECONNREFUSED"    },
    {   ELOOP, "ELOOP"  },
    {   ENAMETOOLONG, "ENAMETOOLONG"    },
    {   EHOSTDOWN, "EHOSTDOWN"  },
    {   EHOSTUNREACH, "EHOSTUNREACH"    },
    {   ENOTEMPTY, "ENOTEMPTY"  },
    {   EPROCLIM, "EPROCLIM"    },
    {   EUSERS, "EUSERS"    },
    {   EDQUOT, "EDQUOT"    },
    {   EVDBAD, "EVDBAD"    }
#endif /* DOS */
};
static int errno_info_cnt = sizeof(errno_info)/sizeof(struct errno_info_s);
#endif

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RIScom_syserr(
	int			msgno,
	rissqlca	*dbcap)
{
	char *buf;
	int   size;

	if (dbcap)
	{
    	buf = dbcap->sqlerrm.sqlerrmc;
		size = sizeof(dbcap->sqlerrm.sqlerrmc);

		dbcap->sqlerrm.sqlerrml = (short)(puterr(msgno, buf, size));
		dbcap->sqlcode = msgno;
		dbcap->sqlcaid[5] = 'O';
		dbcap->sqlcaid[6] = 'S';
		dbcap->sqlcaid[7] = 'D';
	}
}

/******************************************************************************/

#if defined(unix) || defined(WIN32) || defined(DOS)

static int puterr(
	int	  msgno,		/* error number */
	char  *buf,			/* buffer to write to */
	int   maxbufl)		/* size of buffer */
{
	int len;
	char *errmsg;

	maxbufl--;	/* leave room for the null terminator */
	errmsg = strerror(msgno);
	len = strlen(errmsg);
	if (len > maxbufl) len = maxbufl;
	memcpy(buf, errmsg, len);
	buf[len] = '\0';

	return len;
}

#endif

#ifdef vms

static int puterr(
	int msgno,		/* error number */
	char  *buf,			/* buffer to write to */
	int   maxbufl)		/* size of buffer */
{
    struct {
        unsigned short length;
        unsigned char dtype;
        unsigned char class;
        char *buffer;
        } msgbuf;

  int len=0;
  int stat;
  int flags = 0x1;	/* basic message only */

  msgbuf.length = maxbufl;
  msgbuf.dtype = DSC$K_DTYPE_T;
  msgbuf.class = DSC$K_CLASS_S;
  msgbuf.buffer = buf;

  stat = SYS$GETMSG(msgno, &len, &msgbuf, flags, 0);
  if (stat != SS$_NORMAL)
  {
    if (stat == SS$_MSGNOTFND)
	{
      sprintf(buf, "Unknown OS error %d\n", msgno);
	  return;
	}
    else if (stat != SS$_BUFFEROVF)
	{
      sprintf(buf, "RIS internal error, trying to get message for error %d\n", 
		msgno);
	  return;
	}
  }  

  buf[len] = '\0';
  return len;
}

#endif

/******************************************************************************/

#if defined(unix) && !defined(sco) || defined(WIN32) || defined(DOS)

extern char *RIScom_get_errno_name(
	int no)
{
	int i;

	for (i = 0; i < errno_info_cnt; i++)
	{
		if (no == errno_info[i].no)
			return errno_info[i].name;
	}	

	return "Unknown Error";
}

#endif

/******************************************************************************/
