/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							btcdcode.c
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
#include "batch.h"
#if defined(WIN32S)
#include <windows.h>
#include <windowsx.h>
#include "winport.h"
#include "winio.h"
#include "winhan.h"
#include "prog32s.h"
#endif

/*
**	FUNCTION PROTOTYPES
*/
#define btcdcode_c
#include "comdebug.prt"
#include "comumsg.prt"
#include "btcdcode.prt"
#include "ucodcode.prt"
#include "ucofgets.prt"
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

extern void RISbtc_decode(
	char *arg)
{
    int 	status;
	char	*code;
	char	buffer[80]; 

	BTC_DBG(("RISbtc_decode(arg:0x%x)\n",arg));

	if (!arg || !*arg)
	{
#if defined(WIN32S)
		if (RISutl_file_tos->file == NULL)
#else
		if (RISutl_file_tos->file == stdin)
#endif
		{
			/* Prompt for the code */
			RISutl_printf(MSG(RISUTL_I_ENTER_DECODE));
		}
#if defined(WIN32S)
		if (RISutl_file_tos->file == NULL)
			GETS(buffer);
		else
			RISuco_fgets(buffer, 80, RISutl_file_tos->file);
#else
		RISuco_fgets(buffer, 80, RISutl_file_tos->file);
#endif
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

	BTC_DBG(("RISbtc_decode:returning\n"));
}

/******************************************************************************/
