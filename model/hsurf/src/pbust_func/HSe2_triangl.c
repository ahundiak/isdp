#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "dp.h"
#include "dpstruct.h"

#include "hstiler.h"
#include "hslight.h"
#include "hsdisplay.h"

#include "HStl_global.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HSfem_spt.h"
#include "HSd_fixedpt.h"
#include "HSe2_mesher.h"

#include "HSpr_pbust_f.h"

/*------------------------------
 *  for function
 *     HSsave_TriMesh
 */
 
#include "HSpr_driver.h"

/*--------------------------------*/



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


/* HSe2_triangl.c */
static int HSgetNextSide __((int PlanarX, 
			     int PlanarY, 
			     int debug));
			     
static int HSgetMonoPolygon __((struct HStri_vertex *LocalMin, 
						int PlanarX, 
						int PlanarY,
						 int debug));

#if DEBUG						 
static void HSprintMonoPoly __((int NumVerts,
			        int PlanarX, 
			        int PlanarY));
#endif
			        
static void HSclearMonoEdges __((int NumVerts));

static int HSadjacent __((struct HStri_vertex *Lower, 
			  struct HStri_vertex *Upper));
			  
static int HSvalidAngle __((struct PolygonVert *u, 
			    struct PolygonVert *v1, 
			    struct PolygonVert *v2, 
					   int PlanarX, 
					   int PlanarY, 
					double DistTol));
					
static void HSaddDiagonal __((int vcNo, 
	       struct PolygonVert *u, 
	       struct PolygonVert *v1, 
	       struct PolygonVert *v2, 
			      int PlanarX, 
			      int PlanarY));
			      
static HSalloc_trimesh __((int NumVertices));
static void HSalloc_MonoPolys_and_Stack __((int NumVertices));




#if defined(__cplusplus)
}
#endif


#undef __


#define NEITHER_SIDE	0
#define LEFT_SIDE	1
#define RIGHT_SIDE	2

static struct HStri_mesh TriMesh;
static struct HStri_point *vNorms = NULL;
static int MaxVerts = 0;


static struct Edge *Left, *Right;
static struct PolygonVert *MonoPolys;
static struct PolygonVert **Stack;
static int NumTriMeshes;
static int MonoPolysSize = 0;
static int Top = -1;

#define DEBUG		0
#define CONST_DEBUG	0
#define SMOOTH_DEBUG	0
#define DRAWING		0

					

/*--- HSgetNextSide() -----------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static int HSgetNextSide( int PlanarX, int PlanarY, int debug )
#else
	static int HSgetNextSide( PlanarX, PlanarY, debug )
	int PlanarX, PlanarY;
	int debug;
#endif

/*
NAME
	HSgetNextSide (static)

DESCRIPTION
	This function  resets the 'Left' or 'Right' static edge pointer to aid
	in merging of the two monotonic chains of the current polygon.

KEYWORD
	triangulator

PARAMETERS
	LocalMin (IN) - The top vertex in the monotonic polygon.
	PlanarX,PlanarY (IN) - Indices (0-2) of the 3d coordinates to use for 2d triangulation.
	debug (IN) - Flag indicating whether to execute 'DEBUG' code.

GLOBALS USED
	MonoPolys - Used to build the monotonic polygon.
	Left,Right - Two edges that comprise the current interval on the active edge list.

RETURN VALUES
	Returns	the side (RIGHT_SIDE or LEFT_SIDE) which contains the next vertex to be
	merged into the sorted array.
	NEITHER_SIDE means the 'Left' and 'Right' edges have met.

HISTORY
	02/05/90 Created. -Trevor Mink
	02/12/92 Mark each edge of the mono polygon as 'LIVE_EDGE'. -Trevor Mink
*/
{
	int RightMost;
	struct HStri_vertex *v;
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
		/* Turn on the old Left edge. */
		Left->EdgeStatus |= LIVE_EDGE;
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
		Right->EdgeStatus |= LIVE_EDGE;
		Right = v->Out[0];
#if DEBUG
		if( debug )
			fprintf( stderr, "v(Right->Bottom) = %x\tRight = %x\n", v, Right );
#endif
		return( RIGHT_SIDE );
	}

} /* HSgetNextSide */

static int VertNum = 0;

/*--- HSgetMonoPolygon() -----------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static int HSgetMonoPolygon( struct HStri_vertex *LocalMin,
						     int PlanarX, 
						     int PlanarY,
						     int debug )
#else
	static int HSgetMonoPolygon( LocalMin, PlanarX, PlanarY, debug )
	
	struct HStri_vertex *LocalMin;
	int PlanarX, PlanarY;
	int debug;
#endif
/*
NAME
	HSgetMonoPolygon (static)

DESCRIPTION
	This function places the monotonic polygon beginning at the given 'LocalMin'
	into a linked list structure specifically designed for monotonic polygons and
	their triangulation.

KEYWORD
	triangulator

PARAMETERS
	LocalMin (IN) - The top vertex in the monotonic polygon.
	PlanarX,PlanarY (IN) - Indices (0-2) of the 3d coordinates to use for 2d triangulation.
	debug (IN) - Flag indicating whether to execute 'DEBUG' code.

GLOBALS USED
	MonoPolys - Used to build the monotonic polygon.

RETURN VALUES
	The number of vertices in the monotonic polygon.

HISTORY
	02/05/90 Created. -Trevor Mink
*/
{
	int NumVerts = 0, MinSide = LEFT_SIDE; /* Either side is okay to begin with */
	int left, right;
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
                                if( EdgeSet[left] == NULL || EdgeSet[right] == NULL ) return 0;
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
if( !Left ) return( 0 );
if( !Right ) return( 0 );

		if( MinSide == LEFT_SIDE )
			MonoPolys[NumVerts].Vertex = Left->Top;
		else
			MonoPolys[NumVerts].Vertex = Right->Top;
		NumVerts++;
if( NumVerts > MonoPolysSize ) return( 0 );
#if DEBUG
		if( debug ) {
			PrintMonoPoly( NumVerts, PlanarX, PlanarY );
			/* Change 'Left' or 'Right' and return which side has lesser 'Bottom' vertex */
			MinSide = HSgetNextSide( PlanarX, PlanarY, 1 );
		} else
			/* Change 'Left' or 'Right' and return which side has lesser 'Bottom' vertex */
			MinSide = HSgetNextSide( PlanarX, PlanarY, 0 );
#else
		/* Change 'Left' or 'Right' and return which side has lesser 'Bottom' vertex */
		MinSide = HSgetNextSide( PlanarX, PlanarY, 0 );
#endif
	} while( MinSide != NEITHER_SIDE );

	/* Now, place the local maximum vertex at the end of the linked list */

	MonoPolys[NumVerts].Side = MinSide;
	MonoPolys[NumVerts].Vertex = Left->Bottom;	/* or 'Right->Bottom' */
	NumVerts++;
	return( NumVerts );

} /* HSgetMonoPolygon */

#if DEBUG

/*--- HSprintMonoPoly -----------------------------------------------------------------------*/

static void HSprintMonoPoly( NumVerts, PlanarX, PlanarY )
	int NumVerts;
	int PlanarX, PlanarY;
/*
NAME
	HSprintMonoPoly (static)

DESCRIPTION
	This function prints out the current monotonic polygon stored in 'MonoPolys'

KEYWORD
	triangulator

PARAMETERS
	NumVerts (IN) - The number of vertices in the monotonic polygon.
	PlanarX,PlanarY (IN) - Indices (0-2) of the 3d coordinates to use for 2d triangulation.

GLOBALS USED
	MonoPolys (static) - Stores the monotonic polygon.

RETURN VALUES
	none

HISTORY
	02/05/90 Created. -Trevor Mink
*/
{
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

} /* HSprintMonoPoly */
#endif

/*--- HSclearMonoEdges -------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HSclearMonoEdges( int NumVerts )
#else
	static void HSclearMonoEdges( NumVerts )
	int NumVerts;
#endif

/*
NAME
	HSclearMonoEdges (static)

KEYWORD
	triangulator

DESCRIPTION
	This function unmarks all of edges which are members of the out
	set of all vertices in the monotonic polygon just created. This
	assures that all edges will be unmarked prior to marking of the
	next monotonic polygon.

PARAMETERS
	NumVerts (IN) - Number of vertices in the monotonic polygon.

GLOBALS USED
	MonoPolys - Array containing pointers to all vertices of the current
	monotonic polygon.

RETURN VALUES
	none.

HISTORY
	02/12/92 Created. -Trevor Mink
*/
{
	int i, j, Cardinality;
	struct HStri_vertex *Vertex;

	for( i = 0; i < NumVerts; i++ )
	{
		Vertex = MonoPolys[i].Vertex;
		Cardinality = Vertex->OutCardinality;
		for( j = 0; j < Cardinality; j++ )
		{
			/* Zero out 'LIVE_EDGE' bit */
			Vertex->Out[j]->EdgeStatus &= ~LIVE_EDGE;
		}
	}

} /* HSclearMonoEdges */

/*--- HSadjacent() ---------------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static int HSadjacent( struct HStri_vertex *Lower, 
			       struct HStri_vertex *Upper )
#else
	static int HSadjacent( Lower, Upper )
	struct HStri_vertex *Lower, *Upper;
#endif

/*
NAME
	HSadjacent (static)

DESCRIPTION
	This function determines if two vertices of a monotonic polygon share an edge.

KEYWORD
	triangulator

PARAMETERS
	Lower,Upper (IN) - The two vertices to be tested for adjacency.

GLOBALS USED
	None.

RETURN VALUES
	TRUE (non-zero)	Indicates the vertices are adjacent
	FALSE (zero)	Vertices are not adjacent

HISTORY:
	02/06/90 Created. -Trevor Mink
	02/12/92 Check for 'LIVE_EDGE' to assure it's on the polygon. -Trevor Mink
*/
{
	int i, Cardinality;

	Cardinality = Upper->OutCardinality;
	for( i = 0; i < Cardinality; i++ ) {
		/* Does the 'Upper' have an outgoing edge which connects to 'Lower' */
		/* AND, is the edge marked as being on the monotonic polygon? */
		if( (Upper->Out[i]->Bottom == Lower) &&
			(Upper->Out[i]->EdgeStatus & LIVE_EDGE) )
			return( TRUE );
	}
	return( FALSE );

} /* HSadjacent */

/*--- HSvalidAngle -----------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static int HSvalidAngle( struct PolygonVert *u, 
				 struct PolygonVert *v1, 
				 struct PolygonVert *v2,
						int PlanarX, 
						int PlanarY,
					     double DistTol )
#else
	static int HSvalidAngle( u, v1, v2, PlanarX, PlanarY, DistTol )
	
	struct PolygonVert *u, *v1, *v2;
	int PlanarX, PlanarY;
	double DistTol;
#endif

/*
NAME
	HSvalidAngle (static)

DESCRIPTION
	This function determines if the angle between the three vertices of the monotonic
	polygon form an angle valid for adding to the current triangular mesh.

KEYWORD
	triangulator

PARAMETERS
	u, v1, u2 (IN) - The three vertices.
	PlanarX,PlanarY (IN) - Indices (0-2) of the 3d coordinates to use for 2d triangulation.
	DistTol (IN) - EMS Distance Tolerance

GLOBALS USED
	none.

RETURN VALUES
	Flag indicating whether or not the angle is valid.

HISTORY
	02/05/90 Created. -Trevor Mink
*/
{
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

} /* HSvalidAngle */

/*--- HSaddDiagonal() -----------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HSaddDiagonal( int vcNo, 
		    struct PolygonVert *u, 
		    struct PolygonVert *v1, 
		    struct PolygonVert *v2, 
				   int PlanarX, 
				   int PlanarY )
#else
	static void HSaddDiagonal( vcNo, u, v1, v2, PlanarX, PlanarY )
	int vcNo;
	struct PolygonVert *u, *v1, *v2;
	int PlanarX, PlanarY;
#endif

/*
NAME
	HSaddDiagonal (static)

DESCRIPTION
	This function adds a diagonal from 'u' to 'v1'. 'v2' is required to check whether
	the current mesh can be continued with the next vertex.

KEYWORD
	triangulator

PARAMETERS
	vcNo (IN) - Viewing context (Required to make and EG call to display mesh).
	u, v1 (IN) - The two vertices which, with the previous vertex, will form the next
	triangle.
	u2 (IN) - Used to determine if the current mesh can be continued with the next vertex.
	PlanarX,PlanarY (IN) - Indices (0-2) of the 3d coordinates to use for 2d triangulation.

GLOBALS USED
	TriMesh (static) - Hold the triangular mesh structure to send to EG.

RETURN VALUES
	none.

HISTORY
	02/16/90 Created. -Trevor Mink
*/
{
	int k;

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

} /* HSaddDiagonal */

#define NUM_VERTS_IN_8K		(8192 / sizeof( struct HStri_point ))

/* #define NUM_VERTS_IN_56K	(57344 / sizeof( struct HStri_point )) */
#define NUM_VERTS_IN_56K	4778

/*--- HSalloc_trimesh --------------------------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static HSalloc_trimesh( int NumVertices )
#else
	static HSalloc_trimesh( NumVertices )
	int NumVertices;
#endif

/*
NAME
	HSalloc_trimesh

DESCRIPTION
	This function returns sufficient memory for vertices and facet normal(s), as well as
	vertex normals (if smooth shading) for the static 'TriMesh'.

KEYWORD
	triangulator

PARAMETERS
	NumVertices (IN) - Number of vertices in the monotonic polygon. Hence, maximum
	size of a triangular mesh for the mono polygon.

GLOBALS USED
	TriMesh (static) - Holds the triangular mesh structure to send to EG.

RETURN VALUES
	TRUE - If able to alloc everything.
	FALSE - If some alloc failed.

HISTORY
	08/29/91 Created.
*/
{
	int NumChunks;

	if( NumVertices < NUM_VERTS_IN_8K ) NumVertices = NUM_VERTS_IN_8K;

	if( MaxVerts == 0 )
	{
		TriMesh.verts = (struct HStri_point *)malloc( NumVertices * sizeof( struct HStri_point ) );
		TriMesh.fNorms = (struct HStri_point *)malloc( sizeof( struct HStri_point ) );
		vNorms = (struct HStri_point *)malloc( NumVertices * sizeof( struct HStri_point ) );

		TriMesh.vColors = NULL;
		TriMesh.fColors = NULL;
		if( !vNorms || !TriMesh.verts ) return( FALSE );
		MaxVerts = NumVertices;
	}
	else if( NumVertices > MaxVerts )
	{
		NumChunks = NumVertices / NUM_VERTS_IN_8K;
		NumVertices = (NumChunks+1) * NUM_VERTS_IN_8K;
		free( (char *)TriMesh.verts );
		free( (char *)vNorms );
		TriMesh.verts = (struct HStri_point *)malloc( NumVertices * sizeof( struct HStri_point ) );
		vNorms = (struct HStri_point *)malloc( NumVertices * sizeof( struct HStri_point ) );
		if( !vNorms || !TriMesh.verts ) return( FALSE );
		MaxVerts = NumVertices;
	}

        TriMesh.numFacetNormals = 1;

	if( element_parms.facet_type == SMOOTH_SHADE )
	{
		TriMesh.vNorms = vNorms;
	}
	else
	{
		TriMesh.vNorms = NULL;
	}

	return( TRUE );

} /* HSalloc_trimesh */

static struct PolygonVert *PolyArray_static = (struct PolygonVert *)NULL;
static struct PolygonVert **PolyStack_static = (struct PolygonVert **)NULL;

/*--- HSalloc_MonoPolys_and_Stack ------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HSalloc_MonoPolys_and_Stack( int NumVertices )
#else
	static void HSalloc_MonoPolys_and_Stack( NumVertices )
	int NumVertices;
#endif

/*
NAME
	HSalloc_MonoPolys_and_Stack (static)

DESCRIPTION
	This function returns sufficient memory for the 'MonoPolys' and 'Stack'
	static variables.

KEYWORD
	triangulator

PARAMETERS
	NumVertices (IN) - Number of vertices in the entire facet (Overkill, but safe).

GLOBALS USED
	PolyArray_static (static) - Holds 1024 PolygonVert structures (Will handle most cases).
	PolyStack_static (static) - Holds Pointers to 1024 PolygonVert structures (Handles most cases).
	MonoPolys (static) - Used to build the monotonic polygon. Memory is assigned here.
	Stack (static) - Used in the triangulation of the monotonic polygon. Memory is assigned here.

RETURN VALUES
	Return value contains an inaccurate count of the number of tri meshes.

HISTORY
	08/29/91 Created. -Trevor Mink
*/
{
	if( !PolyArray_static )
		PolyArray_static = (struct PolygonVert *)malloc( ONE_K * sizeof( struct PolygonVert ) );

	if( !PolyStack_static )
		PolyStack_static = (struct PolygonVert **)malloc( ONE_K * sizeof( struct PolygonVert *) );

	if( NumVertices > ONE_K )
	{
		MonoPolys = (struct PolygonVert *)malloc( NumVertices * sizeof( struct PolygonVert ) );
		Stack = (struct PolygonVert **)malloc( NumVertices * sizeof( struct PolygonVert *) );
	}
	else
	{
		MonoPolys = PolyArray_static;
		Stack = PolyStack_static;
	}
MonoPolysSize = NumVertices;

} /* HSalloc_MonoPolys_and_Stack */

#define   FREE_MONOPOLYS_AND_STACK  \
                                    \
if( NumVertices > ONE_K )           \
   {                                \
   free( (char *)MonoPolys );               \
   free( (char *)Stack );                   \
   }

/*--- HStriangulate() ----------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	int HStriangulate(	int Window_VC,
		 struct PolygonVert *LocalMins,
				int NumVertices,
				int PlanarX, 
				int PlanarY,
			     double DistTol,
				int debug )
#else
	int HStriangulate( Window_VC, LocalMins, NumVertices, PlanarX, PlanarY, DistTol, debug )
	
	int Window_VC;
	struct PolygonVert *LocalMins;
	int NumVertices;
	int PlanarX, PlanarY;
	double DistTol;
	int debug;
#endif

/*
NAME
	HStriangulate

DESCRIPTION
	This function takes a pointer to a linked list of local minima (for monotonic
	polygons) and triangulates these.

KEYWORD
	triangulator

PARAMETERS
	Window_VC (IN) - Viewing context (Required to make and EG call to display mesh).
	LocalMins (IN) - Linked list of what will be top vertices of the monotonic polygons.
	NumVertices (IN) - Number of vertices in the entire facet.
	PlanarX,PlanarY (IN) - Indices (0-2) of the 3d coordinates to use for 2d triangulation.
	DistTol (IN) - EMS Distance Tolerance (Passed to HSvalidAngle and used there).
	debug (IN) - Flag indicating whether to execute DEBUG code.

GLOBALS USED
	TriMesh (static) - Hold the triangular mesh structure to send to EG.
	MonoPolys (static) - Used to build the monotonic polygon.
	Stack (static) - Used in the triangulation of the monotonic polygon.

RETURN VALUES
	Return value contains an inaccurate count of the number of tri meshes.

HISTORY
	02/06/90 Created. -Trevor Mink
*/
{
	int i, k, NumVerts;
	int Cond1, Cond2;
	struct PolygonVert *u, *Min;
#if DEBUG
	int j, x, y;
#endif
	NumTriMeshes = 0;

	HSalloc_MonoPolys_and_Stack( NumVertices );

	Top = -1;

	for( i = 0; i < NumVertices; i++ )
		MonoPolys[i].VertNo = 0;

	/* For all local minima */
	for( Min = LocalMins; Min; Min = Min->Next ) {
		/* Get the sorted vertices from the monotonic polygon that begins with 'Min->Vertex' */

		NumVerts = HSgetMonoPolygon( Min->Vertex, PlanarX, PlanarY, debug );
                if( NumVerts == 0 )
                   {
                   FREE_MONOPOLYS_AND_STACK
                   HSset_status( HSSTAT_BOUND_ERROR );
                   return( FALSE );
                   }

		if( !HSalloc_trimesh( NumVerts ) )
		   {
		   FREE_MONOPOLYS_AND_STACK
                   return( FALSE );
                   }
		
#               if DEBUG
		if( debug )
			HSprintMonoPoly( NumVerts, PlanarX, PlanarY );
#               endif

		if( NumVerts < 3 ) continue; /* Get next monotonic polygon, don't process this one */
		/* Begin actual triangulation algorithm on polygon 'MonoPolys' */
		Stack[0] = &MonoPolys[0];
		Stack[1] = &MonoPolys[1];
		Top += 2;

		/* for all vertices of monotonic polygon */
		for( k = 2; k < NumVerts; k++ ) {
			u = &MonoPolys[k];
			MonoPolys[k].VertNo = 0;
			Cond1 = HSadjacent( u->Vertex, Stack[0]->Vertex );
			Cond2 = HSadjacent( u->Vertex, Stack[Top]->Vertex );
#if DEBUG
/*			fprintf( stderr, "Cond1 = %d\tCond2 = %d\tTop = %d\n", Cond1, Cond2, Top );
*/
#endif
			if( Cond1 && !Cond2 ) {
				for( i = 1; i <= Top; i++ ) {
					HSaddDiagonal( Window_VC, u, Stack[i], Stack[i-1], PlanarX, PlanarY );
				}
				Stack[0] = Stack[Top];
				Stack[1] = u;
				Top = 1;
			} else if( Cond2 && !Cond1 ) {
				while( Top > 0 &&
					HSvalidAngle( u, Stack[Top], Stack[Top-1], PlanarX, PlanarY,
						DistTol )) {
					HSaddDiagonal( Window_VC, u, Stack[Top-1], Stack[Top],
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
					HSaddDiagonal( Window_VC, u, Stack[i], Stack[i-1],
						PlanarX, PlanarY );
				}

				Top = -1;
				break; /* If we have vertices left, it's a bad polygon. */
			}
		}
		TriMesh.numVerts = VertNum - 1;
		/* Either save the mesh (View Dyn.) or send it to the edgeII board to display */
		(*active_window->process_mesh)( Window_VC, &TriMesh );

		for( k = 0; k <= Top; k++ )
			Stack[k]->VertNo = 0;
		NumTriMeshes++;
		VertNum = 0;

		/* Kill the 'Live edges' of the current monotonic polygon */
		HSclearMonoEdges( NumVerts );
	}

	FREE_MONOPOLYS_AND_STACK
	return( NumTriMeshes );

} /* HStriangulate */
