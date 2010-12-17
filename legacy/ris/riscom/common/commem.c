/* Do not alter this SPC information: $Revision: 1.1.55.1 $ */
/*
**	NAME:							commem.c
**	AUTHORS:						David Michal
**	CREATION DATE:					2/86
**	ABSTRACT:
**	contains the functions that do the memory management
**		
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "ris_err.h"
#include "risdebug.h"
#include "rislimit.h"
#include "rismem.h"

/*
**	DEFINES
*/
#define REMOVE_MEM_TIMEOUT 30

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define commem_c
#include "commem.prt"
#include "comfree.prt"
#include "comdebug.prt"
#include "sys.prt"
#include "sysalloc.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RIScom_get_mem(
	void)
{
	COM_DBG(("RIScom_get_mem()\n"));

	RIS_mem = (ris_mem_info *)malloc(sizeof(ris_mem_info));
	memset((char *)RIS_mem,0,sizeof(ris_mem_info));

	COM_DBG(("RIScom_get_mem: complete\n\tRIS_mem:0x%x\n", RIS_mem));
}

/******************************************************************************/

extern void RIScom_remove_mem()
{
	int i;
	ris_block_info	*ptr;
	ris_block_info	**ptrp;
	ris_block_info	*temp;

	COM_DBG(("RIScom_remove_mem()\n"));

	if (RIS_mem)
	{
		COM_DBG(("RIScom_remove_mem: freeing allocated blocks\n"));
		for (i = 0; i < RIS_MAX_STMTS; i++)
		{
			FREE(i);
		}
		for (i = 0; i < RIS_MAX_OPEN_SCHEMAS; i++)
		{
			FREES(i);
		}
		for (i = 0; i < RIS_MAX_TRANSACTIONS; i++)
		{
			FREEA(i);
		}
		FREEP();

		if (RIS_mem->free)
		{
			COM_DBG(("RIScom_remove_mem: eliminating non-malloc'd blocks\n"));
			ptrp = &RIS_mem->free;
			while(*ptrp)
			{
				if ((*ptrp)->malloc_flag == 0)
				{
					COM_DBG(("\teliminating 0x%x\n", *ptrp));
					(*ptrp) = (*ptrp)->next;
				}
				else
				{
					ptrp = &((*ptrp)->next);
				}
			}

			COM_DBG(("RIScom_remove_mem: freeing free list\n"));
			ptr = RIS_mem->free;
			while(ptr)
			{
				temp = ptr;
				ptr = ptr->next;
				COM_DBG(("\tfreeing 0x%x\n",temp));
				free(temp);
			}
			RIS_mem->free = 0;
		}

		COM_DBG(("RIScom_remove_mem: freeing RIS_mem\n\tfreeing 0x%x\n",
			RIS_mem));
		free(RIS_mem);
		RIS_mem = 0;
	}

	COM_DBG(("RIScom_remove_mem: complete\n"));
}

/******************************************************************************/
