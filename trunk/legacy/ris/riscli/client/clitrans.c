/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							clitrans.c
**	AUTHORS:						Sunil Murthy
**	CREATION DATE:					1/93
**	ABSTRACT:
**		Function that puts the list of schema names involved in transactions
**		into the client/application buffer.
**	
**	REVISION HISTORY:
**
*/
 
/*
**	INCLUDES
*/
#include "client.h"
#include "user.h"


/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define clitrans_c
#include "comdebug.prt"
#include "sys.prt"
#include "clitrans.prt"
#include "comjmp.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RIScli_get_sch_in_trans_tobuf ()
{
	int			i;
	int			count = 0;
	int			offset = 0;
	risschema	*schema;

	CLI_DBG(("RIScli_get_sch_in_trans_tobuf()\n"));

	for (i=0;i < RIS_parms.max_transactions;i++)
	{
		schema = RISusr_transact_schemas[i].schema;
		if (schema)
		{
			count++;
		}
	}
	offset = count * RIS_MAX_ID_SIZE;

	RIS_app_write_len =
		(int)&(((ris_cliapp_buf *)0)->buf.get_sch_in_trans.data) + offset;
	if (RIS_app_write_len > RIS_app_write_size)
	{
		CLI_DBG(("RIScli_get_sch_in_trans_tobuf: ERROR: RIS_app_write_len:%d > "
			"RIS_app_write_size:%d\n", RIS_app_write_len, RIS_app_write_size));
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	RIS_app_write->buf.get_sch_in_trans.sch_count = count;

	for (i=0, offset=0;i < RIS_parms.max_transactions;i++)
	{
		schema = RISusr_transact_schemas[i].schema;
		if (schema)
		{
			memcpy(RIS_app_write->buf.get_sch_in_trans.data + offset,
				schema->schname, RIS_MAX_ID_SIZE);
			offset += RIS_MAX_ID_SIZE;
		}
	}
	CLI_DBG(("RIScli_get_sch_in_trans_tobuf done...\n"));
}

/******************************************************************************/
