#ifndef EMSnrdprotyp_include
#define EMSrndprotyp_include	1


/*
 * This file contains the ANSI function prototypes for functions used
 * within rounding.
 */


IGRlong EMget_rndedge_neighbors_sf_id( IGRlong *EMmsg,
             GRobjid neighbor_ed, struct EMSedge_rnd_info *rnd_ed,
             GRobjid *neighbor_ed_sf_id, struct EMSpartolbasis *partol );

IGRlong EMget_edges_int_pt( IGRlong *EMmsg, struct GRmd_env *md_env,
               IGRpoint ref_pt, struct EMSdataselect *edge1_geom,
               struct EMSdataselect *edge2_geom, IGRdouble *int_pt1_xyz,
               IGRdouble *int_pt2_xyz, IGRdouble *int_pt1_uv,
               IGRdouble *int_pt2_uv );

IGRlong EMweed_out_inters( IGRlong *EMmsg, IGRushort options,
          struct GRmd_env *md_env, IGRpoint ref_pt,
          struct EMSinters *inters_list,
          IGRint *num_intobjs_to_keep, struct EMSintobj ***keep_intobjs,
          IGRboolean *are_identical );

IGRlong	EMget_mindist_to_grp( IGRlong *EMmsg, IGRshort mat_type,
              IGRmatrix matrix, IGRpoint ref_pt,
              struct EMSintobj *subgrps[], IGRint num_subgrps,
              IGRint num_elems_per_subgrp[], IGRdouble *min_dist,
              IGRint *total_num_elems );

IGRlong EMget_sf_BSgeom_info( IGRlong *EMmsg, struct GRmd_env *md_env,
             struct EMSdataselect *sf, struct BSgeom_bsp_surf *sf_info,
             IGRboolean *sf_geom_constructed );

IGRlong	EMget_edge_tangents_at_rnd_vtx( IGRlong *EMmsg,
          struct GRmd_env		*md_env,
          struct EMSvtx_rnd_info 	*rnd_vtx_info,
          IGRint 			ed_inx[2],
          IGRvector 			tan_vecs[2] );

IGRlong EMget_neighbor_pos_wrt_ed( IGRlong *EMmsg, IGRushort options,
           struct GRmd_env *md_env, GRobjid ed, GRobjid neighbor_ed,
           IGRboolean *neighbor_ed_at_stop );

IGRlong EMget_chain_free_ends( IGRlong *EMmsg, IGRushort options,
           struct GRmd_env *md_env, struct GRid *chain_eds,
           IGRint num_eds, IGRint *chain_free_ends );

/* ------------------ definitions in EMrndblnsupp.I ---------------------- */
/*
IGRlong EMget_ed1_ed2_int_info( IGRlong *EMmsg, IGRushort options,
         struct GRmd_env		*md_env,
         struct EMSedge_rnd_info	*ed1_with_fillet,
         struct EMSedge_rnd_info	*ed2_with_fillet,
         IGRboolean			*found,
         struct EMSedge_blend_info	**ed_bln_info );
*/
IGRlong  EMget_ed1_ed2_int_info (IGRlong *EMmsg, IGRushort options,
           struct GRmd_env                *md_env,
           struct EMSedge_rnd_info        *ed1_with_fillet,
           struct EMSedge_rnd_info        *ed2_with_fillet,
           IGRboolean                     *found,
           struct EMSedge_blend_info      **ed_bln_info);

IGRlong EMget_setback_pts_on_fillet_along_ed( IGRlong *EMmsg,
                 IGRushort			options,
                 struct GRmd_env		*md_env,
                 struct EMSedge_rnd_info 	*ed_info,
                 struct EMSedge_blend_info	*ed_bln_info );

IGRlong EMvalidate_int( IGRlong *EMmsg, IGRushort options,
               struct EMSedge_rnd_info *ed_info,
               IGRpoint ref_pt,
               IGRboolean is_stop,
               IGRdouble v_value,
               IGRboolean *is_legal );

IGRlong EMfix_setback_on_edge( IGRlong *EMmsg,
                 struct GRmd_env		*md_env,
                 struct EMSedge_blend_info	*ed_blend_info );

IGRlong EMfix_setback_on_fillet( IGRlong *EMmsg,
                  struct GRmd_env		*md_env,
                  struct EMSedge_rnd_info	**ed_rnd_infos,
                  struct EMSedge_blend_info	*setback_infos,
                  struct EMSvtx_rnd_info	*vtx_rnd_info,
                  IGRint			ed_inx,
                  IGRdouble			def_setback );

IGRlong EMadjust_setback_pt_along_fillet_iso( IGRlong *EMmsg,
                  IGRboolean	      	        processing_ed_stop_end,
                  struct EMSedge_rnd_info	*ed_rnd_info,
                  IGRdouble			setback_dist,
                  IGRdouble		        crnt_setback_pt_uv[2],
                  IGRpoint			crnt_setback_pt_xyz );

IGRlong EMget_edge_lengths( IGRlong *EMmsg, struct GRmd_env *md_env,
                 GRobjid	ed_id,
                 IGRpoint	pt_xyz,
                 IGRdouble	*param_on_ed,
                 IGRdouble      *ed_lengths );

IGRlong EMrefine_free_setback_point( IGRlong *EMmsg, IGRushort options,
                 struct GRmd_env *md_env,
                 struct EMSedge_rnd_info *ed_info,
                 enum EMSedge_config ed_config,
                 struct EMSedge_blend_info *ed_blend_info,
                 IGRint	setback_pt_location );

IGRlong EMreplace_fillet_geometry( IGRlong *EMmsg, IGRushort options,
                struct GRmd_env *md_env,
                struct EMSedge_rnd_info	*ed_info,
                struct IGRbsp_surface *new_fil_geom );

IGRlong EMdealloc_rnd_blend_curve_info( IGRlong *EMmsg,
             struct EMSrnd_blend_curve_info  *ptr_to_free );

void  EMinit_rnd_blend_curve_info(
          struct EMSrnd_blend_curve_info *list_ptr );

IGRlong EMget_bln_cvs_to_rnd_vtx( IGRlong *EMmsg, IGRushort options,
          struct GRmd_env			*md_env,
          struct EMSedge_rnd_info 		*ed_info,
          struct EMSedge_blend_info		*ed_bln_info,
          IGRboolean				process_FIRST,
          IGRboolean				process_SECOND,
          struct EMSrnd_blend_curve_info	*trans_cvs );

IGRlong EMget_bln_cv_from_fillet_or_edge( IGRlong *EMmsg, IGRushort options,
          struct GRmd_env			*md_env,
          struct EMSedge_rnd_info		*ed_infos[2],
          GRobjid				ed_ids[2],
          struct EMSedge_blend_info		*ed_bln_infos[2],
          struct EMSrnd_blend_curve_info	*trans_cv );

void EMreverse_curve( IGRlong *EMmsg, IGRushort options,
                      struct EMSdataselect *in_data );

void  EMmake_curves_pos_continuous( struct IGRbsp_curve *cv1,
                                    struct IGRbsp_curve *cv2 );


/* -------------------end definitions in EMrndblnsupp.I -------------------- */

#endif
