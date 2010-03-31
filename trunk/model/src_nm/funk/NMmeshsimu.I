class implementation NMassoctrans;

#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include <stdio.h>
#include "nddef.h"
#include "nmdef.h"
#include "nm.h"
#include "EMSasnuc.h"
#include "EMSasopts.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EMSbnd.h"
#include "OMmacros.h"
#include "alloca.h"
#include "EMSopt.h"
#include "EMSprop.h"

extern int		NMget_comp_dependents();
extern int		NMget_edge_mates();

from EMSedge		import	EMget_props;

extern OM_S_OBJID	current_creator;

extern OMuword		OPP_NMfeaturelp_class_id;
extern OMuword		OPP_NMptflp_class_id;
extern OMuword		OPP_NMedflp_class_id;

extern IGRlong		EMunwind_stupid_sets();
extern IGRboolean	EFisAncestryValid();
extern IGRint		EMgetvggeom();

from NMnonmanigm	import	NMappend_SSI;
from EMSsurface		import	EMputLsIfNotThere;
from EMSsubbs		import	EMpartolbasis;

extern int		NMget_edges_from_loop();
extern IGRint		NMcreate_nmtp();
extern IGRint		NMget_faces_edges();
extern IGRint		NMget_feature_loops();

/*
	This function will create meshing topology on a located
	surface/composite/NM state.

	outputs:

	status or msg returns:
*/
/* revision log:

   who		when	   version	what
   ----------------------------------------------------------------------
					
   bwh		08/07/91    2.0.1	creation
*/

int NMcreate_mesh_topology( msg, loc_obj )

long			*msg;		/* o - return code */
struct GRlc_info	*loc_obj;	/* i - located obj to be meshed */

{
long			i, sts;
long			num_comp;		/* number of components */
struct GRlc_info	*loc_comps = NULL;	/* component list */
struct GRid		nmtp_grid;
IGRboolean		new_nmtp;
struct GRvg_construct	cnst_list;
short			act_layer;
struct IGRdisplay	act_display;
struct NMgmSSI		MHssi;

/*
 * set up construct info for nmtp
*/
	gr$get_active_layer( buffer = &act_layer );
	gr$get_active_display( buffer = &act_display );

	cnst_list.msg = msg;
	cnst_list.env_info = &loc_obj->module_info;
	cnst_list.newflag = FALSE;
	cnst_list.geometry = NULL;
	cnst_list.class_attr = NULL;
	cnst_list.level = act_layer;
	cnst_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
	cnst_list.display = &act_display;
	cnst_list.name = NULL;

/*
 * get a list of components to be meshed -- the located object could be
 * wireframe, a surface, composite surface, solid, NMstate, or a set.
 * The object located needs to be broken down to a list of surfaces,
 * composite surfaces, solids, and wireframe entities.
*/
	sts = EMunwind_stupid_sets( loc_obj, FALSE, TRUE, NULL_OBJID,
				&num_comp, &loc_comps, msg );
	if ( !(1&sts&(*msg)) )
	{
	    fprintf( stderr, "%s: unwind sets\n", __FILE__ );
	    return( sts );
	}

/*
 * for each component create the mesh topology
*/
	for( i = 0; i < num_comp; ++i )
	{
	    if ( IGEstop() ) goto mem_cleanup;

	    /* get the top level state */
	    sts = NMcreate_nmtp( msg, &loc_comps[i].located_obj,
			&loc_comps[i].module_info, &nmtp_grid, &new_nmtp,
			NULL, &cnst_list );
	    if ( !(1&sts&(*msg)) )
	    {
		fprintf( stderr, "%s: NMcreate_nmtp\n", __FILE__ );
		goto mem_cleanup;
	    }

	    /* set current creator to the nm node */
	    current_creator = nmtp_grid.objid;

/*
 * initialize save state info
*/
	    NMinit_ssi( &MHssi );

/*
 * determine wireframe/surface/solid and create appropriate mesh
 * NOTE:  for topology creation purposes, there is no difference between
 *	  surface and solid
*/

	    if ( EFisAncestryValid( msg, loc_comps[i].located_obj.objid,
		loc_comps[i].located_obj.osnum, OPP_EMSsurface_class_id, FALSE ) )
	    {
		sts = NMcreate_surface_mesh_topo( &loc_comps[i], &MHssi );
		if ( !(1&sts&(*msg)) )
		{
		    fprintf( stderr, "%s: NMcreate_surface_mesh_topo\n", __FILE__ );
		    goto mem_cleanup;
		}
	    }
	    else
	    {
		fprintf( stderr, "Invalid geom for meshing\n" );
		return( OM_S_SUCCESS );
	    }

	    /* reset current creator to NULL_OBJID */
	    current_creator = NULL_OBJID;

	    /* store save state info and free ssi structure */
	    sts = om$send( msg = message NMnonmanigm.NMappend_SSI(msg,&MHssi,NULL),
			senderid = NULL_OBJID,
			targetid = nmtp_grid.objid,
			targetos = nmtp_grid.osnum );
	    if ( !(1&sts&(*msg)) )
	    {
		fprintf( stderr, "%s: NMappend_SSI\n", __FILE__ );
		goto mem_cleanup;
	    }

	    NMfree_ssi( &MHssi );
	}

mem_cleanup:
	/* reset current creator to NULL_OBJID */
	current_creator = NULL_OBJID;

	/* store save state info and free ssi structure */
	sts = om$send( msg = message NMnonmanigm.NMappend_SSI(msg,&MHssi,NULL),
			senderid = NULL_OBJID,
			targetid = nmtp_grid.objid,
			targetos = nmtp_grid.osnum );
	if ( !(1&sts&(*msg)) )
	    fprintf( stderr, "%s: NMappend_SSI\n", __FILE__ );

	NMfree_ssi( &MHssi );

	if ( loc_comps ) free( loc_comps );

	return( sts );
}

/* ****************************** J J J ********************************* */

/* Abstract:
	This function will create necessary objects and perform meshing on
	a surface or composite surface.
*/

/* revision log:

   who		when	   version	what
   ----------------------------------------------------------------------
					
   bwh		09/12/91    2.0.0	creation
   smt          05/11/92    2.0.1       include alloca.h for SUN.
*/

/*---------------------------------------------------------------------*/
int NMcreate_surface_mesh_topo( surface, MHssi )

struct GRlc_info	*surface;	/* i - located surface and module env */
struct NMgmSSI		*MHssi;		/* io- save state info */

{
long			i, j, sts, msg;
int			size;

IGRint			num_comps, comp_list_size = 0;
struct GRid		*compids = NULL;	/* components of composite surf */
IGRint			*nface_per_comp = NULL, face_list_size = 0;
struct GRid		*faceids = NULL;	/* p-loops of surface */
IGRint			*nnestlp_per_face = NULL, nestlp_list_size = 0;
struct GRid		*nest_lpids = NULL;	/* nested loops */
struct GRid		*p_ploop, *p_nest;
IGRint			*p_numnest;

IGRlong			edopt;			/* passed to EMget_edges method */
unsigned int		nmoptions;
IGRint			num_faces;
IGRint			num_edflp;
struct GRid		*edflp = NULL;
IGRint			num_loops;
struct GRid		*loop_list = NULL;

IGRshort		mattyp;
IGRdouble		*matrix;
IGRboolean		world, compute_new;
struct EMSpartolbasis	partolbas;			
struct IGRbsp_surface	*surfgeom = NULL;

extern OM_S_OBJID	current_creator;
OM_S_OBJID		save_creator;

	sts = OM_S_SUCCESS;
/*
 * create a loopset on the surface if one doesn't exist. Save
 * current_creator. Set it to the surface in case natural loopset
 * gets created. Come back and reset it. Maan what a mess!
*/
save_creator = current_creator;
current_creator = surface->located_obj.objid;
	sts = om$send( msg = message EMSsurface.EMputLsIfNotThere( &msg,
				&surface->module_info.md_env, NULL,
				NULL, NULL, NULL ),
			senderid = NULL_OBJID,
			targetid = surface->located_obj.objid,
			targetos = surface->located_obj.osnum );
current_creator = save_creator;

	if ( !(1&sts&msg) )
	{
	    fprintf( stderr, "%s: EMputLsIfNotThere\n", __FILE__ );
	    return(sts);
	}

/*
 * extract list of components (surfaces), faces (p-loops), and nested loops
*/
	edopt = NULL;
	nmoptions = NMquery_ConsiderExternalToModel;
	sts = NMget_faces_edges( &msg, &surface->located_obj,
			&num_comps, &compids, &comp_list_size,
			&nface_per_comp, &faceids, &face_list_size,
			&nnestlp_per_face, &nest_lpids, &nestlp_list_size,
			NULL, NULL, NULL,
			edopt, nmoptions );
	if ( !(1&sts&msg) )
	{
	    fprintf( stderr, "%s: NMget_faces_edges\n", __FILE__ );
	    return(sts);
	}

	/* set pointers for traversing the list of faces and nested loops */
	p_ploop = &faceids[0];			/* face or p-loop */
	p_numnest = &nnestlp_per_face[0];	/* number of nested loops */
	p_nest = &nest_lpids[0];		/* nested loops */

	/* set the matrix type and matrix in local varables */
	mattyp = surface->module_info.md_env.matrix_type;
	matrix = surface->module_info.md_env.matrix;

	/* fill partolbasis structure except for tolerance */
	partolbas.is_valid = TRUE;
	partolbas.in_world = FALSE;
	partolbas.mattyp = &mattyp;
	partolbas.mat = matrix;

/*
 * traverse list of faces and create meshes
*/
	for ( i = 0; i < num_comps; i++ )
	{
/*
 * get the surface geometry, the parametric basis tolerance,
 * and the edge feature loops -- these only need to be done once
 * per surface
*/
	    sts = EMgetvggeom( &msg, &mattyp, matrix, &compids[i],
				&surfgeom, NULL );
	    if ( !(1&sts&msg) )
	    {
		fprintf( stderr, "%s: EMgetvggeom\n", __FILE__ );
		goto mem_cleanup;
	    }

	    world = 0; /* dummy for argument */
	    compute_new = 0; /* dummy for argument */
	    sts = om$send( msg = message EMSsubbs.EMpartolbasis( &msg,
				partolbas.mattyp, partolbas.mat, &world,
				compute_new, &partolbas.tol ),
			senderid = NULL_OBJID,
			targetid = compids[i].objid,
			targetos = compids[i].osnum );
	    if ( !(1&sts&msg) )
	    {
		fprintf( stderr, "%s: EMpartolbasis\n", __FILE__ );
		goto mem_cleanup;
	    }

	    sts = NMget_feature_loops( &msg, &compids[i],
				&num_edflp, &edflp, &OPP_NMedflp_class_id,
				1, NULL, 0, NULL );
	    if ( !(1&sts&msg) )
	    {
		fprintf( stderr, "%s: get edge feat lp\n", __FILE__ );
		goto mem_cleanup;
	    }

	    num_faces = nface_per_comp[i];
	    for ( j = 0; j < num_faces; ++j )
	    {
		if ( IGEstop() ) goto mem_cleanup;

		/* create list of all loops on face */
		num_loops = *p_numnest + 1;
		size = num_loops * sizeof( struct GRid );
		loop_list = ( struct GRid * ) alloca( size );

		loop_list[0] = *p_ploop;
		if ( *p_numnest )
		{
		    size = ( num_loops - 1 ) * sizeof( struct GRid );
		    OM_BLOCK_MOVE( p_nest, &loop_list[1], size );
		}

		/* perform meshing on this face */
		sts = NMcreate_face_mesh_topo(
					num_loops, loop_list,
					&surface->module_info,
					num_edflp, edflp, MHssi );
		if ( !(1&sts&msg) )
		{
		    fprintf( stderr, "%s: NMcreate_face_mesh_topo\n", __FILE__ );
		    goto mem_cleanup;
		}

		/* update pointers for next face */
		p_nest += *p_numnest;
		p_numnest++;
		p_ploop++;
	    }
	}

mem_cleanup:
	/* free memory */
	if ( compids )		free( compids );
	if ( nface_per_comp )	free( nface_per_comp );
	if ( faceids )		free( faceids );
	if ( nnestlp_per_face )	free( nnestlp_per_face );
	if ( nest_lpids )	free( nest_lpids );
	if ( edflp )		free( edflp );
	if ( surfgeom )		free( surfgeom );

	return( sts );
}

/* ****************************** J J J ********************************* */

/* Abstract:	Surface Automeshing
	This method will mesh a face -- a p-loop and its immediate c-loops
	and feature loops
*/

/* revision log:

   who		when	   version	what
   ----------------------------------------------------------------------
					
   bwh		08/09/91    2.0.1	creation
   smt          05/11/92    2.0.1       include alloca.h for SUN.
*/

/*#define MESH_TIMING*/

int NMcreate_face_mesh_topo( nloop, loop_list, surfenv, 
			num_edflp, edflp, MHssi )

	int		nloop;		/* i - number of loops in face */
	struct GRid	loop_list[];	/* i - loops on face
						the first loop in the list
						should be a p-loop.  other loops
						in the list are nested c-loops
						or feature loops */
  	struct GRmd_env *surfenv;	/* i - surface env */
	int		num_edflp;	/* i - number of edge feature loops */
	struct GRid	edflp[];	/* i - list of edge feature loops */
	struct NMgmSSI	*MHssi;		/* io- save state info */

{
long			sts, msg;
long			i, j;
struct GRid		*ptr_lp, *p_edge, *edges = NULL;
unsigned int		NMoptions, nm_asopt, nm_qopt;
int			depth;
long			edopt;
int			num_edg, edlistsize;
struct GRid		nmedge;

#ifdef MESH_TIMING
long			start_time;
char			time_string[30];
#endif


#ifdef MESH_TIMING
	time( &start_time );
#endif


/*
 * if loop_list not passed in, get loop list?????
 * NOTE: p-loop must be passed in, other loops could be determined
*/

	depth = 1;
	edopt = EMS_OPT_NONDEG;/* ignore degenerate edges */

/*
 * place nodes on the edges of all loops of the face
 * store the node info in the loop_node_set struct
*/
	for ( i=0, ptr_lp=loop_list; i<nloop; ++i, ++ptr_lp )
	{
	    if ( edges )
	    {
		free( edges );
		edges = NULL;
	    }
	    edlistsize = 0;
	    num_edg = 0;
	    NMoptions = NMquery_ConsiderExternalToModel;

	    if ( EFisAncestryValid( &msg, ptr_lp->objid, ptr_lp->osnum,
					OPP_NMptflp_class_id, FALSE ) )
	    {
		/* get a list of edges for this loop -- (degenerate edge) */
		sts = NMget_edges_from_loop( &msg, ptr_lp, &num_edg, &edges,
					&edlistsize, num_edflp, edflp,
					NULL, depth, NMoptions );
		if ( !(1&sts&msg) )
		{
		    fprintf( stderr, "%s: get degen edge\n", __FILE__ );
		    goto mem_cleanup;
		}

		sts = NMcreate_vertex_mesh_topo( edges, surfenv, TRUE, MHssi );
		if ( !(1&sts&msg) )
		{
		    fprintf( stderr, "%s: create face NMvtx\n", __FILE__ );
		    goto mem_cleanup;
		}
	    }
	    else
	    {
		/* get a list of edges for this loop */
		sts = NMget_edges_from_loop( &msg, ptr_lp, &num_edg, &edges,
					&edlistsize, num_edflp, edflp,
					edopt, depth, NMoptions );
		if ( !(1&sts&msg) )
		{
		    fprintf( stderr, "%s: get loop edges\n", __FILE__ );
		    goto mem_cleanup;
		}

		for ( j=0, p_edge=edges; j<num_edg; j++, p_edge++ )
		{
		    if ( IGEstop() ) goto mem_cleanup;

		    /* get or create an NMedge */
		    nm_qopt = NMquery_ConsiderExternalToModel |
			      NMquery_CreateIfNotFound;
		    nm_asopt = NMassocpre_NMedge;
		    sts = NMassociative_preprocess( &msg, p_edge, surfenv,
				nm_asopt, nm_qopt, MHssi, NULL, NULL, NULL );
		    if ( !(1&sts&msg) )
		    {
			fprintf( stderr, "%s: get nmedge\n", __FILE__ );
			goto mem_cleanup;
		    }

		    nmedge.objid = MHssi->nmedges[0];
		    nmedge.osnum = surfenv->md_id.osnum;

		    /* reset the ssi */
		    MHssi->nmedgesbufsize += MHssi->num_nmedges;
		    MHssi->num_nmedges = 0;

        	    MHssi->nmbufsize += MHssi->num_sfs;
        	    MHssi->num_sfs = 0;

        	    MHssi->vtxbufsize += MHssi->num_vtx;
        	    MHssi->num_vtx = 0;

		    sts = NMcreate_vertex_mesh_topo( p_edge,
						surfenv, FALSE, MHssi );
		    if ( !(1&sts) )
		    {
			fprintf( stderr, "%s: create vtx topo\n", __FILE__ );
			goto mem_cleanup;
		    }
		} /* end loop through edges of loop */
	    }/* end if point feature -- else */

#ifdef MESH_TIMING
	AP_duration( start_time, time_string );
	fprintf( stderr, "Loop %d completed:  %s\n", i, time_string );
#endif

	}/* end loop through face loops */

	if ( IGEstop() ) goto mem_cleanup;

/*
 * free memory
*/
	if ( edges ) free( edges );

	return( OM_S_SUCCESS );



mem_cleanup:
	if ( edges ) free( edges );

	return( sts );
}

/* ****************************** J J J ********************************* */

/* Abstract:
	This function constructs vertex topology on an edge
*/

/* revision log:

   who		when	   version	what
   ----------------------------------------------------------------------
					
   bwh		08/07/91    2.0.1	creation
*/

/*---------------------------------------------------------------------*/
int NMcreate_vertex_mesh_topo( emsedge, env, face_vtx, MHssi )

struct GRid	*emsedge;	/* i - ems edge on which to check for/
					create vertices - optional? */
struct GRmd_env	*env;		/* i - surface env */
int		face_vtx;	/* i - TRUE for point feature on pt edge */
struct NMgmSSI	*MHssi;		/* io- save state info */

{
long			sts, msg;
long			i;
IGRint			num_edg_vtx;
struct GRid		nmvtx;
struct GRid		refedge;
IGRushort 	edgprops;
unsigned int		nm_qopt, nm_asopt;
IGRint			type, num_parents;
IGRushort	options;

/*
 * get the reference edge corresponding to the emsedge
 * NOTE: use the ems edge for face vertices
*/
	if ( face_vtx )
	{
	    refedge = *emsedge;
	}
	else
	{
	    nm_qopt = NMquery_ConsiderExternalToModel;
	    sts = NMget_edge_mates( &msg, emsedge, NULL, NULL, NULL, &refedge,
				NULL, NULL, nm_qopt, NULL, NULL );
	    if ( !(1&sts&msg) )
	    {
		fprintf( stderr, "%s: get refedge\n", __FILE__ );
		return(sts);
	    }
	}

/*
 * check if the refedge is closed to determine whether one or two vertex
 * objects are necessary
*/
	sts = om$send( msg = message EMSedge.EMget_props( &msg, &edgprops ),
			senderid = NULL_OBJID,
			targetid = refedge.objid,
			targetos = refedge.osnum );
	if ( !(1&sts&msg) )
	{
	    fprintf( stderr, "%s: EMSedge.EMget_props\n", __FILE__ );
	    return(sts);
	}

	num_edg_vtx = ( edgprops & EMED_XYZ_CLOSED ) ? 1 : 2;

	num_parents = 1;
	options = EMS_no_const_assoc | EMSinit_dont_store_recomp_info;
	nm_qopt |= NMquery_CreateIfNotFound;
	type = 0;

/*
 * for each end of the edge, get the NMvertex and check for MHmsvtx
 * construct MHmsvtx as needed
*/
	for ( i = 0; i < num_edg_vtx; ++i )
	{
	    nmvtx.objid = NULL_OBJID;

/*
 * get the NMvertex
*/
	    nm_asopt = ( i == 0 ) ? NMassocpre_StartVtx : NMassocpre_StopVtx;
	    sts = NMassociative_preprocess( &msg, &refedge, env, nm_asopt,
					nm_qopt, MHssi, NULL, NULL, NULL );
	    if ( !(1&sts&msg) )
	    {
		fprintf( stderr, "%s: get start nmvertex\n", __FILE__ );
		return(sts);
	    }

	    nmvtx.objid = MHssi->vtx[0];
	    nmvtx.osnum = env->md_id.osnum;

   	    /* reset the ssi */
	    MHssi->nmedgesbufsize += MHssi->num_nmedges;
	    MHssi->num_nmedges = 0;

            MHssi->nmbufsize += MHssi->num_sfs;
            MHssi->num_sfs = 0;

            MHssi->vtxbufsize += MHssi->num_vtx;
            MHssi->num_vtx = 0;
	}

	return( OM_S_SUCCESS );
}

end implementation NMassoctrans;
