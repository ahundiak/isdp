/*
-------------------------------------------------------------------------------

	Name:			UNIXerrdef.h
	Author:			Yes
	Creation Date:		15-aug-1985
	Operating System(s):	Unix SYSV, v2
	Abstract:               Very

	 This file contains UNIX error definitions by symbol. These symbols
	 are of the form:

			UNIX_E_errorname

	 where "errorname" is the name of the error. When this file is
	 included in a module where the symbol UNIX_D_DEFINE_ERRMSG is

	 defined, then both the error symbols and a set of error messages
	 are created. The error messages are then known by a symbol:

			UNIX_E_erm_errorname

	 where "errorname" is the same as in UNIX_E_errorname.

	 Note that UNIX error codes follow OSA standards,  where:

	 bits <0-2>:	severity
			0	warning
			1	success
			2	error
			3	information
			4	severe (fatal) error
			5-7	undefined

	 bits <3-15>	message number (bit 15 set, since facility spec.)

	 bits <16-26>	facility (UNIX)

	Revision History:

-------------------------------------------------------------------------------
*/

#ifndef	UNIX_D_ERRORDEF
#define	UNIX_D_ERRORDEF	1

#ifndef	UNIX_FACILITY_CODE
#define	UNIX_FACILITY_CODE	0x252
#endif

#define	UNIX_WARN	0
#define	UNIX_SUCC	1
#define	UNIX_ERRO	2
#define	UNIX_INFO	3
#define	UNIX_SEVE	4

/*
-------------------------------------------------------------------------------

	Now we define the UNIX error symbols and messages.

-------------------------------------------------------------------------------
*/

#define UNIX_CONVERT_ERRNO(err_no) \
        (UNIX_FACILITY_CODE << 16)+0X8000+((err_no) << 3)+UNIX_ERRO



#define UNIX_E_EPERM (UNIX_FACILITY_CODE << 16)+0X8000+((1) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_EPERM[]=
{"UNIX-E-EPERM, Not a super-user\n"};
#endif

#define UNIX_E_ENOENT (UNIX_FACILITY_CODE << 16)+0X8000+((2) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_ENOENT[]=
{"UNIX-E-ENOENT, No such file or directory\n"};
#endif

#define UNIX_E_ESRCH (UNIX_FACILITY_CODE << 16)+0X8000+((3) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_ESRCH[]=
{"UNIX-E-ESRCH, No such process\n"};
#endif

#define UNIX_E_EINTR (UNIX_FACILITY_CODE << 16)+0X8000+((4) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_EINTR[]=
{"UNIX-E-EINTR, Interupted system call\n"};
#endif

#define UNIX_E_EIO (UNIX_FACILITY_CODE << 16)+0X8000+((5) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_EIO[]=
{"UNIX-E-EIO, I/O error\n"};
#endif

#define UNIX_E_ENXIO (UNIX_FACILITY_CODE << 16)+0X8000+((6) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_ENXIO[]=
{"UNIX-E-ENXIO, No such device or address\n"};
#endif

#define UNIX_E_E2BIG (UNIX_FACILITY_CODE << 16)+0X8000+((7) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_E2BIG[]=
{"UNIX-E-E2BIG, Argument list too long\n"};
#endif

#define UNIX_E_ENOEXEC (UNIX_FACILITY_CODE << 16)+0X8000+((8) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_ENOEXEC[]=
{"UNIX-E-ENOEXEC, Exec format error\n"};
#endif

#define UNIX_E_EBADF (UNIX_FACILITY_CODE << 16)+0X8000+((9) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_EBADF[]=
{"UNIX-E-EBADF, Bad file number\n"};
#endif

#define UNIX_E_ECHILD (UNIX_FACILITY_CODE << 16)+0X8000+((10) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_ECHILD[]=
{"UNIX-E-ECHILD, No children\n"};
#endif

#define UNIX_E_EAGAIN (UNIX_FACILITY_CODE << 16)+0X8000+((11) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_EAGAIN[]=
{"UNIX-E-EAGAIN, No more processes\n"};
#endif

#define UNIX_E_ENOMEM (UNIX_FACILITY_CODE << 16)+0X8000+((12) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_ENOMEM[]=
{"UNIX-E-ENOMEM, Not enough core\n"};
#endif

#define UNIX_E_EACCES (UNIX_FACILITY_CODE << 16)+0X8000+((13) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_EACCES[]=
{"UNIX-E-EACCES, Permission denied\n"};
#endif

#define UNIX_E_EFAULT (UNIX_FACILITY_CODE << 16)+0X8000+((14) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_EFAULT[]=
{"UNIX-E-EFAULT, Bad address\n"};
#endif

#define UNIX_E_ENOTBLK (UNIX_FACILITY_CODE << 16)+0X8000+((15) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_ENOTBLK[]=
{"UNIX-E-ENOTBLK, Block device required\n"};
#endif

#define UNIX_E_EBUSY (UNIX_FACILITY_CODE << 16)+0X8000+((16) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_EBUSY[]=
{"UNIX-E-EBUSY, Mount device busy\n"};
#endif

#define UNIX_E_EEXIST (UNIX_FACILITY_CODE << 16)+0X8000+((17) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_EEXIST[]=
{"UNIX-E-EEXIST, File exists\n"};
#endif

#define UNIX_E_EXDEV (UNIX_FACILITY_CODE << 16)+0X8000+((18) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_EXDEV[]=
{"UNIX-E-EXDEV, Cross-device link\n"};
#endif

#define UNIX_E_ENODEV (UNIX_FACILITY_CODE << 16)+0X8000+((19) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_ENODEV[]=
{"UNIX-E-ENODEV, No such device\n"};
#endif

#define UNIX_E_ENOTDIR (UNIX_FACILITY_CODE << 16)+0X8000+((20) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_ENOTDIR[]=
{"UNIX-E-NOTDIR, Not a directory\n"};
#endif

#define UNIX_E_EISDIR (UNIX_FACILITY_CODE << 16)+0X8000+((21) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_EISDIR[]=
{"UNIX-E-EISDIR, Is a directory\n"};
#endif

#define UNIX_E_EINVAL (UNIX_FACILITY_CODE << 16)+0X8000+((22) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_EINVAL[]=
{"UNIX-E-EINVAL, Invalid argument\n"};
#endif

#define UNIX_E_ENFILE (UNIX_FACILITY_CODE << 16)+0X8000+((23) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_ENFILE[]=
{"UNIX-E-ENFILE, File table overflow\n"};
#endif

#define UNIX_E_EMFILE (UNIX_FACILITY_CODE << 16)+0X8000+((24) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_EMFILE[]=
{"UNIX-E-EMFILE, Too many open files\n"};
#endif

#define UNIX_E_ENOTTY (UNIX_FACILITY_CODE << 16)+0X8000+((25) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_ENOTTY[]=
{"UNIX-E-ENOTTY, Not a typewriter\n"};
#endif

#define UNIX_E_ETXTBSY (UNIX_FACILITY_CODE << 16)+0X8000+((26) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_ETXTBSY[]=
{"UNIX-E-ETXTBSY, Text file busy\n"};
#endif

#define UNIX_E_EFBIG (UNIX_FACILITY_CODE << 16)+0X8000+((27) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_EFBIG[]=
{"UNIX-E-EFBIG, File too large\n"};
#endif

#define UNIX_E_ENOSPC (UNIX_FACILITY_CODE << 16)+0X8000+((28) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_ENOSPC[]=
{"UNIX-E-ENOSPC, No space left on device\n"};
#endif

#define UNIX_E_ESPIPE (UNIX_FACILITY_CODE << 16)+0X8000+((29) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_ESPIPE[]=
{"UNIX-E-ESPIPE, Illegal seek\n"};
#endif

#define UNIX_E_EROFS (UNIX_FACILITY_CODE << 16)+0X8000+((30) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_EROFS[]=
{"UNIX-E-EROFS, Read only file system\n"};
#endif

#define UNIX_E_EMLINK (UNIX_FACILITY_CODE << 16)+0X8000+((31) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_EMLINK[]=
{"UNIX-E-EMLINK, Too many links\n"};
#endif

#define UNIX_E_EPIPE (UNIX_FACILITY_CODE << 16)+0X8000+((32) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_EPIPE[]=
{"UNIX-E-EPIPE, Broken pipe\n"};
#endif

#define UNIX_E_EDOM (UNIX_FACILITY_CODE << 16)+0X8000+((33) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_EDOM[]=
{"UNIX-E-EDOM, Math argument out of domain of function\n"};
#endif

#define UNIX_E_ERANGE (UNIX_FACILITY_CODE << 16)+0X8000+((34) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_ERANGE[]=
{"UNIX-E-ERANGE, Math result not representable\n"};
#endif

#define UNIX_E_ENOMSG (UNIX_FACILITY_CODE << 16)+0X8000+((35) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_ENOMSG[]=
{"UNIX-E-ENOMSG, No message of desired type\n"};
#endif

#define UNIX_E_EIDRM (UNIX_FACILITY_CODE << 16)+0X8000+((36) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_EIDRM[]=
{"UNIX-E-EIDRM, Identifier removed\n"};
#endif

#define UNIX_E_ECHRNG (UNIX_FACILITY_CODE << 16)+0X8000+((37) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_ECHRNG[]=
{"UNIX-E-ECHRNG, Channel number out of range\n"};
#endif

#define UNIX_E_EL2NSYNC (UNIX_FACILITY_CODE << 16)+0X8000+((38) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_EL2NSYNC[]=
{"UNIX-E-EL2NSYNC, Level 2 not synchronized\n"};
#endif

#define UNIX_E_EL3HLT (UNIX_FACILITY_CODE << 16)+0X8000+((39) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_EL3HLT[]=
{"UNIX-E-EL3HLT, Level 3 halted\n"};
#endif

#define UNIX_E_EL3RST (UNIX_FACILITY_CODE << 16)+0X8000+((40) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_EL3RST[]=
{"UNIX-E-EL3RST, Level 3 reset\n"};
#endif

#define UNIX_E_ELNRNG (UNIX_FACILITY_CODE << 16)+0X8000+((41) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_ELNRNG[]=
{"UNIX-E-ELNRNG, Link number out of range\n"};
#endif

#define UNIX_E_EUNATCH (UNIX_FACILITY_CODE << 16)+0X8000+((42) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_EUNATCH[]=
{"UNIX-E-EUNATCH, Protocol driver not attached\n"};
#endif

#define UNIX_E_ENOCSI (UNIX_FACILITY_CODE << 16)+0X8000+((43) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_ENOCSI[]=
{"UNIX-E-ENOCSI, No CSI structure available\n"};
#endif

#define UNIX_E_EL2HLT (UNIX_FACILITY_CODE << 16)+0X8000+((44) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_EL2HLT[]=
{"UNIX-E-EL2HLT, Level 2 halted\n"};
#endif

#define UNIX_E_EDEADLK (UNIX_FACILITY_CODE << 16)+0X8000+((45) << 3)+UNIX_ERRO
#ifdef	UNIX_D_DEFINE_ERRMSG
static char UNIX_E_erm_EDEADLK[]=
{"UNIX-E-EDEADLK, Record locking deadlock\n"};
#endif

#endif


