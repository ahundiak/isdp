/* ###################   APOGEE COMPILED   ################## */
class implementation EMSslmacfea;

#if DEBUG
#include <stdio.h>
#endif

#ifndef OMerrordef_include
#include "OMerrordef.h"
#endif

#ifndef OMmacros_include
#include "OMmacros.h"
#endif

#ifndef igrtypedef_include
#include "igrtypedef.h"
#endif

#ifndef igetypedef_include
#include "igetypedef.h"
#endif

#ifndef gr_include
#include "gr.h"
#endif

#ifndef igr_include
#include "igr.h"
#endif

#ifndef EMSmsgdef_include
#include "EMSmsgdef.h"
#endif

#ifndef EMSopt_include
#include "EMSopt.h"	/* for EMS_OPT_PLOOP */
#endif

#ifndef EMSlmdef_include
#include "EMSlmdef.h"	/* for EMS_ROUND_OPR */
#endif

#ifndef EMSfeadef_include
#include "EMSfeadef.h"	/* for struct pocket_data */
#endif

#ifndef EC_I_include
#include "EC_I.h"  /* for EMS_I_Processing */
#endif

#ifndef emsdef_include
#include "emsdef.h"	/* for MAXINT */
#endif

#ifndef emssfintdef_include
#include "emssfintdef.h"  /* for EMSsfbool_opt_xxxx */
#endif


#ifndef emserr_include
#include "emserr.h"
#endif

#ifndef emsbool_include
#include "emsbool.h"  /* for EMSbooltype */
#endif

#include "EMSasopts.h"
#include "EMSasdef.h"
#include "EMSprop.h"
#include "EMSasfeatdef.h"
#include "EMSrnd.h"
#include "EMSasnuc.h"
#include "EMSascmacros.h"


#define POCKET		0
#define BOSS		1
#define MAXCRVS		10
#define MAXEDGES	20

from EMSboundary import  EMgetsurface_info;
from EMSsubbs import  EMget_edges;


method EMmake_pocket_fea(IGRlong *EMmsg; 
		IGRint part_type; 
		struct GRevent *pock_dep_eve; 
		IGRboolean drafted; 
		struct GRevent *draft_ang_eve; 
		IGRboolean round_edge; 
		struct GRevent *round_rad_eve; 
		struct GRvg_construct *const_list; 
		struct GRid *solid_id; 
		struct GRlc_info *surfs_info; 
		IGRushort gen_opts)

/*

DESCRIPTION:

This method uses make & lift face and/or the round edges operation to 
construct the regular pocket/boss.

VARIABLES:

IGRlong	 *EMmsg		     Output	return process status except the part
					construction (stat_OM).
IGRint  part_type	     Input	part indicator.
struct GRevent *pock_dep_eve Input 	pocket depth.
IGRboolean  drafted	     Input	place draft pocket/boss.
struct GRevent *draft_angle  Input	draft angle.
IGRboolean  round_edge	     Input	round bottom edges.
structGRevent *round_radius  Input	rounding radius.
struct GRvg_construct *const_list  Input  construct information of 
					countersink/counterbore holes;
struct GRid  *solid_id	     Input	active state id.
struct GRlc_info *surfs_info Input	located surface and profile inform.
IGRushort gen_opts	     Input 	associative/non-associative mode 

HISTORY:

Janaka  01/13/93 Made changes to accommodate new interface to
                 EMround_chamfer_edges().
Tapadia 02/14/92 Fix for TR 92n1252 - Passed the list of edges for boss.
Tapadia 07/25/91 Changed the function name because of extensive changes.
Tapadia 06/12/91 Pocket/boss with draft. 
Tapadia 05/17/91 Recomputation of pockets with rounding supported.
Tapadia 05/02/91 Modified to support associative make face, lift face & 
		 round operation for pocket/boss. 
*/

{
	IGRboolean  	action, same_loop;
	IGRint  	i, num_edges, number_of_groups, num_edges_loops;
	IGRlong  	stat_OM;
	GRobjid  	*edge_ids, edgeids[MAXEDGES], loop_id[1], tmp_loop;
	struct GRid  	*edges, *boundaries, last_face, new_solid, active_id;
	extern IGRlong 	EFgen_make_lift_face(), EMround_chamfer_edges();
	struct EMSvalue_info rnd_vals[1];
	struct GRlc_info  profile[1];
	IGRushort	 mask;

	/* initialize */
	stat_OM = OM_S_SUCCESS;
	*EMmsg = EMS_S_Success;
	mask = EMS_MACRO_STATE;
	edges = boundaries = NULL;  
	edge_ids = NULL;
	action = same_loop = TRUE;

	/* check if the part type is correct */
	if(part_type != POCKET && part_type != BOSS) {
		*EMmsg = EMS_E_Success;
		goto wrapup;
	}

	profile[0] = surfs_info[0];
	profile[0].located_obj.objid = surfs_info[1].located_obj.objid;

	/* This function places pocket/boss with/without draft */
/****************************************************************************
	stat_OM = EFgen_make_lift_face(part_type, 
			&surfs_info[0].module_info,
	    		&surfs_info[0].located_obj, 1, profile,
	    		pock_dep_eve, drafted, draft_ang_eve, gen_opts, 
	    		const_list, solid_id, my_id, &new_solid, &last_face, 
	    		&number_of_groups, EMmsg);
****************************************************************************/
        stat_OM = ems$gen_liftface_pocket_boss(msg = EMmsg,
                        datum_surf_mdenv = &surfs_info[0].module_info,
                        datum_surface = &surfs_info[0].located_obj,
                        curves = profile,
                        lift_distances = pock_dep_eve,
                        is_drafted = drafted,
                        draft_angle = draft_ang_eve,
                        options = gen_opts,
                        construction_list = const_list,
                        top_state_before = solid_id,
                        my_id = my_id,
                        top_state_after = &new_solid,
                        last_lift = &last_face,
                        num_groups = &number_of_groups,
                        part_type = part_type);

	EMerr_hndlr(!(1 & stat_OM & *EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

	/* make & lift */
	ME.EMSsfmacro->num_states = 2;

	/* We pass the loop id (for pocket) for round instead of edges & for
	boss we pass the loop_id (in case the loop gets changed during 
	recompute, the correct number of edges can be obtained) or the list of 
	edges if the loops of common edges are different */

	if(round_edge) {
	    IGRint  buf_size;

	    buf_size = num_edges = 0;
	    edge_ids = edgeids;
	    if(part_type == POCKET) {
		OM_S_CHANSELECT  to_loopset, to_loops;
		OMuint count;
		OM_S_OBJECT_LINKAGE ls, new_loop;

		stat_OM = EMmake_chanselect(EMSsubbs_to_loopset, &to_loopset);
		EMerr_hndlr(!(1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

		stat_OM = om$get_channel_objects(objid = last_face.objid,
			    osnum = last_face.osnum,
			    p_chanselect = &to_loopset,
			    list= &ls,
			    size = 1,
			    count = &count);
		EMerr_hndlr(!(1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

		stat_OM = EMmake_chanselect(EMSloopset_to_loops, &to_loops);
		EMerr_hndlr(!(1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

		stat_OM = om$get_channel_objects(objid = ls.S_objid,
		    		osnum = OM_Gw_current_OS,
				p_chanselect = &to_loops,
				list= &new_loop,
				size = 1,
			    	count = &count);
		EMerr_hndlr(!(1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

		num_edges_loops = 1;
		loop_id[0] = new_loop.S_objid;
	    }
	    else if(part_type == BOSS) {
		IGRint  edge_num, bufsize;
		OM_S_CHANSELECT  to_common_edge, to_loops;
		OM_S_OBJECT_LINKAGE comm_edge_for_loop, new_loop;
		GRobjid  surf_id;

		/* Get all the edges of last face & find the adjacent
		surface id for the first one. Get the edges of this surface. 
		Find a common edge. Get the loop of the common edge for round 
		operation */

		stat_OM = om$send(msg = message EMSsubbs.EMget_edges(EMmsg,
		    		MAXINT, EMS_OPT_NON_DEG_STITCHED, 
			    	&surfs_info[0].module_info,
			    	&edges, &buf_size, &num_edges),
		  	targetid = last_face.objid,
			targetos = last_face.osnum);
		EMerr_hndlr(!(1 & stat_OM & *EMmsg), *EMmsg, EMS_E_OMerror, 
			wrapup);

	        if(num_edges > MAXEDGES) {
			edge_ids = (GRobjid *) om$malloc(size = num_edges * 
				sizeof(GRobjid));
			if(!edge_ids) {
				*EMmsg = EMS_E_NoDynamicMemory;
				goto wrapup;
			}
		}

		stat_OM = EMmake_chanselect(EMSedge_to_common_edge, 
				&to_common_edge);
		EMerr_hndlr(!(1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

		stat_OM = EMmake_chanselect(EMSedge_to_owner, &to_loops);
		EMerr_hndlr(!(1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

		for(i = 0; i < num_edges; ++i) {
			OMuint count;

			/* get the adjacent surface object id */
			stat_OM = om$send(msg = message 
				EMSboundary.EMgetsurface_info(
				    	EMmsg, &surf_id, NULL),
				    	senderid = edges[i].objid,
				    	p_chanselect = &to_common_edge,
				    	targetos = last_face.osnum);
			EMerr_hndlr(!(1 & stat_OM & *EMmsg), *EMmsg, 
				EMS_E_OMerror, wrapup);

			edge_num = bufsize = 0;

			/* Get the edges of the surface */
			stat_OM = om$send(msg = message EMSsubbs.EMget_edges(
					EMmsg, MAXINT, EMS_OPT_NON_DEG_STITCHED,
				    	&surfs_info[0].module_info,
				    	&boundaries, &bufsize, &edge_num),
			  	targetid = surf_id,
				targetos = last_face.osnum);
			EMerr_hndlr(!(1 & stat_OM & *EMmsg), *EMmsg, 
				EMS_E_OMerror, wrapup);

			/* get the common edge of the non-deg-stitched edge */
			stat_OM = om$get_channel_objects(
					objid = boundaries[3].objid,
				    	osnum = OM_Gw_current_OS,
				    	p_chanselect= &to_common_edge,
				    	list = &comm_edge_for_loop,
				    	size = 1,
				    	count = &count);
			EMerr_hndlr(!(1 & stat_OM), *EMmsg, EMS_E_OMerror, 
				wrapup);

			stat_OM = om$get_channel_objects(
					objid = comm_edge_for_loop.S_objid,
				    	osnum = OM_Gw_current_OS,
				    	p_chanselect= &to_loops,
				    	list = &new_loop,
				    	size = 1,
				    	count = &count);
			EMerr_hndlr(!(1 & stat_OM), *EMmsg, EMS_E_OMerror, 
				wrapup);

			if(same_loop) {
			    if(i == 0)  {
				tmp_loop = new_loop.S_objid;
				loop_id[0] = new_loop.S_objid;
			    }
			    else if(!IF_EQ_OBJID(tmp_loop, new_loop.S_objid)) 
				same_loop = FALSE;
		        }
			edge_ids[i] = boundaries[3].objid;
			om$dealloc(ptr = boundaries);  boundaries = NULL;
		} /* for */
	    } /* if BOSS */

	    rnd_vals[0].type = EMSdatainfo_event;
	    rnd_vals[0].valevent = &round_rad_eve[0];

	    /* Pass the loop id */
	    if(part_type == POCKET || same_loop) {
		num_edges_loops = 1;
		edge_ids[0] = loop_id[0];
	    }
	    /* Pass the list of edges */
	    else 
		num_edges_loops = num_edges;

	    gen_opts |= EFrnd_cham_UNIFORM;

	    active_id.objid = NULL_OBJID;

	    /* Constructs the associative round object */
            {
            IGRushort 				loc_opts;
            struct EMSrnd_boundary_input	*rnd_elems;
            struct EMSrnd_error			*rnd_error = NULL;

            rnd_elems = ( struct EMSrnd_boundary_input * ) alloca
                          ( num_edges_loops * 
                                 sizeof( struct EMSrnd_boundary_input ) );
            for( i = 0; i < num_edges_loops; i++ )
            {
               rnd_elems[i].boundary_id.objid = edge_ids[i];
               rnd_elems[i].boundary_id.osnum = OM_Gw_current_OS;
               OM_BLOCK_MOVE( &rnd_vals[0],
                              &rnd_elems[i].radius,
                              sizeof( struct EMSvalue_info ) );
               rnd_elems[i].props =
               rnd_elems[i].options = 0;
               rnd_elems[i].rho_value.type =
               rnd_elems[i].other_radius.type = EMSdatainfo_undefined;
            }

            loc_opts = (gen_opts & EFrnd_cham_PLACE_NON_ASSOC ? 
                        EMS_RND_NON_ASSOCIATIVE : NULL) |
                       (gen_opts & EFrnd_cham_CREATE_SOURCE ?
                        EMSasconst_createsource : NULL);
	    stat_OM = EMround_chamfer_edges(EMmsg, loc_opts,
                       const_list->env_info,
                       num_edges_loops, rnd_elems, &rnd_error,
                       &active_id );

	    if( !(1 & stat_OM & *EMmsg ) )
            {
               /*
                * Need to include code here to delete the 'rnd_error'
                * packet (janaka).
                */

               *EMmsg = EMS_E_Fail;
               goto wrapup;
            }

            }

	    /* Set the dpr bit */
	    stat_OM = om$send(msg = message EMSdpr.EMsetprops(EMmsg, 
				&action, &mask),
	 		senderid = NULL_OBJID,
			targetid = active_id.objid,
			targetos = surfs_info[0].located_obj.osnum);

	    EMerr_hndlr(!(1 & stat_OM & *EMmsg), *EMmsg, EMS_E_Fail,wrapup);

	    /* add the state of round operation */
	    ME.EMSsfmacro->num_states++;
	} /* if round bottom edges */
	else active_id = new_solid;

	/* Create the macro object */
	if(!(gen_opts & EMSasconst_recompute)) {
		stat_OM = om$send(msg = message EMSsfmacro.EMcreate_yourself(
			EMmsg, active_id.objid, ME.EMSsfmacro->num_states, 
		    	&surfs_info[0].module_info),
		    targetid = my_id);
		EMerr_hndlr(!(1 & stat_OM & *EMmsg), *EMmsg, EMS_E_OMerror, 
			wrapup);
	}

        

	if(part_type == POCKET)
           ME.EMSassoc->type = EMS_I_AM_A_MACFEA_POCKET;
        else if ( part_type == BOSS)
           ME.EMSassoc->type = EMS_I_AM_A_MACFEA_BOSS;


wrapup:
	/* if construction error, the model will be recovered */
	if(!(1 & *EMmsg) || *EMmsg == EMS_I_RndGrExit) {
		IGRint  display_count, involk_count;
		IGRlong  loc_msg;
		GRobjid  *display_ids;
		IGRushort  option;

		stat_OM = EMS_E_Success;
		display_ids = NULL;
		display_count = involk_count = 0;
		option = EMS_UNDO_DELETE | EMS_DO_DISPLAY;

		if(!(gen_opts & EMSasconst_recompute)) {
			stat_OM = om$send(msg = message 
				EMSsurface.EMmake_active_state( &loc_msg,
			    	&option,
			    	&surfs_info[0].module_info,
			    	NULL,	/* Active ids after undo */
				NULL,	/* Number of active ids - better be 1 */
				/* Space manager for memory on active ids */
				NULL, 	
				&display_ids,	
			    	&display_count,	
			    	&involk_count),
			targetid = solid_id->objid,
			targetos = solid_id->osnum);
		}
	}

	if(edges)  om$dealloc(ptr = edges);
	if(boundaries)  om$dealloc(ptr = boundaries);
	if(round_edge && num_edges > MAXEDGES)
		if(edge_ids)  om$dealloc(ptr = edge_ids);

	EMWRAPUP(*EMmsg, stat_OM, "In EMSslmacfea.EMmake_pocket")
	    return(stat_OM);

} /* EMmake_pocket */

end implementation EMSslmacfea;
