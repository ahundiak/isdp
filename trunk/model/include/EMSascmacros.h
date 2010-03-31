/***************************************************************************
  
  Description :

  Macros for associativity functions in EMS.

  Creation :

  Vadiraj M.R. - eons ago.
***************************************************************************/
#ifndef EMSassoc_func_macros
#define EMSassoc_func_macros

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) ()
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif
# ifndef igr_include
# include "igr.h"
# endif
# ifndef igrdp_include
# include "igrdp.h"
# endif
#ifndef igetypedef_include
#include "igetypedef.h"
# endif
#ifndef gr_include
#include "gr.h"
# endif
#ifndef go_include
#include "go.h"
# endif
#ifndef griodef_include
#include "griodef.h"
# endif
#ifndef grio_include
#include "grio.h"
# endif
#ifndef godef_include
#include "godef.h"
# endif
#ifndef OM_D_MINIMUM
#include "OMminimum.h"
# endif

extern IGRint EFplace_blend_surface_exterior __((IGRlong *EMmsg,
                                          unsigned int options,
                                          struct GRlc_info *surf1,
                                          IGRint side_1, 
                                          IGRboolean is_side_1_reversed,
                                          IGRpoint blend_direction_1,
                                          struct GRlc_info *surf2,
                                          IGRint side_2,
                                          IGRboolean is_side_2_reversed,
                                          IGRpoint blend_direction_2,
                                          struct GRvg_construct *construct_list,
                                          OM_S_OBJID *constructed_object));
extern IGRlong EFassociative_intersect_elements __((IGRlong *EMmsg,
                                             unsigned int options,
                                             IGRboolean trimming_required,
                                             struct GRlc_info *elem1_info,
                                             struct GRlc_info *elem2_info,
                                          struct GRvg_construct *construct_list,
                                          OM_S_OBJID *res_id)); 
extern IGRlong EFiso_parametric_curves __((IGRlong *EMmsg,
                                    unsigned int options,
                                    IGRboolean trimming_required,
                                    IGRboolean use_u_curve,
                                    struct GRlc_info *surf_info,
                                    IGRint num_param,
                                    IGRdouble start_param,
                                    IGRdouble end_param,
                                    struct GRvg_construct *construct_list,
                                    OM_S_OBJID *res_id));     
extern IGRlong EFplace_counterpart __((IGRlong *EMmsg,
                                IGRushort init_opts,
                                struct GRvg_construct *construct_list,
                                IGRint type,
                                IGRboolean axis_nor,
                                IGRboolean thru_hole,
                                struct GRevent *cen_pt_eve,
                                struct GRevent *bot_ang_eve,
                                struct GRlc_info *surf_info,
                                IGRlong num_parts,
                                struct part_data *part_info,
                                struct GRevent *coun_dep_eve,
                                struct GRevent *coun_dia_eve,
                                struct GRevent *hole_dia_eve,
                                struct GRevent *hole_dep_eve,
                                struct GRid *cons_id,
                                IGRushort gen_opts));   
extern IGRlong EFplace_slot __((IGRlong *EMmsg, IGRushort init_opts,
                         IGRboolean is_dir_rev, IGRboolean is_pro_nor_rev,
                         IGRushort *depth_type, struct GRevent *depth,
                         struct GRlc_info *surf_info, 
                         struct GRvg_construct *construct_list,
                         struct GRid *cons_id, IGRushort gen_opts)); 
extern IGRlong EFgen_make_lift_face __((IGRint part_type, struct GRmd_env *md_env,
                                 struct GRid *datum_surface,
                                 IGRlong number_of_curves,
                                 struct GRlc_info curves[],
                                 struct GRevent lift_distances[],
                                 IGRboolean drafted,
                                 struct GRevent *draft_angle,
                                 IGRushort options,
                                 struct GRvg_construct *construct_list,
                                 struct GRid *top_state_before,
                                 GRobjid my_stupid_id,
                                 struct GRid *top_state_after,
                                 struct GRid *last_lift,
                                 IGRint *num_grps,
                                 IGRlong *msg));
/******************************************************************************
IGRlong EFplace_thread __((IGRlong *EMmsg, IGRushort init_opts,
                           struct GRevent *thr_len,
                           struct GRevent *thr_dia,
                           struct GRevent *thr_per_inch,
                           IGRchar thr_txt_suff[],
                           IGRboolean is_vec_rev,
                           struct GRlc_info *surf_info,
                           struct GRvg_construct *construct_list,
                           struct GRid *cons_id,
                           IGRushort gen_opts));  
******************************************************************************/
extern IGRint EFblend_3_or_more_curves __((IGRlong *EMmsg, IGRuint options,
                                    IGRint number_of_curves,
                                    struct GRlc_info *cvinfo[],
                                    struct GRlc_info *sfinfo[],
                                    struct EMSvalue_info *dist_par,
                                    IGRpoint center_point,
                                    IGRvector normal_vector,
                                    struct GRvg_construct *construct_list,
                                    OM_S_OBJID *constructed_object));   
extern IGRlong EMplace_drafted_surface __((IGRlong *msg, IGRushort opts,
                                    struct GRmd_env *mdenv, IGRshort level,
                                    struct IGRdisplay *disp, 
                                    IGRchar *dispattr, IGRchar *objname,
                                    struct EMSobject_info *curve,
                                    struct EMSpoint_info *vector,
                                    struct EMSvalue_info *angles,
                                    IGRint *codes,
                                    IGRint num_sides,
                                    IGRboolean is_uniform,
                                    IGRboolean is_fillet,
                                    IGRboolean is_right_side,
                                    IGRboolean is_solid,
                                    GRobjid *drfobj));  
extern IGRlong EMplace_fillet __((IGRlong *msg, IGRushort opts,
                           struct GRmd_env *mdenv, IGRshort level,
                           struct IGRdisplay *disp, IGRchar *dispattr,
                           IGRchar *objname, struct EMSobject_info *surface1,
                           IGRboolean natural_normal1,
                           struct EMSobject_info *surface2,
                           IGRboolean natural_normal2,
                           struct EMSpoint_info *start_point,
                           struct EMSpoint_info *start_radius,
                           struct EMSpoint_info *end_point,
                           struct EMSpoint_info *end_radius,
                           IGRchar *variation_curve,
                           IGRdouble rho_value,
                           IGRboolean is_chamfer,
                           GRobjid *filobj,
                           IGRint ext_ind, IGRint cnv_ind, IGRint cnc_ind)); 
extern IGRlong EMplace_partial_surface __((IGRlong *msg, IGRushort opts,
                                    struct GRmd_env *mdenv, IGRshort level,
                                    struct IGRdisplay *disp, IGRchar *dispattr,
                                    IGRchar *objname,
                                    struct EMSobject_info *surface,
                                    struct EMSpoint_info *start_point,
                                    struct EMSpoint_info *end_point,
                                    struct EMSpoint_info *mid_point,
                                    IGRboolean trimming_required,
                                    GRobjid *prtobj)); 
extern IGRint EFplace_ruled_surface __((IGRlong *EMmsg, IGRuint options,
                                struct GRlc_info *cv1info,
                                struct GRlc_info *cv2info,
                                IGRlong ruled_surface_type,
                                IGRint num_cp, IGRdouble *curve1_cp,
                                IGRdouble *curve2_cp,
                                struct GRvg_construct *construct_list,
                                OM_S_OBJID *constr_obj));
extern IGRlong EMplace_surface_to_plane_solid_of_proj __((IGRlong *msg,
                                IGRushort opts, struct GRmd_env *mdenv,
                                IGRshort level, struct IGRdisplay *disp,
                                IGRchar *dispattr, IGRchar *objname,
                                struct EMSobject_info *surface,
                                struct EMSvector_info *projection_vector,
                                struct EMSplane_info *plane,
                                GRobjid *solobj));  
extern IGRlong EMplace_surf_of_projection __((IGRlong *msg,
                                       IGRushort opts,
                                       struct GRmd_env *mdenv,
                                       IGRshort level, struct IGRdisplay *disp,
                                       IGRchar *dispattr, IGRchar *objname,
                                       struct EMSobject_info *curve,
                                       struct EMSpoint_info *base,
                                       struct EMSpoint_info *height,
                                       IGRboolean is_solid,
                                       GRobjid *prjobj)); 
extern IGRlong EMplace_surf_of_revolution __((IGRlong *msg, IGRushort opts,
                                       struct GRmd_env *mdenv,
                                       IGRshort level, struct IGRdisplay *disp,
                                       IGRchar *dispattr, IGRchar *objname,
                                       struct EMSobject_info *curve,
                                       struct EMSpoint_info *axis,
                                       struct EMSvalue_info *start,
                                       struct EMSvalue_info *sweep,
                                       IGRboolean is_solid,
                                       GRobjid *revobj));    
extern IGRlong EMplace_tube __((IGRlong *msg, IGRushort opts,
                         struct GRmd_env *mdenv, IGRshort level,
                         struct IGRdisplay *disp, IGRchar *dispattr,
                         IGRchar *objname, struct EMSobject_info *curve,
                         struct EMSvalue_info *radius,
                         IGRint num_bend_radii,
                         struct EMSvalue_info *bend_radii,
                         IGRboolean is_solid,
                         GRobjid *tbeobj));
/*****************************************************************************
IGRlong EMround_chamfer_edges __((IGRlong *msg, IGRushort opts,
                                  struct GRmd_env *mdenv,
                                  IGRushort op_type,
                                  IGRint num_edges,
                                  GRobjid *edges,
                                  struct EMSvalue_info *radii,
                                  struct GRid *res_id));  
*****************************************************************************/
extern IGRlong EFboolean __((IGRlong *msg, IGRushort options,
                      IGRint num_opnds, GRobjid *opnd_info,
                      enum EMSbooltype bool_type, 
                      struct GRvg_construct *construct_list,
                      struct GRid *res_id));  
extern IGRlong EFimpose_boundaries __((IGRlong *msg, IGRushort options,
                                struct GRlc_info *surface,
                                IGRint nboundaries,
                                struct GRlc_info *boundaries,
                                IGRdouble *point,
                                IGRboolean point_in_area,
                                IGRint reverse,
                                IGRdouble veclen,
                                struct GRvg_construct *construct,
                                IGRlong *npoints,
                                IGRpoint **points,
                                IGRlong *nbadcurves,
                                IGRlong *badcurves,
                                struct GRid *result));  
extern IGRlong EFlift_face __((IGRlong *EMmsg, IGRushort init_options,
                        struct GRlc_info *sf_info, 
                        struct EMSvector_info *vect,
                        struct EMSvalue_info  *mag,
                        IGRboolean lift_with_pos_orient,
                        struct GRvg_construct *construct_list,
                        struct GRid *res_id,
                        IGRushort general_options));
extern IGRlong EFplace_merged_curve __((IGRlong *EMmsg, unsigned int options,
                                 unsigned int num_curves,
                                 struct GRlc_info *cvinfo,
                                 struct GRvg_construct *construct_list,
                                 OM_S_OBJID *res_id));
extern IGRlong EFplace_mirror_copy __((IGRlong *EMmsg, unsigned int options,
                                struct GRlc_info *copyee_info,
                                struct GRlc_info *refpln_info,
                                struct GRvg_construct *construct_list,
                                OM_S_OBJID *res_id));   
extern IGRlong EFmake_comp_surf __((IGRlong *msg, IGRushort options,
                             IGRint nsurfaces, OM_S_OBJID *surfaces,
                             struct GRvg_construct *construct,
                             struct GRid *compsurf));  
extern IGRlong EFmake_face __((IGRlong *EMmsg, IGRushort init_options,
                        IGRint num_curves, struct GRlc_info *cv_info,
                        struct GRlc_info *face_info,
                        struct GRvg_construct *construct_list,
                        struct GRid *res_id,
                        IGRushort general_options));                            
extern IGRlong EFremove_boundaries __((IGRlong *EMmsg,
                                struct GRvg_construct construct_list,
                                struct GRid  active_GRid,
                                IGRint num_loops,
                                struct GRid *loops,
                                struct GRid *result));
extern IGRlong EFmerge_coincident_surfaces __((IGRlong *EMmsg,
                                        struct GRvg_construct construct_list,
                                        struct GRid  active_GRid,
                                        IGRint num_surfs,
                                        struct GRid *surfs,
                                        struct GRid *result));

extern IGRlong EFextract_part_of_curve __((IGRlong *EMmsg,
                IGRuint options,
                struct EMSpoint_info *begin_pt,
                struct EMSpoint_info *end_pt,
                struct EMSpoint_info *middle_pt,
                struct GRvg_construct *construct_list,
                GRobjid *result));

extern IGRlong EFconstruct_key_points __((IGRlong *EMmsg, IGRuint options,
                   IGRpoint snap_point, struct GRlc_info *cv_info,
                   struct GRvg_construct *construct_list, GRobjid *res_id));

#if defined(__cplusplus)
}
#endif

#undef __

/*****************************************************************************

       Description :

       This macro constructs a surface which blends 2 existing surfaces
 along interior curves lying on the surfaces. The constructed object
 is returned in *constructed_object field.

       ARGUMENTS :

       IGRlong *EMmsg                -     Output:
                                           Message return code.
                                           - EMS_S_Success,
                                             if succeeded
                                           - EMS_E_Fail,
                                             in case of a failure.
                                           - EMS_E_BSerror,
                                             in case a math routine
                                             fails.
       struct GRlc_info *surfrace1   -     Input :
                                           Locate information for surface 1.
       IGRint side_1                 -     Input :
                                           A number representing which side
                                           of the surface 1 is to be blended.
                                           The symbolic names are BSULEFTBND,
                                           BSVLEFTBND, BSURIGHTBND,BSVRIGHTBND
                                           as defined in the math include file
                                           "bsconic.h". 
       IGRboolean is_side1_reversed  -     Input :
                                           Is side1 reversed?
                                           This is used in order to prevent
                                           twisting of the blending surface.
                                           Input :
       IGRpoint blend_direction_1    -     A point which determines in which
                                           direction the blend will proceed
                                           in as it leaves surface_1. 
                                           Basically it either moves with the 
                                           natural tangent direction or
                                           opposite.
       struct GRlc_info *surface2    -     Input :
                                           Locate information for surface 2.
       IGRint side2                  -     Input :
                                           A number representing which side of
                                           the surface 2 is to be blended.
                                           BSULEFTBND, BSVLEFTBND, BSURIGHTBND,
                                           BSVRIGHTBND as defined in the math
                                           include file "bsconic.h"  
       IGRbooolean is_side2_reversed -     Input :
                                           Is side_2 reversed?
                                           This is used in order to prevent
                                           twisting of the blending surface.
       IGRpoint blend_direction_2    -     Input :
                                           A point which determines in which
                                           direction the blend will proceed in
                                           as it leaves surface_2. Basically
                                           it either moves with the natural
                                           tangent direction or opposite.
       unsigned int options          -     Input :
                                           Currently can be set to
                                           EMSasconst_notassociative if a   
                                           non-associative blend surface
                                           is needed.
       struct GRvg_construct *construction_list 
                                     -     Input :
                                           Standard construction list for the
                                           object to be constructed.
       OM_S_OBJID *constructed_object
                                     -     Output:
                                           The constructed object.   
*****************************************************************************/
#omdef ems$pl_blnd_sf_ext(msg,
                          surface1,
                          side1,
                          is_side1_reversed = FALSE,
                          blend_direction_1,
                          surface2,
                          side2,
                          is_side2_reversed = FALSE,
                          blend_direction_2,
                          options = NULL,
                          construction_list,
                          constructed_object)
EFplace_blend_surface_exterior((msg), (options), (surface1), (side1), 
                               (is_side1_reversed),   
                               (blend_direction_1), (surface2), (side2), 
                               (is_side2_reversed), (blend_direction_2),
                               (construction_list), (constructed_object))
#endomdef  

/****************************************************************************

        Description :

        This macro constructs, based on the options, an associative or
        non-associative group of intersection objects between two elements.

        ARGUMENTS :

        IGRlong *EMmsg                  - Output:
                                          Message return code.
                                          -EMS_S_Success,
                                           if all ends well.
                                          -EMS_I_Interrupt,
                                           due to user interruption.
                                          -EMS_I_NoSolution,
                                           if the two elements do
                                           not intersect at all.
                                          -EMS_E_Fail,
                                           in case of a severe
                                           failure.
                                          -EMS_E_OMerror,
                                           in case a call to an
                                           OM macro fails.  
         struct GRlc_info *elem1_info   - Input :
                                          Locate information for the
                                          First element.
         struct GRlc_info *elem2_info   - Input :
                                          Locate information for the
                                          Second element.
         IGRboolean trimming_required   - Input :
                                          A Flag indicating whether
                                          trimming of intersections
                                          is required or not.
         unsigned int options           - Input :
                                          Options specifying whether
                                          associative or non-associative
                                          group of intersections to be
                                          constructed.
                                          Refer to the include file
                                          EMSasopts.h for associativity
                                          options.  
         struct GRvg_construct *construction_list
                                        - Input :
                                          Construction information for
                                          the graphic group to be 
                                          constructed.     
         OM_S_OBJID *resultant_obj      - Output:
                                          The objid of the graphic group
                                          object constructed.  
****************************************************************************/
#omdef ems$assoc_intersect_elements(msg,
                                    elem1_info,
                                    elem2_info,
                                    trimming_required = FALSE,
                                    options = NULL,
                                    construction_list,
                                    resultant_obj)
EFassociative_intersect_elements((msg), (options), (trimming_required),
                                 (elem1_info),
                                 (elem2_info), (construction_list), 
                                 (resultant_obj))
#endomdef 

/****************************************************************************

         Description :

         This macro extracts, based on the options, an associative or non-
         associative graphic group of iso-parametric curves of a given
         surface.

         ARGUMENTS :

         IGRlong *EMmsg                -  Output:
                                          Message return code.
                                          -EMS_S_Success,
                                           if the operation is
                                           successful.
                                          -EMS_E_Fail,
                                           in case of a severe
                                           failure.
         struct GRlc_info *surface     -  Input :
                                          Locate information for
                                          the surface whose iso-
                                          parametric curves are
                                          required.
         IGRboolean use_u_curve        -  Input :
                                          A Flag indicating whether
                                          the iso-parametric curves
                                          required are u-constant or
                                          v-constant.
         IGRint num_param              -  Input :
                                          Number of iso-parametric curves
                                          required.
         IGRdouble start_param         -  Input :
                                          The starting parametric value of
                                          the surface, starting from which
                                          the iso-parametric curves are
                                          extracted.
         IGRdouble end_param           -  Input :
                                          The user specified end parametric
                                          value of the uv-space of the surface,
                                          the specified number of iso-
                                          parametric curves getting extracted
                                          over the range spanned by the 
                                          start_param  and the end_param values.         IGRboolean trimming_required  -  Input :
                                          Flag indicating whether the 
                                          extracted iso-parametric are to be
                                          trimmed w.r.t. the surface boundaries
                                          or not.
         unsigned int options          -  Input :
                                          Options specifying whether
                                          associative or non-associative
                                          group of iso-parametric curves to be
                                          constructed.                  
                                          Refer to the include file
                                          EMSasopts.h for associativity
                                          options.
         struct GRvg_construct *construct_list
                                       -  Input :
                                          Construction information for
                                          the graphic group to be
                                          constructed.
          OM_S_OBJID *resultant_obj     -  Output:
                                          The objid of the graphic group
                                          object constructed.
****************************************************************************/
#omdef ems$iso_parametric_curves(msg,
                                 surface,
                                 use_u_curve,
                                 num_param,
                                 start_param,
                                 end_param,
                                 trimming_required = FALSE,
                                 options = NULL,
                                 construction_list,
                                 resultant_obj)  
EFiso_parametric_curves((msg), (options), (trimming_required), (use_u_curve), 
                         (surface),
                         (num_param), (start_param), (end_param), 
                         (construction_list),
                         (resultant_obj))
#endomdef

/*****************************************************************************

         Description :

         This macro creates the feature counter-bore/counter-sink.  The 
         feature can be placed as an associative or non-associative entity.
   
         ARGUMENTS :
      
         IGRlong *msg                   -  Output:
                                           Message return code.
                                           -EMS_S_Success,
                                            if the construction
                                            succeeds.
                                           -EMS_E_NoDynamicMemory,
                                            Failure to allocate
                                            memory.
                                           -EMS_E_Fail,
                                            in case of a severe
                                            failure.
                                           -EMS_E_OMerror,
                                            in case an OM macro
                                            fails.
          struct GRlc_info *surface     - Input :
                                          Locate nformation for the
                                          surface on which a part is
                                          placed.
          IGRint type                   - Input :
                                          type of part to be constructed.
                                          0    -     COUNTERSINK
                                          1    -     COUNTERBORE
          IGRboolean axis_normal        - Input :
                                          Flag indicating whether the 
                                          axis of the part to be placed  
                                          is normal.
          IGRboolean thru_hole          - Input :
                                          Flag indicating whether the
                                          part to be placed is a through
                                          hole or a blind one.
          struct GRevent *center_pt_event
                                        - Input :
                                          center point, at the bottom of the
                                          part to be placed, stored as an 
                                          event structure.
          struct GRevent *bottom_angle_event
                                        - Input :
                                          Counter sink angle stored as an
                                          event structure.
          IGRlong num_parts             - Input :
                                          Number of counter-sink/counter-bore
                                          holes to be placed.
          struct part_data *part_info   - Input :
                                          Information about the counterpart(s)
                                          to be placed.
                                          Refer to the include file EMSfeadef.h
                                          for the fields of the structure 
                                          part_data.
          struct GRevent *counter_depth_event
                                        - Input :
                                          counter-bore/counter-sink depth
                                          stored as an event structure.
          struct GRevent *counter_dia_event
                                        - Input :
                                          counter-bore/counter-sink diameter
                                          stored as an event structure.
          struct GRevent *hole_dia_event
                                        - Input :
                                          The diameter of the hole to be
                                          counter-bored/sunk, stored as an
                                          event structure.
          struct GRevent *hole_depth_event
                                        - Input :
                                          The depth of the hole to be
                                          counter-bored/sunk, stored as an
                                          event structure. 
          IGRushort gen_opts            - Input :
                                          Options indicating whether the
                                          counter-part(s) to be placed
                                          are to be associative or non-
                                          associative.
          IGRushort init_opts           - Input :
                                          Associative options for the
                                          counter-part(s) to be placed.
                                          Refer to the include file EMSasopts.h
                                          for the various associative options
                                          available.                          
                                          Can be NULL, presently.
          struct GRvg_construct *construction_list
                                        - Input :
                                          Construction information for the
                                          for the object to be constructed.
          struct GRid resultant_id      - Output :  
                                          Objid of the object constructed. 
*****************************************************************************/
#omdef ems$place_counterpart(msg,
                             surface,
                             type,
                             axis_normal,
                             thru_hole,
                             center_pt_event,
                             bottom_angle_event,
                             num_parts,
                             part_info,
                             counter_depth_event,
                             counter_dia_event,
                             hole_dia_event,
                             hole_depth_event,
                             gen_opts = NULL,
                             init_opts = NULL,
                             construction_list,
                             resultant_id)    
EFplace_counterpart((msg), (init_opts), (construction_list), (type),
                    (axis_normal),
                    (thru_hole), (center_pt_event), (bottom_angle_event),
                    (surface), (num_parts), (part_info), (counter_depth_event),
                    (counter_dia_event), (hole_dia_event), (hole_depth_event),
                    (resultant_id), (gen_opts))
#endomdef

/****************************************************************************

         Description :

         This macro creates the feature slot.  The feature can be placed as
         a associative or non-associative entity.

         ARGUMENTS :
        
         IGRlong *msg                  -  Output:
                                          Message return code.
                                          -EMS_S_Success,
                                           if construction is
                                           successful.
                                          -EMS_E_NoDynamicMemory,
                                           failure to allocate
                                           dynamic memory.
                                          -EMS_E_Fail,
                                           in case of a severe
                                           failure.
                                          -EMS_E_InvalidArg,
                                           the input arguments
                                           or objects make no sense.
                                          -EMS_E_OMerror,
                                           in case an OM macro
                                           fails.
         IGRushort surface             -  Input :
                                          Locate information for the 
                                          surface on which a slot is
                                          placed.
         IGRboolean is_pro_nor_rev     -  Input :
                                          Flag indicating whether the
                                          prfile normal is reversed or 
                                          not.
         IGRboolean is_dir_rev         -  Input :
                                          Flag indicating whether the
                                          material removal direction
                                          is reversed or not.
         IGRushort *depth_type         -  Input :
                                          For the various depth_types
                                          refer to the include file
                                          EMSasfeatdef.h

                                          0 - thr_all
                                          1 - thru_until
                                          2 - thru_next
                                          3 - finite  

         struct GRevent *depth         -  Input :
                                          The slot depth stored as an
                                          event structure.
         IGRushort gen_opts            -  Input :
                                          Options indicating whether 
                                          the slot is to be placed as
                                          an associative or non-associative
                                          entity. 
         IGRushort init_opts           -  Input :
                                          Associative options for the
                                          slot to be placed.
                                          Refer to the include file EMSasopts.h
                                          for the various associative options
                                          available. 
                                          NULL, presently.  
         struct GRvg_construct *construction_list
                                       -  Input :
                                          Construction information for the
                                          for the object to be constructed.
         struct GRid *resultant_obj     -  Output:
                                          Objid of the object constructed.
****************************************************************************/
#omdef ems$place_slot(msg,
                      surface,
                      is_pro_nor_rev = FALSE,
                      is_dir_rev = FALSE,
                      depth_type,
                      depth,
                      gen_opts = NULL,
                      init_opts = NULL,
                      construction_list,
                      resultant_obj) 
EFplace_slot((msg), (init_opts), (is_dir_rev), 
                     (is_pro_nor_rev), (depth_type), (depth),
                     (surface), (construction_list), (resultant_obj), 
                     (gen_opts))
#endomdef

/****************************************************************************

          Description :

          Given a surface and a set of curves with distances this macro
          will use the set of curves to make faces on the surface and then
          lift the faces by the specified distances.  Curves with the same
          lift distance (i.e. same event) will be placed on the same face.

          The vector, along which the surface is lifted, is determined
          by the normal vector of the surface.  As such, this macro
          will only do something meaningful for planar surfaces.

          If the sign of the lift distance is positive then material is
          added.  If the sign of the lift distance is negative then
          material is removed.

          It is expected that the input curves are closed and planar.
          Ambiguous grouping conditions are not supported and if this
          condition arises it is considered to be an error.

          This macro is used by fast make & lift, Pocket/Boss placement.

          ARGUMENTS :

          IGRlong *msg               -  Output:
                                        -EMS_S_Success,
                                         if successful.
                                        -EMS_E_NoDynamicMemory,
                                         failure to allocate
                                         dynamic memory.
                                        -EMS_E_Fail,
                                         in case of a severe
                                         failure.
          struct GRid *datum_surface -  Input :
                                        Surface on which to place the
                                        features.
          struct GRmd_env *datum_surf_mdenv
                                     -  Input :
                                        Module environment of the datum surface.
          IGRlong number_of_curves   -  Input :
                                        Number of curves to impose as
                                        boundaries.
          struct GRlc_info curves[]  -  Input :
                                        The curves which are used to make faces
                                        on the datum surface.
          struct GRevent lift_distances[]
                                     -  Input :
                                        The distances the faces are to be
                                        lifted to create the features.
          IGRboolean is_drafted      -  Input :
                                        Whether the newly created faces
                                        are to be drafted?
          struct GRevent *draft_angle
                                     -  Input :
                                        If so, the draft angle specified.
          struct GRid top_state_before
                                     -  Input :
                                        Top node in the state tree before
                                        placing any feature.
          IGRint part_type           -  Input :
                                        Feature type to be placed.
                                        part_type == 0  -  POCKET
                                        part_type == 1  -  BOSS
                                        Refer to the include file EMSasfeatdef.h
                                        for pocket/boss definitions.
          GRobjid my_id              -  Input :
                                        The object a method of which is
                                        calling this function.
          IGRushort options          -  Input :
                                        Associativity options related to
                                        initial creation or recompute.
                                        Refer to the file EMSasopts.h for
                                        the various associativity options.
          struct GRvg_construct *construction_list
                                      -  Input :
                                         Construction information for the
                                         object to be constructed.
          struct GRid *top_state_after
                                      -  Output:
                                         Top node after the features are
                                         placed.
          struct GRid *last_lift      -  Output:
                                         The id of the last lifted surface.
          IGRint *num_groups          -  Output:
                                         Number of groups of curves with the
                                         same lift distance.
****************************************************************************/
#omdef ems$gen_liftface_pocket_boss(msg,
                             datum_surface,
                             datum_surf_mdenv,
                             number_of_curves = 1,
                             curves,
                             lift_distances,
                             is_drafted = FALSE,
                             draft_angle,
                             top_state_before,
                             part_type,
                             my_id,
                             options = NULL,
                             construction_list,
                             top_state_after,
                             last_lift,
                             num_groups)
EFgen_make_lift_face((part_type),
                     (datum_surf_mdenv),
                     (datum_surface),
                     (number_of_curves),
                     (curves), 
                     (lift_distances),
                     (is_drafted),
                     (draft_angle), 
                     (options), 
                     (construction_list), 
                     (top_state_before),
                     (my_id), 
                     (top_state_after),
                     (last_lift), 
                     (num_groups), 
                     (msg))
#endomdef

/*****************************************************************************

        Description :

        This macro creates the feature thread.  The feature placed can be
        either associative or non-associative.

        ARGUMENTS :

        IGRlong *msg                    -  Output:
                                           Message return code.
                                           -EMS_S_Success,
                                            if successful.
                                           -EMS_E_Fail,
                                            in case of a severe failure.
                                           -EMS_E_NoDynamicMemory,
                                            failure to allocate memory.
                                           -EMS_E_OMerror,
                                            an OM macro failure.
        struct GRlc_info *surface       -  Input :
                                           Locate information for the surface
                                           on which the thread is going to be
                                           placed.
        IGRboolean is_vec_rev           -  Input :
                                           Flag indicating whether the
                                           material removal direction
                                           is reversed or not.   
        struct GRevent *thread_length   -  Input :
                                           The length of the thread to be
                                           placed stored as an event structure.
        struct GRevent *thread_dia      -  Input :
                                           Thread dia stored as an event 
                                           structure.     
        struct GRevent *threads_per_inch
                                        -  Input :
                                           Number of threads per inch stored
                                           as an event structure.
        IGRchar *thread_text_suffix     -  Input :
                                           Suffix corresponding to thread
                                           standard.
        IGRushort gen_opts              -  Input :
                                           Options to indicate whether the
                                           thread is to be placed as an
                                           associative entity or not.
        IGRushort init_opts             -  Input :
                                           Associative options for the
                                           part to be placed.
                                           Refer to the include file EMSasopts.h
                                           for the various associative options
                                           available. 
                                           Can be NULL.
        struct GRvg_construct *construction_list
                                        -  Input :
                                           Construction information for the
                                           object to be constructed.  
        struct GRid *resultant_id       -  Output:
                                           GRid of the object constructed.
#omdef ems$place_thread(msg,
                        surface,
                        is_vec_rev = FALSE,
                        thread_length,
                        thread_dia,
                        threads_per_inch,
                        thread_text_suffix,
                        gen_opts = NULL,
                        init_opts = NULL,
                        construction_list,
                        resultant_id)
EFplace_thread(msg, init_opts, thread_length, thread_dia, threads_per_inch,
               thread_text_suffix, is_vec_rev, surface, construction_list,
               resultant_id, gen_opts)
#endomdef
*****************************************************************************/
                        
/****************************************************************************

               Description :

               This macro places a blended surface either as an associative
               or non-associative entity.

               ARGUMENTS :
               
               IGRlong *msg            -  Output:
                                          Message return code.
                                          -EMS_S_Success,
                                           if construction is successful.
                                          -EMS_E_DynamicMemoryAllocated, 
                                           failure to allocate memory.
                                          -EMS_E_Fail,
                                           in case of a severe failure.
               IGRint number_of_curves -  Input:
                                          The number of curves involved
                                          in creating the blended surface.
               struct GRlc_info *curve_info[]
                                       -  Input:
                                          Locate information for the above
                                          curves.
               struct GRlc_info *surf_info[] 
                                       -  Input:
                                          If the above curves are part of 
                                          the boundaries of some surfaces,
                                          locate information for the same. 
               struct EMSvalue_info *dist_par
                                       -  Input:
                                          Applicable only when a blend patch
                                          is being created with more than 4
                                          curves. The dist_par controls the
                                          shape of the patch with respect to
                                          the center_point position.  It is as
                                          if the center point is moved with a
                                          distance of dist_par.
                                          Presently not supported.      
               IGRpoint center_point   -  Output:
                                          Info returned to the command.
                                          It is info about the center
                                          of a surface patch with more
                                          than Four sides.
                                          NOTE : A surface patch with more
                                          than Four sides is created using
                                          Five or more curves/surfaces.
               IGRvector normal_vector -  Output: 
                                          Info returned to the command. 
                                          Info about the center of a
                                          surface patch with more than
                                          Four sides.
                                          NOTE :
                                          The command uses center_point &
                                          normal_vector to display the
                                          normal vector and thereafter
                                          allow the user to control the
                                          geometry of a surface patch with
                                          more than Four sides. 
               IGRuint options         -  Input:
                                          Options to indicate whether the
                                          blended surface is to be placed as an
                                          associative entity or not.
               struct GRvg_construct *construction_list
                                       -  Input:
                                          Construction information for the 
                                          blended surface to be placed.
               OM_S_OBJID *constructed_object
                                       -  Output:
                                          The objid of the constructed
                                          object.
****************************************************************************/
#omdef ems$blnd_3_or_more_crvs(msg,
                               number_of_curves,
                               curve_info,
                               surf_info,
                               dist_par,
                               center_point,
                               normal_vector,
                               options = NULL,
                               construction_list,
                               constructed_object)
EFblend_3_or_more_curves((msg), (options), (number_of_curves),
                         (curve_info), (surf_info),
                         (dist_par), (center_point), (normal_vector), 
                         (construction_list), (constructed_object))
#endomdef          

/****************************************************************************

          Description :
         
          This is the macro used to place a drafted surface/solid.
          These can be placed as associative or non-associative entities.

          ARGUMENTS :

          IGRlong *msg            -  Output:
                                     Message return code.
                                     -EMS_S_Success,
                                      if the construction 
                                      is successful.
                                     -EMS_E_Fail,
                                      in case of a severe failure.
          struct EMSobject_info *curve
                                  -  Input :
                                     The cross section information
                                     for the surface to be placed.
          struct EMSpoint_info *vector
                                  -  Input :
                                     Direction vector for the
                                     surface to be placed.
          struct EMSvalue_info *angles
                                  -  Input :
                                     The draft angle.
          IGRint *codes           -  Input :
                                     This info pertains to various
                                     offset options for each component
                                     of the composite curve used in
                                     creating the drafted surface.  

                                     The various codes supported are :

                                     BSCONSTOFF      -  Constant offset.
 
                                     BSPRESERVCVSHP  -  Preserving the
                                                        original curve
                                                        shape after
                                                        offset.
    
                                     BSLINVAROFF     -  Linearly varying
                                                        offset.
                                                
          IGRboolean is_uniform   -  Input :
                                     Flag indicating whether drafting
                                     is to be uniform.
          IGRboolean is_fillet    -  Input :
                                     Flag indicating whether drafting
                                     is to be done with filleting the
                                     corners.
          IGRboolean is_right_side
                                  -  Input :
                                     Flag indicating the offset direction
                                     to create the drafted surface.
         
          IGRboolean is_solid     -  Input :
                                     Flag indicating whether the entity
                                     is to be a solid or a surface.
          IGRushort opts          -  Input :
                                     Options to indicate whether the
                                     surface/solid is to be created as
                                     an associative or non-associative
                                     entity. 
          struct GRvg_construct *construction_list
                                  -  Input :
                                     Construction information for the 
                                     surface/solid to be constructed.      
                                     NOTE : The user should fill in the
                                     construction_list structure before
                                     sending in.
          GRobjid *draft_object   -  Output :
                                     Objid of the drafted surface/solid
                                     constructed.
*****************************************************************************/
#omdef ems$pl_drafted_surface(msg,
                             curve,
                             vector,
                             angles,
                             codes,
                             num_sides,
                             is_uniform = TRUE,
                             is_fillet = FALSE,
                             is_right_side = TRUE,
                             is_solid = TRUE,
                             options = NULL,
                             construction_list,
                             draft_object)
EMplace_drafted_surface ((msg), (options), (construction_list)->env_info,
                         (construction_list)->level,
                         (construction_list)->display,
                         (construction_list)->class_attr,
                         (construction_list)->name,
                         (curve), (vector), (angles), (codes), (num_sides),
                         (is_uniform), (is_fillet), (is_right_side),
                         (is_solid), (draft_object))  
#endomdef    

/****************************************************************************

           Description :

           This is the macro used to place a fillet between two surfaces.
           These can be placed as associative or non-associative entities.

           ARGUMENTS :

           IGRlong *msg            -  Output:
                                      Message return code.
                                      -EMS_S_Success,
                                       if the fillet construction
                                       is successful.
                                      -EMS_S_Fail,
                                       in case of a severe failure.
           struct EMSobject_info *surface1
                                   -  Input :
                                      Surface-1 information.
           IGRboolean natural_normal1
                                   -  Input :
                                      Natural side of surface1.
           struct EMSobject_info *surface2
                                   -  Input :
                                      Surface-2 information. 
           IGRboolean natural_normal2
                                   -  Input :
                                      Natural side of surface1.
           struct EMSpoint_info *start_point
                                   -  Input :
                                      Starting point for the 
                                      fillet surface to be placed.
           struct EMSvalue_info *start_radius
                                   -  Input :
                                      Starting radius for the
                                      fillet surface to be placed.
           struct EMSpoint_info *end_point
                                   -  Input :
                                      End point for the
                                      fillet surface to be placed.   
           struct EMSvalue_info *end_radius
                                   -  Input :
                                      End radius for the fillet
                                      surface to be placed.
           IGRchar *variation_curve
                                   -  Input :
                                      For variable radius rounding,
                                      the transition along the fillet
                                      is specified by the this bsp curve.
                                      Can be NULL.
                                      If NULL, then the transition along
                                      the fillet will be linear.
           IGRdouble rho_value     -  Input :
                                      This value reflects the geometry of
                                      the fillet surface.
                                      full fillet: default(.4142135623730950488)
                                      planar surface: 0.0 (chamfering)
                                      conic section: 0.0 < input_rho < 1.0 
           IGRboolean is_chamfer   -  Input :
                                      Flag to indicate whether the fillet
                                      surface to be placed is to be a
                                      circular one or chamfered. 
           IGRint ext_ind          -  Input :
                                      Fillet property index for external
                                      fillets:
                                      ext_end == 0 - EMS_NO_EXT_FILLET
                                      ext_end == 1 - EMS_EXT_ROLL_BALL_FILLET
                                      ext_end == 2 - EMS_EXT_EXD_FILLET
           IGRint cnv_ind          -  Input :
                                      Fillet property index for convex
                                      (internal)fillets:
                                      cnv_ind == 1 - EMS_INT_ROLL_BALL_FILLET
                                      cnv_ind == 2 - EMS_INT_EXD_FILLET
           IGRint cnc_ind          -  Input :
                                      Fillet property index for concave
                                      fillets:
                                      Presently not supported.
           IGRushort options       -  Input :
                                      Options to indicate whether the
                                      fillet is to be placed as an associative
                                      entity or not.                           
           struct GRvg_construct *construction_list
                                   -  Input :
                                      Construction information for the
                                      object to be constructed.
                                      NOTE : The user should fill in the
                                      construction_list structure before
                                      sending in.
           GRobjid *fillet_object  -  Output:
                                      Objid of the fillet object constructed. 
****************************************************************************/
#omdef ems$place_fillet(msg,
                        surface1,
                        natural_normal1,
                        surface2,
                        natural_normal2,
                        start_point,
                        start_radius,
                        end_point,
                        end_radius,
                        variation_curve = NULL,
                        rho_value = .41421356237309504880,
                        is_chamfer = FALSE,
                        ext_ind = 0,
                        cnv_ind = 1,
                        cnc_ind = 0,
                        options = NULL,
                        construction_list,
                        fillet_object)
EMplace_fillet((msg), (options), (construction_list)->env_info, 
               (construction_list)->level, (construction_list)->display,
               (construction_list)->class_attr, (construction_list)->name,
               (surface1), (natural_normal1), (surface2), (natural_normal2),
               (start_point), (start_radius), (end_point), (end_radius),
               (variation_curve), (rho_value), (is_chamfer), (fillet_object),
               (ext_ind), (cnv_ind), (cnc_ind))
#endomdef 

/*****************************************************************************

             Description :

             This is the macro used to extract the partial surface of a
             given surface either as an associative or non-associative
             entity.

             ARGUMENTS :

             IGRlong *msg           -  Output:
                                       Message return code.
                                       -EMS_S_Success,
                                        if the construction is
                                        successful.
                                       -EMS_E_Fail,
                                        in case of a severe failure.
             struct EMSobject_info *surface
                                    -  Input :
                                       Surface, a part of which is 
                                       to be extracted.
             struct EMSpoint_info *start_point
                                    -  Input :
                                       start point on the surface,
                                       in uv coordinates, starting from
                                       which the partial surface will be
                                       extracted. Should be input through
                                       the GRevent structure pointer in
                                       the EMSpoint_info structure with
                                       the nesting as follows:

                                       start_point->ptevent->located_object[0].
                                              geom_parms.u,v.

             struct EMSpoint_info *end_point
                                    -  Input :
                                       End point on the surface,
                                       in uv coordinates, unto which the
                                       partial surface will be extracted.
                                       Should be input through the GRevent
                                       structure pointer in the
                                       EMSpoint_info structure with the 
                                       nesting as follows:

                                       end_point->ptevent->located_object[0].
                                              geom_parms.u,v.

             struct EMSpoint_info *mid_point
                                    -  Input :
                                       A point for selecting the active
                                       section, in case the input surface
                                       is closed. Also in uv coordinates.
                                       Should be input through the GRevent
                                       structure pointer in the
                                       EMSpoint_info structure with the 
                                       nesting as follows:

                                       mid_point->ptevent->located_object[0].
                                              geom_parms.u,v.

             IGRboolean trimming_required
                                    -  Input :
                                       Flag indicating whether relevant
                                       surface boundaries should be
                                       extracted.                          
             IGRushort options      -  Input :
                                       Options to indicate whether the
                                       partial surface is to be extracted
                                       as an associative entity or not.  
             struct GRvg_construct *construction_list
                                    -  Input :
                                       Construction information for the
                                       object to be constructed.
                                       NOTE : The user should fill in the
                                       construction_list structure before
                                       sending in.
             GRobjid *partsf_obj    -  Output:
                                       Objid of the partial surface object
                                       constructed.
*****************************************************************************/
#omdef ems$place_partial_surface(msg,
                                 surface,
                                 start_point,
                                 end_point,
                                 mid_point,
                                 trimming_required = FALSE,
                                 options = NULL,
                                 construction_list,
                                 partsf_obj)
EMplace_partial_surface((msg), (options), (construction_list)->env_info,
                        (construction_list)->level,
                        (construction_list)->display,
                        (construction_list)->class_attr,           
                        (construction_list)->name,
                        (surface), (start_point), (end_point), (mid_point),
                        (trimming_required), (partsf_obj))
#endomdef       

/*****************************************************************************

             Description :

             This macro creates an associative/non-associative ruled surface
             object.
           
             ARGUMENTS :

             IGRlong *msg             -  Output:
                                         Message return code.
                                         -EMS_S_Success,
                                          If the ruled surface
                                          construction is successful.
                                         -EMS_E_InvalidArg,
                                          if the input arguments do
                                          not make any sense.
                                         -EMS_E_DynamicMemoryAllocated,
                                          failure to allocate memory.
                                         -EMS_E_Bserror,
                                          math function failure.
                                         -EMS_E_Fail,
                                          in case of a severe error
                                          like construction failure.
             struct GRlc_info *crv1_info
                                      -   Input:
                                          Information about first curve.
             struct GRlc_info *crv2_info
                                      -   Input:
                                          Information about second curve. 
             IGRint num_cnt_pts       -   Input:
                                          Number of control points on each
                                          of the input curves.
             IGRdouble *curve1_cnt_pts
                                      -   Input:
                                          Control points for the first curve.
             IGRdouble *curve2_cnt_pts
                                      -   Input:
                                          Control points for the second curve.
             IGRlong ruled_surface_type
                                      -   Input:
                                          Type of ruled surface to be created.
                                          0 - Default
                                          1 - Arc length
                                          2 - Developable  
             IGRushort options        -   Input:
                                          Options to indicate whether the
                                          ruled surface is to be placed as
                                          an associativity entity.
             struct GRvg_construct *construction_list
                                      -   Input:
                                          Construction information for the
                                          object to be constructed.
             OM_S_OBJID *ruledsf_obj  -   Output:
                                          Ruled surface object created. 
*****************************************************************************/
#omdef ems$place_ruled_surface(msg,
                               crv1_info,
                               crv2_info,
                               num_cnt_pts,
                               curve1_cnt_pts,
                               curve2_cnt_pts,
                               ruled_surface_type = 0,
                               options = NULL,
                               construction_list,
                               ruledsf_obj)
EFplace_ruled_surface((msg), (options), (crv1_info), (crv2_info),
                      (ruled_surface_type),
                      (num_cnt_pts), (curve1_cnt_pts), (curve2_cnt_pts), 
                      (construction_list), (ruledsf_obj))
#endomdef    

/****************************************************************************

            Description :
   
            This is the macro used to place a surface to plane solid of
            projection. 
            These can be placed as associative or non-associative entities.
      
            ARGUMENTS :
      
            IGRlong *msg              -  Output:
                                         Message return code.
                                         -EMS_S_Success,
                                          if the construction is
                                          successful.
                                         -EMS_E_Fail,
                                          in case of a severe failure.
            struct EMSobject_info *surface
                                      -  Input:
                                         The surface starting from
                                         which the solid will be
                                         placed. 
            struct EMSplane_info *plane
                                      -  Input:
                                         The infinite plane information
                                         (a pt. & a vector)is extracted
                                         from this input plane.  
            struct EMSvector_info *projection_vector
                                      -  Input:
                                         Direction along which the
                                         projection takes place.
            IGRushort options         -  Input:
                                         Options to indicate whether the
                                         ruled surface is to be placed as
                                         an associativity entity.
            struct GRvg_construct *construction_list
                                      -  Input:
                                         Construction information for the
                                         object to be constructed.
                                         NOTE : The user should fill in the
                                         construction_list structure before
                                         sending in.
            GRobjid *sldprj_obj       -  Output:
                                         Objid of the solid of projection
                                         constructed.  
****************************************************************************/
#omdef ems$pl_surf_to_pln_sld_of_proj(msg,
                                      surface,
                                      plane,
                                      projection_vector,
                                      options = NULL,
                                      construction_list,
                                      sldprj_obj)
EMplace_surface_to_plane_solid_of_proj((msg), (options),
                                       (construction_list)->env_info,
                                       (construction_list)->level,
                                       (construction_list)->display,
                                       (construction_list)->class_attr,
                                       (construction_list)->name,
                                       (surface), (projection_vector),
                                       (plane), (sldprj_obj))
#endomdef   

/*****************************************************************************

            Description :

            This is the macro used to place a surface/solid of projection. 
            These can be placed as associative or non-associative entities.

            ARGUMENTS :

            IGRlong *msg             -  Output:
                                        Message return code.
                                        -EMS_S_Success,
                                         if the construction
                                         succeeds.
                                        -EMS_E_Fail
                                         in case of a severe
                                         failure.
            struct EMSobject_info *curve
                                     -  Input :
                                        The driving curve.
            struct EMSpoint_info *base_point
                                     -  Input :
                                        Base point of the direction
                                        vector.
            struct EMSpoint_info *height_point
                                     -  Input :
                                        Height point of the direction
                                        vector.
            IGRboolean is_solid      -  Input :
                                        Flag to indicate whether the
                                        object to be placed is a solid
                                        or surface of projection.
            IGRushort options        -  Input :
                                        Options to indicate whether the
                                        surface/solid is to be placed as
                                        an associativity entity.  
            struct GRvg_construct *construction_list
                                     -  Input :
                                        Construction information for the
                                        object to be constructed.
            GRobjid *prjn_obj        -  Output:
                                        Solid/surface of projection object.     
*****************************************************************************/
#omdef ems$pl_surf_of_prjn(msg,
                           curve,
                           base_point,
                           height_point,
                           is_solid = TRUE,
                           options = NULL,
                           construction_list,
                           prjn_obj)
EMplace_surf_of_projection((msg), (options), (construction_list)->env_info,
                                     (construction_list)->level,
                                     (construction_list)->display,
                                     (construction_list)->class_attr,
                                     (construction_list)->name,
                                     (curve), (base_point), (height_point),
                                     (is_solid), (prjn_obj)) 
#endomdef

/*****************************************************************************

             Description :

             This is the macro used to place a surface/solid of revolution.
             These can be placed as associative or non-associative entities.

             ARGUMENTS :

             IGRlong *msg            -  Output:
                                        Message return code.
                                        -EMS_S_Success,
                                         if the construction is
                                         successful.
                                        -EMS_E_Fail,
                                         in case of a severe failure.
             struct EMSobject_info *curve
                                     -  Input :
                                        The driving curve.     
             struct EMSpoint_info *axis
                                     -  Input :
                                        The axis information.  
             struct EMSvalue_info *start_angle
                                     -  Input :
                                        The angle starting from
                                        which the surface of rev.
                                        will be placed(Needed only
                                        if the sweep_angle is not 360).
             struct EMSvalue_info *sweep_angle
                                     -  Input :
                                        The angle of sweep.
             IGRushort options       -  Input :
                                        Options to indicate whether the
                                        surface/solid is to be placed as
                                        an associativity entity. 
             struct GRvg_construct *construction_list
                                     -  Input :
                                        Construction information for the
                                        object to be constructed.
             GRobjid *rev_obj        -  Output:
                                        The solid/surface of rev. constructed.
******************************************************************************/
#omdef ems$pl_surf_of_revolution(msg,
                                 curve,
                                 axis,
                                 start_angle = 0.0,
                                 sweep_angle = 360.0,
                                 is_solid = FALSE,
                                 options = NULL,
                                 construction_list,
                                 rev_obj)
EMplace_surf_of_revolution((msg), (options), (construction_list)->env_info,
                           (construction_list)->level,
                           (construction_list)->display,
                           (construction_list)->class_attr,
                           (construction_list)->name,
                           (curve), (axis), (start_angle), (sweep_angle),
                           (is_solid), (rev_obj))
#endomdef
 
/****************************************************************************

            Description :

            This is the macro used to place a tube.
            These can be placed as associative or non-associative entities.

            ARGUMENTS :

            IGRlong *msg           -  Output:
                                      Message return code.
                                      -EMS_S_Success,
                                       if the construction is
                                       successful.
                                      -EMS_E_Fail,
                                       in case of a severe
                                       failure.
            struct EMSobject_info *axis_curve
                                   -  Input :
                                      The input linear curve
                                      along which the tube will
                                      be placed.
            struct EMSvalue_info *tube_radius
                                   -  Input :
                                      The radius of the tube
                                      surface/solid to be placed.
            IGRint num_bend_radii  -  Input :
                                      If the axis_curve is stepped,
                                      number of bend radii to be placed.
            struct EMSvalue_info *bend_radii
                                   -  Input :
                                      The corresponding bend radii.
            IGRushort options      -  Input :
                                      Options to indicate whether the
                                      surface/solid is to be placed as
                                      an associativity entity.
            struct GRvg_construct *construction_list 
                                   -  Input :
                                      Construction information for the
                                      tube object to be constructed.  
            GRobjid *tube_obj      -  Output:
                                      The tube solid/surface object
                                      constructed.
****************************************************************************/
#omdef ems$place_tube(msg,
                      axis_curve,
                      tube_radius,
                      num_bend_radii,
                      bend_radii,
                      is_solid = FALSE,
                      options = NULL,
                      construction_list,
                      tube_obj)
EMplace_tube((msg), (options), (construction_list)->env_info,
             (construction_list)->level,
             (construction_list)->display,
             (construction_list)->class_attr,
             (construction_list)->name,
             (axis_curve), (tube_radius), (num_bend_radii), (bend_radii),
             (is_solid), (tube_obj))
#endomdef    
                              
/*****************************************************************************

          Description :
        
          IGRlong *msg                -  Output:
                                         Message return code.
                                         -EMS_S_Success,
                                          if the operation is
                                          successful.
                                         -EMS_E_InvalidArg,
                                          if the input objects
                                          make no sense.
                                         -EMS_E_NoStackMemory,
                                          failure to allocate
                                          StackMemory.
                                         -EMS_E_BSerror,
                                          call to a math function
                                          fails.  
          IGRushort operation_type    -  Input:
                                         Type of operation to be
                                         performed on the edges.

                                         EMS_CHAMFER_OPR - for chamfering
                                         EMS_ROUND_OPR   - for rounding
                                         EMS_RND_SAMERADIUS - uniform rounding

                                         Refer to the file EMSlmdef.h for
                                         their definitions. 
          IGRint num_edges            -  Input:
                                         The total number of edges to be
                                         rounded or chamfered.
          GRobjid *edges              -  Input:
                                         The edges to be rounded or chamfered.  
          struct EMSvalue_info *radii_or_dist
                                      -  Input:
                                         Rounding radius or set-back distance,
                                         if chamfering.
          IGRushort options           -  Input:
                                         The following associativity options
                                         are supported (EMSasopts.h) :
                                         EMasconst_nonassociative
                                         EMasconst_createsource
          struct GRvg_construct *construction_list
                                      -  Input:
                                         Construction information for the
                                         object to be constructed.
                                         NOTE : The user should fill in the
                                         construction_list structure before
                                         sending in.
          struct GRid *resultant_obj  -  Output:
                                         The resulting object.
#omdef ems$round_chamfer_edges(msg,
                               operation_type,
                               num_edges,
                               edges,
                               radii_or_dist,
                               options = NULL,
                               construction_list,
                               resultant_obj)
EMround_chamfer_edges(msg, options, (construction_list)->env_info,
                      operation_type, num_edges, edges, radii_or_dist,
                      resultant_obj)
#endomdef         
*****************************************************************************/

/******************************************************************************

            Description :

            This macro creates the associative boolean object.

            ARGUMENTS :

            IGRlong *msg               -  Output:
                                          Message return code.
                                          -EMS_S_Success,
                                           if the construction
                                           is successful.
                                          -EMS_E_NoStackMemory,
                                           failure to allocate
                                           Stack Memory.
            IGRint num_opnds           -  Input :
                                          Number of operands involed
                                          in a boolean operation.
            GRobjid *opnd_info         -  Input :
                                          The operands themselves.
            enum EMSbooltype bool_type -  Input :
                                          Type of boolean operation to
                                          be performed.
                                          Refer to the enum EMSbooltype
                                          in the file emsbool.h for the 
                                          various boolean operations.
            IGRushort options          -  Input :
                                          Associativity options.
                                          Refer to the file EMSasopts.h
                                          for the associativity options. 
            struct GRvg_construct *construction_list
                                       -  Input :
                                          Construction information for the
                                          object to be constructed.
            struct GRid *resultant_obj -  Output :
                                          The resulting boolean object. 
******************************************************************************/
#omdef ems$boolean(msg,
                   num_opnds,
                   opnd_info,
                   bool_type,
                   options = NULL,
                   construction_list,
                   resultant_obj)
EFboolean((msg), (options), (num_opnds), (opnd_info),
          (bool_type), (construction_list),
          (resultant_obj))
#endomdef       

/*****************************************************************************

           Description :

           This macro associatively imposes boundaries on a surface.

           ARGUMENTS :

           IGRlong *msg             -  Output:
                                       Message return code.
                                       -EMS_S_Success,
                                        if the operation is
                                        successful.
                                       -EMS_I_NoMoreLoops,
                                        informational message,
                                        in case there are no
                                        loops to impose.
           struct GRlc_info *surface
                                    -  Input :
                                       Surface upon which to impose 
                                       the boundaries. 
           IGRint num_bdrys         -  Input :
                                       Number of boundaries to be
                                       imposed.
           struct GRlc_info *bdrys  -  Input :  
                                       The boundaries themselves.
           IGRdouble *point         -  Input :
                                       Point defining area/hole.
           IGRboolean point_in_area -  Input :
                                       Use the above input point
                                       or auto-nest.   
           IGRint reverse           -  Input :
                                       Reverse vector for recompute?
           IGRdouble dist_along_vect
                                    -  Input :
                                       Distance to move along vector.
           IGRushort options        -  Input :
                                       Either NULL or PLACE_NON_ASSOC
                                       options.
                                       Refer to the file EMSasopts.h
                                       for the various associativity
                                       options.   
           struct GRvg_construct *construction_list
                                    -  Input :
                                       Construction information for the
                                       object to be constructed.
           IGRlong *num_out_points  -  Output :
                                       Number of Xyz points corresponding
                                       to ends of dangling parametric data.
           IGRpoint **out_points    -  Output :
                                       The above Xyz points.
           IGRlong *num_bad_crvs    -  Output :
                                       Number of bad curves - curves not
                                       within tolerance from the surface -
                                       encountered.  
           IGRlong *badcurves       -  Output :
                                       The above bad curves.
           struct GRid *resultant_surface
                                    -  Output :
                                       The surface resulting after the
                                       impose surface boundary operation.
*****************************************************************************/
#omdef ems$impose_boundaries(msg,
                             surface,
                             num_bdrys,
                             bdrys,
                             point,
                             point_in_area = TRUE,
                             reverse,
                             dist_along_vect,
                             options = NULL,
                             construction_list,
                             num_out_points,
                             out_points,
                             num_bad_crvs,
                             bad_crvs,
                             resultant_surface) 
EFimpose_boundaries((msg), (options), (surface),
                    (num_bdrys), (bdrys), (point),
                    (point_in_area), (reverse),
                    (dist_along_vect), (construction_list),
                    (num_out_points), (out_points), (num_bad_crvs), (bad_crvs),
                    (resultant_surface))  
#endomdef

/*****************************************************************************

           Description :

           This macro is responsible for constructing the associative lift face
           object.

           ARGUMENTS :
         
           IGRlong *msg              -  Output:
                                        Message return code. 
                                        -EMS_S_Success,
                                         if the operation is
                                         successful.
                                        -EMS_E_BSerror,
                                         a call to math function
                                         fails.
                                        -EMS_E_NoStackMemory,
                                         failure to allocate stack
                                         memory.
           struct GRlc_info *surface -  Input :
                                        The surface to be lifted.
           struct EMSvector_info *vector
                                     -  Input :
                                        Vector for lift direction.
                                        Can be NULL if the lift is
                                        normal to the surface.
           struct EMSvalue_info  *magnitude
                                     -  Input :
                                        Magnitude of lift.
           IGRboolean lift_with_pos_orient
                                     -  Input :
                                        Normal lift in or out.    
           IGRushort init_options    -  Input :
                                        Options to be used in calling the
                                        functions that are used to create
                                        associative objects in the system.
                                        Presently, NULL.
                                        Refer to the file EMSasopts.h
                                        for the related options.
           IGRushort general_options -  Input :
                                        Options for lift face operation.
                                        Being used for associativity
                                        placement. 
                                        Again refer to the file EMSasopts.h
                                        for the related options. 
           struct GRvg_construct *construction_list
                                     -  Input :
                                        Construction information for the 
                                        lift object to be constructed.
           struct GRid *resultant_obj
                                     -  Output : 
                                        The resulting lift object. 
*****************************************************************************/
#omdef ems$lift_face(msg,
                     surface,
                     vector = NULL,
                     magnitude,
                     lift_with_pos_orient = FALSE,
                     init_options = NULL,
                     general_options = NULL,
                     construction_list,
                     resultant_obj)
EFlift_face((msg), (init_options), (surface), (vector), (magnitude),
            (lift_with_pos_orient), (construction_list), (resultant_obj),
            (general_options))
#endomdef    

/*****************************************************************************

           Description :

           This macro merges a given set of curves.  The parent curves
           will be left behind at the end of the operation.

           ARGUMENTS :

           IGRlong *msg              -  Output:
                                        Message return code.
                                        -EMS_S_Success,
                                         if the operation is 
                                         successful.
                                        -EMS_E_DynamicMemoryAllocated,
                                         failure to allocate dynamic
                                         memory.
                                        -EMS_E_OMerror,
                                         call to an OM macro fails.
                                        -EMS_E_Fail,
                                         in case of a severe failure.
           unsigned int num_curves   -  Input :
                                        Number of curves to be merged.
           struct GRlc_info *curve_info
                                     -  Input :
                                        The parent curves to be merged.
           unsigned int options      -  Input :
                                        Associativity options.
                                        Refer to the file EMSasopts.h
                                        for the various options.
                                        Can be NULL.
           struct GRvg_construct *construction_list
                                     -  Input :
                                        Construction information for the
                                        object to be Constructed.
           OM_S_OBJID *resultant_obj -  Output:
                                        The constructed object.
*****************************************************************************/
#omdef ems$place_merged_curve(msg,
                              num_curves,
                              curve_info,
                              options = NULL,
                              construction_list,
                              resultant_obj)
EFplace_merged_curve((msg), (options), (num_curves),
                     (curve_info), (construction_list),
                     (resultant_obj))
#endomdef    

/****************************************************************************

          Description :

          This macro mirrors and copies element(s) either associatively
          or in a non-associative manner.

          ARGUMENTS :

          IGRlong *msg           -  Output:
                                    Message return code.
                                    -EMS_S_Success,
                                     if the operation is
                                     successful.
                                    -EMS_E_OMerror,
                                     call to an OM macro
                                     fails.
                                    -EMS_E_Fail,
                                     in case of a severe
                                     error.
          struct GRlc_info *elem_info
                                 -  Input :
                                    Element(s) to be copied and
                                    mirrored.
          struct GRlc_info *ref_pln_info  
                                 -  Input :
                                    The plane or reference plane
                                    about which the element(s) are
                                    to be mirrored. 
          unsigned int options   -  Input :
                                    Associativity options.
                                    Refer to EMSasopts.h for the
                                    various options.
          struct GRvg_construct *construction_list
                                 -  Input :
                                    Construction information for
                                    the object to be constructed.
          OM_S_OBJID *resultant_obj 
                                 -  Output:
                                    The resulting object. 
****************************************************************************/
#omdef ems$place_mirror_copy(msg,
                             elem_info,
                             ref_pln_info,
                             options = NULL,
                             construction_list,
                             resultant_obj)
EFplace_mirror_copy((msg), (options), (elem_info),
                    (ref_pln_info), (construction_list),
                    (resultant_obj))
#endomdef     

/*****************************************************************************

            Description :

            This macro creates an associative composite surface object.

            ARGUMENTS :

            IGRlong *msg              -  Output:
                                         Message return code.
                                         -EMS_S_Success,
                                          in case the operation
                                          is successful.
                                         -EMS_I_Fail,
                                          in case the stitching
                                          fails.
            IGRint num_surfs          -  Input :
                                         Number of surfaces passed in.
            OM_S_OBJID *surfaces      -  Input :
                                         Surfaces to make up the composite.
            IGRushort options         -  Input :
                                         EMSasconst_notassociative - the
                                         only option used internally to
                                         place a non-associative compsurf.
                                         No other option is supported.      
            struct GRvg_construct *construction_list
                                      -  Input :
                                         Construction information for the
                                         compsurf to be constructed.
            struct GRid *compsurf     -  Output:
                                         The composite surface object
                                         constructed.  
*****************************************************************************/
#omdef ems$make_comp_surf(msg,
                          num_surfs,
                          surfaces,
                          options = NULL,
                          construction_list,
                          comp_surface)
EFmake_comp_surf((msg), (options), (num_surfs), (surfaces),
                 (construction_list),
                 (comp_surface))
#endomdef   

/****************************************************************************

            Description :

            This macro creates the associative make face object.

            ARGUMENTS :

            IGRlong *msg             -  Output:
                                        Message return code.
                                        -EMS_S_Success,
                                         if the construction is
                                         successful.
                                        -EMS_E_Fail,
                                         in case of a severe
                                         failure.
                                        -EMS_E_OMerror,
                                         a call to an OM macro
                                         fails.
                                        -EMS_E_DynamicMemoryAllocated,
                                         failure to allocate dynamic
                                         memory.
                                        -EMS_E_BSerror,
                                         a call to a math function
                                         fails.
             struct GRlc_info *face_info
                                     -  Input :
                                        The surface which is to be
                                        modified.
             IGRint num_curves       -  Input :
                                        Number of curves being passed in.
             struct GRlc_info *curve_info
                                     -  Input :
                                        Curves which are to be used for
                                        make face.
             IGRushort init_options  -  Input :
                                        Init associativity options.
                                        NULL, presently.
             IGRushort general_options
                                     -  Input :
                                        Presently these can be
                                        -EFfunc_PLACE_NON_ASSOC
                                        -EFfunc_CREATE_SOURCE
                                        For the rest, refer to
                                        the file EMSasopts.h  
             struct GRvg_construct *construction_list
                                     -  Input :
                                        Construction information for
                                        the object to be constructed.  
             struct GRid *resultant_obj
                                     -  Output:
                                        The resulting make face object.
****************************************************************************/
#omdef ems$make_face(msg,
                     face_info,
                     num_curves,
                     curve_info,
                     init_options = NULL,
                     general_options = NULL,
                     construction_list,
                     resultant_obj)
EFmake_face((msg), (init_options), (num_curves),
            (curve_info), (face_info),
            (construction_list), (resultant_obj), (general_options))
#endomdef

/****************************************************************************

            Description :

            This function deletes surface boundaries(imposed) of a given 
            surface.

            ARGUMENTS :

            IGRlong *msg              -  Output:
                                         Message return code.
                                         -EMS_S_Success,
                                          if construction is
                                          successful.
            IGRint num_loops          -  Input :
                                         Number of loops to
                                         be removed.
            struct GRid *loops        -  Input :
                                         The loops to be 
                                         removed.
            struct GRid active_GRid   -  Input :
                                         The active state GRid.
            struct GRvg_construct construction_list
                                      -  Input :
                                         Construction information for
                                         the object to be constructed.
            struct GRid *resultant_obj
                                      -  Output:
                                         The resulting remove boundary
                                         state object.  
****************************************************************************/
#omdef ems$remove_boundaries(msg,
                             num_loops,
                             loops,
                             active_GRid,
                             construction_list,
                             resultant_obj)
EFremove_boundaries((msg), (construction_list), (active_GRid), (num_loops),
                    (loops), (resultant_obj))
#endomdef

/*****************************************************************************

             Description :

            This macro unites two or more coplanar surfaces(eg. a composite
            surface) sharing common edges into a single surface.

             ARGUMENTS :

             IGRlong *msg           -  Output:
                                       Message return code.
                                       -EMS_S_Success,
                                        in case the construction is
                                        successful.  
             IGRint num_surfaces    -  Input :
                                       Number of surfaces to be merged.
             struct GRid *surfaces  -  Input :
                                       The surfaces to be united.
             struct GRid  active_GRid
                                    -  Input :
                                       The active state GRid.
             struct GRvg_construct construction_list
                                    -  Input :
                                       Construction information for the
                                       object to be constructed.
             struct GRid  *resultant_obj
                                    -  Output:
                                       The resulting state object.
*****************************************************************************/
#omdef ems$merge_coincident_surfaces(msg,
                                     num_surfaces,
                                     surfaces,
                                     active_GRid,
                                     construction_list,
                                     resultant_obj)
EFmerge_coincident_surfaces((msg), (construction_list),
                            (active_GRid), (num_surfaces),
                            (surfaces), (resultant_obj))
#endomdef  
/*****************************************************************************

 Description :

 This macro will allow the creation of an associative/non-associative
 part of curve when given the curve, a begin point, an end point,
 and a middle point (if the curve is closed).

 ARGUMENTS :

 IGRlong *msg : O :     -  Output:
                           Message return code.
                           -EMS_S_Success,
                            in case the construction is
                            successful.  
                           -EMS_E_Fail in case there is failure
                           -EMS_E_InvalidArg if the arguments are invalid

 unsigned int options : I :  EMSasconst_notassociative if non-assoc,
                             else NULL. Default is to construct associatively.

 struct GRlc_info *curve_info : I :   The curve from which the extraction needs
                                      to be done
 struct EMSpoint_info *begin_pt : I :   Begin point for extraction
 struct EMSpoint_info *end_pt : I :     End point for extraction
 struct EMSpoint_info *middle_pt : I :  Middle point for extraction,
                                        if the curve is closed

 struct GRvg_construct construction_list : I : 
                                       Construction information for the
                                       object to be constructed.
 GRobjid *resultant_obj : O : Extracted partial curve
*****************************************************************************/

#omdef ems$extract_part_of_curve(msg, options=NULL, curve_info,
                   begin_pt, end_pt, middle_pt,
                   construct_list, resultant_obj)
EFextract_part_of_curve((msg), (options), (curve_info), (begin_pt), (end_pt),
                         (middle_pt), (construct_list), (resultant_obj));
#endomdef

/*****************************************************************************

 Description :

 This macro will allow the creation of an associative/non-associative
 keypoints on a curve when given a closest point to the key point as
 snap point.

 ARGUMENTS :

 IGRlong *msg : O :     -  Output:
                           Message return code.
                           -EMS_S_Success,
                            in case the construction is
                            successful.  
                           -EMS_E_Fail in case there is failure

 unsigned int options : I :  EMSasconst_notassociative if non-assoc,
                             else NULL. Default is to construct
                             associatively.

 IGRpoint snap_point : I : Closest point to the key point
 struct GRlc_info curve_info : I : Curve for which the key point is saught
 struct GRvg_construct *construct_list : I : construction information
 GRobjid *res_id : O : resultant object
*****************************************************************************/

#omdef ems$construct_key_points(msg, options=NULL, snap_point,
                                curve_info,
                                construct_list, res_id)
 EFconstruct_key_points((msg), (options), (snap_point), (curve_info),
                        (construct_list), (res_id));
#endomdef

/*****************************************************************************

 Description :

 This macro will allow the creation of an associative/non-associative
 projection of a curve along a vector onto a surface.

 ARGUMENTS :

 IGRlong *msg : O :     -  Output:
                           Message return code.
                           -EMS_S_Success,
                            in case the construction is
                            successful.  
                           -EMS_E_Fail in case there is failure

 unsigned int options : I :  EMSasconst_notassociative if non-assoc,
                             else NULL. The default is construct
                             the projection associatively.

 struct GRlc_info *curve_info : I : Input curve that needs to be projected
 struct GRlc_info *surf_info  : I : Surface on which the projection needs to
                                    be done
 IGRvector vector : I : Vector along which the projection needs to be done.
                        The system will internally create a vector object
                        that can be constrained using the existing EMS
                        commands.
 IGRboolean trimming_required : I : Whether the curves that are projected
                                    need to be trimmed against boundaries.
                                    The default is TRUE.
 struct GRvg_construct *construct_list : I : Construction information
           
 GRobjid *res_id : O : resultant object
*****************************************************************************/

#omdef ems$project_curve_along_vector_onto_surface(EMmsg, options=NULL,
       curve_info, surf_info, vector, trimming_required=TRUE,
       construct_list, res_id)

    EFproject_curve_along_vector_onto_surface((EMmsg), (options),
         (curve_info), (surf_info), (vector), (trimming_required),
         (construct_list), (res_id));
#endomdef

/*****************************************************************************

 Description :

 This macro will allow the creation of an associative/non-associative
 surface by 3 or 4 boundaries. 

 ARGUMENTS :

 IGRlong *msg : O :     -  Output:
                           Message return code.
                           -EMS_S_Success,
                            in case the construction is
                            successful.  
                           -EMS_E_Fail in case there is failure

 unsigned int options : I :  EMSasconst_notassociative if non-assoc,
                             else NULL. The default is to create
                             an associative surface.

 struct GRlc_info *cv1 : I : Input curve 1
 struct GRlc_info *cv2 : I : Input curve 2
 struct GRlc_info *cv3 : I : Input curve 3
 struct GRlc_info *cv4 : I : Input curve 4 if present. Default is NULL.

 struct GRvg_construct *construct_list : I : Construction information
           
 GRobjid *res_id : O : resultant object
*****************************************************************************/

#omdef ems$surface_by_3_4_boundaries(EMmsg, options=NULL,
  cv1, cv2, cv3, cv4=NULL, construct_list, res_id)
 
 EFcreate_surface_by_3_4_boundaries((EMmsg), (options), (cv1),
   (cv2), (cv3), (cv4), (construct_list), (res_id));
#endomdef

#endif   
     
