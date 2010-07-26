#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/detailco/DYauxview.I */
extern IGRint DYauxview_init __((struct GRmd_env *mod_env, IGRmatrix matrix, IGRpoint origin, struct IGRline *normal, struct IGRline *fold_line, struct GRid *caller_id, OM_p_CHANSELECT chansel));
extern IGRint DYauxview __((struct dyn_args *dptr, struct EX_button *point, IGRdouble *mtx, struct GRid **objects, IGRint *num_objects, struct DPele_header **buffers, IGRint *num_buffers, IGRchar *in_dummy1, IGRchar *in_dummy2, IGRchar *in_dummy3, IGRchar **out_dummy1, struct GRmdenv_info **out_dummy2, IGRchar **out_dummy3));
extern IGRint GRauxview_build_rot_matrix __((IGRlong *msg, IGRpoint origin, struct IGRline *normal, IGRpoint point, IGRmatrix result_matrix));

#if defined(__cplusplus)
}
#endif


#undef __
