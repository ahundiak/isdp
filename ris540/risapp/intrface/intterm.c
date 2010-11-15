/* Do not alter this SPC information: $Revision: 1.1.57.1 $ */
/*
**	NAME:							intterm.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					12/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "risasync.h"
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
#define intterm_c
#include "appclear.prt"
#include "appcli.prt"
#include "appterm.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "comwrap.prt"
#include "interror.prt"
#include "intrap.prt"
#include "intterm.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISAPI RISXterminate(
	void)
{
	int	sts;

	INT_DBG(("RISterminate()\n"));

	RIS_ENTER();

	RISrap_enter_BEGIN();
		fprintf(RIS_RAP, "TERMINATE\n");
	RISrap_enter_END();

	RIS_CLEAR_ERROR();

	if ((sts = SETJMP()) != 0)
	{
		RESETJMP();
		SET_RISCA(sts);
		RISrap_return();
		RIS_RETURN();
	}

	RISapp_stop_client();

	intrap_free();
    RISapp_terminate();
    RISXint_term_error_msg();

	RESETJMP();

	INT_DBG(("RISterminate: complete\n"));

	SET_RISCA(RIS_SUCCESS);
	RISrap_return();
    RISrap_term();
	RIS_RETURN();
}

/*****************************************************************************/

extern void RISAPI RISXstop_client(
	void)
{
    int sts;

    INT_DBG(("RISstop_client()\n"));

    RIS_ENTER();

    RISrap_enter_BEGIN();
        fprintf(RIS_RAP, "STOP CLIENT\n");
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
	** Clear all async stmts; if any in incomplete state return error; 
	** Therefore call this function before calling clear_all to clear all
	** prepared stmts
	*/
	RISapp_clear_all_async();

    RISapp_clear_all(DONT_CLEAR_CLIENT);

    RISapp_stop_client();

    RESETJMP();

    INT_DBG(("RISstop_client: complete\n"));

    SET_RISCA(RIS_SUCCESS);
    RISrap_return();
    RIS_RETURN();
}

/******************************************************************************/
