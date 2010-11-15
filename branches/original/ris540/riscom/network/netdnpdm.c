/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							netdnpdm.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					12/89
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
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
#define netdnpdm_c
#include "net_sys.prt"
#include "netdnpdm.prt"
#include "netumsg.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

extern void NET_connect_dnp(
	net_s 			*net,
	net_connect_s   *connect_info)

{
	connect_info = connect_info ; /* shut up the compiler */

	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

extern void NET_accept_dnp(
	net_s *net)
{
	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

extern void NET_write_dnp(
	net_s	*net,
	char	*user_buffer,
	int		*len,
	int		blocking)
{
	user_buffer = user_buffer;
	len = len; /* shut up the compiler */
	blocking = blocking ; /* shut up the compiler */

	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

extern void NET_read_dnp(
	net_s	*net,
	char	*user_buffer,
	int		*len,
	int		blocking)
{
	user_buffer = user_buffer;
	len = len ; /* shut up the compiler */
	blocking = blocking ; /* shut up the compiler */

	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

extern void NET_error_dnp(
	net_s *net)
{
	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

extern void NET_close_dnp(
	net_s *net)
{
	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

extern void NET_addr_dnp(
	net_s 	*net,
	char    *nodename,
	char    *netaddr,
	int     *len)

{
	nodename = nodename ; /* shut up the compiler */
	netaddr = netaddr ; /* shut up the compiler */
	len = len ; /* shut up the compiler */

	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

extern void NET_node_dnp(
	net_s 	*net,
	char    *nodename,
	int     *len)

{
	nodename = nodename ; /* shut up the compiler */
	len = len ; /* shut up the compiler */

	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

extern void NET_get_file_dnp(
	net_s 			*net,
    net_connect_s   *connect_info,
    char            *remote_file,
    char            *local_file)
{
	connect_info = connect_info ; /* shut up the compiler */
	local_file = local_file ; /* shut up the compiler */
	remote_file = remote_file ; /* shut up the compiler */

	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

extern void NET_put_file_dnp(
    net_s           *net,
    net_connect_s   *connect_info,
    char            *local_file,
    char            *remote_file)
{
	connect_info = connect_info ; /* shut up the compiler */
	local_file = local_file ; /* shut up the compiler */
	remote_file = remote_file ; /* shut up the compiler */

	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

extern void NET_get_lock_file_dnp(
    net_s           *net,
    net_connect_s   *connect_info,
    char            *remote_file)
{
	connect_info = connect_info ; /* shut up the compiler */
	remote_file = remote_file ; /* shut up the compiler */

	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

extern void NET_put_lock_file_dnp(
    net_s           *net,
    net_connect_s   *connect_info,
    char            *remote_file)
{
	connect_info = connect_info ; /* shut up the compiler */
	remote_file = remote_file ; /* shut up the compiler */

	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

extern void NET_remove_file_dnp(
    net_s           *net,
    net_connect_s   *connect_info,
    char            *remote_file)
{
	connect_info = connect_info ; /* shut up the compiler */
	remote_file = remote_file ; /* shut up the compiler */

	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}
