/*
**	NAME:							ccover.c
**	AUTHORS:						Sunil Murthy
**	CREATION DATE:					11/93
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
*/

/*
**	DEFINES
*/

/*
**	INCLUDES
*/
#include "clicom.h"
#include "riscom.h"
#include "rismem.h"

/*
**      FUNCTION PROTOTYPES
*/
#define ccover_c
#include "ccover.prt"
#include "comalloc.prt"
#include "comdebug.prt"
#include "comisfn.prt"
#include "comjmp.prt"
#include "sys.prt"

/******************************************************************************/

extern short RIScco_ver_str_to_number(
	char *val)
{
	char	*tmpval = val;
	short	ret_val = -2;

	CCO_DBG(("RIScco_ver_str_to_number(val:<%s>)\n", STRING(val)));
	if (val)
	{
		while (*tmpval && RIScom_isdigit(*tmpval)) tmpval++;
		if (!*tmpval)
		{
			ret_val = (atoi(val));
		}
	}	
	CCO_DBG(("RIScco_ver_str_to_number: returning %d\n", ret_val));
	return (ret_val);
}

/******************************************************************************/

extern char *RIScco_ver_number_to_str(
	short val)
{
	char	*ret_val = 0;

	CCO_DBG(("RIScco_ver_number_to_str(val:<%d>)\n", val));

	if (val == -1)
	{
		ret_val = ALLOCB(3);
		strcpy(ret_val, "0");
	}
	else if (val >= 0)
	{
		ret_val = ALLOCB(4);
		sprintf(ret_val, "%d", val);
	}
	else
	{
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	CCO_DBG(("RIScco_ver_number_to_str: returning <%s>\n", ret_val));
	return (ret_val);
}
