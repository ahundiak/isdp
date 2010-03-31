
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:34 $
$Locker:  $
*/

#include "hsurf_import.h"

#include <stdio.h>
#include <tools.h>
#include <EG.h>
#include "hsmath.h"

#include "hsdisplay.h"
#include "HStl_element.h"
#include "HStl_window.h"
#include "HStl_global.h"
#include "hrstruct.h"
#include "HStessel.h"
#include "hstiler.h"

#define	SHIFT_15(n)	(((int *) &n)[1] += 0x00f00000)
#define	SHIFT_16(n)	(((int *) &n)[1] += 0x01000000)
#define	SHIFT_31(n)	(((int *) &n)[1] += 0x01f00000)
#define IROUND(n)	((unsigned char) (n + 0.5))
#define XZROUND(n)	((unsigned long) (n + 0.5))
#define UVROUND(n)	((long) (n + 0.5))
#define	PHLROUND(n)	((int) (n + 0.5))
#define	PHSROUND(n)	((short) (n + 0.5))
#if HR_NORMAL_SIZE == 16
#define PHROUND	PHSROUND
#else
#define PHROUND PHLROUND
#endif

#define ZERO_TOL	1.0e-5

/* scale to keep normals from being exactly equal to 1 or -1 */
/* it is (2**32 - 1) / 2**32 because our normals are 1:31    */
#define NORMAL_SCALE 0.999999999534

#define	CL_DISCONNECT	0x01	/* end of a polygon */
#define	CL_POLY_CLOSE	0x02	/* no more polygons */

#define	MAX_LOOPS	512
#define MAX_EDGES	2048
#define MAX_VERTS	2048
#define	OUTER_FACET	0
#define	NO		0
#define	YES		1
#define	MONOTONE_Y	1
#define	MULT_Y		0
#define	TRAVERSED	32
#define	A_MIN		64
#define NEVER_TRUE	0
#define	LEFT_SIDE	1
#define	RIGHT_SIDE	2

/*extern	int			w_no; 		     window number for draw command */

#define PAGE_SIZE		1024

#define CHUNK_QUANTITY1		( PAGE_SIZE / 4 )
#define CHUNK_QUANTITY2		( PAGE_SIZE / 2 )

static	struct	HSshd_vertex	**mins;
static	struct	HSshd_vertex	**maxs;
static	short			*monotone_y;
static	int			*hole_id;
static int SizeOf_mins, SizeOf_maxs, SizeOf_mono_y, SizeOf_hole_id;
static	int			num_loops;
static int			num_mins;
static int			tcount = 0;
static long			total_verts = 0;
static int			no_verts;
static int			plane_x, plane_y, plane_z;


#define EDGEII_DEBUG	0

/*
 * HSgetSomeMemory() copies the old array into a new one when its bounds are exceeded,
 * frees the old array, and returns the location of the new array.
 *
 * HISTORY: 10/02/90	Created.
 *								Trevor Mink
 */

static char *HSgetSomeMemory( OldArray, BytesToCopy, BytesToGet )
	char *OldArray;
	int BytesToCopy, BytesToGet;
{
	char *NewArray;

	NewArray = (char *)malloc( BytesToGet );
	memcpy( NewArray, OldArray, BytesToCopy );
	free( OldArray );
	return( NewArray );

} /* HSgetSomeMemory */

void EGTriMeshData_debug( vcNo, Triangles )
	int vcNo;
	EGTriMeshData3Info *Triangles; {

	int i, FacetNormals;
	
#ifndef MICROCODE
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

#if EDGEII_DEBUG
	EGTriMeshData3( vcNo, Triangles );
#endif
} /* EGTriMeshData */

/*
 *	ABSTRACT:
 *
 *	The following functions implement a polygon tesselation algorithm which
 *	generates triangular meshes. The same algorithm can be used to generate
 *	a trapezoidal tesselation. The salient features of the algorithm:
 *
 *		* No sorting of vertices is done. A pass is done to find mins,
 *		  then the algorithm just starts a traversal of the polygon
 *		  at the outer min.
 *
 *		* The algorithm has linear time complexity in the best and average
 *		  cases, and the worst case is processed in linear time for n
 *		  (number of vertices in the polygon) less than about 8. The
 *		  worst case still beats n-log-n for n < 32. In actual timing tests,
 *		  this algorithm was shown to be 2 to 3 times faster than the
 *		  regularization algorithm from Shamos ans Preparata - an n log(n)
 *		  algorithm.
 
 *		* The speed of the algorithm is truly based on the complexity
 *		  of the polygon, namely, the number of local minima in y
 *		  found in the polygon. For example, a monotonic polygon 
 *		  containing no holes will be processed faster than a polygon
 * 		  with some local minima. In turn, the polygon with few 
 *		  local minima will be processed faster than polygons with
 *		  many local minima.
 
 *		* The algorithm takes a divide and conquer approach to solving
 *		  the holes case. Holes are treated just as if they were mins
 *		  in the outer polygon. When mins of any kind are encountered,
 *		  the traversal continues to the "left" of the min, then to the
 *		  "right". Thus the polygon with holes is actually treated as a tree,
 *		  being traversed in a pre-order fashion - a fundamentally linear
 *		  procedure. Therefore holes do not take away from the characteristic
 *		  linearity of the algorithm. Nothing special needs to be done for
 *		  them.
 
 *		* Nested holes are handled with a very trivial extension to the algorithm.
 *		  Nested holes are handled here.

 *		* Minor steps have been taken toward approaching an optimal tesselation
 *		  (finding an optimal tesselation for the holes case is generally
 *		  regarded as an NP-complete problem) : (1) Unnecessary horizintal lines
 *		  are easily detected, so they are found and tossed. 

 *		* The algorithm is very well-suited to producing the least number
 *		  of triangular meshes for a given polygon. It about 3 times fewer
 *		  triangular meshes per surface than the regularization approach
 *		  appearing in the Preparata, Shamos book ("Computational Geometry",
 *		  Springer-Verlag).
 *
 *		* Lots of potential for future improvement: As this algorithm introduces
 *		  new vertices into the triangularization process, a method for reducing
 *		  the number of such vertices has been devised and prototyped. The results
 *		  for the one case prototyped showed a 38% decrease in the total
 *		  number of vertices. Vertex elimination, along with techniques for approaching
 *		  an optimal triangulation, constitute several areas which hold a great deal of 
 *		  potential for future work.
 *
 *	HISTORY:
 
 *	November, 1989		Conceived the idea.			M. R. Giesy
 *	July,	  1990		Finished debugging.			M. R. Giesy
 */

int	make_triangles( x, y, z, w, illum0, illum1, illum2, percent, edge_mark,
			clip_flag, planarx, planary )

double	x, y, z, w;
double	illum0, illum1, illum2;
IGRshort	percent;
IGRshort	edge_mark;
int	clip_flag, planarx, planary;
{
	register int			i, j;
	int				temp_id;
	static struct HSshd_vertex	*last_vert, *this_vert, *first_vert, *temp_vert;
	struct	HSshd_vertex		*temp_ptr, *left_vert, *right_vert;
	static double			direction, temp_dir,first_dir;
	static int			FirstTime = TRUE;
	static int			first_facet = 1;
	static int			first_vertex_in_loop = 1;
	static int			num_dir_changes;
	static int			this_loop;

	percent = percent;
	edge_mark = edge_mark;

	left_vert = NULL;
	right_vert = NULL;

	/* build facet loops from verts, saving mins and maxs in nondecreasing order */
	if (first_facet) HSinit_pool_memory_management(VERT_LIST);
	this_vert = (struct HSshd_vertex *) HSalloc_struct_from_pool(VERT_LIST);

	/* Only malloc one time for the session */
	/* OK to leave around for entire EMS session, since it will be needed for shading */
	if( FirstTime )
	{
		FirstTime = FALSE;
		mins = (struct HSshd_vertex **)malloc( CHUNK_QUANTITY1 * sizeof(struct HSshd_vertex *) );
		maxs = (struct HSshd_vertex **)malloc( CHUNK_QUANTITY1 * sizeof(struct HSshd_vertex *) );
		monotone_y = (short *)malloc( CHUNK_QUANTITY2 * sizeof(short) );
		hole_id = (int *)malloc( CHUNK_QUANTITY1 * sizeof(int) );
		SizeOf_mins = SizeOf_maxs = SizeOf_hole_id = CHUNK_QUANTITY1;
		SizeOf_mono_y = CHUNK_QUANTITY2;
	}

	if (first_facet)
	{
#ifndef MICROCODE
/*		if (tcount == 570)
			fp = fopen("/usr3/tmp/mold570", "w");*/
#endif
		last_vert = first_vert = this_vert;
		num_mins = 0;
		num_loops = this_loop = 0;
		first_facet = 0;
		no_verts = 0;
	}

	if (first_vertex_in_loop)
	{
		first_vertex_in_loop = 0;
		num_dir_changes = 0;
		maxs[this_loop] = first_vert = last_vert = this_vert;
		first_dir = temp_dir = direction = 0;
	}

	this_vert->mrk = 0;
	no_verts++;
	this_vert->coord[0] = x;
	this_vert->coord[1] = y;
	this_vert->coord[2] = z;
	this_vert->illum.normal[0] = illum0;
	this_vert->illum.normal[1] = illum1;
	this_vert->illum.normal[2] = illum2;
	this_vert->coord[3] = w;

/*	if ((tcount == 570) && (fp))
	fprintf(fp, "%21.20e %21.20e %f %f %f %f %f %d %d %d\n",
		this_vert->coord[planarx], this_vert->coord[planary], 0.0, 0.0,
		0.0, 0.0, 0.0, 0, 0, clip_flag);*/

	/* set up double link to adjacent vertices */
	this_vert->blink = last_vert;
	if (last_vert != this_vert) last_vert->flink = this_vert;

	/* keep track of changes of direction in y, save any local minima in the
	 * "mins" structure and save the id of the hole/facet to which the minimum
	 * belongs
	 */
	if ((last_vert == first_vert) || (first_dir == 0))
	{
		direction = last_vert->coord[planary] - this_vert->coord[planary];
		first_dir = direction;
		if (FABS(first_dir) <= ZERO_TOL) first_dir = 0.0;
		/* be ready for a line coming through */
		if (this_vert != first_vert) {
			if (this_vert->coord[planarx] < left_vert->coord[planarx])
				left_vert = this_vert;
			if (this_vert->coord[planarx] > right_vert->coord[planarx])
				right_vert = this_vert;
		}
		else
			left_vert = right_vert = this_vert;
	}
	else
	{
		/* may be a more efficient way */
		if (clip_flag & (CL_POLY_CLOSE | CL_DISCONNECT)) {
			j = 1;
			if (clip_flag & CL_DISCONNECT) j = 0;
			for (i=j; i < 3; i++) /* need to check three directed edges */
			{
				if (i == 0) {
					temp_vert = last_vert;
					temp_dir = last_vert->coord[planary] - this_vert->coord[planary];
				}
				else if (i == 1) {
					if (clip_flag & CL_DISCONNECT) temp_vert = this_vert;
					else temp_vert = last_vert;
					temp_dir = temp_vert->coord[planary] - first_vert->coord[planary];
				}
				else {
					temp_dir = first_dir;
					temp_vert = first_vert;
				}
				if (FABS(temp_dir) <= ZERO_TOL) temp_dir = 0.0;
				if ((temp_dir > 0.0) && (direction < 0.0)) {
					direction = temp_dir;
					num_dir_changes++;
				}
				else if ((temp_dir < 0.0) && (direction > 0.0))
				{
					num_dir_changes++;
					temp_vert->mrk |= A_MIN;
					mins[num_mins] = temp_vert;
					if (this_loop > 0)
						hole_id[num_mins] = this_loop;
					else
						hole_id[num_mins] = 0;
					if( ++num_mins == SizeOf_mins )
					{
						mins = (struct HSshd_vertex **)HSgetSomeMemory(
							(char *)mins,
							SizeOf_mins * sizeof(struct HSshd_vertex *),
							2 * SizeOf_mins * sizeof(struct HSshd_vertex *) );
						SizeOf_mins += CHUNK_QUANTITY1;
					}
					if( num_mins == SizeOf_hole_id )
					{
						hole_id = (int *)HSgetSomeMemory( (char *)hole_id,
							SizeOf_hole_id * sizeof(int),
							2 * SizeOf_hole_id * sizeof(int) );
						SizeOf_hole_id += CHUNK_QUANTITY1;
					}
					direction = temp_dir;
				}
			}
		}
		else {
			temp_dir = last_vert->coord[planary] - this_vert->coord[planary];
			if (FABS(temp_dir) <= ZERO_TOL) temp_dir = 0.0;

			if ((temp_dir > 0.0) && (direction < 0.0)) {
				direction = temp_dir;
				num_dir_changes++;
			}
			else if ((temp_dir < 0.0) && (direction > 0.0))
			{
				num_dir_changes++;
				last_vert->mrk |= A_MIN;
				mins[num_mins] = last_vert;
				if (this_loop > 0)
					hole_id[num_mins] = this_loop;
				else
					hole_id[num_mins] = 0;
				if( ++num_mins == SizeOf_mins )
				{
					mins = (struct HSshd_vertex **)HSgetSomeMemory( (char *)mins,
						SizeOf_mins * sizeof(struct HSshd_vertex *),
						2 * SizeOf_mins * sizeof(struct HSshd_vertex *) );
					SizeOf_mins += CHUNK_QUANTITY1;
				}
				if( num_mins == SizeOf_hole_id )
				{
					hole_id = (int *)HSgetSomeMemory( (char *)hole_id,
						SizeOf_hole_id * sizeof(int),
						2 * SizeOf_hole_id * sizeof(int) );
					SizeOf_hole_id += CHUNK_QUANTITY1;
				}
				direction = temp_dir;
			}
		}
	}

	/* update which vertex currently has the maximum y
	 */
	if ((this_vert->coord[planary] > maxs[this_loop]->coord[planary]) && (clip_flag != 2))
		maxs[this_loop] = this_vert;

	/*
	 *  When a disconnect is received for a sub-poly, the forward link
	 *  for the disconnected vertex links back to the first vertex.
	 *  This is sent by a pmovexx() command.
	 */

	if( clip_flag & CL_DISCONNECT )
	{
		if (this_vert != last_vert)
		{
			this_vert->flink = first_vert;
			first_vert->blink = this_vert;
			if (this_vert->mrk & 2) first_vert->mrk += 1;
			if (num_dir_changes <= 2) monotone_y[this_loop] = MONOTONE_Y;
			else monotone_y[this_loop] = MULT_Y;
			first_vertex_in_loop = 1;
			if( ++this_loop == SizeOf_mono_y )
			{
				monotone_y = (short *)HSgetSomeMemory( (char *)monotone_y,
					SizeOf_mono_y * sizeof(short),
					SizeOf_mono_y * 2 * sizeof(short) );
				SizeOf_mono_y += CHUNK_QUANTITY2;
			}
			if( this_loop == SizeOf_maxs )
			{
				maxs = (struct HSshd_vertex **)HSgetSomeMemory( (char *)maxs,
					SizeOf_maxs * sizeof(struct HSshd_vertex *),
					SizeOf_maxs * sizeof(struct HSshd_vertex *) * 2 );
				SizeOf_maxs += CHUNK_QUANTITY1;
			}
		}
	}

	/*
	 *  Continue storing vertices in the Master List until the polygon
	 *  close pclose() has been sent.  i.e. ready to start clipping.
	 */
 
	if( clip_flag & CL_POLY_CLOSE )
	{
		last_vert->flink = first_vert;
		first_vert->blink = last_vert;
		if (this_vert->mrk & 2) first_vert->mrk += 1;
		if (num_dir_changes <= 2) monotone_y[this_loop] = MONOTONE_Y;
		else monotone_y[this_loop] = MULT_Y;
		first_facet = 1;
		first_vertex_in_loop = 1;
		this_loop++;
		num_loops = this_loop;
		plane_x = planarx;
		plane_y = planary;
		if ((plane_x != 0) && (plane_y != 0)) plane_z = 0;
		if ((plane_x != 1) && (plane_y != 1)) plane_z = 1;
		if ((plane_x != 2) && (plane_y != 2)) plane_z = 2;
/*		if (tcount == 570) fclose(fp); */
	}
	else
	{
		last_vert = this_vert;
		return (0);
	}

#if DEBUG
if( !(DEBUG_PATCH) ) return;
fprintf( stderr, "patch number - %1d\n", tcount );
fprintf( stderr, "  x      y            z            nx           ny           nz\n" );
fprintf( stderr, "------ ------ ----------------- ------------ ------------ ------------\n" );
#endif

	/* sort the mins (and correspondign hole ids) here for now */
/*	printf("num_mins = %d\n", num_mins);*/
	if (num_dir_changes > 0) {
		for(i=1; i < num_mins; i++)
		{
			j = 0;
			while((j < i) && (mins[i]->coord[planary] >= mins[j]->coord[planary]))
				j++;
			for(j=j; j < i; j++)
			{
				temp_ptr = mins[i];
				mins[i] = mins[j];
				mins[j] = temp_ptr;
				temp_id = hole_id[i];
				hole_id[i] = hole_id[j];
				hole_id[j] = temp_id;
			}
		}

		HStessel_facet();
		HSfree_pool_memory();
	}
/*	else
		linefill(left_vert, right_vert);*/
/*	printf("tcount = %d\n", tcount); 
	printf("total vertices = %ld\n", total_verts);*/
return(0);
} /* make_triangles */


static	EGTriMeshData3Info 	tri_mesh;
static	EGVect3			fnrm[1];
static  int			num_verts;

static void HSadd_triangle( next_vertex, prev_vertex, curr_backward, curr_forward )
	struct HSshd_vertex *next_vertex, *prev_vertex, *curr_backward, *curr_forward;
{
	if( num_verts )
	{
		tri_mesh.verts[num_verts].x = next_vertex->coord[0];
		tri_mesh.verts[num_verts].y = next_vertex->coord[1];
		tri_mesh.verts[num_verts].z = next_vertex->coord[2];
		if( element_parms.facet_type == SMOOTH_SHADE )
		{
			tri_mesh.vNorms[num_verts].x = next_vertex->illum.normal[0];
			tri_mesh.vNorms[num_verts].y = next_vertex->illum.normal[1];
			tri_mesh.vNorms[num_verts].z = next_vertex->illum.normal[2];
		}
		tri_mesh.verts[++num_verts].x = prev_vertex->coord[0];
		tri_mesh.verts[num_verts].y = prev_vertex->coord[1];
		tri_mesh.verts[num_verts].z = prev_vertex->coord[2];
		if( element_parms.facet_type == SMOOTH_SHADE )
		{
			tri_mesh.vNorms[num_verts].x = prev_vertex->illum.normal[0];
			tri_mesh.vNorms[num_verts].y = prev_vertex->illum.normal[1];
			tri_mesh.vNorms[num_verts].z = prev_vertex->illum.normal[2];
		}
		num_verts++;
	}
	else
	{
		if (curr_backward == curr_forward)
		{
			tri_mesh.verts[0].x = curr_backward->coord[0];
			tri_mesh.verts[0].y = curr_backward->coord[1];
			tri_mesh.verts[0].z = curr_backward->coord[2];
			tri_mesh.verts[1].x = next_vertex->coord[0];
			tri_mesh.verts[1].y = next_vertex->coord[1];
			tri_mesh.verts[1].z = next_vertex->coord[2];
			tri_mesh.verts[2].x = prev_vertex->coord[0];
			tri_mesh.verts[2].y = prev_vertex->coord[1];
			tri_mesh.verts[2].z = prev_vertex->coord[2];
			if( element_parms.facet_type == SMOOTH_SHADE )
			{
				tri_mesh.vNorms[0].x = curr_backward->illum.normal[0];
				tri_mesh.vNorms[0].y = curr_backward->illum.normal[1];
				tri_mesh.vNorms[0].z = curr_backward->illum.normal[2];
				tri_mesh.vNorms[1].x = next_vertex->illum.normal[0];
				tri_mesh.vNorms[1].y = next_vertex->illum.normal[1];
				tri_mesh.vNorms[1].z = next_vertex->illum.normal[2];
				tri_mesh.vNorms[2].x = prev_vertex->illum.normal[0];
				tri_mesh.vNorms[2].y = prev_vertex->illum.normal[1];
				tri_mesh.vNorms[2].z = prev_vertex->illum.normal[2];
			}
			num_verts = 3;
		}
		else
		{
			tri_mesh.verts[0].x = curr_forward->coord[0];
			tri_mesh.verts[0].y = curr_forward->coord[1];
			tri_mesh.verts[0].z = curr_forward->coord[2];
			tri_mesh.verts[1].x = curr_backward->coord[0];
			tri_mesh.verts[1].y = curr_backward->coord[1];
			tri_mesh.verts[1].z = curr_backward->coord[2];
			tri_mesh.verts[2].x = next_vertex->coord[0];
			tri_mesh.verts[2].y = next_vertex->coord[1];
			tri_mesh.verts[2].z = next_vertex->coord[2];
			tri_mesh.verts[3].x = prev_vertex->coord[0];
			tri_mesh.verts[3].y = prev_vertex->coord[1];
			tri_mesh.verts[3].z = prev_vertex->coord[2];
			if( element_parms.facet_type == SMOOTH_SHADE )
			{
				tri_mesh.vNorms[0].x = curr_forward->illum.normal[0];
				tri_mesh.vNorms[0].y = curr_forward->illum.normal[1];
				tri_mesh.vNorms[0].z = curr_forward->illum.normal[2];
				tri_mesh.vNorms[1].x = curr_backward->illum.normal[0];
				tri_mesh.vNorms[1].y = curr_backward->illum.normal[1];
				tri_mesh.vNorms[1].z = curr_backward->illum.normal[2];
				tri_mesh.vNorms[2].x = next_vertex->illum.normal[0];
				tri_mesh.vNorms[2].y = next_vertex->illum.normal[1];
				tri_mesh.vNorms[2].z = next_vertex->illum.normal[2];
				tri_mesh.vNorms[3].x = prev_vertex->illum.normal[0];
				tri_mesh.vNorms[3].y = prev_vertex->illum.normal[1];
				tri_mesh.vNorms[3].z = prev_vertex->illum.normal[2];
			}
			num_verts = 4;
		}
	}
} /* HSadd_triangle */

static int HSwithin_tol( plane_y, min_ptr, prev_vertex, next_vertex )
	int plane_y;
	struct HSshd_vertex *min_ptr, *prev_vertex, *next_vertex;
{
	if( (min_ptr->coord[plane_y] - prev_vertex->coord[plane_y] <= ZERO_TOL &&
		prev_vertex->coord[plane_y] - next_vertex->coord[plane_y] <= ZERO_TOL) ||
		(min_ptr->coord[plane_y] - next_vertex->coord[plane_y] <= ZERO_TOL &&
		next_vertex->coord[plane_y] - prev_vertex->coord[plane_y] <= ZERO_TOL) )

		return( TRUE );
	else
		return( FALSE );	

} /* HSwithin_tol */

static void HSsend_mesh()
{
	tri_mesh.numVerts = num_verts;
	(*active_window->process_mesh)( active_window->vc_no, &tri_mesh );
	tcount++;
	total_verts += num_verts;
	num_verts = 0;
} /* HSsend_mesh */


/*
 * HStessel_facet() triangulates the facet that has been assembled within make_triangles.
 *
 * HISTORY: ??/??/90	Created.
 *								Mitch Giesy
 *	    09/??/90	Modularized somewhat.
 *								Trevor Mink
 *	    10/04/90	Some memory management.
 *								Trevor Mink
 */

int HStessel_facet()
{
	double			ylo, yhi;
	double			x0,x1,x2;
	double			w0,w1;
	double			*src_ptr, *dst_ptr, *dst_ptr2, *dst_ptr3;
	double			lve_vert[3], rve_vert[3];
	int			temp_mrk;
	int			mins_head, temp_mins_head, mins_i;
	int			rtop, ltop, rhtop, lhtop, lfptop, rfptop, lctop, rctop, mtop;
	int			*rhole, *lhole;
	int			*lframe_ptr, *rframe_ptr;
	int			*rfclockw_stk, *lfclockw_stk;
	int			*mins_i_stk;
	int			left_face_id, right_face_id;
	IGRdouble 		y_change, ly_change=0, ry_change=0;
	IGRdouble		 temp_x=0, temp_b=0;
	struct HSshd_vertex	*prev_vertex, *next_vertex, *curr_forward, *curr_backward;
	struct HSshd_edge  	*lts, *rts;
	struct HSshd_vertex	*busted, *temp_ptr, *temp_ptr1, *min_ptr, *min_fptr;
	struct HSshd_vertex	temp_ptr2, temp_ptr3;
	IGRboolean 		done_busting, fclockw=TRUE, rfclockw=TRUE, lfclockw;
	IGRboolean		fflag, bflag;
	int			new_num_mins, i;
	int			Vertices;
	/* Local space to handle most facets */
	int			rhole_array[MAX_LOOPS], lhole_array[MAX_LOOPS];
	int			rframe_array[MAX_LOOPS], lframe_array[MAX_LOOPS];
	int			rfclockw_array[MAX_LOOPS],lfclockw_array[MAX_LOOPS];
	int			mins_array[MAX_LOOPS];
	struct HSshd_edge	lts_array[MAX_VERTS], rts_array[MAX_VERTS];

	if( num_loops > MAX_LOOPS )
	{
		/* Only malloc once and make the others offsets into the long array */
		rhole = (int *)malloc( 7 * num_loops * sizeof( int ) );

		lhole = rhole + num_loops;
		lframe_ptr = lhole + num_loops;
		rframe_ptr = lframe_ptr + num_loops;
		rfclockw_stk = rframe_ptr + num_loops;
		lfclockw_stk = rfclockw_stk + num_loops;
		mins_i_stk = lfclockw_stk + num_loops;
	}
	else
	{
		rhole = rhole_array;
		lhole = lhole_array;
		lframe_ptr = lframe_array;
		rframe_ptr = rframe_array;
		rfclockw_stk = rfclockw_array;
		lfclockw_stk = lfclockw_array;
		mins_i_stk = mins_array;
	}

	Vertices = no_verts * 2;
	if( Vertices > MAX_VERTS )
	{
		/* Only malloc once and make the other an offset into the long array */
		lts = (struct HSshd_edge *)malloc( 2 * Vertices * sizeof( struct HSshd_edge ) );
		rts = lts + Vertices;
	}
	else
	{
		lts = lts_array;
		rts = rts_array;
	}

	HSinit_pool_memory_management(BUST_LIST);
	busted = (struct HSshd_vertex *) HSalloc_struct_from_pool(BUST_LIST);
	num_verts = 0;

	tri_mesh.verts = (EGPoint3 *) malloc(sizeof(EGPoint3) * no_verts * 2);
	tri_mesh.vertOffset = sizeof( EGPoint3 );
	if (!tri_mesh.fNorms) tri_mesh.fNorms = fnrm;
	if( element_parms.facet_type == SMOOTH_SHADE ) {
		tri_mesh.vNorms = (EGVect3 *) malloc(sizeof(EGVect3) * no_verts * 2);
		tri_mesh.vNormOffset = sizeof( EGVect3 );
	} else {
		tri_mesh.vNormOffset = 0;
		tri_mesh.vNorms = (EGVect3 *)NULL;
	}
	tri_mesh.vColors = (EGRGBColor *)NULL;
	tri_mesh.fColors = (EGRGBColor *)NULL;
	tri_mesh.fColorOffset = 0;
	tri_mesh.vColorOffset = 0;
	tri_mesh.fNormOffset = 0;
	tri_mesh.fNorms[0].x = element_parms.facet_normal[0];
	tri_mesh.fNorms[0].y = element_parms.facet_normal[1];
	tri_mesh.fNorms[0].z = element_parms.facet_normal[2];

	/********************************************************************************/
	/*			 monotonic in y, no holes				*/
	/********************************************************************************/

	if ((num_loops == 1) && (monotone_y[0] == MONOTONE_Y))
	{
		/* find the direction, clockwise or counter-clockwise, of the vertices */
		next_vertex = mins[0]->flink;
		prev_vertex = mins[0]->blink;
		curr_forward = curr_backward = mins[0];
		do
		{
			while (FABS(curr_backward->coord[plane_y] - prev_vertex->coord[plane_y]) < ZERO_TOL)
			{
				curr_backward = prev_vertex;
				prev_vertex = prev_vertex->blink;
			}
			while (FABS(curr_forward->coord[plane_y] - next_vertex->coord[plane_y]) < ZERO_TOL)
			{
				curr_forward = next_vertex;
				next_vertex = next_vertex->flink;
			}
			if (prev_vertex->coord[plane_y] < next_vertex->coord[plane_y])
			{
				y_change = (prev_vertex->coord[plane_y] - curr_backward->coord[plane_y])
					/ (next_vertex->coord[plane_y] - curr_backward->coord[plane_y]);
				busted->coord[plane_x] = curr_forward->coord[plane_x] + y_change *
					(next_vertex->coord[plane_x] - curr_forward->coord[plane_x]);
				fclockw = busted->coord[plane_x] >= prev_vertex->coord[plane_x];
				temp_x = prev_vertex->coord[plane_x];
				if (FABS(busted->coord[plane_x] - temp_x) < ZERO_TOL)
				{
					curr_forward = next_vertex;
					next_vertex = next_vertex->flink;
				}
			}
			if (next_vertex->coord[plane_y] <= prev_vertex->coord[plane_y])
			{
				y_change = (next_vertex->coord[plane_y] - curr_backward->coord[plane_y])
					/ (prev_vertex->coord[plane_y] - curr_backward->coord[plane_y]);
				busted->coord[plane_x] = curr_backward->coord[plane_x] +
					y_change * (prev_vertex->coord[plane_x] - curr_backward->coord[plane_x]);
				fclockw = busted->coord[plane_x] <= next_vertex->coord[plane_x];
				temp_x = next_vertex->coord[plane_x];
				if (FABS(busted->coord[plane_x] - temp_x) < ZERO_TOL)
				{
					curr_backward = prev_vertex;
					prev_vertex = prev_vertex->blink;
				}
			}
		} while ((FABS(prev_vertex->coord[plane_x] - next_vertex->coord[plane_x]) >= ZERO_TOL) &&
			 (FABS(busted->coord[plane_x] - temp_x) < ZERO_TOL));

		if (!fclockw)
		{
			next_vertex = curr_backward->blink;
			prev_vertex = curr_forward->flink;
			temp_ptr = curr_backward;
			curr_backward = curr_forward;
			curr_forward = temp_ptr;
		}
		done_busting = FALSE;
		bflag = FALSE;
		fflag = FALSE;
		while (!done_busting)
		{
			/* get rid of horizontal edges forward */
			while((FABS(curr_forward->coord[plane_y] - next_vertex->coord[plane_y]) < ZERO_TOL)
				&& (!(done_busting = (next_vertex == curr_backward))))
			{
				fflag = TRUE;
				curr_forward = next_vertex;
				if (fclockw) next_vertex = next_vertex->flink;
				else next_vertex = next_vertex->blink;
			}

			/* get rid of horizontal edges backward */
			while ((FABS(curr_backward->coord[plane_y] - prev_vertex->coord[plane_y]) < ZERO_TOL)
				&& (!(done_busting = (curr_forward == prev_vertex))))
			{
				fflag = TRUE;
				curr_backward = prev_vertex;
				if (fclockw) prev_vertex = prev_vertex->blink;
				else prev_vertex = prev_vertex->flink;
			}

			if (fflag)
			{
				if (num_verts) HSsend_mesh();
				fflag = FALSE;
			}

			if ((done_busting) && (num_verts)) HSsend_mesh();

			if (done_busting) break;  /* quit if no more busting to do */

			/* bust and interp */
			if (prev_vertex->coord[plane_y] < next_vertex->coord[plane_y])
			{
				/* calc change in y at bust point */
				y_change = (prev_vertex->coord[plane_y] - curr_forward->coord[plane_y])
					    / (next_vertex->coord[plane_y] - curr_forward->coord[plane_y]);
				/* bust an edge */
				dst_ptr = busted->coord;
				dst_ptr[plane_x] = y_change * (next_vertex->coord[plane_x] - curr_forward->coord[plane_x])
						  + curr_forward->coord[plane_x];
				dst_ptr[plane_y] = prev_vertex->coord[plane_y];
				dst_ptr[plane_z] = y_change * (next_vertex->coord[plane_z] - curr_forward->coord[plane_z])
						  + curr_forward->coord[plane_z];

				dst_ptr = busted->illum.normal;
				dst_ptr2 = next_vertex->illum.normal;
				dst_ptr3 = curr_forward->illum.normal;
				dst_ptr[0] = y_change * (dst_ptr2[0] - dst_ptr3[0]) + dst_ptr3[0];
				dst_ptr[1] = y_change * (dst_ptr2[1] - dst_ptr3[1]) + dst_ptr3[1];
				dst_ptr[2] = y_change * (dst_ptr2[2] - dst_ptr3[2]) + dst_ptr3[2];

				HSadd_triangle( busted, prev_vertex, curr_backward, curr_forward );

				dst_ptr = curr_forward->coord;
				src_ptr = busted->coord;
				memcpy( (unsigned char *)dst_ptr,
					(unsigned char *)src_ptr, 4 * sizeof( double ) );

				dst_ptr = curr_forward->illum.normal;
				src_ptr = busted->illum.normal;
				memcpy( (unsigned char *)dst_ptr,
					(unsigned char *)src_ptr, 3 * sizeof( double ) );

				curr_backward = prev_vertex;
				if (fclockw) prev_vertex = prev_vertex->blink;
				else prev_vertex = prev_vertex->flink;
			}
			else if (prev_vertex->coord[plane_y] ==  next_vertex->coord[plane_y])
			{
				HSadd_triangle( next_vertex, prev_vertex, curr_backward, curr_forward );

				curr_forward = next_vertex;
				curr_backward = prev_vertex;
				if (fclockw)
				{
					next_vertex = next_vertex->flink;
					prev_vertex = prev_vertex->blink;
				}
				else {
					prev_vertex = prev_vertex->flink;
				 	next_vertex = next_vertex->blink;
				}
			}
			else
			{
				/* calc change in y at bust point */
				y_change = (next_vertex->coord[plane_y] - curr_backward->coord[plane_y])
					    / (prev_vertex->coord[plane_y] - curr_backward->coord[plane_y]);
				/* bust an edge */
				dst_ptr = busted->coord;
				dst_ptr[plane_x] = y_change * (prev_vertex->coord[plane_x] - curr_backward->coord[plane_x])
						  + curr_backward->coord[plane_x];
				dst_ptr[plane_y] = next_vertex->coord[plane_y];
				dst_ptr[plane_z] = y_change * (prev_vertex->coord[plane_z] - curr_backward->coord[plane_z])
						  + curr_backward->coord[plane_z];

				dst_ptr = busted->illum.normal;
				dst_ptr[0] = y_change * (prev_vertex->illum.normal[0] - curr_backward->illum.normal[0])
							     + curr_backward->illum.normal[0];
				dst_ptr[1] = y_change * (prev_vertex->illum.normal[1] - curr_backward->illum.normal[1])
							 + curr_backward->illum.normal[1];
				dst_ptr[2] = y_change * (prev_vertex->illum.normal[2] - curr_backward->illum.normal[2])
							 + curr_backward->illum.normal[2];

				HSadd_triangle( next_vertex, busted, curr_backward, curr_forward );

				dst_ptr = curr_backward->coord;
				src_ptr = busted->coord;
				memcpy( (unsigned char *)dst_ptr,
					(unsigned char *)src_ptr, 3 * sizeof( double ) );
				dst_ptr = curr_backward->illum.normal;
				src_ptr = busted->illum.normal;
				memcpy( (unsigned char *)dst_ptr,
					(unsigned char *)src_ptr, 3 * sizeof( double ) );
				curr_forward = next_vertex;
				if (fclockw)
					next_vertex = next_vertex->flink;
				else
					next_vertex = next_vertex->blink;
			}

			if (done_busting = (curr_forward == curr_backward)) HSsend_mesh();
		}
	}
	else 
	{

	/********************************************************************************/
	/*			Non-monotonic, and/or holes				*/
	/********************************************************************************/

		/* find the direction, clockwise or counter-clockwise, of the vertices */
		next_vertex = mins[0]->flink;
		prev_vertex = mins[0]->blink;
		curr_forward = curr_backward = mins[0];
		do
		{
			while (FABS(curr_backward->coord[plane_y] - prev_vertex->coord[plane_y]) < ZERO_TOL)
			{
				/* This statement doesn't apply to non-holes case */
				if (curr_backward->mrk & A_MIN) curr_backward->mrk |= TRAVERSED;

				curr_backward = prev_vertex;
				prev_vertex = prev_vertex->blink;
			}
			while (FABS(curr_forward->coord[plane_y] - next_vertex->coord[plane_y]) < ZERO_TOL)
			{
				/* This statement doesn't apply to non-holes case */
				if (curr_forward->mrk & A_MIN) curr_forward->mrk |= TRAVERSED;

				curr_forward = next_vertex;
				next_vertex = next_vertex->flink;
			}
			if (prev_vertex->coord[plane_y] < next_vertex->coord[plane_y])
			{
				y_change = (prev_vertex->coord[plane_y] - curr_backward->coord[plane_y])
					/ (next_vertex->coord[plane_y] - curr_backward->coord[plane_y]);
				busted->coord[plane_x] = curr_forward->coord[plane_x] + y_change *
					(next_vertex->coord[plane_x] - curr_forward->coord[plane_x]);
				rfclockw = busted->coord[plane_x] >= prev_vertex->coord[plane_x];
				temp_x = prev_vertex->coord[plane_x];
				if (FABS(busted->coord[plane_x] - temp_x) < ZERO_TOL)
				{
					/* This statement doesn't apply to non-holes case */
					if (curr_forward->mrk & A_MIN) curr_forward->mrk |= TRAVERSED;

					curr_forward = next_vertex;
					next_vertex = next_vertex->flink;
				}
			}
			if (next_vertex->coord[plane_y] <= prev_vertex->coord[plane_y])
			{
				y_change = (next_vertex->coord[plane_y] - curr_backward->coord[plane_y])
					/ (prev_vertex->coord[plane_y] - curr_backward->coord[plane_y]);
				busted->coord[plane_x] = curr_backward->coord[plane_x] +
					y_change * (prev_vertex->coord[plane_x] - curr_backward->coord[plane_x]);
				rfclockw = busted->coord[plane_x] <= next_vertex->coord[plane_x];
				temp_x = next_vertex->coord[plane_x];
				if (FABS(busted->coord[plane_x] - temp_x) < ZERO_TOL)
				{
					/* This statement doesn't apply to non-holes case */
					if (curr_backward->mrk & A_MIN) curr_backward->mrk |= TRAVERSED;

					curr_backward = prev_vertex;
					prev_vertex = prev_vertex->blink;
				}
			}
		} while ((FABS(prev_vertex->coord[plane_x] - next_vertex->coord[plane_x]) >= ZERO_TOL) &&
			 (FABS(busted->coord[plane_x] - temp_x) < ZERO_TOL));
		curr_forward = curr_backward = mins[0];

		if (!rfclockw)
		{
			next_vertex = curr_backward->blink;
			prev_vertex = curr_forward->flink;
		}
		else
		{
			next_vertex = curr_forward->flink;
			prev_vertex = curr_backward->blink;
		}
		lfclockw = rfclockw;

		ltop = rtop = lhtop = rhtop = lctop = rctop = lfptop = rfptop = mtop = 0;
		right_face_id = left_face_id = 0;
		mins_head = mins_i = 1;
		done_busting = FALSE;
		fflag = FALSE;
		bflag = FALSE;
		lframe_ptr[0] = rframe_ptr[0] = rhole[0] = lhole[0] = 0;
		while (!done_busting)
		{
			/* get rid of horizontal edges forward */
			while((FABS(curr_forward->coord[plane_y] - next_vertex->coord[plane_y]) < ZERO_TOL)
				&& (!(done_busting = (next_vertex == curr_backward))))
			{
				fflag = TRUE;
				curr_forward->mrk |= TRAVERSED;
				curr_forward = next_vertex;
				if (rfclockw) next_vertex = next_vertex->flink;
				else next_vertex = next_vertex->blink;
			}

			/* get rid of horizontal edges backward */
			while ((FABS(curr_backward->coord[plane_y] - prev_vertex->coord[plane_y]) < ZERO_TOL)
				&& (!(done_busting = (curr_forward == prev_vertex))))
			{
				fflag = TRUE;
				curr_backward->mrk |= TRAVERSED;
				curr_backward = prev_vertex;
				if (lfclockw) prev_vertex = prev_vertex->blink;
				else prev_vertex = prev_vertex->flink;
			}

			if (fflag)
			{
				if (num_verts) HSsend_mesh();
				fflag = FALSE;
			}

			/* Detect that the left side takes a turn upward and retrace back */
			if( (prev_vertex->coord[plane_y] - curr_backward->coord[plane_y]) <= -ZERO_TOL)
			{
				do
				{
					if (lfclockw) {
						curr_backward = curr_backward->flink;
						prev_vertex = curr_backward->blink;
					}
					else {
						curr_backward = curr_backward->blink;
						prev_vertex = curr_backward->flink;
					}
				}
				while( prev_vertex->coord[plane_y] == curr_backward->coord[plane_y] );
			}

			if( (next_vertex->coord[plane_y] - curr_forward->coord[plane_y]) <= -ZERO_TOL)
			{
				do
				{
					if (rfclockw) {
						curr_forward = curr_forward->blink;
						next_vertex = curr_forward->flink;
					}
					else {
						curr_forward = curr_forward->flink;
						next_vertex = curr_forward->blink;
					}
				}
				while( next_vertex->coord[plane_y] == curr_forward->coord[plane_y] );
			}

			if ((done_busting) && (num_verts)) HSsend_mesh();

			/*** look for mins intersections ***/
			while ((mins_head < num_mins) && (mins[mins_head]->mrk & TRAVERSED))
				mins_head++;
			temp_mins_head = mins_head;
			min_ptr = mins[mins_head];
			while ( (mins_head < num_mins) && (!done_busting) &&
				HSwithin_tol( plane_y, min_ptr, prev_vertex, next_vertex ) )
			{
				/* point location for mins[mins_head] and current trapezoid */
				if( (min_ptr->coord[plane_y] - curr_backward->coord[plane_y]) >= -ZERO_TOL &&
				    (!(min_ptr->mrk & TRAVERSED)))
				{
					ry_change = (min_ptr->coord[plane_y] - curr_forward->coord[plane_y])
						    / (next_vertex->coord[plane_y] - curr_forward->coord[plane_y]);
					rve_vert[plane_x] = ry_change * (next_vertex->coord[plane_x] - curr_forward->coord[plane_x])
						  + curr_forward->coord[plane_x];
					ly_change = (min_ptr->coord[plane_y] - curr_backward->coord[plane_y])
						    / (prev_vertex->coord[plane_y] - curr_backward->coord[plane_y]);
					lve_vert[plane_x] = ly_change * (prev_vertex->coord[plane_x] - curr_backward->coord[plane_x])
						  + curr_backward->coord[plane_x];
				}
				else
					rve_vert[plane_x] = min_ptr->coord[plane_x] - 1.0;
				if ((min_ptr->coord[plane_x] >= lve_vert[plane_x]) &&
				    (min_ptr->coord[plane_x] <= rve_vert[plane_x]) &&
				    (min_ptr != curr_forward) &&
				    (min_ptr != curr_backward))
				{
					/* mark the min as having been traversed */
					min_ptr->mrk |= TRAVERSED;
					/* first bust above mins[num_min] */
/*					ylo = curr_backward->coord[plane_y];*/
					yhi = rve_vert[plane_y] = lve_vert[plane_y] = min_ptr->coord[plane_y];
/*					x0 = lve_vert[plane_x];
					x1 = rve_vert[plane_x];*/

					lve_vert[plane_z] = ly_change * (prev_vertex->coord[plane_z] - curr_backward->coord[plane_z])
						+ curr_backward->coord[plane_z];
					rve_vert[plane_z] = ry_change * (next_vertex->coord[plane_z] - curr_forward->coord[plane_z])
						+ curr_forward->coord[plane_z];
					w0  = ly_change * (prev_vertex->coord[3] - curr_backward->coord[3])
						+ curr_backward->coord[3];
					w1  = ry_change * (next_vertex->coord[3] - curr_forward->coord[3])
						+ curr_forward->coord[3];

					dst_ptr = temp_ptr2.illum.normal;
					dst_ptr[0] = ly_change * (prev_vertex->illum.normal[0] - curr_backward->illum.normal[0])
						+ curr_backward->illum.normal[0];
					dst_ptr[1] = ly_change * (prev_vertex->illum.normal[1] - curr_backward->illum.normal[1])
						+ curr_backward->illum.normal[1];
					dst_ptr[2] = ly_change * (prev_vertex->illum.normal[2] - curr_backward->illum.normal[2])
						+ curr_backward->illum.normal[2];

					dst_ptr = temp_ptr3.illum.normal;
					dst_ptr[0] = ry_change * (next_vertex->illum.normal[0] - curr_forward->illum.normal[0])
						+ curr_forward->illum.normal[0];
					dst_ptr[1] = ry_change * (next_vertex->illum.normal[1] - curr_forward->illum.normal[1])
						+ curr_forward->illum.normal[1];
					dst_ptr[2] = ry_change * (next_vertex->illum.normal[2] - curr_forward->illum.normal[2])
						+ curr_forward->illum.normal[2];

					memcpy( (unsigned char *)temp_ptr3.coord,
						(unsigned char *)rve_vert, 3 * sizeof( double ) );
					memcpy( (unsigned char *)temp_ptr2.coord,
						(unsigned char *)lve_vert, 3 * sizeof( double ) );
					HSadd_triangle( &temp_ptr3, &temp_ptr2, curr_backward, curr_forward );

					HSsend_mesh();

					/* update traversal, not concerned w/ mins[mins_head lying
					 * on yhi or ylo of current trapezoid */
					curr_backward->mrk |= TRAVERSED;

					if (curr_forward == curr_backward)
					{
						temp_ptr = curr_backward->flink;
						temp_ptr1 = curr_backward->blink;
						temp_mrk = curr_backward->mrk;
						curr_backward = busted;
						curr_backward->flink = temp_ptr;
						curr_backward->blink = temp_ptr1;
						curr_backward->mrk = temp_mrk;
						busted = (struct HSshd_vertex *) HSalloc_struct_from_pool(BUST_LIST);
					}

					dst_ptr = curr_backward->coord;
					src_ptr = lve_vert;
					memcpy( (unsigned char *)dst_ptr,
						(unsigned char *)src_ptr, 3 * sizeof( double ) );

					temp_ptr = curr_forward->flink;
					temp_ptr1 = curr_forward->blink;
					temp_mrk = curr_forward->mrk;
					curr_forward = busted;
					curr_forward->flink = temp_ptr;
					curr_forward->blink = temp_ptr1;
					curr_forward->mrk = temp_mrk;

					dst_ptr = curr_forward->coord;
					src_ptr = rve_vert;
					memcpy( (unsigned char *)dst_ptr,
						(unsigned char *)src_ptr, 3 * sizeof( double ) );

					curr_backward->coord[3] = w0;
					curr_forward->coord[3] = w1;

					dst_ptr = curr_backward->illum.normal;
					src_ptr = temp_ptr2.illum.normal;
					memcpy( (unsigned char *)dst_ptr,
						(unsigned char *)src_ptr, 3 * sizeof( double ) );

					dst_ptr = curr_forward->illum.normal;
					src_ptr = temp_ptr3.illum.normal;
					memcpy( (unsigned char *)dst_ptr,
						(unsigned char *)src_ptr, 3 * sizeof( double ) );

					/* make sure stacked right edge spans >1 scanlines */
					while( FABS(curr_forward->coord[plane_y] - next_vertex->coord[plane_y]) <= ZERO_TOL
						&& (!(curr_forward == maxs[right_face_id])) )
					{
						curr_forward->mrk |= TRAVERSED;
						curr_forward = next_vertex;
						if (rfclockw) next_vertex = next_vertex->flink;
						else next_vertex = next_vertex->blink;
					}

					if( (next_vertex->coord[plane_y] - curr_forward->coord[plane_y]) <= -ZERO_TOL)
					{
						if (rfclockw) {
							curr_forward = curr_forward->blink;
							next_vertex = curr_forward->flink;
						}
						else {
							curr_forward = curr_forward->flink;
							next_vertex = curr_forward->blink;
						}
					}

					rts[++rtop].v0 = curr_forward; 	/* push the current right edge */
					rts[rtop].v1 = next_vertex;
					rfclockw_stk[++rctop] = rfclockw;	/* push clockwise indicator */
					rframe_ptr[++rfptop] = rtop;	/* frame pointer for this hole */
					rhole[++rhtop] = right_face_id; /* push the facet/hole id */
					right_face_id = hole_id[mins_head];
					mins_i_stk[++mtop] = mins_i;
					mins_i = mins_head;

					curr_forward = min_ptr;
					next_vertex = min_ptr->flink;
					temp_ptr = temp_ptr1 = min_ptr;
					min_fptr = min_ptr->blink;
					bflag = fflag = FALSE;
					do {
						/* get rid of horizontal edges */
						while ((FABS(min_ptr->coord[plane_y] - min_fptr->coord[plane_y]) < ZERO_TOL)
							&& (!(min_fptr == curr_forward)))
						{
							if (min_ptr->mrk & A_MIN) min_ptr->mrk |= TRAVERSED;
							min_ptr = min_fptr;
							min_fptr = min_fptr->blink;
							if (!bflag) temp_ptr = min_ptr;
						}

						while((FABS(curr_forward->coord[plane_y] - next_vertex->coord[plane_y]) < ZERO_TOL)
							&& (!(next_vertex == curr_backward)))
						{
							if (curr_forward->mrk & A_MIN) curr_forward->mrk |= TRAVERSED;
							curr_forward = next_vertex;
							next_vertex = next_vertex->flink;
							if (!fflag) temp_ptr1 = curr_forward;
						}
						if (min_fptr->coord[plane_y] < next_vertex->coord[plane_y]) {
							bflag = TRUE;
							y_change = (min_fptr->coord[plane_y] - min_ptr->coord[plane_y])
								    / (next_vertex->coord[plane_y] - min_ptr->coord[plane_y]);
							temp_b = curr_forward->coord[plane_x] + y_change * 
								   (next_vertex->coord[plane_x] - curr_forward->coord[plane_x]);
							rfclockw = temp_b <= min_fptr->coord[plane_x];
							temp_x = min_fptr->coord[plane_x];
							if (FABS(temp_b - temp_x) < ZERO_TOL)
							{
								if (curr_forward->mrk & A_MIN) curr_forward->mrk |= TRAVERSED;
								curr_forward = next_vertex;
								next_vertex = next_vertex->flink;
							}
						}
						if (next_vertex->coord[plane_y] <= min_fptr->coord[plane_y]) {
							fflag = TRUE;
							y_change = (next_vertex->coord[plane_y] - min_ptr->coord[plane_y])
								    / (min_fptr->coord[plane_y] - min_ptr->coord[plane_y]);
							temp_b = min_ptr->coord[plane_x] + 
								   y_change * (min_fptr->coord[plane_x] - min_ptr->coord[plane_x]);
							rfclockw = temp_b >= next_vertex->coord[plane_x];
							temp_x = next_vertex->coord[plane_x];
							if (FABS(temp_b - temp_x) < ZERO_TOL)
							{
								if (min_ptr->mrk & A_MIN) min_ptr->mrk |= TRAVERSED;
								min_ptr = min_fptr;
								min_fptr = min_fptr->blink;
							}
						}
					} while ((FABS(min_fptr->coord[plane_x] - next_vertex->coord[plane_x]) >= ZERO_TOL) &&
						 (FABS(temp_b - temp_x) < ZERO_TOL));
					if (!rfclockw) {
						mins[mins_head] = temp_ptr1;
						mins[mins_head]->mrk |= A_MIN | TRAVERSED;
						curr_forward = temp_ptr;
						next_vertex = temp_ptr->blink;
					}
					else {
						mins[mins_head] = temp_ptr;
						mins[mins_head]->mrk |= A_MIN | TRAVERSED;
						curr_forward = temp_ptr1;
						next_vertex = temp_ptr1->flink;
					}

					if (mins_head == temp_mins_head) temp_mins_head++;

					busted = (struct HSshd_vertex *) HSalloc_struct_from_pool(BUST_LIST);
				}

				if ((min_ptr == curr_forward) ||
				   (min_ptr == curr_backward))
					min_ptr->mrk |= TRAVERSED;
				mins_head++;
				min_ptr = mins[mins_head];
					
			}
						
			mins_head = temp_mins_head;
			
			/* bust and interp */
			if ((!done_busting) && (prev_vertex->coord[plane_y] < next_vertex->coord[plane_y]))
			{
						
				/* calc change in y at bust point */
				y_change = (prev_vertex->coord[plane_y] - curr_forward->coord[plane_y])
					    / (next_vertex->coord[plane_y] - curr_forward->coord[plane_y]);
				/* bust an edge */
				dst_ptr = busted->coord;
				dst_ptr[plane_x] = y_change * (next_vertex->coord[plane_x] - curr_forward->coord[plane_x])
						  + curr_forward->coord[plane_x];
				dst_ptr[plane_y] = prev_vertex->coord[plane_y];
				dst_ptr[plane_z] = y_change * (next_vertex->coord[plane_z] - curr_forward->coord[plane_z])
						  + curr_forward->coord[plane_z];
				dst_ptr[3] = y_change * (next_vertex->coord[3] - curr_forward->coord[3])
						  + curr_forward->coord[3];

				dst_ptr = busted->illum.normal;
				dst_ptr2 = next_vertex->illum.normal;
				dst_ptr3 = curr_forward->illum.normal;
				dst_ptr[0] = y_change * (dst_ptr2[0] - dst_ptr3[0]) + dst_ptr3[0];
				dst_ptr[1] = y_change * (dst_ptr2[1] - dst_ptr3[1]) + dst_ptr3[1];
				dst_ptr[2] = y_change * (dst_ptr2[2] - dst_ptr3[2]) + dst_ptr3[2];

				/* Add triangle(s) to mesh and update facet traversal position 
				   for next bust */
				HSadd_triangle( busted, prev_vertex, curr_backward, curr_forward );

				if (curr_forward->mrk & A_MIN) {
					temp_ptr = curr_forward->flink;
					temp_ptr1 = curr_forward->blink;
					temp_mrk = curr_forward->mrk;
					curr_forward = busted;
					curr_forward->flink = temp_ptr;
					curr_forward->blink = temp_ptr1;
					curr_forward->mrk = temp_mrk;
				}

				if (curr_forward == busted)
					busted = (struct HSshd_vertex *) HSalloc_struct_from_pool(BUST_LIST);
				else
				{
					dst_ptr = curr_forward->coord;
					src_ptr = busted->coord;
					memcpy( (unsigned char *)dst_ptr,
						(unsigned char *)src_ptr, 4 * sizeof( double ) );
					dst_ptr = curr_forward->illum.normal;
					src_ptr = busted->illum.normal;
					memcpy( (unsigned char *)dst_ptr,
						(unsigned char *)src_ptr, 3 * sizeof( double ) );
				}

				/***** stack usage here *****/
				/***** deal with upward pointing edges ****/
				if (ltop == lframe_ptr[lfptop])
				{
					curr_backward->mrk |= TRAVERSED;
					curr_backward = prev_vertex;
					if (lfclockw) prev_vertex = prev_vertex->blink;
					else prev_vertex = prev_vertex->flink;
					if ((prev_vertex->mrk & TRAVERSED) && (ltop > 0))
					{
						left_face_id = lhole[lhtop--];
						lfclockw = lfclockw_stk[lctop--];
						lfptop--;
						if (num_verts) HSsend_mesh();

						curr_backward = lts[ltop].v0;
						prev_vertex   = lts[ltop--].v1;
					}
					else {
 					while ((curr_backward->coord[plane_y] >= prev_vertex->coord[plane_y])
					 	&& (curr_backward != maxs[left_face_id]))
					{
						if( curr_backward->coord[plane_y] - prev_vertex->coord[plane_y] >= ZERO_TOL)
						{
							if (num_verts) HSsend_mesh();

							rts[++rtop].v0 = curr_forward;
							rts[rtop].v1 = next_vertex;
							curr_forward = prev_vertex;
							next_vertex = curr_backward;
							curr_backward = prev_vertex;
							curr_backward->mrk |= TRAVERSED;
							if (lfclockw) prev_vertex = prev_vertex->blink;
							else prev_vertex = prev_vertex->flink;
							if (right_face_id != left_face_id) {
								rhole[++rhtop] = right_face_id;
								right_face_id = left_face_id;
								rfclockw_stk[++rctop] = rfclockw;
								rfclockw = lfclockw;
								if (rtop >= rframe_ptr[rfptop])
									rframe_ptr[++rfptop] = rtop;
							}
						}
						else {
							curr_backward->mrk |= TRAVERSED;
							curr_backward = prev_vertex;
							if (lfclockw) prev_vertex = prev_vertex->blink;
							else prev_vertex = prev_vertex->flink;
						}
					}
					}
				}
				else
				{
					if (ltop < lframe_ptr[lfptop])
					{
						left_face_id = lhole[lhtop--];
						lfclockw = lfclockw_stk[lctop--];
						lfptop--;
					}
					if ((num_verts) && (prev_vertex != lts[ltop].v0)) HSsend_mesh();

					curr_backward = lts[ltop].v0;
					prev_vertex   = lts[ltop--].v1;
				}
				/* left traversal position update */
				if (curr_backward == maxs[left_face_id])
				{
					/* pop the needed info for ancestor hole/facet */
					lfptop--;
					left_face_id = lhole[lhtop--];
					lfclockw = lfclockw_stk[lctop--];
					curr_backward = lts[ltop].v0;
					prev_vertex = lts[ltop--].v1;
					if (num_verts) HSsend_mesh();

					/* deal with leftovers on the right by proceeding
					 * with the tesselation along the same hole on
					 * the right
					 */
				}
			}
			else if ((!done_busting) && (prev_vertex->coord[plane_y] == next_vertex->coord[plane_y]))
			{
				/* No need to bust, use the 2 edges for the trapezoid as they are */
				/* Also update facet traversal position for next bust */
				ylo = curr_backward->coord[plane_y];
				yhi = prev_vertex->coord[plane_y];
				x0 = prev_vertex->coord[plane_x];
				x1 = next_vertex->coord[plane_x];
				x2 = curr_backward->coord[plane_x];

				HSadd_triangle( next_vertex, prev_vertex, curr_backward, curr_forward );

				/***** stack usage here *****/
				/***** deal with upward pointing edges ****/
				if (ltop == lframe_ptr[lfptop])
				{
					curr_backward->mrk |= TRAVERSED;
					if (prev_vertex != next_vertex) 
					{
						curr_backward = prev_vertex;
						if (lfclockw) prev_vertex = prev_vertex->blink;
						else prev_vertex = prev_vertex->flink;
					}
					if ((prev_vertex->mrk & TRAVERSED) && (ltop > 0))
					{
						left_face_id = lhole[lhtop--];
						lfclockw = lfclockw_stk[lctop--];
						lfptop--;
						curr_backward = lts[ltop].v0;
						prev_vertex   = lts[ltop--].v1;
						if (num_verts) HSsend_mesh();
					}
					else {
					/* the '=' portion of the >= test is there to throw
					 * out horizontal lines. This will probably be a place
					 * where fem edge marks will get updated 
					 */
					if (rfclockw) temp_ptr = next_vertex->flink;
					else temp_ptr = next_vertex->blink;
 					while ((curr_backward->coord[plane_y] >= prev_vertex->coord[plane_y])
						&& (curr_backward != maxs[left_face_id])
						&& (prev_vertex != next_vertex))
					{
						if( curr_backward->coord[plane_y] - prev_vertex->coord[plane_y] >= ZERO_TOL )
						{
							if (!(temp_ptr->mrk & TRAVERSED))
							{
								rts[++rtop].v0 = curr_forward;
								rts[rtop].v1 = next_vertex;
								curr_forward = prev_vertex;
								next_vertex = curr_backward;
							}
							else {
								curr_forward = prev_vertex;
								next_vertex = curr_backward;
								rts[++rtop].v0 = curr_forward;
								rts[rtop].v1 = next_vertex;
							}
							if (num_verts) HSsend_mesh();

							curr_backward = prev_vertex;
							curr_backward->mrk |= TRAVERSED;
							if (lfclockw) prev_vertex = prev_vertex->blink;
							else prev_vertex = prev_vertex->flink;
							if (right_face_id != left_face_id) {
								rhole[++rhtop] = right_face_id;
								right_face_id = left_face_id;
								rfclockw_stk[++rctop] = rfclockw;
								rfclockw = lfclockw;
								if (rtop >= rframe_ptr[rfptop])
									rframe_ptr[++rfptop] = rtop;
							}
						}
						else {
							curr_backward->mrk |= TRAVERSED;
							curr_backward = prev_vertex;
							if (lfclockw) prev_vertex = prev_vertex->blink;
							else prev_vertex = prev_vertex->flink;
						}
					}
					}
				}
				else
				{
					if (ltop < lframe_ptr[lfptop]) {
						left_face_id = lhole[lhtop--];
						lfclockw = lfclockw_stk[lctop--];
						lfptop--;
					}
					if ((num_verts) && (prev_vertex != lts[ltop].v0)) HSsend_mesh();

					curr_backward = lts[ltop].v0;
					prev_vertex   = lts[ltop--].v1;
				}

				if ((rtop == rframe_ptr[rfptop]) && (prev_vertex != next_vertex))
				{
					curr_forward->mrk |= TRAVERSED;
					curr_forward = next_vertex;
					if (rfclockw) next_vertex = next_vertex->flink;
					else next_vertex = next_vertex->blink;
					if ((next_vertex->mrk & TRAVERSED) && (rtop > 0))
					{
						right_face_id = rhole[rhtop--];
						rfclockw = rfclockw_stk[rctop--];
						rfptop--;
						curr_forward = rts[rtop].v0;
						next_vertex   = rts[rtop--].v1;
						if (num_verts) HSsend_mesh();
					}
					else {
					while ((curr_forward->coord[plane_y] >= next_vertex->coord[plane_y])
						&& (!(curr_forward == maxs[right_face_id])))
					{
						if( curr_forward->coord[plane_y] - next_vertex->coord[plane_y] >= ZERO_TOL)
						{
							if (num_verts) HSsend_mesh();

							lts[++ltop].v0 = curr_backward;
							lts[ltop].v1 = prev_vertex;
							curr_backward = next_vertex;
							prev_vertex = curr_forward;
							curr_forward = next_vertex;
							curr_forward->mrk |= TRAVERSED;
							if (rfclockw) next_vertex = next_vertex->flink;
							else next_vertex = next_vertex->blink;
							if (left_face_id != right_face_id) {
								lhole[++lhtop] = left_face_id;
								left_face_id = right_face_id;
								lfclockw_stk[++lctop] = lfclockw;
								lfclockw = rfclockw;
								if (ltop >= lframe_ptr[lfptop])
									lframe_ptr[++lfptop] = ltop;
							}
						}
						else {
							curr_forward->mrk |= TRAVERSED;
							curr_forward = next_vertex;
							if (rfclockw) next_vertex = next_vertex->flink;
							else next_vertex = next_vertex->blink;
						}
					}
					}
				}
				else
				{
					curr_forward->mrk |= TRAVERSED;
					if ((rtop > 0) && (curr_forward != curr_backward))
					{
					if (prev_vertex == next_vertex)
					{
						/* reset left traversal position */
						left_face_id = right_face_id;
						curr_backward = mins[mins_i];
						if (lfclockw) prev_vertex = mins[mins_i]->blink;
						else prev_vertex = mins[mins_i]->flink;
						mins_i = mins_i_stk[mtop--];

						/* pop the needed info for ancestor hole/facet to be 
						 * traversed as the right side */
						rfptop--;
						right_face_id = rhole[rhtop--];
						rfclockw = rfclockw_stk[rctop--];
						curr_forward = rts[rtop].v0;
						next_vertex = rts[rtop--].v1;
						if (num_verts) HSsend_mesh();
					}
					else 
					{
						if ((num_verts) && (next_vertex != rts[rtop].v0))
							HSsend_mesh();
						curr_forward = rts[rtop].v0;
						next_vertex   = rts[rtop--].v1;
					}
					}
				}
				if ((curr_forward == maxs[right_face_id]) && 
				    (curr_forward != curr_backward))
				{
					/* deal with leftovers on the left */
					if (curr_backward != maxs[left_face_id]) {
						lts[++ltop].v0 = curr_backward;
						lts[ltop].v1 = prev_vertex;
						lfclockw_stk[++lctop] = lfclockw;
						lframe_ptr[++lfptop] = ltop;
						lhole[++lhtop] = left_face_id;
					}

					/* reset left traversal position */
					left_face_id = right_face_id;
					if (rtop > 0) {
						curr_backward = mins[mins_i];
						if (lfclockw) prev_vertex = mins[mins_i]->blink;
						else prev_vertex = mins[mins_i]->flink;
						mins_i = mins_i_stk[mtop--];

						/* pop the needed info for ancestor hole/facet to be 
						 * traversed as the right side */
						rfptop--;
						right_face_id = rhole[rhtop--];
						rfclockw = rfclockw_stk[rctop--];
						curr_forward = rts[rtop].v0;
						next_vertex = rts[rtop--].v1;
						if (num_verts) HSsend_mesh();
					}
					else	curr_backward = curr_forward;
				}
			}
			else if (!done_busting)
			{
				/* calc change in y at bust point */
				y_change = (next_vertex->coord[plane_y] - curr_forward->coord[plane_y])
					    / (prev_vertex->coord[plane_y] - curr_backward->coord[plane_y]);
				/* bust an edge */
				dst_ptr = busted->coord;
				dst_ptr[plane_x] = y_change * (prev_vertex->coord[plane_x] - curr_backward->coord[plane_x])
						  + curr_backward->coord[plane_x];
				dst_ptr[plane_y] = next_vertex->coord[plane_y];
				dst_ptr[plane_z] = y_change * (prev_vertex->coord[plane_z] - curr_backward->coord[plane_z])
						  + curr_backward->coord[plane_z];
				dst_ptr[3] = y_change * (prev_vertex->coord[3] - curr_backward->coord[3])
						  + curr_backward->coord[3];
				dst_ptr = busted->illum.normal;
				dst_ptr[0] = y_change * (prev_vertex->illum.normal[0] - curr_backward->illum.normal[0])
							     + curr_backward->illum.normal[0];
				dst_ptr[1] = y_change * (prev_vertex->illum.normal[1] - curr_backward->illum.normal[1])
							 + curr_backward->illum.normal[1];
				dst_ptr[2] = y_change * (prev_vertex->illum.normal[2] - curr_backward->illum.normal[2])
							 + curr_backward->illum.normal[2];

				/*
				 * Add triangles to mesh and 
				 * update facet traversal position for next bust 
				 */
				HSadd_triangle( next_vertex, busted, curr_backward, curr_forward );

				if (curr_backward->mrk & A_MIN) {
					temp_ptr = curr_backward->flink;
					temp_ptr1 = curr_backward->blink;
					temp_mrk = curr_backward->mrk;
					curr_backward = busted;
					curr_backward->flink = temp_ptr;
					curr_backward->blink = temp_ptr1;
					curr_backward->mrk = temp_mrk;
				}

				if (curr_backward == busted)
					busted = (struct HSshd_vertex *) HSalloc_struct_from_pool(BUST_LIST);
				else
				{
					dst_ptr = curr_backward->coord;
					src_ptr = busted->coord;
					memcpy( (unsigned char *)dst_ptr,
						(unsigned char *)src_ptr, 4 * sizeof( double ) );
					dst_ptr = curr_backward->illum.normal;
					src_ptr = busted->illum.normal;
					memcpy( (unsigned char *)dst_ptr,
						(unsigned char *)src_ptr, 3 * sizeof( double ) );
				}

				/***** stack usage here *****/
				if (rtop == rframe_ptr[rfptop])
				{
					curr_forward->mrk |= TRAVERSED;
					curr_forward = next_vertex;
					if (rfclockw) next_vertex = next_vertex->flink;
					else next_vertex = next_vertex->blink;
					if ((next_vertex->mrk & TRAVERSED) && (rtop > 0))
					{
						right_face_id = rhole[rhtop--];
						rfclockw = rfclockw_stk[rctop--];
						rfptop--;
						curr_forward = rts[rtop].v0;
						next_vertex   = rts[rtop--].v1;
						if (num_verts) HSsend_mesh();
					}
					else {
					while ((curr_forward->coord[plane_y] >= next_vertex->coord[plane_y])
						&& (!(curr_forward == maxs[right_face_id])))
					{
						if (num_verts) HSsend_mesh();

						if( curr_forward->coord[plane_y] - next_vertex->coord[plane_y] >= ZERO_TOL)
						{
							lts[++ltop].v0 = curr_backward;
							lts[ltop].v1 = prev_vertex;
							curr_backward = next_vertex;
							prev_vertex = curr_forward;
							curr_forward = next_vertex;
							curr_forward->mrk |= TRAVERSED;
							if (rfclockw) next_vertex = next_vertex->flink;
							else next_vertex = next_vertex->blink;
							if (left_face_id != right_face_id) {
								lhole[++lhtop] = left_face_id;
								left_face_id = right_face_id;
								lfclockw_stk[++lctop] = lfclockw;
								lfclockw = rfclockw;
								if (ltop >= lframe_ptr[lfptop])
									lframe_ptr[++lfptop] = ltop;
							}
						}
						else {
							curr_forward->mrk |= TRAVERSED;
							curr_forward = next_vertex;
							if (rfclockw) next_vertex = next_vertex->flink;
							else next_vertex = next_vertex->blink;
						}
					}
					}
				}
				else
				{
					if (rtop < rframe_ptr[rfptop])
					{
						right_face_id = rhole[rhtop--];
						rfclockw = rfclockw_stk[rctop--];
						rfptop--;
					}
					if ((num_verts) && (next_vertex != rts[rtop].v0))
						HSsend_mesh();
					curr_forward = rts[rtop].v0;
					next_vertex   = rts[rtop--].v1;
				}

				/*!!! deal with leftovers and resetting traversal positions */
				if (curr_forward == maxs[right_face_id])
				{
					if (num_verts) HSsend_mesh();

					/* deal with leftovers on the left */
					lts[++ltop].v0 = curr_backward;
					lts[ltop].v1 = prev_vertex;
					lfclockw_stk[++lctop] = lfclockw;
					lframe_ptr[++lfptop] = ltop;
					lhole[++lhtop] = left_face_id;

					/* reset left traversal position */
					left_face_id = right_face_id;
					curr_backward = mins[mins_i];
					lfclockw = rfclockw;
					if (lfclockw) prev_vertex = mins[mins_i]->blink;
					else prev_vertex = mins[mins_i]->flink;
					mins_i = mins_i_stk[mtop--];

					/* pop the needed info for ancestor hole/facet to be 
					 * traversed as the right side */
					rfptop--;
					right_face_id = rhole[rhtop--];
					rfclockw = rfclockw_stk[rctop--];
					curr_forward = rts[rtop].v0;
					next_vertex = rts[rtop--].v1;
				}
			}

			done_busting = done_busting || ( (curr_forward == curr_backward) &&
				( (curr_forward == maxs[hole_id[0]]) || (prev_vertex == next_vertex) )
				&& (left_face_id == right_face_id));

			if (done_busting)
			{
				if (num_verts) HSsend_mesh();
			}
			else {
				done_busting = done_busting || ( (next_vertex == prev_vertex) &&
					(curr_forward->mrk & TRAVERSED) && (rtop == 0) );

				if (done_busting) {
					tri_mesh.verts[num_verts].x = next_vertex->coord[0];
					tri_mesh.verts[num_verts].y = next_vertex->coord[1];
					tri_mesh.verts[num_verts].z = next_vertex->coord[2];
					if( element_parms.facet_type == SMOOTH_SHADE ) {
						tri_mesh.vNorms[num_verts].x = next_vertex->illum.normal[0];
						tri_mesh.vNorms[num_verts].y = next_vertex->illum.normal[1];
						tri_mesh.vNorms[num_verts].z = next_vertex->illum.normal[2];
					}
					num_verts++;
					HSsend_mesh();
				}
			}
			if (done_busting)
			{
				num_verts = 0;
				/*
				 * reset mins array for nested hole processing
				 */
				new_num_mins = 0;
				for (i=1; i < num_mins; i++)
					if (!(mins[i]->mrk & TRAVERSED))
					{
						mins[new_num_mins] = mins[i];
						hole_id[new_num_mins++] = hole_id[i];
					}
				num_mins = new_num_mins;
				if (num_mins != 0)
				{
					/* find clockwise direction */
					next_vertex = mins[0]->flink;
					prev_vertex = mins[0]->blink;
					curr_forward = curr_backward = mins[0];
					do {
					while (FABS(curr_backward->coord[plane_y] - prev_vertex->coord[plane_y]) < ZERO_TOL)
					{
						if (curr_backward->mrk & A_MIN) curr_backward->mrk |= TRAVERSED;
						curr_backward = prev_vertex;
						prev_vertex = prev_vertex->blink;
					}
					while (FABS(curr_forward->coord[plane_y] - next_vertex->coord[plane_y]) < ZERO_TOL)
					{
						if (curr_forward->mrk & A_MIN) curr_forward->mrk |= TRAVERSED;
						curr_forward = next_vertex;
						next_vertex = next_vertex->flink;
					}
					if (prev_vertex->coord[plane_y] < next_vertex->coord[plane_y]) {
						y_change = (prev_vertex->coord[plane_y] - curr_backward->coord[plane_y])
							    / (next_vertex->coord[plane_y] - curr_backward->coord[plane_y]);
						busted->coord[plane_x] = curr_forward->coord[plane_x] + y_change * 
								   (next_vertex->coord[plane_x] - curr_forward->coord[plane_x]);
						rfclockw = busted->coord[plane_x] >= prev_vertex->coord[plane_x];
						temp_x = prev_vertex->coord[plane_x];
						if (FABS(busted->coord[plane_x] - temp_x) < ZERO_TOL)
						{
							if (curr_forward->mrk & A_MIN) curr_forward->mrk |= TRAVERSED;
							curr_forward = next_vertex;
							next_vertex = next_vertex->flink;
						}
					}
					if (next_vertex->coord[plane_y] <= prev_vertex->coord[plane_y]) {
						y_change = (next_vertex->coord[plane_y] - curr_backward->coord[plane_y])
							    / (prev_vertex->coord[plane_y] - curr_backward->coord[plane_y]);
						busted->coord[plane_x] = curr_backward->coord[plane_x] +
								   y_change * (prev_vertex->coord[plane_x] - curr_backward->coord[plane_x]);
						rfclockw = busted->coord[plane_x] <= next_vertex->coord[plane_x];
						temp_x = next_vertex->coord[plane_x];
						if (FABS(busted->coord[plane_x] - temp_x) < ZERO_TOL)
						{
							if (curr_backward->mrk & A_MIN) curr_backward->mrk |= TRAVERSED;
							curr_backward = prev_vertex;
							prev_vertex = prev_vertex->blink;
						}
					}
					} while ((FABS(prev_vertex->coord[plane_x] - next_vertex->coord[plane_x]) >= ZERO_TOL) &&
						 (FABS(busted->coord[plane_x] - temp_x) < ZERO_TOL));

					curr_forward = curr_backward = mins[0];
					if (!rfclockw)
					{
						next_vertex = curr_backward->blink;
						prev_vertex = curr_forward->flink;
					}
					else {
						next_vertex = curr_forward->flink;
						prev_vertex = curr_backward->blink;
					}
					lfclockw = rfclockw;

					ltop = rtop = lhtop = rhtop = lctop = rctop = lfptop = rfptop = mtop = 0;
					right_face_id = left_face_id = hole_id[0];
					mins_head = mins_i = 1;
					done_busting = FALSE;
					lframe_ptr[0] = rframe_ptr[0] = rhole[0] = lhole[0] = 0;
				}
			}
/*
			if( (rtop > 0) && (prev_vertex == next_vertex) && (curr_forward == curr_backward) )
			{
				curr_forward = rts[rtop].v0;
				next_vertex = rts[rtop--].v1;
				num_verts = 0;
			}
*/
		}
	}

	if( num_loops > MAX_LOOPS )
		free( rhole ); /* Free the seven consecutive int arrays */
	if( Vertices > MAX_VERTS )
		free( lts ); /* Free the two consecutive HSshd_vertex arrays */

	free (tri_mesh.verts);
	if (element_parms.facet_type == SMOOTH_SHADE)
		free (tri_mesh.vNorms);

	return(0);
} /* HStessel_facet */
