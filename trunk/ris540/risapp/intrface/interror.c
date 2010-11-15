/* Do not alter this SPC information: $Revision: 1.1.57.1 $ */
/*
**	NAME:							interror.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					9/91
**	ABSTRACT:
**	
**	REVISION HISTORY:  Fixed the problem of repeated error strings. 
**                           - 4/94 Radha
**		
**		
*/
 
/*
**	INCLUDES
*/
#include <stdio.h>
#include <string.h>
#include <limits.h>
#include "riscom.h"
#include "risums.h"
#include "ris_inf.h"
#include "intrface.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define interror_c
#include "comdebug.prt"
#include "comjmp.prt"
#include "comumsg.prt"
#include "interror.prt"
#include "sys.prt"

/*
**	VARIABLES
*/
static  char	dyn_msg[512];

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern int RISAPI RISXint_error_msg(
	int	errcode,
	char *buf,
	char *errname)
{
	INT_DBG(("RISint_error_msg(errcode:%d buf:0x%x:<%s> errname:0x%x)\n",
	 errcode, buf, buf, errname));

	if (SETJMP())
	{
		INT_DBG(("RISint_error_msg: got JMP while setting error msg\n"));
		RESETJMP();
		return 0;
	}
	if (errname)
	{
		errname[0] = '\0';
	}
	switch(errcode)
	{
		case END_OF_DATA:
			INT_DBG(("RISint_error_msg: END OF DATA.\n"));
			strcpy(buf, RIScom_umsg(RIS_I_END_OF_DATA));
			dyn_msg[0] = '\0';
		break;
		case STATEMENT_NOT_COMPLETE:
			INT_DBG(("RISint_error_msg: STATEMENT NOT COMPLETE.\n"));
			strcpy(buf, RIScom_umsg(RIS_I_ASYNC_STATEMENT_NOT_COMPLETE));
			dyn_msg[0] = '\0';
		break;
		case STATEMENT_FAILED:
			INT_DBG(("RISint_error_msg: STATEMENT FAILED.\n"));
			strcpy(buf, RIScom_umsg(RIS_I_ASYNCHRONOUS_STATEMENT_FAILED));
			dyn_msg[0] = '\0';
		break;
		default:
			/*
			**	save dynamic message passed in thru buf;
			*/
			strcpy(dyn_msg, buf);

			/*
			**  get the error messages for this error
			*/
			strcpy(buf, RIScom_umsg(errcode));
			if (errname)
			{
				strcpy(errname, RIScom_error_code(errcode));
			}
		break;
	}

	if (*dyn_msg)
	{
 		/* append the input string only if it is different -Radha 4/94 */
		if (strcmp(dyn_msg,buf))
		{
			strcat(buf, " ");
			strcat(buf, dyn_msg);
		}

	}

	RESETJMP();
	INT_DBG(("RISint_error_msg: buf:<%s>\nRISint_error_msg:complete\n", buf));
	return strlen(buf);
}

/******************************************************************************/

extern void RISAPI RISXint_term_error_msg()
{
	INT_DBG(("RISint_term_error_msg()\n"));

	RIScom_clear_ums_msg(RIS_UMS_FILE);
	RIScom_clear_ums_msg(NET_UMS_FILE);

	INT_DBG(("RISint_term_error_msg:complete\n"));
}

/******************************************************************************/

extern void RISAPI RISXint_set_error(
	int	status)
{
	INT_DBG(("RISint_set_error()\n"));

	/*
	**	For use risdecode and the interactive utility
	*/
	RIS_CLEAR_ERROR();

	SQLCODE = status;
	RIS_ERRCODE = status;
    RIS_ERRMSGL = 
		(short)RISXint_error_msg(RIS_ERRCODE, RIS_ERRMSGC, RIS_error_name);

	INT_DBG(("RISint_set_error:returning\n"));
}

/******************************************************************************/

extern void RISAPI RISXint_clear_error()
{
	INT_DBG(("RISint_clear_error()\n"));

	RIS_CLEAR_ERROR();

	INT_DBG(("RISint_clear_error:returning\n"));
}

/******************************************************************************/
