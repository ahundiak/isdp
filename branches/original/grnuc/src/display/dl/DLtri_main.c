#include <stdio.h>
#include <math.h>
#include "wl.h"
#include "igrtypedef.h"
#include "igr.h"
#include "dl.h"
#include "dl_internal.h"

#define DEBUG_LOGGING	0
#define DEBUG_STROKES	0

/*---DLItri_magnitude--------------------------------------------------------*/

double DLItri_magnitude(
   double *v0,
   double *v1,
   double *N )

/*
NAME
    DLItri_magnitude

DESCRIPTION
    Given two vertices form a vector and compute its magnitude.
    normalize the vector

PARAMETERS
    v0 (IN): Coordinates of the first vertex
    v1 (IN): Coordinates of the second vertex
    N (OUT): resultant normal

RETURN VALUES
    The magnitude of the vector

HISTORY
    08/09/93 Created - Mike Lanier
*/

{
   double d;

   N[0] = v1[0] - v0[0];
   N[1] = v1[1] - v0[1];
   N[2] = v1[2] - v0[2];

   d = sqrt( ( N[0] * N[0] ) + ( N[1] * N[1] ) + ( N[2] * N[2] ) );

   if ( d > 0.0 )
   {
      N[0] /= d;
      N[1] /= d;
      N[2] /= d;
   }

   return ( d );

}/* DLItri_magnitude */

/*---DLItri_magnitude_f--------------------------------------------------------*/

double DLItri_magnitude_f(
   float *v0,
   float *v1,
   double *N )

/*
NAME
    DLItri_magnitude_f

DESCRIPTION
    Given two vertices form a vector and compute its magnitude.
    normalize the vector

PARAMETERS
    v0 (IN): Coordinates of the first vertex
    v1 (IN): Coordinates of the second vertex
    N (OUT): resultant normal

RETURN VALUES
    The magnitude of the vector

HISTORY
    08/09/93 Created - Mike Lanier
*/

{
   double d;

   N[0] = v1[0] - v0[0];
   N[1] = v1[1] - v0[1];
   N[2] = v1[2] - v0[2];

   d = sqrt( ( N[0] * N[0] ) + ( N[1] * N[1] ) + ( N[2] * N[2] ) );

   if ( d > 0.0 )
   {
      N[0] /= d;
      N[1] /= d;
      N[2] /= d;
   }

   return ( d );

}/* DLItri_magnitude_f */

/*---DLItri_dot--------------------------------------------------------------*/

double DLItri_dot(
   double *A,
   double *B )

/*
NAME
    DLItri_dot

DESCRIPTION
    Given two vectors, compute the dot product

PARAMETERS
    A, B (IN): Two vectors

RETURN VALUE
    The dot product of the two vectors

HISTORY
    06/09/93 Created - Mike Lanier
*/

{
#if DEBUG_LOGGING
   fprintf( stderr, "DLItri_dot: %f\n", A[0] * B[0] + A[1] * B[1] + A[2] * B[2] );
#endif

   return ( A[0] * B[0] + A[1] * B[1] + A[2] * B[2] );

}/* DLItri_dot */

/*---DLItri_cross--------------------------------------------------------------*/

void DLItri_cross(
   double *A,
   double *B,
   double *N )

/*
NAME
    DLItri_cross

DESCRIPTION
    Given two vectors, compute the cross product

PARAMETERS
    A, B (IN): Two vectors
    N (OUT): The output cross product normal

HISTORY
    06/09/93 Created - Mike Lanier
*/

{
   double d;

   N[0] = A[1] * B[2] - A[2] * B[1];
   N[1] = A[2] * B[0] - A[0] * B[2];
   N[2] = A[0] * B[1] - A[1] * B[0];

   d = sqrt( ( N[0] * N[0] ) + ( N[1] * N[1] ) + ( N[2] * N[2] ) );

   if ( d > 0.0 )
   {
      N[0] /= d;
      N[1] /= d;
      N[2] /= d;
   }

}/* DLItri_cross */

/*---DLItri_compute_facet_normal---------------------------------------------*/

static int DLItri_compute_facet_normal(
   double *points,
   int total_points,
   double dis_tol,
   double *normal )

/*
NAME
    DLItri_compute_facet_normal

KEYWORDS
    triangulator

DESCRIPTION
    Finds suitable vertices on the facet and computes the facet normal

PARAMETERS
    points (IN): Array of polygon vertices
    total_points (IN): Number of vertices in the array points
    dis_tol (IN): Distance tolerance, two vertices have to be at least this far apart
                  before they are unique
    normal (OUT): The computed facet normal

HISTORY
    06/09/93 Created - Mike Lanier
*/

{
   int p0, p1, p2, i;
   double A[3], B[3];

   /* Set vertex p0 to be the 0'th vertex in the array.  Then  */
   /* Find two more that are suitably far enough from p0 and are  */
   /* not parallel */

   p0 = 0;
   p1 = -1;

   for ( p2 = 3, i = 1; i < total_points; i++, p2 += 3 )
   {
      if ( p1 == -1 )
      {
         if ( DLItri_magnitude( &points[p0], &points[p2], A ) >= dis_tol )
         {
            p1 = p2;
         }
      }
      else
      {
         if ( DLItri_magnitude( &points[p0], &points[p2], B ) >= dis_tol )
         {
            if ( DLItri_FABS( DLItri_dot( A, B ) ) <= ( 1.0 - dis_tol ) )
            {
               DLItri_cross( A, B, normal );
               return ( TRUE );
            }
         }
      }
   }

   return ( FALSE );

}/* DLItri_compute_facet_normal */

/*---DLItri_compute_facet_normal_f---------------------------------------------*/

static int DLItri_compute_facet_normal_f(
   float *points,
   int total_points,
   double dis_tol,
   double *normal )

/*
NAME
    DLItri_compute_facet_normal_f

KEYWORDS
    triangulator

DESCRIPTION
    Finds suitable vertices on the facet and computes the facet normal

PARAMETERS
    points (IN): Array of polygon vertices
    total_points (IN): Number of vertices in the array points
    dis_tol (IN): Distance tolerance, two vertices have to be at least this far apart
                  before they are unique
    normal (OUT): The computed facet normal

HISTORY
    06/09/93 Created - Mike Lanier
*/

{
   int p0, p1, p2, i;
   double A[3], B[3];

   /* Set vertex p0 to be the 0'th vertex in the array.  Then  */
   /* Find two more that are suitably far enough from p0 and are  */
   /* not parallel */

   p0 = 0;
   p1 = -1;

   for ( p2 = 3, i = 1; i < total_points; i++, p2 += 3 )
   {
      if ( p1 == -1 )
      {
         if ( DLItri_magnitude_f( &points[p0], &points[p2], A ) >= dis_tol )
         {
            p1 = p2;
         }
      }
      else
      {
         if ( DLItri_magnitude_f( &points[p0], &points[p2], B ) >= dis_tol )
         {
            if ( DLItri_FABS( DLItri_dot( A, B ) ) <= ( 1.0 - dis_tol ) )
            {
               DLItri_cross( A, B, normal );
               return ( TRUE );
            }
         }
      }
   }

   return ( FALSE );

}/* DLItri_compute_facet_normal_f */

/*---DLItriangulate------------------------------------------------*/

int DLItriangulate(
   int num_polys,
   int *num_points,
   double *points,
   double tolerance,
   int (*mesh_processor)() )

/*
NAME
     DLItriangulate

DESCRIPTION
     This function receives data defining a planar polygon and
     all its internal boundaries, unpacks the data and sends it
     to the triangulator.

PARAMETERS
     num_polys (IN): Number of polygons in the input data
     num_points (IN): Array containing the number of points in each polygon
     points (IN): Array of x,y,z vertices
     tolerance (IN): Used in tossing duplicate vertices
     mesh_processor (IN): Function to send the triangular mesh's to.

HISTORY
     06/08/93: Created    Mike Lanier
*/

{
   int i, j, x;
   int total_points;
   double normal[3];

   /* Send all the vertices to the triangulator  */
   total_points = 0;
   for ( x = i = 0; i < num_polys; i++ )
   {
      if ( num_points[i] > 2 )
         total_points += num_points[i];

      for ( j = 0; j < num_points[i]; j++, x += 3 )
      {
         if ( num_points[i] > 2 )
            DLItri_add_vertex( points[x], points[x + 1], points[x + 2], 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0 );
      }

      if ( num_points[i] > 2 )
         DLItri_end_loop();
   }

   /* Compute the facet normal and triangulate  */
   if ( DLItri_compute_facet_normal( points, total_points, tolerance, normal ) )
   {
      /* Mesh the vertices  */
      DLItri_mesh_loops( tolerance, normal, mesh_processor );
   }
   else
   {
      return( DL_ERROR );
   }

   return ( DL_SUCCESS );

}/* DLItriangulate */

/*---DLItriangulate_f------------------------------------------------*/

int DLItriangulate_f(
   int num_polys,
   int *num_points,
   float *points,
   double tolerance,
   int (*mesh_processor)() )

/*
NAME
     DLItriangulate_f

DESCRIPTION
     This function receives single precision data defining a planar polygon
     and all its internal boundaries, unpacks the data and sends it
     to the triangulator.

PARAMETERS
     num_polys (IN): Number of polygons in the input data
     num_points (IN): Array containing the number of points in each polygon
     points (IN): Array of x,y,z vertices
     tolerance (IN): Used in tossing duplicate vertices
     mesh_processor (IN): Function to send the triangular mesh's to.

HISTORY
     06/08/93: Created    Mike Lanier
*/

{
   int i, j, x;
   int total_points;
   double normal[3];

   /* Send all the vertices to the triangulator */
   total_points = 0;
   for ( x = i = 0; i < num_polys; i++ )
   {
      if ( num_points[i] > 2 )
         total_points += num_points[i];

      for ( j = 0; j < num_points[i]; j++, x += 3 )
      {
         if ( num_points[i] > 2 )
            DLItri_add_vertex( points[x], points[x + 1], points[x + 2], 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0 );
      }

      if ( num_points[i] > 2 )
         DLItri_end_loop();
   }


   /* Compute the facet normal  */

   if ( DLItri_compute_facet_normal_f( points, total_points, tolerance, normal ) )
   {
      /* Mesh the vertices  */
      DLItri_mesh_loops( tolerance, normal, mesh_processor );
   }
   else
   {
      return( DL_ERROR );
   }

   return ( DL_SUCCESS );

} /* DLItriangulate_f */

/*---DLItri_set_status------------------------------------------------------*/

void DLItri_set_status(
   int flag )

/*
NAME
    DLItri_set_status

DESCRIPTION
    receives status information from within the triangulator and passes it
    back to the caller

PARAMETERS
    flags (IN): status flag

HISTORY
    06/08/93 Created - Mike Lanier
*/

{
   fprintf( stderr, "STUB: DLItri_set_status: flag: %d\n", flag );

}/* DLItri_set_status */

