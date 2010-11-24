/*
**	NAME:							comver.c
**	AUTHORS:						Sunil Murthy
**	CREATION DATE:					11/93
**	ABSTRACT:
**		
**	
**	REVISION HISTORY: Moved from riscli/clicom to riscom/common, because these
**  functions are used by the application too. -- SK
*/
#include <stdlib.h>
#include <string.h>

#include "risdebug.h"
#include "riscom.h"
#include "rismem.h"
#include "risstjmp.h"
#include "ris_err.h"

/******************************************************************************/

extern short RIScom_ver_str_to_number(char *val)
{
	char	*tmpval = val;
	short	ret_val = -2;

	COM_DBG(("RIScom_ver_str_to_number(val:<%s>)\n", STRING(val)));
	if (val)
	{
		while (*tmpval && RIScom_isdigit(*tmpval)) tmpval++;
		if (!*tmpval)
		{
			ret_val = (short) (atoi(val));
		}
	}	
	COM_DBG(("RIScom_ver_str_to_number: returning %d\n", ret_val));
	return (ret_val);
}

/******************************************************************************/

extern void RIScom_ver_number_to_str(short val, char *ret_val)
{

	COM_DBG(("RIScom_ver_number_to_str(val:<%d>)\n", val));

	if (val == 0)
	{
		strcpy(ret_val, "0");
	}
	else if (val >= 0)
	{
		sprintf(ret_val, "%d", val);
	}
	else
	{
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	COM_DBG(("RIScom_ver_number_to_str: returning <%s>\n", ret_val));
}
