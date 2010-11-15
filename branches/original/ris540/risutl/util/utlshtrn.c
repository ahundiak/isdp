/* Do not alter this SPC information: $Revision: 1.1.53.1 $ */
/*
**	NAME:							utlshtrn.c
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
#define utlshtrn_c
#include "comdebug.prt"
#include "comjmp.prt"
#include "comumsg.prt"
#include "ris.prt"
#include "utlshtrn.prt"
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

extern void RISutl_show_schema_transactions()
{
    int				i;
    int				count;
	int				status;
    risschema_name	*buffer;

	UTL_DBG(("RISutl_show_schema_transactions()\n"));

    /*
    **  Find out how many schema names
    */
    count = 0;
	buffer = 0;
    RISget_schema_transactions(buffer, &count);
	UTL_WARNING_CHECK();
	UTL_ERROR_CHECK();

	if (!count)
	{
		UTL_DBG(("RISutl_show_schema_transactions:complete\n"));
		return;
	}

    /*
    **  Allocate the space to hold the schema names
    */
    buffer = (risschema_name *)malloc(count * sizeof(risschema_name));
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
    RISget_schema_transactions(buffer, &count);
	UTL_WARNING_CHECK();
	UTL_ERROR_CHECK();

    /*
    **  Output the results
    */
    for (i = 0; i < count; i++)
	{
        RISutl_printf(MSG(RISUTL_I_SHOW_SCHNAMES_1), buffer[i]);
	}

	if (buffer)
	{
		free(buffer);
	}

	RESETJMP();

	UTL_DBG(("RISutl_show_schema_transactions:complete\n"));
}

/******************************************************************************/

