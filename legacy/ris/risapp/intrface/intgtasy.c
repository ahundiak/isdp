/* Do not alter this SPC information: $Revision: 1.2.45.1 $ */
/*
**	NAME:							intgtasy.c
**	AUTHORS:						Prasad Challa
**	CREATION DATE:					1/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
**
**	01/95:	Changed the argument for RISapp_initialize from RIS_DEFAULT_LANGUAGE
**			to getenv(RIS_LANGUAGE).  Paula Blohm
*/
 
/*
**	INCLUDES
*/
#include "intrface.h"
#include "risflags.h"
#include "risasync.h"

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
#include "appid.prt"
#include "appinit.prt"
#include "comdebug.prt"
#include "comjmp.prt"
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

extern void RISAPI RISXget_async_stmts(
	int		*buffer,
	int		*countp)
{
	int					sts;
	int					count;
	static  short		stmt_id;
	int					id;

	INT_DBG(("RISget_async_stmts(buffer:0x%x countp:0x%x)\n", buffer, countp));

    RIS_ENTER();

    RISrap_enter_BEGIN();
        fprintf(RIS_RAP, "GET ASYNC STMTS\n");
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

    if (!countp)
    {
        LONGJMP(RIS_E_INV_ARG);
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

	count = 0;
	for (id = 0; id < RIS_MAX_TRANSACTIONS; id ++)
	{
		if (RIS_asyncs[id])
		{
			count++;
		}
	}

	if (*countp == 0)
	{
		*countp = count;
	}
	else if (*countp >= count)
	{
		count = 0;
		for (id = 0; id < RIS_MAX_TRANSACTIONS; id ++)
		{
			if (RIS_asyncs[id])
			{
				buffer[count] = id;
				count++;
			}
		}
		*countp = count;
	}
	else
	{
		LONGJMP(RIS_E_NOT_ENOUGH_SPACE);
	}

    RISapp_clear(&stmt_id, DONT_SET_SQLCODE, DONT_CLEAR_CLIENT, SYNC_MODE);

	RESETJMP();

	INT_DBG(("RISget_async_stmts: complete\n"));

    SET_RISCA(RIS_SUCCESS);
    RISrap_return();
    RIS_RETURN();
}

/******************************************************************************/
