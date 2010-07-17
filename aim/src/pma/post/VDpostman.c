/* $Id:*/
/*	-----------------------------------------------------------------------------
* 	To Compile on Clix: acc -g -c -DCLIX postman.c 
* 	To Compile and link on CLIX: acc -g -DCLIX postman.c -o postman.exe -lbsd

*	To compile and link on NT, consult Postman.doc on pmesrv:c:\users\sg\postman
*	To view this file properly with VISUAL C++, set tools/options/tab=8
*
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      10/3/95         SG              creation
 *	04/21/96	MSM		Modifications to compile & run on solaris.
 *	10/23/96	MSM		for CLIX_CONNECT use the input buffer
 *					to get the server's address instead of
 *					getting the variable from the environ.
 *
 *	Don't use this file to generate a stand alone executable.!!! 

*	----------------------------------------------------------------------------- */

#ifndef	CLIX
#ifndef	X11
#ifndef	_NT_P_
	GARBAGE - NO PLATFORM TYPE
#endif  
#endif  /* for X11 */
#endif

#include <errno.h>
#include <stdio.h>
#include <sys/types.h> 
#include <sys/stat.h> 
#include <signal.h>
#include <setjmp.h>

#if defined(CLIX) || defined (X11)
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#endif	/* CLIX */


#if defined(_NT_P_)
#	include <process.h>
#	include <winsock.h>
#	include <io.h>
#	include <stdlib.h>

#	define _CLMAIN_DEFNS					/* DM2 */
#	include <cl.h>
#	include <msgomf.h>
#	include <sc.h>
#	include <sm.h>						/* ? */
#	include <oi.h>
#	include <rpc.h>					/* ? */
#	include <msgpme.h>
#endif  /* _NT_P_ */

#ifdef 	_NT_P_
typedef unsigned int		uint;
#endif	/* _NT_P_ */

typedef char			ascii_char;
typedef uint			Boolean;


#define POSTMAN_PORTNO		9083			/* socket portno on NT */
#define POSTMAN_MAGICNO		1234567876		/* good buffer identifier prefix */
							
#define SET_ALARM		0
#define UNSET_ALARM		1
#define SIZEOFNULLBYTE		1			/* string terminator size */

#define BUFFERCOUNT		5			/* number of buffers */
#define READBUFFER		1			
#define PACKEDBUFFER		2
#define ERRMSGBUFFER		3
#define CONSOLEBUFFER		4
#define ASCIIFYBUFFER		5

#define RANDOM_MOMENT		time(0)%3+1		/* randomly 1 to 3 seconds */
#define SECONDS			60			/* seconda per minute */
#define RECVWAIT		10			/* min to wait b4 recv call fails; */
							/* peer process hung? */

#define UPPINGDELTA		10000			/* realloc delta */
#define SAFETYNUM		5			/* just a safety factor to avoid +1 errors */
#define SAFETYNUM2		10			/* another very safe +1 error guard */
#define ASCIIFYING_FACTOR	2			/* our encoding scheme 4-bit -> 1byte */
#define BIGENUFMSGBUF		500			/* dirty/temp long enuf msg buffer */
#define MAXHOSTNAME		30			/* machine host name max size */

#define POSTMAN_CHUNKSIZE	100000			/* mx buffersize for tcp/ip */
							/* read/write set with setsocket */
							/* option. Not a problem on CLIX */
#define POSTMAN_CHUNKSIZE_SAFE	2000 			/* a safe value if errors */

							/* copy a length of c including null */
#define	STRNCPY(a,b,c) 		(strncpy(a, b, c),a[c-1] = '\0')

							/* return required size to asciify */
#define Asciifying_Size(len)    (len*ASCIIFYING_FACTOR \
				+ SAFETYNUM * SIZEOFNULLBYTE)

							/* expect at least this length to/from postman */
							/* dstat, mfail, errmsg (null); data maybe len=0 */
#define MINBUFLEN_POSTMAN	sizeof(int)+sizeof(int)+SIZEOFNULLBYTE
#define BLOCKSIZE		512
#define MAXBUFLEN_POSTMAN	100000 * BLOCKSIZE	/* GETBUFFER() checks bad number */

#define NULLC			(char*)NULL
#define TRUE			1
#define FALSE			0

#define NOVAL			3345			/* my own weird no. for special argument */
#define NOVALC			(char*)NOVAL		

#define AMSG			20000			/* Our message number biasing constant */
							/* ... to distinguish from system message nos. */
#define Bias(a)			(AMSG+a)		/* biasing short hand */
#define UnBias(a)		(a-AMSG)

#define RETRY_COUNTER		2			/* socket connection attempts */
#define MINASCIICODE		32			/* added to asciify each 4-bit */
#define SPACE			32

#define HALFBYTEMASK		0xf			/* masks out 1/2 byte */
#define HALFBYTESHIFT		4			/* shifts 1/2 byte */
#define PREVIOUS		-1			/* getbuffer() flag */

#define PROXY_CLIENT_ADDRESS	"PROXY_CLIENT_ADDRESS"	/* export PROXY_CLIENT_ADDRESS="129.135.201.198" */

#define BINARY_NAME		"postman.exe"
#define POSTMANFORUSER		"Postman"

#define NT_ERROR		12346			/* function code if NT postman error */
#define CLIX_ERROR		12345			/* function return code on clix side errors */

							/* SETERRNO flags */
#define	FROMCRUNTIME		0			/* set error from cruntine */
#define	FROMWINAPI		1			/* set error from LastError */
#define	GETERROR		2			/* get last error */
#define	GETMSGSOU		3			/* get message source */
#define	FROMPARAM		4			/* set from func parameter; msgsou=WINAPI */

#define JMPSTAT			1			/* status returned via longjmp */

/*
#ifdef  CLIX
#define MSG_PREFIX		"CLIX:"	
#define OKAY			0
#endif

#ifdef  X11
#define MSG_PREFIX		"SOLARIS:"
#define OKAY			0
#endif
*/

#if defined (CLIX) || defined (X11)
#define	EXIT_SUCCESS		0			/* these are defined for NT */
#define	EXIT_FAILURE		1

#define MSG_PREFIX		"CLIX:"			/* error msg prefix for clix side errors */
#define OKAY			0

#define CLIX_CONNECT		-1			/* flag to connect socket */
#define CLIX_DISCONNECT		-2			/* flag to disconnect socket */
#endif	/* CLIX */

#ifdef	_NT_P_
#define TESTKEY			't'
#define SOCKET_SPAWN		' '			/* spawn after each connection */
#define SOCKET_SPAWN_CONSOLE	'w'			/* ditto but create separate console for messages */
#define SOCKET_NO_SPAWN		'y'			/* no spawn socket connection */
#define INTERNAL_SPAWN		'z'			/* internal spawn after sokcet connection */

#define POSTMAN_PROCESS		FALSE
#define INETD_PROCESS		TRUE			/* just args for process info printer */

#define MSG_PREFIX		POSTMANFORUSER":"

#define TARGETCLASS		"PmPost"

							/* CONSOLE HANDLING CONSTANTS */
#define MAXCONSOLEBUF		UPPINGDELTA - SAFETYNUM2/* max len of messages accumulated from console */
#define MAXCONSOLELINE		200			/* longest line read from console buffer */
#define MINCONSOLEHEIGHT	500			/* console height to set so user can scroll */
#define CHECKCONSOLEWIDTH	300			/* if console wider than this, don't change height */
							/* ... could be memory problem */
#define	CONSOLE_DIVIDER		" -- --- ---- --- --"	/* demarcates new messages on console */

							/* flags for console line manipulation */
	typedef enum consolemsg {CONSTART, CONADD, CONFINIS} CONSOLEMSG;


#define	WINSOCKBIAS		10000
#define	WINSOCKBIAS2		11000
#define	ADDRESS_IN_USE		WINSOCKBIAS + 48	/* winapi error no when portno already in use */

#define sleep(a)		Sleep((a)*1000)
#define INDEFINITELY		1000000			/* seconds; indefinite sleep */

#define LISTEN_CONSTANT		5			/* some number for listen call - from reference text */
#endif	/* _NT_P_ */

	/** Functions common between nt/clix */
static	void 		ALARMING ();
static 	void 		GET_BUFFER (int, int, char**);
static 	void 		JUMPOUT (int, char*, int);
static 	void 		PACK_POSTMAN_BUFFER (int*, char**, int, char*, int, int, ascii_char*);
static  void 		POSTMAN_ASCIIFY (int, char*, ascii_char*);
static  void 		POSTMAN_UNASCIIFY (ascii_char*, char*, int*);
static  void 		SETERRMSG (int, char*, int);
static 	int  		SETERRNO ();
static  void 		SOCKET_CLOSE ();
static 	void 		SOCKET_READ (char**, int*, int*, int*, ascii_char**, Boolean*, Boolean);
static  void 		SOCKET_READ_CHUNK (int, char*, Boolean*);
static  void 		SOCKET_READ_SYNC ();
static 	void 		SOCKET_SELECT ();
static	void 		SOCKET_WRITE (char*, int, int, int, ascii_char*, Boolean);
static	void 		SOCKET_WRITE_CHUNK (int, char*);
static  void 		SOCKET_WRITE_SYNC ();
static 	void 		UNPACK_POSTMAN_BUFFER (int, char*, int*, char**, int*, int*, ascii_char**);
	/** End functions common between nt/clix */


#if defined (CLIX) || defined (X11)
static 	void 		ALARMER ();
static  void 		CLIX_SET_HOSTNAME ();
static 	ascii_char 	*GET_PROXY_CLIENT_ADDRESS ();
static	void 		POSTMAN_CONNECT_ON_CLIX ();
static  void 		POSTMAN_GET_INIT_DATA (int*, ascii_char**);
	int  		POSTMAN_REQUEST_ON_CLIX (int, char*, int*, char**, int*, ascii_char**);
#endif  /* CLIX */

#ifdef	_NT_P_
static void 		BE_INFORMATIVE (Boolean);
static void 		CLIX_SET_HOSTNAME ();
static void		CONSOLE_INIT ();
static Boolean 		CONSOLE_MSG_ADD (CONSOLEMSG, char*);
static void 		CONSOLE_READ ();
static void		CONSOLE_WRITE_DIVIDER ();
static void 		GET_CLIX_ADDRESS ();
static void 		MAIN_ERROR_HANDLER ();
static void 		NTMsg (int, char, char*, int);
static void 		POSTMAN ();
static void 		POSTMAN_CLOSE ();
static void 		POSTMAN_INIT ();
static void 		POSTMAN_SOCKET_INIT (Boolean);
static void 		POSTMAN_SERVICE_STANDALONE (int, char**);
static void 		POSTMAN_INETD ();
static void 		PRINT_FIRST_LINE (ascii_char*);
static void 		SOCKET_DUMMY_READ (); 
static int  		SPAWNPOSTMAN (char*, Boolean, int*);
static void 		TcpStartup ();
static void 		WINAPI_ERR_MSG ();
static void 		WINSOCK_ERR_MSG ();
       void 		mservSetCallbacks();
#endif	/* _NT_P_ */

	static ascii_char *MsgOrigins [] = {			/* message originations */

#define		MOID_NO_MSG					0		
		"",

#define		MOID_ACCEPT_SOC					1
		"Accepting Socket",

#define		MOID_BIND_SOC					2
		"Binding Socket",

#define		MOID_CALLING_POSTMAN				3
		"Sending Message To DM2",

#define		MOID_CANT_READ_FULL				4
		"Cannot Read Full Socket Buffer",

#define		MOID_CANT_WRITE_FULL				5
		"Cannot Write Full Socket Buffer",

#define		MOID_CHECKING					6
		"Checking",

#define		MOID_CLIENT					7
		"ClInitialize",

#define		MOID_CONN_SOC					8
		"Connecting Socket",			

#define		MOID_LOWERR_INIT				9
		"Doing low_err_init",

#define		MOID_OPEN_SOC					10
		"Opening Socket",			

#define		MOID_PACK_BUFF					11
		"Packing Buffer",

#define		MOID_READ_BUFSIZE				12
		"Reading TCP Buffersize",

#define		MOID_READ_INIT					13
		"Reading Init Requst From Clix",

#define		MOID_READ_SOC					14
		"Reading Socket",

#define		MOID_READ_SYNC					15
		"Reading Sync Packet",

#define		MOID_REALLOC_MALLOC				16
		"Realloc/Malloc",

#define		MOID_SELECT_SOC					17
		"Selecting On Socket",

#define		MOID_SPAWN_POST					18
		"Spawning "POSTMANFORUSER,

#define		MOID_START_TCP					19
		"Starting Tcp/Ip",

#define		MOID_UNPACK_BUFF				20
		"Unpacking Buffer",

#define		MOID_WRITE_SOC					21
		"Writing Socket",

#define		MOID_WRITE_SYNC					22
		"Writing Sync Packet",

	};

	static ascii_char *Msgs [] = {				/* MESSAGES */

#define		MSGID_NOMSG					0
		"",

#define		MSGID_ACTUAL_READ				1
		"Actual Bytes Read %d",

#define		MSGID_BAD_MSG_CALL				2
		"BAD Internal Call To NTmsg, Code %",

#define		MSGID_BAD_SERVER_CALL				3
		"Bad call/return to/from server",

#define		MSGID_BUF_TOO_BIG				4
		"Buffer Size Too Big; needed %d, allowed %d",

#define		MSGID_CLIENT_INIT_ERR				5
		"Cannot Initialize Client",

#define		MSGID_CLIX_ADDRESS				6
		" Clix Address = %s",

#define		MSGID_CLIX_NAME					7
		" Clix Host    = %s",

#define		MSGID_DM2_ALREADY_UP				8
		"DM2/"POSTMANFORUSER" Already Initialized",

#define		MSGID_DM2_NOT_INITIALIZED			9
		POSTMANFORUSER" and/or DM2 Not Initialized",

#define		MSGID_INETD_DAEMON				10
		" Unconnected "POSTMANFORUSER" Inetd Daemon",

#define		MSGID_INVALID_BUF				11
		"Received Invalid Buffer",

#define		MSGID_KILLME					12
		"...Ctrl-C To Kill Me ......",

#define		MSGID_LOW_ERR_INIT_PROBLEM			13
		"Cannot low_err_init "POSTMANFORUSER,

#define		MSGID_LOW_ERR_INIT_STAT				14
	        "low_err_init returned dstat = %d",

#define		MSGID_NOSYS_MSG					15
		"No System Error Message",

#define		MSGID_NOT_ENUF_FIELDS				16
		"Incorrect Buffer Format - Not Enough Fields",

#define		MSGID_NO_NT_C_MSG				17
		"No NT Message - C RunTime Error %",

#define		MSGID_NO_NT_SOC_MSG				18
		"No NT Message - Socket Error %",

#define		MSGID_NO_NT_WINAPI_MSG				19
		"No NT Message - WinApi Error %",

#define		MSGID_OTHER_CLOSED				20
		"Connection Closed By Other Side",

#define		MSGID_POSTMAN_PORTNO				21
		"("POSTMANFORUSER" Portno %d) %s",

#define		MSGID_PROC_ID					22
		" Process Id   = %d\n Started At   = %s",

#define		MSGID_PROC_INFO					23
		" ---- Process Information ----",

#define		MSGID_PROXY_UNDEFINED				24
		"Env Variable "PROXY_CLIENT_ADDRESS" Not Found",

#define		MSGID_SEE_SOURCE_FILE				25
		"See postman.c Main Functions For Options",

#define		MSGID_SERVER_TAG				26
		" "POSTMANFORUSER" Server Connected To Clix Host",

#define		MSGID_SOC_TIMED_OUT				27
		"Socket Read Request Timed Out",

#define		MSGID_TCPIP_BAD_VERSION				28
		"Tcp/Ip Version Mismatch",

#define		MSGID_TERMINATE_ALL				29
		"Please Terminate All "BINARY_NAME" Processes",

#define		MSGID_TOO_SHORT_BUF				30
		"Buffer Lenght Too Short",
	};

#ifdef 	_NT_P_
	static ascii_char *HelpText   =
		" \n\n"
		" VDS<->DM2 Communication Link Via NT\n\n"
		" "POSTMANFORUSER" invocation:\n\n"
		" %s [-twy] [test-string]\n\n"
		" where:\n\n"
		" no options       production mode invocation\n\n"
		" -t               testing option, no VDS connection possible;\n"
		"                  will use <test-string> supplied to talk to DM2;\n"
		"                  mainly useful for set-up check\n\n"
		" -w               same as invoking without options, except a console\n"
		"                  with identifying messages will be displayed for each\n"
		"                  incoming VDS connection\n"
	;

	static ascii_char *sockerr [] = {"",
		"",					/* 1 - 4 */
		"",
		"",
		"Interrupted System Call",		/* WSAEINTR  (WSABASEERR+4) */
			
		"",					/* 5 - 8 */
		"",
		"",
		"",
							/* 9 - 12 */
		"Bad File Number",			/* WSAEBADF  (WSABASEERR+9) */
		"",
		"",
		"",
	
		"Permission Denied",			/* WSAEACCES  (WSABASEERR+13) */
		"Bad Address",				/* WSAEFAULT  (WSABASEERR+14) */
		"",
		"",

		"",					/* 17 - 20 */
		"",
		"",
		"",

		"",					/* 21 - 24 */
		"Invalid Argument",			/* WSAEINVAL  (WSABASEERR+22) */
		"", 
		"Too Many Open Files",			/* WSAEMFILE  (WSABASEERR+24) */

		"",					/* 25 - 28 */
		"",
		"",
		"",

		"",					/* 29 - 32 */
		"",
		"",
		"",

		"",					/* 33 - 36 */
		"",
		"Operation would block",		/* WSAEWOULDBLOCK (WSABASEERR+35) */
		"Operation now in progress",		/* WSAEINPROGRESS (WSABASEERR+36) */

							/* 37 - 40 */
		"Operation already in progress",	/* WSAEALREADY (WSABASEERR+37) */
		"Socket operation on non-socket",	/*WSAENOTSOCK (WSABASEERR+38) */
		"Destination address required", 	/* WSAEDESTADDRREQ (WSABASEERR+39) */
		"Message too long",			/* WSAEMSGSIZE (WSABASEERR+40) */

							/* 41 - 44 */
		"Protocol wrong type for socket",	/*WSAEPROTOTYPE (WSABASEERR+41) */
		"Protocol not available",		/* WSAENOPROTOOPT (WSABASEERR+42) */
		"Protocol not supported",		/* WSAEPROTONOSUPPORT (WSABASEERR+43) */
		"Socket type not supported", 		/* WSAESOCKTNOSUPPORT (WSABASEERR+44) */

							/* 45 - 48*/
		"Operation not supported on socket",	/* WSAEOPNOTSUPP (WSABASEERR+45) */
		"Protocol family not supported",	/* WSAEPFNOSUPPORT (WSABASEERR+46) */
		"Address family not supported by protocol family", /* WSAEAFNOSUPPORT (WSABASEERR+47) */
		"Address already in use",		/* WSAEADDRINUSE (WSABASEERR+48) */

							/* 49 - 52 */
		"Can't assign requested address",	/*WSAEADDRNOTAVAIL (WSABASEERR+49) */
		"Network down",				/* WSAENETDOWN (WSABASEERR+50) */
		"Network unreachable", 			/* WSAENETUNREACH (WSABASEERR+51) */
		"Network dropped connection on reset", 	/* WSAENETRESET (WSABASEERR+52) */

							/* 53 - 56 */
		"Software caused connection abort", 	/* WSAECONNABORTED (WSABASEERR+53) */
		"Connection reset by peer", 		/* WSAECONNRESET (WSABASEERR+54) */
		"No buffer space available", 		/* WSAENOBUFS (WSABASEERR+55) */
		"Socket already connected",  		/* WSAEISCONN (WSABASEERR+56) */

							/* 57 - 60 */
		"Socket not connected", 		/* WSAENOTCONN (WSABASEERR+57) */
		"Can't send after socket shutdown", 	/* WSAESHUTDOWN (WSABASEERR+58) */
		"Too many references: can't splice",	/* WSAETOOMANYREFS (WSABASEERR+59) */
		"Connection timed out",			/* WSAETIMEDOUT (WSABASEERR+60) */

							/* 61 - 64 */
		"Connection refused", 			/* WSAECONNREFUSED (WSABASEERR+61) */
		"Socket Looping", 			/* ?? WSAELOOP  (WSABASEERR+62) */
		"Filename or Pathname too long",	/* WSAENAMETOOLONG (WSABASEERR+63) */
		"Host is down", 			/* WSAEHOSTDOWN (WSABASEERR+64) */

							/* 65 - 68 */
		"No route to host", 			/* WSAEHOSTUNREACH (WSABASEERR+65) */
		"",
		"",
		"", 

							/* 69 - 72 */
		"",
		"",
		"",
		"", 
							/* 73 - 76 */
		"",
		"",
		"",
		"", 
							/* 77 - 80 */
		"",
		"",
		"",
		"", 
							/* 81 - 84 */
		"",
		"",
		"",
		"", 
							/* 85 - 88 */
		"",
		"",
		"",
		"", 
							/* 89 - 92 */
		"",
		"",
		"NetWork Subsystem Unusable",		/* WSASYSNOTREADY (WSABASEERR+91) */
		"Socket DLL Cannot Support", 		/* WSAVERNOTSUPPORTED (WSABASEERR+92) */

							/* 93 - 96 */
		"Sockets Not Initialized", 		/* WSANOTINITIALISED (WSABASEERR+93) */
		"",
		"",
		"",
	};

	static ascii_char *sockerr2 [] = {"",
		"",

		"Host Not Found",	 				/* WSAHOST_NOT_FOUND (WSABASEERR+1001) */
		"Try Again; Host not found",				/* WSATRY_AGAIN  (WSABASEERR+1002) */
		"Non-recoverable errors: FORMERR, REFUSED, NOTIMP", 	/* WSANO_RECOVERY (WSABASEERR+1003) */
		"Valid name, no data record of requested type", 	/* WSANO_DATA (WSABASEERR+1004) */
	};
#endif  /* _NT_P_ */

/* ---------------------- Postman Protocol-related Items ------- */

#define POSTMAN_MAGICNO		1234567876		/* good buffer identifier prefix */

							/* packettype CONSTANTS */
#define FULL_BUFFER		1			/* needs packing buffer on CLIX */
#define LEAN_BUFFER		2			/* no mfail etc; saves packing space */

							/* request CONSTANTS */
#define INIT_REQUEST		100			/* first dummy initialize request from clix */
#define SYNC_REQUEST		101			/* syncing packet while reading/writing */
#define CHUNKSIZE_INFO		102			/* chunksize information */

		/* ------ Header Packet Structure -------- */
	typedef struct  header		{		/* postman protocol packet identifier */
		int		magicno;		/* POSTMAN MAGIC NUM - check for valid packets */
		int		packettype;		/* packet type - see #define constants */
		int		bytecount;		/* bytecount of data buffer to follow separately */
	} HEADER;					/* header packet is sent by itself, then data */

		/* ------ Data Packet Structures -------- */
	typedef union  pmdatabuf	{		/* postman buffer format */
		union fullbufTag  {
			struct pmebufTag  {		/* dm2 communication */		  
		   		int 	dstat;		/* method function return code */
				int 	mfail;		/* method return code via argument */
				char	buf[1];		/* errmsg string (null-term), rest .. */
							/* nonascii or null-terminated ascii data */							
			} pmebuf;
			struct	postmanTag {		/* only postman<->clix communication */
				int	request;	/* see #defines */
				int	info;		/* depends on request */
				char	buf[1];		/* not used */
			} postman;
		} fullbuf;
		union leanbufTag  {			/* lean buffer - no packing buffer needed */
			struct pmebufTag2  {		/* DM2 request from CLIX */
				char	data[1];	/* nonascii or null-terminated ascii data */
			} pmebuf;
		} leanbuf;
	} PMDATABUF;
/* ---------------------- End Postman Protocol-related Items ------- */

	typedef struct  globaldata	{		/* some file global data */
		jmp_buf			jmpbuf;		/* global jump buffer */
		Boolean			alarmed;	/* socket read has timed out */
		int			chunksize;	/* send big buffer in chunks of this size */
		Boolean			socketopen;	/* TRUE if socket has been opened */
		int			socket;		/* opened socket  */
		ascii_char		clixhost[MAXHOSTNAME];
#if defined (CLIX) || defined (X11)
		struct sockaddr_in	cserver;	/* connected proxy client  */
		uint			tcpip;		/* proxy client's address */
#endif
#ifdef _NT_P_
		char			*postman_path;	/* binary name from argv[0] */
		fd_set			waitsock;	/* needed for SELECT_SOCKET() */
		int			listeningsocket;/* socket after accepted connection */
		struct sockaddr		sockname;
		Boolean			DM2_client_inited;	
		ascii_char		visible_console;/* console can be seen */
		ascii_char		opletter;	/* option letter */

							/* CATASTROPHIC ERROR NOTIFICATION OF VDS */
		int			errcode;	/* catastrophic error to send to VDS */
							

							/* CONSOLE MESSAGE-RELATED */
		Boolean			consoleOk;	/* TRUE if console inited properly */
		HANDLE			constdout;	/* console stdout handle */
		CONSOLE_SCREEN_BUFFER_INFO csbinfo;     /* console buffer info */
		CHAR_INFO		*cin;		/* console buffer data */
#endif
	} GLOBALDATA;


	static GLOBALDATA	GB;
	extern 			sys_nerr;
	extern int		errno; 
	static char		proxy_client_address[50];


#if defined (CLIX) || defined (X11)
#if	0				/* set to 1 for testing on CLIX */
	void main (argc, argv)
/*	----------------------------
*	any string for testing
*	---------------------------- */
	int 	   argc;
	ascii_char *argv[];
/*	---------------------------- */
{{{	int		outlen, i, dstat, mfail/*, k=1*/;
	ascii_char	*databuf, *errmsg=0;
	unsigned char	abc[] = {'t', 's', 0};
	int  osize=1; 
	char *obor; 
/*	---------------------------- */
	obor = (char *)malloc(1);
	if (argc < 2) {
	   printf ("FROM CLIX:  Need an argument/n");
	   exit (1);
	}

	dstat = POSTMAN_REQUEST_ON_CLIX (CLIX_CONNECT, NULL,NULL,NULL,NULL,&errmsg);
	if (dstat) {printf ("Error Connecting; %s\n", errmsg); exit (1);}
	for (i=0; i<100; i++) { 
#if 1
		/*osize *= 2; if (osize > 2) */
		osize = 1048576;
		obor = (char *)realloc (obor, osize);
		if (!obor) {printf ("shucked off at %d", osize); exit (1);}
		else printf ("Current size %d\n", osize);
		memset (obor, 'a', osize-1); obor[osize-1] = '\0';
		obor[osize-2] = 'z';
		outlen = 0;

		dstat = POSTMAN_REQUEST_ON_CLIX (osize, (char*)obor, 
					 &outlen, 
				  	 (char**)&databuf,
				  	 &mfail, 
				  	 &errmsg);
#endif
#if 0
		dstat = POSTMAN_REQUEST_ON_CLIX (strlen (argv[1])+1,
					 (char*)argv[1], 

					 &outlen, 
				  	 (char**)&databuf,
				  	 &mfail, 
				  	 &errmsg);
#endif
#if 0
		dstat = POSTMAN_REQUEST_ON_CLIX (sizeof abc,
					 (char*)abc, 
					 &outlen, 

				  	 (char**)&databuf,
				  	 &mfail, 
				  	 &errmsg);
#endif
		/* server should sent in a null term string */
		/* if not do it here. But don't do in vds */
		/* you don't know how big buffer is */
/*		if (!dstat && !mfail) databuf[outlen] = '\0';	
*/
		printf (" data sent = %s\n", argv[1]);
		printf (" Results:\n");
		printf (" dstat = %d, mfail = %d outlen = %d\n", dstat, mfail, outlen);
		printf (" errmsg = %s\n", errmsg);
		if (!outlen) continue;
		if (outlen < 80) printf (" Data returned = %s\n", databuf);
		else {
	 	   char a = databuf [30]; databuf[30] = '\0'; 
	 	   printf (" Data returned = %s\n %s\n", databuf, &databuf[outlen-30]);
		   databuf[30] = a;
		}
	}
	dstat = POSTMAN_REQUEST_ON_CLIX (CLIX_DISCONNECT, NULL, NULL, NULL, NULL,  &errmsg);
	if (dstat) {printf ("Error Disconnecting; %s\n", errmsg); exit (1);}
}}}
#endif		/* end "reset to 1 for testing" */

	int POSTMAN_REQUEST_ON_CLIX (	inbuflen,
					inbuf, 

				  	outbuflen, 
				  	outbuf, 
				  	mfail, 
				  	errmsg)
/*	------------------------------------------------
*	Omnibus call to DM2 server from VDS

*	HANDLING Return Codes:
*	Good function return is OKAY (=0); else check
*	errmsg. If Function return OKAY, check mfail
*	(return code from DM2 server) which should be
*	OKAY also. Else check errmsg as well

*	FUNCTION Behavior:
*	To open  socket: POSTMAN_REQUEST_ON_CLIX 
		(CLIX_CONNECT,NULL,NULL,NULL,NULL,&errmsg);
*	To close socket: POSTMAN_REQUEST_ON_CLIX 
		(CLIX_DISCONNECT,NULL,NULL,NULL,NULL,&errmsg);

*	In both cases, if function return not OKAY, check errmsg

*		!!! WARNING !!! WARNING !!!
*	Output parameters outbuffer and errmsg will be 
*	DEALLOCATED next time this function is called.
*	DO NOT ALLOCATE/DEALLOCATE THEM, or COUNT ON THEM 
*	FOR SAVING DATA or MODIFY THEM past outbuflen
*	------------------------------------------------ */
	int		inbuflen;	/* i: data length of inbuffer */
					/* i: also open/close flag - see above */

	char		*inbuf;		/* i: buffer containing data to send */
					/*    if NULL, close socket connection */
					/*    WARNING! not ascii buffer */
	int		*outbuflen;	/* o: data length of outbuffer */
	char		**outbuf;	/* o: buffer containing returned data */
	int		*mfail;		/* o: message return code (in-line arg) */
	ascii_char	**errmsg;	/* o: non-null string if error */
/*	------------------------------------------------ */
{{{	int		len, jmpstat, dstat;
	ascii_char	*asciibuf;
/*	------------------------------------------------ */
	jmpstat = setjmp (GB.jmpbuf);	
	if (jmpstat) {			/* returned after error via longjmp */
	   GET_BUFFER (ERRMSGBUFFER, PREVIOUS, (char **)errmsg);
	   return CLIX_ERROR;
	}

	if (inbuflen == CLIX_CONNECT) {
	   strcpy(proxy_client_address, inbuf ); /* Instead of using putenv & getenv send the address as inbuf */

	   POSTMAN_CONNECT_ON_CLIX ();
	   POSTMAN_GET_INIT_DATA (&dstat, errmsg);
	   return dstat;
	}

	if (inbuflen == CLIX_DISCONNECT) {
	   if (!GB.socketopen) JUMPOUT (Bias(MSGID_DM2_NOT_INITIALIZED), NOVALC, NOVAL);
	   SOCKET_CLOSE ();
	   return OKAY;
	}
	if (!GB.socketopen) JUMPOUT (Bias(MSGID_DM2_NOT_INITIALIZED), NOVALC, NOVAL);

	GET_BUFFER (	ASCIIFYBUFFER, 	/* get a properly allocated buffer */
			Asciifying_Size(inbuflen), 
			(char**)&asciibuf);	

					/* dm2 messages accept strings only */
	POSTMAN_ASCIIFY (inbuflen, inbuf, asciibuf);
	len = strlen (asciibuf) + 1;
	SOCKET_WRITE (asciibuf, len,  NULL, NULL, "", FALSE);
	*outbuf = (char*)0, *outbuflen = 0;
	SOCKET_READ  (outbuf, &len,  &dstat, mfail, errmsg, NULL, FALSE);
	if (*outbuf) POSTMAN_UNASCIIFY ((ascii_char*)*outbuf, *outbuf, outbuflen);
	return dstat;
}}}

	void POSTMAN_CONNECT_ON_CLIX ()
/*	------------------------------------------------
*	If not connected, establish connection with postman
*	on NT
*	------------------------------------------------ */
{{{	struct sockaddr_in *sv = &GB.cserver;
	int		j, retstat;
/*	------------------------------------------------ */
	if (GB.socketopen) JUMPOUT (Bias(MSGID_DM2_ALREADY_UP), NOVALC, NOVAL);
	for (j=0; j<RETRY_COUNTER; j++) {			/* avoid very occasional "refused connec" ... */
	   GB.socket = socket (AF_INET, SOCK_STREAM, IPPROTO_TCP);
	   if (GB.socket < 0) 
		JUMPOUT (SETERRNO(FROMWINAPI, NULL), NOVALC, MOID_OPEN_SOC);
	   GB.socketopen = TRUE;
	   memset (sv, 0, sizeof *sv);
	   GB.tcpip = inet_addr (GET_PROXY_CLIENT_ADDRESS ());
	   memcpy (&sv->sin_addr, &GB.tcpip, sizeof(int));
	   sv->sin_family = AF_INET;
	   sv->sin_port = htons (POSTMAN_PORTNO);

	   retstat = connect (GB.socket, (struct sockaddr *)sv, sizeof (*sv));
	   if (!retstat) break;
	   if (SETERRNO (FROMWINAPI, NULL) != ECONNREFUSED) break;
	   if (!j) {sleep (RANDOM_MOMENT); SOCKET_CLOSE ();}
	}

	GB.chunksize = POSTMAN_CHUNKSIZE_SAFE;
	if (!retstat) return;
	SOCKET_CLOSE ();
	JUMPOUT (SETERRNO(FROMWINAPI, NULL), NOVALC, MOID_CONN_SOC);
}}}

	static void POSTMAN_GET_INIT_DATA (dstat, errmsg)
/*	------------------------------------------------
*	After connecting socket, get initialization data
*	and errors
*	------------------------------------------------ */
	int		*dstat;		/* o: initialization errors */
	ascii_char	**errmsg;	/* o: error messages */
/*	------------------------------------------------ */
{{{	int		len, code, size,  mfail;
	char		*outbuf, *chost;
/*	------------------------------------------------ */
	CLIX_SET_HOSTNAME ();
	chost = GB.clixhost, len = strlen (GB.clixhost);
	SOCKET_WRITE (chost, len, INIT_REQUEST, NULL, "", FALSE);	/* authenticate VDS to POSTMAN */

									/* read chunksize from  NT */
	SOCKET_READ  (&outbuf, &len,  &code, &size, errmsg, NULL, FALSE);
	GB.chunksize = POSTMAN_CHUNKSIZE_SAFE;
	if (code == CHUNKSIZE_INFO) {
	   GB.chunksize = size;
	   if (size <= 0) GB.chunksize = POSTMAN_CHUNKSIZE_SAFE;
	} else if (code == NT_ERROR) {					/* probably spawn error */
	   *dstat = code;
	   return;
	} else JUMPOUT (Bias(MSGID_INVALID_BUF), NOVALC, MOID_READ_BUFSIZE);

									/* read DM2/POSTMAN  init error for NT */
	SOCKET_READ  (&outbuf, &len, dstat, &mfail, errmsg, NULL, FALSE);
}}}

	static void CLIX_SET_HOSTNAME ()
/*	-----------------------------------------------
*	set clix machine host name. 
*	Note: SAFETYNUM used to avoid last null byte
*	past given size problem
*	----------------------------------------------- */
{{{
/*	----------------------------------------------- */
	memset (GB.clixhost, 0, sizeof GB.clixhost);
	gethostname (&GB.clixhost, sizeof GB.clixhost-SAFETYNUM);
	GB.clixhost [sizeof GB.clixhost-1] = '\0';
}}}

	static ascii_char *GET_PROXY_CLIENT_ADDRESS ()
/*	-----------------------------------------------
*	This function should be modified to handle 
*	a different method of obtaining proxy client
*	address. Currently expects an env variable:
*	see PROXY_CLIENT_ADDRESS definition
*	-----------------------------------------------*/
{{{	ascii_char	*val;
/*	-----------------------------------------------*/
/*	val = (ascii_char *) getenv (PROXY_CLIENT_ADDRESS); */
	val = (ascii_char *) proxy_client_address;
	if (!val) JUMPOUT (Bias(MSGID_PROXY_UNDEFINED), NOVALC, MOID_CONN_SOC);
	return val;
}}}
#endif		/* end exclusively CLIX functions */

#ifdef  _NT_P_
	void main(argc, argv)
/*	-------------------------------------------------
*	main function on NT; cannot be commented out. 

	INVOCATIONS

	postman.exe [options] [anystring]

	where options are:

	no options	This is production mode invocation. 
			Will wait on socket port and spawn
			(with the "-z" option) a separate
			postman.exe for each connection request
			(See also -w below)

	-w		Same as above except each spawned process
			will create its own console window for
			error messages that otherwise have no
			avenue of display

	-t 		For standalone testing. anystring must
			also be supplied here. This invocation
			will not bother with sockets

	-y		no spawn socket testing (easier to debug).
			This will wait on socket port for VDS
			connection. When connection is requested,
			remains connected and services message 
			requests. No second connection possible

	-z      	internal invocation by spawning
			(see POSTMAN_INETD)
*	----------------------------------------------- */
	int		argc;
	char		*argv[];
/*	----------------------------------------------- */
{{{	int 		jmpstat;
/*	----------------------------------------------- */
	if (argc <= 1) GB.opletter = SOCKET_SPAWN;
	else GB.opletter = '-' == argv[1][0] ? argv[1][1] : 0;
	GB.postman_path = argv[0];

	jmpstat = setjmp (GB.jmpbuf);	
	if (jmpstat) MAIN_ERROR_HANDLER ();		/* do not come back */

	switch (GB.opletter) {
		case TESTKEY: 
			POSTMAN_SERVICE_STANDALONE (argc, argv);
			break;
		
							/* INETD DAEMON REACHES THESE OPTIONS */
		case SOCKET_SPAWN:			/* no option */
		case SOCKET_NO_SPAWN:			/* -y */
		case SOCKET_SPAWN_CONSOLE:		/* -w */
			BE_INFORMATIVE (INETD_PROCESS);
			GB.visible_console = TRUE;
			TcpStartup ();
			POSTMAN_INETD ();
			break;

							/* SPAWNED BINARY REACHES THIS OPTION */
		case INTERNAL_SPAWN:			/* -z */
			TcpStartup ();
			GB.socketopen = TRUE;
	                GB.socket = atoi (argv[2]);
	                GB.listeningsocket = atoi (argv[3]);
			if (argc >= 5) GB.visible_console = TRUE;	/* 'w' supplied at end */
			POSTMAN ();
			break;

		default:
			printf (HelpText, GB.postman_path);
			break;
	}
	exit (EXIT_FAILURE);				/* should not execute this here */
}}}

	static void MAIN_ERROR_HANDLER ()
/*	----------------------------------------
*	Catastrophic error handler aiming hard
*	to return VDS some kind of indication
*	under all circumstances
*	----------------------------------------*/
{{{	char		*errmsg;
	int		jmphere;
/*	----------------------------------------*/
	jmphere = setjmp (GB.jmpbuf);	
	if (jmphere) goto CLEAN;			/* catastrophe within catastrophe; get out */

	GET_BUFFER (ERRMSGBUFFER, PREVIOUS, &errmsg);	
	PRINT_FIRST_LINE (errmsg);			/* our own message not on console yet */
	if (!GB.errcode) GB.errcode = NT_ERROR;
	if (GB.socketopen) {				/* send error back to vds */
	   SOCKET_WRITE (NULLC, 0, GB.errcode, 0, errmsg, FALSE);
	}

CLEAN:	POSTMAN_CLOSE ();
	if (!GB.visible_console) exit (EXIT_FAILURE);	/* no window for user to kill me */
	printf ("\n%s", Msgs[MSGID_KILLME]);		/* user to kill postman */
	sleep (INDEFINITELY);				/* allow console message to stay */	   
}}}

	static void POSTMAN_SERVICE_STANDALONE (argc, argv)
/*	-----------------------------------------------
*	standalone testing (no sockets). Does not return
*	----------------------------------------------- */
	int		argc;
	char		*argv[];
/*	----------------------------------------------- */
{{{	int 	   dstat       = OKAY, i;
	integer    mfail       = FALSE;
	integer	   BufferLen   = 0;
	string     OutBuffer   = NULL;
	Boolean	   Normal = TRUE;
	ascii_char *asciibuf, *errmsg;
/*	----------------------------------------------- */
	MODNAME ("STANDALONE:postman");

				/* Allow client mode access to the */
				/* MODel file (this will use the mserv */
				/* server for MODel data access, */
				/* big performace boost */
	mservSetCallbacks(NULL);


	dstat = clInitialize();
	if (dstat != OKAY) {
	   low_err_flush ();
	   SETERRMSG (Bias(MSGID_CLIENT_INIT_ERR), NOVALC, MOID_CLIENT);
	   GET_BUFFER (CONSOLEBUFFER, PREVIOUS, &errmsg);	/* get buffer for console msgs */
	   printf ("\n ");printf (errmsg); printf ("\n");
           exit(EXIT_FAILURE);
	}
   
	for (i=0; i<100; i++) {				/* standalone test counter */
		int j = strlen (argv[2]) + 1;		/* include null */
		GET_BUFFER (ASCIIFYBUFFER, 		/* get a properly allocated buffer */
			Asciifying_Size(j), 
			(char**)&asciibuf);	

							/* dm2 messages accept strings only */
		POSTMAN_ASCIIFY (j, argv[2], asciibuf);
		dstat = PmPostMan(TARGETCLASS, asciibuf, &OutBuffer, &BufferLen, &mfail);
		if (dstat != OKAY || mfail) {
			char *errmsg;
			SETERRMSG (Bias(MSGID_BAD_SERVER_CALL), NOVALC, MOID_CALLING_POSTMAN);
	                GET_BUFFER (ERRMSGBUFFER, PREVIOUS, &errmsg);
			printf ("\n ");printf (errmsg); printf ("\n");
			Normal = FALSE; break;
		} else {
			POSTMAN_UNASCIIFY ((ascii_char*)OutBuffer, (ascii_char*)OutBuffer, &j);
			printf (OutBuffer); printf ("\n");
		}
	}

        clTerminate();
	exit(Normal ? EXIT_SUCCESS : EXIT_FAILURE);
}}}

	static void POSTMAN_INETD ()
/*	------------------------------------------------
*	Performs inetd function on NT

*	1. Wait on port 

*	2. Spawn (don't thread) selfsame binary on connection 

*	3. Make inprocess call without spawning if GB.spawnopt 
*	indicates so
*	------------------------------------------------ */
{{{	int 		lasterr, dummy, WaitOrNot;
	struct 	sockaddr_in server;
	ascii_char 	*path, *errmsg, cw[2];
/*	------------------------------------------------ */
	path = GB.postman_path;
	GB.listeningsocket = socket (AF_INET, SOCK_STREAM, IPPROTO_TCP);
	if (GB.listeningsocket < 0) {
	   JUMPOUT (SETERRNO (FROMWINAPI, NULL), NOVALC, MOID_OPEN_SOC);
	}

	memset (&server, 0, sizeof (server));
	server.sin_family = AF_INET;
	server.sin_addr.s_addr = INADDR_ANY;
	server.sin_port = htons (POSTMAN_PORTNO);
	if (bind (GB.listeningsocket, (struct sockaddr *)&server, sizeof (server))) {
	   char  orimsg[BIGENUFMSGBUF], *frag = "";		/* ask to kill all postman if address_in_use */
	   lasterr = SETERRNO (FROMWINAPI, NULL);
	   if (lasterr == ADDRESS_IN_USE) frag = Msgs[MSGID_TERMINATE_ALL];
	   sprintf (orimsg, Msgs[MSGID_POSTMAN_PORTNO], POSTMAN_PORTNO, frag);
	   JUMPOUT (lasterr, orimsg, MOID_BIND_SOC);
	}

	listen (GB.listeningsocket, LISTEN_CONSTANT);
	for (;;) {
	    char chmsg[BIGENUFMSGBUF];
	    GB.socket = accept (GB.listeningsocket, NULL, NULL);
	    if (-1 == GB.socket) {
	       closesocket (GB.listeningsocket);		/* allow no more connections */
	       JUMPOUT (SETERRNO (FROMWINAPI, NULL), NOVALC, MOID_ACCEPT_SOC);
	    }
	    GB.socketopen = TRUE;

	    if (SOCKET_NO_SPAWN == GB.opletter) {		/* testing option */
	       POSTMAN ();
	       exit (EXIT_SUCCESS);
	    }

	    memset (cw, 0, sizeof cw);				/* "you have own console" flag to child */
	    cw[0] = SOCKET_SPAWN_CONSOLE;			/* postman.exe -z 23 42 w */
	    if (SOCKET_SPAWN_CONSOLE != GB.opletter) cw[0] = '\0';
	    sprintf (chmsg, "%s -z %d %d %s", path, GB.socket, GB.listeningsocket, cw);
	    if (SPAWNPOSTMAN (chmsg, WaitOrNot=FALSE, &dummy)) {
	       SOCKET_CLOSE ();
	       continue;					/* okay */
	   }

	   SETERRMSG (SETERRNO(GETERROR, NULL), path, MOID_SPAWN_POST);	/* spawn failed */
	   SOCKET_DUMMY_READ ();				/* dummy read to clear for writeback */
	   GET_BUFFER (ERRMSGBUFFER, PREVIOUS, &errmsg);
	   POSTMAN_SOCKET_INIT (TRUE);				/* TRUE for only set linger option */
	   closesocket (GB.listeningsocket);			/* allow no more connections */
	   JUMPOUT (NOVAL, NOVALC, NOVAL);			/* messages already set; jump out */
	}
}}}             

	static int SPAWNPOSTMAN (cmd, WaitForExit, exicode)
/*	------------------------------------------------
*	For don't wait mode, return TRUE if successfully 
*	kicked off and exicode will have the pid; for 
*	wait mode, return TRUE/exicode if postman was 
*	properly waited on and exit code interrogated; 
*	else FALSE and caller interrogates err routines 
*	to get errno
*	------------------------------------------------*/
	char	*cmd;		/* i: whole command line */
	Boolean WaitForExit;	/* i: 0 - don't wait, 1 - wait until done */
	int	*exicode;	/* o: postman exit code/or error no */
/*	------------------------------------------------*/
{{{	STARTUPINFO StartupInfo;
	PROCESS_INFORMATION ProcessInfo;
	DWORD 	closehand=FALSE, retstat;
/*	------------------------------------------------*/
	memset (&StartupInfo, 0, sizeof StartupInfo);
	memset (&ProcessInfo, 0, sizeof ProcessInfo);
	StartupInfo.cb = sizeof(STARTUPINFO);
	StartupInfo.lpDesktop = 0;
	StartupInfo.lpTitle   = 0;
	StartupInfo.dwX       = 0;
	StartupInfo.dwY       = 0;
	StartupInfo.dwXSize   = 0;
	StartupInfo.dwYSize   = 0;
	StartupInfo.dwFlags   = 0;
	StartupInfo.dwFlags   = STARTF_USESHOWWINDOW;
	StartupInfo.wShowWindow = SW_HIDE;		/* hide console but need it to capture messages */
	if (SOCKET_SPAWN_CONSOLE == GB.opletter) {	/* user wants console for each process */
	   StartupInfo.dwFlags   = 0;			/* ignore ShowWindow field which has been set to HIDE */
	}

	ProcessInfo.hProcess = NULL;

	while (TRUE) {					/* dummy loop to break out of */
	   *exicode = 0;
	   retstat = CreateProcess(
			(LPCTSTR) NULL,
			(LPSTR) cmd,
			(LPSECURITY_ATTRIBUTES) NULL,
			(LPSECURITY_ATTRIBUTES) NULL,
			(BOOL) TRUE,
                        (DWORD) CREATE_NEW_CONSOLE,
			(LPVOID) NULL,
			(LPVOID) NULL,
			(LPSTARTUPINFO) &StartupInfo,
			(LPPROCESS_INFORMATION) &ProcessInfo);
	   if (!retstat) break;
	   *exicode = ProcessInfo.dwProcessId;
	   closehand=TRUE;
	   if (!WaitForExit) break;			/* good & done */
           retstat = WaitForSingleObject (ProcessInfo.hThread, INFINITE);
	   if (WAIT_FAILED == retstat) {retstat = FALSE; break;}
	   retstat = GetExitCodeThread (ProcessInfo.hThread, exicode);
	   break;
	}

	if (!retstat) SETERRNO (FROMWINAPI, NULL);
	if (closehand) {
	   CloseHandle(ProcessInfo.hProcess);
	   CloseHandle(ProcessInfo.hThread);
	}
	return retstat;
}}}

	static void POSTMAN ()
/*	--------------------------------------
*	Main postman loop: 
*	read from Clix/call DM2/write to CLIX
*	-------------------------------------- */
{{{	ascii_char		*errdummy, *reqbuf, *errmsg;
	static 	ascii_char	*resultbuf;
	int			dummy, reqbuflen, resultbuflen;
	int			dstat, mfail;
	Boolean			closed=FALSE;
/*	-------------------------------------- */
	if (resultbuf) {		/* check if SOCKET_WRITE jumped out w/o freeing */
	   low_freespace (resultbuf); 
	   resultbuf = 0;
	}

	POSTMAN_INIT (); 
	while (TRUE) {
	   SOCKET_READ (&reqbuf, &reqbuflen, &dummy, &dummy, &errdummy, &closed, FALSE);
	   if (closed) break;
	   resultbuf = errmsg = (ascii_char*)0;
								/* send message to DM2 */
	   dstat = PmPostMan(TARGETCLASS, reqbuf, &resultbuf, &resultbuflen, &mfail);
	   low_err_flush ();
	   CONSOLE_READ ();					/* read err messages from console */
	   GET_BUFFER (CONSOLEBUFFER, PREVIOUS, &errmsg);	/* get buffer for console msgs */
	   resultbuflen = resultbuf ? strlen (resultbuf) + SIZEOFNULLBYTE : 0;
	   SOCKET_WRITE (resultbuf, resultbuflen, dstat, mfail, errmsg, FALSE);
	   if (!resultbuf) continue;
	   low_freespace (resultbuf); 
	   resultbuf = 0;
	}
   
	POSTMAN_CLOSE ();
        exit(EXIT_SUCCESS);
}}}

	static void POSTMAN_INIT ()
/*	------------------------------------------
*	initialize stuff
*	------------------------------------------ */
{{{	int	   dstat;
	ascii_char *errmsg;
/*	------------------------------------------ */
	CONSOLE_INIT ();					/* initialize console for messages */
	POSTMAN_SOCKET_INIT (FALSE);
	mservSetCallbacks(NULL);				/* MODEL file related */

	dstat = clInitialize();
	if (dstat != OKAY) {
	   low_err_flush ();
	   CONSOLE_READ ();					/* read err messages from console */
	   GET_BUFFER (CONSOLEBUFFER, PREVIOUS, &errmsg);	/* get buffer for console msgs */
	   SETERRMSG (Bias(MSGID_CLIENT_INIT_ERR), errmsg, MOID_CLIENT);
	   GET_BUFFER (ERRMSGBUFFER, PREVIOUS, &errmsg);	/* get final error msg buffer */
	   GB.errcode = dstat;
	   JUMPOUT (NOVAL, NOVALC, NOVAL);
	}
	GB.DM2_client_inited = TRUE;
        SOCKET_WRITE (NULLC, 0, OKAY, OKAY, "", FALSE);		/* good initialization acknowledged */

#if 0
	{ int shandle; char pid[30], *args[2]={"",0};
	if (!getenv ("POCAHONTAS")) return;
	sprintf (pid, "%d", getpid ()); args[0] = pid;
	dstat = smClntCreate ("pmesrv", "pmesvr", 1, 1, args, SM_PG_CURR, NULL, &shandle);
	}
#endif
}}}

	static void CONSOLE_INIT ()
/*	----------------------------------------------
*	Set up console so that stdout and stderr messages
*	output to the console can be read back. If not
*	successful, reset global flag. If a dedicated
*	console is visible, resize the buffer bigger
*	so user can scroll
*	----------------------------------------------*/
{{{	BOOL	retstat; 
	int	height, width;
	COORD	conbufsize;
/*	----------------------------------------------*/
	GB.constdout = GetStdHandle (STD_OUTPUT_HANDLE);	/* get stdout handle to console */
	if (GB.constdout == INVALID_HANDLE_VALUE) return;	/* what can anyone do ? */

								/* let stderr go to stdout also */
	if (!SetStdHandle (STD_ERROR_HANDLE, GB.constdout)) return;
	GB.consoleOk = TRUE;					/* Console inited properly */

	if (INTERNAL_SPAWN != GB.opletter) return;		/* not a separate process from parent */
	retstat = GetConsoleScreenBufferInfo			/* read newly created console size */
		(GB.constdout, &GB.csbinfo);
	if (!retstat) return;
	height = GB.csbinfo.dwSize.Y;				/* get height */
	if (height >= MINCONSOLEHEIGHT) return;
	width  = GB.csbinfo.dwSize.X;
	if (width >= CHECKCONSOLEWIDTH) return;			/* too wide; don't change height */

	conbufsize.X = GB.csbinfo.dwSize.X;
	conbufsize.Y = MINCONSOLEHEIGHT;
	SetConsoleScreenBufferSize (GB.constdout, conbufsize);	/* can't do anything if error */
}}}

	static void CONSOLE_READ ()
/*	----------------------------------------------
*	DM2 servers and client throw various messages at 
*	NT POSTMAN's console intending them for the 
*	end-user. In our case though, VDS is where the
*	messages should end up. POSTMAN simply reads the
*	console buffer and passes it onto VDS. 

*	Output: messages are returned in the global
*	console buffer after suitably squeezed and 
*	newlined 
*	----------------------------------------------*/
{{{	BOOL 		retstat;
	int 		i, j, linesize;
	COORD 		destsize, conlinecoord;
	CHAR_INFO	conline [MAXCONSOLELINE+SAFETYNUM];
	SMALL_RECT	source;
	char		*conbuf, line [MAXCONSOLELINE+SAFETYNUM];
/*	----------------------------------------------*/
	GET_BUFFER (CONSOLEBUFFER, SIZEOFNULLBYTE, &conbuf);	/* null out buffer */
	if (!GB.consoleOk) return;			/* Console not inited properly */
	retstat = GetConsoleScreenBufferInfo		/* read it every time since user .. */
		(GB.constdout, &GB.csbinfo);		/* .. can change console buffer info */
	if (!retstat) return;
	linesize = GB.csbinfo.dwSize.X;			/* get buffer width */
 	if (linesize > MAXCONSOLELINE) {		/* reset size to max allowed */
	   linesize = MAXCONSOLELINE;
	}

	CONSOLE_MSG_ADD (CONSTART, NULLC);		/* start accumulatin */
	for (i=GB.csbinfo.dwSize.Y-1; i>=0; i--) {	/* loop thru from bottom of screen to top */
	   memset (conline, 0, sizeof conline);		/* null terminate upto kazoo */
	   memset (line, 0, sizeof line);		
	   destsize.X = linesize, destsize.Y = 1;	/* read 1 row at a time from bottom of screen */
	   conlinecoord.X = conlinecoord.Y = 0;		/* always {0,0} -> conline[0] */
	   source.Left = 0, source.Top = i;		/* set console buffer area to read from */
	   source.Right = linesize-1, source.Bottom = i;
	   retstat = ReadConsoleOutput 
		(GB.constdout, conline,	destsize, conlinecoord, &source);
	   if (!retstat) return;
	   for (j=0; j<=source.Right; j++) {
		line[j] = conline[j].Char.AsciiChar;	/* move into a plain string */
	   }
	   if (!CONSOLE_MSG_ADD (CONADD, line)) break;	/* too long already, or divider found */
	}
	CONSOLE_MSG_ADD (CONFINIS, "");			/* finish */
}}}

	static Boolean CONSOLE_MSG_ADD (flag, conline)
/*	------------------------------------------------
*	accumulate into our internal console buffer another
*	line read from the console. The lines are coming
*	from Windows NT console buffer bottom to top.
*
*	HOW ACCUMULATION IS DONE: Since the lines are coming
*	from bottom to top, so are strings added from
*	the back end of the buffer until the first char
*	of the last string to be added has a negative index.
*	If that happens, FUNCTION RETURNS FALSE.

*	'CONFINIS' flag moves the accumulated string
*	character by character so it starts from char[0]
*	FUNCTION RETURNS FALSE also if conline is found to
*	be a console divider

*	A newline is added at the end of each line as it
*	is added to the buffer. All lines are are 
*	stripped of trailing blanks to reduce transmission
*	buffer size. Note that console output as read don't
*	contain control characters 

*	!!WARNING!! Side effect -> writes new message
*	divider at FINIS call if the last line is not
*	already a divider
*	------------------------------------------------*/
	CONSOLEMSG	flag;		/* i: see case statement below */
	ascii_char	conline [];	/* i: null-terminated */
/*	------------------------------------------------*/
{{{	char		*conbuf;
	int		i, len, done, lentocopy;
	int	static	roomfor;
	Boolean static  goodline;
/*	------------------------------------------------*/
	switch (flag) {
	   case CONSTART:				/* start accumulating messages */
	      GET_BUFFER (CONSOLEBUFFER, MAXCONSOLEBUF, &conbuf);	/* set size */
	      conbuf [MAXCONSOLEBUF-1] = '\0';		/* null terminate */
	      roomfor = MAXCONSOLEBUF-1;		/* number of characters can yet be copied */
	      goodline = FALSE;				/* have not read in a non-blank line */
	      return TRUE;

	   case CONADD:					/* add one more line */
	      GET_BUFFER (CONSOLEBUFFER, PREVIOUS, &conbuf);	/* get old buffer */
	      len = strlen (CONSOLE_DIVIDER);
	      done = !strncmp (CONSOLE_DIVIDER, conline, len);
	      if (done) return FALSE;			/* encountered console divider */
	      len = strlen (conline);
	      if (!len) return TRUE;			/* null string - ignored */
	      if (roomfor == 0) return FALSE;		/* buffer full */

	      for (i=len-1; i>=0 && conline[i] == SPACE; i--);	/* skip trailing blanks */
	      lentocopy = i >= 0 ? i+1 : 0;		/* string length minus trailing blanks */	       
	      if (!lentocopy && !goodline) return TRUE;	/* no good line yet */
	      goodline  = TRUE;

	      conbuf [roomfor-1] = '\n';		/* add new line */
	      --roomfor;				/* decrease remaining available buf space */
	      if (roomfor < lentocopy) return FALSE;	/* cannot fit whole line */
	      i = roomfor - lentocopy; 
	      memcpy (&conbuf[i], conline, lentocopy);
	      roomfor -= lentocopy;			/* new available space */
	      return TRUE;

	  case CONFINIS:				/* move up message to start from 0 */
	      GET_BUFFER (CONSOLEBUFFER, PREVIOUS, &conbuf);	/* get old buffer */
	      if (roomfor <= 1) return TRUE;		/* already positioned at char[0] */

							/* memmove will move at least a null char */
	      memmove (conbuf, &conbuf [roomfor], MAXCONSOLEBUF-roomfor);
	      if (conbuf[0]) CONSOLE_WRITE_DIVIDER ();
	      return TRUE;
	}
}}}

	static void CONSOLE_WRITE_DIVIDER ()
/*	-------------------------------------------------
*	print console divider to console to demarcate next
*	set of messages
*	-------------------------------------------------*/
{{{
/*	-------------------------------------------------*/
	printf ("\n"); printf (CONSOLE_DIVIDER); printf ("\n");
}}}

	static void POSTMAN_SOCKET_INIT (OnlyLinger)
/*	-------------------------------------------------
*	Initialize socket to not discard unsent data when
*	socket is closed (maybe immediately following the
*	last send of fatal error message). Also, set max
*	buffersize for recv and send tcp/ip calls. The
*	bigger this value possibly faster the transmission
*	of large buffers as they have to be split up into
*	fewer fragments. 
*	Also closes unconnected socket to disallow further
*	connection to this process. If this is not a 
*	spawned postman process, "connection refused"
*	message will be generated if somebody else tries
*	to connect to it
*	------------------------------------------------ */
	Boolean		OnlyLinger;	/* i: if TRUE, just set linger option */
					/*    and return */
/*	------------------------------------------------ */
{{{	int 	   	maxbufsize, reqbuflen, code, mfail, len;
	struct linger	liopt = {1, (unsigned short)0xefff};	/* indefinitely linger */
	char		*errmsg, *reqbuf;
	int		socksize = sizeof GB.sockname;
/*	------------------------------------------ */
	closesocket (GB.listeningsocket);			/* unconnected socket (inherited if spawned) */
	GB.chunksize = POSTMAN_CHUNKSIZE_SAFE;
	setsockopt (GB.socket, SOL_SOCKET, SO_LINGER, 		/* From NT side, don't close until data sent */
		    (char*) &liopt, sizeof liopt);
	if (OnlyLinger) return;

	maxbufsize = POSTMAN_CHUNKSIZE; len=sizeof maxbufsize;
	setsockopt (GB.socket, SOL_SOCKET, SO_RCVBUF, (char*)&maxbufsize, len);
	setsockopt (GB.socket, SOL_SOCKET, SO_SNDBUF, (char*)&maxbufsize, len);

			/* now get the actual size; would be different.. */
			/* .. if could not be set with the above calls */
	len = sizeof maxbufsize;
	getsockopt (GB.socket, SOL_SOCKET, SO_RCVBUF, (char*)&maxbufsize, &len);
	GB.chunksize = maxbufsize;

	len = sizeof maxbufsize;
	getsockopt (GB.socket, SOL_SOCKET, SO_SNDBUF, (char*)&maxbufsize, &len);
	if (GB.chunksize > maxbufsize) GB.chunksize = maxbufsize;
	GB.chunksize -= SAFETYNUM;					/* step back a bit */
	if (GB.chunksize <= 0) GB.chunksize = POSTMAN_CHUNKSIZE_SAFE;

									/* make sure VDS connected */
	SOCKET_READ (&reqbuf, &reqbuflen, &code, &mfail, &errmsg, NULL, FALSE);
	if (code != INIT_REQUEST) {
	   JUMPOUT (Bias(MSGID_INVALID_BUF), NOVALC, MOID_READ_INIT);	/* invalid buffer */
	}
	len = sizeof GB.clixhost;
	if (reqbuflen > len) reqbuflen = len;
	memcpy (GB.clixhost, reqbuf, reqbuflen);
	GB.clixhost [sizeof GB.clixhost - 1] = '\0';
	getpeername (GB.socket, &GB.sockname, &socksize);

									/* send chunksize to CLIX */
   	SOCKET_WRITE (NULLC, 0, CHUNKSIZE_INFO, GB.chunksize, "", FALSE);
	BE_INFORMATIVE (POSTMAN_PROCESS);
}}}

	static void POSTMAN_CLOSE ()
/*	--------------------------------------------
*	shuts down postman
*	-------------------------------------------- */
{{{
/*	-------------------------------------------- */
	if (GB.DM2_client_inited) clTerminate();
	GB.DM2_client_inited = FALSE;
	SOCKET_CLOSE ();
}}}

	static void SOCKET_DUMMY_READ ()
/*	--------------------------------------------
*	dummy read to clear socket 
*	-------------------------------------------- */
{{{	char		 *reqbuf, *errmsg;
	int		dstat, mfail, len;
/*	-------------------------------------------- */
	SOCKET_READ (&reqbuf, &len, &dstat, &mfail, &errmsg, NULL, FALSE);
}}}

	static void TcpStartup ()
/*	-------------------------------------
*	start sockets 
*	-------------------------------------*/
{{{	WORD	wVersionRequested;
	WSADATA	wsaData;
	int	lb, hb, err;
/*	-------------------------------------*/
	wVersionRequested = MAKEWORD (1, 1);	/* 1,1 used from WINAPI example */
	err = WSAStartup (wVersionRequested, &wsaData);
	if (err) JUMPOUT (SETERRNO(FROMWINAPI, NULL), NOVALC, MOID_START_TCP);

	lb = LOBYTE (wsaData.wVersion);
	hb = HIBYTE (wsaData.wVersion);
	if (lb != 1 || hb != 1) {
	   JUMPOUT (Bias(MSGID_TCPIP_BAD_VERSION), NOVALC, MOID_START_TCP);
	}
	GB.chunksize = POSTMAN_CHUNKSIZE_SAFE;
}}}      

	static void NTMsg (errorno, errsou, msg, size)
/*	-------------------------------------------
*	format winapi error msg. If not found,
*	return Not Found msg. 
*	-------------------------------------------*/
	int		errorno;		/* i: */
	char		errsou;			/* i: 0 cruntime, 1 - winapi/socket */
	char		*msg;			/* o: */
	int		size;			/* i: size of msg*/
/*	----------------------------------------*/
{{{	char		ntmsg[BIGENUFMSGBUF];
	int		copysize;
/*	----------------------------------------*/
	memset (ntmsg, 0, sizeof ntmsg);
	switch (errsou) {
	   case FROMCRUNTIME:
	      copysize = sizeof ntmsg-SAFETYNUM2;			/* SAFETYNUM2 to avoid +1 problem */
	      if (errorno >= sys_nerr) 	sprintf (ntmsg, Msgs[MSGID_NO_NT_C_MSG], errorno);
	      else   strncpy (ntmsg, strerror(errorno), copysize);
	      break;
	
	   case FROMWINAPI:
	      copysize = sizeof ntmsg - SAFETYNUM2;			/* avoid null byte past allocated length problem */
	      if (errorno >= WSABASEERR) {
	         WINSOCK_ERR_MSG (errorno, ntmsg, copysize);
	      } else {
		 WINAPI_ERR_MSG (errorno, ntmsg, copysize);
	      }
	      break;
	
	   default: sprintf (ntmsg, Msgs[MSGID_BAD_MSG_CALL], errorno);	/* corresponding text not found */
	      break;
	}

	copysize = size-SAFETYNUM;					/* SAFETYNUM steps back less than SAFETYNUM2 */
	memset (msg, 0, copysize);
	strncpy (msg, ntmsg, copysize);		
}}}

	static void WINAPI_ERR_MSG (errorno, msg, size)
/*	-------------------------------------------
*	format winapi error msg. If not found,
*	return Not Found msg. 
*	-------------------------------------------*/
	int		errorno;		/* i: */
	char		*msg;			/* o: */
	int		size;			/* i: size of msg*/
/*	----------------------------------------*/
{{{	DWORD 		mre;
	char		ntmsg[500];
/*	----------------------------------------*/
	memset (ntmsg, 0, sizeof ntmsg);
	mre = FormatMessage (FORMAT_MESSAGE_FROM_SYSTEM,NULL,errorno, 
		     	      MAKELANGID (LANG_ENGLISH,SUBLANG_ENGLISH_US),
		              (LPSTR)ntmsg, sizeof ntmsg-SAFETYNUM2, NULL);
	if (!mre) sprintf (ntmsg, Msgs[MSGID_NO_NT_WINAPI_MSG], errorno);
	memset (msg, 0, size-SAFETYNUM);
	strncpy (msg, ntmsg, size-SAFETYNUM);
}}}

	static void WINSOCK_ERR_MSG (errorno, ntmsg, size)
/*	-------------------------------------------
*	find socket error message
*	-------------------------------------------*/
	int	errorno;
	char	*ntmsg;
	int	size;
/*	-------------------------------------------*/
{{{	int	maxindex1, maxindex2;
	char	*at=(char *)0, tmsg[300];
/*	-------------------------------------------*/
	memset (ntmsg, 0, size);
	maxindex2 = sizeof sockerr2/sizeof (ascii_char *) -1;
	maxindex1 = sizeof sockerr /sizeof (ascii_char *) -1;
	sprintf (tmsg, Msgs[MSGID_NO_NT_SOC_MSG], errorno);

	if (errorno >= WINSOCKBIAS2) {
	   errorno -= WINSOCKBIAS2;
	   if (errorno <= maxindex2) at = sockerr2 [errorno];
	   if (!at[0]) at = (char *)0;
	} else if (errorno >= WINSOCKBIAS) {
	   errorno -= WINSOCKBIAS;
	   if (errorno <= maxindex1) at = sockerr [errorno];
	   if (!at[0]) at = (char *)0;
	}
	if (at)  strncpy (ntmsg, at, size-2);
	else 	 strncpy (ntmsg, tmsg, size-2);
}}}

	static void GET_CLIX_ADDRESS ()
/*	--------------------------------------------
*	store clix m/c address
*	--------------------------------------------*/
{{{	int	s = sizeof GB.sockname;
/*	--------------------------------------------*/
	getpeername (GB.socket, &GB.sockname, &s);
}}}

	static void BE_INFORMATIVE (process_type)
/*	--------------------------------------------
*	Who is me? and some other info for user
*	--------------------------------------------*/
	Boolean		process_type;		/* i: inetd/postman */
/*	--------------------------------------------*/
{{{	struct in_addr 	a; 
	char		*ma, ttext [100];
	time_t  	tim;
	struct tm 	*tm;
/*	------------------------------------- */
	time (&tim);
	tm = localtime (&tim);
	strftime (ttext, sizeof ttext-SAFETYNUM, "%d-%b-%y %H:%M:%S", tm);
	printf ("\n%s\n", Msgs[MSGID_PROC_INFO]);
	printf (Msgs [MSGID_PROC_ID], getpid (), ttext);

	if (process_type == POSTMAN_PROCESS) {
	   memcpy (&a.s_addr, &GB.sockname.sa_data[2], sizeof (int));
	   ma = inet_ntoa (a);
	   printf ("\n") ; printf (Msgs[MSGID_CLIX_NAME], GB.clixhost);
	   printf ("\n") ; printf (Msgs[MSGID_CLIX_ADDRESS], ma);
	   printf ("\n") ; printf (Msgs[MSGID_SERVER_TAG]);
	} else printf ("\n%s", Msgs[MSGID_INETD_DAEMON]);

	CONSOLE_WRITE_DIVIDER ();
}}}

	static void PRINT_FIRST_LINE (errmsg)
/*	----------------------------------------------
*	Error handling has become rather involved with
*	implicit assumptions shared between multiple
*	modules. Here, print the first line only on
*	console, assuming 2nd line and after are already
*	from console; also assume the first line not
*	already on console
*	---------------------------------------------*/
	ascii_char	errmsg[];		/* i:; temporarily modified */
						/*     ... to insert null */
/*	---------------------------------------------*/
{{{	char	*newline;
/*	---------------------------------------------*/
	newline = strchr (errmsg, '\n');
	if (newline) *newline = '\0';			/* newline found */
	if (errmsg[0]) {
	   printf (errmsg);				/* non-null string */
	   CONSOLE_WRITE_DIVIDER ();			/* demarcate next message */
	}
	if (newline) *newline = '\n';			/* restore newline */
}}}	
#endif			/* end exclusively _NT_P_ functions */

	static void POSTMAN_ASCIIFY (inbuflen, inbuffer, asciibuf)
/*	----------------------------------------------------------
*	dm2 messages accept strings only; convert inbuffer to
*	encoded ascii string; works by adding 32 to each 4-bit
*	fragment and thus doubling the length; asciibuf must be
*	different from inbuffer in the argument

*	The best way to asciify an already ascii string (like we
*	will be doing in testing) is to send in the null terminating
*	byte also. When it is unasciified again, the null byte will
*	come back with it. So for example, inbuflen will be sent in as
*	strlen (inbuffer) +1. Necessary since unasciifying does not 
*	null-terminate its output.
*	--------------------------------------------------------- */
	int		inbuflen;		/* i: length in bytes */
	char		*inbuffer;		/* i: buffer to convert */
	ascii_char	*asciibuf;		/* i: allocated buffer, must be */
						/*    atleast inbuflen*2+1 long */
						/* o: encoded string */
/*	--------------------------------------------------------- */
{{{	int	i,j;
/*	--------------------------------------------------------- */
	for (i=j=0; i<inbuflen; i++) {
	   asciibuf[j++] = MINASCIICODE + (inbuffer [i] & HALFBYTEMASK);
	   asciibuf[j++] = MINASCIICODE + (inbuffer [i] >> HALFBYTESHIFT);
	}
	asciibuf [inbuflen*ASCIIFYING_FACTOR] = '\0';	/* null terminate */
}}}

	static void POSTMAN_UNASCIIFY (inbuffer, outbuffer, outbuflen)
/*	----------------------------------------------------------
*	convert ascii string inbuffer to decoded outbuffer;
*	reverse ASCIIFication by subtracting 32 from each byte
*	and compressing two results into one byte. inbuffer and 
*	outbuffer can be same address
*	--------------------------------------------------------- */
	ascii_char	*inbuffer;		/* i: buffer to decode */
	char		*outbuffer;		/* i: long buffer, must be atleast */
						/*    strlen(inbuffer)/2+1 long */
						/* o: decoded buffer */
	int		*outbuflen;		/* o: length of decoded buffer */
/*	--------------------------------------------------------- */
{{{	int		i;
	char		onechar, twochar;
/*	--------------------------------------------------------- */
	for (i=*outbuflen=0; inbuffer[i]; i += ASCIIFYING_FACTOR) {
	   onechar = (unsigned int) inbuffer [i] - MINASCIICODE;
	   twochar = (unsigned int) inbuffer [i+1] - MINASCIICODE;
	   onechar = onechar | (twochar << HALFBYTESHIFT);
	   outbuffer [i/ASCIIFYING_FACTOR] = onechar;
	   (*outbuflen)++;
	   if (!inbuffer[i+1]) break;		/* odd number of ascii characters */
						/* should not happen but allow for it */
	}
}}}

	static void SOCKET_READ (	
			outbuf,
			outbuflen,
			code, 
			mfail, 
			errmsg, 
			closed,
			syncflag)
/*	------------------------------------------------
*	See elsewhere for arg descriptions. No static
*	- recursive
*	------------------------------------------------ */
	char		**outbuf;	/* o: */
	int		*outbuflen;	/* o: */
	int		*code;		/* o: */
	int		*mfail;		/* o: */
	ascii_char	**errmsg;	/* o: */	
	Boolean		*closed;	/* o: TRUE if socket closes; if omitted */
					/*    with NULL, JUMPOUT on socket close */
	Boolean		syncflag;	/* i: if TRUE, this a call to synchronize */
					/*    No further synch call will be made */
/*	------------------------------------------------ */
{{{	int 		sofar;
	int		toread, bytecount;
	char		*tempbuf;
	HEADER		header;
/*	------------------------------------------------ */
	SOCKET_READ_CHUNK (sizeof header, (char*)&header, closed);
	if (closed) if (*closed) return;
	
					/* check for bad buffer/garbage data */
	if (header.magicno != POSTMAN_MAGICNO) {
	   JUMPOUT (Bias(MSGID_INVALID_BUF), NOVALC, MOID_READ_SOC);
	}
	bytecount = header.bytecount;
	if (header.packettype == FULL_BUFFER && 
	    bytecount < MINBUFLEN_POSTMAN) {
	   JUMPOUT (Bias(MSGID_TOO_SHORT_BUF), NOVALC, MOID_READ_SOC);  	
	}

	GET_BUFFER (READBUFFER, bytecount, &tempbuf);
	sofar = 0;
	while (TRUE) {				/* loop to read complete buffer length */
	   toread = bytecount - sofar;
	   if (!toread) break;
	   if (toread > GB.chunksize) toread = GB.chunksize;

	   if (sofar) {				/* something has already been read in */
	      if (syncflag) JUMPOUT (Bias(MSGID_INVALID_BUF), NOVALC, MOID_READ_SYNC);
	      SOCKET_WRITE_SYNC ();		/* synchronize; allow next chunk to be sent */
	   }
	   SOCKET_READ_CHUNK (toread, &tempbuf[sofar], NULL);
	   sofar += toread;
	}
	if (header.packettype == LEAN_BUFFER) {
	   *outbuf = tempbuf;
	   *outbuflen = header.bytecount;
	   *code = *mfail = OKAY;
	   *errmsg = "";
	} else {
	   UNPACK_POSTMAN_BUFFER (bytecount, tempbuf, outbuflen, 
				  outbuf, code, mfail, errmsg);	      
	}
}}}

	static void SOCKET_WRITE(
				buffer,
				bufferlen,
				code,
				mfail,
				errmsg,
				syncflag)
/*	-------------------------------------------------------
*	Write buffer to socket. Args described in SOCKET_READ
*	If all Null and zero-length except buffer, sends
*	without packing - thus saving on packing buffer allocation
*	------------------------------------------------------- */
	char		*buffer;	/* i: */
	int		bufferlen;	/* i: */
	int		code;		/* i: */
	int		mfail;		/* i: */
	ascii_char	*errmsg;	/* i: NULL, or null term string*/	
	Boolean		syncflag;	/* i: if TRUE, this is a call */
					/*    ... to synchronize. No further */
					/*    sync calls to be made from here */
/*	------------------------------------------------ */
{{{	int	    	tosend, sofar, retstat, bytecount;
	char		*packed;
	HEADER		header;
/*	------------------------------------------------ */
	if (!errmsg) errmsg = "";
	header.magicno = POSTMAN_MAGICNO;
	if (bufferlen && !code && !mfail && !errmsg[0]) {	/* nothing but non-zero length buffer */
	   header.bytecount = bufferlen;
	   header.packettype= LEAN_BUFFER;			/* lean buffer */
	   packed = buffer, bytecount = bufferlen;
	} else {
	   PACK_POSTMAN_BUFFER (&bytecount, &packed, bufferlen, buffer, 
				code, mfail, errmsg);	      
	   header.bytecount = bytecount;
	   header.packettype= FULL_BUFFER;
	}
	SOCKET_WRITE_CHUNK (sizeof header, (char*)&header);

	sofar = 0;
	while (TRUE) {						/* send in small chunks */
	   tosend = bytecount - sofar;
	   if (!tosend) break;
	   if (tosend > GB.chunksize) tosend = GB.chunksize;

	   if (sofar) {
	      if (syncflag) {					/* should not be a sync call within another */
	         JUMPOUT (Bias(MSGID_INVALID_BUF), NOVALC, MOID_WRITE_SYNC);	/* coding error  */
	      }
	      SOCKET_READ_SYNC ();				/* synchronize; allow next chunk to be sent */
	   }
	   retstat = send (GB.socket, &packed[sofar], tosend, 0);	
	   sofar += tosend;
	}
}}}

	static void SOCKET_READ_SYNC ()
/*	---------------------------------------------------
*	Read synchronization packet. Needed for sending big
*	buffers. After each chunk sent, read sync packet
*	to make sure other side has finished reading last
*	chunk
*	---------------------------------------------------*/
{{{	char		*reqbuf, *errmsg;
	int		code, mfail, len;
/*	---------------------------------------------------*/
	SOCKET_READ (&reqbuf, &len, &code, &mfail, &errmsg, NULL, TRUE);
	if 	(code == SYNC_REQUEST) return;		
	else if (code == NT_ERROR) {
	   JUMPOUT (Bias(MSGID_NOMSG), errmsg, NOVAL);			/* some error from postman to clix */
	} else {
	   JUMPOUT (Bias(MSGID_INVALID_BUF), NOVALC, MOID_READ_SYNC);
	}
}}}

	static void SOCKET_WRITE_SYNC ()
/*	---------------------------------------------------
*	Write synchronization packet. Needed for reading big
*	buffers. After each chunk read, write sync packet
*	to inform other side that new chunk can be written
*	---------------------------------------------------*/
{{{
/*	---------------------------------------------------*/
        SOCKET_WRITE (NULLC, 0, SYNC_REQUEST, OKAY, "", TRUE);
}}}

	static void SOCKET_READ_CHUNK (len, buffer, closed)
/*	---------------------------------------------------
*	Read chunk amount if possible; jumpout if can't read 
*	unless 	'closed' argument supplied. In that case if 
*	socket 	closed at other end, set closed = TRUE and 
*	return inline. 

*	Loops until the full length is read. Why does it
*	need to loop? Chunksize is the max amount that can
*	be sent in one socket 'send' call. The 'recv' end
*	on CLIX I found is receiving the same payload in
*	several packets properly sequenced nevertheless. 
*	There is no option (with setsockopt) on CLIX to
*	to set chunksize. It must be done automatically as
*	needed since it is not discarding received data
*	even for very huge buffers. Just that looping is
*	needed. There could be something with iocntl or
*	file control but I didn't bother. Seemed safer
*	to loop.
*	---------------------------------------------------*/
	int		len;		/* i: CHUNK length to read */
	char		*buffer;	/* o: data read */
	Boolean		*closed;	/* o: see above */
/*	---------------------------------------------------*/
{{{	int	    	moid, sofar, rest, retstat, msgno;
/*	---------------------------------------------------*/
	if (closed) *closed = FALSE;
	sofar = 0;							/* total amount read so far */
	while (TRUE) {
	   if (sofar == len) return;
	   SOCKET_SELECT ();
	   ALARMING (SET_ALARM);
	   retstat = 0;
	   rest = len - sofar;
	   retstat = recv (GB.socket, &buffer[sofar], rest, 0);	
	   ALARMING (UNSET_ALARM);
	   if (!retstat && closed) {*closed = TRUE; return;}
	   if (retstat <= 0) {
	      if (GB.alarmed) msgno = Bias(MSGID_SOC_TIMED_OUT);	/* alrmed out */
	      else if (retstat) msgno = SETERRNO(FROMWINAPI, NULL);	/* some kind of error */
	      else msgno = Bias (MSGID_OTHER_CLOSED);			/* connection closed by VDS */
	      moid = retstat < 0 ? MOID_READ_SOC : MOID_CANT_READ_FULL;
	      JUMPOUT (msgno, NOVALC, moid);  	
	   }
	   sofar += retstat;
	}
}}}

	static void SOCKET_WRITE_CHUNK (len, buffer)
/*	---------------------------------------------------
*	Write CHUNK amount; jumpout if can't write
*	---------------------------------------------------*/
	int		len;		/* i: CHUNK length to write */
	char		*buffer;	/* o: data read */
/*	---------------------------------------------------*/
{{{	int	    	retstat, moid, old=0;
/*	---------------------------------------------------*/
	if (!len) return;
#if defined (CLIX) || defined (X11)
	old = (int) sigset (SIGPIPE, SIG_IGN);	/* if the other end died, bombing out here */
#endif
	retstat = send (GB.socket, (char *)buffer, len, 0);	
#if defined (CLIX) || defined (X11)
	sigset (SIGPIPE, (void (*)())old);	/* restore old signal handler if any */
#endif
	if (retstat == len) return;
	moid = retstat < 0 ? MOID_WRITE_SOC : MOID_CANT_WRITE_FULL;
	JUMPOUT (SETERRNO (FROMWINAPI, NULL), NOVALC, moid);
}}}

	static void PACK_POSTMAN_BUFFER ( packedlen,
					  packedbuf, 

					  databuflen,
					  databuf, 
					  dstat, 
					  mfail, 
					  errmsg)
/*	------------------------------------------------
*	Pack components into packedbuf. See PMDATABUF
*	definition for buffer format
*	------------------------------------------------ */
	int		*packedlen;		/* o: */
	char		**packedbuf;		/* o: */

	int		databuflen;		/* i: */
	char		*databuf;		/* i: */
	int		dstat;			/* i: */
	int		mfail;			/* i: */
	ascii_char	*errmsg;		/* i: */
/*	------------------------------------------------ */
{{{	int		bytecount, len;
	PMDATABUF	*outbuf;
/*	------------------------------------------------ */
	if (!errmsg) errmsg = "";
	bytecount = sizeof dstat + sizeof mfail;
	len = strlen (errmsg) + SIZEOFNULLBYTE;
	bytecount += len;
	bytecount += databuflen;

	GET_BUFFER (PACKEDBUFFER, bytecount, packedbuf);
	outbuf = (PMDATABUF*) *packedbuf;
	memcpy (&outbuf->fullbuf.pmebuf.dstat, &dstat, sizeof dstat);
	memcpy (&outbuf->fullbuf.pmebuf.mfail, &mfail, sizeof mfail);
	strcpy (&outbuf->fullbuf.pmebuf.buf[0], errmsg);
	memcpy (&outbuf->fullbuf.pmebuf.buf[len], databuf, databuflen);
	*packedlen = bytecount;
}}}

	static void UNPACK_POSTMAN_BUFFER(
				packedlen, 
				packedbuf, 

				databuflen,
				databuf, 
				dstat, 
				mfail, 
				errmsg)
/*	------------------------------------------------
*	split inbuf into components. See PMDATABUF format.
*	packedlen must be good for at least 3 fields.
*	Split fields will refer to input addresses - so
*	input addresses should not be dynamic
*	------------------------------------------------ */
	int		packedlen;		/* i: packedbuf size in bytes */
	char		*packedbuf;		/* i: */

	int		*databuflen;		/* o: */
	char		**databuf;		/* o: */
	int		*dstat;			/* o: */
	int		*mfail;			/* o: */
	ascii_char	**errmsg;		/* o: */
/*	------------------------------------------------ */
{{{	int		i;
	PMDATABUF	*inbuf = (PMDATABUF*) packedbuf;
	char		*buf = inbuf->fullbuf.pmebuf.buf;
/*	------------------------------------------------ */
	memcpy (dstat, &inbuf->fullbuf.pmebuf.dstat, sizeof dstat);
	memcpy (mfail, &inbuf->fullbuf.pmebuf.mfail, sizeof mfail);

				/* find the first null termination */
	packedlen -= sizeof dstat + sizeof mfail;
	for (i=0; i<packedlen && buf[i]; i++);
	if (i == packedlen) {
	   JUMPOUT (Bias(MSGID_NOT_ENUF_FIELDS), NOVALC, MOID_UNPACK_BUFF);  /* null not found */
	}
	*errmsg = (ascii_char *)buf;

	i++; packedlen -= i;
	*databuflen = packedlen;
	*databuf = *databuflen ? &buf[i] : NULL;
}}}

	static void GET_BUFFER (bufferno, reqsize, buffer)
/*	---------------------------------------------
*	Tries to avoid realloc every time by storing
*	previous size, reallocing only to up the size
*	when necessary, using upping delta of 10000 
*	bytes. This may lessen problems due to 
*	continuous process memory expansion when small
*	upping deltas are used. On clix at least, the 
*	OS keeps allocating new memory space to process
*	until crash
*	-------------------------------------------- */
	int		bufferno;	/* i: 1, 2 */
	int		reqsize;	/* i: new size required; */
					/*    return resized buffer with */
					/*    null string */
					/*    if PREVIOUS, return previous data */
					/*    No nulling */
	char		**buffer;	/* i, o */
/*	-------------------------------------------- */
{{{	static 	int	size [BUFFERCOUNT+1];
	static 	char	*(buf [BUFFERCOUNT+1]);
		int	newsize;	
		unsigned int	checksize;
		char	tempmsg [BIGENUFMSGBUF];
/*	-------------------------------------------- */
	checksize = reqsize;
	if (reqsize != PREVIOUS && checksize> MAXBUFLEN_POSTMAN) {
           sprintf (tempmsg, Msgs[MSGID_BUF_TOO_BIG], reqsize, MAXBUFLEN_POSTMAN);
           JUMPOUT (Bias(MSGID_NOMSG), tempmsg, MOID_REALLOC_MALLOC);  	/* too big - garbage num? */
	}

	if (!size [bufferno] || reqsize >= size [bufferno]) {
	   newsize = size [bufferno];
	   while (reqsize >= newsize) newsize += UPPINGDELTA;
	   if (!size [bufferno]) {
              buf [bufferno] = (char *)malloc (newsize);
	   } else {
              buf [bufferno] = (char *)realloc (buf[bufferno], newsize);
	   }
	   if (!buf[bufferno]) 
		JUMPOUT (SETERRNO(FROMWINAPI, NULL), NOVALC, MOID_REALLOC_MALLOC);  	
	   size [bufferno] = newsize;
	   buf [bufferno][0] = 0;
	}

	if (reqsize != PREVIOUS) buf [bufferno][0] = 0;
	*buffer = buf [bufferno];
}}}

	static void SOCKET_SELECT ()
/*	--------------------------------------------
*	return only if the socket is ready to read.
*	Only for NT
*	--------------------------------------------*/
{{{
#ifdef	_NT_P_
	ascii_char	once=0;
	INT		rb;
/*	--------------------------------------------*/
	GB.waitsock.fd_count=1;               
	GB.waitsock.fd_array[0] = GB.socket;
	while (TRUE) {
	   rb = select (0, &GB.waitsock, 0, 0, NULL);	/* bug in select; returns 0 if ... */ 
							/* receive,send,receive done quickly */
	   if (rb) break;				/* good data */
	   if (once) break;				/* once done */
	   once=1;
	   Sleep (500);					/* bug in select */
	}
	if (rb == SOCKET_ERROR || rb == 0) {
	   JUMPOUT (SETERRNO(FROMWINAPI, NULL), NOVALC, MOID_SELECT_SOC);  	
	}
#endif
}}}	

	static void ALARMING (flag)
/*	-----------------------------------------
*	setting and unsetting of alarm for CLIX
*	----------------------------------------- */
	char		flag;	/* i: SET_ALARM, UNSET_ALARM */
/*	----------------------------------------- */
{{{
#if defined  (CLIX) || defined (X11)
	static int	   old=0;
/*	----------------------------------------- */
	switch (flag) {
	   case SET_ALARM: 
		GB.alarmed = FALSE;
		old = (int) sigset (SIGALRM, ALARMER);
		alarm (RECVWAIT * SECONDS);
		break;

	   case UNSET_ALARM:
	        alarm (0);
	        sigset (SIGALRM, (void (*)())old);	/* restore VDS' handlers if any */
		break;
	}
}}}

	static void ALARMER ()
/*	----------------------------
*	break me out of network hang
*	in recv call. The other postman
*	must have gone into loop
*	----------------------------*/
{{{	GB.alarmed = TRUE;
#endif
}}}

	static void SOCKET_CLOSE ()
/*	------------------------------------------------
*	Close socket if open
*	------------------------------------------------ */
{{{
/*	------------------------------------------------ */
	if (!GB.socketopen) return;
#if defined (CLIX) || defined (X11)
	close (GB.socket);
#endif
#ifdef	_NT_P_
	closesocket (GB.socket);
#endif
	GB.socketopen = FALSE;
}}}

	static void JUMPOUT (msgnum, ssuffix, pprefix)
/*	--------------------------------------------
*	longjump out after constructing message. 
*	Passing on SETERRNO arguments 
*	-------------------------------------------- */
	int 		msgnum;		/* i: if msgno == NOVAL, don't message */	
	char		*ssuffix;	/* i: if supplied, suffixed into msg */
	int 		pprefix;	/* i: message origination id */
/*	-------------------------------------------- */
{{{	if (msgnum != NOVAL) SETERRMSG (msgnum, ssuffix, pprefix);
	longjmp (GB.jmpbuf, JMPSTAT);
}}}

	static int SETERRNO (flag, no)
/*	-------------------------------------------------
*	errno getting/setting mess due to NT GetLastError 
*	and errno. NOTE: this is not an error storage
*	routine (for UNIX) - always returns errno (to keep
*	UNIX undisturbed)
*	-------------------------------------------------*/
	int	flag;		/* i: 0 - set from errno, 
				      1 - set from GetLastError,
				      2 - get,
				      3 - get message source 
				      4 - set from no; msgsou=WINAPI
				*/
	int	no;		/* i: for flag = 4 */
/*	--------------------------*/
{{{	static	int erderr, msgsou;
/*	--------------------------*/
	switch (flag) {
#if defined (CLIX) || defined (X11)
	   case FROMCRUNTIME:
	   case FROMWINAPI: erderr = errno; return (int) errno;

	   case GETERROR: 		   return (int) errno;
	   case GETMSGSOU: msgsou = 0; return msgsou;	/* from C runtime */
#endif
#ifdef	_NT_P_
	   case FROMCRUNTIME: 
		erderr = errno; msgsou = FROMCRUNTIME; return (int) errno;
	   case FROMWINAPI: 
		erderr = GetLastError (); msgsou = FROMWINAPI; return (int) erderr;
	   case GETERROR: return erderr;
	   case GETMSGSOU: return msgsou;
	   case FROMPARAM: 
		erderr = no; msgsou = FROMWINAPI; return no;
#endif
	}
	if (flag == FROMPARAM && no);			/* reference */
	return errno;
}}}

	static void SETERRMSG (msgno, suffix, prefix)
/*	-------------------------------------
*	PUt together message. The last two
*	args omittable if their value is NOVAL
*	Output goes to ERRMSGBUFFER
*	------------------------------------- */
	int 		msgno;			/* i: if <AMSG, system msg, else our msg */
	char		*suffix;		/* i: if supplied, suffixed into msg */
	int		prefix;			/* i: message origination id */
/*	------------------------------------- */
{{{	char	*mm, *nn;
	char	tmsg [5000], ntmsg[300];	/* sprintf does not exceed length */
	int	len, val;
/*	------------------------------------- */
	val = NOVAL;
	if (msgno < AMSG) {
#if defined (CLIX) || defined (X11)
	   if (ntmsg);				/* stop complaining */
	   if (msgno >= sys_nerr) mm = Msgs[MSGID_NOSYS_MSG], val = msgno;
           else mm = (char *) strerror (msgno);
#endif
#ifdef	_NT_P_
	   len = sizeof ntmsg-SAFETYNUM2;
	   NTMsg (msgno, (char)SETERRNO (GETMSGSOU, NULL), ntmsg, len);
	   mm = ntmsg;
#endif
	} else {
	   mm = (char *) Msgs [UnBias(msgno)];
	}

	tmsg[0] = '\0';
	if (prefix != NOVAL) {
	   sprintf (tmsg, "[%-s:%-s] ",  MSG_PREFIX, MsgOrigins [prefix]);
	}

	strcat (tmsg, mm);
	len = strlen (tmsg);
	if (val != NOVAL) sprintf (&tmsg [len], "[%-d]", val);		/* only for undefined errors */
	len = strlen (tmsg);

	if ((int) suffix != NOVAL) {
	   char *new;							/* embedded newline ? */
	   new = strchr (suffix, '\n') ? "\n" : "-";			/* put newline after prefix */
	   sprintf (&tmsg [len], " %s %-s", new, suffix);
	}
	len = strlen (tmsg);

	GET_BUFFER (ERRMSGBUFFER, len+SAFETYNUM, &nn);
	strcpy (nn, tmsg);
}}}
