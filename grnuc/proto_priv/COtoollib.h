#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/toolco/COtoollib.I */
extern IGRint COis_om_file __((FILE *fp));
extern IGRint COtool_access_file __((IGRint *msg, IGRchar *name, IGRchar *path));
extern int COtool_same_file __((char *file1, char *file2));
extern int COtool_strip_quotes __((char *s));
extern int COtool_fi_message __((Form form, int label, int msgnumb, int delay_to_clear));
extern int COtool_ci_strcmp __((char *s, char *t));
extern int COtool_make_set __((IGRint *msg, struct GRmd_env *mod_env, struct GRid *gr_ids, IGRint num, struct GRid *gs_id));

#if defined(__cplusplus)
}
#endif


#undef __
