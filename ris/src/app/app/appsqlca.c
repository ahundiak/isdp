/* Do not alter this SPC information: $Revision: 1.1.59.1 $ */
/*
**	NAME:							appsqlca.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					9/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
**/

#include "rismem.h"
#include "risapp.h"
#include "riscom.h"
#include "risdebug.h"
#include "ris_err.h"

struct stack_s
{
	rissqlca		risca;
	rissqlca		dbca;
	struct stack_s	*next;
};

static  struct stack_s	*stack = NULL;

/******************************************************************************/

extern void RISapp_push_risca_dbca()
{
	int				len;
	struct stack_s	*temp;

	APP_DBG(("RISapp_push_risca_dbca()\n"));

	temp = (struct stack_s *)SYS_MALLOC(sizeof(struct stack_s));

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

	APP_DBG(("RISapp_push_risca_dbca:returning\n"));
}

/******************************************************************************/

extern void RISapp_pop_risca_dbca()
{
	struct stack_s	*temp;

	APP_DBG(("RISapp_pop_risca_dbca()\n"));

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

	APP_DBG(("RISapp_pop_risca_dbca:returning\n"));
}

/******************************************************************************/

extern void RISapp_empty_risca_dbca_stack()
{
	struct stack_s	*temp;

	APP_DBG(("RISapp_empty_risca_dbca_stack()\n"));

	while(stack)
	{
		temp = stack;
		stack = stack->next;

		if (temp->risca.sqlstmt)
		{
			SYS_FREE(temp->risca.sqlstmt);
		}
		if (temp->dbca.sqlstmt)
		{
			SYS_FREE(temp->dbca.sqlstmt);
		}
		SYS_FREE((char *)temp);
	}

	APP_DBG(("RISapp_empty_risca_dbca_stack:returning\n"));
}
