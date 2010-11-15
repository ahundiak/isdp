/* Do not alter this SPC information: $Revision: 1.2.27.1 $ */
/*
**	NAME:							netl62dm.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					12/89
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <stdio.h>
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
#define netl62dm_c
#include "netumsg.prt"
#include "netl62dm.prt"
#include "net_sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void NET_connect_lu62(
	net_s *net)
{
	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

/******************************************************************************/

extern void NET_accept_lu62(
	net_s *net)
{
	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

/******************************************************************************/

extern void NET_write_lu62(
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

/******************************************************************************/

extern void NET_read_lu62(
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

/******************************************************************************/

extern void NET_error_lu62(
	net_s *net)
{
	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

/******************************************************************************/

extern void NET_close_lu62(
	net_s *net)
{
	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

/******************************************************************************/

extern void NET_addr_lu62(
	net_s *net)
{
	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

/******************************************************************************/

extern void NET_node_lu62(
	net_s *net)
{
	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

/******************************************************************************/

extern void NET_get_file_lu62(
	net_s *net)
{
	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

/******************************************************************************/

extern void NET_put_file_lu62(
	net_s *net)
{
	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

/******************************************************************************/

extern void NET_get_lock_file_lu62(
	net_s *net)
{
	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

/******************************************************************************/

extern void NET_put_lock_file_lu62(
	net_s *net)
{
	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

/******************************************************************************/

extern void NET_remove_file_lu62(
	net_s *net)
{
	net->error_code = NET_E_INV_PROTOCOL;
	strcpy(net->error_string,NET_error_msg(net->error_code));
}

/******************************************************************************/

#if defined(WIN32)

extern void NET_cleanup_lu62(
	void)
{
}

#endif

/******************************************************************************/
