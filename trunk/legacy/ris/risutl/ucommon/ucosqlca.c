/* Do not alter this SPC information: $Revision: 1.1.53.1 $ */
/*
**	NAME:							ucosqlca.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					1/94
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "ris.h"
#include "ucommon.h"
#include "utl_err.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/
struct stack_s
{
	int				stack_sqlcode;
	rissqlca		stack_risca;
	rissqlca		stack_dbca;
	struct stack_s	*next;
};

/*
**	FUNCTION PROTOTYPES
*/
#define ucosqlca_c
#include "ucosqlca.prt"
#include "comdebug.prt"
#include "ris.prt"
#include "sys.prt"

/*
**	VARIABLES
*/
static struct stack_s	*stack = NULL;

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern int RISuco_push_risca_dbca()
{
	int				len;
	struct stack_s	*temp;

	UCO_DBG(("RISuco_push_risca_dbca()\n"));

	if ((temp = (struct stack_s *)malloc(sizeof(struct stack_s))) == NULL)
	{
		UCO_DBG(("RISuco_push_risca_dbca: returning RISUTL_E_MALLOC\n"));
		return RISUTL_E_MALLOC;
	}

	/*
	**	SQLCODE
	*/
	temp->stack_sqlcode = SQLCODE;

	/*
	**	risca
	*/
	memcpy(&temp->stack_risca, risca, sizeof(rissqlca));
	if (risca->sqlstmt)
	{
		len = strlen(risca->sqlstmt) + 1;
		if ((temp->stack_risca.sqlstmt = (char *)malloc(len)) == NULL)
		{
			UCO_DBG(("RISuco_push_risca_dbca:returning RISUTL_E_MALLOC\n"));
			return RISUTL_E_MALLOC;
		}
		memcpy(temp->stack_risca.sqlstmt, risca->sqlstmt, len);
	}

	/*
	**	dbca
	*/
	memcpy(&temp->stack_dbca, dbca, sizeof(rissqlca));
	if (dbca->sqlstmt)
	{
		len = strlen(dbca->sqlstmt) + 1;
		if ((temp->stack_dbca.sqlstmt = (char *)malloc(len)) == NULL)
		{
			UCO_DBG(("RISuco_push_risca_dbca:returning RISUTL_E_MALLOC\n"));
			return RISUTL_E_MALLOC;
		}
		memcpy(temp->stack_dbca.sqlstmt, dbca->sqlstmt, len);
	}

	temp->next = stack;
	stack = temp;

	UCO_DBG(("RISuco_push_risca_dbca:returning RIS_SUCCESS\n"));
	return RIS_SUCCESS;
}

/******************************************************************************/

extern int RISuco_pop_risca_dbca()
{
	struct stack_s	*temp;
	char *sqlstmt;

	UCO_DBG(("RISuco_pop_risca_dbca()\n"));

	if (!stack)
	{
		UCO_DBG(("RISuco_pop_risca_dbca:returning RISUTL_E_INTERNAL\n"));
		return RISUTL_E_INTERNAL;
	}
		
	temp = stack;
	stack = stack->next;

	/*
	**	SQLCODE
	*/
	RISint_set_sqlcode(temp->stack_sqlcode);

	/*
	**	risca
	*/
	sqlstmt = risca->sqlstmt;
	memcpy(risca, &temp->stack_risca, sizeof(rissqlca));
	risca->sqlstmt = sqlstmt;
	if (temp->stack_risca.sqlstmt)
	{
		if (risca->sqlstmt)
		{
			strcpy(risca->sqlstmt, temp->stack_risca.sqlstmt);
		}
		free(temp->stack_risca.sqlstmt);
	}

	/*
	**	dbca
	*/
	sqlstmt = dbca->sqlstmt;
	memcpy(dbca, &temp->stack_dbca, sizeof(rissqlca));
	dbca->sqlstmt = sqlstmt;
	if (temp->stack_dbca.sqlstmt)
	{
		if (dbca->sqlstmt)
		{
			strcpy(dbca->sqlstmt, temp->stack_dbca.sqlstmt);
		}
		free(temp->stack_dbca.sqlstmt);
	}

	free(temp);

	UCO_DBG(("RISuco_pop_risca_dbca:returning RIS_SUCCESS\n"));
	return RIS_SUCCESS;
}

/******************************************************************************/

extern void RISuco_empty_risca_dbca_stack()
{
	struct stack_s	*temp;

	UCO_DBG(("RISuco_empty_risca_dbca_stack()\n"));

	while(stack)
	{
		temp = stack;
		stack = stack->next;

		if (temp->stack_risca.sqlstmt)
		{
			free(temp->stack_risca.sqlstmt);
		}
		if (temp->stack_dbca.sqlstmt)
		{
			free(temp->stack_dbca.sqlstmt);
		}
		free(temp);
	}

	UCO_DBG(("RISuco_empty_risca_dbca_stack:returning\n"));
}

/******************************************************************************/
