
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:33 $
$Locker:  $
*/


#include <stdio.h>
#include <stdlib.h>
#include "wl.h"
#include "igrtypedef.h"
#include "igr.h"
#include "dl.h"
#include "dl_internal.h"

#define DEBUG_LOGGING	0
#define DRAWING	0

#define TOLERANCE_CODE		0
#define EDGE_CROSS_DEBUG	0

static struct DLItri_buf_ptr *edge_buffer_list = DLItri_NIL_BUFPTR;     /* edge buffer list */

/*-- DLItri_alloc_edge --------------------------------------------------------------*/

static struct DLItri_edge *DLItri_alloc_edge(
   void )

/*
NAME
        DLItri_alloc_edge (static)

KEYWORD
        triangulator

DESCRIPTION
        This functions allocates an Edge structure and returns its address.  Space is
        allocated by 'malloc' only when the free storage pool and current
        buffer are empty.

PARAMETERS
        none

GLOBALS USED
        edge_buffer_list (static) - Pointer to the pool of available edge structures.

RETURN VALUES
        A pointer to the edge allocated.
        NULL if out of memory.

HISTORY
        09/01/86 Created. -S. A. Rapa
        11/07/89 Changed to allocate fixed-size buffers. -C. M. Jablonski
        12/11/89 Added element counts to speed cleanup.	 -C. M. Jablonski
        --/--/-- Adapted into edge II triangulation code. -Trevor Mink
        02/21/92 Documented. -Trevor Mink
        06/07/93 Converted to DL - Mike Lanier
*/
{
   struct DLItri_edge *this_edge;
   struct DLItri_buf_ptr *this_buffer;

   if ( ( edge_buffer_list != DLItri_NIL_BUFPTR ) && ( edge_buffer_list->num_left > 0 ) )
   {

      /* get the edge from the current buffer */

      this_edge = ( struct DLItri_edge * ) edge_buffer_list->ele_ptr;
      edge_buffer_list->ele_ptr += edge_buffer_list->ele_size;
      edge_buffer_list->num_left--;
   }
   else
   {

      /* allocate the structures for a new buffer */

      if ( ( this_buffer = ( struct DLItri_buf_ptr * ) malloc( sizeof( struct DLItri_buf_ptr ) ) ) &&
           ( this_buffer->buffer = ( char * ) malloc( DLItri_SixtyKB ) ) )
      {
         this_buffer->ele_ptr = this_buffer->buffer;
         this_buffer->num_left = DLItri_NUM_EDGES_IN_60KB;
         this_buffer->ele_size = sizeof( struct DLItri_edge );
         this_buffer->next = edge_buffer_list;
         edge_buffer_list = this_buffer;

         /* allocate the first edge */

         this_edge = ( struct DLItri_edge * ) edge_buffer_list->ele_ptr;
         edge_buffer_list->ele_ptr += edge_buffer_list->ele_size;
         edge_buffer_list->num_left--;
      }
      else
      {
         DLItri_set_status( DLItri_STAT_ALLOC_ERROR );
         this_edge = NULL;
      }
   }

   return ( this_edge );
}

/*--- DLItri_free_edges -------------------------------------------------------------------------*/

void DLItri_free_edges(
   void )

/*
NAME
        DLItri_free_edges

KEYWORD
        triangulator

DESCRIPTION
        This function gets rid of all edge-pool buffers except the first (if more than one).
        and sets the next free edge point to the beginning.

PARAMETERS
        none

GLOBALS USED
        edge_buffer_list (static) - Pointer to the pool of available edge structures.

RETURN VALUES
        none

HISTORY
        08/20/91 Created. -Trevor Mink
        06/07/93 Converted to DL - Mike Lanier
*/

{
   struct DLItri_buf_ptr *this_buffer, *next_buffer;

   /* cleanup the edge structures */

   if ( edge_buffer_list != DLItri_NIL_BUFPTR )
   {
      for ( this_buffer = edge_buffer_list->next;
            this_buffer != DLItri_NIL_BUFPTR;
            this_buffer = next_buffer )
      {
         next_buffer = this_buffer->next;
         free( ( char * ) this_buffer->buffer );
         free( ( char * ) this_buffer );
      }

      edge_buffer_list->ele_ptr = edge_buffer_list->buffer;
      edge_buffer_list->num_left = DLItri_NUM_EDGES_IN_60KB;
      edge_buffer_list->next = DLItri_NIL_BUFPTR;
   }

}/* DLItri_free_edges */

/*--- DLItri_add_added_edge() --------------------------------------------------------------------*/

static void DLItri_add_added_edge(
   struct DLItri_edge * EdgeToAdd,
   struct DLItri_vertex * Vertex,
   struct DLItri_edge ** EdgeSet,
   short InOutFlag,
   int Cardinality,
   struct DLItri_edge * Left,
   struct DLItri_edge * Right )

/*
NAME
        DLItri_add_added_edge (static)

KEYWORD
        triangulator

DESCRIPTION
        This function adds an edge to the given 'EdgeSet' (In or Out) of the given
        'Vertex'. It adds it to the right of edge 'Left' or to the left of edge 'Right'
        if either of these edges is in the set specified by both the 'InOutFlag' and
        the 'EdgeSet'.

PARAMETERS
        EdgeToAdd - Self explanatory
        Vertex - The vertex whose IN or OUT set gets a new edge
        EdgeSet - The IN or OUT set or edges
        InOutFlag - Indicates which set (i.e. IN or OUT)
        Cardinality - Number of edges currently in set
        Left,Right - Current interval of Active Edge List

GLOBALS USED
        none

RETURN VALUES
        none

HISTORY
        08/15/91 Created. -Trevor Mink
        06/07/93 Converted to DL - Mike Lanier
*/

{
   int i, j, Added = FALSE;
   struct DLItri_edge *SearchEdge;

   if ( InOutFlag == DLItri_OUT )
   {
      if ( Vertex == Left->Top )
         SearchEdge = Left;
      else if ( Vertex == Right->Top )
         SearchEdge = Right;
      else
      {
         EdgeSet[0] = EdgeToAdd;
         SearchEdge = ( struct DLItri_edge * ) NULL;
         Added = TRUE;
      }
   }
   else
   {
      if ( Vertex == Left->Bottom )
         SearchEdge = Left;
      else if ( Vertex == Right->Bottom )
         SearchEdge = Right;
      else
      {
         EdgeSet[0] = EdgeToAdd;
         SearchEdge = ( struct DLItri_edge * ) NULL;
         Added = TRUE;
      }
   }

   for ( i = 0; i < Cardinality && !Added; i++ )
   {
      if ( EdgeSet[i] == SearchEdge )
      {
         if ( SearchEdge == Left )
         {
            for ( j = Cardinality; j > i + 1; j-- )
               EdgeSet[j] = EdgeSet[j - 1];
         }
         else
         {
            for ( j = Cardinality; j > i; j-- )
               EdgeSet[j] = EdgeSet[j - 1];
         }

         EdgeSet[j] = EdgeToAdd;
         Added = TRUE;
      }
   }
}

/*--- DLItri_add_to_set() ----------------------------------------------------------------------------*/

static void DLItri_add_to_set(
   struct DLItri_edge * EdgeToAdd,
   struct DLItri_vertex * Vertex,
   short InOutFlag,
   short Horizontal,
   double DistTol,
   int PlanarY,
   struct DLItri_edge * Left,
   struct DLItri_edge * Right )

/*
NAME
        DLItri_add_to_set (static)

KEYWORD
        triangulator

DESCRIPTION
        This function adds the edge: 'EdgeToAdd' to the given set: 'Set'. The 'InOutFlag'
        designates whether it's an OUTgoing set or an INcoming set.

PARAMETERS
        EdgeToAdd - Self explanatory
        Vertex - The vertex whose IN or OUT set gets a new edge
        InOutFlag - Indicates which set (i.e. IN or OUT)
        Horizontal - Flag indicating that the edges y1 and y2 are equal
        DistTol - EMS distance tolerance
        PlanarY - Number of the coordinate (0-2) that being used as the y value in triangulation
        Left,Right - Current interval of Active Edge List

GLOBALS USED
        none

RETURN VALUES
        none

HISTORY
        01/23/90 Created. -Trevor Mink
        06/07/93 Converted to DL - Mike Lanier
*/
{
   struct DLItri_edge **EdgeSet;
   int i, j, Added = FALSE;
   int Cardinality;
   double Tolerance;

#if DOESNT_SEEMTA_MATTER
   Tolerance = ( DistTol / ( EdgeToAdd->Bottom->coord[PlanarY] - EdgeToAdd->Top->coord[PlanarY] ) );
#else
   Tolerance = 0.0;
#endif

#if DEBUG_LOGGING
   fprintf( stderr, "Horizontal = %d\n", Horizontal );
#endif

   if ( Horizontal )
   {
      if ( InOutFlag == DLItri_OUT )
      {
#if DEBUG_LOGGING
         fprintf( stderr, "Adding edge to OUT set at address %x\n", Vertex );
#endif

         /* Horizontal edges will be the last in the set for the outgoing */
         /* vertex. Multiple horizontal edges in a given 'Out' set */
         /* indicates that the latter edge is an 'Added' edge, and barring */
         /* some unforseen error, should be placed prior to an 'Original' */
         /* horizontal edge. */

         Cardinality = Vertex->OutCardinality;
         if ( Cardinality > 0 )
         {
            if ( Vertex->Out[Cardinality - 1]->EdgeStatus & DLItri_HORIZONTAL_EDGE )
            {
               Vertex->Out[Cardinality] = Vertex->Out[Cardinality - 1];
               Vertex->Out[Cardinality - 1] = EdgeToAdd;
            }
            else
               Vertex->Out[Cardinality] = EdgeToAdd;
         }
         else
            Vertex->Out[Cardinality] = EdgeToAdd;

         Vertex->OutCardinality++;
      }
      else
      {

         /* Horizontal edges will be the first in the set for the incoming   */
         /* vertex */
         /* Same holds here as above, but doesn't require special */
         /* processing */

         for ( j = Vertex->InCardinality; j > 0; j-- )
            Vertex->In[j] = Vertex->In[j - 1];

         Vertex->In[0] = EdgeToAdd;
         Vertex->InCardinality++;
      }
   }
   else if ( InOutFlag == DLItri_OUT )
   {
#if DEBUG_LOGGING
      fprintf( stderr, "Adding edge to OUT set at address %x\n", Vertex );
#endif

      EdgeSet = Vertex->Out;
      Cardinality = Vertex->OutCardinality;

      if ( EdgeToAdd->EdgeStatus & DLItri_ADDED_EDGE )
         DLItri_add_added_edge( EdgeToAdd, Vertex, EdgeSet, InOutFlag, Cardinality, Left, Right );
      else
      {
         for ( i = 0; i < Cardinality && !Added; i++ )
         {
#if DEBUG_LOGGING
            fprintf( stderr, "Out edge #%d\t", i );
            fprintf( stderr, "SlopeInverse = %lf\t", EdgeSet[i]->SlopeInverse );
            fprintf( stderr, "EdgeStatus = %d\n", EdgeSet[i]->EdgeStatus );
#endif

            if ( ( EdgeSet[i]->EdgeStatus & DLItri_HORIZONTAL_EDGE ) ||
                 ( EdgeToAdd->SlopeInverse < EdgeSet[i]->SlopeInverse - Tolerance ) )
            {
#if DEBUG_LOGGING
               fprintf( stderr, "EdgeToAdd->SlopeInverse = %lf\n", EdgeToAdd->SlopeInverse );
               fprintf( stderr, "Out edges %d through %d will shift\n", i, Cardinality );
#endif

               for ( j = Cardinality; j > i; j-- )
                  EdgeSet[j] = EdgeSet[j - 1];

               EdgeSet[i] = EdgeToAdd;
               Added = TRUE;
            }
         }

         if ( !Added )
            EdgeSet[Cardinality] = EdgeToAdd;
      }

      Vertex->OutCardinality++;
   }
   else
   {
#if DEBUG_LOGGING
      fprintf( stderr, "Adding edge to IN set at address %x\n", Vertex );
#endif

      EdgeSet = Vertex->In;
      Cardinality = Vertex->InCardinality;

      if ( EdgeToAdd->EdgeStatus & DLItri_ADDED_EDGE )
         DLItri_add_added_edge( EdgeToAdd, Vertex, EdgeSet, InOutFlag, Cardinality, Left, Right );
      else
      {
         for ( i = 0; i < Cardinality && !Added; i++ )
         {
            if ( !( EdgeSet[i]->EdgeStatus & DLItri_HORIZONTAL_EDGE ) &&
                 ( EdgeToAdd->SlopeInverse > EdgeSet[i]->SlopeInverse + Tolerance ) )
            {

               for ( j = Cardinality; j > i; j-- )
                  EdgeSet[j] = EdgeSet[j - 1];

               EdgeSet[i] = EdgeToAdd;
               Added = TRUE;
            }
         }

         if ( !Added )
            EdgeSet[Cardinality] = EdgeToAdd;
      }

      Vertex->InCardinality++;
   }

}/* DLItri_add_to_set */

/*--- DLItri_add_edge() ----------------------------------------------------------------*/

void DLItri_add_edge(
   struct DLItri_vertex * Vertex1,
   struct DLItri_vertex * Vertex2,
   unsigned short EdgeType,
   int PlanarX,
   int PlanarY,
   struct DLItri_edge * Left,
   struct DLItri_edge * Right,
   double DistTol )

/*
NAME
        DLItri_add_edge

KEYWORD
        triangulator

DESCRIPTION
        This function allocates an edge to go from 'Vertex1' to 'Vertex2' and adds to
        the appropriate edge set of both 'Vertex1' and 'Vertex2'. Also, it sets up the
        edge status and slope-inverse.

PARAMETERS
        EdgeToAdd - Self explanatory
        Vertex1,Vertex2 - The vertices between which the new edge will go
        EdgeType - Collection of EdgeStatus flags
        PlanarX,PlanarY - Number of the coordinates (0-2) that are being used as the x,y
        values in triangulation
        Left,Right - Current interval of Active Edge List
        DistTol - EMS distance tolerance

GLOBALS USED
        none

RETURN VALUES
        none

HISTORY
        01/23/90 Created. -Trevor Mink
        06/07/93 Converted to DL - Mike Lanier
*/

{
   struct DLItri_edge *EdgeToAdd;

#if TOLERANCE_CODE
   double y1, y2;

#endif

#if DEBUG_LOGGING
   fprintf( stderr, "Adding edge from (%lf, %lf) to (%lf, %lf) of type %d\n",
            Vertex1->coord[PlanarX], Vertex1->coord[PlanarY],
            Vertex2->coord[PlanarX], Vertex2->coord[PlanarY], EdgeType );
#endif

   if ( ( EdgeToAdd = DLItri_alloc_edge(  ) ) == ( struct DLItri_edge * ) NULL )
   {

      /* We need a user informative error statement here */

      fprintf( stderr, "EdgeToAdd returned NULL from alloc\nReturning\n" );
      return;
   }

#if DEBUG_LOGGING
   if ( !EdgeToAdd )
      fprintf( stderr, "EdgeToAdd returned NULL from alloc\n" );
#endif

   EdgeToAdd->EdgeStatus = EdgeType;

#if TOLERANCE_CODE
   y1 = Vertex1->coord[PlanarY];
   y2 = Vertex2->coord[PlanarY];
   if ( WITHIN_TOLERANCE( y1, y2, DistTol ) )
#else
      if ( Vertex1->coord[PlanarY] == Vertex2->coord[PlanarY] )
#endif
         EdgeToAdd->EdgeStatus |= DLItri_HORIZONTAL_EDGE;
      else
         EdgeToAdd->SlopeInverse = ( Vertex2->coord[PlanarX] - Vertex1->coord[PlanarX] ) /
            ( Vertex2->coord[PlanarY] - Vertex1->coord[PlanarY] );

#if DEBUG_LOGGING
   fprintf( stderr, "SlopeInverse of EdgeToAdd = %lf\n", EdgeToAdd->SlopeInverse );
#endif

#if TOLERANCE_CODE
   if ( EdgeToAdd->EdgeStatus & DLItri_HORIZONTAL_EDGE )
   {
      if ( Vertex1->coord[PlanarX] < Vertex2->coord[PlanarX] )
      {
         EdgeToAdd->Top = Vertex1;
         EdgeToAdd->Bottom = Vertex2;
         DLItri_add_to_set( EdgeToAdd, Vertex1, DLItri_OUT, TRUE, DistTol, PlanarY, Left, Right );
         DLItri_add_to_set( EdgeToAdd, Vertex2, DLItri_IN, TRUE, DistTol, PlanarY, Left, Right );
      }
      else
      {
         EdgeToAdd->Top = Vertex2;
         EdgeToAdd->Bottom = Vertex1;
         DLItri_add_to_set( EdgeToAdd, Vertex2, DLItri_OUT, TRUE, DistTol, PlanarY, Left, Right );
         DLItri_add_to_set( EdgeToAdd, Vertex1, DLItri_IN, TRUE, DistTol, PlanarY, Left, Right );
      }
   }
   else if ( Vertex1->coord[PlanarY] < Vertex2->coord[PlanarY] )
   {
      EdgeToAdd->Top = Vertex1;
      EdgeToAdd->Bottom = Vertex2;
      DLItri_add_to_set( EdgeToAdd, Vertex1, DLItri_OUT, FALSE, DistTol, PlanarY, Left, Right );
      DLItri_add_to_set( EdgeToAdd, Vertex2, DLItri_IN, FALSE, DistTol, PlanarY, Left, Right );
   }
   else
   {
      EdgeToAdd->Top = Vertex2;
      EdgeToAdd->Bottom = Vertex1;
      DLItri_add_to_set( EdgeToAdd, Vertex2, DLItri_OUT, FALSE, DistTol, PlanarY, Left, Right );
      DLItri_add_to_set( EdgeToAdd, Vertex1, DLItri_IN, FALSE, DistTol, PlanarY, Left, Right );
   }
#else
   if ( Vertex1->coord[PlanarY] < Vertex2->coord[PlanarY] )
   {
      EdgeToAdd->Top = Vertex1;
      EdgeToAdd->Bottom = Vertex2;
      DLItri_add_to_set( EdgeToAdd, Vertex1, DLItri_OUT, FALSE, DistTol, PlanarY, Left, Right );
      DLItri_add_to_set( EdgeToAdd, Vertex2, DLItri_IN, FALSE, DistTol, PlanarY, Left, Right );
   }
   else if ( Vertex1->coord[PlanarY] == Vertex2->coord[PlanarY] )
   {
      if ( Vertex1->coord[PlanarX] < Vertex2->coord[PlanarX] )
      {
         EdgeToAdd->Top = Vertex1;
         EdgeToAdd->Bottom = Vertex2;
         DLItri_add_to_set( EdgeToAdd, Vertex1, DLItri_OUT, TRUE, DistTol, PlanarY, Left, Right );
         DLItri_add_to_set( EdgeToAdd, Vertex2, DLItri_IN, TRUE, DistTol, PlanarY, Left, Right );
      }
      else
      {
         EdgeToAdd->Top = Vertex2;
         EdgeToAdd->Bottom = Vertex1;
         DLItri_add_to_set( EdgeToAdd, Vertex2, DLItri_OUT, TRUE, DistTol, PlanarY, Left, Right );
         DLItri_add_to_set( EdgeToAdd, Vertex1, DLItri_IN, TRUE, DistTol, PlanarY, Left, Right );
      }
   }
   else
   {
      EdgeToAdd->Top = Vertex2;
      EdgeToAdd->Bottom = Vertex1;
      DLItri_add_to_set( EdgeToAdd, Vertex2, DLItri_OUT, FALSE, DistTol, PlanarY, Left, Right );
      DLItri_add_to_set( EdgeToAdd, Vertex1, DLItri_IN, FALSE, DistTol, PlanarY, Left, Right );
   }
#endif

}/* DLIadd_edge */

/*--- DLItri_create_edges() ----------------------------------------------------------------*/

void DLItri_create_edges(
   struct DLItri_loop * Facet,
   int PlanarX,
   int PlanarY,
   double DistTol )

/*
NAME
        DLItri_create_edges

KEYWORD
        triangulator

DESCRIPTION
        This function  takes every loop of the given 'Facet' and creates an edge from vertex
        to vertex for the entire loop.

PARAMETERS
        Facet - The entire facet as it comes from the tiler
        PlanarX,PlanarY - Number of the coordinates (0-2) that are being used as the x,y
        values in triangulation
        DistTol - EMS distance tolerance

GLOBALS USED
        none

RETURN VALUES
        none

HISTORY
        01/29/90 Created. -Trevor Mink
        06/07/93 Converted to DL - Mike Lanier
*/

{
   struct DLItri_loop *Loop;
   struct DLItri_vertex *Start, *Vertex;

   for ( Loop = Facet; Loop; Loop = Loop->next )
   {
      Start = Vertex = ( struct DLItri_vertex * ) ( Loop->loop );
      do
      {
         DLItri_add_edge( Vertex,
                          Vertex->next,
                          DLItri_ORIGINAL_EDGE,
                          PlanarX, PlanarY,
                          ( struct DLItri_edge * ) NULL,
                          ( struct DLItri_edge * ) NULL,
                          DistTol );

         Vertex = Vertex->next;
      }
      while ( Vertex != Start );
   }

}/* DLItri_create_edges */

#if NO_DUPLICATE_EDGES
/*--- DLItri_edge_exists() ----------------------------------------------------------------*/

static int DLItri_edge_exists(
   struct DLItri_vertex * Top,
   struct DLItri_vertex * Bottom )

/*
NAME
        DLItri_edge_exists (static)

KEYWORD
        triangulator

DESCRIPTION
        This function tests whether or not an edge connecting 'Top' and 'Bottom' exists.

PARAMETERS
        Top, Bottom - Top and Bottom vertices of edge for which to check.

GLOBALS USED
        none

RETURN VALUES
        Boolean indicating whether or not edge exists.

HISTORY
        08/05/91 Created. -Trevor Mink
        06/07/93 Converted to DL - Mike Lanier
*/

{
   int i, Cardinality;

   Cardinality = Top->OutCardinality;
   for ( i = 0; i < Cardinality; i++ )
   {
      if ( ( Top->Out[i] )->Bottom == Bottom )
         return TRUE;
   }

   return FALSE;

}/* DLItri_edge_exists */

#endif

/*--- DLItri_switch_edges() ---------------------------------------------------------------*/

static int DLItri_switch_edges(
   struct DLItri_vertex * Vertex1,
   short Set1,
   struct DLItri_edge * Edge1,
   struct DLItri_vertex * Vertex2,
   short Set2,
   struct DLItri_edge * Edge2,
   int PlanarX,
   int PlanarY )


/*
NAME
        DLItri_switch_edges (static)

KEYWORD
        triangulator

DESCRIPTION
        This function takes Edge1 and Edge2 and switches their vertices such that:
        (1) 'Vertex1' is removed from 'Edge1' and replaced by 'Vertex2' from 'Edge2',
        and (2) 'Vertex2' is removed from 'Edge2' and replaced by 'Vertex1' from 'Edge1'.

PARAMETERS
        Vertex1 - The vertex of the first edge that is to be switched
        Vertex2 - The vertex of the second edge that is to be switched
        Set1 - The IN or OUT edge set of Vertex1
        Set2 - The IN or OUT edge set of Vertex2
        Edge1, Edge2 - The edges to be switched
        PlanarX,PlanarY - Number of the coordinates (0-2) that are being used as the x,y

GLOBALS USED
        none

RETURN VALUES
        DLItri_CANNOT_HANDLE - Indicates the edges weren't successfully switched
        DLItri_HANDLED - Indicates the edges WERE successfully switched

HISTORY
        08/05/91 Created. -Trevor Mink
        06/07/93 Converted to DL - Mike Lanier
*/

{
   int i, j, Cardinality;
   short Horizontal;
   struct DLItri_vertex *OtherVert, *OtherVert2;
   double x1, y1, x2, y2;

   /* First remove edges from the appropriate sets */

   if ( Set1 == DLItri_OUT )
   {

      /* Find Edge1 in the OUTgoing set of Vertex1 */

      Cardinality = Vertex1->OutCardinality;
      for ( i = 0; i < Cardinality; i++ )
      {
         if ( Vertex1->Out[i] == Edge1 )
            break;
      }

      if ( i == Cardinality )
         return ( DLItri_CANNOT_HANDLE );

      for ( j = i; j < ( Cardinality - 1 ); j++ )
      {
         /* Should overwrite entry 'i' */

         Vertex1->Out[j] = Vertex1->Out[j + 1];
      }

      ( Vertex1->OutCardinality )--;

      OtherVert = Edge1->Bottom;

      /* Find Edge1 in the INcoming set of OtherVert */

      Cardinality = OtherVert->InCardinality;
      for ( i = 0; i < Cardinality; i++ )
      {
         if ( OtherVert->In[i] == Edge1 )
            break;
      }

      if ( i == Cardinality )
         return ( DLItri_CANNOT_HANDLE );

      for ( j = i; j < ( Cardinality - 1 ); j++ )
      {
         /* Should overwrite entry 'i' */

         OtherVert->In[j] = OtherVert->In[j + 1];
      }

      ( OtherVert->InCardinality )--;
   }
   else
   {

      /* Find Edge1 in the INcoming set of Vertex1 */

      Cardinality = Vertex1->InCardinality;
      for ( i = 0; i < Cardinality; i++ )
      {
         if ( Vertex1->In[i] == Edge1 )
            break;
      }

      if ( i == Cardinality )
         return ( DLItri_CANNOT_HANDLE );

      for ( j = i; j < ( Cardinality - 1 ); j++ )
      {
         /* Should overwrite entry 'i' */

         Vertex1->In[j] = Vertex1->In[j + 1];
      }

      ( Vertex1->InCardinality )--;

      OtherVert = Edge1->Top;

      /* Find Edge1 in the OUTgoing set of OtherVert */

      Cardinality = OtherVert->OutCardinality;
      for ( i = 0; i < Cardinality; i++ )
      {
         if ( OtherVert->Out[i] == Edge1 )
            break;
      }

      if ( i == Cardinality )
         return ( DLItri_CANNOT_HANDLE );

      for ( j = i; j < ( Cardinality - 1 ); j++ )
      {
         /* Should overwrite entry 'i' */

         OtherVert->Out[j] = OtherVert->Out[j + 1];
      }

      ( OtherVert->OutCardinality )--;
   }

   if ( Set2 == DLItri_OUT )
   {

      /* Find Edge2 in the OUTgoing set of Vertex2 */

      Cardinality = Vertex2->OutCardinality;
      for ( i = 0; i < Cardinality; i++ )
      {
         if ( Vertex2->Out[i] == Edge2 )
            break;
      }

      if ( i == Cardinality )
         return ( DLItri_CANNOT_HANDLE );

      for ( j = i; j < ( Cardinality - 1 ); j++ )
      {
         /* Should overwrite entry 'i' */

         Vertex2->Out[j] = Vertex2->Out[j + 1];
      }

      ( Vertex2->OutCardinality )--;

      OtherVert2 = Edge2->Bottom;

      /* Find Edge2 in the INcoming set of OtherVert2 */

      Cardinality = OtherVert2->InCardinality;
      for ( i = 0; i < Cardinality; i++ )
      {
         if ( OtherVert2->In[i] == Edge2 )
            break;
      }

      if ( i == Cardinality )
         return ( DLItri_CANNOT_HANDLE );

      for ( j = i; j < ( Cardinality - 1 ); j++ )
      {
         /* Should overwrite entry 'i' */

         OtherVert2->In[j] = OtherVert2->In[j + 1];
      }

      ( OtherVert2->InCardinality )--;
   }
   else
   {

      /* Find Edge2 in the INcoming set of Vertex2 */

      Cardinality = Vertex2->InCardinality;
      for ( i = 0; i < Cardinality; i++ )
      {
         if ( Vertex2->In[i] == Edge2 )
            break;
      }

      if ( i == Cardinality )
         return ( DLItri_CANNOT_HANDLE );

      for ( j = i; j < ( Cardinality - 1 ); j++ )
      {
         /* Should overwrite entry 'i' */

         Vertex2->In[j] = Vertex2->In[j + 1];
      }

      ( Vertex2->InCardinality )--;

      OtherVert2 = Edge2->Top;


      /* Find Edge2 in the OUTgoing set of OtherVert2 */

      Cardinality = OtherVert2->OutCardinality;
      for ( i = 0; i < Cardinality; i++ )
      {
         if ( OtherVert2->Out[i] == Edge2 )
            break;
      }

      if ( i == Cardinality )
         return ( DLItri_CANNOT_HANDLE );

      for ( j = i; j < ( Cardinality - 1 ); j++ )
      {
         /* Should overwrite entry 'i' */

         OtherVert2->Out[j] = OtherVert2->Out[j + 1];
      }

      ( OtherVert2->OutCardinality )--;
   }

   /* Now set up the two NEW edges */

   x1 = OtherVert->coord[PlanarX];
   y1 = OtherVert->coord[PlanarY];
   x2 = Vertex2->coord[PlanarX];
   y2 = Vertex2->coord[PlanarY];

   Horizontal = ( y1 == y2 );

   if ( y1 < y2 || ( Horizontal && x1 < x2 ) )
   {
      Edge1->Top = OtherVert;
      Edge1->Bottom = Vertex2;

#if NO_DUPLICATE_EDGES
      if ( DLItri_edge_exists( OtherVert, Vertex2 ) )
      {
         DLItri_del_set_from_AEL( &Edge1, 1, TRUE );
         DLItri_free_edge( Edge1 );
      }
      else
      {
#endif
         if ( Horizontal )
            Edge1->EdgeStatus |= DLItri_HORIZONTAL_EDGE;
         else
         {
            Edge1->EdgeStatus &= ~DLItri_HORIZONTAL_EDGE;
            Edge1->SlopeInverse = ( Vertex2->coord[PlanarX] - OtherVert->coord[PlanarX] ) /
               ( Vertex2->coord[PlanarY] - OtherVert->coord[PlanarY] );
         }

         DLItri_add_to_set( Edge1, OtherVert, DLItri_OUT, Horizontal, 0.0, PlanarY, ( struct DLItri_edge * ) NULL, ( struct DLItri_edge * ) NULL );
         DLItri_add_to_set( Edge1, Vertex2, DLItri_IN, Horizontal, 0.0, PlanarY, ( struct DLItri_edge * ) NULL, ( struct DLItri_edge * ) NULL );

#if NO_DUPLICATE_EDGES
      }
#endif
   }
   else
   {
      Edge1->Top = Vertex2;
      Edge1->Bottom = OtherVert;

#if NO_DUPLICATE_EDGES
      if ( DLItri_edge_exists( Vertex2, OtherVert ) )
      {
         DLItri_del_set_from_AEL( &Edge1, 1, TRUE );
         DLItri_free_edge( Edge1 );
      }
      else
      {
#endif
         if ( Horizontal )
            Edge1->EdgeStatus |= DLItri_HORIZONTAL_EDGE;
         else
         {
            Edge1->EdgeStatus &= ~DLItri_HORIZONTAL_EDGE;
            Edge1->SlopeInverse = ( OtherVert->coord[PlanarX] - Vertex2->coord[PlanarX] ) /
               ( OtherVert->coord[PlanarY] - Vertex2->coord[PlanarY] );
         }

         DLItri_add_to_set( Edge1, Vertex2, DLItri_OUT, Horizontal, 0.0, PlanarY, ( struct DLItri_edge * ) NULL, ( struct DLItri_edge * ) NULL );
         DLItri_add_to_set( Edge1, OtherVert, DLItri_IN, Horizontal, 0.0, PlanarY, ( struct DLItri_edge * ) NULL, ( struct DLItri_edge * ) NULL );

#if NO_DUPLICATE_EDGES
      }
#endif
   }

   x1 = OtherVert2->coord[PlanarX];
   y1 = OtherVert2->coord[PlanarY];
   x2 = Vertex1->coord[PlanarX];
   y2 = Vertex1->coord[PlanarY];
   Horizontal = ( y1 == y2 );

   if ( y1 < y2 || ( Horizontal && x1 < x2 ) )
   {
      Edge2->Top = OtherVert2;
      Edge2->Bottom = Vertex1;

#if NO_DUPLICATE_EDGES
      if ( DLItri_edge_exists( OtherVert2, Vertex1 ) )
      {
         DLItri_del_set_from_AEL( &Edge2, 1, TRUE );
         DLItri_free_edge( Edge2 );
      }
      else
      {
#endif
         if ( Horizontal )
            Edge2->EdgeStatus |= DLItri_HORIZONTAL_EDGE;
         else
            Edge2->SlopeInverse = ( Vertex1->coord[PlanarX] - OtherVert2->coord[PlanarX] ) /
               ( Vertex1->coord[PlanarY] - OtherVert2->coord[PlanarY] );

         DLItri_add_to_set( Edge2, OtherVert2, DLItri_OUT, Horizontal, 0.0, PlanarY, ( struct DLItri_edge * ) NULL, ( struct DLItri_edge * ) NULL );
         DLItri_add_to_set( Edge2, Vertex1, DLItri_IN, Horizontal, 0.0, PlanarY, ( struct DLItri_edge * ) NULL, ( struct DLItri_edge * ) NULL );

#if NO_DUPLICATE_EDGES
      }
#endif
   }
   else
   {
      Edge2->Top = Vertex1;
      Edge2->Bottom = OtherVert2;

#if NO_DUPLICATE_EDGES
      if ( DLItri_edge_exists( Vertex1, OtherVert2 ) )
      {
         DLItri_del_set_from_AEL( &Edge2, 1, TRUE );
         DLItri_free_edge( Edge2 );
      }
      else
      {
#endif
         if ( Horizontal )
            Edge2->EdgeStatus |= DLItri_HORIZONTAL_EDGE;
         else
            Edge2->SlopeInverse = ( OtherVert2->coord[PlanarX] - Vertex1->coord[PlanarX] ) /
               ( OtherVert2->coord[PlanarY] - Vertex1->coord[PlanarY] );

         DLItri_add_to_set( Edge2, Vertex1, DLItri_OUT, Horizontal, 0.0, PlanarY, ( struct DLItri_edge * ) NULL, ( struct DLItri_edge * ) NULL );
         DLItri_add_to_set( Edge2, OtherVert2, DLItri_IN, Horizontal, 0.0, PlanarY, ( struct DLItri_edge * ) NULL, ( struct DLItri_edge * ) NULL );

#if NO_DUPLICATE_EDGES
      }
#endif
   }

   return ( DLItri_HANDLED );

}/* DLItri_switch_edges */


/*--- DLItri_find_connecting_edge() ---------------------------------------------------------*/

static struct DLItri_edge *DLItri_find_connecting_edge(
   struct DLItri_vertex * TopVert,
   struct DLItri_vertex * BottomVert )

/*
NAME
        DLItri_find_connecting_edge (static)

KEYWORD
        triangulator

DESCRIPTION
        This function looks for an edge that connects 'TopVert' with 'BottomVert'.
        If one is found, it return a pointer to it.

PARAMETERS
        TopVert,BottomVert - The top and bottom vertices of the would-be edge

GLOBALS USED
        none

RETURN VALUES
        A pointer to the edge found
        NULL - No edge found

HISTORY
        08/05/91 Created. -Trevor Mink
        06/07/93 Converted to DL - Mike Lanier
*/

{
   int i, Cardinality;
   struct DLItri_edge *TheEdge;

   Cardinality = TopVert->OutCardinality;
   for ( i = 0; i < Cardinality; i++ )
   {
      TheEdge = TopVert->Out[i];
      if ( TheEdge->Bottom == BottomVert )
      {
         return ( TheEdge );
      }
   }

   return ( ( struct DLItri_edge * ) NULL );

}/* DLItri_find_connecting_edge */

/*--- DLItri_handle_crossing_edges() -----------------------------------------------------------*/

int DLItri_handle_crossing_edges(
   struct DLItri_edge * First,
   struct DLItri_edge * Second,
   int PlanarX,
   int PlanarY )

/*
NAME
        DLItri_handle_crossing_edges

KEYWORD
        triangulator

DESCRIPTION
        This function gets called when two edges on the Active Edge List (AEL) are found to
        no longer be in their proper order. They haven't been switched around, therefore, they must
        have crossed. This function figures out how the edges can be switched around so that the
        regularization process can continue and the triangulator can handle the resulting monotonic
        polygons.

NOTE
        The looks of the facet may be slightly altered, but probably not significantly.

PARAMETERS
        First, Second - The two edges found to cross
        PlanarX,PlanarY - Number of the coordinates (0-2) that are being used as the x,y
        values in triangulation.

GLOBALS USED
        none

RETURN VALUES
        DLItri_CANNOT_HANDLE - Indicates the edges weren't successfully switched
        DLItri_HANDLED - Indicates the edges WERE successfully switched

HISTORY
        08/03/91 Created. -Trevor Mink
        06/07/93 Converted to DL - Mike Lanier
*/

{
#if EDGE_CROSS_DEBUG
   void DLItri_print_facet(  );

#endif

   int Handled;
   struct DLItri_edge *Edge1, *Edge2, *Connector;
   double y1, y2, x1, x2;

   y1 = First->Top->coord[PlanarY];
   y2 = Second->Top->coord[PlanarY];
   x1 = First->Top->coord[PlanarX];
   x2 = Second->Top->coord[PlanarX];

   if ( y1 < y2 || ( y1 == y2 && x1 < x2 ) )
   {
      Edge1 = First;
      Edge2 = Second;
   }
   else
   {
      Edge1 = Second;
      Edge2 = First;
   }

   /* Try to find an edge which connects the two edges */

   if ( ( Connector = DLItri_find_connecting_edge( Edge1->Top, Edge2->Top ) ) &&
        ( Connector != Edge1 ) && ( Connector != Edge2 ) )
      ( void ) DLItri_switch_edges( Edge1->Top, DLItri_OUT, Edge1, Edge2->Top, DLItri_OUT, Edge2, PlanarX, PlanarY );
   else if ( ( Connector = DLItri_find_connecting_edge( Edge1->Bottom, Edge2->Bottom ) ) &&
             ( Connector != Edge1 ) && ( Connector != Edge2 ) )
      ( void ) DLItri_switch_edges( Edge1->Bottom, DLItri_IN, Edge1, Edge2->Bottom, DLItri_IN, Edge2, PlanarX, PlanarY );
   else if ( ( Connector = DLItri_find_connecting_edge( Edge1->Top, Edge2->Bottom ) ) &&
             ( Connector != Edge1 ) && ( Connector != Edge2 ) )
      ( void ) DLItri_switch_edges( Edge1->Top, DLItri_OUT, Edge1, Edge2->Bottom, DLItri_IN, Edge2, PlanarX, PlanarY );
   else if ( ( Connector = DLItri_find_connecting_edge( Edge2->Top, Edge1->Bottom ) ) &&
             ( Connector != Edge1 ) && ( Connector != Edge2 ) )
      ( void ) DLItri_switch_edges( Edge2->Top, DLItri_OUT, Edge2, Edge1->Bottom, DLItri_IN, Edge1, PlanarX, PlanarY );
   else if ( ( Connector = DLItri_find_connecting_edge( Edge2->Bottom, Edge1->Bottom ) ) &&
             ( Connector != Edge1 ) && ( Connector != Edge2 ) )
      ( void ) DLItri_switch_edges( Edge2->Bottom, DLItri_IN, Edge2, Edge1->Bottom, DLItri_IN, Edge1, PlanarX, PlanarY );
   else
   {
#if EDGE_CROSS_DEBUG
      fprintf( stderr, "I cannot handle these edges!\n" );
      fprintf( stderr, "Edge 1: %x going from %lf,%lf to %lf, %lf\n",
               First, First->Top->coord[PlanarX], First->Top->coord[PlanarY],
             First->Bottom->coord[PlanarX], First->Bottom->coord[PlanarY] );
      fprintf( stderr, "Edge 2: %x going from %lf,%lf to %lf, %lf\n",
           Second, Second->Top->coord[PlanarX], Second->Top->coord[PlanarY],
           Second->Bottom->coord[PlanarX], Second->Bottom->coord[PlanarY] );

      DLItri_print_facet( Facet );
#endif

      Handled = DLItri_CANNOT_HANDLE;
   }

   return ( Handled );

}/* DLItri_handle_crossing_edges */
