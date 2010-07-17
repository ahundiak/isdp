/*
	I/STRUCT
*/
#ifndef vsedge_include
#	define vsedge_include

/*
 * Edges type for macro 'vs$get_surface_edges'.
 *
 *		   1
 *	-------------------------
 *	\	   6		|
 *     2 \	---------	|
 *	  \    7|	|9	| 5
 *	  /	---------	|
 *     3 /	   8		|
 *	/			|
 *     --------------------------
 *		   4
 */
#define VS_K_ALL_EDGES		0	/* All edges ( #1 -> #9 ).	      */
#define VS_K_CONTOUR_EDGES	1	/* All contour edges ( #1 -> #5 ).    */
#define VS_K_INSIDE_EDGES	2	/* All inside edges ( #6 -> #9 ).     */

#endif
