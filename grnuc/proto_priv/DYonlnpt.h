#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/copara/DYonlnpt.I */
extern IGRint DYrbonlnpt __((struct GRid *param_obj, struct ret_struct *linedef, struct GRid *l_grid, struct GRmd_env *l_env, struct ret_struct *pointdef, struct IGRdisplay *display, struct GRmd_env *md_env));
extern IGRint DYonlnpt __((struct online_point_header *info_para, IGRpoint point, IGRdouble *matrix, struct GRid **objects, IGRint *num_objects, struct DPele_header **buffer, IGRint *num_buffers, IGRchar **in_dummy1, IGRchar **in_dummy2, IGRchar **in_dummy3, IGRchar **out_dummy1, IGRchar **out_dummy2, IGRchar **out_dummy3));
extern int ASpointon_param __((struct ret_struct *curve_def, struct GRid *curve_id, struct GRmd_env *curve_env, struct ret_struct *point_def, IGRdouble *pt2, IGRdouble *view_vect, IGRdouble *snap, IGRdouble *param_val));

#if defined(__cplusplus)
}
#endif


#undef __
