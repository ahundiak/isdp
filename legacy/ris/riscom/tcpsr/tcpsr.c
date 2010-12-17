/* Do not alter this SPC information: $Revision: 1.12.9.1 $ */
/*
**	NAME:							tcpsr.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					6/89
**	ABSTRACT:
**		A small server program used to kick of the correct RIS server.  It 
**		reads 1 byte from the network to determin which server to start.
**
**	REVISION HISTORY:
**		8/91 - Terry McIntyre
**			The can now also be used to kick off the risclient process.
**	    5/93 - Grace Oliver
**			Merge in Dan Karier's modes for SMP INTEL x86 SCO box.
**			Remove SETJMP/LONGJMP code.
**		2/95 - Radha Shivakumar
**			A new dtype (Z) is added to the ristcpsr to locate the remote
**			client on NT. It is only on WIN32.
*/
#include "riscom.h"

#define COM_GLOBAL_DEFINE

/*
**	INCLUDES
*/
#include <stdio.h>
#include <errno.h>
#if defined(WIN32)
# include <winsock.h>
#endif

#include "ris_err.h"
#include "rislimit.h"
#include "risprods.h"
#include "rispath.h"
#include "risdebug.h"
#include "ris.h"
#if defined(__Sol2__)
# include <widec.h>
#endif

/*
**	DEFINES
*/
#define BUFFER_SIZE		8

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define tcpsr_c
#if defined(unix)
# include "net_sys.prt"
# include "net_wrap.prt"
#endif
#include "comdebug.prt"
#include "comgtdir.prt"
#include "compath.prt"
#include "wrap.prt"
#include "tcpsr.prt"

/*
**	VARIABLES
*/
#if defined(WIN32)
extern SOCKET sd;
#endif
/*
**	RIScom_process_debug_file() references these varibles.  It's easier
**	to define them here, instead of including arch.h and net.h.
*/
#if defined(__clipper__) || defined(sun) || defined(sco) || defined(__Sol2__)  || defined(__hpux__) || defined(Soli)
int	ARC_debug = 0;
int	NET_debug = 0;
#endif

/*
**	FUNCTIONS
*/

#if defined(WIN32)
extern void tcpsr(
	LPVOID arg)
#endif
#if defined(__clipper__) || defined(sun) || defined(sco) || defined(__Sol2__)  || defined(__hpux__) || defined(Soli)
extern int main(
	int argc,
	char *argv[])
#endif
{
#if defined(__clipper__) || defined(sun) || defined(sco) || defined(__Sol2__)  || defined(__hpux__) || defined(Soli)
	int			i;
#endif
	int			status = 0;
	int			development;
	int			maj, min, rel;
	int			match_flag = MATCH_COMPATIBLE;
	char			dtype;
	char			buffer[BUFFER_SIZE];
	char			path[RIS_MAX_PATH_SIZE];
	char			risdir[RIS_MAX_PATH_SIZE];
	char			*config_file;
#if defined(WIN32)
	SOCKET			sochdl;		/* socket descriptor handle */
	STARTUPINFO		si;
	PROCESS_INFORMATION	pi;
	SECURITY_ATTRIBUTES	sa;
	char			sd_str[10];
	char			cmdln[MAX_PATH];
	/* added by goverdhan     6/9 */
	char			tmp_path[RIS_MAX_PATH_SIZE];
	char 			cli_loc_path[RIS_MAX_PATH_SIZE] = "";
	int len;
#endif /* WIN32 */


#if defined(__clipper__) || defined(sun) || defined(sco) || defined(__Sol2__)  || defined(__hpux__) || defined(Soli)
	SET_TCPSERVER;
	RIScom_initialize_debug();

	if (RIStcpsrv_debug)
	{
		for (i = 0; i < argc; i++)
		{
			RIScom_output_debug("ristcpsrv: argv[%d]:<%s>\n", i, argv[i]);
		}
	}
#endif
#if defined(WIN32)
	sochdl = (int)arg;
	TCPSRV_DBG(("ristcpsrv: sochdl:<%d>\n", sochdl));
#endif

	/*
	**	This first read should be exactly 8 bytes
	*/

#if defined(unix)
        {    /********** RIS License Server enforcement **********          arw 10-1-94 
              **  Look at the socket and see who has connected  **
              **  to us. Write these to shared memory using key **
              **  19793578. If and when the ris data            **
              **  server is started it will reference this same **
              **  memory area to pull the peer socket address   **
              **  This is necessary because this may start a    **
              **  client which would talk to the server through **
              **  shared memory.                                **
              ***************************************************/
             
             struct sockaddr_in from, current_loc;
             struct hostent *hp;
             char   node[80];
             int fromlen,segid;
             char location[80],*addr;
             int sh_mem_key;

             gethostname(node,sizeof node);
             
             if ((hp = gethostbyname(node)))
                  memcpy(&current_loc.sin_addr,hp->h_addr,hp->h_length);
               
               
             fromlen=sizeof(from);
             status = getpeername(0,(struct sockaddr *) &from,&fromlen);

             if (status == 0)
             {             
             if (current_loc.sin_addr.s_addr == from.sin_addr.s_addr)               /* Talking to someone local       */
              {
                TCPSRV_DBG(("ristcpsrv: Local instanation .. nothing done\n"));      /* no need for further processing */
              }
             else
                {
                     sprintf(location,"ristcpsrv: Socket Peer Name is [%s]",
                                      inet_ntoa(from.sin_addr));

                     TCPSRV_DBG(("%s\n",location));

                     sh_mem_key = 19793578;

                     if ((segid=shmget(sh_mem_key,30,0666|IPC_CREAT)) == -1)
                                       TCPSRV_DBG(("ristcpsrv: Shared memory get failed....\n"));
                  
                     if ((addr=shmat(segid,0,0)) == (char *)(-1))
                       {
                               TCPSRV_DBG(("ristcpsrv: Shared memory attach failed....\n"));
                       }
                     else
                       {
                               if (strlen(addr))	    /* Server clears this when he is finished */
                                 {			    /* So someone else has it. Wait 3 secs    */
                                    for (i=0; i < 3; i++)
                                      {
                                          TCPSRV_DBG(("ristcpsrv: Concurrency conflict, wait 1 ....\n"));
                                          sleep(1);

                                          if (strlen(addr) == 0)
                                               break;
                                       }
                                  }
 
                                    strcpy(addr,inet_ntoa(from.sin_addr));
                                    shmdt(addr);
                       }
                }             
             }
        }

	status = recv(0, buffer, BUFFER_SIZE, 0);
#endif

#if defined(WIN32)
        {
             /* Need persistent memory object for the case of riscli talking to     *
              * application via tcp/ip and the RIS dataserver through shared memory */

             HANDLE  hShared_memory = NULL , hFilename = NULL;
             LPBYTE  ptr = NULL;
             struct  sockaddr_in from, current_loc;
             struct  hostent *hp;
             char    node[80];
             
             INT      fromlen,i;
             TCHAR    location[256];
                     

             gethostname(node,sizeof node);
             
             if ((hp = gethostbyname(node)))
                  memcpy(&current_loc.sin_addr,hp->h_addr,hp->h_length);
             
                     
             fromlen=sizeof(from);
             status = getpeername((SOCKET)sochdl,(struct sockaddr *) &from,&fromlen);

             if (status == 0)
             {
                if (current_loc.sin_addr.s_addr == from.sin_addr.s_addr)               /* Talking to someone local       */
                   {
                    TCPSRV_DBG(("ristcpsrv: Local instanation .. nothing done\n"));     /* no need for further processing */
                   }
                else
                    {
                        if (GetWindowsDirectory(location,256))
                            lstrcpy(&location[2],"\\temp\\jada.{p}");
                        else
                            lstrcpy(location,"c:\\temp\\jada.{p}");

                        TCPSRV_DBG(("file concurrency name was %s\n",location));
  
                        if ((hFilename = CreateFile(location,
                                         GENERIC_READ | GENERIC_WRITE,
                                         FILE_SHARE_READ | FILE_SHARE_WRITE,
                                         NULL,
                                         OPEN_EXISTING,FILE_ATTRIBUTE_HIDDEN,NULL)) == INVALID_HANDLE_VALUE )
                           {
                                if ((hFilename = CreateFile(location,
                                                 GENERIC_READ | GENERIC_WRITE,
                                                 FILE_SHARE_READ | FILE_SHARE_WRITE,
                                                 NULL,
                                                 CREATE_NEW,FILE_ATTRIBUTE_HIDDEN,NULL)) == INVALID_HANDLE_VALUE )
                                     {
                                          TCPSRV_DBG(("File concurrency create failed\n"));

                                     }
                                 else
                                      {
                                          hShared_memory = CreateFileMapping(hFilename,
                                                           NULL,PAGE_READWRITE,0,30,NULL);
                 
                                          ptr = MapViewOfFile(hShared_memory,
                                                              FILE_MAP_READ | FILE_MAP_WRITE,0,0,30);

                                          memset(ptr,'\0',30); 
                                       }
                          }
                         else
                          {
                                hShared_memory = CreateFileMapping(hFilename,
                                                                   NULL,PAGE_READWRITE,0,30,NULL);
                 
                                ptr = MapViewOfFile(hShared_memory,
                                                    FILE_MAP_READ | FILE_MAP_WRITE,0,0,30);
	                  }
          
                        if (ptr)
                          {
                                for (i=0; i < 6; i++)
                                  {
                                     if (strlen(ptr) == 0)
                                     break;
                        
                                     UnmapViewOfFile(ptr);
                                     ptr = MapViewOfFile(hShared_memory,
                                                         FILE_MAP_READ | FILE_MAP_WRITE,0,0,30);
                                     Sleep(500);
                                     TCPSRV_DBG(("ristcpsrv: Waiting for addr to clear\n"));
                                  }
                           }

                         sprintf(location,"ristcpsrv: Socket Peer Name is  [%s]",
                                           inet_ntoa(from.sin_addr));

                         TCPSRV_DBG(("%s\n",location));

                         if (ptr)
                           {
                               strcpy(ptr,inet_ntoa(from.sin_addr));
                               UnmapViewOfFile(ptr);
             			if (hShared_memory)
				{
                       			  TCPSRV_DBG(("closing hSharedMemory DDF\n"));
				CloseHandle(hShared_memory ); 
				}
				if (hFilename)
				{
       			                  TCPSRV_DBG(("closing hFilename DDF\n"));
				CloseHandle(hFilename );
				}
                           }
                    }
             }  
        }

	status = recv ((SOCKET)sochdl, buffer, BUFFER_SIZE, 0);
#endif
	if (status != BUFFER_SIZE)
	{
#if defined(unix)
		TCPSRV_DBG(("ristcpsrv: bad recv status; expected %d, got:%d\n",
			BUFFER_SIZE, status));
#endif
#if defined(WIN32)
		if (status == SOCKET_ERROR) {
			TCPSRV_DBG(("ristcpsr:bad recv sd %d; want %d, got:%d, err:%d\n",
				sochdl, BUFFER_SIZE, status, WSAGetLastError()));
		}
		else {
			TCPSRV_DBG(("ristcpsrv:bad recv status; expected %d, got:%d\n",
				BUFFER_SIZE, status));
		}
#endif
		TCPSRV_DBG(("ristcpsrv: exiting\n"));
#if defined(unix)
		return(status);
#endif
#if defined(WIN32)
  		status = closesocket ( sochdl );
		if ( status == SOCKET_ERROR ) {
			TCPSRV_DBG(("ristcpsr: closesocket %d call failed: error %d\n",
					sochdl, WSAGetLastError()));
		}
		ExitThread(status);
#endif
	}
	TCPSRV_DBG(("ristcpsrv: recv status:%d\n", status));

	/*
	** A version 4 client(app) sends the first four bytes length, ignore them.
	** A version 5 client(app) sends the 3rd byte match_flag and we pass that on
	** to RIScom_get_risdir.
	** We also know to look for the product entry in /etc/risconfig file.
	** For VerSion 4 or older, we look for product entry in /usr/ip32/ingrconfig
	**      - Sunil 1/5/94
	*/
	dtype = buffer[4];
	maj = (int)buffer[5];
	min = (int)buffer[6];
	rel = (int)buffer[7];
	if (maj > 4)
	{
		match_flag = (int)buffer[3];
		config_file = RISCONFIG_FILE;
		TCPSRV_DBG(("ristcpsrv: match_flag:%d\n", match_flag));
	}
	else
	{
#if defined(__Sol2__) || defined(__hpux__) || defined(Soli)
	/*
	** Well, here a v4 app (or cli) is looking for v4 cli (or srv)
	** on the remote machine. When remote machine is Solaris or HP, there
	** is no v4 stuff. So, we turn back and point to RISCONFIG_FILE !!!
	** 
	** Fix for TR#249407261                    Surjit (Dec.19, 1994)
	*/
		config_file = RISCONFIG_FILE;
#else
		config_file = INGRCONFIG_FILE;		
#endif
	}

	TCPSRV_DBG(("ristcpsrv: dtype:%c maj:%d min:%d rel:%d config_file:%s\n",
				dtype, maj, min, rel, config_file));

	switch(dtype)
	{
#if defined(WIN32)
/**
	This new dtype was added to help locate the location of the RIS client
on the remote NT machine. When the client from the host machine sends this
dtype, the ristcpservice on the NT machine will get the risdir of the 
RIS client on the remote machine and send it back to the host RIS client. 
THe remote RIS client path is needed just to determine where to place the
remote schema file and not for any other purposes. 
Radha 02/03/95
**/
		case 'Z': 
			TCPSRV_DBG(("ristcpsrv: Z getting RIS client location\n"));
      			if (!(status = RIScom_get_risdir(
					RIS_CLIENT_RUNTIME_PRODUCT, maj, 
				  	min, rel, match_flag, 0, config_file, 
					risdir, &development, 0)))
			{
					strcpy(cli_loc_path, risdir);
			}
			else
			{
				strcpy(cli_loc_path, "Cannot find RIS in the registry");
			}
			TCPSRV_DBG(("Radha:  <%s> \n", cli_loc_path));
			len = sizeof(cli_loc_path);
			status = send( sochdl, cli_loc_path, 
					len, 0);	
			if (status == SOCKET_ERROR)
			{
			TCPSRV_DBG(("ristcpsrv:  send failed %d\n", WSAGetLastError()));
			}
				
			break;
#endif
		case 'C':
			TCPSRV_DBG(("ristcpsrv: C starting risclient\n"));

            if (!(status = RIScom_get_risdir(RIS_CLIENT_RUNTIME_PRODUCT, maj, 
				  min, rel, match_flag, 0, config_file, risdir,
				  &development, 0)))
			{
				RIScom_generate_local_exe_path(path, risdir, development, 
										   "riscli", RIS_CLIENT_PROGRAM);
			}
			break;

		case 'X':
			/*
			**	if RISX(C/S)NET is found, use it, otherwise use RISX(C/S)
			**  -- not so for sco; net products are not supported on sco
			*/
			TCPSRV_DBG(("ristcpsrv: X starting informix server\n"));
#ifndef sco
            if (!(status = RIScom_get_risdir(RISXNET_PRODUCT,maj,min,rel,
						  match_flag, 0, config_file, risdir, &development,
						  0)))
            {
				RIScom_generate_local_exe_path(path, risdir, development,
											   "rissrv", RISXNET_PROGRAM);
/* modified by Goverdhan     6/9 */
#ifdef WIN32
		strcpy(tmp_path,path);
		strcat(tmp_path,".exe");
		if (access(tmp_path,0))
#else
                if (access(path,0))
#endif
                {
                    if (!(status = RIScom_get_risdir(RISX_PRODUCT,maj,min,rel,
						match_flag, 0,config_file,risdir,&development, 0)))
					{
						RIScom_generate_local_exe_path(path, risdir, 
										  development, "rissrv", RISX_PROGRAM);
					}
                }
            }
            else
#endif /* ! sco */
            {
                if (!(status = RIScom_get_risdir(RISX_PRODUCT,maj,min,rel,
					match_flag, 0,config_file,risdir,&development, 0)))
				{
					RIScom_generate_local_exe_path(path, risdir, development,
											   "rissrv", RISX_PROGRAM);
				}
            }
			break;

		case 'O':
			/*
			**	if RISOCNET is found, use it, otherwise use RISOC
			**  -- except sco
			*/
			TCPSRV_DBG(("ristcpsrv: O starting oracle server\n"));
#  ifndef sco
            if (!(status = RIScom_get_risdir(RISONET_PRODUCT,maj,min,rel,
			match_flag, 0,config_file,risdir,&development, 0)))
            {
			RIScom_generate_local_exe_path(path, risdir, development,
				"rissrv", RISONET_PROGRAM);
#ifdef WIN32
		strcpy(tmp_path,path); 
		strcat(tmp_path,".exe"); 
		TCPSRV_DBG(("ristcpsrv: O starting oracle serverPATH %s \n",tmp_path));
		if (access(tmp_path,0))
#else
                if (access(path,0))
#endif
                {
                    if (!(status = RIScom_get_risdir(RISO_PRODUCT,maj,min,rel,
			match_flag, 0,config_file,risdir,&development, 0)))
			{
			RIScom_generate_local_exe_path(path, risdir, 
					   development,	"rissrv", RISO_PROGRAM);
			}
                }
            }
            else
# endif /* ! sco */
            {
                if (!(status = RIScom_get_risdir(RISO_PRODUCT,maj,min,rel,
			match_flag, 0,config_file,risdir,&development, 0)))
		{
		    RIScom_generate_local_exe_path(path, risdir, development, "rissrv", RISO_PROGRAM);
		}
            }
		break;

		case 'I':
			/*
			**	if RISICNET is found, use it, otherwise use RISIC
			**  -- except sco
			*/
			TCPSRV_DBG(("ristcpsrv: I starting ingres server\n"));
#  ifndef sco
            if (!(status = RIScom_get_risdir(RISINET_PRODUCT,maj,min,rel,
					match_flag, 0,config_file,risdir,&development, 0)))
            {
				RIScom_generate_local_exe_path(path, risdir, development,
					"rissrv", RISINET_PROGRAM);
                if (access(path,0))
                {
                    if (!(status = RIScom_get_risdir(RISI_PRODUCT,maj,min,rel,
						match_flag, 0,config_file,risdir,&development, 0)))
					{
						RIScom_generate_local_exe_path(path, risdir, 
									   development, "rissrv", RISI_PROGRAM);
					}
                }
            }
            else
# endif /* ! sco */
            {
                if (!(status = RIScom_get_risdir(RISI_PRODUCT,maj,min,rel,
					match_flag, 0,config_file,risdir,&development, 0)))
				{
					RIScom_generate_local_exe_path(path, risdir, development,
												   "rissrv", RISI_PROGRAM);
				}
            }
			break;

		case 'D':
			TCPSRV_DBG(("ristcpsrv: starting db2 server\n"));
			if (!(status = RIScom_get_risdir(RISD_PRODUCT,maj,min,rel,
				match_flag, 0,config_file,risdir,&development, 0)))
		    {
				RIScom_generate_local_exe_path(path, risdir, development,
											   "rissrv", RISD_PROGRAM);
			}
			break;

       case '4':
        TCPSRV_DBG(("ristcpsrv: starting os400 server\n"));
            if (!(status = RIScom_get_risdir(RISOS4DS_PRODUCT,maj,min,rel,
                MATCH_COMPATIBLE, 0,0,risdir,&development, 0)))
            {
                RIScom_generate_local_exe_path(path, risdir, development,
                                            "rissrv", RISOS4DS_PROGRAM);
            }
        break;

		case 'Y':
			TCPSRV_DBG(("ristcpsrv: starting sybase server\n"));
			if (!(status = RIScom_get_risdir(RISY_PRODUCT,maj,min,
				rel, match_flag,0,config_file,risdir,
					&development, 0)))
			{
				RIScom_generate_local_exe_path(path, risdir, 
					development, "rissrv", RISY_PROGRAM);
			}
#if defined(WIN32)
			else
			   if (!(status = RIScom_get_risdir(RISMSSQL_PRODUCT,
				  maj,min, rel, match_flag,0,config_file,
			           risdir, &development, 0)))
 			{
				RIScom_generate_local_exe_path(path, risdir,
       				        development, "rissrv", RISMSSQL_PROGRAM);
			} 
#endif
			break;

		case 'M':
			TCPSRV_DBG(("ristcpsrv: starting mssql server\n"));
			if (!(status = RIScom_get_risdir(RISMSSQL_PRODUCT,
					maj,min,rel, match_flag,0,config_file,
					risdir,&development, 0)))
			{
				RIScom_generate_local_exe_path(path, risdir, 
			       	development, "rissrv", RISMSSQL_PROGRAM);
			}
			break;

		default:
			TCPSRV_DBG(("ristcpsrv: invalid dtype:%d\n",  dtype));
			status = RIS_E_INTERNAL_ERROR;
		break;
	}
	if (status)
	{
		TCPSRV_DBG(("ristcpsrv: exiting\n"));
#if defined(unix)
		return(RIS_E_INTERNAL_ERROR);
#endif
#if defined(WIN32)
		status = closesocket ( sochdl );
		if ( status == SOCKET_ERROR ) {
			TCPSRV_DBG(("ristcpsr: closesocket %d call failed: error %d\n",
					sochdl, WSAGetLastError()));
		}
		ExitThread(RIS_E_INTERNAL_ERROR);
#endif
	}

#if defined(unix)
	argv[0] = path;
	argv[argc] = (char *)0;

	if (RIStcpsrv_debug)
	{
		RIScom_output_debug("ristcpsrv: execing <%s>\n",path);
		for (i=0;i<argc;i++)
		{
			RIScom_output_debug("ristcpsrv: argv[%d]:<%s>\n",i,argv[i]);
		}
	}
	execv(path,argv);
	TCPSRV_DBG(("ristcpsrv: exec <%s> failed: errno:%d: %s\n",
		path, errno, strerror(errno)));
	TCPSRV_DBG(("ristcpsrv: exiting\n"));
	return(status);
#endif

#if defined(WIN32)
	strcpy(cmdln, path);
	strcat(cmdln, " T ");
/*
**  MUST BE ADDED BUT AFFECTS ALL NT SERVERS AND CLIENT
**  BECAUSE THIS HANDLE MUST BE CLOSED BY NEW PROCESS
**	strcat(cmdln, _itoa(sd, sd_str, 10));
*/
	strcat(cmdln, _itoa(sd, sd_str, 10));
	strcat(cmdln, " ");
	strcat(cmdln, _itoa(sochdl, sd_str, 10));
	TCPSRV_DBG(("ristcpsr: create process command line: %s\n", cmdln));

	sa.nLength = sizeof(SECURITY_ATTRIBUTES);
	sa.lpSecurityDescriptor = NULL;
	sa.bInheritHandle = TRUE;
	memset (&si, 0, sizeof(STARTUPINFO));
	si.cb = sizeof(STARTUPINFO);
    si.lpDesktop   = NULL;
    si.lpTitle     = NULL;
    si.dwX         = 0;
    si.dwY         = 0;
    si.dwXSize     = 0;
    si.dwYSize     = 0;
    si.dwFlags     = STARTF_USESHOWWINDOW; /* blue screen change from (DWORD) NULL; */
	/* This prevents a window from being created */
    si.wShowWindow = SW_HIDE;
    si.hStdInput = NULL;
    si.hStdOutput = NULL;
    si.hStdError = NULL;

    pi.hProcess = NULL;

	if ( CreateProcess(NULL, cmdln, &sa, 
		 (LPSECURITY_ATTRIBUTES)NULL, TRUE, 
		  /* DETACHED_PROCESS, */ CREATE_NEW_CONSOLE,
/*
**	0,
**	The DETACHED_PROCESS flag causes popen to fail; 
**  not currently uSing process groups
**
**		  GetEnvironmentStrings(),
*/
		  (LPVOID)NULL, 	
		  (LPTSTR)NULL, &si, &pi) == FALSE )
	{
		TCPSRV_DBG(("ristcpsr: CreateProcess failed: %d error\n",
					GetLastError()));
	}
	TCPSRV_DBG(("ristcpsr: Created process pid: %d\n",
				pi.dwProcessId));

	/*
	**  Close socket as it now belongs to new process
	**  Close new process handles also
	*/
	CloseHandle(pi.hThread);
	CloseHandle(pi.hProcess);
    	CloseHandle(si.hStdInput); 
    	CloseHandle(si.hStdOutput);
    	CloseHandle(si.hStdError );
	status = closesocket ( sochdl );
		TCPSRV_DBG(("ristcpsrv: closed socket sochdl and pi handles\n"));
	if ( status == SOCKET_ERROR ) {
		TCPSRV_DBG(("ristcpsr: closesocket %d call failed: error %d\n", sochdl, WSAGetLastError()));
	}
	if ( status == SOCKET_ERROR ) {
		TCPSRV_DBG(("ristcpsr: closesocket %d call failed: error %d\n", sochdl, WSAGetLastError()));
	}
	TCPSRV_DBG(("ristcpsr: Closed proc: %d thrd: %d sd: %d\n", 
				pi.hProcess, pi.hThread, sochdl));
	ExitThread(0);
#endif
}
