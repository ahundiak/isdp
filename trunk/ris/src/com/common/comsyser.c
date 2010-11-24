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
#include <stdio.h>
#include <errno.h>
#include <string.h>

#include "ris.h"
#include "riscom.h"

typedef struct errno_info_s
{
	int		no;
	char	*name;
} errno_info_s;


static errno_info_s errno_info[] = 
{
	{	EPERM,	"EPERM"	},
	{	ENOENT,	"ENOENT"	},
	{	ESRCH,	"ESRCH"	},
	{	EINTR,	"EINTR"	},
	{	EIO,	  "EIO"	},
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
	{	EDEADLK,	"EDEADLK"	},
	{	ENOLCK,	"ENOLCK"	},

	{	ENOSTR,	"ENOSTR"	},
	{	ETIME,	"ETIME"	},
	{	ENOSR,	"ENOSR"	},
	{	ENONET,	"ENONET"	},

	{	EREMOTE,	"EREMOTE"	},
	{	ENOLINK,	"ENOLINK"	},
	{	EADV,	"EADV"	},
	{	ESRMNT,	"ESRMNT"	},
	{	ECOMM,	"ECOMM"	},
	{	EPROTO,	"EPROTO"	},
	{	EMULTIHOP,	"EMULTIHOP"	},
	{	EBADMSG,	"EBADMSG"	},

	{	ENAMETOOLONG,	"ENAMETOOLONG"	},
	{	EWOULDBLOCK,	"EWOULDBLOCK"	},
	{	EINPROGRESS,	"EINPROGRESS"	},
	{	EALREADY,	"EALREADY"	},
	{	ENOTSOCK,	"ENOTSOCK"	},
	{	EDESTADDRREQ,	"EDESTADDRREQ"	},
	{	EMSGSIZE,	"EMSGSIZE"	},
	{	EPROTOTYPE,	"EPROTOTYPE"	},
	{	EPROTONOSUPPORT, "EPROTONOSUPPORT"	},
	{	ESOCKTNOSUPPORT, "ESOCKTNOSUPPORT"	},
	{	EOPNOTSUPP,      "EOPNOTSUPP"	},
	{	EPFNOSUPPORT,    "EPFNOSUPPORT"	},
	{	EAFNOSUPPORT,    "EAFNOSUPPORT"	},
	{	EADDRINUSE,	     "EADDRINUSE"	},
	{	EADDRNOTAVAIL,   "EADDRNOTAVAIL"	},
	{	ENETDOWN,	       "ENETDOWN"	},
	{	ENETUNREACH,     "ENETUNREACH"	},
	{	ENETRESET,       "ENETRESET"	},
	{	ECONNABORTED,	   "ECONNABORTED"	},
	{	ECONNRESET,      "ECONNRESET"	},
	{	ENOBUFS,         "ENOBUFS"	},
	{	EISCONN,         "EISCONN"	},
	{	ENOTCONN,        "ENOTCONN"	},
	{	ESHUTDOWN,       "ESHUTDOWN"	},
	{	ETOOMANYREFS,    "ETOOMANYREFS"	},
	{	ETIMEDOUT,       "ETIMEDOUT"	},
	{	ECONNREFUSED,	   "ECONNREFUSED"	},
	{	EHOSTDOWN,       "EHOSTDOWN"	},
	{	EHOSTUNREACH,    "EHOSTUNREACH"	},
	{	ENOPROTOOPT,     "ENOPROTOOPT"	}
};
static int errno_info_cnt = sizeof(errno_info)/sizeof(struct errno_info_s);

static int puterr(
  int   msgno,    /* error number */
  char *buf,      /* buffer to write to */
  int   maxbufl); /* size of buffer */

/******************************************************************************/

extern void RIScom_syserr(int msgno, rissqlca *dbcap)
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
