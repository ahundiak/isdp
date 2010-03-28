#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/partco/COprtsave.I */
extern IGRint COpart_save_func __((IGRint *msg, struct GRmd_env *mod_env, struct GRid *part, struct GRevent *origin, IGRchar *cell_name, IGRchar *cell_desc));

#if defined(__cplusplus)
}
#endif


#undef __
