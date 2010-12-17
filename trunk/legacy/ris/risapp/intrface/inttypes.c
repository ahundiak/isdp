/* Do not alter this SPC information: $Revision: 1.1.57.1 $ */
/*
**	NAME:							inttypes.c
**	AUTHORS:						Hitesh R. Patel
**	CREATION DATE:					5/93
**	ABSTRACT:
**				Retrieves RIS sql type code and/or string
**	
**	REVISION HISTORY: Changed the loop value for the search from 
**					   for( i = 1; i < RIS_MAX_TYPES; i++ ) to
**				       for( i = 0; i < RIS_MAX_TYPES; i++ )	
**									TR 249402994 fix - Radha 06/10/94
**
*/
 
/*
**	INCLUDES
*/
#include "ristypes.h"
#include "intrface.h"
#include "ris_inf.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define inttypes_c
#include "comdebug.prt"
#include "inttypes.prt"
#include "interror.prt" /* This file is needed for NT */
#include "intrap.prt"
#include "sys.prt"

/*
**	FUNCTIONS
*/

/******************************************************************************/

/*
** This function returns ris sqltype code for a give ris sqltype string
*/
extern void RISAPI RISXget_ris_sqltype_code(
	int *code,
	char *str)
{
	int i;

	INT_DBG(("RISget_ris_sqltype_code(code:0x%x str:<%s>)\n", code, str));

	RIS_ENTER();

	RISrap_enter_BEGIN();
		fprintf(RIS_RAP, "GET RIS TYPE CODE\n");
		fprintf(RIS_RAP, "code:0x%x\n", code);
		fprintf(RIS_RAP, "str:0x%x\n", str);
		if( str )
		{
			fprintf(RIS_RAP, "*str:%s\n", str);
		}
	RISrap_enter_END();

	RIS_CLEAR_ERROR();

	if( !code || !str )
	{
		SET_RISCA(RIS_E_INV_ARG);
		RISrap_return();
		RIS_RETURN();
	}

	/*
	**	No need to initialize RIS as RIS_types is a static structure and
	**	we are not making ums calls
	*/
	for( i = 0; i < RIS_MAX_TYPES; i++ )
	{
		if(!strcmp(str,RIS_types[i].string))
		{
			if( code ) 
			{
				*code = i;
			}
			SET_RISCA(RIS_SUCCESS);
			RISrap_return();
			RIS_RETURN();
		}
	}
	INT_DBG(("RISget_ris_sqltype_code:complete\n"));
	SET_RISCA(RIS_E_INV_DATA_TYPE);
	RISrap_return();
	RIS_RETURN();
}

/******************************************************************************/

/*
** This function returns ris sqltype string for a give ris sqltype code
*/
extern void RISAPI RISXget_ris_sqltype_string(
	char *str,
	int	 code)
{
	INT_DBG(("RISget_ris_sqltype_string(*str:0x%x code:%d)\n", *str, code));

	RIS_ENTER();

	RISrap_enter_BEGIN();
		fprintf(RIS_RAP, "GET RIS TYPE STRING\n");
		fprintf(RIS_RAP, "str:0x%x\n", str);
		fprintf(RIS_RAP, "code:%d\n", code);
	RISrap_enter_END();

	RIS_CLEAR_ERROR();

	if( !str )
	{
		SET_RISCA(RIS_E_INV_ARG);
		RISrap_return();
		RIS_RETURN();
	}

	/*
	**	No need to initialize RIS as RIS_types is a static structure  and
	**	we are not making ums calls
	*/
	if( code >= RIS_MAX_TYPES )
	{
		SET_RISCA(RIS_E_INV_DATA_TYPE);
		RISrap_return();
		RIS_RETURN();
	}
	strcpy(str, RIS_types[code].string);

	INT_DBG(("RISget_ris_sqltype_string:complete\n"));
	SET_RISCA(RIS_SUCCESS);
	RISrap_return();
	RIS_RETURN();
}

/******************************************************************************/
