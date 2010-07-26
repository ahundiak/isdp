#include <stdio.h>
#include <stdlib.h>
#include "wl.h"
#include "igrtypedef.h"
#include "igr.h"
#include "dl.h"
#include "dl_internal.h"

#define UNDETERMINED	3
#define CROSSING_EDGES	2
#define VALID		1
#define INVALID		0

#define DOWN_SWEEP	1
#define UP_SWEEP	2

static struct DLItri_edge *Left, *Right, *AEL;
static int PlanarX, PlanarY;


#define DEBUG_LOGGING			0
#define TEMP_DEBUG		0
#define DRAWING			0
#define TRIMESH_DEBUG		0
#define BAD_BOUND_DEBUG		0
#define EDGE_CROSS_DEBUG	0


#if BAD_BOUND_DEBUG

/*---DLItri_print_AEL-------------------------------------------------------_*/

static void DLItri_print_AEL(
   int PlanarX,
   int PlanarY )

/*
NAME
    DLItri_print_AEL

DESCRIPTION
    Displays the active edge list

HISTORY
    06/07/93 Converted to DL - Mike Lanier
*/

{
   struct DLItri_edge *TheEdge;

   fprintf( stderr, "Here is the active edge list\n" );
   for ( TheEdge = AEL; TheEdge; TheEdge = TheEdge->Next )
   {
      fprintf( stderr, "TheEdge: %x from (%f, %f) to (%f, %f)\n", TheEdge,
               TheEdge->Top->coord[PlanarX], TheEdge->Top->coord[PlanarY],
         TheEdge->Bottom->coord[PlanarX], TheEdge->Bottom->coord[PlanarY] );
   }
}

#endif

/*--- DLItri_add_set_to_AEL() ----------------------------------------------------------------*/

static void DLItri_add_set_to_AEL(
   struct DLItri_vertex * Vertex,
   short InOutFlag )

/*
NAME
        DLItri_add_set_to_AEL (static)

DESCRIPTION
        This function adds the edges of the given set (identified by 'Vertex' and distin-
        guished by 'InOutFlag') to the Active Edge List between the 'Left' and 'Right' edge
        pointers found in DLItri_find_interval().

KEYWORD
        triangulator

PARAMETERS
        Vertex (IN) - The current vertex.
        InOutFlag (IN) - Determines which set (IN or OUT) of edges for the vertex will be added.

GLOBALS USED
        Left,Right - Two edges that comprise the current interval on the active edge list.
        AEL - Pointer to the Head of the Active Edge List.

RETURN VALUES
        none.

HISTORY
        01/25/90 Created. -Trevor Mink
        06/07/93 Converted to DL - Mike Lanier
*/

{
   int Cardinality, i;
   struct DLItri_edge **EdgeArray, *TempLeft;

#if DEBUG_LOGGING
   int j;

#endif

   if ( InOutFlag == DLItri_OUT )
   {
      Cardinality = Vertex->OutCardinality;
      EdgeArray = Vertex->Out;

#if DEBUG_LOGGING
      fprintf( stderr, "Cardinality for OUT set = %d\n", Cardinality );
      for ( j = 0; j < Cardinality; j++ )
         fprintf( stderr, "Vertex->Out[%d] = %x\n", j, EdgeArray[j] );
#endif
   }
   else
   {
      Cardinality = Vertex->InCardinality;
      EdgeArray = Vertex->In;

#if DEBUG_LOGGING
      fprintf( stderr, "Cardinality for IN set = %d\n", Cardinality );
      for ( j = 0; j < Cardinality; j++ )
         fprintf( stderr, "Vertex->In[%d] = %x\n", j, EdgeArray[j] );
#endif
   }


   /* Use temporary 'TempLeft' to keep from altering 'Left' */

   TempLeft = Left;

   for ( i = 0; i < Cardinality; i++ )
   {

      /* Add non-ADDED_EDGEs and make sure they aren't there already */

      if ( !( EdgeArray[i]->EdgeStatus & ( DLItri_ADDED_EDGE | DLItri_ON_AEL ) ) )
      {
#if DEBUG_LOGGING
         fprintf( stderr, "Adding edge %x with vertex top = (%lf, %lf)\t", EdgeArray[i],
                  EdgeArray[i]->Top->coord[PlanarX], EdgeArray[i]->Top->coord[PlanarY] );
         fprintf( stderr, "and vertex bottom = (%lf, %lf) to AEL\n",
                  EdgeArray[i]->Bottom->coord[PlanarX], EdgeArray[i]->Bottom->coord[PlanarY] );
#endif

         EdgeArray[i]->Extreme_y = Vertex;
         if ( !TempLeft )
            AEL = EdgeArray[i];
         else
            TempLeft->Next = EdgeArray[i];

         EdgeArray[i]->Next = Right;
         EdgeArray[i]->EdgeStatus |= DLItri_ON_AEL;
         TempLeft = EdgeArray[i];
      }
   }

}/* DLItri_add_set_to_AEL */

/*--- DLItri_del_set_from_AEL ------------------------------------------------------------------------*/

static void DLItri_del_set_from_AEL(
   struct DLItri_edge ** EdgeArray,
   int Cardinality )

/*
NAME
        DLItri_del_set_from_AEL (static)

DESCRIPTION
        This function removes the 'Cardinality' edges of the given set (identified by 'EdgeArray')
        from the Active Edge List (if they're there) between the 'Left' and final edge of the AEL.

KEYWORD
        triangulator

PARAMETERS
        EdgeArray (IN) - Set of Incoming or Outgoing edges of the active edge list.
        Cardinality (IN) - The number of edges in the set.

GLOBALS USED
        Left,Right - Two edges that comprise the current interval on the active edge list.
        AEL - Pointer to the Head of the Active Edge List.

RETURN VALUES
        none.

HISTORY
        01/25/90 Created. -Trevor Mink
        06/07/93 Converted to DL - Mike Lanier
*/
{
   int i;
   struct DLItri_edge *Previous, *Current;

#if DEBUG_LOGGING
   int j;

   fprintf( stderr, "Cardinality for set = %d\n", Cardinality );
   for ( j = 0; j < Cardinality; j++ )
      fprintf( stderr, "EdgeArray[%d] = %x\n", j, EdgeArray[j] );
#endif

   Previous = ( struct DLItri_edge * ) NULL;
   Current = AEL;
   for ( i = 0; i < Cardinality && Current; )
   {
      if ( EdgeArray[i]->EdgeStatus & DLItri_ADDED_EDGE || !( EdgeArray[i]->EdgeStatus & DLItri_ON_AEL ) )
      {
         i++;
         continue;      /* Return to top of loop and restart */
      }
      if ( Current == EdgeArray[i] )
      {
#if DEBUG_LOGGING
         fprintf( stderr, "Removing edge %x from AEL\n", EdgeArray[i] );
#endif

         if ( Previous )
         {
            Previous->Next = Current->Next;
            Current = Current->Next;
         }
         else
         {
            AEL = Current->Next;
            Current = AEL;
         }


         /* Mark edge asx being OFF the AEL  */

         EdgeArray[i]->Next = ( struct DLItri_edge * ) NULL;
         EdgeArray[i]->EdgeStatus &= ~DLItri_ON_AEL;

         i++;

         /* Probably will need this due even with the detection and */
         /* hanDLItri_ng of crossing edges in 'FindInterval()' */

         /* Start at front of list to find next edge */

         Previous = ( struct DLItri_edge * ) NULL;
         Current = AEL;
      }
      else
      {
         Previous = Current;
         Current = Current->Next;
      }
   }

}/* DLItri_del_set_from_AEL */

/*--- DLItri_weed_AEL() ---------------------------------------------------------------------*/

static int DLItri_weed_AEL(
   short InOutFlag,
   struct DLItri_vertex * Vertex,
   double x,
   double y )

/*
NAME
        DLItri_weed_AEL (static)

DESCRIPTION
        This function removes edges from the AEL that shouldn't be on it due to an
        edge-switch. This must be done because they might not be removed otherwise.

KEYWORD
        triangulator

PARAMETERS
        InOutFlag (IN) - Determines which set (IN or OUT) of edges for the vertex will be checked.
        Vertex (IN) - The current vertex.
        x,y (IN) - Coordinate of the current vertex.

GLOBALS USED
        AEL - Pointer to the Head of the Active Edge List.

RETURN VALUES
        Boolean indicating whether Active Edge List was changed.

HISTORY
        09/24/91 Created. -Trevor Mink
        06/07/93 Converted to DL - Mike Lanier
*/

{
   struct DLItri_edge *ThisEdge, *Previous;
   short Changed = FALSE;

   if ( AEL )
   {
      Previous = ( struct DLItri_edge * ) NULL;
      for ( ThisEdge = AEL; ThisEdge; )
      {
         if ( ( ( InOutFlag == DLItri_OUT ) && ( ThisEdge->Bottom != Vertex ) ) ||
              ( ( InOutFlag == DLItri_IN ) && ( ThisEdge->Top != Vertex ) ) )
         {
            if ( ( ( ThisEdge->Bottom->coord[PlanarY] < y ) ||
                   ( ( ThisEdge->Bottom->coord[PlanarY] == y ) &&
                     ( ThisEdge->Bottom->coord[PlanarX] < x ) ) )
                 ||
                 ( ( ThisEdge->Top->coord[PlanarY] > y ) ||
                   ( ( ThisEdge->Top->coord[PlanarY] == y ) &&
                     ( ThisEdge->Top->coord[PlanarX] > x ) ) ) )
            {

               /* Mark edge as being OFF the AEL */

               ThisEdge->EdgeStatus &= ~DLItri_ON_AEL;

               if ( Previous )
                  Previous->Next = ThisEdge->Next;
               else
                  AEL = ThisEdge->Next;

               Changed = TRUE;
            }
            else
               Previous = ThisEdge;
         }
         else
            Previous = ThisEdge;

         if ( ThisEdge )
            ThisEdge = ThisEdge->Next;
      }
   }

   return ( Changed );

}/* DLItri_weed_AEL */

/*--- DLItri_sort_AEL() ----------------------------------------------------------------------*/

static int DLItri_sort_AEL(
   void )

/*
NAME
        DLItri_weed_AEL (static)

DESCRIPTION
        This function places the Active Edge List back into sorted order. It may have
        been corrupted by HSswitchEdges().

KEYWORD
        triangulator

PARAMETERS
        none.

GLOBALS USED
        AEL - Pointer to the Head of the Active Edge List.

RETURN VALUES
        Boolean indicating whether Active Edge List was changed.

HISTORY
        08/19/91 Created. -Trevor Mink
        06/07/93 converted to DL - Mike Lanier
*/

{
   struct DLItri_edge *ThisEdge, *NextEdge, *Previous;
   short Switched, Changed = FALSE;

   if ( AEL )
      do
      {
         Switched = FALSE;
         Previous = ( struct DLItri_edge * ) NULL;

         for ( ThisEdge = AEL; ( NextEdge = ThisEdge->Next ); )
         {
            if ( NextEdge->x_intercept < ThisEdge->x_intercept )
            {
               ThisEdge->Next = NextEdge->Next;

               if ( Previous )
                  Previous->Next = NextEdge;
               else
                  AEL = NextEdge;

               NextEdge->Next = ThisEdge;

               Switched = Changed = TRUE;
               Previous = NextEdge;
            }
            else
            {
               Previous = ThisEdge;
               ThisEdge = NextEdge;
            }
         }
      }

      while ( Switched );

   return ( Changed );

}/* DLItri_sort_AEL */

/*--- DLItri_get_one_intercept() -------------------------------------------------------------*/

static void DLItri_get_one_intercept(
   struct DLItri_vertex * Vertex,
   double y,
   struct DLItri_edge * ThisEdge,
   short SweepDirection )

/*
NAME
        DLItri_get_one_intercept (static)

DESCRIPTION
        This function calculates the x-intercept for one edge of the AEL and
        stores it with the edge.

KEYWORD
        triangulator

PARAMETERS
        Vertex (IN) - The current vertex.
        y (IN) - y coordinate of current vertex.
        ThisEdge (IN) - The edge for which to determine the x-intercept.
        SweepDirection (IN) - Whether we're going from top-to-bottom (DOWN_SWEEP) or
        bottom-to-top (UP_SWEEP)

GLOBALS USED
        AEL - Pointer to the Head of the Active Edge List.

RETURN VALUES
        Boolean indicating whether Active Edge List was changed.

HISTORY
        08/19/91 Created. -Trevor Mink
        02/13/92 Added 'SweepDirection' parameter for horizontal edge intercept determination.
        06/07/93 Converted to DL - Mike Lanier
*/

{
   double *VertexCoord;

   /***********************************/
   /* Get the x intercept of the edge */
   /***********************************/

   if ( Vertex == ThisEdge->Bottom || Vertex == ThisEdge->Top )
   {
      if ( SweepDirection == DOWN_SWEEP )
      {
         if ( Vertex == ThisEdge->Bottom )
            ThisEdge->x_intercept = ThisEdge->Bottom->coord[PlanarX];
         else
            ThisEdge->x_intercept = ThisEdge->Top->coord[PlanarX];
      }
      else
      {
         if ( Vertex == ThisEdge->Bottom )
            ThisEdge->x_intercept = ThisEdge->Top->coord[PlanarX];
         else
            ThisEdge->x_intercept = ThisEdge->Bottom->coord[PlanarX];
      }
   }
   else
   {
      if ( ThisEdge->EdgeStatus & DLItri_HORIZONTAL_EDGE )
      {
         if ( SweepDirection == UP_SWEEP )
            ThisEdge->x_intercept = ThisEdge->Bottom->coord[PlanarX];
         else
            ThisEdge->x_intercept = ThisEdge->Top->coord[PlanarX];
      }
      else
      {
         VertexCoord = ThisEdge->Top->coord;
         ThisEdge->x_intercept = ThisEdge->SlopeInverse * ( y - VertexCoord[PlanarY] ) + VertexCoord[PlanarX];
      }
   }

}/* DLItri_get_one_intercept */

/*--- DLItri_get_intercepts() ---------------------------------------------------------*/

void DLItri_get_intercepts(
   struct DLItri_vertex * Vertex,
   double y,
   short SweepDirection )

/*
NAME
        DLItri_get_intercepts

DESCRIPTION
        This function calculates the x-intercept for every edge on the AEL and
        stores it with the edge.

KEYWORD
        triangulator

PARAMETERS
        Vertex (IN) - The current vertex.
        y (IN) - y coordinate of current vertex.
        ThisEdge (IN) - The edge for which to determine the x-intercept.
        SweepDirection (IN) - Whether we're going from top-to-bottom (DOWN_SWEEP) or
        bottom-to-top (UP_SWEEP)

GLOBALS USED
        AEL - Pointer to the Head of the Active Edge List.

RETURN VALUES
        None

HISTORY
        08/19/91 Created. -Trevor Mink
        02/13/92 Added 'SweepDirection' parameter for horizontal edge intercept determination.
        06/07/93 Converted to DL - Mike Lanier
        06/08/93 Set function type to void
*/
{
   struct DLItri_edge *ThisEdge;
   double *VertexCoord;

   for ( ThisEdge = AEL; ThisEdge; ThisEdge = ThisEdge->Next )
   {
      /* Get the x intercept of the edge */

      if ( Vertex == ThisEdge->Bottom || Vertex == ThisEdge->Top )
      {
         if ( Vertex == ThisEdge->Bottom )
            ThisEdge->x_intercept = ThisEdge->Bottom->coord[PlanarX];
         else
            ThisEdge->x_intercept = ThisEdge->Top->coord[PlanarX];
      }
      else
      {
         if ( ThisEdge->EdgeStatus & DLItri_HORIZONTAL_EDGE )
         {
#if FALSE
            if ( SweepDirection == UP_SWEEP )
               ThisEdge->x_intercept = ThisEdge->Bottom->coord[PlanarX];
            else
               ThisEdge->x_intercept = ThisEdge->Top->coord[PlanarX];
#endif

            ThisEdge->x_intercept = Vertex->coord[PlanarX];
         }
         else
         {
            VertexCoord = ThisEdge->Top->coord;
            ThisEdge->x_intercept = ThisEdge->SlopeInverse * ( y - VertexCoord[PlanarY] ) + VertexCoord[PlanarX];
         }
      }
   }

}/* DLItri_get_intercepts */

/*--- DLItri_check_for_crossing_edges() -------------------------------------------------------------*/

static int DLItri_check_for_crossing_edges(
   struct DLItri_vertex * Vertex,
   double y,
   short InOutFlag,
   double Tolerance,
   short SweepDirection )

/*
NAME
        DLItri_check_for_crossing_edges (static)

DESCRIPTION
        This function goes through the Active Edge List and checks it for crossing edges.
        If any are found DLItri_handle_crossing_edges() is called. That function will switch the
        edges if it can.

KEYWORD
        triangulator

PARAMETERS
        Vertex (IN) - The current vertex.
        y (IN) - y coordinate of current vertex.
        InOutFlag (IN) - Determines which set (IN or OUT) of edges for the vertex will be checked.
        Tolerance (IN) - The amount by which edges may legally cross (measured in x).

GLOBALS USED
        none.

RETURN VALUES
        DLItri_CANNOT_HANDLE - If DLItri_handle_crossing_edges() returns this.
        VALID - No crossing edges were found.
        CROSSING_EDGES (crossing edges that were handled okay.

HISTORY
        08/19/91 Created. -Trevor Mink
        08/03/91 Changed to search the entire active edge list every time and call
                 DLItri_handle_crossing_edges() when crossing edges are found. -Trevor Mink
        02/13/92 Added 'SweepDirection' parameter for horizontal edge intercept determination.
                -Trevor Mink
        06/07/93 Converted to DL - Mike Lanier
*/

{
   struct DLItri_edge *ThisEdge, *NextEdge;
   int sts = VALID;
   double x;

   x = Vertex->coord[PlanarX];

   for ( ThisEdge = AEL; ThisEdge && ( NextEdge = ThisEdge->Next ); ThisEdge = ThisEdge->Next )
   {
      if ( ( NextEdge->x_intercept + Tolerance ) < ThisEdge->x_intercept )
      {
         if ( DLItri_handle_crossing_edges( ThisEdge, NextEdge, PlanarX, PlanarY ) == DLItri_CANNOT_HANDLE )
            return ( DLItri_CANNOT_HANDLE );
         else
         {

            /* Edges uncrossed */

            DLItri_get_one_intercept( Vertex, y, ThisEdge, SweepDirection );
            DLItri_get_one_intercept( Vertex, y, NextEdge, SweepDirection );

            sts = CROSSING_EDGES;
            DLItri_sort_AEL(  );
            ( void ) DLItri_weed_AEL( InOutFlag, Vertex, x, y );
         }
      }
   }

   return ( sts );

}/* DLItri_check_for_crossing_edges */

/*--- DLItri_find_interval() --------------------------------------------------------------------------*/

static int DLItri_find_interval(
   struct DLItri_vertex * Vertex,
   double y,
   short InOutFlag,
   short SweepDirection,
   double dis_tol )

/*
NAME
        DLItri_find_interval (static)

DESCRIPTION
        This function searches the Active Edge List (AEL) to find the interval in which the
        given vertex lies. It sets the statics 'Left' and 'Right' to show the edges.

KEYWORD
        triangulator

PARAMETERS
        Vertex (IN) - The current vertex.
        y (IN) - y coordinate of current vertex.
        InOutFlag (IN) - Determines which set (IN or OUT) of edges for the vertex will be checked.
        SweepDirection (IN) - Whether we're going from top-to-bottom (DOWN_SWEEP) or
        bottom-to-top (UP_SWEEP)

NOTES
        If 'Left' is null, an insertion would be at the head of the AEL. If 'Right' is null, the
        insertion would be at the end. If both are null, no edges were on the AEL and insertion
        is obvious.

GLOBALS USED
        Left,Right - Two edges that comprise the current interval on the active edge list.
        AEL - Pointer to the Head of the Active Edge List.

RETURN VALUES
        DLItri_CANNOT_HANDLE - If DLItri_handle_crossing_edges() could not handle the crossing edges.
        VALID - No crossing edges were found.
        CROSSING_EDGES - Crossing edges that were handled okay.

HISTORY
        01/24/90 Created. -Trevor Mink
        06/07/93 Converted to DL - Mike Lanier
*/

{
   int sts = UNDETERMINED;
   struct DLItri_edge *SaveRight = ( struct DLItri_edge * ) NULL;
   double x;

#if BAD_BOUND_DEBUG
   DLItri_print_AEL( PlanarX, PlanarY );
#endif

   DLItri_get_intercepts( Vertex, y, SweepDirection );

   if ( ( sts = DLItri_check_for_crossing_edges( Vertex, y, InOutFlag, dis_tol, SweepDirection ) ) == DLItri_CANNOT_HANDLE )
      return ( CROSSING_EDGES );

   x = Vertex->coord[PlanarX];

   Left = AEL;
   Right = ( struct DLItri_edge * ) NULL;
   while ( Left )
   {
      SaveRight = Right;
      Right = Left->Next;

      if ( DLItri_WITHIN_TOLERANCE( x, Left->x_intercept, dis_tol ) )
         x = Vertex->coord[PlanarX] = Left->x_intercept;

      if ( DLItri_WITHIN_TOLERANCE( x, Right->x_intercept, dis_tol ) )
         x = Vertex->coord[PlanarX] = Right->x_intercept;

      if ( ( Left->x_intercept <= x ) && ( x <= Right->x_intercept ) )
      {
#if DEBUG_LOGGING
         fprintf( stderr, "Valid interval found between left_x = %f and right_x = %f for x = %f\n",
            Left->x_intercept, Right->x_intercept, Vertex->coord[PlanarX] );
#endif

         return ( VALID );
      }
      else
      {
         if ( x < Left->x_intercept )
         {
#if DEBUG_LOGGING
            fprintf( stderr, "Invalid interval (left of leftmost edge) x = %f xleft = %f\n",
                     Vertex->coord[PlanarX], xl_intercept );
#endif

            Right = Left;
            Left = SaveRight;

            return ( INVALID );
         }
      }

      Left = Right->Next;
   }

   if ( !Left )
   {
      Left = Right;
      Right = ( struct DLItri_edge * ) NULL;
   }
   else
   {
      Right = Left;
      Left = SaveRight;
   }

   return ( INVALID );

}/* DLItri_find_interval */

/*--- DLItri_regularize() ---------------------------------------------------------------------------*/

static struct DLItri_polygon_vert *DLItri_regularize(
   struct DLItri_vertex ** VertexList,
   int NumVertices,
   double dis_tol )

/*
NAME
        DLItri_regularize (static)

DESCRIPTION
        This function adds edges to the IN/OUT edge sets such that the solid portion of the
        original polygon/hole(s) is made up entirely of monotonic polygons. It makes two
        passes through the sorted vertices (one in increasing order, one decreasing).

KEYWORD
        triangulator

PARAMETERS
        VertexList (IN) - An array of pointers to the vertices of the polygon (sorted by y,x).
        NumVertices (IN) - The number of vertices in the polygon.

GLOBALS USED
        Left,Right - Two edges that comprise the current interval on the active edge list.
        AEL - Pointer to the Head of the Active Edge List.

RETURN VALUES
        A pointer to a list of all Local Minima including duplicates if applicable.

HISTORY
        01/25/90 Created. -Trevor Mink
        06/07/93 Converted to DL - Mike Lanier
*/

{
   int i, Interval, SweepDirection;
   unsigned short AddedEdge = DLItri_ADDED_EDGE;
   struct DLItri_vertex *Vertex, *Vertex2;
   struct DLItri_polygon_vert *Poly = ( struct DLItri_polygon_vert * ) NULL, *Polygons = ( struct DLItri_polygon_vert * ) NULL;
   double *LeftCoord, *RightCoord;

   AEL = ( struct DLItri_edge * ) NULL;
   Left = ( struct DLItri_edge * ) NULL;
   Right = ( struct DLItri_edge * ) NULL;


   /* Do the first sweep (Top-to-bottom) */

   SweepDirection = DOWN_SWEEP;
   for ( i = 0; i < NumVertices; i++ )
   {
      Vertex = VertexList[i];


      /* Find Interval of vertex in AEL */

      if ( ( Interval = DLItri_find_interval( Vertex, Vertex->coord[PlanarY], DLItri_OUT, SweepDirection, dis_tol ) ) == VALID )
      {

         /* Are there no INcoming edges? */

         if ( Vertex->InCardinality == 0 )
         {

            /* Determine the greater 'Extreme_y' vertex */
            /* ('EdgeX->Extreme_y') between the two edges of the interval */

            LeftCoord = Left->Extreme_y->coord;
            RightCoord = Right->Extreme_y->coord;

            if ( RightCoord[PlanarY] > LeftCoord[PlanarY] ||
                 ( RightCoord[PlanarY] == LeftCoord[PlanarY] &&
                   RightCoord[PlanarX] > LeftCoord[PlanarX] ) )
               Vertex2 = Right->Extreme_y;
            else
               Vertex2 = Left->Extreme_y;

            if ( Vertex2->OutCardinality > 0 )
            {
#if DEBUG_LOGGING
               fprintf( stderr, "Local minimum was found at Vertex ( %lf, %lf )\n",
                        Vertex->coord[PlanarX], Vertex->coord[PlanarY] );
#endif

               Vertex2->LocalExtremity |= DLItri_LOCAL_MINIMUM;
               if ( !Polygons )
               {
                  Polygons = DLItri_alloc_vert_ptr(  );
                  Poly = Polygons;
               }
               else
               {
                  Poly->Next = DLItri_alloc_vert_ptr(  );
                  Poly = Poly->Next;
               }

               Poly->Vertex = Vertex2;
            }

            DLItri_add_edge( Vertex, Vertex2, AddedEdge, PlanarX, PlanarY, Left, Right, dis_tol );
         }
         else
         {

            /* INcoming edge(s) */

            Left->Extreme_y = Vertex;
            Right->Extreme_y = Vertex;
         }
      }
      else if ( Interval == CROSSING_EDGES )
      {

         /* Set the Active Edge List to null */

         AEL = ( struct DLItri_edge * ) NULL;
         Left = ( struct DLItri_edge * ) NULL;
         Right = ( struct DLItri_edge * ) NULL;

         return ( ( struct DLItri_polygon_vert * ) NULL );
      }
      else
      {
         if ( Vertex->InCardinality == 0 )
         {
#if DEBUG_LOGGING
            fprintf( stderr, "Local minimum was found at Vertex ( %lf, %lf )\n",
                     Vertex->coord[PlanarX], Vertex->coord[PlanarY] );
#endif

            Vertex->LocalExtremity |= DLItri_LOCAL_MINIMUM;
            if ( !Polygons )
            {
               Polygons = DLItri_alloc_vert_ptr(  );
               Poly = Polygons;
            }
            else
            {
               Poly->Next = DLItri_alloc_vert_ptr(  );
               Poly = Poly->Next;
            }

            Poly->Vertex = Vertex;
         }
      }

#if DEBUG_LOGGING
      fprintf( stderr, "Placing all OUTgoing vertices of Vertex = %x onto AEL\n", Vertex );
#endif

      /* Place all edges OUTgoing from 'Vertex' on the AEL */

      DLItri_add_set_to_AEL( Vertex, DLItri_OUT );

#if DEBUG_LOGGING
      fprintf( stderr, "Removing all INcoming vertices of Vertex = %x from AEL\n", Vertex );
#endif

      /* Remove any edges INcoming to 'Vertex' from the AEL */

      DLItri_del_set_from_AEL( Vertex->In, Vertex->InCardinality );
   }

   AEL = ( struct DLItri_edge * ) NULL;
   Left = ( struct DLItri_edge * ) NULL;
   Right = ( struct DLItri_edge * ) NULL;

   /* Do the second sweep (Bottom-to-top) */

   SweepDirection = UP_SWEEP;
   for ( i = NumVertices - 1; i >= 0; i-- )
   {
      Vertex = VertexList[i];

      /* Find Interval of vertex in AEL */

      if ( ( Interval = DLItri_find_interval( Vertex, Vertex->coord[PlanarY], DLItri_IN, SweepDirection, dis_tol ) ) == VALID )
      {

         /* Are there no OUTgoing edges? */

         if ( Vertex->OutCardinality == 0 )
         {
            /* Determine the lesser 'Extreme_y' vertex 'EdgeX->Extreme_y' */
            /* between the two edges of the interval */

            LeftCoord = Left->Extreme_y->coord;
            RightCoord = Right->Extreme_y->coord;

            if ( RightCoord[PlanarY] < LeftCoord[PlanarY] ||
                 ( RightCoord[PlanarY] == LeftCoord[PlanarY] &&
                   RightCoord[PlanarX] < LeftCoord[PlanarX] ) )
               Vertex2 = Right->Extreme_y;
            else
               Vertex2 = Left->Extreme_y;

            if ( Vertex2->InCardinality > 0 )
               Vertex2->LocalExtremity |= DLItri_LOCAL_MAXIMUM;

            DLItri_add_edge( Vertex, Vertex2, AddedEdge, PlanarX, PlanarY, Left, Right, dis_tol );
         }
         else
         {

            /* OUTgoing edge(s) */

            Left->Extreme_y = Vertex;
            Right->Extreme_y = Vertex;
         }
      }
      else if ( Interval == CROSSING_EDGES )
      {

         /* Set the Active Edge List to null */

         AEL = ( struct DLItri_edge * ) NULL;
         Left = ( struct DLItri_edge * ) NULL;
         Right = ( struct DLItri_edge * ) NULL;

         return ( ( struct DLItri_polygon_vert * ) NULL );
      }
      else
      {
         if ( Vertex->OutCardinality == 0 )
            Vertex->LocalExtremity |= DLItri_LOCAL_MAXIMUM;
      }

#if DEBUG_LOGGING
      fprintf( stderr, "Placing all INcoming vertices of Vertex = %x onto AEL\n", Vertex );
#endif

      /* Place all edges INcoming to 'Vertex' on the AEL */

      DLItri_add_set_to_AEL( Vertex, DLItri_IN );

#if DEBUG_LOGGING
      fprintf( stderr, "Removing all OUTgoing vertices of Vertex = %x from AEL\n", Vertex );
#endif

      /* Remove any edges OUTgoing from 'Vertex' from the AEL */

      DLItri_del_set_from_AEL( Vertex->Out, Vertex->OutCardinality );
   }

   return ( Polygons );

}/* DLItri_regularize */

#define MAX_LOOPS	20

#if BAD_BOUND_DEBUG
/*--- DLItri_print_facet() ---------------------------------------------------------------------------*/

static void DLItri_print_facet(
   struct DLItri_loop * Facet,
   char filename[20] )

/*
NAME
        DLItri_print_facet (static)

DESCRIPTION
        This function prints the facet. (What did you think it did?)
        It's used for debugging. Surprise!

KEYWORD
        triangulator

PARAMETERS
        Facet (IN) - Only needed for debugging.
        filename (IN) - Name of external file to which to print the debug data.

GLOBALS USED
        none.

RETURN VALUES
        none

HISTORY
        02/14/90 Created. -Trevor Mink
        06/07/93 Converted to DL - Mike Lanier
*/

{
   int NumLoops = 0, NumVerts[MAX_LOOPS], i;
   struct DLItri_loop *Loop;
   struct DLItri_vertex *StartVertex, *Vertex;
   FILE *outfile;

   for ( Loop = Facet; Loop; Loop = Loop->next )
   {
      NumVerts[NumLoops] = 0;
      StartVertex = Vertex = Loop->loop;
      do
      {
         NumVerts[NumLoops]++;

         fprintf( stderr, "Vertex #%d at addr: %x is (%lf, %lf, %lf)\n", NumVerts[NumLoops],
             Vertex, Vertex->coord[0], Vertex->coord[1], Vertex->coord[2] );

         Vertex = Vertex->next;
      }
      while ( StartVertex != Vertex );
      NumLoops++;
   }

   outfile = fopen( filename, "w" );
   fprintf( outfile, "%d\n", PlanarX );
   fprintf( outfile, "%d\n", PlanarY );
   fprintf( outfile, "%d\n", NumLoops );

   for ( Loop = Facet, i = 0; Loop; Loop = Loop->next, i++ )
   {
      StartVertex = Vertex = Loop->loop;
      fprintf( outfile, "%d\n", NumVerts[i] );
      do
      {
         fprintf( outfile, "%20.18lf %20.18lf, %20.18lf\n",
                  Vertex->coord[0], Vertex->coord[1], Vertex->coord[2] );

         fprintf( outfile, "%20.18lf %20.18lf, %20.18lf\n",
                  Vertex->norm[0], Vertex->norm[1], Vertex->norm[2] );

         Vertex = Vertex->next;
      }
      while ( StartVertex != Vertex );
   }

   fclose( outfile );

}/* DLItri_print_facet */

#endif

/*--- DLItri_process_facet() -------------------------------------------------------*/

int DLItri_process_facet(
   struct DLItri_loop * Facet,
   int TotalVertices,
   int Plan_x,
   int Plan_y,
   double dis_tol,
   int (*mesh_processor)( struct DLItri_mesh * ) )

/*
NAME
        DLItri_process_facet

DESCRIPTION
        This function takes the current 'Facet' and sends it through the Polygon Mesher
        to be Regularized and Triangulated.

KEYWORD
        triangulator

PARAMETERS
        Facet (IN) - Only needed for debugging.
        TotalVertices (IN) - The number of vertices in the facet.
        Plan_x, Plan_y (IN) - The indices (0-2) of the pt[] 3d coordinates to be used as the
        2d coordinates for triangulating the facet.

GLOBALS USED
        none.

RETURN VALUES
        The number of triangular meshes for the given facet.
        'NumTriMeshes' - Inaccurately returned by HStriangulate at this time. -Trevor Mink 2/13/92

HISTORY
        01/26/90 Created. -Trevor Mink
        06/07/93 Converted to DL - Mike Lanier
*/

{
   struct DLItri_vertex **VertexList;
   struct DLItri_polygon_vert *MonoPolys;
   int NumTriMeshes;

#if TRIMESH_DEBUG
   fprintf( stderr, "element_parms.facet_normal = (%lf, %lf, %lf)\n", FABS( element_parms.facet_normal[0] ),
            FABS( element_parms.facet_normal[1] ), FABS( element_parms.facet_normal[2] ) );
#endif

   PlanarX = Plan_x;
   PlanarY = Plan_y;


   /* Create the edges represented between the vertices */

   DLItri_create_edges( Facet, PlanarX, PlanarY, dis_tol );

#if TEMP_DEBUG
   fprintf( stderr, "TotalVertices = %d\n", TotalVertices );
#endif

   /* This call is used to set up a list of vertices pointed to by an array */
   /* of pointers. The list will then be sorted by a call to */
   /* 'HSquickSort()'. */

   VertexList = DLItri_setup_list( Facet, TotalVertices, PlanarX, PlanarY );

#if TEMP_DEBUG
   if ( !VertexList )
      fprintf( stderr, "VertexList returned NULL from DLItri_setup_list\n" );

   fprintf( stderr, "calling HSquickSort()\n" );
#endif

   /* Quick-sort the entire list */

   DLItri_quick_sort( 0, TotalVertices - 1 );

#if TEMP_DEBUG
   fprintf( stderr, "calling DLItri_regularize()\n" );
#endif

   /* Regularize the vertex-edge set */

   if ( TotalVertices > 2 )
   {
      if ( MonoPolys = DLItri_regularize( VertexList, TotalVertices, dis_tol ) )
      {
#if TEMP_DEBUG
         fprintf( stderr, "calling HStriangulate()\n" );
#endif

         NumTriMeshes = DLItri_create_mesh( MonoPolys,
                                            TotalVertices,
                                            PlanarX,
                                            PlanarY,
                                            dis_tol,
                                            mesh_processor );

#if TEMP_DEBUG
         fprintf( stderr, "NumTriMeshes = %d\n", NumTriMeshes );
#endif
      }
      else
      {

         /* Write bad-bound message */

#if BAD_BOUND_DEBUG
         fprintf( stderr, "Bad-boundary found for Facet = %x: disposing\n", Facet );
         DLItri_print_facet( Facet );
#endif

         NumTriMeshes = 0;
      }
   }
   else
   {
#if DEBUG_LOGGING
      fprintf( stderr, "TotalVertices = %d, not regularizing\n", TotalVertices );
#endif

      NumTriMeshes = 0;
   }

   if ( TotalVertices > DLItri_OneKB )
      free( VertexList );

#if DRAWING
   DrawFacet( Facet;
   DrawEdges( VerteList, TotalVertices );
#endif

   return ( NumTriMeshes );

}/* DLItri_process_facet */
