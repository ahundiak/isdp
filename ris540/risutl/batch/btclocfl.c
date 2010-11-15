/* Do not alter this SPC information: $Revision: 1.2.9.1 $ */
/*
**	NAME:							btclocfl.c
**	AUTHORS:						Jennifer Xia
**	CREATION DATE:					1/91
**	ABSTRACT:
**		It contains functions which store information about the 
**		location of the risschema file into the parameters file.
**	
**	REVISION HISTORY:
**          mms - 12/1/95 - References to Ascii functions to Unicode
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
**	DEFINES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/*
**      FUNCTION PROTOTYPES
*/
#define btclocfl_c
#include "utlprint.prt"
#include "btclocfl.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "comumsg.prt"
#include "comisfn.prt"
#include "ris.prt"
#include "utlerror.prt"
#include "ucofgets.prt"
#if defined(WIN32S)
#include "btcpaswd.prt"
#else
#include "ucopaswd.prt"
#endif
#include "sys.prt"

/******************************************************************************/

extern void RISutl_show_schfile_loc(
	void)
{
	schema_file_parms parms;

	BTC_DBG(("RISutl_show_schfile_loc()\n"));

	RISget_schema_file_location(&parms);
	UTL_ERROR_CHECK();
	UTL_WARNING_CHECK();

	RISutl_printf("\n");
	RISutl_printf(MSG(RISUTL_I_SHOW_SCHFILE_LOC1), parms.protocol);
	RISutl_printf(MSG(RISUTL_I_SHOW_SCHFILE_LOC2), parms.address);
	RISutl_printf(MSG(RISUTL_I_SHOW_SCHFILE_LOC3), parms.username);
	RISutl_printf(MSG(RISUTL_I_SHOW_SCHFILE_LOC4), parms.password);
	RISutl_printf(MSG(RISUTL_I_SHOW_SCHFILE_LOC5), parms.filename);
	RISutl_printf("\n");

	BTC_DBG(("RISutl_show_schfile_loc:returning\n"));
}

/******************************************************************************/

static int get_schfile_loc(
	schema_file_parms *parms)
{
	/*
	**	This routine prompts the user for the new location of the schema file
	**	It returns 1 on error, otherwise returns 0
	*/
	char	verify_pwd[RIS_MAX_ID_SIZE];
	char	protocol[8];

	BTC_DBG(("get_schfile_loc(parms:0x%x)\n", parms)); 

	if (RISbtc_mode == INTERACTIVE_MODE &&
#if defined(WIN32S)
		RISutl_file_tos->file == NULL)
#else
		RISutl_file_tos->file == stdin)
#endif
	{
		RISutl_printf(MSG(RISUTL_I_PROTOCOL_MENU_M));
		RISutl_printf(MSG(RISUTL_I_PROTOCOL_MENU_T));
		RISutl_printf(MSG(RISUTL_I_PROTOCOL_MENU_X));
		RISutl_printf(MSG(RISUTL_I_PROTOCOL_MENU_D));
	}

	if (RISbtc_mode == INTERACTIVE_MODE &&
#if defined(WIN32S)
		RISutl_file_tos->file == NULL)
#else
		RISutl_file_tos->file == stdin)
#endif
	{
		RISutl_printf(MSG(RISUTL_I_5ENTER_NEW_PROTOCOL), "M,T,X or D");
	}

#if defined(WIN32S)
	if (RISutl_file_tos->file == NULL)
		GETS(protocol);
	else
	RISuco_fgets(protocol, 8, RISutl_file_tos->file);
#else
	RISuco_fgets(protocol, 8, RISutl_file_tos->file);
#endif
	if (strlen(protocol) != 1)
	{
		RISutl_printf(MSG(RISUTL_I_INVALID_CHOICE));
		return 1;
	}

	if (RIScom_islower(protocol[0]))
	{
		parms->protocol = RIScom_toupper(protocol[0]);
	}
	else
	{
		parms->protocol = protocol[0];
	}

	if ((parms->protocol != 'M') &&
		(parms->protocol != 'T') &&
		(parms->protocol != 'X') &&
		(parms->protocol != 'D'))
	{
		RISutl_printf(MSG(RISUTL_I_INVALID_CHOICE));
		return 1;
	}

	if (parms->protocol == 'M')
	{
		parms->address[0] = '\0';
		parms->username[0] = '\0';
		parms->password[0] = '\0';
	}
	else
	{
		/*
		**	Address
		*/
		if (RISbtc_mode == INTERACTIVE_MODE &&
#if defined(WIN32S)
		RISutl_file_tos->file == NULL)
#else
			RISutl_file_tos->file == stdin)
#endif
		{
			RISutl_printf(MSG(RISUTL_I_ENTER_NEW_ADDRESS));
		}

#if defined(WIN32S)
	if (RISutl_file_tos->file == NULL)
		GETS(parms->address);
	else
		RISuco_fgets(parms->address, RIS_MAX_NODE_SIZE,
			RISutl_file_tos->file);
#else
		RISuco_fgets(parms->address, RIS_MAX_NODE_SIZE,
			RISutl_file_tos->file);
#endif
		if (!parms->address[0])
		{
			RISutl_printf(MSG(RISUTL_I_ADDR_MUST_BE_SPEC));
			return 1;
		}

		/*
		**	Username
		*/
		if (RISbtc_mode == INTERACTIVE_MODE &&
#if defined(WIN32S)
		RISutl_file_tos->file == NULL)
#else
			RISutl_file_tos->file == stdin)
#endif
		{
			RISutl_printf(MSG(RISUTL_I_ENTER_NEW_USERNAME));
		}

#if defined(WIN32S)
	if (RISutl_file_tos->file == NULL)
		GETS(parms->username);
	else
		RISuco_fgets(parms->username, RIS_MAX_ID_SIZE,
			RISutl_file_tos->file);
#else
		RISuco_fgets(parms->username, RIS_MAX_ID_SIZE,
			RISutl_file_tos->file);
#endif
		if (!parms->username[0])
		{
			RISutl_printf(MSG(RISUTL_I_USER_MUST_BE_SPEC));
			return 1;
		}

		/*
		**	Password
		*/
		if (RISbtc_mode == INTERACTIVE_MODE &&
#if defined(WIN32S)
		RISutl_file_tos->file == NULL)
#else
			RISutl_file_tos->file == stdin)
#endif
		{
#if defined(WIN32S)
			RISbtc_get_password(RIScom_umsg(RISUTL_I_ENTER_NEW_PASSWORD),
				parms->password, RIS_MAX_ID_SIZE);
#else
			RISuco_get_password(RIScom_umsg(RISUTL_I_ENTER_NEW_PASSWORD),
				parms->password, RIS_MAX_ID_SIZE);
#endif
		}
		else
		{

#if defined(WIN32S)
	if (RISutl_file_tos->file == NULL)
		GETS(parms->password);
	else
			RISuco_fgets(parms->password, RIS_MAX_ID_SIZE, 
				RISutl_file_tos->file);
#else
			RISuco_fgets(parms->password, RIS_MAX_ID_SIZE, 
				RISutl_file_tos->file);
#endif
		}
		if (parms->protocol == 'T' && !parms->password[0])
		{
			RISutl_printf(MSG(RISUTL_I_TCP_REQUIRES_ADDR));
			return 1;
		}

		if (RISbtc_mode == INTERACTIVE_MODE &&
#if defined(WIN32S)
		RISutl_file_tos->file == NULL)
#else
			RISutl_file_tos->file == stdin)
#endif
		{
#if defined(WIN32S)
			RISbtc_get_password(RIScom_umsg(RISUTL_I_REENTER_NEW_PASSWORD),
				verify_pwd, RIS_MAX_ID_SIZE);
#else
			RISuco_get_password(RIScom_umsg(RISUTL_I_REENTER_NEW_PASSWORD),
				verify_pwd, RIS_MAX_ID_SIZE);
#endif
		}
		else
		{
#if defined(WIN32S)
	if (RISutl_file_tos->file == NULL)
		GETS(verify_pwd);
	else
			RISuco_fgets(verify_pwd, RIS_MAX_ID_SIZE,
				RISutl_file_tos->file);
#else
			RISuco_fgets(verify_pwd, RIS_MAX_ID_SIZE,
				RISutl_file_tos->file);
#endif
		}
		if (strcmp(parms->password, verify_pwd))
		{
			RISutl_printf(MSG(RISUTL_I_PASSWORDS_DONT_MATCH));
			return 1;
		}
	}

	if (RISbtc_mode == INTERACTIVE_MODE &&
#if defined(WIN32S)
		RISutl_file_tos->file == NULL)
#else
		RISutl_file_tos->file == stdin)
#endif
	{
		RISutl_printf(MSG(RISUTL_I_ENTER_NEW_FILE));
	}

#if defined(WIN32S)
	if (RISutl_file_tos->file == NULL)
		GETS(parms->filename);
	else
	RISuco_fgets(parms->filename, RIS_MAX_PATH_SIZE,
		RISutl_file_tos->file);
#else
	RISuco_fgets(parms->filename, RIS_MAX_PATH_SIZE,
		RISutl_file_tos->file);
#endif
	if (!parms->filename[0])
	{
		RISutl_printf(MSG(RISUTL_I_FILE_MUST_BE_SPEC));
		return 1;
	}

	BTC_DBG(("get_schfile_loc: returning 0\n")); 
	return 0;
}

/******************************************************************************/

extern void RISutl_locate_schfile(
	void)
{
	schema_file_parms	parms;

	BTC_DBG(("RISutl_locate_schfile()\n"));

	RISutl_show_schfile_loc();

	if (get_schfile_loc(&parms) == 0)
	{
		RISlocate_schema_file(&parms);
		UTL_ERROR_CHECK();
		UTL_WARNING_CHECK();
		RISutl_show_schfile_loc();
	}

	BTC_DBG(("RISutl_locate_schfile: returning\n"));
}

/******************************************************************************/
