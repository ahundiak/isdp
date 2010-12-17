/* Do not alter this SPC information: $Revision: 1.2.45.1 $ */
/*
**	NAME:							intgtprm.c
**	AUTHORS:						Hitesh Patel
**	CREATION DATE:					5/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
**                  Jan. 94, Modified for version spec./interopr. -- Sanju.
**
**	01/95:	Changed the argument for RISapp_initialize from RIS_DEFAULT_LANGUAGE
**			to getenv("RIS_LANGUAGE").  Paula Blohm
*/
 
/*
**	INCLUDES
*/
#include "intrface.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define intgtprm_c
#include "appinit.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "interror.prt"
#include "intgtprm.prt"
#include "intrap.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISAPI RISXget_parameters(
	ris_parameters *parameters)
{
	int				sts;

	INT_DBG(("RISget_parameters(parameters:0x%x)\n", parameters));

	RIS_ENTER();

	RISrap_enter_BEGIN();
		fprintf(RIS_RAP, "GET PARAMETERS\n");
		fprintf(RIS_RAP, "parameters:0x%x\n", parameters);
	RISrap_enter_END();

	RIS_CLEAR_ERROR();

	if ((sts = SETJMP()) != 0)
	{
		RESETJMP();
		SET_RISCA(sts);
		RISrap_return();
		RIS_RETURN();
	}

    /*
    ** CLIENT DIED not required
    */

	if (!parameters)
	{
		LONGJMP(RIS_E_INV_ARG);
	}

	if (!RIS_mem)
	{
		RISapp_initialize(getenv("RIS_LANGUAGE"));
	}

	memset(parameters, 0, sizeof(ris_parameters));

    parameters->shared_memory			= RIS_parms.shm_seg_size;
    parameters->max_local_servers		= RIS_parms.max_locals;
    parameters->max_rows				= RIS_parms.max_rows;
    parameters->max_buffer_size			= RIS_parms.max_buf_size;
    parameters->max_static_stmts		= RIS_parms.max_static_stmts;
    parameters->max_user_stmts			= RIS_parms.max_user_stmts;
    parameters->max_secondary_schemas	= RIS_parms.max_secondary_schemas;
    parameters->max_transactions		= RIS_parms.max_transactions;
    parameters->max_tables_in_memory	= RIS_parms.max_tab_in_mem;

    parameters->timestamp_interval	= RIS_timestamp.timestamp_interval;
    parameters->initial_timeout		= RIS_timestamp.initial_timeout;
    parameters->timestamp_tolerance	= RIS_timestamp.timestamp_tolerance;
    parameters->buffer_full_size	= RIS_timestamp.buffer_full_size;
    parameters->buffer_full_timeout	= RIS_timestamp.buffer_full_timeout;

    parameters->schema_file_protocol = RIS_schfile_parms.protocol;
    strcpy(parameters->schema_file_address, RIS_schfile_parms.address);
    strcpy(parameters->schema_file_username, RIS_schfile_parms.username);
    strcpy(parameters->schema_file_password, RIS_schfile_parms.password);
    strcpy(parameters->schema_file_filename, RIS_schfile_parms.filename);
    parameters->lock_file_retry		= RIS_schfile_parms.lock_file_retry;

    parameters->client_protocol	= RIS_client_parms.protocol;
    strcpy(parameters->client_address, RIS_client_parms.address);
    strcpy(parameters->client_username, RIS_client_parms.username);
    strcpy(parameters->client_password, RIS_client_parms.password);
	parameters->client_major = RIS_client_parms.major;
	parameters->client_feature = RIS_client_parms.feature;

	RESETJMP();

	INT_DBG(("RISget_parameters: complete\n"));

	SET_RISCA(RIS_SUCCESS);
	RISrap_return();
	RIS_RETURN();
}

/******************************************************************************/
