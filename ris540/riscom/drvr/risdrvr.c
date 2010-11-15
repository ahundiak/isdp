/* Do not alter this SPC information: $Revision: 1.2.52.1 $ */
 /*************************************************************************/
 /* "ftpdrvr"                                                             */
 /*                                                                       */
 /* Function:                                                             */
 /*     This routine is a real-mode TSR which accepts requests (via       */
 /*     an interrupt) and passes the request to TCP/IP using socket       */
 /*     calls.                                                            */
 /*                                                                       */
 /*     This code is dependent on FTP's PC/TCP socket library and         */
 /*     header files, and the Microsoft C/C++ V7.0.  This code must       */
 /*     be used with compiler options and librarys supporting "_far"      */
 /*     (4-byte) pointers.                                                */
 /*                                                                       */
 /*     This code is based on sample code provided by Mike Stratoti       */
 /*     of Bently Systems, Inc.   --DAB                                   */
 /*                                                                       */
 /*     Revision History:                                                 */
 /*             3-9-93 modified process_socket, now it closes the         */
 /*     previously hanging socket if interruped.  -- SK                   */
 /*             4-21-93 modified the code, not using assembly code any    */
 /*     more. -- SK                                                       */
 /*             6-1-93 modified getFreeMultiplexId, it doesn't reinstall  */
 /*     the TSR if it is already installed. -- SK                         */
 /*             Dec. 93 modified this file to also work with PCNFS. -- SK */
 /*                             Jan. 93 Implemented sleep() for PCNFS. -- SK              */
 /*                             Jan. 93 Made changes to process_select() for PCNFS, added */
 /*             some macros in ftpdefs.h -- SK                                    */
 /*		May 94 Modified this file to also work for IBM TCP/IP.    */
 /*                                              -- sanju & ashley         */
 /*************************************************************************/
 /* I know looks screwy, but belive me or not the order of the include    */ 
 /* files matters here in this wonderful world of PC's. -- SK             */ 
#include    <dos.h>
#include    <stdio.h>
#if defined (PCTCP) 
#include    <4bsddefs.h>
#endif
#if defined (IBMTCP)
#include <sys/tcptypes.h>
#include <sys/types.h>
#include <sys/uio.h>
#endif
#if defined (PCNFS)
#include        <sys/tk_types.h>
#include        <tklib.h>
#endif
#include    <sys/socket.h>
#include    <netdb.h>
#if defined (PCTCP) || defined (IBMTCP)
#include    <arpa/inet.h>
#endif
#include    <netinet/in.h>
#if defined (PCNFS)
#include        <in_addr.h>
#include    <tk_errno.h>
#endif
#if defined (PCTCP) || defined (IBMTCP)
#include    <errno.h>
#endif
#include    <sys/ioctl.h>
#include    <string.h>
#if defined (PCTCP) 
#include    <sys/time.h>
#include    <pctcp/types.h>
#include    <pctcp/pctcp.h>
#include    <pctcp/options.h>
#endif
#
#if defined (PCNFS)
#include    <sys/nfs_time.h>
#include        <stdlib.h>
#endif
#if defined (IBMTCP)
#include        <stdlib.h>
#include        <time.h>
#include        <arpa/nameser.h>
#include        <resolv.h>
#endif /* IBMTCP */

#include    "ftpdefs.h"


 /*********************************************************************/
 /* Macro definitions.                                                */
 /*********************************************************************/
int RISdrvr_debug = 0;
#define NET_DBG(s) { if(RISdrvr_debug) printf s; }

long _ADDRESS;      /* Global Variable For Macro SHIFTL(x, n) */

#define SHIFTL(x, n) (_ADDRESS = 0L, _ADDRESS = (long) x, _ADDRESS << n);
#define HIBYTE(x) (((unsigned) (x) >> 8) & 0xff)
#define LOBYTE(x) (((unsigned) (x)) & 0xff)

#define GET_PSP_DOS3    	0x62
#define SET_PSP                 0x50

#define INSTALLED               0xff

#define REGPAK unsigned es, unsigned ds, unsigned di, unsigned si,\
	       unsigned bp, unsigned sp, unsigned bx, unsigned dx,\
	       unsigned cx, unsigned ax, unsigned ip,unsigned  cs,\
	       unsigned flags


/* "rel2far" converts a relative ptr in the commarea (addressed by
   &commarea) to a real mode far pointer. */

#define rel2far(p) \
	((char _far *)&commarea + (long)(p))

/* "far2rel" converts a real mode far pointer to a relative
    pointer, based on the beginning of the commarea (addressed by 
    &commarea) */

#define far2rel(p) \
		(char _far *)(((long)(p - (char _far *)&commarea)))


 /*********************************************************************/
 /* Function prototypes.                                              */
 /*********************************************************************/

void cdecl interrupt far isrEntryPoint(REGPAK);
unsigned getMemSize(void);
void process(long opcode);
void process_getservbyname(struct getservbyname_parms *work_ptr);
void process_gethostbyname(struct gethostbyname_parms *work_ptr);
void process_socket(struct socket_parms *work_ptr);
void process_connect(struct connect_parms *work_ptr);
void process_read(struct read_parms *work_ptr);
void process_write(struct write_parms *work_ptr);
void process_getdomainname(struct getdomainname_parms *work_ptr);
void process_gethostname(struct gethostname_parms *work_ptr);
void process_close(struct close_parms *work_ptr);
void process_select(struct select_parms *work_ptr);
void process_fcntl(struct fcntl_parms *work_ptr);
void process_sleep(struct sleep_parms *work_ptr);
/* ASHLEY 9/14/94 - added prototype
*/
#if defined(IBMTCP)
void micro_sleep(clock_t wait);
#endif

 /*********************************************************************/
 /* Static and external variables.                                    */
 /*********************************************************************/

void                            (interrupt far *multiplexChainAddr)();
int                                     multiplexId;
int prev_sockdes = -1;
char                            tsrId[]="RIS PCTCP DRIVER";

struct commarea         commarea;       /* communications area */

#if defined (PCTCP) 
int volatile _near       h_errno;
#endif
#if defined (IBMTCP) 
extern int 		tcperrno;
#endif

void main(void)

 /*********************************************************************/
 /* "main"                                                            */
 /*                                                                   */
 /* Function:                                                         */
 /*     Install interrupt handler, terminate and stay resident.       */
 /*                                                                   */
 /*********************************************************************/
{
    void (interrupt far *isrAddress)() = isrEntryPoint;

    multiplexChainAddr = _dos_getvect(0x2f);

    if ((multiplexId = getFreeMultiplexId()) != 0) {
		_dos_setvect(0x2f, isrAddress);
#if defined(PCNFS)
		printf ("%s:  Installed PCNFS DRIVER on Multiplex ID %x\n", 
			tsrId,multiplexId);
#endif
#if defined(PCTCP)
		printf ("%s:  Installed PCTCP DRIVER on Multiplex ID %x\n", 
			tsrId,multiplexId);
#endif
#if defined(IBMTCP)
		printf ("%s:  Installed IBMTCP DRIVER on Multiplex ID %x\n", 
			tsrId,multiplexId);
#endif

		printf ("%s:  Data buffer at %p\n",tsrId, &commarea);
#if defined(DEBUG)
		printf("This is the DEBUG version of the driver!!!!\n");
#endif

		_dos_keep(0, getMemSize());     
	}

    else {
		printf ("%s:  Error: no free multiplex Id's\n",tsrId);
		printf ("%s:  TSR not installed\n",tsrId);
	}

}       /* end of "main" */


unsigned getMemSize()

 /*********************************************************************/
 /* "getMemSize"                                                      */
 /*                                                                   */
 /* Function:                                                         */
 /*     This routine returns the number of bytes to keep resident.    */
 /*********************************************************************/

{
    unsigned far *psp_pointer;

    psp_pointer = (int far *) SHIFTL(_psp, 16); /* Get segment of the PSP */
    return(psp_pointer[1] - _psp);   /* Amount of memory to stay resident */

}       /* end of "getMemSize" */


int getFreeMultiplexId()

 /*********************************************************************/
 /* "getFreeMultiplexId"                                              */
 /*                                                                   */
 /* Function:                                                         */
 /*     This routine returns the 1st free multiplex interrupt id.     */
 /*********************************************************************/

{
    int         i;
    union REGS  regs;

    for (i=0x80; i<0xff; i++)
	{
		regs.h.ah = i;
		regs.h.al = 0;
		int86 (0x2f, &regs, &regs);
		if (regs.h.al == INSTALLED)
		{
#if defined(PCNFS)
			puts("RIS PCNFS DRIVER already installed\n");
#endif
#if defined(PCTCP)
			puts("RIS PCTCP DRIVER already installed\n");
#endif
#if defined(IBMTCP)
			puts("RIS IBMTCP DRIVER already installed\n");
#endif
			exit(1);
		}
		if (!regs.h.al)                 /* 2 hours! */
	    return i;
	}

    return 0;

}       /* end of "getFreeMultiplexId" */


unsigned getPsp()

 /*********************************************************************/
 /* "getPsp"                                                          */
 /*                                                                   */
 /* Function:                                                         */
 /*     This routine returns the segment address of the program.      */
 /*********************************************************************/

{
    union REGS  regs;

	regs.h.ah = GET_PSP_DOS3;
	intdos(&regs, &regs);
	return regs.x.bx;
}


void setPsp(sp)

 /*********************************************************************/
 /* "setPsp"                                                          */
 /*                                                                   */
 /* Function:                                                         */
 /*     This routine sets the segment address of the PSP.             */
 /*********************************************************************/

unsigned        sp;

{
    union REGS  regs;
    struct _DOSERROR doserror;

#if defined(DEBUG) 
    printf ("setPsp() SET_PSP <0x%x>\n", SET_PSP);
    printf ("setPsp() sp <0x%x>\n", sp);
#endif

	regs.h.ah = SET_PSP;
	regs.x.bx = sp;
	intdos(&regs, &regs);

#if defined(DEBUG) 
	printf(">>> setPsp(): _doserrno: %d\n", _doserrno);

	if (_doserrno)
	{
		_dosexterr(&doserror);
		printf("Error: <%d> Class: <%d> Action: <%d> Locus <%d>\n", doserror.exterror, doserror.errclass, doserror.action, doserror.locus);
	}
#endif

}

void cdecl interrupt far isrEntryPoint(REGPAK)

 /*********************************************************************/
 /* "isrEntryPoint"                                                   */
 /*                                                                   */
 /* Function:                                                         */
 /*     This routine is entered with the multiplex interrupt id is    */
 /*     triggered.                                                    */
 /*********************************************************************/

{
	short   savedPsp;

    if (HIBYTE(ax) != multiplexId)      /* not ours?  pass it along */
		_chain_intr(multiplexChainAddr);

    savedPsp = getPsp();
    setPsp (_psp);

#if defined(DEBUG) 
    printf ("Request received, ax=%x, bx=%x, cx=%x, dx=%x\n", ax,bx,cx,dx);
    printf ("                  si=%x, di=%x, bp=%x, sp=%x\n", si,di,bp,sp);
    printf ("                  ds=%x, es=%x\n", ds,es);
#endif

    switch (LOBYTE(ax))
	{
		case DRVRMSG_DriverLoaded:                      /* Presence test */
			ax = (multiplexId<<8) + 0xff;
			es = ((long)tsrId) >> 16;
			bx = ((long)tsrId) & 0xffff;
			break;

		case DRVRMSG_GetBufferAddress:      /* Return Data Buffer address */
#if 0 
			memset(&commarea,0,sizeof commarea);
			strcpy(commarea.parm.buffer,"buffer eyecatcher");
#endif
			es = ((long)&commarea) >> 16;
			bx = ((long)&commarea) & 0xffff;
			break;

		case DRVRMSG_ProcessFTPCommand:     /* Process FTP library command */
			NET_DBG(("Processing opcode %ld\n",commarea.heading.opcode));
			process(commarea.heading.opcode);
			break;

		default:
			break;

	}       /* end switch */

#if defined(DEBUG) 
    printf ("TSR setting psp, preparing for return\n");
#endif

    setPsp (savedPsp);

#if defined(DEBUG) 
    printf ("TSR AFTER setting psp, preparing for RETURN\n");
#endif

}       /* end of "isrEntryPoint" */


void process(long opcode)

 /*********************************************************************/
 /* "process"                                                         */
 /*********************************************************************/

{
/* ASHLEY - 9/16/94 - used to slow processing for Pentium
*/
#if defined(IBMTCP)
  	micro_sleep((clock_t) 1);
#endif
	switch (opcode) {
		case GETSERVBYNAME:
			process_getservbyname(&commarea.parm.getservbyname_commarea);
			break;

		case GETHOSTBYNAME:
			process_gethostbyname(&commarea.parm.gethostbyname_commarea);
			break;

		case SOCKET:
			process_socket(&commarea.parm.socket_commarea);
			break;

		case CONNECT:
			process_connect(&commarea.parm.connect_commarea);
			break;

		case READ:
			process_read(&commarea.parm.read_commarea);
			break;

		case WRITE:
			process_write(&commarea.parm.write_commarea);
			break;

		case GETDOMAINNAME:
			process_getdomainname(&commarea.parm.getdomainname_commarea);
			break;

		case GETHOSTNAME:
			process_gethostname(&commarea.parm.gethostname_commarea);
			break;

		case CLOSE:
			process_close(&commarea.parm.close_commarea);
			break;

		case SELECT:
			process_select(&commarea.parm.select_commarea);
			break;

		case FCNTL:
			process_fcntl(&commarea.parm.fcntl_commarea);
			break;

		case SLEEP:
			process_sleep(&commarea.parm.sleep_commarea);
			break;

		default:
			printf("Opcode value %ld is invalid\n",opcode);
			break;

	}       /* end switch */

}       /* end of "process" */


void process_getservbyname(struct getservbyname_parms *work_ptr)

 /*********************************************************************/
 /* "process_getservbyname"                                           */
 /*********************************************************************/
{
	char    *p;
	int             name_len,proto_len;


 /*********************************************************************/
 /* Convert relative addresses in commarea to _far pointers.          */
 /*********************************************************************/

	work_ptr->name = rel2far(work_ptr->name);
	work_ptr->proto = rel2far(work_ptr->proto);


 /*********************************************************************/
 /* Clear errno, then issue the socket call.                          */
 /*********************************************************************/
#if defined(PCTCP) || defined(PCNFS)
	errno = 0;
#endif
#if defined(IBMTCP)
	tcperrno = 0;
#endif

	work_ptr->servent_out_ptr =
		getservbyname(work_ptr->name,work_ptr->proto);


 /*********************************************************************/
 /* Copy errno value to commarea.  Then, if the socket call returned  */
 /* NULL, zero out the other output areas in the commarea.            */
 /*********************************************************************/

#if defined(PCTCP) || defined(PCNFS)
	work_ptr->errno = errno;
#endif
#if defined(IBMTCP)
	work_ptr->errno = tcperrno;
#endif

	if (work_ptr->servent_out_ptr == NULL)
		memset(&work_ptr->servent_out,0,sizeof (struct servent));


 /*********************************************************************/
 /* Otherwise copy results to commarea.                               */
 /*********************************************************************/

	else {
		work_ptr->servent_out = *(work_ptr->servent_out_ptr);


 /*********************************************************************/
 /* Copy servent 'name' to commarea and convert its pointer to a      */
 /* relative offset.                                                  */
 /*********************************************************************/

		p = &work_ptr->variable;
		name_len = strlen(work_ptr->servent_out.s_name);
		strcpy(p,work_ptr->servent_out.s_name);
		work_ptr->servent_out.s_name = far2rel(p);


 /*********************************************************************/
 /* Copy servent 'proto' to commarea and convert its pointer to a     */
 /* relative offset.                                                  */
 /*********************************************************************/

		p += name_len + 1;
		proto_len = strlen(work_ptr->servent_out.s_proto);
		strcpy(p,work_ptr->servent_out.s_proto);
		work_ptr->servent_out.s_proto = far2rel(p);


 /*********************************************************************/
 /* Since we don't return aliases, set the alias pointer to NULL.     */
 /*********************************************************************/

		p += proto_len + 1;     /* set this, we may use it someday */
		work_ptr->servent_out.s_aliases = NULL;
	}

}       /* end of "process_getservbyname" */

#if defined(DEBUG) 

print_addr(listptr)
char	**listptr;
{
	struct in_addr *ptr;

	while((ptr = (struct in_addr *) *listptr++) != NULL)
	{
		printf("Internet address: %s\n", inet_ntoa(*ptr));
	}
}

#endif

void process_gethostbyname(struct gethostbyname_parms *work_ptr)

 /*********************************************************************/
 /* "process_gethostbyname"                                           */
 /*********************************************************************/
{
	char    *p;
	int             name_len;


 /*********************************************************************/
 /* Convert relative addresses in commarea to _far pointers.          */
 /*********************************************************************/

	work_ptr->name = rel2far(work_ptr->name);


 /*********************************************************************/
 /* Clear errno, then issue the socket call.                          */
 /*********************************************************************/

#if defined(PCTCP) || defined(PCNFS)
	errno = 0;
#endif
#if defined(IBMTCP)
	tcperrno = 0;
#endif
	h_errno = 0;

	work_ptr->hostent_out_ptr =
		gethostbyname(work_ptr->name);

#if defined(DEBUG) 
	printf("host name <%s> : \n",work_ptr->name);
	print_addr(work_ptr->hostent_out_ptr->h_addr_list);
        if (work_ptr->hostent_out_ptr == NULL)
           printf("gethostbyname returned a NULL\n");
	printf("gethostbyname h_errno <%d> : \n",h_errno);
#endif


 /*********************************************************************/
 /* Copy errno value to commarea.  Then, if the socket call returned  */
 /* NULL, zero out the other output areas in the commarea.            */
 /*********************************************************************/

#if defined(PCTCP) || defined(PCNFS)
	work_ptr->errno = errno;
#endif
#if defined(IBMTCP)
	work_ptr->errno = tcperrno;
#endif
	work_ptr->h_errno = h_errno;

	if (work_ptr->hostent_out_ptr == NULL)
	{
		memset(&work_ptr->hostent_out,0,sizeof (struct hostent));
	}


 /*********************************************************************/
 /* Otherwise copy results to commarea.                               */
 /*********************************************************************/

	else {
		work_ptr->hostent_out = *(work_ptr->hostent_out_ptr);


 /*********************************************************************/
 /* Copy hostent 'name' to commarea and convert its pointer to a      */
 /* relative offset.                                                  */
 /*********************************************************************/

		p = &work_ptr->variable;
		name_len = strlen(work_ptr->hostent_out.h_name);
		strcpy(p,work_ptr->hostent_out.h_name);
		work_ptr->hostent_out.h_name = far2rel(p);


 /*********************************************************************/
 /* Since we don't return aliases, set the alias pointer to NULL.     */
 /*********************************************************************/

		p += name_len + 1;      /* set this, we may use it someday */
		work_ptr->hostent_out.h_aliases = NULL;


 /*********************************************************************/
 /* Since we only return the first IP address, we'll cheat and stick  */
 /* the address in the address pointer list.                          */
 /*********************************************************************/

		_fmemcpy(&(work_ptr->hostent_out.h_addr_list),
			*(work_ptr->hostent_out.h_addr_list),
			sizeof (long));
	}

}       /* end of "process_gethostbyname" */


void process_socket(struct socket_parms *work_ptr)

 /*********************************************************************/
 /* "process_socket"                                                  */
 /*********************************************************************/
{
struct linger ling;


 /*********************************************************************/
 /* Clear errno, then issue the socket call.                          */
 /*********************************************************************/

#if defined(PCTCP) || defined(PCNFS)
	errno = 0;
#endif
#if defined(IBMTCP)
	tcperrno = 0;
#endif

 /*********************************************************************/
 /* Close the previous socket descriptor.                             */
 /*********************************************************************/
	if (prev_sockdes > 0)
	{

		ling.l_onoff = 1;
		ling.l_linger = 0;

		setsockopt(prev_sockdes, SOL_SOCKET, SO_LINGER, (char *)&ling, sizeof(struct linger));

#if defined(PCTCP) || defined(PCNFS)
		close(prev_sockdes);
#endif
#if defined(IBMTCP)
		soclose(prev_sockdes);
#endif

	}

#if defined(PCTCP) || defined(PCNFS)
	errno = 0;
#endif
#if defined(IBMTCP)
	tcperrno = 0;
#endif

	work_ptr->socket_out =
		socket(work_ptr->af,work_ptr->type,work_ptr->protocol);

	prev_sockdes = work_ptr->socket_out;

#if defined(IBMTCP)
	if (tcperrno)
	{
		printf("socket() tcperrno <%d> \n", tcperrno);
	}
#endif

 /*********************************************************************/
 /* Copy errno value to commarea, then return.                        */
 /*********************************************************************/

#if defined(PCTCP) || defined(PCNFS)
	work_ptr->errno = errno;
#endif
#if defined(IBMTCP)
	work_ptr->errno = tcperrno;
#endif

}       /* end of "process_socket" */


void process_connect(struct connect_parms *work_ptr)

 /*********************************************************************/
 /* "process_connect"                                                 */
 /*********************************************************************/
{


#if defined (IBMTCP)
   	struct sockaddr_in temp_ibm;
	struct fake_sockaddr_in  *hold_sockaddr_in;
#endif

 /*********************************************************************/
 /* Clear errno, then issue the connect call.                         */
 /*********************************************************************/

#if defined(PCTCP) || defined(PCNFS)
	errno = 0;
#endif
#if defined(IBMTCP)
	tcperrno = 0;
#endif

#if defined(DEBUG) 
	printf("In process_connect\n");
#endif

#if defined(IBMTCP)
        hold_sockaddr_in = (struct fake_sockaddr_in *) &(work_ptr->name);

        memset(&temp_ibm, 0, sizeof(temp_ibm));
        temp_ibm.sin_len = sizeof(struct sockaddr_in); 
 	temp_ibm.sin_family = (u_char) hold_sockaddr_in->sin_family; 
        temp_ibm.sin_port = hold_sockaddr_in->sin_port; 
    	temp_ibm.sin_addr = (struct in_addr) hold_sockaddr_in->sin_addr; 

	work_ptr->connect_rc =
		connect(work_ptr->socket, (struct sockaddr *) &(temp_ibm), sizeof(struct sockaddr_in));
#endif
#if defined(PCTCP) || defined(PCNFS) 
	work_ptr->connect_rc =
		connect(work_ptr->socket,&(work_ptr->name),work_ptr->namelen);
#endif

 /*********************************************************************/
 /* Copy errno value to commarea, then return.                        */
 /*********************************************************************/

#if defined(PCTCP) || defined(PCNFS)
	work_ptr->errno = errno;
#endif
#if defined(IBMTCP)
	work_ptr->errno = tcperrno;
#endif

}       /* end of "process_connect" */


void process_read(struct read_parms *work_ptr)

 /*********************************************************************/
 /* "process_read"                                                    */
 /*********************************************************************/
{

#if defined(IBMTCP)
	struct iovec  temp_ibm;
#endif

 /*********************************************************************/
 /* Clear errno, then issue the socket call.                          */
 /*********************************************************************/

#if defined(PCTCP) || defined(PCNFS)
	errno = 0;
#endif
#if defined(IBMTCP)
	tcperrno = 0;
#endif

#if defined(IBMTCP)
	work_ptr->read_rc =
  		recv(work_ptr->socket, &work_ptr->variable, work_ptr->nbytes, 0);
#endif

	NET_DBG(("TSR recv returned %d\n",work_ptr->read_rc));

#if defined(PCTCP) || defined(PCNFS)
	work_ptr->read_rc =                                     /* don't overrun buffer! */
		read(work_ptr->socket,&(work_ptr->variable),work_ptr->nbytes);
#endif

 /*********************************************************************/
 /* Copy errno value to commarea, then return.                        */
 /*********************************************************************/

#if defined(PCTCP) || defined(PCNFS)
	work_ptr->errno = errno;
#endif
#if defined(IBMTCP)
	work_ptr->errno = tcperrno;
#endif

}       /* end of "process_read" */


void process_write(struct write_parms *work_ptr)

 /*********************************************************************/
 /* "process_write"                                                   */
 /*********************************************************************/
{
	/*
		This is to take care of the IBM TCP/IP writev().
	*/
#if defined(IBMTCP)
	struct iovec  	temp_ibm;
	int             iovcnt;
#endif


 /*********************************************************************/
 /* Clear errno, then issue the socket call.                          
 /*********************************************************************/

#if defined(PCTCP) || defined(PCNFS)
	errno = 0;
#endif
#if defined(IBMTCP)
	tcperrno = 0;
#endif

#if defined(IBMTCP)
      	work_ptr->write_rc = 
  		send(work_ptr->socket, &work_ptr->variable, work_ptr->nbytes, 0);

	if (tcperrno)
	{
		printf("send() tcperrno <%d> \n", tcperrno);
	}
#endif


#if defined(PCTCP) || defined(PCNFS)
	work_ptr->write_rc =                            /* don't overrun buffer! */
		write(work_ptr->socket,&(work_ptr->variable),work_ptr->nbytes);
#endif

 /*********************************************************************/
 /* Copy errno value to commarea, then return.                        */
 /*********************************************************************/

#if defined(PCTCP) || defined(PCNFS)
	work_ptr->errno = errno;
#endif
#if defined(IBMTCP)
	work_ptr->errno = tcperrno;
#endif

#if defined(DEBUG) 
   printf("write returned %d with errno = %d\n",work_ptr->write_rc,tcperrno);
#endif
}       /* end of "process_write" */


void process_getdomainname(struct getdomainname_parms *work_ptr)

 /*********************************************************************/
 /* "process_getdomainname"                                           */
 /*********************************************************************/
{
	char buf[80];


 /*********************************************************************/
 /* Clear errno, then issue the socket call.                          */
 /*********************************************************************/

#if defined(PCTCP) || defined(PCNFS)
	errno = 0;
#endif
#if defined(IBMTCP)
	tcperrno = 0;
#endif

#if defined(PCTCP) || defined(PCNFS)
	work_ptr->getdomainname_rc =
		getdomainname(&(work_ptr->variable),work_ptr->namelen);
#endif

#if defined(IBMTCP)
	work_ptr->getdomainname_rc =
		res_mkquery(QUERY, &(work_ptr->variable), C_IN, T_PTR, NULL, 0, NULL, buf, 80);
#endif


 /*********************************************************************/
 /* Copy errno value to commarea, then return.                        */
 /*********************************************************************/

#if defined(PCTCP) || defined(PCNFS)
	work_ptr->errno = errno;
#endif
#if defined(IBMTCP)
	work_ptr->errno = tcperrno;
#endif

}       /* end of "process_getdomainname" */


void process_gethostname(struct gethostname_parms *work_ptr)

 /*********************************************************************/
 /* "process_gethostname"                                             */
 /*********************************************************************/
{


 /*********************************************************************/
 /* Clear errno, then issue the socket call.                          */
 /*********************************************************************/

#if defined(PCTCP) || defined(PCNFS)
	errno = 0;
#endif
#if defined(IBMTCP)
	tcperrno = 0;
#endif

	work_ptr->gethostname_rc =
		gethostname(&(work_ptr->variable),work_ptr->namelen);


 /*********************************************************************/
 /* Copy errno value to commarea, then return.                        */
 /*********************************************************************/

#if defined(PCTCP) || defined(PCNFS)
	work_ptr->errno = errno;
#endif
#if defined(IBMTCP)
	work_ptr->errno = tcperrno;
#endif

}       /* end of "process_gethostname" */


void process_close(struct close_parms *work_ptr)

 /*********************************************************************/
 /* "process_close"                                                   */
 /*********************************************************************/
{


 /*********************************************************************/
 /* Clear errno, then issue the socket call.                          */
 /*********************************************************************/

#if defined(PCTCP) || defined(PCNFS)
	errno = 0;
#endif
#if defined(IBMTCP)
	tcperrno = 0;
#endif

#if defined(PCTCP) || defined(PCNFS)
	work_ptr->close_rc =
		close(work_ptr->socket);
#endif

#if defined(IBMTCP)
	work_ptr->close_rc =
		soclose(work_ptr->socket);
#endif
/*********************************************************************/
 /* Copy errno value to commarea, then return.                        */
 /*********************************************************************/

#if defined(PCTCP) || defined(PCNFS)
	work_ptr->errno = errno;
#endif
#if defined(IBMTCP)
	work_ptr->errno = tcperrno;
#endif

}       /* end of "process_close" */


#if defined(DEBUG) 
void print_fds(
	char *name,
	struct fd_set *fds)
{
	long i;

	if (fds)
	{
		for (i = 0; i < FD_SETSIZE; i++)
		{
			if (FD_ISSET(i, fds))
			{
				printf("----%s file descriptor #%d is set\n", name, i);
			}
		}
	}
}
#endif
/************************************************************************/
#if defined(IBMTCP)
/************************************************************************/
/* micro sleep                                                          */
/************************************************************************/
void micro_sleep(clock_t wait)

{
clock_t goal;

	goal = wait + clock();
	while (goal > clock())
	;

}               /* end of sleep */
#endif
/************************************************************************/

void process_select(struct select_parms *work_ptr)

 /*********************************************************************/
 /* "process_select"                                                  */
 /*********************************************************************/
{

/**********************************************************************/
/* TCP/IP for IBM and PCNFS both have FD_SETSIZE = 256                */
/**********************************************************************/

#if defined(PCNFS) || defined(IBMTCP)
struct fd_set RIS_readfds, RIS_writefds, RIS_exceptfds;

	FD_ZERO(&RIS_readfds);
	FD_ZERO(&RIS_writefds);
	FD_ZERO(&RIS_exceptfds);
#endif

 /*********************************************************************/
 /* Convert relative addresses in commarea to _far pointers.          */
 /*********************************************************************/

	if (work_ptr->readfds_ptr)
	{
#if defined (PCTCP)
		work_ptr->readfds_ptr = 
			(struct fd_set PTR_DIST *)rel2far(work_ptr->readfds_ptr);
#endif
#if defined (PCNFS) || defined(IBMTCP)
		work_ptr->readfds_ptr = 
			(struct ris_fd_set PTR_DIST *)rel2far(work_ptr->readfds_ptr);
		RIS_FIX_FD_SET_PROT_TO_REAL(work_ptr->readfds_ptr, RIS_readfds);
#endif
	}

	if (work_ptr->writefds_ptr)
	{
#if defined (PCTCP)
		work_ptr->writefds_ptr = 
			(struct fd_set PTR_DIST *)rel2far(work_ptr->writefds_ptr);
#endif
#if defined (PCNFS) || defined(IBMTCP)
		work_ptr->writefds_ptr = 
			(struct ris_fd_set PTR_DIST *)rel2far(work_ptr->writefds_ptr);
		RIS_FIX_FD_SET_PROT_TO_REAL(work_ptr->writefds_ptr, RIS_writefds);
#endif
	}

	if (work_ptr->exceptfds_ptr)
	{
#if defined (PCTCP)
		work_ptr->exceptfds_ptr = 
			(struct fd_set PTR_DIST *)rel2far(work_ptr->exceptfds_ptr);
#endif
#if defined (PCNFS) || defined(IBMTCP)
		work_ptr->exceptfds_ptr = 
			(struct ris_fd_set PTR_DIST *)rel2far(work_ptr->exceptfds_ptr);
		RIS_FIX_FD_SET_PROT_TO_REAL(work_ptr->exceptfds_ptr, RIS_exceptfds);
#endif
	}

	if (work_ptr->timeout_ptr)
	{
		work_ptr->timeout_ptr = 
			(struct timeval PTR_DIST *)rel2far(work_ptr->timeout_ptr);
	}

 /*********************************************************************/
 /* Clear errno, then issue the socket call.                          */
 /*********************************************************************/

#if defined(PCTCP) || defined(PCNFS)
	errno = 0;
#endif
#if defined(IBMTCP)
	tcperrno = 0;
#endif

#if defined(PCTCP)

	work_ptr->select_rc =
		select(work_ptr->nfds,
			work_ptr->readfds_ptr,
			work_ptr->writefds_ptr,
			work_ptr->exceptfds_ptr,
			work_ptr->timeout_ptr);

#endif

#if defined(PCNFS) || defined(IBMTCP)	/* for PCNFS and IBMTCP only */
#if defined(DEBUG) 
	print_fds("read", &RIS_readfds);
	print_fds("write", &RIS_writefds);
	print_fds("except", &RIS_exceptfds);
#endif
/*
	KLUDGE - NEEDS TO BE FIXED.
	IF WE DON'T USE MICRO SLEEP THE SELECT() HANGS
*/
#if defined (IBMTCP)
  micro_sleep((clock_t) 1); 
#endif 

if (work_ptr->timeout_ptr != NULL)
{
	printf("BEFORE SELECT timeout is %d\n",work_ptr->timeout_ptr->tv_sec);
}

	work_ptr->select_rc =
		select(FD_SETSIZE,
			&RIS_readfds,
			&RIS_writefds,
			&RIS_exceptfds,
			work_ptr->timeout_ptr);

	RIS_FIX_FD_SET_REAL_TO_PROT(RIS_readfds, work_ptr->readfds_ptr);
	RIS_FIX_FD_SET_REAL_TO_PROT(RIS_writefds, work_ptr->writefds_ptr);
	RIS_FIX_FD_SET_REAL_TO_PROT(RIS_exceptfds, work_ptr->exceptfds_ptr);

	NET_DBG(("process_select : sts %d\n",work_ptr->select_rc));
#endif


 /*********************************************************************/
 /* Copy errno value to commarea, then return.                        */
 /*********************************************************************/

#if defined(PCTCP) || defined(PCNFS)
	work_ptr->errno = errno;
#endif
#if defined(IBMTCP)
	work_ptr->errno = tcperrno;
	if (tcperrno)
	{
		printf("select() tcperrno <%d> : \n", tcperrno);
	}
#endif

}       /* end of "process_select" */


void process_fcntl(struct fcntl_parms *work_ptr)

 /*********************************************************************/
 /* "process_fcntl"                                                   */
 /*********************************************************************/
{


 /*********************************************************************/
 /* Clear errno, then issue the socket call.                          */
 /*********************************************************************/

#if defined(PCTCP) || defined(PCNFS)
	errno = 0;
#endif
#if defined(IBMTCP)
	tcperrno = 0;
#endif

#if defined(PCTCP)
	work_ptr->fcntl_rc =
		fcntl(work_ptr->fd, work_ptr->cmd, work_ptr->arg);
#endif
#if defined(PCNFS)
	work_ptr->fcntl_rc =
		tk_ioctl(work_ptr->fd, work_ptr->cmd, &(work_ptr->arg));
#endif
#if defined(IBMTCP)
        work_ptr->cmd = FIONBIO;
        work_ptr->arg = 1;
	work_ptr->fcntl_rc = 0;
/*
**	THIS NEEDS TO BE FIXED - IBM'S PROBLEM
**	ERROR EXISTS ONLY UNDER OS/2, RETURNS ERRNO 22
*/

/* This is IBM's problem and will soon get the update - May 12, 1994  */
/* KLUDGE -  OS/2 returns an error for the ioctl call */
/*           act like it did not happen               */
/*
	work_ptr->fcntl_rc =
		ioctl(work_ptr->fd, (u_long)work_ptr->cmd,(caddr_t)&(work_ptr->arg));
*/

	work_ptr->fcntl_rc = 0;

#endif

#if defined(DEBUG) 
     printf("socket desc is %d\n",work_ptr->fd);
     printf("command is %d\n",work_ptr->cmd); 
     printf("Value returned by ioctl() is %d\n",work_ptr->fcntl_rc);
     printf("tcperrno after ioctl is %d\n",tcperrno);
#endif
 /*********************************************************************/
 /* Copy errno value to commarea, then return.                        */
 /*********************************************************************/

#if defined(PCTCP) || defined(PCNFS)
	work_ptr->errno = errno;
#endif
#if defined(IBMTCP)
	work_ptr->errno = 0;
/*
	work_ptr->errno = tcperrno;
*/
#endif

}       /* end of "process_fcntl" */


void process_sleep(struct sleep_parms *work_ptr)

 /*********************************************************************/
 /* "process_sleep"                                                           */
 /*********************************************************************/

{
#if defined(PCNFS) || defined(IBMTCP)
clock_t start;
clock_t duration;
#endif


 /*********************************************************************/
 /* Clear errno, then issue the            */
 /*********************************************************************/
 
#if defined(PCTCP) || defined(PCNFS)
	errno = 0;
#endif
#if defined(IBMTCP)
	tcperrno = 0;
#endif

#if defined(PCTCP)
	work_ptr->sleep_rc =
		sleep(work_ptr->seconds);
#endif

 /*********************************************************************/
 /* PCNFS does not provide with the sleep function.                   */
 /*********************************************************************/

#if defined(PCNFS) || defined(IBMTCP)
	start = clock()/CLOCKS_PER_SEC;
	duration = work_ptr->seconds;

	do      {
		} while (((clock()/CLOCKS_PER_SEC) - start) <= duration);

	work_ptr->sleep_rc = 0; /* since sleep always returns 0 -- SK */
#endif

 /*********************************************************************/
 /* Copy errno value to commarea, then return.                        */
 /*********************************************************************/

#if defined(PCTCP) || defined(PCNFS)
	work_ptr->errno = errno;
#endif
#if defined(IBMTCP)
	work_ptr->errno = tcperrno;
#endif

}               /* end of "process_sleep" */
