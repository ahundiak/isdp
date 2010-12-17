/* Do not alter this SPC information: $Revision: 1.3.19.1 $ */
/*
**	NAME:							comarch.c
**	AUTHORS:						John Gwyer
**	CREATION DATE:					7/91
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
**	1995.07.18 - Alan Barksdale - Added blocking parameter to
**	RIScom_rec_architecture.  See revision history for
**	riscli/user/usrsrv.c.
*/
 
/*
**	INCLUDES
*/
#include "arch.h"
#include "net.h"
#include "ris_err.h"
#include "risdebug.h"

/*
**	DEFINES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/*
**      FUNCTION PROTOTYPES
*/
#define comarch_c
#include "arcgnerc.prt"
#include "comarch.prt"
#include "comdebug.prt"
#include "netgnerc.prt"

#ifdef Soli
#include "sys.prt"
#endif


/*
============================================================================
        Determine what the remote architecture is. We need
        to know this before any data is sent, so we can properly
        do datatype conversions for machines with different
        architectures.

        The proper protocol is for the controlling process
        to send its architecture, and then receive the slave's
        architectures. (client sends - server receives, then
        server sends - client receives)

============================================================================
*/

/******************************************************************************/

/*
**  We need to send a single byte to the remote server, so use a double
**  aligned buffer and fill it with the 'LOCAL_ARCH' value
*/

extern void RIScom_send_architecture(
	net_s	*net,
	arc_s	*arc,
	int		send_flag)
{
	int		length;

	/*
	** WARNING -- buffer must be aligned for vms networking
	*/

	union {
		double dummy;
		char	buffer[2];
		} local_buffer;

	COM_DBG(("RIScom_send_architecture(net:0x%x arc:0x%x)\n", net, arc));

    if (net->protocol == LU62)
    {
		/*
		** Do nothing for now, when we get 'C' on the ibm then we will
		** change the interface for handling achitecture differences
		*/
    }
    else
    {
		/*
		** send our architecture to the remote machine
		*/
		if (send_flag == TO_BACKEND)
		{
			/*
			** V5 fep to V5 or greater bep
			*/
			local_buffer.buffer[0] = LOCAL_ARCH;
			local_buffer.buffer[1] = HIGHEST_KNOWN_ARCH;
			length = 2;

			COM_DBG(("RIScom_send_architecture: sending architecture:<%d>\nRIScom_send_architecture: highest known arch.:<%d>\n",
				local_buffer.buffer[0], local_buffer.buffer[1]));
		}
		else if (send_flag == TO_FRONTEND)
		{
			if (arc->second_byte == V4_FRONTEND)
			{
				/*
				** If the V4 fep's arch. is greater than the currently known
				** highest architecture of a V4 fep then assume remote arch
				** is CLIPPER and send CLIPPER.
				*/
				if (arc->remote_arch > HYDRA)
				{
					local_buffer.buffer[0] = CLIPPER;
					arc->remote_arch = CLIPPER;
				}
				else
				{
					local_buffer.buffer[0] = LOCAL_ARCH;
				}
				length = 1;
				COM_DBG(("RIScom_send_architecture:sending architecture:<%d>\n",
					local_buffer.buffer[0]));
			}
			else
			{
				if (LOCAL_ARCH > arc->second_byte)
				{
					local_buffer.buffer[0] = CLIPPER;
					local_buffer.buffer[1] = UNKNOWN_ARCH;
				}
				else
				{
					local_buffer.buffer[0] = LOCAL_ARCH;
					local_buffer.buffer[1] = HIGHEST_KNOWN_ARCH;
				}
				length = 2;
				COM_DBG(("RIScom_send_architecture: sending architecture:<%d>\nRIScom_send_architecture: highest known arch.:<%d>\n",
					local_buffer.buffer[0], local_buffer.buffer[1]));
			}
		}

        NET_write_no_len(net, local_buffer.buffer, &length, BLOCKING);
    }

	COM_DBG(("RIScom_send_architecture:returning\n"));
}

/******************************************************************************/
/*
**  We need to receive a single byte from the remote process, so use
**	a double aligned buffer.
*/

/*
**  blocking = -1 ==> non blocking
**  blocking =  0 ==> blocking indefinitely
**  blocking >= 1 ==> blocking with timeout
*/
extern void RIScom_rec_architecture(
	net_s	*net,
	arc_s	*arc,
	int		rec_flag, /* FROM_FRONTEND or FROM_BACKEND */
	int     blocking) /* see above */
{
	int		length;

	/*
	** WARNING -- buffer must be aligned for vms networking
	*/

	union {
		double dummy;
		char	buffer[2];
		} local_buffer;

	COM_DBG(("RIScom_rec_architecture(net:0x%x arc:0x%x rec_flag:%d blocking:%d)\n",
		net, arc, rec_flag, blocking));

	/*
	** receive the architecture of the remote machine
	*/
	length = 2;
	NET_read_no_len(net, local_buffer.buffer, &length, blocking);
	COM_DBG(("RIScom_rec_architecture: received %d bytes\n", length));

	if (net->protocol == LU62)
	{
		/*
		** Hard code the architecture type for now,
		** when we get 'C' on the ibm then we will
		** change the interface for handling achitecture differences
		*/

		arc->remote_arch = IBM_370;
	}
	else
	{
		arc->remote_arch = (short)(local_buffer.buffer[0]);
	}

	if (length > 1)
	{
		/*
		** Front-end-process (fep) is V5
		*/
		arc->second_byte = (short)(local_buffer.buffer[1]);
	}
	else
	{
		arc->second_byte = V4_FRONTEND;
	}
	if (rec_flag == FROM_FRONTEND)
	{
		/*
		** If our arch. is greater than the V5 fep's highest known
		** architecture, then assume remote arch is CLIPPER and send CLIPPER.
		*/
		if (LOCAL_ARCH > arc->second_byte)
		{
			arc->remote_arch = CLIPPER;
		}
	}
	else if (rec_flag == FROM_BACKEND)
	{
		if (arc->second_byte == UNKNOWN_ARCH)
		{
			arc->remote_arch = CLIPPER;
		}
	}

	COM_DBG(("RIScom_rec_architecture: received architecture:<%d>\nRIScom_rec_architecture: second byte:<%d>\n",
		arc->remote_arch, arc->second_byte));

	ARC_set_conversion_flags(arc);

	COM_DBG(("RIScom_rec_architecture:returning\n"));
}

/******************************************************************************/
