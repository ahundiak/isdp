#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/dim_angular/dimline_a.I */
extern int DMget_inter_point __((double *cenpt, double *endpt, double *intpt, double *loc_pt));
extern int DMget_pt_at_angle __((double *pt1, double *pt2, double arc_r, double plane[16 ], double *endpt, double ext_len, int type));

#if defined(__cplusplus)
}
#endif


#undef __
