/*
**	NAME:							ccosqlca.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					9/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "clicom.h"
#include "rismem.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/
struct stack_s
{
	rissqlca		risca;
	rissqlca		dbca;
	struct stack_s	*next;
};

/*
**	FUNCTION PROTOTYPES
*/
#define ccosqlca_c
#include "comalloc.prt"
#include "comjmp.prt"
#include "comsqlca.prt"
#include "comdebug.prt"
#include "ccosqlca.prt"
#include "sys.prt"

/*
**	VARIABLES
*/
static struct stack_s	*stack = NULL;

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RIScco_push_risca_dbca()
{
	int		len;
	struct stack_s	*temp;

	CCO_DBG(("RIScco_push_risca_dbca()\n"));

	temp = (struct stack_s *)SYS_MALLOC(sizeof(struct stack_s));

	if (temp)
	{
		if (risca->sqlstmt)
		{
			len = strlen(risca->sqlstmt) + 1;
			temp->risca.sqlstmt = (char *)SYS_MALLOC(len);
		}
		else
		{
			temp->risca.sqlstmt = (char *)0;
		}
		RIScom_copy_sqlca(&temp->risca, risca);

		if (dbca->sqlstmt)
		{
			len = strlen(dbca->sqlstmt) + 1;
			temp->dbca.sqlstmt = (char *)SYS_MALLOC(len);
		}
		else
		{
			temp->dbca.sqlstmt = (char *)0;
		}
		RIScom_copy_sqlca(&temp->dbca, dbca);

		temp->next = stack;
		stack = temp;
	}
	else
	{
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	CCO_DBG(("RIScco_push_risca_dbca:returning\n"));
}

/******************************************************************************/

extern void RIScco_pop_risca_dbca()
{
	struct stack_s	*temp;

	CCO_DBG(("RIScco_pop_risca_dbca()\n"));

	if (!stack)
	{
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}
		
	temp = stack;
	stack = stack->next;

	RIScom_copy_sqlca(risca, &temp->risca);
	if (temp->risca.sqlstmt)
	{
		SYS_FREE(temp->risca.sqlstmt);
	}

	RIScom_copy_sqlca(dbca, &temp->dbca);
	if (temp->dbca.sqlstmt)
	{
		SYS_FREE(temp->dbca.sqlstmt);
	}

	SYS_FREE((char *)temp);

	CCO_DBG(("RIScco_pop_risca_dbca:returning\n"));
}

/******************************************************************************/
