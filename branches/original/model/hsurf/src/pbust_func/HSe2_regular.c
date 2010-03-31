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

#include "HStl_window.h"
#include "HStl_element.h"
#include "HStl_global.h"
#include "HSfem_spt.h"
#include "HSd_fixedpt.h"
#include "HSe2_mesher.h"

#include "HSpr_pbust_f.h"

/*-----------------------------
 *  for function
 *     HSalloc_VertPtr
 */
 
#include "HSpr_tiler_f.h"

/*-----------------------------*/


#define UNDETERMINED	3
#define CROSSING_EDGES	2
#define VALID		1
#define INVALID		0

#define DOWN_SWEEP	1
#define UP_SWEEP	2

static struct Edge *Left, *Right, *AEL;
static int PlanarX, PlanarY;

/*  Declaration moved to HSpr_pbust_f.h
 *
void HScreateEdges(), HSquickSort(), DrawEdges();
int HStriangulate();
struct HStri_vertex **HSsetupList();
 *
 */
struct PolygonVert *HSalloc_VertPtr();
 
#define DEBUG			0
#define TEMP_DEBUG		0
#define DRAWING			0
#define TRIMESH_DEBUG		0
#define BAD_BOUND_DEBUG		0
#define EDGE_CROSS_DEBUG	1

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

/* HSe2_regular.c */
static PrintAEL __((int PlanarX, 
		    int PlanarY));
		    
static void HSaddSetToAEL __((struct HStri_vertex *Vertex, 
					    short InOutFlag, 
					      int debug));
					      
static int HSweedAEL __((short InOutFlag, 
	   struct HStri_vertex *Vertex, 
			double x, 
			double y));
		      
static int HSsortAEL __((void));

static void HSgetOneIntercept __((struct HStri_vertex *Vertex, 
					       double y, 
					  struct Edge *ThisEdge, 
					     IGRshort SweepDirection));
					     
static int HScheckForCrossingEdges __((struct HStri_vertex *Vertex, 
						    double y, 
						     short InOutFlag, 
						 IGRdouble Tolerance, 
						  IGRshort SweepDirection, 
					struct HStri_loop *Facet));
					
static int HSfindInterval __((struct HStri_vertex *Vertex, 
					   double y, 
					      int debug, 
					    short InOutFlag, 
			       struct HStri_loop *Facet, 
					 IGRshort SweepDirection));
					 
static struct PolygonVert *HSregularize __((struct HStri_vertex **VertexList, 
							    int NumVertices, 
							    int debug, 
					     struct HStri_loop *Facet));
					     
static void PrintFacet __((struct HStri_loop *Facet, 
					 char filename[20 ]));



#if defined(__cplusplus)
}
#endif


#undef __


#if BAD_BOUND_DEBUG
static PrintAEL( PlanarX, PlanarY )
	int PlanarX, PlanarY; {

	struct Edge *TheEdge;
	fprintf( stderr,"Here is the active edge list\n" );
	for( TheEdge = AEL; TheEdge; TheEdge = TheEdge->Next ) {
		fprintf( stderr,"TheEdge: %x from (%f, %f) to (%f, %f)\n", TheEdge,
			TheEdge->Top->coord[PlanarX], TheEdge->Top->coord[PlanarY],
			TheEdge->Bottom->coord[PlanarX], TheEdge->Bottom->coord[PlanarY] );
	}
}
#endif

/*--- HSaddSetToAEL() ----------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HSaddSetToAEL( struct HStri_vertex *Vertex,
						 short InOutFlag,
						   int debug )
#else
	static void HSaddSetToAEL( Vertex, InOutFlag, debug )
	struct HStri_vertex *Vertex;
	short InOutFlag;
	int debug;
#endif

/*
NAME
	HSaddSetToAEL (static)

DESCRIPTION
	This function adds the edges of the given set (identified by 'Vertex' and distin-
	guished by 'InOutFlag') to the Active Edge List between the 'Left' and 'Right' edge
	pointers found in HSfindInterval().

KEYWORD
	triangulator

PARAMETERS
	Vertex (IN) - The current vertex.
	InOutFlag (IN) - Determines which set (IN or OUT) of edges for the vertex will be added.
	debug (IN) - Flag indicating whether to execute 'DEBUG' code.

GLOBALS USED
	Left,Right - Two edges that comprise the current interval on the active edge list.
	AEL - Pointer to the Head of the Active Edge List.

RETURN VALUES
	none.

HISTORY
	01/25/90 Created. -Trevor Mink
*/
{
	int Cardinality, i;
	struct Edge **EdgeArray, *TempLeft;
#if DEBUG
	int j;
#endif
	if( InOutFlag == OUT ) {
		Cardinality = Vertex->OutCardinality;
		EdgeArray = Vertex->Out;
#if DEBUG
		if( debug ) {
			fprintf( stderr, "Cardinality for OUT set = %d\n", Cardinality );
			for( j = 0; j < Cardinality; j++ )
				fprintf( stderr, "Vertex->Out[%d] = %x\n", j, EdgeArray[j] );
		}
#endif
	} else {
		Cardinality = Vertex->InCardinality;
		EdgeArray = Vertex->In;
#if DEBUG
		if( debug ) {
			fprintf( stderr, "Cardinality for IN set = %d\n", Cardinality );
			for( j = 0; j < Cardinality; j++ )
				fprintf( stderr, "Vertex->In[%d] = %x\n", j, EdgeArray[j] );
		}
#endif
	}

	/* Use temporary 'TempLeft' to keep from altering 'Left' */
	TempLeft = Left;

	for( i = 0; i < Cardinality; i++ ) {
		/* Add non-ADDED_EDGEs and make sure they aren't there already */
		if( !( EdgeArray[i]->EdgeStatus & ( ADDED_EDGE | ON_AEL ) ) ) {
#if DEBUG
			if( debug ) {
			fprintf( stderr, "Adding edge %x with vertex top = (%lf, %lf)\t", EdgeArray[i],
				EdgeArray[i]->Top->coord[PlanarX], EdgeArray[i]->Top->coord[PlanarY] );
			fprintf( stderr, "and vertex bottom = (%lf, %lf) to AEL\n",
				EdgeArray[i]->Bottom->coord[PlanarX], EdgeArray[i]->Bottom->coord[PlanarY] );
			}
#endif
			EdgeArray[i]->Extreme_y = Vertex;
			if( !TempLeft ) AEL = EdgeArray[i];
			else TempLeft->Next = EdgeArray[i];

			EdgeArray[i]->Next = Right;
			EdgeArray[i]->EdgeStatus |= ON_AEL;
			TempLeft = EdgeArray[i];
		}
	}

} /* HSaddSetToAEL */

/*--- HSdelSetFromAEL ------------------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSdelSetFromAEL( struct Edge **EdgeArray, 
				      int Cardinality, 
				      int debug )
#else
	void HSdelSetFromAEL( EdgeArray, Cardinality, debug )
		struct Edge **EdgeArray;
		int Cardinality;
		int debug;
#endif

/*
NAME
	HSdelSetFromAEL (static)

DESCRIPTION
	This function removes the 'Cardinality' edges of the given set (identified by 'EdgeArray')
	from the Active Edge List (if they're there) between the 'Left' and final edge of the AEL.

KEYWORD
	triangulator

PARAMETERS
	EdgeArray (IN) - Set of Incoming or Outgoing edges of the active edge list.
	Cardinality (IN) - The number of edges in the set.
	debug (IN) - Flag indicating whether to execute 'DEBUG' code.

GLOBALS USED
	Left,Right - Two edges that comprise the current interval on the active edge list.
	AEL - Pointer to the Head of the Active Edge List.

RETURN VALUES
	none.

HISTORY
	01/25/90 Created. -Trevor Mink
*/
{
	int i;
	struct Edge *Previous, *Current;
#if DEBUG
	int j;

	if( debug ) {
		fprintf( stderr, "Cardinality for set = %d\n", Cardinality );
		for( j = 0; j < Cardinality; j++ )
			fprintf( stderr, "EdgeArray[%d] = %x\n", j, EdgeArray[j] );
	}
#endif

	Previous = (struct Edge *)NULL;
	Current = AEL;
	for( i = 0; i < Cardinality && Current; ) {

if( !EdgeArray[i] ) return;
		if( EdgeArray[i]->EdgeStatus & ADDED_EDGE || !(EdgeArray[i]->EdgeStatus & ON_AEL) ) {
			i++;
			continue; /* Return to top of loop and restart */
		}
		if( Current == EdgeArray[i] ) {
#if DEBUG
			if( debug )
				fprintf( stderr, "Removing edge %x from AEL\n", EdgeArray[i] );
#endif
			if( Previous ) {
				Previous->Next = Current->Next;
				Current = Current->Next;
			} else {
				AEL = Current->Next;
				Current = AEL;
			}
			EdgeArray[i]->Next = (struct Edge *)NULL;
			EdgeArray[i]->EdgeStatus &= ~ON_AEL; /* Mark edge as being OFF the AEL */
			i++;

			/* Probably will need this due even with the detection and handling of crossing
			   edges in 'FindInterval()' */

			/* Start at front of list to find next edge */
			Previous = (struct Edge *)NULL;
			Current = AEL;

		} else {
			Previous = Current;
			Current = Current->Next;
		}
	}
} /* HSdelSetFromAEL */

/*--- HSweedAEL() ---------------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static int HSweedAEL( short InOutFlag,
		struct HStri_vertex *Vertex,
			      double x,
			      double y )
#else
	static int HSweedAEL( InOutFlag, Vertex, x, y )
	short InOutFlag;
	struct HStri_vertex *Vertex;
	double x, y;
#endif

/*
NAME
	HSweedAEL (static)

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
*/
{
	struct Edge *ThisEdge, *Previous;
	short Changed = FALSE;

	if( AEL )
	{
		Previous = (struct Edge *)NULL;
		for( ThisEdge = AEL; ThisEdge; )
		{
			if( ( (InOutFlag == OUT) && (ThisEdge->Bottom != Vertex) ) ||
			    ( (InOutFlag == IN) && (ThisEdge->Top != Vertex) ) )
			{
				if( ( (ThisEdge->Bottom->coord[PlanarY] < y) ||
					( (ThisEdge->Bottom->coord[PlanarY] == y) &&
					  (ThisEdge->Bottom->coord[PlanarX] < x) ) ) ||
					( (ThisEdge->Top->coord[PlanarY] > y) ||
					( (ThisEdge->Top->coord[PlanarY] == y) &&
					  (ThisEdge->Top->coord[PlanarX] > x) ) ) )
				{
					ThisEdge->EdgeStatus &= ~ON_AEL; /* Mark edge as being OFF the AEL */
					if( Previous ) Previous->Next = ThisEdge->Next;
					else AEL = ThisEdge->Next;
					Changed = TRUE;
				}
				else
					Previous = ThisEdge;
			}
			else
				Previous = ThisEdge;
			if( ThisEdge ) ThisEdge = ThisEdge->Next;
		}
	}
	return( Changed );

} /* HSweedAEL */

/*--- HSsortAEL() ----------------------------------------------------------------------*/

static int HSsortAEL()
/*
NAME
	HSweedAEL (static)

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
*/
{
	struct Edge *ThisEdge, *NextEdge, *Previous;
	short Switched, Changed = FALSE;

	if( AEL )
	do
	{
		Switched = FALSE;
		Previous = (struct Edge *)NULL;
		for( ThisEdge = AEL; (NextEdge = ThisEdge->Next); )
		{
			if( NextEdge->x_intercept < ThisEdge->x_intercept )
			{
				ThisEdge->Next = NextEdge->Next;
				if( Previous ) Previous->Next = NextEdge;
				else AEL = NextEdge;
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
	while( Switched );

	return( Changed );

} /* HSsortAEL */

/*--- HSgetOneIntercept() -------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)

static void HSgetOneIntercept( struct HStri_vertex *Vertex, 
					    double y, 
				       struct Edge *ThisEdge, 
					  IGRshort SweepDirection )


#else

static void HSgetOneIntercept( Vertex, y, ThisEdge, SweepDirection )

struct HStri_vertex *Vertex;
double y;
struct Edge *ThisEdge;
IGRshort SweepDirection;

#endif

/*
NAME
	HSgetOneIntercept (static)

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
*/
{
	double *VertexCoord;

	/***********************************/
	/* Get the x intercept of the edge */
	/***********************************/
	if( Vertex == ThisEdge->Bottom || Vertex == ThisEdge->Top )
	{
		if( SweepDirection == DOWN_SWEEP )
		{
			if( Vertex == ThisEdge->Bottom )
				ThisEdge->x_intercept = ThisEdge->Bottom->coord[PlanarX];
			else
				ThisEdge->x_intercept = ThisEdge->Top->coord[PlanarX];
		}
		else
		{
			if( Vertex == ThisEdge->Bottom )
				ThisEdge->x_intercept = ThisEdge->Top->coord[PlanarX];
			else
				ThisEdge->x_intercept = ThisEdge->Bottom->coord[PlanarX];
		}
	}
	else
	{
		if( ThisEdge->EdgeStatus & HORIZONTAL_EDGE )
		{
			if( SweepDirection == UP_SWEEP )
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

} /* HSgetOneIntercept */

/*--- HSgetIntercepts() ---------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	HSgetIntercepts( struct HStri_vertex *Vertex, 
				      double y, 
				    IGRshort SweepDirection )
#else
	HSgetIntercepts( Vertex, y, SweepDirection )
		struct HStri_vertex *Vertex;
		double y;
		IGRshort SweepDirection;
#endif

/*
NAME
	HSgetIntercepts

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
	Boolean indicating whether Active Edge List was changed.

HISTORY
	08/19/91 Created. -Trevor Mink
	02/13/92 Added 'SweepDirection' parameter for horizontal edge intercept determination.
*/
{
	struct Edge *ThisEdge;
	double *VertexCoord;

	for( ThisEdge = AEL; ThisEdge; ThisEdge = ThisEdge->Next )
	{
		/***********************************/
		/* Get the x intercept of the edge */
		/***********************************/
		if( Vertex == ThisEdge->Bottom || Vertex == ThisEdge->Top )
		{
			if( Vertex == ThisEdge->Bottom )
				ThisEdge->x_intercept = ThisEdge->Bottom->coord[PlanarX];
			else
				ThisEdge->x_intercept = ThisEdge->Top->coord[PlanarX];
		}
		else
		{
			if( ThisEdge->EdgeStatus & HORIZONTAL_EDGE )
			{
#if FALSE
				if( SweepDirection == UP_SWEEP )
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
} /* HSgetIntercepts */

/*--- HScheckForCrossingEdges() -------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)

static int HScheckForCrossingEdges (struct HStri_vertex *Vertex, 
						 double y, 
						  short InOutFlag, 
					      IGRdouble Tolerance, 
					       IGRshort SweepDirection, 
				     struct HStri_loop *Facet)
					
#else

static int HScheckForCrossingEdges( Vertex, y, InOutFlag, Tolerance, SweepDirection, Facet )

struct HStri_vertex *Vertex;
double y;
short InOutFlag;
IGRdouble Tolerance;
IGRshort SweepDirection;
struct HStri_loop *Facet;
	
#endif
/*
NAME
	HScheckForCrossingEdges (static)

DESCRIPTION
	This function goes through the Active Edge List and checks it for crossing edges.
	If any are found HShandleCrossingEdges() is called. That function will switch the
	edges if it can.

KEYWORD
	triangulator

PARAMETERS
	Vertex (IN) - The current vertex.
	y (IN) - y coordinate of current vertex.
	InOutFlag (IN) - Determines which set (IN or OUT) of edges for the vertex will be checked.
	Tolerance (IN) - The amount by which edges may legally cross (measured in x).
	Facet (IN) - Used for debugging only.

GLOBALS USED
	none.

RETURN VALUES
	CANNOT_HANDLE - If HShandleCrossingEdges() returns this.
	VALID - No crossing edges were found.
	CROSSING_EDGES (crossing edges that were handled okay.

HISTORY
	08/19/91 Created. -Trevor Mink
	08/03/91 Changed to search the entire active edge list every time and call
		 HShandleCrossingEdges() when crossing edges are found. -Trevor Mink
	02/13/92 Added 'SweepDirection' parameter for horizontal edge intercept determination.
		-Trevor Mink
*/
{
	struct Edge *ThisEdge, *NextEdge;
	int sStatus = VALID;
	double x;

	x = Vertex->coord[PlanarX];

	for( ThisEdge = AEL; ThisEdge && (NextEdge = ThisEdge->Next); ThisEdge = ThisEdge->Next )
	{
		if( (NextEdge->x_intercept + Tolerance) < ThisEdge->x_intercept )
		{
			if( HShandleCrossingEdges( ThisEdge, NextEdge, InOutFlag, PlanarX, PlanarY /*, Facet*/ )
				== CANNOT_HANDLE )
				return( CANNOT_HANDLE );
			else /* Edges uncrossed */
			{
				HSgetOneIntercept( Vertex, y, ThisEdge, SweepDirection );
				HSgetOneIntercept( Vertex, y, NextEdge, SweepDirection );

				sStatus = CROSSING_EDGES;
				HSsortAEL();
				(void)HSweedAEL( InOutFlag, Vertex, x, y );
			}
		}
	}
	return( sStatus );

} /* HScheckForCrossingEdges */

/*--- HSfindInterval() --------------------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)

static int HSfindInterval (struct HStri_vertex *Vertex, 
					double y, 
					   int debug, 
					 short InOutFlag, 
			    struct HStri_loop *Facet, 
				      IGRshort SweepDirection)
				      
#else

static int HSfindInterval( Vertex, y, debug, InOutFlag, Facet, SweepDirection )

struct HStri_vertex *Vertex;
double y;
int debug;
short InOutFlag;
struct HStri_loop *Facet;
IGRshort SweepDirection;
	
#endif

/*
NAME
	HSfindInterval (static)

DESCRIPTION
	This function searches the Active Edge List (AEL) to find the interval in which the
	given vertex lies. It sets the statics 'Left' and 'Right' to show the edges.

KEYWORD
	triangulator

PARAMETERS
	Vertex (IN) - The current vertex.
	y (IN) - y coordinate of current vertex.
	debug (IN) - Flag indicating whether to execute 'DEBUG' code.
	InOutFlag (IN) - Determines which set (IN or OUT) of edges for the vertex will be checked.
	Facet (IN) - Only needed in HShandleCrossingEdges() for debugging.
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
	CANNOT_HANDLE - If HShandleCrossingEdges() could not handle the crossing edges.
	VALID - No crossing edges were found.
	CROSSING_EDGES - Crossing edges that were handled okay.

HISTORY
	01/24/90 Created. -Trevor Mink
*/
{
	int sStatus = UNDETERMINED;
	struct Edge *SaveRight = (struct Edge *)NULL;
	double x;

#if DEBUG
	if( debug ) PrintAEL( PlanarX, PlanarY );
#endif
	HSgetIntercepts( Vertex, y, SweepDirection );

	if( (sStatus = HScheckForCrossingEdges( Vertex, y, InOutFlag,
		element_parms.dis_tol, SweepDirection, Facet ) ) == CANNOT_HANDLE )
		return CROSSING_EDGES;

	x = Vertex->coord[PlanarX];

	Left = AEL;
	Right = (struct Edge *)NULL;
	while( Left )
	{
		SaveRight = Right;
		Right = Left->Next;

if( !Right || !Left ) 
	{
	HSset_status( HSSTAT_BOUND_ERROR );
	return CROSSING_EDGES;
	}
		if( WITHIN_TOLERANCE( x, Left->x_intercept, element_parms.dis_tol ) )
			x = Vertex->coord[PlanarX] = Left->x_intercept;

		if( WITHIN_TOLERANCE( x, Right->x_intercept, element_parms.dis_tol ) )
			x = Vertex->coord[PlanarX] = Right->x_intercept;

		if( (Left->x_intercept <= x) && (x <= Right->x_intercept) )
		{
#if DEBUG
			if( debug ) {
				fprintf( stderr,
				"Valid interval found between left_x = %f and right_x = %f for x = %f\n",
				Left->x_intercept, Right->x_intercept, Vertex->coord[PlanarX] );
			}
#endif
			return( VALID );
		}
		else
		{
			if( x < Left->x_intercept )
			{
#if DEBUG
				if( debug ) {
					fprintf( stderr,
					"Invalid interval (left of leftmost edge) x = %f xleft = %f\n",
					Vertex->coord[PlanarX], xl_intercept );
				}
#endif
				Right = Left;
				Left = SaveRight;

				return( INVALID );
			}
		}
		Left = Right->Next;
	}
	if( !Left )
	{
		Left = Right;
		Right = (struct Edge *)NULL;
	}
	else
	{
		Right = Left;
		Left = SaveRight;
	}
	return( INVALID );

} /* HSfindInterval */

/*--- HSregularize() ---------------------------------------------------------------------------*/

static struct PolygonVert *HSregularize( VertexList, NumVertices, debug, Facet )
	struct HStri_vertex **VertexList;
	int NumVertices;
	int debug;
	struct HStri_loop *Facet;
/*
NAME
	HSregularize (static)

DESCRIPTION
	This function adds edges to the IN/OUT edge sets such that the solid portion of the
	original polygon/hole(s) is made up entirely of monotonic polygons. It makes two
	passes through the sorted vertices (one in increasing order, one decreasing).

KEYWORD
	triangulator

PARAMETERS
	VertexList (IN) - An array of pointers to the vertices of the polygon (sorted by y,x).
	NumVertices (IN) - The number of vertices in the polygon.
	debug (IN) - Flag indicating whether to execute 'DEBUG' code.
	Facet (IN) - Only needed for debugging.

GLOBALS USED
	Left,Right - Two edges that comprise the current interval on the active edge list.
	AEL - Pointer to the Head of the Active Edge List.

RETURN VALUES
	A pointer to a list of all Local Minima including duplicates if applicable.

HISTORY
	01/25/90 Created. -Trevor Mink
*/
{
	int i, Interval, SweepDirection;
	unsigned short AddedEdge = ADDED_EDGE;
	struct HStri_vertex *Vertex, *Vertex2;
	struct PolygonVert *Poly = (struct PolygonVert *)NULL, *Polygons = (struct PolygonVert *)NULL;
	double *LeftCoord, *RightCoord;

	AEL = (struct Edge *)NULL;
	Left = (struct Edge *)NULL;
	Right = (struct Edge *)NULL;

	/* Do the first sweep (Top-to-bottom) */
	SweepDirection = DOWN_SWEEP;
	for( i = 0; i < NumVertices; i++ ) {
		Vertex = VertexList[i];

		/* Find Interval of vertex in AEL */
		if( (Interval = HSfindInterval( Vertex, Vertex->coord[PlanarY], debug, OUT, Facet,
			SweepDirection ) ) == VALID ) {

			/* Are there no INcoming edges? */
			if( Vertex->InCardinality == 0 ) {
				/*	Determine the greater 'Extreme_y' vertex ('EdgeX->Extreme_y')
					between the two edges of the interval */
				LeftCoord = Left->Extreme_y->coord;
				RightCoord = Right->Extreme_y->coord;
				if( RightCoord[PlanarY] > LeftCoord[PlanarY] || ( RightCoord[PlanarY] == LeftCoord[PlanarY] &&
					RightCoord[PlanarX] > LeftCoord[PlanarX] ) )
					Vertex2 = Right->Extreme_y;
				else
					Vertex2 = Left->Extreme_y;
				if( Vertex2->OutCardinality > 0 ) {
#if DEBUG
					if( debug )
						fprintf( stderr,
						"Local minimum was found at Vertex ( %lf, %lf )\n",
						Vertex->coord[PlanarX], Vertex->coord[PlanarY] );
#endif
					Vertex2->LocalExtremity |= LOCAL_MINIMUM;
					if( !Polygons ) {
						Polygons = HSalloc_VertPtr();
						Poly = Polygons;
					} else {
						Poly->Next = HSalloc_VertPtr();
						Poly = Poly->Next;
					}
					Poly->Vertex = Vertex2;
				}
				HSaddEdge( Vertex, Vertex2, AddedEdge, PlanarX, PlanarY, Left, Right,
					element_parms.dis_tol );

			} else { /* INcoming edge(s) */
				Left->Extreme_y = Vertex;
				Right->Extreme_y = Vertex;
			}
		} else if( Interval == CROSSING_EDGES ) {
			/* Set the Active Edge List to null */
			AEL = (struct Edge *)NULL;
			Left = (struct Edge *)NULL;
			Right = (struct Edge *)NULL;

			return( (struct PolygonVert *)NULL );
		} else {
			if( Vertex->InCardinality == 0 ) {
#if DEBUG
				if( debug )
					fprintf( stderr, "Local minimum was found at Vertex ( %lf, %lf )\n",
					Vertex->coord[PlanarX], Vertex->coord[PlanarY] );
#endif
				Vertex->LocalExtremity |= LOCAL_MINIMUM;
				if( !Polygons ) {
					Polygons = HSalloc_VertPtr();
					Poly = Polygons;
				} else {
					Poly->Next = HSalloc_VertPtr();
					Poly = Poly->Next;
				}
				Poly->Vertex = Vertex;
			}
		}
#if DEBUG
		if( debug )
		fprintf( stderr, "Placing all OUTgoing vertices of Vertex = %x onto AEL\n", Vertex );
#endif
		/* Place all edges OUTgoing from 'Vertex' on the AEL */
		HSaddSetToAEL( Vertex, OUT, debug );
#if DEBUG
		if( debug )
		fprintf( stderr, "Removing all INcoming vertices of Vertex = %x from AEL\n", Vertex );
#endif
		/* Remove any edges INcoming to 'Vertex' from the AEL */
		HSdelSetFromAEL( Vertex->In, Vertex->InCardinality, debug );
	}

	AEL = (struct Edge *)NULL;
	Left = (struct Edge *)NULL;
	Right = (struct Edge *)NULL;

	/* Do the second sweep (Bottom-to-top) */
	SweepDirection = UP_SWEEP;
	for( i = NumVertices - 1; i >= 0; i-- ) {
		Vertex = VertexList[i];

		/* Find Interval of vertex in AEL */
		if( ( Interval = HSfindInterval( Vertex, Vertex->coord[PlanarY], debug, IN, Facet,
			SweepDirection ) ) == VALID ) {

			/* Are there no OUTgoing edges? */
			if( Vertex->OutCardinality == 0 ) {
				/* Determine the lesser 'Extreme_y' vertex 'EdgeX->Extreme_y'
					between the two edges of the interval */
				LeftCoord = Left->Extreme_y->coord;
				RightCoord = Right->Extreme_y->coord;
				if( RightCoord[PlanarY] < LeftCoord[PlanarY] ||
					( RightCoord[PlanarY] == LeftCoord[PlanarY] &&
					RightCoord[PlanarX] < LeftCoord[PlanarX] ) )
					Vertex2 = Right->Extreme_y;
				else
					Vertex2 = Left->Extreme_y;
				if( Vertex2->InCardinality > 0 )
					Vertex2->LocalExtremity |= LOCAL_MAXIMUM;
				HSaddEdge( Vertex, Vertex2, AddedEdge, PlanarX, PlanarY, Left, Right,
					element_parms.dis_tol );
			} else { /* OUTgoing edge(s) */
				Left->Extreme_y = Vertex;
				Right->Extreme_y = Vertex;
			}
		} else if( Interval == CROSSING_EDGES ) {
			/* Set the Active Edge List to null */
			AEL = (struct Edge *)NULL;
			Left = (struct Edge *)NULL;
			Right = (struct Edge *)NULL;

			return( (struct PolygonVert *)NULL );
		} else {
			if( Vertex->OutCardinality == 0 )
				Vertex->LocalExtremity |= LOCAL_MAXIMUM;
		}
#if DEBUG
		if( debug )
		fprintf( stderr, "Placing all INcoming vertices of Vertex = %x onto AEL\n", Vertex );
#endif
		/* Place all edges INcoming to 'Vertex' on the AEL */
		HSaddSetToAEL( Vertex, IN, debug );
#if DEBUG
		if( debug )
		fprintf( stderr, "Removing all OUTgoing vertices of Vertex = %x from AEL\n", Vertex );
#endif
		/* Remove any edges OUTgoing from 'Vertex' from the AEL */
		HSdelSetFromAEL( Vertex->Out, Vertex->OutCardinality, debug );
	}
	return( Polygons );

} /* HSregularize */

#define MAX_LOOPS	20

/*--- PrintFacet() ---------------------------------------------------------------------------*/

static void PrintFacet( Facet, filename )
	struct HStri_loop *Facet;
	char filename[20];
/*
NAME
	PrintFacet (static)

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
*/
{
	int NumLoops = 0, NumVerts[MAX_LOOPS], i;
	struct HStri_loop *Loop;
	struct HStri_vertex *StartVertex, *Vertex;
	FILE *outfile;

	for( Loop = Facet; Loop; Loop = Loop->next )
	{
		NumVerts[NumLoops] = 0;
		StartVertex = Vertex = Loop->loop;
		do {
			NumVerts[NumLoops]++;
			fprintf( stderr, "Vertex # %d at addr: %x is (%lf, %lf, %lf)\n", NumVerts[NumLoops],
				Vertex, Vertex->coord[0], Vertex->coord[1], Vertex->coord[2] );
			Vertex = Vertex->next;
		} while( StartVertex != Vertex );
		NumLoops++;
	}

	outfile = fopen( filename, "w" );
	fprintf( outfile, "%d\n", PlanarX );
	fprintf( outfile, "%d\n", PlanarY );
	fprintf( outfile, "%d\n", NumLoops );
	for( Loop = Facet, i = 0; Loop; Loop = Loop->next, i++ )
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
		} while( StartVertex != Vertex );
	}
	fclose( outfile );

} /* PrintFacet */

/*--- HSprocess_tri_facet() -------------------------------------------------------*/

int HSprocess_tri_facet(
   struct HStri_loop *Facet, 
   int TotalVertices, 
   int w_no, 
   int Plan_x, 
   int Plan_y )

/*
NAME
	HSprocess_tri_facet

DESCRIPTION
	This function takes the current 'Facet' and sends it through the Polygon Mesher
	to be Regularized and Triangulated.

KEYWORD
	triangulator

PARAMETERS
	Facet (IN) - Only needed for debugging.
	TotalVertices (IN) - The number of vertices in the facet.
	w_no (IN) - View context number used for EG calls.
	Plan_x, Plan_y (IN) - The indices (0-2) of the pt[] 3d coordinates to be used as the
	2d coordinates for triangulating the facet.

GLOBALS USED
	none.

RETURN VALUES
	The number of triangular meshes for the given facet.
	'NumTriMeshes' - Inaccurately returned by HStriangulate at this time. -Trevor Mink 2/13/92

HISTORY
	01/26/90 Created. -Trevor Mink
*/
{
	struct HStri_vertex **VertexList;
	struct PolygonVert *MonoPolys;
	int NumTriMeshes;

	int debug = 0;

#if TRIMESH_DEBUG
	fprintf( stderr, "element_parms.facet_normal = (%lf, %lf, %lf)\n", FABS(element_parms.facet_normal[0]),
		FABS(element_parms.facet_normal[1]), FABS(element_parms.facet_normal[2]) );
#endif
	PlanarX = Plan_x;
	PlanarY = Plan_y;

	/* Create the edges represented between the vertices */
	HScreateEdges( (struct HSloop *)Facet, PlanarX, PlanarY, element_parms.dis_tol );
#if DEBUG
/*	if( Facet->loop->coord[0] < 358.473 && Facet->loop->coord[0] > 358.472 &&
		Facet->loop->coord[1] < 138.480 && Facet->loop->coord[1] > 138.479 &&
		Facet->loop->coord[2] < 178987.722 && Facet->loop->coord[2] > 178987.721 )
		debug = 1;
	else
		debug = 0;
*/
#endif
#if TEMP_DEBUG
	if( debug )
		fprintf( stderr, "TotalVertices = %d\n", TotalVertices);
#endif
	/*
	 * This call is used to set up a list of vertices pointed to by an array of pointers.
	 * The list will then be sorted by a call to 'HSquickSort()'.
	 */
	VertexList = HSsetupList( (struct HSloop *)Facet, TotalVertices, PlanarX, PlanarY /*, element_parms.dis_tol*/ );
#if TEMP_DEBUG
	if( debug ) {
		if( !VertexList ) fprintf( stderr, "VertexList returned NULL from HSsetupList\n" );
		fprintf( stderr, "calling HSquickSort()\n" );
	}
#endif
	/* Quick-sort the entire list */
	HSquickSort( 0, TotalVertices - 1 );

#if TEMP_DEBUG
	if( debug )
		fprintf( stderr, "calling HSregularize()\n" );
#endif
	/* Regularize the vertex-edge set */
	if( TotalVertices > 2 ) {
		if( MonoPolys = HSregularize( VertexList, TotalVertices, debug, Facet ) ) {

#if TEMP_DEBUG
			if( debug )
				fprintf( stderr, "calling HStriangulate()\n" );
#endif
				NumTriMeshes = HStriangulate( w_no, MonoPolys, TotalVertices, PlanarX, PlanarY,
				element_parms.dis_tol, debug );
#if TEMP_DEBUG
			if( debug )
				fprintf( stderr, "NumTriMeshes = %d\n", NumTriMeshes );
#endif
		} else {
			/* Write bad-bound message */
#if BAD_BOUND_DEBUG
			fprintf( stderr, "Bad-boundary found for Facet = %x: disposing\n", Facet );
			PrintFacet( Facet );
#endif
			NumTriMeshes = 0;
		}
	} else {
#if DEBUG
		fprintf( stderr, "TotalVertices = %d, not regularizing\n", TotalVertices );
#endif
		NumTriMeshes = 0;
	}
	if( TotalVertices > ONE_K ) free( VertexList );

#if DRAWING
	DrawFacet( Facet, w_no );
	DrawEdges( VertexList, TotalVertices, w_no );
#endif
	return( NumTriMeshes );

} /* HSprocess_tri_facet */
