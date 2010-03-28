#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/copara/DYpara.I */
extern IGRint DYrblinepara __((struct GRid *param_id, struct ret_struct *line_def, struct IGRdisplay *display, struct GRmd_env *md_env));
extern int t_vector __((double *in, double *p0, double *v0, double *norm, double *out));
extern IGRint DYlinepara __((struct para_line_header *info_para, struct EX_button *point, IGRdouble *matrix, struct GRid **objects, IGRint *num_objects, struct DPele_header **buffer, IGRint *num_buffers, IGRchar **in_dummy1, IGRchar **in_dummy2, IGRchar **in_dummy3, IGRchar **out_dummy1, IGRchar **out_dummy2, IGRchar **out_dummy3));
extern int ASline_para_param __((struct ret_struct *line_def, IGRdouble *pt2, IGRdouble *view_v, IGRdouble *snap, IGRdouble *dist));

#if defined(__cplusplus)
}
#endif


#undef __
