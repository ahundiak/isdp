/* Do not alter this PINNACLE information: $Revision: 1.2.28.1 $ */
/*
**	NAME:							comrealc.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					3/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
**      Modified by Hitesh R. Patel on 8/92
**
**		Dan Karier modes for AST SCO Unix SMP box 5/93
**			Changes are because malloc returns 4 byte aligned addresses instead
**			of 8 byte aligned addresses. [NOTE: if defined(sco) code]
**
**
**			Same thing withe VC++. James Chang 9/94
*/
 
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
#define comrealc_c
#include "comalloc.prt"
#include "comdebug.prt"
#include "comfree.prt"
#include "comjmp.prt"
#include "comrealc.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/


extern char *RIScom_realloc(
	int		new_alloc_size,
	int		id,
	int		mark,
	char	type)
{
	int				maxid = 0;
	int				old_block_size;
	int				new_block_size;
	char			*old_start_pos;
	char			*new_start_pos;
	char			*return_value;
	ris_alloc_info	*mem = 0;
	ris_block_info	*old_block;
	ris_block_info	*new_block;
#if defined(sco) || defined (WIN32)
	char			*temppos = NULL;
#endif

	COM_DBG(("RIScom_realloc(new_alloc_size:%d id:%d mark:%d type:%d)\n",
		new_alloc_size, id, mark, type));

	switch(type)
	{
		case STATEMENT_MEMORY:
			COM_DBG(("RIScom_realloc: reallocating STATEMENT_MEMORY\n"));
			maxid =	RIS_MAX_STMTS - 1;
		break;

		case SCHEMA_MEMORY:
			COM_DBG(("RIScom_realloc: reallocating SCHEMA_MEMORY\n"));
			maxid =	RIS_MAX_OPEN_SCHEMAS - 1;
		break;

		case SUPERSCHEMA_MEMORY:
			COM_DBG(("RIScom_realloc: reallocating SUPERSCHEMA_MEMORY\n"));
			maxid =	RIS_MAX_OPEN_SUPERSCHEMAS - 1;
		break;

		case PERMANENT_MEMORY:
			COM_DBG(("RIScom_realloc: reallocating PERMANENT_MEMORY\n"));
			maxid = 0;
		break;

		default:
			COM_DBG(("RIScom_realloc: invalid type:%d\n", type));
			LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	/*
	** check that size is >= 1 and <= max concatenated block size
	*/
	if (new_alloc_size < 1)
	{
		LONGJMP(RIS_E_SIZE_TOO_SMALL);
	}

	if (new_alloc_size >
		(RIS_BLOCK_SIZE+sizeof(ris_block_info)) * 65535 + RIS_BLOCK_SIZE)
	{
		LONGJMP(RIS_E_SIZE_TOO_BIG);
	}

	/*
	** check that id is >= 0 and <= maxid
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
	**	Check if mark is valid for realloc
	**	Cannot reallocate DEFAULT_MARK
	*/
	if (mark < 1 || mark >= RIS_MAX_ALLOC_MARK - 1)
	{
		COM_DBG(("RIScom_realloc: invalid mark:%d\n", mark));
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

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

		case PERMANENT_MEMORY:
			mem = &RIS_mem->permanent;
		break;
	}

	/*
	**	Get marked block
	*/
	for (old_block = mem->blk; old_block; old_block = old_block->next)
	{
		if (old_block->mark == (char)mark)
		{
			break;
		}
	}
	if (!old_block)
	{
		COM_DBG(("RIScom_realloc: can't find marked block\n"));
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	old_block_size =
		old_block->count * (RIS_BLOCK_SIZE + sizeof(ris_block_info)) +
		RIS_BLOCK_SIZE;
	old_start_pos = (char *)(old_block) + sizeof(ris_block_info);

	COM_DBG(("RIScom_realloc: old_block_size:%d old_start_pos:0x%x\n", 
			old_block_size, old_start_pos));

#if defined(sco) || defined (WIN32)
	temppos = old_start_pos;
	old_start_pos += (ALIGN - 1) - (((int)old_start_pos - 1) &(ALIGN - 1));

	old_block_size -= (old_start_pos - temppos);

	COM_DBG(("RIScom_realloc adjustment:old_block_size:%d old_start_pos:0x%x\n",
			old_block_size, old_start_pos));
#endif

	if (new_alloc_size <= old_block_size)
	{
		/*
		**	The new request size fits in the old block
		*/
		COM_DBG(("RIScom_realloc: new size fits in the old block\n"));
		return_value = old_start_pos;
	}
	else
	{
#ifdef LATER
		check for contiguous blocks on free list
#endif
		/*
		**	Get a new block
		*/
		COM_DBG(("RIScom_realloc: getting a new block\n"));

#if defined(unix) && !defined(sco) || defined(DOS)
		new_block = RIScom_get_block(new_alloc_size);
#endif
#if defined(sco) || defined (WIN32)
		new_block = RIScom_get_block(new_alloc_size + sizeof(int));
#endif

		new_block_size =
			new_block->count * (RIS_BLOCK_SIZE + sizeof(ris_block_info)) +
			RIS_BLOCK_SIZE;
		new_start_pos = (char *)(new_block) + sizeof(ris_block_info);

#if defined(sco) || defined (WIN32)
		temppos = new_start_pos;
		new_start_pos += (ALIGN - 1) - (((int)new_start_pos - 1) &(ALIGN - 1));

		new_block_size -= (new_start_pos - temppos);

		COM_DBG(
		   ("RIScom_realloc adjustment:new_block_size:%d new_start_pos:0x%x\n",
		   new_block_size, new_start_pos));
#endif

		/*
		**	Copy info out of the old block
		*/
		memcpy(new_start_pos, old_start_pos, old_block_size);
		
		/*
		**	Free the old block
		*/
		RIScom_free(id, mark, type);

		/*
		**	Put the new block on the list
		*/
		mem->end->next = new_block;
		mem->end = new_block;
		mem->end->mark = (char)mark;

		return_value = new_start_pos;
	}

	COM_DBG(("RIScom_realloc: returning 0x%x\n", return_value));
	return return_value;
}
