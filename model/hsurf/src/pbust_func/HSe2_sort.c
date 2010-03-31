#include <stdio.h>
#include <stdlib.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"

#include "hstiler.h"
#include "hslight.h"
#include "hsdisplay.h"

#include "HStl_window.h"
#include "HStl_element.h"
#include "HSfem_spt.h"
#include "HSd_fixedpt.h"
#include "HSe2_mesher.h"

#include "HSpr_pbust_f.h"

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

/* HSe2_sort.c */
static void HSbubbleSort __((int i, 
			     int j));
			     
static int HSpartition __((int i, 
			   int j));


#if defined(__cplusplus)
}
#endif


#undef __



#define BUBSIZE	9

static struct HStri_vertex **VertexList;
struct HStri_vertex **HSgetArray();
static int PlanarX, PlanarY;

#define EDGEII_DEBUG	0

/*--- HSsetupList ---------------------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	struct HStri_vertex **HSsetupList( struct HSloop *Facet, 
						     int NumVertices, 
						     int Pl_x, 
						     int Pl_y )
#else
	struct HStri_vertex **HSsetupList( Facet, NumVertices, Pl_x, Pl_y )

	struct HSloop *Facet;
	int NumVertices;
	int Pl_x, Pl_y;
#endif

/*
NAME
	HSsetupList (static)

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
*/
{
	int i = 0;
	struct HStri_vertex *Vertex, *Start;
	struct HSloop *Loop;

	PlanarX = Pl_x;
	PlanarY = Pl_y;

	VertexList = HSgetArray( NumVertices );

	for( Loop = Facet; Loop; Loop = Loop->next ) {
		Start = Vertex = (struct HStri_vertex *)(Loop->loop);
		do {
			VertexList[i++] = Vertex;
			Vertex = Vertex->next;
		} while( Vertex != Start );
	}

	return( VertexList );

} /* HSsetupList */

/*--- HSbubbleSort ------------------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HSbubbleSort( int i, int j )
#else
	static void HSbubbleSort( i, j )
	int i, j;
#endif

/*
NAME
	HSbubbleSort (static)

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
*/
{
	int k, Altered;
	struct HStri_vertex *TempVertex;
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

} /* HSbubbleSort */

/*--- HSpartition -----------------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static int HSpartition( int i, int j )
#else
	static int HSpartition( i, j )
	int i, j;
#endif

/*
NAME
	HSpartition (static)

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
*/
{
	int Upper, Lower;
	struct HStri_vertex *SaveRecord, *CompRecord;
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
} /* HSpartition */

/*--- HSquickSort -----------------------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSquickSort( int i, int j )
#else
	void HSquickSort( i, j )
	int i, j;
#endif

/*
NAME
	HSquickSort

DESCRIPTION
	HSquickSort() is a recursive routine. It takes two integers (indices of 'VertexList) as arguments.
	If the list delimited by 'i' and 'j' is <= BUBSIZE in length, it calls HSbubbleSort() to sort the
	list, otherwise, it calls HSpartition() to find the partitioning entry and calls itself for the two
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
*/
{
	int p;

#if EDGEII_DEBUG
	int x;

	for( x = i; x <= j; x++ )
		fprintf( stderr, "VertexList[%d] = ( %f, %f )\n",
			x, VertexList[x]->coord[PlanarX], VertexList[x]->coord[PlanarY] );
#endif
	if ( i < j ) {
		if ( j - i < BUBSIZE ) { /* do HSbubblesort on this list */
#if EDGEII_DEBUG
			fprintf( stderr, "HSbubblesorting between %d and %d\n", i, j );
#endif
			HSbubbleSort( i, j );
		} else {
			p = HSpartition( i, j );
#if EDGEII_DEBUG
			fprintf( stderr, "Partitioned at %d\n", p );
#endif
			HSquickSort( i, (p - 1) );
			HSquickSort( (p + 1), j );
		}
	}
} /* HSquickSort */
