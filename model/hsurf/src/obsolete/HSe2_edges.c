#include <stdio.h>
#include "hsurf_import.h"
#include "HSe2_mesher.h"
#include "hstiler.h"

#define DEBUG	0
#define DRAWING	0

/*
 * HSalloc_edge() allocates an 'Edge' structure and returns a pointer to it.
 *
 * NOTE: Placed in function form for conversion to memory management routine later.
 *
 * HISTORY: 01/23/90	Created.
 *								Trevor Mink
 */

static struct Edge *HSalloc_edge() {

	return( (struct Edge *)malloc( sizeof( struct Edge ) ) );
} /* HSalloc_edge */

/*
 * HSaddToSet() adds the edge: 'EdgeToAdd' to the given set: 'Set'. The 'InOutFlag' designates
 * whether it's an OUTgoing set or an INcoming set.
 *
 * HISTORY: 01/23/90	Created.
 *								Trevor Mink
 */

static void HSaddToSet( EdgeToAdd, Vertex, InOutFlag, Horizontal, DistTol, PlanarY )
	struct Edge *EdgeToAdd;
	struct EDGEIIvertex *Vertex;
	short InOutFlag, Horizontal;
	double DistTol;
	int PlanarY; {

	struct Edge **EdgeSet;
	int i, j, Added = FALSE;
	int Cardinality;
	double deltaY;

	deltaY = EdgeToAdd->Top->coord[PlanarY] - EdgeToAdd->Bottom->coord[PlanarY];

#if DEBUG
	printf( "Horizontal = %d\n", Horizontal );
#endif
	if( Horizontal ) {
		if( InOutFlag == OUT ) {
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
			if( Cardinality > 0 ) {
				if( Vertex->Out[Cardinality-1]->EdgeStatus & HORIZONTAL_EDGE ) {
					Vertex->Out[Cardinality] = Vertex->Out[Cardinality-1];
					Vertex->Out[Cardinality-1] = EdgeToAdd;
				} else
					Vertex->Out[Cardinality] = EdgeToAdd;
			} else
				Vertex->Out[Cardinality] = EdgeToAdd;
			Vertex->OutCardinality++;
		} else {
			/* Horizontal edges will be the first in the set for the incoming vertex */
			/* Same holds here as above, but doesn't require special processing */
			for( j = Vertex->InCardinality; j > 0; j-- )
				Vertex->In[j] = Vertex->In[j-1];
			Vertex->In[0] = EdgeToAdd;
			Vertex->InCardinality++;
		}
	} else if( InOutFlag == OUT ) {
#if DEBUG
		printf( "Adding edge to OUT set at address %x\n", Vertex );
#endif
		EdgeSet = Vertex->Out;
		for ( i = 0; i < Vertex->OutCardinality && !Added; i++ ) {
#if DEBUG
			printf( "Out edge # %d\t", i );
			printf( "SlopeInverse = %lf\t", EdgeSet[i]->SlopeInverse );
			printf( "EdgeStatus = %d\n", EdgeSet[i]->EdgeStatus );
#endif
			if( EdgeSet[i]->EdgeStatus & HORIZONTAL_EDGE ||
				EdgeToAdd->SlopeInverse < EdgeSet[i]->SlopeInverse + DistTol / deltaY ) {
#if DEBUG
				printf( "EdgeToAdd->SlopeInverse = %lf\n", EdgeToAdd->SlopeInverse );
				printf( "Out edges %d through %d will shift\n",
					i, Vertex->OutCardinality );
#endif
				for( j = Vertex->OutCardinality - 1; j >= i; j-- )
					EdgeSet[j+1] = EdgeSet[j];
				EdgeSet[i] = EdgeToAdd;
				Added = TRUE;
			}
		}
		if( !Added ) EdgeSet[Vertex->OutCardinality] = EdgeToAdd;
		Vertex->OutCardinality++;
	} else {
#if DEBUG
		printf( "Adding edge to IN set at address %x\n", Vertex );
#endif
		EdgeSet = Vertex->In;
		for ( i = 0; i < Vertex->InCardinality && !Added; i++ ) {
			if( !( EdgeSet[i]->EdgeStatus & HORIZONTAL_EDGE ) &&
				EdgeToAdd->SlopeInverse > EdgeSet[i]->SlopeInverse - DistTol / deltaY ) {

				for( j = Vertex->InCardinality - 1; j >= i; j-- )
					EdgeSet[j+1] = EdgeSet[j];
				EdgeSet[i] = EdgeToAdd;
				Added = TRUE;
			}
		}
		if( !Added ) EdgeSet[Vertex->InCardinality] = EdgeToAdd;
		Vertex->InCardinality++;
	}
} /* HSaddToSet */

/*
 * HSaddEdge() allocates an edge to go from 'Vertex1' to 'Vertex2' and adds to the appropriate edge set
 * of both 'Vertex1' and 'Vertex2'. Also, it sets up the edge status and slope-inverse.
 *
 * HISTORY: 01/23/90	Created.
 *								Trevor Mink
 */

void HSaddEdge( Vertex1, Vertex2, EdgeType, PlanarX, PlanarY, DistTol )
	struct EDGEIIvertex *Vertex1, *Vertex2;
	unsigned short EdgeType;
	int PlanarX, PlanarY;
	double DistTol; {

	struct Edge *EdgeToAdd;

#if DEBUG
	printf( "Adding edge from (%lf, %lf) to (%lf, %lf) of type %d\n",
		Vertex1->coord[PlanarX],Vertex1->coord[PlanarY],
		Vertex2->coord[PlanarX], Vertex2->coord[PlanarY], EdgeType );
#endif
	EdgeToAdd = HSalloc_edge();
#if DEBUG
	if( !EdgeToAdd ) printf( "EdgeToAdd returned NULL from alloc\n" );
#endif
	EdgeToAdd->EdgeStatus = EdgeType;

	if( Vertex1->coord[PlanarY] == Vertex2->coord[PlanarY] )
		EdgeToAdd->EdgeStatus |= HORIZONTAL_EDGE;
	else
		EdgeToAdd->SlopeInverse = ( Vertex2->coord[PlanarX] - Vertex1->coord[PlanarX] ) /
			( Vertex2->coord[PlanarY] - Vertex1->coord[PlanarY] );
#if DEBUG
	printf( "SlopeInverse of EdgeToAdd = %lf\n", EdgeToAdd->SlopeInverse );
#endif
	if( Vertex1->coord[PlanarY] < Vertex2->coord[PlanarY] ) {
		EdgeToAdd->Top = Vertex1;
		EdgeToAdd->Bottom = Vertex2;
		HSaddToSet( EdgeToAdd, Vertex1, OUT, FALSE, DistTol, PlanarY );
		HSaddToSet( EdgeToAdd, Vertex2, IN, FALSE, DistTol, PlanarY );
	} else if( Vertex1->coord[PlanarY] == Vertex2->coord[PlanarY] ) {
		if( Vertex1->coord[PlanarX] < Vertex2->coord[PlanarX] ) {
			EdgeToAdd->Top = Vertex1;
			EdgeToAdd->Bottom = Vertex2;
			HSaddToSet( EdgeToAdd, Vertex1, OUT, TRUE, DistTol, PlanarY );
			HSaddToSet( EdgeToAdd, Vertex2, IN, TRUE, DistTol, PlanarY );
		} else {
			EdgeToAdd->Top = Vertex2;
			EdgeToAdd->Bottom = Vertex1;
			HSaddToSet( EdgeToAdd, Vertex2, OUT, TRUE, DistTol, PlanarY );
			HSaddToSet( EdgeToAdd, Vertex1, IN, TRUE, DistTol, PlanarY );
		}
	} else { /* Vertex1->coord[PlanarY] > Vertex2->coord[PlanarY] */
		EdgeToAdd->Top = Vertex2;
		EdgeToAdd->Bottom = Vertex1;
		HSaddToSet( EdgeToAdd, Vertex2, OUT, FALSE, DistTol, PlanarY );
		HSaddToSet( EdgeToAdd, Vertex1, IN, FALSE, DistTol, PlanarY );
	}
} /* HSaddEdge */

/*
 * HScreateEdges() takes every loop of the given 'Facet' and creates an edge from vertex to vertex
 * for the entire loop.
 *
 * HISTORY: 01/29/90	Created.
 *								Trevor Mink
 */

void HScreateEdges( Facet, PlanarX, PlanarY, DistTol )
	struct HSloop *Facet;
	int PlanarX, PlanarY;
	double DistTol; {

	struct HSloop *Loop;
	struct EDGEIIvertex *Start, *Vertex;

	for( Loop = Facet; Loop; Loop = Loop->next ) {
		Start = Vertex = (struct EDGEIIvertex *)(Loop->loop);
		do {
			HSaddEdge( Vertex, Vertex->next, ORIGINAL_EDGE, PlanarX, PlanarY, DistTol );
			Vertex = Vertex->next;
		} while( Vertex != Start );
	}

} /* HScreateEdges */
