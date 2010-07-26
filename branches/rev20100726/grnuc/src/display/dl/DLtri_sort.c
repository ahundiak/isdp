#include <stdio.h>
#include <stdlib.h>
#include "wl.h"
#include "igrtypedef.h"
#include "igr.h"
#include "dl.h"
#include "dl_internal.h"

#define BUBSIZE	9

static struct DLItri_vertex **VertexList;
static int PlanarX, PlanarY;

#define EDGEII_DEBUG	0

/*--- DLItri_setup_list ---------------------------------------------------------------------------*/

struct DLItri_vertex **DLItri_setup_list(
   struct DLItri_loop * Facet,
   int NumVertices,
   int Pl_x,
   int Pl_y )

/*
NAME
        DLItri_setup_list (static)

DESCRIPTION
        This function gets an array of pointers to vertices and initializes it to point to the vertices of
        the facet which will then be sorted. In addition, it initializes the static variables 'PlanarX' and
        'PlanarY'.

KEYWORD
        triangulator

PARAMETERS
        Facet (IN) - Used to initialize vertex array.
        NumVertices (IN) - Number of vertices in facet.
        Pl_x, Pl_y (IN) - Indices (0-2) of coordinates to be used as planar x and y.

GLOBALS USED
        PlanarX, PlanarY (IN) - Indices (0-2) of coordinates to be used as planar x and y.

RETURN VALUES
        Pointer to array of vertices composing the facet.

HISTORY
        01/23/90 Created. -Trevor Mink
        06/07/93 Converted to DL - Mike Lanier
*/

{
   int i = 0;

   struct DLItri_vertex *Vertex, *Start;
   struct DLItri_loop *Loop;

   PlanarX = Pl_x;
   PlanarY = Pl_y;

   VertexList = DLItri_get_array( NumVertices );

   for ( Loop = Facet; Loop; Loop = Loop->next )
   {
      Start = Vertex = ( struct DLItri_vertex * ) ( Loop->loop );
      do
      {
         VertexList[i++] = Vertex;
         Vertex = Vertex->next;
      }
      while ( Vertex != Start );
   }

   return ( VertexList );

}/* DLItri_setup_list */

/*--- DLItri_bubble_sort ------------------------------------------------------------------------*/

static void DLItri_bubble_sort(
   int i,
   int j )

/*
NAME
        DLItri_bubble_sort (static)

DESCRIPTION
        This function sorts the list delimited by the indices ('i' and 'j') of 'VertexList'
        using the familiar bubblesort algorithm.

KEYWORD
        triangulator

PARAMETERS
        i, j (IN) - Indices in the array of vertices between which to sort.

GLOBALS USED
        VertexList[] - Array of pointers to vertices.

RETURN VALUES
        none.

HISTORY
        01/24/90 Created. -Trevor Mink
        02/12/92 Mark each edge of the mono polygon as 'LIVE_EDGE'. -Trevor Mink
        06/07/93 Converted to DL - Mike Lanier
*/

{
   int k, Altered;
   struct DLItri_vertex *TempVertex;
   double x1, y1, x2, y2;

   do
   {
      Altered = FALSE;
      for ( k = i; k < j; k++ )
      {
         y1 = VertexList[k]->coord[PlanarY];
         x1 = VertexList[k]->coord[PlanarX];
         y2 = VertexList[k + 1]->coord[PlanarY];
         x2 = VertexList[k + 1]->coord[PlanarX];
         if ( y1 > y2 || ( y1 == y2 && x1 > x2 ) )
         {
            TempVertex = VertexList[k + 1];
            VertexList[k + 1] = VertexList[k];
            VertexList[k] = TempVertex;
            Altered = TRUE;
         }
      }
   }
   while ( Altered );

}/* DLItri_bubble_sort */

/*--- DLItri_partition -----------------------------------------------------------------------*/

static int DLItri_partition(
   int i,
   int j )

/*
NAME
        DLItri_partition (static)

DESCRIPTION
        This function manipulates the given list ('VertexList' between indices 'i' and 'j') and
        finds an entry such that:
        1. The given entry is in its correct final position.
        2. Everything above it will stay above it and everything below it will remain below it in the final
        sorting.

KEYWORD
        triangulator

PARAMETERS
        i, j (IN) - Indices in the array of vertices between which to partition.

GLOBALS USED
        none.

RETURN VALUES
        Partition index of the portion of the list from index i to index j.

HISTORY
        01/23/90 Created. -Trevor Mink
        06/07/93 Converted to DL - Mike Lanier
*/

{
   int Upper, Lower;
   struct DLItri_vertex *SaveRecord, *CompRecord;
   double *SRcoord, *CRcoord;

#if EDGEII_DEBUG
   int x;

   fprintf( stderr, "Partitioning VertexList at i = %d, j = %d\n", i, j );
   for ( x = i; x <= j; x++ )
      fprintf( stderr, "VertexList[%d] = ( %lf, %lf )\n",
          x, VertexList[x]->coord[PlanarX], VertexList[x]->coord[PlanarY] );
#endif

   Upper = i;
   Lower = j;
   SaveRecord = VertexList[i];
   SRcoord = SaveRecord->coord;

   while ( Upper != Lower )
   {
      CompRecord = VertexList[Lower];
      CRcoord = CompRecord->coord;

      while ( Upper < Lower && ( SRcoord[PlanarY] < CRcoord[PlanarY] ||
                                 ( SRcoord[PlanarY] == CRcoord[PlanarY] &&
                                   SRcoord[PlanarX] <= CRcoord[PlanarX] ) ) )
      {
         CompRecord = VertexList[--Lower];
         CRcoord = CompRecord->coord;
      }

      if ( Upper != Lower )
         VertexList[Upper] = VertexList[Lower];

      CompRecord = VertexList[Upper];
      CRcoord = CompRecord->coord;

      while ( Upper < Lower && ( SRcoord[PlanarY] > CRcoord[PlanarY] ||
                                 ( SRcoord[PlanarY] == CRcoord[PlanarY] &&
                                   SRcoord[PlanarX] >= CRcoord[PlanarX] ) ) )
      {
         CompRecord = VertexList[++Upper];
         CRcoord = CompRecord->coord;
      }

      if ( Upper != Lower )
         VertexList[Lower] = VertexList[Upper];
   }

   VertexList[Upper] = SaveRecord;

   return ( Upper );
}/* DLItri_partition */

/*--- DLItri_quick_sort -----------------------------------------------------------------------------*/

void DLItri_quick_sort(
   int i,
   int j )

/*
NAME
        DLItri_quick_sort

DESCRIPTION
        DLItri_quick_sort() is a recursive routine. It takes two integers (indices of 'VertexList) as arguments.
        If the list delimited by 'i' and 'j' is <= BUBSIZE in length, it calls DLItri_bubble_sort() to sort the
        list, otherwise, it calls DLItri_partition() to find the partitioning entry and calls itself for the two
        sublists (created from the partitioning).

KEYWORD
        triangulator

PARAMETERS
        i, j (IN) - Indices in the array of vertices between which to sort.

GLOBALS USED
        none.

RETURN VALUES
        none.

HISTORY
        01/23/90 Created. -Trevor Mink
        06/07/93 Converted to DL - Mike Lanier
*/

{
   int p;

#if EDGEII_DEBUG
   int x;

   for ( x = i; x <= j; x++ )
      fprintf( stderr, "VertexList[%d] = ( %f, %f )\n",
          x, VertexList[x]->coord[PlanarX], VertexList[x]->coord[PlanarY] );
#endif

   if ( i < j )
   {
      if ( j - i < BUBSIZE )
      { /* do DLItri_bubble_sort on this list */
#if EDGEII_DEBUG
         fprintf( stderr, "DLItri_bubble_sorting between %d and %d\n", i, j );
#endif

         DLItri_bubble_sort( i, j );
      }
      else
      {
         p = DLItri_partition( i, j );

#if EDGEII_DEBUG
         fprintf( stderr, "Partitioned at %d\n", p );
#endif

         DLItri_quick_sort( i, ( p - 1 ) );
         DLItri_quick_sort( ( p + 1 ), j );
      }
   }

}/* DLItri_quick_sort */
