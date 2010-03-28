/* #######################    APOGEE COMPILED   ######################## */
#include "igrtypedef.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "gr.h"
#include "igrmacros.h"
#include "FI.h"
extern IGRlong CO_ni_place_circle_by_center();
extern IGRlong CO_ni_place_hael_axis();
extern IGRlong CO_ni_place_qrtel_axis();
extern IGRlong CO_ni_place_el_axis();
extern IGRlong CO_ni_place_el_cnt();
extern IGRlong DYrbcirdiam();
extern IGRlong DYrbcircnt();
extern IGRlong DYrbcirrad();
extern IGRlong DYrbellcnt();
extern IGRlong DYrbhalfell();
extern IGRlong DYrbquartell();
extern IGRlong DYrbellaxis();
extern IGRlong CO_ni_place_circle_by_diameter();
extern IGRlong CO_ni_place_linear();
extern IGRlong DYrblinear();
extern IGRlong CO_ni_place_block();
extern IGRlong CO_ni_place_rotblk();
extern IGRlong DYrbblock();
extern IGRlong DYrbrotblk();
extern IGRlong CO_ni_place_point();
extern IGRlong CO_ni_modify_element();
extern IGRlong CO_ni_extend_element();
extern IGRlong CO_ni_split_element();
extern IGRlong CO_ni_delete_vertex();
extern IGRlong CO_ni_place_circle_by_3pts();
extern IGRlong CO_ni_place_arc_3pts();
extern IGRlong CO_ni_place_arc_cent();
extern IGRlong CO_ni_place_arc_radcnt();
extern IGRlong CO_ni_place_arc_rad();
extern IGRlong DYrbarc3pt();
extern IGRlong DYrbarcendpt();
extern IGRlong DYrbarccnt();
extern IGRlong DYrbarccntrad();
extern IGRlong DYrbarcrad();
extern IGRlong CO_ni_insert_vertex();
extern IGRlong DYrb2ptmodify();
extern IGRlong DYrbcircle_by_2pts_radius();
extern IGRlong DYrbcircle_by_3pt();
extern IGRlong CO_ni_measure_distance_to_projection();
extern IGRlong CO_ni_measure_length_along_element();
extern IGRlong CO_ni_measure_radius();
extern IGRlong CO_ni_measure_area();
extern IGRlong CO_ni_measure_diameter();
extern IGRlong CO_ni_measure_distance_btwn_2pts();
extern IGRlong CO_ni_measure_length();
extern IGRlong CO_ni_place_inf_line();
extern IGRlong CO_ni_place_fillet();
extern IGRlong CO_ni_partial_delete();
extern IGRlong CO_ni_move_segment();
extern IGRlong CO_ni_measure_angle_by_3_pts();
extern IGRlong DYrbmsang3pt();
extern IGRlong CO_ni_extend_1_insect();
extern IGRlong CO_ni_extend_2_insect();
extern IGRlong CO_ni_measure_angle_by_2_pts();
extern IGRlong CO_ni_measure_line_angle();
extern IGRlong DYrbfixed_linear();
extern IGRlong CO_ni_place_polygon();
extern IGRlong CO_ni_place_horizontal_line();
extern IGRlong CO_ni_place_vertical_line();
extern IGRlong CO_ni_place_line_at_active_angle();
extern IGRlong DYrbtriangle();
extern IGRlong DYrb_add_pt_modify();
extern IGRlong DYrbbadmodify();
extern IGRlong DYrbproject_linear();
extern IGRlong DYrb_line_active_angle();
extern IGRlong DYrb_vertical_line();
extern IGRlong DYrb_horizontal_line();
extern IGRlong CO_ni_line_at_minimum_distance();
extern IGRlong CO_ni_place_npoly_by_vertex();
extern IGRlong DYrbnpolygon();
extern IGRlong CO_ni_place_angle_bisector_3pt();
extern IGRlong DYrbangbis3pt();
extern IGRlong DYrbconstruct_line();
extern IGRlong DYrborthline();
extern IGRlong DYrborthpoly();
extern IGRlong CO_ni_place_el_2pts();
extern IGRlong CO_ni_place_el_3pts();
extern IGRlong DYel_by_2pts();
extern IGRlong DYel_by_3pts();
extern IGRlong CO_ni_place_tentat_point();
extern IGRlong CO_ni_point_between_2_pts();
extern IGRlong CO_ni_delta_view();
extern IGRlong CO_ni_delta_world();
extern IGRlong CO_ni_abs_wld_coord();
extern IGRlong CO_ni_dist_dir_view();
extern IGRlong CO_ni_pt_along_element();
extern IGRlong CO_ni_place_crosshatch();
extern IGRlong CO_ni_place_line_terminator();
extern IGRlong CO_ni_place_equal_pts();
extern IGRlong CO_ni_measure_min_dis_2_ele();
extern IGRlong CO_ni_measure_min_dist_point_to_element();
extern IGRlong CO_ni_cd();
extern IGRlong CO_ni_mkdir();
extern IGRlong CO_ni_remove();
extern IGRlong CO_ni_rmdir();
#ifndef IDRAW
extern IGRlong CO_ni_measure_angle_of_line_and_axis();
extern IGRlong CO_ni_measure_angle_of_2_pts_and_axis();
extern IGRlong DYrbfixlinear();
extern IGRlong DYfixbuflinear();
extern IGRlong CO_const_current_pt_form();
extern IGRlong CO_ni_show_variable();
extern IGRlong CO_ni_set_variable();
extern IGRlong CO_ni_set_active_CS_type();
extern IGRlong CO_ni_measure_angle_between_2_lines();
extern IGRlong CO_ni_fragment_element();
extern IGRlong CO_ni_ang2bis();
extern IGRlong CO_ni_perbis();
extern IGRlong CO_ni_measure_sweep_angle();
extern IGRlong CO_ni_modify_axis();
extern IGRlong CO_ni_place_circle_by_2pts_radius();
extern IGRlong CO_ni_toggle_dir_mode();
extern IGRlong CO_ni_cdpath();
extern IGRlong CO_ni_pwd();
extern IGRlong CO_ni_shownm();
/*extern IGRlong DYrbraspoly();*/
/*extern IGRlong DYrbraspolt();*/
/*extern IGRlong DYrbfitted();*/
/*extern IGRlong DYrbraspold();*/
/*extern IGRlong DYrbraspolr();*/
extern IGRlong CO_ni_place_circle_tan_chord();
extern IGRlong DYrbcirchd();                            
extern IGRlong CO_ni_place_arc_tan_chord();
extern IGRlong DYrbarcchd();
#endif

extern IGRlong CO_ni_dummy_func();


typedef IGRlong ( *CO_p_FUNCPTR)();

CO_p_FUNCPTR CO_GA_ni_funcs[] = 
{
    CO_ni_dummy_func,                       /*    0    */
    CO_ni_place_circle_by_center,           /*    1     */
    CO_ni_place_hael_axis,                  /*    2     */
    CO_ni_place_qrtel_axis,                 /*    3     */
    CO_ni_place_el_axis,                    /*    4     */
    CO_ni_place_el_cnt,                     /*    5     */
    DYrbcirdiam,                            /*    6     */
    DYrbcircnt,                             /*    7     */
    DYrbcirrad,                             /*    8     */
    DYrbellcnt,                             /*    9     */
    DYrbhalfell,                            /*    10    */
    DYrbquartell,                           /*    11    */
    DYrbellaxis,                            /*    12    */
    CO_ni_place_circle_by_diameter,         /*    13    */
    CO_ni_place_linear,                     /*    14    */
    DYrblinear,                             /*    15    */
    CO_ni_place_block,                      /*    16    */
    CO_ni_place_rotblk,                     /*    17    */
    DYrbblock,                              /*    18    */
    DYrbrotblk,                             /*    19    */
    CO_ni_place_point,                      /*    20    */
    CO_ni_modify_element,                   /*    21    */
    CO_ni_extend_element,                   /*    22    */
    CO_ni_split_element,                    /*    23    */
    CO_ni_delete_vertex,                    /*    24    */
    CO_ni_place_circle_by_3pts,             /*    25    */
#ifndef IDRAW
    CO_ni_place_circle_by_2pts_radius,      /*    26    */
#else
    CO_ni_dummy_func,                       /*    26d   */
#endif /* IDRAW */
    CO_ni_place_arc_3pts,                   /*    27    */
    CO_ni_place_arc_cent,                   /*    28    */
    CO_ni_place_arc_radcnt,                 /*    29    */
    CO_ni_place_arc_rad,                    /*    30    */
    DYrbarc3pt,                             /*    31    */
    DYrbarccnt,                             /*    32    */
    DYrbarccntrad,                          /*    33    */
    DYrbarcrad,                             /*    34    */
    CO_ni_insert_vertex,                    /*    35    */
    DYrb2ptmodify,                          /*    36    */
#ifndef IDRAW
    CO_ni_modify_axis,                      /*    37    */
#else
    CO_ni_dummy_func,                       /*    37d   */
#endif /* IDRAW */
    DYrbcircle_by_2pts_radius,              /*    38    */
    DYrbcircle_by_3pt,                      /*    39    */
    CO_ni_measure_distance_to_projection,   /*    40    */
#ifndef IDRAW
    CO_ni_measure_sweep_angle,              /*    41    */
#else
    CO_ni_dummy_func,                       /*    41d   */
#endif /* IDRAW */
    CO_ni_measure_length_along_element,     /*    42    */
    CO_ni_measure_radius,                   /*    43    */
    CO_ni_measure_area,                     /*    44    */
    CO_ni_measure_diameter,                 /*    45    */
    CO_ni_measure_distance_btwn_2pts,       /*    46    */
    CO_ni_measure_length,                   /*    47    */
    CO_ni_place_inf_line,                   /*    48    */
    CO_ni_place_fillet,                     /*    49    */
    CO_ni_partial_delete,                   /*    50    */
    CO_ni_move_segment,                     /*    51    */
    CO_ni_measure_angle_by_3_pts,           /*    52    */
    DYrbmsang3pt,                           /*    53    */
    CO_ni_extend_1_insect,                  /*    54    */
    CO_ni_extend_2_insect,                  /*    55    */
#ifndef IDRAW
    CO_ni_ang2bis,                          /*    56    */
    CO_ni_perbis,                           /*    57    */
#else
    CO_ni_dummy_func,                       /*    56d   */
    CO_ni_dummy_func,                       /*    57d   */
#endif /* IDRAW */
    CO_ni_place_equal_pts,                  /*    58    */
#ifndef IDRAW
    CO_ni_measure_angle_by_2_pts,           /*    59    */
#else
    CO_ni_dummy_func,                       /*    59d   */
#endif  /* IDRAW */
    CO_ni_measure_line_angle,               /*    60    */
#ifndef IDRAW
    CO_ni_measure_angle_between_2_lines,    /*    61    */
#else
    CO_ni_dummy_func,                       /*    61d   */
#endif  /* IDRAW */
    DYrbfixed_linear,                       /*    62    */
#ifndef IDRAW
    CO_ni_fragment_element,                 /*    63    */
#else
    CO_ni_dummy_func,                       /*    63d   */
#endif /* IDRAW */
    CO_ni_place_polygon,                    /*    64    */
    CO_ni_place_horizontal_line,            /*    65    */
    CO_ni_place_vertical_line,              /*    66    */
    CO_ni_place_line_at_active_angle,       /*    67    */
    DYrbtriangle,                           /*    68    */
    DYrb_add_pt_modify,                     /*    69    */
    DYrbbadmodify,                          /*    70    */
    DYrbproject_linear,                     /*    71    */
    DYrb_line_active_angle,                 /*    72    */
    DYrb_vertical_line,                     /*    73    */
    DYrb_horizontal_line,                   /*    74    */
    CO_ni_line_at_minimum_distance,         /*    75    */
    CO_ni_place_npoly_by_vertex,            /*    76    */
    DYrbnpolygon,                           /*    77    */
    CO_ni_place_angle_bisector_3pt,         /*    78    */
    DYrbangbis3pt,                          /*    79    */
    DYrbconstruct_line,                     /*    80    */
    DYrborthline,                           /*    81    */
    DYrborthpoly,                           /*    82    */
    CO_ni_measure_min_dis_2_ele,            /*    83    */
    CO_ni_place_el_2pts,                    /*    84    */
    CO_ni_place_el_3pts,                    /*    85    */
    DYel_by_2pts,                           /*    86    */
    DYel_by_3pts,                           /*    87    */
    CO_ni_place_tentat_point,               /*    88    */
    CO_ni_dummy_func,                       /*    89d   */
    CO_ni_dummy_func,                       /*    90d   */
    CO_ni_dummy_func,                       /*    91d   */
    CO_ni_dummy_func,                       /*    92d   */
    CO_ni_dummy_func,                       /*    93d   */
    CO_ni_dummy_func,                       /*    94d   */
    CO_ni_dummy_func,                       /*    95d   */
#ifndef IDRAW
    CO_ni_show_variable,                    /*    96    */
    CO_ni_set_variable,                     /*    97    */
    CO_ni_set_active_CS_type,               /*    98    */
#else
    CO_ni_dummy_func,                       /*    96d   */
    CO_ni_dummy_func,                       /*    97d   */
    CO_ni_dummy_func,                       /*    98d   */
#endif  /* IDRAW */
    CO_ni_point_between_2_pts,              /*    99    */
#ifndef IDRAW
    CO_const_current_pt_form,               /*    100   */
#else
    CO_ni_dummy_func,                       /*    100d  */
#endif  /* IDRAW */
    CO_ni_delta_view,                       /*    101   */
    CO_ni_delta_world,                      /*    102   */
    CO_ni_abs_wld_coord,                    /*    103   */
    CO_ni_dist_dir_view,                    /*    104   */
    CO_ni_pt_along_element,                 /*    105   */
    CO_ni_place_crosshatch,                 /*    106   */
#ifndef IDRAW
    CO_ni_measure_angle_of_line_and_axis,   /*    107   */
    CO_ni_measure_angle_of_2_pts_and_axis,  /*    108   */
    DYrbfixlinear,                          /*    109   */
    DYfixbuflinear,                         /*    110   */
#else
    CO_ni_dummy_func,                       /*    107d  */
    CO_ni_dummy_func,                       /*    108d  */
    CO_ni_dummy_func,                       /*    109d  */
    CO_ni_dummy_func,                       /*    110d  */
#endif  /* IDRAW */
    CO_ni_cd,                               /*    111   */
#ifndef IDRAW
    CO_ni_cdpath,                           /*    112   */
#else
    CO_ni_dummy_func,                       /*    112d  */
#endif  /* IDRAW */
    CO_ni_mkdir,                            /*    113   */
#ifndef IDRAW
    CO_ni_pwd,                              /*    114   */
#else
    CO_ni_dummy_func,                       /*    114d  */
#endif  /* IDRAW */
    CO_ni_remove,                           /*    115   */
    CO_ni_rmdir,                            /*    116   */
#ifndef IDRAW
    CO_ni_shownm,                           /*    117   */
    CO_ni_toggle_dir_mode,                  /*    118   */
#else
    CO_ni_dummy_func,                       /*    117d  */
    CO_ni_dummy_func,                       /*    118d  */
#endif /* IDRAW */
    CO_ni_place_line_terminator,            /*    119   */
    CO_ni_measure_min_dist_point_to_element,/*    120   */
#ifndef IDRAW
    CO_ni_place_circle_tan_chord,           /*    121   */
    DYrbcirchd,                             /*    122   */
    CO_ni_place_arc_tan_chord,              /*    123   */
    DYrbarcchd,                             /*    124   */
#else
    CO_ni_dummy_func,                       /*    121d  */
    CO_ni_dummy_func,                       /*    122d  */
    CO_ni_dummy_func,                       /*    123d  */
    CO_ni_dummy_func,                       /*    124d  */
#endif
    DYrbarcendpt,                           /*    125   */
};

int CO_ni_max_number_funcs  = 125;

double   xhatch_angle = .78539816299999998;
double   xhatch_spacing = .25;
short    xhatch_assoc_flag = 1;
int      GR_G_dir_mode = 1;
char     coglobal_data_expansion_buf[508] = {0};
Form     p_CurrentPointForm = NULL;  /* pointer to persistant form data */

