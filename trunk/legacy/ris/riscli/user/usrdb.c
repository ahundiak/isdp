/*
**	NAME:							usrdb.c
**	AUTHORS:						David Michal
**	CREATION DATE:					11/86
**	ABSTRACT:
**	
**	REVISION HISTORY:
**		9/93	Use first working protocol in order given by schema file
*/
 
/*
**	INCLUDES
*/
#include "riscli.h"
#include "riscom.h"
#include "user.h"

/*
**	FUNCTION PROTOTYPES
*/
#define usrdb_c
#include "comdebug.prt"
#include "comjmp.prt"
#include "comstcmi.prt"
#include "usrdb.prt"
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

extern int RISusr_db_on_remote_machine(
	risdb	*db,
	int		*first_usable_protocol_index)
{
	char	*dict_addr;
	char	*net_addr;
	int		remote_machine = 0;
	int		i;

	USR_DBG(("RISusr_db_on_remote_machine(db:0x%x first_usable_protocol_index:%d)\n", db, *first_usable_protocol_index));

	*first_usable_protocol_index = -1;

	for (i=0; 
		 i<RIS_MAX_PROTOCOLS && db->pathways[i].protocol 
		     && *first_usable_protocol_index == -1;
		 ++i)
	{
		switch (db->pathways[i].protocol)
		{
			case 'D':	/* DNP (dec net) */
				if (*RIS_local_dnp_addr)
				{
					*first_usable_protocol_index = i;
					if (strcmp(db->pathways[i].netaddr, RIS_local_dnp_addr))
					{
						remote_machine = 1;
					}
				}
				break;
			case 'T':	/* tcp */
				if (*RIS_local_tcp_addr)
				{
					*first_usable_protocol_index = i;
					if (strcmp(db->pathways[i].netaddr, RIS_local_tcp_addr))
					{
						remote_machine = 1;
					}
				}
				break;
			case 'X':	/* xns */
				if (*RIS_local_xns_addr)
				{
					*first_usable_protocol_index = i;
					/*
				 	**	see if addresses match, ignoring xxxxxx. portion.
				 	**	We ignore the lan id because lan ids can change easily
				 	**	(like by unplugging your ethernet cable) and the
					**  hardware address should always be unique anyhow.
				 	*/
					dict_addr = strchr(db->pathways[i].netaddr, '.');
					if (!dict_addr)
					{
						LONGJMP(RIS_E_INTERNAL_ERROR);
					}
					++dict_addr;

					net_addr = strchr(RIS_local_xns_addr, '.');
					if (!net_addr)
					{
						LONGJMP(RIS_E_INTERNAL_ERROR);
					}
					++net_addr;

					USR_DBG(("comparing <%s> to <%s>\n", net_addr,dict_addr));
					/* compare addrs, ignoring case */
					if (RIScom_strcmp_ic(net_addr, dict_addr))
					{
						remote_machine = 1;
					}
				}
				break;
			case '\0': /* no network protocol */
				break;
			default:
				LONGJMP(RIS_E_INTERNAL_ERROR);
				break;
		}
	}
	USR_DBG(("RISusr_db_on_remote_machine: first_usable_protocol_index:%d\n",
		*first_usable_protocol_index));

	if (*first_usable_protocol_index == -1)
	{
		LONGJMP(RIS_E_NO_PROTOCOL);
	}

	USR_DBG(("RISusr_db_on_remote_machine: returning %d\n", remote_machine));
	return remote_machine;
}
