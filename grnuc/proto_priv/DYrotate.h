#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/manipco/DYrotate.I */
extern IGRint DYrotate __((IGRlong *msg, GRobjid caller_id, OMuword caller_os, struct EX_button *origin, struct EX_button *handle, IGRdouble *radius, struct GRmd_env *curr_mod, OM_S_CHANSELECT *gschan, struct GRevent *event));
extern IGRint DYrotate_dyn __((struct dyn_args *rot_data, struct EX_button *dypoint, IGRdouble *wld_to_vw, struct GRid **objects, IGRint *num_objects, struct DPele_header **buffers, IGRint *num_buffers, IGRint *in_dummy1, IGRchar *in_dummy2, IGRchar *in_dummy3, IGRchar *reset_dypoint, struct GRmdenv_info **dyn_mod_info, IGRchar *out_dummy3));

#if defined(__cplusplus)
}
#endif


#undef __
