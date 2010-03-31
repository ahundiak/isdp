/*
HISTORY

03-Feb-1988 jBk Changed DEBUG definition so it occurs only if
                DEBUG is not yet defined.
*/

# ifndef DEBUG
# define DEBUG 0
# endif

# define ACCEPT_IS_DATA 1

# ifndef EMScmacros_include
# include "EMScmacros.h"
# endif

# ifndef EMSlogic_include
# include "EMSlogic.h"
# endif

#if DEBUG
#define ERROR(sts_stupid, error_number, error_message, label)\
 {\
    if (EMSmsgReport (sts_stupid, error_message, FALSE) OR \
    EMSmsgReport (error_number, error_message, FALSE)) \
    goto label; \
 }
#else
#define ERROR(sts_stupid, error_number, error_message, label)\
 {\
  if (! (1 & sts_stupid & error_number)) goto label;\
 }
#endif


/* grutil.h replacement */

# ifndef OM_D_MINIMUM
# include "OMminimum.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

# ifndef godef_include
# include "godef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

# ifndef go_include
# include "go.h"
# endif

# ifndef ex_include
# include "ex.h"
# endif

# ifndef griodef_include
# include "griodef.h"
# endif

# ifndef grio_include
# include "grio.h"
# endif

/* end of grutil.h replacement */

# ifndef NULL
# define NULL 0
# endif

# ifndef TRUE
# define TRUE  1
# endif
# ifndef FALSE
# define FALSE 0
# endif

# if ACCEPT_IS_DATA
#   ifndef ACCEPT
#       define ACCEPT DATA
#   endif
# endif

/****************************************************************
                        PROMPT STRINGS
****************************************************************/

# define ECsP_Input_vec_pt_1         "Input point 1 of direction vector"
# define ECsP_Input_vec_pt_2         "Input point 2 of direction vector"
# define ECsP_Input_point_1_of_plane "Input point 1 of plane"
# define ECsP_Input_point_2_of_plane "Input point 2 of plane"
# define ECsP_Input_point_3_of_plane "Input point 3 of plane"
# define ECsP_Does_planar_surf_exist "Does planar surface exist y/n [n]"
# define ECsP_Identify_plane_surf "Identify planar surface"
# define ECsP_Accept_reject_surf "Accept/reject surface"
# define ECsP_Identify_surf_project "Identify surface to project"
# define ECsP_Identify_solid     "Identify solid"
# define ECsP_Accept_reject_sol  "Accept/reject solid"
# define ECsP_Solid_not_found    "Solid not found"
# define ECsP_Enter_chord_tol    "Enter chord-height tolerance [0.1]"
# define ECsP_Identify_sol_seg   "Identify a surface of a solid"
# define ECsP_Accept_reject_sol_seg \
                                 "Accept/reject surface of solid"
# define ECsP_Sol_seg_not_found  "Surface of solid not found"

# define ECsP_Accept_loc_new_reject_undo \
                                 "Accept to add to tree/reject to undo"
# define ECsP_Input_from_pt      "Input from point"
# define ECsP_Input_to_pt        "Input to point"
# define ECsP_Enter_scale_factor "Enter scale factor > 0"
# define ECsP_Input_ctr          "Input center point"
# define ECsP_Input_axispt       "Input major axis point"
# define ECsP_Enter_ctr_radius   "Enter radius of circular section at ctr"
# define ECsP_Input_focus1       "Input first focus point"
# define ECsP_Input_focus2       "Input second focus point"
# define ECsP_Enter_major_axlen  "Enter major axis length"

# define ECsP_Input_major_point  "Input semi-major base axis point"
# define ECsP_Input_minor_point  "Input semi-minor base axis point"
# define ECsP_Input_top_major_point \
                                 "Input semi-major upper axis point"
# define ECsP_Input_pt_1         "Input point 1"
# define ECsP_Input_pt_2         "Input point 2"
# define ECsP_Input_pt_3         "Input point 3"
# define ECsP_Input_pt_4         "Input point 4"
# define ECsP_Input_pt_5         "Input point 5"
# define ECsP_Input_pt_6         "Input point 6"
# define ECsP_Input_pt_7         "Input point 7"
# define ECsP_Input_pt_8         "Input point 8"

# define ECsP_Input_pt_one_box   "Input point 1 of box"
# define ECsP_Input_pt_two_box   "Input point 2 of box"
# define ECsP_Input_corner_pt    "Input corner point"
# define ECsP_Input_width_pt     "Input width point"
# define ECsP_Input_depth_pt     "Input depth point"
# define ECsP_Identify_surface   "Identify surface"
# define ECsP_Input_extract_pt   "Input extract point"
# define ECsP_Input_dir_pt       "Input direction point"
# define ECsP_Enter_number_to_ext \
                                 "Enter number to extract"
# define ECsP_Input_range        "Input range point"
# define ECsP_NULL               ""
# define ECsP_Element_not_found  "Element not found"
# define ECsP_Curve_not_found    "Curve not found"
# define ECsP_Surf_not_found     "Surface not found"
# define ECsP_Identify_curve     "Identify curve"
# define ECsP_Accept_reject_cv   "Accept/reject curve"
# define ECsP_Enter_top_radius   "Enter top radius"
# define ECsP_Enter_bottom_radius \
                                 "Enter bottom radius"
# define ECsP_Input_base_point   "Input base point"
# define ECsP_Input_height_point "Input height point"
# define ECsP_Identify_elt       "Identify element"
# define ECsP_Identify_curve_move \
                                 "Identify curve/move on"
# define ECsP_Identify_surf_move "Identify surface/move on"
# define ECsP_Identify_elt_move  "Identify element/move on"
# define ECsP_Input_point_1_of_base \
                                 "Input point 1 of base"
# define ECsP_Input_point_2_of_base \
                                 "Input point 2 of base"
# define ECsP_Accept_reject_vert "Accept with from point/reject vertex"
# define ECsP_Accept_reject_edge "Accept with from point/reject edge"
# define ECsP_Accept_reject_loop "Accept with from point/reject face"
# define ECsP_Accept_reject_elt  "Accept/reject element"
# define ECsP_Accept_loc_next_sf_reject_elt \
                                 "Accept (locate next surface)/reject"
# define ECsP_Accept_loc_next_cv_reject_elt \
                                 "Accept (locate next curve)/reject"
# define ECsP_Accept_loc_next_reject_elt \
                                 "Accept (locate next element)/reject"
# define ECsP_Accept_with_pt     "Accept with endpoint/reject"
# define ECsP_Accept_with_align_pt \
                                 "Accept with aligning endpoint/reject"
# define ECsP_Input_control_c0   "Input control pt on first curve"
# define ECsP_Input_control_c0_move \
                                 "Input control pt on first curve/move on"
# define ECsP_Input_control_c1   "Input control pt on second curve"
# define ECsP_Input_pt           "Input point"

/****************************************************************
                        STATUS STRINGS
****************************************************************/

# define ECsS_Surface_not_planar      "Surface is not planar"
# define ECsS_Surface_is_closed       "Surface is closed"
# define ECsS_Solid_is_prim           "Solid is already a primitive"
# define ECsS_Cannot_drop             "Cannot drop to surfaces"
# define ECsS_Cannot_undo_state       "Cannot undo primitive solid"
# define ECsS_Accept_reject_change    "Please accept/reject this change"
# define ECsS_Surface_not_a_solid     "Surface not part of a solid"
# define ECsS_Point_in_cv_plane       "Point is in the curves plane"
# define ECsS_Curve_not_planar        "Curve is not planar"
# define ECsS_Curve_not_closed        "Curve is not closed"
# define ECsS_Axis_len_lt_foci_dist   "Axis length < foci distance"
# define ECsS_Cone_axis_parallel_ellipse \
                                      "Cone axis parallel to ellipse"
# define ECsS_Axis_point_modified     "Axis point modified"
# define ECsS_Point_was_on_face       "Point is on a face"
# define ECsS_Point_not_on_face       "Point not on a face"
# define ECsS_Points_in_same_plane    "Points are in the same plane"
# define ECsS_Height_pt_modified      "Height point was modified"
# define ECsS_Point_was_projected     "Pt. was projected on curves plane"
# define ECsS_Point_was_modified      "Point was modified"
# define ECsS_Depth_pt_modified       "Depth point was modified"
# define ECsS_Depth_point_was_on_face "Depth point is on face"
# define ECsS_Solid_not_constructed   "Solid not constructed"
# define ECsS_Processing              "Processing"
# define ECsS_U_direction             "U parameter extraction"
# define ECsS_V_direction             "V parameter extraction"
# define ECsS_Invalid_input           "Invalid input"
# define ECsS_Must_be_unique_points   "Must be unique points"
# define ECsS_Points_are_collinear    "Points are collinear"
# define ECsS_Zero_height             "Zero height"
# define ECsS_Zero_length_axis        "Zero axis length"
# define ECsS_No_default_supplied     "No default is supplied"
# define ECsS_Radius_too_small        "Radius too small"
# define ECsS_Cone_radius_too_small   "Cone radius is too small"
# define ECsS_Element_not_constructed "Element not constructed"
# define ECsS_Curve_not_constructed   "Curve not constructed"
# define ECsS_Surface_not_constructed "Surface not constructed"       

/****************************************************************
                        COMMAND STRINGS
****************************************************************/

# define ECsM_Place_sol_proj   "Solid of projection - surface to plane"
# define ECsM_Make_prim            "Make solid a primitive"
# define ECsM_Drop_solid           "Drop solid to surfaces"
# define ECsM_Undo_solid_mod       "Undo solid modification"
# define ECsM_Union_solids         "Union two solids"
# define ECsM_Intersect_solids     "Intersect two solids"
# define ECsM_Difference_solids    "Difference two solids"
# define ECsM_Move_face_on_solid   "Move face on solid"
# define ECsM_Move_edge_on_solid   "Move edge on solid"
# define ECsM_Move_vertex_on_solid "Move vertex on solid"
# define ECsM_Place_cap_sol_cv_tr  "Place cap solid by curve and trace"
# define ECsM_Place_solid_ell_ctr  "Place solid ellipsoid -ctr. axis rad."
# define ECsM_Place_solid_ell_foci "Place solid ellipsoid -foci axis len."
# define ECsM_Place_solid_tel_cone "Place solid trunc. elliptical cone"

# define ECsM_Place_solid_rel_cylinder \
                                   "Place solid right elliptical cylinder"
# define ECsM_Place_solid_cone     "Place solid right trunc. cone"
# define ECsM_Place_solid_4f_4v_poly \
                                   "Place solid 4 face 4 vert. polyhedron"
# define ECsM_Place_solid_5f_5v_poly \
                                   "Place solid 5 face 5 vert. polyhedron"
# define ECsM_Place_solid_5f_6v_poly \
                                   "Place solid 5 face 6 vert. polyhedron"
# define ECsM_Place_solid_6f_7v_poly \
                                   "Place solid 6 face 7 vert. polyhedron"
# define ECsM_Place_solid_6f_8v_poly \
                                   "Place solid 6 face 8 vert. polyhedron"
# define ECsM_Place_solid_right_angle_wedge \
                                   "Place solid right angle wedge"
# define ECsM_Place_solid_box      "Place solid box by two points"
# define ECsM_Ptdist               "Distance from point to element"
# define ECsM_DistanceEqualLF      "Distance = %lf"
# define ECsM_Place_rectangular_plane \
                                   "Place rectangular plane 3 points"
# define ECsM_Place_parallelogram_plane \
                                   "Place parallelogram plane 3 points"
# define ECsM_Place_cone           "Place cone by axis and radii"
# define ECsM_Place_ruled_surface  "Place ruled surface - no control"
# define ECsM_Merge_curves         "Merge curves"
# define ECsM_Make_merged_cv       "Make merged curve"
# define ECsM_Merge_surfaces       "Merge surfaces"
# define ECsM_Make_merged_sf       "Make merged surface"
# define ECsM_Extract_cv           "Isoparametric curves of a surface"
# define ECsM_Place_ruled_cp       "Place ruled surface - control"

/****************************************************************
                         ERROR STRINGS
****************************************************************/

