/* Do not alter this SPC information: $Revision: 1.1.53.1 $ */
/*
**	NAME:							utlshss.c
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
#define utlshss_c
#include "comdebug.prt"
#include "comjmp.prt"
#include "comumsg.prt"
#include "ris.prt"
#include "utlshss.prt"
#include "utlerror.prt"
#include "utlmisc.prt"
#include "utlprint.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISutl_show_ss_names()
{
    int				i;
    int				count;
	int				status;
    risschema_name	*buffer;

	UTL_DBG(("RISutl_show_ss_names()\n"));

    /*
    **  Find out how many schema names
    */
    count = 0;
	buffer = 0;
    RISget_superschema_names(buffer, &count);
	UTL_WARNING_CHECK();
	UTL_ERROR_CHECK();

	if (!count)
	{
		UTL_DBG(("RISutl_show_ss_names:returning\n"));
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
    RISget_superschema_names(buffer, &count);
	UTL_WARNING_CHECK();
	UTL_ERROR_CHECK();

    /*
    **  Output the results
    */
    for (i = 0; i < count; i++)
	{
        RISutl_printf(MSG(RISUTL_I_SHOW_SS_NAMES), buffer[i]);
	}

	if (buffer)
	{
		free(buffer);
	}

	RESETJMP();

	UTL_DBG(("RISutl_show_ss_names:returning\n"));
}

/******************************************************************************/

extern void RISutl_show_ss_def()
{
    int				i;
    int				count;
	char			schname[RIS_MAX_NODE_SIZE];
	char			def_schname[RIS_MAX_NODE_SIZE];
    risschema_name	buffer[10];

	UTL_DBG(("RISutl_show_ss_def()\n"));

	RISget_default_schema_name(def_schname);
	UTL_WARNING_CHECK();
	UTL_ERROR_CHECK();

	CLEAR_INTERRUPT();

	if (def_schname[0])
	{
		RISutl_printf(MSG(RISUTL_I_SHOW_SS_DEF_1), def_schname);
	}
	else
	{
		RISutl_printf(MSG(RISUTL_I_SHOW_SS_DEF_2));
	}
#if defined(WIN32S)
	if (RISutl_file_tos->file == NULL)
		gets(schname);
	else
		RISutl_fgets(schname, RIS_MAX_NODE_SIZE, RISutl_file_tos->file);
#else
	RISutl_fgets(schname, RIS_MAX_NODE_SIZE, RISutl_file_tos->file);
#endif
	if (INTERRUPTED())
	{
		UTL_DBG(("RISutl_show_ss_def:interrupted:returning\n"));
		return;
	}

	if (!schname[0])
	{
		if (def_schname[0])
		{
			strcpy(schname, def_schname);
		}
		else
		{
			UTL_DBG(("RISutl_show_ss_def:returning\n"));
			return;
		}
	}

    /*
    **  Retrieve the schema names
    */
	count = 10;
    RISget_superschema_definition(schname, buffer, &count);
	UTL_WARNING_CHECK();
	UTL_ERROR_CHECK();

    /*
    **  Output the results
    */
    RISutl_printf(MSG(RISUTL_I_SHOW_SS_DEF_3), buffer[0]);
    for (i = 1; i < count; i++)
	{
    	RISutl_printf(MSG(RISUTL_I_SHOW_SS_DEF_4), buffer[i]);
	}

	UTL_DBG(("RISutl_show_ss_def:returning\n"));
}

/******************************************************************************/
