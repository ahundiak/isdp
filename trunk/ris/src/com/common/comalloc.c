/* ============================================================================
 * SOL10 23 Nov 2010
 *
 * 29 Nov 2010
 * Sun really does imply sparc
 * It seems that Sun x86 malloc always returns 8-byte boundaries
 *
 * The 8-byte vs 4-byte comes up again
 * Parts of this code key on sco/win32 while other parts include Soli
 *
 * Also assumes sun means 8 byte alignment but I think sun is always defined for SunStudio
 * 
 * Probably need to come back and revisit, talking to ris daemon on the database server
 * Need to see what is up but maybe can always align or maybe can just add an assert
 *
 * Ran a test and it appears that random mallocs are always 8 byte aligned.
 * So leave as is for now.  Might also use memalign is necessary
 */
/*
**	NAME:							comalloc.c
**	AUTHORS:						Dave Michal
**	CREATION DATE:					2/86
**	ABSTRACT:
**		contains the functions that do the memory management
**	
**	REVISION HISTORY:
**		Modified by Hitesh R. Patel on 8/92
**
**		Dan Karier modes for AST SCO Unix SMP box 5/93
**			Changes are because malloc returns 4 byte aligned addresses instead
**			of 8 byte aligned addresses. [NOTE: if defined(sco) code]
**
**		James Chang 				9/94	
**			VC++ on NT has same problem. [ if defined (WIN32) code ] 
**			
*/
 
#define NO_COM_DBG

/*
**	INCLUDES
*/
#include <string.h>
#include <stdlib.h>

#include "ris_err.h"
#include "riscom.h"
#include "risdebug.h"
#include "rismem.h"
#include "risstjmp.h"

static int tracex = 0;

static ris_block_info * create_ris_block(int size);

/******************************************************************************/

/*
**  allocate 'size' bytes of memory for stmt id.
*/
extern char *RIScom_alloc(
	int		size,
	int		id,
	int		mark,
	char	type)
{
	unsigned int	avail;
	int				maxid = 0;
	char			*temppos = NULL;
	ris_alloc_info	*mem = 0;
	ris_block_info	*tempblock;
	ris_block_info	*old_block;

	COM_DBG(("RIScom_alloc(size:%d id:%d mark:%d type:%d)\n",
		size, id, mark, type));

	switch(type)
	{
		case STATEMENT_MEMORY:
			COM_DBG(("RIScom_alloc: allocating STATEMENT_MEMORY\n"));
			maxid =	RIS_MAX_STMTS - 1;
		break;

		case SCHEMA_MEMORY:
			COM_DBG(("RIScom_alloc: allocating SCHEMA_MEMORY\n"));
			maxid =	RIS_MAX_OPEN_SCHEMAS - 1;
		break;

		case PERMANENT_MEMORY:
			COM_DBG(("RIScom_alloc: allocating PERMANENT_MEMORY\n"));
			maxid = 0;
		break;

		case ASYNC_MEMORY:
			COM_DBG(("RIScom_alloc: allocating ASYNC_MEMORY\n"));
			maxid =	RIS_MAX_TRANSACTIONS - 1;
		break;

		case SUPERSCHEMA_MEMORY:
			COM_DBG(("RIScom_alloc: allocating SUPERSCHEMA_MEMORY\n"));
			maxid =	RIS_MAX_OPEN_SUPERSCHEMAS - 1;
		break;

		default:
			COM_DBG(("RIScom_alloc: invalid type:%d\n", type));
			LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	/*
	** check that size is >= 1 and <= max concatenated block size
	*/
	if (size < 1)
	{
		LONGJMP(RIS_E_SIZE_TOO_SMALL);
	}
	if (size > (RIS_BLOCK_SIZE+sizeof(ris_block_info)) * 65535 + RIS_BLOCK_SIZE)
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
		COM_DBG(("RIScom_alloc: id:%d > maxid:%d\n", id, maxid));
		LONGJMP(RIS_E_STMT_ID_TOO_BIG);
	}

	/*
	**	Check for valid mark
	*/
	if (mark < 0 || mark >= RIS_MAX_ALLOC_MARK - 1)
	{
		COM_DBG(("RIScom_alloc: Invalid mark:%d\n", mark));
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

		case ASYNC_MEMORY:
			mem = &RIS_mem->async[id];
		break;

		case PERMANENT_MEMORY:
			mem = &RIS_mem->permanent;
		break;
	}

	/*
	**	DEFAULT_MARK (mark = 0)
	*/
	if( mark == DEFAULT_MARK )
	{
		/*
		** if a new statement id is given then init its structure
		*/
		if (!mem->blk)
		{
			COM_DBG(("RIScom_alloc: this is a new statement id\n"));
			mem->blk = RIScom_get_block(size);
			mem->end = mem->blk;
			mem->avail = 
				mem->blk->count * (RIS_BLOCK_SIZE + sizeof(ris_block_info)) + 
				RIS_BLOCK_SIZE;
			mem->pos = (char *)(mem->blk) + sizeof(ris_block_info);

			mem->blk->mark = (char) mark;
		}
		else
		{
			/*
			** align position for any type
			*/
			temppos = mem->pos;
			mem->pos +=
				(ALIGN - 1) - (((int)mem->pos - 1) &(ALIGN - 1));
	
			if ((unsigned int)(mem->pos) < (unsigned int)temppos)
			{
				COM_DBG(("RIScom_alloc: mem->pos(0x%x) < temppos(0x%x)\n",
					mem->pos, temppos));
				LONGJMP(RIS_E_INTERNAL_ERROR);
			}
			avail = (unsigned int)(mem->pos) - (unsigned int)temppos;
			if (avail < mem->avail)
			{
				mem->avail -= avail;
			}
			else
			{
				mem->avail = 0;
			}

			/*
			** if there is not enough room in the current block
			** then get a new block
			*/
			if ((unsigned)size > mem->avail)
			{
				COM_DBG(("getting a new block\n"));
				tempblock = RIScom_get_block(size);
				mem->end->next = tempblock;
				mem->end = tempblock;
				mem->avail =
					mem->end->count * (RIS_BLOCK_SIZE+sizeof(ris_block_info)) +
					RIS_BLOCK_SIZE;
				mem->pos = (char *)(mem->end) + sizeof(ris_block_info);

				mem->end->mark = (char) mark; /* DEFAULT_MARK */
			}
		}
		mem->avail -= size;
		temppos = mem->pos;
		mem->pos += size;

		COM_DBG(("addr returned = %x avail = %d\n", temppos, mem->avail));
		return(temppos);
	}
	else
	{
		/*
		**	For non-DEFAULT_MARKS (mark > 0)
		*/

		for (old_block = mem->blk; old_block; old_block = old_block->next)
		{
			if (old_block->mark == (char) mark)
			{
				/*
				**	RIScom_alloc cannot be called.
				*/
				COM_DBG(("RIScom_alloc: mark allocated & reallocable only\n"));
				LONGJMP(RIS_E_INTERNAL_ERROR);
			}
		}

		/*
		** if a new statement id is given then init its structure
		*/
		COM_DBG(("RIScom_alloc: this is a new statement id\n"));
		tempblock = RIScom_get_block(size);

		if (mem->end)
		{
			/*
			**	End of the list
			*/
        	mem->end->next = tempblock;
        	mem->end = tempblock;
		}
		else
		{
			/*
			**	Beginning of the list
			*/
			mem->blk = tempblock;
			mem->end = mem->blk;
		}
        mem->end->mark = (char) mark;
		temppos = (char *)(mem->end) + sizeof(ris_block_info);

#ifndef NO_COM_DBG
		if (RIScom_debug)
		{
			avail = 
				mem->end->count * (RIS_BLOCK_SIZE + sizeof(ris_block_info)) + 
				RIS_BLOCK_SIZE;
			COM_DBG(("addr returned = %x avail = %d\n", temppos, avail));
		}
#endif
		return(temppos);
	}
}

/******************************************************************************/

/*
** get a new or used or new/used block
*/

extern ris_block_info *RIScom_get_block(int size)
{
	int				i;
	int				num_blocks;
	int				total_block_size;
	ris_block_info	*block;
	ris_block_info	**tempblockp;
	ris_block_info	**nextblockp;

	COM_DBG(("RIScom_get_block(size:%d)\n",size));

	nextblockp = (ris_block_info **)0;	/* shut up the compiler */
	tempblockp = (ris_block_info **)0;	/* shut up the compiler */

/*
** calculate the number of blocks needed
*/

	num_blocks = (size + sizeof(ris_block_info)) / (RIS_BLOCK_SIZE + sizeof(ris_block_info));

	if ((size + sizeof(ris_block_info)) % (RIS_BLOCK_SIZE + sizeof(ris_block_info)))
	{
		num_blocks++;
	}

	COM_DBG(("blocks needed = %d\n",num_blocks));

/*
** calculate total size of the blocks
*/

	total_block_size = num_blocks * (RIS_BLOCK_SIZE + sizeof(ris_block_info));

	COM_DBG(("total size of blocks = %d\n",total_block_size));

/*
** if there are enough contiguous free blocks then return them
*/

	COM_DBG(("looking for %d contiguous free block(s)\n",num_blocks));

	for(tempblockp = &RIS_mem->free; (*tempblockp); )
	{

COM_DBG(("examining initial block candidate = 0x%x\n", (*tempblockp)));

		for(nextblockp = &((*tempblockp)->next), i = 1;
			(*nextblockp) && i < num_blocks;
			i++, nextblockp = &((*nextblockp)->next))
		{

COM_DBG(("examining next block candidate = 0x%x\n",(*nextblockp)));

/* check if next block is contiguous */

			if ((char *)(*nextblockp)!=(char *)(*tempblockp)+i*(RIS_BLOCK_SIZE+
				sizeof(ris_block_info)))
			{
				break;
			}
		}

/* check if we found enough contiguous blocks */

		if (i == num_blocks)
		{
			COM_DBG(("found %d contiguous free block(s)\n",num_blocks));
			break;
		}

/* set pointers to look at the blocks after this sequence */
		tempblockp = nextblockp;
	}

/* check if we found/created enough contiguous blocks */

	if ((*tempblockp))
	{
		block = *tempblockp;
		*tempblockp = *nextblockp;

		/*
		** initialize the block
		*/
		memset(block,0,total_block_size);
		block->count = (unsigned short)(num_blocks-1);
	}
	else
	{
		/*
		** else create new block(s)
		*/
		block = create_ris_block(total_block_size);

		/*
		** initialize the block
		*/
		memset(block,0,total_block_size);
		block->count = (unsigned short) (num_blocks-1);
		block->malloc_flag = 1;
	}
	return(block);
}

/******************************************************************************/

/*
** create a new shared or local block
*/

static ris_block_info * create_ris_block(
	int size)
{
	ris_block_info *tempblock;

	COM_DBG(("create_ris_block(size:%d)\n",size));

	tempblock = (ris_block_info *)malloc(size);
	COM_DBG(("addr = 0x%x\n",tempblock));
	if (!tempblock)
	{
		LONGJMP(RIS_E_OUT_OF_MEMORY);
	}
	return tempblock;
}

/******************************************************************************/

extern char *RIScom_sys_calloc(unsigned int nelem, unsigned int size)
{
	char                    *ptr;
	ris_buffer_s    		*buffer=NULL;

	COM_DBG(("RIScom_sys_calloc(size:%d)\n", size));

#if defined (__clipper__) || defined (sun) || defined (vms)  || defined (__Sol2__) || defined(__hpux__) || defined(__i386)


	buffer = (ris_buffer_s *)calloc(nelem, size);
	ptr = (char *)buffer;

  if (tracex) printf(">>> RIScom_sys_calloc %d %d\n",nelem,size);
  if (0x4 & (unsigned)ptr) printf("*** RIScom_sys_calloc 4-byte alignment");
  
#elif defined (sco) || defined (WIN32) || defined (DOS) || defined (Solix)
	/*
	** SCO_PROBLEM
	** intel chip does not require doubles to be 8-byte aligned, so
	** calloc can return something that is only 4-byte aligned.
	** Our assumption has been that calloc always returned something
	** 8-byte aligned.  This means that we may have to adjust our pointer
	** 4 more bytes over, so we allocate an extra 8 bytes (to keep things
	** aligned when they were aligned to begin with), and then adjust
	** the ris_buffer_s/user_buffer 4 bytes left if necessary.
	** When we de/reallocate, we will only know the user
	** buffer, so we need to store how far off from the beginning of the
	** ris_buffer_s the real buffer begins.
	**
	** There are assumptions in the code that the two words immediately
	** preceding the data are the buffer size and data length, so in
	** order to remain compatible with existing clients we have to
	** put anything else BEFORE the size/len fields.  This allows us to
	** avoid modifying the standard ris_buffer_s structure, yet be
	** sure that it is 8-byte aligned.
	**
	** Case 1: no alignment adjustment required; usr_buffer-12 = offset
	**                      
	**       8 extra    |  normal allocation
	**     +++++++++++++ ===========================
	**    | fill | <8>  | size | len | data ... |
	**             ^___________________^
	**    ^______8______^
	**                      
	**                      
	** Case 2: 4-byte alignment adjustment required; usr_buffer-12 = offset
	**
	**       8 extra    |  normal allocation
	**     +++++++++++++ ===========================
	**             <------ (start was shifted left 4 bytes)
	**    | <4>  | size | len | data ... |
	**      ^___________________^
	**
	**    ^__4___^
	*/
	ptr = calloc(nelem, size + 8);
	COM_DBG(("RIScom_sys_calloc(calloc ptr:%d)\n", ptr));
	if (ptr)
	{
		int offset;

		/*
		** use an offset to align the ptr to the next 8-byte boundary
		*/
		if (0x4 & (unsigned)ptr)
		{
			ptr += sizeof(int);
			offset = sizeof(int);
		}
		else
		{
			ptr += (2*sizeof(int));
			offset = (2*sizeof(int));
		}
		buffer = (ris_buffer_s *)ptr;
		ptr = (char *)buffer;

		/*
		** store the offset in the word before the ris_buffer_s
		*/

		*(((int *)buffer)-1) = offset;

		COM_DBG(("RIScom_sys_calloc(buffer: 0x%x) offset: %d\n",buffer,offset));
	}
#else
THIS IS AN ERROR
#endif

	COM_DBG(("RIScom_sys_calloc: returning 0x%x\n", ptr));
	return ptr;
}

/******************************************************************************/

extern char *RIScom_sys_malloc(
	int size)
{
	char                    *ptr;
	ris_buffer_s    		*buffer=NULL;

	COM_DBG(("RIScom_sys_malloc(size:%d)\n", size));

#if defined (__clipper__) || defined (sun) || defined (vms)  || defined (__Sol2__) || defined(__hpux__) || defined(__i386)

	buffer = (ris_buffer_s *)malloc(size);
	ptr = (char *)buffer;

  if (tracex) printf(">>> RIScom_sys_malloc %d\n",size);
  if (0x4 & (unsigned)ptr) printf("*** RIScom_sys_malloc 4-byte alignment");

#elif defined (sco) || defined (WIN32) || defined (DOS) || defined (Solix)
	/*
	** SCO_PROBLEM
	** intel chip does not require doubles to be 8-byte aligned, so
	** malloc can return something that is only 4-byte aligned.
	** Our assumption has been that malloc always returned something
	** 8-byte aligned.  This means that we may have to adjust our pointer
	** 4 more bytes over, so we allocate an extra 8 bytes (to keep things
	** aligned when they were aligned to begin with), and then adjust
	** the ris_buffer_s/user_buffer 4 bytes left if necessary.
	** When we de/reallocate, we will only know the user
	** buffer, so we need to store how far off from the beginning of the
	** ris_buffer_s the real buffer begins.
	**
	** There are assumptions in the code that the two words immediately
	** preceding the data are the buffer size and data length, so in
	** order to remain compatible with existing clients we have to
	** put anything else BEFORE the size/len fields.  This allows us to
	** avoid modifying the standard ris_buffer_s structure, yet be
	** sure that it is 8-byte aligned.
	**
	** Case 1: no alignment adjustment required; usr_buffer-12 = offset
	**                      
	**       8 extra    |  normal allocation
	**     +++++++++++++ ===========================
	**    | fill | <8>  | size | len | data ... |
	**             ^___________________^
	**    ^______8______^
	**                      
	**                      
	** Case 2: 4-byte alignment adjustment required; usr_buffer-12 = offset
	**
	**       8 extra    |  normal allocation
	**     +++++++++++++ ===========================
	**             <------ (start was shifted left 4 bytes)
	**    | <4>  | size | len | data ... |
	**      ^___________________^
	**
	**    ^__4___^
	*/
	ptr = malloc(size + 8);
	COM_DBG(("%s,%d:RIScom_sys_malloc:ptr = %#x, sizeof(int) = %d\n",
		__FILE__, __LINE__, ptr, sizeof(int)));
	if (ptr)
	{
		int offset;

		/*
		** use an offset to align the ptr to the next 8-byte boundary
		*/
		if (0x4 & (unsigned)ptr)
		{
			ptr += sizeof(int);
			offset = sizeof(int);
		}
		else
		{
			ptr += (2*sizeof(int));
			offset = (2*sizeof(int));
		}
		buffer = (ris_buffer_s *)ptr;
		ptr = (char *)buffer;

		/*
		** store the offset in the word before the ris_buffer_s
		*/

		*(((int *)buffer)-1) = offset;

		COM_DBG((
			"%s,%d:RIScom_sys_malloc:buffer = %#x, ((int *)buffer)-1 = %#x, offset= %d\n",
			__FILE__, __LINE__, buffer, ((int *)buffer)-1, offset));
	}
#else
THIS IS AN ERROR
#endif

	COM_DBG(("RIScom_sys_malloc: returning 0x%x\n", ptr));
	return ptr;
}

/******************************************************************************/

extern char *RIScom_sys_realloc(
	char    *user_buffer,
	int             size)
{
	char            *ptr;
	ris_buffer_s    *buffer;
#if defined (sco) || defined (WIN32) || defined (DOS) || defined(Soli)
	int				offset;
#endif

	COM_DBG(("RIScom_sys_realloc(user_buffer:0x%x size:%d)\n",
		user_buffer, size));

#if defined (__clipper__) || defined (sun) || defined (vms)  || defined (__Sol2__) || defined(__hpux__) || defined(__i386)
	buffer = (ris_buffer_s *)(user_buffer);
	buffer = (ris_buffer_s *)realloc((char *)buffer, size);
	ptr = (char *)buffer;

  if (tracex) printf(">>> RIScom_sys_realloc %d\n",size);
  if (0x4 & (unsigned)ptr) printf("*** RIScom_sys_realloc 4-byte alignment");

#elif defined (sco) || defined (WIN32) || defined (DOS) || defined (Solix)
	/*
	** SCO_PROBLEM
	** See description above.
	*/
	buffer = (ris_buffer_s *)(user_buffer);

	/*
	** The offset to the beginning of the real buffer is in the word 
	** immediately before the ris_buffer_s.
	*/
	offset = *(((int *)buffer)-1);
	ptr = ((char *)buffer)-offset;

	ptr = realloc((char *)ptr, size + 8);
	if (ptr)
	{
		/*
		** use an offset to align the ptr to the next 8-byte boundary
		*/
		if (0x4 & (unsigned)ptr)
		{
			ptr += sizeof(int);
			offset = sizeof(int);
		}
		else
		{
			ptr += (2*sizeof(int));
			offset = (2*sizeof(int));
		}
	
		buffer = (ris_buffer_s *)ptr;
		ptr = (char *)buffer;

		/*
		** store the offset in the word before the net_buffer_s
		*/

		*(((int *)buffer)-1) = offset;

		COM_DBG(("RIScom_sys_realloc(buffer: 0x%x) offset: %d\n",
			buffer, offset));
	}

#else
THIS IS AN ERROR
#endif

	COM_DBG(("RIScom_sys_realloc:returning 0x%x\n", ptr));
	return ptr;
}

/******************************************************************************/

extern void RIScom_sys_free(
	char *user_buffer)
{
	ris_buffer_s    *buffer;

#if defined (sco) || defined (WIN32) || defined (DOS) || defined (Soli)
	char 			*ptr;
	int				offset;
#endif

	COM_DBG(("RIScom_sys_free(user_buffer:%#x)\n", user_buffer));

#if defined (__clipper__) || defined (sun) || defined (vms)  || defined (__Sol2__) || defined(__hpux__) || defined(__i386)
	buffer = (ris_buffer_s *)(user_buffer);
	free((char *)buffer);

#elif defined (sco) || defined (WIN32) || defined (DOS) || defined (Solix)
	buffer = (ris_buffer_s *)(user_buffer);

	/*
	** The offset to the beginning of the real buffer is in the word 
	** immediately before the ris_buffer_s.
	*/
	offset = *(((int *)buffer)-1);
	COM_DBG(("%s,%d:RIScom_sys_free:offset = %d, ((int *)buffer)-1 = %#x\n",
		__FILE__, __LINE__, offset, ((int *)buffer)-1));
	ptr = ((char *)buffer)-offset;
	COM_DBG(("%s,%d:RIScom_sys_free:ptr = %#x\n", __FILE__, __LINE__,
		ptr));

	free((char *)ptr);

#else
THIS IS AN ERROR
#endif

	COM_DBG(("RIScom_sys_free:returning\n"));
}

/******************************************************************************/
