
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:40 $
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
#include "hsdisplay.h"
#include "hsmath.h"

#include "HSe2_mesher.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HStl_global.h"
#include "HSfem_spt.h"
#include "HSd_fixedpt.h"
#include "HSe2_mesher.h"

#include "HSpr_pbust_f.h"

/*---------------------------
 *  for function
 *     HSset_status
 */
 
#include "HSpr_tiler_f.h"

/*--------------------------*/

#define DEBUG	0
#define DRAWING	0

#define TOLERANCE_CODE		0
#define EDGE_CROSS_DEBUG	0


/*
 *  Prototype declaration for static functions
 */


#if defined (__) 
#undef __
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* HSe2_edges.c */
static struct Edge *HSalloc_edge __((void));

static void HSaddAddedEdge __((struct Edge *EdgeToAdd, 
		       struct HStri_vertex *Vertex, 
			       struct Edge **EdgeSet, 
				     short InOutFlag, 
				       int Cardinality, 
			       struct Edge *Left, 
			       struct Edge *Right));
			       
static void HSaddToSet __((struct Edge *EdgeToAdd, 
		   struct HStri_vertex *Vertex, 
				 short InOutFlag, 
				 short Horizontal, 
				double DistTol, 
				   int PlanarX, 
				   int PlanarY, 
			   struct Edge *Left, 
			   struct Edge *Right));
			   
static int HSedgeExists __((struct HStri_vertex *Top, 
			    struct HStri_vertex *Bottom));
			    
static int HSswitchEdges __((struct HStri_vertex *Vertex1, 
					   short Set1, 
				     struct Edge *Edge1, 
			     struct HStri_vertex *Vertex2, 
					   short Set2, 
				     struct Edge *Edge2, 
					     int PlanarX, 
					     int PlanarY));
					     
static struct Edge *HSfindConnectingEdge __((struct HStri_vertex *TopVert, 
					     struct HStri_vertex *BottomVert));
					     



#if defined(__cplusplus)
}
#endif


#undef __

static struct HSbufptr *edge_buffer_list = NIL_BUFPTR; /* edge buffer list */

#define	HS_60KB		61440		/* sixty kilobytes: the "magic size" */
#define	NUM_EDGES_IN_60KB	HS_60KB / sizeof (struct Edge)
					/* number of edges in 60kb of memory	*/

/*-- HSalloc_edge --------------------------------------------------------------*/

static struct Edge *HSalloc_edge()
/*
NAME
	HSalloc_edge (static)

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
*/
{
   struct Edge *this_edge;
   struct HSbufptr *this_buffer;

   if ((edge_buffer_list != NIL_BUFPTR) && (edge_buffer_list->num_left > 0))
    {
      /* get the edge from the current buffer */
      this_edge = (struct Edge *)edge_buffer_list->ele_ptr;
      edge_buffer_list->ele_ptr += edge_buffer_list->ele_size;
      edge_buffer_list->num_left--;
    }
  else
    {
      /* allocate the structures for a new buffer */
      if ((this_buffer = (struct HSbufptr *) malloc (sizeof(struct HSbufptr))) &&
          (this_buffer->buffer = (char *) malloc (NUM_EDGES_IN_60KB * sizeof(struct Edge))))
       {
         this_buffer->ele_ptr = this_buffer->buffer;
         this_buffer->num_left = NUM_EDGES_IN_60KB;
         this_buffer->ele_size = sizeof(struct Edge);
         this_buffer->next = edge_buffer_list;
         edge_buffer_list = this_buffer;

         /* allocate the first edge */
         this_edge = (struct Edge *)edge_buffer_list->ele_ptr;
         edge_buffer_list->ele_ptr += edge_buffer_list->ele_size;
         edge_buffer_list->num_left--;
       }
      else
       {
       HSset_status( HSSTAT_ALLOC_ERROR );
       this_edge = NULL;
       }
    }

   if( this_edge )
      {
      this_edge->Top = NULL;
      this_edge->Bottom = NULL;
      this_edge->Extreme_y = NULL;
      this_edge->Next = NULL;
      this_edge->x_intercept = 0.0;
      }
   
   return (this_edge);
}

/*--- HSfree_edges -------------------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSfree_edges(void)
#else
	void HSfree_edges()
#endif

/*
NAME
	HSfree_edges

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
*/
{
   struct HSbufptr *this_buffer, *next_buffer;

   /* cleanup the edge structures */
   if (edge_buffer_list != NIL_BUFPTR)
    {
      for (	this_buffer = edge_buffer_list->next;
		this_buffer != NIL_BUFPTR;
		this_buffer = next_buffer )
       {
         next_buffer = this_buffer->next;
         free((char *)this_buffer->buffer);
         free((char *)this_buffer);
       }
      edge_buffer_list->ele_ptr = edge_buffer_list->buffer;
      edge_buffer_list->num_left = NUM_EDGES_IN_60KB;
      edge_buffer_list->next = NIL_BUFPTR;
    }

} /* HSfree_edges */

/*--- HSaddAddedEdge() --------------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)

static void HSaddAddedEdge    (struct Edge *EdgeToAdd, 
		       struct HStri_vertex *Vertex, 
			       struct Edge **EdgeSet, 
				     short InOutFlag, 
				       int Cardinality, 
			       struct Edge *Left, 
			       struct Edge *Right)

#else

static void HSaddAddedEdge( EdgeToAdd, Vertex, EdgeSet, InOutFlag, Cardinality, Left, Right )
	struct Edge *EdgeToAdd;
	struct Edge **EdgeSet;
	struct HStri_vertex *Vertex;
	short InOutFlag;
	int Cardinality;
	struct Edge *Left, *Right;
	
#endif

/*
NAME
	HSaddAddedEdge (static)

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
*/
{
	int i, j, Added = FALSE;
	struct Edge *SearchEdge;

	if( InOutFlag == OUT )
	{
		if( Vertex == Left->Top ) SearchEdge = Left;
		else if( Vertex == Right->Top ) SearchEdge = Right;
		else
		{
			EdgeSet[0] = EdgeToAdd;
			SearchEdge = (struct Edge *)NULL;
			Added = TRUE;
		}
	}
	else
	{
		if( Vertex == Left->Bottom ) SearchEdge = Left;
		else if( Vertex == Right->Bottom ) SearchEdge = Right;
		else
		{
			EdgeSet[0] = EdgeToAdd;
			SearchEdge = (struct Edge *)NULL;
			Added = TRUE;
		}
	}

	for ( i = 0; i < Cardinality && !Added; i++ )
	{
		if( EdgeSet[i] == SearchEdge )
		{
			if( SearchEdge == Left )
			{
				for( j = Cardinality; j > i+1; j-- )
					EdgeSet[j] = EdgeSet[j-1];
			}
			else /* if( SearchEdge == Right ) */
			{
				for( j = Cardinality; j > i; j-- )
					EdgeSet[j] = EdgeSet[j-1];
			}
			EdgeSet[j] = EdgeToAdd;
			Added = TRUE;
		}
	}
}

/*--- HSaddToSet() ----------------------------------------------------------------------------*/


static void HSaddToSet    (struct Edge *EdgeToAdd, 
		   struct HStri_vertex *Vertex, 
				 short InOutFlag, 
				 short Horizontal, 
				double DistTol, 
				   int PlanarX, 
				   int PlanarY, 
			   struct Edge *Left, 
			   struct Edge *Right)
			   
/*
NAME
	HSaddToSet (static)

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
        07/26/93 for TR 11925929 I fixed problem in which if edge being added and and an edge
                 already there are vertical, there was no check to make sure they were being 
                 added in the correct order.  If they were not added in the correct order, a
                 segmentation fault would occur because it would be going to the left instead
                 of the right and sooner or later their won't be an in or out pointer and it
                 will crash.  Joel Underwood
*/
{
   struct Edge **EdgeSet;
   int i, j, Added = FALSE;
   int Cardinality;
   double Tolerance;
   double top_x, top_y;
   double bottom_x, bottom_y;
   double adding_x, adding_y;
   double edgset_x, edgset_y;
   double adding_next_x, adding_next_y;
   double edgset_next_x, edgset_next_y;
   struct HStri_vertex *adding_next_vertex_ptr, *edgset_next_vertex_ptr;
#if DOESNT_SEEMTA_MATTER
   Tolerance = (DistTol / (EdgeToAdd->Bottom->coord[PlanarY] - EdgeToAdd->Top->coord[PlanarY]) );
#else
   Tolerance = 0.0;
#endif
#if DEBUG
   printf( "Horizontal = %d\n", Horizontal );
#endif
   if ( Horizontal ) 
   {
      if ( InOutFlag == OUT ) 
      {
#if DEBUG
         printf( "Adding edge to OUT set at address %x\n", Vertex );
#endif
         /*
         * Horizontal edges will be the last in the set for the outgoing vertex.
         * Multiple horizontal edges in a given 'Out' set indicates that the latter
         * edge is an 'Added' edge, and barring some unforseen error, should be placed
         * prior to an 'Original' horizontal edge.
         */
         Cardinality = Vertex->OutCardinality;
         if ( Cardinality > 0 ) 
         {
            if( Vertex->Out[Cardinality-1]->EdgeStatus & HORIZONTAL_EDGE )
            {
               Vertex->Out[Cardinality] = Vertex->Out[Cardinality-1];
               Vertex->Out[Cardinality-1] = EdgeToAdd;
            }
            else
            {
               Vertex->Out[Cardinality] = EdgeToAdd;
            }
         } 
         else
         {
            Vertex->Out[Cardinality] = EdgeToAdd;
         } 
         Vertex->OutCardinality++;
      } 
      else 
      {
         /* Horizontal edges will be the first in the set for the incoming vertex */
         /* Same holds here as above, but doesn't require special processing */
         for( j = Vertex->InCardinality; j > 0; j-- )
         {
            Vertex->In[j] = Vertex->In[j-1];
         }
         Vertex->In[0] = EdgeToAdd;
         Vertex->InCardinality++;
      }
   }
   else if ( InOutFlag == OUT ) 
   {
#if DEBUG
      printf( "Adding edge to OUT set at address %x\n", Vertex );
#endif
      EdgeSet = Vertex->Out;
      Cardinality = Vertex->OutCardinality;
      if ( EdgeToAdd->EdgeStatus & ADDED_EDGE )
      {
         HSaddAddedEdge( EdgeToAdd, Vertex, EdgeSet, InOutFlag, Cardinality, Left, Right );
      }
      else
      {
         for ( i = 0; i < Cardinality && !Added; i++ ) 
         {
#if DEBUG
            printf( "Out edge # %d\t", i );
            printf( "SlopeInverse = %lf\t", EdgeSet[i]->SlopeInverse );
            printf( "EdgeStatus = %d\n", EdgeSet[i]->EdgeStatus );
#endif
            if ( (EdgeToAdd->SlopeInverse == 0.0) && (EdgeSet[i]->SlopeInverse == 0.0 ) &&
                 !(EdgeSet[i]->EdgeStatus & HORIZONTAL_EDGE ) ) /* SlopeInverse is undefined for horizontal */
            {
               /* Here we need to be able to check 1 vertex beyond these edges to break the tie and */
               /* sort the out list in the correct order.  TR 11925929 */
               /* set up the x and y values of edge vertices and the next vertices.  since the edges */
               /* are both vertical top_x and adding_x and edgset_x should all be the same */
               top_x = Vertex->coord[PlanarX];
               top_y = Vertex->coord[PlanarY];
               adding_x = EdgeToAdd->Bottom->coord[PlanarX];
               adding_y = EdgeToAdd->Bottom->coord[PlanarY];
               edgset_x = EdgeSet[i]->Bottom->coord[PlanarX];
               edgset_y = EdgeSet[i]->Bottom->coord[PlanarY];
               adding_next_vertex_ptr = EdgeToAdd->Bottom->next;
               /* how do we know we want the right most next vertex instead of left most?  don't think it matters */
               /* edgset_next_vertex_ptr = EdgeSet[i]->Bottom->Out[(EdgeSet[i]->Bottom->OutCardinality)-1]->Bottom;*/
if( EdgeSet[i]->Bottom->Out[0] == NULL ) 
	{
	HSset_status( HSSTAT_BOUND_ERROR );
	return;
	}
               edgset_next_vertex_ptr = EdgeSet[i]->Bottom->Out[0]->Bottom;
               adding_next_x = adding_next_vertex_ptr->coord[PlanarX];
               adding_next_y = adding_next_vertex_ptr->coord[PlanarY];
               edgset_next_x = edgset_next_vertex_ptr->coord[PlanarX];
               edgset_next_y = edgset_next_vertex_ptr->coord[PlanarY];
               if ((adding_y == edgset_y) && (adding_next_x == edgset_next_x) && (adding_next_y == edgset_next_y))
               {
                  /* keep checking the next points until different. */
                  while ((adding_next_x == edgset_next_x) && (adding_next_y == edgset_next_y))
                  {
                     /* The next 2 vertices were the same, find different ones */
                     adding_next_vertex_ptr = adding_next_vertex_ptr->next;
                     edgset_next_vertex_ptr = edgset_next_vertex_ptr->Out[0]->Bottom;
                     adding_next_x = adding_next_vertex_ptr->coord[PlanarX];
                     adding_next_y = adding_next_vertex_ptr->coord[PlanarY];
                     edgset_next_x = edgset_next_vertex_ptr->coord[PlanarX];
                     edgset_next_y = edgset_next_vertex_ptr->coord[PlanarY];
#if DEBUG
                     printf("the next 2 vertices were the same, getting the next ones\n");
                     printf("  Next Vertices EdgeToAdd Bottom %#X (%lf,%lf)\n  EdgeSet[%d] Bottom %#X (%lf,%lf)\n",
                        adding_next_vertex_ptr, adding_next_x, adding_next_y, 
                        i, edgset_next_vertex_ptr, edgset_next_x, edgset_next_y );
#endif
                  }
               }

#if DEBUG
               printf("both edges are vertical, Need some type of tiebreaker here.\n");
               printf( "Out edges %d through %d will shift\n", i, Cardinality );
               printf("Top Vertex = %#X (%lf,%lf)\n EdgeToADD Bottom %#X (%lf,%lf)\n EdgeSet[%d] Bottom %#X (%lf,%lf)\n",
                  Vertex, top_x, top_y, EdgeToAdd->Bottom, adding_x, adding_y, i, EdgeSet[i]->Bottom, 
                  edgset_x, edgset_y);
               printf("  Next Vertices EdgeToAdd Bottom %#X (%lf,%lf)\n  EdgeSet[%d] Bottom %#X (%lf,%lf)\n",
                  adding_next_vertex_ptr, adding_next_x, adding_next_y, 
                  i, edgset_next_vertex_ptr, edgset_next_x, edgset_next_y );
#endif
               /* In all of these cases we need to determine which is rightmost edge and put in that sorted order */
               /* We also know we won't have 3 vertical edges from one vertex so we can just add one to i and it. */
               /* will be loaded after.  The default is that the edgset is right most so add 1 if adding is */
               /* rightmost. */
               if ((adding_next_x == edgset_next_x) || ((adding_next_x > top_x) && (edgset_next_x > top_x)) ||
                   ((adding_next_x < top_x) && (edgset_next_x < top_x)) )
               {
#if DEBUG
                  printf("next vertices X's equal or on same side of top_x\n");
#endif
                  if (adding_next_x > top_x)
                  { 
#if DEBUG
                     printf("next x's are on right so ");
#endif
                     if (adding_y < edgset_y) 
                     {
#if DEBUG
                        printf("adding is right most\n");
#endif
                        i++;
                     }
#if DEBUG
                     else
                     {
                        printf("edgset is right most\n");
                     }
#endif
                  }
                  else
                  { 
#if DEBUG
                     printf("next x's are on left so ");
#endif
                     if (adding_y > edgset_y) 
                     {
#if DEBUG
                        printf("adding is right most\n");
#endif
                        i++;
                     }
#if DEBUG
                     else
                     {
                        printf("edgset is right most\n");
                     }
#endif
                  }
               }
               else  if ( (edgset_next_x < top_x) && (top_x < adding_next_x) )
               {
#if DEBUG
                  printf("edgset next x < top_x < adding next x adding rightmost\n");
#endif
                  i++;
               } 
#if DEBUG
               else  if ( (adding_next_x < top_x) && (top_x < edgset_next_x) )
               {
               	  printf("adding next x < top_x < edgset next x  edgset rightmost\n");
               } 
#endif
            
               for( j = Cardinality; j > i; j-- ) 
               {
                  EdgeSet[j] = EdgeSet[j-1];
               }
               EdgeSet[i] = EdgeToAdd;
               Added = TRUE;
            
            }
            else
            if( (EdgeSet[i]->EdgeStatus & HORIZONTAL_EDGE) ||
               (EdgeToAdd->SlopeInverse < EdgeSet[i]->SlopeInverse - Tolerance ) ) 
            {
#if DEBUG
               printf( "EdgeToAdd->SlopeInverse = %lf\n", EdgeToAdd->SlopeInverse );
               printf( "Out edges %d through %d will shift\n", i, Cardinality );
#endif
               for( j = Cardinality; j > i; j-- )
               {
                  EdgeSet[j] = EdgeSet[j-1];
               }
               EdgeSet[i] = EdgeToAdd;
               Added = TRUE;
            }
         }
         if( !Added ) 
         {
            EdgeSet[Cardinality] = EdgeToAdd;
         }
      }
      Vertex->OutCardinality++;
   } 
   else 
   {
#if DEBUG
      printf( "Adding edge to IN set at address %x\n", Vertex );
#endif
      EdgeSet = Vertex->In;
      Cardinality = Vertex->InCardinality;
      if( EdgeToAdd->EdgeStatus & ADDED_EDGE )
      { 
         HSaddAddedEdge( EdgeToAdd, Vertex, EdgeSet, InOutFlag, Cardinality, Left, Right );
      }
      else
      {
         for ( i = 0; i < Cardinality && !Added; i++ )
         {
            if ( (EdgeToAdd->SlopeInverse == 0.0) && (EdgeSet[i]->SlopeInverse == 0.0 )  &&
                 !(EdgeSet[i]->EdgeStatus & HORIZONTAL_EDGE ) ) /* SlopeInverse is undefined for horizontal */
            {
               /* Here we need to be able to check 1 vertex beyond these edges to break the tie and */
               /* sort the out list in the correct order.  TR 11925929 */
               /* set up the x and y values of edge vertices and the next vertices.  since the edges */
               /* are both vertical top_x and adding_x and edgset_x should all be the same */
               bottom_x = Vertex->coord[PlanarX];
               bottom_y = Vertex->coord[PlanarY];
               adding_x = EdgeToAdd->Top->coord[PlanarX];
               adding_y = EdgeToAdd->Top->coord[PlanarY];
               edgset_x = EdgeSet[i]->Top->coord[PlanarX];
               edgset_y = EdgeSet[i]->Top->coord[PlanarY];
               adding_next_vertex_ptr = EdgeToAdd->Top->next;
               /* how do we know we want the right most next vertex instead of left most?  don't think it matters */
               /* edgset_next_vertex_ptr = EdgeSet[i]->Top->Out[(EdgeSet[i]->Top->OutCardinality)-1]->Top;*/
               edgset_next_vertex_ptr = EdgeSet[i]->Top->Out[0]->Top;
               adding_next_x = adding_next_vertex_ptr->coord[PlanarX];
               adding_next_y = adding_next_vertex_ptr->coord[PlanarY];
               edgset_next_x = edgset_next_vertex_ptr->coord[PlanarX];
               edgset_next_y = edgset_next_vertex_ptr->coord[PlanarY];
               if ((adding_y == edgset_y) && (adding_next_x == edgset_next_x) && (adding_next_y == edgset_next_y))
               {
                  /* some sort of recursive is probably needed here if the points are the same.  keep checking
                     the next points until different. */
                  /* next points are identical=>lower y of middle vertex should be rightmost edge */
                  while ((adding_next_x == edgset_next_x) && (adding_next_y == edgset_next_y))
                  {
                     /* The next 2 vertices were the same, find different ones */
                     adding_next_vertex_ptr = adding_next_vertex_ptr->next;
                     edgset_next_vertex_ptr = edgset_next_vertex_ptr->Out[0]->Top;
                     adding_next_x = adding_next_vertex_ptr->coord[PlanarX];
                     adding_next_y = adding_next_vertex_ptr->coord[PlanarY];
                     edgset_next_x = edgset_next_vertex_ptr->coord[PlanarX];
                     edgset_next_y = edgset_next_vertex_ptr->coord[PlanarY];
#if DEBUG
                     printf("the next 2 vertices were the same, getting the next ones\n");
                     printf("  Next Vertices EdgeToAdd Top %#X (%lf,%lf)\n  EdgeSet[%d] Top %#X (%lf,%lf)\n",
                        adding_next_vertex_ptr, adding_next_x, adding_next_y, 
                        i, edgset_next_vertex_ptr, edgset_next_x, edgset_next_y );
#endif
                  }
               }

#if DEBUG
               printf("both edges are vertical, Need some type of tiebreaker here.\n");
               printf( "Out edges %d through %d will shift\n", i, Cardinality );
               printf("Top Vertex = %#X (%lf,%lf)\n EdgeToADD Top %#X (%lf,%lf)\n EdgeSet[%d] Top %#X (%lf,%lf)\n",
                  Vertex, top_x, top_y, EdgeToAdd->Top, adding_x, adding_y, i, EdgeSet[i]->Top, 
                  edgset_x, edgset_y);
               printf("  Next Vertices EdgeToAdd Top %#X (%lf,%lf)\n  EdgeSet[%d] Top %#X (%lf,%lf)\n",
                  adding_next_vertex_ptr, adding_next_x, adding_next_y, 
                  i, edgset_next_vertex_ptr, edgset_next_x, edgset_next_y );
#endif
               /* In all of these cases we need to determine which is rightmost edge and put in that sorted order */
               /* We also know we won't have 3 vertical edges from one vertex so we can just add one to i and it. */
               /* will be loaded after.  The default is that the edgset is right most so add 1 if adding is */
               /* rightmost. */
               if ((adding_next_x == edgset_next_x) || ((adding_next_x > top_x) && (edgset_next_x > top_x)) ||
                   ((adding_next_x < top_x) && (edgset_next_x < top_x)) )
               {
#if DEBUG
                  printf("next vertices X's equal or on same side of top_x\n");
#endif
                  if (adding_next_x > top_x)
                  { 
#if DEBUG
                     printf("next x's are on right so");
#endif
                     if (adding_y < edgset_y) 
                     {
#if DEBUG
                        printf("adding is right most\n");
#endif
                        i++;
                     }
#if DEBUG
                     else
                     {
                        printf("edgset is right most\n");
                     }
#endif
                  }
                  else
                  { 
#if DEBUG
                     printf("next x's are on left so ");
#endif
                     if (adding_y > edgset_y) 
                     {
#if DEBUG
                        printf("adding is right most\n");
#endif
                        i++;
                     }
#if DEBUG
                     else
                     {
                        printf("edgset is right most\n");
                     }
#endif
                  }
               }
               else  if ( (edgset_next_x < top_x) && (top_x < adding_next_x) )
               {
#if DEBUG
                  printf("edgset next x < top_x < adding next x adding rightmost\n");
#endif
                  i++;
               } 
#if DEBUG
               else  if ( (adding_next_x < top_x) && (top_x < edgset_next_x) )
               {
               	  printf("adding next x < top_x < edgset next x  edgset rightmost\n");
               } 
#endif
            
               for( j = Cardinality; j > i; j-- ) 
               {
                  EdgeSet[j] = EdgeSet[j-1];
               }
               EdgeSet[i] = EdgeToAdd;
               Added = TRUE;
            }
            else
            if ( !( EdgeSet[i]->EdgeStatus & HORIZONTAL_EDGE ) &&
               (EdgeToAdd->SlopeInverse > EdgeSet[i]->SlopeInverse + Tolerance ) ) 
            {
               for( j = Cardinality; j > i; j-- )
               { 
                  EdgeSet[j] = EdgeSet[j-1];
               }
               EdgeSet[i] = EdgeToAdd;
               Added = TRUE;
            }
         }
         if ( !Added ) 
         {
            EdgeSet[Cardinality] = EdgeToAdd;
         }
      }
      Vertex->InCardinality++;
   }
} /* HSaddToSet */

/*--- HSaddEdge() ----------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
        void HSaddEdge( struct HStri_vertex *Vertex1, 
                        struct HStri_vertex *Vertex2, 
			     unsigned short EdgeType, 
					int PlanarX, 
					int PlanarY, 
				struct Edge *Left, 
				struct Edge *Right, 
				     double DistTol )
#else
	void HSaddEdge( Vertex1, Vertex2, EdgeType, PlanarX, PlanarY, Left, Right, DistTol )
	struct HStri_vertex *Vertex1, *Vertex2;
	unsigned short EdgeType;
	int PlanarX, PlanarY;
	struct Edge *Left, *Right;
	double DistTol;
#endif

/*
NAME
	HSaddEdge

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
*/
{
	struct Edge *EdgeToAdd;
#if TOLERANCE_CODE
	double y1, y2;
#endif

#if DEBUG
	printf( "Adding edge from (%lf, %lf) to (%lf, %lf) of type %d\n",
		Vertex1->coord[PlanarX],Vertex1->coord[PlanarY],
		Vertex2->coord[PlanarX], Vertex2->coord[PlanarY], EdgeType);
#endif

	if( (EdgeToAdd = HSalloc_edge() ) == (struct Edge *)NULL )
	{
		/* We need a user informative error statement here */
#if DEBUG
		printf( "EdgeToAdd returned NULL from alloc\nReturning\n" );
#endif
		return;
	}
#if DEBUG
	if( !EdgeToAdd ) printf( "EdgeToAdd returned NULL from alloc\n" );
#endif
	EdgeToAdd->EdgeStatus = EdgeType;

#if TOLERANCE_CODE
	y1 = Vertex1->coord[PlanarY];
	y2 = Vertex2->coord[PlanarY];
	if( WITHIN_TOLERANCE( y1, y2, DistTol ) )
#else
	if( Vertex1->coord[PlanarY] == Vertex2->coord[PlanarY] )
#endif
		EdgeToAdd->EdgeStatus |= HORIZONTAL_EDGE;
	else
		EdgeToAdd->SlopeInverse = ( Vertex2->coord[PlanarX] - Vertex1->coord[PlanarX] ) /
			( Vertex2->coord[PlanarY] - Vertex1->coord[PlanarY] );
#if DEBUG
	printf( "SlopeInverse of EdgeToAdd = %lf\n", EdgeToAdd->SlopeInverse );
#endif
#if TOLERANCE_CODE
	if( EdgeToAdd->EdgeStatus & HORIZONTAL_EDGE )
	{
		if( Vertex1->coord[PlanarX] < Vertex2->coord[PlanarX] )
		{
			EdgeToAdd->Top = Vertex1;
			EdgeToAdd->Bottom = Vertex2;
			HSaddToSet( EdgeToAdd, Vertex1, OUT, TRUE, DistTol, PlanarX, PlanarY, Left, Right );
			HSaddToSet( EdgeToAdd, Vertex2, IN, TRUE, DistTol, PlanarX, PlanarY, Left, Right );
		}
		else
		{
			EdgeToAdd->Top = Vertex2;
			EdgeToAdd->Bottom = Vertex1;
			HSaddToSet( EdgeToAdd, Vertex2, OUT, TRUE, DistTol, PlanarX, PlanarY, Left, Right );
			HSaddToSet( EdgeToAdd, Vertex1, IN, TRUE, DistTol, PlanarX, PlanarY, Left, Right );
		}
	}
	else if( Vertex1->coord[PlanarY] < Vertex2->coord[PlanarY] )
	{
		EdgeToAdd->Top = Vertex1;
		EdgeToAdd->Bottom = Vertex2;
		HSaddToSet( EdgeToAdd, Vertex1, OUT, FALSE, DistTol, PlanarX, PlanarY, Left, Right );
		HSaddToSet( EdgeToAdd, Vertex2, IN, FALSE, DistTol, PlanarX, PlanarY, Left, Right );
	}
	else
	{	/* Vertex1->coord[PlanarY] > Vertex2->coord[PlanarY] */
		EdgeToAdd->Top = Vertex2;
		EdgeToAdd->Bottom = Vertex1;
		HSaddToSet( EdgeToAdd, Vertex2, OUT, FALSE, DistTol, PlanarX, PlanarY, Left, Right );
		HSaddToSet( EdgeToAdd, Vertex1, IN, FALSE, DistTol, PlanarX, PlanarY, Left, Right );
	}
#else
	if( Vertex1->coord[PlanarY] < Vertex2->coord[PlanarY] ) {
#if DEBUG
                printf( "1edge top= Vertex1 %#X edge bottom=Vertex2 %#X\n", Vertex1, Vertex2 );
#endif
		EdgeToAdd->Top = Vertex1;
		EdgeToAdd->Bottom = Vertex2;
		HSaddToSet( EdgeToAdd, Vertex1, OUT, FALSE, DistTol, PlanarX, PlanarY, Left, Right );
		HSaddToSet( EdgeToAdd, Vertex2, IN, FALSE, DistTol, PlanarX, PlanarY, Left, Right );
	} else if( Vertex1->coord[PlanarY] == Vertex2->coord[PlanarY] ) {
		if( Vertex1->coord[PlanarX] < Vertex2->coord[PlanarX] ) {
#if DEBUG
                        printf( "2edge top= Vertex1 %#X edge bottom=Vertex2 %#X\n", Vertex1, Vertex2 );
#endif
			EdgeToAdd->Top = Vertex1;
			EdgeToAdd->Bottom = Vertex2;
			HSaddToSet( EdgeToAdd, Vertex1, OUT, TRUE, DistTol, PlanarX, PlanarY, Left, Right );
			HSaddToSet( EdgeToAdd, Vertex2, IN, TRUE, DistTol, PlanarX, PlanarY, Left, Right );
		} else {
#if DEBUG
                        printf( "3edge top= Vertex2 %#X edge bottom=Vertex1 %#X\n", Vertex2, Vertex1 );
#endif
			EdgeToAdd->Top = Vertex2;
			EdgeToAdd->Bottom = Vertex1;
			HSaddToSet( EdgeToAdd, Vertex2, OUT, TRUE, DistTol, PlanarX, PlanarY, Left, Right );
			HSaddToSet( EdgeToAdd, Vertex1, IN, TRUE, DistTol, PlanarX, PlanarY, Left, Right );
		}
	} else { /* Vertex1->coord[PlanarY] > Vertex2->coord[PlanarY] */
#if DEBUG
                printf( "4edge top= Vertex2 %#X edge bottom=Vertex1 %#X\n", Vertex2, Vertex1 );
#endif
		EdgeToAdd->Top = Vertex2;
		EdgeToAdd->Bottom = Vertex1;
		HSaddToSet( EdgeToAdd, Vertex2, OUT, FALSE, DistTol, PlanarX, PlanarY, Left, Right );
		HSaddToSet( EdgeToAdd, Vertex1, IN, FALSE, DistTol, PlanarX, PlanarY, Left, Right );
	}
#endif
} /* HSaddEdge */

/*--- HScreateEdges() ----------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HScreateEdges( struct HSloop *Facet, 
				      int PlanarX, 
				      int PlanarY, 
				   double DistTol )
#else
	void hscreateEdges( Facet, PlanarX, PlanarY, DistTol )
	struct HSloop *Facet;
	int PlanarX, PlanarY;
	double DistTol;
#endif

/*
NAME
	HScreateEdges

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
*/
{
	struct HSloop *Loop;
	struct HStri_vertex *Start, *Vertex;
        int	nv;

#       if DEBUG
        int i=0;
#       endif

	for( Loop = Facet; Loop; Loop = Loop->next ) {
		Start = Vertex = (struct HStri_vertex *)(Loop->loop);

                nv = 0;
                do {
                   nv++;
                   Vertex = Vertex->next;
                   } while( Vertex != Start && nv < 4 );
                if( nv < 3 ) continue;
		Start = Vertex = (struct HStri_vertex *)(Loop->loop);

		do {
#                       if DEBUG
                        i++;
                        printf("#%d ",i);
#                       endif

			HSaddEdge( Vertex, Vertex->next, ORIGINAL_EDGE, PlanarX, PlanarY,
				(struct Edge *)NULL, (struct Edge *)NULL, DistTol );
			Vertex = Vertex->next;
		} while( Vertex != Start );
	}

} /* HScreateEdges */

#if NO_DUPLICATE_EDGES

/*--- HSedgeExists() ----------------------------------------------------------------*/

static int HSedgeExists( Top, Bottom )
	struct HStri_vertex *Top, *Bottom;
/*
NAME
	HSedgeExists (static)

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
*/
{
	int i, Cardinality;

	Cardinality = Top->OutCardinality;
	for( i = 0; i < Cardinality; i++ )
	{
		if( (Top->Out[i])->Bottom == Bottom ) return TRUE;
	}
	return FALSE;

} /* HSedgeExists */
#endif

/*--- HSswitchEdges() ---------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)

static int HSswitchEdges    (struct HStri_vertex *Vertex1, 
					   short Set1, 
				     struct Edge *Edge1, 
			     struct HStri_vertex *Vertex2, 
					   short Set2, 
				     struct Edge *Edge2, 
					     int PlanarX, 
					     int PlanarY)
					     
#else

static int HSswitchEdges( Vertex1, Set1, Edge1, Vertex2, Set2, Edge2, PlanarX, PlanarY )
	struct HStri_vertex *Vertex1, *Vertex2;
	short Set1, Set2;
	struct Edge *Edge1, *Edge2;
	int PlanarX, PlanarY;
	
#endif

/*
NAME
	HSswitchEdges (static)

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
	CANNOT_HANDLE - Indicates the edges weren't successfully switched
	HANDLED - Indicates the edges WERE successfully switched

HISTORY
	08/05/91 Created. -Trevor Mink
*/
{
	int i, j, Cardinality;
	short Horizontal;
	struct HStri_vertex *OtherVert, *OtherVert2;
	double x1, y1, x2, y2;

	/* First remove edges from the appropriate sets */
	if( Set1 == OUT )
	{
		/* Find Edge1 in the OUTgoing set of Vertex1 */
		Cardinality = Vertex1->OutCardinality;
		for( i = 0; i < Cardinality; i++ )
		{
			if( Vertex1->Out[i] == Edge1 ) break;
		}
		if( i == Cardinality ) return CANNOT_HANDLE;
		for( j = i; j < Cardinality-1; j++ )
		{
			Vertex1->Out[j] = Vertex1->Out[j+1]; /* Should overwrite entry 'i' */
		}
		(Vertex1->OutCardinality)--;

		OtherVert = Edge1->Bottom;

		/* Find Edge1 in the INcoming set of OtherVert */
		Cardinality = OtherVert->InCardinality;
		for( i = 0; i < Cardinality; i++ )
		{
			if( OtherVert->In[i] == Edge1 ) break;
		}
		if( i == Cardinality ) return CANNOT_HANDLE;
		for( j = i; j < Cardinality-1; j++ )
		{
			OtherVert->In[j] = OtherVert->In[j+1]; /* Should overwrite entry 'i' */
		}
		(OtherVert->InCardinality)--;
	}
	else
	{
		/* Find Edge1 in the INcoming set of Vertex1 */
		Cardinality = Vertex1->InCardinality;
		for( i = 0; i < Cardinality; i++ )
		{
			if( Vertex1->In[i] == Edge1 ) break;
		}
		if( i == Cardinality ) return CANNOT_HANDLE;
		for( j = i; j < Cardinality-1; j++ )
		{
			Vertex1->In[j] = Vertex1->In[j+1]; /* Should overwrite entry 'i' */
		}
		(Vertex1->InCardinality)--;

		OtherVert = Edge1->Top;

		/* Find Edge1 in the OUTgoing set of OtherVert */
		Cardinality = OtherVert->OutCardinality;
		for( i = 0; i < Cardinality; i++ )
		{
			if( OtherVert->Out[i] == Edge1 ) break;
		}
		if( i == Cardinality ) return CANNOT_HANDLE;
		for( j = i; j < Cardinality-1; j++ )
		{
			OtherVert->Out[j] = OtherVert->Out[j+1]; /* Should overwrite entry 'i' */
		}
		(OtherVert->OutCardinality)--;
	}

	if( Set2 == OUT )
	{
		/* Find Edge2 in the OUTgoing set of Vertex2 */
		Cardinality = Vertex2->OutCardinality;
		for( i = 0; i < Cardinality; i++ )
		{
			if( Vertex2->Out[i] == Edge2 ) break;
		}
		if( i == Cardinality ) return CANNOT_HANDLE;
		for( j = i; j < Cardinality-1; j++ )
		{
			Vertex2->Out[j] = Vertex2->Out[j+1]; /* Should overwrite entry 'i' */
		}
		(Vertex2->OutCardinality)--;

		OtherVert2 = Edge2->Bottom;

		/* Find Edge2 in the INcoming set of OtherVert2 */
		Cardinality = OtherVert2->InCardinality;
		for( i = 0; i < Cardinality; i++ )
		{
			if( OtherVert2->In[i] == Edge2 ) break;
		}
		if( i == Cardinality ) return CANNOT_HANDLE;
		for( j = i; j < Cardinality-1; j++ )
		{
			OtherVert2->In[j] = OtherVert2->In[j+1]; /* Should overwrite entry 'i' */
		}
		(OtherVert2->InCardinality)--;
	}
	else
	{
		/* Find Edge2 in the INcoming set of Vertex2 */
		Cardinality = Vertex2->InCardinality;
		for( i = 0; i < Cardinality; i++ )
		{
			if( Vertex2->In[i] == Edge2 ) break;
		}
		if( i == Cardinality ) return CANNOT_HANDLE;
		for( j = i; j < Cardinality-1; j++ )
		{
			Vertex2->In[j] = Vertex2->In[j+1]; /* Should overwrite entry 'i' */
		}
		(Vertex2->InCardinality)--;

		OtherVert2 = Edge2->Top;

		/* Find Edge2 in the OUTgoing set of OtherVert2 */
		Cardinality = OtherVert2->OutCardinality;
		for( i = 0; i < Cardinality; i++ )
		{
			if( OtherVert2->Out[i] == Edge2 ) break;
		}
		if( i == Cardinality ) return CANNOT_HANDLE;
		for( j = i; j < Cardinality-1; j++ )
		{
			OtherVert2->Out[j] = OtherVert2->Out[j+1]; /* Should overwrite entry 'i' */
		}
		(OtherVert2->OutCardinality)--;
	}

	/* Now set up the two NEW edges */
	x1 = OtherVert->coord[PlanarX];
	y1 = OtherVert->coord[PlanarY];
	x2 = Vertex2->coord[PlanarX];
	y2 = Vertex2->coord[PlanarY];
	Horizontal = (y1 == y2);
	if( y1 < y2 || (Horizontal && x1 < x2) )
	{
		Edge1->Top = OtherVert;
		Edge1->Bottom = Vertex2;
#if NO_DUPLICATE_EDGES
		if( HSedgeExists( OtherVert, Vertex2 ) )
		{
			DelSetFromAEL( &Edge1, 1, TRUE );
			HSfree_Edge( Edge1 );
		}
		else
		{
#endif
			if( Horizontal ) Edge1->EdgeStatus |= HORIZONTAL_EDGE;
			else
			{
				Edge1->EdgeStatus &= ~HORIZONTAL_EDGE;
				Edge1->SlopeInverse = ( Vertex2->coord[PlanarX] - OtherVert->coord[PlanarX] ) /
					( Vertex2->coord[PlanarY] - OtherVert->coord[PlanarY] );
			}
			HSaddToSet( Edge1, OtherVert, OUT, Horizontal, 0.0, PlanarX, PlanarY, (struct Edge *)NULL, (struct Edge *)NULL );
			HSaddToSet( Edge1, Vertex2, IN, Horizontal, 0.0, PlanarX, PlanarY, (struct Edge *)NULL, (struct Edge *)NULL );
#if NO_DUPLICATE_EDGES
		}
#endif
	}
	else
	{
		Edge1->Top = Vertex2;
		Edge1->Bottom = OtherVert;
#if NO_DUPLICATE_EDGES
		if( HSedgeExists( Vertex2, OtherVert ) )
		{
			DelSetFromAEL( &Edge1, 1, TRUE );
			HSfree_Edge( Edge1 );
		}
		else
		{
#endif
			if( Horizontal ) Edge1->EdgeStatus |= HORIZONTAL_EDGE;
			else
			{
				Edge1->EdgeStatus &= ~HORIZONTAL_EDGE;
				Edge1->SlopeInverse = ( OtherVert->coord[PlanarX] - Vertex2->coord[PlanarX] ) /
					( OtherVert->coord[PlanarY] - Vertex2->coord[PlanarY] );
			}
			HSaddToSet( Edge1, Vertex2, OUT, Horizontal, 0.0, PlanarX, PlanarY, (struct Edge *)NULL, (struct Edge *)NULL );
			HSaddToSet( Edge1, OtherVert, IN, Horizontal, 0.0, PlanarX, PlanarY, (struct Edge *)NULL, (struct Edge *)NULL );
#if NO_DUPLICATE_EDGES
		}
#endif
	}

	x1 = OtherVert2->coord[PlanarX];
	y1 = OtherVert2->coord[PlanarY];
	x2 = Vertex1->coord[PlanarX];
	y2 = Vertex1->coord[PlanarY];
	Horizontal = (y1 == y2);
	if( y1 < y2 || (Horizontal && x1 < x2) )
	{
		Edge2->Top = OtherVert2;
		Edge2->Bottom = Vertex1;
#if NO_DUPLICATE_EDGES
		if( HSedgeExists( OtherVert2, Vertex1 ) )
		{
			DelSetFromAEL( &Edge2, 1, TRUE );
			HSfree_Edge( Edge2 );
		}
		else
		{
#endif
			if( Horizontal ) Edge2->EdgeStatus |= HORIZONTAL_EDGE;
			else
				Edge2->SlopeInverse = ( Vertex1->coord[PlanarX] - OtherVert2->coord[PlanarX] ) /
					( Vertex1->coord[PlanarY] - OtherVert2->coord[PlanarY] );
			HSaddToSet( Edge2, OtherVert2, OUT, Horizontal, 0.0, PlanarX, PlanarY, (struct Edge *)NULL, (struct Edge *)NULL );
			HSaddToSet( Edge2, Vertex1, IN, Horizontal, 0.0, PlanarX, PlanarY, (struct Edge *)NULL, (struct Edge *)NULL );
#if NO_DUPLICATE_EDGES
		}
#endif
	}
	else
	{
		Edge2->Top = Vertex1;
		Edge2->Bottom = OtherVert2;
#if NO_DUPLICATE_EDGES
		if( HSedgeExists( Vertex1, OtherVert2 ) )
		{
			DelSetFromAEL( &Edge2, 1, TRUE );
			HSfree_Edge( Edge2 );
		}
		else
		{
#endif
			if( Horizontal ) Edge2->EdgeStatus |= HORIZONTAL_EDGE;
			else
				Edge2->SlopeInverse = ( OtherVert2->coord[PlanarX] - Vertex1->coord[PlanarX] ) /
					( OtherVert2->coord[PlanarY] - Vertex1->coord[PlanarY] );
			HSaddToSet( Edge2, Vertex1, OUT, Horizontal, 0.0, PlanarX, PlanarY, (struct Edge *)NULL, (struct Edge *)NULL );
			HSaddToSet( Edge2, OtherVert2, IN, Horizontal, 0.0, PlanarX, PlanarY, (struct Edge *)NULL, (struct Edge *)NULL );
#if NO_DUPLICATE_EDGES
		}
#endif
	}
	return( HANDLED );

} /* HSswitchEdges */

/*--- HSfindConnectingEdge() ---------------------------------------------------------*/

static struct Edge *HSfindConnectingEdge( TopVert, BottomVert )
	struct HStri_vertex *TopVert, *BottomVert;
/*
NAME
	HSfindConnectingEdge (static)

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
*/
{
	int i, Cardinality;
	struct Edge *TheEdge;

	Cardinality = TopVert->OutCardinality;
	for( i = 0; i < Cardinality; i++ )
	{
		TheEdge = TopVert->Out[i];
                if( TheEdge == NULL ) return NULL;
		if( TheEdge->Bottom == BottomVert )
		{
			return( TheEdge );
		}
	}
	return( (struct Edge *)NULL );

} /* HSfindConnectingEdge */

/*--- HShandleCrossingEdges() -----------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	int HShandleCrossingEdges( struct Edge *First, 
				   struct Edge *Second, 
					 short InOutFlag, 
					   int PlanarX, 
					   int PlanarY )
#else
	int HShandleCrossingEdges( First, Second, InOutFlag, PlanarX, PlanarY )
		struct Edge *First, *Second;
		short InOutFlag;
		int PlanarX, PlanarY;
#endif

/*
NAME
	HShandleCrossingEdges

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
	InOutFlag - Not currently used!
	PlanarX,PlanarY - Number of the coordinates (0-2) that are being used as the x,y
	values in triangulation.

GLOBALS USED
	none

RETURN VALUES
	CANNOT_HANDLE - Indicates the edges weren't successfully switched
	HANDLED - Indicates the edges WERE successfully switched

HISTORY
	08/03/91 Created. -Trevor Mink
*/
{
#if EDGE_CROSS_DEBUG
	void PrintFacet();
#endif
	int Handled;
	struct Edge *Edge1, *Edge2, *Connector;
	double y1, y2, x1, x2;

	y1 = First->Top->coord[PlanarY];
	y2 = Second->Top->coord[PlanarY];
	x1 = First->Top->coord[PlanarX];
	x2 = Second->Top->coord[PlanarX];
	if( y1 < y2 || ( y1 == y2 && x1 < x2 ) )
	{
		Edge1 = First;		Edge2 = Second;
	}
	else
	{
		Edge1 = Second;		Edge2 = First;
	}

	/* Try to find an edge which connects the two edges */
	if( (Connector = HSfindConnectingEdge( Edge1->Top, Edge2->Top ) ) &&
		(Connector != Edge1) && (Connector != Edge2) )
		(void)HSswitchEdges( Edge1->Top, OUT, Edge1, Edge2->Top, OUT, Edge2, PlanarX, PlanarY );
	else if( (Connector = HSfindConnectingEdge( Edge1->Bottom, Edge2->Bottom ) ) &&
		(Connector != Edge1) && (Connector != Edge2) )
		(void)HSswitchEdges( Edge1->Bottom, IN, Edge1, Edge2->Bottom, IN, Edge2, PlanarX, PlanarY );
	else if( (Connector = HSfindConnectingEdge( Edge1->Top, Edge2->Bottom ) ) &&
		(Connector != Edge1) && (Connector != Edge2) )
		(void)HSswitchEdges( Edge1->Top, OUT, Edge1, Edge2->Bottom, IN, Edge2, PlanarX, PlanarY );
	else if( (Connector = HSfindConnectingEdge( Edge2->Top, Edge1->Bottom ) ) &&
		(Connector != Edge1) && (Connector != Edge2) )
		(void)HSswitchEdges( Edge2->Top, OUT, Edge2, Edge1->Bottom, IN, Edge1, PlanarX, PlanarY );
	else if( (Connector = HSfindConnectingEdge( Edge2->Bottom, Edge1->Bottom ) ) &&
		(Connector != Edge1) && (Connector != Edge2) )
		(void)HSswitchEdges( Edge2->Bottom, IN, Edge2, Edge1->Bottom, IN, Edge1, PlanarX, PlanarY );
	else
	{
#if EDGE_CROSS_DEBUG
		fprintf( stderr, "I cannot handle these edges!\n");
		fprintf( stderr, "Edge 1: %x going from %lf,%lf to %lf, %lf\n",
			First, First->Top->coord[PlanarX], First->Top->coord[PlanarY],
			First->Bottom->coord[PlanarX], First->Bottom->coord[PlanarY] );
		fprintf( stderr, "Edge 2: %x going from %lf,%lf to %lf, %lf\n",
			Second, Second->Top->coord[PlanarX], Second->Top->coord[PlanarY],
			Second->Bottom->coord[PlanarX], Second->Bottom->coord[PlanarY] );
/*		PrintFacet( Facet );
*/
#endif
		Handled = CANNOT_HANDLE;
	}
	return( Handled );

} /* HShandleCrossingEdges */
