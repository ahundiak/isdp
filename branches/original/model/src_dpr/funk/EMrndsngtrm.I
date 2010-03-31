class implementation EMSsfrndbool;

#include "OMmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emssfint.h"
#include "emssfintdef.h"
#include "emsinterdef.h"
#include "emsdattyp.h"
#include "bsgeom_cvsf.h"
#include "EMSrndprotyp.h"
#include "prototypes/bsconstprcv.h"
#include "prototypes/bsalloccv.h"
#include "prototypes/bsfreecv.h"
#include "prototypes/bsmdistptsf.h"
#include "prototypes/bsallocsf.h"
#include "prototypes/bsreffilsrf.h"
#include "prototypes/bsfreesf.h"
#include "bsreffilsrf.h"
#include "bsparameters.h"
#include "bsmdistptsf.h"
#include "bsfreesf.h"
#include "bsfreecv.h"
#include "bsconstprcv.h"
#include "bsallocsf.h"
#include "bsalloccv.h"

#define U0		0
#define U1		1
#define V0 		0
#define V1		1
#define RND_EDGE	0
#define COMMON_EDGE	1

from EMSedge 	import EMget_props, EMget_bcxyz_geom, EMptproject;
from EMSloopset import EMlsparttrim;

%safe
static void get_inter_end_pts( IGRlong *EMmsg, IGRshort dimension,
                struct EMSdataselect *intersection, IGRdouble *end_pts );
%endsafe

/* pathway flags */
extern IGRboolean _pathway_trim, _pathway_orient;



/*
 * DESCRIPTION
      This is a 3-edge vertex processing function, where the 3-edge is
      assumed to be of the following configuration.
      None of the edges are neutral, and the edge being rounded has a
      classification that differs from the remaining two edges at the vertex.
      It is the callers responsibility to validate this condition.
      The solution at this vertex is a trim of the fillet against the model
      surface that is not one of the defining surfaces for the fillet.

      Limitations:
         . Topological interactions between the fillet and the model surfaces
           must be visible to the round vertex.

 * OPTIONS:
      None.

 * INPUT:
      options		None.
      const_list	Construction environment.
      vtx_rnd_info	Information concerning the round vertex.

 * OUTPUT
      EMmsg		EMS errors.
      return value	OM errors.
      fillet_inters	The intersections on the fillet generated within
                        this function are appended to this list.  If
                        (*fillet_inters) == NULL, then memory will be
                        allocated within this function.
      model_inters	As above, for the model.

 * ALGORITHM:
      If needed, refine the fillet such that it is ON the appropriate
      boundaries on the two surfaces that is defining the fillet (only at the
      fillet end that is close to this round vertex).  Determine the model
      surface that is the one not defining the fillet.  Intersect the fillet
      with this model surface.  In case of multiple intersections, choose the
      one closest to the round vertex.  Determine, whether this is a complete
      (i.e. it spans U0 - U1 iso edges of the fillet) intersection on the
      fillet (due to bounded surfaces, there is a possibility of this being
      not TRUE).  If so, generate intedpars for the intersection and add it
      to the input intersection lists.

      For detailes see STEPs within the function.

      NOTE: There are two gotos within the code.
              . The universal 'wrapup'.
              . 'continue_with_old_fillet': It is possible for fillet
                refinement to fail.  On such instances, control is passed to
                this label, which is at the STEP following the fillet
                refinement in the algorithm.  This allows the processing to
                continue with the old fillet, in the hope that it is
                sufficiently accurate for the vertex processing to succeed
                (there is no way to determine this prior to refinement).

 * HISTORY:
      Janaka : 02/11/93 : Original.
      Sudha    06/23/93   Modified for BSprototype ansification
*/

#argsused

IGRlong EM3edge_single_trim( EMmsg, options, const_list, vtx_rnd_info,
                             fillet_inters, model_inters )

IGRlong			*EMmsg;
IGRushort		options;
struct GRvg_construct	*const_list;
struct EMSvtx_rnd_info	*vtx_rnd_info;
struct EMSinters	**fillet_inters, **model_inters;

{
   IGRboolean	at_stop_end[2], test_planarity, nor1, nor2,
                fillet_inter_begin_at_U0, are_identical;
   IGRushort	world_opts, uv_opts, trim_opts, com_ed_props,
                next_ed_props;
   IGRshort	mat_type, param_opt;
   IGRint	i, rnd_ed_inx, num_vtx_edges, num, num_skipped,
                num_intobjs_to_keep;
   IGRlong	OM_stat, msg, num_inters;
   IGRdouble	param, pt_uv[2], min_dist, rho_value,
                arc_begin_pt_uv[2][2], arc_end_pt_uv[2][2],
                fill_inter_end_uv[2][2], model_inter_end_uv[2][2],
                fillet_param_tol, *matrix, xyz_tol;
   IGRpoint     pt_xyz, dum_pt, arc_begin_pt_xyz[2];
   GRobjid	fillet_objid, model_sf_objid, rnd_ed_objid, next_eds[2],
                next_eds_common_eds[2], dum_objid, rnd_ed_common_ed;
   GRspacenum	osnum;

   OM_S_CHANSELECT	chan_to_common_edge;
   OM_S_OBJECT_LINKAGE	object_list;

   struct GRmd_env     		*md_env;
   struct GRpost_info		post_info;
   struct EMSedge_rnd_info	**edge_infos;
   struct GRid			model_sf_GRid, tmp1_GRid;
   struct EMSdataselect		other_data, sf1, sf2, sf3, sf4,
                                tmp1_dataselect, tmp2_dataselect;
   struct EMSinters		*loc_fillet_inters, *loc_model_inters;
   struct IGRbsp_curve		*edge_geom;
   struct IGRbsp_surface	*model_sf, *mod_fillet_geom, *fillet_geom;
   struct EMSintobj		*tmp_intobj, **keep_intobjs;
   struct EMSpartolbasis	partol_basis;
   struct EMSsfintedpar         *tmp_intedpar;

   IGRboolean save_pathway_trim, save_pathway_orient;

   extern struct EMSsfintedpar*	EMsfintedpar_malloc();
   extern void EMdelintobj();


   /* STEP 0:
    *
    * Initialize, and gather some information useful
    * in later steps.
    */
      OM_stat = OM_S_SUCCESS;
      *EMmsg  = EMS_S_Success;
      md_env = const_list->env_info;
      mat_type = md_env->md_env.matrix_type;
      osnum = md_env->md_id.osnum;
      matrix = md_env->md_env.matrix;
      partol_basis.in_world = TRUE;
      partol_basis.mattyp = &mat_type;
      partol_basis.mat = matrix;

      EMmake_chanselect( EMSedge_to_common_edge, &chan_to_common_edge );
      BSEXTRACTPAR( &msg, BSRHO_VALUE, rho_value );

      loc_fillet_inters =
      loc_model_inters = NULL;
      mod_fillet_geom = NULL;
      model_sf = NULL;
      edge_geom = NULL;
      keep_intobjs = NULL;

      /* Get the round edge and fillet information. */

          edge_infos = vtx_rnd_info->edge_infos;
          num_vtx_edges = vtx_rnd_info->num_edges;
          for( rnd_ed_inx = 0; rnd_ed_inx < num_vtx_edges; rnd_ed_inx++ )
             if( edge_infos[ rnd_ed_inx ] )
                break;
          rnd_ed_objid = vtx_rnd_info->edge_ids[ rnd_ed_inx ];

          fillet_objid = edge_infos[ rnd_ed_inx ]->fill_id;
          fillet_geom = edge_infos[ rnd_ed_inx ]->fill_surf;

          OM_stat = om$get_channel_objects(
                               objid = rnd_ed_objid,
                               p_chanselect = &chan_to_common_edge,
                               list = &object_list,
                               size = 1,
                               count = ( IGRuint * ) &num );
          EMerr_hndlr( !( 1 & OM_stat ) || num != 1, *EMmsg, EMS_E_EdgeError,
                       wrapup );
          rnd_ed_common_ed = object_list.S_objid;

          OM_stat = om$send( msg = message EMSedge.EMget_props
                                ( &msg, &com_ed_props ),
                             targetid = rnd_ed_common_ed,
                             senderid = NULL_OBJID );
          EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_EdgeError,
                       wrapup );

          at_stop_end[ RND_EDGE ] = vtx_rnd_info->edge_stops[ rnd_ed_inx ];
          at_stop_end[ COMMON_EDGE ] = com_ed_props & EMED_REVERSE_CONNECT
                            ? ( at_stop_end[0] == TRUE ? FALSE : TRUE )
                            : at_stop_end[0];

      /* Get next edges of the round edge and its common edge, and also
       * the common edges of the next edges.
       */
           for( i = RND_EDGE; i <= COMMON_EDGE; i++ )
           {
              OM_stat = EMgetnxtedges( &msg, EMSvtxedges_nodegenerate,
                     i ? rnd_ed_common_ed : rnd_ed_objid, OM_Gw_current_OS,
                     at_stop_end[i], ( IGRint ) 1, &num,
                     &next_eds[i], &next_ed_props, &num_skipped );
              EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_EdgeError,
                           wrapup );
               OM_stat = om$get_channel_objects ( objid = next_eds[i],
                                  osnum = osnum,
                                  p_chanselect = &chan_to_common_edge,
                                  count = ( IGRuint * ) &num,
                                  size = ( OMuint ) 1,
                                  list = &object_list );
              EMerr_hndlr( !( 1 & OM_stat) || num != 1, *EMmsg,
                           EMS_E_EdgeError, wrapup );
              next_eds_common_eds[i] = object_list.S_objid;
           }

       /* Get the model surface (that is not one of the fillet's defining
        * surfaces) information.
        */
           partol_basis.is_valid = FALSE;
           OM_stat = EMget_rndedge_neighbors_sf_id( &msg,
               next_eds_common_eds[ RND_EDGE ], edge_infos[ rnd_ed_inx ],
               &model_sf_objid, &partol_basis );
           EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, msg, wrapup );
           model_sf_GRid.objid = model_sf_objid;
           model_sf_GRid.osnum = osnum;
           OM_stat = EMgetvggeom( &msg, &mat_type, matrix, &model_sf_GRid,
                                  &model_sf, NULL );
           EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_SurfaceError,
                    wrapup );

      goto Continue_With_Old_Fillet;

   /* STEP 1:
    *
    * Refine the fillet at the following two intersection points.
    *  a. Intersection between a theoretically accurate fillet, the
    *     model surface defining fillet U0, and the model surface that is
    *     not defining the fillet.
    *  b. Repeat (a) with fillet's U0 defining model surface replaced with
    *     that of fillet's U1 defining model surface.
    * Failure during new fillet arc generation, or during the refitting of
    * a new fillet to pass through the new arcs, will cause processing to
    * continue onto STEP 2, with the existing fillet.
    */
        if( ( at_stop_end[ RND_EDGE ] == TRUE
               ? edge_infos[ rnd_ed_inx ]->props
                              & EMSfillet_inaccurate_atstop
               : edge_infos[ rnd_ed_inx ]->props
                              & EMSfillet_inaccurate_atstart ) )
        {
           sf1.datatype =
           sf2.datatype =
           sf3.datatype =
           sf4.datatype = EMSdata_surface;
           sf1.data.surface = edge_infos[ rnd_ed_inx ]->surf;
           sf2.data.surface = edge_infos[ rnd_ed_inx ]->com_surf;
           sf3.data.surface = model_sf;
           sf4.data.surface = fillet_geom;
        
           /* Generate two new fillet arcs:
            *  . One emanating from the proximity of the intersection between
            *    the fillet U0, and the round edge's next edge on the model,
            *    that is on the same surface as the fillet U0 defining model
            *    surface.
            *  . The other emanating from the proximity of the intersection
            *    between fillet U1, and the round edge's common edge's next
            *    edge on the model, that is on the same surface as the fillet
            *    U1 defining model surface.
            */
              for( i = U0; i <= U1; i++ )
              {
                 /* Obtain the approximate fillet arc begin point either
                  * on U0 or on U1.
                  */
                 param_opt = 1;
                 param = i;
                 BSalloccv( fillet_geom->v_order, fillet_geom->v_num_poles,
                   fillet_geom->rational, ( IGRshort ) 0, &edge_geom, &msg );
                 EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory,
                   wrapup );
                 BSconstprcv( &msg, fillet_geom, &param_opt, &param,
                              &test_planarity, edge_geom );
                 EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );

                 tmp1_dataselect.datatype = EMSdata_curve3d;
                 tmp1_dataselect.data.curve = edge_geom;
                 tmp1_GRid.objid = next_eds[i];
                 tmp1_GRid.osnum = osnum;
                 tmp2_dataselect.datatype = EMSdata_object;
                 tmp2_dataselect.data.object = &tmp1_GRid;

                 OM_stat = EMget_edges_int_pt( &msg, md_env, 
                             vtx_rnd_info->vtx_pt, &tmp1_dataselect,
                             &tmp2_dataselect, &pt_xyz[0], NULL, NULL, NULL );
                 EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_Fail,
                              wrapup );
                 BSfreecv( &msg, edge_geom );
                 edge_geom = tmp1_dataselect.data.curve = NULL;

                 /* Project point 'pt_xyz' onto appropriate model
                  * surface to obtain approximate fillet arc start
                  * point uv.
                  */
                     BSmdistptsf( &msg,
                                  i == U1 ? edge_infos[ rnd_ed_inx ]->com_surf
                                          : edge_infos[ rnd_ed_inx ]->surf,
                                  pt_xyz, &pt_uv[0], &pt_uv[1], dum_pt,
                                  &min_dist );
                     EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror,
                                  wrapup );

                 /* For each of the fillet's defining model surfaces,
                  * determine which side of the surface the fillet is
                  * w.r.t. the surfaces natural normal.
                  */
                     if( vtx_rnd_info->edge_configs[ rnd_ed_inx ] ==
                             EMSedge_convex )
                     {
                        nor1 = i == U1 ? sf2.data.surface->pos_orient
                                       : sf1.data.surface->pos_orient;
                        nor2 = i == U1 ? sf1.data.surface->pos_orient
                                       : sf2.data.surface->pos_orient;
                     }
                     else
                     {
                        nor1 = i == U1 
                                 ? ( sf2.data.surface->pos_orient == TRUE
                                        ? FALSE : TRUE )
                                 : ( sf1.data.surface->pos_orient == TRUE
                                        ? FALSE : TRUE );
                        nor2 = i == U1
                                 ? ( sf1.data.surface->pos_orient == TRUE
                                        ? FALSE : TRUE )
                                 : ( sf2.data.surface->pos_orient == TRUE
                                        ? FALSE : TRUE );
                     }

                 /* Obtain the two end points of the new fillet arc */

                    OM_stat = EMsingle_fillet_refine( &msg, ( IGRushort ) 0,
                      md_env, &sf4,
                      i == U1 ? &sf2 : &sf1,
                      i == U1 ? &sf1 : &sf2,
                      &sf3, pt_uv,
                      i == U1 ? FALSE : TRUE,
                      edge_infos[ rnd_ed_inx ]->radius, NULL,
                      nor1, nor2, NULL, arc_begin_pt_xyz[i],
                      arc_begin_pt_uv[i], arc_end_pt_uv[i] );

                    if( !( 1 & OM_stat &msg ) )
                       goto Continue_With_Old_Fillet;
              }

           /* Refine the fillet to include the fillets arcs determined above.
            */
               if( vtx_rnd_info->edge_configs[ rnd_ed_inx ] ==
                             EMSedge_convex )
               {
                  nor1 = sf1.data.surface->pos_orient;
                  nor2 = sf2.data.surface->pos_orient;
               }
               else
               {
                  nor1 = sf1.data.surface->pos_orient == TRUE
                              ? FALSE : TRUE;
                  nor2 = sf2.data.surface->pos_orient == TRUE
                              ? FALSE : TRUE;
               }

               BSallocsf( fillet_geom->u_order, fillet_geom->v_order,
                          fillet_geom->u_num_poles,
                          fillet_geom->v_num_poles + 2,
                          fillet_geom->rational, ( IGRshort ) 0,
                          &mod_fillet_geom, &msg );
               EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory,
                            wrapup );

               BSreffilsrf( sf1.data.surface, sf2.data.surface, fillet_geom,
                       nor1, nor2, edge_infos[ rnd_ed_inx ]->radius,
                       rho_value, 1, &arc_begin_pt_xyz[0],
                       &arc_begin_pt_uv[0][0], &arc_begin_pt_uv[0][1],
                       &arc_end_pt_uv[0][0], &arc_end_pt_uv[0][1],
                       1, &arc_begin_pt_xyz[1], &arc_begin_pt_uv[1][0],
                       &arc_begin_pt_uv[1][1], &arc_end_pt_uv[1][0],
                       &arc_end_pt_uv[1][1], mod_fillet_geom, &msg );

               if( msg != BSSUCC ) 
                 goto Continue_With_Old_Fillet;

               /* Delete the old fillet surface, and update all references
                * to the old fillet geometry.  Also, post the new geometry
                * into the fillet object.
                */
                   post_info.construct_flag = FALSE;
                   OM_stat = om$send( msg = message GRvg.GRpostabsg(
                                      &msg, md_env, &post_info,
                                      ( IGRchar* ) mod_fillet_geom,
                                      &dum_objid ),
                              senderid = NULL_OBJID,
                              targetid = fillet_objid );
                   EMerr_hndlr( !( msg & OM_stat & 1 ), *EMmsg,
                                EMS_E_SurfaceError, wrapup );

                   GRabsg_del_by_objid( &fillet_objid, &osnum );

                   BSfreesf( &msg, fillet_geom );
                   edge_infos[ rnd_ed_inx ]->fill_surf = mod_fillet_geom;
                   mod_fillet_geom = NULL;

           /* Assert that this end of the fillet has been modified. */
              edge_infos[ rnd_ed_inx ]->props &= 
                     at_stop_end[ RND_EDGE ] == TRUE
                           ? ~EMSfillet_inaccurate_atstop
                           : ~EMSfillet_inaccurate_atstart;
        }

   Continue_With_Old_Fillet:

   /* STEP 2:
    *
    * Intersect the fillet with the model surface that is not one of the
    * defining surfaces of the fillet.  If a full intersection on the fillet
    * was obtained, then add the intersections to the fillet and model inters.
    * The possibility of not obtaining a full intersection (or any
    * intersection at all) exists, since surfaces in EMS are bounded surfaces.
    * In such instances, this function does not attempt to extend such model
    * surfaces prior intersection (perhaps should do that).  In case of
    * mutiple intersections, the one closest to the round vertex is choosen.
    * Seam edges on the model surface are not accommodated.
    */
       other_data.datatype = EMSdata_object;
       other_data.data.object = &model_sf_GRid;
       
       world_opts = EMSINT_OUTPUT_WORLD;
       uv_opts = EMSINT_OUTPUT_PARAM | EMSINT_ORIENT_OUTPUT;
       if( vtx_rnd_info->edge_configs[ rnd_ed_inx ] == EMSedge_concave )
          uv_opts |= EMSINT_ORIENT_RIGHT;
       trim_opts = 0; /* Ignore boundaries on the surface, since intersections
                       * occuring inside a hole in the model surface are legal
                       * for this vertex processing function.
                       */

       save_pathway_trim = _pathway_trim;
       save_pathway_orient = _pathway_orient;
       _pathway_trim = 0;
       _pathway_orient = 0;

       num_inters = 0;
       OM_stat = om$send(
                   msg = message EMSsurface.EMsfsfint( &msg,
                                &mat_type, matrix, const_list, &other_data,
                                &md_env->md_env,
                                world_opts, uv_opts, trim_opts,
                                &num_inters, &loc_fillet_inters,
                                &loc_model_inters ),
  		   senderid = NULL_OBJID,
		   targetid = fillet_objid,
                   targetos = osnum );

       _pathway_trim = save_pathway_trim;
       _pathway_orient = save_pathway_orient;

       EMerr_hndlr( !( 1 & OM_stat & msg ) || !num_inters , *EMmsg,
                    EMS_E_SurfaceError, wrapup );

       /* It is possible to receive mutiple, discontinuous intersections.
        * In such instances, pick the intersection closest to the round
        * vertex point.
        */
           OM_stat = EMweed_out_inters( &msg, ( IGRushort ) 0, md_env,
                          vtx_rnd_info->vtx_pt, loc_fillet_inters,
                          &num_intobjs_to_keep, &keep_intobjs,
                          &are_identical );
           /* Number of intersections to keep can be more than one, due
            * to seam edges.  However, since seam edges are not handled,
            * this is an error condition.
            */
               EMerr_hndlr( !( 1 & msg & OM_stat ) ||
                   num_intobjs_to_keep != 1, *EMmsg, EMS_E_Fail, wrapup );

           if( are_identical == FALSE )

              /* Remove the extraneous intersections from the inters lists. */
              for( tmp_intobj = loc_fillet_inters->cvs; tmp_intobj;
                   tmp_intobj = tmp_intobj->next )

                 if( tmp_intobj != *keep_intobjs )
                 {
                    /* Delete this intobj and its counter part, and make
                     * necessary changes to the corresponding EMSinters
                     * nodes.
                     */
                    EMdelintobj( &msg, tmp_intobj );
                    EMerr_hndlr( !( 1 & msg ), *EMmsg, EMS_E_Fail, wrapup );
                 }

       /* Assert (subjected to whether the fillet refinement was successful)
        * that this intersection does not need any refinement at any one of
        * its ends.
        */
           if( !( at_stop_end[ RND_EDGE ] == TRUE
                  ? edge_infos[ rnd_ed_inx ]->props
                              & EMSfillet_inaccurate_atstop
                  : edge_infos[ rnd_ed_inx ]->props
                              & EMSfillet_inaccurate_atstart ) )
           {
              loc_fillet_inters->cvs->props |= EMSintobj_exact_atstart |
                                            EMSintobj_exact_atstop;

              loc_fillet_inters->cvs->other_intobj_node->props
                      |= EMSintobj_exact_atstart | EMSintobj_exact_atstop;
           }

       /* Assert that the intersection on the solid is not in the area (i.e.
        * it is either increasing the area bounded by a p-loop, or decreasing
        * the area excluded by a c-loop).
        */
           loc_fillet_inters->cvs->other_intobj_node->props
                                             |= EMSintobj_not_in_area;

       /* Determine whether the single intersection was a full intersection
        * (at least on the fillet, thus assuming the corresponding
        * intersection on the model to be accurate).  This assumes that the
        * fillet penetrated completely through the model surface.
        * Also, determine the direction of the intersection on the fillet
        * (i.e. U0 -> U1 ? ).
        */
           get_inter_end_pts( &msg, 2, &loc_fillet_inters->cvs->this_uvintobj,
                              &fill_inter_end_uv[0][0] );
           EMerr_hndlr( !( 1 * msg ), *EMmsg, EMS_E_Fail, wrapup );
           get_inter_end_pts( &msg, 2, &loc_model_inters->cvs->this_uvintobj,
                              &model_inter_end_uv[0][0] );
           EMerr_hndlr( !( 1 * msg ), *EMmsg, EMS_E_Fail, wrapup );
 
           fillet_param_tol = edge_infos[ rnd_ed_inx ]->fill_surf_tol;
           if( ( ( fill_inter_end_uv[0][0] - U0 ) > fillet_param_tol &&
                 ( U1 - fill_inter_end_uv[0][0] ) > fillet_param_tol ) ||

               ( ( fill_inter_end_uv[1][0] - U0 ) > fillet_param_tol &&
                 ( U1 - fill_inter_end_uv[1][0] ) > fillet_param_tol ) )
           {
              *EMmsg = EMS_E_Fail;
              goto wrapup;
           }

           fillet_inter_begin_at_U0 = TRUE;
           if( ( fill_inter_end_uv[0][0] - U0 ) > fillet_param_tol )
              fillet_inter_begin_at_U0 = FALSE;

       /* 
	*  Construct 'more_info' for each of the intersections.
        */

           tmp_intedpar = EMsfintedpar_malloc( &msg, 2 );
           EMerr_hndlr( tmp_intedpar == NULL, *EMmsg, EMS_E_NoDynamicMemory,
                        wrapup );

           loc_model_inters->cvs->more_info = ( IGRchar * ) tmp_intedpar;
           BSEXTRACTPAR (&msg, BSTOLCHRDHT, xyz_tol);
           xyz_tol *= 2;

           /* 
	    *  Get the correct incident edge information for
	    *  the both end of the intersection.
	    */

           partol_basis.is_valid = TRUE;	
           for( i = 0; i < 2; i++ )
           {

              EMgetincinfo (&msg, OM_Gw_current_OS, NULL_OBJID, FALSE,
               model_inter_end_uv[i], &mat_type, matrix, model_sf_objid,
               xyz_tol, partol_basis.tol, tmp_intedpar);
              EMerr_hndlr (EMSerror (msg), *EMmsg, EMS_E_Fail, wrapup);

              tmp_intedpar = tmp_intedpar->next;
           }

       /* On the fillet, do two NULL_OBJID intedpars [EMround() will
        * fill these].
        */
           loc_fillet_inters->cvs->more_info = ( IGRchar * )
                                      EMsfintedpar_malloc( &msg, 2 );
           EMerr_hndlr( loc_fillet_inters->cvs->more_info == NULL, *EMmsg,
                        EMS_E_NoDynamicMemory, wrapup );

   /* STEP 3: Assign output */
      EMmergeinters( &msg, fillet_inters, loc_fillet_inters );
      EMerr_hndlr( !( 1 & msg ), *EMmsg, msg, wrapup );
      loc_fillet_inters = NULL;
      EMmergeinters( &msg, model_inters, loc_model_inters );
      EMerr_hndlr( !( 1 & msg ), *EMmsg, msg, wrapup );
      loc_model_inters = NULL;

wrapup:
   if( model_sf ) om$dealloc( ptr = model_sf );
   if( edge_geom ) BSfreecv( &msg, edge_geom );
   if( mod_fillet_geom ) BSfreesf( &msg, mod_fillet_geom );
   if( loc_fillet_inters )
      EMinters_free( loc_fillet_inters, MAXINT );
   if( loc_model_inters )
      EMinters_free( loc_model_inters, MAXINT );
   if( keep_intobjs )
      om$dealloc( ptr = keep_intobjs );

   EMWRAPUP( *EMmsg, OM_stat, "EM3edge_single_trim" );
   return( OM_stat );
}



/*
 * DESCRIPTION:
      Given an intersection, return its begin and end points, in the
      the direction of its natural parameterization.

 * OPTIONS:
      None.

 * INPUT:
      dimension		2 or 3, indicating that the intersection data is
                        either in uv space, or in model space, respectively.
      intersection

 * OUTPUT:
      EMmsg		EMS errors.
      end_pts		The end points of the intersection, in the direction
                        of its natural parameterization (i.e. the begin point
                        will be followed by the end point).  The user must
                        allocate memory with respect to 'dimension'.
 * ALGORITHM:
      Trivial.

 * HISTORY:
      Janaka : 02/11/93 : Original.
 */

static void get_inter_end_pts( IGRlong *EMmsg, IGRshort dimension,
                struct EMSdataselect *intersection, IGRdouble *end_pts )
{
   IGRboolean	rational;
   IGRshort	i, j, index, inter_space_dim;
   IGRlong      num_uvpoints;
   IGRdouble	*uvpoints, weights[2];

   *EMmsg = EMS_S_Success;
   rational = FALSE;
   inter_space_dim = 3;

   if( intersection->datatype == EMSdata_poly2d ||
       intersection->datatype == EMSdata_poly3d )
   {
      uvpoints = intersection->data.poly->points;
      num_uvpoints = intersection->data.poly->num_points;
      if( intersection->datatype == EMSdata_poly2d )
         inter_space_dim = 2;
   }
   else
      if( intersection->datatype == EMSdata_curve3d /* curve2d is a myth */ )
      {
         uvpoints = intersection->data.curve->poles;
         num_uvpoints = intersection->data.curve->num_poles;
         if( ( rational = intersection->data.curve->rational ) )
         {
            if( intersection->data.curve->weights != NULL )
            {
               weights[0] = intersection->data.curve->weights[0];
               weights[1] = intersection->data.curve
                                ->weights[ num_uvpoints - 1 ];
            }
            else
            {
               *EMmsg = EMS_E_BSerror;
               goto wrapup;
            }
         }
      }
      else
      {
         *EMmsg = EMS_E_InvalidArg;
         goto wrapup;
      }

   for( i = 0; i < 2; i++ )
     /* Get the first and the last points in the intersection */
   {
      index = i ? ( num_uvpoints - 1 ) * inter_space_dim : 0;
      for( j = 0; j < dimension; j++ )
        /* Work either in 2D or 3D as specified by 'dimension' */
      {
        *end_pts = uvpoints[ index + j ];
        if( rational == TRUE )
           *end_pts /= weights[i];
        end_pts++;
      }
   }

wrapup: ;

}


end implementation EMSsfrndbool;
