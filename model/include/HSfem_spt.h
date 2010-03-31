
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:57 $
$Locker:  $
*/

#ifndef HSfem_spt_include
#define HSfem_spt_include 1
/*
 * This file contains temporary support of FEM shading.  It contains
 * definitions.
 */

#define IGRFE	22
#define IGRFM	23

struct IGResfct		/* FEM contour tile: type = IGRFE (22) */
{
short		n_mid;
IGRshort	*color_shade;
};

struct fem_vert			/* structure for vertices for FEM vertice */
{float 		x, y, z;
};

struct fem_color		/* structure for colors for FEM vertice */
{float 		red, green, blue;
};

struct HSfem_tri_mesh		/* FEM triangular mesh: type = IGRFM (23) */
{
IGRint 			num_verts;	/* number of vertices in mesh */
struct fem_vert		*verts;  	/* list of vertices */
struct fem_color	*colors;  	/* list of colors for vertices or
	        			facets */

IGRboolean	area_fill;	/* set to true if mesh has one 
				   color per facet (all vertices 
				   same index),false if one color
				   per vertex */
};


#endif
