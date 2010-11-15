/* Do not alter this SPC information: $Revision: 1.1.53.1 $ */
/*
**	NAME:							utllocfl.c
**	AUTHORS:						Jennifer Xia
**	CREATION DATE:					1/91
**	ABSTRACT:
**		It contains functions which store information about the 
**		location of the risschema file into the parameters file.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <ctype.h>
#include "util.h"

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
#define utllocfl_c
#include "comdebug.prt"
#include "comisfn.prt"
#include "comjmp.prt"
#include "comumsg.prt"
#include "ris.prt"
#include "utllocfl.prt"
#include "utlerror.prt"
#include "utlmisc.prt"
#include "ucopaswd.prt"
#include "sys.prt"

/******************************************************************************/

extern void RISutl_show_schfile_loc(
	void)
{
	schema_file_parms parms;

	UTL_DBG(("RISutl_show_schfile_loc()\n"));

	RISget_schema_file_location(&parms);
	UTL_WARNING_CHECK();
	UTL_ERROR_CHECK();

	printf("\n");
	printf(MSG(RISUTL_I_SHOW_SCHFILE_LOC1), parms.protocol);
	printf(MSG(RISUTL_I_SHOW_SCHFILE_LOC2), parms.address);
	printf(MSG(RISUTL_I_SHOW_SCHFILE_LOC3), parms.username);
	printf(MSG(RISUTL_I_SHOW_SCHFILE_LOC4), parms.password);
	printf(MSG(RISUTL_I_SHOW_SCHFILE_LOC5), parms.filename);
	printf("\n");

	UTL_DBG(("RISutl_show_schfile_loc:returning\n"));
}

/******************************************************************************/

static int get_schfile_loc(
	schema_file_parms *parms)
{
	/*
	**	This routine prompts the user for the new location of the schema file
	**	It returns 1 if user quit, otherwise returns 0
	*/
	char	verify_pwd[RIS_MAX_ID_SIZE];
	char	protocol[8];

	UTL_DBG(("get_schfile_loc(parms:0x%x)\n", parms)); 

	CLEAR_INTERRUPT();

	if (RISutl_file_tos->file == stdin)
	{
		printf(MSG(RISUTL_I_PROTOCOL_MENU_M));
		printf(MSG(RISUTL_I_PROTOCOL_MENU_T));
		printf(MSG(RISUTL_I_PROTOCOL_MENU_X));
		printf(MSG(RISUTL_I_PROTOCOL_MENU_D));
	}

	for (;;)
	{
		if (RISutl_file_tos->file == stdin)
		{
			printf(MSG(RISUTL_I_5ENTER_NEW_PROTOCOL), "M,T,X or D");
		}
		RISutl_fgets(protocol, 8, RISutl_file_tos->file);
		if (INTERRUPTED())
		{
			UTL_DBG(("get_schfile_loc:returning 1\n")); 
			return 1;
		}
		if (strlen(protocol) == 1)
		{
			if (RIScom_islower(protocol[0]))
			{
				parms->protocol = RIScom_toupper(protocol[0]);
			}
			else
			{
				parms->protocol = protocol[0];
			}

			if ((parms->protocol == 'M') ||
				(parms->protocol == 'T') ||
				(parms->protocol == 'X') ||
				(parms->protocol == 'D'))
			{
				break;
			}
		}
		printf(MSG(RISUTL_I_INVALID_CHOICE));
	}

	if (parms->protocol == 'M')
	{
		parms->address[0] = '\0';
		parms->username[0] = '\0';
		parms->password[0] = '\0';
	}
	else
	{
		for(;;)
		{
			if (RISutl_file_tos->file == stdin)
			{
				printf(MSG(RISUTL_I_ENTER_NEW_ADDRESS));
			}
			RISutl_fgets(parms->address, RIS_MAX_NODE_SIZE,
				RISutl_file_tos->file);
			if (INTERRUPTED())
			{
				UTL_DBG(("get_schfile_loc: returning 1\n")); 
				return 1;
			}
			if (parms->address[0])
			{
				break;
			}
			printf(MSG(RISUTL_I_ADDR_MUST_BE_SPEC));
		}

		for(;;)
		{
			if (RISutl_file_tos->file == stdin)
			{
				printf(MSG(RISUTL_I_ENTER_NEW_USERNAME));
			}
			RISutl_fgets(parms->username, RIS_MAX_ID_SIZE,
				RISutl_file_tos->file);
			if (INTERRUPTED())
			{
				UTL_DBG(("get_schfile_loc: returning 1\n")); 
				return 1;
			}
			if (parms->username[0])
			{
				break;
			}
			printf(MSG(RISUTL_I_USER_MUST_BE_SPEC));
		}

		for (;;)
		{
			do
			{
				if (RISutl_file_tos->file == stdin)
				{
					RISuco_get_password(
						RIScom_umsg(RISUTL_I_ENTER_NEW_PASSWORD),
						parms->password, RIS_MAX_ID_SIZE);
				}
				else
				{
					RISutl_fgets(parms->password, RIS_MAX_ID_SIZE,
						RISutl_file_tos->file);
				}
				if (INTERRUPTED())
				{
					UTL_DBG(("get_schfile_loc: returning 1\n")); 
					return 1;
				}
			}while (parms->protocol == 'T' &&
					parms->password[0] == '\0' &&
					printf(MSG(RISUTL_I_TCP_REQUIRES_ADDR)));

			if (RISutl_file_tos->file == stdin)
			{
				RISuco_get_password(RIScom_umsg(RISUTL_I_REENTER_NEW_PASSWORD),
					verify_pwd, RIS_MAX_ID_SIZE);
			}
			else
			{
				RISutl_fgets(verify_pwd, RIS_MAX_PATH_SIZE,
					RISutl_file_tos->file);
			}
			if (INTERRUPTED())
			{
				UTL_DBG(("get_schfile_loc: returning 1\n")); 
				return 1;
			}
			if (!strcmp(parms->password, verify_pwd)) break;
			printf(MSG(RISUTL_I_THEY_DONT_MATCH));
		}
	}

	for (;;)
	{
		if (RISutl_file_tos->file == stdin)
		{
			printf(MSG(RISUTL_I_ENTER_NEW_FILE));
		}
		RISutl_fgets(parms->filename, RIS_MAX_PATH_SIZE,
			RISutl_file_tos->file);
		if (INTERRUPTED())
		{
			UTL_DBG(("get_schfile_loc: returning 1\n")); 
			return 1;
		}
		if (parms->filename[0])
		{
			break;
		}
		printf(MSG(RISUTL_I_FILE_MUST_BE_SPEC));
	}

	UTL_DBG(("get_schfile_loc: returning 0\n")); 
	return 0;
}

/******************************************************************************/

extern void RISutl_locate_schfile(
	void)
{
	schema_file_parms	parms;

	UTL_DBG(("RISutl_locate_schfile()\n"));

	RISutl_show_schfile_loc();

	if (get_schfile_loc(&parms) == 0)
	{
		RISlocate_schema_file(&parms);
		UTL_WARNING_CHECK();
		UTL_ERROR_CHECK();
		RISutl_show_schfile_loc();
	}

	UTL_DBG(("RISutl_locate_schfile: returning\n"));
}

/******************************************************************************/
