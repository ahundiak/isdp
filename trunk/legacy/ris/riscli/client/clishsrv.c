/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							clishsrv.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					12/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "client.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define clishsrv_c
#include "clibuff.prt"
#include "clishsrv.prt"
#include "comjmp.prt"
#include "comdebug.prt"
#include "comoutpt.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RIScli_show_servers(
	void)
{
	int				sts;
	risschema		*schema;
	static int		continue_flag = 0;

	CLI_DBG(("RIScli_show_servers()\n"));

	sts = SETJMP();
	if (sts)
	{
		RESETJMP();
		if (sts == RIS_E_BUFFER_FULL)
		{
			continue_flag = 1;
			return;
		}

		continue_flag = 0;
		LONGJMP(sts);
	}

	RIScli_init_string_to_buf(continue_flag);

	RIScli_string_to_buf("RISCLIENT SERVERS: (default: 0x%x)\n", RIS_default);

	for (schema = RIS_srvs; schema; schema = schema->next)
	{
		
		RIScli_string_to_buf("\tserver:0x%x %s\n", schema,
			(schema == RIS_default) ? "(default)" : "");
		RIScom_output_server(RIScli_string_to_buf, schema, 2);
		RIScli_ckpt_string_to_buf((char *)schema);
	}
	RIScli_ckpt_string_to_buf((char *)RIS_srvs);

	RESETJMP();

	continue_flag = 0;

	CLI_DBG(("RIScli_show_servers: complete\n"));
}

/******************************************************************************/
