/* Do not alter this SPC information: $Revision: 1.2.45.1 $ */
/*
**	NAME:							intgtnme.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					8/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
**
**	01/95:	Changed the argument for RISapp_initialize from RIS_DEFAULT_LANGUAGE
**			to getenv("RIS_LANGUAGE").  Paula Blohm
*/
 
/*
**	INCLUDES
*/
#include <string.h>
#include "intrface.h"
#include "risasync.h"
#include "risflags.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define intgtnme_c
#include "appclear.prt"
#include "appcli.prt"
#include "appgetfl.prt"
#include "appid.prt"
#include "appinit.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "interror.prt"
#include "intgtnme.prt"
#include "intrap.prt"
#include "sys.prt"


/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

/*
**	This function retrieves schema names from schema file
*/
extern void RISAPI RISXget_schema_names(
	char	(*buffer)[RIS_MAX_ID_SIZE],
	int		*countp)
{
	int					sts;
	int					count;
	ris_schema_info		*schema;
	ris_schema_info		*schemas;
	static  short		stmt_id;

	INT_DBG(("RISget_schema_names(buffer:0x%x countp:0x%x)\n", buffer, countp));

	RIS_ENTER();

	RISrap_enter_BEGIN();
		fprintf(RIS_RAP, "GET SCHEMA NAMES\n");
		fprintf(RIS_RAP, "buffer:0x%x\n", buffer);
		fprintf(RIS_RAP, "countp:0x%x\n", countp);
		if (countp)
		{
			fprintf(RIS_RAP, "*countp:%d\n", *countp);
		}
	RISrap_enter_END();

	RIS_CLEAR_ERROR();

	stmt_id = -1;

	if ((sts = SETJMP()) != 0)
	{
		RESETJMP();
		if (stmt_id != -1)
		{
			RISapp_clear(&stmt_id, DONT_SET_SQLCODE, DONT_CLEAR_CLIENT,
				SYNC_MODE);
		}
		SET_RISCA(sts);
		RISrap_return();
		RIS_RETURN();
	}

   	if (RIS_client_died)
    {
        LONGJMP(RIS_E_CLIENT_DIED);
    }
    if (!countp)
    {
        LONGJMP(RIS_E_INV_ARG);
    }
    if (!RIS_mem)
    {
        /*
        ** This is OK as we'll be reading schema file
        */
        RISapp_initialize(getenv("RIS_LANGUAGE"));
    }
    if (!RIS_net)
    {
        RISapp_start_client();
    }

	stmt_id = RISapp_new_stmt(RIS_DONT_CLEAR_FLAG, RIS_DYNAMIC_STMT);

	RISapp_get_schfile(NULL, NULL, &schemas, NULL, USE_ALLOCB);

	count = 0;
	for (schema = schemas; schema; schema = schema->next) count++;

	if (*countp == 0)
	{
		*countp = count;
	}
	else if (*countp >= count)
	{
		count = 0;
		for (schema = schemas; schema; schema = schema->next)
		{
			memcpy(buffer[count], schema->schname, RIS_MAX_ID_SIZE);
			count++;
		}
		*countp = count;
	}
	else
	{
		LONGJMP(RIS_E_NOT_ENOUGH_SPACE);
	}

	RISapp_clear(&stmt_id, DONT_SET_SQLCODE, DONT_CLEAR_CLIENT, SYNC_MODE);

	RESETJMP();

	INT_DBG(("RISget_schema_names: complete\n"));

	SET_RISCA(RIS_SUCCESS);
	RISrap_return();
	RIS_RETURN();
}

/******************************************************************************/

/*
**	This function retrieves default schema name
*/
extern void RISAPI RISXget_default_schema_name(
	char	buffer[RIS_MAX_ID_SIZE])
{
	int sts;

	INT_DBG(("RISget_default_schema_name(buffer:0x%x)\n", buffer));

	RIS_ENTER();

	RISrap_enter_BEGIN();
		fprintf(RIS_RAP, "GET DEFAULT SCHNAME\n");
		fprintf(RIS_RAP, "buffer:0x%x\n", buffer);
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
    ** For default schema, though it does not make sense to call this function
    ** even if RIS was not initialized, call initialize and return NULL
    */
    if (!RIS_mem)
    {
        RISapp_initialize(getenv("RIS_LANGUAGE"));	
    }

	if (buffer)
	{
		if( RIS_def_schname[0] )
		{
			strcpy(buffer, RIS_def_schname);
		}
		else
		{
			buffer[0] = '\0';
		}
	}

    RESETJMP();
	INT_DBG(("RISget_default_schema_name:complete\n"));

	SET_RISCA(RIS_SUCCESS);
	RISrap_return();
	RIS_RETURN();
}

/******************************************************************************/

extern void RISAPI RISXget_current_stmt_schema_name(
	char	buffer[RIS_MAX_ID_SIZE])
{
	int sts;

	INT_DBG(("RISget_current_stmt_schema_name(buffer:0x%x)\n", buffer));

	RIS_ENTER();

	RISrap_enter_BEGIN();
		fprintf(RIS_RAP, "GET STMT SCHNAME\n");
		fprintf(RIS_RAP, "buffer:0x%x\n", buffer);
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
    ** For default schema, though it does not make sense to call this function
    ** even if RIS was not initialized, call initialize and return NULL
    */
    if (!RIS_mem)
    {
        RISapp_initialize(getenv("RIS_LANGUAGE"));
    }

	if (buffer)
	{
		if (RIS_stmt && RIS_stmt->prep_def_schname)
		{
			strcpy(buffer, RIS_stmt->prep_def_schname);
		}
		else
		{	
			buffer[0] = '\0';
		}
	}


    RESETJMP();
	INT_DBG(("RISget_current_stmt_schema_name:complete\n"));

	SET_RISCA(RIS_SUCCESS);
	RISrap_return();
	RIS_RETURN();
}

/******************************************************************************/
