#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/detailco/DYprinview.I */
extern IGRint DYprinview_init __((struct GRmd_env *mod_env, IGRpoint origin, struct IGRlbsys *model_lbsys, IGRint *proj_angle, struct GRid *caller_id, OM_p_CHANSELECT chansel));
extern IGRint DYprinview __((struct dyn_args *dptr, struct EX_button *point, IGRdouble *mtx, struct GRid **objects, IGRint *num_objects, struct DPele_header **buffers, IGRint *num_buffers, IGRchar *in_dummy1, IGRchar *in_dummy2, IGRchar *in_dummy3, IGRchar **out_dummy1, struct GRmdenv_info **out_dummy2, IGRchar **out_dummy3));
extern IGRint GRprinview_build_rot_matrix __((IGRlong *msg, IGRint *proj_angle, IGRmatrix window_matrix, IGRpoint origin, struct IGRlbsys *model_lbsys, IGRpoint point, IGRpoint vector, IGRmatrix result_matrix, struct IGRline lines[], IGRint *num_lines));
extern IGRint GRprinview_build_lines __((IGRlong *msg, IGRmatrix window_matrix, struct IGRlbsys *lb, struct IGRline *line1, struct IGRline *line2, struct IGRline lines[], IGRint *num_lines));
static check_face __((IGRlong *msg, IGRpoint pts[], IGRpoint view, IGRint index1, IGRint index2, IGRint index3, IGRint index4, struct IGRline *line1, struct IGRline *line2, struct IGRline lines[], IGRint *num_lines));

#if defined(__cplusplus)
}
#endif


#undef __
