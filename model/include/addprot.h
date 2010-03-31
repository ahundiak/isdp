#ifndef ADDREMPROT_H
#define ADDREMPROT_H

#include "EMSasnuc.h"
#include "EMSdef.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emsbool.h"
#include "emssfintdef.h"
#include "emsinter.h"
#include "emssfint.h"
#include "REaddrmfea.h"
#include "addrmopts.h"


#include "bsgeom_cvsf.h"

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" 
{
#endif

/*
 * The source for the protypes defined below is available in file :
 *     " $MODEL/src_funk/misc/EMaddclosepr.I "
 */

extern IGRboolean IntersectSplitIntobjs __((
IGRlong			*msg,
IGRdouble		uvtol,
IGRboolean              endsofA_and_Aunmodified,
struct EMSinters 	*intersA,
struct EMSinters	*intersB,
struct GRmd_env		*env,
IGRboolean		*intersected));

extern void AllocateMoreInfo __((
IGRint 			num,
struct IntobjInfo 	***info,
struct IntobjInfo	*copy_info));


extern struct EMSintobj *MapProfileOnPlaneWrapper __((
IGRlong 		*msg,
struct GRmd_env 	*profenv,
struct GRid 		*sfgrid, 
struct IGRbsp_surface 	*sfgeom, 
struct EMSpartolbasis 	*ptolb,
struct GRid 		*the_ploop,
struct GRid 		*profgrid,
IGRdouble 		chtol,
IGRboolean 		convex,
struct EMSinters 	**inters));

extern IGRboolean RemoveInnerLoops __((
struct GRid	*the_ploop, 
GRobjid 	*inner,
IGRint 		*count,
IGRboolean 	*cut));

extern IGRboolean AddInnerLoops __((
struct GRid 	*the_ploop,
GRobjid		*inner,
IGRint 		count));

extern IGRlong FixSelfIntersectingEndObjects __((
IGRlong			*EFmsg,
struct GRid 		*compcv,
struct GRmd_env 	*md_env,
struct GRvg_construct 	*const_list));

extern IGRlong ExtendEndCurves __((
IGRlong                 *msg,
struct IGRbsp_curve     **geoms,
IGRboolean              check_from,
IGRboolean              check_to,
IGRuchar                *types,
IGRint                  num_geoms,
IGRboolean              closure,
IGRdouble               *ext_dist,
IGRdouble               *ext_vec,
GRrange                 range,
struct GRid             *sfid,
struct GRmd_env         *modenvsf,
IGRboolean              *self_intersection,
struct IGRbsp_curve     **added_geom));

extern IGRlong FixSelfIntersectingEndGeoms __((
IGRlong			*msg,
struct IGRbsp_curve 	**geoms,
IGRint 			num_geoms,
IGRboolean 		*self_int));

extern IGRboolean FixOneEnd __((
IGRlong                 *msg,
struct IGRbsp_curve     **cv,
IGRboolean              ZEROEND));

extern IGRboolean ExtendLinearCurve __((
IGRlong                 *msg,
struct GRid             *grid,
struct GRmd_env         *env,
struct IGRbsp_curve     *cv,
IGRboolean              ZEROEND,
IGRdouble               *newpt));

extern IGRboolean ExtractCurve __((
IGRlong                 *msg,
struct GRid             *grid,
struct GRmd_env         *env,
struct IGRbsp_curve     **cv,
IGRdouble               par1,
IGRdouble               par2,
IGRdouble               *phy_closedpt));

extern IGRboolean UnMarkIntobj __((
IGRlong		 *msg,
IGRdouble	 *ends,
struct EMSinters *inters,
IGRboolean       *nomark,
IGRboolean	 *endsONmarked));


extern IGRboolean TwoIntobjsExtend __((
IGRlong	            *msg,
IGRvector	    NORMAL,
struct GRmd_env	    *env_cvs,
struct EMSintobj    **cc_intobjs,
struct GRid	    *sl,
struct GRmd_env	    *envsl,
struct IGRbsp_curve ***comp_cvs,
IGRuchar	    **comp_types,
IGRint		    *num_comps,
IGRboolean	    *extended));

extern IGRboolean GetCurveFromIntobj __((
IGRlong			*msg,
struct EMSintobj	*intobj,
IGRboolean		uv,
IGRboolean		WantReversed,
struct IGRbsp_curve	**curve));
  			    
extern IGRboolean IgnoreConcaveIntobjs __((
IGRlong	            *msg,
IGRvector	    NORMAL,
struct GRmd_env	    *env_cvs,
struct EMSintobj    **cc_intobjs,
IGRint		    numcc_intobjs,
struct GRid	    *sl,
struct GRmd_env	    *envsl,
struct IGRbsp_curve ***comp_cvs,
IGRuchar	    **comp_types,
IGRint		    *num_comps,
IGRboolean	    *extended));

extern IGRboolean IgnoreExtendInfo __((
IGRint			*info_array,
IGRint			num_info,
IGRint			**ext_from,
IGRint			**ext_to,
IGRint			*num_ext,
IGRboolean		*allcvx));

extern IGRboolean TraceIntobjs __((
IGRlong		 *msg,
struct GRmd_env  *env,
struct EMSinters **inters,
struct EMSintobj ***cc_intobjs,
IGRint		 *numcc_intobjs));

extern IGRboolean MatInsideYesNo __((
IGRlong		*msg,
IGRvector	NORMAL,
struct GRid 	*prof_grid,
struct GRmd_env	*env,
IGRboolean  	reversed,
IGRboolean  	*inside));

extern IGRboolean IntersectYesNo __((
IGRlong		    *msg,
IGRvector	    NORMAL,
IGRdouble 	    par, 
struct GRid	    *prof,
struct GRmd_env	    *env,
struct IGRbsp_curve *curve, 
IGRboolean	    reversed,
IGRdouble           *min, 
IGRdouble           *max, 
IGRboolean          *inside));

extern IGRboolean IsProfileUnbounded __((
IGRlong		    *msg,
struct GRid	    *prof_grid,
struct GRmd_env	    *env,
struct IGRbsp_curve **cc,
IGRdouble	    *end_tangents,
IGRboolean          *bounded,
IGRboolean	    *coincide));

extern IGRboolean ProjVecOpposing __((
IGRlong		      *msg,
IGRvector	      proj,
struct IGRbsp_surface *cop_surf,
IGRboolean	      *oppose));

extern IGRboolean MatVecsApproach __((
IGRlong		*msg,
IGRdouble	*cvpts,
IGRdouble	*matvecs,
IGRboolean      *approach));

extern IGRboolean MatVecs __((
IGRlong		      *msg,
IGRvector	      NORMAL,
struct GRid	      *prof,
struct GRmd_env	      *env,
struct IGRbsp_curve   **profcv,
IGRboolean	      reversed,
IGRdouble	      *pars,
IGRint		      num_pars,
IGRdouble	      *matvecs,
IGRdouble             *cvpts));

extern IGRboolean ProcessCoplanar __((
IGRlong			*msg,
IGRvector		NORMAL,
IGRdouble		*ENDS,
struct GRvg_construct   *const_args,
struct GRid     	*prof,
IGRboolean		reversed,
struct GRmd_env 	*envcv,
struct GRid 		*sl,
struct GRmd_env 	*envsl,
struct GRid		*the_plane,
struct IGRbsp_surface 	*plane,
struct EMSpartolbasis   *ptolb,
struct GRid		*the_ploop,
IGRboolean		*self_int,
struct GRid		*newprof,
IGRboolean		*extended));
				      
extern IGRboolean MakeCompFromIntobjs __((
IGRlong			*msg,
struct IGRbsp_curve	**comps,
IGRuchar		*types,
IGRint			num_comps,
struct GRvg_construct   *const_args,
struct GRmd_env		*env,
struct GRid		*comp));

extern IGRboolean CloseProfile __((
IGRlong			*msg,
struct GRid		*prof,
struct GRmd_env 	*env,
struct GRvg_construct 	*const_args,
struct GRid		*new_id,
IGRboolean		*self_int,
IGRboolean		*self_overl,
GRobjid			*closing_id));

extern IGRboolean CheckCoplanarCase __((
IGRlong			*msg,
IGRlong			feaopts,
struct GRid     	*prof,
struct GRmd_env 	*envcv,
struct GRid     	*sl,
struct GRmd_env 	*slenv,
IGRboolean      	*coplanar,
struct GRid		*the_plane,
struct IGRbsp_surface 	**plane,
struct EMSpartolbasis   *ptolb,
struct GRid		*the_ploop));

extern IGRboolean ConvertPolyToCurve __((
IGRlong			*msg,
struct IGRpolyline	*poly,
IGRboolean		twoD,
struct IGRbsp_curve 	**curve));

extern IGRboolean AddRmProcessProfile __((
IGRlong                 *msg,
IGRlong                 matopts,
IGRlong                 solopts,
IGRlong                 feaopts,
IGRboolean              reversed,
struct ProfileInfo      *prof_info,
struct GRid             *sfid,
struct GRmd_env         *envsf,
IGRvector               proj_vec,
IGRdouble               *axis_ends,
struct GRvg_construct   *const_args,
enum EMSbooltype        *bool_type,
IGRint                  *num_extprof,
struct ModProfileInfo   **extprof_info));

extern IGRboolean ProcessProfileForRevolved __((
IGRlong                *msg,
IGRlong                matopts,
IGRlong                feaopts,
struct GRvg_construct  *const_args,
struct ModProfileInfo  *prof_info,
IGRdouble              *axis_ends,
struct ModProfileInfo  *newprof_info ));

extern IGRint GetObjectIndexOnChannel __((
GRobjid   id,
OMuword   os,
GRobjid   fromid,
GRobjid   fromos,
OM_S_CHANSELECT  *to_components ));

extern IGRboolean CloseProfileWithBox __((
IGRlong                *msg,
struct GRvg_construct  *const_args,
struct ProfileInfo   *prof_info,
IGRboolean           reversed,
IGRpoint             *boxpts,
IGRdouble            *slrange,
IGRboolean           *self_int,
struct ModProfileInfo *newprof_info ));

extern IGRboolean ExtendCvToPt __((
struct IGRbsp_curve *cv,
IGRboolean          side,
IGRpoint            pt,
struct IGRbsp_curve **extcv ));

extern IGRboolean ExtendCvToIntersectWithBox __((
IGRlong              *EFmsg,
struct IGRbsp_curve  *cv,
IGRboolean           extside,
IGRdouble            *extvec,
IGRpoint             *boxpts,
IGRboolean           *deextended,
struct SegmentInfo   *seginfo,
struct IGRbsp_curve  **extcv ));

extern IGRboolean ExtendPolyToEncloseRangeBox __((
IGRlong    *EFmsg,
IGRpoint   *polypts,
IGRdouble  *range,
IGRdouble  *normal,
IGRboolean *extended,
IGRpoint   *newpts ));

extern IGRboolean GetSurfaceRtreeRange __((
GRobjid          sfid,
OMuword          sfos,
struct GRmd_env  *sfenv,
IGRdouble        *sfrange ));

extern IGRboolean ExtendAndIntersectBoxWithPlane __((
  IGRpoint  minpt,
  IGRpoint  maxpt,
  IGRpoint  pt,
  IGRvector normal,
  IGRvector projvec,
  IGRint    *numint,
  IGRpoint  *intpts ));

extern void GetCubePts __((
  IGRpoint  minpt,
  IGRpoint  maxpt,
  IGRpoint  cubepts[8] ));

extern IGRint GetObjectNumCompsOnChannel __((
GRobjid          id,
OMuword          os, 
OM_S_CHANSELECT  *to_components ));

extern IGRboolean GetObjectCompsOnChannel __((
GRobjid          id,
OMuword          os,
IGRint           num,
OM_S_CHANSELECT  *to_components,
GRobjid          *comps ));

extern GRobjid GetObjectAtIndexOnChannel __((
GRobjid          id,
OMuword          os,
IGRint           index,
OM_S_CHANSELECT  *to_components ));

extern IGRboolean DisconnectObject __((
GRobjid fromid,
OMuword fromos,
GRobjid compid,
OMuword compos ));

extern IGRboolean ConnectObject __((
GRobjid    id,
OMuword    os,
GRobjid    toid,
OMuword    toos,
IGRlong    index ));

extern IGRboolean PostObjectGeom __((
GRobjid              id,
OMuword              os,
struct GRmd_env      *env,
struct IGRbsp_curve  *newgeom,
GRobjid              *newid ));

extern IGRboolean IntersectBoundedLineWithDirectedVector __((
IGRpoint   bound_lnpt1,
IGRpoint   bound_lnpt2,
IGRpoint   dir_vecpt, // start point of the direction vector
IGRpoint   dir_vec,   // Unit direction vector
IGRpoint   intpt ));

extern OMuword GetObjectClass __((
GRobjid  id,
OMuword  os ));

/*
 * Main functions of Add/Remove Material Feature 
 * The source for the prototypes defined below is available in file :
 *     " $MODEL/src_dpr/funk/EMaddrmfecns.I "
 */
extern IGRlong EMmake_associative_add_rem_matl_feature __((
IGRlong                             *EFmsg,
IGRint                              assoc_type, 
struct GRvg_construct               *cons_list,
IGRint                              num_parents,
IGRuint                             *parent_types,
union  EMSparent_info               *parents,
struct EMSAddRm_RecompInfo          *recomp_info, 
struct GRid                         *feature_id ));

/*
 * The source for the prototypes defined below is available in file :
 *     " $MODEL/src_place/funk/EMfeacreat.I "
 */

extern IGRlong EMcreate_add_rem_mat_feature __((
IGRlong                             *msg,
IGRlong                             matopts,
IGRlong                             solopts,
IGRlong                             feaopts,
struct GRid                         *profid,
struct GRmd_env                     *modenvcv,
IGRboolean                          reversed,
struct GRid                         *from_surf_id,
struct GRid                         *to_surf_id,
struct GRmd_env                     *modenvsf,
struct GRid                         *base_solid_id,
IGRdouble                           *start_dist,
IGRdouble                           *proj_dist,
IGRdouble                           *projection_vec,
IGRdouble                           *start_angle,
IGRdouble                           *sweep_angle,
IGRdouble                           *axis_ends,
struct TraceInfo                    *trace_info,
struct GRvg_construct               *const_args,
struct GRid                         feature_object ));

/*
 * The source for the prototypes defined below is available in file :
 *     " $MODEL/src_surf/funk/EMfeasecsf.I "
 */
extern IGRlong EMcreate_secondary_solid __((
IGRlong                *msg,
IGRlong                solopts,
IGRlong                feaopts,
struct GRvg_construct  *const_args,
struct ProfileInfo     *prof_info,
struct ModProfileInfo  *modprof_info,
struct GRid            *from_surf_GRid,
struct GRid            *to_surf_GRid,
struct GRmd_env        *modenvsf,
IGRdouble              *proj_vec,
IGRdouble              *proj_dist,
IGRdouble              *sweep_angle,
IGRdouble              *axis_ends,
struct TraceInfo       *trace_info,
struct GRid            *base_solid,
IGRint                 *num_coinc_sfs,
struct GRid            ***coinc_sfs_grid,
struct SecSolidInfo    *secsl_info ));

extern IGRlong EMget_projection_start_stop_pt __((
IGRlong                *msg,
IGRlong                feaopts,
struct ProfileInfo     *prof_info,
IGRdouble              *proj_vec,
IGRdouble              *proj_dist,
struct GRid            *from_surf_id,
struct GRid            *to_surf_id,
struct GRmd_env        *modenvsf,
struct GRid            *base_solid,
struct GRid            *new_prof_id,
struct FromToSurfInfo  *surf_info ));

extern IGRlong  EMcap_surface_of_revolution __((
IGRlong                *EFmsg,
struct GRvg_construct  *conslist, 
struct GRid            *sfgrid,
struct GRid            *profgrid,
IGRdouble              *axis, 
IGRdouble              startangle,
IGRdouble              sweepangle,
struct GRid            *slgrid ));

extern IGRlong EMget_revolution_svsdpt __((
IGRlong               *EFmsg,
struct GRvg_construct *cons_list,
struct ProfileInfo    *prof_info,
IGRdouble             *axis_ends,
struct GRid           *from_surf_grid,
struct GRid           *to_surf_grid,
struct FromToSurfInfo *surf_info ));

extern IGRlong EFrotate_plane __((
IGRdouble             *point,
IGRdouble             *normal,
IGRdouble             *axis_vec,
IGRdouble             *origin,
IGRdouble             angle, 
IGRdouble             *new_point,
IGRdouble             *new_normal ));

extern IGRboolean  EFare_planes_same __((
IGRdouble   *point1,
IGRdouble   *normal1,
IGRdouble   *point2,
IGRdouble   *normal2 ));

extern IGRlong EFpoint_on_circle_at_angle __((
IGRdouble *center,
IGRdouble *normal,
IGRdouble *stpoint,
IGRdouble angle,
IGRdouble *point ));

extern IGRlong EFget_revsurf_range_box_from_profile __((
struct IGRplane *prof_plane,
IGRdouble       *prof_range,
IGRdouble       *axis_ends,
IGRdouble       *slrange ));

extern IGRboolean  GetSecondarySolidInfo __((
IGRlong               *EFmsg,
IGRlong               options,
IGRlong               solopts,
struct ModProfileInfo *prof_info,
struct GRid           *sec_slgrid,
struct GRmd_env       *slenv,
struct SkinSurfInfo   *skin_info,
struct SecSolidInfo   *sec_slinfo ));

/*
 * The source for the prototypes defined below is available in file :
 *     " $MODEL/src_surf/funk/EFplskinsrf.I "
 */
extern IGRlong EFPlaceSkinSurface __((
IGRlong               *EFmsg,
IGRlong               options, 
struct GRvg_construct *cons_list,
IGRint                nsec_cvs,
struct GRlc_info      *sec_cvs,
IGRint                ntrc_cvs,
struct GRlc_info      *trc_cvs,
struct GRid           *skin_grid,
struct SkinSurfInfo   *skin_info ));

extern IGRlong EFPlaceSkinSolid __((
IGRlong               *EFmsg,
IGRlong               options,  
struct GRvg_construct *cons_list,
IGRint                nsec_cvs,
struct GRlc_info      *sec_cvs,
IGRint                ntrc_cvs,
struct GRlc_info      *trc_cvs,
struct GRid           *skin_grid,
struct SkinSurfInfo   *skin_info ));

/*
 * The source for the prototypes defined below is available in file :
 *     " $MODEL/src_dpr/funk/EFaddrmbool.I "
 */

extern  void EFperform_addrm_boolean __((
IGRlong                 *EFmsg,
IGRushort               options,
struct GRvg_construct   *const_list,
struct GRmd_env         *md_env,
IGRlong                 feature_type,
IGRlong                 sec_solid_type, 
IGRlong                 sec_solid_extent,
enum   EMSbooltype      bool_type,
struct GRid             *base_solid_grid, 
struct SecSolidInfo     *sec_slinfo,
IGRint                  num_coinc_sfs,
struct GRid             *coinc_sfs_grid[2],
struct GRid             arg_bool_GRid ));

/*
 * The source for the prototypes defined below is available in file :
 *     " $MODEL/src_dpr/funk/EFaddrmsupp.I "
 */

extern IGRlong  EFkeep_right_trace_groups __((
IGRlong                   *EFmsg,
IGRushort                 options,
struct GRvg_construct     *cons_list,
struct GRmd_env           *md_env,
IGRlong                   feature_type,
IGRlong                   solid_type,
IGRlong                   solid_extent,
struct GRid               *base_slgrid, 
struct SecSolidInfo       *sec_slinfo,
struct EMSinters          **base_inters, 
struct EMSinters          **sec_inters,
struct EMSsftracedata     *base_trace, 
struct EMSsftracedata     *sec_trace ));

extern void     EFfind_group_numbers_from_sfid __((
IGRlong                 *EFmsg,
struct GRid             *sfgrid,
struct EMSsftracedata   *this_tracedata, 
struct EMSsftracedata   *other_tracedata,
IGRint                  *this_num_grps, 
IGRint                  **this_grp_numbers,
IGRint                  *other_num_grps, 
IGRint                  **other_grp_numbers ));

extern void    EFget_trace_group_from_intobj __((
IGRlong                 *EFmsg,
struct EMSintobj        *intobj,
struct EMSsftracedata   *tracedata,
IGRint                  *group_number ));

extern void  EFdel_keep_trace_groups __((
IGRlong                *EFmsg,
IGRboolean             delete, 
IGRboolean             *grp_del_flags,
struct EMSinters       **inters,
struct EMSsftracedata  *trace ));

extern IGRboolean   EFis_sf_in_inters __((
struct GRid       *sfgrid,
struct EMSinters  **inters, 
struct EMSinters  **sf_inters ));

extern IGRlong  EFget_component_endpts __((
IGRlong          *EFmsg,
struct GRmd_env  *md_env,
struct GRid      *composite_grid, 
IGRint           component_no,
struct GRid      *component_grid,
IGRpoint         *end_pts ));

extern IGRlong  EFget_sort_pts __((
IGRlong          *EFmsg,
struct GRmd_env  *md_env,
IGRint           num_sfs,
struct GRid      *sfs_grid,
IGRpoint         *xyz_pts,
struct EMparms   **sort_pts )); 

extern IGRlong   EFget_channel_objects __((
IGRlong          *EFmsg,
struct GRid      *obj_grid,
OM_S_CHANSELECT  *chan,
IGRint           from_index, 
IGRint           to_index,
struct GRid      **chan_objs_grid ));

extern IGRlong  EFsort_intobjs_by_projecting_along_vector_onto_plane __((
IGRlong             *EFmsg,
struct EMSinters    *inters,
IGRvector           vector,
struct IGRplane     *plane,
IGRint              **sort_index ));

extern void   EFgetmidpt_xyz __((
IGRlong              *EFmsg,
struct GRmd_env      *md_env,
struct EMSdataselect *intdata,
IGRdouble            *mid_pt ));

extern IGRlong   EFget_tocomp_channel_components __((
IGRlong          *EFmsg,
struct GRmd_env  *md_env,
struct GRid      *obj_grid, 
IGRint           *ncomps, 
struct GRid      **comps_grid ));

extern IGRlong   EFget_unmodified_profile_surface_ids __((
IGRlong               *EFmsg,
IGRlong               solid_type,
struct GRmd_env       *md_env,
struct GRid           *prof_grid, 
struct GRid           *modprof_grid, 
struct GRid           *compsf_grid, 
struct GRid           *sfs_grid,
IGRdouble             *end_parms ));

extern IGRlong  EFget_right_trace_groups_to_thru_next __((
IGRlong                   *EFmsg,
IGRushort                 options,
struct GRvg_construct     *cons_list,
struct GRmd_env           *md_env,
IGRlong                   feature_type,
IGRlong                   solid_type,
struct GRid               *base_slgrid,
struct SecSolidInfo       *sec_slinfo,
struct EMSinters          **base_inters, 
struct EMSinters          **sec_inters,
struct EMSsftracedata     *base_trace, 
struct EMSsftracedata     *sec_trace,
IGRushort                 *trace_options,
IGRlong                   *check_present,
IGRboolean                **sec_trace_grp_keep, 
IGRboolean                **base_trace_grp_keep ));

extern IGRboolean  EFis_sf_in_trace_group __((
struct GRid             *sfgrid,
IGRint                  group_num,
struct EMSsftracedata  *tracedata ));

extern IGRlong  EFget_groups_from_options __((
IGRlong                *EFmsg,
IGRushort              options,
struct GRid            *sfgrid,
IGRdouble              *end_parms,
struct EMSinters       **sec_inters, 
struct EMSsftracedata  *sec_trace, 
struct EMSinters       **base_inters,
struct EMSsftracedata  *base_trace,
IGRint                 *ngrps,
IGRint                 **sec_grps, 
IGRint                 **base_grps ));

extern IGRlong  EFget_right_trace_groups_from_to_finite __((
IGRlong                   *EFmsg,
IGRushort                 options,
struct GRvg_construct     *cons_list,
struct GRmd_env           *md_env,
IGRlong                   feature_type,
IGRlong                   solid_type,
IGRlong                   solid_extent,
struct GRid               *base_slgrid,
struct SecSolidInfo       *sec_slinfo,
struct EMSinters          **base_inters,
struct EMSinters          **sec_inters,
struct EMSsftracedata     *base_trace,
struct EMSsftracedata     *sec_trace,
IGRushort                 *trace_options,
IGRlong                   *check_present,
IGRboolean                **sec_trace_grp_keep,
IGRboolean                **base_trace_grp_keep ));

extern struct EMSintobj * Intobj_with_minV __((
IGRlong           *EFmsg,
struct EMSinters  *inters ));

extern void  EFget_surface_group_range __((
IGRlong                *EFmsg,
struct GRid            *sfgrid,
struct EMSsftracedata  *tracedata,
IGRint                 grp_num,
IGRdouble              *uvrange ));


/*
 * The source for the prototypes defined below is available in file :
 *     " $MODEL/src_dpr/funk/EFaddrmblsup.I "
 */

extern IGRlong EFaddrm_modify_trace_groups __((
IGRlong                 *EFmsg,
IGRushort               options,
struct GRvg_construct   *cons_list,
struct GRmd_env         *md_env,
struct EMSinters        **inters1, 
struct EMSinters        **inters2,
struct EMSsftracedata   *tracedata1, 
struct EMSsftracedata   *tracedata2,
IGRint                  *num_sort_pts, 
struct EMparms          *sort_pts, 
IGRint                  *num_bad_pts,
struct EMparms          **bad_pts,
IGRlong                 check_present,
IGRboolean              *keep_grps1, 
IGRboolean              *keep_grps2 ));

/*
 * The source for the prototype(s) defined below is available in file :
 *     " $MODEL/src_funk/misc/EMgetmapint.I "
 */

extern IGRlong EMgetmapped_inters  __((
IGRlong               *msg,
struct GRmd_env       *md_env,
struct GRid           *sfid_a, 
IGRushort             options_a, 
struct GRid           *sfid_b, 
IGRushort             options_b,
struct EMSinters      **inters_a, 
struct EMSinters      **inters_b ));

extern IGRlong  EFmap_the_edge  __((
IGRlong                   *msg,
IGRushort                 opt,
struct GRmd_env           *md_env,
struct GRid               edge_grid,
struct GRid               *sfid, 
struct GRid               *othersfid,
IGRboolean                *is_mapped,
struct EMSinters          **this_inters, 
struct EMSinters          **other_inters ));

/*
 * The source for the prototype(s) defined below is available in file :
 *     " $MODEL/src_dpr/funk/EFmgcoinc.I "
 */

extern IGRlong  EFmerge_coinc_inters __((
IGRlong          *EFmsg,
struct GRmd_env  *md_env,
enum EMSbooltype bool_type,
struct EMSinters **inters_a, 
struct EMSinters **inters_b,
IGRint           num_coinc_sfs,
struct GRid      *coinc_sf_grids[2] ));

/*
 * The source for the prototype(s) defined below is available in file :
 *     " $MODEL/src_funk/misc/EFintsfsolid.I "
 */

extern IGRlong EFplsolid_by_trimming_with_surfaces __((
IGRlong                *EFmsg,
IGRushort              options,
struct GRvg_construct  *cons_list,
IGRint                 num_sfs,
IGRushort              *sfs_opts,
struct GRid            *sfs_grid,
IGRboolean             *ext_sfs,
IGRdouble              *svside_pts,
struct GRid            *sl_grid,
struct GRmd_env        *sl_env,
struct GRid            **int_sfs_grid,
IGRint                 *num_sfs_failed,
struct GRid            **failed_sfs_grid,
struct GRid            *new_solid_grid ));

extern IGRint   EFchkext_required __(( 
GRrange         sfrange, 
GRrange         slrange, 
IGRdouble       tol ));

extern IGRlong  EFfind_extension_directions __((
IGRlong                *EFmsg,
struct GRid            *surface,
struct GRmd_env        *surface_mdenv,
struct IGRbsp_surface  *surface_geom, 
struct GRid            *solid,
IGRdouble              *solid_range,
IGRint                 check_ndir,
IGRint                 *check_dir,
IGRint                 *ndir,
IGRint                 **ext_dir,
IGRdouble              **ext_dist ));

extern IGRlong  EFintsolid_surface_svsd __(( 
IGRlong               *EFmsg,
IGRushort             options,
struct GRid           *sfgrid, 
struct GRmd_env       *sfenv,
struct GRid           *slgrid, 
struct GRvg_construct *cons_list,
IGRpoint              svsd_pt,
struct GRid           *new_slgrid ));

extern IGRdouble EFext_dist __(( 
IGRdouble    *slrange,
IGRdouble    *cvrange,
IGRdouble    *dir ));

extern IGRlong  EFextend_gensurface_in_uvdirections __((
IGRlong                *EFmsg,
IGRushort              options,
struct IGRbsp_surface  *sfgeom,
IGRint                 ndir,
IGRint                 *ext_dir,
IGRdouble              *ext_dst,
struct IGRbsp_surface  **newsfgeom ));

extern IGRlong   EFcreate_full_cylinder __((
IGRlong                  *EFmsg,
IGRushort                options,
struct BSgeom_bsp_surf   *gmsf,
IGRdouble                *slrange,
struct IGRbsp_surface    **newsfgeom ));

extern IGRlong   EFcreate_full_cone __((
IGRlong                  *EFmsg,
IGRushort                options,
struct BSgeom_bsp_surf   *gmsf,
IGRdouble                *slrange,
struct IGRbsp_surface    **newsfgeom ));

extern IGRlong   EFcreate_full_sphere __((
IGRlong                  *EFmsg,
IGRushort                options,
struct BSgeom_bsp_surf   *gmsf,
IGRdouble                *slrange,
struct IGRbsp_surface    **newsfgeom ));

extern IGRlong   EFcreate_full_torus __((
IGRlong                  *EFmsg,
IGRushort                options,
struct BSgeom_bsp_surf   *gmsf,
IGRdouble                *slrange,
struct IGRbsp_surface    **newsfgeom ));

extern IGRlong   EFcreate_full_sfproj __((
IGRlong                  *EFmsg,
IGRushort                options,
struct BSgeom_bsp_surf   *gmsf,
IGRint                   ndir,
IGRint                   *ext_dir,
IGRdouble                *slrange,
struct IGRbsp_surface    **newsfgeom ));

extern IGRlong   EFcreate_full_sfrevol __((
IGRlong                  *EFmsg,
IGRushort                options,
struct BSgeom_bsp_surf   *gmsf,
IGRint                   ndir,
IGRint                   *ext_dir,
IGRdouble                *slrange,
struct IGRbsp_surface    **newsfgeom ));

extern IGRlong   EFcreate_full_gensf __((
IGRlong                  *EFmsg,
IGRushort                options,
struct BSgeom_bsp_surf   *gmsf,
IGRint                   ndir,
IGRint                   *ext_dir,
IGRdouble                *slrange,
struct IGRbsp_surface    **newsfgeom ));

extern IGRlong  EFextend_surface_from_rangebox_limits __((
IGRlong                  *EFmsg,
IGRushort                options,
struct IGRbsp_surface    *sfgeom,
IGRint                   ndir,
IGRint                   *ext_dir,
IGRdouble                *slrange,
OMuword                  *sfclass,
struct IGRbsp_surface    **newsfgeom ));

extern IGRlong    EFextend_surface __((
IGRlong                 *EFmsg,
IGRushort               options,
struct GRvg_construct   *cons_list,
IGRint                  ndir,
IGRint                  *ext_dir,
struct GRid             *slgrid,
IGRdouble               *slrange,
struct GRid             *sfgrid,
struct IGRbsp_surface   *sfgeom,
struct IGRbsp_surface   **newsfgeom ));

extern IGRlong  EFget_group_range __((
IGRlong                *EFmsg,
IGRushort              options,
IGRint                 grp_num,
struct EMSsftracedata  *sftrace,
IGRdouble              *range,
IGRdouble              *intpar ));

extern IGRlong EFcreate_exact_surface __((
IGRlong                 *EFmsg,
struct GRvg_construct   *cons_list,
OMuword                 classid,
struct IGRbsp_surface   *sfgeom,
struct GRid             *sfgrid ));

extern void EFget_bounded_plane_from_rangebox __((
IGRlong                 *EFmsg,
IGRdouble               *range,
struct IGRplane         *plane,
struct IGRbsp_surface   *BSplane ));

extern void EFget_closed_group_range __((
IGRlong      *EFmsg,
IGRint       npts,
IGRdouble    *pts,
IGRushort    options,
IGRdouble    *range,
IGRdouble    *intpar ));

/*
 * The source for the prototype(s) defined below is available in file :
 *     " $MODEL/src_funk/misc/OMsupport.I "
 */
extern IGRboolean CopyObject __((
GRobjid         id,
OMuword         os,
struct GRmd_env *env,
GRobjid         *copyid ));

extern IGRboolean XformObject __((
GRobjid         id,
OMuword         os,
struct GRmd_env *env,
IGRshort        *matrix_type,
IGRdouble       *matrix,
GRobjid         *xformid ));

extern IGRboolean GetObjectGeomProps  __((
GRobjid         id,
OMuword         os,
struct GRmd_env *env,
struct GRprops  *props ));

extern IGRboolean GetObjectRange __((
GRobjid         id,
OMuword         os,
struct GRmd_env *env,
IGRdouble       *range ));

extern IGRboolean GetCvOrSfPlane __((
GRobjid         id,
OMuword         os,
struct GRmd_env *env,
struct IGRplane *plane ));

extern IGRboolean DeleteObject __((
GRobjid 	*obj,
struct GRmd_env *env));

#if defined(__cplusplus)
}
#endif

#endif




