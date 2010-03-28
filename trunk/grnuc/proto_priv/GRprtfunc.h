#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/partgo/GRprtfunc.I */
extern IGRint GRpart_get_default_parts_dir __((struct GRmd_env *mod_env, IGRchar *parts_dir));
extern IGRint GRpart_get_default_catalog_dir __((struct GRmd_env *mod_env, IGRchar *parts_dir));
extern IGRint GRpart_make_partdir __((struct GRmd_env *mod_env, IGRchar *parts_dir, IGRchar *catalog, IGRchar *number, IGRchar *revision, IGRchar *partsdir));
extern IGRint GRpart_get_partname __((IGRchar *partdir, IGRchar *partname));
extern IGRint GRpart_get_count __((IGRchar *partdir, struct GRid *part, IGRint *count));
extern IGRint GRpart_copy_partdir __((OMuword from_os, IGRchar *from_partdir, OMuword to_os, IGRchar *to_partdir));
extern IGRint reverse __((IGRchar *s, IGRchar j, IGRchar k));
extern IGRint swap __((IGRchar *p, IGRchar *q));

#if defined(__cplusplus)
}
#endif


#undef __
