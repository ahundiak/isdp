
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:40 $
$Locker:  $
*/

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
#include "hsmath.h"

#include "HStl_window.h"
#include "HStl_element.h"
#include "HSfem_spt.h"
#include "HSd_fixedpt.h"
#include "HSe2_mesher.h"

#include "HSpr_pbust_f.h"


#define MAX_TRIMESH_VERTICES	100

static int	numVerts = 0;
static struct HStri_point verts[MAX_TRIMESH_VERTICES];
static struct HStri_point vNorms[MAX_TRIMESH_VERTICES];
static struct HStri_point fNorms[MAX_TRIMESH_VERTICES - 2];


/*-----HSdisplay_trimesh------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSdisplay_buffered_trimesh(void)
#else
	void HSdisplay_buffered_trimesh()
#endif

/*
NAME
	HSdisplay_buffered_trimesh

DESCRIPTION
	This function displays the current trimesh and then resets the arrays.

KEYWORD
	triangulator

PARAMETERS
	none

GLOBALS USED
	triMesh (static) - Holds the triangular mesh structure to send to EG.
	numVerts (static) - Number of vertices in the current mesh.

RETURN VALUES
	none.

HISTORY
	03/28/90 Created. -C. M. Jablonski
*/
{
struct HStri_mesh triMesh;

	/* display the trimesh */
	if (numVerts > 2)
		{
		/* format the trimesh data */
		triMesh.numVerts = numVerts;
		triMesh.verts = verts;
		triMesh.vColors = NULL;
		if (element_parms.facet_type == SMOOTH_SHADE)
			{
			triMesh.vNorms = vNorms;
			}
		else
			{
			triMesh.vNorms = NULL;
			}

		triMesh.fColors = NULL;
		triMesh.fNorms = fNorms;
                triMesh.numFacetNormals = numVerts - 2;

		/* process the trimesh */
		(*active_window->process_mesh)( active_window->EG_vc_no, &triMesh );
		}

	/* reset the vertex count */
	numVerts = 0;
}

/*-----HSadd_vertex_to_buffered_trimesh------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSadd_vertex_to_buffered_trimesh( IGRpoint point, 
					       IGRpoint vnorm, 
					       IGRpoint fnorm)
#else
	void HSadd_vertex_to_buffered_trimesh( point, vnorm, fnorm)
	IGRpoint	point, vnorm, fnorm;
#endif

/*
NAME
	HSadd_vertex_to_buffered_trimesh

DESCRIPTION
	This function adds the given vertex to the current trimesh. If the number
	of vertices has reached its limit, the trimesh is displayed and the arrays
	are re-initialized with the last two points.

KEYWORD
	triangulator

PARAMETERS
	point (IN) - x,y,z of next vertex to add to the trimesh.
	vnorm (IN) - Normal of next vertex to add to the trimesh.
	fnorm (IN) - Normal of triangle created by this and the two previous vertices.

GLOBALS USED
	verts (static) - Vertices of current trimesh.
	vNorms (static) - Vertex normals of current trimesh.
	fNorms (static) - Facet normals of current trimesh.
	numVerts (static) - Number of vertices in the current mesh.

RETURN VALUES
	none.

HISTORY
	03/28/90 Created. -C. M. Jablonski
*/
{
IGRpoint	tmp_pt1, tmp_pt2, tmp_vn1, tmp_vn2;

	/* check for overflow */
	if (numVerts == MAX_TRIMESH_VERTICES)
		{
		/* save the last two vertices */
		tmp_pt1[0] = verts[numVerts - 2].x;
		tmp_pt1[1] = verts[numVerts - 2].y;
		tmp_pt1[2] = verts[numVerts - 2].z;
		tmp_vn1[0] = vNorms[numVerts - 2].x;
		tmp_vn1[1] = vNorms[numVerts - 2].y;
		tmp_vn1[2] = vNorms[numVerts - 2].z;

		tmp_pt2[0] = verts[numVerts - 1].x;
		tmp_pt2[1] = verts[numVerts - 1].y;
		tmp_pt2[2] = verts[numVerts - 1].z;
		tmp_vn2[0] = vNorms[numVerts - 1].x;
		tmp_vn2[1] = vNorms[numVerts - 1].y;
		tmp_vn2[2] = vNorms[numVerts - 1].z;

		/* display the trimesh */
		HSdisplay_buffered_trimesh();

		/* define the first two vertices */
		HSadd_vertex_to_buffered_trimesh( tmp_pt1, tmp_vn1, (IGRdouble *)NULL );
		HSadd_vertex_to_buffered_trimesh( tmp_pt2, tmp_vn2, (IGRdouble *)NULL );
		}

	/* set the point */
	verts[numVerts].x = point[0];
	verts[numVerts].y = point[1];
	verts[numVerts].z = point[2];

	/* set the vertex normal */
	if (vnorm)
		{
		vNorms[numVerts].x = vnorm[0];
		vNorms[numVerts].y = vnorm[1];
		vNorms[numVerts].z = vnorm[2];
		}
	else
		{
		vNorms[numVerts].x = 0.0;
		vNorms[numVerts].y = 0.0;
		vNorms[numVerts].z = 0.0;
		}

	/* set the facet normal */
	if (fnorm)
		{
		fNorms[MAX((numVerts - 2), 0)].x = fnorm[0];
		fNorms[MAX((numVerts - 2), 0)].y = fnorm[1];
		fNorms[MAX((numVerts - 2), 0)].z = fnorm[2];
		}
	else
		{
		fNorms[MAX((numVerts - 2), 0)].x = 0.0;
		fNorms[MAX((numVerts - 2), 0)].y = 0.0;
		fNorms[MAX((numVerts - 2), 0)].z = 0.0;
		}

	/* increment the count */
	numVerts++;
}
