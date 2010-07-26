#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/transco/COcvtcltype2.I */
extern IGRint COcvtcltype2 __((IGRlong *rc, struct IGDS_cell *igdscell, IGRdouble *scalefactor, IGRlong *IGDSfiletype, struct GRmd_env *current_env, struct GRid *object_info, struct GRmd_env ModuleInfo));

#if defined(__cplusplus)
}
#endif


#undef __
