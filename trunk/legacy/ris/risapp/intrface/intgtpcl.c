/* Do not alter this SPC information: $Revision: 1.1.57.1 $ */
/*
**	NAME:							intgtpcl.c
**	AUTHORS:						Hitesh R. Patel
**	CREATION DATE:					5/93
**	ABSTRACT:
**		Access to global variables related to protocol addresses.				
**	
**	REVISION HISTORY:
**
*/
 
/*
**	INCLUDES
*/
#include "riscom.h"
#include "intrface.h"
#include "ris_inf.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define intgtpcl_c
#include "comdebug.prt"
#include "interror.prt" 
#include "intgtpcl.prt"
#include "sys.prt"

/*
**	FUNCTIONS
*/

/******************************************************************************/

/*
** Get Client addresses for each protocol. The client addresses are stored in
** RIS_local_*_addr variables which are filled by riscli process.
**
*/
extern void RISAPI RISXint_get_client_addresses(
	char *xns_addr,
	char *tcp_addr,
	char *lu62_addr,
	char *dnp_addr)
{
	INT_DBG(("RISint_get_client_addresses(xns_addr:0x%x, tcp_addr:0x%x"
			 "lu62_addr:0x%x dnp_addr:0x%x)\n", xns_addr, tcp_addr, lu62_addr,
			  dnp_addr));

	RIS_ENTER();

	if (!xns_addr || !tcp_addr || !lu62_addr || !dnp_addr)
	{
		SET_RISCA(RIS_E_INV_ARG);
		RIS_RETURN();
	}

	strcpy(xns_addr,RIS_local_xns_addr);
	strcpy(tcp_addr,RIS_local_tcp_addr);
	strcpy(lu62_addr,RIS_local_lu62_addr);
	strcpy(dnp_addr,RIS_local_dnp_addr);

	SET_RISCA(RIS_SUCCESS);

	INT_DBG(("RISint_get_client_addresses:complete\n"));

	RIS_RETURN();
}

/******************************************************************************/

