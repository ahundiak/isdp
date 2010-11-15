/* Do not alter this SPC information: $Revision: 1.1.57.1 $ */
/*
**	NAME:							intgtlng.c
**	AUTHORS:						Hitesh R. Patel
**	CREATION DATE:					5/93
**	ABSTRACT:
**		Functions to access language information	
**	
**	REVISION HISTORY:
**
*/
 
/*
**	INCLUDES
*/
#include "riscom.h"
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
#define intgtlng_c
#include "comdebug.prt"
#include "comjmp.prt"
#include "comlang.prt"
#include "intgtlng.prt"
#include "interror.prt" 
#include "intrap.prt"
#include "sys.prt"

/*
**	FUNCTIONS
*/

/******************************************************************************/

/*
** Get current language code set by RIS
*/
extern void RISAPI RISXint_get_language_code(
	int *code)
{
	INT_DBG(("RISint_get_language_code(code:0x%x)\n", code));

	RIS_ENTER();

	if( !code )
	{
		SET_RISCA(RIS_E_INV_ARG);
		RIS_RETURN();
	}

	*code = RIS_language_code;

	INT_DBG(("RISint_get_language_code:complete\n"));

	SET_RISCA(RIS_SUCCESS);
	RIS_RETURN();
}

/******************************************************************************/

/*
** Get current language name set by RIS
*/
extern void RISAPI RISXget_language_name(
	char *name)
{
	int 	status;
	char 	*langname;

	INT_DBG(("RISget_language_name(name:0x%x)\n", name));

	RIS_ENTER();

	RISrap_enter_BEGIN();
		fprintf(RIS_RAP, "GET LANGUAGE NAME\n");
		fprintf(RIS_RAP, "name:0x%x\n", name);
	RISrap_enter_END();

	RIS_CLEAR_ERROR();

	if( (status = SETJMP()) != 0 )
	{
		RESETJMP();
		SET_RISCA(status);
		RISrap_return();
		RIS_RETURN();
	}

    /*
    ** CLIENT DIED not required
    */

	if( !name )
	{
		LONGJMP(RIS_E_INV_ARG);
	}
	if (!RIS_mem)
    {
        LONGJMP(RIS_E_NOT_INITIALIZED);
    }

	langname = RIScom_ris_lang_name(RIS_language_code);
	if( langname )
	{
		strcpy(name,langname);
	}
	else
	{
		name[0] = '\0';
	}

	RESETJMP();

	INT_DBG(("RISget_language_name:complete\n"));

	SET_RISCA(RIS_SUCCESS);
	RISrap_return();
	RIS_RETURN();
}

/******************************************************************************/
