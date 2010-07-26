#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/fenceco/COgenseti.I */
extern int COgenset_generate __((Form form, OM_S_OBJID *grset, struct GRmd_env *grset_mod, IGRint *obj_count, IGRint *mod_count));
extern int COgenset_notify __((int f_label, int g_label, double value, Form form));

#if defined(__cplusplus)
}
#endif


#undef __
