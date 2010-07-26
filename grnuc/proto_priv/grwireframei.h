#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/grwireframei.I */
extern int GRgetmd_env __((struct GRmd_env *md_env, struct GRmd_env *local_env, struct GRmd_env **env));
extern int GRgetpolyline_struct __((IGRlong *msg, struct GRid *object_id, struct GRmd_env *md_env, struct IGRpolyline *polyline));
extern int GRgetconic_struct __((IGRlong *msg, struct GRid *object_id, struct GRmd_env *md_env, struct IGRarc *arc));
extern int GRreverse_curve __((IGRlong *msg, struct GRid *object_id, struct GRmd_env *md_env));
extern int GRget_endpoints __((IGRlong *msg, struct GRid *object_id, struct GRmd_env *md_env, IGRdouble *point1, IGRdouble *point2));
extern int GRproject_point __((IGRlong *msg, struct GRid *object_id, struct GRmd_env *md_env, IGRdouble *vec_start, IGRdouble *vec_end, IGRdouble *point, IGRdouble *proj_pt, IGRdouble *u_parm, IGRdouble *v_parm));
extern int GRgetcurve_struct __((IGRlong *msg, struct GRid *object_id, struct GRmd_env *md_env, struct IGRbsp_curve **curve_struct));
extern int GRputcurve_struct __((IGRlong *msg, struct GRid *object_id, struct GRmd_env *md_env, struct IGRbsp_curve *curve_struct, IGRint display_flag, GRobjid *new_id));
extern int GRfree_curve __((struct IGRbsp_curve *curve_struct));
extern int GRcreate_linestring __((IGRint *msg, struct GRmd_env *md_env, IGRint num_points, IGRdouble *points, struct GRid *object_id, IGRchar *name, IGRint display_flag));
extern int GRcreate_conic_by_edge __((IGRint *msg, struct GRmd_env *md_env, int flag, IGRdouble *start_point, IGRdouble *dir_point, IGRdouble *end_point, struct GRid *object_id, IGRchar *name, IGRint display_flag));
extern int GRcreate_conic_by_center __((IGRint *msg, struct GRmd_env *md_env, IGRint flag, IGRdouble *center, IGRdouble *start_point, IGRdouble *end_point, struct GRid *window_id, struct GRid *object_id, IGRchar *name, IGRint display_flag));

#if defined(__cplusplus)
}
#endif


#undef __
