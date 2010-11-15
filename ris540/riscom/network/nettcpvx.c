/*
**      NAME:                                                   nettcpvx.c
**      AUTHORS:                                                Goverdhan Gaini
**      CREATION DATE:                                  	11/94
**      ABSTRACT:
**		Some routines for DEC TCP/IP interface
**
**      REVISION HISTORY:
*/

/*
**      INCLUDES
*/
#ifdef  vms
#include  <errno.h>
#include  <types.h>
#include  <stdio.h>
#include  "sys$common:[decc$lib.include]socket.h"
#include  "sys$common:[decc$lib.include]in.h"
#include  "sys$common:[decc$lib.include]netdb.h"             /* change hostent to comply with BSD 4.3 */
#include  "sys$common:[decc$lib.include]inet.h"
#include  <ucx$inetdef.h>       /* INET symbol definitions */
#include  "sys$common:[decc$lib.include]tcp.h"

#include "net.h"

/*
**      DEFINES
*/

/*
**      TYPES
*/
/*
**      FUNCTION PROTOTYPES
*/
#define nettcpvx_c
#include "nettcpvx.prt"
#include "nettcp.prt"


/*
**      VARIABLES
*/

/*
**      FUNCTIONS
*/



/******************************************************************************/
extern int NET_get_socket(
        net_s   *net)
{

	int	sd;
	int	optval;

	/* get a socket */

	NET_DBG(("NET_get_socket()\n"));
	/*
	**	This socket is passed by ucx 'service listener'
	**						- Goverdhan
	*/
	if ((sd = socket(UCX$C_AUXS, 0, 0)) == -1)
	{
		NET_DBG(("NET_get_socket: socket failed, errno: %d\n",errno));
		NET_error_tcp(net, NET_E_TCP_SOCKET, "");
   	        return (0);
	}

	NET_DBG(("NET_get_socket:socket obtained:sd(%d)\n",sd));
	/*
    	** Set socket option SO_REUSEADDR to true; false by default
        */
        optval = 1;             /* nonzero is true */
        if (setsockopt(sd, SOL_SOCKET, SO_REUSEADDR, (char *)&optval,
                                         sizeof(int)))
	{
		NET_DBG(("NET_get_socket: setsockopt SO_REUSEADDR failed, errno: %d\n",errno));
		NET_error_tcp(net, NET_E_TCP_SOCKET, "");
                return (0);
        }
	NET_DBG(("NET_get_socket:setsockopt successful\n"));

	/*
        ** Set socket option TCP_NODELAY to true; disable Nagle algorithm
        */
        optval = 1;             /* nonzero is true */
        if (setsockopt(sd, IPPROTO_TCP, TCP_NODELAY, (char *)&optval,
                                         sizeof(int)))
        {
                NET_DBG(("NET_get_socket: setsockopt TCP_NODELAY failed, errno: %d\n",errno));
                NET_error_tcp(net, NET_E_TCP_SOCKET, "");
                return (0);
        }
	NET_DBG(("NET_get_socket:setsockopt successful\n"));

	net->id.tcp.server.infildes = sd;
	net->id.tcp.server.outfildes = sd;
	NET_DBG(("NET_get_socket: fd %d\n", sd));
	NET_DBG(("NET_get_socket: complete\n"));
	return (0);
}
#endif
