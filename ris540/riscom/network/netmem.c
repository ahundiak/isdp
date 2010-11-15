/*
**	NAME:							netmem.c
**	AUTHORS:						David Michal
**	CREATION DATE:					2/86
**	ABSTRACT:
**		contains the functions that do the memory management
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <errno.h>
#include <stdio.h>

#include "net.h"

/*
**	DEFINES
*/
#define REMOVE_MEM_TIMEOUT 30

/*
**	TYPES
*/
#if defined (unix) && !defined(sun)
union semun
{
    int             val;
    struct semid_ds *buf;
    ushort          *array;
};
#endif

/*
**	FUNCTION PROTOTYPES
*/
#include "net_sys.prt"
#define netmem_c
#include "netmem.prt"
#include "netshare.prt"

#if defined(sun) || defined(__Sol2__) || defined(__hpux__) || defined(Soli)
#include "netshmem.h"
#endif

/*
**	VARIABLES
*/
#if defined(WIN32)
extern int		client_died;
extern BOOL		server_locked;
extern struct event_info NTevents[25];
#endif


/*
**	FUNCTIONS
*/

/******************************************************************************/

#if defined(unix) || defined(WIN32)

extern void NET_print_free_list()
{
	net_block_info_s *temp;
#if defined(WIN32) || defined(__Sol2__) || defined(Soli)
	net_block_info_s **nextp;
#endif

	if (!NET_debug_handler) return;

	/*
	** free linked list is self-relative pointers ( which means the value
	** is an offset which added to pointer's address yields the pointer);
	** because the client & server processes may not map the shared
	** memory region to the same virtual address space; so end-of-list 
	** is when the ptr's value is equal to its own address.
	*/
#if defined(__clipper__) || defined(sun) || defined(sco) || defined(__hpux__)
	if (NET_mem->free)
#endif
#if defined(WIN32) || defined(__Sol2__) || defined(Soli)
	if (NET_GET_PTR(&NET_mem->free, char) != (char *)&NET_mem->free)
#endif
	{
		NET_debug_handler("\nNET_mem->free:\n");
#if defined(__clipper__) || defined(sun) || defined(sco) || defined(__hpux__)
		for (temp = NET_mem->free; temp; temp = temp->next)
		{
			NET_debug_handler("0x%x\n", temp);
			if ((char *)temp + NET_BLOCK_SIZE == (char *)temp->next)
				NET_debug_handler("        >contiguous\n");
			else
				NET_debug_handler("\n");
		}
#endif
#if defined(WIN32) || defined(__Sol2__) || defined(Soli)
		for (nextp = (net_block_info_s **)(&NET_mem->free),
			 temp = NET_GET_PTR(nextp, net_block_info_s);
			 temp != (net_block_info_s *)nextp;
			 nextp = &temp->next,
			 temp = NET_GET_PTR(nextp, net_block_info_s))
		{
			NET_debug_handler("0x%x\n", temp);
			if ((char *)temp + NET_BLOCK_SIZE ==
				(NET_GET_PTR(&temp->next, char)))
				NET_debug_handler("        >contiguous\n");
			else
				NET_debug_handler("\n");
		}
#endif
	}
	else
	{
		NET_debug_handler("\nNET_mem->free:NULL\n\n");
	}
}

/******************************************************************************/

/*
** create a new shared or local block
*/
static net_block_info_s *NET_create_block(
	net_s	*net,
	int		size)
{
	net_block_info_s	*tempblock = (net_block_info_s *)0;	/* init for acc */

	NET_DBG(("NET_create_block(net:0x%x size:%d)\n", net, size));

	if (size > 0)
	{
		if (NET_mem->avail == (unsigned)(-1) ||
			NET_mem->avail < (unsigned)size)
		{
			NET_error(net, NET_E_OUT_OF_MEMORY);
			return (net_block_info_s *)0;
		}
		NET_mem->avail -= size;
#if defined(__clipper__) || defined(sun) || defined(sco) || defined(__hpux__)
		tempblock = (net_block_info_s *)NET_mem->pos; 
		NET_mem->pos += size;
#endif
#if defined(WIN32) || defined(__Sol2__) || defined(Soli)
		tempblock = NET_GET_PTR(&NET_mem->pos, net_block_info_s);
		NET_DBG(("NET_create_block: old pos 0x%x\n", tempblock));
		NET_SET_PTR((NET_GET_PTR(&NET_mem->pos, char)+size),&NET_mem->pos,
					char);
		NET_DBG(("NET_create_block: new pos 0x%x\n", 
				 NET_GET_PTR(&NET_mem->pos, char)));
#endif
	}

	NET_DBG(("NET_create_block: complete\n"));
	return tempblock;
}

/******************************************************************************/

/*
** get a new or used or new/used block
*/

extern net_block_info_s * NET_get_block(
	net_s	*net,
	int		size)
{
	int					i;
	int					num_blocks;
	int					total_block_size;
	net_block_info_s	*block;
	net_block_info_s	**tempblockp;
	net_block_info_s	**nextblockp;

	NET_DBG(("NET_get_block(net:0x%x size:%d)\n", net, size));

	nextblockp = (net_block_info_s **)0;	/* shut up the compiler */
	tempblockp = (net_block_info_s **)0;	/* shut up the compiler */

	/*
	** calculate the number of blocks needed
	*/
	num_blocks = (size + NET_HEADER_SIZE) / NET_BLOCK_SIZE;
	if ((size + NET_HEADER_SIZE) % NET_BLOCK_SIZE)
	{
		num_blocks++;
	}
	NET_DBG(("NET_get_block: blocks needed:%d\n",num_blocks));

	/*
	** calculate total size of the blocks
	*/
	total_block_size = num_blocks * NET_BLOCK_SIZE;
	NET_DBG(("NET_get_block: total size of blocks:%d\n",total_block_size));

	/*
	** if there are enough contiguous free blocks then return them
	*/
	NET_DBG(("NET_get_block: looking for %d contiguous free block(s)\n",
		num_blocks));
#if defined(__clipper__) || defined(sun) || defined(sco) || defined(__hpux__)
	for(tempblockp = &NET_mem->free; (*tempblockp);)
	{
		NET_DBG(("NET_get_block: examining initial block candidate:0x%x\n",
			(*tempblockp)));
		for(nextblockp = &((*tempblockp)->next), i = 1;
			(*nextblockp) && i < num_blocks;
			i++, nextblockp = &((*nextblockp)->next))
		{
			NET_DBG(("NET_get_block: examining next block candidate:0x%x\n",
				(*nextblockp)));

			/*
			**	check if next block is contiguous
			*/
			if((char *)(*nextblockp) != (char *)(*tempblockp)+i*NET_BLOCK_SIZE)
			{
				break;
			}
		}
#endif
#if defined(WIN32) || defined(__Sol2__) || defined(Soli)
	for(tempblockp = &NET_mem->free;
		NET_GET_PTR(tempblockp, char) != (char *)tempblockp;)
	{
		NET_DBG(("NET_get_block: examining initial block candidate:0x%x\n",
			NET_GET_PTR(tempblockp, char)));
		for(nextblockp =
				&(NET_GET_PTR(tempblockp, net_block_info_s)->next),
				i = 1;
			NET_GET_PTR(nextblockp, char) != (char *)nextblockp
				&& i < num_blocks;
			i++, nextblockp =
				&(NET_GET_PTR(nextblockp, net_block_info_s)->next))
		{
			NET_DBG(("NET_get_block: examining next block candidate:0x%x\n",
				NET_GET_PTR(nextblockp, char)));

			/*
			**	check if next block is contiguous
			*/
			if (NET_GET_PTR(nextblockp, char) !=
					NET_GET_PTR(tempblockp, char)+i*NET_BLOCK_SIZE)
			{
				break;
			}
		}
#endif

		/*
		**	check if we found enough contiguous blocks
		*/
		if (i == num_blocks)
		{
			NET_DBG(("NET_get_block: found %d contiguous free block(s)\n",
				num_blocks));
			break;
		}

		/*
		**	check if we can create new block(s) contiguous to the last
		**	free block(s)
		*/
#if defined(__clipper__) || defined(sun) || defined(sco) || defined(__hpux__)
		if (!(*nextblockp) &&
			(char *)(*tempblockp) + i * NET_BLOCK_SIZE == NET_mem->pos)
#endif
#if defined(WIN32) || defined(__Sol2__) || defined(Soli)
		if (NET_GET_PTR(nextblockp, char) == (char *)nextblockp &&
				NET_GET_PTR(tempblockp, char) + i * NET_BLOCK_SIZE ==
				NET_GET_PTR(&NET_mem->pos, char))
#endif
		{
			NET_DBG(("NET_get_block: found %d contiguous free blocks\n", i));
			NET_DBG(("NET_get_block: allocating %d blocks\n", num_blocks-i));
			NET_create_block(net, (num_blocks - i) * NET_BLOCK_SIZE);
			if (net->error_code) return (net_block_info_s *)0;
			break;
		}

		/*
		**	set pointers to look at the blocks after this sequence
		*/
		tempblockp = nextblockp;
	}

	/*
	**	check if we found/created enough contiguous blocks
	*/
#if defined(__clipper__) || defined(sun) || defined(sco) || defined(__hpux__)
	if ((*tempblockp))
	{
		block = *tempblockp;
		/* mms - 11/07/95 - TR#439502872 - added the last block special case */
		if (*nextblockp)
        		*tempblockp = *nextblockp;
        	else
                {
                     NET_DBG (("LAST BLOCK on the chain : offset to 0\n")) ;
                     *tempblockp = 0 ;
                }
	}
#endif
#if defined(WIN32) || defined(__Sol2__) || defined(Soli)
	if (NET_GET_PTR(tempblockp, char) != (char *)tempblockp)
	{
		block = NET_GET_PTR(tempblockp, net_block_info_s);
		/* mms - 11/07/95 - TR#439502872 - added the last block special case */
		if (NET_GET_PTR (nextblockp, char) == (char *) nextblockp)
		{
		    NET_DBG (("LAST BLOCK on the chain : offset to 0\n")) ;
		    *tempblockp = (net_block_info_s *) 0 ;
		    
		}
		else
		{
        		NET_SET_PTR(NET_GET_PTR(nextblockp, char), tempblockp,
					net_block_info_s);
		}

		
	}
#endif
	/*
	** else if there is enough memory left create new block(s)
	*/
	else
	{
		block = NET_create_block(net, total_block_size);
		 NET_DBG(("NET_get_block:::::::::::::::::::::::::::::::::: \n"));
		if (net->error_code) return (net_block_info_s *)0;
	}

	/*
	** initialize the block
	*/
	memset(block, 0, total_block_size);
	block->count = num_blocks-1;
	block->size = size;

	NET_DBG(("NET_get_block: complete\n"));
	return(block);
}

/******************************************************************************/

static void NET_split_block(
	net_s				*net,
	net_block_info_s	*block)
{
	unsigned int i;
	net_block_info_s * tempblock;
	net_block_info_s * prevblock;
#if defined(WIN32) || defined(__Sol2__) || defined(Soli)
	int	nulltail = 0;
#endif

	NET_DBG(("NET_split_block(net:0x%x block:0x%x)\n", net, block));

	NET_DBG(("NET_split_block: block->count:%d\n", block->count));

	for(i = 1, prevblock = 0;i <= block->count; i++)
	{
		tempblock = (net_block_info_s *)((char *)block + i * NET_BLOCK_SIZE);

		NET_DBG(("NET_split_block: separating off block:0x%x\n",tempblock));
		if (prevblock)
		{
#if defined(__clipper__) || defined(sun) || defined(sco) || defined(__hpux__)
			tempblock->next = prevblock->next;
			prevblock->next = tempblock;
#endif
#if defined(WIN32) || defined(__Sol2__) || defined(Soli)
			NET_SET_PTR(NET_GET_PTR(&prevblock->next, char),
						&tempblock->next, net_block_info_s);
			NET_SET_PTR(tempblock, &prevblock->next, net_block_info_s);
			NET_DBG(("NET_split_block: temp ith block's next: 0x%x\n",
					 NET_GET_PTR(&tempblock->next, char)));
#endif
		}
		else
		{
#if defined(__clipper__) || defined(sun) || defined(sco) || defined(__hpux__)
			tempblock->next = block->next;
			block->next = tempblock;
#endif
#if defined(WIN32) || defined(__Sol2__) || defined(Soli)
			if ( NET_GET_PTR(&block->next, net_block_info_s) == block )
			{
				nulltail = 1;
				NET_DBG(("NET_split_block: nulltail %d\n", nulltail));
			}
			NET_SET_PTR(NET_GET_PTR(&block->next, char), &tempblock->next,
						net_block_info_s);
			NET_SET_PTR(tempblock, &block->next, net_block_info_s);
#endif
		}
		tempblock->count = 0;
		prevblock = tempblock;
	}
#if defined(WIN32) || defined(__Sol2__) || defined(Soli)
	if (nulltail)
	{
		NET_DBG(("NET_split_block: nulltail prevblock: 0x%x\n", prevblock));
		NET_DBG(("NET_split_block: nulltail prev's next: 0x%x\n",
					 NET_GET_PTR(&prevblock->next, char)));
		NET_SET_PTR(&prevblock->next, &prevblock->next, net_block_info_s);
		NET_DBG(("NET_split_block: nulltail's next: 0x%x\n",
					 NET_GET_PTR(&prevblock->next, char)));
	}	
#endif
	block->count = 0;

	NET_DBG(("NET_split_block: complete\n"));
}

/******************************************************************************/

extern void NET_free_blocks(
	net_s	*net,
	net_block_info_s * block)
{
	net_block_info_s ** free_p;

	NET_DBG(("NET_free_blocks(net:0x%x block:0x%x)\n", net, block));

#if defined(__clipper__) || defined(sun) || defined(sco) || defined(__hpux__)
	for (free_p = &NET_mem->free; (*free_p); free_p = &((*free_p)->next))
	{
		if (block == (*free_p))
		{
			NET_error(net, NET_E_ALREADY_FREE);
			return;
		}

		if (block < (*free_p))
		{
			block->next = *free_p;
			*free_p = block;
			break;
		}
	}
	if (!(*free_p))
	{
		block->next = (net_block_info_s *)0;
		*free_p = block;
	}
#endif
#if defined(WIN32) || defined(__Sol2__) || defined(Soli)
	NET_DBG(("NET_free_blocks: NET_mem free: 0x%x\n", 
			 NET_GET_PTR(&NET_mem->free, char)));
	for (free_p = &NET_mem->free;
		 NET_GET_PTR(free_p, char) != (char *)free_p;
		 free_p = &(NET_GET_PTR(free_p, net_block_info_s)->next))
	{
		NET_DBG(("NET_free_blocks: free_p 0x%x\n", free_p));
		if (block == NET_GET_PTR(free_p, net_block_info_s))
		{
			NET_error(net, NET_E_ALREADY_FREE);
			return;
		}

		if (block < NET_GET_PTR(free_p, net_block_info_s))
		{
			NET_SET_PTR(NET_GET_PTR(free_p, char), &block->next,
						net_block_info_s);
			NET_SET_PTR(block, free_p, net_block_info_s);
			break;
		}
	}
	if (NET_GET_PTR(free_p, char) == (char *)free_p)
	{
		NET_DBG(("NET_free_blocks: end free_p 0x%x\n", free_p));
		NET_SET_PTR(&block->next, &block->next, net_block_info_s);
		NET_DBG(("NET_free_blocks: block next: 0x%x\n", 
				 NET_GET_PTR(&block->next, char)));
		NET_SET_PTR(block, free_p, net_block_info_s);
		NET_DBG(("NET_free_blocks: end free_p 0x%x *free_p 0x%x\n",
				 free_p, *free_p));
	}
#endif
	NET_split_block(net, block);
	NET_ERRCHK(net);

	NET_DBG(("NET_free_blocks: complete\n"));
}

/******************************************************************************/

extern void NET_alloc_shmem(
	net_s				*net,
	net_shmem_info_s	*shmem_info)
{
#if defined(unix)
	int			i;
	int			shm_id;
	static char	shm_id_str[32];
	static char	shm_addr_str[32];
#endif
#if defined(WIN32)
	extern HANDLE		hMapObject;
	SECURITY_ATTRIBUTES	sa;
#endif

	NET_DBG(("NET_alloc_shmem(net:0x%x shmem_info:0x%x)\n",
							 net, shmem_info));

	if (NET_debug && NET_debug_handler)
	{
		NET_debug_handler("NET_alloc_shmem: initialize memory\n");

		NET_debug_handler("NET_alloc_shmem: shm_seg_size:%d\n",
			shmem_info->shm_seg_size);
		NET_debug_handler("NET_alloc_shmem: shm_key:0x%x\n",
			shmem_info->shm_key);
		NET_debug_handler("NET_alloc_shmem: shm_access:0%o\n",
			shmem_info->shm_access);
		NET_debug_handler("NET_alloc_shmem: sem_cnt:%d\n",
			shmem_info->sem_cnt);
		NET_debug_handler("NET_alloc_shmem: sem_key:0x%x\n",
			shmem_info->sem_key);
		NET_debug_handler("NET_alloc_shmem: sem_access:0%o\n",
			shmem_info->sem_access);
	}

	if (sizeof(net_mem_info_s) % 8 || sizeof(net_block_info_s) % 8)
	{
		NET_DBG(("Net_allocate_memory: structures are not 8 byte aligned\n"));
		NET_error(net, NET_E_INTERNAL_ERROR);
		return;
	}

	if (shmem_info->shm_seg_size > 0 && shmem_info->sem_cnt > 0)
	{
		/*
		**	Allocate shared memory
		*/
#if defined(unix)
#if defined(sun) || defined (__Sol2__) || defined(__hpux__) || defined(Soli)
		if (shmem_info->shm_seg_size > SHARED_MEMORY_MAX)
		{
			shmem_info->shm_seg_size = SHARED_MEMORY_MAX;
		}
#endif
		errno = EEXIST;
		for (i = 0, shm_id = -1;
			 shm_id == -1 && errno == EEXIST && i <= 9999;
			 i++)
		{
			shm_id = shmget((key_t)(shmem_info->shm_key|i),
				shmem_info->shm_seg_size,
				IPC_CREAT|IPC_EXCL|shmem_info->shm_access);
		}
		if (shm_id == -1)
		{
			NET_error(net, NET_E_CANT_GET_SHM_SEG);
			return;
		}
		NET_DBG(("NET_alloc_shmem: shm_id:%d\n", shm_id));

		NET_mem = (net_mem_info_s *)shmat(shm_id,0,0);
		if (NET_mem == (net_mem_info_s *)-1)
		{
			NET_mem = 0;
			NET_error(net, NET_E_CANT_ATTACH_SHM_SEG);
			return;
		}

		memset((char *)NET_mem, 0, sizeof(net_mem_info_s));
		NET_mem->shmid = shm_id;
		NET_mem->avail = shmem_info->shm_seg_size - sizeof(net_mem_info_s);
#if defined(__Sol2__) || defined(Soli)
		NET_SET_PTR((char *)NET_mem + sizeof(net_mem_info_s), &NET_mem->pos,
                    char);
#else
		NET_mem->pos = (char *)NET_mem + sizeof(net_mem_info_s);
#endif

		NET_DBG(("NET_alloc_shmem: NET_mem:0x%x\n", NET_mem));

		/*
		**	get semaphore set
		*/
		i = -1;
		do
		{
			NET_mem->sem_cnt = shmem_info->sem_cnt + 1;
			i++;
			do
			{
				NET_mem->sem_cnt--;
				NET_mem->semid = semget((key_t)(shmem_info->sem_key|i),
					NET_mem->sem_cnt,
					IPC_CREAT|IPC_EXCL|shmem_info->sem_access);
			}
			while(NET_mem->semid == -1 &&
				  errno == ENOSPC &&
				  NET_mem->sem_cnt);
		}
		while(NET_mem->semid == -1 && errno == EEXIST && i < 0xff);

		if (NET_mem->semid == -1)
		{
			NET_DBG(("NET_alloc_shmem: semget failed errno:%d\n",
				errno));
			NET_mem->sem_cnt = 0;
			NET_error(net, NET_E_CANT_GET_SEM_SET);
			return;
		}

		if (NET_mem->sem_cnt > sizeof(NET_mem->sem_alloc)*8)
		{
			NET_error(net, NET_E_INTERNAL_ERROR);
			return;
		}

		NET_DBG(("NET_alloc_shmem: NET_mem->semid:%d\n", NET_mem->semid));

		sprintf(shm_id_str, "NET_SHM_ID=0x%x", NET_mem->shmid);
		putenv(shm_id_str);
		NET_DBG(("NET_alloc_shmem: shm_id_str:<%s>\n", shm_id_str));

		sprintf(shm_addr_str, "NET_SHM_ADDR=0x%x", NET_mem);
		putenv(shm_addr_str);
		NET_DBG(("NET_alloc_shmem: shm_addr_str:<%s>\n", shm_addr_str));
#endif
#if defined(WIN32)
		/*
		**	Create File Mapping
		*/
		sa.bInheritHandle = TRUE;
		sa.lpSecurityDescriptor = NULL;
		sa.nLength = sizeof(SECURITY_ATTRIBUTES);
		hMapObject = CreateFileMapping ((HANDLE) 0xFFFFFFFF, &sa,
					PAGE_READWRITE, 0, shmem_info->shm_seg_size, NULL);
		if (!hMapObject)
		{
			NET_error(net, NET_E_CANT_GET_SHM_SEG_NT);
			NET_DBG(("NET_alloc_shmem: CreateFileMapping Failed error: %d\n",
						GetLastError()));
			return;
		}
		NET_DBG(("NET_alloc_shmem: CreateFileMapping was successful\n"));
		/*
		**	Map View Of File
		*/
		(LPVOID)NET_mem = MapViewOfFile (hMapObject,
										FILE_MAP_ALL_ACCESS, 0, 0, 0);
		if (!NET_mem)
		{
			NET_error(net, NET_E_CANT_ATTACH_SHM_SEG_NT);
			NET_DBG(("NET_alloc_shmem: MapViewOfFile Failed error: %d\n",
					GetLastError()));
			return;
		}
		NET_DBG(("NET_alloc_shmem: MapViewOfFile was successful\n"));
		memset((char *)NET_mem, 0, sizeof(net_mem_info_s));
		NET_mem->hMapObject = hMapObject;
		NET_mem->avail = shmem_info->shm_seg_size - sizeof(net_mem_info_s);
		NET_SET_PTR((char *)NET_mem + sizeof(net_mem_info_s), &NET_mem->pos,
					char);

		NET_DBG(("NET_alloc_shmem: NET_mem:0x%x\n", NET_mem));
#endif
	}

	NET_DBG(("NET_alloc_shmem: complete\n"));
}

/******************************************************************************/

extern void NET_attach_shmem(
	net_s *net)
{
#if defined(unix)
	int		shm_id;
	char	*ptr;
	char	*shm_addr;
#endif
#if defined(WIN32)
	extern HANDLE	hMapObject;
#endif

	NET_DBG(("NET_attach_shmem(net:0x%x)\n", net));

#if defined (unix)
	if ((ptr = getenv("NET_SHM_ID")) != NULL)
	{
		sscanf(ptr,"0x%x", &shm_id);
	}

	if ((ptr = getenv("NET_SHM_ADDR")) != NULL)
	{
		sscanf(ptr,"0x%x", &shm_addr);
	}

#if defined (__Sol2__) || defined(__hpux__) || defined(Soli)
/* better to let Solaris or HP_UX tell us where segment should be */
	shm_addr=0; 
#endif

	NET_DBG(("NET_attach_shmem: shm_id:0x%x shm_addr:0x%x\n",shm_id, shm_addr));

	NET_mem = (net_mem_info_s *)shmat(shm_id,shm_addr,0);
	if (NET_mem == (net_mem_info_s *)-1)
	{
		NET_mem = 0;
		NET_error(net, NET_E_CANT_ATTACH_SHM_SEG);
		return;
	}
#endif

#if defined (__Sol2__) || defined(Soli)
	NET_DBG(("NET_attach_shmem got: shm_id:0x%x shm_addr:0x%x\n",shm_id, NET_mem));

NET_DBG(("NET_attach_shmem NET_mem->pos: <0x%x>\n", NET_mem->pos));
#endif
#if defined(WIN32)
	/*
	**	MapViewOfFile
	*/
	(LPVOID)NET_mem = MapViewOfFile(hMapObject,FILE_MAP_ALL_ACCESS,0,0,0);
	if (!NET_mem)
	{
		NET_DBG(("NET_attach_shmem: MapViewOfFile Failed: Error %d\n",
				GetLastError()));
		NET_mem = 0;
		NET_error(net, NET_E_CANT_ATTACH_SHM_SEG_NT);
		return;
	}
	NET_DBG(("NET_attach_shmem: MapViewOfFile NET_mem:0x%x\n",NET_mem));
#endif

	NET_DBG(("NET_attach_shmem: complete\n"));
}

/******************************************************************************/

extern void NET_dealloc_shmem(
	net_s			*net)
{
#if defined (unix)
	int				shmid;
	int				semid;
	int				error;
	int				count;
	struct shmid_ds	info;
	union semun arg;
#endif

	NET_DBG(("NET_dealloc_shmem(net:0x%x)\n", net));

#if defined (unix)
	/*
	**	Detach from shared memory.  If no processes are attached to
	**	shared memory, then remove the shared memory and the semaphore set.
	*/

	/*
	**	save shared memory id and sempahore set id
	*/
	shmid = NET_mem->shmid;
	semid = NET_mem->semid;

	/*
	**	detach from shared memory segment
	*/
	NET_DBG(("NET_dealloc_shmem:detaching from shared memory segment\n"));
	if (shmdt((char *)NET_mem) == -1)
	{
		NET_mem = 0;
		NET_error(net, NET_E_CANT_DETACH_SHM_SEG);
		return;
	}
	NET_mem = 0;

	/*
	**	check if there are any other processes attached
	**	to the segment
	*/

	NET_DBG(("NET_dealloc_shmem:check for other attached processes\n"));

	for(count = 0;
		!(error = shmctl(shmid,IPC_STAT,&info)) &&
		info.shm_nattch &&
		count < REMOVE_MEM_TIMEOUT;
		count++)
	{
		NET_DBG(("NET_dealloc_shmem:attach count:%d\n",
			info.shm_nattch));

		sleep(1);
	}
	if (!error && count != REMOVE_MEM_TIMEOUT)
	{
		/*
		**	deallocate the shared memory segment and the semaphore set
		*/
		arg.val = 0;
		NET_DBG(("NET_dealloc_shmem:remove semaphore set\n"));
		if (semctl(semid,0,IPC_RMID,arg) == -1)
		{
			NET_error(net, NET_E_CANT_REMOVE_SEM_SET);
			return;
		}
		NET_DBG(("NET_dealloc_shmem:remove shared memory segment\n"));
		if (shmctl(shmid,IPC_RMID,(struct shmid_ds *)0) == -1)
		{
			NET_error(net, NET_E_CANT_REMOVE_SHM_SEG);
			return;
		}
	}
#endif
#if defined(WIN32)
	if(!UnmapViewOfFile(NET_mem))
	{
		NET_mem = 0;
		NET_DBG(("NET_dealloc_shmem: UnmapViewOfFile error: %d\n",
				GetLastError()));
		NET_error(net, NET_E_CANT_DETACH_SHM_SEG);
		return;
	}
	NET_mem = 0;
#endif

	NET_DBG(("NET_dealloc_shmem: complete\n"));
}

/******************************************************************************/

extern void NET_detach_shmem(
	net_s			*net)
{
	NET_DBG(("NET_detach_shmem(net:0x%x)\n", net));

#if defined (unix)
	/*
	**	Detach from shared memory.
	*/
	if (shmdt((char *)NET_mem) == -1)
	{
		NET_mem = 0;
		NET_error(net, NET_E_CANT_DETACH_SHM_SEG);
		return;
	}
	NET_mem = 0;
#endif
#if defined(WIN32)
	if(!UnmapViewOfFile(NET_mem))
	{
		NET_mem = 0;
		NET_DBG(("NET_detach_shmem: UnmapViewOfFile error: %d\n",
				GetLastError()));
		NET_error(net, NET_E_CANT_DETACH_SHM_SEG);
		return;
	}
	NET_mem = 0;
#endif

	NET_DBG(("NET_detach_shmem: complete\n"));
}

/******************************************************************************/

#endif
