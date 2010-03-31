
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:42 $
$Locker:  $
*/

#include <stdio.h>
#include <stdlib.h>

#include "wl.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"

#include "hstiler.h"
#include "hslight.h"

#include "HStl_global.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HSfem_spt.h"

#include "HSe2_mesher.h"
#include "hsdisplay.h"
#include "HSpr_tiler_f.h"


static int	xmin, xmax;

/*---HSreset_plotting_xrange-------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void	HSreset_plotting_xrange(void)
#else
	void	HSreset_plotting_xrange()
#endif

	{
	xmin = 0x7fffffff;
	xmax = -xmin;
	}
	
/*---HSfetch_plotting_xrange-------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void	HSfetch_plotting_xrange( int *x1, int *x2 )
#else
	void	HSfetch_plotting_xrange( x1, x2 )

	int	*x1, *x2;
#endif

	{
	*x1 = xmin;
	*x2 = xmax;
	}
	
/*--- transform_points ------------------------------------------------------*/

/*
 * Transforms an array of points from world coordinates to normalized
 * coordinates using the matrix of the active window.
 *
 * HISTORY: 01/06/87 created					S. A. Rapa
 */

#if defined(__STDC__) || defined(__cplusplus)
	void	transform_points( IGRint perspective, 
				  IGRint num_pts, 
			       IGRdouble *points, 
			          IGRint w_offset )
#else
	void	transform_points( perspective, num_pts, points, w_offset )
	
	IGRint		perspective;
	IGRint		num_pts;
	IGRdouble	*points;
	IGRint		w_offset;
#endif

	{
	IGRlong	cnt;
	IGRdouble	new_x, new_y, new_z;
	IGRdouble	*w;
	double		xs;
	double		p;

	if( perspective )
		{
			
		/*
		 * W's are stored in the array of surface points, after the
		 * 3D coordinates and normals.
		 */

		w = points + (3 * w_offset);
	
		for (cnt = 0; cnt < num_pts; cnt++)
			{
			new_x = (active_window->transform_matrix[0][0] * points[0]) +
				(active_window->transform_matrix[0][1] * points[1]) +
				(active_window->transform_matrix[0][2] * points[2]) +
				(active_window->transform_matrix[0][3]);
			new_y = (active_window->transform_matrix[1][0] * points[0]) +
				(active_window->transform_matrix[1][1] * points[1]) +
				(active_window->transform_matrix[1][2] * points[2]) +
				(active_window->transform_matrix[1][3]);
			new_z = (active_window->transform_matrix[2][0] * points[0]) +
				(active_window->transform_matrix[2][1] * points[1]) +
				(active_window->transform_matrix[2][2] * points[2]) +
				(active_window->transform_matrix[2][3]);
			*w++  = (active_window->transform_matrix[3][0] * points[0]) +
				(active_window->transform_matrix[3][1] * points[1]) +
				(active_window->transform_matrix[3][2] * points[2]) +
				(active_window->transform_matrix[3][3]);

			*points++ = new_x;
			*points++ = new_y;
			*points++ = new_z;
			
xs = (active_window->dit_clip_range[3] - active_window->dit_clip_range[0]) * 0.5;
p = ((new_x / w[-1]) + 1.0) * xs;
			
			if( (int)p > xmax ) xmax = (int)p;
			if( (int)p < xmin ) xmin = (int)p;
			}
		}

	else
		for( cnt=0; cnt<num_pts; cnt++ )
			{
			new_x = (active_window->transform_matrix[0][0] * points[0]) +
				(active_window->transform_matrix[0][1] * points[1]) +
				(active_window->transform_matrix[0][2] * points[2]) +
				(active_window->transform_matrix[0][3]);
			new_y = (active_window->transform_matrix[1][0] * points[0]) +
				(active_window->transform_matrix[1][1] * points[1]) +
				(active_window->transform_matrix[1][2] * points[2]) +
				(active_window->transform_matrix[1][3]);
			new_z = (active_window->transform_matrix[2][0] * points[0]) +
				(active_window->transform_matrix[2][1] * points[1]) +
				(active_window->transform_matrix[2][2] * points[2]) +
				(active_window->transform_matrix[2][3]);

			*points++ = new_x;
			*points++ = new_y;
			*points++ = new_z;
			
			if( (int)new_x > xmax ) xmax = (int)new_x;
			if( (int)new_x < xmin ) xmin = (int)new_x;
			}
	}


/*-- HSfem_transform --------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSfem_transform( struct HSfem_tri_mesh *mesh )
#else
	void HSfem_transform(mesh)

	struct HSfem_tri_mesh		*mesh;
#endif

/*
 * Transforms an array of points in the new FEM triangular mesh from
 * world coordinates into normalized coordinates that can be used by
 * the tiler. Needed due to the fact that the triangular mesh uses floats
 * rather than doubles, and that they are referenced by x, y, and z fields.
 *
 * HISTORY: 09/16/91 created				R. Druzynski
 */

{
 float	new_x, new_y, new_z;
 int	i;

 for( i = 0; i < mesh->num_verts; i++ )
	{
		new_x = (active_window->transform_matrix[0][0] * mesh->verts[i].x) +
			(active_window->transform_matrix[0][1] * mesh->verts[i].y) +
			(active_window->transform_matrix[0][2] * mesh->verts[i].z) +
			(active_window->transform_matrix[0][3]);

		new_y = (active_window->transform_matrix[1][0] * mesh->verts[i].x) +
			(active_window->transform_matrix[1][1] * mesh->verts[i].y) +
			(active_window->transform_matrix[1][2] * mesh->verts[i].z) +
			(active_window->transform_matrix[1][3]);

		new_z = (active_window->transform_matrix[2][0] * mesh->verts[i].x) +
			(active_window->transform_matrix[2][1] * mesh->verts[i].y) +
			(active_window->transform_matrix[2][2] * mesh->verts[i].z) +
			(active_window->transform_matrix[2][3]);

		mesh->verts[i].x = new_x;
		mesh->verts[i].y = new_y;
		mesh->verts[i].z = new_z;


		if( (int)new_x > xmax ) xmax = (int)new_x;
		if( (int)new_x < xmin ) xmin = (int)new_x;
	 }

}

/*-- rotate_normals ---------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void	rotate_normals( IGRint num_vecs, IGRdouble *vectors )
#else
	void	rotate_normals( num_vecs, vectors )

	IGRint		num_vecs;
	IGRdouble	*vectors;
#endif

/*
 * Rotates an array of vectors from world coordinates into view-aligned
 * coordinates using the rotation matrix of the active window.
 *
 * HISTORY: 01/07/87 created.				S. A. Rapa
 */

	{	
	IGRlong	cnt;
	IGRdouble	new_x, new_y, new_z;

	for( cnt=0; cnt<num_vecs; cnt++)
		{
		new_x = (active_window->rotate_matrix[0][0] * vectors[0]) +
			(active_window->rotate_matrix[0][1] * vectors[1]) +
			(active_window->rotate_matrix[0][2] * vectors[2]);
		new_y = (active_window->rotate_matrix[1][0] * vectors[0]) +
			(active_window->rotate_matrix[1][1] * vectors[1]) +
			(active_window->rotate_matrix[1][2] * vectors[2]);
		new_z = (active_window->rotate_matrix[2][0] * vectors[0]) +
			(active_window->rotate_matrix[2][1] * vectors[1]) +
			(active_window->rotate_matrix[2][2] * vectors[2]);

		*vectors++ = new_x;
		*vectors++ = new_y;
		*vectors++ = new_z;
		}
	}

/*---HSUnRotateVectors-------------------------------------------------------------*/


/*
 *
 * HSUnRotateVectors() rotates an array of vectors from view-aligned coordinates to
 * world coordinates using the transpose of the rotation matrix of the active window.
 *
 * HISTORY: 07/18/89	Created.
 *								Trevor Mink
 */

#if defined(__STDC__) || defined(__cplusplus)
	void HSUnRotateVectors( int num_vecs, double *vectors )
#else
	void HSUnRotateVectors( num_vecs, vectors )
	int num_vecs;
	double *vectors;
#endif

{
	long cnt;
	double new_x, new_y, new_z;

	for( cnt=0; cnt<num_vecs; cnt++ ) {
		new_x = (active_window->rotate_matrix[0][0] * vectors[0]) +
			(active_window->rotate_matrix[1][0] * vectors[1]) +
			(active_window->rotate_matrix[2][0] * vectors[2]);
		new_y = (active_window->rotate_matrix[0][1] * vectors[0]) +
			(active_window->rotate_matrix[1][1] * vectors[1]) +
			(active_window->rotate_matrix[2][1] * vectors[2]);
		new_z = (active_window->rotate_matrix[0][2] * vectors[0]) +
			(active_window->rotate_matrix[1][2] * vectors[1]) +
			(active_window->rotate_matrix[2][2] * vectors[2]);

		*vectors++ = new_x;
		*vectors++ = new_y;
		*vectors++ = new_z;
	}
} /* HSUnRotateVectors() */


#ifndef MICROCODE
/*--- scale_facet_point ----------------------------------------------------*/


/*
 * Scales a point from normalized coordinates into view-aligned coordinates
 * by dividing by the non-uniform perspective scale factors of the active
 * window.
 *
 * HISTORY: 12/13/89 Created.					C. M. Jablonski
 */

#if defined(__STDC__) || defined(__cplusplus)
	void	scale_facet_point( IGRdouble *point )
#else
	void	scale_facet_point( point )

	IGRdouble	*point;
#endif

	{
	point[0] /= active_window->persp_x_scale;
	point[1] /= active_window->persp_y_scale;
	point[2] /= active_window->persp_z_scale;
	}
#endif


/*-- perspective_projection -------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void	perspective_projection( struct HSvertex *vertex_list)
#else
	void	perspective_projection (vertex_list)

	struct
	   HSvertex	*vertex_list;
#endif

/*
 * Transforms an array of points from normalized coordinates to screen
 * coordinates by dividing by w, shifting, and multiplying by the display
 * unit scale factors.
 *
 * HISTORY: ??/??/87 Created					Unknown Programmer
 *          04/06/90 Modified z-scale to use z_min, z_max.	C. M. Jablonski
 */

 {
   struct
      HSvertex	*stop_vertex;
   register
      IGRdouble	*point;
   IGRdouble	x_scale, y_scale, z_scale,
   		old_z;

   x_scale = (active_window->dit_clip_range[3] - active_window->dit_clip_range[0]) * 0.5;
   y_scale = (active_window->dit_clip_range[4] - active_window->dit_clip_range[1]) * 0.5;
   z_scale = (active_window->z_max - active_window->z_min);

   stop_vertex = vertex_list;
   do
    {
      point = vertex_list->coord;
      old_z = point[2];

      point[0] = ((point[0] / point[3]) + 1.0) * x_scale;
      point[1] = ((point[1] / point[3]) + 1.0) * y_scale;
      point[2] =  (point[2] / point[3])        * z_scale;

      /*
       * Save old Z for doing depth cueing later; put it in W.
       */

      /* Keep W undisturbed if rendering.	CMJ 12/08/89 */
      if (element_parms.facet_type != RENDERED) point[3] = old_z;
      vertex_list = vertex_list->next;
    }
   while (vertex_list != stop_vertex);
 }


/*--- HSconvert_transformation_matrix ------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSconvert_transformation_matrix( IGRdouble input_matrix[4][4], 
					      IGRdouble tiler_matrix[4][4] )
#else
	void HSconvert_transformation_matrix( input_matrix, tiler_matrix )

	IGRdouble	input_matrix[4][4], tiler_matrix[4][4];
#endif

/*
 * Converts the given transformation matrix into tiler transformation matrix format.
 * NOTE: no change.
 *
 * HISTORY: 07/16/88 created				C. M. Jablonski
 */

{
	tiler_matrix[0][0] = input_matrix[0][0];
	tiler_matrix[0][1] = input_matrix[0][1];
	tiler_matrix[0][2] = input_matrix[0][2];
	tiler_matrix[0][3] = input_matrix[0][3];

	tiler_matrix[1][0] = input_matrix[1][0];
	tiler_matrix[1][1] = input_matrix[1][1];
	tiler_matrix[1][2] = input_matrix[1][2];
	tiler_matrix[1][3] = input_matrix[1][3];

	tiler_matrix[2][0] = input_matrix[2][0];
	tiler_matrix[2][1] = input_matrix[2][1];
	tiler_matrix[2][2] = input_matrix[2][2];
	tiler_matrix[2][3] = input_matrix[2][3];

	tiler_matrix[3][0] = input_matrix[3][0];
	tiler_matrix[3][1] = input_matrix[3][1];
	tiler_matrix[3][2] = input_matrix[3][2];
	tiler_matrix[3][3] = input_matrix[3][3];
}


/*--- HSconvert_rotation_matrix ------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSconvert_rotation_matrix( IGRdouble input_matrix[4][4], 
					IGRdouble tiler_matrix[4][4] )
#else
	void HSconvert_rotation_matrix( input_matrix, tiler_matrix )

	IGRdouble	input_matrix[4][4], tiler_matrix[4][4];
#endif

/*
 * Converts the given rotation matrix into tiler rotation matrix format.
 * NOTE: y's and z's get flipped.
 *
 * HISTORY: 07/16/88 created				C. M. Jablonski
 */

{
	tiler_matrix[0][0] = input_matrix[0][0];
	tiler_matrix[0][1] = input_matrix[0][1];
	tiler_matrix[0][2] = input_matrix[0][2];
	tiler_matrix[0][3] = input_matrix[0][3];

	tiler_matrix[1][0] = input_matrix[1][0] * -1.0;
	tiler_matrix[1][1] = input_matrix[1][1] * -1.0;
	tiler_matrix[1][2] = input_matrix[1][2] * -1.0;
	tiler_matrix[1][3] = input_matrix[1][3] * -1.0;

	tiler_matrix[2][0] = input_matrix[2][0] * -1.0;
	tiler_matrix[2][1] = input_matrix[2][1] * -1.0;
	tiler_matrix[2][2] = input_matrix[2][2] * -1.0;
	tiler_matrix[2][3] = input_matrix[2][3] * -1.0;

	tiler_matrix[3][0] = input_matrix[3][0];
	tiler_matrix[3][1] = input_matrix[3][1];
	tiler_matrix[3][2] = input_matrix[3][2];
	tiler_matrix[3][3] = input_matrix[3][3];
}
