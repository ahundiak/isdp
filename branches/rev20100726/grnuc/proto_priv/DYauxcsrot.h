#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/detailco/DYauxcsrot.I */
extern IGRint DYaux_cs_rotate __((IGRlong *msg, IGRboolean mode, IGRpoint origin, IGRpoint handle, IGRpoint handle_norm, IGRdouble *radius, struct GRmd_env *curr_mod, struct GRid *cs_id));
extern IGRint DYaux_cs_rotate_dyn __((struct dyn_args *rot_data, struct EX_button *dypoint, IGRdouble *wld_to_vw, struct GRid **objects, IGRint *num_objects, struct DPele_header **buffers, IGRint *num_buffers, IGRint *in_dummy1, IGRchar *in_dummy2, IGRchar *in_dummy3, IGRchar *reset_dypoint, struct GRmdenv_info **dyn_mod_info, IGRchar *out_dummy3));
extern IGRint GRptnlineproj __((IGRlong *sts, struct IGRline *line1, struct IGRline *line2, IGRpoint point, IGRpoint proj_point));

#if defined(__cplusplus)
}
#endif


#undef __
