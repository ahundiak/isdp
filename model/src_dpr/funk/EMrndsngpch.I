class implementation EMSsfrndbool;

/*
 * DESCRIPTION

   Vertex processing for single edge rounding at a non-homogeneous vertex,
   where the classification of the edge being rounded differs from the
   classification of its previous and next neighbouring edges.  The vertex
   processing amounts to creating a patch at the vertex.

 * INPUT

   options         - Typical "options" ( not used right now ).
   construct_list  - construction list.
   vertex_info     - Information packet concerning the vertex that is being
                     processed.

 * OUTPUT

   EMmsg           - return code.
   compsf_GRid     - composite surface to which the patch will be connected.
   inters1         - intersection list containing the intersections on the
                     fillets and patches.  The new patch, and its
                     intersections will be added to this list.
   inters2         - intersection list containing the intersections on the
                     faces of the solid being rounded.  Any new
		     intersections on the faces of the solid will be added
		     to this list.

 * ALGORITHEM (summary)

   [1] Initialize and collect global information.
   [2] Determine the intersection points between fillets iso edges U0, U1,
       and the appropriate edges on the solid.  Also determine the boundary
       geometry for two edges of the patch (the vertex patch generated is a
       three-boundary patch.  Two of its boundaries will have common edges
       on the solid, and the remaining boundary will have a common edge with
       an edge on the fillet).
   [3] Form the patch, either a plane (if possible), or a general bspline
       surface.
   [4] Do various processing on patch (see STEP 4 comments).
   [5] Create the intersection between the patch and the fillet.  Add that
       to 'inters1'.
   [6] Create the intersections on the solid corresponding to the remaining
       edges on the patch.  Add these to intersection lists.

   For further detailes, see comments on each step (i.e. STEP 1,
   STEP 2, etc.), within the function.

 * HISTORY

   Inasu : ??? ??, 91 : creation.
   dlb   : 02/11/92   : comment out resetting of construct_list->msg.
   ss    : 02/14/92   : set the emsintobj props with emsintobj_marked
                        since these will not intersect other intersections
                        in this op.
   Janaka : july 16, 1992 : recoded parts of the function to be compatible
                            with the re-write of EMround() [the driving
		 	    function in rounding].
   WBC    : 01/13/93  : Replaced the call to BSprptonsf with a call to
                        BSprptarrsf.
   Janaka : 03/25/93  : Changed the determination of vertex coincidence
                        from a geometric to a topological check (more
                        expensive but more robust).
   NP     : 05/27/93  :  Funtction "EMmkintlist" is now called by a new
                         name, "EMmakeintlist", due to addition of two new
                         curve type parameters.
                         NOTE: TRY AND SET CURVE TYPES MEANINGFULLY IN THE
                               CALL (CURRENTLY SET TO NULL).
   Jack   : 05/30/93  : Added code to deallocate the poles, knots, and
                        weights for the curves returned from EMget_bcxyz_
                        geom. (Purify)  Also, added some code to deallocate
                        the parms and points returned from BSmdistcvcv.
                        The function call is in a loop and the memory was
                        not getting freed before the next call.
   Jack  : 06/02/93   : sf_ptr was being used for 2 separate things and the
                        memory for one of the uses was not being deallocated.
                        created sf2_ptr for that use and made sure to
                        deallocate it.
   Sudha   06/23/93     Modified for BSprototype ansification
   Aditya : 10/05/95  : Changed the condition for generating single patch to
                        be dependent on the relative configurations of the
                        rounding edge and adjacent edges. Prompted by
                        TR#119523702. Also commented out the old vector
                        addition stuff for patch generation.

 */

#include <math.h>
#include "bserr.h"
#include "bsparameters.h"
#include "OMmacros.h"
#include "emsedgedef.h"
#include "EMSlmdef.h"
#include "emssfintdef.h"
#include "EMSrnd.h"
#include "bsgeom_cvsf.h"
#include "bssfeval.h"
#include "bsskndsf.h"
#include "bssfb4cvs.h"
#include "bsrev_cv.h"
#include "bsprptarrsf.h"
#include "bspjcvnrsf.h"
#include "bspartofcv.h"
#include "bsparameters.h"
#include "bsmdstptcv.h"
#include "bsmdistcvcv.h"
#include "bslininter.h"
#include "bsfreesf.h"
#include "bsfreecv.h"
#include "bsalloccv.h"
#include "emsinterdef.h"

/* imports */

from EMSsubbs    import EMget_edges, EMpartolbasis;
from EMSedge     import EMget_bcxyz_geom, EMget_props, EMget_sf_geom,
                        EMptproject, EMendpts, EMgetvtxedges;
from EMSlinedge  import EMleinit;
from EMSpartedge import EMpeinit;
from EMSloopset  import EMlsparttrim;
from EMSboundary import EMgetsurface_info;

#define  U0    0
#define  V1    1
#define  U1    2
#define  V0    3

#define  FIRST  0
#define  SECOND   1

#define  START	0
#define  STOP   1

#define WBC_USE_NEW_MATH 1

#define MAX_TO_STACK_ALLOC 10

/* pathway flags */
extern IGRboolean _pathway_trim, _pathway_orient;

%safe
static IGRboolean chkatend ();
%endsafe

#argsused

IGRlong EMsingle_patch( EMmsg, options, construct_list, vertex_info,
                        compsf_GRid, inters1, inters2 )
IGRlong			*EMmsg;
IGRushort		options;
struct GRvg_construct	*construct_list;
struct EMSvtx_rnd_info	*vertex_info;
struct GRid		*compsf_GRid;
struct EMSinters	**inters1,
			**inters2;
{
  IGRuchar		curve_type;
  IGRchar		*more_info_a, *more_info_b;
  IGRlong		om_stat, msg;
  GRobjid		sf_id, next_edge[2], next_edge_common_edge[2], pch_id,
  			nat_edges[4], com_ed_id, edge_ids[2];
  GRclassid		vertex_patch_classid;
  GRspacenum		osnum;

  IGRint		ii,num_edges, arr_siz, num, num_ret, num_skipped, index,
			prev, next, chan_count,	i, j, k, ed_inx, one_point;
  IGRint	        num_grps=0, *num_elms_grp=NULL, intedge=0;
  IGRpoint 		points[3], poles_buf[4][2];
  IGRboolean		mdist[2], flag, reverse_a, reverse_b, onSurf,
			rnd_vtx_is_edge_stop_end[2], is_stop_end, on_site;
  IGRushort		com_ed_props, ed_props,	props_a, props_b,
                        world_options, trim_options, param_options; 
  IGRdouble	        **pj_pts=NULL, **uv_pts=NULL;
  IGRdouble		*pars0,	*pars1,	*xyz_pts0, *xyz_pts1, *vtx_pt,
                        end_pars[4], knots_buf[4][4], cht_tol, basis_tol,
			par_tol, dist, *pts;
  IGRshort		sf_type;
  struct IGRbsp_curve	*curve[4], curve_buf[4], fedge_geom[2],	medge_geom[2],
                        *trcvs[2], *crcvs[2];
  struct IGRbsp_surface *surf, *fillet_surf, *sf_ptr = NULL, *sf2_ptr = NULL;
  struct EMSedge_rnd_info **vtx_edge_infos = NULL;
  struct EMSdataselect	other_data;
  struct EMSinters	*sf_inters, *fillet_inters;
  struct EMSintobj	*intobj_ptr;
  struct GRmd_env	*my_env, *other_env;
  struct GRmdenv_info	*md_env;
  struct GRid		object_a, object_b, *object, *edge_object, temp_GRid,
			fillet_id, *sf_edges;
  struct EMSpartolbasis tol_basis;
  struct EMSsfintedpar	*bdry_pars,
           		*start_intedpar, *stop_intedpar;
  struct BSgeom_bsp_surf geom_surface;

  extern GRclassid	OPP_EMSgenbs_class_id,
			OPP_EMSdumedge_class_id;

  OM_S_CHANSELECT	to_common_edge,
			to_loopset,
			to_components,
			chan_to_edge,
			chan_to_owner;
  OM_S_OBJECT_LINKAGE	object_list;
  extern void		EFfind_the_closest_pt();
  extern IGRuchar	EMcurve_typing();
  extern struct EMSsfintedpar	*EMsfintedpar_malloc();
  extern struct EMSintobj	*EMmakeintlist();
  extern IGRboolean EMis_geomequal_3dpt();
  extern void EFinit_geom_surface() ;

  IGRboolean save_pathway_trim, save_pathway_orient;
  struct EMSpypoint *py_bdry=NULL;

   /*
    * STEP 1: Initialize and gather some global data.
    */
     *EMmsg = EMS_S_Success;
     om_stat= OM_S_SUCCESS;

     pars0 = NULL;
     pars1 = NULL;
     xyz_pts0 = NULL;
     xyz_pts1 = NULL;
     for( i = 0; i < 4; i++ )
        curve[i] = NULL;
     for( i = 0; i < 2; i++ )
     {
       fedge_geom[i].poles = NULL;
       fedge_geom[i].knots = NULL;
       fedge_geom[i].weights = NULL;
       medge_geom[i].poles = NULL;
       medge_geom[i].knots = NULL;
       medge_geom[i].weights = NULL;
     }

     surf     = NULL;
     fillet_surf = NULL;
     sf_inters     = NULL;
     fillet_inters = NULL;
     object = NULL;
     edge_object = NULL;
     bdry_pars = NULL;
     start_intedpar = NULL;
     stop_intedpar = NULL;
     more_info_a =
     more_info_b = NULL;
     mdist[0] = mdist[1] = FALSE;
     geom_surface.sfgen_cv = NULL;
     one_point = 1;
     ed_inx = 0;    /* Stop compiler warnings. */

     my_env = other_env = construct_list->env_info;
     osnum = my_env->md_id.osnum;
     md_env = &construct_list->env_info->md_env;

     tol_basis.mattyp   = &md_env->matrix_type;
     tol_basis.mat      = md_env->matrix;

     vtx_pt             = vertex_info->vtx_pt;
     vtx_edge_infos     = vertex_info->edge_infos;

     EMmake_chanselect( EMSedge_to_common_edge, &to_common_edge );
     EMmake_chanselect( EMSsubbs_to_loopset, &to_loopset );
     EMmake_chanselect( EMSbd_owner_to_comps, &chan_to_edge );
     EMmake_chanselect( EMSedge_to_owner, &chan_to_owner );
     EMmake_chanselect( EMSsubbs_to_loopset, &to_loopset );
     EMmake_chanselect( GRcmpowner_to_components, &to_components );

     BSEXTRACTPAR( &msg, BSTOLCHRDHT, cht_tol );
     BSEXTRACTPAR( &msg, BSTOLLENVEC, basis_tol );

     /* get the index of the edge to be rounded */

     for( index = 0; index < vertex_info->num_edges; index++)
             if( vertex_info->edge_infos[index]) break;

     prev = (index == 0) ? (vertex_info->num_edges - 1) : (index - 1);
     next = (index == (vertex_info->num_edges - 1)) ? 0 : (index + 1);

     /* Get the common edge and its properties */

     num = 0;
     om_stat = om$get_channel_objects( objid = vertex_info->edge_ids[index],
                                       p_chanselect = &to_common_edge,
                                       list         = &object_list,
                                       size         = 1,
                                       count        = ( IGRuint * ) &num);
     EMerr_hndlr(! (1 & om_stat ) || !num, *EMmsg,EMS_E_OMerror,wrapup);

     com_ed_id = object_list.S_objid;

     om_stat = om$send( msg = message EMSedge.EMget_props
				( &msg,
				  &com_ed_props ),
                        senderid = NULL_OBJID,
                        targetid = com_ed_id);
     EMerr_hndlr (!(1& om_stat & msg), *EMmsg, EMS_E_EdgeError, wrapup);

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
            om_stat = EMgetnxtedges( &msg,
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
            EMerr_hndlr( !(1 & om_stat & msg), *EMmsg, EMS_E_EdgeError,
                         wrapup );

            num = 0;
            om_stat = om$get_channel_objects( objid = next_edge[i],
                                              p_chanselect = &to_common_edge,
                                              list         = &object_list,
                                              size         = 1,
                                              count        = ( IGRuint * )
								&num );
            EMerr_hndlr( !( 1 & om_stat ) || !num, *EMmsg,
                         EMS_E_OMerror, wrapup );

            next_edge_common_edge[i] = object_list.S_objid;
	 }

      /*
       * Extract fillet information.
       */
         fillet_surf = vtx_edge_infos[index]->fill_surf;
         fillet_id.objid = vtx_edge_infos[index]->fill_id;
         fillet_id.osnum = OM_Gw_current_OS;


   /*
    * STEP 2: Generate the xyz geometry for the edges of the
    *         three-boundary patch.
    *
    * Two of these edges will have common edges with edges on the solid
    * being rounded, and the other will have its common edge with an edge
    * of the fillet.  This latter edge (and its common edge) are generated
    * by intersecting the patch surface with the fillet.  The xyz geometry
    * for the former two edges are generated as follows.
    * Each of the iso edges, u0 and u1 of the fillet may intersect the
    * adjacent edge of the round edge, and the adjacent edge of its
    * common edge (at the round vertex).  If such an intersection occurs,
    * then the partial geometry of that edge, bounded by the round vertex,
    * and the intersection point, is taken as the geometry for that edge
    * of the patch.  A failure to produce the intersection is an indication
    * that the edge which is supposed to have intersected with an fillet
    * iso, does not extend upto that iso edge of the fillet.  In
    * such cases, the edge geometry is generated as follows.  Obtain a
    * straight line between the round vertex, and the minimum distance point
    * from the round vertex, and the fillet's appropriate iso edge
    * (observe that the end points of the line are on the solid).  Then
    * project that line onto the surface on which the appropriate iso edge
    * is lying on.  This projected geometry serves as the geometry of this
    * edge. That geometry is used to produce an edge on the solid, and on
    * the patch.
    *
    * In either case, on exiting this step, the pair (curve[0], points[0])
    * has the xyz geometry of the edge, and the xyz intersection point
    * generated by processing fillet's iso edge U0.  (curve[1], points[1])
    * contains the same information generated by processing fillets iso edge
    * U1.
    */
       /*
        * Obtain U0 and U1 on the fillet.
        */
           num_edges = 0;
           arr_siz   = 0;
           sf_edges  = NULL;

           om_stat = om$send( msg = message EMSsubbs.EMget_edges
					( &msg,
					  MAXINT,
                                          EMS_OPT_NATURAL,
					  my_env,
					  &sf_edges,
					  &arr_siz,
                                          &num_edges ),
                              senderid = NULL_OBJID,
                              targetid = vtx_edge_infos[index]->fill_id );
           EMerr_hndlr( !( 1 & om_stat & msg ), *EMmsg, EMS_E_SurfaceError,
			wrapup);

       flag = IF_EQ_OBJID( vertex_info->edge_ids[prev], next_edge[0] ) ||
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
               
              om_stat = om$send( msg = message EMSedge.EMget_bcxyz_geom
					( &msg,
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
              EMerr_hndlr( !( 1 & om_stat & msg ), *EMmsg,
			   EMS_E_EdgeError, wrapup );
   
              /*
               * Get the geometry of the neighbouring edge corresponding to
               * the above iso edge.
               */ 
                  ed_inx = !i ? ( flag ? prev : next )
                              : ( ed_inx == prev ? next : prev );
                  medge_geom[i].poles = NULL;
                  medge_geom[i].knots = NULL;
                  medge_geom[i].weights = NULL;

                  om_stat = om$send( msg = message EMSedge.EMget_bcxyz_geom
						( &msg,
                                                  &my_env->md_env,
						  NULL,NULL,NULL,
				                  MAXINT,
						  FALSE,
						  NULL,
						  &medge_geom[i] ),
                                     senderid = NULL_OBJID,
			             targetid = vertex_info->edge_ids[ed_inx]);
                  EMerr_hndlr ( !( 1& om_stat & msg ), *EMmsg, EMS_E_EdgeError,
                                wrapup);

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
                         /* since we are in a loop, first check if we need to
                          * deallocate stuff that gets allocated by this
                          * function. (Purify)
                          */
                         if(pars0)
                          {
                            om$dealloc( ptr = pars0 );
                            pars0 = NULL;
                          }
                         if(pars1)
                          {
                            om$dealloc( ptr = pars1 );
                            pars1 = NULL;
                          }
                         if(xyz_pts0)
                          {
                            om$dealloc( ptr = xyz_pts0 );
                            xyz_pts0 = NULL;
                          }
                         if(xyz_pts1)
                          {
                            om$dealloc( ptr = xyz_pts1 );
                            xyz_pts1 = NULL;
                          }

                         BSmdistcvcv( &fedge_geom[i],
				      &medge_geom[i],
				      &num,
				      &pars0, 
                                      &pars1,
				      (IGRpoint **)&xyz_pts0,
				      (IGRpoint **)&xyz_pts1,
				      &dist,
				      &msg );
                         EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror,
				      wrapup); 
                      }

               intedge = i==0 ? next : prev;

               /*
                * If the configuration of this edge (index) is not the same
                * as the next or previous edge (intedge), go for an
                * intersection solution with the corresponding iso. 
                * Otherwise generate the patch by projecting the vertex onto
                * the iso. It was found that the intersection solution 'looks
                *  better' for vertices with more than 3 edges and the 
                * projection condition for vertices with <= 3 edges. -Aditya
                */

               if(((vertex_info->edge_configs[index] !=
                    vertex_info->edge_configs[intedge])
                    && vertex_info->num_edges <= 3)
                    || vertex_info->num_edges > 3)
               {

                     if(dist < cht_tol)
                     {
                       struct EMSdataselect cvdata;
                       IGRint array_index;

                       /*
		        * If there is more than a single intersection, then
		        * pick the intersection that is closest to the round
		        * vertex.
		        */


                       array_index = 0;
   
                       OM_BLOCK_MOVE (xyz_pts0, points[i], sizeof (IGRpoint));
                       if(num > 1)
                       {
                         EFfind_the_closest_pt( &msg,
					        3,
					        vtx_pt,
					        num,
					        xyz_pts0,
					        &array_index,
					        points[i] );
		         EMerr_hndlr(  !( 1 & msg ), *EMmsg, msg, wrapup );
		       }
   
                       /* 
		        * Extract the correct portion of the edge_geometry. The
		        * portion is determined using the end justification of
                        * the edge at the vertex.  If the end justification is
                        * stop end then end portion else start portion.
                        */
                          
                        end_pars[0] = vertex_info->edge_stops[ed_inx]
							   ? 1.0 : 0.0;
                        end_pars[1] = pars1[array_index];

                        BSalloccv( medge_geom[i].order,
				   medge_geom[i].num_poles,
			           medge_geom[i].rational,
				   NULL,
				   &curve[i],
				   &msg );
                        EMerr_hndlr( msg != BSSUCC, *EMmsg,
					   EMS_E_NoDynamicMemory, wrapup);
   
	                BSpartofcv(  &msg,
			             &medge_geom[i],
                                     end_pars[0] < end_pars[1] 
					   ? end_pars[0] : end_pars[1],
                                     (end_pars[0] + end_pars[1])/ 2.0,
                                     end_pars[0] > end_pars[1] 
					   ? end_pars[0] : end_pars[1],
                                     curve[i]);
                        EMerr_hndlr ( msg != BSSUCC, *EMmsg, EMS_E_BSerror, 
                                     wrapup);
                     
                        /*
                         * Adjust the end-points of the curve to be the
                         * vertex-point and the minimum-distance point obtained
                         * on the fillet-iso-curve, respectively. 
                         */

                        cvdata.datatype = EMSdata_curve3d;
                        cvdata.data.curve = curve[i];
                        if (vertex_info->edge_stops[ed_inx])
                          {
                          EMend_modify_data (&msg, NULL, &cvdata, 
                           TRUE, points[i]);
                          EMend_modify_data (&msg, NULL, &cvdata, 
                           FALSE, vtx_pt);
                          }
                        else
                          {
                          EMend_modify_data (&msg, NULL, &cvdata, 
                           TRUE, vtx_pt);
                          EMend_modify_data (&msg, NULL, &cvdata, 
                           FALSE, points[i]);
                          }
   
                       /* To preserve consistency, the curve[0] and curve[1] are
		        * parametrized such a way that it is going away from
		        * the vertex.
                        */

                        if( vertex_info->edge_stops[ed_inx] == TRUE )
                           BSrev_cv(&msg, curve[i]);
                     }
                     else goto min_distance;
             }
             else
             {
             /* Come here for projecting the vertex onto the fillet iso. */
             min_distance:
                {
                    IGRdouble	par;
                    IGRvector	normal;
                    IGRboolean	all_on_cv;


                    pj_pts = NULL;
                    uv_pts = NULL;
		    num_grps = 0;
                    num_elms_grp = NULL;

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
				 &msg);
                     EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror,wrapup);
 
                     mdist[i] = TRUE;

                     BSalloccv( (IGRshort) 2,
			        (IGRlong) 2,
				FALSE,
			        NULL,
				&curve[i],
				&msg );
                     EMerr_hndlr( msg != BSSUCC, *EMmsg,
					EMS_E_NoDynamicMemory, wrapup);

                     curve[i]->order      = 2;
                     curve[i]->num_poles  = 2;
                     curve[i]->num_knots  = 4;
                     curve[i]->rational   = FALSE;
                     curve[i]->planar     = TRUE;
                     curve[i]->weights    = NULL;
                     curve[i]->num_boundaries = 0;
                     curve[i]->phy_closed = FALSE; 

                     for(k = 0; k < 3; k++)
			curve[i]->poles[k] = vtx_pt[k]; 
                     for(k = 0; k < 3; k++)
			curve[i]->poles[3 + k] = points[i][k]; 

                     curve[i]->num_knots =  4;
                     for(k = 0; k < 2; k++) 
                     {
                       curve[i]->knots[k] = 0.0; 
                       curve[i]->knots[2 +k] = 1.0;
                     }
 
                     /* The above curve is a line segment with end points
		      * lying on the respective surfce ( surface or common
                      * surface ). So project this curve to get curve lying
                      * on the surface.
                      */ 

                     sf_ptr = i ? vtx_edge_infos[index]->com_surf
                                 : vtx_edge_infos[index]->surf; 

                     BSpjcvnrsf( curve[i],
				 sf_ptr,
				 cht_tol,
				 &num_grps,
				 &num_elms_grp,
                                 (BSpair ***)&uv_pts,
				 (IGRpoint ***)&pj_pts,
				 &all_on_cv,
				 &msg);
                     EMerr_hndlr( ( msg != BSSUCC ) || ( num_grps > 1 ),
				  *EMmsg, EMS_E_BSerror, wrapup);

                     
                     /* If the number of points in the group is more than 2,
		      * then create a line string out of this and this would
                      * be the curve[i]. Make sure that the end-points of
                      * this line-strings are indeed the vertex-point
                      * and the minimum-distance point, respetively.
                      */

                     if( num_elms_grp[0] > 2 )
                     {
                       BSfreecv( &msg, curve[i] );
                       
                       curve[i] = NULL;

                       BSalloccv( (IGRshort) 2,
				  num_elms_grp[0],
				  FALSE,
				  NULL,
				  &curve[i],
				  &msg);
                       EMerr_hndlr( msg != BSSUCC, *EMmsg,
					EMS_E_NoDynamicMemory, wrapup);

                       BSlininter( &msg,
				   &num_elms_grp[0],
				   pj_pts[0],
				   curve[i],
				   normal );
                       EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror,
                                    wrapup);

                       pts = curve[i]->poles;
                       OM_BLOCK_MOVE (vtx_pt, 
                                      pts,
                                      sizeof (IGRpoint));
                       OM_BLOCK_MOVE (points[i], 
                                      &pts[3*(curve[i]->num_poles-1)], 
                                      sizeof (IGRpoint));
                    } /* if */
                }
             } /* else */
          }

   /*
    * STEP 3: Create the vertex patch, as a general surface with four
    *         boundaries (subsequently, this patch becomes a surface with
    *         three boundaries, due to imposing the edge made by the
    *         intersection between the vertex patch, and the fillet).
    *
    * Two of the curves for the four boundary patch are curve[0] and
    * curve[1].  The other two are obtained as follows.  Evaluate a fourth
    * point P4 as the end point of the vector formed by the addition of the
    * two vectors vtx_pt->points[0], and vtx_pt->points[1].  Then,
    * form two curves, points[0]->P4 and points[1]->P4.
    */
        /*
         * Do the vector addition.
         *
            for(j = 0; j < 3; j++) 
               points[2][j] = points[0][j] + points[1][j] - vtx_pt[j]; 

         *
         * Form 'curve[2] and curve[3]'
         *
            for( i = 2; i < 4; i++)
            {
               curve[i] = &curve_buf[i];

               curve[i]->order      = 2;
               curve[i]->num_poles  = 2;
               curve[i]->num_knots  = 4;
               curve[i]->rational   = FALSE;
               curve[i]->planar     = TRUE;
               curve[i]->weights    = NULL;
               curve[i]->num_boundaries = 0;
               curve[i]->phy_closed = FALSE; 

               curve[i]->poles     = (IGRdouble *) poles_buf[i];

               for(j = 0; j < 3; j++) 
			curve[i]->poles[j] = points[i-2][j];
               for(j = 0; j < 3; j++) 
                        curve[i]->poles[3 + j] = points[2][j];

               curve[i]->knots     = knots_buf[i];
               for(j = 0; j < 2; j++)
               {
                 curve[i]->knots[j] = 0.0;
                 curve[i]->knots[2 +j] = 1.0;
               }
            }
        
         *
         * Form the vertex patch.
         */
/*
            BSsfb4cvs( curve[0],
		       curve[3],
		       curve[1],
		       curve[2],
		       &surf,
                       &msg );
*/
   /*
    * Replacing the above call, with BSskndsf(), because the
    * above math call produces a bad patch, if the order of the
    * bound curves is greater than 3.
    * The new patch is skinned type surface.
    *     --- KNAP (10/1/95)
    */
         trcvs[1]=NULL;
         crcvs[1]=NULL;
         /* Trace curve[0] Should always be curve[1] */
         trcvs[0]=curve[1];

         /* Cross section curve[0] Should always be curve[1] */
         crcvs[0]=curve[0];
         on_site = FALSE;
         BSskndsf ( trcvs, crcvs, (IGRint )1, on_site, &surf, &msg);
         EMerr_hndlr(msg != BSSUCC,*EMmsg, EMS_E_BSerror,wrapup);
         vertex_patch_classid = OPP_EMSgenbs_class_id;

   /*
    * STEP 4: 
    *
    * . Orient the surface patch.
    * . Create an object for the surface.
    * . Create a natural boundary for the patch.
    * . Attach the surface to the composite surface.
    */
      {
       IGRushort  surf_orient;

       surf_orient = vertex_info->edge_infos[index]->surf->pos_orient 
                                    ? 0x01 : 0x00;

       is_stop_end   = vertex_info->edge_stops[index] ? 0x01 : 0x00;

       surf->pos_orient = (surf_orient ^ is_stop_end) ? TRUE : FALSE; 

      }

      construct_list->geometry = (IGRchar *) surf;

      /*DLB - NEVER DO THE FOLLOWING
       *      construct_list->msg      = &msg;
       */
   
      om_stat = om$construct ( classid = vertex_patch_classid,
                      osnum   = OM_Gw_current_OS,
                      p_objid = &pch_id,
                      msg     = message GRgraphics.GRconstruct(construct_list));
      EMerr_hndlr( !( 1 & om_stat), *EMmsg, EMS_E_OMerror, wrapup);

      /* connect this blend to the composite surface */
       {
           chan_count = 0;
           om_stat = om$get_channel_count( osnum = compsf_GRid->osnum,
                                       objid = compsf_GRid->objid,
                                       p_chanselect = &to_components,
                                       count        = ( IGRuint * )
							&chan_count);
           EMerr_hndlr( !(1 & om_stat), *EMmsg, EMS_E_OMerror,wrapup);

           om_stat = om$send( msg = message GRconnector.GRrigidconn( &msg,
                                        compsf_GRid,
				        ( IGRlong * ) &chan_count),
                          senderid = NULL_OBJID,
                          targetid = pch_id);
           EMerr_hndlr(!(1 & om_stat & msg), *EMmsg, EMS_E_OMerror, wrapup);
       }

      /* create natural boundary for the surface patch */

      om_stat = om$send( msg = message EMSsurface.EMmk_nat_bdry
				( &msg,
				  &construct_list->env_info->md_env,
				  nat_edges ),
                         senderid = NULL_OBJID,
                         targetid = pch_id );
      EMerr_hndlr( !( 1 & om_stat & msg ), *EMmsg, EMS_E_SurfaceError,
		   wrapup );

   /*
    * STEP 5:
    *
    * Create the intersection between the surface patch, and the fillet
    * surface.  Add that intersection (for both surfaces) into the
    * intersection list 'inters1'.  Note that NO objects are made for
    * the intersections, on either surface.  These are made by EMround()
    * [the driver of rounding].
    */
      world_options = EMSINT_OUTPUT_WORLD | EMSINT_ORIENT_OUTPUT ;

      param_options = EMSINT_OUTPUT_PARAM | EMSINT_ORIENT_OUTPUT ;

      trim_options  = EMSINT_TRIM_OUTPUT  | EMSINT_TRIM_BDRYISAREA |
                                                EMSINT_TRIM_HANDLESTOP;

      if (vertex_info->edge_configs[index] == EMSedge_concave)
      {
       world_options  |= EMSINT_ORIENT_RIGHT;
       param_options  |= EMSINT_ORIENT_RIGHT;
      }

      num = 0;

      other_data.datatype = EMSdata_object;
      object_a.objid        = vertex_info->edge_infos[index]->fill_id;
      object_a.osnum        = other_env->md_id.osnum;
      other_data.data.object = &object_a;

      save_pathway_trim = _pathway_trim;
      save_pathway_orient = _pathway_orient;
      _pathway_trim = 0;
      _pathway_orient = 0;

      om_stat = om$send(msg = message EMSsurface.EMsfsfint( &msg,
                                                &my_env->md_env.matrix_type,
                                                my_env->md_env.matrix,
                                                construct_list,
                                                &other_data,
                                                &other_env->md_env,
                                                world_options,
                                                param_options,
                                                trim_options,
                                                ( IGRlong * ) &num,
                                                &sf_inters,
                                                &fillet_inters),
                 	senderid = NULL_OBJID,
                  	targetid = pch_id);

      _pathway_trim = save_pathway_trim;
      _pathway_orient = save_pathway_orient;

      EMerr_hndlr(!(1&om_stat&msg) || !num, *EMmsg, EMS_E_SurfaceError, wrapup);

      /*
       * Mark the intersections, to indicate that they need no further
       * processing.
       */
          for (i=0, intobj_ptr = fillet_inters->cvs; 
               i<2;
               i++, intobj_ptr = sf_inters->cvs)
          while (intobj_ptr)
          {
             intobj_ptr->props |= EMSintobj_marked;
             intobj_ptr = intobj_ptr->next;
          }

      EMmergeinters(&msg,inters1,fillet_inters);
      EMmergeinters(&msg,inters1,sf_inters);

   /*
    * STEP 6:
    *
    * Generate the edges corresponding to curve[0], and curve[1], on the
    * corresponding solid edges.  If the curve geometry was due to an
    * intersection, then a part edge with the bounds corresponding to
    * that of curve[0] (or curve[1]) is generated.  If the curve geometry
    * was due to a minimum distance from round vertex to an iso edge, then
    * a new linear edge is generated.  The geometry of this edge is obtained
    * by stroking either curve[0] or curve[1], as appropriate.  Once the
    * edges are obtained, each pair (formed by the intersection on the solid,
    * and its counterpart on the surface patch) is added to 'inters1' and
    * 'inters2'.  Object 'a' would be the surface patch, and object 'b'
    * would be the appropriate solid surface.
    */
      object_a.objid = pch_id;
      object_a.osnum = OM_Gw_current_OS;

      props_a   = props_b   = EMSintobj_marked;
      reverse_a = FALSE;

      /* Reverse curve[0], since its geometry flows opposite to that of
       * the edge on the patch (this is guaranteed by the procedure used
       * in generating the patches).  Note that the flow of the curve
       * geometry would nolonger be consistant with its creation, but it
       * is consistant with the surface patch edge.
       */
          BSrev_cv( &msg, curve[0] );
	  EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );

      edge_ids[0] = nat_edges[V0];
      edge_ids[1] = nat_edges[U0];

      /*
       * Create object 'b', and the dataselects for both objects.
       */

      for( j = 0; j < 2 /* Do for each curve */; j++ )
      {
         struct EMSdataselect	object_a_uvdata,
			      	object_b_uvdata,
				temp_uvdata,
			      	xyz_data;
         IGRboolean		all_pts_onSurf;
         
         reverse_b = FALSE;
         object = (struct GRid *) om$malloc(size = sizeof( struct GRid));
         EMerr_hndlr( !object, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

         object->objid = edge_ids[j];
         object->osnum = OM_Gw_current_OS;

         object_a_uvdata.datatype =  EMSdata_object;
         object_a_uvdata.data.object = object;
         object = NULL;
         /*
          * Make two empty intedpars for the edge.  These can be in any
          * order, since they are NULL Objects (it is not possible to have
          * an intobj with empty 'more_info').
          */
             more_info_a = ( IGRchar * ) EMsfintedpar_malloc( &msg, 2 );
             EMerr_hndlr( !more_info_a, *EMmsg, EMS_E_NoDynamicMemory,
			  wrapup );

         xyz_data.datatype = EMSdata_curve3d;
         xyz_data.data.curve = curve[j];

         /*
          * The following is the edge object that is to containing the
          * uv data of object 'b' intersection.
          */
             edge_object = (struct GRid *) om$malloc
					( size = sizeof( struct GRid ) );
             EMerr_hndlr( ! edge_object, *EMmsg, EMS_E_NoDynamicMemory,
			  wrapup);

        /*
         * Now we have object 'a', its uv data for the intersection, and
	 * the xyz geometry of the intersection.  The following generates
         * object 'b', and its intersection uv data.
	 */

        if( mdist[j] == TRUE )
        {
           /*
            * Now, generate object 'b'.
            */
	      sf_ptr = j ? vtx_edge_infos[index]->com_surf
			 : vtx_edge_infos[index]->surf; 

	      sf_id  = j ? vtx_edge_infos[index]->com_surf_id 
			 : vtx_edge_infos[index]->surf_id;

	      par_tol = j ? vtx_edge_infos[index]->com_surf_tol
		          : vtx_edge_infos[index]->surf_tol;

	      object_b.objid = sf_id;
	      object_b.osnum = OM_Gw_current_OS;

           /*
            * Generate the intersection on the solid such that its flow
            * is consistant with that of its xyz curve (and the flow
            * of its counterpart intersection).  The new intersection is
            * is oriented by correctly seting the 'reverse' field in the
            * intobj for that intersection.
            */

           sf_type =  EMS_O_Unknown;

           EMmapcvxyz_to_uv(&msg,
                          EMS_TRIM_AGAINST_NATBDRY,
                          sf_ptr,
                          &xyz_data,
                          cht_tol,
                          par_tol,
                          &sf_type,
                          &temp_uvdata,
                          &all_pts_onSurf);
           EMerr_hndlr( !( 1 & msg ), *EMmsg, EMS_E_SurfaceError, wrapup );

           curve_type = EMcurve_typing( &temp_uvdata,
					&xyz_data );

           /*
	    * Obtain the EMSsfintedpar instance for the intersection (one end
            * of the mapped curve MUST be on a solid's edge).
            */
               tol_basis.tol      = par_tol * 100.0;
               tol_basis.in_world = FALSE;
               tol_basis.is_valid = TRUE;

               num = 0;
               om_stat = om$send( msg = message EMSloopset.EMlsparttrim
					( &msg,
                                          &temp_uvdata,
					  &tol_basis,
					  NULL,
                                 	  &num,
				          &py_bdry,
					  &bdry_pars ),
                              senderid = sf_id,
                              p_chanselect = &to_loopset);
                   EMerr_hndlr( !(1 & om_stat & msg) || num != 1, *EMmsg,
                                            EMS_E_LoopsetError, wrapup);


               /*
                * Due to modelling inacuracies, it is possible for 'bdry_pars'
                * to be NULL.
                */
                   EMerr_hndlr (!chkatend (&xyz_data, py_bdry, sf_ptr), *EMmsg,
                                EMS_E_NotSupported, wrapup);
               /*
                * The following code is to detect ant topological
                * interactions like invisible topological splits at
                * in the viscinity of vertex. -KNAP
                *
                * Commented this as the above function "chkatend()" will take
                * care of this.
               {
               IGRint tp;
               IGRboolean tp_found = FALSE;
               GRobjid tp_edge;

               if(bdry_pars->edgeid == NULL_OBJID)
                 tp_edge = bdry_pars->next->edgeid;
               else
                 tp_edge = bdry_pars->edgeid;

               if ((tp_edge == vertex_info->edge_ids[index])||
                    (tp_edge == com_ed_id))
                 tp_found = TRUE;
               else
                 {
                 for (tp=0; tp < 2; tp++)
                   {
                   if ((tp_edge == next_edge[tp]) ||
                       (tp_edge == next_edge_common_edge[tp]))
                     {
                     tp_found = TRUE;
                     break;
                     }
                   }
                 }
               EMerr_hndlr (!tp_found, *EMmsg, EMS_E_NotSupported, wrapup);
               }
               **/

               more_info_b = ( IGRchar* ) bdry_pars;
               /*
                * Make a linear edge object.
                */
                   tol_basis.tol = par_tol;
                   om_stat = om$construct
				( classid = OPP_EMSlinedge_class_id,
                                  p_objid = &edge_object->objid,
                                  msg = message EMSlinedge.EMleinit
					 ( &msg,
                                           EMED_OPEN | EMED_COMPATIBLE,
				           curve_type,
					   temp_uvdata.data.poly,
                                           &tol_basis,
					   NULL,
					   sf_id ) );
                   EMerr_hndlr( !( 1 & om_stat), *EMmsg, EMS_E_OMerror,
				wrapup );

		   edge_object->osnum = OM_Gw_current_OS;

           /*
            * Assert the orientation of the intersection on object 'b'
            * by correctly setting the reverse field in its intobj.
            */
               {
                  IGRboolean	flag1;

                  flag1 = rnd_vtx_is_edge_stop_end[j] == TRUE ? 0x1 : 0x0;

                  if( !( flag1 ^ j ) )
                     reverse_b = TRUE;
               }
         }
         else
         {
           struct EMSproj_info	proj_info;
           IGRdouble		param[2],
				end_pts_in_uv[2][2];
	   struct EMSedgebound	edge_pars[2];
	   IGRushort		dum_edge_props,
				real_edge_props;
           GRobjid              proc_edge;
           IGRboolean           next_edge_common_edge_is_dominant = FALSE;

           dum_edge_props = 0;

           /*
            * In this case, a dum edge intersection is created on the
            * appropriate surface (which is the surface corresponding to
            * next_edge_common_edge[j]).  The part edge is created such
            * that it flows in the same direction as the xyz curve (thus,
            * the two UV curves and the xyz curve all flow in the same
            * direction).
	    */
               /*
                * Get the real edges properties.
                */
                   om_stat = om$send( msg = message EMSedge.EMget_props
						( &msg,
						  &real_edge_props ),
                                      senderid = NULL_OBJID,
                                      targetid = next_edge_common_edge[j] );
                   EMerr_hndlr ( !( 1 & om_stat & msg ), *EMmsg,
				  EMS_E_EdgeError, wrapup);
               /*
		* Establish the correct surface as object 'b', and
                * its parametric tolerance.
		*/
		   om_stat = om$send(
			msg = message EMSboundary.EMgetsurface_info
				( &msg,
				  &sf_id,
				  &tol_basis ),
			targetid = next_edge_common_edge[j],
			senderid = NULL_OBJID );
		   EMerr_hndlr( !( 1 & msg & om_stat ), *EMmsg, msg,
				wrapup );

                   temp_GRid.objid = sf_id;
                   temp_GRid.osnum = OM_Gw_current_OS;
                   om_stat = om$send(
				msg = message EMSedge.EMget_sf_geom
						( &msg,
						  &temp_GRid,
						  &sf2_ptr,
					          md_env ),
				senderid = NULL_OBJID,
				targetid = next_edge_common_edge[j] );

                   EMerr_hndlr( !( 1 & msg & om_stat ), *EMmsg, msg, wrapup );

	           object_b.objid = sf_id;
	           object_b.osnum = OM_Gw_current_OS;

                  /*
                   * Get the egde end justification wrt to the round vertex.
		   */
                  
                   if(real_edge_props & EMED_SUBORDINATE)
                      proc_edge = next_edge[j];
                   else
                   {
                      proc_edge = next_edge_common_edge[j];
                      next_edge_common_edge_is_dominant = TRUE;
                   }

                   for ( k = 0; k < vertex_info->num_edges; k++ )
                     if(IF_EQ_OBJID(proc_edge, vertex_info->edge_ids[k]))
                        break;

                   if (next_edge_common_edge_is_dominant)
                     is_stop_end = vertex_info->edge_stops[k];
                   else
                   {
                     if (real_edge_props & EMED_REVERSE_CONNECT)
                       is_stop_end = !vertex_info->edge_stops[k];
                     else
                       is_stop_end = vertex_info->edge_stops[k];
                   }

                 /*
                  * Create the intersection for the 'sf_id'
	          * as a dum edge on next_edge_common_edge[j].
	          */
                  /* Get the bound corresponding to points[j] */

#if WBC_USE_NEW_MATH
                   EFinit_geom_surface(&msg, sf2_ptr, temp_GRid.objid,
                                       temp_GRid.osnum, &geom_surface);
                   EMerr_hndlr(!( 1 & msg), *EMmsg, EMS_E_EdgeError, wrapup);

                   BSprptarrsf(&geom_surface, basis_tol, 0, 0, &one_point,
                               points[j], param, NULL, &onSurf,
                               NULL, &msg);
                   EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
#else
                   BSprptonsf( &msg,
		               sf2_ptr,
		               points[j],
		               &param[0],
		               &param[1],
		               &onSurf );
                   EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
#endif

                   om_stat = om$send ( msg = message EMSedge.EMptproject
				         ( &msg,
                                           param,
				  	   1,
                                           &proj_info,
					   NULL,
                                           &tol_basis ),
                                       senderid = NULL_OBJID,
                                       targetid = next_edge_common_edge[j],
				       targetos = object_b.osnum );

                   EMerr_hndlr( !( 1 & om_stat & msg ), *EMmsg, EMS_E_EdgeError,
			        wrapup );

                   start_intedpar = (struct EMSsfintedpar *) om$malloc
				   ( size = sizeof( struct EMSsfintedpar));
                   stop_intedpar = (struct EMSsfintedpar *) om$malloc
				   ( size = sizeof( struct EMSsfintedpar));
                   EMerr_hndlr( !start_intedpar || !stop_intedpar, *EMmsg,
                                         EMS_E_NoDynamicMemory, wrapup);

                   start_intedpar->next = stop_intedpar;
                   stop_intedpar->next = NULL;
		   more_info_b = ( IGRchar* ) start_intedpar;

                   /* Get the bound corresponding to either the START or
                    * the STOP end of the real edge.
                    */

                   om_stat = om$send( msg = message EMSedge.EMendpts
					( &msg, 
  				          end_pts_in_uv[0],
					  end_pts_in_uv[1], 
                                          is_stop_end == TRUE 
						? NULL : &edge_pars[0],
				          is_stop_end == TRUE
					        ? &edge_pars[1] : NULL,
                                          NULL ),
                                      senderid = NULL_OBJID,
                                      targetid = next_edge_common_edge[j],
				      targetos = object_b.osnum );

                   EMerr_hndlr(! ( 1 & om_stat & msg ), *EMmsg,
						EMS_E_EdgeError, wrapup );

                   /*
                    * Create the intersection to flow consistantly with
		    * the xyz curve.
		    */
                       /*
			* Recall that j=0 correspond to the dominant round
			* edge, and j=1 correspond to its common edge.  Also
			* recall the directions of curves[0 and 1], and the
			* direction of the corresponding edges on the patch.
			*/

                       if( j == 0 )
                       {
                         start_intedpar->intloc   = proj_info.location;
                         start_intedpar->edgeid   = next_edge_common_edge[j];
                         start_intedpar->edgepar  = proj_info.param;
                         start_intedpar->point[0] = proj_info.proj_pt[0];
                         start_intedpar->point[1] = proj_info.proj_pt[1];
	                 start_intedpar->info = NULL;
                   
                         stop_intedpar->intloc = is_stop_end == TRUE
			    ? EMScvint_rtend : EMScvint_lfend;
                         stop_intedpar->edgeid = next_edge_common_edge[j];
                         stop_intedpar->edgepar
			    = edge_pars[ is_stop_end ? 1 : 0 ];
                         stop_intedpar->point[0]
			    = end_pts_in_uv[ is_stop_end ? 1 : 0 ][0];
                         stop_intedpar->point[1]
			    = end_pts_in_uv[ is_stop_end ? 1 : 0 ][1];
		         stop_intedpar->info = NULL;

			 if( is_stop_end == FALSE )
			    reverse_b = TRUE;
                       }
                       else
                       {
                         stop_intedpar->intloc   = proj_info.location;
                         stop_intedpar->edgeid   = next_edge_common_edge[j];
                         stop_intedpar->edgepar  = proj_info.param;
                         stop_intedpar->point[0] = proj_info.proj_pt[0];
                         stop_intedpar->point[1] = proj_info.proj_pt[1];
	                 stop_intedpar->info = NULL;
                   
                         start_intedpar->intloc =  is_stop_end == TRUE
			    ? EMScvint_rtend : EMScvint_lfend;
                         start_intedpar->edgeid = next_edge_common_edge[j];
                         start_intedpar->edgepar
			    = edge_pars[ is_stop_end ? 1 : 0 ];
                         start_intedpar->point[0]
			    = end_pts_in_uv[ is_stop_end ? 1 : 0 ][0];
                         start_intedpar->point[1]
			    = end_pts_in_uv[ is_stop_end ? 1 : 0 ][1];
		         start_intedpar->info = NULL;

			 if( is_stop_end == TRUE )
			    reverse_b = TRUE;
                       }

                      edge_pars[0] = start_intedpar->edgepar;
                      edge_pars[1] = stop_intedpar->edgepar;

                   /*
                    * Create the dum edge.
		    */
                       /*
			* Why the following?  Well, it is a long story...
			* If the start bound is larger than the lower, then
			* the reverse property on the edge must be set.
			*/
                           if( edge_pars[0].span_inx + edge_pars[0].param >
			   	 edge_pars[1].span_inx + edge_pars[1].param )
                               dum_edge_props |= EMED_REVERSED;

                       /*
			* Extract the appropriate properties from the
			* edge.
			*/
			   dum_edge_props |= real_edge_props &
				(EMED_NATURAL | EMED_DEGENERATE | EMED_ISO);

                       dum_edge_props |= EMED_OPEN;

                       om_stat = om$construct(
					classid = OPP_EMSdumedge_class_id,
                                        p_objid = &edge_object->objid,
                                        msg = message EMSpartedge.EMpeinit
						   ( &msg,
                                                     dum_edge_props,
						     edge_pars,
						     NULL ) );
                       EMerr_hndlr(! (1 & om_stat), *EMmsg, EMS_E_OMerror,
				     wrapup );
		   edge_object->osnum = OM_Gw_current_OS;
   
                   chan_count = 0;
                   om_stat = om$get_channel_count
				( objid = next_edge_common_edge[j],
                                  osnum = OM_Gw_current_OS,
                                  p_chanselect = &chan_to_owner, 
                                  count = ( IGRuint * ) &chan_count );
                   EMerr_hndlr(! (1 & om_stat), *EMmsg, EMS_E_OMerror, wrapup);

                   om_stat = om$send( msg = message Root.connect
					( chan_to_edge,
					  chan_count,
                                          next_edge_common_edge[j],
					  OM_Gw_current_OS, 
                                          chan_to_owner,
					  NULL), 
                                      targetid = edge_object->objid,
				      targetos = edge_object->osnum,
                                      senderid = next_edge_common_edge[j] );
                   EMerr_hndlr(! (1 & om_stat), *EMmsg, EMS_E_OMerror, wrapup);

                   /*
                    * Deallocate the memory for sf2_ptr in case we loop around again
                    * to where it gets allocated.
                    */
                   if(sf2_ptr)
                    {
                      om$dealloc( ptr = sf2_ptr );
                      sf2_ptr = NULL;
                    }
             }

         /*
          * Make object 'b' this uv data as the preceding edge.
	  */
             object_b_uvdata.datatype = EMSdata_object;
	     object_b_uvdata.data.object = edge_object;
	     edge_object = NULL;

         EMmakeintlist( &msg,
		      inters1, inters2,
		      &object_a,&object_b,
                      NULL,NULL,NULL,NULL,
                      &xyz_data,
		      &object_a_uvdata, &object_b_uvdata,
                      reverse_a, reverse_b,
		      more_info_a, more_info_b,
                      props_a, props_b,
                      NULL, NULL,
		      TRUE,
		      FALSE );
         EMerr_hndlr( !( 1 & msg ), *EMmsg, msg, wrapup );
         more_info_a = NULL;
         more_info_b = NULL;
         start_intedpar =
	 stop_intedpar =
	 bdry_pars = NULL;
	 curve[j] = NULL;
       }

   /*
    * Determine and set the 'fwd' and 'bwd' pointers for the patch.  This
    * will avoid tracing inacuracies during subsequent operations.
    */
       {
          struct EMSintobj      *patch_intobjs[3], *temp_intobj;
          struct EMSinters	*temp_inters;
          
          for( temp_inters = *inters1; temp_inters->this_obj.objid != pch_id;
				temp_inters = temp_inters->next );

          /*
           * Get the intobjs in the order, U0, the fillet-patch intersection,
           * and V0.
           */
              for( temp_intobj = temp_inters->cvs; temp_intobj;
				temp_intobj = temp_intobj->next )
                 if( temp_intobj->this_uvintobj.datatype == EMSdata_object )
                    if( temp_intobj->this_uvintobj.data.object->objid == 
			        nat_edges[0] )
		       patch_intobjs[0] = temp_intobj;
                    else
		       patch_intobjs[2] = temp_intobj;
	         else    
		       patch_intobjs[1] = temp_intobj;

          /*
           * Now, set the 'fwd' and 'bwd' pointers.
           */
              for( i = 0; i < 3; i++ )
              {
                 patch_intobjs[i]->props |= EMSintobj_fwd_connectuv |
					    EMSintobj_bwd_connectuv;
                 patch_intobjs[i]->fwd = patch_intobjs[ i == 2 ? 0 : i+1 ];
                 patch_intobjs[i]->bwd = patch_intobjs[ i == 0 ? 2 : i-1 ];
              }
       }

wrapup:

/* fix for mlk */
    if(sf_edges) 
      {
      om$dealloc(ptr = sf_edges);
      sf_edges = NULL;
      }
    if (uv_pts)
       {
       for (ii=0; ii<num_grps; ii++)
          if (uv_pts[ii])
             om$dealloc (ptr = uv_pts[ii]);
       om$dealloc (ptr = uv_pts);
       }
    if(num_elms_grp)
      {
      om$dealloc (ptr = num_elms_grp);
      num_elms_grp=NULL;
      }
    if (pj_pts)
       {
       for (ii=0; ii<num_grps; ii++)
          if (pj_pts[ii])
             om$dealloc (ptr = pj_pts[ii]);
       om$dealloc (ptr = pj_pts);
       }

    if(sf2_ptr)
     {
      om$dealloc( ptr = sf2_ptr );
      sf2_ptr = NULL;
     }

    
    /* added code to deallocate memory allocated by EMget_bcxyz_geom */

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

    if(xyz_pts0) free(xyz_pts0);
    if(xyz_pts1) free(xyz_pts1);
    if(pars0)   free(pars0);
    if(pars1)   free(pars1);

    BSfreesf( &msg, surf );

    if( object ) om$dealloc( ptr = object );
    if( edge_object ) om$dealloc( ptr = edge_object );

    EMsfintedpar_free( bdry_pars, 0 );
    EMsfintedpar_free( start_intedpar, 0 );
    EMsfintedpar_free( stop_intedpar, 0 );
    EMsfintedpar_free( ( struct EMSsfintedpar * ) more_info_a, 0 );

    for( i = 0; i < 2; i++ )
       if( curve[i] )
          BSfreecv( &msg, curve[i] );

    if (geom_surface.sfgen_cv)
        BSfreecv(&msg, geom_surface.sfgen_cv);

    EMWRAPUP( *EMmsg, om_stat, "EMsingle_patch" );

    return(om_stat);
}


static IGRboolean chkatend (xyzdata, py, srf)
struct EMSdataselect *xyzdata;
struct EMSpypoint *py;
struct IGRbsp_surface *srf;
{
  IGRboolean atbdry=TRUE, found;
  IGRshort i, j;
  IGRlong msg_loc;
  IGRdouble chttol;
  IGRpoint sfpt[1], endpts[2];
  extern IGRdouble BSdistptpt();

  for (i=FIRST; i<=SECOND; i++)
    {
    if (!(py->props & (EMS_PYPT_ATSTART | EMS_PYPT_ATSTOP)))
      {
      BSsfeval (srf, py->point[U], py->point[V], 0, sfpt, &msg_loc);
      EMerr_hndlr (msg_loc != BSSUCC, atbdry, FALSE, ret_end);

      EMgetendpts_xyz (&msg_loc, NULL, NULL, xyzdata, FALSE, 1, 
       endpts[START], endpts[STOP]);
      EMerr_hndlr (EMSerror (msg_loc), atbdry, FALSE, ret_end);

      BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, chttol);  
      found = FALSE;
      for (j=START; j<=STOP; j++)
        if (BSdistptpt (&msg_loc, sfpt, endpts[j]) <= chttol)
          {
          found = TRUE;
          break;
          }
      EMerr_hndlr (!found, atbdry, FALSE, ret_end);
      }
    py = py->next;
    }

ret_end:
  return (atbdry);
}


end implementation EMSsfrndbool;

