/*
**	NAME:							dicrem.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					3/88
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "riscom.h"
#include "rismem.h"
#include "ristoken.h"
#include "dict.h"

/*
**	DEFINES
*/
#define LEAVE_DATABASE	0
#define REMOVE_DATABASE	1
#define LEAVE_SCHEMAS	0
#define REMOVE_SCHEMAS	1

#define NO_TRANSACTION	0
#define TRANSACTION		1
/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/*
**      FUNCTION PROTOTYPES
*/
#define dicrem_c
#include "comalloc.prt"
#include "comgtnme.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "dicrem.prt"
#include "dicmisc.prt"

/******************************************************************************/

static void remove_hash(
	int		tok,
	void	*ptr,
	int		hashval,
	int		transaction_flag)
{
	hashnode	*hashp;
	hashnode	*save_hashp;
	hashwork	*work;

	DIC_DBG(("remove_hash(tok:%s ptr:0x%x hashval:%d transaction_flag:%s)\n",
		RIScom_get_token_name(tok), ptr, hashval,
		(transaction_flag == TRANSACTION)?"TRANSACTION":"NO_TRANSACTION"));

	for (hashp = RIS_hashtab[hashval]; hashp; hashp = hashp->next) 
	{
		if (hashp->tok == (unsigned short)tok && hashp->ptr == ptr)
		{
			/* save a pointer to the hashnode to be removed */
			save_hashp = hashp;

			if (hashp->next) hashp->next->prev = hashp->prev;

			/* if at head, reset head ptr to the new head */
			if (*(hashnode**)hashp->prev == hashp)
			{
				*(hashnode**)hashp->prev = hashp->next;
			}
			else hashp->prev->next = hashp->next;

			/* make sure save_hashp->next doesn't point anywhere */
			save_hashp->next = NULL;

			if (transaction_flag == TRANSACTION)
			{
				/*
				**	If we're in a transaction add save_hashp to the
				**	work list.
				*/
				work = ALLOCT(hashwork);
				work->hashp = save_hashp;
				work->next = RISdic_hashwork[RIS_stmt->stmt_id];
				work->hashval = hashval;
				work->action = RIS_TOK_DELETE;
				RISdic_hashwork[RIS_stmt->stmt_id] = work;
			}
			else
			{
				/*
				**	If we're not in a transaction free the node.
				*/
				RISdic_free_hash(save_hashp);
			}
			return;
		}
	}

	DIC_DBG(("remove_hash: couldn't find <%s>\n", RISdic_get_name(tok, ptr)));

	/*
	**	Longjmp only if we're in a transaction and the object is not found.
	*/
	if (transaction_flag == TRANSACTION)
	{
		switch(tok)
		{
			case RIS_TOK_TABLE:
				LONGJMP(RIS_E_UNKNOWN_RELATION);
	
			case RIS_TOK_ATTR:
				LONGJMP(RIS_E_UNKNOWN_COLUMN);
	
			case RIS_TOK_DATABASE:
				LONGJMP(RIS_E_UNKNOWN_DATABASE);
	
			case RIS_TOK_SCHEMA:
				LONGJMP(RIS_E_UNKNOWN_SCHEMA);
			
			case RIS_TOK_DECLARE_SCHEMA:
				LONGJMP(RIS_E_UNKNOWN_DECLARE_SCHEMA);
		}
	}
	DIC_DBG(("remove_hash: returning\n"));
}

/******************************************************************************/

static void remove_table(
	ristab	*tab,
	int		transaction_flag)
{
	int		hashval;
	char	*name;
	unsigned int i;
	ristablist *tmp_tablist;

	DIC_DBG(("remove_table(tab:0x%x transaction_flag:%s)\n", tab, 
		(transaction_flag==TRANSACTION)?"TRANSACTION":"NO_TRANSACTION"));

	/*
	** The foll. change was made on 12/22/93 based on Terry's and Sunil's
	** investigation that revealed the scenario where:
	**
	** 1) a dynamic statement S1 is prepared that adds a table T1 to hash,
	** 2) The schema is closed, thereby removing T1 from hash but leaving
	**    S1's tablist->tab pointing to T1 in hash.
	** 3) The schema is opened and the same dynamic statement S1 is prepared.
	**    The client detects that S1 needs to be reprepared and it clears
	**    the previous S1. This 'clear' decrements T1's ref_count (in the
	**    hash). Since the table has already been removed from the hash,
	**    the decrement operation accesses an invalid memory element.
	**
	** The solution therefore is to go thro' all the statements and null out
	** the ristablist(s) of any statements referencing this table in hash
	** before removing the table from hash.
	*/
	if (tab->ref_count > 0)
	{
		for (i=0;i < RIS_max_stmts;i++)
		{
			if (RIS_stmts[i] && RIS_stmts[i]->tablist)
			{
				tmp_tablist = RIS_stmts[i]->tablist;
				while (tmp_tablist)
				{
					if (tmp_tablist->tab && tmp_tablist->tab == tab)
					{
						RIS_stmts[i]->tablist = NULL;
						break;
					}
					tmp_tablist = tmp_tablist->next;
				}
			}
		}
	}
	/*** end of change */

	name = RISdic_get_name(RIS_TOK_TABLE, tab);
	hashval = RISdic_hash_on_name(name);
	remove_hash(RIS_TOK_TABLE, tab, hashval, transaction_flag);

	RISdic_tab_hash_count--;
}

/******************************************************************************/

static void remove_schema(
	risschema	*schema,
	int			remove_db_flag,
	int			transaction_flag)
{
	hashnode	*hashp;
	hashnode	*next_hashp;
	int			i;
	int			schema_count = 0;
	int			hashval;

	DIC_DBG(("remove_schema(schema:0x%x remove_db_flag:%d transaction_flag:%s)"
		"\nremove_schema:schname:<%s>\n", schema, remove_db_flag, 
		(transaction_flag==TRANSACTION)?"TRANSACTION":"NO_TRANSACTION",
		schema->schname));

	/*
	**	Remove the tables and view associated with the schema
	*/
	for (i=0; i < HASH_TAB_SIZE; ++i)
	{
		for (hashp = RIS_hashtab[i]; hashp; hashp = next_hashp)
		{
			next_hashp = hashp->next;

			switch (hashp->tok)
			{
				case RIS_TOK_TABLE:
					if (((ristab *)hashp->ptr)->schema == schema)
					{
						remove_table((ristab *)hashp->ptr, transaction_flag);
					}
					break;

				case RIS_TOK_SCHEMA:
					if (((risschema *)hashp->ptr)->db == schema->db)
					{
						schema_count++;
					}
					break;

				default:
					break;
			}
		}
	}

	/*
	**	remove the database if necessary
	*/
	if (remove_db_flag && schema_count == 1 &&
		schema->superschema_flag!=3)
	{
		DIC_DBG(("remove_schema: <%s> is the only schema on db <%s>, "
			"so removing db also.\n", schema->schname,
			schema->db->dbname));

		remove_db(schema->db, LEAVE_SCHEMAS, transaction_flag);
	}

	/*
	** remove the schema
	*/
	hashval = RISdic_hash_on_name(schema->schname);
	remove_hash(RIS_TOK_SCHEMA, schema, hashval, transaction_flag);

	DIC_DBG(("remove_schema: returning\n"));
}

/******************************************************************************/

static void remove_dschema(
	risdclrschema	*dschema,
	int			transaction_flag)
{
	int			hashval;

	DIC_DBG(("remove_dschema(dschema:0x%x transaction_flag:%s)"
		"\nremove_dschema:schname:<%s>\n", dschema, 
		(transaction_flag==TRANSACTION)?"TRANSACTION":"NO_TRANSACTION",
		dschema->schname));
	/*
	** remove the schema
	*/
	hashval = RISdic_hash_on_name(dschema->schname);
	remove_hash(RIS_TOK_DECLARE_SCHEMA, dschema, hashval, transaction_flag);

	DIC_DBG(("remove_dschema: returning\n"));
}

/******************************************************************************/

static void remove_db(
	risdb	*db,
	int		remove_schemas_flag,
	int		transaction_flag)
{
	int i;
	int hashval;
	hashnode *hashp;
	hashnode *next_hashp;

	DIC_DBG(("remove_db(db:0x%x remove_schemas_flag:%d transaction_flag:%s)\n",
		db, remove_schemas_flag,
		(transaction_flag==TRANSACTION)?"TRANSACTION":"NO_TRANSACTION"));

	if (remove_schemas_flag)
	{
		/*
		**	Remove all the schemas associated with the database
		*/
		for (i=0; i < HASH_TAB_SIZE; ++i)
		{
			for (hashp = RIS_hashtab[i]; hashp; hashp = next_hashp) 
			{
				next_hashp = hashp->next;

				if (hashp->tok == RIS_TOK_SCHEMA &&
					((risschema *)hashp->ptr)->db == db)
				{
					remove_schema((risschema *)hashp->ptr, LEAVE_DATABASE,
						transaction_flag);
				}
			}
		}
	}
	/*
	**	Remove the database
	*/
	hashval = RISdic_hash_on_id(db->dbid);
	remove_hash(RIS_TOK_DATABASE, db, hashval, transaction_flag);

	DIC_DBG(("remove_db:returning\n"));
}
	
/******************************************************************************/

extern void RISdic_remove_hash(
	int		tok,
	void	*ptr)
{
	DIC_DBG(("RISdic_remove_hash(tok:<%s> ptr:0x%x)\n",
		RIScom_get_token_name(tok), ptr));

	switch(tok)
	{
		case RIS_TOK_TABLE:
			remove_table((ristab *)ptr, TRANSACTION);
			break;

		case RIS_TOK_DATABASE:
			remove_db((risdb *)ptr, REMOVE_SCHEMAS, TRANSACTION);
			break;

		case RIS_TOK_SCHEMA:
			remove_schema((risschema *)ptr, REMOVE_DATABASE, TRANSACTION);
			break;

		case RIS_TOK_DECLARE_SCHEMA:
			remove_dschema((risdclrschema *)ptr, TRANSACTION);
			break;

		default:
			LONGJMP(RIS_E_INTERNAL_ERROR);
	}
	DIC_DBG(("RISdic_remove_hash: returning\n"));
}

/******************************************************************************/

extern void RISdic_remove_schema_no_transaction(
	risschema	*schema)
{
	DIC_DBG(("RISdic_remove_schema_no_transaction(schema:0x%x)\n", schema));

	if (schema)
	{
		remove_schema(schema, REMOVE_DATABASE, NO_TRANSACTION);
	}

	DIC_DBG(("RISdic_schema_no_transaction: returning\n"));
}

/******************************************************************************/
