/* Do not alter this SPC information: $Revision: 1.1.55.1 $ */
/*
**	NAME:							comprtcl.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					2/88
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "net.h"
#include "arch.h"
#include "riscom.h"
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
#define comprtcl_c
#include "comprtcl.prt"
#include "comdebug.prt"
#include "netgnerc.prt"
#include "sys.prt"


/******************************************************************************/

/* Initialize remote protocol functions */

extern void RIScom_init_protocols(
	char	*xns_addr,
	int		xns_len,
	char	*tcp_addr,
	int		tcp_len,
	char	*lu62_addr,
	int		lu62_len,
	char	*dnp_addr,
	int		dnp_len)
{
	int		len;
	net_s	net;
	char	nodename[RIS_MAX_NODE_SIZE];

	COM_DBG(("RIScom_init_protocols(xns_addr:0x%x xns_len:%d tcp_addr:0x%x tcp_len:%d lu62_addr:0x%x lu62_len:%d dnp_addr:0x%x dnp_len:%d)\n", xns_addr, xns_len, tcp_addr, tcp_len, lu62_addr, lu62_len, dnp_addr, dnp_len));

	memset((char*)&net,0,sizeof(net));

	net.protocol = XNS;
	len = sizeof(nodename);
	NET_nodename(&net, nodename, &len);
	COM_DBG(("RIScom_init_protocols:xns nodename:<%s>\n", nodename));
	NET_address(&net, nodename, xns_addr, &xns_len);

	net.protocol = TCP;
	len = sizeof(nodename);
	NET_nodename(&net, nodename, &len);
	COM_DBG(("RIScom_init_protocols:tcp nodename:<%s>\n", nodename));
	NET_address(&net, nodename, tcp_addr, &tcp_len);

	net.protocol = LU62;
	len = sizeof(nodename);
	NET_nodename(&net, nodename, &len);
	COM_DBG(("RIScom_init_protocols:lu62 nodename:<%s>\n", nodename));
	len = sizeof(RIS_local_lu62_addr);
	NET_address(&net, nodename, lu62_addr, &lu62_len);

	net.protocol = DNP;
	len = sizeof(nodename);
	NET_nodename(&net, nodename, &len);
	COM_DBG(("RIScom_init_protocols:dnp nodename:<%s>\n", nodename));
	len = sizeof(RIS_local_dnp_addr);
	NET_address(&net, nodename, dnp_addr, &dnp_len);

	COM_DBG(("RIScom_init_protocols: xns_addr:<%s> tcp_addr:<%s> lu62_addr:<%s> dnp_addr:<%s>\n", STRING(xns_addr), STRING(tcp_addr), STRING(lu62_addr), STRING(dnp_addr)));
	COM_DBG(("RIScom_init_protocols: returning\n"));
}

/******************************************************************************/
