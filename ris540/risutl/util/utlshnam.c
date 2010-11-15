/* Do not alter this SPC information: $Revision: 1.1.53.1 $ */
/*
**	NAME:							utlshnam.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					5/92
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
#define utlshnam_c
#include "comdebug.prt"
#include "comjmp.prt"
#include "comumsg.prt"
#include "ris.prt"
#include "utlshnam.prt"
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

extern void RISutl_show_schema_names()
{
    int				i;
    int				count;
	int				status;
    risschema_name	*buffer;

	UTL_DBG(("RISutl_show_schema_names()\n"));

    /*
    **  Find out how many schema names
    */
    count = 0;
	buffer = 0;
    RISget_schema_names(buffer, &count);
	UTL_WARNING_CHECK();
	UTL_ERROR_CHECK();

	if (!count)
	{
		UTL_DBG(("RISutl_show_schema_names:complete\n"));
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
    RISget_schema_names(buffer, &count);
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

	UTL_DBG(("RISutl_show_schema_names:complete\n"));
}

/******************************************************************************/

extern void RISutl_show_default_schema_name(
	void)
{
	char def_schname[RIS_MAX_ID_SIZE];

	UTL_DBG(("RISutl_show_default_schema_name()\n"));

	RISget_default_schema_name(def_schname);
	UTL_WARNING_CHECK();
	UTL_ERROR_CHECK();

	if (def_schname[0])
	{
		RISutl_printf(MSG(RISUTL_I_SHOW_DEF_SCHNAME_1), def_schname);
	}
	else
	{
		RISutl_printf(MSG(RISUTL_I_SHOW_DEF_SCHNAME_2));
	}

	UTL_DBG(("RISutl_show_default_schema_name:complete\n"));
}

/******************************************************************************/
