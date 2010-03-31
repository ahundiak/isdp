#include "hsurf_import.h"
#include "HSe2_mesher.h"
#include "hstiler.h"
#include <stdio.h>

#define BUBSIZE	9

static struct EDGEIIvertex **VertexList;
struct EDGEIIvertex **HSgetArray();
static int PlanarX, PlanarY;

#define EDGEII_DEBUG	0

/*
 * HSsetupList() gets an array of pointers to vertices and initializes it to point to the vertices of
 * the facet which will then be sorted. In addition, it initializes the static variables 'PlanarX' and
 * 'PlanarY'.
 *
 * HISTORY: 01/23/90	Created.
 *								Trevor Mink
 */

struct EDGEIIvertex **HSsetupList( Facet, NumVertices, Pl_x, Pl_y )
	struct HSloop *Facet;
	int NumVertices;
	int Pl_x, Pl_y; {

	int i = 0;
	struct EDGEIIvertex *Vertex, *Start;
	struct HSloop *Loop;

	PlanarX = Pl_x;
	PlanarY = Pl_y;

	VertexList = HSgetArray( NumVertices );

	for( Loop = Facet; Loop; Loop = Loop->next ) {
		Start = Vertex = (struct EDGEIIvertex *)(Loop->loop);
		do {
			VertexList[i++] = Vertex;
			Vertex = Vertex->next;
		} while( Vertex != Start );
	}

	return( VertexList );

} /* HSsetupList */

/*
 * BubbleSort() sorts the list delimited by the indices ('i' and 'j') of 'VertexList' using the
 * familiar bubblesort algorithm.
 *
 * HISTORY: 01/24/90	Created.
 *								Trevor Mink
 */

static void BubbleSort( i, j )
	int i, j; {

	int k, Altered;
	struct EDGEIIvertex *TempVertex;
	double x1, y1, x2, y2;

	do {
		Altered = FALSE;
		for( k = i; k < j; k++ ) {
			y1 = VertexList[k]->coord[PlanarY];
			x1 = VertexList[k]->coord[PlanarX];
			y2 = VertexList[k+1]->coord[PlanarY];
			x2 = VertexList[k+1]->coord[PlanarX];
			if( y1 > y2 || ( y1 == y2 && x1 > x2 ) ) {
				TempVertex = VertexList[k+1];
				VertexList[k+1] = VertexList[k];
				VertexList[k] = TempVertex;
				Altered = TRUE;
			}
		}
	} while( Altered );

} /* BubbleSort */

/*
 * Partition() manipulates the given list ('VertexList' between indices 'i' and 'j') and finds an
 * entry such that:
 * 1. The given entry is in its correct final position.
 * 2. Everything above it will stay above it and everything below it will remain below it in the final
 *	sorting.
 *
 * HISTORY: 01/23/90	Created.
 *								Trevor Mink
 */

static int Partition( i, j )
	int i, j; {

	int Upper, Lower;
	struct EDGEIIvertex *SaveRecord, *CompRecord;
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

	while( Upper != Lower ) {
		CompRecord = VertexList[Lower];
		CRcoord = CompRecord->coord;

		while( Upper < Lower && ( SRcoord[PlanarY] < CRcoord[PlanarY] ||
			( SRcoord[PlanarY] == CRcoord[PlanarY] &&
			  SRcoord[PlanarX] <= CRcoord[PlanarX]) ) ) {
			CompRecord = VertexList[--Lower];
			CRcoord = CompRecord->coord;
		}
		if( Upper != Lower )
			VertexList[Upper] = VertexList[Lower];

		CompRecord = VertexList[Upper];
		CRcoord = CompRecord->coord;

		while( Upper < Lower && ( SRcoord[PlanarY] > CRcoord[PlanarY] ||
			( SRcoord[PlanarY] == CRcoord[PlanarY] &&
			  SRcoord[PlanarX] >= CRcoord[PlanarX] ) ) ) {
			CompRecord = VertexList[++Upper];
			CRcoord = CompRecord->coord;
		}
		if( Upper != Lower )
			VertexList[Lower] = VertexList[Upper];
	}
	VertexList[Upper] = SaveRecord;

	return( Upper );
} /* Partition */

/*
 * HSquickSort() is a recursive routine. It takes two integers (indices of 'VertexList) as arguments.
 * If the list delimited by 'i' and 'j' is <= BUBSIZE in length, it calls BubbleSort() to sort the
 * list, otherwise, it calls Partition() to find the partitioning entry and calls itself for the two
 * sublists (created from the partitioning).
 *
 * HISTORY: 01/23/90	Created.
 *								Trevor Mink
 */

void HSquickSort( i, j )
	int i, j; {

	int p;

#if EDGEII_DEBUG
	int x;

	for( x = i; x <= j; x++ )
		fprintf( stderr, "VertexList[%d] = ( %f, %f )\n",
			x, VertexList[x]->coord[PlanarX], VertexList[x]->coord[PlanarY] );
#endif
	if ( i < j ) {
		if ( j - i < BUBSIZE ) { /* do Bubblesort on this list */
#if EDGEII_DEBUG
			fprintf( stderr, "Bubblesorting between %d and %d\n", i, j );
#endif
			BubbleSort( i, j );
		} else {
			p = Partition( i, j );
#if EDGEII_DEBUG
			fprintf( stderr, "Partitioned at %d\n", p );
#endif
			HSquickSort( i, (p - 1) );
			HSquickSort( (p + 1), j );
		}
	}
} /* HSquickSort */
