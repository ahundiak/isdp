#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/dim_utils/angutils.I */
extern IGRint DMselect_sector __((IGRint *msg, IGRdouble line1[2 ][3 ], IGRdouble line2[2 ][3 ], IGRdouble *selpt, struct DMplan_info *plan_info, double *trak_dist, int *sector));
extern IGRint DMang_compute_proj_line __((struct DMdim_root *src_line, IGRdouble term_pt[3 ], IGRdouble proj_line[6 ], IGRdouble proj_extn, IGRdouble proj_offs));
extern IGRint math_abs_ang __((double *vec1, double *angle, struct dim_plan_info *plan_info));
extern int math_ang_bet_lines __((double *vec1, double *vec2, double *angle, double *norm));
extern int math_get_dir_vec __((int *rc, double *centerpt, double *startpt, double *endpt, double *norm_vec, int *flag));
extern int DMget_ang_txt_info __((struct DMplan_info *plan_info, struct DMloc_param *p_loc, double *txt_vec_orie, double *norm_vec, IGRshort *txt_just, double *breakpt, double *centerpt, int leader, double lead_dist));
extern int MATH_intersect_circle_line __((IGRint *msg, IGRdouble centerpt[3 ], IGRdouble rad, IGRint *num_inter, IGRdouble interpt[2 ][3 ], IGRdouble box_in[12 ], IGRdouble plane[16 ]));
extern int DMget_txt_length __((struct GRid text_grid, double *min_length, double *max_length, struct GRmd_env *md_env, struct DMplan_info *plan_info));
extern IGRint DMproject_points __((IGRint *msg, IGRpoint p0, IGRpoint p1, IGRpoint p2, IGRpoint p3, IGRvector norm, IGRpoint pt));

#if defined(__cplusplus)
}
#endif


#undef __
