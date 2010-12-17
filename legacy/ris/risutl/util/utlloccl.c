/* Do not alter this SPC information: $Revision: 1.2.26.1 $ */
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
#define utlloccl_c
#include "comdebug.prt"
#include "comisfn.prt"
#include "comjmp.prt"
#include "comumsg.prt"
#include "ris.prt"
#include "utlloccl.prt"
#include "utlerror.prt"
#include "utlmisc.prt"
#include "ucopaswd.prt"
#include "sys.prt"

/******************************************************************************/

extern void RISutl_show_client_loc(
	void)
{
	char version[40];
	client_parms parms;

	UTL_DBG(("RISutl_show_client_loc()\n"));

	RISget_client_location(&parms);
	UTL_WARNING_CHECK();
	UTL_ERROR_CHECK();

	sprintf(version, "%d.%d", parms.major, parms.feature);
	if (parms.major == 0 && parms.feature == 0)
	{
		strcat(version, MSG(RISUTL_I_USE_DEFAULT_VERSION));
	}

	printf("\n");
	printf(MSG(RISUTL_I_SHOW_CLIENT_LOC1), parms.protocol);
	printf(MSG(RISUTL_I_SHOW_CLIENT_LOC2), parms.address);
	printf(MSG(RISUTL_I_SHOW_CLIENT_LOC3), parms.username);
	printf(MSG(RISUTL_I_SHOW_CLIENT_LOC4), parms.password);
	printf(MSG(RISUTL_I_SHOW_CLIENT_LOC5), version);
	printf("\n");

	UTL_DBG(("RISutl_show_client_loc:returning\n"));
}

/******************************************************************************/

static int get_client_loc(
	client_parms *parms)
{
	/*
	**	This routine prompts the user for the new location of the schema file
	**	It returns 1 if user quit, otherwise returns 0
	*/
	char	verify_pwd[RIS_MAX_ID_SIZE];
#if defined(unix) || defined(WIN32)
	char	protocol[8];
#endif

	UTL_DBG(("get_client_loc(parms:0x%x)\n", parms)); 

	CLEAR_INTERRUPT();

	if (RISutl_file_tos->file == stdin)
	{
#if defined(__clipper__)
		printf(MSG(RISUTL_I_PROTOCOL_MENU_M));
		printf(MSG(RISUTL_I_PROTOCOL_MENU_T));
		printf(MSG(RISUTL_I_PROTOCOL_MENU_X));
		printf(MSG(RISUTL_I_PROTOCOL_MENU_D));
#elif defined(unix) || defined(WIN32)
		printf(MSG(RISUTL_I_PROTOCOL_MENU_M));
		printf(MSG(RISUTL_I_PROTOCOL_MENU_T));
#endif
	}

#if defined(unix) || defined(WIN32)
	for (;;)
	{
		if (RISutl_file_tos->file == stdin)
		{
#if defined(__clipper__)
			printf(MSG(RISUTL_I_5ENTER_NEW_PROTOCOL), "M,T,X or D");
#elif defined(unix) || defined(WIN32)
			printf(MSG(RISUTL_I_5ENTER_NEW_PROTOCOL), "M or T");
#endif
		}
		RISutl_fgets(protocol, 8, RISutl_file_tos->file);
		if (INTERRUPTED())
		{
			UTL_DBG(("get_client_loc:returning 1\n")); 
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

#if defined(__clipper__)
			if ((parms->protocol == 'M') ||
				(parms->protocol == 'T') ||
				(parms->protocol == 'X') ||
				(parms->protocol == 'D'))
			{
				break;
			}
#elif defined(unix) || defined(WIN32)
			if ((parms->protocol == 'M') ||
				(parms->protocol == 'T'))
			{
				break;
			}
#endif
		}

		printf(MSG(RISUTL_I_INVALID_CHOICE));
	}
#endif /* unix or WIN32 */
#if defined(DOS)
	parms->protocol = 'T';
#endif

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
				UTL_DBG(("get_client_loc:returning 1\n")); 
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
				UTL_DBG(("get_client_loc:returning 1\n")); 
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
			if (RISutl_file_tos->file == stdin)
			{
				RISuco_get_password(RIScom_umsg(RISUTL_I_ENTER_NEW_PASSWORD),
					parms->password, RIS_MAX_ID_SIZE);
			}
			else
			{
				RISutl_fgets(parms->password, RIS_MAX_ID_SIZE,
					RISutl_file_tos->file);
			}
			if (INTERRUPTED())
			{
				UTL_DBG(("get_client_loc:returning 1\n")); 
				return 1;
			}

			if (RISutl_file_tos->file == stdin)
			{
				RISuco_get_password(RIScom_umsg(RISUTL_I_REENTER_NEW_PASSWORD),
					verify_pwd, RIS_MAX_ID_SIZE);
			}
			else
			{
				RISutl_fgets(verify_pwd, RIS_MAX_ID_SIZE,
					RISutl_file_tos->file);
			}
			if (INTERRUPTED())
			{
				UTL_DBG(("get_client_loc:returning 1\n")); 
				return 1;
			}
			if (!strcmp(parms->password, verify_pwd)) break;
			printf(MSG(RISUTL_I_THEY_DONT_MATCH));
		}
	}

	for(;;)
	{
		char version[8];

		if (RISutl_file_tos->file == stdin)
		{
			printf(MSG(RISUTL_I_ENTER_NEW_VERSION));
		}
		RISutl_fgets(version, sizeof(version), RISutl_file_tos->file);
		if (INTERRUPTED())
		{
			UTL_DBG(("get_client_loc:returning 1\n")); 
			return 1;
		}
		if (version[0] == '\0')
		{
			parms->major = 0;
			parms->feature = 0;
			break;
		}
		if (sscanf(version, "%hd.%hd", &parms->major, &parms->feature) == 2)
		{
			break;
		}
		printf(MSG(RISUTL_I_INVALID_VERSION));
	}

	UTL_DBG(("get_client_loc:returning 0\n")); 
	return 0;
}

/******************************************************************************/

extern void RISutl_locate_client(
	void)
{
	client_parms	parms;

	UTL_DBG(("RISutl_locate_client()\n"));

	RISutl_show_client_loc();

	if (!get_client_loc(&parms))
	{
		RISlocate_client(&parms);
		UTL_WARNING_CHECK();
		UTL_ERROR_CHECK();

		RISutl_show_client_loc();
	}

	UTL_DBG(("RISutl_locate_client: returning\n"));
}

/******************************************************************************/
