/* Do not alter this SPC information: $Revision: 1.1.55.1 $ */
/*
**	NAME:							comfree.c
**	AUTHORS:						Dave Michal
**	CREATION DATE:					02/86
**	ABSTRACT:
**		contains the functions that do the memory management
**	
**	REVISION HISTORY:
**      Modified by Hitesh R. Patel on 8/92
**
*/
 
#define NO_COM_DBG

/*
**	INCLUDES
*/
#include "ris_err.h"
#include "risdebug.h"
#include "rismem.h"
#include "risstjmp.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define comfree_c
#include "comfree.prt"
#include "comjmp.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/
/******************************************************************************/

extern void RIScom_free(
	int		id,
	int		mark,
	char	type)
{
	int				maxid = 0;
	ris_alloc_info	*mem = 0;
	ris_block_info	*tempblock;
	ris_block_info	*freeblock;
	ris_block_info	*nextblock;
	ris_block_info	*prevblock;

	COM_DBG(("RIScom_free(id:%d mark:%d type:%d)\n",id,mark,type));

	switch(type)
	{
		case STATEMENT_MEMORY:
			COM_DBG(("RIScom_free: freeing STATEMENT_MEMORY\n"));
			maxid =	RIS_MAX_STMTS - 1;
		break;

		case SCHEMA_MEMORY:
			COM_DBG(("RIScom_free: freeing SCHEMA_MEMORY\n"));
			maxid =	RIS_MAX_OPEN_SCHEMAS - 1;
		break;

		case PERMANENT_MEMORY:
			COM_DBG(("RIScom_free: freeing PERMANENT_MEMORY\n"));
			maxid = 0;
		break;

		case ASYNC_MEMORY:
			COM_DBG(("RIScom_free: freeing ASYNC_MEMORY\n"));
			maxid = RIS_MAX_TRANSACTIONS - 1;
		break;

		case SUPERSCHEMA_MEMORY:
			COM_DBG(("RIScom_free: freeing SUPERSCHEMA_MEMORY\n"));
			maxid =	RIS_MAX_OPEN_SUPERSCHEMAS - 1;
		break;

		default:
			COM_DBG(("RIScom_free: invalid type:%d\n", type));
			LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	/*
	** check that stmt id is >= 0 and <= maxid
	*/
	if (id < 0)
	{
		LONGJMP(RIS_E_STMT_ID_TOO_SMALL);
	}

	if (id > maxid)
	{
		COM_DBG(("RIScom_realloc: id:%d > maxid:%d\n", id, maxid));
		LONGJMP(RIS_E_STMT_ID_TOO_BIG);
	}

	/*
	**	Validate mark
	*/
	if (mark != ALL_MARKS && (mark < 0 || mark >= RIS_MAX_ALLOC_MARK - 1))
	{
		COM_DBG(("free: invalid mark(%d) for free\n", mark));
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	/*
	**	Set up mem pointer
	*/
	switch(type)
	{
		case STATEMENT_MEMORY:
			mem = &RIS_mem->statement[id];
		break;

		case SCHEMA_MEMORY:
			mem = &RIS_mem->schema[id];
		break;

		case SUPERSCHEMA_MEMORY:
			mem = &RIS_mem->sschema[id];
		break;

		case ASYNC_MEMORY:
			mem = &RIS_mem->async[id];
		break;

		case PERMANENT_MEMORY:
			mem = &RIS_mem->permanent;
		break;
	}

	/*
	**	check if there is anything to free
	*/
	if (mem->blk)
	{
		freeblock=RIS_mem->free;
		for (tempblock=mem->blk,prevblock=0;tempblock;tempblock=nextblock)
		{

COM_DBG(("examining block = 0x%x\n",tempblock));

			nextblock = tempblock->next;

/* check if block should be freed */

			if (mark != ALL_MARKS && tempblock->mark != (char)mark)
			{

COM_DBG(("This block is NOT being freed\n"));

				prevblock = tempblock;
				continue;
			}

/* remove this block from the statement block list */

COM_DBG(("This block is being freed\n"));

			if (prevblock)
			{
				prevblock->next = nextblock;
			}
			else
			{
				mem->blk = nextblock;
			}

			/* check if this is the current allocation block */

			if (!nextblock)
			{
				COM_DBG(("reseting pos, avail, and end for this stmt id\n"));

				if (mark == ALL_MARKS || mark == DEFAULT_MARK)
				{
					mem->avail = 0;
					mem->pos = 0;
				}
				mem->end = prevblock;
			}

/* check if free list is empty */

			if (!freeblock)
			{
				tempblock->next = 0;
				RIS_mem->free = tempblock;
			}

/* check if block on free list is greater than this block */

			else if (freeblock > tempblock)
			{

/* check if free list block is first free list block*/

				if (freeblock == RIS_mem->free)
				{
					tempblock->next = freeblock;
					RIS_mem->free = tempblock;
				}
				else
				{

/* find the position in the free list where this block belongs by starting
   at the beginning of the free list */

					for (freeblock=RIS_mem->free;freeblock->next &&
				 	 freeblock->next < tempblock;freeblock=freeblock->next);
				 	tempblock->next = freeblock->next;
				 	freeblock->next = tempblock;
				}
			}

/* find the position in the free list where this block belongs */

			else
			{
				for (;freeblock->next && freeblock->next < tempblock;
				 freeblock=freeblock->next);
				 tempblock->next = freeblock->next;
				 freeblock->next = tempblock;
			}
			split_ris_block(tempblock);
			freeblock = tempblock;
		}
	}
	COM_DBG(("RIScom_free:complete\n"));
}

/******************************************************************************/

static void split_ris_block(
	ris_block_info * block)
{
	unsigned short i;
	ris_block_info * tempblock;
	ris_block_info * prevblock;

COM_DBG(("in split_ris_block block = 0x%x count = %d\n",block,block->count));

	for(i=1,prevblock=0;i <= block->count;i++)
	{
		tempblock = (ris_block_info *)((char *)block + i * (RIS_BLOCK_SIZE +
		 sizeof(ris_block_info)));

COM_DBG(("separating off block = 0x%x\n",tempblock));

		if (prevblock)
		{
			tempblock->next = prevblock->next;
			prevblock->next = tempblock;
		}
		else
		{
			tempblock->next = block->next;
			block->next = tempblock;
		}
		tempblock->count = 0;
		tempblock->mark = 0;
		tempblock->malloc_flag = 0;
		prevblock = tempblock;
	}
	block->count = 0;
	block->mark = 0;
}

/******************************************************************************/
