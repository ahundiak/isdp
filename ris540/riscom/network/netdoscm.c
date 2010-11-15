/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*********************************************************************
**
**      NAME:           netdoscm.c
**      AUTHOR:         Dwayne Blumenberg
**      DATE:           09/09/92
**      DESCRIPTION:
**              This file contains the RIS "fake" TCP/IP functions and the
**              routines that interface to the real-mode TSR that issues the
**              "real" TCP/IP functions.
**
**		REVISION HISTORY:
**				July 93, modified so that now ris doesn't exit if the PC-TCP
**				driver (TSR) is not loaded in the memory, it displays the
**				error message.  Sanju
*********************************************************************/

/*
** INCLUDES
*/      
#include    <dos.h>
#include    <stdio.h>
#include    <stdlib.h>
#include    <sys/time.h>
#include    <assert.h>
#include    <string.h>
#include    <errno.h>
#include    <stddef.h>

#include    "dostcpip.h"
#include    "net.h"

/*
** DEFINES
*/
#define SEG(x)  ( ((unsigned short *) &(x))[1])
#define OFS(x)  ( ((unsigned short *) &(x))[0])

/* "rel2far" converts a relative ptr in the commarea (addressed by
   comm_ptr) to a protected_mode far pointer. */

#define rel2far(p) \
	((char _far *)comm_ptr + (int)(p))

/* "far2rel" converts a protected mode far pointer to a relative
    pointer, based on the beginning of the commarea (addressed by 
    comm_ptr) */

#define far2rel(p) \
	((char _near *) ( _FP_OFF(p) - _FP_OFF(comm_ptr)))


/*
** FUNCTION PROTOTYPES
*/
#define netdoscm_c
#include "netdoscm.prt"
#include "net_sys.prt"

/*
**      VARIABLES
*/
static int                              mpxId=0;
static char                                     idString[] = "RIS TCP DRIVER";

/* extern int volatile _near    h_errno;*/
int volatile _near                      h_errno;

struct commarea _far            *comm_ptr;              /* communications area */

/*
**      FUNCTIONS
*/
static unsigned long ftpcomm_getRmDataBuffer (
	void)

 /*********************************************************************/
 /* "ftpcomm_getRmDataBuffer"                                         */
 /*********************************************************************/

{
    union REGS regs;

    static _packed struct {             /* static ensures DS reg is base */
		unsigned short  intnum;
		unsigned short  ds;
		unsigned short  es;
		unsigned short  fs;
		unsigned short  gs;
		unsigned long   eax;
		unsigned long   edx;
	} rmIntRegs;

    rmIntRegs.intnum = 0x2f;
    rmIntRegs.eax = (mpxId << 8) + 1;
    regs.x.ax = 0x2511; /* DOSX call real mode int., regs spec. */
    regs.x.dx = (int)&rmIntRegs;
    intdos (&regs, &regs);

    return ((long)rmIntRegs.es << 16) + (regs.x.bx & 0x0ffff);

}       /* end of "ftpcomm_getRmDataBuffer */


static int ftpcomm_getTsrMpxId (
	void)

 /*********************************************************************/
 /* "ftpcomm_getTsrMpxId"                                             */
 /*********************************************************************/

{
    int                         i;
    char                        testid[128]="";
    union REGS          regs;

    static _packed struct {             /* static ensures DS reg is base */
		unsigned short  intnum;
		unsigned short  ds;
		unsigned short  es;
		unsigned short  fs;
		unsigned short  gs;
		unsigned long   eax;
		unsigned long   edx;
	}       rmIntRegs;


    rmIntRegs.intnum = 0x2f;

    for (i=0x80; i<=0xff; i++)
	{
		rmIntRegs.eax   = i << 8;
		regs.x.ax               = 0x2511;       /* DOSX call real mode int., regs spec. */
		regs.x.dx               = (int)&rmIntRegs;

		intdos (&regs, &regs);

		if (regs.x.ax & 0xff) {
			if ((regs.x.bx & 0x0ffff) < -sizeof(idString)) {

				copyFromReal (testid, rmIntRegs.es, 
					(regs.x.bx & 0x0ffff), sizeof(idString));

				if (!strcmp (testid, idString))
					return i;
			}
	    }
	}

    return 0;   /* not found */
}       /* end of "ftpcomm_getTsrMpxId */


extern int ftpcomm_initialize (
	void)

 /*********************************************************************/
 /* "ftpcomm_initialize"                                              */
 /*********************************************************************/

{
    union {
		unsigned long           lstat;
		struct {
			unsigned short  ofs;
			unsigned short  seg;
		} sstat;
	} status;

	typedef struct {                /* Ref:  Pharlap 386|Dos-Extender */
		unsigned        ofs;    /* Programmer's Guide to DPMI and */
		short           sel;    /* Windows, pp. 72-73 (Ver 4.0).  */
	} selofs;

	typedef union {                 /* Ref:  Pharlap 386|Dos-Extender */
		void _far       *fp;    /* Programmer's Guide to DPMI and */
		selofs          so;             /* Windows, pp. 72-73 (Ver 4.0).  */
	} farptr;


	NET_DBG(("ftpcomm_initialize() {protected mode}\n"));

    mpxId = ftpcomm_getTsrMpxId();

	if (mpxId == 0)
	{
		NET_DBG(("TCP DRIVER NOT LOADED {protected mode}\n"));
		errno = ENODEV;
		return(-1);
	}


    status.lstat = ftpcomm_getRmDataBuffer();

	((farptr *) (&(comm_ptr)))->so.sel = 0x34;

	((farptr *) (&(comm_ptr)))->so.ofs = 
		(status.sstat.seg<<4) + status.sstat.ofs;

	NET_DBG(("ftpcomm_initialize() complete.\n"));

}       /* end of "ftpcomm_initialize" */


extern void ftpcomm_sendTsrRequest (
	void)

 /*********************************************************************/
 /* "ftpcomm_sendTsrRequest"                                          */
 /*********************************************************************/

{
    union REGS regs;

    static _packed struct {             /* static ensures DS reg is base */
		unsigned short  intnum;
		unsigned short  ds;
		unsigned short  es;
		unsigned short  fs;
		unsigned short  gs;
		unsigned long   eax;
		unsigned long   edx;
	} rmIntRegs;

    rmIntRegs.intnum    = 0x2f;
    rmIntRegs.eax               = (mpxId << 8) + 2;
    regs.x.ax                   = 0x2511;       /* DOSX call real mode int., regs spec. */
    regs.x.dx                   = (int)&rmIntRegs;

	NET_DBG(("ftpcomm_sendTsrRequest() {protected mode}\n"));
    intdos (&regs, &regs);

/*
	NET_DBG((">>> ftpcomm_sendTsrRequest(): regs.x.cflag: %d\n", regs.x.cflag));
	NET_DBG((">>> ftpcomm_sendTsrRequest(): _doserrno: %d\n", _doserrno));
	{
		struct DOSERROR err;
		_dosexterr(&err);
	NET_DBG(("error = %d\n class = %d\n action = %d\n locus = %d\n", 
			err.exterror, err.class, err.action, err.locus));
		exit(-1);
	}
*/
			
	NET_DBG(("ftpcomm_sendTsrRequest(): _doserrno: %d\n", _doserrno));
	NET_DBG(("ftpcomm_sendTsrRequest() complete.\n"));

}       /* end of "ftpcomm_sendTsrRequest */


extern void copyFromReal (
		char dataBuffer[],
		unsigned short rmDataBufferSegment, 
		unsigned short rmDataBufferOffset, 
		long len)

 /*********************************************************************/
 /* "copyFromReal"                                                    */
 /*********************************************************************/

{
	char _far       *target;
	long            i;

	typedef struct {                /* Ref:  Pharlap 386|Dos-Extender */
		unsigned        ofs;    /* Programmer's Guide to DPMI and */
		short           sel;    /* Windows, pp. 72-73 (Ver 4.0).  */
	} selofs;

	typedef union {                 /* Ref:  Pharlap 386|Dos-Extender */
		void _far       *fp;    /* Programmer's Guide to DPMI and */
		selofs          so;     /* Windows, pp. 72-73 (Ver 4.0).  */
	} farptr;


	((farptr *) (&(target)))->so.sel = 0x34;

	((farptr *) (&(target)))->so.ofs = 
		(rmDataBufferSegment<<4) + rmDataBufferOffset;

	for (i=0;i<len;target++,i++) {
		dataBuffer[i] = *target;
	}

}       /* end of "copyFromReal" */


extern void _far * _fmemcpy (
	void _far *dest,
	const void _far *source,
	long len)

 /*********************************************************************/
 /* "_fmemcpy"                                                        */
 /*********************************************************************/

{
	long            i;
	char _far       *dest_c;
	char _far       *source_c;

	dest_c = dest;
	source_c = (void _far *)source;

	for (i=0; i<len; dest_c++, source_c++, i++) {
		*dest_c = *source_c;
	}

	return dest;

} /* end of "_fmemcpy" */


extern size_t _fstrlen (
	const char _far *string)

 /*********************************************************************/
 /* "_fstrlen"                                                        */
 /*********************************************************************/

{
	long            i;

	for (i=0; *string; string++,i++);
	return i;

} /* end of "_fstrlen" */


int errno_fixup(int errno_in)

 /*********************************************************************/
 /* "errno_fixup"                                                     */
 /*********************************************************************/

{
	return errno_in;        /* dummy function for now */

} /* end of "errno_fixup" */


extern struct servent PTR_DIST *getservbyname (
	char PTR_DIST *name,
	char PTR_DIST *proto)

 /*********************************************************************/
 /* "getservbyname"                                                   */
 /*                                                                   */
 /* Note:  We don't return any aliases.                               */
 /*********************************************************************/

{
	char _far                                                       *p;
	long                                                            len;
	static struct servent                           servent_out;
	struct getservbyname_parms _far         *work_ptr;
	static char                                                     *s_name_out = NULL;
	static char                                                     *s_proto_out = NULL;
	

 /*********************************************************************/
 /* Initialize link to real-mode TSR if not already done.             */
 /*********************************************************************/

	NET_DBG(("getservbyname() {protected mode}\n"));

	if (mpxId==0)
	{
		if(ftpcomm_initialize() == -1)
		{
			return(NULL);
		}
	}
	

 /*********************************************************************/
 /* Set opcode, and set work_ptr to point to the commarea overlay for */
 /* this opcode.                                                      */
 /*********************************************************************/

	comm_ptr->heading.opcode = GETSERVBYNAME;
	work_ptr = &(comm_ptr->parm.getservbyname_commarea);


 /*********************************************************************/
 /* Copy 'name' to commarea, and convert its pointer to a relative    */
 /* offset.                                                           */
 /*********************************************************************/

	p = &(work_ptr->variable);
	len = strlen(name) + 1;
	_fmemcpy(p,name,len);
	work_ptr->name = far2rel(p);


 /*********************************************************************/
 /* Copy 'proto' to commarea, and convert its pointer to a relative   */
 /* offset.                                                           */
 /*********************************************************************/

	p += len;
	len = strlen(proto) + 1;
	_fmemcpy(p,proto,len);
	work_ptr->proto = far2rel(p);


 /*********************************************************************/
 /* Issue interrupt to the real-mode TSR.                             */
 /*********************************************************************/

    ftpcomm_sendTsrRequest();


 /*********************************************************************/
 /* Fixup errno.  Then if the output pointer is NULL (indicating an   */
 /* error was encountered) just return NULL.                          */
 /*********************************************************************/

	errno = errno_fixup(work_ptr->errno);

	if (work_ptr->servent_out_ptr == NULL)
		return NULL;


 /*********************************************************************/
 /* Otherwise build static areas to hold the values returned in the   */
 /* commarea.  (We must use static areas since we can't return        */
 /* pointers to commarea fields as they are "far away").              */
 /*********************************************************************/

	else {
		servent_out = work_ptr->servent_out;    /* copy servent */
		servent_out.s_aliases = NULL;                   /* we don't do aliases */


 /*********************************************************************/
 /* Copy servent 'name' and convert its pointer from a relative       */
 /* offset to a _far pointer.                                         */
 /*********************************************************************/

		len = _fstrlen(rel2far(work_ptr->servent_out.s_name));

		s_name_out = (char *) realloc(s_name_out,len + 1);
		assert(s_name_out != NULL);

		_fmemcpy(s_name_out,
			rel2far(work_ptr->servent_out.s_name),
			len + 1);

		servent_out.s_name = s_name_out;


 /*********************************************************************/
 /* Copy servent 'proto' and convert its pointer from a relative      */
 /* offset to a _far pointer.                                         */
 /*********************************************************************/

		len = _fstrlen(rel2far(work_ptr->servent_out.s_proto));

		s_proto_out = (char *) realloc(s_proto_out,len + 1);
		assert(s_proto_out != NULL);

		_fmemcpy(s_proto_out,
			rel2far(work_ptr->servent_out.s_proto),
			len + 1);

		servent_out.s_proto = s_proto_out;


 /*********************************************************************/
 /* ...and return the static area pointer to the caller.              */
 /*********************************************************************/

		return &servent_out;
	}

}       /* end of "getservbyname" */


extern struct hostent PTR_DIST *gethostbyname (
	char PTR_DIST *name)

 /*********************************************************************/
 /* "gethostbyname"                                                   */
 /*                                                                   */
 /* Note:  We don't return any aliases, and we return only the first  */
 /*        address in the h_addr_list.                                */
 /*********************************************************************/

{
	char _far                                                       *p;
	long                                                            len;
	static struct hostent                           hostent_out;
	struct gethostbyname_parms _far         *work_ptr;
	static char                                                     *h_name_out = NULL;
	static char                                                     *h_list_out[2];
	static long                                                     ip_address;
	

 /*********************************************************************/
 /* Initialize link to real-mode TSR if not already done.             */
 /*********************************************************************/

	NET_DBG(("gethostbyname() {protected mode}\n"));

	if (mpxId==0)
	{
		if (ftpcomm_initialize() == -1)
		{
			return(NULL);
		}
	}
	

 /*********************************************************************/
 /* Set opcode, and set work_ptr to point to the commarea overlay for */
 /* this opcode.                                                      */
 /*********************************************************************/

	comm_ptr->heading.opcode = GETHOSTBYNAME;
	work_ptr = &(comm_ptr->parm.gethostbyname_commarea);


 /*********************************************************************/
 /* Copy 'name' to commarea, and convert its pointer to a relative    */
 /* offset.                                                           */
 /*********************************************************************/

	p = &(work_ptr->variable);
	len = strlen(name) + 1;
	_fmemcpy(p,name,len);
	work_ptr->name = far2rel(p);


 /*********************************************************************/
 /* Issue interrupt to the real-mode TSR.                             */
 /*********************************************************************/

    ftpcomm_sendTsrRequest();


 /*********************************************************************/
 /* Fixup errno.  Then if the output pointer is NULL (indicating an   */
 /* error was encountered) just return NULL.                          */
 /*********************************************************************/

	errno = errno_fixup(work_ptr->errno);
	h_errno = work_ptr->h_errno;
	NET_DBG(("gethostbyname() errno = %d\n",errno));

	if (work_ptr->hostent_out_ptr == NULL)
		return NULL;


 /*********************************************************************/
 /* Otherwise build static areas to hold the values returned in the   */
 /* commarea.  (We must use static areas since we can't return        */
 /* pointers to commarea fields as they are "far away").              */
 /*********************************************************************/

	else {
		hostent_out = work_ptr->hostent_out;    /* copy hostent */
		hostent_out.h_aliases = NULL;                   /* we don't do aliases */


 /*********************************************************************/
 /* Copy hostent 'name' and convert its pointer from a relative       */
 /* offset to a _far pointer.                                         */
 /*********************************************************************/

		len = _fstrlen(rel2far(work_ptr->hostent_out.h_name));
		NET_DBG(("gethostbyname() len = %d \n", len));

		h_name_out = (char *) realloc(h_name_out,len + 1);
		NET_DBG(("gethostbyname() before assert 1.\n"));
		assert(h_name_out != NULL);

		_fmemcpy(h_name_out,
			rel2far(work_ptr->hostent_out.h_name),
			len + 1);

		hostent_out.h_name = h_name_out;


 /*********************************************************************/
 /* Fixup hostent 'h_addr_list' and convert its pointer from a        */
 /* relative offset to a _far pointer.                                */
 /*                                                                   */
 /* Note:  Since we don't support more than one IP address, the       */
 /*        actual IP address was returned in                          */
 /*        'work_ptr->hostent_out.h_addr_list' by the TSR.            */
 /*********************************************************************/

		NET_DBG(("gethostbyname() before assert 2.\n"));
		assert(hostent_out.h_length == 4);      /* we only do longs */

		hostent_out.h_addr_list = (char _near * _near *)&h_list_out;

		h_list_out[0] = (char *)&ip_address;
		h_list_out[1] = NULL;                           /* end of list */

		ip_address = (long)work_ptr->hostent_out.h_addr_list;
		NET_DBG(("gethostbyname() ip_address = %d\n", ip_address));


 /*********************************************************************/
 /* ...and return the static area pointer to the caller.              */
 /*********************************************************************/

		NET_DBG(("gethostbyname() complete.\n"));
		return &hostent_out;
	}

}       /* end of "gethostbyname" */


extern int socket (
	int af,
	int type,
	int protocol)

 /*********************************************************************/
 /* "socket"                                                          */
 /*********************************************************************/

{
	struct socket_parms _far                *work_ptr;
	

 /*********************************************************************/
 /* Initialize link to real-mode TSR if not already done.             */
 /*********************************************************************/

	NET_DBG(("socket() {protected mode}\n"));

	if (mpxId==0)
	{
		if (ftpcomm_initialize() == -1)
		{
			return(-1);
		}
	}
	

 /*********************************************************************/
 /* Set opcode, and set work_ptr to point to the commarea overlay for */
 /* this opcode.                                                      */
 /*********************************************************************/

	comm_ptr->heading.opcode = SOCKET;
	work_ptr = &(comm_ptr->parm.socket_commarea);


 /*********************************************************************/
 /* Copy integer parms to commarea.                                   */
 /*********************************************************************/

	work_ptr->af            = af;
	work_ptr->type          = type;
	work_ptr->protocol      = protocol;


 /*********************************************************************/
 /* Issue interrupt to the real-mode TSR.                             */
 /*********************************************************************/

    ftpcomm_sendTsrRequest();


 /*********************************************************************/
 /* Fixup errno, then return the static area pointer to the caller.   */
 /*********************************************************************/

	errno = errno_fixup(work_ptr->errno);

	NET_DBG(("socket() complete.\n"));
	return work_ptr->socket_out;

}       /* end of "socket" */


extern int connect (
	int s,
	struct sockaddr *name,
	int namelen)

 /*********************************************************************/
 /* "connect"                                                         */
 /*********************************************************************/

{
	struct connect_parms _far               *work_ptr;
	

 /*********************************************************************/
 /* Initialize link to real-mode TSR if not already done.             */
 /*********************************************************************/

	NET_DBG(("connect() {protected mode}\n"));

	if (mpxId==0)
	{
		if (ftpcomm_initialize() == -1)
		{
			return(-1);
		}
	}
	

 /*********************************************************************/
 /* Set opcode, and set work_ptr to point to the commarea overlay for */
 /* this opcode.                                                      */
 /*********************************************************************/

	comm_ptr->heading.opcode = CONNECT;
	work_ptr = &(comm_ptr->parm.connect_commarea);


 /*********************************************************************/
 /* Copy parms to commarea.                                           */
 /*********************************************************************/

	work_ptr->socket        = s;
	work_ptr->namelen       = namelen;

	_fmemcpy(&work_ptr->name,
		(void _far *)name,
		sizeof (struct sockaddr));


 /*********************************************************************/
 /* Issue interrupt to the real-mode TSR.                             */
 /*********************************************************************/

    ftpcomm_sendTsrRequest();


 /*********************************************************************/
 /* Fixup errno, then return result to caller.                        */
 /*********************************************************************/

	errno = errno_fixup(work_ptr->errno);
	NET_DBG(("connect() complete.\n"));
	return work_ptr->connect_rc;

}       /* end of "connect" */


extern int PCTCP_read (
	int s,
	char *buf,
	int nbytes)

 /*********************************************************************/
 /* "read"                                                            */
 /*********************************************************************/

{
	struct read_parms _far          *work_ptr;
	

 /*********************************************************************/
 /* Initialize link to real-mode TSR if not already done.             */
 /*********************************************************************/

	NET_DBG(("PCTCP_read() {protected mode}\n"));

	if (mpxId==0)
	{
		if (ftpcomm_initialize() == -1)
		{
			return(-1);
		}
	}


 /*********************************************************************/
 /* Ensure buffer is large enough.                                    */
 /*********************************************************************/

	if(nbytes > (sizeof (struct commarea)) - 
		offsetof(struct commarea,parm.read_commarea.variable))
	{
		errno = ENOBUFS;
		return -1;
	}


 /*********************************************************************/
 /* Set opcode, and set work_ptr to point to the commarea overlay for */
 /* this opcode.                                                      */
 /*********************************************************************/

	comm_ptr->heading.opcode = READ;
	work_ptr = &(comm_ptr->parm.read_commarea);


 /*********************************************************************/
 /* Copy parms to commarea.                                           */
 /*********************************************************************/

	work_ptr->socket        = s;
	work_ptr->nbytes        = nbytes;


 /*********************************************************************/
 /* Issue interrupt to the real-mode TSR.                             */
 /*********************************************************************/

    ftpcomm_sendTsrRequest();


 /*********************************************************************/
 /* Fixup errno, then return results to caller.                       */
 /*********************************************************************/

	errno = errno_fixup(work_ptr->errno);

	if (work_ptr->read_rc > 0)
		_fmemcpy((void _far *)buf,      /* need to make sure we don't */
			&work_ptr->variable,    /* go past end of buffer!     */
			work_ptr->read_rc);

	NET_DBG(("PCTCP_read() complete.\n"));
	return work_ptr->read_rc;

}       /* end of "read" */


extern int PCTCP_write (
	int s,
	char *buf,
	int nbytes)

 /*********************************************************************/
 /* "write"                                                           */
 /*********************************************************************/

{
	struct write_parms _far         *work_ptr;
	

 /*********************************************************************/
 /* Initialize link to real-mode TSR if not already done.             */
 /*********************************************************************/

	NET_DBG(("PCTCP_write() {protected mode}\n"));

	if (mpxId==0)
	{
		if (ftpcomm_initialize() == -1)
		{
			return(-1);
		}
	}
	

 /*********************************************************************/
 /* Ensure buffer is large enough.                                    */
 /*********************************************************************/

	if(nbytes > (sizeof (struct commarea)) - 
		offsetof(struct commarea,parm.write_commarea.variable))
	{
		errno = ENOBUFS;
		return -1;
	}

 /*********************************************************************/
 /* Set opcode, and set work_ptr to point to the commarea overlay for */
 /* this opcode.                                                      */
 /*********************************************************************/

	comm_ptr->heading.opcode = WRITE;
	work_ptr = &(comm_ptr->parm.write_commarea);


 /*********************************************************************/
 /* Copy parms to commarea.                                           */
 /*********************************************************************/

	work_ptr->socket        = s;
	work_ptr->nbytes        = nbytes;

	_fmemcpy(&work_ptr->variable,   /* need to make sure we don't */
		(void _far *)buf,                       /* go past end of buffer!     */
		nbytes);


 /*********************************************************************/
 /* Issue interrupt to the real-mode TSR.                             */
 /*********************************************************************/

    ftpcomm_sendTsrRequest();


 /*********************************************************************/
 /* Fixup errno, then return results to caller.                       */
 /*********************************************************************/

	errno = errno_fixup(work_ptr->errno);

	NET_DBG(("PCTCP_write() complete.\n"));
	return work_ptr->write_rc;

}       /* end of "write" */


extern int getdomainname (
	char *name,
	int namelen)

 /*********************************************************************/
 /* "getdomainname"                                                   */
 /*********************************************************************/

{
	struct getdomainname_parms _far         *work_ptr;
	

 /*********************************************************************/
 /* Initialize link to real-mode TSR if not already done.             */
 /*********************************************************************/

	if (mpxId==0)
	{
		if (ftpcomm_initialize() == -1)
		{
			return(-1);
		}
	}
	

 /*********************************************************************/
 /* Set opcode, and set work_ptr to point to the commarea overlay for */
 /* this opcode.                                                      */
 /*********************************************************************/

	comm_ptr->heading.opcode = GETDOMAINNAME;
	work_ptr = &(comm_ptr->parm.getdomainname_commarea);


 /*********************************************************************/
 /* Copy parms to commarea.                                           */
 /*********************************************************************/

	work_ptr->namelen       = namelen;


 /*********************************************************************/
 /* Issue interrupt to the real-mode TSR.                             */
 /*********************************************************************/

    ftpcomm_sendTsrRequest();


 /*********************************************************************/
 /* Fixup errno, then return results to caller.                       */
 /*********************************************************************/

	errno = errno_fixup(work_ptr->errno);

	if (work_ptr->getdomainname_rc > 0)
		_fmemcpy((void _far *)name,
			&work_ptr->variable,
			work_ptr->getdomainname_rc + 1);

	return work_ptr->getdomainname_rc;

}       /* end of "getdomainname" */


extern int gethostname (
	char *name,
	int namelen)

 /*********************************************************************/
 /* "gethostname"                                                     */
 /*********************************************************************/

{
	struct gethostname_parms _far           *work_ptr;
	

 /*********************************************************************/
 /* Initialize link to real-mode TSR if not already done.             */
 /*********************************************************************/

	if (mpxId==0)
	{
		if (ftpcomm_initialize() == -1)
		{
			return(-1);
		}
	}
	

 /*********************************************************************/
 /* Set opcode, and set work_ptr to point to the commarea overlay for */
 /* this opcode.                                                      */
 /*********************************************************************/

	comm_ptr->heading.opcode = GETHOSTNAME;
	work_ptr = &(comm_ptr->parm.gethostname_commarea);


 /*********************************************************************/
 /* Copy parms to commarea.                                           */
 /*********************************************************************/

	work_ptr->namelen       = namelen;


 /*********************************************************************/
 /* Issue interrupt to the real-mode TSR.                             */
 /*********************************************************************/

    ftpcomm_sendTsrRequest();


 /*********************************************************************/
 /* Fixup errno, then return results to caller.                       */
 /*********************************************************************/

	errno = errno_fixup(work_ptr->errno);

	if (work_ptr->gethostname_rc > 0)
		_fmemcpy((void _far *)name,
			&work_ptr->variable,
			work_ptr->gethostname_rc + 1);

	return work_ptr->gethostname_rc;

}       /* end of "gethostname" */


extern int PCTCP_close (
	int s)

 /*********************************************************************/
 /* "close"                                                           */
 /*********************************************************************/

{
	struct close_parms _far         *work_ptr;
	

 /*********************************************************************/
 /* Initialize link to real-mode TSR if not already done.             */
 /*********************************************************************/

	if (mpxId==0)
	{
		if (ftpcomm_initialize() == -1)
		{
			return(-1);
		}
	}
	

 /*********************************************************************/
 /* Set opcode, and set work_ptr to point to the commarea overlay for */
 /* this opcode.                                                      */
 /*********************************************************************/

	comm_ptr->heading.opcode = CLOSE;
	work_ptr = &(comm_ptr->parm.close_commarea);


 /*********************************************************************/
 /* Copy parms to commarea.                                           */
 /*********************************************************************/

	work_ptr->socket        = s;


 /*********************************************************************/
 /* Issue interrupt to the real-mode TSR.                             */
 /*********************************************************************/

    ftpcomm_sendTsrRequest();


 /*********************************************************************/
 /* Fixup errno, then return results to caller.                       */
 /*********************************************************************/

	errno = errno_fixup(work_ptr->errno);

	return work_ptr->close_rc;

}       /* end of "close" */


extern int PCTCP_select (
	int nfds, 
	struct fd_set *readfds, 
	struct fd_set *writefds,
	struct fd_set *exceptfds, 
	struct timeval *timeout)

 /*********************************************************************/
 /* "select"                                                          */
 /*********************************************************************/

{
	struct select_parms _far                *work_ptr;
	char _far                                               *temp;
	

 /*********************************************************************/
 /* Initialize link to real-mode TSR if not already done.             */
 /*********************************************************************/

	if (mpxId==0)
	{
		if (ftpcomm_initialize() == -1)
		{
			return(0);
		}
	}
	

 /*********************************************************************/
 /* Set opcode, and set work_ptr to point to the commarea overlay for */
 /* this opcode.                                                      */
 /*********************************************************************/

	comm_ptr->heading.opcode = SELECT;
	work_ptr = &(comm_ptr->parm.select_commarea);


 /*********************************************************************/
 /* Copy parms to commarea.                                           */
 /*********************************************************************/

	work_ptr->nfds          = nfds;


 /*********************************************************************/
 /* If 'readfds' is not NULL then convert it to a relative offset     */
 /* and copy the read fds bits to the commarea.                       */
 /*********************************************************************/

	if (readfds) {
		temp = (char _far *) (&work_ptr->readfds);

		work_ptr->readfds_ptr =
			(struct fd_set PTR_DIST *)(far2rel(temp));

		work_ptr->readfds       = *readfds;
	}

	else
		work_ptr->readfds_ptr = NULL;


 /*********************************************************************/
 /* If 'writefds' is not NULL then convert it to a relative offset    */
 /* and copy the write fds bits to the commarea.                      */
 /*********************************************************************/

	if (writefds) {
		temp = (char _far *) (&work_ptr->writefds);

		work_ptr->writefds_ptr =
			(struct fd_set PTR_DIST *)(far2rel(temp));

		work_ptr->writefds      = *writefds;
	}

	else
		work_ptr->writefds_ptr = NULL;


 /*********************************************************************/
 /* If 'exceptfds' is not NULL then convert it to a relative offset   */
 /* and copy the except fds bits to the commarea.                     */
 /*********************************************************************/

	if (exceptfds) {
		temp = (char _far *) (&work_ptr->exceptfds);

		work_ptr->exceptfds_ptr =
			(struct fd_set PTR_DIST *)far2rel(temp);

		work_ptr->exceptfds     = *exceptfds;
	}

	else
		work_ptr->exceptfds_ptr = NULL;


 /*********************************************************************/
 /* If 'timeout' is not NULL then convert it to a relative offset     */
 /* and copy the timeout values to the commarea.                      */
 /*********************************************************************/

	if (timeout) {
		temp = (char _far *) (&work_ptr->exceptfds);

		work_ptr->timeout_ptr =
			(struct timeval PTR_DIST *)far2rel(temp);

		work_ptr->timeout       = *timeout;
	}

	else
		work_ptr->timeout_ptr = NULL;


 /*********************************************************************/
 /* Issue interrupt to the real-mode TSR.                             */
 /*********************************************************************/

    ftpcomm_sendTsrRequest();


 /*********************************************************************/
 /* Fixup errno, then return results to caller.                       */
 /*********************************************************************/

	errno = errno_fixup(work_ptr->errno);

	if (readfds)
		*readfds = work_ptr->readfds;

	if (writefds)
		*writefds = work_ptr->writefds;

	if (exceptfds)
		*exceptfds = work_ptr->exceptfds;

	return work_ptr->select_rc;

}       /* end of "select" */


extern int PCTCP_fcntl (
	int fd,
	int cmd,
	int arg)

 /*********************************************************************/
 /* "fcntl"                                                           */
 /*********************************************************************/

{
	struct fcntl_parms _far         *work_ptr;
	

 /*********************************************************************/
 /* Initialize link to real-mode TSR if not already done.             */
 /*********************************************************************/

	if (mpxId==0)
	{
		if (ftpcomm_initialize() == -1)
		{
			return(-1);
		}
	}
	

 /*********************************************************************/
 /* Set opcode, and set work_ptr to point to the commarea overlay for */
 /* this opcode.                                                      */
 /*********************************************************************/

	comm_ptr->heading.opcode = FCNTL;
	work_ptr = &(comm_ptr->parm.fcntl_commarea);


 /*********************************************************************/
 /* Copy parms to commarea.                                           */
 /*********************************************************************/

	work_ptr->fd    = fd;
	work_ptr->cmd   = cmd;
	work_ptr->arg   = arg;


 /*********************************************************************/
 /* Issue interrupt to the real-mode TSR.                             */
 /*********************************************************************/

    ftpcomm_sendTsrRequest();


 /*********************************************************************/
 /* Fixup errno, then return results to caller.                       */
 /*********************************************************************/

	errno = errno_fixup(work_ptr->errno);

	return work_ptr->fcntl_rc;

}       /* end of "fcntl" */


extern unsword htons (
	unsword hostshort)

 /*********************************************************************/
 /* "htons"                                                           */
 /*********************************************************************/

{
	return ((hostshort << 8) + (hostshort >> 8));   /* swap bytes */

}       /* end of "htons" */


extern unsword ntohs (
	unsword netshort)

 /*********************************************************************/
 /* "ntohs"                                                           */
 /*********************************************************************/

{
	return ((netshort << 8) + (netshort >> 8));     /* swap bytes */

}       /* end of "ntohs" */


extern unslword htonl (
	unslword hostlong)

 /*********************************************************************/
 /* "htonl"                                                           */
 /*********************************************************************/

{
	union {
		unsigned long   l;
		unsigned char   c[4];
	} in,out;

	in.l = hostlong;

	out.c[0] = in.c[3];
	out.c[1] = in.c[2];
	out.c[2] = in.c[1];
	out.c[3] = in.c[0];

	return out.l;

}       /* end of "htonl" */


extern char *inet_ntoa (
	struct in_addr in)

 /*********************************************************************/
 /* "inet_ntoa"                                                       */
 /*********************************************************************/

{
	static char     INNTOAWK[16];

	sprintf(INNTOAWK,
			"%d.%d.%d.%d",
			(in.s_addr & 0x000000ff),
			(in.s_addr & 0x0000ff00) >> 8,
			(in.s_addr & 0x00ff0000) >> 16,
			(in.s_addr & 0xff000000) >> 24);

	return INNTOAWK;

}       /* end of "inet_ntoa" */


extern unslword inet_addr(
	char *s)

 /*********************************************************************/
 /* "inet_addr"                                                       */
 /*                                                                   */
 /* Note:  This routine was copied verbatim for FTP's PC/TCP source   */
 /*        in file c:\tcp\src\socket\inet.c.                          */
 /*********************************************************************/

{
	u_long  a, n, mask;
	int     dots, digs, shft;

	mask = ~0;
	a = 0;
	shft = 32;
	for(dots = 0; dots < 4; ++dots, ++s) {
		for(digs = n = 0; '0'<= *s && *s <= '9'; ++s, ++digs)
			n = n * 10 + *s - '0';

		if(! digs)
			return((unsigned long )-1);

		if(! *s)
			shft = 0;
		else
			shft -= 8;

		a |= (n & mask) << shft;
		mask >>= 8;

		if(*s != '.')
			break;
	}
	if(dots < 1 || dots > 3 || *s)
		a = ~0;
	
	return(htonl(a));

}       /* end of "inet_addr" */


extern int PCTCP_sleep (
	int s)

 /*********************************************************************/
 /* "sleep"                                                           */
 /*                                                                   */
 /* Note:  FTP's PC/TCP sleep() will never be interrupted by a        */
 /*        signal (compared to UNIX's sleep() which can be            */
 /*        interrupted.)                                              */
 /*********************************************************************/

{
	struct sleep_parms _far         *work_ptr;
	

 /*********************************************************************/
 /* Initialize link to real-mode TSR if not already done.             */
 /*********************************************************************/

	if (mpxId==0)
	{
		if (ftpcomm_initialize() == -1)
		{
			return(0);
		}
	}
	

 /*********************************************************************/
 /* Set opcode, and set work_ptr to point to the commarea overlay for */
 /* this opcode.                                                      */
 /*********************************************************************/

	comm_ptr->heading.opcode = SLEEP;
	work_ptr = &(comm_ptr->parm.sleep_commarea);


 /*********************************************************************/
 /* Copy parms to commarea.                                           */
 /*********************************************************************/

	work_ptr->seconds       = s;


 /*********************************************************************/
 /* Issue interrupt to the real-mode TSR.                             */
 /*********************************************************************/

    ftpcomm_sendTsrRequest();


 /*********************************************************************/
 /* Fixup errno, then return results to caller.                       */
 /*********************************************************************/

	errno = errno_fixup(work_ptr->errno);

	return work_ptr->sleep_rc;

}       /* end of "sleep" */
