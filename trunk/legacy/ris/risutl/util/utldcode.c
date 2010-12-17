/* Do not alter this SPC information: $Revision: 1.1.53.1 $ */
/*
**	NAME:							utldcode.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:				
**	ABSTRACT:
**		The source to the DECODE utility.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <ctype.h>
#include "util.h"

/*
**	FUNCTION PROTOTYPES
*/
#define utldcode_c
#include "comdebug.prt"
#include "comumsg.prt"
#include "utldcode.prt"
#include "ucodcode.prt"
#include "utlmisc.prt"
#include "utlprint.prt"


/*
**	DEFINES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISutl_decode(
	char *arg)
{
    int 	status;
	char	*code;
	char	buffer[80]; 

	UTL_DBG(("RISutl_decode(arg:0x%x)\n",arg));

	CLEAR_INTERRUPT();

	do
	{
		if (!arg || !*arg)
		{
			/* Prompt for the code */
			if (RISutl_file_tos->file == stdin)
			{
				RISutl_printf(MSG(RISUTL_I_ENTER_DECODE));
			}
			RISutl_fgets(buffer, 80, RISutl_file_tos->file);
			if (INTERRUPTED())
			{
				RISutl_printf("\n");
	
				UTL_DBG(("RISutl_decode: interrupted: returning\n"));
				return;
			}
			code = buffer;
		}
		else
		{
			code = arg;
		}

		if (!RISuco_valid_code(code, &status))
		{
			RISutl_printf(MSG(RISUTL_E_INVALID_CODE));
			RISutl_printf("\n");
		}
		else if (!RISuco_decode(status, RISutl_printf))
		{
			RISutl_printf(MSG(RISUTL_E_INV_CODE));
			RISutl_printf("\n");
		}
		else
		{
			break;
		}
	}
	while(!arg || !*arg);

	UTL_DBG(("RISutl_decode:returning\n"));
}

/******************************************************************************/
