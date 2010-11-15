/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							nettcpdm.c
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
#define nettcpdm_c
#include "nettcpdm.prt"
#include "netumsg.prt"
#include "net_sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

#if defined(WIN32)
extern void NET_cleanup_tcp(
	void)
{
	/* Do Nothing */
}
#endif

extern void NET_connect_tcp(
	net_s *net)
{
	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

extern void NET_accept_tcp(
	net_s *net)
{
	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

extern void NET_write_tcp(
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

extern void NET_read_tcp(
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

extern void NET_error_tcp(
	net_s *net)
{
	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

extern void NET_close_tcp(
	net_s *net)
{
	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

extern void NET_addr_tcp(
	net_s *net)
{
	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

extern void NET_node_tcp(
	net_s *net)
{
	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

extern void NET_get_file_tcp(
	net_s *net)
{
	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

extern void NET_put_file_tcp(
	net_s *net)
{
	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

extern void NET_get_lock_file_tcp(
	net_s *net)
{
	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

extern void NET_put_lock_file_tcp(
	net_s *net)
{
	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

extern void NET_remove_file_tcp(
	net_s *net)
{
	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}
