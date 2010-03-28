#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/gopara/inter_lib.I */
extern void pr_point __((IGRchar *str, IGRpoint pt));
extern void pr_mat __((IGRchar *str, IGRshort nb_lgn, IGRshort nb_col, IGRdouble *mat));
extern IGRint mes_angle __((IGRdouble radius, IGRpoint start_p, IGRpoint end_p, int flag, IGRdouble *teta1, IGRdouble *teta2, IGRdouble *dif));
extern IGRint point_on_circle __((IGRpoint cent, IGRdouble rad, IGRdouble *mat, IGRdouble *pt, IGRdouble *p_circle));
extern IGRint point_on_line __((IGRpoint pa, IGRpoint va, IGRpoint p, IGRpoint onlnpt));
extern int line_prox_line __((IGRpoint pa, IGRpoint va, IGRpoint pb, IGRpoint vb, IGRdouble *ta, IGRdouble *tb));
extern IGRint unit_vect __((IGRpoint p0, IGRpoint p1, IGRpoint vect_ptr));
extern IGRint cmp_intersection_line_circle __((double *p0, double *p1, struct circle_data circle_st, double *ch_pt, double *pt_ptr, IGRint *orient));
extern IGRint cmp_intersection_circle_circle __((struct circle_data circle_st1, struct circle_data circle_st2, double *ch_pt, double *pt_ptr, IGRint *orient));
extern int modulo __((IGRdouble *angle, IGRdouble div));
extern int ASarc_pts __((int *msg, struct ret_struct *arc_struct, double *start_pt, double *sweep_pt));
extern int ASproj __((IGRlong *msg, IGRdouble *t, IGRboolean pj_pts, IGRint nb_pts, IGRdouble *pts_in, IGRdouble *pts_out));
extern void zzz __((void));

#if defined(__cplusplus)
}
#endif


#undef __
