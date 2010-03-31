
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/


/*
DESCRIPTION
	Structure definitions used by the HSURF rendering memory 
	management routines

HISTORY
	S.P. Rogers  07/07/89  Creation Date
*/


/* linked-list structure to keep track of the starting addresses of all */
/* the memory pools that have been allocated                            */
struct HRpool_list_node
	{
	IGRchar                 *start_addr;
	IGRshort                zbuffer_pool;
	struct HRpool_list_node *next;
	};


/* structure used to manage pool memory allocation */
struct HRpool_mem_data
	{
	IGRint     structs_per_pool;  /* number of structures to allocate per pool       */
	IGRint     struct_size;       /* the size of the structure                       */
	IGRint     left_in_pool;      /* the number of structures left in the pool       */
	IGRboolean restrict_growth;   /* TRUE, if HIGH water mark should be checked      */
	IGRchar    *free_list;        /* linked-list of free structures                  */
	IGRchar    *pool;             /* pointer to the first free structure in the pool */
	IGRint     total_malloced;    /* number of structures malloced for pools         */
	IGRint     pool_allocs;       /* number of structures allocated from the pool    */
	IGRint     list_allocs;       /* number of structures allocated from free list   */
	IGRint     frees;             /* number of structures that have been freed       */
	};
