/*
**	NAME:							intlocli.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					12/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
**                   Jan. 94, Modified for the version specf. and 
**                   interoperability -- Sanju.
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
#define intlocli_c
#include "appclear.prt"
#include "appinit.prt"
#include "appid.prt"
#include "appparmf.prt"
#include "appcli.prt"
#include "appsqlca.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "compd.prt"
#include "comumsg.prt"
#include "interror.prt"
#include "intlocli.prt"
#include "intrap.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/


/******************************************************************************/

extern void RISAPI RISXlocate_client(
	client_parms	*parms)
{
	int				sts;
	char            password[RIS_MAX_PASSWD_SIZE];
	static  short	stmt_id;

	INT_DBG(("RISlocate_client(parms:0x%x)\n", parms));

	RIS_ENTER();

    RISrap_enter_BEGIN();
        fprintf(RIS_RAP, "LOCATE CLIENT\n");
        fprintf(RIS_RAP, "parms:0x%x\n", parms);
        RISXrap_print_client_parms(RIS_RAP, parms);
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

	if (!RIS_mem)
	{
		RISapp_initialize(getenv("RIS_LANGUAGE"));
	}

	stmt_id = RISapp_new_stmt(RIS_DONT_CLEAR_FLAG, RIS_DYNAMIC_STMT);

	if (RIS_net)
	{
		LONGJMP(RIS_E_CLIENT_IS_RUNNING);
	}

    /*
    **  Encrypt the password
    */
    if (*parms->password)
    {
        if ((int)strlen(parms->password) > RIS_MAX_ID_SIZE - 1)
        {
            sprintf(RIS_ERRMSGC, RIScom_umsg(RIS_E_PASSWORD_CAN_NOT_LONGER),
                RIS_MAX_ID_SIZE - 1);
            LONGJMP(RIS_E_INV_CLIENT_PASSWD);
        }
        RIScom_pd(parms->password, password);
    }
    else
    {
        password[0] = '\0';
    }

	/*
	**	Validate the new client parameters
	*/
	RISapp_validate_client_spec(parms->protocol, parms->address, 
		parms->username, password, parms->major);

	RISapp_save_parameters();

	if ((sts = SETJMP()) != 0)
	{
		RESETJMP();
		RISapp_push_risca_dbca();

		if (!SETJMP()) RISapp_stop_client();
		RESETJMP();

		if (!SETJMP()) RISapp_restore_parameters();
		RESETJMP();

		RISapp_pop_risca_dbca();
		LONGJMP(sts);
	}

	/*
	**	Set the parameters to the new values
	*/
	RISapp_update_client_spec(parms->protocol, parms->address, parms->username,
		 password, parms->major, parms->feature);

	/*
	**	Try starting the client
	*/
	RISapp_start_client();

	/*
	**	Save the new values to the file.
	*/
	RISapp_write_parms_file();

	RESETJMP();

	RISapp_clear(&stmt_id, DONT_SET_SQLCODE, DONT_CLEAR_CLIENT, SYNC_MODE);

	RESETJMP();

	INT_DBG(("RISlocate_client:complete\n"));

	SET_RISCA(RIS_SUCCESS);
	RISrap_return();
	RIS_RETURN();
}

/******************************************************************************/


extern void RISAPI RISXget_client_location(
    client_parms    *parms)
{
    int sts;

    INT_DBG(("RISget_client_location(parms:0x%x)\n", parms));

    RIS_ENTER();

    RISrap_enter_BEGIN();
        fprintf(RIS_RAP, "GET CLIENT LOCATION\n");
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

    parms->protocol = RIS_client_parms.protocol;
    strcpy(parms->address, RIS_client_parms.address);
    strcpy(parms->username, RIS_client_parms.username);
    strcpy(parms->password, RIS_client_parms.password);
	parms->major = RIS_client_parms.major;
	parms->feature = RIS_client_parms.feature;

    INT_DBG(("RISget_client_location: returning\n"));

    SET_RISCA(RIS_SUCCESS);
    RISrap_return();
    RIS_RETURN();
}

/******************************************************************************/

