/* Do not alter this SPC information: $Revision: 1.1.53.1 $ */
/*
**	NAME:							ucostrng.c
**	AUTHORS:						Terrence D. McIntyre
**	CREATION DATE:					2/94
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define ucostrng_c
#include "comisfn.prt"
#include "ucostrng.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISuco_tolower_string(
	char *str)
{
	if (str)
	{
		while (*str)
		{
			if (RIScom_isupper(*str))
			{
				*str = RIScom_tolower(*str);
			}
			str++;
		}
	}
}

/******************************************************************************/

extern void RISuco_toupper_string(
	char *str)
{
	if (str)
	{
		while (*str)
		{
			if (RIScom_islower(*str))
			{
				*str = RIScom_toupper(*str);
			}
			str++;
		}
	}
}

/******************************************************************************/

extern void RISuco_remove_trailing_space(
	char *str)
{
	int len;

	if (str)
	{
		len = strlen(str);	

		while(len && RIScom_isspace(str[len-1]))
		{
			len--;
		}
		str[len] = '\0';
	}
}

/******************************************************************************/
