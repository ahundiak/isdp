#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/copara/DYangl.I */
extern IGRint DYrblineangl __((struct GRid *param_id, struct ret_struct *line_def, struct GRid *line_id, struct GRmd_env *line_env, struct ret_struct *point_def, struct IGRdisplay *display));
extern IGRint DYlineangl __((struct angl_line_header *info_angl, struct EX_button *point, IGRdouble *matrix, struct GRid **objects, IGRint *num_objects, struct DPele_header **buffer, IGRint *num_buffers, IGRchar **in_dummy1, IGRchar **in_dummy2, IGRchar **in_dummy3, IGRchar **out_dummy1, IGRchar **out_dummy2, IGRchar **out_dummy3));
extern int ASline_angl_param __((struct ret_struct *line_def, struct GRid *line_id, struct GRmd_env *line_env, struct ret_struct *point_def, IGRdouble *point, IGRdouble *view_vect, IGRdouble *snap, IGRdouble *angle));

#if defined(__cplusplus)
}
#endif


#undef __
