#ifndef APUidmacros
#define APUidmacros

/* prototypes for all functions below */

extern long APgetUidDefaults();
extern long APUidAvail();
extern long APsaveUid();
extern long APsetUidDefaults();
extern long APsetUidMax();

/* *****************************H H H H H******************************* */
/* Doc: fe$next_uid

   Abstract: 
   	This macro returns next avail (default) uid.

   Arguments: 
	long	ndel		i - NODE or ELEM as in APdef.h

	long	*next		o - next avail (default) uid

   Return Status:
	1	-	SUCCESS

	0	-	ERROR

   Examples:

   History:

	Date		Who	Version	Why
	---------	---	-------	---------
	20 Jan 93	ret	2.2.0	ANSI port

*/

/* *****************************H H H H H******************************* */

#omdef	fe$next_uid( ndel, 
		     next )

	APgetUidDefaults(ndel,NULL,NULL,next);

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$uid_available

   Abstract: 
   	This macro determines if range (lo..hi) is available (not in tree).

   Arguments:
	long	ndel		i - NODE or ELEM as in APdef.h

	long	lo		i - low Uid in the target list

	long	hi		i - hi Uid in the target list

   Return Status:
	1	-	the range is free

	0	-	at least one Uid in the range is in the tree

   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
				Creation

*/
/* *****************************H H H H H******************************* */

#omdef	fe$uid_available( ndel, 
			  lo, 
			  hi = NULL )

	APUidAvail( (ndel), (lo), (hi) )

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$set_max_uid

   Abstract: 
   	This macro sets default max uid.

   Arguments:
	long	ndel		i - NODE or ELEM as in APdef.h

	long	max		i - max uid

   Return Status:
	1	-	SUCCESS

	0	-	ERROR

   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
				Creation

*/
/* *****************************H H H H H******************************* */

#omdef	fe$set_max_uid( ndel, 
			max = NULL )

	APsetUidMax( (ndel), (max) )

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$set_uid_defaults

   Abstract: 
   	This macro sets default next uid and uid increment.

   Arguments:
	long	ndel		i - NODE or ELEM as in APdef.h

	long	next		i - next uid ("default") ( NULL to keep current default )
					  
	long	incr		i - uid increment ( NULL to keep current default )
					  
	long	*next_avail	o - next uid available ( NULL if you don't want to know )
					  
   Return Status:
	1	-	SUCCESS

	0	-	ERROR

   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
				Creation

*/
/* *****************************H H H H H******************************* */

#omdef	fe$set_uid_defaults( ndel, 
			     next = NULL, 
			     incr = NULL, 
			     next_avail = NULL )

	APsetUidDefaults( (ndel), (next), (incr), (next_avail) )

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$get_uid_defaults

   Abstract: 
   	This macro gets defaults - max uid, next uid, and uid increment.

   Arguments:
	long	ndel		i - NODE or ELEM as in APdef.h

	long	*max		o - Max uid in tree

	long	*incr		o - uid increment

	long	*next		o - next uid

   Return Status:
	1	-	SUCCESS

	0	-	ERROR

   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
				Creation

*/
/* *****************************H H H H H******************************* */

#omdef	fe$get_uid_defaults( ndel, 
			     max = NULL, 
			     incr = NULL, 
			     next = NULL )

	APgetUidDefaults( (ndel), (max), (incr), (next) )

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$save_uid

   Abstract: 
   	This macro returns next avail (default) uid.

   Arguments:
	long	ndel		i - NODE or ELEM as in APdef.h

	long	uid		i - uid to be saved in tree (in use)

   Return Status:
	1	-	SUCCESS

	0	-	ERROR

   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
				Creation

*/
/* *****************************H H H H H******************************* */

#omdef	fe$save_uid( ndel, 
		     uid )

	APsaveUid( ndel, uid )

#endomdef

#endif
