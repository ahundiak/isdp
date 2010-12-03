/* ==============================================================================
 * SOL10 03 Dec 2010
 * Pretty much copied intact and it seemed to work
 *
 * Tempting to go through with a comb and see what it is really doing
 */

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
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <sys/types.h> 
#include <sys/stat.h> 
#include <signal.h>
#include <setjmp.h>

#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>

typedef char ascii_char;
typedef uint Boolean;

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

#define	EXIT_SUCCESS		0			/* these are defined for NT */
#define	EXIT_FAILURE		1

#define MSG_PREFIX		"CLIX:"			/* error msg prefix for clix side errors */
#define OKAY			0

#define CLIX_CONNECT		-1			/* flag to connect socket */
#define CLIX_DISCONNECT		-2			/* flag to disconnect socket */


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



static 	void 		ALARMER ();
static  void 		CLIX_SET_HOSTNAME ();
static	void 		POSTMAN_CONNECT_ON_CLIX ();
static  void 		POSTMAN_GET_INIT_DATA (int*, ascii_char**);

int POSTMAN_REQUEST_ON_CLIX (int, char*, int*, char**, int*, ascii_char**);


static 	ascii_char 	*GET_PROXY_CLIENT_ADDRESS ();
#include "VDPaimPostMsgs.h"

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
	} GLOBALDATA;


	static GLOBALDATA	GB;
	extern int  sys_nerr; // Where does this come from?
	static char	proxy_client_address[50];


#if defined (CLIX) || defined (X11)

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
#if 0	
{
  int code;
  char *p;

  memcpy(&code,inbuf,4);
  if (inbuflen > 4) p = &inbuf[4];
  else p = "NONE";

  printf("POSTMAN Code %d %s\n",code,p);
}
#endif
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
	for (j=0; j<RETRY_COUNTER; j++) { /* avoid very occasional "refused connec" ... */
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
	gethostname ((char *)&GB.clixhost, sizeof GB.clixhost-SAFETYNUM);
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
           /* I really wonder why we dont surround this with sig traps
            * or even use socket_write_chunk
            */
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
