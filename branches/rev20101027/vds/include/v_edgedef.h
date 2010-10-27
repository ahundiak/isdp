/*
	I/VDS	Copy
*/
#ifndef v_edge_include
#	define v_edge_include

/*
 * Edges type for macro 'vd_$get_surface_edges'.
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
#define VD_K_ALL_EDGES		0	/* All edges ( #1 -> #9 ).	      */
#define VD_K_CONTOUR_EDGES	1	/* All contour edges ( #1 -> #5 ).    */
#define VD_K_INSIDE_EDGES	2	/* All inside edges ( #6 -> #9 ).     */





/*
 * The graphical components of an objects can be get by predefined input.
 * Given an object and a criteria, the macro vd_$select_obj_comps() returns
 * a list of id of the object. Depending on the criteria, only these graphical
 * elements are given back in the list.
 */

#define         VD_K_gm_TEXT                    0x00000001
#define         VD_K_gm_POINT                   0x00000010
#define         VD_K_gm_WIREFRAME               0x00000100
#define         VD_K_gm_SURFACE                 0x00001000
#define         VD_K_gm_SOLIDS                  0x00010000

#define         VD_K_gm_ALL                     0x00011111
#define		VD_K_gm_SdSfWf			0x00011100
#define		VD_K_gm_SdSf			0x00011000

#endif
