#ifndef MHsetmac_included
#define MHsetmac_included

#include "applimits.h"

/* This include file defines macros for use with node and element sets */

/*-------------------------------------------------------------------------*/
/* Doc: fe$create_set

   Abstract:
   	This macro will construct a set object by name and 
	add a list of nodes or elements to the set.
	
   Arguments:
	char		*name		i - set name

	char		delete_existing	i - if TRUE, delete any existing set
					    with the same name

	struct GRid	*elnd_grids	i - (opt) elem or node GRid's to add to set

	int		num_elnd	i - number of nodes or elements to add

	struct GRid	*set_grid	o - GRid of set which was constructed

   Return Status:
	1	-	SUCCESS

   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
				Creation

*/
/* *****************************H H H H H******************************* */

extern long MHcreate_set();

#omdef	fe$create_set ( name,
			delete_existing = FALSE,
			elnd_grids = NULL,
			num_elnd,
			set_grid )

	MHcreate_set( name, delete_existing, elnd_grids, num_elnd, set_grid )
#endomdef

/*-------------------------------------------------------------------------*/
/* Doc: fe$add_to_set

   Abstract:
	This macro adds a list of nodes or elements to a set.

   Arguments:
	char		*name		i - set name

	struct GRid	*set_grid	i - GRid of set. Either name or
				     	    set_grid must be specified

	struct GRid	*elnd_grids	i - (opt) elem or node GRid's to add to set

	int		num_elnd	i - number of nodes or elements to add

   Return Status:
	1	-	SUCCESS

   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
				Creation

*/
/* *****************************H H H H H******************************* */

extern long MHadd_to_set();

#omdef	fe$add_to_set (	name = NULL ^ 
			set_grid = NULL,
			elnd_grids,
			num_elnd )

	MHadd_to_set( set_grid, name, elnd_grids, num_elnd )
#endomdef

/*-------------------------------------------------------------------------*/
/* Doc: fe$setname_to_grid

   Abstract:
	This macro finds the set GRid given a set name.

   Arguments:
	char		*name		i - set name

	struct GRid	*set_grid	o - GRid of set

   Return Status:
	OM_S_SUCCESS 		- if set was found (OMerrordef.h)

	AP_e_SETNOTFOUND 	- if set not found (APerrordef.h)

   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
				Creation
*/
/* *****************************H H H H H******************************* */

extern long MHsetname_to_grid();

#omdef	fe$setname_to_grid( name,
			    set_grid )

	MHsetname_to_grid( name, set_grid )
#endomdef

/*-------------------------------------------------------------------------*/
/* Doc: fe$setgrid_to_name

   Abstract:
	This macro finds the set name given a set GRid.
	The name is assumed to be no longer than AP_MAX_NAME_LEN ( applimits.h )

   Arguments:
	struct GRid	*set_grid	i - GRid of set

	int		maxchar		i - max number of characters for name
					    output

	char		*name		o - set name

   Return Status:
	1	-	SUCCESS

   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
				Creation

*/
/* *****************************H H H H H******************************* */

extern long MHsetgrid_to_name();

#omdef	fe$setgrid_to_name( set_grid,
			    maxchar = AP_MAX_NAME_LEN,
			    name )

	MHsetgrid_to_name( set_grid, maxchar, name )
#endomdef

/*-------------------------------------------------------------------------*/
/* Doc: fe$get_set_count

   Abstract:
	This macro finds the number of objects connected to a set object

   Arguments:
	char		*name		i - set name

	struct GRid	*set_grid	i - GRid of set. Either name or 
				    	    set_grid must be specified

	int		*count		o - number of objects connected to set

   Return Status:
	OM_S_SUCCESS 		- if set was found (OMerrordef.h)

	AP_e_SETNOTFOUND 	- if set not found (APerrordef.h)

   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
				Creation

*/
/* *****************************H H H H H******************************* */

extern long MHset_count ();

#omdef	fe$get_set_count ( name = NULL ^ 
			   set_grid = NULL,
			   count )

	MHset_count( set_grid, name, count )
#endomdef

#endif
