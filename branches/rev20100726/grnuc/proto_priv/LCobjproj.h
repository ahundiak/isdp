#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/locate/locate/LCobjproj.C */
extern int LCobj_project __((struct GRevent *event, IGRint display_flag, IGRboolean is_bore, IGRboolean check_for_set, struct GRmd_env *mod));

#if defined(__cplusplus)
}
#endif


#undef __
