#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/manipco/DYmirrorl.I */
extern IGRint DYmirrorl __((IGRlong *msg, GRobjid caller_id, OMuword caller_os, struct EX_button *point1, struct GRmd_env *curr_mod, OM_S_CHANSELECT *gschan, struct GRevent *event));
extern IGRint DYmirrorl_dyn __((struct dyn_args *mirr_data, struct EX_button *point2, IGRdouble *view_mx, struct GRid **objects, IGRint *num_objects, struct DPele_header **buffers, IGRint *num_buffers, IGRchar *in_dummy1, IGRchar *in_dummy2, IGRchar *in_dummy3, IGRchar **out_dummy1, struct GRmdenv_info **dyn_mod_info, IGRchar **out_dummy3));

#if defined(__cplusplus)
}
#endif


#undef __
