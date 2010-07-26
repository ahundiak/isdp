#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/partco/COprtattr.I */
extern IGRint COpart_attr_func __((IGRint func_index, IGRint *msg, struct GRmd_env *mod_env, IGRchar *parts_dir, IGRchar *catalog, struct GRid *part, IGRchar *number, IGRchar *revision, IGRchar *attr, IGRint *index, IGRchar *value, IGRint *type, IGRint *num));

#if defined(__cplusplus)
}
#endif


#undef __
