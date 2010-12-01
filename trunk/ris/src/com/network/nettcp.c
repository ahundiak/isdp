/*
**	NAME:                                           nettcp.c
**	AUTHORS:                                        Terry McIntyre
**	CREATION DATE:                                  11/89
**	ABSTRACT:
**    Various routines for sending and receiving message buffers
**    across the TCP/IP network interface.
**
**	REVISION HISTORY:
**
**  08/94: Raju
**         Changing the double quotes to single quotes in echo clause
**         of all ftp commands. This fixes TR# 249302469.
**
**	10/94: Radha Shivakumar & Rick Kramer
**         Fixed the recv failed problem in win32s. 
**         1) The solution involved adding the setsockopt call before 
**            the recv call in NET_read_tcp to set the receive buffer 
**            option to the MAX_TCP_BUFFER_SIZE.
**
**         2) Additional requirements need to be met with for this fix.
**         (a)PC-NFS 5.1a will have the fix for setsockopt call crash
**            problem.
**         (b)PC-TCP2.3: Need to up the MinimumCopySpace to atleast
**            28 in system.ini file.
**         (c)PC-TCP3.0: Need to up the MinimumCopySpace to atleast
**            28 in pctcp.ini file. 
**
**	11/94: Paula
**         Modified the NET_error_tcp function to handle INTERNATIONALIZATION.
**         Changed the NET_strcmp_ic function to handle INTERNATIONALIZATION.
**
**	01/95: Paula
**         Changed the carriage return '^M' to 0xD.  When editing file in 
**         nt, the editor converted the '^M' to an actual carriage return.
**		
**	01/95: Surjit Sahoo
**         1) Now, verbose mode is turned on for unix during ftp.
**            (by using -v flag and removing 'verbose' from script)
**            (see also netshare.c)
**
**         2) For all unix platforms, backslashes are accepted as NT
**            filenames by calling ReplaceBackslash(file_name, new_name)
**            This fixes TR# 439500088.
**
**	06/96: Ashley Burns
**         Some implementations Winsock may not support particular socket
**         options specified by setsockopt().  When we get a WSAEINVAL
**         return value then ignore and continue. Fix for TR 439601280
**	07/96: Ashley Burns
**         added more checks for WSAEINVAL and WSAENOPROTOOPT
**
**	07/96: Surjit Sahoo
**         Modified the routine ReplaceBackslash() and renamed it as
**         adjust_filename(), so that for 'ftp' purpose, all UNIX and
**         NT ftp clients use filenames enclosed in double-quotes.
**         This handles NT files with spaces in their name (e.g.
**         "c:\program files\common files\intergraph\schemas")
**         This fixes TR# 439601492 and 439601595.
**
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <signal.h>
#include <fcntl.h>
#include <sys/file.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>
#include <netdb.h>

#include "risnet.h"

static int      NET_timed_out = 0;
static short    once_thru_flag = 0;
static void (*NET_signal_ptr)();

static void adjust_filename(char *old_path, char new_path[]);

/******************************************************************************/
static void NET_signal_handle(int signo)
{
	NET_DBG(("NET_signal_handle: signo:%d\n", signo));
	NET_timed_out = 1;
}
/******************************************************************************/

extern void NET_connect_tcp(net_s *net, net_connect_s *connect_info)
{
	struct sockaddr_in server;
	int					optval;

	NET_DBG(("NET_connect_tcp(net:0x%x connect_info:0x%x)\n",
		net, connect_info));

#if defined(unix) || defined(DOS)
	net->id.tcp.user.socket = -1;

	memset((char *)&server, 0, sizeof(server));
	server.sin_family = AF_INET;

	server.sin_port = htons(connect_info->tcp.port);
	server.sin_addr.s_addr = inet_addr(connect_info->tcp.address);

	if ((net->id.tcp.user.socket = NET_socket(AF_INET, SOCK_STREAM, 0)) == 
		(unsigned)(-1))
	{
		NET_error_tcp(net, NET_E_TCP_SOCKET, "");
		return;
	}

	NET_DBG(("NET_connect_tcp: starting server: addr:<%s> sock:%d prog:%d\n",
		inet_ntoa(server.sin_addr),net->id.tcp.user.socket,
		ntohs(server.sin_port)));

	NET_timed_out = 0;
#if defined(unix)
	NET_signal_ptr = NET_sigset(SIGALRM,NET_signal_handle);
	alarm(TCP_TIME_OUT);
#endif
	while (connect(net->id.tcp.user.socket, (struct sockaddr *)&server,
				sizeof(server)) == -1)
	{
		if (errno == ECONNREFUSED)
		{
#if defined(DOS)
			retry_count++;
			if (retry_count == 100)
				NET_timed_out = 1;
#endif
			NET_DBG(("NET_connect_tcp: connection refused, trying again\n"));
			if (NET_sys_close(net->id.tcp.user.socket) == -1)
			{
				NET_DBG(("NET_connect_tcp: close failed, errno:%d\n", errno));
#if defined(unix)
				alarm(0);
				NET_sigset(SIGALRM,NET_signal_ptr);
#endif
				net->id.tcp.user.socket = -1;
				if (errno == EINTR && NET_timed_out)
				{
					errno = ETIMEDOUT;
					NET_error_tcp(net, NET_E_CONNECT_ERROR, "");
				}
				else
				{
					NET_error_tcp(net, NET_E_TCP_SOCKET, "");
				}
				return;
			}
			if ((net->id.tcp.user.socket = 
				 NET_socket(AF_INET, SOCK_STREAM, 0)) == (unsigned)(-1))
			{
				NET_DBG(("NET_connect_tcp: socket failed, errno:%d\n", errno));
#if defined(unix)
				alarm(0);
				NET_sigset(SIGALRM,NET_signal_ptr);
#endif
				if (errno == EINTR && NET_timed_out)
				{
					errno = ETIMEDOUT;
					NET_error_tcp(net, NET_E_CONNECT_ERROR, "");
				}
				else
				{
					NET_error_tcp(net, NET_E_TCP_SOCKET, "");
				}
				return;
			}
		}
		else
		{
			NET_DBG(("NET_connect_tcp: connection failed, errno:%d\n", errno));
#if defined(unix)
			alarm(0);
			NET_sigset(SIGALRM,NET_signal_ptr);
#endif
			if (errno == EINTR && NET_timed_out)
			{
				errno = ETIMEDOUT;
			}
			NET_error_tcp(net, NET_E_CONNECT_ERROR, "");
			return;
		}

		if (NET_timed_out)
		{
#if defined(unix)
			alarm(0);
			NET_sigset(SIGALRM,NET_signal_ptr);
#endif
			errno = ETIMEDOUT;
			NET_error_tcp(net, NET_E_CONNECT_ERROR, "");
			return;
		}
	}
#if defined(unix)
	alarm(0);
	NET_sigset(SIGALRM,NET_signal_ptr);
#endif

#if defined(__hpux__)
	if (NET_fcntl(net->id.tcp.user.socket, F_SETFL, O_NONBLOCK) == -1)
#else
	if (NET_fcntl(net->id.tcp.user.socket, F_SETFL, FNDELAY) == -1)
#endif
	{
		NET_DBG(("NET_connect_tcp: NET_fcntl failed\n"));
		NET_error_tcp(net, NET_E_CONNECT_ERROR, "");
		return;
	}

#if defined(__clipper__)
	if (NET_ioctl(net->id.tcp.user.socket, I_TCPNAGLE, 0) < 0)
	{
		NET_DBG(("NET_connect_tcp: NET_ioctl failed\n"));
		NET_error_tcp(net, NET_E_CONNECT_ERROR, "");
		return;
	}
#endif
#if defined(sun) || defined(__Sol2__) || defined(Soli) || defined(__hpux__) || defined(__i386)
	/*
	** Set socket option TCP_NODELAY to true; disable Nagle algorithm 
	*/
	optval = 1;		/* nonzero is true */
	/*  setsockopt returns 0 on success; -1 on failure */
	if (setsockopt(net->id.tcp.user.socket, IPPROTO_TCP, TCP_NODELAY, 
					 (char *)&optval, sizeof(optval)))
	{
		NET_DBG(("%s,%d:NET_connect_tcp: setsockopt TCP_NODELAY error: %d\n",
				 __FILE__, __LINE__, errno));
		net->id.tcp.user.socket = 0;
		NET_error_tcp(net, NET_E_CONNECT_ERROR, "");
		return;
	}
#endif
#endif  /* if defined __clipper__ or sun or DOS or sco or hpux */

#if defined(WIN32)
	STARTUP(net);

	net->id.tcp.user.socket = (SOCKET)0;

	memset((char *)&server, 0, sizeof(server));
	server.sin_family = PF_INET;

	server.sin_port = htons((unsigned short)connect_info->tcp.port);
	server.sin_addr.s_addr = inet_addr(connect_info->tcp.address);

	if ((net->id.tcp.user.socket = socket(PF_INET, SOCK_STREAM, 0)) ==
		SOCKET_ERROR)
	{
		winsockerr = WSAGetLastError();
		NET_DBG(("NET_connect_tcp: socket call failed, LastError:%d\n",
			winsockerr));
		net->id.tcp.user.socket = (SOCKET)0;
		NET_error_tcp(net, NET_E_TCP_SOCKET, "");
		return;
	}

	NET_DBG(("NET_connect_tcp: starting server: addr:<%s> sock:%d prog:%d\n",
		inet_ntoa(server.sin_addr),net->id.tcp.user.socket,
		ntohs((unsigned short)server.sin_port)));

	if (connect(net->id.tcp.user.socket, (struct sockaddr *)&server,
				sizeof(server)) == SOCKET_ERROR)
	{
		winsockerr = WSAGetLastError();
		NET_DBG(("NET_connect_tcp: connection failed, LastError:%d\n",
			winsockerr));
		net->id.tcp.user.socket = (SOCKET)0;
		NET_error_tcp(net, NET_E_CONNECT_ERROR, "");
		return;
	}

	nonblocking = 1;
	if (ioctlsocket(net->id.tcp.user.socket, FIONBIO, &nonblocking) ==
		SOCKET_ERROR)
	{
		winsockerr = WSAGetLastError();
		NET_DBG(("NET_connect_tcp: ioctlsocket nonblocking, LastError:%d\n",
				 winsockerr));
		net->id.tcp.user.socket = (SOCKET)0;
		NET_error_tcp(net, NET_E_CONNECT_ERROR, "");
		return;
	}
	/*
	** Set socket option TCP_NODELAY to true; disable Nagle algorithm 
	*/
	optval = 1;		/* nonzero is true */
	if (setsockopt(net->id.tcp.user.socket, IPPROTO_TCP, TCP_NODELAY, 
					 (char *)&optval, sizeof(optval)) == SOCKET_ERROR)
	{
		/* 1996.03.08:TR439600333:Alan Barksdale:See _Windows_Socket_
		   _Network_Programming_, by B. Quinn and D. Shute
		   (ISBN:0-201-63372-8), "Appendix C:  Error Reference".  It
		   might be at "http://www.sockets.com".  The authors suggest
		   ignoring the error if the option is not available.  In
                   nettcp.c for RIS 5.0.1, this problem was handled by not
		   trying to set TCP_NODELAY on WIN32S machines. */
		
		/* Ashley - 7/11/96 - added WSAEINVAL */
		winsockerr = WSAGetLastError();
		if(WSAENOPROTOOPT == winsockerr || winsockerr == WSAEINVAL)
		{
			NET_DBG(("%s,%d:NET_connect_tcp: setsockopt TCP_NODELAY error : %d; just noting error because option not available on some WinSock implementations\n",
				__FILE__, __LINE__, winsockerr));
		}
		else
		{
			NET_DBG(("%s,%d:NET_connect_tcp: setsockopt TCP_NODELAY error : %d\n",
				__FILE__, __LINE__, winsockerr));
			net->id.tcp.user.socket = (SOCKET)0;
			NET_error_tcp(net, NET_E_CONNECT_ERROR, "");
			return;
		}
	}
#endif
	NET_DBG(("NET_connect_tcp: complete\n"));
}

/******************************************************************************/

extern void NET_accept_tcp(net_s *net)
{
#if defined(sun) || defined(__Sol2__) || defined(Soli) || defined(__hpux__) || defined(__clipper__) || defined(__i386)
	int					optval;
#endif
#if defined(WIN32) || defined(sco)
	int					optval;
	struct linger		linger;
#endif

	NET_DBG(("NET_accept_tcp(net:0x%x)\n", net));

#if defined(unix)

#if defined(__hpux__)
	if (NET_fcntl(net->id.tcp.server.infildes, F_SETFL, O_NONBLOCK) == -1)
#else
	if (NET_fcntl(net->id.tcp.server.infildes, F_SETFL, FNDELAY) == -1)
#endif
	{
		NET_DBG(("NET_accept_tcp: NET_fcntl failed\n"));
		NET_error_tcp(net, NET_E_CONNECT_ERROR, "");
		return;
	}
#if defined(__clipper__)
	if (NET_ioctl(net->id.tcp.server.outfildes, I_TCPNAGLE, 0) < 0)
	{
		NET_DBG(("NET_accept_tcp: NET_ioctl failed\n"));
		NET_error_tcp(net, NET_E_CONNECT_ERROR, "");
		return;
	}
#endif
#if defined(sun) || defined(__Sol2__) || defined(Soli) || defined(__hpux__) || defined(__i386)
	/*
	** Set socket option TCP_NODELAY to true; disable Nagle algorithm 
	*/
	optval = 1;		/* nonzero is true */
	/*  setsockopt returns 0 on success; -1 on failure */
	if (setsockopt(net->id.tcp.user.socket, IPPROTO_TCP, TCP_NODELAY, 
					 (char *)&optval, sizeof(optval)))
	{
		NET_DBG(("%s,%d:NET_connect_tcp: setsockopt TCP_NODELAY error: %d\n",
				 __FILE__, __LINE__, errno));
		net->id.tcp.user.socket = 0;
		NET_error_tcp(net, NET_E_CONNECT_ERROR, "");
		return;
	}
#endif
#endif  /* if defined clipper or sun or sco or Sol2 or hpux */

#ifdef vms
    NET_get_socket(net);
#endif

#if defined(sco)

	/*
	** Set socket option TCP_NODELAY to true; disable Nagle algorithm 
	*/
	optval = 1;		/* nonzero is true */
	if (setsockopt(net->id.tcp.server.outfildes, IPPROTO_TCP, TCP_NODELAY, 
		(char *)&optval, sizeof(int)) == -1)
	{
		NET_DBG(("%s,%d:NET_accept_tcp: setsockopt TCP_NODELAY error: %d\n",
				 __FILE__, __LINE__, errno));
		NET_error_tcp(net, NET_E_CONNECT_ERROR, "");
		return;
	}
	linger.l_onoff = 1;
	linger.l_linger = 60;
	if ( setsockopt(net->id.tcp.server.outfildes, SOL_SOCKET, SO_LINGER, 
			(char *)&linger, sizeof(linger)) == -1) {
		NET_DBG(("NET_accept_tcp: setsockopt SO_LINGER error: %d\n",
				 errno));
		NET_error_tcp(net, NET_E_CONNECT_ERROR, "");
		return;
	}
#endif
#if defined(sun) || defined(__Sol2__) || defined(Soli) || defined(__hpux__) || defined(__clipper__) || defined(sco) || defined(__i386)
	NET_DBG(("%s,%d:NET_connect_tcp:before 1st setsockopt SO_KEEPALIVE\n",
		__FILE__,__LINE__));
	/*
	** Set socket option SO_KEEPALIVE to true       -Goverdhan 9/26/95
	*/
	optval = 1;     /* nonzero is true */
	/*  setsockopt returns 0 on success; -1 on failure */
	if (setsockopt(net->id.tcp.user.socket, SOL_SOCKET, SO_KEEPALIVE,
			(char *)&optval, sizeof(optval)))
 	{
		NET_DBG(("NET_connect_tcp: setsockopt SO_KEEPALIVE error: %d\n",
							errno));
		net->id.tcp.user.socket = 0;
		NET_error_tcp(net, NET_E_CONNECT_ERROR, "");
		return;
	}
	NET_DBG(("%s,%d:NET_connect_tcp:before 2nd setsockopt SO_KEEPALIVE\n",
		__FILE__,__LINE__));
	/*
	** Set socket option SO_KEEPALIVE to true       -Goverdhan 9/26/95
	*/
	optval = 1;     /* nonzero is true */
	/*  setsockopt returns 0 on success; -1 on failure */
	if (setsockopt(net->id.tcp.server.infildes, SOL_SOCKET, SO_KEEPALIVE,
			(char *)&optval, sizeof(optval)))
	{
		NET_DBG(("NET_connect_tcp: setsockopt SO_KEEPALIVE error: %d\n",
							errno));
		net->id.tcp.server.infildes = 0;
		NET_error_tcp(net, NET_E_CONNECT_ERROR, "");
		return;
	}
#endif

#if defined(WIN32)
	STARTUP(net);

	/*
	** Set socket option TCP_NODELAY to true; disable Nagle algorithm 
	*/
	optval = 1;		/* nonzero is true */
	if (setsockopt(asd, IPPROTO_TCP, TCP_NODELAY, (char *)&optval, 
				   sizeof(optval)) == SOCKET_ERROR)
	{
		/* 1996.03.08:TR439600333:Alan Barksdale */
		/* Ashley - 7/11/96 adding WSAEINVAL */
		winsockerr = WSAGetLastError();
		if(WSAENOPROTOOPT == winsockerr || winsockerr == WSAEINVAL)
		{
			NET_DBG(("%s,%d:NET_accept_tcp: setsockopt TCP_NODELAY error : %d; just noting error because option not available on some WinSock implementations\n",
				__FILE__, __LINE__, winsockerr));
		}
		else
		{
			NET_DBG(("%s,%d:NET_accept_tcp: setsockopt TCP_NODELAY error: %d\n",
				__FILE__, __LINE__, winsockerr));
			NET_error_tcp(net, NET_E_CONNECT_ERROR, "");
			return;
		}
	}
	linger.l_onoff = 1;
	linger.l_linger = 60;
	if (setsockopt(asd, SOL_SOCKET, SO_LINGER, (char *)&linger,
					sizeof(linger)) == SOCKET_ERROR)
	{
		winsockerr = WSAGetLastError();
		NET_DBG(("NET_accept_tcp: setsockopt SO_LINGER error: %d\n",
				 winsockerr));
		NET_error_tcp(net, NET_E_CONNECT_ERROR, "");
		return;
	}
	/*
	** Set socket option SO_KEEPALIVE to true  -Goverdhan 9/25
	*/
	NET_DBG(("NET_accept_tcp: setsockopt SO_KEEPALIVE\n"));
	optval = 1;		/* nonzero is true */
	if (setsockopt(asd, SOL_SOCKET, SO_KEEPALIVE, (char *)&optval, 
				   sizeof(optval)) == SOCKET_ERROR)
	{
		winsockerr = WSAGetLastError();
		NET_DBG(("NET_accept_tcp: setsockopt SO_KEEPALIVE error: %d\n",
				 winsockerr));
		NET_error_tcp(net, NET_E_CONNECT_ERROR, "");
		return;
	}
#endif

	NET_DBG(("NET_accept_tcp: complete\n"));
}

/******************************************************************************/

extern void NET_write_tcp(
	net_s   *net,
	char    *user_buffer,
	int             *user_lenp,
	int             blocking,
	int             send_length_flag)
{
	int             sts;
#if defined(unix) || defined(DOS) || defined(vms)
	int             sock;
#endif
#if defined(WIN32)
	SOCKET          sock;
#endif
	int             length;
	int             bytes_written;
	int             bytes_to_write;
	char            *data;
#if defined(unix) || defined(DOS) || defined(WIN32)
	fd_set          writefds;
	fd_set          exceptfds;
    struct timeval  timeout;
    time_t          start_time;
    time_t          time_remaining;
#endif
#ifdef vms
        unsigned long   writefds;
        unsigned long   exceptfds;
        struct timeval  timeout;
        time_t          start_time;
        time_t          time_remaining;
#endif
	net_buffer_s    *buffer;

	NET_DBG(("NET_write_tcp(net:0x%x user_buffer:0x%x *user_lenp:%d blocking:%d send_length_flag:%d)\n", net, user_buffer, *user_lenp, blocking, send_length_flag));

	if (send_length_flag)
	{
		bytes_to_write = *user_lenp + NET_LEN_FIELD_SIZE;
		buffer = (net_buffer_s *)(user_buffer - NET_BUFFER_OFFSET);
		NET_put_len(buffer->len, bytes_to_write);
		data = (char *)buffer->len;
	}
	else
	{
		bytes_to_write = *user_lenp;
		data = user_buffer;
	}
	*user_lenp = 0;
	bytes_written = 0;

	if (net->cs_flag == CLIENT_FLAG)
	{
		sock = net->id.tcp.user.socket;
	}
	else
	{
		sock = net->id.tcp.server.outfildes;
	}

	NET_DBG(("NET_write_tcp: sock:%d data:0x%x (actual)bytes_to_write:%d\n",
		sock, data, bytes_to_write));

    /*
    **  This could be blocking with or without time out value or non blocking
    **  blocking == -1 ==> non blocking
    **  blocking ==  0 ==> blocking indefinately
    **  blocking >=  1 ==> blocking with time out value
    */

    /*
    **  blocking
    */

#if defined(unix) || defined(DOS) || defined(WIN32) || defined(vms)
	/*
	** Initial timeout
	*/
    timeout.tv_sec  = (long) blocking;
    timeout.tv_usec = 0;
	time(&start_time);
	NET_DBG(("NET_write_tcp: start_time = %d\n", start_time));

#endif


	while (bytes_written < bytes_to_write)
	{
#if defined(unix) || defined(DOS) || defined(WIN32) || defined(vms)
		while(blocking >= 0)
		{
#ifdef vms
                        exceptfds = writefds = 0;
                        writefds = (1<<sock);
                        exceptfds =(1<<sock);
#else
			FD_ZERO(&writefds);
			FD_ZERO(&exceptfds);
			FD_SET(sock, &writefds);
			FD_SET(sock, &exceptfds);
#endif

			NET_DBG(("NET_write_tcp: calling select\n"));
			/*
			 **  blocking with timeout
			 */
			if( blocking >= 1 )
			{
#if defined (__hpux__) || defined(vms)
				sts = select(FD_SETSIZE, NULL,(int *)&writefds,(int *)&exceptfds, &timeout);
#else
				sts = select(FD_SETSIZE, NULL, &writefds, &exceptfds,
							 &timeout);
#endif
			}
			else
			{
#if defined (__hpux__) || defined(vms)
				sts = select(FD_SETSIZE, NULL,(int *)&writefds,(int *)&exceptfds,
								NULL);
#else
				sts = select(FD_SETSIZE, NULL, &writefds, &exceptfds, NULL);
#endif
			}
			NET_DBG(("NET_write_tcp: select return sts:%d\n", sts));
#if defined(unix) || defined(DOS) || defined(vms)
			if (sts < 0)
#endif
#if defined(WIN32)
			winsockerr = WSAGetLastError();
			if (sts == SOCKET_ERROR)
#endif
			{
#if defined(unix) || defined(DOS) || defined(vms)
				if (errno == EINTR)
#endif
#if defined(WIN32)
				if (winsockerr == WSAEINTR)
#endif
				{
					if (blocking == BLOCKING)
					{
						NET_DBG(("NET_write_tcp:select interrupted continuing\n"));
						continue;
					}
					else
					{
						time_remaining = NET_get_remaining_time(&start_time,
												      (time_t)timeout.tv_sec);
						if( time_remaining > 0 )
						{
							NET_DBG(("NET_write_tcp:select interrupted "));
							NET_DBG(("before time expired ... continuing\n"));
							/*
							 ** Remaining time
							 */
							timeout.tv_sec  = (long) time_remaining;
							timeout.tv_usec = 0;
							continue;
						}
						else
						{
							NET_DBG(("NET_write_tcp: select timed out\n"));
							NET_error_tcp(net, NET_E_TIMEOUT, "");
							return;
						}
					}
				}

				NET_DBG(("NET_write_tcp: select error\n"));
				NET_error_tcp(net, NET_E_WRITE_ERROR, "");
				return;
			}
			else if (sts == 0)
			{
				NET_DBG(("NET_write_tcp: select timed out\n"));
				NET_error_tcp(net, NET_E_TIMEOUT, "");
				return;
			}
			else
			{
#if defined(vms)
                                NET_DBG(("NET_write_tcp:FD_ISSET(except):%s FD_ISSET(write):%s\n",
                                        (exceptfds & (1<<sock)) ? "YES" : "NO",
                                        (writefds & (1<<sock)) ? "YES" : "NO"));
#else
				NET_DBG(("NET_write_tcp:FD_ISSET(except):%s FD_ISSET(write):%s\n",
						 FD_ISSET(sock, &exceptfds) ? "YES" : "NO",
						 FD_ISSET(sock, &writefds) ? "YES" : "NO"));
#endif
				break;
			}
		}
#endif
/*
**      Old tcp code for vax with progress tcpware.
**      Now we code for vax with DEC tcp/ip  -Goverdhan 12/7
*/
/*
#if defined(vms)
		NET_select_tcpware(net,sock,blocking,1);
#endif
*/

		length = MIN(MAX_TCP_BUFFER_SIZE, bytes_to_write - bytes_written);
		NET_DBG(("NET_write_tcp: calling write: length:%d\n", length));
#if defined(unix) || defined(DOS) || defined(vms)
		sts = send(sock, data + bytes_written, length, 0);
		if (sts < 0)
#endif
#if defined(WIN32)
		sts = send(sock, data + bytes_written, length, 0);
		winsockerr = WSAGetLastError();
		if (sts == SOCKET_ERROR)
#endif
/*
**      Old tcp code for vax with progress tcpware.
**      Now we code for vax with DEC tcp/ip  -Goverdhan 12/7
*/
/*
#ifdef vms
		sts = NET_socket_write(sock, data + bytes_written, length);
		if (sts < 0)
#endif
*/
		{
#if defined(unix) || defined(DOS) || defined(vms)
			NET_DBG(("NET_write_tcp: write returned %d errno:%d\n",sts,errno));
#if defined(__hpux__)
			if (errno == EAGAIN)
#else
			if (errno == EWOULDBLOCK)
#endif
#endif
#if defined(WIN32)
			NET_DBG(("NET_write_tcp: write returned %d LastError:%d\n",
				sts, winsockerr));
			if (winsockerr == WSAEWOULDBLOCK)
#endif
			{
				NET_DBG(("NET_write_tcp: write returned -1 EWOULDBLOCK\n"));
				if( blocking != BLOCKING && bytes_written == 0 )
				{
					NET_DBG(("NET_write_tcp: EWOULDBLOCK\n"));
					NET_error_tcp(net, NET_E_TIMEOUT, "");
					return;
				}
				continue;
			}
#if defined(unix) || defined(DOS) || defined(vms)
			if (errno == EINTR)
#endif
#if defined(WIN32)
			if (winsockerr == WSAEINTR)
#endif
			{
				continue;
			}
			NET_error_tcp(net, NET_E_WRITE_ERROR, "");
			return;
		}
		bytes_written += sts;
	}

	if (send_length_flag)
	{
		*user_lenp = bytes_written - NET_LEN_FIELD_SIZE;
	}
	else
	{
		*user_lenp = bytes_written;
	}

	NET_DBG(("NET_write_tcp: *user_lenp:%d\nNET_write_tcp: returning\n",
		*user_lenp));
}

/******************************************************************************/

extern void NET_read_tcp(
	net_s   *net,
	char    *user_buffer,
	int             *user_lenp,
	int             blocking,
	int             receive_length_flag)
{
	int                     sts = 0;
#if defined(unix) || defined(DOS) || defined(vms)
	int                     sock;
#endif
#if defined(WIN32)
	SOCKET                  sock;
   /* added for the setsockopt call added for win32s using PC-TCP 2.3 */
        char FAR *setval, *getval;
        int getlen;
#endif
	int                     length;
	int                     bytes_read;
	int                     bytes_to_read;
	char                    *data;
#if defined(unix) || defined(DOS) || defined(WIN32)
	fd_set                  readfds;
	fd_set                  exceptfds;
    struct timeval      timeout;
    time_t              start_time;
    time_t              time_remaining;
#endif
#ifdef vms
        unsigned long   readfds;
        unsigned long   exceptfds;
    struct timeval      timeout;
    time_t              start_time;
    time_t              time_remaining;
#endif
	net_buffer_s    *buffer = 0;

	NET_DBG(("NET_read_tcp(net:0x%x user_buffer:0x%x user_lenp:0x%x blocking:%d receive_length_flag:%d)\n", net, user_buffer, user_lenp, blocking, receive_length_flag));

	if (receive_length_flag)
	{
		buffer = (net_buffer_s *)(user_buffer - NET_BUFFER_OFFSET);
		bytes_to_read = NET_LEN_FIELD_SIZE;
		data = (char *)buffer->len;
	}
	else
	{
		bytes_to_read = *user_lenp;
		data = user_buffer;
	}
	*user_lenp = 0;
	bytes_read = 0;

	if (net->cs_flag == CLIENT_FLAG)
	{
		sock = net->id.tcp.user.socket;
	}
	else
	{
		sock = net->id.tcp.server.infildes;
	}

	NET_DBG(("NET_read_tcp: sock:%d data:0x%x bytes_to_read:%d\n",
		sock, data, bytes_to_read));

#if defined(unix) || defined(DOS) || defined(vms) || defined(WIN32)
    /*
    **  This could be blocking with or without time out value or non blocking
    **  blocking == -1 ==> non blocking
    **  blocking ==  0 ==> blocking indefinately
    **  blocking >=  1 ==> blocking with time out value
    */

	/*
	** Initial timeout
	*/
    timeout.tv_sec  = (long) blocking;
    timeout.tv_usec = 0;
	time(&start_time);
	NET_DBG(("NET_read_tcp: start_time = %d\n", start_time));

#endif


	if (once_thru_flag == 0)	/* arw 10-1-94 Info for RIS License */
	{
		once_thru_flag = 1;		/* Must be called when there is data on wire */
		NET_tcp_getpeer(sock);	/* usually just before recv() */
	}

	while(1)
	{
#if defined(unix) || defined(DOS) || defined(vms) || defined(WIN32)
		while(blocking >= 0)
		{
#if defined(vms)
                        exceptfds = readfds = 0;
                        readfds = (1<<sock);
                        exceptfds = (1<<sock);
#else
			FD_ZERO(&readfds);
			FD_ZERO(&exceptfds);
			FD_SET(sock, &readfds);
			FD_SET(sock, &exceptfds);
#endif

			NET_DBG(("NET_read_tcp: calling select\n"));
			/*
			 **  blocking with timeout
			 */
			if( blocking >= 1 )
			{
#if defined (__hpux__) || defined(vms)
				sts = select(FD_SETSIZE,(int *)&readfds, NULL,(int *)&exceptfds, &timeout);
#else
				sts = select(FD_SETSIZE,&readfds, NULL, &exceptfds, &timeout);
#endif
			}
			else
			{
#if defined(__hpux__) || defined(vms)
				sts = select(FD_SETSIZE, (int *)&readfds, NULL, (int *)&exceptfds, NULL);
#else
				sts = select(FD_SETSIZE, &readfds, NULL, &exceptfds, NULL);
#endif
			}

#if defined(unix) || defined(DOS) || defined(vms)
			if (sts < 0)
#endif
#if defined(WIN32)
			winsockerr = WSAGetLastError();
			if (sts == SOCKET_ERROR)
#endif
			{
#if defined(unix) || defined(DOS) || defined(vms)
				NET_DBG(("NET_read_tcp: select return sts:%d errno:%d\n", sts,
						 errno));
				if (errno == EINTR)
#endif
#if defined(WIN32)
				NET_DBG(("NET_read_tcp:select returned SOCKET_ERROR LastError:%d\n",
						 winsockerr));
				if (winsockerr == WSAEINTR)
#endif
				{
					if (blocking == BLOCKING)
					{
						NET_DBG(("NET_read_tcp:select interrupted...continuing\n"));
						continue;
					}
					else
					{
						time_remaining = NET_get_remaining_time(&start_time, 
												 (time_t)timeout.tv_sec);
						if( time_remaining > 0 )
						{
							NET_DBG(("NET_read_tcp:select interrupted "));
							NET_DBG(("before time expired ... continuing\n"));
							/*
							 ** Remaining time
							 */
							timeout.tv_sec  = (long) time_remaining;
							timeout.tv_usec = 0;
							continue;
						}
						else
						{
							NET_DBG(("NET_read_tcp: select timed out\n"));
							NET_error_tcp(net, NET_E_TIMEOUT, "");
							return;
						}
					}
				}
				NET_error_tcp(net, NET_E_READ_ERROR, "");
				return;
			}	/* if sts < 0 or sts==SOCKET_ERROR */
			else if (sts == 0)
			{
				NET_DBG(("NET_read_tcp: select timed out\n"));
				NET_error_tcp(net, NET_E_TIMEOUT, "");
				return;
			}
			else
			{
#if defined(vms)
                                NET_DBG(("NET_read_tcp:FD_ISSET(except):%s FD_ISSET(read):%s\n",
                                        (exceptfds & (1<<sock)) ? "YES" : "NO",
                                        (readfds & (1<<sock)) ? "YES" : "NO"));
#else
				NET_DBG(("NET_read_tcp:FD_ISSET(except):%s FD_ISSET(read):%s\n",
						 FD_ISSET(sock, &exceptfds) ? "YES" : "NO",
						 FD_ISSET(sock, &readfds) ? "YES" : "NO"));
#endif
				break;
			}
		}	/*	while(blocking >= 0)  */
#endif
/*
**      Old tcp code for vax with progress tcpware.
**      Now we code for vax with DEC tcp/ip  -Goverdhan 12/7
*/
/*
#if defined(vms)
		NET_select_tcpware(net,sock,blocking,0);
#endif
*/
		/*
		**      TCP reads whatever is there in the TCP internal buffer (socket)
		**      But, actually the buffer might be written using multiple writes.
		**      TCP does not have message (write) boundaries.
		**  Therefore read head information first to get size of data massage
		*/
		length = bytes_to_read;
		NET_DBG(("NET_read_tcp: calling read: length:%d\n", length));
#if defined(unix) || defined(DOS) || defined(vms)
		sts = recv(sock, data, length, 0);
		if (sts < 0)
#endif
#if defined(WIN32)
		if (RIScom_get_platform() == IS_WIN32S)
		{
      // the recv call fails when the size of the buffer is very large
      // using PC-TCP 2.3. To fix that the setsockopt call is added
      // so that we could set the receive buffer size before the call 
      // to recv. Additional changes regarding this problem are 
      // documented in the beginning of this file. 8/94 Radha
      
                 setval = (char FAR *)MAX_TCP_BUFFER_SIZE;
                 if (setsockopt (sock, SOL_SOCKET, SO_RCVBUF, 
                   (LPSTR)&setval, sizeof(char FAR *)) == SOCKET_ERROR)
		 {
                      winsockerr = WSAGetLastError();
/* Ashley 6/25/96 - A particular implementation of winsock may not support this
**                  optional feature 
**/
			if(WSAENOPROTOOPT == winsockerr || winsockerr == WSAEINVAL)
			{
				NET_DBG(("%s,%d:NET_read_tcp: setsockopt SO_RCVBUF error, buffer size <%d> this winsock may not support this buffer size\n",
				__FILE__, __LINE__, setval));
			}
			else
			{
                      		NET_DBG((
                      		"NET_read_tcp: setsockopt failed: LastError %d\n",
                              	winsockerr));
		      		NET_error_tcp(net, NET_E_READ_ERROR, "");
		      		return;
                	}
		}

                 getlen = sizeof(setval);
                 if (getsockopt (sock, SOL_SOCKET, SO_RCVBUF, 
                    (char FAR *)&getval, &getlen) == SOCKET_ERROR)
                 {
                       winsockerr = WSAGetLastError();
                      NET_DBG((
                      "NET_read_tcp: getsockopt failed: LastError %d\n",
                              winsockerr));
		      NET_error_tcp(net, NET_E_READ_ERROR, "");
		      return;
                 }
                 NET_DBG((
           "NET_read_tcp: getsockopt passed: getval: %d getlen: %d\n",
                        getval, getlen));
		}

		sts = recv(sock, data, length, 0);
		winsockerr = WSAGetLastError();
		if (sts == SOCKET_ERROR)
#endif
/*
**      Old tcp code for vax with progress tcpware.
**      Now we code for vax with DEC tcp/ip  -Goverdhan 12/7
*/
/*
#ifdef vms
		sts = NET_socket_read(sock, data, length);
		if (sts < 0)
#endif
*/
		{
#if defined(unix) || defined(DOS) || defined(vms)
			NET_DBG(("NET_read_tcp: read returned %d errno:%d\n", sts, errno));
			if (errno == EINTR)
#endif
#if defined(WIN32)
			NET_DBG(("NET_read_tcp: read returned %d LastError:%d\n",sts,
					 winsockerr));
			if (winsockerr == WSAEINTR)
#endif
			{
				NET_DBG(("NET_read_tcp: read interrupted...continuing\n"));
				continue;
			}
#if defined(unix) || defined(DOS) || defined(vms)
#if defined(__hpux__)
			if (errno == EAGAIN)
#else
			if (errno == EWOULDBLOCK)
#endif
#endif
#if defined(WIN32)
			if (winsockerr == WSAEWOULDBLOCK)
#endif
			{
				NET_DBG(("NET_read_tcp: read NO data...\n"));
				NET_error_tcp(net, NET_E_TIMEOUT, "");
				return;
			}

			NET_error_tcp(net, NET_E_READ_ERROR, "");
			return;
		}
		else if (sts == 0)
		{
			NET_DBG(("NET_read_tcp: read returned %d errno:%d\n", sts, errno));
			NET_DBG(("NET_read_tcp: connection lost\n"));
			NET_error_tcp(net, NET_E_TCP_CONNECTION_LOST, "");
			return;
		}
		else
		{
			bytes_read = sts;
			break;
		}
	}

	if (receive_length_flag)
	{
		/*
		**      Determine the correct number of bytes to read. Continue reading
		**      until that many bytes have been read.
		*/

		NET_get_len(buffer->len, &bytes_to_read);
		NET_DBG(("NET_read_tcp: (actual)bytes_to_read:%d\n", bytes_to_read));
		if (bytes_to_read - NET_LEN_FIELD_SIZE > buffer->size)
		{
			NET_DBG(("NET_read_tcp: error: buffer->size:%d bytes_to_read:%d\n",
				buffer->size, bytes_to_read - NET_LEN_FIELD_SIZE));
			NET_error_tcp(net, NET_E_READ_BUFFER_TOO_SMALL, "");
			return;
		}

		while (bytes_read < bytes_to_read)
		{
			/*
			** Read a packet
			*/
/* NOTE:  12/1/94 Ashley Burns- since a select() is not done during this
** looping to get data a situation could occur when the following conditions
** are met:
**     1) using non-blocking socket
**     2) client processing is faster than server processing
**     3) server sends data greater than internal TCP buffer
**        in which case is would be split into multiple packets
**
**     The client could read the data on the socket faster than the server
**     can send the data.  Once the client does a recv() again in the loop
**     then potientially no data could be on the socket in which case the
**     code will ERROR out.   A blocking select could be used to handle
**     this situation.
**
**     It is left for future development to verify/implement this issue.
*/
			length = MIN(bytes_to_read - bytes_read, MAX_TCP_BUFFER_SIZE);
			NET_DBG(("NET_read_tcp: calling read: length:%d\n", length));
#if defined(unix) || defined(DOS) || defined(vms)

			sts = recv(sock, data + bytes_read, length, 0);

			if (sts < 0)
#endif
#if defined(WIN32)
			if (RIScom_get_platform() == IS_WIN32S)
			{
      // the recv call fails when the size of the buffer is very large
      // using PC-TCP 2.3. To fix that, the setsockopt call is added
      // so that we could set the receive buffer size before the call
      // to recv. Additional changes regarding this problem are
      // documented in the beginning of this file. 8/94 Radha

                 setval = (char FAR *)MAX_TCP_BUFFER_SIZE;
                 if (setsockopt (sock, SOL_SOCKET, SO_RCVBUF,
                   (LPSTR)&setval, sizeof(char FAR *)) == SOCKET_ERROR)
                 {
                      winsockerr = WSAGetLastError();
/* Ashley 6/25/96 - A particular implementation of winsock may not support this
**                  optional feature 
**/
			
			if(WSAENOPROTOOPT == winsockerr || winsockerr == WSAEINVAL)
			{
				NET_DBG(("%s,%d:NET_read_tcp: setsockopt SO_RCVBUF error: buffer size <%d> this winsock may not support this buffer size\n",
				__FILE__, __LINE__, setval));
			}
			else
			{
                      		NET_DBG((
                      		"NET_read_tcp: setsockopt failed: LastError %d\n",
                              	winsockerr));
                      		NET_error_tcp(net, NET_E_READ_ERROR, "");
                      		return;
			}
                 }

                 getlen = sizeof(setval);
                 if (getsockopt (sock, SOL_SOCKET, SO_RCVBUF,
                    (char FAR *)&getval, &getlen) == SOCKET_ERROR)
                 {
                       winsockerr = WSAGetLastError();
                      NET_DBG((
                      "NET_read_tcp: getsockopt failed: LastError %d\n",
                              winsockerr));
                      NET_error_tcp(net, NET_E_READ_ERROR, "");
                      return;
                 }
                 NET_DBG((
           "NET_read_tcp: getsockopt passed: getval: %d getlen: %d\n",
                        getval, getlen));
			}

			sts = recv(sock, data + bytes_read, length, 0);
			winsockerr = WSAGetLastError();
			if (sts == SOCKET_ERROR)
#endif
/*
**      Old tcp code for vax with progress tcpware.
**      Now we code for vax with DEC tcp/ip  -Goverdhan 12/7
*/
/*
#ifdef vms
			sts = NET_socket_read(sock, data + bytes_read, length);
			if (sts < 0)
#endif
*/
			{
#if defined(unix) || defined(DOS) || defined(vms)
				NET_DBG(("NET_read_tcp: read returned %d errno:%d\n",
					sts, errno));
				if (errno == EINTR)
#endif
#if defined(WIN32)
				NET_DBG(("NET_read_tcp: read returned %d LastError:%d\n",
					sts, winsockerr));
				if (winsockerr == WSAEINTR)
#endif

				{
					NET_DBG(("NET_read_tcp: Interupt... continuing\n"));
					continue;
				}

#if defined(unix) || defined(DOS) || defined(vms)
#if defined(__hpux__)
				if (errno == EAGAIN)
#else
				if (errno == EWOULDBLOCK)
#endif
#endif
#if defined(WIN32)
				if (winsockerr == WSAEWOULDBLOCK)
#endif
				{
					NET_DBG(("NET_read_tcp: NO data...\n"));
					continue;
				}

				*user_lenp = 0;
				NET_error_tcp(net, NET_E_READ_ERROR, "");
				return;
			}
			if (sts == 0)
			{
				*user_lenp = 0;
				NET_error_tcp(net, NET_E_TCP_CONNECTION_LOST, "");
				return;
			}

			bytes_read += sts;
		}
		*user_lenp = bytes_read - NET_LEN_FIELD_SIZE;
	}
	else
	{
		*user_lenp = bytes_read;
	}

	NET_DBG(("NET_read_tcp: *user_lenp:%d bytes\nNET_read_tcp: returning\n",        
		*user_lenp));
}

/******************************************************************************/

extern void NET_close_tcp(
	net_s *net)
{
	NET_DBG(("NET_close_tcp(net:0x%x)\n", net));

	if (net->cs_flag == SERVER_FLAG)
	{
#if defined(unix) || defined(DOS) || defined(vms)
		NET_DBG(("NET_close_tcp 0x%x: close srv sockets in: %d out: %d\n",
			net,net->id.tcp.server.infildes,net->id.tcp.server.outfildes));
		sleep(2);
		NET_DBG(("NET_close_tcp: closing descriptors %d and %d\n",
			net->id.tcp.server.infildes, net->id.tcp.server.outfildes));
	    NET_sys_close(net->id.tcp.server.infildes);
		NET_sys_close(net->id.tcp.server.outfildes);
#endif
/*
**      Old tcp code for vax with progress tcpware.
**      Now we code for vax with DEC tcp/ip  -Goverdhan 12/7
*/
/*
#if defined(vms)
		NET_DBG(("NET_close_tcp 0x%x: close server socket\n",
			net));
	NET_close_socket(net);
#endif
*/
#if defined(WIN32)
		NET_DBG(("NET_close_tcp 0x%x: close srv sockets in: %d out: %d\n",
			net,net->id.tcp.server.infildes,net->id.tcp.server.outfildes));
		if (closesocket(net->id.tcp.server.infildes) == SOCKET_ERROR)
		{
			NET_DBG(("NET_close_tcp closesocket %d error: %d\n",
					 net->id.tcp.server.infildes, WSAGetLastError()));
		}
#endif
	}
	else
	{
		NET_DBG(("NET_close_tcp 0x%x: closing socket %d\n",
			net,net->id.tcp.user.socket));
#if defined(unix) || defined(DOS) || defined(vms)
		NET_sys_close(net->id.tcp.user.socket);
#endif
#if defined(WIN32)
		if (closesocket(net->id.tcp.user.socket) == SOCKET_ERROR)
		{
			NET_DBG(("NET_close_tcp closesocket %d error: %d\n",
					 net->id.tcp.user.socket, WSAGetLastError()));
		}
#endif
	}
	NET_DBG(("NET_close_tcp:returning\n"));
}

/******************************************************************************/

/* given a symbolic node name, get the tcp network netaddr */

extern void NET_addr_tcp(
	net_s   *net,
	char    *nodename,
	char    *netaddr,
	int             *len)
{
#if defined(unix) || defined(DOS) || defined(vms) || defined(WIN32)
	struct hostent *host;
	struct in_addr in;
#endif

	NET_DBG(("NET_addr_tcp(net:0x%x nodename:<%s> netaddr:0x%x *len:%d)\n",
		net, nodename, netaddr, *len));

#if defined(WIN32)
	STARTUP(net);
#endif

#if defined(unix) || defined(DOS) || defined(vms)
	if ((host = NET_gethostbyname(nodename)) == 0)
	{
		if ((in.s_addr = inet_addr(nodename)) == (unsigned)(-1))
		{
			NET_error_tcp(net, NET_E_ADDR_ERROR, "");
			return;
		}
	}
	else
	{
		memcpy((char *)&in.s_addr, host->h_addr, host->h_length);
	}
	strncpy(netaddr, (const char *)inet_ntoa(in),*len);
#endif
#if defined(WIN32)
	if ((host = gethostbyname(nodename)) == NULL)
	{
		if ((in.s_addr = inet_addr(nodename)) == (unsigned)(-1))
		{
		NET_DBG(("NET_addr_tcp: gethostbyname error 0x%x\n",
				 WSAGetLastError()));
			NET_error_tcp(net, NET_E_ADDR_ERROR, "");
			return;
		}
	}
	else
	{
		memcpy((char *)&in.s_addr, host->h_addr, host->h_length);
	}
/*---------------------------------------------------------------------------
 *  SPECIAL INTERNATIONALIZATION NOTE:
 *      allowing the strncpy since the tcpip address will always be an
 *      ascii number.
 *
 *      Paula Blohm 10/10/94
---------------------------------------------------------------------------*/
	strncpy(netaddr,inet_ntoa(in),*len);
#endif
/*
**      Old tcp code for vax with progress tcpware.
**      Now we code for vax with DEC tcp/ip  -Goverdhan 12/7
*/
/*
#if defined(vms)
    NET_addr_tcpware(net,nodename,netaddr,len);
#endif
*/

	NET_DBG(("NET_addr_tcp: netaddr:<%s>\nNET_addr_tcp: complete\n",
		STRING(netaddr)));
}


/******************************************************************************/

/* get the local symbolic node name */

extern void NET_node_tcp(
	net_s   *net,
	char    *nodename,
	int             *len)
{
#ifdef vms
    struct item  itmlst;
    int          stat;
#endif

	NET_DBG(("NET_node_tcp(net:0x%x nodename:0x%x *len:%d)\n",
		net, nodename, *len));

#if defined(WIN32)
	STARTUP(net);
#endif

#if defined(unix) || defined(DOS)
    if (NET_gethostname(nodename, *len) < 0)
    {
	NET_error_tcp(net,NET_E_INVALID_NODE,"");
	return;
    }
#endif
#if defined(WIN32)
    if (gethostname(nodename, *len) == SOCKET_ERROR)
    {
		NET_DBG(("NET_node_tcp: gethostname error %d\n", 
				 WSAGetLastError()));
		if ( WSACleanup() ) {
			NET_DBG(("NET_node_tcp WSACleanup error %d\n",
					 WSAGetLastError()));
		}
		NET_error_tcp(net,NET_E_INVALID_NODE,"");
		return;
    }
#endif
#ifdef vms
    itmlst.len      = *len;
    itmlst.code     = SYI$_NODENAME;
    itmlst.addr     = nodename;
    itmlst.ret_addr = len;
    itmlst.empty    = 0;

    stat = SYS$GETSYIW(0, 0, 0, &itmlst, 0, 0, 0);
    if (stat != SS$_NORMAL)
    {
	NET_error_tcp(net,NET_E_INVALID_NODE,"");
	return;
    }
#endif

	NET_DBG(("NET_node_tcp: nodename:<%s>\nNET_node_tcp: complete\n",nodename));
}

/*****************************************************************************/
/* following get/put/remove_file_tcp functions are only used by ris client   */
/*****************************************************************************/

#if defined(unix)
# if defined(__clipper__)
char ftp_flags[] = " -v -h -n ";
# else
char ftp_flags[] = " -v -n ";
# endif
# if defined(sun)
char ftp_program[] = "/usr/ucb/ftp";
# else
char ftp_program[] = "/usr/bin/ftp";
# endif
#endif /* unix */

/******************************************************************************/

extern void NET_get_file_tcp(
	net_s			*net,
	net_connect_s	*connect_info,
	char			*remote_file,
	char			*local_file)
{
	char temp_remote[MAX_PATH_SIZE+2];

#if defined(unix)
	char buffer[sizeof("echo \"user  \nget  \" |   2>&1") +
		MAX_USER_NAME_SIZE + MAX_PASSWORD_SIZE + MAX_PATH_SIZE + MAX_PATH_SIZE +
		sizeof(ftp_program) + sizeof(ftp_flags) + MAX_ADDRESS_SIZE + 100];
#endif /* unix */

#if defined(WIN32)
	char temp_name[MAX_PATH];
	char buf1[sizeof("user  ") + MAX_USER_NAME_SIZE + MAX_PASSWORD_SIZE+50];
	char buf2[sizeof("get  ") + MAX_PATH_SIZE + MAX_PATH_SIZE + 50];
	char buffer[sizeof("ftp -v -n -s:   2>&1") + MAX_PATH_SIZE +
				MAX_ADDRESS_SIZE + 50];
	FILE *tfp;
#endif /* WIN32 */

	NET_DBG(("NET_get_file_tcp(net:0x%x remote_file:<%s> local_file:<%s>)\n",
		net, remote_file, local_file));

#if defined(unix)
	adjust_filename(remote_file, temp_remote);
	sprintf(buffer,
		"echo \'user %s %s\nget %s %s\' | %s %s %s 2>&1",
		connect_info->tcp.username,connect_info->tcp.password,temp_remote,
		local_file,ftp_program,ftp_flags,connect_info->tcp.address);
    NET_execute_command(net,buffer,NET_E_GET_FILE_ERROR,NET_error_tcp,
		"550 ",NET_E_FILE_NOT_FOUND);
	NET_ERRCHK(net);
#endif /* unix */

#if defined(WIN32)
	adjust_filename(remote_file, temp_remote);
	sprintf(buf1, "user %s %s\n", connect_info->tcp.username,
			connect_info->tcp.password);
	sprintf(buf2, "get %s %s\n", temp_remote, local_file);
	NET_tmpnam(temp_name);
	sprintf(buffer,"ftp -v -n -s:%s %s ",temp_name,
			connect_info->tcp.address);
	if ((tfp = fopen(temp_name, "w+")) == NULL)
	{
		NET_DBG(("NET_get_file_tcp: error opening temp file\n"));
		NET_error_tcp(net,NET_E_GET_FILE_ERROR,"");
		return;
	}
	if (fputs(buf1, tfp) == EOF)
	{
		NET_DBG(("NET_get_file_tcp: error fputs buf: %s to %s file\n", buf1,
				temp_name));
		NET_remove(temp_name);
		NET_error_tcp(net,NET_E_GET_FILE_ERROR,"");
		return;
	}
	if (fputs(buf2, tfp) == EOF)
	{
		NET_DBG(("NET_get_file_tcp: error fputs buf: %s to %s file\n",
				buf2, temp_name));
		NET_remove(temp_name);
		NET_error_tcp(net,NET_E_GET_FILE_ERROR,"");
		return;
	}
	if (fclose(tfp) == EOF)
	{
		NET_DBG(("NET_get_file_tcp: error fclose %s file\n", temp_name));
		NET_remove(temp_name);
		NET_error_tcp(net,NET_E_GET_FILE_ERROR,"");
		return;
	}               
    NET_execute_command(net,buffer,NET_E_GET_FILE_ERROR,NET_error_tcp,
		"550 ",NET_E_FILE_NOT_FOUND);
	NET_remove(temp_name);
	NET_ERRCHK(net);
#endif /* WIN32 */

	NET_DBG(("NET_get_file_tcp: complete\n"));
}

/******************************************************************************/

extern void NET_put_file_tcp(
	net_s			*net,
	net_connect_s	*connect_info,
	char			*local_file,
	char			*remote_file)
{
	char temp_remote[MAX_PATH_SIZE+2];

#if defined(unix)
	char buffer[sizeof("echo \"user  \nput  \" |   2>&1") +
		MAX_USER_NAME_SIZE + MAX_PASSWORD_SIZE + MAX_PATH_SIZE + MAX_PATH_SIZE +
		sizeof(ftp_program) + sizeof(ftp_flags) + MAX_ADDRESS_SIZE + 100];
#endif /* unix */

#if defined (WIN32)
	char temp_name[MAX_PATH];
	char buf1[sizeof("user  ") + MAX_USER_NAME_SIZE + MAX_PASSWORD_SIZE+50];
	char buf2[sizeof("put  ") + MAX_PATH_SIZE + MAX_PATH_SIZE + 50];
	char buffer[sizeof("ftp -v -n -s:   2>&1") + MAX_PATH_SIZE +
				MAX_ADDRESS_SIZE + 50];
	FILE *tfp;
#endif /* WIN32 */

	NET_DBG(("NET_put_file_tcp(net:0x%x remote_file:<%s> local_file:<%s>)\n",
		net, remote_file, local_file));

#if defined(unix)
	adjust_filename(remote_file, temp_remote);
	sprintf(buffer,
		"echo \'user %s %s\nput %s %s\' | %s %s %s 2>&1",
		connect_info->tcp.username,connect_info->tcp.password,local_file,
		temp_remote,ftp_program,ftp_flags,connect_info->tcp.address);
	NET_execute_command(net,buffer,NET_E_PUT_FILE_ERROR,NET_error_tcp,0,0);
	NET_ERRCHK(net);
#endif /* unix */

#if defined (WIN32)
	adjust_filename(remote_file, temp_remote);
	sprintf(buf1, "user %s %s\n", connect_info->tcp.username,
			connect_info->tcp.password);
	sprintf(buf2, "put %s %s\n", local_file, temp_remote);
	NET_tmpnam(temp_name);
	sprintf(buffer,"ftp -v -n -s:%s %s ",temp_name,
			connect_info->tcp.address);
	if ((tfp = fopen(temp_name, "w+")) == NULL)
	{
		NET_DBG(("NET_put_file_tcp: error opening temp file\n"));
		NET_error_tcp(net,NET_E_PUT_FILE_ERROR,"");
		return;
	}
	if (fputs(buf1, tfp) == EOF)
	{
		NET_DBG(("NET_put_file_tcp: error fputs buf: %s to %s file\n", buf1,
				temp_name));
		NET_remove(temp_name);
		NET_error_tcp(net,NET_E_PUT_FILE_ERROR,"");
		return;
	}
	if (fputs(buf2, tfp) == EOF)
	{
		NET_DBG(("NET_put_file_tcp: error fputs buf: %s to %s file\n",
				buf2, temp_name));
		NET_remove(temp_name);
		NET_error_tcp(net,NET_E_PUT_FILE_ERROR,"");
		return;
	}
	if (fclose(tfp) == EOF)
	{
		NET_DBG(("NET_put_file_tcp: error fclose %s file\n", temp_name));
		NET_remove(temp_name);
		NET_error_tcp(net,NET_E_PUT_FILE_ERROR,"");
		return;
	}               
	NET_execute_command(net,buffer,NET_E_PUT_FILE_ERROR,NET_error_tcp,0,0);
	NET_remove(temp_name);
	NET_ERRCHK(net);
#endif /* WIN32 */

	NET_DBG(("NET_put_file_tcp: complete\n",net));
}

/******************************************************************************/

extern void NET_get_lock_file_tcp(
	net_s			*net,
	net_connect_s	*connect_info,
	char			*remote_file)
{
	char temp_remote[MAX_PATH_SIZE+2];

#if defined(unix)
	char buffer[sizeof("echo \"user  \ndelete  \" |   2>&1") +
		MAX_USER_NAME_SIZE + MAX_PASSWORD_SIZE + MAX_PATH_SIZE +
		sizeof(ftp_program) + sizeof(ftp_flags) + MAX_ADDRESS_SIZE + 100];
#endif /* unix */

#if defined(WIN32)
	char temp_name[MAX_PATH];
	char buf1[sizeof("user  ") + MAX_USER_NAME_SIZE + MAX_PASSWORD_SIZE+50];
	char buf2[sizeof("delete  ") + MAX_PATH_SIZE + 50];
	char buffer[sizeof("ftp -v -n -s:   2>&1") + MAX_PATH_SIZE +
				MAX_ADDRESS_SIZE + 50];
	FILE *tfp;
#endif /* WIN32 */

	NET_DBG(("NET_get_lock_file_tcp(net:0x%x remote_file:<%s>)\n",
		net, remote_file));

#if defined(unix)
	adjust_filename(remote_file, temp_remote);
	sprintf(buffer,
		"echo \'user %s %s\ndelete %s\' | %s %s %s 2>&1",
		connect_info->tcp.username,connect_info->tcp.password,temp_remote,
		ftp_program,ftp_flags,connect_info->tcp.address);
	NET_execute_command(net,buffer,NET_E_GET_LOCK_FILE_ERROR, NET_error_tcp,
		"550 ",NET_E_NO_LOCK);
	NET_ERRCHK(net);
#endif /* unix */

#if defined (WIN32)
	adjust_filename(remote_file, temp_remote);
	sprintf(buf1, "user %s %s\n", connect_info->tcp.username,
			connect_info->tcp.password);
	sprintf(buf2, "delete %s\n", temp_remote);
	NET_tmpnam(temp_name);
	sprintf(buffer,"ftp -v -n -s:%s %s ",temp_name,
			connect_info->tcp.address);
	if ((tfp = fopen(temp_name, "w+")) == NULL)
	{
		NET_DBG(("NET_get_lock_file_tcp: error opening temp file\n"));
		NET_error_tcp(net,NET_E_GET_LOCK_FILE_ERROR,"");
		return;
	}
	if (fputs(buf1, tfp) == EOF)
	{
		NET_DBG(("NET_get_lock_file_tcp: error fputs buf: %s to %s file\n", 
				buf1, temp_name));
		NET_remove(temp_name);
		NET_error_tcp(net,NET_E_GET_LOCK_FILE_ERROR,"");
		return;
	}
	if (fputs(buf2, tfp) == EOF)
	{
		NET_DBG(("NET_get_lock_file_tcp: error fputs buf: %s to %s file\n",
				buf2, temp_name));
		NET_remove(temp_name);
		NET_error_tcp(net,NET_E_GET_LOCK_FILE_ERROR,"");
		return;
	}
	if (fclose(tfp) == EOF)
	{
		NET_DBG(("NET_get_lock_file_tcp: error fclose %s file\n",
				temp_name));
		NET_remove(temp_name);
		NET_error_tcp(net,NET_E_GET_LOCK_FILE_ERROR,"");
		return;
	}               
	NET_execute_command(net,buffer,NET_E_GET_LOCK_FILE_ERROR, NET_error_tcp,
		"550 ",NET_E_NO_LOCK);
	NET_remove(temp_name);
	NET_ERRCHK(net);
#endif	/* WIN32 */

	NET_DBG(("NET_get_lock_file_tcp: complete\n"));
}

/******************************************************************************/

extern void NET_put_lock_file_tcp(
	net_s			*net,
	net_connect_s	*connect_info,
	char			*remote_file)
{
	char temp_remote[MAX_PATH_SIZE+2];

#if defined(unix)
	char temp[L_tmpnam];
	char buffer[sizeof("> ;echo \"user  \nput  \" |   2>&1") +
		L_tmpnam + MAX_USER_NAME_SIZE + MAX_PASSWORD_SIZE + MAX_PATH_SIZE +
		L_tmpnam + sizeof(ftp_program) + sizeof(ftp_flags) +
		MAX_ADDRESS_SIZE + 100];
#endif /* unix */

#if defined (WIN32)
	char buf1[sizeof("user  ") + MAX_USER_NAME_SIZE + MAX_PASSWORD_SIZE+50];
	char buf2[sizeof("put  ") + MAX_PATH_SIZE + MAX_PATH_SIZE + 50];
	char buffer[sizeof("ftp -v -n -s:   2>&1") + MAX_PATH_SIZE +
				MAX_ADDRESS_SIZE + 50];
	FILE *tfp;
	char temp[MAX_PATH];
#endif /* WIN32 */

	NET_DBG(("NET_put_lock_file_tcp(net:0x%x remote_file:<%s>)\n",
		net, remote_file));

#if defined(unix)
	/*
	** Ftp doesn't like /dev/null so use a temporary file instead
	*/
	NET_tmpnam(temp);
	adjust_filename(remote_file, temp_remote);
	sprintf(buffer,
		">%s;echo \'user %s %s\nput %s %s\' | %s %s %s 2>&1",
		temp,connect_info->tcp.username,connect_info->tcp.password,temp,
		temp_remote,ftp_program,ftp_flags,connect_info->tcp.address);
	NET_execute_command(net, buffer, NET_E_PUT_LOCK_FILE_ERROR,
		NET_error_tcp, 0, 0);
	NET_remove(temp);
	NET_ERRCHK(net);
#endif /* unix */

#if defined (WIN32)
	/*
	** Ftp doesn't like /dev/null so use a temporary file instead
	*/
	NET_tmpnam(temp);
	adjust_filename(remote_file, temp_remote);
	sprintf(buf1, "user %s %s\n", connect_info->tcp.username,
			connect_info->tcp.password);
	sprintf(buf2, "put %s %s\n", temp, temp_remote);
	sprintf(buffer,"ftp -v -n -s:%s %s ", temp, connect_info->tcp.address);
	if ((tfp = fopen(temp, "w+")) == NULL)
	{
		NET_DBG(("NET_put_lock_file_tcp: error opening temp file\n"));
		NET_error_tcp(net,NET_E_PUT_LOCK_FILE_ERROR,"");
		return;
	}
	if (fputs(buf1, tfp) == EOF)
	{
		NET_DBG(("NET_put_lock_file_tcp: error fputs buf: %s to %s file\n", 
				buf1, temp));
		NET_remove(temp);
		NET_error_tcp(net,NET_E_PUT_LOCK_FILE_ERROR,"");
		return;
	}
	if (fputs(buf2, tfp) == EOF)
	{
		NET_DBG(("NET_put_lock_file_tcp: error fputs buf: %s to %s file\n",
				buf2, temp));
		NET_remove(temp);
		NET_error_tcp(net,NET_E_PUT_LOCK_FILE_ERROR,"");
		return;
	}
	if (fclose(tfp) == EOF)
	{
		NET_DBG(("NET_put_lock_file_tcp: error fclose %s file\n",
				temp));
		NET_remove(temp);
		NET_error_tcp(net,NET_E_PUT_LOCK_FILE_ERROR,"");
		return;
	}               
	NET_execute_command(net, buffer, NET_E_PUT_LOCK_FILE_ERROR,
		NET_error_tcp, 0, 0);
	NET_remove(temp);
	NET_ERRCHK(net);
#endif /* WIN32 */

	NET_DBG(("NET_put_lock_file_tcp: complete\n"));
}

/******************************************************************************/

extern void NET_remove_file_tcp(
	net_s			*net,
	net_connect_s	*connect_info,
	char			*remote_file)
{
	char temp_remote[MAX_PATH_SIZE+2];

#if defined(unix)
	char buffer[sizeof("echo \"user  \ndelete  \" |   2>&1") +
		MAX_USER_NAME_SIZE + MAX_PASSWORD_SIZE + MAX_PATH_SIZE +
		sizeof(ftp_program) + sizeof(ftp_flags) + MAX_ADDRESS_SIZE + 100];
#endif /* unix */

#if defined (WIN32)
	char temp_name[MAX_PATH];
	char buf1[sizeof("user  ") + MAX_USER_NAME_SIZE + MAX_PASSWORD_SIZE+50];
	char buf2[sizeof("delete  ") + MAX_PATH_SIZE + 50];
	char buffer[sizeof("ftp -v -n -s:   2>&1") + MAX_PATH_SIZE +
				MAX_ADDRESS_SIZE + 50];
	FILE *tfp;
#endif /* WIN32 */

	NET_DBG(("NET_remove_file_tcp(net:0x%x remote_file:<%s>)\n",
		net, remote_file));

#if defined(unix)
	adjust_filename(remote_file, temp_remote);
	sprintf(buffer,
		"echo \'user %s %s\ndelete %s\' | %s %s %s 2>&1",
		connect_info->tcp.username,connect_info->tcp.password,temp_remote,
		ftp_program,ftp_flags,connect_info->tcp.address);
    NET_execute_command(net,buffer,NET_E_REMOVE_FILE_ERROR,NET_error_tcp,
		"550 ",NET_E_FILE_NOT_FOUND);
	NET_ERRCHK(net);
#endif /* unix */

#if defined (WIN32)
	adjust_filename(remote_file, temp_remote);
	sprintf(buf1, "user %s %s\n", connect_info->tcp.username,
			connect_info->tcp.password);
	sprintf(buf2, "delete %s\n", temp_remote);
	NET_tmpnam(temp_name);
	sprintf(buffer,"ftp -v -n -s:%s %s ",temp_name, 
			connect_info->tcp.address);
	if ((tfp = fopen(temp_name, "w+")) == NULL)
	{
		NET_DBG(("NET_remove_file_tcp: error opening temp file\n"));
		NET_error_tcp(net,NET_E_REMOVE_FILE_ERROR,"");
		return;
	}
	if (fputs(buf1, tfp) == EOF)
	{
		NET_DBG(("NET_remove_file_tcp: error fputs buf: %s to %s file\n", 
				buf1, temp_name));
		NET_remove(temp_name);
		NET_error_tcp(net,NET_E_REMOVE_FILE_ERROR,"");
		return;
	}
	if (fputs(buf2, tfp) == EOF)
	{
		NET_DBG(("NET_remove_file_tcp: error fputs buf: %s to %s file\n",
				buf2, temp_name));
		NET_remove(temp_name);
		NET_error_tcp(net,NET_E_REMOVE_FILE_ERROR,"");
		return;
	}
	if (fclose(tfp) == EOF)
	{
		NET_DBG(("NET_remove_file_tcp: error fclose %s file\n",
				temp_name));
		NET_remove(temp_name);
		NET_error_tcp(net,NET_E_REMOVE_FILE_ERROR,"");
		return;
	}               
    NET_execute_command(net,buffer,NET_E_REMOVE_FILE_ERROR,NET_error_tcp,
		"550 ",NET_E_FILE_NOT_FOUND);
	NET_remove(temp_name);
	NET_ERRCHK(net);
#endif /* WIN32 */

	NET_DBG(("NET_remove_file_tcp: complete\n"));
}

/******************************************************************************/

/*
** For UNIX, replace backslashes in pathname to forward slashes.
**
** For both UNIX and NT, enclose the filename in "double quotes"
** to handle spaces in filename for new NT installations e.g.
** "c:\program files\common files\intergraph\schemas".
**
** This is to fix TR# 439601492, 439601595 - surjit (July 22, 1996)
*/

static void adjust_filename(char *old_path, char new_path[])
{
	char *c;
	int i;

	NET_DBG(("BEFORE adjusting filename=<%s>\n", old_path));
	new_path[0] = '\"';
	for (c = old_path,i = 1; *c != '\0'; c++,i++)
	{
	  if ( *c == '\\' )
		 new_path[i] = '/';
	  else
		new_path[i] = *c;
	}
	new_path[i] = '\"'; new_path[i+1] = '\0';
	NET_DBG(("AFTER adjusting filename=<%s>\n", new_path));
}

/******************************************************************************/

extern void NET_error_tcp(
	net_s   *net,
	int      code,
	char    *string)
{
#if defined(WIN32)
	int		stri;
	int		size;
	int		current_size;
	int		wstring_size;
	int		j;

	static	int				flag = 0;
	static struct cvalues	compare_s[COMPARE_NUMBER];
#endif

#if defined(vms)
int h_errno;
#endif
#if defined(unix) || defined(WIN32) || defined(DOS) || defined(vms)
	int i;
	int net_code = 0; /* initialize to shut up the compiler */

	NET_DBG(("NET_error_tcp(net:0x%x code:0x%x string:<%s>)\n",
		net, code, string ? string : "NULL"));
	/*
	** -- fill in protocol specific code --
	** Some of the tcp calls set the system defined variable errno.
	** For these calls set net->net_error_code to errno and
	** net->net_error_string to the corresponding error string, otherwise
	** leave them blank.
	*/
	switch ((unsigned int)code)
	{
		case NET_E_GET_FILE_ERROR:
		case NET_E_PUT_FILE_ERROR:
		case NET_E_GET_LOCK_FILE_ERROR:
		case NET_E_PUT_LOCK_FILE_ERROR:
		case NET_E_NO_LOCK:
			net->net_error_code = 0;
#if defined(unix) || defined(DOS) || defined(vms)
			for (i=0;i < sizeof(net->net_error_string)-1 && string[i];i++)
			{
				if (string[i] == '\n' || string[i] == '\t')
				{
					net->net_error_string[i] = ' ';
				}
				else
				{
					net->net_error_string[i] = string[i];
				}
			}
#endif
#if defined(WIN32)
			if ( ! flag )
			{
				flag = 1;
				for (stri=0; stri < COMPARE_NUMBER; stri++ )
				{
					compare_s[stri].string = ( wchar_t * ) SYS_MALLOC(COMPARE_SIZE);
					RIScom_mbstowcs (compare_s[stri].string, ascii_values[stri], 
							strlen(ascii_values[stri]));
					compare_s[stri].numchars = RIScom_wstrlen( compare_s[stri].string);
				}
			}
			size = sizeof ( net->net_error_string) - 1;
			RIScom_multiwide ( &RISwide_ptr, &string, &RISwide_size, MULTITOWIDE, 0 );

			/* 	determine if the global pointer RISwide_ptr has enough space to
				hold the error string passed.
			*/

			/* RISwide_size2 is the size of the malloced buffer in bytes */
			current_size = RISwide_size2;
			wstring_size = strlen(string) * sizeof(wchar_t);

			while ( RISwide_size2 < wstring_size )
			{
				RISwide_size2 = RISwide_size2 * 2;
			}
			if ( RISwide_size2 > current_size )
			{
				RISwide_ptr2= (wchar_t *)SYS_REALLOC((char *)RISwide_ptr2, RISwide_size2 );
			}

			for (stri=0, i=0; i < size && RISwide_ptr[stri]; i++, stri++)
			{
				/*
				** Strip off the stdout 'user' line & replace '^M' with space;
				** also strip off the 'get ', 'put ' & 'delete ' lines
				*/
				for ( j = 0; j < COMPARE_NUMBER; j++ )
				{
					if ( ! RIScom_wcsncmp(&RISwide_ptr[stri], compare_s[j].string,
								compare_s[j].numchars))
					{
						/* checking for 0xD - Carriage return */
						while ( RISwide_ptr[stri] != 0xD && 
							RISwide_ptr[stri] && stri < 2048 )
						{
							stri++;
						}
						if (!RISwide_ptr[stri])
						{
							stri--;
						}
						break;
					}
				} /* end for j < COMPARE_NUMBER */

				/* checking for 0xD - Carriage return */
				if (RISwide_ptr[stri] == WIDECHAR('\n') || 
						RISwide_ptr[stri] == WIDECHAR('\t') ||
						RISwide_ptr[stri] == 0xD ||
						RISwide_ptr[stri] == WIDECHAR(' '))
				{
					if (RISwide_ptr2[i-1] != WIDECHAR(' '))
						RISwide_ptr2[i] = WIDECHAR(' ');
					else
						i--;
				}
				else
				{
					RISwide_ptr2[i] = RISwide_ptr[stri];
				}
			} /* end main for */

			RISwide_ptr2[i] = WIDECHAR('\0');
			RIScom_wcstombs(net->net_error_string, RISwide_ptr2, size );
			NET_DBG(("Net string after: <%s>\n", net->net_error_string ));
#endif

#ifndef WIN32
			net->net_error_string[i] = '\0';
#endif
			break;

		case NET_E_TCP_SOCKET:
		case NET_E_CONNECT_ERROR:
		case NET_E_WRITE_ERROR:
		case NET_E_READ_ERROR:
#if defined(unix) || defined(DOS) || defined(vms)
                        if (errno)
                        {
                                net->net_error_code = errno;
                                strcpy((char *)net->net_error_string, strerror(errno));
                        }
#elif defined(WIN32)
                        if (winsockerr != NO_ERROR)
                        {
                                net->net_error_code = winsockerr;
                                strcpy(net->net_error_string,
                                        strerror(net->net_error_code));
                        }
#endif /* WIN32 */
                        else
                        {
                                net->net_error_code = 0;
                                net->net_error_string[0] = '\0';
                        }
                        break;

		case NET_E_ADDR_ERROR:
			net->net_error_code = h_errno;
			switch (h_errno)
			{
				case HOST_NOT_FOUND:
					net_code = NET_E_TCP_HOST_NOT_FOUND;
					break;
				case TRY_AGAIN:
					net_code = NET_E_TCP_TRY_AGAIN;
					break;
				case NO_RECOVERY:
					net_code = NET_E_TCP_NO_RECOVERY;
					break;
				case NO_ADDRESS:
					net_code = NET_E_TCP_NO_ADDRESS;
					break;
			}
			if (net_code)
			{
				strcpy(net->net_error_string,
					NET_error_msg(net_code));
			}
			break;

		default:
			break;
	}

	/*
	** -- fill in generic code --
	*/ 
	switch((unsigned int)code)
	{
		case NET_E_TCP_SOCKET:
			net->error_code = NET_E_CONNECT_ERROR;
			break;

		case NET_E_TCP_CONNECTION_LOST:
			net->error_code = NET_E_READ_ERROR;
			break;

		case NET_E_TCP_INVALID_ADDRESS:
			net->error_code = NET_E_ADDR_ERROR;
			break;

		default:
			net->error_code = code;
			break;
	}
	strcpy(net->error_string,NET_error_msg(code));

	NET_DBG(("NET_error_tcp: net->error_string:<%s>\n", net->error_string));
	NET_DBG(("NET_error_tcp: net->net_error_string:<%s>\n",
		net->net_error_string));
	NET_DBG(("NET_error_tcp: complete\n"));
#endif
/*
**      Old tcp code for vax with progress tcpware.
**      Now we code for vax with DEC tcp/ip  -Goverdhan 12/7
*/
/*
#ifdef vms
    NET_error_tcpware(net,code,string);
#endif
*/
}

/******************************************************************************/

#ifdef BLAHH
extern void NET_set_nodelay(
	net_s   *net,
	int fd)
{
#if defined (sco)
  int   count;
  struct t_optmgmt      req, ret;
  struct opthdr {
        long            level;
        long            name;
        long            len;
        };
  struct ndstruct {
        struct opthdr   header;
        long            value;
        } ndreq, ndret;
#endif
 
  NET_DBG(("NET_set_nodelay(net:0x%x fd:%d\n", net, fd));

#if defined (sco)
  t_errno = errno = 0;
  ndreq.header.level = IPPROTO_TCP;
  ndreq.header.name  = TCP_NODELAY;
  ndreq.header.len   = sizeof(ndreq.value);
  ndreq.value        = 1;
 
  ndret.header.level = 0;
  ndret.header.name  = 0;
  ndret.header.len   = 0;
  ndret.value        = 0;
 
  req.flags = T_NEGOTIATE;
  req.opt.maxlen = req.opt.len = sizeof(ndreq);
  req.opt.buf = (char *)&ndreq;
 
  ret.flags = 0;
  ret.opt.maxlen = sizeof(ndret);
  ret.opt.len = 0;
  ret.opt.buf = (char *)&ndret;
 
  count = 0;
  while ( t_optmgmt(fd,&req,&ret) != 0 )
  {
        if ((t_errno == TSYSERR) && (errno == EINTR)
            && (count++ < T_FUNC_MAX_RETRIES))
                continue;
		NET_DBG(("NET_set_nodelay: t_optmgmt error: %d\n", errno));
		NET_error_tcp(net, NET_E_CONNECT_ERROR, "");
		return;
  }
  NET_DBG(("NET_set_nodelay t_optmgmt done ..\n"));
 
  if ( (req.flags != ret.flags)                    ||
       (ndreq.header.level != ndret.header.level)  ||
       (ndreq.header.name != ndret.header.name)    ||
       (ndreq.header.len != ndret.header.len)      ||
       (ndreq.value != ndret.value)   )
  {
        NET_DBG(("NET_set_nodelay: Return didn't match request.\n"));
        NET_error_tcp(net, NET_E_CONNECT_ERROR, "");
        return;
  }
#endif
  NET_DBG(("NET_set_nodelay done..\n"));
}
#endif /* BLAAH */

/******************************************************************************/

extern int NET_tcp_getpeer(int sock)
{
#if defined(unix) || defined(WIN32)
	struct sockaddr_in from;
	int fromlen,status;

	fromlen=sizeof(from);

	if ((status = getpeername(sock,(struct sockaddr *) &from,&fromlen)) == 0)
	{
		strcpy(NET_peer_name,(char *) inet_ntoa(from.sin_addr));
		NET_DBG(("NET_tcp_getpeer sock = [%d] peer name = [%s]\n",sock,NET_peer_name));
		return(0);
	}
	else
		return(-1);
#endif
}
