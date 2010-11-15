/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							nettcpwr.c
**	AUTHORS:						Sreedhar Barakam
**	CREATION DATE:					10/92
**	ABSTRACT:
**		Various routines for sending and receiving message buffers
**		across the TCP/IP network interface.
**	
**	REVISION HISTORY:
*/

/*
**	INCLUDES
*/
#ifdef  vms
#include <errno.h>
#include <ssdef.h>
#include <iodef.h>
#include <syidef.h>
#include "sys$sysroot:[tcpware.include]socket.h"
#include "sys$sysroot:[tcpware.include]types.h"
#include "sys$sysroot:[tcpware.include]in.h"
#include "sys$sysroot:[tcpware.include]inet.h"
#include "sys$sysroot:[tcpware.include]netdb.h"

#include "net.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/
/*
**	FUNCTION PROTOTYPES
*/
#define nettcpwr_c
#include "nettcpwr.prt"


/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/



/******************************************************************************/
extern int NET_get_socket(
	net_s	*net)
{
	int channel;
	int status;

	NET_DBG(("NET_socket_accept_tcpware: Getting a socket for this connection\n"));

	status = tcpware_server(2,&channel);
	net->id.tcp.server.infildes = channel;
	NET_DBG(("NET_socket_accept_tcpware: insocket:%d,status:%d,fd=%d\n",
		channel,status,net->id.tcp.server.infildes));

		/* A second call to tcpware_server gives a socket, but is not connected 
		** So, use the same socket for both infildes and outfildes
		*/
	net->id.tcp.server.outfildes =  channel;
	NET_DBG(("NET_socket_accept_tcpware: outsocket:%d,status:%d,fd=%d\n",
		channel,status,net->id.tcp.server.infildes));
	
}
/******************************************************************************/

extern void NET_select_tcpware(
	net_s *net,
	int sock,
	int blocking,
	unsigned short wrtflag)
{
	int			sts = 1;
	fd_set                  fds;
	fd_set                  exceptfds;
	struct timeval  timeout;

	NET_DBG(("NET_select_tcpware: net:0x%x,sock:%d,writeflag=%d\n",
		net,sock,wrtflag));

/* tcpware ignores writefds select call for now.  So return doing nothing */

	if (wrtflag)
		return;
	while(blocking >= 0)
	{
		FD_ZERO(&fds);
		FD_ZERO(&exceptfds);
		FD_SET(sock, &fds);
		FD_SET(sock, &exceptfds);

		NET_DBG(("NET_select_tcpware: calling select,blocking=%d\n",blocking));

		timeout.tv_sec  = (long) blocking;
		timeout.tv_usec = 0;

		/*
		**  blocking with timeout
		*/
		if( blocking >= 1 )
		{
			sts = select(FD_SETSIZE, &fds, NULL, &exceptfds, &timeout);
		}
		else
		{
			sts = select(FD_SETSIZE, &fds, NULL, &exceptfds, NULL);
		}

		NET_DBG(("NET_select_tcpware: select return sts:%d\n", sts));

		if (sts < 0)
		{
			if (errno == EINTR)
			{
				if (blocking == BLOCKING)
				{
					NET_DBG((
						"NET_select_tcpware:select interrupted...continuing\n"
					));
					continue;
				}
				else
				{
					NET_DBG(("NET_select_tcpware: select timed out\n"));
					NET_error_tcpware(net, NET_E_TIMEOUT, "");
					return;
				}
			}
			NET_DBG(("NET_select_tcpware: select error: errno:%d\n", errno));
			NET_error_tcpware(net, NET_E_READ_ERROR, "");
			return;
		}
		else if (sts == 0)
		{
			NET_DBG(("NET_select_tcpware: select timed out\n"));
			NET_error_tcpware(net, NET_E_TIMEOUT, "");
			return;
		}
		else
		{
			NET_DBG(("NET_select_tcpware:FD_ISSET(except):%s\n",
				FD_ISSET(sock, &exceptfds) ? "YES" : "NO"));
			NET_DBG(("NET_select_tcpware:FD_ISSET(fd:wrtflag:%d):%s\n",
				wrtflag, FD_ISSET(sock, &fds) ? "YES" : "NO"));
			break;
		}
	}
}
/******************************************************************************/

extern int NET_socket_read(
	int channel,
	char  *buffer,
	int   buflen)
{
int status;

	NET_DBG(("NET_socket_read_tcpware: channel = %d,buffer<0x%x>,buflen=%d\n",
		channel,buffer,buflen));

	status = socket_read(channel,buffer,buflen);

	NET_DBG(("NET_socket_read_tcpware: status:%d\n",status));
	return status;

}

/******************************************************************************/

extern int NET_socket_write(
int channel,
char  *buffer,
int   buflen)
{
	int status;

	NET_DBG(("NET_socket_write_tcpware: channel = %d,buffer<0x%x>,buflen=%d\n",
		channel,buffer,buflen));
	status = socket_write(channel,buffer,buflen);
	NET_DBG(("NET_socket_write_tcpware: status:%d\n"));
	return status;

}

/******************************************************************************/

extern int NET_close_socket(
net_s *net)
{
int status;

	NET_DBG(("NET_socket_close_tcpware\n"));
	status = socket_close(net->id.tcp.server.infildes);
	NET_DBG(("NET_socket_close_tcpware: status:%d\n"));
	return status;

}

/******************************************************************************/

/* given a symbolic node name, get the tcp network netaddr */

extern void NET_addr_tcpware(
net_s   *net,
char    *nodename,
char    *netaddr,
int             *len)
{
	struct hostent *host;
	struct in_addr in;

	NET_DBG(("NET_addr_tcpware(net:0x%x nodename:<%s> netaddr:0x%x *len:%d)\n",
		net, nodename, netaddr, *len));

	if ((host = gethostbyname(nodename)) == 0)
	{
		inet_addr(nodename);
		if (in.s_addr == (unsigned)(-1))
		{
			NET_error_tcpware(net, NET_E_ADDR_ERROR, "");
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
}

/******************************************************************************/

extern void NET_error_tcpware(
net_s   *net,
int             code,
char    *string)
{
	int i;
	int h_errno;
	int net_code = 0; /* initialize to shut up the compiler */

	NET_DBG(("NET_error_tcpware(net:0x%x code:%d string:<%s>)\n",
		net, code, string ? string : "NULL"));
		/*
		** -- fill in protocol specific code --
		** Some of the tcp calls set the system defined variable errno.
		** For these calls set net->net_error_code to errno and
		** net->net_error_string to the corresponding error string, otherwise
		** leave them blank.
		*/
	switch (code)
	{
		case NET_E_GET_FILE_ERROR:
		case NET_E_PUT_FILE_ERROR:
		case NET_E_GET_LOCK_FILE_ERROR:
		case NET_E_PUT_LOCK_FILE_ERROR:
		case NET_E_NO_LOCK:
			net->net_error_code = 0;
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
----------------------------------------------------------------------*/
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
			net->net_error_string[i] = '\0';
			break;
		case NET_E_TCP_SOCKET:
		case NET_E_CONNECT_ERROR:
		case NET_E_WRITE_ERROR:
		case NET_E_READ_ERROR:
			net->net_error_code = errno;
			strcpy(net->net_error_string, "Net error");
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
				strcpy(net->net_error_string,NET_error_msg(net_code));
			}
			break;

		default:
		break;
	}

		/*
		** -- fill in generic code --
		*/
	switch(code)
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

	NET_DBG(("NET_error_tcpware: net->error_string:<%s>\n", net->error_string));
	NET_DBG(("NET_error_tcpware: net->net_error_string:<%s>\n",
		net->net_error_string));
	NET_DBG(("NET_error_tcpware: complete\n"));
}

/******************************************************************************/

#endif
