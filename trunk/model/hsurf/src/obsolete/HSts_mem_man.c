
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:34 $
$Locker:  $
*/

#include "hsurf_import.h"

#include "stdio.h"

#include "values.h"
#include "tools.h"

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"

#include "HStl_element.h"
#include "HStl_window.h"
#include "HStessel.h"

#include "hsmemory.h"
#include "hsdisplay.h"
#include "hrmem.h"
#include "hrstruct.h"

#define HR_2K            2048
#define HR_4K            5096
#define HR_60K           61440

struct	HSpool_list_node {

	struct	HSshd_vertex		*start_addr;
	struct	HSpool_list_node	*next;
};

/* static global data for pool memory managment */
static struct HSpool_list_node  *vert_pool_list = 0;
static struct HSpool_list_node  *bust_pool_list = 0;
static unsigned int		num_vertices, num_busts;
static struct HSpool_list_node	*first_vert_pool_node = 0;
static struct HSpool_list_node	*first_bust_pool_node = 0;
static struct HSshd_vertex	*primary_vert_start_addr = 0;
static struct HSshd_vertex	*primary_bust_start_addr = 0;
static struct HSshd_vertex	*temp_vert_start_addr, *temp_bust_start_addr;

/*---- HSinit_pool_memory_management ------------------------------------------*/

void HSinit_pool_memory_management(which_pool_list)

int	which_pool_list;

/*
DESCRIPTION
	Initialize the global data used by the memory management macros

HISTORY
	S.P. Rogers  07/07/89  Creation Date
*/

{

	switch (which_pool_list) {

	case	VERT_LIST:

		if (!first_vert_pool_node) vert_pool_list = first_vert_pool_node = NULL;
		else {
			vert_pool_list = first_vert_pool_node;
			first_vert_pool_node->start_addr = temp_vert_start_addr = primary_vert_start_addr;
			vert_pool_list->next = NULL;
		}
		num_vertices = 0;
		break;

	case	BUST_LIST:

		if (!first_bust_pool_node) bust_pool_list = first_bust_pool_node = NULL;
		else {
			bust_pool_list = first_bust_pool_node;
			first_bust_pool_node->start_addr = temp_bust_start_addr = primary_bust_start_addr;
			bust_pool_list->next = NULL;
		}
		num_busts = 0;
		break;
	}

}  /* HSinit_pool_memory_management */
		


/*---- HSfree_pool_memory ------------------------------------------------------*/

void HSfree_pool_memory()


/*
DESCRIPTION
	Deallocate all of the memory that is in all of the pools used
	by the polybuster/triangulator

HISTORY
	S.P. Rogers  07/07/89  Creation Date
	M.R. Giesy   06/11/90  Modified for use with polybuster/triangulator
*/
{
	struct HSpool_list_node *cur_node;
	struct HSpool_list_node *temp;

	/* free the allocated vert memory pools */
	cur_node = first_vert_pool_node->next;
	while ( cur_node )
	{
		temp = cur_node->next;
		free( cur_node->start_addr );
		free( cur_node );
		cur_node = temp;
	}

	/* free the allocated bust memory pools */
	cur_node = first_bust_pool_node->next;
	while ( cur_node )
	{
		temp = cur_node->next;
		free( cur_node->start_addr );
		free( cur_node );
		cur_node = temp;
	}

}  /* HSfree_pool_memory */

/***********************************************************************************/

	/* GENERIC POOL MEMORY ALLOCATION/DEALLOCATION ROUTINES */
	

/*------ HSalloc_struct_from_pool --------------------------------------------*/

IGRchar *HSalloc_struct_from_pool(which_pool_list)

int	which_pool_list;
{
	

	switch (which_pool_list) {

	case VERT_LIST:

		if (!vert_pool_list)
		{
			vert_pool_list = (struct HSpool_list_node *) malloc(sizeof(struct HSpool_list_node));
			vert_pool_list->start_addr = (struct HSshd_vertex *) malloc(HR_4K);
			first_vert_pool_node = vert_pool_list;
			first_vert_pool_node->next = NULL;
			primary_vert_start_addr = temp_vert_start_addr = first_vert_pool_node->start_addr;
			num_vertices = 0;
		}
		if (num_vertices < VERTS_PER_EXTENT)
		{
			num_vertices++;
			temp_vert_start_addr++;
		}
		else {
			num_vertices = 0;
			vert_pool_list->next = (struct HSpool_list_node *) malloc(sizeof(struct HSpool_list_node));
			vert_pool_list = vert_pool_list->next;
			vert_pool_list->next = NULL;
			vert_pool_list->start_addr = (struct HSshd_vertex *) malloc(HR_4K);
			temp_vert_start_addr = vert_pool_list->start_addr;
		}
	   
		return( (IGRchar *) temp_vert_start_addr );

	case BUST_LIST:

		if (!bust_pool_list)
		{
			bust_pool_list = (struct HSpool_list_node *) malloc(sizeof(struct HSpool_list_node));
			bust_pool_list->start_addr = (struct HSshd_vertex *) malloc(HR_4K);
			first_bust_pool_node = bust_pool_list;
			first_bust_pool_node->next = NULL;
			primary_bust_start_addr = temp_bust_start_addr = first_bust_pool_node->start_addr;
			num_busts = 0;
		}
		if (num_busts < VERTS_PER_EXTENT)
		{
			num_busts++;
			temp_bust_start_addr++;
		}
		else {
			num_busts = 0;
			bust_pool_list->next = (struct HSpool_list_node *) malloc(sizeof(struct HSpool_list_node));
			bust_pool_list = bust_pool_list->next;
			bust_pool_list->next = NULL;
			bust_pool_list->start_addr = (struct HSshd_vertex *) malloc(HR_4K);
			temp_bust_start_addr = bust_pool_list->start_addr;
		}
	   
		return( (IGRchar *) temp_bust_start_addr );
	}

}  /* HSalloc_struct_from_pool */
