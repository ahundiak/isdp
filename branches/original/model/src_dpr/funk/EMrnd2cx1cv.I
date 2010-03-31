/*
    DESCRIPTION:
    This function provide solutions for a 3-edge vertex that has two edges
    with the same classification, the third is non-neutral, and the two edges
    with the same classification are rounded. 
    If the two fillets intersect the non-rounded edge at a distinct point, 
    special solutions are provided. All other cases result in a general 
    blend solution.
    The kind of special solution is defined by the global "rnd_2cx1cv_bln"
    (defined in ECdbgsendi.I). By default it is FALSE. Under this condition,
    a sharp transition between the two fillets, resulting from the
    intersection between the two fillets is provided.
    Else a three sided blend patch with an edge degeneracy on the unrounded
    edge is provided.

    ARGUMENTS

    comp_sf_GRid        - Input/Output: Composite surface to which the blend 
                          patch will be connected to if that solution is 
                          taken. Else it will remain untouched.

    fillet_inters       - Input/Output: The "intersections" between the
                           the fillets and the patches generated herein
                           are recorded in this list.

    model_inters        - Input/Output: The "intersections" between the
                           the fillets/patches and the model generated herein
                           are recorded in this list.
   HISTORY

    Inasu  : Oct 05, 91  : Creation.
    DLB    : 02/11/92    : Comment out resetting of const_list->msg.
    WBC    : 01/13/93    : Replaced the call to BSprptonsf with a call to
                           BSprptarrsf.
    Janaka : 06-21-93	 : Re-write during Phoenix (unscheduled).
    KNAP   : Feb ' 94    : Re-write.
*/

class implementation EMSsfrndbool;

%safe
#include <math.h>
%endsafe
#include "bserr.h"
#include "bsparameters.h"
#include "OMmacros.h"
#include "emssfintdef.h"
#include "EMSprop.h"
#include "emsinter.h"
#include "emsinterdef.h"
#include "bsgeom_cvsf.h"
#include "bsalloccv.h"
#include "bsmdistcvcv.h"
#include "bsconstprcv.h"
#include "bssfarrevn.h"
#include "bsrev_cv.h"
#include "bscvarrevt.h"
#include "bsnorvec.h"
#include "bsdotp.h"
/*
#include "EMSrndprotyp.h"
*/

#define  FIRST	0
#define  SECOND 1
#define  THIRD  2

#define  THIS_FILLET   0
#define  OTHER_FILLET  1

#define  FILLET_U0   0
#define  FILLET_U1   1

#define  U 0
#define  V 1

#define  UNDEFINED  -1

#define  LIMITING_INC_ANG  PI/180.0*10.0

extern  IGRint	 rnd_2cx1cv_bln;
from    EMSedge  import EMget_props;

/* pathway flags */
extern IGRboolean _pathway_trim, _pathway_orient;

IGRlong EM2edge_cx_1edge_cv( msg, options, construct_list, vtx_rnd_info,
                             comp_sf_GRid, fillet_inters, model_inters )
IGRlong			*msg;
IGRushort		options;
struct GRvg_construct	*construct_list;
struct EMSvtx_rnd_info	*vtx_rnd_info;
struct GRid		*comp_sf_GRid;
struct EMSinters	**fillet_inters, **model_inters;
{
  IGRboolean   intersect_fillets, no_blend_solution, are_identical,
               is_stop_end;
  IGRushort    world_options, trim_options, param_options, ed_props;
  IGRshort     mat_type;
  IGRlong      msg_loc, stat, num_fil_inters;
  IGRint       i, j, k, inx, inx1, inx2, non_rnded_inx, rnded_inx[2], 
	       num_vtx_eds, num_intobjs_to_keep, num_bnd_cvs, int_iso_type[2],
	       other_iso_type;
  IGRdouble    ref_dotp, dotp, *matrix, cht_tol, v_par[2], uv_par[2];
  IGRpoint     int_xyz_pt[2], pt_xyz, dum_pt;
  IGRvector    sf_normal, tan_vecs[2];

  GRspacenum   os;
  GRobjid      bln_sf_id, bln_tan_sf_ids[3], bln_ed_ids[3], dum_ed_ids[2],
	       non_rnded_edge_id;

  OMuint                          count;
  OM_S_CHANSELECT                 to_comm_edge;
  OM_S_OBJECT_LINKAGE             chan_objs[1];
  struct  EMSinters               *loc_fillet_inters, *loc_model_inters;
  struct  GRmd_env                *md_env;
  struct  EMSdataselect           uvdata[2], xyzdata[2], other_data,
				  model_uv_data[3], bln_uv_data, xyz_dataselect;
  struct  EMSsfintedpar           *model_intedpar, *bln_intedpar;
  struct  GRid                    bln_GRid, tmp_GRid, model_GRid, *bln_uv_GRid;
  struct  EMSintobj               **keep_intobjs=NULL, *tmp_intobj;
  struct  IGRbsp_curve            *bnd_cvs[3];
  struct  IGRbsp_surface          *bln_sf_geom, *bln_tan_sf_geoms[3];
  struct  EMSedge_rnd_info        **ed_infos, *tmp_ed_infos[2];
  struct  EMSedge_blend_info      *ed_bln_info[2];
  struct  EMSrnd_blend_curve_info *transcv_info;

  IGRlong      EMget_n_sided_blend();
  IGRboolean   EMis_geomequal_3dpt();
  struct  EMSsfintedpar *EMsfintedpar_malloc();
  extern  IGRdouble EMget_fillet_int_data();
  void    EMinit_rnd_blend_curve_info(), EMdataselect_data_free(),
          EMsfintedpar_free(), EMmergeinters(), EMinters_free(),
          EMinters_data_free();

  IGRboolean save_pathway_trim, save_pathway_orient;

  *msg = EMS_S_Success;
  stat = OM_S_SUCCESS;
  BSEXTRACTPAR( &msg_loc, BSTOLCHRDHT, cht_tol );

  num_vtx_eds = vtx_rnd_info->num_edges;
  ed_infos = vtx_rnd_info->edge_infos;
  md_env = construct_list->env_info;
  mat_type = md_env->md_env.matrix_type;
  matrix = md_env->md_env.matrix;
  os = md_env->md_id.osnum;
  is_stop_end = FALSE;
  no_blend_solution = FALSE;
  intersect_fillets = TRUE;
  num_bnd_cvs = num_vtx_eds;
  loc_fillet_inters = NULL;
  loc_model_inters = NULL;

  for ( i = 0; i < 2; i++ )
  {
    ed_bln_info[i] = ( struct EMSedge_blend_info * ) alloca
                              ( sizeof( struct EMSedge_blend_info ));
    dum_ed_ids[i] = NULL_OBJID;
  }

  for ( i = 0; i < num_vtx_eds; i++ )
  {
    bnd_cvs[i] = NULL;
    model_uv_data[i].datatype = EMSdata_null;
  }

  bln_sf_geom = NULL;
  transcv_info = NULL;
  model_intedpar = bln_intedpar = NULL; bln_uv_GRid = NULL;
  EMmake_chanselect( EMSedge_to_common_edge, &to_comm_edge );
  
  for ( i = THIS_FILLET; i <= OTHER_FILLET; i++ )
  {
    for( j = FIRST; j <= SECOND; j++ )
    {
      ed_bln_info[i]->setback_pt_stat[j]     = setback_pt_undefined;
      ed_bln_info[i]->counter_part[j]        = UNDEFINED;
      ed_bln_info[i]->fillet_int_iso[j]      = UNDEFINED;
      ed_bln_info[i]->setback_pts_refined[j] = FALSE;
      ed_bln_info[i]->bln_cv_props[j]        = EMSrnd_bln_trans_cv_unknown;
    }
    ed_bln_info[i]->blend_cv_type = blend_curve_undefined;
    ed_bln_info[i]->default_setback = UNDEFINED;
  }
  
  /*
   *  Store the indices of the rounded and non-rounded edges.
   */

  j = 0;
  for ( i = 0; i < num_vtx_eds; i++ )
  {
    if ( ed_infos[i] )
    {
      rnded_inx[j]=i;
      j++;
    }
    else
      non_rnded_inx = i;
  }

  /*
   * Intersect each fillet with the non-rounded edge. The intersecting 
   * iso-type, the intersection point, and the const-v parametric curves
   * at the intersection point are stored. These curves will form the
   * bound curves for the blend patch.
   */

  for ( i = THIS_FILLET; i <= OTHER_FILLET; i++ )
  {
    non_rnded_edge_id = vtx_rnd_info->edge_ids[non_rnded_inx];
    v_par[i] = EMget_fillet_int_data ( &msg_loc, ed_infos[rnded_inx[i]],
			               non_rnded_edge_id, os, 
			               vtx_rnd_info->edge_stops[rnded_inx[i]],
			               &int_iso_type[i], &uvdata[i],
                                       &xyzdata[i], NULL, int_xyz_pt[i]);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, wrapup);
  }
  
  /*
   * Check if the intersection points are unique.
   */

  if ( EMis_geomequal_3dpt( int_xyz_pt[THIS_FILLET], int_xyz_pt[OTHER_FILLET],
                            2 * cht_tol ) == TRUE )
  {
    stat = EMget_edge_tangents_at_rnd_vtx( &msg_loc, md_env, vtx_rnd_info,
                                              rnded_inx, tan_vecs );
    EMerr_hndlr( !( 1 & stat & msg_loc ), *msg, EMS_E_Fail, wrapup );
    ref_dotp = cos( LIMITING_INC_ANG );
    dotp = BSdotp( &msg_loc, tan_vecs[FIRST], tan_vecs[SECOND] );
    EMerr_hndlr( msg_loc != BSSUCC, *msg, EMS_E_BSerror, wrapup );

    EMget_rnd_included_data ( &msg_loc, ed_infos[rnded_inx[THIS_FILLET]],
                              ed_infos[rnded_inx[OTHER_FILLET]],
                              vtx_rnd_info->vtx_pt, NULL, NULL, NULL,
                              NULL, NULL, dum_pt );  
    if ( EMSerror( msg_loc ))
      intersect_fillets = FALSE;
 
    if( rnd_2cx1cv_bln || fabs( dotp ) > ref_dotp ||
        intersect_fillets == FALSE )
    {
      /*
       *  Construct a 3-sided blend patch, the first bounding curve is the
       *  constant-v parametric curve on the OTHER_FILLET, followed by a
       *  fillet iso-iso transition on the included surface, and then again
       *  another constant-v parametric curve on the THIS_FILLET. These curves
       *  are oriented consistently with the cyclic order defined by edges at
       *  the round vertex. 
       */

      for ( i = OTHER_FILLET; i >= THIS_FILLET; i-- )
      {
        IGRint ii;
        OM_BLOCK_MOVE ( xyzdata[i].data.curve->poles, pt_xyz,
                        sizeof( IGRpoint ));
        /*
         * Un weight the pole if the curve is rational.
         */ 
        if (xyzdata[i].data.curve->rational && xyzdata[i].data.curve->weights)
          for (ii=0; ii<3; ii++)
             pt_xyz[ii] /= xyzdata[i].data.curve->weights[0];

        if (EMis_geomequal_3dpt ( pt_xyz, int_xyz_pt[i], 2*cht_tol) == TRUE)
        {
          if ( i == THIS_FILLET )
          {
	    EMdata_reverse(&xyzdata[i]);
	    EMdata_reverse(&uvdata[i]);
          }
        }
        else
        {
          if ( i == OTHER_FILLET )
          {
	    EMdata_reverse(&xyzdata[i]);
	    EMdata_reverse(&uvdata[i]);
          }
        }

        k = i == FIRST ? SECOND : FIRST;
	other_iso_type = int_iso_type[i] == FILLET_U0 ? FILLET_U1 : FILLET_U0;
        ed_bln_info[k]->setback_pt_stat[k] = setback_pt_defined;
        ed_bln_info[k]->fillet_int_iso[k] = other_iso_type;
        ed_bln_info[k]->setback_pts_uv[k][U] = other_iso_type;
        ed_bln_info[k]->setback_pts_uv[k][V] = v_par[i];
        OM_BLOCK_MOVE( int_xyz_pt[i], ed_bln_info[k]->setback_pts_xyz[k],
                       sizeof( IGRpoint ));
        count = 0;
        stat = om$get_channel_objects( 
                      objid = ed_infos[rnded_inx[i]]->edge_id,
                      p_chanselect = &to_comm_edge, osnum = os,
                      count = &count, size = 1, list = chan_objs );
        EMerr_hndlr ( !( 1 & stat ) || count != 1, *msg, EMS_E_Fail, wrapup );
        stat = om$send( msg = message EMSedge.EMget_props( &msg_loc,
                                      &ed_props ),
                              senderid = NULL_OBJID,
                              targetos = os,
                              targetid = chan_objs[FIRST].S_objid );
        EMerr_hndlr( !( 1 & stat & msg_loc ), *msg, EMS_E_EdgeError, wrapup );
        is_stop_end = ( ed_props & EMED_REVERSE_CONNECT ? 1 : 0 ) ^
                      ( vtx_rnd_info->edge_stops[ rnded_inx[i]] ? 1 : 0 )
                        ? TRUE : FALSE;

        inx1 = i == THIS_FILLET ? SECOND : FIRST;
        inx2 = i == THIS_FILLET ? FIRST : SECOND;

        if( int_iso_type[i] == FILLET_U1 )
        {
          ed_bln_info[k]->ed_ids[inx1] = ed_infos[rnded_inx[i]]->edge_id;
          ed_bln_info[k]->rnd_end_stop[inx1] = 
                                     vtx_rnd_info->edge_stops[rnded_inx[i]];
          ed_bln_info[k]->FIRST_is_dominant = inx1 == FIRST ? TRUE : FALSE;
          ed_bln_info[k]->ed_ids[inx2] = chan_objs[FIRST].S_objid;
          ed_bln_info[k]->rnd_end_stop[inx2] = is_stop_end;
        }
        else
        {
          ed_bln_info[k]->ed_ids[inx1] = chan_objs[FIRST].S_objid;
          ed_bln_info[k]->rnd_end_stop[inx1] = is_stop_end;
          ed_bln_info[k]->FIRST_is_dominant = inx2 == FIRST ? TRUE : FALSE;
          ed_bln_info[k]->ed_ids[inx2] = ed_infos[rnded_inx[i]]->edge_id;
          ed_bln_info[k]->rnd_end_stop[inx2] = 
                                      vtx_rnd_info->edge_stops[rnded_inx[i]];
        }
	j = i == THIS_FILLET ? THIRD : FIRST;
        bnd_cvs[j] = xyzdata[i].data.curve;
	tmp_ed_infos[k] = ed_infos[rnded_inx[i]];
	bln_tan_sf_geoms[j] = ed_infos[rnded_inx[i]]->fill_surf;
	bln_tan_sf_ids[j] = ed_infos[rnded_inx[i]]->fill_id;
	OM_BLOCK_MOVE( &uvdata[i], &model_uv_data[j],
				   sizeof( struct EMSdataselect ));
      }

      /*
       *  Generate a fillet iso-iso trnasition curve. This will be the
       *  second bound curve.
       */

      stat = EMget_bln_cv_from_fillet_or_edge( &msg_loc, (IGRushort) 0,
		   md_env, tmp_ed_infos, dum_ed_ids, ed_bln_info,
		   &transcv_info );
      EMerr_hndlr( !( 1 & stat & msg_loc ), *msg, EMS_E_Fail, wrapup );

      bnd_cvs[SECOND] = transcv_info->xyz_geom;
      bln_tan_sf_geoms[SECOND] = transcv_info->tangent_sf_geom;
      bln_tan_sf_ids[SECOND] = transcv_info->tangent_sf_id;
      OM_BLOCK_MOVE( &transcv_info->uv1, &model_uv_data[SECOND],
                                        sizeof( struct EMSdataselect ));
      transcv_info->uv1.datatype = EMSdata_null;
      
      /*
       * Make the bound curves positional continuous.
       */
      for (i=0; i <num_bnd_cvs; i++)
      {
        j = (i+1)%num_bnd_cvs;
        EMmake_curves_pos_continuous (bnd_cvs[i], bnd_cvs[j]);
      }

      /*
       * Need to get the surface normal at the end of the first bound curve.
       */
      inx = model_uv_data[FIRST].data.poly->num_points - 1;
      uv_par[U] = model_uv_data[FIRST].data.poly->points[2*inx];
      uv_par[V] = model_uv_data[FIRST].data.poly->points[2*inx + 1];
      BSsfarrevn( &msg_loc, bln_tan_sf_geoms[FIRST], (IGRint) 1,
                  &uv_par[U], (IGRint) 1, &uv_par[V], dum_pt, sf_normal);
      EMerr_hndlr( msg_loc != BSSUCC, *msg, EMS_E_BSerror, wrapup );
      if( bln_tan_sf_geoms[FIRST]->pos_orient == FALSE )
        for( i = 0; i < 3; i++ )
          sf_normal[i] = -sf_normal[i];

      stat = EMcreate_3or4cv_blend_surface( &msg_loc, (IGRushort) 0,
               construct_list, (IGRint) 3, bnd_cvs, bln_tan_sf_geoms,
               &sf_normal, comp_sf_GRid, bln_ed_ids, NULL, &bln_sf_id );
      EMerr_hndlr( !( 1 & stat & msg_loc ), *msg, EMS_E_Fail, wrapup );
      no_blend_solution = TRUE;

      tmp_GRid.objid = bln_sf_id;
      tmp_GRid.osnum = os;
      stat = EMgetvggeom( &msg_loc, &mat_type, matrix, &tmp_GRid,
                               ( IGRchar * ) &bln_sf_geom, NULL );
      EMerr_hndlr( !( 1 & stat & msg_loc ), *msg, EMS_E_Fail, wrapup );

      bln_GRid.objid = bln_sf_id;
      bln_GRid.osnum = os;

      /*
       *  Add the bound curves in to the inters list.
       */

      for( i = FIRST; i < num_bnd_cvs; i++ )
      {
        model_GRid.objid = bln_tan_sf_ids[i];
        model_GRid.osnum = os;
        xyz_dataselect.datatype = EMSdata_curve3d;
        xyz_dataselect.data.curve = bnd_cvs[i];

        bln_uv_GRid = ( struct GRid * ) om$malloc
                                          ( size = sizeof( struct GRid ) );
        EMerr_hndlr( !bln_uv_GRid, *msg, EMS_E_NoDynamicMemory, wrapup );
        bln_uv_GRid->objid = bln_ed_ids[i];
        bln_uv_GRid->osnum = os;
        bln_uv_data.datatype = EMSdata_object;
        bln_uv_data.data.object = bln_uv_GRid;

        model_intedpar = EMsfintedpar_malloc( &msg_loc, ( IGRint ) 2 );
        bln_intedpar = EMsfintedpar_malloc( &msg_loc, ( IGRint ) 2 );

        EMmakeintlist( &msg_loc,
                       i == 1 ? &loc_model_inters : &loc_fillet_inters,
                       &loc_fillet_inters, &model_GRid, &bln_GRid,
                       NULL, NULL,
                       NULL, EMSinters_loopcreated,
                       &xyz_dataselect,
                       &model_uv_data[i], &bln_uv_data,
                       bln_tan_sf_geoms[i]->pos_orient ==
                               bln_sf_geom->pos_orient ? TRUE : FALSE,
                       FALSE, ( IGRchar * ) model_intedpar,
                       ( IGRchar * ) bln_intedpar,
                       i == 1 ? ( IGRulong ) EMSintobj_marked |
                                             EMSintobj_tangent
                              : ( IGRulong ) EMSintobj_marked |
                                  EMSintobj_tangent | EMSintobj_isocurve,
                       ( IGRulong ) EMSintobj_marked | EMSintobj_tangent,
                       NULL, NULL, TRUE, FALSE );

        EMerr_hndlr( !( 1 & msg_loc ), *msg, EMS_E_Fail, wrapup );
        model_intedpar = bln_intedpar = NULL;
        bln_uv_GRid = NULL; bnd_cvs[i] = NULL;
        transcv_info->xyz_geom = NULL;
        model_uv_data[i].datatype = EMSdata_null;
      }

      EMmergeinters( &msg_loc, fillet_inters, loc_fillet_inters );
      EMerr_hndlr( !( 1 & msg_loc ), *msg, EMS_E_Fail, wrapup );
      loc_fillet_inters = NULL;
 
      EMmergeinters( &msg_loc, model_inters, loc_model_inters );
      EMerr_hndlr( !( 1 & msg_loc ), *msg, EMS_E_Fail, wrapup );
      loc_model_inters = NULL;
    }
    else
    {
      /*
       * Generate a sharp transition by intersecting both the fillets.
       */
       
      world_options = EMSINT_OUTPUT_WORLD | EMSINT_ORIENT_OUTPUT ;
      param_options = EMSINT_OUTPUT_PARAM | EMSINT_ORIENT_OUTPUT ;
      trim_options  = EMSINT_TRIM_OUTPUT  | EMSINT_TRIM_BDRYISAREA |
                      EMSINT_TRIM_HANDLESTOP;
      if( vtx_rnd_info->edge_configs[rnded_inx[OTHER_FILLET]] ==
                                                   EMSedge_concave )
      {
        world_options  |= EMSINT_ORIENT_RIGHT;
        param_options  |= EMSINT_ORIENT_RIGHT;
      }

      num_fil_inters = 0;
      other_data.datatype    = EMSdata_object;
      tmp_GRid.objid         = ed_infos[rnded_inx[OTHER_FILLET]]->fill_id;
      tmp_GRid.osnum         = os;
      other_data.data.object = &tmp_GRid;

      save_pathway_trim = _pathway_trim;
      save_pathway_orient = _pathway_orient;

      _pathway_trim = 0;
      _pathway_orient = 0;
     
      stat = om$send( msg = message EMSsurface.EMsfsfint( &msg_loc,
                                                 &mat_type, matrix,
                                                 construct_list,
                                                 &other_data,
                                                 &md_env->md_env,
                                                 world_options,
                                                 param_options,
                                                 trim_options,
                                                 &num_fil_inters,
                                                 &loc_fillet_inters,
                                                 &loc_fillet_inters),
                        senderid = NULL_OBJID,
                        targetid = ed_infos[rnded_inx[THIS_FILLET]]->fill_id,
                        targetos = os );

       _pathway_trim = save_pathway_trim;
       _pathway_orient = save_pathway_orient;

      EMerr_hndlr( EMSerror( stat & msg_loc ) || !num_fil_inters, *msg,
                   EMS_E_SurfaceError, wrapup );

      stat = EMweed_out_inters (&msg_loc, NULL, md_env,
                 vtx_rnd_info->vtx_pt, loc_fillet_inters,
                 &num_intobjs_to_keep, &keep_intobjs, &are_identical);
      EMerr_hndlr (EMSerror (msg_loc & stat) || num_intobjs_to_keep != 1,
                   *msg, EMS_E_Fail, wrapup);

      if (!are_identical)
        for (tmp_intobj=loc_fillet_inters->cvs; tmp_intobj;
             tmp_intobj=tmp_intobj->next)
          if (tmp_intobj != *keep_intobjs)
            EMdelintobj (&msg_loc, tmp_intobj);

      for (k = THIS_FILLET; k <=OTHER_FILLET; k++)
      {
        tmp_intobj = loc_fillet_inters->cvs;
        if (k==OTHER_FILLET)
          tmp_intobj = tmp_intobj->other_intobj_node;
        EFmaptobnd (&msg_loc, NULL, ed_infos[rnded_inx[k]]->fill_surf,
                    2*cht_tol, &tmp_intobj->this_xyzintobj,
                    &tmp_intobj->this_uvintobj);
      }

      EMmergeinters( &msg_loc, fillet_inters, loc_fillet_inters );
      EMerr_hndlr( EMSerror( msg_loc ), *msg, EMS_E_Fail, wrapup );
      loc_fillet_inters = NULL;
      no_blend_solution = TRUE;
    }
  }
  else
  {
    stat = EMget_n_sided_blend( &msg_loc, ( IGRushort ) 0, construct_list,
            vtx_rnd_info, comp_sf_GRid, fillet_inters, model_inters );
    EMerr_hndlr( !( 1 & stat & msg_loc ), *msg, EMS_E_Fail, wrapup );
    no_blend_solution = TRUE;
  }

wrapup:
  EMinters_data_free( &msg_loc, loc_fillet_inters, ( IGRint ) 0, NULL,
                      EMsfintedpar_free );
  EMinters_free( loc_fillet_inters, ( IGRint ) 0 );
 
  EMinters_data_free( &msg_loc, loc_model_inters, ( IGRint ) 0, NULL,
                      EMsfintedpar_free );
  EMinters_free( loc_model_inters, ( IGRint ) 0 );
  for( i = FIRST; i < num_bnd_cvs; i++ )
    if( bnd_cvs[i] ) BSfreecv( &msg_loc, bnd_cvs[i] );

  if( bln_sf_geom ) om$dealloc( ptr = bln_sf_geom );
  EMdealloc_rnd_blend_curve_info( &msg_loc, transcv_info, (IGRint)1 );
  if( !( 1 & msg_loc ) )
    *msg = EMS_E_Fail;

  if (transcv_info)
    om$dealloc (ptr = transcv_info);

  transcv_info = NULL;
  EMdataselect_data_free( &msg_loc, model_uv_data, ( IGRint ) 3 );
  if( !( 1 & msg_loc ) )
    *msg = EMS_E_Fail;
 
  if( bln_uv_GRid )      om$dealloc( ptr = bln_uv_GRid );
 
  EMsfintedpar_free( model_intedpar, ( IGRint ) 0 );
  EMsfintedpar_free( bln_intedpar, ( IGRint ) 0 );

  if (EMSerror (*msg) && !no_blend_solution)
    stat = EMget_n_sided_blend (msg, options, construct_list,
               vtx_rnd_info, comp_sf_GRid, fillet_inters, model_inters);
 
  EMWRAPUP( *msg, stat, "EM2edge_cx_1edge_cv" );
  return(stat);
}
end implementation EMSsfrndbool;
