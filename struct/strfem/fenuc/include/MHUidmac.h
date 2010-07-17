#ifndef MHUIDmacros_include
#define MHUIDmacros_include

#include "APdef.h"

/*----------------------------------------------------------------------------*/
/* Doc: fe$opt_bandwidth

   Abstract:
	This macro will optimize the node Uids based on bandwidth

   Arguments:
	long	max_iter	 i - max iter. to find start

	IGRint	*msg		 o - return status

	IGRlong	*num_of_nodes	 o - number of nodes

   Return Status:
	1	-	SUCCESS

   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
				Creation

*/
/* *****************************H H H H H******************************* */

extern long MHopt_bandwidth ();

#omdef	fe$opt_bandwidth( msg, 
			  num_of_nodes, 
			  max_iter = 10 )

	MHopt_bandwidth ( (msg), (num_of_nodes), (max_iter ) )

#endomdef

/*----------------------------------------------------------------------------*/
/* Doc: fe$opt_wavefront

   Abstract:
	This macro will optimize the element Uids based on wavefront

   Arguments:
	long	max_iter	 i - max iter. to find start

	IGRint	*msg		 o - return status

	IGRlong	*num_of_elems	 o - number of elems

   Return Status:
	1	-	SUCCESS

   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
				Creation

*/
/* *****************************H H H H H******************************* */

extern long MHopt_wavefront ();

#omdef	fe$opt_wavefront( msg, 
			  num_of_elems, 
			  max_iter = 10 )

	MHopt_wavefront ( (msg), (num_of_elems), (max_iter ) )

#endomdef

/*----------------------------------------------------------------------------*/
/* Doc: fe$compress_uids

   Abstract:
	This macro will compress node or element Uids

   Arguments:
	long	ndel		 i - NODE or ELEM as in APdef.h

	long	uid_start	 i - Starting uid

	long	uid_step	 i - Uid step

   Return Status:
	1	-	SUCCESS

   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
				Creation

*/
/* *****************************H H H H H******************************* */

extern long MHcompress_uids ();

#omdef	fe$compress_uids( ndel, 
			  uid_start = 1, 
			  uid_step = 1 )

	MHcompress_uids ( (ndel), (uid_start), (uid_step) )

#endomdef

/*----------------------------------------------------------------------------*/
/* Doc: fe$renumber_uids

   Abstract:
	This macro will renumber node or element Uids

   Arguments:
	long		ndel	 	i - NODE or ELEM as in APdef.h

	struct GRid	*grids		i - Grids to change Uids

	long		uid_count	i - Number of Uids to change

	long		uid_start	i - Starting uid

	long		uid_step	i - Uid step

	long		*uids		i - Uids in renumber order (optional)

   Return Status:
	1	-	SUCCESS

   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
				Creation
*/
/* *****************************H H H H H******************************* */

extern long MHrenumber_uids ();

#omdef	fe$renumber_uids( ndel, 
			  grids, 
			  uid_count, 
			  uid_start = 1, 
			  uid_step = 1, 
			  uids = NULL )

	MHrenumber_uids ( (ndel), (grids), (uid_count), (uid_start), (uid_step), (uids) )

#endomdef

#endif
