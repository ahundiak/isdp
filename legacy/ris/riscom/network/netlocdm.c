/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							netlocdm.c
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
#define netlocdm_c
#include "netlocdm.prt"
#include "netumsg.prt"
#include "net_sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

extern void NET_connect_local(
	net_s *net)
{
	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));

}

extern void NET_accept_local(
	net_s *net)
{
	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

extern void NET_write_local(
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

extern void NET_read_local(
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

extern void NET_error_local(
	net_s *net)
{
	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

extern void NET_close_local(
	net_s *net)
{
	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

extern void NET_addr_local(
	net_s *net)
{
	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

extern void NET_node_local(
	net_s *net)
{
	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

extern void NET_get_file_local(
	net_s *net)
{
	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

extern void NET_put_file_local(
	net_s *net)
{
	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

extern void NET_get_lock_file_local(
	net_s *net)
{
	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

extern void NET_put_lock_file_local(
	net_s *net)
{
	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

extern void NET_remove_file_local(
	net_s *net)
{
	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}
