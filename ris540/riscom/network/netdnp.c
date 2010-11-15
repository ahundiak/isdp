/* Do not alter this SPC information: $Revision: 1.2.19.1 $ */
/*
**	NAME:							netdnp.c
**	AUTHORS:						John Gwyer
**	CREATION DATE:					11/89
**	ABSTRACT:
**		Various routines for sending and receiving message buffers
**		across the DNP (DECnet) network interface.
**	
**	REVISION HISTORY:
**
**  02/06/92 - Sunil 
**  Used the source code from /usr/ip32/dnp/strmap.c instead of linking
**  in  "nfars.a". 
**
**	CAUTION !!! CAUTION !!!
**
**  Make sure to update this file to reflect changes in /usr/ip32/dnp/strmap.c
**  
**  Module:	 strmap.c - Map CommUnity Task to Task interface to Streams
**
*******************************************************************************
**  COPYRIGHT (C) 1984, 1985 by TECHNOLOGY CONCEPTS INC.                      *
**                              SUDBURY, MASSACHUSETTS 01776                  *
**                              ---ALL RIGHTS RESERVED---                     *
**                                                                            *
**  THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY BE USED AND COPIED     *
**  ONLY IN ACCORDANCE WITH THE TERMS OF SUCH LICENSE AND WITH THE INCLUSION  *
**  OF THE ABOVE COPYRIGHT NOTICE.  THIS SOFTWARE OR ANY OTHER COPIES THEREOF *
**  MAY NOT BE PROVIDED OR OTHERWISE MADE AVAILABLE TO ANY OTHER PERSON.  NO  *
**  TITLE TO AND OWNERSHIP OF THE SOFTWARE IS HEREBY TRANSFERRED.             *
**                                                                            *
**  THE INFORMATION IN THIS SOFTWARE IS SUBJECT TO CHANGE WITHOUT NOTICE AND  *
**  SHOULD NOT BE CONSTRUED AS A COMMITMENT BY TECHNOLOGY CONCEPTS INC.       *
*******************************************************************************

Version 1  --  Revision 0

Facility: 	CommUnity-Unix Streams
Prefix:  	str
Product:	CommUnity

Author:		Brian O'Shea

Modified by:
      
Module Abstract:	This module is designed to present the CommUnity-Unix
	Task to Task interface to users on systems using CommUnity-Unix STREAMS.
	The strmapioctl, strmapwrite and strmapread routines should behave the
	same as the non-streams CommUnity-Unix ioctl, write and read system calls.


Routines:
	SetBlk()
	GetInt()
	GetShort()
	SetNonBlk()
	strmapread()
	strmapioctl()
	strmapwrite()
*/

#if defined(__clipper__) || defined(vms)
 
/*
**	INCLUDES
*/

#include <ctype.h>

#if defined(vms)
# define VMUNIX
# include <file.h>
# include <ssdef.h>
# include <syidef.h>
#endif

#if defined(__clipper__)
# define SYSV
#endif

#include <stdio.h>
#include <signal.h>
#include <errno.h>

#if defined(__clipper__)
# include <sys/types.h>
# include <sys/stat.h>
# include <sys/ioctl.h>
# include <fcntl.h>
# define STREAMS
# define CUERRORSTART 145
# include <netdnet/comunity.h>
# include <netdnet/nfars.h>
# include <netdnet/nferror.h>
#endif

#include "net.h"

/*
**	DEFINES
*/
#if defined(__clipper__)
# define PERMENANT_FILE	"/usr/lib/permsnt.dat" /* DNP's permanent data base. */
# define GET_NAME 1		/* Get symbolic nodename */
# define GET_ADDR 2		/* Get dnp address  */
# define CommUnity_MIN_ERR_NUM     145
# define CommUnity_MAX_ERR_NUM     199
#endif

#ifdef vms
# define DNREAD(a,b,c)	read(a,b,c)
# define DNWRITE(a,b,c)	write(a,b,c)
#endif

/*
**	TYPES
*/
#if defined(vms)
struct item
{
    unsigned short  len;
    unsigned short  code;
    char            *addr;
    long            *ret_addr;
    unsigned long   empty;
};
#endif

/*
**	FUNCTION PROTOTYPES
*/
#define netdnp_c
#include "netdnp.prt"
#include "netumsg.prt"
#include "netlen.prt"
#include "netshare.prt"
#include "netwrap.prt"
#include "net_sys.prt"

/*
**	VARIABLES
*/
#if defined(__clipper__)
static OpenBlock opblk;

/* Error messages were taken from comments in comunity.h */
static char *dnp_errlist[] =
{
/* 0 */  "Logical link does not exist ",
/* 1 */  "CommUnity software processing error ",
/* 2 */  "Data in the buffer was truncated ",
/* 3 */  "Invalid logical link number specified ",
/* 4 */  "The user program has closed the link ",
/* 5 */  "Insufficient network resources ",
/* 6 */  "Unrecognized node name ",
/* 7 */  "Remote system isn't accepting new links ",
/* 8 */  "Specified remote object does not exist ",
/* 9 */  "Invalid task name ",
/* 10 */ "Insufficient resources at remote node ",
/* 11 */ "Link disconnected by network management ",
/* 12 */ "Link aborted by remote node ",
/* 13 */ "Invalid node or device name ",
/* 14 */ "Local node is not accepting new links ",
/* 15 */ "Remote node rejected access information ",
/* 16 */ "Local node does not have res for link ",
/* 17 */ "Remote node failed to respond ",
/* 18 */ "Destination node is unreachable ",
/* 19 */ "Already reg as server or open as req ",
/* 20 */ "The CommUnity software not initialized ",
/* 21 */ "Timeout of expected msg from controller ",
/* 22 */ "Timeout of expected recv from controller ",
/* 23 */ "Controller reported error on send ",
/* 24 */ "Controller reported error on receive ",
/* 25 */ "Process aborted by interactive user ",
/* 26 */ "Invalid access attempt on read or write ",
/* 27 */ "No data available for non-blocking read ",
/* 28 */ "Invalid value in SesRecord status field ",
/* 29 */ "Size of I/O request is neg. or too large ",
/* 30 */ "Out of space on controller ",
/* 31 */ "Unidentified controller failure ",
/* 32 */ "Bad command or ioctl request function ",
/* 33 */ "Flow control problem ",
/* 34 */ "Bad parameter value ",
/* 35 */ "Unused error number ",
/* 36 */ "Partner closed link, data available ",
/* 37 */ "Interrupt data contained in data buffer ",
/* 38 */ "Buffer contains beginning of a message ",
/* 39 */ "Buffer contains middle of a message ",
/* 40 */ "Buffer contains end of a message ",
/* 41 */ "Buffer contains a complete message ",
/* 42 */ "Unused error number ",
/* 43 */ "Unused error number ",
/* 44 */ "Unused error number ",
/* 45 */ "Unidentified error sent by remote node ",
/* 46 */ "Duplicate node name detected ",
/* 47 */ "Duplicate node number detected ",
/* 48 */ "Node Records require node numbers ",
/* 49 */ "Function not yet supported ",
/* 50 */ "Driver busy with another request ",
/* 51 */ "Protocol still initializing ",
/* 52 */ "Streams Datalink Provider not linked ",
/* 53 */ "Streams CommUnity Stack not linked ",
/* 54 */ "Out of sequence data message recieved ",
};
#endif

#ifdef vms
extern noshare char *sys_errlist[];
extern noshare int sys_nerr;
#endif

#if defined(__clipper__)
extern char *sys_errlist[];
extern int sys_nerr;
#endif

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void NET_connect_dnp(
	net_s			*net,
	net_connect_s	*connect_info)
{
#if defined(__clipper__)
	int i;
	OpenBlock   opblk;	/* OpenBlock typedef is defined in comunity.h */
	IoOptions	opt;

    net->id.dnp.logical_link = 0;

	/* open the logical link device  -  /dev/ll  */
	if ((net->id.dnp.logical_link = NET_open("/dev/ll", O_RDWR)) < 0)
	{
		/* handle error and leave */
		net->id.dnp.logical_link = 0;
        NET_error_dnp(net, NET_E_DNP_OPEN_LL, "");
        return;
	}

    NET_DBG(("NET_connect_dnp: opened ll:%d\n", net->id.dnp.logical_link));

	/* define the data to start up the remote program */

	strcpy(opblk.op_node_name, connect_info->dnp.node_name);
	if (*connect_info->dnp.task_name)
	{	/* there is a taskname, so there cannot be a object number */
		if (connect_info->dnp.object_nbr)
		{
			NET_sys_close(net->id.dnp.logical_link);
			net->id.dnp.logical_link = 0;
        	NET_error_dnp(net, NET_E_DNP_BOTH_TASK_OBJNUM, "");
       		return;
		}
		strcpy(opblk.op_task_name, connect_info->dnp.task_name);
		opblk.op_object_nbr = 0;
	}
	else
	{	/* no taskname, therefore must have an object number */
		if (connect_info->dnp.object_nbr == 0)
		{
			NET_sys_close(net->id.dnp.logical_link);
			net->id.dnp.logical_link = 0;
        	NET_error_dnp(net, NET_E_DNP_NEITHER_TASK_OBJNUM, "");
       		return;
		}
		opblk.op_object_nbr = connect_info->dnp.object_nbr;
		opblk.op_task_name[0] = 0;
	}

	opblk.op_account[0]  = 0;
	opblk.op_password[0] = 0;

	if (*connect_info->dnp.userid)
	{
		strcpy(opblk.op_userid, connect_info->dnp.userid); 
	}
	else
	{
		opblk.op_userid[0] = '\0';
	}

	if (*connect_info->dnp.password)
	{
		strcpy( opblk.op_password, connect_info->dnp.password);
	}
	else
	{
		opblk.op_password[0] = '\0';
	}

    NET_DBG(("NET_connect_dnp: addr:<%s> prog:%d task:<%s> user:<%s>\n",
		opblk.op_node_name, opblk.op_object_nbr, opblk.op_task_name,
		opblk.op_userid));

	/* define data that remote server will test to verify correct hookup */

	opblk.op_opt_data.im_length = 0;
    opblk.op_opt_data.im_rsvd = 0;           /* Reserved fields  */
    for ( i=0; i<RSVD_LEN; i++ )             /* must be zero     */
        opblk.op_rsvd[i] = 0;

	/* make a logical link request to the remote program */
	/*    - start up interprocess communication -        */

    if ( i = DNIOCTL( net->id.dnp.logical_link, SES_LINK_ACCESS, (char *)&opblk ))
	{
		NET_DBG(("NET_connect_dnp: got error %d (errno: %d)\n", i, errno));
		NET_sys_close(net->id.dnp.logical_link);
		net->id.dnp.logical_link = 0;
        NET_error_dnp(net, NET_E_CONNECT_ERROR, "");
        return;
	}

	opt.io_record=0;		/* stream format */
	opt.io_nonblocking=1;   /* non-blocking read and write */
	opt.io_rsvd[0] = 0;     /* must be zero */
	opt.io_rsvd[1] = 0;		/* must be zero */
	opt.io_signo=0;

	if (DNIOCTL(net->id.dnp.logical_link, SES_IO_TYPE, (char *)&opt))
	{
		NET_DBG(("NET_connect_dnp: error %d setting data format and i/o mode\n",
			errno));
		NET_error_dnp(net, NET_E_DNP_IO_TYPE, "");
		NET_sys_close(net->id.dnp.logical_link);
		net->id.dnp.logical_link = 0;
		return;
	}
#endif /* if defined(__clipper__) */
}

/******************************************************************************/

extern void NET_accept_dnp(
	net_s *net)
{
#if defined(__clipper__)
	static SessionData sd = {0,{0,""}, {0,0,0,0}};
	IoOptions opt;
#endif

	/* 
	**	logical_link was 0 in versions prior to 2.2.10
	*/
	net->id.dnp.logical_link = 3;

	NET_DBG(("NET_accept_dnp(net: 0x%x)\n", net));

#if defined(__clipper__)
	/* receive a request */

	if (DNIOCTL( net->id.dnp.logical_link, SES_GET_AI, (char *)&opblk ))
	{
		NET_DBG(("NET_accept_dnp 0x%x: could not receive a request - error: %d\n", net, errno));
		NET_error_dnp(net, NET_E_DNP_GET_AI, "");
		NET_sys_close(net->id.dnp.logical_link);
		net->id.dnp.logical_link = 0;
		return;
	}

	/*  accept the request */
	NET_DBG(("NET_accept_dnp 0x%x:  accepting the request\n", net));

	if (DNIOCTL(net->id.dnp.logical_link, SES_ACCEPT, (char *)&sd))
	{
		NET_DBG(("NET_accept_dnp 0x%x: error %d accepting request\n", net, errno));
		NET_error_dnp(net, NET_E_ACCEPT_ERROR, "");
		NET_sys_close( net->id.dnp.logical_link );
		net->id.dnp.logical_link = 0;
		return;
	}

	NET_DBG(("NET_accept_dnp 0x%x: request accepted\n", net));

	/* now select the data format and I/O mode */

	opt.io_record=0;		/* stream format */
	opt.io_nonblocking=1;   /* non-blocking read and write */
	opt.io_rsvd[0] = 0;     /* must be zero */
	opt.io_rsvd[1] = 0;		/* must be zero */
	opt.io_signo=0;

	if (DNIOCTL(net->id.dnp.logical_link, SES_IO_TYPE, (char *)&opt))
	{
		NET_DBG(("NET_accept_dnp 0x%x: error %d setting data format and i/o mode\n", net, errno));
		NET_error_dnp(net, NET_E_DNP_IO_TYPE, "");
		NET_sys_close(net->id.dnp.logical_link);
		net->id.dnp.logical_link = 0;
		return;
	}
#endif

#if defined(vms)
	net->id.dnp.logical_link = open ("SYS$NET", O_RDWR);
	if (net->id.dnp.logical_link == -1)
	{
		NET_DBG(("NET_accept_dnp 0x%x: error %d accepting request\n", net, errno));
		NET_error_dnp(net, NET_E_ACCEPT_ERROR, "");
		NET_sys_close(net->id.dnp.logical_link);
		net->id.dnp.logical_link = 0;
		return;
	}

#endif
}

/******************************************************************************/

extern void NET_write_dnp(
	net_s			*net,
	char			*user_buffer,
	int				*user_lenp,
	int				blocking,
	int				send_length_flag)
{
	int				sts;
	int				length;
	int				bytes_written;
	int				bytes_to_write;
	char			*data;
	net_buffer_s	*buffer;
	time_t          start_time;
	time_t          time_remaining;
#if defined(__clipper__)
	fd_set			writefds;
	fd_set			exceptfds;
    struct timeval	timeout;
#endif


	NET_DBG(("NET_write_dnp(net:0x%x user_buffer:0x%x *user_lenp:%d blocking:%d send_length_flag:%d)\n", net, user_buffer, *user_lenp, blocking, send_length_flag));

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

	NET_DBG(("NET_write_dnp:loglink:%d data:0x%x (actual)bytes_to_write:%d\n",
		net->id.dnp.logical_link, data, bytes_to_write));

    /*
    **  This could be blocking with or without time out value or non blocking
    **  blocking == -1 ==> non blocking
    **  blocking ==  0 ==> blocking indefinately
    **  blocking >=  1 ==> blocking with time out value
    */


#if defined(__clipper__)
    /*
    **  blocking
    */

    /*
    ** Initial timeout
    */
    timeout.tv_sec  = (long) blocking;
    timeout.tv_usec = 0;
    time(&start_time);
    NET_DBG(("NET_write_dnp: start_time = %d\n", start_time));

    while(blocking >= 0)
    {
        FD_ZERO(&writefds);
        FD_ZERO(&exceptfds);
        FD_SET(net->id.dnp.logical_link, &writefds);
        FD_SET(net->id.dnp.logical_link, &exceptfds);

        NET_DBG(("NET_write_dnp: calling select\n"));

        /*
        **  blocking with timeout
        */
        if( blocking >= 1 )
        {
            sts = select(FD_SETSIZE, NULL, &writefds, &exceptfds, &timeout);
        }
        else
        {
            sts = select(FD_SETSIZE, NULL, &writefds, &exceptfds, NULL);
        }
        NET_DBG(("NET_write_dnp: select return sts:%d\n", sts));
        if (sts < 0)
        {
            if (errno == EINTR)
            {
				if (blocking == BLOCKING)
				{
					NET_DBG(("NET_write_dnp: select interrupted...continuing\n"
					 ));
					continue;
				}
				else
				{
                    time_remaining = NET_get_remaining_time(&start_time,
						(time_t)timeout.tv_sec);
                    if( time_remaining > 0 )
                    {
                        NET_DBG(("NET_write_dnp:select interrupted "));
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
                        NET_DBG(("NET_write_dnp: select timed out\n"));
                        NET_error_dnp(net, NET_E_TIMEOUT, "");
                        return;
                    }
				}
            }

            NET_DBG(("NET_write_dnp: select error: errno:%d\n", errno));
            NET_error_dnp(net, NET_E_WRITE_ERROR, "");
            return;
        }
        else if (sts == 0)
        {
           	NET_DBG(("NET_write_dnp: select timed out\n"));
           	NET_error_dnp(net, NET_E_TIMEOUT, "");
           	return;
        }
        else
        {
            NET_DBG(("NET_write_dnp:FD_ISSET(except):%s FD_ISSET(write):%s\n",
                FD_ISSET(net->id.dnp.logical_link, &exceptfds) ? "YES" : "NO",
                FD_ISSET(net->id.dnp.logical_link, &writefds) ? "YES" : "NO"));
            break;
        }
    }
#endif

	while (bytes_written < bytes_to_write)
	{
		length = MIN(MAX_DNP_BUFFER_SIZE, bytes_to_write - bytes_written);
		NET_DBG(("NET_write_dnp: calling DNWRITE, length:%d\n", length));
		sts = DNWRITE(net->id.dnp.logical_link, data + bytes_written, length);
		if (sts < 0)
		{
			NET_DBG(("NET_write_dnp: DNWRITE returned %d errno:%d\n",
				sts,errno));
#if defined(__clipper__)
			if (errno == FLOW_CONTROL)
			{
				NET_DBG(("NET_write_dnp: write returned -1 FLOW_CONTROL\n"));
                if( blocking != BLOCKING && bytes_written == 0)
                {
                    NET_DBG(("NET_write_dnp: FLOW_CONTROL\n"));
					NET_error_dnp(net, NET_E_TIMEOUT, "");
                    return;
                }
				continue;
			}
#endif
			if (errno == EINTR)
			{
				continue;
			}

			NET_error_dnp(net, NET_E_WRITE_ERROR, "");
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

	NET_DBG(("NET_write_dnp: *user_lenp:%d\nNET_write_dnp:returning\n",
		*user_lenp));
}

/******************************************************************************/

extern void NET_read_dnp(
	net_s	*net,
	char	*user_buffer,
	int		*user_lenp,
	int		blocking,
	int		receive_length_flag)
{
	int				sts;
	int				length;
	int				bytes_read;
	int				bytes_to_read;
	char			*data;
	net_buffer_s	*buffer = 0;
    time_t          start_time;
    time_t          time_remaining;
#if defined(__clipper__)
	fd_set			readfds;
	fd_set			exceptfds;
    struct timeval	timeout;
#endif

	NET_DBG(("NET_read_dnp(net:0x%x user_buffer:0x%x user_lenp:0x%x blocking:%d receive_length_flag:%d)\n", net, user_buffer, user_lenp, blocking, receive_length_flag));

	if (receive_length_flag)
	{
		buffer = (net_buffer_s *)(user_buffer - NET_BUFFER_OFFSET);
		bytes_to_read = MIN(buffer->size, MAX_DNP_BUFFER_SIZE);
		data = (char *)buffer->len;
	}
	else
	{
		bytes_to_read = *user_lenp;
		data = user_buffer;
	}
	*user_lenp = 0;
	bytes_read = 0;

	NET_DBG(("NET_read_dnp: logical_link:%d data:0x%x bytes_to_read:%d\n",
		net->id.dnp.logical_link, data, bytes_to_read));

#if defined(__clipper__)

    /*
    **  This could be blocking with or without time out value or non blocking
    **  blocking == -1 ==> non blocking
    **  blocking ==  0 ==> blocking indefinately
    **  blocking >=  1 ==> blocking with time out value
    */

    /*
    **  blocking
    */

    /*
    ** Initial timeout
    */
    timeout.tv_sec  = (long) blocking;
    timeout.tv_usec = 0;
    time(&start_time);
    NET_DBG(("NET_read_dnp: start_time = %d\n", start_time));

	while(blocking >= 0)
	{
		FD_ZERO(&readfds);
		FD_ZERO(&exceptfds);
		FD_SET(net->id.dnp.logical_link, &readfds);
		FD_SET(net->id.dnp.logical_link, &exceptfds);

		NET_DBG(("NET_read_dnp: calling select\n"));

        /*
        **   blocking with timeout
        */
        if( blocking >= 1 )
        {
            sts = select(FD_SETSIZE, &readfds, NULL, &exceptfds, &timeout);
        }
        else
        {
            sts = select(FD_SETSIZE, &readfds, NULL, &exceptfds, NULL);
        }
		NET_DBG(("NET_read_dnp: select return sts:%d\n", sts));
		if (sts < 0)
		{
			if (errno == EINTR)
			{
				if (blocking == BLOCKING)
				{
					NET_DBG(("NET_read_dnp:select interrupted...continuing\n"));
					continue;
				}
				else
				{
                    time_remaining = NET_get_remaining_time(&start_time,
						(time_t)timeout.tv_sec);
                    if( time_remaining > 0 )
                    {
                        NET_DBG(("NET_read_dnp:select interrupted "));
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
						NET_DBG(("NET_read_dnp: select timed out\n"));
						NET_error_dnp(net, NET_E_TIMEOUT, "");
						return;
					}
				}
			}
			NET_DBG(("NET_read_dnp: select error: errno:%d\n", errno));
			NET_error_dnp(net, NET_E_READ_ERROR, "");
			return;
		}
		else if (sts == 0)
		{
			NET_DBG(("NET_read_dnp: select timed out\n"));
			NET_error_dnp(net, NET_E_TIMEOUT, "");
			return;
		}
		else
		{
			NET_DBG(("NET_read_dnp:FD_ISSET(except):%s FD_ISSET(read):%s\n",
				FD_ISSET(net->id.dnp.logical_link, &exceptfds) ? "YES" : "NO",
				FD_ISSET(net->id.dnp.logical_link, &readfds) ? "YES" : "NO"));
			break;
		}
	}
#endif

	while(1)
	{
		length = bytes_to_read;
		NET_DBG(("NET_read_dnp: calling DNREAD: length:%d\n", length));
		sts = DNREAD(net->id.dnp.logical_link, data, length);
		if (sts < 0)
		{
			NET_DBG(("NET_read_dnp: DNREAD returned %d, errno %d\n",sts,errno));
			if (errno == EINTR)
			{
				NET_DBG(("NET_read_dnp: Interupt... continuing\n"));
				continue;
			}

#if defined(__clipper__)
			if (errno == NO_DATA_AVAIL)
			{
				NET_DBG(("NET_read_dnp: NO data...\n"));
				net->error_code = NET_E_TIMEOUT;
				return;
			}
#endif
			NET_error_dnp(net, NET_E_READ_ERROR, "");
			return;
		}

		bytes_read = sts;
		break;
	}

	if (receive_length_flag)
	{
		NET_get_len(buffer->len, &bytes_to_read);
		NET_DBG(("NET_read_dnp: (actual)bytes_to_read:%d\n", bytes_to_read));
		if (bytes_to_read - NET_LEN_FIELD_SIZE > buffer->size)
		{
			NET_DBG(("NET_read_dnp: error: buffer->size:%d bytes_to_read:%d\n",
				buffer->size, bytes_to_read - NET_LEN_FIELD_SIZE));
			NET_error_dnp(net, NET_E_READ_BUFFER_TOO_SMALL, "");
			return;
		}

		while (bytes_read < bytes_to_read)
		{
			/*
			** Read a packet
			*/
			length = MIN(bytes_to_read - bytes_read, MAX_DNP_BUFFER_SIZE);
			NET_DBG(("NET_read_dnp: calling DNREAD: length:%d\n", length));
			sts = DNREAD(net->id.dnp.logical_link, data + bytes_read, length);
			if (sts <= 0)
			{
				NET_DBG(("NET_read_dnp: DNREAD returned %d, errno %d\n",
					sts, errno));
				if (errno == EINTR)
				{
					NET_DBG(("NET_read_dnp: Interupt... continuing\n"));
					continue;
				}

#if defined(__clipper__)
				if (errno == NO_DATA_AVAIL)
				{
					NET_DBG(("NET_read_dnp: NO data...\n"));
					continue;
				}
#endif
				NET_error_dnp(net, NET_E_READ_ERROR, "");
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
	NET_DBG(("NET_read_dnp: *user_lenp:%d\nNET_read_dnp:returning\n",
		*user_lenp));
}

/******************************************************************************/

extern void NET_close_dnp(
	net_s *net)
{
	NET_DBG(("NET_close_dnp(net:0x%x)\n", net));
	if (net->id.dnp.logical_link)
	{
		NET_DBG(("NET_close_dnp: closing link %d\n", net->id.dnp.logical_link));
		NET_sys_close(net->id.dnp.logical_link);
	}
	NET_DBG(("NET_close_dnp:returning\n"));
}

/******************************************************************************/

/* given a symbolic node name, get the dnp network address */

extern void NET_addr_dnp(
	net_s	*net,
	char	*nodename,
	char	*netaddr,
	int		*len)
{
#if defined(__clipper__)
	NET_DBG(("NET_addr_dnp(net:0x%x *nodename: <%s>)\n", net, nodename));

	NET_access_prmnt_dnp_db(GET_ADDR,net,nodename,netaddr,len);

	NET_DBG(("NET_addr_dnp 0x%x: netaddr: <%s>\n", net, netaddr));

#endif
#if defined(vms)
	struct item  itmlst;
    int          stat;
    int          node_area;
    int          node_number;

    itmlst.len      = sizeof(int);
    itmlst.code     = SYI$_NODE_AREA;
    itmlst.addr     = &node_area;
    itmlst.ret_addr = len;
    itmlst.empty    = 0;

    stat = SYS$GETSYIW(0, 0, 0, &itmlst, 0, 0, 0);
    if (stat != SS$_NORMAL)
    {
        NET_DBG(("NET_addr_dnp: Could not get node_area , stat = %d\n",stat));
        return;
    }

    itmlst.len      = sizeof(int);
    itmlst.code     = SYI$_NODE_NUMBER;
    itmlst.addr     = &node_number;
    itmlst.ret_addr = len;
    itmlst.empty    = 0;

    stat = SYS$GETSYIW(0, 0, 0, &itmlst, 0, 0, 0);
    if (stat != SS$_NORMAL)
    {
        NET_DBG(("NET_addr_dnp: Could not get node_number , stat = %d\n",stat));
        return;
    }

	sprintf(netaddr, "%d.%d", node_area, node_number);
	*len = strlen(netaddr);

	NET_DBG(("NET_addr_dnp 0x%x: netaddr: <%s>\n", net, netaddr));
#endif
}

/******************************************************************************/

/* get the local symbolic node name */

extern void NET_node_dnp(
	net_s	*net,
	char	*nodename,
	int		*len)
{
#if defined(__clipper__)
	NET_DBG(("NET_node_dnp(net:0x%x *nodename: <%s>)\n", net, nodename));

	NET_access_prmnt_dnp_db(GET_NAME,net,nodename,0,len);

	NET_DBG(("NET_node_dnp 0x%x: net node name = <%s>\n", net, nodename));
#endif

#if defined(vms)
	struct item  itmlst;
    int          stat;

    itmlst.len      = *len;
    itmlst.code     = SYI$_NODENAME;
    itmlst.addr     = nodename;
    itmlst.ret_addr = len;
    itmlst.empty    = 0;

    stat = SYS$GETSYIW(0, 0, 0, &itmlst, 0, 0, 0);
    if (stat != SS$_NORMAL)
    {
        NET_DBG(("NET_dnp.c: Could not get nodename , stat = %d\n",stat));
        return;
    }


	NET_DBG(("NET_node_dnp 0x%x: net node name = <%s>\n", net, nodename));
#endif
}

/******************************************************************************/

extern void NET_get_file_dnp(
	net_s			*net,
	net_connect_s	*connect_info,
	char			*remote_file,
	char			*local_file)
{
#if defined(__clipper__)
	char buffer[sizeof("netcp '\" \"::'  2>&1") + MAX_ADDRESS_SIZE
	 + MAX_USER_NAME_SIZE + MAX_PASSWORD_SIZE + MAX_PATH_SIZE + MAX_PATH_SIZE +
	 100];
#endif

	NET_DBG(("NET_get_file_dnp 0x%x:\n",net));

#if defined(__clipper__)

/* 	Added by Sunil - Changed the foll. because it seems that the command
**	"netcp 'node_name"userid passwd"::remote_file' local_file"
**	asks for a password even if the password field is null
*/

if (connect_info->dnp.password)
	sprintf(buffer,"netcp '%s\"%s %s\"::%s' %s 2>&1",
		connect_info->dnp.node_name,connect_info->dnp.userid,
		connect_info->dnp.password,remote_file,local_file);
else if (connect_info->dnp.password == 0)
	sprintf(buffer,"netcp -u \"%s\" -p \" \" ::%s %s 2>&1",
		connect_info->dnp.userid, connect_info->dnp.node_name,
		remote_file,local_file);

    NET_execute_command(net, buffer, NET_E_GET_FILE_ERROR, NET_error_dnp,
		"file not found", NET_E_FILE_NOT_FOUND);
	NET_ERRCHK(net);
#endif

	NET_DBG(("NET_get_file_dnp 0x%x got file\n",net));
}

/******************************************************************************/

extern void NET_put_file_dnp(
	net_s			*net,
	net_connect_s	*connect_info,
	char			*local_file,
	char			*remote_file)
{
#if defined(__clipper__)
	char buffer[sizeof("netcp  '\" \"::' 2>&1") + MAX_PATH_SIZE +
	 MAX_ADDRESS_SIZE + MAX_USER_NAME_SIZE + MAX_PASSWORD_SIZE + MAX_PATH_SIZE +
	 100];
#endif

	NET_DBG(("NET_put_file_dnp 0x%x:\n",net));

#if defined(__clipper__)
	sprintf(buffer,"netcp %s '%s\"%s %s\"::%s' 2>&1",
		local_file,connect_info->dnp.node_name,connect_info->dnp.userid,
		connect_info->dnp.password,remote_file);
	NET_execute_command(net,buffer,NET_E_PUT_FILE_ERROR,NET_error_dnp,0,0);
	NET_ERRCHK(net);
#endif

	NET_DBG(("NET_put_file_dnp 0x%x got file\n",net));
}

/******************************************************************************/

extern void NET_get_lock_file_dnp(
	net_s			*net,
	net_connect_s	*connect_info,
	char			*remote_file)
{
#if defined(__clipper__)
	char buffer[sizeof("netrm '\" \"::' 2>&1") + MAX_ADDRESS_SIZE + 
	 MAX_USER_NAME_SIZE + MAX_PASSWORD_SIZE + MAX_PATH_SIZE + 100];
#endif

	NET_DBG(("NET_get_lock_file_dnp 0x%x:\n",net));

#if defined(__clipper__)
	sprintf(buffer,"netrm '%s\"%s %s\"::%s' 2>&1",
		connect_info->dnp.node_name,connect_info->dnp.userid,
		connect_info->dnp.password,remote_file);
    NET_execute_command(net,buffer,NET_E_GET_LOCK_FILE_ERROR, NET_error_dnp,
		"file not found",NET_E_NO_LOCK);
	NET_ERRCHK(net);
#endif

	NET_DBG(("NET_get_lock_file_dnp 0x%x got lock file\n",net));
}

/******************************************************************************/

extern void NET_put_lock_file_dnp(
	net_s			*net,
	net_connect_s	*connect_info,
	char			*remote_file)
{
#if defined(__clipper__)
	char buffer[sizeof("netcp /dev/null '\" \"::' 2>&1") + MAX_ADDRESS_SIZE 
	 + MAX_USER_NAME_SIZE + MAX_PASSWORD_SIZE + MAX_PATH_SIZE + 100];
#endif

	NET_DBG(("NET_put_lock_file_dnp 0x%x:\n",net));

#if defined(__clipper__)
	sprintf(buffer,"netcp /dev/null '%s\"%s %s\"::%s' 2>&1",
		connect_info->dnp.node_name,connect_info->dnp.userid,
		connect_info->dnp.password,remote_file);
    NET_execute_command(net,buffer,NET_E_PUT_LOCK_FILE_ERROR,NET_error_dnp,0,0);
	NET_ERRCHK(net);
#endif

	NET_DBG(("NET_put_lock_file_dnp 0x%x got file\n",net));
}

/******************************************************************************/

extern void NET_remove_file_dnp(
	net_s			*net,
	net_connect_s	*connect_info,
	char			*remote_file)
{
#if defined(__clipper__)
	char buffer[sizeof("netrm '\" \"::' 2>&1") + MAX_ADDRESS_SIZE + 
	 MAX_USER_NAME_SIZE + MAX_PASSWORD_SIZE + MAX_PATH_SIZE + 100];
#endif

	NET_DBG(("NET_remove_file_dnp 0x%x:\n",net));

#if defined(__clipper__)
	sprintf(buffer,"netrm '%s\"%s %s\"::%s' 2>&1",
		connect_info->dnp.node_name,connect_info->dnp.userid,
		connect_info->dnp.password,remote_file);
    NET_execute_command(net,buffer,NET_E_REMOVE_FILE_ERROR, NET_error_dnp,
		"file not found",NET_E_FILE_NOT_FOUND);
	NET_ERRCHK(net);
#endif

	NET_DBG(("NET_remove_file_dnp 0x%x removed file\n",net));
}

/******************************************************************************/

static void NET_error_dnp(
	net_s *net,
	int code,
	char * string)
{
	int i;

	NET_DBG(("NET_error_dnp 0x%x: code: %d\n", net, code));

#if defined(__clipper__)
	/*
	**	fill in protocol specific info first
	*/
	switch(code)
	{
        case NET_E_GET_FILE_ERROR:
        case NET_E_PUT_FILE_ERROR:
        case NET_E_GET_LOCK_FILE_ERROR:
        case NET_E_PUT_LOCK_FILE_ERROR:
        case NET_E_NO_LOCK:
        case NET_E_ADDR_ERROR:
        case NET_E_INVALID_NODE:
            net->net_error_code = 0;
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
		default:
			net->net_error_code = errno;
			if (errno >= CommUnity_MIN_ERR_NUM && 
			 errno <= CommUnity_MAX_ERR_NUM)
			{
				strcpy(net->net_error_string,
				 dnp_errlist[errno - CommUnity_MIN_ERR_NUM]);
			}
			else if (errno >= 0 && errno < sys_nerr)
			{
				strcpy(net->net_error_string, sys_errlist[errno]);
			}
			else
			{
				strcpy(net->net_error_string,"Unknown error number");
			}
		break;
	}
#endif

/*
#ifdef vms
	if (errno)
	{
		strcpy(net->net_error_string, sys_errlist[errno]);
	}
#endif
*/


	/*
	**	fill in generic info
	*/
	switch(code)
	{
		case NET_E_DNP_OPEN_LL:
		case NET_E_DNP_BOTH_TASK_OBJNUM:
		case NET_E_DNP_NEITHER_TASK_OBJNUM:
		case NET_E_DNP_LINK_ACCESS:
			net->error_code = NET_E_CONNECT_ERROR;
			break;

		case NET_E_DNP_GET_AI:
		case NET_E_DNP_IO_TYPE:
			net->error_code = NET_E_ACCEPT_ERROR;
			break;

		default:
			net->error_code = code;
			break;
	}
	strcpy(net->error_string,NET_error_msg(code));

	NET_DBG(("NET_error_dnp: net->error_string:<%s>\n", net->error_string));
	NET_DBG(("NET_error_dnp: net->net_error_string:<%s>\n",
		net->net_error_string));
}

/******************************************************************************/

#if defined(__clipper__)
	/*
	** THIS CODE IS FOR COMUNITY UNIX (CLIPPER DECNET) ONLY
	*/

/*
**  INCLUDE
*/
#include <sys/param.h>
#include <sys/stropts.h>
#include <sys/poll.h>
#include <netdnet/tcistd.h>

/*
**	DEFINES
*/

/* This should work for both client and server */
#define ERRFD	stderr

#define IOCLEN(x)	(((x) >> 16) & 0xff) ;

/*
 * If you want to see whats happening, define STRMAPTST when
 * you compile.
 */
#ifdef STRMAPTST
static void PrBuf() ;
static void PrIoctl() ;
static void PrStrBuf() ;
#define TESTPR( x )				fprintf x 
#define TESTPRIOCTL(x)			PrIoctl(x) 
#define TESTPRBUF(Str, Buf)		PrStrBuf((Str), (Buf)) 
#else /* STRMAPTST */
#define TESTPR( x )
#define TESTPRIOCTL(x)
#define TESTPRBUF(Str, Buf)
#endif


/*
**	LOCAL VARIABLES
*/

/*
 * Try to keep track of Record/Stream mode I/O for
 * each file descriptor used.
 */
/* INGR: change NOFILE to 128; currently the max open fds per process
*/
static char FdStat[128] =
	{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	  0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	} ;

/* The ioctl ALWAYS has an infinite timeout! */
static struct strioctl MapIoctl = { 0, INFTIM } ;


/* 
 *  Routine:			STRMAPIOCTL
 *  Access type:		Public
 *  Abstract:			Map historical ioctl to streams ioctl.
 *  Explicit Inputs:	Fd - File descriptor
 *						Cmd - Ioctl command
 *						Ptr - Pointer to data
 *  Implicit Inputs:	None
 *  Explicit Outputs:	None
 *  Implicit Outputs:	None
 *  Return Value:		None
 *  Side Effects:		IOCLEN() macro may be system dependent.
 */
static int strmapioctl( 
	register short	Fd ,
	register long	Cmd ,
	register char	*Ptr)
{
	int i ;
	register int Ret ;
	
	TESTPR((ERRFD,"Fd = %x, Cmd = %x, Ptr = %x\n",Fd, Cmd, Ptr)) ;

	/* Get sizeof() for the structure from the IOCTL command */
	MapIoctl.ic_len = (int)IOCLEN(Cmd) ;
	MapIoctl.ic_dp = Ptr ;
	MapIoctl.ic_cmd = Cmd ;

	TESTPRIOCTL(&MapIoctl) ;

	switch(Cmd)
		{
	case SES_ACCEPT:
	case SES_NUM_SERVER:
	case SES_LINK_ACCESS:
	case SES_NAME_SERVER:
		/* Initialize record mode state for this Fd */
		FdStat[Fd] = FALSE ;
		break ;

	case SES_IO_TYPE:
		{
		register IoOptions *IoPtr ;

		IoPtr = (IoOptions *)Ptr ;

		if (IoPtr->io_nonblocking)
			{
			TESTPR((ERRFD,"strmapioctl: SES_IO_TYPE, Non Blocking Mode\n")) ;
			if (SetNonBlk(Fd) == -1)
				{
				TESTPR((ERRFD,"strmapioctl: NonBlk Failed, errno %d\n",errno)) ;
				return( -1 ) ;
				}
			}
		else
			{
			TESTPR((ERRFD,"strmapioctl: SES_IO_TYPE, Blocking Mode\n")) ;
			if (SetBlk(Fd) == -1)
				{
				TESTPR((ERRFD,"strmapioctl: Blk Failed, errno %d\n",errno)) ;
				return( -1 ) ;
				}
			}

		if (IoPtr->io_signo)
			{
			if (IoPtr->io_signo != SIGPOLL)
				{
				errno = BAD_PARAMETER ;
				return(-1) ;
				}
			if ((Ret = NET_ioctl(Fd, I_GETSIG, &i)) == -1)
				{
				if (errno != EINVAL)
					return(Ret) ;
				if ((Ret = NET_ioctl(Fd, I_SETSIG, S_INPUT)) == -1)
					{
					return(Ret) ;
					}
				}
			else if ((Ret = NET_ioctl(Fd, I_SETSIG, i | S_INPUT)) == -1)
				{
				return(Ret) ;
				}
			}

		if (IoPtr->io_record)
			{
			TESTPR((ERRFD,"strmapioctl: SES_IO_TYPE, Record Mode\n")) ;
			FdStat[Fd] = TRUE ;
			}
		else
			{
			TESTPR((ERRFD,"strmapioctl: SES_IO_TYPE, Non-Record Mode\n")) ;
			FdStat[Fd] = FALSE ;
			}

		break ;
		}

	case ACCEPT_INT:
		if (GetInt((unsigned char *)Ptr) != SIGPOLL)
			{
			errno = BAD_PARAMETER ;
			return(-1) ;
			}
		if ((Ret = NET_ioctl(Fd, I_GETSIG, &i)) == -1)
			{
			if (errno != EINVAL)
				return(Ret) ;
			if ((Ret = NET_ioctl(Fd, I_SETSIG, S_MSG)) == -1)
				{
				return(Ret) ;
				}
			}
		else if ((Ret = NET_ioctl(Fd, I_SETSIG, i | S_MSG)) == -1)
			{
			return(Ret) ;
			}
		break ;

	default:
		break ;
		}

	Ret = NET_ioctl(Fd, I_STR, &MapIoctl) ;
	if (Ret == -1)
		{
		TESTPR((ERRFD,"strmapioctl: Failed, errno = %d\n",errno)) ;
		}
	TESTPR((ERRFD,"strmapioctl: Worked, Ret = %d\n",Ret)) ;

	return( Ret ) ;
}

/* 
**  Routine:			GETSHORT
**  Access type:		Private
**  Abstract:	Return an short from the bytes pointed to by chr. 
**  Explicit Inputs:	chr - Pointer to bytes to be converted to short.
**  Implicit Inputs:	None
**  Explicit Outputs:	None
**  Implicit Outputs:	None
**  Return Value:		The short value the bytes.
**  Side Effects:		None
*/
static short GetShort(
	unsigned char *chr)
{
union 
	{
	unsigned char byt[sizeof(short)];
	unsigned short value;
	} recode;
register int i;

for ( i = 0; i < sizeof(short) ; i++)
	{
	recode.byt[i] = chr[i];
	}
return( recode.value );
}

/* 
**  Routine:			GETINT
**  Access type:		Private
**  Abstract:	Return an int from the bytes pointed to by chr.
**  Explicit Inputs:	chr - Pointer to bytes to be converted to int.
**  Implicit Inputs:	None
**  Explicit Outputs:	None
**  Implicit Outputs:	None
**  Return Value:		The int value for the bytes.
**  Side Effects:		None
*/
static int GetInt(
	unsigned char *chr)
{
union 
	{
	unsigned char byt[sizeof(int)];
	unsigned int value;
	} recode;
register int i;

for ( i = 0; i < sizeof(int) ; i++)
	{
	recode.byt[i] = chr[i];
	}
return( recode.value );
}

/* 
**  Routine:			STRMAPWRITE
**  Access type:		Public
**  Abstract:		Map hostorical write() to Streams putmsg().
**			Need to do a getmsg() 
**  Explicit Inputs:	None
**  Implicit Inputs:	None
**  Explicit Outputs:	None
**  Implicit Outputs:	None
**  Return Value:	None
**  Side Effects:	None
*/
static int strmapwrite(
	register short	Fd,
	register char	*Buf,
	register short	Len)
{
	register int Ret ;
	register SesRecord *SesRecPtr ;
	int flags ;
	short Status ;
	struct strbuf DataMsg ;
	struct strbuf CntrlMsg ;
	char CntrlBuf[100] ;
	struct pollfd Poll ;
	
	TESTPR((ERRFD,"Fd = %x, Buf = %x, Len = %x\n",Fd, Buf, Len)) ;

	if (Len < 0)
		{
		errno = INVALID_SIZE ;
		return(-1) ;
		}

	if (FdStat[Fd])
		{
		/* 
		 * Record Mode I/O, Buf points to a SesRecord structure, the 
		 * sr_status is sent in the control part.
		 */
		SesRecPtr = (SesRecord *)Buf ;
		Buf = SesRecPtr->sr_buffer ;
		Status = SesRecPtr->sr_status ;
		CntrlMsg.buf = (char *)&Status ;
		CntrlMsg.len = sizeof(Status) ;
		}
	else
		{
		/* Stream mode I/O, no control part */
		CntrlMsg.len = -1 ;
		}

	DataMsg.len = Len ;
	DataMsg.buf = Buf ;
	TESTPRBUF("strmapwrite: putmsg Cntrl\n",&CntrlMsg) ;
	TESTPRBUF("strmapwrite: putmsg Data\n",&DataMsg) ;
	Ret = NET_putmsg( Fd, &CntrlMsg, &DataMsg, 0) ;
	if (Ret == -1)
		{
        switch (errno)
            {
        case EAGAIN:
            errno = FLOW_CONTROL ;
            break ;

        case ERANGE:
            errno = SIZE_TOO_BIG ;
            break ;

        default:
            TESTPR((ERRFD,"strmapwrite: putmsg failed, errno = %d\n",errno)) ;
            }
        return(Ret) ;
		}

	/*
	 * Wait for the Stack to send back the Priority message 
	 */
	while(1)
		{
		Poll.fd = Fd ;
		Poll.events = POLLPRI ;
		Poll.revents = 0 ;
		Ret = NET_poll(&Poll, 1, -1) ;
		if (Ret == -1)
			{
			if (errno == EAGAIN)
				{
				continue ;
				}
			if (errno == EINTR)
				{
				TESTPR((ERRFD,"strmapwrite: poll Interrupted\n")) ;
				continue ;
				}
			TESTPR((ERRFD,"strmapwrite: poll failed, errno = %d\n",errno)) ;
			return(Ret) ;
			}
	
		TESTPR((ERRFD,"Ret = 0x%x,Poll.revents = 0x%x\n",Ret,Poll.revents)) ;

		/* Else, poll worked */
		break ;
		}

	/*
	 * Get the result of the Write
	 */
	CntrlMsg.maxlen = sizeof(CntrlBuf) ;
	CntrlMsg.buf = &CntrlBuf[0] ;
	flags = RS_HIPRI ;
	Ret = NET_getmsg(Fd, &CntrlMsg, NULL, &flags) ;
	if (Ret != 0)
		{
		if (Ret == -1)
			{
			TESTPR((ERRFD,"strmapwrite: getmsg failed, errno = %d\n",errno)) ;
			return(Ret) ;
			}

		TESTPR((ERRFD,"strmapwrite: getmsg failed,Ret = %x\n",Ret)) ;
		errno = UNKNOWN ;
		Ret = -1 ;
		return(Ret) ;
		}
	TESTPR((ERRFD,"strmapwrite: getmsg worked, Ret = %d\n",Ret)) ;

	TESTPRBUF("strmapwrite: getmsg Cntrl\n",&CntrlMsg) ;
	if (CntrlMsg.len != sizeof(short))
		{
		errno = UNKNOWN ;	/* Should be more creative */
		return(-1) ;
		}

	if ((errno = GetShort((unsigned char *)&CntrlBuf[0])) == 0)
		{
		TESTPR((ERRFD,"strmapwrite: Success, Len = %d\n",Len)) ;
		return( Len ) ;
		}
	
	TESTPR((ERRFD,"strmapwrite: Failed, errno = %d\n",errno)) ;
	return( -1 ) ;
}

/* 
**  Routine:
**  Access type:
**  Abstract:
**  Explicit Inputs:	None
**  Implicit Inputs:	None
**  Explicit Outputs:	None
**  Implicit Outputs:	None
**  Return Value:	None
**  Side Effects:	None
*/
static int strmapread(
	register short	Fd,
	register char	*Buf,
	register short	Len)
{
	register int MsgStat ;
	int flags = 0 ;
	short ReadStatus = 0 ;
	char ReadData ;
	struct strbuf Data ;
	struct strbuf Cntrl ;

	Data.buf = &ReadData ;
	Data.maxlen = 1 ;
	Cntrl.buf = (char *)&ReadStatus ;
	Cntrl.maxlen = sizeof(ReadStatus) ;
	
	TESTPR((ERRFD,">strmapread: Fd %d, Buf %x, Len %d\n",Fd, Buf, Len)) ;
	if ((MsgStat = NET_getmsg(Fd, &Cntrl, &Data, (int *)&flags)) < 0) 
		{
		/* Bad News */
		if (errno == EAGAIN)
			{
			errno = NO_DATA_AVAIL ;
			}
		TESTPR((ERRFD,"strmapread: getmsg failed errno = %d\n",errno)) ;
		return(-1) ;
		}

	TESTPRBUF("strmapread: getmsg Cntrl\n",&Cntrl) ;
	TESTPRBUF("strmapread: getmsg Data\n",&Data) ;

	if (MsgStat & MORECTL)
		{
		/*
		 * More Control? I don't think so!
		 */
		TESTPR((ERRFD,"strmapread: More Control???\n")); 
		errno = RCV_BAD_SEQ ;
		return(-1) ;
		}

	if ((Cntrl.len != -1) && !FdStat[Fd]) 
		{
		/*
		 * We have a control part and we're not in record mode, that
		 * we know of.
		 */
		if ((ReadStatus < BEG_OF_MESSAGE) || (ReadStatus > COMPLETE))
			{
			errno = ReadStatus ;
			TESTPR((ERRFD,"strmapread: Bad Record Status? errno %d\n",errno)); 
			return( -1 ) ;
			}
		/* We're in Record mode */
		FdStat[Fd] = TRUE ;
		}

	/* 
	 * If we're in record mode.
	 */
	if (FdStat[Fd])
		{
		register SesRecord *SesRecPtr ;	/* Only used in record mode */

		/* 
		 * It's possible to receive data before sending SES_IO_TYPE
		 * ioctl to invoke record mode I/O.  In stream mode, which is
		 * what the stack thought we were in, messages at the stream
		 * head are COMPLETE messages.
		 */
		if (Cntrl.len == -1)
			{
			ReadStatus = COMPLETE ;
			}
		/* 
		 * Either its a successful RECORD mode read or its the disconnect 
		 * reason code.
		 */
		else if ((ReadStatus < BEG_OF_MESSAGE) || (ReadStatus > COMPLETE))
			{
			errno = ReadStatus ;
			TESTPR((ERRFD,"strmapread: Bad Record Status? errno %d\n",errno)); 
			return( -1 ) ;
			}

		/* Sane RECORD mode read */

		SesRecPtr = (SesRecord *)Buf ;
		Buf = SesRecPtr->sr_buffer ;
		SesRecPtr->sr_status = ReadStatus ;
		}

	if (Data.len == -1)
		{
		/* 
		 * What happened to the Data?  At least a Zero length msg 
		 * should be present.
		 */
		TESTPR((ERRFD,"strmapread: No Data?\n")); 
	 	errno = RCV_BAD_SEQ ;
	 	return( -1 ) ;
	 	}


	if (MsgStat & MOREDATA)
		{
		*Buf++ = ReadData ;
		Data.buf = Buf ;
		Data.maxlen = Len - 1 ;
	
		if ((MsgStat = NET_getmsg(Fd, NULL, &Data, (int *)&flags)) < 0) 
			{
			/* Bad News */
			TESTPR((ERRFD,"strmapread: getmsg Data failed, errno = %d\n",errno)) ;
			return(-1) ;
			}

		if (FdStat[Fd] && MsgStat)
			{
			if (MsgStat & MOREDATA)
				{
				TESTPR((ERRFD,"strmapread: Didn't get all the data! \n")) ;
				errno = TRUNCATED ;
				return(-1) ;
				}

			if (MsgStat & MORECTL)
				{
				TESTPR((ERRFD,"strmapread: More Ctl?! \n")) ;
				errno = RCV_BAD_SEQ ;
				return(-1) ;
				}
			}
		TESTPRBUF("<strmapread: getmsg More Data\n",&Data) ;
		return(Data.len + 1) ;
		}
	else	/* No more Data */
		{
		if (Data.len == 1)
			*Buf = ReadData ;

		return(Data.len) ;
		}
			
}

/* 
**  Routine:
**  Access type:
**  Abstract:
**  Explicit Inputs:	None
**  Implicit Inputs:	None
**  Explicit Outputs:	None
**  Implicit Outputs:	None
**  Return Value:	None
**  Side Effects:	None
*/
static int SetBlk(
	register short Fd)
{
	register int i, j ;

	while (1)
		{
		i = NET_fcntl( Fd, F_GETFL, NULL) ;
		if (i == -1)
			{
			if (errno == EINTR)
				continue ;
			errno = EINVAL ;
			return( -1 ) ;
			}
		break ;
		}

	/* If it's already in Non Block mode, return */
	if (!(i & O_NDELAY))
		return( 0 ) ;

	while (1)
		{
		j = i & ~O_NDELAY ;
		j = NET_fcntl( Fd, F_SETFL, j) ;
		if (j == -1)
			{
			if (errno == EINTR)
				continue ;
			errno = EINVAL ;
			return( -1 ) ;
			}
		break ;
		}

	return( 0 ) ;
}

/* 
**  Routine:
**  Access type:
**  Abstract:
**  Explicit Inputs:	None
**  Implicit Inputs:	None
**  Explicit Outputs:	None
**  Implicit Outputs:	None
**  Return Value:	None
**  Side Effects:	None
*/
static int SetNonBlk(
	register short Fd)
{
	register int i, j ;

	while (1)
		{
		i = NET_fcntl( Fd, F_GETFL, NULL) ;
		if (i == -1)
			{
			if (errno == EINTR)
				continue ;
			errno = EINVAL ;
			return( -1 ) ;
			}
		break ;
		}

	/* If it's already in Non Block mode, return */
	if (i & O_NDELAY)
		return( 0 ) ;

	while (1)
		{
		j = i | O_NDELAY ;
		j = NET_fcntl( Fd, F_SETFL, j) ;
		if (j == -1)
			{
			if (errno == EINTR)
				continue ;
			errno = EINVAL ;
			return( -1 ) ;
			}
		break ;
		}

	return( 0 ) ;
}
#ifdef STRMAPTST
/* 
** Assumes that MapIoctl has been filled in already
*/
static void PrIoctl()
{
	register int i ;
	register char *Ptr ;

	fprintf(ERRFD,"MapIoctl.ic_dp = 0x%x\n",MapIoctl.ic_dp) ;
	fprintf(ERRFD,"MapIoctl.ic_cmd = 0x%x\n",MapIoctl.ic_cmd) ;
	fprintf(ERRFD,"MapIoctl.ic_len = 0x%x\n",MapIoctl.ic_len) ;
	fprintf(ERRFD,"MapIoctl.ic_timout = 0x%x\n",MapIoctl.ic_timout) ;
	PrBuf(MapIoctl.ic_dp, MapIoctl.ic_len) ;
}
static void PrStrBuf(
	char *String,
	struct strbuf *Buf)
{
	fprintf(ERRFD,"%s",String) ;
	fprintf(ERRFD,"len = %d\n",Buf->len) ;
	if (Buf->len != -1)
		{
		PrBuf(Buf->buf, Buf->len) ;
		}
}
static void PrBuf(
	register unsigned char *Ptr,
	register int Len)
{
	register int i ;

	if (Len < 0)
		return ;

	for (i = 0;i < Len; i++)
		{
		if ((i % 17) == 16)
			fprintf(ERRFD,"\n") ;
		fprintf(ERRFD,"%2x ",*Ptr++) ;
		}
	fprintf(ERRFD,"\n") ;
}
#endif

#if 0
OpenBlock OpBlk ;
unsigned char OutBuf[4] = "ABC" ;
unsigned char InBuf[4] = { 0, 0, 0, 0 } ;

client()
{
	register short ll, ret ;
	register int i ;

	sleep(2) ;
	ll = NET_open("/dev/ll",2) ;
	if (ll == -1)
		{
		printf("Client Open of dev ll failed, errno = %d\n",errno) ;
		exit(1) ;
		}
	printf("Client Open of dev ll worked\n") ;

	OpBlk.op_node_name[0] = '0' ;
	OpBlk.op_node_name[1] = '\0' ;
	OpBlk.op_task_name[0] = 'f' ;
	OpBlk.op_task_name[1] = 'o' ;
	OpBlk.op_task_name[2] = 'o' ;
	OpBlk.op_task_name[3] = '\0' ;
	OpBlk.op_object_nbr = 0 ;
	OpBlk.op_userid[0] = '\0' ;
	OpBlk.op_account[0] = '\0' ;
	OpBlk.op_password[0] = '\0' ;
	OpBlk.op_opt_data.im_length = 0 ;

	ret = strmapioctl(ll, SES_LINK_ACCESS, &OpBlk) ;
	if (ret == -1)
		{
		printf("Client SES_LINK_ACCESS failed, errno = %d\n",errno) ;
		exit(2) ;
		}
	printf("Client SES_LINK_ACCESS worked\n") ;

	printf("OutBuf = ") ;
	for (i = 0; i < sizeof(OutBuf); i++)
		{
		printf("%2x ",OutBuf[i]) ;
		}
	printf("\n") ;

	ret = strmapwrite(ll, OutBuf, sizeof(OutBuf) ) ;
	if (ret == -1)
		{
		printf("Write failed, errno = %d\n",errno) ;
		exit(3) ;
		}

	ret = strmapread(ll, InBuf, sizeof(InBuf) ) ;
	if (ret == -1)
		{
		printf("Read failed, errno = %d\n",errno) ;
		exit(3) ;
		}
	printf("InBuf = ") ;
	for (i = 0; i < sizeof(InBuf); i++)
		{
		printf("%2x ",InBuf[i]) ;
		}
	printf("\n") ;
	sleep(5) ;

}
server()
{
	register short ll, ret ;
	register int i ;
	OpenBlock OpBlk ;
	SessionData SesDat ;
	unsigned char EchoBuff[4] ;

	ll = NET_open("/dev/ll",2) ;
	if (ll == -1)
		{
		printf("Server Open of dev ll failed, errno = %d\n",errno) ;
		exit(1) ;
		}
	printf("Server Open of dev ll worked\n") ;

	ret = strmapioctl(ll, SES_NAME_SERVER, "foo") ;
	if (ret == -1)
		{
		printf("Server SES_NAME_SERVER failed, errno = %d\n",errno) ;
		exit(2) ;
		}
	printf("Server SES_NAME_SERVER worked\n") ;

	ret = strmapioctl(ll, SES_GET_AI, &OpBlk) ;
	if (ret == -1)
		{
		printf("Server SES_GET_AI failed, errno = %d\n",errno) ;
		exit(2) ;
		}
	printf("Server SES_GET_AI worked\n") ;

	ret = strmapioctl(ll, SES_ACCEPT, &SesDat) ;
	if (ret == -1)
		{
		printf("Server SES_ACCEPT failed, errno = %d\n",errno) ;
		exit(2) ;
		}
	printf("Server SES_ACCEPT worked\n") ;
	ret = strmapread(ll, EchoBuff, sizeof(EchoBuff) ) ;
	if (ret == -1)
		{
		printf("Read failed, errno = %d\n",errno) ;
		exit(3) ;
		}
	printf("EchoBuff = ") ;
	for (i = 0; i < sizeof(EchoBuff); i++)
		{
		printf("%2x ",EchoBuff[i]) ;
		}
	printf("\n") ;
	ret = strmapwrite(ll, EchoBuff, sizeof(EchoBuff) ) ;
	if (ret == -1)
		{
		printf("Server Write failed, errno = %d\n",errno) ;
		exit(3) ;
		}
	sleep(5) ;
}
main()
{
	register int Pid ;

	Pid = fork() ;
	if (Pid == -1)
		{
		printf("fork failed! errno = %d\n",errno) ;
		exit(1) ;
		}
	if (!Pid)
		{
		server() ;
		}
	else
		{
		client() ;
		}
}
#endif

#endif /* clipper only */
/******************************************************************************/

/*
**	This procedure will open DNP's permanent database file and retrieve
**	area numbers, node numbers, and name of nodes(if available).
**
**	NOTE: This procedure accesses the permanent database.
**	"ncp define known nodes all"   will copy any data from the volatile
**	the permanent database. This should be done after defining any
**	remote nodes("set node 31.2 name TOMH).
**
**	NOTE 2: Executor's node is always the first entry.
**
*/

/******************************************************************************/

static void NET_access_prmnt_dnp_db(
	int		name_or_addr,
	net_s	*net,
	char 	*nodename,
	char 	*netaddr,
	int 	*len)
{
#if defined(__clipper__)
	FILE *fp;
	unsigned char tail, head;
	char name[7];
	unsigned int area, node, number, x;

	NET_DBG(("NET_access_prmnt_dnp_db(name_or_addr:%s net:0x%x ",
			(name_or_addr == GET_NAME) ? "GET_NAME" : "GET_ADDRESS", net));
	NET_DBG(("nodename:<%s> netaddr:<%s> *len:0x%x)\n",
			STRING(nodename), STRING(netaddr), len));

	if ((fp = NET_fopen(PERMENANT_FILE, "r")) == NULL)
	{
        NET_error_dnp(net, NET_E_FILE_NOT_FOUND, "");
		NET_DBG(("NET_access_prmnt_dnp_db: returning FILE_NOT_FOUND\n"));
		return;
	}

	fseek(fp,6,0);                        	/* Skip some junk */

	while(!feof(fp))
	{

		if(fscanf(fp,"%c",&tail) == EOF)/* Get first byte of area/node */
		{
			break;
		}
		if(fscanf(fp,"%c",&head) == EOF) 	/* Get next byte of area/node */
		{
			break;
		}
		number = head;                      /* conversion to area and node */
		number = number << 8;
		number += tail;
		node = number % 1024;
		area = number / 1024;
	
		fseek(fp,8,1);              		/* Skip some more junk */
		for(x=0;x<6;x++)
		{        
  			fscanf(fp,"%c",&name[x]); 		/* Get name            */
		}
		name[x] = '\0';
		
		NET_DBG(("NET_access_prmnt_dnp_db: Area Number:%4d Node Number:%4d Name:<%s>\n", area, node, STRING(name)));

		if( name_or_addr == GET_NAME )
		{
			/*
			** First line is Executor node (local node)
			*/
			strncpy(nodename,name,*len);
			NET_fclose(fp);
			NET_DBG(("NET_access_prmnt_dnp_db:returning local node name:<%s>\n",
				nodename));
			return;
		}
		else
		{
			/*
			** Compare the address passed in against the current scanned one
			*/
			if( !NET_strcmp_ic(nodename,name) )
			{
				*len = sprintf(netaddr, "%d.%d", area, node);
				NET_fclose(fp);
				NET_DBG(("NET_access_prmnt_dnp_db: returning net addr:<%s>\n",
					netaddr));
				return;
			}
		}
		fseek(fp,4,1);
	}
	NET_fclose(fp);

	NET_DBG(("NET_access_prmnt_dnp_db: \"%s\" is not a valid nodename, is it an address\n", STRING(nodename)));

	if (sscanf(nodename, "%d.%d", &area, &node) == 2)
	{
		if (area >= 1 && area <= 63 && node >=1 && node <= 1023)
		{
			sprintf(netaddr, "%d.%d", area, node);
			NET_DBG(("NET_access_prmnt_dnp_db: returning net addr:<%s>\n",
				netaddr));
			return;
		}
	}

    NET_error_dnp(net, NET_E_ADDR_ERROR, "");
	NET_DBG(("NET_access_prmnt_dnp_db: returning addr or node name error\n"));
	return;
#endif
}

#endif /* if defined(__clipper__) || defined(vms) */

/******************************************************************************/
