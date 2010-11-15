/* Do not alter this SPC information: $Revision: 1.3.27.1 $ */
/*
**	NAME:							netxns.c
**	AUTHORS:						Dave Buehman
**	CREATION DATE:					2/88
**	ABSTRACT:
**		Various routines for sending and receiving message buffers
**		across the XNS SNI network interface.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <stdio.h>
#include <signal.h>
#include <errno.h>
#include "net.h"

/*
**	DEFINES
*/
#define NO_PEP			"INC_PE, No PEP response received from remote server"
#define NO_PEP_LEN		(sizeof(NO_PEP) - 1)

#define ERR_SPAWN		"INC_CA, Error spawning server"
#define ERR_SPAWN_LEN	(sizeof(ERR_SPAWN) - 1)

#define TIME_OUT		"INC_SP, Network request time out"
#define TIME_OUT_LEN	(sizeof(TIME_OUT) - 1)

#define NO_SERVER		"INC_CA, Server not found"
#define NO_SERVER_LEN	(sizeof(NO_SERVER) -1)

#define TIMEOUT			"INC_SP, Network request time out"
#define TIMEOUT_LEN		(sizeof(TIMEOUT) - 1)

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define netxns_c
#include "netumsg.prt"
#include "netlen.prt"
#include "netshare.prt"
#include "netxns.prt"
#include "netwrapx.prt"
#include "net_sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void NET_connect_xns(
	net_s			*net,
	net_connect_s	*connect_info)
{
	char *error;
	char *server_name;
	char node_log[300];
	char *zero_to_one;

	NET_DBG(("NET_connect_xns(net:0x%x connect_info:0x%x)\n",
		net, connect_info));

	strcpy(node_log, connect_info->xns.address);
	strcat(node_log, ".");

	strcat(node_log, connect_info->xns.username);
	if (*connect_info->xns.password)
	{
		strcat(node_log, ".");
		strcat(node_log, connect_info->xns.password);
	}

	if (*connect_info->xns.server_name)
	{
		if (connect_info->xns.server_num)
		{
			NET_error_xns(net, NET_E_XNS_BOTH_SERV_NAME_NUM, "");
			return;
		}
		server_name = connect_info->xns.server_name;
		NET_DBG(("NET_connect_xns: node:<%s> server_name:<%s>\n",
			node_log,server_name));
	}
	else
	{
		if (!connect_info->xns.server_num)
		{
			NET_error_xns(net, NET_E_XNS_NEITHER_SERV_NAME_NUM, "");
			return;
		}
		server_name = 0;
		NET_DBG(("NET_connect_xns: node:<%s> server_num:%d\n",
			node_log, connect_info->xns.server_num));
	}

	error = NET_sni_connect(&net->id.xns.sni_d,node_log,
		connect_info->xns.server_num,server_name);
	if (error)
	{
		/*
		** this is to make a 5.1 client connect with a 5.0 server
		*/
		if ( (zero_to_one = strrchr(server_name,'0')) != NULL )
		{
			*zero_to_one = '1';
			NET_DBG(("NET_connect_xns. servername is now:%s\n",server_name));

			error = NET_sni_connect(&net->id.xns.sni_d,node_log, connect_info->xns.server_num,server_name);
			if (error)
			{
				NET_error_xns(net, NET_E_CONNECT_ERROR, error);
				return;
			}
		}

	}

	NET_DBG(("NET_connect_xns: complete\n"));
}

/******************************************************************************/

extern void NET_accept_xns(
	net_s		*net)
{
	char	*error;

	NET_DBG(("NET_accept_xns(net:0x%x)\n", net));

	error = NET_sni_accept(&net->id.xns.sni_d);
	if (error)
	{
		NET_DBG(("NET_accept_xns: sni_accept error:%s\n",error));
		NET_error_xns(net, NET_E_ACCEPT_ERROR, error);
		return;
	}

	NET_DBG(("NET_accept_xns: connection made: sni_d:%d\n", net->id.xns.sni_d));

        NET_xns_get_peer(net->id.xns.sni_d);       /* arw RIS license server info */

	NET_DBG(("NET_accept_xns: complete\n"));
}

/******************************************************************************/

extern void NET_write_xns(
	net_s	*net,
	char	*user_buffer,
	int		*user_lenp,
	int		blocking,
	int		send_length_flag)
{
	int				length;
	long			timeout;
	int				bytes_written;
	int				bytes_to_write;
	char			*data;
	char			*error;
	net_buffer_s	*buffer;
	long			time_remaining;
	time_t			start_time;

	NET_DBG(("NET_write_xns(net:0x%x user_buffer:0x%x *user_lenp:%d blocking:%d send_length_flag:%d)\n", net, user_buffer, *user_lenp, blocking, send_length_flag));

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

	NET_DBG(("NET_write_xns: sni_d:%d data:0x%x (actual)bytes_to_write:%d\n",
		net->id.xns.sni_d, data, bytes_to_write));

    /*
    **  This could be blocking with or without time out value or non blocking
	**	timeout should be atleast 1 sec == 1000 milliseconds
	**	otherwise XNS will interprete to be as blocking indefinitely
    **  blocking == -1 ==> non blocking
    **  blocking ==  0 ==> blocking indefinately
    **  blocking >=  1 ==> blocking with time out value
    */

    if ( blocking >= 0 )
    {
        /*
        **  blocking in seconds
		**	timeout in milliseconds
        */
        timeout = blocking * 1000;
    }
    else
    {
        /*
        **   non blocking with default timeout
        */
        timeout = REMOTE_TIME_OUT;
    }


    time(&start_time);
    NET_DBG(("NET_write_xns: start_time = %d\n", start_time));

	while (bytes_written < bytes_to_write)
	{
		length = MIN(MAX_XNS_BUFFER_SIZE, bytes_to_write - bytes_written);

		NET_DBG(("NET_write_xns:calling sni_txw: length:%d timeout:%d\n",
			length, timeout));
		errno = 0;
        error = sni_txw(&net->id.xns.sni_d, data + bytes_written, &length,
			timeout);
		if (error)
		{
			NET_DBG(("NET_write_xns: error:<%s> errno:%d\n", error, errno));
			if (errno == EINTR && strncmp(error, TIMEOUT, TIMEOUT_LEN) != 0)
			{
				if( bytes_written == 0 )
				{
                	if (blocking == BLOCKING)
                	{
                    	NET_DBG(("NET_write_xns:select interrupted...continuing\n"));
                    	continue;
                	}
                	else
                	{
                    	time_remaining = NET_get_remaining_time(&start_time,
							(time_t)(timeout / 1000));
                    	if( time_remaining > 0 )
                    	{
                        	NET_DBG(("NET_write_xns:select interrupted "));
                        	NET_DBG(("before time expired ... continuing\n"));
                        	/*
                        	** Remaining time
                        	*/
                        	timeout = time_remaining * 1000;
                        	continue;
                    	}
                    	else
                    	{
                        	NET_DBG(("NET_write_xns: select timed out\n"));
							NET_error_xns(net, NET_E_TIMEOUT, "");
							return;
                    	}
                	}
				}
				else
				{
					continue;
				}
			}
			if (strncmp(error, TIMEOUT, TIMEOUT_LEN) == 0)
			{
               	NET_DBG(("NET_write_xns: select timed out\n"));
				NET_error_xns(net, NET_E_TIMEOUT, "");
				return;
			}
			NET_error_xns(net, NET_E_WRITE_ERROR, error);
			return;
		}
		bytes_written += length;
	}

	if (send_length_flag)
	{
		*user_lenp = bytes_written - NET_LEN_FIELD_SIZE;
	}
	else
	{
		*user_lenp = bytes_written;
	}
	NET_DBG(("NET_write_xns: *user_lenp:%d\nNET_write_xns: returning\n",
		*user_lenp));
}


/******************************************************************************/

extern void NET_read_xns(
	net_s	*net,
	char	*user_buffer,
	int		*user_lenp,
	int		blocking,
	int		receive_length_flag)
{
	int				length;
	int				bytes_read;
	int				bytes_to_read;
	long			timeout;
	char			*error;
	char			*data;
	net_buffer_s	*buffer = 0;
	long			time_remaining;
	time_t			start_time;

	NET_DBG(("NET_read_xns(net:0x%x user_buffer:0x%x user_lenp:0x%x blocking:%d receive_length_flag:%d)\n", net, user_buffer, user_lenp, blocking, receive_length_flag));

	if (receive_length_flag)
	{
		buffer = (net_buffer_s *)(user_buffer - NET_BUFFER_OFFSET);
		bytes_to_read = MIN(buffer->size, MAX_XNS_BUFFER_SIZE);
		data = (char *)buffer->len;
	}
	else
	{
		bytes_to_read = *user_lenp;
		data = user_buffer;
	}

	*user_lenp = 0;
	bytes_read = 0;

	NET_DBG(("NET_read_xns: sni_d:%d data:0x%x bytes_to_read:%d\n",
		net->id.xns.sni_d, data, bytes_to_read));

    /*
    **  This could be blocking with or without time out value or non blocking
	**	timeout should be atleast 1 sec == 1000 milliseconds
	**	otherwise XNS will interprete to be as blocking indefinitely
    **  blocking == -1 ==> non blocking
    **  blocking ==  0 ==> blocking indefinately
    **  blocking >=  1 ==> blocking with time out value
    */

    if ( blocking >= 0 )
    {
        /*
        **  blocking in seconds
		**	timeout in milliseconds
        */
        timeout = blocking * 1000;
    }
    else
    {
        /*
        **   non blocking with default timeout
        */
        timeout = 1000;
    }

    time(&start_time);
    NET_DBG(("NET_read_xns: start_time = %d\n", start_time));

	/*
	**	Do the first read
	*/
	while(1)
	{
		length = bytes_to_read;
		NET_DBG(("NET_read_xns: calling sni_rxw length:%d timeout:%d\n",
			length, timeout));
		errno = 0; /* kludge for sni_rxw bug */
		error = sni_rxw(&net->id.xns.sni_d, data, &length, timeout);
		if (error)
		{
			NET_DBG(("NET_read_xns: error:<%s> errno:%d\n", error, errno));

			if (errno == EINTR && strncmp(error, TIMEOUT, TIMEOUT_LEN) != 0)
			{
                if (blocking == BLOCKING)
                {
                    NET_DBG(("NET_read_xns:select interrupted...continuing\n"));
                    continue;
                }
                else
                {
					time_remaining = NET_get_remaining_time(&start_time,
						(time_t)(timeout / 1000));
					if( time_remaining > 0 )
					{
						NET_DBG(("NET_write_xns:select interrupted "));
						NET_DBG(("before time expired ... continuing\n"));
						/*	
						** Remaining time
						*/
						timeout = time_remaining * 1000;
						continue;
                    }
                    else
                    {
                        NET_DBG(("NET_read_xns: select timed out\n"));
						NET_error_xns(net, NET_E_TIMEOUT, "");
						return;
                    }
                }
			}
			if(strncmp(error, TIMEOUT, TIMEOUT_LEN) == 0)
			{
                NET_DBG(("NET_read_xns: select timed out\n"));
				NET_error_xns(net, NET_E_TIMEOUT, "");
				return;
			}
			NET_error_xns(net, NET_E_READ_ERROR, error);
			return;
		}
		bytes_read = length;
		break;
	}

	if (receive_length_flag)
	{
		/*
		**	Determine the correct number of bytes to read. Continue reading
		**	until that many bytes have been read.
		*/

		NET_get_len(buffer->len, &bytes_to_read);
		NET_DBG(("NET_read_xns: (actual)bytes_to_read:%d\n", bytes_to_read));
		if (bytes_to_read - NET_LEN_FIELD_SIZE > buffer->size)
		{
			NET_DBG(("NET_read_xns: error: buffer->size:%d bytes_to_read:%d\n",
				buffer->size, bytes_to_read - NET_LEN_FIELD_SIZE));
			NET_error_xns(net, NET_E_READ_BUFFER_TOO_SMALL, "");
			return;
		}

		timeout = 0;
		while (bytes_read < bytes_to_read)
		{
			length = MIN(bytes_to_read - bytes_read, MAX_XNS_BUFFER_SIZE);
			NET_DBG(("NET_read_xns: calling sni_rxw length:%d timeout:%d\n",
				length, timeout));

			errno = 0; /* kludge for sni_rxw bug */
			error = sni_rxw(&net->id.xns.sni_d, data + bytes_read, &length,
				timeout);
			if (error)
			{
				NET_DBG(("NET_read_xns: error:<%s> errno:%d\n", error, errno));
				if (errno == EINTR ||
					strncmp(error, TIMEOUT, TIMEOUT_LEN) == 0)
				{
					NET_DBG(("NET_read_xns: Interrupt... continuing\n"));
					continue;
				}
				NET_error_xns(net, NET_E_READ_ERROR, error);
				return;
			}
			bytes_read += length;
		}

		*user_lenp = bytes_read - NET_LEN_FIELD_SIZE;
	}
	else
	{
		*user_lenp = bytes_read;
	}
	NET_DBG(("NET_read_xns: *user_lenp:%d\nNET_read_xns: returning\n",
		*user_lenp));
}

/******************************************************************************/

extern void NET_close_xns(
	net_s *net)
{
	NET_DBG(("NET_close_xns(net:0x%x)\n", net));
	if (net->cs_flag == SERVER_FLAG)
	{
		/* bug in xns; server sometimes hangs if you don't wait to close */
		sleep(5);
	}
	NET_sni_close(&net->id.xns.sni_d);
}

/******************************************************************************/

/* given a symbolic node name, get the ethernet network netaddr */

extern void NET_addr_xns(
	net_s	*net,
	char	*nodename,
	char	*netaddr,
	int		*len)
{
	unsigned int lan;
	unsigned int a1,a2,a3,a4,a5,a6;
	char *error;
	char temp[32];

	NET_DBG(("NET_addr_xns(net:0x%x nodename:<%s> netaddr:0x%x *len:%d)\n",
		net, nodename, netaddr, *len));

	/*
	**	Do a clearing house lookup to get the address
	*/
	error = clh_vbyop((unsigned char *)nodename, (unsigned char *)"Address",
		(unsigned char *)temp, 32);
	if (error) strncpy(temp,nodename,32);

	/*
	**	Test if temp is a valid address with a lan
	*/
	if (sscanf(temp,"%8x.%2x-%2x-%2x-%2x-%2x-%2x",
			&lan, &a1, &a2, &a3, &a4, &a5, &a6) != 7)
	{

		/*
		**	Test if temp is a valid address without a lan
		*/
		if (sscanf(temp,"%2x-%2x-%2x-%2x-%2x-%2x",
				&a1, &a2, &a3, &a4, &a5, &a6) == 6)
		{
			/*
			**	Temp is a address without a lan. Let's get the local
			**	lan and prepend it to temp
			*/

			int local_len = 32;
			char local_nodename[32];
			char local_address[32];
			net_s local_net;

			/*
			**	Get the local nodename
			*/
			local_net.protocol = XNS;
			local_net.error_handler = 0;
			local_net.error_code = 0;
			NET_node_xns(&local_net, local_nodename, &local_len);
			if (local_net.error_code)
			{
				NET_error_xns(net, NET_E_ADDR_ERROR, "");
				return;
			}

			/*
			**	Get the local address
			*/
			NET_addr_xns(&local_net, local_nodename, local_address, &local_len);
			if (local_net.error_code)
			{
				NET_error_xns(net, NET_E_ADDR_ERROR, "");
				return;
			}

			if (sscanf(local_address,"%8x.",&lan) != 1)
			{
				NET_error_xns(net, NET_E_ADDR_ERROR, "");
				return;
			}
		}
		else
		{
			NET_error_xns(net, NET_E_ADDR_ERROR, error);
			return;
		}
	}

	if (a1 > 255 || a2 > 255 || a3 > 255 || a4 > 255 || a5 > 255 || a6 > 255)
	{
		NET_error_xns(net, NET_E_ADDR_ERROR, "");
		return;
	}

	sprintf(netaddr,"%08x.%02x-%02x-%02x-%02x-%02x-%02x",
		lan, a1, a2, a3, a4, a5, a6);

	NET_DBG(("NET_addr_xns: netaddr:<%s>\nNET_addr_xns: complete\n", netaddr));
}

/******************************************************************************/

/* get the local symbolic node name */

#ifdef vms
extern void NET_node_xns(
	net_s	*net,
	char	*nodename,
	int		*len)
{
	char	*error;

	NET_DBG(("NET_node_xns(net:0x%x nodename:0x%x *len:%d)\n",
		net, nodename, *len));

	if (error = clh_vbyop((unsigned char *)"template",
		(unsigned char *)"Nodename", (unsigned char *)nodename, *len))
	{
		NET_error_xns(net, NET_E_INVALID_NODE, error);
		return;
	}

	NET_DBG(("NET_node_xns: nodename:<%s>\nNET_node_xns: complete\n",nodename));
}
#else /* unix systems */
extern void NET_node_xns(
	net_s	*net,
	char	*nodename,
	int		*len)
{
    struct utsname name;

	NET_DBG(("NET_node_xns(net:0x%x nodename:0x%x *len:%d)\n",
		net, nodename, *len));

    if (uname(&name) < 0)
    {
		NET_error_xns(net, NET_E_INVALID_NODE, "");
        return;
    }
    strncpy(nodename, name.nodename, *len);

	NET_DBG(("NET_node_xns: nodename:<%s>\nNET_node_xns: complete\n",nodename));
}
#endif /* vms-unix */

/******************************************************************************/

extern void NET_get_file_xns(
	net_s			*net,
	net_connect_s	*connect_info,
	char			*remote_file,
	char			*local_file)
{
	char buffer[sizeof("fmu .. rec   2>&1") + MAX_ADDRESS_SIZE +
	 MAX_USER_NAME_SIZE + MAX_PASSWORD_SIZE + MAX_PATH_SIZE + MAX_PATH_SIZE + 
	 100];

	NET_DBG(("NET_get_file_xns(net:0x%x remote_file:<%s> local_file:<%s>)\n",
		net, remote_file, local_file));

#if defined(unix)
	if (*connect_info->xns.password)
	{
		sprintf(buffer,"fmu %s.%s.%s rec %s %s 2>&1",
		 connect_info->xns.address,connect_info->xns.username,
		 connect_info->xns.password,remote_file,local_file);
	}
	else
	{
		sprintf(buffer,"fmu %s.%s rec %s %s 2>&1",
		 connect_info->xns.address,connect_info->xns.username,remote_file,
		 local_file);
	}
	NET_execute_command(net,buffer,NET_E_GET_FILE_ERROR,NET_error_xns,
		"Error opening file",NET_E_FILE_NOT_FOUND);
	NET_ERRCHK(net);
#endif

	NET_DBG(("NET_get_file_xns: complete\n"));
}

/******************************************************************************/

extern void NET_put_file_xns(
	net_s			*net,
	net_connect_s	*connect_info,
	char			*local_file,
	char			*remote_file)
{
	char buffer[sizeof("fmu .. send   2>&1") + MAX_ADDRESS_SIZE +
	 MAX_USER_NAME_SIZE + MAX_PASSWORD_SIZE + MAX_PATH_SIZE + MAX_PATH_SIZE +
	 100];

	NET_DBG(("NET_put_file_xns(net:0x%x remote_file:<%s> local_file:<%s>)\n",
		net, remote_file, local_file));

#if defined(unix)
	if (*connect_info->xns.password)
	{
		sprintf(buffer,"fmu %s.%s.%s send %s %s 2>&1",
		 connect_info->xns.address,connect_info->xns.username,
		 connect_info->xns.password,local_file,remote_file);
	}
	else
	{
		sprintf(buffer,"fmu %s.%s send %s %s 2>&1",
		 connect_info->xns.address,connect_info->xns.username,local_file,
		 remote_file);
	}
	NET_execute_command(net,buffer,NET_E_PUT_FILE_ERROR,NET_error_xns,0,0);
	NET_ERRCHK(net);
#endif

	NET_DBG(("NET_put_file_xns: complete\n"));
}

/******************************************************************************/

extern void NET_get_lock_file_xns(
	net_s * net,
	net_connect_s * connect_info,
	char * remote_file)
{
	char buffer[sizeof("fmu .. rm  2>&1") + MAX_ADDRESS_SIZE +
	 MAX_USER_NAME_SIZE + MAX_PASSWORD_SIZE + MAX_PATH_SIZE + 100];

	NET_DBG(("NET_get_lock_file_xns(net:0x%x remote_file:<%s>)\n",
		net, remote_file));

#if defined(unix)
	if (*connect_info->xns.password)
	{
		sprintf(buffer,"fmu %s.%s.%s rm %s 2>&1",
		 connect_info->xns.address,connect_info->xns.username,
		 connect_info->xns.password,remote_file);
	}
	else
	{
		sprintf(buffer,"fmu %s.%s rm %s 2>&1",
		 connect_info->xns.address,connect_info->xns.username,remote_file);
	}
	NET_execute_command(net,buffer,NET_E_GET_LOCK_FILE_ERROR, NET_error_xns,
		"non-existent",NET_E_NO_LOCK);
	NET_ERRCHK(net);
#endif

	NET_DBG(("NET_get_lock_file_xns: complete\n"));
}

/******************************************************************************/

extern void NET_put_lock_file_xns(
	net_s			*net,
	net_connect_s	*connect_info,
	char			*remote_file)
{
	char buffer[sizeof("fmu .. send /dev/null  2>&1") + MAX_ADDRESS_SIZE +
	 MAX_USER_NAME_SIZE + MAX_PASSWORD_SIZE + MAX_PATH_SIZE + 100];

	NET_DBG(("NET_put_lock_file_xns(net:0x%x remote_file:<%s>)\n",
		net, remote_file));

#if defined(unix)
	if (*connect_info->xns.password)
	{
		sprintf(buffer,"fmu %s.%s.%s send /dev/null %s 2>&1",
		 connect_info->xns.address,connect_info->xns.username,
		 connect_info->xns.password,remote_file);
	}
	else
	{
		sprintf(buffer,"fmu %s.%s send /dev/null %s 2>&1",
		 connect_info->xns.address,connect_info->xns.username,remote_file);
	}
	NET_execute_command(net,buffer,NET_E_PUT_LOCK_FILE_ERROR,NET_error_xns,0,0);
	NET_ERRCHK(net);
#endif

	NET_DBG(("NET_put_lock_file_xns: complete\n"));
}

/******************************************************************************/

extern void NET_remove_file_xns(
	net_s			*net,
	net_connect_s	*connect_info,
	char			*remote_file)
{
	char buffer[sizeof("fmu .. rm  2>&1") + MAX_ADDRESS_SIZE +
	 MAX_USER_NAME_SIZE + MAX_PASSWORD_SIZE + MAX_PATH_SIZE + 100];

	NET_DBG(("NET_remove_file_xns(net:0x%x remote_file:<%s>)\n",
		net, remote_file));

#if defined(unix)
	if (*connect_info->xns.password)
	{
		sprintf(buffer,"fmu %s.%s.%s rm %s 2>&1",
		 connect_info->xns.address,connect_info->xns.username,
		 connect_info->xns.password,remote_file);
	}
	else
	{
		sprintf(buffer,"fmu %s.%s rm %s 2>&1",
		 connect_info->xns.address,connect_info->xns.username,remote_file);
	}
	NET_execute_command(net,buffer,NET_E_REMOVE_FILE_ERROR,NET_error_xns,
		"non-existent",NET_E_FILE_NOT_FOUND);
	NET_ERRCHK(net);
#endif

	NET_DBG(("NET_remove_file_xns: complete\n",net));
}

/******************************************************************************/

extern void NET_error_xns(
	net_s *net,
	int code,
	char *string)
{
	char *ptr;
	
	NET_DBG(("NET_error_xns(net:0x%x code:%d string:<%s>)\n",
		net, code, string ? string : "NULL"));
	/*
	** -- fill in generic code --
	** In the case of a connect error, due to the fact that xns doesn't
	** return an error code, we have to check the error string returned
	** by xns to determine our generic error message.
	*/

	switch (code)
	{
		case NET_E_CONNECT_ERROR:
			net->error_code = NET_E_CONNECT_ERROR;
			if (strncmp(string, NO_PEP, NO_PEP_LEN) == 0)
			{
				code = NET_E_XNS_NO_PEP;
			}
			else if ((strncmp(string, ERR_SPAWN, ERR_SPAWN_LEN) == 0) ||
					 (strncmp(string, TIME_OUT, TIME_OUT_LEN) == 0)) 
			{
				code = NET_E_XNS_NO_SERVER_PROCESS;
			}
			else if (strncmp(string, NO_SERVER, NO_SERVER_LEN) == 0)
			{
				code = NET_E_XNS_NO_SERVER_ENTRY;
			}
			break;

		case NET_E_XNS_BOTH_SERV_NAME_NUM:
		case NET_E_XNS_NEITHER_SERV_NAME_NUM:
			net->error_code = NET_E_CONNECT_ERROR;
			break;

		default:
			net->error_code = code;
			break;
	}
	strcpy(net->error_string,NET_error_msg(code));

	/*
	** -- fill in protocol specific code --
	** xns doesn't provide an error code, only an error string. So set
	** net_error_code to zero and copy the string into net_error_string.
	*/
	net->net_error_code = 0;
	ptr = net->net_error_string;
	for (; *string && ptr < net->net_error_string + 159; string++)
	{
		if (*string == '\t' || *string == '\n') *ptr++ = ' ';
		else *ptr++ = *string;
	}
	*ptr = 0;

	NET_DBG(("NET_error_xns: net->error_string:<%s>\n", net->error_string));
	NET_DBG(("NET_error_xns: net->net_error_string:<%s>\n",
		net->net_error_string));
	NET_DBG(("NET_error_xns: complete\n"));
}

/******************************************************************************/

extern int NET_xns_get_peer(long sni_d)
{
   	/* Please note that the following is undocumented, and is not to be found
      	   anywhere. I had to give the xns programmer a few beers to get the 
      	   following information. arw 10-1-94
   	*/

   	short  xlate[10];

   	typedef struct {
               	unsigned char net[4];       	/* network number */
               	unsigned char hst[6];       	/* host address   */
               	unsigned char skt[2];      	/* socket number  */
                      } st_adr;

	typedef struct {
		long  	efn;			/* Event Flag */
		int	*len;			/* Pointer to users length variable */
		char	*buffer;		/* Pointer to users buffer */
                      } st_aio;

       	typedef struct {
               	char	del[4];			/* delete session handle for vtp */
	       	st_adr  lcladr;			/* Local Address */
	       	st_adr  netadr;			/* remote Address */
               	st_aio	rx;			/* async struct for reads */
		st_aio	tx;			/* async struct for writes */
		short	flags;			/* various flags */
		short 	xt_socket_no;		/* xt socket number */
		int	sppfd;			/* SPP file descriptor */
		int 	pepfd;			/* PEP file descriptor */
                      } st_sni;

       	st_sni *spp;

       	spp = (st_sni *) sni_d;
       
       	xlate[0] = spp->netadr.net[0];	xlate[1] = spp->netadr.net[1];
       	xlate[2] = spp->netadr.net[2];	xlate[3] = spp->netadr.net[3];
       	xlate[4] = spp->netadr.hst[0];	xlate[5] = spp->netadr.hst[1];
       	xlate[6] = spp->netadr.hst[2];	xlate[7] = spp->netadr.hst[3];
       	xlate[8] = spp->netadr.hst[4];	xlate[9] = spp->netadr.hst[5];

       	sprintf(NET_peer_name,"%02x%02x%02x%02x.%02x-%02x-%02x-%02x-%02x-%02x",
       		xlate[0],xlate[1],xlate[2],xlate[3],xlate[4],xlate[5],
		xlate[6],xlate[7],xlate[8],xlate[9]);

 	NET_DBG(("NET_xns_get_peer(): Client Address is [%s]\n",NET_peer_name));
       	return(0);
}
