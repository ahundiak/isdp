/*
**	NAME:							dictrans.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					4/88
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "ristoken.h"
#include "dict.h"

/*
**	DEFINES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/*
**      FUNCTION PROTOTYPES
*/
#define dictrans_c
#include "comjmp.prt"
#include "comdebug.prt"
#include "dictrans.prt"
#include "dicmisc.prt"

/******************************************************************************/

extern void RISdic_commit_hash()
{
	hashnode	*hashp;

	DIC_DBG(("RISdic_commit_hash()\n"));

	DIC_DBG(("searching for hashwork structure for stmt_id = %d\n",
	 RIS_stmt->stmt_id));

	while (RISdic_hashwork[RIS_stmt->stmt_id])
	{
		DIC_DBG(("found hashwork structure = 0x%x action = %d\n",
		 RISdic_hashwork[RIS_stmt->stmt_id],
		 RISdic_hashwork[RIS_stmt->stmt_id]->action));

		if (RISdic_hashwork[RIS_stmt->stmt_id]->action == RIS_TOK_DELETE)
		{
			hashp = RISdic_hashwork[RIS_stmt->stmt_id]->hashp;

			DIC_DBG(("removing hashnode = 0x%x\n",hashp));

			hashp->next = NULL;
			RISdic_free_hash(hashp);
		}
		RISdic_hashwork[RIS_stmt->stmt_id] =
			RISdic_hashwork[RIS_stmt->stmt_id]->next;
	}
	DIC_DBG(("RISdic_commit_hash:returning\n"));
}

/******************************************************************************/

extern void RISdic_rollback_hash()
{
	int			hashval;
	hashnode	*hashp;

	DIC_DBG(("RISdic_rollback_hash\n"));

	DIC_DBG(("searching for hashwork structure for stmt_id = %d\n",
	 RIS_stmt->stmt_id));

	while (RISdic_hashwork[RIS_stmt->stmt_id])
	{
		DIC_DBG(("found hashwork structure = 0x%x action = %d\n",
		 RISdic_hashwork[RIS_stmt->stmt_id],
		 RISdic_hashwork[RIS_stmt->stmt_id]->action));

		if (RISdic_hashwork[RIS_stmt->stmt_id]->action == RIS_TOK_ADD)
		{
			hashp = RISdic_hashwork[RIS_stmt->stmt_id]->hashp;

			DIC_DBG(("removing hashnode = 0x%x\n",hashp));

			if (hashp->next) hashp->next->prev = hashp->prev;

			/* if at head, reset head ptr to the new head */
			if (*(hashnode**)hashp->prev == hashp)
			{
				*(hashnode**)hashp->prev = hashp->next;
			}
			else hashp->prev->next = hashp->next;
			hashp->next = NULL;
			RISdic_free_hash(hashp);
		}
		else if (RISdic_hashwork[RIS_stmt->stmt_id]->action == RIS_TOK_DELETE)
		{
			hashp = RISdic_hashwork[RIS_stmt->stmt_id]->hashp;

			DIC_DBG(("restoring hashnode = 0x%x\n",hashp));

			hashval = RISdic_hashwork[RIS_stmt->stmt_id]->hashval;

			if (RIS_hashtab[hashval])
			{
				hashp->next = RIS_hashtab[hashval];
				RIS_hashtab[hashval]->prev = hashp;
			}
			RIS_hashtab[hashval] = hashp;

			/* head->prev = &head */
			hashp->prev = (hashnode*)&RIS_hashtab[hashval];

			if (hashp->tok == RIS_TOK_TABLE)
			{
				RISdic_tab_hash_count++;
			}
		}
		RISdic_hashwork[RIS_stmt->stmt_id] =
			RISdic_hashwork[RIS_stmt->stmt_id]->next;
	}
	DIC_DBG(("RISdic_rollback_hash:returning\n"));
}

/******************************************************************************/

extern void RISdic_check_for_transact()
{
	DIC_DBG(("RISdic_check_for_transact()\n"));

	DIC_DBG(("searching for hashwork structure for stmt_id = %d\n",
	 RIS_stmt->stmt_id));

	if (RISdic_hashwork[RIS_stmt->stmt_id])
	{
		DIC_DBG(("found hashwork structure = 0x%x\n",
		 RISdic_hashwork[RIS_stmt->stmt_id]));

		LONGJMP(RIS_E_INTERNAL_ERROR);
	}
	DIC_DBG(("RISdic_check_for_transact:returning\n"));
}

/******************************************************************************/
