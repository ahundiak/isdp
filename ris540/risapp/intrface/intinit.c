/* Do not alter this SPC information: $Revision: 1.3.38.1 $ */
/*
**	NAME:							intinit.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					12/91
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
#include "intrface.h"
#include "app.h"
#include "riscom.h"
#include "ris_err.h"
#include "net.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define intinit_c
#include "appinit.prt"
#include "appcli.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "intinit.prt"
#include "interror.prt"
#include "intrap.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISAPI RISXinitialize(
	char *language_name)
{
	int	sts;

	INT_DBG(("RISinitialize(language_name:<%s>)\n", STRING(language_name)));

	RIS_ENTER();

	RISrap_enter_BEGIN();
		fprintf(RIS_RAP, "INITIALIZE\n");
		fprintf(RIS_RAP, "language_name:0x%x\n", language_name);
        if (language_name)
        {
            fprintf(RIS_RAP, "*language_name:%s\n", language_name);
        }
	RISrap_enter_END();

	RIS_CLEAR_ERROR();

	if ((sts = SETJMP()) != 0)
	{
		RESETJMP();
		SET_RISCA(sts);
		RISrap_return();
		RIS_RETURN();
	}

	RISapp_initialize(language_name);

	RESETJMP();

	INT_DBG(("RISinitialize: complete\n"));
	SET_RISCA(RIS_SUCCESS);
	RISrap_return();

	RIS_RETURN();
}

/******************************************************************************/

extern void RISAPI RISXstart_client(
    void)
{
    int sts;

    INT_DBG(("RISstart_client()\n"));

    RIS_ENTER();

    RISrap_enter_BEGIN();
        fprintf(RIS_RAP, "START CLIENT\n");
    RISrap_enter_END();

    RIS_CLEAR_ERROR();

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

    if (!RIS_net)
    {
        RISapp_start_client();
    }

    RESETJMP();

    INT_DBG(("RISstart_client: complete\n"));
    SET_RISCA(RIS_SUCCESS);
    RISrap_return();
    RIS_RETURN();
}

/******************************************************************************/


extern void RISAPI RISXsetbypass()
{
   INT_DBG(("RISXsetbypass: set license bypass enable\n"));

   RIS_license_bypass = 1;

   RIS_RETURN();
}

/******************************************************************************/
