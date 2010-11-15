/* Do not alter this SPC information: $Revision: 1.1.59.1 $ */
/*
**	NAME:							appschf.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					9/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
**
**	10/94:	Added support for INTERNATIONALIZATION.  Mark Boswell
*/
 
/*
**	INCLUDES
*/
#include "app.h"
#include "commacro.h"
#include <ctype.h>

/*
**	DEFINES
*/
#define INVALID_FLAG		0
#define OPTIONAL_FLAG	1
#define REQUIRED_FLAG	2

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define appschf_c
#include "appschf.prt"
#include "comdebug.prt"
#include "comisfn.prt"
#include "comjmp.prt"
#include "comstrcp.prt"
#include "comumsg.prt"
#include "comuni.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/



/******************************************************************************/

extern void RISapp_validate_schfile_spec(
	char	protocol,
	char	*address,
	char	*username,
	char	*password,
	char	*filename)
{
	char	prot;
	char	address_flag = 0;
	char	username_flag = 0;
	char	password_flag = 0;
	char	filename_flag = 0;

	APP_DBG(("RISapp_validate_schfile_spec(protocol:%c address:<%s> "
		"username:<%s> filename:<%s>)\n", protocol, address, username,
		filename));

	if ( ISLOWER(protocol) )
	{
		prot = (char)RIScom_toupper(protocol);
	}
	else
	{
		prot = protocol;
	}
	if (!VALID_PROTOCOL(prot))
	{
		sprintf(RIS_ERRMSGC, RIScom_umsg(RIS_E_EXPECTED_M_X_T_D) ,
			RIScom_isprint(prot)?prot:' ');
		LONGJMP(RIS_E_INV_SCHFILE_PROTOCOL);
	}

	switch(prot)
	{
		case 'M':
			address_flag = INVALID_FLAG;
			username_flag = INVALID_FLAG;
			password_flag = INVALID_FLAG;
			filename_flag = REQUIRED_FLAG;
			break;

		case 'X':
			address_flag = REQUIRED_FLAG;
			username_flag = REQUIRED_FLAG;
			password_flag = OPTIONAL_FLAG;
			filename_flag = REQUIRED_FLAG;
			break;

		case 'T':
			address_flag = REQUIRED_FLAG;
			username_flag = REQUIRED_FLAG;
			password_flag = REQUIRED_FLAG;
			filename_flag = REQUIRED_FLAG;
			break;

		case 'D':
			address_flag = REQUIRED_FLAG;
			username_flag = REQUIRED_FLAG;
			password_flag = OPTIONAL_FLAG;
			filename_flag = REQUIRED_FLAG;
			break;
	}

	if (address && *address)
	{
		if (address_flag == INVALID_FLAG)
		{
			sprintf(RIS_ERRMSGC,
				RIScom_umsg(RIS_E_SPECIFYING_ADDRESS_PROTOCOL) , prot);
			LONGJMP(RIS_E_INV_SCHFILE_SPEC);
		}

		if (strlen(address) >= RIS_MAX_NODE_SIZE)
		{
			sprintf(RIS_ERRMSGC,
				RIScom_umsg(RIS_E_ADDRESS_CAN_NOT_LONGER) ,
				RIS_MAX_NODE_SIZE - 1);
			LONGJMP(RIS_E_INV_SCHFILE_ADDRESS);
		}
	}
	else /* no address */
	{	
		if (address_flag == REQUIRED_FLAG)
		{
			sprintf(RIS_ERRMSGC,
				RIScom_umsg(RIS_E_PROTOCOL_REQUIRES_ADDRESS) , prot);
			LONGJMP(RIS_E_INV_SCHFILE_SPEC);
		}
	}

	if (username && *username)
	{
		if (username_flag == INVALID_FLAG)
		{
			sprintf(RIS_ERRMSGC,
				RIScom_umsg(RIS_E_SPECIFYING_ADDRESS_PROTOCOL) , prot);
			LONGJMP(RIS_E_INV_SCHFILE_SPEC);
		}
		if (strlen(username) >= RIS_MAX_ID_SIZE)
		{
			sprintf(RIS_ERRMSGC,
				RIScom_umsg(RIS_E_USERNAME_CAN_NOT_LONGER) ,
				RIS_MAX_ID_SIZE - 1);
			LONGJMP(RIS_E_INV_SCHFILE_USERNAME);
		}
	}
	else /* no username */
	{	
		if (username_flag == REQUIRED_FLAG)
		{
			sprintf(RIS_ERRMSGC,
				RIScom_umsg(RIS_E_PROTOCOL_REQUIRES_USERNAME), prot);
			LONGJMP(RIS_E_INV_SCHFILE_SPEC);
		}
	}

	if (password && *password)
	{
		if (password_flag == INVALID_FLAG)
		{
			sprintf(RIS_ERRMSGC,
				RIScom_umsg(RIS_E_SPECIFYING_PASSWORD_PROTOCOL) , prot);
			LONGJMP(RIS_E_INV_SCHFILE_SPEC);
		}
		if (strlen(password) != RIS_MAX_PASSWD_SIZE - 1)
		{
			LONGJMP(RIS_E_INV_SCHFILE_PASSWORD);
		}
	}
	else /* no password */
	{	
		if (password_flag == REQUIRED_FLAG)
		{
			sprintf(RIS_ERRMSGC,
				RIScom_umsg(RIS_E_PROTOCOL_REQUIRES_PASSWORD) , prot);
			LONGJMP(RIS_E_INV_SCHFILE_SPEC);
		}
	}

	if (filename && *filename)
	{
		if (filename_flag == INVALID_FLAG)
		{
			sprintf(RIS_ERRMSGC,
				RIScom_umsg(RIS_E_SPECIFYING_FILENAME_PROTOCOL) , prot);
			LONGJMP(RIS_E_INV_SCHFILE_SPEC);
		}
		if (strlen(filename) >= RIS_MAX_PATH_SIZE)
		{
			sprintf(RIS_ERRMSGC,
				RIScom_umsg(RIS_E_FILENAME_CAN_NOT_LONGER) ,
				RIS_MAX_ID_SIZE - 1);
			LONGJMP(RIS_E_INV_SCHFILE_PASSWORD);
		}
	}
	else /* no filename */
	{	
		if (filename_flag == REQUIRED_FLAG)
		{
			sprintf(RIS_ERRMSGC,
				RIScom_umsg(RIS_E_PROTOCOL_REQUIRES_FILENAME) , prot);
			LONGJMP(RIS_E_INV_SCHFILE_SPEC);
		}
	}
	APP_DBG(("RISapp_validate_schfile_spec: complete\n"));
}

/******************************************************************************/

extern void RISapp_update_schfile_spec(
	char	protocol,
	char	*address,
	char	*username,
	char	*password,
	char	*filename)
{
	APP_DBG(("RISapp_update_schfile_spec(protocol:%c address:<%s> username:<%s>"
		"filename:<%s>)\n", protocol, address, username, filename));

	if ( ISLOWER(protocol) )
	{
		RIS_schfile_parms.protocol = (char)RIScom_toupper(protocol);
	}
	else
	{
		RIS_schfile_parms.protocol = protocol;
	}

	if (address && *address)
	{
		RIScom_strcpy(RIS_schfile_parms.address, address);	
	}
	else
	{
		RIS_schfile_parms.address[0] = '\0';	
	}

	if (username && *username)
	{
		RIScom_strcpy(RIS_schfile_parms.username, username);	
	}
	else
	{
		RIS_schfile_parms.username[0] = '\0';	
	}

	if (password && *password)
	{
		RIScom_strcpy(RIS_schfile_parms.password, password);	
	}
	else
	{
		RIS_schfile_parms.password[0] = '\0';	
	}

	RIScom_strcpy(RIS_schfile_parms.filename, filename);	

	APP_DBG(("RISapp_update_schfile_spec: complete\n"));
}

/******************************************************************************/
