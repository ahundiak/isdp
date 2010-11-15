/*
**	NAME:							dicadd.c
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
#include "limits.h"
#include "riscom.h"
#include "rismem.h"
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
#define dicadd_c
#include "ccostmgr.prt"
#include "comalloc.prt"
#include "comdebug.prt"
#include "comgtnme.prt"
#include "comjmp.prt"
#include "dicadd.prt"
#include "dicrem.prt"
#include "dicmisc.prt"



/******************************************************************************/

static void add_hash(
	int		tok,
	void	*ptr,
	int		hashval)
{
	hashnode	*hashp;
	hashnode	*hashptr;
	hashwork	*work;
	
	ristab *lru_tab = 0;
	int 	i, lru_index;
	unsigned int		now_time = 0;
	unsigned int		temp_time;
	unsigned int		lru_time;

/* Added 10/29 - Sunil */
	DIC_DBG(("add_hash:RISdic_tab_hash_count:%d RIS_parms.max_tab_in_mem:%d\n",
		RISdic_tab_hash_count, RIS_parms.max_tab_in_mem));
	if (tok == RIS_TOK_TABLE) 
	{
		now_time = get_now_time();
		if (RISdic_tab_hash_count > RIS_parms.max_tab_in_mem -1)
		{
			lru_time = now_time;
			for (i=0;i<HASH_TAB_SIZE;i++)
			{
				hashptr = RIS_hashtab[i];
				while (hashptr)
				{
					if (hashptr->tok == RIS_TOK_TABLE)
					{
						temp_time = hashptr->hash_time;
						if ((temp_time < lru_time) &&
							(!((ristab *)hashptr->ptr)->ref_count))
						{
							lru_tab = (ristab *)hashptr->ptr;
							lru_time = temp_time;
							lru_index= i;
DIC_DBG(("add_hash lru_tab: 0x%x lru_index:%d\n",lru_tab, lru_index));
						}
					}
					hashptr = hashptr->next;
				}
			}
			if (lru_tab) 
			{
				RISdic_remove_hash(RIS_TOK_TABLE, lru_tab);
			}
			else
			{
				LONGJMP(RIS_E_HASH_MAXTAB_EXCEEDED);
			}
		}
	}
/* ********				*/

/* Added 10/29 - Sunil 	*/
	hashp = RIScco_alloc_hashnode();
	hashp->tok = (unsigned short)tok;
	hashp->ptr = ptr;

	if (tok == RIS_TOK_TABLE)
	{
		hashp->hash_time = now_time;
		RISdic_tab_hash_count++;
	}
/* ********				*/

	if (RIS_hashtab[hashval])
	{
		hashp->next = RIS_hashtab[hashval];
		RIS_hashtab[hashval]->prev = hashp;
	}
	RIS_hashtab[hashval] = hashp;

	/* head->prev = &head */
	hashp->prev = (hashnode*)&RIS_hashtab[hashval];

	work = ALLOCT(hashwork);
	work->hashp = hashp;
	work->action = RIS_TOK_ADD;
	work->hashval = hashval;
	work->next = RISdic_hashwork[RIS_stmt->stmt_id];
	RISdic_hashwork[RIS_stmt->stmt_id] = work;
}
/****************************************************************/

/* Added 11/4 - Sunil 		*/
static int get_now_time()
{
	unsigned int t = 0;
	int i;
	hashnode *hashp;

	DIC_DBG(("get_now_time()\n"));

	for (i=0;i<HASH_TAB_SIZE;i++)
	{
		hashp = RIS_hashtab[i];
		while (hashp)
		{
			if (hashp->tok == RIS_TOK_TABLE)
			{
				DIC_DBG(("get_now_time:hashp->time:%d t:%d, tab:%s sch:%s\n",
					hashp->hash_time,t, ((ristab *)hashp->ptr)->tabname,
					((ristab *)hashp->ptr)->schema->schname));
				if (hashp->hash_time > t)
				{
					t = hashp->hash_time;
				}
			}
			hashp = hashp->next;
		}
	}
	if (t == UINT_MAX - 1) 
	{
		DIC_DBG(("get_now_time() t == %d\n", UINT_MAX -1));
    	for (i=0; i < HASH_TAB_SIZE; i++)
		{
			hashp = RIS_hashtab[i];
			while (hashp)
			{
				if (hashp->tok == RIS_TOK_TABLE)
				{
					hashp->hash_time = hashp->hash_time -
									(UINT_MAX - 1 - RIS_parms.max_tab_in_mem);	
					DIC_DBG(("get_now_time:hashp:0x%x hashp->time:%d\n",
						hashp, hashp->hash_time));
				}
				hashp = hashp->next;
			}
		}
		t = t - (UINT_MAX - 1 - RIS_parms.max_tab_in_mem);
	}
	DIC_DBG(("get_now_time() returning %d\n", t+1));
	return (t+1);
}

/******************************************************************************/

extern void RISdic_add_hash(
	int		tok,
	void	*ptr)
{
	unsigned int hashval;
	char		*name;

	DIC_DBG(("RISdic_add_hash(tok:%s ptr:0x%x\n", RIScom_get_token_name(tok)));

	name = RISdic_get_name(tok, ptr);

	DIC_DBG(("RISdic_add_hash: name:<%s>\n", name));

	switch(tok)
	{
		case RIS_TOK_TABLE:
			/* add relation to hash table using hashvalue */
			hashval = RISdic_hash_on_name(name);
			add_hash(tok, ptr, hashval);
			break;

		case RIS_TOK_DATABASE:
			/* add db to hash table using hashvalue */
			hashval = RISdic_hash_on_id(((risdb *)ptr)->dbid);
			add_hash(tok, ptr, hashval);
			break;

		case RIS_TOK_SCHEMA:
			/* add schema to hash table using hashvalue */
			hashval = RISdic_hash_on_name(name);
			add_hash(tok, ptr, hashval);
			break;

		default:
			LONGJMP(RIS_E_INTERNAL_ERROR);
	}
}

/******************************************************************************/
