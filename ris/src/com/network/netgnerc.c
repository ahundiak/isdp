/*
**      NAME:                                                   netgnerc.c
**      AUTHORS:                                                Dave Buehmann
**      CREATION DATE:                                  12/89
**      ABSTRACT:
**              Generic interface to protocol-specific network routines
**              
**      
**      REVISION HISTORY:
*/
 
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>

#include "riscom.h"
#include "risnet.h"
#include "risnet_stubs.h"

#include "UMS.h"
#include "pums_pub.h"

static int tracex = 0;

#define NET_CLEAR_ERROR(net) \
net->error_code = NET_SUCCESS;\
net->error_string[0] = '\0';\
net->net_error_code = NET_SUCCESS;\
net->net_error_string[0] = '\0';

#define NET_ERROR_RETURN(net) \
{       \
if ((int)(net->error_handler)) (*net->error_handler)(net); \
return net->error_code; \
}       

#define NET_ERROR_CHECK(net) \
if (net->error_code != NET_SUCCESS) \
{ \
	NET_ERROR_RETURN(net); \
} \

#define NET_VALIDATE_PROTOCOL(net) \
if (net->protocol <= NO_PROTOCOL || net->protocol >= LAST_PROTOCOL) \
{ \
	NET_error(net, NET_E_INV_PROTOCOL); \
	NET_ERROR_RETURN(net); \
}

#define NET_VALIDATE_CS_FLAG(net) \
if (net->cs_flag != CLIENT_FLAG && net->cs_flag != SERVER_FLAG) \
{ \
	NET_error(net, NET_E_INV_CS_FLAG); \
	NET_ERROR_RETURN(net); \
}

#define DONT_SEND_LENGTH	0
#define SEND_LENGTH		1

#define DONT_RECEIVE_LENGTH	0
#define RECEIVE_LENGTH		1

static  char lock_file_name[MAX_PATH_SIZE];
static void (*NET_funcs[LAST_PROTOCOL][NET_LAST_FUNC])() =
{
	{
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	},
	{
		NET_connect_xns,                NET_accept_xns,                 NET_write_xns,
		NET_read_xns,                   NET_close_xns,                  NET_addr_xns,
		NET_node_xns,                   NET_get_file_xns,               NET_put_file_xns,
		NET_get_lock_file_xns,  NET_put_lock_file_xns,  NET_remove_file_xns,
	},
	{
		NET_connect_tcp,       NET_accept_tcp,        NET_write_tcp,
		NET_read_tcp,          NET_close_tcp,         NET_addr_tcp,
		NET_node_tcp,          NET_get_file_tcp,      NET_put_file_tcp,
		NET_get_lock_file_tcp, NET_put_lock_file_tcp, NET_remove_file_tcp,
	},
	{
		NET_connect_dnp,                NET_accept_dnp,                 NET_write_dnp,
		NET_read_dnp,                   NET_close_dnp,                  NET_addr_dnp,
		NET_node_dnp,                   NET_get_file_dnp,               NET_put_file_dnp,
		NET_get_lock_file_dnp,  NET_put_lock_file_dnp,  NET_remove_file_dnp,
	},
	{
		NET_connect_lu62,               NET_accept_lu62,                NET_write_lu62,
		NET_read_lu62,                  NET_close_lu62,                 NET_addr_lu62,
		NET_node_lu62,                  NET_get_file_lu62,              NET_put_file_lu62,
		NET_get_lock_file_lu62, NET_put_lock_file_lu62, NET_remove_file_lu62,
	},
	{
		0,0,0,0,0,0,0,0,0,0,0,0
	},
	{
		NET_connect_local,              NET_accept_local,               NET_write_local,
		NET_read_local,                 NET_close_local,                NET_addr_local,
		NET_node_local,                 NET_get_file_local,             NET_put_file_local,
		NET_get_lock_file_local,NET_put_lock_file_local,NET_remove_file_local,
	}
};

static char     message_type[] = { 'W', 'S', 'E', 'I', 'F', 'P', 'M' };

#if defined(WIN32)
SOCKET asd, closesd;
#endif

/*
**      FUNCTIONS
*/

/******************************************************************************/

/* open a connection with a remote server */

extern int NET_connect(
	net_s                   *net,                   /* pointer to net structure */
	net_connect_s   *connect_info)  /* union containing connect information */
{
	NET_DBG(("NET_connect(net:0x%x connect_info:0x%x)\n",
		net, connect_info));

	NET_CLEAR_ERROR(net);

	NET_VALIDATE_PROTOCOL(net);
	if (net->cs_flag != CLIENT_FLAG)
	{
		NET_error(net, NET_E_INV_CS_FLAG);
		NET_ERROR_RETURN(net);
	}

	net->connection_open = 1;

	if (net->protocol > NO_PROTOCOL && net->protocol < LAST_PROTOCOL)
	{
		(*NET_funcs[net->protocol][NET_CONNECT]) (net, connect_info);
	}
	else
	{
		NET_DBG(("NET_connect: invalid protocol: %d\n", net->protocol));
		NET_error(net, NET_E_INV_PROTOCOL);
	}
	if (net->error_code != NET_SUCCESS)
	{
		net->connection_open = 0;
		NET_ERROR_RETURN(net);
	}

	NET_DBG(("NET_connect: returning NET_SUCCESS\n"));
	return NET_SUCCESS;
}

/******************************************************************************/

/* accept a server */

extern int NET_accept(
	net_s                   *net)
{
	NET_DBG(("NET_accept(net:0x%x)\n", net));

	NET_CLEAR_ERROR(net);

	NET_VALIDATE_PROTOCOL(net);

#if defined(unix) || defined(WIN32) || defined(vms)
	if (net->protocol == TCP)
	{
#if defined(unix)
		net->id.tcp.server.infildes = NET_dup(0);
		net->id.tcp.server.outfildes = NET_dup(1);
#endif
#if defined(WIN32)
		net->id.tcp.server.infildes = asd;
		net->id.tcp.server.outfildes = asd;
		NET_DBG(("NET_accept: asd %d\n", asd));
#endif
		NET_fclose(stdin);
		NET_fclose(stdout);
		NET_fclose(stderr);
	}

	(*NET_funcs[net->protocol][NET_ACCEPT])(net);
	NET_ERROR_CHECK(net);

#endif
	net->connection_open = 1;

	NET_DBG(("NET_accept: returning SUCCESS\n"));
	return NET_SUCCESS;
}

/******************************************************************************/

extern int NET_invalidate_connection(net_s *net)
{
	NET_DBG(("NET_invalidate_connection(net:0x%x)\n", net));

	if (net)
	{
		net->connection_open = 0;
	}

	NET_DBG(("NET_invalidate_connection: returning NET_SUCCESS\n"));
	return NET_SUCCESS;
}

/******************************************************************************/

/*
**  blocking = -1 ==> non blocking
**  blocking =  0 ==> blocking indefinitely
**  blocking >= 1 ==> blocking with timeout
*/
/* write a buffer */

extern int NET_write(
	net_s   *net,           /* net structure filled in by connect/accept */
	char    *buffer,        /* pointer to buffer */
	int     *len,           /* length of data to send */
	int     blocking)       /* see above */
{
	NET_DBG(("NET_write(net:0x%x buffer:0x%x *len:%d blocking:%d)\n",
		net, buffer, *len, blocking));

	NET_CLEAR_ERROR(net);

	NET_VALIDATE_PROTOCOL(net);
	NET_VALIDATE_CS_FLAG(net);

	if (!net->connection_open)
	{
		NET_error(net, NET_E_WRITE_ERROR);
		NET_ERROR_RETURN(net);
	}

	if (*len < 0)
	{
		NET_error(net, NET_E_WRITE_LEN_ERROR);
		NET_ERROR_RETURN(net);
	}

	(NET_funcs[net->protocol][NET_WRITE])(net, buffer, len, blocking,
		SEND_LENGTH);
	NET_ERROR_CHECK(net);

	NET_DBG(("NET_write: *len:%d\nNET_write: returning NET_SUCCESS\n", *len));
	return NET_SUCCESS;
}

/******************************************************************************/

/*
**  blocking = -1 ==> non blocking
**  blocking =  0 ==> blocking indefinitely
**  blocking >= 1 ==> blocking with timeout
*/

/*      Send a buffer without prepending the length */

extern int NET_write_no_len(
	net_s   *net,           /* net structure filled in by connect/accept */
	char    *buffer,        /* pointer to buffer */
	int     *len,           /* length of data to send */
	int     blocking)       /* see above */
{
	NET_DBG(("NET_write_no_len(net:0x%x buffer:0x%x *len:%d blocking:%d)\n",
		net, buffer, *len, blocking));

	NET_CLEAR_ERROR(net);

	NET_VALIDATE_PROTOCOL(net);
	NET_VALIDATE_CS_FLAG(net);

	if (!net->connection_open)
	{
		NET_error(net, NET_E_WRITE_ERROR);
		NET_ERROR_RETURN(net);
	}

	if (*len < 0)
	{
		NET_error(net, NET_E_WRITE_LEN_ERROR);
		NET_ERROR_RETURN(net);
	}

	(NET_funcs[net->protocol][NET_WRITE])(net, buffer, len, blocking, 
		DONT_SEND_LENGTH);
	NET_ERROR_CHECK(net);

	NET_DBG(("NET_write_no_len:*len:%d\n NET_write_no_len: returning NET_SUCCESS\n", *len));

	return NET_SUCCESS;
}

/******************************************************************************/

/*
**  blocking = -1 ==> non blocking
**  blocking =  0 ==> blocking indefinitely
**  blocking >= 1 ==> blocking with timeout
*/

/* read a buffer */

extern int NET_read(
	net_s                   *net,           /* net structure filled in by connect/accept */
	char                    *buffer,        /* pointer to buffer */
	int                             *len,           /* pointer to length of read buffer; will be 
									filled in with actual length read */
	int                             blocking)       /* see above */
{
	NET_DBG(("NET_read(net:0x%x buffer:0x%x len:0x%x blocking:%d)\n",
		net, buffer, len, blocking));

#if defined(__hpux__)
         NET_DBG(("NET_read : net->protocol is <%d> \n",net->protocol));
         NET_DBG(("NET_read : NET_READ is <%d> \n",NET_READ));
#endif

	NET_CLEAR_ERROR(net);

	*len = 0;

	NET_VALIDATE_PROTOCOL(net);
	NET_VALIDATE_CS_FLAG(net);

	if (!net->connection_open)
	{
		NET_error(net, NET_E_READ_ERROR);
		NET_ERROR_RETURN(net);
	}

	(NET_funcs[net->protocol][NET_READ])(net, buffer, len, blocking,
		RECEIVE_LENGTH);
	NET_ERROR_CHECK(net);

	NET_DBG(("NET_read: *len:%d\nNET_read: returning NET_SUCCESS\n", *len));
	return NET_SUCCESS;
}

/******************************************************************************/

/*
**  blocking = -1 ==> non blocking
**  blocking =  0 ==> blocking indefinitely
**  blocking >= 1 ==> blocking with timeout
*/

/* read a buffer */

extern int NET_read_no_len(
	net_s                   *net,           /* net structure filled in by connect/accept */
	char                    *buffer,        /* pointer to buffer */
	int                             *len,           /* pointer to how many bytes to read */
	int                             blocking)       /* see above */
{
	NET_DBG(("NET_read_no_len(net:0x%x buffer:0x%x len:0x%x blocking:%d)\n",
		net, buffer, len, blocking));

	NET_CLEAR_ERROR(net);

	NET_VALIDATE_PROTOCOL(net);
	NET_VALIDATE_CS_FLAG(net);

	if (!net->connection_open)
	{
		NET_error(net, NET_E_READ_ERROR);
		NET_ERROR_RETURN(net);
	}
	if (*len < 0)
	{
		NET_error(net, NET_E_READ_LEN_ERROR);
		NET_ERROR_RETURN(net);
	}

	(NET_funcs[net->protocol][NET_READ])(net, buffer, len, blocking,
		DONT_RECEIVE_LENGTH);
	NET_ERROR_CHECK(net);

	NET_DBG(("NET_read_no_len: *len:%d\nNET_read_no_len: returning NET_SUCCESS\n", *len));
	return NET_SUCCESS;
}

/******************************************************************************/

/* close a network connection */

extern int NET_close(net_s *net)
{
	NET_DBG(("NET_close(net:0x%x)\n", net));

	NET_CLEAR_ERROR(net);

	NET_VALIDATE_PROTOCOL(net);
	NET_VALIDATE_CS_FLAG(net);

	(*NET_funcs[net->protocol][NET_CLOSE])(net);
	NET_ERROR_CHECK(net);

	net->connection_open = 0;

	NET_DBG(("NET_close: returning NET_SUCCESS\n"));
	return NET_SUCCESS;
}

/******************************************************************************/

extern int NET_finish(net_s *net, net_finish_s *finish_info)
{
	NET_DBG(("NET_finish(net:0x%x finish_info:0x%x)\n", net, finish_info));

	NET_CLEAR_ERROR(net);

#if defined(unix) || defined(WIN32)
	if (NET_mem)
	{
		if (finish_info->memory_mode == DEALLOCATE)
		{
			NET_dealloc_shmem(net);
		}
		else /*(finish_info->memory_mode == DETACH)*/
		{
			NET_detach_shmem(net);
		}
		NET_mem = (net_mem_info_s *)0;
		NET_ERROR_CHECK(net);
	}
#endif
#if defined(WIN32)
	/*
	**      NET_finish is called when all networking is complete, so call
	**      NET_cleanup_tcp, regardless of the values of net->protocol, because
	**      there may have been a tcp connection at some time.
	*/
	NET_cleanup_tcp();
	NET_cleanup_lu62();
#endif

	NET_DBG(("NET_finish: returning NET_SUCCESS\n"));
	return NET_SUCCESS;
}

/******************************************************************************/

/* given a symbolic node name, get the protocol-specific network address */

extern int NET_address(
	net_s	*net,		/* net structure containing protocol */
	char	*nodename,	/* nodename for which to get address */
	char	*netaddr,	/* pointer to buffer to copy address into */
	int		*len)		/* pointer to length of netaddr buffer */
{
	NET_DBG(("NET_address(net:0x%x nodename:<%s> netaddr:0x%x *len:%d)\n",
		net, nodename ? nodename : "NULL", netaddr, *len));

	NET_CLEAR_ERROR(net);
	NET_VALIDATE_PROTOCOL(net);

	if (nodename && *nodename)
	{
		(*NET_funcs[net->protocol][NET_ADDRESS]) (net, nodename, netaddr, len);
	}
	else
	{
		NET_DBG(("NET_address: invalid address\n"));
		NET_error(net, NET_E_ADDR_ERROR);
	}
	NET_ERROR_CHECK(net);

	NET_DBG(("NET_address: netaddr:<%s>\nNET_address: returning NET_SUCCESS\n",
		netaddr));
	return NET_SUCCESS;
}

/******************************************************************************/

/* get the local symbolic nodename (can be different for each protocol) */

extern int NET_nodename(
	net_s   *net,                   /* net structure containing protocol */
	char    *nodename,              /* pointer to buffer to copy local nodename into */
	int             *len)                   /* pointer to length of nodename buffer */
{
	NET_DBG(("NET_nodename(net:0x%x nodename:0x%x *len:%d)\n",
		net, nodename, *len));

	NET_CLEAR_ERROR(net);

	NET_VALIDATE_PROTOCOL(net);

	(*NET_funcs[net->protocol][NET_NODE])(net, nodename, len);
	NET_ERROR_CHECK(net);

	NET_DBG(("NET_nodename: nodename:<%s>\nNET_nodename: returning NET_SUCCESS\n",nodename));
	return NET_SUCCESS;
}

/******************************************************************************/

/*
** Make a copy of the remote file on this node using the file name given.
*/

extern int NET_get_file(
	net_s                   *net,                   /* pointer to net structure with protocol*/
	net_connect_s   *connect_info,  /* union containing connect information */
	char                    *remote_file,   /* remote file name */
	char                    *local_file)    /* local file name */
{
	NET_DBG(("NET_get_file(net:0x%x remote_file:<%s> local_file:<%s>)\n",
		net, remote_file,local_file));

	NET_CLEAR_ERROR(net);

	NET_VALIDATE_PROTOCOL(net);

	(*NET_funcs[net->protocol][NET_GET_FILE])(net, connect_info, remote_file,
		local_file);
	NET_ERROR_CHECK(net);

	NET_DBG(("NET_get_file: returning NET_SUCCESS\n"));
	return NET_SUCCESS;
}

/******************************************************************************/

/*
** Put a copy of a local file on a remote node using the file name given.
*/

extern int NET_put_file(
	net_s                   *net,                   /* pointer to net structure with protocol*/
	net_connect_s   *connect_info,  /* union containing connect information */
	char                    *local_file,    /* local file name */
	char                    *remote_file)   /* remote file name */
{
	NET_DBG(("NET_put_file(net:0x%x local_file:<%s> remote file:<%s>)\n",
		net,local_file,remote_file));

	NET_CLEAR_ERROR(net);

	NET_VALIDATE_PROTOCOL(net);

	(*NET_funcs[net->protocol][NET_PUT_FILE])(net, connect_info, local_file,
		remote_file);
	NET_ERROR_CHECK(net);

	NET_DBG(("NET_put_file: returning NET_SUCCESS\n"));
	return NET_SUCCESS;
}

/******************************************************************************/

/*
** Remove the lock file from the remote node to indicate a lock.
*/

extern int NET_get_lock_file(
	net_s                   *net,                   /* pointer to net structure with protocol*/
	net_connect_s   *connect_info,  /* union containing connect information */
	char                    *remote_file)   /* remote file name */
{
	NET_DBG(("NET_get_lock_file(net:0x%x connect_info:0x%x remote_file:<%s>)\n",
		net, connect_info, remote_file));

	NET_CLEAR_ERROR(net);

	NET_VALIDATE_PROTOCOL(net);

	(*NET_funcs[net->protocol][NET_GET_LOCK_FILE])(net, connect_info,
		remote_file);
	NET_ERROR_CHECK(net);

	strcpy(lock_file_name,remote_file);

	NET_DBG(("NET_get_lock_file: returning NET_SUCCESS\n"));
	return NET_SUCCESS;
}

/******************************************************************************/

/*
** Replace the lock file on the remote node to indicate no lock.
*/

extern int NET_put_lock_file(
	net_s                   *net,                   /* pointer to net structure with protocol*/
	net_connect_s   *connect_info,  /* union containing connect information */
	char                    *remote_file)   /* remote file name */
{
	NET_DBG(("NET_put_lock_file(net:0x%x connect_info:0x%x remote_file:<%s>)\n",
		net, connect_info, remote_file ? remote_file : "NULL"));

	NET_CLEAR_ERROR(net);

	NET_VALIDATE_PROTOCOL(net);

	if (remote_file)
	{
		(*NET_funcs[net->protocol][NET_PUT_LOCK_FILE])(net, connect_info,
			remote_file);
	}
	else if (lock_file_name[0])
	{
		(*NET_funcs[net->protocol][NET_PUT_LOCK_FILE])(net, connect_info,
			lock_file_name);
	}
	else
	{
		NET_error(net, NET_E_NO_LOCK_FILE_NAME);
	}
	NET_ERROR_CHECK(net);

	lock_file_name[0] = '\0';

	NET_DBG(("NET_put_lock_file: returning NET_SUCCESS\n"));
	return NET_SUCCESS;
}

/******************************************************************************/

/*
** Remove a file from the remote node.
*/

extern int NET_remove_file(
	net_s                   *net,                   /* pointer to net structure with protocol*/
	net_connect_s   *connect_info,  /* union containing connect information */
	char                    *remote_file)   /* remote file name */
{
	NET_DBG(("NET_remove_file(net:0x%x connect_info:0x%x remote_file:<%s>)\n",
		net, connect_info, remote_file));

	NET_CLEAR_ERROR(net);

	NET_VALIDATE_PROTOCOL(net);

	(*NET_funcs[net->protocol][NET_REMOVE_FILE])(net,connect_info,remote_file);
	NET_ERROR_CHECK(net);

	NET_DBG(("NET_remove_file: returning NET_SUCCESS\n"));
	return NET_SUCCESS;
}

/******************************************************************************/

extern int NET_init_lang(net_s *net, char *ums_file)
{
	NET_DBG(("NET_init_lang(net:0x%x ums_file:<%s>)\n",
		net, ums_file ? ums_file : "NULL"));

	strcpy(NET_ums_file, ums_file);

	NET_DBG(("NET_init_lang:returning NET_SUCCESS\n"));
	return NET_SUCCESS;
}

/******************************************************************************/

extern char *NET_error_code(int code)
{
	int status;
	char    *ptr;
	char    temp_key[100];
	static  char     ums_key[100];

	NET_DBG(("NET_error_code(code:0x%x)\n", code));

	if (code == NET_SUCCESS)
	{
		strcpy(ums_key, "NET_SUCCESS"); 
	}
	else
	{
		status = NET_init_error_msg();
		if (!status)
		{

#ifdef UMS_SUPPORTED
			status = UMSGetKeyByNum (temp_key, 0, code & 0x7fffffff);
			if (status != UMS_S_SUCCESS)
			{
				NET_DBG(("NET_error_code: Error name not found for 0x%x "
					"status:%d  0x%x\n", code, status, status));
				sprintf(ums_key, "Error name not found for 0x%x",code);
			}
			else
			{
				if ((ptr = strchr(temp_key, ':')) == NULL)
				{
					NET_DBG(("NET_error_code: no colon found in key.\n"));
					strcpy(ums_key, temp_key);
				}
				else
				{
					*ptr++ = '\0';
					sprintf(ums_key, "%s_%c_%s", temp_key,
						message_type[code & 0x00000007], ptr);
				}
			}
#else /* UMS NOT supported */
			sprintf(ums_key, "Message file not found for 0x%x",code);       
#endif /* UMS or NO UMS */
		}
		else
		{
			sprintf(ums_key, "Message file not found for 0x%x",code);       
		}
	}
	
	NET_DBG(("NET_error_code: ums_key: <%s>\n", ums_key));
	return ums_key;
}

/******************************************************************************/

extern char *NET_alloc(int size)
{
	char                    *ptr;
	net_buffer_s    		*buffer=NULL;

	NET_DBG(("NET_alloc(size:%d)\n", size));
  
  if (tracex) printf(">>> NET_alloc %d\n",size);

		/*
		** SCO_PROBLEM
		** intel chip does not require doubles to be 8-byte aligned, so
		** malloc can return something that is only 4-byte aligned.
		** Our assumption has been that malloc always returned something
		** 8-byte aligned.  This means that we may have to adjust our pointer
		** 4 more bytes over, so we allocate an extra 8 bytes (to keep things
		** aligned when they were aligned to begin with), and then adjust
		** the net_buffer_s/user_buffer 4 bytes left if necessary.
		** When we de/reallocate, we will only know the user
		** buffer, so we need to store how far off from the beginning of the
		** net_buffer_s the real buffer begins.
		**
		** There are assumptions in the code that the two words immediately
		** preceding the data are the buffer size and data length, so in
		** order to remain compatible with existing clients we have to
		** put anything else BEFORE the size/len fields.  This allows us to
		** avoid modifying the standard net_buffer_s structure, yet be
		** sure that it is 8-byte aligned.
		**
		** Case 1: no alignment adjustment required; usr_buffer-12 = offset
		**                      
		**       8 extra    |  normal allocation
		**     +++++++++++++ ===========================
		**    | fill | <8>  | size | len | data ... |
		**             ^___________________^
		**    ^______8______^
		**                      
		**                      
		** Case 2: 4-byte alignment adjustment required; usr_buffer-12 = offset
		**
		**       8 extra    |  normal allocation
		**     +++++++++++++ ===========================
		**             <------ (start was shifted left 4 bytes)
		**    | <4>  | size | len | data ... |
		**      ^___________________^
		**
		**    ^__4___^
		*/

#ifdef OLD
	buffer = (net_buffer_s *)malloc(NET_BUFFER_OFFSET + size);
	if (buffer)
	{
		buffer->size = size;
		ptr = (char *)buffer + NET_BUFFER_OFFSET;
	}
	else
	{
		ptr = (char *)buffer;
	}
#else
	ptr = malloc(NET_BUFFER_OFFSET + size + 8);
	NET_DBG(("NET_alloc(malloc ptr:%d)\n", ptr));
	if (ptr)
	{
		int offset;

			/*
			** use an offset to align the ptr to the next 8-byte boundary
			*/

		if (0x4 & (unsigned)ptr)
		{
			ptr += sizeof(int);
			offset = sizeof(int);
		}
		else
		{
			ptr += (2*sizeof(int));
			offset = (2*sizeof(int));
		}
	
		buffer = (net_buffer_s *)ptr;
		buffer->size = size;   /* this is now usable buffer size */
		ptr = (char *)buffer + NET_BUFFER_OFFSET;

			/*
			** store the offset in the word before the net_buffer_s
			*/

		*(((int *)buffer)-1) = offset;

		NET_DBG(("NET_alloc(buffer: 0x%x) size: %d offset: %d\n", buffer,
				 buffer->size, offset));

	}
#endif
	
	NET_DBG(("NET_alloc: returning 0x%x\n", ptr));
	return ptr;
}

/******************************************************************************/

extern char *NET_realloc(char *user_buffer, int size)
{
	char            *ptr;
	net_buffer_s    *buffer;
	int				offset;

	NET_DBG(("NET_realloc(user_buffer:0x%x size:%d)\n", user_buffer, size));

  if (tracex) printf(">>> NET_realloc %d\n",size);

		/*
		** HYDRA_PROBLEM
		** See description above.
		*/
#ifdef OLD
	buffer = (net_buffer_s *)(user_buffer - NET_BUFFER_OFFSET);

	buffer = (net_buffer_s *)realloc((char *)buffer, NET_BUFFER_OFFSET + size);
	if (buffer)
	{
		buffer->size = size;
		ptr = (char *)buffer + NET_BUFFER_OFFSET;
	}
	else
	{
		ptr = (char *)buffer;
	}
#else
	buffer = (net_buffer_s *)(user_buffer - NET_BUFFER_OFFSET);

		/*
		** The offset to the beginning of the real buffer is in the word 
		** immediately before the net_buffer_s.
		*/

	offset = *(((int *)buffer)-1);
	ptr = ((char *)buffer)-offset;

	ptr = realloc((char *)ptr, NET_BUFFER_OFFSET + size + 8);
	if (ptr)
	{
			/*
			** use an offset to align the ptr to the next 8-byte boundary
			*/

		if (0x4 & (unsigned)ptr)
		{
			ptr += sizeof(int);
			offset = sizeof(int);
		}
		else
		{
			ptr += (2*sizeof(int));
			offset = (2*sizeof(int));
		}
	
		buffer = (net_buffer_s *)ptr;
		buffer->size = size;   /* this is now usable buffer size */
		ptr = (char *)buffer + NET_BUFFER_OFFSET;

			/*
			** store the offset in the word before the net_buffer_s
			*/

		*(((int *)buffer)-1) = offset;

		NET_DBG(("NET_realloc(buffer: 0x%x) size: %d offset: %d\n", buffer,
				 buffer->size, offset));

	}
#endif
	
	NET_DBG(("NET_realloc:returning 0x%x\n", ptr));
	return ptr;
}

/******************************************************************************/

extern void NET_free(char *user_buffer)
{
	net_buffer_s    *buffer;
	char 			*ptr;
	int				offset;

	NET_DBG(("NET_free(user_buffer:0x%x)\n", user_buffer));
  if (tracex) printf(">>> NET_free\n");
#ifdef OLD
		/*
		** HYDRA_PROBLEM
		** See description above.
		*/
	buffer = (net_buffer_s *)(user_buffer - NET_BUFFER_OFFSET);
	free((char *)buffer);
#else
	buffer = (net_buffer_s *)(user_buffer - NET_BUFFER_OFFSET);

		/*
		** The offset to the beginning of the real buffer is in the word 
		** immediately before the net_buffer_s.
		*/

	offset = *(((int *)buffer)-1);
	ptr = ((char *)buffer)-offset;

	free((char *)ptr);
#endif

	NET_DBG(("NET_free:returning\n"));
}

/******************************************************************************/

extern void NET_set_debug_handler(int (*debug_handler)(const char *, ...))
{
	NET_debug_handler = debug_handler;
}

/******************************************************************************/
extern int Net_Error_Return_Function (net_s	*net)
{
	NET_ERROR_RETURN (net) ;
}

