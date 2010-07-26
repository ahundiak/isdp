#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/dim_utils/dynamics.I */
extern IGRint DMinvoke_dynamics __((IGRint *msg, IGRint dynamics, IGRint msgkey, IGRint preproc, IGRint postproc, IGRchar pre_state, IGRchar post_state, IGRint copy, struct GRid *cp_grid, IGRint control, struct GRmd_env *md_env, struct GRevent *event, struct GRid *dim_grid));
extern IGRint DMdynamics __((char *info, struct EX_button *pnt, IGRdouble *rot_matrix, struct GRid **objects, IGRint *num_objects, struct DPele_header **buffer, IGRint *num_buffers, IGRchar **in_dummy1, IGRchar **in_dummy2, IGRchar **in_dummy3, IGRchar **out_dummy1, IGRchar **out_dummy2, IGRchar **out_dummy3));

#if defined(__cplusplus)
}
#endif


#undef __
