#include "igrtypedef.h"
#include "HStl_element.h"
#include "HSe2_mesher.h"
#include "hsurf_import.h"
#include "hsmath.h"
/***
#include "bsparameters.h"
***/
#include <stdio.h>

#define CROSSING_EDGES	2
#define VALID		1
#define INVALID		0

static struct Edge *Left, *Right, *AEL;
static int PlanarX, PlanarY;

void HScreateEdges(), HSquickSort(), DrawEdges();
int HStriangulate();
struct EDGEIIvertex **HSsetupList();
struct PolygonVert *HSalloc_VertPtr();

#define DEBUG		0
#define TEMP_DEBUG	0
#define DRAWING		0
#define TRIMESH_DEBUG	0
#define BAD_BOUND_DEBUG	0

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

/*
 * FindInterval() searches the Active Edge List (AEL) to find the interval in which the given vertex
 * lies. It sets the statics 'Left' and 'Right' to show the edges. In addition, it returns a VALID,
 * INVALID, or CROSSING_EDGES status to indicate if this interval is part of the solid portion of the
 * polygon or if an invalid boundary was found in the polygon (CROSSING_EDGES).
 *
 * NOTE: If 'Left' is null, an insertion would be at the head of the AEL. If 'Right' is null, the
 * insertion would be at the end. If both are null, no edges were on the AEL and insertion is obvious.
 *
 * HISTORY: 01/24/90	Created.
 *								Trevor Mink
 */

static int FindInterval( Vertex, y, debug )
	struct EDGEIIvertex *Vertex;
	double y;
	int debug; {

	int Status = INVALID, FirstTime = TRUE;
	double *VertexCoord, xl_intercept, xr_intercept, LastRightInt;
	struct Edge *SaveRight, *NextEdge;

	long rc;

#if DEBUG
	if( debug ) PrintAEL( PlanarX, PlanarY );
#endif
	Left = AEL;
	Right = (struct Edge *)NULL;
	while( Left ) {
		SaveRight = Right;
		Right = Left->Next;

		if( Left->Bottom == Vertex || Right->Bottom == Vertex ) {
#if DEBUG
			if( debug ) {
				fprintf( stderr,
				"Valid interval found between left_x = %f and right_x = %f for x = %f\n",
				Left->Bottom->coord[PlanarX], Right->Bottom->coord[PlanarX], Vertex->coord[PlanarX] );
			}
#endif
			if( Left->Bottom == Vertex ) {
				VertexCoord = Right->Top->coord;
				xr_intercept = Right->SlopeInverse * ( y - VertexCoord[PlanarY] ) +
					VertexCoord[PlanarX];
			} else
				xr_intercept = Right->Bottom->coord[PlanarX];
			Status = VALID;
			break;
		}

		if( Left->EdgeStatus & HORIZONTAL_EDGE )
			xl_intercept = Left->Top->coord[PlanarX];
		else {
			VertexCoord = Left->Top->coord;
			xl_intercept = Left->SlopeInverse * ( y - VertexCoord[PlanarY] ) + VertexCoord[PlanarX];
		}

		if( Right->EdgeStatus & HORIZONTAL_EDGE )
			xr_intercept = Right->Bottom->coord[PlanarX];
		else {
			VertexCoord = Right->Top->coord;
			xr_intercept = Right->SlopeInverse * ( y - VertexCoord[PlanarY] ) +
				VertexCoord[PlanarX];
		}

		/* Check for crossing edges */
		if( ( !FirstTime && xl_intercept < LastRightInt - element_parms.dis_tol ) ||
			xr_intercept < xl_intercept - element_parms.dis_tol ) {
#if BAD_BOUND_DEBUG
			if( debug ) {
				fprintf( stderr,
					"Crossing edges found: left_x = %f and right_x = %f for x = %f\n",
					xl_intercept, xr_intercept, Vertex->coord[PlanarX] );
				PrintAEL( PlanarX, PlanarY );
			}
#endif
			return( CROSSING_EDGES );
		}
		FirstTime = FALSE;

		if( xl_intercept <= Vertex->coord[PlanarX] + element_parms.dis_tol &&
			Vertex->coord[PlanarX] <= xr_intercept + element_parms.dis_tol ) {
#if DEBUG
			if( debug ) {
				fprintf( stderr,
				"Valid interval found between left_x = %f and right_x = %f for x = %f\n",
				xl_intercept, xr_intercept, Vertex->coord[PlanarX] );
			}
#endif
			Status = VALID;
			break;
		} else {
			if( Vertex->coord[PlanarX] < xl_intercept - element_parms.dis_tol ) {
#if DEBUG
				if( debug ) {
					fprintf( stderr,
					"Invalid interval (left of leftmost edge) x = %f xleft = %f\n",
					Vertex->coord[PlanarX], xl_intercept );
				}
#endif
				Status = INVALID;
				break;
			}
		}
		Left = Right->Next;
		LastRightInt = xr_intercept;
	}
	if( Left ) {
		/* Check next edge to assure that the edge is still sorted according to x-intercept */
		if( NextEdge = Right->Next ) { /* If another edge exists in the AEL */
			if( NextEdge->EdgeStatus & HORIZONTAL_EDGE )
				LastRightInt = NextEdge->Bottom->coord[PlanarX];
			else {
				VertexCoord = NextEdge->Top->coord;
				LastRightInt = NextEdge->SlopeInverse * ( y - VertexCoord[PlanarY] ) +
					VertexCoord[PlanarX];
			}
			if( LastRightInt < xr_intercept - element_parms.dis_tol ) {
#if BAD_BOUND_DEBUG
				if( debug ) {
					fprintf( stderr,
					"Crossing edges found: right_x = %f Following_x = %f for x = %f\n",
						xr_intercept, LastRightInt, Vertex->coord[PlanarX] );
					PrintAEL( PlanarX, PlanarY );
				}
#endif
				return( CROSSING_EDGES );
			}
		}
	}
	if( Status == INVALID ) {
		if ( !Left ) {
			Left = Right;
			Right = (struct Edge *)NULL;
		} else {
			Right = Left;
			Left = SaveRight;
		}
	}
	return( Status );
} /* FindInterval */

/*
 * AddSetToAEL() adds the edges of the given set (identified by 'Vertex' and distinguished by
 * 'InOutFlag') to the Active Edge List between the 'Left' and 'Right' edge pointers found in
 * FindInterval().
 *
 * HISTORY: 01/25/90	Created.
 *								Trevor Mink
 */

static void AddSetToAEL( Vertex, InOutFlag, debug )
	struct EDGEIIvertex *Vertex;
	short InOutFlag;
	int debug; {

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
			if( !Right ) {
				EdgeArray[i]->Next = (struct Edge *)NULL;
			}
			EdgeArray[i]->EdgeStatus |= ON_AEL;
			TempLeft = EdgeArray[i];
		}
	}

} /* AddSetToAEL */

/*
 * DelSetFromAEL() removes the edges of the given set (identified by 'Vertex' and distinguished by
 * 'InOutFlag') from the Active Edge List (if they're there) between the 'Left' and final edge of
 * the AEL.
 *
 * HISTORY: 01/25/90	Created.
 *								Trevor Mink
 */

static void DelSetFromAEL( Vertex, InOutFlag, debug )
	struct EDGEIIvertex *Vertex;
	short InOutFlag;
	int debug; {

	int Cardinality, i;
	struct Edge **EdgeArray, *Previous, *Current;
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

	Previous = (struct Edge *)NULL;
	Current = AEL;
	for( i = 0; i < Cardinality && Current; ) {

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
} /* DelSetFromAEL */

/*
 * HSregularize() adds edges to the IN/OUT edge sets such that the solid portion of the original
 * polygon/hole(s) is made up entirely of monotonic polygons. It makes two passes through the sorted
 * vertices (one in increasing order, one decreasing). Additionally, it returns a pointer to a list
 * of all Local Minima including duplicates if applicable.
 *
 * HISTORY: 01/25/90	Created.
 *								Trevor Mink
 */

static struct PolygonVert *HSregularize( VertexList, NumVertices, debug )
	struct EDGEIIvertex **VertexList;
	int NumVertices;
	int debug; {

	int i, Interval;
	unsigned short AddedEdge = ADDED_EDGE;
	struct EDGEIIvertex *Vertex, *Vertex2;
	struct PolygonVert *Poly, *Polygons = (struct PolygonVert *)NULL;
	double *LeftCoord, *RightCoord;

	AEL = (struct Edge *)NULL;
	Left = (struct Edge *)NULL;
	Right = (struct Edge *)NULL;

	/* Do the first sweep (Top-to-bottom) */
	for( i = 0; i < NumVertices; i++ ) {
		Vertex = VertexList[i];

		/* Find Interval of vertex in AEL */
		if( (Interval = FindInterval( Vertex, Vertex->coord[PlanarY], debug ) ) == VALID ) {

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
				HSaddEdge( Vertex, Vertex2, AddedEdge, PlanarX, PlanarY );

			} else { /* INcoming edge(s) */
				Left->Extreme_y = Vertex;
				Right->Extreme_y = Vertex;
			}
		} else if( Interval == CROSSING_EDGES ) {
			/* Set the Active Edge List to null */
			AEL = (struct Edge *)NULL;
			Left = (struct Edge *)NULL;
			Right = (struct Edge *)NULL;

			free_Mins( Polygons );
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
		AddSetToAEL( Vertex, OUT, debug );
#if DEBUG
		if( debug )
		fprintf( stderr, "Removing all INcoming vertices of Vertex = %x from AEL\n", Vertex );
#endif
		/* Remove any edges INcoming to 'Vertex' from the AEL */
		DelSetFromAEL( Vertex, IN, debug );
	}

	AEL = (struct Edge *)NULL;
	Left = (struct Edge *)NULL;
	Right = (struct Edge *)NULL;

	/* Do the second sweep (Bottom-to-top) */
	for( i = NumVertices - 1; i >= 0; i-- ) {
		Vertex = VertexList[i];

		/* Find Interval of vertex in AEL */
		if( ( Interval = FindInterval( Vertex, Vertex->coord[PlanarY], debug ) ) == VALID ) {

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
				HSaddEdge( Vertex, Vertex2, AddedEdge, PlanarX, PlanarY );

			} else { /* OUTgoing edge(s) */
				Left->Extreme_y = Vertex;
				Right->Extreme_y = Vertex;
			}
		} else if( Interval == CROSSING_EDGES ) {
			/* Set the Active Edge List to null */
			AEL = (struct Edge *)NULL;
			Left = (struct Edge *)NULL;
			Right = (struct Edge *)NULL;

			free_Mins( Polygons );
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
		AddSetToAEL( Vertex, IN, debug );
#if DEBUG
		if( debug )
		fprintf( stderr, "Removing all OUTgoing vertices of Vertex = %x from AEL\n", Vertex );
#endif
		/* Remove any edges OUTgoing from 'Vertex' from the AEL */
		DelSetFromAEL( Vertex, OUT, debug );
	}
	return( Polygons );

} /* HSregularize */

/*
 * PrintFacet() prints the facet. (What did you think it did?)
 *
 * HISTORY: 2/14/90	Created.
 *								Trevor Mink
 */

static void PrintFacet( Facet )
	struct EDGEII_loop *Facet; {

	int NumLoops = 0, NumVerts = 0;
	struct EDGEII_loop *Loop;
	struct EDGEIIvertex *StartVertex, *Vertex;

	for( Loop = Facet; Loop; Loop = Loop->next ) {
		NumVerts = 0;
		NumLoops++;
		fprintf( stderr, "Loop # %d\n", NumLoops );
		StartVertex = Vertex = Loop->loop;
		do {
			NumVerts++;
			fprintf( stderr, "Vertex # %d at addr: %x is (%lf, %lf, %lf)\n", NumVerts,
				Vertex, Vertex->coord[0], Vertex->coord[1], Vertex->coord[2] );
			Vertex = Vertex->next;
		} while( StartVertex != Vertex );
	}

} /* PrintFacet */

/*
 * HSprocess_edgeII_facet() takes the current 'Facet' and sends it through the Polygon Mesher
 * to be Regularized and Triangulated. It also returns the number of triangular meshes
 * for the given facet.
 *
 * HISTORY: 1/26/90	Created.
 *								Trevor Mink
 */

int HSprocess_edgeII_facet( Facet, TotalVertices, w_no, Plan_x, Plan_y )
	struct EDGEII_loop *Facet;
	int TotalVertices;
	int w_no;
	int Plan_x, Plan_y; {

	struct EDGEIIvertex **VertexList;
	struct PolygonVert *MonoPolys, *Min;
	int NumTriMeshes;

	int debug = 0;

#if TRIMESH_DEBUG
	fprintf( stderr, "element_parms.facet_normal = (%lf, %lf, %lf)\n", FABS(element_parms.facet_normal[0]),
		FABS(element_parms.facet_normal[1]), FABS(element_parms.facet_normal[2]) );
#endif
	PlanarX = Plan_x;
	PlanarY = Plan_y;

	/* Create the edges represented between the vertices */
	HScreateEdges( Facet, PlanarX, PlanarY, element_parms.dis_tol );
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
	VertexList = HSsetupList( Facet, TotalVertices, PlanarX, PlanarY );
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
		if( MonoPolys = HSregularize( VertexList, TotalVertices, debug ) ) {

#if TEMP_DEBUG
			if( debug )
				fprintf( stderr, "calling HStriangulate()\n" );
#endif
			NumTriMeshes = HStriangulate( w_no, MonoPolys, TotalVertices, PlanarX, PlanarY,
				element_parms.dis_tol, debug );
			free_Mins( MonoPolys );
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

#if DRAWING
	DrawFacet( Facet, w_no );
	DrawEdges( VertexList, TotalVertices, w_no );
#endif
	return( NumTriMeshes );

} /* HSprocess_edgeII_facet */
