#ifndef APdefinitions
#define APdefinitions

/* *****************************H H H H H******************************* */
/* Doc: APdef.h

   Abstract:
	
   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
      1991	?	2.0.0	Creation
      12-27-91	kk	2.0.0	Added #defines for APdisplay_flags

*/
/* *****************************H H H H H******************************* */


#define	MAX_EL_PTS	20 /* maximum number of points in an element */
#define MAX_ND_PER_FACE	8  /* maximum number of nodes in a 2d element */
#define MAX_EL_DRAW_PTS	31 /* maximum number of points used to draw element
				wireframe geometry */


/* these defines can be used as flags for operations which are common to
   nodes and elements -- such as uid operations */
#define NODE		0
#define ELEM		1
#define NO_UID		0
#define DEFAULT_UID	-1

/* --- element type definitions --- */
#define NUM_ELTYPE	12		/* number of element types */
#define LINE2		0		/* 2 node line element */
#define LINE3		1		/* 3 node line element */
#define TRI3		2		/* 3 node tri element */
#define TRI6		3		/* 6 node tri element */
#define QUAD4		4		/* 4 node quad element */
#define QUAD8		5		/* 8 node quad element */
#define TET4		6		/* 4 node tetra element */
#define TET10		7		/* 10 node tetra element */
#define WED6		8		/* 6 node wedge element */
#define WED15		9		/* 15 node wedge element */
#define BRK8		10		/* 8 node brick element */
#define BRK20		11		/* 20 node brick element */
#define NON_ELEM	12		/* here or greater is not an elem */

/* --- node type definitions --- */
/* NOTE: number used for type (except single) corresponds to geom dimension */
#define	VERTEX		0	/* 0d geom */
#define	EDGE		1	/* 1d geom */
#define FACE		2	/* 2d geom */
#define	SOLID		3	/* 3d geom */
#define	SINGLE		10

/*
 *  Element order.
 */
#define  LINEAR     1
#define  QUADRATIC  2

/*
 *  Element shape.
 */
#define  LINE       0
#define  TRI        1
#define  QUAD       2
#define  BRICK      3
#define  WEDGE      4
#define  TETRA      5

/* --- Neutral File Element Shape Definitions --- */

#define EL_LINE		2
#define EL_TRI		3
#define EL_QUAD		4
#define EL_TETRA	5
#define	EL_UNUSED	6
#define EL_WEDGE	7
#define EL_BRICK	8

/*
 *  Element dimension.
 */
#define  ONE_D      1
#define  TWO_D      2
#define  THREE_D    3

/* --- bits for defining the dimension mask --- */

#define AP_1D_TYPE	0x01
#define AP_2D_TYPE	0x02
#define AP_3D_TYPE	0x04
#define AP_ALL_D_TYPE	0x07

/* --- mesh type - define element dimensions on a mesh object --- */

#define AP_MESH_NODE_GRP	0
#define AP_MESH_EL1D		1
#define AP_MESH_EL2D		2
#define AP_MESH_EL3D		3
#define AP_MESH_ALL_D		4
#define AP_MESH_ELFACE		5

/* --- Reduce verbosity  --- */

#define VFP	if(VERBOSE)fprintf(stderr,
#define FP	fprintf(stderr,
#define FOR(i,start,high)	for ( i = start; i < high; i++ )
#define MSG sts = om$send ( msg = message 
#define MSG1 sts1 = om$send ( msg = message 
#define TO targetid = 

/* --- Flags for APdisplay_flags extern variable
	and APdpb.display_flags instance data  --- */

#define AP_ERASE_NODES		0x01
#define AP_ERASE_ELEMENTS	0x02
#define AP_ERASE_MATPROP	0x04
#define AP_ERASE_BNDRY_COND	0x08
#define AP_ERASE_POST_GRX	0x10

/* ---  General #defines  --- */

#define	AP_UNDEFINED_DBL	-1.E100	/* Undefined double value		*/

/* --- define options for node and element init --- */

#define APinit_dont_add_rtree	0x01	/* don't add element to rtree */
#define APinit_dont_display	0x02	/* don't display element */
#define APinit_dont_save_uid	0x04	/* don't save uid in Btree */

/* To find the corresponding low-order element type for any
   element type, just truncate odd numbers to even by turning
   off the lowest bit. 'And 254' keeps on bits 1111 1110. */
	/* watch out for this whenever #define changes */
#define LOW_ELEMENT(type) (type&254)

#endif
