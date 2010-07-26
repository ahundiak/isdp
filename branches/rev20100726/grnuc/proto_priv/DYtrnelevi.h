#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/detailco/DYtrnelevi.I */
extern IGRint DYtranslate_element_vi_init __((IGRpoint origin, struct GRid *obj_id));
extern IGRint DYtranslate_element_vi __((struct dyn_args *dptr, struct EX_button *point, IGRdouble *mtx, struct GRid **objects, IGRint *num_objects, struct DPele_header **buffers, IGRint *num_buffers, IGRchar *in_dummy1, IGRchar *in_dummy2, IGRchar *in_dummy3, IGRchar **out_dummy1, struct GRmdenv_info **out_dummy2, IGRchar **out_dummy3));

#if defined(__cplusplus)
}
#endif


#undef __
