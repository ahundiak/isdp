#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/transco/COcvtype5lv9.I */
extern IGRint COcvt_type5lv9 __((IGRlong *msg, struct IGDS_ref_file *ref, IGRint *db_type, IGRdouble *scale_factor, struct GRid *object_info, struct GRmd_env *current_env));

#if defined(__cplusplus)
}
#endif


#undef __
