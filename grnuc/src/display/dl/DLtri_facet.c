/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:33 $
$Locker:  $
*/

#include <stdio.h>
#include <malloc.h>
#include "wl.h"
#include "igrtypedef.h"
#include "igr.h"
#include "dl.h"
#include "dl_internal.h"

static int LoopVertices = 0;

static struct DLItri_vertex *PrevPoint = ( struct DLItri_vertex * ) NULL;
static struct DLItri_vertex *ThisPoint = ( struct DLItri_vertex * ) NULL;
static struct DLItri_vertex *FirstPoint = ( struct DLItri_vertex * ) NULL;
static struct DLItri_loop *Facet = ( struct DLItri_loop * ) NULL;
static struct DLItri_loop *ThisLoop = ( struct DLItri_loop * ) NULL;
static struct DLItri_loop *PrevLoop = ( struct DLItri_loop * ) NULL;

static struct DLItri_buf_ptr *vertex_buffer_list = DLItri_NIL_BUFPTR;   /* vertex buffer list */
static struct DLItri_buf_ptr *bound_buffer_list = DLItri_NIL_BUFPTR;    /* bound buffer list */
static struct DLItri_buf_ptr *ptr_buffer_list = DLItri_NIL_BUFPTR;      /* Ptr buffer list */

#define EDGEII_DEBUG	0
#define FACET_DEBUG	0
#define TRIMESH_DEBUG	0
#define MALLOC_DEBUG    0
#define DEBUG_LOGGING		0

#define OLD_TRIANG	0

#if MALLOC_DEBUG
/*---DEBUG_Malloc---------------------------------------------------------*/

static char *DEBUG_Malloc(
   int num_bytes )

{
   char *address_of_malloced;

   address_of_malloced = malloc( num_bytes );
   fprintf( stderr, "Malloced %d bytes at address %x\n", num_bytes, address_of_malloced );
   return ( address_of_malloced );

}/* DEBUG_Malloc */

/*---DEBUG_Free------------------------------------------------------------*/

static void DEBUG_Free(
   char *address_of_freement )

{
   fprintf( stderr, "Freed memory at address %x\n", address_of_freement );
   free( address_of_freement );

}/* DEBUG_Free */

#define malloc	DEBUG_Malloc
#define free	DEBUG_Free

#endif  /* MALLOC_DEBUG */


static struct DLItri_vertex **VertArray_static = ( struct DLItri_vertex ** ) NULL;

/*---DLItri_get_array---------------------------------------------------------------------------*/

struct DLItri_vertex **DLItri_get_array(
   int TotalVertices )

/*
NAME
    DLItri_get_array

DESCRIPTION
    DLItri_get_array() allocates a ONE_K long array of pointers to edge2 vertices and
    keeps it around. If a bigger one is needed, it is malloced, and freed later.
    It returns the beginning address of the appropriate array.

HISTORY
    01/23/90 Created - Trevor Mink
    06/07/93 Converted to DL - Mike Lanier
 */

{
   struct DLItri_vertex **ArrayOfVertices;

   if ( !VertArray_static )
      VertArray_static = ( struct DLItri_vertex ** ) malloc( DLItri_OneKB * sizeof( struct DLItri_vertex * ) );

   if ( TotalVertices > DLItri_OneKB )
      ArrayOfVertices = ( struct DLItri_vertex ** ) malloc( TotalVertices * sizeof( struct DLItri_vertex * ) );
   else
      ArrayOfVertices = VertArray_static;

   return ( ArrayOfVertices );

}/* DLItri_get_array */


/*---DLItri_alloc_vert_ptr---------------------------------------------------------*/

struct DLItri_polygon_vert *DLItri_alloc_vert_ptr(
   void )

/*
NAME
    DLItri_alloc_vert_ptr

DESCRIPTION
    alloc_VertPtr() allocates a monotonic vertex and returns a pointer to it.

HISTORY
    02/06/90: Created - Trevor Mink
    06/07/93: Converted to DL - Mike Lanier
 */

{
   struct DLItri_polygon_vert *this_ptr;
   struct DLItri_buf_ptr *this_buffer;

   if ( ( ptr_buffer_list != DLItri_NIL_BUFPTR ) && ( ptr_buffer_list->num_left > 0 ) )
   {

      /* get the ptr from the current buffer */

      this_ptr = ( struct DLItri_polygon_vert * ) ptr_buffer_list->ele_ptr;
      ptr_buffer_list->ele_ptr += ptr_buffer_list->ele_size;
      ptr_buffer_list->num_left--;
   }
   else
   {

      /* allocate the structures for a new buffer */

      if ( ( this_buffer = ( struct DLItri_buf_ptr * ) malloc( sizeof( struct DLItri_buf_ptr ) ) ) &&
           ( this_buffer->buffer = ( char * ) malloc( DLItri_NUM_PTRS_IN_4KB * sizeof( struct DLItri_polygon_vert ) ) ) )
      {
         this_buffer->ele_ptr = this_buffer->buffer;
         this_buffer->num_left = DLItri_NUM_PTRS_IN_4KB;
         this_buffer->ele_size = sizeof( struct DLItri_polygon_vert );
         this_buffer->next = ptr_buffer_list;
         ptr_buffer_list = this_buffer;

         /* allocate the first ptr */

         this_ptr = ( struct DLItri_polygon_vert * ) ptr_buffer_list->ele_ptr;
         ptr_buffer_list->ele_ptr += ptr_buffer_list->ele_size;
         ptr_buffer_list->num_left--;
      }
      else
      {
         DLItri_set_status( DLItri_STAT_ALLOC_ERROR );
         this_ptr = NULL;
      }
   }

   if ( this_ptr )
      this_ptr->Next = ( struct DLItri_polygon_vert * ) NULL;

   return ( this_ptr );

}/* DLItri_alloc_vert_ptr */


/*-- DLItri_alloc_vertex --------------------------------------------------------------*/

struct DLItri_vertex *DLItri_alloc_vertex(
   void )

/*
NAME
    DLItri_alloc_vertex

DESCRIPTION
    Allocates an DLItri_vertex structure and returns its address.  Space is
    allocated by 'malloc' only when the free storage pool and current
    buffer are empty.

HISTORY
    09/01/86 Created.					S. A. Rapa
    11/07/89 Changed to allocate fixed-size buffers.	C. M. Jablonski
    12/11/89 Added element counts to speed cleanup.	C. M. Jablonski
    06/07/93 Converted to DL                            Mike Lanier
 */

{
   struct DLItri_vertex *this_vertex;
   struct DLItri_buf_ptr *this_buffer;

   if ( ( vertex_buffer_list != DLItri_NIL_BUFPTR ) && ( vertex_buffer_list->num_left > 0 ) )
   {

      /* get the vertex from the current buffer */

      this_vertex = ( struct DLItri_vertex * ) vertex_buffer_list->ele_ptr;
      vertex_buffer_list->ele_ptr += vertex_buffer_list->ele_size;
      vertex_buffer_list->num_left--;
   }
   else
   {

      /* allocate the structures for a new buffer */

      if ( ( this_buffer = ( struct DLItri_buf_ptr * ) malloc( sizeof( struct DLItri_buf_ptr ) ) ) &&
           ( this_buffer->buffer = ( char * ) malloc( DLItri_NUM_VERTICES_IN_60KB * sizeof( struct DLItri_vertex ) ) ) )
      {
         this_buffer->ele_ptr = this_buffer->buffer;
         this_buffer->num_left = DLItri_NUM_VERTICES_IN_60KB;
         this_buffer->ele_size = sizeof( struct DLItri_vertex );
         this_buffer->next = vertex_buffer_list;
         vertex_buffer_list = this_buffer;

         /* allocate the first vertex */

         this_vertex = ( struct DLItri_vertex * ) vertex_buffer_list->ele_ptr;
         vertex_buffer_list->ele_ptr += vertex_buffer_list->ele_size;
         vertex_buffer_list->num_left--;
      }
      else
      {
         DLItri_set_status( DLItri_STAT_ALLOC_ERROR );
         this_vertex = NULL;
      }
   }

   this_vertex->InCardinality = 0;
   this_vertex->OutCardinality = 0;
   this_vertex->LocalExtremity = 0x00000000;
   LoopVertices++;

   return ( this_vertex );
}

/*-- DLItri_alloc_loop --------------------------------------------------------------*/

struct DLItri_loop *DLItri_alloc_loop(
   void )

/*
NAME
    DLItri_alloc_loop

DESCRIPTION
    Allocates an DLItri_loop structure and returns its address.  Space is
    allocated by 'malloc' only when the free storage pool and current
    buffer are empty.

HISTORY
    09/01/86 Created.					S. A. Rapa
    11/07/89 Changed to allocate fixed-size buffers.	C. M. Jablonski
    12/11/89 Added element counts to speed cleanup.	C. M. Jablonski
    06/07/93 Converted to DL                            Mike Lanier
 */

{
   struct DLItri_loop *this_bound;
   struct DLItri_buf_ptr *this_buffer;

   if ( ( bound_buffer_list != DLItri_NIL_BUFPTR ) && ( bound_buffer_list->num_left > 0 ) )
   {

      /* get the bound from the current buffer */

      this_bound = ( struct DLItri_loop * ) bound_buffer_list->ele_ptr;
      bound_buffer_list->ele_ptr += bound_buffer_list->ele_size;
      bound_buffer_list->num_left--;
   }
   else
   {

      /* allocate the structures for a new buffer */

      if ( ( this_buffer = ( struct DLItri_buf_ptr * ) malloc( sizeof( struct DLItri_buf_ptr ) ) ) &&
           ( this_buffer->buffer = ( char * ) malloc( DLItri_NUM_BOUNDS_IN_4KB * sizeof( struct DLItri_loop ) ) ) )
      {
         this_buffer->ele_ptr = this_buffer->buffer;
         this_buffer->num_left = DLItri_NUM_BOUNDS_IN_4KB;
         this_buffer->ele_size = sizeof( struct DLItri_loop );
         this_buffer->next = bound_buffer_list;
         bound_buffer_list = this_buffer;

         /* allocate the first bound */

         this_bound = ( struct DLItri_loop * ) bound_buffer_list->ele_ptr;
         bound_buffer_list->ele_ptr += bound_buffer_list->ele_size;
         bound_buffer_list->num_left--;
      }
      else
      {
         DLItri_set_status( DLItri_STAT_ALLOC_ERROR );
         this_bound = NULL;
      }
   }

   return ( this_bound );

}/* DLItri_alloc_loop */

/*---DLItri_end_loop----------------------------------------------------------------_*/

void DLItri_end_loop(
   void )

/*
NAME
    DLItri_end_loop

DESCRIPTION
    DLItri_end_loop() ends the current loop so that new calls to 'HSadd_vertex'
    adds points to a new DLItri_loop.

HISTORY
    02/14/90 Created.			Trevor Mink
    06/07/93 Converted to DL            Mike Lanier
 */

{
   if ( PrevPoint )
   {
      PrevPoint->next = FirstPoint;
      ThisLoop = DLItri_alloc_loop(  );

#if SHADING_ACTIVE
      if ( tiling_parms.status == DLItri_STAT_ALLOC_ERROR )
         return;
#endif

      if ( Facet == ( struct DLItri_loop * ) NULL )
         Facet = ThisLoop;
      else
         PrevLoop->next = ThisLoop;

      ThisLoop->next = ( struct DLItri_loop * ) NULL;
      ThisLoop->loop = FirstPoint;
      ThisLoop->Vertices = LoopVertices;
      LoopVertices = 0;
      PrevPoint = ( struct DLItri_vertex * ) NULL;
      PrevLoop = ThisLoop;
   }

}/* DLItri_end_loop */

/*-- DLItri_cleanup_triangulator_structures -----------------------------------------------*/

static void DLItri_cleanup_triangulator_structures(
   void )

/*
NAME
   DLItri_cleanup_triangulator_structures (static)

DESCRIPTION
    Frees all boundary structure buffers and resets the free lists.

HISTORY
    11/07/89 Created.					C. M. Jablonski
    12/11/89 Added element counts to speed cleanup.	C. M. Jablonski
    06/07/93 Converted to DL                            Mike Lanier
*/

{
   struct DLItri_buf_ptr *this_buffer, *next_buffer;

   /* cleanup the point structures */

   if ( vertex_buffer_list != DLItri_NIL_BUFPTR )
   {
      for ( this_buffer = vertex_buffer_list->next;
            this_buffer != DLItri_NIL_BUFPTR;
            this_buffer = next_buffer )
      {
         next_buffer = this_buffer->next;
         free( ( char * ) this_buffer->buffer );
         free( ( char * ) this_buffer );
      }

      vertex_buffer_list->ele_ptr = vertex_buffer_list->buffer;
      vertex_buffer_list->num_left = DLItri_NUM_VERTICES_IN_60KB;
      vertex_buffer_list->next = DLItri_NIL_BUFPTR;
   }

   /* cleanup the bound structures */

   if ( bound_buffer_list != DLItri_NIL_BUFPTR )
   {
      for ( this_buffer = bound_buffer_list->next;
            this_buffer != DLItri_NIL_BUFPTR;
            this_buffer = next_buffer )
      {
         next_buffer = this_buffer->next;
         free( ( char * ) this_buffer->buffer );
         free( ( char * ) this_buffer );
      }

      bound_buffer_list->ele_ptr = bound_buffer_list->buffer;
      bound_buffer_list->num_left = DLItri_NUM_BOUNDS_IN_4KB;
      bound_buffer_list->next = DLItri_NIL_BUFPTR;
   }

   /* cleanup the ptr structures */

   if ( ptr_buffer_list != DLItri_NIL_BUFPTR )
   {
      for ( this_buffer = ptr_buffer_list->next;
            this_buffer != DLItri_NIL_BUFPTR;
            this_buffer = next_buffer )
      {
         next_buffer = this_buffer->next;
         free( ( char * ) this_buffer->buffer );
         free( ( char * ) this_buffer );
      }

      ptr_buffer_list->ele_ptr = ptr_buffer_list->buffer;
      ptr_buffer_list->num_left = DLItri_NUM_PTRS_IN_4KB;
      ptr_buffer_list->next = DLItri_NIL_BUFPTR;
   }
}

/*---DLItri_dispose_facet-----------------------------------------------------*/

void DLItri_dispose_facet(
   void )

/*
NAME
    DLItri_dispose_facet

DESCRIPTION
    DLItri_dispose_facet() frees all of the vertices and loops of 'Facet'.

HISTORY
    02/14/90 Created.			Trevor Mink
    06/07/93 Converted to DL            Mike Lanier
 */


{
   DLItri_cleanup_triangulator_structures(  );
   DLItri_free_edges(  );       /* Actually will free all edges */

}/* DLItri_dispose_facet */


/*---DLItri_add_vertex-----------------------------------------------------------*/

void DLItri_add_vertex(
   double x,
   double y,
   double z,
   double w,
   char e,
   double nx,
   double ny,
   double nz,
   double dum1,
   double dum2 )

/*
NAME
    DLItri_add_vertex

DESCRIPTION
    DLItri_add_vertex() adds a vertex (with normals if smooth shading) to the current
    loop of the current facet.  If no loop or facet is active, then they are established.

HISTORY
    02/14/90 Created.				Trevor Mink
    06/07/93 Converted to DL                    Mike Lanier
*/

{
   ThisPoint = DLItri_alloc_vertex(  );

#if SHADING_ACTIVE
   if ( tiling_parms.status == DLItri_STAT_ALLOC_ERROR )
      return;
#endif

   ThisPoint->coord[0] = x;
   ThisPoint->coord[1] = y;
   ThisPoint->coord[2] = z;
   ThisPoint->coord[3] = w;

#if DEBUG_LOGGING
   fprintf( stderr, "Alloced vertex ThisPoint = %x\n", ThisPoint );
   fprintf( stderr, "x, y, z, w = %lf, %lf, %lf, %lf\n",
            x, y, z, w );
#endif

#if SHADING_ACTIVE
   if ( element_parms.doing_vertex_normals )
   {
#if DEBUG_LOGGING
      fprintf( stderr, "normal = %lf, %lf, %lf\n", nx, ny, nz );
#endif

      ThisPoint->norm[0] = nx;
      ThisPoint->norm[1] = ny;
      ThisPoint->norm[2] = nz;
   }
   else
      ThisPoint->norm[0] = 0.0;
#endif

   if ( PrevPoint )
      PrevPoint->next = ThisPoint;
   else
      FirstPoint = ThisPoint;

   PrevPoint = ThisPoint;

#if DEBUG_LOGGING
   fprintf( stderr, "Leaving DLItri_add_vertex\n" );
#endif
}/* DLItri_add_vertex */

/*---DLItri_check_for_dups----------------------------------------------------*/

static int DLItri_check_for_dups(
   struct DLItri_loop * Loop,
   struct DLItri_vertex * vertex_list,
   int PlanarX,
   int PlanarY,
   int PlanarZ,
   double dis_tol )

{
   int Dups = 0;
   struct DLItri_vertex *last_point, *stop_point;

#if FACET_DEBUG
   fprintf( stderr, "dis_tol = %f\n", dis_tol );
#endif

   /* It is critical to the polybusting routine that polygons do not cross */
   /* themselves in the xy plane; to be safe, force adjacent points which */
   /* are 'close' to be exactly equal in x and y.  This prevents floating */
   /* exceptions in the polybuster caused when trying to divide by a very */
   /* small delta Y during interpolation. */

   stop_point = vertex_list;
   do
   {
      last_point = vertex_list;
      vertex_list = vertex_list->next;

      if ( DLItri_FABS( vertex_list->coord[PlanarX] - last_point->coord[PlanarX] ) < dis_tol )
         vertex_list->coord[PlanarX] = last_point->coord[PlanarX];

      if ( DLItri_FABS( vertex_list->coord[PlanarY] - last_point->coord[PlanarY] ) < dis_tol )
         vertex_list->coord[PlanarY] = last_point->coord[PlanarY];

      /* Must do z's too (for perspective cases) */

      if ( DLItri_FABS( vertex_list->coord[PlanarZ] - last_point->coord[PlanarZ] ) < dis_tol )
         vertex_list->coord[PlanarZ] = last_point->coord[PlanarZ];

      /* If vertices are equal in x and y, get rid of one */

      if ( vertex_list->coord[PlanarY] == last_point->coord[PlanarY] &&
           vertex_list->coord[PlanarX] == last_point->coord[PlanarX] )
      {

         /* Toss the vertex */

#if FACET_DEBUG
         fprintf( stderr, "Vertex = (%f, %f, %f) was tossed\n", vertex_list->coord[PlanarX],
                  vertex_list->coord[PlanarY], vertex_list->coord[PlanarZ] );
#endif

         last_point->next = vertex_list->next;
         if ( vertex_list == Loop->loop )
         {
            Loop->loop = vertex_list->next;
            stop_point = vertex_list->next;
         }

         vertex_list = last_point;
         Dups++;
      }

   }
   while ( vertex_list != stop_point || ( ( vertex_list == last_point ) && ( vertex_list != vertex_list->next ) ) );

   return ( Dups );

}/* DLItri_check_for_dups */

/*---DLItri_mesh_loops--------------------------------------------------------------------*/

void DLItri_mesh_loops(
   double dis_tol,
   double *facet_normal,
   int (*mesh_processor)() )

/*
NAME
    DLItri_mesh_loops

DESCRIPTION
    DLItri_mesh_loops() ends the current loop and calls 'DLItri_process_facet()' to create a triangular mesh
    and send it off to the EDGEII.

HISTORY
    02/14/90 Created. 		Trevor Mink
    06/07/93 Converted to DL    Mike Lanier
 */

{
   int Dups, TotalVertices = 0;
   struct DLItri_vertex *Vertex, *StopVertex;
   struct DLItri_loop *Loop;
   int PlanarX = 0, PlanarY = 0, PlanarZ, Greatest, Next;

   if ( PrevPoint )
   {
#if EDGEII_DEBUG
      fprintf( stderr, "calling DLItri_end_loop()\n" );
#endif

      DLItri_end_loop(  );
   }

#if SHADING_ACTIVE
   if ( tiling_parms.status == DLItri_STAT_ALLOC_ERROR )
      return;
#endif

   for ( Loop = Facet; Loop; Loop = Loop->next )
   {
      Vertex = Loop->loop;

      StopVertex = Vertex;
      Loop->Vertices = 0;
      do
      {
         Vertex = Vertex->next;
         Loop->Vertices++;
      }
      while ( Vertex != StopVertex );

      TotalVertices += Loop->Vertices;

      /* Determine against which plane to project the facet according to */
      /* the normal */

#if TRIMESH_DEBUG
      fprintf( stderr, "facet_normal: %lf, %lf, %lf\n", facet_normal[0], facet_normal[1], facet_normal[2] );
#endif

      Greatest = 0;
      for ( Next = 1; Next <= 2; Next++ )
      {
         if ( DLItri_FABS( facet_normal[Next] ) >
              DLItri_FABS( facet_normal[Greatest] ) )
            Greatest = Next;
      }

      if ( Greatest != 0 )
      {
#if TRIMESH_DEBUG
         fprintf( stderr, "x is coord[0]\n" );
#endif

         PlanarX = 0;
         if ( Greatest != 1 )
         {
#if TRIMESH_DEBUG
            fprintf( stderr, "y is coord[1]\n" );
            fprintf( stderr, "z is coord[2]\n" );
#endif

            PlanarY = 1;
            PlanarZ = 2;
         }
         else
         {
#if TRIMESH_DEBUG
            fprintf( stderr, "y is coord[2]\n" );
            fprintf( stderr, "z is coord[1]\n" );
#endif

            PlanarY = 2;
            PlanarZ = 1;
         }
      }
      else
      {
#if TRIMESH_DEBUG
         fprintf( stderr, "x is coord[1]\n" );
         fprintf( stderr, "y is coord[2]\n" );
         fprintf( stderr, "z is coord[0]\n" );
#endif

         PlanarX = 1;
         PlanarY = 2;
         PlanarZ = 0;
      }

      /* Toss vertices within a tolerance of the ems 'DistTol' */

      Dups = DLItri_check_for_dups( Loop, Vertex, PlanarX, PlanarY, PlanarZ, dis_tol );

      Loop->Vertices -= Dups;
      TotalVertices -= Dups;
   }

   if ( Facet )
   {
      ( void ) DLItri_process_facet( Facet,
                                     TotalVertices,
                                     PlanarX,
                                     PlanarY,
                                     dis_tol,
                                     mesh_processor );

      DLItri_dispose_facet(  );
      Facet = ( struct DLItri_loop * ) NULL;
   }

}/* DLItri_mesh_loops */
