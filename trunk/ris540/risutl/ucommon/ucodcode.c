/* Do not alter this SPC information: $Revision: 1.1.53.1 $ */
/*
**	NAME:							ucodcode.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					1/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <stdio.h>
#include "ris.h"
#include "ucommon.h"
#include "risutl.h"
#include "utl_err.h"
#include "utl_inf.h"

/*
**	DEFINES
*/
#define RIS_BASE_NUMBER 660
#define UTL_BASE_NUMBER 462
#define NET_BASE_NUMBER 461

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define ucodcode_c
#include "comdebug.prt"
#include "comisfn.prt"
#include "ucodcode.prt"
#include "ucoerrbx.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern int RISuco_valid_code(
	char *s,
	int *pcode)
{
	unsigned int len;
	char *ptr;

	UCO_DBG(("RISuco_valid_code(s:<%s> pcode:0x%x)\n", STRING(s), pcode));

	/* skip any leading white space */
	while(*s && RIScom_isspace(*s))
	{
		s++;
	}

	if (!*s)
	{
		UCO_DBG(("RISuco_valid_code:returning 0\n"));
		return 0;
	}

	/* remove any trailing white space */
	len = strlen(s);
	while(len > 0 && RIScom_isspace(s[len - 1]))
	{
		len--;
		s[len] = '\0';
	}

	ptr = s;

	if (*ptr == '-')
	{
		ptr++;
		len--;
	}

	if (*ptr == '0')
	{
		ptr++;
		len--;
		/* octal or hexidecimal */

		if (*ptr == 'x' || *ptr == 'X')
		{
			ptr++;
			len--;
			/* hexidecimal */

			if (strspn(ptr, "0123456789abcdefABCDEF") != len)
			{
				UCO_DBG(("RISuco_valid_code:returning 0\n"));
				return 0;
			}
		}
		else
		{
			/* octal */
			if (strspn(ptr, "01234567") != len)
			{
				UCO_DBG(("RISuco_valid_code:returning 0\n"));
				return 0;
			}
		}
	}
	else
	{
		if (strspn(ptr, "0123456789") != len)
		{
			UCO_DBG(("RISuco_valid_code:returning 0\n"));
			return 0;
		}
	}

	if (sscanf(s, "%i", pcode) != 1)
	{
		UCO_DBG(("RISuco_valid_code:returning 0\n"));
		return 0;
	}

	UCO_DBG(("RISuco_valid_code:returning 1\n"));
	return 1;
}

/******************************************************************************/

extern int RISuco_decode(
	int error,
	int (*output_func)(const char *, ...))
{
	int name = 0;
	int type = 0;
	int message = 0;
	char buffer[4000];

	UCO_DBG(("RISuco_decode(error:%d)\n", error));
	if (error >= 0)
	{
		/*
		**	ris info
		*/
		type = RISUTL_I_RIS_INFO;
		switch(error)
		{
			case RIS_SUCCESS:
				name = RISUTL_I_RIS_SUCCESS_NAME;
				message = RISUTL_I_RIS_SUCCESS_MSG;
				break;
			case END_OF_DATA:
				name = RISUTL_I_END_OF_DATA_NAME;
				message = RISUTL_I_END_OF_DATA_MSG;
				break;
			case STATEMENT_NOT_COMPLETE:
				name = RISUTL_I_STMT_NOT_COMP_NAME;
				message = RISUTL_I_STMT_NOT_COMP_MSG;
				break;
			case STATEMENT_FAILED:
				name = RISUTL_I_STMT_FAILED_NAME;
				message = RISUTL_I_STMT_FAILED_MSG;
				break;
			default:
				UCO_DBG(("RISuco_decode:returning 0\n"));
				return 0;
		}
	}
	else
	{
		switch((error & 0x07ff0000) >> 16)
		{
			case RIS_BASE_NUMBER:
				/*
				**	ris error
				*/
				type = RISUTL_I_RIS_ERROR;
				name = 0;
				message = 0;
				break;

			case UTL_BASE_NUMBER:
				/*
				**	utl error
				*/
				type = RISUTL_I_UTL_ERROR;
				name = 0;
				message = 0;
				break;

			case NET_BASE_NUMBER:
				/*
				**	utl error
				*/
				type = RISUTL_I_NET_ERROR;
				name = 0;
				message = 0;
				break;

			default:
				UCO_DBG(("RISuco_decode:returning 0\n"));
				return 0;
		}
	}

	RISuco_char_error_box(buffer, type, name, error, NULL, message, 1);
	output_func("%s", buffer);

	UCO_DBG(("RISuco_decode:returning 1\n"));
	return 1;
}

/******************************************************************************/
