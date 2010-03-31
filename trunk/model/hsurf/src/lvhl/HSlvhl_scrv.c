
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:39 $
$Locker:  $
*/

#include <stdio.h>
#include <stdlib.h>
#include <FI.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "growner.h"
#include "godef.h"
#include "dpstruct.h"

#include "hstiler.h"
#include "hslight.h"
#include "hsdisplay.h"

#include "HStl_window.h"
#include "HStl_element.h"
#include "HSfem_spt.h"
#include "HSd_fixedpt.h"
#include "HSe2_mesher.h"

#include "HSplot.h"
#include "HSpr_lvhl.h"

/*
 *  make the max pool size 2 more than need.  2 for the header 
 *  plus whatever for the curves
 */
 
#define	MAX_POOL_SIZE	52

static	int	*pool = NULL;
static	int	*first_pool = NULL;
static	int	pool_index = 0;

/*---HSlvhl_init_curve_pool-----------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void	HSlvhl_init_curve_pool(void)
#else
	void	HSlvhl_init_curve_pool()
#endif

	{
	
	/*
	 *  If this is the first time, then the pool pointer will be
	 *  NULL.  malloc memory for the first pool buffer, sent the
	 *  number of entries (pool[0]) to 2, (must jump over the header),
	 *  and the next pool pointer (pool[1]) to NULL
	 *
	 *  If this is not the first time, then the first pool pointer
	 *  will not be null. Simply reset the counter to 2.  Dont
	 *  change the next index.
	 */
	 
	if( pool == NULL )
		{
		pool = (int *)malloc( MAX_POOL_SIZE * sizeof( int ) );
		
		pool[1] = NULL;
		
		first_pool = pool;
		}
		
	pool[0] = 2;
	}

/*---HSlvhl_add_curve_to_pool----------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void	HSlvhl_add_curve_to_pool( int objid )
#else
	void	HSlvhl_add_curve_to_pool( objid )

	int	objid;
#endif

	{

	/*
	 *  If the current pool is full, move to the next buffer.
	 *  if the next pool pointer, pool[1] is null then memory
	 *  will have to be allocated for the next buffer, else
	 *  simply set the pool pointer to the next and reset the
	 *  count to 2
	 */

	if( pool[0] == MAX_POOL_SIZE )
		{
		if( pool[1] == NULL )
			{
			pool[1] = (int)malloc( MAX_POOL_SIZE * sizeof( int ) );
		
			pool = (int *)pool[1];
			pool[1] = NULL;
			}
		else
			pool = (int *)pool[1];

		pool[0] = 2;
		}
		
	pool[pool[0]] = objid;
	pool[0]++;
	}

/*---HSlvhl_reset_curve_pool-----------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void	HSlvhl_reset_curve_pool(void)
#else
	void	HSlvhl_reset_curve_pool()
#endif

	{
	pool = first_pool;
	pool_index = 2;
	}

/*---HSlvhl_get_curve_from_pool---------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	int	HSlvhl_get_curve_from_pool(void)
#else
	int	HSlvhl_get_curve_from_pool()
#endif

	{
	int	curve;
	
	/*
	 *  if pool is NULL, then we have reached the end
	 *  of the list.  Return NULL to tell the caller to
	 *  stop
	 */
	 
	if( pool != NULL )
		{
			
		/*
		 *  get the next curve from the pool.  Move the
		 *  index. If you move past the last curve in the
		 *  current buffer (pool[0] not MAX_POOL_SIZE) then
		 *  get the next pool buffer and reset the pool_index
		 *  to 2
		 */

		curve = pool[pool_index++];
		
		if( pool_index >= pool[0] )
			{
			pool = (int *)pool[1];
			pool_index = 2;
			}

		return( curve );
		}
	else
		{
		return( NULL );
		}	
	}
