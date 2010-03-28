#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/partco/COprtpart.I */
extern IGRint COpart_get_parts_func __((IGRint *msg, struct GRmd_env *mod_env, IGRchar *parts_dir, IGRchar *catalog, struct GRid *part, IGRchar **number, IGRchar **revision, IGRchar **description, IGRint *quantity, IGRint *num));

#if defined(__cplusplus)
}
#endif


#undef __
