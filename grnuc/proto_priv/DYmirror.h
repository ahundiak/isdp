#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/manipco/DYmirror.I */
extern IGRint DYmirror __((struct GRid *mirr_object, struct GRevent *event, struct COmnlcdyn *add_info));
extern IGRint DYmirror_dyn __((struct dyn_args *mirr_data, struct EX_button *mirr_point, IGRdouble *mtx, struct GRid **objects, IGRint *num_objects, struct DPele_header **buffers, IGRint *num_buffers, IGRchar *in_dummy1, IGRchar *in_dummy2, IGRchar *in_dummy3, IGRchar **out_dummy1, struct GRmdenv_info **dyn_mod_info, IGRchar **out_dummy3));

#if defined(__cplusplus)
}
#endif


#undef __
