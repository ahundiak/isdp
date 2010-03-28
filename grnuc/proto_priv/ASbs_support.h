#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/gopara/ASbs_support.I */
extern int ASadjust_u __((IGRdouble *u_enter, IGRdouble *u_exit, struct IGRbsp_curve *bc));
extern int ASadjust_i __((IGRint i_enter, IGRint *i_exit, struct IGRbsp_curve *bc));
extern int AStangent __((struct IGRbsp_curve *bc, IGRvector normal, IGRdouble *u_init, IGRdouble *u_final, IGRdouble *p_final, IGRvector tangent));
extern int ASvertex_position __((struct IGRbsp_curve *bc, IGRint iv, IGRdouble *point));
extern int ASangle_on_vertex __((struct IGRbsp_curve *bc, IGRint iv));
extern int ASfind_nearest_vertex __((struct IGRbsp_curve *bc, IGRint test, IGRdouble max_distance, IGRdouble tol, IGRpoint point, IGRpoint vertex_point, IGRint *vertex_num, IGRdouble *distance));
extern int ASedit_bsp __((struct IGRbsp_curve bs));
extern int ASproject_in_xy __((IGRdouble *t, IGRint line, IGRpoint from_pt, IGRpoint to_pt));
extern int AStotlen __((IGRlong *rc, struct IGRbsp_curve *bc, IGRdouble *len));
extern int ASarclen __((IGRlong *rc, IGRboolean *bsstat, struct IGRbsp_curve *bc, IGRdouble *par1, IGRdouble *par2, IGRdouble *par, IGRdouble *len));
extern int ASgenabsg __((struct GRid *obj, char **bc));
extern int ASgetabsg __((struct GRid *obj, int index, char **bc));
extern int ASmdstptcv __((struct IGRbsp_curve *bc, double *pt_init, double *par, double *pt_res, double *dist, long *rc));

#if defined(__cplusplus)
}
#endif


#undef __
