/*
**	NAME:							netlocal.c
**	AUTHORS:						Dave Michal
**	CREATION DATE:					5/90
**	ABSTRACT:
**		Various routines for sending and receiving message buffers
**		locally on a machine.
**	
**	REVISION HISTORY:
**
**		11/94:	Changed the call under WIN32 from strncpy to
**				RIScom_strncpy.  This is for INTERNATIONALIZATION
**				support. Paula
**		01/95:	Changed the carriage return '^M' to 0xD.  When editing file in 
**				nt, the editor converted the '^M' to an actual carriage return.
**				Paula.
**		01/25/95	rlk	changed command to command.com for Win95		
**		02/07/95 Radha Shivakumar
**			Changed the code for NET_get_file_local and 
**			NET_put_file_local to NOT call NET_execute_command but
**			instead call CopyFile to copy the schema file. This
**			change was made to help the I18N effort so that the
**			hard_coded strings checked for in the code is eliminated
**			
**              7/1/96 - Ashley -  Fix for TR 439407587  
**		
*/
 
/*
**	INCLUDES
*/
#include <fcntl.h>
#include <errno.h>
#include <signal.h>
#include <string.h>
#include <unistd.h>

#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/sem.h>
#include <sys/utsname.h>

#include "rislimit.h"
#include "risnet.h"


#define NET_INITIAL_BUFFER_SIZE		67568

// Must be explicitly declared by application program
// Only used for debugging?
#if defined(unix) && !defined(sunx)
union semun
{
	int					val;
	struct semid_ds		*buf;
	ushort				*array;
};
#endif

#if defined(unix)
static int is_sem_locked[25];
#endif

#if defined(WIN32)
HANDLE	hMapObject=0, hEventC=0, hEventS=0;
int		client_died=0;
BOOL	server_locked=FALSE;

struct event_info NTevents[NET_MAX_CONNECTIONS] = { {0,0,0,0,FALSE} };
#endif

/*
**	FUNCTIONS
*/

/******************************************************************************/

#if defined(WIN32)
extern DWORD NET_wait_for_server(
	int index)
{
	DWORD	wStatus;

	NET_DBG(("NET_wait_for_server(index:%d) (handle:%d)\n", index,
			 NTevents[index].Server));

	wStatus = WaitForSingleObject(NTevents[index].Server, INFINITE);
	if (wStatus == 0)
	{
		NET_DBG(("NET_wait_for_server: server died\n"));
		NTevents[index].server_died = 1;
		NTevents[index].Server = 0;
		NTevents[index].EventC = 0;
		NTevents[index].EventS = 0;
		NTevents[index].client_locked = FALSE;
	}
	else
	{
		NET_DBG(("NET_wait_for_server: WaitForSingleObject status: %d\n",
					GetLastError()));
	}

	NET_DBG(("NET_wait_for_server: complete\n"));

	ExitThread(wStatus);
	return(wStatus);
}

/******************************************************************************/

extern DWORD NET_wait_for_client(
	HANDLE handle)
{
	DWORD	wStatus;

	NET_DBG(("NET_wait_for_client(handle: %d)\n", handle));

	wStatus = WaitForSingleObject(handle, INFINITE);
	if (wStatus == 0)
	{
		NET_DBG(("NET_wait_for_client: client died\n"));
		client_died = 1;
	}
	else
	{
		NET_DBG(("NET_wait_for_client: WaitForSingleObject status: %d\n",
					GetLastError()));
	}

	NET_DBG(("NET_wait_for_client: complete\n"));
	
	ExitThread(wStatus);
	return(wStatus);
}
#endif

extern void NET_connect_local(
	net_s			*net,
	net_connect_s	*connect_info)
{
	int			i;
	char		*arg1;
#if defined(unix)
	char			*arg2, *arg3;
	int				val;
	unsigned int	semnum;
	union semun		arg;
#endif
#if defined(WIN32)
	char				buffer[MAX_PATH_SIZE + 50];
	BOOL				status;
	DWORD				idThread;
	HANDLE				hTemp;
	HANDLE				hServer;
	HANDLE				hClient;
	HANDLE				hThread;
	HANDLE				EventC, EventS;
	unsigned int		index;
/*	LPCTSTR				cmdline; sdk version */
	TCHAR				cmdline[255];
	STARTUPINFO			sui;
	PROCESS_INFORMATION	pi;
	SECURITY_ATTRIBUTES	sa;
#endif

	NET_DBG(("NET_connect_local(net:0x%x connect_info:0x%x)\n",
		net, connect_info));

	net->id.shmem.pid = 0;
	net->id.shmem.semnum = 0;
	net->id.shmem.bufferp = (net_block_info_s **)0;
	net->id.shmem.break_connectionp = (char *)0;

	/*
	** If Network shared memory has not been allocated, do so
	*/
	if (!NET_mem)
	{
		/*
		** Allocate shared memory
		*/
		NET_alloc_shmem(net, &connect_info->shmem.shmem_info);
		if (net->error_code != NET_SUCCESS)
		{
			NET_DBG(("NET_connect_local: error allocing shmem\n"));
			return;
		}
	}

	if (!NET_mem)
	{
		NET_DBG(("NET_connect_local: no shared memory\n"));
		NET_error(net, NET_E_NO_SHARED_MEMORY);
		return;
	}

#if defined(unix)
	NET_mem->semnum = 0;
	NET_mem->bufferp = (net_block_info_s **)0;
	NET_mem->break_connectionp = (char *)0;
#endif
#if defined(WIN32) || defined(__Sol2__) || defined(Soli)
	NET_mem->cur_index = -1;
#endif

#if defined(unix)
	if (NET_mem->shmid == -1 || NET_mem->avail <= 0)
#endif
#if defined(WIN32)
	if (NET_mem->hMapObject == 0 || NET_mem->avail <= 0)
#endif
	{
		NET_DBG(("NET_connect_local: no shared memory\n"));
		NET_error(net, NET_E_NO_SHARED_MEMORY);
		return;
	}

#if defined(unix)
	if (NET_mem->semid == -1 || NET_mem->sem_cnt <= 0)
	{
		NET_DBG(("NET_connect_local: no semaphores\n"));
		NET_error(net, NET_E_NO_SEMAPHORES);
		return;
	}
#endif
		
#if defined(unix)
	/*
	**	Get a semaphore
	*/
	for (semnum = 0; semnum < NET_mem->sem_cnt; ++semnum)
	{
		if ((NET_mem->sem_alloc & (1 << semnum)) == 0)
		{
			/* 
			**	initialize the semaphore value to 1
			*/
			arg.val = 1;
			if (semctl(NET_mem->semid, semnum, SETVAL, arg))
			{
				NET_error_local(net, NET_E_SEM_INIT_FAIL, "");
				return;
			}

			/*
			** initialize is semaphore locked value to 1
			*/
			is_sem_locked[semnum] = 1;

			NET_mem->sem_alloc |= (1 << semnum);
			NET_mem->attach_count++;
			break;
		}
	}
	if (semnum == NET_mem->sem_cnt)
	{
		NET_error_local(net, NET_E_NO_AVAIL_SEM, "");
		return;
	}
	net->id.shmem.semnum = semnum;
	NET_DBG(("NET_connect_local: net->id.shmem.semnum:%d\n",
		net->id.shmem.semnum));
#endif

	/*
	**	Get a buffer pointer
	*/
	for (i = 0; i < NET_MAX_CONNECTIONS; i++)
	{
		if (NET_mem->buffers[i] == (net_block_info_s *)0
#if defined(WIN32)
			&& NTevents[i].Server == 0 && NTevents[i].server_died == 0
#endif
			)
		{
			net->id.shmem.bufferp = &NET_mem->buffers[i];
			net->id.shmem.break_connectionp = &NET_mem->break_connections[i];
			/*
			 **	Load the index into arrays into shared memory
			 **	so the server process knows what they are
			 */
#if defined(__Sol2__) || defined(Soli)
				NET_mem->cur_index = i;
#endif
#if defined(WIN32)
			NET_mem->cur_index = i;
			net->id.shmem.semnum = i;
			index = i;
			NTevents[index].Server = 0;
			NTevents[index].EventC = 0;
			NTevents[index].EventS = 0;
			NTevents[index].server_died = 0;
			NTevents[index].client_locked = FALSE;
			NET_DBG(("NET_connect_local: NTevents index: %d\n", index));
#endif
			break;
		}
	}
	if (i == NET_MAX_CONNECTIONS)
	{
#if defined(WIN32)
		/*
		**	Garbage Collect NTevents array
		**	Need to Add a time stamp here also
		*/
		for (i = 0; i < NET_MAX_CONNECTIONS; i++)
		{
			if (NET_mem->buffers[i] == (net_block_info_s *)0 &&
				NTevents[i].server_died)
			{
				net->id.shmem.bufferp = &NET_mem->buffers[i];
				net->id.shmem.break_connectionp = 
					&NET_mem->break_connections[i];
				/*
				 **	Load the index into arrays into shared memory
				 **	so the server process knows what they are
				 */
				NET_mem->cur_index = i;
				net->id.shmem.semnum = i;
				index = i;
				NTevents[index].Server = 0;
				NTevents[index].EventC = 0;
				NTevents[index].EventS = 0;
				NTevents[index].server_died = 0;
				NTevents[index].client_locked = FALSE;
				NET_DBG(("NET_connect_local: NTevents index: %d\n", index));
				break;
			}
		}
		if (i == NET_MAX_CONNECTIONS)
		{
#endif
			NET_DBG(("NET_connect_local: NET_MAX_CONNECTIONS exceeded\n"));
			NET_error(net, NET_E_MAX_CONNECTIONS_EXCEEDED);
			return;
#if defined(WIN32)
		}
#endif
	}
	NET_DBG(("NET_connect_local: net->id.shmem's bufferp:0x%x break_connectionp:0x%x\n",
			 net->id.shmem.bufferp, net->id.shmem.break_connectionp));

#if defined(WIN32)
	/*
	**	Create EventC: client process's event
	*/
	sa.bInheritHandle = TRUE;
	sa.lpSecurityDescriptor = NULL;
	sa.nLength = sizeof(SECURITY_ATTRIBUTES);
	EventC = CreateEvent(&sa, FALSE, FALSE, NULL);
	if (!EventC)
	{
		NET_mem->hEventC = 0;
		NET_error(net, NET_E_CANT_GET_SEM_SET);
		NET_DBG(("NET_connect_local: CreateEventC Failed error: %d\n",
				GetLastError()));
		return;
	}
	NET_mem->hEventC  = EventC;
	NTevents[index].EventC = EventC;
	NET_DBG(("NET_connect_local: CreateEventC yields hEventC %d\n", EventC));
	/*
	**	Create EventS: server process's event
	*/
	EventS = CreateEvent(&sa, FALSE, FALSE, NULL);
	if (!EventS)
	{
		NET_mem->hEventS = 0;
		NET_error(net, NET_E_CANT_GET_SEM_SET);
		NET_DBG(("NET_connect_local: CreateEventS Failed error: %d\n",
				GetLastError()));
		return;
	}
	NET_mem->hEventS = EventS;
	NTevents[index].EventS = EventS;
	NET_DBG(("NET_connect_local: CreateEventS yields EventS %d\n", EventS));

	NET_mem->attach_count++;

#endif

	/*
	**	Get a buffer
	*/
#if defined(__clipper__) || defined(sun) || defined(sco) || defined(__hpux__)
	*net->id.shmem.bufferp = NET_get_block(net, NET_INITIAL_BUFFER_SIZE);
#endif
#if defined(WIN32) || defined(__Sol2__) || defined(Soli)
	NET_SET_PTR(NET_get_block(net, NET_INITIAL_BUFFER_SIZE),
				net->id.shmem.bufferp, net_block_info_s);
#endif
	if (net->error_code != NET_SUCCESS)
	{
		NET_DBG(("NET_connect_local: unable to get a buffer\n"));
		net->id.shmem.bufferp = (net_block_info_s **)0;
		return;
	}
#if defined(__clipper__) || defined(sun) || defined(sco) || defined(__hpux__)
	NET_DBG(("NET_connect_local: *net->id.shmem.bufferp:0x%x\n",
		*net->id.shmem.bufferp));
#endif
#if defined(WIN32) || defined(__Sol2__) || defined(Soli)
	NET_DBG(("NET_connect_local: *net->id.shmem.bufferp:0x%x\n",
			 NET_GET_PTR(net->id.shmem.bufferp, char)));
#endif

	/*
	** Make sure the break_connection flag is clear
	*/
	*net->id.shmem.break_connectionp = 0;

#if defined(unix)
	/*
	**	Load the semaphore number and buffer address into shared memory
	**	so the server process knows what they are
	*/
	NET_mem->semnum = net->id.shmem.semnum;
	NET_mem->bufferp = net->id.shmem.bufferp;
	NET_mem->break_connectionp = net->id.shmem.break_connectionp;
	NET_sighold(SIGCLD);
#if defined(sco)
	switch((val=fork()))
#elif defined(unix)
	switch((val=vfork()))
#endif
	{
		case 0:
			net->id.shmem.pid = val;
			NET_sigrelse(SIGCLD);
			NET_fcntl(0, F_SETFD, 1);
			NET_fcntl(1, F_SETFD, 1);
			NET_fcntl(2, F_SETFD, 1);

			NET_DBG(("NET_connect_local: SERVER: pid:%d exec'ing:<%s>\n",
				getpid(), connect_info->shmem.path));

			if (connect_info->shmem.arg1[0]) arg1 = connect_info->shmem.arg1;
			else arg1 = (char *)0;
			if (connect_info->shmem.arg2[0]) arg2 = connect_info->shmem.arg2;
			else arg2 = (char *)0;
			if (connect_info->shmem.arg3[0]) arg3 = connect_info->shmem.arg3;
			else arg3 = (char *)0;

			if (NET_execl(connect_info->shmem.path,
					  connect_info->shmem.path,
					  arg1, arg2, arg3, (char *)0) == -1)
				_exit(1);
			break;

		case -1:
			NET_DBG(("NET_connect_local: fork error -1; errno:%d\n", errno));
			NET_error_local(net, NET_E_CANT_FORK_SERVER, "");
			net->id.shmem.pid = 0;
			return;

		default:
			net->id.shmem.pid = val;
			NET_DBG(("NET_connect_local: CLIENT: forked pid:%d\n",
				net->id.shmem.pid));
			NET_sigrelse(SIGCLD);
		break;
	}
#endif
#if defined(WIN32)
	/*
	**	Create the child process
	*/
	if (connect_info->shmem.arg1[0]) arg1 = connect_info->shmem.arg1;
	else arg1 = (char *)0;

	if (!arg1)
	{
		NET_DBG(("NET_connect_local: CreateProcess NULL arg1; INVALID\n"));
		NET_error_local(net, NET_E_CANT_FORK_SERVER, "");
		net->id.shmem.pid = 0;
		return;
	}

	sprintf(buffer, "%s %s %d %d %d \0", connect_info->shmem.path,
			arg1, hMapObject, EventC, EventS);
/*	cmdline = buffer; sdk version */
	strcpy(cmdline , buffer);

	memset(&sui, 0, sizeof(STARTUPINFO));
	sui.cb = sizeof (STARTUPINFO);
	sui.cb = sizeof(STARTUPINFO);
    sui.lpDesktop   = NULL;
    sui.lpTitle     = NULL;
    sui.dwX         = 0;
    sui.dwY         = 0;
    sui.dwXSize     = 0;
    sui.dwYSize     = 0;
    sui.dwFlags     = STARTF_USESHOWWINDOW; /* blue screen change (DWORD) NULL; */
	/* This prevents a window from being showing */
    sui.wShowWindow = SW_HIDE;

    pi.hProcess = NULL;

	sa.bInheritHandle = TRUE;
	sa.lpSecurityDescriptor = NULL;
	sa.nLength = sizeof(SECURITY_ATTRIBUTES);
	/*-----------------------------------------------------------------------------
	**  DETACHED_PROCESS changed to CREATE_NEW_CONSOLE below to fix PDS 
	**	batch-mode blue screen problem.  12/94 DDF/DANK
	-----------------------------------------------------------------------------**/
	status = CreateProcess (NULL, cmdline, &sa, NULL,
		TRUE, CREATE_NEW_CONSOLE, NULL, NULL, &sui, &pi );
	if (status == FALSE)
	{
		NET_DBG(("NET_connect_local: CreateProcess cmd %s; failed; error:%d\n",
					cmdline, GetLastError()));
		NET_error_local(net, NET_E_CANT_FORK_SERVER, "");
		net->id.shmem.pid = 0;
		return;
	}
	NET_DBG(("NET_connect_local: CreateProcess cmd %s; successful\n",
					cmdline));
	hServer = pi.hProcess;
	net->id.shmem.pid = (int)hServer;
	NTevents[index].Server = hServer;

	/*
	**	Get Client Handle and put it in shared memory so Server Can
	**	Find Out if Client Dies
	*/
	hTemp = GetCurrentProcess();
	status = DuplicateHandle(hTemp, hTemp, hServer, &hClient, 0, FALSE,
		DUPLICATE_SAME_ACCESS);
	if (status == FALSE)
	{
		NET_DBG(("NET_connect_local: DuplicateHandle failed; error:%d\n",
					GetLastError()));
		NET_error_local(net, NET_E_CANT_FORK_SERVER, "");
		net->id.shmem.pid = 0;
		return;
	}
	NET_DBG(("NET_connect_local: DuplicateHandle successful hClient %d\n",
				hClient));

	/*
	**	Create thread to wait for death of child
	**	may pass only 1 arg to a thread: do not use a local address 
	**  since that's on the stack and can't count on it still being valid 
	**  by the time the new thread references it.
	*/
	hThread = CreateThread(NULL, 0,
				(LPTHREAD_START_ROUTINE)NET_wait_for_server,
				(LPVOID)index, 0, &idThread);
	if (hThread == NULL)
	{
		NET_DBG(("NET_connect_local: CreateThread failed; error:%d\n",
					GetLastError()));
		NET_error_local(net, NET_E_CANT_FORK_SERVER, "");
		net->id.shmem.pid = 0;
		return;
	}
	NET_DBG(("NET_connect_local: CreateThread successful\n"));

	/*
	**	Send hClient to server process
	*/
	NET_mem->hClient = hClient;
	NET_DBG(("NET_connect_local: NET_mem hClient %d\n",NET_mem->hClient));

	NET_DBG(("NET_connect_local: Setting EventC\n"));
	NTevents[index].client_locked = TRUE;
	status = SetEvent(EventC);
	if (status == FALSE)
	{
		NET_DBG(("NET_connect_local: SetEventC failed; error:%d\n",
					GetLastError()));
		NET_error_local(net, NET_E_CANT_FORK_SERVER, "");
		net->id.shmem.pid = 0;
		return;
	}

	/*
	** Wait for child to release EventS
	*/
	NET_DBG(("NET_connect_local: Waiting for EventS\n"));
	do {
		status = WaitForSingleObject(EventS, 500);
	} while(!NTevents[index].server_died && status == WAIT_TIMEOUT);
	if (NTevents[index].server_died)
	{
		NET_DBG(("NET_connect_local: after wait server_died\n"));
		NET_error_local(net, NET_E_LOCAL_CONNECTION_BROKEN, "");
		net->id.shmem.pid = 0;
		return;
	}
	if (status)
	{
		NET_DBG(("NET_connect_local: WaitFor (EventS) error: %d\n",
				GetLastError()));
		NET_error_local(net, NET_E_CANT_FORK_SERVER, "");
		net->id.shmem.pid = 0;
		return;
	}
	NET_DBG(("NET_connect_local: Got EventS\n"));
	NTevents[index].client_locked = FALSE;
#endif

	NET_DBG(("NET_connect_local: complete\n"));
}

/******************************************************************************/

extern void NET_accept_local(
	net_s		*net)
{
#if defined(WIN32)
	HANDLE	hClient, hEventS, hThread;
	BOOL	status;
	DWORD	idThread;
#endif
	NET_DBG(("NET_accept_local(net:0x%x)\n",net));

	NET_attach_shmem(net);
	if (net->error_code != NET_SUCCESS)
	{
		NET_DBG(("NET_accept_local: Unable to attach to shared memory\n"));
		return;
	}

#if defined(__clipper__) || defined(sun) || defined(sco) || defined(__hpux__)
	net->id.shmem.semnum = NET_mem->semnum;
	net->id.shmem.bufferp = NET_mem->bufferp;
	net->id.shmem.break_connectionp = NET_mem->break_connectionp;
	is_sem_locked[NET_mem->semnum] = 0;
 	NET_DBG(("NET_accept: net->id.shmem's semnum:%d bufferp:0x%x break_connectionp:0x%x\n",
			 net->id.shmem.semnum, net->id.shmem.bufferp, 
			 net->id.shmem.break_connectionp));
#endif
#if defined(__Sol2__) || defined(Soli)
	net->id.shmem.semnum = NET_mem->semnum;
	net->id.shmem.bufferp = &NET_mem->buffers[NET_mem->cur_index];
	net->id.shmem.break_connectionp = 
		&NET_mem->break_connections[NET_mem->cur_index];
	is_sem_locked[NET_mem->semnum] = 0;
 	NET_DBG(("NET_accept: net->id.shmem's semnum:%d bufferp:0x%x *bufferp:0x%x break_connectionp:0x%x\n",
			net->id.shmem.semnum, net->id.shmem.bufferp,
			NET_GET_PTR(net->id.shmem.bufferp, char),
			net->id.shmem.break_connectionp));
#endif

#if defined(WIN32)
	/*
	** Wait for client to release EventC,
	** then get hClient out of shared memory
	*/
	server_locked = TRUE;
	NET_DBG(("NET_accept: Waiting for EventC\n"));
	do
	{
		status = WaitForSingleObject(hEventC, 500);
	} while(!client_died && status == WAIT_TIMEOUT);
	if (client_died)
	{
		NET_DBG(("NET_accept: client died\n"));
		NET_error_local(net, NET_E_LOCAL_CONNECTION_BROKEN, "");
		net->id.shmem.pid = 0;
		return;
	}
	if (status)
	{
		NET_error_local(net, NET_E_LOCAL_CONNECTION_BROKEN, "");
		NET_DBG(("NET_accept: WaitForSingleObject(EventC) error: %d\n",
			 GetLastError()));
		net->id.shmem.pid = 0;
		return;
	}
	NET_DBG(("NET_accept: Got EventC\n"));
	server_locked = FALSE;

	net->id.shmem.bufferp = &NET_mem->buffers[NET_mem->cur_index];
	net->id.shmem.break_connectionp = 
		&NET_mem->break_connections[NET_mem->cur_index];
 	NET_DBG(("NET_accept: bufferp:0x%x *bufferp:0x%x break_connectionp:0x%x\n",
			 net->id.shmem.bufferp, NET_GET_PTR(net->id.shmem.bufferp, char),
			 net->id.shmem.break_connectionp));
	hClient = NET_mem->hClient;
	hEventS = NET_mem->hEventS;
	NET_DBG(("NET_accept: hClient %d hEventS %d\n",hClient, hEventS));
	net->id.shmem.pid = (int) hClient;
	NET_DBG(("NET_accept: Setting EventS\n"));
	server_locked = TRUE;
	status = SetEvent(hEventS);
	if (status == FALSE)
	{
		NET_error_local(net, NET_E_LOCAL_CONNECTION_BROKEN, "");
		NET_DBG(("NET_accept: SetEventS failed\n"));
		net->id.shmem.pid = 0;
		return;
	}

	/*
	**	Create thread to wait for death of client.
	**	pass hClient not its address since on stack and can't count on
	**  it still being valid by time new thread references it
	*/
	hThread = CreateThread(NULL, 0,
						(LPTHREAD_START_ROUTINE)NET_wait_for_client,
						(LPVOID)hClient, 0, &idThread);
	if (hThread == NULL)
	{
		NET_error_local(net, NET_E_LOCAL_CONNECTION_BROKEN, "");
		NET_DBG(("NET_accept_local: CreateThread failed\n"));
		net->id.shmem.pid = 0;
		return;
	}
	NET_DBG(("NET_accept_local: CreateThread successful\n"));
#endif
	NET_DBG(("NET_accept_local: complete\n"));
}

/******************************************************************************/

#if defined(unix)
static void NET_alarm_func_local(
	int	sig)
{
	NET_DBG(("NET_alarm_func_local(sig :%d)\nNET_E_TIMEOUT\n", sig));
}
#endif

/******************************************************************************/

#if defined(unix)
static int NET_semop(
	int				semid,
	struct sembuf	*sops,
	unsigned		nsops,
	int             blocking)
{
	int		status;
	void 	(*alarm_func_ptr)(int) = NULL;
	
	NET_DBG(("NET_semop(semid: %d, sops: 0x%x, nsops: %d, blocking: %d)\n", 
		semid, sops, nsops, blocking));
	if (blocking > 0)
	{
		alarm_func_ptr = NET_sigset(SIGALRM,NET_alarm_func_local);
		alarm(blocking);
	}
	
	status = semop(semid,sops,nsops);
	
	if (blocking > 0)
	{
		alarm(0);
		NET_sigset(SIGALRM,alarm_func_ptr);
	}
	NET_DBG(("NET_semop: complete\n"));
	return status;
}
#endif

/******************************************************************************/

extern void NET_write_local(
	net_s	*net,
	char	*user_buffer,
	int		*len,
	int		blocking,
	int		send_length_flag)
{
	char			*data;

	NET_DBG(("NET_write_local(net:0x%x user_buffer:0x%x *len:%d blocking:%d send_length_flag:%d)\n",
			 net, user_buffer, *len, blocking, send_length_flag));

	/*
	** Make sure semaphore is locked before we write
	*/
	NET_lock_sem(net,blocking);
	if (net->error_code != NET_SUCCESS)
	{
		*len = 0;
		NET_DBG(("NET_write_local: error locking sem\n"));
		return;
	}

	/*
	** check if buffer is large enough
	*/
#if defined(__clipper__) || defined(sun) || defined(sco) || defined(__hpux__)
	if ((unsigned)(*len) > (*net->id.shmem.bufferp)->size)
	{
		NET_DBG(("NET_write_local: increasing the buffer size\n"));
		NET_free_blocks(net, *net->id.shmem.bufferp);
		if (net->error_code != NET_SUCCESS)
		{
			*len = 0;
			NET_DBG(("NET_write_local: unable to free buffer\n"));
			return;
		}
		*net->id.shmem.bufferp = NET_get_block(net, *len);
		if (net->error_code != NET_SUCCESS)
		{
			*len = 0;
			NET_DBG(("NET_write_local: unable to get new buffer\n"));
			net->id.shmem.bufferp = (net_block_info_s **)0;
			return;
		}
	}

	(*net->id.shmem.bufferp)->len = *len;
	data = (char *)(*net->id.shmem.bufferp) + NET_HEADER_SIZE;
	NET_DBG(("NET_write_local: copying %d bytes to internal buffer\n", *len));
	memcpy(data, user_buffer, *len);
#endif
#if defined(WIN32) || defined(__Sol2__) || defined(Soli)
	if ((unsigned)(*len) > 
		NET_GET_PTR(net->id.shmem.bufferp, net_block_info_s)->size)
	{
		NET_DBG(("NET_write_local: increasing the buffer size\n"));
		NET_free_blocks(net, NET_GET_PTR(net->id.shmem.bufferp,
										net_block_info_s));
		if (net->error_code != NET_SUCCESS)
		{
			*len = 0;
			NET_DBG(("NET_write_local: unable to free buffer\n"));
			return;
		}
		NET_SET_PTR(NET_get_block(net, *len), net->id.shmem.bufferp,
					net_block_info_s);
		if (net->error_code != NET_SUCCESS)
		{
			*len = 0;
			NET_DBG(("NET_write_local: unable to get new buffer\n"));
			net->id.shmem.bufferp = (net_block_info_s **)0;
			return;
		}
	}

	(NET_GET_PTR(net->id.shmem.bufferp, net_block_info_s))->len = *len;
	data = NET_GET_PTR(net->id.shmem.bufferp, char) + NET_HEADER_SIZE;
	NET_DBG(("NET_write_local: copying %d bytes to internal buffer\n",
			 *len));
	memcpy(data, user_buffer, *len);
	NET_DBG(("NET_write_local: &shmem 0x%x shmem 0x%x &len 0x%x *len%d\n",
			 net->id.shmem.bufferp, data,
			 &(NET_GET_PTR(net->id.shmem.bufferp, net_block_info_s))->len,
			 (NET_GET_PTR(net->id.shmem.bufferp, net_block_info_s))->len));
#endif
	
	NET_unlock_sem(net,blocking);
	if (net->error_code != NET_SUCCESS)
	{
		*len = 0;
		NET_DBG(("NET_write_local: error unlocking sem\n"));
		return;
	}

	NET_DBG(("NET_write_local: complete\n"));
}

/******************************************************************************/

extern void NET_read_local(
	net_s	*net,
	char	*user_buffer,
	int		*len,
	int		blocking,
	int		receive_length_flag)
{
	char			*data;

	NET_DBG(("NET_read_local(net:0x%x user_buf:0x%x len:0x%x blocking:%d rec_len:%d)\n",
			net, user_buffer, len, blocking, receive_length_flag));

	NET_unlock_sem(net,blocking);
	if (net->error_code != NET_SUCCESS)
	{
		*len = 0;
		NET_DBG(("NET_read_local: error unlocking sem\n"));
		return;
	}
	NET_lock_sem(net,blocking);
	if (net->error_code != NET_SUCCESS)
	{
		*len = 0;
		NET_DBG(("NET_read_local: error locking sem\n"));
		return;
	}
 	NET_DBG(("NET_read_local: shmem.bufferp:0x%x\n",net->id.shmem.bufferp));
#if defined(__clipper__) || defined(sun) || defined(sco) || defined(__hpux__)
	*len = (*net->id.shmem.bufferp)->len;
	data = (char *)(*net->id.shmem.bufferp) + NET_HEADER_SIZE;
	NET_DBG(("NET_read_local: copying %d bytes from internal buffer\n", *len));
#endif
#if defined(WIN32) || defined(__Sol2__) || defined(Soli)
 	NET_DBG(("NET_read_local: *bufferp:0x%x\n",
			 NET_GET_PTR(net->id.shmem.bufferp, char)));
	*len = (NET_GET_PTR(net->id.shmem.bufferp, net_block_info_s))->len;
	data = NET_GET_PTR(net->id.shmem.bufferp, char) + NET_HEADER_SIZE;
	NET_DBG(("NET_read_local: copying %d bytes from internal buffer\n",
			 *len));
#endif
	memcpy(user_buffer, data, *len);

	NET_DBG(("NET_read_local: complete\n"));
}

/******************************************************************************/

extern void NET_close_local(
	net_s *net)
{
	NET_DBG(("NET_close_local(net:0x%x)\n", net));

	if (net->cs_flag == CLIENT_FLAG)
	{
#if defined(__clipper__) || defined(sun) || defined(sco) || defined(__hpux__)
		if (net->id.shmem.bufferp && *net->id.shmem.bufferp)
		{
			NET_free_blocks(net, *net->id.shmem.bufferp);
			if (net->error_code != NET_SUCCESS)
			{
				NET_DBG(("NET_close_local: unable to free buffer\n"));
				*net->id.shmem.bufferp = (net_block_info_s *)0;
				return;
			}
			*net->id.shmem.bufferp = (net_block_info_s *)0;
		}
		/* if (net->id.shmem.semnum)
		{ removed because in remote case semnum can be 0...*/

			if (NET_mem->sem_alloc | (1 << net->id.shmem.semnum))
			{
				NET_mem->attach_count--;
				NET_mem->sem_alloc &= ~(1 << net->id.shmem.semnum);
	
				NET_DBG(("NET_close_local 0x%x: freed sem:%d\n",
					net,net->id.shmem.semnum));
			}
		/*  probably not needed...	net->id.shmem.semnum = 0;
		} */
#endif
#if defined(WIN32) || defined(__Sol2__) || defined(Soli)
		if (net->id.shmem.bufferp &&
			NET_GET_PTR(net->id.shmem.bufferp, char))
		{
			NET_free_blocks(net,
					NET_GET_PTR(net->id.shmem.bufferp, net_block_info_s));
			if (net->error_code != NET_SUCCESS)
			{
				NET_DBG(("NET_close_local: unable to free buffer\n"));
				NET_SET_PTR(net->id.shmem.bufferp, net->id.shmem.bufferp,
							net_block_info_s);
				return;
			}
			NET_SET_PTR(net->id.shmem.bufferp, net->id.shmem.bufferp,
						net_block_info_s);
		}
/* Ashley 7/1/96 - Fix for TR 439407587 - Dianne F. put this in revision 1.11 but the 
   change was lost in the 5.3.1 merge in version 1.12.
*/
		 if (NET_mem) NET_mem->attach_count--;
#endif
	}
	NET_DBG(("NET_close_local: complete\n"));
}

/******************************************************************************/

extern void NET_addr_local(
	net_s	*net,
	char	*nodename,
	char	*netaddr,
	int		*len)
{
	nodename = nodename; /* shut up the compiler */
	netaddr = netaddr; /* shut up the compiler */
	len = len; /* shut up the compiler */
	net->error_code = NET_E_NOT_IMPLEMENTED;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

/******************************************************************************/

/* get the local symbolic node name */

extern void NET_node_local(
	net_s	*net,
	char	*nodename,
	int		*len)
{
#if defined(unix)
	struct utsname name;
#endif
#if defined(WIN32)
	char   buffer[MAX_COMPUTERNAME_LENGTH+1];
	LPTSTR computername_ptr = buffer;
	DWORD  computername_len;
#endif

	NET_DBG(("NET_node_local(net:0x%x nodename:0x%x *len:%d)\n",
		net, nodename, *len));

#if defined(unix)
	if (uname(&name) < 0)
	{
		NET_error_local(net, NET_E_INVALID_NODE, "");
		return;
	}
	strncpy(nodename, name.nodename, *len);
#endif
#if defined(WIN32)
	if (GetComputerName(computername_ptr, &computername_len) == FALSE)
	{
	        NET_DBG(("NET_node_local: GetComputerName error %d\n",
			 GetLastError()));
		NET_error_local(net,NET_E_INVALID_NODE,"");
		return;
	}
	RIScom_strncpy(nodename, buffer, *len);
#endif

	NET_DBG(("NET_node_local: nodename:<%s>\nNET_node_local: complete\n",
		nodename));
}

/******************************************************************************/

extern void NET_get_file_local(
	net_s			*net,
	net_connect_s	*connect_info,
	char			*remote_file,
	char			*local_file)
{
#if defined(unix)
	char buffer[sizeof("cp   2>&1") + MAX_PATH_SIZE + MAX_PATH_SIZE + 100];
#endif
#if defined (WIN32)
	DWORD last_error; /* to store the last_error */ 
	LPVOID lpMessageBuffer; /* stores the last error string */
#endif

      NET_DBG(("NET_get_file_local(net:0x%x remote_file:<%s> local_file:<%s>)\n",
               net, remote_file, local_file));

	connect_info = connect_info; /* shut up the compiler */
	
#if defined(unix)
	sprintf(buffer,"cp %s %s 2>&1",remote_file,local_file);
#if defined (sun)
    NET_execute_command(net,buffer,NET_E_GET_FILE_ERROR,NET_error_local,
		"No such file",NET_E_FILE_NOT_FOUND);
#elif defined(unix)
    NET_execute_command(net,buffer,NET_E_GET_FILE_ERROR,NET_error_local,
		"cannot access",NET_E_FILE_NOT_FOUND);
#endif
	NET_ERRCHK(net);
#endif

#if defined(WIN32)
/*------------------------------------------------------------------------------
**	The following changes were made so that INTERNATIONALIZATION effort is not 
**	affected by the hard-coded strings we check for. Local get_file on NT can
**	be done using CopyFile and the system error and error_string can be found
**	instead of calling NET_execute_command which calls CreateProcess to execute
**	a "cmd /c copy x y". Radha 02/06/95
------------------------------------------------------------------------------*/
    if (!CopyFile(remote_file,local_file,FALSE))
    {
		last_error = GetLastError();
		FormatMessage(
			FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM,
			NULL, last_error, MAKELANGID(LANG_NEUTRAL, SUBLANG_SYS_DEFAULT),
			(LPTSTR) &lpMessageBuffer, 0, NULL);
		if (last_error == ERROR_FILE_NOT_FOUND)
		{
		 	NET_DBG(("NET_get_file_local: the copyfile failed <%d> <%s>\n",
					last_error,lpMessageBuffer));	
		NET_error_local(net,NET_E_FILE_NOT_FOUND, lpMessageBuffer);
		}
		else
		{
		 	NET_DBG(("NET_get_file_local: the copyfile failed <%d> <%s>\n",
					last_error,lpMessageBuffer));	
			NET_error_local(net,NET_E_GET_FILE_ERROR, lpMessageBuffer);
		}
    }
	NET_ERRCHK(net);
#endif
	NET_DBG(("NET_get_file_local: complete\n"));
}

/******************************************************************************/

extern void NET_put_file_local(
	net_s			*net,
	net_connect_s	*connect_info,
	char			*local_file,
	char			*remote_file)
{
#if defined(unix)
	char buffer[sizeof("cp   2>&1") + MAX_PATH_SIZE + MAX_PATH_SIZE + 100];
#endif

#if defined (WIN32)
	DWORD last_error; /* to store the last_error */ 
	LPVOID lpMessageBuffer; /* stores the last error string */
#endif
	NET_DBG(("NET_put_file_local(net:0x%x remote_file:<%s> local_file:<%s>)\n",
		net, remote_file, local_file));

	connect_info = connect_info; /* shut up the compiler */
#if defined(unix)
	sprintf(buffer,"cp %s %s 2>&1",local_file,remote_file);
	NET_execute_command(net,buffer,NET_E_PUT_FILE_ERROR,NET_error_local,0,0);
	NET_ERRCHK(net);
#endif

#if defined(WIN32)
/*---------------------------------------------------------------------------------
**	The following changes were made so that INTERNATIONALIZATION effort is not 
**	affected by the hard-coded strings we check for. Local put_file on NT can
**	be done using CopyFile and the system error and error_string can be found
**	instead of calling NET_execute_command which calls CreateProcess to execute
**	a "cmd /c copy x y". Radha 02/06/95
---------------------------------------------------------------------------------*/
   	if (!CopyFile(local_file,remote_file,FALSE))
	{
		last_error = GetLastError();
		FormatMessage(
		FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM,
		NULL, last_error, MAKELANGID(LANG_NEUTRAL, SUBLANG_SYS_DEFAULT),
		(LPTSTR) &lpMessageBuffer, 0, NULL);
		if (last_error == ERROR_FILE_NOT_FOUND)
		{
 			NET_DBG(("NET_put_file_local: copyfile failed <%d> <%s>\n",
					last_error,lpMessageBuffer));	
			NET_error_local(net,NET_E_FILE_NOT_FOUND, lpMessageBuffer);
		}
		else
		{
	 		NET_DBG(("NET_put_file_local: copyfile failed <%d> <%s>\n",
						last_error,lpMessageBuffer));	
			NET_error_local(net,NET_E_PUT_FILE_ERROR, lpMessageBuffer);
		}
   	}
	NET_ERRCHK(net);
#endif
	NET_DBG(("NET_put_file_local: complete\n"));
}

/******************************************************************************/

extern void NET_get_lock_file_local(
	net_s			*net,
	net_connect_s	*connect_info,
	char			*remote_file)
{
#if defined(unix)
	char buffer[sizeof("rm  </dev/null 2>&1") + MAX_PATH_SIZE + 100];
#endif

	NET_DBG(("NET_get_lock_file_local(net:0x%x remote_file:<%s>)\n",
		net, remote_file));

	connect_info = connect_info; /* shut up the compiler */
#if defined(unix)
	sprintf(buffer,"rm %s </dev/null 2>&1",remote_file);
#if defined(__clipper__) || defined(sco) || defined(__hpux__)
	NET_execute_command(net,buffer,NET_E_GET_LOCK_FILE_ERROR, NET_error_local,
		"non-existent",NET_E_NO_LOCK);
#elif defined (sun) || defined(__Sol2__) || defined(Soli)
	NET_execute_command(net,buffer,NET_E_GET_LOCK_FILE_ERROR, NET_error_local,
		"No such file",NET_E_NO_LOCK);
#endif
	NET_ERRCHK(net);
#endif
#if defined(WIN32)
/*  popen/pipe style
	if (RIScom_get_platform() == IS_CHICAGO)
		sprintf(buffer,"command.com /c del %s",remote_file);
	else
		sprintf(buffer,"cmd /c del %s",remote_file);
	NET_execute_command(net,buffer,NET_GET_LOCK_FILE_ERROR, NET_error_local,
		"File Not Found",NET_E_NO_LOCK);
	NET_ERRCHK(net);
*/
	NET_DBG(("NET_get_lock_file_local: unlink %s\n", remote_file));
	_unlink(remote_file);
#endif

	NET_DBG(("NET_get_lock_file_local: complete\n"));
}

/******************************************************************************/

extern void NET_put_lock_file_local(
	net_s			*net,
	net_connect_s	*connect_info,
	char			*remote_file)
{
#if defined(unix)
	char buffer[sizeof("cp /dev/null  2>&1") + MAX_PATH_SIZE + 100];
#endif
#if defined(WIN32)
	FILE 	*tfp;
#endif

	NET_DBG(("NET_put_lock_file_local(net:0x%x remote_file:<%s>)\n",
		net, remote_file));

	connect_info = connect_info; /* shut up the compiler */

#if defined(unix)
	sprintf(buffer,"cp /dev/null %s 2>&1",remote_file);
	NET_execute_command(net,buffer,NET_E_PUT_LOCK_FILE_ERROR,NET_error_local,0,0);
	NET_ERRCHK(net);
#endif
#if defined(WIN32)
	if ((tfp = fopen(remote_file, "w+")) == NULL)
	{
		NET_DBG(("NET_put_lock_file_local: error fopening %s file\n",
				remote_file));
		return;
	}
	fclose(tfp);
#endif

	NET_DBG(("NET_put_lock_file_local: complete\n"));
}

/******************************************************************************/

extern void NET_remove_file_local(
	net_s			*net,
	net_connect_s	*connect_info,
	char			*remote_file)
{
#if defined(unix)
	char buffer[sizeof("rm  </dev/null 2>&1") + MAX_PATH_SIZE + 100];
#endif

	NET_DBG(("NET_remove_file_local(net:0x%x remote_file:<%s>)\n",
		net, remote_file));

	connect_info = connect_info;  /* shut up the compiler */
#if defined(unix)
	sprintf(buffer,"rm %s </dev/null 2>&1",remote_file);
#if defined(__clipper__) || defined(sco) || defined(__hpux__)
	NET_execute_command(net,buffer,NET_E_REMOVE_FILE_ERROR, NET_error_local,
    	"non-existent",NET_E_FILE_NOT_FOUND);
#elif defined(sun) || defined(__Sol2__) || defined(Soli)
	NET_execute_command(net,buffer,NET_E_REMOVE_FILE_ERROR, NET_error_local,
    	"No such",NET_E_FILE_NOT_FOUND);
#endif
	NET_ERRCHK(net);
#endif
#if defined(WIN32)
/*  popen/pipe style
	if (RIScom_get_platform() == IS_CHICAGO)
		sprintf(buffer,"command.com /c del %s",remote_file);
	else
		sprintf(buffer,"cmd /c del %s",remote_file);
	NET_execute_command(net,buffer,NET_E_REMOVE_FILE_ERROR, NET_error_local,
		"File Not Found",NET_E_FILE_NOT_FOUND);
	NET_ERRCHK(net);
*/
	_unlink(remote_file);
#endif

	NET_DBG(("NET_remove_file_local: complete\n",net));
}

/******************************************************************************/

extern void NET_error_local(
	net_s	*net,
	int		code,
	char	*string)
{
	int i;
	
	NET_DBG(("NET_error_local(net:0x%x code:%d string:<%s>)\n",
		net, code, string ? string : "NULL"));

	/*
	** -- fill in generic code --
	*/

	net->error_code = code;
	strcpy(net->error_string,NET_error_msg(code));

	/*
	** -- fill in protocol specific code --
	*/

	switch((unsigned int)code)
	{
		case NET_E_SEM_INIT_FAIL:
		case NET_E_CANT_FORK_SERVER:
		case NET_E_WRITE_ERROR:
		case NET_E_READ_ERROR:
			if (errno)
			{
				net->net_error_code = errno;
				strcpy(net->net_error_string, strerror(errno));
			}
			else
			{
				net->net_error_code = 0;
				net->net_error_string[0] = '\0';
			}
			break;
/*----------------------------------------------------------------------
 * SPECIAL INTERNATIONALIZATION NOTE:
 *	At this time no supported multibyte language can contain a control
 *	character as a bit pattern for a particular character.  It is
 *  ok to compare a byte to a control character at this time.  This wil
 *  need to be modified if a new multibyte language is introduced that
 *  allows for a control character to be a leadbyte or second byte of
 *  that character.
 *
 *	Paula Blohm - 10/10/94 
 *
 *  0xD - is the hex value for a carriage return.  Refer to revision
 *    	  notes for more information.  Paula - 1/10/95
----------------------------------------------------------------------*/
		default:
			net->net_error_code = 0;
			for (i=0;i < sizeof(net->net_error_string)-1 && string[i];i++)
			{
				if (string[i]=='\n' || string[i]=='\t' || string[i]== 0xD)
					net->net_error_string[i] = ' ';
				else
					net->net_error_string[i] = string[i];
			}
			net->net_error_string[i] = '\0';
			break;
	}
	NET_DBG(("NET_error_local: net->error_string:<%s>\n", net->error_string));
	NET_DBG(("NET_error_local: net->net_error_string:<%s>\n",
		net->net_error_string));
	NET_DBG(("NET_error_local: complete\n"));
}

/******************************************************************************/

extern void NET_unlock_sem(
	net_s			*net,
	int				blocking)
{
#if defined(unix)
	int				semnum = net->id.shmem.semnum;
	struct sembuf	unlock;
	union semun		arg;
#endif
#if defined(WIN32)
	int				index = net->id.shmem.semnum;
	BOOL			status, *lock;
	HANDLE			hEvent;
#endif

	NET_DBG(("NET_unlock_sem(net:0x%x blocking:%d)\n", net, blocking));

#if defined(unix)
	if (is_sem_locked[semnum])
	{
		arg.val = 0;
		NET_DBG(("NET_unlock_sem: sem:%d semctl val:%d\n",
		 semnum, semctl(NET_mem->semid, semnum, GETVAL, arg)));

		if (net->cs_flag == CLIENT_FLAG)
		{
			/*
			**	check that server is allocated
			*/
			if (!net->id.shmem.pid)
			{
				NET_error_local(net, NET_E_SERVER_NOT_ALLOCATED, "");
				return;
			}

			/*
			**	set client semaphore operation
			*/
			unlock.sem_num = (ushort)semnum;
			unlock.sem_op = -1;
			unlock.sem_flg = (short)(blocking >= 0 ? 0 : IPC_NOWAIT);
		}
		else
		{
			/*
			**	set server semaphore operation
			*/
			unlock.sem_num = (ushort)semnum;
			unlock.sem_op = 2;
			unlock.sem_flg = (short)(blocking >= 0 ? 0 : IPC_NOWAIT);
		}

		/*
		**	attempt to release semaphore, retry if interrupted
		*/

		NET_DBG(("NET_unlock_sem:  sem_op:%d\n", unlock.sem_op));

		while (1)
		{
			if (*net->id.shmem.break_connectionp)
			{
				NET_DBG(("NET_unlock_sem: break_connection flag set\n"));
				NET_error_local(net, NET_E_LOCAL_CONNECTION_BROKEN, "");
				return;
			}

			if (!NET_semop(NET_mem->semid,&unlock,1,blocking))
			{
				break;
			}

			NET_DBG(("NET_unlock_sem: attempted unlock sem:%d errno:%d (val:%d)\n",
				net, semnum, errno, semctl(NET_mem->semid, semnum, GETVAL, arg)));

			if (errno == EAGAIN && blocking < 0)
			{
				NET_error_local(net, NET_E_TIMEOUT, "");
				return;
			}

			if (errno == EINTR && blocking != 0)
			{
				NET_error_local(net, NET_E_TIMEOUT, "");
				return;
			}

			if (errno != EINTR)
			{
				NET_error_local(net, NET_E_WRITE_ERROR, "");
				return;
			}

			/* We were interrupted by a signal */
			if (!net->connection_open)
			{
				NET_error_local(net, NET_E_WRITE_ERROR, "");
				return;
			}

			NET_DBG(("NET_unlock_sem: Interupt... continuing\n"));
		}
		is_sem_locked[semnum] = 0;

		NET_DBG(("NET_unlock_sem: unlocked sem:%d semctl val:%d\n",
			semnum, semctl(NET_mem->semid,semnum,GETVAL, arg)));
	}
#endif
#if defined(WIN32)
	
	if (net->cs_flag == CLIENT_FLAG)
	{
		hEvent = NTevents[index].EventC;
		lock = &NTevents[index].client_locked;
	}
	else
	{
		hEvent = hEventS;
		lock = &server_locked;
	}
	NET_DBG(("NET_unlock_sem:  hEvent:%d locked:%d\n", hEvent, *lock));
	if (!*lock)
	{
		*lock = TRUE;
		status = SetEvent(hEvent);
		if (status == FALSE)
		{
			NET_error_local(net, NET_E_WRITE_ERROR, "");
			NET_DBG(("NET_unlock_sem: SetEvent error: %d\n",
						GetLastError()));
			return;
		}
		NET_DBG(("NET_unlock_sem:  hEvent:%d locked:%d\n", hEvent, *lock));
	}
#endif

	NET_DBG(("NET_unlock_sem: complete\n"));
}

/******************************************************************************/

extern void NET_lock_sem(
	net_s			*net,
	int				blocking)
{
#if defined(unix)
	int				semnum = net->id.shmem.semnum;
	struct sembuf	lock;
	union semun		arg;
#endif

#if defined(WIN32)
	int				index = net->id.shmem.semnum;
	BOOL			status, *lock;
	HANDLE			hEvent;
	int				*died;
#endif

	NET_DBG(("NET_lock_sem(net:0x%x blocking:%d)\n", net, blocking));

#if defined(unix)
	if (!is_sem_locked[semnum])
	{
		arg.val = 0;
		NET_DBG(("NET_lock_sem: attempting lock sem:%d semctl val:%d\n",
			semnum, semctl(NET_mem->semid,semnum,GETVAL, arg)));

		if (net->cs_flag == CLIENT_FLAG)
		{
			/*
			**	check that server is allocated
			*/
			if (!net->id.shmem.pid)
			{
				NET_error_local(net, NET_E_SERVER_NOT_ALLOCATED, "");
				return;
			}

			/*
			**	set client semaphore operation
			*/
			lock.sem_num = (ushort)semnum;
			lock.sem_op = -1;
			lock.sem_flg = (short)(blocking >= 0 ? 0 : IPC_NOWAIT);
		}
		else
		{
			/*
			**	set server semaphore operation
			*/
			lock.sem_num = (ushort)semnum;
			lock.sem_op = 0;
			lock.sem_flg = (short)(blocking >= 0 ? 0 : IPC_NOWAIT);
		}

		/*
		**	attempt to get semaphore, retry if interrupted
		*/
		NET_DBG(("NET_lock_sem: sem_op:%d\n", lock.sem_op));
		while (1)
		{
			if (*net->id.shmem.break_connectionp)
			{
				NET_DBG(("NET_lock_sem: break_connection flag set\n"));
				NET_error_local(net, NET_E_LOCAL_CONNECTION_BROKEN, "");
				return;
			}

			if (!NET_semop(NET_mem->semid,&lock,1,blocking))
			{
				break;
			}

			NET_DBG(("NET_lock_sem: attempted lock sem:%d errno:%d val:%d\n",
				semnum, errno, semctl(NET_mem->semid,semnum,GETVAL,
				arg)));

			if (errno == EAGAIN && blocking < 0)
			{
				NET_error_local(net, NET_E_TIMEOUT, "");
				return;
			}

			if (errno == EINTR && blocking != 0)
			{
				NET_error_local(net, NET_E_TIMEOUT, "");
				return;
			}
			
			if (errno != EINTR)
			{
				NET_error_local(net, NET_E_READ_ERROR, "");
				return;
			}

			/* We were interrupted by a signal */

			if (!net->connection_open)
			{
				NET_error_local(net, NET_E_READ_ERROR, "");
				return;
			}
			NET_DBG(("NET_lock_sem: Interupt... continuing\n"));
		}
		is_sem_locked[semnum] = 1;
	}
	NET_DBG(("NET_lock_sem: got semnum:%d\n", semnum));
#endif
#if defined(WIN32)
	if (net->cs_flag == CLIENT_FLAG)
	{
		hEvent = NTevents[index].EventS;
		lock = &NTevents[index].client_locked;
		died = &NTevents[index].server_died;
	}
	else
	{
		hEvent = hEventC;
		lock = &server_locked;
		died = &client_died;
	}
	NET_DBG(("NET_lock_sem: hEvent:%d locked:%d\n", hEvent, *lock));
	if (*lock)
	{
		do
		{
/*
**  Changed the timeout parameter for WaitForSingleObject
**  to 1500 from 500 to fix TR# 249403313. RAJU 08/18/94
*/
			status = WaitForSingleObject(hEvent, 1500);
/*
**  Added break if blocking < 0 to fix TR# 439601363 & TR# 439601364
**  Should not be ignoring timeout if blocking is < 0. Sreedhar 7/10/96
*/
			if (status == WAIT_TIMEOUT && blocking < 0)
			{
				break;
			}

		} while( !(*died) && status == WAIT_TIMEOUT);
		if (*died)
		{
			NET_DBG(("NET_lock_sem: peer process died\n"));
			NET_error_local(net, NET_E_LOCAL_CONNECTION_BROKEN, "");
			return;
		}
		else
		{
			if (status != NO_ERROR)
			{
				NET_DBG(("NET_lock_sem: WaitForSingleObject error %d\n",
						GetLastError()));
/*
**  Added timeout error if blocking < 0 to fix TR# 439601363 & TR# 439601364
**  Should not be ignoring timeout if blocking is < 0. Sreedhar 7/10/96
*/
				if (status == WAIT_TIMEOUT && blocking < 0)
				{
					NET_error_local(net, NET_E_TIMEOUT, "");
					return;
				}
				else
				{
					NET_error_local(net, NET_E_READ_ERROR, "");
					return;
				}
			}
		}
		*lock = FALSE;
	}
	NET_DBG(("NET_lock_sem: got lock Event:%d locked:%d\n", hEvent, *lock));
#endif

	NET_DBG(("NET_lock_sem: complete\n"));
}

/******************************************************************************/
