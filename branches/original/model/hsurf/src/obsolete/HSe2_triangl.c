#include <tools.h>
#include "igrtypedef.h"
#include <EG.h>
#include "math.h"
#include "hsurf_import.h"
#include "HStl_global.h"
#include "HStl_element.h"
#include "HStl_window.h"
#include "HSe2_mesher.h"
#include "hstiler.h"
#include <stdio.h>

#define NEITHER_SIDE	0
#define LEFT_SIDE	1
#define RIGHT_SIDE	2

static struct Edge *Left, *Right;
static struct PolygonVert *MonoPolys;
static struct PolygonVert **Stack;
static int NumTriMeshes;
static int Top = -1;

#define DEBUG		0
#define CONST_DEBUG	0
#define SMOOTH_DEBUG	0
#define DRAWING		0

void HSsave_TriMesh();

/*
 * GetNextSide() resets the 'Left' or 'Right' static edge pointer to aid in merging of the two monotonic
 * chains of the current polygon. Also, it returns the side (RIGHT_SIDE or LEFT_SIDE) which contains the
 * next vertex to be merged into the sorted array. A return code of NEITHER_SIDE means the 'Left' and
 * 'Right' edges have met.
 *
 * HISTORY: 02/05/90	Created.
 *								Trevor Mink
 */

static int GetNextSide( PlanarX, PlanarY, debug )
	int PlanarX, PlanarY;
	int debug; {

	int RightMost;
	struct EDGEIIvertex *v;
	double *RightCoord, *LeftCoord;

	if( Right->Bottom == Left->Bottom ) return( NEITHER_SIDE );

	LeftCoord = Left->Bottom->coord;
	RightCoord = Right->Bottom->coord;
#if DEBUG
	if( debug ) {
		fprintf( stderr, "LeftCoord = (%f, %f)\tRightCoord = (%f, %f)\n",
			LeftCoord[PlanarX], LeftCoord[PlanarY], RightCoord[PlanarX], RightCoord[PlanarY] );
		fprintf( stderr, "Left->Bottom = %x\tRight->Bottom = %x\n", Left->Bottom, Right->Bottom);
	}
#endif
	if( RightCoord[PlanarY] > LeftCoord[PlanarY] ||
		(RightCoord[PlanarY] == LeftCoord[PlanarY] &&
		RightCoord[PlanarX] > LeftCoord[PlanarX]) ) {
		v = Left->Bottom;
		RightMost = v->OutCardinality - 1;
		Left = v->Out[RightMost];
#if DEBUG
		if( debug ) {
			fprintf( stderr, "RightMost = %d\n", RightMost );
			fprintf( stderr, "v(Left->Bottom) = %x\tLeft = %x\n", v, Left );
		}
#endif
		return( LEFT_SIDE );
	} else {
		v = Right->Bottom;
		Right = v->Out[0];
#if DEBUG
		if( debug )
			fprintf( stderr, "v(Right->Bottom) = %x\tRight = %x\n", v, Right );
#endif
		return( RIGHT_SIDE );
	}

} /* GetNextSide */

static int VertNum = 0;

/*
 * GetMonoPolygon() places the monotonic polygon beginning at the given 'LocalMin' into a linked list
 * structure specifically designed for monotonic polygons and their triangulation. In addition, it
 * returns the number of vertices in the monotonic polygon.
 *
 * HISTORY: 2/5/90	Created.
 *								Trevor Mink
 */

static int GetMonoPolygon( LocalMin, PlanarX, PlanarY, debug )
	struct EDGEIIvertex *LocalMin;
	int PlanarX, PlanarY;
	int debug; {

	int NumVerts = 0, MinSide = LEFT_SIDE; /* Either side is okay to begin with */
	int left, right;
	double *RightCoord, *LeftCoord;
	struct Edge **EdgeSet;
	void PrintMonoPoly();

	/* Initial setting of 'Left' and 'Right' */
	EdgeSet = LocalMin->Out;
	left = 0;
	right = 1;
	if( LocalMin->OutCardinality > 2 ) {
		while( !( (EdgeSet[left]->EdgeStatus & ADDED_EDGE) ||
			(EdgeSet[right]->EdgeStatus & ADDED_EDGE) ) ) {
			left++;
			right++;
#if DEBUG
			fprintf( stderr, "left = %d\tright = %d\n", left, right );
#endif
		}
		if( LocalMin->LocalExtremity & MONO_MADE ) {
#if DEBUG
			fprintf( stderr, "A local minimum was used twice\n" );
#endif
			do {
				left++;
				right++;
#if DEBUG
				fprintf( stderr, "left = %d\tright = %d\n", left, right );
#endif
			} while( !( (EdgeSet[left]->EdgeStatus & ADDED_EDGE) ||
				(EdgeSet[right]->EdgeStatus & ADDED_EDGE) ) );
		}
		LocalMin->LocalExtremity |= MONO_MADE;
	}
	Left = EdgeSet[left];
	Right = EdgeSet[right];

	/* Now, merge the monotonic polygon into its linked list structure */
	do {
		MonoPolys[NumVerts].Side = MinSide;

#if DEBUG
		if( debug ) {
		fprintf( stderr, "NumVerts = %d\n", NumVerts );
		fprintf( stderr, "MonoPolys[NumVerts] = %x\n", MonoPolys[NumVerts] );
		fprintf( stderr, "left = %d\n", left );
		fprintf( stderr, "right = %d\n", right );
		fprintf( stderr, "EdgeSet[left] = %x\n", EdgeSet[left] );
		fprintf( stderr, "EdgeSet[right] = %x\n", EdgeSet[right] );
		fprintf( stderr, "Left = %x\n", Left );
		fprintf( stderr, "Left->Top = %x\n", Left->Top );
		}
#endif
		if( MinSide == LEFT_SIDE )
			MonoPolys[NumVerts].Vertex = Left->Top;
		else
			MonoPolys[NumVerts].Vertex = Right->Top;
		NumVerts++;
#if DEBUG
		if( debug ) {
			PrintMonoPoly( NumVerts, PlanarX, PlanarY );
			/* Change 'Left' or 'Right' and return which side has lesser 'Bottom' vertex */
			MinSide = GetNextSide( PlanarX, PlanarY, 1 );
		} else 
			/* Change 'Left' or 'Right' and return which side has lesser 'Bottom' vertex */
			MinSide = GetNextSide( PlanarX, PlanarY, 0 );
#else
		/* Change 'Left' or 'Right' and return which side has lesser 'Bottom' vertex */
		MinSide = GetNextSide( PlanarX, PlanarY, 0 );
#endif
	} while( MinSide != NEITHER_SIDE );

	/* Now, place the local maximum vertex at the end of the linked list */

	MonoPolys[NumVerts].Side = MinSide;
	MonoPolys[NumVerts].Vertex = Left->Bottom;	/* or 'Right->Bottom' */
	NumVerts++;
	return( NumVerts );

} /* GetMonoPolygon */

#if DEBUG

static void PrintMonoPoly( NumVerts, PlanarX, PlanarY )
	int NumVerts;
	int PlanarX, PlanarY; {

	int i;
	float x, y;
	struct PolygonVert *Poly;

	fprintf( stderr, "\nNew Poly at addr %x\n", MonoPolys );
	fprintf( stderr, "PlanarX = %d\nPlanarY = %d\n", PlanarX, PlanarY );
	for( i = 0; i < NumVerts; i++ ) {
		x = MonoPolys[i].Vertex->coord[PlanarX];
		y = MonoPolys[i].Vertex->coord[PlanarY];
		fprintf( stderr, "Vertex %x at ( %f, %f ) with side = %d\n", MonoPolys[i].Vertex, x, y,
			MonoPolys[i].Side );
	}

} /* PrintMonoPoly */

#endif

/*
 * Adjacent() determines if two vertices of a monotonic polygon share an edge. It returns TRUE or FALSE.
 *
 * HISTORY: 2/6/90	Created.
 *								Trevor Mink
 */

static int Adjacent( Lower, Upper )
	struct EDGEIIvertex *Lower, *Upper; {

	int i, Cardinality;

	Cardinality = Upper->OutCardinality;
	for( i = 0; i < Cardinality; i++ ) {
		/* Does the 'Upper' have an outgoing edge which connects to 'Lower' */
		if( Upper->Out[i]->Bottom == Lower ) return( TRUE );
	}
	return( FALSE );

} /* Adjacent */

static int ValidAngle( u, v1, v2, PlanarX, PlanarY, DistTol )
	struct PolygonVert *u, *v1, *v2;
	int PlanarX, PlanarY;
	double DistTol; {

	double A_x, A_y, B_x, B_y;
	double CrossProduct;

	A_x = v1->Vertex->coord[PlanarX] - u->Vertex->coord[PlanarX] + DistTol;
	A_y = v1->Vertex->coord[PlanarY] - u->Vertex->coord[PlanarY];
	B_x = v2->Vertex->coord[PlanarX] - v1->Vertex->coord[PlanarX];
	B_y = v2->Vertex->coord[PlanarY] - v1->Vertex->coord[PlanarY];

	if( v1->Side == LEFT_SIDE ) {
		A_x = - A_x;
		A_y = - A_y;
	}
	CrossProduct = A_x * B_y - B_x * A_y;

	if( CrossProduct > 0.0 ) return( FALSE );
	else return( TRUE );

} /* ValidAngle */

static EGTriMeshData3Info TriMesh;

void EGTriMeshData_debug( vcNo, Triangles )
	int vcNo;
	EGTriMeshData3Info *Triangles; {

	int i, FacetNormals;

#if DEBUG
	fprintf( stderr, "Here comes a mesh of length %d\n", Triangles->numVerts );
	FacetNormals = ( ( Triangles->fNormOffset ) ? Triangles->numVerts - 2 : 1 );
	for( i = 0; i < FacetNormals; i++ ) {
		fprintf( stderr, "Facet Normal # %d = (%f, %f, %f)\n", i,
			Triangles->fNorms[i].x, Triangles->fNorms[i].y, Triangles->fNorms[i].z );
	}
	for( i = 0; i < Triangles->numVerts; i++ ) {
		fprintf( stderr, "Vertex = (%f, %f, %f)\t",
			Triangles->verts[i].x, Triangles->verts[i].y, Triangles->verts[i].z );
		if( element_parms.facet_type == SMOOTH_SHADE )
			fprintf( stderr, "Vertex Normal = (%f, %f, %f)\n",
				Triangles->vNorms[i].x, Triangles->vNorms[i].y, Triangles->vNorms[i].z );
	}
#endif

	EGTriMeshData3( vcNo, Triangles );

} /* EGTriMeshData */

/*
 * AddDiagonal() adds a diagonal from 'u' to 'v1'. 'v2' is required to check whether the current mesh
 * can be continued with the next vertex.
 *
 * HISTORY: 2/16/90	Created.
 *								Trevor Mink
 */

static void AddDiagonal( vcNo, u, v1, v2, PlanarX, PlanarY )
	int vcNo;
	struct PolygonVert *u, *v1, *v2;
	int PlanarX, PlanarY; {

	int x, y, k;

#if DRAWING
	x = u->Vertex->coord[PlanarX];
	y = u->Vertex->coord[PlanarY];
	move( vcNo, x, y );
	x = v1->Vertex->coord[PlanarX];
	y = v1->Vertex->coord[PlanarY];
	draw( vcNo, x, y );
#endif

#if DEBUG
/*	fprintf( stderr, "u = %x\tv1 = %x\tv2 = %x\n", u, v1, v2 );
	fprintf( stderr, "u->VertNo = %d\tv1->VertNo = %d\tv2->VertNo = %d\tVertNum = %d\n",
		u->VertNo, v1->VertNo, v2->VertNo, VertNum );
*/
#endif
	/* If current vertex 'u' will numerically fit as vertex 'VertNum' add it as such */
	if( ( v1->VertNo == VertNum - 1 && v2->VertNo == VertNum - 2 ) ||
		( v2->VertNo == VertNum - 1 && v1->VertNo == VertNum - 2 ) ) {

		TriMesh.verts[VertNum-1].x = u->Vertex->coord[0];
		TriMesh.verts[VertNum-1].y = u->Vertex->coord[1];
		TriMesh.verts[VertNum-1].z = u->Vertex->coord[2];

		if( element_parms.facet_type == SMOOTH_SHADE ) {
			TriMesh.vNorms[VertNum-1].x = u->Vertex->norm[0];
			TriMesh.vNorms[VertNum-1].y = u->Vertex->norm[1];
			TriMesh.vNorms[VertNum-1].z = u->Vertex->norm[2];
#if SMOOTH_DEBUG
			fprintf( stderr, "u vertex normal: (%f, %f, %f)\n",
				u->Vertex->norm[0], u->Vertex->norm[1], u->Vertex->norm[2] );
#endif
		}
		u->VertNo = VertNum++;

	/* If current vertex 'v1' will numerically fit as vertex 'VertNum' add it as such */
	} else if( ( u->VertNo == VertNum - 1 && v2->VertNo == VertNum - 2 ) ||
			( v2->VertNo == VertNum - 1 && u->VertNo == VertNum - 2 ) ) {

		TriMesh.verts[VertNum-1].x = v1->Vertex->coord[0];
		TriMesh.verts[VertNum-1].y = v1->Vertex->coord[1];
		TriMesh.verts[VertNum-1].z = v1->Vertex->coord[2];

		if( element_parms.facet_type == SMOOTH_SHADE ) {
			TriMesh.vNorms[VertNum-1].x = v1->Vertex->norm[0];
			TriMesh.vNorms[VertNum-1].y = v1->Vertex->norm[1];
			TriMesh.vNorms[VertNum-1].z = v1->Vertex->norm[2];
#if SMOOTH_DEBUG
			fprintf( stderr, "u vertex normal: (%f, %f, %f)\n",
				u->Vertex->norm[0], u->Vertex->norm[1], u->Vertex->norm[2] );
#endif
		}
		v1->VertNo = VertNum++;
	} else {
		if( VertNum ) {
			TriMesh.numVerts = VertNum - 1;

			/* Send (or save) the current Triangular Mesh */
			(*active_window->process_mesh)( vcNo, &TriMesh );
#if DEBUG
/*			fprintf( stderr, "Mesh sent\n" );
*/
#endif
			for( k = 0; k <= Top; k++ )
				Stack[k]->VertNo = 0;
			NumTriMeshes++;
		}
		v2->VertNo = 1;
		v1->VertNo = 2;
		u->VertNo = 3;

		TriMesh.verts[0].x = v2->Vertex->coord[0];
		TriMesh.verts[0].y = v2->Vertex->coord[1];
		TriMesh.verts[0].z = v2->Vertex->coord[2];

		TriMesh.verts[1].x = v1->Vertex->coord[0];
		TriMesh.verts[1].y = v1->Vertex->coord[1];
		TriMesh.verts[1].z = v1->Vertex->coord[2];

		TriMesh.verts[2].x = u->Vertex->coord[0];
		TriMesh.verts[2].y = u->Vertex->coord[1];
		TriMesh.verts[2].z = u->Vertex->coord[2];

		if( element_parms.facet_type == SMOOTH_SHADE ) {
			TriMesh.vNorms[0].x = v2->Vertex->norm[0];
			TriMesh.vNorms[0].y = v2->Vertex->norm[1];
			TriMesh.vNorms[0].z = v2->Vertex->norm[2];
#if SMOOTH_DEBUG
			fprintf( stderr, "v2 vertex normal: (%f, %f, %f)\n",
				v2->Vertex->norm[0], v2->Vertex->norm[1], v2->Vertex->norm[2] );
#endif
			TriMesh.vNorms[1].x = v1->Vertex->norm[0];
			TriMesh.vNorms[1].y = v1->Vertex->norm[1];
			TriMesh.vNorms[1].z = v1->Vertex->norm[2];
#if SMOOTH_DEBUG
			fprintf( stderr, "v1 vertex normal: (%f, %f, %f)\n",
				v1->Vertex->norm[0], v1->Vertex->norm[1], v1->Vertex->norm[2] );
#endif
			TriMesh.vNorms[2].x = u->Vertex->norm[0];
			TriMesh.vNorms[2].y = u->Vertex->norm[1];
			TriMesh.vNorms[2].z = u->Vertex->norm[2];
#if SMOOTH_DEBUG
			fprintf( stderr, "u vertex normal: (%f, %f, %f)\n",
				u->Vertex->norm[0], u->Vertex->norm[1], u->Vertex->norm[2] );
#endif
		}
		TriMesh.fNorms[0].x = element_parms.facet_normal[0];
		TriMesh.fNorms[0].y = element_parms.facet_normal[1];
		TriMesh.fNorms[0].z = element_parms.facet_normal[2];
#if SMOOTH_DEBUG
		fprintf( stderr, "facet normal: (%f, %f, %f)\n",
			TriMesh.fNorms[0].x, TriMesh.fNorms[0].y, TriMesh.fNorms[0].z );
#endif
		VertNum = 4;
	}

#if DEBUG
/*	fprintf( stderr, "Diagonal added from (%lf, %lf) to (%lf, %lf)\n", u->Vertex->coord[PlanarX],
		u->Vertex->coord[PlanarY], v1->Vertex->coord[PlanarX], v1->Vertex->coord[PlanarY] );
	fprintf( stderr, "u->VertNo = %d\tv1->VertNo = %d\tv2->VertNo = %d\n",
		u->VertNo, v1->VertNo, v2->VertNo );
*/
#endif

} /* AddDiagonal */

/*
 * HStriangulate() takes a pointer to a linked list of local minima (for monotonic polygons) and
 * triangulates these.
 *
 * HISTORY: 2/6/90	Created.
 *								Trevor Mink
 */

int HStriangulate( Window_VC, LocalMins, NumVertices, PlanarX, PlanarY, DistTol, debug )
	int Window_VC;
	struct PolygonVert *LocalMins;
	int NumVertices;
	int PlanarX, PlanarY;
	double DistTol;
	int debug; {

	int i, k, NumVerts;
	int Cond1, Cond2;
	struct PolygonVert *u, *Min;
	int j, x, y;

	NumTriMeshes = 0;

	MonoPolys = (struct PolygonVert *)malloc( NumVertices * sizeof( struct PolygonVert ) );
	Stack = (struct PolygonVert **)malloc( NumVertices * sizeof( struct PolygonVert * ) );
	Top = -1;

	TriMesh.verts = (EGPoint3 *)malloc( NumVertices * sizeof( EGPoint3 ) );
	TriMesh.vertOffset = sizeof( EGPoint3 );
	TriMesh.fNorms = (EGVect3 *)malloc( sizeof( EGVect3 ) );
	if( element_parms.facet_type == SMOOTH_SHADE ) {
		TriMesh.vNorms = (EGVect3 *)malloc( NumVertices * sizeof( EGVect3 ) );
		TriMesh.vNormOffset = sizeof( EGVect3 );
	} else {
		TriMesh.vNormOffset = 0;
		TriMesh.vNorms = (EGVect3 *)NULL;
	}
	TriMesh.vColors = (EGRGBColor *)NULL;
	TriMesh.fColors = (EGRGBColor *)NULL;
	TriMesh.fNormOffset = 0;
	TriMesh.fColorOffset = 0;
	TriMesh.vColorOffset = 0;

	for( i = 0; i < NumVertices; i++ )
		MonoPolys[i].VertNo = 0;

	/* For all local minima */
	for( Min = LocalMins; Min; Min = Min->Next ) {
		/* Get the sorted vertices from the monotonic polygon that begins with 'Min->Vertex' */
		NumVerts = GetMonoPolygon( Min->Vertex, PlanarX, PlanarY, debug );
#if DEBUG
		if( debug )
			PrintMonoPoly( NumVerts, PlanarX, PlanarY );
#endif
		if( NumVerts < 3 ) continue; /* Get next monotonic polygon, don't process this one */
		/* Begin actual triangulation algorithm on polygon 'MonoPolys' */
		Stack[0] = &MonoPolys[0];
		Stack[1] = &MonoPolys[1];
		Top += 2;

		/* for all vertices of monotonic polygon */
		for( k = 2; k < NumVerts; k++ ) {
			u = &MonoPolys[k];
			MonoPolys[k].VertNo = 0;
			Cond1 = Adjacent( u->Vertex, Stack[0]->Vertex );
			Cond2 = Adjacent( u->Vertex, Stack[Top]->Vertex );
#if DEBUG
/*			fprintf( stderr, "Cond1 = %d\tCond2 = %d\tTop = %d\n", Cond1, Cond2, Top );
*/
#endif
			if( Cond1 && !Cond2 ) {
				for( i = 1; i <= Top; i++ ) {
					AddDiagonal( Window_VC, u, Stack[i], Stack[i-1], PlanarX, PlanarY );
				}
				Stack[0] = Stack[Top];
				Stack[1] = u;
				Top = 1;
			} else if( Cond2 && !Cond1 ) {
				while( Top > 0 &&
					ValidAngle( u, Stack[Top], Stack[Top-1], PlanarX, PlanarY,
						DistTol )) {
					AddDiagonal( Window_VC, u, Stack[Top-1], Stack[Top],
						PlanarX, PlanarY );
					Top--;
				}
				Stack[++Top] = &MonoPolys[k];
#if DEBUG
				if( debug )
				for( j = 0; j <= Top; j++ ) {
					x = Stack[j]->Vertex->coord[PlanarX];
					y = Stack[j]->Vertex->coord[PlanarY];
					fprintf( stderr, "Stack[%d] = ( %d, %d )\n", j, x, y );
				}
#endif
			} else { /* both 'Cond1' and 'Cond2' hold */
				for( i = 1; i <= Top; i++ ) {
					AddDiagonal( Window_VC, u, Stack[i], Stack[i-1],
						PlanarX, PlanarY );
				}

				Top = -1;
			}
		}
		TriMesh.numVerts = VertNum - 1;
		/* Either save the mesh (View Dyn.) or send it to the edgeII board to display */
		(*active_window->process_mesh)( Window_VC, &TriMesh );
#if DEBUG
/*		fprintf( stderr, "Mesh sent\n" ); */
#endif
/*
		if( tiling_parms.feedback_mode )
			HSsave_TriMesh( Window_VC, &TriMesh );
		else
*/
/*			EGTriMeshData3( Window_VC, &TriMesh );*/ /* Send the current Triangular Mesh */

		for( k = 0; k <= Top; k++ )
			Stack[k]->VertNo = 0;
		NumTriMeshes++;
		VertNum = 0;
	}
	if( element_parms.facet_type == SMOOTH_SHADE )
		free( TriMesh.vNorms );

	free( TriMesh.fNorms );
	free( TriMesh.verts );

	free( MonoPolys );
	free( Stack );

	return( NumTriMeshes );

} /* HStriangulate */
