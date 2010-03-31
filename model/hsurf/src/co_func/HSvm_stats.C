
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:35 $
$Locker:  $
*/

#include <stdio.h>

#include "wl.h"

#include "OMprimitives.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "hskyoptypes.h"
#include "hsanimate.h"
#include "HSrle.h"
#include "HSsara.h"
#include "HSpr_co_func.h"

#define DEBUG 0

#if defined(__STDC__) || defined(__cplusplus)
	int HSget_vm_stats( unsigned long *total_virtual_mem,
			    unsigned long *used_virtual_mem,
			    unsigned long *physical_mem )
#else
	int HSget_vm_stats( total_virtual_mem, used_virtual_mem, physical_mem )

	unsigned long *total_virtual_mem, *used_virtual_mem, *physical_mem;
#endif

/*
NAME
	HSget_vm_stats

DESCRIPTION
	This function determines the amount of system virtual memory (physical + swap) and
	the total system memory used.

PARAMETERS
	total_virtual_mem (OUT) - the total virtual memory on the machine (can be NULL)
	used_virtual_mem (OUT) - the total amount of virtual memory currently being used (can be NULL)
	physical_mem (OUT) - the total physical memory on the machine (can be NULL)

GLOBALS USED
	none

RETURN VALUES
	1 - indicating success

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
	02/07/92    S.P. Rogers
	   Added physical_mem parameter
	03/16/92    S.P. Rogers
	   Changed to use om$get_mem_info macro
*/

	{
	int avail_swap_mem;
	int my_physical_mem;
	int my_total_virtual_mem;
	int my_used_virtual_mem;
	int total_swap_space;

	om$get_mem_info( p_avail_swap = &avail_swap_mem,
	                 p_total_swap = &total_swap_space,
	                 p_phys_mem   = &my_physical_mem );

#ifdef SUNOS || SUNOS5
	/* SUN doesn't seem to count physical memory in the amount */
	/* of virtual memory that can be allocated                 */
	my_total_virtual_mem = total_swap_space;
#else
	my_total_virtual_mem = my_physical_mem + total_swap_space;
#endif

	if ( total_virtual_mem )
	   *total_virtual_mem = my_total_virtual_mem;

	my_used_virtual_mem = my_total_virtual_mem - avail_swap_mem;

	if ( used_virtual_mem )
	   *used_virtual_mem = my_used_virtual_mem;

	if ( physical_mem )
	   *physical_mem = my_physical_mem;

#if DEBUG
	fprintf( stderr, "\n" );
	fprintf( stderr, "AVAIL-SWAP-MEM: %d\n", avail_swap_mem );
	fprintf( stderr, "TOTAL SWAP SPACE: %d\n", total_swap_space );
	fprintf( stderr, "TOTAL PHYSICAL MEM: %d\n", my_physical_mem );
	fprintf( stderr, "TOTAL VIRTUAL MEM: %d\n", my_total_virtual_mem );
	fprintf( stderr, "USED VIRTUAL MEMORY: %d\n", my_used_virtual_mem );
#endif
	
	return( 1 );

	}  /* HSget_vm_stats */

