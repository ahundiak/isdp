/* Do not alter this SPC information: $Revision: 1.3.26.1 $ */
/*
**	NAME:							ucoshprm.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					6/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "ucommon.h"
#include "risutl.h"
#include "rislimit.h"
#include "utl_inf.h"
#include "ris.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define ucoshprm_c
#include "comdebug.prt"
#include "comumsg.prt"
#include "ucoshprm.prt"
#include "ris.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISuco_show_parameters(
	int             (* output_func)(const char *, ...)
)
{
	ris_parameters	p;
	char version[40];


	UCO_DBG(("RISuco_show_parameters()\n"));

	RISget_parameters(&p);
	if (SQLCODE != RIS_SUCCESS)
	{
		UCO_DBG(("RISuco_show_schfile:RISget_parameters failed: returning\n"));
		return;
	}

	sprintf(version, "%d.%d", p.client_major, p.client_feature);
	if (p.client_major == 0 && p.client_feature == 0)
	{
		strcat(version, MSG(RISUTL_I_USE_DEFAULT_VERSION));
	}

	output_func(MSG(RISUTL_I_SHOW_PARMS_1), p.shared_memory);
	output_func(MSG(RISUTL_I_SHOW_PARMS_2), p.max_local_servers);
	output_func(MSG(RISUTL_I_SHOW_PARMS_3), p.max_rows);
	output_func(MSG(RISUTL_I_SHOW_PARMS_4), p.max_buffer_size);
	output_func(MSG(RISUTL_I_SHOW_PARMS_5), p.max_static_stmts);
	output_func(MSG(RISUTL_I_SHOW_PARMS_6), p.max_user_stmts);
	output_func(MSG(RISUTL_I_SHOW_PARMS_7), p.max_secondary_schemas);
	output_func(MSG(RISUTL_I_SHOW_PARMS_8), p.max_transactions);
	output_func(MSG(RISUTL_I_SHOW_PARMS_9), p.max_tables_in_memory);
	output_func("\n");
	output_func(MSG(RISUTL_I_SHOW_PARMS_10), p.timestamp_interval);
	output_func(MSG(RISUTL_I_SHOW_PARMS_11), p.initial_timeout);
	output_func(MSG(RISUTL_I_SHOW_PARMS_12), p.timestamp_tolerance);
	output_func(MSG(RISUTL_I_SHOW_PARMS_13), p.buffer_full_size);
	output_func(MSG(RISUTL_I_SHOW_PARMS_14), p.buffer_full_timeout);
	output_func("\n");
	output_func(MSG(RISUTL_I_SHOW_PARMS_15), p.schema_file_protocol);
	output_func(MSG(RISUTL_I_SHOW_PARMS_16), p.schema_file_address);
	output_func(MSG(RISUTL_I_SHOW_PARMS_17), p.schema_file_username);
	output_func(MSG(RISUTL_I_SHOW_PARMS_18), p.schema_file_password);
	output_func(MSG(RISUTL_I_SHOW_PARMS_19), p.schema_file_filename);
	output_func("\n");
	output_func(MSG(RISUTL_I_SHOW_PARMS_20), p.lock_file_retry);
	output_func("\n");
	output_func(MSG(RISUTL_I_SHOW_PARMS_21), p.client_protocol);
	output_func(MSG(RISUTL_I_SHOW_PARMS_22), p.client_address);
	output_func(MSG(RISUTL_I_SHOW_PARMS_23), p.client_username);
	output_func(MSG(RISUTL_I_SHOW_PARMS_24), p.client_password);
	output_func(MSG(RISUTL_I_SHOW_PARMS_25), version);

	UCO_DBG(("RISuco_show_parameters:complete\n"));
}

/******************************************************************************/
