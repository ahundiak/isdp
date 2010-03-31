
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:34 $
$Locker:  $
*/

#include "igrtypedef.h"
#include "HStl_element.h"
#include "HSe2_mesher.h"
#include "hsurf_import.h"
#include "hsmath.h"
#include "hstiler.h"
#include <stdio.h>

static int PlanarX, PlanarY;

#define DEBUG		0
#define TRIMESH_DEBUG	0

/*
 * HSprocess_edgeII_facet() takes the current 'Facet' and sends it through the Polygon Mesher
 * to be Regularized and Triangulated. It also returns the number of triangular meshes
 * for the given facet.
 *
 * HISTORY: 1/26/90	Created.
 *								Trevor Mink
 */

int HSprocess_edgeII_facet( Facet, TotalVertices, w_no, Plan_x, Plan_y )
	struct EDGEII_loop 	*Facet;
	int 			TotalVertices;
	int 			w_no;
	int 			Plan_x, Plan_y;
	
	{
	static int NumTriMeshes = 0;

	struct EDGEII_loop *Loop;
	struct EDGEIIvertex *Start, *Vertex;

	if( TotalVertices < 3 ) return( 0 );

#if TRIMESH_DEBUG
	fprintf( stderr, "element_parms.facet_normal = (%lf, %lf, %lf)\n", FABS(element_parms.facet_normal[0]),
		FABS(element_parms.facet_normal[1]), FABS(element_parms.facet_normal[2]) );
#endif
	PlanarX = Plan_x;
	PlanarY = Plan_y;

	for( Loop = Facet; Loop; Loop = Loop->next ) {
		if( Loop->Vertices >= 3 )
		{
			Start = Vertex = (struct EDGEIIvertex *)(Loop->loop);
			do {
				if (Vertex->next == Start)
					if (Loop->next)
						make_triangles( Vertex->coord[0], Vertex->coord[1], Vertex->coord[2],
							Vertex->coord[3], Vertex->norm[0], Vertex->norm[1],
							Vertex->norm[2], 0, 0, 1, PlanarX, PlanarY );
					else {
						make_triangles( Vertex->coord[0], Vertex->coord[1], Vertex->coord[2],
							Vertex->coord[3], Vertex->norm[0], Vertex->norm[1],
							Vertex->norm[2], 0, 0, 0, PlanarX, PlanarY );
						make_triangles( 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
								0, 0, 2, PlanarX, PlanarY );
					}
				else
					make_triangles( Vertex->coord[0], Vertex->coord[1], Vertex->coord[2],
						Vertex->coord[3], Vertex->norm[0], Vertex->norm[1],
						Vertex->norm[2], 0, 0, 0, PlanarX, PlanarY );
				Vertex = Vertex->next;
			} while( Vertex != Start );
		}
		/* If this is the last loop of multiple loops, send a facet break */
		else if( !Loop->next && Loop != Facet )
			make_triangles( 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
				0, 0, 2, PlanarX, PlanarY );
	}
	NumTriMeshes = 1;

	return( NumTriMeshes );

	} /* HSprocess_edgeII_facet */
