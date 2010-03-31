
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:42 $
$Locker:  $
*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "wl.h"

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

#include "HStl_global.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HSfem_spt.h"

#include "HSe2_mesher.h"
#include "hsdisplay.h"
#include "HSpr_tiler_f.h"

/*---------------------------
 *  for function
 *     HSdisplay_fb_NOFPE
 */
 
#include "HSpr_driver.h"

/*----------------------------__*/


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

/* HStl_facet.c */
static struct HSloop *alloc_loop __((		      void));
static void dispose_loop_list __((	struct HSloop *loop_addr));
#if DEBUG_FACET
static void HSdump_facet __((		struct HSloop *facet, char *title));
#endif
static void HSset_planar_z __((		struct HSloop *facet));
static int HSfacet_closed __((		struct HSloop *facet));
static void HSappend_facet __((			      void));


#if defined(__cplusplus)
}
#endif


#undef __



void		process_facet();

#define DISPLAY_DEBUG	0
#define	DEBUG_FACET	0

#define SURF_ALLOC_CHECKS	1

/*
 * local variables
 */

static struct HSvertex		*prev_point = NIL_VERTEX;
static struct HSvertex		*this_point = NIL_VERTEX;
static struct HSvertex		*first_point = NIL_VERTEX;
static struct HSloop		*facet = NIL_LOOP;
static struct HSloop		*new_facet = NIL_LOOP;
static struct HSloop		*this_loop = NIL_LOOP;
static struct HSloop		*prev_loop = NIL_LOOP;
static struct HSvertex		*free_vertex_pool = NIL_VERTEX;
static struct HSloop		*free_loop_pool	= NIL_LOOP;

/*
 * memory management routines
 */

/*---alloc_vertex----------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	struct HSvertex		*alloc_vertex(void)
#else
	struct HSvertex		*alloc_vertex()
#endif

/*
 * Allocates an HSvertex structure from the free storage pool by returning
 * its address.  If the free pool is empty, malloc gets more space.
 *
 * HISTORY: 09/01/86 created		S. A. Rapa
 */

	{
	struct HSvertex		*free_area;
	struct HSvertex		*pool_ptr;
	static IGRint		alloc_size = 20;
	IGRint			count;

	if( free_vertex_pool == NIL_VERTEX )
		{

		/*
		 * Initially allocates the free storage pool with space for 20
		 * vertices & normals.  Subsequent storage allocations 
		 * will increase the free storage pool by 5 times its current
		 * size (i.e. total size = 20 --> 100 --> 500 --> ...).
		 */

#		if DEBUG_MEM
			printf ("** HSxform is enlarging the free vertex pool.\n");
#		endif

#		if DISPLAY_DEBUG
			printf( "In alloc_vertex and about to alloc\n" );
#		endif

		free_vertex_pool = (struct HSvertex *)
			malloc( (unsigned)(alloc_size * sizeof(struct HSvertex)) );

		if ( ! free_vertex_pool ) {
			HSset_status( HSSTAT_ALLOC_ERROR );
			return ( (struct HSvertex *)NULL );
		}			

		/*
		 * Free storage pool is a contiguous chunk of vertex records. 
		 * Initialize the "next" field  of each record with the starting
		 * address of the next one to make a linked list.
		 */

		pool_ptr = free_vertex_pool;
		
		for( count=1; count<alloc_size; count++ ) 
			{
			pool_ptr->next = (struct HSvertex *)(pool_ptr + 1);
			pool_ptr++;
			}
			
		pool_ptr->next = NIL_VERTEX;

		/*
		 *  Commented this line out because we want to try a fixed alloc_size.
		 *	  ML on 4-6
		 */
		 
		/*alloc_size = alloc_size * 4;*/	/* space to allocate next time	*/
		}

	free_area = free_vertex_pool;
	free_vertex_pool = free_vertex_pool->next;
	return(free_area);
	}

/*---dispose_vertex---------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void	dispose_vertex( struct HSvertex *vertex_addr )
#else
	void	dispose_vertex( vertex_addr )

	struct HSvertex		*vertex_addr;	/* input - ptr to a struct in the list	*/
#endif

/*
 * Attaches a single HSvertex structure
 * to the free storage pool, thereby reclaiming the memory.
 *
 * HISTORY: 01/02/87 created		S. A. Rapa
 */

	{
	vertex_addr->next = free_vertex_pool;
	free_vertex_pool = vertex_addr;
	}

/*---dispose_vertex_list----------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void	dispose_vertex_list( struct HSvertex *vertex_addr )
#else
	void	dispose_vertex_list( vertex_addr )

	struct HSvertex		*vertex_addr;	/* input - ptr to a struct in the list	*/
#endif

/*
 * Attaches a circularly linked list of HSvertex structures
 * to the free storage pool, thereby reclaiming the memory.
 *
 * HISTORY: 09/01/86 created		S. A. Rapa
 */

	{
	struct HSvertex		*point;

	point = vertex_addr->next;
	vertex_addr->next = free_vertex_pool;
	free_vertex_pool = point;
	}

/*---alloc_loop------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static struct HSloop	*alloc_loop(void)
#else
	static struct HSloop	*alloc_loop()
#endif

/*
 * Allocates an HSloop structure from the free storage pool by returning
 * its address.  If the free pool is empty, malloc gets more space.
 *
 * HISTORY: 09/01/86 created		S. A. Rapa
 */

	{
	struct HSloop	*free_area;
	struct HSloop	*pool_ptr;
	static IGRint	alloc_size = 5;
	IGRint		count;

	if( free_loop_pool == NIL_LOOP )
		{
			
		/*
		 * Initially allocates the free storage pool with space for 5
		 * loops.  Subsequent storage allocations 
		 * will increase the free storage pool by 5 times its current
		 * size (i.e. total size = 20 --> 100 --> 500 --> ...).
		 */

#if DEBUG_MEM
		printf ("** HSxform is enlarging the free loop pool.\n");
#endif

#if DISPLAY_DEBUG
		printf( "In alloc_loop and about to alloc\n" );
#endif
		free_loop_pool = (struct HSloop *)
			malloc( (unsigned)(alloc_size * sizeof (struct HSloop)) );

		if ( ! free_loop_pool ) {
			HSset_status( HSSTAT_ALLOC_ERROR );
			return ( (struct HSloop *)NULL );
		}

		/*
		 * Free storage pool is a contiguous chunk of loop records. 
		 * Initialize the "next" field  of each record with the starting
		 * address of the next one to make a linked list.
		 */

		pool_ptr = free_loop_pool;
		
		for( count=1; count<alloc_size; count++ )
			{
			pool_ptr->next = (struct HSloop *)(pool_ptr + 1);
			pool_ptr++;
			}
			
		pool_ptr->next = NIL_LOOP;

		/*
		 *  Commented this line out because we was to try a fixed alloc_size.
		 *	  ML on 4-6
		 */
		 
		/*alloc_size = alloc_size * 4;*/	/* space to allocate next time	*/
		}

	free_area = free_loop_pool;
	free_loop_pool = free_loop_pool->next;
	return( free_area );
	}

/*---dispose_loop_list------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void	dispose_loop_list( struct HSloop *loop_addr )
#else
	static void	dispose_loop_list( loop_addr )

	struct HSloop	*loop_addr;	/* input - ptr to 1st struct in list	*/
#endif

/*
 * Attaches a linked list of HSloop structures
 * to the free storage pool, thereby reclaiming the memory.
 *
 * HISTORY: 09/01/86 created		S. A. Rapa
 */

	{
	struct HSloop	*prev;

	prev = loop_addr;
	
	while( prev->next != NIL_LOOP ) prev = prev->next;
	prev->next = free_loop_pool;
	free_loop_pool = loop_addr;
	}


/*-- dispose_facet ----------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void dispose_facet( struct HSloop *facet )
#else
	void dispose_facet( facet )

	struct
	   HSloop	*facet;
#endif

{
struct HSloop	*save_facet;

	save_facet = facet;
	while (facet != NIL_LOOP)
	   {
	   if (facet->loop)
	      dispose_vertex_list (facet->loop);
	   facet = facet->next;
	   }
	dispose_loop_list (save_facet);
}

/*
 * toss_current_facet() is necessary because the variable 'facet' is static (defined in this file only)
 * and HSdisplay_fb_NOFPE needed to free the memory in the associated facet if
 * memory was used up.
 *
 * HISTORY: 12/14/89	Created
 *								Trevor Mink
 */

#if SURF_ALLOC_CHECKS
#if defined(__STDC__) || defined(__cplusplus)
	void toss_current_facet(void)
#else
	void toss_current_facet()
#endif
	{
	dispose_facet( facet );
	}
#endif

#if DEBUG_MEM
/*---check_memory-----------------------------------------------------------*/

void	check_memory()

/*
 * Counts the number of free structures in the free storage pools.
 * Used to verify that all storage is being recycled properly.
 *
 * HISTORY: 09/01/86 created		S. A. Rapa
 */

	{
	IGRint			cnt;
	struct HSvertex		*v;
	struct HSloop		*l;

	cnt = 0;
	v = free_vertex_pool;
	
	while( v != NIL_VERTEX )
		{
		v = v->next;
		cnt++;
		}
		
	printf ("HSxform vertex storage pool size = %d \n", cnt);

	cnt = 0;
	l = free_loop_pool;
	
	while( l != NIL_LOOP )
		{
		l = l->next;
		cnt++;
		}
		
	printf ("HSxform loop storage pool size = %d \n", cnt);
	}
#endif

/*
 * facet building routines
 */

/*---add_vertex_to_loop-----------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void add_vertex_to_loop( IGRdouble x, 
				 IGRdouble y, 
				 IGRdouble z, 
				 IGRdouble w, 
				IGRboolean e, 
				 IGRdouble nx, 
				 IGRdouble ny, 
				 IGRdouble nz, 
				 IGRdouble u, 
				 IGRdouble v )
#else
	void add_vertex_to_loop( x, y, z, w, e, nx, ny, nz, u, v )

	IGRdouble	x, y, z, w;
	IGRboolean	e;
	IGRdouble	nx, ny, nz;
	IGRdouble	u, v;
#endif

/*
 * Adds a vertex (with normals if smooth shading) to the current loop of
 * the current facet.  If no loop or facet is active, then they are
 * established.
 *
 * HISTORY: 02/07/87 Created.				S. A. Rapa
 *          05/15/89 Added edge mark.			C. M. Jablonski
 */

	{
	this_point = alloc_vertex();

	if ( tiling_parms.status == HSSTAT_ALLOC_ERROR ) return;

	this_point->coord[0] = x;
	this_point->coord[1] = y;
	this_point->coord[2] = z;
	this_point->coord[3] = w;
	this_point->edge_flag = e;

	this_point->u = u;
	this_point->v = v;

	if( element_parms.doing_vertex_normals )
		{
		this_point->norm[0]  = nx;
		this_point->norm[1]  = ny;
		this_point->norm[2]  = nz;
		}
	else
		this_point->norm[0]  = 0.0;	/* prevents shade interp. problems in pbust */

	if( prev_point )
		prev_point->next = this_point;
	else
		first_point = this_point;
		
	prev_point = this_point;
	}

/*---add_fem_vertex_to_loop-----------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void add_fem_vertex_to_loop( IGRdouble x, 
				     IGRdouble y, 
				     IGRdouble z, 
				     IGRdouble w, 
				     IGRdouble u, 
				     IGRdouble v, 
				      IGRshort pct, 
				    IGRboolean edge_mark )
#else
	void add_fem_vertex_to_loop( x, y, z, w, u, v, pct, edge_mark )

	IGRdouble	x, y, z, w, u, v;
	IGRshort	pct;
	IGRboolean	edge_mark;
#endif

/*
 * Adds a FEM vertex to the current loop of the current facet.
 * If no loop or facet is active, then they are established.
 *
 * HISTORY: 03/20/89 Created.				C. M. Jablonski
 */

	{
	this_point = alloc_vertex();

	if( tiling_parms.status == HSSTAT_ALLOC_ERROR ) return;

	this_point->coord[0] = x;
	this_point->coord[1] = y;
	this_point->coord[2] = z;
	this_point->coord[3] = w;
	this_point->norm[0] = u;
	this_point->norm[1] = v;
	this_point->percent = pct;
	this_point->edge_flag = edge_mark;

	if( prev_point )
		prev_point->next = this_point;
	else
		first_point = this_point;
		
	prev_point = this_point;
	}

/*---add_fem_vertexII-----------------------------------------------*/

void add_fem_vertexII( struct fem_vert vertex, 
					 float red,
					 float green,
					 float blue)

/* This function is used add a vertex to the current loop for a given 
 * fem facet (uses triangular FEM meshes).
 * If no loop or facet is active, then they are established.
 *
 * HISTORY: 05/17/91 Created.				R. Druzynski
 */
 
{this_point = alloc_vertex();		/* allocate memory for vertex */
 
 this_point->coord[0] = (IGRdouble)vertex.x;	/* assign data to vertex */
 this_point->coord[1] = (IGRdouble)vertex.y;
 this_point->coord[2] = (IGRdouble)vertex.z;
 
 this_point->norm[0] = (IGRdouble)red;		/* assign rgb values to the normal */
 this_point->norm[1] = (IGRdouble)green;	/* to be linearly interpolated just */
 this_point->norm[2] = (IGRdouble)blue;		/* as the normals are */

 if (prev_point)				/* if not first vertex */
	prev_point->next = this_point;
 else
	first_point = this_point;

 prev_point = this_point;
}


/*---end_facet_loop---------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void		end_facet_loop(void)
#else
	void		end_facet_loop()
#endif

/*
 * Ends the current facet loop so that any new calls to "add_vertex..."
 * will add points to a new one.
 *
 * HISTORY: 02/07/87 Created.				S. A. Rapa
 */

	{
	if( prev_point )
		{
		prev_point->next = first_point;

		this_loop = alloc_loop();

		if ( tiling_parms.status == HSSTAT_ALLOC_ERROR ) return;

		if( facet == NIL_LOOP )
			facet = this_loop;
		else
			prev_loop->next = this_loop;

		this_loop->next = NIL_LOOP;
		this_loop->loop = first_point;
		prev_point = NIL_VERTEX;
		prev_loop = this_loop;
		}
	}


/*---construct_facet---------------------------------------------------------*/

/*
 * Adds a vertex to the current loop of the current facet being
 * constructed.
 *
 * HISTORY: 09/01/86 created				S. A. Rapa
 *	    02/07/87 No longer writes to pipe; calls	S. A. Rapa
 *		     "add_vertex..." instead.
 *          05/15/89 Added edge mark.			C. M. Jablonski
 */

#if defined(__STDC__) || defined(__cplusplus)
	void construct_facet( IGRpoint *pnts, 
				IGRint index, 
				IGRint offset, 
			    IGRboolean edge_mark, 
			     IGRdouble u, 
			     IGRdouble v )
#else
	void construct_facet( pnts, index, offset, edge_mark, u, v )

	IGRpoint	*pnts;		/* input - point coordinates */
	IGRint		index;		/* input - index into arrays */
	IGRint		offset;		/* input - normal & w offset */
	IGRboolean	edge_mark;	/* input - edge mark */
	IGRdouble	u, v;
#endif

	{
	IGRdouble	*w;
	IGRpoint	*norm;

	w = pnts[offset + offset];

	if( element_parms.doing_vertex_normals )
		{
		norm = pnts + offset;
		
		(*active_window->add_vertex[active_window->active_zbuffer])(
			pnts[index][0], pnts[index][1], pnts[index][2],
			w[index], edge_mark,
			norm[index][0], norm[index][1], norm[index][2],
			u, v );
		}
	else
		{
		(*active_window->add_vertex[active_window->active_zbuffer])(
			pnts[index][0], pnts[index][1], pnts[index][2],
			w[index], edge_mark,
			u, v,
			0.0, 0.0, 0.0 );
		}
	}


#ifndef MICROCODE
/*---construct_fem_facet---------------------------------------------------------*/

/*
 * Adds a vertex to the current loop of the current facet being constructed.
 *
 * HISTORY: 	03/20/89  Created.				C. M. Jablonski
 */

#if defined(__STDC__) || defined(__cplusplus)
	void construct_fem_facet( IGRpoint *pnts, 
				    IGRint index, 
				 IGRdouble u, 
				 IGRdouble v, 
				  IGRshort shade, 
				IGRboolean edge_mark, 
				    IGRint offset )
#else
	void construct_fem_facet( pnts, index, u, v, shade, edge_mark, offset )

	IGRpoint	*pnts;		/* input - point coordinates */
	IGRint		index;		/* input - index into arrays */
	IGRdouble	u, v;		/* input - uv values of vertex */
	IGRshort	shade;		/* input - vertex shade */
	IGRboolean	edge_mark;	/* input - the edge mark for this vertex */
	IGRint		offset;		/* input - w offset */
#endif

	{

	IGRdouble	*w;

	w = pnts[offset];

	add_fem_vertex_to_loop(
			pnts[index][0], pnts[index][1], pnts[index][2],
			w[index], u, v, shade, edge_mark );
	}


/*---HScreate_fem_facetII--------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HScreate_fem_facetII( struct fem_vert *vertices, 
				  struct fem_color *colors, 
					IGRboolean solid_shade )
#else
	void HScreate_fem_facetII( vertices, colors, solid_shade )
 
	struct fem_vert		*vertices;	/* pointer to first vertex of facet */
	struct fem_color	*colors;	/* pointer to color list */
	IGRboolean		solid_shade;	/* variable to tell how many color 
						   indices to use */
#endif

/* This function is used to create a FEM facet that can be used by the 
 * shading functions for display.  Since all FEM facets are triangles,
 * this function will use the first three data values for the vertices 
 * 
 * HISTORY:	05/17/91  Created.			R. Druzynski
 */

{
 if (solid_shade)		/* facet vertices all have same color index */
	{add_fem_vertexII(vertices[0], colors[0].red, colors[0].green, colors[0].blue);
	 add_fem_vertexII(vertices[1], colors[0].red, colors[0].green, colors[0].blue);
	 add_fem_vertexII(vertices[2], colors[0].red, colors[0].green, colors[0].blue);
	}
 else				/* facet vertices have different indices */
	{add_fem_vertexII(vertices[0], colors[0].red, colors[0].green, colors[0].blue);
	 add_fem_vertexII(vertices[1], colors[1].red, colors[1].green, colors[1].blue);
	 add_fem_vertexII(vertices[2], colors[2].red, colors[2].green, colors[2].blue);
	}
}

#endif


#if DEBUG_FACET
/*---HSdump_facet------------------------------------------*/

/*
NAME
	HSdump_facet: static
	
KEYWORDS
	static
	debug
	
DESCRIPTION
	Display contents fo loop
	
HISTORY
	05/20/92	M. Lanier
		Created
*/

static void	HSdump_facet( facet, title )

struct HSloop	*facet;
char		*title;

	{
	struct HSvertex	*vertex, *stopv = NULL;
	struct HSloop	*f;
		
	f = facet;
	fprintf( stderr, "*** %s ***************************************\n", title );
	while( f != NULL )
		{
		stopv = vertex = f->loop;
		fprintf( stderr, "  addr        x          y          z\n" );
		fprintf( stderr, "-------- ---------- ---------- ----------\n" );
		do
			{
			fprintf( stderr, "%8x %10.4f %10.4f %10.4f\n",
				vertex, 
				vertex->coord[0], 
				vertex->coord[1], 
				vertex->coord[2] );

			vertex = vertex->next;
			}
		while( vertex != stopv );
		
		fprintf( stderr, "\n" );
		
		f = f->next;
		}
	}
#endif
	
static double	active_pvhl_z;

/*---HSset_pvhl_z--------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void	HSset_pvhl_z( int z )
#else
	void	HSset_pvhl_z( z )

	int	z;
#endif

	{
	active_pvhl_z = (double)z;
	}

/*---HSset_planar_z------------------------------------------*/

/*
NAME
	HSdset_planar_z: static
	
KEYWORDS
	static
	debug
	
DESCRIPTION
	
HISTORY
	05/28/92	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HSset_planar_z( struct HSloop *facet )
#else
	static void HSset_planar_z( facet )

	struct HSloop	*facet;
#endif

	{
	struct HSvertex	*vertex, *stopv = NULL;
	struct HSloop	*f;
		
		
	/*
	 *  Get the average z from the outer loop
	 */
	 
	f = facet;
	while( f != NULL )
		{
		stopv = vertex = f->loop;
		do
			{
			vertex->coord[2] = active_pvhl_z;
			vertex = vertex->next;
			}
		while( vertex != stopv );
		
		f = f->next;
		}
	}

/*---HSfacet_closed------------------------------------------*/

/*
NAME
	HSfacet_closed: static
	
KEYWORDS
	static
	facet
	pseudo vhl
	
DESCRIPTION
	Check to see if a facet is closed by comparing the first and
	last vertex of the loop to see if they are equal
	
PARAMETERS
	facet	:(IN) : pointer to the facet loops
	
HISTORY
	05/20/92	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	static int HSfacet_closed( struct HSloop *facet )
#else
	static int HSfacet_closed( facet )

	struct HSloop	*facet;
#endif

	{
	struct HSvertex	*vertex, *stopv = NULL;
	int		closed;

	closed = 1;
	this_loop = facet;
	while( this_loop != NIL_LOOP )
		{
		stopv = vertex = this_loop->loop;
		
		/*
		 *  If the first vertex is the same as the 
		 *  next, then the loop has only one vertex
		 *  and cannot be closed
		 */
		 
		if( vertex->next == vertex )
			{
			return( 0 );
			}
		
		/*
		 *  Loop down to the last vertex.  If any of
		 *  the three coordinates are not equal, then the
		 *  loop is not closed
		 */
		 	
		while( vertex->next != stopv )
			vertex = vertex->next;
	
		if( fabs(vertex->coord[0]-stopv->coord[0]) > 0.00001 ||
		    fabs(vertex->coord[1]-stopv->coord[1]) > 0.00001 ||
		    fabs(vertex->coord[2]-stopv->coord[2]) > 0.00001 )
			{
fprintf( stderr, "vertex, stopv: %x %x\n", vertex, stopv );
fprintf( stderr, "   %f %f %f\n", vertex->coord[0], vertex->coord[1], vertex->coord[2] );
fprintf( stderr, "   %f %f %f\n", stopv->coord[0], stopv->coord[1], stopv->coord[2] );
fprintf( stderr, "   %lf %lf %lf\n",  vertex->coord[0]-stopv->coord[0],  vertex->coord[1]-stopv->coord[1],  vertex->coord[2]-stopv->coord[2] );
			return( 0 );
			}

		this_loop = this_loop->next;
		}
		
	return( 1 );
	}

static struct HSvertex	*newv = NULL;
static struct HSloop	*lastf = NULL;

/*---HSappend_facet--------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HSappend_facet(void)
#else
	static void HSappend_facet()
#endif
	{
	struct HSvertex		*vertex, *stopv, *lastv;

	if( tiling_parms.processing_mode & HS_PMODE_PVHL_OBJECT_BEGIN )
		{
		new_facet = alloc_loop();
		new_facet->loop = NULL;
		new_facet->next = NULL;
		lastf = new_facet;
		newv = NULL;
		}
	else
		{
		if( tiling_parms.processing_mode & HS_PMODE_PVHL_NEW_LOOP )
			{
			lastf->next = alloc_loop();
			lastf = lastf->next;
			lastf->loop = NULL;
			lastf->next = NULL;
			newv = NULL;
			}
		}
		
	stopv = vertex = facet->loop;

	/*
	 *  if the first vertex of the loop is equal to the last
	 *  vertex, skip.
	 */
	 
	if( newv != NULL )
	if( fabs( newv->coord[0] - vertex->coord[0] ) < 0.0001 &&
	    fabs( newv->coord[1] - vertex->coord[1] ) < 0.0001 &&
	    fabs( newv->coord[2] - vertex->coord[2] ) < 0.0001 )
		{
			
		/*
		 *  If the next vertex is the same as the first, then
		 *  the loop has only one vertex, and therefore, nothing
		 *  to add.  return now.  Otherwise, skip the first vertex
		 */
		 
		if( vertex == vertex->next ) return;
		
		vertex = vertex->next;
		}
		
	do
		{
		lastv = newv;
		
		newv = alloc_vertex();
		
		newv->coord[0] = vertex->coord[0];
		newv->coord[1] = vertex->coord[1];
		newv->coord[2] = vertex->coord[2];
		newv->coord[3] = vertex->coord[3];
		newv->norm[0]  = vertex->norm[0];
		newv->norm[1]  = vertex->norm[1];
		newv->norm[2]  = vertex->norm[2];
		newv->u        = vertex->u;
		newv->v        = vertex->v;
		newv->edge_flag= vertex->edge_flag;
		newv->percent  = vertex->percent;
		
		if( lastv == NULL )
			lastf->loop = newv;
		else
			lastv->next = newv;
			
		newv->next = lastf->loop;
		
		vertex = vertex->next;
		}
	while( vertex != stopv );
	}
	
/*---clip_and_shade--------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void clip_and_shade(void)
#else
	void clip_and_shade()
#endif

/*
 * Closes the active loop for the current facet, then calls a function
 * which will take this facet, clip it, shade it, and send it to the
 * polybuster.
 *
 * HISTORY:	02/07/87 Created.				S. A. Rapa
 *		04/19/88 Made change to support feedback.	C. M. Jablonski
 */

	{
#	if DISPLAY_DEBUG
		fprintf( stderr, "Entering clip_and_shade\n" );
#	endif

	if( prev_point ) end_facet_loop();

	if( tiling_parms.status != HSSTAT_OK ) return;

	/*
	 *  If the processing mode is RHL/LVHL SURFACES and PVHL display,
	 *  then collect loops
	 */
	 
#	if DEBUG_FACET
	fprintf( stderr, "***clip and shade***\n" );
	if( tiling_parms.processing_mode & HS_PMODE_PVHL_SURFACE )
		fprintf( stderr, "HS_PMODE_PVHL_SURFACE\n " );
	if( tiling_parms.processing_mode & HS_PMODE_PVHL_EDGES )
		fprintf( stderr, "HS_PMODE_PVHL_EDGES\n " );
	if( tiling_parms.processing_mode & HS_PMODE_LVHL_SURFACE )
		fprintf( stderr, "HS_PMODE_LVHL_SURFACE\n " );
	if( tiling_parms.processing_mode & HS_PMODE_LVHL_EDGES )
		fprintf( stderr, "HS_PMODE_LVHL_EDGES\n " );
	if( tiling_parms.processing_mode & HS_PMODE_RHL_SURFACE )
		fprintf( stderr, "HS_PMODE_RHL_SURFACE\n " );
	if( tiling_parms.processing_mode & HS_PMODE_RHL_EDGES )
		fprintf( stderr, "HS_PMODE_RHL_EDGES\n " );
	if( tiling_parms.processing_mode & HS_PMODE_PVHL_OBJECT_BEGIN )
		fprintf( stderr, "HS_PMODE_PVHL_OBJECT_BEGIN\n " );
	if( tiling_parms.processing_mode & HS_PMODE_PVHL_OBJECT_END )
		fprintf( stderr, "HS_PMODE_PVHL_OBJECT_END\n " );
	if( tiling_parms.processing_mode & HS_PMODE_PVHL_NEW_LOOP )
		fprintf( stderr, "HS_PMODE_PVHL_NEW_LOOP\n" );
	fprintf( stderr, "\n" );
#	endif

	if( (tiling_parms.processing_mode & (HS_PMODE_RHL_SURFACE | HS_PMODE_LVHL_SURFACE )) &&
	    (element_parms.facet_type == POLYLINE) )
		{

		/*
		 *  If the object was a non-composite without holes, then send
		 *  now
		 */
		 
		if( tiling_parms.processing_mode & HS_PMODE_PVHL_OBJECT_BEGIN &&
		    tiling_parms.processing_mode & HS_PMODE_PVHL_OBJECT_END )
			{
			element_parms.facet_type = RASTER_EDGES;

			if( facet && HSfacet_closed( facet ) )
				{
				HSset_planar_z( facet );

#				if DEBUG_FACET
				HSdump_facet( facet, "simple pvhl loop" );
#				endif

				(*active_window->process_facet)( facet );
				}
			}
		else
			{
				
			/*
			 *  add the new facet to the accumulated facet
			 */
			 
			HSappend_facet();

#			if DEBUG_FACET
			HSdump_facet( facet, "facet segment" );
			HSdump_facet( new_facet, "updated facet" );
#			endif

			/*
			 *  if this is the last segment of the last object, then
			 *  send to the tiler
			 */
			 
			if( tiling_parms.processing_mode & HS_PMODE_PVHL_OBJECT_END )
				{
				element_parms.facet_type = RASTER_EDGES;

				if( new_facet && HSfacet_closed( new_facet ) )
					{
					HSset_planar_z( new_facet );

#					if DEBUG_FACET
					HSdump_facet( new_facet, "pvhl loop" );
#					endif

					(*active_window->process_facet)( new_facet );
					}

				dispose_facet( new_facet );
				}
			}
		}
	else
		{
		if( facet )
			{
			if( tiling_parms.processing_mode & HS_PMODE_PVHL_EDGES )
				HSset_planar_z( facet );
				
#			if DEBUG_FACET
			HSdump_facet( facet, "regular loop" );
#			endif

			(*active_window->process_facet)( facet );
			}
		}
	
	dispose_facet( facet );		
	facet = NIL_LOOP;

#	if DISPLAY_DEBUG
		fprintf( stderr, "Exiting clip_and_shade\n" );
#	endif
	}
