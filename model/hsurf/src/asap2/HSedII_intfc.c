
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:34 $
$Locker:  $
*/

/* HSedII_intfc.c */

#include "stdio.h"
#include "EG.h"
#include "AAdef.h"
#include "igrtypedef.h"
#include "HStl_global.h"
#include "HStl_element.h"
#include "hsdisplay.h"

#if TIMING
extern float		compute_time, answer_wait_time, answer_time;
#endif
#if STATS
extern IGRint		num_answers, largest_answer, answer_total;
extern IGRint		num_tri;
#endif
extern void memcpy();
extern void AA_report_error( int );

/*--- HSput_mesh -----------------------------------*/

IGRchar *HSput_mesh( tri_mesh, mesh0_poly1 )

	EGTriMeshData3Info	*tri_mesh;
	IGRint			mesh0_poly1;

	{
	IGRchar *buf_ptr;
	IGRint  num_verts, vert_size, mesh_size, cmd;
	IGRint  vertex_normal_size = 0, facet_normal_size = 0;
	EGPolyLine3Info *polyline = NULL;
	extern int AACL_get_answer_ptr( IGRint, IGRint, IGRchar** );
	extern void AACL_answer_complete( void );

	AAtimer( &answer_wait_time );
	if ( mesh0_poly1 == 0 )
	   {
	   num_verts = tri_mesh->numVerts;
#if STATS
	   num_tri += num_verts - 2;
#endif
	   vert_size = num_verts * sizeof( EGPoint3 );
	   vertex_normal_size = ((tri_mesh->vNorms) ? num_verts : 0) *
						sizeof( EGVect3 );
	   facet_normal_size = ((tri_mesh->fNormOffset) ? (num_verts - 2) : 1) *
						sizeof( EGVect3 );
	   mesh_size = sizeof( EGTriMeshData3Info ) + vert_size +
				vertex_normal_size + facet_normal_size;
	   }
	else
	   {
	   polyline = (EGPolyLine3Info *) tri_mesh;
	   num_verts = polyline->numVerts;
	   vert_size = num_verts * sizeof( EGPoint3 );
	   mesh_size = sizeof( EGPolyLine3Info ) + vert_size;
	   }

	/* At this point, the asap needs to put a mesh in the buffer.  To
	 * do so, it must get an address.  It will stay in this code until
	 * it gets an address, since there is nothing else it can do.
	 */
	cmd = (mesh0_poly1 == 0 ) ? AA_DISPLAY_TRIMESH : AA_DISPLAY_POLYLINE;
	do
	   {
	   if ( ! AACL_get_answer_ptr( mesh_size, cmd, &buf_ptr ) )
	      {
	      AA_report_error( HSSTAT_ALLOC_ERROR );
	      goto quit;
	      }
	   }
	while ( ! buf_ptr );

	AAtimer( &answer_time );

	if ( mesh0_poly1 == 0 )
	   {
	   /* copy EGTriMeshData3Info structure */
	   memcpy( buf_ptr, tri_mesh, sizeof( EGTriMeshData3Info ) );

	   /* copy vertices */
	   buf_ptr += sizeof( EGTriMeshData3Info );
	   memcpy( buf_ptr, tri_mesh->verts, vert_size );

	   /* copy vertex normals (if there are any) */
	   buf_ptr += vert_size;
	   if ( vertex_normal_size )
	      {
	      memcpy( buf_ptr, tri_mesh->vNorms, vertex_normal_size );
	      }

	   /* copy facet normals */
	   buf_ptr += vertex_normal_size;
	   memcpy( buf_ptr, tri_mesh->fNorms, facet_normal_size );

	   }
	else
	   {
	   /* copy EGPolyLine3Info structure */
	   memcpy( buf_ptr, polyline, sizeof( EGPolyLine3Info ) );

	   /* copy vertices */
	   buf_ptr += sizeof( EGPolyLine3Info );
	   memcpy( buf_ptr, polyline->verts, vert_size );
	   }

	AACL_answer_complete();

#if STATS
	++num_answers;
	answer_total += mesh_size;
	if ( mesh_size > largest_answer )
	   largest_answer = mesh_size;
#endif

quit:
	AAtimer( &compute_time );
	return NULL;
	} /* HSput_mesh */


/*--- HSbuffer_tri_meshes_on_ASAPII ------------------------------------------*/

int HSbuffer_tri_meshes_on_ASAPII( vc_no, tri_mesh )

	int vc_no;
	EGTriMeshData3Info *tri_mesh;

/*
DESCRIPTION
	This function calls the function that puts the tri_mesh
	in the mesh_buffer.  It is here for interface reasons.

HISTORY
	S.P. Rogers  09/19/90  Creation Date
*/

	{
	HSput_mesh( tri_mesh, 0 );
	return(0);
	} /* HSbuffer_tri_meshes_on_ASAPII */


/*--- HSbuffer_polylines_on_ASAPII ------------------------------------------*/

void HSbuffer_polylines_on_ASAPII( vc_no, polyline )

	int vc_no;
	EGPolyLine3Info *polyline;

/*
DESCRIPTION
	This function calls the function that puts the polyline
	in the mesh_buffer.  It is here for interface reasons.

HISTORY
	S.P. Rogers  09/19/90  Creation Date
*/

	{
	HSput_mesh( (EGTriMeshData3Info	*) polyline, 1 );
	} /* HSbuffer_polylines_on_ASAPII */


/*--- HSbuffer_traps_on_ASAPII -----------------------------------------------*/

void HSbuffer_traps_on_ASAPII( trap )

	struct trapezoid *trap;

/*
DESCRIPTION
	Put a trapezoid in the output buffer.

HISTORY
	S.P. Rogers  05/13/91  Creation Date
*/

	{
	IGRchar *buf_ptr;

	AAtimer( &answer_wait_time );

	do
	   {
	   if ( ! AACL_get_answer_ptr( sizeof( struct trapezoid ),
				AA_DISPLAY_TRAPEZOID, &buf_ptr ) )
	      {
	      fprintf( stderr, "PANIC: trapezoid too big!!\n" );
	      goto quit;
	      }
	   }
	while ( ! buf_ptr );

	AAtimer( &answer_time );

	memcpy( buf_ptr, trap, sizeof( struct trapezoid ) );

#if STATS
	answer_total += sizeof( struct trapezoid );
#endif
	AACL_answer_complete();

#if STATS
	++num_answers;
	if ( sizeof( struct trapezoid ) > largest_answer )
	   largest_answer = sizeof( struct trapezoid );
#endif

quit:
	AAtimer( &compute_time );

	} /* HSbuffer_traps_on_ASAPII */


/*--- HSset_rendering_parms_from_ASAPII --------------------------------------*/

void HSset_rendering_parms_from_ASAPII( render_parms, color, options, culling )

	struct HS_element_rendering_parms	*render_parms;
	IGRint color, options, culling;

/*
DESCRIPTION
	This function puts a rendering parms packet in the buffer.  Format:
		+---------------------------------------+
		|  struct HS_element_rendering_parms	|
		+---------------------------------------+
		|  EGRGBColor				|
		+---------------------------------------+
		|  int color				|
		+---------------------------------------+
		|  int options				|
		+---------------------------------------+
		|  int culling flag			|
		+---------------------------------------+

HISTORY
	L.M. Brodnax  03/28/91	Creation Date
*/

	{
	IGRchar	*buf_ptr;
	IGRint	size;
	extern EGRGBColor EGcolor;

	/* At this point, the asap needs to put a rendering parms packet
	 * in the buffer.  It will stay in this code until it gets an address
	 * for the packet.
	 */
	AAtimer( &answer_wait_time );
	size = sizeof( struct HS_element_rendering_parms ) +
	       sizeof( EGRGBColor ) + 2 * sizeof( IGRint );
	do
	   {
	   if ( ! AACL_get_answer_ptr( size, AA_RENDERING_PARMS, &buf_ptr ) )
	      {
	      AA_report_error( HSSTAT_ALLOC_ERROR );
	      AAtimer( &compute_time );
	      return;
	      }
	   }
	while ( ! buf_ptr );

	AAtimer( &answer_time );
	if (render_parms)
	  memcpy( buf_ptr, render_parms, sizeof( *render_parms ) );
	buf_ptr += sizeof( *render_parms );
	memcpy( buf_ptr, &EGcolor, sizeof( EGRGBColor ) );
	buf_ptr += sizeof( EGRGBColor );
	memcpy( buf_ptr, &color, sizeof( IGRint ) );
	buf_ptr += sizeof( int );
	memcpy( buf_ptr, &options, sizeof( IGRint ) );
	buf_ptr += sizeof( int );
	memcpy( buf_ptr, &culling, sizeof( IGRint ) );

	AACL_answer_complete();
	AAtimer( &compute_time );

	} /* HSset_rendering_parms_from_ASAPII */
