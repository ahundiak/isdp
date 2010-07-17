// -----------------------------------------------------------------------------
//      Class    :      VLpinjig.S
//
//      Abstract :      Store data corresponding to a I/LOFT pin-jigs'
//			intersections with with the floor
//
//      History  :      Created 18-NOV-1993     Marc FOURNIER
//                      Updated 11-APR-1994     Marc FOURNIER
// -----------------------------------------------------------------------------

class specification VLpinjig(0:0) of VLabstract;

/* Class construction method */
override	ACconstruct_feet;

override	VDgetObjDef;

/* Scattered data access */
/* ========================================================================== */
/*
	This method is a multi-purpose data access.

Arguments :
---------
	IGRlong		*msg	OUTPUT	: Completion code
	IGRint		*idx	INPUT	: Index of pinjig wanted.
					  NULL if info on all pinjigs wanted.
	IGRint		*npin	OUTPUT	: Number of pinjig. NULL if not wanted.
	IGRboolean	format	INPUT	: Option used if <idx> != NULL to
					  format <attr>, adding pinjig index to
					  unformated attribute name.
					  If <idx> == NULL then <format> = TRUE.
struct	ACrg_coll	*attr	OUTPUT	: Pinjig(s) attributes collection.
					  If <idx> != NULL must be allocated to
					  attr[IDX_PB_MAX].
					  If <idx> == NULL must be allocated to
					  attr[IDX_PB_MAX * (*npin)].
					  Can be NULL if not wanted.
struct	ACrg_coll	*glob	OUTPUT	: Global attributes collection,
					  containing H1V1 position.
					  Can be NULL if not wanted.
					  If not NULL must be allocated to
					  glob[IDX_PB_MAX].

Examples :
--------

1) To get pinjigs number :
	....VLget_attributes ( &msg, NULL, &npin, TRUE, NULL, NULL),
		--> format can be TRUE or FALSE, no matter.

2) To get all pinjigs attributes :
	....VLget_attributes ( &msg, NULL, NULL, TRUE, attr, NULL),
		--> format can be TRUE or FALSE, no matter.
		--> attr[IDX_PB_MAX * npin], where npin comes from 1).

3) To get global attributes of pinjig macro :
	....VLget_attributes ( &msg, NULL, NULL, TRUE, NULL, &glob),
		--> format can be TRUE or FALSE, no matter.

4) To get pinjig number N attributes unformated collection :
	....VLget_attributes ( &msg, &N, NULL, FALSE, &attr, NULL),
		--> attr[IDX_PB_MAX] is the allocation.

5) To get pinjig number N attributes formated collection :
	....VLget_attributes ( &msg, &N, NULL, TRUE, &attr, NULL),
		--> attr[IDX_PB_MAX] is the allocation.

	Except 1) and 2) (you need <npin> to allocate <attr>), you can
	combine 1|2, 3, 4, 5.
*/

message		VLget_attributes (		IGRlong		*msg;
						IGRint		*idx;
						IGRint		*npin;
						IGRboolean	format;
					struct	ACrg_coll	*attr;
					struct	ACrg_coll	*glob	);
/* ========================================================================== */

end specification VLpinjig;
