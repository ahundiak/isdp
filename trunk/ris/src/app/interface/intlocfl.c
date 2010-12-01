/* Do not alter this SPC information: $Revision: 1.3.3.1 $ */
/*
**	NAME:							intlocfl.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					9/91
**	ABSTRACT:
**		The functions which store information about the location of the
**		risschema file into the parameters file.
**	
**	REVISION HISTORY:
**
**	01/95:	Changed the argument for RISapp_initialize from RIS_DEFAULT_LANGUAGE
**			to getenv("RIS_LANGUAGE").  Paula Blohm
*/
#include "risrap.h"
#include "risapp.h"
#include "risapp_interface.h"
#include "risapp_rap.h"
#include "riscom.h"

#include "risasync.h"
#include "risflags.h"
#include "risdebug.h"

/******************************************************************************/

extern void RISAPI RISXlocate_schema_file(schema_file_parms	*parms)
{
	int     sts;
  char    password[RIS_MAX_PASSWD_SIZE];
	static  short	stmt_id;

	INT_DBG(("RISlocate_schema_file(parms:0x%x)\n", parms));

	RIS_ENTER();

	RISrap_enter_BEGIN();
		fprintf(RIS_RAP, "LOCATE SCHEMA FILE\n");
		fprintf(RIS_RAP, "parms:0x%x\n", parms);
		RISXrap_print_schema_file_parms(RIS_RAP, parms);
	RISrap_enter_END();

	RIS_CLEAR_ERROR();

	stmt_id = -1;

	if (RIS_client_died)
	{
		SET_RISCA(RIS_E_CLIENT_DIED);
		RISrap_return();
		RIS_RETURN();
	}

	if (!parms)
	{
		SET_RISCA(RIS_E_INV_ARG);
		RISrap_return();
		RIS_RETURN();
	}

	INT_DBG(("locate_schema_file: protocol:%c address:<%s> username:<%s> "
		"filename:<%s>\n", parms->protocol, parms->address, parms->username,
		parms->filename));

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

	if (!RIS_mem)
	{
		RISapp_initialize(getenv("RIS_LANGUAGE"));
	}

	if (!RIS_net)
	{
		RISapp_start_client();
	}

	stmt_id = RISapp_new_stmt(RIS_DONT_CLEAR_FLAG, RIS_DYNAMIC_STMT);

    /*
    **  Encrypt the password
    */
    if (*parms->password)
    {
        if (strlen(parms->password) > RIS_MAX_ID_SIZE - 1)
        {
            sprintf(RIS_ERRMSGC, RIScom_umsg(RIS_E_PASSWORD_CAN_NOT_LONGER),
                RIS_MAX_ID_SIZE - 1);
            LONGJMP(RIS_E_INV_SCHFILE_PASSWD);
        }
        RIScom_pd(parms->password, password);
    }
    else
    {
        password[0] = '\0';
    }

	/*
	** We are expecting quotes around the schema filename
	** (e.g. "C:\Program Files\Common Files\Intergraph\schemas")
	** in which case, we need to remove it before handing it
	** over to the client. RIS client code is modified to handle
	** schema filename with spaces (in riscom/network/nettcp.c)
	** and it gets completely messed up if it sees the quotes.
	** So, remove the quotes from the parms file completely.
	**
	** This fixes TR# 439601492, 439601595. Surjit (July 22, 1996)
	*/
	{
		char temp[RIS_MAX_PATH_SIZE];
		strcpy(temp, parms->filename);
		if ((*temp == '\'' && *(temp+strlen(temp)-1) == '\'')
		 || (*temp == '\"' && *(temp+strlen(temp)-1) == '\"'))
		{
			INT_DBG(("Adjusting the quotes: "));
			*(temp+strlen(temp)-1) = '\0';
			strcpy(parms->filename, temp+1);
			INT_DBG(("<%s>\n", parms->filename));
		}
	}

    /*
    **  Validate the new schema file parameters
    */
    RISapp_validate_schfile_spec(parms->protocol, parms->address,
        parms->username, password, parms->filename);

	/*
	**	Send the new schema file parameters to the client
	*/
	RISapp_locate_schfile_to_buf(parms->protocol, parms->address,
		parms->username, password, parms->filename);
	RISapp_send_rec();

	/*
	**	Update the parameters file.  If there is an error, restore the
	**	current parameters and send the rollback code to the client.
	*/

	RISapp_save_parameters();

	if ((sts = SETJMP()) != 0)
	{
		RESETJMP();
		RISapp_push_risca_dbca();

		RISapp_restore_parameters();
		RISapp_opcode_to_buf(RISCLI_DICT_ROLLBACK_CODE, SYNC_MODE);
		RISapp_send_rec();

		RISapp_pop_risca_dbca();
		LONGJMP(sts);
	}
	else
	{
		/*
		**	Set the parameters to the new values
		*/
		RISapp_update_schfile_spec(parms->protocol, parms->address,
			parms->username, password, parms->filename);

		/*
		**	Save the new values to the file.
		*/
		RISapp_write_parms_file();
		RESETJMP();
	}

	RISapp_clear(&stmt_id, DONT_SET_SQLCODE, DONT_CLEAR_CLIENT, SYNC_MODE);

	RESETJMP();

	INT_DBG(("RISlocate_schema_file: complete\n"));

	SET_RISCA(RIS_SUCCESS);
	RISrap_return();
	RIS_RETURN();
}

/******************************************************************************/

extern void RISAPI RISXget_schema_file_location(schema_file_parms	*parms)
{
	int sts;

	INT_DBG(("RISget_schema_file_location(parms:0x%x)\n", parms));

	RIS_ENTER();

	RISrap_enter_BEGIN();
		fprintf(RIS_RAP, "GET SCHEMA FILE LOCATION\n");
		fprintf(RIS_RAP, "parms:0x%x\n", parms);
	RISrap_enter_END();

    RIS_CLEAR_ERROR();

	if (!parms)
	{
		SET_RISCA(RIS_E_INV_ARG);
		RISrap_return();
		RIS_RETURN();
	}

	if ((sts = SETJMP()) != 0)
	{
		RESETJMP();
		SET_RISCA(sts);
		RISrap_return();
		RIS_RETURN();
	}

	if (!RIS_mem)
	{
		RISapp_initialize(getenv("RIS_LANGUAGE"));
	}

	RESETJMP();

	parms->protocol = RIS_schfile_parms.protocol;
	strcpy(parms->address, RIS_schfile_parms.address);
	strcpy(parms->username, RIS_schfile_parms.username);
	strcpy(parms->password, RIS_schfile_parms.password);
	strcpy(parms->filename, RIS_schfile_parms.filename);

	INT_DBG(("RISget_schema_file_location: returning\n"));

	SET_RISCA(RIS_SUCCESS);
	RISrap_return();
	RIS_RETURN();
}

/******************************************************************************/
