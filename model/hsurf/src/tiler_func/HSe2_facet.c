/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:41 $
$Locker:  $
*/

#include <stdio.h>
#include "igrtypedef.h"

#include "wl.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"

#include "hstiler.h"
#include "hslight.h"
#include "hsmath.h"
#include "hsdisplay.h"

#include "HStl_window.h"
#include "HStl_element.h"
#include "HStl_global.h"
#include "HSe2_mesher.h"
#include "HSfem_spt.h"
#include "HSd_fixedpt.h"

/***
#include "bsparameters.h"
***/


#include "HSpr_tiler_f.h"

/*--------------------------
 *  for functions
 *    HSalloc_edge
 *    HSfree_edge
 *    HSprocess_tri_facet
 *    PrintFacet
 */
 
#include "HSpr_pbust_f.h"

/*--------------------------*/


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

/* HSe2_facet.c */
static void HScleanup_triangulator_structures __((void));

static void PrintFacet __((void));

static int CheckForDups __((struct HStri_loop *Loop, 
			   struct HStri_vertex *vertex_list, 
					   int PlanarX, 
					   int PlanarY, 
					   int PlanarZ));



#if defined(__cplusplus)
}
#endif


#undef __


static int LoopVertices = 0;

static struct HStri_vertex *PrevPoint = (struct HStri_vertex *)NULL;
static struct HStri_vertex *ThisPoint = (struct HStri_vertex *)NULL;
static struct HStri_vertex *FirstPoint = (struct HStri_vertex *)NULL;
static struct HStri_loop *Facet = (struct HStri_loop *)NULL;
static struct HStri_loop *ThisLoop = (struct HStri_loop *)NULL;
static struct HStri_loop *PrevLoop = (struct HStri_loop *)NULL;

static struct HSbufptr *vertex_buffer_list = NIL_BUFPTR; /* vertex buffer list */
static struct HSbufptr *bound_buffer_list = NIL_BUFPTR; /* bound buffer list */
static struct HSbufptr *ptr_buffer_list = NIL_BUFPTR; /* Ptr buffer list */


#define	HS_60KB		61440		/* sixty kilobytes: the "magic size" */
#define	HS_4KB		4096		/* four kilobytes: the other "magic size" */
#define	NUM_VERTICES_IN_60KB	HS_60KB / sizeof (struct HStri_vertex)
					/* number of points in 60kb of memory */
#define	NUM_BOUNDS_IN_4KB	HS_4KB / sizeof (struct HStri_loop)
					/* number of bounds in 4kb of memory */
#define	NUM_PTRS_IN_4KB		HS_4KB / sizeof (struct PolygonVert)
					/* number of Mono-polygon pointers in 4kb of memory */

#define EDGEII_DEBUG	0
#define FACET_DEBUG	0
#define TRIMESH_DEBUG	0
#define MALLOC_DEBUG    0
#define DEBUG		0

#define OLD_TRIANG	0

#if MALLOC_DEBUG

char *DEBUG_Malloc(
    int num_bytes )

{
	char *address_of_malloced;

	address_of_malloced = (char *)malloc( num_bytes );
	fprintf( stderr, "Malloced %d bytes at address %x\n", num_bytes, address_of_malloced );
	return( address_of_malloced );
} /* DEBUG_Malloc */

void DEBUG_Free(
    char *address_of_freement )

{
	fprintf( stderr, "Freed memory at address %x\n", address_of_freement );
	free( address_of_freement );
} /* DEBUG_Free */

#define malloc	DEBUG_Malloc
#define free	DEBUG_Free
#endif

static struct HStri_vertex **VertArray_static = (struct HStri_vertex **)NULL;

/*
 * HSgetArray() allocates a ONE_K long array of pointers to edge2 vertices and
 * keeps it around. If a bigger one is needed, it is malloced, and freed later.
 * It returns the beginning address of the appropriate array.
 *
 * HISTORY: 01/23/90	Created.
 *								Trevor Mink
 */

struct HStri_vertex **HSgetArray(
   int TotalVertices )

{
	struct HStri_vertex **ArrayOfVertices;

	if( !VertArray_static )
		VertArray_static = (struct HStri_vertex **)malloc( ONE_K * sizeof( struct HStri_vertex *) );

	if( TotalVertices > ONE_K )
		ArrayOfVertices = (struct HStri_vertex **)malloc( TotalVertices * sizeof( struct HStri_vertex *) );
	else
		ArrayOfVertices = VertArray_static;

	return( ArrayOfVertices );

} /* HSgetArray */

/*
 * alloc_VertPtr() allocates a monotonic vertex and returns a pointer to it.
 *
 * HISTORY: 02/06/90	Created.
 *								Trevor Mink
 */

struct PolygonVert *HSalloc_VertPtr(
   void)

{
   struct PolygonVert *this_ptr;
   struct HSbufptr *this_buffer;

   if ((ptr_buffer_list != NIL_BUFPTR) && (ptr_buffer_list->num_left > 0))
    {
      /* get the ptr from the current buffer */
      this_ptr = (struct PolygonVert *)ptr_buffer_list->ele_ptr;
      ptr_buffer_list->ele_ptr += ptr_buffer_list->ele_size;
      ptr_buffer_list->num_left--;
    }
  else
    {
      /* allocate the structures for a new buffer */
      if ((this_buffer = (struct HSbufptr *) malloc (sizeof(struct HSbufptr))) &&
          (this_buffer->buffer = (char *) malloc (NUM_PTRS_IN_4KB * sizeof(struct PolygonVert))))
       {
         this_buffer->ele_ptr = this_buffer->buffer;
         this_buffer->num_left = NUM_PTRS_IN_4KB;
         this_buffer->ele_size = sizeof(struct PolygonVert);
         this_buffer->next = ptr_buffer_list;
         ptr_buffer_list = this_buffer;

         /* allocate the first ptr */
         this_ptr = (struct PolygonVert *)ptr_buffer_list->ele_ptr;
         ptr_buffer_list->ele_ptr += ptr_buffer_list->ele_size;
         ptr_buffer_list->num_left--;
       }
      else
       {
       HSset_status( HSSTAT_ALLOC_ERROR );
       this_ptr = NULL;
       }
    }
    if( this_ptr ) this_ptr->Next = (struct PolygonVert *)NULL;

   return (this_ptr);
} /* HSalloc_VertPtr */

/*-- HSalloc_HStri_vertex --------------------------------------------------------------*/

struct HStri_vertex *HSalloc_HStri_vertex(
   void)

/*
 * Allocates an HStri_vertex structure and returns its address.  Space is
 * allocated by 'malloc' only when the free storage pool and current
 * buffer are empty.
 *
 * HISTORY: 09/01/86 Created.					S. A. Rapa
 *          11/07/89 Changed to allocate fixed-size buffers.	C. M. Jablonski
 *          12/11/89 Added element counts to speed cleanup.	C. M. Jablonski
 */

{
   struct HStri_vertex *this_vertex;
   struct HSbufptr *this_buffer;

   if ((vertex_buffer_list != NIL_BUFPTR) && (vertex_buffer_list->num_left > 0))
    {
      /* get the vertex from the current buffer */
      this_vertex = (struct HStri_vertex *)vertex_buffer_list->ele_ptr;
      vertex_buffer_list->ele_ptr += vertex_buffer_list->ele_size;
      vertex_buffer_list->num_left--;
    }
  else
    {
      /* allocate the structures for a new buffer */
      if ((this_buffer = (struct HSbufptr *) malloc (sizeof(struct HSbufptr))) &&
          (this_buffer->buffer = (char *) malloc (NUM_VERTICES_IN_60KB * sizeof(struct HStri_vertex))))
       {
         this_buffer->ele_ptr = this_buffer->buffer;
         this_buffer->num_left = NUM_VERTICES_IN_60KB;
         this_buffer->ele_size = sizeof(struct HStri_vertex);
         this_buffer->next = vertex_buffer_list;
         vertex_buffer_list = this_buffer;

         /* allocate the first vertex */
         this_vertex = (struct HStri_vertex *)vertex_buffer_list->ele_ptr;
         vertex_buffer_list->ele_ptr += vertex_buffer_list->ele_size;
         vertex_buffer_list->num_left--;
       }
      else
       {
       HSset_status( HSSTAT_ALLOC_ERROR );
       this_vertex = NULL;
       }
    }

   this_vertex->InCardinality = 0;
   this_vertex->OutCardinality = 0;
   this_vertex->LocalExtremity = 0x00000000;
   this_vertex->Out[0] = NULL;
   this_vertex->Out[1] = NULL;
   this_vertex->Out[2] = NULL;
   this_vertex->Out[3] = NULL;
   this_vertex->In[0] = NULL;
   this_vertex->In[1] = NULL;
   this_vertex->In[2] = NULL;
   this_vertex->In[3] = NULL;
   LoopVertices++;

   return (this_vertex);
}

/*-- HSalloc_tri_loop --------------------------------------------------------------*/

struct HStri_loop *HSalloc_tri_loop(
   void)

/*
 * Allocates an HStri_loop structure and returns its address.  Space is
 * allocated by 'malloc' only when the free storage pool and current
 * buffer are empty.
 *
 * HISTORY: 09/01/86 Created.					S. A. Rapa
 *          11/07/89 Changed to allocate fixed-size buffers.	C. M. Jablonski
 *          12/11/89 Added element counts to speed cleanup.	C. M. Jablonski
 */

{
   struct HStri_loop *this_bound;
   struct HSbufptr *this_buffer;

   if ((bound_buffer_list != NIL_BUFPTR) && (bound_buffer_list->num_left > 0))
    {
      /* get the bound from the current buffer */
      this_bound = (struct HStri_loop *)bound_buffer_list->ele_ptr;
      bound_buffer_list->ele_ptr += bound_buffer_list->ele_size;
      bound_buffer_list->num_left--;
    }
  else
    {
      /* allocate the structures for a new buffer */
      if ((this_buffer = (struct HSbufptr *) malloc (sizeof(struct HSbufptr))) &&
          (this_buffer->buffer = (char *) malloc (NUM_BOUNDS_IN_4KB * sizeof(struct HStri_loop))))
       {
         this_buffer->ele_ptr = this_buffer->buffer;
         this_buffer->num_left = NUM_BOUNDS_IN_4KB;
         this_buffer->ele_size = sizeof(struct HStri_loop);
         this_buffer->next = bound_buffer_list;
         bound_buffer_list = this_buffer;

         /* allocate the first bound */
         this_bound = (struct HStri_loop *)bound_buffer_list->ele_ptr;
         bound_buffer_list->ele_ptr += bound_buffer_list->ele_size;
         bound_buffer_list->num_left--;
       }
      else
       {
       HSset_status( HSSTAT_ALLOC_ERROR );
       this_bound = NULL;
       }
    }

   return (this_bound);
} /* HSalloc_tri_loop */

/*
 * HSend_tri_loop() ends the current loop so that new calls to 'HSadd_tri_vertex'
 * adds points to a new HStri_loop.
 *
 * HISTORY: 2/14/90	Created.
 *								Trevor Mink
 */

void HSend_tri_loop(
   void)

	{
	if( PrevPoint ) {
		PrevPoint->next = FirstPoint;
		ThisLoop = HSalloc_tri_loop();
		if( tiling_parms.status == HSSTAT_ALLOC_ERROR ) return;
		if( Facet == (struct HStri_loop *)NULL )
			Facet = ThisLoop;
		else
			PrevLoop->next = ThisLoop;
		ThisLoop->next = (struct HStri_loop *)NULL;
		ThisLoop->loop = FirstPoint;
		ThisLoop->Vertices = LoopVertices;
		LoopVertices = 0;
		PrevPoint = (struct HStri_vertex *)NULL;
		PrevLoop = ThisLoop;
	}

} /* HSend_tri_loop */

/*-- HScleanup_triangulator_structures -----------------------------------------------*/

static void HScleanup_triangulator_structures(
   void )

/*
 * Frees all boundary structure buffers and resets the free lists.
 *
 * HISTORY: 11/07/89 Created.					C. M. Jablonski
 *          12/11/89 Added element counts to speed cleanup.	C. M. Jablonski
 */

{
   struct
      HSbufptr	*this_buffer, *next_buffer;

   /* cleanup the point structures */
   if (vertex_buffer_list != NIL_BUFPTR)
    {
      for (	this_buffer = vertex_buffer_list->next;
		this_buffer != NIL_BUFPTR;
		this_buffer = next_buffer )
       {
         next_buffer = this_buffer->next;
         free((char *)this_buffer->buffer);
         free((char *)this_buffer);
       }
      vertex_buffer_list->ele_ptr = vertex_buffer_list->buffer;
      vertex_buffer_list->num_left = NUM_VERTICES_IN_60KB;
      vertex_buffer_list->next = NIL_BUFPTR;
    }

   /* cleanup the bound structures */
   if (bound_buffer_list != NIL_BUFPTR)
    {
      for (	this_buffer = bound_buffer_list->next;
		this_buffer != NIL_BUFPTR;
		this_buffer = next_buffer )
       {
         next_buffer = this_buffer->next;
         free((char *)this_buffer->buffer);
         free((char *)this_buffer);
       }
      bound_buffer_list->ele_ptr = bound_buffer_list->buffer;
      bound_buffer_list->num_left = NUM_BOUNDS_IN_4KB;
      bound_buffer_list->next = NIL_BUFPTR;
    }

   /* cleanup the ptr structures */
   if (ptr_buffer_list != NIL_BUFPTR)
    {
      for (	this_buffer = ptr_buffer_list->next;
		this_buffer != NIL_BUFPTR;
		this_buffer = next_buffer )
       {
         next_buffer = this_buffer->next;
         free((char *)this_buffer->buffer);
         free((char *)this_buffer);
       }
      ptr_buffer_list->ele_ptr = ptr_buffer_list->buffer;
      ptr_buffer_list->num_left = NUM_PTRS_IN_4KB;
      ptr_buffer_list->next = NIL_BUFPTR;
    }
}


/*
 * HSdispose_tri_facet() frees all of the vertices and loops of 'Facet'.
 *
 * HISTORY: 2/14/90	Created.
 *								Trevor Mink
 */

void HSdispose_tri_facet(
   void)

{

	HScleanup_triangulator_structures();
	HSfree_edges(); /* Actually will free all edges */

} /* HSdispose_tri_facet */

/*
 * HSadd_tri_vertex() adds a vertex (with normals if smooth shading) to the current
 * loop of the current facet.  If no loop or facet is active, then they are established.
 *
 * HISTORY: 02/14/90 Created.
 *								Trevor Mink
 */

void HSadd_tri_vertex(
   IGRdouble x,
   IGRdouble y,
   IGRdouble z,
   IGRdouble w,
   IGRboolean e,
   IGRdouble nx,
   IGRdouble ny,
   IGRdouble nz,
   IGRdouble dum1,
   IGRdouble dum2 )
	
	{
	ThisPoint = HSalloc_HStri_vertex();

	if ( tiling_parms.status == HSSTAT_ALLOC_ERROR ) return;

	ThisPoint->coord[0] = x;
	ThisPoint->coord[1] = y;
	ThisPoint->coord[2] = z;
	ThisPoint->coord[3] = w;

#if DEBUG
	fprintf( stderr, "Alloced vertex ThisPoint = %x\n", ThisPoint );
	fprintf( stderr, "x, y, z, w = %lf, %lf, %lf, %lf\n",
		x, y, z, w );
#endif
	if( element_parms.doing_vertex_normals )
		{
#if DEBUG
	fprintf( stderr, "normal = %lf, %lf, %lf\n",
		nx, ny, nz );
#endif
		ThisPoint->norm[0]  = nx;
		ThisPoint->norm[1]  = ny;
		ThisPoint->norm[2]  = nz;
		}
	else
		ThisPoint->norm[0]  = 0.0;

	if( PrevPoint )
		PrevPoint->next = ThisPoint;
	else
		FirstPoint = ThisPoint;

	PrevPoint = ThisPoint;
#if DEBUG
	fprintf( stderr, "Leaving HSadd_tri_vertex\n" );
#endif
} /* HSadd_tri_vertex */

/*
 * PrintFacet() prints the facet. (What did you think it did?)
 *
 * HISTORY: 2/14/90	Created.
 *								Trevor Mink
 */

static void PrintFacet(
   void)

	{
	int NumLoops = 0, NumVerts = 0;
	struct HStri_loop *Loop;
	struct HStri_vertex *StartVertex, *Vertex;

	for( Loop = Facet; Loop; Loop = Loop->next ) {
		NumVerts = 0;
		NumLoops++;
		printf( "Loop # %d\n", NumLoops );
		StartVertex = Vertex = Loop->loop;
		do {
			NumVerts++;
			printf( "Vertex # %d at addr: %x is (%lf, %lf, %lf)\n", NumVerts, Vertex,
				Vertex->coord[0], Vertex->coord[1], Vertex->coord[2] );
			Vertex = Vertex->next;
		} while( StartVertex != Vertex );
	}
} /* PrintFacet */

static int CheckForDups(
   struct HStri_loop *Loop,
   struct HStri_vertex *vertex_list,
   int PlanarX,
   int PlanarY,
   int PlanarZ )

	{
	int Dups = 0;
	struct HStri_vertex *last_point, *stop_point;

#if FACET_DEBUG
	fprintf( stderr, "element_parms.dis_tol = %f\n", element_parms.dis_tol );
#endif
	/*
	 * It is critical to the polybusting routine
	 * that polygons do not cross themselves in the xy plane;
	 * to be safe, force adjacent points which are 'close' to
	 * be exactly equal in x and y.  This prevents floating
	 * exceptions in the polybuster caused when trying to divide
	 * by a very small delta Y during interpolation.
	 */

	stop_point = vertex_list;
	do {
		last_point = vertex_list;
		vertex_list = vertex_list->next;

#if FACET_DEBUG
/*		fprintf( stderr, "Vertex = (%f, %f, %f) being checked\n", vertex_list->coord[PlanarX],
			vertex_list->coord[PlanarY], vertex_list->coord[PlanarZ] );
*/
#endif
		if( FABS( vertex_list->coord[PlanarX] - last_point->coord[PlanarX] ) < element_parms.dis_tol )
			vertex_list->coord[PlanarX] = last_point->coord[PlanarX];
		if( FABS( vertex_list->coord[PlanarY] - last_point->coord[PlanarY] ) < element_parms.dis_tol )
			vertex_list->coord[PlanarY] = last_point->coord[PlanarY];
		/*
		 * Must do z's too (for perspective cases)
		 */
	
		if( FABS( vertex_list->coord[PlanarZ] - last_point->coord[PlanarZ] ) < element_parms.dis_tol )
			vertex_list->coord[PlanarZ] = last_point->coord[PlanarZ];

		/* If vertices are equal in x and y, get rid of one */
		if( vertex_list->coord[PlanarY] == last_point->coord[PlanarY] &&
			vertex_list->coord[PlanarX] == last_point->coord[PlanarX] ) {
			/* Toss the vertex */
#if FACET_DEBUG
			fprintf( stderr, "Vertex = (%f, %f, %f) was tossed\n", vertex_list->coord[PlanarX],
				vertex_list->coord[PlanarY], vertex_list->coord[PlanarZ] );
#endif
			last_point->next = vertex_list->next;
			if( vertex_list == Loop->loop ) {
				Loop->loop = vertex_list->next;
				stop_point = vertex_list->next;
			}
			vertex_list = last_point;
			Dups++;
		}

	} while ( vertex_list != stop_point ||
		( (vertex_list == last_point) && (vertex_list != vertex_list->next) ) );

	return( Dups );

} /* CheckForDups */

/*
 * HSdoTriMesh() ends the current loop and calls 'HSprocess_tri_facet()' to create a triangular mesh
 * and send it off to the EDGEII.
 *
 * HISTORY: 2/14/90	Created.
 *								Trevor Mink
 */

void HSdoTriMesh(
   void)

	{
	int FirstLoop = TRUE;
	int Dups, TotalVertices = 0;
	struct HStri_vertex *Vertex, *StopVertex;
	struct HStri_loop *Loop;
	int PlanarX=0, PlanarY=0, PlanarZ, Greatest, Next;

	if( PrevPoint ) {
#if EDGEII_DEBUG
		fprintf( stderr, "calling HSend_tri_loop()\n" );
#endif
		HSend_tri_loop();
	}

	if ( tiling_parms.status == HSSTAT_ALLOC_ERROR ) return;

	HSnormalize_facet_normal ();
	if( !(tiling_parms.processing_mode & HS_PMODE_FEEDBACK) &&
		(element_parms.culling_back_planes != HS_CULL_NONE) )
	{
		if( HScan_cull_facet( active_window->perspective, Facet->loop->coord ) )
		{
			if( Facet )
			{
				HSdispose_tri_facet();
				Facet = (struct HStri_loop *)NULL;
			}
			return;
		}
	}
	for( Loop = Facet; Loop; Loop = Loop->next ) {
		Vertex = Loop->loop;
		switch (element_parms.facet_type) {
			case SMOOTH_SHADE:
				StopVertex = Vertex;
				Loop->Vertices = 0;
				do {
/*
					Vertex->norm[0] = - Vertex->norm[0];
					Vertex->norm[1] = - Vertex->norm[1];
					Vertex->norm[2] = - Vertex->norm[2];
*/
	            	        	Vertex = Vertex->next;
					Loop->Vertices++;
				} while( Vertex != StopVertex );
				TotalVertices += Loop->Vertices;
				break;
			case AREA_FILL:
				StopVertex = Vertex;
				Loop->Vertices = 0;
				do {
	            	        	Vertex = Vertex->next;
					Loop->Vertices++;
				} while( Vertex != StopVertex );
				TotalVertices += Loop->Vertices;
				break;
			case CONST_SHADE:
				StopVertex = Vertex;
				Loop->Vertices = 0;
				do {
                	        	Vertex = Vertex->next;
					Loop->Vertices++;
				} while( Vertex != StopVertex );
				TotalVertices += Loop->Vertices;
				if( FirstLoop ) {
					FirstLoop = FALSE;
/*
					if (!(element_parms.front_facing_facet)) {
						element_parms.facet_normal[0] =
							- element_parms.facet_normal[0];
						element_parms.facet_normal[1] =
							- element_parms.facet_normal[1];
						element_parms.facet_normal[2] =
							- element_parms.facet_normal[2];
					}
*/
				} else {
					/* place pre-calculated shade in every vertex for this loop */
/*					StopVertex = Vertex;
					do {
*/
						/* Place the facet normal in every vertex normal */
/*
						Vertex->norm[0] = element_parms.facet_normal[0];
						Vertex->norm[1] = element_parms.facet_normal[1];
						Vertex->norm[2] = element_parms.facet_normal[2];

						Vertex = Vertex->next;
					} while( Vertex != StopVertex );
*/
				}
				break;
			case POLYLINE:
				break;
			default:
#if FACET_DEBUG
				printf( "Error: invalid shading style\n" );
#endif
				break;
		}

		/* Determine against which plane to project the facet according to the normal */
		if( element_parms.facet_type != POLYLINE ) {
#if TRIMESH_DEBUG
			fprintf( stderr, "facet_normal: %lf, %lf, %lf\n", element_parms.facet_normal[0],
				element_parms.facet_normal[1], element_parms.facet_normal[2] );
#endif
			Greatest = 0;
			for( Next = 1; Next <= 2; Next++ ) {
				if( FABS(element_parms.facet_normal[Next]) >
					FABS(element_parms.facet_normal[Greatest]) )
					Greatest = Next;
			}

			if( Greatest != 0 ) {
#if TRIMESH_DEBUG
				fprintf( stderr, "x is coord[0]\n" );
#endif
				PlanarX = 0;
				if( Greatest != 1 ) {
#if TRIMESH_DEBUG
					fprintf( stderr, "y is coord[1]\n" );
					fprintf( stderr, "z is coord[2]\n" );
#endif
					PlanarY = 1;
					PlanarZ = 2;
				} else {
#if TRIMESH_DEBUG
					fprintf( stderr, "y is coord[2]\n" );
					fprintf( stderr, "z is coord[1]\n" );
#endif
					PlanarY = 2;
					PlanarZ = 1;
				}
			} else {
#if TRIMESH_DEBUG
				fprintf( stderr, "x is coord[1]\n" );
				fprintf( stderr, "y is coord[2]\n" );
				fprintf( stderr, "z is coord[0]\n" );
#endif
				PlanarX = 1;
				PlanarY = 2;
				PlanarZ = 0;
			}
			/* Toss vertices within a tolerance of the ems 'DistTol' */
			Dups = CheckForDups( Loop, Vertex, PlanarX, PlanarY, PlanarZ );
			Loop->Vertices -= Dups;
			TotalVertices -= Dups;
		}
	}

	if( Facet ) {
#if FACET_DEBUG
/*		fprintf( stderr, "tiling_parms.feedback_mode = %d\n", tiling_parms.feedback_mode );
*/
#endif
		(void)HSprocess_tri_facet( Facet, TotalVertices, active_window->EG_vc_no,
			PlanarX, PlanarY );
		HSdispose_tri_facet();
		Facet = (struct HStri_loop *)NULL;
	}

} /* DoTriMesh */

/*	HSconvert_to_trimesh converts the data stored in the "new"
 *	FEM data structure to a data structure that can be used by
 *	the EdgeII.
 *
 *	Created:		6/13/91
 *	Author:			Bob Druzynski
*/

int HSconvert_to_trimesh(
   struct HSfem_tri_mesh *mesh,
   struct HStri_mesh *trimesh )

{

 trimesh->numVerts 	= mesh->num_verts;
 trimesh->verts 	= (struct HStri_point *)mesh->verts;

 if (mesh->area_fill)
 	{
	trimesh->fColors = (struct HStri_color *)mesh->colors;
	}
 else
	{
	trimesh->vColors = (struct HStri_color *)mesh->colors;
	}

 trimesh->vNorms = NULL;
 trimesh->fNorms = NULL;
 trimesh->numFacetNormals = 0;

} /* HSconvert_to_trimesh */

