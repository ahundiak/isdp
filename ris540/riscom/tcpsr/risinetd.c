/* Do not alter this SPC information: $Revision: 1.3.3.1 $ */
/*
**	NAME:							risinetd.c
**	AUTHORS:						Grace Oliver
**	CREATION DATE:					12/92
**	ABSTRACT:		This is an RIS tcp/ip network daemon front end to
**					the RIS tcpsr program and it is being written
**					to act as an inet daemon on NT systems.  
**
**					The function of this program on an Intergraph system
**					is provided by inetd, which is not currently provided
**					by Microsoft for NT.  
**
**					Syntax:  ristcpsr
**
**					Algorithm:  
**
**						Make sure we are root (necessary on NT?)
**						Verify that RIS_HOME_DIRECTORY\bin\ristcpsr.exe
**							exists. and is owned by root (necessary on NT?)
**						Detach from terminal  (necessary on NT? )
**							a parameter to CreateProcess system call ?
**						Get a socket
**						Bind socket
**						Listen on port #180;
**						Loop:
**								Accept connection request
**								CreateProcess to execv ristcpsr.exe program
**								Close the accepted socket
**
**					The program must be owned/started by root in order
**					to listen on port 180.  General-purpose user ports
**					appear to start at 2000, and anything lower than that
**					requires root access. (necessary on NT?) not under FAT
**					file systems
**
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <stdio.h>
#include <stdlib.h>
#include <winsock.h>
#include <string.h>
#include "risprods.h"
#include "risdebug.h"
#include "riscom.h"

/*
**	DEFINES
*/
#define	DEBUG	1

#define	PORT	((u_short)180)	/* RIS PORT # */
#define MAX_PATH_SIZE	66
#define BUFFER_SIZE		8

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define risinetd_c
#include "risinetd.prt"
#include "tcpsr.prt"
#include "comdebug.prt"

/*  use if multi-threading has problems; but won't be as efficient
** extern void tcpsr(LPVOID string);
*/

/*
**	VARIABLES
*/
SOCKET	sd;

/*
**	RIScom_process_debug_file() references these variables.  It's easier
**	to define them here, instead of including arch.h and net.h.
*/
int	ARC_debug = 0;
int	NET_debug = 0;

/*
**	FUNCTIONS
*/

/****************************************************************************/

extern void main_thread()
{
	int					ret, addrsz = sizeof(struct sockaddr);
	struct sockaddr		addr;
	int					optval;
	SECURITY_ATTRIBUTES	sa;
	int					status;
	DWORD				IdThread;
	WORD				wVerReq = MAKEWORD( 1, 1);
	WSADATA				wsadata;
	SOCKET 				asd;
	DWORD           	excepttype=0;
	PEXCEPTION_POINTERS exceptinfo=0;
	PVOID           	exceptaddr=0;
	HANDLE				hthrd=0;
	int			winsockerr;

 __try {
  __try {

    /*
	** get debug environment setup
	*/
	SET_TCPSERVER;
    RIScom_initialize_debug();

	/*
	** start winsockets
	*/
	if ( status = WSAStartup(wVerReq, &wsadata)) {
		TCPSRV_DBG(("risinetd: WSAStartup failed; status %d\n", status));
		TCPSRV_DBG((" Ver %d.%d HighVer %d.%d \n",
				  LOBYTE(wsadata.wVersion), HIBYTE(wsadata.wVersion),
				  LOBYTE(wsadata.wHighVersion),HIBYTE(wsadata.wHighVersion)));
		TCPSRV_DBG((" szDescription %s szSystemStatus %s\n",
					wsadata.szDescription, wsadata.szSystemStatus));
		TCPSRV_DBG((" iMaxSockets %d iMaxUdpDg %d\n",
					wsadata.iMaxSockets, wsadata.iMaxUdpDg));
		return;
	}
	TCPSRV_DBG(("risinetd: \n"));
	TCPSRV_DBG((" Ver %d.%d HighVer %d.%d \n",
				LOBYTE(wsadata.wVersion), HIBYTE(wsadata.wVersion),
				LOBYTE(wsadata.wHighVersion),HIBYTE(wsadata.wHighVersion)));
	TCPSRV_DBG((" szDescription %s szSystemStatus %s\n",
				wsadata.szDescription, wsadata.szSystemStatus));
	TCPSRV_DBG((" iMaxSockets %d iMaxUdpDg %d\n",
				wsadata.iMaxSockets, wsadata.iMaxUdpDg));

	/*
    ** Get a socket
	*/	
	sd = socket(PF_INET, SOCK_STREAM, 0);
	if ( sd == INVALID_SOCKET ) {
		TCPSRV_DBG(("risinetd: socket call failed: error %d\n", 
					WSAGetLastError()));
		return;
	}
	TCPSRV_DBG(("risinetd: Opened socket descriptor %d\n", sd));

	/*
    ** Set socket option SO_REUSEADDR to true; false by default
	*/
	optval = 1;		/* nonzero is true */
	ret = setsockopt(sd, SOL_SOCKET, SO_REUSEADDR, (char *)&optval,
					 sizeof(int));
	if ( ret == SOCKET_ERROR ) {
		TCPSRV_DBG(("risinetd: setsockopt call failed: error %d\n", 
					WSAGetLastError()));
		return;
	}
	/*
	** Set socket option TCP_NODELAY to true; disable Nagle algorithm 
	*/
	optval = 1;		/* nonzero is true */
	ret = setsockopt(sd, IPPROTO_TCP, TCP_NODELAY, (char *)&optval,
					 sizeof(int));
	if ( ret == SOCKET_ERROR ) {
		/* 1996.03.11:similar to TR439600333:Alan Barksdale */
		winsockerr = WSAGetLastError();
		if(WSAENOPROTOOPT == winsockerr)  {
			TCPSRV_DBG(("%s,%d:main_thread:setsockopt TCP_NODELAY error WSAENOPROTOOPT: %d; just noting error because option not available on some WinSock implementations\n",
				__FILE__, __LINE__, winsockerr));
		} else {
			TCPSRV_DBG(("%s,%d:main_thread:setsockopt call failed: error %d\n",
				__FILE__, __LINE__, winsockerr));
			return;
		}
	}
	/*
    ** Bind to port
	*/
	addr.sa_family = AF_INET;
	memset (addr.sa_data, 0, sizeof(addr.sa_data));
	*(u_short *)(&addr.sa_data[0]) = htons(PORT);
	ret = bind(sd, &addr, addrsz);
	if ( ret == SOCKET_ERROR ) {
		TCPSRV_DBG(("risinetd: bind call failed: error %d\n", 
					WSAGetLastError()));
		return;
	}
	TCPSRV_DBG(("risinetd: bind on sd %d\n", sd));
	/*
    ** Listen on port 180
	*/
	ret = listen(sd, 5);
	if ( ret == SOCKET_ERROR ) {
		TCPSRV_DBG(("risinetd: listen call failed: error %d\n", 
					WSAGetLastError()));
		return;
	}
	TCPSRV_DBG(("risinetd: listen on sd %d\n", sd));

	for (;;) {
		/*
    	** Accept connection
		*/
		asd = accept(sd, &addr, &addrsz);
		if ( asd == SOCKET_ERROR ) {
			TCPSRV_DBG(("risinetd: accept call failed: error %d\n", 
						WSAGetLastError()));
			return;
		}
		TCPSRV_DBG(("risinetd: accepted connection on asd: %d addr len: %d\n", 
					asd, addrsz));

		/*
		**	 Create Thread to do tcpsr
		*/

		TCPSRV_DBG(("risinetd: starting tcpsr thread\n"));

		sa.nLength = sizeof(SECURITY_ATTRIBUTES);
		sa.lpSecurityDescriptor = NULL;
		sa.bInheritHandle = TRUE;
		if ( ! ( hthrd = CreateThread(&sa, 0, (LPTHREAD_START_ROUTINE)tcpsr,
						  (LPVOID)asd, 0, &IdThread) ) )
		{
			ret = GetLastError();
			TCPSRV_DBG(("risinetd: CreateThread failed: %d error\n", ret ));
			return;
		}
		CloseHandle(hthrd);
		TCPSRV_DBG(("risinetd: Created thread successed: %d\n", IdThread));
	}
	return;
  }
  __except (excepttype = GetExceptionCode(),
		exceptinfo = GetExceptionInformation(),
		exceptaddr = exceptinfo->ExceptionRecord->ExceptionAddress,
		EXCEPTION_EXECUTE_HANDLER ) {
	TCPSRV_DBG(("risinetd: EXCEPTION %d caught: Cleaning up\n", excepttype));
	TCPSRV_DBG(("risinetd: exceptaddr 0x%x: \n", exceptaddr));
	closesocket( sd );
	WSACleanup();
  }
 }
 __finally 
 {
	ret = closesocket ( sd );
	if ( ret == SOCKET_ERROR ) {
		TCPSRV_DBG(("risinetd: closesocket sd failed: error %d\n", 
					WSAGetLastError()));
	}
	TCPSRV_DBG(("risinetd: Closed socket descriptor %d\n", sd));

	if (WSAIsBlocking()) 
	{
		TCPSRV_DBG(("risinetd: WSAIsBlocking is true in finally block\n"));
		if (WSACancelBlockingCall()) 
		{
			TCPSRV_DBG(("risinetd: WSAIsBlocking error %d\n", 
						WSAGetLastError()));
		}
	}
	if ( WSACleanup() ) {
		TCPSRV_DBG(("risinetd: WSACleanup error %d\n", WSAGetLastError()));
	}
	TCPSRV_DBG(("risinetd: WSACleanup succeeded\n"));
 }
}
