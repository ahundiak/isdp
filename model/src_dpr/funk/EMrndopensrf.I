class implementation EMSsfrndbool;

/*
 * INPUT

   options         - Typical "options" ( not used right now ).
   construct_list  - construction list.
   vertex_info     - Information packet concerning the vertex that is being
                     processed.

 * ALGORITHM (summary)

   [1] Initialize and collect global information.
   [2] Determine the intersection points between fillets iso edges U0, U1,
       and the appropriate edges on the surfaces. 
   [3] Generate an infinite plane passing through the vertex and the
       intersection points of the iso curves and the edges at the vertex.
   [4] Generate the intersecion curve (V0 or V1 )on the fillet by intersecting 
       the fillet with this infinte radial plane and add it to inters list.
   [5] Orient the intersection and add it to the fillet inters list.

 * HISTORY
      KNAP : 12/10/93 : Creation.
			Most of the code is from EMsingle_patch
			and EM3edge_single_trim.
      KNAP : March'9, 95  : Removed EFget_inf_plane_srf_int, and replaced
                            it with EMget_fillet_intpln_data().
*/

#include <math.h>
#include "bserr.h"
#include "bsparameters.h"
#include "OMmacros.h"
#include "emsedgedef.h"
#include "EMSlmdef.h"
#include "emssfintdef.h"
#include "EMSrnd.h"
#include "bsrev_cv.h"
#include "bsmdstptcv.h"
#include "bsmdistcvcv.h"
#include "bsalloccv.h"


/* imports */

from EMSsubbs    import EMget_edges;
from EMSedge     import EMget_bcxyz_geom, EMget_props;

#define  U0    0
#define  V1    1
#define  U1    2
#define  V0    3

#define CONST_U  1
#define CONST_V  2

#define  START	0
#define  STOP   1

#define WBC_USE_NEW_MATH 1

#define MAX_TO_STACK_ALLOC 10



#argsused

IGRlong EMopen_surf_round( EMmsg, options, construct_list, vertex_info,
                           fillet_inters)
IGRlong			*EMmsg;
IGRushort		options;
struct GRvg_construct	*construct_list;
struct EMSvtx_rnd_info	*vertex_info;
struct EMSinters	**fillet_inters;
{
  IGRuchar		   curve_type;
  IGRlong		   stat_OM, msg_loc;

  GRobjid		   next_edge[2], next_edge_common_edge[2], 
  		   	   com_ed_id, *vtx_edges,
                           *vtx_edges_stack_mem = NULL;
  GRspacenum		   osnum;

  IGRint	   	   num_edges, array_size, num, num_ret, num_skipped,
			   index, prev, next, i, j, ed_inx;

  IGRpoint 	      	   points[2];
  IGRboolean	      	   ed_inx_flag,rnd_vtx_is_edge_stop_end[2];
  IGRboolean               next_edge_common_edge_exists[2];
  IGRboolean               fillet_inter_begin_at_U0,reverse_a;
  IGRushort		   com_ed_props, ed_props,fill_props;

  IGRdouble	       	   *pars0, *pars1, *xyz_pts0, *xyz_pts1, *vtx_pt,
                           cht_tol, basis_tol, dist,par;

  IGRdouble                fill_inter_end_uv[2][2];
  IGRdouble                fillet_param_tol;

  struct IGRbsp_curve      *curve;
  struct IGRbsp_curve	   fedge_geom[2], medge_geom[2];

  struct IGRbsp_surface    *surf, *fillet_surf;
  struct EMSedge_rnd_info  **vtx_edge_infos = NULL;

  struct GRmd_env	   *my_env;
  struct GRid		   fillet_id, *sf_edges;

  struct EMSdataselect     fillet_inter_UV_data,
                           inter_XYZ_data,
                           new_uvdata;

  OM_S_CHANSELECT	   to_common_edge;

  OM_S_OBJECT_LINKAGE	   object_list;

  extern void		   EFfind_the_closest_pt();
  extern IGRdouble         EMget_fillet_intpln_data();
  extern IGRuchar          EMcurve_typing();

  extern struct EMSsfintedpar	*EMsfintedpar_malloc();
  extern struct EMSintobj	*EMmakeintlist();
			

   /*
    * STEP 1: Initialize and gather some global data.
    */
     *EMmsg = EMS_S_Success;
     stat_OM= OM_S_SUCCESS;

     curve = NULL;
     pars0 = NULL;
     pars1 = NULL;
     xyz_pts0 = NULL;
     xyz_pts1 = NULL;

     surf     = NULL;
     fillet_surf = NULL;
     ed_inx = 0;    /* Stop compiler warnings. */

     vtx_edges = NULL;
     vtx_edges_stack_mem = ( GRobjid * ) alloca(
                               MAX_TO_STACK_ALLOC * sizeof( GRobjid ) );

     my_env = construct_list->env_info;
     osnum = my_env->md_id.osnum;

     vtx_pt             = vertex_info->vtx_pt;
     vtx_edge_infos     = vertex_info->edge_infos;

     EMmake_chanselect( EMSedge_to_common_edge, &to_common_edge );

     BSEXTRACTPAR( &msg_loc, BSTOLCHRDHT, cht_tol );
     BSEXTRACTPAR( &msg_loc, BSTOLLENVEC, basis_tol );

     /* Get the index of the edge to be rounded */

     for( index = 0; index < vertex_info->num_edges; index++)
        if( vertex_info->edge_infos[index])
	   break;

     prev = (index == 0) ? (vertex_info->num_edges - 1) : (index - 1);
     next = (index == (vertex_info->num_edges - 1)) ? 0 : (index + 1);

     /* Get the common edge and its properties */

     num = 0;
     stat_OM = om$get_channel_objects( objid = vertex_info->edge_ids[index],
                                       p_chanselect = &to_common_edge,
                                       list         = &object_list,
                                       size         = 1,
                                       count        = ( IGRuint * ) &num);
     EMerr_hndlr(! (1 & stat_OM ) || !num, *EMmsg,EMS_E_OMerror,wrapup);

     com_ed_id = object_list.S_objid;

     stat_OM = om$send( msg = message EMSedge.EMget_props
				( &msg_loc,
				  &com_ed_props ),
                        senderid = NULL_OBJID,
                        targetid = com_ed_id);

     EMerr_hndlr (!(1& stat_OM & msg_loc), *EMmsg, EMS_E_EdgeError, wrapup);

     rnd_vtx_is_edge_stop_end[0] = vertex_info->edge_stops[ index ];
     rnd_vtx_is_edge_stop_end[1] = com_ed_props & EMED_REVERSE_CONNECT
                              ? ! rnd_vtx_is_edge_stop_end[0]
                              :   rnd_vtx_is_edge_stop_end[0];


     /*
      * For the round edge, and its common edge, obtain their next edges,
      * and the next edge's common edge.
      */

     for( i = 0; i < 2; i++ )
     {
        stat_OM = EMgetnxtedges( &msg_loc,
                                 EMSvtxedges_nodegenerate,
                                 i ? com_ed_id
		                 : vertex_info->edge_ids[index],
                                 OM_Gw_current_OS,
                                 rnd_vtx_is_edge_stop_end[i],
                                 1,
                                 &num_ret,
                                 &next_edge[i],
                                 &ed_props,
                                 &num_skipped);
        EMerr_hndlr( !(1 & stat_OM & msg_loc), *EMmsg, EMS_E_EdgeError,
                         wrapup );

        num = 0;
        stat_OM = om$get_channel_objects( objid = next_edge[i],
                                          p_chanselect = &to_common_edge,
                                          list         = &object_list,
                                          size         = 1,
                                          count        = ( IGRuint * )
				          &num );
            EMerr_hndlr( !( 1 & stat_OM ), *EMmsg, EMS_E_OMerror, wrapup );

            if ( !num )
	    {
                next_edge_common_edge[i] = NULL_OBJID;
		next_edge_common_edge_exists[i] = FALSE;
	    }
	    else
	    {
               next_edge_common_edge[i] = object_list.S_objid;
	       next_edge_common_edge_exists[i] = TRUE;
            }
	 }

      /*
       * Extract fillet information.
       */
         fillet_surf     = vtx_edge_infos[index]->fill_surf;
         fillet_id.objid = vtx_edge_infos[index]->fill_id;
         fillet_id.osnum = OM_Gw_current_OS;

         fill_props = vtx_edge_infos[index]->props;

        /*
         * Obtain U0 and U1 on the fillet.
         */
           num_edges = 0;
           array_size   = 0;
           sf_edges  = NULL;

           stat_OM = om$send( msg = message EMSsubbs.EMget_edges
					( &msg_loc,
					  MAXINT,
                                          EMS_OPT_NATURAL,
					  my_env,
					  &sf_edges,
					  &array_size,
                                          &num_edges ),
                              senderid = NULL_OBJID,
                              targetid = vtx_edge_infos[index]->fill_id );
           EMerr_hndlr( !( 1 & stat_OM & msg_loc ), *EMmsg, EMS_E_SurfaceError,
			wrapup);

       ed_inx_flag = IF_EQ_OBJID( vertex_info->edge_ids[prev], next_edge[0] ) ||
              IF_EQ_OBJID( vertex_info->edge_ids[prev],
					next_edge_common_edge[0] );
       /*
        * Generate the edge geometry, and the intersection points.
        */
           for( i = 0; i < 2 /* Do for U0 and U1 of fillet */; i++)
           {
              /*
               * Recall that U0 WILL be on the surface associated with
               * the round edge, and U1 WILL be on the surface associated
               * with the common edge of the round edge.
               */

              j = !i ? U0 : U1;

              fedge_geom[i].poles = NULL;
              fedge_geom[i].knots = NULL;
              fedge_geom[i].weights = NULL;
               
              stat_OM = om$send( msg = message EMSedge.EMget_bcxyz_geom
					( &msg_loc,
                                          &my_env->md_env,
					  &fillet_id,
					  fillet_surf,
					  NULL,
				          MAXINT,
					  FALSE,
					  NULL,
					  &fedge_geom[i] ),
                                 senderid = NULL_OBJID,
			         targetid = sf_edges[j].objid,
                                 targetos = sf_edges[j].osnum );
              EMerr_hndlr( !( 1 & stat_OM & msg_loc ), *EMmsg,
			   EMS_E_EdgeError, wrapup );
   
              /*
               * Get the geometry of the neighbouring edge corresponding to
               * the above iso edge.
               */ 
                  ed_inx = !i ? ( ed_inx_flag ? prev : next )
                              : ( ed_inx == prev ? next : prev );
                  medge_geom[i].poles = NULL;
                  medge_geom[i].knots = NULL;
                  medge_geom[i].weights = NULL;

                  stat_OM = om$send( msg = message EMSedge.EMget_bcxyz_geom
						( &msg_loc,
                                                  &my_env->md_env,
						  NULL,NULL,NULL,
				                  MAXINT,
						  FALSE,
						  NULL,
						  &medge_geom[i] ),
                                     senderid = NULL_OBJID,
			             targetid = vertex_info->edge_ids[ed_inx]);
                  EMerr_hndlr ( !( 1& stat_OM & msg_loc ), *EMmsg,
                                EMS_E_EdgeError, wrapup);

              /*
	       * Intersect these two curves, to determine 'points',
	       */
                  num = 0;
                  dist = MAXDOUBLE;
                  
                  /* If prev == next, it is a two edge vertex case. So there
                   * is no edge to be intersected. Here it will be minimum
		   * distance.
                   */
                      if( prev != next )
                      {
                         BSmdistcvcv( &fedge_geom[i],
				      &medge_geom[i],
				      &num,
				      &pars0, 
                                      &pars1,
				      (IGRpoint **)&xyz_pts0,
				      (IGRpoint **)&xyz_pts1,
				      &dist,
				      &msg_loc );
                         EMerr_hndlr( msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror,
				      wrapup); 
                      }

                  if(dist < cht_tol)
                  {

                    /*
		     * If there is more than a single intersection, then
		     * pick the intersection that is closest to the round
		     * vertex.
		     */

                    IGRint array_index;

                    array_index = 0;

                    OM_BLOCK_MOVE (xyz_pts0, points[i], sizeof (IGRpoint));
                    if(num > 1)
                    {
                       EFfind_the_closest_pt( &msg_loc,
					      3,
					      vtx_pt,
					      num,
					      xyz_pts0,
					      &array_index,
					      points[i] );
		       EMerr_hndlr( !( 1 & msg_loc ), *EMmsg, msg_loc, wrapup );
		    }
                  }
                  else
                  {
                     /*
		      * Determine the minimum distance point from the round
                      * vertex, to the iso curve on fillet.  This point will
		      * serve as the 'intersection' point (once the extension
                      * edge is created, it WILL be the intersection point).
                      */

                      BSmdstptcv( &fedge_geom[i],
				  vtx_pt,
				  &par,
				  points[i],
			          &dist,
				  &msg_loc);
                      EMerr_hndlr( msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror,
                                   wrapup);
                   }
           }
	   /* Generate the intersection curve on the fillet by intersecting
	    * the fillet and an infinite plane passing through the intersec-
	    * tion points and vertex point.
            */

           EMget_fillet_intpln_data (&msg_loc, NULL, vtx_edge_infos[index],
                                     points[0], points[1], vtx_pt, points[0],
                                     osnum, vertex_info->edge_stops[index],
                                     &fillet_inter_UV_data, &inter_XYZ_data,
                                     NULL);
           EMerr_hndlr (!(1 & stat_OM & msg_loc), *EMmsg, msg_loc, wrapup);

          /*
           * Convert the intersection into an edge object.  Tangency
           * is recorded in the intersections 'props' field.
           */
           curve_type = EMcurve_typing( &fillet_inter_UV_data,
                                        &inter_XYZ_data );

           EMmkintdata( &msg_loc,
                        &fillet_inter_UV_data,
                        curve_type,
                        ( IGRushort ) 0,
                        FALSE,
                        NULL,
                        construct_list,
                        TRUE,
                        NULL,
                        NULL,
                        &new_uvdata );

           EMerr_hndlr( !( 1 & msg_loc ), *EMmsg, msg_loc,
                        wrapup );
           fillet_inter_UV_data = new_uvdata;

           EMgetendpts_uv (&msg_loc, &fillet_inter_UV_data, FALSE, 1,
            fill_inter_end_uv[START], fill_inter_end_uv[STOP]);
           EMerr_hndlr( !( 1 * msg_loc ), *EMmsg, EMS_E_Fail, wrapup );

           fillet_param_tol = vtx_edge_infos[index]->fill_surf_tol;

           fillet_inter_begin_at_U0 = TRUE;
           if( ( fill_inter_end_uv[0][0] - U0 ) > fillet_param_tol )
              fillet_inter_begin_at_U0 = FALSE;
           
	   reverse_a = FALSE;

           /* Orient the intersection curve */
	   if ( ! rnd_vtx_is_edge_stop_end[0] )
	   {
              if ( fill_props & EMSfillet_v0_closeto_start_end )
	      {
                 if ( fillet_inter_begin_at_U0 )
	            reverse_a = TRUE;
              }
              else
	      {
                 if (! fillet_inter_begin_at_U0 )
	            reverse_a = TRUE;
              }
           }
	   else
	   {
              if ( fill_props & EMSfillet_v0_closeto_start_end )
	      {
                 if ( !fillet_inter_begin_at_U0 )
	            reverse_a = TRUE;
              }
              else
	      {
                 if ( fillet_inter_begin_at_U0 )
	            reverse_a = TRUE;
              }
	   }

           EMmakeintlist( &msg_loc,
                          fillet_inters, NULL,
                          &fillet_id, NULL,
                          NULL, NULL, NULL,
                          NULL, &inter_XYZ_data,
                          &fillet_inter_UV_data,
                          NULL, reverse_a, FALSE,
                          NULL, NULL, NULL, NULL,
                          NULL, NULL, TRUE, FALSE
                       );

wrapup:
    
    for(i=0; i < 2; i++)
    {
       if( medge_geom[i].poles )
       {
          om$dealloc ( ptr = medge_geom[i].poles );
          medge_geom[i].poles = NULL;
       }
       if( fedge_geom[i].poles )
       {
          om$dealloc ( ptr = fedge_geom[i].poles );
          fedge_geom[i].poles = NULL;
       }
       if( medge_geom[i].knots )
       {
          om$dealloc ( ptr = medge_geom[i].knots );
          medge_geom[i].knots = NULL;
       }
       if( fedge_geom[i].knots )
       {
          om$dealloc ( ptr = fedge_geom[i].knots );
          fedge_geom[i].knots = NULL;
       }
       if( medge_geom[i].weights )
       {
          om$dealloc ( ptr = medge_geom[i].weights );
          medge_geom[i].weights = NULL;
       }
       if( fedge_geom[i].weights )
       {
          om$dealloc ( ptr = fedge_geom[i].weights );
          fedge_geom[i].weights = NULL;
       }

    }

    if( vtx_edges && vtx_edges != vtx_edges_stack_mem )
       om$dealloc( ptr = vtx_edges );

    if(xyz_pts0) 
       free(xyz_pts0);
    if(xyz_pts1)
       free(xyz_pts1);
    if(pars0)
       free(pars0);
    if(pars1)
       free(pars1);

    EMWRAPUP( *EMmsg, stat_OM, "EMopen_surf_round" );

    return(stat_OM);
}


end implementation EMSsfrndbool;

