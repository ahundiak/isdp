/* Do not alter this SPC information: $Revision: 1.2.33.1 $ */
/*
**	NAME:							trnpaths.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					3/88
**	ABSTRACT:
**		This file contains the routine that sets up the remote pathways.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "trans.h"
#include "net.h"
#include "arch.h"


/*
**	FUNCTION PROTOTYPES
*/
#define trnpaths_c
#include "ccoerror.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "comstrng.prt"
#include "netgnerc.prt"
#include "trnpaths.prt"
#include "sys.prt"


/*
**	DEFINES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RIStrn_setup_remote_pathways(
	ristree *remotep,
	risdb *dp)
{
	int i;
	int len;
	char proto_str[RIS_MAX_PROTOCOLS];
	ristree *tp;
	static net_s net;
	char addr[RIS_MAX_NODE_SIZE];
	int atleast_one=0;
	int notnull_flag=0;
	int count=0;
	int xns_null=0;
	int tcp_null=0;
	int dnp_null=0;

	TRN_DBG(("RIStrn_setup_remote_pathways(remotep:0x%x, dp:0x%x\n",
		remotep, dp));

	memset((char*)&net,0,sizeof(net));
	net.error_handler = RIScco_net_errhandle;
	memset(proto_str,0,sizeof(proto_str));

	for (i=0; i< RIS_MAX_PROTOCOLS; i++)
	{
		memset(dp->pathways[i].netaddr, 0, RIS_MAX_NODE_SIZE);
	}
	for (i=0,tp=remotep->rhs;tp;tp=tp->rhs,i++)
	{
		notnull_flag = 0;
		strcpy(addr, tp->lhs->info.val);
		RIScom_uppercase(strlen(addr), (unsigned char *)addr);
		switch(tp->lhs->tok)
		{
			case RIS_TOK_XNS:
				if (strchr(proto_str,'X')) /*itbokic */
				{
					TRN_ERR_RETURN(RIS_E_DUP_PROTOCOL, tp->lhs->pos);
				}
				proto_str[i] = 'X';
				if (strcmp(addr, "NULL"))
				{
					notnull_flag = 1;
					dp->pathways[count].protocol = 'X';
					net.protocol = XNS;
				}
				else
				{
					xns_null = 1;
				}
			break;
			case RIS_TOK_TCP:
				if (strchr(proto_str,'T')) /*itbokic */
				{
					TRN_ERR_RETURN(RIS_E_DUP_PROTOCOL, tp->lhs->pos);
				}
				proto_str[i] = 'T';
				if (strcmp(addr, "NULL"))
				{
					notnull_flag = 1;
					dp->pathways[count].protocol = 'T';
					net.protocol = TCP;
				}
				else
				{
					tcp_null = 1;
				}
			break;
			case RIS_TOK_DNP:
				if (strchr(proto_str,'D')) /*itbokic */
				{
					TRN_ERR_RETURN(RIS_E_DUP_PROTOCOL, tp->lhs->pos);
				}
				proto_str[i] = 'D';
				if (strcmp(addr, "NULL"))
				{
					notnull_flag = 1;
					dp->pathways[count].protocol = 'D';
					net.protocol = DNP;
				}
				else
				{
					dnp_null = 1;
				}
			break;
			default:
				TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,tp->lhs->pos);
			break;
		}

/* look up the protocol-specific address */

		if (notnull_flag)
		{
			++atleast_one;
			len = sizeof(dp->pathways[count].netaddr);
			/*
			**  Server does validity check of protocols so
			**  when pathways[0] is not valid server return error
			*/
			if ( ! NET_address(&net,tp->lhs->info.val,
					   dp->pathways[count].netaddr, &len))
			{
				count++;
			}
			else
			{
				TRN_ERR_RETURN(RIS_E_NODE_ADDR_ERROR, tp->lhs->pos);
			}
		}
	}
	if (remotep->rhs)
	{
		if (!atleast_one)
		{
			LONGJMP(RIS_E_INV_REMOTE_ADDRESS);	
		}
		if (RIStrn_debug)
		{
			for (i=0; i < count; i++)
			{
				RIScom_output_debug("\tprotocol <%c> netaddr <%s>\n",
					 dp->pathways[i].protocol, dp->pathways[i].netaddr);
			}
		}
		if (xns_null)
		{
			strcpy(dp->pathways[count].netaddr, "NULLXNS");
			TRN_DBG(("\tprotocol <XNS> netaddr <%s>\n",
					 dp->pathways[count].netaddr));
			count++;
		}
		if (tcp_null)
		{
			strcpy(dp->pathways[count].netaddr, "NULLTCP");
			TRN_DBG(("\tprotocol <TCP> netaddr <%s>\n",
					 dp->pathways[count].netaddr));
			count++;
		}
		if (dnp_null)
		{
			strcpy(dp->pathways[count].netaddr, "NULLDNP");
			TRN_DBG(("\tprotocol <DNP> netaddr <%s>\n",
					 dp->pathways[count].netaddr));
		}
	}
	TRN_DBG(("RIStrn_setup_remote_pathways Done..\n"));
}
