#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/gopara/ASintpti.I */
extern int find_inter_case __((struct ret_struct *in0, struct ret_struct *in1, struct ret_struct **out0, struct ret_struct **out1, struct GRid *obj0, struct GRid *obj1));
extern int cmp_int_line_line __((IGRdouble *p0, IGRdouble *v0, IGRdouble *p1, IGRdouble *v1, IGRdouble *int_pt));
extern int cmp_int_line_circle __((IGRdouble *p0, IGRdouble *v0, struct circle_data *circle_st, IGRdouble *res1, IGRdouble *angle1, IGRdouble *res2, IGRdouble *angle2));
extern int cmp_int_line_lbs __((IGRdouble *p0, IGRdouble *p00, struct lbs_data *lbs_def, IGRdouble *init_pt, IGRint flag, IGRdouble *result, IGRdouble *other));
extern int cmp_int_circle_lbs __((struct circle_data *cir_def, struct lbs_data *lbs_def, IGRdouble *res1, IGRdouble *res_an1, IGRdouble *res2, IGRdouble *res_an2));
extern int choice_circle_lbsys __((IGRint in_flag, IGRdouble *near_point, IGRdouble *point0, IGRdouble angle0, IGRdouble *point1, IGRdouble angle1, IGRint *nb_res));
static get_extended_geom __((struct GRid *obj, IGRchar **geometry));
static cmp_int_cv_cv __((struct GRid *obj0, struct GRid *obj1, double *pt_init, double *pt_res));

#if defined(__cplusplus)
}
#endif


#undef __
