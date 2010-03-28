#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "wl.h"
#include "igrtypedef.h"
#include "igr.h"
#include "dl.h"
#include "dl_internal.h"

#define NEITHER_SIDE	0
#define LEFT_SIDE	1
#define RIGHT_SIDE	2

static struct DLItri_mesh TriMesh;
static struct DLItri_point *vNorms = NULL;
static int MaxVerts = 0;


static struct DLItri_edge *Left, *Right;
static struct DLItri_polygon_vert *MonoPolys;
static struct DLItri_polygon_vert **Stack;
static int NumTriMeshes;
static int Top = -1;

#define DEBUG_LOGGING		0
#define CONST_DEBUG	0
#define SMOOTH_DEBUG	0
#define DRAWING		0

/*---DLItri_get_next_side()-----------------------------------------------------------------*/

static int DLItri_get_next_side(
   int PlanarX,
   int PlanarY )

/*
NAME
        DLItri_get_next_side (static)

DESCRIPTION
        This function  resets the 'Left' or 'Right' static edge pointer to aid
        in merging of the two monotonic chains of the current polygon.

KEYWORD
        triangulator

PARAMETERS
        LocalMin (IN) - The top vertex in the monotonic polygon.
        PlanarX,PlanarY (IN) - Indices (0-2) of the 3d coordinates to use for 2d triangulation.

GLOBALS USED
        MonoPolys - Used to build the monotonic polygon.
        Left,Right - Two edges that comprise the current interval on the active edge list.

RETURN VALUES
        Returns	the side (RIGHT_SIDE or LEFT_SIDE) which contains the next vertex to be
        merged into the sorted array.
        NEITHER_SIDE means the 'Left' and 'Right' edges have met.

HISTORY
        02/05/90 Created. -Trevor Mink
        02/12/92 Mark each edge of the mono polygon as 'DLItri_LIVE_EDGE'. -Trevor Mink
        06/06/93 Copied from HSURF and modified for DL - Mike Lanier
*/

{
   int RightMost;
   struct DLItri_vertex *v;
   double *RightCoord, *LeftCoord;

   if ( Right->Bottom == Left->Bottom )
      return ( NEITHER_SIDE );

   LeftCoord = Left->Bottom->coord;
   RightCoord = Right->Bottom->coord;

#if DEBUG_LOGGING
   fprintf( stderr, "LeftCoord = (%f, %f)\tRightCoord = (%f, %f)\n",
            LeftCoord[PlanarX], LeftCoord[PlanarY], RightCoord[PlanarX], RightCoord[PlanarY] );
   fprintf( stderr, "Left->Bottom = %x\tRight->Bottom = %x\n", Left->Bottom, Right->Bottom );
#endif

   if ( RightCoord[PlanarY] > LeftCoord[PlanarY] ||
        ( RightCoord[PlanarY] == LeftCoord[PlanarY] &&
          RightCoord[PlanarX] > LeftCoord[PlanarX] ) )
   {
      v = Left->Bottom;
      RightMost = v->OutCardinality - 1;


      /* Turn on the old Left edge. */

      Left->EdgeStatus |= DLItri_LIVE_EDGE;
      Left = v->Out[RightMost];

#if DEBUG_LOGGING
      fprintf( stderr, "RightMost = %d\n", RightMost );
      fprintf( stderr, "v(Left->Bottom) = %x\tLeft = %x\n", v, Left );
#endif

      return ( LEFT_SIDE );
   }
   else
   {
      v = Right->Bottom;
      Right->EdgeStatus |= DLItri_LIVE_EDGE;
      Right = v->Out[0];

#if DEBUG_LOGGING
      fprintf( stderr, "v(Right->Bottom) = %x\tRight = %x\n", v, Right );
#endif

      return ( RIGHT_SIDE );
   }

}/* DLItri_get_next_side */


static int VertNum = 0;

/*---DLItri_get_mono_polygon()-----------------------------------------------------------------*/

static int DLItri_get_mono_polygon(
   struct DLItri_vertex * LocalMin,
   int PlanarX,
   int PlanarY )

/*
NAME
        DLItri_get_mono_polygon (static)

DESCRIPTION
        This function places the monotonic polygon beginning at the given 'LocalMin'
        into a linked list structure specifically designed for monotonic polygons and
        their triangulation.

KEYWORD
        triangulator

PARAMETERS
        LocalMin (IN) - The top vertex in the monotonic polygon.
        PlanarX,PlanarY (IN) - Indices (0-2) of the 3d coordinates to use for 2d triangulation.

GLOBALS USED
        MonoPolys - Used to build the monotonic polygon.

RETURN VALUES
        The number of vertices in the monotonic polygon.

HISTORY
        02/05/90 Created. -Trevor Mink
        06/07/93 Converted to DL - Mike Lanier
*/

{
   int NumVerts = 0, MinSide = LEFT_SIDE;       /* Either side is okay to
                                                 * begin with */
   int left, right;

   struct DLItri_edge **EdgeSet;
   void PrintMonoPoly(  );


   /* Initial setting of 'Left' and 'Right' */

   EdgeSet = LocalMin->Out;
   left = 0;
   right = 1;

   if ( LocalMin->OutCardinality > 2 )
   {
      while ( !( ( EdgeSet[left]->EdgeStatus & DLItri_ADDED_EDGE ) ||
                 ( EdgeSet[right]->EdgeStatus & DLItri_ADDED_EDGE ) ) )
      {
         left++;
         right++;

#if DEBUG_LOGGING
         fprintf( stderr, "left = %d\tright = %d\n", left, right );
#endif
      }

      if ( LocalMin->LocalExtremity & DLItri_MONO_MADE )
      {
#if DEBUG_LOGGING
         fprintf( stderr, "A local minimum was used twice\n" );
#endif

         do
         {
            left++;
            right++;

#if DEBUG_LOGGING
            fprintf( stderr, "left = %d\tright = %d\n", left, right );
#endif
         }
         while ( !( ( EdgeSet[left]->EdgeStatus & DLItri_ADDED_EDGE ) ||
                    ( EdgeSet[right]->EdgeStatus & DLItri_ADDED_EDGE ) ) );
      }

      LocalMin->LocalExtremity |= DLItri_MONO_MADE;
   }

   Left = EdgeSet[left];
   Right = EdgeSet[right];


   /* Now, merge the monotonic polygon into its linked list structure */

   do
   {
      MonoPolys[NumVerts].Side = MinSide;

#if DEBUG_LOGGING
      fprintf( stderr, "NumVerts = %d\n", NumVerts );
      fprintf( stderr, "MonoPolys[NumVerts] = %x\n", MonoPolys[NumVerts] );
      fprintf( stderr, "left = %d\n", left );
      fprintf( stderr, "right = %d\n", right );
      fprintf( stderr, "EdgeSet[left] = %x\n", EdgeSet[left] );
      fprintf( stderr, "EdgeSet[right] = %x\n", EdgeSet[right] );
      fprintf( stderr, "Left = %x\n", Left );
      fprintf( stderr, "Left->Top = %x\n", Left->Top );
#endif

      if ( MinSide == LEFT_SIDE )
         MonoPolys[NumVerts].Vertex = Left->Top;
      else
         MonoPolys[NumVerts].Vertex = Right->Top;

      NumVerts++;

#if DEBUG_LOGGING
      PrintMonoPoly( NumVerts, PlanarX, PlanarY );
#endif

      /* Change 'Left' or 'Right' and return which side has lesser 'Bottom' */
      /* vertex */

      MinSide = DLItri_get_next_side( PlanarX, PlanarY );
   }
   while ( MinSide != NEITHER_SIDE );

   /* Now, place the local maximum vertex at the end of the linked list */

   MonoPolys[NumVerts].Side = MinSide;
   MonoPolys[NumVerts].Vertex = Left->Bottom;   /* or 'Right->Bottom' */
   NumVerts++;
   return ( NumVerts );

}/* DLItri_get_mono_polygon */

#if DEBUG_LOGGING
/*--- DLItri_print_mono_poly -----------------------------------------------------------------------*/

static void DLItri_print_mono_poly(
   int NumVerts,
   int PlanarX,
   int PlanarY )

/*
NAME
        DLItri_print_mono_poly (static)

DESCRIPTION
        This function prints out the current monotonic polygon stored in 'MonoPolys'

KEYWORD
        triangulator

PARAMETERS
        NumVerts (IN) - The number of vertices in the monotonic polygon.
        PlanarX,PlanarY (IN) - Indices (0-2) of the 3d coordinates to use for 2d triangulation.

GLOBALS USED
        MonoPolys (static) - Stores the monotonic polygon.

RETURN VALUES
        none

HISTORY
        02/05/90 Created. -Trevor Mink
        06/07/93 Converted to DL - Mike Lanier
*/

{
   int i;
   float x, y;
   struct DLItri_polygon_vert *Poly;

   fprintf( stderr, "\nNew Poly at addr %x\n", MonoPolys );
   fprintf( stderr, "PlanarX = %d\nPlanarY = %d\n", PlanarX, PlanarY );

   for ( i = 0; i < NumVerts; i++ )
   {
      x = MonoPolys[i].Vertex->coord[PlanarX];
      y = MonoPolys[i].Vertex->coord[PlanarY];

      fprintf( stderr, "Vertex %x at ( %f, %f ) with side = %d\n", MonoPolys[i].Vertex, x, y,
               MonoPolys[i].Side );
   }

}/* DLItri_print_mono_poly */

#endif

/*--- DLItri_clear_mono_edges -------------------------------------------------*/

static void DLItri_clear_mono_edges(
   int NumVerts )

/*
NAME
        DLItri_clear_mono_edges (static)

KEYWORD
        triangulator

DESCRIPTION
        This function unmarks all of edges which are members of the out
        set of all vertices in the monotonic polygon just created. This
        assures that all edges will be unmarked prior to marking of the
        next monotonic polygon.

PARAMETERS
        NumVerts (IN) - Number of vertices in the monotonic polygon.

GLOBALS USED
        MonoPolys - Array containing pointers to all vertices of the current
        monotonic polygon.

RETURN VALUES
        none.

HISTORY
        02/12/92 Created. -Trevor Mink
        06/07/93 Converted to DL - Mike Lanier
*/

{
   int i, j, Cardinality;
   struct DLItri_vertex *Vertex;

   for ( i = 0; i < NumVerts; i++ )
   {
      Vertex = MonoPolys[i].Vertex;
      Cardinality = Vertex->OutCardinality;
      for ( j = 0; j < Cardinality; j++ )
      {

         /* Zero out 'DLItri_LIVE_EDGE' bit */

         Vertex->Out[j]->EdgeStatus &= ~DLItri_LIVE_EDGE;
      }
   }

}/* DLItri_clear_mono_edges */

/*--- DLItri_adjacent() ---------------------------------------------------------------------*/

static int DLItri_adjacent(
   struct DLItri_vertex * Lower,
   struct DLItri_vertex * Upper )

/*
NAME
        DLItri_adjacent (static)

DESCRIPTION
        This function determines if two vertices of a monotonic polygon share an edge.

KEYWORD
        triangulator

PARAMETERS
        Lower,Upper (IN) - The two vertices to be tested for adjacency.

GLOBALS USED
        None.

RETURN VALUES
        TRUE (non-zero)	Indicates the vertices are adjacent
        FALSE (zero)	Vertices are not adjacent

HISTORY:
        02/06/90 Created. -Trevor Mink
        02/12/92 Check for 'DLItri_LIVE_EDGE' to assure it's on the polygon. -Trevor Mink
        06/07/93 Converted to DL - Mike Lanier
*/

{
   int i, Cardinality;

   Cardinality = Upper->OutCardinality;
   for ( i = 0; i < Cardinality; i++ )
   {

      /* Does the 'Upper' have an outgoing edge which connects to 'Lower' */
      /* AND, is the edge marked as being on the monotonic polygon? */

      if ( ( Upper->Out[i]->Bottom == Lower ) &&
           ( Upper->Out[i]->EdgeStatus & DLItri_LIVE_EDGE ) )
         return ( TRUE );
   }

   return ( FALSE );

}/* DLItri_adjacent */

/*--- DLItri_valid_angle -----------------------------------------------------------------*/

static int DLItri_valid_angle(
   struct DLItri_polygon_vert * u,
   struct DLItri_polygon_vert * v1,
   struct DLItri_polygon_vert * v2,
   int PlanarX,
   int PlanarY,
   double DistTol )

/*
NAME
        DLItri_valid_angle (static)

DESCRIPTION
        This function determines if the angle between the three vertices of the monotonic
        polygon form an angle valid for adding to the current triangular mesh.

KEYWORD
        triangulator

PARAMETERS
        u, v1, u2 (IN) - The three vertices.
        PlanarX,PlanarY (IN) - Indices (0-2) of the 3d coordinates to use for 2d triangulation.
        DistTol (IN) - EMS Distance Tolerance

GLOBALS USED
        none.

RETURN VALUES
        Flag indicating whether or not the angle is valid.

HISTORY
        02/05/90 Created. -Trevor Mink
        06/07/93 Converted to DL - Mike Lanier
*/

{
   double A_x, A_y, B_x, B_y;
   double CrossProduct;

   A_x = v1->Vertex->coord[PlanarX] - u->Vertex->coord[PlanarX] + DistTol;
   A_y = v1->Vertex->coord[PlanarY] - u->Vertex->coord[PlanarY];
   B_x = v2->Vertex->coord[PlanarX] - v1->Vertex->coord[PlanarX];
   B_y = v2->Vertex->coord[PlanarY] - v1->Vertex->coord[PlanarY];

   if ( v1->Side == LEFT_SIDE )
   {
      A_x = -A_x;
      A_y = -A_y;
   }
   CrossProduct = A_x * B_y - B_x * A_y;

   if ( CrossProduct > 0.0 )
      return ( FALSE );
   else
      return ( TRUE );

}/* DLItri_valid_angle */

/*--- DLItri_add_diagonal() -----------------------------------------------------------------*/

static void DLItri_add_diagonal(
   struct DLItri_polygon_vert * u,
   struct DLItri_polygon_vert * v1,
   struct DLItri_polygon_vert * v2,
   int PlanarX,
   int PlanarY,
   int (*mesh_processor)( struct DLItri_mesh * ) )

/*
NAME
        DLItri_add_diagonal (static)

DESCRIPTION
        This function adds a diagonal from 'u' to 'v1'. 'v2' is required to check whether
        the current mesh can be continued with the next vertex.

KEYWORD
        triangulator

PARAMETERS
        u, v1 (IN) - The two vertices which, with the previous vertex, will form the next
        triangle.
        u2 (IN) - Used to determine if the current mesh can be continued with the next vertex.
        PlanarX,PlanarY (IN) - Indices (0-2) of the 3d coordinates to use for 2d triangulation.

GLOBALS USED
        TriMesh (static) - Hold the triangular mesh structure to send to EG.

RETURN VALUES
        none.

HISTORY
        02/16/90 Created. -Trevor Mink
        06/07/93 Converted to DL - Mike Lanier
*/

{
   int k;
   int x, y;

#if DRAWING
   x = u->Vertex->coord[PlanarX];
   y = u->Vertex->coord[PlanarY];
   move( vcNo, x, y );
   x = v1->Vertex->coord[PlanarX];
   y = v1->Vertex->coord[PlanarY];
   draw( vcNo, x, y );
#else
   x = v1->Vertex->coord[PlanarX];
   y = v1->Vertex->coord[PlanarY];
#endif

#if DEBUG_LOGGING
   /* fprintf( stderr, "u = %x\tv1 = %x\tv2 = %x\n", u, v1, v2 ); fprintf(
    * stderr, "u->VertNo = %d\tv1->VertNo = %d\tv2->VertNo = %d\tVertNum =
    * %d\n", u->VertNo, v1->VertNo, v2->VertNo, VertNum ); */
#endif

   /* If current vertex 'u' will numerically fit as vertex 'VertNum' add it */
   /* as such */

   if ( ( v1->VertNo == VertNum - 1 && v2->VertNo == ( VertNum - 2 ) ) ||
        ( v2->VertNo == VertNum - 1 && v1->VertNo == ( VertNum - 2 ) ) )
   {
      TriMesh.verts[VertNum - 1].x = u->Vertex->coord[0];
      TriMesh.verts[VertNum - 1].y = u->Vertex->coord[1];
      TriMesh.verts[VertNum - 1].z = u->Vertex->coord[2];

#if SHADING_ACTIVE
      if ( element_parms.facet_type == SMOOTH_SHADE )
      {
         TriMesh.vNorms[VertNum - 1].x = u->Vertex->norm[0];
         TriMesh.vNorms[VertNum - 1].y = u->Vertex->norm[1];
         TriMesh.vNorms[VertNum - 1].z = u->Vertex->norm[2];

#if SMOOTH_DEBUG
         fprintf( stderr, "u vertex normal: (%f, %f, %f)\n",
               u->Vertex->norm[0], u->Vertex->norm[1], u->Vertex->norm[2] );
#endif
      }
#endif

      u->VertNo = VertNum++;

      /* If current vertex 'v1' will numerically fit as vertex 'VertNum' */
      /* add it as such */

   }
   else if ( ( u->VertNo == VertNum - 1 && v2->VertNo == ( VertNum - 2 ) ) ||
             ( v2->VertNo == VertNum - 1 && u->VertNo == ( VertNum - 2 ) ) )
   {
      TriMesh.verts[VertNum - 1].x = v1->Vertex->coord[0];
      TriMesh.verts[VertNum - 1].y = v1->Vertex->coord[1];
      TriMesh.verts[VertNum - 1].z = v1->Vertex->coord[2];

#if SHADING_ACTIVE
      if ( element_parms.facet_type == SMOOTH_SHADE )
      {
         TriMesh.vNorms[VertNum - 1].x = v1->Vertex->norm[0];
         TriMesh.vNorms[VertNum - 1].y = v1->Vertex->norm[1];
         TriMesh.vNorms[VertNum - 1].z = v1->Vertex->norm[2];

#if SMOOTH_DEBUG
         fprintf( stderr, "u vertex normal: (%f, %f, %f)\n",
               u->Vertex->norm[0], u->Vertex->norm[1], u->Vertex->norm[2] );
#endif
      }
#endif

      v1->VertNo = VertNum++;
   }
   else
   {
      if ( VertNum )
      {
         TriMesh.numVerts = VertNum - 1;


         /* Send (or save) the current Triangular Mesh */

         ( *mesh_processor ) ( &TriMesh );

         for ( k = 0; k <= Top; k++ )
            Stack[k]->VertNo = 0;
         NumTriMeshes++;
      }

      v2->VertNo = 1;
      v1->VertNo = 2;
      u->VertNo = 3;

      TriMesh.verts[0].x = v2->Vertex->coord[0];
      TriMesh.verts[0].y = v2->Vertex->coord[1];
      TriMesh.verts[0].z = v2->Vertex->coord[2];

      TriMesh.verts[1].x = v1->Vertex->coord[0];
      TriMesh.verts[1].y = v1->Vertex->coord[1];
      TriMesh.verts[1].z = v1->Vertex->coord[2];

      TriMesh.verts[2].x = u->Vertex->coord[0];
      TriMesh.verts[2].y = u->Vertex->coord[1];
      TriMesh.verts[2].z = u->Vertex->coord[2];

#if SHADING_ACTIVE
      if ( element_parms.facet_type == SMOOTH_SHADE )
      {
         TriMesh.vNorms[0].x = v2->Vertex->norm[0];
         TriMesh.vNorms[0].y = v2->Vertex->norm[1];
         TriMesh.vNorms[0].z = v2->Vertex->norm[2];

#if SMOOTH_DEBUG
         fprintf( stderr, "v2 vertex normal: (%f, %f, %f)\n",
            v2->Vertex->norm[0], v2->Vertex->norm[1], v2->Vertex->norm[2] );
#endif

         TriMesh.vNorms[1].x = v1->Vertex->norm[0];
         TriMesh.vNorms[1].y = v1->Vertex->norm[1];
         TriMesh.vNorms[1].z = v1->Vertex->norm[2];

#if SMOOTH_DEBUG
         fprintf( stderr, "v1 vertex normal: (%f, %f, %f)\n",
            v1->Vertex->norm[0], v1->Vertex->norm[1], v1->Vertex->norm[2] );
#endif

         TriMesh.vNorms[2].x = u->Vertex->norm[0];
         TriMesh.vNorms[2].y = u->Vertex->norm[1];
         TriMesh.vNorms[2].z = u->Vertex->norm[2];

#if SMOOTH_DEBUG
         fprintf( stderr, "u vertex normal: (%f, %f, %f)\n",
               u->Vertex->norm[0], u->Vertex->norm[1], u->Vertex->norm[2] );
#endif
      }
#endif

#if SHHADING_ACTIVE
      TriMesh.fNorms[0].x = element_parms.facet_normal[0];
      TriMesh.fNorms[0].y = element_parms.facet_normal[1];
      TriMesh.fNorms[0].z = element_parms.facet_normal[2];
#endif

#if SMOOTH_DEBUG
      fprintf( stderr, "facet normal: (%f, %f, %f)\n",
            TriMesh.fNorms[0].x, TriMesh.fNorms[0].y, TriMesh.fNorms[0].z );
#endif
      VertNum = 4;
   }

#if DEBUG_LOGGING
   /* fprintf( stderr, "Diagonal added from (%lf, %lf) to (%lf, %lf)\n",
    * u->Vertex->coord[PlanarX], u->Vertex->coord[PlanarY],
    * v1->Vertex->coord[PlanarX], v1->Vertex->coord[PlanarY] ); fprintf(
    * stderr, "u->VertNo = %d\tv1->VertNo = %d\tv2->VertNo = %d\n",
    * u->VertNo, v1->VertNo, v2->VertNo ); */
#endif

}/* DLItri_add_diagonal */

/*--- DLItri_alloc_trimesh --------------------------------------------------------------------------------*/

static int DLItri_alloc_trimesh(
   int NumVertices )

/*
NAME
        DLItri_alloc_trimesh

DESCRIPTION
        This function returns sufficient memory for vertices and facet normal(s), as well as
        vertex normals (if smooth shading) for the static 'TriMesh'.

KEYWORD
        triangulator

PARAMETERS
        NumVertices (IN) - Number of vertices in the monotonic polygon. Hence, maximum
        size of a triangular mesh for the mono polygon.

GLOBALS USED
        TriMesh (static) - Holds the triangular mesh structure to send to EG.

RETURN VALUES
        TRUE - If able to alloc everything.
        FALSE - If some alloc failed.

HISTORY
        08/29/91 Created.
        06/07/93 Converted to DL - Mike Lanier
*/

{
   int NumChunks;

   if ( NumVertices < DLItri_NUM_VERTS_IN_8K )
      NumVertices = DLItri_NUM_VERTS_IN_8K;

   if ( MaxVerts == 0 )
   {
      TriMesh.verts = ( struct DLItri_point * ) malloc( NumVertices * sizeof( struct DLItri_point ) );
      TriMesh.fNorms = ( struct DLItri_point * ) malloc( sizeof( struct DLItri_point ) );
      vNorms = ( struct DLItri_point * ) malloc( NumVertices * sizeof( struct DLItri_point ) );

      TriMesh.vColors = NULL;
      TriMesh.fColors = NULL;

      if ( !vNorms || !TriMesh.verts )
         return ( FALSE );

      MaxVerts = NumVertices;
   }
   else if ( NumVertices > MaxVerts )
   {
      NumChunks = NumVertices / DLItri_NUM_VERTS_IN_8K;
      NumVertices = ( NumChunks + 1 ) * DLItri_NUM_VERTS_IN_8K;

      free( TriMesh.verts );
      free( vNorms );

      TriMesh.verts = ( struct DLItri_point * ) malloc( NumVertices * sizeof( struct DLItri_point ) );
      vNorms = ( struct DLItri_point * ) malloc( NumVertices * sizeof( struct DLItri_point ) );

      if ( !vNorms || !TriMesh.verts )
         return ( FALSE );
      MaxVerts = NumVertices;
   }

   TriMesh.numFacetNormals = 1;

#if SHADING_ACTIVE
   if ( element_parms.facet_type == SMOOTH_SHADE )
   {
      TriMesh.vNorms = vNorms;
   }
   else
   {
      TriMesh.vNorms = NULL;
   }
#endif

   return ( TRUE );

}/* DLItri_alloc_trimesh */


static struct DLItri_polygon_vert *PolyArray_static = ( struct DLItri_polygon_vert * ) NULL;
static struct DLItri_polygon_vert **PolyStack_static = ( struct DLItri_polygon_vert ** ) NULL;

/*--- DLItri_alloc_mono_polys_and_stack ------------------------------------------------*/

static void DLItri_alloc_mono_polys_and_stack(
   int NumVertices )

/*
NAME
        DLItri_alloc_mono_polys_and_stack (static)

DESCRIPTION
        This function returns sufficient memory for the 'MonoPolys' and 'Stack'
        static variables.

KEYWORD
        triangulator

PARAMETERS
        NumVertices (IN) - Number of vertices in the entire facet (Overkill, but safe).

GLOBALS USED
        PolyArray_static (static) - Holds 1024 DLItri_polygon_vert structures (Will handle most cases).
        PolyStack_static (static) - Holds Pointers to 1024 DLItri_polygon_vert structures (Handles most cases).
        MonoPolys (static) - Used to build the monotonic polygon. Memory is assigned here.
        Stack (static) - Used in the triangulation of the monotonic polygon. Memory is assigned here.

RETURN VALUES
        Return value contains an inaccurate count of the number of tri meshes.

HISTORY
        08/29/91 Created. -Trevor Mink
        06/07/93 Converted to DL - Mike Lanier
*/

{
   if ( !PolyArray_static )
      PolyArray_static = ( struct DLItri_polygon_vert * ) malloc( DLItri_OneKB * sizeof( struct DLItri_polygon_vert ) );

   if ( !PolyStack_static )
      PolyStack_static = ( struct DLItri_polygon_vert ** ) malloc( DLItri_OneKB * sizeof( struct DLItri_polygon_vert * ) );

   if ( NumVertices > DLItri_OneKB )
   {
      MonoPolys = ( struct DLItri_polygon_vert * ) malloc( NumVertices * sizeof( struct DLItri_polygon_vert ) );
      Stack = ( struct DLItri_polygon_vert ** ) malloc( NumVertices * sizeof( struct DLItri_polygon_vert * ) );
   }
   else
   {
      MonoPolys = PolyArray_static;
      Stack = PolyStack_static;
   }

}/* DLItri_alloc_mono_polys_and_stack */

/*--- DLItri_create_mesh() ----------------------------------------------------------------*/

int DLItri_create_mesh(
   struct DLItri_polygon_vert * LocalMins,
   int NumVertices,
   int PlanarX,
   int PlanarY,
   double DistTol,
   int (*mesh_processor)() )

/*
NAME
        DLItri_create_mesh

DESCRIPTION
        This function takes a pointer to a linked list of local minima (for monotonic
        polygons) and triangulates these.

KEYWORD
        triangulator

PARAMETERS
        LocalMins (IN) - Linked list of what will be top vertices of the monotonic polygons.
        NumVertices (IN) - Number of vertices in the entire facet.
        PlanarX,PlanarY (IN) - Indices (0-2) of the 3d coordinates to use for 2d triangulation.
        DistTol (IN) - EMS Distance Tolerance (Passed to DLItri_valid_angle and used there).
        mesh_processor (IN) - function to send triangles to

GLOBALS USED
        TriMesh (static) - Hold the triangular mesh structure to send to EG.
        MonoPolys (static) - Used to build the monotonic polygon.
        Stack (static) - Used in the triangulation of the monotonic polygon.

RETURN VALUES
        Return value contains an inaccurate count of the number of tri meshes.

HISTORY
        02/06/90 Created. -Trevor Mink
        06/06/93 Copied from HSURF for DL: Mike Lanier
*/

{
   int i, k, NumVerts;
   int Cond1, Cond2;
   struct DLItri_polygon_vert *u, *Min;

#if DEBUG_LOGGING
   int j, x, y;
#endif

   NumTriMeshes = 0;

   DLItri_alloc_mono_polys_and_stack( NumVertices );

   Top = -1;

   for ( i = 0; i < NumVertices; i++ )
      MonoPolys[i].VertNo = 0;


   /* For all local minima */

   for ( Min = LocalMins; Min; Min = Min->Next )
   {

      /* Get the sorted vertices from the monotonic polygon that begins */
      /* with 'Min->Vertex' */

      NumVerts = DLItri_get_mono_polygon( Min->Vertex, PlanarX, PlanarY );

      if ( !DLItri_alloc_trimesh( NumVerts ) )
         return ( FALSE );

#if DEBUG_LOGGING
      DLItri_print_mono_poly( NumVerts, PlanarX, PlanarY );
#endif

      if ( NumVerts < 3 )
         continue;      /* Get next monotonic polygon, don't process this one */


      /* Begin actual triangulation algorithm on polygon 'MonoPolys' */

      Stack[0] = &MonoPolys[0];
      Stack[1] = &MonoPolys[1];
      Top += 2;


      /* for all vertices of monotonic polygon */

      for ( k = 2; k < NumVerts; k++ )
      {
         u = &MonoPolys[k];
         MonoPolys[k].VertNo = 0;
         Cond1 = DLItri_adjacent( u->Vertex, Stack[0]->Vertex );
         Cond2 = DLItri_adjacent( u->Vertex, Stack[Top]->Vertex );

#if DEBUG_LOGGING
         /* fprintf( stderr, "Cond1 = %d\tCond2 = %d\tTop = %d\n", Cond1,
          * Cond2, Top ); */
#endif

         if ( Cond1 && !Cond2 )
         {
            for ( i = 1; i <= Top; i++ )
            {
               DLItri_add_diagonal( u, Stack[i], Stack[i - 1], PlanarX, PlanarY, mesh_processor );
            }

            Stack[0] = Stack[Top];
            Stack[1] = u;
            Top = 1;
         }
         else if ( Cond2 && !Cond1 )
         {
            while ( Top > 0 &&
                    DLItri_valid_angle( u, Stack[Top], Stack[Top - 1], PlanarX, PlanarY, DistTol ) )
            {
               DLItri_add_diagonal( u, Stack[Top - 1], Stack[Top], PlanarX, PlanarY, mesh_processor );
               Top--;
            }
            Stack[++Top] = &MonoPolys[k];

#if DEBUG_LOGGING
            for ( j = 0; j <= Top; j++ )
            {
               x = Stack[j]->Vertex->coord[PlanarX];
               y = Stack[j]->Vertex->coord[PlanarY];
               fprintf( stderr, "Stack[%d] = ( %d, %d )\n", j, x, y );
            }
#endif
         }
         else
         {      /* both 'Cond1' and 'Cond2' hold */
            for ( i = 1; i <= Top; i++ )
            {
               DLItri_add_diagonal( u, Stack[i], Stack[i - 1], PlanarX, PlanarY, mesh_processor );
            }

            Top = -1;
            break;      /* If we have vertices left, it's a bad polygon. */
         }
      }

      TriMesh.numVerts = VertNum - 1;


      /* Either save the mesh (View Dyn.) or send it to the edgeII board to */
      /* display */

      ( *mesh_processor ) ( &TriMesh );

      for ( k = 0; k <= Top; k++ )
         Stack[k]->VertNo = 0;
      NumTriMeshes++;
      VertNum = 0;


      /* Kill the 'Live edges' of the current monotonic polygon */

      DLItri_clear_mono_edges( NumVerts );
   }

   if ( NumVertices > DLItri_OneKB )
   {
      free( MonoPolys );
      free( Stack );
   }

   return ( NumTriMeshes );

}/* DLItri_create_mesh */
