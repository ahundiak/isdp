#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/dim_utils/math.I */
extern int MATH_ptdelta __((IGRint *rc, IGRdouble point[3 ], IGRdouble vector[3 ], IGRdouble distance, IGRdouble deltapt[3 ]));
extern int MATH_proj_along_vector __((IGRint *rc, IGRdouble point[3 ], IGRdouble vector[3 ], IGRdouble line[6 ], IGRdouble projection[3 ]));
extern int MATH_rotate_vector __((IGRint *rc, IGRdouble vector[3 ], IGRdouble angle, IGRdouble plane[16 ], IGRdouble rotvec[3 ]));
extern int MATH_get_box_points __((int *msg, struct IGRlbsys *lbsys, double box[4 ][3 ]));
extern int MATH_intersect_box_line __((IGRint *msg, IGRdouble line[2 ][3 ], IGRdouble box[4 ][3 ], IGRdouble intpt[2 ][3 ], IGRboolean *intersect, IGRdouble plane[16 ]));
extern int MATH_compute_plan_info __((int *msg, double meas_axis[3 ], double win[16 ], double act[16 ]));
extern int MATH_line_break __((int *msg, double term_pt[3 ], double break_pt[3 ], double plane[16 ], double box[4 ][3 ], double endpt[3 ]));
extern int MATH_line_extend __((int *msg, double term_pt[3 ], double break_pt[3 ], double box[4 ][3 ], double extpt[3 ]));
extern int MATH_get_box_pt_upar __((int *msg, int flag, double *upar, double point[3 ], struct GRid text_grid, struct GRmd_env *md_env));
extern double MATH_fix_dbl __((double d));

#if defined(__cplusplus)
}
#endif


#undef __
