/* Do not alter this SPC information: $Revision: 1.1.53.1 $ */
/*
**	NAME:							utlshasy.c
**	AUTHORS:						Hitesh R. Patel
**	CREATION DATE:					2/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "util.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/
typedef char risschema_name[RIS_MAX_ID_SIZE];

/*
**	FUNCTION PROTOTYPES
*/
#define utlshasy_c
#include "comdebug.prt"
#include "comjmp.prt"
#include "comumsg.prt"
#include "ris.prt"
#include "utlshasy.prt"
#include "utlerror.prt"
#include "utlprint.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISutl_show_async_ids()
{
    int				i;
    int				count;
	int				status;
    int				*buffer;

	UTL_DBG(("RISutl_show_async_ids()\n"));

    /*
    **  Find out how many schema names
    */
    count = 0;
	buffer = 0;
    RISget_async_stmts(buffer, &count);
	UTL_WARNING_CHECK();
	UTL_ERROR_CHECK();

	if (!count)
	{
		UTL_DBG(("RISutl_show_async_stmts:complete\n"));
		return;
	}

    /*
    **  Allocate the space to hold the schema names
    */
    buffer = (int *)malloc(count * sizeof(int));
	if (buffer == NULL)
	{
		LONGJMP(RISUTL_E_MALLOC);
	}

	status = SETJMP();
	if (status)
	{
		RESETJMP();

		if (buffer)
		{
			free(buffer);
		}

		LONGJMP(status);
	}

    /*
    **  Retrieve the schema names
    */
    RISget_async_stmts(buffer, &count);
	UTL_WARNING_CHECK();
	UTL_ERROR_CHECK();

    /*
    **  Output the results
    */
    RISutl_printf(MSG(RISUTL_I_SHOW_ASYNC_IDS));

    for (i = 0; i < count; i++)
	{
        RISutl_printf("%d ", buffer[i]);
	}

    RISutl_printf("\n");

	if (buffer)
	{
		free(buffer);
	}

	RESETJMP();

	UTL_DBG(("RISutl_show_async_ids:complete\n"));
}

/******************************************************************************/

