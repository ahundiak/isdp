/*
 * Name:  assemmath.h
 * 
 * Description: Math Preprocessor Include File 
 *
 * Dependencies:
 *
 * #include "igrtypedef.h"
 * #include "igr.h"
 * #include "igrdef.h"
 *
 */

#ifndef ASSEMMATH_H
#define ASSEMMATH_H

typedef struct surface_info
{
	IGRvector surf_normal;          /** normal to mating surface **/
	IGRpoint  surf_point;           /** point on mating surface  **/
}SURF_INFO;

typedef struct orientation_info
{
	IGRpoint  surf_point;           /** point on the surface     **/
	IGRvector surf_rot_vector;      /** vector on surface to     **
					 ** fix rotational angle     **/
	IGRvector surf_normal;          /** normal to the surface    **/
}ORIENT_INFO;

typedef struct axis_info
{
	IGRvector axis_direction;       /** vector along center axis  **/
	IGRpoint  axis_point;           /** a point on the axis       **/
}AXIS_INFO;

extern int mate ( ORIENT_INFO p1_or, ORIENT_INFO p2_or, IGRmatrix x_matrix );

extern int align( ORIENT_INFO p1_or, ORIENT_INFO p2_or, IGRmatrix x_matrix );

extern int mate_mate_ortho( SURF_INFO p1_surf1, SURF_INFO p1_surf2,
                            SURF_INFO p2_surf1, SURF_INFO p2_surf2,
                            IGRmatrix x_matrix );

extern int mate_mate_acute( SURF_INFO p1_surf1, SURF_INFO p1_surf2,
                            SURF_INFO p2_surf1, SURF_INFO p2_surf2,
                            IGRmatrix x_matrix );

extern int mate_align_ortho( AXIS_INFO p1_axis, SURF_INFO p1_surf,
			     AXIS_INFO p2_axis, SURF_INFO p2_surf,
		     	     IGRint constr_order, IGRmatrix trans_mat);

extern int align_align_ortho( AXIS_INFO p1_axis1, AXIS_INFO p1_axis2,
			      AXIS_INFO p2_axis1, AXIS_INFO p2_axis2,
            		      IGRint constr_order, IGRmatrix trans_mat);

extern int mate_align_parallel( ORIENT_INFO p1_or, ORIENT_INFO p2_or,
                                IGRmatrix trans_mat);

extern int align_align_parallel( AXIS_INFO p1_axis1, AXIS_INFO p1_axis2,
             		         AXIS_INFO p2_axis1, AXIS_INFO p2_axis2,
		                 IGRint constr_order, IGRmatrix trans_mat);

extern int mate_align_acute( AXIS_INFO p1_axis, SURF_INFO p1_surf,
		             AXIS_INFO p2_axis, SURF_INFO p2_surf,
		             IGRmatrix trans_mat);

extern int align_align_acute( AXIS_INFO p1_axis1, AXIS_INFO p1_axis2,
                              AXIS_INFO p2_axis1, AXIS_INFO p2_axis2,
                              IGRint constr_order, IGRmatrix trans_mat);

extern int mate_mate_mate( SURF_INFO p1_surf1, SURF_INFO p1_surf2, SURF_INFO p1_surf3,
                           SURF_INFO p2_surf1, SURF_INFO p2_surf2, SURF_INFO p2_surf3,
                           IGRmatrix x_matrix );

extern int mate_mate_align( SURF_INFO p1_surf1, SURF_INFO p1_surf2, AXIS_INFO p1_axis,
		            SURF_INFO p2_surf1, SURF_INFO p2_surf2, AXIS_INFO p2_axis,
		            IGRint constr_order[2], IGRmatrix trans_mat);

extern int mate_align_align( SURF_INFO p1_surf, AXIS_INFO p1_axis1, AXIS_INFO p1_axis2,
                             SURF_INFO p2_surf, AXIS_INFO p2_axis1, AXIS_INFO p2_axis2,
                             IGRint constr_order, IGRmatrix trans_mat);

#endif /* ASSEMMATH_H */
